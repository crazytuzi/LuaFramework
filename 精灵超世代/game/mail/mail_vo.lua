--
-- User: cloud
-- Date: 2016.12.29
-- 邮件数据类
MailVo = MailVo or BaseClass()

function MailVo:__init()
    self.id = 0				        --邮件bid
    self.srv_id = ""                --邮件服务器id
    self.type = 1                   --0:私人 1:系统 2:公告
    self.from_name = ""			    --发件人用户名
    self.subject = ""				--标题
    self.content = ""				--内容
    self.assets = {}				--'资产类型 coin/gold'
    self.items = {}				    --'物品
    self.send_time = 0				--'发送时间
    self.send_time_order = 0        --用于排升序的发送时间
    self.read_time = 0				--阅读时间
    self.time_out=0                 --超时时间搓
    self.status = 0                 --0:未读 1:已读 2:已领
    self.is_has = 1                 --是否有附件 0有1没
    self.has_items = 0              --是否有附件
end

function MailVo:setContent(value)
    self.mail_content = value
end

--数据赋值(对传过来的协议进行赋值)
function MailVo:initAttrData(data_list)
    if data_list then
        for k, v in pairs(data_list) do
            self:update(k,v)
            if data_list["send_time"] then
                self:update("send_time_order",-data_list["send_time"])
            end
            if data_list["assets"] or data_list["items"] then
                if #data_list["assets"]>0 or #data_list["items"]>0 then
                    self:update("is_has",0)
                else
                    self:update("is_has",1)
                end
            end
        end
    end
end

--==============================--
--desc:清空附件
--time:2019-02-16 12:07:31
--@return 
--==============================--
function MailVo:removeAssets(read_time)
    if read_time then
        self.read_time = read_time 
    end
    self.items = {}
    self.assets = {}
    self.status = 2
    self.has_items = 0
end

function MailVo:update( key,value )
    if self[key] then
        self[key] = value
    end
end

function MailVo:setReaded(read_time)
    if read_time then
        self.read_time = read_time 
    end
    self.status = 1
end


NoticeVo = NoticeVo or BaseClass()

function NoticeVo:__init()
    self.id = 0                     --邮件bid
    self.type = 1                   --1:更新 2:新服 3:活动 4:系统
    self.title = ""               --标题
    self.summary = ""              --概要
    self.content = ""               --内容
    self.start_time = 0           --开始时间
    self.end_time = 0              --结束时间
    self.flag = 0                 --0:未读 1:已读
end

--数据赋值(对传过来的协议进行赋值)
function NoticeVo:initAttrData(data_list)
    if data_list then
        for k, v in pairs(data_list) do
            self:update(k,v)
        end
    end
end

function NoticeVo:update( key,value )
    -- body
    if self[key] then
        self[key] = value
    end
end

function NoticeVo:setReaded()
    self.flag = 1
end