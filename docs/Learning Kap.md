# Learning KAP

KAP is a very powerful & customizable command for Dax, it is able to install packages from the DaxRepo, and it uses
CURL to download files, and save binary data.

KAP is written for DSH, but can easily be modified for any other shell systems.

## Help

```
Kux Advanced Packaging
This app will help you install features to Kux/Dax.

-p     --package The package to operate on.
-b      --branch Change the upstream branch.
-U      --update Do a system update.
-e   --reinstall Reinstall the given package.
-C      --config Print the configured default upstream
-A       --check check if PKG is available (by passing -p)
-i     --install Install PKG (Download and install)
-f   --fail-safe Don't install PKG if the CHK fails. (Failsafe)
-h        --help This help information.

```

## Basics

Referring to the help above, basically, you can use letter options (or full names) to download files.

A basic installation looks like:

```bash
kap -i -p sample-package
```

The `-i` flag tells it to install the package we're about to give, and `-p` tells it the package name.

### Shaving a bumpy road

If you don't want any verbose output, then you can pass the `-A` (check) flag.

All it does is check for the command before installing it, and tells you. You can combine this with the `-f` option (condition)

**NO** checks:

```
$ kap -i -p non-existant-package
error: HTTP request returned status code 404 ()
```

**CORRECT FLAGS**:

```
$ kap -A -f -p non-existant-package
Check available: non-existant-package
warning: application not found
```

### Stacking

If you want to minify your commands, instead of typing out each space and flag,
you can put all of the letters into one flag (JUST MAKE SURE YOU PUT ANY *-p* FLAGS AT THE **END** OF THE STACK!!!)

Example:

```
$ kap -ip package
```

is the same as:

```
$ kap -i -p package
```

Doing this is good for speed, but not as easy to read.

And as you will see.. Commands can become very... very... *Complicated*...

```
$ kap -Afib chaotic/unstable -p basename
```

(that command checks for the given package, it also changes the branch to the chaotic one, then
it uses the fail safe method from above, and it installs it.)