--
-- Kumo.Wang
-- 西尔维斯大斗魂场数据类
-- 

local QBaseModel = import("...models.QBaseModel")
local QSilvesArena = class("QSilvesArena", QBaseModel)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("...ui.QUIViewController")
local QReplayUtil = import("..utils.QReplayUtil")
local QNotificationCenter = import("...controllers.QNotificationCenter")

local QSilvesArrangement = import("...arrangement.QSilvesArrangement")

QSilvesArena.EVENT_UPDATE = "QSILVESARENA.EVENT_UPDATE"
QSilvesArena.STATE_UPDATE = "QSILVESARENA.STATE_UPDATE"
QSilvesArena.TEAM_UPDATE = "QSILVESARENA.TEAM_UPDATE"
QSilvesArena.EVENT_FIGHT_END_ALL = "QSILVESARENA.EVENT_FIGHT_END_ALL"
QSilvesArena.EVENT_SEND_INVITE = "QSILVESARENA.EVENT_SEND_INVITE"
QSilvesArena.EVENT_TEAM_AWARD = "QSILVESARENA.EVENT_TEAM_AWARD"
QSilvesArena.EVENT_FIGHT_START = "QSILVESARENA.EVENT_FIGHT_START"
QSilvesArena.EVENT_FIGHT_END = "QSILVESARENA.EVENT_FIGHT_END"
QSilvesArena.EVENT_STAKE_UPDATE = "QSILVESARENA.EVENT_STAKE_UPDATE"
QSilvesArena.EVENT_PEAK_TEAM_UPDATE = "QSILVESARENA.EVENT_PEAK_TEAM_UPDATE"

QSilvesArena.NEW_MESSAGE_RECEIVED = "QSILVESARENA.NEW_MESSAGE_RECEIVED"

QSilvesArena.STATE_END = 0 -- 结算阶段：赛季结束，给后端结算的阶段，时长前后端约定
QSilvesArena.STATE_REST = 1 -- 休赛阶段
QSilvesArena.STATE_READY = 2 -- 准备阶段：报名
QSilvesArena.STATE_PLAY = 3 -- 游戏阶段：海选赛
QSilvesArena.STATE_PEAK = 4 -- 游戏阶段：巅峰赛

QSilvesArena.PEAK_READY_TO_16 = 411 -- 巅峰赛：准备（阵容调整）
QSilvesArena.PEAK_WAIT_TO_16 = 412 -- 巅峰赛：准备完毕，等待比赛（期间冠亚季军比赛可押注）
QSilvesArena.PEAK_16_IN_8 = 4131 -- 巅峰赛：战斗（第一轮，第一阶段，16进8）
QSilvesArena.PEAK_8_IN_4 = 4132 -- 巅峰赛：战斗（第一轮，第二阶段，8进4）

QSilvesArena.PEAK_READY_TO_4 = 421 -- 巅峰赛：准备（阵容调整）
QSilvesArena.PEAK_WAIT_TO_4 = 422 -- 巅峰赛：准备完毕，等待比赛（期间冠亚季军比赛可押注）
QSilvesArena.PEAK_4_IN_2 = 423 -- 巅峰赛：战斗（第二轮，4进2）

QSilvesArena.PEAK_READY_TO_FINAL = 431 -- 巅峰赛：准备（阵容调整）
QSilvesArena.PEAK_WAIT_TO_FINAL = 432 -- 巅峰赛：准备完毕，等待比赛（期间冠亚季军比赛可押注）
QSilvesArena.PEAK_FINAL_FIGHT = 433 -- 巅峰赛：战斗（第三轮，决赛，冠亚季军）

QSilvesArena.TIME_OF_SINGLE_SEASON = WEEK * 1 -- 单个赛季时长

QSilvesArena.TIME_OF_END_DURATION = MIN * 5 -- 结算阶段时长（从周日20:30开始计算）
QSilvesArena.TIME_OF_READY_DURATION = DAY -- 报名阶段时长（从周四9:00开始计算到周五9:00战斗开始）
QSilvesArena.TIME_OF_PLAY_DURATION = DAY * 2 + HOUR * 11 + MIN * 30 -- 游戏阶段时长（从周五9:00到周日20:30结算阶段）
QSilvesArena.TIME_OF_PEAK_DURATION = DAY * 3 + MIN * 25 -- 巅峰赛赛时长（从周日20:35到下周三21:00冠军展示）

QSilvesArena.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION = HOUR * 14 + MIN * 25 -- 巅峰赛第一轮准备阶段（周日20:35～周一11:00）
QSilvesArena.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION = HOUR * 8 + MIN * 30 -- 巅峰赛第一轮等待阶段（周一11:00～周一19:30）
QSilvesArena.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION = MIN * 30 -- 巅峰赛第一轮第一阶段战斗（16进8）（周一19:30～周一20:00）
QSilvesArena.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION = HOUR * 1 -- 巅峰赛第一轮第二阶段战斗（8进4）（周一20:00～周一21:00）

QSilvesArena.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION = HOUR * 14 -- 巅峰赛第二轮准备阶段（周一21:00～周二11:00）
QSilvesArena.TIME_OF_PEAK_SECOND_ROUND_WAIT_DURATION = HOUR * 8 + MIN * 30 -- 巅峰赛第二轮等待阶段（周二11:00～周二19:30）
QSilvesArena.TIME_OF_PEAK_SECOND_ROUND_FIGHT_DURATION = HOUR * 1 + MIN * 30 -- 巅峰赛第二轮战斗阶段（4进2）（周二19:30～周二21:00）

QSilvesArena.TIME_OF_PEAK_THIRD_ROUND_READY_DURATION = HOUR * 14 -- 巅峰赛第三轮准备阶段
QSilvesArena.TIME_OF_PEAK_THIRD_ROUND_WAIT_DURATION = HOUR * 8 + MIN * 30 -- 巅峰赛第三轮等待阶段
QSilvesArena.TIME_OF_PEAK_THIRD_ROUND_FIGHT_DURATION = HOUR * 1 + MIN * 30 -- 巅峰赛第三轮战斗阶段

QSilvesArena.MAX_TEAM_MEMBER_COUNT = 3 -- 队伍最大人数

QSilvesArena.BATTLEFORMATION_MODULE_CAPTAINPOWER = "BATTLEFORMATION_MODULE_CAPTAINPOWER" -- 队长模式，设置防守阵容
QSilvesArena.BATTLEFORMATION_MODULE_NORMAL = "BATTLEFORMATION_MODULE_NORMAL" -- 队员模式，只能查看
QSilvesArena.BATTLEFORMATION_MODULE_PVP = "BATTLEFORMATION_MODULE_PVP" -- 对战模式，设置攻击阵容
QSilvesArena.BATTLEFORMATION_MODULE_PVP_NORMAL = "BATTLEFORMATION_MODULE_PVP_NORMAL" -- 对战模式，查看阵容
QSilvesArena.BATTLEFORMATION_MODULE_RANK_NORMAL = "BATTLEFORMATION_MODULE_RANK_NORMAL" -- 排行榜模式，查看阵容
QSilvesArena.BATTLEFORMATION_MODULE_RANK_PVP = "BATTLEFORMATION_MODULE_RANK_PVP" -- 排行榜对战模式，查看阵容

QSilvesArena.BATTLEFORMATION_MODULE_TIPS = "BATTLEFORMATION_MODULE_TIPS" -- 文字
QSilvesArena.BATTLEFORMATION_MODULE_SKETCH = "BATTLEFORMATION_MODULE_SKETCH" -- 剪影

QSilvesArena.FORCE_LIMIT = 900000000000 -- 玩家设置的房间战力条件的上限值（主要是限于显示位数）

QSilvesArena.PEAK_SCORE_LIST = {{2, 0}, {2, 1}, {1, 2}, {0, 2}} -- 从后端协议拿出来的比分列表

function QSilvesArena:ctor()
    QSilvesArena.super.ctor(self)
end

function QSilvesArena:init()
    self._dispatchTbl = {}

    self._state = self.STATE_REST -- 游戏当前阶段

    self.seasonInfo = {}
    self.userInfo = {}
    self.myTeamInfo = {} -- 我的队伍
    self.teamInfo = {} -- 他人队伍（这里分阶段，休赛期的排行榜前十，报名期的房间队伍列表，战斗期的对手）
    self.fightInfo = {}
    self.onlineUserInfo = {}
    self.rejectInviteUserIdDict = {} -- 暂时拒绝邀请的黑名单。key：userId，value：q.serverTime

    self.againstTeamInfo = {} -- 对手的team信息。

    self.isSelectedForce = false -- 组队列表，是否选择隐藏战力不满足的队伍信息
    self.isSelectedFull = false -- 组队列表，是否选择隐藏满员的队伍信息
    self.isInBattle = false -- 是否在战斗中
    self.isGetFirstMainInfo = true
    
    self.curWathingIndex = 0 -- 当前战斗播放的战报index
    self.totalSilvesArenaMoney = 0 -- 累计银币数量

    self._fightEndAddScore = nil
    self._statsDataList = nil

    self.isDebugModule = false
end

function QSilvesArena:loginEnd()
    if self:checkUnlock() then
        self:silvesArenaGetMyInfoRequest(function()
            local peakState = self:getCurPeakState(true)
            if peakState and (peakState == self.PEAK_WAIT_TO_4 or peakState == self.PEAK_WAIT_TO_FINAL) then
                self:silvesPeakGetMyBetInfoRequest()
            end
            if (not self.myDefenseTeamReplayData or self.myDefenseTeamReplayData == "") and self.myDefenseTeamBattleFormation and self._isTop16 then
                -- 更新replaydata数据给后端
                self:silvesArenaChangeReplayDataRequest()
            end
        end)
    end
    self:_registerPushCallback()
end

function QSilvesArena:disappear()
    self:_unregisterPushCallback()
end

function QSilvesArena:_addEvent()
    self:_removeEvent()

    self._userEventProxy = cc.EventProxy.new(remote.user)
    self._userEventProxy:addEventListener(remote.user.EVENT_TIME_REFRESH, handler(self, self.timeRefreshHandler))
end

function QSilvesArena:_removeEvent()
    if self._userEventProxy then
        self._userEventProxy:removeAllEventListeners()
        self._userEventProxy = nil
    end
end

function QSilvesArena:timeRefreshHandler( event )
    if event.time and event.time == 0 then
        if self:checkUnlock() then
            self:silvesArenaGetMainInfoRequest(function()
                self:dispatchEvent({name = self.EVENT_UPDATE})
            end)
        end
    end
end

--打开界面
function QSilvesArena:openDialog(openCallback, failCallback)
    if self:checkUnlock(true) then
        local state = self:getCurState()
        if state == self.STATE_END then
            if q.isEmpty(self.fightInfo) then
                local _, cdStr = self:getCountdown()
                app.tip:floatTip("当前西尔维斯海选赛正在进行结算奖励，请 "..cdStr.." 后再进")
                return
            end
        end

        self:silvesArenaGetMainInfoRequest(function()
                app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaMain", options = {openCallback = openCallback}}, {isPopCurrentDialog = true})
            end, function()
                if failCallback then
                    failCallback()
                end
            end)
    end
end

-- 引导打开介绍
function QSilvesArena:showDescription(callback)
    local descText = {
        "进入组队大厅，寻找2名队友一起战斗吧！",
        "每人每日可进行6场战斗，胜利获得积分，失败则会扣除。",
    }
    local resPath = "silves_arena_help_pic"
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogPictureHowToPlay", options = {descText = descText, resPath = resPath, callback = callback}}, {isPopCurrentDialog = false})
end

--打开跳过战斗的结算界面
function QSilvesArena:_showSkipBattleResult( addScore, statsDataList, callback )
    app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaEnding", options = {addScore = addScore, statsDataList = statsDataList, callback = callback}}, {isPopCurrentDialog = true})
end

--------------数据储存.KUMOFLAG.--------------

--------------對外工具.KUMOFLAG.--------------

function QSilvesArena:checkRedTips()
    if not self:checkUnlock() then
        return false
    end

    if self:checkFirstEnterRedTips() then
        return true
    end

    if self:checkShopRedTips() then
        return true
    end

    if self:checkRecordRedTips() then
        return true
    end

    if self:checkTeamRedTips() then
        return true
    end

    if self:checkTeamAwardRedTips() then
        return true
    end

    if self:checkStakeRedTips() then
        return true
    end

    return false
end

function QSilvesArena:checkFightTips()
    if not self:checkUnlock() then
        return false
    end

    if self:checkFightCountRedTips() then
        return true
    end

    return false
end

function QSilvesArena:checkFirstEnterRedTips()
    local isNotEnter = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.SILVES_ARENA)
    if isNotEnter then
        return true
    end

    return false
end

function QSilvesArena:checkShopRedTips()
    local shopInfo = remote.stores:getShopResousceByShopId(SHOP_ID.silvesShop)
    if shopInfo.arawdsId and remote.stores:checkAwardsShopCanBuyByShopId(shopInfo.arawdsId) then
        return true
    end

    return false
end

function QSilvesArena:checkRecordRedTips()
    return false
end

function QSilvesArena:checkTeamRedTips()
    local state = self:getCurState()
    if state == self.STATE_PLAY or state == self.STATE_READY then
        return not remote.teamManager:checkTeamStormIsFull(remote.teamManager.SILVES_ARENA_TEAM)
    else
        return false
    end
end

-- function QSilvesArena:checkIsTeamArrangeTime()
--     local state = self:getCurState()
--     if state == self.STATE_PLAY or state == self.STATE_READY  then
--         print("checkIsTeamArrangeTime true")
--         return true
--     elseif state == self.STATE_PEAK then
--         local peakState = self:getCurPeakState()
--         if peakState == self.PEAK_READY_TO_16
--             or peakState == self.PEAK_READY_TO_4
--             or peakState == self.PEAK_READY_TO_FINAL then
--             return true
--         end
--     else
--         print("checkIsTeamArrangeTime false")
--         return false
--     end
-- end


-- function QSilvesArena:checkSignUpRedTips()
--     local state = self:getCurState()
--     if state == self.STATE_READY and q.isEmpty(self.myTeamInfo) then
--         return true
--     end 
--     return false
-- end

function QSilvesArena:checkFightCountRedTips()
    local state = self:getCurState(true)
    if state == self.STATE_PLAY and not q.isEmpty(self.userInfo) then
        local fightCnt = db:getConfigurationValue("silves_arena_day_fight_count")
        local count = tonumber(fightCnt) - tonumber(self.userInfo.todayFightCount)
        if count > 0 then
            return true
        end
    end 
    return false
end

function QSilvesArena:_splitAward(awardStr)
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

-- 小队目标奖励未领取时返回true
function QSilvesArena:checkTeamAwardRedTips()
    local teamLevel = remote.user.level
    local curSeasonFightCount = self:getCurSeasonFightCount()
    if curSeasonFightCount == 0 then
        return false
    end
    local configsAward = db:getStaticByName("silves_arena_fight_count_reward")
    for k, value in pairs(configsAward) do
        if teamLevel >= value.level_min and teamLevel <= value.level_max then
            local isGet = self:getAwardIsGetById(value.id)
            if not isGet then
                if curSeasonFightCount >= value.condition then 
                    return true 
                end
            end
        end
    end

    return false
end

-- 有押注次数返回true
function QSilvesArena:checkStakeRedTips()
    local peakState = self:getCurPeakState()
    local todayRound = 0
    local todayCount = 0
    if peakState == self.PEAK_WAIT_TO_4 then
        todayRound = 3
        todayCount = 2
    elseif peakState == self.PEAK_WAIT_TO_FINAL then
        todayRound = 4
        todayCount = 2
    else
        return false
    end

    if q.isEmpty(self.myStakeInfoList) then
        return true
    end

    local curCount = 0
    for _, info in ipairs(self.myStakeInfoList) do
        if info.currRound == todayRound or info.isThirdRound then
            if info.myScoreId and info.myScoreId ~= 0 then
                curCount = curCount + 1
            end
        end
    end

    if curCount >= todayCount then
        return false
    end

    return true
end

function QSilvesArena:checkUnlock(isTips, tips)
    if not self._isUnlock and app.unlock:checkModuleUnlockByModuleKey("UNLOCK_SILVES_ARENA", isTips, tips) then
        self._isUnlock = true
        self:_addEvent()

        local isSkipBattle = app:getUserOperateRecord():getRecordByType("SIVES_ARENA_SKIP_BATTLE")
        if isSkipBattle == nil then
            app:getUserOperateRecord():setRecordByType("SIVES_ARENA_SKIP_BATTLE", true)
        end
    end
    return self._isUnlock
end

function QSilvesArena:isEnterWaiting()
    -- local seasonStartAt = app:getUserOperateRecord():getRecordByType("SIVES_ARENA_SHOW_ENTER_WAITING")
    -- if self.seasonInfo and self.seasonInfo.seasonStartAt ~= seasonStartAt then
    --     app:getUserOperateRecord():setRecordByType("SIVES_ARENA_SHOW_ENTER_WAITING", self.seasonInfo.seasonStartAt)
    --     return true
    -- end
    return false
