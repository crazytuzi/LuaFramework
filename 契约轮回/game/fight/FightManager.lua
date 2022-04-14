-- 
-- @Author: LaoY
-- @Date:   2018-07-26 17:48:35
-- 
FightManager = FightManager or class("FightManager",BaseManager)
local this = FightManager


-- 战斗调试
FightManager.Debug = true
if not AppConfig.Debug then
	FightManager.Debug = false
end

FightManager.FightMessageList = {}
FightManager.FightMessageIndex = 0

FightManager.FightState = {
	Null 	= BitState.State[0],
	Normal 	= BitState.State[1],
	PK 		= BitState.State[2],
}

function FightManager:ctor()
	FightManager.Instance = self
	self:Reset()

	-- 攻击序列
	-- 先移动再攻击等放入攻击序列
	self.attack_sequence_list = list()
	self.fightdata_list = {}

	--主角的受伤的飘字要按顺序飘
	self.main_role_be_hurt_damage = list()
	self.last_main_role_hurt_text_time = os.clock()
	self.max_main_role_hurt_text_count = DamageConfig.MainRoleHurtConfig.MaxCount
	self.main_role_hurt_text_cd_ms = DamageConfig.MainRoleHurtConfig.CD * 1000

	self.main_role_add_exp_list = list()
	self.last_main_role_add_exp_time = os.clock()
	-- self.max_main_role_add_exp_count = DamageConfig.MainRoleHurtConfig.MaxCount
	self.main_role_add_exp_cd_ms = DamageConfig.MainRoleHurtConfig.ExpCd * 1000


	self.fight_state = BitState()

	LateUpdateBeat:Add(self.Update,self)

	--攻击模式
	self.pkmode = nil
	
	self:AddEvent()
end

function FightManager:Reset()
	if self.attack_sequence_list then
		self.attack_sequence_list:clear()
	end
	self.fightdata_list = {}

	if self.main_role_be_hurt_damage then
		self.main_role_be_hurt_damage:clear()
	end

	if self.main_role_add_exp_list then
		self.main_role_add_exp_list:clear()
	end

	self.object_wait_attack_pre = nil

	self.object_wait_attack = {}
	self.client_lock_target_id = nil
end

function FightManager.GetInstance()
	if FightManager.Instance == nil then
		FightManager()
	end
	return FightManager.Instance
end

function FightManager:AddEvent()
	--切换场景开始
	local function call_back()
		FightManager:GetInstance():Reset()
	end
	GlobalEvent:AddListener(EventName.ChangeSceneStart, call_back)
end

--[[
	@author LaoY
	@des	主角释放技能
	@param1 skill_vo table 技能信息
	@return bool 是否能释放技能
--]]
function FightManager:MainRoleReleaseSkill(skill_vo,is_auto_fight)
	if not skill_vo then
		return false
	end
	local main_role = SceneManager:GetInstance():GetMainRole()
	if not main_role then
		return false
	end
	if self:PlayPreSKill(main_role,skill_vo,nil,is_auto_fight) then
		return true
	end
	return false
end

--[[
	@author LaoY
	@des	是否能使用技能
	@param1 param1
	@return number
--]]
function FightManager:IsCanSwitchSkill(sceneobject,skill_vo)
	sceneobject = sceneobject or SceneManager:GetInstance():GetMainRole()
	if not sceneobject then
		return false
	end
	if skill_vo and skill_vo.action_name == "empty" then
		return true
	end
	-- 下坐骑可以直接打
	if sceneobject.IsRideDown and sceneobject.IsRideDown(sceneobject) then
		return true
	end
	-- Yzprint('--LaoY FightManager.lua,line 114--',3)
	return sceneobject:IsCanSwitchToAttack(skill_vo)
end

