/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author annym
 */
import model.Producto;
import util.DBConexion;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductoDAO {

    public boolean crear(Producto p) throws SQLException {
        String sql = "INSERT INTO producto (id_vendedor,titulo,descripcion,precio,stock,categoria,imagen_url,estado_producto,visibilidad,politica_devolucion) VALUES (?,?,?,?,?,?,?,?,?,?)";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1,p.getIdVendedor()); ps.setString(2,p.getTitulo()); ps.setString(3,p.getDescripcion());
            ps.setDouble(4,p.getPrecio()); ps.setInt(5,p.getStock()); ps.setString(6,p.getCategoria());
            ps.setString(7,p.getImagenUrl()); ps.setString(8,p.getEstadoProducto());
            ps.setString(9,p.getVisibilidad()); ps.setString(10,p.getPoliticaDevolucion());
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    public List<Producto> listarTodos() throws SQLException {
        return query("SELECT p.*,pe.nombre AS nombre_vendedor FROM producto p JOIN vendedor v ON p.id_vendedor=v.id_vendedor JOIN persona pe ON v.id_persona=pe.id_persona WHERE p.visibilidad!='eliminado' ORDER BY p.id_producto DESC", null);
    }

    public List<Producto> listarActivos() throws SQLException {
        return query("SELECT p.*,pe.nombre AS nombre_vendedor FROM producto p JOIN vendedor v ON p.id_vendedor=v.id_vendedor JOIN persona pe ON v.id_persona=pe.id_persona WHERE p.visibilidad='activo' AND p.stock>0 ORDER BY p.titulo", null);
    }

    public List<Producto> listarPorVendedor(int idVendedor) throws SQLException {
        return queryParam("SELECT p.*,pe.nombre AS nombre_vendedor FROM producto p JOIN vendedor v ON p.id_vendedor=v.id_vendedor JOIN persona pe ON v.id_persona=pe.id_persona WHERE p.visibilidad!='eliminado' AND p.id_vendedor=? ORDER BY p.id_producto DESC", idVendedor);
    }

    
    public List<Producto> buscarFiltrado(String texto, String categoria, String estado, String orden, Double min, Double max) {
        return buscarConFiltros(-1, texto, categoria, estado, orden, min, max);
    }

    
    public List<Producto> buscarFiltradoPorVendedor(int idVendedor, String texto, String categoria, String estado, String orden, Double min, Double max) {
        return buscarConFiltros(idVendedor, texto, categoria, estado, orden, min, max);
    }

    private List<Producto> buscarConFiltros(int idVendedor, String texto, String categoria, String estado, String orden, Double min, Double max) {
        List<Producto> lista = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT p.*,pe.nombre AS nombre_vendedor FROM producto p JOIN vendedor v ON p.id_vendedor=v.id_vendedor JOIN persona pe ON v.id_persona=pe.id_persona WHERE p.visibilidad!='eliminado'");

        if (idVendedor > 0)                              sql.append(" AND p.id_vendedor=?");
        else                                             sql.append(" AND p.visibilidad='activo' AND p.stock>0");
        if (texto != null && !texto.isEmpty())           sql.append(" AND (p.titulo LIKE ? OR p.descripcion LIKE ?)");
        if (categoria != null && !categoria.isEmpty())   sql.append(" AND p.categoria=?");
        if (estado != null && !estado.isEmpty())         sql.append(" AND p.estado_producto=?");
        if (min != null)                                 sql.append(" AND p.precio>=?");
        if (max != null)                                 sql.append(" AND p.precio<=?");

        sql.append(switch (orden != null ? orden : "") {
            case "precio_asc"  -> " ORDER BY p.precio ASC";
            case "precio_desc" -> " ORDER BY p.precio DESC";
            case "nombre_asc"  -> " ORDER BY p.titulo ASC";
            case "nombre_desc" -> " ORDER BY p.titulo DESC";
            case "reciente"    -> " ORDER BY p.fecha_creacion DESC";
            default            -> " ORDER BY p.titulo ASC";
        });

        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql.toString());
            int i = 1;
            if (idVendedor > 0)                            ps.setInt(i++, idVendedor);
            if (texto != null && !texto.isEmpty())       { ps.setString(i++, "%"+texto+"%"); ps.setString(i++, "%"+texto+"%"); }
            if (categoria != null && !categoria.isEmpty()) ps.setString(i++, categoria);
            if (estado != null && !estado.isEmpty())       ps.setString(i++, estado);
            if (min != null)                               ps.setDouble(i++, min);
            if (max != null)                               ps.setDouble(i++, max);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) lista.add(mapear(rs));
        } catch (SQLException e) { e.printStackTrace(); }
        finally { DBConexion.cerrar(conn); }
        return lista;
    }

    public Producto buscarPorId(int id) throws SQLException {
        List<Producto> r = queryParam("SELECT p.*,pe.nombre AS nombre_vendedor FROM producto p JOIN vendedor v ON p.id_vendedor=v.id_vendedor JOIN persona pe ON v.id_persona=pe.id_persona WHERE p.id_producto=?", id);
        return r.isEmpty() ? null : r.get(0);
    }

    public boolean actualizar(Producto p) throws SQLException {
        String sql = "UPDATE producto SET titulo=?,descripcion=?,precio=?,stock=?,categoria=?,imagen_url=?,estado_producto=?,visibilidad=?,politica_devolucion=? WHERE id_producto=?";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1,p.getTitulo()); ps.setString(2,p.getDescripcion()); ps.setDouble(3,p.getPrecio());
            ps.setInt(4,p.getStock()); ps.setString(5,p.getCategoria()); ps.setString(6,p.getImagenUrl());
            ps.setString(7,p.getEstadoProducto()); ps.setString(8,p.getVisibilidad());
            ps.setString(9,p.getPoliticaDevolucion()); ps.setInt(10,p.getIdProducto());
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    public boolean descontarStock(int id, int cant) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement("UPDATE producto SET stock=stock-? WHERE id_producto=? AND stock>=?");
            ps.setInt(1,cant); ps.setInt(2,id); ps.setInt(3,cant);
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    public boolean eliminar(int id) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement("UPDATE producto SET visibilidad='eliminado' WHERE id_producto=?");
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    private List<Producto> query(String sql, Object p) throws SQLException {
        List<Producto> lista = new ArrayList<>();
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            ResultSet rs = conn.createStatement().executeQuery(sql);
            while (rs.next()) lista.add(mapear(rs));
        } finally { DBConexion.cerrar(conn); }
        return lista;
    }

    private List<Producto> queryParam(String sql, int param) throws SQLException {
        List<Producto> lista = new ArrayList<>();
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, param);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) lista.add(mapear(rs));
        } finally { DBConexion.cerrar(conn); }
        return lista;
    }

    private Producto mapear(ResultSet rs) throws SQLException {
        Producto p = new Producto();
        p.setIdProducto(rs.getInt("id_producto")); p.setIdVendedor(rs.getInt("id_vendedor"));
        p.setTitulo(rs.getString("titulo")); p.setDescripcion(rs.getString("descripcion"));
        p.setPrecio(rs.getDouble("precio")); p.setStock(rs.getInt("stock"));
        p.setCategoria(rs.getString("categoria")); p.setImagenUrl(rs.getString("imagen_url"));
        p.setEstadoProducto(rs.getString("estado_producto")); p.setVisibilidad(rs.getString("visibilidad"));
        p.setFechaCreacion(rs.getTimestamp("fecha_creacion"));
        try { p.setNombreVendedor(rs.getString("nombre_vendedor")); } catch (Exception ignored) {}
        try { p.setPoliticaDevolucion(rs.getString("politica_devolucion")); } catch (Exception ignored) {}
        return p;
    }
}
