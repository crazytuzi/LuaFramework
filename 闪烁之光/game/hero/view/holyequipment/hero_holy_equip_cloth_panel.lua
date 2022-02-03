-- --------------------------------------------------------------------
-- 竖版神装装备穿戴
-- 
-- @author: xhj(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-2-27
-- --------------------------------------------------------------------
HeroHolyEquipClothPanel = HeroHolyEquipClothPanel or BaseClass(BaseView)
    
local controller = HeroController:getInstance()
local model = controller:getModel()
local table_insert =table.insert
local table_sort = table.sort
local math_floor = math.floor
local string_format = string.format

--@holy_data 神装方案数据 结构参考 协议25220
function HeroHolyEquipClothPanel:__init(pos, partner_id, data, holy_data, enter_type,hero_vo,equip_list)
    self.is_full_screen = false
    self.layout_name = "hero/hero_holy_equip_cloth_panel"
    
    self.enter_type = enter_type or HeroConst.EnterType.eOhter
    self.holy_data = holy_data
    self.cloth_data = data or {}
    self.empty_res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3")
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("hero","hero"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("stronger","stronger"), type = ResourcesType.plist },
        { path = self.empty_res, type = ResourcesType.single },
    }

    self.win_type = WinType.Big    
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
    self.is_init = true
    self.click_pos = pos or BackPackConst.item_type.GOD_EARRING
    self.click_partner = partner_id or 0
    self.hero_vo = hero_vo
    self.equip_list = equip_list
    self.is_put_off = false
    self.cur_hero_item_list = {} -- 当前英雄的神装item
end

function HeroHolyEquipClothPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_panel , 1) 
    self.main_panel:getChildByName("wnd_title"):setString(TI18N("神装更换"))

    self.close_btn = self.main_panel:getChildByName("close_btn")
    
    self.cur_panel = self.main_panel:getChildByName("cur_panel")
    self.plan_list = self.main_panel:getChildByName("plan_list")
    self.name_lab = self.main_panel:getChildByName("name_lab")

    self.zone_btn_1 = self.main_panel:getChildByName("zone_btn_1")
    self.zone_name_1 = self.zone_btn_1:getChildByName("zone_name")
    self.zone_btn_2 = self.main_panel:getChildByName("zone_btn_2")
    self.zone_name_2 = self.zone_btn_2:getChildByName("zone_name")

     --下拉框面板
    self.filter_panel = self.main_panel:getChildByName("filter_panel")
    self.filter_panel:setSwallowTouches(false)
    self.filter_panel:setVisible(false)

    self.combobox_panel = self.main_panel:getChildByName("combobox_panel")
    self.combobox_panel:setVisible(false)
    self.combobox_bg = self.combobox_panel:getChildByName("bg")
    self.combobox_bg_size = self.combobox_bg:getContentSize()
    self.combobox_max_size = cc.size(200, 300) --最大size 根据示意图得出来的


    self.combobox_panel2 = self.main_panel:getChildByName("combobox_panel2")
    self.combobox_panel2:setVisible(false)
    self.combobox_bg2 = self.combobox_panel2:getChildByName("bg")
    self.combobox_bg_size2 = self.combobox_bg:getContentSize()
    self.combobox_max_size2 = cc.size(230, 300) --最大size 根据示意图得出来的

end

function HeroHolyEquipClothPanel:register_event()
    registerButtonEventListener(self.close_btn, function()
        controller:openHeroHolyEquipClothPanel(false)
    end, true, 2)
    
    registerButtonEventListener(self.background, function()
        controller:openHeroHolyEquipClothPanel(false)
    end, false, 2)
    registerButtonEventListener(self.filter_panel, function()
        self.filter_panel:setVisible(false)
        self.combobox_panel:setVisible(false)
        self.combobox_panel2:setVisible(false)
    end, false, 2)


    registerButtonEventListener(self.zone_btn_1, function() self:onZoneBtn1() end, false, 2)
    registerButtonEventListener(self.zone_btn_2, function() self:onZoneBtn2() end, false, 2)

    

    self:addGlobalEvent(HeroEvent.Del_Hero_Event, function(list)
        if self.click_partner then
            for i,v in ipairs(list) do
                if self.click_partner == v.partner_id then
                    controller:openHeroHolyEquipClothPanel(false)
                end
            end
        end
    end)

    self:addGlobalEvent(HeroEvent.Hero_Get_Holy_Equipment_Event, function(list)
        if not list or not self.hero_vo then return end
        for i,v in ipairs(list) do
            if v.partner_id == self.hero_vo.partner_id then
                self:updateCurHeroHolyItemList()
                self:updateEquipList()
            end
        end
    end)

    self:addGlobalEvent(HeroEvent.Holy_Equipment_Update_Event, function(hero_vo)
        if not hero_vo or not self.hero_vo then return end
        if hero_vo.partner_id == self.hero_vo.partner_id then
            self:updateCurHeroHolyItemList()
            self.total_show_list = nil
            self:updateEquipList()
        end
    end)

    self:addGlobalEvent(HeroEvent.Hero_Get_Holy_Equipment_Plan_Event, function(data)
        if not data then return end
        local _data = model:getHolyEquipmentPlanData()
        self:updateHolyPlanList(_data)
    end)
