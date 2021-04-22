-- @Author: liaoxianbo
-- @Date:   2019-06-21 10:32:02
-- @Last Modified by:   zhouxiaoshu
-- @Last Modified time: 2019-07-24 16:14:11
local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetBlackRockOverView = class("QUIWidgetBlackRockOverView", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

QUIWidgetBlackRockOverView.EVENT_CLICK = "EVENT_CLICK"
QUIWidgetBlackRockOverView.EVENT_COMPOSE = "EVENT_COMPOSE"
QUIWidgetBlackRockOverView.EVENT_PIECE = "EVENT_PIECE"

function QUIWidgetBlackRockOverView:ctor(options)
    local ccbFile = "ccb/Widget_SoulSpirit_Overview.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
    QUIWidgetBlackRockOverView.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    setShadow5(self._ccbOwner.tf_hero_name)

    self._size = self._ccbOwner.sp_frame:getContentSize()
    self._namePosY = self._ccbOwner.tf_hero_name:getPositionY()

end

function QUIWidgetBlackRockOverView:onEnter()
end

function QUIWidgetBlackRockOverView:onExit()
end

function QUIWidgetBlackRockOverView:resetAll()
    self._ccbOwner.node_exist:setVisible(false)
    self._ccbOwner.node_no_exist:setVisible(false)
    self._ccbOwner.sp_call:setVisible(false)
    self._ccbOwner.sp_red_tips:setVisible(false)
    self._ccbOwner.sp_is_collected:setVisible(false)
    self._ccbOwner.node_mask:setVisible(false)
    self._ccbOwner.node_force:setVisible(false)
    self._ccbOwner.node_level:setVisible(false)
    
    self._ccbOwner.node_star:removeAllChildren()
    self._ccbOwner.node_soulSpirit:removeAllChildren()
    self._ccbOwner.node_avatar:removeAllChildren()
    self._ccbOwner.tf_level:setString("")
    self._ccbOwner.tf_hero_name:setString("")

    self._avatar = nil

end

function QUIWidgetBlackRockOverView:setInfo(info, showForce)
    self:resetAll()

    self._info = info
    self._id = self._info.id
    local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(self._id)
    self._ccbOwner.node_soulSpirit:removeAllChildren()
    self._ccbOwner.node_avatar:removeAllChildren()
    -- sprite:setScale(0.5)
    -- if sprite then
    --     self._ccbOwner.node_soulSpirit:addChild(sprite)
    -- end

   if characterConfig.aptitude ~= APTITUDE.SS then
        local sprite = CCSprite:create(characterConfig.card)
        if sprite then
            self._ccbOwner.node_soulSpirit:addChild(sprite)
        end
    else
        self:setSoulSpiritAvatar()
    end


    local color = remote.soulSpirit:getColorByCharacherId(self._id)
    local fontColor = QIDEA_QUALITY_COLOR[color]
    self._ccbOwner.tf_name:setColor(fontColor)
    self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)

    self._ccbOwner.tf_name:setString(characterConfig.name or "")
    self._ccbOwner.tf_name:setPositionY(self._namePosY)
    self._ccbOwner.sp_battle_bg:setColor(QIDEA_QUALITY_COLOR[color])
    local aptitudeColor = string.lower(color)
    self:setFrame(aptitudeColor)
    self:setSABC()

    if self._info.isCommon then
        self._ccbOwner.sp_call:setVisible(true)
        self._ccbOwner.sp_red_tips:setVisible(true)
    end
    if showForce then
        self._ccbOwner.node_force:setVisible(true)
    end
    if self._info.isHave then
        makeNodeFromGrayToNormal(self._ccbOwner.node_soulSpirit)
        makeNodeFromGrayToNormal(self._ccbOwner.node_bg)

        self._ccbOwner.node_exist:setVisible(true)
        self._ccbOwner.node_level:setVisible(true)
        self._ccbOwner.tf_level:setString(self._info.level)

        local force = self._info.force or 0
        self._ccbOwner.tf_force:setString(force)
        local fontInfo = QStaticDatabase.sharedDatabase():getForceColorByForce(force)
        if fontInfo ~= nil then
            local color = string.split(fontInfo.force_color, ";")
            self._ccbOwner.tf_force:setColor(ccc3(color[1], color[2], color[3]))
        end

        self._ccbOwner.tf_wear_state:setString("")
        self:setStar(self._info.grade)
        self._ccbOwner.node_level:setVisible(false)
        
    else
        if self._avatar then
            self._avatar:pauseAnimation()
        end

        makeNodeFromNormalToGray(self._ccbOwner.node_soulSpirit)
        makeNodeFromNormalToGray(self._ccbOwner.node_bg)

        local fontColor = GAME_COLOR_LIGHT.notactive
        self._ccbOwner.tf_name:setColor(fontColor)
        self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
            
        self._ccbOwner.node_no_exist:setVisible(false)
        self._ccbOwner.node_mask:setVisible(true)    
        
        self:setStar(0)
    end
