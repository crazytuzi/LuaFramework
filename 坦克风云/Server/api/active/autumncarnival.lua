--
-- 中秋狂欢
-- User: luoning
-- Date: 14-9-2
-- Time: 下午4:01
--

function api_active_autumncarnival(request)

    local aname = 'autumnCarnival'

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local defaultData = {b1=0,b2=0,b3=0,b4=0,b5=0,b6=0}
    local uid = request.uid
    --类型id
    local bid = request.params.bid

    if uid == nil or bid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops,reward

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    if mUseractive.info[aname].ls then
        defaultData = mUseractive.info[aname].ls
    end

    -- 配置文件
    --local activeAllCfg =  getConfig("active." .. aname )
    local activeAllCfg =  getConfig("active."..aname.."."..mUseractive.info[aname].cfg)
    local serverreward = activeAllCfg.serverreward
    if not serverreward[bid] then
        return response
    end

    if not defaultData[bid] or tonumber(defaultData[bid]) < 1 then
        return response
    end

    local reward = getRewardByPool(serverreward[bid]);
    if not takeReward(uid, reward) then
        return response
    end

    local clientReward = {}
    for type, num in pairs(reward) do
        local tmpData = type:split("_")
        local tmpType = tmpData[2]
        local tmpPrefix = string.sub(type, 1, 1)
        if tmpPrefix == 't' then tmpPrefix = 'o' end
        if tmpPrefix == 'a' then tmpPrefix = 'e' end
        table.insert(clientReward, {p=tmpPrefix, t=tmpType, n=num})
    end

    defaultData[bid] = defaultData[bid] - 1
    mUseractive.info[aname].ls = defaultData

    if uobjs.save() then
        response.ret = 0
        response.msg = 'Success'
        response.clientReward = clientReward
    end
    return response
end

