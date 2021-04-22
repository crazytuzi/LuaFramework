


local QUIWidget = import("..QUIWidget")
local QUIWidgetMockBattleCard = class("QUIWidgetMockBattleCard", QUIWidget)
local QUIWidgetActorDisplay = import("...widgets.actorDisplay.QUIWidgetActorDisplay")
local QRichText = import("....utils.QRichText")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIWidgetHeroProfessionalIcon = import("..widgets.QUIWidgetHeroProfessionalIcon")
local QUIWidgetHeroHead = import("..widgets.QUIWidgetHeroHead")


QUIWidgetMockBattleCard.EVENT_CLICK_CARD = "EVENT_CLICK_CARD"
QUIWidgetMockBattleCard.EVENT_CLICK_BIND_CARD = "EVENT_CLICK_BIND_CARD"
QUIWidgetMockBattleCard.EVENT_CLICK_HELP = "EVENT_CLICK_HELP"


QUIWidgetMockBattleCard.CARD_TYPE_HERO = 1
QUIWidgetMockBattleCard.CARD_TYPE_MOUNT = 2
QUIWidgetMockBattleCard.CARD_TYPE_SOUL = 3
QUIWidgetMockBattleCard.CARD_TYPE_GODARM = 4



QUIWidgetMockBattleCard.CARD_TYPE_BIND_HERO = 101
QUIWidgetMockBattleCard.CARD_TYPE_BIND_MOUNT = 102
QUIWidgetMockBattleCard.CARD_TYPE_BIND_SOUL = 103
QUIWidgetMockBattleCard.CARD_TYPE_BIND_GODARM = 104

local choose_duration = 11


function QUIWidgetMockBattleCard:ctor(options)
    local ccbFile = "ccb/Widget_MockBattle_Card.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, self._onTriggerClick)},
        {ccbCallbackName = "onTriggerHelp", callback = handler(self, self._onTriggerHelp)},
        {ccbCallbackName = "onTriggerClickBindCell", callback = handler(self, self._onTriggerClickBindCell)},
    }
    QUIWidgetMockBattleCard.super.ctor(self, ccbFile, callBacks, options)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()    
    q.setButtonEnableShadow(self._ccbOwner.btn_help)

    self._initNodeStarX = self._ccbOwner.node_star:getPositionX()
    self._isAction = true
    self._professionalIcon = nil
end

function QUIWidgetMockBattleCard:resetAll()
    self._ccbOwner.node_star:removeAllChildren()
    self._ccbOwner.node_avatar:removeAllChildren()
    self._ccbOwner.node_bind_icon:removeAllChildren()
    self._ccbOwner.node_bindCell:setVisible(false)
    self._ccbOwner.node_talent:setVisible(false)
    self._ccbOwner.node_back:setVisible(false)
    self._ccbOwner.effect_node:setVisible(false)

    self._avatar = nil
    -- self._ccbOwner.tf_name:setPositionX(self._initNameX)
    self._ccbOwner.node_star:setPositionX(self._initNodeStarX)
end

--info = {oType = "hero" ,id = value,grade = data_.grade}
function QUIWidgetMockBattleCard:setInfo(info ,isChosen)

	self:resetAll()
	self._info = info
	--self:showCommonDisplay(info.id)
    local grade = info.grade

	if info.oType == QUIWidgetMockBattleCard.CARD_TYPE_HERO then
		self:showHero(info.id)
	elseif	info.oType == QUIWidgetMockBattleCard.CARD_TYPE_SOUL then
		self:showSoul(info.id)
        local characterConfig = db:getCharacterByID(info.id)
        if characterConfig and characterConfig.aptitude == APTITUDE.SS then
            grade = grade - 1
        end
	elseif	info.oType == QUIWidgetMockBattleCard.CARD_TYPE_MOUNT then
		self:showMount(info.id)
    elseif  info.oType == QUIWidgetMockBattleCard.CARD_TYPE_GODARM  then
        self:showGodArm(info.id)    
	end
	self:showStar(grade)
    self:setSABC(info.id)	
    self:showIcon()        
    local dur = q.flashFrameTransferDur(15)
    self:playCardAppear(dur,0 , isChosen)
end


