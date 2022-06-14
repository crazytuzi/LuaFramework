local itemBase =  class("itemBase")
local attCollectionClass  = include("attCollection")


local ITEM_INDEX = "ITEM_INDEX"
local ITEM_POS = "ITEM_POS"
local ITEM_VEC= "ITEM_VEC"


local ITEM_START   = "ITEM_START"
local ITEM_COUNT   = "ITEM_COUNT"
local ITEM_CREATE_TIME = "ITEM_CREATE_TIME"

local ITEM_SHOP_SALE_PRICE = "ITEM_SHOP_SALE_PRICE"
local ITEM_SHOP_SALE_MONEY= "ITEM_SHOP_SALE_MONEY"
local ITEM_SHOP_SALE_FINSH = "ITEM_SHOP_SALE_FINSH"
local ITEM_GUID = "ITEM_GUID"

function itemBase:ctor(tableId)
	 self.id = tableId
	 self.subid = self:getConfig().subID
	 self.att = attCollectionClass.new()
	 self:setStar(self:getConfig().star)
	 self:setCount(1)
	
	 self:setVec(-1)
	 self:setPos(-1)
	 self:setCreateTime(0)	
	 self:setSaleMoney(0)
	 self:setSaleFinish(false)
	 self:setSalePrice(0)
end



function itemBase:getTipText(c)
				
	local yellow = "^FFFF00"
	local itemcolor = "^00FF00"
	local num  = c or self:getCount()
	local color = {}
	color[0] = 	"^FFFFFF" --白色
	color[1] = 	"^00FF00" -- 绿色
	color[2] = 	"^1096D5" -- 蓝色
	color[3] = 	"^BE4BF9" --紫色
	color[4] = 	"^FF9000" -- 橙色
	color[5] = 	"^E30000" -- 红色
	local star = self:getStar()
	itemcolor = color[star] or itemcolor
	 
	local t = nil
	if(self:isEquip())then
		t = yellow.."获得装备".."["..itemcolor..self:getName()..yellow.."] X"..num
	elseif(self:isDebris())then
		t = yellow.."获得碎片".."["..itemcolor..self:getName()..yellow.."] X"..num
	elseif(self:isMatrial())then
		t = yellow.."获得材料".."["..itemcolor..self:getName()..yellow.."] X"..num
	elseif(self:isUsedItem())then
		t = yellow.."获得道具".."["..itemcolor..self:getName()..yellow.."] X"..num
	end
	return t
end 

 

 
function itemBase.getEquipAttDesc(attid)
		local att = ""
		if(attid == enum.EQUIP_ATTR.EQUIP_ATTR_ATTACK)then
			att = "攻击等级"
		elseif(attid == enum.EQUIP_ATTR.EQUIP_ATTR_DEFENCE)then
			att = "防御等级"
		elseif(attid == enum.EQUIP_ATTR.EQUIP_ATTR_CRITICAL)then
			att = "暴击等级"
		elseif(attid == enum.EQUIP_ATTR.EQUIP_ATTR_RESILIENCE)then
			att = "韧性等级"
		end
	 
		return att
end	

function itemBase:getSaleMoneyIcon()
	 return itemManager.getSaleMoneyIcon(self:getSaleMoney())
end


function itemBase:getIndex()
	return self.att:getAttr(ITEM_INDEX)		
end 	

function itemBase:setIndex(index)
	self.att:setAttr(ITEM_INDEX,index)			
end


function itemBase:getGUID()
	return self.att:getAttr(ITEM_GUID)		
end 	

function itemBase:setGUID(id)
	if(type(id) == "userdata")then
		id = id:GetUInt()
	end	
	self.att:setAttr(ITEM_GUID,id)			
end

function itemBase:getPos()
	return self.att:getAttr(ITEM_POS)		
end 	

function itemBase:setPos(pos)
	self.att:setAttr(ITEM_POS,pos)			
end


function itemBase:getVec()
	return self.att:getAttr(ITEM_VEC)		
end 	

function itemBase:setVec(vec)
	self.att:setAttr(ITEM_VEC,vec)			
end
 
