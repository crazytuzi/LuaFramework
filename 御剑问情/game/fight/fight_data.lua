
FightData = FightData or BaseClass()

-- 大招播放速度
ANGER_SKILL_PLAY_SPEED = {
	1.7, 1.9, 1.9, 1.9
}

function FightData:__init()
	if FightData.Instance then
		print_error("[FightData]:Attempt to create singleton twice!")
	end
	FightData.Instance = self

	self.main_role_effect_list = {}					-- 主角effect
	self.target_objid = COMMON_CONSTS.INVALID_OBJID	-- 目标objid
	self.target_effect_list = {}					-- 目标effect

	self.equip_level_add = 0						-- 装备越级
	self.equip_level_change_callback_list = {}

	self.be_hit_list = {}							-- 受击缓存
end

function FightData:__delete()
	FightData.Instance = nil
end

function FightData.CreateEffectInfo()
	return {
		effect_type = 0,
		product_method = 0,
		product_id = 0,
		unique_key = 0,
		param_list = {},
		client_effect_type = 0,
		merge_layer = 0,
		recv_time = 0,
		cd_time = 0,
	}
end

function FightData:Update(now_time, elapse_time)
	for k, v in pairs(self.be_hit_list) do
		if now_time >= v.max_trigger_time then
			self:DoBeHit(v, false, nil)
			self.be_hit_list[k] = nil
		end
	end
end

function FightData:OnEffectList(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj then
		return
	end

	local effect_list = {}
	for k, v in pairs(protocol.effect_list) do
		local effect = FightData.CreateEffectInfo()
		effect.effect_type = v.effect_type
		effect.product_method = v.product_method
		effect.product_id = v.product_id
		effect.param_list = v.param_list
		effect.unique_key = v.unique_key
		effect.client_effect_type = v.client_effect_type
		effect.merge_layer = v.merge_layer
		effect.recv_time = Status.NowTime
		table.insert(effect_list, effect)
	end

	if obj:IsMainRole() then
		self.main_role_effect_list = effect_list
		GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
	else
		self.target_objid = obj:GetObjId()
		self.target_effect_list = effect_list
		GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, false)
	end
end

function FightData:OnEffectInfo(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj then
		return
	end

	local effect = FightData.CreateEffectInfo()
	effect.effect_type = protocol.effect_type
	effect.product_method = protocol.product_method
	effect.product_id = protocol.product_id
	effect.param_list = protocol.param_list
	effect.unique_key = protocol.unique_key
	effect.client_effect_type = protocol.client_effect_type
	effect.merge_layer = protocol.merge_layer
	effect.recv_time = Status.NowTime

	local part = obj:GetDrawObj():GetRoot()
	if protocol.effect_type == 18 and protocol.client_effect_type == 4220 then
		self.scale_unique_key = protocol.unique_key
		part.transform.localScale = Vector3(protocol.param_list[4] / 100, protocol.param_list[4] / 100, protocol.param_list[4] / 100)
	elseif protocol.effect_type == 16 and protocol.client_effect_type == 4223 then
		self.transparent_unique_key = protocol.unique_key
		Scene.Instance:OnAddTransparent()
	end

	if obj:IsMainRole() then
		self:UpdateEffect(self.main_role_effect_list, effect)
		GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
		if effect.effect_type == FIGHT_EFFECT_TYPE.BIANSHEN then
			obj:SetAttr("bianshen_param", protocol.param_list[2])
		end
	else
		if self.target_objid ~= obj:GetObjId() then
			self.target_objid = obj:GetObjId()
			self.target_effect_list = {}
		end

		self:UpdateEffect(self.target_effect_list, effect)
		GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, false)
	end
end

function FightData:GetMainRoleEffectList()
	return self.main_role_effect_list or {}
end

function FightData:UpdateEffect(effect_list, effect)
	for i, v in ipairs(effect_list) do
		if v.unique_key == effect.unique_key then
			effect_list[i] = effect
			return
		end
	end
	table.insert(effect_list, effect)
end

