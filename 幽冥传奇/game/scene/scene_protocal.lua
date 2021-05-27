
Scene = Scene or BaseClass(BaseController)

function Scene:RegisterAllProtocols()
	self:RegisterProtocol(SCVisibleObjEnter, "OnVisibleObjEnter")
	self:RegisterProtocol(SCVisibleObjEnterRole, "OnVisibleObjEnterRole")
	self:RegisterProtocol(SCSpecialEntity, "OnSpecialEntity")
	self:RegisterProtocol(SCEntityAttrChange, "OnEntityAttrChange")
	self:RegisterProtocol(SCVisibleObjLeave, "OnVisibleObjLeave")
	self:RegisterProtocol(SCRestPos, "OnRestPos")
	self:RegisterProtocol(SCObjMove, "OnObjMove")
	self:RegisterProtocol(SCChangeScene, "OnChangeScene")
	self:RegisterProtocol(SCTransmitRole, "OnTransmitRole")
	self:RegisterProtocol(SCObjRun, "OnObjRun")
	self:RegisterProtocol(SCCommonOperateAck, "OnCommonOperateAck")
	self:RegisterProtocol(SCMomentMove, "OnMomentMove")
	self:RegisterProtocol(SCChangeRoleNameColor, "OnChangeRoleNameColor")
	self:RegisterProtocol(SCChangeName, "OnChangeName")
	self:RegisterProtocol(SCAreaAttr, "OnAreaAttr")
	self:RegisterProtocol(SCEntityDie, "OnEntityDie")
	self:RegisterProtocol(SCObjMoveForward, "OnObjMoveForward")
	self:RegisterProtocol(SCObjMoveBack, "OnObjMoveBack")
	self:RegisterProtocol(SCAddEffect, "OnAddEffect")
	self:RegisterProtocol(SCAddSceneEffect, "OnAddSceneEffect")
	self:RegisterProtocol(SCRemoveEffect, "OnRemoveEffect")
	self:RegisterProtocol(SCVisibleObjEnterFallItem, "OnVisibleObjEnterFallItem")
	self:RegisterProtocol(SCFallItemReviseTime, "OnFallItemReviseTime")
	self:RegisterProtocol(SCNpcTaskState, "OnNpcTaskState")
	self:RegisterProtocol(SCSceneAreaInfo, "OnSceneAreaInfo")
	self:RegisterProtocol(SCBossAscriptionChange, "OnBossAscriptionChange")
	self:RegisterProtocol(SCXiaShuAttrChange, "OnXiaShuAttrChange")
	self:RegisterProtocol(SCXiaShuPosChange, "OnXiaShuPosChange")
	self:RegisterProtocol(SCPlayerPkReq, "OnPlayerPkReq")
	self:RegisterProtocol(SCActScreenShake, "OnActScreenShake")

end

-- 场景对象进入视野
function Scene:OnVisibleObjEnter(protocol)
	local obj_type = SceneObjType.Unknown
	local vo = nil
	if protocol.entity_type == EntityType.Hero
		or IsMonsterByEntityType(protocol.entity_type)
		or protocol.entity_type == EntityType.ActorSlave
		or protocol.entity_type == EntityType.Pet
		or protocol.entity_type == EntityType.Saparation then
		-- if protocol.entity_type == EntityType.Saparation then
		-- 	obj_type = SceneObjType.FenShenObj
		-- 	vo = GameVoManager.Instance:CreateVo(MonsterVo)
		-- else
				
		-- end

	
		obj_type = SceneObjType.Monster
		vo = GameVoManager.Instance:CreateVo(MonsterVo)
		vo.name_color = protocol.name_color
		vo.monster_race = protocol.monster_race
		vo.monster_type = protocol.monster_type
		vo.monster_id = protocol.monster_id
		vo.ascription = protocol.ascription
		vo.owner_obj_id = protocol.owner_obj_id
		vo.is_hide_name = protocol.is_hide_name
		vo.buff_list = protocol.buff_list
		vo.effect_list = protocol.effect_list
		vo.mabi_race = protocol.mabi_race
	elseif protocol.entity_type == EntityType.Npc then
		obj_type = SceneObjType.Npc
		vo = GameVoManager.Instance:CreateVo(NpcVo)
		vo.npc_id = protocol.npc_id
		vo.npc_type = protocol.npc_type
		vo.task_state = protocol.task_state
		vo.is_special_model = protocol.is_special_model
	end

	if nil == vo then return end

	local names = Split(protocol.all_name, "\\")

	vo.obj_id = protocol.obj_id
	vo.entity_type = protocol.entity_type
	vo.name = names[1]
	vo.owner_name = names[2]
	vo.pos_x = protocol.attr[OBJ_ATTR.ENTITY_X]
	vo.pos_y = protocol.attr[OBJ_ATTR.ENTITY_Y]
	vo.dir = protocol.attr[OBJ_ATTR.ENTITY_DIR]

	for k, v in pairs(protocol.attr) do
		vo[k] = v
	end

	local obj = self:CreateObj(vo, obj_type)
	if obj and obj_type == SceneObjType.Monster then
		if not obj:IsBiaoche() then
			obj:SetNameLayerShow(self.is_show_monster_name)
		end
		if obj:IsPet() then
			obj:GetModel():SetVisible(not self:IsPingbiPet())
			obj:GetModel():SetScale(self.is_little_pet and 0.66 or 1)
		elseif obj:IsHero() then
			obj:GetModel():SetVisible(not self:IsPingbiHero())
			obj:SetIsPingbiChibang(self:IsPingbiWing())
		elseif obj:IsCommon() then
			obj:GetModel():SetVisible(not self.is_pinbi_monster)
		end
	end
	if protocol.entity_type == EntityType.Pet then
		local mainrole = Scene.Instance:GetMainRole()
		if mainrole:GetObjId() == protocol.owner_obj_id then
			mainrole:SetAttr("pet_obj_id", protocol.obj_id)
		end
	end
