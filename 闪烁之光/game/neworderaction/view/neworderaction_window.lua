--******** 文件说明 ********
-- @Author:      yuanqi
-- @description: 全新战令主界面
-- @DateTime:    2020-2-20
-- *******************************
NewOrderactionWindow = NewOrderactionWindow or BaseClass(BaseView)

local controller = NeworderactionController:getInstance()
local model = controller:getModel()
local controll_action = ActionController:getInstance()
-- local lev_reward_list = Config.HolidayNewWarOrderData.data_lev_reward_list
local lev_reward_list = {}
local table_sort = table.sort
local table_insert = table.insert
function NewOrderactionWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full

    self.layout_name = "neworderaction/neworderaction_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("planesafkorderaction", "planesafkorderaction"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("neworderaction", "neworderaction"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_99", true), type = ResourcesType.single}
    }

    self.reward_list = {}
    self.cur_index = nil
    self.tab_view = {}
end

function NewOrderactionWindow:open_callback()
    model:setPeriodRed(false)
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    if self.background ~= nil then
        self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg", "bigbg_99", true), LOADTEXT_TYPE)
    end
    self.top_bg = self.root_wnd:getChildByName("top_bg")
    self.bottom_bg = self.root_wnd:getChildByName("bottom_bg")
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1) 

    -- 标签
    local tab_view = self.main_container:getChildByName("tab_view")
    local title_name = {TI18N("奖励"), TI18N("每日任务"), TI18N("每周任务")}
    for i = 1, 3 do
        local tab = {}
        tab.btn_tab_view = tab_view:getChildByName("tab_" .. i)
        tab.normal = tab.btn_tab_view:getChildByName("normal")
        tab.select = tab.btn_tab_view:getChildByName("select")
        tab.select:setVisible(false)
        tab.name = tab.btn_tab_view:getChildByName("name")
        tab.name:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
        tab.name:setString(title_name[i])
        tab.index = i
        self.tab_view[i] = tab
    end

    --解锁奖励总览
    self.btn_open_lock = self.main_container:getChildByName("btn_open_lock")
    self.btn_open_lock_label = self.btn_open_lock:getChildByName("name")
    self.btn_open_lock_label:setString(TI18N("解锁英灵殿之剑"))

    --活动时间与领取
    self.main_container:getChildByName("time_title"):setString(TI18N("重置时间："))
    self.time_text = self.main_container:getChildByName("time_text")
    self.time_text:setString("")

    self.btn_rule = self.main_container:getChildByName("btn_rule")
    self.btn_close = self.main_container:getChildByName("btn_close")

    self.main_container:getChildByName("medal_title"):setString(TI18N("勇士功勋："))
    self.medal_num = self.main_container:getChildByName("medal_num")
    self.medal_num:setString("")

    self.icon_img = self.main_container:getChildByName("icon_img")

    self.main_container:getChildByName("Text_33"):setString(TI18N("完成每日任务和每周任务，领取豪华奖励"))

    self.time_text_bg = self.main_container:getChildByName("Text_4")
    self.time_text_bg:setString(TI18N("刷新时间:"))
    self.task_time_text = self.main_container:getChildByName("task_time_text")
    self.task_time_text:setString("")
    
    self.goods_item = self.main_container:getChildByName("goods_item")
    local scroll_view_size = self.goods_item:getContentSize()
    local setting = {
        start_x = 0, -- 第一个单元的X起点
        space_x = 0, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 0, -- y方向的间隔
        item_width = 720, -- 单元的尺寸width
        item_height = 139, -- 单元的尺寸height
        row = 0, -- 行数，作用于水平滚动类型
        col = 1, -- 列数，作用于垂直滚动类型
        need_dynamic = true,
        checkovercallback = handler(self, self.updateSlideShowByVertical)
    }
    self.reward_goods_item = CommonScrollViewSingleLayout.new(self.goods_item, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.reward_goods_item:setSwallowTouches(true)

    self.reward_goods_item:registerScriptHandlerSingle(handler(self, self.createTaskCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.reward_goods_item:registerScriptHandlerSingle(handler(self, self.numberOfTaskCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.reward_goods_item:registerScriptHandlerSingle(handler(self, self.updateTaskCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    local scroll_view_size2 = cc.size(100, scroll_view_size.height)
    local setting = {
        start_x = 0, -- 第一个单元的X起点
        space_x = 0, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 0, -- y方向的间隔
        item_width = 100, -- 单元的尺寸width
        item_height = 139, -- 单元的尺寸height
        row = 0, -- 行数，作用于水平滚动类型
        col = 1, -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.reward_num_item = CommonScrollViewSingleLayout.new(self.goods_item, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size2, setting)
    self.reward_num_item:setClickEnabled(false)

    self.reward_num_item:registerScriptHandlerSingle(handler(self, self.createTaskCell2), ScrollViewFuncType.CreateNewCell) --创建cell
    self.reward_num_item:registerScriptHandlerSingle(handler(self, self.numberOfTaskCells2), ScrollViewFuncType.NumberOfCells) --获取数量
    self.reward_num_item:registerScriptHandlerSingle(handler(self, self.updateTaskCellByIndex2), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    local period = model:getCurPeriod()
    self:createTaskView(period)
    self:createProgress()
    self:adaptationScreen()
end

--设置适配屏幕
function NewOrderactionWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.container)
    local bottom_y = display.getBottom(self.container)

    self.top_bg:setPositionY(top_y)
    self.bottom_bg:setPositionY(bottom_y)
end

--进度条
function NewOrderactionWindow:createProgress()
    if self.comp_bar == nil then
        local size = cc.size(315, 27)
        local res = PathTool.getResFrame("planesafkorderaction", "planesafkaction_4")
        local res1 = PathTool.getResFrame("planesafkorderaction", "planesafkaction_7")
        if self.reward_goods_item and not tolua.isnull(self.reward_goods_item) and self.reward_goods_item.container and not tolua.isnull(self.reward_goods_item.container) then
            local bar_layout = ccui.Layout:create()
            bar_layout:setContentSize(cc.size(27, 27))
            bar_layout:setAnchorPoint(0, 0)
            bar_layout:setRotation(90)
            if bar_layout then
                self.reward_goods_item.container:addChild(bar_layout, 999)
                self.bar_layout = bar_layout
            end

            local bg, comp_bar = createLoadingBar(res, res1, size, self.bar_layout, cc.p(0, 0.5), 0, 0, true, true)

            self.comp_bar_bg = bg
            self.comp_bar = comp_bar
        end
    end
end

function NewOrderactionWindow:updatePercent(exp)
    if tolua.isnull(self.comp_bar) or not exp then
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
        local offset_y = (progress_width + 0) / (#award_config - 1)
        for i, v in ipairs(award_config) do
            if i == 1 then
                if exp <= v.exp then
                    distance = (exp / v.exp) * first_off
                    break
                else
                    distance = first_off
                end
            else
                if exp <= v.exp then
                    distance = distance + ((exp - last_lev) / (v.exp - last_lev)) * offset_y
                    break
                else
                    distance = distance + offset_y
                end
            end
            last_lev = v.exp
        end
        self.comp_bar:setPercent(distance / progress_width * 100)
    end
end

function NewOrderactionWindow:register_event()
    self:addGlobalEvent(
        NeworderactionEvent.OrderAction_Init_Event,
        function(data)
            self:tabChargeView(1, data.period)
            self:initAwardConfig()
            self:setBasicInitData()
            local time = data.end_time - GameNet:getInstance():getTime()
            controll_action:getModel():setCountDownTime(self.time_text, time)
        end
    )

    --任务更新
    self:addGlobalEvent(
        NeworderactionEvent.OrderAction_TaskGet_Event,
        function()
            self:setTabRedPoint()
        end
    )

    self:addGlobalEvent(
        NeworderactionEvent.OrderAction_LevReward_Event,
        function()
            self:setBasicInitData()
            self:setTabRedPoint()
        end
    )

    self:addGlobalEvent(
        NeworderactionEvent.OrderAction_Updata_LevExp_Event,
        function(data)
            self:setBasicInitData()
            model:setRewardLevRedPoint()
            self:setTabRedPoint()
        end
    )

    self:addGlobalEvent(
        NeworderactionEvent.OrderAction_IsPopWarn_Event,
        function(data)
            if data then
                local totle_day = 30
                if (totle_day - data.cur_day) == 7 or (totle_day - data.cur_day) == 3 or (totle_day - data.cur_day) == 0 then
                    if data.is_pop == 1 then
                        controller:openEndWarnView(true, data.cur_day)
                    end
                end
            end
        end
    )

    self:addGlobalEvent(
        NeworderactionEvent.OrderAction_BuyGiftCard_Event,
        function()
            self:setBasicInitData()
            self:setTabRedPoint()
        end
    )

    for i, v in pairs(self.tab_view) do
        registerButtonEventListener(
            v.btn_tab_view,
            function()
                local day = model:getCurDay()
                local period = model:getCurPeriod()
                self:tabChargeView(v.index, period)
            end,
            false,
            3
        )
    end

    registerButtonEventListener(
        self.btn_open_lock,
        function()
            controller:openBuyCardView(true)
        end,
        true,
        1
    )

    registerButtonEventListener(
        self.btn_close,
        function()
            controller:openOrderActionMainView(false)
        end,
        true,
        2
    )

    registerButtonEventListener(
        self.btn_rule,
        function(param, sender, event_type)
            local config = Config.HolidayNewWarOrderData.data_constant
            if config then
                local config_desc = config.action_rule
                TipsManager:getInstance():showCommonTips(config_desc.desc, sender:getTouchBeganPosition(), nil, nil, 500)
            end
        end,
        false,
        1
    )
end

function NewOrderactionWindow:tabChargeView(index, period)
    index = index or 1
    if self.cur_index == index then
        return
    end
    if self.cur_index == 1 then
        self.goods_item:setVisible(false)
    elseif self.cur_index == 2 or self.cur_index == 3 then
        if self.task_view ~= nil then
            self.task_view:setVisibleStatus(false)
        end
    end
    self.cur_index = index
    self:tabHeadTitle(index)
    if self.cur_index == 1 then
        self.goods_item:setVisible(true)
        self.time_text_bg:setVisible(false)
        self.task_time_text:setVisible(false)
        self.task_view.cur_task_index = nil
    elseif self.cur_index == 2 then
        self.task_view:setVisibleStatus(true)
        self.task_view:tabChargeTaskView(1)
        self.time_text_bg:setVisible(true)
        self.task_time_text:setVisible(true)
        local time = model:getDayTaskEndTime() - GameNet:getInstance():getTime()
        controll_action:getModel():setCountDownTime(self.task_time_text,time)
    elseif self.cur_index == 3 then
        self.task_view:setVisibleStatus(true)
        self.task_view:tabChargeTaskView(2)
        self.time_text_bg:setVisible(true)
        self.task_time_text:setVisible(true)
        local time = model:getWeekTaskEndtime() - GameNet:getInstance():getTime()
        controll_action:getModel():setCountDownTime(self.task_time_text,time)
    end
end

function NewOrderactionWindow:createTaskView(period)
    if self.task_view == nil then
        local pos_x, pos_y = self.goods_item:getPosition()
        self.task_view = NewOrderActionTaskPanel.new(period)
        self.task_view:setPosition(cc.p(pos_x, pos_y))
        self.main_container:addChild(self.task_view)
        self.task_view:setVisibleStatus(false)
    end
end

function NewOrderactionWindow:tabHeadTitle(index)
    if self.cur_herd_title ~= nil then
        self.cur_herd_title.select:setVisible(false)
        self.cur_herd_title.name:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
    end
    self.cur_herd_title = self.tab_view[index]
    if self.cur_herd_title ~= nil then
        self.cur_herd_title.select:setVisible(true)
        self.cur_herd_title.name:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
    end
end

--红点
function NewOrderactionWindow:setTabRedPoint()
    local cur_day = model:getCurDay()
    for i = 1, 3 do
        if i == 1 then
            local status = model:getRewardLevRedPoint()
            addRedPointToNodeByStatus(self.tab_view[1].btn_tab_view, status)
        else
            local cur_period = model:getCurPeriod()
            local data_list
            if self.task_view then
                data_list = self.task_view:setTaskData(cur_period, cur_day, i - 1)
            end
            if data_list then
                local status = false
                for k, v in pairs(data_list) do
                    local task_list = model:getInitTaskData(v.goal_id)
                    if task_list then
                        if task_list.finish == 1 then
                            status = true
                            break
                        end
                    end
                end
                addRedPointToNodeByStatus(self.tab_view[i].btn_tab_view, status)
            end
        end
    end
end

--奖励列表
function NewOrderactionWindow:createTaskCell()
    local cell = NewOrderActiodRewardItem.new()
    return cell
end

function NewOrderactionWindow:numberOfTaskCells()
    if not self.reward_list then
        return 0
    end
    return #self.reward_list
end

function NewOrderactionWindow:updateTaskCellByIndex(cell, index)
    if not self.reward_list then
        return
    end
    local cell_data = self.reward_list[index]
    if not cell_data then
        return
    end

    cell:setData(cell_data)
end

--滑动的时候处理显示
function NewOrderactionWindow:updateSlideShowByVertical()
    local container_y = self.reward_goods_item:getCurContainerPosY()
    if container_y and self.reward_num_item and not tolua.isnull(self.reward_num_item) then
        if self.reward_num_item.container and not tolua.isnull(self.reward_num_item.container) then
            self.reward_num_item.container:setPositionY(container_y)
            self.reward_num_item:checkRectIntersectsRect()
        end
    end
end

--功勋数数列表
function NewOrderactionWindow:createTaskCell2()
    local cell = NewOrderActiodRewardItem2.new()
    return cell
end

function NewOrderactionWindow:numberOfTaskCells2()
    if not self.reward_list then
        return 0
    end
    return #self.reward_list
end

function NewOrderactionWindow:updateTaskCellByIndex2(cell, index)
    if not self.reward_list then
        return
    end
    local cell_data = self.reward_list[index]
    if not cell_data then
        return
    end
    cell:setData(cell_data)
end

function NewOrderactionWindow:updateIconImg(status)
    if tolua.isnull(self.icon_img) or tolua.isnull(self.btn_open_lock) then
        return
    end
    loadSpriteTexture(self.icon_img, PathTool.getResFrame("neworderaction", "neworderaction_1"), LOADTEXT_TYPE_PLIST)

    if status == 1 then
        setChildUnEnabled(false, self.icon_img)
    else
        setChildUnEnabled(true, self.icon_img)
    end

    if status == 1 then
        self.btn_open_lock:setVisible(false)
    else
        self.btn_open_lock:setVisible(true)
    end
end

function NewOrderactionWindow:jumpToMoveByY(y)
    if not y then
        return
    end
    local pos = y
    if pos < 0 then
        pos = 0
    end

    local len = #self.reward_list or 1
    local scroll_view_size = self.goods_item:getContentSize()
    local pos_per = pos * 100 / (len * 139 - scroll_view_size.height)
    if pos_per > 100 then
        pos_per = 100
    end
    self.reward_goods_item:scrollToPercentVertical(pos_per, 0.5, true)
end

--当等级变化的时候
function NewOrderactionWindow:setChangeLevelStatus(cur_lev)
    local cur_period = model:getCurPeriod()
    local jump_num
    if lev_reward_list and lev_reward_list[cur_period] then
        self.reward_list = {}
        for i, v in pairs(lev_reward_list[cur_period]) do
            v.cur_lev = cur_lev
            v.status = 0
            v.rmb_status = 0
            v.is_locak = model:getGiftStatus()
            local lev_list = model:getLevShowData(v.lev)
            if lev_list then
                v.status = lev_list.status
                v.rmb_status = lev_list.rmb_status
            end
            if cur_lev >= v.lev and (v.status == 0 or (v.rmb_status == 0 and v.is_locak == 1)) and (jump_num == nil or v.lev < jump_num) then
                jump_num = v.lev
            end
            table_insert(self.reward_list, v)
        end
        if next(self.reward_list) == nil then
            self.reward_goods_item:reloadData()
            self.reward_num_item:reloadData()
        else
            table_sort(
                self.reward_list,
                function(a, b)
                    return a.lev < b.lev
                end
            )
            self.reward_goods_item:reloadData()
            self.reward_num_item:reloadData()
        end

        if self.comp_bar_bg and not tolua.isnull(self.comp_bar_bg) and self.comp_bar and not tolua.isnull(self.comp_bar) and self.bar_layout and not tolua.isnull(self.bar_layout) then
            local len = #self.reward_list or 1
            self.comp_bar_bg:setContentSize(cc.size(139 * (len - 1), 27))
            self.comp_bar:setContentSize(cc.size(139 * (len - 1), 15))
            self.bar_layout:setPosition(cc.p(50, 139 * (len - 1) + 139 / 2))
            self:updatePercent(model:getCurExp())
        end
    end
    local title_pos = jump_num or cur_lev
    local len = #self.reward_list or 1
    if title_pos + 2 >= len then
        title_pos = len + 1
    end
    self:jumpToMoveByY(139 * (title_pos - 1))
end

--设置数据
function NewOrderactionWindow:setBasicInitData()
    --当前等级
    local lev_num = model:getCurLev() or 0
    local exp = model:getCurExp() or 0
    local cur_period = model:getCurPeriod()
    local rmb_status = model:getRMBStatus()
    if self.medal_num and not tolua.isnull(self.medal_num) then
        self.medal_num:setString(exp)
    end
    self:setChangeLevelStatus(lev_num)
    self:updateIconImg(rmb_status)
end

function NewOrderactionWindow:initAwardConfig()
    local temp_reward_list = Config.HolidayNewWarOrderData.data_lev_reward_list
    local cur_period = model:getCurPeriod()
    local period_lev = model:getPeriodLev()
    lev_reward_list[cur_period] = {}
    for k, v in ipairs(temp_reward_list[cur_period]) do
        if period_lev >= v.min_lev and period_lev <= v.max_lev then
            table_insert(lev_reward_list[cur_period], v)
        end
    end
end

function NewOrderactionWindow:openRootWnd()
    controller:send28700()
    controller:send28707()
    controller:send28703()
    controller:send28706()
end

function NewOrderactionWindow:close_callback()
    doStopAllActions(self.time_text)
    doStopAllActions(self.task_time_text)
    if self.reward_goods_item then
        self.reward_goods_item:DeleteMe()
        self.reward_goods_item = nil
    end

    if self.reward_num_item then
        self.reward_num_item:DeleteMe()
        self.reward_num_item = nil
    end

    if self.task_view and self.task_view["DeleteMe"] then
        self.task_view:DeleteMe()
        self.task_view = nil
    end

    controller:openOrderActionMainView(false)
end

------------------------------------------
-- 奖励子项
NewOrderActiodRewardItem =
    class(
    "NewOrderActiodRewardItem",
    function()
        return ccui.Widget:create()
    end
)

function NewOrderActiodRewardItem:ctor()
    self:configUI()
    self:register_event()
end

function NewOrderActiodRewardItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("neworderaction/neworderaction_reward_item"))
    self:setContentSize(cc.size(720, 139))
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.goods_item = main_container:getChildByName("goods_item")
    self.goods_item:setScrollBarEnabled(false)
    self.finish_img = main_container:getChildByName("finish_img")
    self.finish_img:setVisible(false)
    self.btn_get = main_container:getChildByName("btn_get")
    self.btn_name = self.btn_get:getChildByName("name")
    self.btn_name:setString("")
    self.common_goods_item = BackPackItem.new(nil, true, nil, 0.8, nil, true)
    main_container:addChild(self.common_goods_item)
    self.common_goods_item:setPosition(cc.p(170, 139 / 2))
end

function NewOrderActiodRewardItem:register_event()
    registerButtonEventListener(
        self.btn_get,
        function()
            if self.data then
                if self.data.status == 0 or (self.data.rmb_status == 0 and self.data.is_locak == 1) then
                    controller:send28704(self.data.lev)
                elseif self.data.status == 1 and self.data.rmb_status == 1 then
                    message(TI18N("奖励已领取"))
                else
                    controller:openBuyCardView(true)
                end
            end
        end,
        true,
        1
    )
end

function NewOrderActiodRewardItem:setData(data)
    if not data then
        return
    end
    self.data = data

    local common = true
    if self.common_goods_item and not tolua.isnull(self.common_goods_item) then
        if data.reward and data.reward[1] then
            self.common_goods_item:setBaseData(data.reward[1][1], data.reward[1][2])
            self.common_goods_item:setVisible(true)
        else
            self.common_goods_item:setVisible(false)
        end

        --领取状态
        if data.status == 1 then
            self.common_goods_item:IsGetStatus(true, nil, PathTool.getResFrame("planesafkorderaction", "txt_cn_planesafkaction_1"))
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
    setting.lock_pos = cc.p(59.5, 59.5)
    setting.is_tip = true
    setting.show_effect_id = effect_id
    setting.is_get_status = is_get_status
    setting.get_status_res = PathTool.getResFrame("planesafkorderaction", "txt_cn_planesafkaction_1")
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

function NewOrderActiodRewardItem:DeleteMe()
    if self.item_list then
        for i, v in pairs(self.item_list) do
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
-- 功勋子项
NewOrderActiodRewardItem2 =
    class(
    "NewOrderActiodRewardItem2",
    function()
        return ccui.Widget:create()
    end
)

function NewOrderActiodRewardItem2:ctor()
    self.size = cc.size(100, 139)
    self:configUI()
    self:register_event()
end

function NewOrderActiodRewardItem2:configUI()
    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setContentSize(self.size)
    self.root_wnd:setAnchorPoint(0.5, 0.5)
    self:addChild(self.root_wnd)
    self.select_bg = createImage(self.root_wnd, PathTool.getResFrame("planesafkorderaction", "planesafkaction_2"), self.size.width / 2, self.size.height / 2 + 6, cc.p(0.5, 0.5), true)
    self.select_img = createImage(self.root_wnd, PathTool.getResFrame("planesafkorderaction", "planesafkaction_1"), self.size.width / 2, self.size.height / 2 + 6, cc.p(0.5, 0.5), true)
    self.select_img:setVisible(false)
    self.num_bg = createImage(self.root_wnd, PathTool.getResFrame("planesafkorderaction", "planesafkaction_11"), self.size.width / 2, self.size.height / 5 + 11, cc.p(0.5, 0.5), true, nil, true)
    self.num_bg:setCapInsets(cc.rect(19, 17, 2, 2))
    self.num_bg:setContentSize(cc.size(71, 37))
    self.num_txt = createLabel(20, Config.ColorData.data_color4[1], nil, self.size.width / 2 - 2, self.size.height / 5 + 11, "", self.root_wnd, nil, cc.p(0.5, 0.5))
end

function NewOrderActiodRewardItem2:register_event()
end

function NewOrderActiodRewardItem2:setData(data)
    if not data then
        return
    end
    self.data = data
    local exp = data.exp or 0
    self.num_txt:setString(tostring(exp))

    if data.cur_lev >= data.lev then
        self.select_img:setVisible(true)
    else
        self.select_img:setVisible(false)
    end
end

function NewOrderActiodRewardItem2:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end
