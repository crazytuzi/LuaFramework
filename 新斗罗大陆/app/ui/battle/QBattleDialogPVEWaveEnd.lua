--
-- Author: nieming
-- Date: 2016-10-09 20:39:10
--
local QBattleDialog = import(".QBattleDialog")
local QBattleDialogPVEWaveEnd = class("QBattleDialogPVEWaveEnd", QBattleDialog)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QBattleDialogPVEWaveEnd:ctor(options,owner)
	local ccbFile = "ccb/Dialog_tower_zdsl.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerNext", callback = handler(self, QBattleDialogPVEWaveEnd._onTriggerNext)},
	}
	if owner == nil then 
		owner = {}
	end
	QBattleDialogPVEWaveEnd.super.ctor(self,ccbFile,owner,callBacks)
	self._options = options

	local animationManager = tolua.cast(self._ccbNode:getUserObject(), "CCBAnimationManager")
	animationManager:runAnimationsForSequenceNamed("timeline1")
	self.stayTime = 5
	self._ccbOwner.countdownTime:setString(string.format("%s", self.stayTime))
	self._countdownScheduler = scheduler.scheduleGlobal(function(  )
		if self.stayTime > 0 then
			self.stayTime = self.stayTime - 1
			self._ccbOwner.countdownTime:setString(string.format("%s", self.stayTime))
		else
			self:onClose()
		end
	end,1)
end

function QBattleDialogPVEWaveEnd:_onTriggerNext()
  	app.sound:playSound("common_item")
	self:onClose()
end

function QBattleDialogPVEWaveEnd:onClose()
	if self._countdownScheduler then
   		scheduler.unscheduleGlobal(self._countdownScheduler)
   		self._countdownScheduler = nil
    end

    if app.battle:isInReplay() then
    	local record = app:getBattleRecordList()[2]
	    local config = record.dungeonConfig
	    config.isReplay = true
	    config.replayTimeSlices = record.recordTimeSlices
	    config.replayRandomSeed = record.recordRandomSeed
	    config.heroInfos = config.pveMultipleInfos[2].heroes
	    config.supportHeroInfos = config.pveMultipleInfos[2].supports
	    config.supportSkillHeroIndex = config.pveMultipleInfos[2].supportSkillHeroIndex
	    config.supportSkillHeroIndex2 = config.pveMultipleInfos[2].supportSkillHeroIndex2
        config.userSoulSpirits = config.pveMultipleInfos[2].soulSpirits
        config.heroGodArmIdList = config.pveMultipleInfos[2].godArmIdList
	    config.pveMultipleWave = 2 
	    config.battleLog1 = self._options.battleLog1

	    app.scene._dungeonConfig = config
    else
	    self._options.dungeonConfig.heroInfos = self._options.dungeonConfig.pveMultipleInfos[2].heroes
	    self._options.dungeonConfig.supportHeroInfos = self._options.dungeonConfig.pveMultipleInfos[2].supports
	    self._options.dungeonConfig.supportSkillHeroIndex = self._options.dungeonConfig.pveMultipleInfos[2].supportSkillHeroIndex
        self._options.dungeonConfig.supportSkillHeroIndex2 = self._options.dungeonConfig.pveMultipleInfos[2].supportSkillHeroIndex2
        self._options.dungeonConfig.userSoulSpirits = self._options.dungeonConfig.pveMultipleInfos[2].soulSpirits
        self._options.dungeonConfig.heroGodArmIdList = self._options.dungeonConfig.pveMultipleInfos[2].godArmIdList
	    self._options.dungeonConfig.supportHeroInfos2 = nil
	    self._options.dungeonConfig.pveMultipleWave = 2
	    self._options.dungeonConfig.battleLog1 = self._options.battleLog1
	end
 	if self._options.callback then
 		self._options.callback()
	end
end

return QBattleDialogPVEWaveEnd
