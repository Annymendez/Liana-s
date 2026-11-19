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

            // Vendedor real de la orden (orden → producto → vendedor)
            int idPersonaVendedor = obtenerPersonaVendedorDeLaOrden(idOrden);
            if (idPersonaVendedor <= 0) {
                req.setAttribute("error", "No se encontró el vendedor de la orden #" + idOrden
                        + ". Revisa que la orden tenga productos asociados.");
                req.getRequestDispatcher("/error.jsp").forward(req, resp);
                return;
            }

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

    // ─────────────────────────────────────────────────────────────
    // Obtiene el id_persona del vendedor REAL de la orden.
    // Antes devolvía el primer vendedor con cualquier producto activo,
    // por eso las calificaciones le llegaban al vendedor equivocado.
    // Ahora busca el vínculo orden → producto → vendedor según
    // cómo esté armada la BD:
    //   1) orden.id_vendedor
    //   2) orden.id_producto
    //   3) una tabla de detalle con columnas id_orden + id_producto
    // Si no encuentra nada, devuelve -1.
    // ─────────────────────────────────────────────────────────────
    private int obtenerPersonaVendedorDeLaOrden(int idOrden) throws SQLException {
        java.sql.Connection conn = null;
        try {
            conn = util.DBConexion.getConexion();

            // 1) La orden guarda directamente el vendedor
            if (columnaExiste(conn, "orden", "id_vendedor")) {
                int id = consultarId(conn,
                    "SELECT v.id_persona FROM orden o "
                  + "JOIN vendedor v ON v.id_vendedor = o.id_vendedor "
                  + "WHERE o.id_orden = ?", idOrden);
                if (id > 0) return id;
            }

            // 2) La orden guarda el producto
            if (columnaExiste(conn, "orden", "id_producto")) {
                int id = consultarId(conn,
                    "SELECT v.id_persona FROM orden o "
                  + "JOIN producto p ON p.id_producto = o.id_producto "
                  + "JOIN vendedor v ON v.id_vendedor = p.id_vendedor "
                  + "WHERE o.id_orden = ?", idOrden);
                if (id > 0) return id;
            }

            // 3) Tabla de detalle (orden_detalle, detalle_orden, orden_producto…)
            String tablaDetalle = buscarTablaDetalle(conn);
            if (tablaDetalle != null) {
                int id = consultarId(conn,
                    "SELECT v.id_persona FROM `" + tablaDetalle + "` d "
                  + "JOIN producto p ON p.id_producto = d.id_producto "
                  + "JOIN vendedor v ON v.id_vendedor = p.id_vendedor "
                  + "WHERE d.id_orden = ? LIMIT 1", idOrden);
                if (id > 0) return id;
            }

            return -1;
        } finally {
            if (conn != null) {
                try { util.DBConexion.cerrar(conn); } catch (Exception ignored) {}
            }
        }
    }

    private boolean columnaExiste(java.sql.Connection conn, String tabla, String columna) throws SQLException {
        String sql = "SELECT COUNT(*) FROM information_schema.COLUMNS "
                   + "WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?";
        try (java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tabla);
            ps.setString(2, columna);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    // Busca una tabla (distinta de orden) que tenga id_orden e id_producto
    private String buscarTablaDetalle(java.sql.Connection conn) throws SQLException {
        String sql = "SELECT TABLE_NAME FROM information_schema.COLUMNS "
                   + "WHERE TABLE_SCHEMA = DATABASE() "
                   + "AND COLUMN_NAME IN ('id_orden','id_producto') "
                   + "AND TABLE_NAME <> 'orden' "
                   + "GROUP BY TABLE_NAME "
                   + "HAVING COUNT(DISTINCT COLUMN_NAME) = 2 "
                   + "LIMIT 1";
        try (java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             java.sql.ResultSet rs = ps.executeQuery()) {
            return rs.next() ? rs.getString(1) : null;
        }
    }

    private int consultarId(java.sql.Connection conn, String sql, int idOrden) throws SQLException {
        try (java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idOrden);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt(1) : -1;
            }
        }
    }
}