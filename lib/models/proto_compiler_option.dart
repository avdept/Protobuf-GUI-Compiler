import 'package:process_run/which.dart';

class ProtoCompilerOption {
  String name;
  String protocPath;
  String grpcPath;
  bool needsProtoPlugin;
  bool needsGrpcPlugin;
  String defaultProtoBinaryName;
  String defaultGrpcBinaryName;
  bool selected;
  bool needsProtoBinary;
  bool needsGrpcBinary;
  ProtoCompilerOption(this.name, this.protocPath, this.grpcPath, this.defaultProtoBinaryName, this.defaultGrpcBinaryName, this.selected,
      {this.needsProtoPlugin = false, this.needsGrpcPlugin = false}) {
    tryFindPlugin();
  }

  void tryFindPlugin() {
    if (!needsProtoPlugin) return;
    String pluginPath = whichSync(defaultProtoBinaryName);
    this.protocPath = pluginPath;
  }

  bool isGrpcValid() {
    bool result = true;
    result = this.needsProtoPlugin ? this.protocPath.isNotEmpty : true;

    result = this.needsGrpcPlugin ? this.grpcPath.isNotEmpty : true;
    return result;
  }

  bool isProtoValid() {
    bool result = true;
    result = this.needsProtoPlugin ? this.protocPath.isNotEmpty : true;

    result = this.needsGrpcPlugin ? this.grpcPath.isNotEmpty : true;
    return result;
  }
}
