-- 招财符

local ActivityDailyFortune = class("ActivityDailyFortune", UFCCSNormalLayer)

require "app.cfg.role_info"

ActivityDailyFortune.BOX_NUM = 3
ActivityDailyFortune.PRORESSBAR_MAX = 30
ActivityDailyFortune.BUY_TYPE = 37
ActivityDailyFortune.MAX_VIP = 12
ActivityDailyFortune.BOX_ONE_TIMES = 10
ActivityDailyFortune.BOX_TWO_TIMES = 20
ActivityDailyFortune.BOX_THREE_TIMES = 30
ActivityDailyFortune.MIN_MULTI = 10

local EffectNode = require "app.common.effects.EffectNode"

function ActivityDailyFortune.create( ... )
	local layer = ActivityDailyFortune.new("ui_layout/activity_DailyFortune.json", nil, ...)
	return layer
end


function ActivityDailyFortune:ctor( json, func, ... )
	-- 当日已经发生的招财次数
	self._curTimes = 0
	-- 总共可以购买的次数
	self._totalCanBuy = 0
	-- 各次购买的价格列表
	self._costList = {}
	-- 宝箱状态
	self._boxStatusInfo = {}

	self._needResendBuyMsg = false
	self._timer = nil
	
	self:_initPriceInfo()
	self:_createLabelStrokes()
	self:_registerBtnEvents()

	self._boxEffect1 = nil
	self._boxEffect2 = nil
	self._boxEffect3 = nil
	self._multiImage = nil

	self._effectReady = nil
	self._effectHit = nil
	self:_initEffect()

	self._progressBar = self:getLoadingBarByName("ProgressBar_Fortune")
	self._costLabelTag = self:getLabelByName("Label_Cost_Tag")
	self._costLabel = self:getLabelByName("Label_Cost_Num")
	self._goldImage = self:getImageViewByName("Image_Gold")
	self._timesInfoLabel = self:getLabelByName("Label_Times_Info")
	self._totalMoneyLabel = self:getLabelByName("Label_Money_Num")
	self._multiImage = self:getImageViewByName("Image_Multi")
	self._multiImage:setVisible(false)
	self._willGetMoneyTipsLabel = self:getLabelByName("Label_Will_Get_Num_Tips")

	self.super.ctor(self, json)
end


function ActivityDailyFortune:onLayerEnter(  )
	self:registerKeypadEvent(true)

	if not self._timer then
		self._timer = G_GlobalFunc.addTimer(10, function()
			self:_checkShouldUpdateData()	         
		end)
	end

	G_HandlersManager.activityHandler:sendGetFortuneInfo()

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_FORTUNE_BUY_SUCCEED, self._onBuyFortuneSucceed, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_FORTUNE_GET_BOX_AWARD, self._onGetBoxAward, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ACTIVITY_FORTUNE_GET_INFO, self._onGetFortuneInfo, self)
	-- 充值成功
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECHARGE_SUCCESS, self._onRechargeSuccess, self)

	if self:_checkIsToday() then
		self:_updateWidgets(true)
	end
end

function ActivityDailyFortune:onLayerExit(  )
	self._totalMoneyLabel:stopAllActions()
	self._multiImage:stopAllActions()

	if self._timer then
		GlobalFunc.removeTimer(self._timer)
		self._timer = nil
	end
end

