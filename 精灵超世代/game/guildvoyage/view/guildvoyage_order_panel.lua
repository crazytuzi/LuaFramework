-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会远航的可接订单面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildVoyageOrderPanel = class("GuildVoyageOrderPanel", function()
	return ccui.Layout:create()
end)

local controller = GuildvoyageController:getInstance()
local model = controller:getModel()
local backpack_mode = BackpackController:getInstance():getModel()
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove
local partner_model = HeroController:getInstance():getModel()
local item_config_fun = Config.ItemData.data_get_data 

function GuildVoyageOrderPanel:ctor() 
	self:createRootWnd()
	self:registerNodeEvent()
end

function GuildVoyageOrderPanel:createRootWnd()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("guildvoyage/guildvoyage_order_panel"))
	self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

	self.dispatch_notice = self.root_wnd:getChildByName("dispatch_notice")
	self.dispatch_notice:setString(string.format(TI18N("可派遣宝可梦数:%s"), 20))

	self.order_desc = self.root_wnd:getChildByName("order_desc")
	self.order_desc:setString(TI18N("(每日00:00、12:00自动补充订单)"))

	self.item = self.root_wnd:getChildByName("item")
	self.item:setVisible(false)

	self.empty_tips = self.root_wnd:getChildByName("empty_tips")
	self.empty_tips:getChildByName("desc"):setString(TI18N("暂无任何订单!"))

	self.list_container = self.root_wnd:getChildByName("list_container")

	self.refresh_btn = self.root_wnd:getChildByName("refresh_btn")
	self.refresh_btn_label = createRichLabel(24, 1, cc.p(0.5, 0.5), cc.p(105,31))
	self.refresh_btn:addChild(self.refresh_btn_label)

	self.log_container = self.root_wnd:getChildByName("log_container")
	self.notice_log_label = createRichLabel(22, 188, cc.p(0, 1), cc.p(10, 60),nil, nil, 600) 
	self.log_container:addChild(self.notice_log_label)

	self.left_times = self.root_wnd:getChildByName("left_times")
	self.left_times:setString("今日护送次数:10/10")
end

function GuildVoyageOrderPanel:registerNodeEvent()
	self.refresh_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			controller:requestRefresh()
		end
	end) 
	self.log_container:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			controller:openGuildVoyageLogWindow()
		end
	end) 
end

function GuildVoyageOrderPanel:addToParent(status)
	self:setVisible(status)
	self:registerEvent(status)

	if status == true then
		if self.scroll_view == nil then
			local list = model:acceptList()
			if list == nil or next(list) == nil then
				controller:requestOrderList()
			else
				self:updateOrderList(list)
			end
		end

		self:setLog()
		self:escortDailyLeftTimes()
	end
end

function GuildVoyageOrderPanel:registerEvent(status)
	if status == true then
		if self.init_list_event == nil then
			self.init_list_event = GlobalEvent:getInstance():Bind(GuildvoyageEvent.UpdateGuildvoyageOrderListEvent, function() 
				local list = model:acceptList()
				self:updateOrderList(list)
			end)
		end
		if self.update_near_log_info_event == nil then
			self.update_near_log_info_event = GlobalEvent:getInstance():Bind(GuildvoyageEvent.UpdateNearLogInfoEvent, function() 
				self:setLog()
			end)
		end
		if self.update_escort_daily_times == nil then
			self.update_escort_daily_times = GlobalEvent:getInstance():Bind(GuildvoyageEvent.UpdateDailyEscortTimes, function(times) 	
				self:escortDailyLeftTimes()
			end)
		end
	else
		if self.update_near_log_info_event ~= nil then
			GlobalEvent:getInstance():UnBind(self.init_list_event)
			self.init_list_event = nil
		end
		if self.update_near_log_info_event ~= nil then
			GlobalEvent:getInstance():UnBind(self.update_near_log_info_event)
			self.update_near_log_info_event = nil
		end
		if self.update_escort_daily_times ~= nil then
			GlobalEvent:getInstance():UnBind(self.update_escort_daily_times)
			self.update_escort_daily_times = nil
		end
	end
end

function GuildVoyageOrderPanel:escortDailyLeftTimes()
	local times = model:getDailyTimes()
	local config = Config.GuildShippingData.data_const.receive_limit
	if config then
		times = config.val - times 
		if times < 0 then times = 0 end
		self.left_times:setString(string_format("今日护送次数:%s/%s",times, config.val))
	end
end

