--
-- Author: Your Name
-- Date: 2015-01-17 11:36:24
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogXiaoNaNa = class("QUIDialogXiaoNaNa", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView")
local QColorLabel = import("...utils.QColorLabel")
local QRichText = import("...utils.QRichText")
local QUIWidgetHelpDescribe = import("..widgets.QUIWidgetHelpDescribe")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")

QUIDialogXiaoNaNa.BUTTON_HEIGHT = 48
QUIDialogXiaoNaNa.ACTION_DURATION = 0.2
QUIDialogXiaoNaNa.BUTTON_GAP = 3

function QUIDialogXiaoNaNa:ctor(options)
 	local ccbFile = "ccb/Dialog_xiaonana.ccbi"
    self._customizedCallbacks = {
        child = handler(self, self._childClick), 
        parent = handler(self, self._parentClick), 
    }
    self._callBacks = {
        -- @qinyuanji, this function callback are created on the fly
        {ccbCallbackName = "onTriggerZan", callback = handler(self, QUIDialogXiaoNaNa.onTriggerZan)},
    }
    QUIDialogXiaoNaNa.super.ctor(self, ccbFile, self._callBacks, options)

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setAllUIVisible(false)
    page.topBar:showWithHeroOverView()

    self._treeNode = {}

    self:_initNavigationSlide()
    self:_initContentSlid()
    self:_initNavigation()
end

function QUIDialogXiaoNaNa:viewDidAppear()
    QUIDialogXiaoNaNa.super.viewDidAppear(self)

    app:getClient():getXiaoNaNaDianZangTotal(function (data)
            self._zan = {}
            self._zaned = {}
            for k, v in ipairs(data.gameTipsGetAllTipsInfoResponse.gameTipsInfoList) do
                self._zan[v.tips_id] = v.like_count
            end
            for k, v in ipairs(data.gameTipsGetAllTipsInfoResponse.like_tips_id or {}) do
                self._zaned[v] = true
            end

            local activatedNode = self:UpdateTreeNode(true)
            activatedNode.func(activatedNode.value)
        end)

    self:addBackEvent(true)
end 

function QUIDialogXiaoNaNa:viewWillDisappear()
    QUIDialogXiaoNaNa.super.viewWillDisappear(self)

    self:removeBackEvent()
end 

function QUIDialogXiaoNaNa:viewAnimationInHandler()
end

function QUIDialogXiaoNaNa:_initNavigationSlide()
    self._navPageWidth = self._ccbOwner.nav_menu:getContentSize().width
    self._navPageHeight = self._ccbOwner.nav_menu:getContentSize().height

    self._navScrollView = QScrollView.new(self._ccbOwner.navSheet, self._ccbOwner.nav_menu:getContentSize(), {sensitiveDistance = 10, moveDuration = 0.5})
    self._navScrollView:setVerticalBounce(true)

    self._navScrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onNavScrollViewMoving))
    self._navScrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onNavScrollViewBegan))
end

function QUIDialogXiaoNaNa:_initContentSlid()
    self._pageWidth = self._ccbOwner.sheet_layout:getContentSize().width
    self._pageHeight = self._ccbOwner.sheet_layout:getContentSize().height

    self._scrollView = QScrollView.new(self._ccbOwner.sheet, self._ccbOwner.sheet_layout:getContentSize(), {sensitiveDistance = 10, moveDuration = 0.5})
    self._scrollView:setVerticalBounce(true)
end

function QUIDialogXiaoNaNa:_createParentButton(value, callback)
    local button = CCControlButton:create("", global.font_zhcn, 26)
    button:setPreferredSize(CCSize(231, 62))
    local func = function (eventType)
        callback(value, eventType)
    end
    button:addHandleOfControlEvent(func, 1)
    button:addHandleOfControlEvent(func, 2)
    button:addHandleOfControlEvent(func, 4)
    button:addHandleOfControlEvent(func, 8)
    button:addHandleOfControlEvent(func, 16)
    button:addHandleOfControlEvent(func, 32)
    button:addHandleOfControlEvent(func, 64)
    button:addHandleOfControlEvent(func, 128)
    button:addHandleOfControlEvent(func, 256)

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ui/Xiaonana.plist")
    local normal = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(value.value.image_path_2)
    local highlight = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(value.value.image_path_1)
    button:setBackgroundSpriteFrameForState(normal, 1)
    button:setBackgroundSpriteFrameForState(highlight, 2)
    button:setBackgroundSpriteFrameForState(highlight, 4)
    button:setZoomOnTouchDown(false)
    button:setAnchorPoint(ccp(0, 1))

    value.button = button
    return button
