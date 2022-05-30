--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 限时试炼之境挑战界面
-- @DateTime:    2019-05-30 10:28:59
-- *******************************
LimitExerciseChangeWindow = LimitExerciseChangeWindow or BaseClass(BaseView)

local controller = LimitExerciseController:getInstance()
local model = controller:getModel()
local change_boss_list = Config.HolidayBossNewData.data_change_boss_list
local reward_list = Config.HolidayBossNewData.data_lev_reward_list

local math_floor = math.floor
local math_abs = math.abs
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format
local pos_interval = {{0,320},{320,1047},{1047,1500}}
--挑战次数
local fight_count = Config.HolidayBossNewData.data_const.start_fight_count.val
local color_text = {
	[1] = cc.c4b(0x64,0x32,0x23,0xff),
	[2] = cc.c4b(0x6C,0x2B,0x00,0xff),
}

function LimitExerciseChangeWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full 
    self.layout_name = "limitexercise/limitexercise_change_window"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("limitexercise","limitexercise"), type = ResourcesType.plist }
    }
    self.cur_order_type = nil
    self.cur_order_id = nil
    self.cur_box_status = nil
    self.scrollview_bar = nil
end

function LimitExerciseChangeWindow:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
	local main_container = self.root_wnd:getChildByName("main_container")
        self:playEnterAnimatianByObj(main_container , 1) 
	local load_bg = main_container:getChildByName("bg")
	local bg_res = PathTool.getPlistImgForDownLoad("bigbg/limitexercise", "limit_exercise_bg1")
    if not self.change_load_bg then
        self.change_load_bg = loadSpriteTextureFromCDN(load_bg, bg_res, ResourcesType.single, self.change_load_bg)
        load_bg:setScale(display.getMaxScale())
    end
    main_container:getChildByName("Text_10"):setString(TI18N("本轮挑战剩余："))
    self.ramain_time = main_container:getChildByName("ramain_time")
	self.ramain_time:setString("")
    self.level_area_text = main_container:getChildByName("level_area_text")
    self.level_area_text:setString("")

    --左边滑动
    self.left_scrollview_pos = {}
    for i=1,3 do
    	local spr = main_container:getChildByName("sroll_spr_"..i)
    	self.left_scrollview_pos[i] = spr:getPositionY()
    end
    self.sroll_main_spr = main_container:getChildByName("sroll_main_spr")
    self.sroll_main_spr:setOpacity(0)
    --难度
    self.level_num = main_container:getChildByName("level_num")
    self.level_num:setString("")
	main_container:getChildByName("level_area_text_0_0"):setString(TI18N("难度"))

    self.item_area = main_container:getChildByName("item_area")
    --关卡信息
    self.level_msg = main_container:getChildByName("level_msg")
    self.btn_change = self.level_msg:getChildByName("btn_change")
    self.btn_change_text = self.btn_change:getChildByName("Text_4")
    self.btn_change_text:setString(TI18N("挑战"))
    self.btn_box = self.level_msg:getChildByName("btn_box")
    self.box_sprite = self.btn_box:getChildByName("box_sprite")
    self.box_sprite:setAnchorPoint(0.5,0.5)
    self.box_sprite:setPositionY(49)
	self.level_msg:getChildByName("Text_8"):setString(TI18N("下一阶段奖励"))
	self.level_text = self.level_msg:getChildByName("level_text") --第几关
    self.level_text:setString("")

    self.level_msg:getChildByName("level_tips_text"):setString(TI18N("关卡效果"))
    self.level_effect_desc = createRichLabel(22, color_text[1], cc.p(0,0.5), cc.p(229,130), nil, nil, 500)
	self.level_msg:addChild(self.level_effect_desc)
	self.power = self.level_msg:getChildByName("power")
	self.power:setString(TI18N("推荐战力："))
    self.change_item = self.level_msg:getChildByName("change_item")
    self.change_item:setScrollBarEnabled(false)
    
    self.btn_rule = main_container:getChildByName("btn_rule")
    self.btn_rule:setScale(0.8)
    local bottom_panel = main_container:getChildByName("bottom_panel")
    bottom_panel:getChildByName("count_title"):setString(TI18N("挑战次数:"))
    self.remain_count = bottom_panel:getChildByName("remain_count")
    self.remain_count:setString("剩余购买次数：")
    self.change_count = bottom_panel:getChildByName("count_label")
    self.change_count:setString("")

    self.add_btn = bottom_panel:getChildByName("add_btn")
    self.btn_close = bottom_panel:getChildByName("btn_close")
