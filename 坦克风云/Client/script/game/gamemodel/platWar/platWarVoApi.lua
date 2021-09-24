--跨平台战的voapi
platWarVoApi =
{
    warID = nil, --跨平台战id
    platList = nil, --参与跨服战的平台列表
    playerList = nil, --参赛选手的列表
    selfPlayer = nil, --如果玩家自己是参赛选手之一的话，这个就是玩家自己的platWarPlayerVo
    startTime = nil, --开始时间
    endTime = nil, --结束时间
    warInfoExpireTime = 0, --初始化信息过期时间
    battleExpireTime = 0, --战场信息过期时间
    cityList = nil, --所有据点的信息,{{1:platWarCityVo,62:platWarCityVo},{1:platWarCityVo,62:platWarCityVo},{1:platWarCityVo,62:platWarCityVo}}
    moraleList = nil, --一个table, 里面存的数字是双方的士气数目,{100,200}
    buffList = nil, --购买buff的信息
    troopList = nil, --每条路上的部队数, {{1,2,3,4,5},{20,10,20,30,50}},两个table分别表示双方的部队，第几个元素就是第几条路上一共有几支部队
    troopDetailList = nil, --每条路上的前几名部队详细信息,eg:[[[["3-Highs",[["a10027",250],["a10027",682],["a10027",412],{},["a10027",677],["a10027",625]],6],0,0,0,0,0,0,0,0,0,0,0,0],[["3-Gigi",[["a10044",938],["a10044",938],["a10044",938],["a10044",938],["a10044",938],["a10044",938]],0],0,0,0,0,0]],[[0,0,0,0,0,0,0,0,0,0],{}],[[0,0,0,0,0,0,0,0,0,0],{}],[[0,0,0,0,0,0,0,0,0,0],{}],[[0,0,0,0,0,0,0,0,0,0],{}]]
    lineList = nil, --每条路线双方部队到达的点数,{{3,600},{4,345}},每个元素代表一条路，每个元素里面的两个数字分别表示红蓝双方在这条路上到哪里了
    -- landtype={},--战斗地形
    commonList = nil, --道具列表
    rareList = nil, --珍品列表
    troopInfo = nil, --玩家自己的几支部队选择的路线和到达的位置,每个元素代表一支部队，第一个元素表示走的哪条路，第二个元素表示走到哪了,第三个元素是一个数字表示第几个回合复活,{{1,24,120},{1,25,0},{2,126,131}}
    point = 0, --商店积分
    donatePoint = 0, --捐献获得的商店积分
    pointDetail = {}, --积分明细
    detailExpireTime = 0, --积分明细过期时间
    curRound = 0, --当前战斗进行到第几轮了
    nextBattleTime = 0, --下场战斗的时间戳
    winnerID = nil, --获胜的平台ID
    
    lastDonateTime = 0, --上一次捐献士气的时间
    -- curMorale=0, --当前士气
    donateTroops = {}, --捐献的坦克信息
    donateTroopsNum = {0, 0, 0}, --捐献的坦克次数
    eventList = {}, --战斗事件
    eventTotalNum = 0, --战斗事件总数量
    eventHasMore = false, --战斗事件是否有更多
    
    rankList = {{}, {}}, --排行榜
    rankExpireTime = {0, 0}, --排行榜过期时间，1战斗积分，2捐献积分
    myRank = {0, 0}, --我的排行，{战斗排行，捐献排行}
    myPoint = {0, 0}, --我的积分，{战斗积分，捐献积分}
    hasRewardRank = {}, --是否已经领取过排行榜奖励，{1,2},1：战斗，2：捐献

    lastSetLineTime = 0, --上次设置线路时间
    lastSetFleetTime = {0, 0, 0}, --上一次设置部队时间
    
    -- myRank=0,  --我的军团的排名
    -- isRewardRank=false,  --是否领取过排行奖励
    shopFlag = -1, --是否初始化商店数据,-1:未初始化，1:已经初始化
    pointDetailFlag = -1, --是否初始化积分明细,-1:未初始化，0:需要刷新面板，1:已经初始化
    -- rankFlag=-1,  --是否初始化排行榜数据,-1:未初始化，1:已经初始化
    troopsFlag = -1, --是否初始化部队数据,-1:未初始化，1:已经初始化
    
    reportList = {}, --战报数据
    reportNum = {}, --战报数量
    reportExpireTime = {0, 0}, --战报列表过期时间
    reportHasMore = {false, false}, --战报是否海域更多
    
    noticeList = {}, --留言板
    httphost = nil, --请求url
    noticeFlag = {-1, -1, -1},
    lastNoticeTime = {0, 0, 0}, --上一次获取留言板数据时间
}

--平台战ID
function platWarVoApi:getWarID()
    return self.warID
end
function platWarVoApi:setWarID(warID)
    self.warID = warID
end

function platWarVoApi:getWarInfoExpireTime()
    return self.warInfoExpireTime
end

function platWarVoApi:getBattleExpireTime()
    return self.battleExpireTime
end

--获取参加本次平台战的各个平台的ID和名字
--return 一个table, table的每个元素又是一个table B, table B的第一个元素是平台的ID, 第二个元素是平台的名称
function platWarVoApi:getPlatList()
    if(self.platList)then
        return self.platList
    else
        return {}
    end
end

--获取所有的参赛选手信息
--return 一个table, table里面的元素是platWarPlayerVo
function platWarVoApi:getPlayerList()
    if(self.playerList)then
        return self.playerList
    else
        return {}
    end
end

--获取玩家自己的平台ID
function platWarVoApi:getPlatID()
    return base.serverPlatID
end

--获取所有群众部队的列表
function platWarVoApi:getTroopList()
    if(self.troopList)then
        return self.troopList
    else
        return {{0, 0, 0, 0, 0}, {0, 0, 0, 0, 0}}
    end
end

--获取所有路线上的部队详情
function platWarVoApi:getTroopDetailList()
    return self.troopDetailList
end

--根据ID获取参赛选手的数据vo
function platWarVoApi:getPlayer(id)
    if(id == nil)then
        return self.selfPlayer
    end
    local tmp = Split(id)
    if(tmp)then
        local platID = tmp[1]
        if(platID and self.playerList[platID])then
            for k, v in pairs(self.playerList[platID]) do
                if(id == v.id)then
                    return v
                end
            end
        end
    end
    return nil
end

--获取所有城市的数据
function platWarVoApi:getCityList()
    if(self.cityList)then
        return self.cityList
    else
        return {}
    end
end

function platWarVoApi:getMoraleList()
    if(self.moraleList)then
        return self.moraleList
    else
        return {0, 0}
    end
end
function platWarVoApi:setMoraleList(moraleInfo)
    if(moraleInfo)then
        self.moraleList = {}
        for i = 1, 2 do
            if(moraleInfo[i])then
                self.moraleList[i] = tonumber(moraleInfo[i])
            else
                self.moraleList[i] = 0
            end
        end
    end
end

function platWarVoApi:getBuffList()
    if(self.buffList)then
        return self.buffList
    else
        return {}
    end
end

function platWarVoApi:getLineList()
    if(self.lineList)then
        return self.lineList
    else
        return {}
    end
end

function platWarVoApi:getTroopInfo()
    if(self.troopInfo)then
        return self.troopInfo
    else
        return {}
    end
end

--获取本次跨国战的获胜平台ID
function platWarVoApi:getWinnerID()
    return self.winnerID
end

--获取本次跨平台战进行到第几轮了
function platWarVoApi:getCurRound()
    return self.curRound
end

--弹出平台战主面板
--param layerNum: 面板所在的层级
function platWarVoApi:showMainDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/platWar/platWarDialog"
    local td = platWarDialog:new()
    local tbArr = {getlocal("plat_war_sub_title_1"), getlocal("plat_war_sub_title_2"), getlocal("plat_war_sub_title_3")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("plat_war_title"), true, layerNum + 1)
    sceneGame:addChild(dialog, layerNum + 1)
end
--弹出奖励面板
--param layerNum: 面板所在的层级
function platWarVoApi:showRewardDialog(layerNum, tabIndex)
    require "luascript/script/game/scene/gamedialog/platWar/platWarRewardDialog"
    local td = platWarRewardDialog:new()
    local tbArr = {getlocal("plat_war_reward_title_1"), getlocal("plat_war_reward_title_2"), getlocal("plat_war_reward_title_3")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("super_weapon_challenge_reward_preview"), true, layerNum + 1)
    sceneGame:addChild(dialog, layerNum + 1)
    if tabIndex == nil then
        tabIndex = 0
    end
    td:tabClick(tabIndex, false)
end
--弹出设置部队面板
function platWarVoApi:showTroopsDialog(layerNum)
    -- local function callback( ... )
    require "luascript/script/game/scene/gamedialog/platWar/platWarTroopsDialog"
    local td = platWarTroopsDialog:new()
    local tbArr = {getlocal("world_war_sub_title21"), getlocal("world_war_sub_title22"), getlocal("world_war_sub_title23"), getlocal("world_war_sub_title24")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("serverwar_troops"), true, layerNum + 1)
    sceneGame:addChild(dialog, layerNum + 1)
    -- end
    -- self:getInfo(callback)
