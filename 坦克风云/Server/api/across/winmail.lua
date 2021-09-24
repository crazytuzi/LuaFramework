--
-- 全服奖励
-- User: luoning
-- Date: 14-10-21
-- Time: 下午5:41
--

function api_across_winmail()

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
    local amMatchinfo = mServerbattle.getAcrossBattleInfo()
    if not next(amMatchinfo) then
        response.ret = -21001
        return response
    end

    --检查数据信息
    local getRewardAll = amMatchinfo.reward
    getRewardAll = json.decode(getRewardAll)
    if type(getRewardAll) ~= "table" then
        getRewardAll = {}
    end
    if getRewardAll[amMatchinfo.bid] then
        response.ret = -21001
        return response
    end

    local redis = getRedis()
    local redisKey = "z" .. getZoneId() ..".acrosswinmail.matchinfo"..amMatchinfo.bid..amMatchinfo.et
    if redis:incr(redisKey) > 1 then
        response.ret = -21001
        return response
    end
    redis:expireat(redisKey, amMatchinfo.et)

    -- 防止并发处理
    local lockkey = "z" .. getZoneId() ..".acrosswinmailext.matchinfo"..amMatchinfo.bid..amMatchinfo.et
    local ret = redis:getset(lockkey,100)
    if ret then
        writeLog({ret=ret, incret=redis:get(redisKey)},"across")
        response.ret = -21001
        return response
    end
    redis:expireat(lockkey, amMatchinfo.et)

    --检查是否有正在进行的跨服战
    require "model.amatches"
    local mMatches = model_amatches()
    mMatches.setBaseData(amMatchinfo)

    local ranking = mMatches.getRankInfo()
    if not next(ranking) then
        return response
    end

    local rangeType = {22,23,24 }

    local getNameByAid = function(aid)
        local name = "npc_112233"
        for _,v in pairs(mMatches.base.info) do
            if v[1] == aid then
                name = v[2]
                break
            end
        end
        return name
    end

    local function sentSysMail(tmpTime,et,rangeType,json,mail_type,gift,item,send)
        local ret=MAIL:sentSysMail(tmpTime,et,rangeType,json,mail_type,gift,item,send)
        if ret then
            return true
        else
            return sentSysMail(tmpTime,et,rangeType,json,mail_type,gift,item,send)
        end
    end

    local crossCfg = getConfig('serverWarTeamCfg')
    local rewardCfg = crossCfg.severReward
    local zoneId = getZoneId()
    local rankinfo = {}
    for i,v in pairs(ranking) do
        local tmpType = i:split('-')

        -- 第一名 LED 广播
        local winkey ="z" .. getZoneId() ..".across.winer."..1
        if v[1] == 1 then
            --local name = getNameByAid(tonumber(tmpType[2]))
            local name =mMatches.getNameByAid(i)
            redis:set(winkey,json.encode({tmpType[1],name}))
            redis:expireat(winkey,tonumber(amMatchinfo.et)+96*3600)
        end

        if tonumber(tmpType[1]) == tonumber(zoneId)
             and tonumber(v[1]) >= 1 and tonumber(v[1]) <= 2
        then
            local name = getNameByAid(tonumber(tmpType[2]))
            local tmpReward = rewardCfg[tonumber(v[1])]
            if tonumber(v[1])==1 then
                -- 每日捷报设设置跨服战冠军的信息
                local setRet,code=M_alliance.getalliancesname{aids=json.encode({tonumber(tmpType[2])})}
                if setRet then
                    local ninfo=setRet.data[1]
                    if type(ninfo)=="table" and next(ninfo) then
                        local newsdata={ninfo.name,ninfo.level,ninfo.commander,ninfo.fight,ninfo.amaxnum,ninfo.memberNum,ninfo.type,ninfo.level_limit,ninfo.fight_limit,ninfo.notice,tonumber(tmpType[2])}
                        local news={title="d24",content={
                            allianceinfo={
                                newsdata
                            }
                        }}
                        setDayNews(news)
                    end
                end
            end
            local item = {h=tmpReward['serverReward'], q={}, f={} }
            for prefix,vv in pairs(tmpReward['reward']) do
                if not item.q[prefix] then
                    item.q[prefix] = {}
                end
                for _, goods in pairs(vv) do
                    for mType, mNum in pairs(goods) do
                        table.insert(item.q[prefix], {[mType] = mNum})
                    end
                end
            end
            for _,_ in pairs(tmpReward['serverReward']) do
                table.insert(item.f, "0")
            end
            --军团战的最后一场战斗的结束时间
            local tmpTime = getClientTs()
            if sentSysMail(tmpTime,mMatches.base.et ,rangeType[tonumber(v[1])],
                json.encode({type=rangeType[tonumber(v[1])], name=name}),1,2,item,1) then
                table.insert(rankinfo, tonumber(v[1]))
            end
        end
    end

    --本服没有冠亚季军， 写入4
    if not next(rankinfo) then
        table.insert(rankinfo, 4)
    end
    --记录比赛信息
    getRewardAll[amMatchinfo.bid] = json.encode(rankinfo)
    --删除个人战缓存
    mServerbattle.clearBattleCache(2)

    response.msg = "Success"
    response.ret = 0
    return response
end

