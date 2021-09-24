local alliancehelpLib = {}

function alliancehelpLib:getmylist(uid,ts, aid)
    local db = getDbo()
    local result = db:getAllRows("select id,type,et,mc,cc,info from alliancehelp where uid=:uid and et>:ts and aid=:aid",{uid=uid,ts=ts,aid=aid})

    if result then
        return result
    else
        return false
    end
end

function alliancehelpLib:getlistbyaid(aid,id,minid,ts,page_rows,uid)
    local db = getDbo()
    local page_rows = page_rows or 80

    local result
    result = db:getAllRows("select * from alliancehelp where   uid<>:uid and  aid=:aid  and (id < :minid or id > :id) and  et>:ts and  (mc>cc) order by id desc limit ".. page_rows, {aid=aid,id=id,ts=ts,minid=minid,uid=uid})
    if result then
        return result
    else
        return {}
    end
end



function alliancehelpLib:get(id)
    local db = getDbo()
    local result = db:getRow("select * from alliancehelp where id=:id",{id=id})

    if result then
        return result
    else
        return false
    end
end


function alliancehelpLib:Sent(data)
    local db = getDbo()
    local ret = db:insert('alliancehelp',data)
    if ret and ret > 0 then
        local id =db.conn:getlastautoid()
        return id
    end

    return false
end

function alliancehelpLib:del(id)
    local db,result = getDbo()
    result = db:query("delete from alliancehelp where id=" .. id )
    return result > 0
end

function alliancehelpLib:addhelpIncr(hid,et)
    local helpkey="z"..getZoneId()..".alliancehelp.count.hid.-"..hid
    local redis = getRedis()
    local count=redis:incr(helpkey)
    redis:expireat(helpkey,et+600) 
    return count
end

function alliancehelpLib:addhelpcount(id,count,et,ts,uid)

    local redis = getRedis()
    local helpkey="z"..getZoneId()..".alliancehelp.hid.-"..id
    redis:lpush(helpkey,uid)
    redis:expireat(helpkey,et+600) 
    local list=redis:lrange(helpkey,0,-1)
    list=json.encode(list)
    local db = getDbo()
    local sql="update alliancehelp set cc="..count..",list=".."'"..list.."'"..",updated_at="..ts..",et="..et.."  where id="..id
    if db:query(sql) then

        return true
    end
    
    return false
end

function alliancehelpLib:updatealliance(uid,aid)
    local db = getDbo()
    local aid=aid or 0
    local sql="update alliancehelp set aid="..aid.."  where uid="..uid
    if db:query(sql) then
        return true
    end
    
    return false
end

function alliancehelpLib:addhelplog(data)
    local db = getDbo()
    local ret = db:insert('alliancehelplog',data)
    if ret and ret > 0 then
        local id =db.conn:getlastautoid()
        return id
    end

    return false
end

function alliancehelpLib:gethelplist(uid)
    local db = getDbo()
    local result = db:getAllRows("select * from alliancehelplog where uid=:uid order by id desc limit 50 ",{uid=uid})
    local count = tonumber(self:logCount(uid))
    --清除帮助日志
    if count >50 then
        self:logClear(uid,count)
    end
    if result then
        return result
    else
        return false
    end
end

-- log清理
function alliancehelpLib:logClear(uid,log_nums)
    local max = 50
    local delNum = log_nums - max 

    if delNum > 0 then
        local db = getDbo()
        db:query("delete from alliancehelplog where uid = " .. uid .. " order by id asc limit " .. delNum)        
        return delNum
    end
end

function alliancehelpLib:logCount(uid)
    local db = getDbo()
    local count = 0
    local result = db:getRow("select count(id) as count from alliancehelplog where uid=:uid ",{uid=uid})    
    if  type(result)=='table' and next(result) then
        count=result.count
    end
    return count
end

return alliancehelpLib
