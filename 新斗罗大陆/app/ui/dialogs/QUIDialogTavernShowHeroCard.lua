-- @Author: xurui
-- @Date:   2017-10-17 14:57:38
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-11 18:51:50
local QUIDialog = import(".QUIDialog")
local QUIDialogTavernShowHeroCard = class("QUIDialogTavernShowHeroCard", QUIDialog)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetHeroInformation = import("..widgets.QUIWidgetHeroInformation")
local QNavigationController = import("...controllers.QNavigationController")
local QUIDialogHeroOverview = import(".QUIDialogHeroOverview")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIViewController = import("..QUIViewController")
local QUIDialogPreview = import("..dialogs.QUIDialogPreview")
local QUIWidgetHeroSkillCell = import("..widgets.QUIWidgetHeroSkillCell")
local QTutorialEvent = import("...tutorial.event.QTutorialEvent")
local QUIWidgetTavernShowHeroAvatar = import("..widgets.QUIWidgetTavernShowHeroAvatar")
local QUIWidget = import("..widgets.QUIWidget")

function QUIDialogTavernShowHeroCard:ctor(options)
	local ccbFile = "ccb/Dialog_hunshizhanshi.ccbi"
    local callBacks = {
    }
    QUIDialogTavernShowHeroCard.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true
    options = options or {}
    CalculateUIBgSize(self._ccbOwner.node_gold_bg, 1280)
    CalculateUIBgSize(self._ccbOwner.node_sliver_bg, 1280)
    CalculateUIBgSize(self._ccbOwner.node_grad, 1280)
    
    CalculateUIBgSize(self._ccbOwner.hero_image1)
    CalculateUIBgSize(self._ccbOwner.hero_image2)

	self._actorId = options.actorId
    self._callback = options.callBack
    self._tavernType = options.tavernType or TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE
    self._isEnd = false

    if self._tavernType == TAVERN_SHOW_HERO_CARD.GOLD_TAVERN_TYPE then
        self._ccbOwner.node_gold_bg:setVisible(true)
        self._ccbOwner.node_sliver_bg:setVisible(false)
    else
        self._ccbOwner.node_gold_bg:setVisible(false)
        self._ccbOwner.node_sliver_bg:setVisible(true)
    end
    self._ccbOwner.click_lable:setVisible(false)  

    self._animationManager = tolua.cast(self._view:getUserObject(), "CCBAnimationManager")
    self._animationManager:connectScriptHandler(handler(self, self.viewAnimationEndHandler))
    self._animationManager:runAnimationsForSequenceNamed("chuxian")

    app.sound:playSound("common_award_hero")

    self:updateHeroPic()
end

function QUIDialogTavernShowHeroCard:viewAnimationEndHandler()
    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QTutorialEvent.EVENT_CALL_HERO_SUCCESS})

    if not self._isEnd then
        self._ccbOwner.click_lable:setVisible(true) 
    end
end

function QUIDialogTavernShowHeroCard:viewDidAppear()
    QUIDialogTavernShowHeroCard.super.viewDidAppear(self)
end

function QUIDialogTavernShowHeroCard:viewWillDisappear()
    QUIDialogTavernShowHeroCard.super.viewWillDisappear(self)
end

function QUIDialogTavernShowHeroCard:updateHeroPic()
    local character = db:getCharacterByID(self._actorId)
    local right_frame = character.right_frame or ""
    local left_frame =  character.left_frame or ""
    if character.chouka_show2 then
        local widget = QUIWidget.new(character.chouka_show2)
        widget:setPosition(-display.ui_width/2, -display.height/2)
        if nil ~= widget._ccbOwner.sp_ad then
            widget._ccbOwner.sp_ad:setVisible(false)
        end
        self._ccbOwner.node_card:addChild(widget)
        app.nociceNode:setVisible(false)

        if right_frame ~="" and left_frame ~="" then
            local spRightFrame = CCSprite:create(right_frame)
            spRightFrame:setAnchorPoint(ccp(0, 0.5))
            spRightFrame:setPositionX( UI_VIEW_MIN_WIDTH * 0.5 - 2)
            self._ccbOwner.node_card:addChild(spRightFrame)

            local spLeftFrame = CCSprite:create(left_frame)
            spLeftFrame:setAnchorPoint(ccp(1, 0.5))
            spLeftFrame:setPositionX( - UI_VIEW_MIN_WIDTH * 0.5)
            self._ccbOwner.node_card:addChild(spLeftFrame)
        end

    end
    if character.chouka_show1 then
        local texure = CCTextureCache:sharedTextureCache():addImage(character.chouka_show1)
        local size = texure:getContentSize()
        local rect = CCRectMake(0, 0, size.width, size.height)
        self._ccbOwner.hero_image1:setDisplayFrame(CCSpriteFrame:createWithTexture(texure, rect))
        self._ccbOwner.hero_image2:setDisplayFrame(CCSpriteFrame:createWithTexture(texure, rect))
    end


    -- if character.chouka_show2 then
    --     self._ccbOwner.hero_card:setTexture(CCTextureCache:sharedTextureCache():addImage(character.chouka_show2))
    -- end
end

function QUIDialogTavernShowHeroCard:_backClickHandler()
    self._isEnd = true
    self._ccbOwner.click_lable:setVisible(false) 
    self._ccbOwner.node_card:setVisible(false)    
    app.nociceNode:setVisible(true)
    local callback = function()
        self:popSelf()
        if self._callback then
            self._callback()
        end
    end
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogTavernShowHeroInfo",
        options={actorId = self._actorId, tavernType = self._tavernType, callback = callback}}, {isPopCurrentDialog = false})
end

return QUIDialogTavernShowHeroCard