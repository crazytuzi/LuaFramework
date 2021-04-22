-- @Author: xurui
-- @Date:   2017-01-03 11:47:29
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-03-18 17:35:59

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMaritimeJoinProtecter = class("QUIDialogMaritimeJoinProtecter", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRichText = import("...utils.QRichText") 

function QUIDialogMaritimeJoinProtecter:ctor(options)
	local ccbFile = "ccb/Dialog_Haishang_join_protecter.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
	}
	QUIDialogMaritimeJoinProtecter.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local configuration = QStaticDatabase:sharedDatabase():getConfiguration()
	self._protecterTotalNum = configuration["maritime_protect"].value
end

function QUIDialogMaritimeJoinProtecter:viewDidAppear()
	QUIDialogMaritimeJoinProtecter.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogMaritimeJoinProtecter:viewWillDisappear()
	QUIDialogMaritimeJoinProtecter.super.viewWillDisappear(self)
end

function QUIDialogMaritimeJoinProtecter:setInfo()
	local myInfo = remote.maritime:getMyMaritimeInfo()
	self._protecterNum = self._protecterTotalNum - (myInfo.escortCnt or 0)
	self._ccbOwner.tf_join_num:setString("剩余保护次数："..self._protecterNum)

	self._ccbOwner.normalText:setVisible(false)

    local stringFormat = "##w加入保护可将您显示在保护列表中，同宗门成员可选择##o您来保护他们的仙品##w（不影响自己商运）是否加入？"

    if self._richText == nil then
        self._richText = QRichText.new(nil,355,{stringType = 1, defaultColor = ccc3(255,255,255), defaultSize = 24})
        self._richText:setAnchorPoint(0,1)
        self._ccbOwner.colorfulText:addChild(self._richText)
    end
    self._richText:setString(stringFormat)
end

function QUIDialogMaritimeJoinProtecter:_onTriggerConfirm()
	if self._protecterNum <= 0 then
		app.tip:floatTip("魂师大人，保护次数已用完~")
		self:_onTriggerClose()
	else
		remote.maritime:requestMaritimeJoinEscort(function ()
			if self:safeCheck() then
				self:_onTriggerClose()
			end
		end, function ()
			self:_onTriggerClose()
		end)
	end
end

function QUIDialogMaritimeJoinProtecter:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMaritimeJoinProtecter:_onTriggerClose()
	self:playEffectOut()
end

function QUIDialogMaritimeJoinProtecter:viewAnimationOutHandler()
	self:popSelf()
end


return QUIDialogMaritimeJoinProtecter