--[[
******游戏数据装备牌属性数据类*******

	-- by Stephen.tao
	-- 2014/2/7
]]

local GameAttributeData = class("GameAttributeData")


function GameAttributeData:ctor()
	self.attribute 			= {} 			--基本属性
	self.power 				= 0 			--战斗力
	self.factor 			= 1
end

 --[[
Data 为字符串，格式：属性索引_属性值|……
如：2_230|3_40
 ]]
function GameAttributeData:init(Data)
	--self.attribute = {}
	self.attribute,self.indexTable = GetAttrByStringForExtra(Data)
	self:updatePower()
end

--克隆传入的数据信息类
function GameAttributeData:clone(attr1)
	self.attribute = {}
	for k,v in pairs(attr1.attribute) do
		self.attribute[k] = v
	end
	self:updatePower()
end

--通过index获得属性值，如果index为空则传出整个属性table
function GameAttributeData:getAttribute(index)
	if index then
		return self.attribute[index]
	end
	return self.attribute,self.indexTable
end

--更新战斗力
function GameAttributeData:updatePower()
	self.power = GetPowerByAttribute(self.attribute)
end

--获得战斗力
function GameAttributeData:getPower()
	return self.power
end

--该类属性设置为两个属性table相加值
function GameAttributeData:setAdd(attr1,attr2)
	self.attribute = {}
	for i=1,(EnumAttributeType.Max-1) do
		local x = attr1.attribute[i] or 0
		local y = attr2.attribute[i] or 0
		self.attribute[i] = x + y
	end
end

--该类属性table增加一个属性table
function GameAttributeData:setAddAttData(attr1)
	for i=1,(EnumAttributeType.Max-1) do
		local x = attr1.attribute[i]
		if x then
			local y = self.attribute[i] or 0
			self.attribute[i] = x + y
		end
	end
end

--该类属性table增加一个属性table
function GameAttributeData:add(tbl)
	for i=1,(EnumAttributeType.Max-1) do
		local x = tbl[i]
		if x then
			local y = self.attribute[i] or 0
			self.attribute[i] = x + y
		end
	end
end


--该类属性table与一个属性table一起运算
function GameAttributeData:doMathAttData(attr1,cmp,...)
	for i=1,(EnumAttributeType.Max-1) do
		local y = attr1.attribute[i]
		if y then
			local x = self.attribute[i] or 0
			if cmp == nil then
				self.attribute[i] = x + y
			else
				self.attribute[i] = cmp(x,y,...)
			end
		end
	end
end

--清零
function GameAttributeData:clear()
	self.attribute 			= {} 			--基本属性
	self.power 				= 0 			--战斗力
	self.factor = 1
end

--增加某个属性的数字
function GameAttributeData:addAttr(attr_index,attr_num)
	if self.attribute[attr_index] == nil then
		self.attribute[attr_index] = 0
	end
	self.attribute[attr_index] = attr_num + self.attribute[attr_index]
	if self.attribute[attr_index] < 0 then
		self.attribute[attr_index] = 0 
	end
end

--通过非0属性顺序位获得属性值
function GameAttributeData:getAttributeByIndex(index)
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

--通过运算设置属性值
function GameAttributeData:setAttByMath(attr1,cmp,...)
	for i=1,(EnumAttributeType.Max-1) do
		local x = attr1.attribute[i]
		if x then
			self.attribute[i] = cmp(x,i,...)
		end
	end
end

--通过属性18位以后的百分比 刷新属性
function GameAttributeData:refreshBypercent()
	for i=EnumAttributeType.Blood,EnumAttributeType.PoisonResistance do
		if self.attribute[i] and self.attribute[i + 17] then
			local percent = self.attribute[i + 17] or 0
			percent = percent/10000
			self.attribute[i] = math.floor(self.attribute[i] * (1 + percent))
			self.attribute[i + 17] = 0
		end
	end

	local function calAttrPercent(index, indexPercent)
		if self.attribute[index] then
			local percent = 0

			-- if indexPercent and self.attribute[indexPercent] then
			-- 	percent = self.attribute[indexPercent] or 0
			-- 	self.attribute[indexPercent] = 0
			-- end

			-- percent = percent/10000
			-- self.attribute[index] = math.floor(self.attribute[index] * (1 + percent))
		end
	end 

	-- "Crit",				--暴击
	-- "CritPercent",		--暴击率
	local index 		= EnumAttributeType.Crit
	local indexPercent 	= EnumAttributeType.CritPercent

	calAttrPercent(index, indexPercent)


	index 			= EnumAttributeType.Preciseness--命中
	indexPercent 	= EnumAttributeType.PrecisenessPercent--命中率

	calAttrPercent(index, indexPercent)
	
	--暴抗
	calAttrPercent(EnumAttributeType.CritResistance, nil)

	--闪避
	calAttrPercent(EnumAttributeType.Miss, nil)
	
end

--通过属性18位以后的百分比 刷新装备的角色属性
function GameAttributeData:refreshRoleAttrBypercent(role)
	for i=EnumAttributeType.Blood,EnumAttributeType.PoisonResistance do
		--if self.attribute[i + 17] then
			local attr = role.attribute.attribute[i] or 0
			local oldattr = self.attribute[i] or 0
			local percent = self.attribute[i + 17] or 0
			percent = percent/10000
			self.attribute[i] = oldattr + math.floor(attr * percent)
			self.attribute[i + 17] = 0
		--end
	end

	local function calAttrPercent(index, indexPercent)
		-- print("-------------------calAttrPercent---- ", index)

		-- local attr = role.attribute.attribute[index] or 0
		-- local oldattr = self.attribute[index] or 0
		-- local percent = self.attribute[indexPercent] or 0
		-- percent = percent/10000
		-- self.attribute[i] = oldattr + math.floor(attr * percent)
		-- if self.attribute[indexPercent] then
		-- 	self.attribute[indexPercent] = 0
		-- end
	end 

	-- "Crit",				--暴击
	-- "CritPercent",				--暴击率
	local index 		= EnumAttributeType.Crit
	local indexPercent 	= EnumAttributeType.CritPercent

	calAttrPercent(index, indexPercent)


	index 			= EnumAttributeType.Preciseness--命中
	indexPercent 	= EnumAttributeType.PrecisenessPercent--命中率

	calAttrPercent(index, indexPercent)
	
	--暴抗
	calAttrPercent(EnumAttributeType.CritResistance, nil)
	--闪避
	calAttrPercent(EnumAttributeType.Miss, nil)

end

function GameAttributeData:getIndexTable()
	return self.indexTable
end

function GameAttributeData:displayString()
	local string = ""
	for i=1,(EnumAttributeType.Max-1) do
		local y = self.attribute[i]
		if y and y ~= 0 then
			string = string .. AttributeTypeStr[i] .. "：" .. y .. ","
		end
	end
	return string
end

function GameAttributeData:setFactor(factor)
	for i=EnumAttributeType.Blood,EnumAttributeType.PrecisenessPercent do
			local attr = self.attribute[i]
			if attr and attr ~= 0 then
				self.attribute[i] = math.floor(attr/self.factor*factor)
			end
	end
	self.factor = factor
end

return GameAttributeData