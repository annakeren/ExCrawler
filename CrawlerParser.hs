module CrawlerParser where

import Network.HTTP
import Network.URI
import Data.Maybe

parseNewsRSS :: String -> [String]
parseNewsRSS s = parseTitles s ++ parseLinks s

parseLinks :: String -> [String]
parseLinks [] = []
parseLinks ('<':'l':'i':'n':'k':'>':xs) = ("" ++ text) : (parseLinks rest)
    where (text, rest) = break space xs
          space c = elem c ['<']
parseLinks (_:xs) = parseLinks xs

parseTitles :: String -> [String]
parseTitles [] = []
parseTitles ('<':'t':'i':'t':'l':'e':'>':xs) = ("" ++ text) : (parseTitles rest)
    where (text, rest) = break space xs
          space c = elem c ['<']
parseTitles (_:xs) = parseTitles xs
