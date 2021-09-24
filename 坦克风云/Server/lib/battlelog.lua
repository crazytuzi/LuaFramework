local battlelogLib = {}



function battlelogLib:logFormat(log)
    log.content = json.decode(log.content) or log.content

    local format_log = {
            eid = log.id,
            type=log.type,
            dfname=log.dfname,
            isvictory=log.isvictory,
            receiver=log.receiver,
            rank=log.rank,
            content=log.content,
            isRead=log.isRead,
            ts = log.update_at,
        }

    return format_log
end
function battlelogLib:logExpeditionFormat(log,flag)
    log.content = json.decode(log.content) or log.content

    local format_log = {
            id = log.id,
            eid = log.eid,
            type=log.type,
            dfname=log.dfname,
            dlvl=log.dlvl,
            isvictory=log.isvictory,
            receiver=log.receiver,
            rank=log.rank,
            --content=log.content,
            isRead=log.isRead,
            update_at = log.update_at,
        }
    if flag then
        format_log.content = log.content
    end
    
    return format_log
end

function battlelogLib:logExpeditionSent(uid,receiver,dfname,atype,isVictory,eid,dlvl,log)

    local db = getDbo()
    local newlog = ""
    if type(log)=="table" then
        newlog=json.encode(log)
    end
    local logs = {
        uid = tonumber(uid),
        eid = eid,
        receiver = tonumber(receiver),
        dfname = dfname,
        dlvl = dlvl,
        type = atype,
        isvictory=isVictory,
        content = newlog,
        update_at = getClientTs(),
    }
     
    local ret = db:insert('userexpeditionlog',logs)
    if ret and ret > 0 then         
        logs.id = db.conn:getlastautoid()
        logs.content=log
        regSendMsg(uid,"msg.event",{event={e=logs}})
        return logs
    end
     
    return false

end

function battlelogLib:logSent(uid,receiver,dfname,atype,isVictory,log,ranking)
    local db = getDbo()
    local rank = 0
    if atype==1 then
        if ranking>0 then
            rank=ranking
        end
    else
        if ranking<0 then
            rank=ranking
        end

    end
    if type(log)=="table" then
        log=json.encode(log)
    end
    local logs = {
        uid = tonumber(uid),
        receiver = tonumber(receiver),
        dfname = dfname,
        type = atype,
        rank=rank,
        isvictory=isVictory,
        content = log,
        update_at = getClientTs(),
     }
     
     local ret = db:insert('userarenalog',logs)
     
     if ret and ret > 0 then         
        logs.id = db.conn:getlastautoid()

        -- local uobjs = getUserObjs(uid,true)
        -- mUserinfo = uobjs.getModel('userinfo')

        -- if type(mUserinfo.flags.event) ~= 'table' then  mUserinfo.flags.event = {} end
        -- mUserinfo.flags.event.m = log_type
                
       regSendMsg(uid,"msg.event",{event={r=1}})
        
        return logs
    end
     
    return false
end



function battlelogLib:logDel(uid,id)
    local db,result = getDbo()
    
    result = db:query("delete from userarenalog where uid=" .. uid .. " and id=" .. id)
    
    return result
end

--获取远征军的战报
function battlelogLib:logExpeditionList(uid)
    local db = getDbo()
   
    local result = db:getAllRows("select id,uid,eid,receiver, type, dfname,dlvl,isvictory,content,update_at from userexpeditionlog where uid=:uid order by update_at ASC", {uid=uid})
    if result then
        local len =#result
        if len>10 then
            for i=1,len-10 do
                battlelogLib:logExpeditionDel(uid,result[1].id)
                table.remove(result,1)
            end
        end
        for k,v in pairs(result) do
            result[k] = self:logExpeditionFormat(v)
        end

        return result
    else
        return {}
    end
end
--删除远征军的战报    
function battlelogLib:logExpeditionDel(uid,id)
    local db,result = getDbo()
    
    result = db:query("delete from userexpeditionlog where uid=" .. uid .. " and id=" .. id)
    return result
end

