--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-22 16:52:31
-- @description    : 
		-- 转盘活动（限时活动）
---------------------------------

local _controller = DialActionController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _table_sort = table.sort
local _string_format = string.format

DialActionMainPanel = class("DialActionMainPanel", function()
    return ccui.Widget:create()
end)

function DialActionMainPanel:ctor(bid)
	self.pos_node_list = {}
	self.pos_list = {}
	self.cur_pos_index = 1
    self.time_full_flag = false
	self.dial_item_list = {}
    self.ani_showing = false  -- 转盘特效播放中
    self.have_cost_num = 0  -- 拥有的道具数量
    self.dial_item_cfg = {}
    self.is_free = false  -- 是否为免费
    self._init_flag = false

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("actiondial", "actiondial"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_dial_bg", true), type = ResourcesType.single},
	}

	self.resources_load = ResourcesLoad.New(true)
	self.resources_load:addAllList(self.res_list, function()
		self:loadResListCompleted()
	end)

    local ticket_cfg = Config.HolidayDialData.data_dial_const["lottery_ticket"]
    if ticket_cfg then
        self.cost_item_bid = ticket_cfg.val
    end
end

function DialActionMainPanel:loadResListCompleted(  )
	self:configUI()
	self:register_event()
    ActionController:getInstance():cs16603(ActionRankCommonType.dial)
    _controller:sender16670()  -- 转盘基础数据
    _controller:sender16674(2) -- 转盘记录（全服）
    self._init_flag = true
end

function DialActionMainPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_dial_main_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container

    local image_bg = main_container:getChildByName("image_bg")
    image_bg:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_dial_bg", true), LOADTEXT_TYPE)

    self.add_item_btn = main_container:getChildByName("add_item_btn")
    self.award_btn = main_container:getChildByName("award_btn")
    self.award_btn:getChildByName("label"):setString(TI18N("积分奖励"))
    self.extract_btn_1 = main_container:getChildByName("extract_btn_1")
    self.extract_btn_1:getChildByName("label"):setString(TI18N("抽一次"))
    self.free_label = self.extract_btn_1:getChildByName("free_label")
    self.free_label:setString(TI18N("本次免费"))
    self.cost_icon_1 = self.extract_btn_1:getChildByName("cost_icon")
    self.cost_label_1 = self.extract_btn_1:getChildByName("cost_label")
    self.extract_btn_10 = main_container:getChildByName("extract_btn_10")
    self.extract_btn_10:getChildByName("label"):setString(TI18N("抽十次"))
    self.btn_rule = main_container:getChildByName("btn_rule")
    self.no_ani_btn = main_container:getChildByName("no_ani_btn")
    self.no_ani_btn:getChildByName("label"):setString(TI18N("跳过动画"))

    self.no_ani_flag = _model:getIsNoAniFlag()
    self.no_ani_btn:setSelected(self.no_ani_flag)

    self.item_num_txt = main_container:getChildByName("item_num_txt")
    main_container:getChildByName("time_title"):setString(TI18N("剩余时间:"))
    self.refresh_time = main_container:getChildByName("refresh_time")

    self.item_panel = main_container:getChildByName("item_panel")
    for i=1,12 do
    	local pos_node = self.item_panel:getChildByName("pos_node_" .. i)
    	if pos_node then
    		_table_insert(self.pos_node_list, pos_node)
    		local pos_x, pos_y = pos_node:getPosition()
    		_table_insert(self.pos_list, cc.p(pos_x, pos_y))
    	end
    end

    local record_list = main_container:getChildByName("record_list")
	local scroll_view_size = record_list:getContentSize()
    local setting = {
        item_class = DialRecordMainItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 340,               -- 单元的尺寸width
        item_height = 30,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.record_scrollview = CommonScrollViewLayout.new(record_list, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.record_scrollview:setSwallowTouches(false)

    -- 查看更多
    if not self.check_more_txt then
    	local main_size = main_container:getContentSize()
    	self.check_more_txt = createRichLabel(22, 1, cc.p(0.5, 0.5), cc.p(main_size.width/2, 476))
    	main_container:addChild(self.check_more_txt)
    	self.check_more_txt:setString(TI18N("<div fontcolor=5dff38 href=check_more>查看更多</div>"))
    	local function clickLinkCallBack( type, value )
    		if type == "href" and value == "check_more" then
    			_controller:openDialRecordWindow(true)
    		end
    	end
    	self.check_more_txt:addTouchLinkListener(clickLinkCallBack,{"href"})
    end
end

function DialActionMainPanel:register_event(  )
	self.no_ani_btn:addEventListener(function ( sender,event_type )
        if event_type == ccui.CheckBoxEventType.selected then
            playButtonSound2()
            self.no_ani_flag = true
            _model:setIsNoAniFlag(true)
        elseif event_type == ccui.CheckBoxEventType.unselected then
        	playButtonSound2()
            self.no_ani_flag = false
            _model:setIsNoAniFlag(false)
        end
    end)

    -- 增加道具
    registerButtonEventListener(self.add_item_btn, function (  )
    	local price_cfg = Config.HolidayDialData.data_dial_const["item_price"]
        local item_cfg = Config.ItemData.data_get_data(self.cost_item_bid)
        if price_cfg and item_cfg then
            local tips_str = string.format(TI18N("是否使用<img src=%s visible=true scale=0.4 /><div fontColor=#289b14 fontsize= 26>%d购买一个%s</div>"),PathTool.getItemRes(3), price_cfg.val, item_cfg.name)
            CommonAlert.show(tips_str, TI18N("确定"), function (  )
                _controller:sender16675(1)
            end, TI18N("取消"), nil, CommonAlert.type.rich)
        end
    end)

    -- 玩法说明
    registerButtonEventListener(self.btn_rule, function ( param,sender, event_type )
        local rule_cfg = Config.HolidayDialData.data_dial_const["holiday_rule"]
        TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
    end)

    -- 积分奖励
    registerButtonEventListener(self.award_btn, function (  )
    	_controller:openDialAwardWindow(true)
    end, true)

	-- 抽一次
	registerButtonEventListener(self.extract_btn_1, function (  )
        if not self.ani_showing then
            self:onExtractOnce()
        end
	end, true, nil, nil, nil, 0.5)

	-- 抽十次
	registerButtonEventListener(self.extract_btn_10, function (  )
        if not self.ani_showing then
            self:onExtractTen()
        end
	end, true, nil, nil, nil, 0.5)

    -- 抽奖结果
    if not self.update_dial_result_event then
        self.update_dial_result_event = GlobalEvent:getInstance():Bind(DialActionEvent.Update_Dial_Result_Event,function (id)
            if id then
                self.result_index = id
                self:showDialAnimate(true)
            end
        end)
    end

    -- 转盘数据
    if not self.update_dial_data_event then
        self.update_dial_data_event = GlobalEvent:getInstance():Bind(DialActionEvent.Update_Dial_Data_Event,function (data)
            if data then
                self:initDialItemDataByLv(data.holiday_lev)
                self:setData(data)
            end
        end)
    end

    -- 转盘全服记录
    if not self.update_dial_record_event then
        self.update_dial_record_event = GlobalEvent:getInstance():Bind(DialActionEvent.Update_Dial_Record_Event, function ( r_type )
            if r_type == 2 then
                self:updateDialRecordData()
            end
        end)
    end

    -- 奖池数据变化
    if not self.update_dial_gold_event then
        self.update_dial_gold_event = GlobalEvent:getInstance():Bind(DialActionEvent.Update_Dial_Gold_Event, function (  )
            self:updateGialGoldNum()
        end)
    end

    -- 活动数据
    if not self.update_action_dial_event  then
        self.update_action_dial_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_SIGNLE,function (data)
            if data.bid == ActionRankCommonType.dial then
                self.dialLessTime = data.remain_sec
                self:setLessTime( self.dialLessTime )
            end
        end)
    end

    -- 道具数量更新
    if not self.update_add_good_event then
        self.update_add_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS,function(bag_code, data_list)
            self:updateItemNum(bag_code,data_list)
        end)
    end
    if not self.update_delete_good_event then
        self.update_delete_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS,function(bag_code, data_list)
            self:updateItemNum(bag_code,data_list)
        end)
    end
    if not self.update_modify_good_event then
        self.update_modify_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, data_list)
            self:updateItemNum(bag_code,data_list)
        end)
    end
end

