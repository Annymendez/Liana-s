/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author annym
 */
import java.sql.Timestamp;

public class Calificacion {
    private int       idCalificacion;
    private int       idOrden;
    private int       idEvaluador;
    private int       idEvaluado;
    private int       puntaje;
    private String    comentario;
    private String    tipo;
    private Timestamp fecha;
    private String    nombreEvaluador;
    private String    nombreEvaluado;

    public Calificacion() {}

    public int       getIdCalificacion()              { return idCalificacion; }
    public void      setIdCalificacion(int v)         { this.idCalificacion = v; }
    public int       getIdOrden()                     { return idOrden; }
    public void      setIdOrden(int v)                { this.idOrden = v; }
    public int       getIdEvaluador()                 { return idEvaluador; }
    public void      setIdEvaluador(int v)            { this.idEvaluador = v; }
    public int       getIdEvaluado()                  { return idEvaluado; }
    public void      setIdEvaluado(int v)             { this.idEvaluado = v; }
    public int       getPuntaje()                     { return puntaje; }
    public void      setPuntaje(int v)                { this.puntaje = v; }
    public String    getComentario()                  { return comentario; }
    public void      setComentario(String v)          { this.comentario = v; }
    public String    getTipo()                        { return tipo; }
    public void      setTipo(String v)                { this.tipo = v; }
    public Timestamp getFecha()                       { return fecha; }
    public void      setFecha(Timestamp v)            { this.fecha = v; }
    public String    getNombreEvaluador()             { return nombreEvaluador; }
    public void      setNombreEvaluador(String v)     { this.nombreEvaluador = v; }
    public String    getNombreEvaluado()              { return nombreEvaluado; }
    public void      setNombreEvaluado(String v)      { this.nombreEvaluado = v; }

    // Genera string de estrellas para mostrar en JSP
    public String getEstrellas() {
        StringBuilder sb = new StringBuilder();
        for (int i = 1; i <= 5; i++) sb.append(i <= puntaje ? "⭐" : "☆");
        return sb.toString();
    }
}
