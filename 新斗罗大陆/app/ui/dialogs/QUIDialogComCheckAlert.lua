-- @Author: vicentboo
-- @Date:   2019-04-22 16:08:42
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-07-15 16:57:40
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogComCheckAlert = class("QUIDialogComCheckAlert", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIDialogComCheckAlert:ctor(options)
	local ccbFile = "ccb/Dialog_select.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
		{ccbCallbackName = "onTriggerCharge", callback = handler(self, self._onTriggerCharge)},
		{ccbCallbackName = "onTriggerContinue", callback = handler(self, self._onTriggerContinue)},
    }
    QUIDialogComCheckAlert.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._ccbOwner.frame_tf_title:setString("系统提示")
	
    if options then
    	self._callBack = options.callBack
    	self._richTextContent = options.richTextContent or {}
    	self._dailyTimeType = options.dailyTimeType
    	self._okBtnText = options.okBtnText or "确定"
    	self._cancleBtnText = options.cancleBtnText or "取消"
    	self._tipsType = options.tipsType
    end

    if self._tipsType == "FOREVER" then
    	self._ccbOwner.tf_tips:setString("不再显示")
	    self._ccbOwner.node_tip:setPositionX(-120)
	    self._ccbOwner.node_tip:setPositionY(10)
	    self._ccbOwner.normalText:setPositionY(70)    	
    end

    q.setButtonEnableShadow(self._ccbOwner.btn_change)
    q.setButtonEnableShadow(self._ccbOwner.btn_continue)
	self._bSelect = false
	self._iBtnType = 1     --1，确定按钮；2，取消按钮
end

function QUIDialogComCheckAlert:viewDidAppear()
	QUIDialogComCheckAlert.super.viewDidAppear(self)

	self:addBackEvent(true)
	self:setInfo()
end

function QUIDialogComCheckAlert:viewWillDisappear()
  	QUIDialogComCheckAlert.super.viewWillDisappear(self)

	self:removeBackEvent()
end
function QUIDialogComCheckAlert:setInfo()
	if self._richText == nil then
		self._richText = QRichText.new(self._richTextContent,360)
		self._richText:setAnchorPoint(ccp(0.5, 1))
		-- self._richText:setPositionY(20)
		self._ccbOwner.normalText:addChild(self._richText)
	end
	self._ccbOwner.tf_okbtn_text:setString(self._okBtnText)
	self._ccbOwner.tf_canclebtn_text:setString(self._cancleBtnText)
	self:setSelectStatus()
end

function QUIDialogComCheckAlert:setSelectStatus(  )
	self._ccbOwner.sp_on:setVisible(self._bSelect)
end

function QUIDialogComCheckAlert:_onTriggerSelect()
  	app.sound:playSound("common_small")

  	self._bSelect = not self._bSelect
  	self:setSelectStatus()
end

function QUIDialogComCheckAlert:_backClickHandler()
	self._iBtnType = 0

    self:_onTriggerClose()
end

function QUIDialogComCheckAlert:_onTriggerClose()
  	app.sound:playSound("common_close")

  	if self._bSelect then
  		if self._tipsType == "FOREVER" then
  			app:getUserOperateRecord():setRecordByType(self._dailyTimeType,true)
  		else
  			app:getUserOperateRecord():recordeCurrentTime(self._dailyTimeType)
  		end
  	end

	self:playEffectOut()
end

function QUIDialogComCheckAlert:_onTriggerCharge()
  	app.sound:playSound("common_small")

  	self._iBtnType = 1
    self:_onTriggerClose()
end

function QUIDialogComCheckAlert:_onTriggerContinue()
  	app.sound:playSound("common_small")

  	self._iBtnType = 2
    self:_onTriggerClose()
end

function QUIDialogComCheckAlert:viewAnimationOutHandler()
	local callback = self._callBack
	local iBtnType = self._iBtnType

	self:popSelf()

	if callback and iBtnType == 1 then
		callback()
	end
end

return QUIDialogComCheckAlert
