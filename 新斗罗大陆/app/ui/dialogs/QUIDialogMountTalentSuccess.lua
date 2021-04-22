local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMountTalentSuccess = class("QUIDialogMountTalentSuccess", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetMountBox = import("..widgets.mount.QUIWidgetMountBox")
local QActorProp = import("...models.QActorProp")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogMountTalentSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_Weapon_mijijihuo_6.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
	}
	QUIDialogMountTalentSuccess.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
	app.sound:playSound("task_complete")

    self._mountId = options.mountId
    self._callback = options.callback
	self._successTip = options.successTip
	self._mountInfo = options.mountInfo
	self._mountConfig = options.mountConfig
	self._titilePath = options.titilePath
	self._talentDes = options.talentDes

    self._isSelected = false
    local newMasterInfo = options.newMasterInfo

    if self._titilePath then
    	QSetDisplayFrameByPath(self._ccbOwner.sp_title,self._titilePath)
    end

    if self._talentDes then
    	self._ccbOwner.tf_talent_des:setString(self._talentDes)
    end

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

	self._ccbOwner.tf_mount_name:setString(self._mountConfig.name)
	if self._mountBox == nil then
	    self._mountBox = QUIWidgetMountBox.new()
	    self._ccbOwner.node_head:addChild(self._mountBox)
	end
    self._mountBox:setMountInfo(self._mountInfo)
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

function QUIDialogMountTalentSuccess:calculateCombinationProp(masterInfo)
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


function QUIDialogMountTalentSuccess:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not self._isSelected)
end

function QUIDialogMountTalentSuccess:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogMountTalentSuccess:_backClickHandler()
	if self._playOver == true then
		self:playEffectOut()
	end
end

function QUIDialogMountTalentSuccess:viewAnimationOutHandler()
	local callback = self._callback

	if self._isSelected then
        app.master:setMasterShowState(self._successTip)
    end

	self:popSelf()
	if callback ~= nil then
		callback()
	end
end

return QUIDialogMountTalentSuccess
