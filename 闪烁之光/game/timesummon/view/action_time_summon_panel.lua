--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-02-20 15:15:41
-- @description    : 
		-- 限时召唤（限时活动）
---------------------------------

local _controller = TimesummonController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

ActionTimeSummonPanel = class("ActionTimeSummonPanel", function()
    return ccui.Widget:create()
end)

function ActionTimeSummonPanel:ctor( bid )
	self._can_get_award = false   -- 是否有保底奖励可领取
	self._award_is_over = false   -- 奖励是否已经领完
	self._cur_award_data = {}     -- 当前显示的保底奖励数据
	self._summon_type_1 = 1 	  -- 单抽的抽取类型(1免费 3钻石 4道具)
	self._summon_type_10 = 3 	  -- 十连抽抽取类型(3钻石 4道具)
	self._init_flag = false

	local item_bid_cfg = Config.RecruitHolidayData.data_const["common_s"]
	if item_bid_cfg then
		self.summon_item_bid = item_bid_cfg.val -- 召唤道具bid
	end

	self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("timesummon","timesummon"), type = ResourcesType.plist },
    } 
    self.resources_load = ResourcesLoad.New() 
    self.resources_load:addAllList(self.res_list, function (  )
    	self:loadResListCompleted()
    end)
end

-- 资源加载完成
function ActionTimeSummonPanel:loadResListCompleted(  )
	self:configUI()
	self:register_event()
	_controller:requestTimeSummonData()
	self._init_flag = true
end

function ActionTimeSummonPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_time_summon_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")

    self.image_bg = main_container:getChildByName("image_bg")
    self.progress_txt = main_container:getChildByName("progress_txt")
    self.progress_txt:setTextColor(Config.ColorData.data_color4[1])
    self.progress_txt:enableOutline(Config.ColorData.data_color4[2],2)
    self.item_num_txt = main_container:getChildByName("item_num_txt")
    self.item_num_txt:setTextColor(Config.ColorData.data_color4[1])
    self.item_num_txt:enableOutline(Config.ColorData.data_color4[2],2)
    self.progress = main_container:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    self.progress:setPercent(0)

    self.baodi_bg = main_container:getChildByName("baodi_bg")

    self.award_btn = main_container:getChildByName("award_btn")
    self.award_btn:getChildByName("label"):setString(TI18N("奖励预览"))
    self.preview_btn = main_container:getChildByName("preview_btn")
    self.preview_btn:getChildByName("label"):setString(TI18N("英雄预览"))

    self.summon_btn_1 = main_container:getChildByName("summon_btn_1")
    self.summon_btn_1:getChildByName("label"):setString(TI18N("招募1次"))

    self.summon_btn_10 = main_container:getChildByName("summon_btn_10")
    self.summon_btn_10:getChildByName("label"):setString(TI18N("招募10次"))

    self.time_txt = main_container:getChildByName("time_txt")

    self.award_item = BackPackItem.new(true, true, false, 0.6)
    self.award_item:setPosition(cc.p(60, 728))
    self.award_item:addCallBack(handler(self, self._onClickAwardItem))
    main_container:addChild(self.award_item)
end

-- 点击奖励物品
function ActionTimeSummonPanel:_onClickAwardItem(  )
	if self._can_get_award then
		_controller:requestSummonGetAward()
	elseif self.data then
		_controller:openTimeSummonProgressView(true, self.data.times, self.data.camp_id)
	end
end

-- 刷新保底次数显示
function ActionTimeSummonPanel:updateBaodiCount(  )
	if not self.baodi_bg or not self.data then return end

	if not self.data.item_id or self.data.item_id == 0 then
		self.baodi_bg:setVisible(false)
		return
	end
	self.baodi_bg:setVisible(true)
	if not self.baodi_item then
		self.baodi_item = BackPackItem.new(true, true, false, 0.35)
		self.baodi_item:setDefaultTip()
		self.baodi_item:setPosition(cc.p(20, 22.5))
		self.baodi_bg:addChild(self.baodi_item)
	end
	if not self.cur_show_bid or self.cur_show_bid ~= self.data.item_id then
		self.baodi_item:setBaseData(self.data.item_id, self.data.item_num)
		self.cur_show_bid = self.data.item_id
	end

	local count = self.data.must_count or 0
	if not self.baodi_text then
		self.baodi_text = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(158, 22.5))
		self.baodi_bg:addChild(self.baodi_text)
	end
	self.baodi_text:setString(string.format(TI18N("<div fontcolor=#ffffff outline=2,#000000>剩余</div><div fontcolor=#5fde46 outline=2,#000000>%d</div><div fontcolor=#ffffff outline=2,#000000>次招募内必出</div>"), count))
