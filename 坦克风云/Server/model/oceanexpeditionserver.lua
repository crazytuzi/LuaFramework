--[[
    远洋征战
    元帅带领舰队进行征战
]]

local consts = {
    WIN=1, -- 胜者标识
    LOSE=2,    -- 败者标识
    MARSHAL_TEAM=0, -- 元帅组
}

local oceanExpCfg = getConfig("oceanExpedition")

-- 做完了才说取分数又要按开服数来弄,为了改动最小,拿个变量记系统能提供的总分数
local sysTotalPointCfg

-- 属性继承配置
local attrInheritCfg = {
    {"dmg","attack"},
    {"maxhp","life"},
    {"accuracy","accurate"},
    {"evade","avoid"},
    {"crit","critical"},
    {"anticrit","decritical"},
}

local attr2cfg = {
    dmg="attack",
    maxhp="life",
}

-- 这儿直接用了世界大战的数据库配置，省得再加一份要维护
local function DB()
    return getCrossDbo("worldwarserver")
end

-- 记录器
local Recorder = {}

function Recorder:new (group)
    local o = {
        server={},
        formation={},
        battleIdx={},
        tid2Pos={},
        group=group,
        boss=0,
    }
    return setmetatable(o,{__index = self})
end

function Recorder:setFormation(zid,formation)
    zid = tostring(zid)
    self.formation[zid] = formation
    self.tid2Pos[zid] = {}

    for i=2,#self.formation[zid] do
        local tid = tostring(self.formation[zid][i])
        self.tid2Pos[zid][tid] = tostring(i-1) 
    end
end

-- function Recorder:setTeamNum(zid,tid,num)
--     zid = tostring(zid)
--     if not self.server[zid] then
--         self.server[zid] = {}
--     end

--     self.server[zid][tid] = num
-- end

function Recorder:setTeamNum(zid,num)
    self.server[tostring(zid)] = num
end

-- 如果最终由双方BOSS的战斗来决定胜负时，需要记录胜利方BOSS的服ID
function Recorder:setZidOfBoss(zid)
    self.boss = zid
end

-- 记录战斗中的回合信息
function Recorder:setBattleIdx(cycle,zid,tid,memberNum)
    if not self.battleIdx[cycle] then
        self.battleIdx[cycle] = {}
    end
    
    zid = tostring(zid)
    tid = tostring(tid)
    local pos = self.tid2Pos[zid][tid]
    if not self.battleIdx[cycle][zid] then
        self.battleIdx[cycle][zid] = {}
    end

    self.battleIdx[cycle][zid][pos] = memberNum
end

-- 获胜的军团id
function Recorder:setBoss(zid)
    self.boss = zid
end

function Recorder:getContent()
    local content = json.encode{
        server=self.server,
        formation=self.formation,
        battleIdx=self.battleIdx,
        group=self.group,
    }
    return content
end

-- r2 表示日志类型
function Recorder:save(bid,round)
    local db = DB()
    local report = self:getContent()
    for zid in pairs(self.server) do
        local bkey = string.format("r2-%s-%s-%s",tostring(bid),tostring(round+1),tostring(zid))
        db:insert("oceanexp_teamlog",{
            bkey = bkey,
            report = report,
            updated_at = os.time(),
        })
    end
end

------------------------------ 
-- 队伍相关
------------------------------
local Team = {
    name = "", 
    marshalObj = {},  -- 元帅
    captainObj = {},  -- 队长
    membersData = {},    -- 成员数据
}

function Team:new (tid,marshalObj,morale,zid)
    local o = {
         -- marshalId = marshalId or 0,
         -- captainId = captainId or 0,
         zid = zid or 0,
         members = {},
         tid = tid or -1,
         marshalObj = marshalObj or {},
         captainObj = captainObj or {},
         formation = {},
         fIndex = 0,
         morale = morale or 0,
         point = 0, -- 胜利点数
         flag={1,1,1,1}, -- 队伍旗帜
         report = {},
    }

    return setmetatable(o,{__index = self})
end

function Team:show()
    local s = {
        "team:" .. tostring(self.tid),
        "marshal:".. (self.marshalObj.show and self.marshalObj:show() or "nil"),
        "captain:".. (self.captainObj.show and self.captainObj:show() or "nil"),
    }

    return table.concat(s,", ")
end

function Team:getName()
    return "team_".. tostring(self.tid)
end

function Team:getId()
    return self.tid
end

-- 是否队长
function Team:isCaptain(uid)
    if self.tid ~= consts.MARSHAL_TEAM then 
        return self.captainObj.uid == uid
    end
    return false
end

function Team:getCaptain()
    if self.captainObj.uid then
        return self.captainObj
    end
end

function Team:getMarshal()
    if self.marshalObj.uid then
        return self.marshalObj
    end
end

-- 是否元帅
function Team:isMarshal(uid)
    return self.marshalObj.uid == uid
end

function Team:setCaptain(captainObj)
    self.captainObj = captainObj
end

function Team:getMarshalId()
    if self.marshalId > 0 then
        return self.marshalId
    end
end

function Team:addMember(memberObj)
    table.insert(self.members,memberObj)
    memberObj:setTeam(self)
end

function Team:setFormation(formation,index)
    self.formation = {formation,index}
end

function Team:setFlag(flags)
    local tid = self.tid + 1
    if flags[tid] and next(flags[tid]) then
        self.flag = flags[tid]
    end
end

function Team:getMembers()
    return self.members
end

function Team:countMembers()
    return #self.members
end

-- 默认胜利
function Team:defaultVictory()
    for k,v in pairs(self.members) do
        v:defaultWin()
    end

    self:win()
end

-- 对位战斗双方均为队伍时，对战获胜后得1分；有元帅参与的对战获胜后得2分；6场战斗后分数较高的一方获胜
function Team:win()
    local point = self.tid == consts.MARSHAL_TEAM and 2 or 1
    self.point = self.point + point
    table.insert(self.report, {self.tid,consts.WIN,point,self.flag})
end

function Team:lose()
    table.insert(self.report, {self.tid,consts.LOSE,0,self.flag})
end

function Team:getPoint()
    return self.point
end

-- 获取战斗报告
function Team:getBattleReport()
    if not next(self.report) then
        return {{self.tid,consts.LOSE,0,self.flag}}
    end

    return self.report
end

