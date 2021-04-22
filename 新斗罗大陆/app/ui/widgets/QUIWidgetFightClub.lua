--
-- zxs
-- 搏击俱乐部玩家形象
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetFightClub = class("QUIWidgetFightClub", QUIWidget)

local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QActorProp = import("...models.QActorProp")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetHeroTitleBox = import(".QUIWidgetHeroTitleBox")
local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")

QUIWidgetFightClub.EVENT_BATTLE = "EVENT_BATTLE"
QUIWidgetFightClub.EVENT_VISIT = "EVENT_VISIT"

function QUIWidgetFightClub:ctor(options)
	local ccbFile = "ccb/Widget_fight_club.ccbi"
  	local callBacks = {
    	{ccbCallbackName = "onTriggerAvatar", callback = handler(self, self._onTriggerAvatar)},
    	{ccbCallbackName = "onTriggerInfo", callback = handler(self, self._onTriggerInfo)},
  	}
	QUIWidgetFightClub.super.ctor(self,ccbFile,callBacks,options)
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._words = QStaticDatabase:sharedDatabase():getArenaLangaue()
    self._animationManager = tolua.cast(self._ccbView:getUserObject(), "CCBAnimationManager")

    self:resetInfo()
end

function QUIWidgetFightClub:onEnter()
	QUIWidgetFightClub.super.onEnter(self)
end

function QUIWidgetFightClub:onExit()
	QUIWidgetFightClub.super.onExit(self)
    if self._animationManager ~= nil then
        self._animationManager:disconnectScriptHandler()
    end
end

function QUIWidgetFightClub:resetInfo()
	self._ccbOwner.tf_user_name:setString("")
	self._ccbOwner.tf_win_count:setString("")
	self._ccbOwner.tf_wave_value:setString(0)
	self._ccbOwner.tf_force_value:setString(0)
	self._ccbOwner.node_other:setVisible(true)
	self._ccbOwner.node_defeat:setVisible(false)

	self._ccbOwner.level_jiangji:setVisible(false)
	self._ccbOwner.level_baoji:setVisible(false)
	self._ccbOwner.level_jinji:setVisible(false)

	self._ccbOwner.node_avatar:removeAllChildren()
end