end

-- 显示背景图
function ActionTimeSummonPanel:updateImageBg(  )
	if self.config and self.config.res_id and (not self.cur_res_id or self.cur_res_id ~= self.config.res_id) then
		local bg_res = PathTool.getPlistImgForDownLoad("bigbg/timesummon", string.format("txt_cn_timesummon_bigbg_%d", self.config.res_id), true)
		self.bg_load = loadImageTextureFromCDN(self.image_bg, bg_res, ResourcesType.single, self.bg_load)
		self.cur_res_id = self.config.res_id
	end
end

-- 刷新按钮显示状态
function ActionTimeSummonPanel:updateSummonBtnStatus(  )
	if self.data and self.config and self.summon_item_bid then
		local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.summon_item_bid)
		-- 单抽
		if not self.summon_txt_1 then
			self.summon_txt_1 = createRichLabel(18, nil, cc.p(0.5, 0.5), cc.p(120.5, 22))
			self.summon_btn_1:addChild(self.summon_txt_1)
		end
		local cur_time = GameNet:getInstance():getTime()
		local txt_str_1 = ""
		if self.data.free_time and self.data.free_time <= cur_time then
			txt_str_1 = TI18N("<div fontcolor=#ffffff>免费召唤</div>")
			self:openSummonFreeTimer(false)
			self._summon_type_1 = 1
		elseif summon_have_num >= 1 then
			local item_config = Config.ItemData.data_get_data(self.summon_item_bid)
			if item_config then
				local res = PathTool.getItemRes(item_config.icon)
				txt_str_1 = string.format(TI18N("<img src='%s' scale=0.4 /><div fontcolor=#ffffff>%d</div>"), res, summon_have_num)
			end
			self:openSummonFreeTimer(false)
			self._summon_type_1 = 4
		elseif self.data.free_time then
			self.left_time = self.data.free_time - cur_time
			txt_str_1 = string.format(TI18N("<div fontcolor=#35ff14>%s</div><div fontcolor=#ffffff>后免费</div>"), TimeTool.GetTimeFormat(self.left_time))
			self:openSummonFreeTimer(true)
			self._summon_type_1 = 3
		end
		self.summon_txt_1:setString(txt_str_1)

		-- 十连抽
		if not self.summon_txt_10 then
			self.summon_txt_10 = createRichLabel(18, nil, cc.p(0.5, 0.5), cc.p(120.5, 22))
			self.summon_btn_10:addChild(self.summon_txt_10)
		end
		local txt_str_10 = ""
		if summon_have_num >= 10 then
			local item_config = Config.ItemData.data_get_data(self.summon_item_bid)
			if item_config then
				local res = PathTool.getItemRes(item_config.icon)
				txt_str_10 = string.format(TI18N("<img src='%s' scale=0.4 /><div fontcolor=#ffffff>%d</div>"), res, summon_have_num)
			end
			self._summon_type_10 = 4
		else
			local bid = self.config.loss_gold_ten[1][1]
			local num = self.config.loss_gold_ten[1][2]
			txt_str_10 = string.format(TI18N("<img src='%s' scale=0.3 /><div fontcolor=#ffffff>%d</div>"), PathTool.getItemRes(bid), num)
			self._summon_type_10 = 3
		end
		self.summon_txt_10:setString(txt_str_10)
	end
end

