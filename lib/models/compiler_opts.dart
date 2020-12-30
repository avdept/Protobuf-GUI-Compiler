class CompilerOpts {
  CompilerOpts(this.protocPath, this.includePath, this.selectedFiles, this.outputPath);

  String protocPath;
  String includePath;
  List<String> selectedFiles = [];
  String outputPath;
}
