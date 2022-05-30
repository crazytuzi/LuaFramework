--------------------------------------------
-- @Author  : xhj
-- @Editor  : xhj
-- @Date    : 2019-12-2 15:15:41
-- @description    : 
		-- 回归抽奖
---------------------------------

local _controller = ReturnActionController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

ReturnActionSummonPanel = class("ReturnActionSummonPanel", function()
    return ccui.Widget:create()
end)

function ReturnActionSummonPanel:ctor( bid )
	self._summon_type_1 = 1 	  -- 单抽的抽取类型(1免费 3钻石 4道具)
	self._summon_type_10 = 3 	  -- 十连抽抽取类型(3钻石 4道具)
	self._init_flag = false
	self.item_list = {}
	local item_bid_cfg = Config.HolidayReturnNewData.data_constant["draw_item_cost"]
	if item_bid_cfg then
		self.summon_item_bid = item_bid_cfg.val[1][1] -- 召唤道具bid
		self.summon_item_num = item_bid_cfg.val[1][2] -- 召唤道具bid
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
function ReturnActionSummonPanel:loadResListCompleted(  )
	self:configUI()
	self:register_event()
	_model:initActionSummonItem()
	_controller:sender27903()
	self._init_flag = true
end

function ReturnActionSummonPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("returnaction/returnaction_summon_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")

    self.image_bg = main_container:getChildByName("image_bg")
    self.item_num_txt = main_container:getChildByName("item_num_txt")
	
	self.item_icon = main_container:getChildByName("item_icon")
	loadSpriteTexture(self.item_icon, PathTool.getItemRes(self.summon_item_bid), LOADTEXT_TYPE)
    self.baodi_bg = main_container:getChildByName("baodi_bg")

    self.award_btn = main_container:getChildByName("award_btn")
    self.award_btn:getChildByName("label"):setString(TI18N("奖励预览"))
    self.preview_btn = main_container:getChildByName("preview_btn")
    self.preview_btn:getChildByName("label"):setString(TI18N("宝可梦预览"))

    self.summon_btn_1 = main_container:getChildByName("summon_btn_1")
    self.summon_btn_1:getChildByName("label"):setString(TI18N("祈愿1次"))

    self.summon_btn_10 = main_container:getChildByName("summon_btn_10")
    self.summon_btn_10:getChildByName("label"):setString(TI18N("祈愿10次"))

	self.time_txt = main_container:getChildByName("time_txt")
	self.time_txt:setString(TI18N("剩余时间："))
	self.time_num = main_container:getChildByName("time_num")
	
	self.cur_num_txt = main_container:getChildByName("cur_num_txt")
	self.cur_num_txt:setString(TI18N("剩余抽数:"))
	self.cur_num = main_container:getChildByName("cur_num")
	self.award_panel = main_container:getChildByName("award_panel")
end

-- 奖励显示
function ReturnActionSummonPanel:updateAward(  )
	if not self.data then return end
	if self.item_list and next(self.item_list or {}) ~= nil then
		for i,v in pairs(self.item_list) do
			if v and not tolua.isnull(v) then
				if v.cur_num_lab == nil then
					local temp_lab = createLabel(24, 1, nil, v:getContentSize().width / 2, 0, '', v:getRoot(), 0, cc.p(0.5, 1)) 
					v.cur_num_lab = temp_lab
				end
				
				local item_data = v:getData()
				if item_data then
					local count , sum = _model:getActionSummonItemNumById(item_data.id)
					if count and sum then
						if sum-count<=0 then
							if v.setReceivedIcon then
								v:setReceivedIcon(true)	
							end
							if v.showItemEffect then
								v:showItemEffect(false)
							end
						else
							if v.setReceivedIcon then
								v:setReceivedIcon(false)	
							end
							if v.showItemEffect then
								v:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
							end
						end
						v.cur_num_lab:setString(string.format( "%d/%d",sum-count,sum))	
					end	
				end
			end
		end
	else
		local period = _model:getActionPeriod()
		local config = Config.HolidayReturnNewData.data_summon[period]
		if config then
			local temp_award = {}
			for i,v in pairs(config) do
				if v.show == 1 then
					if temp_award[v.type_id] == nil then
						temp_award[v.type_id] = {v.rewards[1][1], v.rewards[1][2],v.sort}
					end
				end
			end

			local show_award = {}
			for i,v in pairs(temp_award) do
				_table_insert(show_award, {v[1], v[2],sort = v[3]})
			end
			table.sort(show_award, SortTools.KeyLowerSorter("sort"))

			local setting = {}
			setting.scale = 0.8
			setting.max_count = 4
			setting.is_center = true
			setting.space_x = 20
			-- setting.show_effect_id = 263
			self.item_list = commonShowSingleRowItemList(self.award_panel, self.item_list, show_award, setting)
			delayRun(self.award_panel, 0.1, function ()
                for i,v in pairs(self.item_list) do
					if v and not tolua.isnull(v) then
						if v.cur_num_lab == nil then
							local temp_lab = createLabel(24, 1, 2, v:getRoot():getContentSize().width / 2, 0, '', v:getRoot(), 2, cc.p(0.5, 1)) 
							v.cur_num_lab = temp_lab
						end
						local item_data = v:getData()
						if item_data then
							local count , sum = _model:getActionSummonItemNumById(item_data.id)
							if count and sum then
								if sum-count<=0 then
									if v.setReceivedIcon then
										v:setReceivedIcon(true)	
									end
									if v.showItemEffect then
										v:showItemEffect(false)
									end
								else
									if v.setReceivedIcon then
										v:setReceivedIcon(false)	
									end
									if v.showItemEffect then
										v:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
									end
								end
								v.cur_num_lab:setString(string.format( "%d/%d",sum-count,sum))	
							end
						end
					end
				end
			end)
		end
	end
