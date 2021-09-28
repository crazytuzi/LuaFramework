-- 争粮战领取排行奖励页面

local ArenaRobGetRankAwardLayer = class("ArenaRobGetRankAwardLayer", UFCCSModelLayer)

require("app.cfg.rice_prize_info")
local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function ArenaRobGetRankAwardLayer.show( ... )
	local layer = ArenaRobGetRankAwardLayer.new("ui_layout/arena_RobRiceRankAwardLayer.json", Colors.modelColor, ...)
	uf_notifyLayer:getModelNode():addChild(layer)
end

function ArenaRobGetRankAwardLayer:ctor( json, color, ... )
	self.super.ctor(self, json, color)

	-- self:registerTouchEvent(false, true, 0)
end

function ArenaRobGetRankAwardLayer:onLayerEnter( ... )
	EffectSingleMoving.run(self, "smoving_bounce")
	self:showAtCenter(true)
	self:closeAtReturn(true)

	self._myRank = G_Me.arenaRobRiceData:getRiceRank()
	self:getLabelByName("Label_Rank_Info"):setText(G_lang:get("LANG_ROB_RICE_RANK_AWARD_INFO_1", {rank = self._myRank}))

	local prizeInfo = nil
    local targetAwardInfo = nil
    for i = 1, rice_prize_info.getLength() do
    	prizeInfo = rice_prize_info.get(i)
    	if self._myRank >= prizeInfo.upper_rank and self._myRank <= prizeInfo.lower_rank then    		   		
    		break
    	end
    end
    
	local item1 = G_Goods.convert(prizeInfo.type_1, prizeInfo.value_1)
	local item2 = G_Goods.convert(prizeInfo.type_2, prizeInfo.value_2)
	-- local item3 = G_Goods.convert(prizeInfo.type_3, prizeInfo.value_3)

	self:getImageViewByName("Image_Item_Icon_1"):loadTexture(item1.icon)
	self:getImageViewByName("Image_Item_Icon_2"):loadTexture(item2.icon)
	-- self:getImageViewByName("Image_Item_Icon_3"):loadTexture(item3.icon)

	local sizeLabel1 = self:getLabelByName("Label_Item_Size_1")
	sizeLabel1:createStroke(Colors.strokeBrown, 1)
	sizeLabel1:setText("x" .. prizeInfo.size_1)

	local sizeLabel2 = self:getLabelByName("Label_Item_Size_2")
	sizeLabel2:createStroke(Colors.strokeBrown, 1)
	sizeLabel2:setText("x" .. prizeInfo.size_2)

	-- local sizeLabel3 = self:getLabelByName("Label_Item_Size_3")
	-- sizeLabel3:createStroke(Colors.strokeBrown, 1)
	-- sizeLabel3:setText("x" .. prizeInfo.size_3)
	
	self:getImageViewByName("Image_Item_Border_1"):loadTexture(G_Path.getEquipIconBack(item1.quality))
	self:getImageViewByName("Image_Item_Border_2"):loadTexture(G_Path.getEquipIconBack(item2.quality))
	-- self:getImageViewByName("Image_Item_Border_3"):loadTexture(G_Path.getEquipIconBack(item3.quality))

	self:getImageViewByName("Image_Item_Bg_1"):loadTexture(G_Path.getEquipColorImage(item1.quality, G_Goods.TYPE_ITEM))
	self:getImageViewByName("Image_Item_Bg_2"):loadTexture(G_Path.getEquipColorImage(item2.quality, G_Goods.TYPE_ITEM))
	-- self:getImageViewByName("Image_Item_Bg_3"):loadTexture(G_Path.getEquipColorImage(item3.quality, G_Goods.TYPE_ITEM))	

	
	self:registerBtnClickEvent("Button_Get", function ( ... )
		self:_getAwards()
	end)


	self:registerBtnClickEvent("Button_Close", function ( ... )
		self:animationToClose()
	end)

	-- EffectSingleMoving.run(self:getImageViewByName("Image_Continue"), "smoving_wait", nil , {position = true} )
end


function ArenaRobGetRankAwardLayer:_getAwards( ... )
	G_HandlersManager.arenaHandler:sendGetRiceRankAward()
	self:animationToClose()
end


-- function ArenaRobGetRankAwardLayer:onTouchEnd( xpos, ypos )
--     self:animationToClose()
-- end


return ArenaRobGetRankAwardLayer