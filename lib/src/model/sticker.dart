import 'package:flutter/material.dart';

class Sticker {
  Sticker({@required this.id, this.collection, this.files, this.fileType});
  String id;
  String collection;
  List<String> files;
  String fileType;
}