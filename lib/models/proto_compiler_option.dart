import 'package:process_run/which.dart';
import 'package:protobuf_compiler/models/compiler_opts.dart';

class ProtoCompilerOption {
  String name;
  String protocPath;
  String grpcPath;
  bool needsProtoPlugin;
  bool needsGrpcPlugin;
  String defaultProtoBinaryName;
  String defaultGrpcBinaryName;
  bool selected;
  ProtoCompilerOption(this.name, this.protocPath, this.grpcPath, this.defaultProtoBinaryName, this.defaultGrpcBinaryName, this.selected,
      {this.needsProtoPlugin = false, this.needsGrpcPlugin = false}) {
    tryFindPlugin();
  }

  List<String> protoCompilerOpts(CompilerOpts compiler) {
    throw "Please override protoCompilerOpts in child class";
  }

  List<String> grpcCompilerOpts(CompilerOpts compiler) {
    throw "Please override grpcCompilerOpts in child class";
  }

  void tryFindPlugin() {
    if (!needsProtoPlugin) return;
    String pluginPath = whichSync(defaultProtoBinaryName);
    this.protocPath = pluginPath;
  }

  bool isGrpcValid() {
    bool result = true;
    result = this.needsProtoPlugin ? this.protocPath != '' : true;
    result = result && (this.needsGrpcPlugin ? this.grpcPath != '' : true);
    return result;
  }

  bool isProtoValid() {
    bool result = true;
    result = this.needsProtoPlugin ? this.protocPath != '' : true;

    result = result && (this.needsGrpcPlugin ? this.grpcPath != '' : true);
    return result;
  }
}
