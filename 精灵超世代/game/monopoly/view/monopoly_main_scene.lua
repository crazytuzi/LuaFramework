--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-10-11 09:48:31
-- @description    : 
		-- 大富翁主场景
---------------------------------
local _controller = MonopolyController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert
local _table_remove = table.remove
local _table_sort = table.sort

MonopolyMainScene = MonopolyMainScene or BaseClass(BaseView)

function MonopolyMainScene:__init()
	self.is_full_screen = true
    self.win_type = WinType.Full
	self.layout_name = "monopoly/monopoly_main_window"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("monopoly", "monopolyboard"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("monopoly", "dim_bg", true), type = ResourcesType.single},
	}

    self:initConfig()
end

function MonopolyMainScene:initConfig(  )
	self.is_proceed_evt = false  -- 当前是否有事件正在进行中（事件进行中不能摇骰子）
	self.is_role_moving = false  -- 当前角色是否正在移动中
	self.cur_role_grid_x = 0 -- 当前角色格子坐标x
	self.cur_role_grid_y = 0 -- 当前角色格子坐标y
	self.role_cur_board_index = 1 -- 当前角色在第几个位置(棋盘格子编号)
	self.role_move_grid_cache = {} -- 待移动的格子坐标
	self.all_grid_item_list = {} -- 所有格子item
	self.board_grid_data = {} 	-- 棋盘格子列表数据
	self.progress_boss_list = {} -- 探索度宝可梦头像显示
	self.route_effect_list = {}  -- 路线特效列表
	self.buff_icon_list = {} 	-- 大富翁buff图标

	-- 棋盘的最大、最小坐标
	self.board_min_pos_x = SCREEN_WIDTH - MonopolyConst.Board_Width
	self.board_max_pos_x = 0
	self.board_min_pos_y = display.height - MonopolyConst.Board_Height
	self.board_max_pos_y = 0

	-- 南瓜机和秘籍的配置
	self.dice_item_bid = 0
	self.dice_item_name = ""
	local dice_cfg = Config.MonopolyMapsData.data_const["monopoly_dice_id"]
	if dice_cfg then
		self.dice_item_bid = dice_cfg.val
	end
	local dice_item_cfg = Config.ItemData.data_get_data(self.dice_item_bid)
	if dice_item_cfg then
		self.dice_item_name = dice_item_cfg.name
	end

	self.secret_item_bid = 0
	self.secret_item_name = 0
	local secret_cfg = Config.MonopolyMapsData.data_const["monopoly_secret_id"]
	if secret_cfg then
		self.secret_item_bid = secret_cfg.val
	end
	local secret_item_cfg = Config.ItemData.data_get_data(self.secret_item_bid)
	if secret_item_cfg then
		self.secret_item_name = secret_item_cfg.name
	end

	self.role_vo = RoleController:getInstance():getRoleVo()

	MonopolyTile.init(MonopolyConst.Tile_Width*0.5, MonopolyConst.Tile_Height*0.5, MonopolyConst.Board_Width, MonopolyConst.Board_Height)
end

function MonopolyMainScene:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	self.background:loadTexture(PathTool.getPlistImgForDownLoad("monopoly", "dim_bg", true), LOADTEXT_TYPE)
	self.background:setScale(display.getMaxScale())

	-- 触摸层
	self.touch_slayer = self.root_wnd:getChildByName("touch_slayer")
	self.touch_slayer:setScale(display.getMaxScale())

	-- 棋盘层
	self.board_container = self.root_wnd:getChildByName("board_container")
	self.board_slayer = self.board_container:getChildByName("board_slayer")
	self.role_slayer = self.board_container:getChildByName("role_slayer")

	-- ui层
	self.ui_container = self.root_wnd:getChildByName("ui_container")
	local top_panel = self.ui_container:getChildByName("top_panel")
	self.top_panel = top_panel
	top_panel:getChildByName("probe_title"):setString(TI18N("探索值"))
	self.btn_rule = top_panel:getChildByName("btn_rule")
	self.probe_progress = top_panel:getChildByName("progress") -- 探索值进度
	self.probe_progress:setScale9Enabled(true)
	self.probe_progress:setPercent(0)
	self.probe_txt = top_panel:getChildByName("probe_txt")
	self.atk_txt = top_panel:getChildByName("atk_txt")
	self.hp_txt = top_panel:getChildByName("hp_txt")
	self.candy_txt = top_panel:getChildByName("candy_txt")
	self.map_name_txt = top_panel:getChildByName("map_name_txt")
	self.candy_sp = top_panel:getChildByName("candy_sp")
	self.candy_sp:setScale(0.5)
	self.buff_panel = self.ui_container:getChildByName("buff_panel")
	
	self.gold_item_bid = 0
	self.gold_item_name = ""
	local gold_cfg = Config.MonopolyMapsData.data_const["monopoly_gold_id"]
	if gold_cfg then
		self.gold_item_bid = gold_cfg.val
	end
	local gold_item_cfg = Config.ItemData.data_get_data(self.gold_item_bid)
	if gold_item_cfg then
		self.gold_item_name = gold_item_cfg.name
		local item_res = PathTool.getItemRes(gold_item_cfg.icon)
        loadSpriteTexture(self.candy_sp, item_res, LOADTEXT_TYPE)
	end

	local bottom_panel = self.ui_container:getChildByName("bottom_panel")
	self.close_btn = bottom_panel:getChildByName("close_btn")
	self.pumpkin_btn = bottom_panel:getChildByName("pumpkin_btn")
	self.pumpkin_btn_label = self.pumpkin_btn:getChildByName("label")
	self.pumpkin_btn_label:setString(self.dice_item_name)
	self.book_btn = bottom_panel:getChildByName("book_btn")
	self.book_btn_label = self.book_btn:getChildByName("label")
	self.book_btn_label:setString(self.secret_item_name)
	local btn_size = self.book_btn:getContentSize()
	self.pumpkin_num = CommonNum.new(18, self.pumpkin_btn, 0, -3)
	self.pumpkin_num:setPosition(btn_size.width-15, btn_size.height)
	self.secret_num = CommonNum.new(18, self.book_btn, 0, -3)
	self.secret_num:setPosition(btn_size.width-15, btn_size.height)

	self:updateItemNum()

	--  适配
	local top_off = display.getTop(main_container)
	local bottom_off = display.getBottom(main_container)
	top_panel:setPositionY(top_off-158)
	self.buff_panel:setPositionY(top_off-215)
	bottom_panel:setPositionY(bottom_off)
