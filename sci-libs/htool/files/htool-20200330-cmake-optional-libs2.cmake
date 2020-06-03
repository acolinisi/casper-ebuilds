--- a/CMakeLists.txt	2020-04-29 00:30:21.953401754 -0000
+++ b/CMakeLists.txt	2020-04-29 00:31:50.863146842 -0000
@@ -101,27 +101,27 @@
 
 # LAPACK
 if (HTOOL_WITH_LAPACK)
-find_package(LAPACK)
-message("-- Found Lapack:" "${LAPACK_LIBRARIES}")
+	find_package(LAPACK REQUIRED)
+	message("-- Found Lapack:" "${LAPACK_LIBRARIES}")
 endif(HTOOL_WITH_LAPACK)
 
 # ARPACK
 if (HTOOL_WITH_ARPACK)
-if (NOT ARPACK_LIBRARIES)
-find_package(ARPACK)
-endif()
-message("-- Found Arpack:" "${ARPACK_LIBRARIES}")
+	if (NOT ARPACK_LIBRARIES)
+		find_package(ARPACK REQUIRED)
+	endif()
+	message("-- Found Arpack:" "${ARPACK_LIBRARIES}")
 endif (HTOOL_WITH_ARPACK)
 
 # HPDDM
 if (HTOOL_WITH_HPDDM)
-find_package(HPDDM)
+	find_package(HPDDM REQUIRED)
 endif (HTOOL_WITH_HPDDM)
 
 
 if (HTOOL_WITH_GUI)
 	# GLM
-	find_package(GLM)
+	find_package(GLM REQUIRED)
 endif()
 
 if (HTOOL_WITH_PYTHON_INTERFACE)
