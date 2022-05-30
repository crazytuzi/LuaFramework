-- --------------------------------------------------------------------
--
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      战斗横版主场景
-- <br/>Create: 2017.4.17
-- --------------------------------------------------------------------

local _render_mgr = RenderMgr:getInstance()
local _controller = BattleController:getInstance()
local _model = BattleController:getInstance():getModel()
local _string_format = string.format
local _drama_controller = BattleDramaController:getInstance()
local _drama_model = BattleDramaController:getInstance():getModel()
local _main_controller = MainuiController:getInstance()

local _table_remove = table.remove
local _table_insert = table.insert

local _tolua_isnull = tolua.isnull

--战斗场景全局变量
--黑色层
BATTLE_VIEW_BACK_LAYER_Z = 0
BATTLE_VIEW_BLACK_LAYER_Z0 = 3
--ui层
BATTLE_VIEW_UI_LAYER_Z = 40
BATTLE_VIEW_UI_LAYER_TAG = 40
--人物层
BATTLE_VIEW_ROLE_LAYER_Z = 25
BATTLE_VIEW_ROLE_LAYER_TAG = 20
BATTLE_VIEW_TOP = 999
BATTLE_VIEW_EFFECT_LAYER_Z0 = 20
BATTLE_VIEW_EFFECT_LAYER_Z2 = 15
--初始化3个技能
SKILL_MAX_NUM = 3

BattleSceneNewView = class("BattleSceneNewView", function()
    return ccui.Widget:create()
end)

function BattleSceneNewView:ctor()
end

--创建战斗场景
--[[	@battle_type:战斗类型
	@sceneID:场景ID
	@current_wave:当前波数
	@total_wave:总波数
]]
function BattleSceneNewView:init(battle_type)
	self.battle_type = battle_type or BattleConst.Fight_Type.Default
	self.fight_round = 1
	self.total_round = 0
	self.charpter_id = 0
	self:config()
	self:configUI()
	self:regitsterEvent()
end

--初始化
function BattleSceneNewView:config()
	if self.battle_type == BattleConst.Fight_Type.TrialTower then
		self.move_camera_total_distance = _controller:getActTime("trial_lround_distance")
		self.move_speed = _controller:getActTime("trial_base_speed")
	else
		self.move_camera_total_distance = _controller:getActTime("round_distance")
		self.move_speed = _controller:getActTime("base_speed")
	end
	self.move_camera_pass_distance = 0 -- 已经移动多少像素
	self.isStartUpdate = false
	self.call_mon_distance = 0
	self.is_run = false
	self.effect_id = ""
	self.map_effect_id = ""
	self.mid_effect_id = ""
	self.b_effect_id = ""
	self.is_need_move_map = false
	self.is_single_bg = FALSE
	self.is_init_normal_battle = false
	self.right_btn_list = {}

	self.fly_item_sum = 0
	
	-- +220
	self.map_init_y = 260				--角色和特效初始Y
	self.slayer_init_y = 0			--地图背景层
	self.flayer_init_y = 716				--地图远景层
	--self.top_size_height = 620			--预留给剧情上面的可以滑动高度

	-- ios打开窗体上报
	if MAKELIFEBETTER == true and ios_log_report then
		ios_log_report("battle_scene_view")
	end
end

function BattleSceneNewView:setbattleModel(model)
	_model = model or _controller:getModel()
end

function BattleSceneNewView:regitsterEvent()
	if self.update_buff_event == nil then
		self.update_buff_event = GlobalEvent:getInstance():Bind(Battle_dramaEvent.BattleDrama_Drama_Buff_View, function(data)
			self:createBuffIcon(data)
		end)		
	end

	if self.chat_ui_size_change == nil then
		self.chat_ui_size_change = GlobalEvent:getInstance():Bind(EventId.CHAT_HEIGHT_CHANGE, function()
			self:changeSomeLayoutPosition()
		end)
	end
	
end

function BattleSceneNewView:configUI()
	self.main_size = cc.size(SCREEN_WIDTH, display.height)
	self:setContentSize(self.main_size)
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
	
	if not self.main_layer then
		self.main_layer = ccui.Layout:create() --场景的主节点
		self.main_layer:setContentSize(self.main_size)
		self.main_layer:setVisible(false)
		self.main_layer:setAnchorPoint(cc.p(0.5, 0.5))
		self.main_layer:setCascadeOpacityEnabled(true)
		self.main_layer:setPosition(self.main_size.width * 0.5, self.main_size.height * 0.5)
		self:addChild(self.main_layer)
		self:setSwallowTouches(false)

		self.map_fLayer = ccui.Widget:create() --远景地图
		self.map_fLayer:setCascadeOpacityEnabled(true)
		self.map_fLayer:setSwallowTouches(false)
		self.map_fLayer:setAnchorPoint(cc.p(0, 0))
		self.map_fLayer:setPositionY(self.flayer_init_y)
		self.main_layer:addChild(self.map_fLayer, BATTLE_VIEW_BLACK_LAYER_Z0)
		
		self.map_sLayer = ccui.Widget:create()				-- 地图层,包含了特效层,角色层和背景层
		self.map_sLayer:setAnchorPoint(cc.p(0, 0))
		self.map_sLayer:setCascadeOpacityEnabled(true)
		self.map_sLayer:setSwallowTouches(false)
		self.map_sLayer:setName("map_sLayer")
		self.main_layer:addChild(self.map_sLayer, BATTLE_VIEW_BLACK_LAYER_Z0 + 1)
		
		self.effect_layer_1 = ccui.Widget:create() --特效层1
		self.effect_layer_1:setPositionY(self.map_init_y)
		self.map_sLayer:addChild(self.effect_layer_1, BATTLE_VIEW_ROLE_LAYER_Z + 1)
		
		self.effect_layer_2 = ccui.Widget:create() --特效层2
		self.effect_layer_2:setPositionY(self.map_init_y)
		self.map_sLayer:addChild(self.effect_layer_2, BATTLE_VIEW_BLACK_LAYER_Z0)
		
		self.role_layer = BattleRoleView.create() --角色层
		self.role_layer:setAnchorPoint(cc.p(0, 1))
		self.role_layer:setOpacity(255)
		self.role_layer:setScale(1)
		self.role_layer:setSwallowTouches(false)
		self.role_layer:setPositionY(self.map_init_y)
		self.map_sLayer:addChild(self.role_layer, BATTLE_VIEW_ROLE_LAYER_Z, BATTLE_VIEW_ROLE_LAYER_TAG)
	end
	
	if self.ui_main_layer == nil then
		self.ui_main_layer = ccui.Layout:create() --战斗所有的UI上面的
		self.ui_main_layer:setContentSize(self.main_size)
		self.ui_main_layer:setAnchorPoint(cc.p(0.5, 0.5))
		self.ui_main_layer:setPosition(self.main_size.width * 0.5, self.main_size.height * 0.5)
		self:addChild(self.ui_main_layer, 1)
	end
	
	self:createMap()
	self:handleLayerShowHide(true)
	self:MapMovescheduleUpdate()
end

--[[    @desc:创建战斗背景 
    author:{author}
    time:2018-10-01 22:24:05
    @return:
]]
function BattleSceneNewView:createMap()
	self.battle_res_id = _controller:curBattleResId(self.battle_type) or 10001
	self.is_pvp = BattleConst.isPvP(self.battle_type)
	self.music_info = AudioManager:getInstance():getMusicInfo()
	self:playMusic()
	self:createHorizontalMap(self.battle_res_id)
end

--[[    @desc:战斗音效 
    author:{author}
    time:2018-10-01 22:23:14
    @return:
]]
function BattleSceneNewView:playMusic()
	local music_config = nil
	if self.battle_type == BattleConst.Fight_Type.Darma then
		local data_config = Config.BattleBgData.data_info2
		if data_config and data_config[self.battle_type] then
			music_config = data_config[self.battle_type] [self.battle_res_id]
		end
	else
		local data_config = Config.BattleBgData.data_info
		if data_config and data_config[self.battle_type] then
			music_config = data_config[self.battle_type]
		end
	end
	if music_config ~= nil then
		self.is_single_bg = music_config.is_single_bg
		if music_config.bg_music ~= "" then
			AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.BATTLE, music_config.bg_music, true)
		end
	end
end

--[[    @desc: 创建水平战斗的地图,区分是单张还是多张.剧情战斗时多张.而且同时要创建剧情地图
    author:{author}
    time:2018-10-01 22:03:00
    --@battle_res_id: 
    @return:
]]
function BattleSceneNewView:createHorizontalMap(battle_res_id)
	print("创建水平战斗的地图",battle_res_id,self.is_single_bg)
	if self.is_single_bg == FALSE then
		local res = PathTool.getBattleSceneRes(_string_format("%s/map_bg", self.battle_res_id), false)
		if self.map_bg_res_id ~= res then		-- 创建前景层,前景层创建完成之后开始加载假战斗
			self.map_bg_res_id = res
			self.load_res_map_bg = createResourcesLoad(res, ResourcesType.single, function()
				if not _tolua_isnull(self.map_sLayer) then
					if not self.map_bg then
						self.map_bg = createSprite(res, 0, 0, self.map_sLayer, cc.p(0, 0), LOADTEXT_TYPE, BATTLE_VIEW_BACK_LAYER_Z)
					end
					self:updateNormalBattle()
					self:createNewBg(self.map_bg_res_id)
				end
			end, self.load_res_map_bg, true)
		end

		local res = PathTool.getBattleSceneRes(_string_format("%s/m_bg", self.battle_res_id), false)
		if self.f_bg_res_id ~= res then
			self.f_bg_res_id = res
			self.load_res_f_bg = createResourcesLoad(res, ResourcesType.single, function()
				if not _tolua_isnull(self.map_sLayer) then
					if not self.f_bg then
						self.f_bg = createSprite(res, 0, 0, self.map_fLayer, cc.p(0, 0), LOADTEXT_TYPE, BATTLE_VIEW_BACK_LAYER_Z)
						-- 远景层要做适配
						self.f_bg:setScale(self:getFarLayerScale())
					end
					self:createNewFbg(self.f_bg_res_id)
					MainSceneController:getInstance():handleSceneStatus(false)
				end
			end, self.load_res_f_bg, true)
		end
		
		-- 剧情副本特有的一些东西
		if self.battle_type == BattleConst.Fight_Type.Darma then
			-- buff图标只在剧情副本界面显示
			if self.battle_buff_object then
				if not _tolua_isnull(self.battle_buff_object.container) then
					self.battle_buff_object.container:setVisible(true)
				end
			end

			_drama_controller:openBattleDramaUI(true, self.battle_res_id, self.battle_type)
		else
			--这里写我的东西?
		end
	else
		local res = PathTool.getBattleSceneRes(_string_format("%s/b_bg", self.battle_res_id), true)
		if self.single_bg_res_id ~= res then
			self.single_bg_res_id = res
			local max_scale = display.getMaxScale()
			self.load_res_f_bg = createResourcesLoad(res, ResourcesType.single, function()
				if not self.single_bg and not _tolua_isnull(self.main_layer) then
					self.single_bg = createSprite(res, self.main_size.width * 0.5, display.getBottom(self), self.map_sLayer, cc.p(0.5, 0), LOADTEXT_TYPE, - 1)
					self.single_bg:setScale(max_scale)
				end
				MainSceneController:getInstance():handleSceneStatus(false)
			end, self.load_res_f_bg, true)	
			-- 考虑到适配问题这边需要重新对一下位置
			if max_scale ~= 1 then
				local off_y = self.map_init_y * max_scale
				off_y = off_y +(off_y - self.map_init_y)
				self.effect_layer_1:setPositionY(off_y)
				self.effect_layer_2:setPositionY(off_y)
				self.role_layer:setPositionY(off_y)
			end
		end
	end
	
	local buff_data = _drama_model:getBuffData()
	if buff_data or _main_controller:checkIsInDramaUIFight() then
		if not BattleConst.isBuffAdd(self.battle_type) then
			self:createBuffIcon(buff_data)
		end
	end
	self:createAutoCombatIcon()
	self:showMainAction()
end

--[[    @desc:创建地图层特效,暂时只处理剧情副本的
    author:{author}
    time:2018-10-01 22:49:58
    --@effect_res: 
    @return:
]]
function BattleSceneNewView:updateMapEffect(effect_res)
end

function BattleSceneNewView:showMainAction()
	self.main_layer:setVisible(true)
end

--[[    @desc:第一对地图创建完成之后,开始创建第二对地图
    author:{author}
    time:2018-10-01 22:12:27
    --@direction: 
    @return:
]]
function BattleSceneNewView:checkFinishLoadMap(direction)
end


function BattleSceneNewView:updateNormalBattle(data)
	local temp_data = data or _controller:getCircleData()
	if temp_data then
		if not self.is_init_normal_battle then
			_controller:openNormalBattle(BattleLoop2.init(temp_data))
			self.is_init_normal_battle = true
		end
	end
end

function BattleSceneNewView:removeTimer()
end

--定时器开启
function BattleSceneNewView:MapMovescheduleUpdate()
	if self.isStartUpdate then return end
	self.isStartUpdate = true
	local function su(dt)
		self:mapUpdate(dt)
	end
	if self.main_layer and not _tolua_isnull(self.main_layer) then
		self.main_layer:scheduleUpdateWithPriorityLua(su, 0)
	end
end

--定时器关闭
function BattleSceneNewView:unMapMovescheduleUpdate()
	if not self.isStartUpdate then return end
	self.isStartUpdate = false
	self.move_camera_pass_distance = 0
	if self.main_layer and not _tolua_isnull(self.main_layer) then
		self.main_layer:unscheduleUpdate()
	end
end

--设置是否开启地图跑动
function BattleSceneNewView:setMoveMapStatus(status)
	self.is_need_move_map = status
	self.is_run = status
	if status == false then
		self.move_camera_pass_distance = 0
	end
end

--每帧更新
function BattleSceneNewView:mapUpdate(dt)
	if _model:getTimeScale() ~= _controller:getActTime("base_speed_scale") then
		self.move_camera_total_distance = _controller:getActTime("round_distance")
		self.move_speed = _controller:getActTime("double_base_speed")
	else
		self.move_camera_total_distance = _controller:getActTime("round_distance")
		self.move_speed = _controller:getActTime("base_speed")
	end
	if self.is_need_move_map == true then
		if not _controller:getIsNoramalBattle() then
			if not _tolua_isnull(self.main_layer) then
				self:updateRun()
			end
		else
			self.move_speed = _controller:getActTime("new_hook_base_speed")
			--预防跑动过程加速
			if not _tolua_isnull(self.f_bg) and not _tolua_isnull(self.map_bg) then
				self:move(self.map_bg, self.f_bg, self.move_speed)
			end
		end
	end
end

function BattleSceneNewView:updateRun()
	self.move_camera_pass_distance = math.min(self.move_camera_pass_distance + self.move_speed, self.move_camera_total_distance)
	local is_move_half = math.abs(self.move_camera_pass_distance / self.move_camera_total_distance) >= _controller:getActTime("normal_battle_per_distance")
	if self.move_camera_pass_distance >= self.move_camera_total_distance then
		self.is_run = false
		_model:updateStop()
	else
		_model:updateRun(is_move_half)
		--预防跑动过程加速
		self:move(self.map_bg, self.f_bg, self.move_speed)
	end
end

--四层地图移动统一接口
function BattleSceneNewView:move(object, object2, move_speed, is_stroy)
	local offset = 0
	--地图
	if object then
		self:mapMove(object, move_speed) --* object:getScale()
	end
	--前景1
	if object2 then
		local move_speed = move_speed * _controller:getActTime("first_speed") --* object2:getScale()
		object2:setPositionX(object2:getPositionX() - move_speed)
		if self.f_bg_2 then
			self.f_bg_2:setPositionX(self.f_bg_2:getPositionX() - move_speed)
		end
		if not is_stroy then
			self:changeBg(object2, self.f_bg_2, true)
		end
	end
	
