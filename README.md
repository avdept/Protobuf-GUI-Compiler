# Protobuf compiler

A GUI app for protoc command line tool. It eases a process of compiling `proto` files into selected language. Currently supports following: Dart, Go, C++

![Screenshot 2020-12-14 at 19 01 15](https://user-images.githubusercontent.com/1757017/102111328-eb35d400-3e3e-11eb-97cd-9abb6a2f5cc6.png)




## Getting Started

### Executables

By default app will look for executables in current `PATH` env using its default names. However you are free to select your own binaries using file selector in according section.

* `protoc` - Main executable which will do protobuf compilation
* `protoc-gen-go` - GRPC go plugin executable
* `grpc_cpp_plugin` - GRPC C++ plugin executable
* `protoc-gen-dart` - GRPC Dart plugin executable

## Usage

To compile `.proto` file into selected language you need `protoc` binary selected, input files, include path and output path. After selecting all data - hit `Compile protobuf` and app will produce either compiled protobufs into your selected language or throw an error.

Same applies to GRPC, just make sure you've selected binary for desired language.
