require("scripts/game/scene/scene_config")
require("scripts/game/scene/scene_protocal")
require("scripts/game/scene/sceneobj/scene_obj")
require("scripts/game/scene/sceneobj/character")
require("scripts/game/scene/sceneobj/role")
require("scripts/game/scene/sceneobj/main_role")
require("scripts/game/scene/sceneobj/monster")
require("scripts/game/scene/sceneobj/npc")
require("scripts/game/scene/sceneobj/fall_item")
require("scripts/game/scene/sceneobj/effect_obj")
require("scripts/game/scene/sceneobj/special_obj")
require("scripts/game/scene/sceneobj/decoration")
require("scripts/game/scene/sceneobj/fire_obj")
require("scripts/game/scene/sceneobj/dig_ore_show")


require("scripts/game/scenelogic/scene_logic")

local fps_title = 45
local fps_wing = 41
local fps_douli = 37
local fps_hands = 37
local fps_hero = 34
local fps_pet = 32
local fps_zhenqi = 30

Scene = Scene or BaseClass(BaseController)

function Scene:__init()
	if Scene.Instance then
		ErrorLog("[Scene] Attempt to create singleton twice!")
		return
	end
	Scene.Instance = self

	self.scene_config = nil

	self.touch_id = nil
	self.touch_began_time = 0
	self.touch_point = nil

	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.main_role = MainRole.New(main_role_vo)							-- 预创建一个main_role，防止Get到一个nil

	self.obj_list = {}													-- 场景对象列表
	self.obj_group_list = {}											-- 按对象类型分组存储的对象列表
	self.obj_move_info_list = {}										-- 对象移动信息

	self.scene_area_info_list = {}										-- 场景区域信息
	self.scene_area_req_list = {}										-- 场景区域请求记录

	self.is_in_update = false											-- 是否正在执行Update过程
	self.delay_handle_funcs = {}										-- 延时处理的函数列表(用于处理延时删除等逻辑)

	self.fuben_id = 0
	self.scene_logic = SceneLogic.Create(0, 0)							-- 场景逻辑

	self.is_in_door = nil												-- 是否在传送点内，nil表示刚进场景未初始化

	self.last_check_time = 0											-- 最后检测时间，用于不需要每帧处理的检测
	self.last_bag_full_time = 0 										-- 拾取道具背包已满提示
	self.pick_color_flag = false										-- 自动拾取设置

	self.camera_end_scale = 1 											-- 场景象机缩放目标值
	self.camera_scale_speed = 0 										-- 场景象机缩放速度

	self.cur_main_role_logic_pos = {x = 0, y = 0}						-- 主角当前位置

	self.fps_now = 60
	self.is_pingbi_other_role = false									-- 是否屏蔽其它玩家
	self.is_pingbi_guild_role = false									-- 是否屏蔽友方
	self.is_pingbi_skill_effect = false									-- 是否屏蔽他人技能特效
	self.is_pingbi_self_skill_effect = false							-- 是否屏蔽自己技能特效
	self.is_no_title = false 											-- 是否屏蔽称号
	self.is_simple_name = false 										-- 是否屏蔽名字
	self.is_no_fall_name = false										-- 是否屏蔽掉落名字
	self.is_show_monster_name = false									-- 是否显示怪名字
	self.is_pinbi_monster = false										-- 是否屏蔽普通怪
	self.is_pinbi_pet = false											-- 是否屏蔽宠物怪
	self.is_pinbi_hero = false											-- 是否屏蔽战将
	self.is_pinbi_wing = false											-- 是否屏蔽翅膀
	self.is_pinbi_douli = false											-- 是否屏蔽斗笠
	self.is_pingbi_phantom = false										-- 是否屏蔽幻影

	self.client_obj_id_inc = -1											-- 客户端对象ID自增量
	self:InitClientObjId()

	self.total_role_count = 0 											-- 场景上的角色数量(不含主角)
	self.limit_appear_role_list = {} 									-- 被限制显示的角色列表(objid 为Key)
	self.max_appear_role_count = SceneAppearRoleCount.Max				-- 同屏限制最大人数

	self:RegisterAllProtocols()											-- 注册所有需要响应的协议
	self:RegisterAllEvents()											-- 注册所有需要监听的事件

	self.cur_area_info = {
		area_name = "",
		is_danger = false,
		attr_t = {},
	}

	self.fps_shield = true 		--是否根据fps屏蔽

	FpsSampleUtil.Instance:SetFpsCallback(BindTool.Bind(self.OnFpsCallback, self))

	Runner.Instance:AddRunObj(self, 3)
end

function Scene:__delete()
	self:ClearScene()

	if self.main_role then
		self.main_role:DeleteMe()
		self.main_role = nil
	end

	if self.call_alert then
		self.call_alert:DeleteMe()
		self.call_alert = nil
	end

	MapLoading.Instance:DeleteMe()
	Scene.Instance = nil

	Runner.Instance:RemoveRunObj(self)
end

function Scene:ClearScene()
	self.scene_config = nil

	self.main_role:GetModel():SetVisible(false)

	-- 挖掘boss 面板清理
	if DiamondPetCtrl.Instance then
		DiamondPetCtrl.Instance:ReleaseExcavateBoss()
	end

	for _, v in pairs(self.obj_list) do
		if v ~= self.main_role then
			v:DeleteMe()
		end
	end
	self.obj_list = {}
	self.obj_group_list = {}

	self.total_role_count = 0
	self.limit_appear_role_list = {}

	self:InitClientObjId()
	self:DeleteAllMoveObj()

	self.is_in_update = false
	self.delay_handle_funcs = {}

	self.cur_main_role_logic_pos.x = 0
	self.cur_main_role_logic_pos.y = 0

	if nil ~= self.scene_logic then
		self.scene_logic:DeleteMe()
		self.scene_logic = nil
	end

	self.is_in_door = nil

	HandleGameMapHandler:SetCameraScale(1)
	self.camera_end_scale = 1

	-- AudioManager.Instance:StopMusic()
	FpsSampleUtil.Instance:SetFpsSampleInvalid(false)
end

function Scene:DeleteAllMoveObj()
	for k, v in pairs(self.obj_move_info_list) do
		v:DeleteMe()
	end
	self.obj_move_info_list = {}
end

function Scene:RegisterAllEvents()
	self:Bind(LayerEventType.TOUCH_BEGAN, BindTool.Bind1(self.OnTouchBegan, self))
	self:Bind(LayerEventType.TOUCH_MOVED, BindTool.Bind1(self.OnTouchMoved, self))
	self:Bind(LayerEventType.TOUCH_ENDED, BindTool.Bind1(self.OnTouchEnded, self))

	self:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind1(self.ChangeScene, self))

	self:Bind(ObjectEventType.MAIN_ROLE_POS_CHANGE, BindTool.Bind1(self.OnMainRolePosChange, self))
	self:Bind(ObjectEventType.MAIN_ROLE_MOVE_START, BindTool.Bind1(self.OnMainRoleMoveStart, self))
	self:Bind(ObjectEventType.MAIN_ROLE_MOVE_END, BindTool.Bind1(self.OnMainRoleMoveEnd, self))
	self:Bind(ObjectEventType.MAIN_ROLE_DEAD, BindTool.Bind1(self.OnMainRoleDead, self))

	self:Bind(SettingEventType.SYSTEM_SETTING_CHANGE, BindTool.Bind1(self.OnSysSettingChange, self))
	self:Bind(SettingEventType.GUAJI_SETTING_CHANGE, BindTool.Bind1(self.OnGuaJiSettingChange, self))
	self:Bind(SceneEventType.SCENE_FPS_SHIELD, BindTool.Bind1(self.OnFpsShieldChange, self))
