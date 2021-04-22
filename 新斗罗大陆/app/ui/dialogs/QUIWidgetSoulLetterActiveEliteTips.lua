--
-- Author: wkwang
-- 手札购买提示框。 包括系统统一提示框与购买提示
-- Date: 2019-10-30 
--


local QUIDialog = import("..dialogs.QUIDialog")
local QUIWidgetSoulLetterActiveEliteTips = class("QUIWidgetSoulLetterActiveEliteTips", QUIDialog)

local QUIWidgetSoulLetterActiveEliteClient = import("..widgets.QUIWidgetSoulLetterActiveEliteClient")
local QUIWidgetSoulLetterBuyExpClient = import("..widgets.QUIWidgetSoulLetterBuyExpClient")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIWidgetSoulLetterActiveEliteTips:ctor(options) 
 	local ccbFile = "ccb/Dialog_Battle_Pass_Activition_Tips.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIWidgetSoulLetterActiveEliteTips._onTriggerClose)},
	    {ccbCallbackName = "onTriggerCancel", callback = handler(self, QUIWidgetSoulLetterActiveEliteTips._onTriggerCancel)},
	    {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIWidgetSoulLetterActiveEliteTips._onTriggerConfirm)},
	}
	QUIWidgetSoulLetterActiveEliteTips.super.ctor(self, ccbFile, callBacks, options)
	options.btnDesc = options.btnDesc or {}
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options.info then
		self._info = options.info
	end

	if options.title then
		self._title = options.title
		self._ccbOwner.frame_tf_title:setString(self._title)
	end

	if options.activityProxy then
		self._activityProxy = options.activityProxy
	end

	self._autoCenter = true

	self._lineWidth = 400
	if options.lineWidth then
		self._lineWidth =  options.lineWidth
	end
	
	self._fontSize = 24
	if options.fontSize then
		self._fontSize =  options.fontSize
	end


	self._day= 1
	if options.day then
		self._day= options.day
	end
	self._max_level  = 1

	if options.max_level then
		self._max_level = options.max_level
	end

	self._content=""


	if options.buyCallback then
		self._buyCallback = options.buyCallback
	end

	if options.expCallback then
		self._expCallback = options.expCallback
	end


	self._ccbOwner.tf_ok:setString("确 认")
	self._ccbOwner.tf_cancel:setString("取 消")

	--self:setInfo() 
end



function QUIWidgetSoulLetterActiveEliteTips:viewDidAppear()
	QUIWidgetSoulLetterActiveEliteTips.super.viewDidAppear(self)
	if self._activityProxy.isOpen == false then
		self:popSelf()
		return
	end

	self:setInfo()
end

function QUIWidgetSoulLetterActiveEliteTips:viewWillDisappear()
  	QUIWidgetSoulLetterActiveEliteTips.super.viewWillDisappear(self)
end


function QUIWidgetSoulLetterActiveEliteTips:setInfo() 


	local show_exp = self._day < 7
	local show_max_buy = self._info.buy_type == 3

	self._ccbOwner.node_suggest_1:removeChildByTag(99)
	self._ccbOwner.node_suggest_2:removeChildByTag(99)

	if show_max_buy then
		local elite2 = self._activityProxy:getBuyExpConfigByType(4)
		if elite2[1] then
			local client =  QUIWidgetSoulLetterActiveEliteClient.new()
			client:addEventListener(QUIWidgetSoulLetterActiveEliteClient.EVENT_CLICK_BUY, handler(self, self._clickBuy))
			self._ccbOwner.node_suggest_1:addChild(client)
			client:setTag(99)
			client:setInfo(elite2[1], self._activityProxy)
			client:showSuggest()
		else
			show_max_buy = false
		end
	end


	if show_exp then
		local configs = self._activityProxy:getBuyExpConfigByType(1)
		if configs[4] then
			local client = QUIWidgetSoulLetterBuyExpClient.new()
			self._ccbOwner.node_suggest_2:addChild(client)
			client:addEventListener(QUIWidgetSoulLetterBuyExpClient.EVENT_CLICK_VIEW, handler(self, self._clickView))
			client:setInfo(configs[4], self._activityProxy)
			client:setTag(99)
			client:setShowView()
		else
			show_exp = false
		end
	end	


	self._ccbOwner.node_suggest_1:setVisible(show_max_buy)
	self._ccbOwner.node_suggest_2:setVisible(show_exp)
	if show_exp and show_max_buy then
		self._ccbOwner.tips_node:setPositionX(-220)
		self._ccbOwner.node_suggest_1:setPositionX(31)
		self._ccbOwner.node_suggest_2:setPositionX(395)

	elseif show_max_buy then
		self._ccbOwner.tips_node:setPositionX(-131)
		self._ccbOwner.node_suggest_1:setPositionX(131)
	elseif show_exp then
		self._ccbOwner.tips_node:setPositionX(-131)
		self._ccbOwner.node_suggest_2:setPositionX(260)
	else
		self._ccbOwner.tips_node:setPositionX(0)
	end



	local endTime = self._activityProxy.endAt or 0
	local week = q.timeToYearMonthDay(endTime)
	
	self._content = string.format("本期手札截止时间为##e%s##n，完成手札任务最高可升至##e%d级##n，需要购买手札经验升至##e60级##n才可获得皮肤，是否确认购买？", week ,self._max_level )
	self._ccbOwner.colorfulText:removeAllChildren()
	local richText = QRichText.new(self._content, self._lineWidth, {autoCenter = self._autoCenter, stringType = 1, defaultSize = self._fontSize})
	richText:setAnchorPoint(ccp(0.5,0.5))
	self._ccbOwner.colorfulText:addChild(richText)

end






function QUIWidgetSoulLetterActiveEliteTips:_onTriggerClose(event) 
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	self:popSelf()
end

function QUIWidgetSoulLetterActiveEliteTips:_onTriggerCancel(event) 
    if q.buttonEventShadow(event, self._ccbOwner.btn_cancel) == false then return end
	self:popSelf()
end

function QUIWidgetSoulLetterActiveEliteTips:_onTriggerConfirm(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_confirm) == false then return end
	self:BuySth(self._info)
end

function QUIWidgetSoulLetterActiveEliteTips:_clickBuy(event)
	if event == nil then return end
	app.sound:playSound("common_small")
	local info = event.info
	self:BuySth(info)
end


function QUIWidgetSoulLetterActiveEliteTips:BuySth(info)
	self:popSelf()
	if self._buyCallback then
		self._buyCallback(info)
	end
end


function QUIWidgetSoulLetterActiveEliteTips:_clickView(event)
	if event == nil then return end
	app.sound:playSound("common_small")
	self:popSelf()
	if self._expCallback then
		self._expCallback()
	end
end


function QUIWidgetSoulLetterActiveEliteTips:_backClickHandler()
	local options = self:getOptions()
	if options.canBackClick ~= false then
    	self:popSelf()
    end
end


return QUIWidgetSoulLetterActiveEliteTips
