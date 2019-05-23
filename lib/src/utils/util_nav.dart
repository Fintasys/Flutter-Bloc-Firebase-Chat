
import 'package:flutter/material.dart';

void navigateTo(BuildContext context, String routeName, dynamic arguments) {
  Navigator.pushNamed(context, routeName, arguments: arguments);
}

void navigateToAndRemoveUntil(BuildContext context, String routeName, dynamic arguments) {
  Navigator.pushNamedAndRemoveUntil(context, routeName, (Route route) => false, arguments: arguments);
}
