--  各种连抽
function api_armor_lottery(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local free= request.params.free
    local num = request.params.num
    local method= request.params.type
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('armor') == 0 then
        response.ret = -11000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive',"hero","armor"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mArmor = uobjs.getModel('armor')
    -- 普通抽奖
    local armorCfg=getConfig('armorCfg')
    mArmor.reffreecount(armorCfg)
    local gemCost=0
    if mArmor.getInfoCount()+num >mArmor.count then
        response.ret=-9050
        return response
    end
    if method==1 then
        --
        num=1
        if free==true then
            if (mArmor.free[method][2] or 0)<=0 then
                response.ret=-102
                return response
            end
            mArmor.free[method][2]=mArmor.free[method][2]-1
            mArmor.reffreetime(method,armorCfg['maxFreeNum'..method])
        else
            gemCost=armorCfg.moneyCost1
        end

    elseif method == 2 then -- 高级抽奖
        if free==true then
            if (mArmor.free[method][2] or 0)<=0 then
                response.ret=-102
                return response
            end
            num=1
            mArmor.free[method][2]=mArmor.free[method][2]-1
            mArmor.reffreetime(method,armorCfg['maxFreeNum'..method])
        else
            gemCost=armorCfg.moneyCost2
            if num>1 then
                gemCost=math.ceil(gemCost*num*armorCfg.discount)
            end
        end
	else
		return response
    end

    -- 高级抽奖每N次换奖池
    local advCnt = nil
    if method == 2 then
       advCnt = mArmor.incrAdvanceLotteryCnt(num)
    end

    local reward={}
    local report={}
    for i=1,num do
        local pool=armorCfg['MatrixPool'..method]
        if  method == 2 and (advCnt - i + 1) % armorCfg.maxNum == 0 then
            pool = armorCfg.MatrixPool3
        end

        local result=getRewardByPool(pool)
        for k,v in pairs (result) do
            reward[k]=(reward[k] or 0)+v

        end
        table.insert(report,formatReward(result))
        -- 奖励发放
    end

    -- 首次普通抽奖 送指定道具
    if num == 1 and method == 1 and mArmor.free[3][1] == 0 then
        mArmor.free[3][1] = 1

        reward={}
        report={}
        reward[armorCfg.mustGet[1]] = armorCfg.mustGet[2]
        table.insert(report,formatReward(reward))
    end

    local ret,retw=takeReward(uid,reward)
    if not ret  then
        response.ret=-403
        return response
    end
    if gemCost>0 then
        if not mUserinfo.useGem(gemCost) then
            response.ret = -109
            return response
        end
        regActionLogs(uid,1,{action=156,item="",value=gemCost,params={type=method,num=num,reward=reward}})
    end

    local logparams = {r=report,hr={}}
   --和谐版
   if moduleIsEnabled('harmonyversion') ==1 then
        local hReward,hClientReward = harVerGifts('funcs','armor',num)
        if not takeReward(uid,hReward) then
            response.ret = -403
            return response
        end
        response.data.hReward = hClientReward
        logparams.hr = hClientReward
    end 


    processEventsBeforeSave()
    if uobjs.save()  then 
        processEventsAfterSave()
        response.data.armor={}
        if type(retw)=="table" and next(retw) then
            response.data.amreward =retw.armor.info
        end

        -- 系统功能抽奖记录
        setSysLotteryLog(uid,method,"armor.lottery",num,logparams,true,true)

        response.data.armor.free=mArmor.free
        response.data.report=report
        response.ret = 0        
        response.msg = 'Success'
    end
    return response

end