
-- 新年除夕活动  类似世界boss  海德拉
function api_active_newyeareva(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = tonumber(request.uid)
    local action = request.params.action
     if uid == nil then
        response.ret = -102
        return response
    end

    -- 活动名称，新年除夕
    local aname = 'newyeareva'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local activStatus = mUseractive.getActiveStatus(aname)
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    local weeTs = getWeeTs()
    local ts = getClientTs()
    local activeCfg = mUseractive.getActiveConfig(aname)
    local lastTs = mUseractive.info[aname].t or 0
    if weeTs > lastTs then
        mUseractive.info[aname].ds = 0
        mUseractive.info[aname].t=weeTs
        mUseractive.info[aname].f=0
        mUseractive.info[aname].v=0
        mUseractive.info[aname].ac=0
    end

    -- 计算减血
    local function addEvaDieHp(point,boss)
        local bossHp=boss[2] 
        local oldhp=boss[2]-boss[3]
        local toldieHp=boss[3]
        local tolHp,oldHp=mUseractive.addEvaHp(aname,tonumber(point))
        oldhp=boss[2]-oldHp
        toldieHp=tolHp
        if oldHp > bossHp then
            response.ret=-1905 
            return response
        end
         if tolHp > bossHp then
            point =point-(tolHp-bossHp)
            tolHp=bossHp
        end
        -- 计算谁击杀的 然后存起来
        local PartBefore = math.ceil((bossHp-oldHp) * 6  / bossHp)
        local PartAfter  = math.ceil((bossHp-tolHp) * 6 / bossHp )
        local Part = PartBefore - PartAfter
        -- 击杀了
        local reward={}
        if Part>0 then
            -- 一次击杀了多个炮头
            if Part>1 then
                for i=1,Part do
                    if PartAfter==0 then
                        local flag=table.contains(reward, 2)
                        if flag then
                            table.insert(reward,1)
                        else
                            mUseractive.killEva(aname,activeCfg.serverreward.mailreward)
                            table.insert(reward,2)
                        end
                    else
                        table.insert(reward,1)
                    end
                end
            else --一次只击杀一个炮头
                -- 击杀的最后一个炮头
                if PartAfter==0 then
                    mUseractive.killEva(aname,activeCfg.serverreward.mailreward)
                    table.insert(reward,2)
                else
                    table.insert(reward,1)
                end
            end
           
        end

        return point,reward,oldhp,toldieHp
    end

    -- 根据伤害来加奖励
    local function addHpPool(pool,maxhp,dhp,reward)
        local reward=reward or {}
        local newreward={}
        local rminhp=math.floor(activeCfg.serverreward.costvalue[pool][1]*dhp)
        local rmaxhp=math.floor(activeCfg.serverreward.costvalue[pool][2]*maxhp)
        setRandSeed()
        if  rminhp>rmaxhp then
            local tmp=rmaxhp
            rmaxhp=rminhp
            rminhp=tmp
        end
        local seed = rand(rminhp, rmaxhp)
        local fix=activeCfg.serverreward.costfix[pool]
        local count=(math.log10(seed)+fix[1])*fix[2]
        local once= string.format("%.2f", count)         
        local oncerate=(once-math.floor(once))*100
        local count=math.floor(once)
        local rate = rand(1, 100)
        if rate<=oncerate then
            count=count+1
        end
        if count>1 then 
            for i=1,count do
                local result = getRewardByPool(activeCfg.serverreward['pool'..pool])
                for k,v in pairs (result or {}) do
                    reward[k]=(reward[k] or 0)+v
                    newreward[k]=(newreward[k] or 0)+v
                end
            end

        end

        return reward,newreward,seed
    end

    --获取年兽
    if action=='get' then
        local Cfg=getConfig("active/"..aname)
        Cfg.level=activeCfg.level
        Cfg.revivetime=activeCfg.revivetime
        local eva=mUseractive.getEvaInfo(aname,Cfg)
        response.ret = 0    
        response.msg = 'Success'
        response.data[aname]=mUseractive.info[aname]
        response.data.eva=eva
        return response
    elseif action=='attack' then --用坦克攻击
        local hero = request.params.hero
        local fleet = request.params.fleetinfo
        local equip = request.params.equip
        local mHero  =uobjs.getModel('hero')
        local mTroop = uobjs.getModel('troops')
        local ac=mUseractive.info[aname].ac or 0
        local gems=tonumber(request.params.gems) or 0
        -- 到达最大攻击次数需要花钱
        if ac>=activeCfg.ac then
            if activeCfg.accost[ac-activeCfg.ac+1]==nil then
                response.ret=-102
                return response
            end
            local gemCost=activeCfg.accost[ac-activeCfg.ac+1]
            if gemCost~=gems then
                response.ret=-102
                return response
            end
            if gemCost >0 then
                if not mUserinfo.useGem(gemCost) then
                    response.ret = -109
                    return response
                end
                regActionLogs(uid,1,{action=117,item="",value=gemCost,params={count=ac-activeCfg.ac+1}})
            end
        end
        --设置英雄
        if type(hero)=='table' and next(hero) then
            hero =mHero.checkFleetHeroStats(hero)
            if hero==false then
                response.ret=-11016 
                return response
            end
        end

        local fleetInfo={}
        -- 设置镜像部队
        local totalTanks = 0
        if type(fleet)=='table' and next(fleet)  then
            for m,n in pairs(fleet) do        
                if type(n) == 'table' and next(n) and n[2] > 0 then
                    if n[1] then 
                        n[1]= 'a' .. n[1] 
                    end    
                    totalTanks = totalTanks + n[2]
                    fleetInfo[m] = n
                else
                    fleetInfo[m] = {}
                end
            end
            if next (fleetInfo) then
                if not mTroop.checkFleetInfo(fleetInfo, nil, equip) then
                    response.ret = -5006
                    return response
                end
            end
        end
        --获取boss信息
        local Cfg=getConfig("active/"..aname)
        Cfg.level=activeCfg.level
        Cfg.revivetime=activeCfg.revivetime
        local boss= mUseractive.getEvaInfo(aname,Cfg)
        local oldhp=boss[2]-boss[3]
        local toldieHp=boss[3]
        if boss[3]>=boss[2] then
            response.ret=-1905 
            return response
        end
        local report,point = mUseractive.Evabattle(fleetInfo,hero,boss,activeCfg,equip)
        report.p = {{},{mUserinfo.nickname,mUserinfo.level,1,1}}
        local reward={}
        if point>0 then
           point,addreward,oldhp,toldieHp=addEvaDieHp(point,boss)
           if point<0 then
                response.ret=-1905 
                return response
           end
           if  type(addreward)=='table' and  next(addreward)  then
                for k,v in pairs(addreward) do
                    for ak,ad in pairs(activeCfg.attackHpreward[v].sr or {}) do
                        reward[ak] =(reward[ak] or 0)+ad
                    end
                end
                response.data.kill=addreward
           end

        end
        local dhp=point
        local maxhp=mUseractive.getMaxDieHpEva(aname)
        if maxhp<=0 then
            maxhp=dhp
        end
        local reward,retreward=addHpPool(1,maxhp,dhp,reward)        
        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret=-403
                return response
            end
        end
        mUseractive.info[aname].th=(mUseractive.info[aname].th or  0)+dhp
        mUseractive.info[aname].h = mUseractive.info[aname].h or 0
        local h=mUseractive.info[aname].h or 0 
        if dhp>h then
            mUseractive.info[aname].h =dhp
        end
        mUseractive.info[aname].ac=(mUseractive.info[aname].ac or 0)+1
        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward
            hReward,hClientReward = harVerGifts('active','newyeareva',1)

            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward= hClientReward
        end        
        if uobjs.save() then
            local eva=mUseractive.getEvaInfo(aname,Cfg)
            eva[3]=toldieHp
            eva[6]=oldhp
             setActiveRanking(uid,mUseractive.info[aname].h,aname,activeCfg.rank,mUseractive.info[aname].st,mUseractive.info[aname].et)
            setActiveRanking(uid,mUseractive.info[aname].th,aname.."-1",activeCfg.rank,mUseractive.info[aname].st,mUseractive.info[aname].et)
            local send=mUseractive.setMaxDieHpEva(aname,mUseractive.info[aname].h)
            response.data[aname]=mUseractive.info[aname]
            if next(harCReward) then
                response.data[aname].hReward=harCReward
            end            
            response.data.sn=send
            response.ret = 0       
            response.msg = 'Success'
            response.data.eva=eva
            response.data.report=report
            if next(retreward) then
                response.data.reward=formatReward(retreward)
            end
        end
        return response
    elseif action=='firecracker' then  -- 爆竹攻击
        local method=tonumber(request.params.method)
        if activeCfg.cost[method]==nil then
            response.ret=-102
            return response
        end 
        local gemCost=activeCfg.cost[method]
        if gemCost >0 then
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109
                return response
            end
            regActionLogs(uid,1,{action=118,item="",value=gemCost,params={pz=method}})
        end 
        if method==3 and activeCfg.cost3vipLimit then
           local f= (mUseractive.info[aname].f or 0)
           if f>=(activeCfg.cost3vipLimit[mUserinfo.vip+1] or activeCfg.cost3vipLimit[#activeCfg.cost3vipLimit]) then
               response.ret= -1993
               return response
           end
           mUseractive.info[aname].f=(mUseractive.info[aname].f or 0)+1
        end
        local Cfg=getConfig("active/"..aname)
        Cfg.level=activeCfg.level
        Cfg.revivetime=activeCfg.revivetime
        local boss= mUseractive.getEvaInfo(aname,Cfg)
        if boss[3]>=boss[2] then
            response.ret=-1905 
            return response
        end

        local dhp=mUseractive.info[aname].h or 0
        if dhp<=0 then
            response.ret=-102
            return response
        end
        local reward={}
        local point=0
        local maxhp=mUseractive.getMaxDieHpEva(aname)
        if maxhp<=0 then
            maxhp=dhp
        end
        local oldhp=boss[2]-boss[3]
        local toldieHp=boss[3]
        local reward,retreward,point=addHpPool(method,maxhp,dhp,reward)  
        if point>0 then
           point,addreward,oldhp,toldieHp=addEvaDieHp(point,boss)
           if point<0 then
                response.ret=-1905 
                return response
           end
           if  type(addreward)=='table' and  next(addreward)  then
                for k,v in pairs(addreward) do
                    for ak,ad in pairs(activeCfg.attackHpreward[v].sr or {}) do
                        reward[ak] =(reward[ak] or 0)+ad
                    end
                end
                response.data.kill=addreward
           end

        end
        if next(reward) then
            if not takeReward(uid,reward) then
                response.ret=-403
                return response
            end
        end
        local dhp=point
        mUseractive.info[aname].th=(mUseractive.info[aname].th or  0)+dhp

        -- 和谐版判断
        local harCReward={}
        if moduleIsEnabled('harmonyversion') ==1 then
            local hReward,hClientReward
            local harnum=1
            if method==3 then
                hReward,hClientReward = harVerGifts('active','newyeareva',harnum,true)
            else
                if method==2 then
                    harnum=10
                end
                hReward,hClientReward = harVerGifts('active','newyeareva',harnum)
            end

            if not takeReward(uid,hReward) then
                response.ret = -403
                return response
            end
            harCReward= hClientReward
        end

        if uobjs.save() then
            setActiveRanking(uid,mUseractive.info[aname].h,aname,activeCfg.rank,mUseractive.info[aname].st,mUseractive.info[aname].et)
            setActiveRanking(uid,mUseractive.info[aname].th,aname.."-1",activeCfg.rank,mUseractive.info[aname].st,mUseractive.info[aname].et)
            local eva=mUseractive.getEvaInfo(aname,Cfg)
            eva[3]=toldieHp
            eva[6]=oldhp
            response.data[aname]=mUseractive.info[aname]
            if next(harCReward) then
                response.data[aname].hReward=harCReward
            end
            response.ret = 0
            response.msg = 'Success'
            response.data.eva=eva
            if next(retreward) then
                response.data.reward=formatReward(retreward)
            end
        end
        return response

    elseif action=='rankreward' then  -- 排行榜奖励
        local method=request.params.method or 1
        local acname=aname
        if method~=1 then
            acname=aname.."-1"
        end
        local rank =tonumber(request.params.rank) or 0

        if type(mUseractive.info[aname].r)~='table' then  mUseractive.info[aname].r={} end
        local flag=table.contains(mUseractive.info[aname].r,method)
        if flag then
            response.ret=-1976
            return response
        end
        if ts < tonumber(mUseractive.getAcet(aname,true)) then
            response.ret =-1978
            return response
        end
        local ranklist = getActiveRanking(acname,mUseractive.info[aname].st)
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
        local retreward={}
        local  rankReward=activeCfg['rankReward'..method]
        for k,v in pairs(rankReward) do
            if  myrank<=v.range[2] then
                rankreward=v.serverReward
                retreward=v.reward
                break
            end
        end
        table.insert(mUseractive.info[aname].r,method)
        if not takeReward(uid,rankreward) then
            response.ret=-403
            return response
        end
        if uobjs.save() then
            response.data[aname] =mUseractive.info[aname]
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=retreward
        end
        return response
    elseif action=='ranklist' then  --排行榜
        local method=request.params.method or 1
        local acname=aname
        if method~=1 then
            acname=aname.."-1"
        end
        local ranklist = getActiveRanking(acname,mUseractive.info[aname].st)
      
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


end
