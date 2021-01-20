import 'dart:io';
import 'package:process_run/cmd_run.dart';
import 'package:process_run/shell.dart';
import 'constants.dart';
import 'models/compiler_opts.dart';
import 'models/proto_compiler_option.dart';

Map<String, String> compilerTypes = {"C++": "--cpp_out", "Go": '--go_out', "Java": '--java_out'};

Map<String, Map<String, String>> grcpCompilerTypes = {
  "C++": {"plugin": "--plugin=protoc-gen-grpc", "command": "-grpc_out=."},
  "Go": {"plugin": ""}
};

class ShellService {
  ShellService(this.lang, this.compiler);

  CompilerOpts compiler;
  ProtoCompilerOption lang;

  List<String> protos;

  String error;

  Future<ProcessResult> compileGrpcs() async {
    List<String> opts = this.lang.grpcCompilerOpts(compiler);

    if (this.compiler.includePath != null) {
      opts.add("--proto_path=${this.compiler.includePath}");
    }

    opts.add(this.compiler.selectedFiles.join(' '));
    // Run the command
    ProcessCmd cmd = processCmd("${this.compiler.protocPath}", opts, runInShell: false);
    print(cmd.toString());
    return await runCmd(cmd);
  }

  Future<ProcessResult> compileProtos() async {
    List<String> opts = this.lang.protoCompilerOpts(compiler);

    if (this.compiler.includePath != null) {
      opts.add("--proto_path=${this.compiler.includePath}");
    }

    opts.add(this.compiler.selectedFiles.join(' '));
    // Run the command
    ProcessCmd cmd = processCmd("${this.compiler.protocPath}", opts, runInShell: false);
    return await runCmd(cmd);
  }
}
