-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: htp(必填, 创建模块的人员)
-- @editor: htp(必填, 后续维护以及修改的人员)
-- @description:
--      位面冒险地图场景
-- <br/>Create: 2019-11-27
-- --------------------------------------------------------------------
local _controller = PlanesController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert
local _table_remove = table.remove
local _table_sort = table.sort

PlanesMapWindow = PlanesMapWindow or BaseClass(BaseView)

function PlanesMapWindow:__init()
	self.is_full_screen = true
	self.win_type = WinType.Full
	self.view_tag = ViewMgrTag.WIN_TAG
	self.layout_name = "planes/planes_map_window"

    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("planes", "planes_map"), type = ResourcesType.plist},
	}

	self:initConfig()
end

-- 初始化数据
function PlanesMapWindow:initConfig(  )
	self.cur_role_grid_index = 0 -- 角色当前所在的格子
	self.is_role_moving = false  -- 角色是否正在行走中
	self.grid_object_list = {} 	 -- 格子列表(key为格子下标)
	self.par_grid_object_list = {} -- 格子列表(用于排序设置层级)
	self.evt_item_list = {} 	 -- 事件图标列表
	self.role_move_grid_cache = {} -- 角色待移动的格子坐标列表
	self.is_hide_top = false  -- 当前是否隐藏了顶部UI
	self.route_effect_list = {}  -- 路线特效列表
	self.break_effect_list = {}  -- 地块裂开特效列表

	-- 地图场景大小
	self.cur_map_width = PlanesConst.Map_Width
	self.cur_map_height = PlanesConst.Map_Height
end

function PlanesMapWindow:open_callback( )
	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())

	-- 触摸层
	self.touch_slayer = self.root_wnd:getChildByName("touch_slayer")
	self.touch_slayer:setScale(display.getMaxScale())
	self.touch_slayer:setSwallowTouches(false)

	self.map_container = self.root_wnd:getChildByName("map_container")
	-- 地图格子层
	self.grid_slayer = self.map_container:getChildByName("grid_slayer")
	-- 事件和角色层
	self.evt_slayer = self.map_container:getChildByName("evt_slayer")

	-- ui层
	self.ui_container = self.root_wnd:getChildByName("ui_container")
	self.close_btn = self.ui_container:getChildByName("close_btn")
	self.close_btn:getChildByName("label"):setString(TI18N("返回"))
	self.dun_btn = self.ui_container:getChildByName("dun_btn")
	self.dun_btn:getChildByName("label"):setString(TI18N("副本信息"))
	self.figure_btn = self.ui_container:getChildByName("figure_btn")
	self.figure_btn:getChildByName("label"):setString(TI18N("更换形象"))
	local look_id = _model:getPlanesRoleLookId()
	if not look_id or look_id == 0 then
		setChildUnEnabled(true, self.figure_btn)
	else
		setChildUnEnabled(false, self.figure_btn)
	end
	self.btn_rule = self.ui_container:getChildByName("btn_rule")
	self.btn_hide = self.ui_container:getChildByName("btn_hide")

	self.bottom_panel = self.ui_container:getChildByName("bottom_panel")
	self.bag_btn = self.bottom_panel:getChildByName("bag_btn")
	self.hero_btn = self.bottom_panel:getChildByName("hero_btn")
	self.buff_btn = self.bottom_panel:getChildByName("buff_btn")

	local shadow_bg_1 = self.ui_container:getChildByName("shadow_bg_1")
	local shadow_bg_2 = self.ui_container:getChildByName("shadow_bg_2")

	-- 章节开启
	self.chapter_panel = self.ui_container:getChildByName("chapter_panel")
	self.chapter_panel:setVisible(false)
	self.chapter_name_txt = self.chapter_panel:getChildByName("chapter_name_txt")
	self.chapter_desc_txt = self.chapter_panel:getChildByName("chapter_desc_txt")

	self.top_title_bg = self.ui_container:getChildByName("top_title_bg")
	self.floor_txt = self.top_title_bg:getChildByName("floor_txt")

	-- 适配
	local top_off = display.getTop()
	local bottom_off = display.getBottom()
	self.bottom_panel:setPositionY(bottom_off+79)
	self.close_btn:setPositionY(top_off-140)
	self.dun_btn:setPositionY(top_off-245)
	self.figure_btn:setPositionY(top_off-350)
	self.btn_rule:setPositionY(top_off-160)
	self.btn_hide:setPositionY(top_off-230)
	shadow_bg_1:setPositionY(bottom_off)
	shadow_bg_2:setPositionY(top_off)
	self.top_title_bg:setPositionY(top_off)

	MainuiController:getInstance():setIsShowMainUIBottom(false) -- 隐藏底部UI
end

