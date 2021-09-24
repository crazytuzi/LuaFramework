--
-- 水晶回馈活动
-- User: luoning
-- Date: 15-1-8
-- Time: 上午11:13
--
function api_active_shuijinghuikui(request)

    local aname = 'shuijinghuikui'

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

    if action == "gemsReward" then

        if not mUseractive.info[aname].m then
            mUseractive.info[aname].m = 0
        end
        local gems = tonumber(request.params.gems) or 0
        if gems == 0 or gems > mUseractive.info[aname].m then
            response.ret = -1981
            return response
        end
        local tmpReward = {}
        local tmpClientReward = {}
        local serverToClient = function(type)
            local tmpData = type:split("_")
            local tmpType = tmpData[2]
            local tmpPrefix = string.sub(type, 1, 1)
            if tmpPrefix == 't' then tmpPrefix = 'o' end
            if tmpPrefix == 'a' then tmpPrefix = 'e' end
            return tmpPrefix, tmpType
        end
        for mtype,mnum in pairs(activeCfg.serverreward.gemsReward) do
            local tmpnum = math.floor(mnum * activeCfg.gemsVate * gems)
            tmpReward[mtype] = tmpnum
            local tmpPrefix,tmpType = serverToClient(mtype)
            table.insert(tmpClientReward, {tmpPrefix, tmpType, tmpnum})
        end
        if not takeReward(uid, tmpReward) then
            return response
        end
        mUseractive.info[aname].m = mUseractive.info[aname].m - gems
        response.data[aname].gems = mUseractive.info[aname].m
        response.data[aname].clientReward=tmpClientReward

    elseif action == "dailyReward" then

        local weelTs = getWeeTs()
        if mUseractive.info[aname].t < weelTs then
            mUseractive.info[aname].v = 0
        end

        if mUseractive.info[aname].v <= 0 then
            response.ret = -1981
            return response
        end

        local tmpReward = {}
        local tmpClientReward = {}
        local serverToClient = function(type)
            local tmpData = type:split("_")
            local tmpType = tmpData[2]
            local tmpPrefix = string.sub(type, 1, 1)
            if tmpPrefix == 't' then tmpPrefix = 'o' end
            if tmpPrefix == 'a' then tmpPrefix = 'e' end
            return tmpPrefix, tmpType
        end
        for mtype,mnum in pairs(activeCfg.serverreward.dailyReward) do
            local tmpnum = math.floor(mnum * activeCfg.dailyGold)
            tmpReward[mtype] = tmpnum
            local tmpPrefix,tmpType = serverToClient(mtype)
            table.insert(tmpClientReward, {tmpPrefix, tmpType, tmpnum})
        end
        if not takeReward(uid, tmpReward) then
            return response
        end

        mUseractive.info[aname].v = -1
        response.data[aname].clientReward=tmpClientReward

    else
        return response
    end

    if uobjs.save() then
        response.ret = 0
        response.msg = "Success"
    end

    return response

end