--[[
	@author LaoY
	@des	客户端预播技能
	@param1 main_role
	@param2 skill_vo
--]]
function FightManager:PlayPreSKill(main_role,skill_vo,is_ignore_time,is_auto_fight)
	main_role = main_role or SceneManager:GetInstance():GetMainRole()
	if not main_role or main_role.is_death then
		return false
	end

	-- 攻击距离不够导致寻路或者冲刺中 不接受攻击指令
	if self.attack_operate_time and Time.time - self.attack_operate_time < 0.8 then
		return
	end

	-- if skill_vo.skill_id == 709011 then
	-- 	Yzprint('--LaoY FightManager.lua,line 150--',data)
	-- end

	local release_control = SkillManager:GetInstance():IsReleaseDebuffSkill(skill_vo.skill_id)
	local bo,buff_effect_type = main_role.object_info:IsCanAttackByBuff()
	if not bo and not release_control then
		main_role:AttackDebuffTip(buff_effect_type)
		return
	end

	local is_pet_skill = SkillManager:GetInstance():IsPetSkill(skill_vo.skill_id)
	if not is_ignore_time and not self:IsCanSwitchSkill(main_role,skill_vo) and not is_pet_skill then
		self:AddWaitAttackPre(main_role,skill_vo)
		return false
	end

	local skill_cf = SkillManager:GetInstance():GetSkillConfig(skill_vo.skill_id)
	local aim_self = false
	if skill_cf then
		aim_self = skill_cf.aim == enum.SKILL_AIM.SKILL_AIM_SELF
	end

	local target
	local pos = main_role:GetPosition()
	local function callback()
		-- self:PlayPreSKill(main_role,skill_vo)
		self.attack_operate_time = 0
		GlobalEvent:Brocast(MainEvent.ReleaseSkill,skill_vo.skill_id)
	end
	local attack_dis = SkillManager:GetInstance():GetSkillAttackDistance(skill_vo.skill_id)
	Yzprint('--LaoY FightManager.lua,line 157--',attack_dis)
	local skill_dis = attack_dis
	local attack_rush_dis = SceneConstant.AttactDis + SceneConstant.RushDis
	local attack_rush_min_dis = SceneConstant.AttactDis + SceneConstant.RushMinDis

	if self.client_lock_target_id then
		local object = SceneManager:GetInstance():GetObject(self.client_lock_target_id)
    	local scene_type = SceneConfigManager:GetInstance():GetSceneType()
		local is_city_or_feild = scene_type == SceneConstant.SceneType.Feild or scene_type == SceneConstant.SceneType.City
		if object and object:IsCanBeAttack() and (is_pet_skill or not is_city_or_feild or MapLayer:GetInstance():IsInScreen(object:GetPosition())) then
			target = object
		end
	end

	if is_pet_skill and not aim_self and not target then
		return
	end

	if not target or target:IsDeath() or not target:IsCanBeAttack() then
		target = main_role:GetHateObject()
	end

	-- if not target or target:IsDeath() then
	-- 	target = self:GetPreSkillTarget(main_role,skill_vo)
	-- end

	local rush_pos
	if not target or target:IsDeath() then
		-- local _rush_pos,_rush_target = SkillManager:GetInstance():GetSkillRushPos(main_role,skill_vo)
		-- if _rush_pos then
		-- 	rush_pos = _rush_pos
		-- 	target = _rush_target 
		-- end
		local function check_func(object)
			return object:IsCanBeAttack()
		end
		target = SceneManager:GetInstance():GetCreepInScreen(nil,enum.CREEP_KIND.CREEP_KIND_MONSTER,check_func)
	end
	if target and target.__cname ~= "Monster" and main_role:IsInSafe() then
		target = nil
	end

	-- 世界boss场景和幻之岛 没有疲劳不攻击boss
	if target and target.__cname == "Monster" and target:IsBoss() then
		local sceneId = SceneManager:GetInstance():GetSceneId()
		local config = Config.db_scene[sceneId]
		if config.type == enum.SCENE_TYPE.SCENE_TYPE_BOSS then
		-- if (config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WORLD or config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_BEAST) then
			if DungeonModel:GetInstance():IsSemptytired(config.stype,sceneId) then
				if not is_auto_fight then
					self:FightBossInTired(config.stype)
				end
				return
			end
		end
	end

	if target and (not aim_self or release_control) and not is_pet_skill then
		self:LockFightTarget(target.object_id)
		local target_pos = target:GetPosition()
		target_pos = {x = target_pos.x,y = target_pos.y}
		if target.fountain_action then
			Yzprint('--LaoY FightManager.lua,line 196--',target.object_info.__cname)
			target_pos = target.object_info:GetFissionPos()
			Yzprint('--LaoY FightManager.lua,line 188--',dis,target.object_id,target.object_info.name,target_pos.x,target_pos.y)
		end
		local dis = Vector2.Distance(pos,target_pos)
		local radius = target:GetVolume() * 0.5
		attack_dis = SceneConstant.AttactDis + radius
		if attack_dis > skill_dis + radius then
			attack_dis = skill_dis + radius
		end
		attack_rush_min_dis = attack_rush_min_dis + radius
		attack_rush_dis = attack_rush_dis + radius
		local err_dir = 20
		Yzprint('--LaoY FightManager.lua,line 208--',dis,radius,target.object_id,target.object_info.name,target_pos.x,target_pos.y)
		self.attack_operate_time = Time.time
		-- if SceneManager:GetInstance():GetSceneId() == 30372 or 
		-- 			SceneManager:GetInstance():GetSceneId() == 30373 then
		-- 			OperationManager:GetInstance():LockObject(nil,pos,target_pos,callback,attack_dis - err_dir,target)
		-- else
		if dis > attack_rush_dis then
			OperationManager:GetInstance():LockObject(nil,pos,target_pos,callback,attack_rush_dis - err_dir,target)
			return false
		elseif dis <= attack_rush_dis and dis > attack_rush_min_dis then
			if not rush_pos then
				-- 朝目标多冲刺一段距离，不要只冲刺到临界值
				-- rush_pos = GetDirDistancePostion(pos,target_pos,SceneConstant.AttactDis * 0.5 + radius)
				rush_pos = GetDirDistancePostion(target_pos,pos,SceneConstant.AttactDis * 0.5 + radius)
			end
			if OperationManager:GetInstance():HasBlock(pos,rush_pos) then
				OperationManager:GetInstance():TryMoveToPosition(nil,pos,target_pos,callback,attack_dis - err_dir)
			else
				if SceneManager:GetInstance():GetSceneId() == 30372 or 
					SceneManager:GetInstance():GetSceneId() == 30373 then
					OperationManager:GetInstance():LockObject(nil,pos,target_pos,callback,attack_dis - err_dir,target)
				else
					main_role:PlayRush(rush_pos,callback)
				end
			end
			return false
		elseif dis <= attack_rush_min_dis and (dis > attack_dis) then
			-- OperationManager:GetInstance():TryMoveToPosition(nil,pos,target_pos,callback,attack_dis - err_dir)
			OperationManager:GetInstance():LockObject(nil,pos,target_pos,callback,attack_dis - err_dir,target)
			return false

		-- 普通怪 在怪物体积内不需要走出来再打
		elseif dis <= radius and (target.__cname == "Monster" and target.config.rarity ~= enum.CREEP_RARITY.CREEP_RARITY_COMM) then
			local move_pos = GetDirDistancePostion(target_pos,pos,radius + 21)
			if not OperationManager:GetInstance():IsBlock(move_pos.x,move_pos.y) then
				OperationManager:GetInstance():TryMoveToPosition(nil,pos,move_pos,callback,nil,0,0)
				return false
			end
		else
			self.attack_operate_time = -1
		end
	end

	-- 返回特殊值判断 自动战斗状态 如果有新的技能释放没有目标 要切回待机状态
	
	-- if AutoFightManager:GetInstance():GetAutoFightState() and not target then
	-- 	return 1
	-- end

	if aim_self then
		target = main_role
	end

	Yzprint('--LaoY FightManager.lua,line 229--',is_pet_skill,target)
	local fightdata = FightData()
	fightdata:InitPreData(main_role,skill_vo,target)
	
	fightdata.seq = SkillManager:GetInstance():GetSkillSeq(skill_vo.skill_id)
	fightdata.skill_key = skill_vo.skill_id .. "_" .. fightdata.seq

	self:PlaySkill(main_role,fightdata)
	self:PlayPreSKillSuccess(main_role,fightdata,target)
	return true