end

function HeroHolyEquipClothPanel:onZoneBtn1()
 if not self.show_list then return end
    self.filter_panel:setVisible(true)
    self.combobox_panel:setVisible(false)
    self.combobox_panel2:setVisible(true)
    self:updateComboboxList2(self.dic_suit_list)
end

function HeroHolyEquipClothPanel:onZoneBtn2()
    if not self.show_list then return end
    self.filter_panel:setVisible(true)
    self.combobox_panel:setVisible(true)
    self.combobox_panel2:setVisible(false)
    self:updateComboboxList1(self.dic_star_list)
end

--更新下拉列表 
function HeroHolyEquipClothPanel:updateComboboxList1(data_list, _type)
    if not data_list then return end
    local item_height = 55
    if self.combobox_scrollview == nil then
        local setting = {
            start_x = 2,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 200,                -- 单元的尺寸width
            item_height = item_height,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.combobox_scrollview = CommonScrollViewSingleLayout.new(self.combobox_panel, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, self.combobox_max_size, setting, cc.p(0, 0))

        self.combobox_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCellCombobox), ScrollViewFuncType.CreateNewCell) --创建cell
        self.combobox_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCellsCombobox), ScrollViewFuncType.NumberOfCells) --获取数量
        self.combobox_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndexCombobox), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    if next(data_list) ~= nil then 
        local count = #data_list
        if count > 5 then
            self.combobox_scrollview:setClickEnabled(true)
            self.combobox_bg:setContentSize(self.combobox_bg_size)
        else
            self.combobox_scrollview:setClickEnabled(false)
            local total_height = count * item_height + (self.combobox_bg_size.height - self.combobox_max_size.height)
            self.combobox_bg:setContentSize(cc.size(self.combobox_bg_size.width, total_height))
        end
        self.comboboxshow_list = data_list
        local select_index = nil

        self.combobox_scrollview:reloadData(select_index)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroHolyEquipClothPanel:createNewCellCombobox(width, height)
    local cell = ccui.Layout:create()
    cell:setAnchorPoint(0.5,0.5)
    cell:setContentSize(cc.size(width, height))

    cell.root_wnd = createCSBNote(PathTool.getTargetCSB("hero/hero_holy_equip_filter_item"))
    cell:addChild(cell.root_wnd)
    local container = cell.root_wnd:getChildByName("container")
    cell.name = container:getChildByName("name")
    cell.checkbox = container:getChildByName("checkbox")
    cell.checkbox:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.began then
                cell.check_box_status = cell.checkbox:isSelected()
            elseif event_type == ccui.TouchEventType.ended then
                self:setCellTouchedCombobox(cell)
            elseif event_type == ccui.TouchEventType.canceled then
                cell.checkbox:setSelected(cell.check_box_status or false)
            end
        end
    )
    -- registerButtonEventListener(cell.checkbox, function() self:setCellTouchedCombobox(cell) end, false, 1)
    return cell
end

--获取数据数量
function HeroHolyEquipClothPanel:numberOfCellsCombobox()
    if not self.comboboxshow_list then return 0 end
    return #self.comboboxshow_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function HeroHolyEquipClothPanel:updateCellByIndexCombobox(cell, index)
    cell.index = index
    local data = self.comboboxshow_list[index]
    if not data then return end
    cell.name:setString(data.name)
    if data.is_select then
        cell.checkbox:setSelected(true)
    else
        cell.checkbox:setSelected(false)
    end
    -- if data.count == 0 then
    --     cell.checkbox:setOpacity(128)
    --     cell.checkbox:setTouchEnabled(false)
    --     cell.checkbox:setSelected(false)
    -- else
    --     cell.checkbox:setOpacity(255)
    --     cell.checkbox:setTouchEnabled(true)
    -- end
end

--点击cell .需要在 createNewCell 设置点击事件
function HeroHolyEquipClothPanel:setCellTouchedCombobox(cell)
    local index = cell.index
    local data = self.comboboxshow_list[index]
    if not data then return end

    if data.is_select == true then
        cell.checkbox:setSelected(true)
        return
    end

    for i,v in ipairs(self.comboboxshow_list) do
        v.is_select = false
    end

    local is_select = cell.checkbox:isSelected()
    data.is_select = is_select
    self.combobox_scrollview:resetCurrentItems()

    --过滤条件
    if self.zone_name_2 then
        self.zone_name_2:setString(data.name)
    end
    self:updateEquipList()
end

