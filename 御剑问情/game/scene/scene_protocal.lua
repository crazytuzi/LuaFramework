
Scene = Scene or BaseClass(BaseController)
local EFFECT_CD = 1
function Scene:RegisterAllProtocols()
	self.couple_halo_record_list = {}

	self:RegisterProtocol(SCEnterScene, "OnEnterScene")
	self:RegisterProtocol(SCVisibleObjEnterRole, "OnVisibleObjEnterRole")
	self:RegisterProtocol(SCVisibleObjLeave, "OnVisibleObjLeave")
	self:RegisterProtocol(SCObjMove, "OnObjMove")
	self:RegisterProtocol(SCVisibleObjEnterFalling, "OnVisibleObjEnterFalling")
	self:RegisterProtocol(SCVisibleObjEnterMonster, "OnVisibleObjEnterMonster")
	-- self:RegisterProtocol(SCVisibleObjEnterBattleFieldShenShi, "OnVisibleObjEnterBattleFieldShenShi")
	self:RegisterProtocol(SCRoleVisibleChange, "OnRoleVisibleChange")
	self:RegisterProtocol(SCVisibleObjEnterGather, "OnVisibleObjEnterGather")
	self:RegisterProtocol(SCVisibleObjEnterWorldEventObj, "OnVisibleObjEnterWorldEventObj")
	self:RegisterProtocol(SCVisibleObjEnterRoleShadow, "OnVisibleObjEnterRoleShadow")
	self:RegisterProtocol(SCVisibleObjEnterEffect, "OnVisibleObjEnterEffect")
	self:RegisterProtocol(SCVisibleObjEnterTrigger, "OnVisibleObjEnterTrigger")
	self:RegisterProtocol(SCResetPos, "OnResetPos")
	self:RegisterProtocol(SCSkillResetPos, "OnSkillResetPos")
	self:RegisterProtocol(SCStartGather, "OnStartGather")
	self:RegisterProtocol(SCStopGather, "OnStopGather")
	self:RegisterProtocol(SCStartGatherTimer, "OnStartGatherTimer")
	self:RegisterProtocol(SCGatherBeGather, "OnGatherBeGather")
	self:RegisterProtocol(SCAllObjMoveInfo, "OnAllObjMoveInfo")
	self:RegisterProtocol(SCObjMoveMode, "OnObjMoveMode")
	self:RegisterProtocol(SCRoleAccetpTaskAppearn, "OnRoleAccetpTaskAppearn")
	self:RegisterProtocol(SCSceneMonsterDie, "OnSceneMonsterDie")
	self:RegisterProtocol(SCRoleSpecialAppearanceChange, "OnRoleSpecialAppearanceChange")
	self:RegisterProtocol(SCGatherChange, "OnGatherChange")
	self:RegisterProtocol(SCPickItem, "OnPickItem")
	self:RegisterProtocol(SCGuildSendAppearance, "OnGuildSendAppearance")
	self:RegisterProtocol(SCGatherGeneraterList, "OnSCGatherGeneraterList")   --下发当前场景采集物生成点列表信息
	self:RegisterProtocol(SCTeamMemberPosList, "OnTeamMemberPosList") 			--队员位置下发
	self:RegisterProtocol(SCMultiMountNotifyArea, "OnMultiMountNotifyArea")  			--广播双人坐骑
	self:RegisterProtocol(SCNotifyAppearanceChangeInfo, "OnNotifyAppearanceChangeInfo")  			--

	self:BindGlobalEvent(LoginEventType.GAME_SERVER_CONNECTED, BindTool.Bind(self.OnConnectGameServer, self))
end

--重连游戏服清特殊形象
function Scene:OnConnectGameServer()
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	main_role_vo.special_appearance = 0
	main_role_vo.appearance_param = 0
end

function Scene.ServerSpeedToClient(server_speed)
	return server_speed / 100 * Config.SCENE_TILE_WIDTH
end

function Scene:OnEnterScene(protocol)
	Scene.SCENE_OBJ_ID_T = {}
	if not self.last_scene_id then
		self.last_scene_id = protocol.scene_id
	end
	if not self.last_scene_key then
		self.last_scene_key = protocol.scene_key
	end
	if self.last_scene_id == protocol.scene_id and self.last_scene_key ~= protocol.scene_key then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.ChangeLineSucc)
	end
	self.last_scene_id = protocol.scene_id
	self.last_scene_key = protocol.scene_key

	local role_data = PlayerData.Instance
	role_data:SetAttr("scene_id", protocol.scene_id)
	role_data:SetAttr("scene_key", protocol.scene_key)
	role_data:SetAttr("obj_id", protocol.obj_id)
	role_data:SetAttr("pos_x", protocol.pos_x)
	role_data:SetAttr("pos_y", protocol.pos_y)
	role_data:SetAttr("max_hp", protocol.max_hp)
	role_data:SetAttr("hp", protocol.hp)
	role_data:SetAttr("open_line", protocol.open_line)

	GameRoot.Instance:SetBuglySceneID(protocol.scene_id)
	GlobalEventSystem:Fire(SceneEventType.SCENE_LOADING_STATE_ENTER, protocol.scene_id)
end

