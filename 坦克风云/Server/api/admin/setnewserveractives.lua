-- 设置新服活动
function api_admin_setnewserveractives(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local actives = request.params.actives
    local server  = tonumber(request.params.server)
    if type(actives) ~= 'table' and not next(active) then
        response.ret = -102 
        return response
    end

    local acfg
    local ts = getClientTs()
    require "model.active"
    local mActive = model_active()
    local newActive=getConfig('newActive')
    for k,v in pairs(actives) do
        if newActive[v.name]== 1 then
            acfg = getConfig("active/"..v.name)
        else
            acfg = getConfig("active." .. v.name)
        end

        -- 活动配置检测
        if not acfg then
            response.ret = -102 
            response.errmsg = "active config error"
            response.active = v.name
            return response
        end
        --时间检测 活动开始时间不能小于服务器时间
        local st = tonumber(v.st)
        if st<ts and server~=1 and getZoneId()~=1000 then
            response.ret = -102 
            response.errmsg = "st is error"
            response.active = v.name
            return response
        end
        -- 多版本活动的版本配置检测
        if v.cfg and acfg.multiSelectType==true then
            if not acfg[tonumber(v.cfg)] then
                response.ret = -102 
                response.errmsg = "active version error"
                response.active = v.name
                return response
            end
        end

        ----支持该活动的所有不用版本同时在线 
        if acfg['simultaneously'] then
            actives[k]['name']=v.name.."_"..(v.cfg or 1)
        end
        local nowactives = mActive.getActives(v.name)
        if next(nowactives) then
            for nk,nv in pairs(nowactives) do
                if tonumber(nv.et)+14400>st then
                    response.ret=-1
                    response.msg="date error"
                    return response
                end
            end

        end
    end

    local ret
        -- ptb:e(actives)
    for k,active in pairs (actives) do
        local st = tonumber(active.st)
        local et = tonumber(active.et)
        local activeId = false
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