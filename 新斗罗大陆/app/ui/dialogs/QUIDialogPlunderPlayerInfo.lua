--
-- Author: Kumo
-- Date: Tue July 12 18:30:36 2016
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogPlunderPlayerInfo = class("QUIDialogPlunderPlayerInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetGemStonePieceBox = import("..widgets.QUIWidgetGemStonePieceBox")
local QScrollView = import("...views.QScrollView")
local QPlunderArrangement = import("...arrangement.QPlunderArrangement")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

local QUIWidgetSilverMineIcon = import("..widgets.QUIWidgetSilverMineIcon")
local QUIWidgetSilverMineOpportunity = import("..widgets.QUIWidgetSilverMineOpportunity")
local QRichText = import("...utils.QRichText")
local QQuickWay = import("...utils.QQuickWay")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")


local ITEM_ROWDISTANCE = 30
local ITEM_LINEDISTANCE = 55
local THING_ROWDISTANCE = 0
local THING_LINEDISTANCE = 5
local SHOW_AWARD = "SHOW_AWARD"
local SHOW_OPPORTUNITY = "SHOW_OPPORTUNITY"

function QUIDialogPlunderPlayerInfo:ctor(options)
    local ccbFile = "ccb/Dialog_plunder_nueduo.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogPlunderPlayerInfo._onTriggerClose)},
        {ccbCallbackName = "onTriggerInfo", callback = handler(self, QUIDialogPlunderPlayerInfo._onTriggerInfo)},
        {ccbCallbackName = "onTriggerBuff", callback = handler(self, QUIDialogPlunderPlayerInfo._onTriggerBuff)},
        {ccbCallbackName = "onTriggerOccupy", callback = handler(self, QUIDialogPlunderPlayerInfo._onTriggerOccupy)},
        {ccbCallbackName = "onTriggerPlunder", callback = handler(self, QUIDialogPlunderPlayerInfo._onTriggerPlunder)},
        {ccbCallbackName = "onTriggerOK", callback = handler(self, QUIDialogPlunderPlayerInfo._onTriggerOK)},
    }
    QUIDialogPlunderPlayerInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._mineId = options.mineId
    self._mineConfig = remote.plunder:getMineConfigByMineId( self._mineId )

    -- self._ccbOwner.tf_self_title = setShadow5(self._ccbOwner.tf_self_title)
    -- self._ccbOwner.tf_other_title = setShadow5(self._ccbOwner.tf_other_title)
    -- self._ccbOwner.tf_award = setShadow5(self._ccbOwner.tf_award)
    -- self._ccbOwner.tf_opportunity = setShadow5(self._ccbOwner.tf_opportunity)

    self._ccbOwner.tf_name:setString("")
    self._ccbOwner.tf_gameAreaName:setString("")
    self._ccbOwner.tf_consortiaName:setString("")
    self._ccbOwner.tf_token_price:setString( "" )
    self._ccbOwner.sp_token:setVisible(false)

    self._ccbOwner.node_ok:setVisible(false)
    self._ccbOwner.btn_ok:setEnabled(false)
    self._ccbOwner.node_occupy:setVisible(false)
    self._ccbOwner.btn_occupy:setEnabled(false)
    self._ccbOwner.node_plunder:setVisible(false)
    self._ccbOwner.btn_plunder:setEnabled(false)
end

function QUIDialogPlunderPlayerInfo:viewDidAppear()
    QUIDialogPlunderPlayerInfo.super.viewDidAppear(self)

    self._plunderProxy = cc.EventProxy.new(remote.plunder)
    self._plunderProxy:addEventListener(remote.plunder.NEW_DAY, self:safeHandler(self, self._updatePlunderHandler))
    self._plunderProxy:addEventListener(remote.plunder.MINE_UPDATE, self:safeHandler(self, self._updatePlunderHandler))
    self._plunderProxy:addEventListener(remote.plunder.MY_INFO_UPDATE, self:safeHandler(self, self._updatePlunderHandler))

    self._requestScheduler = scheduler.scheduleGlobal(function() self:_request() end, 600)
end

function QUIDialogPlunderPlayerInfo:_updatePlunderHandler( event )
    if event.name == remote.silverMine.NEW_DAY then
        self:_updateInfo()
    elseif event.name == remote.plunder.MINE_UPDATE then
        self:_initInfo()
    elseif event.name == remote.plunder.MY_INFO_UPDATE then
        self:_initInfo()
    end
end

function QUIDialogPlunderPlayerInfo:viewAnimationInHandler()
    self:_initInfo()
    self:_request()
end

