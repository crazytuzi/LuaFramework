-- 领奖中心信息
require("app.cfg.mail_info")
local GiftMailData = class("GiftMailData")
local MailData = require("app.data.MailData")


function GiftMailData:ctor()
    self._list = {}
    self._newMailCount = 0
end


function GiftMailData:initFromGiftMailList(GiftMailList)
    self._list = {}
    for i,sm in ipairs(GiftMailList) do
        
        local mail = {
            id=sm.id, 
            awards=sm.awards, 
            mail_info_record = mail_info.get(sm.mail.mail_info_id),
            content =MailData.createMailContent(sm.mail),
            time = sm.mail.time
        }
            
        table.insert(self._list, mail)
    end
    
    
end

function GiftMailData:processMail(id)
    for i,mail in ipairs(self._list) do
        if mail.id == id then
            table.remove(self._list, i)
            break
        end
    end
end


--设置新邮件数目
function GiftMailData:setNewMailCount(n)
    self._newMailCount = n
end

function GiftMailData:getNewMailCount()
    return self._newMailCount
end


function GiftMailData:getMailList()
    return self._list
end

function GiftMailData:getMailById(id)
    for i,mail in ipairs(self._list) do
        if mail.id == id then
            return mail
        end
    end
    
    return nil
end

return GiftMailData
