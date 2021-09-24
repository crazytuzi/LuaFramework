--
-- 全服奖励
-- User: luoning
-- Date: 14-10-21
-- Time: 下午5:41
--

function api_cross_winmail(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local params = request.params

    --检查是否有正在进行的跨服战
    require "model.matches"
    local mMatches = model_matches()
    if not next(mMatches.base) then
        response.ret = mMatches.errorCode
        return response
    end

    if not commonLock(mMatches.base.matchId, "crosswar") then
        writeLog({{matchId=mMatches.base.matchId, 'winmail lock fail...'}}, 'cross')
        response.ret = -5004
        return response
    end

    --检查是否已经发送奖励
    if mMatches.checkAllUser() then
        response.ret = -20019
        return response
    end

    local ranking = {}
    if mMatches.getRankInfo() then
        ranking = mMatches.formatRanking()
    end
    if not next(ranking) then
        return response
    end
    local matchId = mMatches.base.matchId
    mMatches.cacheRewardResult({[matchId]={99}})
    local getRewardAll = mMatches.base.reward

    local rangeType = {16,17,18}

    local tmpMatch = matchId:split('_')
    local bid = tmpMatch[1]
    local crossCfg = getConfig('serverWarPersonalCfg')
    local rewardCfg = crossCfg.severReward
    local zoneId = getZoneId()
    local rankinfo = {}
    for i,v in pairs(ranking) do
        local tmpType = i:split('-')
        if tonumber(tmpType[2]) == tonumber(zoneId)
             and tonumber(v) >= 1 and tonumber(v) <= 3
        then
            local uobjs = getUserObjs(tonumber(tmpType[1]))
            local mUserinfo = uobjs.getModel('userinfo')
            local mCrossinfo = uobjs.getModel('crossinfo')
            mCrossinfo.recordRanking(mMatches, tonumber(v))
            if tonumber(tmpType[1]) >= 1000000 and uobjs.save() then
                if tonumber(v) ==1 then
                    -- 每日捷报设置个人跨服战冠军的信息
                    local newsdata={mUserinfo.pic,mUserinfo.nickname,mUserinfo.level,mUserinfo.fc,mUserinfo.alliancename,tonumber(tmpType[1]),mUserinfo.bpic,mUserinfo.apic}
                    local news={title="d21",content={
                        userinfo={
                            newsdata
                        }
                    }}
                    setDayNews(news)
                end
                writeLog("get talking ranking success" .. tonumber(tmpType[1]) .. " " .. tonumber(v), "cross")
            else
                writeLog("get talking ranking failed " .. tonumber(tmpType[1]) .. " " .. tonumber(v), "cross")
            end
            local name = mUserinfo.nickname
            if not name or name == '' then
                name = "npc_110112"
            end
            local tmpReward = rewardCfg[tonumber(v)]
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
            local tmpTime = getClientTs()
            if tmpTime > mMatches.baseinfo[2][#(mMatches.baseinfo[2])][1] + crossCfg.battleTime * 3 then
                tmpTime = mMatches.baseinfo[2][#(mMatches.baseinfo[2])][1] + crossCfg.battleTime * 3
            end
            if MAIL:sentSysMail(tmpTime,mMatches.base.et ,rangeType[tonumber(v)],
                json.encode({type=rangeType[tonumber(v)], name=name}),1,2,item,1) then
                table.insert(rankinfo, tonumber(v))
            end
        end
    end
    --本服没有冠亚季军， 写入4
    if not next(rankinfo) then
        table.insert(rankinfo, 4)
    end
    getRewardAll[matchId] = rankinfo
    local insertData = json.encode(getRewardAll)
    local db = getDbo()
    db:update('serverbattlecfg', {reward=insertData}, "bid="..bid.."")
    mMatches.cacheRewardResult(getRewardAll)

    require "model.serverbattle"
    local mServerbattle = model_serverbattle()
    --删除个人战缓存
    mServerbattle.clearBattleCache(1)

    response.msg = "Success"
    response.ret = 0
    return response
end

