
local itemDebris = include("itemDebris")
local itemMatrial = include("itemMatrial")
local itemUsed = include("itemUsed")
local itemEquip = include("itemEquip")
local special = include("special")

itemManager = {}




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
 

-- 护腿九  零 一 起 玩 ww w .9  0 1  7 5. com
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


function itemManager.getEquipPartDes(part)
		local des = ""
		if(part == enum.EQUIP_PART.EQUIP_PART_WEAPON)then
			des = "武器"
		elseif(part == enum.EQUIP_PART.EQUIP_PART_GLOVE)then
			des = "手套"
		elseif(part == enum.EQUIP_PART.EQUIP_PART_BREASTPLATE)then
			des = "胸甲"
		elseif(part == enum.EQUIP_PART.EQUIP_PART_LEGGINGS)then
			des = "护腿"
		elseif(part == enum.EQUIP_PART.EQUIP_PART_HELMENT)then
			des = "头盔"
		elseif(part == enum.EQUIP_PART.EQUIP_PART_SHOES)then
			des = "鞋子"
		end
		return des
end	


function itemManager.getConfig(tableid)
	return dataConfig.configs.itemConfig[tableid]
end

function itemManager.getDebrisConfig(tableid)
	return dataConfig.configs.debrisConfig[tableid]
end

function itemManager.getUsedItemConfig(tableid)
	return dataConfig.configs.useItemConfig[tableid]
end

function itemManager.getEquipConfig(tableid)
	return dataConfig.configs.equipConfig[tableid]
end

function itemManager.getStrengthenConfig(tableid)
	return dataConfig.configs.strengthenConfig[tableid]
end

function itemManager.getImageWithStar(star, isDebris)
	star = star or 0
	if star < 0 then
		star = 0
	end
	
	if isDebris then
		return "set:itemcell.xml image:patchcell"..(star);
	else
		return "set:itemcell.xml image:wupinkuang"..(star);
	end
end

 function itemManager.getMaskIcon(isDebris)
	if isDebris then
		return "itemmask.png";
	else
		return nil;
	end
end

function itemManager.getSelectImage(isDebris)
	if(isDebris)then
		return "set:itemcell.xml image:patchcell-chose"
	end
	return "set:maincontrol.xml image:chose"
end

function itemManager.getBackImage(isDebris)
	if(isDebris)then
		return "set:itemcell.xml image:patchcell"
	end
	return "set:itemcell.xml image:itemback3"
end

function itemManager.getSaleMoneyIcon(money)
	
	 return enum.MONEY_ICON_STRING[money]	
	
end



function itemManager.getImageWithAttId(attid)	
	return enum.EQUIP_ATTR_ICON[attid] 
end



itemManager.allItem = {}
itemManager.id = 0
itemManager.isEnahancingEquip = false;

function itemManager.createItem(tableID,index)
	print("createItem tableID "..tableID);
		
	local config = itemManager.getConfig(tableID)
	
	local itemInstance = nil
	if(config.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP )then
		itemInstance = itemEquip.new(tableID)
	elseif(config.type == enum.ITEM_TYPE.ITEM_TYPE_DEBRIS )then
		itemInstance = itemDebris.new(tableID)
	elseif(config.type == enum.ITEM_TYPE.ITEM_TYPE_MATERIAL )then
		itemInstance = itemMatrial.new(tableID)
	elseif(config.type == enum.ITEM_TYPE.ITEM_TYPE_USED )then
		itemInstance = itemUsed.new(tableID)
	end
	
	if(itemInstance)then
	
		if(index == nil)then
			itemManager.id  = itemManager.id  +  1
			itemManager.allItem[itemManager.id] = itemInstance	
			itemInstance:setIndex(itemManager.id)	
		else
			itemManager.allItem[index] = itemInstance	
			itemInstance:setIndex(index)	
		end
	else
		assert(0,"itemManager.createItem failed .."..tableID)
	end
	
	return itemInstance
end	
function itemManager.destroyItem(index)	
	
	--print("destroyItem")
	itemManager.allItem[index] = nil
end


function itemManager.__additemToManger(item)	
	if(item)then
		itemManager.allItem[item:getIndex()] = item
	end
end

function itemManager.getItem(index)	
	return itemManager.allItem[index]
end

function itemManager.getItemWithGuid( id )	
	if(type(id) == "userdata")then
		id = id:GetUInt()
	end	

	for i ,v in pairs (itemManager.allItem)do 
		if(v and v:getGUID() == id )then
			return v
		end
	end
	return nil
end

-- 记录是否有装备在强化
function itemManager.isEnhancingEquip()
	return itemManager.isEnahancingEquip;
end

function itemManager.setEnhancingEquip(flag)
	itemManager.isEnahancingEquip = flag;
end


itemManager.allSpecial ={}
 
function itemManager.createSpecial(tableId,subID,count)
	
	if( tableId == (enum.REWARD_TYPE.REWARD_TYPE_ITEM))then
		  local item =  itemManager.createItem(subID)	
		  if(item)then
			item:setCount(count)
			return item
		  end	
	else		
		local itemInstance = special.new(tableId,subID,count)	
		if(itemInstance)then
			itemManager.id  = itemManager.id  +  1
			itemManager.allSpecial[itemManager.id] = itemInstance	
			itemInstance:setIndex(itemManager.id)		
			return itemInstance				
		end						
	end		
	assert(0,"itemManager.createSpecial failed .."..tableID)	
	return nil	
end	


function itemManager.destroySpecial(index)	
	
	--print("destroySpecial")
	itemManager.allSpecial[index] = nil
end

function itemManager.getSpecial(index)	
	return itemManager.allSpecial[index]
end

function itemManager.getItemAndSpecial(index)	
	local sp = itemManager.allSpecial[index]
	if(not sp)then
		sp = itemManager.allItem[index]
	end	
	return sp
end