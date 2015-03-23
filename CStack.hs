module CStack where

import           Foreign
import           Foreign.C.Types

data Stack

foreign import ccall unsafe "realtime_dynamic_int_stack.h stack_alloc"
  c_stack_alloc :: IO (Ptr Stack)

foreign import ccall unsafe "realtime_dynamic_int_stack.h stack_free"
  c_stack_free :: Ptr Stack -> IO ()

foreign import ccall unsafe "realtime_dynamic_int_stack.h stack_push"
  c_stack_push :: Ptr Stack -> CInt -> IO ()

foreign import ccall unsafe "realtime_dynamic_int_stack.h stack_pop"
  c_stack_pop :: Ptr Stack -> IO CInt

foreign import ccall unsafe "realtime_dynamic_int_stack.h stack_set"
  c_stack_set :: Ptr Stack -> CSize -> CInt -> IO ()

foreign import ccall unsafe "realtime_dynamic_int_stack.h stack_get"
  c_stack_get :: Ptr Stack -> CSize -> IO CInt

foreign import ccall unsafe "realtime_dynamic_int_stack.h stack_is_empty"
  c_stack_is_empty :: Ptr Stack -> IO Bool

foreign import ccall unsafe "realtime_dynamic_int_stack.h stack_size"
  c_stack_size :: Ptr Stack -> IO CSize

foreign import ccall unsafe "realtime_dynamic_int_stack.h stack_capacity"
  c_stack_capacity :: Ptr Stack -> IO CSize

foreign import ccall unsafe "realtime_dynamic_int_stack.h stack_degenerate_to_array"
  c_stack_degenerate_to_array :: Ptr Stack -> Ptr CSize -> IO (Ptr CInt)