--[[
    计算玩家队伍中的玩家最终获得的积分
    所有成员按自己获得的积分占总积分的比例分享系统总分
]]
function Team:calcMembersScore(isWin)
    local totalPoint = 0
    for k,v in pairs(self.members) do
        totalPoint = totalPoint+v:getRoundPoint()
    end

    -- 可分配的系统总分与胜负有关
    local sysTotalPoint = sysTotalPointCfg or oceanExpCfg.total[8]
    if isWin then
        sysTotalPoint = sysTotalPoint * oceanExpCfg.winValue
    else
        sysTotalPoint = sysTotalPoint * oceanExpCfg.loseValue
    end

    -- 为本队所有成员加分
    if totalPoint > 0 then
        for k,v in pairs(self.members) do
            local rate = v:getRoundPoint()/totalPoint
            if rate > 1 then rate = 1 end
            v:addPoint(math.floor( sysTotalPoint * rate))
        end
    end
end

-- 创建战斗小队
function Team:createFightingTeam()
    local team = {}
    for k,v in pairs(self.members) do
        -- 重新进入战斗小队，清除掉阵亡标记(元帅有可能打二次,在前面的战斗中有可能战败)
        v.defeated = false
        table.insert(team,v)
    end
    return team
end

-- 移除失败的成员
function Team:removeDefeatedMember(fightingTeam)
    for i=#fightingTeam,1,-1 do
        if fightingTeam[i].defeated then
            table.remove(fightingTeam,i)
        end
    end
end

function Team:saveBattleReport(cycle,report)
    report.cycle = cycle
    DB():insert("oceanexp_battlelog",report)
end

function Team:attack(targetTeamObj,recorderObj)
    local selfMembers = self:createFightingTeam()
    local targetMembers = targetTeamObj:createFightingTeam()

    local sn = #selfMembers
    local tn = #targetMembers
    local maxRound = sn > tn and sn or tn

    -- 只是为了保险防止无限循环
    for i=1,maxRound do
        local cycle = i


        -- print("ready go go go",i)
        -- for k,v in pairs(selfMembers) do
        --     print(k,v.zid,v.uid)
        -- end

        -- for k,v in pairs(targetMembers) do
        --     print(k,v.zid,v.uid)
        -- end
        -- print("ready go go go",i)




        for k,attacker in pairs(selfMembers) do
            local defender = targetMembers[k]
            if defender then

                -- TEST
                -- print(string.format("ATTACK: %s => %s",attacker:show1(),defender:show1()))
                local report,battleLog, aAliveTroops, dAliveTroops, attSeq, setPoint,aDieTroops,dDieTroops = attacker:attack(defender)

                self:saveBattleReport(cycle,battleLog)
                -- TEST TODO 
                -- if k%2 == 0 then report.r = 0 end

                if not report then
                    attacker:singleBye()
                    defender:singleBye()
                elseif report.r == 1 then
                    attacker:win()
                    defender:lose()
                else
                    defender:win()
                    attacker:lose()
                end

                -- ptb:p(report);os.exit();
            else
                -- 单场轮空
                attacker:singleBye()
            end
        end

        for j=#selfMembers+1,#targetMembers do
            if targetMembers[j] then
                targetMembers[j]:singleBye()
            end
        end

        self:removeDefeatedMember(selfMembers)
        self:removeDefeatedMember(targetMembers)

        sn = #selfMembers
        tn = #targetMembers

        if recorderObj then
            recorderObj:setBattleIdx(cycle,self.zid,self.tid,sn)
            recorderObj:setBattleIdx(cycle,targetTeamObj.zid,targetTeamObj.tid,tn)
        end

        -- 战斗结束
        if sn == 0 or tn == 0 then
            if sn > 0 then
                self:win()
                targetTeamObj:lose()
            else
                targetTeamObj:win()
                self:lose()
            end

            break
        end
    end

end

-- local team1 = Team:new(1,2)
-- local team2 = Team:new(3,4)

-- print("The user（2） is Captain:",team1:isCaptain(2))
-- print("The user（3） is Captain:",team2:isCaptain(4))

-- team1:addMemberData(11)
-- team2:addMemberData(22)

-- team2.membersData[1] = 55

-- ptb:p(team1.membersData)
-- ptb:p(team2.membersData)

------------------------------ 
-- 舰队相关
------------------------------
local Fleet = {}

function Fleet:new (id,zid,log,marshalObj,formation)
    local o = {
        id = id or 0,
        zid = zid or 0,
        marshalObj = marshalObj or {},  -- 元帅
        teams = {}, -- 舰队中的队伍
        status = 0, -- 1是胜利,2是失败
        pos = 0,
        formation=formation,
        log = log or {},
    }

    return setmetatable(o,{__index = self})
end

function Fleet:show()
    local fleetInfo = string.format(
        "\nFLEET:z%d-%s",
        self.zid,
        self.marshalObj.show and self.marshalObj:show() or ""
    )

    local s = {fleetInfo}
    for k,v in pairs(self.teams) do
        table.insert(s,v:show())
    end
    return table.concat(s,"\n")
end

function Fleet:addTeam(teamObj)
    table.insert(self.teams,teamObj)
end

function Fleet:getTeams()
    return self.teams
end

-- 获取舰队的战力
function Fleet:getFc()
    local fc = 0
    for _,teamObj in pairs(self.teams) do
        for _,memberObj in pairs(teamObj:getMembers()) do
            fc = fc + memberObj.fc 
        end
    end
    return fc
end

-- 元帅组
function Fleet:getMarshalTeam()
    for k,v in pairs(self.teams) do
        if v:getId() == consts.MARSHAL_TEAM then
            return v
        end
    end
end

function Fleet:getTeamsMemberNum()
    local tb = {}
    for i=1,oceanExpCfg.teamNum do
        tb[i] = self.teams[i] and self.teams[i]:countMembers() or 0
    end
    return tb
end

-- 舰队
function Fleet:attack(targetFleetObj,recorderObj)
    local targetTeams = targetFleetObj:getTeams()
    
    recorderObj:setFormation(self.zid,self.formation)
    recorderObj:setFormation(targetFleetObj.zid,targetFleetObj.formation)
    recorderObj:setTeamNum(self.zid,self:getTeamsMemberNum())
    recorderObj:setTeamNum(targetFleetObj.zid,targetFleetObj:getTeamsMemberNum())

    -- 我方队伍数与目标方队伍数
    local sn = #self.teams
    local tn = #targetTeams

    for k,v in pairs(self.teams) do
        if targetTeams[k] then
            v:attack(targetTeams[k],recorderObj)
        else
            v:defaultVictory()
        end
    end

    -- 我方队伍数不足,目标方队伍要默认胜利
    if tn > sn then
        for i=sn+1,tn do
            targetTeams[i]:defaultVictory()
        end
    end
end

function Fleet:getBattlePoint()
    local point = 0
    for k,v in pairs(self.teams) do
        point = point + v:getPoint()
    end
    return point
end

-- 默认胜利
function Fleet:defaultVictory(defaultReport)
    for k,v in pairs(self.teams) do
        v:defaultVictory()
    end

    self:win()
end

