# Protobuf compiler

A GUI app for protoc command line tool. It eases a process of compiling `proto` files into selected language. Currently supports following: 
* Go
* C++
* Ruby

More to be added soon

![app.png](https://user-images.githubusercontent.com/1757017/105152497-f354f380-5b0f-11eb-8784-5f847750beef.png)


## Getting Started

### Executables

By default app will look for executables in current `PATH` env using its default names. However you are free to select your own binaries using file selector in according section.

* `protoc` - Main executable which will do protobuf compilation
* `protoc-gen-go` -  Go protobuf plugin executable
* `protoc-gen-go-grpc` -  GRPC go protobuf plugin executable
* `grpc_cpp_plugin` - GRPC C++ plugin executable
* `grpc_ruby_plugin` - GRCP Ruby plugin executable

## Usage

To compile `.proto` file into selected language you need `protoc` binary selected, input files, include path and output path. After selecting all data - hit `Compile protobuf` and app will produce either compiled protobufs into your selected language or throw an error.

Same applies to GRPC, just make sure you've selected binary for desired language.


## Current limitations
* Not possible to select multiple include paths
* Not possible to save binary file paths as defaults for future usage
