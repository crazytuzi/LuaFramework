--
-- Author: Your Name
-- Date: 2016-02-19 16:35:38
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroDetailSkillClient = class("QUIWidgetHeroDetailSkillClient", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroSkillCell = import("..widgets.QUIWidgetHeroSkillCell")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")

QUIWidgetHeroDetailSkillClient.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetHeroDetailSkillClient:ctor(options)
	local ccbFile = "ccb/Widget_Zhaohuanyulan.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClickSkillButton", callback = handler(self, self._onTriggerClickSkillButton)}
	}
	QUIWidgetHeroDetailSkillClient.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	if options then
		self._skillSlot = options.skillSlot
		self._actorId = options.actorId
		self._assistSkill = options.assistSkill
		self._skillLevel = options.skillLevel or 0
	end



	self._heroUIModel = remote.herosUtil:getUIHeroByID(self._actorId)

	if self._heroUIModel ~= nil then
		self._skillInfo = self._heroUIModel:getSkillBySlot(self._skillSlot)
	else
		local skillId = QStaticDatabase:sharedDatabase():getSkillByActorAndSlot(self._actorId, self._skillSlot)
		self._skillInfo = QStaticDatabase:sharedDatabase():getSkillByID(skillId)
	end
	self._skillId = self._skillInfo.skillId or self._skillInfo.id

	self._isAssistSkill = false
	self._ccbOwner.tf_level:setVisible(false)

	if self._assistSkill ~= nil then
		self._ccbOwner.assist_skill:setVisible(true)
		self._isAssistSkill = true
	end

	if self._skillLevel ~= nil then
		self._ccbOwner.tf_level:setVisible(self._skillLevel > 0 and not self._isAssistSkill)
		self._ccbOwner.tf_level:setString("Lv."..self._skillLevel)
		self._ccbOwner.tf_level:setScale(0.8)
	end
end

function QUIWidgetHeroDetailSkillClient:onEnter()
    self.prompt = app:promptTips()
    self.prompt:addSkillEventListener()
end

function QUIWidgetHeroDetailSkillClient:onExit()
	if self.prompt ~= nil then
    	self.prompt:removeSkillEventListener()
	end
end

function QUIWidgetHeroDetailSkillClient:setSkillInfo(skillConfig, actorId)
	-- skill name 
	local skillId = QStaticDatabase:sharedDatabase():getSkillByActorAndSlot(actorId, skillConfig.skill_id_3)
	local skillInfo = QStaticDatabase:sharedDatabase():getSkillByID(skillId)

	self._ccbOwner.skill_name:setVisible(false)

	self:setIconPath(skillInfo.icon)
end 

function QUIWidgetHeroDetailSkillClient:setIconPath(path)
	if self._skillIcon == nil then
			self._skillIcon = CCSprite:create()
			self._ccbOwner.node_icon:addChild(self._skillIcon)
		end
	self._skillIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
end

function QUIWidgetHeroDetailSkillClient:getContentSize()
	return CCSize(80, 110)
end 

function QUIWidgetHeroDetailSkillClient:_onTriggerClickSkillButton(event)
	self:dispatchEvent({name = QUIWidgetHeroDetailSkillClient.EVENT_CLICK, actorId = self._actorId, skillId = self._skillId, assistSkill = self._assistSkill, skillSlotInfo = self._skillInfo})
end

return QUIWidgetHeroDetailSkillClient