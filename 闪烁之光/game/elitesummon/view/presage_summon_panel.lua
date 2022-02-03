--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 预言召唤
-- @DateTime:    2019-07-12 16:00:15
-- *******************************
PresageSummonPanel = class("PresageSummonPanel", function()
    return ccui.Widget:create()
end)

local controller = EliteSummonController:getInstance()
local model = controller:getModel()
local config_data = Config.HolidayPredictData.data_constant
local reward_data = Config.HolidayPredictData.data_reward_pos
local string_format = string.format
function PresageSummonPanel:ctor(bid)
	self.holiday_bid = bid

	self.get_server_return = nil --未获取基础协议的时候不能做任何事情
	self.round_bg_load = {}
	self.open_list_pos = {}
	--松果的位置
	self.pine_pos_x = {}
	self.pine_pos_y = {}
	self.reward_item = {}
	self.open_status_item = {}
	
	self.effect_status_1 = {} --未开启状态松果特效
	self.pine_item = {} --未开启状态的松果
	--购买的状态
	self.buy_item_type = nil
	self.touch_btn_reset = true
	self.tab_change_view = true

	self.tab_view = {}
	self.cur_index = nil
	self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("presagesummon","presagesummon"), type = ResourcesType.plist },
    } 
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(self.res_list, function()
        if self.loadResListCompleted then
        	self:loadResListCompleted()
        end
    end)
end
-- 资源加载完成
function PresageSummonPanel:loadResListCompleted()
	self:configUI()
	self:register_event()
