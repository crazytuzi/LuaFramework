
require("game/fight/fight_def")
require("game/fight/fight_data")
require("game/fight/fight_text")

-- 战斗
FightCtrl = FightCtrl or BaseClass(BaseController)

function FightCtrl:__init()
	if FightCtrl.Instance ~= nil then
		print_error("[FightCtrl] attempt to create singleton twice!")
		return
	end
	FightCtrl.Instance = self

	self.data = FightData.New()
	FightText.New()

	self.last_skill_id = 0
	self.last_atk_time = 0

	self:RegisterAllProtocols()

	Runner.Instance:AddRunObj(self, 5)
	self.monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list
end

function FightCtrl:__delete()
	self:RemoveDelayTime()
	FightCtrl.Instance = nil

	FightText.Instance:DeleteMe()

	self.data:DeleteMe()
	self.data = nil

	Runner.Instance:RemoveRunObj(self)
	self.monster_cfg = nil
end

function FightCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCObjChangeBlood, "OnObjChangeBlood")
	self:RegisterProtocol(SCPerformSkill, "OnPerformSkill")
	self:RegisterProtocol(SCPerformAOESkill, "OnPerformAOESkill")
	self:RegisterProtocol(SCRoleReAlive, "OnRoleReAlive")
	self:RegisterProtocol(SCFixPos, "OnFixPos")
	self:RegisterProtocol(SCSkillTargetPos, "OnSkillTargetPos")
	self:RegisterProtocol(SCBuffMark, "OnBuffMark")
	self:RegisterProtocol(SCBuffAdd, "OnBuffAdd")
	self:RegisterProtocol(SCBuffRemove, "OnBuffRemove")
	self:RegisterProtocol(SCEffectList, "OnEffectList")
	self:RegisterProtocol(SCEffectInfo, "OnEffectInfo")
	self:RegisterProtocol(SCEffectRemove, "OnEffectRemove")
	self:RegisterProtocol(SCFightSpecialFloat, "OnFightSpecialFloat")
	self:RegisterProtocol(SCSpecialShieldChangeBlood, "OnSpecialShieldChangeBlood")
	self:RegisterProtocol(SCSkillPhase, "OnSkillPhase")
	self:RegisterProtocol(SCZhiBaoAttack, "OnZhiBaoAttack")
	self:RegisterProtocol(SCBianShenView, "BianShenView")
	self:RegisterProtocol(SCInvisibleView, "InvisibleView")
end

function FightCtrl:Update(now_time, elapse_time)
	self.data:Update(now_time, elapse_time)
end