function PlanesMapWindow:register_event( )
	registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
	registerButtonEventListener(self.dun_btn, handler(self, self.onClickDunBtn), true)
	registerButtonEventListener(self.btn_hide, handler(self, self.onClickHideBtn), true)
	registerButtonEventListener(self.bag_btn, handler(self, self.onClickBagBtn), true)
	registerButtonEventListener(self.hero_btn, handler(self, self.onClickHeroBtn), true)
	registerButtonEventListener(self.buff_btn, handler(self, self.onClickBuffBtn), true)
	registerButtonEventListener(self.btn_rule, handler(self, self.onClickRuleBtn), true)
	registerButtonEventListener(self.figure_btn, handler(self, self.onClickFigureBtn), true)

	-- 移动场景
	self.touch_slayer:addTouchEventListener(function ( sender, event_type )
		if not self.init_tile_end then return end

		if self.is_role_moving then
			self.stop_center_flag = true -- 移动过程中点击了则停止镜头跟随
		end
    	if event_type == ccui.TouchEventType.began then
			self.touch_began_pos = sender:getTouchBeganPosition()
			self.last_pos = self.touch_began_pos  
    	elseif event_type == ccui.TouchEventType.moved then
    		local touch_move_pos = sender:getTouchMovePosition()
    		if self.last_pos then
    			local offset_x = touch_move_pos.x - self.last_pos.x
    			local offset_y = touch_move_pos.y - self.last_pos.y
    			self.last_pos = touch_move_pos
    			self:onTouchMoveMap(offset_x, offset_y)
			end
		elseif event_type == ccui.TouchEventType.ended then
			local touch_end = sender:getTouchEndPosition()
			if self.touch_began_pos and touch_end and (math.abs(touch_end.x - self.touch_began_pos.x) <= 20 and math.abs(touch_end.y - self.touch_began_pos.y) <= 20) then 
				if self.is_role_moving then -- 移动过程中点击了，则走到下一个格子时停止移动
					self.target_grid_index = nil -- 清掉待触发的事件格子
					self.role_move_grid_cache = {} -- 清掉待行走的格子
				else
					local grid_pos = self.grid_slayer:convertToNodeSpace(touch_end)
					local grid_x, grid_y = PlanesTile.toTile(grid_pos.x, grid_pos.y)
					local grid_index = PlanesTile.tileIndex(grid_x, grid_y)
					self:onClickGridIconByIndex(grid_index)
				end
			end 
    	end
	end)

	-- 地图层的数据
	self:addGlobalEvent(PlanesEvent.Update_Map_Data_Event, function ( data )
		self:setData(data)
	end)

	-- 更新部分格子数据
	self:addGlobalEvent(PlanesEvent.Update_Grid_Event, function ( data )
		if data then
			self:updateSomeGridData(data)
		end
	end)

	-- 新增事件显示
	self:addGlobalEvent(PlanesEvent.Add_Evt_Data_Event, function ( evt_vo_list )
		if self.init_evt_end and evt_vo_list then
			self:addEvtItemList(evt_vo_list)
		end
	end)

	-- 移动角色进入某一格子
	self:addGlobalEvent(PlanesEvent.Update_Role_Grid_Event, function ( data )
		if data then
			if data.code == 0 then -- 进入格子失败（正常情况下不会发生）
				self:doRoleStopMove()
			end
		end
	end)

	-- buff进背包的动画
	self:addGlobalEvent(PlanesEvent.Chose_Buff_Event, function ( buff_id, world_pos )
		self:showBuffItemMoveAni(buff_id, world_pos)
	end)

	-- 格子裂开特效
	self:addGlobalEvent(PlanesEvent.Show_Break_Effect_Event, function ( index_list )
		self:showBreakEffect(index_list)
	end)

	-- 更换形象
	self:addGlobalEvent(HomeworldEvent.Update_My_Home_Figure_Event, function (  )
		local look_id = HomeworldController:getInstance():getModel():getMyCurHomeFigureId()
		self:createRole(look_id)
	end)
end

-- 移动地图场景
function PlanesMapWindow:onTouchMoveMap( offset_x, offset_y )
	if not self.map_container then return end

	local pos_x, pos_y = self.map_container:getPosition()
	local new_pos_x = pos_x + offset_x
	local new_pos_y = pos_y + offset_y
	new_pos_x, new_pos_y = self:checkMapSafePos(new_pos_x, new_pos_y)
	self.map_container:setPosition(cc.p(new_pos_x, new_pos_y))
end

-- 检测棋盘的坐标是否超出边界
function PlanesMapWindow:checkMapSafePos( pos_x, pos_y )
	if pos_x > self.map_max_pos_x then
		pos_x = self.map_max_pos_x
	elseif pos_x < self.map_min_pos_x then
		pos_x = self.map_min_pos_x
	end
	if pos_y > self.map_max_pos_y then
		pos_y = self.map_max_pos_y
	elseif pos_y < self.map_min_pos_y then
		pos_y = self.map_min_pos_y
	end
	return pos_x, pos_y
end

function PlanesMapWindow:onClickCloseBtn(  )
	_controller:openPlanesMapWindow(false)
end

--打开背包
function PlanesMapWindow:onClickBagBtn(  )
	_controller:openPlanesBagPanel(true)
end

--打开英雄界面
function PlanesMapWindow:onClickHeroBtn(  )
	_controller:openPlanesHeroListPanel(true)
end

-- 点击副本信息
function PlanesMapWindow:onClickDunBtn(  )
	if self.cur_dun_id then
		_controller:openPlanesDunInfoWindow(true, self.cur_dun_id)
	end
end

-- 隐藏上栏
function PlanesMapWindow:onClickHideBtn(  )
	self.is_hide_top = not self.is_hide_top
	MainuiController:getInstance():setMainUIShowStatus(not self.is_hide_top)
	MainuiController:getInstance():setIsShowMainUIBottom(false)
	self.top_title_bg:setVisible(not self.is_hide_top)
	self.btn_rule:setVisible(not self.is_hide_top)
	self.btn_hide:setVisible(not self.is_hide_top)
	self.close_btn:setVisible(not self.is_hide_top)
	self.dun_btn:setVisible(not self.is_hide_top)
	self.bottom_panel:setVisible(not self.is_hide_top)

	if self.is_hide_top then
		if not self.hide_mask then
			self.hide_mask = ccui.Layout:create()
			self.hide_mask:setContentSize(SCREEN_WIDTH, SCREEN_HEIGHT)
			self.hide_mask:setScale(display.getMaxScale())
			self.hide_mask:setAnchorPoint(cc.p(0.5, 0.5))
			self.hide_mask:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
			self.hide_mask:setTouchEnabled(true)
			self.ui_container:addChild(self.hide_mask, 99)
			self.hide_mask:setSwallowTouches(false)
			self.hide_mask:addTouchEventListener(function(sender, event_type)
				if event_type == ccui.TouchEventType.ended then
					self:onClickHideBtn()
				end
			end)
		end
		self.hide_mask:setVisible(true)
	elseif self.hide_mask then
		self.hide_mask:setVisible(false)
	end
end

-- buff列表
function PlanesMapWindow:onClickBuffBtn(  )
	_controller:openPlanesBuffListWindow(true)
end

function PlanesMapWindow:onClickRuleBtn( param, sender, event_type )
	local rule_cfg = Config.SecretDunData.data_const["planes_rule"]
	if rule_cfg then
		TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
	end
end

function PlanesMapWindow:onClickFigureBtn(  )
	if self.is_role_moving then
		message(TI18N("角色移动中，无法更换形象"))
		return
	end
	local look_id = _model:getPlanesRoleLookId()
	if not look_id or look_id == 0 then
		local limit_cfg = Config.HomeData.data_const["open_lev"]
		local open_lv = 70
		if limit_cfg then
			open_lv = limit_cfg.val or 70
		end
		message(_string_format(TI18N("%s级开启家园系统，开启后才可更换Q版冒险形象哦~"), open_lv))
	else
		HomeworldController:getInstance():openHomeworldFigureWindow(true)
	end
end