end
function PresageSummonPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("elitesummon/presage_summon_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.bg_image = main_container:getChildByName("bg_image")

	local name = {TI18N("幸运松果"),TI18N("豪华松果")}
	local tab_panel = main_container:getChildByName("tab_panel")
	for i=1,2 do
		local tab = {}
		tab.btn = tab_panel:getChildByName("tab_"..i)
		tab.normal = tab.btn:getChildByName("normal")
		tab.select = tab.btn:getChildByName("select")
		tab.select:setVisible(false)
		tab.name = tab.btn:getChildByName("name")
		tab.name:setString(name[i])
		tab.index = i
		self.tab_view[i] = tab
	end

	--松果币道具
	self.item_pine_count = config_data["item1"].val
	local icon = main_container:getChildByName("icon")
	local item_config = Config.ItemData.data_get_data(self.item_pine_count)
	if item_config then
		loadSpriteTexture(icon, PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
		icon:setScale(0.45)
	end
	self.icon_count = main_container:getChildByName("icon_count")
	self.icon_count:setString("")
	local have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.item_pine_count)
    self.icon_count:setString(have_num)
    self.btn_drop = main_container:getChildByName("btn_drop")
    self.probablity = main_container:getChildByName("probablity")
    self.probablity:setVisible(false)
    self.probablity_panel = self.probablity:getChildByName("panel")
    self.probabily_bg = self.probablity:getChildByName("probabily_bg")

	self.btn_rule = main_container:getChildByName("btn_rule")
	self.btn_buy = main_container:getChildByName("btn_buy")
	self.time_text = main_container:getChildByName("time_text")
	self.time_text:setString("")

	self.item_scroll = main_container:getChildByName("item_scroll")
	self.close_status = main_container:getChildByName("close_status")
	self.close_status:setVisible(false)
	self.btn_open = self.close_status:getChildByName("btn_open")
	self.btn_open:getChildByName("Text_13"):setString(TI18N("打开松果"))

	self.open_status = main_container:getChildByName("open_status")
	self.open_status:setVisible(false)
	self.btn_reset = self.open_status:getChildByName("btn_reset")
	self.btn_reset:getChildByName("Text_13"):setString(TI18N("重新剥开"))
	self.refresh_text = createRichLabel(20, cc.c4b(0xff,0xfb,0x94,0xff), cc.p(0.5,0.5), cc.p(103,22))
    self.btn_reset:addChild(self.refresh_text)
    self.refresh_text:setString(TI18N("免费刷新: "))
    self.remain_refresh_bg = self.open_status:getChildByName("Image_6")
    self.remain_refresh_bg:setVisible(false)

    self.remain_refresh_text = createRichLabel(22, cc.c4b(0xff,0xf7,0xe3,0xff), cc.p(0.5,0.5), cc.p(self.remain_refresh_bg:getContentSize().width/2,15),nil,nil,500)
    self.remain_refresh_bg:addChild(self.remain_refresh_text)
        											
	self.btn_get = self.open_status:getChildByName("btn_get")
	self.btn_get_label = self.btn_get:getChildByName("Text_13")
	self.btn_get_label:setString(TI18N("立即获得"))
	self.get_diamond = createRichLabel(22, cc.c4b(0x8a,0xfa,0x49,0xff), cc.p(0.5,0.5), cc.p(103,22))
    self.btn_get:addChild(self.get_diamond)

	self.limit_count = self.open_status:getChildByName("limit_count")
	self.limit_count:setString(TI18N("活动限购: "))
	for i=1,3 do
		self.open_list_pos[i] = {}
		self.open_list_pos[i][1] = self.open_status:getChildByName("node_"..i):getPositionX()
		self.open_list_pos[i][2] = self.open_status:getChildByName("node_"..i):getPositionY()
		self.pine_pos_x[i] = self.close_status:getChildByName("node_"..i):getPositionX()
		self.pine_pos_y[i] = self.close_status:getChildByName("node_"..i):getPositionY()
	end
	--剩余次数
    self.remain_up = createRichLabel(22, cc.c4b(0xff,0xf7,0xe3,0xff), cc.p(0.5,0.5), cc.p(360,157),nil,nil,500)
    self.open_status:addChild(self.remain_up)
	controller:send16690()
end

--开奖物品
function PresageSummonPanel:setDropProbalyData()
	if not self.probably_item_scrollview then
        local view_size = self.probablity_panel:getContentSize()
        local setting = {
            start_x = 20,
            space_x = 0,
            start_y = 0,
            space_y = 0,
            item_width = PresageSummonItem.width,
            item_height = PresageSummonItem.height,
            row = 1,
            col = 2,
            need_dynamic = true
        }
        self.probably_item_scrollview = CommonScrollViewSingleLayout.new(self.probablity_panel,cc.p(0, 0),ScrollViewDir.vertical,ScrollViewStartPos.top,view_size,setting)
        self.probably_item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.probably_item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.probably_item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    
    if not self.cur_index then return end
    self.drop_list = model:getDropData(self.cur_index)
    if next(self.drop_list) == nil then
    	model:setDropData(self.cur_index)
    	self.drop_list = model:getDropData(self.cur_index)
    end
    if self.probably_item_scrollview then
        self.probably_item_scrollview:reloadData()
    end
end
function PresageSummonPanel:createNewCell()
	local cell = PresageSummonItem.new()
    return cell
end
function PresageSummonPanel:numberOfCells()
	if not self.drop_list then return 0 end
    return #self.drop_list
end
function PresageSummonPanel:updateCellByIndex(cell, index)
    local cell_data = self.drop_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function PresageSummonPanel:tabChangeView(index)
	index = index or 1
	if not self.tab_change_view then return end

	if self.cur_index == index then return end
    if self.cur_tab ~= nil then
        self.cur_tab.normal:setVisible(true)
        self.cur_tab.select:setVisible(false)
    end
    self.cur_index = index
    self.cur_tab = self.tab_view[self.cur_index]

    if self.cur_tab ~= nil then
        self.cur_tab.normal:setVisible(false)
        self.cur_tab.select:setVisible(true)
    end
    self.remain_refresh_bg:setVisible(index == 2)
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/timesummon", "txt_cn_presage_summon"..index)
    if not self.round_bg_load[index] then
		self.round_bg_load[index] = loadSpriteTextureFromCDN(self.bg_image, bg_res, ResourcesType.single, self.round_bg_load[index])
	end
	if self.round_bg_load[index] then
        loadSpriteTexture(self.bg_image,bg_res,LOADTEXT_TYPE)
    end
    self:setConfigData()
    local status = model:getIsStatus(index)
    self:IsActionStatus(status)
    self:setLimitCount()
end
--奖励预览
function PresageSummonPanel:setConfigData()
	if not self.cur_index then return end
	local list
	if self.cur_index == 1 then
		list = config_data["show_item1"].val
	elseif self.cur_index == 2 then
		list = config_data["show_item2"].val
	end
	if not list then return end

	local start_pos = self.item_scroll:getContentSize().height - 60
	local num = #list
	if num >= 6 then num = 6 end
	for i=1, num do
		if not self.reward_item[i] then
			self.reward_item[i] = BackPackItem.new(nil,true,nil,0.7)
		    self.item_scroll:addChild(self.reward_item[i])
		end
		local pos_x = 58 + ((BackPackItem.Width*0.7+ 15) * ((i-1)%3))
		local pos_y = start_pos - ((BackPackItem.Height*0.7+10) * math.floor((i-1)/3))
	    self.reward_item[i]:setPosition(cc.p(pos_x, pos_y))
	    self.reward_item[i]:setBaseData(list[i][1], list[i][2])
	    self.reward_item[i]:setDefaultTip()
	end
end
--是否开奖或者要打开状态 0关闭，1打开
function PresageSummonPanel:IsActionStatus(status)
	self.close_status:setVisible(status == 0)
	self.open_status:setVisible(status == 1)

	local data = model:getGoodsItemPos(self.cur_index)
	if not data then return end
	if not config_data then return end

	if status == 0 then
		self:setEffectStatus_1(false)
		self.btn_open:setVisible(true)
		local list = data.rand_lists
		if next(list) ~= nil then
			for i=1,3 do
				if list[i] and list[i].pos and list[i].id and reward_data[list[i].id] then
					local item_config = Config.ItemData.data_get_data(reward_data[list[i].id].item_id)
					local effect_num = 520
					if item_config then
						if item_config.quality == BackPackConst.quality.orange then
							effect_num = 521
						end
					end
					self:setEffectStatus_1(true,self.cur_index,i,effect_num)
					if not self.pine_item[i] then
						self.pine_item[i] = createSprite(nil, self.pine_pos_x[i], self.pine_pos_y[i], self.close_status, cc.p(0.5, 0.5),LOADTEXT_TYPE_PLIST,10)
					end
				
					self.pine_item[i]:setVisible(true)
					local str_res = PathTool.getResFrame("presagesummon","presagesummon_5")
					if reward_data[list[i].id].is_goal == 1 then
						str_res = PathTool.getResFrame("presagesummon","presagesummon_8")
					end
					loadSpriteTexture(self.pine_item[i], str_res,LOADTEXT_TYPE_PLIST)
				end
			end
		end
	elseif status == 1 then
		local list = data.rand_lists
		if next(list) ~= nil then
			for i=1,3 do
				if not self.open_status_item[i] then
					self.open_status_item[i] = BackPackItem.new(nil,true)
					self.open_status:addChild(self.open_status_item[i])
				end
				if list[i] and list[i].pos and list[i].id and reward_data[list[i].id] then
					local item_config = Config.ItemData.data_get_data(reward_data[list[i].id].item_id)
					local effect_num = 522
					if item_config then
						if item_config.quality == BackPackConst.quality.orange then
							effect_num = 523
						end
					end
					self.open_status_item[i]:setVisible(true)
					self.open_status_item[i]:setPosition(cc.p(self.open_list_pos[list[i].pos][1], self.open_list_pos[list[i].pos][2]))
					self.open_status_item[i]:setBaseData(reward_data[list[i].id].item_id,reward_data[list[i].id].item_num)
				    self.open_status_item[i]:showItemEffect(true, effect_num, PlayerAction.action, true)
				    self.open_status_item[i]:setEffectLocalZOrder(-1)
				    self.open_status_item[i]:setDefaultTip()
				end
			end
		end
		self:setBtnRefreahData()

		local must_num = config_data["must_num_2"].val
		local refresh_str = string_format(TI18N("<div outline=2,#37161a>剩余</div><div fontColor=#8bfa49 fontsize=22 outline=2,#37161a> %d </div><div outline=2,#37161a>次刷新必出两个五星英雄</div>"),must_num-data.count%must_num)
		if (must_num-data.count%must_num) == 1 then
			refresh_str = TI18N("本次刷新必出两个五星英雄")
		end
    	self.remain_refresh_text:setString(refresh_str)
	end
end
--刷新重新剥开按钮
function PresageSummonPanel:setBtnRefreahData()
	if not self.cur_index then return end

	local count = model:getReFreshCount(self.cur_index)
	local num = config_data["free_time1"].val
	if self.cur_index == 2 then
		num = config_data["free_time2"].val
	end
	local str = string_format(TI18N("<div outline=2,#651d00>免费刷新: %d/%d</div>"),num - count,num)
	if count >= num then
		local have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.item_pine_count)
		if have_num >= 1 then
			--使用松果币
			local item_config = Config.ItemData.data_get_data(self.item_pine_count)
			if item_config then
				str = string_format(TI18N("<img src=%s visible=true scale=0.25 /> %d"),PathTool.getItemRes(item_config.icon), 1)
			end
		else
			-- 使用钻石
			local refresh_data = config_data["item_price"].val
			if refresh_data and refresh_data[1] then
	    		str = string_format(TI18N("<img src=%s visible=true scale=0.25 /> %d"),PathTool.getItemRes(refresh_data[1][1]), refresh_data[1][2])
	    	end
	    end
	end
	self.refresh_text:setString(str)

	local cur_count = model:getbuyCount(self.cur_index)
	local totle_count = 0
	if self.cur_index == 1 then
		totle_count = config_data["buy_time1"].val
	elseif self.cur_index == 2 then
		totle_count = config_data["buy_time2"].val
	end

	if cur_count < totle_count then
		local status = model:getGetButtonStatus(self.cur_index)
		if status == 1 then
			self:setGetChildUnEnabled(false)
		else
			self:setGetChildUnEnabled(true)
		end
	end
