module CrawlerDB where

import CrawlerHTTP
import Database.HDBC
import Database.HDBC.Sqlite3
import Control.Exception
import Debug.Trace
import Data.Time (formatTime, getCurrentTime, UTCTime)
import System.Locale (defaultTimeLocale)
import Control.Monad.Trans (MonadIO, liftIO)
    
createDB :: IO ()
createDB = do conn <- connectSqlite3 "urls.db"
              result <- try (run conn "CREATE TABLE urls (url TEXT)" [])  :: IO (Either SqlError Integer)
              case result of
              	Left ex  -> putStrLn $ "Caught exception on creating url table: " ++ show ex
              	Right val -> putStrLn $ "The answer for creating url table was: " ++ show val
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

storeURLs :: [URL] -> IO ()
storeURLs [] = return ()
storeURLs xs =
     do conn <- connectSqlite3 "urls.db"
        stmt <- prepare conn "INSERT INTO urls (url) VALUES (?)"
        executeMany stmt (map (\x -> [toSql x]) xs)
        commit conn        

storeLinksMany :: String ->[String] ->[String]-> IO ()
storeLinksMany _ [] [] = return ()
storeLinksMany x y z = do 
					 storeLinks  x (head y) (head z)
					 storeLinksMany x (tail y) (tail z)

storeLinks :: String ->String ->String-> IO ()
storeLinks xs ys zs =  
     do conn <- connectSqlite3 "urls.db"
        stmt <- prepare conn "INSERT INTO linksTitles (query, links, titles) VALUES (?, ?, ?)" 
        execute stmt [(toSql xs), (toSql ys), (toSql zs)]
        stmt1 <- prepare conn "INSERT INTO dateQuery (query, timeStamp) VALUES (?, ?)"
        t <- liftIO getCurrentTime
        execute stmt1 [(toSql xs), (toSql t)]
       	--run conn "DROP TABLE IF EXISTS linksTitles" []
       	--run conn "DROP TABLE IF EXISTS urls" []
       	--run conn "DROP TABLE IF EXISTS dateQuery" []
        commit conn 
        

printURLs :: IO ()
printURLs = do urls <- getURLs
               mapM_ print urls

printQueryAt :: String -> String -> IO ()
printQueryAt timeFrom timeTo = do 
				 urls1 <- getURLsAt timeFrom timeTo
				 mapM_ print urls1

getURLsAt :: String -> String-> IO [URL]
getURLsAt timeFrom timeTo= do 
				conn <- connectSqlite3 "urls.db"
				res <- quickQuery' conn "SELECT id FROM dateQuery WHERE  timeStamp>? and timeStamp<?" [(toSql timeFrom), (toSql timeTo)]
				selectMany res
				return $ map fromSql (map head res)        

selectMany :: [[SqlValue]] ->IO()
selectMany [] = return ()
selectMany x = do 
					 selectSingle  (head x)
					 selectMany (tail x) 

selectSingle :: [SqlValue] ->IO()
selectSingle [] = return ()
selectSingle x =  do 
		conn <- connectSqlite3 "urls.db"
		stmt <- prepare conn "SELECT query, titles, links FROM linksTitles WHERE  id_parent=?" 
		execute stmt x
		results <- fetchAllRowsAL stmt
		mapM_ print results
        
        
getURLs :: IO [URL]
getURLs = do conn <- connectSqlite3 "urls.db"
             res <- quickQuery' conn "SELECT * FROM linksTitles" []
             mapM_ print (res)
             return $ map fromSql (map head res)

getURLsWhere ::String -> IO [URL]
getURLsWhere urll =
     do conn <- connectSqlite3 "urls.db"
        res1 <- quickQuery' conn "SELECT * FROM urls" []
        return $ map fromSql (map head res1)

unfoldDB :: IO ()
unfoldDB = do urls <- getURLs
              process urls

unfoldDBUrl :: String -> String
unfoldDBUrl url = url

process :: [URL] -> IO ()
process [] = return ()
process (x:xs) = do print $ "Processing : " ++ x
                    urlContent <- downloadURL x
                    storeURLs (parseURLs urlContent)
                    process xs
