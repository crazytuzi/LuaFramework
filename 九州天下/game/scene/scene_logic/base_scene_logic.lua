-------------------------------------------
-- 基础副本逻辑
--------------------------------------------
BaseSceneLogic = BaseSceneLogic or BaseClass()
local RemindMinDis = 1500
function BaseSceneLogic:__init()
	self.scene_type = scene_type

	self.next_get_move_obj_time = 0					-- 下次获取移动对象的时间

	self.auto_guaji_time = 0
	self.auto_guaji_rest_time = 5

	self.key_down = false
	self.key_up = false
	self.is_standby = false
	self.hold_beauty_show_time = 0

	self.scene_all_load_complete_event = GlobalEventSystem:Bind(SceneEventType.SCENE_ALL_LOAD_COMPLETE, BindTool.Bind1(self.OnSceneDetailLoadComplete, self))
end

function BaseSceneLogic:__delete()
	self.auto_guaji_time = nil
	self.next_get_move_obj_time = nil
	self.key_down = nil
	self.key_up = nil
	self.is_standby = nil

	GlobalEventSystem:UnBind(self.scene_all_load_complete_event)
end

function BaseSceneLogic:SetSceneType(scene_type)
	self.scene_type = scene_type
end

function BaseSceneLogic:GetSceneType()
	return self.scene_type
end

--播放背景音乐
function BaseSceneLogic:PlayBGM()
	local audio_cfg = ConfigManager.Instance:GetAutoConfig("audio_auto") or {}
	local scene_id = Scene.Instance:GetSceneId()
	local scene_audio_cfg = audio_cfg.scene or {}

	local show_audio_cfg = scene_audio_cfg[scene_id] or nil
	if show_audio_cfg ~= nil then
		local bundle, asset = ResPath.GetBGMResPath(show_audio_cfg.audio_id)
		AudioService.Instance:PlayBgm(bundle, asset)
	end
end

function BaseSceneLogic:OnSceneDetailLoadComplete()
	-- body
end

-- 进入场景
function BaseSceneLogic:Enter(old_scene_type, new_scene_type)
	ViewManager.Instance:Close(ViewName.Map)
	Scene.SendMoveMode(MOVE_MODE.MOVE_MODE_NORMAL)
	GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
	if self.scene_type ~= SceneType.Common then
		--非普通场景关闭聊天界面
		ViewManager.Instance:Close(ViewName.Chat)
		Scene.Instance:ClearMovePosCache()
	end
	self:PlayBGM()
	GlobalEventSystem:Fire(MainUIEventType.PORTRAIT_TOGGLE_CHANGE, false)
	self:CheckMoveCahche()

	local scene_id = Scene.Instance:GetSceneId()
	if (scene_id >= 9010 and scene_id <= 9021) or (scene_id == 2002 or scene_id == 2102 or scene_id == 2202) then
		local main_role = GameVoManager.Instance:GetMainRoleVo()
		local attack_mode = main_role.attack_mode
		if attack_mode ~= GameEnum.ATTACK_MODE_ALLIANCE then
			MainUICtrl.Instance:SendSetAttackMode(GameEnum.ATTACK_MODE_ALLIANCE)
		end
	end

	MainUICtrl.Instance:FlushView("check_war_scene")
	self:CheckHasCaptureCaptive()
end

--退出场景
function BaseSceneLogic:Out(old_scene_type, new_scene_type)
	SettingData.Instance:ResetAutoShieldRole()
	GlobalEventSystem:Fire(OtherEventType.FUBEN_QUIT, self.scene_type)
	GlobalTimerQuest:AddDelayTimer(function ()
		self:DelayOut(old_scene_type, new_scene_type)
	end, 0.5)
end

function BaseSceneLogic:DelayOut(old_scene_type, new_scene_type)

end