end
function LimitExerciseChangeWindow:openRootWnd()
	self:createAreaList()
	if model:getLimitExerciseData() == nil then
		controller:send25410()
	else
		local data = model:getLimitExerciseData()
		self:setRoundHero(data.difficulty,data.count)
		self:remainBuyCount(data.buy_count)
		self:setCountDownTime(self.ramain_time,data.endtime - GameNet:getInstance():getTime())
		self:levelBoxStatus(data.status,data.order)
		self:showBossMessageItem(data.difficulty)

		local container_y = self.item_innercontainer:getPositionY()
		local cur_pos = self:getCurrentPos(math_abs(container_y))
		self:scrollviewSprintBar(cur_pos)
	end
	controller:send25414()
end

--创建区域
function LimitExerciseChangeWindow:createAreaList()
	if not self.item_scrollview then
		local scroll_view_size = self.item_area:getContentSize()
	    local setting = {
	        start_x = 0,                  -- 第一个单元的X起点
	        space_x = 0,                    -- x方向的间隔
	        start_y = 0,                    -- 第一个单元的Y起点
	        space_y = 0,                   -- y方向的间隔
	        item_width = 720,               -- 单元的尺寸width
	        item_height = LimitExerciseChangeItem.HeightItem,              -- 单元的尺寸height
	        row = 0,                        -- 行数，作用于水平滚动类型
	        col = 1,                         -- 列数，作用于垂直滚动类型
	        need_dynamic = true,
	        checkovercallback = handler(self, self.updateSlideShowByVertical)
	    }
	    self.item_scrollview = CommonScrollViewSingleLayout.new(self.item_area, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.bottom, scroll_view_size, setting)
	    self.item_scrollview:setSwallowTouches(true)
	    self.item_innercontainer = self.item_scrollview:getContainer()

	    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createAreaChangeCell), ScrollViewFuncType.CreateNewCell) --创建cell
	    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfAreaChangeCells), ScrollViewFuncType.NumberOfCells) --获取数量
	    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateAreaChangeCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
	    self.item_scrollview:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
	end
end

--显示boss信息  轮次，难度
function LimitExerciseChangeWindow:showBossMessageItem(diff)
	round = model:getCurrentRound()
	diff = diff or 1
	if self.item_scrollview then
		if change_boss_list[round] and change_boss_list[round][diff] then
			self.area_list = {}
			for i,v in pairs(change_boss_list[round][diff]) do
				table_insert(self.area_list,v)
			end
			local level_type = model:getCurrentType()
			local count = 1
			if level_type then
				count = level_type
			end
			self.item_scrollview:reloadData(count)
			self.sroll_main_spr:setPositionY(self.left_scrollview_pos[count])
		end
	end
end

function LimitExerciseChangeWindow:createAreaChangeCell()
	local cell = LimitExerciseChangeItem.new()
	cell:addCallBack(function(order_type,order_id,index) self:onCellTouched(cell,order_type,order_id,index) end)
    return cell
end

--点击cell .需要在 createNewCell 设置点击事件
function LimitExerciseChangeWindow:onCellTouched(cell,order_type,order_id,index)
	if not cell.index then return end
    local cell_data = self.area_list[cell.index]
    if not cell_data then return end

    self.view_order_type = order_type
    self.view_order_id = order_id

	local all_item = self.item_scrollview:getActiveCellList()
	for i,item in pairs(all_item) do
		item:setTouchKuangVisible(false)
	end
	self.select_index = cell.index
	cell:setTouchKuangPos(true)

    self:getLevelMessage(order_type,order_id)