end

-- 是否准备出战，每赛季第一次从waiting阶段到fighting阶段时
function QSilvesArena:isEnterFighting()
    -- local seasonStartAt = app:getUserOperateRecord():getRecordByType("SIVES_ARENA_SHOW_ENTER_FIGHTING")
    local isNotOpen = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.SILVES_ARENA_OPEN_DOOR)
    -- if self.seasonInfo and self.seasonInfo.seasonStartAt ~= seasonStartAt then
    if isNotOpen then
        -- app:getUserOperateRecord():setRecordByType("SIVES_ARENA_SHOW_ENTER_FIGHTING", self.seasonInfo.seasonStartAt)
        app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.SILVES_ARENA_OPEN_DOOR)
        return true
    end
    return false
end

function QSilvesArena:isLeaveFighting()
    local enterSeasonStartAt = app:getUserOperateRecord():getRecordByType("SIVES_ARENA_SHOW_ENTER_FIGHTING")
    local seasonStartAt = app:getUserOperateRecord():getRecordByType("SIVES_ARENA_SHOW_LEAVE_FIGHTING")
    if enterSeasonStartAt and enterSeasonStartAt == seasonStartAt and self.seasonInfo and self.seasonInfo.seasonStartAt ~= seasonStartAt then
        app:getUserOperateRecord():setRecordByType("SIVES_ARENA_SHOW_LEAVE_FIGHTING", self.seasonInfo.seasonStartAt)
        return true
    end
    return false
end

function QSilvesArena:isLeaveWaiting()
    -- local waitingSeasonStartAt = app:getUserOperateRecord():getRecordByType("SIVES_ARENA_SHOW_ENTER_WAITING")
    -- local seasonStartAt = app:getUserOperateRecord():getRecordByType("SIVES_ARENA_SHOW_LEAVE_WAITING")
    -- if waitingSeasonStartAt and waitingSeasonStartAt == seasonStartAt and self.seasonInfo and self.seasonInfo.seasonStartAt ~= seasonStartAt then
    --     app:getUserOperateRecord():setRecordByType("SIVES_ARENA_SHOW_LEAVE_WAITING", self.seasonInfo.seasonStartAt)
    --     return true
    -- end
    return false
end

-- 是否准备进入巅峰赛，每赛季第一次从fighting阶段到peakFighting阶段时
function QSilvesArena:isEnterPeakFighting()
    local seasonStartAt = app:getUserOperateRecord():getRecordByType("SIVES_ARENA_SHOW_ENTER_PEAK_FIGHTING")
    -- local isNotOpen = app:getUserOperateRecord():compareCurrentTimeWithRecordeTime(DAILY_TIME_TYPE.SILVES_ARENA_OPEN_DOOR)
    if self.seasonInfo and self.seasonInfo.seasonStartAt ~= seasonStartAt then
    -- if isNotOpen then
        -- app:getUserOperateRecord():setRecordByType("SIVES_ARENA_SHOW_ENTER_PEAK_FIGHTING", self.seasonInfo.seasonStartAt) -- 这里不记录
        -- app:getUserOperateRecord():recordeCurrentTime(DAILY_TIME_TYPE.SILVES_ARENA_OPEN_DOOR)
        return true
    end
    return false
end

function QSilvesArena:isShowPeakChampion()
    local seasonStartAt = app:getUserOperateRecord():getRecordByType("SIVES_ARENA_PEAK_SHOW_CHAMPION")
    local curState = self:getCurState()
    -- 优化后面周四早上8点就算新赛季了（比约定的提前了一小时）所以要判断一下seasonStartAt和当前时间，确定是不是新的赛季。因为这个原因，如果玩家在上一赛季没有进过游戏，这个时间段也不会弹出冠军提示了。
    if self.seasonInfo and self.seasonInfo.seasonStartAt < q.serverTime() and self.seasonInfo.seasonStartAt ~= seasonStartAt and curState == self.STATE_REST then
    -- if isNotOpen then
        app:getUserOperateRecord():setRecordByType("SIVES_ARENA_PEAK_SHOW_CHAMPION", self.seasonInfo.seasonStartAt)
        return true
    end
    return false
end

function QSilvesArena:isReadyFightState()
    local state = self:getCurState()
    if state == self.STATE_PLAY and ( not q.isEmpty(self.fightInfo) or not q.isEmpty(self.againstTeamInfo) ) and not q.isEmpty(self.myTeamInfo) then
        return true
    end

    return false
end

-- 获取当前玩法的时间阶段
-- @isIgnoreTeamState 是否忽略组队状态的判断, 或是否忽略16强数据判断
function QSilvesArena:getCurState(isIgnoreTeamState)
    if not self.seasonInfo.seasonStartAt then 
        self._state = self.STATE_REST
        return self._state, nil
    end 

    local curServerTime = q.serverTime()
    local seasonStartAt = self.seasonInfo.seasonStartAt/1000
    local stateEndTime = nil
    if curServerTime >= seasonStartAt 
        and curServerTime < seasonStartAt + self.TIME_OF_READY_DURATION then
        -- 准备阶段 
        self._state = self.STATE_READY
        stateEndTime = seasonStartAt + self.TIME_OF_READY_DURATION

    elseif curServerTime >= seasonStartAt + self.TIME_OF_READY_DURATION 
        and curServerTime < seasonStartAt + self.TIME_OF_READY_DURATION + self.TIME_OF_PLAY_DURATION then
        -- 海选赛阶段
        if not isIgnoreTeamState and q.isEmpty(self.myTeamInfo) or self.myTeamInfo.status == 0 then
            -- 先判断myTeam的状态，如果是组队未完成，继续组队
            self._state = self.STATE_READY
        else
            self._state = self.STATE_PLAY
        end
        stateEndTime = seasonStartAt + self.TIME_OF_READY_DURATION + self.TIME_OF_PLAY_DURATION
    elseif curServerTime >= seasonStartAt + self.TIME_OF_READY_DURATION + self.TIME_OF_PLAY_DURATION
        and curServerTime < seasonStartAt + self.TIME_OF_READY_DURATION + self.TIME_OF_PLAY_DURATION + self.TIME_OF_END_DURATION then
        -- 结算阶段
        self._state = self.STATE_END
        stateEndTime = seasonStartAt + self.TIME_OF_READY_DURATION + self.TIME_OF_PLAY_DURATION + self.TIME_OF_END_DURATION

    elseif curServerTime >= seasonStartAt + self.TIME_OF_READY_DURATION + self.TIME_OF_PLAY_DURATION + self.TIME_OF_END_DURATION
        and curServerTime < seasonStartAt + self.TIME_OF_READY_DURATION + self.TIME_OF_PLAY_DURATION + self.TIME_OF_END_DURATION + self.TIME_OF_PEAK_DURATION then
        -- 巅峰赛阶段
        if not isIgnoreTeamState and q.isEmpty(self.peakTeamInfo) then
            self._state = self.STATE_REST
            stateEndTime = seasonStartAt + self.TIME_OF_SINGLE_SEASON
        else
            self._state = self.STATE_PEAK
            stateEndTime = seasonStartAt + self.TIME_OF_READY_DURATION + self.TIME_OF_PLAY_DURATION + self.TIME_OF_END_DURATION + self.TIME_OF_PEAK_DURATION
        end
    
    else
        -- 休赛阶段
        self._state = self.STATE_REST
        if curServerTime < seasonStartAt then
            stateEndTime = seasonStartAt
        else
            stateEndTime = seasonStartAt + self.TIME_OF_SINGLE_SEASON
        end
    end

    return self._state, stateEndTime
end

-- 获取巅峰赛的时间阶段，如果非巅峰赛阶段，返回nil
function QSilvesArena:getCurPeakState(isIgnoreTeamState)
    if not self.seasonInfo.seasonStartAt then 
        return
    end 

    local curServerTime = q.serverTime()
    local seasonStartAt = self.seasonInfo.seasonStartAt/1000
    if not isIgnoreTeamState and q.isEmpty(self.peakTeamInfo) then
        return nil, seasonStartAt + self.TIME_OF_SINGLE_SEASON
    end
    
    local peakStartAt = seasonStartAt + self.TIME_OF_READY_DURATION + self.TIME_OF_PLAY_DURATION + self.TIME_OF_END_DURATION
    local stateEndTime = nil
    if curServerTime >= peakStartAt 
        and curServerTime < peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION then
        self._peakState = self.PEAK_READY_TO_16
        stateEndTime = peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION

    elseif curServerTime >= peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION 
        and curServerTime < peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION then
        self._peakState = self.PEAK_WAIT_TO_16
        stateEndTime = peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION 

    elseif curServerTime >= peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION 
        and curServerTime < peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION then
        self._peakState = self.PEAK_16_IN_8
        stateEndTime = peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION

    elseif curServerTime >= peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION 
        and curServerTime < peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION then
        self._peakState = self.PEAK_8_IN_4
        stateEndTime = peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION
        
    elseif curServerTime >= peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION 
        and curServerTime < peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION then
        self._peakState = self.PEAK_READY_TO_4
        stateEndTime = peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION
        
    elseif curServerTime >= peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION 
        and curServerTime < peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_WAIT_DURATION then
        self._peakState = self.PEAK_WAIT_TO_4
        stateEndTime = peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_WAIT_DURATION
        
    elseif curServerTime >= peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_WAIT_DURATION 
        and curServerTime < peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_FIGHT_DURATION then
        self._peakState = self.PEAK_4_IN_2
        stateEndTime = peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_FIGHT_DURATION
        
    elseif curServerTime >= peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_FIGHT_DURATION
        and curServerTime < peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_FIGHT_DURATION + self.TIME_OF_PEAK_THIRD_ROUND_READY_DURATION then
        self._peakState = self.PEAK_READY_TO_FINAL
        stateEndTime = peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_FIGHT_DURATION + self.TIME_OF_PEAK_THIRD_ROUND_READY_DURATION
        
    elseif curServerTime >= peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_FIGHT_DURATION + self.TIME_OF_PEAK_THIRD_ROUND_READY_DURATION
        and curServerTime < peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_FIGHT_DURATION + self.TIME_OF_PEAK_THIRD_ROUND_READY_DURATION + self.TIME_OF_PEAK_THIRD_ROUND_WAIT_DURATION then
        self._peakState = self.PEAK_WAIT_TO_FINAL
        stateEndTime = peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_FIGHT_DURATION + self.TIME_OF_PEAK_THIRD_ROUND_READY_DURATION + self.TIME_OF_PEAK_THIRD_ROUND_WAIT_DURATION
        
    elseif curServerTime >= peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_FIGHT_DURATION + self.TIME_OF_PEAK_THIRD_ROUND_READY_DURATION + self.TIME_OF_PEAK_THIRD_ROUND_WAIT_DURATION
        and curServerTime < peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_FIGHT_DURATION + self.TIME_OF_PEAK_THIRD_ROUND_READY_DURATION + self.TIME_OF_PEAK_THIRD_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_THIRD_ROUND_FIGHT_DURATION then
        self._peakState = self.PEAK_FINAL_FIGHT
        stateEndTime = peakStartAt + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_FIGHT_DURATION + self.TIME_OF_PEAK_THIRD_ROUND_READY_DURATION + self.TIME_OF_PEAK_THIRD_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_THIRD_ROUND_FIGHT_DURATION

    else
        self._peakState = nil
        if curServerTime < seasonStartAt then
            stateEndTime = seasonStartAt
        else
            stateEndTime = seasonStartAt + self.TIME_OF_SINGLE_SEASON
        end
    end
    return self._peakState, stateEndTime
end

function QSilvesArena:getCountdown()
    if not self.seasonInfo.seasonStartAt then 
        return "下赛季开始：", "--:--:--"
    end 

    local curServerTime = q.serverTime()
    local state, stateEndTime = self:getCurState(true)
    local titleText = ""

    if state == self.STATE_READY then
        titleText = "比赛开始："
    elseif state == self.STATE_PLAY then
        titleText = "海选结束："
    elseif state == self.STATE_END then
        titleText = "16强揭晓："
    elseif state == self.STATE_PEAK then
        local peakState, peakStateEndTime = self:getCurPeakState()
        if peakState == self.PEAK_READY_TO_16 then
            titleText = "备战结束："
        elseif peakState == self.PEAK_WAIT_TO_16 then
            titleText = "小组赛开始："
        elseif peakState == self.PEAK_16_IN_8 then
            titleText = "8强揭晓："
        elseif peakState == self.PEAK_8_IN_4 then
            titleText = "4强揭晓："
        elseif peakState == self.PEAK_READY_TO_4 then
            titleText = "备战结束："
        elseif peakState == self.PEAK_WAIT_TO_4 then
            titleText = "押注结束："
        elseif peakState == self.PEAK_4_IN_2 then
            titleText = "半决赛结束："
        elseif peakState == self.PEAK_READY_TO_FINAL then
            titleText = "备战结束："
        elseif peakState == self.PEAK_WAIT_TO_FINAL then
            titleText = "押注结束："
        elseif peakState == self.PEAK_FINAL_FIGHT then
            titleText = "决赛结束："
        else
            titleText = "下赛季开始："
        end
        stateEndTime = peakStateEndTime
    elseif state == self.STATE_END then
        titleText = "结算中："
    else
        titleText = "下赛季开始："
    end

    if not stateEndTime then 
        return "下赛季开始：", "--:--:--"
    end 

    local cd = stateEndTime - curServerTime
    if cd < 0 then
        return "下赛季开始：", "--:--:--"
    end

    local cdStr = self:_formatSecTime(cd)
    return titleText, cdStr
end

-- 获取累计银币数量
function QSilvesArena:getTotalSilvesArenaMoneyCount()
    return self.totalSilvesArenaMoney or 0
end

-- 获取赛季战斗次数
function QSilvesArena:getCurSeasonFightCount()
    return self.myTeamInfo.totalFightCount or 0
end

-- 获取奖励是否已经获取
function QSilvesArena:getAwardIsGetById(rid)
    local isGet = false
    local getFightCountReward = self.userInfo.getFightCountReward
    if getFightCountReward then
        for i,v in ipairs(getFightCountReward) do
            if rid == v then
                isGet = true
                break
            end
        end
    end
    return isGet
end

-- 更新
function QSilvesArena:updateAwardId(ids)
    local getFightCountReward = self.userInfo.getFightCountReward
    if not getFightCountReward then
        self.userInfo.getFightCountReward = {}
    end
    for i,v in pairs(ids) do
        if v then
            if not self:getAwardIsGetById(v) then
                table.insert(self.userInfo.getFightCountReward,v)
            end
        end
    end
end

-- 获取是否为组队完成
function QSilvesArena:getCompleteTeam()
    local isInTeam = false

    if not q.isEmpty(self.myTeamInfo) then
        if self.myTeamInfo.status == 1 then
            isInTeam = true
        end
    end
    return isInTeam
end

-- 获取组队信息
function QSilvesArena:getMyCrossTeamInfo()
    return self.myTeamInfo
end

--设置本地默认防守阵容
function QSilvesArena:checkDefenseTeam()
    local actorIds = remote.teamManager:getActorIdsByKey(remote.teamManager.SILVES_ARENA_TEAM)
    if q.isEmpty(actorIds) then
        local team = remote.teamManager:getDefaultTeam(remote.teamManager.SILVES_ARENA_TEAM)
        local battleFormation = remote.teamManager:encodeBattleFormation(team)
        self:silvesArenaChangeDefenseArmyRequest(battleFormation)

        local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.SILVES_ARENA_TEAM)
        teamVO:setTeamDataWithBattleFormation(battleFormation) 

        self.myDefenseTeamBattleFormation = battleFormation
    end   
end

