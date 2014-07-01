module Main where

-- import System.TimeIt
import System.Microtimer
import System.Process
import System.IO
import System.Environment
import Data.List
import Text.Printf

main :: IO ()
main = do
	args <- getArgs
	let cmdline = intercalate " " args
	(tm,ec) <- time $ system cmdline
	hPutStrLn stderr $ printf "%.3f seconds"  tm
