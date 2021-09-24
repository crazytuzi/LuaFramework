serverWarLocalVoApi =
{
    -- initFlag=nil,--是否初始化数据
    -- initBuildingFlag=false,--建筑头顶是否已经显示了图标
    serverWarlocalId = nil, --比赛id
    startTime = nil, --开始时间
    endTime = nil, --结束时间
    lastSetFleetTime = {0, 0, 0}, --上一次设置部队时间
    tankInfoFlag = -1, --是否获取部队信息
    
    -- --占领王城信息 {own_at=0,aid=1,name="",kingname=""},buff截止时间(下一场开战时间)，军团id，军团名称，团长名字
    -- ownCityInfo={},
    -- isOwnCity=false,--当前是否有军团占领王城
    -- applyRank={}, --投拍排行榜
    -- applyAllianceNum=0, --报名军团数
    selfApplyData = {}, --本军团报名信息 {join_at=1442779813}
    isCanBattle = nil, --本军团报名结束后能否参赛
    
    -- officeTab={},--官职数据，{j1=国王，j2=外交官，...，{奴隶1，奴隶2，...}}
    -- officeFlag=-1, --官职是否有变化标示
    -- officeLastStatus=-1,--官职数据上次请求所在的阶段
    -- slaveList={
    -- -- {uid=1000308,name="ddd",level=71,fight=1000,role=1,feat=100},
    -- }, --可以设置成奴隶的列表
    -- jobs={}, --自己的职位提供的buff类型列表
    -- cityLogList={}, --王城记录信息 {"commander":"Dssdf","date":"1443974400","aname":"Dddas","pic":1},{军团长,时间,时间军团名字,头像}
    reportList = {{}, {}}, --战报
    reportExpireTime = {0, 0}, --战报过期时间
    myReportList = {}, --自己战报
    isNewReport = {-1, -1}, --是否有新战报
    -- allFeatRank={}, --所有人功绩排行榜
    -- featRank={}, --功绩排行榜
    -- maxRankNum={0,0},--排行榜总人数
    -- initFeatRank={-1,-1},--战斗结束后是否初始化过功绩排行榜
    -- featRankPageNum=20,--功绩排行榜一页的数量
    -- myFeatRankData={}, --我自己的功绩排行榜数据
    -- allianceMemFeatList={},--自己军团成员的功绩数据,{{memId,featNum},{军团成员id，功绩数值}}
    registrationlist = {}, -- 报名清单
    
    funds = 0, --军饷
    point = 0, --商店积分
    shopList = {}, --商店列表
    shopFlag = -1, --是否初始化过商店信息
    pointDetail = {}, --积分明细
    pointDetailFlag = -1, --积分明细标示
    -- detailExpireTime=0,--积分明细过期时间
    across = {}, -- 对阵表信息
    everyStartBattleTimeTb = {}, -- 每一场战斗的开始时间
    allPerson = {ts = 0, person = {}, myRank = {}, count = 0}, -- ts 请求的时间戳，personList：排名列表
    ownPerson = {ts = 0, person = {}},
    personalListFlag = {0, 0}, -- 排行榜标志位（第一局，第二局结束时刷新） 全部
    ownPersonalListFlag = {0, 0}, -- 排行榜标志位（第一局，第二局结束时刷新） 个人
    socketHost = nil, --第二个Socket的地址和端口
    f_shopItems = nil, --商店列表
    teamTb = {}, --报名期前10名军团信息，（只有 第一、二名可报名）
    servers = {}, --所有参赛服
}

-- 计算每一场战斗的开始时间
function serverWarLocalVoApi:getEveryStartBattleTimeTb()
    local signuptime = serverWarLocalCfg.signuptime
    local battleTime = serverWarLocalCfg.battleTime
    local groupId = self:getGroupID()
    if groupId == nil then
        groupId = "b"
    end
    local startWarTime = serverWarLocalCfg.startWarTime[groupId]
    self.everyStartBattleTimeTb = {}
    for i = 1, battleTime do
        local startTime = self.startTime + serverWarLocalCfg.getSignUp + signuptime * 3600 * 24 + startWarTime[1] * 3600 + startWarTime[2] * 60 + (i - 1) * 3600 * 24
        table.insert(self.everyStartBattleTimeTb, startTime)
    end
    return self.everyStartBattleTimeTb
end

--初始化设置时间
function serverWarLocalVoApi:setTimeData(timeData)
    if timeData then
        if timeData.st and tonumber(timeData.st) then
            self.startTime = tonumber(timeData.st)
        end
        if timeData.et and tonumber(timeData.et) then
            self.endTime = tonumber(timeData.et)
        end
        --建筑图标是否显示
        local status = self:checkStatus()
        if(status and status > 0 and status <= 30)then
            if(buildings.allBuildings)then
                for k, v in pairs(buildings.allBuildings) do
                    if(v:getType() == 16)then
                        v:setSpecialIconVisible(6, true)
                        break
                    end
                end
            end
        end
    end
end

-- --是否初始化区域战数据
-- function serverWarLocalVoApi:getInitFlag()
-- return self.initFlag
-- end
-- function serverWarLocalVoApi:setInitFlag(initFlag)
-- self.initFlag=initFlag
-- end

--群雄争霸id
function serverWarLocalVoApi:getServerWarlocalId()
    return self.serverWarlocalId
end
function serverWarLocalVoApi:setServerWarlocalId(serverWarlocalId)
    self.serverWarlocalId = serverWarlocalId
end

