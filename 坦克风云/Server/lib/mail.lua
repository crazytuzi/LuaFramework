local mailLib = {}

function mailLib:mailGetInbox(uid)
    local db = getDbo()
    local result = db:getAllRows("select * from mail where uid=:uid and receiver=:uid",{uid=uid})

    if result then
        return result
    else
        return false
    end
end

function mailLib:mailGetByType(uid,mail_type,maxeid,mineid,page_rows,isPage)
    local db = getDbo()
    local page_rows = page_rows or 10

    local result
    if isPage then
        result = db:getAllRows("select messageid, uid, sender, receiver, type, mail_from, mail_to, subject, isRead,gift,mlock,item,isreward,update_at from mail where uid=:uid and type=:type and (messageid < :mineid or messageid > :maxeid) order by messageid desc limit ".. page_rows, {uid=uid,type=mail_type,maxeid=maxeid,mineid=mineid})
    else
        result = db:getAllRows("select messageid, uid, sender, receiver, type, mail_from, mail_to, subject, isRead,gift,mlock,item,isreward,update_at from mail where uid=:uid and type=:type and messageid > :maxeid order by messageid desc", {uid=uid,type=mail_type,maxeid=maxeid})
    end

    if result then
        for k,v in pairs(result) do
            result[k] = self:mailFormat(v)
        end

        return result
    else
        return {}
    end
end

function mailLib:mailGetSent(uid,page)
    local db = getDbo()

    local result = db:getAllRows("select * from mail where uid=:uid and sender=:uid",{uid=uid})
    if result then
        return  result
    else
        return false
    end
end

function mailLib:mailGet(uid,messageid)
    local db = getDbo()
    local result = db:getRow("select * from mail where uid=:uid and messageid=:messageid",{uid=uid,messageid=messageid})

    if result then
        return self:mailFormat(result)
    else
        return false
    end
end

--gift =-1 是军团长发邮件的标识
--gift =0  正常邮件
--gift =1  是奖励邮件
--gift =2  是道具奖励邮件
--gift =3  是世界争霸
--gift =4  异星资源
--gift =5  公海领地资源分配
function mailLib:mailSent(uid,sender,receiver,mail_from,mail_to,subject,content,mail_type,isRead,gift,item)
    local db = getDbo()

    local mail = {
        uid = tonumber(uid),
        sender = tonumber(sender),
        receiver = tonumber(receiver),
        mail_from = mail_from,
        mail_to = mail_to,
        subject = subject,
        content = content,
        type = mail_type or 0,
        isRead = isRead or 0,
        gift =gift or 0,
        item = item,
        mlock = 0,
        update_at = getClientTs(),
    }

    local ret = db:insert('mail',mail)

    if ret and ret > 0 then
        mail.messageid = db.conn:getlastautoid()

        -- local uobjs = getUserObjs(uid,true)
        -- mUserinfo = uobjs.getModel('userinfo')

        -- if type(mUserinfo.flags.event) ~= 'table' then  mUserinfo.flags.event = {} end
        -- mUserinfo.flags.event.m = mail_type

        regSendMsg(uid,"msg.event",{event={m=mail_type}})

        return self:mailFormat(mail)
    end

    return false
end

function mailLib:mailDel(uid,messageid,mail_type)
    local db,result = getDbo()
    local lmail = ""
    if moduleIsEnabled('lockEmail') == 1 then
        lmail = " mlock=0 and "
    end
    if mail_type and not messageid then
        result = db:query("delete from mail where " .. lmail .. " uid=" .. uid .. " and type=" .. mail_type)
    else
        result = db:query("delete from mail where " .. lmail .. " uid=" .. uid .. " and messageid=" .. messageid)
    end
    return result > 0
end

function mailLib:lockmailCount( uid )
   local db = getDbo()
   result = db:getAllRows("select count(*) lockmail from mail where uid=:uid and mlock=1", {uid=uid})

   if result then
        return result[1]["lockmail"]    
   end

   return 0