function QUIWidgetFightClub:setInfo(info, refresh)
	self:resetInfo()

	self.info = info

	self._avatar = QUIWidgetHeroInformation.new()
	self._avatar:setBackgroundVisible(false)
	self._avatar:setNameVisible(false)
	self._avatar:setScale(0.8)
	self._avatar:setAutoStand(true)
	self._avatar:setAvatarVisible(true)
	self._avatar:setPositionY(-20)
	self._ccbOwner.node_avatar:addChild(self._avatar)

	if refresh then
		self._effect = QUIWidgetAnimationPlayer.new()
		self._effect:playAnimation("effects/ChooseHero.ccbi",nil,function ()
			self._effect = nil
		end)
		self._effect:setPositionY(-90)
		self:addChild(self._effect)
	else
		if self._effect ~= nil then
			self._effect:disappear()
			self._effect = nil
		end
	end

	local actorId
	local heroInfo
	if self.info.defaultActorId and self.info.defaultActorId ~= 0 then
		actorId = self.info.defaultActorId
		heroInfo = remote.herosUtil:getSpecifiedHeroById(self.info, actorId)
	else
		heroInfo = remote.herosUtil:getMaxForceByHeros(self.info)
		actorId =  heroInfo.actorId
	end
	if actorId then
		if q.isEmpty(heroInfo) then
			heroInfo = {skinId = self.info.defaultSkinId or 0}
		end
		
		local showHeroInfo = clone(heroInfo)
		showHeroInfo.skinId = self.info.defaultSkinId or 0

		self._avatar:setAvatarByHeroInfo(showHeroInfo, actorId, 1.3)
		self._avatar:setStarVisible(false)
	end

	local winCount = (self.info.fightClubRoomRank or 1).." ("..(self.info.fightClubWinCount or 0).."胜)"
	self._ccbOwner.tf_user_name:setString(self.info.name)
	self._ccbOwner.tf_wave_value:setString(winCount)
	
	local force = self.info.force or 0
	local num, unit = q.convertLargerNumber(force)
	self._ccbOwner.tf_force_value:setString(num..(unit or ""))
	self._ccbOwner.tf_server_name:setString(self.info.game_area_name or "")

	local myFloor = remote.fightClub:getMainInfo().floor
	local roomState = remote.fightClub:getRoomState(myFloor, self.info.fightClubRoomRank)
	if roomState == remote.fightClub.STATE_DOWN then
		self._ccbOwner.level_jiangji:setVisible(true)
	elseif roomState == remote.fightClub.STATE_KEEP then
		self._ccbOwner.level_baoji:setVisible(true)
	elseif roomState == remote.fightClub.STATE_UP then
		self._ccbOwner.level_jinji:setVisible(true)
	end

	-- 已击败变灰
	local bFail = remote.fightClub:getIsRivalFailed(self.info.userId)
	if bFail then
		self._avatar:pauseAnimation()
		self._ccbOwner.node_defeat:setVisible(true)
		self._ccbOwner.node_flag:setVisible(false)
	else
		self._ccbOwner.node_flag:setVisible(true)
		self._ccbOwner.node_defeat:setVisible(false)
	end

	if remote.user.userId == self.info.userId then
		self._ccbOwner.node_self:setVisible(true)
		self._ccbOwner.effect_4:setVisible(true)
		self._ccbOwner.node_other:setVisible(false)
		self._ccbOwner.node_flag:setVisible(false)
	else
		self._ccbOwner.node_self:setVisible(false)
		self._ccbOwner.effect_4:setVisible(false)
		self._ccbOwner.node_other:setVisible(true)
	end

	self:showTitle(self.info.title, self.info.soulTrial)
end

function QUIWidgetFightClub:showTitle(title, soulTrial)
	local titleBox = QUIWidgetHeroTitleBox.new()
	titleBox:setTitleId(title, soulTrial)
	self._ccbOwner.chenghao:removeAllChildren()
	self._ccbOwner.chenghao:addChild(titleBox)
end

function QUIWidgetFightClub:removeWord()
	if self._wordWidget ~= nil then
		self._wordWidget:removeFromParent()
		self._wordWidget = nil
	end
end

function QUIWidgetFightClub:showWord(str)
	self:removeWord()
	if self.info == nil then return end
	local word = "封号斗罗"
	if str ~= nil then
		word = str
	elseif self._words ~= nil then
		local maxCount = table.nums(self._words)
		local count = math.random(1, maxCount)
		for _,value in pairs(self._words) do
			if value.id == count then
				word = value.langaue
				break
			end
		end
	end

	if self._wordWidget == nil then
		self._wordWidget = QChatDialog.new()
		self:addChild(self._wordWidget)
	end

	self._wordWidget:setPositionY(70)
	self._wordWidget:setPositionX(20)
	self._wordWidget:setString(word)
	local size = self._wordWidget:getContentSize()
	local pos = self._wordWidget:convertToWorldSpace(ccp(0,0))
	if (pos.x + size.width) > display.width then
		self._wordWidget:setScaleX(-1)
		self._wordWidget:setPositionX(-20)
	else
		self._wordWidget:setScaleX(1)
	end
end

function QUIWidgetFightClub:_onTriggerInfo(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_info) == false then return end
	self:dispatchEvent({name = QUIWidgetFightClub.EVENT_VISIT, info = self.info, isWorship = self.isWorship, widget = self, index = self.index})
end

function QUIWidgetFightClub:_onTriggerAvatar()
	self:dispatchEvent({name = QUIWidgetFightClub.EVENT_BATTLE, info = self.info, isWorship = self.isWorship, widget = self, index = self.index})
end

return QUIWidgetFightClub