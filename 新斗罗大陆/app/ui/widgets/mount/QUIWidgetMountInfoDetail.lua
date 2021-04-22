--
-- zxs
-- 暗器信息
-- 
local QUIWidget = import("..QUIWidget")
local QUIWidgetMountInfoDetail = class("QUIWidgetMountInfoDetail", QUIWidget)

local QScrollView = import("....views.QScrollView") 
local QUIViewController = import("....ui.QUIViewController")
local QUIWidgetMountInfoDetailClient = import(".QUIWidgetMountInfoDetailClient")

function QUIWidgetMountInfoDetail:ctor(ccbFile,callBacks,options)
    local ccbFile = "ccb/Widget_Weapon_xinxi_04.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerUnwear", callback = handler(self, self._onTriggerUnwear)},
        {ccbCallbackName = "onTriggerWear", callback = handler(self, self._onTriggerWear)},
    }
    QUIWidgetMountInfoDetail.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self:setButtonVisible(false)
end

function QUIWidgetMountInfoDetail:onEnter()
    self:initScrollView()
end

function QUIWidgetMountInfoDetail:onExit()
end

function QUIWidgetMountInfoDetail:initScrollView()
    if not self._scrollView then
        local itemContentSize = self._ccbOwner.sheet_layout:getContentSize()
        self._scrollView = QScrollView.new(self._ccbOwner.sheet, itemContentSize, {bufferMode = 1, sensitiveDistance = 10})
        self._scrollView:setVerticalBounce(true)
    end
end

function QUIWidgetMountInfoDetail:setInfo(actorId, showSSMountEffect)
    self:initScrollView()

    self._actorId = actorId
    local heroInfo = remote.herosUtil:getHeroByID(actorId)
    local mountId = heroInfo.zuoqi.zuoqiId
    self:setMountId(mountId, showSSMountEffect)
end

function QUIWidgetMountInfoDetail:setMountId(mountId, showSSMountEffect)
    self._showSSMountEffect = showSSMountEffect
    self._mountId = mountId
    self._scrollView:clear()

    local client = QUIWidgetMountInfoDetailClient.new()
    client:setInfo(mountId, self._showSSMountEffect)
    self._scrollView:addItemBox(client)

    local contentSize = client:getContentSize()
    client:setPosition(ccp(0, 0))
    self._scrollView:setRect(0, -contentSize.height, 0, contentSize.width)

    local mountInfo = remote.mount:getMountById(self._mountId)
    local superZuoqiId = mountInfo.superZuoqiId or 0
    if superZuoqiId ~= 0 then
        self:setButtonVisible(true)
    else
        self:setButtonVisible(false)
    end
end

function QUIWidgetMountInfoDetail:setButtonVisible(isShow)
    self._ccbOwner.node_unwear:setVisible(isShow)
    self._ccbOwner.node_wear:setVisible(isShow)
end

function QUIWidgetMountInfoDetail:_onTriggerWear(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_wear) == false then return end
    app.sound:playSound("common_small")

    local mountInfo = remote.mount:getMountById(self._mountId)
    local superZuoqiId = mountInfo.superZuoqiId or 0
    if superZuoqiId ~= 0 then
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountOverView", 
            options = {mountId = superZuoqiId, callback = function()

            end}})
    else
        app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountOverView", 
            options = {actorId = self._actorId, isSelect = true}})
    end
end

function QUIWidgetMountInfoDetail:_onTriggerUnwear(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_unwear) == false then return end
    app.sound:playSound("common_small")


    local mountInfo = remote.mount:getMountById(self._mountId)
    local superZuoqiId = mountInfo.superZuoqiId or 0
    if superZuoqiId ~= 0 then
        local mountId = mountInfo.zuoqiId
        remote.mount:superMountWearRequest(nil, superZuoqiId, false, function ()
            remote.mount:dispatchEvent({name = remote.mount.EVENT_UNWEAR_MOUNT, mountId = mountId, isDressView = self._isDressView})
        end)
    elseif mountInfo ~= nil then
        if not self._actorId then
            return
        end
        remote.mount:mountTakeOffRequest(self._actorId, function ()
            remote.mount:dispatchEvent({name = remote.mount.EVENT_UNWEAR, mountId = mountInfo.zuoqiId})
            remote.mount:dispatchEvent({name = remote.mount.EVENT_REFRESH_FORCE})
        end)
    end
end

return QUIWidgetMountInfoDetail