end

function QUIDialogXiaoNaNa:_createSubButton(value, callback)
    local button = CCControlButton:create(value.name, global.font_zhcn, 24)
    button:setPreferredSize(CCSize(220, 48))
    button:addHandleOfControlEvent(function (eventType)
        callback(value, eventType)
    end, 32)

    local normal = CCSprite:create("ui/common3/but_arena_2.png")
    local highlight = CCSprite:create("ui/common3/but_arena_1.png")
    
    button:setBackgroundSpriteFrameForState(normal:getDisplayFrame(), 1)
    button:setBackgroundSpriteFrameForState(highlight:getDisplayFrame(), 2)
    button:setBackgroundSpriteFrameForState(highlight:getDisplayFrame(), 4)
    button:setBackgroundSpriteFrameForState(highlight:getDisplayFrame(), 8)
    button:setTitleColorForState(ccc3(253, 239, 205), 1)
    button:setTitleColorForState(ccc3(254, 251, 0), 2)
    button:setTitleColorForState(ccc3(254, 251, 0), 4)
    button:setTitleColorForState(ccc3(254, 251, 0), 8)
    button:setZoomOnTouchDown(false)
    button:setAnchorPoint(ccp(0, 1))

    value.button = button
    return button
end

function QUIDialogXiaoNaNa:_initNavigation(initName, initSubName)
    self._tree = QStaticDatabase:sharedDatabase():getXiaoNaNaTreeStructure()
    local height = 0
    for k, v in ipairs(self._tree) do
        local parent = self:_createParentButton(v, self._customizedCallbacks["parent"])
        parent:setPosition(ccp(5, height))
        height = height - parent:getContentSize().height - 2

        if v.children then
            self:insertChildNode(nil, parent, nil, v, k == 1, true)        

            for k1, v1 in ipairs(v.children) do
                local child = self:_createSubButton(v1, self._customizedCallbacks["child"])
                child:setPosition(ccp(5, height))
                self._navScrollView:addItemBox(child)
                self:insertChildNode(parent, child, self._customizedCallbacks["child"], v1, k1 == 1, true)
                height = height - child:getContentSize().height - 2
            end
        else
            self:insertChildNode(nil, parent, self._customizedCallbacks["parent"], v, k == 1, true)        
        end

        self._navScrollView:addItemBox(parent)
    end

    self._navScrollView:setRect(0, height, 0, self._navPageWidth)
end

-- Build tree structure and expand/folder animation
-- Build a tree structure
-- If parent is nil, node is root or it's a child node
function QUIDialogXiaoNaNa:insertChildNode(parent, child, func, value, expand, unlocked)
    if unlocked ~= false then
        if parent == nil then
            table.insert(self._treeNode, {expand = expand or false, node = child, func = func, value = value})
            child._childNode = {}
            return
        else
            for _, v in ipairs(self._treeNode) do 
                if v.node == parent then
                    table.insert(v.node._childNode, {node = child, func = func, expand = expand, value = value})
                    return 
                end
            end
        end
    end

    child:setVisible(false)
end

-- noEffect: if node movement needs action
function QUIDialogXiaoNaNa:UpdateTreeNode(noEffect)
    if not noEffect then
        self._switching = true
    end

    local posY = 0
    local offset = 0
    local activatedY = 0
    local childNode = {func = function () end}
    for _, v in ipairs(self._treeNode) do
        if v.expand then
            childNode = v
            offset = self:ExpandNode(v.node, posY, noEffect)
            for i = 1, #v.node._childNode do
                if v.node._childNode[i].expand then
                    childNode = v.node._childNode[i]
                    break
                end
            end
            activatedY = posY
        else
            offset = self:FoldNode(v.node, posY, noEffect)
        end

        posY = posY - offset
    end
    self._navScrollView:setRect(0, posY - QUIDialogXiaoNaNa.BUTTON_HEIGHT/2, 0, self._navPageWidth)
    self._navScrollView:moveTo(0, -activatedY, true)

    return childNode
end

