--
-- 连续充值送将领
-- User: luoning
-- Date: 15-3-9
-- Time: 下午7:16
--
function api_active_songjiangling(request)

    local aname = 'songjiangling'

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

    if not mUseractive.info[aname].p then
        mUseractive.info[aname].p = {0,0,0,0,0,0,0}
    end

    local activeCfg = getConfig("active."..aname.."."..mUseractive.info[aname].cfg)

    -- "每日奖励领取"
    if action == "getDailyReward" then

        do return response end

        local num = tonumber(request.params.num) or 0
        if num < 1 or num > 7 then
            response.ret = -102
            return response
        end

        if mUseractive.info[aname].p[num] ~= 1 then
            response.ret = -1981
            return response
        end

        mUseractive.info[aname].p[num] = 2
        local reward = activeCfg.serverreward.dailyReward[num]
        if not takeReward(uid, reward) then
            return response
        end

        -- "修改记录"
    elseif action == "modify" then

        local num = tonumber(request.params.num) or 0
        if num < 1 or num > 7 then
            response.ret = -102
            return response
        end
        if mUseractive.info[aname].p[num] ~= 0 then
            response.ret = -1981
            return response
        end

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
        if num >= day then
            response.ret = -1981
            return response
        end

        mUseractive.info[aname].p[num] = 1
        --黑客修改记录消耗金币
        local gemCost = activeCfg.rR

        if not mUserinfo.useGem(gemCost) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=65,item="",value=gemCost,params={buyNum=num}})


        -- "领取最后一天"
    elseif action == "getLastReward" then

        if not mUseractive.info[aname].m then
            mUseractive.info[aname].m = 0
        end

        if mUseractive.info[aname].m == 1 then
            response.ret = -401
            return response
        end

        local wholeDay = 0
        for _,v in pairs(mUseractive.info[aname].p) do
            if v >= 1 then
                wholeDay = wholeDay + 1
            end
        end

        if wholeDay < 7 then
            response.ret = -102
            return response
        end
        mUseractive.info[aname].m = 1
        local reward = activeCfg.serverreward.bigReward

        if not takeReward(uid, reward) then
            return response
        end

    end

    local mHero = uobjs.getModel('hero')
    response.data.hero =mHero.toArray(true)

    if uobjs.save() then
        response.ret = 0
        response.msg = "Success"
    end

    return response
end

