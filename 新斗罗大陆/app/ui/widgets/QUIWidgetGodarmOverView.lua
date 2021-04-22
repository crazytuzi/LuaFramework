-- @Author: liaoxianbo
-- @Date:   2019-12-23 18:21:40
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-03-05 17:11:27
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetGodarmOverView = class("QUIWidgetGodarmOverView", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QRichText = import("...utils.QRichText")

QUIWidgetGodarmOverView.GODARM_EVENT_CLICK = "GODARM_EVENT_CLICK"
QUIWidgetGodarmOverView.GODARM_EVENT_COMPOSE = "GODARM_EVENT_COMPOSE"
QUIWidgetGodarmOverView.GODARM_EVENT_PIECE = "GODARM_EVENT_PIECE"

function QUIWidgetGodarmOverView:ctor(options)
	local ccbFile = "ccb/Widget_Godarm_Overview.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
    QUIWidgetGodarmOverView.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self._initNodeStarX = self._ccbOwner.node_star:getPositionX()
end

function QUIWidgetGodarmOverView:onEnter()
end

function QUIWidgetGodarmOverView:resetAll()
    self._ccbOwner.node_no_exist:setVisible(false)
    self._ccbOwner.sp_call:setVisible(false)
    self._ccbOwner.sp_red_tips:setVisible(false)
    self._ccbOwner.sp_is_collected:setVisible(false)
    self._ccbOwner.node_mask:setVisible(false)
    self._ccbOwner.node_level:setVisible(false)
    self._ccbOwner.node_effect:setVisible(false)
    
    self._ccbOwner.node_star:removeAllChildren()
    self._ccbOwner.node_avatar:removeAllChildren()
    self._ccbOwner.tf_level:setString("")

    self._avatar = nil
    -- self._ccbOwner.tf_name:setPositionX(self._initNameX)
    self._ccbOwner.node_star:setPositionX(self._initNodeStarX)
end

function QUIWidgetGodarmOverView:setInfo(info)
    self:resetAll()

    self._info = info
    self._godarmId = self._info.godarmId 
    local godarmConfig = db:getCharacterByID(self._godarmId)
    local scale_ = godarmConfig.actor_scale or 1
    if godarmConfig.aptitude == APTITUDE.SS then
        self:setGodarmAvatar(scale_)
        -- self._ccbOwner.node_info:setPositionY(-270)
    else
        local sprite = CCSprite:create(godarmConfig.visitingCard)
        self._ccbOwner.node_avatar:addChild(sprite)
        sprite:setScale(1.25 )
        -- self._ccbOwner.node_info:setPositionY(-265)
    end

    local jobIconPath = remote.godarm:getGodarmJobPath(godarmConfig.label)
    if jobIconPath then
        QSetDisplaySpriteByPath(self._ccbOwner.sp_direction,jobIconPath)
    end    
    
    local color = remote.godarm:getColorByGodarmId(self._godarmId)
    local fontColor = QIDEA_QUALITY_COLOR[color]
    self._ccbOwner.tf_name:setColor(fontColor)
    setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
    
    local level = self._info.level or 0
    local nameStr = godarmConfig.name or ""
    self._ccbOwner.tf_name:setString(nameStr)
    local aptitudeColor = string.lower(color)
    self:setGodarmFrame(aptitudeColor)
    self:setSABC()

    if self._info.isCommon then
        self._ccbOwner.sp_call:setVisible(true)
        self._ccbOwner.sp_red_tips:setVisible(true)
    end

    if self._info.isHave then
        makeNodeFromGrayToNormal(self._ccbOwner.node_avatar)
        makeNodeFromGrayToNormal(self._ccbOwner.node_mount_bg)

        self._ccbOwner.node_level:setVisible(true)

        self._ccbOwner.tf_level:setString(level)

        self:setGodarmStar(self._info.grade)

        local readTips = remote.godarm:isGradeRedTipsById(self._godarmId)
        self._ccbOwner.sp_red_tips:setVisible(readTips)

        if godarmConfig.aptitude == APTITUDE.SS then
            self._ccbOwner.node_effect:setVisible(true)
        end
    else
        if self._avatar then
            self._avatar:pauseAnimation()
        end
        makeNodeFromNormalToGray(self._ccbOwner.node_avatar)
        makeNodeFromNormalToGray(self._ccbOwner.node_mount_bg)

        local fontColor = GAME_COLOR_SHADOW.notactive
        self._ccbOwner.tf_name:setColor(fontColor)
            
        self._ccbOwner.node_no_exist:setVisible(true)
        self._ccbOwner.node_mask:setVisible(true)    
        -- self._ccbOwner.node_info:setPositionY(self._ccbOwner.node_no_exist:getPositionY()) 

        local config = db:getGradeByHeroActorLevel(self._godarmId , 0)
        local haveNum = remote.items:getItemsNumByID(config.soul_gem)
        local scaleX = haveNum/config.soul_gem_count
        self._ccbOwner.tf_progress:setString(haveNum.."/"..config.soul_gem_count)
        if haveNum >= config.soul_gem_count then
            self._ccbOwner.sp_progress:setScaleX(1)
        else
            self._ccbOwner.sp_progress:setScaleX(scaleX)
        end

        if self._itemBox == nil then
            self._itemBox = QUIWidgetItemsBox.new()
            self._ccbOwner.node_item:addChild(self._itemBox)
        end
        self._itemBox:setGoodsInfo(config.soul_gem, ITEM_TYPE.ITEM, 0)
        self._itemBox:hideSabc()

        local isCollected = remote.mount:checkMountHavePast(self._godarmId)
        self._ccbOwner.sp_is_collected:setVisible(isCollected)
        self:setGodarmStar(0)
    end

end

function QUIWidgetGodarmOverView:getGodarmInfo( )
    return self._info
end

function QUIWidgetGodarmOverView:setGodarmAvatar( scale_ )
    self._avatar = QUIWidgetActorDisplay.new(self._godarmId)
    self._avatar:setScaleX(-0.55)
    self._avatar:setScaleY(0.55)


    local size = self._ccbOwner.card_size:getContentSize()
    size.width = size.width *1.25
    size.height = size.height *1.25
    
    local ccclippingNode = CCClippingNode:create()
    local layer = CCLayerColor:create(ccc4(0, 0, 0, 0), size.width, size.height)
    layer:setPosition(-size.width/2, -size.height/2)
    ccclippingNode:setAlphaThreshold(1)
    ccclippingNode:setStencil(layer)
    ccclippingNode:addChild(self._avatar)
    self._ccbOwner.node_avatar:addChild(ccclippingNode)
end

function QUIWidgetGodarmOverView:setGodarmFrame(color)
    self._ccbOwner["sp_blue"]:setVisible(false)
    self._ccbOwner["sp_purple"]:setVisible(false)
    self._ccbOwner["sp_orange"]:setVisible(false)
    self._ccbOwner["sp_red"]:setVisible(false)

    if self._ccbOwner["sp_"..color] then
        self._ccbOwner["sp_"..color]:setVisible(true)
    else
        self._ccbOwner["sp_blue"]:setVisible(true)
    end
end

function QUIWidgetGodarmOverView:setSABC()
    local aptitudeInfo = db:getActorSABC(self._godarmId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

function QUIWidgetGodarmOverView:setGodarmStar(grade)
    local starNum, iconPath = remote.herosUtil:getStarIconByStarNum(grade + 1, false)
    if starNum ~= nil then
        local _scale = 0.85
        local _stepOffset = -5
        local _layerWidth = 0
        local _layerHeight = 0
        local _nodeX = 0
        local _nodeXOffset = 2
        local _widthOffset = 4

        for i = 1, starNum do
            local sprite = CCSprite:create(iconPath)
            if sprite then
                sprite:setAnchorPoint(ccp(0.5, 1))
                local w = sprite:getContentSize().width * _scale
                if w > _layerWidth then
                    _layerWidth = w + _widthOffset
                    _nodeX = _layerWidth/2
                end
                local starStep = sprite:getContentSize().height + _stepOffset
                _layerHeight = (i-1) * starStep * _scale + sprite:getContentSize().height * _scale
                sprite:setScale(_scale)
                sprite:setPositionY(-(i-1) * starStep * _scale)
                self._ccbOwner.node_star:addChild(sprite)
            end
        end
        self._ccbOwner.node_star:setPositionX(_nodeX)
        self._ccbOwner.layerG_star_bg:setPositionX(_nodeX)
        self._ccbOwner.layerG_star_bg:setPositionY(self._ccbOwner.node_star:getPositionY() + 50)
        self._ccbOwner.layerG_star_bg:setContentSize(CCSize(_layerWidth, _layerHeight + 50))
    else
        self._ccbOwner.node_star:setVisible(false)
        self._ccbOwner.layerG_star_bg:setVisible(false)
    end
end

function QUIWidgetGodarmOverView:_onTriggerClick()
    if self._info.isHave then
        self:dispatchEvent({name = QUIWidgetGodarmOverView.GODARM_EVENT_CLICK, info = self._info})
    elseif self._info.isCommon then
        self:dispatchEvent({name = QUIWidgetGodarmOverView.GODARM_EVENT_COMPOSE, info = self._info})
    else
        self:dispatchEvent({name = QUIWidgetGodarmOverView.GODARM_EVENT_PIECE, info = self._info})
        -- self:dispatchEvent({name = QUIWidgetGodarmOverView.GODARM_EVENT_CLICK, info = self._info})
    end
end

function QUIWidgetGodarmOverView:onExit()
end


function QUIWidgetGodarmOverView:getContentSize()
    local size = self._ccbOwner.node_size:getContentSize()
    return size	
end

return QUIWidgetGodarmOverView