end

local lastTimeFightBossInTired = 0
function FightManager:FightBossInTired(stype)
	if Time.time - lastTimeFightBossInTired < 1.0 then
		return
	end
	lastTimeFightBossInTired = Time.time

	if stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WORLD then
		Notify.ShowText("Fatigue used up, unable to attack world boss")        
	elseif stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_BEAST then
		Notify.ShowText("Fatigue used up, unable to attack  mirage island boss")        
    elseif stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_HOME then
		Notify.ShowText("Stamina used up, unable to attack boss home")
    end
end

--[[
	@author LaoY
	@des	获取客户端预播技能目标
	@param1 object
	@param2 skill_vo
--]]
function FightManager:GetPreSkillTarget(object,skill_vo)
	return SkillManager:GetInstance():GetClientTarget(object,skill_vo)
end

function FightManager:IsCanAttackLockTarget(id,skill_vo)
	return SkillManager:GetInstance():IsCanAttackLockTarget(id,skill_vo)
end

function FightManager:PlayPreSKillSuccess(sceneobject,fightdata,target)
	local skill_id = fightdata.skill_vo.skill_id
	SkillManager:GetInstance():ReleaseSkillSuccess(skill_id)
	local unit = 0
	if SkillManager:GetInstance():IsPetSkill(skill_id) then
		unit = 1
	end
	-- local rotate = fightdata.effect_info.rotate
	local rotate = fightdata.rotate
	local rotate_y = 0
	if type(rotate) == "table" then
		rotate_y = rotate.y
	else
		if AppConfig.Debug then
			Yzprint('--LaoY FightManager.lua,line 276--',data)
			traceback()
			logError("客户端打印：该技能没有角度")
		end
	end
	local defid = target and target.object_id or 0
	if target then
		self:LockFightTarget(target.object_id)
	end
	-- 强制同步一次坐标
	local main_role = SceneManager:GetInstance():GetMainRole()
	if main_role then
		main_role:TrySynchronousPosition(true)
	end
	if target and target.__cname == "Monster" and target:IsGM() then
		FightController:GetInstance():RequestNewBie(defid,target.object_info.id,skill_id,rotate_y,fightdata.seq)
	else
		FightController:GetInstance():RequestFightAttack(unit,skill_id,rotate_y,defid,fightdata.seq)
	end
	-- Notify.ShowText(fightdata.seq)
	self.last_fightdata = fightdata
end

--场景清除怪物
function FightManager:RemoveObject(id)
	-- 清除数据要 检查是否删除死亡怪物
	self:ClearObjectDamage(id)
	self:UnLockFightTarget(id)
end

function FightManager:ClearObjectDamage(object_id)
	-- 清除当前的
	local skill_list = self.fightdata_list[object_id]
	if skill_list then
		for skill_id,fightdata in pairs(skill_list) do
			if fightdata.dmgs1 then
				self:ClearDamageInfo(fightdata.dmgs1,fightdata.attack,fightdata.message_time)
			end
		end
	end
	self.fightdata_list[object_id] = nil

	--清除队列数据
	if not table.isempty(self.object_wait_attack[object_id]) then
		local tab = self.object_wait_attack[object_id]
		local length = #tab
		for i=1,length do
			local info = tab[i]
			local fightdata = info.fightdata
			if fightdata.dmgs1 then
				self:ClearDamageInfo(fightdata.dmgs1,fightdata.attack,fightdata.message_time)
			end
		end
	end
	self.object_wait_attack[object_id] = nil
end

function FightManager:ClearDamageInfo(dmgs,attack,message_time)
	for k,damage in pairs(dmgs) do
		local object = SceneManager:GetInstance():GetObject(damage.uid)
		if object then
			object:SetHp(damage.hp,message_time)
		end
		if damage.hp <= 0 then
			if object then
				if not object.object_info.last_set_hp_time or message_time >= object.object_info.last_set_hp_time then
					object:PlayDeath(attack)
				end
			else
				local info = SceneManager:GetInstance():GetObjectInfo(damage.uid)
				if info then
					if not info.last_set_hp_time or message_time >= info.last_set_hp_time then
						SceneManager:GetInstance():RemoveObject(damage.uid)
					-- else
					-- 	if AppConfig.Debug then
					-- 		logError("info.last_set_hp_time = ",info.last_set_hp_time,message_time)
					-- 	end						
					end
				end
			end
		end
	end
end

function FightManager:LockFightTarget(id)
	if id == RoleInfoModel:GetInstance():GetMainRoleId() then
		return
	end
	if self.client_lock_target_id and self.client_lock_target_id == id then
		return
	end
	if self.client_lock_target_id then
		local target = SceneManager:GetInstance():GetObject(self.client_lock_target_id)
		if target then
			target:BeLock(false)
		end
	end
	self.client_lock_target_id = id
	local target = SceneManager:GetInstance():GetObject(id)
	if target then
		target:BeLock(true)
	end
end

function FightManager:UnLockFightTarget(id)
	id = id or self.client_lock_target_id
	if self.client_lock_target_id and self.client_lock_target_id == id then
		 local target = SceneManager:GetInstance():GetObject(self.client_lock_target_id)
		 if target then
		 	target:BeLock(false)
		 end
		self.client_lock_target_id = nil
	end