end

--主要用于记录前景层特效的移动
function BattleSceneNewView:setActionName(action_name)
	self.action_name = action_name
end

--横版重复变换1,2张图片
function BattleSceneNewView:changeBg(object, object2, is_f)
	local scale = 1
	if is_f then
		scale = self:getFarLayerScale()
	end
	if object then
		local width = object:getContentSize().width*scale
		if(object:getPositionX() + width) <= 0 then
			--将第一张地图添加到第二张地图后面
			--第一张地图的横坐标 = 第二张地图的横坐标 + 第二张地图的宽度
			if object2 then
				object:setPositionX(object2:getPositionX() + object2:getContentSize().width*scale)
			end
		end
	end
	if object2 then
		local width = object2:getContentSize().width*scale
		
		--当第二张地图的最右端和窗口的最左端重合时
		--将第二张地图添加到第一张地图后面
		if(object2:getPositionX() + width <= 0) then
			--将第二张地图添加到第一张地图后面
			--第二张地图的横坐标 = 第一张地图的横坐标 + 第一张地图的宽度
			object2:setPositionX(object:getPositionX() + object:getContentSize().width*scale)
		end
	end
end


--地图层移动接口，方便重连之后计算位置
function BattleSceneNewView:mapMove(object, move_speed)
	if	not self.is_pvp then
		--地图2
		if object then
			object:setPositionX(object:getPositionX() - move_speed)
			local offset = object:getContentSize().width + object:getPositionX()
			if self.map_bg_2 then
				self.map_bg_2:setPositionX(self.map_bg_2:getPositionX() - move_speed)
			end
			self:changeBg(object, self.map_bg_2)
		end
	end
end

--[[    @desc:创建第二章背景层
    author:{author}
    time:2018-10-01 22:00:50
    --@direction: 
    @return:
]]
function BattleSceneNewView:createNewBg(res_path)
	if res_path == nil or res_path == "" then 
		return 
	end
	if not self.map_bg_2 and not _tolua_isnull(self.map_sLayer) and not _tolua_isnull(self.map_bg) then
		if not _tolua_isnull(self.map_sLayer) and not _tolua_isnull(self.map_bg) then
			local map_width = self.map_bg:getContentSize().width
			self.map_bg_2 = createSprite(res_path, map_width, 0, self.map_sLayer, cc.p(0, 0), LOADTEXT_TYPE, BATTLE_VIEW_BACK_LAYER_Z)
		end
	end
end

--[[    @desc: 创建第二章前景层
    author:{author}
    time:2018-10-01 22:00:36
    --@direction: 
    @return:
]]
function BattleSceneNewView:createNewFbg(res_path)
	if res_path == nil or res_path == "" then 
		return 
	end
	if not self.f_bg_2 and not _tolua_isnull(self.f_bg) and not _tolua_isnull(self.map_fLayer) then
		if not _tolua_isnull(self.map_fLayer) and not _tolua_isnull(self.f_bg) then
			local map_width = self.f_bg:getContentSize().width*self:getFarLayerScale()
			self.f_bg_2 = createSprite(res_path, map_width, 0, self.map_fLayer, cc.p(0, 0), LOADTEXT_TYPE, BATTLE_VIEW_BACK_LAYER_Z)
			self.f_bg_2:setScale(self:getFarLayerScale())
		end
	end
end

--==============================--
--desc:创建ui层
--time:2018-09-12 09:44:59
--@data:
--@main_vo:
--@combat_type:
--@return 
--==============================--
function BattleSceneNewView:createUiLayer(data, main_vo, combat_type)
	self.is_main_fight_round = false -- 是否自己当前回合
	self.initData = data --初始化数据
	self.main_vo = main_vo --人物数据
	self.is_max_skill = false --是否满技能
	self.fight_round = data.current_wave
	self.total_round = data.total_wave
	self.dunge_data = data.extra_args
	self.dunge_str_data = data.string_ext_args
	self.battle_type = combat_type
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.stand_wait_timer = 0
	self.stand_button_time = 0.2
	
	self.ui_layer = ccui.Layout:create()
	self.ui_layer:setAnchorPoint(cc.p(0, 0))
	self.ui_layer:setPosition(0, 0)
	
	if self.ui_main_layer and not _tolua_isnull(self.ui_main_layer) then
		self.ui_main_layer:addChild(self.ui_layer, BATTLE_VIEW_UI_LAYER_Z, BATTLE_VIEW_UI_LAYER_TAG)
	end
	if not _controller:getIsNoramalBattle() then
		-- 创建双倍速度
		if not self.double_speed_btn then
			self.double_speed_btn = createImage(self.ui_layer, PathTool.getResFrame("common", "common_1018"), 620, 300, cc.p(1, 0.5), true, nil, true)
			self.double_speed_btn:setTouchEnabled(true)
			self.double_speed_Label = createLabel(22,Config.ColorData.data_new_color4[1],Config.ColorData.data_new_color4[10],50,32,TI18N("X1"),self.double_speed_btn,2,cc.p(0.5, 0.5))
			--self.double_speed_btn:setContentSize(cc.size(78, 49))
			--self.double_speed_btn:setCapInsets(cc.rect(20, 24, 1, 2))
			self.double_speed_btn:setPosition(self.main_size.width+80, self.main_size.height/2-40)
			self.double_speed_btn:addTouchEventListener(function(sender, event_type)
				customClickAction(sender, event_type)
				if event_type == ccui.TouchEventType.ended then
					if _model:checkIsCanChangeBattleSpeed(self.battle_type, true) then
						_model:changeSpeed()
					end
				end
			end)
		end

		local is_can_skip = false --战斗跳过判断
		local _config = Config.CombatTypeData.data_fight_list[self.battle_type]
		if _config and _config.is_skip == "true" then --配置表配置为可跳过
			if self.battle_type ==  BattleConst.Fight_Type.Arena then -- 竞技场
				local count = ArenaController:getInstance():getModel():getHadCombatNum()
				local arena_config = Config.ArenaData.data_const.arena_skip_count
				if arena_config and not _controller:getWatchReplayStatus() then 
					local max_count = arena_config.val or 30
					if count >= max_count then
						is_can_skip = true
					end
				end
			elseif self.battle_type == BattleConst.Fight_Type.ExpeditFight then -- 远征
				local diff_choose = HeroExpeditController:getInstance():getModel():getDifferentChoose()
				local config_data = Config.ExpeditionData.data_sign_reward
				if config_data and config_data[diff_choose] and config_data[diff_choose].is_jump == 1 then
					is_can_skip = true
				end
			elseif self.battle_type == BattleConst.Fight_Type.PlanesWar then -- 位面
				local limit_cfg = Config.PlanesData.data_const["planes_skip_battle_lev"]
				local role_vo = RoleController:getInstance():getRoleVo()
				if role_vo and limit_cfg and role_vo.lev >= limit_cfg.val then
					is_can_skip = true
				end
			else
				is_can_skip = true
			end
		end

		if not BattleController:getInstance():getWatchReplayStatus() and _config and _config.is_skip == "true" then
			if not self.skip_btn then
				self.skip_btn = createImage(self.ui_layer, PathTool.getResFrame("battle", "battle_10028"), 620, 580, cc.p(1, 0.5), true, nil, true)
				self.skip_btn_label = createLabel(24,cc.c3b(255,195,141),cc.c3b(33,23,17),39,24,TI18N("跳过"),self.skip_btn,2,cc.p(0.5, 0.5))
				self.skip_btn:setTouchEnabled(true)
				self.skip_btn:setContentSize(cc.size(78, 49))
				self.skip_btn:setCapInsets(cc.rect(20, 24, 1, 2))
				self.skip_btn:setPosition(self.main_size.width+8, self.main_size.height/2+175)
				self.skip_btn:addTouchEventListener(function(sender, event_type)
					customClickAction(sender, event_type)
					if event_type == ccui.TouchEventType.ended then
						if self.battle_type ==  BattleConst.Fight_Type.Arean_Team then
							--组队竞技场 不能让玩家那么快点跳过 ,否则会出现上一场资源没清除干净就到下一场了 -- by lwc
							local time = GameNet:getInstance():getTimeFloat()
							if _model.skip_last_time and  time - _model.skip_last_time < 1.5 then
				                return
				            end
				            _model.skip_last_time = time
				        end

						if is_can_skip then -- 可以跳过
							_controller:send20062()
						else -- 不能跳过
							if self.battle_type ==  BattleConst.Fight_Type.Arena then -- 竞技场
								local arena_config = Config.ArenaData.data_const.arena_skip_count or {}
								local max_count = arena_config.val or 30
								message(_string_format(TI18N("本赛季挑战%s次之后可跳过"), max_count))
							elseif self.battle_type == BattleConst.Fight_Type.PlanesWar then -- 位面
								local limit_cfg = Config.PlanesData.data_const["planes_skip_battle_lev"]
								if limit_cfg then
									message(limit_cfg.desc)
								end
							end
						end
					end
				end)
				self.skip_btn.index = 1
				self.right_btn_list[1] = self.skip_btn
			end
		end
		-- 创建阵法
		if data.formation ~= nil then
			-- 剧情副本战斗的阵法信息加载到剧情副本层
			if self.battle_type == BattleConst.Fight_Type.Darma then
				_drama_controller:updataZhenfaInfo(true, data)
			else
				self:updataZhenfaInfo(data)
			end
			local action_count = 0
			if data.action_count then
				action_count = data.action_count
			end
			-- 创建和更新回合数
			self:updateRound(action_count)
		end
	end
	
	if not _controller:getWatchReplayStatus() then --正常战斗下
		if self.battle_type == BattleConst.Fight_Type.GuildDun then --公会boss战
			self:addGuildBossUI(BattleConst.Fight_Type.GuildDun, 0)
		elseif self.battle_type == BattleConst.Fight_Type.MonopolyBoss then -- 圣夜奇境boss
			self:addGuildBossUI(BattleConst.Fight_Type.MonopolyBoss, 0)
		elseif self.battle_type == BattleConst.Fight_Type.EliteMatchWar then-- 精英常规战斗
			self:addEliteDeclarationUI(self.battle_type)
		elseif self.battle_type == BattleConst.Fight_Type.EliteKingMatchWar then-- 精英王者战斗
			self:addEliteMatchUI(self.battle_type)
			self:addEliteDeclarationUI(self.battle_type)
		elseif self.battle_type == BattleConst.Fight_Type.PK or self.battle_type == BattleConst.Fight_Type.HeroTestWar then
			self:addExitBtnUI()
		elseif self.battle_type == BattleConst.Fight_Type.SandybeachBossFight then  --沙滩保卫战
			self:addSandybeachBossFightUI()
		elseif self.battle_type == BattleConst.Fight_Type.LimitExercise then  --试炼之境
			self:addLimitExerciseBossFightUI()
		elseif self.battle_type == BattleConst.Fight_Type.HeavenWar then  --天界副本
			self:addHeavenStarUI()
			self:updateSkipTeamBtnStatus()
		elseif self.battle_type == BattleConst.Fight_Type.CrossArenaWar then  --跨服竞技场
			self:addSessionStatusUI()
		elseif self.battle_type == BattleConst.Fight_Type.AreanManyPeople then  --多人竞技场
			self:addSessionStatusUI()
		elseif self.battle_type == BattleConst.Fight_Type.GuildSecretArea then  --公会秘境战斗
			self:addGuildSecretAreaUI()
		elseif self.battle_type == BattleConst.Fight_Type.YearMonsterWar then  --年兽战斗
			--self:addYearMonsterUI()
		elseif self.battle_type == BattleConst.Fight_Type.WhiteDayWar then  --女神试炼
			--self:addYearMonsterUI(true)
		elseif self.battle_type == BattleConst.Fight_Type.PractiseTower then  --演武场试练塔活动
			self:addBoosHpUI()
		end
	else
		self:addExitBtnUI()
	end
	-- 元素圣殿要显示常驻信息提示
	if self.battle_type == BattleConst.Fight_Type.ElementWar then
		self:checkShowElementMsg()
	end

	-- 战斗内隐藏buff按钮
	if self.battle_buff_object then
		if not _tolua_isnull(self.battle_buff_object.container) then
			self.battle_buff_object.container:setVisible(false)
		end
	end
end

