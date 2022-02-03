-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      装备熔炼拦截
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
BackPackEquipInterceptWindow = BackPackEquipInterceptWindow or BaseClass(BaseView)

local table_insert = table.insert
local controller = BackpackController:getInstance()

function BackPackEquipInterceptWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.ctrl = BackpackController:getInstance()
	self.model = self.ctrl:getModel()
	self.win_type = WinType.Mini
	self.layout_name = "backpack/backpack_equip_intercept_window"
end 

function BackPackEquipInterceptWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
    container:getChildByName("win_title"):setString(TI18N("熔炼确认"))
    container:getChildByName("sell_title"):setString(TI18N("选择熔炼装备中发现下列强力装备")) 

    self.cancel_btn = container:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("仍然熔炼"))

    self.confirm_btn = container:getChildByName("confirm_btn")
    self.confirm_btn_label = self.confirm_btn:getChildByName("label")
    self.confirm_btn_label:setString(TI18N("保留装备"))
    
    self.list_view = container:getChildByName("list_view")
    local size = self.list_view:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 16,                  -- 第一个单元的X起点
        space_x = 32,                    -- x方向的间隔
        start_y = 6,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = 119,               -- 单元的尺寸width
        item_height = 119,              -- 单元的尺寸height
        row = 4,                        -- 行数，作用于水平滚动类型
        col = 4,                         -- 列数，作用于垂直滚动类型
        once_num = 4,
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(self.list_view, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, size, setting)

    self.sell_desc = container:getChildByName("sell_desc")
    self.sell_desc:setString(TI18N("是否保留以上装备")) 
    self.close_btn = container:getChildByName("close_btn")
    self.container = container
end

function BackPackEquipInterceptWindow:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openBackPackEquipInterceptWindow(false)
        end
    end)
    self.background:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openBackPackEquipInterceptWindow(false)
        end
    end)
    self.cancel_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openSellWindow(true, BackPackConst.Bag_Code.EQUIPS, self.item_list) 
            controller:openBackPackEquipInterceptWindow(false)
        end
    end)

    self.confirm_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openBackPackEquipInterceptWindow(false)
            if self.goto_partner == true then
                MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.partner) 
            else
                controller:openSellWindow(true, BackPackConst.Bag_Code.EQUIPS, self.surplus_list) 
            end
        end
    end)
end

function BackPackEquipInterceptWindow:openRootWnd(list, intercept_list)
    self.item_list = list
    self.intercept_list = intercept_list
    self.surplus_list = {} 
    self.goto_partner = false
    self:checkInterceptList()
end

--==============================--
--desc:跳出可以被提出的物品列表
--time:2018-07-30 08:08:45
--@return 
--==============================--
function BackPackEquipInterceptWindow:checkInterceptList()
    if self.intercept_list == nil or next(self.intercept_list) == nil then return end
    if self.item_list == nil or next(self.item_list) == nil then return end

    local item_id_list = {}
    for i, vo in ipairs(self.intercept_list) do
        item_id_list[vo.id] = vo
    end

    -- 计算出剩余装备.
    self.surplus_list = {} 
    for i,v in ipairs(self.item_list) do
        if item_id_list[v.id] == nil then
            table_insert(self.surplus_list, v)
        end
    end

    -- 剩余装备可能是空的,这个时候就需要是确认跳转了
    if next(self.surplus_list) == nil then
        self.goto_partner = true
        self.sell_desc:setVisible(false)
        self.confirm_btn_label:setString(TI18N("前往穿戴"))
    end
    self:setInterceptEquipList()
end

--==============================--
--desc:显示将要被提出的物品
--time:2018-07-30 08:23:47
--@return 
--==============================--
function BackPackEquipInterceptWindow:setInterceptEquipList()
    if self.intercept_list == nil or next(self.intercept_list) == nil then return end
    local item_list = {}
    local _deepcopy = DeepCopy
    for i,v in ipairs(self.intercept_list) do
        table_insert(item_list, _deepcopy(v))
    end
    local sort_func = SortTools.tableUpperSorter({"quality", "gemstone_sort","sort"})
    -- local sort_func = SortTools.tableUpperSorter({"quality","lev"})
    table.sort(item_list, sort_func)
    self.item_scrollview:setData(item_list, nil, nil, {is_show_tips = true, is_other = false})
end

function BackPackEquipInterceptWindow:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    controller:openBackPackEquipInterceptWindow(false)
end


 