function Scene:OnVisibleObjEnterRole(protocol)
	local scene_obj = self:GetObj(protocol.obj_id)
	if nil ~= scene_obj then
		if scene_obj:IsRole() then
			self:DeleteRolFollower(scene_obj)
		end
		self:DeleteObj(protocol.obj_id, 0)
	end

	local role_vo = GameVoManager.Instance:CreateVo(RoleVo)
	role_vo.obj_id = protocol.obj_id
	role_vo.name = protocol.role_name
	role_vo.pos_x = protocol.pos_x
	role_vo.pos_y = protocol.pos_y

	role_vo.role_id = protocol.role_id
	role_vo.dir = protocol.dir
	role_vo.role_status = protocol.role_status
	role_vo.hp = protocol.hp
	role_vo.max_hp = protocol.max_hp
	role_vo.level = protocol.level
	role_vo.camp = protocol.camp
	role_vo.prof = protocol.prof
	role_vo.sex = protocol.sex
	role_vo.vip_level = protocol.vip_level
	role_vo.rest_partner_obj_id = protocol.rest_partner_obj_id
	role_vo.move_speed = protocol.move_speed
	role_vo.distance = protocol.distance
	role_vo.attack_mode = protocol.attack_mode
	role_vo.name_color = protocol.name_color
	role_vo.move_mode = protocol.move_mode
	role_vo.move_mode_param = protocol.move_mode_param
	role_vo.authority_type = protocol.authority_type
	role_vo.husong_color = protocol.husong_color
	role_vo.husong_taskid = protocol.husong_taskid
	role_vo.guild_post = protocol.guild_post
	role_vo.mount_appeid = protocol.mount_appeid

	role_vo.appearance = protocol.appearance
	role_vo.appearance_param = protocol.appearance_param
	role_vo.used_sprite_id = protocol.used_sprite_id
	role_vo.use_sprite_imageid = protocol.use_sprite_imageid			-- 精灵飞升形象
	role_vo.used_sprite_quality = protocol.used_sprite_quality			-- 仙女品质等级
	role_vo.chengjiu_title_level = protocol.chengjiu_title_level		-- 成就称号等级
	role_vo.sprite_name = protocol.sprite_name
	role_vo.flyup_use_image = protocol.flyup_use_image				 --坐骑使用的筋斗云资源
	role_vo.user_pet_special_img = protocol.user_pet_special_img or -1     --精灵幻化形象
	role_vo.top_dps_flag = protocol.top_dps_flag or 0				-- 最高dps标记
	role_vo.lingzhu_use_imageid = protocol.lingzhu_use_imageid or 0			--使用的灵珠
	role_vo.lingchong_used_imageid = protocol.lingchong_used_imageid or 0	--使用的灵宠
	role_vo.linggong_used_imageid = protocol.linggong_used_imageid or 0		--使用的灵弓
	role_vo.lingqi_used_imageid = protocol.lingqi_used_imageid or 0			--使用的灵骑
	role_vo.model_size = protocol.model_size or 100 						--模型大小
	role_vo.is_invisible = protocol.is_invisible or 0						--模型是否可见
	role_vo.sup_baby_id = protocol.sup_baby_id or -1						--超级宝宝id
	role_vo.sup_baby_name = protocol.sup_baby_name or ""					--超级宝宝名字

	role_vo.pet_id = protocol.pet_id or 0
	role_vo.pet_level = protocol.pet_level or 0
	role_vo.pet_grade = protocol.pet_grade or 0
	role_vo.pet_name = protocol.pet_name or ""
	role_vo.user_lq_special_img = protocol.user_lq_special_img or 0

	role_vo.guild_id = protocol.guild_id or 0
	role_vo.guild_name = protocol.guild_name or ""
	for i=1,3 do
		role_vo.used_title_list[i] = protocol.used_title_list[i] or 0
	end
	role_vo.millionare_type = protocol.millionare_type
	role_vo.buff_mark_low = protocol.buff_mark_low or 0
	role_vo.buff_mark_high = protocol.buff_mark_high or 0
	role_vo.special_param = protocol.special_param or 0
	role_vo.height = protocol.height or 0
	role_vo.special_appearance = protocol.special_appearance or 0
	role_vo.appearance_param = protocol.appearance_param or 0
	role_vo.shenbing_flag = protocol.shenbing_flag or 0
	role_vo.lover_name = protocol.lover_name or ""
	role_vo.jilian_type = protocol.jilian_type or 0
	role_vo.use_xiannv_id = protocol.use_xiannv_id or 0
	role_vo.used_sprite_jie = protocol.used_sprite_jie or 0
	role_vo.xianjie_level =  protocol.xianjie_level or 0
	role_vo.jinghua_husong_status =  protocol.jinghua_husong_status or 0
	role_vo.jinghua_husong_type = protocol.jinghua_husong_type or -1
	role_vo.use_jingling_titleid =  protocol.use_jingling_titleid or 0
	role_vo.tianxiange_level =  protocol.tianxiange_level or 0
	role_vo.halo_type = protocol.halo_type or 0
	role_vo.use_xiannv_halo_img = protocol.use_xiannv_halo_img or 0
	role_vo.multi_mount_res_id = protocol.multi_mount_res_id 					-- 双人坐骑资源id
	role_vo.multi_mount_is_owner = protocol.multi_mount_is_owner				-- 是否当前双人坐骑的主人
	role_vo.multi_mount_other_uid = protocol.multi_mount_other_uid    			-- 一起骑乘的玩家role_id
	role_vo.fight_mount_appeid = protocol.fight_mount_appeid or 0				-- 战斗坐骑
	role_vo.xiannv_name = protocol.xiannv_name or 0
	role_vo.bianshen_param = protocol.bianshen_param or 0
	role_vo.xiannv_huanhua_id = protocol.xiannv_huanhua_id or 0
	role_vo.wuqi_color = protocol.wuqi_color or 0
	role_vo.total_capability = protocol.total_capability or 0
	role_vo.task_appearn = protocol.task_appearn or 0
	role_vo.task_appearn_param_1 = protocol.task_appearn_param_1 or 0
	role_vo.molong_rank = protocol.molong_rank or 0 								-- 龙行天下头衔
	role_vo.combine_server_equip_active_special = protocol.combine_server_equip_active_special or 0
	role_vo.touxian = protocol.touxian or 0

	role_vo.shengbing_use_image_id = protocol.shengbing_use_image_id or 0
	role_vo.baojia_use_image_id = protocol.baojia_use_image_id or 0

	AvatarManager.Instance:SetAvatarKey(protocol.role_id, protocol.avatar_key_big, protocol.avatar_key_small)
	AvatarManager.Instance:SetAvatarKey(protocol.guild_id, protocol.guild_avatar_key_big, protocol.guild_avatar_key_small)

	local obj = self:CreateRole(role_vo)
	if nil == obj then
		return
	end

	obj:SetAttr("used_sprite_id", protocol.used_sprite_id)
	if protocol.fight_mount_appeid and protocol.fight_mount_appeid > 0 then
		-- local part = obj.draw_obj:GetPart(SceneObjPart.Main)
		-- part:EnableMountUpTrigger(false)
		-- local attachment = part:GetObj().actor_attachment
		-- attachment:SetMountUpTriggerEnable(false)
		obj:SetAttr("fight_mount_appeid", protocol.fight_mount_appeid)
	end

	if protocol.millionare_type and protocol.millionare_type > 0 then
		obj:SetAttr("millionare_type", protocol.millionare_type)
	end

	if protocol.appearance then
		obj:SetAttr("appearance", protocol.appearance)
	end

	if role_vo.distance > 0.1 then
		self:DoObjMove(obj, role_vo.pos_x, role_vo.pos_y, role_vo.dir, role_vo.distance)
	end

		--双人坐骑
	obj:SetMultiMountIdAndOnwerFlag(protocol.multi_mount_res_id, protocol.multi_mount_is_owner, protocol.multi_mount_other_uid)
	if protocol.multi_mount_other_uid > 0 then
		local other_role
		if protocol.multi_mount_other_uid == self.main_role.vo.role_id then
			other_role = self.main_role
		else
			other_role = self:GetObjByUId(protocol.multi_mount_other_uid)
		end

		if nil ~= other_role then
			obj:SetMountOtherObjId(other_role:GetObjId())
			other_role:SetMountOtherObjId(obj:GetObjId())
		end
	end

	if role_vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP or role_vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		obj:DoJump2(role_vo.move_mode_param)
	end

	local part = obj:GetDrawObj() and obj:GetDrawObj():GetRoot()
	if part then
		if protocol.show_image == 0 then
			part.transform.localScale = Vector3(1, 1, 1)
		elseif protocol.show_image == 7 or protocol.show_image == 8 then
			part.transform.localScale = Vector3(protocol.model_size / 100, protocol.model_size / 100, protocol.model_size / 100)
		end
	end

	obj:SetAttr("top_dps_flag", protocol.top_dps_flag)
	obj:SetBuffList(bit:ll2b(role_vo.buff_mark_high, role_vo.buff_mark_low))

	obj:SetAttr("molong_rank",protocol.molong_rank)

	obj:SetAttr("halo_type", protocol.halo_type)
	obj:SetAttr("halo_lover_uid", protocol.halo_lover_uid)

	GlobalEventSystem:Fire(SceneEventType.OBJ_ENTER_LEVEL_ROLE)
