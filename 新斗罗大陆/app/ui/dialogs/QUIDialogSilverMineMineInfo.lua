--
-- Author: Kumo
-- Date: Tue July 12 18:30:36 2016
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilverMineMineInfo = class("QUIDialogSilverMineMineInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QUIWidgetGemStonePieceBox = import("..widgets.QUIWidgetGemStonePieceBox")
-- local QScrollView = import("...views.QScrollView")
local QScrollContain = import("...ui.QScrollContain")
local QSilverMineArrangement = import("...arrangement.QSilverMineArrangement")
local QUIViewController = import("..QUIViewController")
local QNotificationCenter = import("...controllers.QNotificationCenter")

local QUIWidgetSilverMineIcon = import("..widgets.QUIWidgetSilverMineIcon")
local QUIWidgetSilverMineOpportunity = import("..widgets.QUIWidgetSilverMineOpportunity")
local QUIWidgetActorDisplay = import("..widgets.actorDisplay.QUIWidgetActorDisplay")

local ITEM_ROWDISTANCE = 20
local ITEM_LINEDISTANCE = 55
local THING_ROWDISTANCE = 0
local THING_LINEDISTANCE = 5
local SHOW_AWARD = "SHOW_AWARD"
local SHOW_OPPORTUNITY = "SHOW_OPPORTUNITY"

function QUIDialogSilverMineMineInfo:ctor(options)
    local ccbFile = "ccb/Dialog_SilverMine_MineInfo.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSilverMineMineInfo._onTriggerClose)},
        {ccbCallbackName = "onTriggerInfo", callback = handler(self, QUIDialogSilverMineMineInfo._onTriggerInfo)},
        {ccbCallbackName = "onTriggerBuff", callback = handler(self, QUIDialogSilverMineMineInfo._onTriggerBuff)},
        {ccbCallbackName = "onTriggerOccupy", callback = handler(self, QUIDialogSilverMineMineInfo._onTriggerOccupy)},
        {ccbCallbackName = "onTriggerExtendOccupy", callback = handler(self, QUIDialogSilverMineMineInfo._onTriggerExtendOccupy)},
        {ccbCallbackName = "onTriggerFinish", callback = handler(self, QUIDialogSilverMineMineInfo._onTriggerFinish)},
        {ccbCallbackName = "onTriggerAward", callback = handler(self, QUIDialogSilverMineMineInfo._onTriggerAward)},
        {ccbCallbackName = "onTriggerOpportunity", callback = handler(self, QUIDialogSilverMineMineInfo._onTriggerOpportunity)},
    }
    QUIDialogSilverMineMineInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

    self._mineId = options.mineId
    self._mineConfig = remote.silverMine:getMineConfigByMineId( self._mineId )
    self._totalAwardWidth = 0
    self._totalThingHeight = 0
    self._isOvertime = false
    self._type = LORD_TYPE.SELF
    self._tab = SHOW_AWARD

    for i=1,3 do
        local tf = self._ccbOwner["tf_self_assister"..i]
        tf:setColor(COLORS.k)
        tf:setString("当前可协助")
        local tf = self._ccbOwner["tf_other_assister"..i]
        tf:setColor(COLORS.k)
        tf:setString("当前可协助")
    end
    self._ccbOwner.tf_self_name:setString("")
    self._ccbOwner.tf_other_name:setString("")
    self._ccbOwner.tf_other_assist:setString("协助者0/3：")
    self._ccbOwner.tf_self_assist:setString("协助者0/3：")
    self._ccbOwner.tf_token_price:setString( "" )
    self._ccbOwner.sp_token:setVisible(false)

    self:_checkType()
end

function QUIDialogSilverMineMineInfo:viewDidAppear()
    -- print("[Kumo] 警告！ QUIDialogSilverMineMineInfo界面进入")
    QUIDialogSilverMineMineInfo.super.viewDidAppear(self)

    self.silverMineProxy = cc.EventProxy.new(remote.silverMine)
    self.silverMineProxy:addEventListener(remote.silverMine.MY_INFO_UPDATE, self:safeHandler(self, self._updateSilverMineHandler))
    self.silverMineProxy:addEventListener(remote.silverMine.CAVE_UPDATE, self:safeHandler(self, self._updateSilverMineHandler))

    self._requestScheduler = scheduler.scheduleGlobal(function() self:_request() end, 600)

    self:_updateByType(true)
end

function QUIDialogSilverMineMineInfo:viewAnimationInHandler()
    -- 弹出框播放完毕后初始化滑动组件，防止组件初始化的位置出现问题。 
    -- self:_initPageSwipe()
    self:initScroll()
    self:_initInfo()
    self:_request()
end

function QUIDialogSilverMineMineInfo:viewWillDisappear()
    -- print("[Kumo] 警告！ QUIDialogSilverMineMineInfo界面退出")
    QUIDialogSilverMineMineInfo.super.viewWillDisappear(self)

    -- if self._scrollViewProxy then
    --     self._scrollViewProxy:removeAllEventListeners()
    -- end
    -- if self._scrollView then
    --     self._scrollView:clear()
    -- end
    if self._scrollContain then
        self._scrollContain:disappear()
        self._scrollContain = nil
    end
    if self.silverMineProxy then
        self.silverMineProxy:removeAllEventListeners()
    end

    if self._scheduler then
        scheduler.unscheduleGlobal(self._scheduler)
        self._scheduler = nil
    end

    -- if self._scrollViewScheduler then
    --     scheduler.unscheduleGlobal(self._scrollViewScheduler)
    --     self._scrollViewScheduler = nil
    -- end

    if self._showOpportunityScheduler then
        scheduler.unscheduleGlobal(self._showOpportunityScheduler)
        self._showOpportunityScheduler = nil
    end

    if self._requestScheduler then
        scheduler.unscheduleGlobal(self._requestScheduler)
        self._requestScheduler = nil
    end
