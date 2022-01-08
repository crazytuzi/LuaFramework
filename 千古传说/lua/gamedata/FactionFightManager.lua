--[[
******帮派战数据管理类*******

	-- by quanhuan
	-- 2016/2/23
	
]]

local FactionFightManager = class("FactionFightManager")

FactionFightManager.ActivityState_0 = 0--活动未开启
FactionFightManager.ActivityState_1 = 1--预选阶段
FactionFightManager.ActivityState_2 = 2--报名阶段
FactionFightManager.ActivityState_3 = 3--战斗阶段
FactionFightManager.ActivityState_4 = 4--展示阶段

FactionFightManager.updateRankSuccess = 'FactionFightManager.updateRankSuccess'
FactionFightManager.activityStateChange = 'FactionFightManager.activityStateChange'
FactionFightManager.winnerInfoUpdate = 'FactionFightManager.winnerInfoUpdate'
FactionFightManager.guildMemberUpdate = 'FactionFightManager.guildMemberUpdate'
FactionFightManager.requesWarInfosSuccess ="FactionFightManager.requesWarInfosSuccess"
FactionFightManager.onReplayInfosSuccess ="FactionFightManager.onReplayInfosSuccess"

function FactionFightManager:ctor(data)

    --繁荣度增长排行
    TFDirector:addProto(s2c.RANK_LIST_GUILD_INC_BOOM, self, self.onUpdateRank)
    --帮派战状态
    TFDirector:addProto(s2c.GUILD_BATTLE_STATE, self, self.onActivityUpdate)
    --成员的报名信息
    TFDirector:addProto(s2c.GUILD_BATTLE_MEMBER_INFO, self, self.onGuildMemberReceive)
    --报名成功
    TFDirector:addProto(s2c.APPLY_SUCESS, self, self.onRequestSignUpReceive)
    --取消报名成功
    TFDirector:addProto(s2c.UNAPPLY_SUCESS, self, self.onRequestCancelSignUpReceive)
    --修改精英成功
    TFDirector:addProto(s2c.UPDATE_ELITE_SUCESS, self, self.onUpdateLeaderReceive)
    --请求上一次冠军
    TFDirector:addProto(s2c.GUILD_BATTLE_LAST_WINER_INFO, self, self.onWinnerResult)
    -- 请求对战信息
    TFDirector:addProto(s2c.GUILD_BATTLE_WAR_INFOS, self, self.onRequestWarInfos)
    -- 请求录像信息
    TFDirector:addProto(s2c.GUILD_BATTLE_REPLAY_INFOS, self, self.onReplayInfosCallBack)


	self:restart()
end

function FactionFightManager:restart()
    self.guildMemberList = {} --公会战报名的成员信息
    self.guildLeaderList = {} --公会战精英信息
    self.guildBoomRankList = {} --公会繁荣度排名信息
    self.myBoomRankInfo = {} --我的公告排名信息
    self.lastWinnerInfo = {} --上一次冠军信息

    self.fightDetailInfo = {} -- 对战详细信息
    self.atkMemberInfo = {} --对战攻击方成员信息
    self.defMemberInfo = {} --对战防守方成员信息
    self.atkGuildInfo = {} --攻击方帮派信息
    self.defGuildInfo = {} --防守方帮派信息

    self.round = 0
    self.index = 0

end

function FactionFightManager:reConnect()
	-- body
end
function FactionFightManager:reLoad()
	-- body
end

function FactionFightManager:getTimeString( second )
    local day = math.floor(second/(24*60*60))
    second = second - 24*60*60*day
    local hour = math.floor(second/(60*60))
    second = second - 60*60*hour
    local min = math.floor(second/(60))
    second = second - 60*min
    --local str = string.format('%d天%d小时%d分%d秒', day, hour, min, second)
    local str = stringUtils.format(localizable.common_time_7_ex, day, hour, min, second) 
    return str
end

function FactionFightManager:getLeaderDataByIndex(index)
    
    return self.guildLeaderList[index]
end

function FactionFightManager:getMemberDataByIndex(index)
    return self.guildMemberList[index]
end

function FactionFightManager:onActivityUpdate( event )
    local state = event.data.state
    self:setActivityState(state)
end

function FactionFightManager:setActivityState(state)    

    self.activityState = state    
    TFDirector:dispatchGlobalEventWith(FactionFightManager.activityStateChange)
end

function FactionFightManager:getActivityState()
    return self.activityState
