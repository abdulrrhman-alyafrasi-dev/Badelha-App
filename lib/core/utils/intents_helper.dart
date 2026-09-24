import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class IntentsHelper {
  /// Opens device dialer with the phone number
  static Future<bool> makePhoneCall(String phoneNumber, BuildContext? context) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanPhone,
    );

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        return true;
      } else {
        // Try direct launch
        await launchUrl(launchUri);
        return true;
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر فتح تطبيق الهاتف. الرقم: $cleanPhone'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      return false;
    }
  }

  /// Opens SMS messaging app with pre-filled text
  static Future<bool> sendSms({
    required String phoneNumber,
    required String itemTitle,
    BuildContext? context,
  }) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final bodyMessage =
        'مرحباً، أنا مهتم بعرض المقايضة الخاص بمنتجك ($itemTitle) عبر تطبيق "بدلها". هل لا زال العرض متاحاً؟';

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: cleanPhone,
      queryParameters: <String, String>{
        'body': bodyMessage,
      },
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
        return true;
      } else {
        await launchUrl(smsUri);
        return true;
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر فتح تطبيق الرسائل للرقم: $cleanPhone'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      return false;
    }
  }

  /// Opens Email client with pre-filled barter proposal text
  static Future<bool> sendEmail({
    required String email,
    required String itemTitle,
    String? ownerName,
    BuildContext? context,
  }) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('صاحب المنتج لم يسجل بريداً إلكترونياً. يمكنك التواصل معه عبر الاتصال أو SMS.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return false;
    }

    final subject = 'طلب مقايضة عبر تطبيق بَدِّلْهَا: بخصوص ($itemTitle)';
    final body =
        'السلام عليكم ورحمة الله،\n\nأخي ${ownerName ?? 'الكريم'}، أنا مهتم بعرض المقايضة الخاص بمنتجك ($itemTitle) المعروض عبر تطبيق "بَدِّلْهَا".\n\nهل العرض لا يزال متاحاً؟ وما هي تفاصيل المقايضة المقترحة من طرفك؟\n\nتحياتي.';

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: cleanEmail,
      queryParameters: <String, String>{
        'subject': subject,
        'body': body,
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        return true;
      } else {
        await launchUrl(emailUri);
        return true;
      }
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر فتح تطبيق البريد الإلكتروني للعنوان: $cleanEmail'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      return false;
    }
  }

  /// Opens external URL (e.g. Telegram channel, website)
  static Future<bool> openUrl(String urlString, [BuildContext? context]) async {
    final cleanUrl = urlString.trim();
    if (cleanUrl.isEmpty) return false;
    final Uri uri = Uri.parse(cleanUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      return true;
    } catch (e) {
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر فتح الرابط: $cleanUrl'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      return false;
    }
  }
}
