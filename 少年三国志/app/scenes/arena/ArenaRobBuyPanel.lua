-- 争粮战购买界面

local ArenaRobBuyPanel = class("ArenaRobBuyPanel", UFCCSModelLayer)

require("app.cfg.shop_price_info")
require("app.cfg.vip_function_info")
require("app.const.VipConst")

ArenaRobBuyPanel.BUY_ATTACK   = 0
ArenaRobBuyPanel.BUY_REVENGE  = 1

function ArenaRobBuyPanel.show( type, ... )
	local panel = ArenaRobBuyPanel.new("ui_layout/arena_Rob_Buy_Panel.json", Colors.modelColor, type, ...)
	panel:adapterWithScreen()
	uf_sceneManager:getCurScene():addChild(panel)
end

function ArenaRobBuyPanel:ctor( json, color, type, ... )
	self.super.ctor(self, json, color, ...)

	self._type = type

	-- 一个都买不起
	-- self._canNotBuyOne = false
	self._buyCount = 0
	self._remainCanBuy = 0
	self._totalCanBuy = 0
	-- 当前要购买所需的总价
	self._totalCost = 0

	-- 各购买次数区间的价格
	self._costList = {}

end

function ArenaRobBuyPanel:onLayerLoad( ... )
	self:getButtonByName("Button_Add_One"):setTag(1)
	self:getButtonByName("Button_Add_Ten"):setTag(10)
	self:getButtonByName("Button_Sub_One"):setTag(-1)
	self:getButtonByName("Button_Sub_Ten"):setTag(-10)

	self:registerBtnClickEvent("Button_Close", handler(self, self._onClickClose))
	self:registerBtnClickEvent("Button_Add_One", handler(self, self._onClickAdd))
	self:registerBtnClickEvent("Button_Add_Ten", handler(self, self._onClickAdd))
	self:registerBtnClickEvent("Button_Sub_One", handler(self, self._onClickAdd))
	self:registerBtnClickEvent("Button_Sub_Ten", handler(self, self._onClickAdd))
	self:registerBtnClickEvent("Button_Confirm", handler(self, self._onClickConfirm))
	self:registerBtnClickEvent("Button_Cancel", handler(self, self._onClickCancel))

	self._countLabel = self:getLabelByName("Label_Buy_Count")
	self._totalCostLabel = self:getLabelByName("Label_Total_Price")

	self:getLabelByName("Label_Sub_Ten"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Sub_One"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Add_Ten"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Add_One"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Attack_Count"):createStroke(Colors.strokeBrown, 1)
	self:getLabelByName("Label_Revenge_Count"):createStroke(Colors.strokeBrown, 1)

	self._currBuyTimesLabel = self:getLabelByName("Label_Current_Tag")
	self._remainBuyTimesLabel = self:getLabelByName("Label_Can_Buy_Count")
end

function ArenaRobBuyPanel:onLayerEnter( ... )
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
	self:showAtCenter(true)
	self:closeAtReturn(true)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_BUY_RICE_TOKEN, self._onBuyToken, self)	

	if self._type == ArenaRobBuyPanel.BUY_ATTACK then
		self:showWidgetByName("Label_Attack_Count", true)
		self:showWidgetByName("Label_Revenge_Count", false)
	else
		self:showWidgetByName("Label_Attack_Count", false)
		self:showWidgetByName("Label_Revenge_Count", true)
	end

	self:_initOriginData()
	self:_initConfigData()

	-- self._currBuyTimesLabel:setText(self._buyRobTokenTimes)
	-- self._remainBuyTimesLabel:setText(self._remainCanBuy)
	self:_checkNumAndPriceDiff(1)
end

function ArenaRobBuyPanel:_initOriginData( ... )
	

	
end

function ArenaRobBuyPanel:_initConfigData( ... )
	-- total number of times the player can buy
	local myVip = G_Me.userData.vip

	local vipType =  require("app.const.VipConst").ROBRICE	-- 26 挑战次数VIP类型
	local buyType = 16
	local boughtTimes = G_Me.arenaRobRiceData:getBuyRobTokenTimes()

	if self._type == ArenaRobBuyPanel.BUY_REVENGE then
		vipType = require("app.const.VipConst").ROBRICEREVENGE
		buyType = 18
		boughtTimes = G_Me.arenaRobRiceData:getBuyRevTokenTimes()
	else
		-- self:getImageViewByName("Image_Title"):loadTexture(G_Path.getTitleTxt("goumaitiaozhancishu.png"))
	end

	self._totalCanBuy = G_Me.vipData:getData(vipType).value

	-- -- 上面这个方法在VIP为0的时候返回-1，故暂时特殊处理
	-- if myVip == 0 then
	-- 	if self._type == ArenaRobBuyPanel.BUY_ATTACK then
	-- 		self._totalCanBuy = 3
	-- 	else
	-- 		self._totalCanBuy = 1
	-- 	end
	-- end

	self._remainBuyCount = self._totalCanBuy - boughtTimes

	-- cost for each purchase
	for i = 1, shop_price_info.getLength() do
		local info = shop_price_info.indexOf(i)
		if info.id == buyType then
			self._costList[#self._costList + 1] = {start_times = info.num, cost = info.price}
		end
	end

	-- dump(self._costList)
	self._remainBuyTimesLabel:setText(math.max(self._totalCanBuy - (self._buyCount + boughtTimes), 0))

end

function ArenaRobBuyPanel:_onClickClose( ... )
	self:animationToClose()
end

function ArenaRobBuyPanel:_onClickAdd( widget )
	local diff = widget:getTag()

	self:_checkNumAndPriceDiff(diff)
end

function ArenaRobBuyPanel:_checkNumAndPriceDiff( diff )
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
	-- local countLabel = self:getLabelByName("Label_BuyCount")
	-- local priceLabel = self:getLabelByName("Label_PriceNum")
	self._countLabel:setText(tostring(self._buyCount))
	self._totalCostLabel:setText(tostring(self._totalCost))

	-- 当前拥有的次数
	local currTimes = G_Me.arenaRobRiceData:getRobToken()
	-- 已经购买过的次数
	local boughtTimes = G_Me.arenaRobRiceData:getBuyRobTokenTimes()
	if self._type == ArenaRobBuyPanel.BUY_REVENGE then
		currTimes = G_Me.arenaRobRiceData:getRevengeToken()
		boughtTimes = G_Me.arenaRobRiceData:getBuyRevTokenTimes()
	end

	-- 这个次数为当前拥有的次数
	self._currBuyTimesLabel:setText(currTimes)

	-- 一次都买不起的情况，把次数和价格显示为红色
	self._countLabel:setColor(self._canNotBuyOnce and Colors.uiColors.RED or Colors.uiColors.WHITE)
	self._totalCostLabel:setColor(self._canNotBuyOnce and Colors.uiColors.RED or Colors.lightColors.DESCRIPTION)
end

-- 获取第N次购买挑战的价格
function ArenaRobBuyPanel:_getPriceOfPurchase(N)
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

function ArenaRobBuyPanel:_onClickConfirm( ... )
	if self._canNotBuyOnce then
		require("app.scenes.shop.GoldNotEnoughDialog").show()
	else
		G_HandlersManager.arenaHandler:sendBuyRiceToken(self._type, self._buyCount)
	end
end


function ArenaRobBuyPanel:_onClickCancel( ... )
	self:animationToClose()
end

function ArenaRobBuyPanel:_onBuyToken( data )
	if data.ret == 1 then
		G_MovingTip:showMovingTip(G_lang:get("LANG_BUY_SUCCESS"))
		self:animationToClose()
	end
end

return ArenaRobBuyPanel