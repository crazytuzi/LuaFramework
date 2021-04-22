-- 
-- zxs
-- 暗器单位
-- 

local QUIWidget = import("..QUIWidget")
local QUIWidgetMountOverView = class("QUIWidgetMountOverView", QUIWidget)

local QUIWidgetActorDisplay = import("...widgets.actorDisplay.QUIWidgetActorDisplay")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QRichText = import("....utils.QRichText")

QUIWidgetMountOverView.MOUNT_EVENT_CLICK = "MOUNT_EVENT_CLICK"
QUIWidgetMountOverView.MOUNT_EVENT_COMPOSE = "MOUNT_EVENT_COMPOSE"
QUIWidgetMountOverView.MOUNT_EVENT_PIECE = "MOUNT_EVENT_PIECE"

function QUIWidgetMountOverView:ctor(ccbFile,callBacks,options)
    -- local ccbFile = "ccb/Widget_Weapon_zonglan_01.ccbi"
    local ccbFile = "ccb/Widget_Mount_Overview.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
    }
    QUIWidgetMountOverView.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    -- self._initNameX = self._ccbOwner.tf_name:getPositionX()
    self._initNodeStarX = self._ccbOwner.node_star:getPositionX()
end

function QUIWidgetMountOverView:resetAll()
    self._ccbOwner.node_exist:setVisible(false)
    self._ccbOwner.node_no_exist:setVisible(false)
    self._ccbOwner.sp_call:setVisible(false)
    self._ccbOwner.sp_red_tips:setVisible(false)
    self._ccbOwner.sp_is_collected:setVisible(false)
    self._ccbOwner.node_mask:setVisible(false)
    self._ccbOwner.node_force:setVisible(false)
    self._ccbOwner.node_level:setVisible(false)
    self._ccbOwner.node_mount_box:setVisible(false)
    self._ccbOwner.node_dressing:setVisible(false)
    self._ccbOwner.node_effect:setVisible(false)
    
    self._ccbOwner.node_star:removeAllChildren()
    self._ccbOwner.node_avatar:removeAllChildren()
    self._ccbOwner.tf_level:setString("")

    self._avatar = nil
    -- self._ccbOwner.tf_name:setPositionX(self._initNameX)
    self._ccbOwner.node_star:setPositionX(self._initNodeStarX)
end