end
--松果特效
function PresageSummonPanel:setEffectStatus_1(status,index,sort,effect_id)
	if status == false then
		for i,v in pairs(self.effect_status_1) do
			if v then
				v:setVisible(false)
			end
		end
	else
		local num = 3 * (index-1) + sort
		if not self.effect_status_1[num] then
			self.effect_status_1[num] = createEffectSpine(PathTool.getEffectRes(effect_id),cc.p(self.pine_pos_x[sort], self.pine_pos_y[sort]),cc.p(0.5, 0.5),true, PlayerAction.action)
			self.close_status:addChild(self.effect_status_1[num])
		end
		if self.effect_status_1[num] then
			self.effect_status_1[num]:setVisible(true)
		end
	end
end
--限购次数与消耗
function PresageSummonPanel:setLimitCount()
	local prize_data = Config.HolidayPredictData.data_prize_pool
	if prize_data[self.cur_index] then
		local data = prize_data[self.cur_index].expend_item --松果币
		local have_num = BackpackController:getInstance():getModel():getItemNumByBid(data[1][1])
		if have_num >= data[1][2] then
			self.buy_item_type = 1
		else
			self.buy_item_type = 2
		end
		local str
		local item_config = Config.ItemData.data_get_data(data[1][1])
		if item_config then
			str = string.format("<img src=%s scale=0.25 visible=true /> <div outline=2,#37161a> %d</div>", PathTool.getItemRes(item_config.icon),data[1][2])
		end
		local count = model:getbuyCount(self.cur_index)
		local totle_count = 0
		if self.cur_index == 1 then
			totle_count = config_data["buy_time1"].val
		elseif self.cur_index == 2 then
			totle_count = config_data["buy_time2"].val
		end
		if count >= totle_count then
			str = TI18N("已到最大值")
			self:setGetChildUnEnabled(false)
		else
			if count < totle_count then
				local status = model:getGetButtonStatus(self.cur_index)
				if status == 1 then
					self:setGetChildUnEnabled(false)
				else
					self:setGetChildUnEnabled(true)
				end
			end
		end

		if count >= totle_count then
			count = totle_count
		end
		local limit_str = string_format(TI18N("活动限购: %d/%d"),count,totle_count)
		self.limit_count:setString(limit_str)

		if str then
			self.get_diamond:setString(str)
		end
	end
