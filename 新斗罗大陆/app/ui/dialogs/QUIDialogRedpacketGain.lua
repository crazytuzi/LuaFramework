--
-- Author: Kumo.Wang
-- 宗门红包获得界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogRedpacketGain = class("QUIDialogRedpacketGain", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QMaskWords = import("...utils.QMaskWords")
local QRichText = import("...utils.QRichText")

function QUIDialogRedpacketGain:ctor(options)
	local ccbFile = "ccb/Dialog_Society_Redpacket_Gain.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
        {ccbCallbackName = "onTriggerInspect", callback = handler(self, self._onTriggerInspect)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogRedpacketGain.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true --是否动画显示

	self._data = options.data

    self:_init()
end

function QUIDialogRedpacketGain:viewDidAppear()
	QUIDialogRedpacketGain.super.viewDidAppear(self)
end

function QUIDialogRedpacketGain:viewWillDisappear()
	QUIDialogRedpacketGain.super.viewWillDisappear(self)
end

function QUIDialogRedpacketGain:_resetAll()
	self._ccbOwner.node_head:removeAllChildren()
    self._ccbOwner.node_playerName:removeAllChildren()
	self._ccbOwner.tf_playerWords:setVisible(false)
    self._ccbOwner.tf_bonusNumber:setVisible(false)
	self._ccbOwner.node_bonusIcon:setVisible(false)
end

function QUIDialogRedpacketGain:_init()
	self:_resetAll()
	if not self._data then return end

	self:_setHeroHead()
	self:_setAwardInfo()
    self:_addInputBox()
end

function QUIDialogRedpacketGain:_addInputBox()
    if not self._inputMsg then
        -- add input box
        self._inputWidth = self._ccbOwner.inputArea:getContentSize().width
        self._inputHeight = self._ccbOwner.inputArea:getContentSize().height
        self._inputMsg = ui.newEditBox({image = "ui/none.png", listener = handler(self, self._onEdit), size = CCSize(self._inputWidth, self._inputHeight)})
        self._inputMsg:setFont(global.font_default, 20)
        self._inputMsg:setMaxLength(36)
        self._inputMsg:setPlaceHolder(remote.redpacket.DEFAULT_GAIN_MESSAGE)
        self._inputMsg:setPlaceholderFontColor(ccc3(200, 200, 200)) 
        self._inputMsg:setPlaceholderFontSize(20)
        self._inputMsg:setFontName(global.font_name)
        self._ccbOwner.input:addChild(self._inputMsg)
    end
end

function QUIDialogRedpacketGain:_onEdit(event, editbox)
    if event == "began" then

    elseif event == "changed" then
        if device.platform == "android" or device.platform == "windows" then
            local msg = self._inputMsg:getText()
            self._inputMsg:setText(msg)
        end
    elseif event == "ended" then
        if device.platform == "android" or device.platform == "windows" then
            local msg = self._inputMsg:getText()
            self._inputMsg:setText(msg)
        end
    elseif event == "return" then
        -- 从输入框返回
    elseif event == "returnDone" then
        if device.platform == "ios" then
            local msg = self._inputMsg:getText()
            self._inputMsg:setText(msg)
        end
    end
end

function QUIDialogRedpacketGain:_setHeroHead()
	local avatarWidget = QUIWidgetAvatar.new()
    avatarWidget:setInfo(self._data.avatar)
    avatarWidget:setSilvesArenaPeak(self._data.championCount)
    self._ccbOwner.node_head:addChild(avatarWidget)
end

function QUIDialogRedpacketGain:_setAwardInfo()
    local str = "##j来自 ##w"..(self._data.nickname or "").." ##j的福袋"
    local richText = QRichText.new(str, 500, {autoCenter = false, stringType = 1})
    richText:setAnchorPoint(ccp(0, 0.5))
    self._ccbOwner.node_playerName:addChild(richText)

    self._ccbOwner.tf_playerWords:setString(self._data.content or "")
    self._ccbOwner.tf_playerWords:setVisible(true)
    for _, log in ipairs(self._data.receiveDetailLogList or {}) do
        if log.userId == remote.user.userId then
            self._ccbOwner.tf_bonusNumber:setString(log.item_num or 0)
            self._ccbOwner.tf_bonusNumber:setVisible(true)
        end
    end
    self._ccbOwner.node_bonusIcon:setVisible(true)
end

-- function QUIDialogRedpacketGain:_backClickHandler()
--     self:_onTriggerClose()
-- end

function QUIDialogRedpacketGain:_onTriggerOK(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_ok) == false then return end
	app.sound:playSound("common_small")
    local msg = self._inputMsg:getText()
    -- print(msg, string.len(msg))

    if msg == nil or msg == "" then
        msg = remote.redpacket.DEFAULT_GAIN_MESSAGE
    end
    if string.len(msg) > 36 then
        app.tip:floatTip("发送祝福语内容过长")
        return
    end
    if QMaskWords:isFind(msg) then
        app.tip:floatTip("发送祝福中包含敏感字符")
        return
    end
    local serverChatData = app:getServerChatData() -- app:getXMPPData() 
    if not serverChatData:messageValid(msg, CHANNEL_TYPE.GLOBAL_CHANNEL) then
        app.tip:floatTip("发送祝福中包含非法字符")
        return
    end
    
    remote.redpacket:unionRedpacketSaveMessageRequest(self._data.redpacketId, msg, self:safeHandler(function()
            self:_onTriggerClose()
        end))
end

function QUIDialogRedpacketGain:_onTriggerInspect(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_inspect) == false then return end
    app.sound:playSound("common_small")
    self._inputMsg:setEnabled(false)
    self._inputMsg:setVisible(false)
    app:getNavigationManager():pushViewController(app.topLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogRedpacketRecord", options = {data = self._data, callback = self:safeHandler(function()
            self._inputMsg:setEnabled(true)
            self._inputMsg:setVisible(true)
        end)}})
end

function QUIDialogRedpacketGain:_onTriggerClose(e)
    if e then
    	app.sound:playSound("common_small")
    end
	self:playEffectOut()
end

function QUIDialogRedpacketGain:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_SPECIFIC_CONTROLLER, nil, self)
end

return QUIDialogRedpacketGain