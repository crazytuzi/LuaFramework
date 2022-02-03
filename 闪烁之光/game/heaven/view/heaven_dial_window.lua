--------------------------------------------
-- @Author  : htp
-- @Editor  : xhj
-- @Date    : 2019-04-25 14:43:31
-- @description    : 
		-- 神装转盘
---------------------------------
local _controller = HeavenController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

HeavenDialWindow = class("HeavenDialWindow", function()
    return ccui.Widget:create()
end)

function HeavenDialWindow:ctor(group_id)
	self.cur_group_id = group_id or self:getDefaultGroupId()
	
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("heavendial", "heavendial"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("heaven", "heaven"), type = ResourcesType.plist},
	}

	self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(self.res_list, function()
        if self.loadResListCompleted then
            self:loadResListCompleted()
        end
    end)
	self.award_item_list = {}  -- 奖励item列表
	self.arriveLuckly_label = {}
	self.stage_data = {}
	self.backpackitem_list = {}
	self.rotate_ani_state = false
	self.cur_stage_index = 1 -- 当前选中的item标识
	self.is_show_dial_ani = false -- 当前是否正在播放祈祷特效
	self.is_first_open = true
	self:configUI()
    self:register_event()
end


function HeavenDialWindow:loadResListCompleted()
    -- self:configUI()
    -- self:register_event()
end

function HeavenDialWindow:addToParent( status )
	status = status or false
	self:setVisible(status)
	if self.is_first_open then
		self:setData()
		self.is_first_open = false
		_controller:sender25232()
  	end
end

function HeavenDialWindow:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("heaven/heaven_dial_window"))
	self.root_wnd:setPosition(0,0)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
	self:setAnchorPoint(0,0)


	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container

	self.pos_light = main_container:getChildByName("pos_light")

	self.close_btn = main_container:getChildByName("close_btn")
	self.arrow_right = main_container:getChildByName("arrow_right")
	self.arrow_left = main_container:getChildByName("arrow_left")
	local top_panel = main_container:getChildByName("top_panel")
	local bottom_panel = main_container:getChildByName("bottom_panel")
	self.tips_label = bottom_panel:getChildByName("tips_label")
	self.tips_label:setString("")
	self.extract_btn_1 = bottom_panel:getChildByName("extract_btn_1")
	self.extract_btn_1:setName("guide_extract_btn_1")
	self.extract_btn_1:getChildByName("label"):setString(TI18N("祈祷1次"))
	self.free_label = bottom_panel:getChildByName("free_label")
	self.free_label:setString(TI18N("本次免费"))
	self.cost_bg_1 = bottom_panel:getChildByName("cost_bg_1")
	self.cost_bg_1_lab = self.cost_bg_1:getChildByName("label")
	self.cost_bg_1_lab:setString(TI18N("消耗:"))
	self.cost_icon_1 = self.cost_bg_1:getChildByName("cost_icon")
	self.cost_label_1 = self.cost_bg_1:getChildByName("cost_label")

	self.extract_btn_10 = bottom_panel:getChildByName("extract_btn_10")
	self.extract_btn_10:getChildByName("label"):setString(TI18N("祈祷10次"))
	self.sp_discount = bottom_panel:getChildByName("sp_discount")
	self.sp_discount:setVisible(false)
	self.sp_discount:getChildByName("Text_1"):setString(TI18N("钻石9折"))
	local cost_bg_10 = bottom_panel:getChildByName("cost_bg_10")
	cost_bg_10:getChildByName("label"):setString(TI18N("消耗:"))
	self.cost_icon_10 = cost_bg_10:getChildByName("cost_icon")
	self.cost_label_10 = cost_bg_10:getChildByName("cost_label")

	self.stage_layer = main_container:getChildByName("stage_layer")
	self.stage_layer:setClippingEnabled(true)

	self.progress_panel = bottom_panel:getChildByName("progress_panel")
	self.progress = self.progress_panel:getChildByName("progress")
	self.progress:setScale9Enabled(true)
	self.num_label = self.progress_panel:getChildByName("num_label")
	self.num_label:setString(TI18N("累计次数"))
	self.cur_num = self.progress_panel:getChildByName("cur_num")
	self.cur_num:setString("")
	
	self.tips_btn = top_panel:getChildByName("tips_btn")
	self.tips_btn:getChildByName("label"):setString(TI18N("概率"))
	self.btn_shop = top_panel:getChildByName("btn_shop")
	self.btn_shop:getChildByName("label"):setString(TI18N("神装商店"))
	

	self.btn_rule = top_panel:getChildByName("btn_rule")

	self.score_bg = top_panel:getChildByName("score_bg")
	self.score_title = self.score_bg:getChildByName("score_title")
	self.score_title:setString(TI18N("最高总评分："))
	self.all_score = createLabel(24,cc.c3b(0xf4,0xee,0xd3),cc.c3b(0x00,0x00,0x00),9.41,18,"",self.score_bg,2, cc.p(0,0.5))
	self:handlerLinghtEffect(true)
	
	self.baodi_count_bg = bottom_panel:getChildByName("baodi_count_bg")
	self.baodi_count_tips = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(105, 17))
	self.baodi_count_bg:addChild(self.baodi_count_tips)

	self.item_num_txt = bottom_panel:getChildByName("item_num_txt")
    self.item_num_txt:setTextColor(Config.ColorData.data_color4[1])
	self.item_num_txt:enableOutline(Config.ColorData.data_color4[2],2)
	self.item_icon = bottom_panel:getChildByName("item_icon")
	
	self.add_btn = bottom_panel:getChildByName("add_btn")

	-- 适配
	local top_off = display.getTop(main_container)
	local bottom_off = display.getBottom(main_container)
	top_panel:setPositionY(top_off - 178)
	bottom_panel:setPositionY(bottom_off+190)
