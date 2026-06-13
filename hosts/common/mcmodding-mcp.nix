{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs-slim,
  pnpm_10,
  pnpmConfigHook,
  makeWrapper,
  python3,
  cctools,
  xcbuild,
}:

let
  pnpm = pnpm_10.override { inherit nodejs-slim; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "mcmodding-mcp";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "OGMatrix";
    repo = "mcmodding-mcp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-7f22gyIBFFC6+lTEMpbYA9fsw/2f2H8X7KTgj2jl47Y=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-feUl2B1HYI/haJDJhOue+aDs59szjN2YIrFSsKJlF7Q=";
  };

  nativeBuildInputs =
    [
      nodejs-slim
      pnpmConfigHook
      pnpm
      makeWrapper
      python3
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      cctools
      xcbuild
    ];

  postPatch = ''
    substituteInPlace package.json \
      --replace-fail '"postinstall": "node scripts/postinstall.js",' ""
  '';

  buildPhase = ''
    runHook preBuild

    export npm_config_nodedir=${nodejs-slim}

    pushd node_modules
    pnpm rebuild better-sqlite3 esbuild protobufjs
    popd

    pushd node_modules/.pnpm/sharp@0.34.5/node_modules/sharp
    pnpm run install
    popd

    pnpm build
    CI=true pnpm prune --prod --ignore-scripts

    # Clean up broken symlinks left behind by `pnpm prune`.
    # https://github.com/pnpm/pnpm/issues/3645
    find node_modules -xtype l -delete

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/mcmodding-mcp $out/bin
    cp -r dist node_modules package.json $out/libexec/mcmodding-mcp/

    makeWrapper ${lib.getExe nodejs-slim} $out/bin/mcmodding-mcp \
      --add-flags "$out/libexec/mcmodding-mcp/dist/index.js"

    runHook postInstall
  '';

  meta = with lib; {
    description = "MCP server for Minecraft modding documentation";
    homepage = "https://github.com/OGMatrix/mcmodding-mcp";
    license = licenses.mit;
    mainProgram = "mcmodding-mcp";
    platforms = platforms.unix;
  };
})
