--------------------------------
-- @Author: lwc
-- @Date:   2020年3月22日
-- @Description:   精灵管理之选择方案
--------------------------------
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert

ElfinFightPlanChooseTips = ElfinFightPlanChooseTips or BaseClass(BaseView)

function ElfinFightPlanChooseTips:__init()
    self.is_full_screen = false  
    self.win_type = WinType.Mini 
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.layout_name = "hero/hero_holy_choose_plan_tips"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }

    self.plan_data = {}
end

function ElfinFightPlanChooseTips:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self:playEnterAnimatianByObj(self.main_panel, 2)

    self.main_panel:getChildByName("title_label"):setString(TI18N("选择目标方案"))

    local panel_list = self.main_panel:getChildByName("panel_list")
    local scroll_view_size = panel_list:getContentSize()
    local setting = {
        start_x = 0,                   -- 第一个单元的X起点
        space_x = 0,                   -- x方向的间隔
        start_y = 0,                   -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = 400,              -- 单元的尺寸width
        item_height = 80,              -- 单元的尺寸height
        row = 0,                       -- 行数，作用于水平滚动类型
        col = 1,                       -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.plan_scrollview = CommonScrollViewSingleLayout.new(panel_list, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.plan_scrollview:setSwallowTouches(false)

    self.plan_scrollview:registerScriptHandlerSingle(handler(self,self._createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
    self.plan_scrollview:registerScriptHandlerSingle(handler(self,self._numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
    self.plan_scrollview:registerScriptHandlerSingle(handler(self,self._updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell

end

function ElfinFightPlanChooseTips:_createNewCell(width, height)
    local cell = ElfinPlanChooseItem.new(width, height, self)
    return cell
end

function ElfinFightPlanChooseTips:_numberOfCells()
    if not self.plan_data then return 0 end
    return #self.plan_data
end

function ElfinFightPlanChooseTips:_updateCellByIndex(cell, index)
    if not self.plan_data then return end
    cell.index = index
    local cell_data = self.plan_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function ElfinFightPlanChooseTips:register_event()
    registerButtonEventListener(self.background, function()
        _controller:openElfinFightPlanChooseTips(false)
    end, true, 2)
end

function ElfinFightPlanChooseTips:openRootWnd(setting)
    local setting = setting or {}
    self.sprites = setting.sprites
    self.plan_data = setting.plan_data
    self.fun_form_type = setting.fun_form_type
    self.team_index = setting.team_index
        
    self.plan_scrollview:reloadData()
end

function ElfinFightPlanChooseTips:close_callback( )
    if self.plan_scrollview then
        self.plan_scrollview:DeleteMe()
        self.plan_scrollview = nil
    end
    _controller:openElfinFightPlanChooseTips(false)
end

-----------------------------@ item
ElfinPlanChooseItem = class("ElfinPlanChooseItem", function()
    return ccui.Widget:create()
end)

function ElfinPlanChooseItem:ctor(width, height, parent)
    self.parent = parent
    self.size = cc.size(400, 80)
    self:setContentSize(self.size)

    self:layoutUI()
    self:registerEvents()
end

function ElfinPlanChooseItem:layoutUI()
    self.container = ccui.Layout:create()
    self.container:setContentSize(self.size)
    self:addChild(self.container)

    self.plan_name_label = createRichLabel(22, cc.c3b(0xff,0xee,0xdd), cc.p(0, 0.5), cc.p(40, 40))
    self.container:addChild(self.plan_name_label)

    local btn_size = cc.size(120, 48)
    self.choose_btn = createImage(self.container, PathTool.getResFrame("mainui","mainui_tips_bg1"), 325, 40, cc.p(0.5,0.5), true, 1, true)
    self.choose_btn:setContentSize(btn_size)
    self.choose_btn:setTouchEnabled(true)

    local choose_label = createLabel(22, 274, nil, btn_size.width/2, btn_size.height/2, TI18N("选择"), self.choose_btn, nil, cc.p(0.5, 0.5))

    self.sp_line = createImage(self.container, PathTool.getResFrame("tips","tips_8"), 200, 0, cc.p(0.5,0), true, 1, true)
    self.sp_line:setContentSize(cc.size(350, 2))
end

function ElfinPlanChooseItem:registerEvents()
    registerButtonEventListener(self.choose_btn, handler(self, self.onChoosePlan), true, 1)
end

--获取当前英雄已穿戴的装备列表
function ElfinPlanChooseItem:getCurHeroEuqipList()
    local list = {}
    local equip_list = _model:getHeroHolyEquipList(self.hero_vo.partner_id)
    for k,v in pairs(equip_list) do
        if v then
            _table_insert(list, {partner_id = self.hero_vo.partner_id, item_id = v.id})
        end
    end
    return list
end

--选择方案
function ElfinPlanChooseItem:onChoosePlan()
    if not self.data then return end
    if not self.parent then return end
    local sprites = self.parent.sprites
    local fun_form_type = self.parent.fun_form_type or 0
    local team_index = self.parent.team_index or 0
    
    -- local status = SysEnv:getInstance():getBool(SysEnv.keys.elfin_plan_save_tip, false)
    -- if status then
        _controller:send26557(self.data.id, sprites, fun_form_type, team_index) --新增神装套装
    -- else
        --覆盖方案，提示被覆盖的目标方案数据
        -- if not self.data.plan_sprites or next(self.data.plan_sprites) == nil then --目标方案为空
           -- _controller:send26557(self.data.id, sprites, fun_form_type, team_index) --新增神装套装
        -- else
            
        --     local setting = {}
        --     setting.id = self.data.id
        --     setting.o_sprites = self.data.plan_sprites
        --     setting.name = self.data.name

        --     setting.sprites = sprites
        --     setting.fun_form_type = fun_form_type
        --     setting.team_index = team_index
        --     --确认是否卸下指定方案的装备并覆盖
        --     _controller:openElfinFightPlanSaveTips(true, setting)
        -- end
    -- end
    _controller:openElfinFightPlanChooseTips(false)
end

function ElfinPlanChooseItem:setData(data)
    if not data then return end
    self.data = data
    local is_status
    if data.is_open == 0 then
        is_status = false
    else
        is_status = true
    end

    self.choose_btn:setVisible(is_status)
    self.sp_line:setVisible(is_status)
    if self.plan_name_label then
        self.plan_name_label:setVisible(is_status)
    end
    if is_status then
        local title_str 
        if not data.plan_sprites or next(data.plan_sprites) == nil then
            title_str = _string_format(TI18N("%d  %s<div fontcolor=#c1b7ab fontsize=20> (空)</div>"), data.id, data.name)
        else
            title_str = _string_format(TI18N("%d  %s"), data.id, data.name)
        end
        self.plan_name_label:setString(title_str)
    end
end

function ElfinPlanChooseItem:DeleteMe()
end