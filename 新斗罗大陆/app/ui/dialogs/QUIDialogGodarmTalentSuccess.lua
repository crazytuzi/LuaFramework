-- @Author: liaoxianbo
-- @Date:   2019-12-31 18:16:35
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-21 17:01:37
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGodarmTalentSuccess = class("QUIDialogGodarmTalentSuccess", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetGodarmBox = import("..widgets.QUIWidgetGodarmBox")
local QActorProp = import("...models.QActorProp")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogGodarmTalentSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_Godarm_tianfujihuo.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
	}
	QUIDialogGodarmTalentSuccess.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
	app.sound:playSound("task_complete")

    self._godarmId = options.godarmId
    self._callback = options.callback
	self._successTip = options.successTip
	self._godarmInfo = remote.godarm:getGodarmById(self._godarmId)
	self._godarmConfig = db:getCharacterByID(self._godarmId)
    self._isSelected = false
    
	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

	local newMasterInfo = db:getGodarmMasterByAptitudeAndLevel(self._godarmConfig.aptitude, self._godarmInfo.level)

	self._ccbOwner.tf_mount_name:setString(self._godarmConfig.name)
	if self._mountBox == nil then
	    self._mountBox = QUIWidgetGodarmBox.new()
	    self._ccbOwner.node_head:addChild(self._mountBox)
	end
    self._mountBox:setGodarmInfo(self._godarmInfo)
    self._mountBox:showRedTips(false)

    self._ccbOwner.tf_name:setString(newMasterInfo.master_name)
    self._ccbOwner.tf_name1:setString(newMasterInfo.master_name)
    self._ccbOwner.tf_name2:setString(newMasterInfo.master_name)

	local propInfo = self:calculateCombinationProp(newMasterInfo)
	self._ccbOwner.tf_prop:setString("天赋属性："..(propInfo[1] or "").."   "..(propInfo[2] or ""))

	self._ccbOwner.node_select:setVisible(app.master:showMasterSelect(self._successTip))
    self._ccbOwner.tf_show_tips:setString(app.master:getMasterShowTips())
    self:showSelectState()

	self._playOver = false
	scheduler.performWithDelayGlobal(function ()
		self._playOver = true
	end, 2)
end

function QUIDialogGodarmTalentSuccess:calculateCombinationProp(masterInfo)
	local propInfo = {}
	local index = 1
	for name,filed in pairs(QActorProp._field) do
		if masterInfo[name] and masterInfo[name] > 0 then
			local value = masterInfo[name]
			if filed.isPercent then
				value = (value*100).."%"
			end
			propInfo[index] = filed.name.." +"..value
			index = index + 1
		end
	end
	return propInfo
end


function QUIDialogGodarmTalentSuccess:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not self._isSelected)
end

function QUIDialogGodarmTalentSuccess:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogGodarmTalentSuccess:_backClickHandler()
	if self._playOver == true then
		self:playEffectOut()
	end
end

function QUIDialogGodarmTalentSuccess:viewAnimationOutHandler()
	local callback = self._callback

	if self._isSelected then
        app.master:setMasterShowState(self._successTip)
    end

	self:popSelf()
	if callback ~= nil then
		callback()
	end
end

return QUIDialogGodarmTalentSuccess
