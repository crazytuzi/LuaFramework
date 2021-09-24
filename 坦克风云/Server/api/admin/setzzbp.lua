function api_admin_setzzbp(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local gmcfg = request.params.cfg
    if type(gmcfg)~='table' or not next(gmcfg) then
        response.ret = -102
        return response
    end
    -- 正式 对字符串处理
    local copytask = copyTable(gmcfg.task)
    local tlen = table.length(gmcfg.task)
    gmcfg.task = {}
    for i=1,tlen do
       table.insert(gmcfg.task,copytask[tostring(i)])
    end

    local copyzones = copyTable(gmcfg.zones)
    gmcfg.zones = {}
    for _,v in pairs(copyzones) do
        table.insert(gmcfg.zones,tonumber(v))
    end

    local zzbpCfg = getConfig("zzbp")
    local curCfg = zzbpCfg[tonumber(gmcfg.cfgid)]
    for k,v in pairs(curCfg.baseTask or {}) do
        for _,t in pairs(gmcfg.task) do
            if not table.contains(t,v) then
                table.insert(t,v)
            end
        end
    end

    local s = 0
    local p = 0
    local avoidtask = {}
    -- 计算全服的积分  个人总积分
    for k,v in pairs(gmcfg.task) do
        for t,tv in pairs(v) do
            if type(curCfg.taskList[tv])=='table' and  next(curCfg.taskList[tv]) and not table.contains(avoidtask,tv) then
                s = s + curCfg.taskList[tv].sScore
                p = p + curCfg.taskList[tv].pScore
                table.insert(avoidtask,tv)
            end
        end
    end

    gmcfg.pScore = p
    gmcfg.sScore = s
 
    require "model.zzbp"
    local zzbp = model_zzbp()
    local  flag,cfg = zzbp.check()
    
    -- 如果有在开启的需要检测
    -- 运营新配置的，需要返回提示 不做任何操作  如果修改当前的 则更新
    if flag then
        if cfg.groupid == gmcfg.groupid then
            if zzbp.upcfg(gmcfg.groupid,gmcfg) then
                response.ret = 0
                return response
            end
        end
      
        response.ret = - 100 -- 已经有开启
        return response
    end

    -- 清空本服的数据
    if zzbp.cleandata()  then
        -- 直接创建一条活动配置
        if zzbp.create(gmcfg) then
            response.ret = 0
            return response
        end
    end
    
    response.ret = -102

    return response

end