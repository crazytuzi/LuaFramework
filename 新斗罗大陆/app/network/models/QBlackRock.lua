-- 黑石副本数据类
-- Author: wkwang
-- Date: 2016-9-27
--
local QBaseModel = import("...models.QBaseModel")
local QBlackRock = class("QBlackRock", QBaseModel)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("...ui.QUIViewController")

QBlackRock.EVENT_UPDATE_TEAM_INFO = "EVENT_UPDATE_TEAM_INFO"
QBlackRock.EVENT_FIGHT_END_AWARDS = "EVENT_FIGHT_END_AWARDS"
QBlackRock.EVENT_SEND_INVITE = "EVENT_SEND_INVITE"
QBlackRock.EVENT_PASS_INFO = "EVENT_PASS_INFO"
QBlackRock.EVENT_UPDATE_MYINFO = "EVENT_UPDATE_MYINFO"
QBlackRock.EVENT_FIGHT_QUICK = "EVENT_FIGHT_QUICK"
QBlackRock.EVENT_UPDATE_STATE = "EVENT_UPDATE_STATE"

QBlackRock.NO_ACTIVE = "QBLACKROCK.NO_ACTIVE"
QBlackRock.NO_AWARD = "QBLACKROCK.NO_AWARD"
QBlackRock.NORMAL = "QBLACKROCK.NORMAL"

function QBlackRock:ctor(options)
    QBlackRock.super.ctor(self)
    self._inviteEnable = true
    self._isEnd = false
    self._blackNpcList = {}
    self._randomBlackSoulSpritList = {} --随机的守护魂灵
    self.rejectInviteUserIdDict = {}     --拒绝邀请的玩家
    self._teamEndGetWardsDouble = false
    self._members = {}
    self._progress = {}
    self._herosHpMp = {}
    self._buff = nil

    self._joinTeamTime = 0

    self.noActiveTimeForMsec = 10*MIN*1000
end

function QBlackRock:didappear()
    self:initStaticConfig()
    self:registerPushCallBack()
end

function QBlackRock:disappear()
    self:unregisterPushCallBack()
end

function QBlackRock:getTotalFightTime()
    -- return 8 * 60 
    local totalTime = QStaticDatabase:sharedDatabase():getConfigurationValue("BLACK_ROCK_OVER_TIME")
    if totalTime then
        return tonumber(totalTime)
    else
        return 8 * 60 
    end
end

function QBlackRock:loginEnd()
    if self:blackRockIsOpen() then
        self:blackRockGetMainMyInfoRequest()
        self:updateBlackNpcList()
    end
end

function QBlackRock:blackRockIsOpen(isTip)
    if app.unlock:checkLock("UNLOCK_BLACKROCK", isTip) then
        return true
    end

    return false
end

function QBlackRock:getTotalAwardsCount()
    local config = QStaticDatabase:sharedDatabase():getConfiguration()
    return config.blackrock_award_free.value
end

function QBlackRock:updateBlackNpcList()
    local blackSoulSpritList = QStaticDatabase.sharedDatabase():getBlackChapterSoulSpirt()
    for _, config in pairs(blackSoulSpritList) do
        table.insert(self._blackNpcList, config.soul_spirit_id)
    end
end

function QBlackRock:getIsRandomBlackSourSpritById(id)

    local soulspritInfo = self:getBlackRockSoulSpiritById(self._dayOfYear)
    if soulspritInfo == nil then return false end
    local showSoulSpritList = string.split(soulspritInfo.random_soul_spirit,";")

    if next(showSoulSpritList) ~= nil then
        local id = tonumber(id)
        for _, soulId in ipairs(showSoulSpritList) do
            if tonumber(soulId) == id then
                return true
            end
        end
    end    
    return false
end
function QBlackRock:getBlackNpcList()
    if next(self._blackNpcList) == nil then
        self:updateBlackNpcList()
    end
    return self._blackNpcList
end

function QBlackRock:setJoinTeamTime( joinTime )
    self._joinTeamTime = joinTime
end

function QBlackRock:getJoinTeamTime()
    return self._joinTeamTime
end
--设置玩家黑石信息
--[[
    optional int32  todayScore = 1;                                             //当日积分
    optional int32  awardCount = 2;                                             //剩余领奖次数
    optional int32  buyAwardCount = 3;                                          //已购买的领奖次数
]]
function QBlackRock:setMyInfo(myInfo)
    if myInfo ~= nil then
        self._myInfo = myInfo
        self:dispatchEvent({name = QBlackRock.EVENT_UPDATE_MYINFO})
    end
end

function QBlackRock:getMyInfo()
    return self._myInfo
end

function QBlackRock:setRandomSoulSprit(day)
    self._dayOfYear = day
end

function QBlackRock:getDayOfYear( )
    return self._dayOfYear
end
function QBlackRock:getBlackRockSoulSpiritById(id)

    return QStaticDatabase.sharedDatabase():getBlackSoulSpirt(id)
end

function QBlackRock:getMaxCombatTeamId()
    if not self.teamInfo then return 0 end
    local chapterId = self.teamInfo.chapterId
    if not chapterId then return 0 end
    if next(self._myInfo) == nil then return 0 end
    local todayPassInfo = {}
    local todayTopPerfectPassBoss = self._myInfo.todayTopPerfectPassBoss
    if todayTopPerfectPassBoss then
        local passBossInfo = string.split(todayTopPerfectPassBoss,";")
        if next(passBossInfo) ~= nil then
            for _,passInfo in pairs(passBossInfo) do
               local chapterInfo = string.split(passInfo, "^")
               if tonumber(chapterInfo[1]) and tonumber(chapterInfo[1]) == tonumber(chapterId) then
                    return chapterInfo[2]
               end
            end
        end
    end

    return 0
end
--设置是否可以邀请
function QBlackRock:setInviteEnable(b)
    self._inviteEnable = b
end

