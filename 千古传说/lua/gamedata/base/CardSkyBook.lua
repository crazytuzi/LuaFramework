--[[
******游戏数据装备牌类*******

	-- by Stephen.tao
	-- 2013/11/25
]]

local GameObject = require('lua.gamedata.base.GameObject')
local CardSkyBook = class("CardSkyBook",GameObject)

--local ItemData = require('lua.table.ItemData')
local GameAttributeData = require('lua.gamedata.base.GameAttributeData')

function CardSkyBook:ctor( Data )
	self.super.ctor(self)
	self:init(Data)

end


function CardSkyBook:init( Data )
	self.baseAttribute		= GameAttributeData:new()	--最终基本属性
	self.stoneAttribute		= GameAttributeData:new()	--镶嵌的精要属性
	self.totalAttribute		= GameAttributeData:new()	--总属性

	self.id 				= Data
	self.level				= 0							--重数
	self.tupoLevel			= 0							--突破重数
	self.sbStoneId			= {}						--精要的id


	self.equip 				= 0									--装备于某人
	self.equipType			= 0									--装备类型

	self.instanceId 		= 0

	self.config 			= ItemData:objectByID(self.id)
	self.quality			= self.config.quality

	self.power				= 0										--战力
	self.maxStoneNum		= 0										--最多可镶嵌精要数

	self:setTupoLevel(0)
	self:setLevel(1)
end

--获得总属性table表
function CardSkyBook:getTotalAttr()
	return self.totalAttribute:getAttribute()
end

--获得总属性
function CardSkyBook:getTotalAttrArray()
	return self.totalAttribute
end

--获得天书类型
function CardSkyBook:getConfigType()
	if self.config then
		return self.config.type
	end
	return nil
end

function CardSkyBook:getConfigKind()
	if self.config then
		return self.config.kind or 1
	end
	return 1
end

function CardSkyBook:getConfigName()
	if self.config then
		return self.config.name
	end
	return ""
end

function CardSkyBook:getConfigOutline()
	if self.config then
		return self.config.outline
	end
	return ""
end

function CardSkyBook:getConfigDetails()
	if self.config then
		return self.config.details
	end
	return ""
end

--设置等级，改变总属性
function CardSkyBook:setLevel( level )
	self.level = level
	self.bibleConfig = BibleData:getBibleInfoByIdAndLevel( self.id ,level )

	--天书可镶嵌精要数
	self.maxStoneNum = self.bibleConfig.essential_num
	self.baseAttribute:clear()
	self.baseAttribute:init(self.bibleConfig.bible_att)
	self:updatePower()
end

function CardSkyBook:dispose()
	self.super.dispose(self)
	-- self.attribute			= nil
	self.id					= nil
	self.level				= nil
	self.sbStoneId			= nil
	self.equip				= nil
	self.equipType			= nil
	self.instanceId			= nil
	self.config				= nil
	self.name				= nil
	self.power				= nil
	self.maxStoneNum		= nil
	-- self.bibleConfig				= nil
	-- self.breachConfig				= nil
	TFDirector:unRequire('lua.gamedata.base.GameObject')
	TFDirector:unRequire('lua.gamedata.base.GameAttributeData')
end

--[[
	--获取图片路径
]]
function CardSkyBook:GetTextrue()
	return self.config:GetPath()
end

--更新战斗力
function CardSkyBook:updatePower()
	self:updateAttr()
end

--更新所有属性总和
function CardSkyBook:updateAttr()
	self.totalAttribute:clear()
	self.totalAttribute:clone(self.baseAttribute)
	for i=1,self.maxStoneNum do
		if self.sbStoneId[i] and self.sbStoneId[i] > 0 then
			local attr = self.bibleConfig:getHoleAttr(i)
			self.totalAttribute:addAttr(attr.key, attr.value)
		end
	end
	self.totalAttribute:setFactor(self.breachConfig.factor)
	self.totalAttribute:updatePower()
	self.power = self.totalAttribute:getPower()

	if self.equip and self.equip ~= 0 then
		local role = CardRoleManager:getRoleById(self.equip)
		if role then
			role:updateSkyBookAttr()
		end
	end
end
--[[
	--获取物品战力
]]
function CardSkyBook:getpower()
	return self.power
end

--获得当前基本属性
function CardSkyBook:getBaseAttribute()	
	return self.baseAttribute
end

--设置精要
function CardSkyBook:setStonePos( pos , id )
	if pos > self.maxStoneNum then
		return
	end
	self.sbStoneId[pos] = id
end

--查找宝石
function CardSkyBook:getStonePos(pos)
	if pos > self.maxStoneNum then
		return nil
	end
	return self.sbStoneId[pos]
end

function CardSkyBook:resetStone()
	self.sbStoneId = {}
end

--设置星级值
function CardSkyBook:setTupoLevel( tupoLevel )
	if tupoLevel > SkyBookManager.kMaxStarLevel then
		print("skybook tupolevel error")
		tupoLevel = SkyBookManager.kMaxStarLevel
	end
	self.tupoLevel = tupoLevel
	self.breachConfig = BibleBreachData:getBreachInfo(self.quality, tupoLevel)
end

--获取星级
function CardSkyBook:getTupoLevel()
	return self.tupoLevel
end

--设置品质
function CardSkyBook:setQuality( quality )
	self.quality = quality
	self.breachConfig = BibleBreachData:getBreachInfo( self.quality ,self.tupoLevel)
end

function CardSkyBook:getTotalGemNum()
	return self.maxStoneNum or 0
end

--获得精要id表
function CardSkyBook:getJingyaoIdTable()
	local ids = self.bibleConfig.essential_id
	local tab = string.split(ids, ",")
	return tab
end

return CardSkyBook