end

function MonopolyMainScene:openRootWnd( id )
	self.cur_monopoly_id = id
	_model:setCurMonopolyMapId(id)
	_controller:sender27401(id)
	_controller:sender27504()
	_controller:sender27500(id)
	_controller:sender27408(id)
end

function MonopolyMainScene:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
	-- 南瓜机
	registerButtonEventListener(self.pumpkin_btn, handler(self, self.onClickPumpkinBtn), true, nil, nil, nil, 0.5)
	-- 秘籍
	registerButtonEventListener(self.book_btn, handler(self, self.onClickBookBtn), true, nil, nil, nil, 0.5)
	-- 规则
	registerButtonEventListener(self.btn_rule, handler(self, self.onClickRuleBtn), true)

	-- 移动场景
	self.touch_slayer:addTouchEventListener(function ( sender, event_type )
    	if self.is_role_moving then return end -- 行走过程中等，不允许移动
    	if event_type == ccui.TouchEventType.began then
    		self.last_pos = sender:getTouchBeganPosition()       
    	elseif event_type == ccui.TouchEventType.moved then
    		local touch_move_pos = sender:getTouchMovePosition()
    		if self.last_pos then
    			local offset_x = touch_move_pos.x - self.last_pos.x
    			local offset_y = touch_move_pos.y - self.last_pos.y
    			self.last_pos = touch_move_pos
    			self:onTouchMoveBoard(offset_x, offset_y)
    		end
    	end
	end)
	
	-- 场景数据
	self:addGlobalEvent(MonopolyEvent.Update_Monopoly_Map_Data_Event, function ()
		self:setData()
	end)

	-- 扔骰子结果
	self:addGlobalEvent(MonopolyEvent.Get_Dice_Result_Event, function (num, is_move)
		-- 出结果的时候先将数据更新（探索值、当前角色位置、当前位置触发的事件）,角色移动完毕后会触发事件
		if self.cur_monopoly_id then
			self.map_data = _model:getMonopolyMapDataById(self.cur_monopoly_id)
		end
		if is_move and num and num > 0 then
			self:MoveRoleByNum(num)
		end
	end)

	-- 当前事件类型变更
	self:addGlobalEvent(MonopolyEvent.Update_Now_Evt_Type_Event, function (id)
		if self.cur_monopoly_id and self.cur_monopoly_id == id then
			self.map_data = _model:getMonopolyMapDataById(self.cur_monopoly_id)
			self.is_proceed_evt = false
		end
	end)

	-- 角色移动
	self:addGlobalEvent(MonopolyEvent.Get_Role_Move_Event, function (num)
		self:MoveRoleByNum(num)
	end)

	-- 道具数量变化
	if not self.role_assets_event and self.role_vo then
        self.role_assets_event =  self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ACTION_ASSETS, function(id, value) 
            if id and (id == self.dice_item_bid or id == self.secret_item_bid) and self.role_vo then 
				self:updateItemNum()
			elseif id and id == self.gold_item_bid and self.role_vo then
				self:updateBuffData()
            end
        end)
	end
	
	-- 公会boss的buff数据
    self:addGlobalEvent(MonopolyEvent.Update_Buff_Data_Event, function ()
        self:updateBuffData()
	end)

	-- 公会boss击杀状态
	self:addGlobalEvent(MonopolyEvent.Get_Boss_Data_Event, function (data)
		if data and data.id == self.cur_monopoly_id then
			self:updateBossIconList(data.boss_list)
		end
	end)
	
	-- 探索度更新
	self:addGlobalEvent(MonopolyEvent.Update_Guild_Dev_Val_Event, function ()
		self:updateBossProgress()
	end)

	-- 大富翁buff数据更新
	self:addGlobalEvent(MonopolyEvent.Update_Monopoly_Buff_Event, function (data)
		if data.id == self.cur_monopoly_id then
			self:updateMonopolyBuffs(data.buffs)
		end
	end)

	-- 显示tips
	self:addGlobalEvent(MonopolyEvent.Get_Show_Tips_Event, function ()
		self:checkShowTips()
	end)
end

function MonopolyMainScene:onClickRuleBtn()
	_controller:openMonopolyItemShowWindow(true)
end

