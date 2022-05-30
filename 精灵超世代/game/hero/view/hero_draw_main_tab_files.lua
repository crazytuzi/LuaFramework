-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      宝可梦档案
-- <br/> 2019年12月4日
-- --------------------------------------------------------------------
HeroDrawMainTabFiles = class("HeroDrawMainTabFiles", function()
    return ccui.Widget:create()
end)

local string_format = string.format
local controller = HeroController:getInstance()
local model = controller:getModel()
local table_insert = table.insert

function HeroDrawMainTabFiles:ctor(parent)  
    self.parent = parent
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function HeroDrawMainTabFiles:config()
    -- self.size = cc.size(680,372.97)
    -- self:setContentSize(self.size)

end

function HeroDrawMainTabFiles:layoutUI()
    local csbPath = PathTool.getTargetCSB("hero/hero_draw_main_tab_files")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container_size = self.main_container:getContentSize()
    self.top_panel = self.main_container:getChildByName("top_panel")
    self.bottom_panel = self.main_container:getChildByName("bottom_panel")

    
    self.hero_draw_icon = self.top_panel:getChildByName("hero_draw_icon")
    self.move_bg = self.top_panel:getChildByName("move_bg")
    self.hero_name = self.top_panel:getChildByName("hero_name")
    self.hero_dec = self.top_panel:getChildByName("hero_dec")
    -- self.hero_wuyu = self.top_panel:getChildByName("hero_wuyu")
    -- self.hero_wuyu:setString(TI18N("宝可梦物语"))

    self.hero_zhuanji = self.top_panel:getChildByName("hero_zhuanji")
    self.hero_zhuanji:setString(TI18N("宝可梦传记"))

    -- self.lay_scrollview_1 = self.top_panel:getChildByName("lay_scrollview_1")

    self.common_1001 = self.top_panel:getChildByName("common_1001")
    self.content_scrollview = self.top_panel:getChildByName("content_scrollview")
    self.content_scrollview:setScrollBarEnabled(false)
    self:adaptationScreen()
end

--设置适配屏幕
function HeroDrawMainTabFiles:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)
    -- -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()

    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y - (self.main_container_size.height - tab_y))

    --多出的高度
    local height = (top_y - self.main_container_size.height) - bottom_y

    local size = self.move_bg:getContentSize()
    self.move_bg:setContentSize(cc.size(size.width, size.height + height))
    local y = self.common_1001:getPositionY()
    self.common_1001:setPositionY(y - height)

    local size = self.content_scrollview:getContentSize()
    self.content_scrollview:setContentSize(cc.size(size.width, size.height + height))
    self.content_scrollview_size = self.content_scrollview:getContentSize() 
end

--事件
function HeroDrawMainTabFiles:registerEvents()
    --详情
    registerButtonEventListener(self.look_btn, function() self:onClickLookBtn()  end ,true, 2, nil, 0.8)

    if self.check_show_library_encounter == nil then
        self.check_show_library_encounter = GlobalEvent:getInstance():Bind(EncounterEvent.CHECK_SHOW_LIBRARY_ENCOUNTER, function(hero_vo)
            if self.scroll_view then
                self.scroll_view:resetCurrentItems()
            end
        end)
    end  
end



function HeroDrawMainTabFiles:initData()
    if not self.parent then return end
    if not self.parent.hero_vo then return end
    self.hero_vo = self.parent.hero_vo

    -- local list = Config.EncounterData.data_encounter_bid_list[self.hero_vo.bid] or {}
    -- self.show_list = {}
    -- if next(list) ~= nil then
    --     table.sort( list, function(a, b) return a.id < b.id end )
    --     for i,v in ipairs(list) do
    --         local config = Config.EncounterData.data_encounter_info[v.id]
    --         if config then
    --             table_insert(self.show_list,  config)
    --         end
    --     end
    -- end

    -- self:updateList()
    local bustid
    local hero_pos
    if self.hero_vo.is_pokedex then
        local parther_config = Config.PartnerData.data_partner_base[self.hero_vo.bid]
        if parther_config then
            bustid = parther_config.bustid
            hero_pos = parther_config.hero_pos
        end
    else
        bustid = self.hero_vo.bustid
        hero_pos = self.hero_vo.hero_pos
    end

    local res = PathTool.getPartnerBustRes(bustid)
    self.item_load = loadSpriteTextureFromCDN(self.hero_draw_icon, res, ResourcesType.single, self.item_load)

    self.library_config = Config.PartnerData.data_partner_library(self.hero_vo.bid)
    if not self.library_config  then return end
    self.hero_name:setString(self.hero_vo.name)

    local str = string_format("%s%s\n%s", tostring(HeroConst.CampAttrName[self.hero_vo.camp_type]), tostring(HeroConst.CareerName[self.hero_vo.type]), hero_pos)
    self.hero_dec:setString(str)

    if self.library_config.story == nil or self.library_config.story == "" then
        commonShowEmptyIcon(self.content_scrollview, true, {text = TI18N("暂无宝可梦传记数据")})
        self.content_scrollview:setTouchEnabled(false)
    else
        --传记内容
        if self.conten_label == nil then
            self.conten_label = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 1), cc.p(0,0), 12, nil, self.content_scrollview_size.width)
            self.content_scrollview:addChild(self.conten_label)
        end
        self.conten_label:setString(self.library_config.story)
        local size = self.conten_label:getContentSize()
        if size.height < self.content_scrollview_size.height then
            self.content_scrollview:setTouchEnabled(false)
        end
        local scroll_heigt = math.max(self.content_scrollview_size.height, size.height) 
        self.content_scrollview:setInnerContainerSize(cc.size(self.content_scrollview_size.width, scroll_heigt))
        self.conten_label:setPositionY(scroll_heigt)
    end
