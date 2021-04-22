-- @Author: zhouxiaoshu
-- @Date:   2019-10-21 15:53:36
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-12-09 10:04:36
local QUIWidget = import("..QUIWidget")
local QUIWidgetMountInfoTalent = class("QUIWidgetMountInfoTalent", QUIWidget)

local QScrollView = import("....views.QScrollView") 
local QUIViewController = import("....ui.QUIViewController")
local QUIWidgetMountInfoTalentClient = import(".QUIWidgetMountInfoTalentClient")

function QUIWidgetMountInfoTalent:ctor(ccbFile,callBacks,options)
    local ccbFile = "ccb/Widget_Weapon_xinxi_04.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerUnwear", callback = handler(self, self._onTriggerUnwear)},
        {ccbCallbackName = "onTriggerWear", callback = handler(self, self._onTriggerWear)},
    }
    QUIWidgetMountInfoTalent.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()
end

function QUIWidgetMountInfoTalent:onEnter()
    self:initScrollView()
end

function QUIWidgetMountInfoTalent:onExit()
end

function QUIWidgetMountInfoTalent:initScrollView()
    if not self._scrollView then
        local itemContentSize = self._ccbOwner.sheet_layout:getContentSize()
        self._scrollView = QScrollView.new(self._ccbOwner.sheet, itemContentSize, {bufferMode = 1, sensitiveDistance = 10})
        self._scrollView:setVerticalBounce(true)
    end
end

function QUIWidgetMountInfoTalent:setInfo(actorId, showSSMountEffect)
    self:initScrollView()

    self._actorId = actorId
    local heroInfo = remote.herosUtil:getHeroByID(actorId)
    local mountId = heroInfo.zuoqi.zuoqiId
    self:setMountId(mountId, showSSMountEffect)
end

function QUIWidgetMountInfoTalent:setMountId(mountId, showSSMountEffect)
    self._scrollView:clear()

    self._mountId = mountId
    local mountInfo = remote.mount:getMountById(self._mountId)
    if mountInfo.wearZuoqiInfo then
        self._ccbOwner.node_unwear:setVisible(true)
        self._ccbOwner.node_wear:setPositionX(400)
        self._ccbOwner.tf_wear_font:setString("换配件")
    else
        self._ccbOwner.node_unwear:setVisible(false)
        self._ccbOwner.node_wear:setPositionX(274)
        self._ccbOwner.tf_wear_font:setString("配件装备")
    end

    local client = QUIWidgetMountInfoTalentClient.new()
    client:setInfo(mountId, showSSMountEffect)
    self._scrollView:addItemBox(client)

    local contentSize = client:getContentSize()
    client:setPosition(ccp(0, 0))
    self._scrollView:setRect(0, -contentSize.height, 0, contentSize.width)
end

function QUIWidgetMountInfoTalent:setButtonVisible(isShow)
    self._ccbOwner.node_unwear:setVisible(isShow)
    self._ccbOwner.node_wear:setVisible(isShow)
end

function QUIWidgetMountInfoTalent:_onTriggerWear(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_wear) == false then return end
    app.sound:playSound("common_small")
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogMountOverView", 
        options = {mountId = self._mountId}})
end

function QUIWidgetMountInfoTalent:_onTriggerUnwear(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_unwear) == false then return end
    app.sound:playSound("common_small")
    if not self._mountId then
        return
    end
    local mountInfo = remote.mount:getMountById(self._mountId)
    if mountInfo ~= nil then
        local mountId = mountInfo.wearZuoqiInfo.zuoqiId
        remote.mount:superMountWearRequest(nil, self._mountId, false, function ()
            remote.mount:dispatchEvent({name = remote.mount.EVENT_UNWEAR_MOUNT, mountId = mountId})
        end)
    end
end

return QUIWidgetMountInfoTalent