--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-10-30 10:16:29
-- @description    : 
		-- 特惠礼包（3星英雄直升礼包）
---------------------------------
ActionPreferentialWindow = ActionPreferentialWindow or BaseClass(BaseView)

function ActionPreferentialWindow:__init( icon_id )
	self.icon_id = icon_id or MainuiConst.icon.preferential
	self.ctrl = ActionController:getInstance()
    self.is_full_screen = true
    self.win_type = WinType.Big  
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.layout_name = "action/action_preferential_window"    
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("welfare","welfare"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("welfaretab","welfaretab"), type = ResourcesType.plist},
        { path = PathTool.getPlistImgForDownLoad("pokedex","pokedex"), type = ResourcesType.plist },
    }
end

function ActionPreferentialWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

	self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)

	local price_label_1 = self.main_container:getChildByName("price_label_1")
	price_label_1:setString(TI18N("总价值"))
	local title_label = self.main_container:getChildByName("title_label")
	title_label:setString(TI18N("购买奖励"))
	local time_title = self.main_container:getChildByName("time_title")
	time_title:setString(TI18N("抢购倒计时:"))

	self.close_btn = self.main_container:getChildByName("close_btn")
	self.explain_btn = self.main_container:getChildByName("explain_btn")
	self.buy_btn = self.main_container:getChildByName("buy_btn")
	self.buy_btn_label = self.buy_btn:getChildByName("label")
	self.price_label = self.main_container:getChildByName("price_label_2")
	self.time_label = self.main_container:getChildByName("time_label")
	self.role_bg = self.main_container:getChildByName("role_bg")
	self.role_bg:ignoreContentAdaptWithSize(true)

	self.goods_con = self.main_container:getChildByName("good_con")
	local scroll_view_size = self.goods_con:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 20,                  -- 第一个单元的X起点
        space_x = 20,                    -- x方向的间隔
        start_y = 4,                    -- 第一个单元的Y起点
        space_y = 4,                   -- y方向的间隔
        item_width = BackPackItem.Width,               -- 单元的尺寸width
        item_height = BackPackItem.Height,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        --scale = 0.85
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.goods_con, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function ActionPreferentialWindow:openRootWnd( bid )
	if bid then
		self.holiday_bid = bid
		self.ctrl:cs16603(self.holiday_bid)
	end
end

function ActionPreferentialWindow:register_event(  )
	if self.close_btn then
		self.close_btn:addTouchEventListener(function(sender, event_type)
			customClickAction(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				self.ctrl:openPreferentialWindow(false)
			end
		end)
	end

	if self.background then
		self.background:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				self.ctrl:openPreferentialWindow(false)
			end
		end)
	end

	if self.explain_btn then
		self.explain_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				local config_desc = Config.HolidayClientData.data_constant.preferential_rules
				if config_desc then
					TipsManager:getInstance():showCommonTips(config_desc.desc or "", sender:getTouchBeganPosition())
				end
			end
		end)
	end

	if self.buy_btn then
		self.buy_btn:addTouchEventListener(function(sender, event_type)
			customClickAction(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playButtonSound2()
				local charge_config = Config.ChargeData.data_charge_data[self.recharge_id or 0]
				if charge_config then
					sdkOnPay(charge_config.val, nil, charge_config.id, charge_config.name, charge_config.name)
				end
			end
		end)
	end

	if not self.update_action_preferential_event  then
		self.update_action_preferential_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
			if data.bid == self.holiday_bid then
				self:setData(data)
			end
		end)
	end
end

function ActionPreferentialWindow:setData( data )
	data = data or {}

	local aim_list = data.aim_list
	if not aim_list or next(aim_list) == nil then
		self.ctrl:openPreferentialWindow(false)
		return
	elseif aim_list[1].status and aim_list[1].status == 2 then -- 充值完成
		self.ctrl:openPreferentialWindow(false)
		return
	end
	local temp_data = aim_list[1].item_list or {}
	local old_price = 0
    local now_price = 0
    self.recharge_id = aim_list[1].aim

    for k,args in pairs(aim_list[1].aim_args) do
    	if args.aim_args_key == ActionExtType.ActivityOldPrice then
    		old_price = args.aim_args_val
    	elseif args.aim_args_key == ActionExtType.ActivityCurrentPrice then
    		now_price = args.aim_args_val
    	end
    end

    local item_data = {}
    for k, v in pairs(temp_data) do
        local vo = deepCopy(Config.ItemData.data_get_data(v.bid))
        vo.quantity = v.num
        table.insert(item_data, vo)
    end
	self.item_scrollview:setData(item_data)
	self.item_scrollview:addEndCallBack(function ( )
        local item_list = self.item_scrollview:getItemList()
        for k,item in pairs(item_list) do
            item:setDefaultTip()
            item:setSwallowTouches(false)
            local data1 = item:getData()
            if data1 and data1.id and data1.quality then
                for _,j in pairs(data.item_effect_list) do
                    if data1.id == j.bid then
                        if data1.quality >= 4 then
                            item:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
                        else
                            item:showItemEffect(true, 263, PlayerAction.action_2, true, 1.1)
                        end
                    end
                end
            end
        end
    end)

	local role_type = 1
	for _,v in pairs(data.args) do
		if v.args_key == 1 then
			role_type = v.args_val
			break
		end
	end
    local role_bg_res
    if role_type == 1 then
    	role_bg_res = PathTool.getTargetRes("bigbg/action","txt_cn_action_preferential_1",false,false)
    elseif role_type == 2 then
    	role_bg_res = PathTool.getTargetRes("bigbg/action","txt_cn_action_preferential_2",false,false)
    elseif role_type == 3 then
    	role_bg_res = PathTool.getTargetRes("bigbg/action","txt_cn_action_preferential_5",false,false)
    elseif role_type == 4 then
    	role_bg_res = PathTool.getTargetRes("bigbg/action","txt_cn_action_preferential_4",false,false)
    elseif role_type == 5 then
    	role_bg_res = PathTool.getTargetRes("bigbg/action","txt_cn_action_preferential_3",false,false)
    end
    self.role_bg_load = loadImageTextureFromCDN(self.role_bg, role_bg_res, ResourcesType.single, self.role_bg_load)

    self.price_label:setString(string.format("￥%d", old_price))
    self.buy_btn_label:setString(string.format(TI18N("￥%d购买"), now_price))

    self.leftTime = data.remain_sec or 0
    self.time_label:setString(TimeTool.GetTimeFormat(self.leftTime))
    self:openPrefertialTimer(true)
end

function ActionPreferentialWindow:openPrefertialTimer( status )
	if status == true then
		if self.action_timer == nil then
            self.action_timer = GlobalTimeTicket:getInstance():add(function()
                self.leftTime = self.leftTime - 1
                if self.leftTime < 0 then
                	GlobalTimeTicket:getInstance():remove(self.action_timer)
                	self.action_timer = nil
                else
                	self.time_label:setString(TimeTool.GetTimeFormat(self.leftTime))
                end
            end, 1)
        end
	else
		if self.action_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.action_timer)
            self.action_timer = nil
        end
	end
end

function ActionPreferentialWindow:close_callback(  )
	ActionController:getInstance():getModel():updataPreferentialRedStatus(false, self.icon_id)
	self.ctrl:openPreferentialWindow(false)
	self:openPrefertialTimer(false)
	if self.update_action_preferential_event then
        GlobalEvent:getInstance():UnBind(self.update_action_preferential_event)
        self.update_action_preferential_event = nil
    end

	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end

	if self.role_bg_load then 
        self.role_bg_load:DeleteMe()
        self.role_bg_load = nil
    end
end