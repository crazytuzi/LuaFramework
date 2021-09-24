function api_active_alliancelevelreward(request)
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

    local  status = mUseractive.isTakeReward("allianceLevel")
    if(status~=1)then
        response.ret=status
        return response
    end

    if mUserinfo.alliance <0 then
        response.msg='alliance error'
        return response
    end
    local aid = mUserinfo.alliance
    local acst =mUseractive.info.allianceLevel.st
    local acet = mUseractive.getAcet("allianceLevel",true)

    local execRet,code = M_alliance.getalliance{uid=uid,aid=aid,acallianceLevel=1,acst=acst,acet=acet}
    --ptb:e(execRet)
    if not execRet then
        response.ret = code
        return response
    end

    local  join_at = execRet.data.join_at
    local role = tonumber(execRet.data.role)


    if tonumber(join_at)>acet then
        response.msg= 'join_at error'
        --return response
       end


       local ranklist = execRet.data.ranklist
       --ptb:p(ranklist)
       local rank = 0
       local myrank = 0


       for k,v in pairs(ranklist) do

           rank=k
           if tonumber(v.aid) ==aid then
               myrank=rank
           end

       end

       if myrank==0 then
        response.ret=-1980
        return response
    end

    --print(role)
    if myrank~=arank then
        response.ret=-1975
        return response
    end
    local activeCfg = getConfig("active")
    local rewards = activeCfg.allianceLevel.serverreward.box
    if(type(rewards[myrank])=='table')then

        
        local addrewards = {}
        local redis = getRedis()
        local redisKey ="zid."..getZoneId().."allianceLevel.commander"..acst.."aid."..aid
        local value = redis:get(redisKey)
        if role==2 and tonumber(value)~=1  then
            addrewards =rewards[myrank]['commander']
            redis:set(redisKey,1)
            redis:expireat(redisKey, mUseractive.info.allianceLevel.et)
        else
            addrewards =rewards[myrank]['members']
        end

        --ptb:e(rewards)
        --ptb:e(addrewards)
        if not takeReward(uid,addrewards) then        
            response.ret = -403 
            return response
        end
        mUseractive.info.allianceLevel.c = -1
        
        if uobjs.save() then
            local setinfo = {}
            setinfo.uid = uid
            mUseractive.setStats('allianceLevel',setinfo)
            response.ret = 0        
            response.msg = 'Success'
            response.flag=1
            response.data.reward = formatReward(addrewards)
            return response
        end
    end


    return response





































end
