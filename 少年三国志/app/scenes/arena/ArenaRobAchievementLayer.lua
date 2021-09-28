-- 争粮战成就领取弹窗

local ArenaRobAchievementLayer = class("ArenaRobAchievementLayer", UFCCSModelLayer)

require("app.cfg.rice_achievement")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function ArenaRobAchievementLayer.show( ... )
	local layer = ArenaRobAchievementLayer.new("ui_layout/arena_RobRiceAchievementLayer.json", Colors.modelColor, ...)
	uf_sceneManager:getCurScene():addChild(layer)
end

function ArenaRobAchievementLayer:ctor( json, color, ... )
	self.super.ctor(self, json, color)

	-- self:registerTouchEvent(false, true, 0)
end

function ArenaRobAchievementLayer:onLayerEnter( ... )
	EffectSingleMoving.run(self, "smoving_bounce")
	self:showAtCenter(true)
	self:closeAtReturn(true)

	local achievementId = G_Me.arenaRobRiceData:getAchievementId()
	-- achievementId 为上一个一取得过的成就，故需要 + 1
	local achievementInfo = rice_achievement.get(achievementId + 1)

	local riceNumLack = achievementInfo.num - G_Me.arenaRobRiceData:getTotalRice()

	local item1 = G_Goods.convert(achievementInfo.type_1, achievementInfo.value_1)
	local item2 = G_Goods.convert(achievementInfo.type_2, achievementInfo.value_2)
	-- local item3 = G_Goods.convert(achievementInfo.type_3, achievementInfo.value_3)

	self:getImageViewByName("Image_Item_Icon_1"):loadTexture(item1.icon)
	self:getImageViewByName("Image_Item_Icon_2"):loadTexture(item2.icon)
	-- self:getImageViewByName("Image_Item_Icon_3"):loadTexture(item3.icon)

	local sizeLabel1 = self:getLabelByName("Label_Item_Size_1")
	sizeLabel1:createStroke(Colors.strokeBrown, 1)
	sizeLabel1:setText("x" .. achievementInfo.size_1)

	local sizeLabel2 = self:getLabelByName("Label_Item_Size_2")
	sizeLabel2:createStroke(Colors.strokeBrown, 1)
	sizeLabel2:setText("x" .. achievementInfo.size_2)

	-- local sizeLabel3 = self:getLabelByName("Label_Item_Size_3")
	-- sizeLabel3:createStroke(Colors.strokeBrown, 1)
	-- sizeLabel3:setText("x" .. achievementInfo.size_3)
	
	self:getImageViewByName("Image_Item_Border_1"):loadTexture(G_Path.getEquipIconBack(item1.quality))
	self:getImageViewByName("Image_Item_Border_2"):loadTexture(G_Path.getEquipIconBack(item2.quality))
	-- self:getImageViewByName("Image_Item_Border_3"):loadTexture(G_Path.getEquipIconBack(item3.quality))

	self:getImageViewByName("Image_Item_Bg_1"):loadTexture(G_Path.getEquipColorImage(item1.quality, G_Goods.TYPE_ITEM))
	self:getImageViewByName("Image_Item_Bg_2"):loadTexture(G_Path.getEquipColorImage(item2.quality, G_Goods.TYPE_ITEM))
	-- self:getImageViewByName("Image_Item_Bg_3"):loadTexture(G_Path.getEquipColorImage(item3.quality, G_Goods.TYPE_ITEM))	

	if riceNumLack > 0 then
		self:getLabelByName("Label_Rice_Num"):setText(riceNumLack)
	else
		self:showWidgetByName("Panel_Tips", false)
		self:showWidgetByName("Button_Get_Awards", true)
		self:registerBtnClickEvent("Button_Get_Awards", function ( ... )
			self:_getAwards()
		end)
	end

	self:getLabelByName("Label_Buble_Tips"):setText(G_lang:get("LANG_ROB_RICE_ACHIEVEMENT_TIPS_2", {num = achievementInfo.num}))

	self:registerBtnClickEvent("Button_Close", function ( ... )
		self:animationToClose()
	end)

	self:registerWidgetClickEvent("Image_Item_Icon_1", function ( ... )
		require("app.scenes.common.dropinfo.DropInfo").show(item1.type, item1.value) 
	end)
	self:registerWidgetClickEvent("Image_Item_Icon_2", function ( ... )
		require("app.scenes.common.dropinfo.DropInfo").show(item2.type, item2.value) 
	end)

	-- EffectSingleMoving.run(self:getImageViewByName("Image_Continue"), "smoving_wait", nil , {position = true} )
end


function ArenaRobAchievementLayer:_getAwards( ... )
	G_HandlersManager.arenaHandler:sendGetRiceAchievement(G_Me.arenaRobRiceData:getAchievementId() + 1)
	self:animationToClose()
end


function ArenaRobAchievementLayer:onTouchEnd( xpos, ypos )
    self:animationToClose()
end
















return ArenaRobAchievementLayer