-- 战斗从SILVES_ARENA_GENERATE_FIGHT_INFO开始，后端锁定双方阵容。
-- 然后前后端连续3次套装循环(fightstart、fightend、uploadReplay），每次endInfo记录。
-- 之后，请求战报（伴随battlelog），前端包装成战斗（结束有战斗结算），每次watchInfo记录。
function QSilvesArena:silvesAutoFightCommandSet()
    if q.isEmpty(self.fightInfo) then return end

    self.isInBattle = true

    if (not self.fightInfo.endInfo or #self.fightInfo.endInfo < self.MAX_TEAM_MEMBER_COUNT) and self.curWathingIndex == 0 then
        self:_silvesAutoFightRequest()
        return
    elseif (not self.fightInfo.watchInfo or #self.fightInfo.watchInfo < #self.fightInfo.endInfo) and self.curWathingIndex <= #self.fightInfo.endInfo then
        self:silvesAutoReplayBattle()
        return
    end

    self.isInBattle = false
end

function QSilvesArena:_silvesAutoFightRequest()
    if q.isEmpty(self.fightInfo) then
        self:_onBattleEnd()
        return
    end

    local index = 1
    while true do
        local info = self.fightInfo.endInfo
        if info then
            local isEnd = false
            for _, endIndex in ipairs(info) do
                if endIndex == index then
                    isEnd = true
                    index = index + 1
                    break
                end
            end
            if not isEnd then
                break
            end
        else
            break
        end
    end
    if index > self.MAX_TEAM_MEMBER_COUNT then
        self:silvesAutoReplayBattle()
        return
    elseif index == self.MAX_TEAM_MEMBER_COUNT then
        -- 判断前2场是不是全胜
        if not q.isEmpty(self.fightInfo.scoreList) then
            local curScore = 0
            for _, score in ipairs(self.fightInfo.scoreList) do
                curScore = curScore + score
            end
            if curScore >= 2 or curScore == 0 then
                self:silvesAutoReplayBattle()
                return
            end
        end
    end

    -- 前2场必有，直接执行
    -- 准备fightstart、fightend、uploadReplay
    self:silvesArenaFightStartRequest(index, function(data)
        self:dispatchEvent({name = self.EVENT_FIGHT_START, index = index})
        local silvesArrange = QSilvesArrangement.new()
        silvesArrange:makeReplayBuffer(index, data.gfStartResponse.battleVerify, function(fightReportData)
            self:silvesArenaFightEndRequest(index, data.gfStartResponse.battleVerify, fightReportData, handler(self, self.silvesAutoFightCommandSet), handler(self, self._onBattleEnd))
        end, handler(self, self._onBattleEnd))
    end, handler(self, self._onBattleEnd))
end

function QSilvesArena:silvesAutoReplayBattle(battleResultCallback, abortBattleCallback)
    if q.isEmpty(self.fightInfo) then
        if abortBattleCallback then
            abortBattleCallback()
        end
        self:_onBattleEnd()
        return
    end
    -- print("QSilvesArena:silvesAutoReplayBattle(1)")
    -- QKumo(self.fightInfo.scoreList)
    -- QKumo(self.fightInfo.endInfo)
    -- QKumo(self.fightInfo.watchInfo)
    -- QKumo(self.fightInfo.reportIdList)
    -- print("QSilvesArena:silvesAutoReplayBattle(2)")

    self.curWathingIndex = self.curWathingIndex + 1

    while true do
        local info = self.fightInfo.watchInfo
        if info then
            local isWatch = false
            for _, watchIndex in ipairs(info) do
                if watchIndex == self.curWathingIndex then
                    isWatch = true
                    self.curWathingIndex = self.curWathingIndex + 1
                    break
                end
            end
            if not isWatch then
                break
            end
        else
            break
        end
    end

    if self.fightInfo.skipWatch then
        self:_showSkipBattleResult( self._fightEndAddScore, self._statsDataList,  handler(self, self._onBattleEnd) )
        return
    elseif not q.isEmpty(self.fightInfo.endInfo) and self.curWathingIndex <= #self.fightInfo.endInfo then
        -- 请求战报（伴随battlelog），前端包装成战斗（结束有战斗结算）
        if not self.fightInfo.reportIdList or not self.fightInfo.reportIdList[self.curWathingIndex] then
            if abortBattleCallback then
                abortBattleCallback()
            end
            self:_onBattleEnd()
            return
        end
    else
        if abortBattleCallback then
            abortBattleCallback()
        end
        self:_onBattleEnd()
        return
    end

    local reportId = self.fightInfo.reportIdList[self.curWathingIndex]
    local isFightEnd = #self.fightInfo.reportIdList == self.curWathingIndex

    -- QNotificationCenter.sharedNotificationCenter():addEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattleHandler, self)
    --[[
    SilvesArenaStatsInfo statsDataList

    message SilvesArenaStatsInfo {
        optional int64 reportId = 1; //战报ID
        optional string statsData = 2; //
    }
    ]]
    QReplayUtil:downloadSilvesArenaReplay(reportId, self.curWathingIndex, function (fightReportData, statsDataList, fightEndAddScore)
        QReplayUtil:playSilvesArena(fightReportData, statsDataList, fightEndAddScore, self.curWathingIndex, isFightEnd, handler(self, self.silvesAutoReplayBattle), battleResultCallback)
    end, function()
        if abortBattleCallback then
            abortBattleCallback()
        end
        self:_onBattleEnd()
    end)
end

function QSilvesArena:_onBattleEnd()
    self.isInBattle = false
     self:silvesArenaGetMainInfoRequest(function()
            self.fightInfo = {}
            self.againstTeamInfo = {}
            self:dispatchEvent({name = self.EVENT_FIGHT_END_ALL})
        end)
end

-- 战报历史记录放大镜 self:silvesArenaBattleHistoryDetailRequest()
function QSilvesArena:silvesLookHistoryDetail(reportType, reportIdList, matchingId, isFight, showShare)
    if not matchingId or not reportIdList then
        return
    end

    self:silvesArenaBattleHistoryDetailRequest(reportIdList, matchingId, function ( data )
        local battleReport = data.silvesArenaInfoResponse.battleReport
        local lastfightAt = 0
        for i, v in ipairs(battleReport) do
            if v.fightersData then
                local content = crypto.decodeBase64(v.fightersData)
                local replayInfo = app:getProtocol():decodeBufferToMessage("cc.qidea.wow.client.battle.ReplayInfo", content)

                v.replayInfo = replayInfo
            end
            if lastfightAt == 0 or lastfightAt < v.fightAt then
                lastfightAt = v.fightAt
            end
            QKumo(v.replayInfo)
        end
        battleReport.reportType = reportType
        battleReport.matchingId = matchingId
        battleReport.reportIdList = reportIdList
        battleReport.fightAt = lastfightAt
        
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSilvesArenaRecordDetail",
            options = {info = battleReport, isFight = isFight, showShare = showShare}}, {isPopCurrentDialog = false})
    end)
end

-- 分享
function QSilvesArena:silvesShareFightBatter(reportType,isFight,matchingId,reportIdList)
    if isFight == nil or not matchingId or not reportIdList or not reportType then
        return
    end
    local repostIdStr = ""
    for i,v in pairs(reportIdList) do
        if v then
            if repostIdStr == "" then
                repostIdStr = v
            else    
                repostIdStr = repostIdStr .. ";" .. v
            end
        end
    end
    repostIdStr = repostIdStr .. "$" .. matchingId
    repostIdStr = repostIdStr .. ";" .. (isFight and 1 or 0)

    self:silvesArenaBattleHistoryDetailRequest(reportIdList,matchingId , function ( data )
        
        local battleReport = data.silvesArenaInfoResponse.battleReport
        local team1Name = battleReport[1].team1Name
        local team2Name = battleReport[1].team2Name

        app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogReplayShare", 
                options = {rivalName = team1Name, myNickName = team2Name, replayId = repostIdStr, replayType = reportType}}, {isPopCurrentDialog = false})
    end)
end

-- 查看单个玩家信息
function QSilvesArena:silvesLookUserDetail(userId)
    if not userId then
        return
    end
    self:silvesArenaQueryUserDataRequest(userId, function ( data )
        local fighter = data.silvesArenaInfoResponse.fighter or {}
        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
        options = {fighter = fighter, forceTitle1 = "玩家信息：", model = GAME_MODEL.NORMAL, isPVP = true}}, {isPopCurrentDialog = false})
    end)
end

-- 判断是否可以跨服聊天、组队聊天
-- 第一个赛季的休赛期没有大区信息，所以不允许聊天
function QSilvesArena:checkCanChat()
    local canChat = false
    if self.userInfo then
        if self.userInfo.zoneNo then
            canChat = self.userInfo.zoneNo > 0
        end
    end
    return canChat
end

-- 修改是否有新的队伍聊天信息
function QSilvesArena:modifyNewMessageState(haveNew)
    self._haveNewTeamMessage = haveNew or false
end

-- 获取是否有新的队伍聊天信息
function QSilvesArena:getNewMessageState()
    return self._haveNewTeamMessage
end

function QSilvesArena:getHideMemberIndexList()
    if self:isTimeToHideSecondTeam() then
        return {2, 3}
    elseif self:isTimeToHideThirdTeam() then
        return {3}
    end
    return {}
end

-- 后端给totalForce用totalForce，不给totalForce或者totalForce==0，则自己算
-- 战斗期内，显示出战前2名成员的平均战力（这个只能前端自己算）
function QSilvesArena:getTotalForceAndTotalNumberByTeamInfo(teamInfo, isMe)
    if q.isEmpty(teamInfo) then return end

    local _totalForce = 0
    local _totalNumber = teamInfo.memberCnt or 0
    local debugInfo = {}
    if teamInfo.totalForce and teamInfo.totalForce ~= 0 then
        if self.isDebugModule and not isMe and self:isTimeToHideThirdTeam() then
            app.tip:floatTip("【内部提示】海选战斗期和巅峰赛备战期，后端应该不给totalForce，或totalForce为0，目前数据不对！")
        end
        _totalForce = teamInfo.totalForce
        if _totalNumber == 0 then
            _totalNumber = self.MAX_TEAM_MEMBER_COUNT
        end
    else
        local count = 0 
        local hideIndeList = self:getHideMemberIndexList()

        if not q.isEmpty(teamInfo.leader) then
            if not isMe and #hideIndeList > 0 and teamInfo.leader.silvesArenaFightPos and teamInfo.leader.silvesArenaFightPos ~= 0 then
                -- 可隐藏，有隐藏
                local isHide = false
                for _, index in ipairs(hideIndeList) do
                    if teamInfo.leader.silvesArenaFightPos == index then
                        isHide = true
                        break
                    end
                end

                if not isHide then
                    count = count + 1
                    _totalForce = _totalForce + (teamInfo.leader.force or 0)
                    debugInfo["force"..teamInfo.leader.silvesArenaFightPos] = teamInfo.leader.force or 0
                end
            else
                count = count + 1
                _totalForce = _totalForce + (teamInfo.leader.force or 0)
                debugInfo["force"..teamInfo.leader.silvesArenaFightPos] = teamInfo.leader.force or 0
            end
        end
        if not q.isEmpty(teamInfo.member1) then
            if not isMe and #hideIndeList > 0 and teamInfo.member1.silvesArenaFightPos and teamInfo.member1.silvesArenaFightPos ~= 0 then
                -- 可隐藏，有隐藏
                local isHide = false
                for _, index in ipairs(hideIndeList) do
                    if teamInfo.member1.silvesArenaFightPos == index then
                        isHide = true
                        break
                    end
                end

                if not isHide then
                    count = count + 1
                    _totalForce = _totalForce + (teamInfo.member1.force or 0)
                    debugInfo["force"..teamInfo.member1.silvesArenaFightPos] = teamInfo.member1.force or 0
                end
            else
                count = count + 1
                _totalForce = _totalForce + (teamInfo.member1.force or 0)
                debugInfo["force"..teamInfo.member1.silvesArenaFightPos] = teamInfo.member1.force or 0
            end
        end
        if not q.isEmpty(teamInfo.member2) then
            if not isMe and #hideIndeList > 0 and teamInfo.member2.silvesArenaFightPos and teamInfo.member2.silvesArenaFightPos ~= 0 then
                -- 可隐藏，有隐藏
                local isHide = false
                for _, index in ipairs(hideIndeList) do
                    if teamInfo.member2.silvesArenaFightPos == index then
                        isHide = true
                        break
                    end
                end

                if not isHide then
                    count = count + 1
                    _totalForce = _totalForce + (teamInfo.member2.force or 0)
                    debugInfo["force"..teamInfo.member2.silvesArenaFightPos] = teamInfo.member2.force or 0
                end
            else
                count = count + 1
                _totalForce = _totalForce + (teamInfo.member2.force or 0)
                debugInfo["force"..teamInfo.member2.silvesArenaFightPos] = teamInfo.member2.force or 0
            end
        end

        _totalNumber = count
    end

    debugInfo["force"] = _totalForce
    debugInfo["count"] = _totalNumber
    if self.isDebugModule then
        local state = self:getCurState(true)
        local peakState = self:getCurPeakState()
        debugInfo["info"] = (state or "")..";"..(peakState or "")
        app.tip:floatTip((debugInfo.force1 or "")..";"..(debugInfo.force2 or "")..";"..(debugInfo.force3 or "")..";"..debugInfo.force..";"..debugInfo.count..";"..debugInfo.info, nil, nil, 2)
    end

    if _totalNumber == 0 then return end

    return _totalForce, _totalNumber
end

-- 这里只判断时间节点，不判断是不是玩家自己的队伍
function QSilvesArena:isTimeToHideThirdTeam()
    if self:isTimeToHideSecondTeam() then
        return true
    end

    local state = self:getCurState(true)
    if state == self.STATE_PLAY then
        return true 
    elseif state == self.STATE_PEAK then
        local peakState = self:getCurPeakState()
        if peakState == self.PEAK_READY_TO_16
            or peakState == self.PEAK_READY_TO_4
            or peakState == self.PEAK_READY_TO_FINAL then
            -- 巅峰赛可以调整阵容的时候，都要隐藏，只有押注或者正式开打了才开放
            return true
        end
    end

    return false
end

-- 能隐藏第二队，必然隐藏第三队
function QSilvesArena:isTimeToHideSecondTeam()
    local state = self:getCurState(true)
    if state == self.STATE_PEAK then
        local peakState = self:getCurPeakState()
        if peakState == self.PEAK_READY_TO_4
            or peakState == self.PEAK_READY_TO_FINAL then
            return true
        end
    end

    return false
end

function QSilvesArena:getMySilvesArenaAuditionRankInfo()
    if q.isEmpty(self.myTeamInfo) then return end
    return self._hasTop16Data, self._isTop16, self.myTeamInfo.teamScore, self.myTeamInfo.teamRank
end


function QSilvesArena:checkCanChangeTeam()  
    local state = self:getCurState()
    if state == self.STATE_PEAK then
        local peakState = self:getCurPeakState()
        if peakState == self.PEAK_READY_TO_16
            or peakState == self.PEAK_READY_TO_4
            or peakState == self.PEAK_READY_TO_FINAL then

            return true
        else
            return false
        end
    else
        return true
    end
end

--------------数据处理.KUMOFLAG.--------------

--[[
message SilvesArenaSendInviteResponse {
    optional string userId = 1;                         // 玩家ID
    optional string nickname = 2;                       // 玩家昵称
    optional int32 teamLevel = 3;                       // 玩家战队等级
    optional int64 fightForce = 4;                      // 玩家的战斗力
    optional string teamId = 5;                         // 加入队伍的队伍ID
}
]]
function QSilvesArena:sendSilvesArenaInvite(sendInfo)
    if not q.isEmpty(self.myTeamInfo) then
        self:silvesArenaInviteRejectRequest(sendInfo.userId)
        return
    end

    --如果当前第二层界面有dialog存在则拒绝邀请
    local controllers = app:getNavigationManager():getController(app.middleLayer)
    local count = controllers:countControllers(QUIViewController.TYPE_DIALOG, true)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()

    local isReject = false    --5分钟内拒绝过邀请
    local rejectInviteTime = self.rejectInviteUserIdDict[sendInfo.userId]
    if rejectInviteTime and (rejectInviteTime + 5 * MIN) > q.serverTime() then
        isReject = true
    end

    if isReject or app.battle ~= nil or count > 0 or page.class.__cname ~= "QUIPageMainMenu" then 
        self:silvesArenaInviteRejectRequest(sendInfo.userId)
    else
        if rejectInviteTime then
            self.rejectInviteUserIdDict[sendInfo.userId] = nil
        end
        self:dispatchEvent({name = QSilvesArena.EVENT_SEND_INVITE, sendInfo = sendInfo})
    end
end

-- function QSilvesArena:sendSilvesArenaInviteReject(sendInfo)
--     app.tip:floatTip(string.format("魂师大人，%s正在忙，请稍后再试", (sendInfo.nickname or "")))
-- end

