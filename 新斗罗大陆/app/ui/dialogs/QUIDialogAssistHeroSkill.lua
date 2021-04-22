--
-- Author: xurui
-- Date: 2015-11-23 14:12:57
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogAssistHeroSkill = class("QUIDialogAssistHeroSkill", QUIDialog)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QNavigationController = import("...controllers.QNavigationController")
local QQuickWay = import("...utils.QQuickWay")
local QUIViewController = import("..QUIViewController")
local QRichText = import("...utils.QRichText")
local QColorLabel = import("...utils.QColorLabel")
local QScrollView = import("...views.QScrollView") 

function QUIDialogAssistHeroSkill:ctor(options)
	local ccbFile = "ccb/Dialog_Heji.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerClickGetHero0", callback = handler(self, self._onTriggerClickGetHero0)},
		{ccbCallbackName = "onTriggerClickGetHero1", callback = handler(self, self._onTriggerClickGetHero1)},
		{ccbCallbackName = "onTriggerClickGetHero2", callback = handler(self, self._onTriggerClickGetHero2)},
		{ccbCallbackName = "onTriggerClickGetHero3", callback = handler(self, self._onTriggerClickGetHero3)},
	}
	QUIDialogAssistHeroSkill.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	self._assistSkill = options.assistSkill
	self._actorId = options.actorId
	self._skillSlotInfo = options.skillSlotInfo
	self._isMockBattle = false
	if options.isMockBattle then
		self._isMockBattle = true
	end


	local isSelf = false
	local superSkill = self._assistSkill.Super_skill
	if self._assistSkill.Super_skill == nil then
		superSkill = self._skillSlotInfo.skillId or self._skillSlotInfo.id
		isSelf = true
	end
	self._skillConfig = QStaticDatabase:sharedDatabase():getSkillByID(superSkill)

	self._ccbOwner.frame_tf_title:setString("融合·"..self._skillConfig.name)

	self._scale = 1

	-- 设置魂师头像
	local heroNums = 0
	self._heroHead = {}
	self._haveHeros = {}
	for i = 1, 4, 1 do
		self._ccbOwner["no_team"..i]:setVisible(false)
		local actorId = self._assistSkill["Deputy_hero"..i]
		if actorId ~= nil then
			self._heroHead = QUIWidgetHeroHead.new()
			self._ccbOwner["hero_head"..i]:addChild(self._heroHead)
			local breakthrough = 0
			local isHide = db:checkHeroShields(actorId)
			if self._assistSkill["show_hero"..i] == 1 or isHide then
				self._haveHeros[i] = false
				self._heroHead:setHero(nil, nil, nil, true)
				self._ccbOwner["no_team"..i]:setVisible(false)
				self._ccbOwner["node_gethero"..i]:setVisible(false)
				self._ccbOwner["hero_name"..i]:setString("即将开放")
				breakthrough = nil
			else
				self._haveHeros[i] = true
				self._heroHead:setHero(actorId)
				if self:checkHasHeroById(actorId) then
					self._ccbOwner["node_gethero"..i]:setVisible(false)
	            else
	            	makeNodeFromNormalToGray(self._ccbOwner["hero_head"..i])
					self._ccbOwner["node_gethero"..i]:setVisible(true)
				end
				local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(actorId))
				-- local profession = heroInfo.func or "dps"
				-- self._heroHead:setProfession(profession)
				self._ccbOwner["hero_name"..i]:setString(heroInfo.name or "")
			end
			self._heroHead:setBreakthrough(breakthrough)
   	 		self._heroHead:showSabc()
			heroNums = heroNums + 1
		else
			self._ccbOwner["node_head"..i]:setVisible(false)
		end
	end
	self._ccbOwner.node_head:setPositionX(self._ccbOwner.node_head:getPositionX()+(4-heroNums) * 72.5)
	local level = 1
	if self._skillSlotInfo.info then
		level = self._skillSlotInfo.info.slotLevel or 1
	end
	self._ccbOwner.level:setString("LV."..level)
	local desc = QColorLabel.removeColorSign(self._skillConfig.description or "") 
	self._ccbOwner.skill_dec:setString("")

	local itemContentSize = self._ccbOwner.sheet_layout:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, itemContentSize, {bufferMode = 1})
    self._scrollView:setVerticalBounce(true)
	local text = QColorLabel:create(desc, 430, nil, nil, nil, COLORS.k)
	text:setAnchorPoint(ccp(0, 1))
	local totalHeight = text:getContentSize().height
	self._scrollView:addItemBox(text)
	self._scrollView:setRect(0, -totalHeight, 0, 0)

	-- set main hero head
	local heros = remote.herosUtil:getHeroByID(self._actorId) or {}
	local heroHead = QUIWidgetHeroHead.new()
	heroHead:setHeroSkinId(heros.skinId)
	heroHead:setHero(self._actorId)
	heroHead:setBreakthrough(0)
	heroHead:showSabc()
	self._ccbOwner.hero_head0:addChild(heroHead)
	local heroInfo = q.cloneShrinkedObject(QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId))
	self._ccbOwner.hero_name0:setString(heroInfo.name or "")
	self._haveHeros[0] = true

	-- check assist skill active state 
	self.assistHero, self._isActive = remote.herosUtil:checkHeroHaveAssistHero(self._actorId)
	