end
-- 
function PresageSummonPanel:setGetChildUnEnabled(status)
	if status == true then
		self.btn_get:setTouchEnabled(true)
		setChildUnEnabled(false, self.btn_get)
		self.btn_get_label:setTextColor(cc.c4b(0xff,0xff,0xff,0xff))
		self.btn_get_label:enableOutline(cc.c4b(0x65,0x1D,0x00,0xff), 2)
	else
		self.btn_get:setTouchEnabled(false)
		setChildUnEnabled(true, self.btn_get)
		self.btn_get_label:disableEffect(cc.LabelEffect.OUTLINE)
	end
end
function PresageSummonPanel:register_event()
	if not self.message_event then
        self.message_event = GlobalEvent:getInstance():Bind(EliteSummonEvent.PresageSummon_Message,function(data)
            if not data then return end
            self.get_server_return = true
            self:setCountDownTime(self.time_text, data.time)
            self:tabChangeView(1)
            self:setLimitCount()
        end)
    end
    --刷新
    if not self.refersh_event then
        self.refersh_event = GlobalEvent:getInstance():Bind(EliteSummonEvent.PresageSummon_ReFresh,function(data)
        	self:setTouchChangeView()
	        self:openPineEffect()
        end)
    end
    --打开松果
    if not self.open_prine_event then
        self.open_prine_event = GlobalEvent:getInstance():Bind(EliteSummonEvent.PresageSummon_Open_Pine,function()
        	self:setTouchChangeView()
        	self:openPineEffect()
        end)
    end
    --购买物品返回
    if not self.buy_return_event then
        self.buy_return_event = GlobalEvent:getInstance():Bind(EliteSummonEvent.PresageSummon_Buy_Return,function()
        	self:setLimitCount()
        end)
    end

	registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
        if self.cur_index then
        	local config
        	if self.cur_index == 1 then
        		config = config_data["game_rule1"]
        	elseif self.cur_index == 2 then 
        		config = config_data["game_rule2"]
        	end
        	if config then
	        	TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
	        end
        end
    end, true,nil,nil,0.9)
    registerButtonEventListener(self.btn_buy, function()
    	if config_data then
	    	local data = config_data["item_price"].val
	    	local bid_id = config_data["item1"].val
	    	local setting = {}
	    	setting.view_type = ArenaConst.view_type.summon
	    	setting.item_bid = bid_id
	    	setting.item_price = data[1][2]
	        ArenaController:getInstance():openArenaLoopChallengeBuy(true, setting)
	    end
    end, true)
    --开启松果
	registerButtonEventListener(self.btn_open, function()
        if self.cur_index then
	        controller:send16694(self.cur_index)
	    end
    end, true)
    --刷新
	registerButtonEventListener(self.btn_reset, function()
		if self.cur_index then
			self:touchBtnReset()
		end
    end, true)
    registerButtonEventListener(self.btn_get, function()
    	self:btnGetRewardItem()
    end, true)
    registerButtonEventListener(self.btn_drop, function()
    	self:btnDropMessage()
    end, true)
    registerButtonEventListener(self.probabily_bg, function()
    	self.probablity:setVisible(false)
    end, false)

	for i,v in pairs(self.tab_view) do
		registerButtonEventListener(v.btn, function()
			if not self.get_server_return then
				message(TI18N("网络玩命加载中~~~~"))
				return
			end
	        self:tabChangeView(v.index)
	    end, false)
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
--点击刷新按钮延时2S,之后才能点击 标题按钮
function PresageSummonPanel:setTouchChangeView()
	if not self.tab_change_view then return end

	if self.tab_change_ticket == nil then
    self.tab_change_ticket = GlobalTimeTicket:getInstance():add(function()
            self.tab_change_view = true
            self:clearTabChangeTicket()
        end,2)
    end
    self.tab_change_view = nil