end

function Scene:OnVisibleObjLeave(protocol)
	local scene_obj = self:GetObj(protocol.obj_id)
	if nil ~= scene_obj then
		if scene_obj:IsRole() then
			self:DeleteRolFollower(scene_obj)
			self:DeleteBoatByRole(protocol.obj_id)
		end

		if scene_obj:IsMonster() or scene_obj:GetVo().is_shadow == 1 then
			if scene_obj.vo.hp <= 0 then
				self:DeleteObj(protocol.obj_id, 2)
			else
				self:DeleteObj(protocol.obj_id, 0)
			end
		else
			self:DeleteObj(protocol.obj_id, 0)
			GlobalEventSystem:Fire(SceneEventType.OBJ_ENTER_LEVEL_ROLE)
		end

		if self.obj_move_info_list[protocol.obj_id] then
			self.obj_move_info_list[protocol.obj_id]:OnScene(false)
		end
	end
end

function Scene:DeleteRolFollower(obj)
	--if obj and obj:IsRole() then
		-- local sprite_obj = obj:GetSpriteObj()
		-- if nil ~= sprite_obj then
		-- 	self:DeleteClientObj(sprite_obj:GetObjId())
		-- end

		-- local pet_obj = obj:GetPetObj()
		-- if nil ~= pet_obj then
		-- 	self:DeleteClientObj(pet_obj:GetObjId())
		-- end

		-- local truck_obj = obj:GetTruckObj()
		-- if nil ~= truck_obj then
		-- 	self:DeleteClientObj(truck_obj:GetObjId())
		-- end
	--end
end

function Scene:OnObjMove(protocol)
	local scene_obj = self:GetObj(protocol.obj_id)
	if nil == scene_obj or scene_obj:IsMainRole() then
		return
	end
	self:DoObjMove(scene_obj, protocol.pos_x, protocol.pos_y, protocol.dir, protocol.distance, protocol.press_onward)
end

function Scene:DoObjMove(scene_obj, pos_x, pos_y, dir, distance, press_onward)
	if nil ~= scene_obj and scene_obj:IsCharacter() then
		if scene_obj:IsRole() and scene_obj:IsMultiMountPartner() then
			return
		end
		local logic_x, logic_y = scene_obj:GetLogicPos()
		if math.abs(logic_x - pos_x) >= 8 or math.abs(logic_y - pos_y) >= 8 then
			scene_obj:SetLogicPos(pos_x, pos_y)
		end

		-- if distance > 0.1 then
			scene_obj:DoMove(math.floor(pos_x + math.cos(dir) * distance), math.floor(pos_y + math.sin(dir) * distance), press_onward == 1)
		-- else
		-- 	scene_obj:ChangeToCommonState()
		-- end
	end
end

