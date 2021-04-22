-- @Author: zhouxiaoshu
-- @Date:   2019-07-25 14:21:58
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-11-05 16:55:12
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonthCardPrivilege = class("QUIDialogMonthCardPrivilege", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetHeroTitleBox = import("..widgets.QUIWidgetHeroTitleBox")

function QUIDialogMonthCardPrivilege:ctor(options)
	local ccbFile = "ccb/Dialog_month_card_privilege.ccbi"
	if options.isSuper then
		ccbFile = "ccb/Widget_Activity_yueka_super.ccbi"
	end
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerBuyPrime", callback = handler(self, self._onTriggerBuyPrime)},
		{ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
    }
    QUIDialogMonthCardPrivilege.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options.isSuper then
		self._ccbOwner.node_card_bg:setPositionY(150)
		return
	end
	self._ccbOwner.btn_go:setVisible(options.isShowGo or false)

	local size = self._ccbOwner.sp_bg2:getContentSize()
	self._ccbOwner.sp_bg2:setContentSize(CCSize(size.width, 322))
	self._ccbOwner.node_buy_2:setVisible(false)

	local titleId = 800
	local titleBox = QUIWidgetHeroTitleBox.new()
	titleBox:setTitleId(titleId)
	titleBox:setPositionY(5)
	self._ccbOwner.node_chenghao:removeAllChildren()
	self._ccbOwner.node_chenghao:addChild(titleBox)

	self._ccbOwner.node_title_1:setVisible(false)
	self._ccbOwner.node_title_2:setVisible(false)

	local isActive = true
	if remote.activity:checkMonthCardActive(1)then
		makeNodeFromGrayToNormal(self._ccbOwner.node_blue)
	else
		makeNodeFromNormalToGray(self._ccbOwner.node_blue)
		self._ccbOwner.remaining1:setColor(GAME_COLOR_SHADOW.notactive)
		self._ccbOwner.remaining1:disableOutline()
		isActive = false
	end
	if remote.activity:checkMonthCardActive(2)then
		makeNodeFromGrayToNormal(self._ccbOwner.node_red)
	else
		makeNodeFromNormalToGray(self._ccbOwner.node_red)
		self._ccbOwner.remaining2:setColor(GAME_COLOR_SHADOW.notactive) 
		self._ccbOwner.remaining2:disableOutline()
		isActive = false
	end

	if isActive then
		self._ccbOwner.tf_title:setString("月卡特权")
		self._ccbOwner.tf_prop:setString("专属称号四项属性+1%")
		makeNodeFromGrayToNormal(self._ccbOwner.node_chenghao)
	else
		self._ccbOwner.tf_title:setString("月卡特权")
		self._ccbOwner.tf_prop:setString("激活双月卡获取专属称号")
		makeNodeFromNormalToGray(self._ccbOwner.node_chenghao)
	end
end

function QUIDialogMonthCardPrivilege:viewDidAppear()
	QUIDialogMonthCardPrivilege.super.viewDidAppear(self)
end

function QUIDialogMonthCardPrivilege:viewWillDisappear()
  	QUIDialogMonthCardPrivilege.super.viewWillDisappear(self)
end

function QUIDialogMonthCardPrivilege:_onTriggerBuyPrime(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_buy_2) == false then return end
  	app.sound:playSound("common_confirm")
	self:viewAnimationOutHandler()
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPanel",
        options = {themeId = 1, curActivityID = "a_yueka"}}, {isPopCurrentDialog = true})
end

function QUIDialogMonthCardPrivilege:_onTriggerGo(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_go) == false then return end
  	app.sound:playSound("common_confirm")
	self:viewAnimationOutHandler()
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogActivityPanel",
        options = {themeId = 1, curActivityID = "a_yueka"}}, {isPopCurrentDialog = true})
end

function QUIDialogMonthCardPrivilege:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMonthCardPrivilege:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

return QUIDialogMonthCardPrivilege
