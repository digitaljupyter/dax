module dax.processor;

import std.process;

void run_command(string f, string[] args) {
    auto proc=spawnProcess([f] ~ args);

    if (wait(proc) != 0) {
        return;
    }
}