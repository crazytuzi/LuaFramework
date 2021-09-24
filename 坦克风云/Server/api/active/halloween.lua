-- 万圣节活动 不给糖就捣乱

function api_active_halloween(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local action =request.params.action
    local ptype =request.params.ptype
     if uid == nil then
        response.ret = -102
        return response
    end


    local aname = 'halloween'
        
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","useractive"})
    local mUseractive = uobjs.getModel('useractive')
    local mUserinfo = uobjs.getModel('userinfo')
    local mbag = uobjs.getModel('bag')
    local mTroops,reward

    local activStatus = mUseractive.getActiveStatus(aname)
    -- 活动检测
    if activStatus ~= 1 then
        response.ret = activStatus
        return response
    end

    local ts = getClientTs()
    local weeTs = getWeeTs()
    local activeCfg = mUseractive.getActiveConfig(aname)
    --ptb:p(mUseractive.info[aname])    -- 领取每天的奖励
    if type(mUseractive.info[aname].tg)~='table' then  mUseractive.info[aname].tg={} end
    if type(mUseractive.info[aname].p)~='table' then  mUseractive.info[aname].p={} end
    if action=='dayreward' then
        local drc =mUseractive.info[aname].drc or 0
        local dc  =mUseractive.info[aname].dc or 0
        if dc<=0 or drc>=dc then
            response.ret=-102
            return response
        end
        local count=dc-drc
        if count<=0 then
            response.ret=-102
            return response
        end
        local reward=copyTable(activeCfg.serverreward.dayreward.p)
        
        if count>1 then
            for k,v in pairs (reward) do
                reward[k]=v*count
            end
            
        end
        for tk,tv in pairs (activeCfg.serverreward.dayreward.t) do
            mUseractive.info[aname].tg[tk]=(mUseractive.info[aname].tg[tk] or 0)+tv*count
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end
        mUseractive.info[aname].drc=dc
    elseif action == "totalreward" then --累计
        local num  =mUseractive.info[aname].num or 0
        if math.floor(num/activeCfg.cost)<=0 or  mUseractive.info[aname].c>=math.floor(num/activeCfg.cost) then
            response.ret=-102
            return response 
        end

        local count=math.floor(num/activeCfg.cost)-mUseractive.info[aname].c
        local reward=copyTable(activeCfg.serverreward.totalreward.p)
        if count>1 then
            for k,v in pairs (reward) do
                reward[k]=v*count
            end
            
        end
        for tk,tv in pairs (activeCfg.serverreward.totalreward.t) do
            mUseractive.info[aname].tg[tk]=(mUseractive.info[aname].tg[tk] or 0)+tv*count
        end

        if not takeReward(uid,reward) then
            response.ret = -403
            return response
        end
        mUseractive.info[aname].c=mUseractive.info[aname].c+count
    elseif action == "plant" then    --种植
        local pid =request.params.pid
        if ptype>6 or ptype<=0 then
            response.ret=-102
            return response
        end
        if mUseractive.info[aname].p["p"..ptype]~=nil then
            response.ret=-102
            return  response 
        end

        if mUseractive.info[aname].tg[pid]==nil or mUseractive.info[aname].tg[pid]<=0 then
            response.ret=-1996
            return  response 
        end

        mUseractive.info[aname].p["p"..ptype]={pid,ts+activeCfg.needtime[pid]*3600}
        mUseractive.info[aname].tg[pid]=mUseractive.info[aname].tg[pid]-1
        
    elseif action == "harvest" then    --收获
        if type(mUseractive.info[aname].p["p"..ptype])~="table" then
            response.ret=-102
            return  response 
        end
        if ts<mUseractive.info[aname].p["p"..ptype][2] then
            response.ret=-102
            return  response 
        end
        local t=mUseractive.info[aname].p["p"..ptype][1]
        local reward=getRewardByPool(activeCfg.serverreward.reward[t])
        if not takeReward(uid,reward) then        
            response.ret = -403 
            return response
        end
        mUseractive.info[aname].p["p"..ptype]=nil
        response.data.reward=formatReward(reward) 
        mUseractive.info[aname].pc=(mUseractive.info[aname].pc or 0) +1
    elseif action == "swreward" then    --超级武器扫荡奖励 
 
        local sw =mUseractive.info[aname].sw or 0
        if activeCfg.ascount > sw or mUseractive.info[aname].swr==1 then
            response.ret=-1981
            return response
        end
        if not takeReward(uid,activeCfg.serverreward.asreward) then        
            response.ret = -403 
            return response
        end
        mUseractive.info[aname].swr=1
    elseif action == "plantreward" then    --种植奖励  
        local pc =mUseractive.info[aname].pc or 0
        if activeCfg.cropcount > pc or mUseractive.info[aname].pcr==1 then
            response.ret=-1981
            return response
        end
        if not takeReward(uid,activeCfg.serverreward.cropreward) then        
            response.ret = -403 
            return response
        end
        mUseractive.info[aname].pcr=1
    elseif action == "speed" then    --加速
        if type(mUseractive.info[aname].p["p"..ptype])~="table" then
            response.ret=-102
            return  response 
        end
        if ts>=mUseractive.info[aname].p["p"..ptype][2] then
            response.ret=-102
            return  response 
        end 
        local gemCost=0
        local cts=mUseractive.info[aname].p["p"..ptype][2]-ts
        gemCost=math.ceil(cts/activeCfg.gemsecond)
        if  not mUserinfo.useGem(gemCost) then
                response.ret = -109
                return response
        end
        mUseractive.info[aname].p["p"..ptype][2]=ts
        regActionLogs(uid,1,{action=100,item="",value=gemCost,params={buyNum=ptype}})
        response.data.usegems=gemCost
    end 
    if uobjs.save() then 
            -- 统计
        response.data[aname]=mUseractive.info[aname]
        response.ret = 0  
        response.msg = 'Success'
    end
    return response
end