import 'package:flutter/material.dart';

extension AppSizer on dynamic {
  double sw(BuildContext context) {
    return MediaQuery.of(context).size.width * this;
  }

  double sh(BuildContext context) {
    return MediaQuery.of(context).size.height * this;
  }

  double toRes(BuildContext context) {
    return (MediaQuery.of(context).size.height * this) +
        (MediaQuery.of(context).size.width * this);
  }
}