end


function HeroDrawMainTabFiles:updateList()
    if self.scroll_view == nil then
        local scroll_view_size = self.lay_scrollview_1:getContentSize()
        local list_setting = {
            start_x = 0,
            space_x = 0,
            start_y = 0,
            space_y = 0,
            item_width = 303,
            item_height = 62,
            row = 1,
            col = 2,
            need_dynamic = true
        }
        self.scroll_view = CommonScrollViewSingleLayout.new(self.lay_scrollview_1, cc.p(scroll_view_size.width * 0.5, scroll_view_size.height * 0.5), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, list_setting, cc.p(0.5, 0.5)) 

        self.scroll_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.scroll_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
    end

    if #self.show_list == 0 then
        commonShowEmptyIcon(self.lay_scrollview_1, true, {text = TI18N("暂无宝可梦物语数据")})
    else
        commonShowEmptyIcon(self.lay_scrollview_1, false)
    end

    self.scroll_view:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function HeroDrawMainTabFiles:createNewCell(width, height)
    local cell = ccui.Layout:create()
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(0.5,0.5)
    cell:setTouchEnabled(true)
    cell:setPosition(width * 0.5 , height * 0.5)
    width = 290
    height = 53
    local size = cc.size(width, height)
    cell:setContentSize(size)

    cell.bg = createImage(cell, PathTool.getResFrame("herodraw", "hero_draw_22"), width * 0.5, height * 0.5, cc.p(0.5, 0.5), true, nil ,true)
    cell.bg:setContentSize(size)
    -- cell.bg:setScale(0.9)

    cell.name = createLabel(22, cc.c4b(0x64,0x32,0x23,0xff), nil, width * 0.5, height * 0.5, TI18N("名字"), cell, nil, cc.p(0.5, 0.5))

    registerButtonEventListener(cell, function() self:onCellTouched(cell)  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    cell.DeleteMe = function()

    end

    return cell
end
--获取数据数量
function HeroDrawMainTabFiles:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function HeroDrawMainTabFiles:updateCellByIndex(cell, index)
    cell.index = index
    local data = self.show_list[index]
    if not data then return end
    cell.name:setString(data.name)
    local isFinish = EncounterController:getInstance():getModel():isFinishByid(data.id)
    if isFinish then
        setChildUnEnabled(false, cell.bg)
    else
        setChildUnEnabled(true, cell.bg)
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function HeroDrawMainTabFiles:onCellTouched(cell)
    if not cell.index then return end
    local index = cell.index
    local data = self.show_list[index]
    if not data then return end
    local isFinish = EncounterController:getInstance():getModel():isFinishByid(data.id)
    if not isFinish then 
        message(TI18N("暂未获得该物语"))
        return 
    end
    EncounterController:getInstance():openEncounterWindow(true,data.id) 
end

function HeroDrawMainTabFiles:setVisibleStatus(bool)
    self:setVisible(bool)
     if bool then
        if not self.is_init then
            self.is_init = true
            self:initData()
        end
    end
end

--移除
function HeroDrawMainTabFiles:DeleteMe()
    if self.check_show_library_encounter then
        GlobalEvent:getInstance():UnBind(self.check_show_library_encounter)
        self.check_show_library_encounter = nil
    end

    -- if role_vo then
    --     if self.role_lev_event then
    --         role_vo:UnBind(self.role_lev_event)
    --         self.role_lev_event = nil
    --     end
    -- end
     if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
end
