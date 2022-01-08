--[[
******游戏数据装备牌类*******

	-- by Stephen.tao
	-- 2013/11/25
]]

local GameObject = require('lua.gamedata.base.GameObject')
local CardEquipment = class("CardEquipment",GameObject)

--local ItemData = require('lua.table.ItemData')
local GameAttributeData = require('lua.gamedata.base.GameAttributeData')

function CardEquipment:ctor( Data )
	self.super.ctor(self)
	self:init(Data)

end


function CardEquipment:init( Data )
	self.attribute 			= GameAttributeData:new() 			--最终基本属性
	self.baseAttribute   	= GameAttributeData:new() 			--基本属性
	self.extraAttribute 	= GameAttributeData:new()			--附加属性
	self.totalAttr 			= GameAttributeData:new()

	self.baseAttributeWithRecast = GameAttributeData:new()			--除开宝石有装备重铸的附加属性
	self.extraAttributeWithRecast = GameAttributeData:new()			--除开宝石有装备重铸的附加属性

	self.totalAttrWithOutGem= GameAttributeData:new()			--除开宝石的总属性
	self.totalAttrWithGem	= GameAttributeData:new()			--宝石的总属性
	self.grow 				= 0 								--成长值
	self.star 				= 0 								--星级
	self.maxGem 			= 0 								--最大宝石数
	self.gemId   			= {} 								--宝石的id
	self.recastInfo			= {}								--重铸信息
	self.recastPercent		= 0									--重铸基本属性加成百分比
	self.extraPercent		= 0									--重铸附加属性加成百分比

	local equipMentData = ItemData:objectByID(Data)
	if equipMentData == nil then
		print("equipMentData == nil,id = ",Data)
		return
	end
	self.type 				= EnumGameObjectType.Equipment 		--道具卡
	self.gmId				= 0 								--服务器唯一id
	self.level 				= 0									--等级
	self.equip 				= 0									--装备于某人
	self.equipType			= 0									--装备类型
	self.failPercent		= 0									--升星失败修正值
	self.refineLevel 		= 0									--------精炼等级


--对解析装备表进行赋值操作
	--self.attribute         = GetAttrByString(equipMentData.def_attr)

	--self.totalAttr 		   = self.attribute + self.extraAttribute
	self.name 			= equipMentData.name
	self.id 			= equipMentData.id
	self.equipType		= equipMentData:getKind()					--装备类型
	self.quality		= equipMentData.quality						--品质
	self.textrueName	= equipMentData:GetPath()					--图片名
	self.describe1		= equipMentData.outline						--描述
	self.describe2		= equipMentData.details	 					--详细描述
	self.price			= equipMentData.price						--身价
	self.usedlevel      = equipMentData.level 	 					--使用等级
	self.power  		= 0  										--战力

	self:setLevel(0)
end

--获得总属性table表
function CardEquipment:GetTotalAttr()
	return self.totalAttr:getAttribute()
end
--获得总属性
function CardEquipment:GetTotalAttrArray()
	return self.totalAttr
end

--设置等级，改变总属性
function CardEquipment:setLevel( level )
	self.level = level
	self:UpdateBaseAttribute()
	self:UpdatePower()
end

function CardEquipment:dispose()
	self.super.dispose(self)
	self.attribute 			= nil
	self.extraAttribute 	= nil
	self.totalAttr 		 	= nil
	self.grow 		 		= nil
	self.gmId				= nil 						--服务器唯一id
	self.level 				= nil						--等级
	self.equip 				= nil						--装备于某人
	self.equipType			= nil						--装备类型
	self.usedlevel      	= nil
	self.power  			= nil
	self.star  				= nil
	self.failPercent		= nil

	self.totalAttrWithRecast = nil
	self.totalAttrWithOutGem = nil
	self.totalAttrWithGem = nil
	TFDirector:unRequire('lua.gamedata.base.GameObject')
	TFDirector:unRequire('lua.gamedata.base.GameAttributeData')
end

--[[
	--获取图片路径
]]
function CardEquipment:GetTextrue()
	--print(self.name .. " path " .. self.textrueName)
	return self.textrueName
end
--更新战斗力
function CardEquipment:UpdatePower()
	self:UpdateAttr()
