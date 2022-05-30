--[[
    * 类注释写在这里-----------------
    * @author {gongjianjun}
    * <br/>Create: 2017-03-02
]]
MailController = MailController or BaseClass(BaseController)

function MailController:config()
    self.model = MailModel.New(self)
    self.dispather = GlobalEvent:getInstance()
    self.is_open = false
end

function MailController:getModel()
    return self.model
end

function MailController:registerEvents()
end

function MailController:registerProtocals()
    ------邮件-----
    self:RegisterProtocal(10800, "mailListHandler")        --邮件列表
    self:RegisterProtocal(10801, "getGoodsHandler")        --提取单个邮件的附件
    self:RegisterProtocal(10802, "getAllGoodsHandler")     --一键提取附件
    self:RegisterProtocal(10803, "handle10803")            --新邮件推送
    self:RegisterProtocal(10804, "delMailHandler")         --删除没有附件的邮件
    self:RegisterProtocal(10805, "readMailHandler")        --读取邮件
    self:RegisterProtocal(10806, "on10806")                --请求指定的邮件返回

    --self:RegisterProtocal(10811, "hander10811")
    --self:RegisterProtocal(10812, "hander10812")
    self:RegisterProtocal(10950, "handle10950") --公告
    self:RegisterProtocal(10951, "handle10951") --删除通知公告
    self:RegisterProtocal(10952, "handle10952") --读取通知公告
    
end

--==============================--
--desc:初始化邮件列表
--time:2019-02-15 11:21:32
--@data:
--@return 
--==============================--
function MailController:mailListHandler(data)
    self.model:initMailList(data.mail)
end

--==============================--
--desc:初始化公告列表
--time:2019-02-15 11:21:44
--@data:
--@return 
--==============================--
function MailController:handle10950(data)
    self.model:initNoticeList(data.board_list, data.type)
end 

--==============================--
--desc:新增一个邮件
--time:2019-02-15 11:28:58
--@data:
--@return 
--==============================--
function MailController:handle10803(data)
    self.model:addMailItem(data.mail)
end

--==============================--
--desc:请求删除一个邮件
--time:2019-02-15 11:29:08
--@ids:
--@return 
--==============================--
function MailController:deletMailSend(ids)
    local protocal ={}
    protocal.ids = ids
    self:SendProtocal(10804,protocal)
end

--==============================--
--desc:推送删除邮件
--time:2019-02-15 11:29:27
--@data:
--@return 
--==============================--
function MailController:delMailHandler(data)
    message(data.msg)
    self.model:delMailItem(data.ids)
end

--==============================--
--desc:读取一个邮件
--time:2019-02-15 11:29:44
--@bid:
--@srv_id:
--@return 
--==============================--
function MailController:read( bid ,srv_id)
    local protocal ={}
    protocal.id = bid
    protocal.srv_id = srv_id
    self:SendProtocal(10805,protocal)
end

--==============================--
--desc:读取一个邮件状态之后
--time:2019-02-15 11:29:57
--@data:
--@return 
--==============================--
function MailController:readMailHandler( data )
    if data.code == 1 then
        self.model:readMailItem(data)
    end
end

--==============================--
--desc:提取邮件附件
--time:2019-02-15 11:52:42
--@id:
--@srv_id:
--@return 
--==============================--
function MailController:getGoods(id, srv_id)
	local protocal = {}
	protocal.id = id
	protocal.srv_id = srv_id
	self:SendProtocal(10801, protocal)
end

--==============================--
--desc:提取邮件返回
--time:2019-02-15 11:52:59
--@data:
--@return 
--==============================--
function MailController:getGoodsHandler(data)
	message(data.msg)
	if data.code == 1 then
        self.model:getMailGood(data)
	end
end 

--==============================--
--desc:一键提取邮件
--time:2019-02-15 11:56:03
--@return 
--==============================--
function MailController:getAllGoods()
	self:SendProtocal(10802, {})
end

--==============================--
--desc:一键提取返回
--time:2019-02-15 11:58:36
--@data:
--@return 
--==============================--
function MailController:getAllGoodsHandler(data)
	message(data.msg)
    if data.ids == nil or next(data.ids) == nil then return end
    self.model:getAllMailGood(data.ids)
end 

--==============================--
--desc:获取已经读取过的 且没有附件的邮件,用于一键删除
--time:2019-02-16 01:03:36
--@return 
--==============================--
function MailController:getHasReadNonRewardList()
    return self.model:getHasReadNonRewardList()
end

---------------------公告------------------
function MailController:sender10950()
    self:SendProtocal(10950,{})
end

--==============================--
--desc:服务端通知删除一个公告
--time:2019-02-16 12:40:39
--@data:
--@return 
--==============================--
function MailController:handle10951(data)
    self.model:delNoticeItem(data.id)
end

function MailController:readNotice(id)
    local protocal ={}
    protocal.id = id
    self:SendProtocal(10952,protocal)
end

--==============================--
--desc:读取一个公告
--time:2019-02-16 12:42:44
--@data:
--@return 
--==============================--
function MailController:handle10952( data )
    message(data.msg)
    if data.code == 1 then
        self.model:readNoticeItem(data.id)
    end
end

function MailController:openMailPanel(bool,index)
    if bool == true then 
        if not self.mail_panel  then
            self.mail_panel = MailWindow.New()
        end
        self.mail_panel:open(index)
    else
        if self.mail_panel then 
            self.mail_panel:close()
            self.mail_panel = nil
        end
    end
end

---打开邮件内容
function MailController:openMailInfo( bool,data)
    if bool == true then 
        if not self.mail_info  then
            self.mail_info = MailInfoWindow.New()
        end
        if self.mail_info:isOpen() == false then
            self.mail_info:open(data)
        else
            self.mail_info:setData(data)
        end
    else
        if self.mail_info then 
            self.mail_info:close()
            self.mail_info = nil
        end
    end
end

function MailController:getMailInfoView( ... )
    if self.mail_info then
        return self.mail_info
    end
end

function MailController:getData()
    return self.model
end

-- --评价客服反馈
-- function MailController:sender10811(id,srv_id,score)
--     local protocal = {}
--     protocal.id = id
--     protocal.srv_id = srv_id
--     protocal.score = score
--     self:SendProtocal(10811,protocal)
-- end
-- function MailController:hander10811(data)
--     message(data.msg)
-- end
-- --客服反馈状态
-- function MailController:sender10812(id,srv_id)
--     local protocal = {}
--     protocal.id = id
--     protocal.srv_id = srv_id
--     self:SendProtocal(10812,protocal)
-- end
-- function MailController:hander10812(data)
--     GlobalEvent:getInstance():Fire(MailEvent.Customer_Service_Status,data)
-- end

-- function MailController:__delete()
--     if self.model ~= nil then
--         self.model:DeleteMe()
--         self.model = nil
--     end
--     self.is_open = nil
-- end
 
--- 请求打开单个邮件
function MailController:requireMailItem(id, srv_id)
    local protocal = {}
    protocal.id = id
    protocal.srv_id = srv_id
    self:SendProtocal(10806, protocal)
end

function MailController:on10806(data)
    if data then
        self:openMailInfo(true, data) 
    end
end