
--------------------------------------------
-- @Author  : xhj
-- @Editor  : xhj
-- @Date    : 2019-11-1 15:15:41
-- @description    : 
		-- 限时精灵召唤（限时活动）
---------------------------------

local _controller = TimesummonController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local string_format = string.format

ActionTimeElfinSummonPanel = class("ActionTimeElfinSummonPanel", function()
    return ccui.Widget:create()
end)

function ActionTimeElfinSummonPanel:ctor( bid )
	self._summon_type_1 = 1 	  -- 单抽的抽取类型(1免费 3钻石 4道具)
	self._summon_type_10 = 3 	  -- 十连抽抽取类型(3钻石 4道具)
	self._summon_type = 1		  -- 抽取类型(1单抽 2十连抽)
	self._init_flag = false
	self._init_status = false -- 是否已初始化（up三个道具显示）
	self.award_item_list = {}  -- 奖励item列表
	self.arriveLuckly_label = {}
	self.win_item_list = {}  -- 中奖item列表
	self.rewards_info = nil -- 抽奖结果数据
	self.cur_ani_time = 0 -- 当前数字动画滚动了多少秒

	local item_bid_cfg = Config.HolidaySpriteLotteryData.data_const["common_s"]
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
function ActionTimeElfinSummonPanel:loadResListCompleted(  )
	self:configUI()
	self:register_event()
	_controller:send26521()
	self._init_flag = true
end

function ActionTimeElfinSummonPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_time_elfin_summon_panel"))
    self.root_wnd:setPosition(-40,-84)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")
	
	self.effect_panel = main_container:getChildByName("effect_panel")
	self.win_award_panel = main_container:getChildByName("win_award_panel")
	self.image_bg = main_container:getChildByName("image_bg")
	self.title_img = main_container:getChildByName("title_img")
	
    self.item_num_txt = main_container:getChildByName("item_num_txt")
    self.item_num_txt:setTextColor(Config.ColorData.data_color4[1])
	self.item_num_txt:enableOutline(Config.ColorData.data_color4[2],2)
	self.item_icon = main_container:getChildByName("item_icon")
	loadSpriteTexture(self.item_icon, PathTool.getItemRes(Config.HolidaySpriteLotteryData.data_const.common_s.val), LOADTEXT_TYPE)
    self.baodi_bg = main_container:getChildByName("baodi_bg")

    self.award_btn = main_container:getChildByName("award_btn")
    self.award_btn:getChildByName("label"):setString(TI18N("奖励预览"))
    self.preview_btn = main_container:getChildByName("preview_btn")
    self.preview_btn:getChildByName("label"):setString(TI18N("精灵预览"))

    self.summon_btn_1 = main_container:getChildByName("summon_btn_1")
    self.summon_btn_1:getChildByName("label"):setString(TI18N("召唤1次"))

    self.summon_btn_10 = main_container:getChildByName("summon_btn_10")
    self.summon_btn_10:getChildByName("label"):setString(TI18N("召唤10次"))

	self.time_txt = main_container:getChildByName("time_txt")
	main_container:getChildByName("time_txt_0"):setString(TI18N("剩余时间："))
	
	self.progress_panel = main_container:getChildByName("progress_panel")
	self.progress = self.progress_panel:getChildByName("progress")
	self.progress:setScale9Enabled(true)

	self.btnRule = main_container:getChildByName("btnRule")
	self:showEffect1(true,PlayerAction.action_1)
	
end

-- 老虎机特效
function ActionTimeElfinSummonPanel:showEffect1( status, action_name, is_pool )
	if status == true then
		action_name = action_name or PlayerAction.action_1
        is_pool = is_pool or false
        self.cur_action_name = action_name
        if not tolua.isnull(self.effect_panel) and self.draw_effect == nil then
            self.draw_effect = createEffectSpine("E27201", cc.p(0, -154), cc.p(0.5, 0.5), is_pool, action_name, handler(self, self.onEffectCallBack))
			self.effect_panel:addChild(self.draw_effect)
		elseif self.draw_effect then
			if PlayerAction.action_1 == action_name then
				self.draw_effect:setToSetupPose()
			end
            self.draw_effect:setAnimation(0, action_name, is_pool)
        end
    else
        if self.draw_effect then
            self.draw_effect:clearTracks()
            self.draw_effect:removeFromParent()
            self.draw_effect = nil
        end
    end
