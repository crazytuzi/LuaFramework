--
-- Kumo
-- 图鉴全屏卡展示
--

local QUIDialog = import(".QUIDialog")
local QUIDialogHandBookHeroImageCard = class("QUIDialogHandBookHeroImageCard", QUIDialog)

local QUIWidget = import("..widgets.QUIWidget")

function QUIDialogHandBookHeroImageCard:ctor(options)
    local ccbFile = "ccb/Dialog_hero_card.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerRight", callback = handler(self, self._onTriggereRight)},
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, self._onTriggereLeft)},
    }
	QUIDialogHandBookHeroImageCard.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    if options then
    	self._actorId = options.actorId
        self._herosID = options.herosID
        self._pos = options.pos
        self._callback = options.callback
        self._skinId = options.skinId
        self._disableOutEffect = options.disableOutEffect
    end

    -- if self._herosID and #self._herosID > 0 then
    --     self._ccbOwner.node_btn:setVisible(true)
    -- else
        self._ccbOwner.node_btn:setVisible(false)
    -- end
end

function QUIDialogHandBookHeroImageCard:_onTriggereRight()
    -- app.sound:playSound("common_change")
    -- local n = table.nums(self._herosID)
    -- if nil ~= self._pos and n > 1 then
    --     self._pos = self._pos + 1
    --     if self._pos > n then
    --         self._pos = 1
    --     end
    --     local options = self:getOptions()
    --     options.pos = self._pos
    --     self._actorId = self._herosID[self._pos]
    --     self:setHeroCard()
    -- end
end

function QUIDialogHandBookHeroImageCard:_onTriggereLeft()
    -- app.sound:playSound("common_change")
    -- local n = table.nums(self._herosID)
    -- if nil ~= self._pos and n > 1 then
    --     self._pos = self._pos - 1
    --     if self._pos < 1 then
    --         self._pos = n
    --     end
    --     local options = self:getOptions()
    --     options.pos = self._pos
    --     self._actorId = self._herosID[self._pos]
    --     self:setHeroCard()
    -- end
end

function QUIDialogHandBookHeroImageCard:viewDidAppear()
    QUIDialogHandBookHeroImageCard.super.viewDidAppear(self)

    self:setHeroCard()
end

function QUIDialogHandBookHeroImageCard:viewWillDisAppear()
    QUIDialogHandBookHeroImageCard.super.viewWillDisAppear(self)
end

function QUIDialogHandBookHeroImageCard:setHeroCard()
    local characherConfig = remote.handBook:getHeroInfoByActorID(self._actorId)
    local heroInfo = remote.herosUtil:getHeroByID(self._actorId)
    local ccbPath = ""
    local right_frame = ""
    local left_frame = ""  
    if self._skinId and self._skinId > 0 then
        local skinConfig = remote.heroSkin:getHeroSkinBySkinId(self._actorId, self._skinId)
        -- QPrintTable(skinConfig)
        if skinConfig.skins_ccb then
            ccbPath = skinConfig.skins_ccb
        end
        right_frame = skinConfig.right_frame or ""
        left_frame = skinConfig.left_frame or ""

    end
    if ccbPath == "" and characherConfig.chouka_show2 then
        ccbPath = characherConfig.chouka_show2
        right_frame = characherConfig.right_frame or ""
        left_frame = characherConfig.left_frame or ""
    end

    -- print("ccbPath = ", ccbPath)
    if ccbPath ~= "" then
        self._ccbOwner.node_hero_card:removeAllChildren()
        local widget = QUIWidget.new(ccbPath)
        widget:setPosition(-display.ui_width/2, -display.ui_height/2)
        if nil ~= widget._ccbOwner.sp_ad then
            widget._ccbOwner.sp_ad:setVisible(false)
        end
        self._ccbOwner.node_hero_card:addChild(widget)
        --CalculateUIBgSize(self._ccbOwner.node_hero_card, 1280)
    end

    if right_frame ~="" and left_frame ~="" then
        local spRightFrame = CCSprite:create(right_frame)
        spRightFrame:setAnchorPoint(ccp(0, 0.5))
        spRightFrame:setPositionX( UI_VIEW_MIN_WIDTH * 0.5 - 2)
        self._ccbOwner.node_hero_card:addChild(spRightFrame)

        local spLeftFrame = CCSprite:create(left_frame)
        spLeftFrame:setAnchorPoint(ccp(1, 0.5))
        spLeftFrame:setPositionX( - UI_VIEW_MIN_WIDTH * 0.5)
        self._ccbOwner.node_hero_card:addChild(spLeftFrame)
    end    
end

function QUIDialogHandBookHeroImageCard:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogHandBookHeroImageCard:_onTriggerClose()
  	app.sound:playSound("common_close")

    if self._disableOutEffect then
        self:viewAnimationOutHandler()
    else
	    self:playEffectOut()
    end
end

function QUIDialogHandBookHeroImageCard:viewAnimationOutHandler()
    self:popSelf()
    if self._callback then
        self._callback()
    end
end

return QUIDialogHandBookHeroImageCard