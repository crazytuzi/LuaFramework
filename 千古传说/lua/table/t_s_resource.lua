local mapArray = MEMapArray:new()
mapArray:push({ id = 1, name = "体力", cooldown = 1800, wait_time = 0, init_value = 20, max = 20, cost_type = 4, price = "20,50,50,100,100,100,200,200,200,200,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400", amount = 20, recovery = 1, level_up = 5, max_vip_rule = 2010, buy_vip_rule = 2000, battle_type = 1, reset_wait_cost_type = 0, reset_wait_price = ""})
mapArray:push({ id = 2, name = "群豪谱", cooldown = 0, wait_time = 300, init_value = 5, max = 5, cost_type = 4, price = "50,50,100,100,100,200,200,200,200,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400", amount = 5, recovery = 0, level_up = 0, max_vip_rule = 2011, buy_vip_rule = 2001, battle_type = 3, reset_wait_cost_type = 4, reset_wait_price = "50,50,100,100,100,100,200,200,200,200,200,400"})
mapArray:push({ id = 3, name = "无量山", cooldown = 0, wait_time = 0, init_value = 5, max = 5, cost_type = 4, price = "50,50,100,100,100,200,200,200,200,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400", amount = 5, recovery = 0, level_up = 0, max_vip_rule = 2012, buy_vip_rule = 2002, battle_type = 5, reset_wait_cost_type = 0, reset_wait_price = ""})
mapArray:push({ id = 4, name = "技能点", cooldown = 360, wait_time = 0, init_value = 10, max = 10, cost_type = 4, price = "20,20,50,50,50,100,100,100,200,200,200,200,400,400,400,400,400,400,400,500,500,500,500,500,500,500,500,500,500,500,500,500,500,500,500,500,500,500,500,500", amount = 10, recovery = 1, level_up = 0, max_vip_rule = 2014, buy_vip_rule = 2004, battle_type = 0, reset_wait_cost_type = 0, reset_wait_price = ""})
mapArray:push({ id = 5, name = "摩诃衍1", cooldown = 0, wait_time = 0, init_value = 3, max = 3, cost_type = 0, price = "", amount = 3, recovery = 0, level_up = 0, max_vip_rule = 2013, buy_vip_rule = 2003, battle_type = 7, reset_wait_cost_type = 0, reset_wait_price = ""})
mapArray:push({ id = 6, name = "摩诃衍2", cooldown = 0, wait_time = 0, init_value = 3, max = 3, cost_type = 0, price = "", amount = 3, recovery = 0, level_up = 0, max_vip_rule = 2013, buy_vip_rule = 2003, battle_type = 7, reset_wait_cost_type = 0, reset_wait_price = ""})
mapArray:push({ id = 7, name = "摩诃衍3", cooldown = 0, wait_time = 0, init_value = 3, max = 3, cost_type = 0, price = "", amount = 3, recovery = 0, level_up = 0, max_vip_rule = 2013, buy_vip_rule = 2003, battle_type = 7, reset_wait_cost_type = 0, reset_wait_price = ""})
mapArray:push({ id = 8, name = "排行榜点赞", cooldown = 0, wait_time = 0, init_value = 5, max = 5, cost_type = 0, price = "", amount = 5, recovery = 0, level_up = 0, max_vip_rule = 0, buy_vip_rule = 0, battle_type = 0, reset_wait_cost_type = 0, reset_wait_price = ""})
mapArray:push({ id = 9, name = "挖矿", cooldown = 0, wait_time = 0, init_value = 0, max = 2, cost_type = 0, price = "", amount = 1, recovery = 0, level_up = 0, max_vip_rule = 8000, buy_vip_rule = 0, battle_type = 18, reset_wait_cost_type = 0, reset_wait_price = ""})
mapArray:push({ id = 10, name = "包子", cooldown = 0, wait_time = 0, init_value = 30, max = 30, cost_type = 4, price = "20,20,20,50,50,50,100,100,100,100,200,200,200,200,200,200,200,400,400,400,400,400,400,400,400,400,400,400,400,400", amount = 10, recovery = 0, level_up = 0, max_vip_rule = 0, buy_vip_rule = 2005, battle_type = 1, reset_wait_cost_type = 0, reset_wait_price = ""})
mapArray:push({ id = 11, name = "杀戮次数", cooldown = 0, wait_time = 0, init_value = 5, max = 5, cost_type = 4, price = "50,50,100,100,100,200,200,200,200,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400,400", amount = 5, recovery = 0, level_up = 0, max_vip_rule = 0, buy_vip_rule = 2006, battle_type = 3, reset_wait_cost_type = 4, reset_wait_price = "50,50,100,100,100,100,200,200,200,200,200,400"})
mapArray:push({ id = 12, name = "报仇", cooldown = 0, wait_time = 0, init_value = 0, max = 0, cost_type = 4, price = "20,20,50,50,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100", amount = 1, recovery = 0, level_up = 0, max_vip_rule = 0, buy_vip_rule = 0, battle_type = 1, reset_wait_cost_type = 0, reset_wait_price = ""})
return mapArray