--[[
    optional string teamId = 1;//组队ID
    optional int32  chapterId = 2;//黑石山章节ID
    optional Fighter leader = 3;//队长
    repeated Fighter members = 4;//队员们
    optional bool   isFight = 5;//是否战斗了
    optional int64  fightStartAt = 6;//战斗开始时间
]]
function QBlackRock:setTeamInfo(teamInfo)
    if teamInfo == nil then
        self.teamInfo = nil
        return
    end
    if self._isEnd == false and self.teamInfo ~= nil and self.teamInfo.teamProgress.createdAt > teamInfo.teamProgress.createdAt then
        return
    end
    if self._isEnd == true then
        self:clearEndAwards()
        self._isEnd = false
    end
    self.teamInfo = teamInfo
    self._members = {}
    self._progress = {}
    self._herosHpMp = {}
    self._buff = nil
    if self.teamInfo ~= nil then
        if self.teamInfo.leader ~= nil then
            self._members[self.teamInfo.leader.userId] = self.teamInfo.leader
        end
        if self.teamInfo.member1 ~= nil then
            self._members[self.teamInfo.member1.userId] = self.teamInfo.member1
        end
        if self.teamInfo.member2 ~= nil then
            self._members[self.teamInfo.member2.userId] = self.teamInfo.member2
        end

        for _,v in ipairs(self.teamInfo.teamProgress.allProgress ) do
            self._progress[v.memberPos] = v
            for _,stepInfo in ipairs(v.stepInfo) do
                if stepInfo.isNpc == false and stepInfo.isComplete == true then
                    self._buff = stepInfo.stepId
                    break
                end
            end
            if v.memberId == remote.user.userId then
                for _,heroInfo in ipairs(v.topnHerosHp or {}) do
                    self._herosHpMp[heroInfo.actorId] = heroInfo
                end
            end
        end
    end
end

function QBlackRock:checkBuffIsEat(buffId)
    local progress = self:getProgress(remote.user.userId)
    local buffIds = progress.ateBuffs or {}
    for _,id in ipairs(buffIds) do
        if id == buffId then
            return true
        end
    end
    return false
end

function QBlackRock:setDouBleFlag(isDouble)
    self._teamEndGetWardsDouble = isDouble
end

--获取progressId
function QBlackRock:getProgressId()
    return self.teamInfo.teamProgress.progressId
end

--根据userid获取组队成员信息
function QBlackRock:getMemberById(userId)
    return self._members[userId]
end

--根据位置获取进度信息
function QBlackRock:getProgressByPos(posIndex)
    return self._progress[posIndex]
end

function QBlackRock:getTeamInfo()
    return self.teamInfo
end

function QBlackRock:getIsLeader()
    if self.teamInfo == nil then
        return false
    end
    if self.teamInfo.leader == nil then
        return false
    end
    return self.teamInfo.leader.userId == remote.user.userId
end

--自己是否放弃了
function QBlackRock:getIsGiveUp(userId)
    local teamInfo = self:getTeamInfo()
    if teamInfo == nil then return false end
    for _, progress in ipairs(teamInfo.teamProgress.allProgress) do
        if progress.memberId == userId then
            return progress.isGiveUp
        end
    end
    return false
end

--获取自己的进度
function QBlackRock:getProgress(userId)
    local teamInfo = self:getTeamInfo()
    if teamInfo == nil then return nil end
    for _, progress in ipairs(teamInfo.teamProgress.allProgress) do
        if progress.memberId == userId then
            return progress
        end
    end
    return nil
end

--自己这条是否结束
function QBlackRock:getIsEnd(userId)
    local progress = self:getProgress(userId)
    if progress == nil then return false end
    return progress.isEnd
end

--战斗是否结束
function QBlackRock:getTeamIsEnd()
    local teamInfo = self:getTeamInfo()
    if teamInfo == nil then return true end
    return teamInfo.teamProgress.isEnd
end

--获取吃过的BUFF
function QBlackRock:getBuff()
    return self._buff
end

function QBlackRock:getAwardCount()
    if self._myInfo ~= nil then
        return self:getTotalAwardsCount() - self._myInfo.awardCount + self._myInfo.buyAwardCount
    else
        return self:getTotalAwardsCount()
    end
end

--获取总积分
function QBlackRock:getTotalScore()
    if self._myInfo ~= nil then
        return (self._myInfo.totalScore or 0)
    end
    return 0
end

--根据当前状态打开指定的dialog
function QBlackRock:openDialog()
    if self:blackRockIsOpen(true) == false then
        return false
    end

    remote.blackrock:blackRockGetMyInfoRequest(function ()
        local teamInfo = remote.blackrock:getTeamInfo()
        -- local progress = remote.blackrock:getProgress(remote.user.userId)
        if teamInfo ~= nil then
        -- if remote.blackrock:getTeamIsEnd() == false and progress ~= nil and progress.isEnd == false then
            if teamInfo.teamProgress.isFight == true and teamInfo.teamProgress.isEnd == false then
                app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockBattle"})
            else 
                app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRockTeam"})
            end
        else
            app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogBlackRock"})
        end
    end)
end

-- 检查小红点
function QBlackRock:checkRedTip()
    if self:blackRockIsOpen() == false then
        return false
    end

    -- 商店
    if remote.stores:checkFuncShopRedTips(SHOP_ID.blackRockShop) then
        return true
    end
    if self:getAwardCount() > 0 then
        return true
    end
    return false
end

function QBlackRock:setCurrentAllTeams(teams)
    self._allTeams = teams
end

function QBlackRock:getCurrentAllTeams()
    return self._allTeams or {}
end

function QBlackRock:searchTeamById(teamId)
    local teams = self:getCurrentAllTeams()
    local team = {}
    for _, value in pairs(teams) do
        if value.symbol == tonumber(teamId) then
            team = value
            break
        end
    end
    return team
end

function QBlackRock:checkShopIdCanBeBuy(shopLimit)

    if self._myInfo == nil then
        return false
    end
    local myTopChapterId = tonumber(self._myInfo.topChapterId)
    local limitChapterId = shopLimit or 0
    if myTopChapterId >= tonumber(limitChapterId) then
        return true
    else
        return false
    end
end
-------------------------------------------量表-----------------------------------------------

function QBlackRock:initStaticConfig()
    self._blackrockConfig = {}
    self._dungeonConfig = {}
    local configs = QStaticDatabase:sharedDatabase():getBalckRockConfig()
    for i,v in pairs(configs) do
        table.insert(self._blackrockConfig, v)
        for _,dungeonConfig in ipairs(v) do
            self._dungeonConfig[dungeonConfig.dungeon_id] = dungeonConfig
        end
    end
    table.sort( self._blackrockConfig, function (a,b)
        return a[1].id < b[1].id
    end)
end

function QBlackRock:getChapterById(id)
    for _,v in ipairs(self._blackrockConfig) do
        if v[1].id == id then
            return v
        end
    end
end

function QBlackRock:getColorById(id)
    if id == 10101 then
        return "##g", ccc3(88, 243, 41)
    elseif id == 10201 then
        return "##b", ccc3(0, 252, 255)
    elseif id == 10301 then
        return "##p", ccc3(214, 40, 233)
    elseif id == 10401 then
        return "##o", ccc3(255, 132, 0)
    elseif id == 10501 then
        return "##r", ccc3(214, 0, 0)
    else
        return "##r", ccc3(214, 0, 0)
    end
