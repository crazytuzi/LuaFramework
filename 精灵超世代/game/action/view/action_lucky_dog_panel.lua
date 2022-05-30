----------------------------
-- @Author: yuanqi
-- @Date:   2020-01-06
-- @Description:   幸运锦鲤
----------------------------
ActionLuckyDogPanel =
    class(
    "ActionLuckyDogPanel",
    function()
        return ccui.Widget:create()
    end
)

local controller = ActionController:getInstance()
local model = controller:getModel()
local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format
local lucky_type_constant = {
    NoPrize = 0,
    Glod = 1,
    Silver = 2,
    Copper = 3,
    Luckly = 4
}

function ActionLuckyDogPanel:ctor(bid)
    self.holiday_bid = bid
    self:configUI()
    self:register_event()

    self.cur_select_period = 1
    self:loadResources()
end

function ActionLuckyDogPanel:loadResources()
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("luckydog", "luckydog"), type = ResourcesType.plist}
    }
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(
        self.res_list,
        function()
            controller:send28400()
        end
    )
end

function ActionLuckyDogPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_lucky_dog_panel"))
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setPosition(-40, -80)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.image_bg = self.main_container:getChildByName("image_bg")

    local str = "action_lucky_dog"
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.reward_title ~= "" and tab_vo.reward_title then
        str = tab_vo.reward_title
    end

    local res = PathTool.getPlistImgForDownLoad("bigbg/action", str)
    if not self.item_load then
        self.item_load =
            createResourcesLoad(
            res,
            ResourcesType.single,
            function()
                if not tolua.isnull(self.image_bg) then
                    self.image_bg:loadTexture(res, LOADTEXT_TYPE)
                end
            end,
            self.item_load
        )
    end

    self.btn_tips = self.main_container:getChildByName("btn_tips")
    self.img_progress_bg = self.main_container:getChildByName("img_progress_bg")
    self.txt_time_value = self.main_container:getChildByName("txt_time_value")
    self.txt_time_value:setString("")
    self.txt_open_time = self.main_container:getChildByName("txt_open_time")
    self.txt_open_time:setString(TI18N("开奖时间："))
    self.txt_open_time_value = self.main_container:getChildByName("txt_open_time_value")
    self.txt_open_time_value:setString("")
    self.btn_get_reward = self.main_container:getChildByName("btn_get_reward")
    self.btn_get_reward:getChildByName("label"):setString(TI18N("一键领取"))
    self.btn_previous = self.main_container:getChildByName("btn_previous")
    self.btn_next = self.main_container:getChildByName("btn_next")
    self.txt_period = self.main_container:getChildByName("txt_period")
    self.reward_list = self.main_container:getChildByName("reward_list")
    for i = 1, 4 do
        self.reward_list["reward_item" .. i] = self.reward_list:getChildByName("reward_item" .. i)
        self.reward_list["reward_item" .. i].goods_con = self.reward_list["reward_item" .. i]:getChildByName("goods_con")
        self.reward_list["reward_item" .. i].title = self.reward_list["reward_item" .. i]:getChildByName("title")
        self.reward_list["reward_item" .. i].ticket = self.reward_list["reward_item" .. i]:getChildByName("ticket")
        self.reward_list["reward_item" .. i].ticket.ticket_num = self.reward_list["reward_item" .. i].ticket:getChildByName("ticket_num")
        local scroll_view_size = self.reward_list["reward_item" .. i].goods_con:getContentSize()
        local setting = {
            item_class = BackPackItem, -- 单元类
            start_x = 10, -- 第一个单元的X起点
            space_x = 10, -- x方向的间隔
            start_y = 11, -- 第一个单元的Y起点
            space_y = 4, -- y方向的间隔
            item_width = BackPackItem.Width * 0.6, -- 单元的尺寸width
            item_height = BackPackItem.Height * 0.6, -- 单元的尺寸height
            row = 1, -- 行数，作用于水平滚动类型
            col = 0, -- 列数，作用于垂直滚动类型
            scale = 0.6
        }
        local item_scroll = CommonScrollViewLayout.new(self.reward_list["reward_item" .. i].goods_con, cc.p(0, 0), ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
        item_scroll:setClickEnabled(false)
        self["item_scrollview" .. i] = item_scroll
    end

    local task_list = self.main_container:getChildByName("task_list")
    local scroll_view_size = task_list:getContentSize()
    local setting = {
        item_class = ActionLuckyDogTaskItem,
        start_x = 10,
        space_x = 39,
        start_y = 0,
        space_y = 0,
        item_width = 200,
        item_height = 155,
        row = 1,
        col = 3,
        need_dynamic = true
    }
    self.task_scrollview = CommonScrollViewLayout.new(task_list, cc.p(0, 0), ScrollViewDir.horizontal, ScrollViewStartPos.bottom, scroll_view_size, setting)
    self.task_scrollview:setSwallowTouches(false)
    self.task_scrollview:setClickEnabled(false)
    self.task_scrollview:setSwallowTouches(false)
    controller:send28403()
end

function ActionLuckyDogPanel:register_event()
    if not self.update_holiday_common_event then
        self.update_holiday_common_event =
            GlobalEvent:getInstance():Bind(
            ActionEvent.UPDATE_HOLIDAY_SIGNLE,
            function(data)
                if not data then
                    return
                end
                if data.bid == self.holiday_bid then
                    self:setPanelData(data)
                end
            end
        )
    end

    if not self.update_dog_base_event then
        self.update_dog_base_event =
            GlobalEvent:getInstance():Bind(
            ActionEvent.LUCKY_DOG_BASE_EVENT,
            function()
                controller:cs16603(self.holiday_bid)
            end
        )
    end

    registerButtonEventListener(
        self.btn_tips,
        function(param, sender, event_type)
            config = Config.HolidayLuckyDogData.data_constant
            if config and config.rules then
                TipsManager:getInstance():showCommonTips(config.rules.desc or "", sender:getTouchBeganPosition(), nil, nil, 500)
            end
        end,
        true,
        1,
        nil,
        0.8
    )

    registerButtonEventListener(
        self.btn_get_reward,
        function()
            if self.cur_select_period and self.cur_select_period ~= 0 then
                controller:send28401(self.cur_select_period)
            end
        end,
        true,
        1
    )

    registerButtonEventListener(
        self.btn_previous,
        function()
            self:setPageCut(0)
        end,
        true,
        1
    )

    registerButtonEventListener(
        self.btn_next,
        function()
            self:setPageCut(1)
        end,
        true,
        1
    )
end

function ActionLuckyDogPanel:setPanelData(data)
    if not data then
        return
    end
    self.cur_select_period = model:getLuckyDogPeriod()
    self:setPeriodData()
end

function ActionLuckyDogPanel:setPeriodData()
    -- 锦鲤设置奖励
    self.cur_select_data = model:getLuckyDogBaseData(self.cur_select_period)
    if not self.cur_select_data then
        return
    end
    local award_config = Config.HolidayLuckyDogData.data_quest_award
    if award_config and award_config[self.cur_select_period] then
        for i = 1, 4 do
            -- 设置奖励
            local list = {}
            for k, v in ipairs(award_config[self.cur_select_period][i].award) do
                local vo = deepCopy(Config.ItemData.data_get_data(v[1]))
                if vo then
                    vo.quantity = v[2]
                    table_insert(list, vo)
                end
            end
            local item_scroll = self["item_scrollview" .. i]
            item_scroll:setData(list)
            item_scroll:setData(list)
            item_scroll:addEndCallBack(
                function()
                    local list = item_scroll:getItemList()
                    for k, v in pairs(list) do
                        v:setDefaultTip()
                        v:setSwallowTouches(false)
                    end
                end
            )
            -- 设置号码
            local str = TI18N("未开奖")
            if self.cur_select_data.state == 1 then
                if award_config[self.cur_select_period][i].limit_number <= 0 then
                    str = TI18N("其他号码")
                elseif award_config[self.cur_select_period][i].limit_number < 10 then
                    str = "XXXXXXX" .. award_config[self.cur_select_period][i].limit_number
                elseif award_config[self.cur_select_period][i].limit_number < 100 then
                    str = "XXXXXX" .. award_config[self.cur_select_period][i].limit_number
                elseif award_config[self.cur_select_period][i].limit_number < 1000 then
                    str = "XXXXX" .. award_config[self.cur_select_period][i].limit_number
                elseif award_config[self.cur_select_period][i].limit_number < 10000 then
                    str = "XXXX" .. award_config[self.cur_select_period][i].limit_number
                elseif award_config[self.cur_select_period][i].limit_number < 100000 then
                    str = "XXX" .. award_config[self.cur_select_period][i].limit_number
                end
            end
            if self.reward_list["reward_item" .. i].ticket.ticket_num then
                self.reward_list["reward_item" .. i].ticket.ticket_num:setString(str)
            end
        end
    end

    -- 设置期数
    local str = string_format(TI18N("第%s期"), StringUtil.numToChinese(self.cur_select_period))
    self.txt_period:setString(str)

    local task_list_data = model:getLuckyDogTaskData(self.cur_select_period)
    table_sort(task_list_data, function(a,b) return a.quest_id < b.quest_id end)
    self.task_scrollview:setData(task_list_data)

    -- 设置按钮变灰和红点
    if model:getLuckyDogPeriodRed(self.cur_select_period) then
        setChildUnEnabled(false, self.btn_get_reward)
        self.btn_get_reward:getChildByName("label"):setString(TI18N("一键领取"))
        self.btn_get_reward:getChildByName("label"):enableOutline(cc.c4b(0x75, 0x4a, 0x19, 0xff), 2)
        addRedPointToNodeByStatus(self.btn_get_reward, true)
        self.btn_get_reward:setEnabled(true)
    else
        setChildUnEnabled(true, self.btn_get_reward)
        if self.cur_select_data.state == 0 then
            self.btn_get_reward:getChildByName("label"):setString(TI18N("暂未开奖"))
        elseif self.cur_select_data.state == 1 then
            if model:getLuckyDogParticipateIn(self.cur_select_period) then
                self.btn_get_reward:getChildByName("label"):setString(TI18N("已领取"))
            else
                self.btn_get_reward:getChildByName("label"):setString(TI18N("未完成"))
            end
        end
        self.btn_get_reward:getChildByName("label"):disableEffect(cc.LabelEffect.OUTLINE)
        addRedPointToNodeByStatus(self.btn_get_reward, false)
        self.btn_get_reward:setEnabled(false)
    end
    -- 设置开奖时间
    local period_config = Config.HolidayLuckyDogData.data_period
    if period_config and period_config[self.cur_select_period] and period_config[self.cur_select_period].open_time then
        self.txt_open_time_value:setString(period_config[self.cur_select_period].open_time)
    end
    -- 设置活动时间
    local base_data = model:getLuckyDogData()
    if base_data and base_data.start_time and base_data.end_time then
        self.txt_time_value:setString(TimeTool.getMD2(base_data.start_time) .. "-" .. TimeTool.getMD2(base_data.end_time))
    end
    -- 检查按钮显示
    self:checkPageBtn()
end

-- 切换期数（dir为0向前切页，为1向后切页）
function ActionLuckyDogPanel:setPageCut(dir)
    if dir == 0 then
        self.cur_select_period = self.cur_select_period - 1
    elseif dir == 1 then
        self.cur_select_period = self.cur_select_period + 1
    end
    self:checkPageBtn()
    self:setPeriodData()
end

-- 检查切页按钮和切页按钮红点是否显示
function ActionLuckyDogPanel:checkPageBtn()
    self.open_period = model:getLuckyDogPeriod()
    if not self.open_period then
        return
    end
    if self.cur_select_period <= 1 then
        self.cur_select_period = 1
        self.btn_previous:setVisible(false)
        self.btn_next:setVisible(self.open_period ~= 1)
        self.btn_next:getChildByName("redpoint"):setVisible(model:getLuckyDogPeriodRed(self.cur_select_period + 1))
    elseif self.cur_select_period >= self.open_period then
        self.cur_select_period = self.open_period
        self.btn_previous:setVisible(true)
        self.btn_next:setVisible(false)
        self.btn_previous:getChildByName("redpoint"):setVisible(model:getLuckyDogPeriodRed(self.cur_select_period - 1))
    else
        self.btn_previous:setVisible(true)
        self.btn_next:setVisible(true)
        self.btn_next:getChildByName("redpoint"):setVisible(model:getLuckyDogPeriodRed(self.cur_select_period + 1))
        self.btn_previous:getChildByName("redpoint"):setVisible(model:getLuckyDogPeriodRed(self.cur_select_period - 1))
    end
end

function ActionLuckyDogPanel:DeleteMe()
    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    doStopAllActions(self.txt_time_value)
    if self.task_scrollview then
        self.task_scrollview:DeleteMe()
    end
    self.task_scrollview = nil
    if self.update_holiday_common_event then
        GlobalEvent:getInstance():UnBind(self.update_holiday_common_event)
        self.update_holiday_common_event = nil
    end
    for i = 1, 4 do
        if self["item_scrollview" .. i] then
            self["item_scrollview" .. i]:DeleteMe()
            self["item_scrollview" .. i] = nil
        end
    end
    if self.resources_load ~= nil then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
    if self.update_dog_base_event then
        GlobalEvent:getInstance():UnBind(self.update_dog_base_event)
        self.update_dog_base_event = nil
    end
end

----------------------------------------
-- @Description:   幸运锦鲤任务item
----------------------------------------
ActionLuckyDogTaskItem =
    class(
    "ActionLuckyDogTaskItem",
    function()
        return ccui.Widget:create()
    end
)

function ActionLuckyDogTaskItem:ctor()
    self:configUI()
    self:registerEvent()
end

function ActionLuckyDogTaskItem:registerEvent()
    registerButtonEventListener(
        self.goto_btn,
        function()
            if self.jump_data and next(self.jump_data) then
                JumpController:getInstance():jumpViewByEvtData(self.jump_data)
            end
        end,
        true,
        1
    )
end

function ActionLuckyDogTaskItem:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("action/action_lucky_dog_task_item"))
    self.size = cc.size(200, 150)
    self:setTouchEnabled(true)
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:setContentSize(self.size)
    self:addChild(self.root_wnd)
    self.stamp_bg = self.root_wnd:getChildByName("stamp_bg")
    self.stamp = self.stamp_bg:getChildByName("stamp")
    self.main_container = self.root_wnd:getChildByName("main_container")
    self.goods_con = self.main_container:getChildByName("goods_con")
    self.ticket = self.main_container:getChildByName("ticket")
    self.txt_ticket = self.ticket:getChildByName("txt_ticket")
    self.goto_btn = self.main_container:getChildByName("goto_btn")
    self.goto_btn_label = self.goto_btn:getChildByName("label")
    self.goto_btn_label:setString(TI18N("前往"))
    self.task_value = self.main_container:getChildByName("task_value")
    self.task_desc = self.main_container:getChildByName("task_desc")

    local scroll_view_size = self.goods_con:getContentSize()
    local setting = {
        item_class = BackPackItem, -- 单元类
        start_x = 0, -- 第一个单元的X起点
        space_x = 10, -- x方向的间隔
        start_y = 0, -- 第一个单元的Y起点
        space_y = 0, -- y方向的间隔
        item_width = BackPackItem.Width * 0.5, -- 单元的尺寸width
        item_height = BackPackItem.Height * 0.5, -- 单元的尺寸height
        row = 1, -- 行数，作用于水平滚动类型
        col = 0, -- 列数，作用于垂直滚动类型
        scale = 0.5
    }
    self.reward_scroll = CommonScrollViewLayout.new(self.goods_con, cc.p(0, 0), ScrollViewDir.horizontal, ScrollViewStartPos.bottom, scroll_view_size, setting)
    self.reward_scroll:setClickEnabled(false)
    self.reward_scroll:setSwallowTouches(false)