function itemBase:getConfig()
 	return  itemManager.getConfig(self.id)
end 		

function itemBase:setStar(s)
	self.att:setAttr(ITEM_START,s)			
end
 
function itemBase:getStar()
 	return self.att:getAttr(ITEM_START)		
end 

function itemBase:getShowStar()
	return 0;
end

function itemBase:getImageWithStar()
	return itemManager.getImageWithStar(self:getStar(), self:isDebris())	
end 	

function itemBase:getSelectImage()
	return itemManager.getSelectImage(self:isDebris())
end

function itemBase:getBackImage()
	return   itemManager.getBackImage(self:isDebris())
end
function itemBase:setCount(s)
	self.att:setAttr(ITEM_COUNT,s)			
end
 
function itemBase:getCount()
 	return self.att:getAttr(ITEM_COUNT)		
end 	 

function itemBase:getEnhanceLevelStr()
	return ""
end 

function itemBase:getEnhanceLevel()
	return 0
end 

function itemBase:setSalePrice(s)
	self.att:setAttr(ITEM_SHOP_SALE_PRICE,s)			
end
 
function itemBase:getSalePrice()
 	return self.att:getAttr(ITEM_SHOP_SALE_PRICE)		
end 	
function itemBase:setSaleMoney(s)
	self.att:setAttr(ITEM_SHOP_SALE_MONEY,s)			
end
 
function itemBase:getSaleMoney()
 	return self.att:getAttr(ITEM_SHOP_SALE_MONEY)		
end 	

function itemBase:setSaleFinish(s)
	self.att:setAttr(ITEM_SHOP_SALE_FINSH,s)			
end
 
function itemBase:getSaleFinish()
 	return self.att:getAttr(ITEM_SHOP_SALE_FINSH)		
end 	

function itemBase:getProductUseLevel()
	return 1
end	
function itemBase:getUseLevel()
	if(self:isEquip())then
		return self:getNeedKingLevel()		
	elseif(self:isUsedItem())then
		return self:getNeedKingLevel()
	else		
		return 1
	end		
end 	 

 	

function itemBase:setCreateTime(s)
	local t = nil
	if(type(s) == "userdata")then
		t  = s:GetUInt()	 
	else
		t  = s		
	end				
	self.att:setAttr(ITEM_CREATE_TIME,t)			
end	

function itemBase:getCreateTime()
 	return self.att:getAttr(ITEM_CREATE_TIME)		
end 	 

function itemBase:getId()
 	return   self.id
end


function itemBase:getSubId()
 	return   self.subid
end
 
function itemBase:getIcon()
 	return   self:getConfig().icon;
end 	 

function itemBase:getMaskIcon()
	if self:isDebris() then
		return "itemmask.png";
	else
		return nil;
	end
end

function itemBase:getName()
 	return   self:getConfig().name	 
end 	
 
function itemBase:getText()
 	return   self:getConfig().text	 
end 	
 
function itemBase:getType()
	local config = self:getConfig()
	return config.type
end 	

function itemBase:isEquip() --装备
	return self:getType() == enum.ITEM_TYPE.ITEM_TYPE_EQUIP
end 

function itemBase:isDebris() --碎片
	return self:getType() == enum.ITEM_TYPE.ITEM_TYPE_DEBRIS
end 

function itemBase:isMatrial()-- 材料
	return self:getType() == enum.ITEM_TYPE.ITEM_TYPE_MATERIAL
end 

function itemBase:isUsedItem() -- 可使用物品
	return self:getType() == enum.ITEM_TYPE.ITEM_TYPE_USED
end 
 
function itemBase:isSpecial()
	return false;
end

function itemBase:filter(_type)
	return self:getType() == _type
end 

function itemBase:getEnhanceCost()
	return 0
end
function itemBase:canScale() -- 可否出售 可以返回结果
	local config = self:getConfig() 
	if(config.noSell == true)then
		return  false,0
	else
		return  true,config.sellToShop + self:getEnhanceCost()
	end		
end 

function itemBase:canOverlap() -- 可否堆叠
	return   self:getConfig().noOverlap == false	 
end 


return itemBase