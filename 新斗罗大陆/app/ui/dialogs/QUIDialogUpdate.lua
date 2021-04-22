
local QUIDialog = import(".QUIDialog")
local QUIDialogUpdate = class("QUIDialogUpdate", QUIDialog)

local QUIWidgetLoadBar = import("..widgets.QUIWidgetLoadBar")
local QUpdateStaticDatabase = import("....app.network.QUpdateStaticDatabase")
local QUIWidgetLoadingBar = import("..widgets.QUIWidgetLoadingBar")
local QNotificationCenter = import("...controllers.QNotificationCenter")

function QUIDialogUpdate:ctor(options)
    local ccbFile = "ccb/Dialog_EnterGame.ccbi"

    local callbacks = {
        {ccbCallbackName = "onLogin", callback = handler(self, QUIDialogUpdate._onStart)},
    }
    QUIDialogUpdate.super.ctor(self, ccbFile, callbacks, options)

    self._oldPosX = self:getView():getPositionX()
    self._oldGapWidth = display.width - display.ui_width
    self:_reloadCCB()
    
    self._isTouchSwallow = false
    self._ccbOwner.btn_logout:setVisible(false)
    self._ccbOwner.btn_game:setVisible(false)
    self._ccbOwner.node_panel:setVisible(false)
    self._ccbOwner.shadow:setVisible(false)
    self._ccbOwner.label_welcome:getParent():setVisible(false)
    if self._ccbOwner.node_anniversary then
        self._ccbOwner.node_anniversary:setVisible(false)
    end
    --self._ccbOwner.label_enterGame:setString("开始游戏")

    -- self._loadBar = QUIWidgetLoadBar.new()
    -- self._loadBar:setVisible(false)
    -- self._ccbOwner.node_loading:addChild(self._loadBar)

    local x, y = self._ccbOwner.btn_game:getPosition()
    x = x - display.cx
    y = y - display.cy
    self._ccbOwner.btn_game:setPosition(x, y)
    if not FinalSDK.showLoginTip() then
        self._ccbOwner.node_tf:setVisible(false)
    end
    if CHANNEL_RES and CHANNEL_RES["envName"] and (CHANNEL_RES["envName"] == "dljxol_238" or CHANNEL_RES["envName"] == "whjx_239" or CHANNEL_RES["envName"] == "yuewen_yinwan") then
        self._ccbOwner.node_tf:setVisible(false)
    end

    self._loadingBar = QUIWidgetLoadingBar.new()
    self:getView():addChild(self._loadingBar)
    self._loadingBar:setVisible(false)
    self._loadingBar:setPosition(ccp(0, -(display.height - display.cy) * 0.6))
    self._loadingBar:setPercent(0)
    self._loadingBar:setCheckingVisible(false)
    self._loadingBar:setUpdatingVisible(false)
    self._loadingBar:setSizeVisible(false)
end

function QUIDialogUpdate:viewDidAppear()
    QUIDialogUpdate.super.viewDidAppear(self)
    if ENABLE_NEW_UPDATE and app.updateManager ~= nil then
        self._updateProxy = cc.EventProxy.new(app.updateManager)
        self._updateProxy:addEventListener(app.updateManager.EVENT_UI_UPDATE_STATE, handler(self, self._updateStatus))
        self._updateProxy:addEventListener(app.updateManager.EVENT_UI_UPDATE_PROGRESS, handler(self, self._updateProgress))
    end
    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_CHANGE_GLVIEW_SIZE, self._reloadCCB, self)
end

function QUIDialogUpdate:viewWillDisappear()
    QUIDialogUpdate.super.viewWillDisappear(self)
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_CHANGE_GLVIEW_SIZE, self._reloadCCB, self)
end