function FightCtrl:OnObjChangeBlood(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end

	if protocol.real_blood ~= 0 then
		obj:SetAttr("hp", obj:GetAttr("hp") + protocol.real_blood)
	end

	if protocol.real_blood > 0 and protocol.fighttype == FIGHT_TYPE.NORMAL then
		return
	end

	local deliverer = Scene.Instance:GetObj(protocol.deliverer)

	local fighttype = protocol.fighttype
	--判断玩家龙行天下头衔打架伤害显示类型
	if deliverer ~= nil and obj ~= nil and deliverer:IsRole() and obj:IsRole() and deliverer:GetVo().molong_rank > obj:GetVo().molong_rank and protocol.fighttype == 1 then
		fighttype = FIGHT_TYPE.YAZHI
	end

	-- 没有攻击者或者技能id为0直接处理受击效果
	if nil == deliverer or 0 == protocol.skill then
		--灵宠伤害
		if fighttype == FIGHT_TYPE.LINGCHONG then
			obj:DoBeHit(deliverer, protocol.skill, protocol.real_blood, protocol.blood, fighttype)
		else
			obj:DoBeHit(nil, protocol.skill, protocol.real_blood, protocol.blood, fighttype)
		end
	else
		-- 主角攻击特殊处理
		local role_hurt, nvshen_hurt = self:CalculateHurt(protocol.blood)
		local is_trigger = false

		local text_type = nil
		if nil ~= deliverer and deliverer:IsMainRole() and fighttype == FIGHT_TYPE.BAOJI and obj:IsRole() and deliverer:GetVo().molong_rank > obj:GetVo().molong_rank then
			text_type = FIGHT_TEXT_TYPE.BAOJI
		end

		if deliverer:IsMainRole() then
			-- 不是本次攻击的，或者已经击中直接表现
			if (protocol.skill ~= deliverer:GetLastSkillId() or deliverer:AtkIsHit(protocol.skill))
			and deliverer.vo.special_appearance ~= SPECIAL_APPEARANCE_TYPE.SPECIAL_APPERANCE_TYPE_TERRITORYWAR then

				is_trigger = true
				obj:DoBeHit(deliverer, protocol.skill, protocol.real_blood, role_hurt, fighttype, text_type)
				if nvshen_hurt < 0 then
					obj:DoBeHit(deliverer, 0, 0, nvshen_hurt, fighttype, FIGHT_TEXT_TYPE.NVSHEN)
				end
			end
			GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_DO_HIT, obj, protocol.blood)
		else
			nvshen_hurt = 0
		end
		if not is_trigger then
			-- 尚未击中先缓存
			self.data:SaveBeHitInfo(protocol.obj_id, protocol.deliverer, protocol.skill,
				protocol.real_blood, role_hurt, fighttype, nvshen_hurt, text_type)
		end
	end

	if obj:IsMainRole() and nil ~= deliverer then
		GlobalEventSystem:Fire(ObjectEventType.MAIN_ROLE_BE_HIT, deliverer)
		if not deliverer:IsMainRole() then
			if deliverer:GetType() == SceneObjType.Trigger then
				ReviveData.Instance:SetKillerName(deliverer.vo.trigger_name or "")
				obj:DoBeHit(deliverer, protocol.skill, protocol.real_blood, protocol.blood, fighttype)
			else
				ReviveData.Instance:SetKillerName(deliverer:GetName() or "")
			end
		end
	end

	local skill_list = bit:d2b(protocol.passive_flag)
	for i,v in ipairs(skill_list) do
		if v == 1 then
			local pos = nil
			if i == PASSIVE_FLAG.PASSIVE_FLAG_JING_LING_LEI_TING + 1 then
				pos = obj and obj.draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(2)
				if nil ~= pos then
					local bundle_name, prefab_name = ResPath.GetMiscEffect(PASSIVE_FLAG_RES[i - 1] or "tongyong_lei")
					EffectManager.Instance:PlayControlEffect(bundle_name, prefab_name, pos.transform.position)
				end
			elseif i == PASSIVE_FLAG.PASSIVE_FLAG_JING_LING_XI_XUE + 1 and deliverer then
				pos = deliverer and deliverer.draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(2)
				if nil ~= pos then
					local bundle_name, prefab_name = ResPath.GetBuffEffect(PASSIVE_FLAG_RES[i - 1] or "Buff_nvshenzhufu")
					EffectManager.Instance:PlayControlEffect(bundle_name, prefab_name, pos.transform.position)
				end
			end
			-- if nil ~= pos then
			-- 	local bundle_name, prefab_name = ResPath.GetMiscEffect(PASSIVE_FLAG_RES[i - 1] or "tongyong_lei")
			-- 	EffectManager.Instance:PlayControlEffect(bundle_name, prefab_name, pos.transform.position)
			-- end
		end
	end

	self:KillRoleInBossScene(obj, deliverer)
end

-- 在BOSS场景中杀人，弹出UI
function FightCtrl:KillRoleInBossScene(obj, deliverer)
	if nil == obj or nil == deliverer then
		return
	end

	local scene_logic = Scene.Instance:GetSceneLogic()
	if not scene_logic:GetIsInBossScene() then
		return
	end

	if obj:IsMainRole()
		or not obj:IsRole()
		or not obj:IsRealDead()
		or not deliverer:IsMainRole() then
		return
	end

	KillRoleCtrl.Instance:ShowKillView(TableCopy(obj:GetVo()))
end

function FightCtrl:OnPerformSkill(protocol)
	local deliverer = Scene.Instance:GetObj(protocol.deliverer)
	if nil == deliverer or not deliverer:IsCharacter() then
		return
	end

	-- if deliverer:IsMainRole() then
	-- 	return
	-- end

	local target_obj = Scene.Instance:GetObj(protocol.target)
	if nil == target_obj then
		return
	end
	local target_x, target_y = target_obj:GetLogicPos()

	if deliverer:IsMainRole() then -- and (protocol.skill == 221 or protocol.skill == 321)
		SkillData.Instance:UseSkill(protocol.skill)
		SkillData.Instance:RecordSkillProficiency(protocol.skill)
		PlayerCtrl.Instance:FlushPlayerSkillView()
	else
		deliverer:DoAttack(protocol.skill, target_x, target_y, protocol.target)
		deliverer.attack_index = protocol.skill_data
	end