--==============================--
--desc:创建阵法以及设置政法相关信息
--time:2018-09-12 09:48:01
--@data_vo:
--@role_name_list:
--@return 
--==============================--
function BattleSceneNewView:updataZhenfaInfo(data)
    if data.formation == nil then return end
	local form_info = {}
	for i, v in pairs(data.formation) do
		form_info[v.group] = {v.formation_type or 1, v.formation_lev or 0}
	end
	-- 不满足任何一个条件,都直接不处理
	if form_info[1] == nil or form_info[2] == nil or form_info[1][1] == nil or form_info[1][2] == nil or form_info[2][1] == nil or form_info[2][2] == nil then return end
	if self.ui_layer and not _tolua_isnull(self.ui_layer) then
		if _tolua_isnull(self.form_view) then
			self.form_view = createCSBNote(PathTool.getTargetCSB("battle/battle_form_view"))
			self.form_view:setAnchorPoint(cc.p(0.5, 0))
			self.ui_layer:addChild(self.form_view)
			self.form_view:setPosition(self.main_size.width/2, display.getBottom(self) + _main_controller:getBottomHeight() + 40)
			
			self.left_btn = self.form_view:getChildByName("left_btn")
			self.left_form_icon = self.left_btn:getChildByName("icon")
			
			self.right_btn = self.form_view:getChildByName("right_btn")
			self.right_form_icon = self.right_btn:getChildByName("icon")

			self.buff_btn = self.form_view:getChildByName("buff_btn")
			self.buff_btn:setOpacity(0)
            self.buff_btn:runAction(cc.FadeIn:create(0.7)) -- 延迟一些显示，避免可能打开buff界面却还没有数据
            registerButtonEventListener(self.buff_btn, function (  )
                local left_name = data.actor_role_name
                local right_name = data.target_role_name
                local group = _controller:getModel():getGroup()
                if group == BattleGroupTypeConf.TYPE_GROUP_ENEMY and not _controller:getWatchReplayStatus() then
                    left_name = data.target_role_name
                    right_name = data.actor_role_name
                end
                _controller:openBattleBuffInfoView(true, left_name, right_name)
            end, false)

            -- 跳过队伍一
            self.skip_team_btn = self.form_view:getChildByName("skip_team_btn")
            self.skip_team_btn:setVisible(false)
            registerButtonEventListener(self.skip_team_btn, function (  )
                _controller:csSkipFirstTeam()
            end, true)

			local image_2 = self.form_view:getChildByName("image_2")
			self.round_label = image_2:getChildByName("round_label")

			self.left_name_panel = self.form_view:getChildByName("left_name_panel")
			self.right_name_panel = self.form_view:getChildByName("right_name_panel")
			self.left_name_label = self.left_name_panel:getChildByName("left_name_label")
			self.right_name_label = self.right_name_panel:getChildByName("right_name_label")

			self.left_camp_btn = self.form_view:getChildByName("left_camp_btn")
			self.right_camp_btn = self.form_view:getChildByName("right_camp_btn")
		end
		
		-- 阵法图标
		if not _tolua_isnull(self.form_view) then
			loadSpriteTexture(self.left_form_icon, PathTool.getResFrame("battle", "battle_form_icon_" .. form_info[1] [1]), LOADTEXT_TYPE_PLIST)
			loadSpriteTexture(self.right_form_icon, PathTool.getResFrame("battle", "battle_form_icon_" .. form_info[2] [1]), LOADTEXT_TYPE_PLIST)
		end

		-- 阵营图标
		local halo_list = data.halo_list or {}
		local left_halo_id = nil  -- 左侧光环id
		local right_halo_id = nil -- 右侧光环id
		for k,v in pairs(halo_list) do
			if v.group == 1 then
				left_halo_id = v.type
			elseif v.group == 2 then
				right_halo_id = v.type
			end
		end
		local left_halo_id_list = {}
		local right_halo_id_list = {}
		-- 兼容旧的录像数据，可能发过来的阵营光环id还是旧的，需要转换为新的id
		if left_halo_id < 100 then
			left_halo_id_list = BattleConst.Old_Halo_Id_Change[left_halo_id] or {}
		else
			local left_id_1 = math.floor(left_halo_id/10000)
            local left_id_2 = math.floor((left_halo_id%10000)/100)
            local left_id_3 = left_halo_id%100
            if left_id_1 > 0 then
                _table_insert(left_halo_id_list, left_id_1)
            end
            if left_id_2 > 0 then
                _table_insert(left_halo_id_list, left_id_2)
            end

            if left_id_3 > 0 then
                _table_insert(left_halo_id_list, left_id_3)
            end
		end
		-- 兼容旧的录像数据，可能发过来的阵营光环id还是旧的，需要转换为新的id
		if right_halo_id < 100 then
			right_halo_id_list = BattleConst.Old_Halo_Id_Change[right_halo_id] or {}
		else
			local right_id_1 = math.floor(right_halo_id/10000)
            local right_id_2 = math.floor((right_halo_id%10000)/100)
            local right_id_3 = right_halo_id%100
            if right_id_1 > 0 then
                _table_insert(right_halo_id_list, right_id_1)
            end
            if right_id_2 > 0 then
                _table_insert(right_halo_id_list, right_id_2)
            end
            if right_id_3 > 0 then
                _table_insert(right_halo_id_list, right_id_3)
            end
		end
		if not _tolua_isnull(self.left_camp_btn) then
			local halo_res = PathTool.getCampGroupIcon( 1000 )
			local halo_icon_config = BattleController:getInstance():getModel():getCampIconConfigByIds(left_halo_id_list)
			if halo_icon_config and halo_icon_config.icon then
				halo_res = PathTool.getCampGroupIcon(halo_icon_config.icon)
				if not self.left_camp_effect then
					local btn_size = self.left_camp_btn:getContentSize()
					self.left_camp_effect = createImage(self.left_camp_btn, PathTool.getResFrame("common", "common_1101"), btn_size.width/2, btn_size.height/2, cc.p(0.5, 0.5), true)
            		self.left_camp_effect:setScale(0.8)
				end
				self:updateCampEffect(true, self.left_camp_effect)
				addCountForCampIcon(self.left_camp_btn, halo_icon_config.nums)
			else
				self:updateCampEffect(false, self.left_camp_effect)
				addCountForCampIcon(self.left_camp_btn)
			end
			self.left_halo_load = loadImageTextureFromCDN(self.left_camp_btn, halo_res, ResourcesType.single, self.left_halo_load)
			local function onClickLeftCampBtn(  )
				_controller:openBattleCampView(true, left_halo_id_list)
			end
			registerButtonEventListener(self.left_camp_btn, onClickLeftCampBtn, true,nil,nil,0.85)
		end
		if not _tolua_isnull(self.right_camp_btn) then
			local halo_res = PathTool.getCampGroupIcon( 1000 )
			local halo_icon_config = BattleController:getInstance():getModel():getCampIconConfigByIds(right_halo_id_list)
			if halo_icon_config and halo_icon_config.icon then
				halo_res = PathTool.getCampGroupIcon(halo_icon_config.icon)
				if not self.right_camp_effect then
					local btn_size = self.right_camp_btn:getContentSize()
					self.right_camp_effect = createImage(self.right_camp_btn, PathTool.getResFrame("common", "common_1101"), btn_size.width/2, btn_size.height/2, cc.p(0.5, 0.5), true)
            		self.right_camp_effect:setScale(0.8)
				end
				self:updateCampEffect(true, self.right_camp_effect)
				addCountForCampIcon(self.right_camp_btn, halo_icon_config.nums)
			else
				self:updateCampEffect(false, self.right_camp_effect)
				addCountForCampIcon(self.right_camp_btn)
			end
			self.right_halo_load = loadImageTextureFromCDN(self.right_camp_btn, halo_res, ResourcesType.single, self.right_halo_load)
			local function onClickRightCampBtn(  )
				_controller:openBattleCampView(true, right_halo_id_list)
			end
			registerButtonEventListener(self.right_camp_btn, onClickRightCampBtn, true,nil,nil,0.85)
		end

		-- 对阵双方名称
		local name1 = data.actor_role_name
		local name2 = data.target_role_name
		local group = _controller:getModel():getGroup()
		if group == BattleGroupTypeConf.TYPE_GROUP_ENEMY and not _controller:getWatchReplayStatus() then
			name1 = data.target_role_name
			name2 = data.actor_role_name
		end
		if name1 then
			self.left_name_label:setString(name1)
		end
		if name2 then
			self.right_name_label:setString(TI18N(name2) )
		end

		self:setPlayerNameClickStatus(data.objects)
	end
end

-- 角色名称点击
function BattleSceneNewView:setPlayerNameClickStatus( fight_objects )
	if not fight_objects then return end
	local left_hero_data = {}
	local right_hero_data = {}
	for k,v in pairs(fight_objects) do
		if v.object_type ~= BattleObjectType.Hallows and v.object_type ~= BattleObjectType.Elfin then
			if v.group == 1 then
				_table_insert(left_hero_data, v)
			elseif v.group == 2 then
				_table_insert(right_hero_data, v)
			end
		end
	end

	local role_vo = RoleController:getInstance():getRoleVo()
	local left_rid = 0
	local left_srv_id = 0
	local is_monster = false
	local is_myself = false
	for k,v in pairs(left_hero_data) do
		if not v.owner_id or v.owner_id == 0 or not v.owner_srv_id then
			is_monster = true
		elseif v.owner_id and v.owner_id == role_vo.rid and v.owner_srv_id and v.owner_srv_id == role_vo.srv_id then
			is_myself = true
		end
		if is_monster or is_myself then
			left_rid = 0
			left_srv_id = 0
			break
		else
			left_rid = v.owner_id
			left_srv_id = v.owner_srv_id
		end
	end
	if left_rid ~= 0 and left_srv_id ~= "" then
		registerButtonEventListener(self.left_name_panel, function (  )
			FriendController:getInstance():openFriendCheckPanel(true, {rid=left_rid, srv_id=left_srv_id})
		end, true)
	end

	local right_rid = 0
	local right_srv_id = 0
	is_monster = false
	is_myself = false
	for k,v in pairs(right_hero_data) do
		if not v.owner_id or v.owner_id == 0 or not v.owner_srv_id then
			is_monster = true
		elseif v.owner_id and v.owner_id == role_vo.rid and v.owner_srv_id and v.owner_srv_id == role_vo.srv_id then
			is_myself = true
		end
		if is_monster or is_myself then
			right_rid = 0
			right_srv_id = 0
			break
		else
			right_rid = v.owner_id
			right_srv_id = v.owner_srv_id
		end
	end
	if right_rid ~= 0 and right_srv_id ~= "" then
		registerButtonEventListener(self.right_name_panel, function (  )
			FriendController:getInstance():openFriendCheckPanel(true, {rid=right_rid, srv_id=right_srv_id})
		end, true)
	end
end

-- 光环特效
function BattleSceneNewView:updateCampEffect( status, effect_node )
	if not effect_node or _tolua_isnull(effect_node) then return end
	if status == true then
		effect_node:setVisible(true)
		local fadein = cc.FadeIn:create(0.6)
        local fadeout = cc.FadeOut:create(0.6)
        effect_node:runAction(cc.RepeatForever:create(cc.Sequence:create(fadein, fadeout)))
	else
		doStopAllActions(effect_node)
		effect_node:setVisible(false)
	end
end

function BattleSceneNewView:getStarPanelUI()
	if not self.dunge_data or next(self.dunge_data) == nil then return end
	if self.ui_layer and not _tolua_isnull(self.ui_layer) then
		if _tolua_isnull(self.star_panel) then
			self.star_panel = createCSBNote(PathTool.getTargetCSB("battle/battle_star_panel"))
			self.star_panel:setAnchorPoint(cc.p(0.5, 0))
			self.ui_layer:addChild(self.star_panel)
			self.star_panel:setPosition(200, display.getTop(self) - 235)
			local star_list = {}
			local desc_txt_list = {}
			for i=1,3 do
				local star = self.star_panel:getChildByName("star_" .. i)
				if star then
					star:setVisible(false)
					star_list[i] = star
				end
				local desc_txt = self.star_panel:getChildByName("star_desc_" .. i)
				if desc_txt then
					desc_txt:setString("")
					_table_insert(desc_txt_list, desc_txt)
				end
			end
			return desc_txt_list, star_list
		end
	end
end

--添加boss血量ui
function BattleSceneNewView:addBoosHpUI()
	local res_list = {
        --{ path = PathTool.getPlistImgForDownLoad("actionyearmonster","actionyearmonster_result"), type = ResourcesType.plist },
        --{ path = PathTool.getPlistImgForDownLoad("actionwhitedaymonster", "actionwhitedaymonster"), type = ResourcesType.plist },
    } 
    self.resources_hp_load = ResourcesLoad.New(false) 
    self.resources_hp_load:addAllList(res_list, function()
    	if self.battle_boss_hp_progress == nil then
	        self.battle_boss_hp_progress = createCSBNote(PathTool.getTargetCSB("battle/battle_boss_hp_progress"))
	        self.battle_boss_hp_progress:setAnchorPoint(cc.p(0.5, 0))
		    self.battle_boss_hp_progress:setPosition(360, display.getTop(self) - 245)
		    self.ui_layer:addChild(self.battle_boss_hp_progress)
	    end
       	self.battle_boss_hp_progress:setVisible(false)
	    local  progress_container = self.battle_boss_hp_progress:getChildByName("progress_container")
	    self.hp_title = progress_container:getChildByName("hp_title")
	    self.hp_title:setString(TI18N("剩余血量:"))

	    self.boss_progress_o = progress_container:getChildByName("progress_o")
	    self.boss_progress_o:setPercent(0)
	    self.boss_progress = progress_container:getChildByName("progress")
	    self.boss_progress_size = self.boss_progress:getContentSize()
        --self.boss_progress_light_img = createImage(self.boss_progress, PathTool.getResFrame("actionwhitedaymonster", "actionwhitedaymonster_2"), 0, self.boss_progress_size.height / 2, cc.p(0.5,0.5), true, 1, true)
	    self.boss_progress:setPercent(100)
	    self.boss_hp_count = progress_container:getChildByName("hp_count")
	    self.boss_hp_count:setString("")
	    local head_panel = progress_container:getChildByName("head_panel")
	    self.hero_node = head_panel:getChildByName("hero_node")

	    local size = cc.size(72, 72)
	    local mask_res = PathTool.getResFrame("common", "common_1032") 
        local mask = createSprite(mask_res, size.width/2, size.height/2, nil, cc.p(0.5, 0.5))
        self.boss_icon_clipNode = cc.ClippingNode:create(mask)
        self.boss_icon_clipNode:setScale(0.94)
        self.boss_icon_clipNode:setAnchorPoint(cc.p(0.5,0.5))
        self.boss_icon_clipNode:setContentSize(size)
        self.boss_icon_clipNode:setCascadeOpacityEnabled(true)
        -- head_data.clipNode:setPosition(self.vSize.width/2,self.vSize.height/2 )--+ self.offest_y)
        self.boss_icon_clipNode:setAlphaThreshold(0)
        self.hero_node:addChild(self.boss_icon_clipNode, 2)

        self.boss_icon = ccui.ImageView:create()
        self.boss_icon:setScale(0.8)
        self.boss_icon:setCascadeOpacityEnabled(true)
        self.boss_icon:setAnchorPoint(0.5,0.5)
        self.boss_icon:setPosition(size.width/2,size.height/2)
        self.boss_icon_clipNode:addChild(self.boss_icon,3)
        self.boss_hp_max = 0
	    if self.boss_hp_updaet_event == nil then
	        self.boss_hp_updaet_event = GlobalEvent:getInstance():Bind(BattleEvent.Battle_Boss_Hp_Event, function(setting)
    			if not self.battle_boss_hp_progress then return end
	            self:updateBossUIInfo(setting)
	        end)
	    end
	end)
end

function BattleSceneNewView:updateBossUIInfo(setting)
	if not setting then  return end
    local show_type = setting.show_type
    if show_type == 1 then --表示头像信息
    	local head_icon = setting.head_icon
    	if self.boss_icon and head_icon then
        	local res = PathTool.getHeadIcon(head_icon)
        	self.boss_icon:loadTexture(res, LOADTEXT_TYPE)
        end
    elseif show_type == 2 then -- 表示血量信息
    	self.battle_boss_hp_progress:setVisible(true)
    	local battle_role = setting.battle_role
    	if battle_role  then
    		local hp = battle_role.hp or 0
    		local hp_max = battle_role.hp_max or 0
    		self.boss_hp_max = hp_max
        	if self.boss_progress and hp_max ~= 0 then
        		self.boss_progress:setPercent(hp * 100/hp_max)
        	end
        	if self.boss_hp_count then
        		self.boss_hp_count:setString(hp.."/"..hp_max)
        	end
        end
    elseif show_type == 3 then --表现血量变化信息
    	if self.boss_hp_max == 0 then return end
    	local percent = setting.percent
    	if percent then
    		if self.boss_progress then
        		self.boss_progress:setPercent(percent)
        	end
        	if self.boss_hp_count then
        		local hp = math.floor(self.boss_hp_max * percent/100)
        		self.boss_hp_count:setString(hp.."/"..self.boss_hp_max)
        	end
    	end
    end
end

function BattleSceneNewView:addYearMonsterUI(is_ignore)
	if (self.dunge_data[1] and self.dunge_data[1].param ~= ActionyearmonsterConstants.Evt_Type.Monster) or is_ignore then
		
		local res_list = {
	        --{ path = PathTool.getPlistImgForDownLoad("actionyearmonster","actionyearmonster_result"), type = ResourcesType.plist },
	        --{ path = PathTool.getPlistImgForDownLoad("actionwhitedaymonster", "actionwhitedaymonster"), type = ResourcesType.plist },
	    } 
	    self.resources_load = ResourcesLoad.New(false) 
	    self.resources_load:addAllList(res_list, function()
	    	if self.actionyearmonster_hp_progress == nil then
		        self.actionyearmonster_hp_progress = createCSBNote(PathTool.getTargetCSB("actionyearmonster/actionyearmonster_hp_progress"))
		        self.actionyearmonster_hp_progress:setAnchorPoint(cc.p(0.5, 0))
			    self.actionyearmonster_hp_progress:setPosition(360, display.getTop(self) - 215)
			    self.ui_layer:addChild(self.actionyearmonster_hp_progress)
		    end
	       
		    local  progress_container = self.actionyearmonster_hp_progress:getChildByName("progress_container")
		    self.year_progress_o = progress_container:getChildByName("progress_o")
		    self.year_progress_o:setPercent(0)
		    self.year_progress = progress_container:getChildByName("progress")
		    self.year_progress_size = self.year_progress:getContentSize()
            --self.progress_light_img = createImage(self.year_progress, PathTool.getResFrame("actionwhitedaymonster", "actionwhitedaymonster_2"), 0, self.year_progress_size.height / 2, cc.p(0.5,0.5), true, 1, true)
		    self.year_progress:setPercent(0)
		    self.year_hp_count = progress_container:getChildByName("hp_count")
		    self.year_hp_count:setString("0/0")
		    self.year_box_lev = progress_container:getChildByName("box_lev")
		    self.year_box_lev:setString("0")
		    self.record_box_count = 0
		    self.per_max = 0
		    self.cur_per = 0

		    self.year_box_effect = {}
		    -- self.year_box_effect_vs = {}
		    if self.year_progress_timer == nil then
			    self.year_progress_timer = GlobalTimeTicket:getInstance():add(function()
		            	self:updateYearProgress()
		        end, 0.02)
			end	   
			if is_ignore then
				local head_panel = progress_container:getChildByName("head_panel")
				local head_bg_0 = head_panel:getChildByName("head_bg_0")
				head_bg_0:setLocalZOrder(99)
				local head_id = ActionController:getInstance():getModel():getWhiteDayHeadId()
				self:setMonsterYearHead(head_panel, head_id)
			else
				self.year_monster_type = self.dunge_data[1].param 
			end
		end)
	end