-- 开启免费倒计时
function ActionTimeSummonPanel:openSummonFreeTimer( status )
	if status == true then
		if self.left_time > 0 and self.summon_txt_1 then
			if not self.summon_timer then
                self.summon_timer = GlobalTimeTicket:getInstance():add(function()
                    if self.data and (self.data.free_time - GameNet:getInstance():getTime()) > 0 then
                        self.left_time = self.data.free_time - GameNet:getInstance():getTime()
                        self.summon_txt_1:setString(string.format(TI18N("<div fontcolor=#35ff14>%s</div><div fontcolor=#ffffff>后免费</div>"), TimeTool.GetTimeFormat(self.left_time)))
                    	self._summon_type_1 = 3
                    else
                        self.summon_txt_1:setString(TI18N("<div fontcolor=#ffffff>免费召唤</div>"))
                        self._summon_type_1 = 1
                        GlobalTimeTicket:getInstance():remove(self.summon_timer)
                        self.summon_timer = nil
                    end
                end, 1)
            end
		else
			if self.summon_timer ~= nil then
	            GlobalTimeTicket:getInstance():remove(self.summon_timer)
	            self.summon_timer = nil
	        end
		end
	else
		if self.summon_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.summon_timer)
            self.summon_timer = nil
        end
	end
end

-- 刷新进度条显示
function ActionTimeSummonPanel:updateProgress(  )
	if self.data and self._cur_award_data and next(self._cur_award_data) ~= nil then
		local reward = self._cur_award_data.reward[1]
		local bid = reward[1]
		local num = reward[2]
		self.award_item:setBaseData(bid, num)

		local percent = self.data.times/self._cur_award_data.times*100
		self.progress:setPercent(percent)

		if self._award_is_over then
			self.progress_txt:setString(TI18N("招募次数 ") .. self.data.times .. "/" .. self._cur_award_data.times)
			self.award_item:setReceivedIcon(true)
		else
			self.progress_txt:setString(TI18N("下一阶段 ") .. self.data.times .. "/" .. self._cur_award_data.times)
			self.award_item:setReceivedIcon(false)
		end

		-- 有奖励可领时显示特效
		if self._can_get_award == true then
			self.award_item:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
		else
			self.award_item:showItemEffect(false)
		end
	end
end

-- 刷新道具数量
function ActionTimeSummonPanel:updateItemNum( bag_code, data_list )
	if self.summon_item_bid then
		if bag_code and data_list then
			if bag_code == BackPackConst.Bag_Code.BACKPACK then
				for i,v in pairs(data_list) do
					if v and v.base_id and self.summon_item_bid == v.base_id then
						local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.summon_item_bid)
						self.item_num_txt:setString(summon_have_num)
						self:updateSummonBtnStatus()
						break
					end
				end
			end
		else
			local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.summon_item_bid)
			self.item_num_txt:setString(summon_have_num)
		end
	end
end

function ActionTimeSummonPanel:register_event(  )
	registerButtonEventListener(self.award_btn, function (  )
		if self.config and self.data then
			_controller:openTimeSummonAwardView(true, self.config.group_id, self.data)
		end
	end, true)

	registerButtonEventListener(self.preview_btn, function (  )
		_controller:send23219(ActionRankCommonType.time_summon)
	end, true)

	-- 召唤1次
	registerButtonEventListener(self.summon_btn_1, function (  )
		local max, count = HeroController:getInstance():getModel():getHeroMaxCount()
        if self:checkHeroBagIsFull() then return end
		if self._summon_type_1 == 3 and self.config then
			local num = self.config.loss_gold_once[1][2]
            local call_back = function ()
                _controller:requestTimeSummon( 1, self._summon_type_1 )
            end
            local item_icon_2 = Config.ItemData.data_get_data(self.config.loss_gold_once[1][1]).icon
            local val_str = Config.ItemData.data_get_data(self.config.gain_once[1][1]).name or ""
            local val_num = self.config.gain_once[1][2]
            local call_num = 1
            self:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
		else
			_controller:requestTimeSummon( 1, self._summon_type_1 )
		end
	end, true)

	-- 召唤10次
	registerButtonEventListener(self.summon_btn_10, function (  )
		if self:checkHeroBagIsFull() then return end
		if self._summon_type_10 == 3 and self.config then
			local num = self.config.loss_gold_ten[1][2]
            local call_back = function ()
                _controller:requestTimeSummon( 10, self._summon_type_10 )
            end
            local item_icon_2 = Config.ItemData.data_get_data(self.config.loss_gold_ten[1][1]).icon
            local val_str = Config.ItemData.data_get_data(self.config.gain_ten[1][1]).name or ""
            local val_num = self.config.gain_ten[1][2]
            local call_num = 10
            self:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
		else
			_controller:requestTimeSummon( 10, self._summon_type_10 )
		end
	end, true)

	-- 召唤数据更新
	if not self.update_summon_data_event then
        self.update_summon_data_event = GlobalEvent:getInstance():Bind(TimesummonEvent.Update_Summon_Data_Event,function (data)
            self:setData(data)
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

-- 检测英雄背包是否已满
function ActionTimeSummonPanel:checkHeroBagIsFull(  )
	local max, count = HeroController:getInstance():getModel():getHeroMaxCount()
	if count >= max then
	    local str = TI18N("英雄列表已满，可通过提升VIP等级或购买增加英雄携带数量，是否前往购买？")
	    local call_back = function()
	        MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.partner)
	        ActionController:getInstance():openActionMainPanel(false)
	    end
	    CommonAlert.show(str, TI18N("前往"), call_back, TI18N("取消"), nil, CommonAlert.type.common)
	    return true
	end
	return false
