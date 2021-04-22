-- @Author: zhouxiaoshu
-- @Date:   2019-06-17 12:07:11
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-06-17 12:19:58

local QActorProp = import("..models.QActorProp")
local QSoulSpiritProp = class("QSoulSpiritProp", QActorProp)

function QSoulSpiritProp:ctor(soulSpiritInfo)
	self:initProp()
	if soulSpiritInfo ~= nil then
		self:setSoulSpiritInfo(soulSpiritInfo)
	end
end

function QSoulSpiritProp:setSoulSpiritInfo(soulSpiritInfo)
	self._heroInfo = heroInfo
    
end

function QSoulSpiritProp:getBattleForce()
	return 20000
end

return QSoulSpiritProp