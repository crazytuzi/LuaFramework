---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/12/11 16:02:08
-- @description: 位面 buff列表展示
---------------------------------
local _controller = PlanesController:getInstance()
local _model = _controller:getModel()
local _table_sort = table.sort
local _table_insert = table.insert

PlanesBuffListWindow = PlanesBuffListWindow or BaseClass(BaseView)

function PlanesBuffListWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "planes/planes_buff_list"

    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("planes", "planes_buff"), type = ResourcesType.plist},
	}
end

function PlanesBuffListWindow:open_callback( )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container

	main_container:getChildByName("win_title"):setString(TI18N("遗物收集"))
	main_container:getChildByName("tips_txt"):setString(TI18N("遗物只会在本次位面探险玩法中生效，结束冒险后，遗物将会被清空"))

	self.close_btn = main_container:getChildByName("close_btn")

	local item_list = main_container:getChildByName("item_list")
	local scroll_view_size = item_list:getContentSize()
    local setting = {
        item_class = PlanesBuffItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 5,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 195,               -- 单元的尺寸width
        item_height = 362,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 3,                         -- 列数，作用于垂直滚动类型
    }
    self.item_scrollview = CommonScrollViewLayout.new(item_list, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
end

function PlanesBuffListWindow:register_event( )
	registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
	registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)

	self:addGlobalEvent(PlanesEvent.Get_Buff_Data_Event, function ( buff_list )
		self:setData(buff_list)
	end)
end

function PlanesBuffListWindow:onClickCloseBtn(  )
	_controller:openPlanesBuffListWindow(false)
end

function PlanesBuffListWindow:openRootWnd( )
	_controller:sender23118()
end

function PlanesBuffListWindow:setData( buff_list )
	if not buff_list or next(buff_list) == nil then return end

	local buff_data = {}
	for k,v in pairs(buff_list) do
		local buff_cfg = Config.SecretDunData.data_buff[v.buff_id]
		if buff_cfg then
			_table_insert(buff_data, deepCopy(buff_cfg))
		end
	end

	self.item_scrollview:setData(buff_data)
end

function PlanesBuffListWindow:close_callback( )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	_controller:openPlanesBuffListWindow(false)
end