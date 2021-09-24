function api_active_personalcheckreward(request)

    local response = {
        ret=-1,
        data={},
        msg="error",
    }

    local aname = 'personalCheckPoint'
    local uid =request.uid
    local arank = tonumber(request.params.rank) or 0
    if uid==nil then
        response.ret=-102
        return response
    end


    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","useractive" ,"props","bag","skills","buildings","dailytask","task"})


    local mUserinfo =  uobjs.getModel("userinfo")
    local mUseractive =uobjs.getModel("useractive")
    
    local  status = mUseractive.isTakeReward("personalCheckPoint")

    if(status~=1)then
        response.ret=status
        return response
    end
    
     local list=mUseractive.getpersonalCheckPoint()

     local myrank = 0

     if type(list)=='table' and next(list) then
         for k,v in pairs(list) do
             if tonumber(v.uid)==uid then
                 --print('fuck')
                 myrank=v.rank
             end
         end
     end

     if myrank==0 then
        response.ret=-1980
        return response
    end

    if myrank~=arank then
        response.ret=-1975
        return response;
    end
     local activeCfg = getConfig("active")

     local cfg = mUseractive.info.personalCheckPoint.cfg 
    local rewards = activeCfg.personalCheckPoint[cfg].serverreward.box
    --ptb:p(mUseractive)
    if type(rewards[myrank])=='table' then

        --ptb:e(rewards[myrank])
        if not takeReward(uid,rewards[myrank]) then        
            response.ret = -403 
            return response
        end
        regActionLogs(uid,6,{action=5007,item='personalCheckPoint',value=rewards[myrank].userinfo_gems,params={}})
        mUseractive.info.personalCheckPoint.c = -1
        local setinfo={}
        setinfo.uid=uid
        
        if uobjs.save() then
            mUseractive.setStats('personalCheckPoint',setinfo)
            response.ret = 0        
            response.msg = 'Success'
            return response
        end
       
    end

    return response
end