end

-- 剩余次数显示
function ReturnActionSummonPanel:updateBaodiCount(  )
	if not self.data then return end

	local draw_time = self.data.draw_time or 0
	local limit_draw_time = self.data.limit_draw_time or 0
	self.cur_num:setString(string.format( "%d/%d",limit_draw_time-draw_time,limit_draw_time))
end

-- 显示背景图
function ReturnActionSummonPanel:updateImageBg(  )
	local period = _model:getActionPeriod()
	if period and (not self.cur_res_id or self.cur_res_id ~= period) then
		local bg_res = PathTool.getPlistImgForDownLoad("bigbg/returnaction", string.format("txt_cn_return_summon_%d", period))
		self.bg_load = loadImageTextureFromCDN(self.image_bg, bg_res, ResourcesType.single, self.bg_load)
		self.cur_res_id = period
	end
end

-- 刷新按钮显示状态
function ReturnActionSummonPanel:updateSummonBtnStatus(  )
	if self.data and self.summon_item_bid then
		local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.summon_item_bid)
		-- 单抽
		if not self.summon_txt_1 then
			self.summon_txt_1 = createRichLabel(18, nil, cc.p(0.5, 0.5), cc.p(120.5, 22))
			self.summon_btn_1:addChild(self.summon_txt_1)
		end
		local cur_time = GameNet:getInstance():getTime()
		local txt_str_1 = ""
		if self.data.free_time and self.data.free_time == 1 then -- 是否有免费次数（0：否，1：是）
			txt_str_1 = TI18N("<div fontcolor=#ffffff>免费</div>")
			self._summon_type_1 = 1
		elseif summon_have_num >= self.summon_item_num then
			local item_config = Config.ItemData.data_get_data(self.summon_item_bid)
			if item_config then
				local res = PathTool.getItemRes(item_config.icon)
				txt_str_1 = string.format(TI18N("<img src='%s' scale=0.4 /><div fontcolor=#ffffff>%d</div>"), res, self.summon_item_num)
			end
			self._summon_type_1 = 4
		else
			local item_config = Config.ItemData.data_get_data(self.summon_item_bid)
			if item_config then
				local res = PathTool.getItemRes(item_config.icon)
				txt_str_1 = string.format(TI18N("<img src='%s' scale=0.4 /><div fontcolor=#ffffff>%d</div>"), res, self.summon_item_num)
			end
			self._summon_type_1 = 3
		end
		self.summon_txt_1:setString(txt_str_1)

		-- 十连抽
		if not self.summon_txt_10 then
			self.summon_txt_10 = createRichLabel(18, nil, cc.p(0.5, 0.5), cc.p(120.5, 22))
			self.summon_btn_10:addChild(self.summon_txt_10)
		end
		local txt_str_10 = ""
		local item_config = Config.ItemData.data_get_data(self.summon_item_bid)
		if item_config then
			local res = PathTool.getItemRes(item_config.icon)
			txt_str_10 = string.format(TI18N("<img src='%s' scale=0.4 /><div fontcolor=#ffffff>%d</div>"), res, 10*self.summon_item_num)
		end
		if summon_have_num >= 10*self.summon_item_num then
			self._summon_type_10 = 4
		else
			self._summon_type_10 = 3
		end
		self.summon_txt_10:setString(txt_str_10)
	end
