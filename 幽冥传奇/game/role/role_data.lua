-------------------------------------------
-- 主角角色数据
-------------------------------------------
RoleData = RoleData or BaseClass(BaseData)

-- 事件
RoleData.ROLE_ATTR_CHANGE = "role_attr_change"	-- OBJ_ATTR里任意一个属性变化就会发出事件

function RoleData:__init()
	if RoleData.Instance then
		ErrorLog("[RoleData] Attemp to create a singleton twice !")
	end
	RoleData.Instance = self

	self.role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.delay_show_attr = false
	self.real_attr_t = {}

	self.role_info = {}
	self.capability_list = {}
	self.bool_show_chuanshi_w = 1
	self.bool_show_chuanshi_f = 1
end

function RoleData:__delete()
	RoleData.Instance = nil
	self:CancelDelayAttrTimer()
end

function RoleData:GetAttr(key)
	return self.role_vo[key]
end

function RoleData:SetAttr(key, value)
	local old_value = self.role_vo[key] or 0
	self.role_vo[key] = value
	self:OnChangeAttr(key, value, old_value)
end

function RoleData:SetDelayShowAttr(value)
	if value then
		self.delay_show_attr = value
		self:CancelDelayAttrTimer()
		self.delay_show_attr_timer = GlobalTimerQuest:AddDelayTimer(function() 
			self:SetNormalAttr()
		end, 4)
	else
		self:SetNormalAttr()
	end
end

function RoleData:SetNormalAttr()
	self.delay_show_attr = false
	for k,v in pairs(self.real_attr_t) do
		self:OnChangeAttr(k, v.value, v.old_value, true)
	end
	self.real_attr_t = {}
end

function RoleData:CancelDelayAttrTimer()
	if self.delay_show_attr_timer then
		GlobalTimerQuest:CancelQuest(self.delay_show_attr_timer)
		self.delay_show_attr_timer = nil
	end
end

function RoleData:OnChangeAttr(key, value, old_value, is_delay)
	if self.delay_show_attr then
		if self.real_attr_t[key] == nil then 
			self.real_attr_t[key] = {}
			self.real_attr_t[key].old_value = old_value
		end
		self.real_attr_t[key].value = value
		return
	end

	if value ~= old_value then
		-- 属性改变通知
		self:DispatchEvent(RoleData.ROLE_ATTR_CHANGE, {key = key, value = value, old_value = old_value, is_delay = is_delay})
		self:DispatchEvent(key, {key = key, value = value, old_value = old_value, is_delay = is_delay})
	end
	if key == OBJ_ATTR.ACTOR_BIND_COIN or key == OBJ_ATTR.ACTOR_COIN then
		if old_value < value then
			AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(AudioEffect.PickCoin))
		end
	end
end

-- 废弃
function RoleData:NotifyAttrChange(callback)
	-- self.notify_callback_list[callback] = callback
end

-- 废弃
function RoleData:UnNotifyAttrChange(callback)
	-- self.notify_callback_list[callback] = nil
end

