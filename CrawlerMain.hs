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
             ["savedAt", time] -> printQueryAt time
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
             	   
             	   storeLinksMany query (drop 2 links) (drop 2 titles)
             	   
             	   --print (drop 2 links)-- the first two links are redundant
             	   --print (drop 2 titles)-- the first two titles are redundant
             	   --storeURLs urls
             _ -> syntaxError

syntaxError = putStrLn 
  "Usage: Crawler command [args]\n\
  \\n\
  \create           Create database all table for urls.db\n\
  \saved            List urls on database\n\
  \savedAt time     List urls on database according to time\n\
  \crawl url        Gather urls and store in database with time stamp of the made query\n"
