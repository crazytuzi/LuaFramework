local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDragonTotemUpgradeSuccess = class("QUIDialogDragonTotemUpgradeSuccess", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogDragonTotemUpgradeSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_Weever_totem_ug.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", 				callback = handler(self, self._onTriggerClose)},
		-- {ccbCallbackName = "onTriggerUpgrade", 				callback = handler(self, self._onTriggerUpgrade)},		
	}
	QUIDialogDragonTotemUpgradeSuccess.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = false

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	
	self._index = options.index
	local totemInfo = remote.dragonTotem:getTotemInfo()
	self._ccbOwner.tf_level1:setString("Lv."..(totemInfo.grade - 1))
	self._ccbOwner.tf_level2:setString("Lv."..totemInfo.grade)

	local config = remote.dragonTotem:getConfigByIdAndLevel(self._index, totemInfo.grade - 1)
	local nextConfig = remote.dragonTotem:getConfigByIdAndLevel(self._index, totemInfo.grade)
	self._ccbOwner.tf_desc1:setString(self:getSkillStr(config))
	self._ccbOwner.tf_desc2:setString(self:getSkillStr(nextConfig))

	local dragonInfo = remote.dragon:getDragonInfo()
	local _dragonId = dragonInfo and dragonInfo.dragonId or 1
    if self._dragonId ~= _dragonId then
        self._dragonId = _dragonId
        self._ccbOwner.node_avatar:removeAllChildren()
        local fca, name, dragonConfig = remote.dragonTotem:getDragonAvatarFcaAndNameByDragonId(_dragonId)
        if fca then
            local avatar = QUIWidgetFcaAnimation.new(fca, "actor", {backSoulShowEffect = dragonConfig.effect})
            avatar:setScaleX(-global.dragon_spine_scale)
            avatar:setScaleY(global.dragon_spine_scale)
            avatar:setPositionY(global.dragon_spine_offsetY)
            self._ccbOwner.node_avatar:addChild(avatar)
        end
    end

	self._isEnd = false
	scheduler.performWithDelayGlobal(function ()
		self._isEnd = true
	end, 1.6)
    app.sound:playSound("hero_grow_up")
end

function QUIDialogDragonTotemUpgradeSuccess:getSkillStr(config)
	local skillId = config.skill_id
	if skillId ~= nil then
		local skillData = QStaticDatabase:sharedDatabase():getSkillDataByIdAndLevel(skillId, config.level)
		return skillData.description_1 or ""
	end
end

function QUIDialogDragonTotemUpgradeSuccess:_backClickHandler()
	if self._isEnd  == false then return end
	app.sound:playSound("common_cancel")
	local callback = self:getOptions().callback
	self:popSelf()
	if callback ~= nil then
		callback()
	end
end

return QUIDialogDragonTotemUpgradeSuccess
