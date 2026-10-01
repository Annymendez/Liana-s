/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author annym
 */
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;

@WebServlet("/documento")
public class DocumentoServlet extends HttpServlet {

    // Carpeta fija fuera del proyecto — no se borra al recompilar
    public static final String UPLOAD_DIR = "C:/mercadored_docs";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Solo admin puede ver documentos
        HttpSession session = req.getSession(false);
        model.Persona usuario = (model.Persona) (session != null ? session.getAttribute("usuario") : null);
        if (usuario == null || !"admin".equals(usuario.getTipo())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Acceso denegado.");
            return;
        }

        String archivo = req.getParameter("archivo");

        // Seguridad: evitar path traversal
        if (archivo == null || archivo.contains("..") || archivo.contains("/") || archivo.contains("\\")) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Nombre de archivo inválido.");
            return;
        }

        File file = new File(UPLOAD_DIR, archivo);

        if (!file.exists() || !file.isFile()) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND,
                "Documento no encontrado en: " + file.getAbsolutePath());
            return;
        }

        // Tipo de contenido
        String nombre = file.getName().toLowerCase();
        if      (nombre.endsWith(".pdf"))                             resp.setContentType("application/pdf");
        else if (nombre.endsWith(".jpg") || nombre.endsWith(".jpeg")) resp.setContentType("image/jpeg");
        else if (nombre.endsWith(".png"))                             resp.setContentType("image/png");
        else                                                          resp.setContentType("application/octet-stream");

        resp.setContentLengthLong(file.length());
        resp.setHeader("Content-Disposition", "inline; filename=\"" + file.getName() + "\"");

        try (FileInputStream fis = new FileInputStream(file);
             OutputStream os = resp.getOutputStream()) {
            byte[] buf = new byte[4096];
            int n;
            while ((n = fis.read(buf)) != -1) os.write(buf, 0, n);
        }
    }
}
