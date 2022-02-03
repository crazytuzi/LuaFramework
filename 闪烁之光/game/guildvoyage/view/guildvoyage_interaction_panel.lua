-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      公会远航互助加速面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildVoyageInteractionPanel = class("GuildVoyageInteractionPanel", function()
	return ccui.Layout:create()
end)

local controller = GuildvoyageController:getInstance()
local string_format = string.format

function GuildVoyageInteractionPanel:ctor()
	self:createRootWnd()
	self:registerEvent()
end

function GuildVoyageInteractionPanel:createRootWnd()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("guildvoyage/guildvoyage_interaction_panel"))
	self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
    self:addChild(self.root_wnd)

	self.interaction_notice = self.root_wnd:getChildByName("interaction_notice")
	self.interaction_notice:setString(string.format(TI18N("还可以帮助加速 %s 次"), 10))

	self.item = self.root_wnd:getChildByName("item")
	self.item:setVisible(false) 

	self.empty_tips = self.root_wnd:getChildByName("empty_tips")
	self.empty_tips:getChildByName("desc"):setString(TI18N("当前没有可互助加速的订单!"))

	self.list_container = self.root_wnd:getChildByName("list_container")
end

function GuildVoyageInteractionPanel:registerEvent()
	if self.update_interaction_event == nil then
		self.update_interaction_event = GlobalEvent:getInstance():Bind(GuildvoyageEvent.UpdateGuildVoyageInteractionEvent, function(interaction_count, list)
			self:showInteractionCount(interaction_count)
			self:createScrollView(list)
		end)
	end

	if self.remove_interaction_event == nil then
		self.remove_interaction_event = GlobalEvent:getInstance():Bind(GuildvoyageEvent.RemoveGuildVoyageInteractionEvent, function(data, interaction_count)
			self:showInteractionCount(interaction_count)
			self:changeInteractionStatus(data)
		end)
	end
end

function GuildVoyageInteractionPanel:showInteractionCount(interaction_count)
	interaction_count = interaction_count or 0
	local config = Config.GuildShippingData.data_const.help_limit
	local count = 0
	if config then
		count = config.val - interaction_count 
	end 
	if count < 0 then count = 0 end
	-- 计算当前剩余次数
	self.interaction_count = count
	self.interaction_notice:setString(string.format(TI18N("还可以帮助加速 %s 次"), count)) 
end

function GuildVoyageInteractionPanel:createScrollView(list)
	if list == nil or next(list) == nil then
		if self.scroll_view then
			self.scroll_view:setVisible(false)
		end
		self.empty_tips:setVisible(true)
	else
		self.empty_tips:setVisible(false)
		if self.scroll_view == nil then
			local size = self.list_container:getContentSize()
			local setting = {
				item_class = GuildVoyageInteractionItem,
				start_x = 4,
				space_x = 0,
				start_y = 4,
				space_y = 2,
				item_width = 600,
				item_height = 135,
				row = 0,
				col = 1
			}
			self.scroll_view = CommonScrollViewLayout.new(self.list_container, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, size, setting, cc.p(0, 0)) 
		end

		local function click_callback(item)
			if item then
				self.selected_item = item
				local data = item.data
				if data then
					controller:requestHelpMemberOrder(data.rid, data.srv_id, data.order_id)
				end
			end
		end
		self.scroll_view:setData(list, click_callback, nil, {node=self.item, count=self.interaction_count})
	end
end

--==============================--
--desc:改变订单状态
--time:2018-07-05 07:44:01
--@data:
--@return 
--==============================--
function GuildVoyageInteractionPanel:changeInteractionStatus(data)
	if self.selected_item == nil or data == nil then return end
	local _data = self.selected_item.data
	if getNorKey(data.rid, data.srv_id, data.order_id) == getNorKey(_data.rid, _data.srv_id, _data.order_id) then
		self.selected_item:updateOrderStatus(data)
	end
end

function GuildVoyageInteractionPanel:addToParent(status)
	self:setVisible(status)
	if status == true then
		if self.scroll_view == nil then
			controller:requestInteractionList()
		end
		if self.time_ticket == nil then
			self.time_ticket = GlobalTimeTicket:getInstance():add(function() 
				self:setTimeTicket()
			end, 1) 
		end
	else
		self:clearTimeTicket()
	end
end

function GuildVoyageInteractionPanel:setTimeTicket()
	if self.scroll_view then
		local item_list = self.scroll_view:getItemList()
		for k, item in pairs(item_list) do
			item:setEndTime()
		end
	end
end

function GuildVoyageInteractionPanel:clearTimeTicket()
	if self.time_ticket then
		GlobalTimeTicket:getInstance():remove(self.time_ticket)
		self.time_ticket = nil
	end