end

-- 钻石召唤时的提示
function ActionTimeSummonPanel:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
    if self.alert then
        self.alert:close()
        self.alert = nil
    end

    local cancle_callback = function ()
        if self.alert then
            self.alert:close()
            self.alert = nil
        end
    end
    local have_sum = RoleController:getInstance():getRoleVo().gold + RoleController:getInstance():getRoleVo().red_gold
    local str = string.format(TI18N("是否使用<img src=%s visible=true scale=0.5 /><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>(拥有:</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>)\n</div>"),PathTool.getItemRes(item_icon_2),num,have_sum)
    local str_ = str..string.format(TI18N("<div fontColor=#764519>购买</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519></div><div fontColor=#d95014 fontsize= 26>%s</div><div fontColor=#764519>(同时附赠</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>次招募)</div>"),val_num,val_str,call_num)
    if not self.alert then
        self.alert = CommonAlert.show(str_, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
    end
end

function ActionTimeSummonPanel:setData( data )
	if not data then return end

	self.data = data
	local action_cfg = Config.RecruitHolidayData.data_action[self.data.camp_id]
	if action_cfg and action_cfg.group_id then
		self.config = Config.RecruitHolidayData.data_summon[action_cfg.group_id]
	end

	-- 是否有保底奖励可领取
	self._can_get_award = false
	self._award_is_over = false
	self._cur_award_data = {}
	local award_config = Config.RecruitHolidayData.data_award[self.data.camp_id]
	if award_config then
		local temp_data = {} -- 次数达到要求的阶段数据
		for k,v in ipairs(award_config) do
			if v.times and v.times <= self.data.times then
				_table_insert(temp_data, v)
			end
		end
		self.data.reward_list = self.data.reward_list or {}
		if #temp_data > #self.data.reward_list then -- 有可领取的奖励
			self._can_get_award = true
			for i,v in ipairs(temp_data) do
				self._cur_award_data = temp_data[#temp_data]  -- 取最靠后的阶段展示
			end
		elseif next(temp_data) == nil then
			self._cur_award_data = award_config[1]
		else
			local last_data = temp_data[#temp_data]
			local id = last_data.id + 1
			if award_config[id] then
				self._cur_award_data = award_config[id]
			else
				self._award_is_over = true
				self._cur_award_data = award_config[last_data.id]
			end
		end
	end

	-- 活动时间
	self.time_txt:setString(TimeTool.getMD2(self.data.start_time) .. "~" .. TimeTool.getMD2(self.data.end_time))
	
	self:updateImageBg()
	self:updateSummonBtnStatus()
	self:updateProgress()
	self:updateItemNum()
	self:updateBaodiCount()
end

function ActionTimeSummonPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
    if bool == true and self._init_flag == true then
    	_controller:requestTimeSummonData()
    end
end

function ActionTimeSummonPanel:DeleteMe(  )
	if self.bg_load then
		self.bg_load:DeleteMe()
		self.bg_load = nil
	end
	if self.award_item then
		self.award_item:DeleteMe()
		self.award_item = nil
	end
	if self.baodi_item then
		self.baodi_item:DeleteMe()
		self.baodi_item = nil
	end
	if self.resources_load then
		self.resources_load:DeleteMe()
		self.resources_load = nil
	end
	if self.alert then
        self.alert:close()
        self.alert = nil
    end
	if self.update_summon_data_event then
		GlobalEvent:getInstance():UnBind(self.update_summon_data_event)
		self.update_summon_data_event = nil
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
	self:openSummonFreeTimer(false)
end
