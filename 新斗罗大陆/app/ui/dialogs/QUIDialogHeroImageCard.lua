-- @Author: xurui
-- @Date:   2017-09-30 14:17:50
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-20 11:31:13
local QUIDialog = import(".QUIDialog")
local QUIDialogHeroImageCard = class("QUIDialogHeroImageCard", QUIDialog)

local QUIWidgetHeroImageCard = import("..widgets.QUIWidgetHeroImageCard")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogHeroImageCard:ctor(options)
    local ccbFile = "ccb/Dialog_hero_card.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerRight", callback = handler(self, QUIDialogHeroImageCard._onTriggereRight)},
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIDialogHeroImageCard._onTriggereLeft)},
    }
	QUIDialogHeroImageCard.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._actorId = options.actorId
        self._herosID = options.herosID
        self._pos = options.pos
    end

    if self._herosID and #self._herosID > 0 then
        self._ccbOwner.node_btn:setVisible(true)
    else
        self._ccbOwner.node_btn:setVisible(false)
    end
end

function QUIDialogHeroImageCard:_onTriggereRight()
    app.sound:playSound("common_change")
    local n = table.nums(self._herosID)
    if nil ~= self._pos and n > 1 then
        self._pos = self._pos + 1
        if self._pos > n then
            self._pos = 1
        end
        local options = self:getOptions()
        options.pos = self._pos
        self._actorId = self._herosID[self._pos]
        self:setHeroCard()
    end
end

function QUIDialogHeroImageCard:_onTriggereLeft()
    app.sound:playSound("common_change")
    local n = table.nums(self._herosID)
    if nil ~= self._pos and n > 1 then
        self._pos = self._pos - 1
        if self._pos < 1 then
            self._pos = n
        end
        local options = self:getOptions()
        options.pos = self._pos
        self._actorId = self._herosID[self._pos]
        self:setHeroCard()
    end
end

function QUIDialogHeroImageCard:viewDidAppear()
    QUIDialogHeroImageCard.super.viewDidAppear(self)

    self:setHeroCard()
end

function QUIDialogHeroImageCard:viewWillDisAppear()
    QUIDialogHeroImageCard.super.viewWillDisAppear(self)
end

function QUIDialogHeroImageCard:setHeroCard()
    if self._widget == nil then
        self._widget = QUIWidgetHeroImageCard.new()
        self._ccbOwner.node_hero_card:addChild(self._widget)
    end
    self._widget:setHeroInfo(self._actorId)

    -- local characherConfig = QStaticDatabase:sharedDatabase():getCharacterByID(self._actorId)

    -- if characherConfig.card then
    -- 	local sprite = CCSprite:create(characherConfig.card)
    --     self._ccbOwner.node_hero_card:removeAllChildren()
    -- 	self._ccbOwner.node_hero_card:addChild(sprite)
    -- end
end

function QUIDialogHeroImageCard:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogHeroImageCard:_onTriggerClose()
  	app.sound:playSound("common_close")

	self:playEffectOut()
end

return QUIDialogHeroImageCard