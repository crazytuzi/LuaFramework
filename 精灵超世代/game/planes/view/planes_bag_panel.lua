-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      位面背包 
-- <br/> 2019年12月12日
-- --------------------------------------------------------------------
PlanesBagPanel = PlanesBagPanel or BaseClass(BaseView)

local controller = PlanesController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local math_ceil = math.ceil


function PlanesBagPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "planes/planes_bag_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("planes","planes_map"), type = ResourcesType.plist }
    }

end

function PlanesBagPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_panel = self.main_container:getChildByName("main_panel")
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("探险背包"))

    self.scroll_container = self.main_container:getChildByName("scroll_container")


    self.bg_tips = self.main_container:getChildByName("bg_tips")
    self.bg_tips:setString(TI18N("背包的物品只在探险玩法中生效，玩法重置后背包将被清空"))    
end

function PlanesBagPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)


    self:addGlobalEvent(PlanesEvent.Iint_Bag_Data_Event, function(data)
        self:initData()
    end)

    self:addGlobalEvent(PlanesEvent.Update_Bag_Data_Event, function(data, is_add)
        if not is_add and self.item_scrollview then
            self.item_scrollview:resetCurrentItems()
        else
            self:initData()
        end
    end)

    self:addGlobalEvent(PlanesEvent.Delete_Bag_Data_Event, function(data)
        self:initData()
    end)
end

--关闭
function PlanesBagPanel:onClickBtnClose()
    controller:openPlanesBagPanel(false)
end

function PlanesBagPanel:openRootWnd(setting)
    local list = model:getPlanesBagData()
    if list == nil or next(list) == nil then
        controller:sender23112()
    else
        self:initData()
    end
end

function PlanesBagPanel:initData()
    local bag_data = model:getPlanesBagData() or {}
    if not bag_data then return end

    self.bag_list = {}
    for k,v in pairs(bag_data) do
        table_insert(self.bag_list, v)
    end
    local sort_func = SortTools.tableCommonSorter({{"id", false}})
    table_sort(self.bag_list, sort_func)
    self:updateList()
end


function PlanesBagPanel:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 2,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 119,                -- 单元的尺寸width
            item_height = 122,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 5,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    -- if #self.bag_list == 0 then
    --     commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无背包数据")})
    -- else
    --     commonShowEmptyIcon(self.scroll_container, false)
    -- end
    self.item_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function PlanesBagPanel:createNewCell(width, height)
    local cell = BackPackItem.new(true, true, false, 0.9)
    cell:setSwallowTouches(false)
    cell:setDefaultTip()
    return cell
end
--获取数据数量
function PlanesBagPanel:numberOfCells()
    if not self.bag_list then return 20 end
    local count = #self.bag_list
    if count < 20 then
        return 20
    else
        local num = math_ceil(count/5)
        return num * 5
    end
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function PlanesBagPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.bag_list[index]
    if cell_data then
        cell:setBaseData(cell_data.base_id, cell_data.num)
        -- cell:setData(cell_data)
    else
        cell:suspendAllActions()
    end
end


function PlanesBagPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    controller:openPlanesBagPanel(false)
end
