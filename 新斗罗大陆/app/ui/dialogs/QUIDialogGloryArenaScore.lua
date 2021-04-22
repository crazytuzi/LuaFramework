--
-- Author: wkwang
-- Date: 2015-01-14 20:06:17
--
local QUIDialogBaseJifenAward = import("..dialogs.QUIDialogBaseJifenAward")
local QUIDialogGloryArenaScore = class("QUIDialogGloryArenaScore", QUIDialogBaseJifenAward)
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollContain = import("..QScrollContain")
local QUIViewController = import("..QUIViewController")
local QVIPUtil = import("...utils.QVIPUtil")

function QUIDialogGloryArenaScore:ctor(options)
    QUIDialogGloryArenaScore.super.ctor(self, ccbFile, callBacks, options)

    self._ccbOwner.frame_tf_title:setString("积分奖励")

    -- 設置父類的參數
    self.isShowBtnOneGet = true
end

function QUIDialogGloryArenaScore:viewDidAppear()
    QUIDialogGloryArenaScore.super.viewDidAppear(self)
    self.gloryArenaEventProxy = cc.EventProxy.new(remote.tower)
    self.gloryArenaEventProxy:addEventListener(remote.tower.GLORY_ARENA_REFRESH, handler(self, self.setInfo))
end

function QUIDialogGloryArenaScore:viewWillDisappear()
    QUIDialogGloryArenaScore.super.viewWillDisappear(self)
    self.gloryArenaEventProxy:removeAllEventListeners()
end

-- 重寫父類的方法
function QUIDialogGloryArenaScore:updateListViewData()
    local configs = QStaticDatabase:sharedDatabase():getGloryArenaScoreAwardsByLevel(remote.user.dailyTeamLevel)
    for k ,v in pairs(configs) do
        v.isGet = remote.tower:dailyGloryArenaScoreIsGet(v.ID)
    end
    table.sort( configs, function (a,b)
        if a.isGet ~= b.isGet  then
            return a.isGet == false
        end
        return a.ID < b.ID
    end )

    self.data = configs
    -- QPrintTable(self.data)

    local curScore = remote.tower:getGloryArenaScore()
    self.score = curScore

    self:initListView()
end

function QUIDialogGloryArenaScore:setInfo()
    self._ccbOwner.descirble1:setString("在争霸赛与对手战斗即可获得积分，每日00:00重置。")

    self:updateView()
    self:updateListViewData()
end

function QUIDialogGloryArenaScore:cellClickCallback(event)
    local info = event.info
    local awards = event.awards
    remote.tower:requestGloryArenaIntegralReward({info.ID}, function (data)
        remote.tower:gloryArenaRefresh(data)
        app.tip:awardsTip(awards,"恭喜您获得积分奖励", function ()
             remote.user:checkTeamUp()
        end)
    end,function ()
    end)
end

--一键领取
function QUIDialogGloryArenaScore:onGetCallBack(event)
    local configs = QStaticDatabase:sharedDatabase():getGloryArenaScoreAwardsByLevel(remote.user.dailyTeamLevel)
    local score = remote.tower:getGloryArenaScore()
    local ids = {}
    for _,value in ipairs(configs) do
        if remote.tower:dailyGloryArenaScoreIsGet(value.ID) == false and score>=value.condition then 
            table.insert(ids, value.ID)          
        end
    end
    if #ids == 0 then
            app.tip:floatTip("没有可领取的积分奖励")
        return
    end
    remote.tower:requestGloryArenaIntegralReward(ids, function (data)
        remote.tower:gloryArenaRefresh(data)
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

return QUIDialogGloryArenaScore