end

-- 模式改变，需要判断当前选择的人能不能攻击
function FightManager:CheckLockFightTarget()
	if not self.client_lock_target_id then
		return
	end
	local target = SceneManager:GetInstance():GetObject(self.client_lock_target_id)
	if target and target.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_ROLE then
		if not target:IsCanBeAttack() then
			self:UnLockFightTarget(self.client_lock_target_id)
			-- SceneManager:GetInstance():CleanRoleLockList()
		end
	end
end

--[[
	@author LaoY
	@des	
	@param1 sceneobject SceneObject派生类	施放技能的本体
	@param1 fightdata 	table				攻击信息
	@param1 target_list table				攻击对象
--]]
function FightManager:PlaySkill(sceneobject,fightdata)
	if not sceneobject or not fightdata or not fightdata.skill_vo then
		return false
	end
	local skill_id = fightdata.skill_vo.skill_id

	local pet
	local is_pet_skill = SkillManager:GetInstance():IsPetSkill(skill_id)
	if is_pet_skill then
		pet = sceneobject:GetDependObject(enum.ACTOR_TYPE.ACTOR_TYPE_PET)
	end

	if pet then
		if not pet:PlayAttack(fightdata.skill_vo) then
			--return
		end
	else
		if not sceneobject:PlayAttack(fightdata.skill_vo) then
			--return
		end
	end

	if sceneobject.__cname == "Role" and fightdata.message and fightdata.message.coord then
		local coord = fightdata.message.coord
		if coord.x ~= 0 and coord.y ~= 0 then
			sceneobject:SetPosition(coord.x,coord.y)
			fightdata:UpdateRotate()
		end
	end

	if pet then
		if pet:GetRotate().y ~= fightdata.rotate.y then
			pet:SetRotateY(fightdata.rotate.y)
		end
	elseif sceneobject:GetRotate().y ~= fightdata.rotate.y then
		sceneobject:SetRotateY(fightdata.rotate.y)
	end

	self.fightdata_list[sceneobject.object_id] = self.fightdata_list[sceneobject.object_id] or {}
	self.fightdata_list[sceneobject.object_id][fightdata.skill_key] = fightdata

	local target = fightdata:GetTarget() or (self.client_lock_target_id and SceneManager:GetInstance():GetObject(self.client_lock_target_id))
	local effect_list = fightdata.skill_vo.effect
	-- 主角或者设置可以看到别人特效才可以显示技能特效
	local is_main_role = sceneobject == SceneManager:GetInstance():GetMainRole()
	if effect_list and (is_main_role or EffectManager:GetInstance():IsCanShowOtherEffect()) then
		local tab
		local effect_info = fightdata.effect_info
		for i=1,#effect_list do
			local vo = effect_list[i]

			-- 弹道类型，直接朝着目标点放。多个弹道技能，回包再校准
			if vo.effect_type == FightConfig.EffectType.BallisticPos or vo.effect_type == FightConfig.EffectType.BallisticDir or
			vo.effect_type == FightConfig.EffectType.BallisticTrack or vo.effect_type == FightConfig.EffectType.BallisticMulPos then
			
			-- 受击方的特效也先不处理。回包再处理
			-- elseif vo.effect_type == FightConfig.EffectType.Hit then

			elseif vo.effect_type ~= FightConfig.EffectType.Hurt then
				self:PlayEffect(pet or sceneobject,target,effect_info,vo)
			end
		end
	end

	if sceneobject == SceneManager:GetInstance():GetMainRole() then
		local is_monster_visible = SceneManager:GetInstance():GetObjectBitStateByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP)
		if not is_monster_visible then
			return true
		end
		local camera_infos = fightdata.skill_vo.camera_infos
		if camera_infos then
			for k,vo in pairs(camera_infos) do
				MapManager.Instance:AddShakeInfo(vo.shake_start_time, vo.shake_type, vo.shake_lase_time, vo.shake_max_range, vo.shake_angle, vo.start_angle)
			end
		end
	end
	return true
end

