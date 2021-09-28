require("app.cfg.treasure_info")
require("app.cfg.treasure_forge_price_info")
require("app.cfg.association_info")
local EffectNode = require "app.common.effects.EffectNode"
local JumpCard = require "app.scenes.common.JumpCard"
local TreasureForgeResult = require("app.scenes.treasure.develope.TreasureForgeResult")
local TreasureForgeConfirm = require("app.scenes.treasure.develope.TreasureForgeConfirm")

local TreasureForgeLayer = class("TreasureForgeLayer", UFCCSNormalLayer)

function TreasureForgeLayer.create(developLayer, ...)
	return require("app.scenes.treasure.develope.TreasureForgeLayer").new("ui_layout/treasure_TreasureForgeLayer.json", developLayer, ...)
end

function TreasureForgeLayer:ctor(json, developLayer, ...)
	self._developLayer = developLayer
	self._isForging = false
	self.super.ctor(self, ...)
end

function TreasureForgeLayer:onLayerLoad()
	-- create strokes
	self:enableLabelStroke("Label_ForgeCost", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Cannot_Forge", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_FateName", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_FateDesc", Colors.strokeBrown, 1)

	for i = 1, 2 do
		self:enableLabelStroke("Label_TreasureName_" .. i, Colors.strokeBrown, 1)
		self:enableLabelStroke("Label_AttrTitle_" .. i, Colors.strokeBrown, 1)

		for j = 1, 2 do
			self:enableLabelStroke("Label_Level_" .. i .. "_" .. j, Colors.strokeBrown, 1)
			self:enableLabelStroke("Label_LevelNum_" .. i .. "_" .. j, Colors.strokeBrown, 1)
			self:enableLabelStroke("Label_1stAttr_" .. i .. "_" .. j, Colors.strokeBrown, 1)
			self:enableLabelStroke("Label_1stAttrNum_" .. i .. "_" .. j, Colors.strokeBrown, 1)
			self:enableLabelStroke("Label_2ndAttr_" .. i .. "_" .. j, Colors.strokeBrown, 1)
			self:enableLabelStroke("Label_2ndAttrNum_" .. i .. "_" .. j, Colors.strokeBrown, 1)
		end
	end

	-- move the treasure up and down
	self:_treasureMove(self:getWidgetByName("Image_Treasure_1"))
	self:_treasureMove(self:getWidgetByName("Image_Treasure_2"))

	-- register button events
	self:registerBtnClickEvent("Button_Forge", handler(self, self._onClickForge))
	self:registerBtnClickEvent("Button_Help", handler(self, self._onClickHelp))

	self:registerWidgetClickEvent("Image_Treasure_1", function()
        if CCDirector:sharedDirector():getSceneCount() > 1 then
            uf_sceneManager:popScene()
    	else
        	uf_sceneManager:replaceScene(require("app.scenes.treasure.TreasureMainScene").new())
    	end
    end)

	-- network message listener
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_TREASURE_FORGE, self._onRcvForge, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECEIVE_CLEAR_FIGHT_TREASURE, self._onRcvUnloadTreasure, self)
end

function TreasureForgeLayer:onLayerExit()
	if self._jumpCardNode ~= nil then 
		self._jumpCardNode:removeFromParentAndCleanup(true)
		self._jumpCardNode = nil
	end

	uf_eventManager:removeListenerWithTarget(self)
end

function TreasureForgeLayer:setCurTreasure(treasure)
	self._curTreasure = treasure
	self:_generateForgeTreasure(treasure)

	self:_initTreasureInfo(false)

	-- 如果当前可铸造，初始化铸造后宝物的属性
	-- 如果不能铸造，隐藏铸造相关的UI
	self:_showUIOnForge(self._forgeTreasure ~= nil)
	if self._forgeTreasure then
		self:_initTreasureInfo(true)
		self:_initForgePrice()
	end
end

-- 从当前宝物生成一个临时的铸造后宝物对象
function TreasureForgeLayer:_generateForgeTreasure(treasure)
	local forgeId = treasure:getInfo().forge_id
	if forgeId == 0 then
		self._forgeTreasure = nil
		return
	end

	self._forgeTreasure = clone(treasure)

	-- 宝物base_id改成铸造后的ID,并重置其baseinfo
	self._forgeTreasure.base_id = forgeId
	self._forgeTreasure._baseInfo = nil

	-- 重新计算强化等级
	local exp = treasure.exp
	local strengthLevel = 1
	while exp > 0 do
		local nextLevelExp = self._forgeTreasure:getStrengthNextLevelExp(strengthLevel)
		if exp >= nextLevelExp then
			strengthLevel = strengthLevel + 1
		end
		exp = exp - nextLevelExp
	end
	self._forgeTreasure.level = strengthLevel
