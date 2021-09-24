--
-- 许愿炉
-- User: luoning
-- Date: 14-12-29
-- Time: 下午4:54
--

function api_active_xuyuanlu(request)

    -- 活动名称，莫斯科赌局
    local aname = 'xuyuanlu'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local action = request.params.action

    if uid == nil or action == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg)


    if action == "gold" then
        --当前时间
        local nowWeelTs = getWeeTs()
        local activeStTime = getWeeTs(mUseractive.info[aname].st)

        local getDay = function(nowWeelTs, activeStTime)
            local day = ((nowWeelTs - activeStTime)/86400) + 1
            if day > 7 or day < 1 then
                return false
            else
                return day
            end
        end
        local day = getDay(nowWeelTs, activeStTime)
        if not day then
            response.ret = -1981
            return response
        end
        --今日次数
        local tmpTimes = activeCfg.goldTimes[day] - mUseractive.info[aname].v
        if tmpTimes <= 0 then
            response.ret = -1981
            return response
        end
        mUseractive.info[aname].v = mUseractive.info[aname].v + 1
        local gemCost = activeCfg.goldReward[mUseractive.info[aname].v][1]
        setRandSeed()
        local rewardGems =rand(
            activeCfg.goldReward[mUseractive.info[aname].v][2][1],
            activeCfg.goldReward[mUseractive.info[aname].v][2][2]
        )
        if not mUserinfo.useGem(gemCost) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=56,item="",value=gemCost,params={buyNum=gemCost,},nowGems=mUserinfo.gems,})
        if not takeReward(uid, {userinfo_gems=rewardGems}) then
            return response
        end
        response.data[aname].rewardGems = rewardGems
        if not mUseractive.info[aname].rr then
            mUseractive.info[aname].rr = {}
        end
        table.insert(mUseractive.info[aname].rr, rewardGems)
        response.data[aname].history = mUseractive.info[aname].rr

    elseif action == "resource" then

        local weelTs = getWeeTs()
        if not mUseractive.info[aname].p then
            mUseractive.info[aname].p = 0
        end
        if not mUseractive.info[aname].m then
            mUseractive.info[aname].m = {{0,0,0},1,{0,0,0}}
        end
        if mUseractive.info[aname].t < weelTs then
            mUseractive.info[aname].m = {{0,0,0},1,{0,0,0}}
            mUseractive.info[aname].t = weelTs
        end
        if mUseractive.info[aname].p <= 0 then
            response.ret = -1981
            return response
        end
        mUseractive.info[aname].p = mUseractive.info[aname].p - 1
        local reward = getRewardByPool(activeCfg.serverreward.pool)
        if not takeReward(uid, reward) then
            return response
        end

        local serverToClient = function(type)
            local tmpData = type:split("_")
            local tmpType = tmpData[2]
            local tmpPrefix = string.sub(type, 1, 1)
            if tmpPrefix == 't' then tmpPrefix = 'o' end
            if tmpPrefix == 'a' then tmpPrefix = 'e' end
            return tmpPrefix, tmpType
        end

        local clientReward = {}
        for mtype,mNum in pairs(reward) do
            local tmpPrefix, tmpType = serverToClient(mtype)
            table.insert(clientReward, {tmpPrefix, tmpType, mNum})
        end

        response.data[aname].clientReward = clientReward

    end

    if uobjs.save() then
        response.ret = 0
        response.msg = "Success"
    end

    return response
end

