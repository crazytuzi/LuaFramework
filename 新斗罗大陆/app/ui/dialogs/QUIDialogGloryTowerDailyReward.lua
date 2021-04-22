
local QUIDialogBaseJifenAward = import("..dialogs.QUIDialogBaseJifenAward")
local QUIDialogGloryTowerDailyReward = class("QUIDialogGloryTowerDailyReward", QUIDialogBaseJifenAward)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogGloryTowerDailyReward:ctor(options)
    QUIDialogGloryTowerDailyReward.super.ctor(self, ccbFile, callBacks, options)

    if options then
        self._closeCallback = options.closeCallback
    end

    self._isCanClose = true

    self._ccbOwner.frame_tf_title:setString("积分奖励")

    -- 設置父類的參數
    self.isShowBtnOneGet = true
end

function QUIDialogGloryTowerDailyReward:viewDidAppear()
    QUIDialogGloryTowerDailyReward.super.viewDidAppear(self)

    self:setInfo()
end

function QUIDialogGloryTowerDailyReward:viewWillDisappear()
    QUIDialogGloryTowerDailyReward.super.viewWillDisappear(self)
end


-- 重寫父類的方法
function QUIDialogGloryTowerDailyReward:updateListViewData()
    local configs = {}
    local towerData = remote.tower:getTowerInfo()
    local drawnRewards, undrawnRewards = self:_getDrawnRewards(towerData.todayAward or "")
    for k, v in ipairs(undrawnRewards) do
        table.insert(configs, {ID = v.id, condition = v.score_service, isGet = false, awardList = {{id = v.reward_id, typeName = v.type, count = v.count}}})
    end

    for k, v in ipairs(drawnRewards) do
        table.insert(configs, {ID = v.id, condition = v.score_service, isGet = true, awardList = {{id = v.reward_id, typeName = v.type, count = v.count}}})
    end

    self.data = configs
    -- QPrintTable(self.data)

    local towerData = remote.tower:getTowerInfo()
    local curScore = towerData.todayScore
    self.score = curScore

    self:initListView()
end

function QUIDialogGloryTowerDailyReward:setInfo()
    self._ccbOwner.descirble1:setString("在段位赛与对手战斗即可获得积分，每日00:00重置。")
    
    self:updateView()
    self:updateListViewData()
end

function QUIDialogGloryTowerDailyReward:_getDrawnRewards(drawnRewardId)
    local dailyRewards = QStaticDatabase:sharedDatabase():getGloryTowerDailyReward()
    local rewards = string.split(drawnRewardId, ";")

    -- sort out drawn and undrawn rewards
    local undrawnRewards = {}
    local drawnRewards = {}
    for k, v in pairs(dailyRewards) do
        local drawn = false
        for k1, v1 in ipairs(rewards) do
            if tonumber(v1) == tonumber(v.id) then
                drawn = true
                break
            end
        end

        if drawn then
            table.insert(drawnRewards, v)
        else
            table.insert(undrawnRewards, v)
        end
    end
    table.sort(undrawnRewards, function (x, y)
        if x.score_service == y.score_service then
            return x.id < y.id
        end
        return x.score_service < y.score_service
    end)
    table.sort(drawnRewards, function (x, y)
        if x.score_service == y.score_service then
            return x.id < y.id
        end
        return x.score_service > y.score_service
    end)

    return drawnRewards, undrawnRewards
end

function QUIDialogGloryTowerDailyReward:refresh()
    
end

function QUIDialogGloryTowerDailyReward:cellClickCallback(event)
    local info = event.info
    local awards = event.awards
    app:getClient():towerDailyRewardRequest({info.ID}, function (data)
        remote.tower:addTodayAward(info.ID)

        if self:safeCheck() then
            self:setInfo()
        end
        app.tip:awardsTip(awards,"恭喜您获得积分奖励", function()
             remote.user:checkTeamUp()
        end)
    end,function()
    end)
end

function QUIDialogGloryTowerDailyReward:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
    if self._isCanClose == false then return end

    app.sound:playSound("common_close")
    self:playEffectOut()

    if self._closeCallback then
        self._closeCallback()
    end
end

function QUIDialogGloryTowerDailyReward:onGetCallBack(event)
    app.sound:playSound("common_small")
    local towerData = remote.tower:getTowerInfo()
    local dailyRewards = QStaticDatabase:sharedDatabase():getGloryTowerDailyReward()
    local rewards = string.split((towerData.todayAward or ""), ";")
    local ids = {}
    for k, v in pairs(dailyRewards) do
        local drawn = false
        for k1, v1 in ipairs(rewards) do
            if tonumber(v1) == tonumber(v.id) then
                drawn = true
                break
            end
        end

        if drawn == false and towerData.todayScore >= v.score_service then
            table.insert(ids, v.id)
        end
    end
    if #ids == 0 then
            app.tip:floatTip("没有可领取的积分奖励")
        return
    end

    self._isCanClose = false
    app:getClient():towerDailyRewardRequest(ids, function(data)
            for _,id in ipairs(ids) do
                remote.tower:addTodayAward(id)
            end
            if self:safeCheck() then
                self:setInfo()
            end
            local items = data.towerGetTodayScoreAwardResponse.lucky_draw_response.items
            if items then
                remote.items:setItems(items)
            end
            local awards = {}
            for _,value in ipairs(data.towerGetTodayScoreAwardResponse.lucky_draw_response.prizes) do
                table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
            end
            local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
                options = {awards = awards, callBack = function ()
                    remote.user:checkTeamUp()
                    self._isCanClose = true
                end}}, {isPopCurrentDialog = false} )
            dialog:setTitle("恭喜您获得积分奖励")
        end, function()
            self._isCanClose = true
        end)
end

return QUIDialogGloryTowerDailyReward



