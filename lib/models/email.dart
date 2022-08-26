import 'dart:convert';

import 'package:http/http.dart' as http;

class Email {
  static String appName = "Contacts";
  static String adminName = "Cruz labs";
  static String serviceId = "service_w4tifkr";
  static String templateId = "template_nkd2igy";
  static String userId = "ktCusyJ2sLF6h7NIt";

  static Future sendEmail(
    String name,
    String email,
    String subject,
    String message,
  ) async {
    final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
    await http.post(
      url,
      headers: {
        "origin": "http://localhost",
        "Content-Type": "application/json",
      },
      body: json.encode({
        "service_id": serviceId,
        "template_id": templateId,
        "user_id": userId,
        "template_params": {
          "user_email": email,
          "reply_to": email,
          "user_subject": subject,
          "user_name": name,
          "user_message": message,
          "admin_name": "$appName by $adminName",
        }
      }),
    );
  }

  static String recoverPasswordSuject = "Recover your $appName password!";

  static String recoverPasswordMessage(String password) =>
      "Here's your password: $password";
}