end
function BattleSceneNewView:setMonsterYearHead(head_panel, head_id)
    local vSize = head_panel:getContentSize()
    head_panel.mask_res = PathTool.getResFrame("common", "common_1032") 
    if head_panel.mask_res ~= nil then
		head_panel.mark_bg = createSprite(head_panel.mask_res,vSize.width/2,vSize.height/2, head_panel, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 1)

		head_panel.mask = createSprite(head_panel.mask_res,vSize.width/2,vSize.height/2, nil, cc.p(0.5, 0.5))

		head_panel.clipNode = cc.ClippingNode:create(head_panel.mask)
		head_panel.clipNode:setAnchorPoint(cc.p(0.5,0.5))
		head_panel.clipNode:setContentSize(vSize)
		head_panel.clipNode:setCascadeOpacityEnabled(true)
		head_panel.clipNode:setPosition(vSize.width/2,vSize.height/2)
		head_panel.clipNode:setAlphaThreshold(0)
		head_panel:addChild(head_panel.clipNode,2)

		head_panel.icon = ccui.ImageView:create()
		head_panel.icon:setCascadeOpacityEnabled(true)
		head_panel.icon:setAnchorPoint(0.5,0.5)
		head_panel.icon:setPosition(vSize.width/2,vSize.height/2+2)
		head_panel.clipNode:addChild(head_panel.icon,3)
    end
    head_panel.clipNode:setScale(0.9)
    
    res = PathTool.getHeadIcon(head_id)
    head_panel.icon:loadTexture(res, LOADTEXT_TYPE)
end
--年兽伤害更新
function BattleSceneNewView:updateYearUIInfo(total_hurt)
	if not self.record_box_count  then return end
	if not self.actionyearmonster_hp_progress then return end
	local box_count, config, max_high
	if self.battle_type == BattleConst.Fight_Type.WhiteDayWar then
		--女神试炼的
		box_count, config, max_high = ActionController:getInstance():getModel():getHarmRewardInfo(total_hurt)
	else --默认是年兽的
		if not self.year_monster_type  then return end
		box_count, config, max_high = ActionyearmonsterController:getInstance():getModel():getHarmRewardInfo(total_hurt, self.year_monster_type)
	end
	
	
	if box_count > 0 and config then
		local dps_high = config.dps_low or config.max
		local dps_low = config.dps_low or config.min
		local low = (total_hurt - dps_low)
		local high = (dps_high - dps_low) 
		local per = low*100/high
		self.year_progress_o:setPercent(per)
		self:updateYearProgress(per)
		if self.battle_type == BattleConst.Fight_Type.WhiteDayWar then 
			--if self.year_progress_size and self.progress_light_img then
			--	if low > 0 then
		    --        self.progress_light_img:setVisible(true)
		    --        self.progress_light_img:setPositionX(self.year_progress_size.width * low/high)
		    --    else
		    --        self.progress_light_img:setVisible(false)
		    --    end
		    --end
		end

		self.year_hp_count:setString(_string_format("%s/%s", total_hurt, dps_high))
		local count = box_count - 1
		self.year_box_lev:setString(count)

		local num = count - self.record_box_count
		if num > 0 then
			local index = self.record_box_count
			for i=1, num do
				self:updateYearBoxEffect( index + i)
			end
		end
		
	end
end

function BattleSceneNewView:updateYearProgress(per)
    if per ~= nil then
    	self.per_max = per
    	if self.cur_per > self.per_max then
    		self.cur_per = 0
    	end
    end 
    if self.cur_per < self.per_max then
    	local speed = (self.per_max - self.cur_per) * 0.05
    	if speed < 0.2 then
    		speed = 0.2
    	end
    	self.cur_per = self.cur_per + speed
    	if self.cur_per > self.per_max then
    		self.cur_per = self.per_max
    	end
    	if self.year_progress then
    		self.year_progress:setPercent(self.cur_per)
    	end
   	end 
end

function BattleSceneNewView:updateYearBoxEffect(count)
	if not self.year_box_effect  then return end
	if self.is_show_action8 then return end
	self.record_box_count = count
	if count > 0 then
		local index = (count - 1) % 7 + 1
		local action = "action"..index
		if self.year_box_effect[index] == nil then
			if index == 7 then
				self.year_box_effect[index] = createEffectSpine("E27704", cc.p(0, display.getBottom(self)), cc.p(0.5, 0.5), false, action, function()
                	self:endYearEffect()
            	end)
			else
				self.year_box_effect[index] = createEffectSpine("E27704", cc.p(0, display.getBottom(self)), cc.p(0.5, 0.5), false, action)
			end
			self.ui_layer:addChild(self.year_box_effect[index])
		else
			if not self.year_box_effect[index]:isVisible() then 
				self.year_box_effect[index]:setVisible(true)
				self.year_box_effect[index]:setAnimation(0, action, false)
			end
		end
	end
end

function BattleSceneNewView:endYearEffect()
	if not self.year_box_effect  then return end
	if self.is_show_action8 then
		for i,v in pairs(self.year_box_effect) do
			v:setVisible(false)
		end
		self.is_show_action8 = false
	else
		for i,v in pairs(self.year_box_effect) do
			if i == 7 then
				self.is_show_action8 = true
				v:setAnimation(0, "action8", false)
			else
				v:setVisible(false)
			end
		end
	end
end

function BattleSceneNewView:addSandybeachBossFightUI()
	local desc_txt_list, star_list = self:getStarPanelUI()
	if desc_txt_list and star_list then
		for i=1,3 do
			local star = self.star_panel:getChildByName("gary_star_" .. i)
			if star then
				star:setVisible(false)
			end
		end
		if not self.dunge_data[1] then return end
		local id = self.dunge_data[1].param or 1
		local config = Config.HolidayBossData.data_boss_info(id)
		if config then
			for i=1,3 do
				if desc_txt_list[i] then
					desc_txt_list[i]:setPositionX(12)
					if i == 1 then
						desc_txt_list[i]:setString(TI18N("关卡效果:"))
					else
						if config.add_skill_decs[i-1] then
							desc_txt_list[i]:setString(config.add_skill_decs[i-1])
						end
					end
				end
			end
		end
	end
end

--
function BattleSceneNewView:addLimitExerciseBossFightUI()
	local desc_txt_list, star_list = self:getStarPanelUI()
	if desc_txt_list and star_list then
		for i=1,3 do
			local star = self.star_panel:getChildByName("gary_star_" .. i)
			if star then
				star:setVisible(false)
			end
		end
		if self.dunge_data[1] and self.dunge_data[2] and self.dunge_data[3] and self.dunge_data[4] then
			local round = self.dunge_data[1].param or 1
			local diff = self.dunge_data[2].param or 1
			local order_type = self.dunge_data[3].param or 1
			local order_id = self.dunge_data[4].param or 1

			local boss_list = Config.HolidayBossNewData.data_change_boss_list
			if boss_list[round] and boss_list[round][diff] and boss_list[round][diff][order_type] and boss_list[round][diff][order_type][order_id] then
				local config = boss_list[round][diff][order_type][order_id]
				if config then
					for i=1,3 do
						if desc_txt_list[i] then
							desc_txt_list[i]:setPositionX(12)
							if i == 1 then
								desc_txt_list[i]:setString(TI18N("关卡效果:"))
							else
								if config.add_skill_decs[i-1] then
									desc_txt_list[i]:setString(config.add_skill_decs[i-1])
								end
							end
						end
					end
				end
			end
		end
	end
end

-- 天界副本
function BattleSceneNewView:addHeavenStarUI(  )
	local is_show_exit = false
	for i,v in ipairs(self.dunge_data) do
		if i == 1 then
			self.heaven_chapter_id = v.param -- 天界副本战斗的章节id
		elseif i == 2 then
			self.heaven_customs_id = v.param -- 天界副本战斗的关卡id
		elseif i == 6 and v.param ~= 1 then
			is_show_exit = true
		end
	end
	if is_show_exit then
		self:addExitBtnUI()
	end
end

-- 更新天界副本星数显示
function BattleSceneNewView:updateHeavenStarInfo( star_status_list )
	if not self.heaven_chapter_id or not self.heaven_customs_id then return end
	if self.battle_type ~= BattleConst.Fight_Type.HeavenWar then return end

	self.star_status_list = star_status_list or {}
	local chapter_data = Config.DungeonHeavenData.data_customs[self.heaven_chapter_id] or {}
	local customs_data = chapter_data[self.heaven_customs_id]
	if not self.desc_txt_list or not self.star_node_list then
		self.desc_txt_list, self.star_node_list = self:getStarPanelUI()
	end
	if customs_data and self.desc_txt_list and self.star_node_list then
		for i,v in ipairs(customs_data.cond_info) do
			local star_id = v[1]
			local con_id = v[2]
			local desc_txt = self.desc_txt_list[i]
			local con_data = Config.DungeonHeavenData.data_star_cond[con_id]
			if desc_txt and con_data then
				desc_txt:setString(con_data.type)
			end
			local star = self.star_node_list[i]
			if star then
				local star_status = self:checkHeavenStarIsOpen(star_id)
	            star:setVisible(star_status)
			end
		end
	end
end

function BattleSceneNewView:checkHeavenStarIsOpen( star_id )
	local is_open = false
	for k,v in pairs(self.star_status_list) do
		if v.id == star_id then
			is_open = (v.val == 1)
			break
		end
	end
	return is_open
end

-- 更新跳过队伍一显示
function BattleSceneNewView:updateSkipTeamBtnStatus(  )
	if not self.skip_team_btn then return end
	if self.battle_type == BattleConst.Fight_Type.HeavenWar then
		local is_show_skip = false
		for i,v in pairs(self.dunge_data) do
			if i == 9 and v.param == 1 then
				is_show_skip = true
			end
		end
		self.skip_team_btn:setVisible(is_show_skip)
	end
end

-- 多场次胜败状态（跨服竞技场）
function BattleSceneNewView:addSessionStatusUI(  )
	if self.ui_layer and not _tolua_isnull(self.ui_layer) then
		if _tolua_isnull(self.session_panel) then
			self.session_panel = createCSBNote(PathTool.getTargetCSB("battle/battle_team_status_panel"))
			self.session_panel:setAnchorPoint(cc.p(0.5, 0))
			self.ui_layer:addChild(self.session_panel)
			self.session_panel:setPosition(self.main_size.width*0.5, display.getTop(self) - 155)

			self.session_list = {}
			for i=1,3 do
				local object = {}
				object.sp_icon = self.session_panel:getChildByName("sp_icon_" .. i)
				object.sp_status = self.session_panel:getChildByName("sp_status_" .. i)
				_table_insert(self.session_list, object)
			end

			self.session_txt = self.session_panel:getChildByName("txt_session")
		end

		local cur_session = 1 -- 当前局数
		local session_status_list = {} -- 三场的胜负情况
		for i,v in ipairs(self.dunge_data) do
			if i == 1 then
				cur_session = v.param
			elseif i == 2 then
				_table_insert(session_status_list, v.param)
			elseif i == 3 then
				_table_insert(session_status_list, v.param)
			elseif i == 4 then
				_table_insert(session_status_list, v.param)
			end
		end
		self.session_txt:setString(_string_format(TI18N("当前:第%d局"), cur_session))
		if self.session_list then
			for i,object in ipairs(self.session_list) do
				local status = session_status_list[i]
				if status then
					if object.sp_icon then
						setChildUnEnabled((status ~= 1), object.sp_icon)
					end
					if status ~= 0 and cur_session > i then
						local status_res
						if status == 1 then -- 胜利
							status_res = PathTool.getResFrame("common", "txt_cn_common_90012")
						elseif status == 2 then -- 失败
							status_res = PathTool.getResFrame("common", "txt_cn_common_90013")
						elseif status == 3 then -- 平局
							status_res = PathTool.getResFrame("common", "txt_cn_common_90026")
						end
						if status_res and object.sp_status then
							loadSpriteTexture(object.sp_status, status_res, LOADTEXT_TYPE_PLIST)
							object.sp_status:setVisible(true)
						end
						object.sp_icon:setVisible(true)
					elseif object.sp_status then
						object.sp_status:setVisible(false)
						object.sp_icon:setVisible(false)
					end
				end
			end
		end
	end
end

--创建等级tips
function BattleSceneNewView:createLevTips(suppress)
	-- local avg_lev = BattleController:getInstance():getSumlev() or 0 --平均
	-- local avg_enemy_lev = BattleController:getInstance():getEnemySumlev() or 0 --平均
	-- local res = PathTool.getResFrame('battle', 'battle_lev_bg_' .. suppress)
	-- if not self.tips_lev_bg then
	-- 	self.tips_lev_bg = createImage(self.ui_layer, res, self.main_size.width - 27, _main_controller:getBottomHeight() + 26, cc.p(0.5, 0.5), true)
	-- 	self.tips_lev_bg:setTouchEnabled(true)
	-- 	self.tips_lev_bg:addTouchEventListener(function(sender, event_type)
	-- 		customClickAction(sender, event_type)
	-- 		if event_type == ccui.TouchEventType.ended then
	-- 			playButtonSound()
	-- 			local str = TI18N("等级压制：怪物<div fontcolor=#3dbf5f>平均等级<div>超过己方宝可梦平均等级时，怪物<div fontcolor=#3dbf5f>伤害和免伤</div>提升，高出等级越多提升越大")--<div>怪物等级超过玩家宝可梦等级<div fontcolor=#289b14>5<div>级后，超过的每一级，怪物伤害提升<div fontcolor=#289b14>3%<div>，免伤提升<div fontcolor=#289b14>1%<div><div>")
	-- 			TipsManager:getInstance():showCommonTips(str, sender:getTouchBeganPosition())
	-- 		end
	-- 	end)
	-- end
end

-- 创建查看目标
function BattleSceneNewView:createLookupTarget()
	-- local res = PathTool.getResFrame('battle', 'battle_lev_bg_3')
	-- if not self.lookup_target_btn then
	-- 	self.lookup_target_btn = createImage(self.ui_layer, res, self.main_size.width - 43, _main_controller:getBottomHeight() + 166, cc.p(0.5, 0.5), true)
	-- 	self.lookup_target_btn:setTouchEnabled(true)
	-- 	self.lookup_target_btn:addTouchEventListener(function(sender, event_type)
	-- 		local info = _model:getEnemyInfo()
	-- 		if event_type == ccui.TouchEventType.ended and info and info.rid > 0 then
	-- 			FriendController:getInstance():openFriendCheckPanel(true, info)
	-- 		end
	-- 	end)
	-- end
end

