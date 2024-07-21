import Const "../const";
import Types "../types";
import { rehash } "./rehash";
import { init; initFront } "./init";
import { natToNat32 = nat32; nat32ToNat = nat; trap } "mo:prim";

module {
  type Set<K> = Types.Set<K>;

  type IterNext<T> = Types.IterNext<T>;

  type HashUtils<K> = Types.HashUtils<K>;

  let DATA = Const.DATA;

  let FRONT = Const.FRONT;

  let BACK = Const.BACK;

  let SIZE = Const.SIZE;

  let NULL = Const.NULL;

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func fromIter<K>(iter: IterNext<K>, hashUtils: HashUtils<K>): Set<K> {
    let map = [var null]:Set<K>;

    var dataOpt = map[DATA];
    var front = 1:Nat32;
    var back = 1:Nat32;
    var size = 1:Nat32;
    var capacity = 2:Nat32;

    for (item in iter) label loopBody {
      let data = switch (dataOpt) {
        case (?data) data;

        case (_) {
          ignore init(map, hashUtils, item);

          dataOpt := map[DATA];

          break loopBody;
        };
      };

      let keys = data.0;
      let hashIndex = nat(hashUtils.0(item) % capacity +% capacity);

      let indexes = data.1;
      let firstIndex = indexes[hashIndex];
      var index = firstIndex;
      var prevIndex = NULL;

      loop if (index == NULL) {
        let oldBack = back;
        let backNat = nat(oldBack);

        back := (back +% 1) % capacity;
        size +%= 1;

        keys[backNat] := ?item;
        indexes[backNat] := firstIndex;
        indexes[hashIndex] := backNat;

        if (oldBack == front) {
          let bounds = data.2;

          bounds[FRONT] := front;
          bounds[BACK] := back;
          bounds[SIZE] := size;

          rehash(map, hashUtils);

          dataOpt := map[DATA];

          switch (dataOpt) {
            case (?data) {
              front := data.2[FRONT];
              back := data.2[BACK];
              capacity := nat32(data.0.size());
            };

            case (_) trap("unreachable");
          };
        };

        break loopBody;
      } else {
        let key = keys[index];

        if (hashUtils.1(switch (key) { case (?key) key; case (_) trap("unreachable") }, item)) {
          let index32 = nat32(index);

          if (index32 != (back -% 1) % capacity) {
            let backNat = nat(back);

            back := (back +% 1) % capacity;

            keys[backNat] := key;
            indexes[backNat] := indexes[index];
            keys[index] := null;

            if (prevIndex == NULL) indexes[hashIndex] := backNat else indexes[prevIndex] := backNat;

            let prevFront = (front +% 1) % capacity;

            if (index32 == prevFront) {
              front := prevFront;

              while (switch (keys[nat((front +% 1) % capacity)]) { case (null) true; case (_) false }) {
                front := (front +% 1) % capacity;
              };
            } else if (back == prevFront) {
              let bounds = data.2;

              bounds[FRONT] := front;
              bounds[BACK] := back;
              bounds[SIZE] := size;

              rehash(map, hashUtils);

              dataOpt := map[DATA];

              switch (dataOpt) {
                case (?data) {
                  front := data.2[FRONT];
                  back := data.2[BACK];
                  capacity := nat32(data.0.size());
                };

                case (_) trap("unreachable");
              };
            };
          };

          break loopBody;
        } else {
          prevIndex := index;
          index := indexes[index];
        };
      };
    };

    switch (dataOpt) {
      case (?data) {
        let bounds = data.2;

        bounds[FRONT] := front;
        bounds[BACK] := back;
        bounds[SIZE] := size;
      };

      case (_) {};
    };

    map;
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func fromIterDesc<K>(iter: IterNext<K>, hashUtils: HashUtils<K>): Set<K> {
    let map = [var null]:Set<K>;

    var dataOpt = map[DATA];
    var front = 0:Nat32;
    var back = 0:Nat32;
    var size = 1:Nat32;
    var capacity = 2:Nat32;

    for (item in iter) label loopBody {
      let data = switch (dataOpt) {
        case (?data) data;

        case (_) {
          ignore initFront(map, hashUtils, item);

          dataOpt := map[DATA];

          break loopBody;
        };
      };

      let keys = data.0;
      let hashIndex = nat(hashUtils.0(item) % capacity +% capacity);

      let indexes = data.1;
      let firstIndex = indexes[hashIndex];
      var index = firstIndex;
      var prevIndex = NULL;

      loop if (index == NULL) {
        let oldFront = front;
        let frontNat = nat(oldFront);

        front := (front -% 1) % capacity;
        size +%= 1;

        keys[frontNat] := ?item;
        indexes[frontNat] := firstIndex;
        indexes[hashIndex] := frontNat;

        if (oldFront == back) {
          let bounds = data.2;

          bounds[FRONT] := front;
          bounds[BACK] := back;
          bounds[SIZE] := size;

          rehash(map, hashUtils);

          dataOpt := map[DATA];

          switch (dataOpt) {
            case (?data) {
              front := data.2[FRONT];
              back := data.2[BACK];
              capacity := nat32(data.0.size());
            };

            case (_) trap("unreachable");
          };
        };

        break loopBody;
      } else {
        let key = keys[index];

        if (hashUtils.1(switch (key) { case (?key) key; case (_) trap("unreachable") }, item)) {
          let index32 = nat32(index);

          if (index32 != (front +% 1) % capacity) {
            let frontNat = nat(front);

            front := (front -% 1) % capacity;

            keys[frontNat] := key;
            indexes[frontNat] := indexes[index];
            keys[index] := null;

            if (prevIndex == NULL) indexes[hashIndex] := frontNat else indexes[prevIndex] := frontNat;

            let prevBack = (back -% 1) % capacity;

            if (index32 == prevBack) {
              back := prevBack;

              while (switch (keys[nat((back -% 1) % capacity)]) { case (null) true; case (_) false }) {
                back := (back -% 1) % capacity;
              };
            } else if (front == prevBack) {
              let bounds = data.2;

              bounds[FRONT] := front;
              bounds[BACK] := back;
              bounds[SIZE] := size;

              rehash(map, hashUtils);

              dataOpt := map[DATA];

              switch (dataOpt) {
                case (?data) {
                  back := data.2[BACK];
                  front := data.2[FRONT];
                  capacity := nat32(data.0.size());
                };

                case (_) trap("unreachable");
              };
            };
          };

          break loopBody;
        } else {
          prevIndex := index;
          index := indexes[index];
        };
      };
    };

    switch (dataOpt) {
      case (?data) {
        let bounds = data.2;

        bounds[FRONT] := front;
        bounds[BACK] := back;
        bounds[SIZE] := size;
      };

      case (_) {};
    };

    map;
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func fromIterMap<K, T>(iter: IterNext<T>, hashUtils: HashUtils<K>, mapItem: (T) -> ?K): Set<K> {
    let map = [var null]:Set<K>;

    var dataOpt = map[DATA];
    var front = 1:Nat32;
    var back = 1:Nat32;
    var size = 1:Nat32;
    var capacity = 2:Nat32;

    for (item in iter) label loopBody switch (mapItem(item)) {
      case (?item) {
        let data = switch (dataOpt) {
          case (?data) data;

          case (_) {
            ignore init(map, hashUtils, item);

            dataOpt := map[DATA];

            break loopBody;
          };
        };

        let keys = data.0;
        let hashIndex = nat(hashUtils.0(item) % capacity +% capacity);

        let indexes = data.1;
        let firstIndex = indexes[hashIndex];
        var index = firstIndex;
        var prevIndex = NULL;

        loop if (index == NULL) {
          let oldBack = back;
          let backNat = nat(oldBack);

          back := (back +% 1) % capacity;
          size +%= 1;

          keys[backNat] := ?item;
          indexes[backNat] := firstIndex;
          indexes[hashIndex] := backNat;

          if (oldBack == front) {
            let bounds = data.2;

            bounds[FRONT] := front;
            bounds[BACK] := back;
            bounds[SIZE] := size;

            rehash(map, hashUtils);

            dataOpt := map[DATA];

            switch (dataOpt) {
              case (?data) {
                front := data.2[FRONT];
                back := data.2[BACK];
                capacity := nat32(data.0.size());
              };

              case (_) trap("unreachable");
            };
          };

          break loopBody;
        } else {
          let key = keys[index];

          if (hashUtils.1(switch (key) { case (?key) key; case (_) trap("unreachable") }, item)) {
            let index32 = nat32(index);

            if (index32 != (back -% 1) % capacity) {
              let backNat = nat(back);

              back := (back +% 1) % capacity;

              keys[backNat] := key;
              indexes[backNat] := indexes[index];
              keys[index] := null;

              if (prevIndex == NULL) indexes[hashIndex] := backNat else indexes[prevIndex] := backNat;

              let prevFront = (front +% 1) % capacity;

              if (index32 == prevFront) {
                front := prevFront;

                while (switch (keys[nat((front +% 1) % capacity)]) { case (null) true; case (_) false }) {
                  front := (front +% 1) % capacity;
                };
              } else if (back == prevFront) {
                let bounds = data.2;

                bounds[FRONT] := front;
                bounds[BACK] := back;
                bounds[SIZE] := size;

                rehash(map, hashUtils);

                dataOpt := map[DATA];

                switch (dataOpt) {
                  case (?data) {
                    front := data.2[FRONT];
                    back := data.2[BACK];
                    capacity := nat32(data.0.size());
                  };

                  case (_) trap("unreachable");
                };
              };
            };

            break loopBody;
          } else {
            prevIndex := index;
            index := indexes[index];
          };
        };
      };

      case (_) {};
    };

    switch (dataOpt) {
      case (?data) {
        let bounds = data.2;

        bounds[FRONT] := front;
        bounds[BACK] := back;
        bounds[SIZE] := size;
      };

      case (_) {};
    };

    map;
  };

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  public func fromIterMapDesc<K, T>(iter: IterNext<T>, hashUtils: HashUtils<K>, mapItem: (T) -> ?K): Set<K> {
    let map = [var null]:Set<K>;

    var dataOpt = map[DATA];
    var front = 0:Nat32;
    var back = 0:Nat32;
    var size = 1:Nat32;
    var capacity = 2:Nat32;

    for (item in iter) label loopBody switch (mapItem(item)) {
      case (?item) {
        let data = switch (dataOpt) {
          case (?data) data;

          case (_) {
            ignore initFront(map, hashUtils, item);

            dataOpt := map[DATA];

            break loopBody;
          };
        };

        let keys = data.0;
        let hashIndex = nat(hashUtils.0(item) % capacity +% capacity);

        let indexes = data.1;
        let firstIndex = indexes[hashIndex];
        var index = firstIndex;
        var prevIndex = NULL;

        loop if (index == NULL) {
          let oldFront = front;
          let frontNat = nat(oldFront);

          front := (front -% 1) % capacity;
          size +%= 1;

          keys[frontNat] := ?item;
          indexes[frontNat] := firstIndex;
          indexes[hashIndex] := frontNat;

          if (oldFront == back) {
            let bounds = data.2;

            bounds[FRONT] := front;
            bounds[BACK] := back;
            bounds[SIZE] := size;

            rehash(map, hashUtils);

            dataOpt := map[DATA];

            switch (dataOpt) {
              case (?data) {
                front := data.2[FRONT];
                back := data.2[BACK];
                capacity := nat32(data.0.size());
              };

              case (_) trap("unreachable");
            };
          };

          break loopBody;
        } else {
          let key = keys[index];

          if (hashUtils.1(switch (key) { case (?key) key; case (_) trap("unreachable") }, item)) {
            let index32 = nat32(index);

            if (index32 != (front +% 1) % capacity) {
              let frontNat = nat(front);

              front := (front -% 1) % capacity;

              keys[frontNat] := key;
              indexes[frontNat] := indexes[index];
              keys[index] := null;

              if (prevIndex == NULL) indexes[hashIndex] := frontNat else indexes[prevIndex] := frontNat;

              let prevBack = (back -% 1) % capacity;

              if (index32 == prevBack) {
                back := prevBack;

                while (switch (keys[nat((back -% 1) % capacity)]) { case (null) true; case (_) false }) {
                  back := (back -% 1) % capacity;
                };
              } else if (front == prevBack) {
                let bounds = data.2;

                bounds[FRONT] := front;
                bounds[BACK] := back;
                bounds[SIZE] := size;

                rehash(map, hashUtils);

                dataOpt := map[DATA];

                switch (dataOpt) {
                  case (?data) {
                    back := data.2[BACK];
                    front := data.2[FRONT];
                    capacity := nat32(data.0.size());
                  };

                  case (_) trap("unreachable");
                };
              };
            };

            break loopBody;
          } else {
            prevIndex := index;
            index := indexes[index];
          };
        };
      };

      case (_) {};
    };

    switch (dataOpt) {
      case (?data) {
        let bounds = data.2;

        bounds[FRONT] := front;
        bounds[BACK] := back;
        bounds[SIZE] := size;
      };

      case (_) {};
    };

    map;
  };
};
