function api_active_fightrankreward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }


    local uid = request.uid
    local rank = tonumber(request.params.rank) or 0
    if(uid ==nil or rank>30) then
        response.ret=-102
        return response
    end


    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})

    local mUserinfo =  uobjs.getModel("userinfo")
    local mUseractive =uobjs.getModel("useractive")

    local  status = mUseractive.isTakeReward("fightRank")
    if(status~=1)then
        response.ret=status
        return response
    end

    local list,mylist =mUseractive.getfightRank(1,1,uid)

    if(next(mylist)==nil)then
        response.msg='rank error'
        response.ret=-1
        return response
    end
    rank=mylist[3]
    local activeCfg = getConfig("active")

    local cfg = mUseractive.info.fightRank.cfg 
    local rewards = activeCfg.fightRank[cfg].serverreward.box
    if not rewards[rank] then
        response.ret = -1980
        return response
    end


    if not takeReward(uid,rewards[rank]) then        
        response.ret = -403 
        return response
    end
    mUseractive.info.fightRank.c = -1
    if uobjs.save() then
        local setinfo = {}
        setinfo.uid=uid
        setinfo.rank=rank
        mUseractive.setStats('fightRank',setinfo)
        response.ret = 0        
        response.msg = 'Success'
    end
    
    return response


end