------------------------------------------------------------------------
------------------------------------------------------------------------
-- 外观属性key
RoleData.APPEARANCE_ATTR_KEY = {
	[OBJ_ATTR.ENTITY_MODEL_ID] = 1,
	[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = 1,
	[OBJ_ATTR.ACTOR_WING_APPEARANCE] = 1,
	[OBJ_ATTR.ACTOR_FOOT_APPEARANCE] = 1,
}
function RoleData.IsAppearanceAttrKey(key)
	return nil ~= RoleData.APPEARANCE_ATTR_KEY[key]
end

------------------------------------------------------------------------
------------------------------------------------------------------------

-- 轮回总等级
function RoleData:GetLunhuiTotalLevel()
	local val = self.role_vo[OBJ_ATTR.PROP_ACTOR_CHLLFBCOUNT]
	local level = bit:_and(bit:_rshift(val, 8), 0xf)
	local level2 = bit:_and(bit:_rshift(val, 12), 0xf)
	return level * 7 + level2
end

function RoleData:GetAtkSpeed()
	return self.role_vo[OBJ_ATTR.CREATURE_ATTACK_SPEED] / 1000 + 0.1
end

function RoleData:GetExp()
	return bit:merge64(self.role_vo[OBJ_ATTR.ACTOR_EXP_L], self.role_vo[OBJ_ATTR.ACTOR_EXP_H])
end

function RoleData:GetMaxExp()
	return bit:merge64(self.role_vo[OBJ_ATTR.ACTOR_MAX_EXP_L], self.role_vo[OBJ_ATTR.ACTOR_MAX_EXP_H])
end

function RoleData:GetRoleBaseProf(prof)
	local prof = prof or self.role_vo[OBJ_ATTR.ACTOR_PROF]
	return prof % 10, math.floor(prof / 10)
end

function RoleData:RoleInfoIsOk()
	return true
end

function RoleData:GetRoleInfo()
	return self.role_info
end

--获得职业名字
function RoleData:GetProfNameByType(prof_type)
	return Language.Common.ProfName[prof_type]
end

--获得阵营编号
function RoleData:GetCampColorByType(camp_type)
	return camp_type
end

--根据属性类型获得属性名字。名字参照role中的vo
function RoleData:GetRoleAttrNameByType(type)		
	if self.attr_name == nil then
		self.attr_name = {}
		self.attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_HP] = "hp"
		self.attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_MP] = "mp"
		self.attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_MAXHP] = "max_hp"
		self.attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_MAXMP] = "max_mp"
		self.attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_GONGJI] = "gong_ji"
		self.attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_FANGYU] = "fang_yu"
		self.attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_MINGZHONG] = "ming_zhong"
		self.attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_SHANBI] = "shan_bi"
		self.attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_BAOJI] = "bao_ji"
		self.attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_JIANREN] = "jian_ren"
		self.attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_MOVE_SPEED] = "move_speed"
		self.attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_FUJIA_SHANGHAI] = "fujia_shanghai"
		self.attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_DIKANG_SHANGHAI] = "dikang_shanghai"

		self.attr_name[GameEnum.BASE_CHARINTATTR_TYPE_MAXHP] = "base_max_hp"
		self.attr_name[GameEnum.BASE_CHARINTATTR_TYPE_GONGJI] = "base_gongji"
		self.attr_name[GameEnum.BASE_CHARINTATTR_TYPE_FANGYU] = "base_fangyu"
		self.attr_name[GameEnum.BASE_CHARINTATTR_TYPE_MINGZHONG] = "base_mingzhong"
		self.attr_name[GameEnum.BASE_CHARINTATTR_TYPE_SHANBI] = "base_shanbi"
		self.attr_name[GameEnum.BASE_CHARINTATTR_TYPE_BAOJI] = "base_baoji"
		self.attr_name[GameEnum.BASE_CHARINTATTR_TYPE_JIANREN] = "base_jianren"
		self.attr_name[GameEnum.BASE_CHARINTATTR_TYPE_MOVE_SPEED] = "base_move_speed"
		self.attr_name[GameEnum.BASE_CHARINTATTR_TYPE_FUJIA_SHANGHAI] = "base_fujia_shanghai"
		self.attr_name[GameEnum.BASE_CHARINTATTR_TYPE_DIKANG_SHANGHAI] = "base_dikang_shanghai"
	end
	
	return self.attr_name[type]
end

--根据属性类型获得服务端属性名字。名字参照role中的vo
function RoleData:GetServerRoleAttrNameByType(type)		
	if self.sever_attr_name == nil then
		self.sever_attr_name = {}
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_HP] = "hp"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_MP] = "mp"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_MAXHP] = "maxhp"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_MAXMP] = "maxmp"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_GONGJI] = "gongji"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_FANGYU] = "fangyu"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_MINGZHONG] = "mingzhong"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_SHANBI] = "shanbi"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_BAOJI] = "baoji"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_JIANREN] = "jianren"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_MOVE_SPEED] = "movespeed"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_FUJIA_SHANGHAI] = "fujia_shanghai"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_DIKANG_SHANGHAI] = "dikang_shanghai"

		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_MAXHP] = "maxhp"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_GONGJI] = "gongji"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_FANGYU] = "fangyu"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_MINGZHONG] = "mingzhong"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_SHANBI] = "shanbi"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_BAOJI] = "baoji"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_JIANREN] = "jianren"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_MOVE_SPEED] = "move_speed"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_FUJIA_SHANGHAI] = "fujia_shanghai"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_DIKANG_SHANGHAI] = "dikang_shanghai"
	end
	return type and self.sever_attr_name[type] or self.sever_attr_name
