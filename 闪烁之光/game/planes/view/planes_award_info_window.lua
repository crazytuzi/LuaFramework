---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/12/16 23:08:34
-- @description: 位面奖励加成
---------------------------------
local _controller = PlanesController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert

PlanesAwardInfoWindow = PlanesAwardInfoWindow or BaseClass(BaseView)

function PlanesAwardInfoWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "planes/planes_award_info_window"
end

function PlanesAwardInfoWindow:open_callback( )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
    self:playEnterAnimatianByObj(main_container , 1)

	self.close_btn = main_container:getChildByName("close_btn")
	self.base_total_txt = main_container:getChildByName("base_total_txt")

	main_container:getChildByName("win_title"):setString(TI18N("宝箱奖励加成"))
	main_container:getChildByName("title_label_2"):setString(TI18N("宝箱奖励加成"))
	main_container:getChildByName("title_txt_1"):setString(TI18N("加成条件"))
	main_container:getChildByName("title_txt_6"):setString(TI18N("加成值"))
	main_container:getChildByName("title_txt_2"):setString(TI18N("是否达成"))
	main_container:getChildByName("tips_label"):setString(TI18N("副本探索度达100%后，永久加成所有副本的宝箱奖励"))

	local base_list_panel = main_container:getChildByName("base_list_panel")
	local scroll_view_size_1 = base_list_panel:getContentSize()
    local setting = {
        item_class = PlanesAwardInfoItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 602,               -- 单元的尺寸width
        item_height = 30,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.base_scrollview = CommonScrollViewLayout.new(base_list_panel, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size_1, setting)
    self.base_scrollview:setSwallowTouches(false)
end

function PlanesAwardInfoWindow:register_event( )
	registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
	registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
end

function PlanesAwardInfoWindow:onClickCloseBtn(  )
	_controller:openPlanesAwardInfoWindow(false)
end

function PlanesAwardInfoWindow:openRootWnd( )
	self:setData()
end

function PlanesAwardInfoWindow:setData(  )
	local add_val = 0
	local show_data_list = {}
	for id,cfg in pairs(Config.SecretDunData.data_customs) do
		if cfg.add_radio > 0 then
			local object = {}
			object.dun_id = id
			object.dun_info = Config.SecretDunData.data_dun_info[id]
			object.add_radio = cfg.add_radio
			if _model:checkDunIsPassByDunId(id) then
				add_val = add_val + cfg.add_radio
			end
			_table_insert(show_data_list, object)
		end
	end
	table.sort(show_data_list, SortTools.KeyLowerSorter("dun_id"))
	self.base_scrollview:setData(show_data_list)

	self.base_total_txt:setString(TI18N(string.format("当前总加成:%d%%", add_val/10)))
end

function PlanesAwardInfoWindow:close_callback( )
	if self.base_scrollview then
		self.base_scrollview:DeleteMe()
		self.base_scrollview = nil
	end
	_controller:openPlanesAwardInfoWindow(false)
end

----------------------
PlanesAwardInfoItem = class("PlanesAwardInfoItem", function()
    return ccui.Widget:create()
end)

function PlanesAwardInfoItem:ctor()
	self:configUI()
	self:register_event()
end

function PlanesAwardInfoItem:configUI(  )
	self.root_wnd = ccui.Layout:create()
    self.size = cc.size(602, 30)
    self.root_wnd:setContentSize(self.size)
    self:setContentSize(self.size)
    self.root_wnd:setTouchEnabled(false)
    self:addChild(self.root_wnd)
end

function PlanesAwardInfoItem:register_event(  )
	
end

function PlanesAwardInfoItem:setData( data )
	if not data then return end

	if not self.name_txt then
		self.name_txt = createLabel(24, 274, nil, 0, self.size.height*0.5, nil, self.root_wnd, nil, cc.p(0, 0.5))
	end
	if data.dun_info and data.dun_info.name then
		self.name_txt:setString(TI18N(string.format("[%s]探索度达100%%", data.dun_info.name)))
	end

	if not self.num_txt then
		self.num_txt = createLabel(24, cc.c4b(36,144,3, 255), nil, 352, self.size.height*0.5, nil, self.root_wnd, nil, cc.p(0, 0.5))
	end
	data.add_radio = data.add_radio or 0
	self.num_txt:setString(data.add_radio/10 .. "%")

	if not self.reach_txt then
		self.reach_txt = createLabel(24, 274, nil, 492, self.size.height*0.5, nil, self.root_wnd, nil, cc.p(0, 0.5))
	end
	if _model:checkDunIsPassByDunId(data.dun_id) then
		self.reach_txt:setString(TI18N("已达成"))
		self.reach_txt:setTextColor(cc.c4b(36,144,3, 255))
	else
		self.reach_txt:setString(TI18N("未达成"))
		self.reach_txt:setTextColor(cc.c4b(0x64,0x32,0x23,0xff))
	end
end

function PlanesAwardInfoItem:DeleteMe(  )
	self:removeAllChildren()
	self:removeFromParent()
end