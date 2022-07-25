module dax.preload;

import dax.processor;
import std.stdio : writeln;
import std.file : read, exists, mkdir, write;
import std.conv;

void p_initialize() {
    if (!("usr/".exists)) {
        "usr".mkdir();
    }

    bool tos = false;

    if (!("usr/init").exists) {
        writeln("adding DSH as the startup shell...");

        write("usr/init", "dsh");
    } else {
        string startup = to!string(read("usr/init"));

        run_command("usr/bin/dsh", []);
    }
}