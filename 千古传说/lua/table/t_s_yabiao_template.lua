local mapArray = MEMapArray:new()
mapArray:push({ quality = 1, quality1_rate = 0, quality2_rate = 100, quality3_rate = 0, quality4_rate = 0, quality5_rate = 0, reward_coin = 10000, duration = 30})
mapArray:push({ quality = 2, quality1_rate = 0, quality2_rate = 50, quality3_rate = 40, quality4_rate = 10, quality5_rate = 0, reward_coin = 20000, duration = 30})
mapArray:push({ quality = 3, quality1_rate = 0, quality2_rate = 0, quality3_rate = 60, quality4_rate = 35, quality5_rate = 5, reward_coin = 60000, duration = 30})
mapArray:push({ quality = 4, quality1_rate = 0, quality2_rate = 0, quality3_rate = 0, quality4_rate = 70, quality5_rate = 30, reward_coin = 120000, duration = 30})
mapArray:push({ quality = 5, quality1_rate = 0, quality2_rate = 0, quality3_rate = 0, quality4_rate = 0, quality5_rate = 100, reward_coin = 200000, duration = 30})
return mapArray
