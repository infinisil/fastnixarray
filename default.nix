rec {

  testArray = {
    capacity = 2;
    contents = [ 1 2 ];
    empty = "empty";
  };

  foo = set 2 "hi" (set 4 10 (set 3 1 testArray));

  set = i: v: arr:
    if i >= arr.capacity
    then set i v { empty = arr.empty; capacity = arr.capacity * 2; contents = [ arr.contents ]; }
    else
      let
        go = j: l: c:
          let
            left = if builtins.length c <= 0 then if l == 1 then arr.empty else [] else builtins.elemAt c 0;
            right = if builtins.length c <= 1 then if l == 1 then arr.empty else [] else builtins.elemAt c 1;
          in
          if l == 0 then builtins.trace "Setting v" v
          else if j >= l then builtins.trace "Going right" [
            left
            (go (j - l) (l / 2) right)
          ] else builtins.trace "Going left" [
            (go j (l / 2) left)
            right
          ];
      in { empty = arr.empty; capacity = arr.capacity; contents = go i (arr.capacity / 2) arr.contents; };

  get = i: arr:
    let
      # j < size(c)
      go = j: l: c:
        if l == 0 then c
        else if j >= l then
          if builtins.length c <= 1 then arr.empty
          else go (j - l) (l / 2) (builtins.elemAt c 1)
        else
          if builtins.length c <= 0 then arr.empty
          else go j (l / 2) (builtins.elemAt c 0);
    in go i (arr.capacity / 2) arr.contents;

    #go 0 2 [ 5 7 ]

  test = builtins.genList (n: get n testArray) testArray.capacity;
   

}