end

--是否足够绑定和非绑定元宝，优先使用绑定的情况(现在已废弃)
function RoleData:GetIsEnoughAllGold(cost_gold)
	if nil == cost_gold then
		return false
	end
	local all_gold = RoleData.Instance.role_info.gold + RoleData.Instance.role_info.bind_gold
	return all_gold >= cost_gold
end

--是否足够非绑定元宝
function RoleData:GetIsEnoughUseGold(cost_gold)
	if nil == cost_gold then
		return false
	end
	local gold = RoleData.Instance.role_info.gold
	return gold >= cost_gold
end

--是否足够绑定和非绑定铜币，优先使用绑定的情况
function RoleData.GetIsEnoughAllCoin(cost_coin)
	if nil == cost_coin then
		return false
	end
	local coin = RoleData.Instance.role_info.coin or 0
	local bind_coin = RoleData.Instance.role_info.bind_coin or 0
	local all_coin = coin + bind_coin
	return all_coin >= cost_coin
end

-- ACTOR_BIND_COIN					= 55,		-- uint 绑元
-- ACTOR_COIN						= 56,		-- uint 非绑元
-- ACTOR_BIND_GOLD					= 57,		-- uint 钻石
-- ACTOR_GOLD						= 58,		-- uint 非绑定钻石
RoleData.MoneyType2AttrName = {
	[MoneyType.BindCoin] = OBJ_ATTR.ACTOR_BIND_COIN,
	[MoneyType.Coin] = OBJ_ATTR.ACTOR_COIN,
	[MoneyType.BindYuanbao] = OBJ_ATTR.ACTOR_BIND_GOLD,
	[MoneyType.Yuanbao] = OBJ_ATTR.ACTOR_GOLD,
} 

RoleData.RewardRypeAttrName  = {
	[tagAwardType.qatBindMoney] = OBJ_ATTR.ACTOR_BIND_COIN,
	[tagAwardType.qatMoney] = OBJ_ATTR.ACTOR_COIN,
	[tagAwardType.qatBindYb] = OBJ_ATTR.ACTOR_BIND_GOLD,
	[tagAwardType.qatYuanbao] = OBJ_ATTR.ACTOR_GOLD,
	[tagAwardType.qatSpiritShield] = OBJ_ATTR.ACTOR_SHIELD_SPIRIT,
	[tagAwardType.qatBravePoint] = OBJ_ATTR.ACTOR_BRAVE_POINT,
}

function RoleData.GetMoneyTypeIcon(price_type)
	if price_type == MoneyType.BindCoin then
		return ResPath.GetCommon("bind_coin")
	elseif price_type == MoneyType.Coin then
		return ResPath.GetCommon("coin")
	elseif price_type == MoneyType.BindYuanbao then
		return ResPath.GetCommon("bind_gold")
	elseif price_type == MoneyType.Yuanbao then
		return ResPath.GetCommon("gold")
	end
end

function RoleData.GetMoneyTypeIconByAwardType(award_type)
	if award_type == tagAwardType.qatBindMoney then
		return ResPath.GetCommon("bind_coin")
	elseif award_type == tagAwardType.qatMoney then
		return ResPath.GetCommon("bind_gold")
	elseif award_type == tagAwardType.qatYuanbao then
		return ResPath.GetCommon("gold")
	end
end

--根据奖励类型获得属性
function RoleData:GetMainMoneyByType(award_type)
	return self:GetAttr(RoleData.RewardRypeAttrName[award_type])
end

function RoleData:GetManMoneyByType(money_type)
	return self:GetAttr(RoleData.MoneyType2AttrName[money_type])
end

--是否足够非绑定铜币
function RoleData.GetIsEnoughUseCoin(cost_coin)
	if nil == cost_coin then
		return false
	end
	local coin = RoleData.Instance.role_info.coin
	return coin >= cost_coin
end

--现在协议里面，转生等级通过 * 1000 由level这个字段传过来
function RoleData.GetLevelString(level, zhuan)
	if nil == zhuan then
		zhuan = math.floor(level / 1000)
		level = level % 1000
	end
	return string.format(Language.Common.LevelFormat, level, zhuan)