end

-- 闪光特效
function ActionTimeElfinSummonPanel:showEffect2( status )
	if status == true then
        if not tolua.isnull(self.win_award_panel) and self.draw_effect_2 == nil then
            self.draw_effect_2 = createEffectSpine("E27203", cc.p(self.win_award_panel:getContentSize().width/2, self.win_award_panel:getContentSize().height/2-3), cc.p(0.5, 0.5), false, PlayerAction.action)
			self.win_award_panel:addChild(self.draw_effect_2)
        end
    else
        if self.draw_effect_2 then
            self.draw_effect_2:clearTracks()
            self.draw_effect_2:removeFromParent()
            self.draw_effect_2 = nil
        end
    end
end


-- 闪光特效2
function ActionTimeElfinSummonPanel:showEffect4( status )
	if status == true then
        if not tolua.isnull(self.win_award_panel) and self.draw_effect_4 == nil then
            self.draw_effect_4 = createEffectSpine("E27204", cc.p(self.win_award_panel:getContentSize().width/2, self.win_award_panel:getContentSize().height/2-3), cc.p(0.5, 0.5), false, PlayerAction.action)
			self.win_award_panel:addChild(self.draw_effect_4)
        end
    else
        if self.draw_effect_4 then
            self.draw_effect_4:clearTracks()
            self.draw_effect_4:removeFromParent()
            self.draw_effect_4 = nil
        end
    end
end

-- 掉蛋特效
function ActionTimeElfinSummonPanel:showEffect3( status ,action_name)
	if status == true then
		action_name = action_name or PlayerAction.action_1
        if not tolua.isnull(self.effect_panel) and self.draw_effect_3 == nil then
            self.draw_effect_3 = createEffectSpine("E27202", cc.p(self.effect_panel:getContentSize().width/2, self.effect_panel:getContentSize().height/2-224), cc.p(0.5, 0.5), false, action_name,handler(self, self.onEffectCallBack2))
			self.effect_panel:addChild(self.draw_effect_3)
        end
    else
        if self.draw_effect_3 then
            self.draw_effect_3:clearTracks()
            self.draw_effect_3:removeFromParent()
            self.draw_effect_3 = nil
        end
    end
end

function ActionTimeElfinSummonPanel:onEffectCallBack()
    if self.cur_action_name == PlayerAction.action_2 then
		self:showEffect1(true, PlayerAction.action_3, true)
		self:openEndTimer(true)
    end
end

function ActionTimeElfinSummonPanel:onEffectCallBack2()
	_controller:openActionTimeElfinSummonGainWindow(true,self.rewards_info,TRUE)
end


-- 刷新保底次数显示
function ActionTimeElfinSummonPanel:updateBaodiCount(  )
	if not self.baodi_bg or not self.data then return end

	if not self.data.item_id or self.data.item_id == 0 then
		self.baodi_bg:setVisible(false)
		return
	end
	self.baodi_bg:setVisible(true)
	if not self.baodi_item then
		self.baodi_item = BackPackItem.new(true, true, false, 0.35)
		self.baodi_item:setDefaultTip()
		self.baodi_item:setPosition(cc.p(30, 22.5))
		self.baodi_bg:addChild(self.baodi_item)
	end
	if not self.cur_show_bid or self.cur_show_bid ~= self.data.item_id then
		self.baodi_item:setBaseData(self.data.item_id, self.data.item_num)
		self.cur_show_bid = self.data.item_id
	end

	local count = self.data.must_count or 0
	if not self.baodi_text then
		self.baodi_text = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(152, 22.5))
		self.baodi_bg:addChild(self.baodi_text)
	end
	self.baodi_text:setString(string.format("<div fontcolor=#ffffff outline=2,#000000>剩余</div><div fontcolor=#5fde46 outline=2,#000000>%d</div><div fontcolor=#ffffff outline=2,#000000>次召唤内必出</div>", count))
