import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class  ChatInfo{
  final String pubKey;
  final String name;
  final String symmetricKey;

  ChatInfo({this.pubKey, this.name, this.symmetricKey});
}

