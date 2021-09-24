function api_alliance_find(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local allianceName = request.params.name or ''

    local uid = request.uid 

    if uid == nil then
        response.ret = -102
        return response
    end

    local list, err = M_alliance.search{name=allianceName}

    if not list then
        response.ret = err
        return response
    end    

    if list.data and list.data.searchlist then
        for k,v in pairs(list.data.searchlist) do
            -- 2018/4/10 优化去掉军团资金，外挂会通过列表获取到其它军团剩余资金
            v.point = nil
        end
    end

    response.data.alliance = list.data
    response.ret = 0
    response.msg = 'Success'

    return response
end 