--------------------------------------------
-- @Author  : yuanqi
-- @Date    : 2020年1月5日
-- @description    :
-- 不放回抽奖选择自选奖励
---------------------------------
ActionFortuneBagSelectWindow = ActionFortuneBagSelectWindow or BaseClass(BaseView)

local controller = ActionController:getInstance()
local model = controller:getModel()

local table_insert = table.insert
local table_sort = table.sort
local string_format = string.format

function ActionFortuneBagSelectWindow:__init()
    self.camp_id = model:getFortuneBagCampId()
    self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.res_list = {}
    self.layout_name = "action/action_fortune_bag_select_window"
end

function ActionFortuneBagSelectWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    local main_panel = self.main_container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("设置终极大奖"))

    self.close_btn = main_panel:getChildByName("close_btn")

    self.comfirm_btn = self.main_container:getChildByName("comfirm_btn")
    self.comfirm_btn_label = self.comfirm_btn:getChildByName("label")
    self.comfirm_btn_label:setString(TI18N("确 定"))
    self.cancel_btn = self.main_container:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("取 消"))

    self.lay_srollview = self.main_container:getChildByName("lay_srollview")

    self.tips_label = self.main_container:getChildByName("tips_label")
    self.tips_label:setString(TI18N("选择本轮终极大奖"))
end

function ActionFortuneBagSelectWindow:register_event()
    registerButtonEventListener(
        self.background,
        function()
            self:onClosedBtn()
        end,
        false,
        2
    )
    registerButtonEventListener(
        self.close_btn,
        function()
            self:onClosedBtn()
        end,
        true,
        2
    )
    registerButtonEventListener(
        self.comfirm_btn,
        function()
            self:onComfirmBtn()
        end,
        true,
        1
    )
    registerButtonEventListener(
        self.cancel_btn,
        function()
            self:onCancelBtn()
        end,
        true,
        1
    )

    if not self.update_fortune_bag_ultimate_event then
        self.update_fortune_bag_ultimate_event =
            GlobalEvent:getInstance():Bind(
            ActionEvent.FORTUNE_BAG_ULTIMATE_EVENT,
            function(data)
                if not data then
                    return
                end
                self:setPanelData(data)
            end
        )
    end
end

--关闭
function ActionFortuneBagSelectWindow:onClosedBtn()
    controller:openFortuneBagSelectWindow(false)
end

--确定
function ActionFortuneBagSelectWindow:onComfirmBtn()
    if self.select_type_id and self.select_type_id ~= 0 then
        controller:sender28305(self.select_type_id)
    end
    self:onClosedBtn()
end

--取消
function ActionFortuneBagSelectWindow:onCancelBtn()
    self:onClosedBtn()
end

function ActionFortuneBagSelectWindow:openRootWnd(data)
    if not data then
        return
    end
    self.cur_round = data.cur_round or 0
    self.select_type_id = data.select_type_id or 0
    controller:sender28303()
end

function ActionFortuneBagSelectWindow:setPanelData(data)
    if not data then
        return
    end
    self.data = data
    if self.item_scrollview == nil then
        local scroll_view_size = self.lay_srollview:getContentSize()
        local width = scroll_view_size.width / 4
        local setting = {
            start_x = 0, -- 第一个单元的X起点
            space_x = 0, -- x方向的间隔
            start_y = 0, -- 第一个单元的Y起点
            space_y = 0, -- y方向的间隔
            item_width = width, -- 单元的尺寸width
            item_height = 158, -- 单元的尺寸height
            row = 1, -- 行数，作用于水平滚动类型
            col = 4, -- 列数，作用于垂直滚动类型
            once_num = 1 -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.lay_srollview, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self, self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end

    local item_list_data = {}
    local ultimate_config = Config.HolidayOptionalLotteryData.data_optional_award[self.camp_id]
    for k, v in pairs(data.award_list) do
        local item_data = {}
        if ultimate_config[v.type_id] then
            item_data.rewards = ultimate_config[v.type_id].rewards
            item_data.get_count = v.get_count
            item_data.count = v.count
            item_data.round = v.round
            item_data.cur_round = self.cur_round
            item_data.type_id = v.type_id
            table_insert(item_list_data, item_data)
        end
    end
    table_sort(
        item_list_data,
        function(a, b)
            if b.round > a.round then
                return true
            elseif b.round == a.round then
                return b.type_id > a.type_id
            end
        end
    )
    self.show_list = item_list_data or {}
    self.item_scrollview:reloadData()
end

--创建cell
--@width 是setting.item_width
--@height 是setting.item_height
function ActionFortuneBagSelectWindow:createNewCell(width, height)
    local cell = ccui.Widget:create()
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(0.5, 0)
    cell:setContentSize(cc.size(width, height))
    cell.goods_item = BackPackItem.new(true, true, false, nil, nil, false)
    cell.goods_item:setPosition(width * 0.5, 90)
    cell:addChild(cell.goods_item)
    cell.txt_surplus_count = createLabel(22, Config.ColorData.data_color4[175], nil, width * 0.5, 5, nil, cell, nil, cc.p(0.5, 0))

    if cell.lay_select == nil then
        local _x, _y = cell.goods_item:getPosition()
        local size = cell.goods_item:getContentSize()
        cell.lay_select = ccui.Layout:create()
        cell.lay_select:setAnchorPoint(cc.p(0.5, 0.5))
        cell.lay_select:setContentSize(size)
        cell.lay_select:setPosition(_x, _y)
        cell.lay_select:setTouchEnabled(false)
        showLayoutRect(cell.lay_select, 150)
        local res = PathTool.getResFrame("common", "common_1043")
        createImage(cell.lay_select, res, size.width / 2, size.height / 2, cc.p(0.5, 0.5), true, 0, false)
        cell:addChild(cell.lay_select, 1)
        cell.lay_select:setVisible(false)
        cell.lay_lock = ccui.Layout:create()
        cell.lay_lock:setAnchorPoint(cc.p(0.5, 0.5))
        cell.lay_lock:setContentSize(size)
        cell.lay_lock:setPosition(_x, _y)
        cell.lay_lock:setTouchEnabled(false)
        showLayoutRect(cell.lay_lock, 150)
        local res = PathTool.getResFrame("common", "common_90009")
        createImage(cell.lay_lock, res, 0, size.height, cc.p(0, 1), true, 0, false)
        cell:addChild(cell.lay_lock, 1)
        cell.lay_lock:setVisible(false)
    end

    cell.goods_item:addCallBack(
        function()
            self:onCellTouched(cell)
        end
    )
    return cell
end

--获取数据数量
function ActionFortuneBagSelectWindow:numberOfCells()
    if not self.show_list then
        return 0
    end
    return #self.show_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ActionFortuneBagSelectWindow:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then
        return
    end
    if self.select_type_id == cell_data.type_id then
        cell.lay_select:setVisible(true)
        self.select_cell = cell
    end
    if cell_data.rewards and next(cell_data.rewards) ~= nil then
        local vo = {}
        vo = deepCopy(Config.ItemData.data_get_data(cell_data.rewards[1][1]))
        if vo ~= nil then
            vo.quantity = cell_data.rewards[1][2]
            cell.goods_item:setData(vo)
        end
    end
    if cell_data.cur_round >= cell_data.round then
        str = string_format("%d/%d", cell_data.count - cell_data.get_count, cell_data.count)
        cell.lay_lock:setVisible(false)
        cell.goods_item:setReceivedIcon(cell_data.get_count >= cell_data.count)
    else
        str = string_format(TI18N("第%d轮可选"), cell_data.round)
        cell.lay_lock:setVisible(true)
    end
    cell.txt_surplus_count:setString(str)
end

-- --点击cell .需要在 createNewCell 设置点击事件
function ActionFortuneBagSelectWindow:onCellTouched(cell, index)
    if not cell.index then
        return
    end
    local cell_data = self.show_list[cell.index]
    if not cell_data then
        return
    end

    if cell_data.cur_round >= cell_data.round then
        if cell_data.get_count >= cell_data.count then
            message(TI18N("已经没有可选次数了"))
            return
        end
    else
        message(TI18N("暂时未到可选轮次"))
        return
    end

    if self.select_cell and self.select_cell.goods_item then
        self.select_cell.lay_select:setVisible(false)
    end

    if self.select_type_id and self.select_type_id == cell_data.type_id then
        --取消选中
        self.select_type_id = nil
        self.select_cell = nil
        return
    else
        self.select_type_id = cell_data.type_id
        self.select_cell = cell
        if self.select_cell and self.select_cell.goods_item then
            self.select_cell.lay_select:setVisible(true)
        end
        return
    end
end

function ActionFortuneBagSelectWindow:close_callback()
    if self.update_fortune_bag_ultimate_event then
        GlobalEvent:getInstance():UnBind(self.update_fortune_bag_ultimate_event)
        self.update_fortune_bag_ultimate_event = nil
    end
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    controller:openFortuneBagSelectWindow(false)
end