end

--获取所有的黑石副本配置信息
function QBlackRock:getAllBalckRockConfig()
    return self._blackrockConfig
end

--获取配置通过副本ID
function QBlackRock:getConfigByDungeonId(dungeonId)
    return self._dungeonConfig[dungeonId]
end

-------------------------------------------协议推送-----------------------------------------------

--协议推送部分
function QBlackRock:registerPushCallBack()
    remote:registerPushMessage("BLACK_ROCK_MEMBER_JOIN", self, self.sendChatByPush)
    remote:registerPushMessage("BLACK_ROCK_MEMBER_QUIT", self, self.sendChatByPush)
    remote:registerPushMessage("BLACK_ROCK_MEMBER_KICKED", self, self.sendChatByPush)
    remote:registerPushMessage("BLACK_ROCK_REFRESH_RIVALS", self, self.refreshTeamInfo)
    remote:registerPushMessage("BLACK_ROCK_MEMBER_CHANGE_POSITION", self, self.refreshTeamInfo)
    remote:registerPushMessage("BLACK_ROCK_STEP_FIGHT_END", self, self.refreshTeamInfo)
    remote:registerPushMessage("BLACK_ROCK_TEAM_FIGHT_START", self, self.refreshTeamInfo)
    remote:registerPushMessage("BLACK_ROCK_FIGHT_GIVE_UP", self, self.refreshTeamInfo)
    remote:registerPushMessage("BLACK_ROCK_TEAM_FIGHT_END_AWARD", self, self.fightEndAwardHandler)
    remote:registerPushMessage("BLACK_ROCK_MEMBER_STATUS_NOTIFY", self, self.memderStatusHandler)
    remote:registerPushMessage("BLACK_ROCK_TEAM_CREATE", self, self.chatMessageHandler)    
    remote:registerPushMessage("BLACK_ROCK_TEAM_DELETE", self, self.refreshTeamInfo)  
    remote:registerPushMessage("BLACK_ROCK_ONE_KEY_INVITE", self, self.refreshTeamInfo) 
    remote:registerPushMessage("BLACK_ROCK_MEMBER_CHAT", self, self.refreshTeamInfo) 
    remote:registerPushMessage("BLACK_ROCK_REFRESH_LEADER_LAST_ACTIVE_AT", self, self.refreshTeamInfo) 


    remote:registerPushMessage("BLACK_ROCK_STEP_FIGHT_START", self, self.stepFightStartHandler)

    remote:registerPushMessage("BLACK_ROCK_MEMBER_OFFLINE", self, self.refreshTeamInfo)
    remote:registerPushMessage("BLACK_ROCK_MEMBER_ONLINE", self, self.refreshTeamInfo)

end

function QBlackRock:unregisterPushCallBack()
    remote:removePushMessage("BLACK_ROCK_MEMBER_JOIN", self, self.sendChatByPush)
    remote:removePushMessage("BLACK_ROCK_MEMBER_QUIT", self, self.sendChatByPush)
    remote:removePushMessage("BLACK_ROCK_MEMBER_KICKED", self, self.sendChatByPush)
    remote:removePushMessage("BLACK_ROCK_REFRESH_RIVALS", self, self.refreshTeamInfo)
    remote:removePushMessage("BLACK_ROCK_MEMBER_CHANGE_POSITION", self, self.refreshTeamInfo)
    remote:removePushMessage("BLACK_ROCK_STEP_FIGHT_END", self, self.refreshTeamInfo)
    remote:removePushMessage("BLACK_ROCK_TEAM_FIGHT_START", self, self.refreshTeamInfo)
    remote:removePushMessage("BLACK_ROCK_FIGHT_GIVE_UP", self, self.refreshTeamInfo)
    remote:removePushMessage("BLACK_ROCK_TEAM_FIGHT_END_AWARD", self, self.fightEndAwardHandler)
    remote:removePushMessage("BLACK_ROCK_MEMBER_STATUS_NOTIFY", self, self.memderStatusHandler)
    remote:removePushMessage("BLACK_ROCK_TEAM_CREATE", self, self.chatMessageHandler)    
    remote:removePushMessage("BLACK_ROCK_TEAM_DELETE", self, self.refreshTeamInfo)   
    remote:removePushMessage("BLACK_ROCK_ONE_KEY_INVITE", self, self.refreshTeamInfo)  

    remote:removePushMessage("BLACK_ROCK_STEP_FIGHT_START", self, self.stepFightStartHandler)

    remote:removePushMessage("BLACK_ROCK_MEMBER_OFFLINE", self, self.refreshTeamInfo)
    remote:removePushMessage("BLACK_ROCK_MEMBER_ONLINE", self, self.refreshTeamInfo)
end

function QBlackRock:sendBlacRockInvite(sendInfo)
    --如果当前第二层界面有dialog存在则拒绝邀请
    local controllers = app:getNavigationManager():getController(app.middleLayer)
    local count = controllers:countControllers(QUIViewController.TYPE_DIALOG, true)
    local page = app:getNavigationManager():getController(app.mainUILayer):getTopPage()

    local isReject = false    --5分钟内拒绝过邀请
    local rejectInviteTime = self.rejectInviteUserIdDict[sendInfo.userId]
    if rejectInviteTime and (rejectInviteTime + 5 * MIN) > q.serverTime() then
        isReject = true
    end

    if isReject or app.battle ~= nil or count > 0 or self._inviteEnable == false or page.class.__cname ~= "QUIPageMainMenu" then 
        remote.blackrock:blackRockInviteRejectRequest(sendInfo.userId)
    else
        if rejectInviteTime then
            self.rejectInviteUserIdDict[sendInfo.userId] = nil
        end
        self:dispatchEvent({name = QBlackRock.EVENT_SEND_INVITE, sendInfo = sendInfo})
    end
end

function QBlackRock:sendBlacRockInviteReject(sendInfo)
    app.tip:floatTip(string.format("魂师大人，%s正在忙，请稍后再试", (sendInfo.nickname or "")))
end

