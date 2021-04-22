-- 
-- zxs
-- 武魂真身大师激活,技能学习
--

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogArtifactTalentSuccess = class("QUIDialogArtifactTalentSuccess", QUIDialog)
local QUIWidgetArtifactBox = import("..widgets.artifact.QUIWidgetArtifactBox")
local QUIWidgetArtifactSkill = import("..widgets.artifact.QUIWidgetArtifactSkill")
local QActorProp = import("...models.QActorProp")
local QColorLabel = import("...utils.QColorLabel")
local QRichText = import("...utils.QRichText")


function QUIDialogArtifactTalentSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_artifact_jihuo.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerSelected", callback = handler(self, self._onTriggerSelected)},
	}
	QUIDialogArtifactTalentSuccess.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
	app.sound:playSound("task_complete")

    self._actorId = options.actorId
    self._callBack = options.callback
    self._skillInfo = options.skillInfo
	self._successTip = options.successTip
	
    self._isSelected = false
	self._playOver = false
	self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:connectScriptHandler(handler(self, self.animationEndHandler))

    self:showIconInfo()
	if options.isTalent then
		self._animationManager:runAnimationsForSequenceNamed("1")
		self:showTalentInfo()
    	self:showSelectState()
		self._ccbOwner.node_select:setVisible(app.master:showMasterSelect(self._successTip))
    	self._ccbOwner.tf_show_tips:setString(app.master:getMasterShowTips())
	else
		self._animationManager:runAnimationsForSequenceNamed("2")
		self:showSkillInfo()
		self._ccbOwner.node_select:setVisible(false)
	end
end

function QUIDialogArtifactTalentSuccess:animationEndHandler()
	self._playOver = true
end

function QUIDialogArtifactTalentSuccess:showIconInfo()
	local character = db:getCharacterByID(self._actorId)
	local artifactConfig = db:getItemByID(character.artifact_id)

	self._ccbOwner.tf_name:setString(artifactConfig.name)
	if self._artifactBox == nil then
	    self._artifactBox = QUIWidgetArtifactBox.new()
	    self._ccbOwner.node_icon:addChild(self._artifactBox)
	end
    self._artifactBox:setHero(self._actorId)
    self._artifactBox:showRedTips(false)
end

function QUIDialogArtifactTalentSuccess:showTalentInfo()
	local artifactInfo = remote.herosUtil:getHeroByID(self._actorId).artifact
	local character = db:getCharacterByID(self._actorId)
	local artifactConfig = db:getItemByID(character.artifact_id)
	local masterProp, masterLevel, newMasterInfo = db:getArtifactMasterInfo(character.aptitude, artifactInfo.artifactLevel)

    self._ccbOwner.tf_skill_name:setString(newMasterInfo.master_name)
    self._ccbOwner.tf_skill_name2:setString(newMasterInfo.master_name)
	local propInfo = self:calculateCombinationProp(newMasterInfo)
	self._ccbOwner.tf_prop:setString("效果："..(propInfo[1] or "").."   "..(propInfo[2] or ""))
end

function QUIDialogArtifactTalentSuccess:showSkillInfo()
	local skillBox = QUIWidgetArtifactSkill.new()
	skillBox:setSkill(self._skillInfo)
	skillBox:setName("")
	self._ccbOwner.node_skill_icon:addChild(skillBox)

	local skillConfig = db:getSkillByID(self._skillInfo.skill_id)
	self._ccbOwner.tf_skill_name:setString(skillConfig.name)
	-- local desc = QColorLabel.replaceColorSign(skillConfig.description or "",true)
	local skillDesc = q.getSkillMainDesc(skillConfig.description or "")
	local desc = QColorLabel.removeColorSign(skillDesc)

	self._ccbOwner.tf_skill_desc:setString("")
	local describe = "##m"..skillConfig.name.."：##j"..desc
    local strArr  = string.split(describe, "\n") or {}
    local height = 0
    for i, v in pairs(strArr) do
        local richText = QRichText.new(v, 460.0, {stringType = 1,defaultColor = COLORS.a,defaultSize = 22})
        richText:setAnchorPoint(ccp(0, 1))
        richText:setPositionY(-height)
        self._ccbOwner.node_skill_desc:addChild(richText)
        height = height + richText:getContentSize().height
    end
end

function QUIDialogArtifactTalentSuccess:calculateCombinationProp(masterInfo)
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

function QUIDialogArtifactTalentSuccess:_backClickHandler()
	if self._playOver then
		self:playEffectOut()
	end
end

function QUIDialogArtifactTalentSuccess:showSelectState()
    self._ccbOwner.btn_select:setHighlighted(not (self._isSelected == true))
end

function QUIDialogArtifactTalentSuccess:_onTriggerSelected()
    self._isSelected = not self._isSelected
    self:showSelectState()
end

function QUIDialogArtifactTalentSuccess:viewAnimationOutHandler()
	local callback = self._callback

	if self._isSelected == true then
        app.master:setMasterShowState(self._successTip)
    end

	self:popSelf()
	if callback ~= nil then
		callback()
	end
end

return QUIDialogArtifactTalentSuccess