end
--弹出战报面板
function platWarVoApi:showReportDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/platWar/platWarReportDialog"
    local td = platWarReportDialog:new()
    local tbArr = {getlocal("plat_war_main_event"), getlocal("plat_war_alliance_report"), getlocal("serverwarteam_person_report")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("allianceWar_battleReport"), true, layerNum + 1)
    sceneGame:addChild(dialog, layerNum + 1)
end
--弹出奖励详情面板,type:1.战斗排行，2.捐献排行
function platWarVoApi:showRewardDetailSmallDialog(type, layerNum)
    require "luascript/script/game/scene/gamedialog/platWar/rewardDetailSmallDialog"
    local smallDialog = rewardDetailSmallDialog:new()
    smallDialog:init(layerNum, type)
    return smallDialog
end
--index 第几支部队
function platWarVoApi:showSelectRoadSmallDialog(layerNum, index, callback)
    require "luascript/script/game/scene/gamedialog/platWar/platWarSelectRoadDialog"
    local sd = platWarSelectRoadDialog:new()
    sd:init(layerNum, index, callback)
end
--选择坦克面板
function platWarVoApi:showSelectTankDialog(layerNum, callBack, tankData, troopsLimit, index)
    require "luascript/script/game/scene/gamedialog/platWar/platWarSelectTankDialog"
    local function selectCallBack(id, num)
        if callBack then
            callBack(id, num)
        end
    end
    if tankData and tankData[1] and tankData[2] then
        platWarSelectTankDialog:showSelectTankDialog(nil, layerNum + 1, selectCallBack, tankData, troopsLimit, index)
    end
end

function platWarVoApi:showMap(layerNum)
    require "luascript/script/game/scene/gamedialog/platWar/platWarMapScene"
    platWarMapScene:show(layerNum)
