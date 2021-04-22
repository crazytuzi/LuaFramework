--
-- Kumo.Wang
-- 魂靈信息
-- 
local QUIWidget = import(".QUIWidget")
local QUIWidgetSoulSpiritDetail = class("QUIWidgetSoulSpiritDetail", QUIWidget)

local QScrollView = import("...views.QScrollView") 
local QUIViewController = import("...ui.QUIViewController")
local QUIWidgetSoulSpiritDetailCell = import(".QUIWidgetSoulSpiritDetailCell")

function QUIWidgetSoulSpiritDetail:ctor(ccbFile,callBacks,options)
    local ccbFile = "ccb/Widget_SoulSpirit_Detail_Client.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerUnwear", callback = handler(self, self._onTriggerUnwear)},
        {ccbCallbackName = "onTriggerWear", callback = handler(self, self._onTriggerWear)},
    }
    QUIWidgetSoulSpiritDetail.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self:setButtonVisible(false)
end

function QUIWidgetSoulSpiritDetail:onEnter()
    self:initScrollView()
end

function QUIWidgetSoulSpiritDetail:onExit()
end

function QUIWidgetSoulSpiritDetail:initScrollView()
    if self._scrollView ~= nil then
        self._scrollView:clear()
        self._scrollView = nil
    end
    
    local itemContentSize = self._ccbOwner.sheet_layout:getContentSize()
    self._scrollView = QScrollView.new(self._ccbOwner.sheet, itemContentSize, {bufferMode = 1, sensitiveDistance = 10})
    self._scrollView:setVerticalBounce(true)
end

function QUIWidgetSoulSpiritDetail:setInfo(id, heroId)
    self:initScrollView()
    
    -- print("QUIWidgetSoulSpiritDetail:setInfo(1)  ", id, heroId)
    if not id and not heroId then
        return
    elseif id and heroId then
        self._id = id
        self._heroId = heroId
    elseif id then
        self._id = id
        local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritInfoById(self._id)
        self._heroId = soulSpiritInfo and soulSpiritInfo.heroId or 0
    elseif heroId then
        self._heroId = heroId
        local heroInfo = remote.herosUtil:getHeroByID(self._heroId)
        local soulSpiritInfo = heroInfo.soulSpirit
        self._id = soulSpiritInfo and soulSpiritInfo.id or 0
    end
    -- print("QUIWidgetSoulSpiritDetail:setInfo(2)  ", id, heroId, self._heroId)
    if self._heroId > 0 then
        self:setButtonVisible(true)
    else
        self:setButtonVisible(false)
    end

    self:showInfo()
end

function QUIWidgetSoulSpiritDetail:showInfo()
    self._scrollView:clear()
        
    if self._client then
        self._client = nil
    end
    if not self._client then
        self._client = QUIWidgetSoulSpiritDetailCell.new()
    end
    self._client:setInfo(self._id)
    self._scrollView:addItemBox(self._client)

    local contentSize = self._client:getContentSize()
    self._client:setPosition(ccp(14, 0))
    self._scrollView:setRect(14, -contentSize.height, 0, contentSize.width)
end

function QUIWidgetSoulSpiritDetail:setButtonVisible(isShow)
    -- print("QUIWidgetSoulSpiritDetail:setButtonVisible(isShow)  ", isShow)
    self._ccbOwner.node_unwear:setVisible(isShow)
    self._ccbOwner.node_wear:setVisible(isShow)
    if isShow then
        self._ccbOwner.sheet_layout:setContentSize(CCSize(564, 415))
    else
        self._ccbOwner.sheet_layout:setContentSize(CCSize(564, 415+80))
    end
    if self._id and self._id > 0 then
        self._ccbOwner.tf_wear_name:setString("替 换")
    else
        self._ccbOwner.tf_wear_name:setString("护 佑")
    end
    self:initScrollView()
end

function QUIWidgetSoulSpiritDetail:_onTriggerWear(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_wear) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSoulSpiritOverView", 
        options = {heroId = self._heroId}})
end

function QUIWidgetSoulSpiritDetail:_onTriggerUnwear(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_unwear) == false then return end
    app.sound:playSound("common_small")
    if self._id and self._id > 0 then
        remote.soulSpirit:soulSpiritEquipRequest(self._heroId, self._id, false)
    else
        app.tip:floatTip("该魂师并没有护佑魂灵")
    end
end

return QUIWidgetSoulSpiritDetail