end

function FightCtrl:OnPerformAOESkill(protocol)
	local deliverer = Scene.Instance:GetObj(protocol.obj_id)
	if nil == deliverer or not deliverer:IsCharacter() then
		return
	end

	-- 怪物在施法阵过程中，会一直收到AOE，法阵原因不处理
	if AOE_REASON.AOE_REASON_FAZHEN == protocol.aoe_reason then
		return
	end

	if not deliverer:IsMainRole() then
		deliverer.attack_index = protocol.skill_data
		deliverer:DoAttack(protocol.skill, protocol.pos_x, protocol.pos_y, protocol.target)
	else--if protocol.skill == 221 or protocol.skill == 321 then
		SkillData.Instance:UseSkill(protocol.skill)
		SkillData.Instance:RecordSkillProficiency(protocol.skill)
		PlayerCtrl.Instance:FlushPlayerSkillView()
	end
end

function FightCtrl:OnRoleReAlive(protocol)
	local target_obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == target_obj then
		return
	end
	target_obj:SetLogicPos(protocol.pos_x, protocol.pos_y)
	target_obj:DoStand()
	ReviveData.Instance:SetRoleReviveInfo(protocol)
end

function FightCtrl:OnFixPos(protocol)
	Scene.Instance:GetMainRole():SetLogicPos(protocol.x, protocol.y)
end

-- 技能目标位置
function FightCtrl:OnSkillTargetPos(protocol)
	local obj = Scene.Instance:GetObj(protocol.target_obj_id)
	if obj then
		obj:SetLogicPos(protocol.pos_x, protocol.pos_y)
	end
end