function BaseSceneLogic:Update(now_time, elapse_time)
	if self:CanGetMoveObj() then
		if now_time >= self.next_get_move_obj_time then
			self.next_get_move_obj_time = now_time + self:GetMoveObjAllInfoFrequency()
			Scene.SendGetAllObjMoveInfoReq()
		end
	end

	-- 场景中，待机5秒以上，设置自动挂机
	self:CheckAutoGuaji(now_time)
end

-- 是否可以拉取移动对象信息
function BaseSceneLogic:CanGetMoveObj()
	return false
end

-- 是否可以取消自动挂机
function BaseSceneLogic:CanCancleAutoGuaji()
	return true
end

function BaseSceneLogic:OnTouchScreen()
	self.auto_guaji_time = Status.NowTime + self.auto_guaji_rest_time
	self.is_standby = false
end

-- 是否自动设置挂机
function BaseSceneLogic:IsSetAutoGuaji()
	return false
end

-- 是否在头上显示特殊图标
function BaseSceneLogic:GetIsShowSpecialImage(scene_obj)
	return false
end

-- 拉取移动对象信息间隔
function BaseSceneLogic:GetMoveObjAllInfoFrequency()
	return 100000
end

-- 是否可以使用气血药
function BaseSceneLogic:CanUseHpDrug()
	return true
end

-- 是否可以移动
function BaseSceneLogic:CanMove()
	return true
end

-- 是否可以屏蔽怪物
function BaseSceneLogic:CanShieldMonster()
	return 1 ~= Scene.Instance:GetCurFbSceneCfg().monster_alwaysshow
end

-- 获取角色名
function BaseSceneLogic:GetRoleNameBoardText(role_vo)
	local name_color = role_vo.name_color or 0
	local t = {}
	local index = 1

	local camp = role_vo.camp or 0
	local camp_data = CampData.Instance:GetCampItemList(role_vo)
	if camp > 0 then
		t[index] = {}
		t[index].color = CAMP_COLOR[camp]
		t[index].text = Language.Common.ScnenCampNameAbbr[camp] .. "·"
		if camp_data.camp_name then
			if camp_data.camp_name == "" or camp_data.camp_name == Language.Common.CampName[camp] then
				-- 名字为空，或者为默认名字时，采取如下显示
				t[index].text = Language.Common.ScnenCampNameAbbr[camp] .. "·"
			else
				-- 否则，采用自定义的国家名字
				t[index].text = camp_data.camp_name .. "·"
			end
		end
		if self:ChangeCampName() then
			local server_group = role_vo.server_group
			local color = server_group == 0 and "#FD563A" or "#097FF4"
			t[index].text = ToColorStr(Language.Convene.ServerGroup[server_group] .. "·",color)
		end
		index = index + 1
	end

	t[index] = {}
	if role_vo.role_id == GameVoManager.Instance:GetMainRoleVo().role_id then
		t[index].color = name_color == EvilColorList.NAME_COLOR_WHITE and TEXT_COLOR.ROLE_YELLOW or COLOR.RED
	else
		local guild_id = GameVoManager.Instance:GetMainRoleVo().guild_id
		local color = COLOR.WHITE
		if guild_id == role_vo.guild_id and guild_id ~= 0 then
			color = COLOR.BLUE
		end
		-- 是否是本国的内奸
		if role_vo.is_neijian > 0 then
			t[index].color = COLOR.RED
		else
			t[index].color = name_color == EvilColorList.NAME_COLOR_WHITE and color or COLOR.RED
		end
	end

	local role_name = role_vo.name or role_vo.role_name
	t[index].text = role_name -- PlayerData.ParseCrossServerUserName(role_name)

	-- local txg_cfg = PataData.Instance:GetCfgByLevel(role_vo.tianxiange_level)
	-- if txg_cfg then
	-- 	index = index + 1
	-- 	t[index] = {}
	-- 	t[index].color = COLOR.YELLOW
	-- 	t[index].text ="·" .. txg_cfg.title_name
	-- end

	return t
end

function BaseSceneLogic:ChangeCampName()
	return false
end

