--
-- zxs
-- 团购积分
--
local QUIDialogBaseJifenAward = import("..dialogs.QUIDialogBaseJifenAward")
local QUIDialogActivityGroupBuyScore = class("QUIDialogActivityGroupBuyScore", QUIDialogBaseJifenAward)
local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollContain = import("..QScrollContain")
local QUIViewController = import("..QUIViewController")

function QUIDialogActivityGroupBuyScore:ctor(options)
    QUIDialogActivityGroupBuyScore.super.ctor(self, ccbFile, callBacks, options)

    self._ccbOwner.frame_tf_title:setString("团购积分")

    -- 設置父類的參數
    self.isShowBtnOneGet = true

    self._groupBuy = remote.activityRounds:getGroupBuy()
end

function QUIDialogActivityGroupBuyScore:viewDidAppear()
    QUIDialogActivityGroupBuyScore.super.viewDidAppear(self)
    self._activityRoundsEventProxy = cc.EventProxy.new(remote.activityRounds)
    self._activityRoundsEventProxy:addEventListener(remote.activityRounds.GROUPBUY_UPDATE, handler(self, self.setInfo))
end

function QUIDialogActivityGroupBuyScore:viewWillDisappear()
    QUIDialogActivityGroupBuyScore.super.viewWillDisappear(self)
    self._activityRoundsEventProxy:removeAllEventListeners()
    self._activityRoundsEventProxy = nil
end

-- 重寫父類的方法
function QUIDialogActivityGroupBuyScore:updateListViewData()
    local rowNum = self._groupBuy.rowNum or 1
    local funcName = string.format("group_buying_%d", rowNum)
    local configs = db:getScoreAwardsByLevel(funcName, remote.user.level)

    for k ,v in pairs(configs) do
        v.isGet = self._groupBuy:dailyRewardInfoIsGet(v.id)
    end

    table.sort( configs, function (a,b)
        if a.isGet ~= b.isGet  then
            return a.isGet == false
        end
        return a.id < b.id
    end )

    self.data = configs
    -- QPrintTable(self.data)

    local curScore = self._groupBuy:getDailyScore()
    self.score = curScore

    self:initListView()
end

function QUIDialogActivityGroupBuyScore:setInfo()
    self._ccbOwner.descirble1:setString("购买道具即可获得等量积分。")

    self:updateView()
    self:updateListViewData()
end

function QUIDialogActivityGroupBuyScore:cellClickCallback(event)
    local info = event.info
    local awards = event.awards
    self._groupBuy:getScoreAwards({info.id}, function (data)
        app.tip:awardsTip(awards,"恭喜您获得积分奖励")
    end)
end

--一键领取
function QUIDialogActivityGroupBuyScore:onGetCallBack(event)
    local rowNum = self._groupBuy.rowNum or 1
    local funcName = string.format("group_buying_%d", rowNum)
    local configs = db:getScoreAwardsByLevel(funcName, remote.user.level)
    local score = self._groupBuy:getDailyScore()

    local ids = {}
    for _,value in ipairs(configs) do
        if self._groupBuy:dailyRewardInfoIsGet(value.id) == false and score >= value.condition then 
            table.insert(ids, value.id)          
        end
    end
    if #ids == 0 then
        app.tip:floatTip("没有可领取的积分奖励")
        return
    end

    self._groupBuy:getScoreAwards(ids, function (data)
        local awards = {}
        for _,value in ipairs(data.prizes) do
            table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
        end
        app.tip:awardsTip(awards,"恭喜您获得积分奖励")
    end)
end

return QUIDialogActivityGroupBuyScore