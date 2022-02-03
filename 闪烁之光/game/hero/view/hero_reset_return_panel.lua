 -- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      英雄重生 查看返回资源
-- <br/>Create: 2018年11月12日
--
-- --------------------------------------------------------------------
HeroResetReturnPanel = HeroResetReturnPanel or BaseClass(BaseView)

local table_insert = table.insert
local controller = HeroController:getInstance()
local model = controller:getModel()

function HeroResetReturnPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini
    self.layout_name = "hero/hero_reset_return_panel"
end 

function HeroResetReturnPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container , 2)  
    self.win_title = container:getChildByName("win_title")
    self.win_title:setString(TI18N("英雄献祭"))

    self.confirm_btn = container:getChildByName("confirm_btn")
    self.confirm_btn_label = self.confirm_btn:getChildByName("label")
    self.confirm_btn_label:setString(TI18N("确 定"))
    self.confirm_btn_label:enableOutline(Config.ColorData.data_color4[264], 2)
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

    self.close_btn = container:getChildByName("close_btn")
    self.container = container
end

function HeroResetReturnPanel:register_event()
    registerButtonEventListener(self.close_btn, function() controller:openHeroResetReturnPanel(false) end ,true, 1)
    registerButtonEventListener(self.background, function() controller:openHeroResetReturnPanel(false) end ,false, 1)

    registerButtonEventListener(self.confirm_btn, function() controller:openHeroResetReturnPanel(false) end ,true, 2)

    self:addGlobalEvent(HeroEvent.Hero_Reset_Look_Event, function(data)
        if not data then return end
        self:setData(data.list)
    end)
end

function HeroResetReturnPanel:openRootWnd(hero_list)
    if not hero_list then return end
    controller:sender11075(hero_list)
end

function HeroResetReturnPanel:setData(list)
    if not list then return end
    
    local item_list = {}
    for i,v in ipairs(list) do
        local item = {}
        item.id = v.id
        item.quantity = v.num
        table_insert(item_list, item)
    end

    local sort_func = SortTools.tableUpperSorter({"id"})
    -- local sort_func = SortTools.tableUpperSorter({"quality","lev"})
    table.sort(item_list, sort_func)
    self.item_scrollview:setData(item_list, nil, nil, {is_show_tips = true, is_other = false})
end


function HeroResetReturnPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    controller:openHeroResetReturnPanel(false)
end


