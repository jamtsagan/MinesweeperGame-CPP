#ifndef DLL_EXPORT_H
#define DLL_EXPORT_H

#if defined(_WIN32) || defined(__CYGWIN__)
  #ifdef MINESWEEPERCORE_EXPORTS // 这个宏只在编译库本身时被定义
    #define API __declspec(dllexport)
  #else
    #define API __declspec(dllimport)
  #endif
#else
  #define API // 在非 Windows 系统上，这个宏什么都不做
#endif

#endif //DLL_EXPORT_H
