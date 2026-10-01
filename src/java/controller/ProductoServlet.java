package controller;

/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */


import dao.ProductoDAO;
import dao.VendedorDAO;
import model.Producto;
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

@WebServlet("/producto")
public class ProductoServlet extends HttpServlet {

    private final ProductoDAO dao         = new ProductoDAO();
    private final VendedorDAO vendedorDAO = new VendedorDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String accion = req.getParameter("accion");
        if (accion == null) accion = "listar";
        HttpSession session = req.getSession(false);
        Persona usuario = (Persona) session.getAttribute("usuario");

        try {
            switch (accion) {

                case "listar" -> {
                    String texto     = req.getParameter("buscar");
                    String categoria = req.getParameter("categoria");
                    String estado    = req.getParameter("estado");
                    String orden     = req.getParameter("orden");
                    Double min = null, max = null;
                    try {
                        if (req.getParameter("min") != null && !req.getParameter("min").isEmpty())
                            min = Double.parseDouble(req.getParameter("min"));
                        if (req.getParameter("max") != null && !req.getParameter("max").isEmpty())
                            max = Double.parseDouble(req.getParameter("max"));
                    } catch (Exception ignored) {}

                    boolean hayFiltro = (texto != null && !texto.isEmpty())
                        || (categoria != null && !categoria.isEmpty())
                        || (estado != null && !estado.isEmpty())
                        || (orden  != null && !orden.isEmpty())
                        || min != null || max != null;

                    List<Producto> productos = switch (usuario.getTipo()) {
                        case "comprador" -> hayFiltro
                            ? dao.buscarFiltrado(texto, categoria, estado, orden, min, max)
                            : dao.listarActivos();
                        case "vendedor"  -> {
                            Vendedor v = vendedorDAO.buscarPorIdPersona(usuario.getIdPersona());
                            yield v == null ? List.of()
                                : hayFiltro
                                    ? dao.buscarFiltradoPorVendedor(v.getIdVendedor(), texto, categoria, estado, orden, min, max)
                                    : dao.listarPorVendedor(v.getIdVendedor());
                        }
                        default -> { hayFiltro = false; yield dao.listarTodos(); }
                    };

                    req.setAttribute("productos",  productos);
                    req.setAttribute("hayFiltro",  hayFiltro);
                    req.setAttribute("buscar",     texto     != null ? texto     : "");
                    req.setAttribute("categoria",  categoria != null ? categoria : "");
                    req.setAttribute("estado",     estado    != null ? estado    : "");
                    req.setAttribute("orden",      orden     != null ? orden     : "");
                    req.setAttribute("min",        min != null ? min.toString()  : "");
                    req.setAttribute("max",        max != null ? max.toString()  : "");
                    dispatch(req, resp, "/lista.jsp");
                }

                case "detalle" -> {
                    int id = Integer.parseInt(req.getParameter("id"));
                    Producto p = dao.buscarPorId(id);
                    if (p == null) { resp.sendRedirect(req.getContextPath() + "/producto?accion=listar"); return; }
                    req.setAttribute("producto", p);
                    dispatch(req, resp, "/detalle.jsp");
                }

                case "nuevo" -> {
                    if ("vendedor".equals(usuario.getTipo())) {
                        Vendedor v = vendedorDAO.buscarPorIdPersona(usuario.getIdPersona());
                        if (v == null || !v.isIdentidadValidada()) {
                            req.setAttribute("productos", obtenerSegunRol(usuario));
                            req.setAttribute("errorIdentidad", true);
                            req.setAttribute("hayFiltro", false);
                            dispatch(req, resp, "/lista.jsp"); return;
                        }
                    }
                    dispatch(req, resp, "/formulario.jsp");
                }

                case "editar" -> {
                    int id = Integer.parseInt(req.getParameter("id"));
                    Producto p = dao.buscarPorId(id);
                    if (p == null) { resp.sendRedirect(req.getContextPath() + "/producto?accion=listar"); return; }
                    if (!puedeEditar(usuario, p)) {
                        req.setAttribute("productos", obtenerSegunRol(usuario));
                        req.setAttribute("errorPropietario", true);
                        req.setAttribute("hayFiltro", false);
                        dispatch(req, resp, "/lista.jsp"); return;
                    }
                    req.setAttribute("producto", p);
                    dispatch(req, resp, "/formulario.jsp");
                }

                case "eliminar" -> {
                    int id = Integer.parseInt(req.getParameter("id"));
                    Producto p = dao.buscarPorId(id);
                    if (p != null && puedeEditar(usuario, p)) {
                        dao.eliminar(id);
                        resp.sendRedirect(req.getContextPath() + "/producto?accion=listar&msg=eliminado");
                    } else {
                        req.setAttribute("productos", obtenerSegunRol(usuario));
                        req.setAttribute("errorPropietario", true);
                        req.setAttribute("hayFiltro", false);
                        dispatch(req, resp, "/lista.jsp");
                    }
                }

                default -> dispatch(req, resp, "/lista.jsp");
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Error: " + e.getMessage());
            dispatch(req, resp, "/error.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        Persona usuario = (Persona) session.getAttribute("usuario");
        String accion = req.getParameter("accion");
        if (accion == null) accion = "";
        try {
            switch (accion) {
                case "guardar" -> {
                    if ("vendedor".equals(usuario.getTipo())) {
                        Vendedor v = vendedorDAO.buscarPorIdPersona(usuario.getIdPersona());
                        if (v == null || !v.isIdentidadValidada()) {
                            req.setAttribute("productos", obtenerSegunRol(usuario));
                            req.setAttribute("errorIdentidad", true);
                            req.setAttribute("hayFiltro", false);
                            dispatch(req, resp, "/lista.jsp"); return;
                        }
                        dao.crear(construir(req, v.getIdVendedor()));
                    } else {
                        dao.crear(construir(req, 1));
                    }
                    resp.sendRedirect(req.getContextPath() + "/producto?accion=listar&msg=creado");
                }
                case "actualizar" -> {
                    int id = Integer.parseInt(req.getParameter("idProducto"));
                    Producto p = dao.buscarPorId(id);
                    if (p == null || !puedeEditar(usuario, p)) {
                        req.setAttribute("productos", obtenerSegunRol(usuario));
                        req.setAttribute("errorPropietario", true);
                        req.setAttribute("hayFiltro", false);
                        dispatch(req, resp, "/lista.jsp"); return;
                    }
                    Producto act = construir(req, p.getIdVendedor());
                    act.setIdProducto(id);
                    dao.actualizar(act);
                    resp.sendRedirect(req.getContextPath() + "/producto?accion=listar&msg=actualizado");
                }
                default -> resp.sendRedirect(req.getContextPath() + "/producto?accion=listar");
            }
        } catch (SQLException e) {
            req.setAttribute("error", "Error: " + e.getMessage());
            dispatch(req, resp, "/error.jsp");
        }
    }

    private List<Producto> obtenerSegunRol(Persona u) throws SQLException {
        if ("admin".equals(u.getTipo())) return dao.listarTodos();
        if ("vendedor".equals(u.getTipo())) {
            Vendedor v = vendedorDAO.buscarPorIdPersona(u.getIdPersona());
            return v != null ? dao.listarPorVendedor(v.getIdVendedor()) : List.of();
        }
        return dao.listarActivos();
    }

    private boolean puedeEditar(Persona u, Producto p) throws SQLException {
        if ("admin".equals(u.getTipo())) return true;
        if ("vendedor".equals(u.getTipo())) {
            Vendedor v = vendedorDAO.buscarPorIdPersona(u.getIdPersona());
            return v != null && v.getIdVendedor() == p.getIdVendedor();
        }
        return false;
    }

    private Producto construir(HttpServletRequest req, int idVendedor) {
        Producto p = new Producto();
        p.setIdVendedor(idVendedor);
        p.setTitulo(req.getParameter("titulo"));
        p.setDescripcion(req.getParameter("descripcion"));
        p.setPrecio(Double.parseDouble(req.getParameter("precio")));
        p.setStock(Integer.parseInt(req.getParameter("stock")));
        p.setCategoria(req.getParameter("categoria"));
        p.setImagenUrl(req.getParameter("imagenUrl"));
        p.setEstadoProducto(req.getParameter("estadoProducto"));
        p.setVisibilidad(req.getParameter("visibilidad"));
        p.setPoliticaDevolucion(req.getParameter("politicaDevolucion"));
        return p;
    }

    private void dispatch(HttpServletRequest req, HttpServletResponse resp, String jsp)
            throws ServletException, IOException {
        req.getRequestDispatcher(jsp).forward(req, resp);
    }
}