end

function RoleData:IsEnoughLevelZhuan(limit_level)
	return self.role_vo[OBJ_ATTR.CREATURE_LEVEL] >= limit_level
end

function RoleData:SetDayRevivalTimes(day_revival_times)
	self.day_revival_times = day_revival_times
end

-- 每日复活次数
function RoleData:GetDayRevivalTimes()
	return self.day_revival_times
end

-- 铜币复活所需铜币
function RoleData:GetRevivalCoin(times)
	times = times or self.role_vo.day_revival_times + 1
	local coin = 0
	for i,v in ipairs(DAY_REVIVAL_TIMES) do
		if times >= v[1] then
			coin = v[2]
		else
			return coin
		end
	end
	return coin
end

-- 获取角色等级属性经验配置
function RoleData.GetRoleExpCfgByLv(lv)
	lv = lv or RoleData.Instance.role_vo.level
	return ConfigManager.Instance:GetAutoConfig("roleexp_auto").exp_config[lv]
end

function RoleData:SetCapabilityList(capability_list)
	self.capability_list = capability_list
end

function RoleData:GetCapabilityByType(type)
	return self.capability_list[type]
end

function RoleData.HasBuffGroup(buff_group)
	local buff_list = RoleData.Instance.role_vo.buff_list
	if buff_list == nil then return false end
	for k,v in pairs(buff_list) do
		if v.buff_group == buff_group then
			return true
		end
	end
	return false
end

function RoleData.GetBuffGroup(buff_group)
	local buff_list = RoleData.Instance.role_vo.buff_list
	if buff_list == nil then return nil end
	for k,v in pairs(buff_list) do
		if v.buff_group == buff_group then
			return v
		end
	end
	return nil
end

local range_attr = nil
local attr_color = {
	[83] = "ff2828",
    [84] = "ff2828",
    [164] = "ff2828",
    [165] = "ff2828",
}

--prof_ignore 职业枚举
function RoleData.FormatRoleAttrStr(title_attrs, is_range, prof_ignore)
	range_attr = range_attr or {
			[GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MIN_ADD] = GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MAX_ADD,
			[GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MAX_ADD] = -GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MIN_ADD,
			[GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MIN_POWER] = GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MAX_POWER,
			[GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MAX_POWER] = -GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MIN_POWER,
			[GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MIN_ADD] = GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MAX_ADD,
			[GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MAX_ADD] = -GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MIN_ADD,
			[GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MIN_POWER] = GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MAX_POWER,
			[GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MAX_POWER] = -GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MIN_POWER,
			[GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MIN_ADD] = GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MAX_ADD,
			[GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MAX_ADD] = -GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MIN_ADD,
			[GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MIN_POWER] = GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MAX_POWER,
			[GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MAX_POWER] = -GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MIN_POWER,
			[GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MIN_ADD] = GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MAX_ADD,
			[GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MAX_ADD] = -GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MIN_ADD,
			[GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MIN_POWER] = GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MAX_POWER,
			[GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MAX_POWER] = -GAME_ATTRIBUTE_TYPE.PHYSICAL_DEFENCE_MIN_POWER,
			[GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MIN_ADD] = GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MAX_ADD,
			[GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MAX_ADD] = -GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MIN_ADD,
			[GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MIN_POWER] = GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MAX_POWER,
			[GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MAX_POWER] = -GAME_ATTRIBUTE_TYPE.MAGIC_DEFENCE_MIN_POWER,
		}

	local base_prof = RoleData.Instance:GetRoleBaseProf()

	local temp_attr_list = {}
	if nil == is_range or is_range then
		for i, v in ipairs(title_attrs) do
			if nil ~= range_attr[v.type] then
				if (v.job == nil or v.job == base_prof) then
					temp_attr_list[v.type] = v.value
				end
			end
		end
	end

	local prof_ignore_list = RoleData.ProfIgnoreAttrList(prof_ignore)
	local attr_str_list = {}
	for i, v in ipairs(title_attrs) do
		if (v.job == nil or v.job == base_prof) then
			local other_type = range_attr[v.type]
			if nil ~= temp_attr_list[v.type] and nil ~= other_type and temp_attr_list[math.abs(other_type)] then
				if other_type > 0 and not prof_ignore_list[v.type] then
					local other_value = temp_attr_list[other_type]
					table.insert(attr_str_list, {
							type_str = Language.Role.BuffAttrName[v.type + 1000] or "",
							value_str = RoleData.FormatValueStr(v.type, v.value) .. "-" .. RoleData.FormatValueStr(other_type, other_value),
							type = v.type,
							type_r = other_type,
							value = v.value,
							value_r = other_value,
						})
				end
			else
				table.insert(attr_str_list, {
						type_str = Language.Role.BuffAttrName[v.type] or "",
						value_str = RoleData.FormatValueStr(v.type, v.value),
						type = v.type,
						value = v.value,
						type_color = attr_color[v.type],
						value_color = attr_color[v.type],
					})
			end

		end
	end
	return attr_str_list