-- 获取角色仙盟名
function BaseSceneLogic:GetGuildNameBoardText(role_vo)
	local t = {}
	local guild_name = role_vo.guild_name or ""

	if "" == guild_name then return t end

	local authority = GuildDataConst.GUILD_POST_AUTHORITY_LIST[role_vo.guild_post]
	local post_name = authority and authority.post or ""

	t[1] = {}
	t[1].color = COLOR.WHITE
	t[1].text = "【" .. guild_name .. "】" .. COMMON_CONSTS.POINT .. post_name

	return t
end

-- 是否友方
function BaseSceneLogic:IsFriend(target_obj, main_role)
	return not self:IsEnemy(target_obj, main_role)
end

local name_t = {}
local color_name = ""
-- 设置角色头上名字的颜色
function BaseSceneLogic:GetColorName(role)
	color_name = ""
	name_t = self:GetRoleNameBoardText(role.vo)
	for k,v in pairs(name_t) do
		color_name = color_name .. "<color=" .. v.color .. ">" .. v.text .. "</color>"
	end
	return color_name
end

-- 是否能走到该坐标
function BaseSceneLogic:GetIsCanMove(x, y)
	return true
end

-- 在不同模式是否敌方
function BaseSceneLogic:AttackModeIsEnemy(target_obj, main_role, shield_others)
	if nil == target_obj or nil == main_role or not target_obj:IsCharacter() then
		return false
	end

	-- if target_obj:GetVo().shadow_type >= ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_KING_STATUES and not shield_others then -- 用于皇城雕像
	-- 	return false
	-- end

	local attack_mode = MainUICtrl.Instance:GetAttckMode()
	if attack_mode == GameEnum.ATTACK_MODE_PEACE then
		return true
	end

	if attack_mode == GameEnum.ATTACK_MODE_GUILD then --是否是同公会
		return main_role:GetVo().guild_id == target_obj:GetVo().guild_id
	end

	if attack_mode == GameEnum.ATTACK_MODE_CAMP then --是否是同国家
		return main_role:GetVo().camp == target_obj:GetVo().camp
	end
end

-- 是否敌方
function BaseSceneLogic:IsEnemy(target_obj, main_role, ignore_table)
	if nil == target_obj or nil == main_role or not target_obj:IsCharacter() then
		return false
	end
	ignore_table = ignore_table or {}	-- 忽略列表

	if main_role:IsRealDead() then												-- 自己死亡
		return false, Language.Fight.SelfDead
	end

	if target_obj:IsRealDead() then												-- 目标死亡
		return false, Language.Fight.TargetDead
	end

	if main_role.vo.hold_beauty_npcid > 0 then									-- 抱美人
		if self.hold_beauty_show_time <= Status.NowTime then
			self.hold_beauty_show_time = Status.NowTime + 0.5
			SysMsgCtrl.Instance:ErrorRemind(Language.Fight.HoldBeautyLimit)
			GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		end
		return false, Language.Fight.HoldBeautyLimit
	end

	if target_obj:GetVo().is_shadow == 1 then									-- 判断军团雕像是否可攻击
		if MainUIData.IsInCampStatueoScene() and CampData.ShowCampStatueFollow() then
			return true
		else
			return false
		end
	end

	if main_role:IsInSafeArea() and not ignore_table[SceneIgnoreStatus.MAIN_ROLE_IN_SAFE] then											-- 自己在安全区
		return false, Language.Fight.InSafe
	end

	if target_obj:IsInSafeArea() and not ignore_table[SceneIgnoreStatus.OTHER_IN_SAFE] then											-- 目标在安全区
		return false, Language.Fight.TargetInSafe
	end

	if target_obj:GetType() == SceneObjType.Role then
		if Scene.Instance:GetSceneForbidPk() then
			return false, Language.Fight.SceneForbidPk
		end


		if main_role:GetVo().level < COMMON_CONSTS.XIN_SHOU_LEVEL then			-- 自己新手
			return false, Language.Fight.XinShou
		end

		if target_obj:GetVo().level < COMMON_CONSTS.XIN_SHOU_LEVEL then			-- 目标新手
			return false, Language.Fight.TargetXinShou
		end

		return self:IsRoleEnemy(target_obj, main_role)

	elseif target_obj:GetType() == SceneObjType.Monster then
		if not BaseSceneLogic.IsAttackMonster(target_obj:GetMonsterId(), target_obj.vo) then	-- 是否可攻击的怪
			return false, Language.Fight.TargetNotAtk
		end
		return self:IsMonsterEnemy(target_obj, main_role)
	end

	return false, Language.Fight.TargetNotAtk