function Fleet:win(targetFleetObj)
    self.status = consts.WIN
    table.insert(self.log,{self.pos,consts.WIN})
end

function Fleet:lose(targetFleetObj)
    self.status = consts.LOSE
    table.insert(self.log,{self.pos,consts.LOSE})
end

-- 设置本次战斗所在的位置(组)
function Fleet:setPos(pos)
    self.pos = pos
end

function Fleet:getBattleReport()
    local trace = {}
    for k,v in pairs(self.teams) do
        table.insert(trace,v:getBattleReport())
    end

    return trace
end

function Fleet:save()
    -- print(string.format("%s,status:%s,pos:%s,log:%s",self.id,self.status,self.pos,json.encode(self.log)))
    DB():update("oceanexp_team",{
        id = self.id,
        log = json.encode(self.log),
        status = self.status,
        pos = self.pos,
        updated_at = os.time(),
    },{"id"})

    -- print(DB():getQueryString())

    for _,teamObj in pairs(self.teams) do
        teamObj:calcMembersScore(self.status == consts.WIN)
        for _,memberObj in pairs(teamObj:getMembers()) do
            memberObj:save()
        end
    end
end


------------------------------ 
-- 成员相关
------------------------------
local Member = {}

function Member:new (o,round)
    o = o or {}
    o.teamObj = {}
    o.defeated = false
    o.winCount = 0
    o.rPoint = 0 -- 战斗获得的分数
    o.point = tonumber(o.point)
    o.zid = tonumber(o.zid)
    o.uid = tonumber(o.uid)
    o.log = json.decode(o.log) or {}
    o.round = tonumber(round)
    o.fc = tonumber(o.fc)
    o.level = tonumber(o.level)
    o.job = tonumber(o.job)
    o.leftTroops = nil -- 战斗中剩余部队信息
    o.attackTroops = nil -- 格式化好的所有属性加成完毕的作战部队数据
    return setmetatable(o,{__index = self})
end

function Member:show()
    return string.format("member(%d-%d)",self.zid,self.uid)
end

function Member:show1()
    return string.format("%s,member(%d-%d)",self.teamObj:show(), self.zid,self.uid)
end

function Member:setTeam(teamObj)
    self.teamObj = teamObj
end

function Member:isMarshal()
    return self.teamObj:isMarshal(self.uid)
end

function Member:isCaptain()
    return self.teamObj:isCaptain(self.uid)
end

-- 获取属性加成值
function Member:getAttrAddVal()
    if type(self.battr) ~= "table" then
        local battr = json.decode(self.battr) or {}
        self.battr = {}
        for k,v in pairs(attrInheritCfg) do
            self.battr[v[1]] = battr[k] or 0
        end
    end

    return self.battr
end

-- 小场战斗胜利
function Member:win()
    self.rPoint = self.rPoint + oceanExpCfg.singleWinP
    self.winCount = self.winCount + 1

    -- print(string.format("team:%s,victory:%s,isMarshal:%s,isCaptain:%s",self.teamObj:getName(),self:show(),self:isMarshal(),self:isCaptain()))
end

-- 小场战斗失败
function Member:lose()
    self.defeated = true
    self.rPoint = self.rPoint + oceanExpCfg.singleLoseP

    -- print(string.format("team:%s,defeated:%s,isMarshal:%s,isCaptain:%s",self.teamObj:getName(),self:show(),self:isMarshal(),self:isCaptain()))
end

-- 获取玩家本回合获得的积分
function Member:getRoundPoint()
    -- 元帅和小队长有加成
    if self:isMarshal() or self:isCaptain() then
        return self.rPoint * oceanExpCfg.tlAddValue
    end

    return self.rPoint
end

-- 添加积分
-- 添加的积分在log里做记录
function Member:addPoint(point)
    self.point = self.point + point
    table.insert(self.log,{point,self.rPoint})
end

-- 默认胜利，并给轮空分
function Member:defaultWin(defaultReport)
    self.rPoint = self.rPoint + oceanExpCfg.singleByeP
    if defaultReport then
        -- TODO 生成一个说明战报(运营开服了，但是没有一个人)
    end
end

-- 对战轮空
-- 轮空时会给玩家轮空积分
function Member:singleBye()
    self.rPoint = self.rPoint + oceanExpCfg.singleByeP
end

-- 获取玩家的士气
function Member:getMorale()
    return tonumber(self.teamObj.morale) or 0
end

-- 获取玩家的阵型
function Member:getFormation()
    if self.teamObj.formation then
        return self.teamObj.formation[1], self.teamObj.formation[2]
    end
end

-- 从格式化的部队数据中获取设置的部队数据{{'a10001',5},{'a10002',5},}
-- 存的数据是属性加成算好的，需要换成动画能播的格式
local function getTroopsByInitTroopsInfo(initTroopsInfo)
    local troops = {}
    local totalnum = 0

    for k,v in pairs(initTroopsInfo) do
        if (tonumber(v.num) or 0) > 0 then
            table.insert(troops,{v.id,v.num})
            totalnum = totalnum + v.num
        else
            table.insert(troops,{})
        end
    end

    if totalnum <= 0 then
        troops = {}
    end

    return troops
end

-- 从战斗后的部队数据中获取胜余的坦克数量
-- return table, table
local function getDieTroopsByInavlidFleet(fleetinfo,invalidFleet)
    local troops = {}

    for k,v in pairs(fleetinfo) do
        if (v[2] or 0) > 0 then
            local dienum = v[2] - (invalidFleet[k] and invalidFleet[k][2] or 0)

            if dienum > 0 then
                troops[v[1]] = (troops[v[1]] or 0) + dienum
            end
        end
    end

    return troops
end

--[[
    生成战报的唯一key
    只要发生战斗后就会淘汰掉其中一个，因此使用双方的服id和队伍id可以生成一个唯一的战报key

    param wZid 进攻方服id
    param lZid 防守方服id
    param wTid 进攻方队伍id
    param lTid 防守方队伍id
]]
local function makeZKey(wZid,lZid,wTid,lTid)
    local tb = {wZid,lZid}
    local tb1 = {wTid,lTid}
    table.sort(tb)
    table.sort(tb1)
    return table.concat(tb, "-") .. "-" .. table.concat(tb1, "-")
end

local function mInfo2log(battleLog,memberObj,isWin)
    if isWin then
        battleLog.winnerId = memberObj.uid
        battleLog.wNickname = memberObj.nickname
        battleLog.wPic = memberObj.pic
        battleLog.wbPic = memberObj.bpic
        battleLog.waPic = memberObj.apic
        battleLog.wZid = memberObj.zid
        battleLog.wtid = memberObj.teamObj:getId()
    else
        battleLog.loserId = memberObj.uid
        battleLog.lNickname = memberObj.nickname
        battleLog.lPic = memberObj.pic
        battleLog.lbPic = memberObj.bpic
        battleLog.laPic = memberObj.apic
        battleLog.lZid = memberObj.zid
        battleLog.ltid = memberObj.teamObj:getId()
    end
