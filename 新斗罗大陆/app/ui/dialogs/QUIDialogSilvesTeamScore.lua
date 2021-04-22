-- @Author: dsl
-- @Date:   2020-05-29
-- 希尔维斯 目标奖励

local QUIDialogBaseJifenAward = import("..dialogs.QUIDialogBaseJifenAward")
local QUIDialogSilvesTeamScore = class("QUIDialogSilvesTeamScore", QUIDialogBaseJifenAward)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QScrollContain = import("..QScrollContain")
local QUIViewController = import("..QUIViewController")
local QVIPUtil = import("...utils.QVIPUtil")

function QUIDialogSilvesTeamScore:ctor(options)
    QUIDialogSilvesTeamScore.super.ctor(self, ccbFile, callBacks, options)

    self.teamLevel = remote.user.level

    self._ccbOwner.frame_tf_title:setString("目标奖励")
    self._ccbOwner.descirble1:setString("你的小队战斗次数累积达到次数获得奖励，不论胜负，每赛季重开时重置。")
end

function QUIDialogSilvesTeamScore:viewDidAppear()
    QUIDialogSilvesTeamScore.super.viewDidAppear(self)

    self._silvesArenaProxy = cc.EventProxy.new(remote.silvesArena)
    self._silvesArenaProxy:addEventListener(remote.silvesArena.EVENT_UPDATE, handler(self, self.setInfo))
end

function QUIDialogSilvesTeamScore:viewWillDisappear()
    QUIDialogSilvesTeamScore.super.viewWillDisappear(self)
    self._silvesArenaProxy:removeAllEventListeners()
    self._silvesArenaProxy = nil
end

function QUIDialogSilvesTeamScore:_splitAward(awardStr)
    local awardList = {}
    if awardStr ~= nil then
        local strTable = string.split(awardStr,";")
        for i,v in ipairs(strTable) do
            local itemTB = string.split(v,"^")
            local itemId,itemCount = itemTB[1],tonumber(itemTB[2])
            local itemInfo = {}
            itemInfo.count = itemCount
            if tonumber(itemId) ~= nil then
                itemInfo.typeName = "item"
                itemInfo.id = tonumber(itemId)
            else
                itemInfo.typeName = itemId
            end
            table.insert(awardList,itemInfo)
        end
    end
    return awardList
end

-- 重寫父類的方法
function QUIDialogSilvesTeamScore:updateListViewData()
    local configs = {}
    local silvesReword = db:getStaticByName("silves_arena_fight_count_reward")
    for k, value in pairs(silvesReword) do
        if self.teamLevel >= value.level_min and self.teamLevel <= value.level_max then
            value.isGet = remote.silvesArena:getAwardIsGetById(value.id)
            value.awardList = self:_splitAward(value.awards)
            value.widgetTitleStr = "小队战斗%d次"
            configs[value.id] = value
        end
    end
    table.sort( configs, function (a,b)
        if a.isGet ~= b.isGet  then
            return a.isGet == false
        end
        return a.id < b.id
    end )

    self.data = configs

    local curScore = remote.silvesArena:getCurSeasonFightCount()
    self.score = curScore

    self:initListView()
end

function QUIDialogSilvesTeamScore:setInfo()
    self:updateView()
    self:updateListViewData()
end

function QUIDialogSilvesTeamScore:cellClickCallback(event)
    local info = event.info
    local awards = event.awards

    remote.silvesArena:silvesArenaGetTeamRewardRequest({info.id}, function (data)
        remote.silvesArena:updateAwardId({info.id})
        if self.class then
            self:updateListViewData()
            app.tip:awardsTip(awards,"恭喜您获得小队目标奖励")
        end
    end)
end

--一键领取
function QUIDialogSilvesTeamScore:onGetCallBack(event)
    local configs = {}
    local configsAward = db:getStaticByName("silves_arena_fight_count_reward")
    for k, value in pairs(configsAward) do
        if self.teamLevel >= value.level_min and self.teamLevel <= value.level_max then
            value.isGet = remote.silvesArena:getAwardIsGetById(value.id)
            value.awardList = self:_splitAward(value.awards)
            configs[value.id] = value
        end
    end

    local score = remote.silvesArena:getCurSeasonFightCount()
    local ids = {}
    for _,value in pairs(configs) do
        if value.isGet == false and score >= value.condition then 
            table.insert(ids, value.id)    
        end
    end
    if #ids == 0 then
        app.tip:floatTip("没有可领取的奖励")
        return
    end
    
    remote.silvesArena:silvesArenaGetTeamRewardRequest(ids, function (data)
        remote.silvesArena:updateAwardId(ids)
        if self.class then
            self:updateListViewData()
            if data.prizes then
                local awards = {}
                -- 这里需要确认奖励道具服务端返回还是客户端自己计算
                for _, value in ipairs(data.prizes) do
                    if value.id == 0 then
                        table.insert(awards, {typeName = value.type, count = value.count})
                    else
                        table.insert(awards, {id = value.id, typeName = value.type, count = value.count})
                    end
                end
                app:alertAwards({awards = awards, title = "恭喜您获得小队目标奖励"})
            end
        end
    end)
end

return QUIDialogSilvesTeamScore