function QUIDialogUpdate:_reloadCCB()
    local gapWidth = display.width - display.ui_width
    local gapHeight = display.height - display.ui_height

    local offset = 0
    if event and event.name == "EVENT_CHANGE_GLVIEW_SIZE" then
        offset = display.ui_width/2 - self._oldPosX + self._oldGapWidth/2
    end

    local pos = self:getView():convertToWorldSpaceAR(ccp(0,0))
    self:getView():setPositionX(display.ui_width/2 - offset + gapWidth/2)
    local pos = self:getView():convertToWorldSpaceAR(ccp(0,0))

    self._ccbOwner.node_user:setPositionX(gapWidth/2 - gapWidth/2)
    self._ccbOwner.node_user:setPositionY(display.ui_height - gapHeight/2)

    self._ccbOwner.LoginNode:setPositionX(display.ui_width/2)
    self._ccbOwner.LoginNode:setPositionY(-gapHeight/2)

    self._ccbOwner.node_loading:setPositionX(display.ui_width/2)
    self._ccbOwner.node_loading:setPositionY(-gapHeight/2)

    self._ccbOwner.node_anniversary:setPositionX(display.ui_width)
    self._ccbOwner.node_anniversary:setPositionY(display.ui_height - gapHeight/2)

    self._ccbOwner.node_tf:setPositionX(display.ui_width)
    self._ccbOwner.node_tf:setPositionY(display.ui_height + gapHeight/2)
end


function QUIDialogUpdate:enableStartGameButton(callback)
    self._onStartGameCall = callback
    -- self._ccbOwner.btn_game:setVisible(true)
    scheduler.performWithDelayGlobal(function()
      self:_onStart()
    end, 0.05)
end

function QUIDialogUpdate:disableStartGameButton()
    self._onStartGameCall = nil
    -- self._ccbOwner.btn_game:setVisible(false)
end

function QUIDialogUpdate:_onStart(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_enter) == false then return end
    
    if device.platform == "ios" or device.platform == "android" then
        if CCNetwork:getInternetConnectionStatus() == kCCNetworkStatusNotReachable then
            app:alert({title = "网络错误", content = "当前没有网络连接，请检查网络设置，点击确定重试", callback = function()
                self:_onStart()
            end})
            return
        end
    end

    if self._onStartGameCall then
        self._onStartGameCall()
    end
end

--更新界面提示
function QUIDialogUpdate:_updateStatus(evt)
    self._loadingBar:setVisible(false)
    self._loadingBar:setCheckingVisible(false)
    self._loadingBar:setUpdatingVisible(false)
    self._loadingBar:setSizeVisible(false)
    if evt.data ~= nil then
        if evt.data.text ~= nil then
            self._loadingBar:setTips(evt.data.text)
        end
    end
    if evt.status == 2 then
        self._loadingBar:setVisible(true)
        self._loadingBar:setUpdatingVisible(true)
        self._loadingBar:setWifiTipsVisible(CCNetwork:isLocalWiFiAvailable())
    end
    if evt.status == 3 then
        self._loadingBar:setVisible(true)
        self._loadingBar:setCheckingVisible(true)
        self._loadingBar:setWifiTipsVisible(false)
    end
    if evt.status == 4 then
        self._loadingBar:setVisible(true)
        self._loadingBar:setUpdatingVisible(true)
        self._loadingBar:setSizeVisible(true)
        self._loadingBar:setWifiTipsVisible(CCNetwork:isLocalWiFiAvailable())
    end
end

--更新进度
function QUIDialogUpdate:_updateProgress(evt)
    if evt.data then
        if evt.data.percent then
            self._loadingBar:setPercent(evt.data.percent)
        end
        if evt.status == 2 and evt.data.text then
            self._loadingBar:setDownloadText(evt.data.text)
            self._loadingBar:setSizeVisible(false)
        end
        if evt.status == 4 then
            if evt.data then
                local currentkb = math.ceil(evt.data.currentSize/1000)
                local totalkb = math.ceil(evt.data.totalSize/1000)
                local text = currentkb.."KB"
                if currentkb > 1000 then
                    text = math.ceil(currentkb/1000).."MB"
                end
                self._loadingBar:setUpdatingText(text)
                self._loadingBar:setTotalSize(totalkb)
                self._loadingBar:setDownloadedSize(currentkb)
                if evt.data.name then
                    self._loadingBar:setTips(evt.data.name)
                end
            end
        end
    end
end

return QUIDialogUpdate