end

-- 攻击
function Member:attack(targetObj)
    local aFleetInfo,fleetInfo1 = self:getTroops()
    local defFleetInfo,fleetInfo2 = targetObj:getTroops()

    if not aFleetInfo or not defFleetInfo then
        return false
    end

    local aTroops = getTroopsByInitTroopsInfo(aFleetInfo)
    local dTroops = getTroopsByInitTroopsInfo(defFleetInfo)

    require "lib.battle"

    local report, aInvalidFleet, dInvalidFleet, attSeq, seqPoint = {}
    report.d, report.r, aInvalidFleet, dInvalidFleet, attSeq, seqPoint = battle(aFleetInfo,defFleetInfo)

    local aAliveTroops = getTroopsByInitTroopsInfo(aInvalidFleet)
    local dAliveTroops = getTroopsByInitTroopsInfo(dInvalidFleet)

    report.p = {{targetObj.nickname,targetObj.level,0,seqPoint[2]},{self.nickname,self.level,1,seqPoint[1]}}

    if attSeq == 1 then
        report.p[1][3] = 1
        report.p[2][3] = 0                               
    end

    report.t = {dTroops,aTroops}
    report.h = {{},{}}

    if fleetInfo1[3] and fleetInfo1[3][1] then
        report.h[2] = fleetInfo1[3][1]
    end

    if fleetInfo2[3] and fleetInfo2[3][1] then
        report.h[1] = fleetInfo2[3][1]
    end

    report.se={0, 0}
    if fleetInfo1[4] then
        report.se[2] = fleetInfo1[4] --a
    end    
    if fleetInfo2[4] then
        report.se[1] = fleetInfo2[4] -- d
    end

    self:setLeftTroops(aAliveTroops)
    targetObj:setLeftTroops(dAliveTroops)

    -- 战报
    local battleLog = {
        brkey = string.format("%s-%d",self.bid,self.round+1),
        cycle=cycle,
        report = json.encode(report),
        zkey = makeZKey(self.zid,targetObj.zid,self.teamObj:getId(),targetObj.teamObj:getId()),
        updated_at = os.time(),
    }

    if report.r == 1  then
        mInfo2log(battleLog,self,true)
        mInfo2log(battleLog,targetObj,false)
    else
        mInfo2log(battleLog,self,false)
        mInfo2log(battleLog,targetObj,true)
    end
    
    return report, battleLog
end

function Member:setLeftTroops(troops)
    self.leftTroops = troops
end

local function calcAttrTool(attrVal,addVal)
    for k,v in pairs(attrInheritCfg) do
        if addVal[v[1]] and v[1] ~= "maxhp" and v[1] ~= "dmg" then
            attrVal[v[1]] = (attrVal[v[1]] or 0) + addVal[v[1]]
        end
    end
end

-- 格式化部队（处理成能战斗的格式，保存的时候是简化了的数据）
-- TODO 把初始化好的属性先存起来,连续作战的时候用，作战失败的时候清除掉即可
function Member:getTroops()
    if type(self.binfo) == "string" then
        self.binfo = json.decode(self.binfo)
    end

    local attTroops

    if self.attackTroops then
        attTroops = copyTable(self.attackTroops)
    elseif type(self.binfo) == "table" then

        local buffAdd = 1

        local captainObj = self.teamObj:getCaptain()
        local marshalObj = self.teamObj:getMarshal()

        local captainAttrAdd = captainObj and captainObj:getAttrAddVal()
        local marshalAttrAdd = marshalObj and marshalObj:getAttrAddVal()
        local selfAttrAdd = self:getAttrAddVal()


-- TEST
-- local testFunc = function ( a )
--     local b = {}
--     for k,v in pairs(attrInheritCfg) do
--         b[v[1]] = a[k]
--     end
--     return b
-- end
-- local selfAttrAdd = testFunc( {18.31501832,1.4652,3,2.7,3,3} )
-- local selfAttrAdd = testFunc{18.31501832,1.831501832,3,2.7,3,3}
-- local selfAttrAdd = testFunc{18.31501832,1.831501832}
-- local marshalAttrAdd = testFunc({10.98901099,1.098901099,1.8,1.62,1.8,1.8})
-- local captainAttrAdd = testFunc{5.494505495,0.43956044,0.9,0.81,0.9,0.9}
-- marshalAttrAdd = nil
-- captainAttrAdd = nil


        local attrAddVal = {}
        -- 血量和攻击需要特殊计算
        local specialAttr = {"dmg","maxhp"}

        if self:isCaptain() then
            -- 小队长BUFF
            for k,v in pairs(specialAttr) do
                if selfAttrAdd[v] then
                    attrAddVal[v] = selfAttrAdd[v] * oceanExpCfg.tlAdd
                end

                -- 继承元帅的属性
                if marshalAttrAdd and marshalAttrAdd[v] then
                    attrAddVal[v] = attrAddVal[v] + marshalAttrAdd[v]
                end
            end

            if marshalAttrAdd then
                calcAttrTool(attrAddVal,marshalAttrAdd)
            end

            buffAdd = oceanExpCfg.tlAdd
            
            -- print("-----------元帅加成11mmp————————————add",self.uid)

        elseif self:isMarshal() then
            for k,v in pairs(specialAttr) do
                if selfAttrAdd[v] then
                    attrAddVal[v] = selfAttrAdd[v] * oceanExpCfg.marAdd
                end
            end

            buffAdd = oceanExpCfg.marAdd


            -- print("-----------元帅加成22mmp————————————add",self.uid)

        else
            for k,v in pairs(specialAttr) do
                if not attrAddVal[v] then
                    attrAddVal[v] = selfAttrAdd[v] or 0
                end

                if captainAttrAdd and captainAttrAdd[v] then
                    attrAddVal[v] = attrAddVal[v] + captainAttrAdd[v]
                end

                -- 继承元帅的属性
                if marshalAttrAdd and marshalAttrAdd[v] then
                    attrAddVal[v] = attrAddVal[v] + marshalAttrAdd[v]
                end
            end

            -- 继承小队长的属性
            if captainAttrAdd then
                calcAttrTool(attrAddVal,captainAttrAdd)

                -- print("-----------队长光环33————————————add",self.uid)
                -- ptb:p(attrAddVal)

            end
            
            -- 继承元帅的属性
            if marshalAttrAdd then
                calcAttrTool(attrAddVal,marshalAttrAdd)

                -- print("-----------元帅光环33————————————add",self.uid,marshalObj.uid)
                -- ptb:p(attrAddVal)

            end
        end

        attTroops = {}
        for m,n in pairs(self.binfo[2][1]) do
            attTroops[m] = {}
            if n[1] then
                for k,v in pairs(self.binfo[1]) do
                    attTroops[m][v] = n[k]
                end
            end
        end

