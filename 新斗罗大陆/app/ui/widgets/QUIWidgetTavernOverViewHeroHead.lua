--
-- Author: xurui
-- Date: 2015-06-02 20:39:13
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTavernOverViewHeroHead = class("QUIWidgetTavernOverViewHeroHead", QUIWidget)

local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")

QUIWidgetTavernOverViewHeroHead.OVERVIEW_HEROHEAD_CLICK = "OVERVIEW_HEROHEAD_CLICK"

function QUIWidgetTavernOverViewHeroHead:ctor(options)
	local ccbFile = "ccb/Widget_TreasureChestDraw_Review_client1.ccbi"
	local callBacks = {
  		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
	}
	QUIWidgetTavernOverViewHeroHead.super.ctor(self, ccbFile, callBacks, options)

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetTavernOverViewHeroHead:initGLLayer(glLayerIndex)
    self._glLayerIndex = glLayerIndex or 1
   	if self._heroHead then
    	self._glLayerIndex = self._heroHead:initGLLayer(self._glLayerIndex)
    end
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_name_bg, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.hero_name, self._glLayerIndex)
    
    return self._glLayerIndex
end

function QUIWidgetTavernOverViewHeroHead:setHeroHead(actorId)
	self._actorId = actorId
	local characher = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId) or {}
    
    if not self._heroHead then
		self._heroHead = QUIWidgetHeroHead.new()
		self._ccbOwner.hero_head:addChild(self._heroHead)
	end
	self._heroHead:setHeroSkinId(heroInfo.skinId)
	self._heroHead:setHero(self._actorId, 0)
	self._heroHead:setBreakthrough()
	self._heroHead:setStar(characher.grade)
	self._heroHead:setGodSkillShowLevel(0)
	local profession = characher.func or "dps"
    self._heroHead:setProfession(profession)
	self._heroHead:showSabc()

    if remote.herosUtil:checkHeroHavePast(self._actorId) == false then
    	makeNodeFromNormalToGray(self._heroHead:getNode())
    else
    	makeNodeFromGrayToNormal(self._heroHead:getNode())
    end

	local heroConfig = db:getCharacterByID(self._actorId)
	if heroConfig then
		self._ccbOwner.hero_name:setString(heroConfig.name or "")
	end
end


function QUIWidgetTavernOverViewHeroHead:setHeroHeadNotMine(actorId)
	self._actorId = actorId
	local characher = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)
	local heroInfo = remote.herosUtil:getHeroByID(self._actorId) or {}
    
    if not self._heroHead then
		self._heroHead = QUIWidgetHeroHead.new()
		self._ccbOwner.hero_head:addChild(self._heroHead)
	end
	self._heroHead:setHeroInfo({actorId = self._actorId})
	-- self._heroHead:setStar(characher.grade)
	self._heroHead:setStar(0)
	self._heroHead:setBreakthrough()
	self._heroHead:setLevel()
	
	local profession = characher.func or "dps"
    self._heroHead:setProfession(profession)
	self._heroHead:showSabc()

	local heroConfig = db:getCharacterByID(self._actorId)
	if heroConfig then
		self._ccbOwner.hero_name:setString(heroConfig.name or "")
	end
end


function QUIWidgetTavernOverViewHeroHead:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetTavernOverViewHeroHead:_onTriggerClick()
	self:dispatchEvent({name = QUIWidgetTavernOverViewHeroHead.OVERVIEW_HEROHEAD_CLICK, actorId = self._actorId})
end

return QUIWidgetTavernOverViewHeroHead