function BattleSceneNewView:createAutoCombatIcon()
	if true then return end -- 屏蔽自动推图按钮
	if not _main_controller:checkIsInDramaUIFight() then return end
	if self.auto_combat_btn == nil then
		self.auto_combat_btn = createButton(self.ui_main_layer, TI18N("自动"), self.main_size.width - 44, _main_controller:getBottomHeight() + 192, cc.size(79, 79), PathTool.getResFrame("battle", "battle_btn_7"), 20, Config.ColorData.data_color4[1])
		self.auto_combat_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				if self.auto_combat_btn.status == 3 then
					_drama_controller:send13003(1)
				elseif self.auto_combat_btn.status == 4 then
					local str = TI18N("开启“自动推图”后队伍将不断挑战下一关卡（离线不会中断），直到战斗失败或背包满格，是否确定自动战斗？")
					local function fun()
						_drama_controller:send13003(1)
					end
					CommonAlert.show(str, TI18N("确认"), fun, TI18N("取消"), nil, CommonAlert.type.rich, nil, nil, nil, true)
				elseif self.auto_combat_btn.status == 2 then
					local config = Config.DungeonData.data_drama_dungeon_info(Config.DungeonData.data_drama_const.auto_combat_dun_id.val)
					message(string.format(TI18N("通关%s开启"), config.name))
				else
					message(string.format(TI18N("冒险者达%s级后开启"), Config.DungeonData.data_drama_const.auto_combat_lev.val))
				end
			end
		end, true)
	end
	local quickdata = _drama_model:getQuickData()
	if quickdata.is_auto_combat == 1 then
		self.auto_combat_btn.status = 3
		self.auto_combat_btn:setBtnLabel(TI18N("取消\n自动"))
		self.auto_combat_btn:getButton():runAction(cc.RepeatForever:create(cc.RotateBy:create(4, 360)))
	else
		self.auto_combat_btn.status = 4
		self.auto_combat_btn:setBtnLabel(TI18N("自动\n推图"))
		self.auto_combat_btn:getButton():stopAllActions()
	end
	local role_vo = RoleController:getInstance():getRoleVo()
	local drama_data = _drama_model:getDramaData()
	if role_vo and Config.DungeonData.data_drama_const.auto_combat_lev.val > role_vo.lev then
		self.auto_combat_btn:setRichText(string.format(TI18N("<div fontcolor=#ffffff outline=2,#000000>%s级开启</div>"), Config.DungeonData.data_drama_const.auto_combat_lev.val), 18, 1, 100)
		self.auto_combat_btn.rich_label:setPosition(- 1, 18)
		self.auto_combat_btn.btn_label:setVisible(true)
		self.auto_combat_btn.status = 1
		self.auto_combat_btn:setGrayAndUnClick(true, 0)
		self.auto_combat_btn:enableOutline(cc.c4b(90, 90, 90, 255), 2)
	elseif drama_data and Config.DungeonData.data_drama_const.auto_combat_dun_id.val > drama_data.max_dun_id then
		local config = Config.DungeonData.data_drama_dungeon_info(Config.DungeonData.data_drama_const.auto_combat_dun_id.val)
		self.auto_combat_btn:setRichText(TI18N("<div fontcolor=#ffffff outline=2,#000000>未开启</div>"), 18, 1, 300)
		self.auto_combat_btn.rich_label:setPositionY(6)
		self.auto_combat_btn.btn_label:setVisible(true)
		self.auto_combat_btn.status = 2
		self.auto_combat_btn:setGrayAndUnClick(true, 0)
		self.auto_combat_btn:enableOutline(cc.c4b(90, 90, 90, 255), 2)
	else
		self.auto_combat_btn:setGrayAndUnClick(false)
		self.auto_combat_btn:enableOutline(cc.c4b(90, 44, 0, 255), 2)
	end
end

function BattleSceneNewView:clearBuffIcon(...)
	if self.battle_buff_object then
		if not _tolua_isnull(self.battle_buff_object.container) then
			self:clearDieTimer()
			self.battle_buff_object.container:removeFromParent()
		end
		self.battle_buff_object = nil
	end
end

--创建buffIcon
function BattleSceneNewView:createBuffIcon(buff_data)
	if not buff_data then return end
	if next(buff_data.buff_list or {}) == nil then
		self:clearBuffIcon()
		return
	end
	self.room_buff_data = buff_data.buff_list
	
	-- 只取出第一个
	local buff_vo = self.room_buff_data[1]
	if buff_vo and Config.BuffData.data_get_buff_data[buff_vo.bid] then
		if self.battle_buff_object == nil then
			self.battle_buff_object = {}
			
			local container = createCSBNote(PathTool.getTargetCSB("battle/battle_buff_icon"))
			container:setAnchorPoint(0, 0)
			container:setPosition(self.main_size.width-118, self.main_size.height/2+90)
			self.ui_main_layer:addChild(container)
			local icon = container:getChildByName("icon")
			local num_label = container:getChildByName("num_label")
			local desc_label = container:getChildByName("desc_label")
			
			self.battle_buff_object.container = container 			-- 父节点
			self.battle_buff_object.buff_icon = icon 				-- 资源
			self.battle_buff_object.buff_time = num_label 			-- 时间倒计时
			self.battle_buff_object.buff_desc = desc_label 			-- 描述
		end
		
		local config = Config.BuffData.data_get_buff_data[buff_vo.bid]
		if config then
			local battle_buff_icon_res = PathTool.getBuffRes(config.icon)
			if battle_buff_icon_res ~= self.battle_buff_object.buff_res then
				self.battle_buff_object.buff_res = battle_buff_icon_res
				loadSpriteTexture(self.battle_buff_object.buff_icon, battle_buff_icon_res, LOADTEXT_TYPE)
			end
			local time = buff_vo.end_time - GameNet:getInstance():getTime()
			self.battle_buff_object.time = time
			self.battle_buff_object.buff_desc:setString(config.des)
		end
		
		self:clearDieTimer()
		if self.die_timer == nil then
			self.die_timer = GlobalTimeTicket:getInstance():add(function()
				self:handleDieTimer()
			end, 1)
		end
	end
end

function BattleSceneNewView:handleDieTimer()
	if self.battle_buff_object and self.battle_buff_object.time then
		if not _tolua_isnull(self.battle_buff_object.buff_time) then
			self.battle_buff_object.time = self.battle_buff_object.time - 1
			self:updateBuffTimer(self.battle_buff_object.buff_time, self.battle_buff_object.time)
		end
	end
end

function BattleSceneNewView:updateBuffTimer(label, time)
	local temp_time = time
	if temp_time and label then
		if temp_time > 0 then
			label:setString(TimeTool.GetTimeMS(time))
		else
			label:setString("00:00")
		end
	end
end

--Boss来袭提示
function BattleSceneNewView:floorTips(call_back, data)
	local combat_config = Config.CombatTypeData.data_fight_list[self.battle_type]
	if combat_config then
		self.call_back = call_back

		if BattleConst.isNeedSpecStart(self.battle_type) then
			-- 跨服竞技场特殊处理，只在第一局开始时才显示 VS 动画
			if self.battle_type == BattleConst.Fight_Type.CrossArenaWar then
				local cur_session = 1 -- 当前局数
				for k,v in pairs(self.dunge_data or {}) do
					if k == 1 then
						cur_session = v.param
						break
					end
				end
				if cur_session == 1 then
					self:showSpecStart(self.call_back, data)
				else
					self.call_back()
				end
			else
				self:showSpecStart(self.call_back, data)
			end
		else
			local start_effect = combat_config.start_effect		
			-- 剧情副本特殊处理
			if self.battle_type == BattleConst.Fight_Type.Darma then
				local drama_data = _drama_model:getDramaData()
				if drama_data and drama_data.dun_id then
					local dun_config = Config.DungeonData.data_drama_dungeon_info(drama_data.dun_id) or {}
					if dun_config.is_big ~= 1 then -- 不是大关卡
						start_effect = "E51147"
					end
				end
			end
			playEffectOnce(start_effect, self.main_size.width * 0.5, 770, self.ui_layer, function()
				if self.call_back then
					self.call_back()
				end
			end, nil, nil, nil, PlayerAction.action, 1, true)
		end
	else
		if self.call_back then
			self.call_back()
		end
	end
end

