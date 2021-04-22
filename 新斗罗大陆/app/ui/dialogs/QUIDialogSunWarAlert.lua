--
-- Author: Kumo
-- Date: 2016-02-18 14:08:11
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSunWarAlert = class("QUIDialogSunWarAlert", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QColorLabel = import("...utils.QColorLabel")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QVIPUtil = import("...utils.QVIPUtil")

-- QUIDialogSunWarAlert.REVIVE_EVENT = "REVIVE_EVENT"

function QUIDialogSunWarAlert:ctor(options) 
	assert(options ~= nil, "alert dialog options is nil !")
 	local ccbFile = "ccb/Dialog_VipChongzhi_client.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSunWarAlert._onTriggerClose)},
	    {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogSunWarAlert._onTriggerConfirm)},
	    {ccbCallbackName = "onTriggerBack", callback = handler(self, QUIDialogSunWarAlert._onTriggerBack)},
	}
	QUIDialogSunWarAlert.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	
	self.isAnimation = options.isAnimation == nil and true or false
	self:_init()
end

function QUIDialogSunWarAlert:_init()
	local buff = remote.sunWar:getInspectBuffUpValue()
	if buff > 0 then
		self._ccbOwner.tf_content:setString("魂师大人，是否满血复活我方所有魂师？本次复活全员将获得战力提升"..buff.."%的效果。")
	else
		self._ccbOwner.tf_content:setString("魂师大人，是否满血复活我方所有魂师？")
	end
	self._ccbOwner.tf_content:setVisible(true)
	self._ccbOwner.node_text:setVisible(false)
	-- self._ccbOwner.tf_zaixiangxiang:setString("取  消")
	self._ccbOwner.tf_quchongzhi:setString("复  活")
	self._ccbOwner.frame_tf_title:setString("复  活")
end

function QUIDialogSunWarAlert:viewDidAppear()
	QUIDialogSunWarAlert.super.viewDidAppear(self)
	self:addBackEvent(false)
end

function QUIDialogSunWarAlert:viewWillDisappear()
	QUIDialogSunWarAlert.super.viewWillDisappear(self)
	self:removeBackEvent()
end

function QUIDialogSunWarAlert:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSunWarAlert:_onTriggerBack(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_back) == false then return end

	self:_onTriggerClose()
end

function QUIDialogSunWarAlert:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
   	self:playEffectOut()
end

function QUIDialogSunWarAlert:_onTriggerConfirm(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_recharge) == false then return end
	local canReviveCount = remote.sunWar:getCanReviveCount()
	if canReviveCount > 0 then
		app:getClient():sunwarHeroReviveRequest(false, function(response)
			remote.sunWar:sendReviveEvent()
			remote.sunWar:responseHandler(response)

			-- remote.sunWar:addBuff( true )
			-- self:dispatchEvent({name = QUIDialogSunWarAlert.REVIVE_EVENT})
			self:playEffectOut()
		end)
	else
		app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBuyVirtual",
  			options = {typeName = ITEM_TYPE.SUNWAR_REVIVE_COUNT}})
  		-- app.tip:floatTip("魂师大人，复活次数不足，购买功能尚未开放，敬请期待！")
	end
end

function QUIDialogSunWarAlert:_backClickHandler()
	self:_onTriggerClose()
end
return QUIDialogSunWarAlert