function PlanesMapWindow:openRootWnd( param )
	param = param or {}
	self.cur_dun_id = param.dun_id or _model:getCurDunId() -- 当前副本id
	self.cur_floor = param.floor or _model:getCurPlanesFloor() -- 当前层数
	if self.cur_dun_id == 0 or self.cur_floor == 0 then
		_controller:openPlanesMapWindow(false)
		return
	end
	_controller:sender23106(self.cur_floor) -- 请求当前层的数据
	_controller:sender23115() -- 请求可出战的英雄数据

	-- 是否有待显示的剧情缓存数据
	local dram_id = _model:getPlanesDramIdCache()
	local dram_cfg = Config.SecretDunData.data_drama[dram_id]
	if dram_cfg then
		delayOnce(function (  )
			MonopolyController:getInstance():openMonopolyDialogWindow(true, 89, 0, dram_cfg)
		end, 0.5)
		_model:setPlanesDramIdCache(0)
	end
end

function PlanesMapWindow:setVisible( bool )
	self.is_visible = bool
	if self.root_wnd == nil or tolua.isnull(self.root_wnd) then return end
	self.root_wnd:setVisible(bool)
	if bool == true then
		MainuiController:getInstance():setIsShowMainUIBottom(false) -- 隐藏底部UI
	else
		MainuiController:getInstance():setIsShowMainUIBottom(true) -- 隐藏底部UI
	end
end

function PlanesMapWindow:setData( data )
	if not data then return end
	self:playCloudEffect(true)

	self:initMapTileConfig(data.map_id)

	self.data = data
	self.cur_floor = data.floor -- 当前层
	self.cur_role_grid_index = data.index -- 当前角色所在格子
	self.cur_grid_data = {} -- 格子数据
	for _,g_data in pairs(data.tile_list or {}) do -- 以格子下标为key来存储
		self.cur_grid_data[g_data.index] = g_data
	end
	local all_evt_data = _model:getPlanesEvtVoList() -- 所有事件数据
	local show_grid_data = {} -- 通过后端发过来的走过的格子，算出需要显示的格子
	local show_evt_data = {}
	if data.walk_tile and next(data.walk_tile) ~= nil then
		local temp_index_list = {}
		for _,v in pairs(data.walk_tile) do
			local grid_x, grid_y = PlanesTile.indexTile(v.pos)
			local range_list = PlanesTile.tileRange(grid_x, grid_y, PlanesConst.Grid_Round, PlanesConst.Grid_Round)
			for k,g_pos in pairs(range_list) do
				if g_pos[1] and g_pos[2] then
					local g_index = PlanesTile.tileIndex(g_pos[1], g_pos[2])
					if not temp_index_list[g_index] and self.cur_grid_data[g_index] then
						temp_index_list[g_index] = true
						_table_insert(show_grid_data, self.cur_grid_data[g_index])
						_table_insert(show_evt_data, all_evt_data[g_index])
					end
				end
			end
		end
	end

	-- 当前层名称
	local cur_dun_id = _model:getCurDunId()
	local max_floor_num = Config.SecretDunData.data_max_dun_num[self.cur_floor]
	local dun_info = Config.SecretDunData.data_dun_info[cur_dun_id]
	if dun_info and max_floor_num then
		self.floor_txt:setString(TI18N(_string_format("%s 第%d/%d层", dun_info.name, self.cur_floor, max_floor_num)))
	end
	-- 创建地图背景
	self:updateMapBg()
	-- 创建地板
	self.init_grid_end = false
	self:updateGridList(show_grid_data, true) -- 只创建能看见的
	-- 创建事件
	self.init_evt_end = false
	self:updateEvtList(show_evt_data)
	-- 创建角色
	self:createRole()
	-- 角色移动到屏幕中间
	self:moveMapToRoleCenter()
	-- 播放背景音乐
	self:playBackgroundMusic()
end

function PlanesMapWindow:playBackgroundMusic(  )
	local cur_dun_id = _model:getCurDunId()
	local dun_cfg = Config.SecretDunData.data_customs[cur_dun_id]
	if not dun_cfg then return end

	if not self.cur_music or self.cur_music ~= dun_cfg.music then
		self.cur_music = dun_cfg.music
		if dun_cfg.music ~= "" then
			AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.SCENE, dun_cfg.music, true)
		end
	end
end

-- 初始化地图格子数据
function PlanesMapWindow:initMapTileConfig( map_id )
	if not map_id then return end
	self.cur_block_cfg = Config.MapBlock.data(map_id) or {} -- 当前地图的地编数据
	local map_cfg = Config.Map[map_id]
	if map_cfg then
		self.cur_map_width = map_cfg.width
		self.cur_map_height = map_cfg.height
	end
	-- 地图的最大、最小坐标
	self.map_min_pos_x = SCREEN_WIDTH - self.cur_map_width
	self.map_max_pos_x = 0
	self.map_min_pos_y = display.height - self.cur_map_height
	self.map_max_pos_y = 0

	PlanesTile.init(PlanesConst.Grid_Width*0.5, PlanesConst.Grid_Height*0.5, self.cur_map_width, self.cur_map_height)
	self.init_tile_end = true -- 初始化地图数据完成才可以进行一些操作
end

-- 更新地图背景
function PlanesMapWindow:updateMapBg(  )
	if not self.cur_dun_id or not self.cur_floor then return end
	local dun_map_cfg = Config.SecretDunData.data_dun_map[self.cur_dun_id]
	if not dun_map_cfg or not dun_map_cfg[self.cur_floor] then return end

	local map_res_id = dun_map_cfg[self.cur_floor].map_res_id or 1
	if not self.cur_map_res_id or self.cur_map_res_id ~= map_res_id then
		self.cur_map_res_id = map_res_id
		local map_res_path = _string_format("resource/planes/map_bg/map_bg_%s.jpg", map_res_id)
		self.bg_img_load = loadImageTextureFromCDN(self.background, map_res_path, ResourcesType.single, self.bg_img_load)
	end
end

-- 创建地板
function PlanesMapWindow:updateGridList( grid_data_list, is_init )
	if not grid_data_list or next(grid_data_list) == nil then return end

	-- 先加载所有格子资源
	if self.grid_icon_load then
		self.grid_icon_load:DeleteMe()
		self.grid_icon_load = nil
	end
	local grid_res_list = {}
	local temp_res_list = {} -- 用于判断资源是否已经存在
	for k,v in pairs(grid_data_list) do
		if not temp_res_list[v.res_id] then
			local grid_res = self:getGridPathByResId(v.res_id)
			_table_insert(grid_res_list, {path = grid_res, type = ResourcesType.single})
			temp_res_list[v.res_id] = true
		end
	end
	self.grid_icon_load = ResourcesLoad.New()
	self.grid_icon_load:addAllList(grid_res_list, function (  )
		if is_init then -- 第一次创建格子时
			for _,grid_object in pairs(self.grid_object_list) do
				if grid_object.grid_icon then
					grid_object.grid_icon:setVisible(false)
					if grid_object.grid_data then
						grid_object.grid_data.is_hide = 1
					end
				end
			end
			local delay_index = 0
			local temp_index = 0
			for i,g_data in ipairs(grid_data_list) do
				delay_index = delay_index + 1
				delayRun(self.grid_slayer, (delay_index/5) / display.DEFAULT_FPS, function (  )
					self:createOneGridObject(g_data)
					temp_index = temp_index + 1
					if temp_index == tableLen(grid_data_list) then -- 格子初始化完成
						self.init_grid_end = true
					end
				end)
			end
		else
			for i,g_data in pairs(grid_data_list) do
				self:createOneGridObject(g_data)
			end
		end
	end)
