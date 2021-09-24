--领取勤劳致富的奖励
function api_active_hardgetrich(request)
    local response = {
        ret=-1,
        msg="error",
        data={}
    }


    local uid = tonumber(request.uid)
    local rid = tostring(request.params.rid) or ''
    local method = tonumber(request.params.method) or 0
    local rank = tonumber(request.params.rank) or 0
    local uobjs = getUserObjs(uid)
      uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","useractive"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mUseractive = uobjs.getModel('useractive')
      
    --活动名称  勤劳致富
    local acname = "hardGetRich"

    -- 状态检测
    local activStatus = mUseractive.getActiveStatus(acname)

    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    mUseractive.info[acname].c=0
    --local activeCfg = getConfig("active")
    local activeCfg = getConfig("active."..acname.."."..mUseractive.info[acname].cfg)

    local rewards = activeCfg.serverreward
    local reward = {}
    local myrank = 0
    local acet = tonumber(mUseractive.getAcet(acname,true))
    if rank >0 then
       local ts = getClientTs()
       if ts<acet then
          response.ret = -1978
          return response
       end
       local list  = getActiveRanking(acname..rid,mUseractive.info[acname].st)


       if next(list) then
          for k,v in pairs(list) do
              local muid=tonumber(v[1])
              if uid == muid then
                 myrank=k
              end
          end
       end

       if myrank==0 then
            response.ret=-1980 
            return response
       end
       if type(mUseractive.info[acname].r) ~='table' then mUseractive.info[acname].r ={} end
       local flag=table.contains(mUseractive.info[acname].r,rid)
       if(flag)then
            response.ret=-1976
            return response
       end
       if myrank >3 and myrank<=5 then
            myrank=4
       end

       if myrank>5 and myrank<=10 then
           myrank=5 
       end    
       if myrank>10 then
           myrank=6 
       end     
       reward =rewards.rankreward[myrank]
       table.insert(mUseractive.info[acname].r,rid)
    else
        --领取第几档资源的奖励
        if type(mUseractive.info[acname].t)~='table' then  mUseractive.info[acname].t={} end
        if type(mUseractive.info[acname].t[rid])~='table' then  mUseractive.info[acname].t[rid]={} end
        local flag=table.contains(mUseractive.info[acname].t[rid],method)
        if(flag) then
            response.ret=-1976
            return response
        end
        local personalGoal= activeCfg.personalGoal

        local needcount = personalGoal[method]
        local cutcount = (mUseractive.info[acname].res[rid]) or 0

        if  cutcount< needcount then
            response.ret=-1981  
            return response
        end
        reward =rewards.personreward[method]
        table.insert(mUseractive.info[acname].t[rid],method)
    end

    if not next(reward) then
        response.ret=-1988  
        return response
    end

    if not takeReward(uid,reward) then        
        response.ret = -403 
        return response
    end
    regEventBeforeSave(uid,'e1')
    processEventsBeforeSave()
    if uobjs.save() then
        processEventsAfterSave()
        response.ret = 0        
        response.msg = 'Success'
    end

    return response
end 