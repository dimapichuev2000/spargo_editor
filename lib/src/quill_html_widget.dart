import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';

import 'quill_html_display.dart';

/// Виджет для отображения Quill HTML (списки, ссылки, выравнивание).
///
/// Использует [HtmlWidget] с препроцессингом и стилями из [QuillHtmlDisplay].
/// По клику на ссылку открывает URL во внешнем приложении.
class QuillHtmlWidget extends StatelessWidget {
  const QuillHtmlWidget({
    super.key,
    required this.content,
    this.textStyle,
    this.padding,
    this.onTapUrl,
  });

  final String content;
  final TextStyle? textStyle;
  final EdgeInsets? padding;

  /// Если не задан, ссылки открываются через [launchUrl] (url_launcher).
  final Future<bool> Function(String url)? onTapUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: HtmlWidget(
        QuillHtmlDisplay.preprocessQuillHtml(content),
        textStyle: textStyle,
        customStylesBuilder: (element) =>
            QuillHtmlDisplay.buildStyles(context, element),
        onTapUrl: onTapUrl ?? _defaultOnTapUrl,
      ),
    );
  }

  static Future<bool> _defaultOnTapUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
