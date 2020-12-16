rec {

  lib = import <nixpkgs/lib>;

  foo = let
    list = lib.range 0 20000;
  in builtins.deepSeq list (builtins.seq (measure "array" (toArray list)) null);

  test = set 0 0 emptyArray;

  count = 4;

  emptyArray = {
    capacity = count;
    contents = [];
    empty = null;
  };

  measure = name: x: builtins.trace "Measure start ${name}" (builtins.seq x (builtins.trace "Measure stop ${name}" x));

  toArray = list: builtins.foldl' (arr: i: (set i (builtins.elemAt list i) arr)) emptyArray (builtins.genList (i: i) (builtins.length list));

  toList = arr: seqListElems (builtins.genList (n: get n arr) arr.capacity);

  seqListElems = list: builtins.seq (builtins.foldl' builtins.seq null list) list;

  set = i: v: arr:
    if i >= arr.capacity
    then set i v { empty = arr.empty; capacity = arr.capacity * count; contents = [ arr.contents ]; }
    else
      let
        go = j: l: c:
          if l == 0 then v
          else seqListElems (builtins.genList (n:
            let
              value = if builtins.length c <= n then if l < count then arr.empty else [] else builtins.elemAt c n;
              match = j >= n * l && j < (n + 1) * l;
            in if match then go (j - n * l) (l / count) value else value
          ) count);
        newContents = go i (arr.capacity / count) arr.contents;
      in builtins.seq newContents { empty = arr.empty; capacity = arr.capacity; contents = newContents; };

  get = i: arr:
    let
      go = j: l: c:
        if l == 0 then c
        else let n = j / l; in
          if builtins.length c <= n then arr.empty
          else go (j - n * l) (l / count) (builtins.elemAt c n);
    in go i (arr.capacity / count) arr.contents;

}
