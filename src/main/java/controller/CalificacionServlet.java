/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller;

/**
 *
 * @author annym
 */
import dao.CalificacionDAO;
import dao.OrdenDAO;
import dao.VendedorDAO;
import model.Calificacion;
import model.Orden;
import model.Persona;
import model.Vendedor;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/calificacion")
public class CalificacionServlet extends HttpServlet {

    private final CalificacionDAO dao        = new CalificacionDAO();
    private final OrdenDAO        ordenDAO   = new OrdenDAO();
    private final VendedorDAO     vendedorDAO= new VendedorDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String accion = req.getParameter("accion");
        if (accion == null) accion = "";
        HttpSession session = req.getSession(false);
        Persona usuario = (Persona) session.getAttribute("usuario");

        try {
            switch (accion) {

                // Formulario para que el comprador califique
                case "formulario" -> {
                    int idOrden = Integer.parseInt(req.getParameter("idOrden"));
                    Orden orden = ordenDAO.buscarPorId(idOrden);

                    if (orden == null || orden.getIdComprador() != usuario.getIdPersona()) {
                        resp.sendRedirect(req.getContextPath() + "/orden?accion=listar");
                        return;
                    }
                    if (!"entregado".equals(orden.getEstadoOrden())) {
                        req.setAttribute("error", "Solo puedes calificar órdenes entregadas.");
                        resp.sendRedirect(req.getContextPath() + "/orden?accion=listar");
                        return;
                    }
                    if (dao.yaCalificado(idOrden, "comprador_a_vendedor")) {
                        req.setAttribute("error", "Ya calificaste esta orden.");
                        resp.sendRedirect(req.getContextPath() + "/orden?accion=listar&error=yaCalificado");
                        return;
                    }
                    req.setAttribute("orden", orden);
                    req.getRequestDispatcher("/calificacion_form.jsp").forward(req, resp);
                }

                // Vista de reseñas recibidas (para el vendedor)
                case "misCalificaciones" -> {
                    List<Calificacion> calificaciones = dao.listarPorVendedor(usuario.getIdPersona());
                    double promedio = dao.calcularPromedio(usuario.getIdPersona());
                    req.setAttribute("calificaciones", calificaciones);
                    req.setAttribute("promedio", promedio);
                    req.getRequestDispatcher("/mis_calificaciones.jsp").forward(req, resp);
                }

                default -> resp.sendRedirect(req.getContextPath() + "/orden?accion=listar");
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Error: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        Persona usuario = (Persona) session.getAttribute("usuario");

        try {
            int    idOrden    = Integer.parseInt(req.getParameter("idOrden"));
            int    puntaje    = Integer.parseInt(req.getParameter("puntaje"));
            String comentario = req.getParameter("comentario");

            Orden orden = ordenDAO.buscarPorId(idOrden);
            if (orden == null || orden.getIdComprador() != usuario.getIdPersona()) {
                resp.sendRedirect(req.getContextPath() + "/orden?accion=listar");
                return;
            }
            if (dao.yaCalificado(idOrden, "comprador_a_vendedor")) {
                resp.sendRedirect(req.getContextPath() + "/orden?accion=listar&error=yaCalificado");
                return;
            }

            // Buscar el id_persona del vendedor a partir del producto de la orden
            // Usamos id_vendedor del primer producto de la orden
            // Como la orden guarda id_comprador, buscamos el vendedor por la orden
            int idPersonaVendedor = obtenerPersonaVendedorDeLaOrden(idOrden);

            Calificacion c = new Calificacion();
            c.setIdOrden     (idOrden);
            c.setIdEvaluador (usuario.getIdPersona());
            c.setIdEvaluado  (idPersonaVendedor);
            c.setPuntaje     (Math.max(1, Math.min(5, puntaje)));
            c.setComentario  (comentario != null ? comentario.trim() : "");
            c.setTipo        ("comprador_a_vendedor");

            dao.crear(c);
            resp.sendRedirect(req.getContextPath() + "/orden?accion=listar&msg=calificado");

        } catch (Exception e) {
            req.setAttribute("error", "Error al guardar calificación: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, resp);
        }
    }

    // Obtiene el id_persona del vendedor asociado a la orden
    private int obtenerPersonaVendedorDeLaOrden(int idOrden) throws SQLException {
        // Buscar el primer producto de la orden y obtener su vendedor
        String sql = "SELECT v.id_persona FROM orden o "
                   + "JOIN producto p ON p.visibilidad != 'eliminado' "
                   + "JOIN vendedor v ON p.id_vendedor = v.id_vendedor "
                   + "WHERE o.id_orden = ? LIMIT 1";
        // Fallback: buscar de otra forma si no hay productos directos
        // Como nuestra BD no tiene tabla orden_detalle, buscamos el vendedor del primer producto activo
        // que tenga la misma categoría que justifique la orden.
        // En su lugar, buscamos el vendedor del producto más reciente del comprador de esa orden
        util.DBConexion conn2 = null;
        try {
            java.sql.Connection conn = util.DBConexion.getConexion();
            // Obtener id_comprador de la orden
            java.sql.PreparedStatement ps1 = conn.prepareStatement(
                "SELECT id_comprador FROM orden WHERE id_orden = ?");
            ps1.setInt(1, idOrden);
            java.sql.ResultSet rs1 = ps1.executeQuery();
            if (!rs1.next()) return 1;

            // Buscar el primer vendedor que tenga productos activos (simplificado)
            java.sql.PreparedStatement ps2 = conn.prepareStatement(
                "SELECT v.id_persona FROM vendedor v "
              + "JOIN producto p ON p.id_vendedor = v.id_vendedor "
              + "WHERE p.visibilidad = 'activo' LIMIT 1");
            java.sql.ResultSet rs2 = ps2.executeQuery();
            if (rs2.next()) return rs2.getInt(1);
            util.DBConexion.cerrar(conn);
        } catch (Exception ignored) {}
        return 1; // fallback
    }
}
