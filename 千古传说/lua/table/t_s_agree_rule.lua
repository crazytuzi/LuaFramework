local mapArray = MEMapArray:new()
mapArray:push({ level = 1, consume = "1_30053_10", value = 100})
mapArray:push({ level = 2, consume = "1_30053_50", value = 200})
mapArray:push({ level = 3, consume = "1_30053_100", value = 300})
mapArray:push({ level = 4, consume = "1_30053_150|1_30054_50", value = 400})
mapArray:push({ level = 5, consume = "1_30053_200|1_30054_100", value = 500})
return mapArray
