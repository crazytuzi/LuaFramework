
require("scripts/game/fight/fight_def")
require("scripts/game/fight/fight_data")
require("scripts/game/fight/fight_text")

-- 战斗
FightCtrl = FightCtrl or BaseClass(BaseController)

function FightCtrl:__init()
	if FightCtrl.Instance ~= nil then
		ErrorLog("[FightCtrl] attempt to create singleton twice!")
		return
	end
	FightCtrl.Instance = self

	self.data = FightData.New()

	self.max_effect_total_num = 48 					-- 同屏总特效最大数量
	self.max_effect_same_num = 48 					-- 同屏相同特效最大数量
	self.main_role_hited_effect_list = {}

	self:RegisterAllProtocols()
	self:RegisterAllEvents()
end

function FightCtrl:__delete()
	FightCtrl.Instance = nil

	self.data:DeleteMe()
	self.data = nil
end

function FightCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCPerformSkill, "OnPerformSkill")
	self:RegisterProtocol(SCEntityBeHit, "OnEntityBeHit")
	self:RegisterProtocol(SCChangeDir, "OnChangeDir")
	self:RegisterProtocol(SCNearAtk, "OnNearAtk")
	self:RegisterProtocol(SCChongFeng, "OnChongFeng")
	self:RegisterProtocol(SCChangeDoubleHitCD, "OnChangeDoubleHitCD")
	self:RegisterProtocol(SCPetChangeAtkType, "OnPetChangeAtkType")
	self:RegisterProtocol(SCHitFly, "OnHitFly")
	self:RegisterProtocol(SCFindTargetSound, "OnFindTargetSound")
	self:RegisterProtocol(SCDogDie, "OnDogDie")
	self:RegisterProtocol(SCChongFeng2, "OnChongFeng2")
	self:RegisterProtocol(SCSuckBloodAtk, "OnSuckBloodAtk")
	self:RegisterProtocol(SCAddBuff, "OnAddBuff")
	self:RegisterProtocol(SCDelBuff, "OnDelBuff")
	self:RegisterProtocol(SCUpdateBuff, "OnUpdateBuff")
	self:RegisterProtocol(SCDelBuffByType, "OnDelBuffByType")
	self:RegisterProtocol(SCAttackOutput, "OnAttackOutput")
	self:RegisterProtocol(SCTriggerSpecialAttr, "OnTriggerSpecialAttr")
end

function FightCtrl:RegisterAllEvents()
end

