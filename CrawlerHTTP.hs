module CrawlerHTTP where

import Network.HTTP
import Network.URI
import Data.Maybe

type URL = String
type TITLE = String

downloadURL :: String -> IO String
downloadURL url =
    do resp <- simpleHTTP request
       case resp of
         Left x -> return $ "Error connecting: " ++ show x
         Right r -> 
             case rspCode r of
               (2,_,_) -> return $ rspBody r
               _ -> return $ show r
    where request = Request {rqURI = uri, rqMethod = GET, rqHeaders = [], rqBody = ""}
          uri = fromJust $ parseURI url



parseURLs :: String -> [URL]
parseURLs [] = []
parseURLs ('h':'t':'t':'p':':':'/':'/':xs) = ("http://" ++ url) : (parseURLs rest)
    where (url, rest) = break space xs
          space c = elem c [' ','\t','\n','\r','\"','\'',')',';','<']
parseURLs (_:xs) = parseURLs xs