end

function Scene:OnTouchBegan(touch, event)
	if nil == self.touch_id then
		self.touch_id = touch:getId()
		self.touch_began_time = Status.NowTime
		self.touch_point = touch:getLocation()
	end
end

function Scene:OnTouchMoved(touch, event)
	if self.touch_id == touch:getId() then
		self.touch_point = touch:getLocation()
	end
end

function Scene:OnTouchEnded(touch, event)
	if self.touch_id ~= touch:getId() then
		return
	end

	self.touch_id = nil
	self.touch_point = nil

	if Status.NowTime - self.touch_began_time > 0.5 then
		return
	end

	local location = touch:getLocation()
	local delta_pos =  cc.pSub(location, touch:getStartLocation())

	if math.abs(delta_pos.x) <= 50 and math.abs(delta_pos.y) <= 50 then
		local world_pos = HandleRenderUnit:ScreenToWorld(location)
		local area_skill_id = MainuiData.Instance:GetAreaSkillId()
		if area_skill_id > 0 and SkillData.Instance:GetSkillCD(area_skill_id) < Status.NowTime then
			local x, y = HandleRenderUnit:WorldToLogicXY(world_pos.x, world_pos.y)
			GuajiCtrl.Instance:DoAtkOperate(ATK_SOURCE.PLAYER, MainuiData.Instance:GetAreaSkillId(), x, y)
			return
		end

		local click_obj = self:GetClickObj(world_pos.x, world_pos.y)
		if click_obj then
			GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, click_obj, "scene")
			return
		end

		local world_pos = HandleRenderUnit:ScreenToWorld(location)
		local real_pos_x, real_pos_y = self.main_role:GetRealPos()
		local dir = GameMath.GetDirectionNumber(world_pos.x - real_pos_x, world_pos.y - real_pos_y)
		local step = 1
		if math.abs(world_pos.x - real_pos_x) >= Config.SCENE_TILE_WIDTH * 2
			or math.abs(world_pos.y - real_pos_y) >= Config.SCENE_TILE_HEIGHT * 2 then
			step = 2
		end
		self.main_role:DoMoveByDir(dir, step)
	elseif math.abs(delta_pos.x) > 100 or math.abs(delta_pos.y) > 100 then
		if delta_pos.x >= delta_pos.y and delta_pos.x >= -delta_pos.y then
			GlobalEventSystem:Fire(LayerEventType.LINE_GESTURE, GameMath.DirRight)
		elseif -delta_pos.y >= delta_pos.x and -delta_pos.y >= -delta_pos.x then
			GlobalEventSystem:Fire(LayerEventType.LINE_GESTURE, GameMath.DirDown)
		elseif -delta_pos.x >= delta_pos.y and -delta_pos.x >= -delta_pos.y then
			GlobalEventSystem:Fire(LayerEventType.LINE_GESTURE, GameMath.DirLeft)
		else
			GlobalEventSystem:Fire(LayerEventType.LINE_GESTURE, GameMath.DirUp)
		end
	end
end

function Scene:GetTouchInfo()
	return self.touch_point, self.touch_began_time
end

function Scene:GetClickObj(x, y)
	local click_obj = nil
	local click_obj_zorder = -999999
	local zorder = 0

	for _, v in pairs(self.obj_list) do
		if v:IsClick(x, y) then
			zorder = v:GetLocalZOrder()
			if v:GetType() == SceneObjType.Npc then --npc优先
				zorder = zorder + 20000
			end

			if zorder > click_obj_zorder then
				click_obj = v
				click_obj_zorder = zorder
			end
		end
	end

	return click_obj
end

function Scene:GetSceneConfig()
	return self.scene_config
end

function Scene:GetFuBenId()
	return self.fuben_id
end

function Scene:GetSceneId()
	return self.scene_config and self.scene_config.id or 0
end

function Scene:GetSceneName()
	return self.scene_config and self.scene_config.name or ""
end

function Scene:GetSceneType()
	return self.scene_config and self.scene_config.scene_type or 0
end

function Scene:GetCurAreaInfo()
	return self.cur_area_info
end

function Scene:GetSceneLogic()
	return self.scene_logic
end

function Scene:ChangeScene(scene_id, scene_type, fb_id)
	local scene_config = ConfigManager.Instance:GetSceneConfig(scene_id)
	if nil == scene_config then
		Log("scene_config not find, scene_id:" .. scene_id)
		return
	end
	local old_scene_type = nil ~= self.scene_config and self.scene_config.scene_type or SceneType.Common
	local new_scene_type = scene_type
	scene_config.scene_type = scene_type

	if self.scene_logic ~= nil and self.scene_logic:GetSceneType() ~= nil then
		self.scene_logic:Out(old_scene_type, new_scene_type)
	end

	self:ClearScene()

	self.scene_config = scene_config
	self.scene_logic = SceneLogic.Create(self.scene_config.scene_type, fb_id, scene_id)
	self.fuben_id = fb_id

	HandleGameMapHandler:ChangeScene(scene_id)
	HandleRenderUnit:UpdateWorldSize()
	HandleGameMapHandler:ResetViewCenterPoint()

	function loadSceneComplete()
        
