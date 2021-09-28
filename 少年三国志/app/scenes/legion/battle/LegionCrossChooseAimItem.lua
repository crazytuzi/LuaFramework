--LegionCrossChooseAimItem.lua


local LegionCrossChooseAimItem = class("LegionCrossChooseAimItem", function ( ... )
	return CCSItemCellBase:create("ui_layout/legion_CrossAimItem.json")
end)


function LegionCrossChooseAimItem:ctor( ... )
	self:enableLabelStroke("Label_level_value", Colors.strokeBrown, 1 )
	self:enableLabelStroke("Label_legion_name", Colors.strokeBrown, 1 )
end

function LegionCrossChooseAimItem:updateItem( index )
	if type(index) ~= "number" then 
		return 
	end

	local enemyInfo = G_Me.legionData:getBattleFieldInfoByIndex(index)
	if not enemyInfo then 
		return 
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
    self:showTextWithLabel("Label_acquire_exp", enemyInfo.rob_exp)
    self:showTextWithLabel("Label_lost_exp", enemyInfo.robbed_exp)

    local check = self:getCheckBoxByName("CheckBox_choose")
    if check then 
    	check:setSelectedState(enemyInfo.fire_on)
    	check:setCheckDisabled(true)
    end

    self:registerCheckboxEvent("CheckBox_choose", function ( widget, eventType, selected )
    	self:_onChooseFireCorp(widget, selected, index)
    end)
end

function LegionCrossChooseAimItem:_onChooseFireCorp( widget, selected, index )
	index = index or 0

	local detailCorp = G_Me.legionData:getCorpDetail() or {}
	if not detailCorp or detailCorp.position < 1 then 
		if selected then 
			widget:setSelectedState(false)
		end
		return G_MovingTip:showMovingTip(G_lang:get("LANG_LEGION_CROSS_CHANGE_BATTLE_AIM_TIP"))
	end

	local enemyInfo = G_Me.legionData:getBattleFieldInfoByIndex(index)
	if selected and enemyInfo then
		G_HandlersManager.legionHandler:sendSetCrossBattleFireOn(enemyInfo.sid, enemyInfo.corp_id)
	end
end

return LegionCrossChooseAimItem

