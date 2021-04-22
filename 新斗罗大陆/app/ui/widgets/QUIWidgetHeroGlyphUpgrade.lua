
--
-- Author: Kumo.Wang
-- Date: Wed Apr 27 18:37:13 2016
--
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetHeroGlyphUpgrade = class("QUIWidgetHeroGlyphUpgrade", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QRemote = import("...models.QRemote")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QUIWidgetGlyphClient = import("..widgets.QUIWidgetGlyphClient")
local QUIWidgetGlyphClientCell = import("..widgets.QUIWidgetGlyphClientCell")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")

function QUIWidgetHeroGlyphUpgrade:ctor(options)
	local ccbFile = "ccb/Widget_DiaoWen.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerAdd", callback = handler(self, QUIWidgetHeroGlyphUpgrade._onTriggerAdd)}
    }
	QUIWidgetHeroGlyphUpgrade.super.ctor(self, ccbFile, callBacks, options)

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    page.topBar:showWithGlyph()
    
    self._totleHeight = 0

    self._pageWidth = self._ccbOwner.node_mask:getContentSize().width
    self._pageHeight = self._ccbOwner.node_mask:getContentSize().height
    self._pageContent = self._ccbOwner.node_contain
    self._orginalPosition = ccp(self._pageContent:getPosition())

    local layerColor = CCLayerColor:create(ccc4(255,0,0,150),self._pageWidth,self._pageHeight)
    local ccclippingNode = CCClippingNode:create()
    layerColor:setPositionX(self._ccbOwner.node_mask:getPositionX())
    layerColor:setPositionY(self._ccbOwner.node_mask:getPositionY())
    ccclippingNode:setStencil(layerColor)
    self._pageContent:removeFromParent()
    ccclippingNode:addChild(self._pageContent)

    self._ccbOwner.node_mask:getParent():addChild(ccclippingNode)
    
    self._itemId = 800001 --体技晶石物品ID

    -- self._ccbOwner.btn_add:setVisible(false)
    self._ccbOwner.tf_glyph_num:setString("")
    -- self._ccbOwner.scroll_bar:setOpacity(0)
    -- self._ccbOwner.scroll_sm:setOpacity(0)
    -- self._ccbOwner.node_shadow_bottom:setVisible(false)
    -- self._ccbOwner.node_shadow_top:setVisible(false)
    -- self:_scrollAutoLayout()
    self:_updateInfo()
end

function QUIWidgetHeroGlyphUpgrade:onEnter()
    self._touchLayer = QUIGestureRecognizer.new()
    self._touchLayer:attachToNode(self._ccbOwner.node_mask:getParent(),self._pageWidth, self._pageHeight, -self._pageWidth/2, -self._pageHeight/2, handler(self, self.onTouchEvent))
    self._touchLayer:enable()
    self._touchLayer:addEventListener(QUIGestureRecognizer.EVENT_SLIDE_GESTURE, handler(self, self.onTouchEvent))

    self._remoteProxy = cc.EventProxy.new(remote)
    self._remoteProxy:addEventListener(QRemote.HERO_UPDATE_EVENT, handler(self, self.onEvent)) 

    self._itemProxy = cc.EventProxy.new(remote.items)
    self._itemProxy:addEventListener(remote.items.EVENT_ITEMS_UPDATE, handler(self, self.onEvent))
end

function QUIWidgetHeroGlyphUpgrade:onExit()
    self._touchLayer:removeAllEventListeners()
    self._touchLayer:disable()
    self._touchLayer:detach()

    self._itemProxy:removeAllEventListeners()
    self._remoteProxy:removeAllEventListeners()
   
    if self._handler ~= nil then
        scheduler.unscheduleGlobal(self._handler)
    end
end

-- function QUIWidgetHeroGlyphUpgrade:_scrollAutoLayout()
    -- local totalHeight = self._ccbOwner.scroll_bar:getContentSize().height
    -- local smHeight = self._ccbOwner.scroll_sm:getContentSize().height
    -- local rate = (self._pageContent:getPositionY() - self._orginalPosition.y)/(self._totleHeight - self._pageHeight)
    -- self._ccbOwner.scroll_sm:setPositionY(rate * (totalHeight - smHeight) + self._ccbOwner.scroll_bar:getPositionY() + smHeight/2)
-- end