function QBlackRock:sendChatByPush(value)
    local params = string.split(value.params, "|=|")
    local nickName = string.split(params[1], "=")[2]
    local topnForce = tonumber(string.split(params[2], "=")[2])
    local num,unit = q.convertLargerNumber(topnForce)
    if value.messageType == "BLACK_ROCK_MEMBER_QUIT" then
        local message = string.format("%s(战力：%s)退出了战队", nickName, (num..(unit or "")))
        local misc = {type = "admin"}
        local severChatData = app:getServerChatData()
        severChatData:_onMessageReceived(4, nil, nil, message, q.OSTime(), misc)
    elseif value.messageType == "BLACK_ROCK_MEMBER_JOIN" then
        local message = string.format("%s(战力：%s)加入了战队", nickName, (num..(unit or "")))
        local misc = {type = "admin"}
        local severChatData = app:getServerChatData()
        severChatData:_onMessageReceived(4, nil, nil, message, q.OSTime(), misc)
    elseif value.messageType == "BLACK_ROCK_MEMBER_KICKED" then
        local message = string.format("%s(战力：%s)已被踢出队伍", nickName, (num..(unit or "")))
        local misc = {type = "admin"}
        local severChatData = app:getServerChatData()
        severChatData:_onMessageReceived(4, nil, nil, message, q.OSTime(), misc)
    end
    self:refreshTeamInfo(value)
end

function QBlackRock:refreshTeamInfo(value)
    local oldProgress = self._progress
    local isFight = false
    if self.teamInfo ~= nil and self.teamInfo.teamProgress ~= nil then
        isFight = self.teamInfo.teamProgress.isFight == true
    end
    self:blackRockGetMyInfoRequest(function ()
        self:dispatchEvent({name = QBlackRock.EVENT_UPDATE_TEAM_INFO, value = value})
        if oldProgress ~= nil and isFight == true then
            local passInfo = {}
            for i=1,3 do
                local oldProgressInfo = oldProgress[i]
                local progressInfo = self._progress[i]
                if progressInfo ~= nil and progressInfo.memberId ~= remote.user.userId then
                    local totalStep = #progressInfo.stepInfo
                    for index,stepInfo in ipairs(progressInfo.stepInfo) do
                        local oldStepInfo = oldProgressInfo.stepInfo[index]
                        if oldStepInfo ~= nil and oldStepInfo.isComplete == false and stepInfo.isComplete == true then
                            table.insert(passInfo, {fighter = self:getMemberById(progressInfo.memberId), stepInfo = stepInfo, isPass = (index == totalStep)})
                        end 
                    end
                end
            end
            if #passInfo > 0 then
                self:dispatchEvent({name = QBlackRock.EVENT_PASS_INFO, passInfo = passInfo})
            end
        end
    end)
end

--成员状态变化
function QBlackRock:memderStatusHandler(value)
    local params = string.split(value.params, "|=|")
    local userId = string.split(params[1], "=")[2]
    local status = tonumber(string.split(params[2], "=")[2])
    for _,progress in pairs(self._progress) do
        if progress.memberId == userId then
            progress.memberSts = status
            break
        end
    end
    self:dispatchEvent({name = QBlackRock.EVENT_UPDATE_TEAM_INFO, value = value})
end

function QBlackRock:fightEndAwardHandler(v)
    self._isEnd = true
    local params = string.split(v.params, "|=|")
    self._endAwardId = params[1]
    self._endAwards = remote.items:analysisServerItem(params[2], awards)
    self._endScore = tonumber(params[3] or 0)
    self._giveAward = params[4] == "true"
    self._isPlayerComeBack = params[5] == "true"
    
    self:dispatchEvent({name = QBlackRock.EVENT_FIGHT_END_AWARDS})
    
    self:blackRockGetMyInfoRequest(nil, nil, true)
end

--吃BUFF改变HP和MP
function QBlackRock:eatBuffById(buffId, herosHpMp)
    local _herosHpMp = herosHpMp or {}
    local buffConfig = QStaticDatabase:sharedDatabase():getBlackRockBuffId(buffId)
    if buffConfig and buffConfig.buff_property then
        local buffDatas = string.split(buffConfig.buff_property, ":")
        local fieldName = buffDatas[1]
        local value = tonumber(buffDatas[2])
        if fieldName == "energy" then
            for _,v in ipairs(_herosHpMp) do
                v.currMp = v.currMp + value
            end
        elseif fieldName == "hp_percent" then
            for _,v in ipairs(_herosHpMp) do
                if v.currHp > 0 then
                    local heroModel = remote.herosUtil:createHeroPropById(v.actorId)
                    local totalHp = heroModel:getMaxHp()
                    if totalHp ~= nil then
                        v.currHp = math.floor(v.currHp + totalHp * value)
                    else
                        print(v.actorId, " hp is nil ")
                    end
                end
            end
        end
    end
    return _herosHpMp
end

--扫荡后通知更新进度
function QBlackRock:quickFightEnd( )
    self:dispatchEvent({name = QBlackRock.EVENT_FIGHT_QUICK})
end

function QBlackRock:setLastFastFightSeclectId(dungeonId )
    self._lastFastFightSelectId = dungeonId
end

function QBlackRock:getLastFastFightSeclectId( )
    return self._lastFastFightSelectId
end
--清除最后的奖励
function QBlackRock:clearEndAwards()
    self._endAwards = nil
    self._endAwardId = nil
    self._endScore = nil
    self._giveAward = nil
    self._isPlayerComeBack = nil
end

function QBlackRock:getEndAwards()
    if self._endAwards ~= nil then
        local tbl = {}
        tbl.endAwards = self._endAwards
        tbl.endAwardId = self._endAwardId
        tbl.endScore = self._endScore
        tbl.giveAward = self._giveAward
        tbl.isPlayerComeBack = self._isPlayerComeBack
        self:clearEndAwards()
        return tbl
    end
    return nil
end

function QBlackRock:stepFightStartHandler(v)
    --userId=8bc5dd89-8bb9-4e04-b912-6e88c7c1a587|=|stepId=4010103
    local params = string.split(v.params, "|=|")
    local userId = string.split(params[1],"=")[2]
    local stepId = string.split(params[2],"=")[2]
    local teamInfo = self:getTeamInfo()
    if teamInfo == nil then return false end
    
    for _,progress in ipairs(teamInfo.teamProgress.allProgress) do
        if progress.memberId == userId then
            progress.isFightStart = true
            break
        end
    end
    self:setTeamInfo(teamInfo)
    self:dispatchEvent({name = QBlackRock.EVENT_UPDATE_TEAM_INFO, value = v})
end