function FightManager:PlayEffect(attack,target,effect_info,vo,pass_time)
	if not effect_info then
		return
	end
	local is_monster_visible = SceneManager:GetInstance():GetObjectBitStateByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP)
	if not is_monster_visible then
		return
	end

	local start_time = vo.start_time
	if start_time and pass_time then
		start_time = start_time - pass_time
		start_time = start_time < 0 and 0 or start_time
	end
	local pos = effect_info.pos or {x=0,y=0}
	local tab = {
		target = attack,
		skill_id = skill_id,
		pos = Vector3(pos.x,pos.y,pos.z),
		rotate = effect_info.rotate,
		scale = 1,
		speed = 1,
		play_count = vo.play_count,
		start_time = start_time,
		skill_effect_type = vo.effect_type,
		skill_vo = vo,
		play_time = vo.play_time,
	}
	local parent = nil
	local scene_effect_type = EffectManager.SceneEffectType.Pos
	local effect_cls = ScenePositionEffect
	local is_hit_target_effect = vo.effect_type == FightConfig.EffectType.Hit or vo.effect_type == FightConfig.EffectType.Hit2Pos
	if vo.effect_type == FightConfig.EffectType.Attack or vo.effect_type == FightConfig.EffectType.Attack2Pos or (is_hit_target_effect and not target) then
		local bone_name = SceneConstant.EffectBoneNode[vo.root_type]

		if bone_name ~= SceneConstant.BoneNode.Root or (attack.__cname == "Role" or attack.__cname == "MainRole") then
			parent = attack:GetBoneNode(bone_name) or attack.transform
		else
			parent = attack.transform
		end

		scene_effect_type = EffectManager.SceneEffectType.Target
		tab.pos.x = 0
		tab.pos.y = 0
		tab.pos.z = 0
		if (is_hit_target_effect and not target) then
			if not vo.offset then
				if AppConfig.Debug then
					logError(vo.skill_id , " 该技能配置错误，没有 offset")
				else
					DebugLog(vo.skill_id , " 该技能配置错误，没有 offset")
				end
			end
			tab.skill_effect_type = FightConfig.EffectType.Attack2Pos
			local vec = Vector2(attack.direction.x,attack.direction.y)
			vec:Mul(vo.offset)
			tab.pos.x = tab.pos.x + vec.x
			tab.pos.y = tab.pos.y + vec.y
		end
		tab.rotate = nil
		effect_cls = SceneTargetEffect

		Yzprint('--LaoY FightManager.lua,line 531--',effect_info)
		Yzdump(effect_info,"effect_info")
	elseif vo.effect_type == FightConfig.EffectType.Pos then
		if vo.offset then
			local start_pos = tab.pos
			local vec = Vector2(attack.direction.x,attack.direction.y)
			vec:Mul(vo.offset)
			tab.pos = {x=start_pos.x+vec.x,y = start_pos.y+vec.y,z = start_pos.z}
			tab.pos.z = LayerManager:GetInstance():GetSceneObjectDepth(tab.pos.y) * SceneConstant.PixelsPerUnit
		end
		if vo.rotate_type == 2 then
			tab.rotate = nil
		end
	elseif vo.effect_type == FightConfig.EffectType.Hurt then
		if not target or not EffectManager:GetInstance():IsCanAddBeHitEffect() then
			return
		end
		local width = target:GetBodyWidth()/SceneConstant.PixelsPerUnit
		local height = target:GetBodyHeight()/SceneConstant.PixelsPerUnit
		-- target:SetTargetEffect(vo.name,false,nil,{x=0,y=height * 0.5,z=0})
		-- return 
		-- effect_female_attack_hurt
		parent = target.effect_parent
		effect_cls = SceneTargetEffect
		scene_effect_type = EffectManager.SceneEffectType.Target
	elseif vo.effect_type == FightConfig.EffectType.BallisticPos or vo.effect_type == FightConfig.EffectType.BallisticDir or
		vo.effect_type == FightConfig.EffectType.BallisticTrack or vo.effect_type == FightConfig.EffectType.BallisticMulPos then
		local bone_name = SceneConstant.EffectBoneNode[vo.root_type]
		parent = attack:GetBoneNode(bone_name) or attack.transform
		scene_effect_type = EffectManager.SceneEffectType.Shoot
		if vo.offset then
			local start_pos = attack:GetPosition()
			local height = attack:GetBodyHeight()
			local vec = Vector2(attack.direction.x,attack.direction.y)
			vec:Mul(vo.offset)
			tab.to_pos = {x=start_pos.x+vec.x,y = start_pos.y+vec.y + height * 0.5,z = start_pos.z}
			tab.to_pos.z = LayerManager:GetInstance():GetSceneObjectDepth(tab.to_pos.y) * SceneConstant.PixelsPerUnit
		end
		tab.rotate = nil

		effect_cls = SceneShootEffect
	elseif is_hit_target_effect then
		local bone_name = SceneConstant.EffectBoneNode[vo.root_type]
		parent = target:GetBoneNode(bone_name) or target.transform
		scene_effect_type = EffectManager.SceneEffectType.Target

		tab.pos.x = 0
		tab.pos.y = 0
		tab.pos.z = 0
		tab.rotate = nil
		effect_cls = SceneTargetEffect
		tab.target = target
	end
	if effect_cls.__cname == "SceneTargetEffect" and not parent then
		return
	end

	PoolManager:GetInstance():AddConfig(vo.name,vo.name,Constant.CacheRoleObject,0,false)
	local effect = effect_cls(parent,vo.name,scene_effect_type,tab.target)
	effect:SetConfig(tab)
end

function FightManager:AddWaitAttackPre(sceneobject,skill_vo)
	self.object_wait_attack_pre = {sceneobject = sceneobject,skill_vo = skill_vo , add_time= Time.time , is_main_role = true}
end

function FightManager:AddWaitAttack(sceneobject,fightdata,is_pre)
	if not sceneobject or sceneobject:IsDeath() then
		return
	end
	
	self.object_wait_attack[sceneobject.object_id] = self.object_wait_attack[sceneobject.object_id] or {}
	local info = {sceneobject = sceneobject,fightdata = fightdata , add_time= Time.time , is_main_role = sceneobject == SceneManager:GetInstance():GetMainRole()}
	table.insert(self.object_wait_attack[sceneobject.object_id],info)
	-- if not info then
	-- 	self.object_wait_attack[sceneobject.object_id] = info
	-- else
	-- 	info.fightdata = fightdata
	-- 	info.add_time = Time.time
	-- end
end

function FightManager:CheckWaitAttack(object_id)
	if table.isempty(self.object_wait_attack[object_id]) then
		local sceneobject = SceneManager:GetInstance():GetObject(object_id)
		if sceneobject and sceneobject.__cname == "MainRole" then
			local info = self.object_wait_attack_pre
			if not info or sceneobject:IsDeath() or (not sceneobject:IsAttacking() and not sceneobject:CheckExitCurAction()) then
				return false
			end
			local state = self:PlayPreSKill(info.sceneobject,info.skill_vo)
			self.object_wait_attack_pre = nil
			return state ~= 1
		end
		return
	end
	local info = table.remove(self.object_wait_attack[object_id],1)
	if not info or info.sceneobject:IsDeath() or (not info.sceneobject:IsAttacking() and not info.sceneobject:CheckExitCurAction()) then
		return false
	end
	self:PlaySkill(info.sceneobject,info.fightdata)
	return true
end