function QUIDialogPlunderPlayerInfo:viewWillDisappear()
    QUIDialogPlunderPlayerInfo.super.viewWillDisappear(self)

    if self._plunderProxy then
        self._plunderProxy:removeAllEventListeners()
    end

    if self._scheduler then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end

    if self._requestScheduler then
        scheduler.unscheduleGlobal(self._requestScheduler)
        self._requestScheduler = nil
    end
end

function QUIDialogPlunderPlayerInfo:_onTriggerInfo(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_info) == false then return end
    app.sound:playSound("common_small")
    if remote.plunder:isLock() then return end
    if remote.plunder:checkBurstIn() then return end 

    remote.plunder:addLock()
    local userId = remote.plunder:getOwnerIdByMineId( self._mineId )
    remote.plunder:plunderQueryFighterRequest(userId, function(response)
            local data = response.kuafuMineQueryFighterResponse.fighter
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo", 
                options = {fighter = data, forceTitle = "防守战力：", specialTitle1 = "服务器名：", specialValue1 = data.game_area_name, isPVP = true}}, {isPopCurrentDialog = false})
        end)
end

function QUIDialogPlunderPlayerInfo:_onTriggerBuff()
    app.sound:playSound("common_small")
    if remote.plunder:checkBurstIn() then return end 

    app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlunderBuffTips", options = {x = 0, y = 0, mineId = self._mineId}})
end

function QUIDialogPlunderPlayerInfo:_onTriggerOccupy(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_plunder) == false then return end
    app.sound:playSound("common_small")
    if remote.plunder:checkBurstIn() then return end 

    if tonumber(remote.plunder:getMyMineId()) == tonumber(self._mineId) then 
        app.tip:floatTip("魂师大人，无法占领自己的魂兽区")
        return
    end
    if remote.plunder:isLock() then return end
    remote.plunder:addLock()

    if remote.plunder:getOccupyPrice() > 0 then
        if remote.plunder:canBuyOccupyCnt() then
            -- print(remote.user.token.."  <  "..remote.plunder:getOccupyPrice())
            if remote.user.token < remote.plunder:getOccupyPrice() then
                QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil)
                return
            end
            remote.plunder:plunderBuyOccupyCntRequest(function() 
                    remote.plunder:removeLock()
                    -- self:_onTriggerOccupy()
                    local mines = remote.plunder:getMines()
                    local userId = nil
                    for _, mine in pairs(mines) do
                        if mine.mineId == self._mineId then
                            userId = mine.ownerId
                        end
                    end
                    -- remote.plunder:plunderQueryFighterRequest(userId)
                    self:_gotoTeamArrangement(self._mineId, userId, false)
                end)
        else
            if QVIPUtil:VIPLevel() < QVIPUtil:getMaxLevel() then
                app:vipAlert({content="购买次数已达上限，提升VIP等级可提高购买次数上限"}, false)
            else
                app.tip:floatTip("今日的购买次数已用完")
            end
        end
        return
    end

    local mines = remote.plunder:getMines()
    local userId = nil
    for _, mine in pairs(mines) do
        if mine.mineId == self._mineId then
            userId = mine.ownerId
        end
    end
    -- remote.plunder:plunderQueryFighterRequest(userId)
    self:_gotoTeamArrangement(self._mineId, userId, false)
end

function QUIDialogPlunderPlayerInfo:_onTriggerPlunder(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_occupy) == false then return end
    app.sound:playSound("common_small")
    if remote.plunder:checkBurstIn() then return end 
    
    if tonumber(remote.plunder:getMyMineId()) == tonumber(self._mineId) then 
        app.tip:floatTip("魂师大人，无法掠夺自己的魂兽区")
        return
    end
    if remote.plunder:isLock() then return end
    remote.plunder:addLock()
    if remote.plunder:getLootCnt() == 0 then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogBuyCountBase", options = {cls = "QBuyCountUnionPlunder"}})
        return
    end
    local mines = remote.plunder:getMines()
    local userId = nil
    for _, mine in pairs(mines) do
        if mine.mineId == self._mineId then
            userId = mine.ownerId
        end
    end
    -- remote.plunder:plunderQueryFighterRequest(userId)
    self:_gotoTeamArrangement(self._mineId, userId, true)
end

function QUIDialogPlunderPlayerInfo:viewAnimationOutHandler()
    self:removeSelfFromParent()
end

function QUIDialogPlunderPlayerInfo:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogPlunderPlayerInfo:_onTriggerOK(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_ok) == false then return end
    self:_onTriggerClose()
end

function QUIDialogPlunderPlayerInfo:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    if e then
        app.sound:playSound("common_cancel")
    end
    self:playEffectOut()
end

