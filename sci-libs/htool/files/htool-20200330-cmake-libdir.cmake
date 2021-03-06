--- a/CMakeLists.txt	2020-04-29 00:01:50.396561532 -0000
+++ b/CMakeLists.txt	2020-04-29 00:02:24.099601986 -0000
@@ -261,12 +261,12 @@
 install(EXPORT ${PROJECT_NAME}Targets
         FILE ${PROJECT_NAME}Targets.cmake
         NAMESPACE ${PROJECT_NAME}::
-		DESTINATION lib/cmake/${PROJECT_NAME})
+	DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})
 
 
 install(FILES "${PROJECT_BINARY_DIR}/${PROJECT_NAME}ConfigVersion.cmake"
 				"${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake"
-		DESTINATION lib/cmake/${PROJECT_NAME})
+	DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})
 
 ###### install files
 install(DIRECTORY ${PROJECT_SOURCE_DIR}/include/ DESTINATION include)
