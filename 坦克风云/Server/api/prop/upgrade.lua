function api_prop_upgrade(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local pid = request.params.pid
    local nums = request.params.nums or 1
    nums = math.floor(nums)

    if uid == nil or pid == nil or nums <1 then
        response.ret = -102
        response.msg = 'params invalid'
        return response
    end

    pid = 'p' .. pid

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mProp = uobjs.getModel('props')
    local mBag = uobjs.getModel('bag')

    

    -- 制造车间等级不够
    local mBuilding = uobjs.getModel('buildings')
    if tonumber(mBuilding.getLevel('b6')) < 1 then
        response.ret = -7001
        response.msg = 'building level invalid'
        return response
    end

    -- 刷新生产队列
    mProp.update()

    -- 是否可生产    
    if not mProp.isAbleProduce(pid) then
        response.ret = -1999
        return response
    end

    local reduce = 0
    if pid=='p3417' then
        local mSkills = uobjs.getModel('skills')
        -- 这个技能可以减少生产道具的时间
        if mSkills['s301']<1 then
            response.ret = -1999
            return response
        end
        local skillcfg = mSkills.getConfig('s301')

        reduce = (mSkills['s301']-1)*skillcfg.skillValue*nums
    end

    local cfg = getConfig('prop.' .. pid)


    local iMaxCount = tonumber(cfg.maxCount)        
    local iCurrCount = mBag.getPropNums(pid)
    local iAllCount = iCurrCount + nums        

    if iAllCount > iMaxCount then
        nums = nums - (iAllCount - iMaxCount)
    end
    
    -- 建筑等级影响速度            
    local iConsumeTime = mProp.getUpLevelTimeConsume(pid,'b6') * nums-reduce    
    local ts = getClientTs()
    local bSlotInfo = {
        st=ts,
        id=pid,
        nums=nums
    }
    bSlotInfo.et = iConsumeTime + ts 
    bSlotInfo.timeConsume = iConsumeTime

    if not mProp.useSlot(bSlotInfo) then
        response.ret = -1997
        return response
    end

    -- 资源，道具需求
    local bResources = {}
    bResources.gold = nums * (tonumber(cfg.moneyConsume) or 0)    
    local propConsume = arrayGet(cfg,'propConsume')
    local propConsumeNums = propConsume[2] * nums

    if propConsume and not mBag.use(propConsume[1],propConsumeNums) then
        response.ret = -1996
        return response
    end

    if not mUserinfo.useResource(bResources) then
        response.ret = -107
        return response
    end  

    local mTask = uobjs.getModel('task')
    mTask.check()

    regActionLogs(uid,5,{action=1,item=pid,value=nums,params={n=propConsumeNums,pid=propConsume[1]}})
    processEventsBeforeSave()

    if uobjs.save() then 
        processEventsAfterSave()
        response.data.userinfo = mUserinfo.toArray(true)
        response.data.bag = mBag.toArray(true)
        response.data.props = mProp.toArray(true)
        response.ret = 0	    
        response.msg = 'Success'
        ------------------------消息推送 start ----------------------------------------   
        if type (request.push)=='table' and moduleIsEnabled('push') ==1 then
            if request.push.tb[5]~=nil and request.push.tb[5]==1 then

                local execRet, code=M_push.addPushMsg({bindid=request.push.binid,ts=bSlotInfo.et,t=4,pt=request.system,lag=request.lang,msg=pid,id=uid..pid,l=nums,appid=request.appid})
            end
           
        end
        ------------------------消息推送 end   ----------------------------------------   
    else
        response.ret = -1
        response.msg = "save failed"
    end
    
    return response
end	