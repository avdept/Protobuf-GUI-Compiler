import 'package:process_run/which.dart';

class ProtoCompilerOption {
  String name;
  String path;
  bool needsPlugin;
  String defaultBinaryName;
  bool selected;
  ProtoCompilerOption(this.name, this.path, this.defaultBinaryName, this.selected, {this.needsPlugin = false}) {
    tryFindPlugin();
  }

  void tryFindPlugin() {
    if (!needsPlugin) return;
    String pluginPath = whichSync(defaultBinaryName);
    this.path = pluginPath;
  }
}