function QBlackRock:chatMessageHandler(value)
    if app.unlock:checkLock("UNLOCK_BLACKROCK", false) == false then
        return
    end
    -- value.params = "chapterId=10101|=|teamId=6f1fc857-2193-4a40-ab49-0c4fecf9ee0f|=|gameAreaName=Alpha测试服|=|userId=7180029f-1f50-4fb1-9bd7-543de9d8e3a6|=|nickName=w001|=|topnForce=40790435"
    local tbl = q.convertStrToTable(value.params,{"|=|","="})
    local chapterInfos = self:getChapterById(tonumber(tbl.chapterId))
    local num, unit = q.convertLargerNumber(tbl.topnForce)
    local num2,unit2 = q.convertLargerNumber(chapterInfos[1].monster_battleforce)
    local color = self:getColorById(tonumber(tbl.chapterId))
    local message = string.format("##n%s（战力：%s）在%s%s(%s)##n创建了队伍，大家快来加入吧~", tbl.nickName, (num..(unit or "")), color, chapterInfos[1].name, (num2..(unit2 or "")))
    local misc = {type = "blackrock", teamId = tbl.teamId, chapterId = tbl.chapterId, nickName = tbl.nickName, avatar = tbl.avatar, vip = tbl.vip, badge = tbl.badge}
    app:getServerChatData():_onMessageReceived(CHANNEL_TYPE.TEAM_INFO_CHANNEL, tbl.userId, tbl.nickName, message, q.OSTime(), misc)
end

-------------------------------------------协议请求-----------------------------------------------


    -- //黑石山Response
    -- optional BlackRockGetChapterTeamListResponse blackRockGetChapterTeamListResponse = 526;
    -- optional BlackRockGetMyInfoResponse blackRockGetMyInfoResponse = 527;
    -- optional BlackRockBuyAwardCountResponse blackRockBuyAwardCountResponse = 528;
    -- optional BlackRockGetTeamAwardListResponse blackRockGetTeamAwardListResponse = 529;
    -- optional BlackRockGetTeamAwardResponse blackRockGetTeamAwardResponse = 530;
    -- optional BlackRockGetOnlineConsortiaMemberListResponse blackRockGetOnlineConsortiaMemberListResponse = 531;
    -- optional BlackRockInviteConsortiaMemberJoinTeamResponse blackRockInviteConsortiaMemberJoinTeamResponse = 532;
    -- optional BlackRockAcceptInviteJoinTeamResponse blackRockAcceptInviteJoinTeamResponse = 533;
    -- optional BlackRockCreateTeamResponse blackRockCreateTeamResponse = 534;
    -- optional BlackRockJoinTeamResponse blackRockJoinTeamResponse = 535;
    -- optional BlackRockQuitTeamResponse blackRockQuitTeamResponse = 536;
    -- optional BlackRockKickOffTeamResponse blackRockKickOffTeamResponse = 537;

--黑石山-获取我的信息Request,BlackRockGetMyInfoRequest
function QBlackRock:blackRockGetMainMyInfoRequest(success, fail, isOnlyMyInfo)
    if isOnlyMyInfo == nil then isOnlyMyInfo = false end
    local request = {api = "BLACK_ROCK_GET_MY_INFO"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockGetMyInfoResponse(response, success, nil, true, isOnlyMyInfo)
    end, function (response)
        self:blackRockGetMyInfoResponse(response, nil, fail, false, isOnlyMyInfo)
    end)
end

--黑石山-获取我的信息Request,BlackRockGetMyInfoRequest
function QBlackRock:blackRockGetMyInfoRequest(success, fail, isOnlyMyInfo)
    if isOnlyMyInfo == nil then isOnlyMyInfo = false end
    local blackRockGetMyInfoRequest = {}
    local request = {api = "BLACK_ROCK_GET_MAIN_INFO", blackRockGetMyInfoRequest = blackRockGetMyInfoRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockGetMyInfoResponse(response, success, nil, true, isOnlyMyInfo)
    end, function (response)
        self:blackRockGetMyInfoResponse(response, nil, fail, false, isOnlyMyInfo)
    end)
end

function QBlackRock:blackRockGetMyInfoResponse(data, success, fail, succeeded, isOnlyMyInfo)
    if data.blackRockGetMyInfoResponse ~= nil then
        self:setMyInfo(data.blackRockGetMyInfoResponse.myInfo)
        self:setRandomSoulSprit(data.blackRockGetMyInfoResponse.dayOfYear)
        if isOnlyMyInfo == false then
            self:setTeamInfo(data.blackRockGetMyInfoResponse.myTeam)
        end
    end
    self:responseHandler(data, success, fail, succeeded)
end

