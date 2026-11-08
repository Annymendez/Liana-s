package util;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * Utilidades para imprimir texto de forma segura en las JSP.
 *
 * Por qué existe: si un vendedor escribe <script>...</script> como título de
 * un producto, o alguien manipula el parámetro "buscar" de la URL, la página
 * lo ejecutaría como código en el navegador de quien la abre (ataque XSS).
 * Escapar convierte esos caracteres en texto inofensivo.
 */
public final class Html {

    private Html() { }

    /** Escapa texto para ponerlo dentro de HTML o dentro de un atributo (value="..."). */
    public static String esc(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder(s.length() + 16);
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '&'  -> sb.append("&amp;");
                case '<'  -> sb.append("&lt;");
                case '>'  -> sb.append("&gt;");
                case '"'  -> sb.append("&quot;");
                case '\'' -> sb.append("&#39;");
                default   -> sb.append(c);
            }
        }
        return sb.toString();
    }

    /** Codifica un valor para ponerlo dentro de una URL (?buscar=...). */
    public static String url(String s) {
        return s == null ? "" : URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}
