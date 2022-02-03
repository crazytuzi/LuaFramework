-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      选择荣誉icon界面
-- <br/> 2019年5月30日
-- --------------------------------------------------------------------
RoleSelectHonorListPanel = RoleSelectHonorListPanel or BaseClass(BaseView)

local controller = RoleController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove
local table_sort = table.sort

function RoleSelectHonorListPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "roleinfo/role_select_honor_list_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("rolehonorwall","rolehonorwall"), type = ResourcesType.plist },
    }

end

function RoleSelectHonorListPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1)

    local main_panel = self.main_container:getChildByName("main_panel")
    self.title = main_panel:getChildByName("win_title")
    self.title:setString(TI18N("展示设置"))

    self.close_btn = main_panel:getChildByName("close_btn")

    --台子
    self.title_img = self.main_container:getChildByName("title_img")

    local res = PathTool.getPlistImgForDownLoad("bigbg/rolepersonalspace", "role_honor_wall_desk", false)
    self.item_load_title_img = loadSpriteTextureFromCDN(self.title_img, res, ResourcesType.single, self.item_load_title_img) 
    
    self.item_load_list = {}
    self.item_list = {}
    for i=1,3 do
        local item_bg = self.main_container:getChildByName("item_bg_"..i)
        self.item_list[i] = {}
        self.item_list[i].item_btn = item_bg
        local item_node = item_bg:getChildByName("item_node")
        self.item_list[i].honor_item = RoleHonorItem.new(0.6)
        item_node:addChild(self.item_list[i].honor_item)

        self.item_list[i].change_img = item_bg:getChildByName("lock_img")
    end 

    self.lay_srollview = self.main_container:getChildByName("lay_srollview")

    self.tip_name = self.main_container:getChildByName("tip_name")
    self.tip_name:setString(TI18N("选择展示的徽章将其显示在个人信息面板中"))
end

function RoleSelectHonorListPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose), false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose), true, 2)

    for i,v in ipairs(self.item_list) do
        registerButtonEventListener(v.item_btn, function() self:onChangeBtn(i) end, false, 1)        
    end
    -- 卸载 装备 返回
    self:addGlobalEvent(RoleEvent.ROLE_UPDATE_HONOR_WALL_EVENT, function(data)
        if not data then return end
        if not self.show_list then return end
        self:updateEquipInfo(data)
    end)
end

--关闭
function RoleSelectHonorListPanel:onClickBtnClose()
    controller:openRoleSelectHonorListPanel(false)
end

function RoleSelectHonorListPanel:onChangeBtn(pos)
    if not self.item_list then return end
    if self.item_list[pos] and self.item_list[pos].can_touch then 
        for i,item in ipairs(self.item_list) do
            item.can_touch = false
            item.change_img:setVisible(false)
        end
        if self.select_index ~= 0 and self.show_list[self.select_index] then
            local id = self.show_list[self.select_index].id
            controller:send25805(pos, id)
        end
    end
end

function RoleSelectHonorListPanel:updateEquipInfo(data)
    if data.id == 0 then
        --卸下
        if self.honor_list[data.pos] then
            self.dic_honor_data[self.honor_list[data.pos].id] = nil
        end
        self.honor_list[data.pos] = nil
        self:updateItemByindex(data.pos)

        for i,item in ipairs(self.item_list) do
            item.can_touch = false
            item.change_img:setVisible(false)
        end
    else
        --装备
        local new_data = {pos = data.pos, id = data.id}
        self.honor_list[data.pos] = new_data
        self.dic_honor_data = {}
        for k,v in pairs(self.honor_list) do
            self.dic_honor_data[v.id] = v
        end
        self.dic_honor_data[data.id] = new_data
        self:updateItemByindex(data.pos, new_data)
    end

    if self.list_view then
        self.list_view:resetCurrentItems()
    end
end


--@ pos 技能位置
function RoleSelectHonorListPanel:openRootWnd(setting)
    --荣誉数据
    local setting = setting or {}
    self.honor_list = setting.use_honor_icon_list
    if not self.honor_list then return end
    self.show_list = setting.active_list or {}

    self.dic_honor_data = {}

    for i,v in ipairs(self.item_list) do
        if self.honor_list[i] then
            self.dic_honor_data[self.honor_list[i].id] = self.honor_list[i]
            self:updateItemByindex(i, self.honor_list[i])
        else
            self:updateItemByindex(i)
        end
    end

    self:updateHonorList()
end

function RoleSelectHonorListPanel:updateItemByindex(index, data)
    if self.item_list[index] then
        if data then
            self.item_list[index].honor_item:setVisible(true)
            self.item_list[index].change_img:setVisible(false)
            self.item_list[index].honor_item:setData(data)
            self.item_list[index].honor_item:setShowEffect(true)
        else
            self.item_list[index].honor_item:setVisible(false)
            self.item_list[index].change_img:setVisible(false)
        end
    end
