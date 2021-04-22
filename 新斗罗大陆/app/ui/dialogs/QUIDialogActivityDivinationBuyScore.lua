--
-- Author: nieming
-- Date: 2016-09-19 20:06:17
--
local QUIDialogBaseJifenAward = import("..dialogs.QUIDialogBaseJifenAward")
local QUIDialogActivityDivinationBuyScore = class("QUIDialogActivityDivinationBuyScore", QUIDialogBaseJifenAward)
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollContain = import("..QScrollContain")
local QUIViewController = import("..QUIViewController")

function QUIDialogActivityDivinationBuyScore:ctor(options)
    QUIDialogActivityDivinationBuyScore.super.ctor(self, ccbFile, callBacks, options)

    self._ccbOwner.frame_tf_title:setString("占卜积分")

    -- 設置父類的參數
    self.isShowBtnOneGet = false
end

function QUIDialogActivityDivinationBuyScore:viewDidAppear()
    QUIDialogActivityDivinationBuyScore.super.viewDidAppear(self)
    self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsEventProxy:addEventListener(remote.activityRounds.DIVINATION_UPDATE, handler(self, self.setInfo))

end

function QUIDialogActivityDivinationBuyScore:viewWillDisappear()
    QUIDialogActivityDivinationBuyScore.super.viewWillDisappear(self)
    self._activityRoundsEventProxy:removeAllEventListeners()
    self._activityRoundsEventProxy = nil
end

-- 重寫父類的方法
function QUIDialogActivityDivinationBuyScore:updateListViewData()
    local rowNum = remote.activityRounds:getDivination().rowNum or 1
    local divinationInfo = QStaticDatabase:sharedDatabase():getDivinationShowInfo(rowNum) or {}
    local funcName = divinationInfo.score_reward or "zhanbu"
    local configs = QStaticDatabase:sharedDatabase():getScoreAwardsByLevel(funcName, remote.user.level)
    for k ,v in pairs(configs) do
        v.isGet = remote.activityRounds:getDivination():dailyRewardInfoIsGet(v.id)
        v.widgetTitleStr = "累计达到%d积分"
    end
    table.sort( configs, function (a,b)
        if a.isGet ~= b.isGet  then
            return a.isGet == false
        end
        return a.id < b.id
    end )

    self.data = configs
    -- QPrintTable(self.data)

    local curScore = remote.activityRounds:getDivination():getDailyScore()
    self.score = curScore

    self:initListView()
end

function QUIDialogActivityDivinationBuyScore:setInfo()
    self._ccbOwner.descirble1:setString("占卜一次即可获取10点积分，积分进行累积不重置。")

    self:updateView()
    self:updateListViewData()
end

function QUIDialogActivityDivinationBuyScore:cellClickCallback(event)
    local info = event.info
    local awards = event.awards
    remote.activityRounds:getDivination():getScoreAwards({info.id}, function (data)
        -- if data.items ~= nil then
        --     remote.items:setItems(data.items)
        -- end
        app.tip:awardsTip(awards,"恭喜您获得积分奖励", function ()
             remote.user:checkTeamUp()
        end)
    end,function ()
    end)
end

--一键领取
function QUIDialogActivityDivinationBuyScore:onGetCallBack(event)
    local funcName = "zhanbu"
    local configs = QStaticDatabase:sharedDatabase():getScoreAwardsByLevel(funcName, remote.user.level)
    local score = remote.activityRounds:getDivination():getDailyScore()
    local ids = {}
    for _,value in ipairs(configs) do
        if remote.activityRounds:getDivination():dailyRewardInfoIsGet(value.id) == false and score >=value.condition then 
            table.insert(ids, value.id)          
        end
    end
    if #ids == 0 then
            app.tip:floatTip("没有可领取的积分奖励")
        return
    end
    remote.activityRounds:getDivination():getScoreAwards(ids, function (data)
        -- if data.items ~= nil then
        --     remote.items:setItems(data.items)
        -- end
        local awards = {}
        for _,value in ipairs(data.prizes) do
            table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
        end
        local dialog = app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogAwardsAlert",
            options = {awards = awards, callBack = function ()
                remote.user:checkTeamUp()
            end}}, {isPopCurrentDialog = false} )
        -- dialog:setTitle("恭喜您获得积分奖励")
    end,function ()
    end)
end

return QUIDialogActivityDivinationBuyScore