-- 获取远征军某一条战报
function battlelogLib:logExpeditionByid(uid,id)
    local db = getDbo()
    local result = db:getRow("select id,uid,eid,receiver, type, dfname,dlvl,isvictory,content,update_at from userexpeditionlog where uid=" .. uid .. " and id=" .. id)
    if type(result) == 'table' and next(result) then
        return self:logExpeditionFormat(result,true)
    end

    return {}
end

function battlelogLib:logGetByType(uid,maxeid,mineid,page_rows,isPage,content)
    local db = getDbo()
    local page_rows = page_rows or 10

    local result
    if isPage then
        result = db:getAllRows("select id, uid,receiver, type, dfname, isvictory, rank, content, isRead,update_at from userarenalog where uid=:uid   and  (id < :mineid or id > :maxeid) order by id desc limit ".. page_rows, {uid=uid,maxeid=maxeid,mineid=mineid})
    else
        if content~=nil then
            result = db:getAllRows("select id, uid,receiver, type, dfname, isvictory, rank, isRead,update_at from userarenalog where uid=:uid  and id > :maxeid order by id desc limit "..page_rows, {uid=uid,maxeid=maxeid})
        else
            result = db:getAllRows("select id, uid,receiver, type, dfname, isvictory, rank,content, isRead,update_at from userarenalog where uid=:uid  and id > :maxeid order by id desc limit "..page_rows, {uid=uid,maxeid=maxeid})
        end
        
    end
    if result then
        for k,v in pairs(result) do
            result[k] = self:logFormat(v)
        end

        return result
    else
        return {}
    end
end


-- 战报清理
function battlelogLib:logClear(uid,log_nums)
    local max = 50
    local delNum = log_nums - max 

    if delNum > 0 then
        local db = getDbo()
        db:query("delete from userarenalog where uid = " .. uid .. " order by id asc limit " .. delNum)        
        return delNum
    end
end

-- 列表
function battlelogLib:logList(uid,maxeid,mineid,isPage,content)
    local list = {}
    local page_rows = 10

    maxeid = maxeid or 0
    mineid = mineid or 0
    list = self:logGetByType(uid,maxeid,mineid,page_rows,isPage,content)
    
    
    local count = tonumber(self:logCount(uid))
    
    if count >50 then

        self:logClear(uid,count)
        count=50
    end
    
    list.maxrows = count
    list.unread = self:logHasUnread(uid)

    return list
end

--  return int
function battlelogLib:logCount(uid)
    local db = getDbo()
    local count = 0
    local result = db:getRow("select count(*) as count from userarenalog where uid=:uid ",{uid=uid})    
    if  type(result)=='table' and next(result) then
        count=result.count
    end
    return count
end

function battlelogLib:logRead(uid,id)
    local log = self:logGet(uid,id)

    if log and log.isRead == "0" then
        local db = getDbo()

        if db:query("update userarenalog set isRead = 1 where uid="..uid.." and id="..id) then
            log.isRead = 1
        end        
    end

    return log
end

function battlelogLib:logReadAll(uid)
    local db = getDbo()

    if db:query("update userarenalog set isRead = 1 where uid="..uid.." and isRead=0") then
        return true
    end        

    return false
end

function battlelogLib:logGet(uid,id)
    local db = getDbo()
    local result = db:getRow("select * from userarenalog where uid=:uid and id=:id",{uid=uid,id=id})
    
    if result then  
        return self:logFormat(result)
    else
        return false
    end
end

-- 是否有可读的
-- return int 
function battlelogLib:logHasUnread(uid)
    local count = 0
    local db = getDbo()
    local result = db:getRow("select count(*) as count from userarenalog where uid=:uid and isRead = 0 ",{uid=uid})
    if type(result) == 'table' then
        count =result.count
    end
    return count
end

---     区域站战报获取
function battlelogLib:areaLogGet(id)
    local db = getDbo()
    local result={}
    local result = db:getRow("select * from areawarlog where id=:id ",{id=id})
    return result
end
-- 区域站获取战报list
function battlelogLib:areaLogGetList(uid,id,method,aid)
    local db = getDbo()
    local result={}
    method =method or 2 
    aid = aid or 0
    if method==1 then
        result = db:getAllRows("select id,btype,attname,defname,attaname,defaname,win,occupy,updated_at from areawarlog where (attaid=:aid or defaid=:aid) and id>=:id  order by id desc limit 50",{aid=aid,id=id})
    else
        result = db:getAllRows("select id,btype,attuid,defuid,attname,defname,attaname,defaname,win,occupy,updated_at from areawarlog where (attuid=:uid or defuid=:uid) and id>=:id  order by id desc limit 50",{uid=uid,id=id})
    end
    
    return  result
