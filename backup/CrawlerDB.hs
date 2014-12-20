module CrawlerDB where

import CrawlerHTTP
import Database.HDBC
import Database.HDBC.Sqlite3

createDB :: IO ()
createDB = do conn <- connectSqlite3 "urls.db"
              run conn "CREATE TABLE urls (url TEXT)" []
              commit conn

storeURLs :: [URL] -> IO ()
storeURLs [] = return ()
storeURLs xs =
     do conn <- connectSqlite3 "urls.db"
        stmt <- prepare conn "INSERT INTO urls (url) VALUES (?)"
        executeMany stmt (map (\x -> [toSql x]) xs)
        commit conn        

printURLs :: IO ()
printURLs = do urls <- getURLs
               mapM_ print urls

getURLs :: IO [URL]
getURLs = do conn <- connectSqlite3 "urls.db"
             res <- quickQuery' conn "SELECT url FROM urls" []
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