-- 道具数量
function MonopolyMainScene:updateItemNum()
	local have_num = self.role_vo:getActionAssetsNumByBid(self.dice_item_bid)
	self.pumpkin_num:setNum(have_num)
	have_num = self.role_vo:getActionAssetsNumByBid(self.secret_item_bid)
	self.secret_num:setNum(have_num)
end

-- buff数据
function MonopolyMainScene:updateBuffData()
    local buff_data = _model:getMonopolyBuffData()
    local atk_buff_val = 0
    local hp_buff_val = 0
    for k,v in pairs(buff_data) do
        if v.buff_id == 1 then
            atk_buff_val = v.val
        elseif v.buff_id == 2 then
            hp_buff_val = v.val
        end
    end
    self.atk_txt:setString(_string_format(TI18N("攻击+%d"), atk_buff_val))
    self.hp_txt:setString(_string_format(TI18N("血量+%d"), hp_buff_val))
    
    local have_num = self.role_vo:getActionAssetsNumByBid(self.gold_item_bid)
    self.candy_txt:setString(_string_format(TI18N("%s:%d"), self.gold_item_name, have_num))
end

function MonopolyMainScene:onClickPumpkinBtn()
	if self.is_proceed_evt then
		message(TI18N("当前有未完成的事件"))
		return
	end
	if self.is_role_moving then
		message(TI18N("角色正在行走中"))
		return
	end
	if not self.role_vo then return end
	local left_num = self.role_vo:getActionAssetsNumByBid(self.dice_item_bid)
	if left_num <= 0 then
		message(_string_format(TI18N("没有%s啦，请去活动中获取更多~"), self.dice_item_name))
	else
		_controller:openMonopolyPumpkinWindow(true)
	end
end

function MonopolyMainScene:onClickBookBtn()
	if self.is_proceed_evt then
		message(TI18N("当前有未完成的事件"))
		return
	end
	if self.is_role_moving then
		message(TI18N("角色正在行走中"))
		return
	end
	if not self.role_vo then return end
	local left_num = self.role_vo:getActionAssetsNumByBid(self.secret_item_bid)
	if left_num <= 0 then
		message(_string_format(TI18N("没有%s啦，请去活动中获取更多~"), self.secret_item_name))
	else
		_controller:openMonopolyChoseStepWindow(true)
	end
end

function MonopolyMainScene:onClickCloseBtn(  )
	_controller:openMonopolyMianScene(false)
end

-- 创建棋盘格子
function MonopolyMainScene:updateBoardGridList()
	for k, item in pairs(self.all_grid_item_list) do
		item:setVisible(false)
	end

	local num = #self.board_grid_data
	for i, grid_vo in pairs(self.board_grid_data) do
		delayRun(self.board_slayer, 1/display.DEFAULT_FPS, function ()
			local item = self.all_grid_item_list[i]
			if not item then
				item = MonopolyGridItem.new()
				self.board_slayer:addChild(item)
				self.all_grid_item_list[i] = item
			end
			item:setVisible(true)
			item:setData(grid_vo)
			if i == num then
				self:updateGridListZorder()
			end
		end)
	end
end

function MonopolyMainScene:onTouchMoveBoard( offset_x, offset_y )
	if not self.board_container then return end

	local pos_x, pos_y = self.board_container:getPosition()
	local new_pos_x = pos_x + offset_x
	local new_pos_y = pos_y + offset_y
	new_pos_x, new_pos_y = self:checkBoardPos(new_pos_x, new_pos_y)
	self.board_container:setPosition(cc.p(new_pos_x, new_pos_y))
end

-- 检测棋盘的坐标是否超出边界
function MonopolyMainScene:checkBoardPos( pos_x, pos_y )
	if pos_x > self.board_max_pos_x then
		pos_x = self.board_max_pos_x
	elseif pos_x < self.board_min_pos_x then
		pos_x = self.board_min_pos_x
	end
	if pos_y > self.board_max_pos_y then
		pos_y = self.board_max_pos_y
	elseif pos_y < self.board_min_pos_y then
		pos_y = self.board_min_pos_y
	end
	return pos_x, pos_y
end

-- 棋盘背景
function MonopolyMainScene:updateBoardBgById( id )
	if not self.cur_board_bg_id or self.cur_board_bg_id ~= id then
		self.cur_board_bg_id = id

		if not self.board_bg_1 then
            self.board_bg_1 = createSprite(nil, 932, MonopolyConst.Board_Height, self.board_slayer, cc.p(0, 1), LOADTEXT_TYPE)
		end
		if not self.board_bg_2 then
            self.board_bg_2 = createSprite(nil, 0, MonopolyConst.Board_Height*0.5-28, self.board_slayer, cc.p(0, 0.5), LOADTEXT_TYPE)
		end
		if not self.board_bg_3 then
            self.board_bg_3 = createSprite(nil, 911, 0, self.board_slayer, cc.p(0, 0), LOADTEXT_TYPE)
		end
		if not self.board_bg_4 then
            self.board_bg_4 = createSprite(nil, MonopolyConst.Board_Width, MonopolyConst.Board_Height*0.5-20, self.board_slayer, cc.p(1, 0.5), LOADTEXT_TYPE)
        end

		local bg_res_list = {}
		for i = 1, 4 do
			local res_path = PathTool.getPlistImgForDownLoad(_string_format("monopoly/background/%d", self.cur_board_bg_id), i)
			_table_insert(bg_res_list, {path = res_path, type = ResourcesType.single})
		end
		if self.board_bg_load then
			self.board_bg_load:DeleteMe()
			self.board_bg_load = nil
		end
		self.board_bg_load = ResourcesLoad.New(true)
		self.board_bg_load:addAllList(bg_res_list, function()
			loadSpriteTexture(self.board_bg_1, _string_format("resource/monopoly/background/%d/%d.png", self.cur_board_bg_id, 1), LOADTEXT_TYPE)
			loadSpriteTexture(self.board_bg_2, _string_format("resource/monopoly/background/%d/%d.png", self.cur_board_bg_id, 2), LOADTEXT_TYPE)
			loadSpriteTexture(self.board_bg_3, _string_format("resource/monopoly/background/%d/%d.png", self.cur_board_bg_id, 3), LOADTEXT_TYPE)
			loadSpriteTexture(self.board_bg_4, _string_format("resource/monopoly/background/%d/%d.png", self.cur_board_bg_id, 4), LOADTEXT_TYPE)
		end)
	end
