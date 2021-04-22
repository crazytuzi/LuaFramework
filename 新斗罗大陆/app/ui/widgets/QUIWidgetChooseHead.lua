--
-- Author: Qinyuanji
-- Date: 2014-11-20
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetChooseHead = class("QUIWidgetChooseHead", QUIWidget)
local QNavigationController = import("...controllers.QNavigationController")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIDialogChooseHead = import("..dialogs.QUIDialogChooseHead")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QUIWidgetAvatar = import("..widgets.QUIWidgetAvatar")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QUIWidgetChooseHead.AVATAR_GAP = 30
QUIWidgetChooseHead.PAGE_MARGIN = 40
QUIWidgetChooseHead.BREAKTHROUGH_AVATAR_LEVEL = 7
QUIWidgetChooseHead.DEFAULT_COLUMN_NUMBER = 4
QUIWidgetChooseHead.EVENT_RESPOND_IGNORE = 0.3

QUIWidgetChooseHead.CLICK_AVATAR_HEAD = "CLICK_AVATAR_HEAD"
QUIWidgetChooseHead.DEFAULT_FRAME_ID = 400000

function QUIWidgetChooseHead:ctor(options, columnNumber)
	local ccbFile = "ccb/Widget_ChooseHead.ccbi"
	local callBacks = {}
	QUIWidgetChooseHead.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._parent = options.parent

	-- calculate a proper width for showing avatar depends on the column numbers
	self._columnNumber = columnNumber or QUIWidgetChooseHead.DEFAULT_COLUMN_NUMBER
	self._pageWidth = self._ccbOwner.layer_content:getContentSize().width
	self._pageHeight = self._ccbOwner.layer_content:getContentSize().height
	self._avatarWidth = (self._pageWidth - 2 * QUIWidgetChooseHead.PAGE_MARGIN + QUIWidgetChooseHead.AVATAR_GAP - self._columnNumber * QUIWidgetChooseHead.AVATAR_GAP) / self._columnNumber
	self._ccbOwner.no_breakthrough:setVisible(false)

	-- default avatars
	self._avatarList = {} 
	local defaultAvatars = QStaticDatabase:sharedDatabase():getDefaultAvatars()
	for k, avatar in pairs(defaultAvatars) do
		local avatarId = avatar.id+QUIWidgetChooseHead.DEFAULT_FRAME_ID
		table.insert(self._avatarList, {index = k, avatarId = avatarId})
	end
	table.sort( self._avatarList, function (a, b)
		return a.index < b.index
	end)

	-- break through avatars
	self._breakthroughtAvatarList = {}
	for _, heroInfo in pairs(remote.herosUtil.heros) do
		if heroInfo.breakthrough >= QUIWidgetChooseHead.BREAKTHROUGH_AVATAR_LEVEL then
			-- local resPath = QStaticDatabase:sharedDatabase():getCharacterByID(heroInfo.actorId).icon
			-- print("heroInfo.actorId = "..heroInfo.actorId)
			local defaultExist = false
			for k, avatar in pairs(defaultAvatars) do
				if heroInfo.actorId == avatar.index_id then
					defaultExist = true
					break
				end
			end
			if not defaultExist then
				local headId = QStaticDatabase:sharedDatabase():convertUserId(heroInfo.actorId)
				if headId then
					local avatarId = headId+QUIWidgetChooseHead.DEFAULT_FRAME_ID
					table.insert(self._breakthroughtAvatarList, {index = headId, avatarId = avatarId})
				end
			end

		end
	end

	-- locked avatars
	self._lockedAvatarList = {} 
	local achieveAvatars = QStaticDatabase:sharedDatabase():getAvatars(remote.headProp.AVATAR_OTHER_TYPE)
	for k, avatar in pairs(achieveAvatars) do
		if remote.achieve:getAchieveIsDone(tostring(avatar.condition)) then
			local avatarId = avatar.id+QUIWidgetChooseHead.DEFAULT_FRAME_ID
			table.insert(self._avatarList, {index = k, resPath = avatarId})
		else
			local avatarId = avatar.id+QUIWidgetChooseHead.DEFAULT_FRAME_ID
			table.insert(self._lockedAvatarList, {index = k, avatarId = avatarId})
		end
	end
	table.sort( self._avatarList, function (a, b)
		return a.index < b.index
	end)
	table.sort( self._lockedAvatarList, function (a, b)
		return a.index < b.index
	end)

	self:show(self._avatarList, self._breakthroughtAvatarList, self._lockedAvatarList)
