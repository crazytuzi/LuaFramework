
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDragonTotemTalentSuccess = class("QUIDialogDragonTotemTalentSuccess", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")
local QUIWidgetFcaAnimation = import("..widgets.actorDisplay.QUIWidgetFcaAnimation")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogDragonTotemTalentSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_Weever_talentjihuo.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerClose", 				callback = handler(self, self._onTriggerClose)},
		-- {ccbCallbackName = "onTriggerUpgrade", 				callback = handler(self, self._onTriggerUpgrade)},		
	}
	QUIDialogDragonTotemTalentSuccess.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true
	
	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

	self._index = options.index
	self._config = options.config
	self._gradeLevel = options.gradeLevel

	self._ccbOwner.tf_prop_effect:setVisible(false)
	-- self._ccbOwner.tf_level:setString("Lv."..self._gradeLevel)
	-- self._ccbOwner.talent_node:addChild(CCSprite:create(self._config.name_tianfu))
	-- self._ccbOwner.talent_node2:addChild(CCSprite:create(self._config.name_tianfu))
	self._ccbOwner.tf_skill_name_big:setString(self._config.dragon_name)
	self._ccbOwner.tf_skill_name_small:setString(self._config.dragon_name)
	local propDesc = self:getPropStr(self._config)
	local desc = ""
	for i=1,2 do
		if propDesc[i] ~= nil then
			if desc == "" then
				desc = desc..propDesc[i]
			else
				desc = desc.."   "..propDesc[i]
			end
		end
	end
	self._ccbOwner.tf_prop_dsec:setString("天赋属性："..desc)

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
	app.sound:playSound("task_complete")
end

function QUIDialogDragonTotemTalentSuccess:getPropStr(config)
	local props = {}
	for _,v in ipairs(QActorProp._uiFields) do
		if config[v.fieldName] ~= nil then
			table.insert(props, v)
		end
	end
	local propDesc = {}
	if props ~= nil and #props > 0 then
		for _,prop in ipairs(props) do
			local value = config[prop.fieldName]
			if prop.handlerFun ~= nil then
				value = prop.handlerFun(value)
			end
			table.insert(propDesc, prop.name.."+"..value)
		end
	end
	return propDesc
end

function QUIDialogDragonTotemTalentSuccess:_backClickHandler()
	if self._isEnd  == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogDragonTotemTalentSuccess
