--------------------------------------------
-- @Author  : yuanqi
-- @Editor  : yuanqi
-- @Date    : 2019-1-4
-- @description    :
-- 不放回抽奖规则
---------------------------------

local controller = ActionController:getInstance()
local model = controller:getModel()
local _table_insert = table.insert

ActionFortuneBagRuleWindow = ActionFortuneBagRuleWindow or BaseClass(BaseView)

function ActionFortuneBagRuleWindow:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false
    self.layout_name = "action/action_fortune_bag_rule_window"
    self.camp_id = model:getFortuneBagCampId()
    self.rule_data = {}
end

function ActionFortuneBagRuleWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background then
        self.background:setScale(display.getMaxScale())
    end

    local container = self.root_wnd:getChildByName("container")
    self.container = container
    self:playEnterAnimatianByObj(self.container, 2)
    local win_title = container:getChildByName("win_title")
    win_title:setString(TI18N("奖励详情"))

    self.close_btn = container:getChildByName("close_btn")

    local list_panel = container:getChildByName("list_panel")
    self.scroll_size = list_panel:getContentSize()
    self.desc_scrollview = createScrollView(self.scroll_size.width, self.scroll_size.height, 0, 0, list_panel)
end

function ActionFortuneBagRuleWindow:register_event()
    registerButtonEventListener(
        self.close_btn,
        function()
            controller:openFortuneBagRuleWindow(false)
        end,
        false,
        2
    )

    if not self.update_fortune_bag_surplus_event then
        self.update_fortune_bag_surplus_event =
            GlobalEvent:getInstance():Bind(
            ActionEvent.FORTUNE_BAG_SURPLUS_EVENT,
            function(data)
                if not data then
                    return
                end
                self:setPanelData(data)
            end
        )
    end
end

function ActionFortuneBagRuleWindow:openRootWnd(rule_data)
    self.rule_data = rule_data
    controller:sender28301()
end

function ActionFortuneBagRuleWindow:setPanelData(data)
    if not self.rule_data or not data then
        return
    end

    local container_height = 0

    local pro_config = data

    local up_con_height = 0
    if pro_config and pro_config.award_list then
        -- 本轮道具剩余数量
        if not self.title_bg_1 then
            self.title_bg_1 = createImage(self.desc_scrollview, PathTool.getResFrame("common", "common_90090"), 0, 0, cc.p(0, 1), true, nil, true)
            self.title_bg_1:setCapInsets(cc.rect(2, 10, 2, 2))
            self.title_bg_1:setContentSize(cc.size(205, 36))
            local tempLab = TI18N("本轮剩余数量")
            local title_txt_1 = createLabel(24, 274, nil, 10, 18, tempLab, self.title_bg_1, nil, cc.p(0, 0.5))
        end

        if not self.info_bg_1 then
            self.info_bg_1 = createImage(self.desc_scrollview, PathTool.getResFrame("common", "common_90024"), self.scroll_size.width * 0.5, 0, cc.p(0.5, 1), true, nil, true)
            self.info_bg_1:setContentSize(cc.size(614, 260))
        end

        if not self.info_title_bg_1 then
            self.info_title_bg_1 = createImage(self.desc_scrollview, PathTool.getResFrame("common", "common_90025"), self.scroll_size.width * 0.5, 0, cc.p(0.5, 1), true, nil, true)
            self.info_title_bg_1:setContentSize(cc.size(610, 44))

            self.line_1 = createImage(self.info_title_bg_1, PathTool.getResFrame("common", "common_1069"), 305, 22, cc.p(0.5, 0.5), true, nil, true)
            self.line_1:setContentSize(cc.size(2, 40))

            local tempLab = TI18N("道具剩余数量")
            local info_title_txt_1 = createLabel(24, 116, nil, 152, 22, TI18N("道具"), self.info_title_bg_1, nil, cc.p(0.5, 0.5))
            local info_title_txt_2 = createLabel(24, 116, nil, 457, 22, TI18N("剩余数量"), self.info_title_bg_1, nil, cc.p(0.5, 0.5))
        end

        local scroll_view_size = cc.size(584, 200)
        if self.num_scrollview == nil then
            local setting = {
                start_x = 0, -- 第一个单元的X起点
                space_x = 0, -- x方向的间隔
                start_y = 0, -- 第一个单元的Y起点
                space_y = 5, -- y方向的间隔
                item_width = 584, -- 单元的尺寸width
                item_height = 30, -- 单元的尺寸height
                row = 1, -- 行数，作用于水平滚动类型
                col = 1, -- 列数，作用于垂直滚动类型
                once_num = 1 -- 每次创建的数量
            }

            self.num_scrollview = CommonScrollViewSingleLayout.new(self.desc_scrollview, cc.p(0, 990), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 1))

            self.num_scrollview:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
            self.num_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
            self.num_scrollview:registerScriptHandlerSingle(handler(self, self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        end
        local num_config_list = {}
        local normal_config = Config.HolidayOptionalLotteryData.data_normal_award[self.camp_id][self.rule_data.round]
        local ultimate_config = Config.HolidayOptionalLotteryData.data_optional_award[self.camp_id]
        local type_id_list = {}
        if normal_config then
            for k, v in pairs(normal_config) do
                if type_id_list[v.type_id] == nil then
                    type_id_list[v.type_id] = {}
                    type_id_list[v.type_id].sum_count = 1
                    type_id_list[v.type_id].rewards = v.rewards
                else
                    type_id_list[v.type_id].sum_count = type_id_list[v.type_id].sum_count + 1
                end
            end
        end

        if self.rule_data.optional_id and ultimate_config[self.rule_data.optional_id] then
            type_id_list[self.rule_data.optional_id] = {}
            type_id_list[self.rule_data.optional_id].sum_count = 1
            type_id_list[self.rule_data.optional_id].rewards = ultimate_config[self.rule_data.optional_id].rewards
        end

        -- if ultimate_config then
        --     for k, v in pairs(ultimate_config) do
        --         if type_id_list[v.type_id] == nil then
        --             type_id_list[v.type_id] = {}
        --             type_id_list[v.type_id].sum_count = 1
        --             type_id_list[v.type_id].rewards = v.rewards
        --         else
        --             type_id_list[v.type_id].sum_count = type_id_list[v.type_id].sum_count + v.count
        --         end
        --     end
        -- end

        for k, v in pairs(type_id_list) do
            v.count = v.sum_count
            for k1, v1 in pairs(pro_config.award_list) do
                if v1.type_id == k then
                    v.count = v.sum_count - v1.get_count
                end
            end
            _table_insert(num_config_list, v)
        end

        self.num_config = num_config_list
        self.num_scrollview:reloadData()

        up_con_height = 54 + scroll_view_size.height + 60

        container_height = up_con_height
    end

    -- 描述内容
    local desc_height = 0
    if self.rule_data then
        local constant_cfg = Config.HolidayOptionalLotteryData.data_constant
        if constant_cfg then
            if not self.title_bg_2 then
                self.title_bg_2 = createImage(self.desc_scrollview, PathTool.getResFrame("common", "common_90090"), 0, 0, cc.p(0, 1), true, nil, true)
                self.title_bg_2:setCapInsets(cc.rect(2, 10, 2, 2))
                self.title_bg_2:setContentSize(cc.size(205, 36))

                local title_txt_2 = createLabel(24, 274, nil, 10, 18, TI18N("内容详情"), self.title_bg_2, nil, cc.p(0, 0.5))
            end
            if not self.award_desc then
                self.award_desc = createRichLabel(22, cc.c4b(0x64, 0x32, 0x23, 0xff), cc.p(0.5, 1), cc.p(self.scroll_size.width * 0.5, 430), 10, nil, 580)
                self.desc_scrollview:addChild(self.award_desc)
            end
            self.award_desc:setString(constant_cfg.rules.desc or "")
            local desc_size = self.award_desc:getContentSize()

            desc_height = desc_size.height + 54 + 10
            container_height = container_height + desc_height
        end
    end

    local max_height
    if container_height + 50 <= self.scroll_size.height then
        self.desc_scrollview:setTouchEnabled(false)
        max_height = self.scroll_size.height
    else
        self.desc_scrollview:setTouchEnabled(true)
        max_height = container_height + 50
    end

    self.desc_scrollview:setInnerContainerSize(cc.size(self.scroll_size.width, max_height))
    if self.title_bg_1 then
        self.title_bg_1:setPositionY(max_height)
    end

    if self.info_title_bg_1 then
        self.info_title_bg_1:setPositionY(max_height - 42)
    end

    if self.info_bg_1 then
        self.info_bg_1:setPositionY(max_height - 40)
    end

    if self.num_scrollview then
        self.num_scrollview:setPositionY(max_height - 90)
    end
    if self.title_bg_2 then
        self.title_bg_2:setPositionY(max_height - up_con_height)
    end
    if self.award_desc then
        self.award_desc:setPositionY(max_height - up_con_height - 54)
    end
end

--创建cell
--@width 是setting.item_width
--@height 是setting.item_height
function ActionFortuneBagRuleWindow:createNewCell()
    local cell = ActionFortuneBagRuleItem.new()
    return cell
end

--获取数据数量
function ActionFortuneBagRuleWindow:numberOfCells()
    if not self.num_config then
        return 0
    end
    return #self.num_config
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ActionFortuneBagRuleWindow:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.num_config[index]
    if not cell_data then
        return
    end
    local time_desc = cell:setData(cell_data)
end

function ActionFortuneBagRuleWindow:close_callback()
    doStopAllActions(self.desc_scrollview)
    if self.num_scrollview then
        self.num_scrollview:DeleteMe()
    end
    self.num_scrollview = nil
    if self.update_fortune_bag_surplus_event then
        GlobalEvent:getInstance():UnBind(self.update_fortune_bag_surplus_event)
        self.update_fortune_bag_surplus_event = nil
    end
    controller:openFortuneBagRuleWindow(false)
end

-------------------@ item
ActionFortuneBagRuleItem =
    class(
    "ActionFortuneBagRuleItem",
    function()
        return ccui.Widget:create()
    end
)

function ActionFortuneBagRuleItem:ctor()
    self:configUI()
    self:register_event()
end

function ActionFortuneBagRuleItem:configUI()
    self.size = cc.size(584, 30)
    self:setTouchEnabled(false)
    self:setAnchorPoint(cc.p(0, 1))
    self:setContentSize(self.size)

    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setContentSize(self.size)
    self:addChild(self.root_wnd)

    self.name_text = createLabel(24, 274, nil, 169, self.size.height / 2, "", self.root_wnd, nil, cc.p(0.5, 0.5))
    --名字
    self.num_text = createLabel(24, 274, nil, 473, self.size.height / 2, "", self.root_wnd, nil, cc.p(0.5, 0.5))
    --数量
end

function ActionFortuneBagRuleItem:register_event()
end

function ActionFortuneBagRuleItem:setData(data)
    if not data then
        return
    end

    self.name_text:setTextColor(Config.ColorData.data_color4[274])
    self.num_text:setTextColor(Config.ColorData.data_color4[274])
    local item_config = Config.ItemData.data_get_data(data.rewards[1][1])
    if item_config then
        self.name_text:setString(string.format("%s*%d", item_config.name, data.rewards[1][2]))
    end
    self.name_text:setTextColor(BackPackConst.getWhiteQualityColorC4B(item_config.quality))

    --数量

    self.num_text:setString(string.format("%d/%d", data.count, data.sum_count))
end

function ActionFortuneBagRuleItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end