end

function QUIDialogSilverMineMineInfo:_onTriggerExtendOccupy(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_extend_occupy) == false then return end
    app.sound:playSound("common_small")
    if remote.silverMine:isLock() then return end
    remote.silverMine:addLock()
    if self._isOvertime then
        app.tip:floatTip("结算中，当前操作无效")
        return
    end
    local myOccupy = remote.silverMine:getMyOccupy()
    if myOccupy and myOccupy.extendCount then
        if myOccupy.extendCount < remote.silverMine:getMaxExtendOccupyCount() then
            app:alert({content = "是否花费"..remote.silverMine:getExtendOccupyPrice().."钻石，延长8小时狩猎时间？", title = "系统提示", 
                            callback = function(state)
                                if state == ALERT_TYPE.CONFIRM then
                                    remote.silverMine:silvermineExtendOccupyTimeRequest(self._mineId, self:safeHandler(function()
                                            self:_updateInfo()
                                        end))
                                elseif state == ALERT_TYPE.CANCEL then
                                    remote.silverMine:removeLock()
                                end
                            end, isAnimation = false}, true, true) 
            
            return
        end
    end
    remote.silverMine:removeLock()
    app.tip:floatTip("魂师大人，您的延长狩猎次数已经用完了")
end

function QUIDialogSilverMineMineInfo:_onTriggerFinish(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_finish) == false then return end
    app.sound:playSound("common_small")
    if remote.silverMine:isLock() then return end
    remote.silverMine:addLock()
    if self._isOvertime then
        app.tip:floatTip("结算中，当前操作无效")
        return
    end
    local myOccupy = remote.silverMine:getMyOccupy()
    local time = 8
    if myOccupy and table.nums(myOccupy) > 0 then
        -- print("[Kumo] myOccupy.extendCount = ", myOccupy.extendCount)
        time = time * (myOccupy.extendCount + 1)
    end
    app:alert({content = "是否要放弃当前所占的魂兽区并结算奖励？（狩猎"..time.."小时可以收益最大化）", title = "系统提示", 
                        callback = function(state)
                            if state == ALERT_TYPE.CONFIRM then
                                remote.silverMine:setFinishMineId( self._mineId )
                                remote.silverMine:silvermineFinishMineOccupyRequest(self:safeHandler(function()
                                        self:_onTriggerClose()
                                        -- self:_request()
                                    end))
                            elseif state == ALERT_TYPE.CANCEL then
                                remote.silverMine:removeLock()
                            end
                        end,isAnimation = false}, true, true)   
end

function QUIDialogSilverMineMineInfo:_onTriggerAward()
    app.sound:playSound("common_small")
    if remote.silverMine:isLock() then return end
    remote.silverMine:addLock()
    if self._isOvertime then
        self._ccbOwner.btn_award:setHighlighted(true)
        self._ccbOwner.btn_opportunity:setHighlighted(false)
        app.tip:floatTip("结算中，当前操作无效")
        return
    end
    remote.silverMine:silvermineGetMyInfoRequest()
    self._tab = SHOW_AWARD
    self:_updateShow()
end

function QUIDialogSilverMineMineInfo:_onTriggerOpportunity()
    app.sound:playSound("common_small")
    if remote.silverMine:isLock() then return end
    remote.silverMine:addLock()
    if self._isOvertime then
        self._ccbOwner.btn_award:setHighlighted(false)
        self._ccbOwner.btn_opportunity:setHighlighted(true)
        app.tip:floatTip("结算中，当前操作无效")
        return
    end
    local myOccupy = remote.silverMine:getMyOccupy()
    if myOccupy and myOccupy.occupyId then
        remote.silverMine:silvermineGetMiningEventListRequest(self._mineId, myOccupy.occupyId, self:safeHandler(function( response )
            self._miningEvents = response.silverMineGetMiningEventListResponse.miningEvents 
            self._tab = SHOW_OPPORTUNITY
            self:_updateShow()
        end))
    end
end

