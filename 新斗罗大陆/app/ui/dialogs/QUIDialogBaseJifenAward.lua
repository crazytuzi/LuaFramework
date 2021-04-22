--
-- Kumo.Wang
-- 积分奖励父类
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogBaseJifenAward = class("QUIDialogBaseJifenAward", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetJifenAward = import("..widgets.QUIWidgetJifenAward")
local QListView = import("...views.QListView")

function QUIDialogBaseJifenAward:ctor(options)
 	local ccbFile = "ccb/Dialog_Base_Jifen_Award.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOneGet", callback = handler(self, self._onTriggerOneGet)},
    }
    QUIDialogBaseJifenAward.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._leftX = -340 -- 左側距離邊框線15像素的x座標
    self._bottomY = -240 -- 底部距離邊框線15像素的y座標
    self._s9sBgWidth = 680 -- s9s_bg的寬度（距離兩邊15像素）

    self.isShowBtnOneGet = true
    self.score = 0
    self.isVertical = true
    self.enableShadow = true
    self.spaceY = -6
end

function QUIDialogBaseJifenAward:viewDidAppear()
    QUIDialogBaseJifenAward.super.viewDidAppear(self)
    -- 預先初始化一下，避免界面空著
    self:setInfo()
end


function QUIDialogBaseJifenAward:viewAnimationInHandler()
    QUIDialogBaseJifenAward.super.viewAnimationInHandler(self)
    -- 正式显示列表
    self._lastSheetY = nil
    self:setInfo()
end

function QUIDialogBaseJifenAward:viewWillDisappear()
    QUIDialogBaseJifenAward.super.viewWillDisappear(self)
end

function QUIDialogBaseJifenAward:setInfo()
end

-- 這個方法只讀
function QUIDialogBaseJifenAward:updateView()
    -- 根據常見情況，自適應排版界面
    self._ccbOwner.descirble1:setAnchorPoint(ccp(0, 1))
    self._ccbOwner.descirble1:setPosition(ccp(self._leftX, 243))

    local descH = self._ccbOwner.descirble1:isVisible() and self._ccbOwner.descirble1:getContentSize().height or 0
    self._ccbOwner.sheet:setPosition(ccp(self._leftX, self._ccbOwner.descirble1:getPositionY() - descH - 10))

    if not self._lastSheetY or self._lastSheetY ~= self._ccbOwner.sheet:getPositionY() then
        self._isResetListView = true
        self._lastSheetY = self._ccbOwner.sheet:getPositionY()
    end

    self._ccbOwner.sheet_layout:setAnchorPoint(ccp(0, 1))
    self._ccbOwner.sheet_layout:setPosition(ccp(0, 0))

    self._ccbOwner.s9s_bg:setAnchorPoint(ccp(0.5, 1))
    self._ccbOwner.s9s_bg:setPosition(ccp(0, self._ccbOwner.sheet:getPositionY()))

    self._ccbOwner.screen_bottom:setAnchorPoint(ccp(0.5, 1))
    self._ccbOwner.screen_bottom:setPreferredSize(CCSize(self._s9sBgWidth, 300))
    self._ccbOwner.screen_top:setAnchorPoint(ccp(0.5, 0))
    self._ccbOwner.screen_top:setPreferredSize(CCSize(self._s9sBgWidth, 300))
    self._ccbOwner.screen_top:setPosition(ccp(0, self._ccbOwner.sheet:getPositionY()))

    if self.isShowBtnOneGet then
        self._ccbOwner.node_btn_oneGet:setVisible(true)
        local btnH = self._ccbOwner.btn_oneGet:getContentSize().height
        self._ccbOwner.node_btn_oneGet:setPosition(ccp(0, self._bottomY + btnH/2))

        self._ccbOwner.s9s_bg:setPreferredSize(CCSize(self._s9sBgWidth, self._ccbOwner.s9s_bg:getPositionY() - (self._bottomY + btnH + 10)))
        self._ccbOwner.screen_bottom:setPosition(ccp(0, self._bottomY + btnH + 10))
    else
        self._ccbOwner.node_btn_oneGet:setVisible(false)
        self._ccbOwner.s9s_bg:setPreferredSize(CCSize(self._s9sBgWidth, self._ccbOwner.s9s_bg:getPositionY() - self._bottomY))
        self._ccbOwner.screen_bottom:setPosition(ccp(0, self._bottomY))
    end
    self._ccbOwner.sheet_layout:setContentSize(CCSize(self._ccbOwner.s9s_bg:getContentSize()))
end

-- 這個方法需要重寫
function QUIDialogBaseJifenAward:updateListViewData()
    self.data = {}
    self:initListView()
end

-- 這個方法只讀
function QUIDialogBaseJifenAward:initListView()
    if self._isResetListView and self._listView ~= nil then
        self._listView:clear()
        self._listView = nil
    end

    self._listViewCfg = {
            renderItemCallBack = handler(self, self.renderItemCallBack),
            isVertical = self.isVertical,
            enableShadow = self.enableShadow,
            spaceY = self.spaceY,
            totalNumber = #self.data
        }
    self:_initListView()
end

function QUIDialogBaseJifenAward:_initListView()
    if self._listView == nil then
        self._listView = QListView.new(self._ccbOwner.sheet_layout, self._listViewCfg)
    else
        self._listView:reload({totalNumber = #self.data})
    end
end

-- 這個方法可以重寫
function QUIDialogBaseJifenAward:renderItemCallBack(list, index, info)
    local isCacheNode = true
    local data = self.data[index]
    local item = list:getItemFromCache()
    if not item then            
        item = QUIWidgetJifenAward.new()
        item:addEventListener(QUIWidgetJifenAward.EVENT_CLICK, handler(self, self.cellClickHandler))
        isCacheNode = false
    end
    item:setInfo(data, self.score)
    info.item = item
    info.size = item:getContentSize()

    list:registerTouchHandler(index, "onTouchListView")
    list:registerBtnHandler(index, "btn_award", "_onTriggerClickAwards", nil, true)

    return isCacheNode
end

function QUIDialogBaseJifenAward:cellClickCallback( event )
end

function QUIDialogBaseJifenAward:onGetCallBack()
end

function QUIDialogBaseJifenAward:cellClickHandler(event)
    self:cellClickCallback(event)
end

function QUIDialogBaseJifenAward:_onTriggerOneGet(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_oneGet) == false then return end
    app.sound:playSound("common_small")
    self:onGetCallBack()
end

function QUIDialogBaseJifenAward:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogBaseJifenAward:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
    app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogBaseJifenAward:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogBaseJifenAward