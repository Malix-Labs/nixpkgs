# Run:
# [nixpkgs]$ nix-instantiate --eval --strict lib/tests/systems.nix
# Expected output: [], or the failed cases
#
# OfBorg runs (approximately) nix-build lib/tests/release.nix
let
  lib = import ../default.nix;
  mseteq = x: y: {
    expr = lib.sort lib.lessThan x;
    expected = lib.sort lib.lessThan y;
  };

  /*
    Try to convert an elaborated system back to a simple string. If not possible,
    return null. So we have the property:

        sys: _valid_ sys ->
          sys == elaborate (toLosslessStringMaybe sys)

    NOTE: This property is not guaranteed when `sys` was elaborated by a different
          version of Nixpkgs.
  */
  toLosslessStringMaybe =
    sys:
    if lib.isString sys then
      sys
    else if lib.systems.equals sys (lib.systems.elaborate sys.system) then
      sys.system
    else
      null;

in
lib.runTests (
  # We assert that the new algorithmic way of generating these lists matches the
  # way they were hard-coded before.
  #
  # One might think "if we exhaustively test, what's the point of procedurally
  # calculating the lists anyway?". The answer is one can mindlessly update these
  # tests as new platforms become supported, and then just give the diff a quick
  # sanity check before committing :).

  (with lib.systems.doubles; {
    testall = mseteq all (
      linux
      ++ darwin
      ++ freebsd
      ++ openbsd
      ++ netbsd
      ++ illumos
      ++ wasi
      ++ windows
      ++ cygwin
      ++ embedded
      ++ mmix
      ++ js
      ++ genode
      ++ redox
      ++ uefi
    );

    testarm = mseteq arm [
      "armv5tel-linux"
      "armv6l-linux"
      "armv6l-netbsd"
      "armv6l-none"
      "armv7a-linux"
      "armv7a-netbsd"
      "armv7l-linux"
      "armv7l-netbsd"
      "arm-none"
    ];
    testarmv7 = mseteq armv7 [
      "armv7a-linux"
      "armv7l-linux"
      "armv7a-netbsd"
      "armv7l-netbsd"
    ];
    testi686 = mseteq i686 [
      "i686-linux"
      "i686-freebsd"
      "i686-genode"
      "i686-netbsd"
      "i686-openbsd"
      "i686-cygwin"
      "i686-windows"
      "i686-none"
    ];
    testmips = mseteq mips [
      "mips-none"
      "mips64-none"
      "mips-linux"
      "mips64-linux"
      "mips64el-linux"
      "mipsel-linux"
      "mipsel-netbsd"
    ];
    testmmix = mseteq mmix [ "mmix-mmixware" ];
    testpower = mseteq power [
      "powerpc-linux"
      "powerpc-netbsd"
      "powerpc-none"
      "powerpc64-linux"
      "powerpc64le-linux"
      "powerpcle-none"
    ];
    testriscv = mseteq riscv [
      "riscv32-linux"
      "riscv64-linux"
      "riscv32-netbsd"
      "riscv64-netbsd"
      "riscv32-none"
      "riscv64-none"
    ];
    testriscv32 = mseteq riscv32 [
      "riscv32-linux"
      "riscv32-netbsd"
      "riscv32-none"
    ];
    testriscv64 = mseteq riscv64 [
      "riscv64-linux"
      "riscv64-netbsd"
      "riscv64-none"
    ];
    tests390x = mseteq s390x [
      "s390x-linux"
      "s390x-none"
    ];
    testx86_64 = mseteq x86_64 [
      "x86_64-linux"
      "x86_64-freebsd"
      "x86_64-genode"
      "x86_64-redox"
      "x86_64-openbsd"
      "x86_64-netbsd"
      "x86_64-cygwin"
      "x86_64-solaris"
      "x86_64-windows"
      "x86_64-none"
      "x86_64-uefi"
    ];

    testcygwin = mseteq cygwin [
      "i686-cygwin"
      "x86_64-cygwin"
    ];
    testdarwin = mseteq darwin [
      "aarch64-darwin"
    ];
    testfreebsd = mseteq freebsd [
      "aarch64-freebsd"
      "i686-freebsd"
      "x86_64-freebsd"
    ];
    testgenode = mseteq genode [
      "aarch64-genode"
      "i686-genode"
      "x86_64-genode"
    ];
    testredox = mseteq redox [ "x86_64-redox" ];
    testgnu = mseteq gnu linux; # ++ kfreebsd ++ ...
    testillumos = mseteq illumos [ "x86_64-solaris" ];
    testlinux = mseteq linux [
      "aarch64-linux"
      "arc-linux"
      "armv5tel-linux"
      "armv6l-linux"
      "armv7a-linux"
      "armv7l-linux"
      "i686-linux"
      "loongarch64-linux"
      "m68k-linux"
      "sh4-linux"
      "microblaze-linux"
      "microblazeel-linux"
      "mips-linux"
      "mips64-linux"
      "mips64el-linux"
      "mipsel-linux"
      "powerpc-linux"
      "powerpc64-linux"
      "powerpc64le-linux"
      "riscv32-linux"
      "riscv64-linux"
      "s390-linux"
      "s390x-linux"
      "x86_64-linux"
    ];
    testnetbsd = mseteq netbsd [
      "aarch64-netbsd"
      "armv6l-netbsd"
      "armv7a-netbsd"
      "armv7l-netbsd"
      "i686-netbsd"
      "m68k-netbsd"
      "mipsel-netbsd"
      "powerpc-netbsd"
      "riscv32-netbsd"
      "riscv64-netbsd"
      "x86_64-netbsd"
    ];
    testopenbsd = mseteq openbsd [
      "i686-openbsd"
      "x86_64-openbsd"
    ];
    testwindows = mseteq windows [
      "aarch64-windows"
      "i686-windows"
      "x86_64-windows"
    ];
    testunix = mseteq unix (
      linux ++ darwin ++ freebsd ++ openbsd ++ netbsd ++ illumos ++ cygwin ++ redox
    );
  })

  // {
    test_platforms_pass_typecheck = {
      # To improve performance, the result of parsing all 70+ systems in
      # `lib.platforms` into their attrset representations aren't typechecked.
      # The results are expected to be constant, and avoiding the slow
      # validation gives a meaningful improvement to evaluation speed. We ensure
      # that all systems pass validation here
      expr = builtins.filter (
        system:
        let
          evalResult = builtins.tryEval (lib.systems.parse.mkSystemFromString system);
        in
        evalResult.success == false
      ) lib.platforms.all;

      expected = [ ];
    };
    test_equals_example_x86_64-linux = {
      expr = lib.systems.equals (lib.systems.elaborate "x86_64-linux") (
        lib.systems.elaborate "x86_64-linux"
      );
      expected = true;
    };

    test_toLosslessStringMaybe_example_x86_64-linux = {
      expr = toLosslessStringMaybe (lib.systems.elaborate "x86_64-linux");
      expected = "x86_64-linux";
    };
    test_toLosslessStringMaybe_fail = (
      let
        baseSystem = lib.systems.elaborate "x86_64-linux";
      in
      {
        expr = toLosslessStringMaybe (
          baseSystem
          // {
            _withoutFunctions = baseSystem._withoutFunctions // {
              something = "extra";
            };
          }
        );
        expected = null;
      }
    );
    test_elaborate_config_over_system = {
      expr =
        (lib.systems.elaborate {
          config = "i686-unknown-linux-gnu";
          system = "x86_64-linux";
        }).system;
      expected = "i686-linux";
    };
    test_elaborate_config_over_parsed = {
      expr =
        (lib.systems.elaborate {
          config = "i686-unknown-linux-gnu";
          parsed = (lib.systems.elaborate "x86_64-linux").parsed;
        }).parsed.cpu.arch;
      expected = "i686";
    };
    test_elaborate_system_over_parsed = {
      expr =
        (lib.systems.elaborate {
          system = "i686-linux";
          parsed = (lib.systems.elaborate "x86_64-linux").parsed;
        }).parsed.cpu.arch;
      expected = "i686";
    };
    test_equals_reelaborate_overridden_platform = {
      expr =
        let
          base = lib.systems.elaborate "x86_64-linux";
        in
        lib.systems.equals base (
          lib.systems.elaborate (
            base
            // {
              useLLVM = true;
              linker = "lld";
            }
          )
        );
      expected = false;
    };

    test_x86_64_microarch_parse = {
      expr = {
        v1 = (lib.systems.parse.mkSystemFromString "x86_64-v1-linux").cpu.name;
        v2 = (lib.systems.parse.mkSystemFromString "x86_64-v2-linux").cpu.name;
        v3 = (lib.systems.parse.mkSystemFromString "x86_64-v3-linux").cpu.name;
        v4 = (lib.systems.parse.mkSystemFromString "x86_64-v4-linux").cpu.name;
        v3_underscore = (lib.systems.parse.mkSystemFromString "x86_64_v3-linux").cpu.name;
        v3_triplet = (lib.systems.parse.mkSystemFromString "x86_64-v3-unknown-linux-gnu").cpu.name;
      };
      expected = {
        v1 = "x86_64-v1";
        v2 = "x86_64-v2";
        v3 = "x86_64-v3";
        v4 = "x86_64-v4";
        v3_underscore = "x86_64-v3";
        v3_triplet = "x86_64-v3";
      };
    };

    test_x86_64_microarch_elaborate = {
      expr =
        let
          v3 = lib.systems.elaborate "x86_64-v3-linux";
        in
        {
          inherit (v3) system isx86_64;
          gcc_arch = v3.gcc.arch;
          uname_processor = v3.uname.processor;
          rustcTarget = v3.rust.rustcTarget;
          goamd64 = v3.go.GOAMD64;
        };
      expected = {
        system = "x86_64-v3-linux";
        isx86_64 = true;
        gcc_arch = "x86-64-v3";
        uname_processor = "x86_64";
        rustcTarget = "x86_64-unknown-linux-gnu";
        goamd64 = "v3";
      };
    };

    test_x86_64_microarch_canExecute = {
      expr =
        let
          base = lib.systems.elaborate "x86_64-linux";
          v1 = lib.systems.elaborate "x86_64-v1-linux";
          v3 = lib.systems.elaborate "x86_64-v3-linux";
        in
        {
          v3_canExecute_v1 = v3.canExecute v1;
          v1_canExecute_v3 = v1.canExecute v3;
          base_canExecute_v1 = base.canExecute v1;
          v1_canExecute_base = v1.canExecute base;
          v3_canExecute_base = v3.canExecute base;
          base_canExecute_v3 = base.canExecute v3;
        };
      expected = {
        v3_canExecute_v1 = true;
        v1_canExecute_v3 = false;
        base_canExecute_v1 = true;
        v1_canExecute_base = true;
        v3_canExecute_base = true;
        base_canExecute_v3 = false;
      };
    };
  }
  // {
    # equals.functionNames must list exactly the function-valued attrs of an
    # elaborated system, so that _withoutFunctions stays correct without
    # iterating.
    test_equals_functionNames_in_sync =
      let
        sys = lib.systems.elaborate "x86_64-linux";
        actual = lib.filter (n: builtins.isFunction sys.${n}) (builtins.attrNames sys);
        expected = lib.sort lib.lessThan lib.systems.functionNames;
      in
      {
        expr = lib.sort lib.lessThan actual;
        inherit expected;
      };
  }

  # Generate test cases to assert that a change in any non-function attribute makes a platform unequal
  // (
    let
      # arbitrary choice, just to get all the elaborated attrNames
      baseSystem = lib.systems.elaborate "x86_64-linux";
    in
    lib.concatMapAttrs (platformAttrName: origValue: {
      ${"test_equals_unequal_${platformAttrName}"} =
        let
          # lib.systems.equals only checks the subattrset
          modified =
            assert origValue != arbitraryValue;
            baseSystem
            // {
              _withoutFunctions = baseSystem._withoutFunctions // {
                ${platformAttrName} = arbitraryValue;
              };
            };
          arbitraryValue = x: "<<modified>>";
        in
        {
          expr = lib.systems.equals baseSystem modified;
          expected = false;
        };

    }) baseSystem
  )

)
