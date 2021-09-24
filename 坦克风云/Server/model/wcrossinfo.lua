--
-- 跨服战数据
-- User: luoning
-- Date: 14-9-28
-- Time: 下午2:48
--
function model_wcrossinfo(uid,data)

    local self = {
        uid = uid,
        --跨服战积分来源
        pointlog ={},
        -- 积分
        point=0;
        --押注信息
        bet = {},
        --shuju 
        info={},
        --排名信息
        rank = {},
        --errorCode 错误码不计入数据库
        errorCode = -1
    }

    --设置matchId
    --
    --params matchId string
    --params et 结束时间
    --
    --return boolean
    function self.setMatchId(matchId, et,jointype)
        if jointype~=0 then
            if type(self.pointlog["p"..jointype])~='table' then  self.pointlog["p"..jointype]={}  end
            if self.pointlog["p"..jointype][matchId]==nil then
                self.pointlog["p"..jointype][matchId] = {et=et}
            end
            if type(self.bet["p"..jointype])~='table' then  self.bet["p"..jointype]={}  end
            if not self.bet["p"..jointype][matchId] then
                self.bet["p"..jointype][matchId] = {et=et}
            end
        end
        if type(self.pointlog["p"..0])~='table' then  self.pointlog["p"..0]={}  end
        if not self.pointlog["p"..0][matchId] then
            self.pointlog["p"..0][matchId] = {et=et}
        end
    end

    function self.bind(data)
        if type(data) ~= 'table' then
            return false
        end

        for k,v in pairs (self) do
            local vType = type(v)
            if vType~="function" and k~='errorCode' then
                if data[k] == nil then return false end
                if vType == 'number' then
                    self[k] = tonumber(data[k]) or data[k]
                else
                    self[k] = data[k]
                end
            end
        end
        self.refresh()
        return true
    end

     --刷新数据
    function self.refresh()
        local nowTime = getClientTs()
        --记录保留时间(3天)
        local recordTime = 3*24*3600
        --删除过期的比赛数据
        if next(self.pointlog) then
            for jp,jv in pairs(self.pointlog) do
                if jp~='del' then --舰队要查看部队过滤掉
                    for k,v in pairs(jv) do
                        if v['et']==nil or tonumber(v['et']) + recordTime < nowTime   then
                            self.pointlog[jp][k] = nil
                        end
                    end
                end
            end
        end
        --删除过期的押注数据
        if next(self.bet) then
            for mk,iv in pairs(self.bet) do
                for k,v in pairs(iv) do
                    if v['et'] + recordTime < nowTime then
                        self.bet[mk][k] = nil
                    end
                end
                
            end
        end
    end

    --下注
    --
    --params mObj
    --params matchId 详细信息Id
    --params detailId 详细比赛Id
    --params joinUid  押注的用户
    --params crossCfg 跨服战配置文件
    --params st 比赛开始时间
    --
    --return boolean
    function self.userBet(mObj, matchId, detailId, joinUid, crossCfg,jointype)

        local Round=mObj.getEliminateCurrentRound()+1
        if Round>6 then
            Round=6
        end
        local cfg, type = self.getBetCfg(crossCfg, st, nil,Round,jointype)
        if not self.bet["p"..jointype][matchId] then
            self.bet["p"..jointype][matchId] = {}
        end
        if not self.bet["p"..jointype][matchId][detailId] then
            self.bet["p"..jointype][matchId][detailId] = {uid=joinUid,count=0,isGet=0,type=type}
        end
        --检查追加的是否为押注的同一个参赛用户
        if self.bet["p"..jointype][matchId][detailId]['uid'] ~= joinUid then
            self.errorCode = -20008
            return false
        end
        self.bet["p"..jointype][matchId][detailId]['count'] = self.bet["p"..jointype][matchId][detailId]['count'] + 1
        return true, cfg.betGem[self.bet["p"..jointype][matchId][detailId]['count']]
    end

    --领取下注奖励
    --
    --params mObj
    --params matchId 详细信息Id
    --params detailId 详细比赛Id
    --params crossCfg 跨服战配置文件
    --params st 比赛开始时间
    --
    --return boolean
    function self.getBetReward(mObj, matchId, detailId, crossCfg,jointype)


        if not self.bet["p"..jointype][matchId] then
            self.errorCode = -22014
            return false
        end
        if not self.bet["p"..jointype][matchId][detailId] then
            self.errorCode = -22014
            return false
        end

        if self.bet["p"..jointype][matchId][detailId]['isGet'] == 1 then
            self.errorCode = -22011
            return false
        end
        --标识已经领奖
        self.bet["p"..jointype][matchId][detailId]['isGet'] = 1
        local type = self.bet["p"..jointype][matchId][detailId]['type']
        local count = self.bet["p"..jointype][matchId][detailId]['count']
        local Round=mObj.getEliminateCurrentRound()+1
        if Round>6 then
            Round=6
        end
        local cfg = self.getBetCfg(crossCfg, st, type, Round,jointype)

        local point = cfg.failer[count]
        if mObj.isWinMatch(self.bet["p"..jointype][matchId][detailId]['uid'], detailId,jointype) then
            point = cfg.winner[count]
        end

        if self.addPoint(matchId, point, detailId,jointype) then
            return true
        end
        return false
    end

    --是否允许下注
    --
    --params mObj
    --params matchId 详细信息Id
    --params detailId 详细比赛Id
    --params crossCfg 跨服战配置文件
    --params st 比赛开始时间
    --
    --return boolean
    function self.allowBet(mObj, matchId, detailId, crossCfg,jointype )
        local Round=mObj.getEliminateCurrentRound()+1
        if Round>6 then
            Round=6
        end
        local cfg = self.getBetCfg(crossCfg, st, nil,Round,jointype)

        if not detailId or not cfg then
            self.errorCode = -22015
            return false
        end

        if not self.bet["p"..jointype][matchId] then
            return true
        end

        --检查压的是否为同一场比赛
        local checkSameMatch = function(dId, hasDId)
            local dIdTable = dId:split('_')
            for i, v in pairs(dIdTable) do
                dIdTable[i] = tonumber(v) or v
            end
            local hasDIdTable = hasDId:split('_')
            for i, v in pairs(hasDIdTable) do
                hasDIdTable[i] = tonumber(v) or v
            end
            if dIdTable[3] == hasDIdTable[3]
                    and dIdTable[4] == hasDIdTable[4]
                    and dIdTable[5] == hasDIdTable[5]
                    and dIdTable[6] ~= hasDIdTable[6]
            then
                return false
            end
            return true
        end

        for hasId,_ in pairs(self.bet["p"..jointype][matchId]) do
            if hasId ~= 'et' then
                if not checkSameMatch(detailId, hasId) then
                    self.errorCode = -20012
                    return false
                end
            end
        end
        --没有押注过
        if not self.bet["p"..jointype][matchId][detailId] then
            return true
        end

        if self.bet[matchId] and self.bet["p"..jointype][detailId] then
            if self.bet[matchId][detailId]['count'] >= #cfg['betGem'] then
                self.errorCode = -20013
                return false
            end
        end

        return true
    end

    --得到积分配置信息
    --
    --params cfg
    --params st
    --
    --return table
    function self.getBetCfg(cfg, st, sType, round,jointype)
    
        if not sType then
            if round < 1 then
                return false
            end
            sType = cfg["betStyle4Round"..jointype][round]
        end



        --配置Id
        local res = {}
        if sType == 1 then
            res['betTs'] = cfg['betTs_a']
        else
            res['betTs'] = cfg['betTs_b']
        end
        res['betGem'] = cfg['betGem_'..sType]
        res['winner'] = cfg['winner_'..sType]
        res['failer'] = cfg['failer_'..sType]
        return res, sType
    end

    --刷新用户获取比赛积分信息
    --
    --params object matchObj
    --
    --return boolean
    function self.bindJoinPoint(matchObj, matchId,jointype)
        --记录积分来源(押注积分0，参赛积分1)mt
        if not self.pointlog["p"..jointype][matchId]['rc'] then
            self.pointlog["p"..jointype][matchId]['rc'] = {}
        end
        if not self.pointlog["p"..jointype][matchId]['rc']['join'] then
            self.pointlog["p"..jointype][matchId]['rc']['join'] = {}
        end
        local point, join, tmpAddDid = matchObj.addJoinUserPoint(self.uid, self.pointlog["p"..jointype][matchId]['rc']['join'],jointype)
        --记录积分信息
        if not self.pointlog["p"..jointype][matchId]['rc'] then
            self.pointlogp["p"..jointype][matchId]['rc'] = {}
        end
        if not self.pointlog["p"..jointype][matchId]['rc']['add'] then
            self.pointlog["p"..jointype][matchId]['rc']['add'] = {}
        end
        --ptb:p(tmpAddDid)
        if next(tmpAddDid) then
            for i, v in pairs(tmpAddDid) do
                table.insert(self.pointlog["p"..jointype][matchId]['rc']['add'], v)
            end
        end

        self.addJoinPoint(matchId, point, join,jointype)
    end

    --得到积分信息
    --
    --params matchId
    --
    --return table
    function self.getPointInfo(matchId)
        local data = self.toArray()
        --[[
        if  self.point[matchId] and
            self.point[matchId]['rc'] and
            self.point[matchId]['rc']['buy'] then
            data.point[matchId]['rc']['buy'] = nil
        end
        if  self.point[matchId] and
                self.point[matchId]['rc'] and
                self.point[matchId]['rc']['add'] then
            data.point[matchId]['rc']['add'] = nil
        end--]]
        --data['battle'] = nil
        return data
    end

    --得到积分记录
    --
    --return table
    self.getPointRecord = function(matchId)

        local formatData = function(res)
            local resData = {add={}, buy={}}
            local allData = {}
            for _, v in pairs(res) do
                for _, vv in pairs(v) do
                    table.insert(allData, vv)
                end
            end
            local length = #allData
            for i=1, length do
                for ii=1, length - i do
                    local time1 = #allData[ii] > 2 and allData[ii][4] or allData[ii][2]
                    local time2 = #allData[ii + 1] > 2 and allData[ii + 1][4] or allData[ii + 1][2]
                    if time1 < time2 then
                        allData[ii], allData[ii+1] = allData[ii+1], allData[ii]
                    end
                end
            end
            for i=1, 50 do
                if allData[i] then
                    if #(allData[i]) == 2 then
                        table.insert(resData.buy, allData[i])
                    else
                        table.insert(resData.add, allData[i])
                    end
                end
            end
            return resData
        end

        local res = {buy={},add={}}
        local data = self.toArray()
        local nowTime = getClientTs()
        local p0=self.pointlog["p0"] or {}
        if  p0[matchId] and
                p0[matchId]['rc'] and
                p0[matchId]['rc']['buy'] then
            res.buy = p0[matchId]['rc']['buy']
        end
        local p1=self.pointlog["p1"] or {}
        if  p1[matchId] and
                p1[matchId]['rc'] and
                p1[matchId]['rc']['add'] then
            for i,v in pairs(p1[matchId]['rc']['add']) do
                if v[4] <= nowTime  then
                    if v[2]==0 then
                        v[5]=1
                    end
                    table.insert(res.add,v)
                end
            end
        end
        local p2=self.pointlog["p2"] or {}
        if  p2[matchId] and
                p2[matchId]['rc'] and
                p2[matchId]['rc']['add'] then
            for i,v in pairs(p2[matchId]['rc']['add']) do
                if v[4] <= nowTime  then
                    if  v[2]==0  then
                        v[5]=2
                    end
                    
                    table.insert(res.add, v)
                end
            end
        end
        if #(res.buy) + #(res.add) > 50 then
            res = formatData(res)
        end
        return res
    end

    --后台直接修改积分(不记录)
    function self.addAdminPoint(point)
        self.point = self.point + point
    end

    --参赛用户增加积分
    --
    --params matchId    比赛Id
    --params point
    --params join 所有已经领奖的did
    --
    --return boolean
    function self.addJoinPoint(matchId, point, join,jointype)

        if not self.pointlog["p"..jointype][matchId] then
            self.pointlog["p"..jointype][matchId] = {}
        end
        if not self.pointlog["p"..jointype][matchId]['nm'] then
            self.pointlog["p"..jointype][matchId]['nm'] = 0
        end
        self.pointlog["p"..jointype][matchId]['nm'] = self.pointlog["p"..jointype][matchId]['nm'] + point
        self.point = self.point + point

        --记录积分来源(押注积分0，参赛积分1)mt
        if not self.pointlog["p"..jointype][matchId]['rc'] then
            self.pointlog["p"..jointype][matchId]['rc'] = {}
        end
        if not self.pointlog["p"..jointype][matchId]['rc']['join'] then
            self.pointlog["p"..jointype][matchId]['rc']['join'] = {}
        end
        self.pointlog["p"..jointype][matchId]['rc']['join'] = join
        return true
    end

    --增加排名积分
    --
    --params matchId 比赛Id
    --params point 积分数量
    --params detailId 小Id
    --
    --return boolean
    function self.addRankingPoint(matchId, point, ranking,jointype)

        if not self.pointlog["p"..jointype][matchId] then
            self.pointlog["p"..jointype][matchId] = {}
        end
        if not self.pointlog["p"..jointype][matchId]['nm'] then
            self.pointlog["p"..jointype][matchId]['nm'] = 0
        end
        --已经领取排名奖励
        if self.pointlog["p"..jointype][matchId]['rank'] then
            self.errorcode = -20018
            return false
        end

        self.point= self.point + point
        --标识已经领取排名奖励
        self.pointlog["p"..jointype][matchId]['rank'] = {ranking, point}

        --记录积分来源(押注积分0，参赛积分1)mt
        if not self.pointlog["p"..jointype][matchId]['rc'] then
            self.pointlog["p"..jointype][matchId]['rc'] = {}
        end
        if not self.pointlog["p"..jointype][matchId]['rc']['add'] then
            self.pointlog["p"..jointype][matchId]['rc']['add'] = {}
        end
        table.insert(self.pointlog["p"..jointype][matchId]['rc']['add'], {point, 2, 'r', getClientTs(), ranking})
        return true
    end

    --记录排名信息，聊天称号用
    --
    --params mObjs
    --params ranking
    --
    --return boolean
    function self.recordRanking(mObj, ranking)
        if ranking <=0 or ranking > 3 then
            return false
        end
        local checkAdd = function(mId, data)
            for _,v in pairs(data) do
                if v[1] == mId then
                    return false
                end
            end
            return true
        end
        if not checkAdd(mObj.base.matchId, self.rank) then
            return false
        end
        local cfg = getConfig('serverWarPersonalCfg')
        table.insert(self.rank, {mObj.base.matchId, ranking, mObj.baseinfo[2][#(mObj.baseinfo[2])][1] + cfg.battleTime * 3})
        if #self.rank > 40 then
            table.remove(self.rank, 1)
        end
    end

    --得到排名信息
    --
    --return table
    function self.getRecordRanking()
        local result = 0
        local startTime = 0
        local length = #self.rank
        local nowTime = getClientTs()
        local cfg = getConfig('serverWarPersonalCfg')
        for i=1, length do
            if self.rank[length - i + 1] then
                local timeCfg = cfg.rankReward[self.rank[length - i + 1][2]]['lastTime']
                if (timeCfg[1] + timeCfg[2]) * 24 * 3600 + self.rank[length - i + 1][3] >= nowTime then
                    result = self.rank[length - i + 1][2]
                    startTime = self.rank[length - i + 1][3]
                    break
                end
            end
        end
        return result, startTime
    end

    --增加积分
    --
    --params matchId 比赛Id
    --params point 积分数量
    --params detailId 小Id
    --
    --return boolean
    function self.addPoint(matchId, point, detailId,jointype)

        if not self.pointlog["p"..jointype][matchId] then
            self.pointlog[matchId] = {}
        end
        if not self.pointlog["p"..jointype][matchId]['nm'] then
            self.pointlog["p"..jointype][matchId]['nm'] = 0
        end
        self.pointlog["p"..jointype][matchId]['nm'] = self.pointlog["p"..jointype][matchId]['nm'] + point
        self.point=self.point + point

        --记录积分来源(押注积分0，参赛积分1)mt
        if not self.pointlog["p"..jointype][matchId]['rc'] then
            self.pointlog["p"..jointype][matchId]['rc'] = {}
        end
        if not self.pointlog["p"..jointype][matchId]['rc']['add'] then
            self.pointlog["p"..jointype][matchId]['rc']['add'] = {}
        end
        table.insert(self.pointlog["p"..jointype][matchId]['rc']['add'], {point, 0, detailId, getClientTs()})
        return true
    end


    function self.addScorePoint(point)
        self.point=self.point + point

    end

    --消费积分
    --
    --params matchId 比赛Id
    --params point 消费的积分
    --params tId 配置Id
    --params limitNum 限制数量
    --params rewardType 道具类别
    --params rewardNum 道具数量
    --params sType 0普通商店， 1精品商店
    --
    --return boolen
    function self.usePoint(matchId, point, tId, limitNum, rewardType, rewardNum, sType, jointype)
        --消费积分
        if type(self.pointlog["p"..jointype])~="table" then self.pointlog["p"..jointype]={}  end
        if self.point < point then
            self.errorCode = -20014
            return false
        end
        self.point = self.point - point

        --验证购买数量
        if not self.pointlog["p"..jointype][matchId]['lm'] then
            self.pointlog["p"..jointype][matchId]['lm'] = {}
        end
        if not self.pointlog["p"..jointype][matchId]['lm'][tId] then
            self.pointlog["p"..jointype][matchId]['lm'][tId] = 0
        end
        if self.pointlog["p"..jointype][matchId]['lm'][tId] >= limitNum then
            self.errorCode = -20015
            return false
        end
        self.pointlog["p"..jointype][matchId]['lm'][tId] = self.pointlog["p"..jointype][matchId]['lm'][tId] + 1
        takeReward(self.uid, {[rewardType]=rewardNum})
        --记录消费信息
        if not self.pointlog["p"..jointype][matchId]['rc'] then
            self.pointlog["p"..jointype][matchId]['rc'] = {}
        end
        if not self.pointlog["p"..jointype][matchId]['rc']['buy'] then
            self.pointlog["p"..jointype][matchId]['rc']['buy'] = {}
        end
        table.insert(self.pointlog["p"..jointype][matchId]['rc']['buy'], {tId, getClientTs()})
        return true
    end


    -- 获取第一名
    function self.getFirst()
        local key ="z" .. getZoneId() ..".worldwar.winer."..1
        local redis = getRedis()
        return json.decode(redis:get(key))
    end

    -- 发送数据到第三台整合

    function self.getlastdata(aName,fleetInfo1,fleetInfo2,fleetInfo3,heros)


        local uobjs = getUserObjs(self.uid)
        local mUserinfo = uobjs.getModel('userinfo')
        local mToops = uobjs.getModel('troops')
        local params = {}
    
        local sevCfg=getConfig("serverWarPersonalCfg")
        local fleetInfo=sevCfg.troops
        if type(self.battle.flag)~='table' then  self.battle.flag={1,1,1} end
        if (type(fleetInfo1)=='table' and not next(fleetInfo1)) or fleetInfo1==nil then
            fleetInfo1=fleetInfo
            self.battle.flag[1]=1
        end
        if (type(fleetInfo2)=='table' and not next(fleetInfo2)) or fleetInfo2 ==nil then
            fleetInfo2=fleetInfo
            self.battle.flag[2]=1
        end
        if (type(fleetInfo3)=='table' and not next(fleetInfo3))  or fleetInfo3==nil then
            fleetInfo3=fleetInfo
            self.battle.flag[3]=1
        end


        local hero1 =heros[1]
        local hero2 =heros[2]   
        local hero3 =heros[3]  

        local fleetInfo1,accessoryEffectValue1,herosinfo1 =mToops.initFleetAttribute(fleetInfo1,12,{hero=hero1})
        local fleetInfo2,accessoryEffectValue2,herosinfo2 =mToops.initFleetAttribute(fleetInfo2,12,{hero=hero2})
        local fleetInfo3,accessoryEffectValue3,herosinfo3 =mToops.initFleetAttribute(fleetInfo3,12,{hero=hero3})
            
        --uid 
        params[1]=self.uid
        --name
        params[2]=mUserinfo.nickname
        --服务器ID
        params[3]=getZoneId()
        -- 公会名称
        params[4] =aName
        -- 头像(pic)
        params[5]=mUserinfo.pic
        -- 军衔
        params[6]=mUserinfo.rank
        -- 等级
        params[7]=mUserinfo.level
        --战斗力
        params[8]=mUserinfo.fc
        --坦克数据 
        params[9]={{},{},{}}
        
        --st 
        require "model.matches"


        local mMatches = model_matches(true)

        local info =mMatches.base
        --st
        params[10]=tonumber(info.st)+sevCfg.preparetime*24*3600
        self.battle.st=tonumber(info.st)
        --et
        params[11]=tonumber(info.et)
        -- 战斗id
        params[12]=info.matchId
        --跨服所有服
        params[13]=json.decode(info.servers)
        --排名

        local members=json.decode(info.info)
        local rank=0
        if type(members)=='table' then
            for k,v in pairs(members) do
                if tonumber(v[1])==self.uid then
                    rank=k
                end
            end
        end 
        params[14]=rank
        local keys={}
        for i=1,6 do
            if type(fleetInfo1[i])=='table' and next(fleetInfo1[i]) then
                local isHero = false
                for k,v in pairs (fleetInfo1[i]) do   
                    table.insert(keys,k)
                    if k == 'hero' then isHero = true end
                end 
                if not isHero then table.insert(keys,'hero') end
                break
            end
        end
    
        params[9][1]=keys
        params[9][2]={}
        params[9][3]={}
        table.insert(params[9][3],herosinfo1[1])
        table.insert(params[9][3],herosinfo2[1])
        table.insert(params[9][3],herosinfo3[1])
        local troops = {}
        for i=1,3 do
            for k,v in pairs(keys) do
                local  attfleetInfo = {}
                if(i==1) then
                    attfleetInfo=fleetInfo1
                end
                if(i==2) then
                    attfleetInfo=fleetInfo2
                end
                if(i==3) then
                     attfleetInfo=fleetInfo3
                end
                for k1,v1 in pairs(attfleetInfo)  do
                    if type (troops[i]) ~='table' then troops[i]={} end
                    if type (troops[i][k1])~='table' then troops[i][k1]={}  end
                    if next(v1) then 
                        troops[i][k1][k]=v1[v]
                    end
                    
                end
            end
        end

        params[9][2]=troops
        return params
    end     
    

    function self.toArray(format)
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' and k ~= 'errorCode' then
                if format then
                    if type(v) == 'table'  then
                        if next(v) then data[k] = v end
                    elseif v ~= 0 and v~= '0' and v~='' then
                        data[k] = v
                    end
                else
                    data[k] = v
                end
            end
        end
        return data
    end

    return self

end


