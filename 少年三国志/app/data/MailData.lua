-- 邮件信息
require("app.cfg.mail_info")
local MailData = class("MailData")


function MailData:ctor()
    self._list = {}
    self._newMailCount = 0
    self._newRechargeMailCount = 0
    self._mailList = {}
end

--从简单邮件(只含头部）列表中进行初始化 
function MailData:initFromSimpleMailList(simpleMailList)
    self._list = {}
    self:addSimpleMails(simpleMailList)

    --todo sort
    
end

--添加邮件列表, 默认插在最前面
function MailData:addSimpleMails(simpleMailList)
    for i,sm in ipairs(simpleMailList) do 
        local mail = {tempid=sm.id, mail_info_id=sm.mail_info_id, mail_info_record = mail_info.get(sm.mail_info_id)}
            
        table.insert(self._list,  1, mail)
    end
    
    --todo sort
    
end

--获得邮件
function MailData:getMailByMailId(id)
    for i,mail in ipairs(self._list) do
        if mail.tempid == id then
            return mail
        end
    end
    
    return nil
end

--从完整邮件列表中进行更新
function MailData:updateMails(mailList)
    self._mailList = mailList
    for i,mail in ipairs(mailList) do
        local localMail = self:getMailByMailId(mail.id)
        if localMail ~= nil then
            --update localMail from mail
            localMail.source_id = mail.source_id
            localMail.time = mail.time
            -- localMail.name = mail.name
            -- localMail.comment = mail.comment
            localMail.content = MailData.createMailContent(mail)
            local key = {}
            local value = {}
            if rawget(mail, "key") then
                key = mail.key
                value = mail.value
                for i,k in ipairs(key) do
                    localMail[k] = value[i]
                end
            end

            -- if localMail.mail_info_id ~= 10 or G_Me.friendData:getFriendByUid(localMail.source_id) == nil then
            --     table.remove(mail,  index) 
            -- end
        end
            
    end
    
    
end

--key+value+mail_info_id => content
function MailData.createMailContent(mail)
    if not mail then
        return ""
    end

    local key = {}
    local value = {}
    if rawget(mail, "key") then
        key = mail.key
        value = mail.value
    end
            
    local mail_info_record = mail_info.get(mail.mail_info_id or 0)
    local comment = mail_info_record and mail_info_record.comment or ""
    
    --有修改, 邮件模板里如果想放 比如 宝物名字, 以前后端您需要把名字传进来, 现在只需要传ID就可以了
    --模板里配置是这样的 #treasure_info|name|id#, 后端协议传过来的是ID, 那么需要去treasure_info表根据ID进行索引,然后取到记录的name
    for i,k in ipairs(key) do
        
        comment = string.gsub(comment, "#" .. k .. "#", value[i])  

        local tablename, column = string.match(comment,"#([%l_]+)|([%l_]+)|" .. k .. "#")    
        if tablename ~= nil and column ~= nil then
            require("app.cfg." .. tablename)
            local cfg_table = _G[tablename]
            if cfg_table ~= nil  then



                local record = cfg_table.get(toint(value[i]))
                local actualValue = record[column]
                if actualValue ~= nil then
                    local newKey = "#" .. tablename .. "|"  .. column .. "|" .. k.. "#"
                    comment = string.gsub(comment, newKey, actualValue)  
                end
            end
            
        end      
    end

    if comment == nil then
        comment = ""
    end
    return comment
end

--设置新邮件数目
function MailData:setNewMailCount(n)
    self._newMailCount = n
    --todo
    --dispatch event
end

function MailData:setNewRechargeMailCount(n)
    self._newRechargeMailCount = n
end

function MailData:getNewMailCount()
    return self._newMailCount
end

function MailData:getNewRechargeMailCount()
    return self._newRechargeMailCount
end

function MailData:setMailList(list)
    self._mailList = list
end

function MailData:getMyMailList()
    local mail = {}
    for k,v in ipairs(self._mailList) do
        if v.mail_info_id ~= 10 or G_Me.friendData:getFriendByUid(v.source_id) == nil then
            table.insert(mail,#mail+1,  v) 
        end
    end
    -- return self._mailList
    return mail
end


--todo 先粗暴点
function MailData:getAllHungryMailIdList()
    local list = {}
    for i,mail in ipairs(self._list) do
        if mail.content == nil then
           table.insert(list,  mail.tempid) 
        end
    end
    return list
end




--todo 先粗暴点
function MailData:getMailList(tag)
    local sortMail = function(a,b)
        return a.tempid > b.tempid
    end
    
    local mail = {}
    for k,v in ipairs(self._list) do
        local mail_info_record = mail_info.get(v.mail_info_id)
        if tag == 0 or mail_info_record.tag == tag then
            table.insert(mail,#mail+1,  v) 
        end
    end
    table.sort(mail, sortMail)
    -- return self._list
    return mail
end
return MailData
