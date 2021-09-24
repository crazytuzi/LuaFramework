function api_admin_getactive(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local db = getDbo()
    local result

    local result = db:getAllRows("select id,name,type,cfg,st,et from active order by et desc limit 200")
    if result then
        for i,v in pairs(result) do
            local tmpCfg = getConfig('active.'..v['name']) or getConfig('active/' ..v['name'])
            result[i]['maxCfg'] = 1
            if type(tmpCfg) == 'table' and tmpCfg.multiSelectType then
                local tmpCount = 0
                for _,_ in pairs(tmpCfg) do
                    tmpCount = tmpCount + 1
                end
                result[i]['maxCfg'] = tmpCount - 1
            end
        end
    end
    response.data.active = result
    response.ret = 0
    response.msg = 'Success'
    
    return response

end