end
function LimitExerciseChangeWindow:numberOfAreaChangeCells()
	if not self.area_list then return 0 end
    return #self.area_list
end
function LimitExerciseChangeWindow:updateAreaChangeCellByIndex(cell, index)
	cell.index = index
	if not self.area_list then return end
    local cell_data = self.area_list[index]
    if not cell_data then return end
    cell:setData(cell_data)

    if self.view_order_type == nil or self.view_order_id == nil then
    	cell:setItemIndex()
    end

    if self.select_index and self.select_index == index then
	    cell:setTouchKuangPos(true)
    else
    	cell:setTouchKuangPos(false)
	end
end

--滑动的时候处理显示
function LimitExerciseChangeWindow:updateSlideShowByVertical()
	local container_y = self.item_innercontainer:getPositionY()
	if self.item_scrollview then
		local cur_pos = self:getCurrentPos(math_abs(container_y))
		self:scrollviewSprintBar(cur_pos)
		self.level_area_text:setString(LimitExerciseConstants.type[cur_pos])
	end
end
--滑动的动作处理
function LimitExerciseChangeWindow:scrollviewSprintBar(cur_pos)
	if self.scrollview_bar == cur_pos then return end
	self.scrollview_bar = cur_pos

	doStopAllActions(self.sroll_main_spr)

	local fadeout = cc.FadeOut:create(0.3)
	local fadein = cc.FadeIn:create(0.3)
	local move_to = cc.MoveTo:create(0.001,cc.p(41, self.left_scrollview_pos[cur_pos]))
	local scaleto1 = cc.ScaleTo:create(0.1, 1.2)
	local scaleto2 = cc.ScaleTo:create(0.1, 1)
	local spawn = cc.Spawn:create(fadein,move_to)
	local seq = cc.Sequence:create(fadeout,spawn,scaleto1,scaleto2)
 	self.sroll_main_spr:runAction(seq)
end

--判断当前位置
function LimitExerciseChangeWindow:getCurrentPos(pos)
	local cur_pos = 1
	if pos >= pos_interval[1][1] and pos <= pos_interval[1][2] then
		cur_pos = 1
	elseif pos >= pos_interval[2][1] and pos <= pos_interval[2][2] then
		cur_pos = 2
	elseif pos >= pos_interval[3][1] and pos <= pos_interval[3][2] then
		cur_pos = 3
	end
	return cur_pos
end

--关卡信息  (关卡类型、关卡id)
function LimitExerciseChangeWindow:getLevelMessage(ord_type,ord_id)
	ord_type = ord_type or 1
	ord_id = ord_id or model:getCurrentChangeID()
	if self.cur_order_type == ord_type and self.cur_order_id == ord_id then
		return
	end
	local round = model:getCurrentRound()
	local diff = model:getCurrentDiff()
	if not round then return end

	self.level_area_text:setString(LimitExerciseConstants.type[ord_type])

	if change_boss_list[round] and change_boss_list[round][diff] then
		local lev_data = change_boss_list[round][diff]
		
		if ord_id >= 15 then ord_id = 15 end
		if lev_data[ord_type] and lev_data[ord_type][ord_id] then
			local lev_count = lev_data[ord_type][ord_id].order_id
			self.level_text:setString(TI18N("第")..lev_count..TI18N("关"))

			if lev_count == model:getCurrentChangeID() then
				setChildUnEnabled(false, self.btn_change)
				self.btn_change:setTouchEnabled(true)
				self.btn_change_text:enableOutline(color_text[2], 2)
			else
				setChildUnEnabled(true, self.btn_change)
				self.btn_change:setTouchEnabled(false)
				self.btn_change_text:disableEffect(cc.LabelEffect.OUTLINE)
			end

			local str = ""
			local desc = lev_data[ord_type][ord_id].add_skill_decs or {}
			for i=1, #desc do
				str = str..desc[i].."\n"
			end
			self.level_effect_desc:setString(str)
			local power = lev_data[ord_type][ord_id].power or 0
			self.power:setString(TI18N("推荐战力：")..power)

			if self.cur_order_type ~= ord_type then
				local count = self:getBoxRewardID(ord_id)
				if reward_list[diff] and reward_list[diff][count] then
					--获取奖励
					local data_list = reward_list[diff][count].reward or {}
				    local setting = {}
				    setting.scale = 0.6
				    setting.max_count = 3
				    setting.is_center = true
				    setting.show_effect_id = 263
				    self.level_item_list = commonShowSingleRowItemList(self.change_item, self.level_item_list, data_list, setting)
				end
			end
		end
	end
	self.cur_order_type = ord_type
	self.cur_order_id = ord_id