end

function QUIDialogAssistHeroSkill:checkHasHeroById(actorId)
	if self._isMockBattle then
		return remote.mockbattle:checkHeroHasChoosen(actorId)
	else
		return remote.herosUtil:checkHeroHavePast(actorId)
	end
end


function QUIDialogAssistHeroSkill:viewDidAppear()
	QUIDialogAssistHeroSkill.super.viewDidAppear(self)

	-- set skill icon
	local headImageTexture = CCTextureCache:sharedTextureCache():addImage(self._skillConfig.icon)
	self._imgSp = CCSprite:createWithTexture(headImageTexture)
	local imgSize = self._imgSp:getContentSize()
	self._imgSp:setScale(self._scale * 100/imgSize.width)

	if self._isActive == false then
		self._ccbOwner.node_icon1:setVisible(false)
		self._ccbOwner.node_icon2:setVisible(true)
		self._ccbOwner.node_effect2:setVisible(false)
		self._ccbOwner.skill_icon2:addChild(self._imgSp)
		makeNodeFromNormalToGray(self._ccbOwner.node_skill_icon2)
	else
		self._ccbOwner.skill_icon1:addChild(self._imgSp)
	end
end 

function QUIDialogAssistHeroSkill:viewWillDisappear()
	QUIDialogAssistHeroSkill.super.viewWillDisappear(self)
end 

function QUIDialogAssistHeroSkill:_onTriggerClickGetHero0()
	self:_openHeroDetail(self._actorId, 0)
end

function QUIDialogAssistHeroSkill:_onTriggerClickGetHero1(e)
	if e ~= nil then
		app.sound:playSound("common_common")
	end
	self:_openHeroDetail(self._assistSkill.Deputy_hero1, 1)
end

function QUIDialogAssistHeroSkill:_onTriggerClickGetHero2(e)
	if e ~= nil then
		app.sound:playSound("common_common")
	end
	self:_openHeroDetail(self._assistSkill.Deputy_hero2, 2)
end

function QUIDialogAssistHeroSkill:_onTriggerClickGetHero3(e)
	if e ~= nil then
		app.sound:playSound("common_common")
	end
	self:_openHeroDetail(self._assistSkill.Deputy_hero3, 3)
end

function QUIDialogAssistHeroSkill:_openHeroDetail(actorId, index)
	if self._haveHeros[index] == false then 
		app.tip:floatTip("该魂师即将开放，敬请期待")
		return 
	end
  	self:viewAnimationOutHandler()
  	app.tip:itemTip(ITEM_TYPE.HERO, actorId, true)
end

function QUIDialogAssistHeroSkill:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogAssistHeroSkill:_backClickHandler()
  self:_onTriggerClose()
end 

function QUIDialogAssistHeroSkill:viewAnimationOutHandler()
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end


return QUIDialogAssistHeroSkill