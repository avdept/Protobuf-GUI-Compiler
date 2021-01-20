import 'dart:io';

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:process_run/which.dart';
import 'package:protobuf_compiler/models/go_compiler_option.dart';
import 'package:protobuf_compiler/models/proto_compiler_option.dart';
import 'package:protobuf_compiler/shell_service.dart';
import 'package:window_size/window_size.dart';
import 'constants.dart';
import 'models/compiler_opts.dart';
import 'models/cpp_compiler_option.dart';

final CompilerOpts opts = CompilerOpts('', '', [], '');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle("Protobuf GUI compiler");
    setWindowMinSize(Size(1280, 800));
    setWindowMaxSize(Size(1280, 800));
  }
  runApp(ProtobufCompilerApp(items: buildCompileOptions()));
}

List<ProtoCompilerOption> buildCompileOptions() {
  final cpp = CppCompilerOption(CPP, '', '', '', 'grpc_cpp_plugin', false, needsProtoPlugin: false, needsGrpcPlugin: true);
  final go = GoCompilerOption(GO, '', '', 'protoc-gen-go', 'protoc-gen-go-grpc', false, needsProtoPlugin: true, needsGrpcPlugin: true);

  return [cpp, go];
}

class ProtobufCompilerApp extends StatelessWidget {
  final List<ProtoCompilerOption> items;
  // This widget is the root of your application.
  @override
  ProtobufCompilerApp({Key key, this.items}) : super(key: key);
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Protobuf GUI compiler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RootPage(title: 'Protobuf GUI compiler', items: items),
    );
  }
}

class RootPage extends StatefulWidget {
  RootPage({Key key, this.title, this.items}) : super(key: key);

  final List<ProtoCompilerOption> items;
  final String title;

  @override
  _RootPageState createState() => _RootPageState(items: this.items);
}

class _RootPageState extends State<RootPage> {
  @override
  _RootPageState({this.items});

  final List<ProtoCompilerOption> items;

  void _openBinFileSelector() {
    showOpenPanel(allowsMultipleSelection: false).then((value) => setState(() {
          opts.protocPath = value.paths.first;
        }));
  }

  bool _compileEnabled() {
    return opts.protocPath != null && opts.outputPath != null && opts.selectedFiles != [] && _anyOptionSelected();
  }

  bool _grpcCompileEnabled() {
    return opts.protocPath != null && opts.outputPath != null && opts.selectedFiles != [] && _grpcOptionSelectedAndValid();
  }

  bool _grpcOptionSelectedAndValid() {
    return this.items.where((item) => (item.selected == true) && item.isGrpcValid())?.isNotEmpty;
  }

  bool _anyOptionSelected() {
    return this.items.where((item) => item.selected == true).isNotEmpty;
  }

  void _openOutputPathSelector() {
    showOpenPanel(allowsMultipleSelection: false, canSelectDirectories: true).then((value) => setState(() {
          opts.outputPath = value.paths.first;
        }));
  }

  void _openGrpcPluginPathSelector(ProtoCompilerOption item) {
    showOpenPanel(allowsMultipleSelection: false, canSelectDirectories: false).then((value) => setState(() {
          item.grpcPath = value.paths.first;
        }));
  }

  void _openProtoPluginPathSelector(ProtoCompilerOption item) {
    showOpenPanel(allowsMultipleSelection: false, canSelectDirectories: false).then((value) => setState(() {
          item.protocPath = value.paths.first;
        }));
  }

  void _openIncludePathSelector() {
    showOpenPanel(allowsMultipleSelection: false, canSelectDirectories: true).then((value) => setState(() {
          opts.includePath = value.paths.first;
        }));
  }

  void _openProtosSelector() {
    showOpenPanel(allowsMultipleSelection: true, canSelectDirectories: false, allowedFileTypes: [
      FileTypeFilterGroup(fileExtensions: ["proto"])
    ]).then((value) => setState(() {
          opts.selectedFiles = value.paths.map((name) => name).toList();
        }));
  }

