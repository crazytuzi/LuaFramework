function api_active_alliancefightreward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }


    local uid = request.uid

    local arank = tonumber(request.params.rank) or 0
    
    if(uid ==nil ) then
        response.ret=-102
        return response
    end

    --uid =1012749
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})


    local mUserinfo =  uobjs.getModel("userinfo")
    local mUseractive =uobjs.getModel("useractive")

    local  status = mUseractive.isTakeReward("allianceFight")

    if(status~=1)then
        response.ret=status
        return response
    end
    --ptb:e(mUserinfo)
    if mUserinfo.alliance <=0 then
        response.msg='alliance error'
        return response
    end
    --ptb:e(mUseractive)
    local acst =mUseractive.info.allianceFight.st
    local acet = tonumber(mUseractive.getAcet("allianceFight",true))
    local execRet,code = M_alliance.getalliance{uid=uid,aid=aid,acalliancfight=1,acst=acst,acet=acet,members=1}

    if not execRet then
        response.ret = code
        return response
    end
    
    local rank = 0
    local myrank = 0
    local members = execRet.data.members

    --ptb:p(members)
    if type(members)=='table' then
        for k,v in pairs(members) do
            rank=tonumber(k)
            for key,val in pairs(v) do
                if tonumber(val.uid) ==uid then
                    myrank=rank

                end
                
            end
            
        end
    end
    local setinfo = {}
    setinfo.members = members
    mUseractive.setStats('allianceFight',setinfo)
    if myrank==0 then
        response.ret=-1
        response.flag=0
        return response
    end

    if myrank~=arank then
        response.ret=-1975
        return response;
    end
    --ptb:e(myrank)
    local activeCfg = getConfig("active")
    local rewards = activeCfg.allianceFight.serverreward.box


    --print(myrank)
    if(type(rewards[myrank])=='table')then

        --ptb:e(rewards[myrank]);
        if not takeReward(uid,rewards[myrank]) then        
            response.ret = -403 
            return response
        end
        mUseractive.info.allianceFight.c = -1
        setinfo.uid=uid
        mUseractive.setStats('allianceFight',setinfo)
        if uobjs.save() then
            response.ret = 0        
            response.msg = 'Success'
            return response
        end
    end


    return response




end
