import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

// An asynchronous method to get the path
Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  // For your reference print the AppDoc directory
  // print(directory.path);
  return directory.path;
}

//A method to read from our file
Future<String> readFromFile(String fileName) async {
  try {
    final filePath = await _localPath;
    File readFile = File('$filePath/$fileName');
    // Read the file
    String contents = await readFile.readAsString();
    // Returning the contents of the file
    return contents;
  } catch (e) {
    // If encountering an error, return
    return 'Error!';
  }
}

//A method to write to our file
Future<File> writeToFile(String fileName, String text) async {
  final filePath = await _localPath;
  // Write the file
  File writeFile = File('$filePath/$fileName');
  return writeFile.writeAsString(text);
}