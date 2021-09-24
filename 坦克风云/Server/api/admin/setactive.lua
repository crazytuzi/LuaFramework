function api_admin_setactive(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local active = request.params
    if type(active) ~= 'table' or not active.name then
        response.ret = -102 
        return response
    end
    local activeCfg = getConfig("active")
    local newActive=getConfig('newActive')
    local acfg = activeCfg[active.name]
    if newActive[active.name]== 1 then
        acfg = getConfig("active/"..active.name)
    end

    -- 活动配置检测
    if not acfg then
        response.ret = -102 
        response.errmsg = "active config error"
        response.active = active.name
        return response
    end

    -- 多版本活动的版本配置检测
    if active.cfg and acfg.multiSelectType==true then
        if not acfg[tonumber(active.cfg)] then
            response.ret = -102 
            response.errmsg = "active version error"
            response.active = active.name
            return response
        end

        -- 这是测试版本,只允许在 993和994 服开放
        if acfg[tonumber(active.cfg)]._TESTVERSION then
            local zoneId = getZoneId()
            if zoneId ~= 993 and zoneId ~= 994 then
                response.ret = -102
                response.err = "The version is a test config"
                return response
            end
        end
    end

    ----支持该活动的所有不用版本同时在线 
    if acfg['simultaneously'] then
        active.name=active.name.."_"..(active.cfg or 1)
    end
    require "model.active"

    local mActive = model_active()

    if active.name and (active.name == "chongzhiyouli" or active.name == "zhenqinghuikui") and active.selfcfg then
        local base64 = require "lib.base64"
        active.selfcfg = json.decode(active.selfcfg)
        if active.selfcfg["activeTitle"] then
            active.selfcfg["activeTitle"] = base64.Decrypt(active.selfcfg["activeTitle"])
        end
        if active.selfcfg["gamename"] then
            active.selfcfg["gamename"] = base64.Decrypt(active.selfcfg["gamename"])
        end
        active.selfcfg = json.encode(active.selfcfg)
    end

    local ret = false
    if active.id then
        local et = tonumber(active.et)
        local actives = mActive.getActives(active.name)
        if next(actives) then
            for k,v in pairs(actives) do
                if  v.id==active.id then
                    ret = mActive.setActive(active.id,active)
                    break
                end
            end
        end     
    else

        local st = tonumber(active.st)
        local et = tonumber(active.et)
        local actives = mActive.getActives(active.name)
        local activeId = false
        if next(actives) then

            for k,v in pairs(actives) do
                if tonumber(v.et)+14400>st then
                    response.ret=-1
                    response.msg="date error"
                    return response
                    
                end
            end

        end
        if activeId then
            ret = mActive.setActive(tonumber(activeId),active)
        else
            ret = mActive.createActive(active)
        end
    end

    if ret then    
        response.ret = 0
        response.msg = 'Success'
    end

    return response

end