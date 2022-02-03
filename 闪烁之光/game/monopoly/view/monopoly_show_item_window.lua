---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/10/28 21:14:57
-- @description: 大富翁图例说明
---------------------------------
local _controller = MonopolyController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

MonopolyShowItemWindow = MonopolyShowItemWindow or BaseClass(BaseView)

function MonopolyShowItemWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "monopoly/monopoly_item_show_window"
end

function MonopolyShowItemWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container
    self:playEnterAnimatianByObj(main_container , 2) 
    
    main_container:getChildByName("win_title"):setString(TI18N("图例说明"))
    self.close_btn = main_container:getChildByName("close_btn")
    
    local item_list = main_container:getChildByName("item_list")
    local bgSize = item_list:getContentSize()
	local scroll_view_size = cc.size(bgSize.width, bgSize.height)
    local setting = {
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 8,                   -- y方向的间隔
        item_width = 600,               -- 单元的尺寸width
        item_height = 142,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewSingleLayout.new(item_list, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)

    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.item_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
end

function MonopolyShowItemWindow:_createNewCell()
    local cell = MonopolyShowItem.new()
    return cell
end

function MonopolyShowItemWindow:_numberOfCells()
    if not self.show_data then return 0 end
    return #self.show_data
end

function MonopolyShowItemWindow:_updateCellByIndex(cell, index)
    if not self.show_data then return end
    cell.index = index
    local cell_data = self.show_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function MonopolyShowItemWindow:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
end

function MonopolyShowItemWindow:onClickCloseBtn()
    _controller:openMonopolyItemShowWindow(false)
end

function MonopolyShowItemWindow:openRootWnd()
    self:setData()
end

function MonopolyShowItemWindow:setData()
    self.show_data = {}
    for k, v in pairs(Config.MonopolyMapsData.data_item_show) do
        _table_insert(self.show_data, v)
    end
    table.sort(self.show_data, SortTools.KeyLowerSorter("id"))

    self.item_scrollview:reloadData()
end

function MonopolyShowItemWindow:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    _controller:openMonopolyItemShowWindow(false)
end

-------------------------@item
MonopolyShowItem = class("MonopolyShowItem", function()
    return ccui.Widget:create()
end)

function MonopolyShowItem:ctor()
	self:configUI()
	self:register_event()
end

function MonopolyShowItem:configUI()
    self.size = cc.size(600, 142)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("monopoly/monopoly_show_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.title_txt = container:getChildByName("title_txt")
    self.desc_txt = createRichLabel(20, cc.c4b(142,129,119,255), cc.p(0, 1), cc.p(123, 80), 5, nil, 445)
    container:addChild(self.desc_txt)
end

function MonopolyShowItem:register_event()
    
end

function MonopolyShowItem:setData(data)
    if not data then return end

    self.title_txt:setString(data.title or "")
    self.desc_txt:setString(data.desc or "")

    local item_cfg = Config.ItemData.data_get_data(data.item_bid)
    if not self.item_node then
        self.item_node = BackPackItem.new(true, true, false, 0.8)
        self.item_node:setPosition(67, 71)
        self.container:addChild(self.item_node)
    end
    self.item_node:setData(item_cfg)
end

function MonopolyShowItem:DeleteMe()
    if self.item_node then
        self.item_node:DeleteMe()
        self.item_node = nil
    end
end