--==============================--
--desc:初始化订单列表,或者购买新的订单时候更新的
--time:2018-06-26 04:46:24
--@list:
--@return 
--==============================--
function GuildVoyageOrderPanel:updateOrderList(list)
	if list == nil then return end
	if next(list) == nil then
		if self.scroll_view then
			self.scroll_view:setVisible(false)
		end
		if self.empty_tips then
			self.empty_tips:setVisible(true)
		end
	else
		if self.scroll_view == nil then
			local size = self.list_container:getContentSize()
			local setting = {
				item_class = GuildVoyageOrderItem,
				start_x = 7,
				space_x = 0,
				start_y = 7,
				space_y = 2,
				item_width = 594,
				item_height = 197,
				row = 0,
				col = 1,
				need_dynamic = true
			}
			self.scroll_view = CommonScrollViewLayout.new(self.list_container, nil, nil, nil, size, setting)
		end

		self.scroll_view:setData(list, nil, nil, self.item)
		self.scroll_view:setVisible(true)
		if self.empty_tips then
			self.empty_tips:setVisible(false)
		end
	end

	-- 当前剩余伙伴数量
	local partner_list = partner_model:getHeroList()
	local partner_sum = tableLen(partner_list)
	local escort_num = model:getEscortPartnerSum()
	local num = partner_sum - escort_num
	if num < 0 then num = 0 end
	self.dispatch_notice:setString(string.format(TI18N("可派遣宝可梦数:%s"), num))

	-- 设置刷新价格
	self:setRefreshCost()
end

function  GuildVoyageOrderPanel:setRefreshCost()
	local refresh_order_times = model:getRefreshTimes()
	if refresh_order_times == nil then refresh_order_times = 0 end

    local refresh_next_times = refresh_order_times + 1
    local refresh_config = Config.GuildShippingData.data_refresh[refresh_next_times]
    if refresh_config == nil then
		self.refresh_btn_label:setString(TI18N("今日刷次次数已满")) 
    else
		if refresh_config.loss_fee and refresh_config.loss_fee[1] then
			local cost = refresh_config.loss_fee[1] 
			if cost == nil or #cost < 2 then return end
			local item_config = Config.ItemData.data_get_data(cost[1])
			if item_config then
				local str = string.format("<img src=%s visible=true scale=0.35 />,<div fontcolor=#ffffff fontsize=24 outline=1,#c45a14>%s %s</div>", PathTool.getItemRes(item_config.icon), cost[2], TI18N("刷新订单"))
				self.refresh_btn_label:setString(str)
			end
		end
	end
end

--==============================--
--desc:设置最近的一条log
--time:2018-09-05 05:43:10
--@return 
--==============================--
function GuildVoyageOrderPanel:setLog()
	local log = model:getNearLogInfo()
	if log.order_bid ~= 0 then
		local order = Config.GuildShippingData.data_order(log.order_bid)
		if order then
			local quality = order.quality
			local color_id = BackPackConst.quality_color_id[quality]
			if color_id == nil then 
				color_id = 1
			end
			local time_str = TimeTool.getMDHM(log.endtime)
			local order_name = order.name
			local item_str = ""
			local show_rewards = order.show_rewards 
			if show_rewards and show_rewards[1] then
				for i,v in ipairs(show_rewards[1]) do
					if type(v) == "number" then
						local item_config = item_config_fun(v)
						local item_color_id = 1
						if item_config then
							item_color_id = BackPackConst.quality_color_id[item_config.quality]
							if item_str ~= "" then
								item_str = item_str..","
							end
							item_str = string_format("%s<div fontcolor=%s>%s</div>", item_str, tranformC3bTostr(item_color_id), item_config.name)
						end
					end
				end
			end
			local str = string_format(TI18N("%s 会友<div fontcolor=#249003>%s</div>接取了<div fontcolor=%s>%s</div>远航护送订单,他将获得%s等奖励"),time_str, log.name, tranformC3bTostr(color_id), order_name, item_str)
			self.notice_log_label:setString(str)
		end
	end
end

function GuildVoyageOrderPanel:DeleteMe()
	self:registerEvent(false)
	if self.scroll_view then
		self.scroll_view:DeleteMe()
		self.scroll_view = nil
	end
end

-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      订单列表单项类型
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildVoyageOrderItem = class("GuildVoyageOrderItem", function()
	return ccui.Layout:create()
end)

function GuildVoyageOrderItem:ctor()
	self.item_list = {}
	self.item_pool_list = {}
	self.is_completed = false
end