function QUIWidgetMockBattleCard:showCommonDisplay(id)
    local characterConfig = db:getCharacterByID(id)
    local sprite = CCSprite:create(characterConfig.visitingCard)
    local size = self._ccbOwner.card_size:getContentSize()
    local size_scale = size.width  / sprite:getContentSize().width
    sprite:setScale(size_scale)

    local offsetY = size.height - sprite:getContentSize().height + size.height/2
    sprite:setPositionY(offsetY)
    local ccclippingNode = CCClippingNode:create()
    local layer = CCLayerColor:create(ccc4(100, 0, 0, 0), size.width, size.height)
    layer:setPosition(-size.width/2, -size.height/2)
    self._ccbOwner.node_avatar:addChild(layer)
    ccclippingNode:setAlphaThreshold(1)
    ccclippingNode:setStencil(layer)
    ccclippingNode:addChild(sprite)
    self._ccbOwner.node_avatar:addChild(ccclippingNode)
    local sabcInfo = db:getSABCByQuality(characterConfig.aptitude)
    local color = string.upper(sabcInfo.color)
    local fontColor = QIDEA_QUALITY_COLOR[color]
    self._ccbOwner.tf_name:setColor(fontColor)
    setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
    self._ccbOwner.tf_name:setString(characterConfig.name or "")
    local aptitudeColor = string.lower(color)
    self:setFrame(aptitudeColor)
end


function QUIWidgetMockBattleCard:showHero(id)
    local characterConfig = db:getCharacterByID(id)
    local sprite = CCSprite:create(characterConfig.visitingCard)
    local size = self._ccbOwner.card_size:getContentSize()
    local size_scale = size.width  / sprite:getContentSize().width
    sprite:setScale(size_scale)

    local offsetY = size.height - sprite:getContentSize().height + size.height/2
    sprite:setPositionY(offsetY)
    local ccclippingNode = CCClippingNode:create()
    local layer = CCLayerColor:create(ccc4(100, 0, 0, 0), size.width, size.height)
    layer:setPosition(-size.width/2, -size.height/2)
    self._ccbOwner.node_avatar:addChild(layer)
    ccclippingNode:setAlphaThreshold(1)
    ccclippingNode:setStencil(layer)
    ccclippingNode:addChild(sprite)
    self._ccbOwner.node_avatar:addChild(ccclippingNode)

    self._ccbOwner.node_talent:setVisible(true)
    if self._professionalIcon == nil then 
        self._professionalIcon = QUIWidgetHeroProfessionalIcon.new()
        self._ccbOwner.node_talent:addChild(self._professionalIcon)
    end
    self._professionalIcon:setHero(id,false,1.3)


    local sabcInfo = db:getSABCByQuality(characterConfig.aptitude)
    local color = string.upper(sabcInfo.color)
    local fontColor = QIDEA_QUALITY_COLOR[color]
    self._ccbOwner.tf_name:setColor(fontColor)


    setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
    self._ccbOwner.tf_name:setString(characterConfig.name or "")
    self._ccbOwner.node_talent:setPositionX(self._ccbOwner.tf_name:getPositionX() - self._ccbOwner.tf_name:getContentSize().width * 0.5 - 12)
    local aptitudeColor = string.lower(color)
    self:setFrame(aptitudeColor)
end

function QUIWidgetMockBattleCard:showMount(id)

    local mountConfig = db:getCharacterByID(id)
  	local color = remote.mount:getColorByMountId(id)
    local fontColor = QIDEA_QUALITY_COLOR[color]
    self._ccbOwner.tf_name:setColor(fontColor)
    setShadowByFontColor(self._ccbOwner.tf_name, fontColor)	
    local nameStr = mountConfig.name or ""
    self._ccbOwner.tf_name:setString(nameStr)

	local aptitudeColor = string.lower(color)
    self:setFrame(aptitudeColor)

	local sprite = CCSprite:create(mountConfig.visitingCard or mountConfig.card)
    sprite:setScale(0.8)
	self._ccbOwner.node_avatar:addChild(sprite)

end


function QUIWidgetMockBattleCard:showGodArm(id)

    local godarmConfig = db:getCharacterByID(id)
    local color = remote.godarm:getColorByGodarmId(id)
    local fontColor = QIDEA_QUALITY_COLOR[color]
    self._ccbOwner.tf_name:setColor(fontColor)
    setShadowByFontColor(self._ccbOwner.tf_name, fontColor) 
    local nameStr = godarmConfig.name or ""
    self._ccbOwner.tf_name:setString(nameStr)

    local aptitudeColor = string.lower(color)
    self:setFrame(aptitudeColor)

    local sprite = CCSprite:create(godarmConfig.visitingCard or godarmConfig.card)
    sprite:setScale(0.9)
    self._ccbOwner.node_avatar:addChild(sprite)
end

function QUIWidgetMockBattleCard:getBindCard()
    if not self._info.bind_card_id  then return nil end
    local data_ = remote.mockbattle:getCardInfoByIndex(self._info.bind_card_id)
    local heroHead = QUIWidgetHeroHead.new()
    heroHead:setHeroInfo(data_)
    heroHead:showSabc()
    heroHead:setParam(self._info.bind_card_id)
    heroHead:setScale(0.6)
    return heroHead