-------------以下面板---------------
--弹出主面板
function serverWarLocalVoApi:showMainDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalDialog"
    local td = serverWarLocalDialog:new()
    local tbArr = {getlocal("serverWarLocal_sub_title1"), getlocal("help")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("serverWarLocal_title"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end
--弹出奖励面板
function serverWarLocalVoApi:showRewardDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalRewardDialog"
    local td = serverWarLocalRewardDialog:new()
    local tbArr = {getlocal("award"), getlocal("serverWarLocal_feat_exchange"), getlocal("serverwar_shop_tab3")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("award"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
    td:tabClick(0, false)
end
--弹出部队面板
function serverWarLocalVoApi:showTroopsDialog(layerNum)
    
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalTroopsDialog"
    local td = serverWarLocalTroopsDialog:new()
    local tbArr = {getlocal("local_war_troops_status"), getlocal("local_war_troops_preset")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("local_war_my_troops"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end
--弹出战报面板
function serverWarLocalVoApi:showReportDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalReportDialog"
    local td = serverWarLocalReportDialog:new()
    local tbArr = {getlocal("local_war_report_alliance"), getlocal("local_war_report_person")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("allianceWar_battleReport"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end
--弹出情报面板
function serverWarLocalVoApi:showInforDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalInforDialog"
    local td = serverWarLocalInforDialog:new()
    local tbArr = {getlocal("local_war_battleStatus"), getlocal("local_war_alliance_feat"), getlocal("serverWarLocal_map")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("serverWarLocal_information"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
    -- td:tabClick(0,false)
end
--弹出帮助面板
function serverWarLocalVoApi:showHelpDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalHelpDialog"
    local td = serverWarLocalHelpDialog:new()
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("help"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end
--弹出科技面板
function serverWarLocalVoApi:showBuffDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalBuffDialog"
    local td = serverWarLocalBuffDialog:new()
    local tbArr = {}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("alliance_skill"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end
--设置军饷面板
function serverWarLocalVoApi:showBattleFundsDialog(layerNum)
    smallDialog:showBattleFundsDialog("PanelHeaderPopup.png", CCSizeMake(550, 650), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), true, layerNum, getlocal("serverwarteam_funds_title"), nil, 1)
end
-------------以上面板---------------

-------------以下接口---------------
--初始化
function serverWarLocalVoApi:getInitData(callback, isShowTip, isRef)
    local function getInitCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data then
                if sData.data.matchId then
                    self:setServerWarlocalId(sData.data.matchId)
                end
                if sData.data.matchinfo then
                    self:setTeamTb(sData.data.matchinfo)
                end
                if sData.data.servers then
                    self:setThisServers(sData.data.servers)
                end
                if sData.data.areacrossinfo then
                    local initData = sData.data.areacrossinfo
                    if initData.gems then
                        self:setFunds(tonumber(initData.gems))
                    end
                    if initData.point then
                        self:setPoint(tonumber(initData.point))
                    end
                    if initData.info then
                        local troopsInfo = initData.info
                        if troopsInfo.ts then
                            self:setLastSetFleetTime(troopsInfo.ts)
                        end
                        if troopsInfo.troops then
                            local skinTb = troopsInfo.skin or {}
                            for m, n in pairs(troopsInfo.troops) do
                                local tType = 23 + m
                                if n and SizeOfTable(n) > 0 then
                                    for k, v in pairs(n) do
                                        if v and v[1] and v[2] then
                                            local tid = (tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
                                            local num = tonumber(v[2])
                                            tankVoApi:setTanksByType(tType, k, tid, num)
                                        end
                                    end
                                end
                                local tskin = skinTb[m] or {}
                                tankSkinVoApi:setTankSkinListByBattleType(tType, tskin)
                            end
                            self:setTankInfoFlag(1)
                        end
                        if troopsInfo.hero then
                            for k, v in pairs(troopsInfo.hero) do
                                if v and SizeOfTable(v) > 0 then
                                    heroVoApi:setServerWarLocalHeroList(k, v)
                                end
                            end
                        end
                        --AI部队数据处理
                        if troopsInfo.aitroops then
                            for k, v in pairs(troopsInfo.aitroops) do
                                if v and SizeOfTable(v) > 0 then
                                    AITroopsFleetVoApi:setServerWarLocalAITroopsList(k, v)
                                end
                            end
                        end
                        if troopsInfo.equip then
                            for k, v in pairs(troopsInfo.equip) do
                                local tType = 23 + tonumber(k)
                                emblemVoApi:setBattleEquip(tType, v)
                            end
                        end
                        if troopsInfo.plane then
                            for k, v in pairs(troopsInfo.plane) do
                                local tType = 23 + tonumber(k)
                                planeVoApi:setBattleEquip(tType, v)
                            end
                        end
                        if troopsInfo.ap then
                            for k, v in pairs(troopsInfo.ap) do
                                local tType = 23 + tonumber(k)
                                airShipVoApi:setBattleEquip(tType, v)
                            end
                        end
                        if troopsInfo.lm then
                            --商店数据
                            self:getShopInfo(nil, troopsInfo.lm)
                        end
                    end
                end
                -- local sData = '{"uid":2000246,"cmd":"areateamwar.crossinit","msg":"Success","ret":0,"zoneid":2,"data":{"et":"1447344000","across":{"over":1,"ainfo":{"3-15":["3服_15","1447249862",1],"1-1164":["1服_1164","1447249862",2],"1-1184":["1服_1184","1447249862",4],"1-1197":["1服_1197","1447249862",3]},"schedule":[{"a":[["1-1164"],["3-15"],["1-1184"],["1-1197"]],"b":{}},{"a":[["1-1184",880],["1-1197",180]],"b":[["3-15",100],["1-1164",100]]}]},"httphost":"http:\/\/192.168.8.213\/tank-server\/public\/index.php\/api\/areateamwar\/","matchId":"b134","st":"1446652800","areacrossinfo":{"usegems_at":0,"info":{},"pointlog":{"rc":{"add":[[1447253620,1000,9],[1447253629,1000,9]]}},"point":2000,"usegems":0,"bid":"","gems":0}},"ts":1447256106,"rnum":8}'
                -- sData=G_Json.decode(sData)
                if sData.data.across then
                    self.across = sData.data.across
                    local selfAlliance = allianceVoApi:getSelfAlliance()
                    if selfAlliance and selfAlliance.aid and sData.data.across.schedule then
                        local schedule = sData.data.across.schedule
                        if schedule and schedule[1] then
                            local zoneId = tostring(base.curZoneID)
                            local selfID = zoneId.."-"..selfAlliance.aid
                            -- print("selfID",selfID)
                            for k, v in pairs(schedule[1]) do
                                if v and SizeOfTable(v) > 0 then
                                    for m, n in pairs(v) do
                                        if n and SizeOfTable(n) > 0 then
                                            -- print("n~~~~~~~",n,n[1])
                                            if n and n[1] and n[1] == selfID then
                                                self:setIsCanBattle(true)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                
                if sData.data.httphost then
                    self.httphost = sData.data.httphost
                end
                if sData.data.host then
                    self.socketHost = sData.data.host
                end
                
                -- if sData.data.city then
                -- self:setOwnCityInfo(sData.data.city)
                -- self:setIsOwnCity(true)
                -- end
                -- if sData.data.info then
                -- self:setSelfApplyData(sData.data.info)
                -- end
                -- if sData.data.applycount then
                -- self:setApplyAllianceNum(tonumber(sData.data.applycount))
                -- end
                -- if sData.data.targetState and sData.data.targetState>0 then
                -- self:setIsCanBattle(true)
                -- else
                -- local selfAlliance=allianceVoApi:getSelfAlliance()
                -- local ownCityInfo=self:getOwnCityInfo()
                -- if ownCityInfo and ownCityInfo.aid and selfAlliance and tonumber(selfAlliance.aid)==tonumber(ownCityInfo.aid) then
                -- self:setIsCanBattle(true)
                -- end
                -- end
            end
            
            --建筑图标是否显示
            local status = self:checkStatus()
            if(status > 0 and status <= 30)then
                if(buildings.allBuildings)then
                    for k, v in pairs(buildings.allBuildings) do
                        if(v:getType() == 16)then
                            v:setSpecialIconVisible(6, true)
                            break
                        end
                    end
                end
            end
            
            if callback then
                callback()
            end
        end
    end
    -- print("~~~~~~~~~~~~~~~selfAlliance",selfAlliance)
    -- if isCheck==false then
    socketHelper:areateamwarCrossinit(getInitCallback, isRef)
    -- else
    -- local aid
    -- local selfAlliance=allianceVoApi:getSelfAlliance()
    -- if(selfAlliance~=nil)then
    -- -- aid=selfAlliance.aid
    -- -- socketHelper:areawarGetapply(aid,getApplyCallback)
    -- socketHelper:areateamwarCrossinit(getApplyCallback,isRef)
    -- elseif isShowTip==true then
    -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("local_war_no_alliance_tip"),30)
    -- end
    -- end
end
--获取报名信息
function serverWarLocalVoApi:getApplyData(callback)
    local function getApplyCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data then
                -- if sData.data.join_at then
                -- self:setSelfApplyData({apply_at=tonumber(sData.data.join_at)})
                -- end
                if sData.data.info and sData.data.info.apply_at then
                    self:setSelfApplyData({apply_at = tonumber(sData.data.info.apply_at)})
                end
            end
            if callback then
                callback()
            end
        end
    end
    if self:checkStatus() < 30 then
        if self:hadSignup() == true then
            if callback then
                callback()
            end
        else
            socketHelper:areateamwarGetapply(getApplyCallback)
        end
    else
        if callback then
            callback()
        end
    end
end
--报名，投拍
function serverWarLocalVoApi:bid(callback)
    -- if point then
    local function applyCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data and sData.data.point then
                local selfAlliance = allianceVoApi:getSelfAlliance()
                if selfAlliance then
                    selfAlliance.point = tonumber(sData.data.point)
                end
            end
            -- if sData.data and sData.data.join_at then
            -- self:setSelfApplyData({apply_at=tonumber(sData.data.join_at)})
            -- end
            if sData.data.info and sData.data.info.apply_at then
                self:setSelfApplyData({apply_at = tonumber(sData.data.info.apply_at)})
            end
            -- self:setApplyAllianceNum(self:getApplyAllianceNum()+1)
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("local_war_bid_success"), 30)
            if callback then
                callback()
            end
        end
    end
    local aid
    local selfAlliance = allianceVoApi:getSelfAlliance()
    if(selfAlliance ~= nil)then
        aid = selfAlliance.aid
        -- socketHelper:areawarApply(aid,point,applyCallback)
        socketHelper:areateamwarApply(aid, applyCallback)
    else
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("local_war_no_alliance_tip"), 30)
    end
    -- end
end

-- --获取部队信息
-- function serverWarLocalVoApi:getTankInfo(callback)
-- if self:getTankInfoFlag()==-1 then
-- local function getinfoCallback(fn,data)
-- local ret,sData=base:checkServerData(data)
-- if ret==true then
-- if sData.data and sData.data.troops then
-- for k,v in pairs(sData.data.troops) do
-- if v and v[1] and v[2] then
-- local tid=(tonumber(v[1]) or tonumber(RemoveFirstChar(v[1])))
-- local num=tonumber(v[2])
-- tankVoApi:setTanksByType(17,k,tid,num)
-- end
-- end
-- self:setTankInfoFlag(1)
-- end
-- if sData.data and sData.data.hero then
-- heroVoApi:setLocalWarHeroList(sData.data.hero)
-- end
-- if callback then
-- callback()
-- end
-- end
-- end
-- socketHelper:areawarGetinfo(getinfoCallback)
-- else
-- if callback then
-- callback()
-- end
-- end
-- end

--获取战报信息 type:1军团，2自己
function serverWarLocalVoApi:formatReportList(type, callback, isPage)
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
                if self.reportNum[type] > serverWarLocalCfg.reportMaxNum then
                    self.reportNum[type] = serverWarLocalCfg.reportMaxNum
                end
            end
            if sData.data.list then
                require "luascript/script/game/gamemodel/serverWarLocal/serverWarLocalReportVo"
                local minid, maxid = self:getMinAndMaxId(type)
                for k, v in pairs(sData.data.list) do
                    if v then
                        local id = tonumber(v[1])
                        if minid > 0 and maxid > 0 and id > minid and id < maxid then
                        else
                            local reportVo = serverWarLocalReportVo:new()
                            reportVo:initWithData(v)
                            table.insert(self.reportList[type], reportVo)
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
            local reportMaxNum = serverWarLocalCfg.reportMaxNum
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
            local warId = self:getServerWarlocalId()
            local httpUrl = self.httphost.."report"
            -- local reqStr="uid="..playerVoApi:getUid().."&bid="..warId.."&mineid="..mineid.."&maxeid="..maxeid.."&action="..type
            local reqStr = "bid="..warId.."&mineid="..mineid.."&maxeid="..maxeid.."&action="..type.."&zid="..base.curZoneID
            local selfAlliance = allianceVoApi:getSelfAlliance()
            if selfAlliance and selfAlliance.aid then
                reqStr = reqStr.."&aid="..selfAlliance.aid
                if type == 2 then
                    reqStr = reqStr.."&uid="..playerVoApi:getUid()
                end
                deviceHelper:luaPrint(httpUrl)
                deviceHelper:luaPrint(reqStr)
                local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
                deviceHelper:luaPrint(retStr)
                if(retStr ~= "")then
                    local retData = G_Json.decode(retStr)
                    if (retData["ret"] == 0 or retData["ret"] == "0") and retData.data then
                        reportCallback(retData)
                    end
                end
            end
        elseif base.serverTime > self:getReportExpireTime(type) then
            local warId = self:getServerWarlocalId()
            local httpUrl = self.httphost.."report"
            -- local reqStr="uid="..playerVoApi:getUid().."&bid="..warId.."&mineid=0&maxeid=0&action="..type
            local reqStr = "bid="..warId.."&mineid=0&maxeid=0&action="..type.."&zid="..base.curZoneID
            local selfAlliance = allianceVoApi:getSelfAlliance()
            if selfAlliance and selfAlliance.aid then
                reqStr = reqStr.."&aid="..selfAlliance.aid
                if type == 2 then
                    reqStr = reqStr.."&uid="..playerVoApi:getUid()
                end
                self.reportList[type] = {}
                deviceHelper:luaPrint(httpUrl)
                deviceHelper:luaPrint(reqStr)
                local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
                deviceHelper:luaPrint(retStr)
                local expireTime = self:getReportExpireTime(type)
                if(retStr ~= "")then
                    local retData = G_Json.decode(retStr)
                    if (retData["ret"] == 0 or retData["ret"] == "0") and retData.data then
                        reportCallback(retData)
                        
                        local expireTime = self:getReportExpireTime(type)
                        local status, lbColor, endTime = self:checkStatus()
                        if status == 21 or status == 22 or status == 23 then
                            expireTime = base.serverTime + 60
                        elseif status > 10 then
                            expireTime = endTime
                        else
                            expireTime = self.endTime
                        end
                        self:setReportExpireTime(type, expireTime)
                    else
                        expireTime = base.serverTime + 60
                    end
                else
                    expireTime = base.serverTime + 60
                end
            end
        end
    end
    if callback then
        callback()
    end
end

--获取战斗战报信息
function serverWarLocalVoApi:getBattleReport(type, id, callback)
    if type and id then
        local report
        local reportList = self:getReportList(type)
        for k, v in pairs(reportList) do
            if v and v.id == id and v.report and SizeOfTable(v.report) > 0 then
                report = v.report
            end
        end
        if report and SizeOfTable(report) > 0 then
            if callback then
                callback(report)
            end
        else
            if self.httphost then
                local warId = self:getServerWarlocalId()
                local httpUrl = self.httphost.."report"
                local reqStr = "bid="..warId.."&action=3&id="..id
                deviceHelper:luaPrint(httpUrl)
                deviceHelper:luaPrint(reqStr)
                local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
                deviceHelper:luaPrint(retStr)
                if(retStr ~= "")then
                    local retData = G_Json.decode(retStr)
                    if (retData["ret"] == 0 or retData["ret"] == "0") and retData.data and retData.data.report then
                        local report = retData.data.report
                        self:setBattleReport(type, id, report)
                        if callback then
                            callback(report)
                        end
                    end
                end
            end
        end
    end
end

-- --获取功绩排行榜
-- function serverWarLocalVoApi:updateRankList(type,page,callback)
-- require "luascript/script/game/gamemodel/localWar/localWarFeatRankVo"
-- if type==nil then
-- type=1
-- end
-- if page==nil then
-- page=1
-- end
-- local aid
-- local selfAlliance=allianceVoApi:getSelfAlliance()
-- if selfAlliance and type==2 then
-- aid=selfAlliance.aid
-- end
-- if type==2 and aid==nil then
-- do return end
-- end
-- local checkStatus=self:checkStatus()
-- if page==1 and (checkStatus==21 or (checkStatus~=21 and self:getInitFeatRank(type)==-1)) then
-- local function donatelistCallback(fn,data)
-- local ret,sData=base:checkServerData(data)
-- if ret==true then
-- if sData.data and sData.data.areaWarserver then
-- if sData.data.areaWarserver.donateRows then
-- local maxNum=tonumber(sData.data.areaWarserver.donateRows)
-- self:setMaxRankNum(type,maxNum)
-- end
-- local myRank=0
-- if sData.data.areaWarserver.myrank then
-- myRank=tonumber(sData.data.areaWarserver.myrank)
-- end
-- if sData.data.areaWarserver.myrows then
-- local myrows=sData.data.areaWarserver.myrows
-- if myrows and SizeOfTable(myrows)>0 then
-- local featRankVo=localWarFeatRankVo:new()
-- local rank=myRank
-- local name=myrows[1] or ""
-- local point=tonumber(myrows[2]) or 0
-- local power=tonumber(myrows[3]) or 0
-- local frData={rank=rank,name=name,power=power,point=point}
-- featRankVo:initWithData(frData)
-- self:setMyFeatRankData(type,featRankVo)
-- end
-- end
-- if sData.data.areaWarserver.donateList then
-- local donateList=sData.data.areaWarserver.donateList
-- if donateList and SizeOfTable(donateList)>0 then
-- self:clearFeatRank(type)
-- for k,v in pairs(donateList) do
-- if v then
-- local featRankVo=localWarFeatRankVo:new()
-- local rank=k
-- local name=v[1] or ""
-- local point=tonumber(v[2]) or 0
-- local power=tonumber(v[3]) or 0
-- local frData={rank=rank,name=name,power=power,point=point}
-- featRankVo:initWithData(frData)
-- if type==2 then
-- table.insert(self.featRank,featRankVo)
-- else
-- table.insert(self.allFeatRank,featRankVo)
-- end
-- end
-- end
-- local function sortFunc(a,b)
-- if a and b and a.rank and b.rank then
-- return a.rank<b.rank
-- end
-- end
-- if type==2 then
-- table.sort(self.featRank,sortFunc)
-- else
-- table.sort(self.allFeatRank,sortFunc)
-- end
-- end
-- end
-- end
-- if checkStatus==21 then
-- serverWarLocalVoApi:setInitFeatRank(type,-1)
-- else
-- serverWarLocalVoApi:setInitFeatRank(type,1)
-- end
-- if callback then
-- callback()
-- end
-- end
-- end
-- socketHelper:areawarDonatelist(aid,playerVoApi:getUid(),1,donatelistCallback)
-- elseif page>1 then
-- if self:getHasMoreRankNum(type)==true then
-- local function donatelistCallback(fn,data)
-- local ret,sData=base:checkServerData(data)
-- if ret==true then
-- if sData.data and sData.data.areaWarserver then
-- if sData.data.areaWarserver.donateRows then
-- local maxNum=tonumber(sData.data.areaWarserver.donateRows)
-- self:setMaxRankNum(type,maxNum)
-- end
-- local myRank=0
-- if sData.data.areaWarserver.myrank then
-- myRank=tonumber(sData.data.areaWarserver.myrank)
-- end
-- if sData.data.areaWarserver.myrows then
-- local myrows=sData.data.areaWarserver.myrows
-- if myrows and SizeOfTable(myrows)>0 then
-- local featRankVo=localWarFeatRankVo:new()
-- local rank=myRank
-- local name=myrows[1] or ""
-- local point=tonumber(myrows[2]) or 0
-- local power=tonumber(myrows[3]) or 0
-- local frData={rank=rank,name=name,power=power,point=point}
-- featRankVo:initWithData(frData)
-- self:setMyFeatRankData(type,featRankVo)
-- end
-- end
-- if sData.data.areaWarserver.donateList then
-- local donateList=sData.data.areaWarserver.donateList
-- if donateList and SizeOfTable(donateList)>0 then
-- for k,v in pairs(donateList) do
-- if v then
-- local featRankVo=localWarFeatRankVo:new()
-- local rank=k+(page-1)*self.featRankPageNum
-- local name=v[1] or ""
-- local point=tonumber(v[2]) or 0
-- local power=tonumber(v[3]) or 0
-- local frData={rank=rank,name=name,power=power,point=point}
-- featRankVo:initWithData(frData)
-- if type==2 then
-- table.insert(self.featRank,featRankVo)
-- else
-- table.insert(self.allFeatRank,featRankVo)
-- end
-- end
-- end
-- end
-- end
-- end
-- if callback then
-- callback()
-- end
-- end
-- end
-- socketHelper:areawarDonatelist(aid,playerVoApi:getUid(),page,donatelistCallback)
-- else
-- if callback then
-- callback()
-- end
-- end
-- else
-- if callback then
-- callback()
-- end
-- end
-- end

--购买物品 id：物品id
function serverWarLocalVoApi:buyItem(id, callback)
    local function buyHandler(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            local shopItems = self:getShopItems()
            for k, v in pairs(self.shopList) do
                if v.id == id then
                    self.shopList[k].num = self.shopList[k].num + 1
                end
            end
            local cfg = shopItems[id]
            local rewardTb = FormatItem(cfg.reward)
            local price = cfg.price
            self:setPoint(self:getPoint() - price)
            for k, v in pairs(rewardTb) do
                G_addPlayerAward(v.type, v.key, v.id, v.num, nil, true)
            end
            G_showRewardTip(rewardTb, true)
            if callback then
                callback()
            end
            
            local addData = {id, sData.ts}
            self:addPointDetail(addData, 2)
        end
    end
    if id then
        socketHelper:areateamwarBuy(id, buyHandler)
    end
end

--初始化积分明细
function serverWarLocalVoApi:formatPointDetail(callback)
    local function pointlogCallback(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData.data and sData.data.pointlog then
                -- local warId=self:getWarID()
                -- if warId and sData.data.pointlog[warId] then
                self:clearPointDetail()
                --商店数据
                local shopData = sData.data.pointlog.lm or {}
                if shopData then
                    self:getShopInfo(nil, shopData)
                end
                
                --积分明细
                require "luascript/script/game/gamemodel/serverWarLocal/serverWarLocalPointDetailVo"
                local record = sData.data.pointlog.rc or {}
                -- record.add={
                -- {1441548771,100,2,1},
                -- {1441548871,10,1,2},
                -- {1441549871,90,3},
                -- }
                if record and record.add and SizeOfTable(record.add) > 0 then
                    for k, v in pairs(record.add) do
                        local type, time, message, color = self:formatMessage(v, 1)
                        if type and time and message then
                            local vo = serverWarLocalPointDetailVo:new()
                            vo:initWithData(type, time, message, color)
                            table.insert(self.pointDetail, vo)
                        end
                    end
                end
                if record and record.buy and SizeOfTable(record.buy) > 0 then
                    for k, v in pairs(record.buy) do
                        local type, time, message, color = self:formatMessage(v, 2)
                        if time and message then
                            local vo = serverWarLocalPointDetailVo:new()
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
                -- end
            end
            self:setPointDetailFlag(1)
            if callback then
                callback()
            end
        end
    end
    if self:getPointDetailFlag() == -1 then
        socketHelper:areateamwarPointlog(pointlogCallback)
    else
        if callback then
            callback()
        end
    end
end
function serverWarLocalVoApi:formatMessage(data, mType)
    local type
    local time = 0
    local point = 0
    local targetName = ""
    local color = G_ColorGreen
    local itemId
    local params = {}
    local message = ""
    if mType == 1 then
        if data and SizeOfTable(data) > 0 then
            time = tonumber(data[1]) or 0
            point = tonumber(data[2])
            type = tonumber(data[3])
            if type == 9 then
                params = {point}
                message = getlocal("serverWarLocal_point_desc_1", params)
            else
                params = {type, point}
                message = getlocal("serverWarLocal_point_desc_2", params)
            end
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
function serverWarLocalVoApi:addPointDetail(data, mType)
    require "luascript/script/game/gamemodel/serverWarLocal/serverWarLocalPointDetailVo"
    local type, time, message, color = self:formatMessage(data, mType)
    local vo = serverWarLocalPointDetailVo:new()
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
        while SizeOfTable(self.pointDetail) > serverWarLocalCfg.militaryrank + 3 do
            table.remove(self.pointDetail, serverWarLocalCfg.militaryrank + 3 + 1)
        end
    end
end
--设置部队和军饷
function serverWarLocalVoApi:setFleetAndFunds(usegems, line, fleetinfo, hero, callback, clear, emblemID, planePos, aitroops, airshipId)
    local group = self:getGroupID()
    emblemID = emblemVoApi:getEquipIdForBattle(emblemID)
    if emblemID ~= -1 then
        socketHelper:areateamwarSetinfo(usegems, line, fleetinfo, hero, callback, clear, group, emblemID, planePos, aitroops, airshipId)
    end
end
-------------以上接口---------------
-------------以下商店和积分明细数据---------------
--商店积分
function serverWarLocalVoApi:getPoint()
    return self.point
end
function serverWarLocalVoApi:setPoint(point)
    self.point = point
end
--获取商店里面的道具列表
function serverWarLocalVoApi:getShopList()
    if (self.shopList) then
        return self.shopList
    end
    return {}
end
--根据id获取道具的配置
function serverWarLocalVoApi:getItemById(id)
    local item = nil
    if id then
        local shopList = self:getShopItems()
        if shopList and shopList[id] then
            item = shopList[id]
        end
    end
    return item
end
--初始化商店信息
function serverWarLocalVoApi:initShopInfo()
    require "luascript/script/game/gamemodel/serverWarLocal/serverWarLocalShopVo"
    local shopItems = self:getShopItems()
    self.shopList = {}
    for k, v in pairs(shopItems) do
        local vo = serverWarLocalShopVo:new()
        vo:initWithData(k, 0)
        table.insert(self.shopList, vo)
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
    table.sort(self.shopList, sortAsc)
end
--获取商店信息
--param callback: 获取之后的回调函数
function serverWarLocalVoApi:getShopInfo(callback, data)
    local shopFlag = self:getShopFlag()
    if shopFlag == -1 then
        self:initShopInfo()
        self:setShopFlag(1)
    end
    
    if data then
        if self.shopList == nil or SizeOfTable(self.shopList) == 0 then
            self:initShopInfo()
        end
        -- for k,v in pairs(data) do
        -- local key=string.sub(k,1,1)
        -- if key=="i" then
        -- for m,n in pairs(self.commonList) do
        -- if n and n.id==k then
        -- self.commonList[m].num=v
        -- end
        -- end
        -- elseif key=="a" then
        -- for m,n in pairs(self.rareList) do
        -- if n and n.id==k then
        -- self.rareList[m].num=v
        -- end
        -- end
        -- end
        -- end
        for k, v in pairs(data) do
            for m, n in pairs(self.shopList) do
                if n and n.id == k then
                    self.shopList[m].num = v
                end
            end
        end
    end
    
    if(callback)then
        callback()
    end
end
--普通道具配置
function serverWarLocalVoApi:getShopItems()
    if self.f_shopItems and next(self.f_shopItems) then
        do return self.f_shopItems end
    end
    self.f_shopItems = {}
    for k, v in pairs(serverWarLocalCfg.ShopItems) do
        local item = FormatItem(v.reward)[1]
        if bagVoApi:isRedAccessoryProp(item.key) == false or bagVoApi:isRedAccPropCanSell() == true then
            self.f_shopItems[k] = v
        end
    end
    return self.f_shopItems
end
function serverWarLocalVoApi:getShopFlag()
    return self.shopFlag
end
function serverWarLocalVoApi:setShopFlag(shopFlag)
    self.shopFlag = shopFlag
end
function serverWarLocalVoApi:getShopShowStatus()
    -- local isJoinBattle=self:isJoinBattle(false)
    local status = self:checkStatus()
    if status and status >= 30 then
        -- if isJoinBattle==true then
        -- return 2
        -- end
        return 1
    end
    return 0
end
--获取积分明细
function serverWarLocalVoApi:getPointDetail()
    if (self.pointDetail) then
        return self.pointDetail
    end
    return {}
end
function serverWarLocalVoApi:getTimeStr(time)
    local date = G_getDataTimeStr(time)
    return date
end
function serverWarLocalVoApi:getPointDetailFlag()
    return self.pointDetailFlag
end
function serverWarLocalVoApi:setPointDetailFlag(pointDetailFlag)
    self.pointDetailFlag = pointDetailFlag
end
-- function serverWarLocalVoApi:getDetailExpireTime()
-- return self.detailExpireTime
-- end
-- function serverWarLocalVoApi:setDetailExpireTime(detailExpireTime)
-- self.detailExpireTime=detailExpireTime
-- end

function serverWarLocalVoApi:clearPointDetail()
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
    -- self.detailExpireTime=0
end

-------------以上商店和积分明细数据数据---------------

--是否已经报过名
function serverWarLocalVoApi:hadSignup()
    local applyData = self:getSelfApplyData()
    if applyData and applyData.apply_at and applyData.apply_at > 0 then
        return true
    end
    return false
end

--是否可以报名，0可以，1未加入军团，2不是团长，3军团资金不足，4已经报过名了，5战斗名单生成中,6 通知期, 7 报名期没有报名资格
function serverWarLocalVoApi:canSignupStatus()
    local status = self:checkStatus()
    if status ~= 8 then
        local selfAlliance = allianceVoApi:getSelfAlliance()
        if selfAlliance then
            if self:inApplyTimeIsCan() then
                if self:hadSignup() == false then
                    local role = tonumber(selfAlliance.role or 0)
                    if role >= 1 then
                        if selfAlliance.point then
                            local point = selfAlliance.point
                            if point and point >= serverWarLocalCfg.minRegistrationFee then
                                do return 0 end
                            end
                        end
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverWarLocal_signup_fail_3"), 30)
                        do return 3 end
                    end
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverWarLocal_signup_fail_2"), 30)
                    do return 2 end
                end
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverWarLocal_signup_tip"), 30)
                do return 4 end
            end
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("allianceNotSingupTip"), 30)
            do return 7 end
        end
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("local_war_no_alliance_tip"), 30)
        do return 1 end
    end
    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("local_war_noticeTimeTip"), 30)
    do return 1 end
end

-- function serverWarLocalVoApi:getInitFeatRank(type)
-- if type then
-- return self.initFeatRank[type]
-- end
-- return -1
-- end
-- function serverWarLocalVoApi:setInitFeatRank(type,initFeatRank)
-- if type then
-- self.initFeatRank[type]=initFeatRank
-- end
-- end
-- function serverWarLocalVoApi:getMaxRankNum(type)
-- if type then
-- return self.maxRankNum[type]
-- end
-- return 0
-- end
-- function serverWarLocalVoApi:setMaxRankNum(type,num)
-- if type then
-- self.maxRankNum[type]=num
-- end
-- end
-- function serverWarLocalVoApi:getHasMoreRankNum(type)
-- if type then
-- local featRank=self:getFeatRank(type)
-- local num=SizeOfTable(featRank)
-- local maxRankNum=self:getMaxRankNum(type)
-- if num<maxRankNum then
-- return true
-- end
-- end
-- return false
-- end
-- function serverWarLocalVoApi:getMyFeatRankData(type)
-- if type then
-- return self.myFeatRankData[type]
-- end
-- return nil
-- end
-- function serverWarLocalVoApi:setMyFeatRankData(type,frData)
-- if type then
-- self.myFeatRankData[type]=frData
-- end
-- end
-- function serverWarLocalVoApi:clearFeatRank(type)
-- if type==2 then
-- self.featRank={}
-- else
-- self.allFeatRank={}
-- end
-- end
-- function serverWarLocalVoApi:getFeatRank(type)
-- if type==2 then
-- return self.featRank
-- else
-- return self.allFeatRank
-- end
-- end

-- function serverWarLocalVoApi:getCityLogList()
-- return self.cityLogList
-- end
-- function serverWarLocalVoApi:setCityLogList(cityLogList)
-- self.cityLogList=cityLogList
-- if self.cityLogList and SizeOfTable(self.cityLogList)>0 then
-- for k,v in pairs(self.cityLogList) do
-- if v then
-- v.index=k
-- end
-- end
-- local function sortFunc(a,b)
-- if a and b and a.index and b.index then
-- return a.index>b.index
-- end
-- end
-- table.sort(self.cityLogList,sortFunc)
-- end
-- end

function serverWarLocalVoApi:canJoinBattle()
    local selfAlliance = allianceVoApi:getSelfAlliance()
    if(selfAlliance ~= nil)then
        local joinTime = allianceVoApi:getJoinTime()
        local startTime = self:getStartTime()
        if joinTime and joinTime > 0 and joinTime < (startTime + serverWarLocalCfg.getSignUp + 86400 * serverWarLocalCfg.signuptime) then
            -- print("self:getIsCanBattle()",self:getIsCanBattle())
            local signuptime = self.startTime + serverWarLocalCfg.getSignUp + serverWarLocalCfg.signuptime * 3600 * 24
            if self:getIsCanBattle() == true then
                local group = self:getGroupID()
                -- print("group",group)
                if group then
                    -- print("base.serverTime",base.serverTime)
                    -- print("signuptime",signuptime)
                    if base.serverTime > signuptime and base.serverTime <= signuptime + 5 then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverWarLocal_can_not_join_battle4"), 30)
                        return false
                    else
                        return true
                    end
                else
                    if base.serverTime > signuptime and base.serverTime <= signuptime + 5 then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverWarLocal_can_not_join_battle4"), 30)
                    else
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverWarLocal_can_not_join_battle1"), 30)
                    end
                    return false
                end
            else
                if base.serverTime > signuptime and base.serverTime <= signuptime + 5 then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverWarLocal_can_not_join_battle4"), 30)
                else
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverWarLocal_can_not_join_battle1"), 30)
                end
                return false
            end
        else
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverWarLocal_can_not_join_battle2"), 30)
            return false
        end
    else
        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverWarLocal_no_alliance_tip"), 30)
        return false
    end
    return false
end

function serverWarLocalVoApi:getIsCanBattle()
    return self.isCanBattle
end
function serverWarLocalVoApi:setIsCanBattle(isCanBattle)
    self.isCanBattle = isCanBattle
end

function serverWarLocalVoApi:getSelfApplyData()
    return self.selfApplyData
end
function serverWarLocalVoApi:setSelfApplyData(selfApplyData)
    self.selfApplyData = selfApplyData
end

function serverWarLocalVoApi:getApplyAllianceNum()
    return self.applyAllianceNum
end
function serverWarLocalVoApi:setApplyAllianceNum(applyAllianceNum)
    self.applyAllianceNum = applyAllianceNum
end

function serverWarLocalVoApi:getApplyRank()
    return self.applyRank
end

---------------以下部队和军饷数据-----------------
--获取部队标示
function serverWarLocalVoApi:getTankInfoFlag()
    return self.tankInfoFlag
end
function serverWarLocalVoApi:setTankInfoFlag(flag)
    self.tankInfoFlag = flag
end
--上次设置部队时间
function serverWarLocalVoApi:getLastSetFleetTime(index)
    return self.lastSetFleetTime[index]
end
function serverWarLocalVoApi:setLastSetFleetTime(timeData)
    if timeData then
        self.lastSetFleetTime = timeData
    end
end
function serverWarLocalVoApi:setLastSetFleetTimeByIdx(index, time)
    if index then
        self.lastSetFleetTime[index] = time
    end
end
-- 0可以设置,1不能设置
function serverWarLocalVoApi:getSetFleetStatus()
    local status = self:checkStatus()
    if status >= 20 and status < 30 then
        return 0
    end
    return 1, getlocal("local_war_troops_cannot_set_fleet")
end
function serverWarLocalVoApi:getIsAllSetFleet()
    local canSet = self:getSetFleetStatus()
    if canSet == 0 then
        local isAllSet, isSetOne = tankVoApi:serverWarLocalIsAllSetFleet()
        if isSetOne == false then
            return false
        end
    end
    return true
end
-- 0 可以设置
-- serverWarLocal_cannot_set_funds1="比赛尚未开启，无法设置军饷！",
-- serverWarLocal_cannot_set_funds2="战斗即将开始，无法设置军饷！",
-- serverWarLocal_cannot_set_funds3="战斗进行中，无法设置军饷!",
-- serverWarLocal_cannot_set_funds4="战斗已结束，无法设置军饷！",可以提取军饷
function serverWarLocalVoApi:getSetFundsStatus()
    local status, lbColor, endTime = self:checkStatus()
    if status == 20 then
        if endTime and base.serverTime > endTime - serverWarLocalCfg.setTroopsLimit then
            return 2
        else
            return 0
        end
    elseif status == 21 or status == 22 then
        return 3
    elseif status >= 30 then
        return 4
    end
    return 1
end
-- --可以设置军饷
-- function serverWarLocalVoApi:canSetFunds()
-- local status=self:getSetFundsStatus()
-- if status and status==0 then
-- return true
-- end
-- return false
-- end

--军饷
function serverWarLocalVoApi:getFunds()
    return self.funds or 0
end
function serverWarLocalVoApi:setFunds(funds)
    self.funds = funds
end

--有军饷未提取，提取军饷
function serverWarLocalVoApi:extractFunds(layerNum)
    local usegems = self:getFunds()
    if usegems <= 0 then
        usegems = playerVoApi:getServerWarLocalUsegems()
    end
    if usegems and usegems > 0 then
        local function extractHandler()
            if G_checkClickEnable() == false then
                do
                    return
                end
            else
                base.setWaitTime = G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            
            local function extractCallback(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    local leftFunds = sData.data.salaries or 0
                    self:setFunds(0)
                    playerVoApi:setGems(playerVoApi:getGems() + leftFunds)
                    playerVoApi:setServerWarLocalUsegems(0)
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverwarteam_extract_success", {leftFunds}), 30)
                end
            end
            socketHelper:areateamwarTakegems(usegems, extractCallback)
        end
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("serverWarLocal_extract_left_funds", {getlocal("serverWarLocal_title")}), nil, layerNum + 1, nil, extractHandler)
    end
end

---------------以上部队和军饷数据-----------------
------------------以下战报数据-------------------

--战报列表
function serverWarLocalVoApi:getReportList(type)
    if type and self.reportList and self.reportList[type] then
        return self.reportList[type]
    else
        return {}
    end
end
function serverWarLocalVoApi:getReportById(type, id)
    local reports = self:getReportList(type)
    for k, v in pairs(reports) do
        if tostring(id) == tostring(v.id) then
            return v
        end
    end
    return {}
end
function serverWarLocalVoApi:getMinAndMaxId(type)
    local minid, maxid = 0, 0
    local reports = self:getReportList(type)
    if reports ~= nil and SizeOfTable(reports) ~= 0 then
        minid, maxid = reports[SizeOfTable(reports)].id, reports[1].id
    end
    return minid, maxid
end
function serverWarLocalVoApi:getReportNum(type)
    local num = 0
    if type then
        local reports = self:getReportList(type)
        num = SizeOfTable(reports)
    end
    return num
end
function serverWarLocalVoApi:getTotalNum(type)
    local num = 0
    if type and self.reportNum and self.reportNum[type] then
        num = tonumber(self.reportNum[type] or 0)
    end
    return num
end
--战报过期时间
function serverWarLocalVoApi:getReportExpireTime(type)
    if type and self.reportExpireTime and self.reportExpireTime[type] then
        return self.reportExpireTime[type]
    else
        return 0
    end
end
function serverWarLocalVoApi:setReportExpireTime(type, time)
    if type and time then
        if self.reportExpireTime == nil then
            self.reportExpireTime = {}
        end
        self.reportExpireTime[type] = time
    end
end
--战报列表是否还有更多
function serverWarLocalVoApi:getReportHasMore(type)
    if type and self.reportHasMore and self.reportHasMore[type] ~= nil then
        return self.reportHasMore[type]
    else
        return false
    end
end
function serverWarLocalVoApi:setReportHasMore(type, value)
    if type and value ~= nil then
        if self.reportHasMore == nil then
            self.reportHasMore = {}
        end
        self.reportHasMore[type] = value
    end
end

function serverWarLocalVoApi:getIsNewReport(type)
    if type then
        return self.isNewReport[type]
    end
    return - 1
end
function serverWarLocalVoApi:setIsNewReport(type, isNewReport)
    if type then
        self.isNewReport[type] = isNewReport
    end
end
function serverWarLocalVoApi:setBattleReport(type, id, report)
    if type and id and report and self.reportList and self.reportList[type] then
        for k, v in pairs(self.reportList[type]) do
            if v and v.id == id then
                v.report = report
            end
        end
    end
end

------------------以上战报数据-------------------

function serverWarLocalVoApi:getStartTime()
    return self.startTime
    -- --周几 1~7对应周一到周日
    -- local weekDay=G_getFormatWeekDay(base.serverTime)
    -- local startTime=G_getWeeTs(base.serverTime)-(weekDay-1)*86400
    -- return startTime
end

--判断是否可以进行军团操作
--type：1.退出，2.踢人
-- 报名期：
-- 成功报名后，团长不能解散军团
-- 备战期：
-- 有参战资格团长不能解散军团
-- 战斗期：
-- 团内所有人不能退出，团长和副团长不能踢人，团长不能解散军团
function serverWarLocalVoApi:canQuitAlliance(type)
    if base.serverWarLocalSwitch == 1 then
        local selfAlliance = allianceVoApi:getSelfAlliance()
        if selfAlliance == nil then
            do return false end
        end
        local checkStatus = self:checkStatus()
        if checkStatus == 0 then
            return true
        else
            if checkStatus >= 21 and checkStatus < 30 then
                local isCanBattle = self:getIsCanBattle()
                if isCanBattle == true then
                    if type == 1 then
                        if selfAlliance.role and tonumber(selfAlliance.role) == 2 then
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverWarLocal_operate_alliance_tip1"), 30)
                        else
                            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverWarLocal_operate_alliance_tip2"), 30)
                        end
                    else
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverWarLocal_operate_alliance_tip3"), 30)
                    end
                    return false
                end
            else
                local isLimit = 0
                if checkStatus == 10 then
                    local selfApplyData = self:getSelfApplyData()
                    if selfApplyData and SizeOfTable(selfApplyData) > 0 then
                        isLimit = 4
                    end
                elseif checkStatus == 20 then
                    local isCanBattle = self:getIsCanBattle()
                    if isCanBattle == true then
                        isLimit = 5
                    end
                    -- else
                    -- local selfAlliance=allianceVoApi:getSelfAlliance()
                    -- local ownCityInfo=self:getOwnCityInfo()
                    -- if ownCityInfo and ownCityInfo.aid and selfAlliance and tonumber(selfAlliance.aid)==tonumber(ownCityInfo.aid) then
                    -- isLimit=6
                    -- end
                end
                if isLimit > 0 and type == 1 and selfAlliance.role and tonumber(selfAlliance.role) == 2 then
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("serverWarLocal_operate_alliance_tip" .. (isLimit)), 30)
                    return false
                else
                    return true
                end
            end
        end
    else
        return true
    end
end

--当前处于哪个阶段
--return 0: 啥都没有的期, 不在战斗时间内, 为了防止当前时间不在后台传来的开始结束时间内而做的兼容
--return 8: 通知期
--return 10: 报名期
--return 20: 备战期
--return 21: A组战斗期
--return 23: B组战斗期
--return 24: 等待B组战斗结果
--return 22: 战斗结算期
--return 30: 商店购买期
function serverWarLocalVoApi:checkStatus()
    local color = G_ColorWhite
    -- do return 21,color,0 end
    if(self.startTime == nil or self.endTime == nil or base.serverTime < self.startTime or base.serverTime > self.endTime)then
        return 0, color, 0
        
    elseif base.serverTime < self.startTime + serverWarLocalCfg.getSignUp then
        local noticeTime = self.startTime + serverWarLocalCfg.getSignUp
        return 8, color, noticeTime
    elseif(base.serverTime < self.startTime + serverWarLocalCfg.getSignUp + serverWarLocalCfg.signuptime * 3600 * 24)then
        local signupTime = self.startTime + serverWarLocalCfg.getSignUp + serverWarLocalCfg.signuptime * 3600 * 24
        color = G_ColorYellowPro
        return 10, color, signupTime
    elseif self:isEndOftwoBattle() == false then
        color = G_ColorRed
        -- 当前分组
        local groupId = self:getGroupID()
        -- print("groupId------>>>>",groupId)
        -- 当前时间（减去了当天零点的时间戳，所以小于24小时）
        local weets = G_getWeeTs(base.serverTime)
        local agroupBattleSt = weets + serverWarLocalCfg.startWarTime["a"][1] * 3600 + serverWarLocalCfg.startWarTime["a"][2] * 60 --a组战斗开始时间
        local bgroupBattleSt = weets + serverWarLocalCfg.startWarTime["b"][1] * 3600 + serverWarLocalCfg.startWarTime["b"][2] * 60 --b组战斗开始时间
        local bgroupBattleEt = bgroupBattleSt + serverWarLocalCfg.maxBattleTime --b组战斗结束时间
        local settlementEt = bgroupBattleEt + 300 --本局结算时间
        if groupId == "a" then
            local battleEt = agroupBattleSt + serverWarLocalCfg.maxBattleTime
            if base.serverTime < agroupBattleSt then --a组备战期
                return 20, color, agroupBattleSt
            elseif base.serverTime <= battleEt then --a组战斗期
                return 21, color, battleEt
            elseif base.serverTime <= bgroupBattleEt then --等待b组战斗结束
                return 24, color, bgroupBattleEt
            elseif base.serverTime > settlementEt then --下一局a组备战期
                return 20, color, agroupBattleSt + 86400
            end
        elseif groupId == "b" then
            if base.serverTime < bgroupBattleSt then --b组备战期
                return 20, color, bgroupBattleSt
            elseif base.serverTime <= bgroupBattleEt then --b组战斗期
                return 23, color, bgroupBattleEt
            elseif base.serverTime > settlementEt then --下一局b组备战期
                return 20, color, bgroupBattleSt + 86400
            end
        elseif groupId == nil then
            local agroupBattleEt = agroupBattleSt + serverWarLocalCfg.maxBattleTime
            if base.serverTime < agroupBattleSt then
                return 20, color, agroupBattleSt
            elseif base.serverTime <= agroupBattleEt then
                return 21, color, agroupBattleEt
            elseif base.serverTime <= bgroupBattleEt then
                return 23, color, bgroupBattleEt
            elseif base.serverTime > settlementEt then
                return 20, color, agroupBattleSt + 86400
            end
        end
        if base.serverTime > bgroupBattleEt and base.serverTime <= settlementEt then
            return 22, color, settlementEt
        end
        return 0, color, 0
    else
        return 30, color, self.endTime
    end
end

function serverWarLocalVoApi:showAgainstRankDialog(layerNum)
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalAgainstRankDialog"
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalAgainstRankTab1"
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalAgainstRankTab2"
    require "luascript/script/game/scene/gamedialog/serverWarLocal/serverWarLocalAgainstRankTab3"
    
    local td = serverWarLocalAgainstRankDialog:new()
    local tbArr = {getlocal("serverWarLocal_against_rank_tab1"), getlocal("serverWarLocal_against_rank_tab2"), getlocal("serverWarLocal_against_rank_tab3")}
    local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("serverWarLocal_against_rank"), true, layerNum)
    sceneGame:addChild(dialog, layerNum)
end

-- 报名军团信息 报名清单
function serverWarLocalVoApi:getRegistrationlist(callback)
    local function getList(fn, data)
        local ret, sData = base:checkServerData(data)
        if ret == true then
            if sData and sData.data and sData.data.ranklist then
                self.registrationlist = sData.data.ranklist
                if callback then
                    callback(self.registrationlist)
                end
            end
        end
    end
    print("++++++self:checkStatus()", self:checkStatus())
    if SizeOfTable(self.registrationlist) == 0 and self:checkStatus() ~= 0 and self:checkStatus() ~= 10 then
        -- if SizeOfTable(self.registrationlist)==0  then
        socketHelper:getRegistrationlist(getList)
    else
        if callback then
            callback(self.registrationlist)
        end
    end
    
end

-- 得到对阵列表消息
-- schedule：两场的对阵列表
-- ainfo：对阵列表的映射信息
function serverWarLocalVoApi:getAcross()
    return self.across
end

-- 个人排行
-- fst:第一场开始时间 sst:第二场开始时间 btime:战斗时间 action :1 己方 2 全部 page: 全部排名的第几页
-- aid:如果是自己军团需要传自己军团aid callback1:page==1  callback2:page>1
function serverWarLocalVoApi:getPersonalList(page, callback)
    local httpUrl = self.httphost.."userranking"
    local everyStartBattleTimeTb = self:getEveryStartBattleTimeTb()
    local fst = everyStartBattleTimeTb[1]
    local sst = everyStartBattleTimeTb[2]
    local btime = serverWarLocalCfg.maxBattleTime
    local zoneid = base.curZoneID
    local bid = self.serverWarlocalId
    
    local reqStr = "fst="..fst.."&sst="..sst.."&btime="..btime.."&action="..2 .. "&bid=" .. bid
    reqStr = reqStr .. "&page=" .. page
    local _, flag = tankVoApi:serverWarLocalIsAllSetFleet()
    if flag then
        reqStr = reqStr .. "&uid=" .. playerVoApi:getUid()
    end
    
    local personalListFlag = self:getPersonalListFlag()
    local checkStatus = self:checkStatus()
    if checkStatus == 30 and personalListFlag[2] == 0 then
        personalListFlag[2] = 1
        self:setPersonalListFlag(personalListFlag)
    end
    if (checkStatus >= 20 and checkStatus < 30) and self:isEndOfoneBattle() and personalListFlag[1] == 0 then
        personalListFlag[1] = 1
        self:setPersonalListFlag(personalListFlag)
    end
    
    deviceHelper:luaPrint(httpUrl)
    deviceHelper:luaPrint(reqStr)
    local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
    print(retStr)
    -- allPerson={ts=0,person={}}, -- ts 请求的时间戳，personList：排名列表
    -- ownPerson={ts=0,person={}},
    if(retStr ~= "")then
        local retData = G_Json.decode(retStr)
        if(retData["ret"] == 0 or retData["ret"] == "0")then
            self.allPerson.ts = base.serverTime + 60
            self.allPerson.count = retData.data.count or 0
            if page == 1 then
                self.allPerson.person = retData.data.ranklist or {}
                self.allPerson.myRank = retData.data.myrank or {}
            else
                local rankList = retData.data.ranklist or {}
                for k, v in pairs(rankList) do
                    table.insert(self.allPerson.person, v)
                end
                
            end
            if callback then
                callback()
            end
        end
    end
    
end

function serverWarLocalVoApi:getOwnPersonList(callback)
    local httpUrl = self.httphost.."userranking"
    local everyStartBattleTimeTb = self:getEveryStartBattleTimeTb()
    local fst = everyStartBattleTimeTb[1]
    local sst = everyStartBattleTimeTb[2]
    local btime = serverWarLocalCfg.maxBattleTime
    local zoneid = base.curZoneID
    local bid = self.serverWarlocalId
    
    local reqStr = "fst="..fst.."&sst="..sst.."&btime="..btime.."&action="..1 .. "&bid=" .. bid
    local aid = playerVoApi:getPlayerAid() or 0
    --
    -- self.ownPersonalListFlag={0,0}
    local ownPersonalListFlag = self:getOwnPersonalListFlag()
    if self:checkStatus() == 30 and ownPersonalListFlag[2] == 0 then
        ownPersonalListFlag[2] = 1
        self:setOwnPersonalListFlag(ownPersonalListFlag)
    end
    if (self:checkStatus() >= 20 and self:checkStatus() < 30) and self:isEndOfoneBattle() and ownPersonalListFlag[1] == 0 then
        ownPersonalListFlag[1] = 1
        self:setOwnPersonalListFlag(ownPersonalListFlag)
    end
    
    if aid and tonumber(aid) > 0 then
        reqStr = reqStr .. "&aid=" .. aid
        local retStr = G_sendHttpRequestPost(httpUrl, reqStr)
        print(retStr)
        if(retStr ~= "")then
            local retData = G_Json.decode(retStr)
            if(retData["ret"] == 0 or retData["ret"] == "0")then
                self.ownPerson.ts = base.serverTime + 60
                self.ownPerson.person = retData.data.ranklist or {}
                if callback then
                    callback()
                end
            end
        end
    else
        if callback then
            callback()
        end
    end
    
end

function serverWarLocalVoApi:getAllPerson()
    return self.allPerson
end

function serverWarLocalVoApi:getOwnPerson()
    return self.ownPerson
end

-- true 结束 false 未结束
function serverWarLocalVoApi:isEndOfoneBattle()
    local schedule = self.across.schedule or {}
    if SizeOfTable(schedule) == 2 then
        if (base.serverTime > self.startTime + serverWarLocalCfg.getSignUp + serverWarLocalCfg.signuptime * 3600 * 24 + serverWarLocalCfg.startWarTime["b"][1] * 3600 + serverWarLocalCfg.startWarTime["b"][2] * 60 + serverWarLocalCfg.maxBattleTime + 300) then
            return true
        end
    end
    return false
end
-- true 结束 false 未结束
function serverWarLocalVoApi:isEndOftwoBattle()
    local over = 0
    if self and self.across and self.across.over then
        over = self.across.over
    end
    if tonumber(over) == 1 then
        return true
    end
    return false
end

function serverWarLocalVoApi:getGroupID()
    local groupID = nil
    local schedule = self.across.schedule or {}
    local batttleNum = 1
    if self:isEndOfoneBattle() or base.serverTime > self.startTime + serverWarLocalCfg.getSignUp + serverWarLocalCfg.signuptime * 3600 * 24 + (serverWarLocalCfg.battleTime - 1) * 3600 * 24 + serverWarLocalCfg.startWarTime["b"][1] * 3600 + serverWarLocalCfg.startWarTime["b"][2] * 60 + serverWarLocalCfg.maxBattleTime + 300 then
        batttleNum = 2
    end
    local dayTb = schedule[batttleNum] or {}
    if dayTb and SizeOfTable(dayTb) > 0 then
        for k, v in pairs(dayTb) do
            for kk, vv in pairs(v) do
                local arrTb = Split(vv[1], "-")
                local aid = playerVoApi:getPlayerAid() or 0
                local fid = base.curZoneID
                if tonumber(fid) == tonumber(arrTb[1]) and tonumber(aid) == tonumber(arrTb[2]) then
                    groupID = k
                end
            end
        end
    end
    return groupID
end

function serverWarLocalVoApi:getPersonalListFlag()
    return self.personalListFlag
end

function serverWarLocalVoApi:setPersonalListFlag(personalListFlag)
    self.personalListFlag = personalListFlag
end

function serverWarLocalVoApi:getOwnPersonalListFlag()
    return self.ownPersonalListFlag
end

function serverWarLocalVoApi:setOwnPersonalListFlag(ownPersonalListFlag)
    self.ownPersonalListFlag = ownPersonalListFlag
end

function serverWarLocalVoApi:getAllianceRankList()
    local across = self:getAcross()
    local ainfo = across.ainfo or {}
    local rankList = {}
    for k, v in pairs(ainfo) do
        local rankInfo = {}
        table.insert(rankInfo, k)
        table.insert(rankInfo, v[1]) -- 军团名字
        table.insert(rankInfo, v[3]) -- 军团排行
        local fight = v[4] or 0
        table.insert(rankInfo, fight) -- 军团战力
        local jifen = v[5] or 0
        table.insert(rankInfo, jifen) -- 军团jifen
        table.insert(rankList, rankInfo)
    end
    
    local function sortFunc(a, b)
        return tonumber(a[3]) < tonumber(b[3])
    end
    table.sort(rankList, sortFunc)
    return rankList
end

function serverWarLocalVoApi:getSettlementWaitingSprite(callback)
    local url = G_downloadUrl("function/swlocal_waiting.png")
    local function onLoadIcon(fn, sprite)
        if callback then
            callback(sprite)
        end
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    -- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    local webImage = LuaCCWebImage:createWithURL(url, onLoadIcon)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
end

function serverWarLocalVoApi:setTeamTb(newTeamTb)
    self.teamTb = newTeamTb
end
function serverWarLocalVoApi:getTeamTb()
    if SizeOfTable(self.teamTb) > 0 then
        return self.teamTb
    end
    return nil
end

function serverWarLocalVoApi:setThisServers(thisServers)
    self.servers = thisServers
end
function serverWarLocalVoApi:getservers()
    if SizeOfTable(self.servers) > 0 then
        return self.servers
    end
    return 0
end
function serverWarLocalVoApi:getThisServersTeamNum()
    local largeNum = serverWarLocalCfg.signupBattleNum
    local thisServers = serverWarLocalVoApi:getservers()
    if thisServers == 0 then
        print " ============ e r r o r : thisServers number is 0 ! ============ "
    end
    return largeNum / SizeOfTable(thisServers)
end

function serverWarLocalVoApi:inApplyTimeIsCan()
    local teamTb = self:getTeamTb()
    local ownAlliance = allianceVoApi:getSelfAlliance()
    if teamTb then
        local useNum = serverWarLocalVoApi:getThisServersTeamNum() + 1
        for k, v in pairs(teamTb) do
            if k < useNum and tonumber(v[1]) == tonumber(ownAlliance.aid) then
                print("tonumber(v[1]) == tonumber(ownAlliance.aid)", tonumber(v[1]), tonumber(ownAlliance.aid))
                return true
            end
        end
        
    end
    return false
end

function serverWarLocalVoApi:clear()
    -- if(localWarFightVoApi and localWarFightVoApi.clear)then
    -- localWarFightVoApi:clear()
    -- end
    -- self.initFlag=nil
    -- self.initBuildingFlag=false
    self.serverWarlocalId = nil
    self.startTime = nil
    self.endTime = nil
    self.lastSetFleetTime = {0, 0, 0}
    self.tankInfoFlag = -1
    
    -- self.ownCityInfo={}
    -- self.isOwnCity=false
    -- self.applyRank={}
    -- self.applyAllianceNum=0
    self.selfApplyData = {}
    self.isCanBattle = nil
    -- self.officeTab={}
    -- self.officeFlag=nil
    -- self.officeLastStatus=-1
    -- self.slaveList={}
    -- self.jobs={}
    -- self.cityLogList={}
    self.reportList = {{}, {}}
    self.reportExpireTime = {0, 0}
    self.myReportList = {}
    self.isNewReport = {-1, -1}
    self.registrationlist = {}
    -- self.allFeatRank={}
    -- self.featRank={}
    -- self.maxRankNum={0,0}
    -- self.initFeatRank={-1,-1}
    -- self.featRankPageNum=20
    -- self.myFeatRankData={}
    -- self.allianceMemFeatList={}
    self.funds = 0
    self.point = 0
    self.shopList = {}
    self.shopFlag = -1
    self.pointDetail = {}
    self.pointDetailFlag = -1
    -- self.detailExpireTime=0
    self.across = {}
    self.httphost = nil
    self.everyStartBattleTimeTb = {}
    self.allPerson = {ts = 0, person = {}, myRank = {}, count = 0} -- ts 请求的时间戳，personList：排名列表
    self.ownPerson = {ts = 0, person = {}}
    self.personalListFlag = {0, 0}
    self.ownPersonalListFlag = {0, 0} -- 排行榜标志位（第一局，第二局结束时刷新） 个人
    self.socketHost = nil
    self.f_shopItems = nil
    self.teamTb = {}
    self.servers = {}
end