function GuildVoyageOrderItem:setExtendData(node)
	if not tolua.isnull(node) and self.root_wnd == nil then
		self.is_completed = true
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)

		self.root_wnd = node:clone()
		self.root_wnd:setVisible(true)
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5) 
		self:addChild(self.root_wnd)

		self.quality_img = self.root_wnd:getChildByName("quality_img")
		self.order_name = self.root_wnd:getChildByName("order_name")
		self.order_time = self.root_wnd:getChildByName("order_time")
		self.item_status = self.root_wnd:getChildByName("item_status")	-- 宝物充足 249003   宝物不足 d95014

		self.confirm_btn = self.root_wnd:getChildByName("confirm_btn")
		self.confirm_btn:getChildByName("label"):setString(TI18N("接取"))

		self.root_wnd:getChildByName("rewards_title_1"):setString(TI18N("固定奖励"))

		local rewards_title_2 = self.root_wnd:getChildByName("rewards_title_2")
		rewards_title_2:setString(TI18N("概率奖励"))

		self.init_radio = self.root_wnd:getChildByName("init_radio")
		self.init_radio:setPositionX(rewards_title_2:getPositionX() + rewards_title_2:getContentSize().width + 2)

		self:setTouchEnabled(true)
		self:setSwallowTouches(false)
		self:registerEvent()
	end
end

function GuildVoyageOrderItem:registerEvent()
	self:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then	
			self.touch_end = sender:getTouchEndPosition()
			local is_click = true
			if self.touch_began ~= nil then
				is_click = math.abs( self.touch_end.x - self.touch_began.x ) <= 20 and math.abs( self.touch_end.y - self.touch_began.y ) <= 20
			end
			if is_click == true then
				playButtonSound2()
				if self.data then
					controller:openGuildvoyageOrderEscortWindow(true, GuildvoyageConst.escort_type.prepare, self.data.order_id)
				end
			end
		elseif event_type == ccui.TouchEventType.began then			
			self.touch_began = sender:getTouchBeganPosition()
		end
	end) 

	self.confirm_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender,event_type)
		if event_type == ccui.TouchEventType.ended then	
			if self.data then
				playButtonSound2()
				if self.data then
					controller:openGuildvoyageOrderEscortWindow(true, GuildvoyageConst.escort_type.prepare, self.data.order_id)
				end
				-- local max_times = model:getMaxRefreshTimes()
				-- if self.data.refresh_count >= max_times then
				-- 	CommonAlert.show(TI18N("该订单已经刷新超过上限啦!"), TI18N("确定"))
				-- else
				-- 	local cost = model:refreshCost(self.data.refresh_count)
				-- 	local item_config = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id.guild)
				-- 	if item_config then
				-- 		local msg = string_format(TI18N("是否确定花费<img src=%s visible=true scale=0.5 /><div fontcolor=#289b14 fontsize=22>%s</div>刷新该订单?"),PathTool.getItemRes(item_config.icon),cost)
				-- 		local extend_str = string_format(TI18N("(刷新后订单将会改变,该订单已刷新<div fontcolor=#289b14 fontsize=22>%s/%s</div>次)"), self.data.refresh_count, max_times)
				-- 		CommonAlert.show(msg,TI18N("确定"),function() 
				-- 			controller:requestRefresh(self.data.order_id)
				-- 		end, TI18N("取消"), nil, CommonAlert.type.rich, nil,{off_y = 43, extend_str = extend_str, extend_offy = -25,  extend_type = CommonAlert.type.rich, extend_aligment = cc.TEXT_ALIGNMENT_CENTER})
				-- 	end
				-- end
			end
		end
	end)
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code, data_list)
			if bag_code == BackPackConst.Bag_Code.BACKPACK then
				if self.data then
					local loss_config = Config.GuildShippingData.data_consume[self.data.loss_id or 0]
					if loss_config and loss_config.loss then
						for i, v in ipairs(loss_config.loss) do
							local base_id = v[1]
							for i1, v1 in pairs(data_list) do
								if v1 and v1.base_id == base_id then
									self:updateInfo()
								end
							end
						end
					end
				end
            end
        end)
    end

    if not self.modify_goods_event then
        self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code, data_list)
            if bag_code and bag_code == BackPackConst.Bag_Code.BACKPACK then 
				if self.data then
					local loss_config = Config.GuildShippingData.data_consume[self.data.loss_id or 0]
					if loss_config and loss_config.loss then
						for i, v in ipairs(loss_config.loss) do
							local base_id = v[1]
							for i1, v1 in pairs(data_list) do
								if v1 and v1.base_id == base_id then
									self:updateInfo()
								end
							end
						end
					end
				end
            end
        end)
    end
