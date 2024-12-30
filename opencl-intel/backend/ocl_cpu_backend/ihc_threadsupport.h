// Copyright (C) 2022 Intel Corporation
//
// This software and the related documents are Intel copyrighted materials, and
// your use of them is governed by the express license under which they were
// provided to you ("License"). Unless the License provides otherwise, you may
// not use, modify, copy, publish, distribute, disclose or transmit this
// software or the related documents without Intel's prior written permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

/* Wrapper library to keep mutexes out of kernel code */

LLVM_BACKEND_API void *_ihc_mutex_create();
LLVM_BACKEND_API int _ihc_mutex_delete(void *);
LLVM_BACKEND_API int _ihc_mutex_lock(void *);
LLVM_BACKEND_API int _ihc_mutex_unlock(void *);

LLVM_BACKEND_API void *_ihc_cond_create();
LLVM_BACKEND_API int _ihc_cond_delete(void *cv);
LLVM_BACKEND_API int _ihc_cond_notify_one(void *);
LLVM_BACKEND_API int _ihc_cond_wait(void *, void *);

LLVM_BACKEND_API void *_ihc_pthread_create(void *(*func)(void *), void *arg);
LLVM_BACKEND_API int _ihc_pthread_join(void *handle);
LLVM_BACKEND_API int _ihc_pthread_detach(void *handle);

#ifdef _WIN32
LLVM_BACKEND_API void *_Znwy(unsigned long long);
LLVM_BACKEND_API void _ZdlPvy(void *, unsigned long long);
LLVM_BACKEND_API void _ZSt14_Xlength_errorPKc(char const *);
LLVM_BACKEND_API void _ZdlPv(void *);
#endif