end

function QUIWidgetMockBattleCard:showIcon()
    if not self._info.bind_card_id  then 
        return 
    end
    self._ccbOwner.node_bindCell:setVisible(true)
    self._ccbOwner.node_bind_icon:addChild(self:getBindCard())
end


function QUIWidgetMockBattleCard:setIconVisible(isVisible)
    self._ccbOwner.node_bindCell:setVisible(isVisible)

end

function QUIWidgetMockBattleCard:showSoul(id)
    local characterConfig = db:getCharacterByID(id)
  	local sprite = CCSprite:create(characterConfig.visitingCard or characterConfig.card)
    if sprite then
        sprite:setScale(0.8)
        self._ccbOwner.node_avatar:addChild(sprite)
    end
    local color = remote.soulSpirit:getColorByCharacherId(id)
    local fontColor = QIDEA_QUALITY_COLOR[color]
    self._ccbOwner.tf_name:setColor(fontColor)
    setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
    self._ccbOwner.tf_name:setString(characterConfig.name or "")
    local aptitudeColor = string.lower(color)
    self:setFrame(aptitudeColor)

end

function QUIWidgetMockBattleCard:setAvatar(id)
    self._avatar = QUIWidgetActorDisplay.new(id)
    self._avatar:setScaleX(-1)
    local size = self._ccbOwner.card_size:getContentSize()
    local ccclippingNode = CCClippingNode:create()
    local layer = CCLayerColor:create(ccc4(0, 0, 0, 0), size.width, size.height)
    layer:setPosition(-size.width/2, -size.height/2)
    ccclippingNode:setAlphaThreshold(1)
    ccclippingNode:setStencil(layer)
    ccclippingNode:addChild(self._avatar)
    self._ccbOwner.node_avatar:addChild(ccclippingNode)
end

function QUIWidgetMockBattleCard:setFrame(color)
	local color_index = 1
	if color =="green" then
		color_index= 1
	elseif color =="blue" then
		color_index= 2
	elseif color =="purple" then
		color_index= 3
	elseif color =="orange" then
		color_index= 4
	elseif color =="red" then
		color_index= 5
	end
	self._ccbOwner.sp_bg:setDisplayFrame(QSpriteFrameByPath(QResPath("card_bg")[color_index]))
end


function QUIWidgetMockBattleCard:showStar(grade)
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
        --self._ccbOwner.node_star:setPositionX(_nodeX)
        --self._ccbOwner.layerG_star_bg:setPositionX(_nodeX)
        --self._ccbOwner.layerG_star_bg:setPositionY(self._ccbOwner.node_star:getPositionY() + 60)
        self._ccbOwner.layerG_star_bg:setContentSize(CCSize(_layerWidth -10, _layerHeight + 60))
    else
        self._ccbOwner.node_star:setVisible(false)
        self._ccbOwner.layerG_star_bg:setVisible(false)
    end

end


function QUIWidgetMockBattleCard:setSABC(id)
   	local aptitudeInfo =  db:getActorSABC(id)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
end
-----------------------------------------------------


function QUIWidgetMockBattleCard:playCardAppear(dur,delay , isChosen)

    self._isAction =true
    self._ccbOwner.node_front:setScaleY(1)
    self._ccbOwner.node_back:setScaleX(1)
    self._ccbOwner.node_back:setVisible(true)
    self._ccbOwner.node_front:setVisible(false)


    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(dur* 0.5, 0.1,1))
    arr:addObject(CCCallFunc:create(function()
        self._ccbOwner.node_back:setVisible(false)
        self._ccbOwner.node_front:setVisible(true)
        self._ccbOwner.node_front:setScaleX(0.1)

        local flipxIn = CCScaleTo:create(dur* 0.5, 1, 1)
        self._ccbOwner.node_front:stopAllActions()
        self._ccbOwner.node_front:runAction(flipxIn)
    end))

    if isChosen then
        arr:addObject(CCDelayTime:create(dur))
        arr:addObject(CCCallFunc:create(function()
            self:cardBeChosen(true)
        end))
    else
        arr:addObject(CCDelayTime:create(dur))
        arr:addObject(CCCallFunc:create(function()
            self:cardBeChosen(false)
        end))
    end

    self._ccbOwner.node_back:stopAllActions()
    self._ccbOwner.node_back:runAction(CCSequence:create(arr))
end

