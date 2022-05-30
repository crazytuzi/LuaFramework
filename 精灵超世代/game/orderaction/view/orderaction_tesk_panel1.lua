--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 战令三期 任务
-- @DateTime:    2019-06-24 13:53:25
-- *******************************
OrderActionTeskPanel1 = class("OrderActionTeskPanel1", function()
    return ccui.Widget:create()
end)

local table_insert = table.insert
local controller = OrderActionController:getInstance()
local model = controller:getModel()
local string_format = string.format
local title_name_list = {TI18N("每日任务"),TI18N("每周挑战"),TI18N("终极试炼")}
function OrderActionTeskPanel1:ctor(period)
    self.cur_period = period or 1
    self.cur_task_index = nil
    self:layoutUI()
    self:registerEvents()
end
function OrderActionTeskPanel1:layoutUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("orderaction/tesk_panel1"))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(651,558))

    local main_container = self.root_wnd:getChildByName("main_container")
    self.time_desc = createRichLabel(22, OrderActionConstants.ColorConst[9], cc.p(0,0.5), cc.p(5,-30), nil, nil, 400)
    main_container:addChild(self.time_desc)

    self.tab_view_list = {}
    local tab_view = main_container:getChildByName("tab_view")
    for i=1,3 do
        local tab = {}
        tab.btn_view = tab_view:getChildByName("tab_task_"..i)
        tab.normal = tab.btn_view:getChildByName("normal")
        tab.select = tab.btn_view:getChildByName("select")
        tab.select:setVisible(false)
        tab.title_name = tab.btn_view:getChildByName("title_name")
        tab.title_name:setString(title_name_list[i])
        tab.redpoint = tab.btn_view:getChildByName("redpoint")
        tab.redpoint:setVisible(false)
        self.tab_view_list[i] = tab
    end

    local task_item = main_container:getChildByName("task_item")
    local scroll_view_size = task_item:getContentSize()
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 635,               -- 单元的尺寸width
        item_height = 116,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true,
    }
    self.task_goods_item = CommonScrollViewSingleLayout.new(task_item, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.task_goods_item:setSwallowTouches(true)

    self.task_goods_item:registerScriptHandlerSingle(handler(self,self.createTaskCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.task_goods_item:registerScriptHandlerSingle(handler(self,self.numberOfTaskCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.task_goods_item:registerScriptHandlerSingle(handler(self,self.updateTaskCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

    self:setTabRedPoint()
    self:tabChargeTaskView(1)
end
function OrderActionTeskPanel1:createTaskCell()
	local cell = OrderActionTeskItem1.new()
    return cell
end
function OrderActionTeskPanel1:numberOfTaskCells()
	if not self.task_list then return 0 end
    return #self.task_list
end
function OrderActionTeskPanel1:updateTaskCellByIndex(cell, index)
	if not self.task_list then return end
    local cell_data = self.task_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function OrderActionTeskPanel1:tabChargeTaskView(index)
    index = index or 1
    if self.cur_task_index == index then return end
    if self.cur_tab_view ~= nil then
        self.cur_tab_view.select:setVisible(false)
    end
    self.cur_task_index = index
    self.cur_tab_view = self.tab_view_list[index]
    if self.cur_tab_view ~= nil then
        self.cur_tab_view.select:setVisible(true)
    end
    self:setTaskGetStatus()
end

function OrderActionTeskPanel1:setTaskGetStatus()
    local cur_day = model:getCurDay()
    local data_list = self:setTaskData(self.cur_period,cur_day,self.cur_task_index)
    local time = 0
    if data_list then
        self.task_list = {}
        for i,v in pairs(data_list) do
            local task_list = model:getInitTaskData(v.goal_id)
            v.tab_index = self.cur_task_index
            if task_list then
                v.status = task_list.finish
                v.value = task_list.value
                v.target_val = task_list.target_val
                if time == 0 then
                    time = task_list.end_time - GameNet:getInstance():getTime()
                end
            end
            table_insert(self.task_list,v)
        end
        model:sortTeskItemList(self.task_list)
        self.task_goods_item:reloadData()
    end

    local setting = {}
    setting.label_type = CommonAlert.type.rich
    setting.time_title = TI18N("刷新时间:")
    setting.time_color = "#249003"
    commonCountDownTime(self.time_desc, time, setting)
end
function OrderActionTeskPanel1:setTaskData(period,day,index)
    index = index or 1
    local sort_list = nil
    local tesk_list = model:getTaskInduct(index)
    if tesk_list then
        sort_list = tesk_list
    else
        model:setTaskInduct(period,day,index)
        local data = model:getTaskInduct(index)
        if data then
            sort_list = data
        end
    end
    return sort_list
end

function OrderActionTeskPanel1:registerEvents()
	if not self.update_taskget_event then
        self.update_taskget_event = GlobalEvent:getInstance():Bind(OrderActionEvent.OrderAction_TaskGet_Event,function()
            self:setTaskGetStatus()
            self:setTabRedPoint()
        end)
    end

	for i,v in pairs(self.tab_view_list) do
        registerButtonEventListener(v.btn_view, function()
            self:tabChargeTaskView(i)
        end,false, 1)
    end
end
--红点
function OrderActionTeskPanel1:setTabRedPoint()
    local cur_day = model:getCurDay()
    for i=1,3 do
        local data_list = self:setTaskData(self.cur_period,cur_day,i)
        if data_list then
            local status = false
            for i,v in pairs(data_list) do
                local task_list = model:getInitTaskData(v.goal_id)
                if task_list then
                    if task_list.finish == 1 then
                        status = true
                        break
                    end
                end
            end
            self.tab_view_list[i].redpoint:setVisible(status)
        end
    end
end

function OrderActionTeskPanel1:setVisibleStatus(bool)
    self:setVisible(bool)
end

function OrderActionTeskPanel1:DeleteMe()
	if self.update_taskget_event then
        GlobalEvent:getInstance():UnBind(self.update_taskget_event)
        self.update_taskget_event = nil
    end
	doStopAllActions(self.time_desc)
	if self.task_goods_item then
        self.task_goods_item:DeleteMe()
        self.task_goods_item = nil
    end

	self:removeAllChildren()
    self:removeFromParent()
end

------------------------------------------
-- 子项
OrderActionTeskItem1 = class("OrderActionTeskItem1", function()
    return ccui.Widget:create()
end)

local tab_name = {TI18N("每日"),TI18N("每周"),TI18N("每月")}
function OrderActionTeskItem1:ctor()
    self:configUI()
    self:register_event()
end

function OrderActionTeskItem1:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("orderaction/tesk_item1"))
    self:setContentSize(cc.size(635,116))
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.btn_goto = main_container:getChildByName("btn_goto")
    self.btn_goto:getChildByName("Text_3"):setString(TI18N("前往"))
    self.btn_goto:setVisible(false)
    self.btn_get = main_container:getChildByName("btn_get")
    self.btn_get:getChildByName("Text_3"):setString(TI18N("领取"))
    self.btn_get:setVisible(false)
    self.spr_get = main_container:getChildByName("spr_get")
    self.spr_get:setVisible(false)

    self.big_title_head = main_container:getChildByName("big_title_head")
    self.big_title_head:setString("")
    self.big_title = main_container:getChildByName("big_title")
    self.big_title:setString("")
    self.small_title = main_container:getChildByName("small_title")
    self.small_title:setString("")

    if not self.task_reward then
        self.task_reward = BackPackItem.new(nil,true,nil,0.7)
        main_container:addChild(self.task_reward)
        self.task_reward:setPosition(cc.p(59, 57))
        self.task_reward:setDefaultTip()
    end
end
function OrderActionTeskItem1:register_event()
    registerButtonEventListener(self.btn_get, function()
        if self.data and self.data.goal_id then
            controller:send25302(self.data.goal_id)
        end
    end ,true, 1)
    registerButtonEventListener(self.btn_goto, function()
        if self.data and self.data.show_icon ~= "" then
            StrongerController:getInstance():clickCallBack(self.data.show_icon)
        end
    end ,true, 1)
end

function OrderActionTeskItem1:setData(data)
    if not data then return end
    self.data = data
    if self.task_reward then
    	if data.award and data.award[1] then
	    	self.task_reward:setBaseData(data.award[1][1],data.award[1][2])
	    end
    end
    
    if data.tab_index then
    	self.big_title_head:setString("【"..tab_name[data.tab_index].."】")
    end
    self.big_title:setString(data.title or "")
    local desc = data.desc or ""
    local value = MoneyTool.GetMoneyString(data.value or 0)
    local target_val = MoneyTool.GetMoneyString(data.target_val or 0)
    local str = string_format("%s (%s/%s)",desc,value,target_val)
    self.small_title:setString(str)

    self.btn_goto:setVisible(data.status == 0)
    self.btn_get:setVisible(data.status == 1)
    self.spr_get:setVisible(data.status == 2)
end

function OrderActionTeskItem1:DeleteMe()
	if self.task_reward then 
       self.task_reward:DeleteMe()
       self.task_reward = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end