end

--显示可替换图片
function RoleSelectHonorListPanel:showChangeImg()
    for i,item in ipairs(self.item_list) do
        if self.honor_list[i] then
            item.change_img:setVisible(true)
            item.can_touch = true
        else
            item.change_img:setVisible(false)
        end
    end
end

--检查是否有空位置可方法
-- @ return 是否有空位, 空位索引
function RoleSelectHonorListPanel:checkHonorList()
    for i,item in ipairs(self.item_list) do
        if self.honor_list[i] == nil then
            return true, i
        end
    end
    return false
end

--创建英雄列表 
function RoleSelectHonorListPanel:updateHonorList()
    if not self.show_list then return end
    if self.list_view == nil then
        local scroll_view_size = self.lay_srollview:getContentSize()
        local list_setting = {
            start_x = 1,
            space_x = 0,
            start_y = 0,
            space_y = 0,
            item_width = 152,
            item_height = 134,
            row = 0,
            col = 4,
            need_dynamic = true
        }
        self.list_view = CommonScrollViewSingleLayout.new(self.lay_srollview, cc.p(0, 0), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0, 0)) 

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        -- self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end

    local sort_func = SortTools.tableCommonSorter({{"id", false}})
    table_sort(self.show_list, sort_func)

    self.list_view:reloadData()

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.lay_srollview, true, {text = TI18N("还没有徽章哦，快去收集吧~")})
    else
        commonShowEmptyIcon(self.lay_srollview, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function RoleSelectHonorListPanel:createNewCell(width, height)
    local cell = RoleSelectHonorItem.new(width, height)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function RoleSelectHonorListPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function RoleSelectHonorListPanel:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if not data then return end
    cell:setData(data)
    if self.select_index and self.select_index == index then
        cell:setSelect(true)
    else
        cell:setSelect(false)
    end

    if self.dic_honor_data[data.id] then
        cell:setBoxVisible(true)
    else
        cell:setBoxVisible(false)
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function RoleSelectHonorListPanel:onCellTouched(cell)
    local index = cell.index
    local data = self.show_list[index]
    if not data then return end

    if self.select_cell then
        self.select_cell:setSelect(false)
    end
    self.select_cell = cell
    self.select_cell:setSelect(true)
    self.select_index = index

    --说明在装备中 要卸下
    if self.dic_honor_data[data.id] ~= nil then
        controller:send25805(self.dic_honor_data[data.id].pos, 0)
    else
        local is_have, pos_index = self:checkHonorList()
        if is_have then
            -- 有位置 要装备
            controller:send25805(pos_index, data.id)
        else
            self:showChangeImg()
        end    
    end 
end



function RoleSelectHonorListPanel:close_callback()
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end 

    if self.item_load_title_img then 
        self.item_load_title_img:DeleteMe()
        self.item_load_title_img = nil
    end

    if self.item_list then
        for i,v in ipairs(self.item_list) do
            if v.item_load then
                v.item_load:DeleteMe()
                v.item_load = nil
            end
        end
    end


    controller:openRoleSelectHonorListPanel(false)
end


-- 子项
RoleSelectHonorItem = class("RoleSelectHonorItem", function()
    return ccui.Widget:create()
end)

function RoleSelectHonorItem:ctor(width, height)
    self:configUI(width, height)
    self:register_event()
end

function RoleSelectHonorItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("roleinfo/role_select_honor_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setSwallowTouches(false)
    self.icon = self.main_container:getChildByName("icon")

    local item_node = self.main_container:getChildByName("item_node")
    self.honor_item = RoleHonorItem.new(0.6)
    item_node:addChild(self.honor_item)
    self.select_img = self.main_container:getChildByName("select_img")
    self.checkbox = self.main_container:getChildByName("checkbox")
end

function RoleSelectHonorItem:register_event( )
    registerButtonEventListener(self.main_container, function() 
        if self.callback then
            self.callback()
        end
     end, true, 1, nil, nil, nil, true)
end

function RoleSelectHonorItem:addCallBack(callback)
    self.callback = callback
end

function RoleSelectHonorItem:setData(data)
    self.data = data
    
    if self.honor_item then
        self.honor_item:setData(data)
        self.honor_item:setShowEffect(true)
    end
end

function RoleSelectHonorItem:setSelect(is_select)
    if self.select_img then
        self.select_img:setVisible(is_select or false)
    end
end

function RoleSelectHonorItem:setBoxVisible(is_select)
    if self.checkbox then
        self.checkbox:setVisible(is_select or false)
    end
end

function RoleSelectHonorItem:DeleteMe()
    self:removeAllChildren()
    self:removeFromParent()
end
