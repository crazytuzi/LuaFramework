function api_active_fightrankbasereward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local uid = request.uid
    local index = request.params.index
    if uid ==nil or index==nil then
        response.ret=-102
        return response
    end
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})
    local aname = 'fightRank'
    local mUserinfo =  uobjs.getModel("userinfo")
    local fc = mUserinfo.fc
    local mUseractive =uobjs.getModel("useractive")
    local activeCfg = getConfig("active")
    local cfg = mUseractive.info.fightRank.cfg 
    local reward = activeCfg.fightRank[cfg].serverreward.allCanGet
    if reward == nil then
        response.ret = -102 
        return response
    end
    if type(mUseractive.info.fightRank.rewardlog) ~= 'table' then
        mUseractive.info.fightRank.rewardlog = {}--奖励记录
        for k,v in pairs(reward) do
            table.insert(mUseractive.info.fightRank.rewardlog,0)
        end
    end
    if mUseractive.info.fightRank.rewardlog[index] == 1 then
        response.ret = -1976 
        return response
    end
    local fight = reward[index].fight
    local basereward = reward[index].r
    if fc < fight then
        response.ret = -102 
        return response
    end
    if not takeReward(uid,basereward) then        
        response.ret = -403 
        return response
    end
    mUseractive.info.fightRank.rewardlog[index] = 1
    if uobjs.save() then
        response.data[aname] =mUseractive.info[aname]
        response.data[aname].reward = formatReward(basereward)
        response.ret = 0        
        response.msg = 'Success'
    end
    
    return response


end