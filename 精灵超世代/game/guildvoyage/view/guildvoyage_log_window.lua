-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      远航订单详情界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildVoyageLogWindow = GuildVoyageLogWindow or BaseClass(BaseView)

local table_insert = table.insert
local controller = GuildvoyageController:getInstance()
local string_format = string.format
local item_config_fun = Config.ItemData.data_get_data 
local shipping_config_fun = Config.GuildShippingData.data_order 

function GuildVoyageLogWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Mini
	self.layout_name = "guildvoyage/guildvoyage_log_window"
end

function GuildVoyageLogWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    container:getChildByName("win_title"):setString(TI18N("日志"))

    self.list_view = container:getChildByName("list_view")
    self.close_btn = container:getChildByName("close_btn")
    self.finish_btn = container:getChildByName("finish_btn") 
    self.finish_btn:getChildByName("label"):setString(TI18N("确定"))

    self.empty_tips = container:getChildByName("empty_tips")
    self.empty_tips:getChildByName("desc"):setString(TI18N("暂无日志记录!"))
end

function GuildVoyageLogWindow:register_event()
	self.close_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openGuildVoyageLogWindow(false)
		end
	end) 
	self.finish_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
            controller:openGuildVoyageLogWindow(false)
		end
	end) 
	if self.update_log_list_event == nil then
		self.update_log_list_event = GlobalEvent:getInstance():Bind(GuildvoyageEvent.UpdateLogListEvent, function(list)
			self:setDataList(list)
		end)
	end
end

function GuildVoyageLogWindow:openRootWnd()
	controller:requestLogList()
end

function GuildVoyageLogWindow:setDataList(list)
	if list == nil or next(list) == nil then
		if self.scroll_view then
			self.scroll_view:setVisible(false)
		end
		if self.empty_tips then
			self.empty_tips:setVisible(true)
		end
	else
		if self.scroll_view == nil then
			local size = self.list_view:getContentSize()
			local setting = {
				item_class = GuildVoyageLogItem,
				start_x = 10,
				space_x = 0,
				start_y = 7,
				space_y = 20,
				item_width = 520,
				item_height = 50,
				row = 0,
				col = 1,
				need_dynamic = true
			}
			self.scroll_view = CommonScrollViewLayout.new(self.list_view, nil, nil, nil, size, setting)
		end

		self.scroll_view:setData(list)
		self.scroll_view:setVisible(true)
		if self.empty_tips then
			self.empty_tips:setVisible(false)
		end
	end
end

function GuildVoyageLogWindow:close_callback()
	if self.update_log_list_event then
		GlobalEvent:getInstance():UnBind(self.update_log_list_event)
		self.update_log_list_event = nil
	end
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view  = nil
    end
    controller:openGuildVoyageLogWindow(false)
end

 


-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      订单列表单项类型
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildVoyageLogItem = class("GuildVoyageLogItem", function()
	return ccui.Layout:create()
end)

function GuildVoyageLogItem:ctor()
    local size = cc.size(540, 50)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(size)

    self.notice_log_label = createRichLabel(22, 175, cc.p(0, 1), cc.p(10, 50), nil, nil, 540)
   	self:addChild(self.notice_log_label) 
end

function GuildVoyageLogItem:registerEvent()
end

function GuildVoyageLogItem:setData(log)
	if log then
		if log.order_bid ~= 0 then
			local order = shipping_config_fun(log.order_bid)
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
end

function GuildVoyageLogItem:suspendAllActions()
end

function GuildVoyageLogItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end 