end


-- 刷新道具数量
function ReturnActionSummonPanel:updateItemNum( bag_code, data_list )
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

function ReturnActionSummonPanel:register_event(  )
	registerButtonEventListener(self.award_btn, function (  )
		local period = _model:getActionPeriod()
		if period and self.data then
			_controller:openReturnActionSummonAwardView(true, period, self.data)
		end
	end, true)

	registerButtonEventListener(self.preview_btn, function (  )
		TimesummonController:getInstance():send23219(BattlePreviewParm.ReturnActionSummon)
	end, true)

	-- 召唤1次
	registerButtonEventListener(self.summon_btn_1, function (  )
		local max, count = HeroController:getInstance():getModel():getHeroMaxCount()
		local draw_item_value = Config.HolidayReturnNewData.data_constant["draw_item_value"]
		if self._summon_type_1 == 3 and draw_item_value then
			local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.summon_item_bid)
            local call_back = function ()
                _controller:sender27904( 2 )
			end
			local item_icon_1 = Config.ItemData.data_get_data(self.summon_item_bid).icon
            local item_icon_2 = Config.ItemData.data_get_data(draw_item_value.val[1][1]).icon
            local val_num_1 = self.summon_item_num
            local val_num_2 = val_num_1 * draw_item_value.val[1][2]
			self:showAlert(item_icon_1,item_icon_2,val_num_1,val_num_2,call_back)
		else
			local type = 1
			if self._summon_type_1 == 4 then
				type = 2
			end
			_controller:sender27904( type )
		end
	end, true)

	-- 召唤10次
	registerButtonEventListener(self.summon_btn_10, function (  )
		local draw_item_value = Config.HolidayReturnNewData.data_constant["draw_item_value"]
		if self._summon_type_10 == 3 and draw_item_value then
			local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.summon_item_bid)
            local call_back = function ()
                _controller:sender27904( 3 )
            end
			local item_icon_1 = Config.ItemData.data_get_data(self.summon_item_bid).icon
			local item_icon_2 = Config.ItemData.data_get_data(draw_item_value.val[1][1]).icon
			local val_num_1 = 10*self.summon_item_num - summon_have_num
			local val_num_2 = val_num_1*draw_item_value.val[1][2]
            self:showAlert(item_icon_1,item_icon_2,val_num_1,val_num_2,call_back)
		else
			_controller:sender27904( 3 )
		end
	end, true)

	-- 召唤数据更新
	if not self.update_summon_data_event then
        self.update_summon_data_event = GlobalEvent:getInstance():Bind(ReturnActionEvent.Summon_Data_Event,function ()
            self:setData()
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


-- 钻石召唤时的提示
function ReturnActionSummonPanel:showAlert(item_icon_1,item_icon_2,val_num_1,val_num_2,call_back)
    if self.alert then
        self.alert:close()
        self.alert = nil
    end

    local have_sum = RoleController:getInstance():getRoleVo().gold + RoleController:getInstance():getRoleVo().red_gold
	local str = string.format(TI18N("祈愿还差<img src=%s visible=true scale=0.35 /> *%d个，是否消耗 <img src=%s visible=true scale=0.35 /><div fontColor=#289b14 fontsize=26> *%d</div> 补足并进行祈愿"),PathTool.getItemRes(item_icon_1),val_num_1, PathTool.getItemRes(item_icon_2),val_num_2)
    if not self.alert then
        self.alert = CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
    end
end

function ReturnActionSummonPanel:setData( )
	local data = _model:getActionSummonData()
	if not data then return end

	self.data = data
	
	-- 活动时间
	setCountDownTime(self.time_num,self.data.endtime - GameNet:getInstance():getTime())
	
	self:updateImageBg()
	self:updateSummonBtnStatus()
	self:updateItemNum()
	self:updateBaodiCount()
	self:updateAward()
end

function ReturnActionSummonPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
    if bool == true and self._init_flag == true then
    	_controller:sender27903()
    end
end

function ReturnActionSummonPanel:DeleteMe(  )
	doStopAllActions(self.award_panel)
	doStopAllActions(self.time_num)
	if self.bg_load then
		self.bg_load:DeleteMe()
		self.bg_load = nil
	end

	if self.resources_load then
		self.resources_load:DeleteMe()
		self.resources_load = nil
	end

	if self.item_list ~= nil then
		for k, v in pairs(self.item_list) do
			if v.DeleteMe then
				v:DeleteMe()	
			end
        end
    end
	self.item_list = nil
	
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
	
end
