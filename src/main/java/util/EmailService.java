package util;

import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.*;

public class EmailService {

    private static final String REMITENTE  = "annymendez2005@gmail.com";
    private static final String CONTRASENA = "ojfnojqtuaxebdqa";

    public static void enviarCodigo(String destinatario, String nombreUsuario,
                                     String codigo, String motivo) throws Exception {

        Properties props = new Properties();
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host",            "smtp.gmail.com");
        props.put("mail.smtp.port",            "587");
        props.put("mail.smtp.ssl.trust",       "smtp.gmail.com");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(REMITENTE, CONTRASENA);
            }
        });

        Message mensaje = new MimeMessage(session);
        mensaje.setFrom(new InternetAddress(REMITENTE, "Liana's"));
        mensaje.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
        mensaje.setSubject("Liana's — Código de verificación");

        String cuerpo = "<div style='font-family:Arial,sans-serif;max-width:480px;margin:0 auto;'>"
            + "<h2 style='color:#2c2217;'>Liana's</h2>"
            + "<p>Hola <strong>" + nombreUsuario + "</strong>,</p>"
            + "<p>Tu código de verificación para <strong>" + motivo + "</strong> es:</p>"
            + "<div style='background:#f5f0e8;border-radius:10px;padding:20px;text-align:center;margin:20px 0;'>"
            + "<span style='font-size:2.5rem;font-weight:bold;color:#8b6247;letter-spacing:8px;'>"
            + codigo + "</span></div>"
            + "<p style='color:#888;font-size:.85rem;'>Este código expira en 10 minutos. "
            + "Si no solicitaste esto, ignora este mensaje.</p>"
            + "<hr style='border:none;border-top:1px solid #ece8e1;margin:20px 0;'>"
            + "<p style='color:#aaa;font-size:.75rem;'>Liana's · Bogotá, Colombia</p>"
            + "</div>";

        mensaje.setContent(cuerpo, "text/html;charset=UTF-8");
        Transport.send(mensaje);
    }
}