--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-04-08 11:41:31
-- @description    : 
		-- 砸金蛋活动（限时活动）
---------------------------------

local _controller = SmasheggController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format
local _table_sort = table.sort

ActionSmasheggPanel = class("ActionSmasheggPanel", function()
    return ccui.Widget:create()
end)

function ActionSmasheggPanel:ctor(bid)
	self.pos_node_list = {}
	self.egg_list = {}
	self._init_flag = false
    self._is_refresh = false -- 标识是否为刷新

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("actionsmashegg", "actionsmashegg"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_smash_egg", true), type = ResourcesType.single},
	}

	self.resources_load = ResourcesLoad.New(true)
	self.resources_load:addAllList(self.res_list, function()
		self:loadResListCompleted()
	end)

	self.cost_item_bid = Config.BreakEggData.data_const["item_bid"].val
end

function ActionSmasheggPanel:loadResListCompleted(  )
	self:configUI()
	self:register_event()
	
	_controller:sender16680()
	_controller:sender16685(2)
	self:updateGreatAwardList()

	self._init_flag = true
end

function ActionSmasheggPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_smash_egg_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")
    local main_size = main_container:getContentSize()
    self.main_container = main_container

    local image_bg = main_container:getChildByName("image_bg")
    image_bg:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_smash_egg", true), LOADTEXT_TYPE)

    self.add_item_btn = main_container:getChildByName("add_item_btn")
    self.item_num_txt = main_container:getChildByName("item_num_txt")

    self.btn_rule = main_container:getChildByName("btn_rule")
    self.refresh_time = main_container:getChildByName("refresh_time")

    main_container:getChildByName("title_award"):setString(TI18N("极品奖励展示:"))
    main_container:getChildByName("title_luck"):setString(TI18N("幸运值:"))
    main_container:getChildByName("title_record"):setString(TI18N("全服记录"))
    main_container:getChildByName("time_title"):setString(TI18N("剩余时间:"))

    local progress_bg = main_container:getChildByName("progress_bg")
    self.progress = progress_bg:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    self.progress:setPercent(0)
    self.progress_value = progress_bg:getChildByName("progress_value")
    self.progress_value:setString(0)

    self.refresh_btn = main_container:getChildByName("refresh_btn")
    self.refresh_btn:getChildByName("label"):setString(TI18N("刷新"))
    self.smash_all_btn = main_container:getChildByName("smash_all_btn")
    self.smash_all_btn:getChildByName("label"):setString(TI18N("全部砸开"))
    self.record_more = main_container:getChildByName("record_more")

    if not self.cost_tips then
    	self.cost_tips = createRichLabel(20, cc.c4b(254, 255, 213, 255), cc.p(0.5, 0.5), cc.p(main_size.width/2, 245))
    	main_container:addChild(self.cost_tips)
    	local item_config = Config.ItemData.data_get_data(self.cost_item_bid)
    	if item_config then
    		self.cost_tips:setString(_string_format(TI18N("每次砸蛋消耗 <img src='%s' scale=0.3 />X1"), PathTool.getItemRes(item_config.icon)))
    	end
    end

    -- 刷新消耗显示
    if not self.refresh_cost_txt then
    	self.refresh_cost_txt = createRichLabel(20, cc.c4b(254, 255, 213, 255), cc.p(0.5, 0.5), cc.p(163, 146))
    	main_container:addChild(self.refresh_cost_txt)
    end
    -- 全部砸开消耗显示
    if not self.smash_cost_txt then
    	self.smash_cost_txt = createRichLabel(20, cc.c4b(254, 255, 213, 255), cc.p(0.5, 0.5), cc.p(564, 146))
    	main_container:addChild(self.smash_cost_txt)
    end

    for i=1,6 do
    	local pos_node = main_container:getChildByName("pos_node_" .. i)
    	if pos_node then
    		_table_insert(self.pos_node_list, pos_node)
    	end
    end

    -- 极品奖励展示
    local award_list = main_container:getChildByName("award_list")
    local bgSize = award_list:getContentSize()
	local scroll_view_size = cc.size(bgSize.width, bgSize.height)
	local scale = 0.7
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 7,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*scale,               -- 单元的尺寸width
        item_height = BackPackItem.Height*scale,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    	scale = scale
    }
    self.award_scrollview = CommonScrollViewLayout.new(award_list, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)

    -- 全服记录
    local record_list = main_container:getChildByName("record_list")
	local scroll_view_size = record_list:getContentSize()
    local setting = {
        item_class = SmasheggMainRecordItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 1,                   -- y方向的间隔
        item_width = 400,               -- 单元的尺寸width
        item_height = 22,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.record_scrollview = CommonScrollViewLayout.new(record_list, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.record_scrollview:setSwallowTouches(false)
end

function ActionSmasheggPanel:register_event(  )
	registerButtonEventListener(self.add_item_btn, function (  )
		self:onClickAddItemBtn()
	end, false)

	registerButtonEventListener(self.btn_rule, function ( param,sender, event_type )
		self:onClickRuleBtn(param,sender, event_type)
	end, false)

	registerButtonEventListener(self.refresh_btn, function (  )
		self:onClickRefreshBtn()
	end, true, nil, nil, nil, 0.5)

	registerButtonEventListener(self.smash_all_btn, function (  )
		self:onClickSmashAllBtn()
	end, true, nil, nil, nil, 0.5)

    -- 查看更多日志
    self.record_more:addTouchEventListener(function ( sender, event_type )
        if event_type == ccui.TouchEventType.began then
            self.touch_began = sender:getTouchBeganPosition()
        elseif event_type == ccui.TouchEventType.ended then
            self.touch_end = sender:getTouchEndPosition()
            local is_click = true
            if self.touch_began ~= nil then
                is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click == true then
                playButtonSound2()
                _controller:openSmasheggRecordWindow(true)
            end
        end
    end)

	-- 砸蛋活动数据
	if not self.update_smashegg_data_event then
        self.update_smashegg_data_event = GlobalEvent:getInstance():Bind(SmasheggEvent.Update_Smashegg_Data_Event, function (data)
            if data then
                self:setData(data)
            end
        end)
    end

    -- 日志数据
    if not self.update_smashegg_record_event then
    	self.update_smashegg_record_event = GlobalEvent:getInstance():Bind(SmasheggEvent.Update_Smashegg_Record_Event, function (data)
            if data and data.type == 2 then
                self:updateRecordList(data.log_list)
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

function ActionSmasheggPanel:updateItemNum( bag_code, data_list )
	if self.cost_item_bid then
        if bag_code and data_list then
            if bag_code == BackPackConst.Bag_Code.BACKPACK then
                for i,v in pairs(data_list) do
                    if v and v.base_id and self.cost_item_bid == v.base_id then
                        local have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.cost_item_bid)
                        self.item_num_txt:setString(have_num)
                        break
                    end
                end
            end
        else
            have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.cost_item_bid)
            self.item_num_txt:setString(have_num)
        end
    end
end

-- 点击购买道具
function ActionSmasheggPanel:onClickAddItemBtn(  )
    local id = ActionRankCommonType.action_wolf
    local action_crtl = ActionController:getInstance()
    local tab_vo = action_crtl:getActionSubTabVo(id)
    if tab_vo and action_crtl.action_operate then
        action_crtl.action_operate:handleSelectedTab(action_crtl.action_operate.tab_list[id])
    end
	--[[if not self.cost_item_bid then return end
	local item_cfg = Config.ItemData.data_get_data(self.cost_item_bid)
	local give_exp_cfg = Config.BreakEggData.data_const["give_exp"]
	local gold_once_cfg = Config.BreakEggData.data_const["gold_once"]
    if item_cfg and give_exp_cfg and gold_once_cfg then
        local role_vo = RoleController:getInstance():getRoleVo()
        local tips_str = string.format(TI18N("是否使用<img src=%s visible=true scale=0.4 /><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>(拥有:</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>)\n</div>"),PathTool.getItemRes(3), gold_once_cfg.val, role_vo.gold)
        tips_str = tips_str .. string.format(TI18N("<div fontColor=#764519>购买<div fontColor=#289b14 fontsize= 26>%d</div><div fontColor=#d95014 fontsize= 26>宝可梦经验</div><div fontColor=#764519>(同时附赠</div><div fontColor=#289b14 fontsize= 26>1个</div><div fontColor=#764519>%s)</div>"), give_exp_cfg.val, item_cfg.name)
        CommonAlert.show(tips_str, TI18N("确定"), function (  )
            _controller:sender16684(1)
        end, TI18N("取消"), nil, CommonAlert.type.rich)
    end--]]
end

-- 点击规则说明
function ActionSmasheggPanel:onClickRuleBtn( param, sender, event_type )
	local rule_cfg = Config.BreakEggData.data_const["holiday_rule"]
	if rule_cfg then
		TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
	end
end

-- 点击刷新按钮
function ActionSmasheggPanel:onClickRefreshBtn(  )
	if not _controller:checkRefreshReqIsBack() then
		message(TI18N("刷新过快"))
		return
	end
	if self.data then
		if self:checkIsHaveGreatEgg() then
			local tips_str = _string_format(TI18N("当前还有极品蛋未砸开哦，您是否要刷新？"))
            CommonAlert.show(tips_str, TI18N("确定"), function (  )
                self._is_refresh = true
                _controller:sender16681()
            end, TI18N("取消"), nil, CommonAlert.type.rich)
		else
            self._is_refresh = true
			_controller:sender16681()
		end
	end
end

-- 点击全部砸开按钮
function ActionSmasheggPanel:onClickSmashAllBtn(  )
	if not self.cost_item_bid then return end
	local left_egg_num = self:getNotSmashEggNum()
	local have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.cost_item_bid)
	if have_num >= left_egg_num then
		_controller:sender16683()
	else
        local item_cfg = Config.ItemData.data_get_data(self.cost_item_bid)
        if item_cfg then
            message(_string_format(TI18N("%s数量不足"), item_cfg.name))
        end
		--[[local item_cfg = Config.ItemData.data_get_data(self.cost_item_bid)
		local give_exp_cfg = Config.BreakEggData.data_const["give_exp"]
		local gold_once_cfg = Config.BreakEggData.data_const["gold_once"]
        if item_cfg and give_exp_cfg and gold_once_cfg then
            local role_vo = RoleController:getInstance():getRoleVo()
            local tips_str = string.format(TI18N("是否使用<img src=%s visible=true scale=0.4 /><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>(拥有:</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>)\n</div>"),PathTool.getItemRes(3), gold_once_cfg.val*left_egg_num, role_vo.gold)
            tips_str = tips_str .. string.format(TI18N("<div fontColor=#764519>购买<div fontColor=#289b14 fontsize= 26>%d</div><div fontColor=#d95014 fontsize= 26>宝可梦经验</div><div fontColor=#764519>(同时附赠</div><div fontColor=#289b14 fontsize= 26>%d个</div><div fontColor=#764519>%s)</div>"), give_exp_cfg.val*left_egg_num, left_egg_num, item_cfg.name)
            CommonAlert.show(tips_str, TI18N("确定"), function (  )
                _controller:sender16683()
            end, TI18N("取消"), nil, CommonAlert.type.rich)
        end--]]
	end