end

function GuildVoyageOrderItem:setData(data)
	if self.is_completed == false then return end
	if data == nil or data.config == nil then return end
	self.data = data
	self:updateInfo()
end

function GuildVoyageOrderItem:updateInfo()
	if self.data == nil then return end
	local data = self.data
	if self.quality ~= data.config.quality then
		self.quality = data.config.quality
		local res_id = PathTool.getResFrame("guildvoyage","guildvoyage_100"..self.quality)
		self.quality_img:loadTexture(res_id, LOADTEXT_TYPE_PLIST) 
	end
	self.order_name:setString(data.config.name)
	self.order_time:setString(TimeTool.GetTimeFormat(data.config.time))
	self.init_radio:setString(string_format(TI18N("(初始%s%s)"), data.config.rate*0.1, "%"))

	local loss_config = Config.GuildShippingData.data_consume[data.loss_id or 0]
	local be_enough = true
	if loss_config and loss_config.loss then
		for i,v in ipairs(loss_config.loss) do
			local base_id = v[1]
			local need_sum = v[2]
			local sum = backpack_mode:getBackPackItemNumByBid(base_id)
			if sum < need_sum then
				be_enough = false
				break 
			end
		end
	end	
	if be_enough == true then
		self.item_status:setString(TI18N("宝物充足"))
		self.item_status:setTextColor(Config.ColorData.data_color4[178])
	else
		self.item_status:setString(TI18N("宝物不足"))
		self.item_status:setTextColor(Config.ColorData.data_color4[183])
	end

	-- 清掉之前的物品列表
	for i, item in ipairs(self.item_list) do
		item:setVisible(false)
		table_insert(self.item_pool_list, item)
	end
	self.item_list = {}

	self:createRewardsList(data.config.rewards)
	self:createRandRewardsList(data.config.rand_rewards) 
end

--==============================--
--desc:创建固定奖励
--time:2018-06-26 05:56:35
--@return 
--==============================--
function GuildVoyageOrderItem:createRewardsList(list)
	if list == nil or next(list) == nil then return end
	local item = nil
	local scale = 0.65
	local off = 6
	local _x, _y = 0, 53
	for i,v in ipairs(list) do
		if #self.item_pool_list == 0 then
			item = BackPackItem.new(false, true, false, scale, false)
			self.root_wnd:addChild(item)
		else
			item = table_remove(self.item_pool_list, 1)
			item:setVisible(true)
		end
		_x = 25 + (i-1)*(BackPackItem.Width*scale+off) + BackPackItem.Width*scale*0.5
		item:setPosition(_x, _y)
		item:setBaseData(v[1], v[2])
		item:setDefaultTip(true)
		item:setVisible(true)
		table_insert(self.item_list, item)
	end
end

--==============================--
--desc:创建随机奖励
--time:2018-06-26 05:56:52
--@return 
--==============================--
function GuildVoyageOrderItem:createRandRewardsList(list)
	if list == nil or next(list) == nil then return end
	local item = nil
	local scale = 0.65
	local off = 6
	local _x, _y = 0, 53
	for i,v in ipairs(list) do
		if #self.item_pool_list == 0 then
			item = BackPackItem.new(false, true, false, scale, false)
			self.root_wnd:addChild(item)
		else
			item = table_remove(self.item_pool_list, 1)
		end
		_x = 213 + (i-1)*(BackPackItem.Width*scale+off) + BackPackItem.Width*scale*0.5
		item:setPosition(_x, _y)
		item:setBaseData(v[1], v[2])
		item:setDefaultTip(true, true)
		item:setVisible(true)
		table_insert(self.item_list, item)
	end
end

function GuildVoyageOrderItem:suspendAllActions()
end

function GuildVoyageOrderItem:DeleteMe()
	for i, item in ipairs(self.item_list) do
		item:DeleteMe()
	end
	if self.modify_goods_event then
		GlobalEvent:getInstance():UnBind(self.modify_goods_event)
		self.modify_goods_event = nil
	end
	if self.add_goods_event then
		GlobalEvent:getInstance():UnBind(self.add_goods_event)
		self.add_goods_event = nil
	end
	self.item_list = nil

	for i, item in ipairs(self.item_pool_list) do
		item:DeleteMe()
	end
	self.item_pool_list = nil

	self:removeAllChildren()
	self:removeFromParent()
end 