function QUIWidgetMountOverView:setInfo(info, showForce)
    self:resetAll()

    self._info = info
    self._mountId = self._info.mountId
    local mountConfig = db:getCharacterByID(self._mountId)
    if mountConfig.aptitude >= APTITUDE.SS then
        self:setMountAvatar(mountConfig.aptitude)
    else
        local sprite = CCSprite:create(mountConfig.visitingCard)
        self._ccbOwner.node_avatar:addChild(sprite)
    end

    local color = remote.mount:getColorByMountId(self._mountId)
    local fontColor = QIDEA_QUALITY_COLOR[color]
    self._ccbOwner.tf_name:setColor(fontColor)
    setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
    
    local reformLevel = self._info.reformLevel or 0
    local nameStr = mountConfig.name or ""
    if reformLevel > 0 then
        nameStr = nameStr.."+"..reformLevel
    end
    self._ccbOwner.tf_name:setString(nameStr)
    local aptitudeColor = string.lower(color)
    self:setMountFrame(aptitudeColor,mountConfig.aptitude)
    self:setSABC()

    if self._info.isCommon then
        self._ccbOwner.sp_call:setVisible(true)
        self._ccbOwner.sp_red_tips:setVisible(true)
    end
    if self._info.isHave then
        makeNodeFromGrayToNormal(self._ccbOwner.node_avatar)
        makeNodeFromGrayToNormal(self._ccbOwner.node_mount_bg)

        self._ccbOwner.node_exist:setVisible(true)
        self._ccbOwner.node_level:setVisible(true)
        if showForce then
            self._ccbOwner.node_force:setVisible(true)
            self._ccbOwner.node_info:setPositionY(self._ccbOwner.node_exist:getPositionY()) 
        else
            self._ccbOwner.node_info:setPositionY(self._ccbOwner.node_exist:getPositionY() - self._ccbOwner.sp_battle_bg:getContentSize().height) 
            -- self._ccbOwner.tf_name:setPositionY(self._namePosY - 30)
        end

        local mountInfo = remote.mount:getMountById(self._mountId)
        self._ccbOwner.tf_level:setString(mountInfo.enhanceLevel)

        -- 不显示战力
        local force = info.force or 0
        self._ccbOwner.tf_force:setString(force)
        local fontInfo = db:getForceColorByForce(force)
        if fontInfo ~= nil then
            local color = string.split(fontInfo.force_color, ";")
            self._ccbOwner.tf_force:setColor(ccc3(color[1], color[2], color[3]))
        end

        self._ccbOwner.node_state:removeAllChildren()
        local infoStr = ""
        -- local posX = self._ccbOwner.tf_hero_name:getPositionX()
        local actorId = mountInfo.actorId or 0
        if self._info.superZuoqiId and self._info.superZuoqiId > 0 then
            local superMountConfig = db:getCharacterByID(self._info.superZuoqiId)
            infoStr = "##w"..(superMountConfig.name or "").."##b(配件中)"
            -- self._ccbOwner.tf_hero_name:setString(superMountConfig.name or "")
            -- self._ccbOwner.tf_wear_state:setString(" (配件中)")
            -- self._ccbOwner.tf_wear_state:setColor(UNITY_COLOR_LIGHT.green)
            -- local sizeX = self._ccbOwner.tf_hero_name:getContentSize().width
            -- self._ccbOwner.tf_wear_state:setPositionX(posX+sizeX)
            self._ccbOwner.node_dressing:setVisible(true)
        elseif actorId ~= 0 then
            local actorInfo = db:getCharacterByID(actorId)
            infoStr = "##w"..(actorInfo.name or "").."##b(装备中)"
            -- self._ccbOwner.tf_hero_name:setString(actorInfo.name or "")
            -- self._ccbOwner.tf_wear_state:setString(" (装备中)")
            -- self._ccbOwner.tf_wear_state:setColor(UNITY_COLOR_LIGHT.green)
            -- local sizeX = self._ccbOwner.tf_hero_name:getContentSize().width
            -- self._ccbOwner.tf_wear_state:setPositionX(posX+sizeX)
            -- local UIHeroModel = remote.herosUtil:getUIHeroByID(actorId)
            -- self._ccbOwner.sp_red_tips:setVisible(UIHeroModel:getMountGradeTip() or UIHeroModel:getMountReformTip())
        else
            infoStr = "##z(未装备)"
            -- self._ccbOwner.tf_wear_state:setString(" (未装备)")
            -- self._ccbOwner.tf_wear_state:setColor(GAME_COLOR_SHADOW.notactive)
            -- self._ccbOwner.tf_wear_state:setPositionX(-100)
        end

        local mountInfo = remote.mount:getMountById(self._mountId)
        local gradeRedtips = false
        if remote.mount:checkMountCanGrade(mountInfo) then
            gradeRedtips = true
        end
        if actorId ~= 0 then
            local UIHeroModel = remote.herosUtil:getUIHeroByID(actorId)
            if  UIHeroModel:getMountReformTip() then
                gradeRedtips = true
            end
        end
        
        if remote.mount:checkCanGrave(self._mountId) then
            gradeRedtips = true
        end

        self._ccbOwner.sp_red_tips:setVisible(gradeRedtips)

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

        self:setHeroStar(mountInfo.grade,mountInfo.aptitude)

        if mountConfig.aptitude == APTITUDE.SS or mountConfig.aptitude == APTITUDE.SSR then
            self._ccbOwner.node_effect:setVisible(true)
            self._ccbOwner.node_mount_box:setVisible(true)
            -- 名字位置調整
            -- local nameWidth = self._ccbOwner.tf_name:getContentSize().width
            -- if nameWidth/2 > self._ccbOwner.node_mount_box:getPositionX() then
            --     self._ccbOwner.tf_name:setPositionX(self._initNameX - (self._ccbOwner.node_mount_box:getPositionX() - nameWidth/2))
            -- end
            self._ccbOwner.sp_mount_lock:setVisible(false)
            if self._info.wearZuoqiInfo then
                self._ccbOwner.sp_mount_plus:setVisible(false)
                local heroDisplay = db:getCharacterByID(self._info.wearZuoqiInfo.zuoqiId)
                if self._mountIcon == nil then
                    self._mountIcon = CCSprite:create()
                    self._ccbOwner.node_mount:addChild(self._mountIcon)
                end
                self._mountIcon:setTexture(CCTextureCache:sharedTextureCache():addImage(heroDisplay.icon))
            else
                if self._mountIcon ~= nil then
                    self._mountIcon:removeFromParent()
                    self._mountIcon = nil
                end
                self._ccbOwner.sp_mount_plus:setVisible(true)
            end
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
        self._ccbOwner.node_info:setPositionY(self._ccbOwner.node_no_exist:getPositionY()) 

        local config = db:getGradeByHeroActorLevel(self._mountId , 0)
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

        local isCollected = remote.mount:checkMountHavePast(self._mountId)
        self._ccbOwner.sp_is_collected:setVisible(isCollected)
        self:setHeroStar(0,mountConfig.aptitude)
    end
