-- 中秋赏月
function api_active_midautumn(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local action = tonumber(request.params.action) or 2
    local t = request.params.t or 1
    local num=request.params.num or 1
    local cost = request.params.cost or 0
    local aname = request.params.aname or 'midautumn'
    local ts = getClientTs()
    local weeTs = getWeeTs()

    if not uid or not action then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo",'useractive','bag','troops','accessory','hero'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroops = uobjs.getModel('troops')
    local mAccessory = uobjs.getModel('accessory')
    local mBag = uobjs.getModel("bag")
    local mHero = uobjs.getModel('hero')
    local activStatus = mUseractive.getActiveStatus(aname)

    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local activeCfg = mUseractive.getActiveConfig(aname)
    -- 刷新
    local ts = getClientTs()
    local weeTs = getWeeTs()
    setRandSeed()
    local data={}
    local redis =getRedis()
    local redkey ="zid."..getZoneId()..aname..mUseractive.info[aname].st.."uid."..uid
    --请求日志
    local save=false
    if action==5 then
        local data =redis:get(redkey)
        data =json.decode(data)
        if type(data)=='table' then
            response.data.log=data
         end
        response.ret=0
        response.msg = 'Success'
        return response

    end
    local last=mUseractive.info[aname].t or 0
    if last<weeTs then
        mUseractive.info[aname].v=0 --每天的充值金币
        mUseractive.info[aname].c=0 --每天充值礼包礼包
        mUseractive.info[aname].t=weeTs
        mUseractive.info[aname].tk={}
        mUseractive.info[aname].r=nil
    end
    --  获取不同品级任务
    local function gettask(cfg)
        local tal=0
        local tmp={}
        for k,v in pairs (cfg) do
            tal=tal+v
            table.insert(tmp,tal)
        end
        local seed = rand(1, tal)
        for k,v in pairs (tmp) do
            if seed<=v then
                return k
            end
        end
    end
    -- 刷新任务
    if action==1 then
        local task={}
        local changedTask=copyTab(activeCfg.changedTask)
        while(#task<activeCfg.tnum)do
            local i=math.random(1,#changedTask)
            local value=table.remove(changedTask,i)
            local numkey=gettask(value.ratio)
            local num =value.needNum[numkey]
            local tmp={value.key,numkey,num}
            table.insert(task,tmp)
        end
        local gems=0
        if cost>0 then
            gems=activeCfg.change
        else
            local r =mUseractive.info[aname].r or 0
            if r>0 then
                response.ret=-102
                return response
            end
            mUseractive.info[aname].r=1
        end
        if gems>0 then
            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end
            regActionLogs(uid,1,{action=136,item="",value=gems,params={}})
        end
        mUseractive.info[aname].tk=task
        -- 领取奖励或者是购买礼包
    elseif action==2 then
        --购买礼包
        local reward={}
        if t==1  then
            local cfg=activeCfg.fixedTask[1]
            local gems=cfg.needNum
            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end
            reward=cfg.serverreward
            regActionLogs(uid,1,{action=137,item="",value=gems,params={}})
        else
            local cfg=activeCfg.fixedTask[2]
            if mUseractive.info[aname].c>0 then
                response.ret=-1976
                return response
            end
            if mUseractive.info[aname].v<cfg.needNum then
                response.ret=-1981
                return response
            end
            reward=cfg.serverreward
            mUseractive.info[aname].c=1
        end
        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end
        response.data.reward=formatReward(reward)
    -- 领取任务奖励
    elseif action==3 then
        if mUseractive.info[aname].tk[t]==nil then
            response.ret=-102
            return response
        end
        local num=mUseractive.info[aname].tk[t][4] or 0
        if mUseractive.info[aname].tk[t][3]> num then
            response.ret=-1981
            return response
        end
        local reward={}
        for k,v in pairs(activeCfg.changedTask) do
            if v.key==mUseractive.info[aname].tk[t][1] then
                reward=v.serverreward[mUseractive.info[aname].tk[t][2]]
                break
            end
        end
        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end
        mUseractive.info[aname].tk[t][4]=-1
        response.data.reward=formatReward(reward)
    -- 抽奖
    elseif action==4 then
        local prop=copyTab(activeCfg.need1[1])
        local tmp={}
        for k,v in pairs(prop) do
            if num>1 then
                v=v*num
            end
            local tmpnum=mBag.getPropNums(k)
            local count=v
            if tmpnum<v then
                count=tmpnum
                tmp[k]=(tmp[k] or 0) +(v-tmpnum)
            end
            if count>0 then
                if not mBag.use(k,count)  then
                    response.ret=-1996
                    return response
                end
            end
        end
        if next(tmp) then
            local gems=0
            local cfg = getConfig('prop')
            for k,v in pairs (tmp) do
                local pcfg=cfg[k]
                gems=gems+pcfg.gemCost*v
            end
            if not mUserinfo.useGem(gems) then
                response.ret = -109
                return response
            end
            regActionLogs(uid,1,{action=138,item="",value=gems,params=tmp})
        end
        local reward={}
        local repoint=0
        local report={}
        for i=1,num do
            local result=getRewardByPool(activeCfg.serverreward.randomPool)
            local lpoint=0
            for k,v in pairs (result) do
                local randkey=activeCfg.serverreward.pointType[k]
                local pointList=activeCfg.serverreward.pointList[randkey]
                local point = rand(pointList[1],pointList[2])
                repoint=repoint+point
                lpoint=lpoint+point
                mUseractive.info[aname].p=(mUseractive.info[aname].p or 0)+point
                reward[k]=(reward[k] or 0)+v
            end
            table.insert(report,{formatReward(result),lpoint})
        end
        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end
        save=true
        response.data.report=report
        data =redis:get(redkey)
        data =json.decode(data)
        if type (data)~="table" then data={}  end
        local lnum=nil
        if num>1 then
            lnum=num
        end
        table.insert(data,{formatReward(reward),ts,lnum})
        if next(data) then
            if #data >10 then
                for i=1,#data-10 do
                    table.remove(data,1)
                end
            end
            data=json.encode(data)
        end
    -- 排行榜奖励
    elseif action==6 then
        local rank=tonumber(request.params.rank) or 0
        local myrank=-1
        local acname=aname
        local  flag=mUseractive.info[aname].rk or 0
        if flag>=1 then
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
            response.ret=-102
            return response
        end
        local rankreward={}
        local  rankReward=activeCfg.serverreward.rankReward
        for k,v in pairs(rankReward) do
            if  myrank<=v[1][2] then
                rankreward=v[2]
                break
            end
        end
        if not takeReward(uid,rankreward) then
            response.ret=-403
            return response
        end
        mUseractive.info[aname].rk=1
        response.data.reward=formatReward(rankreward)
    elseif action==7 then
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
        response.data.ranklist=list
        return response
    end
    if uobjs.save() then
        if (mUseractive.info[aname].p or 0) >=activeCfg.rankLimit then
            setActiveRanking(uid,mUseractive.info[aname].p,aname,10,mUseractive.info[aname].st,mUseractive.info[aname].et)
        end
        if save then
            redis:set(redkey,data)
            redis:expireat(redkey,mUseractive.info[aname].et+86400)
        end
        response.data[aname]=mUseractive.info[aname]
        response.ret = 0
        response.msg = 'Success'
    end
    return response
end