function QUIDialogSilverMineMineInfo:_onTriggerInfo(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_info) == false then return end
    app.sound:playSound("common_small")
    if remote.silverMine:isLock() then return end
    remote.silverMine:addLock()
    if self._isOvertime then
        app.tip:floatTip("结算中，当前操作无效")
        return
    end
    remote.silverMine:silvermineShowDefenseArmyRequest(self._mineId, self:safeHandler(function(response)
            local data = response.silverMineShowDefenseArmyResponse.defender
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo", options = {fighter = data, forceTitle = "防守战力：", isPVP = true}}, {isPopCurrentDialog = false})
            -- app:getNavigationManager():pushViewController(app.topLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSilverMineFigterInfo", options = {info = data, layer = app.topLayer}})
        end))
end

function QUIDialogSilverMineMineInfo:_onTriggerBuff()
    app.sound:playSound("common_small")
    if self._isOvertime then
        app.tip:floatTip("结算中，当前操作无效")
        return
    end
    app:getNavigationManager():pushViewController(app.topLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSilverMineBuffTips", options = {x = 0, y = 0, type = self._type, mineId = self._mineId}})
end

function QUIDialogSilverMineMineInfo:_onTriggerOccupy(e)
    if q.buttonEventShadow(e, self._ccbOwner.btn_occupy) == false then return end
    app.sound:playSound("common_small")
    if remote.silverMine:isLock() then return end
    remote.silverMine:addLock()

    if remote.silverMine:getFightCount() == 0 then
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBuyVirtual", options = {typeName = ITEM_TYPE.SILVERMINE_LIMIT}}, {isPopCurrentDialog = false})
        remote.silverMine:removeLock()
        return
    end

    local myOccupy = remote.silverMine:getMyOccupy()
    local lordType = remote.silverMine:getLordTypeByMineId( self._mineId )
    local mineInfo = remote.silverMine:getMineOccupyInfoByMineID( self._mineId )
    local myConsortiaId = remote.silverMine:getMyConsortiaId()

    if self:_isInTheTime() then
        -- 24~6 额外消耗钻石提醒
        if myOccupy and table.nums(myOccupy) > 0 then
            if lordType == LORD_TYPE.BOSS then
                -- 晚上，自己有魂兽区，打怪
                app:alert({content = "当前已有魂兽区，当您成功狩猎新魂兽区后将放弃并结算现有的魂兽区，是否继续狩猎？", title = "系统提示", 
                        callback = function(state)
                            if state == ALERT_TYPE.CONFIRM then
                                self:_checkForFightStartRequest()
                            elseif state == ALERT_TYPE.CANCEL then
                                remote.silverMine:removeLock()
                            end
                        end, isAnimation = true}, true, true)  
            else
                -- 晚上，自己有魂兽区，打人
                if mineInfo and myConsortiaId ~= "" and myConsortiaId == mineInfo.consortiaId then
                    -- 狩猎同宗门的魂兽区
                    app:alert({content = "##d是否消耗##e"..(remote.silverMine:getOccupyPriceAtPM() + remote.silverMine:getOccupyPriceForFriend()).."钻##d狩猎新魂兽区？（狩猎##e同宗门魂兽区##d需消耗##e"..remote.silverMine:getOccupyPriceForFriend().."钻##d，##e0点至6点##d狩猎需消耗##e"..remote.silverMine:getOccupyPriceAtPM().."钻##d）", title = "系统提示", 
                            callback = function(state)
                                if state == ALERT_TYPE.CONFIRM then
                                    self:_checkForFightStartRequest()
                                elseif state == ALERT_TYPE.CANCEL then
                                    remote.silverMine:removeLock()
                                end
                            end, isAnimation = true, colorful = true}, true, true)
                else
                    -- 狩猎非同宗门的魂兽区
                    app:alert({content = "##d是否放弃当前已狩猎的魂兽区并结算奖励？##e（每日0点至6点狩猎他人魂兽区需消耗"..remote.silverMine:getOccupyPriceAtPM().."钻石）", title = "系统提示", 
                            callback = function(state)
                                if state == ALERT_TYPE.CONFIRM then
                                    self:_checkForFightStartRequest()
                                elseif state == ALERT_TYPE.CANCEL then
                                    remote.silverMine:removeLock()
                                end
                            end, isAnimation = true, colorful = true}, true, true)   
                end
            end
        else
            if lordType == LORD_TYPE.BOSS then
                -- 晚上，自己没魂兽区，打怪
                self:_checkForFightStartRequest()
            else
                -- 晚上，自己没魂兽区，打人
                if mineInfo and myConsortiaId ~= "" and myConsortiaId == mineInfo.consortiaId then
                    -- 狩猎同宗门的魂兽区
                    app:alert({content = "##d是否消耗##e"..(remote.silverMine:getOccupyPriceAtPM() + remote.silverMine:getOccupyPriceForFriend()).."钻##d狩猎新魂兽区？（狩猎##e同宗门魂兽区##d需消耗##e"..remote.silverMine:getOccupyPriceForFriend().."钻##d，##e0点至6点##d狩猎需消耗##e"..remote.silverMine:getOccupyPriceAtPM().."钻##d）", title = "系统提示", 
                            callback = function(state)
                                if state == ALERT_TYPE.CONFIRM then
                                    self:_checkForFightStartRequest()
                                elseif state == ALERT_TYPE.CANCEL then
                                    remote.silverMine:removeLock()
                                end
                            end, isAnimation = true, colorful = true}, true, true)
                else
                    -- 狩猎非同宗门的魂兽区
                    app:alert({content = "##e每日0点至6点##d狩猎他人魂兽区需要额外消耗##e"..remote.silverMine:getOccupyPriceAtPM().."钻石##d，是否继续？", title = "系统提示", 
                            callback = function(state)
                                if state == ALERT_TYPE.CONFIRM then
                                    self:_checkForFightStartRequest()
                                elseif state == ALERT_TYPE.CANCEL then
                                    remote.silverMine:removeLock()
                                end
                            end, isAnimation = true, colorful = true}, true, true)    
                end
            end
        end
    else
        if myOccupy and table.nums(myOccupy) > 0 then
            -- 白天，自己有魂兽区，打怪
            -- 白天，自己有魂兽区，打人
            if mineInfo and myConsortiaId ~= "" and myConsortiaId == mineInfo.consortiaId then
                -- 狩猎同宗门的魂兽区(打怪肯定是非同宗门的)
                app:alert({content = "##d是否放弃当前已狩猎的魂兽区并结算奖励？（狩猎##e同宗门的魂兽区##d需额外消耗##e"..remote.silverMine:getOccupyPriceForFriend().."钻##d）", title = "系统提示", 
                        callback = function(state)
                            if state == ALERT_TYPE.CONFIRM then
                                self:_checkForFightStartRequest()
                            elseif state == ALERT_TYPE.CANCEL then
                                remote.silverMine:removeLock()
                            end
                        end, isAnimation = true, colorful = true}, true, true)  
            else
                -- 狩猎非同宗门的魂兽区
                app:alert({content = "当前已有魂兽区，当您成功狩猎新魂兽区后将放弃并结算现有的魂兽区，是否继续狩猎？", title = "系统提示", 
                        callback = function(state)
                            if state == ALERT_TYPE.CONFIRM then
                                self:_checkForFightStartRequest()
                            elseif state == ALERT_TYPE.CANCEL then
                                remote.silverMine:removeLock()
                            end
                        end, isAnimation = true}, true, true)  
            end
        else
            -- 白天，自己没魂兽区，打怪
            -- 白天，自己没魂兽区，打人
            if mineInfo and myConsortiaId ~= "" and myConsortiaId == mineInfo.consortiaId then
                -- 狩猎同宗门的魂兽区(打怪肯定是非同宗门的)
                app:alert({content = "##d狩猎##e同宗门的魂兽区##d需额外消耗##e"..remote.silverMine:getOccupyPriceForFriend().."钻##d，是否狩猎？", title = "系统提示", 
                        callback = function(state)
                            if state == ALERT_TYPE.CONFIRM then
                                self:_checkForFightStartRequest()
                            elseif state == ALERT_TYPE.CANCEL then
                                remote.silverMine:removeLock()
                            end
                        end, isAnimation = true, colorful = true}, true, true)  
            else
                -- 狩猎非同宗门的魂兽区
                self:_checkForFightStartRequest()
            end
        end
    end
end

function QUIDialogSilverMineMineInfo:_checkForFightStartRequest()
    remote.silverMine:silvermineCheckForFightStartRequest(self._mineId, function(response)
        local data = response.gfStartCheckResponse.silverMineFightStartCheckResponse.fightLock
        if data and table.nums(data) > 0 then
            -- print("[Kumo] QUIDialogSilverMineMineInfo:_onTriggerOccupy() ", data.lockUserId, remote.user:getPropForKey("userId"))
            if data.lockUserId and data.lockUserId == remote.user:getPropForKey("userId") then
                -- 可以挑战
                local mineId = self._mineId
                local mines = remote.plunder:getMines()
                local occupyInfo = remote.silverMine:getMineOccupyInfoByMineID(mineId)
                self:_gotoTeamArrangement(self._mineId, occupyInfo and occupyInfo.ownerId)
            else
                app.tip:floatTip("魂师大人，玩家"..data.lockUserName.."正在挑战")
            end
        end
    end)
end

function QUIDialogSilverMineMineInfo:viewAnimationOutHandler()
    self:removeSelfFromParent()
end

function QUIDialogSilverMineMineInfo:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSilverMineMineInfo:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_cancel")
    self:playEffectOut()
end

function QUIDialogSilverMineMineInfo:removeSelfFromParent()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSilverMineMineInfo:_updateSilverMineHandler( event )
    if event.name == remote.silverMine.MY_INFO_UPDATE then
        if self._type ~= LORD_TYPE.SELF then
            -- 如果看别人魂兽区的时候，不可能变更狩猎者为“我”，所以，只需更新下我狩猎等级变化带来的变化
            self:_updateInfo()
        else
            -- 被人打的话，可能会变更狩猎者
            self:_checkType()
            -- 更新时间、总产量、奖励或事件
            if self._type ~= LORD_TYPE.SELF then
                self:_updateByType(true)
                self:_initInfo()
            end
            self:_updateInfo()
            self:_updateShow()
        end
    elseif event.name == remote.silverMine.CAVE_UPDATE then
        self:_initInfo()
        self:_updateInfo()
    end
end

function QUIDialogSilverMineMineInfo:_request()
    local caveId = remote.silverMine:getCaveIdByMineId( self._mineId )
    remote.silverMine:silvermineGetCaveInfoRequest(caveId)

    if self._type == LORD_TYPE.SELF then
        remote.silverMine:silvermineGetMyInfoRequest()
    end

    if self._tab == SHOW_OPPORTUNITY then
        local myOccupy = remote.silverMine:getMyOccupy()
        if myOccupy and myOccupy.occupyId then
            remote.silverMine:silvermineGetMiningEventListRequest(self._mineId, myOccupy.occupyId, self:safeHandler(function( response )
                self._miningEvents = response.silverMineGetMiningEventListResponse.miningEvents 
                self:_showOpportunity()
            end))
        end
    end

    local lordType = remote.silverMine:getLordTypeByMineId( self._mineId )
    if lordType == LORD_TYPE.NORMAL or lordType == LORD_TYPE.SOCIETY then
        remote.silverMine:silverMineGetMineOccupyInfoRequest( self._mineId, self:safeHandler(function( response )
            self:_updateInfo()
        end))
    end
end

function QUIDialogSilverMineMineInfo:_checkType()
    self._type = remote.silverMine:getLordTypeByMineId( self._mineId )
end

function QUIDialogSilverMineMineInfo:_updateByType( isGoOn )
    if self._type == LORD_TYPE.SELF then
        self._tab = SHOW_AWARD
        self._ccbOwner.node_other:setVisible(false)
        self._ccbOwner.node_self:setVisible(true)
    else
        self._tab = SHOW_AWARD
        self._ccbOwner.node_other:setVisible(true)
        self._ccbOwner.node_self:setVisible(false)
    end

    if isGoOn then
        -- self:_initPageSwipe()
        self:initScroll()
    end
end

function QUIDialogSilverMineMineInfo:initScroll( ... )
    if self._scrollContain then
        self._scrollContain:disappear()
        self._scrollContain = nil
    end
    if self._type == LORD_TYPE.SELF then
        self._scrollWidth = self._ccbOwner.sheet_self_layout:getContentSize().width
        self._scrollHeight = self._ccbOwner.sheet_self_layout:getContentSize().height
        local scrollOptions = {}
        scrollOptions.sheet = self._ccbOwner.sheet_self
        scrollOptions.sheet_layout = self._ccbOwner.sheet_self_layout
        if self._tab == SHOW_AWARD then
            scrollOptions.direction = QScrollContain.directionX
        else
            scrollOptions.direction = QScrollContain.directionY
        end
        scrollOptions.touchLayerOffsetY = 10
        scrollOptions.touchLayerOffsetY = -self._ccbOwner.sheet_self_layout:getContentSize().height
        self._scrollContain = QScrollContain.new(scrollOptions)

        -- if self._tab == SHOW_AWARD then
        --     self._scrollContain:setHorizontalBounce(true)
        --     self._scrollContain:setVerticalBounce(false)
        -- else
        --     self._scrollContain:setHorizontalBounce(false)
        --     self._scrollContain:setVerticalBounce(true)
        -- end
    else
        self._scrollWidth = self._ccbOwner.sheet_other_layout:getContentSize().width
        self._scrollHeight = self._ccbOwner.sheet_other_layout:getContentSize().height
        local scrollOptions = {}
        scrollOptions.sheet = self._ccbOwner.sheet_other
        scrollOptions.sheet_layout = self._ccbOwner.sheet_other_layout
        scrollOptions.direction = QScrollContain.directionX
        scrollOptions.touchLayerOffsetY = 10
        scrollOptions.touchLayerOffsetY = -self._ccbOwner.sheet_self_layout:getContentSize().height
        self._scrollContain = QScrollContain.new(scrollOptions)
        self._scrollContain:setIsCheckAtMove(true)
        -- self._scrollContain:setHorizontalBounce(false)
        -- self._scrollContain:setVerticalBounce(false)
    end
end

-- function QUIDialogSilverMineMineInfo:_initPageSwipe()
--     -- Initialize achievement part scroll
--     if self._scrollView then
--         self._scrollView:clear()
--         self._scrollView = nil
--     end

--     if self._type == LORD_TYPE.SELF then
--         self._scrollWidth = self._ccbOwner.sheet_self_layout:getContentSize().width
--         self._scrollHeight = self._ccbOwner.sheet_self_layout:getContentSize().height
--         self._scrollView = QScrollView.new(self._ccbOwner.sheet_self, CCSize(self._scrollWidth, self._scrollHeight), {sensitiveDistance = 10})
--         if self._tab == SHOW_AWARD then
--             -- print("[Kumo] self._tab == SHOW_AWARD")
--             self._scrollView:setHorizontalBounce(true)
--             self._scrollView:setVerticalBounce(false)
--         else
--             -- print("[Kumo] self._tab ~= SHOW_AWARD")
--             self._scrollView:setHorizontalBounce(false)
--             self._scrollView:setVerticalBounce(true)
--         end
--     else
--         -- print("[Kumo] self._type ~= LORD_TYPE.SELF")
--         self._scrollWidth = self._ccbOwner.sheet_other_layout:getContentSize().width
--         self._scrollHeight = self._ccbOwner.sheet_other_layout:getContentSize().height
--         self._scrollView = QScrollView.new(self._ccbOwner.sheet_other, CCSize(self._scrollWidth, self._scrollHeight), {sensitiveDistance = 10, isNoTouch = true})
--         self._scrollView:setHorizontalBounce(false)
--         self._scrollView:setVerticalBounce(false)
--     end
    
--     self._scrollViewProxy = cc.EventProxy.new(self._scrollView)
--     self._scrollViewProxy:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
--     self._scrollViewProxy:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
--     self._scrollViewProxy:addEventListener(QScrollView.GESTURE_END, handler(self, self._onScrollViewEnd))

--     self._scrollView:setGradient(false)
-- end

-- function QUIDialogSilverMineMineInfo:_onScrollViewBegan( ... )
--     self._isMoving = false
-- end

-- function QUIDialogSilverMineMineInfo:_onScrollViewMoving( ... )
--     self._isMoving = true
-- end

-- function QUIDialogSilverMineMineInfo:_onScrollViewEnd( ... )
--     self._scrollViewScheduler = scheduler.performWithDelayGlobal(function() 
--         self._isMoving = false 
--         if self._scrollViewScheduler then
--             scheduler.unscheduleGlobal(self._scrollViewScheduler)
--             self._scrollViewScheduler = nil
--         end
--     end, 0.5)
-- end

function QUIDialogSilverMineMineInfo:_initInfo()
    local name = remote.silverMine:getMineCNNameByQuality( self._mineConfig.mine_quality )

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
    end

    if self._type == LORD_TYPE.SELF then
        -- self._mineConfig.mine_name.." - "..
        self._ccbOwner.frame_tf_title:setString(name)
        self._ccbOwner.node_self_icon:addChild(self._monsterAvatar) 
    else
        -- self._mineConfig.mine_name.." - "..
        self._ccbOwner.frame_tf_title:setString(name)
        self._ccbOwner.tf_explain:setString("狩猎"..name.."几率获得：")
        self._ccbOwner.node_other_icon:addChild(self._monsterAvatar) 
    end

    self:_updateInfo()
    self:_updateShow()
end

function QUIDialogSilverMineMineInfo:_updateInfo()
    local lordType = remote.silverMine:getLordTypeByMineId( self._mineId )
    if lordType == LORD_TYPE.BOSS then
        local bossInfo = remote.silverMine:getNPCInfoById( self._mineConfig.dungeon_monster_id )
        self._ccbOwner.tf_other_name:setString(bossInfo.name)
        self._ccbOwner.tf_other_time:setString("00:00:00")
        self._ccbOwner.btn_info:setVisible(false)
        self._ccbOwner.node_token_price:setVisible(false)

        local moneyOutput, silverMineMoneyOutput = remote.silverMine:getOutPutByMineId( self._mineId, remote.silverMine:getMyConsortiaId(), nil, nil, true )
        self._ccbOwner.tf_other_money_output:setString(math.floor(moneyOutput))
        self._ccbOwner.tf_other_silvermineMoney_output:setString(math.floor(silverMineMoneyOutput))

        local num, unit = q.convertLargerNumber(math.floor(moneyOutput) * 48)
        self._ccbOwner.tf_other_money_count:setString(num..(unit or ""))
        num, unit = q.convertLargerNumber(math.floor(silverMineMoneyOutput) * 48)
        self._ccbOwner.tf_other_silvermineMoney_count:setString(num..(unit or ""))
        self._ccbOwner.tf_other_assist:setString("协助者0/3：")
    else
        local occupy = remote.silverMine:getMineOccupyInfoByMineID( self._mineId )

        if self._type == LORD_TYPE.SELF then
            -- 我

            self._ccbOwner.tf_self_name:setString(occupy.ownerName)

            local price = remote.silverMine:getExtendOccupyPrice()
            if not price then
                --不能再延长狩猎了
                self._ccbOwner.tf_token_price:setString( "" )
                self._ccbOwner.sp_token:setVisible(false)
                makeNodeFromNormalToGray(self._ccbOwner.node_extend_occupy)
                self._ccbOwner.tf_extend_occupy:disableOutline()
            else
                self._ccbOwner.tf_token_price:setString( price )
                self._ccbOwner.sp_token:setVisible(true)
                makeNodeFromGrayToNormal(self._ccbOwner.node_extend_occupy)
                self._ccbOwner.tf_extend_occupy:enableOutline()
            end

            local moneyOutput, silverMineMoneyOutput = remote.silverMine:getOutPutByMineId( self._mineId, nil, nil, nil, true )
            self._ccbOwner.tf_self_money_output:setString(math.floor(moneyOutput))
            self._ccbOwner.tf_self_silvermineMoney_output:setString(math.floor(silverMineMoneyOutput))

            local myOccupy = remote.silverMine:getMyOccupy()
            local awards = ""
            -- QPrintTable(myOccupy)
            if myOccupy then
                if myOccupy.occupyAward then 
                    awards = myOccupy.occupyAward
                    if myOccupy.exOccupyAward then
                        awards = awards..";"..myOccupy.exOccupyAward
                    end
                end
            end
            local awardTbl = self:_analyseAwards(awards)
            if awardTbl and table.nums(awardTbl) > 0 then
                local sm = 0
                local m = 0
                for _, award in pairs(awardTbl) do
                    local id, type, count = remote.silverMine:getItemBoxParaMetet(award)
                    -- local num, unit = q.convertLargerNumber(count)
                    if type == "silvermineMoney" or type == "silvermine_money" or type == "SILVERMINE_MONEY" then
                        sm = sm + count
                        -- self._ccbOwner.tf_self_silvermineMoney_count:setString(num..(unit or ""))
                    elseif type == "money" or type == "MONEY" then
                        m = m + count
                        -- self._ccbOwner.tf_self_money_count:setString(num..(unit or ""))
                    end
                end
                local num, unit = q.convertLargerNumber(sm)
                self._ccbOwner.tf_self_silvermineMoney_count:setString(num..(unit or ""))
                num, unit = q.convertLargerNumber(m)
                self._ccbOwner.tf_self_money_count:setString(num..(unit or ""))
            else
                self._ccbOwner.tf_self_silvermineMoney_count:setString("0")
                self._ccbOwner.tf_self_money_count:setString("0")
            end
            --协助信息
            self._ccbOwner.tf_self_assist:setString(string.format("协助者%d/%d：", #(occupy.assistUserInfo or {}), remote.silverMine:getAssistTotalCount()))
            local assistInfo = occupy.assistUserInfo or {}
            for i=1,remote.silverMine:getAssistTotalCount() do
                local tf = self._ccbOwner["tf_self_assister"..i]
                if assistInfo[i] ~= nil then
                    tf:setString(assistInfo[i].nickname)
                else
                    tf:setString("当前可协助")
                end
            end
        else
            -- 其他玩家

            self._ccbOwner.tf_other_name:setString(occupy.ownerName)
            local width = self._ccbOwner.tf_other_name:getContentSize().width
            local x = self._ccbOwner.tf_other_name:getPositionX()
            self._ccbOwner.btn_info:setPositionX( x + width + 30 )
            self._ccbOwner.btn_info:setVisible(true)

            local level = nil
            local ownerConsortiaId = nil
            local otherPlayerSilverMine = remote.silverMine:getOtherPlayerSilverMine()
            local otherPlayerOccupy = remote.silverMine:getOtherPlayerOccupy()
            if otherPlayerSilverMine then
                level = otherPlayerSilverMine.miningLv
            end
            if otherPlayerOccupy then
                ownerConsortiaId = otherPlayerOccupy.consortiaId
            end
            local moneyOutput, silverMineMoneyOutput = remote.silverMine:getOutPutByMineId( self._mineId, nil, level, ownerConsortiaId )
            self._ccbOwner.tf_other_money_output:setString(math.floor(moneyOutput))
            self._ccbOwner.tf_other_silvermineMoney_output:setString(math.floor(silverMineMoneyOutput))

            local num, unit = q.convertLargerNumber(math.floor(moneyOutput) * 48)
            self._ccbOwner.tf_other_money_count:setString(num..(unit or ""))
            num, unit = q.convertLargerNumber(math.floor(silverMineMoneyOutput) * 48)
            self._ccbOwner.tf_other_silvermineMoney_count:setString(num..(unit or ""))
        end

        -- 和时间有关的数据
        self:_updateTime()
        if self._scheduler then
            scheduler.unscheduleGlobal(self._scheduler)
            self._scheduler = nil
        end
        self._scheduler = scheduler.scheduleGlobal(function ()
            self:_updateTime()
        end, 1)
        --协助信息
        self._ccbOwner.tf_other_assist:setString(string.format("协助者%d/%d：", #(occupy.assistUserInfo or {}), remote.silverMine:getAssistTotalCount()))
        local assistInfo = occupy.assistUserInfo or {}
        for i=1,remote.silverMine:getAssistTotalCount() do
            local tf = self._ccbOwner["tf_other_assister"..i]
            if assistInfo[i] ~= nil then
                tf:setString(assistInfo[i].nickname)
            else
                tf:setString("当前可协助")
            end
        end
    end
end

function QUIDialogSilverMineMineInfo:_updateShow()
    if self._tab == SHOW_AWARD then
        self._ccbOwner.btn_award:setHighlighted(true)
        self._ccbOwner.btn_opportunity:setHighlighted(false)
        if self._scrollContain then
            self._scrollContain:setDirection(QScrollContain.directionX)
        end
        -- if self._scrollView then
        --     self._scrollView:setHorizontalBounce(true)
        --     self._scrollView:setVerticalBounce(false)
        -- end
        self:_showAwards()
    else
        self._ccbOwner.btn_award:setHighlighted(false)
        self._ccbOwner.btn_opportunity:setHighlighted(true)
        if self._scrollContain then
            self._scrollContain:setDirection(QScrollContain.directionY)
        end
        -- if self._scrollView then
        --     self._scrollView:setHorizontalBounce(false)
        --     self._scrollView:setVerticalBounce(true)
        -- end
        self:_showOpportunity()
    end
end

function QUIDialogSilverMineMineInfo:_showAwards()
    -- self._scrollView:clear()
    self._scrollContain:clear()
    self._totalAwardWidth = 0

    local awards = ""
    local row = 0
    local width

    if self._type == LORD_TYPE.SELF then
        local myOccupy = remote.silverMine:getMyOccupy()
        if myOccupy and myOccupy.miningAward then
            awards = myOccupy.miningAward
        end
    else
        if self._mineConfig and table.nums(self._mineConfig) > 0 then
            awards = self._mineConfig.mine_award_display
        end
    end

    local awardTbl = self:_analyseAwards(awards)
    -- print(awards)
    -- QPrintTable(awardTbl)
    if awardTbl and table.nums(awardTbl) > 0 then
        for _, award in pairs(awardTbl) do
            local id, type, count = remote.silverMine:getItemBoxParaMetet(award)
            if not id and type == "" and count == 0 then break end
            local item = nil
            if type == ITEM_TYPE.GEMSTONE_PIECE then
                item = QUIWidgetGemStonePieceBox.new()
                if count == 0 then
                    item:setGoodsInfo(id, type, count, false, false)
                else
                    item:setGoodsInfo(id, type, count, true, false)
                end
                
                item:setPromptIsOpen(true)
            else
                item = QUIWidgetItemsBox.new()
                item:setGoodsInfo(id, type, count)
                item:setPromptIsOpen(true)
            end
            -- self._scrollView:addItemBox(item)
            self._scrollContain:addChild(item)
            width = item:getContentSize().width
                
            local positionX = ITEM_ROWDISTANCE * (row + 1) + width / 2 + width * row
            local positionY = -ITEM_LINEDISTANCE
            item:setPosition(ccp(positionX, positionY))

            row = row + 1

            self._totalAwardWidth = self._totalAwardWidth + ITEM_ROWDISTANCE + width
        end
        self._totalAwardWidth = self._totalAwardWidth + ITEM_ROWDISTANCE
        -- self._scrollView:setRect(0, -self._scrollHeight, 0, self._totalAwardWidth)
        self._scrollContain:setRect(0, -self._scrollHeight, 0, self._totalAwardWidth)
    end
end

function QUIDialogSilverMineMineInfo:_analyseAwards( awards )
    if awards == "" then return nil end

    local tbl = string.split(awards, ";")
    if tbl and table.nums(tbl) > 0 then
        local awardTbl = {}
        awardTbl = tbl
        -- QPrintTable(awardTbl)
        remote.silverMine:arrangeByQuality( awardTbl )
        return awardTbl
    end
    return nil
end

function QUIDialogSilverMineMineInfo:_showOpportunity()
    -- self._scrollView:clear()
    self._scrollContain:clear()
    self._totalThingHeight = 0

    if not self._miningEvents or table.nums(self._miningEvents) == 0 then return end

    table.sort(self._miningEvents, function ( a, b )
        -- return a.miningSec < b.miningSec
        return a.miningAt < b.miningAt
    end)
    -- QPrintTable(self._miningEvents)
    local line = 0
    for _, thing in pairs(self._miningEvents) do
        local thingWidget = QUIWidgetSilverMineOpportunity.new({thing = thing, width = self._scrollWidth, height = self._scrollHeight})
        -- self._scrollView:addItemBox(thingWidget)
        self._scrollContain:addChild(thingWidget)
        local height = thingWidget:getHeight()
        -- print("[Kumo] height : ", height)
        local positionX = THING_ROWDISTANCE
        local positionY = -(THING_LINEDISTANCE * line + height * line )
        thingWidget:setPosition(ccp(positionX, positionY))

        line = line + 1

        self._totalThingHeight = self._totalThingHeight + THING_LINEDISTANCE + height
    end
    self._totalThingHeight = self._totalThingHeight + THING_LINEDISTANCE
    -- self._scrollView:setRect(0, -self._totalThingHeight, 0, self._scrollWidth)
    self._scrollContain:setRect(0, -self._totalThingHeight, 0, self._scrollWidth)
end

function QUIDialogSilverMineMineInfo:_updateTime()
    local isOvertime = false
    local timeStr = ""

    if self._type == LORD_TYPE.SELF then
        isOvertime, timeStr = remote.silverMine:updateTime( true )
        self._isOvertime = isOvertime
        if self._isOvertime then
            self._ccbOwner.tf_self_time:setString("结算中...")
        else
            self._ccbOwner.tf_self_time:setString(timeStr)
        end
    else
        local mineInfo = remote.silverMine:getMineOccupyInfoByMineID( self._mineId )
        local myConsortiaId = remote.silverMine:getMyConsortiaId()
        local price = 0
        if self._isInTheTime() then
            price = price + remote.silverMine:getOccupyPriceAtPM()
        end
        if mineInfo and myConsortiaId ~= "" and myConsortiaId == mineInfo.consortiaId then
            price = price + remote.silverMine:getOccupyPriceForFriend()
        end

        if price > 0 then
            self._ccbOwner.node_token_price:setVisible(true)
            self._ccbOwner.tf_count_token_price:setString( price )
        else
            self._ccbOwner.node_token_price:setVisible(false)
        end

        isOvertime, timeStr = remote.silverMine:updateTime( false, self._mineId )
        -- print("[Kumo] QUIDialogSilverMineMineInfo:_updateTime() ", self._mineId, isOvertime, timeStr)
        self._isOvertime = isOvertime
        if self._isOvertime then
            self._ccbOwner.tf_other_time:setString("结算中...")
        else
            self._ccbOwner.tf_other_time:setString(timeStr)
        end
    end

    if self._isOvertime then
        if self._scheduler then
            scheduler.unscheduleGlobal(self._scheduler)
            self._scheduler = nil
        end
        return
    end
end

function QUIDialogSilverMineMineInfo:_gotoTeamArrangement(mineId, mineOwnerId)
    local silverMineArrangement = QSilverMineArrangement.new({mineId = mineId, mineOwnerId = mineOwnerId})
    -- silverMineArrangement:setIsLocal(true)
    app:getNavigationManager():pushViewController(app.mainUILayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogTeamArrangement",
        options = {arrangement = silverMineArrangement}})
end

-- 24:00~6:00
function QUIDialogSilverMineMineInfo:_isInTheTime()
    local hour = tonumber(q.date("%H", q.serverTime()))
    -- print("[Kumo] QUIDialogSilverMineMineInfo:_isInTheTime() hour : ", hour)
    if hour >= 24 or hour < 6 then
        return true
    end
    return false
end

return QUIDialogSilverMineMineInfo
