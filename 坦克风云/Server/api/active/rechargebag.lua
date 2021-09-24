-- 充值红包
function api_active_rechargebag(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local action = request.params.action
    local method =request.params.method
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo",'useractive','bag','troops','accessory','hero'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local aname="rechargebag"
    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    local activeCfg = mUseractive.getActiveConfig(aname)
    if action == "reward" then
        if type(mUseractive.info[aname].d)~='table' then mUseractive.info[aname].d={}  end
        local flag=table.contains(mUseractive.info[aname].d, method)
        if flag then
            response.ret=-1976
            return response
        end

        if activeCfg.cost[method]==nil then
            response.ret=-102
            return response
        end
        if activeCfg.cost[method]>mUseractive.info[aname].v then
            response.ret=-102
            return response
        end
        
        table.insert(mUseractive.info[aname].d,method)
        local reward=activeCfg.serverreward.r[method]
        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end
        if uobjs.save() then
            response.data[aname] =mUseractive.info[aname]
            processEventsAfterSave()
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=formatReward(reward)
        end
    elseif action=="ranklist" then

        local ranklist = getActiveRanking(aname,mUseractive.info[aname].st)
        local list={}
        if type(ranklist)=='table' and next(ranklist) then
            for k,v in pairs(ranklist) do
                local mid= tonumber(v[1])
                local muobjs = getUserObjs(mid,true)
                muobjs.load({"userinfo", "techs", "troops", "props","bag","skills","hero",'useractive',"alien"})
                local tmUserinfo = muobjs.getModel('userinfo')
                table.insert(list,{mid,tmUserinfo.nickname,v[2],tmUserinfo.level})
            end
        end

        response.ret = 0
        response.msg = 'Success'
        response.ranklist=list
    elseif action=="rankreward" then
        local r=mUseractive.info[aname].r or 0
        local ts=getClientTs()
        local acet = mUseractive.getAcet(aname,true)
        if r==1 then
            response.ret=-1976
            return response
        end
        if ts<= acet then
            response.ret=-1978    
            return response
        end
        local rank=request.params.rank or 0
        local myrank=0
        local ranklist = getActiveRanking(aname,mUseractive.info[aname].st)
        if type(ranklist)=='table' and next(ranklist) then
            for k,v in pairs(ranklist) do
                local mid= tonumber(v[1])
                if mid==uid then
                    myrank=k
                end
            end
        end   
        if myrank~=rank then
            response.ret=-1975
            return response
        end
        if myrank<=0 then
            response.ret=-1980
            return response
        end
        local rankreward={}
        for k,v in pairs(activeCfg.serverreward.rankReward) do
            if  myrank<=v[1][2] then
                rankreward=v[2]
                break
            end
        end
        mUseractive.info[aname].r =1
        if not takeReward(uid,rankreward) then
            response.ret=-403
            return response
        end
        if uobjs.save() then
            response.data[aname] =mUseractive.info[aname]
            processEventsAfterSave()
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=formatReward(rankreward)
        end

    elseif action == "extra" then   
        local l= mUseractive.info[aname].l or 0
        local dl= mUseractive.info[aname].dl or 0
        if l<=dl then
            response.ret=-102
            return response
        end
        local count=l-dl
        local reward={}
        for k,v in pairs (activeCfg.serverreward.extra) do 
            reward[k] =(reward[k] or 0)+v*count
        end
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end
        mUseractive.info[aname].dl=l
        if uobjs.save() then
            response.data[aname] =mUseractive.info[aname]
            processEventsAfterSave()
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=formatReward(reward)
        end
    end    


    return response

end