end

function QUIWidgetBlackRockOverView:setFrame(color)
    self._ccbOwner["sp_purple"]:setVisible(false)
    self._ccbOwner["sp_orange"]:setVisible(false)
    if self._ccbOwner["sp_"..color] then
        self._ccbOwner["sp_"..color]:setVisible(true)
    else
        self._ccbOwner["sp_orange"]:setVisible(true)
    end

    local pathList = QResPath("soulSpirit_big_frame_"..color)
    if pathList then
        local frame = QSpriteFrameByPath(pathList[1])
        if frame then
            self._ccbOwner.sp_frame:setSpriteFrame(frame)
            self._ccbOwner.sp_frame:setContentSize(self._size) 
        end
        local topPath = pathList[2]
        if topPath then
            local spLeft = CCSprite:create(topPath)
            self._ccbOwner.node_top_left:removeAllChildren()
            self._ccbOwner.node_top_left:addChild(spLeft)
            spLeft:setScaleX(1)
            local spRight = CCSprite:create(topPath)
            self._ccbOwner.node_top_right:removeAllChildren()
            self._ccbOwner.node_top_right:addChild(spRight)
            spRight:setScaleX(-1)
        end
    end
end

function QUIWidgetBlackRockOverView:setStar(grade)
    local starNum, iconPath = remote.herosUtil:getStarIconByStarNum(grade + 1, false)
    if starNum == nil then return end
    
    for i = 1, starNum do
        local sprite = CCSprite:create(iconPath)
        if sprite then
            local starStep = sprite:getContentSize().height
            sprite:setScale(0.9)
            sprite:setPositionY(- (i-1) * starStep*0.9)
            self._ccbOwner.node_star:addChild(sprite)
        end
    end
end

function QUIWidgetBlackRockOverView:setSoulSpiritAvatar()
    self._avatar = QUIWidgetActorDisplay.new(self._id)
    self._avatar:setScaleX(-1)
    local size = self._ccbOwner.card_size:getContentSize()
    self._avatar:setPositionY(-80)
    local ccclippingNode = CCClippingNode:create()
    local layer = CCLayerColor:create(ccc4(0, 0, 0, 0), size.width, size.height)
    layer:setPosition(-size.width/2, -size.height/2)
    ccclippingNode:setAlphaThreshold(1)
    ccclippingNode:setStencil(layer)
    ccclippingNode:addChild(self._avatar)
    self._ccbOwner.node_avatar:addChild(ccclippingNode)
end


function QUIWidgetBlackRockOverView:setSABC()
    local aptitudeInfo = db:getActorSABC(self._id)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

function QUIWidgetBlackRockOverView:_onTriggerClick()
    -- if self._info.isHave then
        self:dispatchEvent({name = QUIWidgetBlackRockOverView.EVENT_CLICK, info = self._info})
    -- elseif self._info.isCommon then
    --     self:dispatchEvent({name = QUIWidgetBlackRockOverView.EVENT_COMPOSE, info = self._info})
    -- else
    --     self:dispatchEvent({name = QUIWidgetBlackRockOverView.EVENT_PIECE, info = self._info})
    -- end
end

function QUIWidgetBlackRockOverView:getContentSize()
	local size = self._ccbOwner.node_size:getContentSize()
    return size
end

return QUIWidgetBlackRockOverView