end

function QUIWidgetMountOverView:setMountFrame(color,aptitude)
    self._ccbOwner["sp_blue"]:setVisible(false)
    self._ccbOwner["sp_purple"]:setVisible(false)
    self._ccbOwner["sp_orange"]:setVisible(false)
    self._ccbOwner["sp_red"]:setVisible(false)
    self._ccbOwner["sp_ssr_bg"]:setVisible(false)

    -- self._ccbOwner["node_blue"]:setVisible(false)
    -- self._ccbOwner["node_purple"]:setVisible(false)
    -- self._ccbOwner["node_orange"]:setVisible(false)
    -- self._ccbOwner["node_red"]:setVisible(false)
    -- self._ccbOwner["node_gold"]:setVisible(false)

    if aptitude == APTITUDE.SSR then
        self._ccbOwner["sp_ssr_bg"]:setVisible(true)
    else
        if self._ccbOwner["sp_"..color] then
            self._ccbOwner["sp_"..color]:setVisible(true)
        else
            self._ccbOwner["sp_blue"]:setVisible(true)
        end
    end
    -- if self._ccbOwner["node_"..color] then
    --     self._ccbOwner["node_"..color]:setVisible(true)
    -- else
    --     self._ccbOwner["node_blue"]:setVisible(true)
    -- end
end

function QUIWidgetMountOverView:setMountAvatar(aptitude)
    self._avatar = QUIWidgetActorDisplay.new(self._mountId)
    if aptitude == APTITUDE.SSR then
        self._avatar:setScaleX(1)
    else
        self._avatar:setScaleX(-1)
    end
    local size = self._ccbOwner.card_size:getContentSize()
    local ccclippingNode = CCClippingNode:create()
    local layer = CCLayerColor:create(ccc4(0, 0, 0, 0), size.width, size.height)
    layer:setPosition(-size.width/2, -size.height/2)
    ccclippingNode:setAlphaThreshold(1)
    ccclippingNode:setStencil(layer)
    ccclippingNode:addChild(self._avatar)
    self._ccbOwner.node_avatar:addChild(ccclippingNode)
end

function QUIWidgetMountOverView:setHeroStar(grade,aptitude)
    local starNum, iconPath = remote.herosUtil:getStarIconByStarNum(grade + 1, false)
    if aptitude == APTITUDE.SSR then
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
        -- self._ccbOwner.node_star:setPositionX(self._initNodeStarX - _totalWidth / 2)

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

function QUIWidgetMountOverView:setSABC()
    local aptitudeInfo = db:getActorSABC(self._mountId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end

function QUIWidgetMountOverView:_onTriggerClick()
    if self._info.isHave then
        self:dispatchEvent({name = QUIWidgetMountOverView.MOUNT_EVENT_CLICK, info = self._info})
    elseif self._info.isCommon then
        self:dispatchEvent({name = QUIWidgetMountOverView.MOUNT_EVENT_COMPOSE, info = self._info})
    else
        self:dispatchEvent({name = QUIWidgetMountOverView.MOUNT_EVENT_PIECE, info = self._info})
    end
end

function QUIWidgetMountOverView:getContentSize()
    local size = self._ccbOwner.node_size:getContentSize()
    return size
end

return QUIWidgetMountOverView