function FightManager:CheckWaitAttackCombo(object_id,skill_id)
	if table.isempty(self.object_wait_attack[object_id]) then
		local sceneobject = SceneManager:GetInstance():GetObject(object_id)
		if sceneobject.__cname == "MainRole" then
			local info = self.object_wait_attack_pre
			if not info or sceneobject:IsDeath() then
				return false
			end
			self:PlayPreSKill(info.sceneobject,info.skill_vo,true)
			self.object_wait_attack_pre = nil
			return true
		end
		return
	end

	local info = table.remove(self.object_wait_attack[object_id],1)
	if not info or info.sceneobject:IsDeath() then
		return false
	end
	self:PlaySkill(info.sceneobject,info.fightdata)
	return true
end

local DamageList = {}
function FightManager:ReceiveFightMessage(message)
	local sceneobject = SceneManager:GetInstance():GetObject(message.atkid)

	if FightManager.Debug then
		Yzprint('--LaoY FightManager.lua,line 649--',data)
		Yzdump(message,"message")
	end

	if not sceneobject then
		-- 没有攻击方，要把血量直接重置
		Yzprint('--LaoY FightManager.lua,line 651--',data)
		self:ClearDamageInfo(message.dmgs1,nil,message.message_time)
		return
	end
	
	-- if tonumber(message.skill) == 709011 then
	-- 	print("1111111111111")
	-- end
	
	local skill_key = message.skill .. "_" .. message.seq

	if AppConfig.Debug then
		if sceneobject.__cname == "MainRole" then
			Yzprint('--LaoY FightManager.lua,line 675--',skill_key,Time.time,NetManager.HandleMsg.len)
		end
	end

	if sceneobject.__cname == "Monster" then
		sceneobject:SetServerPosInfo(message.coord, SceneConstant.SynchronousType.Stop)
	end

	-- 如果已经有该技能在播放
	local fightdata = self.fightdata_list[message.atkid] and self.fightdata_list[message.atkid][skill_key]

	-- 已有该技能在播放，而且又伤害数据包，直接把数据包处理
	if fightdata then
		if FightManager.Debug then
			Yzprint('--LaoY FightManager.lua,line 805--',fightdata.dmgs1)
			dump(fightdata.dmgs1,"fightdata.dmgs1")
		end

		if fightdata.dmgs1 then
			self:ClearDamageInfo(fightdata.dmgs1,nil,fightdata.message_time)
			self.fightdata_list[message.atkid][skill_key] = nil
			fightdata = nil
		end
	end

	if FightManager.Debug then
		FightManager.FightMessageIndex = FightManager.FightMessageIndex + 1
		local index = FightManager.FightMessageIndex
		FightManager.FightMessageList[skill_key] = {message = message , time = Time.time , is_use = false,index = index,skill_key = skill_key}

		local bo = self:IsCanSwitchSkill(sceneobject,skill_vo)
		local object_info = {
			cur_state_name = sceneobject.cur_state_name,
			is_can_switch_skill = bo,
		}
		FightManager.FightMessageList[skill_key].object_info = object_info
	end

	if fightdata then
		-- if not table.isempty(fightdata.dmgs1) and (fightdata.attack.__cname == "MainRole" or fightdata.attack.__cname == "Role") and AppConfig.Debug then
		-- 	Notify.ShowText("伤害错误",message.skill)
		-- 	Yzprint('--LaoY FightManager.lua,line 448-- data=',message.skill)
		-- 	Yzprint('--LaoY FightManager.lua,line 449-- 11=',11)
		-- 	dump(fightdata.dmgs1,"tab")
		-- 	Yzprint('--LaoY FightManager.lua,line 451-- 22=',22)
		-- 	dump(message,"tab")
		-- end
		fightdata:InitResult(message)
	else
		-- sceneobject,fightdata,target_list
		local skill_vo = SkillManager:GetInstance():GetSkillVo(message.skill)
		if not skill_vo then
			if FightManager.Debug then
				logError("开发服打印 ：改技能没有配置表现效果：" .. message.skill)
			end
			self:ClearDamageInfo(message.dmgs1,nil,message.message_time)
			return
		end
		local fightdata = FightData()

		fightdata:InitData(sceneobject,skill_vo,message)
		fightdata.skill_key = skill_key

		if fightdata.attack and  fightdata.attack.__cname == "Role" then
			-- Notify.ShowText("收到技能" .. skill_key)
		end

		-- local bo = self:IsCanSwitchSkill(sceneobject,skill_vo)
		-- if sceneobject.__cname == "Role" and _g_role_rush and not bo then
		-- 	Notify.ShowText("222")
		-- end
		-- if sceneobject.__cname == "Role" then
		-- 	Yzprint('--LaoY FightManager.lua,line 426-- data=',data)
		-- end

		if FightManager.Debug then
			Yzprint('--LaoY FightManager.lua,line 867--',self:IsCanSwitchSkill(sceneobject,skill_vo),sceneobject.object_id,sceneobject.cur_state_name)
		end
		
		if self:IsCanSwitchSkill(sceneobject,skill_vo) then
			local bo = self:PlaySkill(sceneobject,fightdata)
			if FightManager.Debug then
				Yzprint('--LaoY FightManager.lua,line 873--',bo)
			end
		else
			-- if fightdata.attack and  fightdata.attack.__cname == "Role" then
			-- 	Yzprint('--LaoY FightManager.lua,line 652--',sceneobject.cur_state_name,skill_key,sceneobject:CheckExitCurAction())
			-- 	if sceneobject:IsAttacking() then
			-- 		-- _G_attack_test = true
			-- 		local cur_action = sceneobject.action_list[sceneobject.cur_state_name]
			-- 		Yzprint('--LaoY FightManager.lua,line 654--',cur_action.skill_vo,sceneobject:IsCanPlayNextAttack())
			-- 		Yzprint('--LaoY FightManager.lua,line 658--',cur_action.skill_vo and cur_action.skill_vo.skill_id,message.skill)
			-- 		Yzprint('--LaoY FightManager.lua,line 658--pass_time:',cur_action.pass_time)
			-- 		Yzprint('--LaoY FightManager.lua,line 661--fuse_time:',cur_action.skill_vo and cur_action.skill_vo.fuse_time)
			-- 	end
			-- 	Yzprint('--LaoY FightManager.lua,line 654--',sceneobject:IsCanInterruption(),sceneobject:IsRushing(),sceneobject:IsJumping())
			-- end
			Yzprint('--LaoY FightManager.lua,line 799--',data)
			self:AddWaitAttack(sceneobject,fightdata)
		end
	end

	if FightManager.Debug then
		Yzprint('--LaoY FightManager.lua,line 885--',self.fightdata_list[message.atkid] and self.fightdata_list[message.atkid][skill_key])

		if message.dmgs1 then
			local is_kill = false
			for k,v in pairs(message.dmgs1) do
				if v.hp == 0 then
					DamageList[skill_key] = fightdata
					break
				end
			end
		end
	end