end

-- 检测是否有未砸开的极品蛋
function ActionSmasheggPanel:checkIsHaveGreatEgg(  )
	local is_have = false
	if self.data and self.data.egg_status then
		for k,eData in pairs(self.data.egg_status) do
			if eData.type == 2 and eData.status == 0 then
				is_have = true
				break
			end
		end
	end
	return is_have
end

-- 获取剩余未砸开的金蛋数量
function ActionSmasheggPanel:getNotSmashEggNum(  )
	local num = 0
	if self.data and self.data.egg_status then
		for k,eData in pairs(self.data.egg_status) do
			if eData.status == 0 then
				num = num + 1
			end
		end
	end
	return num
end

function ActionSmasheggPanel:setData( data )
	if not data then return end

	self.data = data
	local egg_list = data.egg_status or {}
	_table_sort(egg_list, SortTools.KeyLowerSorter("pos"))

	self:updateLuckInfo()
	self:updateLessTime()
	self:updateFreeTimes()
	self:updateItemNum()
	self:updateEggsList(egg_list)
end

-- 显示极品奖励展示
function ActionSmasheggPanel:updateGreatAwardList(  )
	local award_data = {}
	for i,v in ipairs(Config.BreakEggData.data_award) do
		local bid = v.bid
		local vo = deepCopy(Config.ItemData.data_get_data(bid))
        vo.quantity = v.num
        vo.show_effect = v.show_effect
        _table_insert(award_data, vo)
	end
	self.award_scrollview:setData(award_data)
	self.award_scrollview:setClickEnabled(#award_data > 4)
	self.award_scrollview:addEndCallBack(function ()
		local list = self.award_scrollview:getItemList()
        for k,v in pairs(list) do
            v:setDefaultTip()
            local item_data = v:getData()
            if item_data and item_data.show_effect == 1 then
            	v:showItemEffect(true,263,PlayerAction.action_1,true,1.1)
            end       
        end
	end)
end

-- 刷新幸运值
function ActionSmasheggPanel:updateLuckInfo(  )
	if not self.data then return end

	local lucky = self.data.lucky or 0
	local max_lucky = 0
	local lucky_cfg = Config.BreakEggData.data_const["lucky_max"]
	if lucky_cfg then
		max_lucky = lucky_cfg.val or 0
	end
	local percent = (lucky/max_lucky)*100
	self.progress:setPercent(percent)
	self.progress_value:setString( lucky .. "/" .. max_lucky)
end

-- 刷新全服记录
function ActionSmasheggPanel:updateRecordList( record_data )
	self.record_scrollview:setData(record_data)
end

-- 刷新金蛋显示
function ActionSmasheggPanel:updateEggsList( data_list )
	if not data_list or next(data_list) == nil then return end
    if self._is_refresh then -- 刷新时才全部隐藏再依次显示
        for k,v in pairs(self.egg_list) do
            v:setVisible(false)
        end
    end
	for i=1,6 do
        local delay_time = 0
        if self._is_refresh then
            delay_time = 2*i/display.DEFAULT_FPS
        end
		delayRun(self.main_container, delay_time, function()
            local egg_item = self.egg_list[i]
            if egg_item == nil then
            	local pos_node = self.pos_node_list[i]
            	egg_item = SmasheggItem.new()
            	pos_node:addChild(egg_item)
            	self.egg_list[i] = egg_item
            end
            local egg_data = data_list[i]
            if egg_data then
            	egg_item:setData(egg_data)
                egg_item:setVisible(true)
            end
        end)
	end
    self._is_refresh = false
end

-- 按钮消耗显示
function ActionSmasheggPanel:updateFreeTimes(  )
	if not self.data or not self.refresh_cost_txt then return end

	local free_time = self.data.free_num or 0
	if free_time > 0 then
		local max_free_cfg = Config.BreakEggData.data_const["free_time"]
		local max_free_num = 0
		if max_free_cfg then
			max_free_num = max_free_cfg.val or 0
		end
		self.refresh_cost_txt:setString(_string_format(TI18N("免费次数:%d/%d"), free_time, max_free_num))
	else
		local refresh_cfg = Config.BreakEggData.data_const["refresh_gold"]
		if refresh_cfg then
			local cost_gold = refresh_cfg.val or 0
			self.refresh_cost_txt:setString(_string_format(TI18N("消耗 <img src='%s' scale=0.25 /> %d"), PathTool.getItemRes(3), cost_gold))
		end
	end

	if self.smash_cost_txt then
		local item_config = Config.ItemData.data_get_data(self.cost_item_bid)
		local left_egg_num = self:getNotSmashEggNum()
		if item_config then
			self.smash_cost_txt:setString(_string_format(TI18N("消耗 <img src='%s' scale=0.3 />%d"), PathTool.getItemRes(item_config.icon), left_egg_num or 6))
		end
	end
end

-- 刷新剩余时间
function ActionSmasheggPanel:updateLessTime(  )
	if not self.data then return end

	local end_time = self.data.endtime
	local cur_time = GameNet:getInstance():getTime()
	local less_time = end_time - cur_time
	self:setLessTime(less_time)
end

-- 设置倒计时
function ActionSmasheggPanel:setLessTime( less_time )
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

function ActionSmasheggPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
    if bool == true and self._init_flag == true then
        _controller:sender16680()
    end
end

function ActionSmasheggPanel:DeleteMe(  )
	if self.resources_load then
		self.resources_load:DeleteMe()
		self.resources_load = nil
	end
	if self.award_scrollview then
		self.award_scrollview:DeleteMe()
		self.award_scrollview = nil
	end
	if self.record_scrollview then
		self.record_scrollview:DeleteMe()
		self.record_scrollview = nil
	end
	for k,v in pairs(self.egg_list) do
		v:DeleteMe()
		v = nil
	end
	if self.update_smashegg_data_event then
		GlobalEvent:getInstance():UnBind(self.update_smashegg_data_event)
		self.update_smashegg_data_event = nil
	end
	if self.update_smashegg_record_event then
		GlobalEvent:getInstance():UnBind(self.update_smashegg_record_event)
		self.update_smashegg_record_event = nil
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
	_model:setSmasheggAniPlaying(false)
end

---------------- 金蛋 item
SmasheggItem = class("SmasheggItem", function()
    return ccui.Widget:create()
end)

function SmasheggItem:ctor()
	self:configUI()
	self:register_event()

	self.is_ani_playing = false -- 是否正在播放特效
	self.cost_item_bid = Config.BreakEggData.data_const["item_bid"].val
end

function SmasheggItem:configUI(  )
	self.size = cc.size(124, 150)
	self:setTouchEnabled(true)
	self:setAnchorPoint(cc.p(0.5, 0))
	self:setPosition(cc.p(self.size.width/2, -7))
    self:setContentSize(self.size)

    self.egg_icon = createImage(self, nil, 0, 0, cc.p(0.5, 0), true)
    self.egg_icon:setTouchEnabled(true)
end

function SmasheggItem:register_event(  )
	registerButtonEventListener(self.egg_icon, function (  )
		self:onClickEggIcon()
	end, false)
end

function SmasheggItem:onClickEggIcon(  )
	if _model:getSmasheggAniPlaying() then return end -- 特效播放中
	if not self.data or self.data.status == 1 then return end -- 已经砸开
	if self.data and self.cost_item_bid then
		local have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.cost_item_bid)
		if have_num >= 1 then
			_model:setSmasheggAniPlaying(true)
			self:handleEffect(true)
		else
            local item_cfg = Config.ItemData.data_get_data(self.cost_item_bid)
            if item_cfg then
                message(_string_format(TI18N("%s数量不足"), item_cfg.name))
            end
            --[[if self.alert_tips then
                self.alert_tips:close()
                self.alert_tips = nil
            end
			local item_cfg = Config.ItemData.data_get_data(self.cost_item_bid)
			local give_exp_cfg = Config.BreakEggData.data_const["give_exp"]
			local gold_once_cfg = Config.BreakEggData.data_const["gold_once"]
	        if item_cfg and give_exp_cfg and gold_once_cfg then
	            local role_vo = RoleController:getInstance():getRoleVo()
	            local tips_str = string.format(TI18N("是否使用<img src=%s visible=true scale=0.4 /><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>(拥有:</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>)\n</div>"),PathTool.getItemRes(3), gold_once_cfg.val, role_vo.gold)
	            tips_str = tips_str .. string.format(TI18N("<div fontColor=#764519>购买<div fontColor=#289b14 fontsize= 26>%d</div><div fontColor=#d95014 fontsize= 26>宝可梦经验</div><div fontColor=#764519>(同时附赠</div><div fontColor=#289b14 fontsize= 26>1个</div><div fontColor=#764519>%s)</div>"), give_exp_cfg.val, item_cfg.name)
	            self.alert_tips = CommonAlert.show(tips_str, TI18N("确定"), function (  )
                    if gold_once_cfg.val <= role_vo.gold then
                        _model:setSmasheggAniPlaying(true)
                        self:handleEffect(true)
                    else
                        message(TI18N("钻石不足"))
                    end
                end, TI18N("取消"), nil, CommonAlert.type.rich)
	        end--]]
		end
	end
