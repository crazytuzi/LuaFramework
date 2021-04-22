-- @Author: zhouxiaoshu
-- @Date:   2019-10-23 17:58:03
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-21 16:29:17

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMountSoulGuideGradeSuccess = class("QUIDialogMountSoulGuideGradeSuccess", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QHeroModel = import("...models.QHeroModel")
local QUIWidgetMountBox = import("..widgets.mount.QUIWidgetMountBox")
local QUIWidgetHeroHeadVibrate = import("..widgets.QUIWidgetHeroHeadVibrate")
local QColorLabel = import("...utils.QColorLabel")
local QUIViewController = import("..QUIViewController")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogMountSoulGuideGradeSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_Weapon_soul_guide_success.ccbi"
	local callBacks = {}
	QUIDialogMountSoulGuideGradeSuccess.super.ctor(self,ccbFile,callBacks,options)

    self.isAnimation = true --是否动画显示
	app.sound:playSound("hero_breakthrough")
	self._isEnd = false

	self._callback = options.callback

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

	self._animationStage = "1"
    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:runAnimationsForSequenceNamed("1")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))

	local soulGuideLevel = remote.user:getPropForKey("soulGuideLevel") or 1
	local oldConfig = db:getSoulGuideConfigByLevel(soulGuideLevel-1) or {}
	local newConfig = db:getSoulGuideConfigByLevel(soulGuideLevel)
	self._ccbOwner.tf_old_name:setString((soulGuideLevel-1).."级属性")
	self._ccbOwner.tf_new_name:setString(soulGuideLevel.."级属性")
	local index = 1
	index = self:setPropTF(index, "生    命", oldConfig.team_hp_value or 0, newConfig.team_hp_value or 0)
	index = self:setPropTF(index, "攻    击", oldConfig.team_attack_value or 0, newConfig.team_attack_value or 0)
	index = self:setPropTF(index, "物理防御", oldConfig.team_armor_physical or 0, newConfig.team_armor_physical or 0)
	index = self:setPropTF(index, "法术防御", oldConfig.team_armor_magic or 0, newConfig.team_armor_magic or 0)
end

function QUIDialogMountSoulGuideGradeSuccess:setPropTF(index, name, value1, value2)
	if index > 4 then return index end
	self._ccbOwner["node_title_"..index]:setString(name.."：")
	self._ccbOwner["tf_old_value_"..index]:setString(value1)
	self._ccbOwner["tf_new_value_"..index]:setString(value2)
	return index + 1
end

function QUIDialogMountSoulGuideGradeSuccess:animationEndHandler(name)
	self._animationStage = name
end

function QUIDialogMountSoulGuideGradeSuccess:_onTriggerClose()
	if self._isEnd == true then
		local masterConfig = self:getMaterConfig()
		if masterConfig then
			local callback = self._callback
			self:popSelf()
			app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountMaterGuideGradeSuccess",
				options = { masterConfig = masterConfig, callback = callback}})
		else
			self:playEffectOut()
		end
	else
		if self._animationStage == "1" then
			self._animationManager:runAnimationsForSequenceNamed("2")
		else
			self._isEnd = true
		end
	end
end

function QUIDialogMountSoulGuideGradeSuccess:getMaterConfig()
    local masterConfig = nil
	local configs = db:getStaticByName("soul_arms_science_tianfu")
	local soulGuideLevel = remote.user:getPropForKey("soulGuideLevel") or 1
    for i, config in pairs(configs) do
    	if config.condition == soulGuideLevel then
    		masterConfig = config
    		break
    	end
	end
	return masterConfig
end

function QUIDialogMountSoulGuideGradeSuccess:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogMountSoulGuideGradeSuccess:viewAnimationOutHandler()
	local callback = self._callback
	self:popSelf()
	
   	if callback then
		callback()
	end
end

return QUIDialogMountSoulGuideGradeSuccess