
FightData = FightData or BaseClass()

FIGHT_EFFECT_JIANG_PO = 3102
FIGHT_EFFECT_MASSAGE = 3322
KUAFU_FIGHT_ATTACK = 3310
KUAFU_FIGHT_DEFEND = 3311
function FightData:__init()
	if FightData.Instance then
		print_error("[FightData]:Attempt to create singleton twice!")
	end
	FightData.Instance = self

	self.main_role_effect_list = {}					-- 主角effect
	self.target_objid = COMMON_CONSTS.INVALID_OBJID	-- 目标objid
	self.target_effect_list = {}					-- 目标effect
	self.beauty_effect_list = {}					-- 美人effect
	self.equip_level_add = 0						-- 装备越级
	self.equip_level_change_callback_list = {}

	self.be_hit_list = {}							-- 受击缓存
	self.buff_pause_list = {} 						-- buff暂停时间表
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

	self.buff_pause_list = {}

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

	if obj:IsMainRole() then
		self:UpdateEffect(self.main_role_effect_list, effect)
		GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
		if effect.effect_type == FIGHT_EFFECT_TYPE.BIANSHEN then
			obj:SetAttr("bianshen_param", protocol.param_list[2])
		end
		if BUFF_PROGRESS[effect.client_effect_type] then
			local buff_info = {}
			buff_info.buff_type = effect.client_effect_type
			buff_info.time = effect.param_list[BUFF_PROGRESS[effect.client_effect_type]]		--buff 持续市场（毫秒单位）
			BuffProgressData.Instance:SetBuffInfo(buff_info)
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
			effect.param_list[3] = vip_cfg.mianshang_per / 100  --vip免伤，由于是万分比，需要显示成百分比，所以除以100
			--effect.param_list[6] = vip_cfg.fangyu
			--effect.param_list[9] = vip_cfg.maxhp

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
	local add_percent = math.min(COMMON_CONSTS.WORLD_LEVEL_EXP_PERCENT_BASE + (world_level - role_level) * COMMON_CONSTS.WORLD_LEVEL_EXP_PERCENT, COMMON_CONSTS.WORLD_LEVEL_EXP_MAX_PERCENT)

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

-- 获取主角Effect列表
function FightData:GetMainRoleShowEffect()
	local effect_list = {}

	-- 策划不要VIP buff
	-- local vip_effect = self:GetMainRoleVipEffect()
	-- if nil ~= vip_effect then
	-- 	table.insert(effect_list, {type = 0, info = vip_effect})
	-- end

	local world_effect = self:GetWroldLevelEffect()
	if nil ~= world_effect then
		table.insert(effect_list, {type = 0, info = world_effect})
	end

	local boss_die_effect = self:GetWroldBossDieEffect()
	if nil ~= boss_die_effect then
		table.insert(effect_list, {type = 0, info = boss_die_effect})
	end

	local cd_time = 0
	for k, v in pairs(self.main_role_effect_list) do
		if v.client_effect_type > 0 then
			if v.effect_type == FIGHT_EFFECT_TYPE.MOVESPEED then
				cd_time = v.param_list[3]
			else
				cd_time = v.param_list[1]
			end

			local pause_time = self.buff_pause_list[v.client_effect_type] or 0
			if pause_time > 0 then
				pause_time = Status.NowTime - pause_time
				v.recv_time = v.recv_time + pause_time
			end

			v.cd_time = math.max(cd_time / 1000 - (Status.NowTime - v.recv_time), 0)
			self.buff_pause_list[v.client_effect_type] = 0
			table.insert(effect_list, {type = 1, info = v})
		end
	end
	for k,v in pairs(self.beauty_effect_list) do
		if nil ~= v then
			v.cd_time = v.param2 - TimeCtrl.Instance:GetServerTime()
			table.insert(effect_list, {type = 2, info = v})
		end
	end
	return effect_list
end

-- 设置美人effect
function FightData:SetBeautyEffectLest(protocol)
	if protocol.is_exist == 1 then
		local beauty_skill = BeautyData.Instance:GetBeautySkill(protocol.skill_type)
		if beauty_skill then
			local effect = FightData.CreateEffectInfo()
			effect.effect_type = protocol.skill_type
			effect.param1 = protocol.param1
			effect.param2 = protocol.param2
			self.beauty_effect_list[protocol.skill_type] = effect
		end
	else
		self.beauty_effect_list[protocol.skill_type] = nil
	end
	GlobalEventSystem:Fire(ObjectEventType.FIGHT_EFFECT_CHANGE, true)
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
					if effect_info.type == 1 and index == 1 and temp ~= nil and data.effect_type ~= FIGHT_EFFECT_TYPE.ATTR_PER then
						temp = temp / 1000
					end

					if "w" == str_arr[3] then
						local merge_layer = 1
						if data.merge_layer and data.merge_layer ~= 0 then
							merge_layer = data.merge_layer
						end
						temp = data.client_effect_type == FIGHT_EFFECT_JIANG_PO and temp * merge_layer / 100 or temp * merge_layer
						desc = desc .. (temp or 0) .. "%"
					elseif index == 2 and data.client_effect_type == FIGHT_EFFECT_MASSAGE then 	-- 按摩buff将p_2转为文字描述
						if temp == 18 then 
							temp = Language.Common.AttrName.ice_master
						elseif temp == 19 then 
							temp = Language.Common.AttrName.fire_master
						elseif temp == 20 then 
							temp = Language.Common.AttrName.thunder_master
						elseif temp == 21 then 
							temp = Language.Common.AttrName.poison_master	
						end
						desc = desc .. temp
					elseif data.client_effect_type == KUAFU_FIGHT_ATTACK or data.client_effect_type == KUAFU_FIGHT_DEFEND then
						desc = desc..CommonDataManager.ConverMoney(temp or 0)   --特殊场景，buff数值太大需要加单位
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

function FightData:SaveBeHitInfo(obj_id, deliverer_id, skill_id, real_blood, blood, fighttype, nvshen_hurt)
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
	})
end

function FightData:DoBeHit(info, is_main_role, target_obj_id)
	for k, v in pairs(info.hit_info_list) do
		if v.obj ~= nil and not v.obj:IsDeleted() and v.obj:IsCharacter() then
			v.obj:DoBeHit(info.deliverer, info.skill_id, v.real_blood, v.blood, v.fighttype)
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

function FightData:SetBuffPause(client_type, value)
	if client_type == nil or value == nil then
		return
	end

	self.buff_pause_list[client_type] = value
end