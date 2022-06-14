local itemBase = include("itemBase")
local itemEquip =  class("itemEquip",itemBase)



local EQUIP_ENHANCE_EXP = "EQUIP_ENHANCE_EXP"
local EQUIP_ENHANCE_GOLD = "EQUIP_ENHANCE_GOLD"


function itemEquip:ctor(tableId)
	 self.super.ctor(self,tableId)	
	 local config = self:getEquipConfig()	
	 self:updateEquipAtt()
	 self:setEnhanceGold(0)
	 
   self.equipAtt = {};
   
   -- 下面三个都是有exp计算得到
   self.enhanceLevel = 0;
   self.currentExp = 0;
   self.nextExp = 0;
   
end

function itemEquip:getEquipConfig()
 	 return  itemManager.getEquipConfig(self.subid)
end 	
 
function itemEquip:getNeedKingLevel()
	 return self:getEquipConfig().requireLevel
end 

function itemEquip:getEquipPoint()
	 return self:getEquipConfig().part
end 

-- 武器
function itemEquip:isWeapon()
	 return self:getEquipConfig().part == enum.EQUIP_PART.EQUIP_PART_WEAPON
end 

-- 手套
function itemEquip:isGlove()
	 return self:getEquipConfig().part == enum.EQUIP_PART.EQUIP_PART_GLOVE
end 

-- 胸甲
function itemEquip:isBreastplate()
	 return self:getEquipConfig().part == enum.EQUIP_PART.EQUIP_PART_BREASTPLATE
end 
 

-- 护腿
function itemEquip:isLeggings()
	 return self:getEquipConfig().part == enum.EQUIP_PART.EQUIP_PART_LEGGINGS
end 
-- 头盔
function itemEquip:isHelment()
	 return self:getEquipConfig().part == enum.EQUIP_PART.EQUIP_PART_HELMENT
end 
-- 鞋子
function itemEquip:isShoes()
	 return self:getEquipConfig().part == enum.EQUIP_PART.EQUIP_PART_SHOES
end  

---是否可强化
function itemEquip:canEnhance()
 	 local config = self:getEquipConfig()	
	 if(config.noEnhance) == true then
		return false
	 else		
		return not self:isMaxEnhance();
	 end		
end
--曾经的花费
function itemEquip:getEnhanceCost()
	
	return self:getEnhanceGold()
	
	--[[
	local can = self:canEnhance()
	if(not can )then
		return 0
	end
	local res = 0
	local config = self:getEquipConfig();
	for i = 1,self.enhanceLevel do
		local sconfig =  itemManager.getStrengthenConfig(i);
		if sconfig then
			res = res + toint(config.enhanceCost * sconfig.costFactor);
		end
	end
	return res
	]]--
end
 
--是否最大强化
function itemEquip:isMaxEnhance()
	 --local config = self:getEquipConfig()	
	 --return self.enhanceLevel >= config.enhanceMax 	
	return self.enhanceLevel >= dataManager.playerData:getLevel();
end

--下次强化花费
function itemEquip:getNextEnhanceCost()
	local sconfig =  itemManager.getStrengthenConfig( self:getEnhanceLevel() + 1 );
	if not sconfig then
		return 0;
	end
	local config = self:getEquipConfig();
	return toint(config.enhanceCost * sconfig.costFactor);
end

-- 是否有足够的金币
function itemEquip:isEnoughGoldEnhance()
	local playerInstance = dataManager.playerData;
	local gold = playerInstance:getGold();
	return gold >= self:getNextEnhanceCost();
end

function itemEquip:setEnhanceGold(gold)
	
	local t = nil
	if(type(gold) == "userdata")then
		t  = gold:GetUInt()	 
	else
		t  = gold		
	end						
	self.att:setAttr(EQUIP_ENHANCE_GOLD,t)	
end

function itemEquip:getEnhanceGold()
	return self.att:getAttr(EQUIP_ENHANCE_GOLD)
end
 
--
function itemEquip:setEnhanceLevel(level)
	self.enhanceLevel = level;
	
	self:updateEquipAtt();
end

function itemEquip:isMaxLevel()
	return self.enhanceLevel == #dataConfig.configs.strengthenConfig;
end

function itemEquip:getEnhanceExp()
	return self.att:getAttr(EQUIP_ENHANCE_EXP)
end 

function itemEquip:getNextExp()
	return self.nextExp;
end

function itemEquip:getCurrentExp()
	return self.currentExp;
end

function itemEquip:getEnhanceLevel()
	return self.enhanceLevel;
end

function itemEquip:getEnhanceLevelStr()
	local str = ""
	 if(self.enhanceLevel <= 0)then
		str = ""
	 else
		str = "+"..tostring(self:getEnhanceLevel())
	 end
	 
	return str
end

function	itemEquip:updateEquipAtt()
	self.equipAtt = {}
	local config = self:getEquipConfig()
	local sconfig =  itemManager.getStrengthenConfig( self:getEnhanceLevel())
	if(sconfig)then
		if(config.attr ~= -1)then	
			local att = {}
			att.attid = config.attr
			att.attvalue =  config.baseAttrValue + toint(config.enhanceValue  * sconfig.attrFactor)
			table.insert(self.equipAtt,att)	
		end
		if(config.attr2 ~= -1)then	
			local att = {}
			att.attid = config.attr2
			att.attvalue = config.baseAttrValue2 + toint(config.enhanceValue2  * sconfig.attrFactor)
			table.insert(self.equipAtt,att)	
		end		
	else
		if(config.attr ~= -1)then
			local att = {}
			att.attid = config.attr
			att.attvalue = config.baseAttrValue	
			table.insert(self.equipAtt,att)			
		end
		if(config.attr2 ~= -1)then	
			local att = {}
			att.attid = config.attr2
			att.attvalue = config.baseAttrValue2 			
			table.insert(self.equipAtt,att)	
		end	
		
	end	
			
end


function	itemEquip:getEquipAtt()
	return self.equipAtt
end

function itemEquip:getFirstAttr()
	return self.equipAtt[1];
end

function itemEquip:getSecondAttr()
	return self.equipAtt[2];
end

function itemEquip:getNextFirstAttr()

	local nextConfig = itemManager.getStrengthenConfig( self:getEnhanceLevel()+1);
	if not nextConfig then
		return 0;
	end
	
	return self:getEquipConfig().baseAttrValue + toint(nextConfig.attrFactor * self:getEquipConfig().enhanceValue);
end

function itemEquip:getNextSecondAttr()
	local nextConfig = itemManager.getStrengthenConfig( self:getEnhanceLevel()+1);
	if not nextConfig then
		return 0;
	end
	
	return self:getEquipConfig().baseAttrValue2 + toint(nextConfig.attrFactor * self:getEquipConfig().enhanceValue2);
end



function itemEquip:getFeatureMaxEquipAtt()
		
			local config = self:getEquipConfig()
			--local sconfig =  itemManager.getStrengthenConfig(config.enhanceMax)
			local sconfig =  itemManager.getStrengthenConfig(dataManager.playerData:getLevel());
			
			local v1,v2 = config.baseAttrValue,config.baseAttrValue2
			if(sconfig)then
				if(config.attr ~= -1)then	
					v1 =  v1 + toint(config.enhanceValue  * sconfig.attrFactor)
				end
				
				if(config.attr2 ~= -1)then	
					v2  = v2 + toint(config.enhanceValue2  * sconfig.attrFactor)
				end		
			end	
			return v1,v2
end


return itemEquip