-- Expand particular node
function QUIDialogXiaoNaNa:ExpandNode(node, posY, noEffect)
    if noEffect then
        node:setPositionY(posY)
        self._switching = false
    else
        local moveTo = CCMoveTo:create(QUIDialogXiaoNaNa.ACTION_DURATION, ccp(node:getPositionX(), posY))
        local array = CCArray:create()
        array:addObject(moveTo)
        array:addObject(CCDelayTime:create(QUIDialogXiaoNaNa.ACTION_DURATION))
        array:addObject(CCCallFunc:create(function ( ... )
            self._switching = false
        end))
        node:runAction(CCSequence:create(array))
    end 
    node:setHighlighted(true)

    -- Show child node
    local offset = 0
    if node._childNode ~= nil then
        for i = 1, #node._childNode do
            local cPosY = posY - node:getContentSize().height/2 - QUIDialogXiaoNaNa.BUTTON_HEIGHT/2
                     - (i - 1) * (QUIDialogXiaoNaNa.BUTTON_HEIGHT + QUIDialogXiaoNaNa.BUTTON_GAP) - 8
            if noEffect then
                node._childNode[i].node:setPositionY(cPosY)
            else
                local moveTo = CCMoveTo:create(QUIDialogXiaoNaNa.ACTION_DURATION, 
                    ccp(node:getPositionX(), cPosY))
                local array = CCArray:create()
                array:addObject(CCCallFunc:create(
                    function()
                        node._childNode[i].node:setVisible(true)
                    end))
                array:addObject(moveTo)
                node._childNode[i].node:runAction(CCSequence:create(array))
            end
            node._childNode[i].node:setHighlighted(false)
            node._childNode[i].node:setEnabled(true)

            if i == 1 then
                node._childNode[i].node:setHighlighted(true)
                node._childNode[i].node:setEnabled(false)
            end
        end
        offset = #node._childNode * (QUIDialogXiaoNaNa.BUTTON_HEIGHT + QUIDialogXiaoNaNa.BUTTON_GAP)
    end

    return offset + node:getContentSize().height
end

-- Fold particular node
function QUIDialogXiaoNaNa:FoldNode(node, posY, noEffect)
    if noEffect then
        node:setPositionY(posY)
        self._switching = false
    else
        local moveTo = CCMoveTo:create(QUIDialogXiaoNaNa.ACTION_DURATION, ccp(node:getPositionX(), posY))
        local array = CCArray:create()
        array:addObject(moveTo)
        array:addObject(CCDelayTime:create(QUIDialogXiaoNaNa.ACTION_DURATION))
        array:addObject(CCCallFunc:create(function ( ... )
            self._switching = false
        end))
        node:runAction(CCSequence:create(array))
    end
    node:setHighlighted(false)

    -- Fold child node
    local offset = 0
    if node._childNode ~= nil then
        for i = 1, #node._childNode do
            if noEffect then
                node._childNode[i].node:setPositionY(posY)
            else
                local moveTo = CCMoveTo:create(QUIDialogXiaoNaNa.ACTION_DURATION, ccp(node:getPositionX(), posY))
                local array = CCArray:create()
                array:addObject(moveTo)
                array:addObject(CCCallFunc:create(
                    function()
                        node._childNode[i].node:setVisible(false)
                    end))
                node._childNode[i].node:runAction(CCSequence:create(array))
            end
            node._childNode[i].node:setHighlighted(false)
        end
    end

    return offset + node:getContentSize().height
end

function QUIDialogXiaoNaNa:updateExpandState( button )
    if self._switching then return end

    for i = 1, #self._treeNode do
        if self._treeNode[i].node == button then
            if next(self._treeNode[i].node._childNode) then
                self._treeNode[i].expand = not self._treeNode[i].expand
                for j = 1, #self._treeNode[i].node._childNode do
                    self._treeNode[i].node._childNode[j].expand = false
                end
                self._treeNode[i].node._childNode[1].expand = true
            else
                self._treeNode[i].expand = true
            end
        else
            self._treeNode[i].expand = false
        end
    end

    local activatedNode = self:UpdateTreeNode()
    activatedNode.func(activatedNode.value)
end

function QUIDialogXiaoNaNa:isExpand( button )
    for i = 1, #self._treeNode do
        if self._treeNode[i].node == button then
            return self._treeNode[i].expand
        end
    end
end