end

function ActionLuckyDogTaskItem:setData(data)
    self.data = data
    self.award_config = Config.HolidayLuckyDogData.data_quest_award
    self.task_config = Config.HolidayLuckyDogData.data_quest
    if not self.data or not self.award_config or not self.task_config then
        return
    end
    self.reward_scroll:setData(list)
    self.reward_scroll:addEndCallBack(
        function()
            local list = self.reward_scroll:getItemList()
            for k, v in pairs(list) do
                v:setDefaultTip()
                v:setSwallowTouches(false)
            end
        end
    )
    if data.num == 0 then --未完成
        self.goods_con:setVisible(false)
        self.stamp_bg:setVisible(false)
        self.ticket:setVisible(false)
        self.task_desc:setVisible(true)
        self.task_value:setVisible(true)
        self.goto_btn:setVisible(true)
        self:setTaskBtn()
        self:setTaskTxt()
        self.jump_data = {}
        if self.task_config and self.task_config[self.data.quest_id] then
            table_insert(self.jump_data, self.task_config[self.data.quest_id].jump_id)
            if self.task_config[self.data.quest_id].condition[4] and next(self.task_config[self.data.quest_id].condition[4]) then
                for k, v in pairs(self.task_config[self.data.quest_id].condition[4]) do
                    table_insert(self.jump_data, v)
                end
            end
        end
    else --已完成
        self.goods_con:setVisible(true)
        self.stamp_bg:setVisible(true)
        self.ticket:setVisible(true)
        self.task_desc:setVisible(false)
        self.task_value:setVisible(false)
        self.goto_btn:setVisible(false)
        self:setTicketNum()
        if data.state == 0 or data.lucky_type == 0 then --未开奖或未中奖
            self.stamp_bg:setVisible(false)
            self.goods_con:setVisible(false)
            self.task_desc:setVisible(true)
            self.task_value:setVisible(true)
            self:setTaskTxt()
        else
            self:setStamp()
            self:setRewardData()
        end
    end
