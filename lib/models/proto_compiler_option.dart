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
    result = this.needsProtoPlugin ? this.protocPath != null : true;
    print(this.name);
    print(this.grpcPath);
    result = result && (this.needsGrpcPlugin ? this.grpcPath != null : true);
    return result;
  }

  bool isProtoValid() {
    bool result = true;
    result = this.needsProtoPlugin ? this.protocPath != null : true;

    result = result && (this.needsGrpcPlugin ? this.grpcPath != null : true);
    return result;
  }
}