end
function PresageSummonPanel:clearTabChangeTicket()
	if self.tab_change_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.tab_change_ticket)
        self.tab_change_ticket = nil
    end
end
--点击刷新按钮
function PresageSummonPanel:touchBtnReset()
	local refresh_data = config_data["refresh"].val
	local role_vo = RoleController:getInstance():getRoleVo()
	local have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.item_pine_count)
	local data = config_data["item_price"].val
	if have_num <= 0 and role_vo.gold < data[1][2] then
		message(TI18N("钻石不足~~~~"))
		return
	end

	if not self.touch_btn_reset then return end
	if self.btn_reset_ticket == nil then
    self.btn_reset_ticket = GlobalTimeTicket:getInstance():add(function()
            self.touch_btn_reset = true
            if self.btn_reset_ticket ~= nil then
                GlobalTimeTicket:getInstance():remove(self.btn_reset_ticket)
                self.btn_reset_ticket = nil
            end
        end,2)
    end
    self.touch_btn_reset = nil
    --活动期间购买次数
    local count = EliteSummonController:getInstance():getModel():getbuyCount(self.cur_index)
	local totle_count = 0
	if self.cur_index == 1 then
		totle_count = config_data["buy_time1"].val
	elseif self.cur_index == 2 then
		totle_count = config_data["buy_time2"].val
	end

	--每天刷新次数
	local refresh_num = 0
	if self.cur_index == 1 then
		refresh_num = config_data["free_time1"].val
	elseif self.cur_index == 2 then
		refresh_num = config_data["free_time2"].val
	end
	local day_refresh_count = EliteSummonController:getInstance():getModel():getReFreshCount(self.cur_index)
	
	if count >= totle_count then
		local str
		if day_refresh_count < refresh_num then
			controller:send16691(self.cur_index)
		else
			if have_num > 0 then
				local data = config_data["item1"]
				str = string_format(TI18N("本次活动已无可购买次数，是否消耗<img src=%s visible=true scale=0.35 /><div fontColor=#289b14 fontsize= 26> 1</div> 继续刷新"),PathTool.getItemRes(data.val))
			else
				local data = config_data["item_price"].val
				str = string_format(TI18N("本次活动已无可购买次数，是否消耗<img src=%s visible=true scale=0.30 /><div fontColor=#289b14 fontsize= 26> %d</div> 继续刷新"),PathTool.getItemRes(data[1][1]), data[1][2])
			end
			if str then
				local function call_back()
		            controller:send16691(self.cur_index)
		        end
		        CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
		    end
		end
	else
		controller:send16691(self.cur_index)
	end
