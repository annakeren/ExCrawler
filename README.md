ExCrawler
=========
--This piece of software offers a user to search news articles from news.google.com.
--The queries that are made by the user are saved in form of title of an article, its links and time of a query performed.
--Later all the titles and links can be listed or titles and links of queries that are saved in certain period of time.
--Information is retrieved using rss api from news.google.com.
--Current version of this program treats space as a valid delemeter only. So, in order to make query that consists of more than one word, use space.
--Usage examples:
--["create"]
--["crawl", "queen mary"]
--["saved"]
--["savedAt", "2014-12-25 19:54:01", "2014-12-25 23:00:01"]

Crawling application in haskell
