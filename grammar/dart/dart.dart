// Copyright (c) 2012, Lukas Renggli <renggli@gmail.com>

#library('dart');

#import('dart:io');
#import('../../lib/petitparser.dart');

#source('dart_grammar.dart');
#source('dart_parser.dart');

void main() {
  Parser parser = new DartParser();
  Map<String, String> sources = new Map();

  Directory directory = new Directory('/Applications/Dart/dart-sdk/lib/');
  DirectoryLister lister = directory.list(true);
  lister.onFile = function(String filename) {
    if (filename.endsWith('.dart')) {
      sources[filename] = new File(filename).readAsTextSync(Encoding.UTF_8);
    }
  };
  lister.onDone = function(completed) {
    sources.forEach((key, value) {
      print('$key: ${value.length}');
    });
  };
}