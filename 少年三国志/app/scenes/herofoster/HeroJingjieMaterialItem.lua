--HeroJingjieMaterialItem.lua


local HeroJingjieMaterialItem = class("HeroJingjieMaterialItem",function()
    return CCSItemCellBase:create("ui_layout/HeroShengJie_MaterialItem.json")
end)

function HeroJingjieMaterialItem:ctor(...)
	self:enableLabelStroke("Label_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_jingjie", Colors.strokeBrown, 1 )
end

function HeroJingjieMaterialItem:updateItem( knightId )
	knightId = knightId or 0
	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)
	if knightInfo == nil then
		return 
	end

	local baseId = knightInfo["base_id"]
	local resId = 1
	local knightBaseInfo = nil
	if baseId > 0 then
		knightBaseInfo = knight_info.get(baseId)
	else
		__LogError("baseId is invalid:%d", baseId)
		return 
	end

	if not knightBaseInfo then 
		__LogError("knightinfo is nil for baseId:%d", baseId)
		return 
	end

	local image = self:getImageViewByName("ImageView_item")
	if image then 
		local heroPath = G_Path.getKnightIcon(knightBaseInfo["res_id"] or 1)
    	image:loadTexture(heroPath, UI_TEX_TYPE_LOCAL) 
	end

	image = self:getImageViewByName("Image_item_bg")
	if image then 
		image:loadTexture(G_Path.getAddtionKnightColorImage(knightBaseInfo.quality))  
	end

	local clr = Colors.qualityColors[knightBaseInfo.quality]
	local labelCtrl = self:getLabelByName("Label_name")
	if labelCtrl then
		labelCtrl:setColor(clr)
		labelCtrl:setText(knightBaseInfo.name)
	end

	labelCtrl = self:getLabelByName("Label_jingjie")
	if labelCtrl then 
		local jieshu = knightBaseInfo and knightBaseInfo.advanced_level or 0
		labelCtrl:setColor(clr)
		labelCtrl:setText(jieshu > 0 and ("+"..jieshu) or "")
	end

	self:showTextWithLabel("Label_tianming", G_lang:get("LANG_KNIGHT_GUANZHI_LEVEL", {levelValue = knightInfo.halo_level}))
	self:showTextWithLabel("Label_level", knightInfo and knightInfo["level"] or 1)
end

return HeroJingjieMaterialItem