end

function SmasheggItem:setData( data )
	if not data then return end

	self.data = data

	local is_show_ani = false
	local egg_res = PathTool.getResFrame("actionsmashegg","actionsmashegg_1001")
	if data.type == 1 and data.status == 0 then 	   -- 普通蛋，未砸开
		egg_res = PathTool.getResFrame("actionsmashegg","actionsmashegg_1001")
	elseif data.type == 1 and data.status == 1 then -- 普通蛋，已砸开
		egg_res = PathTool.getResFrame("actionsmashegg","actionsmashegg_1003")
	elseif data.type == 2 and data.status == 0 then -- 极品蛋，未砸开
		is_show_ani = true
		egg_res = PathTool.getResFrame("actionsmashegg","actionsmashegg_1002")
	elseif data.type == 2 and data.status == 1 then -- 极品蛋，已砸开
		egg_res = PathTool.getResFrame("actionsmashegg","actionsmashegg_1004")
	end
	if not self.cur_egg_res or self.cur_egg_res ~= egg_res then
		self.egg_icon:loadTexture(egg_res, LOADTEXT_TYPE_PLIST)
	end
    self.egg_icon:setVisible(true)

	-- 砸开的物品
	if data.status == 1 and data.show_reward and data.show_reward[1] then
		local bid = data.show_reward[1].item_id
		local num = data.show_reward[1].num
		if not self.reward_item then
			self.reward_item = BackPackItem.new(true, true, nil, 0.7)
			self.reward_item:setDefaultTip()
			self.reward_item:setAnchorPoint(cc.p(0.5, 0.5))
			self.reward_item:setPosition(cc.p(0, 100))
			self:addChild(self.reward_item)
		end
		self.reward_item:setVisible(true)
		self.reward_item:setBaseData(bid, num)
	elseif self.reward_item then
		self.reward_item:setVisible(false)
	end

	if is_show_ani then
		if not self.ani_showing then
			self.egg_icon:setRotation(0)
			self.egg_icon:stopAllActions()
			local act_1 = cc.RotateBy:create(0.05, -5)
	        local act_2 = cc.RotateBy:create(0.1, 10)
	        local act_3 = cc.RotateBy:create(0.05, -5)
	        local delay = cc.DelayTime:create(0.7)
	        local actions = {}
	        for i=1,5 do
	            _table_insert(actions, act_1)
	            _table_insert(actions, act_2)
	            _table_insert(actions, act_3)
	        end
	        _table_insert(actions, delay)
			self.egg_icon:runAction(cc.RepeatForever:create(cc.Sequence:create(unpack(actions))))
			self.ani_showing = true
		end
	else
		self.egg_icon:setRotation(0)
		self.egg_icon:stopAllActions()
		self.ani_showing = false
	end