end
-- 区域站发送战报
function battlelogLib:areaLogSend(data)
    local db = getDbo()
    local ids={}
    if type(data)=='table' and next(data) then
        for k,logs in pairs(data) do
            if  type(logs)=='table' and next(logs) then
                if logs.updated_at==nil then
                    logs.updated_at=getClientTs()
                end
                if type(logs.report)=="table" then
                    logs.report=json.encode(logs.report)
                end
                local attuid=logs.attuid
                local ret = db:insert('areawarlog',logs)
                if ret and ret > 0 then         
                    local id = db.conn:getlastautoid()
                    regSendMsg(attuid,"msg.event",{event={areawar=id}})
                    table.insert(ids,id)
                    if logs.defuid>0 then
                        regSendMsg(logs.defuid,"msg.event",{event={areawar=id}})
                    end
                end
            end
        end
        return ids

    end
     
    return false
    
end



-- 击杀叛军增加记录
function battlelogLib:allianceLogSend(data,uid,x,y)
    local db = getDbo()
    local ret = db:insert('allianceforceslog',data)
     
    if ret and ret > 0 then         
       data.id = db.conn:getlastautoid()
       data.x=x
       data.y=y
       regSendMsg(uid,"map.change",data)  

       return data
    end
     
    return false
end

-- 击杀叛军查询记录
function battlelogLib:allianceLogGet(aid,uid)
    local redis = getRedis()
    local key = "z"..getZoneId()..".killrebelforces."..uid..'weets'..getWeeTs()
    local logkey = "z"..getZoneId()..".rebelforceslog."..aid
    local data={}
    local db = getDbo()
    local killcount=0
    data=redis:get(logkey)
    killcount=redis:get(key) or 0
    if data~=nil then

        return json.decode(data),killcount
    else
        data={}
    end
    local db = getDbo()
    local result = db:getAllRows("select * from allianceforceslog where aid=:aid and kill_at>:kill_at  order by id desc limit 10",{aid=aid,kill_at=getWeeTs()})

    if result==nil then
      result={}
      data=result
    end
    if next(result) then
        for k,v in pairs(result) do
            table.insert(data,{v.rfname,v.dieid,v.kill_at,v.lvl,v.name})
        end
    end
    redis:set(logkey,json.encode(data))
    redis:expireat(logkey,getWeeTs()+24*3600)
    return data,killcount
end

-- 获取数据
function battlelogLib:allianceLogGetData(data)
    local db = getDbo()
    local result = db:getAllRows("select * from allianceforceslog where dieid in ("..table.concat(data,",")..")")

    if result==nil then
      result={}
    end
    return result
end

--更新数据
function battlelogLib:annealLogSend(uid, data, starTs, expireTs)
    local db = getDbo()
    local result = db:getRow("select * from annealog where uid=:uid" , {uid=uid})

    if type(result) == 'table' then
        local info = {}
        if tonumber(result['updated_at']) <= expireTs and tonumber(result['updated_at']) >= starTs then --插入最后
            info = json.decode(result['info']) or {}
            table.insert(info, data)
            if #info > 10 then
                table.remove(info, 1)
            end
        else --新的任务重新记录
            table.insert(info, data)
        end

        db:update("annealog", {info=info, updated_at=getClientTs()}, "uid=" .. uid)
    else
        db:insert("annealog", {info={data}, updated_at=getClientTs(), uid=uid})
    end
end

--查看数据
function battlelogLib:annealLogGet(uid, starTs)
    local db = getDbo()
    local result = db:getRow("select * from annealog where uid=:uid" , {uid=uid})
    if type(result) == 'table' and tonumber(result['updated_at']) >= starTs then
        return json.decode(result['info']) or {}
    end    
    return {}
end