-- 移除Effect
function FightData:OnEffectRemove(effect_key)
	if effect_key == self.transparent_unique_key then
		Scene.Instance:OnRemoveTransparent()
		self.transparent_unique_key = nil
	elseif effect_key == self.scale_unique_key then
		local main_role = Scene.Instance:GetMainRole()
		local part = main_role:GetDrawObj():GetRoot()
		part.transform.localScale = Vector3(1, 1, 1)
		self.scale_unique_key = nil
	end

	for i, v in ipairs(self.main_role_effect_list) do
		if v.unique_key == effect_key then
			table.remove(self.main_role_effect_list, i)
			GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
			break
		end
	end
end

function FightData:HasEffectByClientType(client_type)
	for k, v in pairs(self.main_role_effect_list) do
		if v.client_effect_type == client_type then
			return true
		end
	end

	return false
end

-- vip加成
function FightData:GetMainRoleVipEffect()
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
	if vip_level > 0 then
		local vip_cfg = VipData.Instance:GetVipBuffCfg(vip_level)
		if nil ~= vip_cfg then
			local effect = FightData.CreateEffectInfo()
			effect.unique_key = -1
			effect.client_effect_type = EFFECT_CLIENT_TYPE.ECT_OTHER_VIP
			effect.cd_time = 0
			for i = 1, 10 do
				effect.param_list[i] = 0
			end
			effect.param_list[3] = vip_cfg.gongji
			effect.param_list[6] = vip_cfg.fangyu
			effect.param_list[9] = vip_cfg.maxhp

			return effect
		end
	end

	return nil
end

-- 世界加成
function FightData:GetWroldLevelEffect()
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local world_level = RankData.Instance:GetWordLevel()
	if role_level < COMMON_CONSTS.WORLD_LEVEL_OPEN or role_level >= world_level then
		return nil
	end
	local add_percent = math.min((world_level - role_level - COMMON_CONSTS.WORLD_LEVEL_LIMIT) * COMMON_CONSTS.WORLD_LEVEL_EXP_PERCENT, COMMON_CONSTS.WORLD_LEVEL_EXP_MAX_PERCENT)
	if add_percent <= 0 then
		return nil 	--加成经验少于0不显示buff
	end
	local effect = FightData.CreateEffectInfo()
	effect.unique_key = -2
	effect.client_effect_type = EFFECT_CLIENT_TYPE.ECT_OTHER_SJJC
	effect.cd_time = 0
	for i = 1, 10 do
		effect.param_list[i] = 0
	end
	effect.param_list[2] = add_percent

	return effect
end

-- 世界boss死亡buff
function FightData:GetWroldBossDieEffect()
	local boss_weary = BossData.Instance:GetWroldBossWeary()
	local last_die_time = BossData.Instance:GetWroldBossWearyLastDie() + 300 - TimeCtrl.Instance:GetServerTime()
	if boss_weary <= 0 or BossData.Instance:GetWroldBossWearyLastDie() <= 0 then
		return nil
	end

	local effect = FightData.CreateEffectInfo()
	effect.unique_key = -2
	effect.client_effect_type = EFFECT_CLIENT_TYPE.ECT_BOSS_PILAO
	effect.cd_time = last_die_time
	for i = 1, 10 do
		effect.param_list[i] = 0
	end
	effect.param_list[2] = boss_weary < 5 and boss_weary or 5

	return effect
end

-- 一战到底攻击鼓舞buff
function FightData:GetYiZhanDaoDiGuWuEffect()
	local buff_value = YiZhanDaoDiData.Instance:GetGuWuValue()
	if buff_value <= 0 then return nil end

	local effect = FightData.CreateEffectInfo()
	effect.unique_key = -2
	effect.client_effect_type = EFFECT_CLIENT_TYPE.BCT_YZDD_GJ_BUFF
	effect.cd_time = 0
	for i = 1, 10 do
		effect.param_list[i] = 0
	end
	effect.param_list[4] = buff_value

	return effect
end