function Scene:OnVisibleObjEnterFalling(protocol)
	local scene_obj = self:GetObj(protocol.obj_id)
	if scene_obj then
		self:DeleteObj(protocol.obj_id, 0)
	end

	local fallitem_vo = GameVoManager.Instance:CreateVo(FallItemVo)
	fallitem_vo.obj_id = protocol.obj_id
	fallitem_vo.item_id = protocol.item_id
	fallitem_vo.pos_x = protocol.pos_x
	fallitem_vo.pos_y = protocol.pos_y
	fallitem_vo.owner_role_id = protocol.owner_role_id
	fallitem_vo.coin = protocol.coin
	fallitem_vo.monster_id = protocol.monster_id
	fallitem_vo.item_num = protocol.item_num
	fallitem_vo.drop_time = protocol.drop_time
	fallitem_vo.create_interval = protocol.create_interval
	fallitem_vo.is_create = protocol.is_create
	fallitem_vo.is_buff_falling = protocol.is_buff_falling
	fallitem_vo.buff_appearan = protocol.buff_appearan
	fallitem_vo.create_time = Status.NowTime
	local scene_id = self:GetSceneId()
	if not GameEnum.SHIELD_OTHERS_FALLITEM_SCENE_ID[scene_id] or
		(fallitem_vo.owner_role_id <= 0 or fallitem_vo.owner_role_id == self.main_role:GetRoleId()) then
		self:CreateFallItem(fallitem_vo)
	end
end

function Scene:OnVisibleObjEnterMonster(protocol)
	local scene_obj = self:GetObj(protocol.obj_id)
	if scene_obj then
		self:DeleteObj(protocol.obj_id, 0)
	end

	local monster_vo = GameVoManager.Instance:CreateVo(MonsterVo)
	monster_vo.obj_id = protocol.obj_id
	monster_vo.status_type = protocol.status_type
	monster_vo.monster_id = protocol.monster_id
	monster_vo.pos_x = protocol.pos_x
	monster_vo.pos_y = protocol.pos_y
	monster_vo.hp = protocol.hp
	monster_vo.max_hp = protocol.max_hp
	monster_vo.move_speed = protocol.move_speed
	monster_vo.dir = protocol.dir
	monster_vo.distance = protocol.distance
	monster_vo.buff_mark_low = protocol.buff_mark_low
	monster_vo.buff_mark_high = protocol.buff_mark_high
	monster_vo.dsp_name = protocol.dsp_name
	monster_vo.special_param = protocol.special_param

	local monster = self:CreateMonster(monster_vo)
	if monster_vo.distance > 0.1 then
		self:DoObjMove(monster, monster_vo.pos_x, monster_vo.pos_y, monster_vo.dir, monster_vo.distance)
	end
	if monster then
		monster:SetBuffList(bit:ll2b(monster_vo.buff_mark_high, monster_vo.buff_mark_low))
	end

	if MainUICtrl.Instance.view.target_view then
		MainUICtrl.Instance.view.target_view:OnBossFirstHurtChange(protocol.obj_id, protocol.dsp_name)
	end
end

function Scene:OnVisibleObjEnterBattleFieldShenShi(protocol)

end

function Scene:OnRoleVisibleChange(protocol)
	local scene_obj = self:GetObj(protocol.obj_id)
	if nil == scene_obj or not scene_obj:IsRole() then
		return
	end
	scene_obj:SetAttr("appearance", protocol.appearance)

	if scene_obj:GetType() == SceneObjType.MainRole then
		GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_APPERANCE_CHANGE)
	end
end

function Scene:OnVisibleObjEnterGather(protocol)
	local scene_obj = self:GetObj(protocol.obj_id)
	if scene_obj then
		self:DeleteObj(protocol.obj_id, 0)
	end

	local gather_vo = GameVoManager.Instance:CreateVo(GatherVo)
	gather_vo.obj_id = protocol.obj_id
	gather_vo.gather_id = protocol.gather_id
	gather_vo.special_gather_type = protocol.special_gather_type
	gather_vo.pos_x = protocol.pos_x
	gather_vo.pos_y = protocol.pos_y
	gather_vo.param = protocol.param
	gather_vo.param1 = protocol.param1
	gather_vo.param2 = protocol.param2
	gather_vo.param3 = protocol.param3
	gather_vo.param4 = protocol.param4
	self:CreateGatherObj(gather_vo)
end

function Scene:OnVisibleObjEnterWorldEventObj(protocol)
	local scene_obj = self:GetObj(protocol.obj_id)
	if scene_obj then
		self:DeleteObj(protocol.obj_id, 0)
	end
	local event_vo = GameVoManager.Instance:CreateVo(EventVo)
	event_vo.obj_id = protocol.obj_id
	event_vo.world_event_id = protocol.world_event_id
	event_vo.pos_x = protocol.pos_x
	event_vo.pos_y = protocol.pos_y
	event_vo.hp = protocol.hp
	event_vo.max_hp = protocol.max_hp

	self:CreateZhuaGuiNpc(event_vo)
end

