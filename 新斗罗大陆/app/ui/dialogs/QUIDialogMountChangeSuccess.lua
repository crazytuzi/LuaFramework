-- @Author: zhouxiaoshu
-- @Date:   2019-10-24 11:26:55
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-21 16:32:45

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMountChangeSuccess = class("QUIDialogMountChangeSuccess", QUIDialog)
local QUIWidgetMountBox = import("..widgets.mount.QUIWidgetMountBox")
local QColorLabel = import("...utils.QColorLabel")
local QActorProp = import("...models.QActorProp")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogMountChangeSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_Weapon_change_success.ccbi"
	local callBacks = {}
	QUIDialogMountChangeSuccess.super.ctor(self,ccbFile,callBacks,options)

    self.isAnimation = true --是否动画显示
	app.sound:playSound("hero_breakthrough")
	self._isEnd = false

	self._callback = options.callback
	self._mountId = options.mountId
	self._mountInfo = remote.mount:getMountById(self._mountId)
    local charaterConfig = db:getCharacterByID(self._mountInfo.zuoqiId)

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	
    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))

    local reformLevel = self._mountInfo.reformLevel or 1
	local oldGradeConfig = db:getReformConfigByAptitudeAndLevel(charaterConfig.aptitude, reformLevel - 1)
    local oldMountBox = QUIWidgetMountBox.new()
    local oldMountInfo = clone(self._mountInfo)
    oldMountBox:setMountInfo(oldMountInfo)
    oldMountBox:setStarVisible(true)
    self._ccbOwner.old_head:addChild(oldMountBox)

    local nameStr1 = charaterConfig.name
    if reformLevel > 1 then
    	nameStr1 = nameStr1.."+"..(reformLevel-1)
    end
    local nameStr2 = charaterConfig.name.."+"..reformLevel
    self._ccbOwner.tf_old_name:setString(nameStr1)
    self._ccbOwner.tf_new_name:setString(nameStr2)
    
    local color = remote.mount:getColorByMountId(self._mountId)
    local fontColor = QIDEA_QUALITY_COLOR[color]
    self._ccbOwner.tf_old_name:setColor(fontColor)
    self._ccbOwner.tf_new_name:setColor(fontColor)

    local props = QActorProp:getPropUIByConfig(oldGradeConfig)
	local index = 1
	for i, prop in pairs(props) do
		if self._ccbOwner["prop_node_"..index] then
			self._ccbOwner["name_"..index]:setString(prop.name)
			self._ccbOwner["old_prop_"..index]:setString(prop.value)
		end
		index = index + 1
	end

	local newGradeConfig = db:getReformConfigByAptitudeAndLevel(charaterConfig.aptitude, reformLevel)
    local newMountBox = QUIWidgetMountBox.new()
    local newMountInfo = clone(self._mountInfo)
    newMountBox:setMountInfo(newMountInfo)
    newMountBox:setStarVisible(true)
	self._ccbOwner.new_head:addChild(newMountBox)

    local props = QActorProp:getPropUIByConfig(newGradeConfig)
	local index = 1
	for i, prop in pairs(props) do
		if self._ccbOwner["prop_node_"..index] then
			self._ccbOwner["new_prop_"..index]:setString(prop.value)
		end
		index = index + 1
	end
end

function QUIDialogMountChangeSuccess:animationEndHandler(name)
	self._animationStage = name
end

function QUIDialogMountChangeSuccess:_onTriggerClose()
	if self._isEnd == true then
		self:playEffectOut()
	else
		if self._animationStage == "1" then
			self._animationManager:runAnimationsForSequenceNamed("2")
		else
			self._isEnd = true
		end
	end
end

function QUIDialogMountChangeSuccess:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogMountChangeSuccess:viewAnimationOutHandler()
	local callback = self._callback
	self:popSelf()
	if callback ~= nil then
		callback()
	end
end

return QUIDialogMountChangeSuccess