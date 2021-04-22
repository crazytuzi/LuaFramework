--
-- zxs
-- 武魂真身天赋技能页签
--

local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetHeroArtifactSkillClient = class("QUIWidgetHeroArtifactSkillClient", QUIWidget)
local QScrollContain = import("...QScrollContain")
local QUIViewController = import("...QUIViewController")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIWidgetArtifactSkill = import("...widgets.artifact.QUIWidgetArtifactSkill")
local QUIWidgetAnimationPlayer = import("...widgets.QUIWidgetAnimationPlayer")

function QUIWidgetHeroArtifactSkillClient:ctor(options)
	local ccbFile = "ccb/Widget_artifact_tianfu_client.ccbi"
	local callBacks = {
	}
	QUIWidgetHeroArtifactSkillClient.super.ctor(self,ccbFile,callBacks,options)

	self._size = self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetHeroArtifactSkillClient:getContentSize()
	return self._size
end

function QUIWidgetHeroArtifactSkillClient:setInfo(actorId, learnPoint)
	self._actorId = actorId
	self._artifactId = remote.artifact:getArtiactByActorId(self._actorId)
	local skillConfig = remote.artifact:getSkillByArtifactId(self._artifactId)
	local uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local heroSkillInfos = uiHeroModel:getArtifactSkill()

	if #skillConfig > 6 then
		self._ccbOwner.sp_gray_7:setVisible(true)
		self._ccbOwner.node_super:setVisible(true)
		self._size.height = 770
	else
		self._ccbOwner.sp_gray_7:setVisible(false)
		self._ccbOwner.node_super:setVisible(false)
		self._size.height = 472
	end

	self._ccbOwner.sp_line_789:setVisible(false)
	for slot, skill in ipairs(skillConfig) do
		local slotConfig = heroSkillInfos[slot]
		local skillBox = QUIWidgetArtifactSkill.new()
		skillBox:setSkill(skill)
		skillBox:setLock(slotConfig.isLock)
		skillBox:addEventListener(QUIWidgetArtifactSkill.EVENT_CLICK, handler(self, self.skillClickHandler))
		skillBox:setName("")
		skillBox:setSkillSlot(slot)

		local line = skill.skill_order
		-- 已学习
		if slotConfig.learnSkill then
			skillBox:setGray(false)
			self._ccbOwner["sp_line_"..line]:setVisible(true)
			self._ccbOwner.sp_line_789:setVisible(line >= 6 and #skillConfig > 6)
			self._ccbOwner.effect_1:setVisible(line < 6)
			self._ccbOwner.effect_2:setVisible(line < 6)
			self._ccbOwner.effect_3:setVisible(line == 6)
			self._ccbOwner.effect_4:setVisible(line < 10)
			self._ccbOwner.effect_5:setVisible(line < 10)
			self._ccbOwner.effect_6:setVisible(line < 10)
		else
			skillBox:setGray(true)
			self._ccbOwner["sp_line_"..line]:setVisible(false)
		end

		-- 特效
		if not slotConfig.learnSkill and not slotConfig.isLock and learnPoint > 0 then
			skillBox:showBoxEffect("effects/leiji_light.ccbi", 0.5)
		end

		local skillConfig = db:getSkillByID(skill.skill_id)
		self._ccbOwner["tf_skill_name"..slot]:setString(skillConfig.name)
		self._ccbOwner["tf_skill_icon"..slot]:removeAllChildren()
		self._ccbOwner["tf_skill_icon"..slot]:addChild(skillBox)
	end
end

function QUIWidgetHeroArtifactSkillClient:skillClickHandler(e)
	app.sound:playSound("common_cancel")
	local box = e.target
	local skillSlot = box:getSkillSlot()
	local skillInfo = box:getSkill()
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArtifactSkillLearn", 
        options = {actorId = self._actorId, skillSlot = skillSlot, skillInfo = skillInfo, callback = handler(self,self._skillUpgradeHandler)}})
end

function QUIWidgetHeroArtifactSkillClient:_skillUpgradeHandler(actorId, skillInfo)
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArtifactTalentSuccess", 
        options = {actorId = actorId, skillInfo = skillInfo, callback = function ()
        	self:setInfo(actorId)
			remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
        end}})
end

return QUIWidgetHeroArtifactSkillClient