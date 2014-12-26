import CrawlerDB
import CrawlerHTTP
import CrawlerParser
import CrawlerHelper
import System.Environment
import System.IO
import Debug.Trace

--This piece of software offers a user to search news articles from news.google.com.
--The queries that are made by the user are saved in form of title of an article, its links and time of a query performed.
--Later all the titles and links can be listed or only alternatively only titles and links of queries that are saved in certain period of time.
--Information is retrieved using rss api from news.google.com.
--Current version of this program treats space as a valid delemeter only. So, in order to make query that consists of more than one word, use space.
--Usage examples:
--["create"]
--["crawl", "queen mary"]
--["saved"]
--["savedAt", "2014-12-25 19:54:01", "2014-12-25 23:00:01"]
main = do args <- getArgs
          case args of
             ["create"] -> createDB	
             ["saved"] -> printURLs		
             ["savedAt", timeFrom, timeTo] -> do
             		--validate input timestamps before making query in db
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
             	   
             	   --first two links and titles contain query performed, so drop them, save other results
             	   storeLinksMany query (drop 2 links) (drop 2 titles)
             	 
             _ -> syntaxError

syntaxError = putStrLn 
  "Usage: Crawler command [args]\n\
  \\n\
  \create           Create all tables in database urls.db\n\
  \saved            List all queries made from database\n\
  \savedAt timeFrom timeTo     List queries saved from database that were made between two timestamps, timestamp format YYYY-MM-DD HH:MM:SS\n\
  \crawl url        Gather urls and store in database with time stamp of each query made\n"
