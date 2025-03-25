
cd graphviz_module/


./autogen.sh

# здесь все инструменты разработчика
XCODE_ROOT=$(xcode-select -print-path)
# корневая папка iPhone OS SDK
XCODE_ARM_ROOT=$XCODE_ROOT/Platforms/iPhoneOS.platform/Developer
# корневая папка iPhone Simulator SDK
XCODE_SIM_ROOT=$XCODE_ROOT/Platforms/iPhoneSimulator.platform/Developer
# здесь все основные утилиты, такие как...
XCODE_TOOLCHAIN_BIN=$XCODE_ROOT/Toolchains/XcodeDefault.xctoolchain/usr/bin 
# C++ компилятор
CXX_COMPILER=${XCODE_TOOLCHAIN_BIN}/clang++
# C компилятор
C_COMPILER=${XCODE_TOOLCHAIN_BIN}/clang 
LD_Complier=${XCODE_TOOLCHAIN_BIN}/ld
SDKROOT=$(xcrun --sdk iphoneos --show-sdk-path)

./configure \
  # --with-smyrna \
  # --with-glutincludedir=/opt/local/include  \
  # --with-glutlibdir=/opt/local/lib \
  # --host=arm-apple-darwin \
  --disable-shared \
  --enable-static \
  # --with-sysroot=$SDKROOT \
  # CFLAGS="-arch arm64 -miphoneos-version-min=18.0 -isysroot $SDKROOT" \
  # CXXFLAGS="-arch arm64 -miphoneos-version-min=18.0 -isysroot $SDKROOT" \
  # LDFLAGS="-arch arm64 -miphoneos-version-min=18.0 -isysroot $SDKROOT" \
  # CC="clang -arch arm64 -miphoneos-version-min=18.0 -isysroot $SDKROOT" \
#   CXX="clang++ -arch arm64 -miphoneos-version-min=18.0 -isysroot $SDKROOT" \
  --disable-dependency-tracking \
  --enable-shared=no \
  --enable-static=yes \
  --enable-ltdl=no \
  --ENABLE_LTDL=no \
  --enable-swig=no \
  --enable-tcl=no \
  --ENABLE_TCL=no \
  --with-codegens=no \
  --with-cgraph=yes \
  --with-expat=no \
  --with-fontconfig=no \
  --with-freetype2=no \
  --with-ipsepcola=no \
  --with-libgd=no \
  --with-gdiplus=no \
  --with-xdot=yes \
  --with-quartz=no \
  --with-visio=no \
  --with-x=no \
  --WITH_ORTHO=no \
  --with_ortho=no \
  --with-pangocairo=no \
  --ENABLE_SWIG=no \
  --WITH_EXPAT=no \
  --WITH_GVEDIT=no \
  --ENABLE_SHARP=no \
  --with-qt=no \
  -DHAVE_DL_ITERATE_PHDR=OFF \
  -DCAIRO_HAS_XLIB_SURFACE=OFF \
  CC="$C_COMPILER" \
  CPP="$C_COMPILER -E" \
  CXX="$CXX_COMPILER " \
  OBJC="$C_COMPILER" \
  LD=$LD_Complier

make
sudo make install

cd ..



#  install(
#     TARGETS ${name}
#     RUNTIME DESTINATION ${BINARY_INSTALL_DIR}
#     LIBRARY DESTINATION ${LIBRARY_INSTALL_DIR}
#     ARCHIVE DESTINATION ${LIBRARY_INSTALL_DIR}
#     BUNDLE DESTINATION ${BINARY_INSTALL_DIR}
#   )