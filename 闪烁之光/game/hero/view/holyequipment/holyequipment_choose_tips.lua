--------------------------------
-- @Author: zj@qqg.com
-- @Date:   2019-05-13 11:39:59
-- @Description:   神装管理之选择方案
--------------------------------
local _controller = HeroController:getInstance()
local _model = HeroController:getInstance():getModel()
local _string_format = string.format
local _table_insert = table.insert

HolyequipmentChooseTips = HolyequipmentChooseTips or BaseClass(BaseView)

function HolyequipmentChooseTips:__init()
    self.is_full_screen = false  
    self.win_type = WinType.Mini 
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  
    self.layout_name = "hero/hero_holy_choose_plan_tips"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }

    self.plan_data = {}
end

function HolyequipmentChooseTips:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_panel = self.root_wnd:getChildByName("main_panel")

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

function HolyequipmentChooseTips:_createNewCell(width, height)
    local cell = HolyequipmentChooseItem.new(width, height)
    cell:setExtendData(self.hero_vo, self.plan_data)
    return cell
end

function HolyequipmentChooseTips:_numberOfCells()
    if not self.plan_data then return 0 end
    return #self.plan_data
end

function HolyequipmentChooseTips:_updateCellByIndex(cell, index)
    if not self.plan_data then return end
    cell.index = index
    local cell_data = self.plan_data[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function HolyequipmentChooseTips:register_event()
	registerButtonEventListener(self.background, function()
		_controller:openHolyequipmentChooseTips(false)
	end, true, 2)
end

function HolyequipmentChooseTips:openRootWnd(hero_vo, plan_data)
	self.hero_vo = hero_vo
	self.plan_data = plan_data
	
	self.plan_scrollview:reloadData()
end

function HolyequipmentChooseTips:close_callback( )
	if self.plan_scrollview then
        self.plan_scrollview:DeleteMe()
        self.plan_scrollview = nil
    end
	_controller:openHolyequipmentChooseTips(false)
end

-----------------------------@ item
HolyequipmentChooseItem = class("HolyequipmentChooseItem", function()
    return ccui.Widget:create()
end)

function HolyequipmentChooseItem:ctor(width, height)
	self.size = cc.size(width, height)
    self:setContentSize(self.size)

    self:layoutUI()
    self:registerEvents()
end

function HolyequipmentChooseItem:layoutUI()
    self.container = ccui.Layout:create()
    self.container:setContentSize(self.size)
    self:addChild(self.container)

    self.plan_name_label = createRichLabel(22, cc.c3b(0xff,0xee,0xdd), cc.p(0, 0.5), cc.p(40, self.size.height/2))
    self.container:addChild(self.plan_name_label)

    self.choose_btn = createImage(self.container, PathTool.getResFrame("mainui","mainui_tips_bg1"), 325, self.size.height/2, cc.p(0.5,0.5), true, 1, true)
    self.choose_btn:setContentSize(cc.size(120, 48))
    self.choose_btn:setTouchEnabled(true)
    local btn_size = self.choose_btn:getContentSize()
    local choose_label = createLabel(22, 274, nil, btn_size.width/2, btn_size.height/2, TI18N("选择"), self.choose_btn, nil, cc.p(0.5, 0.5))

    self.sp_line = createImage(self.container, PathTool.getResFrame("tips","tips_8"), self.size.width/2, 0, cc.p(0.5,0), true, 1, true)
    self.sp_line:setContentSize(cc.size(350, 2))
end

function HolyequipmentChooseItem:registerEvents()
	registerButtonEventListener(self.choose_btn, handler(self, self.onChoosePlan), true, 1)
end

--获取当前英雄已穿戴的装备列表
function HolyequipmentChooseItem:getCurHeroEuqipList()
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
function HolyequipmentChooseItem:onChoosePlan()
    if not self.hero_vo or not self.plan_data then return end
    
    local status = SysEnv:getInstance():getBool(SysEnv.keys.holy_plan_save_tip, false)
    if status then
        local list = self:getCurHeroEuqipList()
        _controller:sender25221(self.data.id, self.hero_vo.partner_id, self.data.name, list) --新增神装套装
    else
        local holy_data = {}
        holy_data.id = self.data.id
        holy_data.name = self.data.name
        holy_data.partner_id = self.hero_vo.partner_id
        holy_data.item_list = {}
        
        --覆盖方案，提示被覆盖的目标方案数据
        local target_plan = self.plan_data[self.data.id]
        if tableLen(target_plan.list) == 0 then --目标方案为空
            local list = self:getCurHeroEuqipList()
            _controller:sender25221(self.data.id, self.hero_vo.partner_id, self.data.name, list) --新增神装套装
        else
            local temp_list = {}
            if target_plan.list then
                for _,data in pairs(target_plan.list) do
                    _table_insert(temp_list, {item_id = data.item_id, name = self.data.name, partner_id = data.partner_id})
                end
            end
            for _,item_vo in pairs(target_plan.equip_list) do
                for k,v in ipairs(temp_list) do
                    if v and v.item_id == item_vo.id then
                        local holy_type = item_vo.config.type
                        temp_list[k].item_vo = item_vo
                        _table_insert(holy_data.item_list, holy_type, temp_list[k])
                    end
                end
            end
            --确认是否卸下指定方案的装备并覆盖
            _controller:openHolyequipmentSaveTips(true, holy_data)
        end
    end
    _controller:openHolyequipmentChooseTips(false)
end

function HolyequipmentChooseItem:setExtendData(hero_vo, plan_data)
	self.hero_vo = hero_vo
	self.plan_data = plan_data
end

function HolyequipmentChooseItem:setData(data)
	if not data then return end
	self.data = data
    
	self.choose_btn:setVisible(data.is_open == 1)
	self.sp_line:setVisible(data.is_open == 1)
	if self.plan_name_label then
		self.plan_name_label:setVisible(data.is_open == 1)
	end
	if data.is_open == 1 then
		local title_str = _string_format(TI18N("%d  %s"), data.id, data.name)
		if not data.list or next(data.list) == nil then
			title_str = _string_format(TI18N("%d  %s<div fontcolor=#c1b7ab fontsize=20> (空)</div>"), data.id, data.name)
		end
		self.plan_name_label:setString(title_str)
	end
end

function HolyequipmentChooseItem:DeleteMe()
end