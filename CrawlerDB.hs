module CrawlerDB where

import CrawlerHTTP
import Database.HDBC
import Database.HDBC.Sqlite3
import Control.Exception
import Debug.Trace


    
createDB :: IO ()
createDB = do conn <- connectSqlite3 "urls.db"
              result <- try (run conn "CREATE TABLE urls (url TEXT)" [])  :: IO (Either SqlError Integer)
              case result of
              	Left ex  -> putStrLn $ "Caught exception: " ++ show ex
              	Right val -> putStrLn $ "The answer was: " ++ show val
              result <- try (run conn "CREATE TABLE linksTitles (links TEXT, titles TEXT)" []):: IO (Either SqlError Integer)
              case result of
              	Left ex  -> putStrLn $ "Caught exception: " ++ show ex
              	Right val -> putStrLn $ "The answer was: " ++ show val
              commit conn

storeURLs :: [URL] -> IO ()
storeURLs [] = return ()
storeURLs xs =
     do conn <- connectSqlite3 "urls.db"
        stmt <- prepare conn "INSERT INTO urls (url) VALUES (?)"
        executeMany stmt (map (\x -> [toSql x]) xs)
        commit conn        

storeLinksMany :: [String] ->[String]-> IO ()
storeLinksMany [] [] = return ()
storeLinksMany x y = do 
					 storeLinks  (head x) (head y) 
					 storeLinksMany (tail x) (tail y)

storeLinks :: String ->String-> IO ()
storeLinks xs ys =  --(print (ys))
     do conn <- connectSqlite3 "urls.db"
        stmt <- prepare conn "INSERT INTO linksTitles (links, titles) VALUES (?, ?)" 
        execute stmt [(toSql xs), (toSql ys)]
       	--run conn "DROP TABLE IF EXISTS linksTitles" []
        commit conn 
        
printURLs :: IO ()
printURLs = do urls <- getURLs
               mapM_ print urls

getURLs :: IO [URL]
getURLs = do conn <- connectSqlite3 "urls.db"
             res <- quickQuery' conn "SELECT titles FROM linksTitles" []
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
