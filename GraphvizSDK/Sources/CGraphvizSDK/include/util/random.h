/// @file
/// @brief random number generation

#pragma once

/// hide the symbols this header declares by default
///
/// The expectation is that users of this header (applications, shared
/// libraries, or static libraries) want to call `gv_random` but not re-export
/// it to their users. This annotation is only correct while the containing
/// library is built statically. If it were built as a shared library,
/// `gv_random` would need to have `default` visibility (and thus be unavoidably
/// re-exported) in order to be callable.
#ifndef UTIL_API
#if !defined(__CYGWIN__) && defined(__GNUC__) && !defined(__MINGW32__)
#define UTIL_API __attribute__((visibility("hidden")))
#else
#define UTIL_API /* nothing */
#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

/// generate a random permutation of the numbers `[0, bound - 1]`
///
/// The caller is responsible for `free`ing the returned array. This function
/// calls `exit` on memory allocation failure.
///
/// @param bound Exclusive upper bound on the sequence
/// @return A permutation of `[0, bound - 1]`
UTIL_API int *gv_permutation(int bound);

/// generate a random number in the range `[0, bound - 1]`
///
/// This function assumes the caller has previously seeded the `rand` random
/// number generator.
///
/// @param bound Exclusive upper bound on random number generation
/// @return A random number drawn from a uniform distribution
UTIL_API int gv_random(int bound);

#ifdef __cplusplus
}
#endif
