
local QUIDialogBaseJifenAward = import("..dialogs.QUIDialogBaseJifenAward")
local QUIDialogInvasionReward = class("QUIDialogInvasionReward", QUIDialogBaseJifenAward)

local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogInvasionReward:ctor(options)
    QUIDialogInvasionReward.super.ctor(self, ccbFile, callBacks, options)

    self._ccbOwner.frame_tf_title:setString("积分奖励")

    -- 設置父類的參數
    self.isShowBtnOneGet = true
end

function QUIDialogInvasionReward:viewDidAppear()
    QUIDialogInvasionReward.super.viewDidAppear(self)
    self:setInfo()
end

function QUIDialogInvasionReward:viewWillDisappear() 
    QUIDialogInvasionReward.super.viewWillDisappear(self)
end

-- 重寫父類的方法
function QUIDialogInvasionReward:updateListViewData()
    local invasion = remote.invasion:getSelfInvasion()
    self.data = self:getDrawnRewards(invasion.rewardInfo)

    local curScore = invasion.allHurt
    self.score = curScore

    self:initListView()
end

function QUIDialogInvasionReward:setInfo()
    self._ccbOwner.descirble1:setString("")
    self._ccbOwner.descirble1:setVisible(false)
    
    self:updateView()
    self:updateListViewData()
end

function QUIDialogInvasionReward:getDrawnRewards(drawnRewardId)
    local dailyRewards = QStaticDatabase:sharedDatabase():getIntrusionReward(1)
    local conditionLevel = remote.user.dailyTeamLevel == 0 and 1 or remote.user.dailyTeamLevel
    local rewards = {}
    local maxRewardsLevel = 1
    self._sortRewards = function()
        for k, v in pairs(dailyRewards) do
            local drawn = false
            local _,pos = string.find(drawnRewardId, tostring(v.id))
            if pos then
                drawn = true
            end
            if conditionLevel and conditionLevel >= v.lowest_levels and conditionLevel <= v.maximum_levels then
                local info = {ID = v.id, condition = v.meritorious_service, isGet = drawn, awardList = {{id = v.reward_id, typeName = v.type, count = v.count}}}
                table.insert(rewards, info)
            end
            maxRewardsLevel = maxRewardsLevel < v.maximum_levels and v.maximum_levels or maxRewardsLevel
        end
    end
    self._sortRewards()
    if not next(rewards) then
        conditionLevel = maxRewardsLevel
        self._sortRewards()
    end

    table.sort(rewards, function (a, b)
        if a.isGet ~= b.isGet then
            return b.isGet
        end
        if a.isGet then
            return a.condition > b.condition
        end
        return a.condition < b.condition
    end)

    return rewards
end

function QUIDialogInvasionReward:cellClickCallback(event)
    local info = event.info
    local awards = event.awards
    remote.invasion:getInvasionRewardRequest({info.ID},false,function(data)
        if self:safeCheck() then
            self:setInfo()
        end
        app.tip:awardsTip(awards, "恭喜您获得积分奖励", function()
             remote.user:checkTeamUp()
        end)
    end,function()
    end)
end

function QUIDialogInvasionReward:_onTriggerClose(event)
    if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
    if event ~= nil then
        app.sound:playSound("common_close")
    end
    self:playEffectOut()

    if self:getOptions().closeCallback then
        self:getOptions().closeCallback()
    end
end

function QUIDialogInvasionReward:onGetCallBack(event)
    app.sound:playSound("common_small")
    local invasion = remote.invasion:getSelfInvasion()
    local dailyRewards = QStaticDatabase:sharedDatabase():getIntrusionReward(1)
    local drawnRewardId = invasion.rewardInfo or ""
    local ids = {}
    local conditionLevel = remote.user.dailyTeamLevel == 0 and 1 or remote.user.dailyTeamLevel
    local maxRewardsLevel = 1
    for k, v in pairs(dailyRewards) do
        local drawn = false
        local _, pos = string.find(drawnRewardId, tostring(v.id))
        if pos then
            drawn = true
        end
        if conditionLevel and conditionLevel >= v.lowest_levels and conditionLevel <= v.maximum_levels then
            if drawn == false and v.meritorious_service <= invasion.allHurt then
                table.insert(ids, v.id)
            end
        end
        maxRewardsLevel = maxRewardsLevel < v.maximum_levels and v.maximum_levels or maxRewardsLevel
    end
    if #ids == 0 then
        app.tip:floatTip("没有可领取的奖励")
        return
    end
    remote.invasion:getInvasionRewardRequest(ids,false,function(data)
        if self:safeCheck() then
            self:setInfo()
        end
        local awards = {}
        for _,value in ipairs(data.prizes) do
            table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
        end
        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogAwardsAlert",
            options = {awards = awards, callBack = function ()
                remote.user:checkTeamUp()
            end}}, {isPopCurrentDialog = false} )
        dialog:setTitle("恭喜您获得积分奖励")
    end)
end

return QUIDialogInvasionReward