end

function MonopolyMainScene:removeBoardRole(  )
	if self.board_role then
        self.board_role:clearTracks()
        self.board_role:removeFromParent()
        self.board_role = nil
    end
end

-- 显示行走路线
function MonopolyMainScene:showMoveRoute(num)
	local target_index = self.role_cur_board_index + num
	local target_grid_vo = self.board_grid_data[target_index]
	if target_grid_vo and target_grid_vo.grid_index then
		local pos_x, pos_y = MonopolyTile.indexPixel(target_grid_vo.grid_index)
		self:handlerTargetEffect(true, pos_x, pos_y+6)
	end

	local route_info = {}
	for i = 1, num-1 do
		local index = self.role_cur_board_index + i
		if index <= #self.board_grid_data then
			local grid_vo = self.board_grid_data[index]
			if grid_vo and grid_vo.grid_index then
				local info = {}
				info.dir = 1
				local pos_x, pos_y = MonopolyTile.indexPixel(grid_vo.grid_index)
				local next_grid_vo = self.board_grid_data[index+1]
				if next_grid_vo then
					local next_pos_x, next_pos_y = MonopolyTile.indexPixel(next_grid_vo.grid_index)
					if pos_x < next_pos_x and pos_y < next_pos_y then -- 右上
						info.dir = 1
					elseif pos_x < next_pos_x and pos_y > next_pos_y then --右下
						info.dir = 2
					elseif pos_x > next_pos_x and pos_y > next_pos_y then --左下
						info.dir = 3
					elseif pos_x > next_pos_x and pos_y < next_pos_y then --左上
						info.dir = 4
					end
				end
				info.pos_x = pos_x + 4
				info.pos_y = pos_y + 10
				info.grid_index = grid_vo.grid_index
				_table_insert(route_info, info)
			end
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
			self.board_slayer:addChild(object.effect, 99)
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

function MonopolyMainScene:handlerTargetEffect(status, pos_x, pos_y)
	if status == true then
        if not tolua.isnull(self.board_slayer) and self.target_effect == nil then
            self.target_effect = createEffectSpine(Config.EffectData.data_effect_info[1504], cc.p(pos_x, pos_y), cc.p(0.5, 0.5), true, PlayerAction.action_2)
            self.board_slayer:addChild(self.target_effect, 99)
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

-- 根据摇到的数字进行移动
function MonopolyMainScene:MoveRoleByNum(num)
	if self.is_role_moving then return end

	-- 创建行走路线
	self:showMoveRoute(num)

	local function startMoveRole()
		self.is_role_moving = false
		self.move_tips_bg:setVisible(false)
		for i = 1, num do
			local index = self.role_cur_board_index + i
			if index <= #self.board_grid_data then
				local grid_vo = self.board_grid_data[index]
				if grid_vo and grid_vo.grid_index then
					local grid_x, grid_y = MonopolyTile.indexTile(grid_vo.grid_index)
					self:moveRoleByGrid( grid_x, grid_y )
				end
			end
		end
		
		if (self.role_cur_board_index + num) > #self.board_grid_data then
			self.role_cur_board_index = #self.board_grid_data
		else
			self.role_cur_board_index = self.role_cur_board_index + num
		end
	end

	if not self.move_tips_bg then
		local con_size = self.ui_container:getContentSize()
		self.move_tips_bg = createImage(self.ui_container, PathTool.getResFrame("monopoly", "monopolyboard_1017", false, "monopolyboard"), con_size.width*0.5, con_size.height*0.5+100, cc.p(0.5, 0.5), true, 99, true)
		self.move_tips_bg:setContentSize(cc.size(720, 108))
	end
	if not self.move_num then
		self.move_num = CommonNum.new(32, self.move_tips_bg, 0)
		self.move_num:setPosition(360, 82)
	end
	local num_str = "g" .. num .. "s"
	self.move_num:setNum(num_str)
	self.move_tips_bg:setVisible(true)
	self.is_role_moving = true
	if self.move_tips_sound ~= nil then
        AudioManager:getInstance():removeEffectByData(self.move_tips_sound)
    end
    self.move_tips_sound = AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON, 'c_arenasettlement', false)
	self.move_tips_bg:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(startMoveRole)))
end

