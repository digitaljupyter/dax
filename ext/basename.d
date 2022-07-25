module ext.basename;

import std.path;
import std.stdio;


void main(string[] args) {
    writeln(baseName(args[1]));
}