--黑石山-获取章节组队信息列表Request,BlackRockGetChapterTeamListRequest
function QBlackRock:blackRockGetChapterTeamListRequest(chapterId, teamId,success, fail)
    local blackRockGetChapterTeamListRequest = {chapterId = chapterId,teamId = teamId or ""}
    local request = {api = "BLACK_ROCK_GET_CHAPTER_TEAM_LIST", blackRockGetChapterTeamListRequest = blackRockGetChapterTeamListRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockGetChapterTeamListResponse(response, success, nil, true)
    end, function (response)
        self:blackRockGetChapterTeamListResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockGetChapterTeamListResponse(data, success, fail, succeeded)
    self:responseHandler(data,success,fail, succeeded)
end

--黑石山-购买领奖次数Request,BlackRockBuyAwardCountRequest
function QBlackRock:blackRockBuyAwardCountRequest(success, fail)
    local blackRockBuyAwardCountRequest = {}
    local request = {api = "BLACK_ROCK_BUY_AWARD_COUNT", blackRockBuyAwardCountRequest = blackRockBuyAwardCountRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockBuyAwardCountResponse(response, success, nil, true)
    end, function (response)
        self:blackRockBuyAwardCountResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockBuyAwardCountResponse(data, success, fail, succeeded)
    if data.blackRockBuyAwardCountResponse ~= nil then
        self:setMyInfo(data.blackRockBuyAwardCountResponse.myInfo)
    end
    self:responseHandler(data,success,fail, succeeded)
end

--黑石山-获取组队战奖励列表Request,BlackRockGetTeamAwardListRequest
function QBlackRock:blackRockGetTeamAwardListRequest(success, fail)
    local blackRockGetTeamAwardListRequest = {}
    local request = {api = "BLACK_ROCK_GET_TEAM_AWARD_LIST", blackRockGetTeamAwardListRequest = blackRockGetTeamAwardListRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockGetTeamAwardListResponse(response, success, nil, true)
    end, function (response)
        self:blackRockGetTeamAwardListResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockGetTeamAwardListResponse(data, success, fail, succeeded)
    self:responseHandler(data,success,fail, succeeded)
end

--黑石山-领取组队战奖励Request,BlackRockGetTeamAwardRequest
function QBlackRock:blackRockGetTeamAwardRequest(awardId, isDouble,isGiveUp,success, fail)
    local blackRockGetTeamAwardRequest = {awardId = awardId,isDouble = isDouble,isGiveUp = isGiveUp}
    local request = {api = "BLACK_ROCK_GET_TEAM_AWARD", blackRockGetTeamAwardRequest = blackRockGetTeamAwardRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockGetTeamAwardResponse(response, success, nil, true)
    end, function (response)
        self:blackRockGetTeamAwardResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockGetTeamAwardResponse(data, success, fail, succeeded)
    if data.blackRockGetTeamAwardResponse ~= nil then
        self:setMyInfo(data.blackRockGetTeamAwardResponse.myInfo)
    end
    self:responseHandler(data,success,fail, succeeded)
end

--黑石山-获取在线宗门会员列表Request,BlackRockGetOnlineConsortiaMemberListRequest
function QBlackRock:blackRockGetOnlineConsortiaMemberListRequest(chapterId, success, fail)
    local blackRockGetOnlineConsortiaMemberListRequest = {chapterId = chapterId}
    local request = {api = "BLACK_ROCK_GET_ONLINE_CONSORTIA_MEMBER_LIST", blackRockGetOnlineConsortiaMemberListRequest = blackRockGetOnlineConsortiaMemberListRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockGetOnlineConsortiaMemberListResponse(response, success, nil, true)
    end, function (response)
        self:blackRockGetOnlineConsortiaMemberListResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockGetOnlineConsortiaMemberListResponse(data, success, fail, succeeded)
    self:responseHandler(data,success,fail, succeeded)
end

--黑石山-邀请宗门会员加入组队队伍Request,BlackRockInviteConsortiaMemberJoinTeamRequest
function QBlackRock:blackRockInviteConsortiaMemberJoinTeamRequest(consortiaMemberId, chapterId, teamId, success, fail)
    local blackRockInviteConsortiaMemberJoinTeamRequest = {consortiaMemberId = consortiaMemberId, chapterId = chapterId, teamId = teamId}
    local request = {api = "BLACK_ROCK_INVITE_CONSORTIA_MEMBER_JOIN_TEAM", blackRockInviteConsortiaMemberJoinTeamRequest = blackRockInviteConsortiaMemberJoinTeamRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockInviteConsortiaMemberJoinTeamResponse(response, success, nil, true)
    end, function (response)
        self:blackRockInviteConsortiaMemberJoinTeamResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockInviteConsortiaMemberJoinTeamResponse(data, success, fail, succeeded)
    self:responseHandler(data,success,fail, succeeded)
end

--黑石山-接受邀请加入组队队伍Request,BlackRockAcceptInviteJoinTeamRequest
function QBlackRock:blackRockAcceptInviteJoinTeamRequest(teamId, success, fail)
    local blackRockAcceptInviteJoinTeamRequest = {teamId = teamId}
    local request = {api = "BLACK_ROCK_ACCEPT_INVITE_JOIN_TEAM", blackRockAcceptInviteJoinTeamRequest = blackRockAcceptInviteJoinTeamRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockAcceptInviteJoinTeamResponse(response, success, nil, true)
    end, function (response)
        self:blackRockAcceptInviteJoinTeamResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockAcceptInviteJoinTeamResponse(data, success, fail, succeeded)
    self:responseHandler(data,success,fail, succeeded)
end

--黑石山-创建队伍Request,BlackRockCreateTeamRequest
function QBlackRock:blackRockCreateTeamRequest(chapterId, success, fail)
    local blackRockCreateTeamRequest = {chapterId = chapterId}
    local request = {api = "BLACK_ROCK_CREATE_TEAM", blackRockCreateTeamRequest = blackRockCreateTeamRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockCreateTeamResponse(response, success, nil, true)
    end, function (response)
        self:blackRockCreateTeamResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockCreateTeamResponse(data, success, fail, succeeded)
    self:clearEndAwards()
    if data.blackRockCreateTeamResponse ~= nil then
        self:setTeamInfo(data.blackRockCreateTeamResponse.myTeam)
    end
    self:responseHandler(data,success,fail, succeeded)
end

--黑石山-加入队伍Request,BlackRockJoinTeamRequest
function QBlackRock:blackRockJoinTeamRequest(teamId, chapterId, password, joinType, success, fail)
    local blackRockJoinTeamRequest = {teamId = teamId, chapterId = chapterId,password = password,joinType= joinType}
    local request = {api = "BLACK_ROCK_JOIN_TEAM", blackRockJoinTeamRequest = blackRockJoinTeamRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockJoinTeamResponse(response, success, nil, true)
    end, function (response)
        self:blackRockJoinTeamResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockJoinTeamResponse(data, success, fail, succeeded)
    if succeeded then
        app.tip:floatTip("加入成功，请点击准备~")
    end
    self:clearEndAwards()
    if data.blackRockJoinTeamResponse ~= nil then
        self:setTeamInfo(data.blackRockJoinTeamResponse.myTeam)
        self:setMyInfo(data.blackRockJoinTeamResponse.myInfo)
    end
    self:responseHandler(data,success,fail, succeeded)
end

--黑石山-退出队伍Request,BlackRockQuitTeamRequest
function QBlackRock:blackRockQuitTeamRequest(success, fail)
    local blackRockQuitTeamRequest = {}
    local request = {api = "BLACK_ROCK_QUIT_TEAM",blackRockQuitTeamRequest = blackRockQuitTeamRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockQuitTeamResponse(response, success, nil, true)
    end, function (response)
        self:blackRockQuitTeamResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockQuitTeamResponse(data, success, fail, succeeded)
    self:setTeamInfo()
    self:responseHandler(data,success,fail, succeeded)
end

--黑石山-踢出队伍Request,BlackRockKickOffTeamRequest
function QBlackRock:blackRockKickOffTeamRequest(teamMemberId, success, fail)
    local blackRockKickOffTeamRequest = {teamMemberId = teamMemberId}
    local request = {api = "BLACK_ROCK_KICK_OFF_TEAM", blackRockKickOffTeamRequest = blackRockKickOffTeamRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockKickOffTeamResponse(response, success, nil, true)
    end, function (response)
        self:blackRockKickOffTeamResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockKickOffTeamResponse(data, success, fail, succeeded)
    if data.blackRockKickOffTeamResponse ~= nil then
        self:setTeamInfo(data.blackRockKickOffTeamResponse.myTeam)
    end
    self:responseHandler(data,success,fail, succeeded)
end

--黑石山-刷新对手信息Request,BlackRockRefreshTeamRivalsRequest
-- optional bool isAllBoss = 1;
function QBlackRock:blackRockRefreshTeamRivalsRequest(isAllBoss, success, fail)
    local blackRockRefreshTeamRivalsRequest = {isAllBoss = isAllBoss}
    local request = {api = "BLACK_ROCK_REFRESH_TEAM_RIVALS", blackRockRefreshTeamRivalsRequest = blackRockRefreshTeamRivalsRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockRefreshTeamRivalsResponse(response, success, nil, true)
    end, function (response)
        self:blackRockRefreshTeamRivalsResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockRefreshTeamRivalsResponse(data, success, fail, succeeded)
    if data.blackRockRefreshTeamRivalsResponse ~= nil then
        self:setTeamInfo(data.blackRockRefreshTeamRivalsResponse.myTeam)
        self:setMyInfo(data.blackRockRefreshTeamRivalsResponse.myInfo)
    end
    self:responseHandler(data,success,fail, succeeded)
end

--黑石山-交换玩家的出战位置Request,BlackRockChangeMemberPositionRequest
function QBlackRock:blackRockChangeMemberPositionRequest(memberPos1, memberPos2, success, fail)
    local blackRockChangeMemberPositionRequest = {memberPos1 = memberPos1, memberPos2 = memberPos2}
    local request = {api = "BLACK_ROCK_CHANGE_MEMBER_POSITION", blackRockChangeMemberPositionRequest = blackRockChangeMemberPositionRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockChangeMemberPositionResponse(response, success, nil, true)
    end, function (response)
        self:blackRockChangeMemberPositionResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockChangeMemberPositionResponse(data, success, fail, succeeded)
    if data.blackRockChangeMemberPositionResponse ~= nil then
        self:setTeamInfo(data.blackRockChangeMemberPositionResponse.myTeam)
    end
    self:responseHandler(data,success,fail, succeeded)
end

--黑石山-队伍战斗开始Request,BlackRockTeamFightStartRequest
function QBlackRock:blackRockTeamFightStartRequest(success, fail)
    local blackRockTeamFightStartRequest = {}
    local request = {api = "BLACK_ROCK_TEAM_FIGHT_START", blackRockTeamFightStartRequest = blackRockTeamFightStartRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockTeamFightStartResponse(response, success, nil, true)
    end, function (response)
        self:blackRockTeamFightStartResponse(response, nil, fail)
    end)
    -- body
end

function QBlackRock:blackRockTeamFightStartResponse(data, success, fail, succeeded)
    if data.blackRockTeamFightStartResponse ~= nil then
        self:setTeamInfo(data.blackRockTeamFightStartResponse.myTeam)
    end
    self:responseHandler(data,success,fail, succeeded)
end

--黑石山-队员阶段战斗结束Request,BlackRockMemberStepFightEndRequest
function QBlackRock:blackRockMemberStepFightEndRequest(fightStep, herosHpMp, fightReportData, battleFormation, progressId, battleVerify, success, fail)   
    local blackRockMemberStepFightEndRequest = {fightStep = fightStep, herosHpMp = herosHpMp, progressId = progressId}
    local battleVerify = q.battleVerifyHandler(battleVerify)
    local gfEndRequest = {battleType = BattleTypeEnum.BLACK_ROCK, battleVerify = battleVerify,isQuick = false, isWin = nil, fightReportData  = fightReportData,
                                 blackRockMemberStepFightEndRequest = blackRockMemberStepFightEndRequest}
    local request = {api = "GLOBAL_FIGHT_END", gfEndRequest = gfEndRequest, battleFormation = battleFormation}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockMemberStepFightEndResponse(response, success, nil, true)
    end, function (response)
        self:blackRockMemberStepFightEndResponse(response, nil, fail)
    end)
end

--[[
    扫荡
]]
function QBlackRock:responsBlackRockFightQuick(fightStep, progressId, success, fail)
    local blackRockQuickFightRequestRequest = {fightStep = fightStep, progressId = progressId}
    local gfQuickRequest = {battleType = BattleTypeEnum.BLACK_ROCK, blackRockQuickFightRequestRequest = blackRockQuickFightRequestRequest}
    local request = {api = "GLOBAL_FIGHT_QUICK", gfQuickRequest = gfQuickRequest}
    app:getClient():requestPackageHandler("GLOBAL_FIGHT_QUICK", request, function (response)
        self:blackRockMemberStepFightEndResponse(response, success, nil, true)
    end, function (response)
        self:blackRockMemberStepFightEndResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockMemberStepFightEndResponse(data, success, fail, succeeded)
    if data.gfEndResponse ~= nil and data.gfEndResponse.blackRockMemberStepFightEndResponse ~= nil then
        self:setTeamInfo(data.gfEndResponse.blackRockMemberStepFightEndResponse.myTeam)
        self:setMyInfo(data.gfEndResponse.blackRockMemberStepFightEndResponse.myInfo)
    end
    self:responseHandler(data,success,fail, succeeded)
end

--黑石山-吃BUFFRequest,blackRockEatBuffRequest
function QBlackRock:blackRockEatBuffRequest(buffId, herosHpMp, progressId, success, fail)
    herosHpMp = self:eatBuffById(buffId, herosHpMp)
    local blackRockEatBuffRequest = {buffId = buffId, herosHpMp = herosHpMp, progressId = progressId}
    local request = {api = "BLACK_ROCK_EAT_BUFF", blackRockEatBuffRequest = blackRockEatBuffRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockEatBuffResponse(response, success, nil, true)
    end, function (response)
        self:blackRockEatBuffResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockEatBuffResponse(data, success, fail, succeeded)
    if data.blackRockEatBuffResponse ~= nil then
        self:setTeamInfo(data.blackRockEatBuffResponse.myTeam)
    end
    self:responseHandler(data,success,fail, succeeded)
end

function QBlackRock:blackRockGetProgressInfoRequest(progressId,success,fail)
    local blackRockGetProgressInfoRequest = {progressId = progressId}
    local request = {api = "BLACK_ROCK_GET_PROGRESS_INFO",blackRockGetProgressInfoRequest = blackRockGetProgressInfoRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        if response.blackRockGetProgressInfoResponse ~= nil then
            self:setTeamInfo(response.blackRockGetProgressInfoResponse.myTeam)
        end
        self:responseHandler(response,success,nil, true)    
    end, function (response)
        self:responseHandler(response,nil,fail)    
    end)    
end
--黑石山-战斗结算之后弹出的时候领取奖励
function QBlackRock:blackRockDoTeamFightEndRequest(progressId,isDouble,isGiveUp,success, fail)
    local blackRockDoTeamFightEndRequest = {progressId = progressId,isDouble = isDouble,isGiveUp = isGiveUp}
    local request = {api = "BLACK_ROCK_DO_TEAM_FIGHT_END", blackRockDoTeamFightEndRequest = blackRockDoTeamFightEndRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockDoTeamFightEndResponse(response, success, nil, true)
    end, function (response)
        self:blackRockDoTeamFightEndResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockDoTeamFightEndResponse(data, success, fail, succeeded)
    if data.blackRockDoTeamFightEndResponse ~= nil then
        self:setTeamInfo(data.blackRockDoTeamFightEndResponse.myTeam)
    end
    self:responseHandler(data,success,fail, succeeded)    
end

-- 黑石山-拉取战报列表
function QBlackRock:blackRockGetTeamFightReportList(success, fail)
    local request = {api = "BLACK_ROCK_GET_TEAM_FIGHT_REPORT_LIST"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

-- 黑石山-
function QBlackRock:blackRockGetMemberFightReportList(progressId, success, fail)
    local blackRockGetMemberFightReportListRequest = {progressId = progressId}
    local request = {api = "BLACK_ROCK_GET_MEMBER_FIGHT_REPORT_LIST", blackRockGetMemberFightReportListRequest = blackRockGetMemberFightReportListRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--黑石山-战斗结算之后弹出的时候领取奖励
function QBlackRock:blackRockInviteRejectRequest(userId, success, fail)
    local blackRockInviteRejectRequest = {userId = userId}
    local request = {api = "BLACK_ROCK_INVITE_REJECT", blackRockInviteRejectRequest = blackRockInviteRejectRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockInviteRejectResponse(response, success, nil, true)
    end, function (response)
        self:blackRockInviteRejectResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockInviteRejectResponse(data, success, fail, succeeded)
    self:responseHandler(data,success,fail, succeeded)    
end

--自动加入队伍
function QBlackRock:blackRockAutoJoinTeamRequest(chapterId, success, fail)
    local blackRockAutoJoinTeamRequest = {chapterId = chapterId}
    local request = {api = "BLACK_ROCK_AUTO_JOIN_TEAM", blackRockAutoJoinTeamRequest = blackRockAutoJoinTeamRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockAutoJoinTeamResponse(response, success, nil, true)
    end, function (response)
        self:blackRockAutoJoinTeamResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockAutoJoinTeamResponse(data, success, fail, succeeded)
    if data.blackRockAutoJoinTeamResponse ~= nil then
        self:setTeamInfo(data.blackRockAutoJoinTeamResponse.myTeam)
    end
    self:responseHandler(data,success,fail, succeeded)
end

--一键邀请请求
function QBlackRock:blackRockOneKeyInviteRequest(success, fail)
    local request = {api = "BLACK_ROCK_ONE_KEY_INVITE"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockOneKeyInviteResponse(response, success, nil, true)
    end, function (response)
        self:blackRockOneKeyInviteResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockOneKeyInviteResponse(data, success, fail, succeeded)
    if data.blackRockOneKeyInviteResponse ~= nil then
        self:setTeamInfo(data.blackRockOneKeyInviteResponse.myTeam)
    end
    self:responseHandler(data, success, fail, succeeded)
end

--放弃战斗
function QBlackRock:blackRockMemberFightGiveUpRequest(success, fail)
    local request = {api = "BLACK_ROCK_MEMBER_FIGHT_GIVE_UP"}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockMemberFightGiveUpResponse(response, success, nil, true)
    end, function (response)
        self:blackRockMemberFightGiveUpResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockMemberFightGiveUpResponse(data, success, fail, succeeded)
    if data.blackRockMemberFightGiveUpResponse ~= nil then
        self:setTeamInfo(data.blackRockMemberFightGiveUpResponse.myTeam)
        self:setMyInfo(data.blackRockMemberFightGiveUpResponse.myInfo)
    end
    self:responseHandler(data, success, fail, succeeded)
end

--开始战斗
function QBlackRock:blackRockMemberStepFightStartRequest(stepId, progressId, battleFormation,success, fail)
    local blackRockMemberStepFightStartRequest = {stepId = stepId, progressId = progressId}
   local gfStartRequest = {battleType = BattleTypeEnum.BLACK_ROCK, battleFormation = battleFormation, blackRockMemberStepFightStartRequest = blackRockMemberStepFightStartRequest}
    local request = {api = "GLOBAL_FIGHT_START", gfStartRequest = gfStartRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:responseHandler(response, success, nil, true)
    end, function (response)
        self:responseHandler(response, nil, fail)
    end)
end

--准备
function QBlackRock:blackRockFightReadyRequest(isCancel, success, fail)
    local blackRockFightReadyRequest = {isCancel = isCancel}
    local request = {api = "BLACK_ROCK_FIGHT_READY", blackRockFightReadyRequest = blackRockFightReadyRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockFightReadyResponse(response, success, nil, true)
    end, function (response)
        self:blackRockFightReadyResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockFightReadyResponse(data, success, fail, succeeded)
    if data.blackRockFightReadyResponse ~= nil then
        self:setTeamInfo(data.blackRockFightReadyResponse.myTeam)
    end
    self:responseHandler(data, success, fail, succeeded)
end

function QBlackRock:blackRockShareInviteMessageRequest(success, fail)
    local blackRockShareInviteMessageRequest = {}
    local request = {api = "BLACK_ROCK_SHARE_INVITE_MESSAGE", blackRockShareInviteMessageRequest = blackRockShareInviteMessageRequest}
    app:getClient():requestPackageHandler(request.api, request, success, fail)
end

function QBlackRock:blackRockSetPasswordRequest(password, success, fail)
    local blackRockSetPasswordRequest = {password = password}
    local request = {api = "BLACK_ROCK_SET_PASSWORD", blackRockSetPasswordRequest = blackRockSetPasswordRequest}
    app:getClient():requestPackageHandler(request.api, request, function (response)
        self:blackRockSetPasswordResponse(response, success, nil, true)
    end, function (response)
        self:blackRockSetPasswordResponse(response, nil, fail)
    end)
end

function QBlackRock:blackRockSetPasswordResponse(data, success, fail, succeeded)
    if data.blackRockChangeMemberPositionResponse ~= nil then
        self:setTeamInfo(data.blackRockChangeMemberPositionResponse.myTeam)
    end
    self:responseHandler(data, success, fail, succeeded)
end

function QBlackRock:responseHandler(data, success, fail, succeeded)
    if data.api == "BLACK_ROCK_SET_PASSWORD" and data.error == "NO_ERROR" then
        self:dispatchEvent({name = QBlackRock.EVENT_UPDATE_STATE})
    end
    if succeeded == true then
        if success ~= nil then
            success(data)
        end
    else
        if fail ~= nil then
            fail(data)
        end
    end
end

return QBlackRock