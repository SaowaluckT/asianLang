import 'package:flutter/material.dart';

class AppConstants {
  static Map<String, String> languages = {
    "en": "English",
    'zh':'Chinese',
    'th':'Thai',
    'ja':'Japanese',
  };

  static Map<String, String> languagesCode = {
    "en": "en-US",
    'zh':'zh-CN',
    'th':'th-TH',
    'ja':'ja-JP',
  };

  static List<PopupMenuItem> listLanguagesPopupMenuItem = [
    const PopupMenuItem(
      value: 'zh',
      child: Text('Chinese'),
    ),
    const PopupMenuItem(
      value: 'en',
      child: Text('English'),
    ),
    const PopupMenuItem(
      value: 'th',
      child: Text('Thai'),
    ),
    const PopupMenuItem(
      value: 'ja',
      child: Text('Japanese'),
    ),
  ];
}