--更新下拉列表 
function HeroHolyEquipClothPanel:updateComboboxList2(data_list, _type)
    if not data_list then return end
    local item_height = 55
    if self.combobox_scrollview2 == nil then
        local setting = {
            start_x = 2,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 230,                -- 单元的尺寸width
            item_height = item_height,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.combobox_scrollview2 = CommonScrollViewSingleLayout.new(self.combobox_panel2, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, self.combobox_max_size2, setting, cc.p(0, 0))

        self.combobox_scrollview2:registerScriptHandlerSingle(handler(self,self.createNewCellCombobox2), ScrollViewFuncType.CreateNewCell) --创建cell
        self.combobox_scrollview2:registerScriptHandlerSingle(handler(self,self.numberOfCellsCombobox2), ScrollViewFuncType.NumberOfCells) --获取数量
        self.combobox_scrollview2:registerScriptHandlerSingle(handler(self,self.updateCellByIndexCombobox2), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    if next(data_list) ~= nil then 
        local count = #data_list
        if count > 5 then
            self.combobox_scrollview2:setClickEnabled(true)
            self.combobox_bg:setContentSize(self.combobox_bg_size)
        else
            self.combobox_scrollview2:setClickEnabled(false)
            local total_height = count * item_height + (self.combobox_bg_size.height - self.combobox_max_size.height)
            self.combobox_bg:setContentSize(cc.size(self.combobox_bg_size.width, total_height))
        end
        self.comboboxshow_list2 = data_list
        local select_index = nil

        self.combobox_scrollview2:reloadData(select_index)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroHolyEquipClothPanel:createNewCellCombobox2(width, height)
    local cell = ccui.Layout:create()
    cell:setAnchorPoint(0.5,0.5)
    cell:setContentSize(cc.size(width, height))

    cell.root_wnd = createCSBNote(PathTool.getTargetCSB("hero/hero_holy_equip_filter_item2"))
    cell:addChild(cell.root_wnd)
    local container = cell.root_wnd:getChildByName("container")
    cell.name = container:getChildByName("name")
    cell.checkbox = container:getChildByName("checkbox")

    cell.checkbox:addTouchEventListener(
        function(sender, event_type)
            if event_type == ccui.TouchEventType.began then
                cell.check_box_status = cell.checkbox:isSelected()
            elseif event_type == ccui.TouchEventType.ended then
                self:setCellTouchedCombobox2(cell)
            elseif event_type == ccui.TouchEventType.canceled then
                cell.checkbox:setSelected(cell.check_box_status or false)
            end
        end
    )
    return cell
end

--获取数据数量
function HeroHolyEquipClothPanel:numberOfCellsCombobox2()
    if not self.comboboxshow_list2 then return 0 end
    return #self.comboboxshow_list2
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function HeroHolyEquipClothPanel:updateCellByIndexCombobox2(cell, index)
    cell.index = index
    local data = self.comboboxshow_list2[index]
    if not data then return end
    cell.name:setString(data.name)
    if data.is_select then
        cell.checkbox:setSelected(true)
    else
        cell.checkbox:setSelected(false)
    end
    -- if data.count == 0 then
    --     cell.checkbox:setOpacity(128)
    --     cell.checkbox:setTouchEnabled(false)
    --     cell.checkbox:setSelected(false)
    -- else
    --     cell.checkbox:setOpacity(255)
    --     cell.checkbox:setTouchEnabled(true)
    -- end
end

--点击cell .需要在 createNewCell 设置点击事件
function HeroHolyEquipClothPanel:setCellTouchedCombobox2(cell)
    local index = cell.index
    local data = self.comboboxshow_list2[index]
    if not data then return end
    if data.is_select == true then
        cell.checkbox:setSelected(true)
        return
    end
    local is_select = cell.checkbox:isSelected()
    data.is_select = is_select

    --过滤条件
    for i,v in ipairs(self.comboboxshow_list2) do
        v.is_select = false
    end

    local is_select = cell.checkbox:isSelected()
    data.is_select = is_select
    self.combobox_scrollview2:resetCurrentItems()

    --过滤条件
    if self.zone_name_1 then
        self.zone_name_1:setString(data.name)
    end
    self:updateEquipList()
end



--刷新神装装备方案列表
--@holy_equip_plan 神装套装列表
function HeroHolyEquipClothPanel:updateHolyPlanList(holy_equip_plan)
    if not holy_equip_plan then return end

    self.plan_data = {} --所有套装数据
    local cell_num = model.holy_equip_plan_count --已开启格子数量
    local eqm_config_data = Config.PartnerHolyEqmData.data_holy_suit_manage --格子开启配置条件
    for i=1,cell_num do
        local config_data = eqm_config_data[i]
        if holy_equip_plan[config_data.id] then
            self.plan_data[i] = holy_equip_plan[config_data.id]
            self.plan_data[i].equip_list = self:getEquipList(self.plan_data[i].list)
        else
            self.plan_data[i] = {}   
            self.plan_data[i].name = string_format(TI18N("方案%s"), i)
            self.plan_data[i].id = config_data.id
        end
        self.plan_data[i].config = config_data
        self.plan_data[i].is_open = 1
    end
    --除了开放的格子信息，额外加载一个待开放的格子
    if cell_num < Config.PartnerHolyEqmData.data_holy_suit_manage_length then
        table_insert(self.plan_data, eqm_config_data[cell_num + 1])
    end
    table_sort(self.plan_data, SortTools.KeyLowerSorter("id"))

    for k,v in pairs(self.plan_data) do
        if self.holy_data and self.holy_data.id == v.id then
            self.holy_data = v
            self.equip_list = v.equip_list
            break
        end
    end

    self:updateCurHeroHolyItemList()
    self:updateEquipList()
end

--获取神装装备数据列表
--@list 神装套装列表 {{item_id, partner_id}, ...}
--return {goodsvo, goodsvo, ...}
function HeroHolyEquipClothPanel:getEquipList(list)
    if not list then return end
    if #list == 0 then return {} end
    local equip_list = {} --神装数据
    for k,v in ipairs(list) do
        if v.item_id then
            local item_vo
            if v.partner_id == 0 then --在装备背包中
                item_vo = BackpackController:getModel():getBagItemById(BackPackConst.Bag_Code.EQUIPS, v.item_id)
            else --英雄已穿戴
                item_vo = model:getHolyEquipById(v.item_id)
            end
            if item_vo and item_vo.config then
                equip_list[item_vo.config.type] = item_vo
            end
        end
    end
    return equip_list
end

--刷新当前英雄神装方案信息
function HeroHolyEquipClothPanel:initCurHeroHolyInfo()
    local temp_name = TI18N("当前配置")
    if self.holy_data and self.holy_data.name then
        temp_name = self.holy_data.name
    end
    self.name_lab:setString(temp_name)
    --头像
    if not self.cur_hero_head then
        self.cur_hero_head = HeroExhibitionItem.new(1, true, 0, false)
        self.cur_hero_head:setPosition(cc.p(530, 220))
        self.cur_panel:addChild(self.cur_hero_head)
    end
    if self.hero_vo then
        self.cur_hero_head:setData(self.hero_vo)
        self.cur_hero_head:showStrTips(false)
    else
        self.cur_hero_head:showStrTips(true, TI18N("无英雄"),nil,22)
    end
    

    -- 神装item
    local start_x = 80
    for i,holy_type in ipairs(HeroConst.HolyequipmentPosList) do
        local holy_item = self.cur_hero_item_list[holy_type]
        if not holy_item then
            holy_item = BackPackItem.new(false,true,nil,1,false)
            holy_item:addCallBack(function() self:selectHolyByIndex(holy_item,holy_type) end)
            self.cur_panel:addChild(holy_item)
            local empty_res = PathTool.getResFrame("hero", HeroConst.HolyEmptyIconName[holy_type])
            local empty_icon = createImage(holy_item:getRoot(), empty_res,60,60, cc.p(0.5,0.5), true, 10, false)
            holy_item.empty_icon = empty_icon
            self.cur_hero_item_list[holy_type] = holy_item
        end
        holy_item:setPosition(cc.p(start_x + (i-1)*(BackPackItem.Width+29), 67.5))
    end

    --装备组合套装提示
    if not self.holy_tips_label then
        self.holy_tips_label = createRichLabel(22, cc.c4b(0x95,0x53,0x22,0xff), cc.p(0, 1), cc.p(20, 230), 10, nil, 600)
        self.cur_panel:addChild(self.holy_tips_label)
    end

    self:updateCurHeroHolyItemList()
end

-- 点击装备位置头像
function HeroHolyEquipClothPanel:selectHolyByIndex( holy_item,holy_type )
	if holy_item.is_ui_select == true then return end
	if self.cur_hero_item then
		self.cur_hero_item.is_ui_select = false
		self.cur_hero_item:setBoxSelected(false)
	end
	holy_item.is_ui_select = true
	holy_item:setBoxSelected(true)
    self.cur_hero_item = holy_item
    self.click_pos = holy_type
    self.cloth_data = self.cur_hero_item.equip_vo or {}

    self.total_show_list = self:initEquipData()
    -- self:updateStarFilterList()
    -- self:updateSuitFilterList()
    -- self:updateEquipList(true)

    self:updateEquipList()
end

--更新神装item显示
function HeroHolyEquipClothPanel:updateCurHeroHolyItemList()
    local equip_list = {}
    if self.hero_vo then 
        equip_list = model:getHeroHolyEquipList(self.hero_vo.partner_id)
    elseif self.equip_list then
        equip_list = self.equip_list
    end
    
    for i,holy_type in ipairs(HeroConst.HolyequipmentPosList) do
        local equip_vo = equip_list[holy_type]
        local holy_item = self.cur_hero_item_list[holy_type]
        if equip_vo then
            holy_item:setData(equip_vo)
            if holy_item.empty_icon then 
                holy_item.empty_icon:setVisible(false)
            end
            holy_item.equip_vo = equip_vo
        else
            holy_item:setData()
            if holy_item.empty_icon then 
                holy_item.empty_icon:setVisible(true)
            end
            holy_item.equip_vo = nil
        end
        holy_item.is_ui_select = false
        if (self.cloth_data and holy_type == self.cloth_data.type) or self.click_pos == holy_type then
            holy_item.is_ui_select = true
            self.cur_hero_item = holy_item 
            self.cloth_data = self.cur_hero_item.equip_vo or {}
        end
        
        holy_item:setBoxSelected(holy_item.is_ui_select)
    end

    -- 激活套装提示
    if self.holy_tips_label then
        local list = model:getHolyEquipSuitDes(equip_list)
        if next(list) ~= nil then
            local str = ""
            for k,v in ipairs(list) do
                local suit_str = string_format("<img src='%s' scale=0.8 /> %s\n", v.icon_res, v.name)
                str = str..suit_str
            end
            self.holy_tips_label:setString(str)
        else
            self.holy_tips_label:setString(TI18N("暂无组合套装"))
        end
    end
end

--显示空白
function HeroHolyEquipClothPanel:showEmptyIcon(bool)
    if not self.empty_con and bool == false then return end
    if not self.empty_con then 
        local size = cc.size(200,200)
        self.empty_con = ccui.Widget:create()
        self.empty_con:setContentSize(size)
        self.empty_con:setPosition(cc.p(310,220))
        self.plan_list:addChild(self.empty_con,100)

        local bg = createImage(self.empty_con, self.empty_res, size.width/2, size.height/2, cc.p(0.5,0.5), false)
        self.empty_label = createLabel(24,cc.c4b(0x76,0x45,0x19,0xff),nil,size.width/2,-10,"",self.empty_con,0, cc.p(0.5,0))
    end
    local str = TI18N("背包中无可穿戴装备")
    self.empty_label:setString(str)
    self.empty_con:setVisible(bool)
end

function HeroHolyEquipClothPanel:openRootWnd() 
    self:initCurHeroHolyInfo()
    self:updateStarFilterList()
    self:updateSuitFilterList()

    self:updateEquipList(true)
end

--更新星级过滤条件
function HeroHolyEquipClothPanel:updateStarFilterList( )
    if self.dic_star_list == nil then
        local max_star = 5 --现在神装只开了5个星的 估计要加入配置表 或者读取当前开启星级
        -- {data = v,open_type = 1,sort = 0,eqm_star = v.eqm_star,eqm_jie = v.eqm_jie,base_id = v.base_id})
        max_star = max_star + 1 --1 表示全部那个
        self.dic_star_list = {}
        for i=1,max_star do
            self.dic_star_list[i] = {}
            self.dic_star_list[i].eqm_star = i - 1
            if i == 1 then
                self.dic_star_list[i].name = TI18N("全部神装")
                self.dic_star_list[i].is_select = true
            else
                self.dic_star_list[i].name = string_format(TI18N("%s星神装"), (i - 1))
                self.dic_star_list[i].is_select = false
            end
        end
    else
        for i,v in ipairs(self.dic_star_list) do
            if i == 1 then
                v.is_select = true
            else
                v.is_select = false
            end
        end
    end

    if self.zone_name_2  then
        self.zone_name_2:setString(self.dic_star_list[1].name)
    end
end

function HeroHolyEquipClothPanel:updateSuitFilterList()
    if self.dic_suit_list == nil then
        local config_list = Config.PartnerHolyEqmData.data_suit_res_prefix

        self.dic_suit_list = {}
        for i,v in pairs(config_list) do
            local data = {}
            data.id = v.id
            data.name = v.name
            data.is_select = false
            table_insert(self.dic_suit_list, data)
        end
        local data = {}
        data.id = 0
        data.name = TI18N("全部套装")
        data.is_select = true
        table_insert(self.dic_suit_list, data)
        table_sort(self.dic_suit_list, function(a, b) return a.id < b.id end)
    else
        for i,v in ipairs(self.dic_suit_list) do
            if v.id == 0 then
                v.is_select = true
            else
                v.is_select = false
            end
        end
    end

    if self.zone_name_1  then
        self.zone_name_1:setString(self.dic_suit_list[1].name)
    end
end

function HeroHolyEquipClothPanel:initEquipData()
    local click_pos = self.click_pos or BackPackConst.item_type.GOD_EARRING
    --有穿戴的要创建穿戴的
    local show_list = {}
    if self.cloth_data and next(self.cloth_data) ~=nil then 
        table_insert(show_list, {data = self.cloth_data,open_type = 2,sort = 1, eqm_set = self.cloth_data.config.eqm_set, eqm_star = self.cloth_data.eqm_star})
    end

    --背包的装备
    local list = BackpackController:getInstance():getModel():getBagItemList(BackPackConst.Bag_Code.EQUIPS) or {}
    for i,v in pairs(list) do
        if v and v.config and v.config.type then
            if click_pos == v.config.type then
                if self.cloth_data and self.cloth_data.id ~= v.id then
                    table_insert(show_list, {data = v,open_type = 1,sort = 0,eqm_set = v.config.eqm_set, eqm_star = v.eqm_star,eqm_jie = v.eqm_jie,base_id = v.base_id})
                end
            end
        end
    end
    --英雄上面神装装备
    if self.holy_data and next(self.holy_data) ~= nil and BackPackConst.checkIsHolyEquipment(click_pos) then
        --神装管理要显示穿戴在英雄上面的装备
        local hero_equip_list = model:getAllHeroHolyEquipList()
        for k,v in pairs(hero_equip_list) do
            if v.config and v.config.type and click_pos == v.config.type then
                if self.cloth_data and self.cloth_data.id ~= v.id then
                    table_insert(show_list, {data = v,open_type = 1,sort = 0,eqm_set = v.config.eqm_set, eqm_star = v.eqm_star,eqm_jie = v.eqm_jie,base_id = v.base_id})
                end
            end
        end
    end
    return show_list
end

function HeroHolyEquipClothPanel:filterCondition()
    local show_list = self.total_show_list or {}

    --星级过滤
    local dic_star_filter = {}
    local is_all_select = false
    if self.dic_star_list then
        for i,v in ipairs(self.dic_star_list) do
            if i == 1 and v.is_select then
                is_all_select = true
                break
            else
                if v.is_select then
                    dic_star_filter[v.eqm_star] = true
                end
            end
        end
    end
    if not is_all_select then
        local temp_list = {}
        for i,v in ipairs(show_list) do
            if v.sort == 1 or (v.eqm_star and dic_star_filter[v.eqm_star]) then
                table_insert(temp_list, v)
            end
        end
        show_list = temp_list
    end
    -- 套装过滤
    local dic_suit_filter = {}
    is_all_select = false
    if self.dic_suit_list then
        for i,v in ipairs(self.dic_suit_list) do
            if v.id == 0 and v.is_select then
                is_all_select = true
                break
            else
                if v.is_select then
                    dic_suit_filter[v.id] = true
                end
            end
        end
    end
    if not is_all_select then
        local temp_list = {}
        for i,v in ipairs(show_list) do
            if v.sort == 1 or v.eqm_set then
                local id = math_floor(v.eqm_set/100)
                if v.sort == 1 or dic_suit_filter[id] then
                    table_insert(temp_list, v)
                end
            end
        end
        show_list = temp_list
    end
    return show_list
end

-- @is_all_data 是否total数据
function HeroHolyEquipClothPanel:updateEquipList(is_total_data)
    if self.list_view == nil then
        local scroll_view_size = self.plan_list:getContentSize()
        local setting = {
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 2,                   -- y方向的间隔
            item_width = 595,               -- 单元的尺寸width
            item_height = 141,              -- 单元的尺寸height
            row = 1,                        -- 行数，作用于水平滚动类型
            col = 1,                        -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.list_view = CommonScrollViewSingleLayout.new(self.plan_list, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)

        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end
    
    if self.total_show_list == nil then
        self.total_show_list = self:initEquipData()
    end
    if is_total_data then
        self.show_list = self.total_show_list
    else
        self.show_list = self:filterCondition()
    end

    if self.show_list == nil then return end
    if #self.show_list > 0 then
        local sort_func = SortTools.tableUpperSorter({"sort","eqm_star", "eqm_jie", "base_id"})
        table_sort(self.show_list, sort_func)
    end
    if next(self.show_list) == nil then 
        self:showEmptyIcon(true)
    else
        self:showEmptyIcon(false)    
    end

    self.list_view:reloadData()
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroHolyEquipClothPanel:createNewCell(width, height)
    local cell = EquipClothItem2.new()
    cell:setExtendData({my_equip_score = self.cloth_data.all_score, enter_type = self.enter_type})
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function HeroHolyEquipClothPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function HeroHolyEquipClothPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function HeroHolyEquipClothPanel:onCellTouched(cell)
    local index = cell.index
    local cell_data = self.show_list[index]
    self:clickFun(cell_data)
end

function HeroHolyEquipClothPanel:clickFun(info)
    if not info or not info.data then
        return
    end

    local vo = info.data
    
    --神装方案穿戴
    if self.holy_data and next(self.holy_data) ~= nil and BackPackConst.checkIsHolyEquipment(self.click_pos) then
        local partner_id = self.holy_data.partner_id or 0
        if info.open_type and info.open_type == 2 then
            local list = {}
            --方案中已有的装备
            if self.holy_data.list and next(self.holy_data.list) ~= 0 then
                for k,v in ipairs(self.holy_data.list) do
                    if v and v.item_id then
                        table.insert(list, {partner_id = v.partner_id, item_id = v.item_id})
                    end
                end
            end
            --卸下的装备
            for i=#list,1,-1 do
                if list[i] and list[i].item_id == vo.id then
                    table.remove(list, i)
                end
            end
            controller:sender25221(self.holy_data.id, partner_id, self.holy_data.name, list)
        else
            --检查道具是否在神装管理里面
            local id_status,plan_data = model:checkHolyEquipmentPalnByItemID(vo.id)
            --检查是否勾选今日不再提示
            local status = SysEnv:getInstance():getBool(SysEnv.keys.holy_plan_save_tip, false)

            if id_status and not status then
                local holy_data = {}
                holy_data.id = self.holy_data.id
                holy_data.name = self.holy_data.name
                holy_data.partner_id = partner_id
                holy_data.item_list = {}
                holy_data.equip_list = self.holy_data.equip_list
                holy_data.select_vo = vo

                --装备已穿戴/在背包
                local item_vo = model:getHolyEquipById(vo.id)
                if not item_vo then
                    item_vo = BackpackController:getModel():getBagItemById(BackPackConst.Bag_Code.EQUIPS, vo.id)
                end
                local holy_type = item_vo.config.type
                for _,data in pairs(plan_data.list) do
                    if data and vo.id == data.item_id then
                        table_insert(holy_data.item_list, holy_type, {item_vo = item_vo, name = plan_data.name})
                    end
                end
                --判断是否有已被其他英雄穿戴的神装，有则提示
                if holy_data and next(holy_data.item_list) ~= nil then
                    controller:openHolyequipmentSaveTips(true, holy_data)
                end
            else
                local is_new = true
                local list = {}
                if self.holy_data.equip_list then
                    for _type , equip_vo in pairs(self.holy_data.equip_list) do
                        local each_partner_id =  0
                        if vo.config.type ==  _type then
                            if model.dic_itemid_to_partner_id[vo.id] then
                                each_partner_id = model.dic_itemid_to_partner_id[vo.id]
                            end
                            table.insert(list, {partner_id = each_partner_id, item_id = vo.id})
                            is_new = false
                        else
                            if model.dic_itemid_to_partner_id[equip_vo.id] then
                                each_partner_id = model.dic_itemid_to_partner_id[equip_vo.id]
                            end
                            table.insert(list, {partner_id = each_partner_id, item_id = equip_vo.id})
                        end
                    end
                end
                if is_new then
                    local each_partner_id =  0
                    if model.dic_itemid_to_partner_id[vo.id] then
                        each_partner_id = model.dic_itemid_to_partner_id[vo.id]
                    end
                    table.insert(list, {partner_id = each_partner_id, item_id = vo.id})
                end
                controller:sender25221(self.holy_data.id, partner_id, self.holy_data.name, list) --新增神装方案   
            end
        end
    else
        if info.open_type and info.open_type == 2 then--卸下
            controller:sender11093(self.click_partner, vo.id, 0)
        else
            controller:sender11093(self.click_partner, vo.id, 1)
        end
    end    
end


function HeroHolyEquipClothPanel:close_callback()
    for k,v in pairs(self.cur_hero_item_list) do
        v:DeleteMe()
        v = nil
    end
    
    if self.cur_hero_head then
		self.cur_hero_head:DeleteMe()
		self.cur_hero_head = nil
    end
    
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    if self.combobox_scrollview then
        self.combobox_scrollview:DeleteMe()
        self.combobox_scrollview = nil
    end
    if self.combobox_scrollview2 then
        self.combobox_scrollview2:DeleteMe()
        self.combobox_scrollview2 = nil
    end
    controller:openHeroHolyEquipClothPanel(false)
end



-- --------------------------------------------------------------------
-- 竖版装备穿戴子项
-- 
-- @author: xhj(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-2-27
-- --------------------------------------------------------------------
EquipClothItem2 = class("EquipClothItem2", function()
    return ccui.Widget:create()
end)

function EquipClothItem2:ctor(open_type)  
    self.open_type = open_type or 1
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function EquipClothItem2:setExtendData(extend_info)
    self.my_equip_score = extend_info.my_equip_score or 0
    self.enter_type = extend_info.enter_type
end
function EquipClothItem2:config()
    self.size = cc.size(595.00,141)
    self:setContentSize(self.size)
    self.attr_list = {}
    self.star_list = {}
end
function EquipClothItem2:layoutUI()
    local csbPath = PathTool.getTargetCSB("hero/hero_holy_equip_cloth_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.equip_item = BackPackItem.new(false,true)
    self.equip_item:setPosition(cc.p(70,self.size.height/2))
    self.main_panel:addChild(self.equip_item)
    self.equip_item:addCallBack(function ()
        controller:openEquipTips(true, self.data, PartnerConst.EqmTips.other)
    end)

    self.bg = self.main_panel:getChildByName("bg")
   
    self.cloth_btn = self.main_panel:getChildByName("lev_btn")
    self.cloth_btn:setTitleText(TI18N("穿戴"))
    self.cloth_title = self.cloth_btn:getTitleRenderer()
    
    --装备名字
    self.equip_name = createLabel(24,cc.c4b(0x64,0x32,0x23,0xff),nil,146,98,"",self.main_panel,0, cc.p(0,0))

    self.plan_eqm_name = createRichLabel(22, cc.c4b(0xd9,0x50,0x14,0xff), cc.p(0.5, 0.5), cc.p(526, 118), nil, nil, 380)
    self.main_panel:addChild(self.plan_eqm_name)
end

function EquipClothItem2:setData(info)
    if not info then return end
    if not info.data or not info.data.config then return end
    -- 引导需要,这里做修改  
    if self.index then
        self.cloth_btn:setName("guildsign_equip_list_item_"..self.index)
    end

    self.open_type = info.open_type or 1
    local res = PathTool.getResFrame("common","common_1029")
    self.cloth_btn:setBright(true)
    self.cloth_title:enableOutline(Config.ColorData.data_color4[264], 2)
    self.cloth_btn:setTitleText(TI18N("穿戴"))
    if self.open_type == 2 then 
        res = PathTool.getResFrame("common","common_1020")
        self.cloth_btn:setBright(false)
        self.cloth_btn:setTitleText(TI18N("卸下"))
    	self.cloth_title:enableOutline(Config.ColorData.data_color4[263], 2)
    end
    self.bg:loadTexture(res,LOADTEXT_TYPE_PLIST)

    local id_status,plan_data = model:checkHolyEquipmentPalnByItemID(info.data.id)
    if id_status then
        self.plan_eqm_name:setString(string_format(TI18N("【%s】"),plan_data.name))
    else
        self.plan_eqm_name:setString("")
    end
    if self.enter_type == HeroConst.EnterType.eHolyPlan and self.open_type ~= 2 then
        self.cloth_btn:setTitleText(TI18N("装配"))
    end

    self.data = info.data
    -- self.equip_item:setBaseData(data.base_id)
    self.equip_item:setData(info.data)
    
    self.equip_item:setEnchantLev(info.data.enchant)

    local name = info.data.config.name or ""
    local str = name
    local enchant = info.data.enchant or 0
    if enchant > 0 then 
        str = name .. "+" .. enchant
    end
    self.equip_name:setString(str)

    if self.data.config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then --神装
        self:updateHolyEquipInfo()
    end
end


function EquipClothItem2:updateHolyEquipInfo()
    self.equip_name:setPositionY(106)
    --基本属性的位置
    local label_x = 146
    local label_y = 76
    --属性值的x位置 y 位置和 label 一样

    local label_y2 = 44

    local attr_x = 210
    local attr_x2 = 333


    if self.holy_base_label == nil then
        self.holy_base_label = createLabel(20, cc.c4b(0x64,0x32,0x23,0xff), nil, label_x, label_y, "", self.main_panel, 0, cc.p(0,0.5))
        self.holy_base_label:setString(TI18N("基础:"))
    end

    local main_attr1 = self.data.main_attr or {}
    if main_attr1 and next(main_attr1) ~= nil then
        --神装的主属性只有一条..多的无视掉
        local main_attr = main_attr1[1] or {}
        local res, attr_name, attr_val = commonGetAttrInfoByIDValue(main_attr.attr_id, main_attr.attr_val)

        if res then
            if self.base_attr_label == nil then
                self.base_attr_label = createRichLabel(20, cc.c4b(0x95,0x53,0x22,0xff), cc.p(0, 0.5), cc.p(attr_x, label_y), nil, nil, 380)
                self.main_panel:addChild(self.base_attr_label)
            end
            -- <img src='%s' scale=1 />
            local attr_str = string_format("<div fontcolor=#955322> %s %s </div>", attr_name, attr_val)
            self.base_attr_label:setString(attr_str)
        end
    end

    if self.holy_random_label == nil then
        local x = label_x
        local y = label_y2
        self.holy_random_label = createLabel(20, cc.c4b(0x64,0x32,0x23,0xff), nil, x, y , "", self.main_panel, 0, cc.p(0,0.5))
        self.holy_random_label:setString(TI18N("随机:"))
    end

    local dic_holy_eqm_attr = {}
    for i,v in ipairs(self.data.holy_eqm_attr) do
        dic_holy_eqm_attr[v.pos] = v
    end
    --神装随机属性最多 2 条  多的需要调整ui才可以
    if self.random_holy_equip_attr == nil then
        self.random_holy_equip_attr = {}
    end
    for i=1,2 do
        if self.random_holy_equip_attr[i] == nil then
            local x = attr_x 
            if i >= 2 then
                x = attr_x2
            end
            local y = label_y2
            self.random_holy_equip_attr[i] = createRichLabel(20, cc.c4b(0x95,0x53,0x22,0xff), cc.p(0, 0.5), cc.p(x, y), nil, nil, 380)
            self.main_panel:addChild(self.random_holy_equip_attr[i])
        end

        local random_eqm_attr = dic_holy_eqm_attr[i] 
        if random_eqm_attr then
            local res, attr_name, attr_val = commonGetAttrInfoByIDValue(random_eqm_attr.attr_id, random_eqm_attr.attr_val)
            if res then
                local attr_key = Config.AttrData.data_id_to_key[random_eqm_attr.attr_id]
                local color = model:getHolyEquipmentColorByItemIdAttrKey(self.data.config.id, attr_key, random_eqm_attr.attr_val, 1, 2)
                -- local color = BackPackConst.getBlackQualityColorStr(1) --<img src='%s' scale=1 />
                local attr_str = string_format("<div fontcolor=#955322> %s </div><div fontcolor=%s>%s</div>", attr_name, color, attr_val)
                self.random_holy_equip_attr[i]:setString(attr_str)
            end
        else
            if i == 1 then
                self.random_holy_equip_attr[i]:setString(TI18N("无"))
            else
                self.random_holy_equip_attr[i]:setString("")
            end
        end
    end
end
--事件
function EquipClothItem2:registerEvents()
    self.cloth_btn:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            if self.call_fun then 
                self:call_fun(self.data)
            end
        end
    end)
    
end
function EquipClothItem2:clickHandler()
    if self.call_fun then 
        self:call_fun(self.data)
    end
end
function EquipClothItem2:addCallBack(call_fun)
    self.call_fun =call_fun
end

function EquipClothItem2:setVisibleStatus(bool)
    self:setVisible(bool)
end

function EquipClothItem2:DeleteMe()
    if self.equip_item then 
        self.equip_item:DeleteMe()
        self.equip_item = nil
    end
    self.data = nil
    self:removeFromParent()
end




