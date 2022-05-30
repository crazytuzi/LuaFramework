local data_lunjian_lunjian = require("data.data_lunjian_lunjian")
local data_item_item = require("data.data_item_item")

--local HUASHAN_HIGHT = 3420
--local HUASHAN_FLOOR_LIMIT = 15

local HUASHAN_HIGHT = 4380
local HUASHAN_FLOOR_LIMIT = 21

local HUASHAN_FORM_INFO = "huashan_form_info" .. tostring(game.player.m_uid)
local HUASHAN_FLOOR = "huashan_floor" .. tostring(game.player.m_uid)

local BaseScene = require("game.BaseScene")
local HuaShanScene = class("HuaShanScene", BaseScene)

function HuaShanScene:ctor()
	HuaShanScene.super.ctor(self, {
	contentFile = "huashan/huashan_scene.ccbi"
	})
	
	ResMgr.removeBefLayer()
	
	--ÖØÖÃ
	self._rootnode.resetBtn:addHandleOfControlEvent(function()
		self:onReset()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	self._floor = 0
	self._rootnode.infoBtn:addHandleOfControlEvent(function()
		self:onInfo()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	self:createMaskLayer()
	RequestHelper.huashan.state({
	callback = function(data)
		self:refresh(data)
	end,
	errorback = function()
		self.maskLayer:removeSelf()
		self.maskLayer = nil
	end
	})
	
	local floor = CCUserDefault:sharedUserDefault():getIntegerForKey(HUASHAN_FLOOR, 0)
	if floor > 0 then
		local pos = self._rootnode[string.format("posNode_%d", floor - 1)]:convertToWorldSpace(ccp(0, 0))
		local offset = pos.y - self:getBottomHeight() - 140
		self._rootnode.imageBg:setPositionY(-offset)
	end
	
	local curFloorLabel = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@CurrentLevel", 0),
	font = FONTS_NAME.font_fzcy,
	color = cc.c3b(70, 250, 144),
	shadowColor = FONT_COLOR.BLACK,
	size = 22
	})
	ResMgr.replaceKeyLableEx(curFloorLabel, self._rootnode, "curFloorLabel", 0, 0)
	curFloorLabel:align(display.LEFT_CENTER)
	self._maxPosY = 0
	
	self._rootnode.touchNode:setTouchEnabled(true)
	self._rootnode.touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event, x, y)
		if "began" == event.name then
			return true
		elseif "moved" == event.name then
			local posX, posY = self._rootnode.imageBg:getPosition()
			if posY + event.y - event.prevY > 0 then
				self._rootnode.imageBg:setPosition(posX, 0)
			elseif posY + event.y - event.prevY < self._maxPosY then
				self._rootnode.imageBg:setPosition(posX, self._maxPosY)
			else
				self._rootnode.imageBg:setPosition(posX, posY + event.y - event.prevY)
			end
		end
	end,
	1)
	
	local effect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "lunjian_yunceng",
	isRetain = false,
	finishFunc = function()
	end
	})
	self._rootnode.yunNode:addChild(effect, 100)
	self._rootnode.rewardShowBtn:addHandleOfControlEvent(function(sender, eventName)
		local layer = require("game.huashan.HuaShanRewardShow").new({miPageId = 1})
		self:addChild(layer, 100)
	end,
	CCControlEventTouchUpInside)
	
	if ENABLE_HUASHAN_SHOP == true then
		ResMgr.setControlBtnEvent(self._rootnode.shop_btn, function()
			GameStateManager:ChangeState(GAME_STATE.STATE_HUASHAN_SHOP)
		end)
	else
		self._rootnode.shop_btn:setVisible(false)
	end
	self._bExit = false
end

function HuaShanScene:createMaskLayer()
	if self.maskLayer then
		self.maskLayer:removeSelf()
		self.maskLayer = nil
	end
	self.maskLayer = display.newColorLayer(color or cc.c3b(0, 0, 0, 0))
	self.maskLayer:setTouchEnabled(true)
	self.maskLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event, x, y)
		if "began" == event.name then
			return true
		end
	end,
	1)
	
	self.maskLayer:setTouchSwallowEnabled(true)
	self:addChild(self.maskLayer, 1000)
end

function HuaShanScene:showRewardMsg(itemData)
	local title = common:getLanguageString("@Get")
	local msgBox = require("game.Huodong.RewardMsgBox").new({
	title = title,
	cellDatas = itemData,
	confirmFunc = function()
		self._rootnode[string.format("box%d", self._floor)]:removeAllChildren()
		self._rootnode[string.format("box%d", self._floor)]:setDisplayFrame(display.newSpriteFrame(string.format("huashan_box_%d_1.png", data_lunjian_lunjian[self._floor].chest)))
		if self._floor < HUASHAN_FLOOR_LIMIT then
			self:createArrow(self._floor, 1)
		end
	end
	})
	self:addChild(msgBox, 10)
	self._rootnode[string.format("box%d", self._floor)]:setTouchEnabled(true)
