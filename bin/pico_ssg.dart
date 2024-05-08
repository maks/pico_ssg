import 'dart:io';

import 'package:args/args.dart';
import 'package:markdown/markdown.dart';
import 'package:path/path.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag(
      'version',
      negatable: false,
      help: 'Print the tool version.',
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart pico_ssg.dart <flags> [arguments]');
  print(argParser.usage);
}

void main(List<String> arguments) {
  _parseArguments(arguments);

  final wdFiles = Directory(".").listSync();
  final mdFIles =
      wdFiles
      .map((e) => basename(e.path))
      .where((n) => n.toLowerCase().endsWith('.md'));
  for (String f in mdFIles) {
    final markdown = File(f).readAsStringSync();
    final html = markdownToHtml(markdown);
    final htmlFile = File("$f.html");
    htmlFile.writeAsStringSync(html);
    print("file:$f -> $f.html");
  }
}

void _parseArguments(arguments) {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = false;

    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    if (results.wasParsed('version')) {
      print('pico_ssg version: $version');
      return;
    }
    if (results.wasParsed('verbose')) {
      verbose = true;
    }

    // Act on the arguments provided.
    print('Positional arguments: ${results.rest}');
    if (verbose) {
      print('[VERBOSE] All arguments: ${results.arguments}');
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}