end

-- 侦察报告
-- 删除时只删除type类型是2的（异星矿场的侦察邮件是4）
function mailLib:mailDelScout(uid)
    local db = getDbo()
    db:query("delete FROM `mail` WHERE `uid` = "..uid.." AND type = 2 AND `subject` LIKE '2-%' ")
end

-- 删除异星矿场的战报,每周1直接删除type是4的邮件就行了，
-- function mailLib:mailDelAlienmine()
--     local db = getDbo()
--     local ts = getWeeTs() - 172800
--     db:query("delete FROM `mail` WHERE type = 4 AND update_at <= " .. ts)
-- end

-- 列表
-- type  1.系统邮件/个人邮件； 2.战报邮件； 3.发件箱；
function mailLib:mailList(uid,maxeid,mineid,mail_type,isPage)
    local list = {}
    local page_rows = 10

    maxeid = maxeid or 0
    mineid = mineid or 0

    if mail_type == 1 then
        list.inbox = {}
        list.inbox.mails = self:mailGetByType(uid,1,maxeid,mineid,page_rows,isPage)
    elseif mail_type == 2 then
        list.report = {}
        list.report.mails = self:mailGetByType(uid,2,maxeid,mineid,page_rows,isPage)
    elseif mail_type == 3 then
        list.sent = {}
        list.sent.mails = self:mailGetByType(uid,3,maxeid,mineid,page_rows,isPage)
    elseif mail_type == 4 then
        list.alienreport = {}
        list.alienreport.mails = self:mailGetByType(uid,4,maxeid,mineid,page_rows,isPage)
    end

    local count = self:mailCount(uid,mail_type)

    for k,v in pairs(count) do
        local n = tonumber(v.count) or 0
        local t = tonumber(v.type)

        if n>0 then
            local deln= self:mailClear(uid,t,n) or 0
            n = n-deln
        end

        if t == 1 then
            list.inbox.maxrows = n
        elseif t == 2 then
            list.report.maxrows = n
        elseif t == 3 then
            list.sent.maxrows = n
        elseif t == 4 then
            list.alienreport.maxrows = n
        end
    end


    if mail_type == 1 then
        for k, v in pairs(list.inbox.mails) do
            local senderuid =  tonumber(v.sender)
            local sender = {}
            if senderuid ~= 1 then
                local senderobj = getUserObjs( senderuid )
                local sUserinfo = senderobj.getModel( "userinfo" )
                sender.level = sUserinfo.level
                sender.alliancename = sUserinfo.alliancename
                sender.rank = sUserinfo.rank
                sender.vip = sUserinfo.showvip()
                sender.pic = sUserinfo.pic
                sender.fc = sUserinfo.fc 
                sender.bpic = sUserinfo.bpic
                sender.apic = sUserinfo.apic
            end
            list.inbox.mails[k].sendermsg = sender
        end
    end

    list.unread = self:mailHasUnread(uid)

    return list
end

function mailLib:mailRead(uid,messageid)
    local mail = self:mailGet(uid,messageid)

    if mail and mail.isRead == "0" then
        local db = getDbo()

        if db:query("update mail set isRead = 1 where uid="..uid.." and messageid="..messageid) then
            mail.isRead = 1
        end
    end

    return mail
end

function mailLib:mailreadByType(uid, type)
    -- body
    local db = getDbo()
    if db:query("update mail set isRead = 1 where uid="..uid.." and type="..type.." and isRead=0") then
        return true
    end

    return false
end

function mailLib:mailReward(uid,messageid)
    local mail = self:mailGet(uid,messageid)
    local flag = false
    if mail and mail.isreward == "0" then
        local db = getDbo()

        if db:query("update mail set isreward = 1 where uid="..uid.." and messageid="..messageid) then
            flag=true
        end
    end

    return flag
end

