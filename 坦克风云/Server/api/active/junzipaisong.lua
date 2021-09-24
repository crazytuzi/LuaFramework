--
-- 军资派送
-- User: luoning
-- Date: 15-1-21
-- Time: 上午11:58
--
function api_active_junzipaisong(request)

    local aname = 'junzipaisong'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local dtype = request.params.dtype

    local checkDtype = {1,10}

    if uid == nil or not table.contains(checkDtype, dtype) then
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

    local getCostFlag = true
    local weelTs = getWeeTs()

    if mUseractive.info[aname].t < weelTs and dtype == 10 then
        response.ret = -1981
        return response
    end

    if mUseractive.info[aname].t < weelTs then
        getCostFlag = false
        mUseractive.info[aname].t = weelTs
    end

    local gemCost = dtype == 10 and activeCfg.mulCost or activeCfg.cost
    if getCostFlag and ( gemCost < activeCfg.cost or not mUserinfo.useGem(gemCost)) then
        response.ret = -109
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

    local serverreward={}
    local clientreward={}
    for i=1,dtype do
        local sReward = getRewardByPool(activeCfg.serverreward.pool)
        local cReward = {}
        for mtype,mnum in pairs(sReward) do
            if serverreward[mtype] then
                serverreward[mtype] = mnum + serverreward[mtype]
            else
                serverreward[mtype] = mnum
            end
            local tmpPrefix, tmpType = serverToClient(mtype)
            cReward = {tmpPrefix, tmpType, mnum}
        end
        table.insert(clientreward,cReward)
    end

    if not takeReward(uid, serverreward) then
        return response
    end
    -- 和谐版
    if moduleIsEnabled('harmonyversion') ==1 then
        local hReward,hClientReward = harVerGifts('active','junzipaisong',dtype)
        if not takeReward(uid,hReward) then
            response.ret = -403
            return response
        end
        response.data[aname].hReward=hClientReward
    end    

    response.data[aname].clientreward=clientreward

    if getCostFlag then
        regActionLogs(uid,1,{action=60,item="",value=gemCost,params={buyNum=dtype,reward=clientreward}})
    end

    if uobjs.save() then
        response.ret = 0
        response.msg = "Success"
    end

    return response
end