function Scene:OnVisibleObjEnterRoleShadow(protocol)
	local scene_obj = self:GetObj(protocol.obj_id)
	if scene_obj then
		self:DeleteRolFollower(scene_obj);
		self:DeleteObj(protocol.obj_id, 0)
	end

	local role_vo = GameVoManager.Instance:CreateVo(RoleVo)
	role_vo.obj_id = protocol.obj_id
	role_vo.name = protocol.role_name
	role_vo.pos_x = protocol.pos_x
	role_vo.pos_y = protocol.pos_y

	role_vo.role_id = protocol.role_id
	role_vo.level = protocol.level
	role_vo.prof = protocol.prof
	-- 防止机器人性别错误
	role_vo.sex = PlayerData.Instance:GetSexByProf(protocol.prof)
	-- role_vo.sex = protocol.sex
	role_vo.camp = protocol.camp
	role_vo.hp = protocol.hp
	role_vo.max_hp = protocol.max_hp
	role_vo.move_speed = protocol.move_speed
	role_vo.dir = protocol.dir
	role_vo.distance = protocol.distance
	role_vo.appearance = protocol.appearance
	role_vo.vip_level = protocol.vip_level
	role_vo.guild_id = protocol.guild_id
	role_vo.guild_name = protocol.guild_name
	role_vo.guild_post = protocol.guild_post
	role_vo.is_shadow = 1 --是影子
	role_vo.attack_mode = 1 -- 全体模式
	role_vo.shadow_type = protocol.shadow_type
	role_vo.shadow_param = protocol.shadow_param


	-- AvatarManager.Instance:SetAvatarKey(protocol.role_id, protocol.avatar_key_big, protocol.avatar_key_small)

	local obj = self:CreateRole(role_vo)
	if nil == obj then
		return
	end

	if role_vo.distance > 0.1 then
		self:DoObjMove(obj, role_vo.pos_x, role_vo.pos_y, role_vo.dir, role_vo.distance)
	end
end

function Scene:OnVisibleObjEnterEffect(protocol)
	local scene_obj = self:GetObj(protocol.obj_id)
	if scene_obj then
		self:DeleteObj(protocol.obj_id, 0)
	end

	local effect_vo = GameVoManager.Instance:CreateVo(EffectObjVo)
	effect_vo.obj_id = protocol.obj_id
	effect_vo.pos_x = protocol.pos_x
	effect_vo.pos_y = protocol.pos_y
	effect_vo.product_method = protocol.product_method
	effect_vo.product_id = protocol.product_id
	effect_vo.birth_time = protocol.birth_time
	effect_vo.disappear_time = protocol.disappear_time
	effect_vo.param1 = protocol.param1
	effect_vo.param2 = protocol.param2
	effect_vo.src_pos_x = protocol.src_pos_x
	effect_vo.src_pos_y = protocol.src_pos_y

	self:CreateEffectObj(effect_vo)
end

function Scene:OnVisibleObjEnterTrigger(protocol)
	local scene_obj = self:GetObj(protocol.obj_id)
	if scene_obj then
		self:DeleteObj(protocol.obj_id, 0)
	end

	local trigger_vo = GameVoManager.Instance:CreateVo(TriggerObjVo)
	trigger_vo.obj_id = protocol.obj_id
	trigger_vo.pos_x = protocol.pos_x
	trigger_vo.pos_y = protocol.pos_y
	trigger_vo.param0 = protocol.param0
	trigger_vo.param1 = protocol.param1
	trigger_vo.action_type = protocol.action_type
	trigger_vo.affiliation = protocol.affiliation
	trigger_vo.trigger_name = protocol.trigger_name
	self:CreateTriggerObj(trigger_vo)
end

function Scene:OnResetPos(protocol)
	local main_role = self:GetMainRole()
	if main_role then
		local logic_x, logic_y = main_role:GetLogicPos()
		main_role:SetLogicPos(protocol.pos_x, protocol.pos_y)
		main_role:ChangeToCommonState()
		Scene.SendMoveMode(MOVE_MODE.MOVE_MODE_NORMAL)
		main_role:SetJump(false)
		main_role.vo.move_mode = MOVE_MODE.MOVE_MODE_NORMAL
		GlobalEventSystem:Fire(OtherEventType.JUMP_STATE_CHANGE, false)
		main_role:ContinuePath()
	end
	GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_RESET_POS, protocol.pos_x, protocol.pos_y)
end

function Scene:OnSkillResetPos(protocol)
	local obj = self:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end
	obj:OnSkillResetPos(protocol.skill_id, protocol.reset_pos_type, protocol.pos_x, protocol.pos_y)
end

function Scene:OnStartGather(protocol)
	local obj = self:GetObj(protocol.role_obj_id)
	if nil ~= obj and obj:IsRole() then
		local gather = self:GetObj(protocol.gather_obj_id)

		--捕鱼
		local is_fish = false
		if gather and gather.vo.gather_id == 112 then
			is_fish = true
		end
		local is_kf_mining = false
		if gather and KuaFuMiningData.Instance:IsMiningGather(gather.vo.gather_id) then
			is_kf_mining = true
		end
		obj:SetIsGatherState(true, is_fish, is_kf_mining)
		if obj:IsMainRole() then
			local gather = self:GetObj(protocol.gather_obj_id)
			GlobalEventSystem:Fire(ObjectEventType.START_GATHER, protocol.role_obj_id, protocol.gather_obj_id)
		else
			GlobalEventSystem:Fire(ObjectEventType.OTHER_ROLE_START_GATHER, protocol.role_obj_id, protocol.gather_obj_id)
		end

		local obj_root = obj:GetRoot()
		if obj_root and gather then
			local towards = gather:GetRoot().transform.position
			towards = u3d.vec3(towards.x, obj_root.transform.position.y, towards.z)

			obj_root.transform:DOLookAt(towards, 0.5)
		end
	end
end

function Scene:OnStopGather(protocol)
	local obj = self:GetObj(protocol.role_obj_id)
	if nil ~= obj and obj:IsRole() then
		obj:SetIsGatherState(false)
		if obj:IsMainRole() then
			GlobalEventSystem:Fire(ObjectEventType.STOP_GATHER, protocol.role_obj_id, protocol.reason)
		else
			GlobalEventSystem:Fire(ObjectEventType.OTHER_ROLE_STOP_GATHER, protocol.role_obj_id, protocol.reason)
		end
	end
end

function Scene:OnStartGatherTimer(protocol)
	GlobalEventSystem:Fire(ObjectEventType.GATHER_TIMER, protocol.gather_time / 1000)
end

