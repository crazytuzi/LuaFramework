local itemBase = include("itemBase")
local itemUsed =  class("itemUsed",itemBase)


function itemUsed:ctor(tableId)
	 self.super.ctor(self,tableId)
	
end

 
function itemUsed:getUsedItemConfig()
 	return  itemManager.getUsedItemConfig(self.subid)
end 	
 
function itemUsed:getNeedKingLevel()
	 return  self:getUsedItemConfig().kingLevelLimit
end	






return itemUsed