end

--非组合属性
function RoleData.FormatRoleAttrStrNotCombination(title_attrs)
    local attr_str_list = {}
    for i, v in ipairs(title_attrs) do
        table.insert(attr_str_list, {
            type_str = Language.Role.BuffAttrName[v.type] or "",
            value_str = RoleData.FormatValueStr(v.type, v.value),
            type = v.type,
            value = v.value,
            type_color = attr_color[v.type],
            value_color = attr_color[v.type],
        })
    end
    return attr_str_list
end

-- 职业要忽略的属性
local PROF_IGNORE_ATTR_LIST = nil
function RoleData.ProfIgnoreAttrList(prof)
	local prof = prof or RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	if not PROF_IGNORE_ATTR_LIST then
		PROF_IGNORE_ATTR_LIST = {
			[GameEnum.ROLE_PROF_1] = {
				[GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MIN_ADD] = 1,
				[GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MAX_ADD] = 1,
				[GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MIN_POWER] = 1,
				[GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MAX_POWER] = 1,
				[GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MIN_ADD] = 1,
				[GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MAX_ADD] = 1,
				[GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MIN_POWER] = 1,
				[GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MAX_POWER] = 1,
			},
			[GameEnum.ROLE_PROF_2] = {
				[GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MIN_ADD] = 1,
				[GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MAX_ADD] = 1,
				[GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MIN_POWER] = 1,
				[GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MAX_POWER] = 1,
				[GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MIN_ADD] = 1,
				[GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MAX_ADD] = 1,
				[GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MIN_POWER] = 1,
				[GAME_ATTRIBUTE_TYPE.WIZARD_ATTACK_MAX_POWER] = 1,
			},
			[GameEnum.ROLE_PROF_3] = {
				[GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MIN_ADD] = 1,
				[GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MAX_ADD] = 1,
				[GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MIN_POWER] = 1,
				[GAME_ATTRIBUTE_TYPE.PHYSICAL_ATTACK_MAX_POWER] = 1,
				[GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MIN_ADD] = 1,
				[GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MAX_ADD] = 1,
				[GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MIN_POWER] = 1,
				[GAME_ATTRIBUTE_TYPE.MAGIC_ATTACK_MAX_POWER] = 1,
			},
		}
	end
	return PROF_IGNORE_ATTR_LIST[prof] or {}
end

function RoleData.IsFloatAttr(type)
	if AttrDataTypes[type] == eAttribueTypeDataType.adFloat then
		return true
	end
	return false
end

function RoleData.IsTenThousandPerAttr(type)
	local format_info = GAME_ATTRIBUTE_FORMAT[type]
	if format_info and format_info.val_rate == 0.0001 then
		return true
	end
	return false
end

-- GAME_ATTRIBUTE_TYPE 格式化属性
function RoleData.FormatValueStr(type, value)
	if RoleData.IsFloatAttr(type) then
		return value * 100 .. "%"
	elseif RoleData.IsTenThousandPerAttr(type) then
		return string.format("%.2f", value / 100) .. "%"
	elseif type == GAME_ATTRIBUTE_TYPE.DIE_REFRESH_HP_PRO
		or type == GAME_ATTRIBUTE_TYPE.Dizzy
		or type == GAME_ATTRIBUTE_TYPE.CONTROL_SKILL_IMMUNE then
		return value .. Language.Common.TimeList.s
	elseif type == GAME_ATTRIBUTE_TYPE.ADD_SKILL_LEVEL then
		local skill_id, level = RefineData.GetSkillIdAndLevel(value)
		local skill_cfg = SkillData.GetSkillCfg(skill_id)
		return string.format("%s+%d",  skill_cfg and skill_cfg.name or "", level) 
	end
	return tostring(value)