-- TEST
-- attTroops[1].dmg = 10000
-- attTroops[1].maxhp = 10000
-- attTroops[1].accuracy = 3
-- attTroops[1].crit = 3
-- attTroops[1].anticrit = 3
-- attTroops[1].evade = 3
-- attTroops[1].id = "a10073"

-- -- TEST
-- for k,v in pairs(attrInheritCfg) do
--     print(v[1],attTroops[1][v[1]])
-- end

-- print("--------ff-------")

        -- 职位与额外继承的属性
        local tankCfg = getConfig("tank")
        for _,troop in pairs(attTroops) do
            if next(troop) then
                for _,v in pairs(attrInheritCfg) do
                    local attr = v[1]
                    if troop[attr] and attrAddVal[attr] then
                        if attr == "maxhp" or attr == "dmg" then
                            if tankCfg[troop.id] and tankCfg[troop.id][attr2cfg[attr]] then
                                -- 攻击与伤害计算加成时需要用原始配置里的值来进行计算
                                troop[attr] = math.floor(tankCfg[troop.id][attr2cfg[attr]] * attrAddVal[attr] * oceanExpCfg.alienValue)
                                -- 重算总血量
                                troop.hp = troop.maxhp * troop.num
                            end
                        else
                            troop[attr] = troop[attr] * buffAdd + attrAddVal[attr]
                        end
                    end
                end
            end
        end

-- -- TEST
-- for k,v in pairs(attrInheritCfg) do
--     print(v[1],attTroops[1][v[1]])
-- end

-- os.exit()

        local morale = self:getMorale()
        local moraleAttrCfg = oceanExpCfg.morale.moralereward.morAtt[morale]
        local moraleFirst = oceanExpCfg.morale.moralereward.first[morale] or 0
        if moraleAttrCfg then
            for _,troop in pairs(attTroops) do
                if next(troop) then
                    -- 历史遗留问题,先手值不能重复加,这里加完直接置0
                    troop.first = (troop.first or 0) + moraleFirst
                    moraleFirst = 0

                    -- arp
                    if troop[moraleAttrCfg[1][1]] then
                        troop[moraleAttrCfg[1][1]] = troop[moraleAttrCfg[1][1]] + moraleAttrCfg[1][2]
                    end
                    
                    -- armor
                    if troop[moraleAttrCfg[2][1]] then
                        troop[moraleAttrCfg[2][1]] = troop[moraleAttrCfg[2][1]] + moraleAttrCfg[2][2]
                    end
                end
            end
        end

        -- 处理阵型属性加成
        -- 队伍在不同位置,加成的效果不同
        local formation,fIndex = self:getFormation()
        if formation and oceanExpCfg.formation[formation] and oceanExpCfg.formation[formation][fIndex] then
            local attr = oceanExpCfg.formation[formation][fIndex].att[1]
            local value = oceanExpCfg.formation[formation][fIndex].value[1]
            for _,troop in pairs(attTroops) do
                if next(troop) then
                    if attr == "dmg_reduce" then
                        troop[attr] = (troop[attr] or 1) * (1/(1+value))
                    else
                        troop[attr] = math.floor(troop[attr] + troop[attr] * value)
                    end
                end
            end
        end

        -- 连续发生多次战斗,属性算好后存起来
        self.attackTroops = copyTable(attTroops)
    end

    if attTroops then
        -- 剩余部队
        if self.leftTroops then
            for k,v in ipairs(self.leftTroops) do
                if not next(v) or (v[2] or 0) <= 0 then
                    attTroops[k] = {}
                else
                    attTroops[k].num = v[2]
                end
            end
        end

        -- 连续作战减免
        if self.winCount > 0 then
            local deRate = oceanExpCfg.fatigueBuff ^ self.winCount
            for _,v in pairs(attrInheritCfg) do
                local attr = v[1]
                for _,troop in pairs(attTroops) do
                    if troop[attr] then troop[attr] = troop[attr] * deRate end
                end
            end
        end

        -- 重新计算总血量
        for k,v in pairs(attTroops) do
            if v.hp then v.hp = math.floor(v.maxhp * v.num) end
        end
    end

    return  attTroops, self.binfo 
end

function Member:save()
    -- 1统帅 2队长 3成员
    local job = self.job
    if self:isMarshal() then
        job = 1
    elseif self:isCaptain() then
        job = 2
    else
        job = 3
    end

    DB():update("oceanexp_members",{
        id = self.id,
        round = self.round + 1,
        log = json.encode(self.log),
        point = self.point,
        job = job,
        feat = self.feat + self:getRoundPoint(),
        updated_at = os.time(),
    },{"id"})

    -- print(DB():getQueryString())
end

------------------------------ 
-- 战场相关
------------------------------

local OceanExpedition = {
    
} 

-- 考虑开错了的情况
function OceanExpedition:createMatch(bid,st,et,servers,zoneId,fc)
    local bidData = self:getBidDataFromDb(bid)
    local teamsData = self:getAllTeamsDataFromDb(bid)
    
    local zid2team = {}
    for k,v in pairs(teamsData) do
        zid2team[tonumber(v.zid)] = true
    end

    local zid2server = {}
    for k,v in pairs(servers) do
        zid2server[v] = true
    end

    local db = DB()
    db.conn:setautocommit(false)

    local newBidData = {
        bid=bid,
        st=st,
        et=et,
        servers=servers,
    }

    if not bidData then
        self:setBidData(newBidData)
    else
        self:updateBidData(newBidData)
    end

    fc = tonumber(fc) or 0

    -- 新增加的服
    for _,zid in pairs(servers) do
        if not zid2team[zid] then
            local teamData = {
                bid=bid,
                zid=zid,
            }

            if fc > 0 and tonumber(zid) == tonumber(zoneId) then
                teamData.fc = fc
            end

            self:addTeamDataToDb(teamData)
        end
    end

    if fc > 0 and zid2team[zoneId] then
        self:updateTeamData(bid,zoneId,{bid=bid,zid=zoneId,fc = fc})
    end

    -- 开错了,要删除的
    for zid in pairs(zid2team) do
        if not zid2server[zid] then
            self:deleteTeamDataFromDb(bid,zid)
        end
    end
    
    if db.conn:commit() then
        return true
    end
end

--[[
    增加一条跨服区域战的信息
    数据是从报名表中的数据提取出来的
]]
function OceanExpedition:setBidData(bidData)
    bidData.updated_at = os.time()
    return DB():insert("oceanexp_bid",bidData)
end