-- 设置倒计时
function DialActionMainPanel:setLessTime( less_time )
    if tolua.isnull(self.refresh_time) then return end
    self.refresh_time:stopAllActions()
    if less_time > 0 then
        self.refresh_time:setString(TimeTool.GetTimeFormatDayIIIIII(less_time))
        self.refresh_time:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                self.refresh_time:stopAllActions()
            else
                self.refresh_time:setString(TimeTool.GetTimeFormatDayIIIIII(less_time))
            end
        end))))
    else
        self.refresh_time:setString(TimeTool.GetTimeFormatDayIIIIII(less_time))
    end
end

-- 抽一次
function DialActionMainPanel:onExtractOnce(  )
    if self.is_free or self.have_cost_num >= 1 then
        if self.no_ani_flag then
            _controller:sender16671(1, 1)
        else
            _controller:sender16671(1, 0)
        end
    elseif _model:getRemindFlag() and self.cost_item_bid then
        local cost_cfg = Config.HolidayDialData.data_dial_const["cost_once"]
        local item_cfg = Config.ItemData.data_get_data(self.cost_item_bid)
        if cost_cfg and item_cfg then
            local role_vo = RoleController:getInstance():getRoleVo()
            local tips_str = string.format(TI18N("是否使用<img src=%s visible=true scale=0.4 /><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>(拥有:</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>)\n</div>"),PathTool.getItemRes(3), cost_cfg.val, role_vo.gold)
            tips_str = tips_str .. string.format(TI18N("<div fontColor=#764519>购买</div><img src=%s visible=true scale=0.5 /><div fontColor=#289b14 fontsize= 26>X1</div><div fontColor=#764519>，并进行抽奖？</div>"), PathTool.getItemRes(item_cfg.icon))
            CommonAlert.show(tips_str, TI18N("确定"), function (  )
                if self.no_ani_flag then
                    _controller:sender16671(1, 1)
                else
                    _controller:sender16671(1, 0)
                end
            end, TI18N("取消"), nil, CommonAlert.type.rich)
        end
    else
        if self.no_ani_flag then
            _controller:sender16671(1, 1)
        else
            _controller:sender16671(1, 0)
        end
    end 
end

-- 抽十次
function DialActionMainPanel:onExtractTen(  )
    if self.have_cost_num >= 10 then
        if self.no_ani_flag then
            _controller:sender16671(10, 1)
        else
            _controller:sender16671(10, 0)
        end
    elseif _model:getRemindFlag() and self.cost_item_bid then
        local cost_cfg = Config.HolidayDialData.data_dial_const["cost_ten"]
        local item_cfg = Config.ItemData.data_get_data(self.cost_item_bid)
        if cost_cfg and item_cfg then
            local role_vo = RoleController:getInstance():getRoleVo()
            local tips_str = string.format(TI18N("是否使用<img src=%s visible=true scale=0.4 /><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>(拥有:</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>)\n</div>"),PathTool.getItemRes(3), cost_cfg.val, role_vo.gold)
            tips_str = tips_str .. string.format(TI18N("<div fontColor=#764519>购买</div><img src=%s visible=true scale=0.5 /><div fontColor=#289b14 fontsize= 26>X10</div><div fontColor=#764519>，并进行抽奖？</div>"), PathTool.getItemRes(item_cfg.icon))
            CommonAlert.show(tips_str, TI18N("确定"), function (  )
                if self.no_ani_flag then
                    _controller:sender16671(10, 1)
                else
                    _controller:sender16671(10, 0)
                end
            end, TI18N("取消"), nil, CommonAlert.type.rich)
        end
    else
        if self.no_ani_flag then
            _controller:sender16671(10, 1)
        else
            _controller:sender16671(10, 0)
        end
    end
end

-- 显示界面的基础数据
function DialActionMainPanel:setData( data )
    if not data then return end

    self.data = data

    self:updateGialGoldNum()
    self:updateItemNum()
    self:updateOnceBtnStatus()
    self:updateAwardRedStatus()
end

-- 刷新奖池数值显示
function DialActionMainPanel:updateGialGoldNum(  )
    local gold_num = _model:getDialGoldNum()
    if not self.gold_num then
        self.gold_num = CommonNum.new(1, self.main_container, 0, 1, cc.p(0, 0.5))
        self.gold_num:setPosition(cc.p(380, 414))
    end
    self.gold_num:setNum(gold_num)
end

