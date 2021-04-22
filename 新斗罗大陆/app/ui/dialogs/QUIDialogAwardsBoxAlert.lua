--
-- Author: wkwang
-- Date: 2014-07-28 19:39:30
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogAwardsBoxAlert = class("QUIDialogAwardsBoxAlert", QUIDialog)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")
local QRichText = import("...utils.QRichText")

QUIDialogAwardsBoxAlert.EVENT_GET_SUCC = "EVENT_GET_SUCC"

function QUIDialogAwardsBoxAlert:ctor(options)
	local ccbFile = "ccb/Dialog_ChestAward2.ccbi"
	if options.tips ~= nil then
		ccbFile = "ccb/Dialog_ChestAward.ccbi"
	end
    local callBacks = {
        {ccbCallbackName = "onTriggerCancel", callback = handler(self, self._onTriggerCancel)},
        {ccbCallbackName = "onTriggerConfirm", callback = handler(self, self._onTriggerConfirm)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerOk", callback = handler(self,self._onTriggerOk)},
    }
    QUIDialogAwardsBoxAlert.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self.isAnimation = true

    if options.tips ~= nil then	
    	self._ccbOwner.node_sp:setVisible(false)
		self._ccbOwner.tf_tips:setString("")
		self._ccbOwner.tf_num:setString("")
    	local richText = QRichText.new(nil, nil, {defaultColor = COLORS.j})
    	-- richText:setAnchorPoint(0,0.5)
    	self._ccbOwner.tf_tips:getParent():addChild(richText)
    	richText:setPosition(ccp(self._ccbOwner.tf_tips:getPosition()))
    	richText:setString(options.tips)
    	richText:setPositionX(-richText:getContentSize().width/2)

    	self._ccbOwner.frame_tf_title:setString(options.titleStr or "宝箱奖励")
	end

	if self._ccbOwner.tf_redpacket_tips then
		self._ccbOwner.tf_redpacket_tips:setVisible(options.isShowRedpacketTips and remote.user.level >= remote.redpacket.sendTokenRedpacketUnlockLevel and next(remote.union.consortia) ~= nil)
	end
	local width = 418
    if options.tips ~= nil then
    	width = 460
		self._ccbOwner.btn_ok:setVisible(false)
		self._ccbOwner.btn_cancel:setVisible(false)
		self._ccbOwner.btn_close:setVisible(false)
	end
	QPrintTable(options.awards)
	self._items = {}
	self._awards = {}
	if options ~= nil then
    	if options.tips ~= nil then	
			if options.isGet == true then
				self._ccbOwner.btn_ok:setVisible(true)
				self._ccbOwner.btn_cancel:setVisible(true)
			else
				self._ccbOwner.btn_close:setVisible(true)
			end
		end
		if options.awards ~= nil then
			self._awards = options.awards
			local count = #self._awards
    		local gap = width/(count*2+1)
			for index,value in ipairs(self._awards) do
				self._items[index] = QUIWidgetItemsBox.new()
				self._items[index]:setPositionX(index*gap*2-gap/2)
				self._ccbOwner.node_goods:addChild(self._items[index])
				self._items[index]:setGoodsInfo(value.id,value.typeName,value.count)
				self._items[index]:setPromptIsOpen(true)
			end
		end
	end
end

function QUIDialogAwardsBoxAlert:viewDidAppear()
	QUIDialogAwardsBoxAlert.super.viewDidAppear(self)
	self.prompt = app:promptTips()
	self.prompt:addItemEventListener(self)
end

function QUIDialogAwardsBoxAlert:viewWillDisappear()
  	QUIDialogAwardsBoxAlert.super.viewWillDisappear(self)
 	self.prompt:removeItemEventListener()
 end

function QUIDialogAwardsBoxAlert:_backClickHandler()
    self:_close()
end

function QUIDialogAwardsBoxAlert:_onTriggerCancel(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_cancel_bg) == false then return end
	app.sound:playSound("common_cancel")
    self:_close()
end

function QUIDialogAwardsBoxAlert:_onTriggerOk(event)
	if q.buttonEventShadow(event,self._ccbOwner.button_close) == false then return end
	app.sound:playSound("common_cancel")
    self:_close()
end

function QUIDialogAwardsBoxAlert:_onTriggerClose(event)
	if q.buttonEventShadow(event,self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
    self:_close()
end

function QUIDialogAwardsBoxAlert:_close()
    self:playEffectOut()
end

function QUIDialogAwardsBoxAlert:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER, nil, self)
end

function QUIDialogAwardsBoxAlert:_onTriggerConfirm(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_ok_sp) == false then return end
	app.sound:playSound("common_confirm")
    self:_close()
end

return QUIDialogAwardsBoxAlert