function OceanExpedition:updateBidData(bidData)
    bidData.updated_at = os.time()
    return DB():update("oceanexp_bid",bidData,{"bid"})
end

function OceanExpedition:getBidDataFromDb(bid)
    local sql = "select bid,round,servers from oceanexp_bid where bid=:bid limit 1"
    local data = DB():getRow(sql,{bid=bid})
    if type(data) == "table" then
        data.round = tonumber(data.round)
        data.servers = json.decode(data.servers) or {}
    end
    return data
end

-- TODO st,et is test
function OceanExpedition:getAllBidDataFromDb()
    local sql = "select bid,round,servers,st,et from oceanexp_bid where st <= :ts and et > :ts"
    local data = DB():getAllRows(sql,{ts=os.time(),status=consts.LOSE})
    for k,v in pairs(data) do
        v.round = tonumber(v.round)
        v.servers = json.decode(v.servers) or {}
    end
    return data
end

function OceanExpedition:setMatchRound(bid,round)
    DB():update("oceanexp_bid",{bid=bid,round=round,updated_at=os.time()},{"bid"})
end

local function transformTeamDbData(data)
    for k,v in pairs(data) do
        v.zid = tonumber(v.zid)
        v.fc = tonumber(v.fc)
        v.pos = tonumber(v.pos)
        v.status = tonumber(v.status)
        v.morale = tonumber(v.morale)
        v.formation = json.decode(v.formation)
        v.servers = json.decode(v.servers)
        v.log = json.decode(v.log) or {}
        v.flag = json.decode(v.flag) or {1,1,1,1}

        if type(v.formation) ~= "table" or not next(v.formation) then
            v.formation = {1,0,1,2,3,4,5}
        end

        for i=0,5 do
            local team = "team"..i
            v[team] = json.decode(v[team])
        end
    end
end

-- 添加队伍数据
function OceanExpedition:addTeamDataToDb(data)
    data.log = nil
    data.status = nil
    data.pos = nil
    data.updated_at = os.time()

    return DB():insert("oceanexp_team",data)
end

-- 添加队伍数据
function OceanExpedition:deleteTeamDataFromDb(bid,zid)
    local db = DB()
    local sql = string.format("delete from oceanexp_team where bid='%s' and zid=%d",db:escape(bid),db:escape(zid))
    return db:query(sql)
end

-- 修改队伍数据
-- 与战斗逻辑相关的数据不能在这里修改
function OceanExpedition:updateTeamData(bid,zid,data)
    data.log = nil
    data.status = nil
    data.pos = nil
    data.updated_at = os.time()

    local db = DB()
    local ret, err = db:update("oceanexp_team",data,{"bid","zid"})
    if not ret or ret <= 0 then
        ret = false
        err = db:getError()
    end

    return ret, err
end

-- 获取队伍的数据
function OceanExpedition:getTeamDataFromDb(bid,zid)
    local sql = "select * from oceanexp_team where bid=:bid and zid = :zid"
    local data = DB():getRow(sql,{bid=bid,zid=zid}) 
    transformTeamDbData(data)
    return data
end

-- 获取胜利队伍的数据
function OceanExpedition:getWinningTeamsDataFromDb(bid)
    local sql = "select * from oceanexp_team where bid=:bid and status = :status"
    local data = DB():getAllRows(sql,{bid=bid,status=consts.WIN}) 
    transformTeamDbData(data)
    return data
end

function OceanExpedition:getAllTeamsDataFromDb(bid)
    local sql = "select * from oceanexp_team where bid=:bid"
    local data = DB():getAllRows(sql,{bid=bid}) 
    transformTeamDbData(data)
    return data
end

-- -- 按bid分组
-- function OceanExpedition:groupBidData(data)
--     local gdata = {}
--     for k,v in pairs(data) do
--         if not gdata[v.bid] then
--             gdata[v.bid] = {}
--         end

--         v.zid = tonumber(v.zid)
--         v.formation = json.decode(v.formation)
--         v.servers = json.decode(v.servers)
--         v.log = json.decode(v.log)

--         for i=1,6 do
--             local team = "team"..i
--             v[team] = json.decode(v[team])
--         end
        
--         table.insert(gdata[v.bid],v)
--     end

--     return gdata
-- end

--[[
    binfo 详细部队数据
    battr 部队属性加成信息
]]
function OceanExpedition:getMembersDataFromDb(bid,round)
    local sql = string.format("select id,bid,uid,zid,binfo,point,feat,log,nickname,pic,bpic,apic,battr,fc,level,job from oceanexp_members where bid = '%s' and round <= '%d'",bid,round)
    return DB():getAllRows(sql)
end

function OceanExpedition:getMemberDataFromDb(bid,uid)
    local sql = string.format("select id,uid,log from oceanexp_members where bid = '%s' and uid = '%d'",bid,uid)
    return DB():getRow(sql)
end

local memberFields = {
    "bid","uid","nickname","fc","pic","bpic",
    "apic","level","fc","job","zid","binfo","battr",
}

-- 添加队伍数据
function OceanExpedition:addMemberDataToDb(bid,data)
    local member = {}
    for k,v in pairs(memberFields) do
        member[v] = data[v]
    end

    member.updated_at = os.time()
    return DB():insert("oceanexp_members",member)
end

-- 修改队伍数据
-- 与战斗逻辑相关的数据不能在这里修改
function OceanExpedition:updateMemberData(bid,uid,data)
    local member = {}
    for k,v in pairs(memberFields) do
        member[v] = data[v]
    end

    member.updated_at = os.time()

    local db = DB()
    local ret, err = db:update("oceanexp_members",member,{"uid","bid"})
    if not ret or ret <= 0 then
        ret = false
        err = db:getError()
    end

    return ret, err
end

-- local function getBattleRoundTs(st)
--     st = getWeeTs(st)
--     local oceanExpCfg = oceanExpCfg
--     local baseinfo = {
--         -- [1] = 0, -- 参赛报名/元帅选拔
--         -- [2] = 0, -- 队长选拔
--         -- [3] = 0, -- 队伍调整
--         -- [4] = 0, -- 比赛期
--         -- [5] = 0, -- 领奖期
--     }

--     baseinfo[1] = {st + (oceanExpCfg.marTime-1) * 86400, st + oceanExpCfg.marTime * 86400 - oceanExpCfg.diffTime * 60}
--     baseinfo[2] = {st + (oceanExpCfg.tlTime-1) * 86400, st + oceanExpCfg.tlTime * 86400 - oceanExpCfg.diffTime * 60}
--     baseinfo[3] = {st + (oceanExpCfg.tpTime-1) * 86400, st + oceanExpCfg.tpTime * 86400 - oceanExpCfg.diffTime * 60}