-- 角色移动
function MonopolyMainScene:moveRoleByGrid( grid_x, grid_y, force )
	if not self.board_role then return end

	if grid_x and grid_y then
		_table_insert(self.role_move_grid_cache, {grid_x, grid_y})
	end
	if self.is_role_moving == true and not force then return end

	local target_grid_info = _table_remove(self.role_move_grid_cache, 1)
	if not target_grid_info or next(target_grid_info) == nil then
		self:doRoleStopMove()
		return
	end
	local target_grid_x = target_grid_info[1]
	local target_grid_y = target_grid_info[2]

	self:openBoardMoveTimer(false)
	-- 每次开始走的时候要恢复到中心位置（但连续走动时不需要）
	if grid_x and grid_y then
		self:moveBoardToRoleCenter()
	end
	self.is_role_moving = true

	self.cur_role_grid_x, self.cur_role_grid_y = target_grid_x, target_grid_y
	local cur_pos_x, cur_pos_y = self.board_role:getPosition()
	local new_pos_x, new_pos_y = MonopolyTile.toPixel(target_grid_x, target_grid_y)
	-- 记录一下角色移动的目标格子坐标
	self.move_target_pos_x = new_pos_x
	self.move_target_pos_y = new_pos_y

	if new_pos_x > cur_pos_x then
		self.board_role:setScaleX(0.65)
	else
		self.board_role:setScaleX(-0.65)
	end

	-- 角色移动
	local distance = math.sqrt(math.pow(new_pos_x-cur_pos_x, 2)+math.pow(new_pos_y-cur_pos_y, 2))
	local time = distance/MonopolyConst.Move_Speed
	if not self.cur_role_action or self.cur_role_action ~= PlayerAction.move then
		self.cur_role_action = PlayerAction.move
		self.board_role:setToSetupPose()
		self.board_role:setAnimation(0, PlayerAction.move, true)
	end
	self.board_role:setTimeScale(1.4)
	self.board_role:runAction(cc.Sequence:create(cc.MoveTo:create(time, cc.p(new_pos_x, new_pos_y)), cc.CallFunc:create(function (  )
		if next(self.role_move_grid_cache) == nil then
			self:doRoleStopMove()
		else
			local cur_grid_index = MonopolyTile.tileIndex(self.cur_role_grid_x, self.cur_role_grid_y) 
			for k, object in pairs(self.route_effect_list) do
				if object.grid_index == cur_grid_index then
					if object.effect then
						object.effect:setVisible(false)
					end
					break
				end
			end
			self:moveRoleByGrid(nil, nil, true)
		end
	end)))

	-- 棋盘移动
	local board_cur_pos_x, board_cur_pos_y = self.board_container:getPosition()
	local board_new_pos_x = board_cur_pos_x - (new_pos_x - cur_pos_x)
	local board_new_pos_y = board_cur_pos_y - (new_pos_y - cur_pos_y)

	self.board_move_state = self:checkBoardIsCanMove()
	if self.board_move_state ~= 0 then -- 棋盘可以移动
		board_new_pos_x, board_new_pos_y = self:checkBoardPos( board_new_pos_x, board_new_pos_y )
		if self.board_move_state == 1 then -- y轴不能移动
			board_new_pos_y = board_cur_pos_y
			self:openBoardMoveTimer(true)
		elseif self.board_move_state == 2 then -- x轴不能移动
			board_new_pos_x = board_cur_pos_x
			self:openBoardMoveTimer(true)
		end
		local board_dis = math.sqrt(math.pow(board_new_pos_x-board_cur_pos_x, 2)+math.pow(board_new_pos_y-board_cur_pos_y, 2))
		local board_time = board_dis/MonopolyConst.Move_Speed
		self.board_container:runAction(cc.MoveTo:create(board_time, cc.p(board_new_pos_x, board_new_pos_y)))
	end

	-- 只要棋盘不是可以完全自由移动，就需要实时判断
	if self.board_move_state ~= 3 then
		self:openBoardMoveTimer(true)
	end
end

-- 清除移动中的数据
function MonopolyMainScene:doRoleStopMove()
	self:handlerTargetEffect(false)
	for k, object in pairs(self.route_effect_list) do
		if object.effect then
			object.effect:setVisible(false)
		end
	end
	self.board_role:setToSetupPose()
	self.board_role:setAnimation(0, PlayerAction.idle, true)
	self.cur_role_action = PlayerAction.idle
	self.move_target_pos_x = nil
	self.move_target_pos_y = nil
	self.board_role:stopAllActions()
	self.board_container:stopAllActions()
	self:openBoardMoveTimer(false)
	self.is_role_moving = false

	-- 移动完毕检测触发当前格子的事件
	self:checkProceedGridEvt()
end

-- 棋盘是否可以移动 0：不能移动 1：x轴可以移动 2：y轴可以移动 3：可以随意移动
function MonopolyMainScene:checkBoardIsCanMove(  )
	local move_state = 0
	if not self.board_role then return move_state end

	local cur_pos_x, cur_pos_y = self.board_role:getPosition()

	if cur_pos_x >= SCREEN_WIDTH*0.5 and cur_pos_x <= (MonopolyConst.Board_Width-SCREEN_WIDTH*0.5)then
		move_state = 1
	end
	if cur_pos_y >= display.height*0.5 and cur_pos_y <= (MonopolyConst.Board_Height-display.height*0.5) then
		if move_state > 0 then
			move_state = 3
		else
			move_state = 2
		end
	end
	return move_state
end

