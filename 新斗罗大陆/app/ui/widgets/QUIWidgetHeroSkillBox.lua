
local QUIWidget = import(".QUIWidget")
local QUIWidgetHeroSkillBox = class("QUIWidgetHeroSkillBox", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIWidgetHeroSkillBox.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetHeroSkillBox:ctor(options)
	local ccbFile = "ccb/Widget_HeroSkillBox.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetHeroSkillBox._onTriggerClick)},
    }
	QUIWidgetHeroSkillBox.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self:unselected()
    self:hideArrow()
	self._ccbOwner.tf_star:setString("")
	self._ccbOwner.node_super:setVisible(false)
	self._ccbOwner.node_god_skill:setVisible(false)
end

function QUIWidgetHeroSkillBox:hideAllColor()
	self._ccbOwner.node_normal:setVisible(false)
	self._ccbOwner.node_white:setVisible(false)
	self._ccbOwner.node_green:setVisible(false)
	self._ccbOwner.node_blue:setVisible(false)
	self._ccbOwner.node_purple:setVisible(false)
	self._ccbOwner.node_orange:setVisible(false)
	self._ccbOwner.node_red:setVisible(false)
end

function QUIWidgetHeroSkillBox:setColor(name)
	self:hideAllColor()
	if self._ccbOwner["node_"..name] then
		self._ccbOwner["node_"..name]:setVisible(true)
	end
end

function QUIWidgetHeroSkillBox:setStarFont(str)
	self._ccbOwner.tf_star:setString(str)
end

function QUIWidgetHeroSkillBox:setSkillID(skillId)
  	self._skillId = skillId
  	local skillInfo = QStaticDatabase:sharedDatabase():getSkillByID(skillId)
  	self:setSkillIcon(skillInfo.icon)
	self._ccbOwner.node_grade:setVisible(false)
	self._ccbOwner.node_name:setVisible(false)
	self._ccbOwner.tf_name:setString(skillInfo.name)
	self._ccbOwner.tf_level:setVisible(false)
end 

function QUIWidgetHeroSkillBox:showArrow()
    self._ccbOwner.node_arrow:setVisible(true)
end  

function QUIWidgetHeroSkillBox:hideArrow()
    self._ccbOwner.node_arrow:setVisible(false)
end 

function QUIWidgetHeroSkillBox:selected()
	self._ccbOwner.node_select:setVisible(true)
end 

function QUIWidgetHeroSkillBox:unselected()
	self._ccbOwner.node_select:setVisible(false)
end 

function QUIWidgetHeroSkillBox:showSkillName()
	self._ccbOwner.node_name:setVisible(true)
end

function QUIWidgetHeroSkillBox:setSkillName(skillName)
	self._ccbOwner.node_name:setVisible(true)
	self._ccbOwner.tf_name:setString(skillName)
end

function QUIWidgetHeroSkillBox:setSkillLock(lockName,lockValue)
	self._ccbOwner.node_grade:setVisible(true)
	self._ccbOwner.tf_lock_name:setString(lockName)
	self._ccbOwner.tf_lock_value:setString(lockValue)
end

function QUIWidgetHeroSkillBox:setSkillLevel(level)
	self._ccbOwner.tf_level:setVisible(true)
	self._ccbOwner.tf_level:setString(level)
end

function QUIWidgetHeroSkillBox:setLock(b)
	self._ccbOwner.node_mask:setVisible(b)
end

function QUIWidgetHeroSkillBox:setSuperSkill(b)
	self._ccbOwner.node_super:setVisible(b)
end

function QUIWidgetHeroSkillBox:setGodSkillShowLevel(realLevel, actorId)
	self._ccbOwner.node_god_skill:setVisible(false)

	-- 策划不要在技能icon上面显示神几，屏蔽掉
	self._ccbOwner.sp_god_bg:setVisible(false)
	self._ccbOwner.sp_god_skill:setVisible(false)

	if not realLevel then return end
	self._godGrade = realLevel
	local showLevel = remote.herosUtil:getGodSkillLevelByActorId(actorId, realLevel)
	
	if showLevel == -1 then
		return
	end

	self._ccbOwner.node_god_skill:setVisible(true)

	for i = 0, 5 do
		self._ccbOwner["sp_grade_"..i]:setVisible(false)
	end

	-- local path = nil
	-- if showLevel == 0 then
	-- 	path = QResPath("god_skill_0")
	-- else
	-- 	path = QResPath("god_skill")[showLevel]
	-- end
	-- QSetDisplayFrameByPath(self._ccbOwner.sp_god_skill, path)

	if self._ccbOwner["sp_grade_"..showLevel] then
		self._ccbOwner["sp_grade_"..showLevel]:setVisible(true)
	end
end

function QUIWidgetHeroSkillBox:getContentSize()
	return self._ccbOwner.node_select:getContentSize()
end

function QUIWidgetHeroSkillBox:setSkillDesc(desc)
	self._describle = desc
end

function QUIWidgetHeroSkillBox:setSkillIcon(respath)
	if respath then
		if self.icon == nil then
			self.icon = CCSprite:create()
			self._ccbOwner.node_icon:addChild(self.icon)
		end
		self.icon:setTexture(CCTextureCache:sharedTextureCache():addImage(respath))

		local size = self.icon:getContentSize()
		local size2 = self._ccbOwner.node_mask:getContentSize()
		if size.width > size2.width then
			self.icon:setScaleX(size2.width/size.width)
		end
		if size.height > size2.height then
			self.icon:setScaleY(size2.height/size.height)
		end
	end
end

function QUIWidgetHeroSkillBox:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetHeroSkillBox.EVENT_CLICK, skillId = self._skillId, desc = self._describle, godGrade = self._godGrade, target = self})
end

return QUIWidgetHeroSkillBox