end

-- OBJ_ATTR 格式化属性
function RoleData.FormatObjAttrValueStr(type, value)
	local attr_info = OBJ_ATTR_FORMAT[type]
	if nil ~= attr_info then
		if attr_info.type == OBJ_ATTR_TYPE.NORAML then
			return tostring(value * attr_info.val_rate)
		elseif attr_info.type == OBJ_ATTR_TYPE.RATE then
			return string.format("%.2f", value * attr_info.val_rate * 100) .. "%"
		end
	else
		return tostring(value)
	end
end

function RoleData.FormatAttrContent(attr_cfg, rich_param, mark)
	local type_str_color
	local value_str_color
	local prof_ignore
	if rich_param then
		type_str_color = rich_param.type_str_color and (type(rich_param.type_str_color) == "string" and
				rich_param.type_str_color or C3b2Str(rich_param.type_str_color))
		value_str_color = rich_param.value_str_color and (type(rich_param.value_str_color) == "string" and
				rich_param.value_str_color or C3b2Str(rich_param.value_str_color))
		prof_ignore = rich_param.prof_ignore
	end
	mark = mark or "\n"
	local attr_data = RoleData.FormatRoleAttrStr(attr_cfg, nil, prof_ignore)
	local attr_content = ""
	
	if attr_data then
		local index= 1	
		for i,v in ipairs(attr_data) do
			if index ~= 1 then
				attr_content = attr_content .. mark
			end
			local type_str = v.type_str
			if type_str_color then
				type_str = "{wordcolor;" .. type_str_color .. ";" .. type_str .. "}"
			end
			local value_str = v.value_str
			if value_str_color then
				value_str = "{wordcolor;" .. value_str_color .. ";" .. value_str .. "}"
			end
			attr_content = attr_content .. type_str .. "：" .. value_str
			index = index + 1
		end
	end
	return attr_content
end

function RoleData:IsSocialMask(mask_def)
	if bit:_and(bit:_rshift(self:GetAttr(OBJ_ATTR.ACTOR_SOCIAL_MASK), mask_def), 1) == 1 then
		return true
	end
	return false
end

function RoleData:IsEntityState(state_def)
	if bit:_and(bit:_rshift(self:GetAttr(OBJ_ATTR.CREATURE_STATE), state_def), 1) == 1 then
		return true
	end
	return false
end

function RoleData.SubRoleName(name)
	if nil == name then return "" end
	local i, j = string.find(name, "^s%d+.")
	if i == 1 and j ~= nil then
		return string.sub(name, j + 1)
	end
	return name
end

function RoleData:GetRoleName()
	return self:GetAttr("name")
end


--选出特殊属性
function RoleData:GetSpecailAttr(attrs)
	local normal_attr = {}
	local special_attr = {}
	for k, v in pairs(attrs) do
		if (JiChuXingShuTypeCfg[v.type] == true) then
			table.insert(normal_attr, v)

		else
			table.insert(special_attr, v)
		end
	end
	return normal_attr, special_attr
end

function RoleData:SetChuanShiSHow( bool_show_chuanshi_w)
	self.bool_show_chuanshi_w = bool_show_chuanshi_w
	--self.bool_show_chuanshi_f = 1
end

function RoleData:GetCanChuanSHiWeapon( ... )
	return self.bool_show_chuanshi_w
end

function RoleData:SetChuanShiFashion(bool_show_chuanshi_f)
	self.bool_show_chuanshi_f = bool_show_chuanshi_f
end

function RoleData:GetShowShiFashion()
	return self.bool_show_chuanshi_f
end

function RoleData:GetAttrColorByType(type)
	if type == 5 or type == 7 or type == 9 or type == 11 or type ==13 or type == 15 or 
		type == 17 or type == 19 or type == 21 or type == 23 or type ==25 or type == 27 then
		return COLOR3B.WHITE
	end
	return COLOR3B.RED
end