{
  lib,
  rustPlatform,
  pkg-config,
  cmake,
  glib,
  openssl,
}:
rustPlatform.buildRustPackage {
  pname = "hivecom-dc";
  version = "0.1.0";
  cargoLock = {
    lockFile = ./Cargo.lock;
  };
  src = lib.cleanSource ./.;

  nativeBuildInputs = [pkg-config cmake];
  buildInputs = [
    glib
    openssl
  ];

  meta = {
    description = "Discord Bot";
    mainProgram = "hivecom-dc";
    maintainers = with lib.maintainers; [jokler];
  };
}
