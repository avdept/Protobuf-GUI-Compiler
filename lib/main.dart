import 'dart:io';

import 'package:file_chooser/file_chooser.dart';
import 'package:flutter/material.dart';
import 'package:process_run/which.dart';
import 'package:protobuf_compiler/models/proto_compiler_option.dart';
import 'package:protobuf_compiler/shell_service.dart';
import 'package:window_size/window_size.dart';

void main() {
  var availableOptions = {
    "Go": "protoc-gen-go",
    "C++": "grpc_cpp_plugin",
    "Dart": "protoc-gen-dart"
  };
  List<ProtoCompilerOption> items = [];
  availableOptions.forEach((name, defaultPath) => items.add(ProtoCompilerOption(
      name, null, defaultPath, false,
      needsPlugin: defaultPath != '')));
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle("Protobuf compiler");
    setWindowMinSize(Size(1280, 800));
    setWindowMaxSize(Size(1280, 800));
  }
  runApp(ProtobufCompilerApp(items: items));
}

class ProtobufCompilerApp extends StatelessWidget {
  final List<ProtoCompilerOption> items;
  // This widget is the root of your application.
  @override
  ProtobufCompilerApp({Key key, this.items}) : super(key: key);
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Protobuf compiler',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RootPage(title: 'Protobuf compiler', items: items),
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
  String _protoBinPath;
  String _outputPath;
  String _includePath;
  List<String> _selectedOutputList = [];
  List<String> _protosList = [];

  void _openBinFileSelector() {
    showOpenPanel(allowsMultipleSelection: false).then((value) => setState(() {
          _protoBinPath = value.paths.first;
        }));
  }

  bool _compileEnabled() {
    return this._protoBinPath != null &&
        this._outputPath != null &&
        this._protosList != null &&
        _anyOptionSelected();
  }

  bool _anyOptionSelected() {
    return this.items.where((item) => item.selected == true).isNotEmpty;
  }

  void _openOutputPathSelector() {
    showOpenPanel(allowsMultipleSelection: false, canSelectDirectories: false)
        .then((value) => setState(() {
              _outputPath = value.paths.first;
            }));
  }

  void _openIncludePathSelector() {
    showOpenPanel(allowsMultipleSelection: false, canSelectDirectories: true)
        .then((value) => setState(() {
              _includePath = value.paths.first;
            }));
  }

  void _openProtosSelector() {
    showOpenPanel(
        allowsMultipleSelection: true,
        canSelectDirectories: false,
        allowedFileTypes: [
          FileTypeFilterGroup(fileExtensions: ["proto"])
        ]).then((value) => setState(() {
          _protosList = value.paths.map((name) => name).toList();
        }));
  }

