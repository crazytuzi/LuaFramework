


local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMockBattleSoulCardInfo = class("QUIDialogMockBattleSoulCardInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")
local QColorLabel = import("...utils.QColorLabel")
local QRichText = import("...utils.QRichText")
local QUIWidgetSoulSpiritInfoCell = import("..widgets.QUIWidgetSoulSpiritInfoCell")

function QUIDialogMockBattleSoulCardInfo:ctor(options)
	local ccbFile = "ccb/Dialog_MockBattle_SoulCardInfo.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		{ccbCallbackName = "onTriggerGet", callback = handler(self, self._onTriggerGet)},
	}
	QUIDialogMockBattleSoulCardInfo.super.ctor(self, ccbFile, callBacks, options)
	self.isAnimation = true --是否动画显示
	
	self._soulSpiritId = options.soulSpiritId or options.actorId
    self._id = options.id or 0
    self._soulSpiritInfo = remote.mockbattle:getCardInfoByIndex(self._id)

    self:initScrollView()
    self:setHeroInfo()
end

function QUIDialogMockBattleSoulCardInfo:initScrollView()
    local itemContentSize = self._ccbOwner.sheet_layout:getContentSize()

    self._scrollView = QScrollView.new(self._ccbOwner.sheet, itemContentSize, {bufferMode = 1, sensitiveDistance = 10})
    self._scrollView:setVerticalBounce(true)
end

--------------------------- main logic -----------------------------
function QUIDialogMockBattleSoulCardInfo:setHeroInfo()

    local soulSpiritConfig = db:getCharacterByID(self._soulSpiritId)
    --self._soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._soulSpiritId)
    self._ccbOwner.frame_tf_title:setString(soulSpiritConfig.name or "")
    self._ccbOwner.tf_desc:setString("")

    local desc = soulSpiritConfig.brief or ""
	local itemContentSize = self._ccbOwner.desc_sheet_layout:getContentSize()
    local scrollView = QScrollView.new(self._ccbOwner.desc_sheet, itemContentSize, {bufferMode = 0})
    scrollView:setVerticalBounce(true)
	local text = QColorLabel:create(desc, 270, nil, nil, 20, GAME_COLOR_LIGHT.normal)
	text:setAnchorPoint(ccp(0, 1))
	local totalHeight = text:getContentSize().height
	scrollView:addChild(text)
	scrollView:setRect(0, -totalHeight, 0, 0)

    -- hero avatar
    local avatar = QUIWidgetActorDisplay.new(self._soulSpiritId)
    avatar:setPositionY(-100)
    self._ccbOwner.node_avatar:addChild(avatar)
    self._ccbOwner.node_avatar:setScaleX(-1)
    
	-- hero quality
    local aptitudeInfo = db:getActorSABC(self._soulSpiritId)

    local fontColor = UNITY_COLOR_LIGHT[aptitudeInfo.color]
	self._ccbOwner.frame_tf_title:setColor(fontColor)
	setShadowByFontColor(self._ccbOwner.frame_tf_title, fontColor)

	self:setSABC()
    self:showInfo()
end

function QUIDialogMockBattleSoulCardInfo:setSABC()
    local aptitudeInfo = db:getActorSABC(self._soulSpiritId)
    q.setAptitudeShow(self._ccbOwner, aptitudeInfo.lower)

    self._ccbOwner["node_blue"]:setVisible(false)
    self._ccbOwner["node_purple"]:setVisible(false)
    self._ccbOwner["node_orange"]:setVisible(false)
    if aptitudeInfo.lower == "b" then
    	self._ccbOwner["node_blue"]:setVisible(true)
    elseif aptitudeInfo.lower == "a" or aptitudeInfo.lower == "a+" then
    	self._ccbOwner["node_purple"]:setVisible(true)
    elseif aptitudeInfo.lower == "s" or aptitudeInfo.lower == "s+" then
    	self._ccbOwner["node_orange"]:setVisible(true)
    end
end

function QUIDialogMockBattleSoulCardInfo:showInfo()
    self._scrollView:clear()
        
    if self._client then
        self._client:removeFromParent()
        self._client = nil
    end
    if not self._client then
        self._client = QUIWidgetSoulSpiritInfoCell.new()
    end
    self._client:setInfoData(self._soulSpiritId,self._soulSpiritInfo ,true)
    self._scrollView:addItemBox(self._client)

    local contentSize = self._client:getContentSize()
    self._client:setPosition(ccp(0, 0))
    self._scrollView:setRect(0, -contentSize.height, 0, contentSize.width)
end

function QUIDialogMockBattleSoulCardInfo:_onTriggerGet(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_get) == false then return end
	app.sound:playSound("common_common")
	self:playEffectOut()
end

function QUIDialogMockBattleSoulCardInfo:_backClickHandler()
	self:_onTriggerClose()
end 

function QUIDialogMockBattleSoulCardInfo:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogMockBattleSoulCardInfo