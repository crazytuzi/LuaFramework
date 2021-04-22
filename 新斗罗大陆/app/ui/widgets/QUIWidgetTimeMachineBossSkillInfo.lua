-- by Kumo
-- 活动副本Boss技能介绍界面子条款

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTimeMachineBossSkillInfo = class("QUIWidgetTimeMachineBossSkillInfo", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroSkillBox = import("..widgets.QUIWidgetHeroSkillBox")
local QRichText = import("...utils.QRichText")

function QUIWidgetTimeMachineBossSkillInfo:ctor(options)
	local ccbFile = "ccb/Widget_Timemachine_skill.ccbi"
	local callBacks = {}
	QUIWidgetTimeMachineBossSkillInfo.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._size = self._ccbOwner.layer_size:getContentSize()
	self._offsetHeight = 0
end

function QUIWidgetTimeMachineBossSkillInfo:onEnter()
end

function QUIWidgetTimeMachineBossSkillInfo:onExit()
end

function QUIWidgetTimeMachineBossSkillInfo:getContentSize()
	return CCSize(self._size.width, self._size.height + self._offsetHeight)
end

function QUIWidgetTimeMachineBossSkillInfo:init( skillId ) 
	local skillConfig = QStaticDatabase.sharedDatabase():getSkillByID(skillId)
	if not skillConfig then
		return
	end

	self._offsetHeight = 0
	self._ccbOwner.node_textContent:removeAllChildren()
    local strArr  = string.split(skillConfig.description,"\n") or {}
    for _, v in pairs(strArr) do
        local richText = QRichText.new(v, 400, {stringType = 1, defaultColor = COLORS.j})
        richText:setAnchorPoint(ccp(0, 1))
        richText:setPositionY(-self._offsetHeight)
		self._ccbOwner.node_textContent:addChild(richText)
        self._offsetHeight = self._offsetHeight + richText:getContentSize().height
    end

	self._ccbOwner.tf_skill_name:setString("【"..skillConfig.name.."】")
	-- if self._richText == nil then
	-- 	self._richText = QRichText.new("", 400, {autoCenter = false, stringType = 1, defaultColor = COLORS.j})
	-- 	self._richText:setAnchorPoint(0, 1)
	-- 	self._ccbOwner.node_textContent:addChild(self._richText)
	-- end
	-- self._richText:setString(skillConfig.description)
	-- self._offsetHeight = self._richText:getContentSize().height


	if self._skillBox == nil then
		self._skillBox = QUIWidgetHeroSkillBox.new()
		self._skillBox:setLock(false)
		self._ccbOwner.node_icon:addChild(self._skillBox)
	end
	self._skillBox:setSkillID(skillId)
end

return QUIWidgetTimeMachineBossSkillInfo