function QUIDialogXiaoNaNa:updateChildNodeState(child)
    for i = 1, #self._treeNode do
        local parent = self._treeNode[i].node
        for j = 1, #parent._childNode do
            if parent._childNode[j].node == child then
                child:setHighlighted(true)
                child:setEnabled(false)
            else
                parent._childNode[j].node:setHighlighted(false)
                parent._childNode[j].node:setEnabled(true)
            end
        end
    end
end

function QUIDialogXiaoNaNa:showContent(content)
    self._scrollView:clear()

    -- local richText = QRichText.new(nil,self._richTextWidthLimit, {lineSpacing = self._richTextLineSpacing})
    local richText = QUIWidgetHelpDescribe.new()
    richText:setInfo({widthLimit = self._pageWidth, defaultColor = ccc3(235, 223, 191), offsetX = 0, defaultSize = 23, lineSpacing = 10}, content)
    self._scrollView:addItemBox(richText)

    self._scrollView:setRect(0, -richText:getContentSize().height, 0, self._pageWidth)

    self._ccbOwner.zanLight:setString(self._zan[tostring(self._currentId)] or "0")
    self._ccbOwner.zan2:setString(self._zan[tostring(self._currentId)] or "0")
    self._ccbOwner.zan:setString(self._zan[tostring(self._currentId)] or "0")

    self._ccbOwner.zanLight:setVisible(self._zaned[tostring(self._currentId)])
    self._ccbOwner.zan:setVisible(self._zaned[tostring(self._currentId)] ~= true)
    if self._zaned[tostring(self._currentId)] == true then
        self._ccbOwner.zanButton:setEnabled(false)
    else
        self._ccbOwner.zanButton:setEnabled(true)
        self._ccbOwner.zanButton:setHighlighted(true)
    end
end

-- Button click callbacks ------------------------------------------------------------
function QUIDialogXiaoNaNa:_childClick(value, eventType)
    if self._isNavMoving == true then return end 
    if e ~= nil then app.sound:playSound("common_switch") end
    self:updateChildNodeState(value.button)

    self._currentId = value.value.id
    self._currentContent = value.value.content_text
    self:showContent(value.value.content_text)
end

function QUIDialogXiaoNaNa:_parentClick(value, eventType)
    if self._isNavMoving == true or tonumber(eventType) ~= CCControlEventTouchUpInside then         
        if self:isExpand(value.button) then
            value.button:setHighlighted(true)
        end
    else    
        if eventType ~= nil then app.sound:playSound("common_switch") end
        self:updateExpandState(value.button)

        if not value.children then
            self._currentId = value.value.id
            self._currentContent = value.value.content_text
            self:showContent(value.value.content_text)
        end
    end
end

function QUIDialogXiaoNaNa:onTriggerZan()
    if not self._zaned[tostring(self._currentId)] then
        app.sound:playSound("common_small")
        self._ccbOwner.zanButton:setHighlighted(true)

        app:getClient():XiaoNaNaDianZang(self._currentId, function (data)
            self._effect = QUIWidgetAnimationPlayer.new()
            self._ccbOwner.effect:addChild(self._effect)
            self._effect:playAnimation("effects/Tips_add.ccbi", function(ccbOwner)
                ccbOwner.content:setString("+1")
            end, function()
                self._effect:disappear()
                self._effect:removeFromParent()
            end)

            self._zaned = {}

            self._zan[data.gameTipsLikeTipsResponse.gameTipsInfo.tips_id] = data.gameTipsLikeTipsResponse.gameTipsInfo.like_count
            for k, v in ipairs(data.gameTipsLikeTipsResponse.like_tips_id or {}) do
                self._zaned[v] = true
            end

            self:showContent(self._currentContent)
        end)
    end
end

-- Gesture reaction -------------------------------------------------------------------------------------------------
-- Respond to touch event
function QUIDialogXiaoNaNa:_onNavScrollViewMoving()
    self._isNavMoving = true
end

function QUIDialogXiaoNaNa:_onNavScrollViewBegan()
    self._isNavMoving = false
end

-- 关闭对话框
function QUIDialogXiaoNaNa:_onTriggerClose(e)
    if e ~= nil then
        app.sound:playSound("common_small")
    end
    self:playEffectOut()
end

function QUIDialogXiaoNaNa:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogXiaoNaNa:onTriggerBackHandler()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogXiaoNaNa:onTriggerHomeHandler()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end


return QUIDialogXiaoNaNa