function DialActionMainPanel:updateOnceBtnStatus(  )
    if self.data then
        if self.data.is_free and self.data.is_free == 0 then -- 本次免费
            self.cost_icon_1:setVisible(false)
            self.cost_label_1:setVisible(false)
            self.free_label:setVisible(true)
            self.is_free = true
        else
            self.cost_icon_1:setVisible(true)
            self.cost_label_1:setVisible(true)
            self.free_label:setVisible(false)
            self.is_free = false
        end
    end
end

function DialActionMainPanel:updateItemNum( bag_code, data_list )
    if self.cost_item_bid then
        if bag_code and data_list then
            if bag_code == BackPackConst.Bag_Code.BACKPACK then
                for i,v in pairs(data_list) do
                    if v and v.base_id and self.cost_item_bid == v.base_id then
                        self.have_cost_num = BackpackController:getInstance():getModel():getItemNumByBid(self.cost_item_bid)
                        self.item_num_txt:setString(self.have_cost_num)
                        break
                    end
                end
            end
        else
            self.have_cost_num = BackpackController:getInstance():getModel():getItemNumByBid(self.cost_item_bid)
            self.item_num_txt:setString(self.have_cost_num)
        end
    end
end

-- 转盘全服记录
function DialActionMainPanel:updateDialRecordData(  )
    local record_data = _model:getAllDialRecordData()
    self.record_scrollview:setData(record_data)
end

-- 积分奖励红点
function DialActionMainPanel:updateAwardRedStatus(  )
    local red_status = _model:getDialAwardResStatus()
    addRedPointToNodeByStatus(self.award_btn, red_status, 10, 10)
end

-- 初始化转盘物品数据
function DialActionMainPanel:initDialItemDataByLv( lv )
    if not lv then return end
    if self.dial_item_cfg and next(self.dial_item_cfg) ~= nil then return end
    self.dial_item_cfg = {}
    for k,cfg_list in pairs(Config.HolidayDialData.data_dial_item) do
        for _,v in pairs(cfg_list) do
            if v.limit_lev_min <= lv and v.limit_lev_max >= lv then
                _table_insert(self.dial_item_cfg, v)
                break
            end
        end
    end
    _table_sort(self.dial_item_cfg, SortTools.KeyLowerSorter("order"))

    self:showDialItemList()
end

-- 显示转盘物品列表
function DialActionMainPanel:showDialItemList(  )
	for i=1,12 do
		delayRun(
            self.main_container, i / display.DEFAULT_FPS, function()
            	local dial_item = self.dial_item_list[i]
            	if not dial_item then
            		local pos_node = self.pos_node_list[i]
            		if pos_node then
            			dial_item = DialGoodsItem.new()
            			pos_node:addChild(dial_item)
            			self.dial_item_list[i] = dial_item
            		end
            	end
                local item_info = self.dial_item_cfg[i]
                if item_info then
                	dial_item:setData(item_info)
                	if i == 1 or i == 4 or i == 7 or i == 10 then
                		dial_item:setItemScale(0.9)
                	else
                		dial_item:setItemScale(0.8)
                	end	
                end
                if i == 12 then
                    self:showDialAnimate()
                end
            end
        )
	end
end

-- 显示转盘特效
function DialActionMainPanel:showDialAnimate( is_extract )
    self:hideAllItemEffect(false)
	self:openDialAniTimer(false)
    self.time_full_flag = false
	if not is_extract then
		self:updateKuangAnimate(0.7)
	else
        self.ani_showing = true
		self:openDialAniTimer(true)
		self:updateKuangAnimate(0.04)
	end
end

function DialActionMainPanel:openDialAniTimer( status )
	if status == true then
		if self.dial_timer == nil then
			self.total_time = 0
			self.temp_delay_time = 0
			self.dial_timer = GlobalTimeTicket:getInstance():add(function()
                self.total_time = self.total_time + 0.1
                if self.total_time >= 1.5 then            
                	if self.temp_delay_time == 0 or self.temp_delay_time + 0.05 < self.total_time/10 then
                		self.temp_delay_time = self.total_time/10
                		self:updateKuangAnimate(self.temp_delay_time)
	                	if self.total_time > 2 then
                            self.time_full_flag = true
                            self:openDialAniTimer(false)      
	                	end
                	end             
                end
            end, 0.1)
		end
	else
		if self.dial_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.dial_timer)
            self.dial_timer = nil
        end
	end