end

--根据当前关数来显示宝箱的奖励
function LimitExerciseChangeWindow:getBoxRewardID(ord_id)
	local diff = model:getCurrentDiff()
	local count = 1
	if reward_list[diff] then
		for i=1,3 do
			if ord_id <= reward_list[diff][1].order_id then
				count = 1
			elseif ord_id > reward_list[diff][1].order_id and ord_id <= reward_list[diff][2].order_id then
				count = 2
			elseif ord_id > reward_list[diff][2].order_id then
				count = 3
			end
		end
	end
	return count
end

--宝箱状态
function LimitExerciseChangeWindow:levelBoxStatus(status,ord_id)
	if self.cur_box_status == status then return end

	self.cur_box_status = status

	local id = self:getBoxRewardID(ord_id)
   	loadSpriteTexture(self.box_sprite,PathTool.getResFrame("limitexercise","limitexercise_box"..id),LOADTEXT_TYPE_PLIST)

   	if status == 1 then
   		doStopAllActions(self.box_sprite)
		local skewto_1 = cc.RotateTo:create(0.1, 10)
		local skewto_2 = cc.RotateTo:create(0.1, -10)
		local skewto_3 = cc.RotateTo:create(0.1, 0)
		local seq = cc.Sequence:create(skewto_1,skewto_2, skewto_1,skewto_2, skewto_1,skewto_2,skewto_3,cc.DelayTime:create(1))
		local repeatForever = cc.RepeatForever:create(seq)
	    self.box_sprite:runAction(repeatForever)
	elseif status == 2 then
		doStopAllActions(self.box_sprite)
	end
end

function LimitExerciseChangeWindow:register_event()
	self:addGlobalEvent(LimitExerciseEvent.LimitExercise_Message_Event, function(data)
		self:setRoundHero(data.difficulty,data.count)
		self:remainBuyCount(data.buy_count)
		self:setCountDownTime(self.ramain_time,data.endtime - GameNet:getInstance():getTime())
		self:levelBoxStatus(data.status,data.order)
		self:showBossMessageItem(data.difficulty)
		self:getLevelMessage(data.order_type,data.order)
	end)

	self:addGlobalEvent(LimitExerciseEvent.LimitExercise_GetBox_Event, function(data)
		if data then
			if data.code == 1 then
				self:levelBoxStatus(2,15)
			end
		end
	end)

	self:addGlobalEvent(LimitExerciseEvent.LimitExercise_BuyCount_Event,function(data)
		if data then
			local difficulty = model:getCurrentDiff()
			self:setRoundHero(difficulty,data.count)
			self:remainBuyCount(data.buy_count)
		end
	end)

	registerButtonEventListener(self.btn_close, function()
		controller:openLimitExerciseChangeView(false)
	end, true,2)

	registerButtonEventListener(self.btn_change, function()
		HeroController:getInstance():openFormGoFightPanel(true,PartnerConst.Fun_Form.LimitExercise)
	end, true)

	registerButtonEventListener(self.btn_rule, function()
		MainuiController:getInstance():openCommonExplainView(true, Config.HolidayBossNewData.data_explain,TI18N("规则说明"))
	end, true,1,nil,0.8)

	registerButtonEventListener(self.btn_box, function()
		if model:getBoxStatus() == 1 then
			controller:send25412()
		else
			controller:openLimitExerciseRewardView(true)
		end
	end, true)

	registerButtonEventListener(self.add_btn, function()
		local const_data = Config.HolidayBossNewData.data_const
		if not const_data then return end
		local cur_count = model:getDayBuyCount()
		local max_count = const_data.fight_buy_max_count.val
		if cur_count >= max_count then
			message(TI18N("已达今日购买最大值"))
			return
		end

		local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(3).icon)
		local str = string_format(TI18N("是否花费 <img src='%s' scale=0.3 />%s购买一次挑战次数？"), iconsrc, const_data.action_num_espensive.val)
        local call_back = function()
            controller:send25411()
        end
        CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
	end, true)
