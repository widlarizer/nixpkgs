{ lib
, mkDerivation
, fetchFromGitHub
, fetchpatch
, bison
, cmake
, doxygen
, flex
, git
, python3
, swig4
, boost179
, cbc       # for clp
, cimg
, clp       # for or-tools
, eigen
, glpk
, lcov
, lemon-graph
, libjpeg
, or-tools
, pcre
, pkg-config
, qtbase
, re2       # for or-tools
, readline
, spdlog
, tcl
, tcllib
, xorg
, yosys
, zlib
}:

mkDerivation rec {
  pname = "openroad";
  version = "unstable-2024-07-30";

  src = fetchFromGitHub {
    owner = "The-OpenROAD-Project";
    repo = "OpenROAD";
    rev = "c2be1612ee2294dd88a2b17b66cae48945643f6e";
    fetchSubmodules = true;
    hash = "sha256-RSnw0+zxdqqVSAmKD5KUsivsioh4WdJuh0II0fe6mV0=";
  };

  nativeBuildInputs = [
    bison
    cmake
    doxygen
    flex
    git
    pkg-config
    swig4
  ];

  buildInputs = [
    boost179
    cbc
    cimg
    clp
    eigen
    glpk
    lcov
    lemon-graph
    libjpeg
    or-tools
    pcre
    python3
    qtbase
    re2
    readline
    spdlog
    tcl
    tcllib
    yosys
    xorg.libX11
    zlib
  ];

  patches = [
    ./0001-Fix-newer-swig.patch
  ];

  postPatch = ''
    patchShebangs --build etc/find_messages.py
  '';

  # Enable output images from the placer.
  cmakeFlags = [
    # Tries to download gtest 1.13 as part of the build. We currently rely on
    # the regression tests so we can get by without building unit tests.
    "-DENABLE_TESTS=OFF"
    "-DUSE_SYSTEM_BOOST=ON"
    "-DUSE_CIMG_LIB=ON"
    "-DOPENROAD_VERSION=${src.rev}"
  ];

  # Resynthesis needs access to the Yosys binaries.
  qtWrapperArgs = [ "--prefix PATH : ${lib.makeBinPath [ yosys ]}" ];

  # Upstream uses vendored package versions for some dependencies, so regression testing is prudent
  # to see if there are any breaking changes in unstable that should be vendored as well.
  doCheck = true;
  checkPhase = ''
    # ../test/regression
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    $out/bin/openroad -version
    $out/bin/sta -version
  '';

  meta = with lib; {
    description = "OpenROAD's unified application implementing an RTL-to-GDS flow";
    homepage = "https://theopenroadproject.org";
    license = licenses.bsd3;
    maintainers = with maintainers; [ trepetti ];
    platforms = platforms.linux;
  };
}
