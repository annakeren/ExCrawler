module CrawlerHelper where

import System.Locale (defaultTimeLocale)
import Data.Time (UTCTime)
import Data.Time.Format (readTime)

--replaces space with %20
uriEscapeSpaces :: String -> String
uriEscapeSpaces uri = substitute uri " " "%20"


substitute :: String -> String -> String  -> String
substitute [] _ _ = []
substitute (uriHead:uriTail) escape substitution = (substituteSingle (charToString uriHead) escape substitution)++(substitute uriTail escape substitution)

substituteSingle :: String -> String -> String  -> String
substituteSingle x escape substitution
										| x==escape = substitution
										|otherwise = x
	
	
charToString :: Char -> String
charToString c = [c]				


--timestamp validation function
readHMS :: String -> UTCTime
readHMS = readTime defaultTimeLocale "%Y-%M-%d %H:%M:%S"