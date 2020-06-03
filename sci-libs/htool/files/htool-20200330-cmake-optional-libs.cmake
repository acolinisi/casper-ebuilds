--- a/CMakeLists.txt	2020-04-28 23:35:08.481110091 -0000
+++ b/CMakeLists.txt	2020-04-28 23:53:25.686980551 -0000
@@ -45,7 +45,7 @@
 	set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
 
 	# Let's nicely support folders in IDE's
-	set_property(GLOBAL PROPERTY USE_FOLDERS ON)
+	set_property(GLOBAL PROPERTY HTOOL_WITH_FOLDERS ON)
 	
 	# Testing only available if this is the main app
     # Note this needs to be done in the main CMakeLists
@@ -68,6 +68,9 @@
 option(HTOOL_WITH_EXAMPLES             "Build htool examples ?" ON)
 option(HTOOL_WITH_GUI                  "Build htool visualization tools ?" OFF)
 option(HTOOL_WITH_PYTHON_INTERFACE     "Build htool visualization tools ?" OFF)
+option(HTOOL_WITH_LAPACK               "Link to LAPACK in installed cmake modules for htool?" OFF)
+option(HTOOL_WITH_ARPACK               "Link to ARPACK in installed cmake modules for htool?" OFF)
+option(HTOOL_WITH_HPDDM                "Include HPDDM in installed cmake modules for htool?" OFF)
 
 
 
@@ -97,15 +100,23 @@
 message("-- Found Blas implementation:" "${BLAS_LIBRARIES}")
 
 # LAPACK
+if (HTOOL_WITH_LAPACK)
 find_package(LAPACK)
 message("-- Found Lapack:" "${LAPACK_LIBRARIES}")
+endif(HTOOL_WITH_LAPACK)
 
 # ARPACK
+if (HTOOL_WITH_ARPACK)
+if (NOT ARPACK_LIBRARIES)
 find_package(ARPACK)
+endif()
 message("-- Found Arpack:" "${ARPACK_LIBRARIES}")
+endif (HTOOL_WITH_ARPACK)
 
 # HPDDM
+if (HTOOL_WITH_HPDDM)
 find_package(HPDDM)
+endif (HTOOL_WITH_HPDDM)
 
 
 if (HTOOL_WITH_GUI)