function Scene:OnAllObjMoveInfo(protocol)
	self:DeleteAllMoveObj()
	for k, v in pairs(protocol.obj_move_info_list) do
		local vo = GameVoManager.Instance:CreateVo(MapMoveVo)
		vo.obj_id = v.obj_id
		vo.obj_type = v.obj_type
		vo.type_special_id = v.type_special_id
		vo.dir = v.dir
		vo.distance = v.distance
		vo.pos_x = v.pos_x
		vo.pos_y = v.pos_y
		vo.move_speed = v.move_speed
		vo.monster_key = v.monster_key
		local map_move_obj = MapMoveObj.New(vo)
		self.obj_move_info_list[v.obj_id] = map_move_obj
		if self.obj_list[v.obj_id] then
			map_move_obj:OnScene(true)
		end
	end
end

function Scene:OnObjMoveMode(protocol)
	local scene_obj = self:GetObj(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsRole() then
		scene_obj.vo.move_mode = protocol.move_mode
		scene_obj.vo.move_mode_param = protocol.move_mode_param

		local scene_type = Scene.Instance:GetSceneType()
		if scene_type == SceneType.Fishing and scene_obj:IsMainRole() then
			-- 取消钓鱼状态
			FishingCtrl.Instance:SendFishingOperaReq(FISHING_OPERA_REQ_TYPE.FISHING_OPERA_REQ_TYPE_STOP_FISHING)
		end

		if scene_obj.vo.move_mode == MOVE_MODE.MOVE_MODE_NORMAL and protocol.move_mode == MOVE_MODE.MOVE_MODE_JUMP then
			scene_obj:DoJump(protocol.move_mode_param)
		end

		if protocol.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
			if not scene_obj:IsMainRole() then
				scene_obj:DoJump(protocol.move_mode_param)
			end
		end

		if scene_obj.vo.move_mode == MOVE_MODE.MOVE_MODE_NORMAL and protocol.move_mode == MOVE_MODE.MOVE_MODE_FLY then
			if nil ~= self:GetMainRole().vo.special_appearance and self:GetMainRole().vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_HUASHENG then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.SucceedFlight)
			end
			--执行飞行
			--scene_obj:StartFlyingUp()
		elseif scene_obj.vo.move_mode == MOVE_MODE.MOVE_MODE_FLY and protocol.move_mode == MOVE_MODE.MOVE_MODE_NORMAL then
			if nil ~= self:GetMainRole().vo.special_appearance and self:GetMainRole().vo.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_HUASHENG then
				SysMsgCtrl.Instance:ErrorRemind(Language.Common.SucceedLanding)
			end
			--停止飞行
			--scene_obj:StartFlyingDown()
		end
	end
end

function Scene:OnSceneMonsterDie(protocol)
	self.obj_move_info_list[protocol.obj_id] = nil
end

function Scene:OnRoleSpecialAppearanceChange(protocol)
	local scene_obj = self:GetObj(protocol.obj_id)
	if nil == scene_obj then
		return
	end
	if scene_obj:IsRole() then
		scene_obj:SetAttr("appearance_param", protocol.appearance_param)
		scene_obj:SetAttr("special_appearance", protocol.special_appearance)
	end
	-- 名将变身广播特效
	if protocol.special_appearance == SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_GREATE_SOLDIER then
		local bundle, asset = ResPath.GetMiscEffect("Effect_bianshen")

		if not scene_obj:IsMainRole() and SettingData.Instance:GetSettingData(SETTING_TYPE.SHIELD_OTHERS) then
			return
		end
		scene_obj:SetRoleEffect(bundle, asset, 4)
		-- if scene_obj:IsMainRole() then
		-- 	FamousGeneralCtrl.Instance:ShowBianShen(protocol.appearance_param)
		-- end
		MainUICtrl.Instance:FlushView("general_bianshen", {"skill"})
	end

	-- if protocol.special_appearance > 0 then
	-- 	local cur_use_seq = GeneralSkillData.Instance:GetCurUseSeq()
	-- 	-- 防止在有未完成主线的时候 变身之后强制做主线
	-- 	if cur_use_seq >= 0 then
	-- 		local task_cfg = TaskData.Instance:GetNextZhuTaskConfig()
	-- 		if task_cfg then
	-- 			TaskCtrl.Instance:DoTask(task_cfg.task_id)
	-- 		end
	-- 	end
	-- end

end