end

-- Remove all the avatar sprite listener
function QUIWidgetChooseHead:onExit()
	if self._avatarSpriteList == nil or #self._avatarSpriteList == 0 then
		return
	end
	for k, v in pairs(self._avatarSpriteList) do
		v.removeEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self.onAvatarChanged))
	end

	if self._lockedAvatarSpriteList == nil or #self._lockedAvatarSpriteList == 0 then
		return
	end
	for k, v in pairs(self._lockedAvatarSpriteList) do
		v.removeEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self.onAvatarChanged))
	end

	if self._breakthroughAvatarSpriteList == nil or #self._breakthroughAvatarSpriteList == 0 then
		return
	end
	for k, v in pairs(self._breakthroughAvatarSpriteList) do
		v.removeEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self.onAvatarChanged))
	end
end

-- Show avatar in list style
-- Each avatar has touch event associated
-- When avatar is selected, update with server and send event to outer class
function QUIWidgetChooseHead:show(avatarList, breakthroughAvatarList, lockedAvatarList)
	self._contentHeight = 0
	if avatarList == nil or #avatarList <= 0 then
		return
	end

	-- Show normal avatar
	self._avatarSpriteList = {}
	local index = 0
	local startPosX = QUIWidgetChooseHead.PAGE_MARGIN
	local startPosY = self._ccbOwner.basicAvatar:getPositionY() - QUIWidgetChooseHead.AVATAR_GAP
	local currentPosX = startPosX
	local currentPosY = startPosY
	for k, v in ipairs(avatarList) do
	    -- local sprite = QUIWidgetHeroHead.new()	
	    local sprite = QUIWidgetAvatar.new(v.avatarId)
	    -- sprite:setHeroByFile(v.index, v.resPath)
	    -- sprite:addLockedIcon(false)
	    self._ccbOwner.layer_content:addChild(sprite)
		sprite:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self.onAvatarChanged))

      	sprite:setPosition(currentPosX + self._avatarWidth/2, currentPosY - self._avatarWidth/2 - 30)

      	-- sprite:setBreakthrough(1)

      	table.insert(self._avatarSpriteList, sprite)
      	index = index + 1

      	-- calculate new position X, Y
      	currentPosX = startPosX + (index % self._columnNumber) * (self._avatarWidth + QUIWidgetChooseHead.AVATAR_GAP)
       	currentPosY = startPosY - math.modf(index / self._columnNumber) * (self._avatarWidth + QUIWidgetChooseHead.AVATAR_GAP)	
    end

    -- set break through text position
    if index % self._columnNumber ~= 0 then
    	currentPosY = currentPosY - self._avatarWidth - 2 * QUIWidgetChooseHead.AVATAR_GAP
    else 
     	currentPosY = currentPosY - QUIWidgetChooseHead.AVATAR_GAP
    end
    self._ccbOwner.breakthroughAvatar:setPositionY(currentPosY)

    -- Show breakthrough avatar
 	self._breakthroughAvatarSpriteList = {}
 	index = 0
	startPosX = QUIWidgetChooseHead.PAGE_MARGIN
	startPosY = currentPosY - QUIWidgetChooseHead.AVATAR_GAP
	currentPosX = startPosX
	currentPosY = startPosY
	for k, v in ipairs(breakthroughAvatarList) do
	    -- local sprite = QUIWidgetHeroHead.new()	
	    local sprite = QUIWidgetAvatar.new(v.avatarId)
	    -- sprite:setHeroByFile(v.index, v.resPath)
	    self._ccbOwner.layer_content:addChild(sprite)
		sprite:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self.onAvatarChanged))

      	sprite:setPosition(currentPosX + self._avatarWidth/2, currentPosY - self._avatarWidth/2 - 30)

      	-- sprite:setBreakthrough(QUIWidgetChooseHead.BREAKTHROUGH_AVATAR_LEVEL)

      	table.insert(self._breakthroughAvatarSpriteList, sprite)
      	index = index + 1

       	-- calculate new position X, Y
      	currentPosX = startPosX + (index % self._columnNumber) * (self._avatarWidth + QUIWidgetChooseHead.AVATAR_GAP)
       	currentPosY = startPosY - math.modf(index / self._columnNumber) * (self._avatarWidth + QUIWidgetChooseHead.AVATAR_GAP)	
    end
    if index == 0 then
    	print("currentPosY " .. currentPosY)
    	self._ccbOwner.no_breakthrough:setVisible(true)
		self._ccbOwner.no_breakthrough:setPositionY(currentPosY - 20)
		currentPosY = currentPosY - 60
    end

    -- set locked avatar text position
    if index % self._columnNumber ~= 0 then
    	currentPosY = currentPosY - self._avatarWidth - 2 * QUIWidgetChooseHead.AVATAR_GAP
    else 
     	currentPosY = currentPosY - QUIWidgetChooseHead.AVATAR_GAP
    end
    self._ccbOwner.lockedAvatar:setPositionY(currentPosY)
   
    -- Show locked avatar
    self._lockedAvatarSpriteList = {}
 	index = 0
	startPosX = QUIWidgetChooseHead.PAGE_MARGIN
	startPosY = currentPosY - QUIWidgetChooseHead.AVATAR_GAP
	currentPosX = startPosX
	currentPosY = startPosY
	for k, v in ipairs(lockedAvatarList) do
	    -- local sprite = QUIWidgetHeroHead.new()	
	    local sprite = QUIWidgetAvatar.new(v.avatarId)
	    -- sprite:setHeroByFile(v.index, v.resPath)
	    -- sprite:addLockedIcon(true)
	    sprite:showLock(true)
	    self._ccbOwner.layer_content:addChild(sprite)
		sprite:addEventListener(QUIWidgetHeroHead.EVENT_HERO_HEAD_CLICK, handler(self, self.onAvatarChanged))
      	sprite:setPosition(self._pageWidth/2 - 100, currentPosY - self._avatarWidth/2 - 30)
      	-- sprite:setBreakthrough(1)

      	local description = QStaticDatabase:sharedDatabase():getAvatars()[v.index].desc
      	local desc = CCLabelTTF:create()
		desc:setFontSize(24)
		desc:setAnchorPoint(ccp(0, 0.5))
		desc:setFontName(global.font_zhcn)
		desc:setString(description or "")
		desc:setPosition(ccp(70, 0))
		sprite:addChild(desc)

      	table.insert(self._lockedAvatarSpriteList, sprite)
      	index = index + 1

       	-- calculate new position Y
       	currentPosY = currentPosY - self._avatarWidth - QUIWidgetChooseHead.AVATAR_GAP
    end
   
    self._contentHeight = self._pageHeight - currentPosY
end

-- React on click event, but ignore when moving
-- Quick-x also responds on gesture movement, so we set the lastMoveTime when it's moving, and ignore the event if it issues after the release of gesture too soon 
function QUIWidgetChooseHead:onAvatarChanged(event)
	if self._parent:isMoving() then return end
	
	app.sound:playSound("common_item")

	for k, v in ipairs(self._lockedAvatarList) do
		if v.index == event.target._index then
			local config = QStaticDatabase:sharedDatabase():getAvatars()[event.target._index]
			app.tip:floatTip(config.tip or "")
			return
		end
	end

	self:dispatchEvent({name = QUIWidgetChooseHead.CLICK_AVATAR_HEAD, newAvatarId = event.target._index})
end

function QUIWidgetChooseHead:getContentHeight()
	return self._contentHeight
end

return QUIWidgetChooseHead