-- 检测棋盘移动的定时器
function MonopolyMainScene:openBoardMoveTimer( status )
	if status == true then
		if not self.board_move_timer then
            self.board_move_timer = GlobalTimeTicket:getInstance():add(function()
            	local board_move_state = self:checkBoardIsCanMove()
            	if board_move_state ~= self.board_move_state then
            		self.board_move_state = board_move_state
            		if self.move_target_pos_x and self.move_target_pos_y then
            			local cur_pos_x, cur_pos_y = self.board_role:getPosition()

						local board_cur_pos_x, board_cur_pos_y = self.board_container:getPosition()
						local board_new_pos_x = board_cur_pos_x - (self.move_target_pos_x - cur_pos_x)
						local board_new_pos_y = board_cur_pos_y - (self.move_target_pos_y - cur_pos_y)
						-- 棋盘移动
						board_new_pos_x, board_new_pos_y = self:checkBoardPos( board_new_pos_x, board_new_pos_y )
						if board_move_state == 1 then
							board_new_pos_y = board_cur_pos_y
						elseif board_move_state == 2 then
							board_new_pos_x = board_cur_pos_x
						end
						local board_dis = math.sqrt(math.pow(board_new_pos_x-board_cur_pos_x, 2)+math.pow(board_new_pos_y-board_cur_pos_y, 2))
						local board_time = board_dis/MonopolyConst.Move_Speed
						self.board_container:runAction(cc.MoveTo:create(board_time, cc.p(board_new_pos_x, board_new_pos_y)))
            		end
            	end
            end, 0.1)
        end
	else
		if self.board_move_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.board_move_timer)
            self.board_move_timer = nil
        end
	end
end

function MonopolyMainScene:setData(  )
	if not self.cur_monopoly_id then return end
	self.map_data = _model:getMonopolyMapDataById(self.cur_monopoly_id)
	if not self.map_data then return end
	self.map_cfg_data = Config.MonopolyMapsData.data_map_info[self.map_data.map_id]
	if not self.map_cfg_data then return end

	self:playCloudEffect(true)

	self.board_grid_data = {}
	for i, grid_index in ipairs(self.map_cfg_data.grid_pos_list or {}) do
		local map_grid_vo = MonopolyGridVo.New()
		local g_info = {}
		g_info.index = i
		g_info.grid_index = grid_index
		g_info.step_id = self.map_data.id
		g_info.map_id = self.map_data.map_id
		g_info.evt_type = self:getGridEventTypeByIndex(i)
		map_grid_vo:updateData(g_info)
		_table_insert(self.board_grid_data, map_grid_vo)
	end
	
	-- 名称
	local customs_cfg = Config.MonopolyMapsData.data_customs[self.cur_monopoly_id]
	if customs_cfg then
		self.map_name_txt:setString(customs_cfg.name)
	end
	--更新棋盘背景
	self:updateBoardBgById(self.map_cfg_data.res_id)
	-- 更新棋盘格子
	self:updateBoardGridList()
	-- 进度
	self:updateBossProgress()

	-- 创建角色
	if not self.board_role then
		local look_id = _model:getHomeLookId()
		local figure_cfg = Config.HomeData.data_figure[look_id]
		local effect_id = "H60001"
		if figure_cfg then
			effect_id = figure_cfg.look_id
		end
		self.board_role = createEffectSpine( effect_id, cc.p(0, 0), cc.p(0.5, 0), true, PlayerAction.idle )
		self.board_role:setScale(0.65)
    	self.role_slayer:addChild(self.board_role)
	end
	-- 角色位置
	self.role_cur_board_index = self.map_data.pos or 1
	local role_grid_vo = self.board_grid_data[self.role_cur_board_index]
	if role_grid_vo then
		self.cur_role_grid_x, self.cur_role_grid_y = MonopolyTile.indexTile(role_grid_vo.grid_index)
		local pos_x, pos_y = MonopolyTile.indexPixel(role_grid_vo.grid_index)
		self.board_role:setPosition(pos_x, pos_y)

		-- 根据下一个格子的位置计算角色的方向
		local next_grid_vo = self.board_grid_data[self.role_cur_board_index+1]
		if next_grid_vo then
			local next_pos_x, next_pos_y = MonopolyTile.indexPixel(next_grid_vo.grid_index)
			if next_pos_x < pos_x then
				self.board_role:setScaleX(-0.65)
			else
				self.board_role:setScaleX(0.65)
			end
		end
	end

	self:moveBoardToRoleCenter(0.01)

	-- 当前格子有事件正在触发
	self:checkProceedGridEvt()
end

-- 检测当前是否有格子事件需要触发
function MonopolyMainScene:checkProceedGridEvt()
	if self.map_data.now_type and self.map_data.now_type ~= 0 then
		self.is_proceed_evt = true
		_controller:triggerGridEvtByType(self.map_data.now_type, self.cur_monopoly_id)
	end
end

function MonopolyMainScene:getGridEventTypeByIndex(index)
	local evt_type = MonopolyConst.Event_Type.Normal
	if not self.map_data then return evt_type end
	for _, info in pairs(self.map_data.events or {}) do
		if info.pos == index then
			evt_type = info.type
			break
		end
	end
	return evt_type
end

-- 棋盘迅速移动到人物居中位置
function MonopolyMainScene:moveBoardToRoleCenter( time )
	time = time or 0.3
	local board_pos_x, board_pos_y = self:getBoardPosOfRoleCenter()
	self.board_container:runAction(cc.MoveTo:create(time, cc.p(board_pos_x, board_pos_y)))
end

