using BinaryBuilder

name = "LMDB"
version = v"0.9.27"

# No sources, we're just building the testsuite
sources = [
    ArchiveSource("https://git.openldap.org/openldap/openldap/-/archive/LMDB_$(version)/openldap-LMDB_$(version).tar.gz",
                  "752a3ebd4bbfa1830dff2ca4f5ff4c4be97da843810626d5dd9e2e4e5484a399"),
]

# Bash recipe for building across all platforms
# - CC: mdb_env_close0 segfaults on MacOS because CC is set to gcc in Makefile
# - rm: remove man files (it does not make sense)
# - exeext: Makefile does not support extensions - need to rename execuables manually
script = raw"""
cd ${WORKSPACE}/srcdir/openldap-*/libraries/liblmdb
make CC=${CC} SOEXT=.${dlext} -j${nproc}
make CC=${CC} SOEXT=.${dlext} ILIBS=liblmdb.${dlext} prefix=${prefix} install
rm -rf ${prefix}/share
if [ -n "${exeext}" ]; then
    for f in ${bindir}/mdb_*; do
        mv "${f}" "${f}${exeext}"
    done
fi
install_license ${WORKSPACE}/srcdir/openldap-*/libraries/liblmdb/LICENSE
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms()

# The products that we will ensure are always built
products = [
    ExecutableProduct("mdb_copy", :mdb_copy),
    ExecutableProduct("mdb_dump", :mdb_dump),
    ExecutableProduct("mdb_load", :mdb_load),
    ExecutableProduct("mdb_stat", :mdb_stat),
    LibraryProduct("liblmdb", :liblmdb),
]

# Dependencies that must be installed before this package can be built
dependencies = [
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
