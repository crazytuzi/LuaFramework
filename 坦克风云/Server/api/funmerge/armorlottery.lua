--  各种连抽
function api_funmerge_armorlottery(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    if moduleIsEnabled('funmerge') == 0 then
        response.ret = -180
        return response
    end
    local uid = request.uid
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
    local remainnum = mArmor.count-mArmor.getInfoCount()
    if remainnum <= 0 then
        response.ret=-9050
        return response
    end
    if (mArmor.free[2][2] or 0)<=0 and (mArmor.free[1][2] or 0)<=0 then
        response.ret=-102
        return response
    end
    local qreward = {}
    local reward = {}
    local report = {}
    local num = 0
    local advCnt = nil
    if remainnum>0 and remainnum<6 then
        -- 高级抽奖
        if (mArmor.free[2][2] or 0)>0 then
            advCnt = mArmor.incrAdvanceLotteryCnt(1)
            local result = {}
            if advCnt % armorCfg.maxNum == 0 then
                result=getRewardByPool(armorCfg['MatrixPool3'])
            else
                result=getRewardByPool(armorCfg['MatrixPool2'])
            end
            for k,v in pairs (result) do
                table.insert(qreward,{[k]=v})
                reward[k]=(reward[k] or 0)+v
            end
            mArmor.free[2][2] = mArmor.free[2][2] - 1
            mArmor.reffreetime(2,armorCfg['maxFreeNum2'])
            remainnum = remainnum - 1
            num = num + 1
        end
        --普通
        if remainnum > 0 then
            for i=1,remainnum do
                if (mArmor.free[1][2] or 0)>0 then
                    local result=getRewardByPool(armorCfg['MatrixPool1'])
                    for k,v in pairs (result) do
                        table.insert(qreward,{[k]=v})
                        reward[k]=(reward[k] or 0)+v
                    end
                    mArmor.free[1][2] = mArmor.free[1][2] - 1
                    mArmor.reffreetime(1,armorCfg['maxFreeNum1'])
                    num = num + 1
                end
            end
        end
    end
    if remainnum >= 6 then
        -- 首次普通抽奖 送指定道具
        if mArmor.free[3][1] == 0 then
            mArmor.free[3][1] = 1
            reward[armorCfg.mustGet[1]] = armorCfg.mustGet[2]
            for k,v in pairs(reward) do
                table.insert(qreward,{[k]=v})
            end
            mArmor.free[1][2] = mArmor.free[1][2] - 1
            num = num + 1
        end

        -- 高级抽奖
        if (mArmor.free[2][2] or 0)>0 then
            advCnt = mArmor.incrAdvanceLotteryCnt(1)
            local result = {}
            if advCnt % armorCfg.maxNum == 0 then
                result=getRewardByPool(armorCfg['MatrixPool3'])
            else
                result=getRewardByPool(armorCfg['MatrixPool2'])
            end
            for k,v in pairs(result) do
                table.insert(qreward,{[k]=v})
                reward[k]=(reward[k] or 0)+v
            end
            mArmor.free[2][2] = mArmor.free[2][2] - 1
            mArmor.reffreetime(2,armorCfg['maxFreeNum2'])
            num = num + 1
        end
        --普通
        if (mArmor.free[1][2] or 0)>0 then
            for i=1,mArmor.free[1][2] do
                local result=getRewardByPool(armorCfg['MatrixPool1'])
                for k,v in pairs (result) do
                    table.insert(qreward,{[k]=v})
                    reward[k]=(reward[k] or 0)+v
                end
                mArmor.free[1][2] = mArmor.free[1][2] - 1
                mArmor.reffreetime(1,armorCfg['maxFreeNum1'])
                num = num + 1
            end
        end
    end    
    for k,v in pairs(qreward) do
        for k1,v1 in pairs(v) do
            table.insert(report, formatReward({[k1]=v1}))
        end
    end
    local ret,retw=takeReward(uid,reward)
    if not ret  then
        response.ret=-403
        return response
    end
   --和谐版
   if moduleIsEnabled('harmonyversion') ==1 and num>0 then
        local hReward,hClientReward = harVerGifts('funcs','armor',num)
        if not takeReward(uid,hReward) then
            response.ret = -403
            return response
        end
        response.data.hReward = hClientReward
    end 
    processEventsBeforeSave()
    if uobjs.save()  then 
        processEventsAfterSave()
        response.data.armor={}
        if type(retw)=="table" and next(retw) then
            response.data.amreward =retw.armor.info
        end
        response.data.armor.free=mArmor.free
        response.data.report=report
        response.ret = 0        
        response.msg = 'Success'
    end
    return response

end