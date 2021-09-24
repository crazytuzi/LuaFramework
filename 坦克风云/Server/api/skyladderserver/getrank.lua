-- 读取天梯榜排名
function api_skyladderserver_getrank(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local ts = getClientTs()
    local action = request.params.action
    local page = tonumber(request.params.page) or 1

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
    local rankList = across.getRanking(base.cubid,rtype,page,100)
    
    -- 20170721 优化
    -- 从数据库取出pic,bpic,apic返回客户端
    if action == 1 then
        local uids = {}
        local uid2k = {}
        for k,v in pairs(rankList) do
           local t = string.split(v[1],"-") -- 第一位是zid-uid拼接的串
           table.insert(uids,t[2])
           uid2k[t[2]] = k -- uid对应ranklist的key
        end

        if next(uids) then
            local persons = across.getPersonsByUids(base.cubid,uids)
            if type(persons) == "table" then
                for _,person in pairs(persons) do
                    -- 设置图像信息,如果从数据库没有查到个人信息,客户端自己取默认值
                    table.insert(rankList[ uid2k[person.id] ],{person.pic,person.bpic,person.apic})
                end
            end
        end

        uids,uid2k = nil,nil
    elseif action == 2 then
        -- 从数据库取出log返回客户端
        local aids = {}
        local aid2k = {}
        for k,v in pairs(rankList) do
           local t = string.split(v[1],"-") -- 第一位是zid-aid拼的串
           table.insert(aids,t[2])
           aid2k[v[1]] = k -- zid-aid对应的rankList的key
        end

        if next(aids) then
            local alliances = across.getAlliancesByAids(base.cubid,aids)
            if type(alliances) == "table" then
                for _,alliance in pairs(alliances) do
                    local zidAid = alliance.zid .. "-" .. alliance.id
                    if aid2k[zidAid] then
                        local logo = json.decode(alliance.logo)
                        if type(logo) ~= "table" or not next(logo) then logo = "" end
                        table.insert(rankList[ aid2k[zidAid] ],logo)
                    end
                end
            end
        end

        aids,aid2k = nil,nil
    end

    response.ret = 0
    response.msg = 'Success'
    response.data.rankList = rankList

    if ts > tonumber(base.overtime) or tonumber(base.over) == 1 then
        response.data.over = 1
    end

    return response
end