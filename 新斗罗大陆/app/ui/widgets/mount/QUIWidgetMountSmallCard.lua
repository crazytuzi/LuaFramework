
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetMountSmallCard = class("QUIWidgetMountSmallCard", QUIWidget)

QUIWidgetMountSmallCard.EVENT_CLICK_CARD = "EVENT_CLICK_CARD" 

function QUIWidgetMountSmallCard:ctor(options)
	local ccbFile = "ccb/Widget_mount_tujian_client.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClickCard", callback = handler(self, self._onTriggerClickCard)},
	}
	QUIWidgetMountSmallCard.super.ctor(self, ccbFile, callBacks, options)
	
  	cc.GameObject.extend(self)
  	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._size = self._ccbOwner.sp_frame:getContentSize()
    self._ccbOwner.node_no:setVisible(false)
end

function QUIWidgetMountSmallCard:resetAll()
    self._ccbOwner.node_no:setVisible(true)
    self._ccbOwner.tf_mount_name:setString("")
    self._ccbOwner.node_level:setVisible(false)
    for i = 1, 5 do
        self._ccbOwner["star"..i]:setVisible(false)
    end 
end

function QUIWidgetMountSmallCard:setCardInfo(mountId, leftId)
    self:resetAll()

    self._mountId = mountId
    self._leftId = leftId
    
    -- set name
    local color = remote.mount:getColorByMountId(self._leftId)
    local aptitudeColor = string.lower(color)
    self:setMountFrame(aptitudeColor)

	if self._mountId == nil then
        self._ccbOwner.node_mount:removeAllChildren()
        self:setSABC()
		return
	end
    self._ccbOwner.node_no:setVisible(false)

	-- add card
	local heroDisplay = db:getCharacterByID(self._mountId)
	if heroDisplay == nil then return end
    self._ccbOwner.node_mount:removeAllChildren()
    local sprite = CCSprite:create(heroDisplay.visitingCard)
    self._ccbOwner.node_mount:addChild(sprite)

	-- add star
	local heroGrade = heroDisplay.grade
	local heroLevel = 1
	local mountInfo = remote.mount:getMountById(self._mountId)
	if mountInfo ~= nil then
		heroGrade = mountInfo.grade
		heroLevel = mountInfo.enhanceLevel
	end

    local grade = heroGrade + 1
    for i = 1, 5 do
        if i <= grade then
            self._ccbOwner["star"..i]:setVisible(true)
        else
            self._ccbOwner["star"..i]:setVisible(false)
        end
    end

    local fontColor = QIDEA_QUALITY_COLOR[color]
    self._ccbOwner.tf_mount_name:setColor(fontColor)
    self._ccbOwner.tf_mount_name = setShadowByFontColor(self._ccbOwner.tf_mount_name, fontColor)

	self._ccbOwner.tf_mount_name:setString(heroDisplay.name or "")
	self._ccbOwner.tf_mount_level:setString(heroLevel or "")

	-- set active state
	self._isHave = remote.mount:checkMountHavePast(self._mountId)
	if self._isHave then
		self._ccbOwner.node_shadow:setVisible(false)
        makeNodeFromGrayToNormal(self._ccbOwner.node_mount)
        --makeNodeFromGrayToNormal(self._ccbOwner.node_bg)
	else
		self._ccbOwner.node_shadow:setVisible(true)

        local fontColor = GAME_COLOR_LIGHT.notactive
        self._ccbOwner.tf_mount_name:setColor(fontColor)
        self._ccbOwner.tf_mount_name = setShadowByFontColor(self._ccbOwner.tf_mount_name, fontColor)
    
        makeNodeFromNormalToGray(self._ccbOwner.node_mount)
        --makeNodeFromNormalToGray(self._ccbOwner.node_bg)
	end
    
    self:setSABC()
end

function QUIWidgetMountSmallCard:setSABC()
    if self._mountId then
        local aptitudeInfo = db:getActorSABC(self._mountId)
        q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
    elseif self._leftId then
        local aptitudeInfo = db:getActorSABC(self._leftId)
        q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)
    end
end

function QUIWidgetMountSmallCard:setMountFrame(color)
    self._ccbOwner["sp_blue"]:setVisible(false)
    self._ccbOwner["sp_purple"]:setVisible(false)
    self._ccbOwner["sp_orange"]:setVisible(false)
    self._ccbOwner["sp_red"]:setVisible(false)
    if color and self._ccbOwner["sp_"..color] then
        self._ccbOwner["sp_"..color]:setVisible(true)
    else
        self._ccbOwner["sp_orange"]:setVisible(true)
    end
end

function QUIWidgetMountSmallCard:_onTriggerClickCard()
    if self._mountId ~= nil then
	   self:dispatchEvent({name = QUIWidgetMountSmallCard.EVENT_CLICK_CARD, mountId = self._mountId, isHave = self._isHave})
    end
end

return QUIWidgetMountSmallCard