-- 获取主角Effect列表
function FightData:GetMainRoleShowEffect()
	local effect_list = {}

	local vip_effect = self:GetMainRoleVipEffect()
	if nil ~= vip_effect then
		table.insert(effect_list, {type = 0, info = vip_effect})
	end

	local world_effect = self:GetWroldLevelEffect()
	if nil ~= world_effect then
		table.insert(effect_list, {type = 0, info = world_effect})
	end

	local boss_die_effect = self:GetWroldBossDieEffect()
	if nil ~= boss_die_effect then
		table.insert(effect_list, {type = 0, info = boss_die_effect})
	end

	local yizhandaodi_guwu_effect = self:GetYiZhanDaoDiGuWuEffect()
	if nil ~= yizhandaodi_guwu_effect then
		table.insert(effect_list, {type = 0, info = yizhandaodi_guwu_effect})
	end

	local cd_time = 0
	for k, v in pairs(self.main_role_effect_list) do
		if v.client_effect_type > 0 then
			if v.effect_type == FIGHT_EFFECT_TYPE.MOVESPEED then
				cd_time = v.param_list[3]
			else
				cd_time = v.param_list[1]
			end
			v.cd_time = math.max(cd_time / 1000 - (Status.NowTime - v.recv_time), 0)
			table.insert(effect_list, {type = 1, info = v})
		end
	end
	return effect_list
end

-- 获取Effect描述
function FightData:GetEffectDesc(effect_info)
	local data = effect_info.info
	local cfg = ConfigManager.Instance:GetAutoConfig("buff_desc_auto").desc[data.client_effect_type]
	local desc = ""
	local name = ""
	if nil ~= cfg then
		name = cfg.name
		local i, j = 0, 0
		local last_pos = 1

		for loop_count = 1, 20 do
			i, j = string.find(cfg.desc, "(%[p_.-%])", j + 1)
			if nil == i or nil == j then
				desc = desc .. string.sub(cfg.desc, last_pos, -1)
				break
			else
				if last_pos ~= i then
					desc = desc .. string.sub(cfg.desc, last_pos, i - 1)
				end

				local str_arr = Split(string.sub(cfg.desc, i + 1, j - 1), "_")
				if #str_arr >= 2 then
					local index = tonumber(str_arr[2]) or 1
					local temp = data.param_list[index]
					if effect_info.type == 1 and (index == 1 or index == 3) and temp ~= nil and data.effect_type ~= FIGHT_EFFECT_TYPE.ATTR_PER then
						temp = temp / 1000
					end

					if "w" == str_arr[3] then
						desc = desc .. (temp or 0) / 100 .. "%"
					else
						desc = desc .. (math.ceil(temp or 0))
					end
				else
					desc = desc .. "nil"
				end
				last_pos = j + 1
			end
		end
	end
	return desc, name
end

function FightData:GetBeHitInfo(deliverer)
	return self.be_hit_list[deliverer]
end

function FightData:OnHitTrigger(deliverer, target_obj)
	local info = self.be_hit_list[deliverer]
	if nil ~= info and nil ~= target_obj then
		self:DoBeHit(info, deliverer:IsMainRole(), target_obj:GetObjId())
		self.be_hit_list[deliverer] = nil
	end
end

function FightData.CreateBeHitInfo(deliverer, skill_id)
	return {
		deliverer = deliverer,
		skill_id = skill_id,
		max_trigger_time = Status.NowTime + SkillData.GetSkillBloodDelay(skill_id),
		hit_info_list = {}
	}
end

function FightData:SaveBeHitInfo(obj_id, deliverer_id, skill_id, real_blood, blood, fighttype, nvshen_hurt, text_type)
	local deliverer = Scene.Instance:GetObj(deliverer_id)
	if deliverer == nil then
		return
	end

	if nil ~= self.be_hit_list[deliverer] then
		local info = self.be_hit_list[deliverer]
		if skill_id ~= info.skill_id or Status.NowTime - info.max_trigger_time > 0.1 then
			self:DoBeHit(info, false, nil)
			self.be_hit_list[deliverer] = FightData.CreateBeHitInfo(deliverer, skill_id)
		end
	else
		self.be_hit_list[deliverer] = FightData.CreateBeHitInfo(deliverer, skill_id)
	end

	table.insert(self.be_hit_list[deliverer].hit_info_list, {
		obj = Scene.Instance:GetObj(obj_id),
		real_blood = real_blood,
		blood = blood,
		fighttype = fighttype,
		nvshen_hurt = nvshen_hurt,
		text_type = text_type,
	})
end

