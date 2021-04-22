--
-- Author: Kumo
-- Date: Tue July 12 18:30:36 2016
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilverMineAwardAndRecord = class("QUIDialogSilverMineAwardAndRecord", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIGestureRecognizer = import("..QUIGestureRecognizer")
local QUIViewController = import("..QUIViewController")
local QScrollView = import("...views.QScrollView") 
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetSilverRegionalRecord = import("..widgets.QUIWidgetSilverRegionalRecord")
local QUIWidgetSilverPersonalRecord = import("..widgets.QUIWidgetSilverPersonalRecord")
local QUIWidgetSilverMineAward = import("..widgets.QUIWidgetSilverMineAward")
local QListView = import("...views.QListView")

QUIDialogSilverMineAwardAndRecord.AWARD = 1
QUIDialogSilverMineAwardAndRecord.PERSONAL_RECORD = 2
QUIDialogSilverMineAwardAndRecord.REGIONAL_RECORD = 3

local AWARD_ROWDISTANCE = 0 
local AWARD_LINEDISTANCE = 5

function QUIDialogSilverMineAwardAndRecord:ctor(options)
    local ccbFile = "ccb/Dialog_SilverMine_grzb.ccbi"
    local callBacks = {
        {ccbCallbackName = "onTriggerClose", callback = handler(self, QUIDialogSilverMineAwardAndRecord._onTriggerClose)},
        {ccbCallbackName = "onTriggerOneGet", callback = handler(self, QUIDialogSilverMineAwardAndRecord._onTriggerOneGet)},
        {ccbCallbackName = "onTriggerAward", callback = handler(self, QUIDialogSilverMineAwardAndRecord._onTriggerAward)},
        {ccbCallbackName = "onTriggerPersonalRecord", callback = handler(self, QUIDialogSilverMineAwardAndRecord._onTriggerPersonalRecord)},
        {ccbCallbackName = "onTriggerRegionalRecord", callback = handler(self, QUIDialogSilverMineAwardAndRecord._onTriggerRegionalRecord)},
    }
    QUIDialogSilverMineAwardAndRecord.super.ctor(self,ccbFile,callBacks,options)
    self.isAnimation = true --是否动画显示

    self._type = options.tab or QUIDialogSilverMineAwardAndRecord.AWARD
    self._awardList = {}
    self._totalAwardHeight = 0
    self._caveRegion = options.caveRegion or SILVERMINEWAR_TYPE.SENIOR

    self._bgSize = self._ccbOwner.s9s_bg:getContentSize()
    self._ccbOwner.node_no:setVisible(false)
    self:_selectType()
end

function QUIDialogSilverMineAwardAndRecord:viewDidAppear()
    QUIDialogSilverMineAwardAndRecord.super.viewDidAppear(self)
end

function QUIDialogSilverMineAwardAndRecord:viewAnimationInHandler()
    self:_request()
end

function QUIDialogSilverMineAwardAndRecord:viewWillDisappear()
    QUIDialogSilverMineAwardAndRecord.super.viewWillDisappear(self)

    self._loadAgainstRecordImp = function ( ... ) end
    self._loadRegionalAgainstRecordImp = function ( ... ) end

    if self._delayScheduler then
        scheduler.unscheduleGlobal(self._delayScheduler)
        self._delayScheduler = nil
    end
end

function QUIDialogSilverMineAwardAndRecord:getContentListView()
    return self._contentListView
end

function QUIDialogSilverMineAwardAndRecord:_resetBtns()
    self._ccbOwner.btn_award:setEnabled(false)
    self._ccbOwner.btn_award:setHighlighted(false)
    self._ccbOwner.btn_personalRecord:setEnabled(false)
    self._ccbOwner.btn_personalRecord:setHighlighted(false)
    self._ccbOwner.btn_regionalRecord:setEnabled(false)
    self._ccbOwner.btn_regionalRecord:setHighlighted(false)

    self._ccbOwner.style_node_btn_get:setVisible(false)
    self._ccbOwner.award_tips:setVisible(false)
    self._ccbOwner.personalRecord_tips:setVisible(false)

    self._ccbOwner.s9s_bg:setPreferredSize(CCSize(self._bgSize.width, self._bgSize.height))

    self._ccbOwner.node_hands:setVisible(false)
end

function QUIDialogSilverMineAwardAndRecord:_request( delayTime )
    if self._type == QUIDialogSilverMineAwardAndRecord.AWARD then
        if delayTime and tonumber(delayTime) then
            if self._delayScheduler then
                scheduler.unscheduleGlobal(self._delayScheduler)
                self._delayScheduler = nil
            end
            self._delayScheduler = scheduler.performWithDelayGlobal(function()
                    remote.silverMine:silvermineShowOccupyAwardListRequest(self:safeHandler(function( response )
                            local data = response.silverMineShowOccupyAwardListResponse
                            if data then
                                self._awardList = data.awards or {}
                                self:_updateRedTips(true)
                                self:_initAwardPageSwipe()
                            end
                        end))
                end, tonumber(delayTime))
        else
            remote.silverMine:silvermineShowOccupyAwardListRequest(self:safeHandler(function( response )
                    local data = response.silverMineShowOccupyAwardListResponse
                    if data then
                        self._awardList = data.awards or {}
                        self:_updateRedTips(true)
                        self:_initAwardPageSwipe()
                    end
                end))
        end
    end
end

function QUIDialogSilverMineAwardAndRecord:_selectType( isGoOn )
    self:_resetBtns()
    self:_updateRedTips()

    if self._type == QUIDialogSilverMineAwardAndRecord.AWARD then
        -- 初始化页面滑动框和遮罩层
        self._achieveBox = {}
        self._receivedChapterIds = {}
        self._ccbOwner.btn_award:setHighlighted(true)
        self._ccbOwner.btn_personalRecord:setEnabled(true)
        self._ccbOwner.btn_regionalRecord:setEnabled(true)
        self._ccbOwner.style_node_btn_get:setVisible(true)
        -- self._ccbOwner.s9s_bg:setPreferredSize(CCSize(self._bgSize.width, self._bgSize.height - 130))
        if isGoOn then
            self:_request()
        end
    elseif self._type == QUIDialogSilverMineAwardAndRecord.PERSONAL_RECORD then
        if self._delayScheduler then
            scheduler.unscheduleGlobal(self._delayScheduler)
            self._delayScheduler = nil
        end
        if self._contentListView then
            self._contentListView:clear(true)
        end
        self._ccbOwner.btn_personalRecord:setHighlighted(true)
        self._ccbOwner.btn_award:setEnabled(true)
        self._ccbOwner.btn_regionalRecord:setEnabled(true)
    elseif self._type == QUIDialogSilverMineAwardAndRecord.REGIONAL_RECORD then
        if self._delayScheduler then
            scheduler.unscheduleGlobal(self._delayScheduler)
            self._delayScheduler = nil
        end
        if self._contentListView then
            self._contentListView:clear(true)
        end
        self._ccbOwner.btn_regionalRecord:setHighlighted(true)
        self._ccbOwner.btn_personalRecord:setEnabled(true)
        self._ccbOwner.btn_award:setEnabled(true)
    end
end

function QUIDialogSilverMineAwardAndRecord:_updateRedTips( isShowTips )
    if remote.silverMine:checkSilverMineAwardRedTip() then
        self._ccbOwner.award_tips:setVisible(true)
    else
        self._ccbOwner.award_tips:setVisible(false)
    end

    if remote.silverMine:getIsRecordRedTip() then
        self._ccbOwner.personalRecord_tips:setVisible(true)
    else
        self._ccbOwner.personalRecord_tips:setVisible(false)
    end

    if self._type == QUIDialogSilverMineAwardAndRecord.AWARD then
        -- print("#self._awardList = "..#self._awardList)
        -- print("isShowTips = "..tostring(isShowTips))
        if #self._awardList > 0 or not isShowTips then
            self._ccbOwner.node_no:setVisible(false)
        else
            self._ccbOwner.node_no:setVisible(true)
            self._ccbOwner.label_tips:setString("魂师大人，当前还没有奖励哦～")
        end

    elseif self._type == QUIDialogSilverMineAwardAndRecord.PERSONAL_RECORD then
        if (self._againstRecord and #self._againstRecord > 0) or not isShowTips then
            self._ccbOwner.node_no:setVisible(false)
        else
            self._ccbOwner.node_no:setVisible(true)
            self._ccbOwner.label_tips:setString("您在魂兽森林还未与任何人交手！")
        end
    elseif self._type == QUIDialogSilverMineAwardAndRecord.REGIONAL_RECORD then
        self._ccbOwner.node_no:setVisible(false)
    end

end

function QUIDialogSilverMineAwardAndRecord:_initAwardPageSwipe()
    if not self._contentListView then
        local cfg = {
            renderItemCallBack = handler(self,self._reandFunHandler),
            ignoreCanDrag = true,
            enableShadow = false,
            totalNumber = #self._awardList,
            spaceY = AWARD_LINEDISTANCE,
        }  
        self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
    else
        self._contentListView:reload({totalNumber = #self._awardList})
    end
end

function QUIDialogSilverMineAwardAndRecord:_reandFunHandler( list, index, info )
    local isCacheNode = true
    local masterConfig = self._awardList[index]
    local item = list:getItemFromCache()
    if not item then
        item = QUIWidgetSilverMineAward.new()
        isCacheNode = false
    end
    item:init( masterConfig, self ) 
    item:addEventListener(QUIWidgetSilverMineAward.EVENT_CLICK, handler(self, self._onEvent))
    item:addEventListener(QUIWidgetSilverMineAward.EVENT_INFO, handler(self, self._onEvent))
    info.item = item
    info.size = item:getContentSize()
    list:registerTouchHandler(index, "onTouchListView")
    list:registerBtnHandler(index, "btn_ready", "_onTriggerClick", nil, true)
    list:registerBtnHandler(index, "btn_info", "_onTriggerInfo", nil, true)

    return isCacheNode
end

function QUIDialogSilverMineAwardAndRecord:_onEvent(event)
    if event.name == QUIWidgetSilverMineAward.EVENT_CLICK then
        if event.state == QUIWidgetSilverMineAward.WEI_WAN_CHENG then
            return
        elseif event.state == QUIWidgetSilverMineAward.DONE then
            -- go on
        elseif event.state == QUIWidgetSilverMineAward.YI_LING_QU then
            return
        else
            return
        end

        app.sound:playSound("common_small")
        local tbl = {}
        local awards = {}
        table.insert(tbl, event.occupyId)
        for _, award in pairs(self._awardList) do
            if event.occupyId == award.occupyId then
                remote.items:analysisServerItem(award.miningAward, awards)
                remote.items:analysisServerItem(award.occupyAward, awards)
                remote.items:analysisServerItem(award.exOccupyAward, awards)
            end
        end
        self:_removeAward(event.occupyId)
        self:_sendGetOccupyAwardRequest(tbl, awards)
    elseif event.name == QUIWidgetSilverMineAward.EVENT_INFO then
        -- print("event.name == QUIWidgetSilverMineAward.EVENT_INFO", event.fightReportId)
        self._fightReportId = event.fightReportId
        self:_onTriggerPersonalRecord()
    end
end

function QUIDialogSilverMineAwardAndRecord:_sendGetOccupyAwardRequest(tbl, awards)
    if not tbl or table.nums(tbl) == 0 then return end

    remote.silverMine:silvermineGetOccupyAwardRequest(tbl, self:safeHandler(function (data)
        -- QPrintTable(data)
        -- local awards = {}
        -- if data and data.wallet then
        --     for key, value in pairs(data.wallet) do
        --         local count = value - (oldWallet[key] or 0)
        --         if count > 0 then
        --             table.insert(awards, {typeName = key, count = count})
        --         end
        --     end
        --     remote.user:update( data.wallet )
        -- end

        -- if data and data.items then 
        --     for _, value in pairs(data.items) do
        --         local id = value.type
        --         local itemType = remote.silverMine:getItemTypeById( id )
        --         local typeName = ""
        --         -- if itemType == ITEM_CONFIG_TYPE.GEMSTONE_PIECE then
        --         --     typeName = ITEM_TYPE.GEMSTONE_PIECE
        --         -- else
        --             typeName = ITEM_TYPE.ITEM
        --         -- end
        --         -- print("[Kumo] ", id, value.count, oldItem[tostring(id)])
        --         local count = value.count - (oldItem[tostring(id)] or 0)
        --         if count > 0 then
        --             table.insert(awards, {id = id, typeName = typeName, count = count})
        --         end
        --     end

        --     remote.items:setItems( data.items ) 
        -- end

        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert", 
            options = {awards = awards, callBack = function()
                if remote.silverMine:getIsLevelUp() then
                    remote.silverMine:setIsLevelUp( false )
                    app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogSilverMineLevelUp", options = {callBack = handler(self, self._request)}}, {isPopCurrentDialog = false} )
                else
                    self:_request()
                end
            end}}, {isPopCurrentDialog = false} )
        dialog:setTitle("恭喜您获得狩猎奖励")
    end))
end

function QUIDialogSilverMineAwardAndRecord:_removeAward(occupyId)
    for _, award in pairs(self._awardList) do
        if award.occupyId == occupyId then
            award.getAward = true
        end
    end
end

function QUIDialogSilverMineAwardAndRecord:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogSilverMineAwardAndRecord:_onTriggerClose(e)
    if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    app.sound:playSound("common_close")
    if remote.silverMine:isLock() then return end
    remote.silverMine:addLock()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
    if callback ~= nil then
        callback()
    end
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()
    if page.class.__cname == "QUIPageMainMenu" then
        printInfo("call QUIPageMainMenu function checkGuiad()")
        page:checkGuiad()
    end
end

function QUIDialogSilverMineAwardAndRecord:_onTriggerOneGet(e)
    if q.buttonEventShadow(e, self._ccbOwner.style_btn_get) == false then return end
    app.sound:playSound("common_small")
    if remote.silverMine:isLock() then return end
    remote.silverMine:addLock()
    -- QPrintTable(self._awardList)
    if self._awardList and table.nums(self._awardList) > 0 then
        local tbl = {}
        local awards = {}
        for _, award in pairs(self._awardList) do
            if not award.getAward then
                table.insert(tbl, award.occupyId)
                remote.items:analysisServerItem(award.miningAward, awards)
                remote.items:analysisServerItem(award.occupyAward, awards)
                remote.items:analysisServerItem(award.exOccupyAward, awards)
                self:_removeAward(award.occupyId)
            end
        end

        if table.nums(tbl) > 0 then
            self:_sendGetOccupyAwardRequest(tbl, awards)
            return
        end
    end
    remote.silverMine:removeLock()
    app.tip:floatTip("魂师大人，您没有奖励可以领取")
end

function QUIDialogSilverMineAwardAndRecord:_onTriggerAward(e)
    app.sound:playSound("common_small")
    self._fightReportId = nil
    -- if remote.silverMine:isLock() then return end
    -- remote.silverMine:addLock()
    -- if self._type == QUIDialogSilverMineAwardAndRecord.AWARD then return end
    self._type = QUIDialogSilverMineAwardAndRecord.AWARD
    self:_selectType(true)
    if self._personalRecordScrollView then
        self._personalRecordScrollView:setVisible(false)
    end
    if self._regionalRecordScrollView then
        -- self._regionalRecordScrollView:clear()
        self._regionalRecordScrollView:setVisible(false)
        -- self._regionalRecordScrollView = nil
    end
    if self._scrollView then
        self._scrollView:setVisible(true)
        return
    end
end

function QUIDialogSilverMineAwardAndRecord:_onScrollViewMoving()
    self._fightReportId = nil
    self._ccbOwner.node_hands:setVisible(false)
end

function QUIDialogSilverMineAwardAndRecord:_onScrollViewBegan()
    self._fightReportId = nil
    self._ccbOwner.node_hands:setVisible(false)
end

function QUIDialogSilverMineAwardAndRecord:_onTriggerPersonalRecord(e)
    app.sound:playSound("common_small")
    -- if remote.silverMine:isLock() then return end
    -- remote.silverMine:addLock()
    -- if self._type == QUIDialogSilverMineAwardAndRecord.PERSONAL_RECORD then return end
    self._type = QUIDialogSilverMineAwardAndRecord.PERSONAL_RECORD
    remote.silverMine:setIsRecordRedTip(false)
    self:_selectType()
    if self._scrollView then
        self._scrollView:setVisible(false)
    end
    if self._regionalRecordScrollView then
        self._regionalRecordScrollView:setVisible(false)
    end
    if self._personalRecordScrollView then
        self._personalRecordScrollView:setVisible(true)
        self._personalRecordScrollView:clear()
        -- return
    end
    local size = self._ccbOwner.sheet_layout:getContentSize()
    self._personalRecordScrollView = QScrollView.new(self._ccbOwner.sheet, size, {bufferMode = 1, sensitiveDistance = 10})
    self._personalRecordScrollView:addEventListener(QScrollView.GESTURE_MOVING, handler(self, self._onScrollViewMoving))
    self._personalRecordScrollView:addEventListener(QScrollView.GESTURE_BEGAN, handler(self, self._onScrollViewBegan))
    self._personalRecordScrollView:setVerticalBounce(true)

    self._totalHeightPersonal = 10

    self._loadAgainstRecordImp = function (data)
        self._againstRecord = clone(data.silverMineGetFightReportListResponse.reports or {})
        local _filteredRecord = {}
        for _, record in ipairs(self._againstRecord) do
            if record.fighter2 then
                _filteredRecord[#_filteredRecord + 1] = record
            end
        end
        self._againstRecord = _filteredRecord

        if self._againstRecord ~= nil then
            local recordsWithTime = {}
            local recordsWithoutTime = {}
            for _, record in ipairs(self._againstRecord) do
                if record.fighter1.lastFightAt then
                    recordsWithTime[#recordsWithTime + 1] = record
                else
                    recordsWithoutTime[#recordsWithoutTime + 1] = record
                end
            end
            table.sort(recordsWithTime, function (x, y)
                return x.fighter1.lastFightAt > y.fighter1.lastFightAt
            end)
            self._againstRecord = {}
            table.mergeForArray(self._againstRecord, recordsWithTime)
            table.mergeForArray(self._againstRecord, recordsWithoutTime)

            local index = 0
            local isNeedTips = true
            -- QPrintTable(self._againstRecord)
            for _, v in pairs(self._againstRecord) do
                local me = v.fighter1
                local rival = v.fighter2
                local result = v.success

                -- need to know which fighter is myself
                if me.userId ~= remote.user.userId then
                    me, rival = rival, me
                    result = not result
                end

                local widgetPersonalRecord = QUIWidgetSilverPersonalRecord.new(
                    {parent = self, userId = rival.userId, nickName = rival.name, level = rival.level, result = result, 
                    rankChanged = 0, avatar = rival.avatar, time = v.fighter1.lastFightAt,
                    type = REPORT_TYPE.SILVERMINE, replay = v.fightReportId, vip = rival.vip, mineId = v.mineId}) 

                widgetPersonalRecord:setPosition(ccp(0, -index * (widgetPersonalRecord:getContentSize().height + widgetPersonalRecord.GAP)))
                self._personalRecordScrollView:addItemBox(widgetPersonalRecord)
                self._totalHeightPersonal = self._totalHeightPersonal + widgetPersonalRecord:getContentSize().height + widgetPersonalRecord.GAP
                index = index + 1

                self._personalRecordScrollView:setRect(0, -self._totalHeightPersonal, 0, self._ccbOwner.sheet_layout:getContentSize().width)

                -- print("QUIDialogSilverMineAwardAndRecord:_onTriggerPersonalRecord() ", index, self._fightReportId, v.fightReportId)
                if self._fightReportId then
                    if tostring(self._fightReportId) == tostring(v.fightReportId) then
                        isNeedTips = false
                        if index > 3 then
                            self._personalRecordScrollView:moveTo(0, index * (widgetPersonalRecord:getContentSize().height + widgetPersonalRecord.GAP) + 10)
                        end
                        -- widgetPersonalRecord:showSelected()
                        local x, y = widgetPersonalRecord:getPosition()
                        self._ccbOwner.node_hands:setVisible(true)
                        if index > 3 then
                            self._ccbOwner.node_hands:setPosition(x + 280, -110)
                        else
                            self._ccbOwner.node_hands:setPosition(x + 280, y + 110)
                        end
                    end
                end
            end 

            if self._fightReportId and isNeedTips then
                -- app.tip:floatTip("魂师大人，指定战报（"..self._fightReportId.."）已过期~" )
                app.tip:floatTip("魂师大人，您的战报已失效。" )
            end
        end
    end

    remote.silverMine:silverMineAgainstRecordRequest(self:safeHandler(function (data)
        self._loadAgainstRecordImp(data)
        self:_updateRedTips(true)
    end))

end

function QUIDialogSilverMineAwardAndRecord:_onTriggerRegionalRecord(e)
    app.sound:playSound("common_small")
    self._fightReportId = nil
    -- if remote.silverMine:isLock() then return end
    -- remote.silverMine:addLock()
    -- if self._type == QUIDialogSilverMineAwardAndRecord.REGIONAL_RECORD then return end
    self._type = QUIDialogSilverMineAwardAndRecord.REGIONAL_RECORD
    self:_selectType()
    if self._scrollView then
        self._scrollView:setVisible(false)
    end
    if self._personalRecordScrollView then
        self._personalRecordScrollView:setVisible(false)
    end
    if self._regionalRecordScrollView then
        self._regionalRecordScrollView:setVisible(true)
        return
    end
    local size = self._ccbOwner.sheet_layout:getContentSize()
    self._regionalRecordScrollView = QScrollView.new(self._ccbOwner.sheet, size, {bufferMode = 1, sensitiveDistance = 10})
    self._regionalRecordScrollView:setVerticalBounce(true)

    self._totalHeightRegional = 10

    self._loadRegionalAgainstRecordImp = function (data)
        self._regionalAgainstRecord = clone(data.silverMineGetFightReportListResponse.reports or {})
        local _filteredRecord = {}
        for _, record in ipairs(self._regionalAgainstRecord) do
            if record.fighter2 then
                _filteredRecord[#_filteredRecord + 1] = record
            end
        end
        self._regionalAgainstRecord = _filteredRecord

        if self._regionalAgainstRecord ~= nil then
            local recordsWithTime = {}
            local recordsWithoutTime = {}
            for _, record in ipairs(self._regionalAgainstRecord) do
                if record.fighter1.lastFightAt then
                    recordsWithTime[#recordsWithTime + 1] = record
                else
                    recordsWithoutTime[#recordsWithoutTime + 1] = record
                end
            end
            table.sort(recordsWithTime, function (x, y)
                return x.fighter1.lastFightAt > y.fighter1.lastFightAt
            end)
            self._regionalAgainstRecord = {}
            table.mergeForArray(self._regionalAgainstRecord, recordsWithTime)
            table.mergeForArray(self._regionalAgainstRecord, recordsWithoutTime)

            local index = 0
            for _, v in pairs(self._regionalAgainstRecord) do
                local me = v.fighter1
                local rival = v.fighter2
                local result = v.success

                local nickNameWin, forceWin, nickNameLose, forceLose
                if result == true then
                    nickNameWin = v.fighter1.name
                    forceWin = v.fighter1.force
                    nickNameLose = v.fighter2.name
                    forceLose = v.fighter2.force
                else
                    nickNameWin = v.fighter2.name
                    forceWin = v.fighter2.force
                    nickNameLose = v.fighter1.name
                    forceLose = v.fighter1.force
                end
                local winnerIsAttacker = v.success

                local widgetRegionalRecord = QUIWidgetSilverRegionalRecord.new(
                    {parent = self, time = v.fighter1.lastFightAt, winnerIsAttacker = winnerIsAttacker,
                    type = REPORT_TYPE.SILVERMINE, replay = v.fightReportId, vip = rival.vip, mineId = v.mineId,
                    nickNameWin = nickNameWin, forceWin = forceWin, nickNameLose = nickNameLose, forceLose = forceLose,
                    bgVisible = math.fmod(index, 2) == 0}) 

                widgetRegionalRecord:setPosition(ccp(0, -index * (widgetRegionalRecord:getContentSize().height + widgetRegionalRecord.GAP)))
                self._regionalRecordScrollView:addItemBox(widgetRegionalRecord)
                self._totalHeightRegional = self._totalHeightRegional + widgetRegionalRecord:getContentSize().height + widgetRegionalRecord.GAP
                index = index + 1

                self._regionalRecordScrollView:setRect(0, -self._totalHeightRegional, 0, self._ccbOwner.sheet_layout:getContentSize().width)
            end
        end
    end

    remote.silverMine:silverMineRegionAgainstRecordRequest(self._caveRegion, self:safeHandler(function (data)
        self._loadRegionalAgainstRecordImp(data)
    end))
end

return QUIDialogSilverMineAwardAndRecord














