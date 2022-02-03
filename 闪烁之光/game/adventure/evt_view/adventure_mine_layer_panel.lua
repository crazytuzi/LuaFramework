-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      我的矿脉信息
-- <br/> 2019年7月16日
-- --------------------------------------------------------------------
AdventureMineLayerPanel = AdventureMineLayerPanel or BaseClass(BaseView)

local controller = AdventureController:getInstance()
local model = controller:getUiModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function AdventureMineLayerPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "adventure/adventure_mine_layer_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("adventure","adventuremine"), type = ResourcesType.plist }
    }

end

function AdventureMineLayerPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("层数跳转"))

    self.scroll_container = self.main_container:getChildByName("scroll_container")


    self.right_btn = self.main_container:getChildByName("right_btn")
    self.right_btn:getChildByName("label"):setString(TI18N("继续冒险"))
    self.close_btn = self.main_panel:getChildByName("close_btn")
end

function AdventureMineLayerPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    registerButtonEventListener(self.right_btn, function() self:onClickBtnRight() end ,true, 1)


    self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_All_LAYER_INFO_EVENT, function(data)
        if not data then return end
        self.dic_floor_had = {}
        for i,v in ipairs(data.floor_list) do
            self.dic_floor_had[v.floor] = true
        end
        if self.item_scrollview then
            self.item_scrollview:resetCurrentItems()
        end
    end)
end

--关闭
function AdventureMineLayerPanel:onClickBtnClose()
    controller:openAdventureMineLayerPanel(false)
end

--继续冒险
function AdventureMineLayerPanel:onClickBtnRight()
    local base_data = model:getAdventureBaseData()
    if base_data  then 
        if base_data.id and base_data.id == base_data.current_id then
            if Config.AdventureMineData.data_floor_data[base_data.current_id] then
                --当最大层 和当前一致的时候.说明是在矿脉层 需要触发到下一层的操作
                controller:setMustChangeWindow()
                controller:send20620(13, AdventureEvenHandleType.handle, {}) 
            end
        else
            controller:requestEnterAdventure(true)    
        end
    else
        controller:requestEnterAdventure(true)
    end
    self:onClickBtnClose()
end

--@level_id 段位
function AdventureMineLayerPanel:openRootWnd(setting)
    local setting = setting or {}
    self.cur_floor = setting.floor
    self.dic_floor_had = {}
    self:setData()
    controller:send20653()
end

function AdventureMineLayerPanel:setData()
    local base_data = model:getAdventureBaseData()
    if base_data == nil then return end
    self.floor = base_data.pass_id or 0
    self.show_list = {}

    local config_list = Config.AdventureMineData.data_floor_data
    if config_list then
        for k,config in pairs(config_list) do
            if self.floor >= config.floor then 
                table_insert(self.show_list, config)
            end
        end
    end 
    table_sort(self.show_list, function(a, b) return a.floor > b.floor end)
    self:updateList()
end

function AdventureMineLayerPanel:updateList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 600,                -- 单元的尺寸width
            item_height = 122,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无灵矿层数据")})
    else
        commonShowEmptyIcon(self.scroll_container, false)
    end
    self.item_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function AdventureMineLayerPanel:createNewCell(width, height)
   local cell = AdventureMineLayerItem.new(width, height, self)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function AdventureMineLayerPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function AdventureMineLayerPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data, self.dic_floor_had[cell_data.floor])
end


function AdventureMineLayerPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    controller:openAdventureMineLayerPanel(false)
end


-- 子项
AdventureMineLayerItem = class("AdventureMineLayerItem", function()
    return ccui.Widget:create()
end)

function AdventureMineLayerItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function AdventureMineLayerItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("adventure/adventure_mine_layer_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.name = self.container:getChildByName("name")
    self.name_x = self.name:getPosition()
    self.have_icon = self.container:getChildByName("have_icon")

    self.desc_1 = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0,0.5), cc.p(self.name_x, 28), 6, nil, 900)
    self.container:addChild(self.desc_1)

    self.goto_btn = self.container:getChildByName("goto_btn")
    self.goto_btn:getChildByName("label"):setString(TI18N("前 往"))
end

function AdventureMineLayerItem:register_event( )
    registerButtonEventListener(self.goto_btn, function() self:onGotoBtn()  end ,true, 1)
end

--选择
function AdventureMineLayerItem:onGotoBtn()
    if not self.data then return end
    if not self.parent then return end
    if self.parent.cur_floor == nil or self.parent.cur_floor ~= self.data.floor then
        controller:requestEnterAdventureMine(self.data.floor)
    end
    self.parent:onClickBtnClose()
end


--@data  是 表数据:Config.AdventureMineData.data_floor_data
function AdventureMineLayerItem:setData(data, is_have)
    if not data then return end
    self.data = data

    self.name:setString(self.data.name)
    if is_have then
        self.have_icon:setVisible(true)
        local size = self.name:getContentSize()
        self.have_icon:setPositionX(self.name_x + size.width + 10)
    else
        self.have_icon:setVisible(false)
    end
    if self.data.min_produce and next(self.data.min_produce) ~= nil then
        local item_id = self.data.min_produce[1][1]
        local num = model:getMineRate(self.data.floor, self.data.min_produce[1][2]) --求出衰减数量
        local item_config  = Config.ItemData.data_get_data(item_id)
        if item_config then
            local res = PathTool.getItemRes(item_config.icon)
            local str = string_format(TI18N("最低产出：<img src=%s scale=0.3 />%s/m"),res, num)
            self.desc_1:setString(str)
        end
    end
end

function AdventureMineLayerItem:DeleteMe()
    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end