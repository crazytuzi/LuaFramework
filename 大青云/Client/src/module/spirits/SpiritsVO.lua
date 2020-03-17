--[[
武魂VO
liyuan
2014年9月27日10:11:28
]]

_G.SpiritsVO = {}

SpiritsVO.wuhunId = 0; -- 武魂id
SpiritsVO.hunzhu = 0; -- 武魂当前魂珠
SpiritsVO.feedNum = 0; -- 喂养次数
SpiritsVO.hunzhuProgress = 0; -- 魂珠进度
SpiritsVO.wuhunWish = 0; -- 喂养祝福
SpiritsVO.wuhunState = 0; -- 状态，0,未激活，1表示激活，2,俯身
SpiritsVO.feedItem = nil

function SpiritsVO:new()
	local obj = setmetatable({},{__index = self})
	return obj
end