end

-- 创建或刷新一个格子
function PlanesMapWindow:createOneGridObject( g_data, is_hide )
	local index = g_data.index
	local object = self.grid_object_list[index] or {}
	local grid_icon = object.grid_icon
	if not grid_icon then
		grid_icon = createImage(self.grid_slayer, nil, 0, 0, cc.p(0.5, 0.5), false)
		grid_icon:ignoreContentAdaptWithSize(true)

		-- test 
		-- object.text_txt = createLabel(18, 2, nil,PlanesConst.Grid_Width*0.5, PlanesConst.Grid_Height*0.5, "", self.evt_slayer, nil, cc.p(0.5, 0.5))
		-- object.text_txt:setLocalZOrder(9999)

		object.grid_icon = grid_icon
		self.grid_object_list[index] = object
	_table_insert(self.par_grid_object_list, object)
	end
	if grid_icon then
		if g_data.is_hide == 1 then -- 后端告知要隐藏
			grid_icon:setVisible(false)
		else
			local grid_res = self:getGridPathByResId(g_data.res_id)
			if not object.grid_data or grid_icon.grid_res ~= grid_res then
				grid_icon.grid_res = grid_res
				grid_icon:loadTexture(grid_res, LOADTEXT_TYPE)
				local grid_size = grid_icon:getContentSize()
				grid_icon:setAnchorPoint(cc.p(0.5, 1-(PlanesConst.Grid_Height*0.5/grid_size.height)))
			end
			grid_icon:setVisible(not is_hide)
			local pos_x, pos_y = PlanesTile.indexPixel(g_data.index)
			object.pos_x = pos_x
            object.pos_y = pos_y
			grid_icon:setPosition(pos_x, pos_y)
			-- 设置层级，y越小层级越高，x越大层级越高
			local grid_x, grid_y = PlanesTile.indexTile(index)
			grid_icon:setLocalZOrder((100-grid_y)*100 + grid_x)

			-- test
			-- object.text_txt:setPosition(pos_x, pos_y)
			-- object.text_txt:setString(_string_format("%s,evt:%s", g_data.is_walk, g_data.index))
		end
	end
	self.cur_grid_data[index] = g_data
	object.grid_data = g_data
end

-- 显示地板格子入场动画
function PlanesMapWindow:showGridEnterAniByIndex( index_list )
	local cur_grid_x, cur_grid_y = PlanesTile.indexTile(self.cur_role_grid_index)
	for _,index in pairs(index_list) do
		local object = self.grid_object_list[index]
		if object and object.grid_icon and object.grid_data then
			object.grid_icon:setVisible(true)
			object.grid_icon:setOpacity(0)

			local grid_x, grid_y = PlanesTile.indexTile(index)
			local pos_x, pos_y = PlanesTile.indexPixel(index)
			local fade_in = cc.FadeIn:create(0.4)
			local move_to = cc.EaseBackOut:create(cc.MoveTo:create(0.4, cc.p(pos_x, pos_y)))

			local distance = PlanesTile.tileDistance(grid_x, grid_y, cur_grid_x, cur_grid_y)
			local random_val = math.random(5, 10)/10
			local delay_time = distance/4*random_val
			local delay_act = cc.DelayTime:create(delay_time)
			object.grid_icon:setPositionY(pos_y-200)
			object.grid_icon:runAction(cc.Sequence:create(delay_act, cc.Spawn:create(fade_in, move_to)))

			-- 事件
			if object.grid_data and object.grid_data.evtid > 0 then
				local evt_item = self.evt_item_list[index]
				if evt_item then
					evt_item:showEvtEnterAni(delay_time)
				end
			end
		end
	end
end

-- 更新部分地板数据
function PlanesMapWindow:updateSomeGridData( grid_data_list )
	if grid_data_list and next(grid_data_list) ~= nil and self.init_grid_end then -- 格子初始化完成才能更新
		self:updateGridList(grid_data_list)
	end
end

-- 检测周围需要显示的格子
function PlanesMapWindow:checkShowRoundGrid( grid_index )
	if not grid_index then return end

	local grid_x, grid_y = PlanesTile.indexTile(grid_index)
	local add_grid_list = PlanesTile.tileRange(grid_x, grid_y, PlanesConst.Grid_Round, PlanesConst.Grid_Round)

	local show_ani_index_list = {}
	for k,v in pairs(add_grid_list) do
		if v[1] and v[2] then
			local grid_index = PlanesTile.tileIndex(v[1], v[2])
			local g_data = self.cur_grid_data[grid_index]
			local old_object = self.grid_object_list[grid_index]
			if g_data and g_data.is_hide == 0 and (not old_object or (old_object.grid_data and old_object.grid_data.is_hide == 1)) then
				-- 格子
				self:createOneGridObject(g_data, true)
				_table_insert(show_ani_index_list, grid_index)
				-- 事件
				local evt_vo = _model:getPlanesEvtVoByGridIndex(grid_index)
				self:createOneEvtItem(evt_vo, true)
			end
		end
	end
	if next(show_ani_index_list) ~= nil then
		self:showGridEnterAniByIndex(show_ani_index_list)
	end
end

-- 获取格子图标资源
function PlanesMapWindow:getGridPathByResId(res_id)
    if res_id and res_id ~= "" then
        return _string_format("resource/planes/grid_icon/%s.png", res_id)
    end
end

-- 创建事件列表
function PlanesMapWindow:updateEvtList( evt_vo_list )
	if not evt_vo_list or next(evt_vo_list) == nil then return end

	-- 先加载所有事件资源
	if self.evt_icon_load then
		self.evt_icon_load:DeleteMe()
		self.evt_icon_load = nil
	end
	local evt_res_list = self:getEvtResPathListByData(evt_vo_list)
	self.evt_icon_load = ResourcesLoad.New()
	self.evt_icon_load:addAllList(evt_res_list, function (  )
		for _,item in pairs(self.evt_item_list) do
			item:setVisible(false)
		end
		local index = 0
		local temp_index = 0
		for k,vo in pairs(evt_vo_list) do
			index = index + 1
			delayRun(self.evt_slayer, (index/5) / display.DEFAULT_FPS, function ( )
				self:createOneEvtItem(vo)
				temp_index = temp_index + 1
				if temp_index == tableLen(evt_vo_list) then -- 格子初始化完成
					self.init_evt_end = true
				end
			end)
		end
	end)