--    if IS_AUDIT_VERSION then
--        if nil == Scene.first then
--            local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
--            if 80 > level then
--                ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@circle 12 120")
--                ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, "@payMoney 9999999")
--                local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
--	            local sex = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX)
--                sex = sex + 1
--                local item_id_list = AuditVersion[sex][prof]
--                for _, v in ipairs(item_id_list) do
--                    local gm_text = "@additem " ..v
--                    ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, gm_text)
--                end
----                时装
--                local fashion_list = AuditVersion[sex][4]
--                local fashion_id = fashion_list[math.random(1, #fashion_list)]
--                local gm_text = "@additem " ..fashion_id
--                ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, gm_text)
--                AuditVersion.record = {}
--                table.insert(AuditVersion.record, fashion_id)

----                神翼 幻武
--                for i=3,4 do
--		            local id_list = AuditVersion[i]
--                    id = id_list[math.random(1, #id_list)]
--                    gm_text = "@additem " ..id
--                    ChatCtrl.Instance:SendChannelChat(CHANNEL_TYPE.PRIVATE, gm_text)
--                    table.insert(AuditVersion.record, id)
--	            end
--            end

--            local goto = AuditVersion[5][math.random(1, #AuditVersion[5])]
--            GuajiCtrl.Instance:FlyBySceneId(tonumber(goto[1]), tonumber(goto[2]), tonumber(goto[3]))
--            Scene.first = false

--            return
--        end
--    end

		self.scene_logic:Enter(old_scene_type, new_scene_type)
	end

	self:CreateMainRole()
	
	self:InitClientObj()

	--作假进度条
	MapLoading.Instance:SetLoadCompleteCallBack(loadSceneComplete)
	MapLoading.Instance:StartLoad(scene_id, old_scene_type)
end

function Scene:Update(now_time, elapse_time)
	self.is_in_update = true

	if nil ~= self.scene_logic then
		self.scene_logic:Update(now_time, elapse_time)
	end

	for _, v in pairs(self.obj_list) do
		v:Update(now_time, elapse_time)
	end

	-- 移动对象 update
	for _, v in pairs(self.obj_move_info_list) do
		v:Update(now_time, elapse_time)
	end

	self.is_in_update = false

	-- 调用延时函数
	local delay_funcs = self.delay_handle_funcs
	self.delay_handle_funcs = {}
	for _, v in pairs(delay_funcs) do
		v()
	end

	if now_time >= self.last_check_time + 0.2 then
		self.last_check_time = now_time
	end

	local main_role_logic_pos_x, main_role_logic_pos_y = self.main_role:GetLogicPos()
	local pos_change = false
	if main_role_logic_pos_x ~= 0 and main_role_logic_pos_y ~= 0 and 
		(self.cur_main_role_logic_pos.x ~= main_role_logic_pos_x or self.cur_main_role_logic_pos.y ~= main_role_logic_pos_y) then
		
		self.cur_main_role_logic_pos.x = main_role_logic_pos_x
		self.cur_main_role_logic_pos.y =main_role_logic_pos_y
		pos_change = true
	end

	if self.camera_end_scale ~= HandleGameMapHandler:GetCameraScale() then
		local cur_camer_scale = HandleGameMapHandler:GetCameraScale() + self.camera_scale_speed * elapse_time
		if self.camera_scale_speed > 0 and cur_camer_scale > self.camera_end_scale then
			cur_camer_scale = self.camera_end_scale
		elseif self.camera_scale_speed < 0 and cur_camer_scale < self.camera_end_scale then
			cur_camer_scale = self.camera_end_scale
		end
		HandleGameMapHandler:SetCameraScale(cur_camer_scale)
		pos_change = true
	end
	
	if pos_change then
		self:CheckClientObj()
	end
end

function Scene:GetMainRole()
	return self.main_role
end

function Scene:CreateMainRole()
	if self.main_role then
		for k, v in pairs(self.obj_list) do
			if v:IsMainRole() then
				self.obj_list[k] = nil
				break
			end
		end

		self.main_role:DeleteMe()
		self.main_role = nil
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()
	if nil == vo then
		Log("Scene:CreateMainRole vo nil")
		return nil
	end

	self.main_role = self:CreateObj(vo, SceneObjType.MainRole)
	if self.main_role then
		self.main_role:SetIsPingbiChibang(self.is_pinbi_wing)
		self.main_role:SetIsPingbiDouli(self.is_pinbi_douli)
		self.main_role:SetIsPingbiHands(self.is_pinbi_hands)
		self.main_role:SetIsPingbiPhantom(self.is_pingbi_phantom)
		self.main_role:SetIsPingbiZhenqi(self.is_pinbi_zhenqi)
		self.main_role:SetTitleLayerVisible(not self.is_no_title)
		self.main_role:SetNameLayerSimple(self.is_simple_name)
	end
	return self.main_role
end

function Scene:ChangeMainRoleObjId(obj_id)
	self.obj_list[self.main_role:GetObjId()] = nil
	self.main_role:GetVo().obj_id = obj_id
	self.obj_list[obj_id] = self.main_role
end

function Scene:CreateRole(role_vo)
	local role = self:CreateObj(role_vo, SceneObjType.Role)
	if nil ~= role then
		self.total_role_count = self.total_role_count + 1
		if self:IsNeedLimitAppear() then
			self:AddToAppearLimitList(role)
		else
			self:RefreshPingBiRoleOne(role)
		end
	end
	return role
end

function Scene:CreateMonster(monster_vo)
	local monster = self:CreateObj(monster_vo, SceneObjType.Monster)
	monster:SetNameLayerShow(self.is_show_monster_name)
	return monster
end

function Scene:CreateFallItem(fallitem_vo)
	local fall_item = self:CreateObj(fallitem_vo, SceneObjType.FallItem)
	fall_item:SetNameLayerVisible(not self.is_no_fall_name)
	return fall_item
end

function Scene:CreateGather(gather_vo)
	return self:CreateObj(gather_vo, SceneObjType.GatherObj)
end

function Scene:CreateNpc(npc_vo)
	return self:CreateObj(npc_vo, SceneObjType.Npc)
end

function Scene:CreateDecoration(decoration_vo)
	return self:CreateObj(decoration_vo, SceneObjType.Decoration)
end

--拾取场景所有物品 pick_callback 回调函数  duration 默认为1
function Scene:PickAllItemByFly(pick_callback,duration)
	if Scene.Instance.isPickFling then return end
	Scene.Instance.isPickFling = true
	duration = duration or 0.6
	local itemlist = self:GetFallItemList()
	local main_role = self:GetMainRole()
	local target_x,target_y = main_role:GetLogicPos();
	local move_end_pos = HandleRenderUnit:LogicToWorld({x=target_x,y=target_y})
	move_end_pos.y = move_end_pos.y + 70  --人物胸口位置
	for __,v in pairs(itemlist) do
		local node = v:GetModel():_EnsureCoreNode(GRQ_SCENE_OBJ)
		local move = cc.EaseSineIn:create(cc.MoveTo:create(duration, move_end_pos))
		local seq = cc.Sequence:create(move)
		node:runAction(seq)
	end
	GlobalTimerQuest:AddDelayTimer(function() 
		local itemlist = Scene.Instance:GetFallItemList()
		local awards = {}
		for __,v in pairs(itemlist) do
			table.insert(awards,{type=0,id=v:GetItemID(),count=1})
			Scene.Instance:ScenePickItem(v:GetObjId())
		end
		Scene.Instance.isPickFling = nil
		if pick_callback then
			pick_callback(awards)
		end	
	end,duration+0.1)
end

function Scene:CreateEffectObj(effectobj_vo)
	-- if effectobj_vo.deliverer_obj_id ~= self.main_role:GetObjId() then
	-- 	if self.is_pingbi_skill_effect or ClientCmdCtrl.Instance:IsMemoryLack() then
	-- 		return nil
	-- 	end
	-- else
	-- 	if self.is_pingbi_self_skill_effect then
	-- 		return
	-- 	end
	-- end
	if Story.Instance:GetIsStoring() then
		return
	end

	return self:CreateObj(effectobj_vo, SceneObjType.EffectObj)
end

function Scene:CreateSpecialObj(special_vo)
	return self:CreateObj(special_vo, SceneObjType.SpecialObj)
end

function Scene:CreateFireObj(fireobj_vo)
	return self:CreateObj(fireobj_vo, SceneObjType.FireObj)
end

function Scene:CreateObj(vo, obj_type)
	if self.obj_list[vo.obj_id] then
		return nil
	end

	if 0 == vo.obj_id then
		vo.obj_id = self:GetClientObjId()
	end

	local obj = nil
	if obj_type == SceneObjType.Monster then
		obj = Monster.New(vo)
	elseif obj_type == SceneObjType.Role then
		obj = Role.New(vo)
	elseif obj_type == SceneObjType.MainRole then
		obj = MainRole.New(vo)
	elseif obj_type == SceneObjType.FallItem then
		obj = FallItem.New(vo)
	elseif obj_type == SceneObjType.Npc then
		obj = Npc.New(vo)
	elseif obj_type == SceneObjType.Decoration then
		obj = Decoration.New(vo)
	elseif obj_type == SceneObjType.EffectObj then
		obj = EffectObj.New(vo)
	elseif obj_type == SceneObjType.SpecialObj then
		obj = SpecialObj.New(vo)
	elseif obj_type == SceneObjType.FireObj then
		obj = FireObj.New(vo)
	elseif obj_type == SceneObjType.DirOreObj then
		obj = DigOreShow.New(vo)
	end

	if nil == obj then
		ErrorLog("Unknow obj type", obj_type)
		return
	end

	obj:Init(self)

	if obj:GetObjId() then
		self.obj_list[obj:GetObjId()] = obj
	end

	if obj:GetObjKey() and 0 ~= obj:GetObjKey() then
		if nil == self.obj_group_list[obj_type] then
			self.obj_group_list[obj_type] = {}
		end
		self.obj_group_list[obj_type][obj:GetObjKey()] = obj
	end

	obj:CreateEnd()

	GlobalEventSystem:Fire(ObjectEventType.OBJ_CREATE, obj)
	return obj
end

function Scene:ClearDigOreShow()
	for i,v in ipairs(self.obj_group_list[SceneObjType.DirOreObj]) do
		-- GlobalEventSystem:Fire(ObjectEventType.OBJ_DELETE, v)
		v:DeleteMe()
	end
	self.obj_group_list[SceneObjType.DirOreObj] = {}
end

function Scene:DelObjHelper(obj_id)
	local del_obj = self.obj_list[obj_id]
	if del_obj then
		if del_obj == self.main_role then
			Log("Scene:DeleteObj warning: try to remove mainrole")
			return
		end
		self:RemoveFromAppearLimitList(del_obj)
		if del_obj:GetType() == SceneObjType.Role then
			self.total_role_count = self.total_role_count - 1
			if self.total_role_count < 0 then self.total_role_count = 0 end
		end

		self.obj_list[obj_id] = nil

		if nil ~= self.obj_group_list[del_obj:GetType()] then
			self.obj_group_list[del_obj:GetType()][del_obj:GetObjKey()] = nil
		end

		self.obj_move_info_list[del_obj:GetObjId()] = nil

		GlobalEventSystem:Fire(ObjectEventType.OBJ_DELETE, del_obj)
		del_obj:DeleteMe()
	end
end

function Scene:DeleteObj(obj_id)
	if self.is_in_update then
		-- update过程延迟删除
		if self.obj_list[obj_id] then
			table.insert(self.delay_handle_funcs, BindTool.Bind(self.DelObjHelper, self, obj_id))
		end
	else
		-- 直接删除对象
		self:DelObjHelper(obj_id)
	end
end

function Scene:DeleteObjByTypeAndKey(obj_type, obj_key)
	if nil ~= self.obj_group_list[obj_type] then
		local obj = self.obj_group_list[obj_type][obj_key]
		if nil ~= obj then
			self:DeleteObj(obj:GetObjId())
		end
	end
end

function Scene:GetObjectByObjId(obj_id)
	return self.obj_list[obj_id]
end

-- 检查一个对象引用 是否有效
function Scene:CheckObjRefIsValid(obj, obj_id)
	return self.obj_list[obj_id] == obj
end

function Scene:GetObjectByTypeAndKey(obj_type, obj_key)
	if nil ~= self.obj_group_list[obj_type] then
		return self.obj_group_list[obj_type][obj_key]
	end
	return nil
end

function Scene:GetObjectByRoleId(role_id)
	for k,v in pairs(self.obj_list) do
		if v:GetType() == SceneObjType.Role and v.vo.role_id == role_id then
			return v
		end
	end
	return nil
end

function Scene:GetRoleByObjId(obj_id)
	local obj = self.obj_list[obj_id]
	if nil ~= obj and obj:IsRole() then
		return obj
	end

	return nil
end

function Scene:InitClientObj()
	if not self.scene_config then
		return
	end
end

function Scene.CalcSceneIndex(obj_type, cfg_index)
	return obj_type * 100000 + cfg_index
end

-- 是否工会成员
function Scene:IsGuildMember(target_obj)
	return RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GUILD_ID) == target_obj:GetVo()[OBJ_ATTR.ACTOR_GUILD_ID] and target_obj:GetVo()[OBJ_ATTR.ACTOR_GUILD_ID] ~= 0
end

-- 是否友方
function Scene:IsFriend(target_obj)
	return self.scene_logic:IsFriend(target_obj, self.main_role)
end

-- 是否敌方
function Scene:IsEnemy(target_obj)
	return self.scene_logic:IsEnemy(target_obj, self.main_role)
end

-- 选取最近的对象
function Scene:SelectObjHelper(obj_list, x, y, distance_limit, select_type)
	local target_obj = nil
	local target_distance = distance_limit

	for _, v in pairs(obj_list) do
		if v:IsCharacter() or v:GetModel():IsVisible() then 
			local can_select = true
			if SelectType.Friend == select_type then
				can_select = self.scene_logic:IsFriend(v, self.main_role)
			elseif SelectType.Enemy == select_type then
				can_select = self.scene_logic:IsEnemy(v, self.main_role)
			elseif SelectType.Alive == select_type then
				can_select = not v:IsRealDead()
			end

			-- if self:GetIsInAppearLimitList(v) then --限制显示的不让选择
			-- 	can_select = false
			-- end

			if can_select then
				local target_x, target_y = v:GetLogicPos()
				local distance = GameMath.GetDistance(x, y, target_x, target_y, false)
				if distance < target_distance then
					if v:IsInBlock() then
						if nil == target_obj then
							target_obj = v
						end
					else
						target_obj = v
						target_distance = distance
					end
				end
			end
		end
	end

	return target_obj, target_distance
end

--选择指定id的最近的怪物
function Scene:SelectMinDisMonster(monster_id, distance_limit)
	if monster_id == 0 then return nil end
	
	local target_obj = nil
	local target_distance = distance_limit or 50
	target_distance = target_distance * target_distance
	local main_role_x, main_role_y = self.main_role:GetLogicPos()

	for _, v in pairs(self:GetMonsterList()) do
		if v:GetVo().monster_id == monster_id and not v:IsDead() then
			local target_x, target_y = v:GetLogicPos()
			local distance = GameMath.GetDistance(main_role_x, main_role_y, target_x, target_y, false)
			if distance < target_distance then
				if v:IsInBlock() then
					if nil == target_obj then
						target_obj = v
					end
				else
					target_obj = v
					target_distance = distance
				end
			end
		end
	end
	return target_obj
end

--获取最近的Boss
function Scene:GetMinDisBoss()
	local boss_id, x, y = 0, 0, 0
	local target_distance = 1000 * 1000
	local main_role_x, main_role_y = self.main_role:GetLogicPos()

	for _, v in pairs(BossData.Instance:GetOneSceneBossList(self:GetSceneId())) do
		local target_x, target_y = MapData.GetMapBossPos(self:GetSceneId(), v)
		local distance = GameMath.GetDistance(main_role_x, main_role_y, target_x, target_y, false)
		if distance < target_distance then
			boss_id = v
			x, y = target_x, target_y
			target_distance = distance
		end
	end
	return boss_id, x, y
end

--选择指定id的最近的采集物
function Scene:SelectMinDisGather(gather_id, distance_limit)
	local target_obj = nil
	local target_distance = distance_limit or 50
	target_distance = target_distance * target_distance
	local main_role_x, main_role_y = self.main_role:GetLogicPos()

	for _, v in pairs(self:GetGatherList()) do
		if v:GetVo().gather_id == gather_id then
			local target_x, target_y = v:GetLogicPos()
			local distance = GameMath.GetDistance(main_role_x, main_role_y, target_x, target_y, false)
			if distance < target_distance then
				target_obj = v
				target_distance = distance
			end
		end
	end

	return target_obj
end

-- 选择最近的可拾取掉落
function Scene:SelectMinRemindFallItem(distance_limit, ignore_setting)
	local target_obj = nil
	local target_distance = distance_limit or 50
	target_distance = target_distance * target_distance
	local main_role_x, main_role_y = self.main_role:GetLogicPos()
	local main_role_dir = self.main_role:GetDirNumber()
	local target_dir = 9

	for _, v in pairs(self:GetFallItemList()) do
		if v:CanPick(ignore_setting) then
			local target_x, target_y = v:GetLogicPos()
			local distance = GameMath.GetDistance(main_role_x, main_role_y, target_x, target_y, false)
			if distance <= target_distance then
				local dir = GameMath.GetDirectionNumber(target_x - main_role_x, target_y - main_role_y)
				-- 选择最近的，距离相同时优先同方向，其次向上开始顺时针优先
				if distance < target_distance or dir == main_role_dir or (target_dir ~= main_role_dir and dir < target_dir) then
					target_obj = v
					target_distance = distance
					target_dir = dir
				end
			end
		end
	end

	--判断是否继续拾取上次选择物品
	-- for _, v in pairs(self:GetFallItemList()) do
	-- 	if self.last_select_fall_item == v then
	-- 		return self.last_select_fall_item
	-- 	end
	-- end

	-- for _, v in pairs(self:GetFallItemList()) do
	-- 	if v:CanPick(ignore_setting) then
	-- 		local target_x, target_y = v:GetLogicPos()
	-- 		local distance = GameMath.GetDistance(main_role_x, main_role_y, target_x, target_y, false)

	-- 		if distance <= target_distance then
	-- 			local dir = GameMath.GetDirectionNumber(target_x - main_role_x, target_y - main_role_y)
	-- 			-- 选择最近的，距离相同时优先同方向，其次向上开始顺时针优先
	-- 			if distance < target_distance or dir == main_role_dir or (target_dir ~= main_role_dir and dir < target_dir) then
	-- 				target_obj = v
	-- 				target_distance = distance
	-- 				target_dir = dir
	-- 			end
	-- 		end
	-- 	end
	-- end


	-- self.last_select_fall_item = target_obj

	return target_obj
end

function Scene:CanPickFallItem()
	if not next(self:GetFallItemList()) or BagData.Instance:GetEmptyNum() <= 0 then
		return false
	end

	for _, v in pairs(self:GetFallItemList()) do
		if v:CanPick() then
			return true
		end
	end

	return false
end

-- 主线拾取
function Scene:GetIsTask()
	local is_pick = true
	local fb_id = Scene.Instance:GetFuBenId()
	for k, v in pairs(CleintFubenPick) do
		if fb_id == v then
			if Scene.Instance:CanPickFallItem() then
				is_pick = false
				break
			end
		end
	end
	
	return is_pick
end

function Scene:GetNpcByNpcId(npc_id)
	for _, v in pairs(self:GetObjListByType(SceneObjType.Npc)) do
		if v:GetNpcId() == npc_id then
			return v
		end
	end
	return nil
end

local empty_table = {}
function Scene:GetObjListByType(obj_type)
	return self.obj_group_list[obj_type] or empty_table
end

function Scene:GetRoleList()
	return self.obj_group_list[SceneObjType.Role] or empty_table
end

function Scene:GetMonsterList()
	return self.obj_group_list[SceneObjType.Monster] or empty_table
end

function Scene:GetNpcList()
	return self.obj_group_list[SceneObjType.Npc] or empty_table
end

function Scene:GetGatherList()
	return self.obj_group_list[SceneObjType.Gather] or empty_table
end

function Scene:GetFallItemList()
	return self.obj_group_list[SceneObjType.FallItem] or empty_table
end

function Scene:GetSpecialObjList()
	return self.obj_group_list[SceneObjType.SpecialObj] or empty_table
end

function Scene:GetSpecialObjExpFireList()
	local fire_obj = {}
	for k, v in pairs(self.obj_group_list[SceneObjType.SpecialObj] or empty_table) do
		if v.vo and WeiZhiAnDianCfg.FireId[v.vo.model_id] then
			table.insert(fire_obj, v)
		end
	end

	table.sort(fire_obj, function (a, b)
		return a.vo.model_id > b.vo.model_id
	end)

	return fire_obj
end

function Scene:GetObjMoveInfoList()
	return self.obj_move_info_list
end

function Scene:OnMainRolePosChange(x, y)

end

function Scene:OnMainRoleMoveStart()

end

function Scene:OnMainRoleMoveEnd()

end

function Scene:OnMainRoleDead(main_role)
	main_role:ClearPathInfo()
	GuajiCtrl.Instance:ClearAllOperate()
end

function Scene:CheckClientObj()
	if not self.scene_config then
		return
	end
	local rect = HandleRenderUnit:GetCoreScene():GetViewRect()
	for k, v in pairs(self.scene_config.decorations) do
		local x, y = HandleRenderUnit:LogicToWorldXY(v.x, v.y)
		x = x * HandleGameMapHandler:GetCameraScale()
		y = y * HandleGameMapHandler:GetCameraScale()
		
		if GameMath.IsInRect(x, y, rect.x, rect.y, rect.width, rect.height) then
			if nil == self:GetObjectByTypeAndKey(SceneObjType.Decoration, k) then
				local decoration_vo = GameVoManager.Instance:CreateVo(DecorationVo)
				decoration_vo.obj_key = k
				decoration_vo.decoration_id = v.id
				decoration_vo.name = v.name
				decoration_vo.pos_x = v.x
				decoration_vo.pos_y = v.y
				local decoration = self:CreateDecoration(decoration_vo)
			end
		else
			self:DeleteObjByTypeAndKey(SceneObjType.Decoration, k)
		end
	end
end

-- 场景配置
function Scene:GetSceneServerConfig(scene_id)
	local cfg = ConfigManager.Instance:GetConfig("scripts/config/server/envir/scene/scene" .. (scene_id or self:GetSceneId()))
	return cfg and cfg[1]
end

----------------------------------------------------
-- 在场景上生成一次性特效
----------------------------------------------------
function Scene:CreateOnceEffect(effect_id, pos_x, pos_y, layer, end_callback, res_path)
	local effect = nil
	function callback_func()
		if end_callback ~= nil then
			end_callback()
		end
		NodeCleaner.Instance:AddNode(effect)
	end

	local res_path = res_path or ResPath.GetEffectAnimPath
	local anim_path, anim_name = res_path(effect_id)
	effect = RenderUnit.CreateAnimSprite(anim_path, anim_name, FrameTime.Effect, 1, false, callback_func)
	effect:setPosition(pos_x, pos_y)
	HandleRenderUnit:GetCoreScene():addChildToRenderGroup(effect, layer or GRQ_SCENE_OBJ)

	return effect
end

function Scene:CreateOnceUiEffect(effect_id, pos_x, pos_y, layer, end_callback)
	local effect = nil
	function callback_func()
		if end_callback ~= nil then
			end_callback()
		end
		NodeCleaner.Instance:AddNode(effect)
	end

	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
	effect = RenderUnit.CreateAnimSprite(anim_path, anim_name, FrameTime.Effect, 1, false, callback_func)
	effect:setPosition(pos_x, pos_y)
	HandleRenderUnit:AddUi(effect, layer or COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)

	return effect
end

function Scene.PlayOneFlyEffect(effect_id, time, pos_x, pos_y, layer, end_callback)
	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	local screen_w_m = screen_w * 0.5
	local screen_h_m = screen_h * 0.5
	pos_x = pos_x or screen_w_m
	pos_y = pos_y or screen_h_m

	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id or 918)
	local fly_effect = AnimateSprite:create(anim_path, anim_name, 99, FrameTime.Effect, false)
	fly_effect:setPosition(pos_x, pos_y)
	HandleRenderUnit:AddUi(fly_effect, layer or COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)

	-- local bezier_to = cc.BezierTo:create(time or 1.4, {cc.p(screen_w * math.random(), screen_h * 0.9), cc.p(screen_w * math.random(), pos_y), cc.p(screen_w_m, 3)})
	local bezier_to = cc.BezierTo:create(time or 1.4, {cc.p(screen_w * math.random(), screen_h * math.random()), cc.p(screen_w * math.random(), pos_y), cc.p(screen_w_m, 3)})
	local callback = cc.CallFunc:create(function ()
		if end_callback ~= nil then
			end_callback()
		end
		fly_effect:setStop()
		NodeCleaner.Instance:AddNode(fly_effect)
	end)
	local action = cc.Sequence:create(bezier_to, callback)
	fly_effect:runAction(action)
end

----------------------------------------------------
-- 屏蔽隐藏控制
----------------------------------------------------
-- 是否是正处于屏蔽其他玩家
function Scene:GetIsPingbiOtherRole()
	return self.is_pingbi_other_role
end

-- 是否是正处于屏蔽工会玩家
function Scene:GetIsPingbiGuildRole()
	return self.is_pingbi_guild_role
end

function Scene:IsPingbiTitle()
	return self.is_no_title or (self.fps_now < fps_title)
end

function Scene:IsPingbiWing()
	return self.is_pinbi_wing or (self.fps_now < fps_wing)
end

function Scene:IsPingbiPhantom()
	return self.is_pingbi_phantom or (self.fps_now < fps_wing)
end

function Scene:IsPingbiDouli()
	return self.is_pinbi_douli or (self.fps_now < fps_douli)
end

function Scene:IsPingbiHands()
	return self.is_pinbi_hands or (self.fps_now < fps_hands)
end

function Scene:IsPingbiZhenqi()
	return self.is_pinbi_hands or (self.fps_now < fps_zhenqi)
end

-- 是否屏蔽战将
function Scene:IsPingbiHero()
	return self.is_pinbi_hero or self.fps_now < fps_hero
end

-- 是否屏蔽宠物
function Scene:IsPingbiPet()
	return self.is_pinbi_pet or self.fps_now < fps_pet
end

-- 是否被隐藏的角色
function Scene:GetIsHidedRole(role)
	if role == nil then return false end

	return not role:GetModel():IsVisible()
end

-- 刷新屏蔽角色
function Scene:RefreshPingBiRole()
	if nil ~= self.obj_group_list[SceneObjType.Role] then
		for k, v in pairs(self.obj_group_list[SceneObjType.Role]) do
			self:RefreshPingBiRoleOne(v)
		end
	end
end

-- 刷新单个屏蔽玩家
function Scene:RefreshPingBiRoleOne(role)
	if role:IsMainRole() then
		return
	end

	if self:GetIsInAppearLimitList(role) then
		return
	end

	self:SetRoleVisible(role, not self:IsNeedPingBiRole(role))
end

-- 刷新屏蔽战将
function Scene:RefreshPingBiHero()
	local is_visible = not self:IsPingbiHero()

	for k, v in pairs(self:GetObjListByType(SceneObjType.Monster)) do
		if v:IsHero() then
			v:GetModel():SetVisible(is_visible)
		end
	end
end

-- 刷新屏蔽宠物
function Scene:RefreshPingBiPet()
	local is_visible = not self:IsPingbiPet()
	for k, v in pairs(self:GetObjListByType(SceneObjType.Monster)) do
		if v:IsPet() then
			v:GetModel():SetVisible(is_visible)
		end
	end
end

-- 刷新缩小宠物
-- function Scene:RefreshLittlePet()
-- 	for k, v in pairs(self:GetObjListByType(SceneObjType.Monster)) do
-- 		if v:IsPet() then
-- 			v:GetModel():SetScale(self.is_little_pet and 0.66 or 1)
-- 		end
-- 	end
-- end

-- 刷新屏蔽怪
function Scene:RefreshPingBiMonster()
	if nil ~= self.obj_group_list[SceneObjType.Monster] then
		for k, v in pairs(self.obj_group_list[SceneObjType.Monster]) do
			if v:IsCommon() then
				v:GetModel():SetVisible(not self.is_pinbi_monster)
			end
		end
	end
end

-- 刷新屏蔽角色
function Scene:RefreshPingBiRole()
	if nil ~= self.obj_group_list[SceneObjType.Role] then
		for k, v in pairs(self.obj_group_list[SceneObjType.Role]) do
			self:RefreshPingBiRoleOne(v)
		end
	end
end

--设置角色相关的可见性
function Scene:SetRoleVisible(role, role_v)
	if role == nil or 1 == role:GetVo().is_shadow then return end

	role:GetModel():SetVisible(role_v)
	role:SetIsPingbiChibang(self:IsPingbiWing())
	role:SetIsPingbiPhantom(self:IsPingbiPhantom())
	role:SetIsPingbiDouli(self:IsPingbiDouli())
	role:SetTitleLayerVisible(not self:IsPingbiTitle())
	role:SetNameLayerSimple(self.is_simple_name)
end

-- 是否是要屏蔽的角色
function Scene:IsNeedPingBiRole(role)
	if 1 == role:GetVo().is_shadow then
		 return false
	end
	local is_pingbi = false

	if self.is_pingbi_other_role then
		if not role:IsAtkMainRole() then
			is_pingbi = true
		end
	else
		if self.is_pingbi_guild_role and self:IsGuildMember(role) then
			is_pingbi = true
		end
	end
	return is_pingbi
end

-- 系统设置改变
function Scene:OnSysSettingChange(setting_type, flag)
	if setting_type == SETTING_TYPE.SHIELD_OTHERS then
		self.is_pingbi_other_role = flag
		self:RefreshPingBiRole()
	elseif setting_type == SETTING_TYPE.SHIELD_SAME_CAMP then
		self.is_pingbi_guild_role = flag
		self:RefreshPingBiRole()
	elseif setting_type == SETTING_TYPE.CLOSE_TITLE then
		self.is_no_title = flag
		self:RefreshTitleView()
	elseif setting_type == SETTING_TYPE.SIMPLE_ROLE_NAME then
		self.is_simple_name = flag
		self:RefreshNameView()
	elseif setting_type == SETTING_TYPE.SHIELD_FALL_NAME then
		self.is_no_fall_name = flag
		self:RefreshFallNameView()
	elseif setting_type == SETTING_TYPE.SHIELD_MONSTER_NAME then
		self.is_show_monster_name = flag
		self:RefreshMonsterNameView()
	elseif setting_type == SETTING_TYPE.SHIELD_MONSTER then
		self.is_pinbi_monster = flag
		self:RefreshPingBiMonster()
	elseif setting_type == SETTING_TYPE.SHIELD_PET then
		self.is_pinbi_pet = flag
		self:RefreshPingBiPet()
	-- elseif setting_type == SETTING_TYPE.SHIELD_HERO then
	-- 	self.is_pinbi_hero = flag
	-- 	self:RefreshPingBiHero()
	elseif setting_type == SETTING_TYPE.SHIELD_WING then
		self.is_pinbi_wing = flag
		self:RefreshPingBiWing()
	elseif setting_type == SETTING_TYPE.SHIELD_HATS then
		self.is_pinbi_douli = flag
		self:RefreshPingBiDouli()
	elseif setting_type == SETTING_TYPE.SHIELD_HANDS then
		self.is_pinbi_hands = flag
		self:RefreshPingBiHands()
	elseif setting_type == SETTING_TYPE.SHIELD_ZHENQI then
		self.is_pinbi_zhenqi = flag
		self:RefreshPingBiZhenqi()
	-- elseif setting_type == SETTING_TYPE.SHIELD_PHANTOM then
	-- 	self.is_pingbi_phantom = flag
	-- 	self:RefreshPingBiPhantom()
	end
end

-- 挂机设置改变
function Scene:OnGuaJiSettingChange(guaji_setting_type, flag)
	if GUAJI_SETTING_TYPE.GUAJI_PICKUP == guaji_setting_type then
		self.pick_color_flag = flag
	end
end

-- 是否自动屏蔽
function Scene:OnFpsShieldChange(value)
	self.fps_shield = value
	self:OnFpsCallback(31)
	if not value then
		for k,v in pairs(self.limit_appear_role_list) do
			self:SetRoleVisible(v, true)
		end
		self.limit_appear_role_list = {}
		GlobalEventSystem:Fire(SceneEventType.SCENE_HAS_FPS_SHIELD, false)
	end
end

-- 设置是否屏蔽精灵
function Scene:SetPingBiSprite(is_pingbi_sprite)
	if self.is_pingbi_sprite ~= is_pingbi_sprite then
		self.is_pingbi_sprite = is_pingbi_sprite
		self:RefreshPingBiRole()

		local sprite_obj = self.main_role:GetspriteObj()
		if nil ~= sprite_obj then
			sprite_obj:GetModel():SetVisible(not self.is_pingbi_sprite)
		end
	end
end

-- 帧率回调
function Scene:OnFpsCallback(fps)
	if not self.fps_shield then
		fps = math.max(fps, 31)
	end
	local old_fps = self.fps_now
	self.fps_now = fps
	if fps <= 30 then
		local appear_count = math.floor(SceneAppearRoleCount.Max * (1 - (30 - fps) / 10))
		self:SetMaxAppearRoleCount(appear_count)
	else
		self:SetMaxAppearRoleCount(SceneAppearRoleCount.Max)
	end

	local buffer_val = 5
	if (old_fps >= fps_title and fps < fps_title) or (old_fps < fps_title and fps >= (fps_title + buffer_val))then
		self:RefreshTitleView()
	end
	if (old_fps >= fps_wing and fps < fps_wing) or (old_fps < fps_wing and fps >= (fps_wing + buffer_val)) then
		self:RefreshPingBiWing()
	end
	if (old_fps >= fps_douli and fps < fps_douli) or (old_fps < fps_douli and fps >= (fps_douli + buffer_val)) then
		self:RefreshPingBiDouli()
	end
	if (old_fps >= fps_hands and fps < fps_hands) or (old_fps < fps_hands and fps >= (fps_hands + buffer_val)) then
		self:RefreshPingBiHands()
	end
	if (old_fps >= fps_hero and fps < fps_hero) or (old_fps < fps_hero and fps >= (fps_hero + buffer_val)) then
		self:RefreshPingBiHero()
	end
	if (old_fps >= fps_pet and fps < fps_pet) or (old_fps < fps_pet and fps >= (fps_pet + buffer_val)) then
		self:RefreshPingBiPet()
	end
	if (old_fps >= fps_zhenqi and fps < fps_zhenqi) or (old_fps < fps_zhenqi and fps >= (fps_zhenqi + buffer_val)) then
		self:RefreshPingBiZhenqi()
	end
end

----------------------------------------------------
-- 角色个数控制
----------------------------------------------------
function Scene:IsNeedLimitAppear()
	return self.total_role_count > self.max_appear_role_count
end

function Scene:AddToAppearLimitList(role_obj)
	if role_obj == nil or role_obj:GetType() ~= SceneObjType.Role then return end

	self.limit_appear_role_list[role_obj:GetObjId()] = role_obj
	GlobalEventSystem:Fire(SceneEventType.SCENE_HAS_FPS_SHIELD, true)
	self:SetRoleVisible(role_obj, false)
end

function Scene:RemoveFromAppearLimitList(role_obj)
	if role_obj == nil or role_obj:GetType() ~= SceneObjType.Role then return end

	self.limit_appear_role_list[role_obj:GetObjId()] = nil
	GlobalEventSystem:Fire(SceneEventType.SCENE_HAS_FPS_SHIELD, nil ~= next(self.limit_appear_role_list))
end

function Scene:GetIsInAppearLimitList(role_obj)
	if role_obj == nil then return end
	return nil ~= self.limit_appear_role_list[role_obj:GetObjId()]
end

function Scene:RefreshTitleView()
	local is_visible = not self:IsPingbiTitle()

	self.main_role:SetTitleLayerVisible(not self.is_no_title)

	for k,v in pairs(self:GetObjListByType(SceneObjType.Role)) do
		v:SetTitleLayerVisible(is_visible)
	end
end

function Scene:RefreshPingBiWing()
	local is_pinbi = self:IsPingbiWing()

	self.main_role:SetIsPingbiChibang(self.is_pinbi_wing)

	for k,v in pairs(self:GetObjListByType(SceneObjType.Role)) do
		v:SetIsPingbiChibang(is_pinbi)
	end

	for k,v in pairs(self:GetObjListByType(SceneObjType.Monster)) do
		if v:IsHero() then
			v:SetIsPingbiChibang(is_pinbi)
		end
	end
end

function Scene:RefreshPingBiPhantom()
	local is_pinbi = self:IsPingbiPhantom()

	self.main_role:SetIsPingbiPhantom(self.is_pingbi_phantom)

	for k,v in pairs(self:GetObjListByType(SceneObjType.Role)) do
		v:SetIsPingbiPhantom(is_pinbi)
	end
end

function Scene:RefreshPingBiDouli()
	local is_pinbi = self:IsPingbiDouli()

	self.main_role:SetIsPingbiDouli(self.is_pinbi_douli)

	for k,v in pairs(self:GetObjListByType(SceneObjType.Role)) do
		v:SetIsPingbiDouli(is_pinbi)
	end
end

function Scene:RefreshPingBiHands()
	local is_pinbi = self:IsPingbiHands()

	self.main_role:SetIsPingbiHands(self.is_pinbi_hands)

	for k,v in pairs(self:GetObjListByType(SceneObjType.Role)) do
		v:SetIsPingbiHands(self.is_pinbi_hands)
	end
end

function Scene:RefreshPingBiZhenqi()
	local is_pinbi = self:IsPingbiZhenqi()

	self.main_role:SetIsPingbiZhenqi(self.is_pinbi_zhenqi)

	for k,v in pairs(self:GetObjListByType(SceneObjType.Role)) do
		v:SetIsPingbiZhenqi(self.is_pinbi_zhenqi)
	end
end

function Scene:RefreshNameView()
	self.main_role:SetNameLayerSimple(self.is_simple_name)

	for k,v in pairs(self:GetObjListByType(SceneObjType.Role)) do
		v:SetNameLayerSimple(self.is_simple_name)
	end
end

function Scene:RefreshFallNameView()
	for k,v in pairs(self:GetObjListByType(SceneObjType.FallItem)) do
		v:SetNameLayerVisible(not self.is_no_fall_name)
	end
end

function Scene:RefreshMonsterNameView()
	for k,v in pairs(self:GetObjListByType(SceneObjType.Monster)) do
		if v:GetType() == SceneObjType.Monster then
			v:SetNameLayerShow(self.is_show_monster_name)
		end
	end
end

-- 设置同屏最大人数限制
function Scene:SetMaxAppearRoleCount(appear_count)
	local old_count = self.max_appear_role_count
	self.max_appear_role_count = math.min(appear_count, SceneAppearRoleCount.Max)
	self.max_appear_role_count = math.max(appear_count, SceneAppearRoleCount.Min)
	if self.max_appear_role_count >= old_count then
		return
	end

	-- 已屏蔽数量
	local scene_pingbi_count = 0
	for k, v in pairs(self.limit_appear_role_list) do
		scene_pingbi_count = scene_pingbi_count + 1
	end

	-- 还需要屏蔽数量
	local need_pingbi_count = (self.total_role_count - scene_pingbi_count) - self.max_appear_role_count
	if need_pingbi_count <= 0 then
		return
	end

	for k, v in pairs(self:GetObjListByType(SceneObjType.Role)) do
		if nil == self.limit_appear_role_list[k] then
			self:AddToAppearLimitList(v)

			need_pingbi_count = need_pingbi_count - 1
			if need_pingbi_count <= 0 then
				break
			end
		end
	end
end

-- 获取特效数量
-- @return 总数，相同数
function Scene:GetEffectCount(effect_id)
	local total_count, same_count = 0, 0

	for k, v in pairs(self:GetObjListByType(SceneObjType.EffectObj)) do
		total_count = total_count + 1
		if v:GetVo().effect_id == effect_id then
			same_count = same_count + 1
		end
	end

	return total_count, same_count
end

----------------------------------------------------
-- 场景缩放
----------------------------------------------------
function Scene:SetSceneCameraScaleTo(scale, use_time)
	scale = scale or 1
	use_time = use_time or 1
	if scale > 0 and scale ~= HandleGameMapHandler:GetCameraScale() then
		Log("场景缩放到:", use_time, scale)
		self.camera_end_scale = scale
		self.camera_scale_speed = (scale - HandleGameMapHandler:GetCameraScale()) / use_time
	end
end

----------------------------------------------------
-- 场景区域
----------------------------------------------------
function Scene:GetSceneAreaInfo(scene_id)
	scene_id = scene_id or self:GetSceneId()
	-- if nil ~= self.scene_area_info_list[scene_id] then
	-- 	return self.scene_area_info_list[scene_id]
	-- end

	-- if scene_id and nil == self.scene_area_req_list[scene_id] then
	-- 	self.scene_area_req_list[scene_id] = true
	-- 	local protocol = ProtocolPool.Instance:GetProtocol(CSSceneAreaInfoReq)
	-- 	protocol.scene_id = scene_id or 0
	-- 	protocol:EncodeAndSend()
	-- end
	local cfg = ConfigManager.Instance:GetServerSceneConfig(scene_id)[1].area
	if nil == self.scene_area_info_list[scene_id] then

		local default_index = nil
		for k,v in pairs(cfg) do
			local point_list = {}
			local idx = 1
			for i = 1, #v.range / 2 do
				point_list[#point_list].x = v.range[idx]
				idx = idx + 1
				point_list[#point_list].y = v.range[idx]
				idx = idx + 1
			end

			-- 找出默认区域
			if not default_index and #point_list == 3 then
				local fit_num = 0
				for i = 1, #MAP_AREA_DEFAULT_PARAM do
					if point_list[i].x == MAP_AREA_DEFAULT_PARAM[i].x
						and	point_list[i].y == MAP_AREA_DEFAULT_PARAM[i].y then
						fit_num = fit_num + 1
					else
						break
					end
				end
				if fit_num == 3 then
					default_index = k
				end
			end

			-- 是否是危险区域
			v.is_danger = v.area_name == Language.Map.DangerArea
			-- 区域颜色
			v.name_color = v.is_danger and COLOR3B.RED or COLOR3B.GREEN
		end

		if default_index then
			local default_area = table.remove(cfg, default_index)
			self.scene_area_info_list[scene_id] = {
				default_area = default_area,
				area_list = cfg
			}
			GlobalEventSystem:Fire(ObjectEventType.OBJ_ATTR_CHANGE)
		end
	end
	return self.scene_area_info_list[scene_id] or {}
end

----------------------------------------------------
-- 生成足迹
----------------------------------------------------
function Scene:CreateFootPrint(role, effect_id)
	if role == nil then return end
	if self:GetIsHidedRole(role) then return end

	local pos_x, pos_y = role:GetRealPos()
	self:CreateOnceEffect(effect_id, pos_x, pos_y, GRQ_SHADOW, nil, ResPath.GetEffectUiAnimPath)
end




function Scene:FlyToRolePhoto()
	-- if true then
	-- 	return
	-- end
	local target_node = ViewManager.Instance:GetUiNode("MainUi", "MainuiRoleBar")
	--print(target_node)
	if target_node == nil then
		return
	end


	local screen_w = HandleRenderUnit:GetWidth()
	local screen_h = HandleRenderUnit:GetHeight()
	-- local screen_w_m = screen_w * 0.5 - 300
	-- local screen_h_m = screen_h * 0.5

	for  i = 1, 10 do
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1161)
		local fly_effect = AnimateSprite:create(anim_path, anim_name, 99, FrameTime.Effect, false)
		
		local y = i > 5 and ( screen_h/2 - 200*math.random()) or ( screen_h/2 - 100*math.random())
		local x = i > 5 and ( screen_w/2 - 30*math.random()*i) or ( screen_w/2 + 30*math.random()*(10 - i))
		fly_effect:setPosition(x, y)
		fly_effect:setScale(0.5)
		HandleRenderUnit:AddUi(fly_effect, layer or COMMON_CONSTS.ZORDER_SYSTEM_EFFECT)

		local world_pos = fly_effect:convertToWorldSpace(cc.p(0,0))
		local fly_to_pos = target_node:convertToWorldSpace(cc.p(0,0))
		local move_to =cc.MoveTo:create(0.8, cc.p(fly_to_pos.x + 20*math.random(), fly_to_pos.y + 20*math.random()))
		local callback = cc.CallFunc:create(function ()
			
			if fly_effect then
				fly_effect:setStop()
				NodeCleaner.Instance:AddNode(fly_effect)
			end
		end)
		local action = cc.Sequence:create(move_to, callback)
		fly_effect:runAction(action)
	end
	
end


function Scene:FlyToRolePos(delay_time)
	
	duration = 0.2
	local main_role = self:GetMainRole()
	local target_x,target_y = main_role:GetLogicPos();
	local move_end_pos = HandleRenderUnit:LogicToWorld({x=target_x,y=target_y})
	move_end_pos.y = move_end_pos.y + 70  --人物胸口位置
	local itemlist = Scene.Instance:GetFallItemList()
	for __,v in pairs(itemlist) do
		local node = v:GetModel():_EnsureCoreNode(GRQ_SCENE_OBJ)
		local move = cc.EaseSineIn:create(cc.MoveTo:create(duration, move_end_pos))
		local seq = cc.Sequence:create(move)
		node:runAction(seq)
		
	end
	
	GlobalTimerQuest:AddDelayTimer(function()
		
		local itemlist = Scene.Instance:GetFallItemList()
		local awards = {}
		for __,v in pairs(itemlist) do
			table.insert(awards,{type=0,id=v:GetItemID(),count=1})
			Scene.Instance:ScenePickItem(v:GetObjId())
		end
		
	end, delay_time)
end

----------------------------------------------------
-- 剧情
----------------------------------------------------
function Scene:InitClientObjId()
	self.client_obj_id_inc = -1
end

function Scene:GetClientObjId()
	self.client_obj_id_inc = self.client_obj_id_inc - 1
	return self.client_obj_id_inc
end