end

function HuaShanScene:openBox(index)
	if self._awards[index] then
		show_tip_label(common:getLanguageString("@HintChestGot"))
	elseif self._floor == index then
		self:requestReward()
	else
		show_tip_label(common:getLanguageString("@StageNotBegin"))
	end
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
end

function HuaShanScene:requestReward()
	RequestHelper.huashan.getaward({
	floor = self._floor,
	callback = function(data)
		if data.packetOut and 0 < #data.packetOut then
			local layer = require("utility.LackBagSpaceLayer").new({
			bagObj = data.packetOut
			})
			self:addChild(layer, 10)
		else
			local itemData = {}
			for _, v in ipairs(data.itemAry) do
				local itemInfo = data_item_item[v.id]
				local iconType = ResMgr.getResType(v.t) or ResMgr.ITEM
				table.insert(itemData, {
				id = v.id,
				type = itemInfo.type,
				name = itemInfo.name,
				describe = itemInfo.describe,
				iconType = iconType,
				num = v.n or 0
				})
			end
			table.insert(self._awards, self._floor)
			self:showRewardMsg(itemData)
		end
		game.player:setGold(data.gold)
		game.player:setSilver(data.silver)
		PostNotice(NoticeKey.CommonUpdate_Label_Gold)
		PostNotice(NoticeKey.CommonUpdate_Label_Silver)
	end
	})
end

function HuaShanScene:getReward()
	local bGet = false
	if self._awards then
		for k, v in ipairs(self._awards) do
			if v == self._floor then
				bGet = true
			end
			self._rootnode[string.format("box%d", v)]:setDisplayFrame(display.newSpriteFrame(string.format("huashan_box_%d_1.png", data_lunjian_lunjian[k].chest)))
			self._rootnode[string.format("box%d", v)]:setVisible(true)
		end
	end
	if bGet == false and CCUserDefault:sharedUserDefault():getIntegerForKey("HUASHAN_FLOOR", -1) ~= self._floor then
		CCUserDefault:sharedUserDefault():setIntegerForKey("HUASHAN_FLOOR", self._floor)
		self:showSelfHero(self._floor - 1, true)
		self:createArrow(self._floor)
	else
		local pos, offset
		pos = self._rootnode[string.format("posNode_%d", self._floor)]:convertToWorldSpace(ccp(0, 0))
		offset = pos.y - self:getBottomHeight() - 140
		if math.abs(-(HUASHAN_HIGHT - self:getCenterHeightWithSubTop())) > math.abs(offset) then
			self._rootnode.imageBg:setPositionY(self._rootnode.imageBg:getPositionY() - offset)
		else
			self._rootnode.imageBg:setPositionY(self._rootnode.imageBg:getPositionY() - (HUASHAN_HIGHT - self:getCenterHeightWithSubTop()))
		end
		self._maxPosY = self._rootnode.imageBg:getPositionY()
		self:showSelfHero(self._floor)
		if bGet == false then
			self:createArrow(self._floor)
			self:showOpenEffect()
		else
			self:createArrow(self._floor, 1)
		end
	end
	self._maxPosY = self._rootnode.imageBg:getPositionY()
end

function HuaShanScene:refresh(data)
	self._enemies = data.enemies
	self._heros = HelpLineModel:setHeroHelpState(data.cards)
	self._floor = data.curFloor
	self._resetTimes = data.resetTimes
	self._goldResetTimes = data.goldResetTimes
	self._resetGold = data.resetGold
	self._awards = data.awards
	for i = 1, HUASHAN_FLOOR_LIMIT do
		self._rootnode[string.format("box%d", i)]:setDisplayFrame(display.newSpriteFrame(string.format("huashan_box_%d_3.png", data_lunjian_lunjian[i].chest)))
	end
	table.sort(self._heros, function(l, r)
		return l.star > r.star
	end)
	self._selfInfo = {}
	for k, v in ipairs(self._heros) do
		if v.cardId == 1 or v.cardId == 2 then
			self._selfInfo.cardId = v.cardId
			self._selfInfo.star = v.star
			self._selfInfo.cls = v.cls
		end
		v.resId = v.cardId
	end
	CCUserDefault:sharedUserDefault():setIntegerForKey(HUASHAN_FLOOR, self._floor)
	self._rootnode.freeNumLabel:setString(self._resetTimes)
	if self._floor >= 0 then
		self._rootnode.curFloorLabel:setString(common:getLanguageString("@CurrentLevel", self._floor))
	else
		self._rootnode.curFloorLabel:setString(common:getLanguageString("@CurrentLevel", 0))
	end
	game.player:setGold(data.gold)
	self:refreshHero()
	PostNotice(NoticeKey.CommonUpdate_Label_Gold)
	if self._resetTimes == 0 then
		self._rootnode.resetTitleLabel:setDisplayFrame(display.newSpriteFrame("huashan_reset_vip_num.png"))
		self._rootnode.freeNumLabel:setString(self._goldResetTimes)
	end
	self:nextFloor()
	if self._floor <= 0 then
		self._posHeros[0]:setVisible(true)
	elseif self._floor == 1 and self._awards[1] == nil and CCUserDefault:sharedUserDefault():getIntegerForKey("HUASHAN_FLOOR", -1) ~= self._floor then
		self._posHeros[0]:setVisible(true)
	end
