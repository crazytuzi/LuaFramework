local CrossWarBuyPanel = class("CrossWarBuyPanel", UFCCSModelLayer)

require("app.cfg.contest_value_info")
require("app.cfg.shop_price_info")
require("app.cfg.vip_function_info")
require("app.cfg.item_info")
local CrossWarCommon = require("app.scenes.crosswar.CrossWarCommon")

-- 两种购买类型：购买挑战次数，押注
CrossWarBuyPanel.BUY_CHALLENGE 	= 1
CrossWarBuyPanel.BET			= 2

function CrossWarBuyPanel.show(type, ...)
	local panel = CrossWarBuyPanel.new("ui_layout/crosswar_BuyPanel.json", Colors.modelColor, type, ...)
	panel:adapterWithScreen()
	uf_sceneManager:getCurScene():addChild(panel)	
end

function CrossWarBuyPanel:ctor(json, color, type, ...)
	self._type = type

	-- 当前是否为积分赛期间
	self._isScoreMatch = G_Me.crossWarData:isInScoreMatch()

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
end

function CrossWarBuyPanel:onLayerLoad(...)
	-- show associative panels by different type
	self:showWidgetByName("Panel_Info_" .. self._type, true)

	-- set title
	if self._type == CrossWarBuyPanel.BUY_CHALLENGE then
		local strMode = G_lang:get(self._isScoreMatch and "LANG_CROSS_WAR_MODE_1" or "LANG_CROSS_WAR_MODE_2")
		local strTitle = strMode .. G_lang:get("LANG_CROSS_WAR_CHALLENGE_COUNT")
		self:showTextWithLabel("Label_ChallengeCount", strTitle)
	end

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

function CrossWarBuyPanel:onLayerEnter(...)
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- initialize some original data
	self:_initOriginData()

	-- initialize some configuration data to calculate the total price
	self:_initConfigData()

	-- check default number and price
	if self._type == CrossWarBuyPanel.BUY_CHALLENGE then
		self:_checkNumAndPrice(1)
	else
		self:_checkNumOnly(1)
	end
end

-- initialize original data (free challenge count, flower number, etc..)
function CrossWarBuyPanel:_initOriginData()
	-- set title
	local titleImg = G_Path.getTitleTxt( self._type == CrossWarBuyPanel.BUY_CHALLENGE and "goumaitiaozhancishu.png" or "yazhu.png")
	self:getImageViewByName("Image_Title"):loadTexture(titleImg)

	if self._type == CrossWarBuyPanel.BUY_CHALLENGE then
		-- set current free chanllenge count
		local freeCount = G_Me.crossWarData:getChallengeCount()
		self:showTextWithLabel("Label_CurCount", freeCount)

		-- set the remain count you can buy today
		self._remainBuyCount = G_Me.crossWarData:getRemainBuyChallengeCount()
		self:showTextWithLabel("Label_CanBuyCount", self._remainBuyCount)
	else
		-- set flower icon and name
		local itemInfo = item_info.get(CrossWarCommon.ITEM_FLOWER_ID)
		self:getImageViewByName("Image_Icon"):loadTexture(G_Path.getItemIcon(itemInfo.res_id))
		self:showTextWithLabel("Label_ItemName", itemInfo.name)

		-- set current own flower count
		local ownNum = G_Me.bagData:getNumByTypeAndValue(G_Goods.TYPE_ITEM, itemInfo.id)
		self:showTextWithLabel("Label_OwnNum", ownNum)

		-- set the number of flowers already bet
		local betNum = G_Me.crossWarData:getBetNum()
		local limit = CrossWarCommon.getLimitBetNum()
		self:showTextWithLabel("Label_BetNum", betNum .. "/" .. limit)

		self._totalCanBuy = math.min(ownNum, limit - betNum)
	end
end

-- initialize some data to calculate the total price
function CrossWarBuyPanel:_initConfigData()
	if self._type == CrossWarBuyPanel.BUY_CHALLENGE then
		-- total number of times the player can buy
		if self._isScoreMatch then
			local myVip = G_Me.userData.vip
			local vipType = 23 -- 23是vip表中购买积分赛挑战次数的类型
			local vipIndex = 0
			for i = 1, vip_function_info.getLength() do
				local info = vip_function_info.get(i)
				if info.type == vipType then
					if vipIndex == myVip then
						self._totalCanBuy = info.value_1
						break
					end
					vipIndex = vipIndex + 1
				end
			end
		else
			self._totalCanBuy = contest_value_info.get(25).value -- 25是contest_value_info表中争霸赛购买次数上限的ID
		end

		-- cost for each purchase
		local valueId = self._isScoreMatch and 4 or 24 -- 4 和 24 是contest_value_info表中购买积分赛和争霸赛挑战次数的价格的类型ID
		local buyType = contest_value_info.get(valueId).value
		for i = 1, shop_price_info.getLength() do
			local info = shop_price_info.indexOf(i)
			if info.id == buyType then
				self._costList[#self._costList + 1] = {start_times = info.num, cost = info.price}
			end
		end
	end
end

-- 
function CrossWarBuyPanel:_checkNumAndPrice(diff)
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
function CrossWarBuyPanel:_checkNumOnly(diff)
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
function CrossWarBuyPanel:_getPriceOfPurchase(N)
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

function CrossWarBuyPanel:_onClickAdd(widget)
	local diff = widget:getTag()

	if self._type == CrossWarBuyPanel.BUY_CHALLENGE then
		self:_checkNumAndPrice(diff)
	else
		self:_checkNumOnly(diff)
	end
end

function CrossWarBuyPanel:_onClickConfirm()
	if self._canNotBuyOnce then
		if self._type == CrossWarBuyPanel.BUY_CHALLENGE then
			G_MovingTip:showMovingTip(G_lang:get("LANG_RECYCLE_REBORN_GOLD_EMPTY"))
		else
			local itemInfo = item_info.get(CrossWarCommon.ITEM_FLOWER_ID)
			G_MovingTip:showMovingTip(G_lang:get("LANG_NO_ENOUGH_AMOUNT", {item_name = itemInfo.name}))
		end
	else
		if self._type == CrossWarBuyPanel.BUY_CHALLENGE then
			if self._isScoreMatch then
				G_HandlersManager.crossWarHandler:sendCountReset(2, self._buyCount)
			else
				G_HandlersManager.crossWarHandler:sendBuyChallenge(self._buyCount)
			end
		elseif self._type == CrossWarBuyPanel.BET then
			G_HandlersManager.crossWarHandler:sendAddBets(self._buyCount)
		end
	end

	self:animationToClose()
end

function CrossWarBuyPanel:_onClickClose()
	self:animationToClose()

	local soundConst = require("app.const.SoundConst")
	G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
end

return CrossWarBuyPanel