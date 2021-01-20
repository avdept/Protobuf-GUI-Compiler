import 'package:protobuf_compiler/models/compiler_opts.dart';
import 'package:protobuf_compiler/models/proto_compiler_option.dart';

class RubyCompilerOption extends ProtoCompilerOption {
  RubyCompilerOption(String name, String protocPath, String grpcPath, String defaultProtoBinaryName, String defaultGrpcBinaryName, bool selected,
      {needsProtoPlugin = false, needsGrpcPlugin = false})
      : super(name, protocPath, grpcPath, defaultProtoBinaryName, defaultGrpcBinaryName, selected,
            needsProtoPlugin: needsProtoPlugin, needsGrpcPlugin: needsGrpcPlugin);

  @override
  List<String> protoCompilerOpts(CompilerOpts compiler) {
    return ["--ruby_out=${compiler.outputPath}"];
  }

  @override
  List<String> grpcCompilerOpts(CompilerOpts compiler) {
    return ["--grpc_out=${compiler.outputPath}", "--plugin=protoc-gen-grpc=${this.grpcPath}"];
  }
}
