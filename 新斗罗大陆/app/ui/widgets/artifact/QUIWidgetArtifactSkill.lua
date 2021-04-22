--
-- zxs
-- 真身技能icon
--
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetArtifactSkill = class("QUIWidgetArtifactSkill", QUIWidget)
local QStaticDatabase = import("....controllers.QStaticDatabase")

QUIWidgetArtifactSkill.EVENT_CLICK = "EVENT_CLICK"

function QUIWidgetArtifactSkill:ctor(options)
	local ccbFile = "ccb/Widget_artifact_box.ccbi"
	local callBacks = {
			{ccbCallbackName = "onPress", callback = handler(self, QUIWidgetArtifactSkill._onPress)},
		}
	QUIWidgetArtifactSkill.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetArtifactSkill:resetAll()
	self._ccbOwner.sp_lock:setVisible(false)
    self._ccbOwner.sp_gray:setVisible(false)
    self._ccbOwner.node_level:setVisible(false)
    self._ccbOwner.bg_normal:setVisible(true)
    self._ccbOwner.bg_copper:setVisible(false)
    self._ccbOwner.bg_silver:setVisible(false)
    self._ccbOwner.bg_orange:setVisible(false)
	self._ccbOwner.bg_red:setVisible(false)

	self:setName("")
end

function QUIWidgetArtifactSkill:setSkill(skill)
	self:resetAll()
	self._skill = skill
	local skillConfig = db:getSkillByID(self._skill.skill_id)
	if self._skill == nil or skillConfig == nil then 
		return 
	end

	self:setIconPath(skillConfig.icon)
	self:setName(skillConfig.name)
end

function QUIWidgetArtifactSkill:getSkill()
	return self._skill
end

function QUIWidgetArtifactSkill:getSkillSlot()
	return self._skillSlot
end

function QUIWidgetArtifactSkill:setIconPath(path)
	if self._skillIcon == nil then
		self._skillIcon = CCSprite:create()
		self._ccbOwner.node_icon:removeAllChildren()
		self._ccbOwner.node_icon:addChild(self._skillIcon)
	end
	if path then
		self._skillIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(path))
	end
end

function QUIWidgetArtifactSkill:showBoxEffect(ccbFile, scale)
	self:removeEffect()
	if self._effectFile == nil then
		self._effectFile = CCBuilderReaderLoad(ccbFile, CCBProxy:create(), {})
		self._effectFile:setScale(scale)
		self._ccbOwner.node_effect:addChild(self._effectFile)
	end
end

--移除动画 
function QUIWidgetArtifactSkill:removeEffect()
	if self._effectFile ~= nil then
		self._effectFile:removeFromParent()
		self._effectFile = nil
	end
end

function QUIWidgetArtifactSkill:setLock(isLock)
	self._ccbOwner.sp_lock:setVisible(false)
	if isLock then
		makeNodeFromNormalToGray(self._ccbOwner.node_rect)
	else
		makeNodeFromGrayToNormal(self._ccbOwner.node_rect)
	end
	self:setGray(isLock)
end

function QUIWidgetArtifactSkill:setGray(isGray)
	self._ccbOwner.sp_gray:setVisible(isGray)
	if isGray then
		makeNodeFromNormalToGray(self._ccbOwner.node_icon)
	else
		makeNodeFromGrayToNormal(self._ccbOwner.node_icon)
	end
end

function QUIWidgetArtifactSkill:setSkillSlot(slot)
	self._skillSlot = slot or 0
	if self._skillSlot == 1 then
		self._ccbOwner.bg_silver:setVisible(true)
	elseif self._skillSlot == 2 or self._skillSlot == 3 or self._skillSlot == 4 or self._skillSlot == 5 then
		self._ccbOwner.bg_normal:setVisible(true)
	elseif self._skillSlot == 6 then
		self._ccbOwner.bg_orange:setVisible(true)
	elseif self._skillSlot == 7 or self._skillSlot == 8 or self._skillSlot == 9 then
		self._ccbOwner.bg_copper:setVisible(true)
	elseif self._skillSlot == 10 then
		self._ccbOwner.bg_red:setVisible(true)
	else
		self._ccbOwner.bg_normal:setVisible(true)
	end
end

function QUIWidgetArtifactSkill:setName(name)
	self._ccbOwner.tf_name:setString(name)
end

function QUIWidgetArtifactSkill:setLevel(level)
    self._ccbOwner.node_level:setVisible(true)
	self._ccbOwner.tf_level:setString(level)
end

function QUIWidgetArtifactSkill:_onPress()
	self:dispatchEvent({name = QUIWidgetArtifactSkill.EVENT_CLICK})
end

return QUIWidgetArtifactSkill