end

function SmasheggItem:handleEffect( status )
	if status == false then
        if self.egg_effect then
            self.egg_effect:clearTracks()
            self.egg_effect:removeFromParent()
            self.egg_effect = nil
        end
    else
    	self.is_ani_playing = true
        if not tolua.isnull(self) and self.egg_effect == nil then
            self.egg_effect = createEffectSpine(Config.EffectData.data_effect_info[532], cc.p(5, 65), cc.p(0.5, 0.5), false, PlayerAction.action, handler(self, self._onEggAniCallBack))
            self:addChild(self.egg_effect)
            -- 事件帧，此时把金蛋资源隐藏
            local function animationEventFunc( event )
                if event.eventData.name == "appear" then
                    self.egg_icon:setVisible(false)
                end
            end
            self.egg_effect:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)
        elseif self.egg_effect then
        	self.egg_effect:setToSetupPose()
            self.egg_effect:setAnimation(0, PlayerAction.action, false)
        end
    end
end

function SmasheggItem:_onEggAniCallBack(  )
	if self.data and self.data.pos then
		_controller:sender16682(self.data.pos)
	end
end

function SmasheggItem:DeleteMe(  )
	if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
	end
    if self.alert_tips then
        self.alert_tips:close()
        self.alert_tips = nil
    end
	self:handleEffect(false)
	self.egg_icon:stopAllActions()
	self:removeAllChildren()
    self:removeFromParent()
end

---------------- 全服记录 item
SmasheggMainRecordItem = class("SmasheggMainRecordItem", function()
    return ccui.Widget:create()
end)

function SmasheggMainRecordItem:ctor()
	self:configUI()
end

function SmasheggMainRecordItem:configUI(  )
	self.size = cc.size(400, 22)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)
end

function SmasheggMainRecordItem:setData( data )
	if not data then return end
	if not self.record_txt then
		self.record_txt = createRichLabel(20, cc.c3b(232,219,185), cc.p(0.5, 0.5), cc.p(self.size.width/2, self.size.height/2), nil, nil, 400)
		self:addChild(self.record_txt)
	end
    if data.bid then
        local item_cfg = Config.ItemData.data_get_data(data.bid)
        if item_cfg then
            local txt_str = _string_format(TI18N("恭喜 <div fontcolor=5dff38>%s </div>获得 %sX%d"), data.role_name, item_cfg.name, data.num)
            self.record_txt:setString(txt_str)
        end
    end
end

function SmasheggMainRecordItem:DeleteMe(  )
	self:removeAllChildren()
    self:removeFromParent()
end
