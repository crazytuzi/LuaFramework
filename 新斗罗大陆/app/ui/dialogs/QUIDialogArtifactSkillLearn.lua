--
-- zxs
-- 武魂真身技能学习
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogArtifactSkillLearn = class("QUIDialogArtifactSkillLearn", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetArtifactSkill = import("..widgets.artifact.QUIWidgetArtifactSkill")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QRichText = import("...utils.QRichText")
local QColorLabel = import("...utils.QColorLabel")
local QScrollView = import("...views.QScrollView") 

function QUIDialogArtifactSkillLearn:ctor(options)
	local ccbFile = "ccb/Dialog_artifact_xuexi_new.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 				callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerLearn", 				callback = handler(self, self._onTriggerLearn)},
	}
	QUIDialogArtifactSkillLearn.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true

	self._skillInfo = options.skillInfo
	self._skillSlot = options.skillSlot
	self._actorId = options.actorId
	self._callback = options.callback
	self._isLearn = false

	self._ccbOwner.frame_tf_title:setString("天赋学习")
	q.setButtonEnableShadow(self._ccbOwner.btn_learn)
	self:updateInfo()
end

function QUIDialogArtifactSkillLearn:updateInfo()
	local skillBox = QUIWidgetArtifactSkill.new()
	skillBox:setSkill(self._skillInfo)
	skillBox:setSkillSlot(self._skillSlot)
	skillBox:setName("")
	self._ccbOwner.node_icon:removeAllChildren()
	self._ccbOwner.node_icon:addChild(skillBox)

	local uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local skillConfig = db:getSkillByID(self._skillInfo.skill_id)
	local totalPoint = uiHeroModel:getArtifactTotalPoint()
	local usePoint = uiHeroModel:getArtifactUsePoint()
	self._ccbOwner.tf_point:setString("1")--/"..(totalPoint-usePoint))
	self._ccbOwner.tf_skill_name:setString(skillConfig.name or "")
	self._ccbOwner.tf_type:setString((skillConfig.description_type or ""))

	local itemContentSize = self._ccbOwner.sheet_layout:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, itemContentSize, {bufferMode = 1})
    self._scrollView:setVerticalBounce(true)
    
	-- 这里策划爸爸说写死这种颜色
	local desc = skillConfig.description or ""
    local strArr  = string.split(desc,"\n") or {}
    local textNode = CCNode:create()
    local height = 0
    for i, v in pairs(strArr) do
		local describe = QColorLabel.replaceColorSign(v or "", false)
        local richText = QRichText.new(describe, 436, {stringType = 1, defaultColor = GAME_COLOR_LIGHT.normal, defaultSize = 22})
        richText:setAnchorPoint(ccp(0, 1))
        richText:setPositionY(-height)
        textNode:addChild(richText)
        height = height + richText:getContentSize().height
    end
    textNode:setContentSize(CCSize(436, height))
    textNode:setPositionY(-5)
	self._scrollView:addItemBox(textNode)
	self._scrollView:setRect(0, -height-5, 0, 0)

	local heroSlotInfo = uiHeroModel:getArtifactSkillBySlot(self._skillInfo.skill_order)
	if heroSlotInfo.isLock then
		self._ccbOwner.tf_lock:setVisible(true)
		self._ccbOwner.node_point:setVisible(false)
		self._ccbOwner.btn_learn:setEnabled(false)
		makeNodeFromNormalToGray(self._ccbOwner.node_learn)
	elseif heroSlotInfo.learnSkill then
		self._ccbOwner.tf_lock:setVisible(true)
		self._ccbOwner.tf_lock:setString("已学习")
		self._ccbOwner.node_point:setVisible(false)
		self._ccbOwner.btn_learn:setEnabled(false)
		makeNodeFromNormalToGray(self._ccbOwner.node_learn)
	else
		self._ccbOwner.tf_lock:setVisible(false)
		self._ccbOwner.node_point:setVisible(true)
		self._ccbOwner.btn_learn:setEnabled(true)
		makeNodeFromGrayToNormal(self._ccbOwner.node_learn)
	end
end

function QUIDialogArtifactSkillLearn:viewWillDisappear()
    QUIDialogArtifactSkillLearn.super.viewWillDisappear(self)
end

function QUIDialogArtifactSkillLearn:_backClickHandler()
	app.sound:playSound("common_cancel")
    self:playEffectOut()
end

function QUIDialogArtifactSkillLearn:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogArtifactSkillLearn:_onTriggerLearn()
	app.sound:playSound("common_cancel")
	local uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local totalPoint = uiHeroModel:getArtifactTotalPoint()
	local usePoint = uiHeroModel:getArtifactUsePoint()
	if totalPoint <= usePoint then
		app.tip:floatTip("魂师大人，魂技点不足，赶紧去突破武魂真身吧~")
	else
		remote.artifact:artifactImproveSkillRequest(self._actorId, self._skillInfo.skill_id, function ()
			if self:safeCheck() then
				self._isLearn = true
				self:playEffectOut()
			end
		end)
	end
end

function QUIDialogArtifactSkillLearn:viewAnimationOutHandler()
	local callback = self._callback
	local actorId = self._actorId
	local skillInfo = self._skillInfo
	self:popSelf()
	if callback ~= nil and self._isLearn then
		callback(actorId, skillInfo)
	end
end

return QUIDialogArtifactSkillLearn