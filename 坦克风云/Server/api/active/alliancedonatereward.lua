function api_active_alliancedonatereward(request)
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

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})


    local mUserinfo =  uobjs.getModel("userinfo")
    local mUseractive =uobjs.getModel("useractive")
    local acname = "allianceDonate"
    local  status = mUseractive.isTakeReward(acname)

    if(status~=1)then
        response.ret=status
        return response
    end
    if mUserinfo.alliance <=0 then
        response.msg='alliance error'
        return response
    end
    local acst =mUseractive.info.allianceDonate.st
    local acet = tonumber(mUseractive.getAcet(acname,true))
    local execRet,code = M_alliance.getalliance{uid=uid,aid=mUserinfo.alliance,allianceDonate=1,acst=acst,acet=acet}

    if not execRet then
        response.ret = code
        return response
    end
    
    

    local join_at = tonumber(execRet.data.join_at) or 0

    if(join_at>acet) then
        response.ret=-1979
        return response
    end
    local myrank = 0
    local ranklist = execRet.data.rank
    if type(ranklist)=='table' then
        for k,v in pairs(ranklist) do
            if(type(v)=='table') then

                   if(v[1]==mUserinfo.alliance) then
                         myrank=tonumber(k)
                   end 
            end
        end
    end

    if myrank==0 then
        response.ret=-1
        response.flag=0
        return response
    end

   

    if myrank~=arank then
        response.ret=-1975
        return response;
    end
    
    local activeCfg = getConfig("active")
    local rewards = activeCfg.allianceDonate.serverreward.reward
    if(type(rewards[myrank])=='table')then

        if not takeReward(uid,rewards[myrank]) then        
            response.ret = -403 
            return response
        end
        mUseractive.info.allianceDonate.c = -1
        local setinfo = {}
        setinfo.uid=uid
        mUseractive.setStats('allianceDonate',setinfo)
        if uobjs.save() then
            response.ret = 0
            response.data.reward = formatReward(rewards[myrank])        
            response.msg = 'Success'
            return response
        end
    end


    return response




end
