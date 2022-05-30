--[[
    * 类注释写在这里-----------------
    * @author {AUTHOR}
    * <br/>Create: 2016-12-28
]]
MailModel = MailModel or BaseClass()
MailModel.MAX_COUNT = 50

function MailModel:__init(ctrl)
    self.ctrl = ctrl
    self.mail_list = {}		    --所有邮件
    self.notice_list = {}       --公告列表

    self.red_status_list = {}   --红点状态
    self:config()
end

function MailModel:config()
end

--==============================--
--desc:初始化邮件列表
--time:2019-02-15 11:35:06
--@data:
--@return 
--==============================--
function MailModel:initMailList(data_list)
    self.mail_list = {}
    
    if data_list == nil or next(data_list) == nil then return end
    local _getNorKey = getNorKey
    for i,v in ipairs(data_list) do
        local key = _getNorKey(v.id, v.srv_id)
        local mail_vo = self.mail_list[key]
        if mail_vo == nil then
            mail_vo =  MailVo.New()
            self.mail_list[key] = mail_vo 
        end
        mail_vo:initAttrData(v)
    end
    -- 初始化红点
    self:checkMailRedSum()
end

--==============================--
--desc:新增邮件 10803 
--time:2019-02-15 11:44:17
--@data:
--@return 
--==============================--
function MailModel:addMailItem(data_list)
    if data_list == nil or next(data_list) == nil then return end
    local _getNorKey = getNorKey
    for i,v in ipairs(data_list) do
        local key = _getNorKey(v.id, v.srv_id)
        local mail_vo = self.mail_list[key]
        if mail_vo == nil then
            mail_vo =  MailVo.New()
            self.mail_list[key] = mail_vo 
        end
        mail_vo:initAttrData(v)
    end
    -- 设置红点
    self:checkMailRedSum()
    -- 新增一个邮件的时候刷新邮件列表
    GlobalEvent:getInstance():Fire(MailEvent.UPDATE_ITEM)
end

--==============================--
--desc:设置邮件红点状态
--time:2019-02-16 12:29:11
--@return 
--==============================--
function MailModel:checkMailRedSum()
    local red_num = 0
    for k,v in pairs(self.mail_list) do
        if v.status == 0 then
            red_num = red_num + 1
        end
    end
    self:updateRedStatus(1, red_num)
end

--==============================--
--desc:获取邮件列表
--time:2019-02-16 12:18:55
--@return 
--==============================--
function MailModel:getAllMailArray()
    local temp_list = {}
    local now_time = GameNet:getInstance():getTime()
	for k, v in pairs(self.mail_list) do
		if v.time_out ~= 0 and v.time_out <= now_time and v.has_items == 0 then     -- 已经过期且没有物品的时候

		elseif v.type == 1 or v.type == 3 then
            table.insert( temp_list, v )
		end
	end
    if #temp_list > 0 then
        local sort_fun = SortTools.tableLowerSorter({"status", "has_items"}) 
        table.sort(temp_list, sort_fun)
    end
	return temp_list
end

--==============================--
--desc:删除没有附件的邮件 10804 
--time:2019-02-15 11:46:14
--@ids_list:
--@return 
--==============================--
function MailModel:delMailItem(ids_list)
    if ids_list == nil or next(ids_list) == nil then return end
    local _getNorKey = getNorKey 
    for i,v in ipairs(ids_list) do
        local key = _getNorKey(v.id, v.srv_id)
        self.mail_list[key] = nil
    end
    -- 新增一个邮件的时候刷新邮件列表
    GlobalEvent:getInstance():Fire(MailEvent.UPDATE_ITEM)
end

--==============================--
--desc:读取一封邮件,这个时候需要设置一些状态 10805 
--time:2019-02-15 11:50:03
--@data:
--@return 
--==============================--
function MailModel:readMailItem(data)
    if data == nil then return end
    local key = getNorKey(data.id, data.srv_id) 
    local mail_vo = self.mail_list[key]
    if mail_vo == nil then return end
    mail_vo:setReaded(data.read_time)
    -- 设置红点
    self:checkMailRedSum()
    -- 读取单封邮件的处理
    GlobalEvent:getInstance():Fire(MailEvent.READ_MAIL_INFO, key)
end

--==============================--
--desc:提取一个邮件附件 10801 
--time:2019-02-15 11:54:20
--@data:
--@return 
--==============================--
function MailModel:getMailGood(data)
    if data == nil then return end
    local key = getNorKey(data.id, data.srv_id) 
    local mail_vo = self.mail_list[key]
    mail_vo:removeAssets()
    -- 设置红点
    self:checkMailRedSum()
    -- 提取一个邮件的物品
    GlobalEvent:getInstance():Fire(MailEvent.GET_ITEM_ASSETS, key)
end

