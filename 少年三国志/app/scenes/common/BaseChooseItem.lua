
local BaseChooseItem = class("BaseChooseItem", function (  )
	return CCSItemCellBase:create("ui_layout/common_BaseChooseItem.json")
end)

function BaseChooseItem:ctor( ... )
	self._item = {}
	self._acquireExp = 0

	self:registerCellClickEvent(function ( cell, index )
		local checkbox = self:getCheckBoxByName("CheckBox_choose")
		if checkbox then
			checkbox:setSelectedState(not checkbox:getSelectedState())


			if self._selectCallback  ~= nil then

				local ret = self._selectCallback(self._item, self._acquireExp, self )
				if checkbox:getSelectedState() and not ret then
					checkbox:setSelectedState(false)
				end		
			end
			
		end
	end) 

	self:enableLabelStroke("Label_name", Colors.strokeBlack, 1 )
	self:setTouchEnabled(true)
end

function BaseChooseItem:setSelectCallback(func )
	self._selectCallback = func

end

function BaseChooseItem:updateItem( item, selectedItems )

	self._item = item
	local itemInfo = self:getItemInfo(item)
	if not itemInfo then 
		return
	end
	
	local icon = self:getImageViewByName("ImageView_hero_head")
	if icon ~= nil then
    		icon:loadTexture(self:getItemIcon(item), UI_TEX_TYPE_LOCAL) 
	end

	local pingji = self:getImageViewByName("ImageView_pingji")
	if pingji then
    		pingji:loadTexture(G_Path.getAddtionKnightColorImage(itemInfo.quality)) 
    	end

    	self:addEquipBack(itemInfo)

	local checkBox = self:getCheckBoxByName("CheckBox_choose")
	if checkBox then
		local selected = self:_isItemSelected(item, selectedItems)
		checkBox:setSelectedState(selected)
	end

	local name = self:getLabelByName("Label_name")
	if name ~= nil then
		name:setColor(Colors.qualityColors[itemInfo.quality])
		name:setText(itemInfo.name)
	end

	self:updateLevel(item)
	self:updateExp(item)
	self:updateRefineLevel(item)
end

function BaseChooseItem:addEquipBack( itemInfo )
	local sp = ImageView:create()
	sp:setName("default_image_name")
	sp:loadTexture(G_Path.getEquipIconBack(itemInfo.quality))
	local pingji = self:getImageViewByName("ImageView_pingji")
	sp:setPosition(ccp(pingji:getPosition()))
	sp:setZOrder(-1)
	pingji:getParent():addChild(sp)
end

function BaseChooseItem:updateLevel( item )
	self:showTextWithLabel("Label_level", item.level )
	self:showTextWithLabel("Label_level_title", G_lang:get("LANG_TREASURE_STRENGTH_DENGJI") )
end

function BaseChooseItem:updateExp( item )
	self._acquireExp = self:getSupplyExp(item)
	self:showTextWithLabel("Label_exp_value", ""..self._acquireExp)
end

function BaseChooseItem:getSupplyExp( item )
    return 0
end

function BaseChooseItem:updateRefineLevel( item )
	--精炼X阶
	-- if item.refining_level > 0 then
	--     self:showWidgetByName("ImageView_jieshu",true)
	--     self:getLabelByName("Label_jieshu"):setText(G_lang:get("LANG_JING_LIAN", {level = item.refining_level}))
	-- else
	--     self:showWidgetByName("ImageView_jieshu",false)
	-- end
end

function BaseChooseItem:getItemInfo( item )
	return nil
end

function BaseChooseItem:getItemIcon( item )
	return nil
end

function BaseChooseItem:checkStrengthItem( check )
	local checkBox = self:getCheckBoxByName("CheckBox_choose")
	if checkBox then
		checkBox:setSelectedState(check or false)
	end
end

function BaseChooseItem:isSelectedStatus(  )
	local checkBox = self:getCheckBoxByName("CheckBox_choose")
	if checkBox then
		return checkBox:getSelectedState()
	end

	return false
end

function BaseChooseItem:_isItemSelected( item, selectedItems )

	if #selectedItems < 1 then
		return false
	end

	for i, v in pairs(selectedItems) do
		if v.id == item.id then
			return true
		end
	end

	return false
end

return BaseChooseItem
