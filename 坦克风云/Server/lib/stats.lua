local statsLib = {}

local function getPrefix(name)
    local key = ""

    if name then
        key = "z"..getZoneId().."." .. name .. ".stats."
    else
        key =  "z"..getZoneId()..".md.stats."
    end

    return key
end

-- 装备统计
-- param data table
function statsLib.accessory(data)
    if type(data) ~= 'table' then return false end

    local key = getPrefix() .. "accessory"
    local redis = getRedis()
    local flags = {}

    for k,v in pairs(data) do
        flags[k] = redis:hincrby(key,k,v)
    end

    return flags
end

-- 装备统计，日常
-- param data table
function statsLib.accessory_daily(data)    
    if type(data) ~= 'table' then return false end

    local key = getPrefix() .. "accessory_daily"
    local redis = getRedis()
    local flags = {}
    local weeTs = getWeeTs() 
    
    for k,v in pairs(data) do
        flags[k] = redis:hincrby(key,weeTs..'_'..k,v)
    end

    return flags
end


-- 军团战统计，每日
-- param data table
function statsLib.alliancebattle_daily(data)    
    if type(data) ~= 'table' then return false end

    local key = getPrefix() .. "alliancebattle_daily"
    local redis = getRedis()
    local flags = {}
    local weeTs = getWeeTs() 
    
    local stats=redis:hget(key,tostring(weeTs))
    stats=json.decode(stats)
    if type(stats)~="table" then  stats={}  end
    table.insert(stats,data)
    local flags= redis:hset(key,tostring(weeTs),json.encode(stats))
    
    redis:hdel(key,tostring(weeTs-(7*24*3600)))
    return flags
end


--获取军团战的统计

function statsLib.getalliance()
    local data={}
    local key2 = getPrefix() .. "alliancebattle_daily"

    local accessoryData = redis:hgetall(key1)
    local accessoryDailyData = redis:hgetall(key2)
     if type(accessoryDailyData) == 'table' then
        for k,v in pairs(accessoryDailyData) do
            data.dailyData[k] = (data.dailyData[k] or 0) + (tonumber(v) or 0)
        end
    end

    return data

end

-- 获取统计数据
function statsLib.getAccessory()
    local data = {hasF0Users=0,hasAorFUsers=0,totalData={},dailyData={}}
    local tmp = {hasF0Users={},hasAorFUsers={}}
    local db = getDbo()
    local result = db:getRow("select count(*) as num from accessory");

    local num = result and tonumber(result.num) or 0
    local n = 0
    local i = 0
    while n < num do
        local limit1 = i * 100
        local limit2 = limit1 +99
        local result = db:getAllRows("select * from accessory order by uid limit " .. limit1 .. ","..limit2);

        if type(result) == 'table' then
            for _,ainfo in pairs(result) do
                local info = json.decode(ainfo.info)
                for k,v in pairs(info or {}) do 
                    if v[1] then
                        data[v[1]] = (data[v[1]] or 0) + 1 
                        if not tmp.hasAorFUsers[ainfo.uid] then
                            data.hasAorFUsers = data.hasAorFUsers + 1
                            tmp.hasAorFUsers[ainfo.uid] = 1
                        end
                    end
                end

                local used = json.decode(ainfo.used)
                for k,v in pairs(used or {}) do 
                    if type(v) =='table' then
                        for uk,uv in pairs(v) do
                            if uv[1] then                               
                                data[uv[1]] = (data[uv[1]] or 0) + 1 
                                if not tmp.hasAorFUsers[ainfo.uid] then
                                    data.hasAorFUsers = data.hasAorFUsers + 1
                                    tmp.hasAorFUsers[ainfo.uid] = 1
                                end
                            end
                        end
                    end
                end

                local fragment = json.decode(ainfo.fragment)                
                for k,v in pairs(fragment or {}) do          
                    if k == "f0" and not tmp.hasF0Users[ainfo.uid] then
                        data.hasF0Users = data.hasF0Users + 1
                    end

                    if v and v > 0 then
                        data[k] = (data[k] or 0) + v
                    end

                    if not tmp.hasAorFUsers[ainfo.uid] then
                        data.hasAorFUsers = data.hasAorFUsers + 1
                        tmp.hasAorFUsers[ainfo.uid] = 1
                    end
                end

                local props = json.decode(ainfo.props)                
                for k,v in pairs(props or {}) do                    
                    if v and v > 0 then
                        data[k] = (data[k] or 0) + v
                    end
                end

            end
        end

        n = limit2
        i = i + 1
    end

    local redis = getRedis()
    local key1 = getPrefix() .. "accessory"
    local key2 = getPrefix() .. "accessory_daily"

    local accessoryData = redis:hgetall(key1)
    local accessoryDailyData = redis:hgetall(key2)

    if type(accessoryData) == 'table' then
        for k,v in pairs(accessoryData) do
            data.totalData[k] = (data.totalData[k] or 0) + (tonumber(v) or 0)
        end
    end
    
    if type(accessoryDailyData) == 'table' then
        for k,v in pairs(accessoryDailyData) do
            data.dailyData[k] = (data.dailyData[k] or 0) + (tonumber(v) or 0)
        end
    end

    return data