-- 更新异星武器战报
function battlelogLib:logAweaponSent(uid, report, log_type, isvictory, dfname)
    local logs = {
        uid=uid,
        content= json.encode(report),
        type = log_type,
        isvictory = isvictory,
        dfname = dfname,
        ts= getClientTs(),
    }
    local db = getDbo()
    local ret = db:insert('alienweaponlog',logs)
    if ret and ret > 0 then         
        logs.id = db.conn:getlastautoid()
        logs.content=report
        if log_type == 2 then
            regSendMsg(uid,"msg.event",{event={awattack=isvictory, type=log_type}})
        end
        return logs
    end
    return false
end

-- 获取战报
function battlelogLib:logAweaponGet(uid, log_type, maxeid, mineid, isPage, content)
    local list = {}
    local page_rows = 10

    maxeid = maxeid or 0
    mineid = mineid or 0
    list = self:logAweaponGetByType(uid,maxeid,mineid,page_rows,isPage,content,log_type)
        
    local count = tonumber(self:logAweaponCount(uid, log_type))
    
    if count>20 then
        self:logAweaponClear(uid,log_type,count)
        count=20
    end
    
    list.maxrows = count
    list.unread = self:logAweaponHasUnread(uid, log_type)

    return list
end

-- 获取异星武器战报
function battlelogLib:logAweaponGetByType(uid,maxeid,mineid,page_rows,isPage,content,log_type)
    local db = getDbo()

    local result
    if isPage then
        result = db:getAllRows("select id,uid,content,isRead,isvictory,dfname, ts from alienweaponlog where uid=:uid and (id < :mineid or id > :maxeid) and type=:log_type order by id desc limit ".. page_rows, {uid=uid,maxeid=maxeid,mineid=mineid,log_type=log_type})
    else
        if content~=nil then
            result = db:getAllRows("select id,uid, isRead,isvictory,dfname, ts from alienweaponlog where uid=:uid and  id > :maxeid and type=:log_type order by id desc limit "..page_rows, {uid=uid,maxeid=maxeid,log_type=log_type})
        else
            result = db:getAllRows("select id,uid,content,isRead,isvictory,dfname, ts from alienweaponlog where uid=:uid and  id > :maxeid and type=:log_type order by id desc limit "..page_rows, {uid=uid,maxeid=maxeid,log_type=log_type})
        end
        
    end
    if result then
        for k,v in pairs(result) do
            if v.content then
                v.content = json.decode(v.content)
            end
        end

        return result
    else
        return {}
    end
end

-- 获取战报数量
function battlelogLib:logAweaponCount(uid, log_type)
    local db = getDbo()
    local count = 0
    local result = db:getRow("select count(*) as count from alienweaponlog where uid=:uid and type=:log_type",{uid=uid, log_type=log_type})    
    if  type(result)=='table' and next(result) then
        count=result.count
    end
    return tonumber(count)
end

-- 战报清理
function battlelogLib:logAweaponClear(uid,log_type, log_nums)
    local max = 20
    local delNum = log_nums - max 

    if delNum > 0 then
        local db = getDbo()
        db:query("delete from alienweaponlog where uid = " .. uid .. " and type = ".. log_type .. " order by id asc limit " .. delNum)
        return delNum
    end
end

function battlelogLib:logAweaponGetById(uid,id)
    local db = getDbo()
    local result = db:getRow("select * from alienweaponlog where uid=:uid and id=:id",{uid=uid,id=id})
    
    if result then  
        result.content = json.decode(result.content)
        if tonumber(result.isRead) == 0 and db:query("update alienweaponlog set isRead = 1 where uid="..uid.." and id="..id) then
            result.isRead = 1
        end         
        return result
    else
        return false
    end
end

function battlelogLib:logAweaponReadAll(uid, log_type)
    local db = getDbo()

    if db:query("update alienweaponlog set isRead = 1 where uid=" .. uid .. " and type=" .. log_type .." and isRead=0") then
        return true
    end        

    return false
end

function battlelogLib:logAweaponHasUnread(uid, log_type)
    local db = getDbo()
    local count = 0
    local result = db:getRow("select count(*) as count from alienweaponlog where uid=:uid and type=:type and isRead=0",{uid=uid, type=log_type})    
    if  type(result)=='table' and next(result) then
        count=result.count
    end
    return tonumber(count)

end

return battlelogLib