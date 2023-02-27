{
  description = "wash - wasmCloud Shell";

  inputs.nixify.url = github:rvolosatovs/nixify;

  outputs = {
    self,
    nixify,
  }:
    with nixify.lib;
      rust.mkFlake {
        src = self;

        excludePaths = [
          ".devcontainer"
          ".github"
          ".gitignore"
          ".pre-commit-config.yaml"
          "Dockerfile"
          "flake.lock"
          "flake.nix"
          "LICENSE"
          "Makefile"
          "README.md"
          "rust-toolchain.toml"
          "snap"
          "tools"

          # Exclude unsupported tests

          # These require non-deterministic networking, which is not available in Nix sandbox:
          "tests/integration_build.rs"
          "tests/integration_claims.rs"

          # This test fails with:
          # ```
          # wash-cli> test integration_par_inspect_cached ... FAILED
          # wash-cli> test integration_par_inspect ... FAILED
          # wash-cli> failures:
          # wash-cli> ---- integration_par_inspect_cached stdout ----
          # wash-cli> thread 'integration_par_inspect_cached' panicked at 'assertion failed: get_http_client.status.success()', tests/integration_par.rs:326:5
          # wash-cli> note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
          # wash-cli> ---- integration_par_inspect stdout ----
          # wash-cli> thread 'integration_par_inspect' panicked at 'assertion failed: get_http_client.status.success()', tests/integration_par.rs:242:5
          # wash-cli> failures:
          # wash-cli>     integration_par_inspect
          # wash-cli>     integration_par_inspect_cached
          # wash-cli> test result: FAILED. 1 passed; 2 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.55s
          # wash-cli> error: test failed, to rerun pass `--test integration_par`
          # ```
          "tests/integration_par.rs"

          # This test fails with:
          # wash-cli> running 4 tests
          # wash-cli> test integration_pull_basic ... FAILED
          # wash-cli> test integration_pull_comprehensive ... FAILED
          # wash-cli> test integration_push_basic ... FAILED
          # wash-cli> test integration_push_comprehensive ... FAILED
          # wash-cli> failures:
          # wash-cli> ---- integration_pull_basic stdout ----
          # wash-cli> thread 'integration_pull_basic' panicked at 'assertion failed: pull_basic.status.success()', tests/integration_reg.rs:31:5
          # wash-cli> note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
          # wash-cli> ---- integration_pull_comprehensive stdout ----
          # wash-cli> thread 'integration_pull_comprehensive' panicked at 'assertion failed: pull_echo_comprehensive.status.success()', tests/integration_reg.rs:61:5
          # wash-cli> ---- integration_push_basic stdout ----
          # wash-cli> thread 'integration_push_basic' panicked at 'assertion failed: push_echo.status.success()', tests/integration_reg.rs:125:5
          # wash-cli> ---- integration_push_comprehensive stdout ----
          # wash-cli> thread 'integration_push_comprehensive' panicked at 'assertion failed: push_all_options.status.success()', tests/integration_reg.rs:198:5
          # wash-cli> failures:
          # wash-cli>     integration_pull_basic
          # wash-cli>     integration_pull_comprehensive
          # wash-cli>     integration_push_basic
          # wash-cli>     integration_push_comprehensive
          # wash-cli> test result: FAILED. 0 passed; 4 failed; 0 ignored; 0 measured; 0 filtered out; finished in 1.90s
          # wash-cli> error: test failed, to rerun pass `--test integration_reg`
          "tests/integration_reg.rs"

          # This test fails with:
          # wash-cli> test doesnt_kill_unowned_nats ... FAILED
          # wash-cli> {
          # wash-cli>   "success": false,
          # wash-cli>   "error": "Permission denied (os error 13)"
          # wash-cli> }
          # wash-cli> test can_stop_detached_host ... FAILED
          # wash-cli> {
          # wash-cli>   "error": "Permission denied (os error 13)",
          # wash-cli>   "success": false
          # wash-cli> }
          # wash-cli> test integration_up_can_start_wasmcloud_and_actor ... FAILED
          # wash-cli> failures:
          # wash-cli> ---- doesnt_kill_unowned_nats stdout ----
          # wash-cli> Error: Failed to request NATS release: reqwest::Error { kind: Request, url: Url { scheme: "https", cannot_be_a_base: false, username: "", password: None, host: Some(Domain("github.com")), port: None, path: "/nats-io/nats-server/releases/download/v2.8.4/nats-server-v2.8.4-linux-amd64.tar.gz", query: None, fragment: None }, source: hyper::Error(Connect, ConnectError("dns error", Custom { kind: Uncategorized, error: "failed to lookup address information: Temporary failure in name resolution" })) }
          # wash-cli> ---- can_stop_detached_host stdout ----
          # wash-cli> thread 'can_stop_detached_host' panicked at 'assertion failed: status.success()', tests/integration_up.rs:88:5
          # wash-cli> note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
          # wash-cli> ---- integration_up_can_start_wasmcloud_and_actor stdout ----
          # wash-cli> thread 'integration_up_can_start_wasmcloud_and_actor' panicked at 'assertion failed: status.success()', tests/integration_up.rs:28:5
          # wash-cli> failures:
          # wash-cli>     can_stop_detached_host
          # wash-cli>     doesnt_kill_unowned_nats
          # wash-cli>     integration_up_can_start_wasmcloud_and_actor
          # wash-cli> test result: FAILED. 0 passed; 3 failed; 0 ignored; 0 measured; 0 filtered out; finished in 0.03s
          # wash-cli> error: test failed, to rerun pass `--test integration_up`
          "tests/integration_up.rs"
        ];

        buildOverrides = {
          pkgs,
          buildInputs ? [],
          ...
        } @ args: {
          buildInputs =
            buildInputs
            ++ [
              pkgs.protobuf # build dependency of prost-build v0.9.0
            ];
        };

        withDevShells = {
          pkgs,
          devShells,
          ...
        }:
          extendDerivations {
            buildInputs = [
              pkgs.tinygo # required for integration tests
              pkgs.protobuf # build dependency of prost-build v0.9.0
            ];
          }
          devShells;
      };
}