end

function statsLib:statsGetInbox(uid)
    local db = getDbo()
    local result = db:getAllRows("select * from stats where uid=:uid and receiver=:uid",{uid=uid})

    if result then
    	return result
    else
        return false
    end
end

function statsLib:statsGetByType(uid,stats_type,maxeid,mineid,page_rows,isPage)
    local db = getDbo()
    local page_rows = page_rows or 10

    local result
    if isPage then
        result = db:getAllRows("select messageid, uid, sender, receiver, type, stats_from, stats_to, subject, isRead,update_at from stats where uid=:uid and type=:type and (messageid < :mineid or messageid > :maxeid) order by messageid desc limit ".. page_rows, {uid=uid,type=stats_type,maxeid=maxeid,mineid=mineid})
    else
        result = db:getAllRows("select messageid, uid, sender, receiver, type, stats_from, stats_to, subject, isRead,update_at from stats where uid=:uid and type=:type and messageid > :maxeid order by messageid desc", {uid=uid,type=stats_type,maxeid=maxeid})
    end

    if result then
        for k,v in pairs(result) do
            result[k] = self:statsFormat(v)
        end

        return result
    else
        return {}
    end
end

function statsLib:statsGetSent(uid,page)
    local db = getDbo()

    local result = db:getAllRows("select * from stats where uid=:uid and sender=:uid",{uid=uid})
    if result then
    	return  result
    else
        return false
    end
end

function statsLib:statsGet(uid,messageid)
    local db = getDbo()
    local result = db:getRow("select * from stats where uid=:uid and messageid=:messageid",{uid=uid,messageid=messageid})
    
    if result then  
        return self:statsFormat(result)
    else
        return false
    end
end

function statsLib:statsSent(uid,sender,receiver,stats_from,stats_to,subject,content,stats_type,isRead)
    local db = getDbo()
    
    local stats = {
        uid = tonumber(uid),
        sender = tonumber(sender),
        receiver = tonumber(receiver),
        stats_from = stats_from,
        stats_to = stats_to,
        subject = subject,
        content = content,
        type = stats_type or 0,
        isRead = isRead or 0,
        update_at = getClientTs(),
     }
     
     local ret = db:insert('stats',stats)
     
     if ret and ret > 0 then         
        stats.messageid = db.conn:getlastautoid()

        -- local uobjs = getUserObjs(uid,true)
        -- mUserinfo = uobjs.getModel('userinfo')

        -- if type(mUserinfo.flags.event) ~= 'table' then  mUserinfo.flags.event = {} end
        -- mUserinfo.flags.event.m = stats_type
                
        regSendMsg(uid,"msg.event",{event={m=stats_type}})
        
        return self:statsFormat(stats)
    end
     
     return false
