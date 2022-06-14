local special =  class("special")
local attCollectionClass  = include("attCollection")


local SPECIAL_INDEX = "SPECIAL_INDEX"
local SPECIAL_POS = "SPECIAL_POS"
local SPECIAL_VEC= "SPECIAL_VEC"


local SPECIAL_START   = "SPECIAL_START"
local SPECIAL_COUNT   = "SPECIAL_COUNT"
 

local SPECIAL_SHOP_SALE_PRICE = "SPECIAL_SHOP_SALE_PRICE"
local SPECIAL_SHOP_SALE_MONEY= "SPECIAL_SHOP_SALE_MONEY"
local SPECIAL_SHOP_SALE_FINSH = "SPECIAL_SHOP_SALE_FINSH"


function special:ctor(tableId,subID,count)
	 self.stype = tableId
	 self.subid = subID	
	 self.att = attCollectionClass.new()
	 count = count or 0
	 self.configCount = count
	 self:setStar(0)
	 self:setCount(count)	
	 self:setVec(-1)
	 self:setPos(-1)	

	 self:setSaleMoney(enum.MONEY_TYPE.MONEY_TYPE_GOLD)
	 self:setSaleFinish(false)
	 self:setSalePrice(0)

end

function special:getIndex()
	return self.att:getAttr(SPECIAL_INDEX)		
end 	

function special:setIndex(index)
	self.att:setAttr(SPECIAL_INDEX,index)			
end

function special:getPos()
	return self.att:getAttr(SPECIAL_POS)		
end 	

function special:setPos(pos)
	self.att:setAttr(SPECIAL_POS,pos)			
end


function special:getVec()
	return self.att:getAttr(SPECIAL_VEC)		
end 	

function special:setVec(vec)
	self.att:setAttr(SPECIAL_VEC,vec)			
end
 

function special:setStar(s)
	self.att:setAttr(SPECIAL_START,s)			
end
 
function special:getStar()
 	return self.att:getAttr(SPECIAL_START)		
end 

function special:getShowStar()
	
	return self:getStar();
	
end

function special:getSaleMoneyIcon()
	
	local m = self:getSaleMoney()
 	return itemManager.getSaleMoneyIcon(m)
	
	
	
end 

function special:getImageWithStar()

	return itemManager.getImageWithStar(self:getStar(), self:isDebris());

end 	

function special:getSelectImage()
	return itemManager.getSelectImage(self:isDebris())
end

function special:getBackImage()
	return itemManager.getBackImage(self:isDebris())
end

function special:setCount(s)
	self.att:setAttr(SPECIAL_COUNT,s)	
	local name,icon,star =  self:getInfo() 
	if(star)then	
		self:setStar(star)	
	end
end








 
function special:getCount()
	local name,icon,star, isdebris = self:getInfo() 	
	local 	c = self.att:getAttr(SPECIAL_COUNT)
	if(c == 0 )then
		return self.configCount
	end
	return c
	--[[
	if(isdebris)then
		return self.att:getAttr(SPECIAL_COUNT)
	else
		return 1
	end	
	]]---
end 	 

function special:getEnhanceLevelStr()
	return ""
end 

function special:setSalePrice(s)
	self.att:setAttr(SPECIAL_SHOP_SALE_PRICE,s)			
end
 
function special:getSalePrice()
 	return self.att:getAttr(SPECIAL_SHOP_SALE_PRICE)		
end 	
function special:setSaleMoney(s)
	self.att:setAttr(SPECIAL_SHOP_SALE_MONEY,s)			
end
 
function special:getSaleMoney()
 	return self.att:getAttr(SPECIAL_SHOP_SALE_MONEY)			
end 	

function special:setSaleFinish(s)
	self.att:setAttr(SPECIAL_SHOP_SALE_FINSH,s)			
end
 
function special:getSaleFinish()
 	return self.att:getAttr(SPECIAL_SHOP_SALE_FINSH)		
end 	

 
function special:getType()
 	return   self.stype
end

function special:getSubId()
 	return   self.subid
end

function special:getConfig()
		if(self:isCardExp() )then			
			return dataConfig.configs.unitConfig[self.subid];
		end
		if(self:isMagicExp() )then		
			return  dataConfig.configs.magicConfig[self.subid]
		end
	return nil
end 		

function special:getInfo()

		local isdebris = false;
		
		if(self:isMoney() )then
			return enum.MONEY_NAME_STRING[self.subid], enum.MONEY_ICON_STRING[self.subid]
		end
		if(self:isCardExp() )then
			local c = self:getConfig()
			if c then		
	
				if(table.find(dataConfig.configs.ConfigConfig[0].startLevelTable, self.configCount))then
					name = c.name	
				else
					name = c.name.."碎片"
					isdebris = true;
				end	
	
				return name,c.icon,cardData.getStarByExp(self.configCount), isdebris;										
			end				
		end
		if(self:isMagicExp() )then		
			local c = self:getConfig()
			local name = ""
			if c then		
				if( table.find(dataConfig.configs.ConfigConfig[0].magicLevelExp, self.configCount))then
					name = c.name	
				else
					name = c.name.."碎片"
					isdebris = true;
				end
				return name,c.icon,dataManager.kingMagic:getStarByExp(self.configCount), isdebris;					
			end		
		end	
end 	 

function special:getIcon()
 	local name,icon,star, isdebris = self:getInfo() 	
	return icon;
end 

function special:getMaskIcon()
	if self:isDebris() then
		return "corpsmask.png";
	else
		return nil;
	end
end

function special:isDebris()
	local name,icon,star, isdebris = self:getInfo();
	return isdebris;
end

function special:getName()
	local name,icon,star =  self:getInfo() 	
 	return  name 	
end 

 
 
function special:isMoney() --钱
	return self:getType() == enum.REWARD_TYPE.REWARD_TYPE_MONEY
end 

function special:isCardExp()-- 卡牌经验
	return self:getType() == enum.REWARD_TYPE.REWARD_TYPE_CARD_EXP
end 

function special:isMagicExp() -- 魔法经验
	return self:getType() == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP
end 
 
function special:isSpecial()
	return true;
end

function special:filter(_type)
	return self:getType() == _type
end 
 
 

return special