-- 处理各种touch event
function QUIWidgetHeroGlyphUpgrade:onTouchEvent(event)
    if event == nil or event.name == nil then
        return
    end
    if self._totleHeight <= self._pageHeight then
        return 
    end
    if event.name == QUIGestureRecognizer.EVENT_SLIDE_GESTURE then
        -- self._page:endMove(event.distance.y)
    elseif event.name == "began" then
        self._startY = event.y
        self._pageY = self._pageContent:getPositionY()
    elseif event.name == "moved" then
        if math.abs(event.y - self._startY) < 5 then return end
        local offsetY = self._pageY + event.y - self._startY
        if offsetY < self._orginalPosition.y then
            -- self._ccbOwner.node_shadow_bottom:setVisible(true)
            -- self._ccbOwner.node_shadow_top:setVisible(false)
            offsetY = self._orginalPosition.y
        elseif offsetY > (self._totleHeight - self._pageHeight + self._orginalPosition.y) then
            offsetY = (self._totleHeight - self._pageHeight + self._orginalPosition.y)
            -- self._ccbOwner.node_shadow_bottom:setVisible(false)
            -- self._ccbOwner.node_shadow_top:setVisible(true)
        -- else
        -- self._ccbOwner.node_shadow_bottom:setVisible(true)
        -- self._ccbOwner.node_shadow_top:setVisible(true)
        end
        self._pageContent:setPositionY(offsetY)
        -- self:_showScroll()
    elseif event.name == "ended" then
    end
end

function QUIWidgetHeroGlyphUpgrade:onEvent(event)
    if event.name == QRemote.HERO_UPDATE_EVENT then
        self:_updateHero()
    elseif event.name == remote.items.EVENT_ITEMS_UPDATE then
        self:_updateInfo()
    end
end

-- function QUIWidgetHeroGlyphUpgrade:_showScroll()
    -- if self._handler ~= nil then
    --     scheduler.unscheduleGlobal(self._handler)
    -- end
    -- self._handler = scheduler.performWithDelayGlobal(function()
    --         -- self._ccbOwner.scroll_bar:runAction(CCFadeOut:create(0.3))
    --         -- self._ccbOwner.scroll_sm:runAction(CCFadeOut:create(0.3))
    --         -- self._ccbOwner.node_scroll:setVisible(false)
    --         scheduler.unscheduleGlobal(self._handler)
    --         self._handler = nil
    --     end,0.5)
    -- self._ccbOwner.scroll_bar:setOpacity(255)
    -- self._ccbOwner.scroll_sm:setOpacity(255)
    -- self:_scrollAutoLayout()
-- end

function QUIWidgetHeroGlyphUpgrade:_updateHero()
    -- local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    if self._actorId then
        self:setHero(self._actorId)
    end
end

function QUIWidgetHeroGlyphUpgrade:_updateInfo()
    local num = remote.items:getItemsNumByID(self._itemId)
    local numX = self._ccbOwner.tf_glyph_num:getPositionX()
    self._ccbOwner.tf_glyph_num:setString(num)
    local numW = self._ccbOwner.tf_glyph_num:getContentSize().width
    local spW = self._ccbOwner.sp_glyph_icon:getContentSize().width * self._ccbOwner.sp_glyph_icon:getScaleX() / 2
    self._ccbOwner.sp_glyph_icon:setPositionX( numX - numW - spW )
end

function QUIWidgetHeroGlyphUpgrade:setHero(actorId)
    if self._actorId ~= actorId then
        self._actorId = actorId
        self._pageContent:removeAllChildren()
        self._pageContent:setPosition(self._orginalPosition.x, self._orginalPosition.y)
        self._totleHeight = 0

        self._glyphClint = QUIWidgetGlyphClient.new()
        self._glyphClint:setHero(actorId, true)
        self._glyphClint:setPositionY(-50)
        self._glyphClint:addEventListener(QUIWidgetGlyphClientCell.EVENT_CLICK, handler(self, self._onEvent))
        self._glyphClint:addEventListener(QUIWidgetGlyphClient.UPDATE_HEIGHT, handler(self, self._updateHeight))

        self._pageContent:addChild(self._glyphClint)
    else
        self._glyphClint:setHero(actorId)
    end

    self:_updateHeight()
end

function QUIWidgetHeroGlyphUpgrade:_updateHeight()
    if self._glyphClint then
        self._totleHeight = self._glyphClint:getHeight()
    end
end

function QUIWidgetHeroGlyphUpgrade:_onEvent( event )
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogGlyphUp",
        options = {skillId = event.skillId, skillLevel = event.skillLevel, actorId = event.actorId, callBackFun = handler(self, QUIWidgetHeroGlyphUpgrade._updateHero)}}, {isPopCurrentDialog = false})
end

function QUIWidgetHeroGlyphUpgrade:_onTriggerAdd()
    QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._itemId, nil, nil, false)
end

return QUIWidgetHeroGlyphUpgrade