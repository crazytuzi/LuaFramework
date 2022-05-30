-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      ElitematchZoneListPanel 录像信息
-- <br/> 2019年3月6日
-- --------------------------------------------------------------------
ElitematchZoneListPanel = ElitematchZoneListPanel or BaseClass(BaseView)

local controller = ElitematchController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ElitematchZoneListPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "elitematch/elitematch_zone_list_panel"

    self.res_list = {
    }
end

function ElitematchZoneListPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)
    self.main_panel = self.main_container:getChildByName("main_panel")

  
    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("查看赛区"))



    self.tips = self.main_panel:getChildByName("tips")
    self.tips:setString(TI18N("在列表中选择需要查看的赛区"))
    self.scroll_container = self.main_container:getChildByName("scroll_container")
    self.close_btn = self.main_panel:getChildByName("close_btn")
end

function ElitematchZoneListPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 1)
    -- self:addGlobalEvent(VedioEvent.LOOK_VEDIO_EVENT, function(data)
    --     if not data then return end
    --     self:setData(data)
    -- end)
end

--关闭
function ElitematchZoneListPanel:onClickBtnClose()
    controller:openElitematchZoneListPanel(false)
end


--@vedio_id id
--@svr_id 服务器id
--@_type
function ElitematchZoneListPanel:openRootWnd(max_zone , callback)
   if not max_zone then return end
   self.callback = callback
    local config_list = Config.ArenaEliteData.data_zone
    self.show_list = {}
    if config_list then
        for i,v in ipairs(config_list) do
            if v.id <= max_zone then
                table_insert(self.show_list, v)
            end
        end
    end
    table.sort( self.show_list, function(a, b) return a.id < b.id end)
    self:updateList()
end

function ElitematchZoneListPanel:updateList(index)
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 600,                -- 单元的尺寸width
            item_height = 114   ,               -- 单元的尺寸height
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
        self:showEmptyIcon(true)
    else
        self:showEmptyIcon(false)
    end
    self.item_scrollview:reloadData()
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ElitematchZoneListPanel:createNewCell(width, height)
   local cell = ElitematchZoneItem.new(width, height)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ElitematchZoneListPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ElitematchZoneListPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

--点击cell .需要在 createNewCell 设置点击事件
function ElitematchZoneListPanel:onCellTouched(cell)
    local index = cell.index
    local data = self.show_list[index]
    if data then
        if self.callback then
            self.callback(data.id)
        end
        self:onClickBtnClose()
    end
end

function ElitematchZoneListPanel:showEmptyIcon(bool)
    if not self.empty_con and bool == false then return end
    local main_size = self.main_panel:getContentSize()
    if not self.empty_con then 
        local size = cc.size(200,200)
        self.empty_con = ccui.Widget:create()
        self.empty_con:setContentSize(size)
        self.empty_con:setAnchorPoint(cc.p(0.5,0))
        self.empty_con:setPosition(cc.p(main_size.width/2,330))
        self.main_panel:addChild(self.empty_con,10)
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3")
        local bg = createImage(self.empty_con, res, size.width/2, size.height/2, cc.p(0.5,0.5), false)
        self.empty_label = createLabel(26,Config.ColorData.data_color4[175],nil,size.width/2,-10,"",self.empty_con,0, cc.p(0.5,0))
    end
    local str = TI18N("暂无数据")
    self.empty_label:setString(str)
    self.empty_con:setVisible(bool)
end



function ElitematchZoneListPanel:close_callback()
    self.data = nil
    controller:openElitematchZoneListPanel(false)
end

------------------------------------------
-- 子项
ElitematchZoneItem = class("ElitematchZoneItem", function()
    return ccui.Widget:create()
end)

function ElitematchZoneItem:ctor(width, height)
    self:configUI(width, height)
    self:register_event()
end

function ElitematchZoneItem:configUI(width, height  )
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("elitematch/elitematch_zone_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.icon = main_container:getChildByName("icon")
    self.zone_name = main_container:getChildByName("zone_name")

    self.comfirm_btn = main_container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("查 看"))
end

function ElitematchZoneItem:register_event( )
    registerButtonEventListener(self.comfirm_btn, handler(self, self.onClickComfirmBtn) ,true, 2)
end

function ElitematchZoneItem:onClickComfirmBtn()
    if not self.data then return end
    if self.callback then
        self.callback()
    end
end

function ElitematchZoneItem:addCallBack(callback)
    self.callback = callback
end

function ElitematchZoneItem:setData(data)
    if not data then return end
    self.data = data
    
    local str = string_format("%s  %s", self.data.name, TI18N("赛区"))
    self.zone_name:setString(str)
 
    local bg_res = PathTool.getPlistImgForDownLoad("elitematch/elitematch_zone_icon",self.data.icon, false)
    self.item_load = loadSpriteTextureFromCDN(self.icon , bg_res, ResourcesType.single, self.item_load)
end

function ElitematchZoneItem:DeleteMe( )
    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end