function FightCtrl:OnPerformSkill(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsCharacter() then
		if scene_obj:IsMainRole() then
			scene_obj:ServerOnMainRolePerformSkill(protocol)
		else
			if protocol.dir >= GameMath.DirUp and protocol.dir <= GameMath.DirUpLeft then
				scene_obj:SetDirNumber(protocol.dir)
			else
				Log("OnPerformSkill dir error", protocol.dir)
			end
			scene_obj:DoAttack(protocol.skill_id, protocol.skill_level, protocol.sound_id)
		end
	end
end

function FightCtrl:OnEntityBeHit(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	local atker_obj = Scene.Instance:GetObjectByObjId(protocol.atker_obj_id)
	local is_pet = false
	if nil ~= atker_obj then
		local type = atker_obj:GetVo().entity_type
		is_pet = (type == EntityType.Hero)
	end
	if nil ~= scene_obj then
		local x, y = scene_obj:GetRealPos()
		FightTextMgr:OnChangeHp(x, y + scene_obj:GetFixedHeight(), protocol.hurt_value, protocol.atk_type, protocol.obj_id == Scene.Instance:GetMainRole():GetObjId(), is_pet)
		scene_obj:OnBeHit(protocol.atker_obj_id)

		if protocol.obj_id == Scene.Instance:GetMainRole():GetObjId() and SettingData.Instance:GetOneGuajiSetting(GUAJI_SETTING_TYPE.AUTO_ATTACT_BACK) then
			local atker_scene_obj = Scene.Instance:GetObjectByObjId(protocol.atker_obj_id)
			if atker_scene_obj then
				GlobalEventSystem:Fire(ObjectEventType.BE_SELECT, atker_scene_obj, "scene")
			end
		end
		ExperimentCtrl.Instance:OnHurtChange(protocol.hurt_value) -- 试炼boss伤害计算

		local cfg = BabelTowerFubenConfig and BabelTowerFubenConfig.layerlist or {}
		local cur_cfg = cfg[1] or {}
		local scene_id = Scene.Instance:GetSceneId()
		if scene_id == cur_cfg.sceneid then
			BabelCtrl.Instance:OnHurtChange(protocol.hurt_value)
		end
	end
end

function FightCtrl:OnChangeDir(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil ~= scene_obj then
		if protocol.dir >= GameMath.DirUp and protocol.dir <= GameMath.DirUpLeft then
			if scene_obj:GetDirNumber() ~= protocol.dir then
				scene_obj:SetDirNumber(protocol.dir)
				if scene_obj:IsStand() or scene_obj:IsWait() then
					scene_obj:RefreshAnimation()
				end
			end
		elseif scene_obj:IsCharacter() then
			scene_obj:ClearAction()
		end
	end
end

function FightCtrl:OnNearAtk(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsCharacter() then
		if protocol.dir >= GameMath.DirUp and protocol.dir <= GameMath.DirUpLeft then
			scene_obj:SetDirNumber(protocol.dir)
		else
			Log("OnNearAtk dir error", protocol.dir)
		end
		if scene_obj:IsMainRole() then
			scene_obj:ServerOnMainRolePerformSkill(protocol)
		else
			scene_obj:DoAttack(0, protocol.skill_level, protocol.sound_id)
		end
	end
end

function FightCtrl:OnChongFeng(protocol)
	Log("======OnChongFeng")
end

function FightCtrl:OnChangeDoubleHitCD(protocol)
	Log("======OnChangeDoubleHitCD")
end

function FightCtrl:OnPetChangeAtkType(protocol)
	Log("======OnPetChangeAtkType")
end

function FightCtrl:OnHitFly(protocol)
	Log("======OnHitFly")
end

function FightCtrl:OnFindTargetSound(protocol)
	AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(protocol.sound_id), AudioInterval.FindTarget)
end

function FightCtrl:OnDogDie(protocol)
	Scene.Instance:GetMainRole():SetAttr("pet_obj_id", 0)
end

function FightCtrl:OnChongFeng2(protocol)
	Log("======OnChongFeng2")
end

function FightCtrl:OnSuckBloodAtk(protocol)
	Log("======OnSuckBloodAtk")
end

function FightCtrl:OnAddBuff(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsCharacter() then
		scene_obj:AddBuff(protocol)
		GlobalEventSystem:Fire(ObjectEventType.OBJ_BUFF_CHANGE, scene_obj)
	end
end

function FightCtrl:OnDelBuff(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsCharacter() then
		scene_obj:DelBuff(protocol.buff_type, protocol.buff_group)
		GlobalEventSystem:Fire(ObjectEventType.OBJ_BUFF_CHANGE, scene_obj)
	end
end

function FightCtrl:OnDelBuffByType(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsCharacter() then
		scene_obj:DelBuffByType(protocol.buff_type)
		GlobalEventSystem:Fire(ObjectEventType.OBJ_BUFF_CHANGE, scene_obj)
	end
end

function FightCtrl:OnUpdateBuff(protocol)
	local scene_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil ~= scene_obj and scene_obj:IsCharacter() then
		scene_obj:UpdateBuff(protocol)
		GlobalEventSystem:Fire(ObjectEventType.OBJ_BUFF_CHANGE, scene_obj)
	end
end

function FightCtrl:OnAttackOutput(protocol)
end

-- 命中特殊属性技能
function FightCtrl:OnTriggerSpecialAttr(protocol)
	Scene.Instance:GetMainRole():FloatingAttrTxt(protocol.attr_type)
end

function FightCtrl.SendPerformSkillReq(skill_id, obj_id, x, y, dir)
	local protocol = ProtocolPool.Instance:GetProtocol(CSUseSkillReq)
	protocol.skill_id = skill_id
	protocol.obj_id = obj_id
	protocol.pos_x = x
	protocol.pos_y = y
	protocol.dir = dir
	protocol:EncodeAndSend()

	-- GlobalData.last_action_time = Status.NowTime

	-- SkillData.Instance:OnUseSkill(skill_id)
end

function FightCtrl.SendNearAttackReq(obj_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSNearAttackReq)
	protocol.obj_id = obj_id
	protocol:EncodeAndSend()

	-- GlobalData.last_action_time = Status.NowTime
end

function FightCtrl.NextAttackTime()
	return math.max(GlobalData.last_action_time + RoleData.Instance:GetAtkSpeed(), SkillData.Instance:GetGlobalCD())
end

-- 攻击操作
function FightCtrl:DoAtkOperate(skill_id, x, y, target_obj, dir, range, first_atk)
end

function FightCtrl:ClearOperateCache()
end

----------------------------------------------------
-- 战斗特效个数控制
----------------------------------------------------
function FightCtrl:GetIsCanPlayEffect(effect_id, is_relate_main_role, is_hit_effect_in_mainrole)
	if nil == effect_id then return false end

	if is_relate_main_role then
		if not is_hit_effect_in_mainrole then
			return true
		else
			if self.main_role_hited_effect_list[effect_id] == nil then
				self.main_role_hited_effect_list[effect_id] = self.now_time
				return true
			end
			if self.now_time - self.main_role_hited_effect_list[effect_id] > 0.4 then --防止叠加在主角身上同样的受击特效过多
				self.main_role_hited_effect_list[effect_id] = self.now_time
				return true
			end
			return false
		end
	end 				

	local total_count, same_count = Scene.Instance:GetEffectCount(effect_id)
	if total_count >= self.max_effect_total_num or same_count >= self.max_effect_same_num then
		return false
	end

	return true
end
