local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogUnionDragonTrainLevelSucess = class("QUIDialogUnionDragonTrainLevelSucess", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QHeroModel = import("...models.QHeroModel")
local QUIWidgetMountBox = import("..widgets.mount.QUIWidgetMountBox")
local QUIWidgetHeroHeadVibrate = import("..widgets.QUIWidgetHeroHeadVibrate")
local QColorLabel = import("...utils.QColorLabel")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogUnionDragonTrainLevelSucess:ctor(options)
	local ccbFile = "ccb/Dialog_society_dragontrain_gradesuccess.ccbi"
	local callBacks = {}
	QUIDialogUnionDragonTrainLevelSucess.super.ctor(self,ccbFile,callBacks,options)

	app.sound:playSound("hero_breakthrough")
    self.isAnimation = true --是否动画显示
	self._isEnd = false

	self._callback = options.callback
	self._dragonLevel = options.level
	self._oldLevel = options.oldLevel

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	
    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("Default Timeline")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))

    self:setPropInfo()
end

function QUIDialogUnionDragonTrainLevelSucess:setPropInfo()
	local dragon = remote.dragon:getDragonInfo()
    if not self._dragonLevel then
    	self._dragonLevel = dragon.level
    end
	local str1 = "武魂"
	local str2 = "武魂"
	local oldLevel = self._oldLevel or self._dragonLevel - 1
	local dragonConfig = db:getUnionDragonConfigById(dragon.dragonId)
	if dragonConfig.type == remote.dragon.TYPE_WEAPON then
		str1 = string.format("lv.%d %s", oldLevel, dragonConfig.dragon_name or "")
		str2 = string.format("lv.%d %s", self._dragonLevel, dragonConfig.dragon_name or "")
	else
		str1 = string.format("lv.%d %s", oldLevel, dragonConfig.dragon_name or "")
		str2 = string.format("lv.%d %s", self._dragonLevel, dragonConfig.dragon_name or "")
	end
    self._ccbOwner.tf_old_name:setString(str1)
    self._ccbOwner.tf_new_name:setString(str2)

	local oldConfig = db:getUnionDragonInfoByLevel(oldLevel)
	local newConfig = db:getUnionDragonInfoByLevel(self._dragonLevel)
	local curProp = remote.dragon:getPropInfo(oldConfig)
	local nextProp = remote.dragon:getPropInfo(newConfig)
	for index = 1, 4 do
		if curProp[index] then
			self._ccbOwner["tf_old_value_"..index]:setString(curProp[index].value)
		else
			self._ccbOwner["tf_old_value_"..index]:setString("")
		end
		if nextProp[index] then
			self._ccbOwner["node_title_"..index]:setString(nextProp[index].name.."：")
			self._ccbOwner["tf_new_value_"..index]:setString(nextProp[index].value)
		else
			self._ccbOwner["node_title_"..index]:setString("")
			self._ccbOwner["tf_new_value_"..index]:setString("")
		end
	end
end

function QUIDialogUnionDragonTrainLevelSucess:animationEndHandler()
	self._isEnd = true
end

function QUIDialogUnionDragonTrainLevelSucess:_onTriggerClose()
	if self._isEnd then
		self:playEffectOut()
	end
end

function QUIDialogUnionDragonTrainLevelSucess:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogUnionDragonTrainLevelSucess:viewAnimationOutHandler()
	self:popSelf()
   	if self._callback then
		self._callback()
	end
end

return QUIDialogUnionDragonTrainLevelSucess