--[[
message SilvesArenaInfoResponse {
    optional SilvesArenaSeasonInfo seasonInfo = 1; //赛季信息
    optional SilvesArenaUserInfo userInfo = 2; //个人信息
    repeated SilvesArenaTeamInfo myTeamInfo = 3; //队伍信息
    repeated SilvesArenaTeamInfoList teamInfoList = 3; //队伍信息
    repeated SilvesArenaFightInfo fightInfo = 4; //战斗信息
    optional SilvesArenaGetOnlineUserInfo onlineUserInfo = 5; //在线用户信息
    optional SilvesArenaApplyInfo applyInfo = 6; //申请信息
    repeated SilvesArenaBattleHistory battleHistoryList = 7; //战斗过的信息
    optional SilvesArenaBattleReport battleReport = 8; //战报
    optional SilvesArenaGameAreaListInfo gameArenList = 9; //envinfo
    repeated string chatInfoList = 13; //聊天记录
    optional int64 totalSilvesArenaMoney = 14; //历史累积希尔维斯银币
    optional int32 fightEndAddScore = 15; //战斗结束增加的积分
    optional Fighter fighter = 16;   // 单个玩家阵容信息
    optional DefenseBattleArmy battleArmy = 17; //阵容信息
    optional bool haveApply = 18; //是否有人向我申请
    optional int32 myTeamRank = 19; //我的队伍排名
    repeated SilvesArenaTeamInfo peakTeamInfos = 20; //巅峰赛队伍数据
}
]]
function QSilvesArena:responseHandler( response, successFunc, failFunc )
    -- QPrintTable( response )
    if response.error == "NO_ERROR" then
        if response.silvesArenaInfoResponse then
            self:_updateSeasonInfo(response.silvesArenaInfoResponse.seasonInfo)
            self:_updateUserInfo(response.silvesArenaInfoResponse.userInfo)
            self:_updateMyTeamInfo(response.silvesArenaInfoResponse.myTeamInfo)
            if response.api == "SILVES_ARENA_QUERY_TEAM_FIGHTER" and not q.isEmpty(response.silvesArenaInfoResponse.teamInfoList) then
                self:_updateEnemyTeamDetailInfo(response.silvesArenaInfoResponse.teamInfoList.teamInfo)
            elseif response.api == "SILVES_ARENA_GET_ROOM_LIST" then
                if q.isEmpty(response.silvesArenaInfoResponse.teamInfoList) or q.isEmpty(response.silvesArenaInfoResponse.teamInfoList.teamInfo) then
                    self:_updateTeamInfo({})
                else
                    self:_updateTeamInfo(response.silvesArenaInfoResponse.teamInfoList.teamInfo)
                end
            elseif response.silvesArenaInfoResponse.teamInfoList then
                if q.isEmpty(response.silvesArenaInfoResponse.teamInfoList) then
                    self:_updateTeamInfo({})
                else
                    self:_updateTeamInfo(response.silvesArenaInfoResponse.teamInfoList.teamInfo)
                end
            end
            self:_updatePeakTeamInfo(response.silvesArenaInfoResponse.peakTeamInfos)
            self:_updateFightInfo(response.silvesArenaInfoResponse.fightInfo)
            self:_updateOnlineUserInfo(response.silvesArenaInfoResponse and response.silvesArenaInfoResponse.onlineUserInfo or {})
            self:_updateApplyInfo(response.silvesArenaInfoResponse.applyInfo)
            self:_updateBattleHistoryList(response.silvesArenaInfoResponse.battleHistoryList)
            self:_updateBattleReport(response.silvesArenaInfoResponse.battleReport)
            self:_updateGameArenList(response.silvesArenaInfoResponse.gameArenList)
            self:_updateRankInfo(response.silvesArenaInfoResponse.rankInfo)
            self:_updateChatInfo(response.silvesArenaInfoResponse.chatInfoList)
            self:_updateDefenseTeam(response.silvesArenaInfoResponse.battleArmy)

            self:_updateChampionTeamInfo(response.silvesArenaInfoResponse.championTeamInfo)

            if response.api == "SILVES_PEAK_GET_MY_BET_INFO" then
                self:_updateStakeInfo(response.silvesArenaInfoResponse.silvesPeakUserBetInfo)
            end
            if response.silvesArenaInfoResponse.totalSilvesArenaMoney then
                self.totalSilvesArenaMoney = response.silvesArenaInfoResponse.totalSilvesArenaMoney
            end

            if response.silvesArenaInfoResponse.haveApply ~= nil then
                self.haveApply = response.silvesArenaInfoResponse.haveApply
            end

            -- 这个更新模式和陈昊伟约定的
            if response.silvesArenaInfoResponse.myTeamRank ~= nil and response.silvesArenaInfoResponse.myTeamRank > 0 then
                self.myTeamRank = response.silvesArenaInfoResponse.myTeamRank
            end

            if response.silvesArenaInfoResponse and response.api == "SILVES_ARENA_GET_MY_INFO" then
                self._isTop16 = response.silvesArenaInfoResponse.isTop16
                self._hasTop16Data = response.silvesArenaInfoResponse.hasTop16Data
            end

            if response.silvesArenaInfoResponse and (response.api == "SILVES_ARENA_GET_MY_INFO" or response.api == "SILVES_ARENA_GET_MAIN_INFO") then
                self.myDefenseTeamReplayData = response.silvesArenaInfoResponse.replayData
            end
        end

        if response.todayTeamBattleInfoResponse then
            self:_updateTodayTeamBattleInfo(response.todayTeamBattleInfoResponse.todayTeamBattleInfo)
        end

        -- if response.silvesArenaGetTargetTeamResponse then
        --     self:_upda
        -- end

        if response.api == "SILVES_ARENA_MATCH" then
            table.insert(self._dispatchTbl, {name = QSilvesArena.STATE_UPDATE})
            table.insert(self._dispatchTbl, {name = QSilvesArena.TEAM_UPDATE})
        end
        if response.api == "SILVES_ARENA_GENERATE_FIGHT_INFO" then
            self.curWathingIndex = 0
        end

        if response.api == "SILVES_ARENA_GET_TEAM_REWARD" then
            table.insert(self._dispatchTbl, {name = QSilvesArena.EVENT_TEAM_AWARD})
        end

        if response.api == "SILVES_ARENA_CREATE_TEAM" or response.api == "SILVES_ARENA_QUIT_TEAM" then
            table.insert(self._dispatchTbl, {name = QSilvesArena.TEAM_UPDATE})
        end
        if response.api == "SILVES_PEAK_SET_BET" then
            remote.user:addPropNumForKey("todaySilvesArenaPeakStakeCount")
            table.insert(self._dispatchTbl, {name = QSilvesArena.EVENT_STAKE_UPDATE})
        end

        if response.api == "SILVES_ARENA_CHANGE_BATTLE_USER" then
            table.insert(self._dispatchTbl, {name = QSilvesArena.EVENT_PEAK_TEAM_UPDATE})
        end
    end

    if successFunc then 
        successFunc(response) 
        self:_dispatchAll()
        return
    end

    if failFunc then 
        failFunc(response)
    end

    self:_dispatchAll()
end

--[[
SILVES_ARENA_MEMBER_JOIN = 47; //希尔维斯大斗魂场-新人加入队伍
SILVES_ARENA_MEMBER_QUIT = 48; //希尔维斯大斗魂场-队员退出队伍
SILVES_ARENA_MEMBER_KICKED = 49; //希尔维斯大斗魂场-队员被踢出队伍
SILVES_ARENA_MEMBER_CHAT = 50; //希尔维斯大斗魂场-向队员推送聊天信息
]]
function QSilvesArena:pushHandler( data )
    QPrintTable(data)
    if data.messageType == "SILVES_ARENA_MEMBER_JOIN" or data.messageType == "SILVES_ARENA_MEMBER_QUIT" or data.messageType == "SILVES_ARENA_MEMBER_KICKED" --[[or data.messageType == "SILVES_ARENA_MEMBER_CHAT"]] then
        self:silvesArenaGetMainInfoRequest(function()
            table.insert(self._dispatchTbl, {name = QSilvesArena.TEAM_UPDATE})
        end)
    end
    if data.messageType == "SILVES_ARENA_MEMBER_CHAT" then
        app:getServerChatData():refreshSilvesTeamChatHistory(true)
        self:modifyNewMessageState(true)
    end
end

--[[
    SILVES_ARENA_GET_MY_INFO = 10160; //希尔维斯大斗魂场--登录信息 无request SilvesArenaInfoResponse
    SILVES_ARENA_GET_MAIN_INFO = 10161; //希尔维斯大斗魂场--主界面信息 无request SilvesArenaInfoResponse
    SILVES_ARENA_GET_ROOM_LIST = 10163; //希尔维斯大斗魂场--获取房间列表 无request SilvesArenaInfoResponse
    SILVES_ARENA_CREATE_TEAM = 10165; //希尔维斯大斗魂场--创建房间 SilvesArenaCreateTeamRequest  SilvesArenaInfoResponse
    SILVES_ARENA_GET_APPLY_LIST = 10166; //希尔维斯大斗魂场--获取申请列表 无request SilvesArenaInfoResponse
    SILVES_ARENA_APPLY_TEAM = 10167; //希尔维斯大斗魂场--申请队伍 SilvesArenaApplyTeamRequest SilvesArenaInfoResponse isCancel = true 就是取消申请
    SILVES_ARENA_PROMISS_TEAM = 10168; //希尔维斯大斗魂场--答应加入队伍 SilvesArenaPromissTeamRequest SilvesArenaInfoResponse
    SILVES_ARENA_JOIN_TEAM = 10169; //希尔维斯大斗魂场--加入队伍 SilvesArenaJoinTeamRequest SilvesArenaInfoResponse
    SILVES_ARENA_QUIT_TEAM = 10170; //希尔维斯大斗魂场--离开队伍 SilvesArenaQuitTeamRequest SilvesArenaInfoResponse
    SILVES_ARENA_MATCH = 10171; //希尔维斯大斗魂场--匹配 无request SilvesArenaInfoResponse
    SILVES_ARENA_INVITE = 10172; //希尔维斯大斗魂场--邀请 SilvesArenaInviteRequest SilvesArenaInfoResponse
    SILVES_ARENA_CHAT = 10174; //希尔维斯大斗魂场--聊天 SilvesArenaChatRequest SilvesArenaInfoResponse 聊天类型 1是大厅聊天 2是队伍分享 3组队聊天
    SILVES_ARENA_GET_TEAM_REWARD = 10175; //希尔维斯大斗魂场--领取队伍奖励 SilvesArenaGetTeamRewardRequest SilvesArenaInfoResponse
    SILVES_ARENA_CHANGE_BATTLE_USER = 10176; //希尔维斯大斗魂场--修改出站顺序 SilvesArenaChangeBattleUserPosRequest SilvesArenaInfoResponse
    SILVES_ARENA_CHANGE_DEFENSE_ARMY = 10178; //希尔维斯大斗魂场--修改防守阵容 无request SilvesArenaInfoResponse
    SILVES_ARENA_GET_ZONE_LIST = 10179; //希尔维斯大斗魂场--获取匹配大区集合 无request SilvesArenaInfoResponse
    SILVES_ARENA_GET_TEAM_HISTORY = 10180; //希尔维斯大斗魂场--获取历史战斗记录 SilvesArenaTeamHistoryRequest SilvesArenaInfoResponse
    SILVES_ARENA_REFRESH = 10182; //希尔维斯大斗魂场--刷新对手 无request SilvesArenaInfoResponse
    SILVES_ARENA_GENERATE_FIGHT_INFO = 10184; //希尔维斯大斗魂场--生成战斗信息 SilvesArenaGenerateFightInfoRequest SilvesArenaInfoResponse
    SILVES_ARENA_KICK_OFF_TEAM = 10185; //希尔维斯大斗魂场--踢出队伍 SilvesArenaKickOffTeamRequest SilvesArenaInfoResponse
    SILVES_ARENA_INVITE_REJECT = 10186; //希尔维斯大斗魂场--拒绝邀请 SilvesArenaInviteRejectRequest SilvesArenaInfoResponse
    SILVES_ARENA_WATCH_REPORT = 10187; //希尔维斯大斗魂场--观看战报 SilvesArenaWatchFightReportRequest SilvesArenaInfπoResponse
    SILVES_ARENA_QUERY_TEAM_FIGHTER = 10188; //希尔维斯大斗魂场--查询对手信息 SilvesArenaQueryTeamFighterRequest SilvesArenaInfoResponse
    SILVES_ARENA_GET_ONLINE_USER = 10189; //希尔维斯大斗魂场--获取在线的宗门玩家或者用户 无request SilvesArenaInfoResponse
    SILVES_ARENA_GET_BATTLE_HISTORY_DETAIL = 10190; //希尔维斯大斗魂场--战斗历史记录放大镜请求 SilvesArenaBattleHistoryDetailRequest SilvesArenaInfoResponse
    SILVES_ARENA_GET_TODAY_TEAM_BATTLE_INFO = 10191; //希尔维斯大斗魂场--今日小队战斗情况请求 无request SilvesArenaTodayTeamBattleInfoResponse
    SILVES_ARENA_QUERY_FIGHTERS_DATA = 10192; //希尔维斯大斗魂场--请求fightersData SilvesArenaQueryFightersDataRequest SilvesArenaInfoResponse
    SILVES_ARENA_GET_FIGHTER = 10193; //希尔维斯大斗魂场--请求单个玩家阵容数据 SilvesArenaGetFighterRequest SilvesArenaInfoResponse

    //----------------------希尔维斯 -巅峰赛开始
    SILVES_PEAK_GET_BET_INFO = 10240;               // 获取押注信息请求 SilvesPeakBetInfoRequest SilvesPeakBetInfoResponse
    SILVES_PEAK_SET_BET = 10241;                    // 设置押注  SilvesPeakBetRequest  SilvesPeakBetResponse
    SILVES_PEAK_GET_MY_BET_INFO = 10242;            // 获取自身押注列表信息  SilvesPeakGetMyBetInfoRequest  SilvesPeakGetMyBetInfoResponse
    SILVES_PEAK_GET_BATTLE_INFO = 10243;            // 获取对战阵容结果  SilvesPeakGetBattleInfoRequest  SilvesArenaInfoResponse
    SILVES_PEAK_PREV_TOP3       = 10247;            // 获取上个赛季top3  无  SilvesArenaInfoResponse
    SILVES_PEAK_SET_REPLAY_DATA = 10250;            // 设置replayData数据
    SILVES_GET_TARGET_TEAM       = 10248;            //获取目标队伍   SilvesGetTargetTeamRequest  SilvesArenaGetTargetTeamResponse
    //----------------------希尔维斯 -巅峰赛结束
]]

