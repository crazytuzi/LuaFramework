-- 
-- Kumo.Wang
-- 弹框通知界面_有icon版
-- 

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogPromptWithAward = class("QUIDialogPromptWithAward", QUIDialog)

local QRichText = import("...utils.QRichText") 

function QUIDialogPromptWithAward:ctor(options)
	local ccbFile = "ccb/Dialog_Prompt_With_Award.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
    }
    QUIDialogPromptWithAward.super.ctor(self, ccbFile, callBacks, options)
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
        self._iconPath = options.iconPath
    end

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

    self._ccbOwner.node_award:removeAllChildren()
    if self._iconPath then
        local sprite = CCSprite:create(self._iconPath)
        if sprite then
            self._ccbOwner.node_award:addChild(sprite)
        end
    end

    if self._btnText then
        self._ccbOwner.tf_ok:setString(self._btnText)
    end
end

function QUIDialogPromptWithAward:viewDidAppear()
	QUIDialogPromptWithAward.super.viewDidAppear(self)
end

function QUIDialogPromptWithAward:viewWillDisappear()
  	QUIDialogPromptWithAward.super.viewWillDisappear(self)
end

function QUIDialogPromptWithAward:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogPromptWithAward:_onTriggerOK(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_ok) == false then return end
    self:_onTriggerClose()
end

function QUIDialogPromptWithAward:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogPromptWithAward:viewAnimationOutHandler()
	local callback = self._callback

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogPromptWithAward
