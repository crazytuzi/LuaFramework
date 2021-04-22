
local QBattleDialog = import(".QBattleDialog")
local QBattleDialogPause = class("QBattleDialogPause", QBattleDialog)
local QBattleHelpDescribePause = import(".QBattleHelpDescribePause")
local QUserData = import("...utils.QUserData")
function QBattleDialogPause:ctor(owner, options)
	local ccbFile = "Battle_Dialog_Pause.ccbi"
	if app.battle:isInTotemChallenge() then
		ccbFile = "Battle_Dialog_Pause_totemchallenge.ccbi"
	end
	if owner == nil then
		owner = {}
	end
	owner.onTriggerSelect = handler(self, self.onTriggerSelect)
	owner.onTriggerHelp = handler(self, self.onTriggerHelp)
    owner.onClose = handler(self, self.onClose)

    owner.onAbort = handler(self, self.onAbort)
    owner.onRestart = handler(self, self.onRestart)
    owner.onContinue = handler(self, self.onContinue)
    owner.onTriggerSelectNumber = handler(self, self.onTriggerSelectNumber)

    self._onAbortCallBack = options.onAbortCallBack
    self._onRestartCallBack = options.onRestartCallBack

	QBattleDialogPause.super.ctor(self, ccbFile, owner)

	local unlock_number = remote.user.level >= 60

	self._ccbOwner.sp_select:setVisible(not app.battle:isDisableAI())
	self._ccbOwner.frame_tf_title:setString("游戏暂停")

	self._isReplay = options.isReplay
	if options.isReplay then
		owner.label_abort:setString("退出观看")
		owner.label_restart:setString("重新观看")
		owner.label_resume:setString("继续观看")
		if unlock_number then
			owner.auto_move_node:setVisible(false)
			owner.node_number:setVisible(true)
			if not app.battle:isInTotemChallenge() then
				owner.node_number:setPositionY(-48)
				owner.node_btns:setPositionY(0)
			end
		else
			owner.auto_move_node:setVisible(false)
			owner.node_number:setVisible(false)
			if not app.battle:isInTotemChallenge() then
				owner.node_btns:setPositionY(-20)
			end
		end
	else
		if not unlock_number then
			owner.node_number:setVisible(false)
			owner.auto_move_node:setVisible(true)
			if not app.battle:isInTotemChallenge() then
				owner.auto_move_node:setPositionY(-48)
				owner.node_btns:setPositionY(0)
			end
		end
	end

	if app.battle:isInTotemChallenge() then
		owner.description_1:setDimensions(CCSize(440, 0))
		owner.description_1:setHorizontalAlignment(kCCTextAlignmentCenter)
		owner.description_1:setColor(COLORS.k)
		local str = db:getTotemAffixsConfigByBuffId(app.battle._dungeonConfig.totemChallengeBuffId)["ruletext"..app.battle:getPVPMultipleNewCurWave()]
		if str:find("#HERO_NAME#") then
			local affix = (app.battle._totem_challenge_affix_hero and app.battle._totem_challenge_affix_hero.kind and app.battle._totem_challenge_affix_hero.kind > 0) or app.battle._totem_challenge_affix_enemy
			if affix.target then
				str = string.gsub(str, "#HERO_NAME#", affix.target:getDisplayName())
				owner.description_1:setString(str)
			end
		else
			owner.description_1:setString(str)
		end
	end

	if unlock_number then
		owner.sp_show_number:setVisible(app.scene:isHideDamageNumber())
	end
end

function QBattleDialogPause:onTriggerSelect()
	if self._isReplay then
		return
	end

	local key = app.scene:getDisableAIKey()
	if key == nil then return end

	local old = self._ccbOwner.sp_select:isVisible()
	self._ccbOwner.sp_select:setVisible(not old)
	app.battle:setDisableAI(old)

	
    app:getUserData():setUserValueForKey(key, old and QUserData.STRING_FALSE or QUserData.STRING_TRUE)
end

function QBattleDialogPause:onTriggerHelp(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_help) == false then
        return
    end

	self:addChild(QBattleHelpDescribePause.new())
end 

function QBattleDialogPause:onAbort(event)
    if q.buttonEventShadow(event, self._ccbOwner.but_giveup) == false then
        return
    end
    self._onAbortCallBack()
end

function QBattleDialogPause:onRestart(event)
    if q.buttonEventShadow(event, self._ccbOwner.but_restart) == false then
        return
    end
    self._onRestartCallBack()
end

function QBattleDialogPause:onContinue(event)
    if q.buttonEventShadow(event, self._ccbOwner.but_resume) == false then
        return
    end
    self:_onOK()
end

function QBattleDialogPause:onClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then
        return
    end
    self:_onOK()
end

function QBattleDialogPause:onTriggerSelectNumber(event)
	local is_show = not app.scene:isHideDamageNumber()
    app.scene:setHideDamageNumber(is_show)
    self._ccbOwner.sp_show_number:setVisible(is_show)
end

return QBattleDialogPause