end

-- 创建或更新一个事件item
function PlanesMapWindow:createOneEvtItem( evt_vo, is_hide )
	if not evt_vo then return end
	local index = evt_vo.index
	local evt_item = self.evt_item_list[index]
	if not evt_item then
		evt_item = PlanesEvtItem.New(self.evt_slayer)
		self.evt_item_list[index] = evt_item
	end
	evt_item:setData(evt_vo, is_hide)
	-- 格子
	local pos_x, pos_y = PlanesTile.indexPixel(index)
	evt_item:setPosition(pos_x, pos_y)
	-- 层级
	local grid_x, grid_y = PlanesTile.indexTile(index)
	evt_item:setLocalZOrder((100-grid_y)*100 + grid_x)
end

-- 获取事件的资源路径列表
function PlanesMapWindow:getEvtResPathListByData( evt_vo_list )
	local evt_res_list = {}
	local temp_res_list = {} -- 用于判断资源是否已经存在
	for k,vo in pairs(evt_vo_list) do
		local res_cfg
		if vo.status == PlanesConst.Evt_State.Doing then -- 未完成
			res_cfg = vo.config.res_1
		else
			res_cfg = vo.config.res_2
		end
		if res_cfg and res_cfg[1] and res_cfg[1] == 1 then
			if not temp_res_list[res_cfg[2]] then
				local evt_res = self:getEvtPathByResId(res_cfg[2])
				_table_insert(evt_res_list, {path = evt_res, type = ResourcesType.single})
				temp_res_list[res_cfg[2]] = true
			end
		end
	end
	return evt_res_list
end

-- 新增事件
function PlanesMapWindow:addEvtItemList( evt_vo_list )
	if not evt_vo_list or next(evt_vo_list) == nil then return end

	-- 先加载所有事件资源
	if self.evt_icon_load then
		self.evt_icon_load:DeleteMe()
		self.evt_icon_load = nil
	end
	local evt_res_list = self:getEvtResPathListByData(evt_vo_list)
	self.evt_icon_load = ResourcesLoad.New()
	self.evt_icon_load:addAllList(evt_res_list, function (  )
		for k,vo in pairs(evt_vo_list) do
			local evt_item = self.evt_item_list[vo.index]
			if not evt_item then
				evt_item = PlanesEvtItem.New(self.evt_slayer)
				self.evt_item_list[vo.index] = evt_item
			end
			evt_item:setData(vo)
			-- 格子
			local pos_x, pos_y = PlanesTile.indexPixel(vo.index)
			evt_item:setPosition(pos_x, pos_y)
			-- 层级
			local grid_x, grid_y = PlanesTile.indexTile(vo.index)
			evt_item:setLocalZOrder((100-grid_y)*100 + grid_x)
		end
	end)
end

-- 获取事件图标资源
function PlanesMapWindow:getEvtPathByResId( res_id )
	if res_id and res_id ~= "" then
        return _string_format("resource/planes/evt_icon/%s.png", res_id)
    end
end

-- 创建角色
function PlanesMapWindow:createRole( look_id )
	look_id = look_id or _model:getPlanesRoleLookId()

	if not self.cur_look_id or self.cur_look_id ~= look_id then
		self.cur_look_id = look_id
		self:removeMapRole()
		local figure_cfg = Config.HomeData.data_figure[look_id]
		local effect_id = "H60001"
		if figure_cfg then
			effect_id = figure_cfg.look_id
		end
		self.map_role = createEffectSpine( effect_id, cc.p(0, 0), cc.p(0.5, 0), true, PlayerAction.idle )
		self.map_role:setScale(0.4)
		self.map_role:setTimeScale(1.6)
		self.evt_slayer:addChild(self.map_role)
	end
	local pos_x, pos_y = PlanesTile.indexPixel(self.cur_role_grid_index)
	self.map_role:setPosition(pos_x, pos_y)
	self:updateRoleZOrder()
end

-- 更新角色的层级
function PlanesMapWindow:updateRoleZOrder(  )
	if not self.cur_role_grid_index then return end

	local grid_x, grid_y = PlanesTile.indexTile(self.cur_role_grid_index)
	self.map_role:setLocalZOrder((100-grid_y)*100 + grid_x + 1)
end

-- 移除角色形象
function PlanesMapWindow:removeMapRole(  )
	if self.map_role then
        self.map_role:clearTracks()
        self.map_role:removeFromParent()
        self.map_role = nil
    end
end

