import 'package:flutter/material.dart';

class User {
  User({@required this.id, this.name, this.avatar, this.aboutMe});
  String id;
  String name;
  String avatar;
  String aboutMe;
}