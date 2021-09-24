-- 领取世界boss奖励 包括排行榜，击杀，占雪亮总比奖励
-- 优化v1:
-- 2018-04-13 hwm 优化
-- 全程自动攻击的玩家奖励需要直接发到奖励中心,如果后期有加奖励需要注意这块
function api_boss_reward(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local rank= request.params.rank or 0
    local autoAttack = request.params.autoAttack

    if uid == nil  then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('boss') == 0 then
        response.ret = -15000
        return response
    end
    local bossCfg = getConfig('bossCfg')
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","hero","worldboss"})
    local mUserinfo = uobjs.getModel('userinfo')
    local weet = getWeeTs()
    local ts = getClientTs()
    local mWorldboss= uobjs.getModel('worldboss')

    -- 优化v1:
    -- 自动攻击领奖需要检测自动攻击
    if autoAttack and not mWorldboss.checkAutoAttack() then
        response.ret = -102
        response.err = "checkAutoAttack failed"
        return response
    end

    local autoAttackRewards = {}

    if mWorldboss.reward_at>weet then
        response.ret=-1976
        return response
    end
    local boss= mWorldboss.getBossInfo(bossCfg)
    local time=bossCfg.opentime[2][1]*3600+bossCfg.opentime[2][2]*60
    local flag =false
    -- boss 没被干死要检测是否到时间了
    local rankreward={}
    if boss[3]<boss[2] then
        if ts< weet+time then
            response.ret=-15007
            return response
        end
    else --否则就给排名的奖励
        local list=getActiveRanking("worldboss.rank",weet)
        local ranklist={}
        local myrank=0
        if type(list)=='table' and next(list) then
            for k,v in pairs(list) do
                if v[1]==uid then
                    myrank=k
                    break
                end
            end
            if rank >0 then
                if rank~=myrank then
                    response.ret=-1975
                    return response
                end
            end
            if myrank>0 then
                for k,v in pairs (bossCfg.serverreward.rankReward) do
                    if  myrank <=v.range[2] then
                        rankreward =v[1]
                        flag=true

                        if autoAttack then
                            table.insert(autoAttackRewards,rankreward)
                        else
                            if not takeReward(uid,rankreward) then        
                                response.ret = -403  
                                return response
                            end
                        end

                        break
                    end 
                end
            end
        end
       
    end
        
    if weet>mWorldboss.attack_at then
        mWorldboss.point=0
        mWorldboss.info.k=nil
    end

    --  击杀奖励
    local killreward={}
    if type(mWorldboss.info.k)=='table' and next(mWorldboss.info.k) then
        for k,v in pairs (mWorldboss.info.k) do

            if k>6 then
                break
            end
            -- 最后一个炮头
            if v ==6  then
                --ptb:p(bossCfg.attackHpreward)
                for k,v in pairs(bossCfg.serverreward.attackHpreward[2]) do
                    killreward[k] =(killreward[k] or 0) +v   
                end
            else -- 普通炮头    
                for k,v in pairs(bossCfg.serverreward.attackHpreward[1]) do
                    killreward[k] =(killreward[k] or 0) +v   
                end
            end
        end
        flag=true

        if autoAttack then
            table.insert(autoAttackRewards,killreward)
        else
            if not takeReward(uid,killreward) then        
                response.ret = -403 
                return response
            end
        end
    end
    -- 占总血量比的奖励
    local hpreward ={}
    if mWorldboss.point>0 then
        local rate= mWorldboss.point / mWorldboss.info.boss[2]
        rate= math.ceil(rate*bossCfg.attacktolHprewardRate)
        local bai =math.floor(rate/100)
        local baireward={}
        if bai >0 then
            for k,v in pairs(bossCfg.serverreward.attacktolHpreward[1]) do
                baireward[k]=v*bai
            end
        end
        local shireward={}
        local shi=math.floor((rate-bai*100)/10)   
        if shi>0 then
            for k,v in pairs(bossCfg.serverreward.attacktolHpreward[2]) do
                shireward[k]=v*shi
            end
        end
        local gereward ={}
        local ge=math.floor(rate%10)
        if ge >0 then
            for k,v in pairs(bossCfg.serverreward.attacktolHpreward[3]) do
                gereward[k]=v*ge
            end
        end

        if next (baireward) then
            for k,v in pairs(baireward) do
                hpreward[k] =(hpreward[k] or 0) +v  
            end
        end 
        if next (shireward) then
            for k,v in pairs(shireward) do
                hpreward[k] =(hpreward[k] or 0) +v  
            end
        end 
        if next (gereward) then
            for k,v in pairs(gereward) do
                hpreward[k] =(hpreward[k] or 0) +v  
            end
        end    

        if next (hpreward) then
            flag=true

            if autoAttack then
                table.insert(autoAttackRewards,hpreward)
            else
                if not takeReward(uid,hpreward) then        
                    response.ret = -403 
                    return response
                end
            end
        end
    end

    if not flag then
        response.ret=-15008
        return response
    end

    if autoAttack and next(autoAttackRewards) then
        local tmp = {}
        for _,rinfo in pairs(autoAttackRewards) do
            for rid,rn in pairs(rinfo) do
                tmp[rid] = (tmp[rid] or 0) + rn
            end
        end

        sendToRewardCenter(uid,'boss',50,getWeeTs(),nil,nil,tmp)
    end

    mWorldboss.reward_at=ts
    if uobjs.save() then
         writeLog('boss-reward'..uid..'-----hp--'..json.encode(hpreward)..'--kill--'..json.encode(killreward).."---rank---"..json.encode(rankreward),'boss')
        response.data.worldboss = mWorldboss.toArray(true)
        response.ret = 0       
        response.msg = 'Success'
    end
    return response 
end