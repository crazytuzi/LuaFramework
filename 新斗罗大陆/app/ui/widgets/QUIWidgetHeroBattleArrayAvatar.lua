

local QUIWidget = import(".QUIWidget")
local QUIWidgetHeroBattleArrayAvatar = class("QUIWidgetHeroBattleArrayAvatar", QUIWidget)
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetAnimationPlayer = import("..QUIWidgetAnimationPlayer")
local QBaseArrangementWithDataHandle = import("...arrangement.QBaseArrangementWithDataHandle")

local AVATAR_SCALE = 1.3


QUIWidgetHeroBattleArrayAvatar.AVATAR_SKILL_CLICK = "AVATAR_SKILL_CLICK"
QUIWidgetHeroBattleArrayAvatar.AVATAR_ICON_CLICK = "AVATAR_ICON_CLICK"



function QUIWidgetHeroBattleArrayAvatar:ctor(options)
	local ccbFile = "ccb/Widget_HeroArray_Avatar.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerSkill", callback = handler(self, self._onTriggerSkill)},
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	
	}
	QUIWidgetHeroBattleArrayAvatar.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
    self._chooseEffect = nil
end

function QUIWidgetHeroBattleArrayAvatar:resetAll()
	self._ccbOwner.node_unlock:setVisible(false)
	self._ccbOwner.node_skill_father:setVisible(false)
	self._ccbOwner.node_hero:setVisible(false)

	-- if self._widgetSoulSpirit then
	-- 	self._widgetSoulSpirit:setVisible(false)
	-- end

end

--[[
QBaseArrangementWithDataHandle
	info
	@actorId or id		对象id
	@hpScale 		当前血量比例
	@mpScale 		当前法力比例
	@index			索引
	@trialNum		队伍
	@force			战斗力
	@pos			位置
	@oType			对象类型 ： 魂师1 魂灵2 神器3 
	@grade 			等级
]]--
function QUIWidgetHeroBattleArrayAvatar:setInfo(info)
	-- QPrintTable(info)
	self._info = info
	self:resetAll()
	self:setStageBgSprite()
	self:setAvatar()
	self:setSkillMark()
	self:setSkill()
end

function QUIWidgetHeroBattleArrayAvatar:updateInfo()
	self:setSkillMark()
end

function QUIWidgetHeroBattleArrayAvatar:setAvatar()
	self._ccbOwner.node_hero:setVisible(true)	
	if self._info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE 
		or self._info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE then
		if self._avatar == nil then
			self._avatar = QUIWidgetHeroInformation.new() 
			self._ccbOwner.node_hero:addChild(self._avatar)
	        self._avatar:setBackgroundVisible(false)
		    self._avatar:setInfotype("QUIDialogMetalCityTeamArrangement")
		    print("QUIWidgetHeroBattleArrayAvatar:create1")
		end
		if self._info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE then
			self._avatar:setAvatar(self._info.actorId, AVATAR_SCALE)
			self._avatar:hideGodarmInfo()
			self._avatar:setPositionY(0)
		else
			self._avatar:setAvatar(self._info.id, AVATAR_SCALE)
			self._avatar:setGodarmInfo(self._info.id)
			self._avatar:showGodarmInfo()
			self._avatar:setPositionY(50)
		end
		self._avatar:setNameVisible(false)
		self._avatar:setStarVisible(false)
		self._avatar:setHpMp(self._info.hpScale, self._info.mpScale)
		self:setLockInfo(false,"")
	elseif self._info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE then

		if self._avatar == nil then
			self._avatar = QUIWidgetHeroInformation.new() 
			self._ccbOwner.node_hero:addChild(self._avatar)
	        self._avatar:setBackgroundVisible(false)
		    self._avatar:setInfotype("QUIDialogMetalCityTeamArrangement")
		end
		self._avatar:setSoulSpirit(self._info.id,AVATAR_SCALE,AVATAR_SCALE)
		self._avatar:setNameVisible(false)
		self._avatar:setStarVisible(false)
		self._avatar:hideGodarmInfo()
		
		self:setLockInfo(false,"")
	elseif self._info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.EMPTY_HERO_ELE_TYPE
		or self._info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.EMPTY_SOUL_ELE_TYPE
		or self._info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.EMPTY_GODARM_ELE_TYPE
	 then
		self:setLockInfo(false,"")
		self._ccbOwner.node_hero:setVisible(false)	

	elseif self._info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.LOCK_SOUL_ELE_TYPE then
		self:setLockInfo(true,"未解锁")
		self._ccbOwner.node_hero:setVisible(false)	
	elseif self._info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.LOCK_HERO_ELE_TYPE then
		self:setLockInfo(true,self._info.lockStr or "敬请期待")
		self._ccbOwner.node_hero:setVisible(false)	
	elseif self._info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.LOCK_GODARM_ELE_TYPE then
		self:setLockInfo(true,"敬请期待")
		self._ccbOwner.node_hero:setVisible(false)	

	end
