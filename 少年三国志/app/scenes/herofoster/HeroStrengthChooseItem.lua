--HeroStrengthChooseItem.lua


local HeroStrengthChooseItem = class("HeroStrengthChooseItem", function (  )
	return CCSItemCellBase:create("ui_layout/HeroStrengthen_ChooseItem.json")
end)

function HeroStrengthChooseItem:ctor( ... )
	self._heroKnightId = -1
	self._acquireExp = 0

	self:enableWidgetByName("CheckBox_choose", false)
	self:registerCheckboxEvent("CheckBox_choose", function ( widget, type, isCheck )
		local ret = self:selectedCell(self._heroKnightId, self._acquireExp )
		if isCheck and not ret then
			widget:setSelectedState(false)
		end
	end)

	self:registerCellClickEvent(function ( cell, index )
		local checkbox = self:getCheckBoxByName("CheckBox_choose")
		if checkbox then
			checkbox:setSelectedState(not checkbox:getSelectedState())
			local ret = self:selectedCell(self._heroKnightId, self._acquireExp )
			if checkbox:getSelectedState() and not ret then
				checkbox:setSelectedState(false)
			end		
		end
	end) 

	--self:enableLabelStroke("Label_level", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_jingjie", Colors.strokeBrown, 1 )
	--self:enableLabelStroke("Label_jingjie", Colors.strokeBrown, 1 )
	--self:enableLabelStroke("Label_exp_value", Colors.strokeBrown, 1 )
	--label = self:getLabelByName("Label_exp")
	--if label then
	--	label:createStroke(Colors.strokeBrown, 1)
	--end
	--label = self:getLabelByName("Label_level_title")
	--	if label then 
	--		label:createStroke(Colors.strokeBrown, 1)
	--	end

	self:setTouchEnabled(true)
end

function HeroStrengthChooseItem:updateHeroItem( knightId, selectedKnights )
	if self._heroKnightId == knightId then
		return 
	end

	self:showWidgetByName("ImageView_wearon", false)
	self._heroKnightId = knightId

	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)
	if knightInfo == nil then
		return 
	end

	local baseId = knightInfo["base_id"]
	local resId = 1
	local knightBaseInfo = nil
	if baseId > 0 then
		knightBaseInfo = knight_info.get(baseId)
	end

	if knightBaseInfo ~= nil then
		resId = knightBaseInfo["res_id"]
	else
		__LogError("knightinfo is nil for baseId:%d", baseId)
	end

	local icon = self:getImageViewByName("ImageView_hero_head")
	if icon ~= nil then
		--icon:removeChildByTag(1000, true)
		local heroPath = G_Path.getKnightIcon(resId)
		--local heroSprite = CCSprite:create(heroPath)
    	icon:loadTexture(heroPath, UI_TEX_TYPE_LOCAL) 
	end

	local pingji = self:getImageViewByName("ImageView_pingji")
	if pingji then
    	pingji:loadTexture(G_Path.getAddtionKnightColorImage(knightBaseInfo.quality)) 
    end

	local checkBox = self:getCheckBoxByName("CheckBox_choose")
	if checkBox then
		local selected = self:_isKnightSelected(knightId, selectedKnights)
		checkBox:setSelectedState(selected)
	end

	local name = self:getLabelByName("Label_name")
	if name ~= nil then
		name:setColor(Colors.qualityColors[knightBaseInfo.quality])
		name:setText(knightBaseInfo ~= nil and knightBaseInfo.name or "Default Name")
	end
	--self:showTextWithLabel("Label_zizhi_value", knightBaseInfo.potential)
	--self:showTextWithLabel("Label_jingjie", "+"..knightBaseInfo.advanced_level)
	self:showTextWithLabel("Label_jingjie", knightBaseInfo.advanced_level > 0 and "+"..knightBaseInfo.advanced_level or "")
	--self:showTextWithLabel("Label_level", ""..knightInfo["level"])
	self:showTextWithLabel("Label_level", knightInfo and knightInfo["level"] or 1 )
	self._acquireExp = G_Me.bagData.knightsData:getKnightAcquireExp(knightId)
	self:showTextWithLabel("Label_exp_value", ""..self._acquireExp)

	--GlobalFunc.loadStars(self, 
		--{"ImageView_star_1", "ImageView_star_2","ImageView_star_3","ImageView_star_4","ImageView_star_5", "ImageView_star_6", },
		--knightBaseInfo and knightBaseInfo.quality or 0, 1, G_Path.getListStarIcon())

end

function HeroStrengthChooseItem:checkStrengthItem( check )
	local checkBox = self:getCheckBoxByName("CheckBox_choose")
	if checkBox then
		checkBox:setSelectedState(check or false)
	end
end

function HeroStrengthChooseItem:isSelectedStatus(  )
	local checkBox = self:getCheckBoxByName("CheckBox_choose")
	if checkBox then
		return checkBox:getSelectedState()
	end

	return false
end

function HeroStrengthChooseItem:_isKnightSelected( knightId, selectedKnights )
	if type(selectedKnights) ~= "table" or #selectedKnights < 1 then
		return false
	end

	for i, v in pairs(selectedKnights) do
		if v == knightId then
			return true
		end
	end

	return false
end

return HeroStrengthChooseItem
