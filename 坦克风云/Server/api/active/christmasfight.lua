-- 圣诞节大作战（2015版）
-- lmh
-- 2015 11  24

function api_active_christmasfight(request)

    local aname = 'christmasfight'

    local response = {
        ret=-1,
        msg='error',
        data = {
            [aname] = {},
        },
    }

    local uid = request.uid
    local action = request.params.action
    local method = request.params.method or 1
    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive'})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    -- local mWeapon = uobjs.getModel('weapon')

    -- 活动检测
    local activStatus = mUseractive.getActiveStatus(aname)
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end
    local ts = getClientTs()
    local weeTs = getWeeTs()
    if mUseractive.info[aname].t < weeTs then
        mUseractive.info[aname].t = weeTs
        mUseractive.info[aname].c=0
    end

    local activeCfg = mUseractive.getActiveConfig(aname)
    if action=='get' then   -- 获取恶魔
        local stats,devil=mUseractive.getchristmasfight(aname,0,activeCfg.maxPoint,activeCfg.addMin)
        response.data[aname]=mUseractive.info[aname]
        response.data['devil']=devil
        response.ret = 0
        response.msg = "Success"
    
    elseif action=='rand' then   --抽奖
        local gemsCost=0
        local num=0
        if method==1 then
            if mUseractive.info[aname].c>=1 then
                response.ret=-102
                return response
            end
            mUseractive.info[aname].c=1
            num=1
        elseif method==2 then
            gemsCost=activeCfg.oneCost
            num=1
        elseif method==3 then
            gemsCost=activeCfg.tenCost   
            num=10
        end

        mUseractive.info[aname].d =(mUseractive.info[aname].d or 0 ) +num*activeCfg.lotNum
        if gemsCost>0 then
            if  not mUserinfo.useGem(gemsCost) then
                response.ret = -109
                return response
            end
        end
        local stats,devil
        local reward={}
        local heros={}
        local report={}
        for i=1,num do
            stats,devil,send=mUseractive.getchristmasfight(aname,activeCfg.lotNum,activeCfg.maxPoint,activeCfg.addMin)
            local result={}
            local tmpstats=stats
            local tmpResult={}
            if stats==1 then
                local newcount,newdevil=mUseractive.delchristmasfight(aname,activeCfg.lotNum,activeCfg.maxPoint,activeCfg.addMin, send)
                devil=newdevil
                if newcount>=0 then
                    if activeCfg.serverreward.bR['p'..newcount+1]~=nil then
                        result=copyTab(activeCfg.serverreward.bR['p'..newcount+1])
                        tmpResult=activeCfg.bR['p'..newcount+1]
                    else
                        result = getRewardByPool(activeCfg.serverreward.poold)
                        tmpResult=formatReward(result)                     
                    end
                    
                else
                    tmpstats=0
                    result = getRewardByPool(activeCfg.serverreward.poola)
                    tmpResult=formatReward(result)
                end
            else
                result = getRewardByPool(activeCfg.serverreward.poola)
                tmpResult=formatReward(result)
            end
            for k, v in pairs(result or {}) do
                local award = k:split('_')
                --英雄的品阶特殊处理
                if award[1]=='hero' then
                    table.insert(heros,{award[2],v})
                else
                    reward[k] = (reward[k] or 0) + v
                end
            end
            table.insert(report,{tmpResult, tmpstats})
        end
        if reward  and next(reward) then
            if not takeReward(uid,reward) then
                response.ret = -403 
                return response
            end
        end

       
        if next(heros) then
            for k,v in pairs(heros) do
                local flag =mHero.addHeroResource(v[1],v[2])
                if not flag then
                    response.ret = -403 
                    return response
                end
            end
        end
        regActionLogs(uid,1,{action=109,item="",value=gemsCost,params={heros=heros,reward=reward}})

        if uobjs.save() then
            if mUseractive.info[aname].d >activeCfg.cRankp then
                setActiveRanking(uid,mUseractive.info[aname].d,aname..-"2",activeCfg.rankNum,mUseractive.info[aname].st,mUseractive.info[aname].et)
            end
            -- response.data.weapon =mWeapon.toArray(true)
            response.data[aname]=mUseractive.info[aname]
            response.data['devil']=devil
            response.data.report = report
            response.ret = 0
            response.msg = "Success"
        end

      elseif action=='rank' then
        local acname=aname
        if method==1 then
            acname=acname..-"2"
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
       
    elseif action=="rankreward" then   -- 排名奖励
        local rank=tonumber(request.params.rank)
        local myrank=-1
        local acname=aname
        if type(mUseractive.info[aname].r)~='table' then  mUseractive.info[aname].r={} end
        local flag=table.contains(mUseractive.info[aname].r, method)
        if flag then
            response.ret=-1976
            return response
        end
        if ts < tonumber(mUseractive.getAcet(aname,true)) then
            response.ret =-1978
            return response
        end
        if method==1 then
            acname=acname..-"2"
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
            -- response.data.weapon =mWeapon.toArray(true)
        end
    elseif action=="devote" then   -- 排名奖励
        if type(mUseractive.info[aname].dr)~='table' then  mUseractive.info[aname].dr={} end
        local flag=table.contains(mUseractive.info[aname].dr, method)
        if flag then
            response.ret=-1976
            return response
        end

        if activeCfg.dreward[method]==nil then
            response.ret=-102
            return response
        end
        
        local d=mUseractive.info[aname].d  or 0
        if  d<activeCfg.dreward[method].p then
            response.ret=-102
            return response
        end

        if not takeReward(uid,activeCfg.dreward[method].serverReward) then
            response.ret=-403
            return response
        end
        table.insert(mUseractive.info[aname].dr,method)

        if uobjs.save() then
            response.data[aname] =mUseractive.info[aname]
            response.ret = 0
            response.msg = 'Success'
            response.data.reward=formatReward(activeCfg.dreward[method].serverReward)
            -- response.data.weapon =mWeapon.toArray(true)
        end
    end

    return response
end