end

function DialActionMainPanel:updateKuangAnimate( time )
    if not self.dial_item_list or next(self.dial_item_list) == nil then return end

    self.item_panel:stopAllActions()
	local function call_back(  )
		self.cur_pos_index = self.cur_pos_index + 1
		if self.cur_pos_index > #self.dial_item_list then
			self.cur_pos_index = 1
		end
        local item = self.dial_item_list[self.cur_pos_index]
        if item then
            item:showDialEffect(true)
        end
        if self.time_full_flag and self.result_index and self.cur_pos_index == self.result_index then
            self:openDialAniTimer(false)
            self.result_index = nil
            self.time_full_flag = false
            item:showDialEffect(true, PlayerAction.action_2)
            self.item_panel:stopAllActions()
            delayRun(self.main_container, 0.8, function (  )
                _controller:sender16672()
                self:showDialAnimate()
                self.ani_showing = false
            end)
        end
	end
	local delay = cc.DelayTime:create(time)
	self.item_panel:runAction(cc.RepeatForever:create(cc.Sequence:create(delay, cc.CallFunc:create(call_back))))
end

function DialActionMainPanel:hideAllItemEffect(  )
    for k,item in pairs(self.dial_item_list) do
        item:setEffectVisible(false)
    end
end

function DialActionMainPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
    if bool == true and self._init_flag == true then
        ActionController:getInstance():cs16603(ActionRankCommonType.dial)
    	_controller:sender16670()  -- 转盘基础数据
        _controller:sender16674(2) -- 转盘记录（全服）
    end
end

function DialActionMainPanel:DeleteMe(  )
    if self.ani_showing then
        _controller:sender16672()
    end
	self:openDialAniTimer(false)
    if self.item_panel then
        self.item_panel:stopAllActions()
    end
	if self.record_scrollview then
		self.record_scrollview:DeleteMe()
		self.record_scrollview = nil
	end
	if self.resources_load then
		self.resources_load:DeleteMe()
		self.resources_load = nil
	end
    for k,v in pairs(self.dial_item_list) do
        v:DeleteMe()
        v = nil
    end
    if self.gold_num then
        self.gold_num:DeleteMe()
        self.gold_num = nil
    end
    if self.update_dial_result_event then
        GlobalEvent:getInstance():UnBind(self.update_dial_result_event)
        self.update_dial_result_event = nil
    end
    if self.update_dial_data_event then
        GlobalEvent:getInstance():UnBind(self.update_dial_data_event)
        self.update_dial_data_event = nil
    end
    if self.update_dial_record_event then
        GlobalEvent:getInstance():UnBind(self.update_dial_record_event)
        self.update_dial_record_event = nil
    end
    if self.update_action_dial_event then
        GlobalEvent:getInstance():UnBind(self.update_action_dial_event)
        self.update_action_dial_event = nil
    end
    if self.update_dial_gold_event then
        GlobalEvent:getInstance():UnBind(self.update_dial_gold_event)
        self.update_dial_gold_event = nil
    end
    if self.update_add_good_event then
        GlobalEvent:getInstance():UnBind(self.update_add_good_event)
        self.update_add_good_event = nil
    end
    if self.update_delete_good_event then
        GlobalEvent:getInstance():UnBind(self.update_delete_good_event)
        self.update_delete_good_event = nil
    end
    if self.update_modify_good_event then
        GlobalEvent:getInstance():UnBind(self.update_modify_good_event)
        self.update_modify_good_event = nil
    end
end

-------------------@ 转盘上的物品 
DialGoodsItem = class("DialGoodsItem", function()
    return ccui.Widget:create()
end)

function DialGoodsItem:ctor()
	self:configUI()
end

function DialGoodsItem:configUI(  )
	self.size = cc.size(119, 119)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)
end