function QUIWidgetMockBattleCard:playCardDisappear(dur,delay)

    self._isAction =true
    self._ccbOwner.node_front:setScaleY(1)

    self._ccbOwner.node_front:setScaleX(1)
    self._ccbOwner.node_front:setVisible(true)
    self._ccbOwner.node_back:setVisible(false)

    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(dur * 0.5, 0.1,1))
    arr:addObject(CCCallFunc:create(function()
        self._ccbOwner.node_front:setVisible(false)
        self._ccbOwner.node_back:setVisible(true)
        self._ccbOwner.node_back:setScaleX(0.1)

        local flipxIn = CCScaleTo:create(dur* 0.5, 1, 1)
        self._ccbOwner.node_back:stopAllActions()
        self._ccbOwner.node_back:runAction(flipxIn)
    end))
    self._ccbOwner.node_front:stopAllActions()
    self._ccbOwner.node_front:runAction(CCSequence:create(arr))

end


function QUIWidgetMockBattleCard:playCardDisappearHalf(dur,delay)
    self._isAction = true
    self._ccbOwner.node_front:setScaleY(1)
    self._ccbOwner.node_front:setScaleX(0)
    self._ccbOwner.node_back:setScaleX(0)
    self._ccbOwner.node_back:setScaleY(1)
    self._ccbOwner.node_back:setVisible(false)
    makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_front ,0.1,255)
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(dur * 0.5))
    arr:addObject(CCCallFunc:create(function()
        self._ccbOwner.node_front:setVisible(false)
        self._ccbOwner.node_back:setVisible(true)
        local arr1 = CCArray:create()
        arr1:addObject(CCScaleTo:create(dur * 0.5, 1,1))
        arr1:addObject(CCCallFunc:create(function()
            self._isAction = false
        end))
        self._ccbOwner.node_back:runAction(CCSequence:create(arr1))
    end))

    self._ccbOwner.node_front:stopAllActions()
    self._ccbOwner.node_front:runAction(CCSequence:create(arr))
end


function QUIWidgetMockBattleCard:cardMoveLonger()
    self._isAction =true
    local dur = q.flashFrameTransferDur(5)
    local dur2 = q.flashFrameTransferDur(6)
    makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_front ,dur , 0)
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(dur))
    arr:addObject(CCCallFunc:create(function()
        makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_front ,dur2, 255  )
        makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_black_bg ,dur2, 255 )
    end))
    arr:addObject(CCDelayTime:create(dur2))
    arr:addObject(CCCallFunc:create(function()
        self._isAction = false
    end))
    self._ccbOwner.node_back:runAction(CCSequence:create(arr))

end


function QUIWidgetMockBattleCard:cardBeChosen(chooseOrNot)

    self._isAction =true

    local dur = q.flashFrameTransferDur(11)

    local alpha_value = 255 
    local scale = 1
    if chooseOrNot then
        alpha_value = 0
        scale = 1.15
    end
    makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_black_bg ,dur , alpha_value)
    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(dur, scale))
    arr:addObject(CCCallFunc:create(function()
        self._isAction = false
    end)) 
    self._ccbOwner.node_front:runAction(CCSequence:create(arr))

    self._ccbOwner.effect_node:setVisible(false)
    if chooseOrNot then
        local dur1 = q.flashFrameTransferDur(9)
        local arr = CCArray:create()
        arr:addObject(CCDelayTime:create(dur1))
        arr:addObject(CCCallFunc:create(function()
            self._ccbOwner.effect_node:setOpacity(0)
            self._ccbOwner.effect_node:setVisible(true)
            local dur2 = q.flashFrameTransferDur(3)
            makeNodeFadeToByTimeAndOpacity(self._ccbOwner.effect_node ,dur2, 255)
        end))
        self._ccbOwner.effect_node:runAction(CCSequence:create(arr))
    end

end


function QUIWidgetMockBattleCard:cardFlyAction()
    self._isAction =true
    local dur = q.flashFrameTransferDur(5)
    local dur2 = q.flashFrameTransferDur(12)
    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(dur, 1.3))
    arr:addObject(CCCallFunc:create(function()
        makeNodeFadeToByTimeAndOpacity(self._ccbOwner.node_front ,dur2,0)
    end))
    self._ccbOwner.node_front:runAction(CCSequence:create(arr))
end
------------------------------------------------------

function QUIWidgetMockBattleCard:_onTriggerClick()
    if self._isAction then return end
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetMockBattleCard.EVENT_CLICK_CARD, info = self._info})
end

function QUIWidgetMockBattleCard:_onTriggerClickBindCell()
    if self._isAction then return end
    QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetMockBattleCard.EVENT_CLICK_BIND_CARD, info = self._info})
end

function QUIWidgetMockBattleCard:_onTriggerHelp()
    if self._isAction then return end
	QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QUIWidgetMockBattleCard.EVENT_CLICK_HELP, info = self._info})
end


function QUIWidgetMockBattleCard:getContentSize()
    local size = self._ccbOwner.card_size:getContentSize()
    return size
end


return QUIWidgetMockBattleCard