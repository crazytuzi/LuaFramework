-- @Author: xurui
-- @Date:   2018-09-13 15:42:43
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-25 18:40:33
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionImpeachDialog = class("QUIDialogUnionImpeachDialog", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText") 

function QUIDialogUnionImpeachDialog:ctor(options)
	local ccbFile = "ccb/Dialog_black_mountain_tanhe.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
    }
    QUIDialogUnionImpeachDialog.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    end

    if remote.union.consortia and remote.union.consortia.name then
        local rt = QRichText.new(nil, 400)
        rt:setAnchorPoint(ccp(0, 1))
        local tfTbl = {}
        table.insert(tfTbl, {oType = "font", content = "魂师大人，您已经成为", size = 24, color = ccc3(255,215,172)})
        table.insert(tfTbl, {oType = "font", content = remote.union.consortia.name, size = 24, color = ccc3(255,255,255)})
        table.insert(tfTbl, {oType = "font", content = "的新任宗主啦！相信在您的带领下一定会成为威震斗罗大陆的上三宗！ ", size = 24, color = ccc3(255,215,172)})
        rt:setString(tfTbl)
    	self._ccbOwner.node_tf:addChild(rt)
	end
end

function QUIDialogUnionImpeachDialog:viewDidAppear()
	QUIDialogUnionImpeachDialog.super.viewDidAppear(self)
end

function QUIDialogUnionImpeachDialog:viewWillDisappear()
  	QUIDialogUnionImpeachDialog.super.viewWillDisappear(self)
end

function QUIDialogUnionImpeachDialog:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogUnionImpeachDialog:_onTriggerConfirm(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_confirm) == false then return end
    self:_onTriggerClose()
end

function QUIDialogUnionImpeachDialog:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogUnionImpeachDialog:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogUnionImpeachDialog
