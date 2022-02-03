-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-06-23
-- --------------------------------------------------------------------
GuildvoyageModel = GuildvoyageModel or BaseClass()

local table_insert = table.insert
local table_sort = table.sort

function GuildvoyageModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function GuildvoyageModel:config()
    self.order_list = {}
    self.guildvoyage_red_list = {}
    self.refresh_order_times = 0        -- 已刷新的次数
    self.log_info = {}
    self.daily_times = 0            -- 今日护送次数
end

function GuildvoyageModel:clearGuildVoyageInfo()
    self.order_list = {}
    self.guildvoyage_red_list = {} 
end

function GuildvoyageModel:setDailyTimes(times)
    self.daily_times = times or 0
    GlobalEvent:getInstance():Fire(GuildvoyageEvent.UpdateDailyEscortTimes, self.daily_times)

    -- 还有剩余护送次数的时候显示一下红点
    local config = Config.GuildShippingData.data_const.receive_limit
    local is_order = false
    if config then
        is_order = (config.val > times)
    end
    local list = self:acceptList()
    is_order = is_order and (list~=nil) and (next(list) ~= nil)
    self:updateGuildRedStatus(GuildConst.red_index.voyage_order , is_order )
end

function GuildvoyageModel:getDailyTimes()
    return self.daily_times or 0
end

--==============================--
--desc:最近的订单日志
--time:2018-09-05 06:09:33
--@data:
--@return 
--==============================--
function GuildvoyageModel:updateLogInfo(data)
    self.log_info = data
    GlobalEvent:getInstance():Fire(GuildvoyageEvent.UpdateNearLogInfoEvent)
end
--==============================--
--desc:最近订单信息
--time:2018-09-05 06:09:25
--@return 
--==============================--
function GuildvoyageModel:getNearLogInfo()
    return self.log_info
end

function GuildvoyageModel:updateGuildRedStatus(bid, status)
    local _status = self.guildvoyage_red_list[bid]
    if _status == status then return end

	self.guildvoyage_red_list[bid] = status
	
	-- 更新场景红点状态
   -- MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.guild, {bid = bid, status = status}) 

	-- 事件用于同步更新公会主ui的红点
	--GlobalEvent:getInstance():Fire(GuildEvent.UpdateGuildRedStatus, bid, status)
end 

--==============================--
--desc:公会远航是否有红点
--time:2018-06-15 04:16:12
--@return 
--==============================--
function GuildvoyageModel:checkGuildVoyageRedStatus()
	for k, v in pairs(self.guildvoyage_red_list) do
		if v == true then
			return true
		end
	end
	return false
end 

--==============================--
--desc:根据类型获取红点，
--time:2018-06-15 04:34:59
--@type:GuildConst.red_index
--@return 
--==============================--
function GuildvoyageModel:getRedStatusByType(type)
    return self.guildvoyage_red_list[type]
end

--==============================--
--desc:获取护送订单红点
--time:2018-07-16 09:36:14
--@return 
--==============================--
function GuildvoyageModel:getEscortStatus()
    local status = self:getRedStatusByType(GuildConst.red_index.voyage_escort)
    if status == true then 
        return status
    end
    status = self:getRedStatusByType(GuildConst.red_index.voyage_temp_escort)
    return status
end

--==============================--
--desc:可接订单
--time:2018-06-26 04:21:23
--@return 
--==============================--
function GuildvoyageModel:acceptList()
    local accept_list = {}
    for k,v in pairs(self.order_list) do
        if v.status == GuildvoyageConst.status.accept then
            table_insert(accept_list, v)
        end
    end
    if next(accept_list) then
        table_sort(accept_list, function(a, b) 
            return a.quality > b.quality
        end)
    end
    return accept_list
end

--==============================--
--desc:护送中的订单,包含可提交的
--time:2018-07-04 04:39:48
--@return 
--==============================--
function GuildvoyageModel:escortList()
    local escortlist = {}
    for k,v in pairs(self.order_list) do
        if v.status == GuildvoyageConst.status.doing or v.status == GuildvoyageConst.status.submit then
            table_insert(escortlist, v)
        end
    end
    return escortlist
end

function GuildvoyageModel:getBaseInfo()
    return self.order_list
end

function GuildvoyageModel:getRefreshTimes()
    return self.refresh_order_times
end