end

function FactionFightManager:openCurrLayer()

    if FactionManager:isJoinFaction() == false then
        --toastMessage('请先加入帮派')
	toastMessage(localizable.FactionFightManager_join_before)
        return
    end

    local state = self:getActivityState()
    if state == self.ActivityState_1 then
        local layer = require("lua.logic.factionfight.FightMainLayer"):new()
        layer:switchShowLayer(1)
        AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
        AlertManager:show()
    elseif state == self.ActivityState_2 then
        local layer = require("lua.logic.factionfight.FightMainLayer"):new()
        layer:switchShowLayer(2)
        AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
        AlertManager:show()
    elseif state == self.ActivityState_3 then
        --self:enterFightMessage()
        FactionFightManager:requestWarInfos()   
    elseif state == self.ActivityState_4 then
        local layer = require("lua.logic.factionfight.FightMainLayer"):new()
        layer:switchShowLayer(3)
        AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
        AlertManager:show()
    else
        --toastMessage('不在活动时间内')
	toastMessage(localizable.FactionFightManager_not_in_avtivity)
        return
    end
end

function FactionFightManager:switchToFightOrMainLayer(layer)
    AlertManager:closeAllToLayer(layer)
    self:openCurrLayer()
end

function FactionFightManager:getCutDownTimeByState( state )
    local desTime = nil
    if state == self.ActivityState_1 then
        desTime = ConstantData:objectByID("Gangwar.Qualifier.Over").value
    elseif state == self.ActivityState_2 then
        desTime = ConstantData:objectByID("Gangwar.Qualifier.Over").value + ConstantData:objectByID("Gangwar.Signup.Over").value
        desTime = desTime + ConstantData:objectByID("Gangwar.Warstart.Over").value
    end

    if desTime then
        local date = os.date("*t", MainPlayer:getNowtime())
        if date.wday == 1 then
            date.wday = 8
        end
        local wday = date.wday - 2        
        local nowTime = wday*(24*60*60) + (date.hour*60 + date.min)*60 + date.sec
        local timeCount = desTime - nowTime
        if timeCount < 0 then
            timeCount = 0
        end
        return timeCount
    end
    return 9999999
end

function FactionFightManager:getFightTime()
    local state = self:getActivityState()
    if state ~= self.ActivityState_3 then
        return nil
    end

    local desTime = ConstantData:objectByID("Gangwar.Qualifier.Over").value + ConstantData:objectByID("Gangwar.Signup.Over").value
    desTime = desTime + ConstantData:objectByID("Gangwar.Warstart.Over").value
    --local desTime = 7*24*60*60 + 9*60*60
    local date = os.date("*t", MainPlayer:getNowtime())
    if date.wday == 1 then
        date.wday = 8
    end
    local wday = date.wday - 2

    local nowTime = wday*(24*60*60) + (date.hour*60 + date.min)*60 + date.sec
    local timeCount = nowTime - desTime
    if timeCount < 0 then
        timeCount = 0
    end
    return timeCount
end

--计算当前战斗场次
--[[@return 
    当前场次
    下一场倒计时
]]
function FactionFightManager:getFightRound()
    -- body
    if self:getActivityState() == 3 then
        local timeCount = self:getFightTime()
        local desTime =  ConstantData:objectByID("Gangwar.Team.Time").value
        local index =  math.modf(timeCount / desTime)  --场次
        local nextTime = (index + 1) * desTime - timeCount    --距离下一场的倒计时
        local bOver = false
        if nextTime < 0 then
            bOver = true
        end 
        if  index > 3 then
            bOver = true
        end 
        return index , nextTime ,bOver
    else
        return 5 , 0 ,true
    end
end

--[[
    帮派繁荣排名
]]
function FactionFightManager:requestUpdateRank()
    showLoading()
    local Msg = 
    {
        12,
        0,
        16,0,0,0
    }
    TFDirector:send(c2s.QUERY_RANKING_BASE_INFO,Msg)
end

function FactionFightManager:onUpdateRank( event )

    local data = event.data

    local guildBoomRank = data.infos or {}
    self.guildBoomRankList = {}
    for k,v in pairs(guildBoomRank) do
        local iData = {}
        iData.guildName = v.name
        iData.guildBoom = v.incBoom
        iData.guildId = v.guildId
        table.insert(self.guildBoomRankList, iData)
    end

    self.myBoomRankInfo = {}
    self.myBoomRankInfo.rank = data.myGuildRank or 0
    self.myBoomRankInfo.boom = data.incBoom or 0
    
    TFDirector:dispatchGlobalEventWith(FactionFightManager.updateRankSuccess)
    hideLoading()
