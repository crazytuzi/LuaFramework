--KnightAssociationItem.lua

require("app.cfg.association_info")
require("app.cfg.knight_info")
require("app.cfg.equipment_info")
require("app.cfg.treasure_info")

local KnightAssociationItem = class("KnightAssociationItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/BaseInfo_AssociationItem.json")
end)


function KnightAssociationItem:ctor( ... )
	self._type = 0
	self._id = 0

	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
	self:setTouchEnabled(true)
	self:registerCellClickEvent(function ( ... )
		self:_onGet()
	end)
end

function KnightAssociationItem:_onGet( ... )
	if self._type == 1 then
			require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_KNIGHT, self._value, self._scenePack)
		elseif self._type == 2 then
			require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_EQUIPMENT, self._value, self._scenePack)
		elseif self._type == 3 then
			require("app.scenes.common.acquireInfo.AcquireInfoLayer").show(G_Goods.TYPE_TREASURE, self._value, self._scenePack)
		end
end

function KnightAssociationItem:updateItem( wayItem )
	if type(wayItem) ~= "table" then 
		return 
	end

	self._type = wayItem.typeId
	self._value = wayItem.value

	self:registerBtnClickEvent("Button_get", function ( ... )
		self:_onGet()
	end)

	local itemInfo = nil
	if self._type == 1 then 
		itemInfo = knight_info.get(self._value)
	elseif self._type == 2 then 
		itemInfo = equipment_info.get(self._value)
	elseif self._type == 3 then 
		itemInfo = treasure_info.get(self._value)
	end

	if not itemInfo then 
		assert("[KnightAssociationItem] wrong id:"..self._value)
		return 
	end

	local count = 0
    if self._type == 1 then
    	local arr = G_Me.bagData.knightsData:getCostKnight(itemInfo.advance_code, nil, -1)
        count = #arr
    elseif self._type == 2 then
        count = G_Me.bagData:getEquipmentNumByBaseId(value)
    elseif self._type == 3 then
        count = G_Me.bagData:getTreasureNumByBaseId(value)
    end
    self:showWidgetByName("Image_flag", count > 0)

	local associtionInfo = association_info.get(wayItem.id or 0)
	self:showTextWithLabel("Label_content", associtionInfo and ("["..associtionInfo.name.."] "..associtionInfo.directions) or "")

	

	local name = self:getLabelByName("Label_name")
	if name ~= nil then
		name:setColor(Colors.qualityColors[itemInfo.quality])
		name:setText(itemInfo.name or "Default Name")		
	end

	local icon = self:getImageViewByName("Image_icon")
	if icon ~= nil then
		local heroPath = nil
		if self._type == 1 then
			heroPath = G_Path.getKnightIcon(itemInfo.res_id)
		elseif self._type == 2 then 
			heroPath = G_Path.getEquipmentIcon(itemInfo.res_id)
		elseif self._type == 3 then 
			heroPath = G_Path.getTreasureIcon(itemInfo.res_id)
		end
    	icon:loadTexture(heroPath, UI_TEX_TYPE_LOCAL)    	  
	end

	icon = self:getImageViewByName("Image_equip_back")
	if icon then
		icon:setVisible(self._type == 2 or self._type == 3)
		if self._type == 2 or self._type == 3 then 
			icon:loadTexture(G_Path.getEquipIconBack(itemInfo.quality))
		end
	end

	local pingji = self:getImageViewByName("Image_pingji")
	if pingji then
    	pingji:loadTexture(G_Path.getAddtionKnightColorImage(itemInfo.quality))  
    end
end

return KnightAssociationItem