end

function HuaShanScene:showOpenEffect()
	local box = self._rootnode[string.format("box%d", self._floor)]
	local effect
	effect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "fubenjiangli_shanguang",
	isRetain = false,
	finishFunc = function()
	end
	})
	effect:setPosition(box:getContentSize().width / 2, box:getContentSize().height / 2)
	box:addChild(effect)
	effect:setTag(100)
	self._rootnode[string.format("box%d", self._floor)]:setDisplayFrame(display.newSpriteFrame(string.format("huashan_box_%d_2.png", data_lunjian_lunjian[self._floor].chest)))
end

function HuaShanScene:runNextAnim()
	local pos, offset
	pos = self._rootnode[string.format("posNode_%d", self._floor)]:convertToWorldSpace(ccp(0, 0))
	offset = pos.y - self:getBottomHeight() - 140
	local function callFunc()
		self._maxPosY = self._rootnode.imageBg:getPositionY()
		if self.maskLayer then
			self.maskLayer:removeSelf()
			self.maskLayer = nil
		end
		self._posHeros[0]:setVisible(false)
		self:showOpenEffect()
	end
	if math.abs(-(HUASHAN_HIGHT - self:getCenterHeightWithSubTop())) > math.abs(offset) then
		self._rootnode.imageBg:runAction(transition.sequence({
		CCMoveBy:create(1, ccp(0, -offset)),
		CCCallFunc:create(callFunc)
		}))
	else
		self._rootnode.imageBg:runAction(transition.sequence({
		CCMoveBy:create(1, ccp(0, -(HUASHAN_HIGHT - self:getCenterHeightWithSubTop()))),
		CCCallFunc:create(callFunc)
		}))
	end
end

function HuaShanScene:createArrow(index, t)
	if self._arrowNode then
		self._arrowNode:removeChildByTag(100)
	end
	if t == 1 then
		self._arrowNode = self._rootnode[string.format("posNode_%d", index + 1)]
		if self._arrowNode then
			self._arrowNode:setContentSize(cc.size(0, 120))
		else
			return
		end
	else
		self._arrowNode = self._rootnode[string.format("box%d", index)]
	end
	local arrow = display.newSprite("#huashan_arrow.png")
	arrow:setPosition(self._arrowNode:getContentSize().width / 2, self._arrowNode:getContentSize().height + arrow:getContentSize().height / 2)
	self._arrowNode:addChild(arrow)
	arrow:setTag(100)
	arrow:setScale(0.7)
	local move = CCMoveBy:create(0.6, cc.p(0, 30))
	local action = CCRepeatForever:create(CCSequence:createWithTwoActions(move, move:reverse()))
	arrow:runAction(action)
end

function HuaShanScene:showSelfHero(floor, bMove)
	if bMove then
		self._posHeros[floor]:showTmpSelf(self._selfInfo)
		local effectUp = ResMgr.createArma({
		resType = ResMgr.UI_EFFECT,
		armaName = "lunjian_qi",
		isRetain = false,
		finishFunc = function()
			if floor == 0 then
				self._posHeros[floor]:setVisible(false)
			end
			local effectDown = ResMgr.createArma({
			resType = ResMgr.UI_EFFECT,
			armaName = "lunjian_luo",
			isRetain = false,
			finishFunc = function()
				self._posHeros[floor + 1]:showSelfHero(self._selfInfo)
				self:runNextAnim()
			end
			})
			self._posHeros[floor + 1]:addChild(effectDown, 10)
		end
		})
		effectUp:setPosition(0, 0)
		self._posHeros[floor]:addChild(effectUp, 10)
	else
		self._posHeros[floor]:showSelfHero(self._selfInfo)
		self.maskLayer:removeSelf()
		self.maskLayer = nil
	end