function Scene:OnRoleAccetpTaskAppearn(protocol)
	local scene_obj = self:GetObj(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsRole() then
		scene_obj:SetAttr("task_appearn_param_1", protocol.task_appearn_param_1)
		scene_obj:SetAttr("task_appearn", protocol.task_appearn)
	end
end

function Scene:OnGatherChange(protocol)
	print_log("=============OnGatherChange", protocol)
	-- local scene_obj = self:GetObj(protocol.obj_id)
	-- if nil ~= scene_obj then
	-- 	if GuildData.Instance:IsGatherBonfire(protocol.gather_id) then
	-- 		scene_obj:GetVo().param = protocol.param
	-- 		scene_obj:UpdateNameBoard()
	-- 		scene_obj:RefreshAnimation()
	-- 		GuildCtrl.Instance:RefreshBonfireView()
	-- 	end
	-- 	if XiuLianData.Instance:IsGatherJinghua(protocol.gather_id) then
	-- 		scene_obj:GetVo().param = protocol.param
	-- 		scene_obj:GetVo().special_gather_type = protocol.special_gather_type
	-- 		scene_obj:UpdateNameBoard()
	-- 	end
	-- end
	if protocol.special_gather_type == SPECIAL_GATHER_TYPE.JINGHUA then 							-- 如果是精华护送采集物更变
		JingHuaHuSongCtrl.Instance:OnJingHuaGatherChange(protocol.gather_id, protocol.param, protocol.param1)		-- param是剩余采集次数
		if JingHuaHuSongData.Instance and protocol.gather_id == JingHuaHuSongData.Instance:GetGatherId(JingHuaHuSongData.JingHuaType.Big) then
			MainUIData.Instance:SendJingHuaHuSongNum(protocol.param)
			MainUIView.Instance:JingHuaHuSongNum()
			if FuBenCtrl.Instance then
				FuBenCtrl.Instance:SetJingHuaHuSongNum()
			end
		end
	elseif protocol.special_gather_type == SPECIAL_GATHER_TYPE.KUAFU_MINING then
		--param是采集物状态（未被采集还是正在被人采集） param1是采集者的Obj_id
		KuaFuMiningCtrl.Instance:OnKuaFuMiningGatherChange(protocol.pos_x, protocol.pos_y, protocol.param, protocol.param1)
	end
end

function Scene:OnPickItem(protocol)
	for i,v in ipairs(protocol.item_objid_list) do
		local fall_item = self:GetObj(v)
		if fall_item ~= nil and not fall_item:IsDeleted() then
			fall_item:PlayPick()
		end
	end
end

function Scene:OnGuildSendAppearance(protocol)
	local scene_obj = self:GetObj(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsRole() then
		AvatarManager.Instance:SetAvatarKey(scene_obj:GetVo().guild_id, protocol.guild_avatar_key_big, protocol.guild_avatar_key_small)
		scene_obj:SetAttr("guild_name", protocol.guild_name)
		scene_obj:ReloadGuildIcon()
	end
end

function Scene:OnNotifyAppearanceChangeInfo(protocol)
	local scene_obj = self:GetObj(protocol.obj_id)
	if protocol.reason_type == NOTIFY_REASON_TYPE.JINGJIE_LEVEL_CHANGE and nil ~= scene_obj and scene_obj:IsRole() then
		scene_obj:SetAttr("touxian", protocol.param1)
	end
end

function Scene:OnSCGatherGeneraterList(protocol)
	print_log("changjing baoxiang ",protocol)
	self:GetSceneLogic():OnSCGatherGeneraterList(protocol)
	CrossCrystalCtrl.Instance:OnSCGatherGeneraterList(protocol)  --水晶场景
end

function Scene.SendTransportReq(transport_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTransportReq)
	protocol.transport_index = transport_index
	protocol:EncodeAndSend()
end

function Scene.SendMoveReq(dir, x, y, distance, is_press_onward)
	local protocol = ProtocolPool.Instance:GetProtocol(CSObjMove)
	protocol.dir = dir
	protocol.pos_x = math.floor(x)
	protocol.pos_y = math.floor(y)
	protocol.distance = distance
	protocol.is_press_onward = is_press_onward or 0
	protocol:EncodeAndSend()
end

function Scene.SendCancelMonsterStaticState()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCancelMonsterStaticState)
	protocol:EncodeAndSend()
end

function Scene.SendStartGatherReq(gather_obj_id, gather_count)
	local protocol = ProtocolPool.Instance:GetProtocol(CSStartGatherReq)
	protocol.gather_obj_id = gather_obj_id
	protocol.gather_count = gather_count
	protocol:EncodeAndSend()
end

function Scene.SendStopGatherReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSStopGatherReq)
	protocol:EncodeAndSend()
end

function Scene.ScenePickItem(item_objid_list)
	if nil == item_objid_list then
		return
	end

	local protocol = ProtocolPool.Instance:GetProtocol(CSPickItem)
	protocol.item_objid_list = item_objid_list
	protocol:EncodeAndSend()
end

function Scene.SendMoveMode(move_mode, move_mode_param)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSetMoveMode)
	protocol.move_mode = move_mode
	protocol.move_mode_param = move_mode_param or 0
	protocol:EncodeAndSend()
end

function Scene.SendGetAllObjMoveInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetAllObjMoveInfoReq)
	protocol:EncodeAndSend()
end

function Scene.SendWorldEventObjTouch(obj_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSWorldEventObjTouch)
	protocol.obj_id = obj_id
	protocol:EncodeAndSend()
end

function Scene.SendReqTeamMemberPos()
	local  protocol = ProtocolPool.Instance:GetProtocol(CSReqTeamMemberPos)
	protocol:EncodeAndSend()
end

function Scene:OnTeamMemberPosList(protocol)
	-- MapCtrl.Instance:OnFlushTeamMemberPos(protocol.team_member_list)
	ScoietyData.Instance:SCTeamMemberPosList(protocol)
end

function Scene.SendMultiuserChallengeReqSideMemberPos()
	local  protocol = ProtocolPool.Instance:GetProtocol(CSMultiuserChallengeReqSideMemberPos)
	protocol:EncodeAndSend()
end

