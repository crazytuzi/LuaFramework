local mapArray = MEMapArray:new()
mapArray:push({ id = 1, name = "争霸赛" , level = 1,path = "ui_new/Zhenbashai/tab_wldh",layer = "lua.logic.zhengba.ZhenbashaiHomeLayer"})
mapArray:push({ id = 2, name = "争霸赛2" , level = 1,path = "ui_new/faction/fight/tab_bpzf",layer = "lua.logic.factionfight.FactionFightEntrance"})
mapArray:push({ id = 3, name = "个人跨服战" , level = 1,path = "ui_new/wulin/tab_kfwl",layer = "lua.logic.multiServerFight.KuaFuEntrance"})

return mapArray