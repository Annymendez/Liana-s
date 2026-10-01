/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author annym
 */
import model.Persona;
import util.DBConexion;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PersonaDAO {

    public Persona autenticar(String correo, String contrasena) throws SQLException {
        return buscarUno("SELECT * FROM persona WHERE correo=? AND contrasena=?", correo, contrasena);
    }

    public int crear(Persona p) throws SQLException {
        String sql = "INSERT INTO persona (nombre,documento,correo,celular,direccion,contrasena,estado,tipo) VALUES (?,?,?,?,?,?,'inactivo',?)";
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1,p.getNombre()); ps.setString(2,p.getDocumento()); ps.setString(3,p.getCorreo());
            ps.setString(4,p.getCelular()); ps.setString(5,p.getDireccion());
            ps.setString(6,p.getContrasena()); ps.setString(7,p.getTipo());
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            return rs.next() ? rs.getInt(1) : -1;
        } finally { DBConexion.cerrar(conn); }
    }

    public boolean existeDocumentoOCorreo(String doc, String correo) throws SQLException {
        return count("SELECT COUNT(*) FROM persona WHERE documento=? OR correo=?", doc, correo) > 0;
    }

    public boolean activarCuenta(int id) throws SQLException { return cambiarEstado(id, "activo"); }

    public boolean cambiarEstado(int id, String estado) throws SQLException {
        return update("UPDATE persona SET estado=? WHERE id_persona=?", estado, id);
    }

    public boolean cambiarTipo(int id, String tipo) throws SQLException {
        return update("UPDATE persona SET tipo=? WHERE id_persona=?", tipo, id);
    }

    public boolean eliminar(int id) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement("DELETE FROM persona WHERE id_persona=?");
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    public Persona buscarPorId(int id) throws SQLException {
        return buscarUno("SELECT * FROM persona WHERE id_persona=?", String.valueOf(id), null);
    }

    public List<Persona> listarTodos() throws SQLException {
        return lista("SELECT * FROM persona ORDER BY tipo, nombre");
    }

    public List<Persona> listarPorTipo(String tipo) throws SQLException {
        Connection conn = null;
        List<Persona> result = new ArrayList<>();
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM persona WHERE tipo=? ORDER BY nombre");
            ps.setString(1, tipo);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) result.add(mapear(rs));
        } finally { DBConexion.cerrar(conn); }
        return result;
    }

    
    private Persona buscarUno(String sql, String p1, String p2) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, p1);
            if (p2 != null) ps.setString(2, p2);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? mapear(rs) : null;
        } finally { DBConexion.cerrar(conn); }
    }

    private List<Persona> lista(String sql) throws SQLException {
        List<Persona> r = new ArrayList<>();
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            ResultSet rs = conn.createStatement().executeQuery(sql);
            while (rs.next()) r.add(mapear(rs));
        } finally { DBConexion.cerrar(conn); }
        return r;
    }

    private int count(String sql, String p1, String p2) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, p1); ps.setString(2, p2);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } finally { DBConexion.cerrar(conn); }
    }

    private boolean update(String sql, String p1, int p2) throws SQLException {
        Connection conn = null;
        try {
            conn = DBConexion.getConexion();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, p1); ps.setInt(2, p2);
            return ps.executeUpdate() > 0;
        } finally { DBConexion.cerrar(conn); }
    }

    private Persona mapear(ResultSet rs) throws SQLException {
        Persona p = new Persona();
        p.setIdPersona (rs.getInt   ("id_persona"));
        p.setNombre    (rs.getString("nombre"));
        p.setDocumento (rs.getString("documento"));
        p.setCorreo    (rs.getString("correo"));
        p.setCelular   (rs.getString("celular"));
        p.setDireccion (rs.getString("direccion"));
        p.setContrasena(rs.getString("contrasena"));
        p.setEstado    (rs.getString("estado"));
        p.setTipo      (rs.getString("tipo"));
        return p;
    }
}
