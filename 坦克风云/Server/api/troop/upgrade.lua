function api_troop_upgrade(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local aid = request.params.aid and 'a' .. request.params.aid
    local bid = request.params.bid and 'b' .. request.params.bid
    local nums = tonumber(request.params.nums) or 0

    if uid == nil or aid == nil or bid == nil or nums < 1 then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local mBuilding = uobjs.getModel('buildings')

    if not mTroop.troops[aid] then 
        response.ret = -102
        return response
    end

    -- 刷新队列
    mTroop.upgradeupdate()

    -- 解锁验证
    if not mBuilding.shipUpIsUnlock(aid,bid) then
        response.ret = -114
        return response
    end
    
    nums = math.floor(nums)
            
    local qName = mTroop.bid2Qname(bid)
    local ts = getClientTs()
    local cfg = getConfig('tank.' .. aid)
    local bTankConsume = cfg.upgradeShipConsume
    
    -- 此坦克不能改装
    if not next(bTankConsume)  then  
        response.ret = -123
        return response
    end

    -- 升级需要消耗的坦克数
    local iTanks = bTankConsume[2] * nums
    if iTanks > mTroop.troops[bTankConsume[1]] or not mTroop.consumeTanks(bTankConsume[1],iTanks) then 
        response.ret = -115
        return response
    end

    -- 改装需要的道具
    local bPropConsume = cfg.upgradePropConsume
    if type(bPropConsume) == 'table' and next(bPropConsume) then
        local mBag = uobjs.getModel('bag')
        
        for _,v in ipairs(bPropConsume) do
            local tmpNum = v[2] * nums
            if not mBag.use(v[1],tmpNum) then
                response.ret = -1996
                return response
            end
        end
        response.data.bag = mBag.toArray(true)
    end
 
    local bRes = {}
    bRes.r1 = nums * cfg.upgradeMetalConsume
    bRes.r2 = nums * cfg.upgradeOilConsume
    bRes.r3 = nums * cfg.upgradeSiliconConsume
    bRes.r4 = nums * cfg.upgradeUraniumConsume
    bRes.gold = nums * cfg.upgradeMoneyConsume

    if not mUserinfo.useResource(bRes) then
        response.ret = -107
        return response
    end 

    -- 单个生产时间*生产数量*技能指数
    local iConsumeTime = mTroop.getUpLevelTimeConsume(aid,bid,'upgradeTimeConsume',ts) * nums      
    local bSlotInfo = {
        st=ts,
        id=aid,
        nums=nums,
        bid=bid,
    }            
    bSlotInfo.et = iConsumeTime + ts 
    bSlotInfo.timeConsume = iConsumeTime

    -- 使用队列失败
    if not mTroop.useSlot(bSlotInfo,qName) then
        response.ret = -1997
        return response     
    end
          
    --local ret = mTroop.upgrade(aid,request.params.nums,bid)
    
    local mTask = uobjs.getModel('task')
    mTask.check()    

    processEventsBeforeSave()

    if uobjs.save() then     
        processEventsAfterSave()    
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.troops = mTroop.toArray(true)
        response.ret = 0	    
        response.msg = 'Success'
        ------------------------消息推送 start ----------------------------------------   
        if type (request.push)=='table' then
            if request.push.tb[4]~=nil and request.push.tb[4]==1 then

                local execRet, code=M_push.addPushMsg({bindid=request.push.binid,ts=bSlotInfo.et,t=3,pt=request.system,lag=request.lang,msg=aid,id=uid..aid,l=nums,appid=request.appid})
            end
            -- --加速以后删除消息
            -- local execRet, code=M_push.delPushMsg({bindid=request.push.binid,ts=bSlotInfo.et,id=uid..aid})
            --     ptb:e(execRet)
        end
        ------------------------消息推送 end   ----------------------------------------
    else
	response.ret = -1
    end
    
    return response
end	