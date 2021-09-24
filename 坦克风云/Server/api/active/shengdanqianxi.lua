-- 活动圣诞前夕

function api_active_shengdanqianxi(request)
    local aname = 'shengdanqianxi'

    local response = {
        ret=-1,
        msg='error',
        data = {
        },
    }

    local uid = request.uid
    local method = tonumber(request.params.method) or 0
    local action = request.params.action
    local taruid = tonumber(request.params.tuid) or 0
    local sid    = request.params.sid
    if uid == nil or  method==nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","hero",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mHero = uobjs.getModel('hero')
    local mTroops = uobjs.getModel('troops')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg = mUseractive.getActiveConfig(aname)
    local weeTs = getWeeTs()
    local ts = getClientTs()
    local lastTs = mUseractive.info[aname].t or 0
    if weeTs > lastTs then
        mUseractive.info[aname].ds = 0
        mUseractive.info[aname].t=weeTs
    end
    

    if action=='send' then   --送礼
        local db = getDbo()
        db.conn:setautocommit(false)
        if taruid<=0 or taruid==uid or activeCfg.serverreward.reward[sid]==nil  then
            response.ret=-102
            return response
        end
        if type(mUseractive.info[aname].s)~='table' then  mUseractive.info[aname].s={}  end
        local  send =mUseractive.info[aname].ds or 0
        local tuobjs = getUserObjs(taruid)
        tuobjs.load({"userinfo", "techs", "troops", "props","bag","skills","hero",'useractive','bag'})
        local tUseractive = tuobjs.getModel('useractive')
        local tUserinfo = tuobjs.getModel('userinfo')
        local mHero = uobjs.getModel('hero')
        local item=activeCfg.serverreward.reward[sid]
       
        local icount=mUseractive.info[aname].s[sid] or 0
        if icount>= item.s then
            response.ret= -1993
            return response
        end
        if send>= activeCfg.daysend then
           response.ret= -1993
           return response
        end
        local gemCost=item.p
        if method==1 then
            gemCost=gemCost+item.g
        else
            local need =item.n
            if need==nil then
                return response
            end
            for k,num in pairs (need) do
                local model
                local used = k:split('_') 
                if type(used) == 'table' then
                    if used[1] == 'props' then
                        model = uobjs.getModel('bag')
                        local ret = model.use(used[2],num)
                        if not ret then
                            response.data={}
                            response.ret=-1996
                            return response
                        end
                        response.data.bag = model.toArray(true)
                    elseif used[1] == 'troops' then
                        model = uobjs.getModel('troops')
                        local ret = model.consumeTanks(used[2],num)
                        if not ret then
                            response.data={}
                            response.ret=-1996
                            return response
                        end
                        response.data.troops = model.toArray(true)
                    elseif used[1] == 'accessory' then
                        model = uobjs.getModel('accessory')
                        local ret= model.useProp(used[2],num)
                        if not ret then
                            response.data={}
                            response.ret=-1996
                            return response
                        end
                        response.data.accessory ={}
                        response.data.accessory.props=model.props
                    end
                else
                    return response
                end
            end

        end

            if gemCost >0 then
                if not mUserinfo.useGem(gemCost) then
                    response.ret = -109
                    return response
                end

                regActionLogs(uid,1,{action=110,item="",value=gemCost,params={gift=sid,method=method}})
            end

            mUseractive.info[aname].ds=(mUseractive.info[aname].ds or 0) +1
            mUseractive.info[aname].s[sid]=(mUseractive.info[aname].s[sid] or 0)+1
            mUseractive.info[aname].v=mUseractive.info[aname].v +item.d
            if type(tUseractive.info[aname].g)~='table' then  tUseractive.info[aname].g={}  end
            local tgcount=0
            if next(tUseractive.info[aname].g) then
                for k,v in pairs (tUseractive.info[aname].g) do
                    tgcount=tgcount+v
                end
            end
            if tgcount>=activeCfg.usercount then
                response.ret =-2236
                return response
            end
            tUseractive.info[aname].g[sid]=(tUseractive.info[aname].g[sid] or 0)+1
            if tuobjs.save() then  
                if uobjs.save() and db.conn:commit() then
                    local redis =getRedis()
                    if mUseractive.info[aname].v>activeCfg.rankPoint  then
                        setActiveRanking(uid,mUseractive.info[aname].v,aname,10,mUseractive.info[aname].st,mUseractive.info[aname].et)
                    end
                    local key = "z"..getZoneId()..".ac."..aname..taruid..".user."..mUseractive.info[aname].st
                    local data =redis:get(key)
                    data =json.decode(data)
                    if type (data)~="table" then data={}  end
                    table.insert(data,{sid,mUserinfo.nickname,ts})
                    data=json.encode(data)
                    redis:set(key,data)
                    redis:expireat(key,mUseractive.info[aname].et+86400)
                    local data = {[aname] = tUseractive.info[aname],name=mUserinfo.nickname}
                    regSendMsg(taruid,'active.change',data)
                    response.data[aname]=mUseractive.info[aname]
                    response.ret = 0
                    response.msg = 'Success'
                    return response
                end
            end



    elseif action=='get' then  --礼物清单

        local redis =getRedis()
        local key = "z"..getZoneId()..".ac."..aname..uid..".user."..mUseractive.info[aname].st
        local data =redis:get(key)
        data =json.decode(data)
        response.data.list=data
        response.ret = 0
        response.msg = 'Success'
        return response

    elseif action=='ranklist' then  --慷慨值排行
        local ranklist = getActiveRanking(aname,mUseractive.info[aname].st)
      
        local list={}
        if type(ranklist)=='table' and next(ranklist) then
            for k,v in pairs(ranklist) do
                local mid= tonumber(v[1])
                local muobjs = getUserObjs(mid,true)
                muobjs.load({"userinfo", "techs", "troops", "props","bag","skills","hero",'useractive',"alien"})
                local tmUserinfo = muobjs.getModel('userinfo')
                table.insert(list,{mid,tmUserinfo.nickname,v[2]})
            end
        end

        response.ret = 0
        response.msg = 'Success'
        response.ranklist=list
        return response


    elseif action=='rankreward' then  -- 领取排行榜奖励
        local rank=tonumber(request.params.rank)
        local myrank=-1
        local r=mUseractive.info[aname].r or 0
        if r==1 then
            response.ret=-1976
            return response
        end
        if ts < tonumber(mUseractive.getAcet(aname,true)) then
            response.ret =-1978
            return response
        end
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
        for k,v in pairs(activeCfg.rankReward) do
            if    myrank<=v.range[2] then
                rankreward=v.serverReward
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
            response.data.hero =mHero.toArray(true)
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=formatReward(rankreward)
        end
        return response

    elseif action=='firstreward'  then   -- 领取第一次奖励
        local f=mUseractive.info[aname].f or 0
        if f==1 then
            response.ret=-1976
            return response
        end
        mUseractive.info[aname].f =1
        if not takeReward(uid,activeCfg.serverreward.firstreward) then
            response.ret=-403
            return response
        end
        if uobjs.save() then
            response.data[aname] =mUseractive.info[aname]
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=formatReward(activeCfg.serverreward.firstreward)
        end
        return response



    elseif action=="gift"  then    -- 领取自己的礼物
        local mBag = uobjs.getModel('bag')
        if mUseractive.info[aname].g== nil then
            response.ret=-102
            return response
        end
        local reward={}
        local d=0
        local userd =mUseractive.info[aname].d  or 0
        if method==1 then   -- 领取全部
            for k,v in pairs (mUseractive.info[aname].g) do
                d=d+activeCfg.serverreward.reward[k].l*v
                for rk,rv  in pairs (activeCfg.serverreward.reward[k].r) do
                    reward[rk]=(reward[rk] or 0) +rv*v
                end
            end
            mUseractive.info[aname].g=nil
        else   -- 领取单个
            
            if mUseractive.info[aname].g[sid]==nil or mUseractive.info[aname].g[sid]<=0 then
                response.ret=-102
                return response
            end

            reward=copyTab(activeCfg.serverreward.reward[sid].r)
            d     =activeCfg.serverreward.reward[sid].l
            mUseractive.info[aname].g[sid]=mUseractive.info[aname].g[sid]-1
            if mUseractive.info[aname].g[sid]<=0 then
                mUseractive.info[aname].g[sid]=nil
            end
            if not next(mUseractive.info[aname].g) then  mUseractive.info[aname].g=nil end
        end

        if (mUseractive.info[aname].v-userd)<d then
            response.ret=-1996
            return response
        end 
        if not takeReward(uid,reward) then
            response.ret=-403
            return response
        end
        mUseractive.info[aname].d=(mUseractive.info[aname].d or 0)+d
        if uobjs.save() then
            local redis =getRedis()
            local key = "z"..getZoneId()..".ac."..aname..uid..".user."..mUseractive.info[aname].st
            if method==1 then
                redis:del(key)
            else
                local user=tonumber(request.params.user)
                local data =redis:get(key)
                data =json.decode(data)
                if type (data)=="table" then 
                    for k,v in pairs (data) do
                        if k==user then
                            table.remove(data,k)
                        end
                    end
                    data=json.encode(data)
                    redis:set(key,data)
                    redis:expireat(key,mUseractive.info[aname].et+86400)
                end
                
            end
           
            response.data[aname] =mUseractive.info[aname]
            response.ret = 0
            response.msg = 'Success'
            response.data.bag = mBag.toArray(true)
            response.data.hero =mHero.toArray(true)
            response.data.troops =mTroops.toArray(true)
        end
        return response

    elseif action=='buy'  then     -- 购买
        local d =mUseractive.info[aname].d  or 0
        if type(mUseractive.info[aname].buy)~='table' then mUseractive.info[aname].buy={} end
        if activeCfg.shop[sid]==nil then
            response.ret=-102
            return response
        end

        if (mUseractive.info[aname].v-d)<activeCfg.shop[sid].price then
            response.ret=-1996
            return response
        end

        local buynum=mUseractive.info[aname].buy[sid] or 0
        if buynum>=activeCfg.shop[sid].buynum then
            response.ret= -1993
            return response
        end

        mUseractive.info[aname].d=(mUseractive.info[aname].d or 0)+activeCfg.shop[sid].price

        if not takeReward(uid,activeCfg.shop[sid].serverReward) then
            response.ret=-403
            return response
        end
        
        mUseractive.info[aname].buy[sid]=(mUseractive.info[aname].buy[sid] or 0)  +1

        if uobjs.save() then
            response.data[aname] =mUseractive.info[aname]
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=formatReward(activeCfg.shop[sid].serverReward)
        end
        return response

    end


end
