--LegionOrderItem.lua


local LegionOrderItem = class("LegionOrderItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_LegionOrderListItem.json")
end)

function LegionOrderItem:ctor( ... )
	self:enableLabelStroke("Label_legion_name", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_level", Colors.strokeBrown, 1 )
end

function LegionOrderItem:updateItem( corpInfo, rankIndex, isLevelRank )
	self:showTextWithLabel("Label_legion_name", corpInfo and corpInfo.name or "")
	self:showTextWithLabel("Label_level", corpInfo and corpInfo.level or 0)
	self:showTextWithLabel("Label_tuanzhang", corpInfo and corpInfo.leader_name or "")
	self:showWidgetByName("Label_dungeon", not isLevelRank)

	local corpsInfo = corps_info.get(corpInfo and corpInfo.level or 0)
	self:showTextWithLabel("Label_count", (corpInfo and corpInfo.size or 0).."/"..(corpsInfo and corpsInfo.number or 0))

	local myRankIndex = isLevelRank and G_Me.legionData:getMyCorpLevelRankIndex() or 
	G_Me.legionData:getMyCorpDungeonRankIndex()
	local panel1Back = self:getPanelByName("Panel_Root")
    local panel2Back = self:getPanelByName("Panel_Info")
    if myRankIndex == rankIndex then 
        panel1Back:setBackGroundImage("board_red.png",UI_TEX_TYPE_PLIST)
        panel2Back:setBackGroundImage("list_board_red.png",UI_TEX_TYPE_PLIST)
    else
        panel1Back:setBackGroundImage("board_normal.png",UI_TEX_TYPE_PLIST)
        panel2Back:setBackGroundImage("list_board.png",UI_TEX_TYPE_PLIST)
    end

	local img = self:getImageViewByName("Image_icon")
    if img then 
        img:loadTexture(G_Path.getLegionIconByIndex(corpInfo and corpInfo.icon_pic or 1))
    end
    img = self:getImageViewByName("Image_legion")
    if img then 
        img:loadTexture(G_Path.getLegionIconBackByIndex(corpInfo and corpInfo.icon_frame or 1))
    end

    rankIndex = rankIndex or 1
    self:showWidgetByName("Image_rank_icon", rankIndex < 4)
    self:showWidgetByName("BitmapLabel_rank_value", rankIndex >= 4)
    if rankIndex < 4 then 
		local img = self:getImageViewByName("Image_rank_icon")
		if img then 
			img:loadTexture(G_Path.getRankTopThreeIcon(rankIndex))
		end
	else
		local rankLabel = self:getLabelBMFontByName("BitmapLabel_rank_value")
		if rankLabel then
			rankLabel:setText(rankIndex)
		end
	end

	if not isLevelRank then 
		require("app.cfg.corps_dungeon_chapter_info")
		local chapterInfo = corps_dungeon_chapter_info.get(corpInfo.chapter_id)
		self:showTextWithLabel("Label_dungeon_count", G_lang:get("LANG_LEGION_DUNGEON_MAP_TITLE_FORMAT", 
    		{chapterIndex = corpInfo.chapter_id, chapterName = chapterInfo and chapterInfo.name or ""}))
	end
end

return LegionOrderItem