end

-- 是否可攻击的怪
function BaseSceneLogic.IsAttackMonster(monster_id, objvo)
	local monster_config = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[monster_id]
	if nil == monster_config or 0 == monster_config.is_attacked then
		return false
	end

	local camp = PlayerData.Instance.role_vo.camp
	if objvo then
		if IS_ON_CROSSSERVER then
			if objvo.unique_server_camp_id and objvo.unique_server_camp_id.plat_type == 1 and objvo.unique_server_camp_id.server_id == 1 and objvo.unique_server_camp_id.camp_type == 1 then
				return false
			end
		else
			if objvo.monster_camp_type and objvo.monster_camp_type == camp then
				return false
			end
		end
	end

	-- 如果是本国大臣，不允许攻击
	local dachen_id = NationalWarfareData.Instance:GetDachenOtherInfo()
	if dachen_id[1] and dachen_id[1]["camp_".. camp .."_dachen_monster_id"] then
		if dachen_id[1]["camp_".. camp .."_dachen_monster_id"] == monster_id then
			return false, Language.Fight.TargetNotAtk
		end
	end

	-- 如果是本国国旗，不允许攻击
	local guoqi_id = NationalWarfareData.Instance:GetGuoQiOtherInfo()
	if guoqi_id[1] and guoqi_id[1]["camp_".. camp .."_flag_monster_id"] then
		if guoqi_id[1]["camp_".. camp .."_flag_monster_id"] == monster_id then
			return false, Language.Fight.TargetNotAtk
		end
	end

	-- 判断是本国气运塔，不攻击
	local camp_war_fate_other_cfg = NationalWarfareData.Instance:GetCampWarFateOtherCfg()
	local camp_monster_id = camp_war_fate_other_cfg["camp_" .. camp .. "_qiyun_tower_id"]
	if camp_monster_id and camp_monster_id == monster_id then
		return false, Language.Fight.TargetNotAtk
	end

	if Scene.Instance:GetSceneType() == SceneType.MonsterSiegeFb then
		local data = CampData.Instance:GetMonsterSiegeInfo()
		local is_interfere = false
		if data ~= nil then
			local other_camp = data.monster_siege_camp
			if other_camp ~= nil and other_camp > 0 and other_camp ~= camp then
				is_interfere = true
			end
		end

		local monster_siege_id = CampData.Instance:GetOtherByStr("monster_siege_monster_id")
		if is_interfere then
			if monster_siege_id ~= nil and monster_id == monster_siege_id then
				return false, Language.Fight.TargetNotAtk
			end
		else
			local tower_tab = CampData.Instance:GetTowerId()
			if tower_tab[monster_id] ~= nil then
				return false, Language.Fight.TargetNotAtk
			end
		end
	end

	-- 高于boss100级无法攻击boss
	local role_info = GameVoManager.Instance:GetMainRoleVo()
	local main_role_x, main_role_y = Scene.Instance:GetMainRole():GetLogicPos()
	if BossData.Instance:GetBossSceneList(monster_id) and role_info.level > (monster_config.level + 100) then
		local target_dis = GameMath.GetDistance(main_role_x, main_role_y, objvo.pos_x, objvo.pos_y, false)
		if target_dis < RemindMinDis then
			SysMsgCtrl.Instance:ErrorRemind(Language.Fight.LevelHighNotAtk)
		end
		GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
		return false, Language.Fight.LevelHighNotAtk
	end

	if monster_config.camp_type and monster_config.camp_type == camp then
		return false
	end

	if objvo then
		if objvo.special_param == MONSTER_SPECIAL_PARAM.MONSTER_SPECIAL_PARAM_CAPTIVE_MALE 			-- 目标为连服场景中俘虏
			or objvo.special_param == MONSTER_SPECIAL_PARAM.MONSTER_SPECIAL_PARAM_CAPTIVE_FEMALE then
			return
		end
	end

	if monster_id == LianFuDailyData.MiDaoMonsterId or monster_id == LianFuDailyData.QingLouMonsterId then
		local info = LianFuDailyData.Instance:GetXYCityGroupCfg(role_info.server_group)
		if Scene.Instance:GetSceneId() == info.scene_id then
			return false
		end
	end

	if Scene.Instance:GetSceneType() == SceneType.CrossGuildBattle then
		if monster_id == LianFuDailyData.FlagId[role_info.server_group] then
			return false
		end
	end

	if BossData.Instance:CheckIsBabyBoss(monster_id) then
		if not BossData.Instance:CheckIsCanAck() then
			SysMsgCtrl.Instance:ErrorRemind(Language.Fight.BabyBossLimit)
			return false
		end
	end

	return true
