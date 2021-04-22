-- @Author: zhouxiaoshu
-- @Date:   2019-06-18 11:45:54
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-05-21 16:35:16


local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetSoulSpiritSmallCard = class("QUIWidgetSoulSpiritSmallCard", QUIWidget)

QUIWidgetSoulSpiritSmallCard.EVENT_CLICK_CARD = "EVENT_CLICK_CARD" 

function QUIWidgetSoulSpiritSmallCard:ctor(options)
	local ccbFile = "ccb/Widget_SoulSpirit_tujian_client.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClickCard", callback = handler(self, self._onTriggerClickCard)},
	}
	QUIWidgetSoulSpiritSmallCard.super.ctor(self, ccbFile, callBacks, options)
	
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._size = self._ccbOwner.sp_frame:getContentSize()
    self._ccbOwner.node_no:setVisible(false)
end

function QUIWidgetSoulSpiritSmallCard:resetAll()
    self._ccbOwner.node_no:setVisible(true)
    self._ccbOwner.tf_name:setString("")
    self._ccbOwner.node_star:setVisible(false)
    self._ccbOwner.node_level:setVisible(false)
    self._ccbOwner.node_avatar:removeAllChildren()
end

function QUIWidgetSoulSpiritSmallCard:setCardInfo(soulSpiritId, leftId)
    self:resetAll()

    self._soulSpiritId = soulSpiritId
    self._leftId = leftId
	if self._soulSpiritId == nil then
        self:setSoulSpiritFrame()
        self:setSABC()
		return
	end
    
    self._ccbOwner.node_no:setVisible(false)

	-- add card
	local character = db:getCharacterByID(self._soulSpiritId)
	if character == nil then
        return
    end

    if character.visitingCard then
        local sprite = CCSprite:create(character.visitingCard)
        self._ccbOwner.node_avatar:addChild(sprite)
    end

	-- add star
	local heroGrade = 0
	local heroLevel = 0
	local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritHistoryInfoById(self._soulSpiritId)
	if soulSpiritInfo ~= nil then
		heroGrade = soulSpiritInfo.grade
		heroLevel = soulSpiritInfo.level
	end
    local aptitude = character.aptitude
    self:setStar(heroGrade,aptitude)

	-- set name
	local color = remote.soulSpirit:getColorByCharacherId(self._soulSpiritId)
	local aptitudeColor = string.lower(color)
    self:setSoulSpiritFrame(aptitudeColor)
	self._ccbOwner.tf_name:setString(character.name or "")
    self._ccbOwner.tf_level:setString(heroLevel)
    
    self._isHave = heroLevel > 0
	if self._isHave then
        self._ccbOwner.node_shadow:setVisible(false)
        self._ccbOwner.node_star:setVisible(true)
		--self._ccbOwner.node_level:setVisible(true)

		local fontColor = QIDEA_QUALITY_COLOR[color]
	    self._ccbOwner.tf_name:setColor(fontColor)
	    setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
        makeNodeFromGrayToNormal(self._ccbOwner.node_avatar)
	else
		self._ccbOwner.node_shadow:setVisible(true)

        local fontColor = GAME_COLOR_LIGHT.notactive
        self._ccbOwner.tf_name:setColor(fontColor)
        setShadowByFontColor(self._ccbOwner.tf_name, fontColor)
        makeNodeFromNormalToGray(self._ccbOwner.node_avatar)
	end
    
    self:setSABC()
end

function QUIWidgetSoulSpiritSmallCard:setStar(grade,aptitude)
   local starNum, iconPath = remote.herosUtil:getStarIconByStarNum(grade + 1, false)
    if aptitude == APTITUDE.SS then
        if  grade == 0 then
            iconPath = QResPath("sp_empty_star")
            starNum = 1
        else
            starNum, iconPath = remote.herosUtil:getStarIconByStarNum(grade , false)
        end
    end

    -- local starNum, iconPath = remote.herosUtil:getStarIconByStarNum(grade, false)
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
        self._ccbOwner.node_star:removeAllChildren()
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
        self._ccbOwner.layerG_star_bg:setPositionY(self._ccbOwner.node_star:getPositionY() + 40)
        self._ccbOwner.layerG_star_bg:setContentSize(CCSize(_layerWidth, _layerHeight + 40))
    else
        self._ccbOwner.node_star:setVisible(false)
        self._ccbOwner.layerG_star_bg:setVisible(false)
    end
end

function QUIWidgetSoulSpiritSmallCard:setSABC()
    if self._soulSpiritId then
        local aptitudeInfo = db:getActorSABC(self._soulSpiritId)
        q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
    elseif self._leftId then
        local aptitudeInfo = db:getActorSABC(self._leftId)
        q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
    end
end

function QUIWidgetSoulSpiritSmallCard:setSoulSpiritFrame(color)
    self._ccbOwner["sp_blue"]:setVisible(false)
    self._ccbOwner["sp_purple"]:setVisible(false)
    self._ccbOwner["sp_orange"]:setVisible(false)
    if color and self._ccbOwner["sp_"..color] then
        self._ccbOwner["sp_"..color]:setVisible(true)
    else
        self._ccbOwner["sp_orange"]:setVisible(true)
    end
end

function QUIWidgetSoulSpiritSmallCard:setSoulSpiritCard(path)
    local sprite = CCSprite:create(path)
    if not sprite then
        return
    end
    local size = self._ccbOwner.card_size:getContentSize()
    local ccclippingNode = CCClippingNode:create()
    local layer = CCLayerColor:create(ccc4(0, 0, 0, 0), size.width, size.height)
    layer:setPosition(-size.width/2, -size.height/2)
    ccclippingNode:setAlphaThreshold(1)
    ccclippingNode:setStencil(layer)
    ccclippingNode:addChild(sprite)
    self._ccbOwner.node_avatar:addChild(ccclippingNode)
end

function QUIWidgetSoulSpiritSmallCard:_onTriggerClickCard()
	self:dispatchEvent({name = QUIWidgetSoulSpiritSmallCard.EVENT_CLICK_CARD, soulSpiritId = self._soulSpiritId, isHave = self._isHave})
end

return QUIWidgetSoulSpiritSmallCard