function QUIDialogPlunderPlayerInfo:removeSelfFromParent()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogPlunderPlayerInfo:_request()
    local caveId = remote.plunder:getCaveIdByMineId( self._mineId )
    remote.plunder:plunderGetCaveInfoRequest(caveId)
    remote.plunder:plunderGetMyInfoRequest()
end

function QUIDialogPlunderPlayerInfo:_initInfo()
    local name = remote.plunder:getMineCNNameByQuality( self._mineConfig.mine_quality )
    -- self._mineConfig.mine_name.." - "..
    self._ccbOwner.frame_tf_title:setString(name)
    -- local icon = QUIWidgetSilverMineIcon.new({quality = self._mineConfig.mine_quality, isNoEvent = true})
    -- self._ccbOwner.node_icon:addChild(icon)

    --展示怪物形象
    local monsterId = self._mineConfig.show_monster_id or 3170 
    local scale = self._mineConfig.show_monster_size or 1
    local isTurn = self._mineConfig.show_monster_turn
    if self._monsterAvatar == nil then
        self._monsterAvatar = QUIWidgetActorDisplay.new(monsterId)
        self._monsterAvatar:setScaleY(scale)
        if isTurn then
            scale = -scale
        end
        self._monsterAvatar:setScaleX(scale)
        self._ccbOwner.node_icon:addChild(self._monsterAvatar) 
    end

    local mineInfo = remote.plunder:getMineInfoByMineId( self._mineId )
    if mineInfo then
        self._ccbOwner.tf_name:setString(mineInfo.ownerName or "")
        self._ccbOwner.tf_gameAreaName:setString(mineInfo.gameAreaName or "")
        self._ccbOwner.tf_consortiaName:setString(mineInfo.consortiaName or "")
    end

    self:_updateInfo()
end

function QUIDialogPlunderPlayerInfo:_updateInfo()
    local mineInfo = remote.plunder:getMineInfoByMineId( self._mineId )
    if not mineInfo then
        self._ccbOwner.tf_total_score:setVisible(false)
        self._ccbOwner.tf_plunder_score:setVisible(false)
        self._ccbOwner.tf_score_output:setVisible(false)
        self._ccbOwner.tf_explain:setVisible(false)
        return
    end
    if tonumber(remote.plunder:getMyMineId()) == tonumber(self._mineId) or mineInfo.consortiaId == remote.plunder:getMyConsortiaId() then 
        self._ccbOwner.node_ok:setVisible(true)
        self._ccbOwner.btn_ok:setEnabled(true)
        self._ccbOwner.node_occupy:setVisible(false)
        self._ccbOwner.btn_occupy:setEnabled(false)
        self._ccbOwner.node_plunder:setVisible(false)
        self._ccbOwner.btn_plunder:setEnabled(false)
        self._ccbOwner.sp_token:setVisible(false)
        self._ccbOwner.tf_token_price:setString("")
    else
        self._ccbOwner.node_ok:setVisible(false)
        self._ccbOwner.btn_ok:setEnabled(false)
        self._ccbOwner.node_occupy:setVisible(true)
        self._ccbOwner.btn_occupy:setEnabled(true)
        self._ccbOwner.node_plunder:setVisible(true)
        self._ccbOwner.btn_plunder:setEnabled(true)
        local price = remote.plunder:getOccupyPrice()
        if price == 0 or not price then
            self._ccbOwner.sp_token:setVisible(false)
            self._ccbOwner.tf_token_price:setString("")
        else
            self._ccbOwner.sp_token:setVisible(true)
            self._ccbOwner.tf_token_price:setString(price)
        end
    end

    self._ccbOwner.tf_total_score:setString( mineInfo.occupyScore )
    self._ccbOwner.tf_plunder_score:setString( math.floor(mineInfo.occupyScore * remote.plunder:getPlunderProportion()) )

    local output = remote.plunder:getOutPutByMineId( self._mineId, nil, mineInfo.consortiaId )
    self._ccbOwner.tf_score_output:setString(output)

    local time = remote.plunder:getPlunderTime()
    local num = remote.plunder:getPlunderProportion()
    self._ccbOwner.tf_explain:setString("掠夺敌方前"..time.."小时（以当前时间点为准）产量的"..(num*100).."%")
end

function QUIDialogPlunderPlayerInfo:_gotoTeamArrangement(mineId, mineOwnerId, isPlunder)
    local plunderArrangement = QPlunderArrangement.new({mineId = mineId, mineOwnerId = mineOwnerId, isPlunder = isPlunder})
    plunderArrangement:setIsLocal(true)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
        options = {arrangement = plunderArrangement}})
end

return QUIDialogPlunderPlayerInfo
