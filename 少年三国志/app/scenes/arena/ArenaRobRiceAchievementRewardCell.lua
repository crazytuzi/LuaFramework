-- 成就奖励列表cell

local ArenaRobRiceAchievementRewardCell = class("ArenaRobRiceAchievementRewardCell", function ( ... )
	return CCSItemCellBase:create("ui_layout/arena_RobRiceAchievementRewardCell.json")
end)

function ArenaRobRiceAchievementRewardCell:ctor()
	
end

function ArenaRobRiceAchievementRewardCell:updateCell( achievementInfo, stateInfo, getAchievementCallback )

	self:getLabelByName("Label_Rice_Amount"):setText(G_lang:get("LANG_ROB_RICE_CURR_RICE", {num = achievementInfo.num}))
	self:getLabelByName("Label_Rice_Amount"):createStroke(Colors.strokeBrown, 1)

	local riceNumLack = achievementInfo.num - G_Me.arenaRobRiceData:getTotalRice()

	local item1 = G_Goods.convert(achievementInfo.type_1, achievementInfo.value_1)
	local item2 = G_Goods.convert(achievementInfo.type_2, achievementInfo.value_2)
	-- local item3 = G_Goods.convert(achievementInfo.type_3, achievementInfo.value_3)

	self:getImageViewByName("Image_Icon_1"):loadTexture(item1.icon)
	self:getImageViewByName("Image_Icon_2"):loadTexture(item2.icon)
	-- self:getImageViewByName("Image_Item_Icon_3"):loadTexture(item3.icon)

	local sizeLabel1 = self:getLabelByName("Label_Size_1")
	sizeLabel1:createStroke(Colors.strokeBrown, 1)
	sizeLabel1:setText("x" .. G_GlobalFunc.ConvertNumToCharacter3(achievementInfo.size_1))

	local sizeLabel2 = self:getLabelByName("Label_Size_2")
	sizeLabel2:createStroke(Colors.strokeBrown, 1)
	sizeLabel2:setText("x" .. G_GlobalFunc.ConvertNumToCharacter3(achievementInfo.size_2))

	-- local sizeLabel3 = self:getLabelByName("Label_Item_Size_3")
	-- sizeLabel3:createStroke(Colors.strokeBrown, 1)
	-- sizeLabel3:setText("x" .. achievementInfo.size_3)
	
	self:getImageViewByName("Image_Border_1"):loadTexture(G_Path.getEquipIconBack(item1.quality))
	self:getImageViewByName("Image_Border_2"):loadTexture(G_Path.getEquipIconBack(item2.quality))
	-- self:getImageViewByName("Image_Item_Border_3"):loadTexture(G_Path.getEquipIconBack(item3.quality))

	self:getImageViewByName("Image_Bg_1"):loadTexture(G_Path.getEquipColorImage(item1.quality, G_Goods.TYPE_ITEM))
	self:getImageViewByName("Image_Bg_2"):loadTexture(G_Path.getEquipColorImage(item2.quality, G_Goods.TYPE_ITEM))
	-- self:getImageViewByName("Image_Item_Bg_3"):loadTexture(G_Path.getEquipColorImage(item3.quality, G_Goods.TYPE_ITEM))	

	if stateInfo.state == 0 then
		self:showWidgetByName("Image_Not_Achieve", false)
		self:showWidgetByName("Image_Already_Get", false)
		self:showWidgetByName("Button_Get", true)
		self:registerBtnClickEvent("Button_Get", function ( ... )
			if getAchievementCallback then
				getAchievementCallback()
			end
		end)
	elseif stateInfo.state == 1 then
		self:showWidgetByName("Image_Not_Achieve", false)
		self:showWidgetByName("Image_Already_Get", true)
		self:showWidgetByName("Button_Get", false)
	elseif stateInfo.state == 2 then 
		self:showWidgetByName("Image_Not_Achieve", true)
		self:showWidgetByName("Image_Already_Get", false)
		self:showWidgetByName("Button_Get", false)
	end

	self:registerWidgetClickEvent("Image_Icon_1", function ( ... )
		require("app.scenes.common.dropinfo.DropInfo").show(item1.type, item1.value) 
	end)
	self:registerWidgetClickEvent("Image_Icon_2", function ( ... )
		require("app.scenes.common.dropinfo.DropInfo").show(item2.type, item2.value) 
	end)
end


return ArenaRobRiceAchievementRewardCell