function ActivityDailyFortune:_checkIsToday( ... )
	--如果跨天了则需要重新拉取一下协议
	local detailList = G_Me.activityData.fortune:getFortuneDetailInfo()
	-- dump(detailList)
	-- __Log("[ActivityDailyFortune:_checkIsToday] currtime: " .. G_ServerTime:getTimeString())
	if detailList[#detailList] then
		if not G_ServerTime:isToday(detailList[#detailList].time) then

			G_HandlersManager.activityHandler:sendGetFortuneInfo()

			return false
		end
	end

	return true
end

function ActivityDailyFortune:_updateWidgets( isFirstTime )

	self._curTimes = G_Me.activityData.fortune:getTimes()

	-- 进度条
	self._progressBar:setPercent(self._curTimes/ActivityDailyFortune.PRORESSBAR_MAX * 100)

	-- 总的银两数
	if isFirstTime then
		-- __Log("[ActivityDailyFortune:_updateWidgets] totalMoney: " .. G_Me.activityData.fortune:getTotalMoney())
		self._totalMoneyLabel:setText(G_GlobalFunc.ConvertNumToCharacter(G_Me.activityData.fortune:getTotalMoney()))
	end

	-- 价格与次数信息
	self:_updatePriceAndTimesInfo()

	-- 宝箱
	self:_updateBoxStatus()

	-- 最少可获得银两数
	local moneyInfo = role_info.get(G_Me.userData.level)
	local moneyNum = moneyInfo.fortune_num
	self._willGetMoneyTipsLabel:setText(G_lang:get("LANG_ACTIVITY_FORTUNE_WILL_GET_MONEY_TIPS", {num = moneyNum}))

	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)	
end

function ActivityDailyFortune:_updatePriceAndTimesInfo(  )
	self._costLabelTag:setVisible(false)
	self._timesInfoLabel:setVisible(false)
	self._goldImage:setVisible(false)
	self._costLabel:setPositionX(320)
	self._costLabel:setColor(Colors.darkColors.TITLE_01)
	
	local costNum = 0
	if self._curTimes == 0 or self:_getPrice(self._curTimes) == 0 then
		costNum = G_lang:get("LANG_DROP_KNIGHT_FREE")
	elseif self._curTimes < self._totalCanBuy then
		self._costLabelTag:setVisible(true)
		self._timesInfoLabel:setVisible(true)
		self._goldImage:setVisible(true)
		costNum = self:_getPrice(self._curTimes)
		self._costLabel:setPositionX(312)
		self._timesInfoLabel:setText("(" .. self._curTimes .. "/" .. self._totalCanBuy .. ")")
	else
		costNum = G_lang:get("LANG_ACTIVITY_FORTUNE_NO_BUY_TIMES")
		self._costLabel:setColor(Colors.darkColors.TIPS_01)
	end
	
	self._costLabel:setText(costNum)
end

function ActivityDailyFortune:_updateBoxStatus(  )
	self._boxStatusInfo = G_Me.activityData.fortune:getBoxStatus()

	if not self._boxEffect1 then
		self._boxEffect1 = EffectNode.new("effect_box_light", function ( event, frameIndex )	end)
		self._boxEffect1:setPositionXY(12, 12)
		self:getButtonByName("Button_Box_1"):addNode(self._boxEffect1)
		self._boxEffect1:play()
		self._boxEffect1:setVisible(false)
	end
	if not self._boxEffect2 then
		self._boxEffect2 = EffectNode.new("effect_box_light", function ( event, frameIndex )	end)
		self._boxEffect2:setPositionXY(12, 12)
		self:getButtonByName("Button_Box_2"):addNode(self._boxEffect2)
		self._boxEffect2:play()
		self._boxEffect2:setVisible(false)
	end
	if not self._boxEffect3 then
		self._boxEffect3 = EffectNode.new("effect_box_light", function ( event, frameIndex )	end)
		self._boxEffect3:setPositionXY(12, 12)
		self:getButtonByName("Button_Box_3"):addNode(self._boxEffect3)
		self._boxEffect3:play()
		self._boxEffect3:setVisible(false)
	end

	-- 宝箱
	if self._curTimes >= ActivityDailyFortune.BOX_ONE_TIMES then
		if self._boxStatusInfo[1] then
			self._boxEffect1:setVisible(false)
			self:getButtonByName("Button_Box_1"):loadTextureNormal("ui/dailytask/baoxiangtong_kong.png")
		else
			self:getButtonByName("Button_Box_1"):loadTextureNormal("ui/dailytask/baoxiangtong_kai.png")
			self._boxEffect1:setVisible(true)
		end
	else
		self:getButtonByName("Button_Box_1"):loadTextureNormal("ui/dailytask/baoxiangtong_guan.png")
		self._boxEffect1:setVisible(false)
	end

	if self._curTimes >= ActivityDailyFortune.BOX_TWO_TIMES then
		if self._boxStatusInfo[2] then
			self._boxEffect2:setVisible(false)
			self:getButtonByName("Button_Box_2"):loadTextureNormal("ui/dailytask/baoxiangyin_kong.png")
		else
			self:getButtonByName("Button_Box_2"):loadTextureNormal("ui/dailytask/baoxiangyin_kai.png")
			self._boxEffect2:setVisible(true)
		end
	else
		self:getButtonByName("Button_Box_2"):loadTextureNormal("ui/dailytask/baoxiangyin_guan.png")
		self._boxEffect2:setVisible(false)
	end

	if self._curTimes >= ActivityDailyFortune.BOX_THREE_TIMES then
		if self._boxStatusInfo[3] then
			self._boxEffect3:setVisible(false)
			self:getButtonByName("Button_Box_3"):loadTextureNormal("ui/dailytask/baoxiangjin_kong.png")
		else
			self:getButtonByName("Button_Box_3"):loadTextureNormal("ui/dailytask/baoxiangjin_kai.png")
			self._boxEffect3:setVisible(true)
		end
	else
		self:getButtonByName("Button_Box_3"):loadTextureNormal("ui/dailytask/baoxiangjin_guan.png")
		self._boxEffect3:setVisible(false)
	end
end

function ActivityDailyFortune:_onBuyFortuneBtnClicked(  )
	-- 如果没有网络，就弹出断线重联界面, 然后直接return
	if not G_NetworkManager:isConnected() then
		G_NetworkManager:checkConnection()
	    return
	end

	if not self:_checkIsToday() then
		self._needResendBuyMsg = true
		G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_FORTUNE_DATA_OUTOF_DATE"))
		return
	end	

	self._curTimes = G_Me.activityData.fortune:getTimes()
	if self._curTimes >= self._totalCanBuy then
		local myVip = G_Me.userData.vip
		if myVip >= ActivityDailyFortune.MAX_VIP then
			G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_FORTUNE_NOT_TIMES"))
		else
			G_GlobalFunc.showVipNeedDialog(require("app.const.VipConst").FORTUNE)		
		end
		return
	end

	local cost = self:_getPrice(self._curTimes)
	if cost > G_Me.userData.gold then
		require("app.scenes.shop.GoldNotEnoughDialog").show()
		return
	end
	
	G_HandlersManager.activityHandler:sendFortuneBuySilver()
end


function ActivityDailyFortune:_onBoxClicked( idx, posX, posY )
	if self:_checkIsToday() then
		local boxIdx = tonumber(idx)
		require("app.scenes.activity.ActivityDailyFortuneBoxAwardLayer").show(boxIdx, posX, posY)
	else
		G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_FORTUNE_DATA_OUTOF_DATE"))
	end
end

function ActivityDailyFortune:_onDetailButtonClicked(  )
	if self:_checkIsToday() and self._curTimes > 0 then
		require("app.scenes.activity.ActivityDailyFortuneDetailLayer").show()
	else
		G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_FORTUNE_NO_DETAIL_INFO"))
	end
end

function ActivityDailyFortune:onBackKeyEvent()
	uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
	return true
end

function ActivityDailyFortune:_onBuyFortuneSucceed( data )
	self._multiImage:setVisible(false)
	self._multiImage:stopAllActions()

	self:_playHitEffect()

	G_flyAttribute._clearFlyAttributes()
	-- 如果有暴击
	if data.buy.multi > ActivityDailyFortune.MIN_MULTI then
		G_flyAttribute.addNormalText(G_lang:get("LANG_ACTIVITY_FORTUNE_FLY_MULTI", {num = data.buy.multi/10}), Colors.uiColors.RED)
		self:_playMultiImageAnim()
	end

	G_flyAttribute.addNormalText(G_lang:get("LANG_ACTIVITY_FORTUNE_FLY_MONEY", {num = data.buy.silver}), Colors.uiColors.GREEN)
	
	G_flyAttribute.play(function ( ... )
    	self:_playNumberGrowAnim(data.buy.silver)
    end)

	self:_updateWidgets()
end

function ActivityDailyFortune:_onGetBoxAward( data )
	local layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(data.awards)
    uf_sceneManager:getCurScene():addChild(layer)

    self:_updateWidgets()
end

function ActivityDailyFortune:_onGetFortuneInfo(  )
	-- __Log("[ActivityDailyFortune:_onGetFortuneInfo]")

	self:_updateWidgets(true)

	if self._needResendBuyMsg then
		self._needResendBuyMsg = false
		self:_onBuyFortuneBtnClicked()
	end
end

function ActivityDailyFortune:_onRechargeSuccess(  )
	-- __Log("===============[ActivityDailyFortune:_onRechargeSuccess]===========")
	self:_initPriceInfo()
	G_HandlersManager.activityHandler:sendGetFortuneInfo()
end

function ActivityDailyFortune:_playNumberGrowAnim( increaseNum )
	local totalMoney = G_Me.activityData.fortune:getTotalMoney()
    local growupNumber = CCNumberGrowupAction:create(totalMoney - increaseNum, totalMoney, 0.5, function ( number )
	                        self._totalMoneyLabel:setText(G_GlobalFunc.ConvertNumToCharacter(number))
	                    end)
    local actionScale = CCSequence:createWithTwoActions(CCScaleTo:create(0.5/2, 2), CCScaleTo:create(0.5/2, 1))
    local action = CCSpawn:createWithTwoActions(growupNumber, actionScale)
    self._totalMoneyLabel:runAction(action)
end

-- 初始化购买价格相关信息
function ActivityDailyFortune:_initPriceInfo(  )
	local myVip = G_Me.userData.vip

	-- 次数VIP类型
	local vipType = require("app.const.VipConst").FORTUNE
	local buyType = ActivityDailyFortune.BUY_TYPE

	self._totalCanBuy = G_Me.vipData:getData(vipType).value

	-- cost for each purchase
	self._costList = {}
	for i = 1, shop_price_info.getLength() do
		local info = shop_price_info.indexOf(i)
		if info.id == buyType then
			self._costList[#self._costList + 1] = {start_times = info.num, cost = info.price}
		end
	end
end

-- 获取本次购买的价格
function ActivityDailyFortune:_getPrice( times )
	-- 因为第一次免费
	times = times + 1
	if times < 1 or times > self._totalCanBuy + 1 then
		return 0
	end

	-- 找到本次所属的区间段，返回价格
	for i = 1, #self._costList do
		local nextCostInfo = self._costList[i + 1]
		if not nextCostInfo or nextCostInfo.start_times > times then
			return self._costList[i].cost
		end
	end

	return 0
end

function ActivityDailyFortune:_createLabelStrokes(  )
	-- Labels add stroke
	self:enableLabelStroke("Label_Box_1", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Box_2", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Box_3", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Total_Money_Tag", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Money_Num", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Will_Get_Num_Tips", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Cost_Tag", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Cost_Num", Colors.strokeBrown, 1)
	self:enableLabelStroke("Label_Times_Info", Colors.strokeBrown, 1)
end

function ActivityDailyFortune:_registerBtnEvents(  )
	self:registerBtnClickEvent("Button_Fortune", function (  )
		self:_onBuyFortuneBtnClicked()
	end)

	for i = 1, ActivityDailyFortune.BOX_NUM do
		self:registerBtnClickEvent("Button_Box_" .. i, function ( widget )
			local posBtnNode = self:getButtonByName("Button_Box_" .. i):getPositionInCCPoint()
			local posBtnWorld = widget:getParent():convertToWorldSpace(posBtnNode)
			self:_onBoxClicked(i, posBtnWorld.x, posBtnWorld.y)
		end)
	end

	self:registerBtnClickEvent("Button_Show_Detail", function (  )
		self:_onDetailButtonClicked()
	end)

	self:registerBtnClickEvent("Button_Help", function (  )
		-- test protocal
		-- G_HandlersManager.activityHandler:sendGetFortuneInfo()
		-- G_HandlersManager.activityHandler:sendFortuneBuySilver()
		-- G_HandlersManager.activityHandler:sendFortuneGetBox(2)

		require("app.scenes.common.CommonHelpLayer").show(
		{
			{title = G_lang:get("LANG_ACTIVITY_FORTUNE_HELP_TITLE"), content = G_lang:get("LANG_ACTIVITY_FORTUNE_HELP_CONTENT")}
		})
		
	end)
end

function ActivityDailyFortune:_initEffect(  )
	if not self._effectReady then
		self._effectReady = EffectNode.new("effect_zcf_ready", function ( event, frameIndex )	end)
	end

	if not self._effectHit then
		self._effectHit = EffectNode.new("effect_zcf_hit", 
			function( event, frameIndex )
				if event == "finish" then
					-- 隐藏自己，显示ready特效
					self._effectHit:setVisible(false)
					self._effectReady:setVisible(true)
					self._multiImage:setVisible(false)
				end
			end)
	end

	local parentNode = self:getPanelByName("Panel_Effect")
	parentNode:addNode(self._effectReady)
	self._effectReady:play()

	parentNode:addNode(self._effectHit)
	self._effectHit:setVisible(false)
end

-- 翻倍图片动画
function ActivityDailyFortune:_playMultiImageAnim(  )
	self._multiImage:setVisible(true)
	local actionScale = CCSequence:createWithTwoActions(CCScaleTo:create(0.05, 1.6), CCScaleTo:create(0.3, 1.5))
	self._multiImage:runAction(actionScale)
end

-- 播放招财成功的特效
function ActivityDailyFortune:_playHitEffect(  )
	if self._effectHit then
		self._effectHit:setVisible(true)
		self._effectHit:play()
	end

	if self._effectReady then
		self._effectReady:setVisible(false)
	end
end

-- 检测是否到了第二天
function ActivityDailyFortune:_checkShouldUpdateData(  )
	if G_NetworkManager:isConnected() then
		-- __Log("[ActivityDailyFortune:_checkShouldUpdateData] currtime: " .. G_ServerTime:getTimeString())
		self:_checkIsToday()
	end
end

return ActivityDailyFortune
