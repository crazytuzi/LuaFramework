-- @Author: xurui
-- @Date:   2017-10-16 15:37:08
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-07-24 16:21:31
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTavernShowHeroAvatar = class("QUIWidgetTavernShowHeroAvatar", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QSkeletonViewController = import("...controllers.QSkeletonViewController")

QUIWidgetTavernShowHeroAvatar.EVENT_AVATAR_CLICK = "EVENT_AVATAR_CLICK"

function QUIWidgetTavernShowHeroAvatar:ctor(tavernType)
	local ccbFile = "ccb/Widget_TreasureChestDtraw_SilverNew.ccbi"
    if tavernType == TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE then
        ccbFile = "ccb/Widget_TreasureChestDtraw_GoldNew.ccbi"
    end
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIWidgetTavernShowHeroAvatar.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetTavernShowHeroAvatar:onEnter()
    self._ccbOwner.sp_bg:setTouchEnabled(true)
    self._ccbOwner.sp_bg:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._ccbOwner.sp_bg:setTouchSwallowEnabled(true)
    self._ccbOwner.sp_bg:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self._onTouchAvatar))
end

function QUIWidgetTavernShowHeroAvatar:onExit()
end

function QUIWidgetTavernShowHeroAvatar:_onFrame(dt)
    if self._animation then
        self._animation:updateAnimation(dt)
    end
end

function QUIWidgetTavernShowHeroAvatar:setHero(actorId)
    self._actorId = tonumber(actorId)

    -- set hero avatar
    local heroConfig = QStaticDatabase:sharedDatabase():getCharacterByID(actorId)
    if heroConfig and heroConfig.avatar then
        self._ccbOwner.tf_name:setString(heroConfig.name or "宁风致")
        self._ccbOwner.tf_title:setString(heroConfig.title or "")
    end

    local aptitudeInfo = QStaticDatabase:sharedDatabase():getActorSABC(actorId)
    if aptitudeInfo then
        self._ccbOwner.tf_name:setColor(BREAKTHROUGH_COLOR_LIGHT[aptitudeInfo.color])
    end

    if heroConfig.visitingCard then
        self:setHeroCard(heroConfig.visitingCard)
    end

    self:setSABC()
end 

function QUIWidgetTavernShowHeroAvatar:setHeroCard(path)
    self._ccbOwner.node_card:removeAllChildren()
    local sprite = CCSprite:create(path)
    sprite:setPosition(0, 0)

    local size = self._ccbOwner.sheet_layout:getContentSize()
    sprite:setScale(size.width/sprite:getContentSize().width)

    local offsetY = (size.height-sprite:getContentSize().height)/2
    sprite:setPositionY(offsetY)

    local ccclippingNode = CCClippingNode:create()
    local layer = CCLayerColor:create(ccc4(100, 0, 0, 0), size.width, size.height)
    layer:setPosition(-size.width/2, -size.height/2)
    self._ccbOwner.node_card:addChild(layer)
    ccclippingNode:setAlphaThreshold(1)
    ccclippingNode:setStencil(layer)
    ccclippingNode:addChild(sprite)
    self._ccbOwner.node_card:addChild(ccclippingNode)
end

function QUIWidgetTavernShowHeroAvatar:setSABC()
    local aptitudeInfo = db:getActorSABC(self._actorId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

function QUIWidgetTavernShowHeroAvatar:getActorId()
    return self._actorId
end

function QUIWidgetTavernShowHeroAvatar:getContentSize()
    return self._ccbOwner.sheet_layout:getContentSize()
end

function QUIWidgetTavernShowHeroAvatar:setTouchEnabled(isEnable)
    self._isEnable = isEnable
end

function QUIWidgetTavernShowHeroAvatar:_onTouchAvatar(event)
    if self._isEnable and event.name == "ended" then
        self:dispatchEvent({name = QUIWidgetTavernShowHeroAvatar.EVENT_AVATAR_CLICK, actorId = self._actorId})
    end
end

return QUIWidgetTavernShowHeroAvatar