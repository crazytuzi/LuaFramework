function api_building_buyautoupgrade(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
      --没有开启自动升级
    if not getConfig("gameconfig").auto_build or getConfig("gameconfig").auto_build.enable~=1 then
        response.ret = -1
        return response
    end

    local uid = request.uid

    local useGem = request.params.useGem or 0

    if uid == nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mTech = uobjs.getModel('techs')
    local mBuildings = uobjs.getModel('buildings')
    local mBag = uobjs.getModel('bag')
     local mTask = uobjs.getModel('task')
    -- 刷新队列
    mBuildings.update()

    --检查是否已经使用自动建造
    local ts = getClientTs()
    -- if mBuildings.auto_expire > ts then
    --      error('use auto upgrade')
    --     response.ret = -1
    --     return response
    -- end

    --自动升级道具id
    local propId = "p2129"
    local propConfig =getConfig('prop')[propId]
    local propNum = mBag.getPropNums(propId)
    
    --使用金钱
    if useGem==1 then
        --判断是否有道具
        if propNum>0 then
            error('has prop')
            response.ret = -1
           return response
        end
        --扣除金钱
        if not mUserinfo.useGem(propConfig.gemCost) then
            error('no enough money'..tostring(propConfig.gemCost))
            response.ret = -1
            return response
        end

    else
        --判断是否有道具
        if propNum<=0 then
            error("no prop")
            response.ret = -1
            return response
        end
        --扣除道具
        if not mBag.use(propId,1) then
            error("can not use prop")
            response.ret = -1
            return response
        end
    end

    --更改数据
    if mBuildings.auto == 0 then
        mBuildings.auto = 1
        mBuildings.auto_expire = mBuildings.auto_expire + ts + propConfig.useDurationTime
    elseif mBuildings.auto == 1 then
        --过期的玩家
        if mBuildings.auto_expire < ts then
            mBuildings.auto_expire = ts
        end        
        mBuildings.auto_expire = mBuildings.auto_expire + propConfig.useDurationTime
    end

    -- 刷新队列
    mBuildings.autoUpgrade()
    mTask.check()
    --记录金钱消耗
    if useGem == 1 then
        regActionLogs(uid,1,{action=4,item=propId,value=propConfig.gemCost,params={}})
    else
        --消耗物品
        regActionLogs(uid,mUserinfo.vip,mUserinfo.level,5,{action=1000,item=pid,value=1,params={}})
    end

    processEventsBeforeSave()
    if uobjs.save() then

        --保存成功后，注册到定时任务
        local redis = getRedis()
        local key = "z"..getZoneId()..".autoUpgrade.alluids"
        local data = redis:get(key)
        data = data and json.decode(data) or {}
        local isInsert = true
        for k, v in pairs(data) do 
            if v.uid == uid then
                data[k] = {uid=uid, expire=mBuildings.auto_expire}
                isInsert = false
                break
            end
        end 
        if isInsert then
            table.insert(data, {uid=uid, expire=mBuildings.auto_expire})
        end
        --保存到缓存
        --redis:set(key, json.encode(data))

        -- --注册执行
        -- key = "z"..getZoneId()..".autoUpgrade.exect"
        -- local lastTime = redis:get(key)
        -- if not lastTime or ( lastTime + 15*60*60 ) < ts then
        --     local cronParams = {cmd ="admin.autobuilding",params={}}
        --     setGameCron(cronParams, 5*60)
        --     redis:set(key, ts)
        -- end

        response.data.userinfo = mUserinfo.toArray(true)
        response.data.buildings = mBuildings.toArray(true)
        response.data.bag = mBag.toArray(true)
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    else
        error("save erro")
        response.ret = -1
        response.msg = "save failed"
    end
       
    return response
end	