end

-- 角色进入视野
function Scene:OnVisibleObjEnterRole(protocol)
	local scene_obj = self:GetObjectByObjId(protocol.obj_id)
	if scene_obj then
		self:DeleteObj(protocol.obj_id)
	end

	local names = Split(protocol.all_name, "\\")

	local role_vo = GameVoManager.Instance:CreateVo(RoleVo)
	role_vo.obj_id = protocol.obj_id
	role_vo.entity_type = EntityType.Role
	role_vo.name = names[1] or ""
	role_vo.guild_name = names[2] or ""
	role_vo.partner_name = names[6] or ""
	role_vo.pos_x = protocol.attr[OBJ_ATTR.ENTITY_X]
	role_vo.pos_y = protocol.attr[OBJ_ATTR.ENTITY_Y]
	role_vo.dir = protocol.attr[OBJ_ATTR.ENTITY_DIR]
	role_vo.name_color = protocol.name_color
	role_vo.name_color_state = protocol.name_color_state

	for k, v in pairs(protocol.attr) do
		role_vo[k] = v
	end
	role_vo.effect_list = protocol.effect_list
	self:CreateRole(role_vo)
end

function Scene:OnSpecialEntity(protocol)
	local scene_obj = self:GetObjectByObjId(protocol.obj_id)
	if scene_obj then
		self:DeleteObj(protocol.obj_id)
	end

	local vo = GameVoManager.Instance:CreateVo(SpecialVo)
	vo.obj_id = protocol.obj_id
	vo.entity_type = bit:_rshift(protocol.obj_id, 32)
	vo.pos_x = protocol.pos_x
	vo.pos_y = protocol.pos_y
	vo.name = protocol.name
	vo.model_id = protocol.model_id

	self:CreateSpecialObj(vo)
end

