import 'dart:io';
import 'package:process_run/cmd_run.dart';
import 'package:process_run/shell.dart';

Map<String, String> compilerTypes = {
  "C++": "--cpp_out",
  "Go": '--go_out',
  "Java": '--java_out'
};

class ShellService {
  ShellService(this.type, this.protocPath, this.outputPath, this.includesPath, this.protos, this.pluginPath);

  String type;
  String protocPath;
  String outputPath;
  String includesPath;
  String pluginPath;

  List<String> protos;

  String error;

  Future<ProcessResult> compileProtos() async {
    bool runInShell = Platform.isWindows;

    // Run the command
    ProcessCmd cmd = processCmd(this.protocPath, ["${compilerTypes[this.type]}=${this.outputPath}", "--proto_path=${this.includesPath}", this.protos.join(" ")], runInShell: runInShell);
    print(cmd);
    return await runCmd(cmd);
  }
}
