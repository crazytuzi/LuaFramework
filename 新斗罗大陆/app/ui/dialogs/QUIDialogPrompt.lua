-- 
-- Kumo.Wang
-- 弹框通知界面
-- 

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogPrompt = class("QUIDialogPrompt", QUIDialog)

local QRichText = import("...utils.QRichText") 

function QUIDialogPrompt:ctor(options)
	local ccbFile = "ccb/Dialog_Prompt.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
		{ccbCallbackName = "onTriggerCanel", callback = handler(self, self._onTriggerCanel)},
    }
    QUIDialogPrompt.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callback = options.callback
        self._content = options.content
        self._titlePath = options.titlePath
        self._spAvatarPath = options.spAvatarPath
        self._uorType = options.uorType
        self._btnText = options.btnText
        self._okCallback = options.okCallback
    end

    self._ccbOwner.node_btn_cancel:setVisible(true)
    self._ccbOwner.node_btn_ok:setVisible(false)

    -- 仅支持每日一次
    if self._uorType and app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(self._uorType) then
        app:getUserOperateRecord():recordeCurrentTime(self._uorType)
    end

    if self._content then
        local rt = QRichText.new(nil, 400)
        rt:setAnchorPoint(ccp(0, 1))
        rt:setString(self._content)
    	self._ccbOwner.node_tf:addChild(rt)
	end

    if self._titlePath then
        QSetDisplayFrameByPath(self._ccbOwner.sp_title, self._titlePath)
        self._ccbOwner.sp_title:setVisible(true)
    else
        self._ccbOwner.sp_title:setVisible(false)
    end

    if self._spAvatarPath then
        QSetDisplayFrameByPath(self._ccbOwner.sp_avatar, self._spAvatarPath)
    end

    if self._okCallback then
        self._ccbOwner.node_btn_ok:setVisible(true)
        self._ccbOwner.node_btn_ok:setPositionX(-58)
        self._ccbOwner.node_btn_cancel:setPositionX(122)
    else
        self._ccbOwner.node_btn_cancel:setPositionX(32)
    end
    if self._btnText then
        self._ccbOwner.tf_ok:setString(self._btnText)
    end
end

function QUIDialogPrompt:viewDidAppear()
	QUIDialogPrompt.super.viewDidAppear(self)
end

function QUIDialogPrompt:viewWillDisappear()
  	QUIDialogPrompt.super.viewWillDisappear(self)
end

function QUIDialogPrompt:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogPrompt:_onTriggerOK(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
    self._isOK = true
    self:_onTriggerClose()
end

function QUIDialogPrompt:_onTriggerCanel(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_cancel) == false then return end
    self._isOK = false
    self:_onTriggerClose()
end

function QUIDialogPrompt:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogPrompt:viewAnimationOutHandler()
	local callback = self._callback
    local okCallback = nil
    if self._isOK then
        okCallback = self._okCallback
    end
	self:popSelf()

	if callback then
		callback()
	end
    if okCallback then
        okCallback()
    end
end

return QUIDialogPrompt