-- 获取保持角色居中时，棋盘的坐标
function MonopolyMainScene:getBoardPosOfRoleCenter(  )
	local pos_x = 0
	local pos_y = 0
	if self.board_role then
		local role_pos_x, role_pos_y = self.board_role:getPosition()
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
	return self:checkBoardPos(pos_x, pos_y)
end

-- 更新格子层级
function MonopolyMainScene:updateGridListZorder()
	local sort_func = function ( objA, objB )
		local a_grid_x, a_grid_y = objA:getCurGridPos()
		local b_grid_x, b_grid_y = objB:getCurGridPos()
		if a_grid_y == b_grid_y then
			return a_grid_x < b_grid_x
		else
			return a_grid_y > b_grid_y
		end
	end
	_table_sort(self.all_grid_item_list, sort_func)

	local zorder = 1
	for i,unit in ipairs(self.all_grid_item_list) do
		zorder = zorder + 1
        unit:setItemLocalZOrder(zorder)
	end
end

-- 关卡进度
function MonopolyMainScene:updateBossProgress()
	if not self.cur_monopoly_id then return end
	local cur_dev_val = _model:getGuildDevelopValById(self.cur_monopoly_id) or 0
	local customs_cfg = Config.MonopolyMapsData.data_customs[self.cur_monopoly_id]
	if customs_cfg then
		local max_dev_val = customs_cfg.max_develop or 1
		local percent = cur_dev_val/max_dev_val*100
		self.probe_txt:setString(cur_dev_val .. "/" .. max_dev_val)
		self.probe_progress:setPercent(percent)
	end
end

-- 更新boss状态
function MonopolyMainScene:updateBossIconList(boss_data)
	boss_data = boss_data or {}
	local function getBossDataById(id)
		for k, b_data in pairs(boss_data) do
			if b_data.boss_id == id then
				return b_data
			end
		end
	end	
	local boss_cfg = Config.MonopolyDungeonsData.data_boss_info[self.cur_monopoly_id]
	if boss_cfg then
		local star_pos_x = 390
		for i, info in ipairs(boss_cfg) do
			local icon = self.progress_boss_list[i]
			if not icon then
				icon = PlayerHead.new(PlayerHead.type.circle)
				icon:addCallBack(function ()
					MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.MonopolyBoss, self.cur_monopoly_id)
				end)
				icon:setScale(0.6)
				self.top_panel:addChild(icon)
				icon.num_txt = createLabel(20, cc.c4b(255,248,191), 2, 50, 5, info.develop, icon, 2, cc.p(0.5, 1))
				icon.num_txt:setScale(1.67)
				icon:setHeadRes(info.head_id)
				icon:setPosition(star_pos_x+(i-1)*97, 22)
				icon.status = 0
				self.progress_boss_list[i] = icon
			end
			local b_data = getBossDataById(info.boss_id)
			-- 这里只要探索值变化后端就会推协议(蛋疼)，所以判断一下boss状态是否变化，有变化才做更新
			if not icon.pass_sp then
				icon.pass_sp = createSprite(PathTool.getResFrame("common", "common_1000"), 54, 54, icon, cc.p(0.5, 0.5))
				icon.pass_sp:setVisible(false)
			end
			if b_data and icon.status ~= b_data.status then
				icon.status = b_data.status
				if b_data.status == 1 then -- 未解锁
					icon.pass_sp:setVisible(false)
					setChildUnEnabled(true, icon)
				elseif b_data.status == 2 then -- 可挑战
					icon.pass_sp:setVisible(false)
					setChildUnEnabled(false, icon)
				else
					icon.pass_sp:setVisible(true)
					setChildUnEnabled(true, icon)
				end
			elseif not b_data then -- 没加入公会时，没有boss数据
				icon.pass_sp:setVisible(false)
				setChildUnEnabled(true, icon)
			end
		end
	end
end

-- 左上角buff列表
function MonopolyMainScene:updateMonopolyBuffs(buff_data)
	self.monopoly_buff_data = buff_data or {}
	for k,icon in pairs(self.buff_icon_list) do
		icon:setVisible(false)
	end
	table.sort(self.monopoly_buff_data, SortTools.KeyLowerSorter("type"))
	for i, v in ipairs(self.monopoly_buff_data) do
		local buff_icon = self.buff_icon_list[i]
		if not buff_icon then
			buff_icon = self:createBuffIcon()
			registerButtonEventListener(buff_icon, function ()
				self:onClickBuffIcon(i)
			end, true)
			self.buff_icon_list[i] = buff_icon
		end
		local b_info = MonopolyConst.Buff_Info[v.type]
		if b_info then
			buff_icon:loadTexture(PathTool.getResFrame("monopoly", b_info[1], false, "monopolyboard"), LOADTEXT_TYPE_PLIST)
			local num = v.num or 0
			buff_icon.num_txt:setString("X" .. num)
		end
		buff_icon:setVisible(true)
		buff_icon:setPositionY(183-(i-1)*94)
	end
end

