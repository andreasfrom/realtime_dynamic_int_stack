{-# LANGUAGE TemplateHaskell #-}

module Main where

import           Control.Applicative
import           Control.Monad           (forM, forM_, void)
import           CStack
import           Foreign                 hiding (void)
import           Foreign.C.Types
import           System.IO.Unsafe        (unsafePerformIO)
import           Test.QuickCheck
import           Test.QuickCheck.All     ()
import           Test.QuickCheck.Monadic

newtype StackPtr = StackPtr (Ptr Stack)

instance Show StackPtr where
  show (StackPtr s) = show $ stackToList s

data StackWithIdx = StackWithIdx (Ptr Stack) CSize CSize deriving Show

instance Arbitrary CInt where
  arbitrary = choose (minBound, maxBound)

instance Arbitrary StackPtr where
  arbitrary = StackPtr <$> unsafePerformIO <$> listToStack' <$> arbitrary

instance Arbitrary StackWithIdx where
  arbitrary = sized $ \n -> do
    k <- choose (1, n `max` 1)
    list <- vector k
    let stack = listToStack list
    idx <- choose (0, k-1)
    return $ StackWithIdx stack (fromIntegral idx) (fromIntegral k)

stackToList :: Ptr Stack -> [CInt]
stackToList = unsafePerformIO . stackToList'

listToStack :: [CInt] -> Ptr Stack
listToStack = unsafePerformIO . listToStack'

stackToList' :: Ptr Stack -> IO [CInt]
stackToList' s = do
  sz <- c_stack_size s
  if sz == 0 then return [] else
    forM [0..sz-1] (c_stack_get s)

listToStack' :: [CInt] -> IO (Ptr Stack)
listToStack' xs = do
  s <- c_stack_alloc
  forM_ xs (c_stack_push s)
  return s

prop_to_from_list :: [CInt] -> Property
prop_to_from_list xs = monadicIO $ do
  s <- run $ listToStack' xs
  xs' <- run $ stackToList' s
  run $ c_stack_free s
  assert (xs == xs')

prop_set_get :: StackWithIdx -> CInt -> Property
prop_set_get (StackWithIdx s ix _) x = monadicIO $ do
  run $ c_stack_set s ix x
  y <- run $ c_stack_get s ix
  run $ c_stack_free s
  assert (x == y)

prop_set_push_get :: StackWithIdx -> CInt -> [CInt] -> Property
prop_set_push_get (StackWithIdx s ix _) x xs = monadicIO $ do
  run $ c_stack_set s ix x
  run $ forM_ xs (c_stack_push s)
  y <- run $ c_stack_get s ix
  run $ c_stack_free s
  assert (x == y)

prop_set_push_pop_get :: StackWithIdx -> CInt -> [CInt] -> Property
prop_set_push_pop_get (StackWithIdx s ix _) x xs = monadicIO $ do
  run $ c_stack_set s ix x
  run $ forM_ xs (c_stack_push s)
  run $ forM_ xs (\_ -> c_stack_pop s)
  y <- run $ c_stack_get s ix
  run $ c_stack_free s
  assert (x == y)

prop_set_pop_get :: StackWithIdx -> CInt -> Property
prop_set_pop_get (StackWithIdx s ix l) x = monadicIO $ do
  run $ c_stack_set s ix x
  -- Pop off everything except y
  run $ forM_ [1..l - ix - 1] (\_ -> c_stack_pop s)
  y <- run $ c_stack_pop s
  run $ c_stack_free s
  assert (x == y)

prop_push_pop :: StackPtr -> CInt -> Property
prop_push_pop (StackPtr s) x = monadicIO $ do
  run $ c_stack_push s x
  y <- run $ c_stack_pop s
  run $ c_stack_free s
  assert (x == y)

prop_push_preserves_input :: [CInt] -> Property
prop_push_preserves_input xs = monadicIO $ do
  s <- run c_stack_alloc
  forM_ xs (run . c_stack_push s)
  xs' <- run $ stackToList' s
  run $ c_stack_free s
  assert (xs == xs')

prop_fifo_stack :: [CInt] -> Property
prop_fifo_stack xs = monadicIO $ do
  s <- run c_stack_alloc
  run $ forM_ xs (c_stack_push s)
  xs' <- run $ forM xs (\_ -> c_stack_pop s)
  run $ c_stack_free s
  assert (xs == reverse xs')

prop_degenerate_to_array :: StackPtr -> Property
prop_degenerate_to_array (StackPtr s) = monadicIO $ do
  sz <- run malloc
  xs <- run $ stackToList' s
  int_ptr <- run $ c_stack_degenerate_to_array s sz
  sz' <- run $ peek sz
  xs' <- run $ peekArray (fromIntegral sz') int_ptr
  run $ free sz
  run $ free int_ptr
  assert (xs == xs')

return []
runTests :: IO Bool
runTests = $quickCheckAll

runDeepTests :: IO Bool
runDeepTests = $forAllProperties $ quickCheckWithResult
               (stdArgs { maxSuccess = 1000, maxSize = 1000})
main :: IO ()
main = void runDeepTests