end

function HeavenDialWindow:register_event(  )

	registerButtonEventListener(self.add_btn, function (  )
		if self.cur_cost_bid then
			BackpackController:getInstance():openTipsSource(true, self.cur_cost_bid)
		end
	end, true)

	-- 规则说明
	registerButtonEventListener(self.btn_rule, function ( param, sender, event_type )
		local pray_rule = Config.HolyEqmLotteryData.data_const["pray_rule"]
		if pray_rule then
			TipsManager:getInstance():showCommonTips(pray_rule.desc, sender:getTouchBeganPosition())
		end
	end, true)

	-- 概率说明
	registerButtonEventListener(self.tips_btn, function ( param, sender, event_type )
		if self.cur_group_cfg then
			TipsManager:getInstance():showCommonTips(self.cur_group_cfg.desc, sender:getTouchBeganPosition())
		end
	end, true)

	-- 商店
	registerButtonEventListener(self.btn_shop, function (  )
		SuitShopController:getInstance():openSuitShopMainView(true)
	end, true)


	-- 向左
	registerButtonEventListener(self.arrow_left, function (  )
		if self.is_show_dial_ani then return end
		self:showItemRotateAni(2)
	end, true)

	-- 向右
	registerButtonEventListener(self.arrow_right, function (  )
		if self.is_show_dial_ani then return end
		self:showItemRotateAni(1)
	end, true)


	-- 祈祷1次
	registerButtonEventListener(self.extract_btn_1, function (  )
		if self.is_show_dial_ani then return end
		self:onClickExtractBtn(1)
	end, true)

	-- 祈祷10次
	registerButtonEventListener(self.extract_btn_10, function (  )
		if self.is_show_dial_ani then return end
		self:onClickExtractBtn(10)
	end, true)

	-- 滑动层
	self.stage_layer:addTouchEventListener(function ( sender, event_type )
		if event_type == ccui.TouchEventType.began then
            self.touch_began = sender:getTouchBeganPosition()
        elseif event_type == ccui.TouchEventType.ended then
            self.touch_end = sender:getTouchEndPosition()
            local is_touch = true
            if self.touch_began ~= nil then
                is_touch = math.abs(self.touch_end.x - self.touch_began.x) >= 15
            end
            if is_touch == true and not self.is_show_dial_ani then
                playButtonSound2()
                if self.touch_end.x > self.touch_began.x then
                	self:showItemRotateAni(2)
            	else
            		self:showItemRotateAni(1)
            	end
            end
        end
	end)

	--基础数据（免费次数、保底次数）
	if not self.update_dial_base_data  then
		self.update_dial_base_data = GlobalEvent:getInstance():Bind(HeavenEvent.Update_Dial_Base_Data,function ()
			self:updateDialCostInfo()
			self:updateBaodiCount()
			if self.cur_stage_index == 1 and self.stage_item_1 then
				self.stage_item_1:updateHolyItem()
			elseif self.cur_stage_index == 2 and self.stage_item_2 then
				self.stage_item_2:updateHolyItem()
			end
		end)
	end

	--红点数据
	if not self.update_heaven_red_status  then
		self.update_heaven_red_status = GlobalEvent:getInstance():Bind(HeavenEvent.Update_Heaven_Red_Status,function (bid)
			if bid == HeavenConst.Red_Index.Dial then
				self:updateArrowBtnStatus()
			end
		end)
	end

	--道具数量变化
	if not self.add_goods_event  then
		self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS,function (bag_code, data_list)
			self:updateItemNum(bag_code, data_list)
		end)
	end

	if not self.delete_goods_event  then
		self.delete_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS,function (bag_code, data_list)
			self:updateItemNum(bag_code, data_list)
		end)
	end


	if not self.modify_goods_event  then
		self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function (bag_code, data_list)
			self:updateItemNum(bag_code, data_list)
		end)
	end

	if not self.update_all_score  then
		self.update_all_score = GlobalEvent:getInstance():Bind(HeavenEvent.Update_All_Score,function ()
			if self.all_score and _model then
				local Score = _model:getAllScore()
				if Score then
					self.all_score:setString(tostring(Score))
				end
			end
		end)
	end
end


-- 详情
function HeavenDialWindow:onClickDetailBtn( param, sender, event_type )
	if self.cur_group_cfg then
		TipsManager:getInstance():showCommonTips(self.cur_group_cfg.desc, sender:getTouchBeganPosition())
	end
end