--==============================--
--desc:初始化订单列表
--time:2018-07-05 10:24:01
--@data_list:
--@return 
--==============================--
function GuildvoyageModel:initGuildVoyageOrderList(data)
    if data == nil or data.order_list == nil then return end
    self.refresh_order_times = data.buy_order_times 

    -- 是否有可领取奖励
    local is_escort = false

    -- 是否有互助
    local is_interaction = (data.is_assist == TRUE)

    -- 只要触发这个,都要先清除掉那些未接订单
    for k,v in pairs(self.order_list) do
        if v.status == GuildvoyageConst.status.accept then
            self.order_list[k] = nil
        end
    end

    for i, _data in ipairs(data.order_list) do
        local vo = self.order_list[_data.order_id]
        if vo == nil then
            vo = GuildvoyageOrderVo.New(_data.order_bid)
            self.order_list[_data.order_id] = vo
        end
        vo:updateData(_data)
        if _data.status == GuildvoyageConst.status.submit and is_escort == false then
            is_escort = true
        end
    end 
    GlobalEvent:getInstance():Fire(GuildvoyageEvent.UpdateGuildvoyageOrderListEvent)

    -- 红点相关的
    self.guildvoyage_red_list[GuildConst.red_index.voyage_escort] = is_escort 
    self.guildvoyage_red_list[GuildConst.red_index.voyage_interaction] = is_interaction
    
    MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.guild, {{bid = GuildConst.red_index.voyage_interaction, status = is_interaction}, {bid = GuildConst.red_index.voyage_escort, status = is_escort}}) 
end

--==============================--
--desc:订单更新,或者是新增
--time:2018-06-26 04:56:42
--@data:
--@return 
--==============================--
function GuildvoyageModel:updateGuildVoyageOrderList(data)
    if data == nil then return end
    local order = self.order_list[data.order_id]
    local event_type = 0
    if order == nil then
        order = GuildvoyageOrderVo.New(data.order_bid)
        self.order_list[data.order_id] = order
        event_type = 1
    else
        -- 状态的改变
        if order.status ~= data.status then
            if data.status == GuildvoyageConst.status.doing then
                event_type = 1 
            elseif data.status == GuildvoyageConst.status.submit then
                event_type = 2
            end
        end
    end
    order:updateData(data)
    if event_type == 1 then
        GlobalEvent:getInstance():Fire(GuildvoyageEvent.UpdateGuildvoyageOrderListEvent)
        -- 如果是接受订单,给一个红点到远航标签
        if data.status == GuildvoyageConst.status.doing then
            self:updateGuildRedStatus(GuildConst.red_index.voyage_temp_escort, true)
        end
    else
        GlobalEvent:getInstance():Fire(GuildvoyageEvent.UpdateGuildvoyageOrderStatus, data.order_id, data.status)
    end
    -- 判断有可提交订单红点
    self:checkEscortRedStatus(data.status)
end

--==============================--
--desc:在订单改变状态的时候,主要包含提交结束和可提交的事情
--time:2018-07-10 11:01:56
--@status:
--@return 
--==============================--
function GuildvoyageModel:checkEscortRedStatus(status)
    if status == GuildvoyageConst.status.over or status == GuildvoyageConst.status.submit then
        local is_escort = false
        for k, v in pairs(self.order_list) do
            if v.status == GuildvoyageConst.status.submit then
                is_escort = true
                break
            end
        end 
        self:updateGuildRedStatus(GuildConst.red_index.voyage_escort, is_escort)
    end
end

--==============================--
--desc:设置一个订单的状态,出现在提交返回之后
--time:2018-07-03 03:36:40
--@order_id:
--@status:
--@return 
--==============================--
function GuildvoyageModel:changeGuildVoyageStatus(order_id, status)
    local vo = self.order_list[order_id] 
    if vo then
        vo:setBaseData("status", status)
        GlobalEvent:getInstance():Fire(GuildvoyageEvent.UpdateGuildvoyageOrderStatus, order_id, status)
        -- 判断远航红点状态
        self:checkEscortRedStatus(status)
    end
end

--==============================--
--desc:互动加速结果
--time:2018-07-05 11:57:17
--@data:
--@return 
--==============================--
function GuildvoyageModel:updateVoyageInfo(data)
    if data == nil then return end
    local order = self.order_list[data.order_id]
    if order == nil then return end
    order:setBaseData("status", data.status) 
    order:setBaseData("end_time", data.end_time) 
    GlobalEvent:getInstance():Fire(GuildvoyageEvent.UpdateGuildvoyageOrderStatus, data.order_id, data.status)
    -- 判断远航红点状态
    self:checkEscortRedStatus(data.status)
end

--==============================--
--desc:获取以出征伙伴数量,只有已接收的订单才需要计算
--time:2018-06-26 07:21:43
--@return 
--==============================--
function GuildvoyageModel:getEscortPartnerSum()
    local sum = 0
    if self.order_list then
        for k,vo in pairs(self.order_list) do
            if vo.assign_ids and (vo.status == GuildvoyageConst.status.doing or vo.status == GuildvoyageConst.status.submit) then
                sum = sum + #vo.assign_ids
            end
        end
    end
    return sum 
end

--==============================--
--desc:获取正在护送中的订单包含的所有伙伴,这个在新订单的放置伙伴列表中是剔除掉的
--time:2018-07-03 03:26:27
--@return 
--==============================--
function GuildvoyageModel:getBusyPartnerList()
    local partner_list = {}
    if self.order_list then
        for k,vo in pairs(self.order_list) do
            if vo.status == GuildvoyageConst.status.doing or vo.status == GuildvoyageConst.status.submit then
                for _, partner in pairs(vo.assign_ids) do
                    partner_list[partner.partner_id] = true
                end
            end
        end
    end
    return partner_list
end

--==============================--
--desc:获取指定id的订单
--time:2018-06-29 03:16:58
--@id:
--@return 
--==============================--
function GuildvoyageModel:getOrderById(order_id)
    return self.order_list[order_id]
end

--==============================--
--desc:可加速互助的订单列表
--time:2018-07-05 07:07:06
--@data:
--@return 
--==============================--
function GuildvoyageModel:updateGuildVoyageInteractionList(data)
    self.interaction_count = data.count
    self.can_interaction_total = #data.assist_list
    GlobalEvent:getInstance():Fire(GuildvoyageEvent.UpdateGuildVoyageInteractionEvent, self.interaction_count, data.assist_list)

    -- 这里做互助红点吧
    local config = Config.GuildShippingData.data_const.help_limit
    if config ~= nil then
        local red_status = (self.interaction_count < config.val) and (self.can_interaction_total > 0)
        self:updateGuildRedStatus(GuildConst.red_index.voyage_interaction,red_status)
    end
end

--==============================--
--desc:待移除的一个订单
--time:2018-07-05 07:08:23
--@data:
--@return 
--==============================--
function GuildvoyageModel:removeGuildVoyageInteraction(data)
    if self.interaction_count == nil then self.interaction_count = 0 end
    self.interaction_count = self.interaction_count + 1
    GlobalEvent:getInstance():Fire(GuildvoyageEvent.RemoveGuildVoyageInteractionEvent, data, self.interaction_count)

    -- 这里做互助红点吧
    self.can_interaction_total = self.can_interaction_total - 1
    local config = Config.GuildShippingData.data_const.help_limit
    if config ~= nil then
        local red_status = (self.interaction_count < config.val) and (self.can_interaction_total > 0)
        self:updateGuildRedStatus(GuildConst.red_index.voyage_interaction,red_status)
    end
end

--==============================--
--desc:获取秒掉的时间价格
--time:2018-07-09 05:58:02
--@end_time:
--@return 
--==============================--
function GuildvoyageModel:getFinishCost(end_time)
    if self.guild_cost_data == nil then
        self.guild_cost_data = Config.GuildShippingData.data_cost
    end
    if self.guild_cost_data == nil or next(self.guild_cost_data) == nil then
        return 0
    end
    for i,v in ipairs(self.guild_cost_data) do
        if end_time <= v.time then
            return (v.loss or 0)
        end
    end
    return 0
end

--[[
    @desc: 获取刷新消耗
    author:{author}
    time:2018-08-09 17:48:28
    --@times: 
    @return:
]]
function GuildvoyageModel:refreshCost(times)
    if self.refresh_data == nil then
        self.refresh_data = DeepCopy(Config.GuildShippingData.data_refresh)
        table.sort(self.refresh_data, function(a, b) 
            return a.count < b.count
        end)
    end
    for i,v in ipairs(self.refresh_data) do
        if times <= v.count then
            return v.cost or 0
        end
    end
    return 0
end

--[[
    @desc: 最大刷新次数
    author:{author}
    time:2018-08-09 17:58:30
    @return:
]]
function GuildvoyageModel:getMaxRefreshTimes()
    if self.max_refresh_times then
        return self.max_refresh_times
    end
    self.max_refresh_times = 0
    
    for i,v in ipairs(Config.GuildShippingData.data_refresh) do
        if self.max_refresh_times <= v.count then
            self.max_refresh_times = v.count
        end
    end
    return self.max_refresh_times
end

--[[
    @desc: 获取当前最大可护送次数
    author:{author}
    time:2018-08-09 19:21:48
    @return:
]]
function GuildvoyageModel:getMaxSubTimes()
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo == nil then return 0 end
    if self.vip_limite_data == nil then
        self.vip_limite_data = DeepCopy(Config.GuildShippingData.data_vip_limit)
        table.sort(self.vip_limite_data, function(a, b) 
            return a.vip > b.vip
        end)
    end
    for i,v in ipairs(self.vip_limite_data) do
        if role_vo.vip_lev >= v.vip then
            return v.limit or 0
        end
    end
    return 0
end

function GuildvoyageModel:__delete()
end