end

function HuaShanScene:refreshHero()
	self._posHeros = {}
	for k, v in ipairs(self._enemies) do
		local hero = require("game.huashan.PosHero").new({
		index = k,
		info = v,
		listener = function(index)
			self:chooseEnemy(index)
		end
		})
		self._posHeros[k] = hero
		if k <= HUASHAN_FLOOR_LIMIT then
			self._rootnode[string.format("posNode_%d", k)]:removeChildByTag(10)
			self._rootnode[string.format("posNode_%d", k)]:addChild(hero)
			hero:setTag(10)
		end
		if k <= self._floor then
			hero:failFlag()
		end
	end
	for i = 1, HUASHAN_FLOOR_LIMIT do
		self._rootnode[string.format("box%d", i)]:setTouchEnabled(true)
		self._rootnode[string.format("box%d", i)]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
			if event.name == "began" then
				self._rootnode[string.format("box%d", i)]:setTouchEnabled(false)
				self._rootnode[string.format("box%d", i)]:schedule(function()
					self._rootnode[string.format("box%d", i)]:setTouchEnabled(true)
				end,
				2)
				self:openBox(i)
			end
		end)
	end
	local hero = require("game.huashan.PosHero").new({index = 0})
	hero:setVisible(false)
	self._posHeros[0] = hero
	self._rootnode[string.format("posNode_%d", 0)]:addChild(hero)
	hero:showSelfHero(self._selfInfo)
end

function HuaShanScene:chooseEnemy(index)
	if self._floor > 0 and index > self._floor + 1 or index > 1 and self._floor == -1 then
		show_tip_label(data_error_error[1600009].prompt)
	elseif index == 1 or self._awards[index - 1] then
		local formLayer = require("game.huashan.HuaShanFormLayer").new({
		info = self._enemies[index],
		heros = self._heros,
		floor = self._floor,
		index = index
		})
		self:addChild(formLayer, 10)
	else
		show_tip_label(common:getLanguageString("@HintRewardGet"))
	end
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
end

function HuaShanScene:nextFloor()
	if self._floor > 0 and self._floor <= HUASHAN_FLOOR_LIMIT then
		self:getReward()
	elseif self._floor == 0 or self._floor == -1 then
		self._rootnode.imageBg:setPositionY(0)
		self._maxPosY = self._rootnode.imageBg:getPositionY()
		if self.maskLayer then
			self.maskLayer:removeSelf()
			self.maskLayer = nil
		end
		self:createArrow(0, 1)
	end
end

function HuaShanScene:onInfo()
	local layer = require("game.huashan.HuaShanDescLayer").new()
	self:addChild(layer, 1)
end

function HuaShanScene:onReset()
	if self._floor == -1 then
		show_tip_label(common:getLanguageString("@HintResetNoNeed"))
		return
	end
	if self._resetTimes > 0 then
		local layer = require("game.huashan.HuaShanResetTip").new({
		showType = 0,
		listener = function()
			RequestHelper.huashan.reset({
			
			errorback = function(data)
				show_tip_label(data_error_error[data.errCode].prompt)
			end,
			
			callback = function(data)
				CCUserDefault:sharedUserDefault():setStringForKey(HUASHAN_FORM_INFO, "")
				CCUserDefault:sharedUserDefault():flush()
				self._rootnode[string.format("box%d", self._floor)]:removeAllChildren()
				self:refresh(data)
			end
			})
		end
		})
		self:addChild(layer, 1)
	else
		local layer = require("game.huashan.HuaShanResetTip").new({
		cost = self._resetGold,
		remainNum = self._goldResetTimes,
		showType = 1,
		listener = function()
			if self._goldResetTimes > 0 then
				RequestHelper.huashan.reset({
				callback = function(data)
					CCUserDefault:sharedUserDefault():setStringForKey(HUASHAN_FORM_INFO, "")
					CCUserDefault:sharedUserDefault():flush()
					if 0 < self._floor then
						self._rootnode[string.format("box%d", self._floor)]:removeAllChildren()
					end
					self:refresh(data)
				end,
				gold = self._resetGold
				})
			else
				show_tip_label(common:getLanguageString("@HintResetTimeLack"))
			end
		end
		})
		self:addChild(layer, 1)
	end
end

function HuaShanScene:onEnter()
	HuaShanScene.super.onEnter(self)
	PostNotice(NoticeKey.UNLOCK_BOTTOM)
	GameAudio.playMainmenuMusic(true)
end

function HuaShanScene:onExit()
	HuaShanScene.super.onExit(self)
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return HuaShanScene