end

-- 显示背景图
function ActionTimeElfinSummonPanel:updateImageBg(  )
	if self.config and self.config.res_id and (not self.cur_res_id or self.cur_res_id ~= self.config.res_id) and self.config.call_bg then
		local bg_res = PathTool.getPlistImgForDownLoad("bigbg/timesummon", string.format("txt_cn_elfinsummon_bigbg_%d", self.config.call_bg), true)
		self.bg_load = loadImageTextureFromCDN(self.image_bg, bg_res, ResourcesType.single, self.bg_load)

		local bg_res_2 = PathTool.getPlistImgForDownLoad("bigbg/timesummon", string.format("txt_cn_elfinsummon_%d", self.config.res_id), false)
		self.title_load = loadSpriteTextureFromCDN(self.title_img, bg_res_2, ResourcesType.single, self.title_load)
		
		self.cur_res_id = self.config.res_id
	end
end

-- 刷新按钮显示状态
function ActionTimeElfinSummonPanel:updateSummonBtnStatus(  )
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
function ActionTimeElfinSummonPanel:openSummonFreeTimer( status )
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
function ActionTimeElfinSummonPanel:updateProgress(  )
	local award_config = Config.HolidaySpriteLotteryData.data_award[self.data.camp_id]
	local start_y = 80
	local distance_y = 527
	if award_config then
		local offset_y = (distance_y - start_y + 0)/(#award_config-1)
		for i,v in ipairs(award_config) do
			local item = self.award_item_list[i]
			local pos_y = start_y + (i-1)*offset_y
			if item == nil then
				item = RoundItem.new(true,0.55,0.6)
				self.progress_panel:addChild(item)
				self.award_item_list[i] = item

				
				item:setPosition(cc.p(16.5, pos_y))
				item:setBaseData(v.reward[1][1], v.reward[1][2])
				item:setVisibleRedPoint(false)
				item:setVisibleRoundBG(false)
				local function func()
					_controller:send26523(v.id)
				end
				item:addCallBack(func)
			end

			if not self.arriveLuckly_label[i] and self.award_item_list[i] then
				self.arriveLuckly_label[i] = createLabel(22,cc.c3b(0xf4,0xee,0xd3),cc.c3b(0x00,0x00,0x00),45,pos_y,"",self.progress_panel,2, cc.p(0,0.5))
			end
			if self.arriveLuckly_label[i] then
				self.arriveLuckly_label[i]:setString(v.times)
			end
		end

		-- 计算进度条
		local last_times = 0
		local progress_width = 527
		local first_off = start_y-0 -- 0到第一个的距离
		local distance = 0
		for i,v in ipairs(award_config) do
			if i == 1 then
				if self.data.times <= v.times then
					distance = (self.data.times/v.times)*first_off
					break
				else
					distance = first_off
				end
			else
				if self.data.times <= v.times then
					distance = distance + ((self.data.times-last_times)/(v.times-last_times))*offset_y
					break
				else
					distance = distance + offset_y
				end
			end
			last_times = v.times
		end
		self.progress:setPercent(distance/progress_width*100)

		if not self.num_label then
			self.num_label = createLabel(22,cc.c3b(0xf4,0xee,0xd3),cc.c3b(0x00,0x00,0x00),-20,-20,"",self.progress_panel,2, cc.p(0,0.5))
		end
		self.num_label:setString(string_format(TI18N("已抽:%d"),self.data.times))
	end

	self:updateAwardStatus()
end

function ActionTimeElfinSummonPanel:updateAwardStatus()
	local award_config = Config.HolidaySpriteLotteryData.data_award[self.data.camp_id]
	if award_config then
		for i,v in pairs(award_config) do
			local _bool = false
			local _un_enabled = false
			for k,m in pairs(self.data.reward_list) do
				if v.id == m.id then
					_un_enabled = true
					break
				end
			end

			
			for j,n in ipairs(self.data.award_list) do
				if v.id == n.id then
					_bool = true
					break
				end
			end
			
	
			setChildUnEnabled(false, self.award_item_list[i])
			if self.award_item_list[i] then
				self.award_item_list[i]:setDefaultTip(not _bool)
				self.award_item_list[i]:setVisibleRedPoint(_bool)
	
				if _un_enabled == true then
					setChildUnEnabled(true, self.award_item_list[i])
				end
			end
		end
	end
end

-- 刷新道具数量
function ActionTimeElfinSummonPanel:updateItemNum( bag_code, data_list )
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

function ActionTimeElfinSummonPanel:register_event(  )
	registerButtonEventListener(self.award_btn, function (  )
		if self.config and self.data then
			_controller:openTimeSummonAwardView(true, self.config.group_id, self.data,TimesummonConst.ActonInfoType.ElfinType)
		end
	end, true)

	registerButtonEventListener(self.preview_btn, function (  )
		_controller:send23219(ActionRankCommonType.time_elfin_summon)
	end, true)

	-- registerButtonEventListener(self.btnRule, function(param,sender, event_type)
	-- 	local config = Config.HolidaySpriteLotteryData.data_action[self.data.camp_id]
	-- 	if config then
	-- 		TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)	
	-- 	end
    -- end ,true, 1)

	-- 召唤1次
	registerButtonEventListener(self.summon_btn_1, function (  )
		local max, count = HeroController:getInstance():getModel():getHeroMaxCount()
		if self._summon_type_1 == 3 and self.config then
			local num = self.config.loss_gold_once[1][2]
			local call_back = function ()
				self._summon_type = 1
                _controller:send26522( 1, self._summon_type_1 ,false)
            end
            local item_icon_2 = Config.ItemData.data_get_data(self.config.loss_gold_once[1][1]).icon
            local val_str = Config.ItemData.data_get_data(self.config.gain_once[1][1]).name or ""
            local val_num = self.config.gain_once[1][2]
            local call_num = 1
            self:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
		else
			self._summon_type = 1
			_controller:send26522( 1, self._summon_type_1 ,false)
		end
	end, true)

	-- 召唤10次
	registerButtonEventListener(self.summon_btn_10, function (  )
		if self._summon_type_10 == 3 and self.config then
			local num = self.config.loss_gold_ten[1][2]
			local call_back = function ()
				self._summon_type = 2
                _controller:send26522( 10, self._summon_type_10 ,false)
            end
            local item_icon_2 = Config.ItemData.data_get_data(self.config.loss_gold_ten[1][1]).icon
            local val_str = Config.ItemData.data_get_data(self.config.gain_ten[1][1]).name or ""
            local val_num = self.config.gain_ten[1][2]
            local call_num = 10
            self:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
		else
			self._summon_type = 2
			_controller:send26522( 10, self._summon_type_10 ,false)
		end
	end, true)

	-- 召唤数据更新
	if not self.update_summon_data_event then
        self.update_summon_data_event = GlobalEvent:getInstance():Bind(TimesummonEvent.Update_Elfin_Summon_Data_Event,function (data)
            self:setData(data)
        end)
	end

	-- 精灵抽奖结果更新
	if not self.update_summon_rewards_data_event then
		self.update_summon_rewards_data_event = GlobalEvent:getInstance():Bind(TimesummonEvent.Update_Elfin_Summon_Rewards_Data_Event,function (data)
			self.rewards_info = data
            self:startEffectAwardShow()
        end)
	end

	-- 精灵抽奖结果item更新
	if not self.update_elfin_item_event then
		self.update_elfin_item_event = GlobalEvent:getInstance():Bind(TimesummonEvent.Update_Elfin_Item_Event,function (data)
			self.rewards_info = data
            self:updateAwardItmes(false)
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

--开始奖励和特效显示
function ActionTimeElfinSummonPanel:startEffectAwardShow(  )
	self:showEffect2(false)
	self:showEffect3(false)
	self:showEffect4(false)
	-- delayOnce(function()
		
		
	-- end, 0.5)
	
	if self.win_item_list and next(self.win_item_list or {}) ~= nil then
		for i, v in ipairs(self.win_item_list) do
			if v and v.setVisible then
				v:setVisible(false)
				v:suspendAllActions()
			end
		end
	end

	if not self.touchUi then
		self.touchUi = ccui.Layout:create()
		self.touchUi:setTouchEnabled(true)
		self.touchUi:setSwallowTouches(true)
		self.touchUi:setContentSize(SCREEN_WIDTH,SCREEN_HEIGHT)
		ViewManager:getInstance():getLayerByTag(ViewMgrTag.DIALOGUE_TAG):addChild(self.touchUi)
		handleTouchEnded(self.touchUi, function(...)
			_controller:openActionTimeElfinSummonGainWindow(true,self.rewards_info,TRUE)
			if self.touchUi and not tolua.isnull(self.touchUi) then
				self.touchUi:removeFromParent()
			end
			self.touchUi = nil
			self:openEndTimer(false)
			self:showEffect1(true, PlayerAction.action_1)
			self:showEffect2(false)
			self:showEffect4(false)
			self:updateAwardItmes(false)
			self:showEffect3(false)
		end)
	end
	self:showEffect1(true,PlayerAction.action_2)
end

--结束奖励和特效显示
function ActionTimeElfinSummonPanel:endEffectAwardShow(  )
	if self.touchUi and not tolua.isnull(self.touchUi) then
		self.touchUi:removeFromParent()
	end
	self.touchUi = nil
	local num = 0
	for i ,v in ipairs(self.rewards_info.sprite_bids) do
		if v.quality >= 4 then
			num = num+1
		end
	end

	self:openEndTimer(false)
	self:showEffect1(true, PlayerAction.action_1)
	if num>0 then
		self:showEffect2(true)
	else
		self:showEffect4(true)
	end
	
	self:updateAwardItmes(false)

	
	local action_name = PlayerAction.action_1
	if self._summon_type == 1 then
		if num > 0 then
			action_name = PlayerAction.action_2
		end
	else
		action_name = "action"..(3+num)
	end
	self:showEffect3(true,action_name)
end

-- 定时器
function ActionTimeElfinSummonPanel:openEndTimer(status)
    if status == true then
        if self.roll_timer == nil then
            self.roll_timer = GlobalTimeTicket:getInstance():add(function()
                self.cur_ani_time = self.cur_ani_time + 1
                if self.cur_ani_time >= 2 then
                    GlobalTimeTicket:getInstance():remove(self.roll_timer)
					self.roll_timer = nil
					self.cur_ani_time = 0
					self:endEffectAwardShow()
                end
            end, 1)
        end
    else
        if self.roll_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.roll_timer)
            self.roll_timer = nil
        end
    end