  Widget successDialog(BuildContext context, Map<String, ProcessResult> results) {
    List<Widget> resultRows = [];
    results.keys.forEach((String element) {
      String desc = results[element].exitCode == 0 ? 'Compiled succesfully' : results[element].stderr.toString().replaceAll(RegExp('null:'), '');
      resultRows.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [Expanded(child: Text('$element: $desc', overflow: TextOverflow.visible))]));
    });
    return AlertDialog(
      title: Text("Compilation result"),
      content: Container(
        child: Column(children: resultRows, mainAxisAlignment: MainAxisAlignment.start, mainAxisSize: MainAxisSize.min),
        key: UniqueKey(),
        width: 600,
      ),
      actions: [
        MaterialButton(child: Text("Close"), onPressed: () => {Navigator.of(context).pop()})
      ],
    );
  }

  void _showResult(BuildContext context, Map<String, ProcessResult> results) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return this.successDialog(context, results);
        });
  }

  void _compileGrpcs(BuildContext context) {
    Map<String, ProcessResult> compileResult = {};
    this.selectedOutputList().forEach((item) {
      ShellService(item, opts).compileGrpcs().then((ProcessResult result) => {
            compileResult[item.name] = result,
            if (this.selectedOutputList().last == item) {this._showResult(context, compileResult)}
          });
    });
  }

  List<ProtoCompilerOption> selectedOutputList() {
    return this.items.where((item) => (item.selected == true)).toList();
  }

  void _compile(BuildContext context) {
    Map<String, ProcessResult> compileResult = {};
    this.selectedOutputList().forEach((item) {
      var service = ShellService(item, opts);
      service.compileProtos().then((ProcessResult result) => {
            compileResult[item.name] = result,
            if (this.selectedOutputList().last == item) {this._showResult(context, compileResult)}
          });
    });
  }

  String binDescriptionText() {
    if (Platform.isMacOS || Platform.isLinux) {
      String protocPath = whichSync('protoc');
      if (protocPath != null) {
        opts.protocPath = protocPath;
      }
    }
    return opts.protocPath == '' ? "Select protoc file executable" : "Binary selected at ${opts.protocPath}";
  }

  String outputPathDescriptionText() {
    return opts.outputPath == '' ? "Path not selected" : "Path selected at ${opts.outputPath}";
  }

  String protosPathDescriptionText() {
    return opts.selectedFiles == [] ? "Files not selected" : "Selected files: ${opts.selectedFiles.join(", ")}";
  }

  String includePathText() {
    return opts.includePath == '' ? "Path not selected" : "Path selected at ${opts.includePath}";
  }

  String pluginPathText(ProtoCompilerOption item) {
    return item.grpcPath == null ? "Plugin Path not selected" : "Path selected at ${item.grpcPath}";
  }

  Widget _buildBinarySection() {
    return Container(
      padding: EdgeInsets.only(top: 25),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            MaterialButton(
              color: Color(0xFF508CA4),
              onPressed: _openBinFileSelector,
              child: Text("Select protoc executable file", style: TextStyle(color: Color(0xFFFCF7FF))),
            )
          ]),
          Container(
            padding: EdgeInsets.only(top: 5.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [Text(this.binDescriptionText(), key: UniqueKey(), style: TextStyle(color: Color(0xFFC7C7C7), fontSize: 12))]),
          )
        ],
      ),
      height: 100,
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(width: 2.0, color: Color(0xFF232E21)),
      )),
      margin: EdgeInsets.only(top: 10.0),
    );
  }

  Widget _buildOutputSection() {
    return Container(
      padding: EdgeInsets.only(top: 25),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            MaterialButton(
              color: Color(0xFF508CA4),
              onPressed: _openOutputPathSelector,
              child: Text("Select output folder", style: TextStyle(color: Color(0xFFFCF7FF))),
            )
          ]),
          Container(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [Text(this.outputPathDescriptionText(), key: UniqueKey(), style: TextStyle(color: Color(0xFFC7C7C7), fontSize: 12))]),
              padding: EdgeInsets.only(top: 5.0))
        ],
      ),
      height: 100,
      decoration: BoxDecoration(
          color: Color(0xFFFCF7FF),
          border: Border(
            bottom: BorderSide(width: 2.0, color: Color(0xFF232E21)),
          )),
      margin: EdgeInsets.only(top: 10.0),
    );
  }

  Widget _buildProtoSelectionSection() {
    return Container(
        padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 25),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              MaterialButton(
                color: Color(0xFF508CA4),
                onPressed: _openProtosSelector,
                child: Text("Select proto files to compile", style: TextStyle(color: Color(0xFFFCF7FF))),
              )
            ]),
            Container(
                child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.max, children: [
                  Expanded(
                      child: Text(this.protosPathDescriptionText(),
                          key: UniqueKey(),
                          style: TextStyle(color: Color(0xFFC7C7C7), fontSize: 12),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.visible))
                ]),
                padding: EdgeInsets.only(top: 5))
          ],
        ),
        height: 100,
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(width: 2.0, color: Color(0xFF232E21)),
        )),
        margin: EdgeInsets.only(top: 10.0));
  }

  Widget _buildIncludePathSection() {
    return Container(
      padding: EdgeInsets.only(top: 25),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            MaterialButton(
              color: Color(0xFF508CA4),
              onPressed: _openIncludePathSelector,
              child: Text("Select include folder", style: TextStyle(color: Color(0xFFFCF7FF))),
            )
          ]),
          Container(
              child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.max, children: [
                Expanded(
                    child:
                        Text(this.includePathText(), key: UniqueKey(), textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFC7C7C7), fontSize: 12)))
              ]),
              padding: EdgeInsets.only(top: 5))
        ],
      ),
      height: 100,
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(width: 2.0, color: Color(0xFF232E21)),
      )),
      margin: EdgeInsets.only(top: 10.0),
    );
  }

  List<Widget> _buildPluginPathButtons(ProtoCompilerOption item) {
    List<Widget> items = [Text(item.name)];
    List<Widget> container = [];
    if (item.needsGrpcPlugin) {
      container.add(MaterialButton(
        color: Color(0xFF508CA4),
        onPressed: () => {this._openGrpcPluginPathSelector(item)},
        child: Text("Select GRPC plugin path", style: TextStyle(color: Color(0xFFFCF7FF))),
      ));
    }

    if (item.needsProtoPlugin) {
      container.add(MaterialButton(
        color: Color(0xFF508CA4),
        onPressed: () => {this._openProtoPluginPathSelector(item)},
        child: Text("Select proto plugin path", style: TextStyle(color: Color(0xFFFCF7FF))),
      ));
    }

    items.add(Container(
      child: Expanded(
        // crossAxisAlignment: CrossAxisAlignment.end,
        // mainAxisAlignment: MainAxisAlignment.start,
        child: Row(
          children: container,
          mainAxisAlignment: MainAxisAlignment.end,
        ),
      ),
    ));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCF7FF),
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),
      body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
        children: <Widget>[
          this._buildBinarySection(),
          this._buildOutputSection(),
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Expanded(child: this._buildProtoSelectionSection(), flex: 1), Expanded(child: this._buildIncludePathSection(), flex: 1)]),
          Expanded(
              flex: 1,
              child: Container(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = this.items[index];
                      return CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        subtitle: Text(pluginPathText(item), style: TextStyle(fontSize: 12, color: Color(0xFFC7C7C7))),
                        title: Row(
                          children: this._buildPluginPathButtons(item),
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                        value: item.selected,
                        onChanged: (value) {
                          setState(() {
                            item.selected = !item.selected;
                          });
                        },
                      );
                    },
                  ),
                  height: 50)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                width: 200,
                padding: EdgeInsets.only(bottom: 10),
                child: RaisedButton(
                  color: Color(0xFF508CA4),
                  onPressed: this._grpcCompileEnabled() ? () => {this._compileGrpcs(context)} : null,
                  child: Text("Compile GRPC", style: TextStyle(color: Color(0xFFFCF7FF))),
                )),
            Container(
                width: 200,
                padding: EdgeInsets.only(bottom: 10),
                margin: EdgeInsets.only(left: 30),
                child: RaisedButton(
                  color: Color(0xFF508CA4),
                  onPressed: this._compileEnabled() ? () => {this._compile(context)} : null,
                  child: Text("Compile Protobuf", style: TextStyle(color: Color(0xFFFCF7FF))),
                ))
          ])
        ],
      )),
    );
  }
}
