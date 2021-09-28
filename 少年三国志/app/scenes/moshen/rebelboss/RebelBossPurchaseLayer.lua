require("app.cfg.shop_price_info")
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local VipConst = require("app.const.VipConst")

local RebelBossPurchaseLayer = class("RebelBossPurchaseLayer", UFCCSModelLayer)

-- 两种购买类型：购买挑战次数，押注
RebelBossPurchaseLayer.BUY_CHALLENGE 	= 1
RebelBossPurchaseLayer.BET			= 2

-- 在vip_function_info表中，购买积分赛挑战次数的特权类型
local VIP_BUY_CHALLENGE_TYPE = 25

function RebelBossPurchaseLayer.show(...)
	local panel = RebelBossPurchaseLayer.new("ui_layout/moshen_RebelBossBuyPanel.json", Colors.modelColor, ...)
	panel:adapterWithScreen()
	uf_sceneManager:getCurScene():addChild(panel)	
end

function RebelBossPurchaseLayer:ctor(json, color, ...)
	-- 当前vip等级总共可买的数量或次数（免费挑战次数，鲜花数量）
	self._totalCanBuy = 0

	-- 当前要购买的次数
	self._buyCount = 0

	-- 剩余可购买的数量或次数（免费挑战次数，鲜花数量）
	self._remainBuyCount = 0

	-- 当前要购买所需的总价
	self._totalCost = 0

	-- 一次都买不起的标记
	self._canNotBuyOnce = false

	-- 各购买次数区间的价格
	self._costList = {}

	self.super.ctor(self, json, color, ...)

	self:_initFixedData()
end

function RebelBossPurchaseLayer:onLayerLoad(...)
	self:showWidgetByName("Panel_Info_1", true)

	-- create strokes
	self:enableLabelStroke("Label_ChallengeCount", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_Add", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_AddTen", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_Sub", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_SubTen", Colors.strokeBrown, 2)
	self:enableLabelStroke("Label_ItemName", Colors.strokeBrown, 2)

	-- register button events
	self:registerBtnClickEvent("Button_Confirm", handler(self, self._onClickConfirm))
	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_Cancel", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_AddOne", handler(self, self._onClickAdd))
	self:registerBtnClickEvent("Button_AddTen", handler(self, self._onClickAdd))
	self:registerBtnClickEvent("Button_SubOne", handler(self, self._onClickAdd))
	self:registerBtnClickEvent("Button_SubTen", handler(self, self._onClickAdd))
end

function RebelBossPurchaseLayer:onLayerEnter(...)
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- initialize some original data
	self:_initOriginData()

	-- initialize some configuration data to calculate the total price
	self:_initConfigData()

	-- check default number and price
	self:_checkNumAndPrice(1)

	require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")
end

function RebelBossPurchaseLayer:_initFixedData()
	CommonFunc._updateLabel(self, "Label_ChallengeCount", {text=G_lang:get("LANG_REBEL_BOSS_CHALLENGE_TIME_TITLE"), stroke=Colors.strokeBrown, size=2})

end

-- initialize original data (free challenge count, flower number, etc..)
function RebelBossPurchaseLayer:_initOriginData()
	-- set title
--	local titleImg = G_Path.getTitleTxt("goumaitiaozhancishu.png")
--	self:getImageViewByName("Image_Title"):loadTexture(titleImg)

	-- set current free chanllenge count
	local freeCount = G_Me.moshenData:getChallengeTime()
	self:showTextWithLabel("Label_CurCount", freeCount)

	-- set the remain count you can buy today
	self._remainBuyCount = G_Me.moshenData:getRemainPurchaseTime()
	self:showTextWithLabel("Label_CanBuyCount", self._remainBuyCount)
end