--     -- 战斗期
--     baseinfo[4] = {
--         {   
--             st + (oceanExpCfg.matchTime1-1) * 86400 + oceanExpCfg.matchTime[1][1]*3600 + oceanExpCfg.matchTime[1][2]*60,
--             st + (oceanExpCfg.matchTime1-1) * 86400 + oceanExpCfg.matchTime[2][1]*3600 + oceanExpCfg.matchTime[2][2]*60
--         },
--         {   
--             st + (oceanExpCfg.matchTime2-1) * 86400 + oceanExpCfg.matchTime[1][1]*3600 + oceanExpCfg.matchTime[1][2]*60,
--             st + (oceanExpCfg.matchTime2-1) * 86400 + oceanExpCfg.matchTime[2][1]*3600 + oceanExpCfg.matchTime[2][2]*60
--         },
--         {   
--             st + (oceanExpCfg.matchTime3-1) * 86400 + oceanExpCfg.matchTime[1][1]*3600 + oceanExpCfg.matchTime[1][2]*60,
--             st + (oceanExpCfg.matchTime3-1) * 86400 + oceanExpCfg.matchTime[2][1]*3600 + oceanExpCfg.matchTime[2][2]*60
--         },
--     }

--     baseinfo[5] = {baseinfo[4][#baseinfo[4]][2] + 1800,st + (oceanExpCfg.rewardTime+1) * 86400}

--     return baseinfo
-- end

-- 按时间获取当前的轮数
function OceanExpedition:getCurrentRound(st,servers,ts,isClient)
    local round = 0
    local ts = ts or os.time()
    st = getWeeTs(st)

    -- 获取最大场次
    local maxRound = OceanExpedition:getMaxRoundByServers(servers)
    -- 提前时间(要比客户端时间早一点算，客户端才能及时拿到结果)
    local advanceTs = 0
    if not isClient then
        advanceTs = 600
    end

    -- 第一场战斗起始时间
    -- local battleSt = st + (oceanExpCfg.matchTime1-1) * 86400 + oceanExpCfg.matchTime[1][1]*3600 + oceanExpCfg.matchTime[1][2]*60
    local battleSt = st + oceanExpCfg.matchTime[1][1]*3600 + oceanExpCfg.matchTime[1][2]*60 - advanceTs

    for i=1,maxRound do
        local t1 = battleSt + (i-1) * 86400
        local t2 = battleSt + i * 86400

        -- 只要过了最后一场的起始时间都算为最后一场,直接在当前时间上加了一天
        if i == maxRound then
            t2 = ts + 86400
        end

        -- print(battleSt,os.date('%Y%m%d %H:%M:%S',t1),os.date('%Y%m%d %H:%M:%S',t2),os.date('%Y%m%d %H:%M:%S',ts))

        if ts >= t1 and ts < t2 then
            round = i
            break
        end
    end

    return round
end

-- TODO 要处理一下元帅组没有小队长
-- memberObjs分配到队列后会被清掉
function OceanExpedition:createTeam(teamId,teamInfo,marshalObj,memberObjs,morale,zid)
    local teamObj = Team:new(teamId,marshalObj,morale,zid)
    local captainObj = teamInfo[1] and memberObjs[teamInfo[1]]

    -- 必需有小队长
    if captainObj and type(teamInfo[2]) == "table" then
        teamObj:setCaptain(captainObj)
        for _,uid in pairs(teamInfo[2]) do
            if memberObjs[uid] then
                teamObj:addMember(memberObjs[uid])
                memberObjs[uid] = nil
            end
        end
    end

    return teamObj
end

-- 获取元帅数据
function OceanExpedition:getMarshalObj(bidData,memberObjs)
    local marshalTeam = "team" .. consts.MARSHAL_TEAM -- 元帅所在组
    if bidData[marshalTeam] and bidData[marshalTeam][1] then
        return memberObjs[bidData[marshalTeam][1]]
    end
end

-- 检测阵型信息
function OceanExpedition:checkFormation(formationInfo)
    if not oceanExpCfg.formation[formationInfo[1]] then
        return false
    end

    local teamList = {}
    for i=2,oceanExpCfg.teamNum+1 do
        if teamList[formationInfo[i]] or not formationInfo[i] then
            return false
        end
        teamList[formationInfo[i]] = true
    end

    for i=0,oceanExpCfg.teamNum-1 do
        if not teamList[i] then
            return false
        end
    end

    return true
end

-- formationInfo 第1位是阵型id,后边是队伍出阵的顺序表
function OceanExpedition:getFormationAndTeamList(formationInfo)
    -- 没有设置阵型时给一个默认值1
    local formationId = formationInfo[1] or 1

    -- 从第2位开始是出阵顺序表
    local teamList = {}
    for i=2,oceanExpCfg.teamNum+1 do
        table.insert(teamList,formationInfo[i])
    end

    -- 默认出阵顺序
    if not next(teamList) then
        -- 客户端提前定好了,队伍id为0-5,所以这里是0至oceanExpCfg.teamNum-1
        for i=0,oceanExpCfg.teamNum-1 do
            table.insert(teamList,i)
        end
    end

    return formationId, teamList
end

-- 创建舰队
-- TODO 处理没有队伍的member数据
function OceanExpedition:createFleet(bid,teamsData,round)
    local fleets = {}

    local membersData = self:getMembersDataFromDb(bid,round)

    local memberObjs = {}
    if next(membersData) then
        for k,v in pairs(membersData) do
            memberObjs[tonumber(v.uid)] = Member:new(v,round)
        end
    end

    local teamObjs = {}
    
    -- TODO 读配置
    local teamNum = oceanExpCfg.teamNum

    for k,v in pairs(teamsData) do
        local marshalObj = self:getMarshalObj(v,memberObjs)
        local fleetObj = Fleet:new(v.id,v.zid,v.log,marshalObj,v.formation)

        -- 阵形与队伍出战顺序
        local formation,teamList = self:getFormationAndTeamList(v.formation)

        -- 创建队伍后,memberObjs将不可用
        for i=0,teamNum-1 do
            local t = "team"..i
            teamObjs[i] = self:createTeam(i,v[t],marshalObj,memberObjs,v.morale,v.zid)
        end

        -- TODO 如果有memberObjs 没有被分配完，并且队伍都没有满,需要系统来分配到队伍
        -- members

        for idx,teamId in pairs(teamList) do
            local teamObj = teamObjs[teamId]
            if teamObj then
                teamObj:setFormation(formation,idx)
                teamObj:setFlag(v.flag)
                fleetObj:addTeam(teamObj)
                teamObjs[teamId] = nil
            end
        end

        fleets[tonumber(v.zid)] = fleetObj
    end

    return fleets
end

-- 获取比赛规模
local function getMatchScale(servers)
    local scale
    local serverNum = #servers
    if serverNum < 1 then return scale end

    local matchList = oceanExpCfg.matchList
    if matchList[serverNum] then
        scale = serverNum
    else
        local keys = table.keys(matchList)
        table.sort(keys)
        for k,v in pairs(keys) do
            if serverNum < v then
                scale = v
                break
            end
        end
    end

    sysTotalPointCfg = oceanExpCfg.total[scale]
    return scale
end

-- 获取比赛需要进行的最大轮数
function OceanExpedition:getMaxRoundByServers(servers)
    local round = 0
    local scale = getMatchScale(servers)
    if scale then
        round = math.floor(math.log(scale,2))
    end
    return round
end

-- 首场对阵列表
function OceanExpedition:firstBattleList( servers, data)
    local battleList = {}

    if type(data) == "table" then
        local scale = getMatchScale(servers)
        if scale then
            local matchList = oceanExpCfg.matchList
            local cfg = matchList[scale]
            
            table.sort(data,function ( a,b )
                return tonumber(a.fc) > tonumber(b.fc) 
            end)

            for k,v in pairs(cfg) do
                if not battleList[k] then battleList[k] = {} end
                -- table.insert(battleList[k],data[v[1]] and tonumber(data[v[1]].zid) or servers[v[1]] or 0)
                -- table.insert(battleList[k],data[v[2]] and tonumber(data[v[2]].zid) or servers[v[2]] or 0)

                if data[v[1]] and #(data[v[1]].log) == 0 then
                    table.insert(battleList[k],tonumber(data[v[1]].zid))
                else
                    table.insert(battleList[k],0)
                end

                if data[v[2]] and #(data[v[2]].log) == 0 then
                    table.insert(battleList[k],tonumber(data[v[2]].zid))
                else
                    table.insert(battleList[k],0)
                end
            end
        end
    end

    return battleList
end

-- 对阵列表
function OceanExpedition:mkMatchList(round,servers,data)
    local battleList = {}

    -- 第一场由配置决定
    if round == 0 then
        battleList = self:firstBattleList(servers,data)
    else
        for k,v in pairs(data) do
            if v.status == consts.WIN and v.pos > 0 then
                local pos = math.ceil(v.pos / 2)
                if not battleList[pos] then
                    battleList[pos] = {}
                end

                table.insert(battleList[pos],v.zid)
            end
        end
    end

    return battleList
end

-- 设置舰队战斗的详细信息
-- 记录双方舰队中各队伍的战斗情况
function OceanExpedition:setFleetBattleReport(fleet1,fleet2,bid,pos,round)
    if fleet1 or fleet2 then
        -- 双方战斗信息
        local report1 = {}
        local report2 = {}

        local zoneInfo = {0,0} -- 双方服信息
        local statusInfo = {0,0} -- 战斗胜负状态信息

        if fleet1 then
            zoneInfo[1] = fleet1.zid
            statusInfo[1] = fleet1.status
            report1 = fleet1:getBattleReport()
        end

        if fleet2 then
            zoneInfo[2] = fleet2.zid
            statusInfo[2] = fleet2.status
            report2 = fleet2:getBattleReport()
        end

        -- 存放队伍日志
        local teamLog = {}

        -- 比分一样的时候，双方元帅队会在最后额外进行一轮战斗
        local marshalTeamLog = {}

        for i=1,oceanExpCfg.teamNum do
            teamLog[i] = {{}, {}}

            if report1[i] then
                teamLog[i][1] = report1[i][1]

                -- 第二场战斗一定是元帅队
                if report1[i][2] then
                    marshalTeamLog[1] = report1[i][2]
                end
            end

            if report2[i] then
                teamLog[i][2] = report2[i][1]
                if report2[i][2] then
                    marshalTeamLog[2] = report2[i][2]
                end
            end
        end

        -- 如果元帅队有额外进行战斗,将此记录追加到最后
        if next(marshalTeamLog) then
            table.insert(teamLog,marshalTeamLog)
        end

        local bkey = string.format("r1-%s-%s-%s",tostring(bid),tostring(round+1),tostring(pos))

        DB():insert("oceanexp_teamlog",{
            bkey = bkey,
            report = {zoneInfo,teamLog,statusInfo},
            updated_at = os.time(),
        })
    end
end

--[[
    小组内的战斗

    不正常的情况
        a.如果对阵到了空服(运营少开服了),默认我方全体成员进行了一场战斗,并胜利,无战报
        b.如果对阵到的服没有人(该服无人报名),默认我方全体成员进行了一场战斗,并胜利,但需要有战报说明

    正常情况双方都有人,如果对阵的服报名人数不够,我方成员则可能不发生战斗,此时没有功绩也没有战报
]]
function OceanExpedition:battle(fleet1,fleet2,zid1,zid2,pos,round,bid)
    if fleet1 then fleet1:setPos(pos) end
    if fleet2 then fleet2:setPos(pos) end

    -- 只有一支舰队有数据
    if fleet1 and not fleet2 then
        fleet1:defaultVictory(zid2 ~= 0)

    -- 只有一支舰队有数据
    elseif not fleet1 and fleet2 then
        fleet2:defaultVictory(zid1 ~= 0)

    elseif fleet1 and fleet2 then
        -- print(fleet1:show(),fleet2:show())
        local recorderObj = Recorder:new(pos)
        fleet1:attack(fleet2,recorderObj)

        local point1 = fleet1:getBattlePoint()
        local point2 = fleet2:getBattlePoint()

        -- 分数一样时,双方元帅需要再对阵一场
        if point1 == point2 then
            local marshalTeam1 = fleet1:getMarshalTeam()
            local mrashalteam2 = fleet2:getMarshalTeam()

            if marshalTeam1 and mrashalteam2 then
                marshalTeam1:attack(mrashalteam2)
            elseif marshalTeam1 then
                marshalTeam1:win()
            elseif marshalTeam2 then
                marshalTeam2:win()
            end

            point1 = fleet1:getBattlePoint()
            point2 = fleet2:getBattlePoint()
        end

        -- 分一样时,战力值高的胜利
        local winFlag
        if point1 > point2 then
            winFlag = true
        elseif point1 == point2 then
            winFlag = fleet1:getFc() > fleet2:getFc()
        end

        if winFlag then
            fleet1:win(); 
            fleet2:lose()
            recorderObj:setBoss(fleet1.zid)
        else
            fleet1:lose(); 
            fleet2:win()
            recorderObj:setBoss(fleet2.zid)
        end

        recorderObj:save(bid,round)
    end

    -- 设置舰队战斗报告
    self:setFleetBattleReport(fleet1,fleet2,bid,pos,round)

    -- 保存数据

    -- TEST
    if fleet1 then fleet1:save() end
    if fleet2 then fleet2:save() end

end



return OceanExpedition
