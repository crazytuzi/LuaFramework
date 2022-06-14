local itemBase = include("itemBase")
local itemDebris =  class("itemDebris",itemBase)

function itemDebris:ctor(tableId)
	 self.super.ctor(self,tableId)
	 
	 self:updateEquipAtt();
end


function itemDebris:getDebrisConfig()
 	 return  itemManager.getDebrisConfig(self.subid)
end 	
 

 
function itemDebris:getProduct()
 	return  self:getDebrisConfig().productID ,self:getDebrisConfig().needCount
end 	

function itemDebris:getProductStar()
 	local id =  self:getDebrisConfig().productID  
	return itemManager.getConfig(id).star or 0
end 	
 
function itemDebris:getProductUseLevel()
	local config = self:getProductDetailConfig()
	local level = 1
	if(self:getProductIsEquip())then
		 if(config)then
		
			level =  config.requireLevel
		 end
	elseif(self:getProductIsUsedItem())then
		 if(config)then
			level = config.kingLevelLimit 
		 end	
	end		
	return level
end 	

function itemDebris:getProductIsEquip()
	local config = self:getProductConfig()
	return config.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP
end	

function itemDebris:getProductIsUsedItem()
	local config = self:getProductConfig()
	return config.type == enum.ITEM_TYPE.ITEM_TYPE_USED
end	

 

function itemDebris:getProductIsMatrial()
	local config = self:getProductConfig()
	return config.type == enum.ITEM_TYPE.ITEM_TYPE_MATERIAL
end	


function itemDebris:getProductDetailConfig()
	local config = self:getProductConfig()
	local t = nil
	if(config.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP)then
		t  = itemManager.getEquipConfig(config.subID)
	elseif(config.type == enum.ITEM_TYPE.ITEM_TYPE_USED)then
		t  = itemManager.getUsedItemConfig(config.subID)
	elseif(config.type == enum.ITEM_TYPE.ITEM_TYPE_MATERIAL)then
	
	elseif(config.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP)then
		t  = itemManager.getDebrisConfig(config.subID)
	end
	
	return t 
end 


function itemDebris:getProductConfig()
	return itemManager.getConfig(self:getDebrisConfig().productID)
end 

function	itemDebris:updateEquipAtt()
	self.equipAtt = {}
	local config = self:getProductDetailConfig()
	if(config)then
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

function itemDebris:getFirstAttr()
	return self.equipAtt[1];
end

function itemDebris:getSecondAttr()
	return self.equipAtt[2];
end

return itemDebris