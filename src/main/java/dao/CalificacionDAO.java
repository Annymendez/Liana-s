/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author annym
 */
import model.Calificacion;
import util.DBConexion;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CalificacionDAO {

    // Crear calificación y actualizar reputación del evaluado
    public boolean crear(Calificacion c) throws SQLException {
        String sql = "INSERT INTO calificacion (id_orden, id_evaluador, id_evaluado, puntaje, comentario, tipo) "
                   + "VALUES (?,?,?,?,?,?)";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt   (1, c.getIdOrden());
            ps.setInt   (2, c.getIdEvaluador());
            ps.setInt   (3, c.getIdEvaluado());
            ps.setInt   (4, c.getPuntaje());
            ps.setString(5, c.getComentario());
            ps.setString(6, c.getTipo());
            boolean ok = ps.executeUpdate() > 0;

            // RF-AN-18: actualizar reputación del vendedor si lo califica el comprador
            if (ok && "comprador_a_vendedor".equals(c.getTipo())) {
                actualizarReputacionVendedor(conn, c.getIdEvaluado());
            }
            return ok;
        } finally { DBConexion.cerrar(conn); }
    }

    // Verificar si ya existe calificación para esa orden y tipo
    public boolean yaCalificado(int idOrden, String tipo) throws SQLException {
        String sql = "SELECT COUNT(*) FROM calificacion WHERE id_orden=? AND tipo=?";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt   (1, idOrden);
            ps.setString(2, tipo);
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    // Calificaciones recibidas por un vendedor (para mis_calificaciones.jsp)
    public List<Calificacion> listarPorVendedor(int idPersonaVendedor) throws SQLException {
        List<Calificacion> lista = new ArrayList<>();
        String sql = "SELECT c.*, pe.nombre AS nombre_evaluador, pv.nombre AS nombre_evaluado "
                   + "FROM calificacion c "
                   + "JOIN persona pe ON c.id_evaluador = pe.id_persona "
                   + "JOIN persona pv ON c.id_evaluado  = pv.id_persona "
                   + "WHERE c.id_evaluado = ? AND c.tipo = 'comprador_a_vendedor' "
                   + "ORDER BY c.fecha DESC";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, idPersonaVendedor);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) lista.add(mapear(rs));
        } finally { DBConexion.cerrar(conn); }
        return lista;
    }

    // Promedio de reputación de un vendedor
    public double calcularPromedio(int idPersonaVendedor) throws SQLException {
        String sql = "SELECT AVG(puntaje) FROM calificacion "
                   + "WHERE id_evaluado=? AND tipo='comprador_a_vendedor'";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, idPersonaVendedor);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getDouble(1);
        } finally { DBConexion.cerrar(conn); }
        return 0.0;
    }

    // RF-AN-18: actualizar campo reputacion en tabla vendedor
    private void actualizarReputacionVendedor(Connection conn, int idPersonaVendedor) throws SQLException {
        String sqlProm = "SELECT AVG(puntaje) FROM calificacion "
                       + "WHERE id_evaluado=? AND tipo='comprador_a_vendedor'";
        PreparedStatement ps1 = conn.prepareStatement(sqlProm);
        ps1.setInt(1, idPersonaVendedor);
        ResultSet rs = ps1.executeQuery();
        if (rs.next()) {
            double prom = rs.getDouble(1);
            String sqlUpd = "UPDATE vendedor SET reputacion=? WHERE id_persona=?";
            PreparedStatement ps2 = conn.prepareStatement(sqlUpd);
            ps2.setDouble(1, Math.round(prom * 100.0) / 100.0);
            ps2.setInt   (2, idPersonaVendedor);
            ps2.executeUpdate();
        }
    }

    private Calificacion mapear(ResultSet rs) throws SQLException {
        Calificacion c = new Calificacion();
        c.setIdCalificacion(rs.getInt      ("id_calificacion"));
        c.setIdOrden       (rs.getInt      ("id_orden"));
        c.setIdEvaluador   (rs.getInt      ("id_evaluador"));
        c.setIdEvaluado    (rs.getInt      ("id_evaluado"));
        c.setPuntaje       (rs.getInt      ("puntaje"));
        c.setComentario    (rs.getString   ("comentario"));
        c.setTipo          (rs.getString   ("tipo"));
        c.setFecha         (rs.getTimestamp("fecha"));
        try { c.setNombreEvaluador(rs.getString("nombre_evaluador")); } catch (Exception ignored) {}
        try { c.setNombreEvaluado (rs.getString("nombre_evaluado"));  } catch (Exception ignored) {}
        return c;
    }
}
