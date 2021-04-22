-- @Author: xurui
-- @Date:   2020-04-17 11:19:11
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-09-14 19:08:45
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDungeonSkipBattle = class("QUIDialogDungeonSkipBattle", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")

function QUIDialogDungeonSkipBattle:ctor(options)
	local ccbFile = "ccb/Dialog_select.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerSelect", callback = handler(self, self._onTriggerSelect)},
		{ccbCallbackName = "onTriggerCharge", callback = handler(self, self._onTriggerCharge)},
		{ccbCallbackName = "onTriggerContinue", callback = handler(self, self._onTriggerContinue)},
    }
    QUIDialogDungeonSkipBattle.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._battleCallback = options.battleCallback
    	self._skipBattleCallback = options.skipBattleCallback
      self._selectCallback = options.selectCallback
    end

    q.setButtonEnableShadow(self._ccbOwner.btn_change)
    q.setButtonEnableShadow(self._ccbOwner.btn_continue)
	  self._bSelect = false

    self._ccbOwner.frame_tf_title:setString("系统提示")
    self._ccbOwner.tf_okbtn_text:setString("进入战斗")
    self._ccbOwner.tf_canclebtn_text:setString("跳过战斗")
    self._ccbOwner.tf_tips:setString("本次登录不再显示")
    self._ccbOwner.node_tip:setPositionX(-150)
    self._ccbOwner.node_tip:setPositionY(10)
    self._ccbOwner.normalText:setPositionY(70)
end

function QUIDialogDungeonSkipBattle:viewDidAppear()
	QUIDialogDungeonSkipBattle.super.viewDidAppear(self)

	self:setInfo()
end

function QUIDialogDungeonSkipBattle:viewWillDisappear()
  	QUIDialogDungeonSkipBattle.super.viewWillDisappear(self)

end

function QUIDialogDungeonSkipBattle:setInfo()
	if self._richText == nil then
		self._richText = QRichText.new("战力远超出当前关卡，是否选择跳过战斗直接获取本关奖励？", 360, {autoCenter = true})
		self._richText:setAnchorPoint(ccp(0.5, 1))
		-- self._richText:setPositionY(20)
		self._ccbOwner.normalText:addChild(self._richText)
	end
	self:setSelectStatus()
end

function QUIDialogDungeonSkipBattle:setSelectStatus(  )
	self._ccbOwner.sp_on:setVisible(self._bSelect)
end

function QUIDialogDungeonSkipBattle:_onTriggerSelect()
  	app.sound:playSound("common_small")

  	self._bSelect = not self._bSelect
    local selectCallback = self._selectCallback
    if selectCallback then
      selectCallback(self._bSelect)
    end
  	-- remote.instance.showSkipBattle = not self._bSelect
  	self:setSelectStatus()
end

function QUIDialogDungeonSkipBattle:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogDungeonSkipBattle:_onTriggerClose()
  	app.sound:playSound("common_close")
    -- local selectCallback = self._selectCallback
    -- if selectCallback then
    --   selectCallback(self._bSelect)
    -- end
    -- remote.instance.showSkipBattle = true
	self:playEffectOut()
end

function QUIDialogDungeonSkipBattle:_onTriggerCharge()
  	app.sound:playSound("common_small")
  	local battleCallback = self._battleCallback
  	self:popSelf()

  	if battleCallback then
  		battleCallback()
  	end
end

function QUIDialogDungeonSkipBattle:_onTriggerContinue()
  	app.sound:playSound("common_small")

  	local skipBattleCallback = self._skipBattleCallback

  	self:popSelf()

  	if skipBattleCallback then
  		skipBattleCallback()
  	end
end

return QUIDialogDungeonSkipBattle
