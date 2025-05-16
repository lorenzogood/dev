rec {
  findNixFiles = dir: let
    inherit (builtins) attrNames readDir pathExists concatMap;

    # Helper function to build full paths
    fullPath = name: dir + "/${name}";

    # Get directory contents
    contents = readDir dir;

    # Convert contents attrset to list of names
    names = attrNames contents;

    # Filter and process each item
    processItem = name: let
      path = fullPath name;
      type = contents.${name};
    in
      if type == "regular" && hasSuffix "nix" name
      then [path]
      else if type == "directory" && pathExists path
      then findNixFiles path
      else [];
  in
    concatMap processItem names;

  getName = filename: let
    parts = builtins.split "\\." filename;
    base = builtins.head (builtins.split "\\." filename);
  in
    if builtins.length parts == 1
    then filename
    else base;

  getSuffix = filename: let
    parts = builtins.split "\\." filename;
    end = builtins.tail (builtins.split "\\." filename);
  in
    if builtins.length parts == 1
    then filename
    else builtins.elemAt end (builtins.length end - 1);

  hasSuffix = suffix: filename:
    if (getSuffix filename) == suffix
    then true
    else false;
}