function FightCtrl:OnBuffMark(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end

	obj:SetBuffList(bit:ll2b(protocol.buff_mark_high, protocol.buff_mark_low))
end

function FightCtrl:OnBuffAdd(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end

	obj:AddBuff(protocol.buff_type)
end

function FightCtrl:OnBuffRemove(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end

	obj:RemoveBuff(protocol.buff_type)
end

function FightCtrl:OnEffectList(protocol)
	self.data:OnEffectList(protocol)
end

function FightCtrl:OnEffectInfo(protocol)
	self.data:OnEffectInfo(protocol)
end

function FightCtrl:OnEffectRemove(protocol)
	self.data:OnEffectRemove(protocol.effect_key)
end

function FightCtrl:OnFightSpecialFloat(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end

	local deliverer = Scene.Instance:GetObj(protocol.deliver_obj_id)
	if protocol.float_type == FLOAT_VALUE_TYPE.EFFECT_UP_GRADE_SKILL then
		obj:DoBeHit(deliverer, 0, 0, protocol.float_value, FIGHT_TYPE.NORMAL, FIGHT_TEXT_TYPE.SHENSHENG)
		local bundle_name, prefab_name = ResPath.GetMiscEffect(ATTATCH_SKILL_SPECIAL_EFFECT_RES[protocol.skill_special_effect] or"tongyong_lei")
		local deliverer_pos = nil
		if deliverer then
			deliverer_pos = deliverer:GetRoot().transform.position
		end
		EffectManager.Instance:PlayControlEffect(bundle_name, prefab_name, obj:GetRoot().transform.position, deliverer_pos)
	elseif protocol.float_type == FLOAT_VALUE_TYPE.EFFECT_REBOUNDHURT then
		-- 精灵的反弹技能特殊处理
		if protocol.skill_special_effect == ATTATCH_SKILL_SPECIAL_EFFECT.SPECIAL_EFFECT_JINGLING_REBOUNDHURT and nil ~= deliverer then
			deliverer:AddEffect(ATTATCH_SKILL_SPECIAL_EFFECT_RES[protocol.skill_special_effect], 2)
		else
			local pos = obj.draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(AttachPoint.BuffMiddle)
			local bundle_name, prefab_name = ResPath.GetMiscEffect(ATTATCH_SKILL_SPECIAL_EFFECT_RES[protocol.skill_special_effect] or "tongyong_lei")
			if pos == nil then return end
			EffectManager.Instance:PlayControlEffect(bundle_name, prefab_name, pos.transform.position)
		end
		obj:DoBeHit(deliverer, 0, 0, protocol.float_value, FIGHT_TYPE.NORMAL, FIGHT_TEXT_TYPE.NVSHEN_FAN)
	elseif protocol.float_type == FLOAT_VALUE_TYPE.EFFECT_RESTORE_HP then
		-- 精灵回血技能服务端会发个0过来 因为只需要到飘字，但特效的播放会通过另外的一条协议（我也很无奈 --||）
		if protocol.skill_special_effect > 0 then
			local pos = obj.draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(AttachPoint.BuffMiddle)
			if pos == nil then return end
			local bundle_name, prefab_name = ResPath.GetMiscEffect(ATTATCH_SKILL_SPECIAL_EFFECT_RES[protocol.skill_special_effect] or "tongyong_lei")
			EffectManager.Instance:PlayControlEffect(bundle_name, prefab_name, pos.transform.position)
		end
	elseif protocol.float_type == FLOAT_VALUE_TYPE.EFFECT_NORMAL_HURT then
		local pos = obj.draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(AttachPoint.BuffMiddle)
		if pos == nil then return end
		local bundle_name, prefab_name = ResPath.GetMiscEffect(ATTATCH_SKILL_SPECIAL_EFFECT_RES[protocol.skill_special_effect] or "tongyong_lei")
		EffectManager.Instance:PlayControlEffect(bundle_name, prefab_name, pos.transform.position)
		obj:DoBeHit(deliverer, 0, 0, protocol.float_value, FIGHT_TYPE.NORMAL, FIGHT_TEXT_TYPE.NVSHEN_SHA)
	elseif protocol.float_type == FLOAT_VALUE_TYPE.EFFECT_JUST_SPECIAL_EFFECT then
		local pos = obj.draw_obj:GetPart(SceneObjPart.Main):GetAttachPoint(AttachPoint.BuffMiddle)
		if pos == nil then return end
		local bundle_name, prefab_name = ResPath.GetMiscEffect(ATTATCH_SKILL_SPECIAL_EFFECT_RES[protocol.skill_special_effect] or "tongyong_lei")
		local deliverer_pos = nil
		if deliverer then
			deliverer_pos = deliverer:GetRoot().transform.position
		end
		EffectManager.Instance:PlayControlEffect(bundle_name, prefab_name, pos.transform.position, deliverer_pos)
		if protocol.skill_special_effect >= 60 and protocol.skill_special_effect <= 69 then
			local is_left = true
			if deliverer_pos then
				local screen_pos_1 = UnityEngine.RectTransformUtility.WorldToScreenPoint(MainCamera, pos.transform.position)
				local screen_pos_2 = UnityEngine.RectTransformUtility.WorldToScreenPoint(MainCamera, deliverer_pos)
				is_left = screen_pos_1.x > screen_pos_2.x
			end
			FightText.Instance:ShowLianhunText(pos)
		end
	else
		-- obj:OnFightSpecialFloat(protocol.float_value)
	end
end

function FightCtrl:OnSpecialShieldChangeBlood(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end
	local info = {
		obj_id = protocol.obj_id,
		real_hurt = protocol.real_hurt,
		left_times = protocol.left_times,
		max_times = protocol.max_times,
	}
	GlobalEventSystem:Fire(ObjectEventType.SPECIAL_SHIELD_CHANGE, info)
end

function FightCtrl:OnSkillPhase(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj or not obj:IsMonster() then
		return
	end

	if MAGIC_SKILL_PHASE.READING == protocol.phase then
		if Scene.Instance:GetSceneType() ~= SceneType.Common and Scene.Instance:GetSceneType() ~= SceneType.KfMining then
			ViewManager.Instance:Open(ViewName.BossSkillWarning)
		end
		obj:StartSkillReading(protocol.skill_id)
	end
end

function FightCtrl:RemoveDelayTime()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function FightCtrl:OnZhiBaoAttack(protocol)
	local obj = Scene.Instance:GetObj(protocol.target_id)
	if nil == obj or not obj:IsCharacter() then
		return
	end
	local deliverer = Scene.Instance:GetObj(protocol.attacker_id)
	local is_shield_self = SettingData.Instance:GetSettingData(SETTING_TYPE.SELF_SKILL_EFFECT)
	if is_shield_self then
		if deliverer and deliverer:IsMainRole() then
			return
		end
	end
	local is_shield_other = SettingData.Instance:GetSettingData(SETTING_TYPE.SKILL_EFFECT)
	if is_shield_other then
		if deliverer and not deliverer:IsMainRole() then
			return
		end
	end
	-- print_error("OnZhiBaoAttack  IsMainRole", deliverer:IsMainRole() ,"skill_index:", protocol.skill_index,
	-- "target_id", protocol.target_id, "hurt", protocol.hurt, "is_baoji", protocol.is_baoji)
	local asset_bundle = "effects2/prefab/misc/tongyong_lei_prefab"
	local name = "tongyong_lei"

	if not self.game_root then
		self.game_root = GameObject.Find("GameRoot/SceneObjLayer")
	end
	if self.game_root then
		local effect = AsyncLoader.New(self.game_root.transform)
		local call_back = function(effect_obj)
			if effect_obj then
				local root = obj:GetRoot()
				if root and not IsNil(root.gameObject) then
					effect_obj.transform.localPosition = root.transform.localPosition
				end
			end
		end
		effect:Load(asset_bundle, name, call_back)
		self.timer_quest = GlobalTimerQuest:AddDelayTimer(function() effect:Destroy() effect:DeleteMe() end, 5)
	end

	local fighttype = FIGHT_TYPE.NORMAL
	if protocol.is_baoji == 1 then
		fighttype = FIGHT_TYPE.BAOJI
	end
	if nil == deliverer then
		obj:DoBeHit(nil, 0, 0, protocol.hurt, fighttype, FIGHT_TEXT_TYPE.BAOJU)
	else
		-- 主角攻击特殊处理
		if deliverer:IsMainRole() then
			obj:DoBeHit(deliverer, 0, 0, protocol.hurt, fighttype, FIGHT_TEXT_TYPE.BAOJU)
		end
		-- asset_bundle = "effects/prefabs"
		-- name = "10042"
		-- deliverer:AddBaoJuEffect(asset_bundle, name, 1)
	end
end

function FightCtrl.SendPerformSkillReq(skill_index, attack_index, pos_x, pos_y, target_id, is_specialskill, client_pos_x, client_pos_y)
	--print_warning("ab>>>>>SendPerformSkillReq",skill_index, attack_index, pos_x, pos_y, target_id, is_specialskill, client_pos_x, client_pos_y)
	local protocol = ProtocolPool.Instance:GetProtocol(CSPerformSkillReq)
	protocol.skill_index = skill_index
	protocol.pos_x = pos_x
	protocol.pos_y = pos_y
	protocol.target_id = target_id
	protocol.is_specialskill = is_specialskill and 1 or 0
	protocol.client_pos_x = client_pos_x
	protocol.client_pos_y = client_pos_y
	protocol.skill_data = attack_index
	protocol:EncodeAndSend()
end

function FightCtrl.SendRoleReAliveReq(realive_type, is_timeout_req, item_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRoleReAliveReq)
	protocol.realive_type = realive_type or 0
	protocol.is_timeout_req = is_timeout_req or 0
	protocol.item_index = item_index or 0
	protocol:EncodeAndSend()
end

function FightCtrl.SendGetEffectListReq(obj_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetEffectListReq)
	protocol.target_obj_id = obj_id
	protocol:EncodeAndSend()
end

function FightCtrl:NextCanAtkTime()
	-- if not self.last_skill_id or self.last_skill_id <= 0 then
	-- 	return self.last_atk_time + 0.3
	-- else
	-- 	local is_not_normal_skill = SkillData.IsNotNormalSkill(self.last_skill_id)
	-- 	return is_not_normal_skill and (self.last_atk_time + 0.3) or self.last_atk_time
	-- end

	return self.last_atk_time
end

-- 尝试使用角色技能
function FightCtrl:TryUseRoleSkill(skill_id, target_obj)
	if nil == target_obj then
		return false
	end

	local main_role = Scene.Instance:GetMainRole()
	local is_not_normal_skill = SkillData.IsNotNormalSkill(skill_id)
	if main_role:IsChenMo() and is_not_normal_skill then
		return false
	end

	if main_role:IsAtkPlaying() then
		return false
	end

	local can_use, range = SkillData.Instance:CanUseSkill(skill_id)
	if not can_use then
		return false
	end

	--伙伴技能在一些场景中无法使用
	if GoddessData.Instance:IsGoddessSkill(skill_id) then
		local scene_logic = Scene.Instance:GetSceneLogic()
		if scene_logic and not scene_logic:CanUseGoddessSkill() then
			return false
		end
	end

	local x, y = target_obj:GetLogicPos()
	self:DoAtkOperate(skill_id, x, y, target_obj, false, range)
	return true
end

-- 攻击操作
function FightCtrl:DoAtkOperate(skill_id, x, y, target_obj, is_specialskill, range)
	-- 停止采集
	if Scene.Instance:GetMainRole():GetIsGatherState() then
		Scene.SendStopGatherReq()
	end

	self.last_skill_id = skill_id
	self.last_atk_time = Status.NowTime

	GuajiCtrl.SetAtkValid(true)
	AtkCache.skill_id = skill_id
	AtkCache.x = x
	AtkCache.y = y
	AtkCache.is_specialskill = is_specialskill
	AtkCache.target_obj = target_obj
	AtkCache.target_obj_id = (nil ~= target_obj) and target_obj:GetObjId() or COMMON_CONSTS.INVALID_OBJID
	AtkCache.range = range or 1
	AtkCache.offset_range = 0
	AtkCache.monster_range = 0
	if target_obj and target_obj:IsMonster() and self.monster_cfg[target_obj:GetMonsterId()] then
		AtkCache.monster_range = self.monster_cfg[target_obj:GetMonsterId()].hurt_range
		if AtkCache.monster_range > 3 then
			AtkCache.monster_range = AtkCache.monster_range - 1
			AtkCache.offset_range = 1
		end
	end

	if AtkCache.range > 3 then
		AtkCache.range = AtkCache.range - 1
		AtkCache.offset_range = 1
	end
	-- if skill_id == 121 then
	-- 	AtkCache.range = 5
	-- end
	if Scene.Instance:GetMainRole():IsFightState() then
		MountCtrl.Instance:SendGoonMountReq(0)
	end
	GuajiCtrl.SetMoveValid(false)
	MoveCache.task_id = 0

	GuajiCache.target_obj = target_obj
	GuajiCache.target_obj_id = AtkCache.target_obj_id
	return true
end

-- 跳跃操作
function FightCtrl:DoJump()
	Scene.SendMoveMode(MOVE_MODE.MOVE_MODE_JUMP)
end

function FightCtrl:BianShenView(protocol)
	local scene_obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsRole() then
		scene_obj:SetAttr("bianshen_param", protocol.show_image)
		local part = scene_obj:GetDrawObj():GetRoot()
		if protocol.show_image == 0 then
			part.transform.localScale = Vector3(1, 1, 1)
		elseif protocol.show_image == 7 or protocol.show_image == 8 then
			part.transform.localScale = Vector3(protocol.model_size / 100, protocol.model_size / 100, protocol.model_size / 100)
		end
	end
end

function FightCtrl:InvisibleView(protocol)
	local scene_obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsRole() and not scene_obj:IsMainRole() then
		scene_obj:ChangeModelTransparent(protocol.is_invisible)
	end
end

function FightCtrl:CalculateHurt(total_hurt)
	if total_hurt > -4 then
		return total_hurt, 0
	end
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.use_xiannv_id == nil or vo.use_xiannv_id <= -1 then
		return total_hurt, 0
	end
	local rand = (math.random() - 0.5) * 2
	if rand ~= 0 then
		rand = rand / 10
	end
	local nvshen_hurt = math.floor(vo.base_fujia_shanghai * 0.5 * (1 + rand) * -1)
	local role_hurt = total_hurt - nvshen_hurt
	if role_hurt >= 0 or nvshen_hurt / role_hurt > 0.4 then
		nvshen_hurt = math.floor(total_hurt * 0.3)
		role_hurt = total_hurt - nvshen_hurt
	end
	return role_hurt, nvshen_hurt
end