--
-- Author: wkwang
-- Date: 2015-01-14 20:06:17
--
local QUIDialogBaseJifenAward = import("..dialogs.QUIDialogBaseJifenAward")
local QUIDialogArenaScore = class("QUIDialogArenaScore", QUIDialogBaseJifenAward)
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollContain = import("..QScrollContain")
local QUIViewController = import("..QUIViewController")
local QVIPUtil = import("...utils.QVIPUtil")

function QUIDialogArenaScore:ctor(options)
    QUIDialogArenaScore.super.ctor(self, ccbFile, callBacks, options)

    self._ccbOwner.frame_tf_title:setString("斗魂积分")

    -- 設置父類的參數
    self.isShowBtnOneGet = true
end

function QUIDialogArenaScore:viewDidAppear()
    QUIDialogArenaScore.super.viewDidAppear(self)
    self.arenaEventProxy = cc.EventProxy.new(remote.arena)
    self.arenaEventProxy:addEventListener(remote.arena.EVENT_SCORE_CHANGE, handler(self, self.setInfo))
end

function QUIDialogArenaScore:viewWillDisappear()
    QUIDialogArenaScore.super.viewWillDisappear(self)
    self.arenaEventProxy:removeAllEventListeners()
end

-- 重寫父類的方法
function QUIDialogArenaScore:updateListViewData()
    local configs = QStaticDatabase:sharedDatabase():getArenaScoreAwardsByLevel(remote.user.dailyTeamLevel)
    for k ,v in pairs(configs) do
        v.isGet = remote.arena:dailyRewardInfoIsGet(v.ID)
    end
    table.sort( configs, function (a,b)
        if a.isGet ~= b.isGet  then
            return a.isGet == false
        end
        return a.ID < b.ID
    end )

    self.data = configs
    -- QPrintTable(self.data)

    local curScore = remote.arena:getDailyScore()
    self.score = curScore

    self:initListView()
end

function QUIDialogArenaScore:setInfo()
    local config = QStaticDatabase:sharedDatabase():getConfiguration()
    self._ccbOwner.descirble1:setString(string.format("在斗魂场与对手战斗即可获得积分，每日5：00重置。胜利：积分+%s 失败：积分+%d （v6以上玩家失败积分+%d）", config.ARENA_SUCCESS_INTEGRAL.value, QVIPUtil:getArenaFailScore(0), QVIPUtil:getArenaFailScore(6)))

    self:updateView()
    self:updateListViewData()
end

function QUIDialogArenaScore:cellClickCallback(event)
    local info = event.info
    local awards = event.awards
    remote.arena:ArenaIntegralRewardRequest({info.ID}, function (data)
        remote.arena:setDailyRewardInfo(data.arenaResponse.mySelf.arenaRewardInfo)

        app.tip:awardsTip(awards,"恭喜您获得积分奖励", function()
             remote.user:checkTeamUp()
        end)
    end,function()
    end)
end

--一键领取
function QUIDialogArenaScore:onGetCallBack(event)
    local configs = QStaticDatabase:sharedDatabase():getArenaScoreAwardsByLevel(remote.user.dailyTeamLevel)
    local score = remote.arena:getDailyScore()
    local ids = {}
    for _,value in ipairs(configs) do
        if remote.arena:dailyRewardInfoIsGet(value.ID) == false and score>=value.condition then 
            table.insert(ids, value.ID)          
        end
    end
    if #ids == 0 then
        app.tip:floatTip("没有可领取的奖励")
        return
    end
    remote.arena:ArenaIntegralRewardRequest(ids, function (data)
        remote.arena:setDailyRewardInfo(data.arenaResponse.mySelf.arenaRewardInfo)
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

return QUIDialogArenaScore