end

--更新所有属性总和
function CardEquipment:UpdateAttr()
	self.totalAttr:clear()
	self.totalAttrWithOutGem:clear()
	self.totalAttrWithGem:clear()

	self.baseAttributeWithRecast:clear()
	self.extraAttributeWithRecast:clear()

	--刷新重铸属性
	self.baseAttributeWithRecast:clone(self.attribute)
	self.extraAttributeWithRecast:clone(self.extraAttribute)
	local baseAttribute = self.baseAttributeWithRecast.attribute or {}
	for k,v in pairs(baseAttribute) do
		self.baseAttributeWithRecast:addAttr(k,math.floor(v*self.recastPercent/100))
	end
	local extraAttribute = self.extraAttributeWithRecast.attribute or {}
	for k,v in pairs(extraAttribute) do
		self.extraAttributeWithRecast:addAttr(k,math.floor(v*self.extraPercent/100))
	end

	-- self.totalAttr:setAdd(self.attribute,self.extraAttribute)
	--self.totalAttrWithOutGem:setAdd(self.attribute,self.extraAttribute)
	self.totalAttr:setAdd(self.baseAttributeWithRecast,self.extraAttributeWithRecast)
	self.totalAttrWithOutGem:setAdd(self.baseAttributeWithRecast,self.extraAttributeWithRecast)

	--self.totalAttr:refreshBypercent()
	local newPower = CalculateEquipPower(self.totalAttr.attribute)
	for i=1,self.maxGem do
		if self:getGemPos(i) then
			local gem = GemData:objectByID(self:getGemPos(i))
			if gem then
				local attr_index,attr_num = gem:getAttribute()
				self.totalAttr:addAttr(attr_index,attr_num)
				self.totalAttrWithGem:addAttr(attr_index,attr_num)
				newPower = newPower + CalculateGemPower(attr_index,attr_num)
			end
		end
	end
	-- self.totalAttr:updatePower()
	self.power = newPower
	if self.equip and self.equip ~= 0 then
		local role = CardRoleManager:getRoleById(self.equip)
		if role then
			role:RefreshEquipment()
		end
	end
end

--[[
	--获取物品战力
]]
function CardEquipment:getpower()
	-- return self.totalAttr:getPower()
	return self.power
end

--设置基本属性
function CardEquipment:setBaseAttribute( str )
	self.baseAttribute:init(str)
	self.baseAttributeWithRecast:init(str)
	self:UpdateBaseAttribute()
end

--更新基本属性
function CardEquipment:UpdateBaseAttribute()
	local function cmp( attr , index ,tbl)
		local totalGrowNum = GetTotalGrowNumByKind( index ,tbl.level)
		local num = (attr + totalGrowNum)*tbl.grow
		return math.floor(num)
	end
	self.attribute:clear()
	self.attribute:setAttByMath(self.baseAttribute,cmp,{level = self.level,grow = self.grow})

	-- local baseAttribute = self.attribute.attribute or {}
	-- for k,v in pairs(baseAttribute) do
	-- 	self.attribute:addAttr(k,math.floor(v*self.recastPercent/100))
	-- end
end

--获得当前基本属性
function CardEquipment:getBaseAttribute()	
	return self.attribute
end

--获得一级的基本属性
function CardEquipment:getBaseAttributeOnOne()	
	return self.baseAttribute
end

--设置附加属性
function CardEquipment:setExtraAttribute( str )
	--print("equipment extra : " , str)
	self.extraAttribute:init(str)
	self.extraAttributeWithRecast:init(str)
	-- self:UpdateExtraAttribute()
end

--获得附加属性
function CardEquipment:getExtraAttribute()	
	return self.extraAttribute
end

--设置宝石
function CardEquipment:setGemPos( pos , id )
	if pos > self.maxGem then
		return
	end
	self.gemId[pos] = id
end

--查找宝石
function CardEquipment:getGemPos( pos )
	if pos > self.maxGem then
		return nil
	end
	 return self.gemId[pos]
end

--设置成长值
function CardEquipment:setGrow( grow )
	if grow == nil then
		self.grow = 0
	else
		self.grow = grow/100
	end
	
	self:UpdateBaseAttribute()
