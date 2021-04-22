-- @Author: zhouxiaoshu
-- @Date:   2019-09-07 19:41:35
-- @Last Modified by:   xurui
-- @Last Modified time: 2019-11-01 17:16:32
local QUIDialogBaseJifenAward = import("..dialogs.QUIDialogBaseJifenAward")
local QUIDialogSotoTeamScore = class("QUIDialogSotoTeamScore", QUIDialogBaseJifenAward)
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollContain = import("..QScrollContain")
local QUIViewController = import("..QUIViewController")
local QVIPUtil = import("...utils.QVIPUtil")

function QUIDialogSotoTeamScore:ctor(options)
    QUIDialogSotoTeamScore.super.ctor(self, ccbFile, callBacks, options)

    self._ccbOwner.frame_tf_title:setString("云顶积分")

    -- 設置父類的參數
    self.isShowBtnOneGet = true
end

function QUIDialogSotoTeamScore:viewDidAppear()
    QUIDialogSotoTeamScore.super.viewDidAppear(self)
    self.sotoTeamEventProxy = cc.EventProxy.new(remote.sotoTeam)
    self.sotoTeamEventProxy:addEventListener(remote.sotoTeam.EVENT_SOTO_TEAM_MY_INFO, handler(self, self.setInfo))
end

function QUIDialogSotoTeamScore:viewWillDisappear()
    QUIDialogSotoTeamScore.super.viewWillDisappear(self)
    self.sotoTeamEventProxy:removeAllEventListeners()
end

-- 重寫父類的方法
function QUIDialogSotoTeamScore:updateListViewData()
    local configs = {}
    for k, value in pairs(db:getStaticByName("soto_team_reward")) do
        value.isGet = remote.sotoTeam:dailyRewardInfoIsGet(value.ID)
        configs[value.ID] = value
    end
    table.sort( configs, function (a,b)
        if a.isGet ~= b.isGet  then
            return a.isGet == false
        end
        return a.ID < b.ID
    end )

    self.data = configs
    -- QPrintTable(self.data)

    local curScore = remote.sotoTeam:getDailyScore()
    self.score = curScore

    self:initListView()
end

function QUIDialogSotoTeamScore:setInfo()
    self._ccbOwner.descirble1:setString("在云顶之战与对手战斗即可获得积分，每日5:00重置。")

    self:updateView()
    self:updateListViewData()
end

function QUIDialogSotoTeamScore:cellClickCallback(event)
    local info = event.info
    local awards = event.awards
    remote.sotoTeam:sotoTeamIntegralRewardRequest({info.ID}, function (data)
        app.tip:awardsTip(awards,"恭喜您获得积分奖励")
    end)
end

--一键领取
function QUIDialogSotoTeamScore:onGetCallBack(event)
    local configs = db:getStaticByName("soto_team_reward")
    local score = remote.sotoTeam:getDailyScore()
    local ids = {}
    for _,value in pairs(configs) do
        if remote.sotoTeam:dailyRewardInfoIsGet(value.ID) == false and score >= value.condition then 
            table.insert(ids, value.ID)          
        end
    end
    if #ids == 0 then
        app.tip:floatTip("没有可领取的奖励")
        return
    end
    remote.sotoTeam:sotoTeamIntegralRewardRequest(ids, function (data)
        local awards = {}
        for _,value in ipairs(data.prizes) do
            table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
        end
        app:alertAwards({awards = awards, title = "恭喜您获得积分奖励"})
    end,function ()
    end)
end

return QUIDialogSotoTeamScore