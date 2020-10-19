import 'package:flutter/material.dart';


class QueryCard {
  final String _title;
  final Future widgetFuture;

  QueryCard(this._title, this.widgetFuture);

  String get title {
    return _title;
  }
}
