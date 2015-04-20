# meteor-publish-tool

These bash scripts are meant to simplify the process of versioning and publishing on a large number of packages.

# Usage

## Publish Tool

The script ```publish-tool.sh``` is designed to be able to automatically detect errors in the process, correct them, and try publishing again. It can be used interactively (default) or in autopublish mode, in which it will automatically try to correct errors. It's usage is as follows:

```
$ ./publish-tool.sh /path/to/package

    -a | --autopublish        Automatically try to correct errors and republish
```

Wildcard expansion and multiple different packages at once works, so you could specify

```
$ ./publish-tool.sh /path/to/packages-dir/*
```

and it would publish all packages it could find.

The errors that publish-tool can automatically handle are:

 * Version already exists - will automatically increment the patch by one.
 * Package has never been published - will automatically use --create

Future planned error handling:

 * Must specify a version for PACKAGE_NAME

## Version Tool

The script ```version-tool.sh``` uses very simple regular expressions to update the version of your package within the package.js without having to ever open the file. It's usage is as follows:

```
$ ./version-tool.sh /path/to/package

    The absence of either the -M or -m flags will result in a patch number increment in the semantic versioning number.

    -M | --major        Will increment the major part of the semantic versioning number and reset the minor and patch number
    -m | --minor        Will increment the minor part of the semantic versioning number and reset the patch number
```

This tool is used by ```publish-tool.sh``` for its automatic mode. This tool also supports wildcard expansion and multiple paths so you can update manyy packages at once.
