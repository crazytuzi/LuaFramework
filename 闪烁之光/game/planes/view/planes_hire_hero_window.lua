---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/12/10 23:09:13
-- @description: 位面冒险 雇佣英雄界面
---------------------------------
local _controller = PlanesController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

PlanesHireHeroWindow = PlanesHireHeroWindow or BaseClass(BaseView)

function PlanesHireHeroWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "planes/planes_hire_hero_window"
end

function PlanesHireHeroWindow:open_callback( )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container

	main_container:getChildByName("win_title"):setString(TI18N("英雄雇佣"))
	main_container:getChildByName("tips_txt"):setString(TI18N("雇佣一位英雄，帮助你完成本次冒险吧"))

	self.btn_sure = main_container:getChildByName("btn_sure")
	self.btn_sure:getChildByName("label"):setString(TI18N("确认选择"))
	self.close_btn = main_container:getChildByName("close_btn")

	local item_list = main_container:getChildByName("item_list")
	local scroll_view_size = item_list:getContentSize()
    local setting = {
        item_class = PlanesHireHeroItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 597,               -- 单元的尺寸width
        item_height = 141,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewLayout.new(item_list, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
end

function PlanesHireHeroWindow:register_event( )
	registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
	registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
	registerButtonEventListener(self.btn_sure, handler(self, self.onClickSureBtn), true)
end

function PlanesHireHeroWindow:onClickCloseBtn(  )
	_controller:openPlanesHireHeroWindow(false)
end

function PlanesHireHeroWindow:onClickSureBtn(  )
	if self.cur_item then
		local pos = self.cur_item:getHireHeropos()
		if pos then
			_controller:sender23104( nil, 1, {{type = PlanesConst.Proto_23104._10, val1 = pos, val2 = 0}} )
		end
		_controller:openPlanesHireHeroWindow(false)
	else
		message(TI18N("请选择一位雇佣英雄"))
	end
end

function PlanesHireHeroWindow:openRootWnd( data )
	self:setData(data)
end

function PlanesHireHeroWindow:setData( data )
	if not data then return end
	self.item_scrollview:setData(data, handler(self, self.onClickItemCallBcak))
end

function PlanesHireHeroWindow:onClickItemCallBcak( item, status )
	if self.cur_item then
		self.cur_item:setIsSelect(false)
	end
	if status == true then
		item:setIsSelect(true)
		self.cur_item = item
	else
		self.cur_item = nil
	end
end

function PlanesHireHeroWindow:close_callback( )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	_controller:openPlanesHireHeroWindow(false)
end