function mailLib:mailCount(uid,mail_type)
    local db = getDbo()
    local result = nil
    if mail_type then
        result = db:getAllRows("select count(*) as count,type from mail where uid=:uid and type = :type",{uid=uid,type=mail_type})
    else
        result = db:getAllRows("select count(*) as count,type from mail where uid=:uid group by type",{uid=uid})
    end
    return result
end

function mailLib:mailFormat(mail)
    mail.content = json.decode(mail.content) or mail.content

    local format_mail = {
        eid = mail.messageid,
        type=mail.type,
        from=mail.mail_from,
        sender=mail.sender,
        to=mail.mail_to,
        title=mail.subject,
        content=mail.content,
        gift=mail.gift,
        item=json.decode(mail.item),
        isreward=mail.isreward,
        isRead=mail.isRead,
        mlock=mail.mlock,
        ts = mail.update_at,
    }

    return format_mail
end

-- 邮件清理
function mailLib:mailClear(uid,mail_type,mail_nums)
    local max = {200,100,200,100}
    local delNum = mail_nums - max[mail_type]
    if delNum > 0 then
        local db = getDbo()
        db:query("delete from mail where uid = " .. uid .. " and type = ".. mail_type .. " and mlock=0 order by messageid asc limit " .. delNum)
        return delNum
    end
end

-- 是否有可读的
-- return int 
function mailLib:mailHasUnread(uid)
    local count = {}
    local db = getDbo()
    local result = db:getAllRows("select count(*) as count, type from mail where uid=:uid and isRead = 0 group by type",{uid=uid})
    if type(result) == 'table' then
        for _,v in pairs(result) do
            count[v.type] = v.count
        end
    end
    return count
end

-- 邮件解锁
function mailLib:mailLock(uid, messageid, mlock)
    local mail = self:mailGet(uid, messageid)

    if not mail or tonumber(mail.type)~=2 or tonumber(mail.mlock) == mlock then
        return false
    end

    local db = getDbo()
    if db:query("update mail set mlock = " ..mlock.. " where uid="..uid.." and messageid="..messageid) then
        mail.mlock = mlock
    end

    return mail
end

----------------------------新的扩展读取系统邮件

--添加新的系统邮件
--appid 区分渠道
--limittype 限制类型，0为不限制，1玩家等级，2vip
--min 最大值
--max 最小值

function mailLib:sentSysMail(st,et,subject,content,mail_type,gift,item,send,appid,limittype,min,max,lastlogintime)
    local db = getDbo()

    if not appid then
        appid = 0
    end


    local mail = {
        st = tonumber(st),
        et = tonumber(et),
        type = mail_type or 0,
        subject = subject,
        content = content,
        gift =gift or 0,
        item = item,
        send =send or 0,
        appid = tonumber(appid) or 0,
        limittype = tonumber(limittype) or 0,
        min = tonumber(min) or 0,
        max = tonumber(max) or 0,
        lastlogintime = tonumber(lastlogintime) or 0,
        update_at = getClientTs(),
    }
    local ret = db:insert('sysmail',mail)

    if ret and ret > 0 then
        mail.id = db.conn:getlastautoid()
        local redis = getRedis()

        local key = "z"..getZoneId()..".alluser.sysmailinfo"
        local data=redis:get(key)
        data=json.decode(data)
        if type (data)~='table' then  data={} end
        local info = {mail.id,mail.st,mail.et}
        table.insert(data,info)
        redis:set(key,json.encode(data))

        return mail.id
    end

    return false
end

-- 获取有效的系统邮件的信息 

function mailLib:SysMailInFo()

    local redis = getRedis()

    local key = "z"..getZoneId()..".alluser.sysmailinfo"
    local data  = redis:get(key)
    data =json.decode(data)
    if type(data)~='table' or data==nil then
        local db = getDbo()
        data ={}
        local result = db:getAllRows("select id,st,et from sysmail where et>:et",{et=getClientTs()})
        if type(result)~='table' then result={} end
        if next(result) then
            for k,v in pairs(result) do
                local info = {tonumber(v.id),tonumber(v.st),tonumber(v.et)}
                table.insert(data,info)
            end

        end
        redis:set(key,json.encode(data))
    end
    return data
