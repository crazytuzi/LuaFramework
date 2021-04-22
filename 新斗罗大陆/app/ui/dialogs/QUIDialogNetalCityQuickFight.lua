-- @Author: xurui
-- @Date:   2018-08-17 10:35:00
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-10-24 15:28:57
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogNetalCityQuickFight = class("QUIDialogNetalCityQuickFight", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetEliteBattleAgain = import("..widgets.QUIWidgetEliteBattleAgain")

function QUIDialogNetalCityQuickFight:ctor(options)
	local ccbFile = "ccb/Dialog_EliteBattleAgain.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
        {ccbCallbackName = "onTriggerQuickFightOne", callback = handler(self, self._onTriggerQuickFightOne)},
    }
    QUIDialogNetalCityQuickFight.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._ccbOwner.frame_tf_title:setString("扫荡")

    if options then
    	self._callBack = options.callBack
        self._awards = options.awards
        self._info = options.info
        self._awardRatio = options.awardRatio
    end
    self._awardPanels = {}
    self._isEnd = false
end

function QUIDialogNetalCityQuickFight:viewDidAppear()
	QUIDialogNetalCityQuickFight.super.viewDidAppear(self)

	self:setAwardInfo()
end

function QUIDialogNetalCityQuickFight:viewWillDisappear()
  	QUIDialogNetalCityQuickFight.super.viewWillDisappear(self)
end

function QUIDialogNetalCityQuickFight:setAwardInfo()
	self._floorInfo = remote.metalCity:getMetalCityConfigByFloor(self._info.num)

	self._ccbOwner.label_name:setString(string.format("第%s-%s关", self._info.metalcity_chapter, self._floorInfo.metalcity_floor))
    self._ccbOwner.tf_one:setString("再扫1次")
    self._ccbOwner.btn_one:setVisible(false)

    local panel = QUIWidgetEliteBattleAgain.new()
    self._awardPanels = panel
    panel:setPositionY(0)
    panel:setTitle("第1次")
    printTable(self._awards)
    panel:setInfo(self._awards, nil, nil, nil, self._awardRatio)
    self._ccbOwner.node_contain:addChild(panel)
    self._height = panel:getHeight()

	panel:startAnimation(function()
	    	self:_showFinishedAnimation()
	    end)
end

function QUIDialogNetalCityQuickFight:_showFinishedAnimation()
	local ccbProxy = CCBProxy:create()
    local ccbOwner = {}
    local node = CCBuilderReaderLoad("ccb/effects/saodangwancheng.ccbi", ccbProxy, ccbOwner)
    self._ccbOwner.node_contain:addChild(node)
    node:setPositionY(-self._height - 100)
    node:setPositionX(ccbOwner.sp_saodang:getContentSize().width/2 + 100)
    self._isEnd = true
    self._ccbOwner.btn_one:setVisible(true)
end

function QUIDialogNetalCityQuickFight:_onTriggerQuickFightOne(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_fight) == false then return end
    self._isAgain = true

    self:_onTriggerClose()
end

function QUIDialogNetalCityQuickFight:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogNetalCityQuickFight:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
  	app.sound:playSound("common_close")

    if self._isEnd then
	   self:playEffectOut()
    end
end

function QUIDialogNetalCityQuickFight:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback(self._isAgain)
	end
end

return QUIDialogNetalCityQuickFight
