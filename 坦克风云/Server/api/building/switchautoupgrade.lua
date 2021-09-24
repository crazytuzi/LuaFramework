function api_building_switchautoupgrade(request)
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
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mBuildings = uobjs.getModel('buildings')
    local mTask = uobjs.getModel('task')
    
    local redis = getRedis()
    local ts = getClientTs()
    local self = {}
    --自动升级开关
    function self.switch(on)
        -- body
        if mBuildings.auto == on then
            return false
        end
        if mBuildings.auto_expire <= 0 then
            return false
        end 

        local key = "z"..getZoneId()..".autoUpgrade.alluids"
        local data = redis:get(key)
        data = data and json.decode(data) or {}  

        if on and on==1 then
            --开启恢复过期时间
            mBuildings.auto_expire = mBuildings.auto_expire + ts 
            --插入
            table.insert(data, {uid=uid, expire=mBuildings.auto_expire})

            --自动升级
            mBuildings.autoUpgrade()
            mTask.check()            
            --检测注册
            --self.registerCron()
        else
            --关闭计算剩余时间
            mBuildings.auto_expire = mBuildings.auto_expire - ts
            --删除
            local tempdata = {}
            for k, v in pairs(data) do 
                if v.uid ~= uid then
                    table.insert(tempdata, v)
                end
            end 
            data = tempdata           
        end

        --更新开关
        mBuildings.auto = on
        --同步到缓存
        -- redis:set(key, json.encode(data))

        return true
    end

    --注册计划任务
    -- function self.registerCron()
    --     -- body
    --     --注册执行
    --     local ts = getWeeTs()
    --     key = "z"..getZoneId()..".autoUpgrade.exect"
    --     local lastTime = redis:get(key)
    --     if not lastTime or ( lastTime + 15*60*60 ) < ts then
    --         local cronParams = {cmd ="admin.autobuilding",params={}}
    --         setGameCron(cronParams, 5*60)
    --         redis:set(key, ts)
    --     end

    -- end

    ----------------main------------------
    local on = request.params.on or 0

    self.switch(on)

    processEventsBeforeSave()
    if uobjs.save() then
        response.data.buildings = mBuildings.toArray(true)
        processEventsAfterSave()
        response.ret = 0
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = "save failed"
    end
       
    return response
end	