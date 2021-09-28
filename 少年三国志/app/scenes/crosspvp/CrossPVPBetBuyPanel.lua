local CrossPVPBetBuyPanel = class("CrossPVPBetBuyPanel", UFCCSModelLayer)

require("app.cfg.crosspvp_bet_info")
local CrossPVPConst = require("app.const.CrossPVPConst")

function CrossPVPBetBuyPanel.show(betType, betTarget)
	local panel = CrossPVPBetBuyPanel.new("ui_layout/crosspvp_BetBuyPanel.json",
		Colors.modelColor, betType, betTarget)
	panel:adapterWithScreen()
	uf_sceneManager:getCurScene():addChild(panel)
end

function CrossPVPBetBuyPanel:ctor(json, color, betType, betTarget)
	self._betType 	= betType 	-- 投注类型：1鲜花 2鸡蛋
	self._betTarget = betTarget -- 投注对象
	self._betCount 	= 1 		-- 当前投注数（初始为1）
	self._unitPrice = 0 		-- 每投一个的价格
	self._totalPrice= 0 		-- 当前总价格
	self._cantBetOne= false 	-- 没钱,连一注都不能投

	self:_initData()

	self.super.ctor(self, json, color)
end

function CrossPVPBetBuyPanel:onLayerLoad()
	local isBetFlower = self._betType == CrossPVPConst.BET_FLOWER

	-- init label text
	local strTitle = G_lang:get(isBetFlower and "LANG_CROSS_PVP_BET_FLOWER" or "LANG_CROSS_PVP_BET_EGG")
	self:showTextWithLabel("Label_BetTitle", strTitle)

	local strAlready = G_lang:get(isBetFlower and "LANG_CROSS_PVP_HAS_BET_FLOWER" or "LANG_CROSS_PVP_HAS_BET_EGG")
	self:showTextWithLabel("Label_AlreadyBet", strAlready .. "：")

	local alreadyBetNum = isBetFlower and G_Me.crossPVPData:getNumBetFlower() or G_Me.crossPVPData:getNumBetEgg()
	self:showTextWithLabel("Label_AlreadyBetNum", tostring(alreadyBetNum))

	-- create strokes
	self:enableLabelStroke("Label_BetTitle", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Add", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_AddTen", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Sub", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_SubTen", Colors.strokeBrown, 1)

	-- register button events
	self:registerBtnClickEvent("Button_Confirm", handler(self, self._onClickConfirm))
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_Cancel", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_AddOne", handler(self, self._onClickAdd))
	self:registerBtnClickEvent("Button_AddTen", handler(self, self._onClickAdd))
	self:registerBtnClickEvent("Button_SubOne", handler(self, self._onClickAdd))
	self:registerBtnClickEvent("Button_SubTen", handler(self, self._onClickAdd))
end

function CrossPVPBetBuyPanel:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)
	self:_updateCountAndPrice(0)
end

function CrossPVPBetBuyPanel:_initData()
	self._unitPrice = crosspvp_bet_info.get(self._betType).price
	self._totalPrice = self._unitPrice * self._betCount
end

function CrossPVPBetBuyPanel:_updateCountAndPrice(countDiff)
	local diff = countDiff or 0
	self._betCount = math.max(1, self._betCount + diff)
	self._totalPrice = self._unitPrice * self._betCount

	-- if my gold is not enough, calculate the max affordable num
	if self._totalPrice > G_Me.userData.gold then
		if self._betCount == 1 then
			self._cantBetOne = true
		else
			self._betCount = math.floor(G_Me.userData.gold / self._unitPrice)
			self._totalPrice = self._unitPrice * self._betCount
		end
	end

	-- set label
	self:showTextWithLabel("Label_BuyCount", tostring(self._betCount))
	self:showTextWithLabel("Label_PriceNum", tostring(self._totalPrice))

	if self._cantBetOne then
		self:getLabelByName("Label_BuyCount"):setColor(Colors.uiColors.RED)
		self:getLabelByName("Label_PriceNum"):setColor(Colors.uiColors.RED)
	end
end

function CrossPVPBetBuyPanel:_onClickAdd(widget)
	if self._cantBetOne then return end

	local diff = widget:getTag()
	self:_updateCountAndPrice(diff)
end

function CrossPVPBetBuyPanel:_onClickConfirm()
	if self._cantBetOne then
		G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_REBORN_GOLD_EMPTY"))
	else
		G_HandlersManager.crossPVPHandler:sendBet(self._betTarget.id, self._betTarget.sid, self._betTarget.battlefield, self._betType, self._betCount)
		self:animationToClose()
	end
end

function CrossPVPBetBuyPanel:_onClickClose()
	self:animationToClose()

	local soundConst = require("app.const.SoundConst")
	G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
end

return CrossPVPBetBuyPanel