-- 祈祷
function HeavenDialWindow:onClickExtractBtn( times )
	if not self.cur_group_id then return end
	if times == 1 and self.dial_way_1 then
		local recruit_type
		if self.dial_way_1 == HeavenConst.Dial_Way.Free then
			recruit_type = 1
		elseif self.dial_way_1 == HeavenConst.Dial_Way.Item then
			recruit_type = 4
		elseif self.dial_way_1 == HeavenConst.Dial_Way.Gold then
			recruit_type = 3
		end
		if recruit_type then
			if recruit_type == 3 then
				local dialy_data = _model:getHeavenDialById(self.cur_group_id)
				if dialy_data and self.cur_group_cfg and dialy_data.day_count >= self.cur_group_cfg.day_limit_count then
					message(TI18N("今日钻石祈祷次数已达上限"))
					return
				end
				if self.cur_group_cfg and self.cur_group_cfg.gain_once and self.cur_group_cfg.gain_once[1] then
					local gain_item_bid = self.cur_group_cfg.gain_once[1][1]
					local gain_item_num = self.cur_group_cfg.gain_once[1][2]
					local item_cfg = Config.ItemData.data_get_data(gain_item_bid)
					if item_cfg and gain_item_bid and gain_item_num then
						local role_vo = RoleController:getInstance():getRoleVo()
				        local tips_str = string.format(TI18N("是否使用<img src=%s visible=true scale=0.4 /><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>(拥有:</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>)祈祷<div fontColor=#289b14 fontsize= 26>1</div>次\n</div>"),PathTool.getItemRes(3), self.cur_group_cfg.loss_gold_once, role_vo.gold)
				        tips_str = tips_str .. string.format(TI18N("祈祷后可获得<div fontColor=#289b14 fontsize= 26>%d</div><div fontColor=#d95014 fontsize= 26>%s</div><div fontColor=#764519>(同时附赠</div><div fontColor=#289b14 fontsize= 26>1</div>次随机奖励)</div>"), gain_item_num, item_cfg.name)
				        CommonAlert.show(tips_str, TI18N("确定"), function (  )
				        	self.dial_times = 1
							self.dial_recruit_type = recruit_type
							self:handleDialEffect(true)
				        end, TI18N("取消"), nil, CommonAlert.type.rich)
					end
				end
			else
				self.dial_times = 1
				self.dial_recruit_type = recruit_type
				self:handleDialEffect(true)
			end
		end
	elseif self.dial_way_10 then
		if self.dial_way_10 == HeavenConst.Dial_Way.Item then
			recruit_type = 4
		elseif self.dial_way_10 == HeavenConst.Dial_Way.Gold then
			recruit_type = 3
		end
		if recruit_type then
			if recruit_type == 3 then
				local dialy_data = _model:getHeavenDialById(self.cur_group_id)
				if dialy_data and self.cur_group_cfg and dialy_data.day_count+10 > self.cur_group_cfg.day_limit_count then
					message(TI18N("今日钻石祈祷次数已达上限"))
					return
				end
				if self.cur_group_cfg and self.cur_group_cfg.gain_once and self.cur_group_cfg.gain_once[1] then
					local gain_item_bid = self.cur_group_cfg.gain_once[1][1]
					local gain_item_num = self.cur_group_cfg.gain_once[1][2]
					local item_cfg = Config.ItemData.data_get_data(gain_item_bid)
					if item_cfg and gain_item_bid and gain_item_num then
						local role_vo = RoleController:getInstance():getRoleVo()
				        local tips_str = string.format(TI18N("是否使用<img src=%s visible=true scale=0.4 /><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>(拥有:</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>)祈祷<div fontColor=#289b14 fontsize= 26>10</div>次\n</div>"),PathTool.getItemRes(3), self.cur_group_cfg.loss_gold_ten, role_vo.gold)
				        tips_str = tips_str .. string.format(TI18N("祈祷后可获得<div fontColor=#289b14 fontsize= 26>%d</div><div fontColor=#d95014 fontsize= 26>%s</div><div fontColor=#764519>(同时附赠</div><div fontColor=#289b14 fontsize= 26>10</div>次随机奖励)</div>"), gain_item_num*10, item_cfg.name)
				        CommonAlert.show(tips_str, TI18N("确定"), function (  )
				        	self.dial_times = 10
							self.dial_recruit_type = recruit_type
							self:handleDialEffect(true)
				        end, TI18N("取消"), nil, CommonAlert.type.rich)
					end
				end
			else
				self.dial_times = 10
				self.dial_recruit_type = recruit_type
				self:handleDialEffect(true)
			end
		end
	end
end


