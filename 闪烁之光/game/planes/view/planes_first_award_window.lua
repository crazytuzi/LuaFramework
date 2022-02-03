---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/12/23 20:48:11
-- @description: 位面首通奖励界面
---------------------------------
local _controller = PlanesController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _table_sort = table.sort

PlanesFirstAwardWindow = PlanesFirstAwardWindow or BaseClass(BaseView)

function PlanesFirstAwardWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "planes/planes_first_award_window"
end

function PlanesFirstAwardWindow:open_callback( )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	main_container:getChildByName("win_title"):setString(TI18N("首通奖励"))

	self.close_btn = main_container:getChildByName("close_btn")

	local item_list = main_container:getChildByName("item_list")
	local scroll_view_size = item_list:getContentSize()
    local setting = {
        item_class = PlanesFirstAwardItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 5,                   -- y方向的间隔
        item_width = 601,               -- 单元的尺寸width
        item_height = 147,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }
    self.item_scrollview = CommonScrollViewLayout.new(item_list, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
end

function PlanesFirstAwardWindow:register_event( )
	registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)

	self:addGlobalEvent(PlanesEvent.Get_First_Award_Event, function (  )
		if self.click_dun_id and self.item_scrollview then
			local item_list = self.item_scrollview:getItemList()
			for k,item in pairs(item_list) do
				if item:getDunId() == self.click_dun_id then
					item:updateBtnStatus()
					self.click_dun_id = nil
					break
				end
			end
		end
	end)
end

function PlanesFirstAwardWindow:onClickCloseBtn(  )
	_controller:openPlanesFirstAwardWindow(false)
end

function PlanesFirstAwardWindow:openRootWnd( )
	self:setData()
end

function PlanesFirstAwardWindow:setData(  )
	local award_data = {}
	for id,v in pairs(Config.SecretDunData.data_customs) do
		local object = {}
		object.dun_id = id
		object.award = v.first_reward or {}
		_table_insert(award_data, object)
	end
	_table_sort(award_data, SortTools.KeyLowerSorter("dun_id"))
	self.item_scrollview:setData(award_data, handler(self, self.onClickItemCallBack))
end

function PlanesFirstAwardWindow:onClickItemCallBack( dun_id )
	self.click_dun_id = dun_id
end

function PlanesFirstAwardWindow:close_callback( )
	if self.item_scrollview then
		self.item_scrollview:DeleteMe()
		self.item_scrollview = nil
	end
	_controller:openPlanesFirstAwardWindow(false)
end

---------------------------
PlanesFirstAwardItem = class("PlanesFirstAwardItem", function()
    return ccui.Widget:create()
end)

function PlanesFirstAwardItem:ctor()
	self:configUI()
	self:register_event()
end

function PlanesFirstAwardItem:configUI(  )
	self.size = cc.size(601, 147)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("planes/planes_first_award_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")

	container:getChildByName("first_title"):setString(TI18N("首次通过"))

	self.dun_name_txt = container:getChildByName("dun_name_txt")
	self.dun_name_txt:setPositionX(111)
	self.get_btn = container:getChildByName("get_btn")
	self.get_btn_label = self.get_btn:getChildByName("label")
	self.get_btn_label:setString(TI18N("领取"))
	self.got_sp = container:getChildByName("got_sp")

	local item_list = container:getChildByName("item_list")
	local scroll_view_size = item_list:getContentSize()
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 10,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                   -- y方向的间隔
        item_width = BackPackItem.Width*0.7,               -- 单元的尺寸width
        item_height = BackPackItem.Height*0.7,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
        scale = 0.7
    }
    self.award_item_scrollview = CommonScrollViewLayout.new(item_list, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)
	self.award_item_scrollview:setSwallowTouches(false)
end

function PlanesFirstAwardItem:register_event(  )
	registerButtonEventListener(self.get_btn, handler(self, self.onClickGetBtn), true)
end

function PlanesFirstAwardItem:onClickGetBtn(  )
	if not self.data then return end
	local is_can_get = _model:checkIsCanGetAwardByDunId(self.data.dun_id)
	if is_can_get then
		if self.callback then
			self.callback(self.data.dun_id)
		end
		_controller:sender23117(self.data.dun_id)
	end
end

function PlanesFirstAwardItem:setData( data )
	if not data then return end

	self.data = data

	-- 名称
	local info_cfg = Config.SecretDunData.data_dun_info[data.dun_id]
	if info_cfg then
		self.dun_name_txt:setString(info_cfg.name or "")
	end

	-- 奖励
	local award_list = {}
	for k, v in pairs(data.award or {}) do
		local vo = {}
		vo.bid = v[1]
		vo.quantity = v[2]
		_table_insert(award_list, vo)
	end
	self.award_item_scrollview:setData(award_list)
	self.award_item_scrollview:addEndCallBack(function()
		local list = self.award_item_scrollview:getItemList()
		for k,v in pairs(list) do
			v:setDefaultTip()
		end
	end)

	self:updateBtnStatus()
end

function PlanesFirstAwardItem:updateBtnStatus(  )
	if not self.data then return end
	local is_can_get = _model:checkIsCanGetAwardByDunId(self.data.dun_id)
	local is_got_award = _model:checkIsGetAwardByDunId(self.data.dun_id)
	if is_got_award then -- 已领取
		self.got_sp:setVisible(true)
		self.get_btn:setVisible(false)
	elseif not is_can_get then -- 不可领取
		self.got_sp:setVisible(false)
		self.get_btn:setVisible(true)
		self.get_btn:setTouchEnabled(false)
		setChildUnEnabled(true, self.get_btn)
		self.get_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
	else -- 可领取
		self.got_sp:setVisible(false)
		self.get_btn:setVisible(true)
		self.get_btn:setTouchEnabled(true)
		setChildUnEnabled(false, self.get_btn)
		self.get_btn_label:enableOutline(Config.ColorData.data_color4[278], 2)
	end
end

function PlanesFirstAwardItem:addCallBack( callback )
	self.callback = callback
end

function PlanesFirstAwardItem:getDunId(  )
	if self.data then
		return self.data.dun_id
	end
end

function PlanesFirstAwardItem:DeleteMe(  )
	if self.award_item_scrollview then
		self.award_item_scrollview:DeleteMe()
		self.award_item_scrollview = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end