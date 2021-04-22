--
-- Kumo.Wang
-- 鼠年春节活动主界面——福卡收集
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRatFestival = class("QUIDialogRatFestival", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")
local QListView = import("...views.QListView")
local QRichText = import("...utils.QRichText")

local QUIWidgetRatFestival = import("..widgets.QUIWidgetRatFestival")

function QUIDialogRatFestival:ctor(options)
	local ccbFile = "ccb/Dialog_RatFestival.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerGoto", callback = handler(self, self._onTriggerGoto)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
        {ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
		-- {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		
	}
	QUIDialogRatFestival.super.ctor(self, ccbFile, callBack, options)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end
    if page.topBar then page.topBar:showWithMainPage() end

    self._ratFestivalModel = remote.activityRounds:getRatFestival()
    if self._ratFestivalModel and self._ratFestivalModel.isOpen then
        self._ratFestivalModel:ratFestivalMainInfoRequest()
    end
    self:_init()
end

function QUIDialogRatFestival:viewDidAppear()
    -- print("QUIDialogRatFestival:viewDidAppear()")
	QUIDialogRatFestival.super.viewDidAppear(self)
	self:addBackEvent(false)

    self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsEventProxy:addEventListener(remote.activityRounds.RAT_FESTIVAL_UPDATE, self:safeHandler(handler(self, self._updateInfo)))

    self._itemProxy = cc.EventProxy.new(remote.items)
    self._itemProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, self:safeHandler(handler(self, self._itemsUpdateEventHandler)))
end

function QUIDialogRatFestival:viewWillDisappear()
    -- print("QUIDialogRatFestival:viewWillDisappear()")
	QUIDialogRatFestival.super.viewWillDisappear(self)
	self:removeBackEvent()

    self._activityRoundsEventProxy:removeAllEventListeners()
    self._itemProxy:removeAllEventListeners()
end

function QUIDialogRatFestival:_resetAll()
    self._ccbOwner.tf_complete_number:setVisible(true)
    self._ccbOwner.tf_complete_number:setString(0)
    self._ccbOwner.tf_total_money:setVisible(true)
    self._ccbOwner.tf_total_money:setString(0)
    self._ccbOwner.node_btn_goto:setVisible(true)
    self._ccbOwner.node_btn_ok:setVisible(false)

    self._ccbOwner.node_sheet_layout:setVisible(true)
    self._ccbOwner.tf_btn_ok:setString("瓜分大奖")
    self._ccbOwner.node_money:setVisible(true)

    self._ccbOwner.sp_btn_goto_redTips:setVisible(false)
    self._ccbOwner.sp_btn_ok_redTips:setVisible(false)

    self._ccbOwner.node_tips:removeAllChildren()
end

function QUIDialogRatFestival:_init()
    self:_resetAll()
    self._data = {}
    if not self._ratFestivalModel then return end

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

    self:_updateInfo()
    self:_itemsUpdateEventHandler()
end

function QUIDialogRatFestival:_itemsUpdateEventHandler()
    if not self._ratFestivalModel then return end
    if not self._ccbOwner.node_money or not self._ccbOwner.node_money:isVisible() then return end

    if not self._luckyCardFragmentItemId then
        self._luckyCardFragmentItemId = self._ratFestivalModel:getLuckyCardFragmentItemId()
        local path = remote.items:getURLForId(self._luckyCardFragmentItemId, "icon_1")
        QSetDisplayFrameByPath(self._ccbOwner.sp_total_money, path)
    end

    local count = remote.items:getItemsNumByID(self._luckyCardFragmentItemId)
    self._ccbOwner.tf_total_money:setString("x"..count)

    if not self._lastTotalMoney or self._lastTotalMoney ~= count then
        -- 遍历一下福卡
        if self._listView then
            local index = 1
            while true do
                local item = self._listView:getItemByIndex(index)
                if item then
                    item:updateState()
                    index = index + 1
                else
                    break
                end
            end
        end
    end
    self._lastTotalMoney = count
end

function QUIDialogRatFestival:_updateInfo()
    if not self._ratFestivalModel then return end

    self._ccbOwner.sp_btn_goto_redTips:setVisible(self._ratFestivalModel:checkTavernBuyRedTips() or self._ratFestivalModel:checkTavernScoreRedTips())
    self._ccbOwner.sp_btn_ok_redTips:setVisible(self._ratFestivalModel:checkFinalRewardRedTips())

    -- 活动时间已过
    if q.serverTime() > self._ratFestivalModel.showEndAt then
        app.tip:floatTip("活动已结束，敬请期待下次活动")
        self:_onTriggerClose()
        return
    end

    local serverInfo = self._ratFestivalModel:getServerInfo()

    self._ccbOwner.tf_complete_number:setString(serverInfo.totalCompleteCount or 0)

    if serverInfo.getFinalReward then
        self._ccbOwner.tf_btn_ok:setString("我的大奖")
    end

    self._data = self._ratFestivalModel:getLuckyCradDataList()
    self:_initListView()

    -- 最後的瓜分大獎只能在endAt～showEndAt之間請求
    -- PS: WARN!!!!  在瓜分大奖的期间，不能去收集福卡（因为，前端这里判断集齐多少福卡去瓜分大奖是根据玩家身上的福卡道具数量来计算，如果瓜分大奖期间还能继续收集，可能出现问题）
    local startTime = self._ratFestivalModel.endAt or 0
    local endTime = self._ratFestivalModel.showEndAt or 0
    local curTime = q.serverTime()
    if curTime >= startTime and curTime <= endTime then
        local hadLuckyCradIdsList = self._ratFestivalModel:getNowHadLuckyCradIdsList()
        if #hadLuckyCradIdsList > 0 then
            self._ccbOwner.node_btn_goto:setVisible(false)
            self._ccbOwner.node_btn_ok:setVisible(true)
        else
            self._ccbOwner.node_btn_goto:setVisible(true)
            self._ccbOwner.node_btn_ok:setVisible(false)
            makeNodeFromNormalToGray(self._ccbOwner.node_btn_goto)
        end
    else
        self._ccbOwner.node_btn_goto:setVisible(true)
        self._ccbOwner.node_btn_ok:setVisible(false)
        makeNodeFromGrayToNormal(self._ccbOwner.node_btn_goto)
    end
end

function QUIDialogRatFestival:_initListView()
    if not self._listView then
        local cfg = {
            renderItemCallBack = function( list, index, info )
                local isCacheNode = true
                local itemData = self._data[index]
                local item = list:getItemFromCache()
                if not item then
                    item = QUIWidgetRatFestival.new()
                    item:addEventListener(QUIWidgetRatFestival.EVENT_CLICK, handler(self, self._cardClickHandler))
                    isCacheNode = false
                end
                item:setInfo(itemData, index, #self._data)
                info.item = item
                info.size = item:getContentSize()

                list:registerBtnHandler(index, "btn_click", "onTriggerClick")

                return isCacheNode
            end,
            isVertical = false,
            enableShadow = false,
            ignoreCanDrag = false,
            autoCenter = true,
            spaceX = 1,
            totalNumber = #self._data,
        }
        self._listView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._listView:reload({totalNumber = #self._data})
    end
end

function QUIDialogRatFestival:_cardClickHandler(e)
    if not self._ratFestivalModel then return end

    local itemId = e.info.id 
    local count = remote.items:getItemsNumByID(itemId)
    if count > 0 then
        -- 已收集
        return
    else
        -- 未收集
        local startTime = self._ratFestivalModel.endAt or 0
        local endTime = self._ratFestivalModel.showEndAt or 0
        local curTime = q.serverTime()
        if curTime >= startTime and curTime <= endTime then
            local serverInfo = self._ratFestivalModel:getServerInfo()
            if serverInfo.getFinalReward then
                app.tip:floatTip("已瓜分大奖，无法再兑换福卡")
                return
            end
        end

        local price = self._ratFestivalModel:getLuckyCardConvertPriceById(itemId)
        local haveMoney
        if self._lastTotalMoney then
            haveMoney = self._lastTotalMoney
        else
            local fragmentItemId = self._ratFestivalModel:getLuckyCardFragmentItemId()
            haveMoney = remote.items:getItemsNumByID(fragmentItemId)
        end
        
        if price and haveMoney >= price then
            -- 请求兑换
            local config = db:getItemByID(itemId)
            local tbl = {}
            table.insert(tbl, {oType = "font", content = "是否花费",size = 22, color = COLORS.j})
            table.insert(tbl, {oType = "font", content = price, size = 22, color = COLORS.k})
            table.insert(tbl, {oType = "font", content = "个福卡碎片，兑换一张",size = 22,color = COLORS.j})
            table.insert(tbl, {oType = "font", content = config.name,size = 22,color = COLORS.k})
            table.insert(tbl, {oType = "font", content = "？",size = 22,color = COLORS.j})

            app:alert({content = tbl, title = "兑换提示", colorful = true, callback = function (callType)
                    if callType == ALERT_TYPE.CONFIRM then
                        self._ratFestivalModel:ratFestivalCombineFokaRequest(itemId)
                    end
                end})
        else
            if price then
                app.tip:floatTip("需要"..price.."福卡碎片合成")
            else
                app.tip:floatTip("福卡碎片不足，无法兑换福卡")
            end
        end
    end
end

function QUIDialogRatFestival:_onTriggerGoto(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_goto) == false then return end
    if not self._ratFestivalModel then return end
    if e then
        app.sound:playSound("common_small")
    end

    local startTime = self._ratFestivalModel.endAt or 0
    local endTime = self._ratFestivalModel.showEndAt or 0
    local curTime = q.serverTime()
    if curTime >= startTime and curTime <= endTime then
        -- 瓜分大獎時間
        app.tip:floatTip("活动时间已过")
        return
    end

    self._ratFestivalModel:setActivityClickedToday()
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRatFestivalTavern", options = {}})
end

function QUIDialogRatFestival:_onTriggerOK(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_ok) == false then return end
    if e then
        app.sound:playSound("common_small")
    end
    if self._ratFestivalModel then
        -- 最後的瓜分大獎只能在endAt～showEndAt之間請求
        local startTime = self._ratFestivalModel.endAt or 0
        local endTime = self._ratFestivalModel.showEndAt or 0
        local curTime = q.serverTime()
        if curTime >= startTime and curTime <= endTime then
            local serverInfo = self._ratFestivalModel:getServerInfo()
            local hadLuckyCradIdsList = self._ratFestivalModel:getNowHadLuckyCradIdsList()
            local luckyCardCount = #hadLuckyCradIdsList
            local luckyCradDataList = self._ratFestivalModel:getLuckyCradDataList()
            local isGetAllCard = luckyCardCount == #luckyCradDataList
            local callback = function()
                        if self:safeCheck() then
                            self:_updateInfo()
                        end
                    end
            if serverInfo.getFinalReward then
                local awardCount = serverInfo.finalRewardCount or 0
                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRatFestivalCongratulate", 
                    options = {luckyCardCount = luckyCardCount, awardCount = awardCount, isGetAllCard = isGetAllCard, callback = callback}})
            else
                if isGetAllCard then
                    -- 全部集齊，直接瓜分
                    self._ratFestivalModel:ratFestivalFinalPrizeRequest(function(data)
                            if data and data.ratFestivalInfoResponse and data.ratFestivalInfoResponse.userInfo then
                                local info = data.ratFestivalInfoResponse.userInfo or {}
                                local awardCount = info.finalRewardCount
                                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRatFestivalCongratulate", 
                                    options = {luckyCardCount = luckyCardCount, awardCount = awardCount, isGetAllCard = isGetAllCard, callback = callback}})
                            end
                        end)
                else
                    local isNeedAlert = false
                    for _, value in ipairs(luckyCradDataList) do
                        local count = remote.items:getItemsNumByID(value.id)
                        if count == 0 then
                            local price = self._ratFestivalModel:getLuckyCardConvertPriceById(value.id)
                            local moneyId = self._ratFestivalModel:getLuckyCardFragmentItemId()
                            local haveMoney = remote.items:getItemsNumByID(moneyId)
                            if haveMoney >= price then
                                isNeedAlert = true
                                break
                            end
                        end
                    end
                    if isNeedAlert then
                        -- 尚有可兌換的福卡，提示確認
                        local tbl = {}
                        table.insert(tbl, {oType = "font", content = "有",size = 22, color = COLORS.j})
                        table.insert(tbl, {oType = "font", content = "可合成", size = 22, color = COLORS.k})
                        table.insert(tbl, {oType = "font", content = "的福卡，可瓜分",size = 22,color = COLORS.j})
                        table.insert(tbl, {oType = "font", content = "更多奖励",size = 22,color = COLORS.k})
                        table.insert(tbl, {oType = "font", content = "，是否确定直接瓜分？",size = 22,color = COLORS.j})
                        app:alert({content = tbl, title = "开奖提示", colorful = true, callback = function (callType)
                                if callType == ALERT_TYPE.CONFIRM then
                                    if self:safeCheck() then
                                        self._ratFestivalModel:ratFestivalFinalPrizeRequest(function(data)
                                            if data and data.ratFestivalInfoResponse and data.ratFestivalInfoResponse.userInfo then
                                                local info = data.ratFestivalInfoResponse.userInfo or {}
                                                local awardCount = info.finalRewardCount
                                                app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRatFestivalCongratulate", 
                                                    options = {luckyCardCount = luckyCardCount, awardCount = awardCount, isGetAllCard = isGetAllCard, callback = callback}})
                                            end
                                        end)
                                    end
                                end
                            end})
                    else
                        -- 雖然尚未集齊，但是也沒有足夠碎片兌換，直接瓜分
                        self._ratFestivalModel:ratFestivalFinalPrizeRequest(function(data)
                                if data and data.ratFestivalInfoResponse and data.ratFestivalInfoResponse.userInfo then
                                    local info = data.ratFestivalInfoResponse.userInfo or {}
                                    local awardCount = info.finalRewardCount
                                    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRatFestivalCongratulate", 
                                        options = {luckyCardCount = luckyCardCount, awardCount = awardCount, isGetAllCard = isGetAllCard, callback = callback}})
                                end
                            end)
                    end
                end
               
            end
        elseif curTime < startTime then
            app.tip:floatTip("尚未到开奖时间，请稍后再试")
        else
            app.tip:floatTip("活动已结束，敬请期待下次活动")
            self:_onTriggerClose()
        end
    else
        self:_onTriggerClose()
    end
end

function QUIDialogRatFestival:_onTriggerHelp(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_help) == false then return end
    if e then
        app.sound:playSound("common_small")
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogRatFestivalHelp", options = {helpType = "help_20Festival"}})
end

-- function QUIDialogRatFestival:onTriggerBackHandler()
--     self:_onTriggerClose()
-- end

function QUIDialogRatFestival:_onTriggerClose()
	self:popSelf()
end

function QUIDialogRatFestival:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogRatFestival:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

return QUIDialogRatFestival