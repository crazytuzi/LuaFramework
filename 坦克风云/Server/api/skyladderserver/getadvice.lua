-- 读取天梯
function api_skyladderserver_getadvice(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local ts = getClientTs()
    local action = request.params.action
    local battleType = tonumber(request.params.battleType) or 1
    local num = tonumber(request.params.num) or 3
    local groupnum = tonumber(request.params.groupnum) or 4
    local allServer = request.params.allServer or {1,2,3,4,5,6,7,8}

    if not action then
        response.ret = -102
        return response
    end
    
    require "model.skyladderserver"
    local across = model_skyladderserver()

    local rtype
    if action == 1 then
        rtype = 'person'
    elseif action == 2 then
        rtype = 'alliance'
    else
        response.ret = -102
        return response
    end
    
    local base = across.getStatus()
    local countId = tonumber(base.lsbid) ~= 0 and base.lsbid or base.cubid
    local rankList = across.getSkyladder(countId,rtype,battleType,num)

    local skyladderServer = {}
    local inListGroup = {}
   
    -- 统计有天梯分数据的服务器id
    for i,v in pairs(rankList) do
        if v and type(v) == 'table' and v.zid then
            local new = false
            if not skyladderServer[tostring(v.zid)] then
                skyladderServer[tostring(v.zid)] = 1
                table.insert(inListGroup,v.zid)
            end
        end
    end
                
    -- 统计没有天梯分数据的服务器id
    local noListGroup = {}
    for i,v in pairs(allServer) do
        if not skyladderServer[tostring(v)] then
            skyladderServer[tostring(v)] = 1
            table.insert(noListGroup,v)
        end
    end

    
    local group = {}
    local length = #inListGroup
    local iGroup = {}
    
    -- 有天梯分的分组
    for i=1,length do
        table.insert(iGroup,tonumber(inListGroup[i]))
        if i % groupnum == 0 or i == length then
            table.insert(group,iGroup)
            iGroup = {}
        end
    end
    
    -- 没有天梯分的分组
    local length = #noListGroup
    local iGroup = {}
    for i=1,length do
        table.insert(iGroup,tonumber(noListGroup[i]))
        if i % groupnum == 0 or i == length then
            table.insert(group,iGroup)
            iGroup = {}
        end
    end

    response.ret = 0
    response.msg = 'Success'
    response.data.group = group

    return response
end