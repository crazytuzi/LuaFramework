function api_troop_add(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local aid = request.params.aid
    local bid = request.params.bid
    local nums = request.params.nums or 0

    nums = math.floor(nums)
    if uid == nil or aid == nil or bid == nil or nums < 1 then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    local aid =  'a' .. aid
    local bid = 'b' .. bid

    local uobjs = getUserObjs(uid) 
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTroop = uobjs.getModel('troops')
    local mBuilding = uobjs.getModel('buildings')
    
    -- 刷新当前队列
    mTroop.update()    

    -- 坦克未解锁
    if not mBuilding.shipIsUnlock(aid,bid) then
        response.ret = -114
        return response
    end

    local cfg = getConfig('tank.' .. aid)
    local ts = getClientTs()

    -- 生产的总时间=单量生产时间*生产数量，
    -- 需要考虑建筑对时间的加成
    local iConsumeTime = mTroop.getUpLevelTimeConsume(aid,bid,'timeConsume',ts) * nums            
    
    local bSlotInfo = {
        st=ts,
        id=aid,
        nums=nums,
        bid=bid,
    }
    -- 新队列完成与消耗的时间
    bSlotInfo.et = iConsumeTime + ts 
    bSlotInfo.timeConsume = iConsumeTime 

    -- 使用队列
    if not mTroop.useSlot(bSlotInfo,mTroop.bid2Qname(bid)) then
        response.ret = -1997
        return response
    end

    local bRes = {}
    bRes.r1 = nums * cfg.metalConsume
    bRes.r2 = nums * cfg.oilConsume
    bRes.r3 = nums * cfg.siliconConsume
    bRes.r4 = nums * cfg.uraniumConsume
    
    -- 使用资源
    if not mUserinfo.useResource(bRes) then
        response.ret = -107
        return response
    end
     -- 
    local bPropConsume = cfg.propConsume
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
        if type (request.push)=='table' and moduleIsEnabled('push') ==1 then
            if request.push.tb[4]~=nil and request.push.tb[4]==1 then

                local execRet, code=M_push.addPushMsg({bindid=request.push.binid,ts=bSlotInfo.et,t=3,pt=request.system,lag=request.lang,msg=aid,id=uid..aid,l=nums,appid=request.appid})
            end
            
        end
        ------------------------消息推送 end   ----------------------------------------   

    else
        response.ret = -1
        response.msg = "save failed"
    end
    
    return response
end	