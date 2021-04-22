--
-- Author: xurui
-- Date: 2016-04-13 11:35:17
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogAchieveCardNew = class("QUIDialogAchieveCardNew", QUIDialog)

local QNotificationCenter = import("...controllers.QNotificationCenter")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QNotificationCenter = import("...controllers.QNotificationCenter")


function QUIDialogAchieveCardNew:ctor(options)
	local ccbFile = "ccb/effects/card_comeout_ren.ccbi"
	local callBack = {}
	QUIDialogAchieveCardNew.super.ctor(self, ccbFile, callBack, options)

 	if options then
	    self._actorId = options.actorId
	    self._callBack = options.callBack
	    self._isHave = options.isHave or false
	    self._data = options.data
	    self._count = options.count
	    self._isLeft = options.isLeft
	    self._isMount = options.isMount
	    self._actorScale = QStaticDatabase:sharedDatabase():getCharacterByID(options.actorId).actor_scale or 1.0
	end

    app.sound:playSound("common_award_hero")

    self._isEnd = false

    if self._data then
    	local str = ""
	    local config = QStaticDatabase:sharedDatabase():getGradeByHeroActorLevel(self._data.id , self._data.grade or 0)
	    if config ~= nil then
		    local star = (self._data.grade or 0)+1
		    local count = self._count or config.soul_second_hero
		    str = "已拥有此魂师，"..star.."星卡牌转化为魂力精魄"..count.."个"
		    if self._isMount == true then
		    	str = "已拥有此暗器，转化为"..count.."个暗器碎片"
		    end
		end
	    self._ccbOwner.tf_info:setString(str)
	end
    if self._isHave == false then
    	self._ccbOwner.tf_info:setVisible(false)
    end

    -- set bg
	self._ccbOwner.node_bg1:setVisible(true)
	self._ccbOwner.node_bg2:setVisible(false)
    if self._isMount then
    	self._ccbOwner.node_bg1:setVisible(false)
    	self._ccbOwner.node_bg2:setVisible(true)
    	local posY = self._ccbOwner.node_hero_avatar:getPositionY()
    	self._ccbOwner.node_hero_avatar:setPositionY(posY+100)
    end

    self:setHeroAvatar()
end

function QUIDialogAchieveCardNew:viewDidAppear()
	QUIDialogAchieveCardNew.super.viewDidAppear(self)
end

function QUIDialogAchieveCardNew:viewWillDisappear()
	QUIDialogAchieveCardNew.super.viewWillDisappear(self)
end

function QUIDialogAchieveCardNew:setHeroAvatar()
	self._heroAvatar = QUIWidgetHeroInformation.new({isLeft = self._isLeft})
	self._ccbOwner.node_hero_avatar:addChild(self._heroAvatar)
	self._heroAvatar:setBackgroundVisible(false)
	self._heroAvatar:setNameVisible(false)
	self._heroAvatar:setStarVisible(false)

	if self._isMount then
		self._heroAvatar:setAvatarByHeroInfo(nil, self._actorId, 1)
	else
		self._heroAvatar:setAvatarByHeroInfo(nil, self._actorId, 1.2 * 1.1)
	end
	self._heroAvatar:setStarVisible(false)
	-- self._heroAvatar:playChestAnimation(self:safeHandler(function()
		self._heroAvatar:avatarPlayAnimation(ANIMATION_EFFECT.VICTORY, true)
		self._isEnd = true
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_CALL_HERO_SUCCESS})
	-- end))
end

function QUIDialogAchieveCardNew:_backClickHandler()
	if self._isEnd == false then return end

	local callBack = self._callBack
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
	if callBack ~= nil then
		callBack()
	end
end

return QUIDialogAchieveCardNew