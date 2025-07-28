#      - name: Patch node_modules/react-native-screens/android/CMakeLists.txt file (reproducible build test, this is correct)
#        run: |
#          echo "set_target_properties(rnscreens PROPERTIES LINK_FLAGS \"-Wl,--build-id=none\")" >> node_modules/react-native-screens/android/CMakeLists.txt
#
#      - name: Patch node_modules/react-native/ReactAndroid/cmake-utils/default-app-setup/CMakeLists.txt file to fix libappmodules.so (reproducible build test, this is correct)
#        run: |
#          echo "set_target_properties(appmodules PROPERTIES LINK_FLAGS \"-Wl,--build-id=none\")" >> node_modules/react-native/ReactAndroid/cmake-utils/default-app-setup/CMakeLists.txt
#
#      - name: Patch node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake file to fix codegen .so files (reproducible build test, this is ?)
#        run: |
#          sed -i '/find_program(CCACHE_FOUND ccache)/,/endif(CCACHE_FOUND)/d' node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake
#          sed -i 's/set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)/set(CMAKE_INTERPROCEDURAL_OPTIMIZATION FALSE)/' node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake
#          sed -i '/add_library(${CMAKE_PROJECT_NAME} SHARED ${input_SRC})/a target_compile_options(${CMAKE_PROJECT_NAME} PRIVATE -g0)' CMakeLists.txt
#          sed -i 's/set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES LINK_FLAGS "-Wl,--build-id=none")/set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES LINK_FLAGS "-Wl,--build-id=none -Wl,--sort-common -Wl,--sort-section=name -s")/' node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake
#          sed -i '/foreach(autolinked_library ${AUTOLINKED_LIBRARIES})/a \            target_compile_options(${autolinked_library} PRIVATE -g0)\n\            target_link_options(${autolinked_library} PRIVATE -Wl,--build-id=none -Wl,--sort-common -Wl,--sort-section=name -s)' node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake
#          sed -i '/foreach(codegen_target ${APP_CODEGEN_TARGET})/a \            target_compile_options(${codegen_target} PRIVATE -g0)\n\            target_link_options(${codegen_target} PRIVATE -Wl,--build-id=none -Wl,--sort-common -Wl,--sort-section=name -s)' node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake
#          sed -i '/target_link_libraries(${APP_CODEGEN_TARGET} common_flags)/a \        foreach(codegen_target ${APP_CODEGEN_TARGET})\n            target_link_options(${codegen_target} PRIVATE -Wl,--build-id=none)\n        endforeach()' node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake
#          sed -i '/if(override_cpp_SRC)/,/endif()/c\
#          if(override_cpp_SRC)\
#              file(GLOB input_SRC CONFIGURE_DEPENDS\
#                   ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp\
#                   ${BUILD_DIR}/generated/autolinking/src/main/jni/*.cpp)\
#              list(SORT input_SRC) # Ensure deterministic order\
#          else()\
#              file(GLOB input_SRC CONFIGURE_DEPENDS\
#                   ${REACT_ANDROID_DIR}/cmake-utils/default-app-setup/*.cpp\
#                   ${BUILD_DIR}/generated/autolinking/src/main/jni/*.cpp)\
#              list(SORT input_SRC) # Ensure deterministic order\
#          endif()' node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake
#          echo 'set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES LINK_FLAGS "-Wl,--build-id=none")' >> node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake


rm -rf node_modules && npm install

echo "set_target_properties(rnscreens PROPERTIES LINK_FLAGS \"-Wl,--build-id=none\")" >> node_modules/react-native-screens/android/CMakeLists.txt

echo "set_target_properties(appmodules PROPERTIES LINK_FLAGS \"-Wl,--build-id=none\")" >> node_modules/react-native/ReactAndroid/cmake-utils/default-app-setup/CMakeLists.txt

sed -i '/find_program(CCACHE_FOUND ccache)/,/endif(CCACHE_FOUND)/d' node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake
sed -i 's/set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)/set(CMAKE_INTERPROCEDURAL_OPTIMIZATION FALSE)/' node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake
sed -i '/if(override_cpp_SRC)/,/endif()/c\
if(override_cpp_SRC)\
    file(GLOB input_SRC CONFIGURE_DEPENDS\
        ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp\
        ${BUILD_DIR}/generated/autolinking/src/main/jni/*.cpp)\
    list(SORT input_SRC) # Ensure deterministic order\
else()\
    file(GLOB input_SRC CONFIGURE_DEPENDS\
        ${REACT_ANDROID_DIR}/cmake-utils/default-app-setup/*.cpp\
        ${BUILD_DIR}/generated/autolinking/src/main/jni/*.cpp)\
    list(SORT input_SRC) # Ensure deterministic order\
endif()' node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake
sed -i '/add_library(${CMAKE_PROJECT_NAME} SHARED ${input_SRC})/a target_compile_options(${CMAKE_PROJECT_NAME} PRIVATE -g0)' node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake
sed -i 's/set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES LINK_FLAGS "-Wl,--build-id=none")/set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES LINK_FLAGS "-Wl,--build-id=none -Wl,--sort-common -Wl,--sort-section=name -s")/' node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake
sed -i '/foreach(autolinked_library ${AUTOLINKED_LIBRARIES})/a \            target_compile_options(${autolinked_library} PRIVATE -g0)\n\            target_link_options(${autolinked_library} PRIVATE -Wl,--build-id=none -Wl,--sort-common -Wl,--sort-section=name -s)' node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake
sed -i '/foreach(codegen_target ${APP_CODEGEN_TARGET})/a \            target_compile_options(${codegen_target} PRIVATE -g0)\n\            target_link_options(${codegen_target} PRIVATE -Wl,--build-id=none -Wl,--sort-common -Wl,--sort-section=name -s)' node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake
sed -i '/target_link_libraries(${APP_CODEGEN_TARGET} common_flags)/a \        foreach(codegen_target ${APP_CODEGEN_TARGET})\n           target_compile_options(${codegen_target} PRIVATE -g0)\n           target_link_options(${codegen_target} PRIVATE -Wl,--build-id=none -Wl,--sort-common -Wl,--sort-section=name -s)\n        endforeach()' node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake
echo 'set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES LINK_FLAGS "-Wl,--build-id=none -Wl,--sort-common -Wl,--sort-section=name -s")' >> node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake



#sed -i '/target_link_libraries(${APP_CODEGEN_TARGET} common_flags)/a \        foreach(codegen_target ${APP_CODEGEN_TARGET})\n           target_link_options(${codegen_target} PRIVATE -Wl,--build-id=none -Wl,--sort-common -Wl,--sort-section=name -s)\n        endforeach()' node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake
