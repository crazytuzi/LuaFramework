-------------------------------------------
-- 管理主角数据
-------------------------------------------
PlayerData = PlayerData or BaseClass(BaseEvent)

PlayerDataReNameItemId = {
	ItemId = 26918
}

PlayerData.ATTR_EVENT = "role_attr_event"	--角色属性变化

function PlayerData:__init()
	if PlayerData.Instance then
		print_error("[PlayerData] Attempt to create singleton twice!")
		return
	end
	PlayerData.Instance = self
	self:AddEvent(PlayerData.ATTR_EVENT)

	self.role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.exp_extra_per = 0
	RemindManager.Instance:Register(RemindName.AvatarChange, BindTool.Bind(self.GetAvatarChangeRemind, self))

	self.fashion_select = 1
	self.to_title_id = 1
	self.world_level = 0
	self.cur_server_level_seq = 0
	self.cur_satify_role_num = 0
	self.server_level_auto_uplevel_last_days = 0


	self.server_level_cfg = ConfigManager.Instance:GetAutoConfig("other_config_auto").server_level
	self.get_server_level_cfg = ListToMap(self.server_level_cfg or {},"seq")

	self.is_lock_capability_notify_tips = false
	self.origin_open_day = -1
end

function PlayerData:__delete()
	RemindManager.Instance:UnRegister(RemindName.AvatarChange)

	PlayerData.Instance = nil
end

function PlayerData:SetLockCapabilityNotifyTips(is_lock)
	self.is_lock_capability_notify_tips = is_lock
end

function PlayerData:IsLockCapabilityNotifyTips()
	return self.is_lock_capability_notify_tips
end

function PlayerData:GetRoleVo()
	return self.role_vo
end

function PlayerData:SetFashionSelect(num)
	self.fashion_select = num
end

function PlayerData:GetFashionSelect()
	return self.fashion_select
end

function PlayerData:GetAttr(key)
	return self.role_vo[key]
end

function PlayerData:SetAttr(key, value)
	local old_value = self.role_vo[key]
	self.role_vo[key] = value
	self:NotifyEventChange(PlayerData.ATTR_EVENT, key, value, old_value)
end

-- 监听数据改变
function PlayerData:ListenerAttrChange(callback)
	self:AddListener(PlayerData.ATTR_EVENT, callback)
end

-- 取消监听数据改变
function PlayerData:UnlistenerAttrChange(callback)
	self:RemoveListener(PlayerData.ATTR_EVENT, callback)
end

function PlayerData:GetRoleBaseProf(prof)
	prof = prof or self.role_vo.prof
	return prof % 10, math.floor(prof / 10)
end

-- -- 屏蔽根据等级算出转生
-- function PlayerData.GetLevelAndRebirth(level)
-- 	if nil == level then
-- 		return 0, 0
-- 	end
-- 	return (level - 1) % 100 + 1, math.floor((level - 1) / 100)
-- end

function PlayerData.GetLevelAndRebirth(level)
	if nil == level then
		return 0, 0
	end
	return level, 0
end

function PlayerData:GetRoleLevel()
	local sub_level, rebirth = PlayerData.GetLevelAndRebirth(self.role_vo.level)
	return self.role_vo.level, sub_level, rebirth
end

function PlayerData.GetLevelString(level, small)
	local sub_level, rebirth = PlayerData.GetLevelAndRebirth(level)
	if small then
		return string.format(Language.Common.LevelFormat2, sub_level, rebirth)
	end
	return string.format(Language.Common.LevelFormat, sub_level, rebirth)
	-- return sub_level
end

-- 根据经验获取当前经验的等级
function PlayerData:GetRoleLevelByExp(exp)
	local role_exp_cfg = ConfigManager.Instance:GetAutoConfig("roleexp_auto").exp_config or {}
	local temp = exp
	for i = self.role_vo.level, #role_exp_cfg do
		if temp > role_exp_cfg[i].exp then
			temp = temp - role_exp_cfg[i].exp
		else
			return role_exp_cfg[i].level or 1
		end
	end
	return 1
end

--获得职业名字
function PlayerData.GetProfNameByType(prof_type, is_gray)
	local prof_name = ""
	if is_gray then
		prof_name = ToColorStr(Language.Common.ProfName[prof_type] or "", COLOR.GREY)
	else
		prof_name = ToColorStr(Language.Common.ProfName[prof_type] or "", PROF_COLOR[prof_type])
	end
	return prof_name
end

function PlayerData:SetExpExtraPer(value)
	self.exp_extra_per = value
end

function PlayerData:GetExpExtraPer()
	return self.exp_extra_per
end

-- 根据属性类型获得属性名字。名字参照game_vo.lua中的RoleVo
local attr_name_list = nil
function PlayerData.GetRoleAttrNameByType(type)
	if attr_name_list == nil then
		attr_name_list = {
			[GameEnum.FIGHT_CHARINTATTR_TYPE_HP] = "hp",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_MP] = "mp",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_MAXHP] = "max_hp",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_MAXMP] = "max_mp",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_GONGJI] = "gong_ji",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_FANGYU] = "fang_yu",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_MINGZHONG] = "ming_zhong",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_SHANBI] = "shan_bi",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_BAOJI] = "bao_ji",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_JIANREN] = "jian_ren",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_MOVE_SPEED] = "move_speed",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_FUJIA_SHANGHAI] = "fujia_shanghai",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_DIKANG_SHANGHAI] = "dikang_shanghai",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_JINGZHUN] = "per_jingzhun",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_BAOJI] = "per_baoji",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_KANGBAO] = "per_kangbao",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_POFANG] = "per_pofang",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_MIANSHANG] = "per_mianshang",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_IGNORE_FANGYU] = "ignore_fangyu",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_HURT_INCREASE] = "hurt_increase",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_HURT_REDUCE] = "hurt_reduce",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_ICE_MASTER] = "ice_master",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_FIRE_MASTER] = "fire_master",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_THUNDER_MASTER] = "thunder_master",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_POISON_MASTER] = "poison_master",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_XIXUE] = "per_xixue",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_STUN] = "per_stun",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_MINGZHONG] = "per_mingzhong",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_SHANBI] = "per_shanbi",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_PVP_HURT_INCREASE] = "per_pvp_hurt_increase",
			[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_PVP_HURT_REDUCE] = "per_pvp_hurt_reduce",

			[GameEnum.BASE_CHARINTATTR_TYPE_MAXHP] = "base_max_hp",
			[GameEnum.BASE_CHARINTATTR_TYPE_GONGJI] = "base_gongji",
			[GameEnum.BASE_CHARINTATTR_TYPE_FANGYU] = "base_fangyu",
			[GameEnum.BASE_CHARINTATTR_TYPE_MINGZHONG] = "base_mingzhong",
			[GameEnum.BASE_CHARINTATTR_TYPE_SHANBI] = "base_shanbi",
			[GameEnum.BASE_CHARINTATTR_TYPE_BAOJI] = "base_baoji",
			[GameEnum.BASE_CHARINTATTR_TYPE_JIANREN] = "base_jianren",
			[GameEnum.BASE_CHARINTATTR_TYPE_MOVE_SPEED] = "base_move_speed",
			[GameEnum.BASE_CHARINTATTR_TYPE_FUJIA_SHANGHAI] = "base_fujia_shanghai",
			[GameEnum.BASE_CHARINTATTR_TYPE_DIKANG_SHANGHAI] = "base_dikang_shanghai",
			[GameEnum.BASE_CHARINTATTR_TYPE_PER_JINGZHUN] = "base_per_jingzhun",
			[GameEnum.BASE_CHARINTATTR_TYPE_PER_BAOJI] = "base_per_baoji",
			[GameEnum.BASE_CHARINTATTR_TYPE_PER_KANGBAO] = "base_per_kangbao",
			[GameEnum.BASE_CHARINTATTR_TYPE_PER_POFANG] = "base_per_pofang",
			[GameEnum.BASE_CHARINTATTR_TYPE_PER_MIANSHANG] = "base_per_mianshang",
			[GameEnum.BASE_HURT_INCREASE] = "base_hurt_increase",
			[GameEnum.BASE_HURT_REDUCE] = "base_hurt_reduce",
			[GameEnum.BASE_ICE_MASTER] = "base_ice_master",
			[GameEnum.BASE_FIRE_MASTER] = "base_fire_master",
			[GameEnum.BASE_THUNDER_MASTER] = "base_thunder_master",
			[GameEnum.BASE_POISON_MASTER] = "base_poison_master",
			[GameEnum.BASE_CHARINTATTR_TYPE_IGNORE_FANGYU] = "base_ignore_fangyu",
			[GameEnum.BASE_PER_PVP_HURT_INCREASE] = "base_per_pvp_hurt_increase",
			[GameEnum.BASE_PER_PVP_HURT_REDUCE] = "base_per_pvp_hurt_reduce",
			[GameEnum.BASE_CHARINTATTR_TYPE_PER_SHANBI] = "base_per_shanbi",
			[GameEnum.BASE_CHARINTATTR_TYPE_PER_XIXUE] = "base_per_xixue",
			[GameEnum.BASE_CHARINTATTR_TYPE_PER_STUN] = "base_per_stun",
		}
	end
	return attr_name_list[type] or ""
end

--是否足够绑定和非绑定铜币，优先使用绑定的情况
function PlayerData.GetIsEnoughAllCoin(cost_coin)
	if nil == cost_coin then
		return false
	end
	local coin = PlayerData.Instance.role_vo.coin or 0
	local bind_coin = PlayerData.Instance.role_vo.bind_coin or 0
	local all_coin = coin + bind_coin
	return all_coin >= cost_coin
end

--是否足够绑定和非绑定钻石，优先使用绑定的情况
function PlayerData.GetIsEnoughAllGold(cost_gold)
	if nil == cost_gold then
		return false
	end
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local bind_gold = main_vo.bind_gold
	local gold = main_vo.gold
	local all_gold = bind_gold + gold
	return all_gold >= cost_gold
end

--根据属性类型获得服务端属性名字
function PlayerData:GetServerRoleAttrNameByType(type)
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
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_JINGZHUN] = "per_jingzhun"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_BAOJI] = "per_baoji"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_KANGBAO] = "per_kangbao"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_POFANG] = "per_pofang"
		self.sever_attr_name[GameEnum.FIGHT_CHARINTATTR_TYPE_PER_MIANSHANG] = "per_mianshang"

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
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_PER_JINGZHUN] = "per_jingzhun"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_PER_BAOJI] = "per_baoji"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_PER_KANGBAO] = "per_kangbao"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_PER_POFANG] = "per_pofang"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_PER_MIANSHANG] = "per_mianshang"
		self.sever_attr_name[GameEnum.BASE_CHARINTATTR_TYPE_IGNORE_FANGYU] = "base_ignore_fangyu"
	end
	return type and self.sever_attr_name[type] or self.sever_attr_name
end

-- 获取角色等级属性经验配置
function PlayerData.GetRoleExpCfgByLv(lv)
	lv = lv or PlayerData.Instance.role_vo.level
	return ConfigManager.Instance:GetAutoConfig("roleexp_auto").exp_config[lv]
end

-- 获取某已转生配置
function PlayerData:GetZsCfgByZsLevel(zhuansheng_level)
	local zhuansheng_cfg = ConfigManager.Instance:GetAutoConfig("zhuansheng_cfg_auto").zhuansheng_attr_cfg
	for k,v in pairs(zhuansheng_cfg) do
		if zhuansheng_level == v.zhuansheng_level then
			return v
		end
	end
	return nil
end

function PlayerData:GetCurLevelzhuan()
	local _, _, cur_zhuan = PlayerData.Instance:GetRoleLevel()
	return cur_zhuan
end

function PlayerData:GetCurLevel()
	local _, cur_level, _ = PlayerData.Instance:GetRoleLevel()
	return cur_level
end

--获取是否可以转生的状态
function PlayerData:GetZhuanShengStatus(cur_zhuan)
	local flag = 0
	local cur_zhuan_cfg = self:GetZsCfgByZsLevel(cur_zhuan)
	local now_level = self:GetCurLevel()
	local next_zhuan_cfg = self:GetZsCfgByZsLevel(cur_zhuan+ 1)

	if next_zhuan_cfg == nil then
		flag = 10000 			--满级
	elseif now_level % 100 ~= 0 then
		flag = 10000 + 1	   --等级不足
	elseif next_zhuan_cfg.nv_wa_shi > PlayerData.Instance.role_vo.nv_wa_shi then
		flag = 10000 + 1 * 10 	--女娲石不足
	elseif not PlayerData.GetIsEnoughAllCoin(next_zhuan_cfg.coin) then
		flag = 10000 + 1 * 100 	--金币不足
	end

	if flag ~= 0 then	--若不能转生直接返回
		return flag
	end

	return flag
end

function PlayerData:CanRebirth()
	local cur_zhuan = self:GetCurLevelzhuan()
	local flag = self:GetZhuanShengStatus(cur_zhuan)
	--满级
	if flag == 10000 then
		return false
	end
	--等级不足
	if flag == 10001 then
		return false
	end
	return true
end

function PlayerData:GetRoleZhanli()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local power = vo.max_hp * 0.1 + vo.gong_ji * 2 + vo.fang_yu * 2 + vo.ming_zhong + vo.shan_bi + vo.bao_ji + vo.jian_ren + GoddessData.Instance:GetXiannvGongji()
	return power
end

function PlayerData:GetAvatarChangeRemind()
	local level = GameVoManager.Instance:GetMainRoleVo().level
	return (level >= GameEnum.AVTAR_REMINDER_LEVEL and not TipsPortraitView.HasOpen and 0 == GameVoManager.Instance:GetMainRoleVo().is_change_avatar) and 1 or 0
end

function PlayerData:GetInfoRedPoint()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	if vo.is_change_avatar == 0 then
		return true
	end
	return false
end

--服务器在不同阶段有不同的奖励配置表，用这个方法来读相应的配置表
function PlayerData:GetCurrentRandActivityConfig()
	return ServerActivityData.Instance:GetCurrentRandActivityConfig()
end

function PlayerData:GetCheckCfg()
	-- local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local role_level = 999
	local prof = PlayerData.Instance:GetRoleBaseProf()
	local check_cfg = ConfigManager.Instance:GetAutoConfig("equipment_strategy_auto").equipment
	for i,v in ipairs(check_cfg) do
		if role_level < v.role_level then
			return v["purple_equip_".. prof], v["orange_equip_".. prof], v["red_equip_".. prof]
		end
	end
	return 0, 0, 0
end

-- 获取服务器等级配置
function PlayerData:GetSeverLevelCfg(level)
	if self.server_level_cfg then
		-- for i,v in ipairs(self.server_level_cfg) do
		-- 	if level == v.seq then
		-- 		return v
		-- 	end
		-- end
		if nil ~= self.get_server_level_cfg[level] then
			return self.get_server_level_cfg[level]
		end
		return self.server_level_cfg[#self.server_level_cfg]
	end
end

-- 获取提醒等级
function PlayerData:GetRemindLevelCfg()
	if self.remind_level_cfg == nil then
		self.remind_level_cfg = ConfigManager.Instance:GetAutoConfig("other_config_auto").remind_level
	end
	return self.remind_level_cfg
end

function PlayerData:GetSeverMaxLevelCfg()
	return self.server_level_cfg[#self.server_level_cfg]
end

function PlayerData:GetResetNameNeedGold()
	 local gold_cfg = ConfigManager.Instance:GetAutoConfig("other_config_auto").other[1]
	if gold_cfg then
		return gold_cfg.reset_name_need_gold
	end
	return 0
end

-- 设置世界等级信息
function PlayerData:SetServerLevelInfo(protocol)
	self.world_level = protocol.world_level
	self.cur_server_level_seq = protocol.cur_server_level_seq
	self.cur_server_level = protocol.cur_server_level
	self.cur_satify_role_num = protocol.cur_satify_role_num
	self.server_level_auto_uplevel_last_days = protocol.server_level_auto_uplevel_last_days
end

-- 服务器等级信息
function PlayerData:GetServerLevelInfo()
	return self.cur_server_level_seq, self.cur_satify_role_num, self.server_level_auto_uplevel_last_days
end

-- 获取服务器等级
function PlayerData:GetServerLevel()
	return self.cur_server_level
end

-- 世界等级
function PlayerData:GetWorldLevel()
	return self.world_level
end

function PlayerData:GetSexByProf(prof)
	local sex = GameEnum.MALE
	if prof == GameEnum.ROLE_PROF_2 or prof == GameEnum.ROLE_PROF_4 then
		sex = GameEnum.FEMALE
	end
	return sex
end

function PlayerData:SetTotalChongZhiInfo(protocol)
	self.total_chongzhi = protocol.total_chongzhi
end

function PlayerData:GetTotalChongZhi()
	return self.total_chongzhi or 0
end

function PlayerData:SetOriginOpenDay(open_day)
	self.origin_open_day = open_day
end

function PlayerData:GetOriginOpenDay()
	return self.origin_open_day
end