-- initialize some data to calculate the total price
function RebelBossPurchaseLayer:_initConfigData()
	-- total number of times the player can buy
	self._totalCanBuy = G_Me.vipData:getData(VipConst.REBELBOSS).value

	-- cost for each purchase
	local buyType = 13
	for i = 1, shop_price_info.getLength() do
		local info = shop_price_info.indexOf(i)
		if info.id == buyType then
			self._costList[#self._costList + 1] = {start_times = info.num, cost = info.price}
		end
	end
end

-- 
function RebelBossPurchaseLayer:_checkNumAndPrice(diff)
	-- 之前计算出一次都买不起，直接返回
	if self._canNotBuyOnce then
		return
	end

	-- 当前要购买的是第几次
	local curBuyNo = self._totalCanBuy - self._remainBuyCount + self._buyCount

	-- 判断价格和购买次数
	local from = diff > 0 and 1 or -1
	local step = diff > 0 and 1 or -1
	self._canNotBuyOnce = false
	for i = from, diff, step do
		-- 如果购买次数超出范围，跳出循环
		local buyCount = self._buyCount + step
		if buyCount < 1 or buyCount > self._remainBuyCount then
			break
		end

		-- 获取这一次购买的价格
		curBuyNo = curBuyNo + step
		local price = self:_getPriceOfPurchase(step > 0 and curBuyNo or curBuyNo + 1)
		local curCost = self._totalCost + price * step


		-- 如果价格超出了本钱，跳出循环
		if curCost > G_Me.userData.gold then
			-- 一次都买不起，但仍然设置一下次数和价格
			if buyCount == 1 then
				self._canNotBuyOnce = true
				self._buyCount = buyCount
				self._totalCost = curCost
			end
			break
		end

		self._buyCount = buyCount
		self._totalCost = curCost
	end

	-- __Log("self._totalCanBuy = %d, self._remainBuyCount = %d, self._buyCount = %d", self._totalCanBuy, self._remainBuyCount, self._buyCount)

	-- 设置当前的次数和价格
	local countLabel = self:getLabelByName("Label_BuyCount")
	local priceLabel = self:getLabelByName("Label_PriceNum")
	countLabel:setText(tostring(self._buyCount))
	priceLabel:setText(tostring(self._totalCost))

	-- 一次都买不起的情况，把次数和价格显示为红色
	countLabel:setColor(self._canNotBuyOnce and Colors.uiColors.RED or Colors.uiColors.WHITE)
	priceLabel:setColor(self._canNotBuyOnce and Colors.uiColors.RED or Colors.lightColors.DESCRIPTION)
end

-- 这个函数只有在类型为押注时才调用，检查押注次数的上下限
function RebelBossPurchaseLayer:_checkNumOnly(diff)
	-- 之前计算出一次都买（押）不起，直接返回
	if self._canNotBuyOnce then
		return
	end

	-- 判断能购买的次数是否超出限制
	if self._totalCanBuy == 0 then
		-- 一次都（买）押不起
		self._canNotBuyOnce = true
		self._buyCount = 1
	else
		self._buyCount = self._buyCount + diff
		self._buyCount = math.min(self._buyCount, self._totalCanBuy)
		self._buyCount = math.max(self._buyCount, 1)
	end

	-- 设置当前的次数
	local countLabel = self:getLabelByName("Label_BuyCount")
	countLabel:setText(tostring(self._buyCount))

	-- 一次都买不起的情况，把次数显示为红色
	countLabel:setColor(self._canNotBuyOnce and Colors.uiColors.RED or Colors.uiColors.WHITE)
end

-- 获取第N次购买挑战的价格
function RebelBossPurchaseLayer:_getPriceOfPurchase(N)
	if N < 1 or N > self._totalCanBuy then
		return 0
	end

	-- 找到本次所属的区间段，返回价格
	for i = 1, #self._costList do
		local nextCostInfo = self._costList[i + 1]
		if not nextCostInfo or nextCostInfo.start_times > N then
			return self._costList[i].cost
		end
	end

	return 0
end

function RebelBossPurchaseLayer:_onClickAdd(widget)
	local diff = widget:getTag()
	if diff == 1 or diff == 10 then
		if self._remainBuyCount == 0 then
			G_GlobalFunc.showVipNeedDialog(VipConst.REBELBOSS)
			self:animationToClose()
			return
		end
		if self._canNotBuyOnce then
			G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_REBORN_GOLD_EMPTY"))
			self:animationToClose()
			return
		end
	end
	self:_checkNumAndPrice(diff)
end

function RebelBossPurchaseLayer:_onClickConfirm()
	if self._canNotBuyOnce then
		G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_REBORN_GOLD_EMPTY"))
	else
		if self._remainBuyCount == 0 then
			G_GlobalFunc.showVipNeedDialog(VipConst.REBELBOSS)
		else
			G_HandlersManager.moshenHandler:sendPurchaseAttackCount(self._buyCount)
		end
	end

	self:animationToClose()
end

function RebelBossPurchaseLayer:_onClickClose()
	self:animationToClose()

	local soundConst = require("app.const.SoundConst")
	G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
end

return RebelBossPurchaseLayer