end

-- 角色是否是敌人
function BaseSceneLogic:IsRoleEnemy(target_obj, main_role)
	local attack_mode = main_role:GetVo().attack_mode
	
	if target_obj ~= nil then
		local target_is_shadow = false
		if target_obj:GetVo().shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_QINGLOU_DANCER or
		 target_obj:GetVo().shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_DAKUAFU_BOSS_ROLE then
		end
		if target_is_shadow then
			return false
		end
	end

	if attack_mode == GameEnum.ATTACK_MODE_PEACE then
		return false

	elseif attack_mode == GameEnum.ATTACK_MODE_TEAM then
		return not ScoietyData.Instance:IsTeamMember(target_obj:GetRoleId())
	elseif attack_mode == GameEnum.ATTACK_MODE_GUILD then
		return (main_role:GetVo().guild_id == 0 or main_role:GetVo().guild_id ~= target_obj:GetVo().guild_id) and not ScoietyData.Instance:IsTeamMember(target_obj:GetRoleId())
	elseif attack_mode == GameEnum.ATTACK_MODE_ALL then
		return true

	elseif attack_mode == GameEnum.ATTACK_MODE_NAMECOLOR then
		return target_obj:GetVo().name_color ~= GameEnum.NAME_COLOR_WHITE
	elseif attack_mode == GameEnum.ATTACK_MODE_CAMP then
		--怪物攻城阵营判断
		if Scene.Instance:GetSceneType() == SceneType.MonsterSiegeFb then
			local camp = PlayerData.Instance.role_vo.camp
			local data = CampData.Instance:GetMonsterSiegeInfo()
			local is_interfere = false
			local target_is_interfere = false
			local target_is_shadow = target_obj:GetVo().shadow_type == ROLE_SHADOW_TYPE.ROLE_SHADOW_TYPE_MONSTER_SIEGE_KING
			if data ~= nil then
				local other_camp = data.monster_siege_camp
				if other_camp ~= nil and other_camp > 0 then
					if other_camp ~= camp then
						is_interfere = true
					end

					if other_camp ~= target_obj:GetVo().camp then
						target_is_interfere = true
					end
				end
			end

			if target_is_shadow then
				-- if is_interfere then
				-- 	return 
				-- else
				-- 	return false
				-- end
				return false
			else
				if target_is_interfere and is_interfere then
					return false
				elseif not target_is_interfere and not is_interfere then
					return false
				else
					return true
				end
			end
		else
			local is_enemy = false
			if main_role:GetVo().camp ~= target_obj:GetVo().camp or target_obj:GetVo().is_neijian > 0 then
				is_enemy = true
			end
			return main_role:GetVo().camp == 0 or is_enemy
		end
	elseif attack_mode == GameEnum.ATTACK_MODE_ALLIANCE then
		local camp_info = CampData.Instance:GetCampInfo()
		if camp_info.alliance_camp == 0 then
			return not(target_obj:GetVo().camp == main_role:GetVo().camp)
		else
			return not(target_obj:GetVo().camp == main_role:GetVo().camp or target_obj:GetVo().camp == camp_info.alliance_camp)
		end
	end

	return true
