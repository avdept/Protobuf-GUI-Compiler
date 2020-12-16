import 'dart:io';
import 'package:process_run/cmd_run.dart';
import 'package:process_run/shell.dart';

Map<String, String> compilerTypes = {
  "C++": "--cpp_out",
  "Go": '--go_out',
  "Java": '--java_out'
};

Map<String, Map<String, String>> grcpCompilerTypes = {
  "C++": {"plugin": "--plugin=protoc-gen-grpc", "command": "-grpc_out=."},
  "Go": {"plugin": ""}
};

class ShellService {
  ShellService(this.type, this.protocPath, this.outputPath, this.includesPath,
      this.protos, this.pluginPath);

  String type;
  String protocPath;
  String outputPath;
  String includesPath;
  String pluginPath;

  List<String> protos;

  String error;

  Future<ProcessResult> compileCppGrpc() async {
    List<String> opts = [];
    opts.add("-grpc_out=${this.outputPath}");
    if (this.includesPath != null) {
      opts.add("--proto_path=${this.includesPath}");
    }
    opts.add("--plugin=${this.pluginPath}");

    opts.add(this.protos.join(' '));
    // Run the command
    ProcessCmd cmd = processCmd("${this.protocPath}", opts, runInShell: false);
    print(opts);
    return await runCmd(cmd);
  }

  Future<ProcessResult> compileProtos() async {
    List<String> opts = [];
    opts.add("${compilerTypes[this.type]}=${this.outputPath}");
    if (this.includesPath != null) {
      opts.add("--proto_path=${this.includesPath}");
    }

    opts.add(this.protos.join(' '));
    // Run the command
    ProcessCmd cmd = processCmd("${this.protocPath}", opts, runInShell: false);
    return await runCmd(cmd);
  }
}