end

function TreasureForgeLayer:_initForgePrice()
	local priceType = self._curTreasure:getInfo().forge_price
	local refLevel  = self._curTreasure.refining_level

	for i = 1, treasure_forge_price_info.getLength() do
		local v = treasure_forge_price_info.get(i)
		if v.type == priceType and v.advance_level == refLevel then
			self:showTextWithLabel("Label_ForgeCost", tostring(v.price))
			self._forgeCost = v.price
		end
	end
end

function TreasureForgeLayer:_initTreasureInfo(isAfterForge)
	local treasure 	= isAfterForge and self._forgeTreasure or self._curTreasure
	local info 		= treasure:getInfo()
	local strLevel 	= treasure.level 			-- 强化等级
	local refLevel 	= treasure.refining_level	-- 精炼等级

	-- 控件后缀
	local postfix = isAfterForge and "_2" or "_1"

	-- 宝物名字和图片
	local nameLabel = self:getLabelByName("Label_TreasureName" .. postfix)
	nameLabel:setText(info.name)
	nameLabel:setColor(Colors.qualityColors[info.quality])

	local pic = G_Path.getTreasurePic(info.res_id)
	local imageWidget = self:getImageViewByName("Image_Treasure" .. postfix)
	imageWidget:loadTexture(pic)
	imageWidget:setOpacity(isAfterForge and 128 or 255)

	-- 若装备在身上，铸造后的宝物信息要显示缘分
	-- PS: 需求有变，目前直接不显示
	local showFate = false --isAfterForge and self._curTreasure:isWearing()
	self:showWidgetByName("Image_FateBg", showFate)
	if showFate then
		-- 找到穿着该宝物的武将index和缘分所需的装备表
		local knightId = self._curTreasure:getWearingKnightId()
		self._team, self._knightSlot = G_Me.formationData:getTeamSlotByKnightId(knightId)
		local requireEquip = G_Me.bagData.knightsData:getRequireEquipJipan(self._knightSlot, info.type) or {}

		-- 找到能触发缘分的宝物ID和缘分ID
		local fateId = 0
		local hasFind = false
		for k, v in pairs(requireEquip) do
			if hasFind then break end
			for k2, v2 in pairs(v) do
				if k2 == info.id then
					fateId = k
					hasFind = true
					break
				end
			end
		end

		-- 设置缘分信息
		local fateInfo = hasFind and association_info.get(fateId) or nil
		local fateName = hasFind and G_lang:get("LANG_KNIGHT_CAN_ACTIVATE_JIBAN", {name = fateInfo.name}) or G_lang:get("LANG_WUSH_NO")
		local fateDesc = hasFind and fateInfo.directions or G_lang:get("LANG_KNIGHT_NO_JIBAN")
		self:showTextWithLabel("Label_FateName", fateName)
		self:showTextWithLabel("Label_FateDesc", fateDesc)
	end

	-- 强化和精炼属性
	local attrs = { treasure:getStrengthAttrs(strLevel), 
					treasure:getRefineAttrs(refLevel) }
	attrs[1].levelString = strLevel .. G_lang:get("LANG_TREASURE_DENGJI")
	attrs[2].levelString = refLevel .. G_lang:get("LANG_JING_LIAN_CURLEVEL2")

	for i = 1, #attrs do
		local attr = attrs[i]
		self:showTextWithLabel("Label_LevelNum" .. postfix .. "_" .. i, attr.levelString)
		self:showTextWithLabel("Label_1stAttr" .. postfix .. "_" .. i, attr[1].typeString .. "：")
		self:showTextWithLabel("Label_1stAttrNum" .. postfix .. "_" .. i, attr[1].valueString)
		self:showTextWithLabel("Label_2ndAttr" .. postfix .. "_" .. i, attr[2].typeString .. "：")
		self:showTextWithLabel("Label_2ndAttrNum" .. postfix .. "_" .. i, "+" .. attr[2].valueString)
	end

	-- 记录下来：
	if isAfterForge then
		self._forgedAttrs = attrs
	else
		self._originAttrs = attrs
	end
end

function TreasureForgeLayer:_treasureMove(image)
	local anime1 = CCMoveBy:create(1, ccp(0,10))
    local anime2 = CCMoveBy:create(1, ccp(0,-10))
    local seqAction = CCSequence:createWithTwoActions(anime1, anime2)
    seqAction = CCRepeatForever:create(seqAction)
    image:runAction(seqAction)
end