function BattleSceneNewView:showSpecStart(call_back, data)
	if self.spec_tips then
		self.spec_tips:stopAllActions()
		self.spec_tips:removeAllChildren()
		self.spec_tips = nil
	end
	if not data then return end
	local form_info = {}
	
	if data then
		for i, v in pairs(data.formation) do
			form_info[v.group] = {v.formation_type or 1, v.formation_lev or 0}
		end
	end
	if not self.spec_tips then
		self.spec_tips = ccui.Layout:create()
		self.spec_tips:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
		self.spec_tips:setAnchorPoint(cc.p(0.5, 0.5))
		self.spec_tips:setPosition(self.main_size.width / 2, self.main_size.height / 2)
		self.spec_tips:setScale(display.getMaxScale())
		showLayoutRect(self.spec_tips, 155)
		self.ui_layer:addChild(self.spec_tips)
	end
	if self.spec_tips then
		local left_y = SCREEN_HEIGHT * 0.5 + 100
		local right_y = SCREEN_HEIGHT * 0.5 - 100
		
		self.left_bg = ccui.Layout:create()
		self.left_bg:setContentSize(399, 56)
		self.left_bg:setAnchorPoint(cc.p(1, 0.5))
		self.left_bg:setPosition(0, left_y)
		self.spec_tips:addChild(self.left_bg)
		local left_img = createSprite(PathTool.getResFrame("battle", "battle_star_bg"), 0, 28, self.left_bg, cc.p(0, 0.5), LOADTEXT_TYPE_PLIST)
		left_img:setScale(4)
		local left_zhenfa_quan = createSprite(PathTool.getResFrame("battle", "battle_zhenfa_quan"), 120, 27, self.left_bg, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
		if form_info and form_info[1] and form_info[1] [1] then
			local left_form_icon = createSprite(PathTool.getResFrame("battle", "battle_form_icon_" .. form_info[1] [1]), 120, 27, self.left_bg, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
		end
		self.left_name = createLabel(26, cc.c4b(255, 245, 212, 255), nil, 150, self.left_bg:getContentSize().height / 2, data.actor_role_name, self.left_bg, 2, cc.p(0, 0.5))
		
		self.right_bg = ccui.Layout:create()
		self.right_bg:setContentSize(399, 56)
		self.right_bg:setAnchorPoint(cc.p(0, 0.5))
		self.right_bg:setPosition(self.main_size.width, right_y)
		self.spec_tips:addChild(self.right_bg)
		
		local right_img = createSprite(PathTool.getResFrame("battle", "battle_star_bg"), 0, 28, self.right_bg, cc.p(0, 0.5), LOADTEXT_TYPE_PLIST)
		right_img:setScale(4)
		local roght_zhenfa_quan = createSprite(PathTool.getResFrame("battle", "battle_zhenfa_quan"), 120, 27, self.right_bg, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
		if form_info and form_info[2] and form_info[2] [1] then
			local right_form_icon = createSprite(PathTool.getResFrame("battle", "battle_form_icon_" .. form_info[2] [1]), 120, 27, self.right_bg, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
		end
		self.right_name = createLabel(26, cc.c4b(255, 245, 212, 255), nil, 150, self.right_bg:getContentSize().height / 2, data.target_role_name, self.right_bg, 2, cc.p(0, 0.5))
		
		self.left_bg:runAction(cc.Sequence:create(cc.MoveTo:create(0.4, cc.p(520, left_y)), cc.CallFunc:create(function(...)
			self:showEffect(form_info)
		end),
		
		cc.DelayTime:create(2),
		cc.CallFunc:create(function()
			self:clearSpeEffect()
			if self.spec_tips and not _tolua_isnull(self.spec_tips) then
				self.spec_tips:stopAllActions()
				self.spec_tips:removeAllChildren()
				self.spec_tips:removeFromParent()
				self.spec_tips = nil
			end
			if call_back then
				call_back()
			end
		end)
		))
		self.right_bg:runAction(cc.Sequence:create(cc.MoveTo:create(0.4, cc.p(200, right_y)), cc.DelayTime:create(0.5), cc.CallFunc:create(function(...)
			self:showRightEffect(form_info)
		end)))
	end
end

function BattleSceneNewView:showEffect(form_info)
	self:clearSpeEffect()
	if not self.left_effect then
		self.left_effect = createEffectSpine(PathTool.getEffectRes(321), cc.p(self.left_bg:getContentSize().width / 2, self.left_bg:getContentSize().height / 2), cc.p(0.5, 0.5), false, PlayerAction.action_1)
		self.left_effect:setScale(- 1)
		self.left_bg:addChild(self.left_effect)
	end
	if not self.spec_effect_2 then
		self.spec_effect_2 = createEffectSpine(PathTool.getEffectRes(321), cc.p(self.spec_tips:getContentSize().width / 2, SCREEN_HEIGHT * 0.5), cc.p(0.5, 0.5), false, PlayerAction.action_2)
		self.spec_tips:addChild(self.spec_effect_2)
	end
end

function BattleSceneNewView:showRightEffect(form_info)
	if not self.right_effect then
		self.right_effect = createEffectSpine(PathTool.getEffectRes(321), cc.p(self.right_bg:getContentSize().width / 2, self.right_bg:getContentSize().height / 2), cc.p(0.5, 0.5), false, PlayerAction.action_1)
		self.right_effect:setScale(- 1)
		self.right_bg:addChild(self.right_effect)
	end
end

function BattleSceneNewView:clearSpeEffect()
	if self.left_effect then
		self.left_effect:runAction(cc.RemoveSelf:create(true))
		self.left_effect = nil
	end
	if self.spec_effect_2 then
		self.spec_effect_2:runAction(cc.RemoveSelf:create(true))
		self.spec_effect_2 = nil
	end
	if self.right_effect then
		self.right_effect:runAction(cc.RemoveSelf:create(true))
		self.right_effect = nil
	end
end

--是否显示面板
function BattleSceneNewView:setWait(bool)
	if self.round_time_widget and not _tolua_isnull(self.round_time_widget) then
		if bool == true then
			self.round_time_widget:setVisible(true)
		else
			self.round_time_widget:setVisible(false)
		end
	end
end

-- 退出按钮
function BattleSceneNewView:addExitBtnUI( )
	if self.leave_btn == nil then
		local btn_res = PathTool.getResFrame("battle", "battle_exit")
		if self.battle_type == BattleConst.Fight_Type.HeavenWar then
			--btn_res = PathTool.getResFrame("battle", "txt_cn_exit_battle_2")
		end
		self.leave_btn = createButton(self.ui_layer, "", 0, 0, nil, btn_res, 24)
		local top_view_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
		if self.battle_type == BattleConst.Fight_Type.Darma then
			self.leave_btn:setPosition(self.main_size.width-120, self.main_size.height/2+240)
		else
			self.leave_btn:setPosition(self.main_size.width-60, self.main_size.height-top_view_height-40)
		end
		self.leave_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				if self.battle_type == BattleConst.Fight_Type.HeavenWar then
					local str = TI18N("若退出本场战斗则无法获得奖励，确定要退出吗？\n                          （本场不消耗挑战次数）")                
		            CommonAlert.show( str, TI18N("我要退出"), function()
		               _controller:csFightExit()
		            end, TI18N("继续挑战"), nil, CommonAlert.type.rich)
				else
					_controller:csFightExit()
				end
			end
		end)
	end

end

--公会副本额外UI
function BattleSceneNewView:addGuildBossUI(fight_type, total_hurt)
	if fight_type == BattleConst.Fight_Type.GuildDun or fight_type == BattleConst.Fight_Type.MonopolyBoss then
		if not self.guild_boss_view then
			self.guild_boss_view_size = cc.size(SCREEN_WIDTH, 100)
			self.guild_boss_view = ccui.Widget:create()
			self.guild_boss_view:setContentSize(self.guild_boss_view_size)
			self.guild_boss_view:setAnchorPoint(cc.p(0, 1))
			self.guild_boss_view:setPosition(display.getLeft(self), self.main_size.height/2+340)
			self.guild_boss_view:setCascadeOpacityEnabled(true)
			self.ui_main_layer:addChild(self.guild_boss_view)
			
			local pos_y = 50

			self.total_hurt = createSprite(PathTool.getTargetRes("battle/txt_battle","txt_cn_battle_total_hurt",false,false),self.guild_boss_view_size.width / 2, pos_y, self.guild_boss_view, cc.p(1, 1),LOADTEXT_TYPE)
			--self.total_hurt = createSprite(PathTool.getResFrame("battle", "txt_cn_battle_total_hurt"), self.guild_boss_view_size.width / 2, pos_y, self.guild_boss_view, cc.p(1, 1))
			self.total_hurt:setVisible(true)
			self.get_label = createRichLabel(28, 1, cc.p(0, 1), cc.p(self.total_hurt:getPositionX() + 5, pos_y), nil, nil, 200)
			self.guild_boss_view:addChild(self.get_label)
		end
		if total_hurt ~= nil then
			self.get_label:setString(_string_format("<div fontcolor=#ffffff outline=2,#401f0e>%s</div>", total_hurt))
		end
	end
end

function BattleSceneNewView:addGuildSecretAreaUI()
	if self.ui_main_layer then
		local x = SCREEN_WIDTH * 0.5
		local y = self.main_size.height/2+420
		local bg = createImage(self.ui_main_layer, PathTool.getResFrame("common", "common_90056"), x, y, cc.p(0.5, 0.5), true, nil ,true)
    	bg:setContentSize(cc.size(500, 74))
		local str1 = TI18N("秘境Boss免疫【封印】且每回合攻击递增")
		local str2 = TI18N("在第10回合进入爆发状态并将造成大量伤害")
		local tips1 = createLabel(20,cc.c4b(0xff,0xff,0xff,0xff),cc.c4b(0x40,0x1f,0x0e,0xff), x, y + 13, str1,self.ui_main_layer, 2, cc.p(0.5,0.5))
		local tips2 = createLabel(20,cc.c4b(0xff,0xff,0xff,0xff),cc.c4b(0x40,0x1f,0x0e,0xff), x, y - 13, str2,self.ui_main_layer, 2, cc.p(0.5,0.5))
		-- breatheShineAction(tips1, 1.5, 0.5)
		-- breatheShineAction(tips2, 1.5, 0.5)
		-- self.tips_label = createRichLabel(20, 1, cc.p(0.5, 1), cc.p(x, y), nil, nil, 720)
		-- self.ui_main_layer:addChild(self.tips_label)
		-- self.tips_label:setString(TI18N("<div fontcolor=#ffffff outline=2,#401f0e>\n在第10回合进入爆发状态并将造成大量伤害</div>"))
	end
end

--精英赛ui
function BattleSceneNewView:addEliteMatchUI(fight_type)
	if fight_type == BattleConst.Fight_Type.EliteKingMatchWar and self.dunge_data then
		self.elitematch_bg = createScale9Sprite(PathTool.getResFrame("common", "common_90056"))
		self.elitematch_bg:setScale9Enabled(true)
		local size = cc.size(315, 80)
		self.elitematch_bg:setContentSize(size)
		self.elitematch_bg:setPosition(SCREEN_WIDTH * 0.5, self.main_size.height/2+280)
		self.ui_main_layer:addChild(self.elitematch_bg)

		local str1 , str2 
		if self.dunge_data[1] then
			str1 = _string_format(TI18N("第%s场"), self.dunge_data[1].param) 
		else
			str1 = TI18N("第1场")
		end
		if self.dunge_data[2] and self.dunge_data[3] then
			str2 = _string_format(TI18N("%s:%s"), self.dunge_data[2].param, self.dunge_data[3].param) 
		else
			str2 = "0:0"
		end
		self.elitematch_label1 = createLabel(26,cc.c4b(0xff,0xf2,0xc7,0xff),nil,size.width * 0.5 , size.height * 0.7 ,str1,self.elitematch_bg,nil, cc.p(0.5,0.5))
		self.elitematch_label2 = createLabel(22,cc.c4b(0xff,0xf2,0xc7,0xff),nil,size.width * 0.5 , size.height * 0.3 ,str2,self.elitematch_bg,nil, cc.p(0.5,0.5))
	end
end

--精英赛宣言ui
--@ fight_type 战斗类型 
--@show_type 显示类型 1 战前  2 战后
--@scdata  20006 协议
function BattleSceneNewView:addEliteDeclarationUI(fight_type, show_type, scdata)
	if not self.dunge_data then return end
	if not self.form_view then return end
	if fight_type == BattleConst.Fight_Type.EliteMatchWar or fight_type == BattleConst.Fight_Type.EliteKingMatchWar then
		local show_type = show_type or 1
		local left_id
		local right_id 

		local _getIDByIndex = function(index)
			if self.dunge_data[index] then
				return self.dunge_data[index].param
			end
			return 0
		end
		--已后端协议  索引 4,5 表示我 ,敌的站前宣言
		--已后端协议  索引 6,7 表示我 ,敌的胜利宣言
		--已后端协议  索引 8,9 表示我 ,敌的失败宣言
		if show_type == 1 then
			--战前的
			left_id = _getIDByIndex(4)
			right_id = _getIDByIndex(5)
		else
			if scdata then
				if scdata.result == 1 then --我方胜利
					left_id = _getIDByIndex(6)
					right_id = _getIDByIndex(9)
				else
					left_id = _getIDByIndex(8)
					right_id = _getIDByIndex(7)
				end
			end
		end
		
		local _runDisappearAction = function(object, show_type, is_left)
			if not object then return end
			object:setOpacity(0)
			local action1 = cc.FadeIn:create(0.5)
			local action2 = cc.DelayTime:create(3)
			local action3 = cc.FadeOut:create(0.5)
			object:runAction(cc.Sequence:create(action1,action2, action3, cc.CallFunc:create(function() 
				object:setVisible(false)
				self:removeDeclarationSpine(show_type, is_left)
			end)))
		end

		local _addFace = function(id, is_left)
			local config = Config.ArenaEliteData.data_face[id]
			if config then
				local spine = createEffectSpine(config.msg, nil , cc.p(0.5, 0.5), false, PlayerAction.action)
				if is_left then --左边
		        	spine:setScaleX(-1)
			    	spine:setPosition(230, 102)
			    else --右边
			    	spine:setPosition(488, 102)
			    end
	        	self.form_view:addChild(spine)
	        	return spine
	        end
		end
		if left_id ~= nil and left_id ~= 0 then
			if self.declaration_spine_left_list == nil then
				self.declaration_spine_left_list = {}
			end
			self.declaration_spine_left_list[show_type] = _addFace(left_id, true)
			--_runDisappearAction(self.declaration_spine_left_list[show_type], show_type, true)
		end

		if right_id ~= nil and right_id ~= 0 then
			if self.declaration_spine_right_list == nil then
				self.declaration_spine_right_list = {}
			end
			self.declaration_spine_right_list[show_type] = _addFace(right_id)
			--_runDisappearAction(self.declaration_spine_right_list[show_type], show_type)
		end
	end
end

function BattleSceneNewView:removeDeclarationSpine(show_type, is_left)
	if not show_type then return end
	if is_left then
		if self.declaration_spine_left_list and self.declaration_spine_left_list[show_type] then
			self.declaration_spine_left_list[show_type]:clearTracks()
            self.declaration_spine_left_list[show_type]:removeFromParent()
			self.declaration_spine_left_list[show_type] = nil
		end
	else
		if self.declaration_spine_right_list and self.declaration_spine_right_list[show_type] then
			self.declaration_spine_right_list[show_type]:clearTracks()
            self.declaration_spine_right_list[show_type]:removeFromParent()
			self.declaration_spine_right_list[show_type] = nil
		end
	end
end


function BattleSceneNewView:clearDieTimer()
	if self.die_timer ~= nil then
		GlobalTimeTicket:getInstance():remove(self.die_timer)
		self.die_timer = nil
	end
end

function BattleSceneNewView:updateBtnLayerStatus(status)
	_drama_controller:updateBtnLayerStatus(status)
end

--[[	@desc: 更新战斗北京,有可能是剧情章节更新了,这个时候需要切换地图了
    author:{author}
    time:2018-10-02 15:11:45
    --@map_bg_res:
	--@f_bg_res:
	--@effect_res: 作废 不处理了
    @return:
]]
function BattleSceneNewView:updateBg(map_bg_res, f_bg_res, effect_res)
	if self.map_bg_res_id ~= map_bg_res then
		self.map_bg_res_id = map_bg_res
		if self.map_bg and not _tolua_isnull(self.map_bg) then
			loadSpriteTexture(self.map_bg, map_bg_res, LOADTEXT_TYPE)
		end
		if self.map_bg_2 and not _tolua_isnull(self.map_bg_2) then
			loadSpriteTexture(self.map_bg_2, map_bg_res, LOADTEXT_TYPE)
		end
	end
	
	if self.f_bg_res_id ~= f_bg_res then
		self.f_bg_res_id = f_bg_res
		if self.f_bg and not _tolua_isnull(self.f_bg) then
			loadSpriteTexture(self.f_bg, f_bg_res, LOADTEXT_TYPE)
		end
		if self.f_bg_2 and not _tolua_isnull(self.f_bg_2) then
			loadSpriteTexture(self.f_bg_2, f_bg_res, LOADTEXT_TYPE)
		end
	end
	-- self:updateMapEffect(effect_res)
end

--更新回合
function BattleSceneNewView:updateRound(round)
	-- 用于通知buff总览界面更新数据
	GlobalEvent:getInstance():Fire(BattleEvent.UPDATE_ROUND_NUM)
	-- 检测是否进入天平模式
	self:checkShowBalaceMsg(round)
	-- 剧情战斗的回合数在topscene中
	if self.battle_type == BattleConst.Fight_Type.Darma then
		_drama_controller:updateRound(round)
		return
	end
	local fight_list_config = Config.CombatTypeData.data_fight_list
	if fight_list_config == nil or fight_list_config[self.battle_type] == nil then return end
	
	local total_round = fight_list_config[self.battle_type].max_action_count or 0
	if not _tolua_isnull(self.round_label) then
		self.round_label:setString(string.format(TI18N("第%d/%d回合"), round, total_round))
	end
end

-- 检测显示天平模式
function BattleSceneNewView:checkShowBalaceMsg( round )
	if self.cur_round and self.cur_round == round then return end
	local combat_config = Config.CombatTypeData.data_fight_list[self.battle_type]
	if combat_config and combat_config.is_use_balance_mode > 0 then
		local balace_config = Config.CombatTypeData.data_blance_fight_mode[combat_config.is_use_balance_mode]
		if balace_config and balace_config[round] and balace_config[round][1] then
			self.cur_round = round
			GlobalMessageMgr:getInstance():showPermanentMsg(true, balace_config[round][1].desc)
			return
		end
	end
end

-- 检测显示圣殿战斗提示
function BattleSceneNewView:checkShowElementMsg(  )
	if self.dunge_data and next(self.dunge_data) ~= nil then
		if self.dunge_data[1] then
			local group = self.dunge_data[1].param
			local group_cfg = Config.ElementTempleData.data_monster[group]
			if group_cfg then
				GlobalMessageMgr:getInstance():showPermanentMsg(true, group_cfg.combat_desc or "")
				return
			end
		end
	end
end

--设置加速
function BattleSceneNewView:setSpeed(bool, speed)
	if self.double_speed_Label and not _tolua_isnull(self.double_speed_Label) then
		self.double_speed_Label:setString("X"..speed)
		if speed == 3 then
			local speed_scale = _controller:getActTime("speed_scale_2")
			_model:setBattleTimeScale(speed_scale)
		elseif speed == 2 then
			_model:setBattleTimeScale(_controller:getActTime("speed_scale"))
		else
			_model:setBattleTimeScale(1)
		end
	end
end

-- 黑幕隐藏地图
function BattleSceneNewView:setBlack(enable, alpha, zorder)
	local alpha = alpha or 255
	if not enable then
		if not _tolua_isnull(self.black_layer) then
			self.black_layer:setVisible(false)
			self.black_on_show = false
		end
	else
		if self.black_on_show == true then
			return
		end
		self.black_on_show = true
		
		if self.black_layer then
			self.black_layer:setVisible(true)
		else
			if not _tolua_isnull(self.map_sLayer) then
				self.black_layer = ccui.Layout:create()
				self.black_layer:setContentSize(self.main_size.width + 200, self.main_size.height + 200)
				self.black_layer:setPosition(-100, -100)
				self.map_sLayer:addChild(self.black_layer, 1)
				showLayoutRect(self.black_layer, alpha)
			end
		end
		self.black_layer:setOpacity(0)
		self.black_layer:runAction(cc.FadeIn:create(0.2))
	end
end

-- 黑幕隐藏地图和技能图标
function BattleSceneNewView:setBlack2(enable, alpha)
end

--自动动作呈现
function BattleSceneNewView:powerAction(bool)
end

--显示UI
function BattleSceneNewView:showUiViewAction()
	if not _tolua_isnull(self.ui_layer) and self.ui_layer then
		self.ui_layer:setVisible(true)
	end
end

--==============================--
--desc:战斗播报
--time:2018-09-21 10:02:24
--@attacker:
--@call_back:
--@is_act:
--@return 
--==============================--
function BattleSceneNewView:showSkillName(attacker, call_back, is_act)
	if attacker == nil or attacker.skill_data == nil or attacker.spine_renderer == nil then
		if call_back then
			call_back()
		end
		return
	end	
	if not is_act and attacker.temp_skill_bid ~= attacker.attacker_info.skill_bid then
		attacker.temp_skill_bid = attacker.attacker_info.skill_bid
		
		local is_left = _model:isLeft(attacker.group)
		local action = PlayerAction.action_1
		if is_left == true then
			action = PlayerAction.action_2
		end
		if self.skill_container == nil then
			self.skill_container = ccui.Layout:create()
			self.skill_container:setContentSize(cc.size(470, 190))
			self.skill_container:setAnchorPoint(cc.p(0.5, 0.5))
			self.skill_container:setPosition(self.main_size.width * 0.5, 550)
			self.effect_layer_1:addChild(self.skill_container)
			
			self.player_head = createSprite(nil, 80, 102, self.skill_container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 2)
			self.player_head:setScale(0.4)
			self.skill_name_label = createLabel(30, 193, nil, 267, 102, "", self.skill_container, nil, cc.p(0.5, 0.5))
			self.skill_name_label:setZOrder(2)
		end

		local object_type = attacker.object_type
		local object_bid = attacker.object_bid
		local name_pos_x = 0
		if object_type == BattleObjectType.Elfin then --精灵喊招特效
			if self.elfin_skill_effect_1 == nil then
				self.elfin_skill_effect_1 = createEffectSpine("E31330", cc.p(235, 100), cc.p(0.5, 0.5), false, action)
				self.skill_container:addChild(self.elfin_skill_effect_1, 1)
			else
				self.elfin_skill_effect_1:setVisible(true)
			end
			if self.skill_effect then
				self.skill_effect:setVisible(false)
			end
			self.elfin_skill_effect_1:setAnimation(0, action, false)
			self.skill_name_label:setString(_string_format("%s Lv.%s", attacker.skill_data.name, attacker.skill_data.level))
			name_pos_x = 294
		else --普通喊招特效
			if self.skill_effect == nil then
				self.skill_effect = createEffectSpine(PathTool.getEffectRes(276), cc.p(235, 100), cc.p(0.5, 0.5), false, action)
				self.skill_container:addChild(self.skill_effect, 1)
			else
				self.skill_effect:setVisible(true)
			end
			if self.elfin_skill_effect_1 then
				self.elfin_skill_effect_1:setVisible(false)
			end
			self.skill_effect:setAnimation(0, action, false)
			self.skill_name_label:setString(attacker.skill_data.name)
			name_pos_x = 267
		end
		
		if object_type == nil then
			if call_back then
				call_back()
			end
		else
			local head_icon = 0
			if object_type == 2 then
				head_icon = object_bid
			elseif object_type == 3 then
				local config = Config.UnitData.data_unit(object_bid)
				if config then
					head_icon = config.head_icon
				end
			elseif object_type == BattleObjectType.Elfin then -- 精灵的头像
				head_icon = Config.SpriteData.data_elfin_skill_icon[attacker.attacker_info.skill_bid]
			end
			if head_icon == nil or head_icon == 0 or head_icon == "" then
				if call_back then
					call_back()
				end
			else
				if attacker.fashion ~= 0 then
					local skill_config = Config.PartnerSkinData.data_skin_info[attacker.fashion]
					if skill_config then
						head_icon = skill_config.head_id
					end
				end
				local res
				if object_type == BattleObjectType.Elfin then -- 精灵的喊招头像特殊处理
					res = PathTool.getElfinHeadIcon(head_icon)
				else
					res = PathTool.getHeadIcon(head_icon)
				end
				loadSpriteTexture(self.player_head, res, LOADTEXT_TYPE)

				doStopAllActions(self.player_head)
				doStopAllActions(self.skill_name_label)
				
				self.skill_container:setVisible(true)
				self.player_head:setPosition(50, 102)
				self.skill_name_label:setPosition(425, 102)
				self.player_head:setOpacity(0)
				self.skill_name_label:setOpacity(0)
				
				local call_back_fun = cc.CallFunc:create(call_back)
				local head_move_to = cc.MoveTo:create(_controller:getActTime("skill_bg_move_time"), cc.p(80, 102))
				local head_fade_in = cc.FadeIn:create(_controller:getActTime("skill_bg_fadeIn"))
				local head_delay = cc.DelayTime:create(_controller:getActTime("skill_name_delay_time"))
				local head_delay_2 = cc.DelayTime:create(_controller:getActTime("skill_name_delay_time2"))
				local head_over = cc.CallFunc:create(function()
					self.skill_container:setVisible(false)
				end)
				self.player_head:runAction(cc.Sequence:create(cc.Spawn:create(head_move_to, head_fade_in), head_delay, call_back_fun, head_delay_2, head_over))
				
				local label_move_to = cc.MoveTo:create(_controller:getActTime("skill_bg_move_time"), cc.p(name_pos_x, 102))
				local label_fade_in = cc.FadeIn:create(_controller:getActTime("skill_bg_fadeIn"))
				self.skill_name_label:runAction(cc.Spawn:create(label_move_to, label_fade_in))
			end
		end
	else
		if call_back then
			call_back()
		end
	end
end

-- 显示被动技能名
--[[	@param:attacker-释放者
	@call_back:回调函数
	@is_act:是否动作中
]]
function BattleSceneNewView:showPassiveSkillName(attacker, call_back)
	if attacker.skill_data == nil or not attacker.spine_renderer then return end
	attacker.spine_renderer:playPassiveSkillName(attacker.skill_data.name, call_back);
end


--==============================--
--desc:精灵技能动作
--time:2020年3月13日
--@attacker: lwc
--@call_back:
--@is_act:
--@return 
--==============================--
function BattleSceneNewView:showElfinSkillAni(attacker, call_back, is_act)
	if attacker == nil or attacker.skill_data == nil or attacker.spine_renderer == nil then
		if call_back then
			call_back()
		end
		return
	end	
	if not is_act and attacker.temp_skill_bid ~= attacker.attacker_info.skill_bid then
		attacker.temp_skill_bid = attacker.attacker_info.skill_bid
		
		local is_left = _model:isLeft(attacker.group)
		local action = nil
		local skill_color = nil 
		if is_left == true then
			skill_color = cc.c3b(0xd8,0xff,0xf1)
			action = PlayerAction.action_2
		else
			skill_color = cc.c3b(0xff,0xe9,0xc6)
			action = PlayerAction.action_1
		end

		local object_type = attacker.object_type
		local object_bid = attacker.object_bid
		if object_type ~= BattleObjectType.Elfin then return end
		--精灵喊招特效

		if self.elfin_skill_container == nil then
			self.elfin_skill_container = ccui.Layout:create()
			self.elfin_skill_container:setContentSize(cc.size(470, 190))
			self.elfin_skill_container:setAnchorPoint(cc.p(0.5, 0.5))
			self.elfin_skill_container:setPosition(self.main_size.width * 0.5, 550)
			self.effect_layer_1:addChild(self.elfin_skill_container)
		end
		if self.elfin_head == nil then
			self.elfin_head = createSprite(nil, 140, 110, self.elfin_skill_container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 2)
			self.elfin_head:setScale(1)
		end
		if self.elfin_skill_name_label == nil then
			self.elfin_skill_name_label = createLabel(30, skill_color, 2, 303, 110, "", self.elfin_skill_container, 2, cc.p(0.5, 0.5))
			self.elfin_skill_name_label:setZOrder(2)
		end

		if self.elfin_skill_effect_1 == nil then
			self.elfin_skill_effect_1 = createEffectSpine("E31330", cc.p(235, 100), cc.p(0.5, 0.5), false, action)
			self.elfin_skill_container:addChild(self.elfin_skill_effect_1, 1)
		else
			self.elfin_skill_effect_1:setVisible(true)
		end

		self.elfin_skill_effect_1:setAnimation(0, action, true)
		self.elfin_skill_name_label:setString(_string_format("%s Lv.%s", attacker.skill_data.name, attacker.skill_data.level))
	
		
		if object_type == nil then
			if call_back then
				call_back()
			end
		else
			local head_icon = 0
			if object_type == BattleObjectType.Elfin then -- 精灵的头像
				head_icon = Config.SpriteData.data_elfin_skill_icon[attacker.attacker_info.skill_bid]
			end
			if head_icon == nil or head_icon == 0 or head_icon == "" then
				if call_back then
					call_back()
				end
			else
				if attacker.fashion ~= 0 then
					local skill_config = Config.PartnerSkinData.data_skin_info[attacker.fashion]
					if skill_config then
						head_icon = skill_config.head_id
					end
				end
				local res = PathTool.getElfinHeadIcon(head_icon)
				loadSpriteTexture(self.elfin_head, res, LOADTEXT_TYPE)

				doStopAllActions(self.elfin_head)
				doStopAllActions(self.elfin_skill_name_label)
				
				self.elfin_skill_container:setVisible(true)
				self.elfin_head:setPosition(80, 110)
				self.elfin_skill_name_label:setPosition(440, 110)
				self.elfin_skill_name_label:setTextColor(skill_color)
				self.elfin_head:setOpacity(0)
				self.elfin_skill_name_label:setOpacity(0)
				
				local call_back_fun = cc.CallFunc:create(call_back)
				local head_move_to = cc.MoveTo:create(_controller:getActTime("skill_bg_move_time"), cc.p(140, 110))
				local head_fade_in = cc.FadeIn:create(_controller:getActTime("skill_bg_fadeIn"))
				local head_delay = cc.DelayTime:create(_controller:getActTime("skill_name_delay_time"))
				local head_delay_2 = cc.DelayTime:create(_controller:getActTime("skill_name_delay_time2"))
				local head_over = cc.CallFunc:create(function()
					self.elfin_skill_container:setVisible(false)
				end)
				self.elfin_head:runAction(cc.Sequence:create(cc.Spawn:create(head_move_to, head_fade_in), head_delay, call_back_fun, head_delay_2, head_over))
				
				local label_move_to = cc.MoveTo:create(_controller:getActTime("skill_bg_move_time"), cc.p(303, 110))
				local label_fade_in = cc.FadeIn:create(_controller:getActTime("skill_bg_fadeIn"))
				self.elfin_skill_name_label:runAction(cc.Spawn:create(label_move_to, label_fade_in))
			end
		end
	else
		if call_back then
			call_back()
		end
	end
end

-- -- 显示精灵的技能动画
-- function BattleSceneNewView:showElfinSkillAni( attacker, call_back, is_act )
-- 	if attacker.object_type ~= BattleObjectType.Elfin or not attacker.spine_renderer then 
-- 		if call_back then
-- 			call_back()
-- 		end
-- 		return 
-- 	end

-- 	if not is_act and attacker.temp_skill_bid ~= attacker.attacker_info.skill_bid then
-- 		attacker.temp_skill_bid = attacker.attacker_info.skill_bid

-- 		AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.BATTLE, "b_sprite_skill")

-- 		-- 放精灵技能图标亮起的效果
-- 		attacker.spine_renderer:showElfinSkillIconAni(attacker.attacker_info.skill_bid)

-- 		if self.elfin_ani_container then
-- 			self.elfin_ani_container:stopAllActions()
-- 			self.elfin_ani_container:setVisible(false)
-- 		end

-- 		if self.elfin_ani_container == nil then
-- 			self.elfin_ani_container = ccui.Layout:create()
-- 			self.elfin_ani_container:setContentSize(cc.size(720, 335))
-- 			self.elfin_ani_container:setAnchorPoint(cc.p(0.5, 0.5))
-- 			self.elfin_ani_container:setPosition(self.main_size.width * 0.5, 430)
-- 			self.effect_layer_1:addChild(self.elfin_ani_container)

-- 			-- 压黑遮罩
-- 			self.elfin_mask = ccui.Layout:create()
-- 			self.elfin_mask:setBackGroundColor(cc.c3b(0,0,0))
-- 			self.elfin_mask:setBackGroundColorOpacity(100)
-- 			self.elfin_mask:setBackGroundColorType(1)
-- 	        self.elfin_mask:setContentSize(SCREEN_WIDTH, display.height)
-- 	        self.elfin_mask:setAnchorPoint(cc.p(0.5, 0.5))
-- 	        self.elfin_mask:setPosition(cc.p(360, display.getBottom(self.elfin_ani_container) + 167))
-- 	        self.elfin_mask:setTouchEnabled(false)
-- 	        self.elfin_ani_container:addChild(self.elfin_mask)
-- 		end
-- 		self.elfin_ani_container:setVisible(true)
-- 		if attacker.group == 1 then
-- 			self.elfin_ani_container:setScaleX(1)
-- 		else
-- 			self.elfin_ani_container:setScaleX(-1)
-- 		end

-- 		local call_back_fun = cc.CallFunc:create(call_back)
-- 		self.elfin_ani_container:runAction(cc.Sequence:create(cc.DelayTime:create(0.4), call_back_fun))

-- 		if self.elfin_enter_effect then
-- 			self.elfin_enter_effect:clearTracks()
-- 	        self.elfin_enter_effect:removeFromParent()
-- 			self.elfin_enter_effect = nil
-- 		end

-- 		local enter_effect_id = "E26001"
-- 		if attacker.group == 2 then
-- 			enter_effect_id = "E26002"
-- 		end
-- 		self.elfin_enter_effect = createEffectSpine(enter_effect_id, cc.p(360, 127), cc.p(0.5, 0.5), false, PlayerAction.action)
-- 		self.elfin_ani_container:addChild(self.elfin_enter_effect)

-- 		-- 精灵特效
-- 		local effect_id = Config.SpriteData.data_elfin_skill[attacker.attacker_info.skill_bid]
-- 		if effect_id then
-- 			local function elfinEffectEndCallback(  )
-- 				self.elfin_ani_container:setVisible(false)
-- 			end
-- 			if self.elfin_skill_effect then
-- 				self.elfin_skill_effect:clearTracks()
-- 		        self.elfin_skill_effect:removeFromParent()
-- 				self.elfin_skill_effect = nil
-- 			end
-- 			self.elfin_skill_effect = createEffectSpine(effect_id, cc.p(360, 80), cc.p(0.5, 0.5), false, PlayerAction.action_1, elfinEffectEndCallback)
-- 			self.elfin_ani_container:addChild(self.elfin_skill_effect)

-- 			-- 这一帧加一个淡出
-- 			local function animationEventFunc(event)
-- 	            if event.eventData.name == "appear" then
-- 	                self.elfin_skill_effect:runAction(cc.FadeOut:create(0.3))
-- 	                if self.elfin_enter_effect then
-- 	                	self.elfin_enter_effect:runAction(cc.FadeOut:create(0.3))
-- 	                end
-- 	            end
-- 	        end
-- 	        self.elfin_skill_effect:registerSpineEventHandler(animationEventFunc, sp.EventType.ANIMATION_EVENT)
-- 		else
-- 			if call_back then
-- 				call_back()
-- 			end
-- 		end
-- 	else
-- 		if call_back then
-- 			call_back()
-- 		end
-- 	end
-- end

--设置按钮隐藏
function BattleSceneNewView:setButtonHide(bool)
	if self.auto then
		self.auto:setVisible(bool)
	end
	if self.pasue_btn then
		self.pasue_btn:setVisible(bool)
	end
end

--快速归位置
function BattleSceneNewView:resetMap()
	self.map_sLayer:setPositionX(0)
	if self.f_bg and not _tolua_isnull(self.f_bg) then
		self.f_bg:setPosition(display.left + _controller:getActTime("first_offset_distance"), display.bottom)
	end
	if self.f_bg_2 and not _tolua_isnull(self.f_bg_2) then
		local offset = self.main_size.width - self.f_bg:getBoundingBox().width*self:getFarLayerScale()
		self.f_bg_2:setPosition(self.f_bg:getBoundingBox().width*self:getFarLayerScale() + offset + _controller:getActTime("first_offset_distance") * 2, display.bottom)
	end
end

-- 添加额外的界面
--@param view:需要添加的额外view
function BattleSceneNewView:addExternView(view, x, y)
	self:addChild(view, 2)
	x = x or 0
	y = y or 0
	view:setPosition(x, y)
end

function BattleSceneNewView:handleLayerShowHide(status)
	if self.effect_layer_1 and not _tolua_isnull(self.effect_layer_1) then
		self.effect_layer_1:setVisible(status)
	end
	if self.effect_layer_2 and not _tolua_isnull(self.effect_layer_2) then
		self.effect_layer_2:setVisible(status)
	end
	if self.role_layer and not _tolua_isnull(self.role_layer) then
		self.role_layer:setVisible(status)
	end
end

--==============================--
--desc:设计屏幕震动
--time:2019-05-09 02:34:36
--@shake_bid:
--@return 
--==============================--
function BattleSceneNewView:shakeScreen(shake_bid)
	if self.is_shake then return end    -- 禁掉抖屏
	local data = Config.SkillData.data_get_shake_data[shake_bid]
	if not data then
		return
	end
	local scene = self.main_layer
	if scene.action then
		scene:stopAllActions()--stopAction(scene.action)
		scene.action = nil
	end
	self.camera_shake_pos = cc.p(self.main_layer:getPosition())
	self.is_shake = true

	local function returnPos()
		self.is_shake = false
		scene:setPosition(self.camera_shake_pos)
	end

	local order = {1, 4, 7, 8, 9, 6, 3, 2}
	local str = data.shake_strength or 30 --振幅，单位像素
	local damp = 3 --振动减衰, 单位像素
	local step = data.shake_rate / 1000 or 0.015 --振动间隔，单位秒
	local shakeXTime = 0.25 --横向加倍
	local shakeYTime = 0.25 --纵向加倍
	local shakeTime = data.shake_time or 3 --振动次数
	local xy_list = {{- 0.7, 0.7}, {0, 1}, {0.7, 0.7}, {- 1, 0}, {0, 0}, {1, 0}, {- 0.7, - 0.7}, {0, - 1}, {0.7, - 0.7}}

	local function setRandomPos(index)
		local pos_x, pos_y
		pos_x = str * shakeYTime * xy_list[order[index]][1]
		pos_y = - str * shakeXTime * xy_list[order[index]][2]
		local pos = cc.p(self.camera_shake_pos.x + pos_x, self.camera_shake_pos.y + pos_y)
		scene:setPosition(pos)
	end

	local base_call
	for j = 1, shakeTime do
		for i = 1, #order do
			local delay = cc.DelayTime:create(step)
			base_call = cc.Sequence:create(base_call, cc.CallFunc:create(function() setRandomPos(i) end), delay)
		end
		str = str - damp
	end
	base_call = cc.Sequence:create(base_call, cc.CallFunc:create(returnPos))
	scene.action = base_call
	scene:runAction(base_call)
end

--------------------------获取变量部分逻辑began-----------------------
--==============================--
--desc:获取场景特效层
--time:2017-08-03 04:04:00
--@type:1为上层特效,2为下层特效
--@return
--==============================--
function BattleSceneNewView:getEffectLayer(type)
	if type == 1 then
		return self.effect_layer_1
	else
		return self.effect_layer_2
	end
end

--获取人物层
function BattleSceneNewView:getMapLayer()
	if not _tolua_isnull(self.role_layer) then
		return self.role_layer
	end
end

--获取战斗层
function BattleSceneNewView:getBattleLayer()
	if not _tolua_isnull(self.ui_layer) then
		return self.ui_layer
	end
end

--获取阵法层
function BattleSceneNewView:getBattleReadyLayer()
	return self.ui_redyLayer
end

--获取地图层
function BattleSceneNewView:getSmapLayer()
	return self.map_sLayer
end

--获取地图层初始位置
function BattleSceneNewView:getSmapLayerPositionX()
	return self.map_sLayer:getPositionX()
end

--获取前景层
function BattleSceneNewView:getFmapLayer()
	return self.map_fLayer
end

--获取前景层原始位置
function BattleSceneNewView:getFmapLayerPositionX()
	return self.map_fLayer:getPositionX()
end

--获取中间层第一张地图
function BattleSceneNewView:getMapBg()
	return self.map_bg
end

--是否跑动中
function BattleSceneNewView:getIsRun()
	return self.is_run
end

--获取当前出手位置
function BattleSceneNewView:getOrderPos()
	return self.order_pos
end

function BattleSceneNewView:handleBattleSceneStatus(status)
	-- 这里只是隐藏战斗场景UI,无需进行剧情副本UI隐藏倒计时
	if status == true and self.battle_type == BattleConst.Fight_Type.Darma then
		_drama_controller:openBattleDramaUI(true, self.battle_res_id, self.battle_type, true)
	else
		_drama_controller:openBattleDramaUI(false, self.battle_res_id, self.battle_type, true)
	end
	if self.main_layer and not _tolua_isnull(self.main_layer) then
		self.main_layer:setVisible(status)
	end
	if self.ui_layer and not _tolua_isnull(self.ui_layer) then
		self.ui_layer:setVisible(status)
	end
end

--是否自己回合
-- function BattleSceneNewView:getIsRoleRound()
-- 	return self.is_role
-- end
function BattleSceneNewView:getMainRound()
	return self.is_main_fight_round
end

--==============================--
--desc:主城ui变化的时候相关位置调整
--time:2018-09-12 11:32:47
--@return 
--==============================--
function BattleSceneNewView:changeSomeLayoutPosition()
	local isnull = tolua.isnull
	local target_pos_y = _main_controller:getBottomHeight()
	if not isnull(self.form_view) then
		self.form_view:setPositionY(target_pos_y + 60)
	end
	if not isnull(self.tips_lev_bg) then
		self.tips_lev_bg:setPositionY(target_pos_y + 26)
	end
	if not isnull(self.lookup_target_btn) then
		self.lookup_target_btn:setPositionY(target_pos_y + 26)
	end
end

--------------------------获取变量部分逻辑end-----------------------
-----------------------------清场began---------------------
--清理战斗UI
function BattleSceneNewView:cleanFightView()
	self.call_back = nil

	if self.skill_effect then
		self.skill_effect:clearTracks()
        self.skill_effect:removeFromParent()
		self.skill_effect = nil
	end
	if self.elfin_skill_effect_1 then
		self.elfin_skill_effect_1:clearTracks()
        self.elfin_skill_effect_1:removeFromParent()
		self.elfin_skill_effect_1 = nil
	end
	-- 战斗喊招
	if not _tolua_isnull(self.skill_container) then
		self.skill_container:removeAllChildren()
		self.skill_container = nil
	end
	-- 战斗喊招
	if not _tolua_isnull(self.elfin_skill_container) then
		self.elfin_skill_container:removeAllChildren()
		self.elfin_skill_container = nil
	end
	-- 黑屏部分,手动创建的
	if not _tolua_isnull(self.black_layer) then
		doStopAllActions(self.black_layer)
		self.black_layer:removeFromParent()
	end
	self:unMapMovescheduleUpdate()
	self:clearRoleLayer()
	self:clearUiLayer()

	if not _tolua_isnull(self.map_sLayer) then
		self.map_sLayer:removeAllChildren()
		self.map_sLayer = nil
	end
	if not _tolua_isnull(self.map_fLayer) then
		self.map_fLayer:removeAllChildren()
		self.map_fLayer = nil
	end	
	if self.load_res_f_bg then
		self.load_res_f_bg:DeleteMe()
		self.load_res_f_bg = nil
	end
	if self.load_res_map_bg then
		self.load_res_map_bg:DeleteMe()
		self.load_res_map_bg = nil
	end
	if not _tolua_isnull(self.single_bg) then
		self.single_bg:removeAllChildren()
		self.single_bg = nil
	end
	if self.update_buff_event ~= nil then
		GlobalEvent:getInstance():UnBind(self.update_buff_event)
		self.update_buff_event = nil
	end

	if self.chat_ui_size_change then
		GlobalEvent:getInstance():UnBind(self.chat_ui_size_change)
		self.chat_ui_size_change = nil
	end
	
	self.map_bg = nil
	self.map_bg_2 = nil
	self.f_bg_2 = nil
	self.f_bg = nil
	
	if not _tolua_isnull(self.effect_layer_1) then
		self.effect_layer_1:removeAllChildren()
		self.effect_layer_1 = nil
	end
	if not _tolua_isnull(self.effect_layer_2) then
		self.effect_layer_2:removeAllChildren()
		self.effect_layer_2 = nil
	end
	local is_detele = _controller:getExtendFightType() ~= BattleConst.Fight_Type.Darma or _controller:getCurFightType() == 0
	
	_drama_controller:openBattleDramaUI(false)

	if not _tolua_isnull(self.main_layer) then
		self.main_layer:removeAllChildren()
		self.main_layer:removeFromParent()
	end
	self.main_layer = nil
	
	-- 切换之后延迟一秒清楚模型
	RenderMgr:getInstance():doNextFrame(function()
		display.removeUnusedTextures()
	end)
end

--[[    @desc:搞不懂,退出战斗还要把这个设置nil是何用意 
    author:{author}
    time:2018-10-02 14:54:01
    @return:
]]
function BattleSceneNewView:clearRoleLayer()
	if self.role_layer and not _tolua_isnull(self.role_layer) then
		self.role_layer:removeAllChildren()
	end
end

function BattleSceneNewView:clearUiLayer(is_reconnect)
	self.call_back = nil

	self:removeDeclarationSpine(1,true)
	self:removeDeclarationSpine(1)
	self:removeDeclarationSpine(2,true)
	self:removeDeclarationSpine(2)

	if self.elfin_skill_effect then
		self.elfin_skill_effect:clearTracks()
        self.elfin_skill_effect:removeFromParent()
		self.elfin_skill_effect = nil
	end
	if self.elfin_enter_effect then
		self.elfin_enter_effect:clearTracks()
        self.elfin_enter_effect:removeFromParent()
		self.elfin_enter_effect = nil
	end

	self:clearDieTimer()
	GlobalTimeTicket:getInstance():remove("drance_wait_timer")
	
	self.is_init_normal_battle = false
	self.skill_cooldown_info = {}
	
	if not _tolua_isnull(self.passive_skill) then
		self.passive_skill:runAction(cc.RemoveSelf:create())
		self.passive_skill = nil
	end
	if self.floor_round and not _tolua_isnull(self.floor_round) then
		self.floor_round:DeleteMe()
		self.floor_round = nil
	end
	GlobalMessageMgr:getInstance():showPermanentMsg(false)
	self:updateCampEffect(false, self.left_camp_effect)
	self:updateCampEffect(false, self.right_camp_effect)
	if self.left_halo_load then
		self.left_halo_load:DeleteMe()
		self.left_halo_load = nil
	end
	if self.right_halo_load then
		self.right_halo_load:DeleteMe()
		self.right_halo_load = nil
	end
	if self.star_panel and not _tolua_isnull(self.star_panel) then
		self.star_panel:removeAllChildren()
		self.star_panel:removeFromParent()
		self.star_panel = nil
	end
	if self.form_view and not _tolua_isnull(self.form_view) then
		self.form_view:removeAllChildren()
		self.form_view:removeFromParent()
		self.form_view = nil
		self.left_camp_effect = nil
		self.right_camp_effect = nil
	end
	_drama_controller:updataZhenfaInfo(false)
	if self.tips_lev_bg and not _tolua_isnull(self.tips_lev_bg) then
		self.tips_lev_bg:removeAllChildren()
		self.tips_lev_bg:removeFromParent()
		self.tips_lev_bg = nil
	end
	
	if self.lookup_target_btn and not _tolua_isnull(self.lookup_target_btn) then
		self.lookup_target_btn:removeAllChildren()
		self.lookup_target_btn:removeFromParent()
		self.lookup_target_btn = nil
	end
	
	self:clearBuffIcon()
	
	if self.double_speed_btn and not _tolua_isnull(self.double_speed_btn) then
		self.double_speed_btn:removeAllChildren()
		self.double_speed_btn:removeFromParent()
		self.double_speed_btn = nil
	end
	if not _tolua_isnull(self.guild_boss_view) then
		self.guild_boss_view:stopAllActions()
		self.guild_boss_view:removeAllChildren()
		self.guild_boss_view = nil
	end	
	if self.skip_btn and not _tolua_isnull(self.skip_btn) then
		self.skip_btn:removeAllChildren()
		self.skip_btn:removeFromParent()
		self.skip_btn = nil
	end
	if self.leave_btn then
		self.leave_btn:removeFromParent()
		self.leave_btn = nil
	end
	if not _tolua_isnull(self.floor_begin_tips) then
		self.floor_begin_tips:removeAllChildren()
		self.floor_begin_tips = nil
	end
	
	if not _tolua_isnull(self.danrace_con) then
		self.danrace_con:removeAllChildren()
		self.danrace_con = nil
	end
	if not _tolua_isnull(self.map_name_bg) then
		self.map_name_bg:removeAllChildren()
		self.map_name_bg = nil
	end
	if not _tolua_isnull(self.time_num) then
		self.time_num:DeleteMe()
	end
	if not _tolua_isnull(self.round_time_widget) then
		self.round_time_widget:removeAllChildren()
		self.round_time_widget = nil
	end

	if self.year_box_effect then
    	for i,v in pairs(self.year_box_effect) do
    		v:clearTracks()
			v:removeFromParent()
    	end
    	self.year_box_effect = nil
    end

    if self.battle_boss_hp_progress then
		self.battle_boss_hp_progress:removeFromParent()
		self.battle_boss_hp_progress = nil
	end
    if self.actionyearmonster_hp_progress then
		self.actionyearmonster_hp_progress:removeFromParent()
		self.actionyearmonster_hp_progress = nil
	end

	if self.resources_load ~= nil then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
	if self.resources_hp_load ~= nil then
        self.resources_hp_load:DeleteMe()
        self.resources_hp_load = nil
    end
    if self.boss_hp_updaet_event then
        GlobalEvent:getInstance():UnBind(self.boss_hp_updaet_event)
        self.boss_hp_updaet_event = nil
    end

	if not _tolua_isnull(self.ui_layer) then
		self.ui_layer:removeAllChildren()
		self.ui_layer = nil
	end

    if self.year_progress_timer ~= nil then
        GlobalTimeTicket:getInstance():remove(self.year_progress_timer)
        self.year_progress_timer = nil
    end

	-- 不是战斗重连才播放战斗之前的音乐
	if not is_reconnect then
		if not _main_controller:checkIsInDramaUIFight() then
			if self.music_info then
				AudioManager:getInstance():playMusic(self.music_info.type, self.music_info.name, self.music_info.is_loop)
			end
		else
			self:playMusic()
		end
	end
end
--清除选择特效
function BattleSceneNewView:clearSelectSkill()
	if self.sprite_sel and(not _tolua_isnull(self.sprite_sel)) then
		self.sprite_sel:setVisible(false)
	end
end


--角色layer
BattleRoleView = class("BattleRoleView")
BattleRoleView.create = function()
	BattleRoleView.__index = BattleRoleView --避免每次create都创建一个新的元表
	local layer = ccui.Layout:create()
	local t = tolua.getpeer(layer) --元表的__index指向了一个C函数，当在Lua中要访问一个C++对象的成员变量(准确的说是一个域)时，会调用这个C函数，在这个C函数中，会查找各个关联表来取得要访问的域，这其中就包括peer表的查询。 
	if not t then
		t = {}
		tolua.setpeer(layer, t)--C++对象需要存贮自己的成员变量的值，这个值不能够存贮在元表里(因为元表是类共用的)，所以每个对象要用一个私有的表来存贮，这个表在tolua里叫做peer表。
	end
	setmetatable(t, BattleRoleView)
	return layer
end

--------------------------------剧情相关
function BattleSceneNewView:addUnit(vo)
	if self.story_unit_list == nil then
		self.story_unit_list = {}
	end
	if self.story_unit_list[vo.id] then return end
	local npc = Npc.New()
	npc:setParentWnd(self.role_layer)
	npc:setVo(vo)
	npc:initSpine()
	self.story_unit_list[vo.id] = npc
	GlobalEvent:getInstance():Fire(SceneEvent.SCENE_ADDNPC, vo)
end

function BattleSceneNewView:removeUnit(id)
	if self.story_unit_list == nil or self.story_unit_list[id] == nil then return end
	self.story_unit_list[id]:DeleteMe()
	self.story_unit_list[id] = nil
end

function BattleSceneNewView:getUnitById(id)
	if self.story_unit_list ~= nil and next(self.story_unit_list or {}) ~= nil then
		return self.story_unit_list[id]
	end
end

function BattleSceneNewView:syncUnit(id, x, y)
	if self.story_unit_list == nil then return end
	local npc = self.story_unit_list[id]
	if npc == nil then return end
	npc:doMove(nil, cc.p(x, y))
end

-- 获取远景层缩放比例
function BattleSceneNewView:getFarLayerScale(  )
	if self._f_scale then
		return self._f_scale
	end
	self._f_scale = 1
	if self.f_bg then
		local bg_size = self.f_bg:getContentSize()
		local pos_y = self.map_fLayer:getPositionY()
		if (pos_y+bg_size.height) < display.height then
			self._f_scale = display.height/(pos_y+bg_size.height)
		end
	end
	return self._f_scale
end
