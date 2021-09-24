--
-- 团队跨服战押注积分
-- User: luoning
-- Date: 14-11-27
-- Time: 上午11:48
--
function model_acrossinfo(uid,data)

    local self = {
        uid = uid,
        --跨服战积分
        point = {},
        --押注信息
        bet = {},
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
    function self.setMatchId(matchId, et)
        if not self.point[matchId] then
            self.point[matchId] = {et=et}
        end
        if not self.bet[matchId] then
            self.bet[matchId] = {et=et}
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
        if type(self.point) ~= 'table' then
            self.point = {}
        end
        --删除过期的比赛数据
        if next(self.point) then
            for matchId, info in pairs(self.point) do
                if info['et'] + recordTime < nowTime then
                    self.point[matchId] = nil
                end
            end
        end
        --删除过期的押注数据
        if next(self.bet) then
            for matchId, info in pairs(self.bet) do
                if info['et'] + recordTime < nowTime then
                    self.bet[matchId] = nil
                end
            end
        end
    end

    --下注
    --
    --params mObj
    --params matchId 详细信息Id
    --params detailId 详细比赛Id
    --params aid  押注的军团
    --params crossCfg 跨服战配置文件
    --params st 比赛开始时间
    --
    --return boolean
    function self.userBet(mObj, matchId, detailId, aid, crossCfg, st)

        local round = mObj.getNowRound()

        if not round then
            self.errorCode = -1981
            return false
        end

        local cfg, type = self.getBetCfg(crossCfg, st, nil, round)
        if not self.bet[matchId] then
            self.bet[matchId] = {}
        end
        if not self.bet[matchId][detailId] then
            self.bet[matchId][detailId] = {aid=aid,count=0,isGet=0,type=type}
        end
        --检查追加的是否为同一个军团
        if self.bet[matchId][detailId]['aid'] ~= aid then
            self.errorCode = -21022
            return false
        end
        self.bet[matchId][detailId]['count'] = self.bet[matchId][detailId]['count'] + 1
        return true, cfg.betGem[ self.bet[matchId][detailId]['count'] ]
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
    function self.getBetReward(mObj, matchId, detailId, crossCfg, st)

        if not self.bet[matchId] then
            self.errorCode = -21023
            return false
        end
        if not self.bet[matchId][detailId] then
            self.errorCode = -21023
            return false
        end

        if self.bet[matchId][detailId]['isGet'] == 1 then
            self.errorCode = -21024
            return false
        end
        --标识已经领奖
        self.bet[matchId][detailId]['isGet'] = 1
        local type = self.bet[matchId][detailId]['type']
        local count = self.bet[matchId][detailId]['count']
        local cfg = self.getBetCfg(crossCfg, st, type, mObj.getNowRound())

        local point = cfg.failer[count]
        local result = mObj.isWinMatch(self.bet[matchId][detailId]['aid'], detailId)
        if not result then
            self.errorCode = -1981
            return false
        end
        if result == 2 then
            point = cfg.winner[count]
        end

        if self.addPoint(matchId, point, detailId) then
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
    function self.allowBet(mObj, matchId, detailId, crossCfg, st)

        local round = mObj.getNowRound()
        if not round then
            self.errorCode = -1981
            return false
        end

        local cfg = self.getBetCfg(crossCfg, st, nil, round)

        if not detailId or not cfg then
            self.errorCode = -21025
            return false
        end

        if not self.bet[matchId] then
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
            --bid-type-round-detail
            if dIdTable[3] == hasDIdTable[3]
                    and dIdTable[4] ~= hasDIdTable[4]
            then
                return false
            end
            return true
        end

        for hasId,_ in pairs(self.bet[matchId]) do
            if hasId ~= 'et' then
                if not checkSameMatch(detailId, hasId) then
                    self.errorCode = -21026
                    return false
                end
            end
        end

        --没有押注过
        if not self.bet[matchId][detailId] then
            return true
        end

        if self.bet[matchId] and self.bet[matchId][detailId] then
            if self.bet[matchId][detailId]['count'] >= #cfg['betGem'] then
                self.errorCode = -21027
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
    function self.getBetCfg(cfg, st, sType, round)
        if not sType then
            if round < 1 then
                return false
            end
            sType = cfg.betStyle4Round[round]
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
    --params matchId 比赛Id
    --params aid 军团id
    --
    --return boolean
    function self.bindJoinPoint(matchObj, matchId, aid)
        --记录积分来源(押注积分0，参赛积分1)mt
        if not self.point[matchId]['rc'] then
            self.point[matchId]['rc'] = {}
        end
        if not self.point[matchId]['rc']['join'] then
            self.point[matchId]['rc']['join'] = {}
        end
        local point, tmpAddDid, join = matchObj.addJoinUserPoint(self.uid, aid, self.point[matchId]['rc']['join'])
        if not point then
            return false
        end
        --记录积分信息
        if not self.point[matchId]['rc'] then
            self.point[matchId]['rc'] = {}
        end
        if not self.point[matchId]['rc']['add'] then
            self.point[matchId]['rc']['add'] = {}
        end
        if next(tmpAddDid) then
            for i, v in pairs(tmpAddDid) do
                table.insert(self.point[matchId]['rc']['add'], v)
            end
        end
        self.addJoinPoint(matchId, point, join)
    end

    --得到积分信息
    --
    --params matchId
    --
    --return table
    function self.getPointInfo(matchId)
        local data = self.toArray()
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
        if  self.point[matchId] and
                self.point[matchId]['rc'] and
                self.point[matchId]['rc']['buy'] then
            res.buy = self.point[matchId]['rc']['buy']
        end
        if  self.point[matchId] and
                self.point[matchId]['rc'] and
                self.point[matchId]['rc']['add'] then
            for i,v in pairs(self.point[matchId]['rc']['add']) do
                if v[4] <= nowTime then
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
    function self.addAdminPoint(matchId, point)

        if not self.point[matchId] then
            self.point[matchId] = {}
        end
        if not self.point[matchId]['nm'] then
            self.point[matchId]['nm'] = 0
        end
        self.point[matchId]['nm'] = self.point[matchId]['nm'] + point
    end

    --参赛用户增加积分
    --
    --params matchId    比赛Id
    --params point
    --params join 所有已经领奖的did
    --
    --return boolean
    function self.addJoinPoint(matchId, point, join)

        if not self.point[matchId] then
            self.point[matchId] = {}
        end
        if not self.point[matchId]['nm'] then
            self.point[matchId]['nm'] = 0
        end
        self.point[matchId]['nm'] = self.point[matchId]['nm'] + point

        --记录积分来源(押注积分0，参赛积分1)mt
        if not self.point[matchId]['rc'] then
            self.point[matchId]['rc'] = {}
        end
        if not self.point[matchId]['rc']['join'] then
            self.point[matchId]['rc']['join'] = {}
        end
        self.point[matchId]['rc']['join'] = join
        return true
    end

    --增加排名积分
    --
    --params matchId 比赛Id
    --params point 积分数量
    --params detailId 小Id
    --
    --return boolean
    function self.addRankingPoint(matchId, point, ranking)

        if not self.point[matchId] then
            self.point[matchId] = {}
        end
        if not self.point[matchId]['nm'] then
            self.point[matchId]['nm'] = 0
        end
        --已经领取排名奖励
        if self.point[matchId]['rank'] then
            self.errorCode = -21028
            return false
        end

        self.point[matchId]['nm'] = self.point[matchId]['nm'] + point
        --标识已经领取排名奖励
        self.point[matchId]['rank'] = {ranking, point}

        --记录积分来源(押注积分0，参赛积分1)mt
        if not self.point[matchId]['rc'] then
            self.point[matchId]['rc'] = {}
        end
        if not self.point[matchId]['rc']['add'] then
            self.point[matchId]['rc']['add'] = {}
        end
        table.insert(self.point[matchId]['rc']['add'], {point, 2, 'r', getClientTs(), ranking})
        return true
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
    function self.addPoint(matchId, point, detailId)

        if not self.point[matchId] then
            self.point[matchId] = {}
        end
        if not self.point[matchId]['nm'] then
            self.point[matchId]['nm'] = 0
        end
        self.point[matchId]['nm'] = self.point[matchId]['nm'] + point

        --记录积分来源(押注积分0，参赛积分1)mt
        if not self.point[matchId]['rc'] then
            self.point[matchId]['rc'] = {}
        end
        if not self.point[matchId]['rc']['add'] then
            self.point[matchId]['rc']['add'] = {}
        end
        table.insert(self.point[matchId]['rc']['add'], {point, 0, detailId, getClientTs()})
        return true
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
    function self.usePoint(matchId, point, tId, limitNum, rewardType, rewardNum, sType)
        --消费积分
        local uPoint = 0
        if self.point[matchId] and self.point[matchId]['nm'] then
            uPoint = self.point[matchId]['nm']
        else
            self.point[matchId] = {}
        end
        if uPoint < point then
            self.errorCode = -21029
            return false
        end
        self.point[matchId]['nm'] = uPoint - point

        --验证购买数量
        if not self.point[matchId]['lm'] then
            self.point[matchId]['lm'] = {}
        end
        if not self.point[matchId]['lm'][tId] then
            self.point[matchId]['lm'][tId] = 0
        end
        if self.point[matchId]['lm'][tId] >= limitNum then
            self.errorCode = -21030
            return false
        end
        self.point[matchId]['lm'][tId] = self.point[matchId]['lm'][tId] + 1
        takeReward(self.uid, {[rewardType]=rewardNum})
        --记录消费信息
        if not self.point[matchId]['rc'] then
            self.point[matchId]['rc'] = {}
        end
        if not self.point[matchId]['rc']['buy'] then
            self.point[matchId]['rc']['buy'] = {}
        end
        table.insert(self.point[matchId]['rc']['buy'], {tId, getClientTs()})
        return true
    end

    function self.getFirst()
        local key ="z" .. getZoneId() ..".across.winer."..1
        local redis = getRedis()
        return json.decode(redis:get(key))
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