function FightData:DoBeHit(info, is_main_role, target_obj_id)
	for k, v in pairs(info.hit_info_list) do
		if v.obj ~= nil and not v.obj:IsDeleted() and v.obj:IsCharacter() then
			v.obj:DoBeHit(info.deliverer, info.skill_id, v.real_blood, v.blood, v.fighttype, v.text_type)
			if v.nvshen_hurt and v.nvshen_hurt < 0 then
				v.obj:DoBeHit(info.deliverer, 0, 0, v.nvshen_hurt, v.fighttype, FIGHT_TEXT_TYPE.NVSHEN)
			end
			if not is_main_role or v.obj_id ~= target_obj_id then
				v.obj:DoBeHitShow(info.deliverer, info.skill_id, target_obj_id)
			end
		end
	end
end

function FightData:GetBuffDescCfgByType(effect_type)
	return ConfigManager.Instance:GetAutoConfig("buff_desc_auto").desc[effect_type]
end

function FightData:GetMainRoleDrugAddExp()
	if #self.main_role_effect_list == 0 then return 0 end
	local effect_type = 0
	for k,v in pairs(self.main_role_effect_list) do
		if v.client_effect_type == 2201 or v.client_effect_type == 2202 or v.client_effect_type == 2203 or v.client_effect_type == 2204 then
			return v.param_list[3]
		end
	end
	return 0
end

RoleSkillHit = {
	[1] = {
		attack1 = {
			[1] = 0.43,
			[2] = 0.6,
			[3] = 0.8,
		},
		attack2 = {
			[1] = 0.03,
			[2] = 0.7,
			[3] = 1.4,
		},
		attack3 = {
			[1] = 0.43,
			[2] = 1.37,
			[3] = 1.43,
		},
		attack4 = {
			[1] = 0.3,
			[2] = 0.63,
			[3] = 0.97,
			[4] = 1.5,
			[5] = 1.67,
			[6] = 2.87,
		},
		combo1_1 = {
			[1] = 0.13,
		},
		combo1_2 = {
			[1] = 0.16,
		},
		combo1_3 = {
			[1] = 0.33,
		},
	},
	[2] = {
		attack1 = {
			[1] = 0.07,
			[2] = 0.2,
			[3] = 0.6,
			[4] = 1.1,
		},
		attack2 = {
			[1] = 0.37,
			[2] = 0.67,
			[3] = 0.97,
			[4] = 1.13,
			[5] = 1.67,
		},
		attack3 = {
			[1] = 0.5,
			[2] = 0.73,
			[3] = 1.07,
		},
		attack4 = {
			[1] = 0.43,
			[2] = 1,
			[3] = 1.8,
			[4] = 2.03,
			[5] = 2.33,
			[6] = 2.67,
			[7] = 3.37,
		},
		combo1_1 = {
			[1] = 0.17,
		},
		combo1_2 = {
			[1] = 0.3,
		},
		combo1_3 = {
			[1] = 0.1,
		},
	},
	[3] = {
		attack1 = {
			[1] = 0.7,
			[2] = 0.9,
			[3] = 1.1,
		},
		attack2 = {
			[1] = 0.77,
			[2] = 1.33,
			[3] = 1.8,
		},
		attack3 = {
			[1] = 1.17,
			[2] = 1.4,
		},
		attack4 = {
			[1] = 2.4,
			[2] = 2.5,
			[3] = 3.06,
			[4] = 3.2,
		},
		combo1_1 = {
			[1] = 0.23,
		},
		combo1_2 = {
			[1] = 0.43,
		},
		combo1_3 = {
			[1] = 0.2,
		},
	},
	[4] = {
		attack1 = {
			[1] = 0.47,
			[2] = 0.06,
			[3] = 0.83,
			[4] = 1.1,
		},
		attack2 = {
			[1] = 0.5,
			[2] = 0.83,
			[3] = 1.2,
			[4] = 1.7,
		},
		attack3 = {
			[1] = 0.6,
			[2] = 1.4,
		},
		attack4 = {
			[1] = 0.9,
			[2] = 1.2,
			[3] = 1.4,
			[4] = 3.23,
		},
		combo1_1 = {
			[1] = 0.3,
		},
		combo1_2 = {
			[1] = 0.17,
			[2] = 0.3,
			[3] = 0.4,
		},
		combo1_3 = {
			[1] = 0.2,
		},
	},
}