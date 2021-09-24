-- 装备研究院

function api_equip_lottery(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local uid = request.uid
    local method=request.params.type
    local pid=request.params.pid
    if uid == nil then
        response.ret = -102
        return response
    end
    if moduleIsEnabled('he') == 0 then
        response.ret = -18000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'equip',"hero","userarena","userexpedition"})
    local mHero = uobjs.getModel('hero')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')
    local mEquip= uobjs.getModel('equip')
    local ts = getClientTs()
    local weets  = getWeeTs()
    local count=1
    local equipShopCfg = getConfig('equipShopCfg')

    local lotteryType = 1
    if method==1 then
        if mEquip.last_at+equipShopCfg.freeTicketTime > ts then
            response.ret=-102
            return response
        end 
        mEquip.last_at=ts
    else
        local gemCost=0
        if method==2 then
            gemCost=equipShopCfg.payTicketCost
            if pid==1 then
                if not mBag.use(equipShopCfg.payitem,count) then
                    response.ret=-1996
                    return response
                end
                gemCost=0 
            end 
        else
            gemCost=equipShopCfg.payTicketTenCost
            count=10  
	    lotteryType=2
        end
        
      
        if gemCost>0 then   
            if not mUserinfo.useGem(gemCost) then
                response.ret = -109 
                return response
            end
            regActionLogs(uid,1,{action=97,item="",value=gemCost,params={}})
        end

    end
    local tofalg=true
    local function search(cfg,num,rand,reward,currN,report,heros)
        report = report or {}
        heros  = heros  or {}
        currN = (currN or 0) + 1
        local result,rewardKey =nil
        if currN==rand  and num>1 then
            result,rewardKey = cfg.payTenTicketBouns
        else
            if num>1 then
                result,rewardKey = getRewardByPool(cfg.payTicket1)
            else
                result,rewardKey = getRewardByPool(cfg.payTicket)
            end
            
        end
        reward = reward or {}
        for k, v in pairs(result or {}) do

            if num >1 then

                local flag=table.contains(cfg.once, k)
                if flag then
                    if not tofalg then
                        currN=currN-1
                        return search(cfg,num,rand,reward,currN,report,heros)
                    end 
                    tofalg=false
                end
            end
            local award = k:split('_')

            if award[1]=='hero' then
                table.insert(heros,{award[2],v})
            else
                reward[k] = (reward[k] or 0) + v 
            end  
            
        end

        table.insert(report,{formatReward(result)})

        if currN >= num then
            return reward,report,heros
        else
            return search(cfg,num,rand,reward,currN,report,heros)
        end        
    end
    
    local logparams = {r={},hr={}}
    setRandSeed()
    local randnum = rand(1,10)

    local payTicketBouns=equipShopCfg.payTicketBouns
    local otherreward=copyTab(payTicketBouns)
    if count>1 then
        for k,v in pairs (otherreward) do
           otherreward[k]=v*count
           logparams.r[k] =(logparams.r[k] or 0)+v*count
        end
    end
    if not takeReward(uid,otherreward) then
        return response
    end
    local reward,report,heros = search(equipShopCfg,count,randnum)
    if reward  and next(reward) then
        if not takeReward(uid,reward) then
            return response
        end
        for k,v in pairs(reward) do
            logparams.r[k] = (logparams.r[k] or 0) + v
        end
    end



    if next(heros) then
        for k,v in pairs(heros) do
            local flag =mHero.addHeroResource(v[1],v[2])
            if not flag then
                return response
            end

            if string.find(v[1],'h') then
                logparams.r['hero_'..v[1]] = (logparams.r['hero_'..v[1]] or 0) + 1-- 加将领 第二个值是品质不是数量
            else
                logparams.r['hero_'..v[1]] = (logparams.r['hero_'..v[1]] or 0) + v[2]
            end
        end
        
    end


    if uobjs.save() then  
       -- 系统功能抽奖记录
        setSysLotteryLog(uid,lotteryType,"equip.lottery",count,logparams)       

        response.data.equip =mEquip.toArray(true)
        response.data.equip.report = report
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    end
    
    return response

end