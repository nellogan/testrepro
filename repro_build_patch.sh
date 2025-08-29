#!/bin/bash

## react-native patch

# Force appmodules.so to omit unnecessary data that can interfere with reproducibility when linking
CMAKE_FILE="node_modules/react-native/ReactAndroid/cmake-utils/default-app-setup/CMakeLists.txt"
echo "set_target_properties(appmodules PROPERTIES LINK_FLAGS \"-Wl,--build-id=none -Wl,--sort-common -Wl,--sort-section=name -Wl,--no-undefined-version -Wl,--no-rosegment -Wl,--strip-all\")" >> $CMAKE_FILE

# Set compiler to use -g0 to omit debug data which can interfere with reproducibility
CMAKE_FILE="node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake"
sed -i '/add_library(${CMAKE_PROJECT_NAME} SHARED ${input_SRC})/a target_compile_options(${CMAKE_PROJECT_NAME} PRIVATE -g0)' $CMAKE_FILE

# Force linked third party libraries to omit unnecessary data when linking
sed -i '/if(EXISTS ${PROJECT_BUILD_DIR}\/generated\/autolinking\/src\/main\/jni\/Android-autolinking.cmake)/,/endif()/c\
if(EXISTS ${PROJECT_BUILD_DIR}/generated/autolinking/src/main/jni/Android-autolinking.cmake)\
    include(${PROJECT_BUILD_DIR}/generated/autolinking/src/main/jni/Android-autolinking.cmake)\
    target_link_libraries(${CMAKE_PROJECT_NAME} ${AUTOLINKED_LIBRARIES})\
    foreach(autolinked_library ${AUTOLINKED_LIBRARIES})\
        target_link_options(${autolinked_library} PRIVATE -Wl,--build-id=none -Wl,--sort-common -Wl,--sort-section=name -Wl,--no-undefined-version -Wl,--no-rosegment -Wl,--strip-all)\
        target_link_libraries(${autolinked_library} common_flags)\
    endforeach()\
endif()' $CMAKE_FILE

# Force codegen files to be compiled with -g0 and omit unnecessary data when linking
sed -i '/if(EXISTS ${PROJECT_BUILD_DIR}\/generated\/source\/codegen\/jni\/CMakeLists.txt)/,/endif()/c\
if(EXISTS ${PROJECT_BUILD_DIR}/generated/source/codegen/jni/CMakeLists.txt)\
    add_subdirectory(${PROJECT_BUILD_DIR}/generated/source/codegen/jni/ codegen_app_build)\
    get_property(APP_CODEGEN_TARGET DIRECTORY ${PROJECT_BUILD_DIR}/generated/source/codegen/jni/ PROPERTY BUILDSYSTEM_TARGETS)\
    target_link_libraries(${CMAKE_PROJECT_NAME} ${APP_CODEGEN_TARGET})\
    foreach(codegen_target ${APP_CODEGEN_TARGET})\
        target_compile_options(${codegen_target} PRIVATE -g0)\
        target_link_options(${codegen_target} PRIVATE -Wl,--build-id=none -Wl,--sort-common -Wl,--sort-section=name -Wl,--no-undefined-version -Wl,--no-rosegment -Wl,--strip-all)\
        target_link_libraries(${codegen_target} common_flags)\
    endforeach()\
    string(REGEX REPLACE "react_codegen_" "" APP_CODEGEN_HEADER "${APP_CODEGEN_TARGET}")\
    target_compile_options(${CMAKE_PROJECT_NAME}\
            PRIVATE\
            -DREACT_NATIVE_APP_CODEGEN_HEADER="${APP_CODEGEN_HEADER}.h"\
            -DREACT_NATIVE_APP_COMPONENT_DESCRIPTORS_HEADER="react/renderer/components/${APP_CODEGEN_HEADER}/ComponentDescriptors.h"\
            -DREACT_NATIVE_APP_COMPONENT_REGISTRATION=${APP_CODEGEN_HEADER}_registerComponentDescriptorsFromCodegen\
            -DREACT_NATIVE_APP_MODULE_PROVIDER=${APP_CODEGEN_HEADER}_ModuleProvider\
    )\
endif()' $CMAKE_FILE


## react-native-screens patch, does not pass or respect all settings from node_modules/react-native/ReactAndroid/cmake-utils/ReactNative-application.cmake

# Set linker options for the main react-native-screens CMakeLists.txt file
CMAKE_FILE="node_modules/react-native-screens/android/CMakeLists.txt"
echo "set_target_properties(rnscreens PROPERTIES LINK_FLAGS \"-Wl,--build-id=none -Wl,--sort-common -Wl,--sort-section=name -Wl,--no-rosegment -Wl,--strip-all\")" >> $CMAKE_FILE

# Get the absolute project root path for prefix mapping
PROJECT_ROOT=$(pwd)
CMAKE_FILE="node_modules/react-native-screens/android/src/main/jni/CMakeLists.txt"

# By default react-native-screens codegen files embed file paths which is problematic for reproducible builds so instead add flags to standardize these paths
sed -i '/cmake_minimum_required(VERSION 3.13)/a \
set(CMAKE_EXPORT_COMPILE_COMMANDS ON) \
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ffile-prefix-map='"$PROJECT_ROOT"'=/project -fmacro-prefix-map='"$PROJECT_ROOT"'=/project") \
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffile-prefix-map='"$PROJECT_ROOT"'=/project -fmacro-prefix-map='"$PROJECT_ROOT"'=/project")' "$CMAKE_FILE"