  Widget successDialog(
      BuildContext context, Map<String, ProcessResult> results) {
    List<Widget> resultRows = [];
    results.keys.forEach((String element) {
      String desc = results[element].exitCode == 0
          ? 'Compiled succesfully'
          : results[element].stderr.toString().replaceAll(RegExp('null:'), '');
      resultRows.add(Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                child: Text('$element: $desc', overflow: TextOverflow.visible))
          ]));
    });
    return AlertDialog(
      title: Text("Compilation result"),
      content: Container(
        child: Column(
            children: resultRows,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min),
        key: UniqueKey(),
        width: 600,
      ),
      actions: [
        MaterialButton(
            child: Text("Close"),
            onPressed: () => {Navigator.of(context).pop()})
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

  void _compile(BuildContext context) {
    Map<String, ProcessResult> compileResult = {};
    this._selectedOutputList.forEach((lang) {
      var service = ShellService(lang, this._protoBinPath, this._outputPath,
          this._includePath, this._protosList, null);
      service.compileProtos().then((ProcessResult result) => {
            compileResult[lang] = result,
            if (this._selectedOutputList.last == lang)
              {this._showResult(context, compileResult)}
          });
    });
  }

  String binDescriptionText() {
    if (Platform.isMacOS || Platform.isLinux) {
      String protocPath = whichSync('protoc');
      if (protocPath != null) {
        this._protoBinPath = protocPath;
      }
    }
    return this._protoBinPath == null
        ? "Select protoc file executable"
        : "Binary selected at ${this._protoBinPath}";
  }

  String outputPathDescriptionText() {
    return this._outputPath == null
        ? "Path not selected"
        : "Path selected at ${this._outputPath}";
  }

  String protosPathDescriptionText() {
    return this._protosList == null
        ? "Files not selected"
        : "Selected files: ${this._protosList.join(", ")}";
  }

  String includePathText() {
    return this._includePath == null
        ? "Path not selected"
        : "Path selected at ${this._includePath}";
  }

  String pluginPathText(ProtoCompilerOption item) {
    return item.path == null
        ? "Plugin Path not selected"
        : "Path selected at ${item.path}";
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
              child: Text("Select protoc executable file",
                  style: TextStyle(color: Color(0xFFFCF7FF))),
            )
          ]),
          Container(
            padding: EdgeInsets.only(top: 5.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(this.binDescriptionText(),
                      key: UniqueKey(),
                      style: TextStyle(color: Color(0xFFC7C7C7), fontSize: 12))
                ]),
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
              child: Text("Select output folder",
                  style: TextStyle(color: Color(0xFFFCF7FF))),
            )
          ]),
          Container(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(this.outputPathDescriptionText(),
                        key: UniqueKey(),
                        style:
                            TextStyle(color: Color(0xFFC7C7C7), fontSize: 12))
                  ]),
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
                child: Text("Select proto files to compile",
                    style: TextStyle(color: Color(0xFFFCF7FF))),
              )
            ]),
            Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                          child: Text(this.protosPathDescriptionText(),
                              key: UniqueKey(),
                              style: TextStyle(
                                  color: Color(0xFFC7C7C7), fontSize: 12),
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
              child: Text("Select include folder",
                  style: TextStyle(color: Color(0xFFFCF7FF))),
            )
          ]),
          Container(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                        child: Text(this.includePathText(),
                            key: UniqueKey(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFFC7C7C7), fontSize: 12)))
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
              children: [
                Expanded(child: this._buildProtoSelectionSection(), flex: 1),
                Expanded(child: this._buildIncludePathSection(), flex: 1)
              ]),
          Expanded(
              flex: 1,
              child: Container(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = this.items[index];
                      return CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        subtitle: Text(pluginPathText(item),
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFFC7C7C7))),
                        title: Row(
                          children: [
                            Text(item.name),
                            item.needsPlugin
                                ? MaterialButton(
                                    color: Color(0xFF508CA4),
                                    onPressed: _openOutputPathSelector,
                                    child: Text("Select plugin path",
                                        style: TextStyle(
                                            color: Color(0xFFFCF7FF))),
                                  )
                                : Container()
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                        value: item.selected,
                        onChanged: (value) {
                          setState(() {
                            if (this._selectedOutputList.indexOf(item.name) >
                                -1) {
                              this._selectedOutputList.remove(item.name);
                            } else {
                              this._selectedOutputList.add(item.name);
                            }
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
                  onPressed: this._compileEnabled()
                      ? () => {this._compile(context)}
                      : null,
                  child: Text("Compile GRPC",
                      style: TextStyle(color: Color(0xFFFCF7FF))),
                )),
            Container(
                width: 200,
                padding: EdgeInsets.only(bottom: 10),
                margin: EdgeInsets.only(left: 30),
                child: RaisedButton(
                  color: Color(0xFF508CA4),
                  onPressed: this._compileEnabled()
                      ? () => {this._compile(context)}
                      : null,
                  child: Text("Compile Protobuf",
                      style: TextStyle(color: Color(0xFFFCF7FF))),
                ))
          ])
        ],
      )),
    );
  }
}
