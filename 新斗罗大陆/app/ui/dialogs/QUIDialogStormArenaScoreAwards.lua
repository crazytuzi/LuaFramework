
--
-- Author: nieming
-- Date: 2016-09-27 20:06:17
--
local QUIDialogBaseJifenAward = import("..dialogs.QUIDialogBaseJifenAward")
local QUIDialogStormArenaScoreAwards = class("QUIDialogStormArenaScoreAwards", QUIDialogBaseJifenAward)
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollContain = import("..QScrollContain")
local QUIViewController = import("..QUIViewController")
local QVIPUtil = import("...utils.QVIPUtil")

function QUIDialogStormArenaScoreAwards:ctor(options)
    QUIDialogStormArenaScoreAwards.super.ctor(self, ccbFile, callBacks, options)

    self._ccbOwner.frame_tf_title:setString("索托积分")

    -- 設置父類的參數
    self.isShowBtnOneGet = true
end

function QUIDialogStormArenaScoreAwards:viewDidAppear()
    QUIDialogStormArenaScoreAwards.super.viewDidAppear(self)

    self.stormArenaEventProxy = cc.EventProxy.new(remote.stormArena)
    self.stormArenaEventProxy:addEventListener(remote.stormArena.STORM_ARENA_REFRESH, handler(self, self.setInfo))
end

function QUIDialogStormArenaScoreAwards:viewWillDisappear()
    QUIDialogStormArenaScoreAwards.super.viewWillDisappear(self)
    self.stormArenaEventProxy:removeAllEventListeners()
    self.stormArenaEventProxy = nil
end

-- 重寫父類的方法
function QUIDialogStormArenaScoreAwards:updateListViewData()
    local configs = QStaticDatabase:sharedDatabase():getStormArenaScoreAwardsByLevel(remote.user.dailyTeamLevel)
    for k ,v in pairs(configs) do
        v.isGet = remote.stormArena:dailyStormArenaScoreIsGet(v.ID)
    end

    table.sort(configs, function (a,b)
        if a.isGet ~= b.isGet  then
            return a.isGet == false
        end
        return a.ID < b.ID
    end)

    self.data = configs

    local curScore = remote.stormArena:getStormArenaScore()
    self.score = curScore

    self:initListView()
end

function QUIDialogStormArenaScoreAwards:setInfo()
    self._ccbOwner.descirble1:setString("在索托斗魂场与对手战斗即可获得积分，每日5:00重置。")

    self:updateView()
    self:updateListViewData()
end

function QUIDialogStormArenaScoreAwards:cellClickCallback(event)
    local info = event.info
    local awards = event.awards
    remote.stormArena:requestStormArenaIntegralReward({info.ID}, function (data)
        remote.stormArena:stormArenaRefresh(data)
        app.tip:awardsTip(awards,"恭喜您获得积分奖励", function ()
             remote.user:checkTeamUp()
        end)
    end,function ()
    end)
end

--一键领取
function QUIDialogStormArenaScoreAwards:onGetCallBack(event)
    local configs = QStaticDatabase:sharedDatabase():getStormArenaScoreAwardsByLevel(remote.user.dailyTeamLevel)
    local score = remote.stormArena:getStormArenaScore()
    local ids = {}
    for _,value in ipairs(configs) do
        if remote.stormArena:dailyStormArenaScoreIsGet(value.ID) == false and score>=value.condition then 
            table.insert(ids, value.ID)          
        end
    end
    if #ids == 0 then
        app.tip:floatTip("没有可领取的积分奖励")
        return
    end
    remote.stormArena:requestStormArenaIntegralReward(ids, function (data)
        remote.stormArena:stormArenaRefresh(data)

        local awards = {}
        for _,value in ipairs(data.prizes) do
            table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
        end
        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
            options = {awards = awards, callBack = function ()
                remote.user:checkTeamUp()
            end}}, {isPopCurrentDialog = false} )
        dialog:setTitle("恭喜您获得积分奖励")

    end,function ()
    end)
end

return QUIDialogStormArenaScoreAwards