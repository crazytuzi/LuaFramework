local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetDailySignInBox = class("QUIWidgetDailySignInBox", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QVIPUtil = import("...utils.QVIPUtil")
local QUIWidgetAnimationPlayer = import("..widgets.QUIWidgetAnimationPlayer")
local QLogFile = import("...utils.QLogFile")

QUIWidgetDailySignInBox.EVENT_CLICK = "SIGNINBOX_EVENT_CLICK"
QUIWidgetDailySignInBox.ADD_EVENT_CLICK = "ADD_SIGNINBOX_EVENT_CLICK"
QUIWidgetDailySignInBox.IS_VIP_READY = "IS_VIP_READY"
QUIWidgetDailySignInBox.IS_VIP_DONE = "IS_VIP_DONE"


QUIWidgetDailySignInBox.IS_DONE = "IS_DONE"
QUIWidgetDailySignInBox.IS_READY = "IS_READY"
QUIWidgetDailySignInBox.IS_WAITING = "IS_WAITING"
QUIWidgetDailySignInBox.IS_PATCH = "IS_PATCH"

function QUIWidgetDailySignInBox:ctor(options)
    local ccbFile = "ccb/Widget_DailySignIn_Box.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClick", callback = handler(self, QUIWidgetDailySignInBox._onTriggerClick)}
    }
    QUIWidgetDailySignInBox.super.ctor(self, ccbFile, callBacks, options)

    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

    -- setShadow5(self._ccbOwner.label_buqian,ccc3(255,69, 70))
    self.isVip = false
    self.vipLevel = nil
    self.state = nil
    if options ~= nil then
        self.type = options.type
    end

    self:setItem()
    self._ccbOwner.is_vip:setVisible(false)

    self._ccbOwner.sp_gray:setShaderProgram(qShader.Q_ProgramColorLayer)
    self._ccbOwner.sp_gray:setColor(ccc3(0, 0, 0))
    self._ccbOwner.sp_gray:setOpacity(0.5 * 255)

    self._ccbOwner.title:setVisible(false)
end

function QUIWidgetDailySignInBox:ininGLLayer(glLayerIndex)
    self._glLayerIndex = glLayerIndex or 1
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sprite_bj, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.is_ready, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.check_in_vip, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.box_bg, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.node_itme, self._glLayerIndex)
    if self.itemBox then
        self._glLayerIndex = self.itemBox:initGLLayer(self._glLayerIndex)
    end
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.num, self._glLayerIndex) -- 55
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sprite_gradient, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.is_vip, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_label, self._glLayerIndex) 
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.vip_level, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.tf_double, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_gray, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.choose, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.btn_click, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.label_buqian, self._glLayerIndex)
    self._glLayerIndex = q.nodeAddGLLayer(self._ccbOwner.sp_buqian, self._glLayerIndex)

    return self._glLayerIndex
end

-- nzhang: http://jira.joybest.com.cn/browse/WOW-9294
function QUIWidgetDailySignInBox:onEnter()
    if self.itemType then
        self:setItemBoxInfo(self.itemType, self.itemId, self.itemNum, self.index, self.state, self.effect)
    end
end

function QUIWidgetDailySignInBox:onExit()
    if self._scheduler ~= nil then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end 
end

function QUIWidgetDailySignInBox:resetAll()

    self._ccbOwner.box_bg:setVisible(false)
    self._ccbOwner.is_ready:setVisible(false)
    self._ccbOwner.check_in_vip:setVisible(false)
    self._ccbOwner.node_patch:setVisible(false)
    self._ccbOwner.choose:setVisible(false)
    self._ccbOwner.sp_gray:setVisible(false)


    if self.itemBox then
        self.itemBox:removeEffect()
    end
end

function QUIWidgetDailySignInBox:setItem()
    self.itemBox = QUIWidgetItemsBox.new()
    self._ccbOwner.node_itme:addChild(self.itemBox)
end

function QUIWidgetDailySignInBox:setItemBoxInfo(type, id, num, index, state, effect,isLeft)
    self.itemType = type
    self.itemId = id or nil
    self.itemNum = num
    self.index = index or 0
    self.effect = effect

    if self.itemId ~= nil then
        self.itemBox:setGoodsInfo(self.itemId, ITEM_TYPE.ITEM, 0)
    else
        self.itemBox:setGoodsInfo(self.itemId, remote.items:getItemType(self.itemType), 0)
    end

    self._ccbOwner.num:setString("×"..self.itemNum)
    local numSize = self._ccbOwner.num:getContentSize()
    local boxSize = self._ccbOwner.box_bg:getContentSize()
    local scale = (boxSize.width - 40)/numSize.width
    if scale < 1 then
        self._ccbOwner.num:setScale(scale)
    else
        self._ccbOwner.num:setScale(1)
    end

    self:setSignInState(state)

    if self.effect and self.effect == 1 then
        self:setSpecialEffect()
    end
    if isLeft then
        self._ccbOwner.sp_bg_di:setVisible(false)
    end
end

function QUIWidgetDailySignInBox:setSignInState(state)
    if state == QUIWidgetDailySignInBox.IS_DONE then
        self:setSignIsDone()
    elseif state == QUIWidgetDailySignInBox.IS_READY then
        self:setSignIsReady()
    elseif state == QUIWidgetDailySignInBox.IS_WAITING then
        self:setSignIsWaiting()
    elseif state == QUIWidgetDailySignInBox.IS_PATCH then
        self:setSignIsPatch()
    end
    self.state = state
end

function QUIWidgetDailySignInBox:setVipInfo(index, vipLevel)
    self.vipLevel = vipLevel

    if vipLevel then
        self._ccbOwner.is_vip:setVisible(true)
        self._ccbOwner.vip_level:setString("V"..vipLevel)
        self.isVip = true
    else
        self.isVip = false
        self._ccbOwner.is_vip:setVisible(false)
    end
end

function QUIWidgetDailySignInBox:setSpecialEffect()
    if self.itemBox then
        self.itemBox:removeEffect()
    end
    self.itemBox:showBoxEffect("effects/DailySignIn_saoguang2.ccbi", true)
end

--可以签到
function QUIWidgetDailySignInBox:setSignIsReady(isVip)
    self:resetAll()
    self._ccbOwner.is_ready:setVisible(true)
    self.itemBox:showBoxEffect("effects/leiji_light.ccbi", true,0,0,0.8)
    if self.isVip == true and remote.daily:getCurrentSignInState() == 1 then
        self._ccbOwner.check_in_vip:setVisible(true)
    else
        self._ccbOwner.check_in_vip:setVisible(false)
    end
end

--签到未完成
function QUIWidgetDailySignInBox:setSignIsWaiting()
    if self.state == QUIWidgetDailySignInBox.IS_WAITING then return end
    self:resetAll()
end

--签到完成
function QUIWidgetDailySignInBox:setSignIsDone()
    if self.state == QUIWidgetDailySignInBox.IS_DONE then return end

    self:resetAll()
    self._ccbOwner.choose:setVisible(true)
    self._ccbOwner.box_bg:setVisible(true)
    self._ccbOwner.sp_gray:setVisible(true)
end

function QUIWidgetDailySignInBox:setSignIsPatch()
    self:resetAll()

    self._ccbOwner.is_ready:setVisible(true)
    self._ccbOwner.node_patch:setVisible(true)
    self.itemBox:showBoxEffect("effects/leiji_light.ccbi", true,0,0,0.8)
end

function QUIWidgetDailySignInBox:setTitleStr(signNum)
    -- self._ccbOwner.title:setVisible(self.index == 1)

    if signNum then
        self._ccbOwner.sign_num:setString(signNum)
    end
end

function QUIWidgetDailySignInBox:getName()
    return "QUIWidgetDailySignInBox"
end

function QUIWidgetDailySignInBox:getContentSize()
    local contentSize = self._ccbOwner.box_bg:getContentSize()
    return CCSize(contentSize.width, contentSize.height - 20)
end

function QUIWidgetDailySignInBox:getItemContentSize()
    local contentSize = self._ccbOwner.box_bg:getContentSize()
    return CCSize(contentSize.width, contentSize.height)
end

function QUIWidgetDailySignInBox:_onTriggerClick()
    local items = {}
    
    local clickName = QUIWidgetDailySignInBox.EVENT_CLICK
    --当前日志是为了检查线上问题使用，请不要随意删除
    QLogFile:debug(function ( ... ) return string.format("--- self.type == %s ---", self.type) end)
    if self.type ~= "ADD_UP" then
        items[1] = {id = self.itemId, typeName = self.itemType, count = self.itemNum}
        QLogFile:debug(function ( ... ) return string.format("--- self.state == %s, self.isVip == %s ---", self.state, self.isVip) end)
        QLogFile:debug(function ( ... ) return string.format("--- QVIPUtil:VIPLevel() >= self.vipLevel == %s ---", QVIPUtil:VIPLevel() >= (self.vipLevel or 0) ) end)
        if self.state == QUIWidgetDailySignInBox.IS_READY then
            QLogFile:debug(function ( ... ) return string.format("--- remote.daily:getCurrentSignInState() == %s ---", remote.daily:getCurrentSignInState()) end)
            if self.isVip == true and QVIPUtil:VIPLevel() >= self.vipLevel and remote.daily:getCurrentSignInState() < 1 then
                items[2] = {id = self.itemId, typeName = self.itemType, count = self.itemNum}
            end
        elseif self.state == QUIWidgetDailySignInBox.IS_PATCH then
            if self.isVip == true and QVIPUtil:VIPLevel() >= self.vipLevel then
                items[2] = {id = self.itemId, typeName = self.itemType, count = self.itemNum}
            end
        end
    else
        items[1] = {id = self.itemId, typeName = self.itemType, count = self.itemNum}
        clickName = QUIWidgetDailySignInBox.ADD_EVENT_CLICK
    end

    self:dispatchEvent({name = clickName, items = items, state = self.state, index = self.index, isVip = self.isVip, vipLevel = self.vipLevel})
end

return QUIWidgetDailySignInBox
