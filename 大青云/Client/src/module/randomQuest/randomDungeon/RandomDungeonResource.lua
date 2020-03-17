--[[
奇遇副本 多倍打坐效果
2015年7月31日21:25:24
haohu
]]
--------------------------------------------------------------这个类暂未用到

_G.RandomDungeonResource = setmetatable( {}, {__index = RandomDungeon} )

function RandomDungeonResource:GetType()
	return RandomDungeonConsts.Type_Resource
end

function RandomDungeonResource:DoStep2()
	-- self:RunToNpc()
end

