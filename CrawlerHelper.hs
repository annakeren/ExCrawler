module CrawlerHelper where


--Story contains title + link
data Story = Story String String deriving (Show)  


createStory :: [String] -> [String] -> [Story]
createStory [] [] = []
--createStory [x] [y] = Story (head x) (head y)