function QSilvesArena:silvesArenaGetMyInfoRequest(success, fail, status)
    local request = { api = "SILVES_ARENA_GET_MY_INFO"}
    app:getClient():requestPackageHandler("SILVES_ARENA_GET_MY_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QSilvesArena:silvesArenaGetMainInfoRequest(success, fail, status)
    local request = { api = "SILVES_ARENA_GET_MAIN_INFO"}
    app:getClient():requestPackageHandler("SILVES_ARENA_GET_MAIN_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QSilvesArena:silvesArenaGetRoomListRequest(success, fail, status)
    local request = { api = "SILVES_ARENA_GET_ROOM_LIST"}
    app:getClient():requestPackageHandler("SILVES_ARENA_GET_ROOM_LIST", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string teamName = 1; //队伍名称
-- optional int64 minForce = 2; //最低战斗力
function QSilvesArena:silvesArenaCreateTeamRequest(teamName, minForce, success, fail, status)
    local silvesArenaCreateTeamRequest = {teamName = teamName, minForce = minForce}
    local request = { api = "SILVES_ARENA_CREATE_TEAM", silvesArenaCreateTeamRequest = silvesArenaCreateTeamRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_CREATE_TEAM", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QSilvesArena:silvesArenaGetApplyListRequest(success, fail, status)
    local request = { api = "SILVES_ARENA_GET_APPLY_LIST"}
    app:getClient():requestPackageHandler("SILVES_ARENA_GET_APPLY_LIST", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string teamId = 1; //队伍ID
-- optional bool isCancel = 2; //是否是取消
function QSilvesArena:silvesArenaApplyTeamRequest(teamId, isCancel, success, fail, status)
    local silvesArenaApplyTeamRequest = {teamId = teamId, isCancel = isCancel}
    local request = { api = "SILVES_ARENA_APPLY_TEAM", silvesArenaApplyTeamRequest = silvesArenaApplyTeamRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_APPLY_TEAM", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string applyUserId = 1; //申请的userId
-- optional bool isCancel = 2; //是否是通过
function QSilvesArena:silvesArenaPromissTeamRequest(applyUserId, isCancel, success, fail, status)
    local silvesArenaPromissTeamRequest = {applyUserId = applyUserId, isCancel = isCancel}
    local request = { api = "SILVES_ARENA_PROMISS_TEAM", silvesArenaPromissTeamRequest = silvesArenaPromissTeamRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_PROMISS_TEAM", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string teamId = 1; //队伍ID
function QSilvesArena:silvesArenaJoinTeamRequest(teamId, success, fail, status)
    local silvesArenaJoinTeamRequest = {teamId = teamId}
    local request = { api = "SILVES_ARENA_JOIN_TEAM", silvesArenaJoinTeamRequest = silvesArenaJoinTeamRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_JOIN_TEAM", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string teamId = 1; //队伍ID
function QSilvesArena:silvesArenaQuitTeamRequest(teamId, success, fail, status)
    local silvesArenaQuitTeamRequest = {teamId = teamId}
    local request = { api = "SILVES_ARENA_QUIT_TEAM", silvesArenaQuitTeamRequest = silvesArenaQuitTeamRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_QUIT_TEAM", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QSilvesArena:silvesArenaMatchRequest(success, fail, status)
    local request = { api = "SILVES_ARENA_MATCH"}
    app:getClient():requestPackageHandler("SILVES_ARENA_MATCH", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- repeated string consortiaMemberId = 1; // 公会会员ID
-- optional string teamId = 2; // 队伍ID
function QSilvesArena:silvesArenaInviteRequest(consortiaMemberId, teamId, success, fail, status)
    local silvesArenaInviteRequest = {consortiaMemberId = consortiaMemberId, teamId = teamId}
    local request = { api = "SILVES_ARENA_INVITE", silvesArenaInviteRequest = silvesArenaInviteRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_INVITE", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QSilvesArena:silvesArenaShareTeamRequest(success, fail, status)
    local request = { api = "SILVES_ARENA_SHARE_TEAM"}
    app:getClient():requestPackageHandler("SILVES_ARENA_SHARE_TEAM", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional ChatType type = 1; //聊天类型 1是大厅聊天 2是队伍分享 3组队聊天
-- optional string content = 2; //聊天内容
function QSilvesArena:silvesArenaChatRequest(type, content, success, fail, status)
    local silvesArenaChatRequest = {type = type, content = content}
    local request = { api = "SILVES_ARENA_CHAT", silvesArenaChatRequest = silvesArenaChatRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_CHAT", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional ChatType type = 1; //聊天类型 1是跨服 3组队聊天
function QSilvesArena:silvesArenaChatHistoryRequest(type, success, fail, status)
    local silvesArenaGetChatListRequest = {type = type}
    local request = { api = "SILVES_ARENA_GET_CHAT_LIST", silvesArenaGetChatListRequest = silvesArenaGetChatListRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_GET_CHAT_LIST", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- repeated int32 rewardIdList = 1; //奖励id集合
function QSilvesArena:silvesArenaGetTeamRewardRequest(rewardIdList, success, fail, status)
    local silvesArenaGetTeamRewardRequest = {rewardIdList = rewardIdList}
    local request = { api = "SILVES_ARENA_GET_TEAM_REWARD", silvesArenaGetTeamRewardRequest = silvesArenaGetTeamRewardRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_GET_TEAM_REWARD", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--[[
message SilvesArenaBattleOrder {
    optional string userId = 1; //玩家id
    optional int32 order = 2; //顺序 1,2,3
}
]]
-- -repeated SilvesArenaBattleOrder battleOrder = 1;//出站顺序
function QSilvesArena:silvesArenaChangeBattleUserPosRequest(battleOrder, success, fail, status)
    local silvesArenaChangeBattleUserPosRequest = {battleOrder = battleOrder}
    local request = { api = "SILVES_ARENA_CHANGE_BATTLE_USER", silvesArenaChangeBattleUserPosRequest = silvesArenaChangeBattleUserPosRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_CHANGE_BATTLE_USER", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QSilvesArena:silvesArenaChangeDefenseArmyRequest(battleFormation, success, fail, status)
    local replayData = QReplayUtil:createReplayFighterSingleTeamBuffer(remote.teamManager.SILVES_ARENA_TEAM)
    replayData = crypto.encodeBase64(replayData)  
    local silvesModifyArmyRequest = {replayData = replayData}
    local request = { api = "SILVES_ARENA_CHANGE_DEFENSE_ARMY", battleFormation = battleFormation, silvesModifyArmyRequest = silvesModifyArmyRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_CHANGE_DEFENSE_ARMY", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QSilvesArena:silvesArenaChangeReplayDataRequest()
    local replayData = QReplayUtil:createReplayFighterSingleTeamBuffer(remote.teamManager.SILVES_ARENA_TEAM)
    replayData = crypto.encodeBase64(replayData)  
    local silvesModifyArmyRequest = {replayData = replayData}
    local request = { api = "SILVES_PEAK_SET_REPLAY_DATA", silvesModifyArmyRequest = silvesModifyArmyRequest}
    app:getClient():requestPackageHandler("SILVES_PEAK_SET_REPLAY_DATA", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QSilvesArena:silvesArenaGetZoneListRequest(success, fail, status)
    local request = { api = "SILVES_ARENA_GET_ZONE_LIST"}
    app:getClient():requestPackageHandler("SILVES_ARENA_GET_ZONE_LIST", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int32 type = 1; // 0:防守记录; 1:进攻记录
function QSilvesArena:silvesArenaTeamHistoryRequest(type, success, fail, status)
    local silvesArenaTeamHistoryRequest = {type = type}
    local request = { api = "SILVES_ARENA_GET_TEAM_HISTORY", silvesArenaTeamHistoryRequest = silvesArenaTeamHistoryRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_GET_TEAM_HISTORY", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QSilvesArena:silvesArenaRefreshRequest(success, fail, status)
    local request = { api = "SILVES_ARENA_REFRESH"}
    app:getClient():requestPackageHandler("SILVES_ARENA_REFRESH", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string rivalTeamId = 1; //对手teamId
-- repeated SilvesArenaBattleOrder battleOrderList = 2; //出站顺序
-- optional bool skipWatch = 3; //是否跳过战斗
function QSilvesArena:silvesArenaGenerateFightInfoRequest(rivalTeamId, battleOrderList, skipWatch, success, fail, status)
    self._fightEndAddScore = nil
    self._statsDataList = nil
    local silvesArenaGenerateFightInfoRequest = {rivalTeamId = rivalTeamId, battleOrderList = battleOrderList, skipWatch = skipWatch}
    local request = { api = "SILVES_ARENA_GENERATE_FIGHT_INFO", silvesArenaGenerateFightInfoRequest = silvesArenaGenerateFightInfoRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_GENERATE_FIGHT_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string teamMemberId = 1; //队员ID
function QSilvesArena:silvesArenaKickOffTeamRequest(teamMemberId, success, fail, status)
    local silvesArenaKickOffTeamRequest = {teamMemberId = teamMemberId}
    local request = { api = "SILVES_ARENA_KICK_OFF_TEAM", silvesArenaKickOffTeamRequest = silvesArenaKickOffTeamRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_KICK_OFF_TEAM", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string userId = 1; // 发起组队邀请的玩家ID
function QSilvesArena:silvesArenaInviteRejectRequest(userId, success, fail, status)
    local silvesArenaInviteRejectRequest = {userId = userId}
    local request = { api = "SILVES_ARENA_INVITE_REJECT", silvesArenaInviteRejectRequest = silvesArenaInviteRejectRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_INVITE_REJECT", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int64 fightReportId = 1; //战报id
-- optional bool isFightEndWatch = 2; //是否是战斗结束后的观看
-- optional int32 index = 3; // 观看战报的index 1 2 3
function QSilvesArena:silvesArenaWatchFightReportRequest(fightReportId, isFightEndWatch, index, success, fail, status)
    local silvesArenaWatchFightReportRequest = {fightReportId = fightReportId, isFightEndWatch = isFightEndWatch, index = index}
    local request = { api = "SILVES_ARENA_WATCH_REPORT", silvesArenaWatchFightReportRequest = silvesArenaWatchFightReportRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_WATCH_REPORT", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string team1Id = 1; // 队伍id
-- optional string team2Id = 1; // 队伍id
function QSilvesArena:silvesArenaQueryTeamFighterRequest(team1Id, team2Id, success, fail, status)
    local silvesArenaQueryTeamFighterRequest = {team1Id = team1Id, team2Id = team2Id}
    local request = { api = "SILVES_ARENA_QUERY_TEAM_FIGHTER", silvesArenaQueryTeamFighterRequest = silvesArenaQueryTeamFighterRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_QUERY_TEAM_FIGHTER", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QSilvesArena:silvesArenaGetOnlineUserRequest(success, fail, status)
    local request = { api = "SILVES_ARENA_GET_ONLINE_USER"}
    app:getClient():requestPackageHandler("SILVES_ARENA_GET_ONLINE_USER", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string fightReportIds = 1; // 战报IDs
    -- optional string matchingId = 2; // 匹配ID
function QSilvesArena:silvesArenaBattleHistoryDetailRequest(fightReportIds, matchingId, success, fail, status)
    local silvesArenaBattleHistoryDetailRequest = {fightReportIds = fightReportIds, matchingId = matchingId}
    local request = { api = "SILVES_ARENA_GET_BATTLE_HISTORY_DETAIL", silvesArenaBattleHistoryDetailRequest = silvesArenaBattleHistoryDetailRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_GET_BATTLE_HISTORY_DETAIL", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QSilvesArena:silvesArenaTodayTeamBattleInfoRequest(success, fail, status)
    local request = { api = "SILVES_ARENA_GET_TODAY_TEAM_BATTLE_INFO"}
    app:getClient():requestPackageHandler("SILVES_ARENA_GET_TODAY_TEAM_BATTLE_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int64 fightReportId = 1; // 战报ID
function QSilvesArena:silvesArenaQueryFightersDataRequest(fightReportId, success, fail, status)
    local silvesArenaQueryFightersDataRequest = {fightReportId = fightReportId}
    local request = { api = "SILVES_ARENA_QUERY_FIGHTERS_DATA", silvesArenaQueryFightersDataRequest = silvesArenaQueryFightersDataRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_QUERY_FIGHTERS_DATA", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--[[
message SilvesArenaFightStartRequest {
    optional string team1UserId = 1; // 我方出阵userId
    optional string team2UserId = 2; // 对手userId
    optional int32 index = 3; // index
}
]]
function QSilvesArena:silvesArenaFightStartRequest(index, success, fail, status)
    local battleFormation = {}
    local team1UserId = ""
    local team2UserId = ""
    for _, attackFight in ipairs(self.fightInfo.attackFightInfo) do
        if attackFight.silvesArenaFightPos == index then
            team1UserId = attackFight.userId
            battleFormation = self:encodeBattleFormation(attackFight)
        end
    end
    for _, defenseFight in ipairs(self.fightInfo.defenseFightInfo) do
        if defenseFight.silvesArenaFightPos == index then
            team2UserId = defenseFight.userId
        end
    end
    local silversArenaFightStartRequest = {team1UserId = team1UserId, team2UserId = team2UserId, index = index} 
    local gfStartRequest = {battleType = BattleTypeEnum.SILVES_ARENA, battleFormation = battleFormation, silversArenaFightStartRequest = silversArenaFightStartRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_START", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--[[
message SilvesArenaFightEndRequest {
    optional string team1UserId = 1; // 我方出阵userId
    optional string team2UserId = 2; // 对手userId
    optional int32 index = 3; // index
}
]]
function QSilvesArena:silvesArenaFightEndRequest(index, battleKey, content, success, fail, status)
    local team1UserId = ""
    local team2UserId = ""
    local curAttackFight = {}
    local curDefenseFight = {}
    for _, attackFight in ipairs(self.fightInfo.attackFightInfo) do
        if attackFight.silvesArenaFightPos == index then
            team1UserId = attackFight.userId
            curAttackFight = attackFight
        end
    end
    for _, defenseFight in ipairs(self.fightInfo.defenseFightInfo) do
        if defenseFight.silvesArenaFightPos == index then
            team2UserId = defenseFight.userId
            curDefenseFight = defenseFight
        end
    end

    local battleVerify = q.battleVerifyHandler(battleKey)
    local silversArenaFightEndRequest = {team1UserId = team1UserId, team2UserId = team2UserId, index = index} 
    
    -- local content = readFromBinaryFile("last.reppb")
    local fightReportData = crypto.encodeBase64(content)

    local gfEndRequest = {battleType = BattleTypeEnum.SILVES_ARENA, battleVerify = battleVerify, isQuick = false, isWin = nil, fightReportData = fightReportData, silversArenaFightEndRequest = silversArenaFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_END", request, function (response)
        if self.fightInfo and self.fightInfo.skipWatch then
            if response and response.silvesArenaInfoResponse then
                if response.silvesArenaInfoResponse.fightEndAddScore then
                    self._fightEndAddScore = response.silvesArenaInfoResponse.fightEndAddScore
                end
                if response.silvesArenaInfoResponse.battleReport and response.silvesArenaInfoResponse.battleReport[1] and response.silvesArenaInfoResponse.battleReport[1].statsDataList then
                    self._statsDataList = response.silvesArenaInfoResponse.battleReport[1].statsDataList
                end
                self:dispatchEvent({name = self.EVENT_FIGHT_END, index = index, isWin = response.gfEndResponse.isWin})
            end
        end
        local replayInfo = QReplayUtil:generateReplayInfo(curAttackFight, curDefenseFight, response.gfEndResponse.isWin and 1 or 2, nil)
        QReplayUtil:uploadReplay(response.gfEndResponse.reportId, replayInfo, function() end, function() end, REPORT_TYPE.SILVES_ARENA)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string targetUserId = 1; // 获取的玩家ID
function QSilvesArena:silvesArenaQueryUserDataRequest(targetUserId, success, fail, status)
    local silvesArenaGetFighterRequest = {targetUserId = targetUserId}
    local request = { api = "SILVES_ARENA_GET_FIGHTER", silvesArenaGetFighterRequest = silvesArenaGetFighterRequest}
    app:getClient():requestPackageHandler("SILVES_ARENA_GET_FIGHTER", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string team1Id = 1; // 队伍1ID
-- optional string team2Id = 2; // 队伍2ID
function QSilvesArena:silvesPeakBetInfoRequest(team1Id, team2Id, success, fail, status)
    local silvesPeakBetInfoRequest = {team1Id = team1Id, team2Id = team2Id}
    local request = { api = "SILVES_PEAK_GET_BET_INFO", silvesPeakBetInfoRequest = silvesPeakBetInfoRequest}
    app:getClient():requestPackageHandler("SILVES_PEAK_GET_BET_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end  

-- optional string team1Id = 1; // 队伍1ID
-- optional string team2Id = 2; // 队伍2ID
-- optional int32 betAward = 3; //押注的金额
-- optional int32 scoreId = 4; //押注的比分id 1 2 3 4
function QSilvesArena:silvesPeakBetRequest(team1Id, team2Id, betAward, scoreId, success, fail, status)
    local silvesPeakBetRequest = {team1Id = team1Id, team2Id = team2Id, betAward = betAward, scoreId = scoreId}
    local request = { api = "SILVES_PEAK_SET_BET", silvesPeakBetRequest = silvesPeakBetRequest}
    app:getClient():requestPackageHandler("SILVES_PEAK_SET_BET", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end  

-- 暂无
function QSilvesArena:silvesPeakGetMyBetInfoRequest(success, fail, status)
    local silvesPeakGetMyBetInfoRequest = {}
    local request = { api = "SILVES_PEAK_GET_MY_BET_INFO", silvesPeakGetMyBetInfoRequest = silvesPeakGetMyBetInfoRequest}
    app:getClient():requestPackageHandler("SILVES_PEAK_GET_MY_BET_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional string team1Id = 1; //team1Id
-- optional string team2Id = 2; //team2Id
function QSilvesArena:silvesPeakGetBattleInfoRequest(team1Id, team2Id, success, fail, status)
    local silvesPeakGetBattleInfoRequest = {team1Id = team1Id, team2Id = team2Id}
    local request = { api = "SILVES_PEAK_GET_BATTLE_INFO", silvesPeakGetBattleInfoRequest = silvesPeakGetBattleInfoRequest}
    app:getClient():requestPackageHandler("SILVES_PEAK_GET_BATTLE_INFO", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

function QSilvesArena:silvesPeakGetChampionTeamInfoRequest(success, fail, status)
    local request = { api = "SILVES_PEAK_PREV_TOP3"}
    app:getClient():requestPackageHandler("SILVES_PEAK_PREV_TOP3", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- optional int64 teamId = 1; 
function QSilvesArena:silvesGetTargetTeamRequest(teamId, success, fail, status)
    local silvesGetTargetTeamRequest = {teamId = teamId}
    local request = { api = "SILVES_GET_TARGET_TEAM", silvesGetTargetTeamRequest = silvesGetTargetTeamRequest}
    app:getClient():requestPackageHandler("SILVES_GET_TARGET_TEAM", request, function (response)
        self:responseHandler(response, success)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end


--------------本地工具.KUMOFLAG.--------------

function QSilvesArena:_dispatchAll()
    if q.isEmpty(self._dispatchTbl) then return end

    local tbl = {}
    local tblKey = ""
    for _, eventTbl in pairs(self._dispatchTbl) do
        tblKey = eventTbl.name
        local eventInfo = {}
        if eventTbl.param then
            for key, value in pairs(eventTbl.param) do
                tblKey = tblKey .. key
                eventInfo[key] = value
            end
        end
        if not tbl[tblKey] then
            eventInfo.name = eventTbl.name
            self:dispatchEvent(eventInfo)
            tbl[tblKey] = true
        end
    end
    self._dispatchTbl = {}
end

-- 将秒为单位的数字转换成 0天 00：00：00格式
function QSilvesArena:_formatSecTime( sec )
    -- local d = math.floor(sec/DAY)
    -- local h = math.floor((sec%DAY)/HOUR)
    local h = math.floor(sec/HOUR)
    local m = math.floor((sec%HOUR)/MIN)
    local s = math.floor(sec%MIN)

    -- if d > 0 then
    --     return string.format("%d天 %02d:%02d:%02d", d, h, m, s)
    -- else
        return string.format("%02d:%02d:%02d", h, m, s)
    -- end
end

function QSilvesArena:encodeBattleFormation( fighter )
    local battleFormation = {}
    
    if fighter ~= nil then
        battleFormation.mainHeroIds = {} -- 主力
        battleFormation.sub1HeroIds = {} -- 援助1
        battleFormation.sub2HeroIds = {} -- 援助2
        battleFormation.sub3HeroIds = {} -- 援助3
        battleFormation.soulSpiritId = {} -- 魂灵
        battleFormation.godArmIdList = {} -- 神器

        battleFormation.activeSub1HeroId = 0 -- 援助1，施技英雄
        battleFormation.activeSub2HeroId = 0 -- 援助2，施技英雄   
        battleFormation.activeSub3HeroId = 0 -- 援助3，施技英雄

        if fighter.heros then
            for _, value in ipairs(fighter.heros) do
                table.insert(battleFormation.mainHeroIds, value.actorId)
            end
        end
        if fighter.subheros then
            for _, value in ipairs(fighter.subheros) do
                table.insert(battleFormation.sub1HeroIds, value.actorId)
            end
        end
        if fighter.sub2heros then
            for _, value in ipairs(fighter.sub2heros) do
                table.insert(battleFormation.sub2HeroIds, value.actorId)
            end
        end
        if fighter.sub3heros then
            for _, value in ipairs(fighter.sub3heros) do
                table.insert(battleFormation.sub3HeroIds, value.actorId)
            end
        end
        if fighter.soulSpirit then
            for _, value in ipairs(fighter.soulSpirit) do
                table.insert(battleFormation.soulSpiritId, value.id)
            end
        end
        if fighter.godArm1List then
            for _, value in ipairs(fighter.godArm1List) do
                table.insert(battleFormation.godArmIdList, value.id)
            end
        end
        battleFormation.activeSub1HeroId = fighter.activeSubActorId or 0
        battleFormation.activeSub2HeroId = fighter.activeSub2ActorId or 0 
        battleFormation.activeSub3HeroId = fighter.activeSub3ActorId or 0
    end

    return battleFormation
end


--[[
message SilvesArenaSeasonInfo {
    optional int32 seasonNo = 1; //  赛季
    optional int64 seasonStartAt = 2; //  赛季开始时间
    optional int64 seasonEndAt = 3; //  赛季结束时间
}
]]
-- 一个完整赛季，周四9:00～下周四8:59，前端和后端的约定
function QSilvesArena:_updateSeasonInfo(seasonInfo)
    if q.isEmpty(seasonInfo) then return end
    local curServerTime = q.serverTime()
    local updateAlarmClock = function(clockTime, alarmClockName, callback)
        local timeTbl = q.date("*t", clockTime)
        print("[QSilvesArena] alarmClockName : ", alarmClockName, string.format("日期：%d/%d/%d，周%d，%d:%d:%d", timeTbl.year, timeTbl.month, timeTbl.day, (timeTbl.wday - 1), timeTbl.hour, timeTbl.min, timeTbl.sec))
        app:getAlarmClock():deleteAlarmClock(alarmClockName)
        if curServerTime < clockTime then
            app:getAlarmClock():createNewAlarmClock(alarmClockName, clockTime, function()
                    callback()
                end)
        end
    end
    if self.seasonInfo.seasonStartAt ~= seasonInfo.seasonStartAt then
        self.championTeamInfo = nil

        local clockTime = seasonInfo.seasonStartAt/1000
        updateAlarmClock(clockTime, "RestTimeOver", handler(self, self._restOverCallback))

        clockTime = clockTime + self.TIME_OF_READY_DURATION
        updateAlarmClock(clockTime, "ReadyTimeOver", handler(self, self._readyOverCallback))

        clockTime = clockTime + self.TIME_OF_PLAY_DURATION
        updateAlarmClock(clockTime, "PlayTimeOver", handler(self, self._playOverCallback))

        clockTime = clockTime + self.TIME_OF_END_DURATION
        updateAlarmClock(clockTime, "EndTimeOver", handler(self, self._endOverCallback))

        -- 1/8决赛结束
        clockTime = clockTime + self.TIME_OF_PEAK_FIRST_ROUND_READY_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_FIRST_ROUND_FIRST_PHASE_FIGHT_DURATION
        updateAlarmClock(clockTime, "16In8TimeOver", handler(self, self._peakFirstRoundFirstPhaseOverCallback))

        -- 1/4决赛结束
        clockTime = clockTime + self.TIME_OF_PEAK_FIRST_ROUND_SECOND_PHASE_FIGHT_DURATION
        updateAlarmClock(clockTime, "8In4TimeOver", handler(self, self._peakFirstRoundSecondPhaseOverCallback))

        -- 开始半决赛押注
        clockTime = clockTime + self.TIME_OF_PEAK_SECOND_ROUND_READY_DURATION
        updateAlarmClock(clockTime, "ReadyTo4TimeOver", handler(self, self._peakReadyTo4OverCallback))

        -- 半决赛结束
        clockTime = clockTime + self.TIME_OF_PEAK_SECOND_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_SECOND_ROUND_FIGHT_DURATION
        updateAlarmClock(clockTime, "4In2TimeOver", handler(self, self._peakSecondRoundOverCallback))

        -- 开始决赛押注
        clockTime = clockTime + self.TIME_OF_PEAK_THIRD_ROUND_READY_DURATION
        updateAlarmClock(clockTime, "ReadyToFinalTimeOver", handler(self, self._peakReadyToFinalOverCallback))

        -- 决赛结束
        clockTime = clockTime + self.TIME_OF_PEAK_THIRD_ROUND_WAIT_DURATION + self.TIME_OF_PEAK_THIRD_ROUND_FIGHT_DURATION
        updateAlarmClock(clockTime, "PeakTimeOver", handler(self, self._peakOverCallback))
    end

    self.seasonInfo = seasonInfo
end

-- 休赛阶段结束，准备阶段开始时的回调
function QSilvesArena:_restOverCallback()
    self._state = self.STATE_READY
    
    self:dispatchEvent({name = self.STATE_UPDATE})
end

-- 准备阶段结束，海选赛阶段开始时的回调
function QSilvesArena:_readyOverCallback()
    self._state = self.STATE_PLAY

    self:dispatchEvent({name = self.STATE_UPDATE})
end

-- 海选赛阶段结束
function QSilvesArena:_playOverCallback()
    self._state = self.STATE_PEAK
    self._peakState = self.PEAK_READY_TO_16

    self:dispatchEvent({name = self.STATE_UPDATE})
end

-- 1/8决赛结束
function QSilvesArena:_peakFirstRoundFirstPhaseOverCallback()
    self._state = self.STATE_PEAK
    self._peakState = self.PEAK_8_IN_4

    self:dispatchEvent({name = self.STATE_UPDATE})
end

-- 1/4决赛结束
function QSilvesArena:_peakFirstRoundSecondPhaseOverCallback()
    self._state = self.STATE_PEAK
    self._peakState = self.PEAK_READY_TO_4

    self:dispatchEvent({name = self.STATE_UPDATE})
end

-- 开始半决赛押注
function QSilvesArena:_peakReadyTo4OverCallback()
    self._state = self.STATE_PEAK
    self._peakState = self.PEAK_WAIT_TO_4

    -- 这个时间点需要拉一下数据，用于显示押注小红点
    self:silvesPeakGetMyBetInfoRequest()
    self:dispatchEvent({name = self.STATE_UPDATE})
end

-- 半决赛结束
function QSilvesArena:_peakSecondRoundOverCallback()
    self._state = self.STATE_PEAK
    self._peakState = self.PEAK_READY_TO_FINAL

    self:dispatchEvent({name = self.STATE_UPDATE})
end

-- 开始决赛押注
function QSilvesArena:_peakReadyToFinalOverCallback()
    self._state = self.STATE_PEAK
    self._peakState = self.PEAK_WAIT_TO_FINAL

    -- 这个时间点需要拉一下数据，用于显示押注小红点
    self:silvesPeakGetMyBetInfoRequest()
    self:dispatchEvent({name = self.STATE_UPDATE})
end

-- 决赛结束
function QSilvesArena:_peakOverCallback()
    self._state = self.STATE_REST

    self:dispatchEvent({name = self.STATE_UPDATE})
end

-- 海选赛结算
function QSilvesArena:_endOverCallback()
    self._state = self.STATE_END

    self:dispatchEvent({name = self.STATE_UPDATE})
end

--[[
message SilvesArenaUserInfo {
    repeated int32 getFightCountReward = 1; //领取的战斗奖励
    optional int32 todayFightCount = 2; //今日战斗次数
    optional int32 todayFightAt = 3; //战斗时间
    repeated string myApplyIdList = 4; //我申请的队伍
    optional int32 refreshCount = 6; //今日已刷新次数
}
]]
function QSilvesArena:_updateUserInfo(userInfo)
    if q.isEmpty(userInfo) then return end

    self.userInfo = userInfo
end

--[[
message SilvesArenaTeamInfo {
    optional string teamId = 1; //组队ID
    optional string teamName = 3; //队伍名字
    optional int32 memberCnt = 4; //队伍当前人数
    optional string teamGameAreaName = 5; //队伍所在服务器名字
    optional Fighter leader = 6; //队长
    optional Fighter member1 = 7; //队员1
    optional Fighter member2 = 8; //队员2
    optional int32 status = 9; //队伍状态 0为组队状态 1组队提交完成
    optional int64 teamMinForce = 10; //最低战斗力
    optional int32 teamScore = 11; //队伍积分
    optional int32 symbol = 12; // 队伍标识 取db中的id，最后6位
    optional int32 teamRank = 13; // 队伍排名
    optional int64 averageForce = 14; //平均战斗力
    optional int32 totalFightCount = 15; // 小队战斗次数
    optional int64 totalForce = 17; // 小队总战斗力
}
]]
function QSilvesArena:_updateMyTeamInfo(myTeamInfo)
    if myTeamInfo == nil then return end

    -- 后端说直接替换就行，不要缓存，信息是会变得
    -- if q.isEmpty(self.myTeamInfo) then
        self.myTeamInfo = myTeamInfo
    --     return
    -- end

    -- for key, value in pairs(myTeamInfo) do
    --     self.myTeamInfo[key] = value
    -- end
end

--[[
message SilvesArenaTeamInfoList {
    repeated SilvesArenaTeamInfo teamInfo = 1; //队伍信息
}

message SilvesArenaTeamInfo {
    optional string teamId = 1; //组队ID
    optional string teamName = 3; //队伍名字
    optional int32 memberCnt = 4; //队伍当前人数
    optional string teamGameAreaName = 5; //队伍所在服务器名字
    optional Fighter leader = 6; //队长
    optional Fighter member1 = 7; //队员1
    optional Fighter member2 = 8; //队员2
    optional int32 status = 9; //队伍状态 0为组队状态 1组队提交完成
    optional int64 teamMinForce = 10; //最低战斗力
    optional int32 teamScore = 11; //队伍积分
    optional int32 symbol = 12; // 队伍标识 取db中的id，最后6位
    optional int32 teamRank = 13; // 队伍排名
    optional int64 averageForce = 14; //平均战斗力
    optional int32 totalFightCount = 15; // 小队战斗次数
    optional int64 totalForce = 17; // 小队总战斗力
}
]]
-- 报名期，这是room列表。战斗期，这是敌人列表（3个）
function QSilvesArena:_updateTeamInfo(teamInfo)
    if teamInfo == nil then return end

    self.teamInfo = teamInfo
end

function QSilvesArena:_updatePeakTeamInfo(peakTeamInfo)
    if peakTeamInfo == nil then return end

    self.peakTeamInfo = peakTeamInfo
end

function QSilvesArena:_updateEnemyTeamDetailInfo(enemyTeamDetailInfoList)
    if q.isEmpty(enemyTeamDetailInfoList) then return end
    local enemyTeamDetailInfoList = enemyTeamDetailInfoList
    if q.isEmpty(enemyTeamDetailInfoList) then return end

    for _, teamInfo in ipairs(enemyTeamDetailInfoList) do
        local delIndex = 0
        if not q.isEmpty(self.teamInfo) then
            for index, info in ipairs(self.teamInfo) do
                if info.teamId == teamInfo.teamId then
                    delIndex = index 
                    break
                end
            end
        end

        if delIndex > 0 then
            table.remove(self.teamInfo, delIndex)
            table.insert(self.teamInfo, delIndex, teamInfo)
        else
            table.insert(self.teamInfo, teamInfo)
        end
    end
end

--[[
message SilvesArenaFightInfo {
    message SilvesArenaFightInfo {
    optional string matchingId = 1; //唯一的匹配id
    optional string teamId = 2; //组队ID
    repeated Fighter attackFightInfo = 3; //攻击的fighter信息
    repeated Fighter defenseFightInfo = 4; //防守的fighter信息
    repeated int32 endInfo = 5; //战斗结束信息  1 2 3
    repeated int32 watchInfo = 6; //观看过的信息
    repeated int32 scoreList = 7; //战斗结束信息  1 2 3
    repeated int64 reportIdList = 8; //战报id集合
    optional string team1Name = 9; //队伍1的name
    optional string team2Name = 10; //队伍2的name
    optional int32 team1Score = 11; //队伍1的初始积分
    optional int32 team2Score = 12; //队伍2的初始积分
    optional bool skipWatch = 13; //是否跳过战斗
} 
}
]]
function QSilvesArena:_updateFightInfo(fightInfo)
    if fightInfo == nil then return end

    -- if q.isEmpty(self.fightInfo) then
        self.fightInfo = fightInfo
    -- else
    --     for key, value in pairs(fightInfo) do
    --         self.fightInfo[key] = value
    --     end
    -- end
end

--[[
message SilvesArenaGetOnlineUserInfo {
    repeated Fighter onlineFighter = 1; //在线公会会员
}
]]
function QSilvesArena:_updateOnlineUserInfo(onlineUserInfo)
    if onlineUserInfo == nil then return end

    self.onlineUserInfo = onlineUserInfo
end

--[[
message SilvesArenaApplyInfo {
    repeated Fighter applyFighter = 1; //申请fighter
}
]]
function QSilvesArena:_updateApplyInfo(applyInfo)
    if applyInfo == nil then return end

    self.applyInfo = applyInfo
end

--[[
message SilvesArenaBattleHistory {
    optional string matchingId = 1; //队伍ID
    optional string team1Id = 2; //队伍1id
    optional string team1Name = 3; //队伍1名称
    repeated Fighter team1fighterList = 4; //队伍1fighterlist
    optional int32 team1AddScore = 5; //队伍1增加的积分

    optional string team2Id = 6; //队伍1id
    optional string team2Name = 7; //队伍1名称
    repeated Fighter team2fighterList = 8; //队伍1fighterlist
    optional int32 team2AddScore = 9; //队伍1增加的积分

    optional bool success = 10; // 玩家1是否胜利
    repeated int64 reportIdList = 11; //战报ID
}
]]
function QSilvesArena:_updateBattleHistoryList(battleHistoryList)
    if q.isEmpty(battleHistoryList) then return end

    self.battleHistoryList = battleHistoryList
end

--[[
message SilvesArenaBattleReport {
    optional int64 reportId = 1; //战报ID
    optional Fighter fighter1 = 3; //攻击者
    optional Fighter fighter2 = 6; //被攻击者
    optional bool success = 9; //是否胜利
    optional int64 fightAt = 12; //战斗发生时间
    optional string fightersData = 13; //
    optional string fighterReportData = 14; //
}
]]
function QSilvesArena:_updateBattleReport(battleReport)
    if q.isEmpty(battleReport) then return end

    self.battleReport = battleReport
end
--[[
message SilvesArenaGameAreaListInfo {
    repeated string gameAreaNameList = 1; //游戏区列表
}
]]
function QSilvesArena:_updateGameArenList(gameArenList)
    if q.isEmpty(gameArenList) then return end

    self.gameArenList = gameArenList
end

--[[
message SilvesArenaRankResponse {
    repeated SilvesArenaTeamInfo teamRankInfo = 1; //队伍信息
    optional SilvesArenaTeamInfo myRankInfo = 2; //我的队伍排行
}
]]
function QSilvesArena:_updateRankInfo(rankInfo)
    if rankInfo == nil then return end

    self.rankInfo = rankInfo
end

function QSilvesArena:_updateChatInfo(chatInfo)
    if chatInfo == nil then return end

    self:dispatchEvent({name = QSilvesArena.NEW_MESSAGE_RECEIVED, chatInfoList = chatInfo})
end


--[[
message SilvesArenaTodayTeamBattleInfo {
    optional Fighter fighter = 1; //玩家简单信息
    repeated bool success = 2; //是否胜利
    optional bool leader = 3; //是否队长
    optional int32 fightCount = 4; //今日剩余战斗次数
}
]]
function QSilvesArena:_updateTodayTeamBattleInfo(todayTeamBattleInfo)
    if q.isEmpty(todayTeamBattleInfo) then return end

    self.todayTeamBattleInfo = todayTeamBattleInfo
end

--协议推送部分
function QSilvesArena:_registerPushCallback()
    remote:registerPushMessage("SILVES_ARENA_MEMBER_JOIN", self, self.pushHandler)
    remote:registerPushMessage("SILVES_ARENA_MEMBER_QUIT", self, self.pushHandler)
    remote:registerPushMessage("SILVES_ARENA_MEMBER_KICKED", self, self.pushHandler)
    remote:registerPushMessage("SILVES_ARENA_MEMBER_CHAT", self, self.pushHandler)

end

function QSilvesArena:_unregisterPushCallback()
    remote:removePushMessage("SILVES_ARENA_MEMBER_JOIN", self, self.pushHandler)
    remote:removePushMessage("SILVES_ARENA_MEMBER_QUIT", self, self.pushHandler)
    remote:removePushMessage("SILVES_ARENA_MEMBER_KICKED", self, self.pushHandler)
    remote:removePushMessage("SILVES_ARENA_MEMBER_CHAT", self, self.pushHandler)
end

function QSilvesArena:_exitFromBattleHandler(event)
    -- if event and event.options and event.options.isReplay and event.options.isQuick and event.options.isInSilvesArenaReplayBattleModule then
    --     QNotificationCenter.sharedNotificationCenter():removeEventListener(QNotificationCenter.EVENT_EXIT_FROM_BATTLE, self._exitFromBattleHandler, self)
    --     --[[Kumo]]
    --     -- self:silvesAutoReplayBattle()
    -- end
end

--更新本地防守阵容
function QSilvesArena:_updateDefenseTeam( battleArmy )  
    if q.isEmpty(battleArmy) then return end

    local battleFormation = battleArmy.battleFormation or {}
    local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.SILVES_ARENA_TEAM)
    if not battleFormation.mainHeroIds then
        local team = remote.teamManager:getDefaultTeam(remote.teamManager.SILVES_ARENA_TEAM)
        battleFormation = remote.teamManager:encodeBattleFormation(team)
        self:silvesArenaChangeDefenseArmyRequest(battleFormation)
    end   
    teamVO:setTeamDataWithBattleFormation(battleFormation) 

    self.myDefenseTeamBattleFormation = battleFormation
end

function QSilvesArena:_updateStakeInfo( silvesPeakUserBetInfo )
    if q.isEmpty(silvesPeakUserBetInfo) then return end

    self.myStakeInfoList = silvesPeakUserBetInfo
end

function QSilvesArena:_updateChampionTeamInfo(championTeamInfo)
    if not championTeamInfo then return end

    self.championTeamInfo = championTeamInfo
end

--------------虚拟数据.KUMOFLAG.--------------

-- QSilvesArena._main_info = 
-- {
--     error = "NO_ERROR",
--     api = "SILVES_ARENA_GET_MAIN_INFO",
--     serverTime = 1598875967589,
--     key = 82,
--     silvesArenaInfoResponse = 
--     {
--         seasonInfo = 
--         {
--             seasonStartAt = 1598490000000,
--             seasonNo = 1,
--             seasonEndAt = 1596675599000
--         },
--         haveApply = false,
--         fightInfo = 
--         {
--         },
--         myTeamInfo = 
--         {
--         },
--         peakTeamInfos = 
--         {
--             {
--                 position = 1,
--                 isThirdRound = false,
--                 peakWinCount = 0,
--                 currRound = 1,
--                 isSuccess = false,
--                 shareAt = 631123200000,
--                 symbol = 1,
--                 createAt = 1598585342000,
--                 totalForce = 960690846409,
--                 totalFightCount = 0,
--                 member1 = 
--                 {
--                     level = 90,
--                     userId = "69189649-b771-4378-8f46-22dd4f8b8a72",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 2,
--                     consortiaName = "",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 0,
--                     name = "鬼域盘龙组合",
--                     force = 474317620,
--                 },
--                 averageForce = 0,
--                 status = 1,
--                 teamScore = 1649,
--                 memberCnt = 3,
--                 teamId = "a92fdff7-e78d-482e-bfe3-1951494a8c16",
--                 todayFightCount = 0,
--                 teamName = "Hello0",
--                 teamMinForce = 0,
--                 leader = 
--                 {
--                     level = 120,
--                     userId = "de3595f6-4af3-44b1-8e80-93129b69e18a",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 1,
--                     consortiaName = "",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 5,
--                     name = "测试1",
--                     force = 959735197596,
--                 },
--                 member2 = 
--                 {
--                     level = 100,
--                     userId = "0bb866a3-e9fc-4fd9-966a-4dcb9a885d63",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 3,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 0,
--                     name = "",
--                     force = 481331193,
--                 },
--                 teamRank = 0,
--             },
--             {
--                 position = 2,
--                 isThirdRound = false,
--                 peakWinCount = 0,
--                 currRound = 2,
--                 isSuccess = false,
--                 shareAt = 631123200000,
--                 symbol = 2,
--                 createAt = 1598585342000,
--                 totalForce = 3148315733,
--                 totalFightCount = 0,
--                 member1 = 
--                 {
--                     level = 120,
--                     userId = "3e4aec47-31d4-4418-a801-fffde825f693",
--                     defaultSkinId = 11,
--                     silvesArenaFightPos = 2,
--                     consortiaName = "丝默默",
--                     rank = 0,
--                     avatar = 3500038,
--                     soulTrial = 0,
--                     consortiaId = "1ca40f69-c153-4c92-ad5b-a92814cd9ab5",
--                     pvpForce = 0,
--                     title = 3200000,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 20,
--                     name = "xd03",
--                     force = 314348904,
--                 },
--                 averageForce = 0,
--                 status = 1,
--                 teamScore = 9721,
--                 memberCnt = 3,
--                 teamId = "b66462fd-b527-4dcd-a415-428a0b813c93",
--                 todayFightCount = 0,
--                 teamName = "Hello1",
--                 teamMinForce = 0,
--                 leader = 
--                 {
--                     level = 120,
--                     userId = "ab1294ad-f548-47e9-af9a-f596d7e2feeb",
--                     defaultSkinId = 69,
--                     silvesArenaFightPos = 1,
--                     consortiaName = "lll",
--                     rank = 0,
--                     avatar = 3102037,
--                     soulTrial = 0,
--                     consortiaId = "3dd39ceb-35c7-4fbc-b16d-4def97760d33",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1052,
--                     game_area_name = "斗罗大陆",
--                     vip = 20,
--                     name = "测试2",
--                     force = 2362277702,
--                 },
--                 member2 = 
--                 {
--                     level = 120,
--                     userId = "9b0fe215-4806-4d04-8df2-f7a7ef6bea85",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 3,
--                     consortiaName = "天上天下",
--                     rank = 0,
--                     avatar = 90042,
--                     soulTrial = 0,
--                     consortiaId = "6007fa3f-b06c-40f3-966b-1355cdab585d",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1044,
--                     game_area_name = "斗罗大陆",
--                     vip = 13,
--                     name = "xd203",
--                     force = 471689127,
--                 },
--                 teamRank = 0,
--             },
--             {
--                 position = 3,
--                 isThirdRound = false,
--                 peakWinCount = 0,
--                 currRound = 2,
--                 isSuccess = false,
--                 shareAt = 631123200000,
--                 symbol = 3,
--                 createAt = 1598585342000,
--                 totalForce = 2347254543,
--                 totalFightCount = 0,
--                 member1 = 
--                 {
--                     level = 100,
--                     userId = "ec611e3f-e29f-4931-aa42-a9255b32ba86",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 2,
--                     consortiaName = "遗憾",
--                     rank = 0,
--                     avatar = 390037,
--                     soulTrial = 0,
--                     consortiaId = "4d536f06-d50c-4cfa-b3ba-3de2e6ede610",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1030,
--                     game_area_name = "斗罗大陆",
--                     vip = 20,
--                     name = "冠军冠军好声音",
--                     force = 473766104,
--                 },
--                 averageForce = 0,
--                 status = 1,
--                 teamScore = 9913,
--                 memberCnt = 3,
--                 teamId = "ebf007fc-2f1a-42ad-9062-62ce75a3cf34",
--                 todayFightCount = 0,
--                 teamName = "Hello2",
--                 teamMinForce = 0,
--                 leader = 
--                 {
--                     level = 120,
--                     userId = "85d60057-b3af-4daf-ae3b-5672bd76098d",
--                     defaultSkinId = 70,
--                     silvesArenaFightPos = 1,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 3502038,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1048,
--                     game_area_name = "斗罗大陆",
--                     vip = 16,
--                     name = "测试3",
--                     force = 1359241290,
--                 },
--                 member2 = 
--                 {
--                     level = 120,
--                     userId = "857fa616-e9dd-4195-921b-7acd179f42ba",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 3,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 3,
--                     name = "奥特七兄弟",
--                     force = 514247149,
--                 },
--                 teamRank = 0,
--             },
--             {
--                 position = 4,
--                 isThirdRound = false,
--                 peakWinCount = 0,
--                 currRound = 1,
--                 isSuccess = false,
--                 shareAt = 631123200000,
--                 symbol = 1,
--                 createAt = 1598585342000,
--                 totalForce = 960690846409,
--                 totalFightCount = 0,
--                 member1 = 
--                 {
--                     level = 90,
--                     userId = "69189649-b771-4378-8f46-22dd4f8b8a72",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 2,
--                     consortiaName = "",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 0,
--                     name = "鬼域盘龙组合",
--                     force = 474317620,
--                 },
--                 averageForce = 0,
--                 position = 11,
--                 status = 1,
--                 teamScore = 1649,
--                 memberCnt = 3,
--                 teamId = "a92fdff7-e78d-482e-bfe3-1951494a8c16",
--                 todayFightCount = 0,
--                 teamName = "Hello0",
--                 teamMinForce = 0,
--                 leader = 
--                 {
--                     level = 120,
--                     userId = "de3595f6-4af3-44b1-8e80-93129b69e18a",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 1,
--                     consortiaName = "",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 5,
--                     name = "测试4",
--                     force = 959735197596,
--                 },
--                 member2 = 
--                 {
--                     level = 100,
--                     userId = "0bb866a3-e9fc-4fd9-966a-4dcb9a885d63",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 3,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 0,
--                     name = "",
--                     force = 481331193,
--                 },
--                 teamRank = 0,
--             },
--             {
--                 position = 5,
--                 isThirdRound = false,
--                 peakWinCount = 0,
--                 currRound = 1,
--                 isSuccess = false,
--                 shareAt = 631123200000,
--                 symbol = 2,
--                 createAt = 1598585342000,
--                 totalForce = 3148315733,
--                 totalFightCount = 0,
--                 member1 = 
--                 {
--                     level = 120,
--                     userId = "3e4aec47-31d4-4418-a801-fffde825f693",
--                     defaultSkinId = 11,
--                     silvesArenaFightPos = 2,
--                     consortiaName = "丝默默",
--                     rank = 0,
--                     avatar = 3500038,
--                     soulTrial = 0,
--                     consortiaId = "1ca40f69-c153-4c92-ad5b-a92814cd9ab5",
--                     pvpForce = 0,
--                     title = 3200000,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 20,
--                     name = "xd03",
--                     force = 314348904,
--                 },
--                 averageForce = 0,
--                 status = 1,
--                 teamScore = 9721,
--                 memberCnt = 3,
--                 teamId = "b66462fd-b527-4dcd-a415-428a0b813c93",
--                 todayFightCount = 0,
--                 teamName = "Hello1",
--                 teamMinForce = 0,
--                 leader = 
--                 {
--                     level = 120,
--                     userId = "ab1294ad-f548-47e9-af9a-f596d7e2feeb",
--                     defaultSkinId = 69,
--                     silvesArenaFightPos = 1,
--                     consortiaName = "lll",
--                     rank = 0,
--                     avatar = 3102037,
--                     soulTrial = 0,
--                     consortiaId = "3dd39ceb-35c7-4fbc-b16d-4def97760d33",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1052,
--                     game_area_name = "斗罗大陆",
--                     vip = 20,
--                     name = "测试5",
--                     force = 2362277702,
--                 },
--                 member2 = 
--                 {
--                     level = 120,
--                     userId = "9b0fe215-4806-4d04-8df2-f7a7ef6bea85",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 3,
--                     consortiaName = "天上天下",
--                     rank = 0,
--                     avatar = 90042,
--                     soulTrial = 0,
--                     consortiaId = "6007fa3f-b06c-40f3-966b-1355cdab585d",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1044,
--                     game_area_name = "斗罗大陆",
--                     vip = 13,
--                     name = "xd203",
--                     force = 471689127,
--                 },
--                 teamRank = 0,
--             },
--             {
--                 position = 6,
--                 isThirdRound = false,
--                 peakWinCount = 0,
--                 currRound = 2,
--                 isSuccess = false,
--                 shareAt = 631123200000,
--                 symbol = 3,
--                 createAt = 1598585342000,
--                 totalForce = 2347254543,
--                 totalFightCount = 0,
--                 member1 = 
--                 {
--                     level = 100,
--                     userId = "ec611e3f-e29f-4931-aa42-a9255b32ba86",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 2,
--                     consortiaName = "遗憾",
--                     rank = 0,
--                     avatar = 390037,
--                     soulTrial = 0,
--                     consortiaId = "4d536f06-d50c-4cfa-b3ba-3de2e6ede610",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1030,
--                     game_area_name = "斗罗大陆",
--                     vip = 20,
--                     name = "冠军冠军好声音",
--                     force = 473766104,
--                 },
--                 averageForce = 0,
--                 status = 1,
--                 teamScore = 9913,
--                 memberCnt = 3,
--                 teamId = "ebf007fc-2f1a-42ad-9062-62ce75a3cf34",
--                 todayFightCount = 0,
--                 peakWinCount = 0,
--                 teamName = "Hello2",
--                 teamMinForce = 0,
--                 leader = 
--                 {
--                     level = 120,
--                     userId = "85d60057-b3af-4daf-ae3b-5672bd76098d",
--                     defaultSkinId = 70,
--                     silvesArenaFightPos = 1,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 3502038,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1048,
--                     game_area_name = "斗罗大陆",
--                     vip = 16,
--                     name = "测试6",
--                     force = 1359241290,
--                 },
--                 member2 = 
--                 {
--                     level = 120,
--                     userId = "857fa616-e9dd-4195-921b-7acd179f42ba",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 3,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 3,
--                     name = "奥特七兄弟",
--                     force = 514247149,
--                 },
--                 teamRank = 0,
--             },
--             {
--                 position = 7,
--                 isThirdRound = false,
--                 peakWinCount = 0,
--                 currRound = 1,
--                 isSuccess = false,
--                 shareAt = 631123200000,
--                 symbol = 1,
--                 createAt = 1598585342000,
--                 totalForce = 960690846409,
--                 totalFightCount = 0,
--                 member1 = 
--                 {
--                     level = 90,
--                     userId = "69189649-b771-4378-8f46-22dd4f8b8a72",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 2,
--                     consortiaName = "",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 0,
--                     name = "鬼域盘龙组合",
--                     force = 474317620,
--                 },
--                 averageForce = 0,
--                 status = 1,
--                 teamScore = 1649,
--                 memberCnt = 3,
--                 teamId = "a92fdff7-e78d-482e-bfe3-1951494a8c16",
--                 todayFightCount = 0,
--                 teamName = "Hello0",
--                 teamMinForce = 0,
--                 leader = 
--                 {
--                     level = 120,
--                     userId = "de3595f6-4af3-44b1-8e80-93129b69e18a",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 1,
--                     consortiaName = "",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 5,
--                     name = "测试7",
--                     force = 959735197596,
--                 },
--                 member2 = 
--                 {
--                     level = 100,
--                     userId = "0bb866a3-e9fc-4fd9-966a-4dcb9a885d63",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 3,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 0,
--                     name = "",
--                     force = 481331193,
--                 },
--                 teamRank = 0,
--             },
--             {
--                 position = 8,
--                 isThirdRound = false,
--                 peakWinCount = 0,
--                 currRound = 2,
--                 isSuccess = false,
--                 shareAt = 631123200000,
--                 symbol = 2,
--                 createAt = 1598585342000,
--                 totalForce = 3148315733,
--                 totalFightCount = 0,
--                 member1 = 
--                 {
--                     level = 120,
--                     userId = "3e4aec47-31d4-4418-a801-fffde825f693",
--                     defaultSkinId = 11,
--                     silvesArenaFightPos = 2,
--                     consortiaName = "丝默默",
--                     rank = 0,
--                     avatar = 3500038,
--                     soulTrial = 0,
--                     consortiaId = "1ca40f69-c153-4c92-ad5b-a92814cd9ab5",
--                     pvpForce = 0,
--                     title = 3200000,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 20,
--                     name = "xd03",
--                     force = 314348904,
--                 },
--                 averageForce = 0,
--                 status = 1,
--                 teamScore = 9721,
--                 memberCnt = 3,
--                 teamId = "b66462fd-b527-4dcd-a415-428a0b813c93",
--                 todayFightCount = 0,
--                 teamName = "Hello1",
--                 teamMinForce = 0,
--                 leader = 
--                 {
--                     level = 120,
--                     userId = "ab1294ad-f548-47e9-af9a-f596d7e2feeb",
--                     defaultSkinId = 69,
--                     silvesArenaFightPos = 1,
--                     consortiaName = "lll",
--                     rank = 0,
--                     avatar = 3102037,
--                     soulTrial = 0,
--                     consortiaId = "3dd39ceb-35c7-4fbc-b16d-4def97760d33",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1052,
--                     game_area_name = "斗罗大陆",
--                     vip = 20,
--                     name = "测试8",
--                     force = 2362277702,
--                 },
--                 member2 = 
--                 {
--                     level = 120,
--                     userId = "9b0fe215-4806-4d04-8df2-f7a7ef6bea85",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 3,
--                     consortiaName = "天上天下",
--                     rank = 0,
--                     avatar = 90042,
--                     soulTrial = 0,
--                     consortiaId = "6007fa3f-b06c-40f3-966b-1355cdab585d",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1044,
--                     game_area_name = "斗罗大陆",
--                     vip = 13,
--                     name = "xd203",
--                     force = 471689127,
--                 },
--                 teamRank = 0,
--             },
--             {
--                 position = 9,
--                 isThirdRound = true,
--                 peakWinCount = 0,
--                 currRound = 3,
--                 isSuccess = false,
--                 shareAt = 631123200000,
--                 symbol = 3,
--                 createAt = 1598585342000,
--                 totalForce = 2347254543,
--                 totalFightCount = 0,
--                 member1 = 
--                 {
--                     level = 100,
--                     userId = "ec611e3f-e29f-4931-aa42-a9255b32ba86",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 2,
--                     consortiaName = "遗憾",
--                     rank = 0,
--                     avatar = 390037,
--                     soulTrial = 0,
--                     consortiaId = "4d536f06-d50c-4cfa-b3ba-3de2e6ede610",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1030,
--                     game_area_name = "斗罗大陆",
--                     vip = 20,
--                     name = "冠军冠军好声音",
--                     force = 473766104,
--                 },
--                 averageForce = 0,
--                 status = 1,
--                 teamScore = 9913,
--                 memberCnt = 3,
--                 teamId = "ebf007fc-2f1a-42ad-9062-62ce75a3cf34",
--                 todayFightCount = 0,
--                 peakWinCount = 0,
--                 teamName = "Hello2",
--                 teamMinForce = 0,
--                 leader = 
--                 {
--                     level = 120,
--                     userId = "85d60057-b3af-4daf-ae3b-5672bd76098d",
--                     defaultSkinId = 70,
--                     silvesArenaFightPos = 1,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 3502038,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1048,
--                     game_area_name = "斗罗大陆",
--                     vip = 16,
--                     name = "测试9",
--                     force = 1359241290,
--                 },
--                 member2 = 
--                 {
--                     level = 120,
--                     userId = "857fa616-e9dd-4195-921b-7acd179f42ba",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 3,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 3,
--                     name = "奥特七兄弟",
--                     force = 514247149,
--                 },
--                 teamRank = 0,
--             },
--             {
--                 position = 10,
--                 isThirdRound = false,
--                 peakWinCount = 0,
--                 currRound = 1,
--                 isSuccess = false,
--                 shareAt = 631123200000,
--                 symbol = 1,
--                 createAt = 1598585342000,
--                 totalForce = 960690846409,
--                 totalFightCount = 0,
--                 member1 = 
--                 {
--                     level = 90,
--                     userId = "69189649-b771-4378-8f46-22dd4f8b8a72",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 2,
--                     consortiaName = "",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 0,
--                     name = "鬼域盘龙组合",
--                     force = 474317620,
--                 },
--                 averageForce = 0,
--                 status = 1,
--                 teamScore = 1649,
--                 memberCnt = 3,
--                 teamId = "a92fdff7-e78d-482e-bfe3-1951494a8c16",
--                 todayFightCount = 0,
--                 peakWinCount = 0,
--                 teamName = "Hello0",
--                 teamMinForce = 0,
--                 leader = 
--                 {
--                     level = 120,
--                     userId = "de3595f6-4af3-44b1-8e80-93129b69e18a",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 1,
--                     consortiaName = "",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 5,
--                     name = "测试10",
--                     force = 959735197596,
--                 },
--                 member2 = 
--                 {
--                     level = 100,
--                     userId = "0bb866a3-e9fc-4fd9-966a-4dcb9a885d63",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 3,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 0,
--                     name = "",
--                     force = 481331193,
--                 },
--                 teamRank = 0,
--             },
--             {
--                 position = 11,
--                 isThirdRound = false,
--                 peakWinCount = 0,
--                 currRound = 4,
--                 isSuccess = false,
--                 shareAt = 631123200000,
--                 symbol = 2,
--                 createAt = 1598585342000,
--                 totalForce = 3148315733,
--                 totalFightCount = 0,
--                 member1 = 
--                 {
--                     level = 120,
--                     userId = "3e4aec47-31d4-4418-a801-fffde825f693",
--                     defaultSkinId = 11,
--                     silvesArenaFightPos = 2,
--                     consortiaName = "丝默默",
--                     rank = 0,
--                     avatar = 3500038,
--                     soulTrial = 0,
--                     consortiaId = "1ca40f69-c153-4c92-ad5b-a92814cd9ab5",
--                     pvpForce = 0,
--                     title = 3200000,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 20,
--                     name = "xd03",
--                     force = 314348904,
--                 },
--                 averageForce = 0,
--                 status = 1,
--                 teamScore = 9721,
--                 memberCnt = 3,
--                 teamId = "b66462fd-b527-4dcd-a415-428a0b813c93",
--                 todayFightCount = 0,
--                 peakWinCount = 0,
--                 teamName = "Hello1",
--                 teamMinForce = 0,
--                 leader = 
--                 {
--                     level = 120,
--                     userId = "ab1294ad-f548-47e9-af9a-f596d7e2feeb",
--                     defaultSkinId = 69,
--                     silvesArenaFightPos = 1,
--                     consortiaName = "lll",
--                     rank = 0,
--                     avatar = 3102037,
--                     soulTrial = 0,
--                     consortiaId = "3dd39ceb-35c7-4fbc-b16d-4def97760d33",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1052,
--                     game_area_name = "斗罗大陆",
--                     vip = 20,
--                     name = "测试11",
--                     force = 2362277702,
--                 },
--                 member2 = 
--                 {
--                     level = 120,
--                     userId = "9b0fe215-4806-4d04-8df2-f7a7ef6bea85",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 3,
--                     consortiaName = "天上天下",
--                     rank = 0,
--                     avatar = 90042,
--                     soulTrial = 0,
--                     consortiaId = "6007fa3f-b06c-40f3-966b-1355cdab585d",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1044,
--                     game_area_name = "斗罗大陆",
--                     vip = 13,
--                     name = "xd203",
--                     force = 471689127,
--                 },
--                 teamRank = 0,
--             },
--             {
--                 position = 12,
--                 isThirdRound = false,
--                 peakWinCount = 0,
--                 currRound = 1,
--                 isSuccess = false,
--                 shareAt = 631123200000,
--                 symbol = 3,
--                 createAt = 1598585342000,
--                 totalForce = 2347254543,
--                 totalFightCount = 0,
--                 member1 = 
--                 {
--                     level = 100,
--                     userId = "ec611e3f-e29f-4931-aa42-a9255b32ba86",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 2,
--                     consortiaName = "遗憾",
--                     rank = 0,
--                     avatar = 390037,
--                     soulTrial = 0,
--                     consortiaId = "4d536f06-d50c-4cfa-b3ba-3de2e6ede610",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1030,
--                     game_area_name = "斗罗大陆",
--                     vip = 20,
--                     name = "冠军冠军好声音",
--                     force = 473766104,
--                 },
--                 averageForce = 0,
--                 status = 1,
--                 teamScore = 9913,
--                 memberCnt = 3,
--                 teamId = "ebf007fc-2f1a-42ad-9062-62ce75a3cf34",
--                 todayFightCount = 0,
--                 teamName = "Hello2",
--                 teamMinForce = 0,
--                 leader = 
--                 {
--                     level = 120,
--                     userId = "85d60057-b3af-4daf-ae3b-5672bd76098d",
--                     defaultSkinId = 70,
--                     silvesArenaFightPos = 1,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 3502038,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1048,
--                     game_area_name = "斗罗大陆",
--                     vip = 16,
--                     name = "测试12",
--                     force = 1359241290,
--                 },
--                 member2 = 
--                 {
--                     level = 120,
--                     userId = "857fa616-e9dd-4195-921b-7acd179f42ba",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 3,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 3,
--                     name = "奥特七兄弟",
--                     force = 514247149,
--                 },
--                 teamRank = 0,
--             },
--             {
--                 position = 13,
--                 isThirdRound = true,
--                 peakWinCount = 0,
--                 currRound = 3,
--                 isSuccess = false,
--                 shareAt = 631123200000,
--                 symbol = 1,
--                 createAt = 1598585342000,
--                 totalForce = 960690846409,
--                 totalFightCount = 0,
--                 member1 = 
--                 {
--                     level = 90,
--                     userId = "69189649-b771-4378-8f46-22dd4f8b8a72",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 2,
--                     consortiaName = "",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 0,
--                     name = "鬼域盘龙组合",
--                     force = 474317620,
--                 },
--                 averageForce = 0,
--                 status = 1,
--                 teamScore = 1649,
--                 memberCnt = 3,
--                 teamId = "a92fdff7-e78d-482e-bfe3-1951494a8c16",
--                 todayFightCount = 0,
--                 teamName = "Hello0",
--                 teamMinForce = 0,
--                 leader = 
--                 {
--                     level = 120,
--                     userId = "de3595f6-4af3-44b1-8e80-93129b69e18a",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 1,
--                     consortiaName = "",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 5,
--                     name = "测试13",
--                     force = 959735197596,
--                 },
--                 member2 = 
--                 {
--                     level = 100,
--                     userId = "0bb866a3-e9fc-4fd9-966a-4dcb9a885d63",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 3,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 0,
--                     name = "",
--                     force = 481331193,
--                 },
--                 teamRank = 0,
--             },
--             {
--                 position = 14,
--                 isThirdRound = false,
--                 peakWinCount = 0,
--                 currRound = 1,
--                 isSuccess = false,
--                 shareAt = 631123200000,
--                 symbol = 2,
--                 createAt = 1598585342000,
--                 totalForce = 3148315733,
--                 totalFightCount = 0,
--                 member1 = 
--                 {
--                     level = 120,
--                     userId = "3e4aec47-31d4-4418-a801-fffde825f693",
--                     defaultSkinId = 11,
--                     silvesArenaFightPos = 2,
--                     consortiaName = "丝默默",
--                     rank = 0,
--                     avatar = 3500038,
--                     soulTrial = 0,
--                     consortiaId = "1ca40f69-c153-4c92-ad5b-a92814cd9ab5",
--                     pvpForce = 0,
--                     title = 3200000,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 20,
--                     name = "xd03",
--                     force = 314348904,
--                 },
--                 averageForce = 0,
--                 status = 1,
--                 teamScore = 9721,
--                 memberCnt = 3,
--                 teamId = "b66462fd-b527-4dcd-a415-428a0b813c93",
--                 todayFightCount = 0,
--                 teamName = "Hello1",
--                 teamMinForce = 0,
--                 leader = 
--                 {
--                     level = 120,
--                     userId = "ab1294ad-f548-47e9-af9a-f596d7e2feeb",
--                     defaultSkinId = 69,
--                     silvesArenaFightPos = 1,
--                     consortiaName = "lll",
--                     rank = 0,
--                     avatar = 3102037,
--                     soulTrial = 0,
--                     consortiaId = "3dd39ceb-35c7-4fbc-b16d-4def97760d33",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1052,
--                     game_area_name = "斗罗大陆",
--                     vip = 20,
--                     name = "测试14",
--                     force = 2362277702,
--                 },
--                 member2 = 
--                 {
--                     level = 120,
--                     userId = "9b0fe215-4806-4d04-8df2-f7a7ef6bea85",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 3,
--                     consortiaName = "天上天下",
--                     rank = 0,
--                     avatar = 90042,
--                     soulTrial = 0,
--                     consortiaId = "6007fa3f-b06c-40f3-966b-1355cdab585d",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1044,
--                     game_area_name = "斗罗大陆",
--                     vip = 13,
--                     name = "xd203",
--                     force = 471689127,
--                 },
--                 teamRank = 0,
--             },
--             {
--                 position = 15,
--                 isThirdRound = false,
--                 peakWinCount = 0,
--                 currRound = 4,
--                 isSuccess = false,
--                 shareAt = 631123200000,
--                 symbol = 3,
--                 createAt = 1598585342000,
--                 totalForce = 2347254543,
--                 totalFightCount = 0,
--                 member1 = 
--                 {
--                     level = 100,
--                     userId = "ec611e3f-e29f-4931-aa42-a9255b32ba86",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 2,
--                     consortiaName = "遗憾",
--                     rank = 0,
--                     avatar = 390037,
--                     soulTrial = 0,
--                     consortiaId = "4d536f06-d50c-4cfa-b3ba-3de2e6ede610",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1030,
--                     game_area_name = "斗罗大陆",
--                     vip = 20,
--                     name = "冠军冠军好声音",
--                     force = 473766104,
--                 },
--                 averageForce = 0,
--                 status = 1,
--                 teamScore = 9913,
--                 memberCnt = 3,
--                 teamId = "ebf007fc-2f1a-42ad-9062-62ce75a3cf34",
--                 todayFightCount = 0,
--                 teamName = "Hello2",
--                 teamMinForce = 0,
--                 leader = 
--                 {
--                     level = 120,
--                     userId = "85d60057-b3af-4daf-ae3b-5672bd76098d",
--                     defaultSkinId = 70,
--                     silvesArenaFightPos = 1,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 3502038,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1048,
--                     game_area_name = "斗罗大陆",
--                     vip = 16,
--                     name = "测试15",
--                     force = 1359241290,
--                 },
--                 member2 = 
--                 {
--                     level = 120,
--                     userId = "857fa616-e9dd-4195-921b-7acd179f42ba",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 3,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 3,
--                     name = "奥特七兄弟",
--                     force = 514247149,
--                 },
--                 teamRank = 0,
--             },
--             {
--                 position = 16,
--                 isThirdRound = false,
--                 peakWinCount = 0,
--                 currRound = 1,
--                 isSuccess = false,
--                 shareAt = 631123200000,
--                 symbol = 3,
--                 createAt = 1598585342000,
--                 totalForce = 2347254543,
--                 totalFightCount = 0,
--                 member1 = 
--                 {
--                     level = 100,
--                     userId = "ec611e3f-e29f-4931-aa42-a9255b32ba86",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 2,
--                     consortiaName = "遗憾",
--                     rank = 0,
--                     avatar = 390037,
--                     soulTrial = 0,
--                     consortiaId = "4d536f06-d50c-4cfa-b3ba-3de2e6ede610",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1030,
--                     game_area_name = "斗罗大陆",
--                     vip = 20,
--                     name = "冠军冠军好声音",
--                     force = 473766104,
--                 },
--                 averageForce = 0,
--                 status = 1,
--                 teamScore = 9913,
--                 memberCnt = 3,
--                 teamId = "ebf007fc-2f1a-42ad-9062-62ce75a3cf34",
--                 todayFightCount = 0,
--                 teamName = "Hello2",
--                 teamMinForce = 0,
--                 leader = 
--                 {
--                     level = 120,
--                     userId = "85d60057-b3af-4daf-ae3b-5672bd76098d",
--                     defaultSkinId = 70,
--                     silvesArenaFightPos = 1,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 3502038,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1048,
--                     game_area_name = "斗罗大陆",
--                     vip = 16,
--                     name = "测试16",
--                     force = 1359241290,
--                 },
--                 member2 = 
--                 {
--                     level = 120,
--                     userId = "857fa616-e9dd-4195-921b-7acd179f42ba",
--                     defaultSkinId = 0,
--                     silvesArenaFightPos = 3,
--                     consortiaName = "我见青山多妩媚",
--                     rank = 0,
--                     avatar = 10037,
--                     soulTrial = 0,
--                     consortiaId = "55bde819-4dd8-4f22-ad0d-4eb2d74fe6cc",
--                     pvpForce = 0,
--                     title = 0,
--                     defaultActorId = 1001,
--                     game_area_name = "斗罗大陆",
--                     vip = 3,
--                     name = "奥特七兄弟",
--                     force = 514247149,
--                 },
--                 teamRank = 0,
--             },
--         },
--         battleArmy = 
--         {
--             pvpForce = 13616653,
--             battleFormation = 
--             {
--                 activeSub1HeroId = 1036,
--                 sub1HeroIds = 
--                 {
--                     1013,
--                     1031,
--                     1036,
--                     1043,
--                 },
--                 mainHeroIds = 
--                 {
--                     1016,
--                     1028,
--                     1032,
--                     1039,
--                 },
--                 activeSub3HeroId = 0,
--                 sub2HeroIds = 
--                 {
--                     1023,
--                 },
--                 activeSub2HeroId = 0,
--                 godArmIdList = 
--                 {
--                     30007,
--                 }
--             },
--             armyForce = 13599358,
--         },
--         totalSilvesArenaMoney = 0,
--         userInfo = 
--         {
--             zoneNo = 1,
--             todayFightAt = 631123200000,
--             todayFightCount = 0,
--             refreshCount = 0,
--             defenseReplayUrl = "",
--         }
--     }
-- }

return QSilvesArena
