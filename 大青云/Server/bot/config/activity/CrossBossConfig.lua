--[[
跨服boss
]]
_G.CrossBossConfig = {
	[1] = {x = -445, y = -544, dir = 0},--小BOSS坐标
    [2] = {x = 525, y = -430, dir = 0},
    [3] = {x = 440, y = 450, dir = 0},
    [4] = {x = -468, y = 308, dir = 0},
	[5] = {x = -60, y = -81, dir = 0}--大BOSS坐标
}

_G.CrossBossTimeConfig = {
	[1] = 1,--宝箱刷新时间1分钟
}

_G.CrossBossStatueConfig = {
	[1] = {id = 10000081, x = 658, y = 130, dir = 0, owner = 0, buff = 1013014},--4个buff柱子
	[2] = {id = 10000082, x = 365, y = -539, dir = 0, owner = 0, buff = 1013015},
	[3] = {id = 10000083, x = -612, y = 131, dir = 0, owner = 0, buff = 1013016},
	[4] = {id = 10000084, x = -207, y = 534, dir = 0, owner = 0, buff = 1013017},
}