local mapArray = MEMapArray:new()
--mapArray:push({ id = 1, name = "三十六天罡" , level = 1,path = "ui_new/activity/tiangang",layer = "lua.logic.thirtysix.ThirtySixEnter"})
mapArray:push({ id = 1, name = "群豪谱" , level = 1,path = "ui_new/spectrum/jz_qunhao",layer = "lua.logic.arena.ArenaHomeLayer"})
mapArray:push({ id = 2, name = "无量山" , level = 1,path = "ui_new/spectrum/jz_wuliang",layer = "lua.logic.climb.ClimbHomeLayer"})
mapArray:push({ id = 3, name = "血战" , level = 1,path = "ui_new/spectrum/jz_xuezhan",layer = "lua.logic.bloodFight.BloodyHomeLayer"})
mapArray:push({ id = 4, name = "摩诃崖" , level = 1,path = "ui_new/spectrum/zhanhun",layer = "lua.logic.climb.CarbonHomeLayer"})
mapArray:push({ id = 5, name = "Boss" , level = 1,path = "ui_new/spectrum/boss",layer = "lua.logic.bossfight.BossFightHomeLayer"})
mapArray:push({ id = 6, name = "挖矿" , level = 1,path = "ui_new/spectrum/jz_kuang",layer = "lua.logic.mining.MiningHomeLayer"})
return mapArray