end

function FightManager:DebugKillDamage(object_id)
	if not AppConfig.Debug then
		return
	end
	for k,fightdata in pairs(DamageList) do
		for _,dmg in pairs(fightdata.dmgs1) do
			if dmg.uid == object_id then
				self:DebugFightData(fightdata)
				break
			end
		end
	end
end

function FightManager:DebugFightData(fightdata)
	Yzprint('--DebugFightData==>',
		string.format("is_dctored = %s,is_play_hurt_text = %s,pass_time = %s",fightdata.is_dctored,fightdata.is_play_hurt_text,fightdata.pass_time))

	-- Yzdump(fightdata,"fightdata")
end

--[[
	@author LaoY
	@des	角色打断技能
	@param1 sceneobject SceneObject派生类	施放技能的本体
	@param2 skill_id 	技能ID
--]]
function FightManager:InterruptionSkill(object_id,skill_id)
	-- todo
end

function FightManager:RemoveFightData(object_id,skill_key)
	if not self.fightdata_list[object_id] then
		return
	end
	self.fightdata_list[object_id][skill_key] = nil
end

function FightManager:Clear()
	self.fightdata_list = {}
	self.object_wait_attack = {}
	self:UnLockFightTarget(self.client_lock_target_id)
end

--[[
	@author LaoY
	@des	采集
--]]
function FightManager:TryDoCollect(target_id)
	local pick_up_range = SceneConstant.PickUpDis
	local object = SceneManager:GetInstance():GetCreepByTypeId(target_id,pick_up_range)
	if not object then
		return false
	end
	local main_role = SceneManager:GetInstance():GetMainRole()
	if not main_role then
		return false
	end
	GlobalEvent:Brocast(FightEvent.ReqCollect,object.object_info.uid,1)
	-- self:DoCollect(main_role,object)
	return true
end

function FightManager:DoCollect(attack,target)
	if not attack or not target or attack:IsDeath() or not attack.PlayCollect then
		return
	end
	local config = Config.db_creep[target.object_info.id]
	if not config then
		return
	end
	local attack_pos = attack:GetPosition()
	local target_pos = target:GetPosition()
	local angle = GetSceneAngle(attack_pos,target_pos)
	attack:SetRotateY(angle)
	local info = {target_id = target.object_id,action_time = config.collect > 0.2 and config.collect or 0.2}
	attack:PlayCollect(info)
end

function FightManager:GetFightState()
	local main_role = SceneManager:GetInstance():GetMainRole()
	if not main_role then
		self.fight_state:SetValue(FightManager.FightState.Null)
		return self.fight_state
	end
	if self.fight_state.last_change_time == Time.time then
		return self.fight_state
	end
	local cur_time_ms = os.clock()
	local pk_time = 8000
	local normal_time = 1500
	if cur_time_ms - main_role.last_be_role_hit_time > pk_time and cur_time_ms - main_role.last_attack_role_time > pk_time then
		self.fight_state:Remove(FightManager.FightState.PK)
	else
		self.fight_state:Add(FightManager.FightState.PK)
	end
	if cur_time_ms - main_role.last_attack_monster_time > normal_time then
		self.fight_state:Remove(FightManager.FightState.Normal)
	else
		self.fight_state:Add(FightManager.FightState.Normal)
	end
	self.fight_state.last_change_time = Time.time
	return self.fight_state
end

--/*判断是否在普通战斗状态*/
function FightManager:IsInFightNornalState()
	self:GetFightState()
	return self.fight_state:Contain(FightManager.FightState.Normal)
end

--/*判断是否在PK战斗状态*/
function FightManager:IsInFightPKState()
	self:GetFightState()
	return self.fight_state:Contain(FightManager.FightState.PK)
end

--/*判断是否在非战斗状态*/
function FightManager:IsInFightNULLState()
	self:GetFightState()
	return self.fight_state:Contain(FightManager.FightState.Null)
end

