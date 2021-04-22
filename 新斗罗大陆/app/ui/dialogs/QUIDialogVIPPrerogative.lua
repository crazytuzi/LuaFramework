-- @Author: xurui
-- @Date:   2018-09-07 11:01:43
-- @Last Modified by:   xurui
-- @Last Modified time: 2018-09-07 11:05:10
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogVIPPrerogative = class("QUIDialogVIPPrerogative", QUIDialog)

local QRichText = import("...utils.QRichText")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

function QUIDialogVIPPrerogative:ctor(options)
	local ccbFile = "ccb/Dialog_VIP_renzheng.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
    }
    QUIDialogVIPPrerogative.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._callBack = options.callBack
    end
    self:setContent()
end

function QUIDialogVIPPrerogative:setContent()
	self._ccbOwner.content:removeAllChildren()
	local titleRichText = QRichText.new({}, 500)
	titleRichText:setAnchorPoint(ccp(0, 1))
    self._ccbOwner.content:addChild(titleRichText)
    titleRichText:setString({
	        {oType = "font", content = "亲爱的魂师大人：\n", size = 20, color = GAME_COLOR_SHADOW.normal},
	    })
    local contentRichText = QRichText.new({}, 500)
    contentRichText:setAnchorPoint(ccp(0, 1))
    contentRichText:setPositionY(-titleRichText:getContentSize().height)
    self._ccbOwner.content:addChild(contentRichText)
    contentRichText:setString({
	        {oType = "font", content = "    小舞兴奋地告诉您，您已经可以进行（新斗罗大陆）尊享VIP认证啦！认证之后，您可以获取VIP尊贵特权、节日礼包、咨询优先通知等一系列VIP优质服务。详情请联系", size = 20, color = GAME_COLOR_SHADOW.normal},
	        {oType = "font", content = "VIP客服QQ公众号服务（起点游戏中心）：800038605", size = 20, color = GAME_COLOR_SHADOW.warning},
	        {oType = "font", content = "，小舞等您来认证哦~（PS：", size = 20, color = GAME_COLOR_SHADOW.normal},
	        {oType = "font", content = "请大家小心谨慎，不要误入一些非官方QQ群哦", size = 20, color = GAME_COLOR_SHADOW.warning},
	        {oType = "font", content = "）", size = 20, color = GAME_COLOR_SHADOW.normal},
	    })
end

function QUIDialogVIPPrerogative:viewDidAppear()
	QUIDialogVIPPrerogative.super.viewDidAppear(self)
end

function QUIDialogVIPPrerogative:viewWillDisappear()
  	QUIDialogVIPPrerogative.super.viewWillDisappear(self)
end

function QUIDialogVIPPrerogative:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogVIPPrerogative:_onTriggerConfirm()
	self:_onTriggerClose()
end

function QUIDialogVIPPrerogative:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogVIPPrerogative:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogVIPPrerogative
