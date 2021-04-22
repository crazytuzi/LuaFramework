--
-- Author: Your Name
-- Date: 2015-01-17 11:36:24
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogVIPRecharge = class("QUIDialogVIPRecharge", QUIDialog)

local QUIViewController = import("..QUIViewController")
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollView = import("...views.QScrollView")
local QUIWidgetVIPRecharge = import("..widgets.QUIWidgetVIPRecharge")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QUIDialogVIP = import(".QUIDialogVip")
local QVIPUtil = import("...utils.QVIPUtil")


function QUIDialogVIPRecharge:ctor(options)
 	local ccbFile = "ccb/Dialog_VipChongzhi.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerVIP", callback = handler(self, QUIDialogVIPRecharge._onTriggerVIP)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogVIPRecharge._onTriggerClose)},
        {ccbCallbackName = "onTriggerLeft", callback = handler(self, QUIDialogVIPRecharge._onTriggerLeft)},
        {ccbCallbackName = "onTriggerRight", callback = handler(self, QUIDialogVIPRecharge._onTriggerRight)},

        
    }
    QUIDialogVIPRecharge.super.ctor(self, ccbFile, callBacks, options)

    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()

    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    page:setManyUIVisible()
    if FinalSDK.isHXShenhe() then
        page:setScalingVisible(false)
        self._ccbOwner.recharge:setVisible(false)
    end
    page.topBar:showWithMainPage()

    self._scrollView = QScrollView.new(self._ccbOwner.sheet, self._ccbOwner.sheet_layout:getContentSize(),{sensitiveDistance = 10,moveDuration = 0.5})
    self._scrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._scrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
    self._scrollView:addEventListener(QScrollView.GESTURE_END, handler(self, self._onScrollViewEnd))

    self._scrollView:setVerticalBounce(false)
    self._scrollView:setHorizontalBounce(false)
    self._scrollView:setSlideEnable(false)


    self._columnNumber = 5
    self._rowNumber = 2
    self._widthGap = 185
    self._heightGap = 196
    self._curPage = 1
    self._totalPageNum = 1
    
    if not options then
        options = {}
    end
    self._highLightValues = options.highLightValues or {}
end

function QUIDialogVIPRecharge:viewDidAppear( ... )
    QUIDialogVIPRecharge.super.viewDidAppear(self)
    self:addBackEvent()
    if FinalSDK.isHXShenhe() then
        local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
        page:setHomeBtnVisible(false)
    end
    self:updateVIP()
    QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.VIP_RECHARGED, self.refresh, self)

end

function QUIDialogVIPRecharge:viewAnimationInHandler()
    app:getClient():getRechargetHistory(function (data)
        if self:safeCheck() then
            self:update()
        end
    end)
end

function QUIDialogVIPRecharge:viewWillDisappear( ... )
    QUIDialogVIPRecharge.super.viewWillDisappear(self)
    self:removeBackEvent()
    self:removeAllEventListeners()
    QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.VIP_RECHARGED, self.refresh, self)

end


function QUIDialogVIPRecharge:update()
    self._scrollView:clear(false)

    local currentVIPLevel = QVIPUtil:VIPLevel()
    local currentRecharged = QVIPUtil:recharged()

    -- Show monthly recharge in front of ordinary recharge
    local recharge = QStaticDatabase:sharedDatabase():getRecharge()
   

    local rechargeData = {}
    for k, v in pairs(recharge) do
        if v.type == 1 or v.type == 2 then     --type 3 是魂师手札充值类型，不需要加到充值界面
            table.insert(rechargeData, v)
        end
    end

    table.sort( rechargeData, function (x, y)
        if x.type == y.type then
            if x.type == 2 then
                return x.RMB < y.RMB
            else
                return x.RMB > y.RMB
            end
        else
            if x.type == 2 then
                local remainingDays = 0
                local rmb = tonumber(x.RMB) or 0
                if rmb == 25 then
                     remainingDays = (remote.recharge.monthCard1EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(3600 * 24)
                else
                     remainingDays = (remote.recharge.monthCard2EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(3600 * 24)
                end

                if remainingDays > 0 then
                    return false
                else
                    return true
                end

            elseif y.type == 2 then
                local remainingDays = 0
                local rmb = tonumber(y.RMB) or 0
                if rmb == 25 then
                     remainingDays = (remote.recharge.monthCard1EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(3600 * 24)
                else
                     remainingDays = (remote.recharge.monthCard2EndTime/1000 - q.refreshTime(remote.user.c_systemRefreshTime))/(3600 * 24)
                end
                if remainingDays > 0 then
                    return true
                else
                    return false
                end
            else
                return x.type > y.type
            end
        end
    end )

    local rechargeCount = #rechargeData
    local pageMaxNum = self._columnNumber * self._rowNumber
    self._totalPageNum = math.ceil(rechargeCount/ pageMaxNum)

    for i = 1, self._totalPageNum, 1 do
        for j = 1 + (i-1)*pageMaxNum, i*pageMaxNum, 1 do
            local v = rechargeData[j]
            if not v then
                break;
            end

            local rechargeItem
            if v.type == 2 then
                rechargeItem = QUIWidgetVIPRecharge.new({parent = self, type = v.type, cost = v.RMB,
                    presentCount = v.token, dailyPresent = v.everyday, extra = {v.recharge1, v.recharge2, v.recharge3}, extraAward = {v.recharge1_reward},
                    boughtCount = self:getBoughtCount(v.RMB, v.type), icon = v.icon,icon2 = v.icon2,isHighLight = self._highLightValues[tostring(v.RMB)],
                    callback = function ( ... )
                        self:refresh()
                    end})
                
            else
                rechargeItem = QUIWidgetVIPRecharge.new({parent = self, type = v.type, cost = v.RMB, 
                    presentCount = v.token, dailyPresent = v.everyday, extra = {v.recharge1, v.recharge2, v.recharge3}, extraAward = {v.recharge1_reward},
                    boughtCount = self:getBoughtCount(v.RMB, v.type), icon = v.icon,icon2 = v.icon2,isHighLight = self._highLightValues[tostring(v.RMB)],
                    callback = function ( ... )
                        self:refresh()
                    end})
            end
            local x = ((j - 1)% self._columnNumber + (i-1)*self._columnNumber) * (self._widthGap + 5 ) - 1
            local y = - math.floor((((j - 1)%pageMaxNum) / self._columnNumber)) * (self._heightGap + 5) - 5

            rechargeItem:setPosition(x, y)
            self._scrollView:addItemBox(rechargeItem)
        end
    end

    self._scrollView:setRect(0,-self._ccbOwner.sheet_layout:getContentSize().height, 0, self._totalPageNum * self._columnNumber * self._widthGap)

    self:updatePageInfo()
    self:updateVIP()

end


function QUIDialogVIPRecharge:updatePageInfo( )
    -- body
    if self._totalPageNum == 1  then
        self._ccbOwner.goRight:setVisible(false)
        self._ccbOwner.goLeft:setVisible(false)
        self._curPage = 1
    elseif self._curPage <= 1 then
        self._ccbOwner.goRight:setVisible(true)
        self._ccbOwner.goLeft:setVisible(false)
        self._curPage = 1
    elseif self._curPage >= self._totalPageNum then
        self._ccbOwner.goRight:setVisible(false)
        self._ccbOwner.goLeft:setVisible(true)
        self._curPage = self._totalPageNum
    else
        self._ccbOwner.goRight:setVisible(true)
        self._ccbOwner.goLeft:setVisible(true)
    end
end



function QUIDialogVIPRecharge:updateVIP()
    -- Show vip exp progress bar
    local function addMaskLayer(ccb, mask, scaleX, scaleY)
        local width = ccb:getContentSize().width * scaleX
        local height = ccb:getContentSize().height * scaleY
        local maskLayer = CCLayerColor:create(ccc4(0,0,0,150), width, height)
        maskLayer:setAnchorPoint(ccp(0, 0.5))
        maskLayer:setPosition(ccp(-width/2, -height/2))

        local ccclippingNode = CCClippingNode:create()
        ccclippingNode:setStencil(maskLayer)
        ccb:retain()
        ccb:removeFromParent()
        ccb:setPosition(ccp(-width/2, 0))
        ccclippingNode:addChild(ccb)
        ccb:release()

        mask:addChild(ccclippingNode)
        return maskLayer
    end

    local currentVIPLevel = QVIPUtil:VIPLevel()
    self._ccbOwner.currentVIPLevel:setString(currentVIPLevel)
    self._ccbOwner.recharge_tip:setVisible(remote.stores:checkVipAwardRedTips())
    if QVIPUtil:isVIPMaxLevel() then
        self._ccbOwner.nextVIPNode:setVisible(false)

        local vipLevel, vipExp = QVIPUtil:getVIPLevel(remote.user.totalRechargeToken) 
        -- vipExp = QVIPUtil:cash(vipLevel)
        -- self._ccbOwner.vip_progress:setString(tostring(remote.user.totalRechargeToken) .. "/" .. QVIPUtil:cash(vipLevel))

        -- local vipMask = addMaskLayer(self._ccbOwner.vip_bar, self._ccbOwner.vip_mask, 3.39, 1.1)
        -- local vipRatio = remote.user.totalRechargeToken/QVIPUtil:cash(vipLevel)
        -- vipRatio = vipRatio > 1 and 1 or (vipRatio < 0 and 0 or vipRatio)
        -- vipMask:setScaleX(vipRatio)

        vipExp = QVIPUtil:cash(vipLevel)
        self._ccbOwner.vip_progress:setString(tostring(remote.user.totalRechargeToken) .. "/" .. self:getAllExp(vipLevel))

        local vipMask = addMaskLayer(self._ccbOwner.vip_bar, self._ccbOwner.vip_mask, 1, 1)
        local vipRatio = remote.user.totalRechargeToken/self:getAllExp(vipLevel)
        vipRatio = vipRatio > 1 and 1 or (vipRatio < 0 and 0 or vipRatio)
        vipMask:setScaleX(vipRatio)
    else
        local nextVIPLevel = currentVIPLevel + 1
        self._ccbOwner.nextVIPNode:setVisible(true)
        self._ccbOwner.nextVIPLevel:setString(nextVIPLevel)


        local vipLevel, vipExp = QVIPUtil:getVIPLevel(remote.user.totalRechargeToken)
        -- local nextVIPExp = QVIPUtil:cash(nextVIPLevel) - vipExp
        -- local nextString = nextVIPExp > 1000000 and tostring(math.floor(nextVIPExp/10000)) .. "万" or nextVIPExp
        -- self._ccbOwner.vip_progress:setString(tostring(remote.user.totalRechargeToken) .. "/" .. QVIPUtil:cash(nextVIPLevel))
        -- self._ccbOwner.nextCost:setString(nextString)

        -- local vipMask = addMaskLayer(self._ccbOwner.vip_bar, self._ccbOwner.vip_mask, 3.39, 1.1)
        -- local vipRatio = remote.user.totalRechargeToken/QVIPUtil:cash(nextVIPLevel)
        -- vipRatio = vipRatio > 1 and 1 or (vipRatio < 0 and 0 or vipRatio)
        -- vipMask:setScaleX(vipRatio)

        local nextVIPExp = QVIPUtil:cash(nextVIPLevel) - vipExp
        local nextString = nextVIPExp > 1000000 and tostring(math.floor(nextVIPExp/10000)) .. "万" or nextVIPExp
        self._ccbOwner.vip_progress:setString(tostring(remote.user.totalRechargeToken) .. "/" .. self:getAllExp(nextVIPLevel))
        self._ccbOwner.nextCost:setString(nextString)

        local vipMask = addMaskLayer(self._ccbOwner.vip_bar, self._ccbOwner.vip_mask, 1, 1)
        local vipRatio = remote.user.totalRechargeToken/self:getAllExp(nextVIPLevel)
        vipRatio = vipRatio > 1 and 1 or (vipRatio < 0 and 0 or vipRatio)
        vipMask:setScaleX(vipRatio)
    end
end

function QUIDialogVIPRecharge:getAllExp(vipLevel)
    return QVIPUtil:cash(vipLevel)
end

function QUIDialogVIPRecharge:getBoughtCount(cost, type)
    local recharge = remote.recharge or {}
    for k, v in ipairs(recharge.rechargeDetails or {}) do
        if tonumber(v.cash_num) == tonumber(cost) and tonumber(v.cash_type) == tonumber(type) then
            return v.recharge_cnt
        end
    end

    return 0
end

function QUIDialogVIPRecharge:refresh()
    self:updateVIP()
    self:update()
end


function QUIDialogVIPRecharge:_onTriggerVIP( ... )
    if self._isTrigger == true then return end
    app.sound:playSound("common_small")
    self._isTrigger = true
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER, false)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogVip"})
end


function QUIDialogVIPRecharge:_onScrollViewMoving()
    self._isMoving = true
end


function QUIDialogVIPRecharge:_onScrollViewBegan()
    self._isMoving = false
    self._preX = self._scrollView:getPositionX()
end


function QUIDialogVIPRecharge:_onScrollViewEnd()
    local x = self._scrollView:getPositionX()
    local prex = self._preX or 0
    if math.abs(prex - x) > 100 then
        if x < prex  then
            self:_onTriggerRight()
        else
            self:_onTriggerLeft()
        end
    else
        scheduler.performWithDelayGlobal(self:safeHandler(function (  )
            -- body
            self._scrollView:stopAllActions()
            self._scrollView:moveTo(-(self._curPage -1 )*self._columnNumber * self._widthGap, 0, true)
        end),0)
    end
end

function QUIDialogVIPRecharge:isScrollViewMoving()
    return self._scrollView:isScrollViewMoving()
end



function QUIDialogVIPRecharge:onTriggerBackHandler(tag)
    self:_onTriggerBack()
end

function QUIDialogVIPRecharge:onTriggerHomeHandler(tag)
    self:_onTriggerHome()
end

function QUIDialogVIPRecharge:_onTriggerBack()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogVIPRecharge:_onTriggerHome()
    app:getNavigationManager():popViewController(app.mainUILayer, QNavigationController.POP_TO_CURRENT_PAGE)
end

-- 关闭对话框
function QUIDialogVIPRecharge:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogVIPRecharge:_onTriggerLeft()
    if self._curPage >= 2 then
        app.sound:playSound("common_switch")
        self._curPage = self._curPage - 1
        self:updatePageInfo()
    end
     self._scrollView:stopAllActions()
    self._scrollView:moveTo(-(self._curPage -1 )*self._columnNumber * self._widthGap, 0, true)

end

function QUIDialogVIPRecharge:_onTriggerRight()
    if self._curPage < self._totalPageNum then
        app.sound:playSound("common_switch")
        self._curPage = self._curPage + 1
        self:updatePageInfo()
    end
    self._scrollView:stopAllActions()
    self._scrollView:moveTo(-(self._curPage -1 )*self._columnNumber * self._widthGap, 0, true)

    --  print("_onTriggerRight")
    -- self._scrollView:moveTo(-(self._curPage -1 )*self._columnNumber * self._widthGap, 0, true)
end

return QUIDialogVIPRecharge