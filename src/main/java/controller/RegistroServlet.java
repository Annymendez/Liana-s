/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author annym
 */

import dao.PersonaDAO;
import dao.VendedorDAO;
import model.Persona;
import model.Vendedor;
import util.EmailService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Random;

@WebServlet("/registro")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,
    maxFileSize       = 5 * 1024 * 1024,
    maxRequestSize    = 10 * 1024 * 1024
)
public class RegistroServlet extends HttpServlet {

    private final PersonaDAO  personaDAO  = new PersonaDAO();
    private final VendedorDAO vendedorDAO = new VendedorDAO();

    // Misma carpeta fija que DocumentoServlet
    private static final String UPLOAD_DIR = "C:/mercadored_docs";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/registro.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String paso = req.getParameter("paso");
        try {
            if ("2".equals(paso)) procesarVerificacion(req, resp);
            else                  procesarRegistro(req, resp);
        } catch (SQLException e) {
            req.setAttribute("error", "Error del sistema: " + e.getMessage());
            req.getRequestDispatcher("/registro.jsp").forward(req, resp);
        }
    }

    private void procesarRegistro(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {

        String nombre     = req.getParameter("nombre");
        String documento  = req.getParameter("documento");
        String correo     = req.getParameter("correo");
        String celular    = req.getParameter("celular");
        String direccion  = req.getParameter("direccion");
        String contrasena = req.getParameter("contrasena");
        String tipo       = req.getParameter("tipo");

        // CA001: campos obligatorios
        if (nombre == null || nombre.isBlank() || documento == null || documento.isBlank()
         || correo == null || correo.isBlank() || celular == null || celular.isBlank()
         || direccion == null || direccion.isBlank() || contrasena == null || contrasena.isBlank()) {
            req.setAttribute("error", "Todos los campos obligatorios deben estar diligenciados. (CA001)");
            req.setAttribute("datos", req.getParameterMap());
            req.getRequestDispatcher("/registro.jsp").forward(req, resp);
            return;
        }

        // CA002: duplicados
        if (personaDAO.existeDocumentoOCorreo(documento, correo)) {
            req.setAttribute("error", "Ya existe una cuenta con ese documento o correo electrónico. (CA002)");
            req.setAttribute("datos", req.getParameterMap());
            req.getRequestDispatcher("/registro.jsp").forward(req, resp);
            return;
        }

        // CA005: contrato de comisión
        if ("vendedor".equals(tipo)) {
            String acepta = req.getParameter("aceptaContrato");
            if (!"si".equals(acepta)) {
                req.setAttribute("error", "Debes aceptar el contrato de comisión para registrarte como vendedor. (CA005)");
                req.setAttribute("datos", req.getParameterMap());
                req.getRequestDispatcher("/registro.jsp").forward(req, resp);
                return;
            }
        }

        // Crear persona
        Persona p = new Persona();
        p.setNombre    (nombre.trim());
        p.setDocumento (documento.trim());
        p.setCorreo    (correo.trim());
        p.setCelular   (celular.trim());
        p.setDireccion (direccion.trim());
        p.setContrasena(contrasena);
        p.setTipo      (tipo);

        int idPersona = personaDAO.crear(p);
        if (idPersona < 0) {
            req.setAttribute("error", "No se pudo crear la cuenta. Inténtalo de nuevo.");
            req.getRequestDispatcher("/registro.jsp").forward(req, resp);
            return;
        }

        // CA004 / CA011: datos del vendedor + documento digital
        if ("vendedor".equals(tipo)) {
            String docPath = null;
            try {
                Part filePart = req.getPart("docDigital");
                if (filePart != null && filePart.getSize() > 0) {
                    String nombreArchivo = idPersona + "_" + obtenerNombreArchivo(filePart);

                    // Guardar en carpeta fija C:/mercadored_docs
                    File uploadDir = new File(UPLOAD_DIR);
                    if (!uploadDir.exists()) uploadDir.mkdirs();

                    filePart.write(UPLOAD_DIR + File.separator + nombreArchivo);
                    docPath = nombreArchivo; // solo el nombre, sin ruta
                }
            } catch (Exception e) {
                System.err.println("Error al guardar documento: " + e.getMessage());
            }

            Vendedor v = new Vendedor();
            v.setIdPersona      (idPersona);
            v.setCuentaBancaria (req.getParameter("cuentaBancaria"));
            v.setBanco          (req.getParameter("banco"));
            v.setDocumentoPath  (docPath);
            vendedorDAO.crear(v);
        }

        // Enviar código por correo
        String codigo = String.format("%06d", new Random().nextInt(999999));
        try {
            EmailService.enviarCodigo(correo.trim(), nombre.trim(), codigo, "registro de cuenta");
        } catch (Exception e) {
            req.setAttribute("error", "Cuenta creada pero no se pudo enviar el correo: " + e.getMessage());
            req.getRequestDispatcher("/registro.jsp").forward(req, resp);
            return;
        }

        // CA003: sesión de verificación
        HttpSession session = req.getSession(true);
        session.setAttribute("codigoVerif",    codigo);
        session.setAttribute("idPersonaVerif", idPersona);
        session.setAttribute("nombreVerif",    nombre.trim());
        session.setAttribute("correoVerif",    correo.trim());

        req.setAttribute("nombre",  nombre.trim());
        req.setAttribute("correo",  correo.trim());
        req.setAttribute("esLogin", false);
        req.getRequestDispatcher("/verificar.jsp").forward(req, resp);
    }

    private void procesarVerificacion(HttpServletRequest req, HttpServletResponse resp)
            throws SQLException, ServletException, IOException {

        String      codigo  = req.getParameter("codigo");
        HttpSession session = req.getSession(false);

        if (session == null) { resp.sendRedirect(req.getContextPath() + "/registro"); return; }

        String codigoReal = (String)  session.getAttribute("codigoVerif");
        int    idPersona  = (Integer) session.getAttribute("idPersonaVerif");
        String nombre     = (String)  session.getAttribute("nombreVerif");
        String correo     = (String)  session.getAttribute("correoVerif");

        if (!codigoReal.equals(codigo)) {
            req.setAttribute("error",   "Código incorrecto. Revisa tu correo.");
            req.setAttribute("nombre",  nombre);
            req.setAttribute("correo",  correo);
            req.setAttribute("esLogin", false);
            req.getRequestDispatcher("/verificar.jsp").forward(req, resp);
            return;
        }

        personaDAO.activarCuenta(idPersona);
        session.removeAttribute("codigoVerif");
        session.removeAttribute("idPersonaVerif");
        session.removeAttribute("nombreVerif");
        session.removeAttribute("correoVerif");
        resp.sendRedirect(req.getContextPath() + "/login?msg=registrado");
    }

    private String obtenerNombreArchivo(Part part) {
        String header = part.getHeader("content-disposition");
        if (header == null) return "documento";
        for (String token : header.split(";")) {
            if (token.trim().startsWith("filename")) {
                return new File(token.substring(token.indexOf('=') + 1).trim().replace("\"", "")).getName();
            }
        }
        return "documento";
    }
}
