// Kux Advanced Packaging

import std.stdio : writeln, write, File;
import std.getopt;
import std.net.curl;
import std.string;
import std.file : read, setAttributes, dirEntries, exists, getAttributes, getcwd, SpanMode;
import std.process;
import std.path;
import std.conv;
import core.stdc.stdlib;

extern (C) char* readline(const char* prompt);

class ExitException : Exception
{
    int rc;

    @safe pure nothrow this(int rc, string file = __FILE__, size_t line = __LINE__)
    {
        super(null, file, line);
        this.rc = rc;
    }
}

string installerprompt(string prompt, string question, string[] participants)
{
    write(prompt ~ "\n\t");

    foreach (string cm; participants)
    {
        write("\x1b[31;1m" ~ cm ~ "\x1b[0m\t");
    }
    writeln();
    string p = to!string(readline(toStringz(question ~ " (y/n) ")));
    return p;

}

void main(string[] args)
{
    string PATH = environment.get("DAXI_PATH", "./");
    string pkg = null;
    bool chk;
    bool ins;
    bool branch;
    string upstream = "master";

    if (!endsWith(PATH, "/"))
    {
        PATH ~= "/";
    }

    if (PATH ~ "usr".exists)
    {

        if ((PATH ~ "usr/config/default_upstream").exists)
        {
            upstream = to!string(read((PATH ~ "usr/config/default_upstream")));
        }
    }
    bool conf = false;
    bool updatesys = false;
    bool reins = false;
    auto opts = getopt(args,
        std.getopt.config.bundling,
        "package|p", "The package to operate on.", &pkg,
        "branch|b", "Change the upstream branch.", &upstream,
        "update|U", "Do a system update.", &updatesys,
        "reinstall|e", "Reinstall the given package.", &reins,

        "config|C", "Print the configured default upstream", &conf,

        "check|A", "check if PKG is available (by passing -p)", &chk,
        "install|i", "Install PKG (Download and install)", &ins,
        "fail-safe|f", "Don't install PKG if the CHK fails. (Failsafe)", &branch,
    );

    if (opts.helpWanted)
    {
        defaultGetoptPrinter("Kux Advanced Packaging\nThis app will help you install features to Kux/Dax.",
            opts.options);
    }
    else
    {
        try
        {

            if (conf)
            {
                writeln(upstream);
                throw new ExitException(0);
            }
            if (updatesys)
            {
                writeln("updating system..");
                writeln("reviewing binaries..");
                string[] required_updates;
                foreach (string cmd; dirEntries(PATH ~ "usr/dsh", SpanMode.shallow))
                {
                    string cmdname = baseName(cmd);

                    try
                    {
                        auto buff = to!string(std.net.curl.get(
                                "https://raw.githubusercontent.com/thekaigonzalez/DaxRepo/" ~ upstream ~ "/" ~
                                cmdname));

                        auto buff2 = to!string(read(PATH ~ "usr/dsh/" ~ cmdname));

                        if (buff != buff2)
                        {
                            required_updates ~= cmdname;
                        }
                    }
                    catch (CurlException)
                    {
                    }

                }
                if (required_updates.length > 0)
                {

                    string p = installerprompt("some commands need updates:", "would you like to upgrade them?",
                        required_updates);

                    if (p == "n")
                        throw new ExitException(0);

                    writeln("starting upgrade...");

                    foreach (string comd; required_updates)
                    {
                        download("https://raw.githubusercontent.com/thekaigonzalez/DaxRepo/" ~ upstream ~ "/" ~ comd,
                            "usr/dsh/" ~ comd);
                        writeln("\x1b[33;1m" ~ comd ~ "\x1b[0m has been upgraded!");
                        writeln("patching...");
                        ("usr/dsh/" ~ comd).setAttributes(("usr/dsh/" ~ pkg)
                                .getAttributes | octal!700);
                    }
                }

                throw new ExitException(0);
            }
            int available = 0;
            if (pkg == null)
            {
                writeln("did you specify a package?");
                throw new ExitException(1);
            }
            if (chk)
            {
                writeln("Check available: " ~ pkg);

                try
                {
                    std.net.curl.get(
                        "https://raw.githubusercontent.com/thekaigonzalez/DaxRepo/" ~ upstream ~ "/" ~ pkg);

                    available = 1;

                    writeln("check: success (app found on upstream -> " ~ upstream ~ ")");

                }
                catch (CurlException e)
                {
                    writeln("warning: application not found");
                }

                if (branch && available == 0)
                {
                    writeln("Could not continue: not available & failsafe is active (-f).");
                    throw new ExitException(1);
                }
            }
            if (reins)
            {
                if (pkg != null)
                {
                    if (!exists(PATH ~ "usr/dsh/" ~ pkg))
                    {
                        writeln(
                            "'" ~ pkg ~ "' does not exist. Did you mean, kap -i -p \"" ~ pkg ~ "\" ?");
                        throw new ExitException(0);
                    }
                    string inp = installerprompt(
                        "the following commands will be reinstalled " ~
                            "(from upstream " ~ upstream ~ "):", "would you like " ~
                            "to execute this action?", [
                                pkg
                            ]);
                    if (inp == "n")
                    {
                        writeln("operation cancelled.");
                        throw new ExitException(0);
                    }
                    else
                    {
                        writeln("beginning reinstallation...");
                        download("https://raw.githubusercontent.com/thekaigonzalez/DaxRepo/" ~ upstream ~ "/" ~ pkg,
                            "usr/dsh/" ~ pkg);
                        writeln("complete!");
                    }
                }
            }
            if (ins)
            {
                try
                {
                    string n = to!string(std.net.curl.get(
                            "https://raw.githubusercontent.com/thekaigonzalez/DaxRepo/" ~ upstream ~ "/" ~ pkg));

                    writeln("Installing PKG");
                    writeln("Install application?");
                    writeln("Upstream: " ~ upstream);

                    string input = to!string(readline("begin installation? (Y/n) "));

                    if (input == "n")
                    {
                        writeln("Aborting...");
                    }
                    else
                    {
                        writeln("Installing...");
                        download("https://raw.githubusercontent.com/thekaigonzalez/DaxRepo/" ~ upstream ~ "/" ~ pkg,
                            "usr/dsh/" ~ pkg);
                        ("usr/dsh/" ~ pkg).setAttributes(("usr/dsh/" ~ pkg)
                                .getAttributes | octal!700);
                    }
                }
                catch (CurlException e)
                {
                    writeln("error: " ~ e.msg);
                }
            }
        }
        catch (ExitException)
        {
        }
    }
}