end

function FactionFightManager:getGuildBoomList()
    return self.guildBoomRankList
end

function FactionFightManager:getMyGuildBoomRank()
    return self.myBoomRankInfo
end


--进入帮派对战 或者 对战信息界面
function FactionFightManager:enterFightMessage()
    self:requestWarInfos()
end

function FactionFightManager:showRuleLayer()
    CommonManager:showRuleLyaer( 'bangpaizhan' )
end

function FactionFightManager:showAwardLayer()
    local layer = require("lua.logic.factionfight.FactionFightReward"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show()
end

function FactionFightManager:getWinnerInfo()
    return self.lastWinnerInfo
end

function FactionFightManager:getMyGuildFightRank()
    return self.lastWinnerInfo.myRank or 0
end
--[[
    帮派战冠军结果展示
]]
function FactionFightManager:requestWinnerResult()
    showLoading()
    TFDirector:send(c2s.QUERY_GUILD_BATTLE_LAST_WINER,{})
end

function FactionFightManager:onWinnerResult(event)

    print('onWinnerResult = ',event.data)
    self.lastWinnerInfo = {}
    self.lastWinnerInfo.maxGuildLevel = event.data.maxGuildLevel
    self.lastWinnerInfo.guildSize = event.data.guildSize
    self.lastWinnerInfo.openTime = event.data.openTime
    self.lastWinnerInfo.guildId = event.data.guildId or 0
    self.lastWinnerInfo.guildName = event.data.guildName
    self.lastWinnerInfo.bannerId = event.data.bannerId
    self.lastWinnerInfo.professions = event.data.professions
    self.lastWinnerInfo.myRank = event.data.myRank or 0
    self.lastWinnerInfo.names = string.split(event.data.names, ",") 

    TFDirector:dispatchGlobalEventWith(FactionFightManager.winnerInfoUpdate)
    hideLoading()
end

--[[
    获取本帮派的成员报名信息
]]
function FactionFightManager:requestGuildMember()
    showLoading()
    TFDirector:send(c2s.QUERY_GUILD_BATTLE_MEMBER_INFO,{})
end

function FactionFightManager:onGuildMemberReceive( event )
    
    for i=1,3 do
        self.guildMemberList[i] = {}
        self.guildLeaderList[i] = {}
        local info = event.data.infos[i] or {}
        local memberInfo = info.battleInfo or {}
        for k,v in pairs(memberInfo) do
            if v.playerId ~= 0 then
                local data = {}
                data.playerId = v.playerId
                data.profession = v.profession
                data.playerName = v.name
                data.power = v.power
                data.headPicFrame = v.headPicFrame
                table.insert(self.guildMemberList[i], data)
                if v.playerId == info.eliteId then
                    self.guildLeaderList[i].playerId = v.playerId
                    self.guildLeaderList[i].profession = v.profession
                    self.guildLeaderList[i].playerName = v.name
                    self.guildLeaderList[i].power = v.power
                    self.guildLeaderList[i].headPicFrame = v.headPicFrame
                end
            end
        end
    end

    TFDirector:dispatchGlobalEventWith(FactionFightManager.guildMemberUpdate)
    hideLoading()
end

--[[
    修改精英成员
]]
function FactionFightManager:requestUpdateLeader(index, playerId)
    if self:CheckInSignUpTime() == false then
        toastMessage(TFLanguageManager:getString(ErrorCodeData.Guild_War_War_star))
    else
        showLoading()
        TFDirector:send(c2s.UPDATE_ELITE_GUILD_BATTLE,{index, playerId})
    end
end

function FactionFightManager:onUpdateLeaderReceive( event )
    if event.data.sucess then
        --修改精英成功
    else
        --修改精英失败
        if self:CheckInSignUpTime() == false then
            toastMessage(TFLanguageManager:getString(ErrorCodeData.Guild_War_War_star))
        else
    		toastMessage(TFLanguageManager:getString(ErrorCodeData.Guild_War_No_Elite))
        end
    end
    hideLoading()
    self:requestGuildMember()
end

--[[
    报名
]]
function FactionFightManager:requestSignUp(index)
    self.requestSignUpIndex = index + 1
    local memberdata = self:getMemberDataByIndex(self.requestSignUpIndex) or {}
    if self:CheckInSignUpTime() == false then
        toastMessage(TFLanguageManager:getString(ErrorCodeData.Guild_War_War_star))
    elseif #memberdata >= 10 then
        toastMessage(TFLanguageManager:getString(ErrorCodeData.Guild_War_No_Position))
    else
        showLoading()
        TFDirector:send(c2s.APPLY_GUILD_BATTLE,{index})
    end
end

function FactionFightManager:CheckInSignUpTime()

    local desTime = ConstantData:objectByID("Gangwar.Qualifier.Over").value + ConstantData:objectByID("Gangwar.Signup.Over").value
    local date = os.date("*t", MainPlayer:getNowtime())
    if date.wday == 1 then
        date.wday = 8
    end
    local wday = date.wday - 2        
    local nowTime = wday*(24*60*60) + (date.hour*60 + date.min)*60 + date.sec

    if nowTime >= desTime then
        return false
    end
    return true
end

function FactionFightManager:onRequestSignUpReceive( event )

    if event.data.sucess then
        --报名成功
    else
        --报名失败
        local memberdata = self:getMemberDataByIndex(self.requestSignUpIndex) or {}
        if self:CheckInSignUpTime() == false then
            toastMessage(TFLanguageManager:getString(ErrorCodeData.Guild_War_War_star))
        elseif #memberdata >= 10 then
            toastMessage(TFLanguageManager:getString(ErrorCodeData.Guild_War_No_Position))
        end
    end
    hideLoading()
    self:requestGuildMember()
end

--[[
    取消报名
]]
function FactionFightManager:requestCancelSignUp()

    if self:CheckInSignUpTime() == false then
        toastMessage(TFLanguageManager:getString(ErrorCodeData.Guild_War_War_star))
    else
       showLoading()
        TFDirector:send(c2s.UNAPPLY_GUILD_BATTLE,{}) 
    end

    
end

function FactionFightManager:onRequestCancelSignUpReceive( event )

    if event.data.sucess then
        --报名成功
    else
        --报名失败
        -- if self:CheckInSignUpTime() == false then
        --     toastMessage(TFLanguageManager:getString(ErrorCodeData.Guild_War_War_star))
        -- else
        --     toastMessage(TFLanguageManager:getString(ErrorCodeData.Guild_War_No_Elite))
        -- end
    end
    hideLoading()
    self:requestGuildMember()
end

-- 工会对战信息
function FactionFightManager:requestWarInfos()
    showLoading()
    TFDirector:send(c2s.QUERY_GUILD_BATTLE_WAR_INFOS, { })
end

function FactionFightManager:onRequestWarInfos(event)
    -- print(event.data.infos)
    --self.warInfos = { }
    --self.warInfos = event.data.infos
    hideLoading()
    if event.data.infos == nil then
        -- print('没有帮派战斗信息')
        --toastMessage(TFLanguageManager:getString(ErrorCodeData.Guild_War_No_Videotape))
	toastMessage(localizable.Guild_War_No_Videotape)
        return 
    end
    self.warInfos = {}
    for k,v in pairs(event.data.infos) do
        if k < 5 then
           self.warInfos[k] ={} 
        end    
        if v.round == 1 then
            table.insert(self.warInfos[1],v)
        elseif v.round ==2 then
            table.insert(self.warInfos[2],v)
        elseif v.round == 3 then
            table.insert(self.warInfos[3],v)           
        elseif v.round ==4 then
            table.insert(self.warInfos[4],v)
        end    
    end

   if self.warInfos  then
        local layer = require("lua.logic.factionfight.FactionFightMessage"):new()
        layer:initData()
        AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
        AlertManager:show()
    end

    --TFDirector:dispatchGlobalEventWith(FactionFightManager.requesWarInfosSuccess)
    
end

function FactionFightManager:getWarInfos()
    return self.warInfos;
end

-- 录像信息
-- c2s.QUERY_GUILD_BATTLE_REPLAY_INFOS
function FactionFightManager:requireRePlayeInfos(round, index)
    showLoading()
    self.round = round or 0
    self.index = index or 0
    self.requireRePlayeInfosRound = round or 0
    TFDirector:send(c2s.QUERY_GUILD_BATTLE_REPLAY_INFOS, { round, index })
end

function FactionFightManager:onReplayInfosCallBack(event)
    self.replayInfos = event.data

    self:resetFightRecordInfo(event.data)

    if self.requireRePlayeInfosRound and self.requireRePlayeInfosRound ~= 0 then
        local layer = require("lua.logic.factionfight.FactionRecordNew"):new()
        layer:setFightRound(self.requireRePlayeInfosRound)
        AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
        AlertManager:show()
    end


    -- self.atkInfos = {}
    -- self.defInfos = {}
    -- self.replays = { }  

    -- for i = 1 ,#self.replayInfos.atkGuildTeamInfos  do
    --     if i < 4 then
    --         table.insert(self.atkInfos,self.replayInfos.atkGuildTeamInfos[i])
    --     else
    --         table.insert(self.defInfos,self.replayInfos.atkGuildTeamInfos[i])
    --     end
    -- end    
    
    -- self.replays = self.replayInfos.replays or {}
    -- self.replays_teams ={}
    -- for i=1,3 do
    --     self.replays_teams[i] ={}        
    -- end

    -- for i = 1, #self.replays do
    --     if self.replays[i].team == 0 then
    --         table.insert(self.replays_teams[1], self.replays[i])
    --     elseif self.replays[i].team == 1 then
    --         table.insert(self.replays_teams[2], self.replays[i])
    --     elseif self.replays[i].team == 2 then
    --         table.insert(self.replays_teams[3], self.replays[i])
    --     end
    -- end

    -- TFDirector:dispatchGlobalEventWith(FactionFightManager.onReplayInfosSuccess)
    hideLoading()
end

function FactionFightManager:resetFightRecordInfo(eventData)

    print('eventDataeventDataeventData = ',eventData)
    
    local memberInfo = eventData.atkGuildTeamInfos or {}
    self.atkMemberInfo = {}
    self.defMemberInfo = {}
    for i=1,6 do
        local data = memberInfo[i] or {}
        local member = data.battleInfo or {}
        if i <= 3 then
            self.atkMemberInfo[i] = {}
        else
            self.defMemberInfo[i-3] = {}
        end

        for k,v in pairs(member) do
            if v.playerId ~= 0 then
                local details = {}
                details = clone(v)
                details.isLeader = false
                if (data.eliteId and data.eliteId ~= 0) and (data.eliteId == v.playerId) then
                    details.isLeader = true
                end

                if i <= 3 then
                    -- if details.isLeader then
                        -- table.insert(self.atkMemberInfo[i], 1, details)
                    -- else    
                        table.insert(self.atkMemberInfo[i], details)
                    -- end
                else
                    -- if details.isLeader then
                    --     table.insert(self.defMemberInfo[i-3], 1, details)
                    -- else    
                        table.insert(self.defMemberInfo[i-3], details)
                    -- end
                end
            end
        end
    end

    local fightInfo = eventData.replays or {}
    self.fightDetailInfo = {}
    for i=1,3 do
        self.fightDetailInfo[i] = {}
    end
    for k,v in pairs(fightInfo) do
        local teamIndex = v.team + 1
        -- print('teamIndex = ',teamIndex)
        local addIndex = #self.fightDetailInfo[teamIndex] + 1
        self.fightDetailInfo[teamIndex][addIndex] = {}
        self.fightDetailInfo[teamIndex][addIndex] = clone(v)
    end
    local function sortBySence(v1,v2)
        return v1.scene < v2.scene
    end
    for i=1,3 do
        table.sort(self.fightDetailInfo[i], sortBySence)
    end
end


--[[@return
    team 当前小队  
]]
function FactionFightManager:getCurrTeam()
    local teamRound = 1
    local teamTime = 0 
    if self:getActivityState() == 3 then
        local timeCount = self:getFightTime()
        local roundTime =  ConstantData:objectByID("Gangwar.Team.Time").value
        local lefttime = timeCount - (self.round - 1) * roundTime --当前这轮 剩余时间

        local teamTime = ConstantData:objectByID("Gangwar.Personal.Time").value --小队时间

        local count = #self.replayInfos.replays --总的场次

        local number1 =  #self.replays_team_1
        local number2 =  #self.replays_team_2
        local number3 =  #self.replays_team_3

        if lefttime > count * teamTime then
            teamRound = 4
        elseif lefttime > (number1 + number2) * teamTime then
            teamRound = 3
            teamTime = lefttime - (number1 + number2) * teamTime
        elseif lefttime > (number1) * teamTime then
            teamRound = 2
            teamTime = lefttime - (number1) * teamTime
        else
            teamRound = 1
            teamTime = lefttime
        end
   end
   return teamRound , teamTime
end

--不需要计算时间
--[[@reutrn
   录像信息
   攻击方信息
   防守方信息
]]

function FactionFightManager:getCurrReplayTeamInfo(teamIndex,teams)
    local tempTeams ={}
    if teamIndex > #teams then
        return tempTeams
    else     
        for i=1,teamIndex do
            table.insert(tempTeams,teams[i])
        end
    end
    return tempTeams
end

--[[
    新添加
]]
function FactionFightManager:getTeamInfoByIndex( teamIndex )
    return self.fightDetailInfo[teamIndex]
end

function FactionFightManager:getDefMemberInfo(teamIndex)
    return self.defMemberInfo[teamIndex]
end

function FactionFightManager:getAtkMemberInfo(teamIndex)
    return self.atkMemberInfo[teamIndex]
end


function FactionFightManager:setCurrFightStartTime( round )
    local desTime = ConstantData:objectByID("Gangwar.Qualifier.Over").value + ConstantData:objectByID("Gangwar.Signup.Over").value
    desTime = desTime + ConstantData:objectByID("Gangwar.Warstart.Over").value
    -- local desTime = 20*60*60 + 40*60
    self.startFightTime = desTime + (round - 1)*60*60
end

function FactionFightManager:getCurrScene(nowTime)
    -- 获取本次对战进行的战斗次数
    --返回当前正在战斗 第几场
    --返回 cutTime剩下倒计时
    local sec = ConstantData:objectByID("Gangwar.Personal.Time").value
    local count = math.ceil((nowTime - self.startFightTime)/sec)
    local cutTime = sec - (nowTime - self.startFightTime)%sec
    if cutTime == sec then
        count = count + 1
    end
    return count,cutTime
end

function FactionFightManager:getStateByTeamIndex(teamIndex)

    -- 根据teamIndex判断这个小队的战斗状态
    
    local isEnd = false
    local currFightIndex

    local date = os.date("*t", MainPlayer:getNowtime())
    if date.wday == 1 then
        date.wday = 8
    end
    local wday = date.wday - 2
    
    local nowTime = wday*(24*60*60) + (date.hour*60 + date.min)*60 + date.sec
    local count,cutTime = self:getCurrScene(nowTime)
    if self.activityState == self.ActivityState_2 then
        count = 0
    elseif self.activityState ~= self.ActivityState_3 then
        count = 11000
    end
    -- print('count = ',count)
    -- print('cutTime = ',cutTime)

    local totalFight = 0

    for i=1,teamIndex do
        totalFight = totalFight + #self.fightDetailInfo[i]
    end

    if count > totalFight then
        isEnd = true
        currFightIndex = #self.fightDetailInfo[teamIndex]
    else
        isEnd = false
        totalFight = 0
        for i=1,teamIndex-1 do
            totalFight = totalFight + #self.fightDetailInfo[i]
        end
        if count > totalFight then
            currFightIndex = count - totalFight
        else
            --这场的战斗还未开始
            currFightIndex = 0
        end
    end

    return isEnd,currFightIndex,cutTime
end

function FactionFightManager:setGuildDataInfo(atkInfo, defInfo)
    -- atkInfo = {}
    -- atkInfo.bannerId = "1_1_1_1"
    -- atkInfo.name = "一一一"

    -- defInfo = {}
    -- defInfo.bannerId = "1_1_1_1"
    -- defInfo.name = "二二二"
    -- print("atkInfo = ",atkInfo)
    -- print("defInfo = ",defInfo)
    self.atkGuildInfo = atkInfo
    self.defGuildInfo = defInfo
end

function FactionFightManager:getGuildDataInfo()
    --[[
        atkGuildInfo
        --bannerId
        --name
    ]]
    return self.atkGuildInfo,self.defGuildInfo
end

function FactionFightManager:checkInReadyTime()

    local date = os.date("*t", MainPlayer:getNowtime())
    if date.wday == 1 then
        date.wday = 8
    end
    local wday = date.wday - 2
    
    local nowTime = wday*(24*60*60) + (date.hour*60 + date.min)*60 + date.sec
    local readyTime = ConstantData:objectByID("Gangwar.Qualifier.Start").value

    if nowTime >= readyTime then
        return true
    end
    return false
end
return FactionFightManager:new()