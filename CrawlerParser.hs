module CrawlerParser where

import Network.HTTP
import Network.URI
import Data.Maybe

parseNewsRSS :: String -> [String]
parseNewsRSS s = parseTitles s ++ parseLinks s

--Parses titles of the news
parseLinks :: String -> [String]
parseLinks [] = []
parseLinks ('<':'l':'i':'n':'k':'>':xs) = ("" ++ text) : (parseLinks rest)
    where (text, rest) = break space xs
          space c = elem c ['<']
parseLinks (_:xs) = parseLinks xs

--Parses links of the news
parseTitles :: String -> [String]
parseTitles [] = []
parseTitles ('<':'t':'i':'t':'l':'e':'>':xs) = ("" ++ text) : (parseTitles rest)
    where (text, rest) = break space xs
          space c = elem c ['<']
parseTitles (_:xs) = parseTitles xs
