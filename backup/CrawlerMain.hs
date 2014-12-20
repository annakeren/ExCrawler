import CrawlerDB
import CrawlerHTTP
import System.Environment

main = do args <- getArgs
          case args of
             ["create"] -> createDB	
             ["saved"] -> printURLs	
             ["unfold"] -> unfoldDB
             ["show", url] ->
             	do urlText <- downloadURL url
             	   print urlText
             ["crawl", url] ->
             	do urlText <- downloadURL url
             	   let urls = parseURLs urlText
             	   storeURLs urls
             _ -> syntaxError

syntaxError = putStrLn 
  "Usage: Crawler command [args]\n\
  \\n\
  \create           Create database urls.db\n\
  \show url         Shows contents of given URL\n\
  \unfoldUrl url    Crawl saved given URL\n\
  \saved            List urls on database\n\
  \crawl url        Gather urls and store in database\n\
  \unfold           Crawl each of the saved URLs\n"
