-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      成长基金
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ActionGrowFundPanel = class("ActionGrowFundPanel", function()
    return ccui.Widget:create()
end)

local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local controller = ActionController:getInstance()

function ActionGrowFundPanel:ctor(bid,type)
	self.touch_buy_growfund = true
	self.holiday_bid = bid
	self.type = type
	self.item_list = {}
	self:configUI()
	self:register_event()
end

function ActionGrowFundPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_grow_fund_panel"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0,0)

    self.main_container = self.root_wnd:getChildByName("main_container")

	self.challenge_btn = self.main_container:getChildByName("challenge_btn")
	self.challenge_btn_label = self.challenge_btn:getChildByName("label")

	self.item = self.root_wnd:getChildByName("item")
	self.item:setVisible(false)

	self.goods_con = self.main_container:getChildByName("goods_con")

	self.empty_tips = self.main_container:getChildByName("empty_tips")
	self.empty_tips:getChildByName("label"):setString(TI18N("您已获得全部成长基金!!"))

    self.title_con = self.main_container:getChildByName("title_con")
    self.title_img = self.title_con:getChildByName("title_img")
    local res = PathTool.getTargetRes("bigbg/action","txt_cn_action_grow_fund_title",false,false)
    if not self.resources_load then
        self.resources_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.title_img) then
                loadSpriteTexture(self.title_img, res, LOADTEXT_TYPE)
            end
        end)
    end
end

function ActionGrowFundPanel:register_event()
    self.challenge_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
			local config = Config.ChargeData.data_charge_data[101]
			if config and self.touch_buy_growfund == true then
				self.touch_buy_growfund = nil
				sdkOnPay(config.val, nil, config.id, config.name)
				if self.send_buy_growfund_ticket == nil then
	                self.send_buy_growfund_ticket = GlobalTimeTicket:getInstance():add(function()
	                    self.touch_buy_growfund = true
	                    if self.send_buy_growfund_ticket ~= nil then
	                        GlobalTimeTicket:getInstance():remove(self.send_buy_growfund_ticket)
	                        self.send_buy_growfund_ticket = nil
	                    end
	                end,2)
	            end
			end
        end
    end)
    if not self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function(data)
            if data.bid == self.holiday_bid then
                self:createList(data)
				self:checkTabIconStatus()
            end
        end)
    end
end

function ActionGrowFundPanel:checkTabIconStatus(data)
	--未激活的时候
	if SysEnv:getInstance():getBool(SysEnv.keys.grow_fund_redpoint) then
		controller:setHolidayStatus(self.holiday_bid, false)
		if self.holiday_bid == ActionSpecialID.growfund then
			WelfareController:getInstance():setWelfareStatus(ActionSpecialID.growfund, false)
		end
		SysEnv:getInstance():set(SysEnv.keys.grow_fund_redpoint, false)
	end
end

function ActionGrowFundPanel:createList(data)
	if data == nil or data.aim_list == nil then return end
	local can_buy = (data.finish == FALSE and (next(data.aim_list) ~= nil))
	if self.challenge_btn_status ~= can_buy then
		self.challenge_btn_status = can_buy
		if can_buy == false then
			setChildUnEnabled(true, self.challenge_btn) 
			self.challenge_btn:setTouchEnabled(false) 
			--self.challenge_btn_label:disableEffect()
			self.challenge_btn_label:setString(TI18N("已充值"))
		else
			setChildUnEnabled(false, self.challenge_btn) 
			self.challenge_btn:setTouchEnabled(true) 
			--self.challenge_btn_label:enableOutline(Config.ColorData.data_color4[277], 2)

			local config = Config.ChargeData.data_charge_data[101]
			local val = 88
			if config then
				val = config.val
			end
			local label_str = string.format(TI18N("￥%s购买"), val)
			self.challenge_btn_label:setString(label_str)
		end
	end

	local item_list = {}
	for i,v in ipairs(data.aim_list) do
		v.sort_index = 0
		if v.status == ActionStatus.un_finish then
			v.sort_index = 1
		elseif v.status == ActionStatus.finish then
			v.sort_index = 0
		elseif v.status == ActionStatus.completed then
			v.sort_index = 2
		end
		table_insert(item_list, v)
	end

	if next(item_list) == nil then
		self.empty_tips:setVisible(true)
		if self.scroll_view then
			self.scroll_view:setVisible(false)
		end
	else
		local sort_func = SortTools.tableLowerSorter({"sort_index", "aim"})
		table_sort(item_list, sort_func)
		if self.scroll_view == nil then
			local size = self.goods_con:getContentSize()
			local setting = {
				item_class = ActionGrowFundItem,
				start_x = 3,
				space_x = 0,
				start_y = 0,
				space_y = 5,
				item_width = 678,
				item_height = 90,
				row = 0,
				col = 1,
				need_dynamic = true
			}
			self.scroll_view = CommonScrollViewLayout.new(self.goods_con, nil, nil, nil, size, setting)
		end
		local function callback(data)
			if data and data.aim then
				controller:cs16604(self.holiday_bid, data.aim, 0)
			end
		end
		self.scroll_view:setData(item_list, callback, nil, self.item) 

		self.empty_tips:setVisible(false)
		self.scroll_view:setVisible(true)
	end
