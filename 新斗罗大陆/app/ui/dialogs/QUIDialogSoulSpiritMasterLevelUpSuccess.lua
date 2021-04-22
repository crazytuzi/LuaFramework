--
-- Kumo.Wang
-- 魂灵升级激活护佑天赋界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritMasterLevelUpSuccess = class("QUIDialogSoulSpiritMasterLevelUpSuccess", QUIDialog)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QActorProp = import("...models.QActorProp")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogSoulSpiritMasterLevelUpSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_Master_LevelUp_Success.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)}
	}
	QUIDialogSoulSpiritMasterLevelUpSuccess.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
	app.sound:playSound("task_complete")

	if options then
	    self._id = options.id
	    self._callBack = options.callback
   	end

    local titleWidget = QUIWidgetTitelEffect.new()
    self._ccbOwner.node_title_effect:addChild(titleWidget)

   	local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
    local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(self._id)
   	local masterConfig = remote.soulSpirit:getMasterConfigByAptitudeAndSoulSpiritLevel(characterConfig.aptitude, soulSpiritInfo.level)

   	self._ccbOwner.node_avatar:removeAllChildren()
    local avatar = QUIWidgetActorDisplay.new(self._id)
    avatar:setScale(1.2)
    self._ccbOwner.node_avatar:addChild(avatar)
    -- self._ccbOwner.node_avatar:setScaleX(-1)

    self._ccbOwner.tf_name:setString(masterConfig and masterConfig.master_name or "")
    if masterConfig then
        local propDic = remote.soulSpirit:getPropDicByConfig(masterConfig)
        for key, value in pairs(propDic) do
            if value > 0 then
                local name = QActorProp._field[key].uiName or QActorProp._field[key].name
                local isPercent = QActorProp._field[key].isPercent
                local str = q.getFilteredNumberToString(tonumber(value), isPercent, 2)  
                self._ccbOwner.tf_prop:setString("【"..masterConfig.master_name.."】被护佑魂师"..name.."+"..str.."（魂灵"..masterConfig.condition.."级激活）")
                break
            end
        end
    else
        self._ccbOwner.tf_prop:setString("")
    end

    self._isSelected = false
    self:_showSelectStatus()

	self._playOver = false
	scheduler.performWithDelayGlobal(function ()
		self._playOver = true
	end, 2)
end

function QUIDialogSoulSpiritMasterLevelUpSuccess:_showSelectStatus()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
end

function QUIDialogSoulSpiritMasterLevelUpSuccess:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:_showSelectStatus()
end

function QUIDialogSoulSpiritMasterLevelUpSuccess:viewWillDisappear()
    if self._isSelected then
        remote.soulSpirit:setDevourUpGradeShowState()
    end
end

function QUIDialogSoulSpiritMasterLevelUpSuccess:_backClickHandler()
	if self._playOver == true then
		self:playEffectOut()
		if self._callBack then
			self._callBack()
		end
	end
end

return QUIDialogSoulSpiritMasterLevelUpSuccess
