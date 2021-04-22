--
-- zxs
-- 武魂真身天赋技能页签
--

local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetArtifactInfoSkill = class("QUIWidgetArtifactInfoSkill", QUIWidget)
local QScrollView = import("....views.QScrollView")
local QUIViewController = import("...QUIViewController")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIWidgetArtifactSkill = import("...widgets.artifact.QUIWidgetArtifactSkill")
local QUIWidgetHeroArtifactSkillClient = import("...widgets.artifact.QUIWidgetHeroArtifactSkillClient")
local QQuickWay = import("....utils.QQuickWay")

function QUIWidgetArtifactInfoSkill:ctor(options)
	local ccbFile = "ccb/Widget_artifact_tianfu.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerReset", callback = handler(self, QUIWidgetArtifactInfoSkill._onTriggerReset)},
		{ccbCallbackName = "onTriggerProp", callback = handler(self, QUIWidgetArtifactInfoSkill._onTriggerProp)},
	}
	QUIWidgetArtifactInfoSkill.super.ctor(self,ccbFile,callBacks,options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetArtifactInfoSkill:onEnter()
	local size = self._ccbOwner.sheet_layout:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, size, {bufferMode = 1, sensitiveDistance = 30, nodeAR = ccp(0.5, 0.5)})
end

function QUIWidgetArtifactInfoSkill:setInfo(actorId)
	self._actorId = actorId
	self._artifactId = remote.artifact:getArtiactByActorId(self._actorId)
	self._heroInfo = remote.herosUtil:getHeroByID(self._actorId)

	local uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
	local totalPoint = uiHeroModel:getArtifactTotalPoint()
	local usePoint = uiHeroModel:getArtifactUsePoint()
	local learnPoint = totalPoint-usePoint
	self._ccbOwner.tf_skill_point:setString("0/0")
	if self._heroInfo ~= nil and self._heroInfo.artifact ~= nil then
		self._ccbOwner.tf_skill_point:setString(learnPoint)
	end

    local client = QUIWidgetHeroArtifactSkillClient.new()
    client:setInfo(actorId, learnPoint)
    client:setPosition(ccp(0, 0))   
    local contentSize = client:getContentSize()
    local posY = self._scrollView:getPositionY() or 0
    self._scrollView:clear()
    self._scrollView:addItemBox(client)
    self._scrollView:setRect(0, -contentSize.height, 0, contentSize.width)
    self._scrollView:moveTo(0, posY)
end

function QUIWidgetArtifactInfoSkill:_onTriggerReset(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_reset) == false then return end
	app.sound:playSound("common_small")
	local resetToken = db:getConfiguration().RESETTING_RECYCLE.value or 0
	local contentStr = "重置所有已经学习的武魂真身天赋，返还所有学习过程中消耗的天赋点数"
	local haveMonthCard = remote.activity:checkMonthCardActive(2) --至尊月卡
	local sucessCallback = function()
		local uiHeroModel = remote.herosUtil:getUIHeroByID(self._actorId)
		local usePoint = uiHeroModel:getArtifactUsePoint()
		if usePoint == 0 then
			app.tip:floatTip("魂师大人，你还没学习过魂技呢~")
			return
		end

		if resetToken > remote.user.token and not haveMonthCard then
			QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
			return
		end
		remote.artifact:artifactSkillResetRequest(self._actorId, function()
				if self:safeCheck() then
		        	app.tip:floatTip("重置成功")
					remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
				end
			end)
	end

    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArifactSkillReset", 
        options = {title = "重置魂技", contentStr = contentStr, costToken = resetToken,callback = function (isReset)
	        if isReset == true then
	        	sucessCallback()
			end
        end}})
end

function QUIWidgetArtifactInfoSkill:_onTriggerProp()
	local skillList = {}
	if self._heroInfo.artifact and self._heroInfo.artifact.artifactSkillList then
		skillList = self._heroInfo.artifact.artifactSkillList
	end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogArifactSkillProp", 
        options = {actorId = self._actorId, skillList = skillList}})
end

return QUIWidgetArtifactInfoSkill