-- 点击格子
function PlanesMapWindow:onClickGridIconByIndex( index )
	local grid_object = self.grid_object_list[index]
	if not grid_object then return end

	if grid_object.grid_icon then
		local pos_x = grid_object.pos_x or 0
        local pos_y = grid_object.pos_y or 0
        grid_object.grid_icon:stopAllActions()
        grid_object.grid_icon:setPosition(pos_x, pos_y)
		local move_by_1 = cc.EaseBackOut:create(cc.MoveTo:create(0.1, cc.p(pos_x, pos_y+20)))
		local move_by_2 = cc.EaseBackOut:create(cc.MoveTo:create(0.1, cc.p(pos_x, pos_y)))
		local act_1 = cc.Spawn:create(move_by_1, cc.ScaleTo:create(0.1, 1.2))
		local act_2 = cc.Spawn:create(move_by_2, cc.ScaleTo:create(0.1, 0.9))
		grid_object.grid_icon:runAction(cc.Sequence:create(act_1, act_2, (cc.ScaleTo:create(0.05, 1.0))))
		local evt_item = self.evt_item_list[index]
		if evt_item then
			evt_item:showClickAni()
		end
		playButtonSound2()
	end

	-- 格子初始化完成才能点击
	if not self.init_grid_end then return end
	-- 点击当前所在的格子
	if self.cur_role_grid_index == index then return end
	-- 不可行走的或隐藏的格子
	if not grid_object.grid_data or grid_object.grid_data.is_hide == 1 then return end
	-- 格子没有事件、且配置了不可行走
	if not _model:checkIsHaveEvtByGridIndex(index) and grid_object.grid_data.is_walk == 0 then
		message(TI18N("目标点为不可行走区域，请选择其他目标点"))
		return
	end
	-- 根据事件状态判断事件不可行走，则不给点击
	if not _model:checkEvtCanWalkByGridIndex(index, true) then
		message(TI18N("目标点为不可行走区域，请选择其他目标点"))
		return
	end
	-- 移动过程中点击了一个格子，则角色继续移动到下一个目标格子后，停止动作
	if self.is_role_moving then
		self.target_grid_index = nil -- 清掉待触发的事件格子
		self.role_move_grid_cache = {} -- 清掉待行走的格子
		return
	end
	local start_grid_x, start_grid_y = PlanesTile.indexTile(self.cur_role_grid_index) 
	local start_pos = cc.p(start_grid_x, start_grid_y)
	local end_grid_x, end_grid_y = PlanesTile.indexTile(index) 
	local end_pos = cc.p(end_grid_x, end_grid_y)
	local astar_result = PlanesTile.astar(start_pos, end_pos, self.cur_block_cfg)

	self.role_move_grid_cache = {} -- 缓存待行走的格子列表
	while astar_result do
        local x = astar_result.x
		local y = astar_result.y
		local grid_index = PlanesTile.tileIndex(x, y)
		if grid_index ~= self.cur_role_grid_index then -- 当前所在的格子不用缓存
			_table_insert(self.role_move_grid_cache, 1, grid_index) -- A星计算出来的路线是终点排在第一位，于是这里逆序缓存
		end
        astar_result = astar_result.parent
	end

	-- 点击的格子有事件、且事件未完成，则需要走到事件前一格停下来（出生点除外，出生点一直是未完成）
	if _model:checkIsNeedStopPreGrid(index) then
		-- 这里缓存待触发的事件格子
		self.target_grid_index = _table_remove(self.role_move_grid_cache, #self.role_move_grid_cache)
	end

	-- 目标点特效
	if next(self.role_move_grid_cache) ~= nil then
		local target_index = self.role_move_grid_cache[#self.role_move_grid_cache]
		if target_index then
			local target_pos_x, target_pos_y = PlanesTile.indexPixel(target_index)
			self:handlerTargetEffect(true, target_pos_x, target_pos_y)
		end
	end
	self.stop_center_flag = false
	self:showMoveRoute()
	self:doNextRoleMove()
end

-- 创建路线特效显示
function PlanesMapWindow:showMoveRoute(  )
	if not self.role_move_grid_cache or next(self.role_move_grid_cache) == nil then return end
	local route_info = {}
	for i,grid_index in ipairs(self.role_move_grid_cache) do
		local info = {}
		info.dir = 1
		local pos_x, pos_y = PlanesTile.indexPixel(grid_index)
		local next_grid_index = self.role_move_grid_cache[i+1]
		if next_grid_index then
			local next_pos_x, next_pos_y = PlanesTile.indexPixel(next_grid_index)
			if pos_x < next_pos_x and pos_y < next_pos_y then -- 右上
				info.dir = 1
			elseif pos_x < next_pos_x and pos_y > next_pos_y then --右下
				info.dir = 2
			elseif pos_x > next_pos_x and pos_y > next_pos_y then --左下
				info.dir = 3
			elseif pos_x > next_pos_x and pos_y < next_pos_y then --左上
				info.dir = 4
			end
			info.pos_x = pos_x
			info.pos_y = pos_y
			info.grid_index = grid_index
			_table_insert(route_info, info)
		end
	end
	for k, object in pairs(self.route_effect_list) do
		if object.effect then
			object.effect:setVisible(false)
		end
	end
	for i, r_data in ipairs(route_info) do
		local object = self.route_effect_list[i]
		if not object or next(object) == nil then
			object = {}
			object.effect = createEffectSpine(Config.EffectData.data_effect_info[1505], cc.p(r_data.pos_x, r_data.pos_y), cc.p(0.5, 0.5), true, PlayerAction.action)
			self.evt_slayer:addChild(object.effect, 999)
			self.route_effect_list[i] = object
		else
			object.effect:setToSetupPose()
			object.effect:setPosition(r_data.pos_x, r_data.pos_y)
            object.effect:setAnimation(0, PlayerAction.action, true)
		end
		object.effect:setVisible(true)
		object.effect:setScale(1)
		if r_data.dir == 1 then
			object.effect:setScale(-1)
		elseif r_data.dir == 2 then
			object.effect:setScaleX(-1)
		elseif r_data.dir == 3 then
			object.effect:setScale(1)
		elseif r_data.dir == 4 then
			object.effect:setScaleY(-1)
		end
		object.grid_index = r_data.grid_index
	end
end

function PlanesMapWindow:handlerTargetEffect(status, pos_x, pos_y)
	if status == true then
        if not tolua.isnull(self.evt_slayer) and self.target_effect == nil then
            self.target_effect = createEffectSpine(Config.EffectData.data_effect_info[1504], cc.p(pos_x, pos_y), cc.p(0.5, 0.5), true, PlayerAction.action_2)
            self.evt_slayer:addChild(self.target_effect, 99999)
        elseif self.target_effect then
			self.target_effect:setToSetupPose()
			self.target_effect:setPosition(pos_x, pos_y)
            self.target_effect:setAnimation(0, PlayerAction.action_2, true)
        end
    else
        if self.target_effect then
            self.target_effect:clearTracks()
            self.target_effect:removeFromParent()
            self.target_effect = nil
        end
    end
end

-- 显示地块裂开特效
function PlanesMapWindow:showBreakEffect( data_list )
	if not data_list or next(data_list) == nil then return end

	for k,index in pairs(data_list) do
		-- 隐藏事件图标和格子
		local evt_item = self.evt_item_list[index]
		if evt_item then
			evt_item:setVisible(false)
		end
		local object = self.grid_object_list[index]
		if object and object.grid_icon then
			object.grid_icon:setVisible(false)
		end
		
		-- 播放裂开特效
		local break_effect = self.break_effect_list[k]
		if not break_effect then
			break_effect = createEffectSpine(Config.EffectData.data_effect_info[1705], cc.p(0, 0), cc.p(0.5, 0.75), false, PlayerAction.action, handler(self, self.onBreakAniEnd))
			self.grid_slayer:addChild(break_effect)
			self.break_effect_list[k] = break_effect
		else
			break_effect:setVisible(true)
			break_effect:setToSetupPose()
			break_effect:setAnimation(0, PlayerAction.action, false)
		end
		local pos_x, pos_y = PlanesTile.indexPixel(index)
		break_effect:setPosition(pos_x, pos_y)
		-- 设置层级，y越小层级越高，x越大层级越高
		local grid_x, grid_y = PlanesTile.indexTile(index)
		break_effect:setLocalZOrder((100-grid_y)*100 + grid_x)
	end
end

function PlanesMapWindow:onBreakAniEnd(  )
	for k,break_effect in pairs(self.break_effect_list) do
		break_effect:setVisible(false)
	end
end

-- 锁屏
function PlanesMapWindow:isLockPlanesMapScreen( flag )
	if flag == true then
		if not self.lock_mask then
			local con_size = self.ui_container:getContentSize()
			self.lock_mask = ccui.Layout:create()
			self.lock_mask:setContentSize(SCREEN_WIDTH, SCREEN_HEIGHT)
			self.lock_mask:setAnchorPoint(cc.p(0.5, 0.5))
			self.lock_mask:setScale(display.getMaxScale())
			self.lock_mask:setPosition(con_size.width*0.5, con_size.height*0.5)
			self.lock_mask:setTouchEnabled(true)
			self.lock_mask:setSwallowTouches(true)
			self.ui_container:addChild(self.lock_mask, 10)
		end
		self.lock_mask:setVisible(true)
	elseif self.lock_mask then
		self.lock_mask:setVisible(false)
	end
end

-- 一格一格去移动角色
function PlanesMapWindow:doNextRoleMove(  )
	local move_grid_index = _table_remove(self.role_move_grid_cache, 1)
	if not move_grid_index then -- 移动到最后一格了
		self:doRoleStopMove()
		return
	end

	if not self.stop_center_flag then
		self:moveMapToRoleCenter() -- 角色移动到屏幕中间
	end
	_controller:sender23103(move_grid_index) -- 通知服务端到达某一格子
	self:moveRoleByGrid(move_grid_index)
end

-- 移动角色
function PlanesMapWindow:moveRoleByGrid( grid_index )
	if not self.map_role then return end

	local move_grid_x, move_grid_y = PlanesTile.indexTile(grid_index)

	self.cur_role_grid_index = grid_index
	self.is_role_moving = true

	self:openMapMoveTimer(false)
	
	local cur_pos_x, cur_pos_y = self.map_role:getPosition()
	local new_pos_x, new_pos_y = PlanesTile.indexPixel(grid_index)
	-- 记录一下角色移动的目标格子坐标
	self.move_target_pos_x = new_pos_x
	self.move_target_pos_y = new_pos_y

	-- 角色转向
	if new_pos_x > cur_pos_x then
		self.map_role:setScaleX(0.4)
	else
		self.map_role:setScaleX(-0.4)
	end

	-- 路线动态隐藏
	for k, object in pairs(self.route_effect_list) do
		if object.grid_index == grid_index then
			if object.effect then
				object.effect:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function (  )
					object.effect:setVisible(false)
				end)))
			end
			break
		end
	end

	-- 角色移动
	local distance = math.sqrt(math.pow(new_pos_x-cur_pos_x, 2)+math.pow(new_pos_y-cur_pos_y, 2))
	local time = distance/PlanesConst.Move_Speed
	if not self.cur_role_action or self.cur_role_action ~= PlayerAction.move then
		self.cur_role_action = PlayerAction.move
		self.map_role:setToSetupPose()
		self.map_role:setAnimation(0, PlayerAction.move, true)
	end
	self.map_role:runAction(cc.Sequence:create(cc.MoveTo:create(time, cc.p(new_pos_x, new_pos_y)), cc.CallFunc:create(function (  )
		self:doNextRoleMove()
		self:checkShowRoundGrid(self.cur_role_grid_index)
	end)))
	self:updateRoleZOrder() -- 更新角色层级

	-- 地图移动
	if not self.stop_center_flag then
		local map_cur_pos_x, map_cur_pos_y = self.map_container:getPosition()
		local map_new_pos_x = map_cur_pos_x - (new_pos_x - cur_pos_x)
		local map_new_pos_y = map_cur_pos_y - (new_pos_y - cur_pos_y)

		self.map_move_state = self:checkMapIsCanMove()
		if self.map_move_state ~= 0 then -- 棋盘可以移动
			map_new_pos_x, map_new_pos_y = self:checkMapSafePos( map_new_pos_x, map_new_pos_y )
			if self.map_move_state == 1 then -- y轴不能移动
				map_new_pos_y = map_cur_pos_y
				self:openMapMoveTimer(true)
			elseif self.map_move_state == 2 then -- x轴不能移动
				map_new_pos_x = map_cur_pos_x
				self:openMapMoveTimer(true)
			end
			local map_dis = math.sqrt(math.pow(map_new_pos_x-map_cur_pos_x, 2)+math.pow(map_new_pos_y-map_cur_pos_y, 2))
			local map_time = map_dis/PlanesConst.Move_Speed
			self.map_container:runAction(cc.MoveTo:create(map_time, cc.p(map_new_pos_x, map_new_pos_y)))
		end

		-- 只要棋盘不是可以完全自由移动，就需要实时判断
		if self.map_move_state ~= 3 then
			self:openMapMoveTimer(true)
		end
	end