end
--剩余购买次数
function LimitExerciseChangeWindow:remainBuyCount(buy_count)
	buy_count = buy_count or 0
	if self.remain_count then
		local count = 0
		local const_data = Config.HolidayBossNewData.data_const.fight_buy_max_count
		if const_data and const_data.val then
			count = const_data.val - buy_count
			if count <= 0 then
				count = 0
			end
			self.remain_count:setString("剩余购买次数："..count)
		end
	end
end


--购买次数
function LimitExerciseChangeWindow:setRoundHero(change_id,count)
	self.level_num:setString(change_id or 1)
	self.change_count:setString(count or 0)
end
--******** 设置倒计时
function LimitExerciseChangeWindow:setCountDownTime(node,less_time)
    if tolua.isnull(node) then return end
    doStopAllActions(node)
    if less_time > 0 then
        self:setTimeFormatString(node,less_time)
        node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                doStopAllActions(node)
                node:setString("00:00:00")
            else
                self:setTimeFormatString(node,less_time)
            end
        end))))
    else
        self:setTimeFormatString(node,less_time)
    end
end
function LimitExerciseChangeWindow:setTimeFormatString(node,time)
    if time > 0 then
        node:setString(TimeTool.GetTimeFormatDay(time))
    else
        doStopAllActions(node)
        node:setString("00:00:00")
    end
end
--*************************
function LimitExerciseChangeWindow:close_callback()
	if self.change_load_bg then
        self.change_load_bg:DeleteMe()
    end
    self.change_load_bg = nil
    doStopAllActions(self.ramain_time)
    doStopAllActions(self.box_sprite)
    doStopAllActions(self.sroll_main_spr)
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.level_item_list then
        for i,v in pairs(self.level_item_list) do
            v:DeleteMe()
        end
        self.level_item_list = nil
    end
    controller:openLimitExerciseChangeView(false)
end

--******************************
--挑战子项
LimitExerciseChangeItem = class("LimitExerciseChangeItem", function()
    return ccui.Widget:create()
end)

LimitExerciseChangeItem.HeightItem = 568
function LimitExerciseChangeItem:ctor()
	self.btn_master = {}
    self:configUI()
    self:register_event()
end

function LimitExerciseChangeItem:configUI()
	self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("limitexercise/limitexercise_change_item"))
    self:addChild(self.root_wnd)
    self:setContentSize(cc.size(720,LimitExerciseChangeItem.HeightItem))
    local main_container = self.root_wnd:getChildByName("main_container")

    self.touch_kuang = main_container:getChildByName("touch_kuang")

    for i=1,5 do
    	local tab = {}
    	tab.btn = main_container:getChildByName("btn_master_"..i)

    	tab.hero_item = HeroExhibitionItem.new(0.9, true, 0, false)
    	tab.hero_item:addCallBack(function() self:onClickHeroItem(i) end)
		tab.hero_item:setPosition(49, 49)
		tab.btn:addChild(tab.hero_item)
		
		tab.name = tab.btn:getChildByName("name")
		tab.name:setString("")

		tab.bar = tab.btn:getChildByName("bar")
		tab.bar:setScale9Enabled(true)
		tab.bar:setPercent(0)
		tab.bar_num = tab.btn:getChildByName("bar_num")		
		tab.bar_num:setString("")

		tab.kill_spr = tab.btn:getChildByName("kill_spr")
		tab.kill_spr:setLocalZOrder(10)
		tab.kill_spr:setVisible(false)
		tab.lock_spr = tab.btn:getChildByName("lock_spr")
		tab.lock_spr:setLocalZOrder(10)
		tab.lock_spr:setVisible(false)
		if i == 5 then
			local boss_spr = tab.btn:getChildByName("boss_spr")
			boss_spr:setLocalZOrder(10)
		end

		tab.index = i
	    self.btn_master[i] = tab
	end
