import CrawlerDB
import CrawlerHTTP
import CrawlerParser
import System.Environment
import System.IO
import Debug.Trace


main = do args <- getArgs
          case args of
             ["create"] -> createDB	
             ["saved"] -> printURLs		
             ["savedAt", timeFrom, timeTo] -> printQueryAt timeFrom timeTo
             ["crawl", query] ->
             	do 
             	
             	   --build url
             	   let url = "http://news.google.com/news?pz=1&cf=all&ned=uk&hl=en&q=" ++ query ++ "&output=rss"
             	   
             	   print ("downloading from url: " ++ url)
             	   
             	   --download the rss feed from url
             	   newsRSS <- downloadURL url
             	   
             	   --parse the feed
             	   let links = parseLinks newsRSS
             	   let titles = parseTitles newsRSS
             	   
             	   -- first two lines are redundtant
             	   storeLinksMany query (drop 2 links) (drop 2 titles)
             	 
             _ -> syntaxError

syntaxError = putStrLn 
  "Usage: Crawler command [args]\n\
  \\n\
  \create           Create database all table for urls.db\n\
  \saved            List all queries made from database\n\
  \savedAt timeFrom timeTo     List queries made from database that were made between timestamps, timestamp format YYYY-MM-DD HH:MM:SS\n\
  \crawl url        Gather urls and store in database with time stamp of the made query\n"
