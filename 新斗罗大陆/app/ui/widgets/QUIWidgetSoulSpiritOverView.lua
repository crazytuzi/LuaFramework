-- 
-- Kumo.Wang
-- 魂灵主界面cell
-- 

local QUIWidget = import(".QUIWidget")
local QUIWidgetSoulSpiritOverView = class("QUIWidgetSoulSpiritOverView", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QRichText = import("...utils.QRichText")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")

QUIWidgetSoulSpiritOverView.EVENT_CLICK = "QUIWIDGETSOULSPIRITOVERVIEW.EVENT_CLICK"
QUIWidgetSoulSpiritOverView.EVENT_COMPOSE = "QUIWIDGETSOULSPIRITOVERVIEW.EVENT_COMPOSE"
QUIWidgetSoulSpiritOverView.EVENT_PIECE = "QUIWIDGETSOULSPIRITOVERVIEW.EVENT_PIECE"

function QUIWidgetSoulSpiritOverView:ctor(options)
    local ccbFile = "ccb/Widget_SoulSpirit_Overview.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
    QUIWidgetSoulSpiritOverView.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    -- self._size = self._ccbOwner.sp_frame:getContentSize()
    -- self._namePosY = self._ccbOwner.tf_name:getPositionY()
end

function QUIWidgetSoulSpiritOverView:onEnter()
end

function QUIWidgetSoulSpiritOverView:onExit()
end

function QUIWidgetSoulSpiritOverView:resetAll()
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
    self._ccbOwner.node_item:removeAllChildren()
    self._ccbOwner.tf_level:setString("")

    self._avatar = nil
end

function QUIWidgetSoulSpiritOverView:setInfo(info, showForce)
    self:resetAll()

    self._info = info
    self._id = self._info.id
    local characterConfig = QStaticDatabase.sharedDatabase():getCharacterByID(self._id)
    
    self._ccbOwner.node_soulSpirit:removeAllChildren()
    self._ccbOwner.node_avatar:removeAllChildren()

    if characterConfig.aptitude ~= APTITUDE.SS then
        local sprite = CCSprite:create(characterConfig.visitingCard or characterConfig.card)
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
    local nameStr  = characterConfig.name or ""
    if self._info.awaken_level and self._info.awaken_level > 0 then
        nameStr = nameStr.."+"..self._info.awaken_level
    end
    self._ccbOwner.tf_name:setString(nameStr)
    -- self._ccbOwner.tf_name:setPositionY(self._namePosY)
    self._ccbOwner.sp_battle_bg:setColor(QIDEA_QUALITY_COLOR[color])
    local aptitudeColor = string.lower(color)
    self:setFrame(aptitudeColor)
    self:setSABC()

    if self._info.isCommon then
        self._ccbOwner.sp_call:setVisible(true)
        self._ccbOwner.sp_red_tips:setVisible(true)
    end


    if not self._info.isSelect and
        (remote.soulSpirit:isGradeRedTipsById(self._id) or 
           remote.soulSpirit:isAwakenRedTipsById(self._id) or 
           remote.soulSpirit:isInheritRedTipsById(self._id) ) then
        self._ccbOwner.sp_red_tips:setVisible(true)
    end
            
    -- if showForce then
    --     self._ccbOwner.node_force:setVisible(true)
    -- else
    --     -- self._ccbOwner.tf_name:setPositionY(self._namePosY - 30)
    -- end
    if self._info.isHave then
        makeNodeFromGrayToNormal(self._ccbOwner.node_soulSpirit)
        makeNodeFromGrayToNormal(self._ccbOwner.node_bg)

        self._ccbOwner.node_exist:setVisible(true)
        self._ccbOwner.node_level:setVisible(true)
        if showForce then
            self._ccbOwner.node_force:setVisible(true)
            self._ccbOwner.node_info:setPositionY(self._ccbOwner.node_exist:getPositionY()) 
        else
            self._ccbOwner.node_info:setPositionY(self._ccbOwner.node_exist:getPositionY() - self._ccbOwner.sp_battle_bg:getContentSize().height) 
            -- self._ccbOwner.tf_name:setPositionY(self._namePosY - 30)
        end

        self._ccbOwner.tf_level:setString(self._info.level)

        local force = self._info.force or 0
        local num,unit = q.convertLargerNumber(force)
        self._ccbOwner.tf_force:setString(num..unit)
        
        local fontInfo = QStaticDatabase.sharedDatabase():getForceColorByForce(force)
        if fontInfo ~= nil then
            local color = string.split(fontInfo.force_color, ";")
            self._ccbOwner.tf_force:setColor(ccc3(color[1], color[2], color[3]))
        end

        self._ccbOwner.node_state:removeAllChildren()
        local infoStr = ""
        -- local posX = self._ccbOwner.tf_hero_name:getPositionX()
        local heroId = self._info.heroId or 0
        if heroId ~= 0 then
            local actorInfo = QStaticDatabase.sharedDatabase():getCharacterByID(heroId)
            -- self._ccbOwner.tf_hero_name:setString(actorInfo.name or "")
            infoStr = "##w"..(actorInfo.name or "").."##b(护佑中)"
            -- self._ccbOwner.tf_wear_state:setString(" (护佑中)")
            -- self._ccbOwner.tf_wear_state:setColor(COLORS.B)
            -- local sizeX = self._ccbOwner.tf_hero_name:getContentSize().width
            -- self._ccbOwner.tf_wear_state:setPositionX(posX + sizeX)
        else
            infoStr = "##z(空闲中)"
            -- self._ccbOwner.tf_wear_state:setString(" (空闲中)")
            -- self._ccbOwner.tf_wear_state:setColor(COLORS.f)
            -- self._ccbOwner.tf_wear_state:setPositionX(posX)
        end
        local infoRichText = QRichText.new(infoStr, nil, {defaultColor = COLORS.b, defaultSize = 18, stringType = 1})
        infoRichText:setAnchorPoint(ccp(0.5, 0))
        infoRichText:setPositionY(6)
        local width = infoRichText:getContentSize().width
        local richTextMaxWidth = self._ccbOwner.card_size:getContentSize().width
        -- print("richText width : ", width)
        if width > richTextMaxWidth then
            self._ccbOwner.node_state:setScale(richTextMaxWidth/width)
        else
            self._ccbOwner.node_state:setScale(1)
        end
        self._ccbOwner.node_state:addChild(infoRichText)
        infoRichText:setVisible(true)
        self:setStar(self._info.grade , characterConfig.aptitude)
    else

        if self._avatar then
            self._avatar:pauseAnimation()
        end

        makeNodeFromNormalToGray(self._ccbOwner.node_soulSpirit)
        makeNodeFromNormalToGray(self._ccbOwner.node_bg)

        local fontColor = GAME_COLOR_LIGHT.notactive
        self._ccbOwner.tf_name:setColor(fontColor)
        -- self._ccbOwner.tf_name = setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
            
        self._ccbOwner.node_no_exist:setVisible(true)
        self._ccbOwner.node_mask:setVisible(true)   
        self._ccbOwner.node_info:setPositionY(self._ccbOwner.node_no_exist:getPositionY()) 
        
        local gradeConfig = QStaticDatabase.sharedDatabase():getGradeByHeroActorLevel(self._id, 0)
        if gradeConfig then
            local haveNum = remote.items:getItemsNumByID(gradeConfig.soul_gem)
            local scaleX = haveNum / gradeConfig.soul_gem_count
            self._ccbOwner.tf_progress:setString(haveNum.."/"..gradeConfig.soul_gem_count)
            if haveNum >= gradeConfig.soul_gem_count then
                self._ccbOwner.sp_progress_bar:setScaleX(1)
            else
                self._ccbOwner.sp_progress_bar:setScaleX(scaleX)
            end
            local itemBox = QUIWidgetItemsBox.new()
            self._ccbOwner.node_item:addChild(itemBox)
            itemBox:hideSabc()
            itemBox:setGoodsInfo(gradeConfig.soul_gem, ITEM_TYPE.ITEM, 0)
        else
            self._ccbOwner.tf_progress:setString("--/--")
            self._ccbOwner.sp_progress_bar:setScaleX(0)
        end

        -- local isCollected = remote.mount:checkMountHavePast(self._id)
        local historySoulInfo = remote.soulSpirit:getMySoulSpiritHistoryInfoById(self._id)
        if q.isEmpty(historySoulInfo) then
            self._ccbOwner.sp_is_collected:setVisible(false)
        else
            self._ccbOwner.sp_is_collected:setVisible(historySoulInfo.level>0 or historySoulInfo.grade > 0)
        end
        self:setStar(0 , characterConfig.aptitude)
    end
end


function QUIWidgetSoulSpiritOverView:setSoulSpiritAvatar()
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


function QUIWidgetSoulSpiritOverView:setFrame(color)
    self._ccbOwner["sp_purple"]:setVisible(false)
    self._ccbOwner["sp_orange"]:setVisible(false)
    self._ccbOwner["sp_red"]:setVisible(false)
    if self._ccbOwner["sp_"..color] then
        self._ccbOwner["sp_"..color]:setVisible(true)
    else
        self._ccbOwner["sp_orange"]:setVisible(true)
    end

    -- local pathList = QResPath("soulSpirit_big_frame_"..color)
    -- if pathList then
    --     local frame = QSpriteFrameByPath(pathList[1])
    --     if frame then
    --         self._ccbOwner.sp_frame:setSpriteFrame(frame)
    --         self._ccbOwner.sp_frame:setContentSize(self._size) 
    --     end
    --     local topPath = pathList[2]
    --     if topPath then
    --         local spLeft = CCSprite:create(topPath)
    --         self._ccbOwner.node_top_left:removeAllChildren()
    --         self._ccbOwner.node_top_left:addChild(spLeft)
    --         spLeft:setScaleX(1)
    --         local spRight = CCSprite:create(topPath)
    --         self._ccbOwner.node_top_right:removeAllChildren()
    --         self._ccbOwner.node_top_right:addChild(spRight)
    --         spRight:setScaleX(-1)
    --     end
    -- end
end

-- function QUIWidgetSoulSpiritOverView:setCard(path)
--     local sprite = CCSprite:create(path)
--     if not sprite then
--         return
--     end
--     local size = self._ccbOwner.card_size:getContentSize()
--     local ccclippingNode = CCClippingNode:create()
--     local layer = CCLayerColor:create(ccc4(0, 0, 0, 0), size.width, size.height)
--     layer:setPosition(-size.width/2, -size.height/2)
--     ccclippingNode:setAlphaThreshold(1)
--     ccclippingNode:setStencil(layer)
--     ccclippingNode:addChild(sprite)
--     self._ccbOwner.node_soulSpirit:addChild(ccclippingNode)
-- end

function QUIWidgetSoulSpiritOverView:setStar(grade , aptitude)
    local starNum, iconPath = remote.herosUtil:getStarIconByStarNum(grade + 1, false)
    if aptitude == APTITUDE.SS then
        if  grade == 0 then
            iconPath = QResPath("sp_empty_star")
        else
            starNum, iconPath = remote.herosUtil:getStarIconByStarNum(grade , false)
        end
    end


    if starNum ~= nil then
        local _scale = 0.85
        local _stepOffset = -5
        local _layerWidth = 0
        local _layerHeight = 0
        local _nodeX = 0
        local _nodeXOffset = 2
        local _widthOffset = 4
        -- 橫版，目前不用
        -- local _totalWidth = 0
        -- for i = 1, starNum do
        --     local sprite = CCSprite:create(iconPath)
        --     sprite:setAnchorPoint(ccp(0, 0))
        --     if sprite then
        --         local starStep = sprite:getContentSize().width
        --         sprite:setScale(_scale)
        --         -- sprite:setPositionX(- (i-1) * starStep * _scale)
        --         sprite:setPositionX((i-1) * starStep * _scale)
        --         _totalWidth = _totalWidth + starStep * _scale
        --         self._ccbOwner.node_star:addChild(sprite)
        --     end
        -- end
        -- self._ccbOwner.node_star:setPositionX(self._ccbOwner.node_star:getPositionX() - _totalWidth / 2)

        -- 豎版
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

function QUIWidgetSoulSpiritOverView:setSABC()
    local aptitudeInfo = db:getActorSABC(self._id)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

function QUIWidgetSoulSpiritOverView:_onTriggerClick()
    if self._info.isHave then
        self:dispatchEvent({name = QUIWidgetSoulSpiritOverView.EVENT_CLICK, info = self._info})
    elseif self._info.isCommon then
        self:dispatchEvent({name = QUIWidgetSoulSpiritOverView.EVENT_COMPOSE, info = self._info})
    else
        self:dispatchEvent({name = QUIWidgetSoulSpiritOverView.EVENT_PIECE, info = self._info})
    end
end

function QUIWidgetSoulSpiritOverView:getSoulSpiritInfo()
    return self._info
end

function QUIWidgetSoulSpiritOverView:getContentSize()
    local size = self._ccbOwner.node_size:getContentSize()
    return size
end

return QUIWidgetSoulSpiritOverView
