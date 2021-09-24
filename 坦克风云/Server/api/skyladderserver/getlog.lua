function api_skyladderserver_getlog(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local ts = getClientTs()
    local action = request.params.action
    local zid = tonumber(request.params.zid)
    local id = tonumber(request.params.id)
    local page = tonumber(request.params.page) or 1

    if not action or not id then
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
    local data = across.getLogData(base.cubid,rtype,zid,id) or {}
    local allLog = json.decode(data.info) or {}

    local function concat(a,b)
        return a .. "-" .. b
    end

    -- 20170721 优化
    -- 从数据库取出pic,bpic,apic返回客户端
    if action == 1 then
        local uids = {}
        local defPic = {"","",""} -- 图像,图像框,挂件

        -- 得到日志中所有uid
        for k,v in pairs(allLog) do
            table.insert(uids,v.id1)
            if v.id2 then
                table.insert(uids,v.id2)
            end
        end

        if next(uids) then
            local uid2k = {} -- 记录uid对应的图像信息
            local persons = across.getPersonsByUids(base.cubid,uids)
            if type(persons) == "table" then
                for _,person in pairs(persons) do
                    uid2k[person.id] = {person.pic,person.bpic,person.apic}
                end
            end

            -- 设置日志对应的图像信息
            for k,v in pairs(allLog) do
                v.pic1 = uid2k[v.id1] or defPic
                if v.id2 then
                    v.pic2 = uid2k[v.id2] or defPic
                end
            end
        end

        uids,uid2k = nil,nil
    elseif action == 2 then
        -- 从数据库取出log返回客户端
        local aids = {}
        local defPic = "" -- 默认logo信息
        for k,v in pairs(allLog) do
           table.insert(aids,v.id1)
            if v.id2 then
                table.insert(aids,v.id2)
            end
        end

        if next(aids) then
            local aid2k = {}
            local alliances = across.getAlliancesByAids(base.cubid,aids)

             -- 军团id不是唯一,需要与服id拼接作标识
            if type(alliances) == "table" then
                for _,alliance in pairs(alliances) do
                    local logo = json.decode(alliance.logo)
                    if type(logo) ~= "table" or not next(logo) then logo = "" end
                    aid2k[concat(alliance.id,alliance.zid)] = logo
                end
            end

            for k,v in pairs(allLog) do
                v.pic1 = aid2k[concat(v.id1,v.z1)] or defPic
                if v.id2 then
                    v.pic2 = aid2k[concat(v.id2,v.z2)] or defPic
                end
            end
        end

        aids,aid2k = nil,nil
    end

    response.ret = 0
    response.msg = 'Success'
    response.data.allLog = allLog

    if ts > tonumber(base.overtime) or tonumber(base.over) == 1 then
        response.data.over = 1
    end

    return response
end