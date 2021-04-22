--
-- Author: xurui
-- Date: 2016-04-08 15:49:22
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogAssistHeroSkillAchieve = class("QUIDialogAssistHeroSkillAchieve", QUIDialog)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QNavigationController = import("...controllers.QNavigationController")
local QRichText = import("...utils.QRichText")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogAssistHeroSkillAchieve:ctor(options)
	local ccbFile = "ccb/Dialog_Hejijihuo.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)}
	}
	QUIDialogAssistHeroSkillAchieve.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	
    app.sound:playSound("common_level_up")
	if options then
		self._actorId = options.actorId
		self._skillId = options.skillId
		self._assistSkillInfo = options.assistSkillInfo
		self._callBack = options.callBack
		self._assistHero = options.assistHero
	end

	self._skillId = self._assistSkillInfo.Super_skill or self._skillId
  	self._skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(self._skillId)
  	self._heroInfos = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId))

  	self._animationIsDone = false

  	-- self._sharkeScheduler = scheduler.performWithDelayGlobal(function()
  	-- 		q.shakeScreen(8, 0.1)
  	-- 	end, 7/5)

  	scheduler.performWithDelayGlobal(function()
  			self._animationIsDone = true
  		end, 2)
end

function QUIDialogAssistHeroSkillAchieve:viewDidAppear()
	QUIDialogAssistHeroSkillAchieve.super.viewDidAppear(self)

	self:_setHeroInfos()
	self:_setAssistSkillInfo()
end

function QUIDialogAssistHeroSkillAchieve:viewWillDisappear()
	QUIDialogAssistHeroSkillAchieve.super.viewWillDisappear(self)
	if self._sharkeScheduler ~= nil then
		scheduler.unscheduleGlobal(self._sharkeScheduler)
		self._sharkeScheduler = nil
	end
end

function QUIDialogAssistHeroSkillAchieve:_setHeroInfos()
	self:_createHeroHead(1, self._actorId)

	local haveTowAssistHero = true
	local heroNum = 1
	for i = 2, 5 do
		if self._assistSkillInfo["Deputy_hero"..heroNum] ~= nil then
			self:_createHeroHead(i, self._assistSkillInfo["Deputy_hero"..heroNum])
			heroNum = heroNum + 1
		else
    		self._ccbOwner["hero_"..i]:setVisible(false)
    		if self._ccbOwner["plus_"..(i-1)] then
    			self._ccbOwner["plus_"..(i-1)]:setVisible(false)
    		end
    	end
	end
	local offsetX = (4 - (heroNum - 1)) * 64
	self._ccbOwner.head_node:setPositionX(self._ccbOwner.head_node:getPositionX() + offsetX)

	local richText = QRichText.new({
            {oType = "font", content = "获得以上魂师激活", size = 23,color = ccc3(255,255,255)},
            {oType = "font", content = self._heroInfos.name, size = 23,color = ccc3(254,251,0)},
            {oType = "font", content = "融合技：",size = 23,color = ccc3(255,255,255)},
            {oType = "font", content = "融合·"..self._skillConfig.name, size = 23,color = ccc3(254,251,0)},
        },790)
	self._ccbOwner.tf_node_content:addChild(richText)

 
	local wordLen = q.wordLen("获得以上魂师激活"..(self._heroInfos.name or "").."融合技：融合·"..(self._skillConfig.name or ""), 22, 10)
	local positionX = self._ccbOwner.tf_node_content:getPositionX() - (wordLen-504)/2
	local positionY = self._ccbOwner.tf_node_content:getPositionY() - 25
	self._ccbOwner.tf_node_content:setPosition(ccp(positionX, positionY))
end

function QUIDialogAssistHeroSkillAchieve:_setAssistSkillInfo()
	local skillIcon = CCSprite:create()
	self._ccbOwner.node_iconContent:addChild(skillIcon)
	skillIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(self._skillConfig.icon))

	self._ccbOwner.skill_name:setString("融合·"..self._skillConfig.name or "")

	local text = string.format("%s%s%s%s", self._skillConfig.name or "", "魂技替换为", "融合·"..self._skillConfig.name or "", "，在原有效果上")
	local richText = QRichText.new({
            {oType = "font", content = text, size = 23,color = ccc3(255,255,255)},
            {oType = "font", content = self._assistSkillInfo.super_skill_postil or "", size = 23,color = ccc3(254,251,0)},
        },530)
	richText:setAnchorPoint(ccp(0, 1))
	self._ccbOwner.node_desc:addChild(richText)
	self._ccbOwner.skill_description:setString("")
end

function QUIDialogAssistHeroSkillAchieve:_createHeroHead(index, actorId)
	local heros = remote.herosUtil:getHeroByID(actorId) or {}
    local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(actorId))
	local heroHead = QUIWidgetHeroHead.new()
	heroHead:setHeroSkinId(heros.skinId)
    heroHead:setHero(actorId)
    -- heroHead:setBreakthrough(0)
    heroHead:showSabc()
	for _,value in ipairs(HERO_SABC) do
        if value.aptitude == tonumber(heroInfo.aptitude) then
        	heroHead:setBreakthrough(value.breakLevel)
			break
        end
    end

 --    local profession = heroInfo.func or "dps"
	-- heroHead:setProfession(profession)

    self._ccbOwner["node_head_"..index]:addChild(heroHead)
    self._ccbOwner["hero_name_"..index]:setString(heroInfo.name or "")

    if self._assistHero == actorId then
    	heroHead:setHighlightedSelectState(true)
    end
end

function QUIDialogAssistHeroSkillAchieve:_onTriggerClose()
	self:_backClickHandler()
end

function QUIDialogAssistHeroSkillAchieve:_backClickHandler()
	if not self._animationIsDone then return end

    local callback = self._callBack
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)

    if next(app.tip._assistSkillInfos) then
    	app.tip:creatAssistSkillTip(callback)
    elseif next(app.tip._combnationInfos) then
    	app.tip:creatCombinationTip(callback)
    else
	    if callback ~= nil then
	        callback()
	    end
	end
end

return QUIDialogAssistHeroSkillAchieve