import 'package:protobuf_compiler/models/compiler_opts.dart';
import 'package:protobuf_compiler/models/proto_compiler_option.dart';

class GoCompilerOption extends ProtoCompilerOption {
  GoCompilerOption(String name, String protocPath, String grpcPath, String defaultProtoBinaryName, String defaultGrpcBinaryName, bool selected,
      {needsProtoPlugin = false, needsGrpcPlugin = false})
      : super(name, protocPath, grpcPath, defaultProtoBinaryName, defaultGrpcBinaryName, selected,
            needsProtoPlugin: needsProtoPlugin, needsGrpcPlugin: needsGrpcPlugin);

  @override
  List<String> protoCompilerOpts(CompilerOpts compiler) {
    List<String> opts = [];
    opts.add("--plugin=protoc-gen-go=${this.protocPath}");
    opts.add("--go_out=${compiler.outputPath}");
    return opts;
  }

  @override
  List<String> grpcCompilerOpts(CompilerOpts compiler) {
    List<String> opts = [];
    opts.add("--plugin=protoc-gen-go-grpc=${this.grpcPath}");
    opts.add("--go-grpc_out=${compiler.outputPath}");
    return opts;
  }
}