end

function statsLib:statsDel(uid,messageid,stats_type)
    local db,result = getDbo()
    if stats_type and not messageid then
        result = db:query("delete from stats where uid=" .. uid .. " and type=" .. stats_type)
    else
        result = db:query("delete from stats where uid=" .. uid .. " and messageid=" .. messageid)
    end
    return result > 0
end

-- 侦察报告
function statsLib:statsDelScout(uid)
    local db = getDbo()    
    db:query("delete FROM `stats` WHERE `uid` = "..uid.."  AND `subject` LIKE '2-%'")
end

-- 列表
function statsLib:statsList(uid,maxeid,mineid,stats_type,isPage)
    local list = {}
    local page_rows = 10

    maxeid = maxeid or 0
    mineid = mineid or 0

    if stats_type == 1 then
        list.inbox = {}
        list.inbox.statss = self:statsGetByType(uid,1,maxeid,mineid,page_rows,isPage)
    elseif stats_type == 2 then
        list.report = {}
        list.report.statss = self:statsGetByType(uid,2,maxeid,mineid,page_rows,isPage)
    elseif stats_type == 3 then
        list.sent = {}
        list.sent.statss = self:statsGetByType(uid,3,maxeid,mineid,page_rows,isPage)
    end
    
    local count = self:statsCount(uid,stats_type)
    
    for k,v in pairs(count) do
        local n = tonumber(v.count) or 0
        local t = tonumber(v.type)

        if n>0 then 
            local deln= self:statsClear(uid,t,n) or 0
            n = n-deln
        end

        if t == 1 then 
            list.inbox.maxrows = n
        elseif t == 2 then 
            list.report.maxrows = n
        elseif t == 3 then 
            list.sent.maxrows = n
        end
    end
    
     list.unread = self:statsHasUnread(uid)

    return list
end

function statsLib:statsRead(uid,messageid)
    local stats = self:statsGet(uid,messageid)

    if stats and stats.isRead == "0" then
        local db = getDbo()

        if db:query("update stats set isRead = 1 where uid="..uid.." and messageid="..messageid) then
            stats.isRead = 1
        end        
    end

    return stats
end

function statsLib:statsCount(uid,stats_type)
    local db = getDbo()
    if stats_type then
        local result = db:getAllRows("select count(*) as count,type from stats where uid=:uid and type = :type",{uid=uid,type=stats_type})    
    else
        local result = db:getAllRows("select count(*) as count,type from stats where uid=:uid group by type",{uid=uid})    
    end    
    return result
end

function statsLib:statsFormat(stats)
    stats.content = json.decode(stats.content) or stats.content

    local format_stats = {
            eid = stats.messageid,
            type=stats.type,
            from=stats.stats_from,
            sender=stats.sender,
            to=stats.stats_to,
            title=stats.subject,
            content=stats.content,
            isRead=stats.isRead,
            ts = stats.update_at,
        }

    return format_stats
end

-- 邮件清理
function statsLib:statsClear(uid,stats_type,stats_nums)
    local max = {200,100,200}
    local delNum = stats_nums - max[stats_type]    
    if delNum > 0 then
        local db = getDbo()
        db:query("delete from stats where uid = " .. uid .. " and type = ".. stats_type .. " order by messageid asc limit " .. delNum)        
        return delNum
    end
end

-- 是否有可读的
-- return int 
function statsLib:statsHasUnread(uid)
    local count = {}
    local db = getDbo()
    local result = db:getAllRows("select count(*) as count, type from stats where uid=:uid and isRead = 0 group by type",{uid=uid})
    if type(result) == 'table' then
        for _,v in pairs(result) do
            count[v.type] = v.count
        end
    end
    return count
end

return statsLib