function MonopolyMainScene:onClickBuffIcon(index)
	if not self.monopoly_buff_data then return end
	local buff_data = self.monopoly_buff_data[index]
	if not buff_data then return end
	local b_info = MonopolyConst.Buff_Info[buff_data.type]
	if not b_info then return end

	if not self.buff_desc_bg then
		self.buff_desc_bg = createImage(self.buff_panel, PathTool.getResFrame("monopoly", "monopolyboard_1019", false, "monopolyboard"), 105, 0, cc.p(0, 0.5), true, nil, true)
		self.buff_desc_bg:setCapInsets(cc.rect(28,30,1,1))

		self.buff_desc_txt = createRichLabel(20,  cc.c4b(142,129,119,255), cc.p(0.5, 0.5), cc.p(0, 0), nil, nil, 500)
		self.buff_desc_bg:addChild(self.buff_desc_txt)
	end
	local buff_cfg = Config.MonopolyMapsData.data_item_show[b_info[2]]
	if buff_cfg then
		self.buff_desc_txt:setString(buff_cfg.desc)
		local txt_size = self.buff_desc_txt:getContentSize()
		self.buff_desc_bg:setContentSize(cc.size(txt_size.width+45, txt_size.height+20))
		self.buff_desc_txt:setPosition((txt_size.width+50)*0.5+15, (txt_size.height+20)*0.5)
		self.buff_desc_bg:setVisible(true)

		local buff_icon = self.buff_icon_list[index]
		if buff_icon then
			self.buff_desc_bg:setPositionY(buff_icon:getPositionY())
		end

		if not self.buff_mask then
            self.buff_mask = ccui.Layout:create()
            self.buff_mask:setContentSize(SCREEN_WIDTH, display.height)
            self.buff_mask:setPositionY(display.getBottom(self.ui_container))
            self.buff_mask:setTouchEnabled(true)
            self.ui_container:addChild(self.buff_mask)
            self.buff_mask:setSwallowTouches(false)
            self.buff_mask:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    self.buff_desc_bg:setVisible(false)
                    self.buff_mask:setVisible(false)
                end
			end)
		else
			self.buff_mask:setVisible(true)
        end
	end
end

function MonopolyMainScene:createBuffIcon()
	local icon = createImage(self.buff_panel, nil, 60, 0, cc.p(0.5, 0.5), true)
	icon:setTouchEnabled(true)
	local num_bg = createSprite(PathTool.getResFrame("monopoly", "monopolyboard_1018", false, "monopolyboard"), 37, 0, icon, cc.p(0.5, 0.5))
	icon.num_txt = createLabel(20, cc.c4b(255, 248, 191, 255), cc.c4b(22, 5, 0, 255), 37, 0, "", icon, 2, cc.p(0.5, 0.5))
	return icon
end

-- 播放云层特效
function MonopolyMainScene:playCloudEffect( status )
    if status == true then
        if not tolua.isnull(self.root_wnd) and self.cloud_effect == nil then
            self.cloud_effect = createEffectSpine(Config.EffectData.data_effect_info[157], cc.p(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5), cc.p(0.5, 0.5), false, PlayerAction.action_1)
            self.cloud_effect:setScale(display.getMaxScale())
            self.root_wnd:addChild(self.cloud_effect, 99)
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

-- 显示tips
function MonopolyMainScene:checkShowTips()
	local wait_show_tips_data = _model:getWaitShowTipsData()
	if wait_show_tips_data and wait_show_tips_data[1] then -- 有待显示的tips则先显示tips
		if not self.wait_tips_bg then
			local con_size = self.ui_container:getContentSize()
			self.wait_tips_bg = createImage(self.ui_container, PathTool.getResFrame("monopoly", "monopolyboard_1017", false, "monopolyboard"), con_size.width*0.5, con_size.height*0.5+100, cc.p(0.5, 0.5), true, 99, true)
			self.wait_tips_bg:setContentSize(cc.size(720, 108))

			self.wait_tips_txt = createLabel(40, cc.c4b(255,253,217,255), cc.c4b(167,80,3,255), 360, 54, "", self.wait_tips_bg, 2, cc.p(0.5, 0.5), "fonts/title.ttf")
		end
		local tips_cfg = Config.MonopolyMapsData.data_buff_tips[wait_show_tips_data[1].type]
		if tips_cfg then
			self.wait_tips_bg:setVisible(true)
			self.wait_tips_txt:setString(tips_cfg.desc)
			local function tipsShowCallBack()
				self.wait_tips_bg:setVisible(false)
				_controller:checkShowWaitAward()
			end
			self.wait_tips_bg:runAction(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(tipsShowCallBack)))
			_model:clearWaitShowTipsData()
		else
			_controller:checkShowWaitAward()
		end
	else
		_controller:checkShowWaitAward()
	end
end

function MonopolyMainScene:close_callback(  )
	self:playCloudEffect(false)
	self:handlerTargetEffect(false)
	for k, object in pairs(self.route_effect_list) do
		if object.effect then
			object.effect:clearTracks()
            object.effect:removeFromParent()
            object.effect = nil
		end
	end
	if self.role_assets_event and self.role_vo then
        self.role_vo:UnBind(self.role_assets_event)
        self.role_assets_event = nil
    end
	self:openBoardMoveTimer(false)
	if self.board_bg_load then
		self.board_bg_load:DeleteMe()
		self.board_bg_load = nil
	end
	self:removeBoardRole()
	for k, item in pairs(self.all_grid_item_list) do
		item:DeleteMe()
		item = nil
	end
	if self.pumpkin_num then
		self.pumpkin_num:DeleteMe()
		self.pumpkin_num = nil
	end
	if self.secret_num then
		self.secret_num:DeleteMe()
		self.secret_num = nil
	end
	for k, icon in pairs(self.progress_boss_list) do
		icon:DeleteMe()
		icon = nil
	end
	_model:setCurMonopolyMapId(0)
	_controller:openMonopolyMianScene(false)
end