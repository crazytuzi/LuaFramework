--
-- Kumo.Wang
-- 鼠年春节活动——整張福卡展示界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRatFestivalTavernShowCard = class("QUIDialogRatFestivalTavernShowCard", QUIDialog)

local QRichText = import("...utils.QRichText")
local QUIWidgetRatFestival = import("..widgets.QUIWidgetRatFestival")

function QUIDialogRatFestivalTavernShowCard:ctor(options)
    local ccbFile = "ccb/Dialog_RatFestival_Tavern_Show_Card.ccbi"
    local callBacks = {}
    QUIDialogRatFestivalTavernShowCard.super.ctor(self, ccbFile, callBacks, options)   
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page.setAllUIVisible then page:setAllUIVisible(false) end
    if page.setScalingVisible then page:setScalingVisible(false) end

    CalculateUIBgSize(self._ccbOwner.sp_bg)
    
    self._showLuckyCardId = options.showLuckyCardId
    self._callback = options.callback

    self._ratFestivalModel = remote.activityRounds:getRatFestival()

    self._isPlaying = true

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:connectScriptHandler(handler(self, self.viewAnimationEndHandler))
    self._ccbOwner.ccb_card_effect:setVisible(false)
    self._ccbOwner.fca_card_effect:setVisible(false)
    self._animationManager:runAnimationsForSequenceNamed("show_animation")
end

function QUIDialogRatFestivalTavernShowCard:viewAnimationEndHandler(aniName)
    if aniName == "show_animation" then
        self._ccbOwner.ccb_card_effect:setVisible(true)
        self._ccbOwner.fca_card_effect:setVisible(true)
        self._animationManager:runAnimationsForSequenceNamed("end_animation")
    elseif aniName == "end_animation" then
        self._isPlaying = false
        self._ccbOwner.ccb_card_effect:setVisible(true)
        self._ccbOwner.fca_card_effect:setVisible(true)
        self._animationManager:stopAnimation()
    end
end

function QUIDialogRatFestivalTavernShowCard:viewDidAppear()
    QUIDialogRatFestivalTavernShowCard.super.viewDidAppear(self)

    self:_setInfo()
end

function QUIDialogRatFestivalTavernShowCard:viewWillDisappear()
    QUIDialogRatFestivalTavernShowCard.super.viewWillDisappear(self)
end

function QUIDialogRatFestivalTavernShowCard:_setInfo()
    self._ccbOwner.node_card:removeAllChildren()

    if not self._showLuckyCardId or not self._ratFestivalModel then 
        self:_backClickHandler()
        return 
    end

    local luckyCradDataList = self._ratFestivalModel:getLuckyCradDataList()
    local itemData = {}
    for _, value in ipairs(luckyCradDataList) do
        if value.id == self._showLuckyCardId then
            itemData = value
        end
    end
    local item = QUIWidgetRatFestival.new()
    item:setStateDone()
    item:setInfo(itemData, 1, 1)
    self._ccbOwner.node_card:addChild(item)

    -- 設置時間說明，endAt是抽卡結束時間，showEndAt是活動結束，最後的瓜分大獎只能在endAt～showEndAt之間請求
    local endTimeTbl = q.date("*t", (self._ratFestivalModel.endAt or 0) + DAY) -- 整個活動結束時間
    local serverInfo = self._ratFestivalModel:getServerInfo()
    local tipStr = string.format("%d玩家已经集齐，%d月%d日开奖", (serverInfo.totalCompleteCount or 0), endTimeTbl.month, endTimeTbl.day)
    self._ccbOwner.tf_tips:setString(tipStr)
end 

function QUIDialogRatFestivalTavernShowCard:_backClickHandler()
    if self._isPlaying then
        self._animationManager:runAnimationsForSequenceNamed("end_animation")
        return
    else
        local callback = self._callback
        self:popSelf()

        if callback then
            callback()
        end
    end
end

return QUIDialogRatFestivalTavernShowCard