end

-- 移动地图使得角色居中
function PlanesMapWindow:moveMapToRoleCenter(  )
	local map_pos_x, map_pos_y = self:getMapPosOfRoleCenter()
	self.map_container:runAction(cc.MoveTo:create(0.3, cc.p(map_pos_x, map_pos_y)))
end

-- 获取角色居中时地图的坐标
function PlanesMapWindow:getMapPosOfRoleCenter(  )
	local pos_x = 0
	local pos_y = 0
	if self.map_role then
		local role_pos_x, role_pos_y = self.map_role:getPosition()
		if role_pos_x <= SCREEN_WIDTH*0.5 then
			pos_x = 0
		else
			pos_x = SCREEN_WIDTH*0.5 - role_pos_x
		end
		if role_pos_y <= display.height*0.5 then
			pos_y = 0
		else
			pos_y = display.height*0.5 - role_pos_y
		end
	end
	return self:checkMapSafePos(pos_x, pos_y)
end

-- 地图是否可以移动 0：不能移动 1：x轴可以移动 2：y轴可以移动 3：可以随意移动
function PlanesMapWindow:checkMapIsCanMove(  )
	local move_state = 0
	if not self.map_role then return move_state end

	local cur_pos_x, cur_pos_y = self.map_role:getPosition()

	if cur_pos_x >= SCREEN_WIDTH*0.5 and cur_pos_x <= (self.cur_map_width-SCREEN_WIDTH*0.5)then
		move_state = 1
	end
	if cur_pos_y >= display.height*0.5 and cur_pos_y <= (self.cur_map_height-display.height*0.5) then
		if move_state > 0 then
			move_state = 3
		else
			move_state = 2
		end
	end
	return move_state
