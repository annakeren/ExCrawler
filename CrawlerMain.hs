import CrawlerDB
import CrawlerHTTP
import CrawlerParser
import CrawlerHelper
import System.Environment
import System.IO
import Debug.Trace


main = do args <- getArgs
          case args of
             ["create"] -> createDB	
             ["saved"] -> printURLs		
             ["savedAt", timeFrom, timeTo] -> do
             		print (readHMS timeFrom)
             		print (readHMS timeTo)
             		printQueryAt timeFrom timeTo
             ["crawl", query] ->
             	do 
             	
             	   let escapedQuery = uriEscapeSpaces query
             	   --build url
             	   let url = "http://news.google.com/news?pz=1&cf=all&ned=uk&hl=en&q=" ++ escapedQuery ++ "&output=rss"
             	   
             	   print ("downloading from url: " ++ url)
             	   
             	   --download the rss feed from url
             	   newsRSS <- downloadURL url
             	   
             	   --parse the feed
             	   let links = parseLinks newsRSS
             	   let titles = parseTitles newsRSS
             	   
             	   -- first two lines are redundant
             	   storeLinksMany query (drop 2 links) (drop 2 titles)
             	 
             _ -> syntaxError

syntaxError = putStrLn 
  "Usage: Crawler command [args]\n\
  \\n\
  \create           Create all tables in database urls.db\n\
  \saved            List all queries made from database\n\
  \savedAt timeFrom timeTo     List queries saved from database that were made between two timestamps, timestamp format YYYY-MM-DD HH:MM:SS\n\
  \crawl url        Gather urls and store in database with time stamp of each query made\n"