function FightManager:Revive(uid)
	local is_has_damage = false
	for object_id,skill_list in pairs(self.fightdata_list) do
		for skill_key,fightdata in pairs(skill_list) do
			local del_tab
			if fightdata.dmgs1 then
				local len = #fightdata.dmgs1
				for i=1,len do
					local damage = fightdata.dmgs1[i]
					local object = SceneManager:GetInstance():GetObject(damage.uid)
					if damage.uid == uid then
						del_tab = del_tab or {}
						del_tab[#del_tab+1] = i
					end
				end
			end
			if not table.isempty(del_tab) then
				if not is_has_damage then
					is_has_damage = true
				end
				table.RemoveByIndexList(fightdata.dmgs1,del_tab)
			end
		end
	end
	return is_has_damage
end

function FightManager:AddHeal(uid,value,text_type)
	uid = uid or RoleInfoModel:GetInstance():GetMainRoleId()
	local damage = {
		type = text_type or enum.DAMAGE.DAMAGE_HEAL,
		uid = uid,
		value = value,
	}
	local info = {damage = damage,atkid = uid}
	self:AddTextInfo(info)
end

function FightManager:AddTextInfo(info)
	self.main_role_be_hurt_damage:push(info)
end

function FightManager:AddExpTextInfo(value)
	local role_id = RoleInfoModel:GetInstance():GetMainRoleId()
	local damage = {
		type = enum.DAMAGE.DAMAGE_EXP,
		uid = role_id,
		value = value,
	}
	local info = {damage = damage,atkid = role_id}
	self.main_role_add_exp_list:push(info)
end

function FightManager:Update(deltaTime)
	local delete_tab
	for object_id,skill_list in pairs(self.fightdata_list) do
		for skill_key,fightdata in pairs(skill_list) do

			fightdata:Update(deltaTime)
			
			if fightdata.pass_time >= fightdata.skill_vo.action_time then
				-- 清除数据要 检查是否删除死亡怪物
				if fightdata.dmgs1 then
					self:ClearDamageInfo(fightdata.dmgs1,fightdata.attack,fightdata.message_time)
				end
				delete_tab = delete_tab or {}
				delete_tab[#delete_tab + 1] = {object_id = object_id,skill_key = skill_key}
			end
		end
	end

	if delete_tab then
		for k,info in pairs(delete_tab) do
			self:RemoveFightData(info.object_id,info.skill_key)
		end
		delete_tab = nil
	end

	--
	local cur_time = Time.time
	for object_id,list in pairs(self.object_wait_attack) do
		local d_tab = {}
		local length = #list
		for i=1,length do
			local info = list[i]
			if cur_time - info.add_time > 3.0 then
				local fightdata = info.fightdata
				if fightdata.dmgs1 then
					self:ClearDamageInfo(fightdata.dmgs1,fightdata.attack,fightdata.message_time)
				end
				d_tab[#d_tab+1] = i
			end
		end
		if not table.isempty(d_tab) then
			-- if AppConfig.Debug then
			-- 	local object = SceneManager:GetInstance():GetObject(object_id)
			-- 	if object and object.__cname == "Role" then
			-- 		logError("本地调试：战斗包超过3秒都没法处理，查看日志")
			-- 		if object then
			-- 			Yzprint('--LaoY FightManager.lua,line 840--',object.object_info.name,object.cur_state_name,object.is_dctored,object:IsDeath())
			-- 		else
			-- 			Yzprint('--LaoY FightManager.lua,line 840--',object_id)
			-- 		end
			-- 		for k,v in pairs(d_tab) do
			-- 			local info = list[v]
			-- 			local fightdata = info.fightdata
			-- 			Yzprint('--LaoY FightManager.lua,line 851--',fightdata.skill_key)
			-- 			Yzdump(fightdata.skill_vo,"fightdata.skill_vo")
			-- 		end
			-- 	end
			-- end
			table.RemoveByIndexList(list,d_tab)
		end
	end

	local count = self.main_role_be_hurt_damage.length
	local main_role = SceneManager:GetInstance():GetMainRole()
	local start_count = self.max_main_role_hurt_text_count+1
	if main_role and main_role:IsDeath() then
		start_count = 1
	end
	for i=start_count,count do
		self.main_role_be_hurt_damage:shift()
	end

	local cur_time_ms = os.clock()
	if self.main_role_be_hurt_damage.length > 0 and cur_time_ms - self.last_main_role_hurt_text_time >= self.main_role_hurt_text_cd_ms then
		self.last_main_role_hurt_text_time = cur_time_ms
		local info = self.main_role_be_hurt_damage:shift()
		local damagetext = DamageText(nil,nil,info.damage)
		damagetext:SetData(info.atkid,info.damage,info.delay_time,info.coord)
	end

	if self.main_role_add_exp_list.length > 0 and cur_time_ms - self.last_main_role_add_exp_time >= self.main_role_add_exp_cd_ms then
		self.last_main_role_add_exp_time = cur_time_ms
		local info = self.main_role_add_exp_list:shift()
		local damagetext = DamageText(nil,nil,info.damage)
		damagetext:SetData(info.atkid,info.damage)
	end
end

function FightManager:DebugMonster(object_id,is_use)
	-- if is_use == nil then
	-- 	is_use = false
	-- end
	local object = SceneManager:GetInstance():GetObject(object_id)
	Yzprint('--LaoY FightManager.lua,line 958--',is_use,object_id,object)
	-- Yzdump(FightManager.FightMessageList,"FightManager.FightMessageList")
	if not object then
		return
	end

	local t = {}
	for k,info in pairs(FightManager.FightMessageList) do
		if is_use == nil or info.is_use == is_use or true then
			for _,damage in pairs(info.message.dmgs1) do
				if damage.uid == object.object_id then
					t[#t+1] = info
				end
			end
		end
	end

	self:DebugPrint(t)
end

local debug_count = 0
function FightManager:DebugPrint(list)
	if not FightManager.Debug then
		return
	end
	debug_count = debug_count + 1
	list = list or FightManager.FightMessageList
	local t = {}
	for k,v in pairs(list) do
		t[#t+1] = v
	end
	local function sortFunc(a,b)
		return a.index<b.index
	end

	Yzprint('--LaoY FightManager.lua,line 992--',debug_count,#list)

	local len = #t
	for i=1,len do
		local info = t[i]
		Yzprint("FightManager:DebugPrint===>index:",info.index,info.skill_key,info.is_use)
		Yzdump(info.message,"message")
		Yzdump(info.object_info,"object_info")
	end
end