function Scene:OnMultiuserChallengeTeamMemberPosList(protocol)
	local list = {}
	for k,v in pairs(protocol.team_member_list) do
		if v.role_id ~= PlayerData.Instance.role_vo.role_id then
			list[#list + 1] = v
		end
	end
	MapCtrl.Instance:OnFlushTeamMemberPos(list)
end

--夫妻光环--------暂时没用
function Scene:OnQingyuanCoupleHaloTrigger(protocol)
	-- if nil ~= protocol.role1_uid and nil ~= protocol.role2_uid and nil ~= protocol.halo_type then
	-- 	local scene_obj_1, 	scene_obj_2
	-- 	if protocol.role1_uid == self.main_role.vo.role_id then
	-- 		scene_obj_1 = self:GetMainRole()
	-- 		scene_obj_2 = self:GetObjByUId(protocol.role2_uid)
	-- 	elseif protocol.role2_uid == self.main_role.vo.role_id then
	-- 		scene_obj_1 = self:GetMainRole()
	-- 		scene_obj_2 = self:GetObjByUId(protocol.role1_uid)
	-- 	else
	-- 		scene_obj_1 = self:GetObjByUId(protocol.role1_uid)
	-- 		scene_obj_2 = self:GetObjByUId(protocol.role2_uid)
	-- 	end
	-- 	if scene_obj_1 and scene_obj_2 and protocol.halo_type ~= 0 then
	-- 		for k,v in pairs(self.couple_halo_record_list) do
	-- 			if v.id1 == protocol.role1_uid or v.id2 == protocol.role1_uid then
	-- 				return
	-- 			end
	-- 		end
	-- 		local halo = CoupleHalo.New(protocol.halo_type, scene_obj_1, scene_obj_2)
	-- 		local data = {}
	-- 		data.id1 = protocol.role1_uid
	-- 		data.id2 = protocol.role2_uid
	-- 		data.halo = halo
	-- 		table.insert(self.couple_halo_record_list, data)
	-- 	elseif 0 == protocol.halo_type then
	-- 		for k,v in pairs(self.couple_halo_record_list) do
	-- 			if v.id1 == protocol.role1_uid or v.id2 == protocol.role1_uid then
	-- 				v.halo:DeleteMe()
	-- 				self.couple_halo_record_list[k] = nil
	-- 				break
	-- 			end
	-- 		end
	-- 	end
	-- end
end

-- 双人坐骑
function Scene:OnMultiMountNotifyArea(protocol)
	local owner_obj = self:GetRoleByObjId(protocol.owner_objid)
	local partner_obj = self:GetRoleByObjId(protocol.parnter_objid)
	if protocol.parnter_multi_mount_res_id > 0 then
		if nil ~= partner_obj then
			partner_obj:SetMultiMountIdAndOnwerFlag(protocol.owner_multi_mount_res_id, 0, protocol.owner_role_id)
			if nil ~= owner_obj then
				partner_obj:SetMountOtherObjId(owner_obj:GetObjId())
			else
				partner_obj:SetMountOtherObjId(COMMON_CONSTS.INVALID_OBJID)
			end
		end
		if nil ~= owner_obj then
			owner_obj:SetMultiMountIdAndOnwerFlag(protocol.owner_multi_mount_res_id, 1, protocol.partner_role_id)
			if nil ~= partner_obj then
				owner_obj:SetMountOtherObjId(partner_obj:GetObjId())
			else
				owner_obj:SetMountOtherObjId(COMMON_CONSTS.INVALID_OBJID)
			end
		end
	else
		if nil ~= owner_obj then
			owner_obj:SetMultiMountIdAndOnwerFlag(protocol.owner_multi_mount_res_id, 1, 0)
			owner_obj:SetMountOtherObjId(COMMON_CONSTS.INVALID_OBJID)
		end
		if nil ~= partner_obj then
			partner_obj:SetMultiMountIdAndOnwerFlag(protocol.parnter_multi_mount_res_id, 0, 0)
			partner_obj:SetMountOtherObjId(COMMON_CONSTS.INVALID_OBJID)
		end
	end
end

function Scene.SendChangeSceneLineReq(scene_key)
	local main_role = Scene.Instance:GetMainRole()
	if main_role:IsJump() or main_role.vo.move_mode == MOVE_MODE.MOVE_MODE_JUMP2 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.CannotChangeLine2)
		return
	end
	local now_scene_key = PlayerData.Instance:GetAttr("scene_key") or 0
	if now_scene_key ~= scene_key then
		local protocol = ProtocolPool.Instance:GetProtocol(CSChangeSceneLineReq)
		protocol.scene_key = scene_key or 0
		protocol:EncodeAndSend()
	end
end

-- 同步跳跃
function Scene.SendSyncJump(scene_id, pos_x, pos_y, scene_key)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSyncJump)
	protocol.scene_id = scene_id
	protocol.scene_key = scene_key
	protocol.pos_x = pos_x
	protocol.pos_y = pos_y
	protocol.item_id = 0
	protocol:EncodeAndSend()
end

function Scene.SendReqGatherGeneraterList(get_scene_id, scene_key)
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqGatherGeneraterList)
	protocol.get_scene_id = get_scene_id
	protocol.scene_key = scene_key or 1
	protocol:EncodeAndSend()
end


function Scene:OnGatherBeGather(protocol)
	local obj = self:GetObj(protocol.gather_obj_id)
	if obj and obj.vo and obj.vo.special_gather_type == SPECIAL_GATHER_TYPE.BOSS_TOMBSTONE then
		obj.vo.param = 1
		obj.vo.param3 = protocol.left_gather_times
		obj:UpdateTombstone()
	end
	local role_obj = self:GetObj(protocol.gather_role_obj_id)
	if role_obj and role_obj:IsMainRole() and obj:GetType() == SceneObjType.GatherObj then
		local gather_id = protocol.gather_id
		local gather_cfg = ConfigManager.Instance:GetAutoConfig("gather_auto").gather_list[gather_id]
		if gather_cfg then
			if gather_cfg.bundle ~= "" then
				self:PlayGatherEffect(obj or role_obj, gather_cfg.bundle, gather_cfg.asset, gather_cfg.effect_scale, gather_cfg.voice)
			end
		end
	end
end

-- 采集物OBJ，特效路径，特效名字
function Scene:PlayGatherEffect(gather_obj, bundle, asset, effect_scale, voice)
	if effect_scale == "" then
		effect_scale = nil
	end
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		-- local gather_transform = gather_obj:GetDrawObj():GetTransfrom()
		local gather_transform = gather_obj:GetRoot().transform
		if gather_transform then
			EffectManager.Instance:PlayControlEffect(
				asset,
				bundle,
				gather_transform.position,
				nil,
				gather_transform,
				effect_scale
			)
		end

		self.effect_cd = Status.NowTime + EFFECT_CD
	end
	if voice and voice ~= "" then
		AudioManager.PlayAndForget(AssetID("audios/sfxs/other", voice))
	end
end