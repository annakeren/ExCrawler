module CrawlerDB where

import CrawlerHTTP
import CrawlerHelper
import Database.HDBC
import Database.HDBC.Sqlite3
import Control.Exception
import Debug.Trace
import Data.Time (formatTime, getCurrentTime, UTCTime)
import System.Locale (defaultTimeLocale)
import Control.Monad.Trans (MonadIO, liftIO)
   
--Initialises db by creating its tables, exceptions are handled 
--Table linksTitles: id_parent, query, links, titles
--Table dateQuery: id, query, timestamp, FK(id_parent)
createDB :: IO ()
createDB = do conn <- connectSqlite3 "urls.db"
              result <- try (run conn "CREATE TABLE linksTitles (id_parent INTEGER PRIMARY KEY, query TEXT, links TEXT, titles TEXT)" []):: IO (Either SqlError Integer)
              case result of
              	Left ex  -> putStrLn $ "Caught exception on creating linksTitles table: " ++ show ex
              	Right val -> putStrLn $ "The answer for creating linksTitles table was: " ++ show val
              
              commit conn
              result <- try (run conn "CREATE TABLE dateQuery (id INTEGER PRIMARY KEY, query TEXT, timeStamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY (id) REFERENCES parent(id_parent))" []):: IO (Either SqlError Integer)
              case result of
              	Left ex  -> putStrLn $ "Caught exception on creating dateQuery table: " ++ show ex
              	Right val -> putStrLn $ "The answer for creating dateQuery table was: " ++ show val	
              commit conn

       
--Inserts to db recursively
storeLinksMany :: String ->[String] ->[String]-> IO ()
storeLinksMany _ [] [] = return ()
storeLinksMany query links titles = do 
					 storeLinks  query (head links) (head titles)
					 storeLinksMany query (tail links) (tail titles)
--Perfroms singe insert
storeLinks :: String ->String ->String-> IO ()
storeLinks query links titles =  
     do conn <- connectSqlite3 "urls.db"
        stmt <- prepare conn "INSERT INTO linksTitles (query, links, titles) VALUES (?, ?, ?)" 
        execute stmt [(toSql query), (toSql links), (toSql titles)]
        stmt1 <- prepare conn "INSERT INTO dateQuery (query, timeStamp) VALUES (?, ?)"
        t <- liftIO getCurrentTime
        execute stmt1 [(toSql query), (toSql t)]
        commit conn 
        
--Prints out all queries saved in db
printURLs :: IO ()
printURLs = do urls <- getURLs
               print "These are all the queries made"

--Prints queries saved between two timestamps
printQueryAt :: String -> String -> IO ()
printQueryAt timeFrom timeTo = do 
				 urls1 <- getURLsAt timeFrom timeTo
				 print "These are the queries made between selected period"

--Retrieves queries saved between two timestamps from db
getURLsAt :: String -> String-> IO [URL]
getURLsAt timeFrom timeTo= do 
				conn <- connectSqlite3 "urls.db"
				ids <- quickQuery' conn "SELECT id FROM dateQuery WHERE  timeStamp>? and timeStamp<?" [(toSql timeFrom), (toSql timeTo)]
				selectMany ids
				return $ map fromSql (map head ids)        

--Selects recursively 
selectMany :: [[SqlValue]] ->IO()
selectMany [] = return ()
selectMany ids = do 
					 selectSingle  (head ids)
					 selectMany (tail ids) 

--Performs single select
selectSingle :: [SqlValue] ->IO()
selectSingle [] = return ()
selectSingle id =  do 
		conn <- connectSqlite3 "urls.db"
		stmt <- prepare conn "SELECT query, titles, links FROM linksTitles WHERE  id_parent=?" 
		execute stmt id
		results <- fetchAllRowsAL stmt
		mapM_ print results
        
--Retrieves from db all queries saved from linksTitles table        
getURLs :: IO [URL]
getURLs = do conn <- connectSqlite3 "urls.db"
             res <- quickQuery' conn "SELECT * FROM linksTitles" []
             mapM_ print (res)
             return $ map fromSql (map head res)