-- 刷新进度条显示
function HeavenDialWindow:updateProgress(  )
	local dialy_data = _model:getHeavenDialById(self.cur_group_id)
	if not dialy_data then return end

	if self.cur_group_cfg then
		self.tips_label:setString(_string_format(TI18N("今日钻石召唤次数上限：%d/%d"),dialy_data.day_count,self.cur_group_cfg.day_limit_count))
	end

	local award_config = Config.HolyEqmLotteryData.data_award[self.cur_group_id]
	local start_y = 80
	local distance_y = 425
	local list = {108,108,108,110,110,110}
	if award_config then
		local offset_y = (distance_y - start_y + 0)/(#award_config-1)
		for i,v in ipairs(award_config) do
			local item = self.award_item_list[i]
			local pos_y = start_y + (i-1)*offset_y
			if item == nil then
				item = ccui.Layout:create()
				item:setContentSize(cc.size(50,50))
				item:setAnchorPoint(cc.p(0.5,0.5))
				item:setPosition(cc.p(pos_y, 16.5))
				self.progress_panel:addChild(item)
				item:setTouchEnabled(true)
				self.award_item_list[i] = item
				
				local res_id = PathTool.getEffectRes(list[i])
				
				local effect =  createEffectSpine(res_id, cc.p(25, 0), cc.p(0.5, 0.5), true, PlayerAction.action_1)
				item.effect = effect
           		item:addChild(effect)
			end

			registerButtonEventListener(item, function(param,sender, event_type)
				local dialy_data = _model:getHeavenDialById(self.cur_group_id)
				if dialy_data then
					local _bool = false
					local _un_enabled = false
					for k,m in pairs(dialy_data.do_awards) do
						if v.id == m.award_id then
							_un_enabled = true
							break
						end
					end

					if _un_enabled == false and v.times <= dialy_data.all_award_count then
						_bool = true
					end		
					if _bool == true then
						_controller:sender25231(self.cur_group_id,v.id)
						return
					end
				end					
				
				self:showRewardItems(v.reward,sender:getTouchBeganPosition(), i)
			end,false, 1)

			if not self.arriveLuckly_label[i] and self.award_item_list[i] then
				self.arriveLuckly_label[i] = createLabel(22,cc.c3b(0xf4,0xee,0xd3),cc.c3b(0x00,0x00,0x00),pos_y,-10,"",self.progress_panel,2, cc.p(0.5,1))
			end
			if self.arriveLuckly_label[i] then
				self.arriveLuckly_label[i]:setString(v.times)
			end
		end

		-- 计算进度条
		local last_times = 0
		local progress_width = 425
		local first_off = start_y-0 -- 0到第一个的距离
		local distance = 0
		for i,v in ipairs(award_config) do
			if i == 1 then
				if dialy_data.all_award_count <= v.times then
					distance = (dialy_data.all_award_count/v.times)*first_off
					break
				else
					distance = first_off
				end
			else
				if dialy_data.all_award_count <= v.times then
					distance = distance + ((dialy_data.all_award_count-last_times)/(v.times-last_times))*offset_y
					break
				else
					distance = distance + offset_y
				end
			end
			last_times = v.times
		end
		self.progress:setPercent(distance/progress_width*100)

		self.cur_num:setString(tostring(dialy_data.all_award_count))
	end
	
	self:updateAwardStatus()
end

function HeavenDialWindow:updateAwardStatus()
	local dialy_data = _model:getHeavenDialById(self.cur_group_id)
	if not dialy_data then return end

	local award_config = Config.HolyEqmLotteryData.data_award[self.cur_group_id]
	if award_config then
		for i,v in pairs(award_config) do
			local _bool = false
			local _un_enabled = false
			for k,m in pairs(dialy_data.do_awards) do
				if v.id == m.award_id then
					_un_enabled = true
					break
				end
			end

			if _un_enabled == false and v.times <= dialy_data.all_award_count then
				_bool = true
			end		
			
			local action = PlayerAction.action_1
			if _bool == true then
				action = PlayerAction.action_2
			end
			if _un_enabled == true then
				action = PlayerAction.action_3
			end
			if self.award_item_list[i] and self.award_item_list[i].effect then
				self.award_item_list[i].effect:setToSetupPose()
				self.award_item_list[i].effect:setAnimation(0, action, true)
			end
		end
	end
end

function HeavenDialWindow:showRewardItems(data, pos, touch_pos)
    local size = self.root_wnd:getContentSize()
    if not self.tips_layer then
        self.tips_layer = ccui.Layout:create()
        self.tips_layer:setContentSize(size)
        self.root_wnd:addChild(self.tips_layer)
        self.tips_layer:setTouchEnabled(true)
        registerButtonEventListener(self.tips_layer, function()
            self.tips_bg:removeFromParent()
            self.tips_bg = nil
            self.tips_layer:removeFromParent()
            self.tips_layer = nil
        end,false, 1)
    end
    
    local list = {}
    if not self.tips_bg then
        self.tips_bg = createImage(self.tips_layer, PathTool.getResFrame("common","common_1056"), size.width*0.5, 100, cc.p(0,0), true, 10, true)
        self.tips_bg:setTouchEnabled(true)
    end
    if self.tips_bg then
        self.tips_bg:setContentSize(cc.size(BackPackItem.Width*#data+50,BackPackItem.Height+50))
        local ccp = cc.p(0.5,0)
        if self.tips_bg:getContentSize().width + pos.x >= 720 then
            ccp = cc.p(1,0)
        end
		self.tips_bg:setAnchorPoint(ccp)
		local world_pos = self.award_item_list[touch_pos]:convertToWorldSpace(cc.p(0,50))    
		local cur_pos = self.root_wnd:convertToNodeSpace(world_pos) 
        self.tips_bg:setPosition(cur_pos)
    end
	
    for i,v in pairs(data) do
        if not list[i] then
            list[i] = BackPackItem.new(nil,true,nil,0.8)
            list[i]:setAnchorPoint(cc.p(0,0.5))
            self.tips_bg:addChild(list[i])
            list[i]:setBaseData(v[1])
            list[i]:setPosition(cc.p(BackPackItem.Width*(i-1)+30, 100))
            list[i]:setDefaultTip()
            self.backpackitem_list[i] = list[i]
            self.text_num = createLabel(22,cc.c4b(0xff,0xee,0xdd,0xff),nil,60,-25,"",list[i],nil, cc.p(0.5,0.5))
            self.text_num:setString("x"..v[2])
        else
            list[i]:setBaseData(v[1])
            list[i]:setPosition(cc.p(BackPackItem.Width*(i-1)+30, 100))
            self.text_num:setString("x"..v[2])
        end
    end
end

-- 更新保底次数显示
function HeavenDialWindow:updateBaodiCount(  )
	if not self.cur_group_id then return end
	local count = _model:getHeavenDialBaodiCountById(self.cur_group_id)
	self.baodi_count_tips:setString(_string_format(TI18N("再抽<div fontcolor=#68C74B>%d</div>次必出<div fontcolor=#FF5D5D>良品</div>以上"), count))
end

-- 获取默认的组id
function HeavenDialWindow:getDefaultGroupId(  )
	local default_id = 0
	for k,v in pairs(Config.HolyEqmLotteryData.data_group) do
		if (not v.open_cond or v.open_cond == 0 or _model:checkHeavenDialIsOpenByGId(v.group_id)) and v.group_id > default_id then
			default_id = v.group_id
		end
	end
	
	return default_id
end


function HeavenDialWindow:setData(  )
	if not self.cur_group_id then return end
	self.cur_group_cfg = Config.HolyEqmLotteryData.data_group[self.cur_group_id]
	if not self.cur_group_cfg then return end
	
	-- 记录消耗的道具id
	if self.cur_group_cfg.loss_item_once and self.cur_group_cfg.loss_item_once[1] then
		self.cur_cost_bid = self.cur_group_cfg.loss_item_once[1][1]
	end

	local Score = _model:getAllScore()
	if Score then
		self.all_score:setString(tostring(Score))
	end
	
	-- 石像
	self:createStageItem()
	self:updateArrowBtnStatus()
	self:updateDialCostInfo()

	-- 保底次数
	self:updateBaodiCount()
end

-- 道具数量刷新
function HeavenDialWindow:updateItemNum( bag_code, data_list )
	if self.cur_cost_bid and bag_code and data_list then
        if bag_code == BackPackConst.Bag_Code.BACKPACK then
            for i,v in pairs(data_list) do
                if v and v.base_id and self.cur_cost_bid == v.base_id then
                    self:updateDialCostInfo()
                    break
                end
            end
        end
    end
end

-- 刷新消耗显示
function HeavenDialWindow:updateDialCostInfo(  )
	local item_cfg = Config.ItemData.data_get_data(self.cur_cost_bid)
	if not item_cfg or not self.cur_group_cfg then return end

	local item_res = PathTool.getItemRes(item_cfg.icon)
	loadSpriteTexture(self.cost_icon_10, item_res, LOADTEXT_TYPE)

	loadSpriteTexture(self.item_icon, PathTool.getItemRes(item_cfg.icon), LOADTEXT_TYPE)
	
	local have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.cur_cost_bid)
	self.item_num_txt:setString(have_num)

	-- 单抽
	local is_free = _model:getHeavenDialIsFreeById(self.cur_group_id)
	if is_free then
		self.cost_bg_1_lab:setVisible(false)
		self.cost_icon_1:setVisible(false)
		self.cost_label_1:setVisible(false)
		self.free_label:setVisible(true)
		self.dial_way_1 = HeavenConst.Dial_Way.Free
	elseif have_num >= 1 then
		self.cost_bg_1_lab:setVisible(true)
		self.cost_icon_1:setVisible(true)
		self.cost_label_1:setVisible(true)
		self.free_label:setVisible(false)
		self.cost_label_1:setString("1")
		loadSpriteTexture(self.cost_icon_1, item_res, LOADTEXT_TYPE)
		self.cost_icon_1:setScale(0.4)
		self.dial_way_1 = HeavenConst.Dial_Way.Item
	else
		self.cost_bg_1_lab:setVisible(true)
		self.cost_icon_1:setVisible(true)
		self.cost_label_1:setVisible(true)
		self.free_label:setVisible(false)

		-- 消耗的钻石数量
		local gold_num = self.cur_group_cfg.loss_gold_once or 0
		self.cost_label_1:setString(gold_num)
		loadSpriteTexture(self.cost_icon_1, PathTool.getItemRes(3), LOADTEXT_TYPE)
		self.cost_icon_1:setScale(0.3)
		self.dial_way_1 = HeavenConst.Dial_Way.Gold
	end

	-- 十连抽
	if have_num >= 10 then
		self.cost_label_10:setString("10")
		loadSpriteTexture(self.cost_icon_10, item_res, LOADTEXT_TYPE)
		self.cost_icon_10:setScale(0.4)
		self.sp_discount:setVisible(false)
		self.dial_way_10 = HeavenConst.Dial_Way.Item
	else
		-- 消耗的钻石数量
		local gold_num = self.cur_group_cfg.loss_gold_ten or 0
		self.cost_label_10:setString(gold_num)
		loadSpriteTexture(self.cost_icon_10, PathTool.getItemRes(3), LOADTEXT_TYPE)
		self.cost_icon_10:setScale(0.3)
		self.dial_way_10 = HeavenConst.Dial_Way.Gold

		-- 折扣
		if self.cur_group_cfg.discount_res and self.cur_group_cfg.discount_res ~= "" then
			self.sp_discount:setVisible(true)
			loadSpriteTexture(self.sp_discount, PathTool.getResFrame("heavendial", self.cur_group_cfg.discount_res), LOADTEXT_TYPE_PLIST)
		else
			self.sp_discount:setVisible(false)
		end
	end

	self:updateProgress()
end

function HeavenDialWindow:createStageItem(  )
	if self.stage_item_1 or not self.cur_group_cfg then return end

	self.stage_item_1 = HeavenDialItem.new()
	self.stage_item_1:setPosition(cc.p(350, 370))
	self.stage_item_1:setData(self.cur_group_cfg)
	self.stage_layer:addChild(self.stage_item_1)
end

-- 旋转动画 dir:1 向左 dir：2 向右
function HeavenDialWindow:showItemRotateAni( dir )
	if not self.cur_group_id then return end
	if dir == 1 then -- 向左判断是否开启
		local new_group_id = self.cur_group_id + 1
		local group_cfg = Config.HolyEqmLotteryData.data_group[new_group_id]
		if not group_cfg or not _model:checkHeavenDialIsOpenByGId(new_group_id) then
			if group_cfg then
				message(group_cfg.open_desc)
			end
			return
		end
	end
	-- 判断是否达到左右边界
	if (dir == 2 and self.cur_group_id <= 1) or (dir == 1 and self.cur_group_id >= Config.HolyEqmLotteryData.data_group_length) then
		return
	end

	if self.rotate_ani_state then return end
	self.rotate_ani_state = true

	if dir == 1 then
		self.cur_group_id = self.cur_group_id + 1
	elseif dir == 2 then
		self.cur_group_id = self.cur_group_id - 1
	end

	self:setData()

	if not self.stage_item_2 then
		self.stage_item_2 = HeavenDialItem.new()
		self.stage_layer:addChild(self.stage_item_2)
	end

	if self.cur_stage_index == 1 then
		self.stage_item_2:setData(self.cur_group_cfg)
		self.stage_item_1:showRotateAni(dir, false)
		self.stage_item_2:showRotateAni(dir, true)
		self.cur_stage_index = 2
	elseif self.cur_stage_index == 2 then
		self.stage_item_1:setData(self.cur_group_cfg)
		self.stage_item_2:showRotateAni(dir, false)
		self.stage_item_1:showRotateAni(dir, true)
		self.cur_stage_index = 1
	end

	GlobalTimeTicket:getInstance():add(function()
        self.rotate_ani_state = false
    end, 0.25, 1)
end

function HeavenDialWindow:updateArrowBtnStatus(  )
	local left_red_status = _model:getHeavenDialIsFreeById(self.cur_group_id-1)
	if left_red_status == false then
		left_red_status = _model:getHeavenDialAwardRedById(self.cur_group_id-1)
	end
	
	local right_red_status = _model:getHeavenDialIsFreeById(self.cur_group_id+1)
	if right_red_status == false then
		right_red_status = _model:getHeavenDialAwardRedById(self.cur_group_id+1)
	end
	if not self.cur_group_id then
		self.arrow_left:setVisible(false)
		self.arrow_right:setVisible(false)
		addRedPointToNodeByStatus(self.arrow_left, false)
		addRedPointToNodeByStatus(self.arrow_right, false)
	elseif self.cur_group_id <= 1 then
		self.arrow_left:setVisible(false)
		self.arrow_right:setVisible(true)
		local new_group_id = self.cur_group_id + 1
		local group_cfg = Config.HolyEqmLotteryData.data_group[new_group_id]
		local next_is_open = true
		if not group_cfg or not _model:checkHeavenDialIsOpenByGId(new_group_id) then
			next_is_open = false
		end
		setChildUnEnabled(not next_is_open, self.arrow_right)
		setChildUnEnabled(false, self.arrow_left)
		addRedPointToNodeByStatus(self.arrow_left, false)
		if next_is_open then
			addRedPointToNodeByStatus(self.arrow_right, right_red_status, 4, 4)
		else
			addRedPointToNodeByStatus(self.arrow_right, false)
		end
	elseif self.cur_group_id >= Config.HolyEqmLotteryData.data_group_length then
		self.arrow_left:setVisible(true)
		self.arrow_right:setVisible(false)
		setChildUnEnabled(false, self.arrow_right)
		addRedPointToNodeByStatus(self.arrow_left, left_red_status, 4, 4)
		addRedPointToNodeByStatus(self.arrow_right, false)
	else
		self.arrow_left:setVisible(true)
		self.arrow_right:setVisible(true)
		local new_group_id = self.cur_group_id + 1
		local group_cfg = Config.HolyEqmLotteryData.data_group[new_group_id]
		local next_is_open = true
		if not group_cfg or not _model:checkHeavenDialIsOpenByGId(new_group_id) then
			next_is_open = false
		end
		setChildUnEnabled(not next_is_open, self.arrow_right)
		addRedPointToNodeByStatus(self.arrow_left, left_red_status, 4, 4)
		if next_is_open then
			addRedPointToNodeByStatus(self.arrow_right, right_red_status, 4, 4)
		else
			addRedPointToNodeByStatus(self.arrow_right, false)
		end
	end
end

-- 光束特效
function HeavenDialWindow:handlerLinghtEffect( status )
	if status == true then
		if not tolua.isnull(self.pos_light) and self.light_effect == nil then
            self.light_effect = createEffectSpine(Config.EffectData.data_effect_info[1090], cc.p(-6, -343), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.pos_light:addChild(self.light_effect)
        end
	else
		if self.light_effect then
            self.light_effect:clearTracks()
            self.light_effect:removeFromParent()
            self.light_effect = nil
        end
	end
end

-- 祈祷特效
function HeavenDialWindow:handleDialEffect( status )
	if status == false then
        if self.dial_effect then
            self.dial_effect:clearTracks()
            self.dial_effect:removeFromParent()
            self.dial_effect = nil
        end
    else
        if not tolua.isnull(self.main_container) and self.dial_effect == nil then
        	local main_size = self.main_container:getContentSize()
            self.dial_effect = createEffectSpine(Config.EffectData.data_effect_info[1000], cc.p(main_size.width/2, main_size.height/2-200), cc.p(0.5, 0.5), false, PlayerAction.action, handler(self, self._onDialAniCallBack))
            self.main_container:addChild(self.dial_effect)
            self.is_show_dial_ani = true
        elseif self.dial_effect then
            self.dial_effect:setToSetupPose()
            self.dial_effect:setAnimation(0, PlayerAction.action, false)
            self.is_show_dial_ani = true
        end
    end
end

function HeavenDialWindow:_onDialAniCallBack(  )
	if self.cur_group_id and self.dial_times and self.dial_recruit_type then
		_controller:sender25217( self.cur_group_id, self.dial_times, self.dial_recruit_type )
	end
	self.is_show_dial_ani = false
end


function HeavenDialWindow:DeleteMe(  )
	if self.resources_load then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
	if self.update_dial_base_data then
        GlobalEvent:getInstance():UnBind(self.update_dial_base_data)
        self.update_dial_base_data = nil
	end

	if self.update_heaven_red_status then
        GlobalEvent:getInstance():UnBind(self.update_heaven_red_status)
        self.update_heaven_red_status = nil
	end

	if self.add_goods_event then
        GlobalEvent:getInstance():UnBind(self.add_goods_event)
        self.add_goods_event = nil
	end

	if self.delete_goods_event then
        GlobalEvent:getInstance():UnBind(self.delete_goods_event)
        self.delete_goods_event = nil
	end

	if self.modify_goods_event then
        GlobalEvent:getInstance():UnBind(self.modify_goods_event)
        self.modify_goods_event = nil
	end

	if self.update_all_score then
        GlobalEvent:getInstance():UnBind(self.update_all_score)
        self.update_all_score = nil
	end
	

	if self.award_item_list and next(self.award_item_list or {}) ~= nil then
		for i, v in ipairs(self.award_item_list) do
            if v and v.effect then
                v.effect:clearTracks()
                v.effect:removeFromParent()
                v.effect = nil
            end
        end
	end

	if self.backpackitem_list and next(self.backpackitem_list or {}) ~= nil then
		for k,v in pairs(self.backpackitem_list) do
			if v and v.DeleteMe then
				v:DeleteMe()
			end
		end
	end
	self.backpackitem_list = {}

	if self.stage_item_1 then
		self.stage_item_1:DeleteMe()
		self.stage_item_1 = nil
	end
	if self.stage_item_2 then
		self.stage_item_2:DeleteMe()
		self.stage_item_2 = nil
	end
	self:handleDialEffect(false)
	self:handlerLinghtEffect(false)
	if self.stage_layer then
		self.stage_layer:setClippingEnabled(false)
	end
end

--------------------------@ item
HeavenDialItem = class("HeavenDialItem", function()
    return ccui.Widget:create()
end)

function HeavenDialItem:ctor()
	self.heaven_list = {}
	self.item_panel_list = {}
	self.item_panel_pos_list = {}
	self:configUI()
	self:register_event()
end

function HeavenDialItem:configUI(  )
	self.size = cc.size(200, 300)
	self:setTouchEnabled(false)
	self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("heaven/heaven_dial_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.name = container:getChildByName("name")
    self.image_name = container:getChildByName("image_name")
    self.image_name:setLocalZOrder(1)
	self.name:setLocalZOrder(2)
	
	self.bg = container:getChildByName("bg")

	for i=1,4 do
		local item = container:getChildByName("heaven_"..i)
		item:setLocalZOrder(2+i)
		holy_item = BackPackItem.new(false, true, false,0.7)
		holy_item:addCallBack(function() self:selectHolyByIndex(i) end)
		holy_item:addLongTimeTouchCallback(function() self:onCellLongTimeTouched(i) end)
		holy_item:setPosition(cc.p(50.5, 53))
		holy_item:showAddIcon(true)
		item:addChild(holy_item)
		self.heaven_list[i] = holy_item
		self.item_panel_list[i] = item
		self.item_panel_pos_list[i] = cc.p(item:getPositionX(),item:getPositionY())
	end
end

function HeavenDialItem:register_event(  )

end

function HeavenDialItem:selectHolyByIndex( pos )
	if self.dialy_data then
		_controller:openHeavenDialWishWindow(true,pos,self.dialy_data)
	end
end

function HeavenDialItem:onCellLongTimeTouched( pos )
	local equip_vo = nil
	if self.dialy_data then
		for i,j in pairs(self.dialy_data.lucky_holy_eqm) do
			if j.pos == pos then
				local cur_elfin_cfg = Config.HolyEqmLotteryData.data_wish_show[j.lucky_holy_eqm]
				if cur_elfin_cfg then
					equip_vo = cur_elfin_cfg
				end
				break
			end
		end
	end
	
	if equip_vo then
		equip_vo.open_type = 1
		TipsManager:getInstance():showGoodsTips(equip_vo)
	end
end

function HeavenDialItem:setData( data )
	if not data then return end

	self.data = data

	self.name:setString(data.name)

	-- 石像
	self:handleStoneEffect(false)
	self:handleStoneEffect(true, data.effect_id)
	self:updateHolyItem()
	self:showItemAction(true)

	if data.shadow_res then
		local res = PathTool.getPlistImgForDownLoad("heavendial",data.shadow_res)
		self.shadow_res_load = loadSpriteTextureFromCDN(self.bg, res, ResourcesType.single, self.shadow_res_load)
		local posX = 100
		if data.group_id == 1 then
			posX = 110
		end
		self.bg:setPositionX(posX)
	end
end


-- 刷新心愿图标
function HeavenDialItem:updateHolyItem( )
	if not self.data then
		return
	end
	local dialy_data = _model:getHeavenDialById(self.data.group_id)
	self.dialy_data = dialy_data
	for k,v in pairs(self.heaven_list) do
		local equip_vo = nil
		for i,j in pairs(dialy_data.lucky_holy_eqm) do
			if j.pos == k then
				local cur_elfin_cfg = Config.HolyEqmLotteryData.data_wish_show[j.lucky_holy_eqm]
				if cur_elfin_cfg then
					equip_vo = cur_elfin_cfg
				end
				break
			end
		end

		local holy_item = v
		if equip_vo then
			holy_item:setData(equip_vo)
			local icon_res = PathTool.getItemRes(equip_vo.icon)
			holy_item:setItemIcon(icon_res)
			holy_item:setGoodsName(equip_vo.name,cc.p(holy_item.Width/2,-36),26,cc.c4b(0xff,0xea,0xbc,0xff))
			holy_item:showAddIcon(false)
			holy_item:setSelfBackground(equip_vo.quality)
		else
            holy_item:setData()
			holy_item.item_icon:setVisible(false)
			holy_item:setGoodsName(TI18N("心愿水晶"),cc.p(holy_item.Width/2,-36),26,cc.c4b(0xff,0xea,0xbc,0xff))
			holy_item:showAddIcon(true)
			holy_item:setSelfBackground(BackPackConst.quality.white)
        end
	end
end

-- 石像特效
function HeavenDialItem:handleStoneEffect( status, effect_id )
	if status == true then
		if not tolua.isnull(self.container) and self.stone_effect == nil and effect_id then
            self.stone_effect = createEffectSpine(Config.EffectData.data_effect_info[effect_id], cc.p(self.size.width/2, 40), cc.p(0.5, 0), true, PlayerAction.action)
            self.container:addChild(self.stone_effect)
            self.effect_id = effect_id
        end
	else
		if self.stone_effect then
            self.stone_effect:clearTracks()
            self.stone_effect:removeFromParent()
            self.stone_effect = nil
        end
	end
end

-- 移动位置
function HeavenDialItem:showRotateAni( dir, flag )
	self:stopAllActions()

	if dir == 1 then
		if flag then
			self:setPosition(cc.p(1050, 370))
			self:runAction(cc.MoveTo:create(0.2, cc.p(350, 370)))
		else
			self:setPosition(cc.p(350, 370))
			self:runAction(cc.MoveTo:create(0.2, cc.p(-350, 370)))
		end
	elseif dir == 2 then
		if flag then
			self:setPosition(cc.p(-350, 370))
			self:runAction(cc.MoveTo:create(0.2, cc.p(350, 370)))
		else
			self:setPosition(cc.p(350, 370))
			self:runAction(cc.MoveTo:create(0.2, cc.p(1050, 370)))
		end
	end
end

-- 上下浮动效果
function HeavenDialItem:showItemAction( status )
	if status == true then
		if self.item_panel_list then
			for k,v in pairs(self.item_panel_list) do
				if self.item_panel_pos_list[k] then
					v:setPosition(self.item_panel_pos_list[k])
					v:stopAllActions()
					
					local index3 = math.random(1, 10)
					delayRun(v,index3/10,function()
						local off_y = 20
						local act_1 = cc.MoveBy:create(2.5, cc.p(0, -off_y))
						local act_3 = cc.MoveBy:create(2.5, cc.p(0, off_y))

						local index = math.random(1, 10)
						local delay = cc.DelayTime:create(index/10)
						local sequence = cc.Sequence:create(act_1,act_3)
						local index_2 = math.random(1, 2)
						if index_2 == 2 then
							sequence = cc.Sequence:create(act_3,act_1)
						end
						
						local RepeatForever = cc.RepeatForever:create(sequence)
						v:runAction(RepeatForever)
					end)	
				end
			end
		end
        
	else
		if self.item_panel_list then
			for k,v in pairs(self.item_panel_list) do
				if self.item_panel_pos_list[k] then
					v:setPosition(self.item_panel_pos_list[k])
					v:stopAllActions()
				end
			end
		end
    end
end

function HeavenDialItem:DeleteMe(  )
	self:showItemAction(false)
	if self.heaven_list then
		for k,v in pairs(self.heaven_list) do
			if v.DeleteMe then
				v:DeleteMe()
			end
		end
		self.heaven_list = nil
	end

	if self.shadow_res_load then 
        self.shadow_res_load:DeleteMe()
        self.shadow_res_load = nil
    end
	self:handleStoneEffect(false)
	self:removeAllChildren()
    self:removeFromParent()
end
