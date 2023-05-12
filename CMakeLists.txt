cmake_minimum_required(VERSION 3.13)

project(gdbm_parser)

find_package (Threads)

add_definitions(-fpermissive)

add_executable(gdbm_parser main.cpp)

target_link_libraries(gdbm_parser libdb_cxx-5.3.a Threads::Threads)