--******** 文件说明 ********
-- @Author:      xhj 
-- @description: 位面战令
-- @DateTime:    2020-2-13
-- *******************************
PlanesafkOrderactionWindow = PlanesafkOrderactionWindow or BaseClass(BaseView)

local controller = PlanesafkController:getInstance()
local model = controller:getModel()
local controll_action = ActionController:getInstance()
local lev_reward_list = Config.PlanesWarOrderData.data_lev_reward_list
local table_sort = table.sort
local table_insert = table.insert
function PlanesafkOrderactionWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full

    self.layout_name = "planesafk/planesafk_orderaction_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("planesafkorderaction", "planesafkorderaction"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("planes","planes_bg",true), type = ResourcesType.single},
    }
    
    self.reward_list = {}
end

function PlanesafkOrderactionWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    if self.background ~= nil then
    	self.background:loadTexture(PathTool.getPlistImgForDownLoad("planes","planes_bg",true), LOADTEXT_TYPE)
    end
    self.top_bg = self.root_wnd:getChildByName("top_bg")
	self.bottom_bg = self.root_wnd:getChildByName("bottom_bg")
    self.main_container = self.root_wnd:getChildByName("main_container")

    self:playEnterAnimatianByObj(self.main_container , 1)

    --解锁奖励总览
    self.btn_open_lock = self.main_container:getChildByName("btn_open_lock")
    self.btn_open_lock_label = self.btn_open_lock:getChildByName("name")
    self.btn_open_lock_label:setString(TI18N("解锁征战之证"))
   
    
    --前往战斗
    self.btn_go = self.main_container:getChildByName("btn_go")
    self.btn_go_lab = self.btn_go:getChildByName("name")
    self.btn_go_lab:setString(TI18N("前往"))

    --活动时间与领取
    self.main_container:getChildByName("time_title"):setString(TI18N("重置时间："))
    self.time_text = self.main_container:getChildByName("time_text")
    self.time_text:setString("")
    
    self.btn_rule = self.main_container:getChildByName("btn_rule")
    self.btn_rule_2 = self.main_container:getChildByName("btn_rule_2")
    self.btn_rule_2:setVisible(false)
    self.btn_close = self.main_container:getChildByName("btn_close")
    
    self.main_container:getChildByName("level_title"):setString(TI18N("通关积分："))
    self.level_num = self.main_container:getChildByName("level_num")
    self.level_num:setString("")
    
    self.icon_img = self.main_container:getChildByName("icon_img")

    self.main_container:getChildByName("Text_33"):setString(TI18N("位面征战击败每层BOSS即可获得通关积分"))
    
    
    local goods_item = self.main_container:getChildByName("goods_item")
    local scroll_view_size = goods_item:getContentSize()
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 720,               -- 单元的尺寸width
        item_height = 139,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
        checkovercallback = handler(self, self.updateSlideShowByVertical)
    }
    self.reward_goods_item = CommonScrollViewSingleLayout.new(goods_item, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.reward_goods_item:setSwallowTouches(true)

    self.reward_goods_item:registerScriptHandlerSingle(handler(self,self.createTaskCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.reward_goods_item:registerScriptHandlerSingle(handler(self,self.numberOfTaskCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.reward_goods_item:registerScriptHandlerSingle(handler(self,self.updateTaskCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    local scroll_view_size2 = cc.size(100,scroll_view_size.height)
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 100,               -- 单元的尺寸width
        item_height = 139,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
    }
    self.reward_num_item = CommonScrollViewSingleLayout.new(goods_item, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size2, setting)
    self.reward_num_item:setClickEnabled(false)

    self.reward_num_item:registerScriptHandlerSingle(handler(self,self.createTaskCell2), ScrollViewFuncType.CreateNewCell) --创建cell
    self.reward_num_item:registerScriptHandlerSingle(handler(self,self.numberOfTaskCells2), ScrollViewFuncType.NumberOfCells) --获取数量
    self.reward_num_item:registerScriptHandlerSingle(handler(self,self.updateTaskCellByIndex2), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    self:createProgress()
    self:adaptationScreen()
end

--设置适配屏幕
function PlanesafkOrderactionWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.container)
    local bottom_y = display.getBottom(self.container)

	self.top_bg:setPositionY(top_y)
	self.bottom_bg:setPositionY(bottom_y)
    
end

--进度条
function PlanesafkOrderactionWindow:createProgress()
    if self.comp_bar == nil then
        local size = cc.size(315, 27)
        local res = PathTool.getResFrame("planesafkorderaction","planesafkaction_4")
        local res1 = PathTool.getResFrame("planesafkorderaction","planesafkaction_7")
        if self.reward_goods_item and not tolua.isnull(self.reward_goods_item) and self.reward_goods_item.container and not tolua.isnull(self.reward_goods_item.container) then
            local bar_layout = ccui.Layout:create()
            bar_layout:setContentSize(cc.size(27,27))
            bar_layout:setAnchorPoint(0,0)
            bar_layout:setRotation(90)
            if bar_layout then
                self.reward_goods_item.container:addChild(bar_layout,999)	
                self.bar_layout = bar_layout
            end

            local bg,comp_bar = createLoadingBar(res, res1, size, self.bar_layout, cc.p(0,0.5), 0, 0, true, true)
            
            self.comp_bar_bg = bg
            self.comp_bar = comp_bar
        end
    end
end

function PlanesafkOrderactionWindow:updatePercent(win_count)
    if tolua.isnull(self.comp_bar) or not win_count then
        return
    end
    local cur_period = model:getCurPeriod()
    if lev_reward_list and lev_reward_list[cur_period] then
        local award_config = lev_reward_list[cur_period]
        -- 计算进度条
        local last_lev = 0
        local progress_width = self.bar_layout:getContentSize().width
        local first_off = 0 -- 0到第一个的距离
        local distance = 0
        local offset_y = (progress_width + 0)/(#award_config-1)
        for i,v in ipairs(award_config) do
            if i == 1 then
                if win_count <= v.win_count then
                    distance = (win_count/v.win_count)*first_off
                    break
                else
                    distance = first_off
                end
            else
                if win_count <= v.win_count then
                    distance = distance + ((win_count-last_lev)/(v.win_count-last_lev))*offset_y
                    break
                else
                    distance = distance + offset_y
                end
            end
            last_lev = v.win_count
        end
        self.comp_bar:setPercent(distance/progress_width*100)
    end
    
    
end

function PlanesafkOrderactionWindow:register_event()
    self:addGlobalEvent(PlanesafkEvent.Planesafk_OrderAction_Init_Event, function(data)
        self:setBasicInitData(data)
        local time = data.end_time - GameNet:getInstance():getTime()
        controll_action:getModel():setCountDownTime(self.time_text,time)
    end)

    self:addGlobalEvent(PlanesafkEvent.Planesafk_OrderAction_IsPopWarn_Event, function(data)
        if data then
            local cur_period = model:getCurPeriod()
            local period_day_cof = Config.PlanesWarOrderData.data_period_day[cur_period]
            if period_day_cof then
                local totle_day = period_day_cof.period_day
                if (totle_day - data.cur_day) == 7 or (totle_day - data.cur_day) == 3 or (totle_day - data.cur_day) == 0 then
                    if data.is_pop == 1 then
                        controller:openPlanesafkEndWarnView(true,data.cur_day)
                    end
                end
            end
            
        end
    end)

    registerButtonEventListener(self.btn_open_lock, function()
        controller:openBuyCardView(true)
    end,true, 1)

    registerButtonEventListener(self.btn_go, function()
        controller:openPlanesafkOrderactionWindow(false)
        JumpController:getInstance():jumpViewByEvtData({68})
    end,true, 1)
    
    registerButtonEventListener(self.btn_close, function()
        controller:openPlanesafkOrderactionWindow(false)
    end,true, 2)

    registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
        local config = Config.PlanesWarOrderData.data_constant
        if config then
            local config_desc = config.rule_desc
            TipsManager:getInstance():showCommonTips(config_desc.desc, sender:getTouchBeganPosition(),nil,nil,500)
        end
    end ,false, 1)
    registerButtonEventListener(self.btn_rule_2, function(param,sender, event_type)
        local config = Config.PlanesWarOrderData.data_constant
        if config then
            local config_desc = config.rule_desc_2
            TipsManager:getInstance():showCommonTips(config_desc.desc, sender:getTouchBeganPosition(),nil,nil,500)
        end
    end ,false, 1)
    
end

--奖励列表
function PlanesafkOrderactionWindow:createTaskCell()
	local cell = PlanesafkOrderActiodRewardItem.new()
    return cell
end
function PlanesafkOrderactionWindow:numberOfTaskCells()
	if not self.reward_list then return 0 end
    return #self.reward_list
end
function PlanesafkOrderactionWindow:updateTaskCellByIndex(cell, index)
	if not self.reward_list then return end
    local cell_data = self.reward_list[index]
    if not cell_data then return end

    cell:setData(cell_data)
end

--滑动的时候处理显示
function PlanesafkOrderactionWindow:updateSlideShowByVertical()
	local container_y = self.reward_goods_item:getCurContainerPosY()
	if container_y and self.reward_num_item and not tolua.isnull(self.reward_num_item) then
        if self.reward_num_item.container and not tolua.isnull(self.reward_num_item.container) then
            self.reward_num_item.container:setPositionY(container_y)
            self.reward_num_item:checkRectIntersectsRect()
        end
	end
end

--胜利数列表
function PlanesafkOrderactionWindow:createTaskCell2()
	local cell = PlanesafkOrderActiodRewardItem2.new()
    return cell
end
function PlanesafkOrderactionWindow:numberOfTaskCells2()
	if not self.reward_list then return 0 end
    return #self.reward_list
end
function PlanesafkOrderactionWindow:updateTaskCellByIndex2(cell, index)
	if not self.reward_list then return end
    local cell_data = self.reward_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function PlanesafkOrderactionWindow:updateIconImg(status)
    if tolua.isnull(self.icon_img) or tolua.isnull(self.btn_open_lock) then
        return
    end
    loadSpriteTexture(self.icon_img, PathTool.getResFrame("planesafkorderaction","planesafkaction_14"), LOADTEXT_TYPE_PLIST)   
    
    if status == 1 then 
        setChildUnEnabled(false,self.icon_img)
    else
        setChildUnEnabled(true,self.icon_img)
    end

	if status == 1 then
        self.btn_open_lock:setVisible(false)
    else
        self.btn_open_lock:setVisible(true)
    end
end

function PlanesafkOrderactionWindow:jumpToMoveByY(y)
    if not y then return end
    local pos = y
    if pos < 0 then
        pos = 0
    end

    local len = #self.reward_list or 1
    local pos_per = pos * 100 / (len* 139)
    if pos_per > 100 then
        pos_per = 100
    end
    self.reward_goods_item:scrollToPercentVertical(pos_per, 0.5, true)
end

--当等级变化的时候
function PlanesafkOrderactionWindow:setChangeLevelStatus(cur_lev)
    local cur_period = model:getCurPeriod()
	if lev_reward_list and lev_reward_list[cur_period] then
    	self.reward_list = {}
	    for i,v in pairs(lev_reward_list[cur_period]) do
            v.cur_lev = cur_lev
	    	v.status = 0
	    	v.rmb_status = 0
	    	v.is_locak = model:getGiftStatus()
	    	local lev_list = model:getLevShowData(v.lev)
	    	if lev_list then
		    	v.status = lev_list.award_status
	    		v.rmb_status = lev_list.rmb_award_status
		    end
            table_insert(self.reward_list,v)
            
	    end
        if next(self.reward_list) == nil then
            self.reward_goods_item:reloadData()
            self.reward_num_item:reloadData()
        else
    	    table_sort(self.reward_list,function(a,b) return a.lev < b.lev end)
            self.reward_goods_item:reloadData()
            self.reward_num_item:reloadData()
        end

        if self.comp_bar_bg and not tolua.isnull(self.comp_bar_bg) and self.comp_bar and not tolua.isnull(self.comp_bar) and self.bar_layout and not tolua.isnull(self.bar_layout) then
            local len = #self.reward_list or 1
            self.comp_bar_bg:setContentSize(cc.size(139*(len-1),27))
            self.comp_bar:setContentSize(cc.size(139*(len-1),15))
            self.bar_layout:setPosition(cc.p(50,139*(len-1)+139/2))
            self:updatePercent(model:getWinCounts())
        end
    end
    local title_pos = cur_lev or 1
    local len = #self.reward_list or 1
    if title_pos+2 >= len then
        title_pos = len+1
    end
    self:jumpToMoveByY(139 * (title_pos-1))
end


--设置数据
function PlanesafkOrderactionWindow:setBasicInitData(data)
    if not data then return end
    --当前等级
    local lev_num = data.lev or 0
    local win_count = data.win_count or 0
    local cur_period = model:getCurPeriod()

    if self.level_num and not tolua.isnull(self.level_num) then
        self.level_num:setString(win_count)
    end
    self:setChangeLevelStatus(lev_num)
    self:updateIconImg(data.rmb_status)
    
end


function PlanesafkOrderactionWindow:openRootWnd()
    model:setOrderactionRedStatus(0)
    model:checkPlanesafkRedPoint()
    GlobalEvent:getInstance():Fire(PlanesafkEvent.Planesafk_OrderAction_First_Red_Event)
    controller:sender28616()
    controller:sender28619()
end
function PlanesafkOrderactionWindow:close_callback()
    doStopAllActions(self.time_text)

    if self.reward_goods_item then
        self.reward_goods_item:DeleteMe()
        self.reward_goods_item = nil
    end

    if self.reward_num_item then
        self.reward_num_item:DeleteMe()
        self.reward_num_item = nil
    end
    
    controller:openPlanesafkOrderactionWindow(false)
end

------------------------------------------
-- 奖励子项
PlanesafkOrderActiodRewardItem = class("PlanesafkOrderActiodRewardItem", function()
    return ccui.Widget:create()
end)

function PlanesafkOrderActiodRewardItem:ctor()
    self:configUI()
    self:register_event()
end

function PlanesafkOrderActiodRewardItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("planesafk/planesafk_orderaction_reward_item"))
    self:setContentSize(cc.size(720,139))
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.goods_item = main_container:getChildByName("goods_item")
    self.goods_item:setScrollBarEnabled(false)
    self.finish_img = main_container:getChildByName("finish_img")
    self.finish_img:setVisible(false)
    self.btn_get = main_container:getChildByName("btn_get")
    self.btn_name = self.btn_get:getChildByName("name")
    self.btn_name:setString("")
    self.common_goods_item = BackPackItem.new(nil,true,nil,0.8,nil,true)
    main_container:addChild(self.common_goods_item)
    self.common_goods_item:setPosition(cc.p(170, 139/2))

end
function PlanesafkOrderActiodRewardItem:register_event()
    registerButtonEventListener(self.btn_get, function()
        if self.data then
            if self.data.status == 0 or (self.data.rmb_status == 0 and self.data.is_locak == 1) then
                controller:sender28617(0)
            elseif self.data.status == 1 and self.data.rmb_status == 1 then
                message(TI18N("奖励已领取"))
            else
                controller:openBuyCardView(true)
            end
        end
        
    end,true, 1)
end

function PlanesafkOrderActiodRewardItem:setData(data)
    if not data then return end
    self.data = data


    local common = true
    if self.common_goods_item and not tolua.isnull(self.common_goods_item) then
    	if data.reward and data.reward[1] then
    		self.common_goods_item:setBaseData(data.reward[1][1],data.reward[1][2])
    		self.common_goods_item:setVisible(true)
    	else
    		self.common_goods_item:setVisible(false)
    	end
 
    	--领取状态
    	if data.status == 1 then
    		self.common_goods_item:IsGetStatus(true,nil,PathTool.getResFrame("planesafkorderaction","txt_cn_planesafkaction_1"))
    	else
	    	self.common_goods_item:IsGetStatus(false)
	    end
    end

    local is_locak_status = true
    if data.cur_lev >= data.lev then
    	common = false
	    if data.is_locak == 1 then
	    	is_locak_status = false
	    else
	    	is_locak_status = true
	    end
    else
    	common = true
	    is_locak_status = true
    end
    if common == false then
    	if data.status == 1 then
    		self.common_goods_item:showItemEffect(false)
    	else
		    self.common_goods_item:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
		end
	else
		self.common_goods_item:showItemEffect(false)
	end
  
    --进阶奖励
    local advance = true
    local effect_id
    if model:getGiftStatus() == 1 then
    	if data.rmb_status == 0 then
    		if data.cur_lev >= data.lev then
    			advance = false
    		end
    	end
    end
    if advance == false then
    	effect_id = 263
    end

    local is_get_status = false
    if data.rmb_status == 1 then
        is_get_status = true
    end

    local data_list = data.rmb_reward or {}
	local setting = {}
	setting.start_x = 10
	setting.scale = 0.8
	setting.max_count = 3
    setting.lock = is_locak_status
    setting.lock_pos = cc.p(59.5,59.5)
	setting.is_tip = true
    setting.show_effect_id = effect_id
    setting.is_get_status = is_get_status
    setting.get_status_res = PathTool.getResFrame("planesafkorderaction","txt_cn_planesafkaction_1")
    self.item_list = commonShowSingleRowItemList(self.goods_item, self.item_list, data_list, setting)
    if self.btn_get then
        addRedPointToNodeByStatus(self.btn_get, false, 5, 5)
        if data.cur_lev < data.lev then
            setChildUnEnabled(true, self.btn_get)
            self.btn_get:setTouchEnabled(false)
            self.btn_name:setString(TI18N("领取"))
            self.btn_name:disableEffect(cc.LabelEffect.OUTLINE)
            self.btn_get:setVisible(true)
            self.finish_img:setVisible(false)
        else
            if data.status == 0 or (data.rmb_status == 0 and data.is_locak == 1) then
                setChildUnEnabled(false, self.btn_get)
                self.btn_get:setTouchEnabled(true)
                self.btn_name:setString(TI18N("可领取"))
                self.btn_name:enableOutline(Config.ColorData.data_color4[264], 2)
                self.btn_get:setVisible(true)
                self.finish_img:setVisible(false)
                addRedPointToNodeByStatus(self.btn_get, true, 5, 5)
            elseif data.status == 1 and data.rmb_status == 1 then
                self.btn_get:setVisible(false)
                self.finish_img:setVisible(true)
            else
                setChildUnEnabled(false, self.btn_get)
                self.btn_get:setTouchEnabled(true)
                self.btn_name:setString(TI18N("继续领取"))
                self.btn_name:enableOutline(Config.ColorData.data_color4[264], 2)
                self.btn_get:setVisible(true)
                self.finish_img:setVisible(false)
            end
        end
    end
end

function PlanesafkOrderActiodRewardItem:DeleteMe()
	if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    if self.common_goods_item then 
       self.common_goods_item:DeleteMe()
       self.common_goods_item = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end

------------------------------------------
-- 场次子项
PlanesafkOrderActiodRewardItem2 = class("PlanesafkOrderActiodRewardItem2", function()
    return ccui.Widget:create()
end)

function PlanesafkOrderActiodRewardItem2:ctor()
    self.size = cc.size(100,139)
    self:configUI()
    self:register_event()
end

function PlanesafkOrderActiodRewardItem2:configUI()
    self.root_wnd = ccui.Layout:create()
	self.root_wnd:setContentSize(self.size)
	self.root_wnd:setAnchorPoint(0.5,0.5)
    self:addChild(self.root_wnd)
    self.select_bg = createImage(self.root_wnd, PathTool.getResFrame("planesafkorderaction", "planesafkaction_2"),self.size.width/2,self.size.height/2+6,cc.p(0.5, 0.5),true)
    self.select_img = createImage(self.root_wnd, PathTool.getResFrame("planesafkorderaction", "planesafkaction_1"),self.size.width/2,self.size.height/2+6,cc.p(0.5, 0.5),true)
    self.select_img:setVisible(false)
    self.num_bg = createImage(self.root_wnd, PathTool.getResFrame("planesafkorderaction", "planesafkaction_11"),self.size.width/2,self.size.height/5+11,cc.p(0.5, 0.5),true,nil,true)
    self.num_bg:setCapInsets(cc.rect(19, 17, 2, 2))
    self.num_bg:setContentSize(cc.size(71,37))
    self.num_txt = createLabel(20,Config.ColorData.data_color4[1],nil,self.size.width/2-2,self.size.height/5+11,"",self.root_wnd,nil,cc.p(0.5, 0.5))
end

function PlanesafkOrderActiodRewardItem2:register_event()
end

function PlanesafkOrderActiodRewardItem2:setData(data)
    if not data then return end
    self.data = data
    local win_count = data.win_count or 0
    self.num_txt:setString(tostring(win_count))
    
    if data.cur_lev >= data.lev then
        self.select_img:setVisible(true)
    else
        self.select_img:setVisible(false)
    end
end

function PlanesafkOrderActiodRewardItem2:DeleteMe()
	
    self:removeAllChildren()
    self:removeFromParent()
end