end

function QUIWidgetHeroBattleArrayAvatar:setStageBgSprite()
	self._ccbOwner.sp_enable:setPositionY(0)
	local type_ = self._info.oType % 100

	if type_== QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE then
		if remote.teamManager.TEAM_INDEX_MAIN == self._info.index then
			self._ccbOwner.sp_enable:setDisplayFrame(QSpriteFrameByKey("godarm_arrangement_bg", 1))	
		else
			self._ccbOwner.sp_enable:setDisplayFrame(QSpriteFrameByKey("godarm_arrangement_bg", 2))	
		end
	elseif  type_ == QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE then
		self._ccbOwner.sp_enable:setDisplayFrame(QSpriteFrameByKey("godarm_arrangement_bg", 7))	
	elseif  type_ == QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE then
	 	self._ccbOwner.sp_enable:setPositionY(40)
		self._ccbOwner.sp_enable:setDisplayFrame(QSpriteFrameByKey("godarm_arrangement_bg", 3))	
	end
end

function QUIWidgetHeroBattleArrayAvatar:setLockInfo(lock , str)
	self._bIsLock = lock
	self._ccbOwner.node_unlock:setVisible(lock)
	if not lock then
		makeNodeFromGrayToNormal(self._ccbOwner.sp_enable)
	else
		makeNodeFromNormalToGray(self._ccbOwner.sp_enable)				
	end
	self._ccbOwner.tf_bmf_unlock:setString(str or "2－10 解锁")
	
end

function QUIWidgetHeroBattleArrayAvatar:setSkillMark()

	self._ccbOwner.sp_team_mark:setVisible(true)
	self._ccbOwner.sp_combo:setVisible(false)
	self._ccbOwner.node_skilleffect:setVisible(false)

	if self._info.index == remote.teamManager.TEAM_INDEX_MAIN then
		-- self._ccbOwner.sp_team_mark:setDisplayFrame(QSpriteFrameByKey("team_mark_sp", 1))	
		self._ccbOwner.sp_combo:setVisible(true)
		self._ccbOwner.sp_team_mark:setVisible(false)
		self._ccbOwner.node_skill_select:setVisible(false)
		self._ccbOwner.node_skilleffect:setVisible(true)
	elseif self._info.index == remote.teamManager.TEAM_INDEX_HELP then
		self._ccbOwner.sp_team_mark:setDisplayFrame(QSpriteFrameByKey("team_mark_sp", 1))	
	elseif self._info.index == remote.teamManager.TEAM_INDEX_HELP2 then
		self._ccbOwner.sp_team_mark:setDisplayFrame(QSpriteFrameByKey("team_mark_sp", 2))	
	elseif self._info.index == remote.teamManager.TEAM_INDEX_HELP3 then
		self._ccbOwner.sp_team_mark:setDisplayFrame(QSpriteFrameByKey("team_mark_sp", 3))	
	elseif self._info.index == remote.teamManager.TEAM_INDEX_GODARM then
		self._ccbOwner.sp_team_mark:setDisplayFrame(QSpriteFrameByKey("team_mark_sp", 4 + self._info.pos))	
	end

	if self._info.skillIdx and self._info.skillIdx >= 1 then
		self._ccbOwner.sp_team_mark:setDisplayFrame(QSpriteFrameByKey("team_mark_sp", self._info.skillIdx + 1))	
	end

