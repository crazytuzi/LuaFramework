--LegionCrossDistrictItem.lua


local LegionCrossDistrictItem = class("LegionCrossDistrictItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_CrossLegionDetailItem.json")
end)

function LegionCrossDistrictItem:ctor( ... )
	self:enableLabelStroke("Label_level_value", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_legion_name", Colors.strokeBrown, 1 )
end

function LegionCrossDistrictItem:updateItem( index )
	if type(index) ~= "number" then 
		return 
	end

	local enemyInfo = G_Me.legionData:getBattleFieldInfoByIndex(index)
	if not enemyInfo then 
		return 
	end

	local panelBack = self:getPanelByName("Panel_Root")
	local imgBack = self:getImageViewByName("Image_111")
	local detailCorp = G_Me.legionData:getCorpDetail() or {}
	if enemyInfo and detailCorp and enemyInfo.corp_id == detailCorp.id then 
        panelBack:setBackGroundImage("board_red.png",UI_TEX_TYPE_PLIST)
        imgBack:loadTexture("list_board_red.png",UI_TEX_TYPE_PLIST)
    else
        panelBack:setBackGroundImage("board_normal.png",UI_TEX_TYPE_PLIST)
        imgBack:loadTexture("list_board.png",UI_TEX_TYPE_PLIST)
    end

	local img = self:getImageViewByName("Image_legion_icon")
    if img then 
        img:loadTexture(G_Path.getLegionIconByIndex(enemyInfo.icon_pic))
    end
    img = self:getImageViewByName("Image_back_icon")
    if img then 
        img:loadTexture(G_Path.getLegionIconBackByIndex(enemyInfo.icon_frame))
    end

    self:showTextWithLabel("Label_legion_name", enemyInfo.name)
    self:showTextWithLabel("Label_level_value", enemyInfo.level)
    self:showTextWithLabel("Label_server_name", "["..enemyInfo.sname.."]")
    self:showTextWithLabel("Label_acquire_exp", enemyInfo.total_exp)

    self:showTextWithLabel("Label_buff_hp", string.format("+%.1f%%", enemyInfo.total_hp*0.5))
    self:showTextWithLabel("Label_buff_attack", string.format("+%.1f%%", enemyInfo.total_atk*0.5))

end


return LegionCrossDistrictItem