function DialGoodsItem:setData( data )
	if not data then return end

    -- 特等奖和一等奖加一个特殊的光效
    if data.other_type == 1 or data.other_type == 2 or data.other_type == 9 then
        self:showSpecialEffect(true)
    else
        self:showSpecialEffect(false)
    end

    self.dial_item = BackPackItem.new(true, true, false, 1, nil, true)
    self.dial_item:setPosition(cc.p(self.size.width/2, self.size.height/2))
    self:addChild(self.dial_item)
    if self.percent_sp then
        self.percent_sp:setVisible(false)
    end
    if self.percent_num then
        self.percent_num:setVisible(false)
    end
    if data.percent and data.percent > 0 then
        if not self.percent_sp then
            self.percent_sp = createSprite(PathTool.getResFrame("actiondial", "actiondial_1002"), self.size.width-12, 14, self, cc.p(1, 0))
        end
        self.percent_sp:setVisible(true)
        if not self.percent_num then
            self.percent_num = CommonNum.new(1, self, 0, -1, cc.p(1, 0))
            self.percent_num:setPosition(cc.p(self.size.width-42, 27))
        end
        self.percent_num:setVisible(true)
        self.percent_num:setNum(data.percent/10)
        self.dial_item:setBaseData(data.id)
    elseif data.num and data.num > 0 then
        self.dial_item:setBaseData(data.id, data.num)
    else
        self.dial_item:setBaseData(data.id)
    end

    local flag_res = DialActionConst.Dial_Item_Res[data.other_type]
    if flag_res then
        self.dial_item:showFlagByRes(true, PathTool.getResFrame("actiondial", flag_res))
    else
        self.dial_item:showFlagByRes(false)
    end
end

function DialGoodsItem:showDialEffect( status, action )
    if status == true then
        action = action or PlayerAction.action_1
        local loop = false
        if action == PlayerAction.action_2 then
            loop = true
        end
        if not tolua.isnull(self) and self.dial_effect == nil then
            self.dial_effect = createEffectSpine(Config.EffectData.data_effect_info[531], cc.p(self.size.width/2, self.size.height/2), cc.p(0.5, 0.5), loop, action)
            self:addChild(self.dial_effect)
        elseif self.dial_effect then
            self.dial_effect:setVisible(true)
            self.dial_effect:setToSetupPose()
            self.dial_effect:setAnimation(0, action, loop)
        end
    else
        if self.dial_effect then
            self.dial_effect:clearTracks()
            self.dial_effect:removeFromParent()
            self.dial_effect = nil
        end
    end
end

function DialGoodsItem:setEffectVisible( status )
    if self.dial_effect then
        self.dial_effect:setVisible(status)
    end
end

-- 显示特等奖、一等奖特效
function DialGoodsItem:showSpecialEffect( status )
    if status == true then
        if not tolua.isnull(self) and self.special_effect == nil then
            self.special_effect = createEffectSpine(Config.EffectData.data_effect_info[533], cc.p(self.size.width/2, self.size.height/2), cc.p(0.5, 0.5), true, PlayerAction.action)
            self:addChild(self.special_effect)
        end
    else
        if self.special_effect then
            self.special_effect:clearTracks()
            self.special_effect:removeFromParent()
            self.special_effect = nil
        end
    end
end

function DialGoodsItem:setItemScale( scale )
    self.dial_item:setScale(scale)
end

function DialGoodsItem:DeleteMe(  )
	if self.dial_item then
        self.dial_item:DeleteMe()
        self.dial_item = nil
    end
    if self.percent_num then
        self.percent_num:DeleteMe()
        self.percent_num = nil
    end
    self:showSpecialEffect(false)
    self:showDialEffect(false)
end


-------------------@ 抽奖记录item
DialRecordMainItem = class("DialRecordMainItem", function()
    return ccui.Widget:create()
end)

function DialRecordMainItem:ctor()
	self:configUI()
	self:register_event()
end

function DialRecordMainItem:configUI(  )
	self.size = cc.size(340, 30)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)
end

function DialRecordMainItem:register_event(  )
	
end

function DialRecordMainItem:setData( data )
	if not data then return end
	if not self.record_txt then
		self.record_txt = createRichLabel(20, cc.c3b(232,219,185), cc.p(0, 0.5), cc.p(7, self.size.height/2), nil, nil, 320)
		self:addChild(self.record_txt)
	end
    if data.bid then
        local item_cfg = Config.ItemData.data_get_data(data.bid)
        if item_cfg then
            local txt_str = _string_format(TI18N("<div fontcolor=5dff38>%s </div>获得%sX%d"), data.role_name, item_cfg.name, data.num)
            self.record_txt:setString(txt_str)
        end
    end
end

function DialRecordMainItem:DeleteMe(  )
	
end