end

-- 设置章
function ActionLuckyDogTaskItem:setStamp()
    if self.data.lucky_type == 4 then
        self.stamp:setContentSize(cc.size(80, 24))
    else
        self.stamp:setContentSize(cc.size(106, 24))
    end
    self.stamp:loadTexture(PathTool.getResFrame("luckydog", "luckydog_stamp_" .. self.data.lucky_type), LOADTEXT_TYPE_PLIST)
end

-- 设置任务描述和完成度
function ActionLuckyDogTaskItem:setTaskTxt()
    if self.task_config and self.task_config[self.data.quest_id] then
        self.task_desc:setString(self.task_config[self.data.quest_id].desc or "")
        if self.task_config[self.data.quest_id].condition and self.task_config[self.data.quest_id].condition[3] then
            local str = (self.data.val or 0) .. "/" .. self.task_config[self.data.quest_id].condition[3]
            self.task_value:setString(str)
        end
    end
end

-- 设置奖励
function ActionLuckyDogTaskItem:setRewardData()
    if self.award_config and self.award_config[self.data.period] and self.award_config[self.data.period][self.data.lucky_type] then
        -- 设置奖励
        local list = {}
        for k, v in ipairs(self.award_config[self.data.period][self.data.lucky_type].award) do
            local vo = deepCopy(Config.ItemData.data_get_data(v[1]))
            if vo then
                vo.quantity = v[2]
                table_insert(list, vo)
            end
        end
        self.reward_scroll:setData(list)
    end
end

-- 设置按钮
function ActionLuckyDogTaskItem:setTaskBtn()
    if self.data.num == 0 then --未完成
        if self.data.state == 0 then --未开奖
            setChildUnEnabled(false, self.goto_btn)
            self.goto_btn_label:enableOutline(Config.ColorData.data_color4[263], 2)
            self.goto_btn_label:setString(TI18N("前往"))
            self.goto_btn:setEnabled(true)
        else
            setChildUnEnabled(true, self.goto_btn)
            self.goto_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
            self.goto_btn_label:setString(TI18N("未完成"))
            self.goto_btn:setEnabled(false)
        end
    end
end

-- 设置奖票号码
function ActionLuckyDogTaskItem:setTicketNum()
    self.txt_ticket:setString(tostring(self.data.num))
end

function ActionLuckyDogTaskItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end
