-- @Author: liaoxianbo
-- @Date:   2020-01-10 19:47:51
-- @Last Modified by:   liaoxianbo
-- @Last Modified time: 2020-01-13 20:20:40
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGodarmSkillbox = class("QUIWidgetGodarmSkillbox", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")

function QUIWidgetGodarmSkillbox:ctor(options)
	local ccbFile = "ccb/Widget_Godarm_skillbox.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetGodarmSkillbox.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	local index = options.index
	local unlockKey = "UNLOCK_GOD_ARM_1_"..index
	if not app.unlock:checkLock(unlockKey) then
		local unlockLevel = app.unlock:getConfigByKey(unlockKey).team_level
		local str = unlockLevel.."级".."\n开启"
		self._ccbOwner.tf_lock:setVisible(true)
		self._ccbOwner.tf_lock:setScale(1)
		self._ccbOwner.tf_lock:setString(str)
	else
		self._ccbOwner.tf_lock:setString("未上阵")
		self._ccbOwner.tf_lock:setScale(0.9)
		self._ccbOwner.tf_lock:setVisible(true)
	end
	self._ccbOwner.sp_godarm_label:setVisible(false)
end

function QUIWidgetGodarmSkillbox:onEnter()
end

function QUIWidgetGodarmSkillbox:onExit()
end

function QUIWidgetGodarmSkillbox:setSkillInfo( godarmInfo)
	if next(godarmInfo) == nil or not godarmInfo then return end
	self._ccbOwner.tf_lock:setVisible(false)
	local gradeInfo = db:getGradeByHeroActorLevel(godarmInfo.godarmId or godarmInfo.id,godarmInfo.grade) or {}
	local godarmConfig = db:getCharacterByID(godarmInfo.godarmId or godarmInfo.id)
	local sabcInfo = db:getSABCByQuality(godarmConfig.aptitude)
	self:showSabc(sabcInfo.lower)		
	
	local skillIds = string.split(gradeInfo.god_arm_skill_sz, ":")
	local skillConfig = db:getSkillByID(tonumber(skillIds[1]))   

	local icon = CCSprite:create()
	self._ccbOwner.node_icon:addChild(icon)
	icon:setTexture(CCTextureCache:sharedTextureCache():addImage(skillConfig.icon))
	icon:setScale(1)
	local size = self._ccbOwner.sp_bg:getContentSize()
	icon:setScale(size.width/icon:getContentSize().width)

	local jobIconPath = remote.godarm:getGodarmJobPath(godarmConfig.label)
	if jobIconPath then
		self._ccbOwner.sp_godarm_label:setVisible(true)
		QSetDisplaySpriteByPath(self._ccbOwner.sp_godarm_label,jobIconPath)
	end	
end

function QUIWidgetGodarmSkillbox:showSabc( quality )
	local icon = CCSprite:create(QResPath("itemBoxPingZhi_"..quality))
	if icon then
		if quality == "a+" or quality == "ss" then
			icon:setPositionX(5)
		end
		self._ccbOwner.node_pingzhi:addChild(icon)
	end
end

function QUIWidgetGodarmSkillbox:getContentSize()
end

return QUIWidgetGodarmSkillbox