--==============================--
--desc:一键提取所有邮件  10802 
--time:2019-02-15 11:56:47
--@ids_list:
--@return 
--==============================--
function MailModel:getAllMailGood(ids_list)
    if ids_list == nil or next(ids_list) == nil then return end
    local _getNorKey = getNorKey 
    for i,v in ipairs(ids_list) do
        local key = _getNorKey(v.id, v.srv_id)
        local mail_vo = self.mail_list[key]
        if mail_vo then
            mail_vo:removeAssets(v.read_time)
        end
    end
    -- 设置红点
    self:checkMailRedSum()
    -- 新增一个邮件的时候刷新邮件列表
    GlobalEvent:getInstance():Fire(MailEvent.UPDATE_ITEM)
end

--==============================--
--desc:获取已读且已经领取的邮件
--time:2019-02-16 12:19:57
--@return 
--==============================--
function MailModel:getHasReadNonRewardList()
	local mail_ids = {}
	for _index, v in pairs(self.mail_list) do
		if v.id and v.srv_id and (v.status == 2 or (v.status == 1 and v.has_items == 0)) then --删除邮件的已经领取的邮件
			local mail_data = {}
			mail_data.id = v.id
			mail_data.srv_id = v.srv_id
			table.insert(mail_ids, mail_data)
		end
	end
	return mail_ids
end 

--==============================--
--desc:更新红点状态
--time:2019-02-16 12:28:14
--@bid:
--@num:
--@return 
--==============================--
function MailModel:updateRedStatus(bid, num)
    local red_num = self.red_status_list[bid]
    if red_num == num then return end
    self.red_status_list[bid] = num
    -- 红点
    local list = {bid = bid, num = num }
    MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.mail, list) 

    -- 更新红点, 1为邮件 2位公告
    GlobalEvent:getInstance():Fire(MailEvent.UPDATEREDSTATUS, bid, num)
end

function MailModel:getRedSum(bid)
    return self.red_status_list[bid]
end

--==============================--
--desc:初始化公告列表
--time:2019-02-15 11:40:59
--@data_list:
--@data_type:类型(0:全部 1:更新或新增)
--@return 
--==============================--
function MailModel:initNoticeList(data_list, data_type)
    if data_list == nil or next(data_list) == nil then return end
    for i,v in ipairs(data_list) do
        local notice_vo = self.notice_list[v.id]
        if notice_vo == nil then
            notice_vo =  NoticeVo.New()
            self.notice_list[v.id] = notice_vo 
        end
        notice_vo:initAttrData(v)
    end
    -- 红点状态
    self:checkNoticeRedSum()
    -- 这里包含了更新删除之类
    GlobalEvent:getInstance():Fire(MailEvent.UPDATE_NOTICE)
end

--==============================--
--desc:公告红点
--time:2019-02-16 12:52:49
--@return 
--==============================--
function MailModel:checkNoticeRedSum()
    local red_num = 0
    for k,v in pairs(self.notice_list) do
        if v.flag == 0 then
            red_num = red_num + 1
        end
    end
    self:updateRedStatus(2, red_num)
end

--==============================--
--desc:通知删除一个公告
--time:2019-02-16 12:42:11
--@id:
--@return 
--==============================--
function MailModel:delNoticeItem(id)
    if self.notice_list[id] then
        self.notice_list[id] = nil
    end
    -- 红点状态
    self:checkNoticeRedSum()
    -- 删除更新
    GlobalEvent:getInstance():Fire(MailEvent.UPDATE_NOTICE)
end

--==============================--
--desc:通知读取一个公告
--time:2019-02-16 12:43:16
--@id:
--@return 
--==============================--
function MailModel:readNoticeItem(id)
    -- local notice_vo = self.notice_list[id]
    -- if notice_vo then
    --     notice_vo:setReaded()
    -- end
    -- 红点状态
    self:checkNoticeRedSum()
    -- 读取一封公告
    GlobalEvent:getInstance():Fire(MailEvent.READ_INFO_NOTICE,id)
end

--==============================--
--desc:获取公告列表(主要用于排序)
--time:2019-02-16 12:46:34
--@return 
--==============================--
function MailModel:getNoticeArray()
    local temp_list = {}
    for k, v in pairs(self.notice_list) do
        table.insert(temp_list, v)
    end
    if #temp_list > 0 then
        local sort_fun = SortTools.tableLowerSorter({"flag", "start_time"})
        table.sort(temp_list, sort_fun)
    end
    return temp_list 
end
--为了更快获取公告的信息
function MailModel:getNoticeMessage(id)
    if self.notice_list[id] then
        return self.notice_list[id]
    end
    return nil
end

function MailModel:__delete()
	self.main_info = nil
    self.mail_list = {}
    self.notice_list = {}
    self.mail_count = 0
end