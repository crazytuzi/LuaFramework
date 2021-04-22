--
-- Author: Kumo
-- Date: 
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogThunderRobot = class("QUIDialogThunderRobot", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")

local NORMAL = "normal"
local ADVANCE = "advance"

function QUIDialogThunderRobot:ctor(options) 
 	local ccbFile = "ccb/Dialog_ThunderKing_saodang.ccbi"
	local callBacks = {
	    {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogThunderRobot._onTriggerClose)},
	    {ccbCallbackName = "onTriggerSelect", callback = handler(self, QUIDialogThunderRobot._onTriggerSelect)},
	    {ccbCallbackName = "onTriggerStart", callback = handler(self, QUIDialogThunderRobot._onTriggerStart)},
	}
	QUIDialogThunderRobot.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = options.isAnimation == nil and true or false

	self._normalIndex = options.normalIndex
	self._advanceIndex = options.advanceIndex
	self._curWaveIndex = options.curWaveIndex
	self._isFreeTime = options.isFreeTime

	self._ccbOwner.frame_tf_title:setString("一键扫荡")
	self:_init()
end

function QUIDialogThunderRobot:_init()
	self._isStartRobot = false
	if self._isFreeTime then
		self._isSelectedNormal = true
		self._isSelectedAdvance = false
	else
		self._isSelectedNormal = false
		self._isSelectedAdvance = false
	end

	-- 三星扫荡是否解锁
	self._isUnlockNormalRobot = app.unlock:checkLock("UNLOCK_THUNDER_QUICK_FIGHT")
	-- 一星扫荡是否解锁（全部扫荡）
	self._isUnlockAdvanceRobot = not self._isFreeTime
	if app.unlock:checkLock("UNLOCK_THUNDER_SAODANG") then
		self._isUnlockAdvanceRobot = true
	end

	self:_initView(NORMAL, self._isUnlockNormalRobot, "UNLOCK_THUNDER_QUICK_FIGHT", self._normalIndex)
	self:_initView(ADVANCE, self._isUnlockAdvanceRobot, "UNLOCK_THUNDER_QUICK_FIGHT_ALL", self._advanceIndex)

	self:_onTriggerSelect()
end

function QUIDialogThunderRobot:_initView( key, isUnlock, unlockKey, waveIndex )
	self._ccbOwner["sp_"..key.."_selected_off"]:setVisible(true)
	self._ccbOwner["sp_"..key.."_selected_on"]:setVisible(false)

	if isUnlock then
		self._ccbOwner["btn_"..key.."_select"]:setVisible(true)
		self._ccbOwner["tf_desc_"..key]:setString("可扫荡至:"..waveIndex.."关")

		makeNodeFromGrayToNormal( self._ccbOwner["node_"..key] )
		if self._curWaveIndex >= waveIndex then
			makeNodeFromNormalToGray( self._ccbOwner["node_"..key] )
			self._ccbOwner["layer_"..key]:setVisible(false)
			self._ccbOwner["btn_"..key.."_select"]:setVisible(false)
		else
			makeNodeFromGrayToNormal( self._ccbOwner["node_"..key] )
			self._ccbOwner["layer_"..key]:setVisible(true)
		end
	else
		self._ccbOwner["btn_"..key.."_select"]:setVisible(false)
		if key == NORMAL then
			local unlockConfig = app.unlock:getConfigByKey(unlockKey)
			self._ccbOwner["tf_desc_"..key]:setString("组合"..unlockConfig.team_level.."或VIP"..unlockConfig.vip_level.."解锁")
		else
			self._ccbOwner["tf_desc_"..key]:setString("每天第2次重置后解锁")
		end
		makeNodeFromNormalToGray( self._ccbOwner["node_"..key] )
		self._ccbOwner["layer_"..key]:setVisible(false)
	end
end

function QUIDialogThunderRobot:_onTriggerClose()
	self:close()
end

function QUIDialogThunderRobot:_onTriggerSelect(e, target)
	if e then
		if target == self._ccbOwner.btn_normal_select then
			self._isSelectedNormal = true
			self._isSelectedAdvance = false
		else
			self._isSelectedNormal = false
			self._isSelectedAdvance = true
		end
	end

	self:_updateSelectState( NORMAL, self._isSelectedNormal )
	self:_updateSelectState( ADVANCE, self._isSelectedAdvance )
end

function QUIDialogThunderRobot:_updateSelectState( key, value )
	self._ccbOwner["sp_"..key.."_selected_off"]:setVisible( not value )
	self._ccbOwner["sp_"..key.."_selected_on"]:setVisible( value )
end

function QUIDialogThunderRobot:_onTriggerStart(event)
	if q.buttonEventShadow(event,self._ccbOwner.btn_start) == false then return end
	if not self._isSelectedNormal and not self._isSelectedAdvance then
		app.tip:floatTip("请选择一种扫荡方式～")
		return
	end

	self._isStartRobot = true
	self:close()
end

function QUIDialogThunderRobot:_backClickHandler()
	self:close()
end

function QUIDialogThunderRobot:close()
	if app.sound ~= nil then
		app.sound:playSound("common_confirm")
	end
	self:playEffectOut()
end

function QUIDialogThunderRobot:viewAnimationOutHandler()
	app:getUserOperateRecord():setThunderRobot( NORMAL, self._isSelectedNormal )
	app:getUserOperateRecord():setThunderRobot( ADVANCE, self._isSelectedAdvance )

	local options = self:getOptions()
	local callback = options.callback

	self:popSelf()

	if callback ~= nil and self._isStartRobot then
		callback()
	end
end

return QUIDialogThunderRobot