function TreasureForgeLayer:_showUIOnForge(isShow)
	self:showWidgetByName("Image_Arrow", isShow)
	self:showWidgetByName("Image_Base_R", isShow)
	self:showWidgetByName("Image_InfoBoard_R", isShow)
	self:showWidgetByName("Panel_Buttons", isShow)

	self:showWidgetByName("Label_Cannot_Forge", not isShow)
end

-- 在铸造结束后，更新一下当前养成页面的宝物
function TreasureForgeLayer:_updateTreasureScene()
	uf_sceneManager:getCurScene():setEquipment(self._curTreasure)
	self:setCurTreasure(self._curTreasure)
	self._isForging = false
end

function TreasureForgeLayer:_onClickForge()
	if self._isForging == false then
		if self._forgeCost > G_Me.userData.gold then
			-- if gold is not enough, show the hint
			require("app.scenes.shop.GoldNotEnoughDialog").show()
		elseif self._curTreasure:isWearing() then
			-- if current treasure is equipped, tell the player it'll be unloaded
			local knightId = self._curTreasure:getWearingKnightId()
			self._team, self._knightSlot = G_Me.formationData:getTeamSlotByKnightId(knightId)

			local panel = TreasureForgeConfirm.create(self._team, self._knightSlot, self._curTreasure:getInfo().type)
			uf_sceneManager:getCurScene():addChild(panel)
		else
			-- if current treasure is not equipped, forge directly
			G_HandlersManager.treasureHandler:sendForgeTreasure(self._curTreasure.id)
			self._isForging = true
		end
	end
end

function TreasureForgeLayer:_onClickHelp()
	require("app.scenes.common.CommonHelpLayer").show(
	{
		{title = G_lang:get("LANG_TREASURE_FORGE"), content = G_lang:get("LANG_TREASURE_FORGE_HELP")},
	})
end

function TreasureForgeLayer:_onRcvForge(result_treasure_id)
	self:setTouchEnabled(false)
	self._developLayer:setTouchEnabled(false)

	-- record the result treasure
	self._curTreasure = G_Me.bagData:getTreasureById(result_treasure_id)

	-- play effects
	local leftImage	 = self:getImageViewByName("Image_Treasure_1")
	local rightImage = self:getImageViewByName("Image_Treasure_2")

	local effect = nil
	effect = EffectNode.new("effect_jingjie", function(event)
		if event == "hide_left" then
			-- 淡出左边的宝物
			transition.fadeTo(leftImage, {time = 0.2, opacity = 0})
			local soundConst = require("app.const.SoundConst")               
    		G_SoundManager:playSound(soundConst.GameSound.KNIGHT_EAT_MATERIAL)
		elseif event == "show_right" then
			-- 淡入右边的宝物
			transition.fadeTo(rightImage, {time = 0.2, opacity = 255})
		elseif event == "fullscreen" then
			-- 全屏显示铸造结果
			local waitFunc = function()
				TreasureForgeResult.show(self._forgeTreasure:getInfo(),
										 self._originAttrs,
										 self._forgedAttrs,
										 function()
										 	if self._jumpCardNode then 
										 		self._jumpCardNode:resume()
										 	end
										 end)	
			end

			local endFunc = function()
				if self._jumpCardNode then
					self._jumpCardNode:removeFromParentAndCleanup(true)
					self._jumpCardNode = nil
				end

				self:_updateTreasureScene()

				self:setTouchEnabled(true)
				self._developLayer:setTouchEnabled(true)
			end

			self._jumpCardNode = JumpCard.createWithTreasure(self._forgeTreasure.base_id,
															 ccp(rightImage:convertToWorldSpaceXY(0, 0)),
															 ccp(leftImage:convertToWorldSpaceXY(0, 0)),
															 leftImage:getScale(), waitFunc, endFunc)
			uf_notifyLayer:getModelNode():addChild(self._jumpCardNode)
		elseif event == "finish" then
			effect:removeFromParentAndCleanup(true)
		end
	end)

	local x, y = leftImage:convertToWorldSpaceXY(0, 0)
	x, y = self:convertToNodeSpaceXY(x, y)
	effect:setPositionXY(x, y)
	self:addChild(effect)
	effect:play()
end

function TreasureForgeLayer:_onRcvUnloadTreasure(ret, teamId, posId, slotId, oldTreasureId)
	if ret == NetMsg_ERROR.RET_OK and 
	   self._team == teamId and 
	   self._knightSlot == posId and 
	   self._curTreasure:getInfo().type == slotId and
	   self._curTreasure.id == oldTreasureId 
	then
	   	G_HandlersManager.treasureHandler:sendForgeTreasure(self._curTreasure.id)
		self._isForging = true
	end
end

function TreasureForgeLayer:onUncheck()

end

return TreasureForgeLayer