end
--弹出帮助面板
function platWarVoApi:showHelpDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/platWar/platWarHelpDialog"
    local td = platWarHelpDialog:new()
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("help"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

function platWarVoApi:showPlayerListDialog(platID, layerNum)
    require "luascript/script/game/scene/gamedialog/platWar/platWarPlayerListDialog"
    local td = platWarPlayerListDialog:new(platID)
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("mainRank"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

function platWarVoApi:showBuyBuffDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/platWar/platWarBuffDialog"
    local td = platWarBuffDialog:new(platID)
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("alliance_skill"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

function platWarVoApi:showNoticeDialog(layerNum, parent)
    local tbArr = {getlocal("chat_world"), getlocal("plat_war_notice_camp"), getlocal("plat_war_notice_command")}
    local selfPlayer = platWarVoApi:getPlayer()
    if tonumber(playerVoApi:getUid()) == 1037662 and G_curPlatName() == "qihoo" then
    elseif(selfPlayer == nil or selfPlayer.rank > platWarCfg.joinLimit)then
        tbArr = {getlocal("chat_world"), getlocal("plat_war_notice_camp")}
    end
    require "luascript/script/game/scene/gamedialog/platWar/platWarNoticeDialog"
    require "luascript/script/game/scene/gamedialog/platWar/platWarNoticeDialogTab1"
    require "luascript/script/game/scene/gamedialog/platWar/platWarNoticeDialogTab2"
    require "luascript/script/game/scene/gamedialog/platWar/platWarNoticeDialogTab3"
    local td = platWarNoticeDialog:new(parent)
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("chat"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
    -- td:tabClick(1)
end

--获取平台战的整体信息
--param callback: 获取之后的回调函数
function platWarVoApi:getWarInfo(callback)
    require "luascript/script/game/gamemodel/platWar/platWarPlayerVo"
    require "luascript/script/game/gamemodel/platWar/platWarCityVo"
    if(base.serverTime >= self.warInfoExpireTime)then
        local function initHandler(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                self.startTime = tonumber(sData.data.st)
                self.endTime = tonumber(sData.data.et)
                base.serverPlatID = sData.data.plat
                if(sData.data.platlist)then
                    self.platList = {}
                    for k, v in pairs(sData.data.platlist) do
                        local platName = getlocal("plat_war_platName_"..v)
                        self.platList[k] = {v, platName}
                    end
                end
                if(sData.data.platinfo)then
                    local nameArr
                    if(base.serverPlatID == self.platList[1][1])then
                        nameArr = sData.data.platinfo[1]
                    else
                        nameArr = sData.data.platinfo[2]
                    end
                    for k, v in pairs(nameArr) do
                        self.platList[k][2] = v
                    end
                end
                if(sData.data.list)then
                    self.playerList = {}
                    for platID, platData in pairs(sData.data.list) do
                        self.playerList[platID] = {}
                        for rank, playerData in pairs(platData) do
                            local playerVo = platWarPlayerVo:new()
                            playerData.pid = platID
                            playerData.rank = rank
                            playerVo:init(playerData)
                            self.playerList[platID][rank] = playerVo
                            if(tonumber(playerVo.uid) == tonumber(playerVoApi:getUid()) and tonumber(playerVo.serverID) == tonumber(base.curZoneID) and playerVo.platID == base.serverPlatID)then
                                self.selfPlayer = playerVo
                            end
                        end
                    end
                end
                if(self.playerList == nil)then
                    self.playerList = {}
                    for k, v in pairs(self.platList) do
                        self.playerList[v[1]] = {}
                    end
                end
                if(base.serverTime > self.startTime and base.serverTime < self.endTime)then
                    if(buildings.allBuildings)then
                        for k, v in pairs(buildings.allBuildings) do
                            if(v:getType() == 16)then
                                v:setSpecialIconVisible(5, true)
                                break
                            end
                        end
                    end
                end
                if(sData.data.platwarserver or sData.data.userstats)then
                    self:formatBattleData(sData.data.platwarserver, sData.data.userstats)
                end
                local status = self:checkStatus()
                --为了防止后台还没计算完，所以给了10秒的延迟
                if(status == 0)then
                    if(base.serverTime < self.startTime)then
                        self.warInfoExpireTime = self.startTime + 10
                        self.battleExpireTime = self.startTime + 10
                    else
                        self.warInfoExpireTime = base.serverTime + 300
                        self.battleExpireTime = base.serverTime + 300
                    end
                else
                    self.warInfoExpireTime = self.endTime
                    if(status < 20)then
                        self.battleExpireTime = base.serverTime + 300
                    elseif(status < 30)then
                        self.battleExpireTime = base.serverTime - base.serverTime % platWarCfg.battleAttr.cdTime + platWarCfg.battleAttr.cdTime + 10
                    else
                        self.battleExpireTime = self.endTime
                    end
                end
                if sData.data.httphost then
                    self.httphost = sData.data.httphost
                end
                if(platWarCfg.platform[base.serverPlatID] == nil)then
                    platWarCfg.platform[base.serverPlatID] = {icon = "platIcon_1.png", donateNum = 1}
                end
                if sData.data.donateNum then
                    platWarCfg.platform[base.serverPlatID].icon = tostring(sData.data.donateNum.icon)
                    platWarCfg.platform[base.serverPlatID].donateNum = tonumber(sData.data.donateNum.donateNum)
                end
                if(callback)then
                    callback()
                end
            else
                self.warInfoExpireTime = base.serverTime + 300
            end
        end
        socketHelper:platWarInit(initHandler)
    elseif(callback)then
        callback()
    end
end
--获取部队信息
function platWarVoApi:getInfo(callback)
    local function getinfoCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data then
                self:updateInfo(sData.data)
            end
            self:setTroopsFlag(1)
            if callback then
                callback()
            end
        end
    end
    if self:getTroopsFlag() == -1 then
        socketHelper:platwarGetinfo(getinfoCallback)
    else
        if callback then
            callback()
        end
    end
end
function platWarVoApi:updateInfo(infoData)
    if infoData then
        if infoData.platwar then
            if infoData.platwar.info then
                local tinfo = infoData.platwar.info
                local troops = tinfo.troops or {}
                for k, v in pairs(troops) do
                    local tType = k + 20
                    for m, n in pairs(v) do
                        if n and n[1] and n[2] then
                            local tid = (tonumber(n[1]) or tonumber(RemoveFirstChar(n[1])))
                            tankVoApi:setTanksByType(tType, m, tid, tonumber(n[2]))
                        else
                            tankVoApi:deleteTanksTbByType(tType, m)
                        end
                    end
                end
                if base.heroSwitch == 1 then
                    local hero = tinfo.hero or {}
                    for k, v in pairs(hero) do
                        if v and SizeOfTable(v) > 0 then
                            heroVoApi:setPlatWarHeroList(k, v)
                        end
                    end
                end
                if tinfo.line then
                    local line = tinfo.line
                    if line and SizeOfTable(line) > 0 then
                        tankVoApi:setPlatWarFleetIndexTb(line)
                    end
                end
                if(tinfo.buff)then
                    self.buffList = {}
                    for k, v in pairs(tinfo.buff) do
                        self.buffList[k] = tonumber(v)
                    end
                end
                if tinfo.ts then
                    for k, v in pairs(tinfo.ts) do
                        self:setLastSetFleetTime(k, v)
                    end
                end
                if tinfo.lts then
                    self:setLastSetLineTime(tinfo.lts)
                end
                if tinfo.rd then
                    self:setHasRewardRank(tinfo.rd)
                end
                if tinfo.addpoint then
                    self:setDonatePoint(tonumber(tinfo.addpoint))
                end
                if tinfo.equip then
                    for k, v in pairs(tinfo.equip) do
                        local bType = k + 20
                        emblemVoApi:setBattleEquip(bType, v)
                    end
                end
                if tinfo.plane then
                    for k, v in pairs(tinfo.plane) do
                        local bType = k + 20
                        planeVoApi:setBattleEquip(bType, v)
                    end
                end
                if tinfo.ap then --飞艇
                    for k, v in pairs(tinfo.ap) do
                        local bType = k + 20
                        airShipVoApi:setBattleEquip(bType, v)
                    end
                end
            end
            if infoData.platwar.donate_at then
                self:setLastDonateTime(tonumber(infoData.platwar.donate_at))
            end
            if infoData.platwar.point then
                self:setPoint(tonumber(infoData.platwar.point))
            end
            if infoData.platwar.bid then
                self:setWarID(infoData.platwar.bid)
            end
        end
        if infoData.donateinfo then
            local donateInfo = infoData.donateinfo
            for i = 1, 3 do
                local donateNum = 0
                if donateInfo["final"..i] then
                    donateNum = donateInfo["final"..i]
                    self:setDonateTroopsNumByIndex(i, donateNum)
                end
                if donateInfo["info"..i] then
                    for k, v in pairs(donateInfo["info"..i]) do
                        if v and v[1] and v[2] then
                            local tid = v[1]
                            local num = v[2] or 0
                            local id = (tonumber(tid) or tonumber(RemoveFirstChar(tid)))
                            local oldNum = self:getDonateTroopsByIndexPos(i, k)
                            if oldNum < num then
                                self:setDonateTroopsByIndexPos(i, k, id, num)
                            end
                            -- if platWarCfg and platWarCfg.troopsDonate and platWarCfg.troopsDonate[i] and platWarCfg.troopsDonate[i].troops then
                            -- local tCfg=platWarCfg.troopsDonate[i].troops
                            -- if num and tCfg[k] and tCfg[k][2] then
                            -- local needNum=tCfg[k][2]*(donateNum+1)-num
                            -- print("needNum",tCfg[k][2]*(donateNum+1),num,needNum)
                            -- self:setDonateTroopsByIndexPos(i,k,id,needNum)
                            -- end
                            -- end
                        end
                    end
                end
            end
        end
        if infoData.moraleInfo then
            self:setMoraleList(infoData.moraleInfo)
        end
        if infoData.npcCount then
            self.troopList = {}
            for i = 1, 2 do
                self.troopList[i] = {}
                for j = 1, platWarCfg.mapAttr.lineNum do
                    if(infoData.npcCount[i] and infoData.npcCount[i][tostring(j)])then
                        self.troopList[i][j] = tonumber(infoData.npcCount[i][tostring(j)])
                    else
                        self.troopList[i][j] = 0
                    end
                end
            end
            eventDispatcher:dispatchEvent("platWar.npcCount")
        end
    end
end

function platWarVoApi:refreshBattle(callback)
    if(base.serverTime >= self.battleExpireTime)then
        local function onRequestEnd(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                if(sData.data.platwarserver or sData.data.userstats or sData.data.donateinfo)then
                    self:formatBattleData(sData.data.platwarserver, sData.data.userstats)
                    self:updateInfo(sData.data)
                    local status = self:checkStatus()
                    --为了防止后台还没计算完，所以给了10秒的延迟
                    if(status == 0)then
                        if(base.serverTime < self.startTime)then
                            self.battleExpireTime = self.startTime + 10
                        else
                            self.battleExpireTime = base.serverTime + 300
                        end
                    else
                        if(status < 20)then
                            self.battleExpireTime = base.serverTime + 300
                        elseif(status < 30)then
                            self.battleExpireTime = base.serverTime - base.serverTime % platWarCfg.battleAttr.cdTime + platWarCfg.battleAttr.cdTime + 10
                        else
                            self.battleExpireTime = self.endTime
                        end
                    end
                    if(callback)then
                        callback()
                    end
                end
            else
                self.battleExpireTime = base.serverTime + 60 + math.random(1, 10)
            end
        end
        socketHelper:platWarRefresh(onRequestEnd)
    elseif(callback)then
        callback()
    end
end

function platWarVoApi:formatBattleData(battleData, playerData)
    if(battleData)then
        if(battleData.round)then
            self.curRound = tonumber(battleData.round)
        end
        if(battleData.nextRoundAt)then
            self.nextBattleTime = tonumber(battleData.nextRoundAt)
        end
        if(battleData.moraleInfo)then
            self:setMoraleList(battleData.moraleInfo)
        end
        if(battleData.battleLineInfo)then
            self.lineList = {}
            for i = 1, platWarCfg.mapAttr.lineNum do
                if(battleData.battleLineInfo[i])then
                    self.lineList[i] = {}
                    if(battleData.battleLineInfo[i][1])then
                        self.lineList[i][1] = tonumber(battleData.battleLineInfo[i][1])
                    else
                        self.lineList[i][1] = 0
                    end
                    if(battleData.battleLineInfo[i][2])then
                        self.lineList[i][2] = tonumber(battleData.battleLineInfo[i][2])
                    else
                        self.lineList[i][2] = platWarCfg.mapAttr.lineLength + 1
                    end
                else
                    self.lineList = {0, platWarCfg.mapAttr.lineLength + 1}
                end
            end
        end
        if(battleData.cityInfo)then
            self.cityList = {}
            for road, tb in pairs(battleData.cityInfo) do
                self.cityList[road] = {}
                for point, cityData in pairs(tb) do
                    cityData[3] = road
                    cityData[4] = point
                    local cityVo = platWarCityVo:new()
                    cityVo:init(cityData)
                    self.cityList[road][point] = cityVo
                end
            end
        end
        if(battleData.npcCount)then
            self.troopList = {}
            for i = 1, 2 do
                self.troopList[i] = {}
                for j = 1, platWarCfg.mapAttr.lineNum do
                    if(battleData.npcCount[i] and battleData.npcCount[i][tostring(j)])then
                        self.troopList[i][j] = tonumber(battleData.npcCount[i][tostring(j)])
                    else
                        self.troopList[i][j] = 0
                    end
                end
            end
        end
        if(battleData.lineUserList)then
            self.troopDetailList = battleData.lineUserList
        end
        if(battleData.over)then
            if(battleData.over.winner)then
                self.winnerID = self.platList[tonumber(battleData.over.winner)][1]
            end
        end
    end
    if(playerData)then
        if(playerData.userMoveInfo)then
            self.troopInfo = {}
            for troopIndex, troopInfo in pairs(playerData.userMoveInfo) do
                for k, v in pairs(troopInfo) do
                    troopInfo[k] = tonumber(v)
                end
                self.troopInfo[tonumber(troopIndex)] = troopInfo
            end
        end
        if(playerData.reviveRound)then
            if(self.troopInfo == nil)then
                self.troopInfo = {}
            end
            for troopIndex, reviveRound in pairs(playerData.reviveRound) do
                if(self.troopInfo[tonumber(troopIndex)] == nil)then
                    self.troopInfo[tonumber(troopIndex)] = {}
                end
                if(tonumber(reviveRound) > self:getCurRound())then
                    self.troopInfo[tonumber(troopIndex)][3] = tonumber(reviveRound)
                else
                    self.troopInfo[tonumber(troopIndex)][3] = 0
                end
            end
        end
    end
end

function platWarVoApi:getTroopsFlag()
    return self.troopsFlag
end
function platWarVoApi:setTroopsFlag(troopsFlag)
    self.troopsFlag = troopsFlag
end
--地形
function platWarVoApi:getFleetLandType(fleetIndex)
    if platWarCfg and platWarCfg.mapAttr and platWarCfg.mapAttr.lineLandtype then
        if platWarCfg.mapAttr.lineLandtype[fleetIndex] then
            return platWarCfg.mapAttr.lineLandtype[fleetIndex]
        end
    end
    return 0
end
function platWarVoApi:getLastSetLineTime()
    return self.lastSetLineTime
end
function platWarVoApi:setLastSetLineTime(time)
    self.lastSetLineTime = time
end
function platWarVoApi:getLastSetFleetTime(index)
    if index then
        return self.lastSetFleetTime[index]
    end
    return 0
end
function platWarVoApi:setLastSetFleetTime(index, time)
    if index and time and self.lastSetFleetTime and self.lastSetFleetTime[index] then
        self.lastSetFleetTime[index] = time
    end
end
function platWarVoApi:getIsCanSetFleet(index, layerNum, isShowTip)
    if isShowTip == nil then
        isShowTip = true
    end
    local lastTime = self:getLastSetFleetTime(index)
    if lastTime then
        local leftTime = platWarCfg.settingTroopsLimit - (base.serverTime - lastTime)
        if leftTime > 0 then
            do return false end
        end
    end
    
    local isEable = true
    local num = 0;
    local type = index + 20
    
    for k, v in pairs(tankVoApi:getTanksTbByType(type)) do
        if SizeOfTable(v) == 0 then
            num = num + 1;
        end
    end
    
    if num == 6 then
        isEable = false
    end
    if isEable == false then
        if isShowTip == true then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("allianceWarNoArmy"), nil, layerNum + 1, nil)
        end
        do return false end
    end
    return true
end

--判断是否能设置部队和线路提示
function platWarVoApi:isCanSetTroops(isShowTip)
    local checkStatus = self:checkStatus()
    if checkStatus >= 30 then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("plat_war_end"), 30)
        do return false end
    end
    local isCanSetTroops = self:isJoinBattle(isShowTip)
    return isCanSetTroops
end
--判断是否能设置部队和线路提示
function platWarVoApi:isJoinBattle(isShowTip)
    local selfData = self:getPlayer()
    if selfData then
        if selfData.rank and selfData.rank <= platWarCfg.joinLimit then
            do return true end
        end
    end
    if isShowTip == false then
    else
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("plat_war_not_join"), 30)
    end
    return false
end
--部队状态 index:第几支部队
function platWarVoApi:getTroopsStatus(index)
    local status = 2
    local round = 0
    local checkStatus = self:checkStatus()
    if checkStatus == 20 then
        local troopsStatus = self:getTroopInfo()
        if troopsStatus and troopsStatus[index] then
            local infoTb = troopsStatus[index]
            local curRound = platWarVoApi:getCurRound()
            if curRound and infoTb[3] and infoTb[3] > 0 and curRound < infoTb[3] then
                status = 3
                round = infoTb[3] - curRound
            elseif infoTb[1] and infoTb[2] and infoTb[1] > 0 and infoTb[2] > 0 then
                status = 1
            else
                status = 2
            end
        end
    end
    return status, round
end

--获取平台系数，捐献部队和金币都要乘以这个系数
function platWarVoApi:getPlatRate()
    local rate = 1
    if platWarCfg and platWarCfg.platform and base.serverPlatID and platWarCfg.platform[base.serverPlatID] then
        local pCfg = platWarCfg.platform[base.serverPlatID]
        if pCfg.donateNum then
            rate = pCfg.donateNum
        end
    end
    return rate
end

--上次捐献士气时间
function platWarVoApi:getLastDonateTime()
    return self.lastDonateTime
end
function platWarVoApi:setLastDonateTime(lastDonateTime)
    self.lastDonateTime = lastDonateTime
end
--士气
function platWarVoApi:getCurMorale()
    local curMorale = 0
    local index
    local platList = self:getPlatList()
    for k, v in pairs(platList) do
        if v and v[1] and v[1] == base.serverPlatID then
            index = k
        end
    end
    if index then
        local moraleList = self:getMoraleList()
        if moraleList and moraleList[index] then
            curMorale = moraleList[index]
        end
    end
    return curMorale
end
function platWarVoApi:setCurMorale(curMorale)
    local index
    local platList = self:getPlatList()
    for k, v in pairs(platList) do
        if v and v[1] and v[1] == base.serverPlatID then
            index = k
        end
    end
    if index and curMorale then
        if self.moraleList and self.moraleList[index] then
            self.moraleList[index] = curMorale
        end
    end
end
--捐献的部队
function platWarVoApi:getDonateTroops()
    return self.donateTroops
end
function platWarVoApi:setDonateTroops(donateTroops)
    self.donateTroops = donateTroops
end
function platWarVoApi:getDonateTroopsByIndex(index)
    if index and self.donateTroops and self.donateTroops[index] then
        return self.donateTroops[index]
    else
        return {}
    end
end
function platWarVoApi:setDonateTroopsByIndex(index, troops)
    if self.donateTroops == nil then
        self.donateTroops = {}
    end
    if index and troops then
        self.donateTroops[index] = troops
    end
end
function platWarVoApi:getDonateTroopsByIndexPos(index, pos)
    if index and self.donateTroops and self.donateTroops[index] and self.donateTroops[index][pos] and self.donateTroops[index][pos][2] then
        return self.donateTroops[index][pos][2]
    end
    return 0
end
function platWarVoApi:setDonateTroopsByIndexPos(index, pos, id, num)
    if self.donateTroops == nil then
        self.donateTroops = {}
    end
    if index then
        if self.donateTroops[index] == nil then
            self.donateTroops[index] = {}
        end
        self.donateTroops[index][pos] = {id, num}
    end
end
--获取捐献的是第几个位置的坦克
function platWarVoApi:getPosByTankId(index, tankId)
    if index and tankId and platWarCfg.troopsDonate and platWarCfg.troopsDonate[index] and platWarCfg.troopsDonate[index].troops then
        local troopsCfg = platWarCfg.troopsDonate[index].troops
        for k, v in pairs(troopsCfg) do
            if v and v[1] and v[1] == tankId then
                return k
            end
        end
    end
    return 0
end
--捐献部队的次数
function platWarVoApi:getDonateTroopsNumByIndex(index)
    if index and self.donateTroopsNum and self.donateTroopsNum[index] then
        return self.donateTroopsNum[index]
    else
        return 0
    end
end
function platWarVoApi:setDonateTroopsNumByIndex(index, num)
    if self.donateTroopsNum == nil then
        self.donateTroopsNum = {}
    end
    if index and num then
        self.donateTroopsNum[index] = num
    end
end

--获取士气影响的属性值
-- 造成的伤害（额外提升部分）=   士气点数 / (  100000 + 士气点数） * 1
-- 受到伤害的公式 =  0-  ( 士气点数 / (  100000 + 士气点数） * 1 )
-- 命中的公式 =  士气点数 / (  100000 + 士气点数） * 1
-- 暴击的公式 =  士气点数 / (  100000 + 士气点数） * 1
-- 闪避的公式 =  士气点数 / (  100000 + 士气点数） * 1
-- 装甲的公式 =  士气点数 / (  100000 + 士气点数） * 1
-- 击破的公式 =  士气点数 / (  100000 + 士气点数） * 50
-- 防护的公式 =  士气点数 / (  100000 + 士气点数） * 50
function platWarVoApi:getAddAttrNum(curMorale)
    local addDamage, reduceDamage, accurate, critical, avoid, decritical, penetrate, armor = 0, 0, 0, 0, 0, 0, 0, 0
    if curMorale then
        -- print("addDamage",curMorale/(100000+curMorale)*1)
        -- print("reduceDamage",1-(curMorale/(100000+curMorale)*1))
        addDamage = tonumber(string.format("%.2f", curMorale / (100000 + curMorale) * 1)) * 100
        reduceDamage = tonumber(string.format("%.2f", (curMorale / (100000 + curMorale) * 1))) * 100
        accurate = tonumber(string.format("%.2f", curMorale / (100000 + curMorale) * 1)) * 100
        critical = tonumber(string.format("%.2f", curMorale / (100000 + curMorale) * 1)) * 100
        avoid = tonumber(string.format("%.2f", curMorale / (100000 + curMorale) * 1)) * 100
        decritical = tonumber(string.format("%.2f", curMorale / (100000 + curMorale) * 1)) * 100
        penetrate = tonumber(string.format("%.2f", curMorale / (100000 + curMorale) * 250))
        armor = tonumber(string.format("%.2f", curMorale / (100000 + curMorale) * 250))
    end
    return addDamage, reduceDamage, accurate, critical, avoid, decritical, penetrate, armor
end

function platWarVoApi:formatReportList(type, callback, isPage)
    if type == nil then
        type = 1
    end
    if self.reportList == nil then
        self.reportList = {}
    end
    if self.reportList[type] == nil then
        self.reportList[type] = {}
    end
    local function reportCallback(sData)
        -- local function reportCallback(fn,data)
        -- local ret,sData=base:checkServerData(data)
        -- if ret==true then
        if sData and sData.data then
            if sData.data.count then
                if self.reportNum == nil then
                    self.reportNum = {}
                end
                self.reportNum[type] = tonumber(sData.data.count)
            end
            if sData.data.list then
                require "luascript/script/game/gamemodel/platWar/platWarReportVo"
                local minid, maxid = self:getMinAndMaxId(type)
                for k, v in pairs(sData.data.list) do
                    if v then
                        local id = tonumber(v.id)
                        if minid > 0 and maxid > 0 and id > minid and id < maxid then
                        else
                            local attacker = tonumber(v.attid)
                            local attName = v.attname
                            if tonumber(attName) and tonumber(attName) < 10 then
                                attName = getlocal("plat_war_donate_troops_"..attName)
                            end
                            local attPlat = v.ap
                            local attServer = tonumber(v.attzid)
                            local defender = tonumber(v.defid)
                            local defName = v.defname
                            if tonumber(defName) and tonumber(defName) < 10 then
                                defName = getlocal("plat_war_donate_troops_"..defName)
                            end
                            local defPlat = v.dp
                            local defServer = tonumber(v.defzid)
                            local isVictory = tonumber(v.iswin)
                            local time = tonumber(v.updated_at)
                            local roadIndex = tonumber(v.line or 0)
                            local isAttacker
                            if base.serverPlatID == attPlat then
                                isAttacker = true
                            else
                                isAttacker = false
                            end
                            local vo = platWarReportVo:new()
                            vo:initWithData(id, attacker, attName, attPlat, attServer, defende, defName, defPlat, defServer, isVictory, isAttacker, time, roadIndex)
                            table.insert(self.reportList[type], vo)
                        end
                    end
                end
            end
            local function sortFunc(a, b)
                if a and b and a.id and b.id then
                    return a.id > b.id
                end
            end
            table.sort(self.reportList[type], sortFunc)
            local reportMaxNum = platWarCfg.reportMaxNum
            local num = self:getReportNum(type)
            local totalNum = self:getTotalNum(type)
            if totalNum > reportMaxNum then
                totalNum = reportMaxNum
            end
            if num < totalNum then
                self:setReportHasMore(type, true)
            else
                self:setReportHasMore(type, false)
            end
            local nextTime = self:getBattleExpireTime()
            self:setReportExpireTime(type, nextTime)
            if reportMaxNum then
                while SizeOfTable(self.reportList[type]) > reportMaxNum do
                    table.remove(self.reportList[type], reportMaxNum + 1)
                end
            end
        end
        -- if callback then
        -- callback()
        -- end
        -- end
    end
    if self.httphost then
        if isPage == true then
            local mineid, maxeid = self:getMinAndMaxId(type)
            local warId = platWarVoApi:getWarID()
            local httpUrl = self.httphost.."report"
            local reqStr = "uid="..playerVoApi:getUid() .. "&bid="..warId.."&mineid="..mineid.."&maxeid="..maxeid.."&action="..type
            -- deviceHelper:luaPrint(httpUrl)
            -- deviceHelper:luaPrint(reqStr)
            local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
            -- deviceHelper:luaPrint(retStr)
            if(retStr ~= "")then
                local retData = G_Json.decode(retStr)
                if (retData["ret"] == 0 or retData["ret"] == "0") and retData.data then
                    reportCallback(retData)
                end
            end
            -- socketHelper:platwarReport(type,reportCallback,mineid,maxeid)
        elseif base.serverTime > self:getReportExpireTime(type) then
            self.reportList[type] = {}
            local warId = platWarVoApi:getWarID()
            local httpUrl = self.httphost.."report"
            local reqStr = "uid="..playerVoApi:getUid() .. "&bid="..warId.."&mineid=0&maxeid=0&action="..type
            -- deviceHelper:luaPrint(httpUrl)
            -- deviceHelper:luaPrint(reqStr)
            local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
            -- deviceHelper:luaPrint(retStr)
            if(retStr ~= "")then
                local retData = G_Json.decode(retStr)
                if (retData["ret"] == 0 or retData["ret"] == "0") and retData.data then
                    reportCallback(retData)
                end
            end
            -- socketHelper:platwarReport(type,reportCallback,0,0)
        end
    end
    if callback then
        callback()
    end
end
function platWarVoApi:addReportBattle(type, id, callback, isShowBattle)
    if type and id then
        local report = self:getReportById(type, id)
        if report then
            local function showBattle(report1)
                local data = {data = {report = report1}, isReport = true, battleType = 4}
                local landform = self:getLandform(report.roadIndex)
                if landform then
                    data.landform = {landform, landform}
                end
                battleScene:initData(data)
            end
            if report.report and SizeOfTable(report.report) > 0 then
                if isShowBattle == true then
                    showBattle(report.report)
                end
                -- if callback then
                -- callback()
                -- end
            else
                local function showBattleCallback(sData)
                    -- local function showBattleCallback(fn,data)
                    -- local ret,sData=base:checkServerData(data)
                    --              if ret==true then
                    if sData.data and sData.data.report then
                        if self.reportList and self.reportList[type] then
                            for k, v in pairs(self.reportList[type]) do
                                if tostring(id) == tostring(v.id) then
                                    self.reportList[type][k].report = sData.data.report
                                end
                            end
                            if isShowBattle == true then
                                showBattle(sData.data.report)
                            end
                        end
                    end
                    -- if callback then
                    -- callback()
                    -- end
                    --   end
                end
                local id = report.id
                if self.httphost then
                    local mineid, maxeid = self:getMinAndMaxId(type)
                    local warId = platWarVoApi:getWarID()
                    local httpUrl = self.httphost.."report"
                    local reqStr = "uid="..playerVoApi:getUid() .. "&bid="..warId.."&action=3&id="..id
                    -- deviceHelper:luaPrint(httpUrl)
                    -- deviceHelper:luaPrint(reqStr)
                    local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
                    -- deviceHelper:luaPrint(retStr)
                    if(retStr ~= "")then
                        local retData = G_Json.decode(retStr)
                        if (retData["ret"] == 0 or retData["ret"] == "0") and retData.data then
                            showBattleCallback(retData)
                        end
                    end
                end
                -- if callback then
                -- callback()
                -- end
                -- socketHelper:platwarGetreport(id,showBattleCallback)
            end
        end
    end
    if callback then
        callback()
    end
end
--战报列表
function platWarVoApi:getReportList(type)
    if type and self.reportList and self.reportList[type] then
        return self.reportList[type]
    else
        return {}
    end
end
function platWarVoApi:getReportById(type, id)
    local reports = self:getReportList(type)
    for k, v in pairs(reports) do
        if tostring(id) == tostring(v.id) then
            return v
        end
    end
    return {}
end
function platWarVoApi:getMinAndMaxId(type)
    local minid, maxid = 0, 0
    local reports = self:getReportList(type)
    if reports ~= nil and SizeOfTable(reports) ~= 0 then
        minid, maxid = reports[SizeOfTable(reports)].id, reports[1].id
    end
    return minid, maxid
end
function platWarVoApi:getReportNum(type)
    local num = 0
    if type then
        local reports = self:getReportList(type)
        num = SizeOfTable(reports)
    end
    return num
end
function platWarVoApi:getTotalNum(type)
    local num = 0
    if type and self.reportNum and self.reportNum[type] then
        num = tonumber(self.reportNum[type] or 0)
    end
    return num
end
--战报过期时间
function platWarVoApi:getReportExpireTime(type)
    if type and self.reportExpireTime and self.reportExpireTime[type] then
        return self.reportExpireTime[type]
    else
        return 0
    end
end
function platWarVoApi:setReportExpireTime(type, time)
    if type and time then
        if self.reportExpireTime == nil then
            self.reportExpireTime = {}
        end
        self.reportExpireTime[type] = time
    end
end
--战报列表是否还有更多
function platWarVoApi:getReportHasMore(type)
    if type and self.reportHasMore and self.reportHasMore[type] ~= nil then
        return self.reportHasMore[type]
    else
        return false
    end
end
function platWarVoApi:setReportHasMore(type, value)
    if type and value ~= nil then
        if self.reportHasMore == nil then
            self.reportHasMore = {}
        end
        self.reportHasMore[type] = value
    end
end
--index 第几条线
function platWarVoApi:getLandform(index)
    if index and index > 0 and platWarCfg and platWarCfg.mapAttr and platWarCfg.mapAttr.lineLandtype then
        return platWarCfg.mapAttr.lineLandtype[index]
    end
    return nil
end
----------------以下积分商店和积分明细---------------
--普通道具配置
function platWarVoApi:getShopCommonItems()
    return platWarCfg.pShopItems
end
--珍品配置
function platWarVoApi:getShopRareItems()
    return platWarCfg.aShopItems
end
function platWarVoApi:getShopFlag()
    return self.shopFlag
end
function platWarVoApi:setShopFlag(shopFlag)
    self.shopFlag = shopFlag
end
-- function platWarVoApi:getBuyStatus()
-- return self.buyStatus
-- end
-- function platWarVoApi:setBuyStatus(buyStatus)
-- self.buyStatus=buyStatus
-- end
function platWarVoApi:getShopShowStatus(type)
    local isJoinBattle = self:isJoinBattle(false)
    local status = self:checkStatus()
    if status and status >= 30 then
        if isJoinBattle == true and type == 2 then
            return 2
        end
        return 1
    end
    return 0
end

--根据id获取道具的配置
function platWarVoApi:getItemById(id)
    local item = nil
    if id then
        local commonList = self:getShopCommonItems()
        local rareList = self:getShopRareItems()
        local key = string.sub(id, 1, 1)
        if key == "i" then
            if commonList[id] then
                item = commonList[id]
            end
        elseif key == "a" then
            if rareList[id] then
                item = rareList[id]
            end
        end
    end
    return item
end
--初始化世界争霸的商店信息
function platWarVoApi:initShopInfo()
    require "luascript/script/game/gamemodel/platWar/platWarShopVo"
    local commonItems = self:getShopCommonItems()
    local rareItems = self:getShopRareItems()
    self.commonList = {}
    self.rareList = {}
    for k, v in pairs(commonItems) do
        local vo = platWarShopVo:new()
        vo:initWithData(k, 0)
        table.insert(self.commonList, vo)
    end
    for k, v in pairs(rareItems) do
        local vo = platWarShopVo:new()
        vo:initWithData(k, 0)
        table.insert(self.rareList, vo)
    end
    local function sortAsc(a, b)
        if a and b and a.id and b.id then
            local aid = (tonumber(a.id) or tonumber(RemoveFirstChar(a.id)))
            local bid = (tonumber(b.id) or tonumber(RemoveFirstChar(b.id)))
            if aid and bid then
                return aid < bid
            end
        end
    end
    table.sort(self.commonList, sortAsc)
    table.sort(self.rareList, sortAsc)
end
--获取世界争霸的商店信息
--param callback: 获取之后的回调函数
function platWarVoApi:getShopInfo(callback, data)
    local shopFlag = self:getShopFlag()
    if shopFlag == -1 then
        self:initShopInfo()
        self:setShopFlag(1)
    end
    
    if data then
        if self.commonList == nil or self.rareList == nil then
            self:initShopInfo()
        end
        for k, v in pairs(data) do
            local key = string.sub(k, 1, 1)
            if key == "i" then
                for m, n in pairs(self.commonList) do
                    if n and n.id == k then
                        self.commonList[m].num = v
                    end
                end
            elseif key == "a" then
                for m, n in pairs(self.rareList) do
                    if n and n.id == k then
                        self.rareList[m].num = v
                    end
                end
            end
        end
    end
    
    if(callback)then
        callback()
    end
end

function platWarVoApi:getPointDetailFlag()
    return self.pointDetailFlag
end
function platWarVoApi:setPointDetailFlag(pointDetailFlag)
    self.pointDetailFlag = pointDetailFlag
end

function platWarVoApi:getDetailExpireTime()
    return self.detailExpireTime
end
function platWarVoApi:setDetailExpireTime(detailExpireTime)
    self.detailExpireTime = detailExpireTime
end

function platWarVoApi:clearPointDetail()
    if self.pointDetail ~= nil then
        for k, v in pairs(self.pointDetail) do
            self.pointDetail[k] = nil
        end
        self.pointDetail = nil
    end
    self.pointDetail = {}
    -- self.page=0
    -- self.hasMore=false
    self.pointDetailFlag = -1
    self.detailExpireTime = 0
end
--初始化积分明细
function platWarVoApi:formatPointDetail(callback)
    local function GetpointlogCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data and sData.data.pointlog then
                local warId = self:getWarID()
                if warId and sData.data.pointlog[warId] then
                    self:clearPointDetail()
                    --商店数据
                    local shopData = sData.data.pointlog[warId].lm or {}
                    if shopData then
                        self:getShopInfo(nil, shopData)
                    end
                    --积分明细
                    require "luascript/script/game/gamemodel/platWar/platWarPointDetailVo"
                    local record = sData.data.pointlog[warId].rc or {}
                    -- record.add={
                    -- {1441548771,100,2,1},
                    -- {1441548871,10,1,2},
                    -- {1441549871,90,3},
                    -- }
                    if record and record.add and SizeOfTable(record.add) > 0 then
                        for k, v in pairs(record.add) do
                            local type, time, message, color = self:formatMessage(v, 1)
                            if type and time and message then
                                local vo = platWarPointDetailVo:new()
                                vo:initWithData(type, time, message, color)
                                table.insert(self.pointDetail, vo)
                            end
                        end
                    end
                    if record and record.buy and SizeOfTable(record.buy) > 0 then
                        for k, v in pairs(record.buy) do
                            local type, time, message, color = self:formatMessage(v, 2)
                            if type and time and message then
                                local vo = platWarPointDetailVo:new()
                                vo:initWithData(type, time, message, color)
                                table.insert(self.pointDetail, vo)
                            end
                        end
                    end
                    if self.pointDetail and SizeOfTable(self.pointDetail) > 0 then
                        local function sortAsc(a, b)
                            if a and b and a.time and b.time and tonumber(a.time) and tonumber(b.time) then
                                return tonumber(a.time) > tonumber(b.time)
                            end
                        end
                        table.sort(self.pointDetail, sortAsc)
                    end
                end
            end
            self:setPointDetailFlag(1)
            if callback then
                callback()
            end
        end
    end
    if self:getPointDetailFlag() == -1 then
        socketHelper:platwarGetpointlog(GetpointlogCallback)
    else
        if callback then
            callback()
        end
    end
end

function platWarVoApi:formatMessage(data, mType)
    local id
    local type
    local time = 0
    local point = 0
    local targetName = ""
    local color = G_ColorGreen
    local rank = 0
    local itemId
    local params = {}
    local message = ""
    if mType == 1 then
        if data and SizeOfTable(data) > 0 then
            time = tonumber(data[1]) or 0
            point = tonumber(data[2])
            type = tonumber(data[3])
            if data[4] then
                rank = tonumber(data[4])
            end
            if type == 1 or type == 2 then
                params = {rank, point}
                -- elseif type==3 then
                -- params={point}
            end
            message = getlocal("plat_war_point_record_desc_"..type, params)
        end
    elseif mType == 2 then
        if data and data[1] then
            color = G_ColorRed
            itemId = data[1]
            time = tonumber(data[2]) or 0
            local cfg = self:getItemById(itemId)
            if cfg then
                if cfg.reward then
                    local rewardTb = FormatItem(cfg.reward)
                    local item = rewardTb[1]
                    targetName = item.name.."x"..item.num
                end
                if cfg.price then
                    point = tonumber(cfg.price)
                end
            end
            params = {targetName, point}
            message = getlocal("world_war_point_desc_7", params)
        end
    end
    return type, time, message, color
end
function platWarVoApi:addPointDetail(data, mType)
    require "luascript/script/game/gamemodel/platWar/platWarPointDetailVo"
    local type, time, message, color = self:formatMessage(data, mType)
    local vo = platWarPointDetailVo:new()
    vo:initWithData(type, time, message, color)
    table.insert(self.pointDetail, vo)
    local function sortAsc(a, b)
        if a and b and a.time and b.time and tonumber(a.time) and tonumber(b.time) then
            return tonumber(a.time) > tonumber(b.time)
        end
    end
    table.sort(self.pointDetail, sortAsc)
    self:setPointDetailFlag(0)
    
    if self.pointDetail then
        while SizeOfTable(self.pointDetail) > platWarCfg.militaryrank do
            table.remove(self.pointDetail, platWarCfg.militaryrank + 1)
        end
    end
end

function platWarVoApi:getTimeStr(time)
    local date = G_getDataTimeStr(time)
    return date
end

--购买物品 type:1：道具，2：珍品 id：物品id
function platWarVoApi:buyItem(type, id, callback)
    local function buyHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if type == 1 then
                local commonItems = self:getShopCommonItems()
                for k, v in pairs(self.commonList) do
                    if v.id == id then
                        self.commonList[k].num = self.commonList[k].num + 1
                    end
                end
                local cfg = commonItems[id]
                local rewardTb = FormatItem(cfg.reward)
                local price = cfg.price
                self:setPoint(self:getPoint() - price)
                for k, v in pairs(rewardTb) do
                    G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                end
                G_showRewardTip(rewardTb, true)
                
                local addData = {id, sData.ts}
                self:addPointDetail(addData, 2)
            elseif type == 2 then
                local rareItems = self:getShopRareItems()
                for k, v in pairs(self.rareList) do
                    if v.id == id then
                        self.rareList[k].num = self.rareList[k].num + 1
                    end
                end
                local cfg = rareItems[id]
                local rewardTb = FormatItem(cfg.reward)
                local price = cfg.price
                self:setPoint(self:getPoint() - price)
                for k, v in pairs(rewardTb) do
                    G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
                end
                G_showRewardTip(rewardTb, true)
                
                local addData = {id, sData.ts}
                self:addPointDetail(addData, 2)
            end
            if callback then
                callback()
            end
        end
    end
    local sType
    if type == 1 then
        sType = "pShopItems"
    elseif type == 2 then
        sType = "aShopItems"
    end
    if sType and id then
        socketHelper:platwarBuy(sType, id, buyHandler)
    end
end

--获取商店里面的道具列表
function platWarVoApi:getCommonList()
    if (self.commonList) then
        return self.commonList
    end
    return {}
end
--获取商店里面的珍品列表
function platWarVoApi:getRareList()
    if (self.rareList) then
        return self.rareList
    end
    return {}
end
--获取积分明细
function platWarVoApi:getPointDetail()
    if (self.pointDetail) then
        return self.pointDetail
    end
    return {}
end
--商店总积分
function platWarVoApi:getPoint()
    return self.point
end
function platWarVoApi:setPoint(point)
    self.point = point
end
--捐献获得的商店积分
function platWarVoApi:getDonatePoint()
    return self.donatePoint
end
function platWarVoApi:setDonatePoint(donatePoint)
    self.donatePoint = donatePoint
end
----------------以上积分商店和积分明细---------------

---------------------以下排行榜--------------------
function platWarVoApi:getRankExpireTime(type)
    if type and self.rankExpireTime then
        return self.rankExpireTime[type]
    else
        return - 1
    end
end
--排行榜
function platWarVoApi:clearRankList(type)
    if type then
        if self.rankList[type] then
            self.rankList[type] = {}
        end
    else
        self.rankList = {{}, {}}
    end
end
function platWarVoApi:formatRankList(type, callback)
    local function ranklistcallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data and sData.data.mypoint then
                self:setMyPoint(type, tonumber(sData.data.mypoint))
            end
            if sData.data and sData.data.myrank then
                self:setMyRank(type, tonumber(sData.data.myrank))
            end
            if sData.data and sData.data.list then
                local list = sData.data.list
                require "luascript/script/game/gamemodel/platWar/platWarRankVo"
                if self.rankList == nil then
                    self.rankList = {}
                end
                if self.rankList[type] == nil then
                    self.rankList[type] = {}
                end
                self:clearRankList(type)
                for k, v in pairs(list) do
                    if v then
                        local id
                        local platId
                        local server
                        local pData = v.u
                        if pData then
                            local arr = Split(pData, "-")
                            platId = arr[1]
                            server = arr[2]--GetServerNameByID(arr[2])
                            id = tonumber(arr[3])
                        end
                        local name = v.n
                        local rank = tonumber(v.r)
                        -- local power=tonumber(v.fc) or 0
                        local value = tonumber(v.v) or 0
                        local vo = platWarRankVo:new()
                        vo:initWithData(id, name, platId, server, rank, value)
                        table.insert(self.rankList[type], vo)
                    end
                end
                local function sortAsc(a, b)
                    if a and b then
                        -- if a.value and b.value and a.value~=b.value then
                        --  return a.value>b.value
                        -- else
                        if a.rank and b.rank and a.rank ~= b.rank then
                            return a.rank < b.rank
                            -- else
                            --  if a.power and b.power and a.power~=b.power then
                            --  return a.power>b.power
                            --  else
                            --  return a.id<b.id
                            --  end
                        end
                        -- end
                    end
                end
                table.sort(self.rankList[type], sortAsc)
            end
            if callback then
                callback()
            end
        end
    end
    socketHelper:platwarRanklist(type, ranklistcallback)
end
function platWarVoApi:getRankList(type)
    if type and self.rankList and self.rankList[type] then
        return self.rankList[type]
    end
    return {}
end
function platWarVoApi:getMyRank(type)
    local myRank = 0
    if type and self.myRank and self.myRank[type] and tonumber(self.myRank[type]) > 0 then
        myRank = self.myRank[type]
    end
    return myRank
end
function platWarVoApi:setMyRank(type, rank)
    if self.myRank == nil then
        self.myRank = {}
    end
    if type then
        if self.myRank[type] == nil then
            self.myRank[type] = 0
        end
        if rank then
            self.myRank[type] = rank
        end
    end
end
function platWarVoApi:getMyPoint(type)
    if type and self.myPoint and self.myPoint[type] then
        return self.myPoint[type]
    end
    return 0
end
function platWarVoApi:setMyPoint(type, point)
    if self.myPoint == nil then
        self.myPoint = {}
    end
    if type then
        if self.myPoint[type] == nil then
            self.myPoint[type] = 0
        end
        if point then
            self.myPoint[type] = point
        end
    end
end
function platWarVoApi:getPlatIcon(platId)
    local icon
    if platId then
        icon = CCSprite:createWithSpriteFrameName(platWarCfg.platform[platId].icon)
    end
    return icon
end
function platWarVoApi:getHasRewardRank(type)
    if type then
        if self.hasRewardRank and SizeOfTable(self.hasRewardRank) > 0 then
            for k, v in pairs(self.hasRewardRank) do
                if v and tonumber(type) == tonumber(v) then
                    return true
                end
            end
        end
    end
    return false
end
function platWarVoApi:setHasRewardRank(rewardRank)
    if rewardRank then
        self.hasRewardRank = rewardRank
    end
end
--是否能领取排行榜奖励
--0:可以，1:不可领取，2:已经领取
function platWarVoApi:isCanRewardRank(type)
    if type then
        if self:getHasRewardRank(type) == true then
            return 2
        elseif self:checkStatus() >= 30 then
            local myRank = self:getMyRank(type)
            local myPoint = platWarVoApi:getMyPoint(type)
            if myRank and myRank > 0 and myPoint and myPoint > 0 then
                if type == 1 then
                    if platWarCfg and platWarCfg.battleRank and platWarCfg.battleRank.maxNum and platWarCfg.battleRank.limitNum then
                        local limitNum = tonumber(platWarCfg.battleRank.limitNum)
                        local maxNum = tonumber(platWarCfg.battleRank.maxNum)
                        if myRank <= maxNum and myPoint >= limitNum then
                            return 0
                        end
                    end
                elseif type == 2 then
                    if platWarCfg and platWarCfg.pointRank and platWarCfg.pointRank.maxNum and platWarCfg.pointRank.limitNum then
                        local limitNum = tonumber(platWarCfg.pointRank.limitNum)
                        local maxNum = tonumber(platWarCfg.pointRank.maxNum)
                        if myRank <= maxNum and myPoint >= limitNum then
                            return 0
                        end
                    end
                end
            end
        end
    end
    return 1
end
--领取排行榜奖励
function platWarVoApi:rankReward(type, rank, callback)
    local function getrankrewardCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data then
                self:updateInfo(sData.data)
            end
            self:setPointDetailFlag(-1)
            if callback then
                callback()
            end
        end
    end
    socketHelper:platwarGetrankreward(type, rank, getrankrewardCallback)
end
---------------------以上排行榜--------------------

--战斗事件
function platWarVoApi:formatEventList(callback, isPage)
    local function geteventsCallback(sData)
        -- local function geteventsCallback(fn,data)
        -- local ret,sData=base:checkServerData(data)
        -- if ret==true then
        if sData and sData.data then
            if sData.data.count then
                self:setEventTotalNum(tonumber(sData.data.count))
            end
            if sData.data.list then
                require "luascript/script/game/gamemodel/platWar/platWarEventVo"
                local minid, maxid = self:getMinAndMaxEventId()
                for k, v in pairs(sData.data.list) do
                    if v and SizeOfTable(v) > 0 then
                        local id = tonumber(v.id)
                        if minid > 0 and maxid > 0 and id > minid and id < maxid then
                        else
                            local eventType = tonumber(v.type)
                            local time = tonumber(v.updated_at)
                            local platName = v.platform
                            local pramData = v.content
                            if type(pramData) == "string" then
                                pramData = G_Json.decode(pramData)
                            end
                            local param = {}
                            local width = 400
                            local color = G_ColorWhite
                            local targetStr = ""
                            -- local selfServerName=GetServerNameByID(base.curZoneID)
                            local isOur = false --是否是我方
                            if platName then
                                if tostring(platName) == base.serverPlatID then
                                    targetStr = getlocal("plat_war_our")
                                    color = G_ColorBlue
                                    isOur = true
                                else
                                    targetStr = getlocal("plat_war_enemy")
                                    color = G_ColorRed
                                    isOur = false
                                end
                            end
                            local messageKey = "plat_war_report_event_"..eventType
                            if eventType >= 1 and eventType <= 2 then
                                color = G_ColorYellow
                                if eventType == 2 then
                                    param = {targetStr}
                                end
                            elseif eventType == 3 then
                                local troopsIndex = pramData[1]
                                local troopsName = getlocal("plat_war_donate_troops_"..troopsIndex)
                                param = {targetStr, troopsName}
                            elseif eventType == 4 then
                                local cityIndex = pramData[1]
                                local cityName = self:getCityName(cityIndex)
                                local point = pramData[2]
                                param = {targetStr, cityName, point}
                            elseif eventType == 5 then
                                local cityIndex = pramData[1]
                                local cityName = self:getCityName(cityIndex)
                                param = {targetStr, cityName}
                            elseif eventType == 6 then
                                local point = pramData[1]
                                param = {targetStr, point}
                            elseif eventType == 7 or eventType == 8 then
                                local name = pramData[1]
                                local level = pramData[2]
                                if isOur == true then
                                    messageKey = messageKey.."_1"
                                else
                                    messageKey = messageKey.."_2"
                                end
                                param = {name, level}
                            end
                            local message = getlocal(messageKey, param)
                            local lb = GetTTFLabelWrap(message, 22, CCSizeMake(width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                            local height = lb:getContentSize().height + 20
                            local eVo = platWarEventVo:new()
                            eVo:initWithData(id, eventType, time, message, width, height, color)
                            table.insert(self.eventList, eVo)
                        end
                    end
                end
                
            end
            local function sortFunc(a, b)
                if a and b and a.id and b.id then
                    return a.id > b.id
                end
            end
            table.sort(self.eventList, sortFunc)
            local num = self:getEventNum()
            local totalNum = self:getEventTotalNum()
            if num < totalNum then
                self:setEventHasMore(true)
            else
                self:setEventHasMore(false)
            end
            -- local nextTime=self:getBattleExpireTime()
            -- self:setReportExpireTime(type,nextTime)
        end
        -- if callback then
        -- callback()
        -- end
        -- end
    end
    if self.httphost then
        if isPage == true then
            local mineid, maxeid = self:getMinAndMaxEventId()
            local warId = platWarVoApi:getWarID()
            local httpUrl = self.httphost.."getevent"
            local reqStr = "&bid="..warId.."&mineid="..mineid.."&maxeid="..maxeid
            -- deviceHelper:luaPrint(httpUrl)
            -- deviceHelper:luaPrint(reqStr)
            local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
            -- deviceHelper:luaPrint(retStr)
            if(retStr ~= "")then
                local retData = G_Json.decode(retStr)
                if (retData["ret"] == 0 or retData["ret"] == "0") and retData.data then
                    geteventsCallback(retData)
                end
            end
            -- socketHelper:platwarGetevents(mineid,maxeid,geteventsCallback)
        else
            self.eventList = {}
            local warId = platWarVoApi:getWarID()
            local httpUrl = self.httphost.."getevent"
            local reqStr = "&bid="..warId.."&mineid=0&maxeid=0"
            -- deviceHelper:luaPrint(httpUrl)
            -- deviceHelper:luaPrint(reqStr)
            local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
            -- deviceHelper:luaPrint(retStr)
            if(retStr ~= "")then
                local retData = G_Json.decode(retStr)
                if (retData["ret"] == 0 or retData["ret"] == "0") and retData.data then
                    geteventsCallback(retData)
                end
            end
            -- socketHelper:platwarGetevents(0,0,geteventsCallback)
        end
    end
    if callback then
        callback()
    end
end
function platWarVoApi:getCityName(cityIndex)
    local cityName = ""
    if cityIndex then
        cityName = getlocal("plat_war_city_"..cityIndex)
    end
    return cityName
end
function platWarVoApi:getEventList()
    return self.eventList
end
function platWarVoApi:getEventTotalNum()
    return self.eventTotalNum
end
function platWarVoApi:setEventTotalNum(num)
    self.eventTotalNum = num
end
function platWarVoApi:getMinAndMaxEventId()
    local minid, maxid = 0, 0
    local events = self:getEventList()
    if events ~= nil and SizeOfTable(events) ~= 0 then
        minid, maxid = events[SizeOfTable(events)].id, events[1].id
    end
    return minid, maxid
end
function platWarVoApi:getEventNum()
    local num = 0
    if type then
        local events = self:getEventList()
        num = SizeOfTable(events)
    end
    return num
end
--事件是否还有更多
function platWarVoApi:getEventHasMore()
    if self.eventHasMore ~= nil then
        return self.eventHasMore
    else
        return false
    end
end
function platWarVoApi:setEventHasMore(value)
    if value ~= nil then
        self.eventHasMore = value
    end
end

function platWarVoApi:buyBuff(buffID, callback)
    local status = self:checkStatus()
    if(status >= 30)then
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("plat_war_end"), 30)
        do return end
    end
    local function onRequestEnd(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if(sData.data)then
                self:updateInfo(sData.data)
                if(callback)then
                    callback()
                end
            end
        end
    end
    socketHelper:platWarBuyBuff(buffID, onRequestEnd)
end

-------------------以下发送跨平台信息--------------------
function platWarVoApi:initNoticeList(action)
    if self.httphost then
        local warId = self:getWarID()
        if warId then
            local httpUrl = self.httphost.."getmsg"
            local reqStr = "action="..action.."&bid="..warId
            if action >= 1 then
                reqStr = "action="..action.."&bid="..warId.."&platform="..base.serverPlatID
            end
            -- deviceHelper:luaPrint(httpUrl)
            -- deviceHelper:luaPrint(reqStr)
            local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
            -- deviceHelper:luaPrint(retStr)
            if(retStr ~= "")then
                local retData = G_Json.decode(retStr)
                if (retData["ret"] == 0 or retData["ret"] == "0") and retData.data then
                    require "luascript/script/game/gamemodel/platWar/platWarNoticeVo"
                    if retData.data.allmsg then
                        if self.noticeList == nil then
                            self.noticeList = {}
                        end
                        self.noticeList[action + 1] = {}
                        for k, v in pairs(retData.data.allmsg) do
                            local index = v[1]
                            -- local nType=v[3]+1
                            local nType = action + 1
                            local platform = v[4]
                            local contentType = 1
                            local zoneID = v[5]
                            local sender = v[6]
                            local senderName = v[7]
                            local params = v[8]
                            local time = v[9]
                            local content = ""
                            -- content=v[8]
                            
                            local param = {}
                            if params ~= nil and type(params) == "table" then
                                content = params.msg
                                param = params
                                param.level = params.level or 1
                                param.rank = params.rank or 1
                                param.power = params.power or 0
                                contentType = params.contentType or 1
                            end
                            if content and content ~= "" then
                                local color = G_ColorWhite
                                if action + 1 >= 2 then
                                    color = G_ColorBlue
                                end
                                -- local showMsg=content or ""
                                if contentType == 2 then
                                    content = getlocal(content)
                                end
                                local width = 500
                                local messageLabel = GetTTFLabelWrap(content, 26, CCSizeMake(width, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
                                local height = messageLabel:getContentSize().height + 5
                                height = height + 32--35
                                
                                local msgData = {width = width, height = height, color = color}
                                local nVo = platWarNoticeVo:new()
                                nVo:initWithData(index, action + 1, platform, contentType, content, sender, senderName, "", "", param, msgData, time)
                                table.insert(self.noticeList[action + 1], nVo)
                            end
                        end
                        local function sortFunc(a, b)
                            if a and b and a.time and b.time then
                                if a.time == b.time then
                                    if a.index and b.index then
                                        return a.index < b.index
                                    end
                                else
                                    return a.time < b.time
                                end
                            elseif a and b and a.index and b.index then
                                return a.index < b.index
                            end
                        end
                        -- local function sortFunc(a,b)
                        -- if a and b and a.time and b.time then
                        -- return a.time<b.time
                        -- end
                        -- end
                        table.sort(self.noticeList[action + 1], sortFunc)
                        self:setNoticeFlag(action + 1, 0)
                        self:setLastNoticeTime(base.serverTime, action + 1)
                    end
                    return true
                end
            end
        end
    end
    return false
end
function platWarVoApi:getNoticeList()
    if self.noticeList then
        return self.noticeList
    else
        return {}
    end
end
function platWarVoApi:getNoticeListByType(type)
    if type and self.noticeList and self.noticeList[type] then
        return self.noticeList[type]
    else
        return {}
    end
end
function platWarVoApi:getNoticeFlag(type)
    if type and self.noticeFlag then
        return self.noticeFlag[type]
    else
        return 1
    end
end
function platWarVoApi:setNoticeFlag(type, flag)
    if type and flag and self.noticeFlag then
        self.noticeFlag[type] = flag
    end
end
function platWarVoApi:sendPlatMsg(ntype, content, callback)
    if ntype == nil then
        ntype = 0
    end
    if content then
        local function sendmsgCallback(fn, data)
            local ret, sData = base:checkServerData(data)
            if ret == true then
                platWarVoApi:initNoticeList(ntype)
                if(callback)then
                    callback()
                end
            end
        end
        socketHelper:platwarSendmsg(ntype, content, sendmsgCallback)
    end
end
--是否显示军衔
function platWarVoApi:isShowRank(rank)
    if rank and rankCfg and rankCfg.chatShowRank and rank >= rankCfg.chatShowRank then
        return true
    else
        return false
    end
end

function platWarVoApi:getLastNoticeTime(index)
    return self.lastNoticeTime[index]
end
function platWarVoApi:setLastNoticeTime(lastNoticeTime, index)
    self.lastNoticeTime[index] = lastNoticeTime
end
function platWarVoApi:getLastNotice(showType)
    local list = self:getNoticeListByType(showType)
    if list then
        local num = SizeOfTable(list)
        if num > 0 then
            local noticeVo = list[num]
            if noticeVo then
                do return noticeVo end
            end
        end
    end
    return nil
end
-------------------以上发送跨平台信息--------------------

--当前处于哪个阶段
--return 0: 啥都没有的期, 不在战斗时间内, 为了防止当前时间不在后台传来的开始结束时间内而做的兼容
--return 10: 准备期
--return 20: 开战期
--return 30: 商店购买期
function platWarVoApi:checkStatus()
    if(self.startTime == nil or self.endTime == nil or base.serverTime < self.startTime or base.serverTime > self.endTime)then
        return 0
    elseif(base.serverTime < self.startTime + platWarCfg.preparetime * 3600)then
        return 10
    elseif(self.winnerID == nil and base.serverTime < self.startTime + platWarCfg.preparetime * 3600 + platWarCfg.battletime * 3600)then
        return 20
    else
        return 30
    end
end

function platWarVoApi:clear()
    self.warID = nil
    self.platList = nil
    self.playerList = nil
    self.selfPlayer = nil
    self.startTime = nil
    self.endTime = nil
    self.warInfoExpireTime = 0
    self.battleExpireTime = 0
    self.cityList = nil
    self.moraleList = nil
    self.buffList = nil
    self.troopList = nil
    self.troopDetailList = nil
    self.lineList = nil
    -- self.landtype={}
    self.commonList = nil
    self.rareList = nil
    self.troopInfo = nil
    self.point = 0
    self.donatePoint = 0
    self.pointDetail = {}
    self.detailExpireTime = 0
    self.curRound = 0
    self.nextBattleTime = 0
    self.winnerID = nil
    
    self.lastDonateTime = 0
    -- self.curMorale=0
    self.donateTroops = {}
    self.donateTroopsNum = {0, 0, 0}
    self.rankList = {{}, {}}
    self.rankExpireTime = {0, 0}
    self.myRank = {0, 0}
    self.myPoint = {0, 0}
    self.hasRewardRank = {}
    self.eventList = {}
    self.eventTotalNum = 0
    self.eventHasMore = false
    self:clearRankList()
    -- self.buyStatus=0
    
    self.lastSetLineTime = 0
    self.lastSetFleetTime = {0, 0, 0}
    
    self.shopFlag = -1
    self.pointDetailFlag = -1
    self.troopsFlag = -1
    self.reportList = {}
    self.reportNum = {}
    self.reportExpireTime = {0, 0}
    self.reportHasMore = {false, false}
    
    self.noticeList = {}
    self.httphost = nil
    self.noticeFlag = {-1, -1, -1}
    self.lastNoticeTime = {0, 0, 0}
end
