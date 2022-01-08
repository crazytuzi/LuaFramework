--[[
******效果加成属性数据类*******

	-- by Stephen.tao
	-- 2014/2/7
]]

local EffectExtraData = require('lua.gamedata.base.EffectExtraData')
local RoleEffectExtraData = class("RoleEffectExtraData")


function RoleEffectExtraData:ctor(cardrole)
	self.baseAttribute 	= EffectExtraData:new() --基本属性
	self.attributeUp 	= EffectExtraData:new()
	self.skillAttribute	= EffectExtraData:new()
	self.practiceAttribute	= EffectExtraData:new()
	self.qimenAttribute	= EffectExtraData:new()--奇门遁属性
	self.totalAttribute	= EffectExtraData:new()

	self.power 			= 0		--战斗力
	self.cardrole = cardrole
	self:restart()
end

function RoleEffectExtraData:restart()
	self.baseAttribute:clear()
	self.attributeUp:clear()
	self.skillAttribute:clear()
	self.qimenAttribute:clear()
	self.practiceAttribute:clear()
	self.totalAttribute:clear()
end


function RoleEffectExtraData:initBaseAttribute( attr_string )
	self.baseAttribute:clear()
	self.attributeUp:clear()
	if attr_string == nil or attr_string == "" then
		return
	end

	local temptbl = string.split(attr_string,'|')			--分解"|"
	for k,v in pairs(temptbl) do
		local temp = string.split(v,'_')				--分解'_',集合为 key，vaule 2个元素
		self.baseAttribute:setAttr(tonumber(temp[1]),tonumber(temp[2]))
		self.attributeUp:setAttr(tonumber(temp[1]),tonumber(temp[3]))
	end

	self.baseAttribute:updatePower()
	self.attributeUp:updatePower()

	self:updateAttribute()
end

function RoleEffectExtraData:clearSkillAttribute()
	self.skillAttribute:clear()
end

function RoleEffectExtraData:isNeedUpdateByLevelUp()
	return not self.attributeUp:isEmpty()
end

function RoleEffectExtraData:updateAttribute()
	local function cmp( base , growth ,level)
		return base + growth * level
	end
	self.totalAttribute:clear()
	self.totalAttribute:clone(self.baseAttribute)
	self.totalAttribute:doMathAttData( self.attributeUp,cmp,self.cardrole.level)
	self.totalAttribute:setAddAttData(self.skillAttribute)
	self.totalAttribute:setAddAttData(self.qimenAttribute)
	self.totalAttribute:setAddAttData(self.practiceAttribute)
	self:updatePower()
end

function RoleEffectExtraData:updatePower()
	self.power = 0
	return self.power
end
function RoleEffectExtraData:getSkillAttribute()
	return self.skillAttribute
end
function RoleEffectExtraData:getPracticeAttribute()
	return self.skillAttribute
end

function RoleEffectExtraData:getQimenAttribute()
	return self.qimenAttribute
end
function RoleEffectExtraData:displayString()
	return self.totalAttribute:displayString()
end

return RoleEffectExtraData