end

-- 怪物是否是敌人
function BaseSceneLogic:IsMonsterEnemy(target_obj, main_role)
	return true
end

function BaseSceneLogic:GetGuajiPos()
	-- body
end

function BaseSceneLogic:OnMainRoleRealive()
	-- body
end

-- 获得捡取掉物品的最大距离
function BaseSceneLogic:GetPickItemMaxDic(item_id)
	-- 拾取距离 国战项目设置为0
	-- if GoldMemberData.Instance:GetVIPSurplusTime() > 0 then
	-- 	return 0
	-- end
	-- return 4
	return 0
end

function BaseSceneLogic:FindScenePathNode(scene_id, node)
	local scene_cfg = ConfigManager.Instance:GetSceneConfig(scene_id)
	if nil == scene_cfg then
		return
	end
	self.checked_list[scene_id] = 1 --记录检查过的
	for k,v in pairs(scene_cfg.doors) do
		if v.target_scene_id ~= nil then
			local cur_node = {}
			cur_node.x = v.x
			cur_node.y = v.y
			cur_node.target_scene_id = v.target_scene_id
			cur_node.scene_id = scene_id
			cur_node.prve_node = node

			self.node_list[#self.node_list + 1] = cur_node
			if v.target_scene_id == self.target_scene_id then --找到目的地
				return
			elseif self.checked_list[v.target_scene_id] ~= 1 then
				self:FindScenePathNode(v.target_scene_id, cur_node)
			end
		end
	end
end

--获得场景之间可行走路径点（不考虑最短路径）
function BaseSceneLogic:GetScenePath(start_scene_id, target_scene_id)
	self.checked_list = {}
	self.node_list = {}
	self.target_scene_id = target_scene_id
	self:FindScenePathNode(start_scene_id)
	--从目标场景节点中往前推组成新的路径列表
	local cur_node = nil
	for k,v in pairs(self.node_list) do
		if v.target_scene_id == target_scene_id then
			cur_node = v
			break
		end
	end

	if cur_node == nil then
		return {}
	end

	local path_list = {}
	path_list[1] = cur_node
	local loop_count = 0
	if nil ~= cur_node then
		while loop_count < 200 do
			for k,v in pairs(self.node_list) do
				if v == cur_node.prve_node then
					table.insert(path_list, 1, v) --总是放在第1个
					cur_node = v
					if v.target_scene_id == start_scene_id then -- 返回到起始场景结束
						return path_list
					end
				end
			end
			loop_count = loop_count + 1
		end
	end
	return path_list
end

--获得场景目标点。
--找不到场景入口点的情况下则找该场景的传送点
--一个地图可能有多个传送点，需通过地图寻路找到路径上的传送点。
function BaseSceneLogic:GetTargetScenePos(scene_id)
	local fly_x, fly_y = Scene.Instance:GetEntrance(Scene.Instance:GetSceneId(), scene_id)
	if fly_x == nil or fly_y == nil then
		local scene_path = self:GetScenePath(Scene.Instance:GetSceneId(), scene_id)
		local scene_node = scene_path[#scene_path]
		if scene_node ~= nil then --最终获得所在目标场景上的传送点
			fly_x, fly_y = Scene.Instance:GetSceneDoorPos(scene_node.target_scene_id, scene_node.scene_id)
		end
	end
	return fly_x, fly_y
end

-- 自动挂机优先级,为ture的话则自动挂机优先于寻路
function BaseSceneLogic:GetAutoGuajiPriority()
	return false
end

function BaseSceneLogic:GetGuajiSelectObjDistance()
	return COMMON_CONSTS.SELECT_OBJ_DISTANCE
end

function BaseSceneLogic:IsAutoStopTaskOnGuide()
	return true
end

-- 是否能够在频率过低时自动设置
function BaseSceneLogic:IsCanSystemAutoSetting()
	return true
end

-- 待机5秒，设置自动挂机状态
function BaseSceneLogic:CheckAutoGuaji(now_time)
	local main_role = Scene.Instance:GetMainRole()
	if self:IsSetAutoGuaji() and main_role then
		if GuajiCache.guaji_type == GuajiType.None then
			if not main_role:IsMove() and not main_role:IsRealDead() then
				-- 鼠标点击事件
				if UnityEngine.Input.GetMouseButtonDown(0) then
					self.key_down = true
					self.key_up = false
				end
				if UnityEngine.Input.GetMouseButtonUp(0) then
					self.key_up = true
					self.key_down = false
				end
				if not self.key_up and self.key_down then
					self.auto_guaji_time = now_time + self.auto_guaji_rest_time
				end

				-- 移动端触屏事件
				if UnityEngine.Input.touchCount > 0 then
					self.auto_guaji_time = now_time + self.auto_guaji_rest_time
				end
				if self.auto_guaji_time <= 0 then
					self.auto_guaji_time = now_time + self.auto_guaji_rest_time
				elseif self.auto_guaji_time <= now_time then
					if not self.is_standby then
						GuajiCtrl.Instance:SetGuajiType(GuajiType.Auto)
						-- TipsCtrl.Instance:ShowOrHideStandbyMaskView(true)
						self.is_standby = true
					end
				end
			elseif not main_role:IsStand() and not main_role:IsRealDead() then
				self.auto_guaji_time = now_time + self.auto_guaji_rest_time
				self.is_standby = false
			end
		elseif main_role:IsMove() then
			self.auto_guaji_time = now_time + self.auto_guaji_rest_time
			self.is_standby = false
		end
	elseif not self:IsSetAutoGuaji() and self.is_standby then
		-- TipsCtrl.Instance:ShowOrHideStandbyMaskView()
		self.is_standby = false
	end
end

-- 游泳区的高度
function BaseSceneLogic:GetWaterWayOffset()
	return 0
end

function BaseSceneLogic:AlwaysShowMonsterName()
	return false
end

--检查并处理移动的操作缓存
function BaseSceneLogic:CheckMoveCahche()
	local cache = Scene.Instance:GetMoveToPosCache()
	if cache then
		--如果有场景路径列表，说明在跨地图寻路中
		if cache.scene_path ~= nil and #cache.scene_path > 0 then
			local path = cache.scene_path[1]
			table.remove(cache.scene_path, 1)
			Scene.Instance:GetMainRole():DoMoveOperate(path.x, path.y, 0, nil, true)

		elseif cache.x ~= -1 and cache.y ~= -1 then --飞到某点后再寻路过去
			if not cache.is_special then
				GuajiCtrl.Instance:MoveToPos(cache.scene_id, cache.x, cache.y)
			else
				GuajiCtrl.Instance:MoveToPos(cache.scene_id, cache.x, cache.y, 10, 10, nil, nil, true)
			end
		else 	--直接飞到某点
			-- print("123123123")
			-- GuajiCtrl.Instance:OnOperate()
		end

		if cache.scene_path == nil or #cache.scene_path == 0 then
			Scene.Instance:ClearMovePosCache()
		end
	end
end

-- 跨服六界的寻路不知道在哪里断开了 只能强行在进入场景的时候重新检查一次
function BaseSceneLogic:CheckHasCaptureCaptive()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPEARANCE_TYPE_CAPTURE_CAPTIVE then
		local cfg = LianFuDailyData.Instance:GetXYCityGroupCfg(vo.server_group)
		if cfg and cfg.scene_id then
			local x, y = self:GetTargetScenePos(cfg.scene_id)
			GuajiCtrl.Instance:MoveToScenePos(cfg.scene_id, x, y)
		end
	end
end