module dax.modules.dsh;

import std.stdio;
import std.algorithm;
import std.json;
import std.conv;
import std.file;
import std.process;
import std.path;
import std.array;
import std.string;

extern (C) char* readline(const char* prompt);
extern (C) void add_history(char* text);


JSONValue dax_config_file()
{
    JSONValue conf = parseJSON(to!string(read("usr/conf.json")));
    return conf;
}

string[] path_list()
{
    string[] l;

    foreach (JSONValue j; dax_config_file()["path"].array())
    {
        l ~= j.str();
    }
    return l;
}

void dsh(string f, string[] args, string[] PATH)
{
    string cf;
    int found = 0;

    foreach (string path; PATH)
    {
        path = expandTilde(path);
        if (!endsWith(path, "/"))
        {
            path ~= "/";
        }
        if (exists(path ~ f))
        {
            found = 1;
            try {
            auto proc = spawnProcess([path ~ f] ~ args);
            if (wait(proc) != 0)
            {
                break;
            }
            } catch (ProcessException a) {
                writeln(a.msg);
            }
            break;
            
        }
    }

    if (!found)
        writeln(f ~ ": command not found");
}

string[] parse_cmd(string txt)
{
    string cmd;
    string[] args;
    int state = 0;
    foreach (char s; txt)
    {
        if (state == 0 && s == '"')
        {
            state = 1;
        }
        else if (state == 1 && s == '"')
        {
            state = 0;
        }
        else if (s == ' ' && state == 0)
        {
            args ~= cmd;
            cmd = "";
        }
        else
        {
            cmd ~= s;
        }
    }
    if (cmd.length > 0)
    {
        args ~= cmd;
    }
    return args;
}

void main()
{
    writeln("Welcome to DSH!");

    string[] pat = path_list();
    while (true)
    {
        string inp = to!string(readline("$ "));
        add_history(cast(char*)(toStringz(inp)));
        
        string[] command = parse_cmd(inp);
        if (command.length > 0)
        {
            if (command[0] == "cd")
            {
                chdir(command[1]);
            }
            else
            {
                dsh(command[0], command[1 .. $], pat);
            }
        }
    }
}
