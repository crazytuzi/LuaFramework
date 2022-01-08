--[[
******游戏数据装备牌属性数据类*******

	-- by Stephen.tao
	-- 2014/2/7
]]

local EffectExtraData = class("EffectExtraData")


function EffectExtraData:ctor()
	self.attribute 			= {} 			--基本属性
	self.power 				= 0 			--战斗力
end

 --[[
Data 为字符串，格式：属性索引_属性值|……
如：2_230|3_40
 ]]
function EffectExtraData:init(Data)
	--self.attribute = {}
	self.attribute,self.indexTable = GetAttrByStringForExtra(Data)
	self:updatePower()
end


--增加某个属性的数字
function EffectExtraData:setAttr(attr_index,attr_num)
	self.attribute[attr_index] = attr_num
end


--克隆传入的数据信息类
function EffectExtraData:clone(attr1)
	self.attribute = {}
	for k,v in pairs(attr1.attribute) do
		self.attribute[k] = v
	end
	self:updatePower()
end

--通过index获得属性值，如果index为空则传出整个属性table
function EffectExtraData:getAttribute(index)
	if index then
		return self.attribute[index]
	end
	return self.attribute,self.indexTable
end

--更新战斗力
function EffectExtraData:updatePower()
	self.power = 0
end

--获得战斗力
function EffectExtraData:getPower()
	return self.power
end


--该类属性table增加一个属性table
function EffectExtraData:setAddAttData(attr1)
	self:add(attr1.attribute)
end

--该类属性table增加一个属性table
function EffectExtraData:add(tbl)
	for k,v in pairs(tbl) do
		local x = self.attribute[k] or 0
		self.attribute[k] = x + v
	end
end


--该类属性table与一个属性table一起运算
function EffectExtraData:doMathAttData(attr1,cmp,...)
	for k,v in pairs(attr1.attribute) do
		local x = self.attribute[k] or 0
		if cmp == nil then
			self.attribute[k] = x + v
		else
			self.attribute[k] = cmp(x,v,...)
		end
	end
end

--清零
function EffectExtraData:clear()
	self.attribute 			= {} 			--基本属性
	self.power 				= 0 			--战斗力
end

function EffectExtraData:isEmpty()
	return next(self.attribute) == nil
end

--增加某个属性的数字
function EffectExtraData:addAttr(attr_index,attr_num)
	if self.attribute[attr_index] == nil then
		self.attribute[attr_index] = 0
	end
	self.attribute[attr_index] = attr_num + self.attribute[attr_index]
end

--通过非0属性顺序位获得属性值
function EffectExtraData:getAttributeByIndex(index)
	local temp = 1
	for k,v in pairs(self.attribute) do
		if v > 0 then
			if temp == index then
				return k , v
			end
			temp = temp + 1
		end
	end
end


function EffectExtraData:getIndexTable()
	return self.indexTable
end

function EffectExtraData:displayString()
	local string = ""
	for k,v in pairs(self.attribute) do
		string = string .. AttributeTypeStr[k] .. "：" .. v/100 .. "%,"
	end
	return string
end

return EffectExtraData