end
-- 刷新道具数量
function PresageSummonPanel:updateItemNum(bag_code, data_list)
    if self.item_pine_count and bag_code and data_list then
        if bag_code == BackPackConst.Bag_Code.BACKPACK then
            for i,v in pairs(data_list) do
                if v and v.base_id and self.item_pine_count == v.base_id then
                    local have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.item_pine_count)
                    if self.icon_count then
                        self.icon_count:setString(have_num)
                    end
                    self:setLimitCount()
                    self:setBtnRefreahData()
                end
            end
        end
    end
end
--直接获得物品
function PresageSummonPanel:btnGetRewardItem()
	if self.cur_index and self.buy_item_type then
    	if self.buy_item_type == 2 then
    		local prine_data = Config.HolidayPredictData.data_prize_pool[self.cur_index]

    		local have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.item_pine_count)
    		local _str = "松果币数量不足，"
    		local item_str = ""
    		local expend_gold = prine_data.expend_gold[1][2]
    		if have_num > 0 then
    			local price_data = config_data["item_price"].val
    			expend_gold = expend_gold - price_data[1][2] * have_num
    			local item_config = Config.ItemData.data_get_data(self.item_pine_count)
    			if item_config then
    				_str = ""
	    			item_str = string_format(TI18N("<img src=%s visible=true scale=0.30 /><div fontColor=#289b14 fontsize= 26>%d</div> 和 "),PathTool.getItemRes(item_config.icon),have_num)
	    		end
    		end

    		local str = string_format(TI18N("%s是否消耗 %s<img src=%s visible=true scale=0.30 /><div fontColor=#289b14 fontsize= 26>%d</div> 购买当前物品"),_str,item_str,PathTool.getItemRes(prine_data.expend_gold[1][1]), expend_gold)
    		local function call_back()
                controller:send16693(self.cur_index)
            end
            CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
    	else
	        controller:send16693(self.cur_index)
	    end
    end
