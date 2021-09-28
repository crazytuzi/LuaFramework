-- 争粮战排行奖励的条目

local ArenaRobRiceAwardCell = class("ArenaRobRiceAwardCell", function ( ... )
	return CCSItemCellBase:create("ui_layout/arena_RobRiceRankingAwardItem.json")
end)


function ArenaRobRiceAwardCell:ctor( ... )
	-- body
end



function ArenaRobRiceAwardCell:updateCell( awardInfo )
	__Log("===========ArenaRobRiceAwardCell:updateCell============")

	if awardInfo == nil then return end

	local upperRank = awardInfo.upper_rank
	local lowerRank = awardInfo.lower_rank

	local rankAreaText = G_lang:get("LANG_ROB_RICE_RANK_AWARD_CELL_TIPS_1")
	if upperRank == lowerRank then
		rankAreaText = G_lang:get("LANG_ROB_RICE_RANK_AWARD_CELL_TIPS_2", {rank = upperRank})
	else
		rankAreaText = G_lang:get("LANG_ROB_RICE_RANK_AWARD_CELL_TIPS_3", {rank1 = upperRank, rank2 = lowerRank})
	end

	local rankAreaLabel = self:getLabelByName("Label_Rank_Area")
	rankAreaLabel:setText(rankAreaText)

	local item1 = G_Goods.convert(awardInfo.type_1, awardInfo.value_1)
	local item2 = G_Goods.convert(awardInfo.type_2, awardInfo.value_2)
	-- local item3 = G_Goods.convert(awardInfo.type_3, awardInfo.value_3)

	self:getImageViewByName("Image_Icon_1"):loadTexture(item1.icon)
	self:getImageViewByName("Image_Icon_2"):loadTexture(item2.icon)
	-- self:getImageViewByName("Image_Icon_3"):loadTexture(item3.icon)

	local sizeLabel1 = self:getLabelByName("Label_Size_1")
	sizeLabel1:createStroke(Colors.strokeBrown, 1)
	sizeLabel1:setText("x" .. awardInfo.size_1)

	local sizeLabel2 = self:getLabelByName("Label_Size_2")
	sizeLabel2:createStroke(Colors.strokeBrown, 1)
	sizeLabel2:setText("x" .. awardInfo.size_2)

	-- local sizeLabel3 = self:getLabelByName("Label_Size_3")
	-- sizeLabel3:createStroke(Colors.strokeBrown, 1)
	-- sizeLabel3:setText("x" .. awardInfo.size_3)
	
	self:getImageViewByName("Image_Border_1"):loadTexture(G_Path.getEquipIconBack(item1.quality))
	self:getImageViewByName("Image_Border_2"):loadTexture(G_Path.getEquipIconBack(item2.quality))
	-- self:getImageViewByName("Image_Border_3"):loadTexture(G_Path.getEquipIconBack(item3.quality))

	self:getImageViewByName("Image_Bg_1"):loadTexture(G_Path.getEquipColorImage(item1.quality, G_Goods.TYPE_ITEM))
	self:getImageViewByName("Image_Bg_2"):loadTexture(G_Path.getEquipColorImage(item2.quality, G_Goods.TYPE_ITEM))
	-- self:getImageViewByName("Image_Bg_3"):loadTexture(G_Path.getEquipColorImage(item3.quality, G_Goods.TYPE_ITEM))

	self:registerWidgetClickEvent("Image_Icon_1", function ( ... )
		__Log("Image_Bg_1 clicked")
		require("app.scenes.common.dropinfo.DropInfo").show(item1.type, item1.value) 
	end)
	self:registerWidgetClickEvent("Image_Icon_2", function ( ... )
		__Log("Image_Bg_2 clicked")
		require("app.scenes.common.dropinfo.DropInfo").show(item2.type, item2.value) 
	end)

end







return ArenaRobRiceAwardCell