end
--设置成长值
function CardEquipment:getGrow()
	return self.grow
end

--设置星级值
function CardEquipment:setStar( star )
	self.star = star	
end
--获取星级
function CardEquipment:getStar()
	return self.star	
end
--设置品质
function CardEquipment:setQuality( quality )
	self.quality = quality	
end

function CardEquipment:getAttrWithOutGem()
	return self.totalAttrWithOutGem
end

function CardEquipment:getAttrWithGem()
	return self.totalAttrWithGem
end

function CardEquipment:isCanMosaicStone( stoneId ,pos)
	local stone = ItemData:objectByID(stoneId)
	if stone == nil then
		print("没有此宝石 id==",stoneId)
		return false
	end
	local gemPos = GemPosData:getConfigByTypeAndPos(self.equipType,pos)
    if gemPos == nil then
		print("没有该类型装备镶嵌的宝石类型")
        return false
    end
    local gemKind = gemPos:getGemKind()
    for k,v in pairs(gemKind) do
		if tonumber(v) == stone.kind then
			return true
		end
    end
    return false
end

function CardEquipment:setRecastInfo(recast_list)
	self.recastInfo = recast_list or {}
	self.recastPercent = 0
	if self.recastInfo then
		for k,v in pairs(self.recastInfo) do
			self.recastPercent = self.recastPercent + v.ratio
		end
	end
	self.extraPercent = EquipmentManager:getExtraPercentByRecast( self.recastInfo )
	--策划将基数由100调到10000了
	self.recastPercent = self.recastPercent/100
	self.extraPercent = self.extraPercent/100


	self:UpdatePower()
end

function CardEquipment:getRecastInfo()
	return self.recastInfo
end

function CardEquipment:getRecastInfoByIdx(idx)
	if self.recastInfo then
		for k,v in pairs(self.recastInfo) do
			if v.index == idx then
				return v
			end
		end
	end
	return nil
end

--是否存在重铸属性
function CardEquipment:getRecastPercent()
	return self.recastPercent or 0
end

function CardEquipment:getPercentByIndex( index )
	if self.recastInfo then
		for k,v in pairs(self.recastInfo) do
			if v.index == index then
				return v
			end
		end
	end
	return nil
end
--新加宝石孔或属性
--1.宝石孔
--2.新加属性
function CardEquipment:getNewTypeAdd()
	print('gmId = ',self.gmId)
	print('recastInfo = ',self.recastInfo)
	local currNewType = {}
	for data in EquipmentRecastData:iterator() do
		if data.sub_type > 0 then
			local des = 0
			local quality = data.quality
			for k,v in pairs(self.recastInfo) do
				if v.quality >= quality then
					des = des + 1
				end
			end
			if des >= data.sub_type then
				local idx = #currNewType + 1
				currNewType[idx] = {}
				currNewType[idx].subType = data.sub_type
				currNewType[idx].describe_title = data.describe_title				
			end
		end
	end
	return currNewType	
end

function CardEquipment:getTotalGemNum()
	return self.maxGem or 0
end

function CardEquipment:getTotalExtraAttrNum()
	local attribute,indexTable = self.extraAttribute:getAttribute()

	return #indexTable or 0
end

function CardEquipment:isCanRecaseGoOnByPos(pos)
	local info = self.recastInfo[pos]
	if info then
		if info.quality < 4 then
			return true
		else
			local templete = EquipmentRecastData:getInfoByquality(info.quality)
			local maxpercent = templete:getMaxPercent(pos)
			if info.ratio >= maxpercent then
				return false
			end
			return true
		end
	end
	return true	
end

function CardEquipment:isCanTouchByPos(pos)
	if pos == 1 then
		return true
	end

	local info = self.recastInfo[pos-1]
	local data = EquipmentRecastConditionData:getInfoByPos(pos)
	if info and data then
		if info.quality >= data.quality then
			return true
		end
	end
	return false	
end

function CardEquipment:getBaseAttributeWithRecast()
	return self.baseAttributeWithRecast
end

function CardEquipment:getExtraAttributeWithRecast()
	return self.extraAttributeWithRecast
end
return CardEquipment