function Scene:OnEntityAttrChange(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil ~= scene_obj then
		for k, v in pairs(protocol.attr_list) do
			scene_obj:SetAttr(v.index, v.value)
			GlobalEventSystem:Fire(ObjectEventType.OBJ_ATTR_CHANGE, scene_obj, v.index, v.value)
		end
	end
end

function Scene:OnVisibleObjLeave(protocol)
	local obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil ~= obj then
		self:DeleteObj(protocol.obj_id)
	end
end

function Scene:OnRestPos(protocol)
	local self_x, self_y = self.main_role:GetLogicPos()
	if self_x == protocol.pos_x and self_y == protocol.pos_y then
		return
	end

	self.main_role:SetLogicPos(protocol.pos_x, protocol.pos_y)
	self.main_role:ClearAction(true)
end

function Scene:OnObjMove(protocol)
	local scene_obj = self:GetObjectByObjId(protocol.obj_id)
	if scene_obj and scene_obj:IsCharacter() then
		scene_obj:ClearAction(true)
		scene_obj:DoMove(protocol.pos_x, protocol.pos_y)
	end
end

function Scene:OnObjRun(protocol)
	self:OnObjMove(protocol)
end

function Scene:OnObjMoveForward(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsCharacter() then
		scene_obj:DoSpecialMove(protocol.pos_x, protocol.pos_y, protocol.move_speed)
	end
end

function Scene:OnChangeScene(protocol)
	Log("Scene:OnChangeScene, scene_id:", protocol.scene_id)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	main_role_vo.scene_id = protocol.scene_id
	main_role_vo.scene_type = protocol.scene_type
	main_role_vo.pos_x = protocol.pos_x
	main_role_vo.pos_y = protocol.pos_y
	main_role_vo.fb_id = protocol.fb_id
	GlobalEventSystem:Fire(SceneEventType.SCENE_LOADING_STATE_ENTER, protocol.scene_id, protocol.scene_type, protocol.fb_id)
end

function Scene:OnTransmitRole(protocol)
	local scene_obj = self:GetObjectByObjId(protocol.obj_id)
	if nil == scene_obj then
		return
	end
	scene_obj.vo.pos_x = protocol.pos_x
	scene_obj.vo.pos_y = protocol.pos_y
	scene_obj.vo.dir = protocol.dir
	scene_obj:SetLogicPos(protocol.pos_x, protocol.pos_y)
end

function Scene:OnCommonOperateAck(protocol)
end

function Scene:OnMomentMove(protocol)
	local scene_obj = self:GetObjectByObjId(protocol.obj_id)
	if scene_obj then
		scene_obj:SetLogicPos(protocol.pos_x, protocol.pos_y)
		if scene_obj:GetDirNumber() ~= protocol.dir then
			scene_obj:SetDirNumber(protocol.dir)
			scene_obj:RefreshAnimation()
		end
	end
end

function Scene:OnChangeRoleNameColor(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil ~= scene_obj then
		scene_obj:SetAttr("name_color", protocol.name_color)
		scene_obj:SetAttr("name_color_state", protocol.name_color_state)
	end
end

local is_submit_roledata = false
function Scene:OnChangeName(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil ~= scene_obj then
		local names = Split(protocol.name, "\\")
		scene_obj:SetAttr("name", names[1] or "")
		if scene_obj:GetType() == SceneObjType.Monster then
			scene_obj:SetAttr("owner_name", names[2])
		else
			if nil ~= scene_obj:GetAttr("guild_name") then
				scene_obj:SetAttr("guild_name", names[2] or "")

				-- 主角行会名字在这里才有下发，所以在这里上报角色登陆信息
				if not is_submit_roledata and Scene.Instance:GetMainRole() == scene_obj then
					local user_vo = GameVoManager.Instance:GetUserVo()
					local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
					if AgentAdapter.SubmitRoleData and main_role_vo ~= nil then
						local zone_name = user_vo.plat_server_id .. "服-" .. user_vo.plat_server_name
						AgentAdapter:SubmitRoleData(main_role_vo[OBJ_ATTR.ENTITY_ID], main_role_vo.name, main_role_vo[OBJ_ATTR.CREATURE_LEVEL], user_vo.plat_server_id, zone_name)
						is_submit_roledata = true
					end
				end
			end
			if nil ~= scene_obj:GetAttr("partner_name") then
				scene_obj:SetAttr("partner_name", names[6] or "")
			end
		end
	end
end

function Scene:OnAreaAttr(protocol)
	self.cur_area_info.area_name = protocol.area_name
	self.cur_area_info.attr_t = protocol.attr_t

	local is_danger = protocol.area_name == Language.Map.DangerArea
	if self.cur_area_info.is_danger ~= is_danger then
		self.cur_area_info.is_danger = is_danger
		if self.cur_area_info.is_danger then
			SysMsgCtrl.Instance:FloatingTopRightText("{wordcolor;ff2828;您已经离开安全区域}")
		else
			SysMsgCtrl.Instance:FloatingTopRightText("{wordcolor;1eff00;您已经进入安全区域}")
		end
	end

	GlobalEventSystem:Fire(SceneEventType.SCENE_AREA_ATTR_CHANGE, self.cur_area_info)
end

function Scene:OnEntityDie(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsCharacter() then
		-- 死亡时校准主角坐标
		if scene_obj:IsMainRole() then
			self.main_role:SetLogicPos(protocol.pos_x, protocol.pos_y)
			self.main_role:ClearAction(true)
		end
	end
end

function Scene:OnAddEffect(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsCharacter() then
	
		-- 左上浮动文字处理
		if EffectType.leftTopFloatTxt == protocol.effect_type then
			scene_obj:FloatingAttrTxt(protocol.effect_id)
			return
		end

		local is_relate_main_role = scene_obj:IsMainRole()
		if FightCtrl.Instance:GetIsCanPlayEffect(protocol.effect_id, is_relate_main_role) then
			if protocol.effect_type == EffectType.Throw or protocol.effect_type == EffectType.Fly then
				local deliverer = Scene.Instance:GetObjectByObjId(protocol.deliverer_obj_id)
				if nil ~= deliverer then
					local vo = GameVoManager.Instance:CreateVo(EffectObjVo)
					vo.deliverer_obj_id = protocol.deliverer_obj_id
					vo.entity_type = EntityType.Effect
					vo.effect_type = protocol.effect_type
					vo.effect_id = protocol.effect_id
					vo.pos_x, vo.pos_y = deliverer:GetLogicPos()
					vo.target_pos_x, vo.target_pos_y = scene_obj:GetLogicPos()
					vo.remain_time = protocol.remain_time
					self:CreateEffectObj(vo)
				end
			elseif scene_obj:GetModel():IsVisible() then
				scene_obj:AddEffect(protocol.effect_id, protocol.effect_type, protocol.remain_time)
			end
		end
		if protocol.sound_id > 0 then
			AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(protocol.sound_id))
		end
	end
end

function Scene:OnAddSceneEffect(protocol)
	if protocol.effect_type == 7 then -- 秒杀BOSS
		local text_pos = HandleRenderUnit:LogicToWorld(cc.p(protocol.pos_x, protocol.pos_y))
		FightTextMgr:OnChangeHp(text_pos.x, text_pos.y + 100, -protocol.param, 186, false)
		FindBossData.Instance:SetCanCastSecondKill(false)
		-- 震屏
		Story.Instance:ActShake(8)
	end
	if FightCtrl.Instance:GetIsCanPlayEffect(protocol.effect_id) then
		local vo = GameVoManager.Instance:CreateVo(EffectObjVo)
		vo.deliverer_obj_id = protocol.obj_id
		vo.entity_type = EntityType.Effect
		vo.effect_type = protocol.effect_type
		vo.effect_id = protocol.effect_id
		vo.pos_x = protocol.pos_x
		vo.pos_y = protocol.pos_y
		vo.target_pos_x = protocol.pos_x
		vo.target_pos_y = protocol.pos_y
		vo.remain_time = protocol.remain_time
		self:CreateEffectObj(vo)
		if protocol.sound_id > 0 then
			AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(protocol.sound_id))
		end
		if protocol.effect_type ~= 7 and bit:_and(1, bit:_rshift(protocol.param, 0)) > 0 then --地震
			Story.Instance:ActShake(1)
		end
	end
end

function Scene:OnRemoveEffect(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsCharacter() then
		scene_obj:RemoveEffect(protocol.effect_id, protocol.effect_type)
	end
end

function Scene:OnObjMoveBack(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsCharacter() then
		scene_obj:DoSpecialMove(protocol.pos_x, protocol.pos_y, protocol.move_speed)
	end
end

function Scene:OnVisibleObjEnterFallItem(protocol)
	local scene_obj = self:GetObjectByObjId(protocol.obj_id)
	if scene_obj then
		self:DeleteObj(protocol.obj_id)
	end

	local vo = GameVoManager.Instance:CreateVo(FallItemVo)
	vo.obj_id = protocol.obj_id
	vo.entity_type = EntityType.FallItem
	vo.name = protocol.item_name
	vo.item_id = protocol.item_id
	vo.item_num = protocol.item_num
	vo.zhuanshen_level = protocol.zhuanshen_level
	vo.quanghua_level = protocol.quanghua_level
	vo.item_type = protocol.item_type
	vo.level = protocol.level
	vo.zhuan = protocol.zhuan
	vo.pos_x = protocol.pos_x
	vo.pos_y = protocol.pos_y
	vo.dir = protocol.dir
	vo.icon_id = protocol.icon_id
	vo.color = protocol.color
	vo.is_remind = protocol.is_remind
	vo.lock_time = protocol.lock_time
	vo.fall_time = protocol.fall_time
	vo.expire_time = protocol.expire_time
	ItemData.Instance:GetItemConfig(vo.item_id)
	self:CreateFallItem(vo)
end

function Scene:OnFallItemReviseTime(protocol)
	local scene_obj = self:GetObjectByObjId(protocol.obj_id)
	if scene_obj and scene_obj:GetType() == SceneObjType.FallItem then
		scene_obj:SetLockTime(0)
	end
end

function Scene:OnNpcTaskState(protocol)
	local scene_obj = self:GetObjectByObjId(protocol.obj_id)
	if scene_obj and scene_obj:GetType() == SceneObjType.Npc then
		scene_obj:SetTaskState(protocol.task_state)
	end
end

function Scene:OnSceneAreaInfo(protocol)
	self.scene_area_info_list = self.scene_area_info_list or {}

	local default_index = nil
	for k,v in pairs(protocol.area_list) do
		local point_list = v.point_list

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
		local default_area = table.remove(protocol.area_list, default_index)
		self.scene_area_info_list[protocol.scene_id] = {
			default_area = default_area,
			area_list = protocol.area_list
		}
		GlobalEventSystem:Fire(ObjectEventType.OBJ_ATTR_CHANGE)
	end
end

function Scene:OnBossAscriptionChange(protocol)
	local monster_list = self:GetMonsterList()
	for k,v in pairs(monster_list) do
		if v:GetVo().obj_id == protocol.obj_id then
			v:GetVo().ascription = protocol.ascription
			GlobalEventSystem:Fire(ObjectEventType.OBJ_ATTR_CHANGE, v, "ascription", {v:GetVo().name, protocol.ascription, protocol.role_id})
		end
	end
end

function Scene:OnXiaShuAttrChange(protocol)

end

function Scene:OnXiaShuPosChange(protocol)

end

function Scene:ScenePickItem(obj_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSPickUpItemReq)
	protocol.obj_id = obj_id
	protocol:EncodeAndSend()
end

------------------------------------------------------------------------
function Scene.SendQuicklyTransportReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSQuicklyTransmitReq)
	protocol.index = index
	protocol:EncodeAndSend()
end

function Scene.SendQuicklyTransportReqByNpcId(npc_id)
	if nil == npc_id then
		return
	end
	for _, v in pairs(ChuansongPoint) do
		if v.ncpid == npc_id then
			Scene.SendQuicklyTransportReq(v.id)
			return
		end
	end
end

function Scene.SendTransmitSceneReq(scene_id, x, y)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSceneTransmitReq)
	protocol.scene_id = scene_id or 0
	protocol.pos_x = x or 0
	protocol.pos_y = y or 0
	protocol:EncodeAndSend()
end

function Scene.SendTransmitToRobEscortReq(scene_id, x, y)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTransmitToRobEscortReq)
	protocol.scene_id = scene_id or 0
	protocol.pos_x = x or 0
	protocol.pos_y = y or 0
	protocol:EncodeAndSend()
end

function Scene:OnActScreenShake(protocol)
	Story.Instance:ActShake(1)
end

function Scene:OnPlayerPkReq(protocol)
	local data = {
		req_name = protocol.req_name,
		scene_id = protocol.scene_id,
		scene_name = protocol.scene_name,
		x = protocol.x,
		y = protocol.y,
	}

	if nil == self.pk_req_list then
		self.pk_req_list = {}
	end
	table.insert(self.pk_req_list, data)

	self:CheckPkReqTip()
end

function Scene.SentPkAnswer(answer, req_name, scene_id, scene_name, x, y)
	local protocol = ProtocolPool.Instance:GetProtocol(CSPkReqAnswer)
	protocol.answer = answer or 0
	protocol.req_name = req_name or ""
	protocol.scene_id = scene_id or 0
	protocol.scene_name = scene_name or ""
	protocol.x = x or 0
	protocol.y = y or 0
	protocol:EncodeAndSend()
end

function Scene:CheckPkReqTip()
	local num = #self.pk_req_list
	MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.PLAY_PK_REQ, num, function ()
		local data = table.remove(self.pk_req_list, 1)
		self.call_alert = self.call_alert or Alert.New()
		self.call_alert:SetIsAnyClickClose(false)
		local content = string.format(Language.Common.PkReqAlert, data.req_name, data.scene_name)
		self.call_alert:SetLableString(content)
		self.call_alert:SetOkFunc(function ()
			Scene.SentPkAnswer(1, data.req_name, data.scene_id, data.scene_name, data.x, data.y)
			self.pk_req_list = {}
			self:CheckPkReqTip()
		end)
		self.call_alert:SetCancelFunc(function ()
			Scene.SentPkAnswer(0, data.req_name, data.scene_id, data.scene_name, data.x, data.y)
			local req_list = {}
			for i,v in ipairs(self.pk_req_list) do
				if v.req_name ~= data.req_name then
					table.insert(req_list, v)
				end
			end
			self.pk_req_list = req_list
			self:CheckPkReqTip()
		end)
		self.call_alert:SetShowCheckBox(false)
		self.call_alert:Open()
	end)
end