end

function GuildVoyageInteractionPanel:DeleteMe()
	self:clearTimeTicket()
	if self.scroll_view then
		self.scroll_view:DeleteMe()
		self.scroll_view = nil
	end
	if self.update_interaction_event then
		GlobalEvent:getInstance():UnBind(self.update_interaction_event)
		self.update_interaction_event = nil
	end 
	if self.remove_interaction_event then
		GlobalEvent:getInstance():UnBind(self.remove_interaction_event)
		self.remove_interaction_event = nil
	end 
end 


-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildVoyageInteractionItem = class("GuildVoyageInteractionItem", function()
	return ccui.Layout:create()
end)

function GuildVoyageInteractionItem:ctor()
	self.item_list = {}
	self.interaction_count = 0
	self.btn_status = 0
end

--==============================--
--desc:设置扩展参数  {node = self.item, count = self.interaction_count} 
--time:2018-07-16 09:40:01
--@data:
--@return 
--==============================--
function GuildVoyageInteractionItem:setExtendData(data)
	if data == nil then return end
	local node = data.node
	self.interaction_count = data.count

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
		
		self.handle_status = self.root_wnd:getChildByName("handle_status")			-- 已加速状态
		self.handle_btn = self.root_wnd:getChildByName("handle_btn")
		self.handle_btn_label = self.handle_btn:getChildByName("label") 
		self.handle_btn_label:setString(TI18N("帮助加速"))

		self.role_name = self.root_wnd:getChildByName("role_name")					-- 角色名字
		self.order_name = self.root_wnd:getChildByName("order_name")				-- 订单名字描述
		self.order_time = self.root_wnd:getChildByName("order_time")				-- 订单剩余时间

		self.role_head = PlayerHead.new(PlayerHead.type.circle)
		self.role_head:setPosition(70, 68)
		self.root_wnd:addChild(self.role_head)
		self.role_head:setLev(99) 
		
		self:setTouchEnabled(true)
		self:setSwallowTouches(false)
		self:registerEvent()
	end
end 

function GuildVoyageInteractionItem:registerEvent()
	self.handle_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
			if self.data and self.call_back then
				self:call_back()
			end
		end
	end)
end

function GuildVoyageInteractionItem:addCallBack(callback)
	self.call_back = callback
end

function GuildVoyageInteractionItem:setData(data)
	if data then
		self.data = data
		self.role_head:setLev(data.lev)
		self.role_head:setHeadRes(data.face_id)
		self.role_name:setString(data.name)
		local order_config = Config.GuildShippingData.data_order(data.order_bid)
		if order_config ~= nil then
			self.order_name:setString(order_config.name)
		end
		self:setEndTime()
		self:updateInteractionCount()
	end
end

--==============================--
--desc:设置当前次数
--time:2018-07-16 09:50:22
--@num:
--@return 
--==============================--
function GuildVoyageInteractionItem:updateInteractionCount(num)
	self.updateInteractionCount = num or self.updateInteractionCount
	local btn_status = 0
	if self.interaction_count == 0 then
		btn_status = 1
	else
		btn_status = 0
	end
	if self.btn_status ~= btn_status then
		self.btn_status = btn_status
		if self.btn_status == 0 then
			setChildUnEnabled(false, self.handle_btn)
			self.handle_btn:setTouchEnabled(true)
			self.request_btn_label:enableOutline(Config.ColorData.data_color4[177]) 
			self.handle_btn_label:setString(TI18N("帮助加速"))
		else
			setChildUnEnabled(true, self.handle_btn)
			self.handle_btn:setTouchEnabled(false)
			self.handle_btn_label:disableEffect()
			self.handle_btn_label:setString(TI18N("次数不足"))
		end
	end
end

function GuildVoyageInteractionItem:setEndTime()
	if self.data == nil then return end
	local end_time = self.data.end_time - GameNet:getInstance():getTime()
	if end_time < 0 then 
		self.order_time:setString(TI18N("订单已完成")) 
	else
		self.order_time:setString(string_format("%s:%s", TI18N("剩余时间"), TimeTool.GetTimeFormat(end_time)))
	end
end

--==============================--
--desc:更新订单状态
--time:2018-07-05 08:10:50
--@data:
--@return 
--==============================--
function GuildVoyageInteractionItem:updateOrderStatus(data)
	if data then
		self.data.end_time = data.end_time
		self.data.status = data.status
		self.handle_btn:setTouchEnabled(false)
		setChildUnEnabled(true, self.handle_btn)
		self.handle_btn_label:disableEffect()
		self.handle_btn_label:setString(TI18N("已加速"))
	end
end

function GuildVoyageInteractionItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end 