end
function LimitExerciseChangeItem:setTouchKuangPos(status)
	if self.touch_kuang then
		if status then
			if self.item_index then
				local x = self.btn_master[self.item_index].btn:getPositionX() - 25
				local y = self.btn_master[self.item_index].btn:getPositionY() - 4
				self.touch_kuang:setPosition(x,y)
				self.touch_kuang:setVisible(true)
			end
		else
			self.touch_kuang:setVisible(false)
		end
	end
end

function LimitExerciseChangeItem:setTouchKuangVisible(visible)
	if self.touch_kuang then
		self.touch_kuang:setVisible(visible)
	end
end

function LimitExerciseChangeItem:setData(data)
	if not data then return end

	self:setGuardData(data)
end

function LimitExerciseChangeItem:setGuardData(data)
	local list = {}
	for i,v in pairs(data) do
		table_insert(list,v)
	end
	table_sort(list,function(a,b) return a.sort_id < b.sort_id end)
	
	self.data = data
	for i=1,#list do
		if self.btn_master[i] then
			self.btn_master[i].hero_item:setHeadImg(list[i].head_id)
			self.btn_master[i].hero_item:setQualityImg(list[i].star)
			self.btn_master[i].hero_item:setLev(list[i].master_lev)
			self.btn_master[i].name:setString(list[i].name)

			local hp,level_status = self:getHeroHp(list[i].order_id)
			self.btn_master[i].bar_num:setString(string_format("%d%%",hp))
			self.btn_master[i].bar:setPercent(hp)

			if level_status == true then
				self.btn_master[i].lock_spr:setVisible(false)
			else
				self.btn_master[i].lock_spr:setVisible(hp==100)
			end
			self.btn_master[i].kill_spr:setVisible(hp==0)
			setChildUnEnabled(hp==0, self.btn_master[i].hero_item)
		end
	end
end
--获取当前血量
--[[
关卡id的血量显示：少于正在挑战的为100，，大于为0，，
]]
function LimitExerciseChangeItem:getHeroHp(order_id)
	local cur_level = model:getCurrentChangeID()
	local cur_hp = model:getCurrentBossHp()
	if not cur_level or not cur_hp then return 0 end

	local hp_num = 0
	local level_status = false
	if order_id < cur_level then
		hp_num = 0
	elseif order_id == cur_level then
		hp_num = cur_hp*0.001
		level_status = true
	elseif order_id > cur_level then
		hp_num = 100
	end
	return hp_num,level_status
end
function LimitExerciseChangeItem:onClickHeroItem(pos)
	self:funcCallBack(self.data,pos)
end
function LimitExerciseChangeItem:register_event()
	if self.data then
		for i,v in pairs(self.btn_master) do
			registerButtonEventListener(v.btn, function()
				self:funcCallBack(self.data,v.index)
			end, false)
		end
	end
end

function LimitExerciseChangeItem:funcCallBack(data,index)
	if not data then return end

	if self.callback then
		local order_type,order_id
		for i,item in pairs(data) do
			if item.sort_id == index then
				order_type = item.order_type
				order_id = item.order_id
				break
			end
		end
		if order_type and order_id then
			self.item_index = index
	        self.callback(order_type,order_id,index)
	    end
    end
end
function LimitExerciseChangeItem:setItemIndex()
	--默认点击的位置
	local init_index = 1
	local cur_change = model:getCurrentChangeID()
	if self.data and cur_change then
		for i,v in pairs(self.data) do
			if v.order_id == cur_change then
				init_index = v.sort_id
				break
			end
		end
	end
	self.item_index = init_index
end

function LimitExerciseChangeItem:addCallBack(callback)
    self.callback = callback
end
function LimitExerciseChangeItem:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end

