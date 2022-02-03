--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-07-09 16:06:34
-- @description    : 
		-- 家园详情
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

HomeworldInfoWindow = HomeworldInfoWindow or BaseClass(BaseView)

function HomeworldInfoWindow:__init()
	self.win_type = WinType.Big
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "homeworld/homeworld_info_window"

	--[[self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("homeworld", "homeworld"), type = ResourcesType.plist},
	}--]]
end

function HomeworldInfoWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container , 1) 

	local cur_storey_index = _model:getMyHomeCurStoreyIndex()
	main_container:getChildByName("win_title"):setString(cur_storey_index .. TI18N("楼详情"))
	main_container:getChildByName("title_label_1"):setString(TI18N("概况总览"))
	main_container:getChildByName("title_label_2"):setString(TI18N("舒适度基础加成"))
	main_container:getChildByName("title_label_3"):setString(TI18N("家具主题加成"))
	main_container:getChildByName("title_txt_1"):setString(TI18N("家具名"))
	main_container:getChildByName("title_txt_2"):setString(TI18N("舒适度加成值"))
	main_container:getChildByName('title_txt_3'):setString(TI18N("套装名"))
	main_container:getChildByName("title_txt_4"):setString(TI18N("套件数量"))
	main_container:getChildByName("title_txt_5"):setString(TI18N("舒适度加成值"))
	main_container:getChildByName("tips_label"):setString(TI18N("多个相同的家具存在于房间时，对应的套件数量只会激活1个"))

	self.close_btn = main_container:getChildByName("close_btn")
	self.btn_rule = main_container:getChildByName("btn_rule")

	self.soft_label = main_container:getChildByName("soft_label")
	self.homecoin_label = main_container:getChildByName("homecoin_label")
	self.worship_label = main_container:getChildByName("worship_label")
	self.base_total_txt = main_container:getChildByName("base_total_txt")
	self.suit_total_txt = main_container:getChildByName("suit_total_txt")

	local base_list_panel = main_container:getChildByName("base_list_panel")
	local scroll_view_size_1 = base_list_panel:getContentSize()
    local setting = {
        item_class = HomeworldInfoBaseItem,      -- 单元类
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

	local suit_list_panel = main_container:getChildByName("suit_list_panel")
	local scroll_view_size_2 = suit_list_panel:getContentSize()
    local setting = {
        item_class = HomeworldInfoSuitItem,      -- 单元类
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
    self.suit_scrollview = CommonScrollViewLayout.new(suit_list_panel, cc.p(0, 0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size_2, setting)
    self.suit_scrollview:setSwallowTouches(false)
end

function HomeworldInfoWindow:register_event(  )
	registerButtonEventListener(self.close_btn, function (  )
		_controller:openHomeInfoWindow(false)
	end, true, 2)

	registerButtonEventListener(self.background, function (  )
		_controller:openHomeInfoWindow(false)
	end, false, 2)

	registerButtonEventListener(self.btn_rule, function ( param,sender, event_type )
		local rule_cfg = Config.HomeData.data_const["home_value_rule"]
    	if rule_cfg then
    		TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition(), nil, nil, 550)
    	end
	end, true, 1)
end

function HomeworldInfoWindow:openRootWnd(  )
	self:setData()
end

function HomeworldInfoWindow:setData(  )
	-- 总舒适度
	local my_soft = _model:getHomeComfortValue()
	self.soft_label:setString(_string_format(TI18N("舒适度 %d"), my_soft))

	-- 家园币产出
	local cur_storey_index, max_soft_storey = _model:getMyHomeCurStoreyIndex()
	if cur_storey_index == max_soft_storey then
		local output_val = _model:getHomeCoinOutput()
		self.homecoin_label:setString(_string_format(TI18N("家园币 +%d/时"), output_val))
	else
		self.homecoin_label:setString(TI18N("本层非家园币收入楼层"))
	end

	-- 被点赞
	local worship_num = _model:getHomeWorship()
	self.worship_label:setString(_string_format(TI18N("被赞数 %d"), worship_num))

	local unit_cfg_list = {}
	local suit_data_list = {}

	local function checkAddSuitData( unit_cfg )
		if unit_cfg.set_id and unit_cfg.set_id > 0 then
			local is_have = false
			for k,v in pairs(suit_data_list) do
				if unit_cfg.set_id == v.set_id then
					is_have = true
                    local is_cal_num = true
                    for _,u_bid in pairs(v.item_list) do
                        if unit_cfg.bid == u_bid then
                            is_cal_num = false
                            break
                        end
                    end
                    if is_cal_num then
                        v.num = v.num + 1
                        _table_insert(v.item_list, unit_cfg.bid)
                    end
					break
				end
			end
			if not is_have then
				local suit_data = {}
				suit_data.set_id = unit_cfg.set_id
				suit_data.num = 1
				suit_data.cfg = Config.HomeData.data_suit_soft[unit_cfg.set_id]
				suit_data.item_list = {}
				_table_insert(suit_data.item_list, unit_cfg.bid)
				_table_insert(suit_data_list, suit_data)
			end
		end
	end

	-- 墙壁
	local wall_bid = _model:getMyHomeWallId()
	local wall_cfg = Config.HomeData.data_home_unit(wall_bid)
	if wall_cfg then
		local s_data = {}
		s_data.bid = wall_cfg.bid
		s_data.num = 1
		s_data.cfg = deepCopy(wall_cfg)
		_table_insert(unit_cfg_list, s_data)

		checkAddSuitData(wall_cfg)
	end
	-- 地板
	local floor_bid = _model:getMyHomeFloorId()
	local floor_cfg = Config.HomeData.data_home_unit(floor_bid)
	if floor_cfg then
		local s_data = {}
		s_data.bid = floor_cfg.bid
		s_data.num = 1
		s_data.cfg = deepCopy(floor_cfg)
		_table_insert(unit_cfg_list, s_data)

		checkAddSuitData(floor_cfg)
	end
	-- 家具
	local all_furniture_list = _model:getMyHomeFurnitureData()
	for k,vo in pairs(all_furniture_list) do
		local furniture_cfg = Config.HomeData.data_home_unit(vo.bid)
		if furniture_cfg then
			local is_have = false
			for _,s_data in pairs(unit_cfg_list) do
				if s_data.bid == furniture_cfg.bid then
					is_have = true
					s_data.num = s_data.num + 1
					break
				end
			end
			if not is_have then
				local s_data = {}
				s_data.bid = furniture_cfg.bid
				s_data.num = 1
				s_data.cfg = deepCopy(furniture_cfg)
				_table_insert(unit_cfg_list, s_data)
			end

			checkAddSuitData(furniture_cfg)
		end
	end

	-- 家具基础舒适度
	local total_base_soft = 0
	for k,s_data in pairs(unit_cfg_list) do
		local cal_num = math.min(s_data.cfg.effect_count, s_data.num)
		s_data.cal_soft = s_data.cfg.soft*cal_num
		total_base_soft = total_base_soft + s_data.cal_soft
	end

	self.base_total_txt:setString(_string_format(TI18N("总计:%d"), total_base_soft))
	self.base_scrollview:setData(unit_cfg_list)

	-- 套装舒适度加成
	local show_suit_data = {}
	local total_suit_soft = 0
	for k,s_data in pairs(suit_data_list) do
		local diff_val
		local cur_num
		for num,cfg in pairs(s_data.cfg) do
			if s_data.num >= num and (not diff_val or diff_val > (s_data.num - num)) then
				diff_val = s_data.num - num
				cur_num = num
			end
		end
		if cur_num then
			s_data.cfg = s_data.cfg[cur_num]
			total_suit_soft = total_suit_soft + s_data.cfg.all_soft
			_table_insert(show_suit_data, s_data)
		end
	end
	self.suit_scrollview:setData(show_suit_data)
	self.suit_total_txt:setString(_string_format(TI18N("总计:%d"), total_suit_soft))
end

function HomeworldInfoWindow:close_callback(  )
	if self.base_scrollview then
		self.base_scrollview:DeleteMe()
		self.base_scrollview = nil
	end
	if self.suit_scrollview then
		self.suit_scrollview:DeleteMe()
		self.suit_scrollview = nil
	end
	_controller:openHomeInfoWindow(false)
end

--------------------------
HomeworldInfoBaseItem = class("HomeworldInfoBaseItem", function()
    return ccui.Widget:create()
end)

function HomeworldInfoBaseItem:ctor()
	self:configUI()
	self:register_event()
end

function HomeworldInfoBaseItem:configUI(  )
	self.root_wnd = ccui.Layout:create()
    self.size = cc.size(602, 30)
    self.root_wnd:setContentSize(self.size)
    self:setContentSize(self.size)
    self.root_wnd:setTouchEnabled(false)
    self:addChild(self.root_wnd)
end

function HomeworldInfoBaseItem:register_event(  )
	
end

function HomeworldInfoBaseItem:setData( data )
	if not data then return end

	local item_cfg = Config.ItemData.data_get_data(data.bid)
	if not item_cfg then return end

	local unit_cfg = data.cfg

	if not self.name_txt then
		self.name_txt = createLabel(24, 1, nil, 20, self.size.height*0.5, nil, self.root_wnd, nil, cc.p(0, 0.5))
	end
	self.name_txt:setTextColor(BackPackConst.getWhiteQualityColorC4B(item_cfg.quality))
	self.name_txt:setString(unit_cfg.name)

	if not self.num_txt then
		self.num_txt = createLabel(24, 274, nil, 295, self.size.height*0.5, nil, self.root_wnd, nil, cc.p(0, 0.5))
	end
	self.num_txt:setString(data.num .. "/" .. unit_cfg.effect_count)

	if not self.soft_txt then
		self.soft_txt = createLabel(24, 274, nil, 450, self.size.height*0.5, nil, self.root_wnd, nil, cc.p(0, 0.5))
	end
	local min_num = math.min(data.num, unit_cfg.effect_count)
	local soft_val = min_num * unit_cfg.soft
	self.soft_txt:setString("+" .. soft_val)
end

function HomeworldInfoBaseItem:DeleteMe(  )
	self:removeAllChildren()
	self:removeFromParent()
end

--------------------------
HomeworldInfoSuitItem = class("HomeworldInfoSuitItem", function()
    return ccui.Widget:create()
end)

function HomeworldInfoSuitItem:ctor()
	self:configUI()
	self:register_event()
end

function HomeworldInfoSuitItem:configUI(  )
	self.root_wnd = ccui.Layout:create()
    self.size = cc.size(602, 30)
    self.root_wnd:setContentSize(self.size)
    self:setContentSize(self.size)
    self.root_wnd:setTouchEnabled(false)
    self:addChild(self.root_wnd)
end

function HomeworldInfoSuitItem:register_event(  )
	
end

function HomeworldInfoSuitItem:setData( data )
	if not data then return end

	if not self.name_txt then
		self.name_txt = createLabel(24, 274, nil, 20, self.size.height*0.5, nil, self.root_wnd, nil, cc.p(0, 0.5))
	end
	self.name_txt:setString(data.cfg.name)

	if not self.num_txt then
		self.num_txt = createLabel(24, 274, nil, 283, self.size.height*0.5, nil, self.root_wnd, nil, cc.p(0, 0.5))
	end
	self.num_txt:setString(data.num .. "/" .. data.cfg.num)

	if not self.soft_txt then
		self.soft_txt = createLabel(24, 274, nil, 450, self.size.height*0.5, nil, self.root_wnd, nil, cc.p(0, 0.5))
	end
	self.soft_txt:setString("+" .. data.cfg.all_soft)
end

function HomeworldInfoSuitItem:DeleteMe(  )
	self:removeAllChildren()
	self:removeFromParent()
end