end
--开启松果
function PresageSummonPanel:openPineEffect()
	doStopAllActions(self.actionNode)
	self:setEffectStatus_1(false)
	if self.pine_item then
    	for i,v in pairs(self.pine_item) do
    		if v then
        		v:setVisible(false)
        	end
    	end
    end
    if self.open_status_item then
    	for i,v in pairs(self.open_status_item) do
    		if v then
        		v:setVisible(false)
        	end
    	end
    end
    self.btn_open:setVisible(false)
    self.close_status:setVisible(true)
    local effect = {524,525}
	local openSingle = {}
    for i=1, 3 do
        local function test()
            local effect = createEffectSpine(PathTool.getEffectRes(effect[self.cur_index]),cc.p(self.pine_pos_x[i], self.pine_pos_y[i]),cc.p(0.5, 0.5),false, PlayerAction.action)
			self.close_status:addChild(effect)
        end
        openSingle[i] = cc.CallFunc:create(test)
    end

    self.actionNode = cc.Node:create()
    self.close_status:addChild(self.actionNode)
    local function func()
        self:IsActionStatus(1)
        self.tab_change_view = true
    end
    self.actionNode:runAction(cc.Sequence:create(openSingle[1],openSingle[2],openSingle[3],cc.DelayTime:create(0.3),cc.CallFunc:create(func),cc.RemoveSelf:create(true)))
end
--******** 设置倒计时
function PresageSummonPanel:setCountDownTime(node,less_time)
    if tolua.isnull(node) then return end
    doStopAllActions(node)

    local setTimeFormatString = function(time)
        if tolua.isnull(node) then return end
        node:setString(TimeTool.GetTimeFormatDayIIIIII(time))
    end
    if less_time > 0 then
        setTimeFormatString(less_time)
        node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            setTimeFormatString(less_time)
        end))))
    else
        setTimeFormatString(less_time)
    end
end
--掉落信息
function PresageSummonPanel:btnDropMessage()
	if not self.cur_index then return end
	self.probablity:setVisible(true)

	self:setDropProbalyData()
end
function PresageSummonPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
end

function PresageSummonPanel:DeleteMe()
	doStopAllActions(self.time_text)
	doStopAllActions(self.actionNode)
	for i,v in pairs(self.effect_status_1) do
		if v then
			v:clearTracks()
			v:removeFromParent()
			v = nil
		end
	end
	if self.resources_load then
		self.resources_load:DeleteMe()
		self.resources_load = nil
	end
	if self.probably_item_scrollview then
        self.probably_item_scrollview:DeleteMe()
        self.probably_item_scrollview = nil
    end
	self:clearTabChangeTicket()
	if self.btn_reset_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.btn_reset_ticket)
        self.btn_reset_ticket = nil
    end
	self.effect_status_1 = {}
	if self.message_event then
        GlobalEvent:getInstance():UnBind(self.message_event)
        self.message_event = nil
    end
    if self.refersh_event then
        GlobalEvent:getInstance():UnBind(self.refersh_event)
        self.refersh_event = nil
    end
    if self.buy_return_event then
        GlobalEvent:getInstance():UnBind(self.buy_return_event)
        self.buy_return_event = nil
    end
    if self.open_prine_event then
        GlobalEvent:getInstance():UnBind(self.open_prine_event)
        self.open_prine_event = nil
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

	if self.bg_load then
		self.bg_load:DeleteMe()
		self.bg_load = nil
	end
	for i,v in pairs(self.reward_item) do
		if v then 
	       v:DeleteMe()
	       v = nil
	    end
	end
	for i,v in pairs(self.open_status_item) do
		if v then 
	       v:DeleteMe()
	       v = nil
	    end
	end
	for i,v in pairs(self.round_bg_load) do
        if v and v.DeleteMe then
            v:DeleteMe()
        end
        v = nil
    end

end

--******************************
local name_color = cc.c4b(0x4c,0xd8,0x49,0xff)
--掉落展示
PresageSummonItem = class("PresageSummonItem", function()
    return ccui.Widget:create()
end)

PresageSummonItem.width = 250
PresageSummonItem.height = 30
function PresageSummonItem:ctor()
    self:configNumberUI()
end

function PresageSummonItem:configNumberUI()
    self:setContentSize(cc.size(PresageSummonItem.width, PresageSummonItem.height))
end

function PresageSummonItem:setData(data)
    if not data then return end
    if not self.name_text then
        self.name_text = createRichLabel(26, name_color, cc.p(0, 0.5), cc.p(0, 15), nil, nil, 250)
        self:addChild(self.name_text)
    end
	local txt_str = string_format(TI18N("%s<div fontColor=#ffa72a fontsize= 26> *%d</div>"), data.name, data.num)
    self.name_text:setString(txt_str)
end
function PresageSummonItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end

