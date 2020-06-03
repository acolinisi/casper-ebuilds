--- a/CMakeLists.txt	2020-04-28 23:40:50.615671608 -0000
+++ b/CMakeLists.txt.orig	2020-04-28 23:35:08.481110091 -0000
@@ -101,9 +101,7 @@
 message("-- Found Lapack:" "${LAPACK_LIBRARIES}")
 
 # ARPACK
-if (NOT ARPACK_LIBRARIES)
 find_package(ARPACK)
-endif()
 message("-- Found Arpack:" "${ARPACK_LIBRARIES}")
 
 # HPDDM