end

function ActionGrowFundPanel:setVisibleStatus(status)
    self:setVisible(status)
    if status then
		if self.scroll_view == nil then
        	ActionController:getInstance():cs16603(self.holiday_bid)
		end
    end
end

function ActionGrowFundPanel:DeleteMe()
	if self.update_action_even_event then
		GlobalEvent:getInstance():UnBind(self.update_action_even_event)
		self.update_action_even_event = nil
	end
	if self.send_buy_growfund_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.send_buy_growfund_ticket)
        self.send_buy_growfund_ticket = nil
    end
	if self.scroll_view then
		self.scroll_view:DeleteMe()
	end
	self.scroll_view = nil

	if self.resources_load then
		self.resources_load:DeleteMe()
	end
	self.resources_load = nil
end


ActionGrowFundItem = class("ActionGrowFundItem", function()
	return ccui.Layout:create()
end)

function ActionGrowFundItem:ctor()
    self.is_completed = false
end

--==============================--
--desc:设置扩展参数  {node = self.item, count = self.interaction_count} 
--time:2018-07-16 09:40:01
--@data:
--@return 
--==============================--
function ActionGrowFundItem:setExtendData(node)	
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

		self.title_bg = self.root_wnd:getChildByName("title_bg")
		self.title = self.root_wnd:getChildByName("title")

		self.get_btn = self.root_wnd:getChildByName("get_btn")
		self.get_btn_label = self.get_btn:getChildByName("label")
		self.get_btn_label:setString(TI18N("领取"))

		self.item_icon_1 = self.root_wnd:getChildByName("item_icon_1")
		self.item_icon_2 = self.root_wnd:getChildByName("item_icon_2")
		self.item_value_1 = self.root_wnd:getChildByName("item_value_1")
		self.item_value_2 = self.root_wnd:getChildByName("item_value_2")

		self.pass_icon = self.root_wnd:getChildByName("pass_icon")

		self:registerEvent()
	end
end

function ActionGrowFundItem:registerEvent()
    self.get_btn:addTouchEventListener(function(sender, event_type)
		customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
			if self.call_back and self.data then
				self.call_back(self.data)
			end
        end
    end)
end

function ActionGrowFundItem:addCallBack(callback)
	self.call_back = callback
end

function ActionGrowFundItem:setData(data)
	if data then
		self.data = data
		self.title:setString(data.aim_str or "")
		self.get_btn:setVisible(data.status ~= ActionStatus.completed)
		self.pass_icon:setVisible(data.status == ActionStatus.completed)
		if data.status == ActionStatus.un_finish then
			setChildUnEnabled(true, self.get_btn) 
			self.get_btn:setTouchEnabled(false)
			self.get_btn_label:setString(TI18N("未达成"))
			self.get_btn_label:disableEffect(cc.LabelEffect.SHADOW)
			self.title_bg:setOpacity(255)
		elseif data.status == ActionStatus.finish then
			setChildUnEnabled(false, self.get_btn) 
			self.get_btn:setTouchEnabled(true)
			self.get_btn_label:setString(TI18N("领取"))
			self.get_btn_label:enableShadow(Config.ColorData.data_new_color4[4],cc.size(0, -2),2)
			self.title_bg:setOpacity(255)
		elseif data.status == ActionStatus.completed then
			self.title_bg:setOpacity(128)
		end

		if data.item_list then
			for i,v in ipairs(data.item_list) do
				if self["item_icon_"..i] then
					self["item_icon_"..i]:loadTexture(PathTool.getItemRes(v.bid), LOADTEXT_TYPE)
				end
				if self["item_value_"..i] then
					self["item_value_"..i]:setString("x"..(v.num or 0))
				end
			end
		end
	end
end

function ActionGrowFundItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end 