end

-- 钻石召唤时的提示
function ActionTimeElfinSummonPanel:showAlert(num,item_icon_2,val_str,val_num,call_num,call_back)
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
    local str_ = str..string.format(TI18N("<div fontColor=#764519>购买</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519></div><div fontColor=#d95014 fontsize= 26>%s</div><div fontColor=#764519>(同时附赠</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>次召唤)</div>"),val_num,val_str,call_num)
    if not self.alert then
        self.alert = CommonAlert.show(str_, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
    end
end

function ActionTimeElfinSummonPanel:setData( data )
	if not data then return end
	self.data = data
	local action_cfg = Config.HolidaySpriteLotteryData.data_action[self.data.camp_id]
	if action_cfg and action_cfg.group_id then
		self.config = Config.HolidaySpriteLotteryData.data_summon[action_cfg.group_id]
	end

	if self._init_status == false then
		self._init_status = true
		self:updateAwardItmes(true)
	end

	-- 活动时间
	setCountDownTime(self.time_txt,self.data.end_time - GameNet:getInstance():getTime())
	
	self:updateImageBg()
	self:updateSummonBtnStatus()
	self:updateProgress()
	self:updateItemNum()
	self:updateBaodiCount()
end

function ActionTimeElfinSummonPanel:updateAwardItmes(is_init)
	local item_id = nil
	local num = 1
	if is_init == true then--初始化
		if self.data then
			item_id = self.data.item_id	
		end
	else
		if self.rewards_info then
			if #self.rewards_info.sprite_bids > 0 then
				local sort_func = SortTools.tableUpperSorter({"quality", "jie"})
				table.sort(self.rewards_info.sprite_bids,sort_func)
				item_id = self.rewards_info.sprite_bids[1].sprite_bid
				for i ,v in ipairs(self.rewards_info.sprite_bids) do
					if v.sprite_bid == self.data.item_id then
						item_id = v.sprite_bid
						break
					end
				end
			elseif #self.rewards_info.rewards >0 then
				item_id = self.rewards_info.rewards[1].base_id
				num = self.rewards_info.rewards[1].num
			end
		end
	end
	
	if item_id then
		for i=1,3 do
			local item = self.win_item_list[i]
			if not item then
				item = BackPackItem.new(true, true, false, 1)
				item:setBackgroundOpacity(0)
				item:setDefaultTip()
				item:setPosition(cc.p(54+(120*0.5+29)*(i-1), 59))
				self.win_award_panel:addChild(item)
				self.win_item_list[i] = item
			end
			item:setVisible(true)
			item:setBaseData(item_id, num)
			local scale = 0.8
			local config = Config.ItemData.data_get_data(item_id)
			if config and config.type and BackPackConst.checkIsElfin(config.type) then
				res_id = PathTool.getPlistImgForDownLoad("bigbg/elfin", "elfin_"..item_id)	
				item:setItemIcon(res_id)
				scale = 1
			end
			item:setScale(scale)
			item:setElfinStep(false)
			item:setShowNumBg(false)
			
		end
	end

end

function ActionTimeElfinSummonPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
    if bool == true and self._init_flag == true then
    	_controller:send26521()
	end
	if bool == false then
		if self.touchUi and not tolua.isnull(self.touchUi) then
			self.touchUi:removeFromParent()
		end
		self.touchUi = nil
	end
end

function ActionTimeElfinSummonPanel:DeleteMe(  )
	doStopAllActions(self.time_txt)
	self:showEffect1(false)
	self:showEffect2(false)
	self:showEffect4(false)
	self:showEffect3(false)
	self:openEndTimer(false)
	if self.touchUi and not tolua.isnull(self.touchUi) then
		self.touchUi:removeFromParent()
	end
	self.touchUi = nil

	if self.award_item_list and next(self.award_item_list or {}) ~= nil then
        for i, v in ipairs(self.award_item_list) do
            if v and v.DeleteMe then
                v:DeleteMe()
            end
        end
	end

	if self.win_item_list and next(self.win_item_list or {}) ~= nil then
        for i, v in ipairs(self.win_item_list) do
            if v and v.DeleteMe then
                v:DeleteMe()
            end
        end
	end
	
	if self.bg_load then
		self.bg_load:DeleteMe()
		self.bg_load = nil
	end

	if self.title_load then
		self.title_load:DeleteMe()
		self.title_load = nil
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
	if self.update_summon_rewards_data_event then
		GlobalEvent:getInstance():UnBind(self.update_summon_rewards_data_event)
		self.update_summon_rewards_data_event = nil
	end
	if self.update_elfin_item_event then
		GlobalEvent:getInstance():UnBind(self.update_elfin_item_event)
		self.update_elfin_item_event = nil
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
