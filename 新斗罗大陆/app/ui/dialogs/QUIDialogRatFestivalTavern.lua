--
-- Kumo.Wang
-- 鼠年春节活动——抽福卡界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRatFestivalTavern = class("QUIDialogRatFestivalTavern", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")
local QUIDialogPreview = import("..dialogs.QUIDialogPreview")
local QUIWidgetRatFestivalTavernProgressBar = import("..widgets.QUIWidgetRatFestivalTavernProgressBar")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText")

function QUIDialogRatFestivalTavern:ctor(options)
	local ccbFile = "ccb/Dialog_RatFestival_Tavern.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerBuyOne", callback = handler(self, self._onTriggerBuyOne)},
		{ccbCallbackName = "onTriggerBuyFive", callback = handler(self, self._onTriggerBuyFive)},
		{ccbCallbackName = "onTriggerPreview", callback = handler(self, self._onTriggerPreview)},
		{ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
    }
    QUIDialogRatFestivalTavern.super.ctor(self, ccbFile, callBacks, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page.setScalingVisible then page:setScalingVisible(true) end
    if page.topBar then page.topBar:showWithRatFestival() end

    CalculateUIBgSize(self._ccbOwner.sp_bg)
    
    self._heroAvatar = {}

    self._ratFestivalModel = remote.activityRounds:getRatFestival()
end

function QUIDialogRatFestivalTavern:viewDidAppear()
	QUIDialogRatFestivalTavern.super.viewDidAppear(self)
	self:addBackEvent()

	self:_initRewardPreview()
	self:_initInfo()
	self:_updateMoneyCount()
	self:_updateProgressBar()
end

function QUIDialogRatFestivalTavern:viewWillDisappear()
  	QUIDialogRatFestivalTavern.super.viewWillDisappear(self)
	self:removeBackEvent()
end

function QUIDialogRatFestivalTavern:_updateMoneyCount()
	local moneyCount = remote.user[ITEM_TYPE.RAT_FESTIVAL_MONEY] or 0
	self._ccbOwner.tf_money:setString(moneyCount.."/1")
	self._ccbOwner.tf_money_five:setString(moneyCount.."/5")
end

function QUIDialogRatFestivalTavern:_initInfo()
	local moneyConfig = remote.items:getWalletByType(ITEM_TYPE.RAT_FESTIVAL_MONEY)
	QSetDisplayFrameByPath(self._ccbOwner.sp_gold_one, moneyConfig.alphaIcon)
	QSetDisplayFrameByPath(self._ccbOwner.sp_gold_five, moneyConfig.alphaIcon)

	self._ccbOwner.node_tips:removeAllChildren()
	-- 設置時間說明，endAt是抽卡結束時間，showEndAt是活動結束，最後的瓜分大獎只能在endAt～showEndAt之間請求
    local startTimeTbl = q.date("*t", (self._ratFestivalModel.startAt or 0))
    local luckyDrawEndTimeTbl = q.date("*t", (self._ratFestivalModel.endAt or 0)) -- 收集福卡結束時間
    local luckyDrawTimeStr = string.format("%d月%d日%02d:%02d～%d月%d日%02d:%02d", 
                                    startTimeTbl.month, startTimeTbl.day, startTimeTbl.hour, startTimeTbl.min, 
                                    luckyDrawEndTimeTbl.month, luckyDrawEndTimeTbl.day, luckyDrawEndTimeTbl.hour, luckyDrawEndTimeTbl.min)

    local endTimeTbl = q.date("*t", (self._ratFestivalModel.endAt or 0) + DAY) -- 整個活動結束時間
    local finalRewardTimeStr = string.format("（%d月%d日瓜分大奖）", endTimeTbl.month, endTimeTbl.day)

    local richText = QRichText.new({
            {oType = "font", size = 22, color = COLORS.b, content = luckyDrawTimeStr},
            {oType = "font", size = 22, color = COLORS.a, content = finalRewardTimeStr},
        })
    richText:setAnchorPoint(ccp(0, 0.5))
    self._ccbOwner.node_tips:addChild(richText)
end

function QUIDialogRatFestivalTavern:_initRewardPreview()
	-- 幸福大奖预览
	local key = self._ratFestivalModel:getTavernPreviewKey()
	local previewInfo = db:getTavernOverViewInfoByTavernType(tostring(key))
	if previewInfo and previewInfo.item_1 then
		local items = string.split(previewInfo.item_1, ";")
		local index = 1
		for i, v in pairs(items) do
			local node = self._ccbOwner["node_itemBox_"..index]
			if node then
				node:removeAllChildren()
				if not db:checkItemShields(v) then
					local itemBox = QUIWidgetItemsBox.new()
					if tonumber(v) then
						itemBox:setGoodsInfo(v, ITEM_TYPE.ITEM, 0)
					else
						itemBox:setGoodsInfo(nil, v, 0)
					end
					itemBox:showItemName()
					itemBox:setPromptIsOpen(true)
					node:addChild(itemBox)
					index = index + 1
				end
			else
				break
			end
		end
	end
end

function QUIDialogRatFestivalTavern:_updateProgressBar()
	if self._widgetProgress then
		if self._widgetProgress.refreshInfo then
			self._widgetProgress:refreshInfo()
			return
		end
	end
	self._ccbOwner.node_progress:removeAllChildren()
	self._widgetProgress = QUIWidgetRatFestivalTavernProgressBar.new()
	self._ccbOwner.node_progress:addChild(self._widgetProgress)
end

function QUIDialogRatFestivalTavern:_isInTime()
	if not self._ratFestivalModel then return end

	local startTime = self._ratFestivalModel.startAt or 0
    local luckyDrawEndTime = self._ratFestivalModel.endAt or 0 -- 收集福卡結束時間
    local curTime = q.serverTime()
    if curTime >= startTime and curTime <= luckyDrawEndTime then
    	return true
    end
    return false
end

function QUIDialogRatFestivalTavern:_onTriggerBuyOne(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_buy_one) == false then return end
	if not self:_isInTime() then
		app.tip:floatTip("抽卡集福活动已经结束，快去瓜分大奖吧～")
		if self:safeCheck() then
			self:onTriggerBackHandler()
		end
		return
	end
	if event ~= nil then app.sound:playSound("common_small") end
	self:goldBuyHandler(1, handler(self, self._onTriggerBuyOne), event.isAgain)
end

function QUIDialogRatFestivalTavern:_onTriggerBuyFive(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_buy_five) == false then return end
	if not self:_isInTime() then
		app.tip:floatTip("抽卡集福活动已经结束，快去瓜分大奖吧～")
		if self:safeCheck() then
			self:onTriggerBackHandler()
		end
		return
	end
	if event ~= nil then app.sound:playSound("common_small") end
	self:goldBuyHandler(5, handler(self, self._onTriggerBuyFive), event.isAgain)
end

function QUIDialogRatFestivalTavern:goldBuyHandler(count, againCallback, isAgain)
	local moneyCount = remote.user[ITEM_TYPE.RAT_FESTIVAL_MONEY] or 0
	if moneyCount >= count then
		self:buyGoldItem(count, againCallback, isAgain)
	else
		QQuickWay:addQuickWay(QQuickWay.RESOUCE_DROP_WAY, ITEM_TYPE.RAT_FESTIVAL_MONEY)
	end
end

function QUIDialogRatFestivalTavern:buyGoldItem(count, againCallback, isAgain)
	local lastLuckyCardIds = self._ratFestivalModel:getNowHadLuckyCradIdsList()
	self._ratFestivalModel:ratFestivalLuckyDrawRequest(count, function(data)
		if self:safeCheck() then
			self:_updateMoneyCount()
			local confirmCallback = function()
				self:_updateProgressBar()
			end
			self._ratFestivalModel:getRatFestivalRewardItemsTips(data.prizes, lastLuckyCardIds, againCallback, confirmCallback, isAgain)
		end
	end)
end

function QUIDialogRatFestivalTavern:_onTriggerPreview(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_preview) == false then return end
    if event ~= nil then app.sound:playSound("common_small") end
    local key = self._ratFestivalModel:getTavernPreviewKey()
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogChestPreview", 
		options = {previewType = key, title = {"福运奖励"}, frameTitleName = "幸福大奖预览"}},{isPopCurrentDialog = false})
end

function QUIDialogRatFestivalTavern:_onTriggerHelp(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_help) == false then return end
    if event ~= nil then app.sound:playSound("common_small") end
	app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRatFestivalHelp", options = {helpType = "help_20Festival_prize"}})
end

function QUIDialogRatFestivalTavern:onTriggerBackHandler()
	local dialog = app:getNavigationManager():getController(app.mainUILayer):getTopDialog()
	if dialog.class.__cname == "QUIDialogRatFestivalTavernAchieve" then
		app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
	end
	app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

-- 返回主界面
function QUIDialogRatFestivalTavern:onTriggerHomeHandler()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogRatFestivalTavern