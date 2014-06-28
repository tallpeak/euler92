import Data.Char
import Data.List

ssd :: Int -> Int
ssd = sum . map square . digits . show where
	square x = x*x
	digits = map digitToInt

termination x = if x `elem` [1,89] then x else termination (ssd x)

countT89 = length . filter (==89) . map termination $ [1..10000000]

main = print countT89 
	