end

---系统中的邮件插入玩家邮件
function mailLib:SysMailSentUser(uid,mid, appid, userinfo)

    appid = tonumber(appid) or 0

    local redis = getRedis()
    local key = "z"..getZoneId()..".alluser.sysmail."..mid
    local data  = redis:get(key)
    data=json.decode(data)
    if data==nil or type(data)~='table' then
        local db = getDbo()
        data={}
        local result = db:getAllRows("select * from sysmail where id=:id ",{id=mid})

        if result then
            data=result[1]
            redis:set(key,json.encode(data))
        end
    end
    --检查用户等级 等级大于等于30级可以接受全服奖励邮件
    local checkCrossMailByLevel = function(mailSubject)
        mailSubject = tonumber(mailSubject) or 0
        --个人跨服战和团队跨服战所有的邮件主题
        local checkSubject = {16,17,18,22,23,24,30}
        if not table.contains(checkSubject, mailSubject) then
            return true
        end
        local checkLevel = 30

        -- 远洋征战全服奖励邮件限制为40级
        if mailSubject == 30 then checkLevel = 40 end

        if userinfo.level >= checkLevel then
            return true
        end
        return false
    end

    local flag = false
    
    if next(data) then

        local checkAppid = data.appid and tonumber(data.appid) or 0

        if appid ~= 0 and checkAppid ~= 0 and appid ~= checkAppid then
            return false
        end
        --跨服战全服奖励限制level
        if not checkCrossMailByLevel(data.subject) then
            return false
        end
        --有vip和等级限制  limittype=3同时限制VIP和等级
        local limittype = tonumber(data.limittype) or 0
        if limittype > 0 then
            local checkItem
            local u_l
            local u_v
            if limittype == 1 then
                checkItem = tonumber(userinfo.level) or 0
            elseif limittype == 2 then
                checkItem = tonumber(userinfo.vip) or 0
            elseif limittype == 3 then
                u_l = tonumber(userinfo.level) or 0
                u_v = tonumber(userinfo.vip) or 0
                local min_st = data.min
                local l_st = tonumber(string.sub(min_st,1,-3)) or 0
                local v_st = tonumber(string.sub(min_st,-2,-1)) or 0
                local max_et = data.max
                local l_et = tonumber(string.sub(max_et,1,-3)) or 0
                local v_et = tonumber(string.sub(max_et,-2,-1)) or 0
                if u_l < l_st or u_l > l_et or u_v < v_st or u_v > v_et then
                    return false
                end
            end
            if checkItem then
                if checkItem < (tonumber(data.min) or 0) or checkItem > (tonumber(data.max) or 0) then
                    return false
                end
            end
        end

        -- 老玩家最后登录时间检测
        local logindateLimit = tonumber(data.lastlogintime) or 0
        if logindateLimit > 0 then
            if not (userinfo.online_at and userinfo.online_at > 100 and userinfo.online_at < logindateLimit) then
                return true
            end
        end
        if tonumber(data.gift) == 8 then
            if tonumber(userinfo.regdate) > tonumber(data.st) then
                return false
            end
        end
        local ret=self:mailSent(uid,data.send,uid,'','',data.subject,data.content,tonumber(data.type),0,tonumber(data.gift),data.item)
        if ret then
            flag=true
        end
    end

    return flag
end


--------------删除缓存中的过期的系统邮件

function mailLib:delSysMailInFo(mid)
    local redis = getRedis()

    local key = "z"..getZoneId()..".alluser.sysmailinfo"
    local data  = redis:get(key)
    data =json.decode(data)
    if type(data)=='table' and next(data) then

        for k,v in pairs(data) do
            if v[1]==mid then
                table.remove(data,k)
                break
            end
        end

        local ret=redis:set(key,json.encode(data))
        if ret~=nil then
            return true
        end
    end
    return false
end


return mailLib