end

function QUIWidgetHeroBattleArrayAvatar:setSkill()
	local skillConfig = nil
	local isGray = false
	local effectShow = true 
	local showSkill = true 

	if self._info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.HERO_ELE_TYPE then
		if self._info.index == remote.teamManager.TEAM_INDEX_MAIN then
			local assistSkill, haveAssistHero = remote.herosUtil:checkHeroHaveAssistHero(self._info.actorId)
			isGray = not haveAssistHero
			effectShow = false

			if not assistSkill then
				showSkill = false
			end
		else

			effectShow = self._info.skillIdx and self._info.skillIdx > 0
		end

		skillConfig = remote.herosUtil:getManualSkillsByActorId(self._info.actorId)
	elseif  self._info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.SOUL_ELE_TYPE then
	elseif  self._info.oType == QBaseArrangementWithDataHandle.ELEMENT_TYPE.GODARM_ELE_TYPE then
		local gradeConfig = db:getGradeByHeroActorLevel(self._info.id, self._info.grade)
		if gradeConfig ~= nil and gradeConfig.god_arm_skill_sz then
	        local skillIds = string.split(gradeConfig.god_arm_skill_sz, ":")
			skillConfig = db:getSkillByID(tonumber(skillIds[1]))
		end	
	end
	if skillConfig then
		self._ccbOwner.node_skill_father:setVisible(showSkill)
		local texture = CCTextureCache:sharedTextureCache():addImage(skillConfig.icon)
		self._ccbOwner.sp_skill:setTexture(texture)
	    local size = texture:getContentSize()
	    local rect = CCRectMake(0, 0, size.width, size.height)
	    self._ccbOwner.sp_skill:setTextureRect(rect)
	else
		self._ccbOwner.node_skill_father:setVisible(false)
	end

	if isGray then
		makeNodeFromNormalToGray(self._ccbOwner.sp_skill)
	else
		makeNodeFromGrayToNormal(self._ccbOwner.sp_skill)
	end



	self._ccbOwner.node_skill_select:setVisible(effectShow)
	-- if self._ccbOwner.fca_effect ~= nil then
 --        local animationManager = tolua.cast(self._ccbOwner.fca_effect:getUserObject(), "CCBAnimationManager")
 --        if animationManager ~= nil then 
 --            animationManager:runAnimationsForSequenceNamed("up")
 --        end
 --    end


end


function QUIWidgetHeroBattleArrayAvatar:showChooseAction()
	if self._avatar then
		self._avatar:avatarPlayAnimation(ANIMATION_EFFECT.VICTORY)
		if self._chooseEffect == nil then
			self._chooseEffect = QUIWidgetAnimationPlayer.new()
			self._ccbOwner.node_light:addChild(self._chooseEffect)
		end
		self._chooseEffect:playAnimation("effects/ChooseHero.ccbi")
	end
end


function QUIWidgetHeroBattleArrayAvatar:onEnter()
end

function QUIWidgetHeroBattleArrayAvatar:onExit()
end

function QUIWidgetHeroBattleArrayAvatar:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetHeroBattleArrayAvatar.AVATAR_ICON_CLICK, info = self._info})
end

function QUIWidgetHeroBattleArrayAvatar:_onTriggerSkill()
	self:dispatchEvent({name = QUIWidgetHeroBattleArrayAvatar.AVATAR_SKILL_CLICK, info = self._info})
end

return QUIWidgetHeroBattleArrayAvatar