end

-- 检测地图移动的定时器
function PlanesMapWindow:openMapMoveTimer( status )
	if status == true then
		if not self.map_move_timer then
            self.map_move_timer = GlobalTimeTicket:getInstance():add(function()
				local map_move_state = self:checkMapIsCanMove()
            	if map_move_state ~= self.map_move_state then
            		self.map_move_state = map_move_state
            		if self.move_target_pos_x and self.move_target_pos_y then
            			local cur_pos_x, cur_pos_y = self.map_role:getPosition()

						local map_cur_pos_x, map_cur_pos_y = self.map_container:getPosition()
						local map_new_pos_x = map_cur_pos_x - (self.move_target_pos_x - cur_pos_x)
						local map_new_pos_y = map_cur_pos_y - (self.move_target_pos_y - cur_pos_y)
						-- 棋盘移动
						map_new_pos_x, map_new_pos_y = self:checkMapSafePos( map_new_pos_x, map_new_pos_y )
						if map_move_state == 1 then
							map_new_pos_y = map_cur_pos_y
						elseif map_move_state == 2 then
							map_new_pos_x = map_cur_pos_x
						end
						local map_dis = math.sqrt(math.pow(map_new_pos_x-map_cur_pos_x, 2)+math.pow(map_new_pos_y-map_cur_pos_y, 2))
						local map_time = map_dis/PlanesConst.Move_Speed
						self.map_container:runAction(cc.MoveTo:create(map_time, cc.p(map_new_pos_x, map_new_pos_y)))
            		end
            	end
            end, 0.1)
        end
	else
		if self.map_move_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.map_move_timer)
            self.map_move_timer = nil
        end
	end
end

-- 角色停止移动
function PlanesMapWindow:doRoleStopMove(  )
	self:openMapMoveTimer(false)
	self:handlerTargetEffect(false)
	self.map_role:stopAllActions()
	self.map_role:setToSetupPose()
	self.map_role:setAnimation(0, PlayerAction.idle, true)
	self.cur_role_action = PlayerAction.idle
	self.is_role_moving = false
	self.role_move_grid_cache = {}
	for k, object in pairs(self.route_effect_list) do
		if object.effect then
			object.effect:stopAllActions()
			object.effect:setVisible(false)
		end
	end

	self:checkProceedGridEvt()
end

-- 检测是否有事件需要触发
function PlanesMapWindow:checkProceedGridEvt(  )
	if self.target_grid_index then
		local evt_vo = _model:getPlanesEvtVoByGridIndex(self.target_grid_index)
		if evt_vo and evt_vo.config and evt_vo.status == PlanesConst.Evt_State.Doing then
			_controller:onHandlePlanesEvtById(evt_vo.config.type, evt_vo.index)
		end
		self.target_grid_index = nil
	end
end

-- 播放云层特效
function PlanesMapWindow:playCloudEffect( status )
    if status == true then
        if not tolua.isnull(self.ui_container) and self.cloud_effect == nil then
            self.cloud_effect = createEffectSpine(Config.EffectData.data_effect_info[157], cc.p(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5), cc.p(0.5, 0.5), false, PlayerAction.action_1)
            self.cloud_effect:setScale(display.getMaxScale())
            self.ui_container:addChild(self.cloud_effect, 99)
        elseif self.cloud_effect then
            self.cloud_effect:setToSetupPose()
            self.cloud_effect:setAnimation(0, PlayerAction.action_1, false)
        end
    else
        if self.cloud_effect then
            self.cloud_effect:clearTracks()
            self.cloud_effect:removeFromParent()
            self.cloud_effect = nil
        end
    end
end

-- 播放buff进背包的效果
function PlanesMapWindow:showBuffItemMoveAni( buff_id, world_pos )
	if not buff_id or not world_pos then return end
	local buff_cfg = Config.SecretDunData.data_buff[buff_id]
	if not buff_cfg then return end

	if self.move_buff_item then
		self.move_buff_item:DeleteMe()
		self.move_buff_item = nil
	end

	self.move_buff_item = PlanesBuffItem.new()
	self.move_buff_item:setAnchorPoint(cc.p(0.5, 0.5))
	self.move_buff_item:setData(buff_cfg)
	local local_pos = self.ui_container:convertToNodeSpace(world_pos)
	local item_size = self.move_buff_item:getContentSize()
	self.move_buff_item:setPosition(cc.p(local_pos.x+item_size.width*0.5, local_pos.y+item_size.height*0.5))
	self.ui_container:addChild(self.move_buff_item)

	local target_pos_x, target_pos_y = self.buff_btn:getPosition()
	local move_act = cc.MoveTo:create(0.7, cc.p(target_pos_x, target_pos_y))
	local rotate_act = cc.RotateTo:create(0.4, -30)
	local scale_act = cc.ScaleTo:create(0.7, 0.2)
	local function call_back(  )
		self.move_buff_item:DeleteMe()
		self.move_buff_item = nil
	end
	self.move_buff_item:runAction(cc.Sequence:create(cc.Spawn:create(move_act, rotate_act, scale_act), cc.CallFunc:create(call_back)))
end

function PlanesMapWindow:close_callback( )
	for k, object in pairs(self.route_effect_list) do
		if object.effect then
			object.effect:stopAllActions()
			object.effect:clearTracks()
            object.effect:removeFromParent()
            object.effect = nil
		end
	end
	for k,effect in pairs(self.break_effect_list) do
		effect:clearTracks()
		effect:removeFromParent()
		effect = nil
	end
	self:openMapMoveTimer(false)
	self:playCloudEffect(false)
	self:handlerTargetEffect(false)
	if self.move_buff_item then
		self.move_buff_item:DeleteMe()
		self.move_buff_item = nil
	end
	if self.grid_icon_load then
		self.grid_icon_load:DeleteMe()
		self.grid_icon_load = nil
	end
	if self.evt_icon_load then
		self.evt_icon_load:DeleteMe()
		self.evt_icon_load = nil
	end
	if self.bg_img_load then
		self.bg_img_load:DeleteMe()
		self.bg_img_load = nil
	end
	for k,item in pairs(self.evt_item_list) do
		item:DeleteMe()
		item = nil
	end
	self:removeMapRole()
	local music_name = RoleController:getInstance():getModel().city_music_name or "s_002"
	AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.SCENE, music_name, true) -- 恢复主城背景音乐播放
	MainuiController:getInstance():setIsShowMainUIBottom(true) -- 隐藏底部UI
	_controller:openPlanesMapWindow(false)
end