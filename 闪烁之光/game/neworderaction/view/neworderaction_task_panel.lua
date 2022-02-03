--******** 文件说明 ********
-- @Author:      yuanqi@shiyue.com
-- @description: 英灵战令 任务面板
-- @DateTime:    2020-2-20
-- *******************************
NewOrderActionTaskPanel =
    class(
    "NewOrderActionTaskPanel",
    function()
        return ccui.Widget:create()
    end
)

local table_insert = table.insert
local controller = NeworderactionController:getInstance()
local model = controller:getModel()
local string_format = string.format
function NewOrderActionTaskPanel:ctor(period)
    self.cur_period = period or 1
    self.cur_task_index = nil
    self:layoutUI()
    self:registerEvents()
end

function NewOrderActionTaskPanel:layoutUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("neworderaction/task_panel"))
    self:setAnchorPoint(cc.p(0, 0))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(720, 661))

    local main_container = self.root_wnd:getChildByName("main_container")

    local task_item = main_container:getChildByName("task_item")
    local scroll_view_size = task_item:getContentSize()
    local setting = {
        start_x = 0, -- 第一个单元的X起点
        space_x = 0, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 0, -- y方向的间隔
        item_width = 720, -- 单元的尺寸width
        item_height = 139, -- 单元的尺寸height
        row = 0, -- 行数，作用于水平滚动类型
        col = 1, -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.task_goods_item = CommonScrollViewSingleLayout.new(task_item, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.task_goods_item:setSwallowTouches(true)

    self.task_goods_item:registerScriptHandlerSingle(handler(self, self.createTaskCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.task_goods_item:registerScriptHandlerSingle(handler(self, self.numberOfTaskCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.task_goods_item:registerScriptHandlerSingle(handler(self, self.updateTaskCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

end

function NewOrderActionTaskPanel:createTaskCell()
    local cell = NewOrderActionTaskItem.new()
    return cell
end

function NewOrderActionTaskPanel:numberOfTaskCells()
    if not self.task_list then
        return 0
    end
    return #self.task_list
end

function NewOrderActionTaskPanel:updateTaskCellByIndex(cell, index)
    if not self.task_list then
        return
    end
    local cell_data = self.task_list[index]
    if not cell_data then
        return
    end
    cell:setData(cell_data)
end

function NewOrderActionTaskPanel:tabChargeTaskView(index)
    index = index or 1
    if self.cur_task_index == index then
        return
    end
    self.cur_task_index = index
    self:setTaskGetStatus()
end

function NewOrderActionTaskPanel:setTaskGetStatus()
    local cur_day = model:getCurDay()
    local data_list = self:setTaskData(self.cur_period, cur_day, self.cur_task_index)
    local time = 0
    if data_list then
        self.task_list = {}
        for i, v in pairs(data_list) do
            local task_list = model:getInitTaskData(v.goal_id)
            v.tab_index = self.cur_task_index
            if task_list then
                v.status = task_list.finish
                v.value = task_list.value
                v.target_val = task_list.target_val
            end
            table_insert(self.task_list, v)
        end
        model:sortTaskItemList(self.task_list)
        self.task_goods_item:reloadData()
    end
end

function NewOrderActionTaskPanel:setTaskData(period, day, index)
    index = index or 1
    local sort_list = nil
    local tesk_list = model:getTaskInduct(index)
    if tesk_list then
        sort_list = tesk_list
    else
        model:setTaskInduct(period, day, index)
        local data = model:getTaskInduct(index)
        if data then
            sort_list = data
        end
    end
    return sort_list
end

function NewOrderActionTaskPanel:registerEvents()
    if not self.update_taskget_event then
        self.update_taskget_event =
            GlobalEvent:getInstance():Bind(
            NeworderactionEvent.OrderAction_TaskGet_Event,
            function()
                self:setTaskGetStatus()
            end
        )
    end

    -- for i, v in pairs(self.tab_view_list) do
    --     registerButtonEventListener(
    --         v.btn_view,
    --         function()
    --             self:tabChargeTaskView(i)
    --         end,
    --         false,
    --         1
    --     )
    -- end
end

function NewOrderActionTaskPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

function NewOrderActionTaskPanel:DeleteMe()
    if self.update_taskget_event then
        GlobalEvent:getInstance():UnBind(self.update_taskget_event)
        self.update_taskget_event = nil
    end
    if self.task_goods_item then
        self.task_goods_item:DeleteMe()
        self.task_goods_item = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end

------------------------------------------
-- 子项
NewOrderActionTaskItem =
    class(
    "NewOrderActionTaskItem",
    function()
        return ccui.Widget:create()
    end
)

local tab_name = {TI18N("每日"),TI18N("每周")}
function NewOrderActionTaskItem:ctor()
    self:configUI()
    self:register_event()
end

function NewOrderActionTaskItem:configUI()
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("neworderaction/task_item"))
    self:setContentSize(cc.size(720, 139))
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
        self.task_reward = BackPackItem.new(nil, true, nil, 0.8)
        main_container:addChild(self.task_reward)
        self.task_reward:setPosition(cc.p(59, 70))
        self.task_reward:setDefaultTip()
    end
end

function NewOrderActionTaskItem:register_event()
    registerButtonEventListener(
        self.btn_get,
        function()
            if self.data and self.data.goal_id then
                controller:send28702(self.data.goal_id)
            end
        end,
        true,
        1
    )
    registerButtonEventListener(
        self.btn_goto,
        function()
            if self.data and self.data.show_icon ~= "" then
                StrongerController:getInstance():clickCallBack(self.data.show_icon)
            end
        end,
        true,
        1
    )
end

function NewOrderActionTaskItem:setData(data)
    if not data then
        return
    end
    self.data = data
    if self.task_reward then
        if data.award and data.award[1] then
            self.task_reward:setBaseData(data.award[1][1], data.award[1][2])
        end
    end

    if data.tab_index then
    	self.big_title_head:setString("【"..tab_name[data.tab_index].."】")
    end

    self.big_title:setString(data.title or "")
    local desc = data.desc or ""
    local value = MoneyTool.GetMoneyString(data.value or 0)
    local target_val = MoneyTool.GetMoneyString(data.target_val or 0)
    local str = string_format("%s (%s/%s)", desc, value, target_val)
    self.small_title:setString(str)

    self.btn_goto:setVisible(data.status == 0)
    self.btn_get:setVisible(data.status == 1)
    self.spr_get:setVisible(data.status == 2)
end

function NewOrderActionTaskItem:DeleteMe()
    if self.task_reward then
        self.task_reward:DeleteMe()
        self.task_reward = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end
