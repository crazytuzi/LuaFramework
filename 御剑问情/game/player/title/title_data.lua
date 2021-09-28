-------------------------------------------
--主角称号数据
--------------------------------------------
MAX_TITLE_COUNT_TO_SAVE = 200 -- 保存进阶称号最大数量
ACTIVE_TITLE = 0			  -- 活动称号
SPECIAL_TITLE = 1 			  -- 特殊称号
NO_TITLE = 2 				  -- 不计入称号
TITLE_SOURCE_TYPE = {
	TITLE_CARDS = 1,	-- 称号卡
	RANK = 2,			-- 排行榜
	ACTIVITY = 3,		-- 活动
	ZHEN_MO_TA = 4,		-- 镇魔塔
	OTHER = 5,			-- 其他
	PATA_FB = 7,		-- 爬塔副本
	SPIRIT = 8,			-- 精灵
}

TitleData = TitleData or BaseClass()

function TitleData:__init()
	if TitleData.Instance then
		print_error("[TitleData] Attemp to create a singleton twice !")
		return
	end
	TitleData.Instance = self
	self.title_list = {}
	self.use_jingling_titleid = 0
	self.count = 0
	self.used_title_list = {}   --正在使用中的称号
	self.obj_id = 0
	self.is_operate = false
	self.title_cfg = ConfigManager.Instance:GetAutoConfig("titleconfig_auto")
	self.title_list_cfg = ListToMap(self.title_cfg.title_list, "title_id")
	self.upgrade_cfg = ListToMapList(self.title_cfg.upgrade, "title_id")
	self.title_other_cfg = self.title_cfg.other_title_list

	self.first_title_id = self.title_cfg.title_list[1].title_id

	local cfg = self:GetAllTitleCfg()
	self.active_title_id_cfg = {}
	self.special_title_id_cfg = {}
	for k,v in ipairs(cfg) do
		if v.title_type == ACTIVE_TITLE then
			table.insert(self.active_title_id_cfg, v.title_id)
		elseif v.title_type == SPECIAL_TITLE then
			table.insert(self.special_title_id_cfg, v.title_id)
		end
	end


	self.upgrade_list = {}
	RemindManager.Instance:Register(RemindName.PlayerTitle, BindTool.Bind(self.GetPlayerTitleRemind, self))
end

function TitleData:__delete()
	RemindManager.Instance:UnRegister(RemindName.PlayerTitle)

	TitleData.Instance = nil
	self.title_cfg = {}
	self.upgrade_list = {}
	TitleData.Instance = nil
end

function TitleData:OnTitleList(protocol) ----获得新称号时回调 或者 主动请求时回调 查看已激活的称号
	self.title_list = protocol.title_list
	self.upgrade_list = protocol.upgrade_list
end

function TitleData:OnUsedTitleList(protocol) --进入游戏时回调同步称号 用来初始化称号佩戴情况
	self.use_jingling_titleid = protocol.use_jingling_titleid
	self.count = protocol.count
	self.used_title_list = protocol.used_title_list
end

function TitleData:OnRoleUsedTitleChange(protocol) --穿戴称号时
	self.obj_id = protocol.obj_id
	self.use_jingling_titleid = protocol.use_jingling_titleid
	self.count = protocol.count
	-- 这里必须使用TableCopy，因为视野内其他人称号变更也会进这条协议
	self.used_title_list = TableCopy(protocol.title_active_list)
end

function TitleData:GetFirstTitleId()
	return self.first_title_id
end

--获取单个称号配置
function TitleData:GetTitleCfg(id)
	return self.title_list_cfg[id]
end

-- function TitleData:GetPataShowTitle()
-- 	local pata_title_id = 0
-- 	for k, v in pairs(self.title_cfg.patafb_title) do
-- 		for i, j in ipairs(self.title_list) do
-- 			if v.title_id == j.title_id then
-- 				pata_title_id = v.title_id
-- 				break
-- 			end
-- 		end
-- 	end
-- 	table.sort(self.title_cfg.patafb_title, function(a, b)
-- 		return a.title_id < b.title_id
-- 	end)
-- 	if pata_title_id == 0 then
-- 		pata_title_id = self.title_cfg.patafb_title[1].title_id
-- 	end

-- 	return self:GetTitleCfg(pata_title_id)
-- end

-- function TitleData:IsPataFbTitle(title_id)
-- 	if not title_id then return false end

-- 	for k, v in pairs(self.title_cfg.patafb_title) do
-- 		if v.title_id == title_id then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

--获取所有称号配置
function TitleData:GetAllTitleCfg()
	local list =  {}
	for k, v in pairs(self.title_cfg.title_list) do
		if not self:IsLingPoTitle(v.title_id) then
			table.insert(list, v)
		end
	end
	-- table.insert(list, self:GetPataShowTitle())
	return list
end

--获得称号信息
function TitleData:GetTitleInfo()
	local info = {}
	info.used_title_list = self.used_title_list
	info.title_list = self.title_list
	return info
end

function TitleData:GetTitleType(title_id)
	local cfg = self:GetAllTitleCfg()
	for _,v in ipairs(cfg) do
		if title_id == v.title_id then
			return v.title_type
		end
	end
	return nil
end

function TitleData:GetDefTitleType()
	local use_title = self:GetUsedTitle()
	if use_title ~= 0 then
		local title_type = self:GetTitleType(use_title)
		if title_type ~= NO_TITLE then
			return title_type
		end
	end

	if #self.title_list == 0 then
		return SPECIAL_TITLE
	end
	for _,v in pairs(self.title_list) do
		if not self:IsLingPoTitle(v.title_id) and self:GetTitleType(v.title_id) == SPECIAL_TITLE then
			return SPECIAL_TITLE
		end
	end
	return ACTIVE_TITLE
end

--获得激活后的数据排序
function TitleData:ResortTitleIdList(title_type)
	local all_title_list = self:GetAllTitle(title_type) or {}
	-- for k,v in pairs(self:GetAllTitleCfg()) do
	-- 	all_title_list[k] = v.title_id
	-- end

	if #self.title_list == 0 then
		return all_title_list
	else
		local new_list = {}
		for k,v in pairs(self.title_list) do
			if not self:IsLingPoTitle(v.title_id) then
				--new_list[k] = v.title_id
				for i,v1 in ipairs(all_title_list) do
					if v1 == v.title_id then
						table.insert(new_list,v.title_id)
					end
				end
			end
		end
		for k,v in pairs(all_title_list) do
			local is_ok = true
			for m,n in pairs(self.title_list) do
				if n.title_id == v then
					is_ok = false
				end
			end
			if is_ok then
				new_list[#new_list + 1] = v
			end
		end
		return new_list
	end
end

function TitleData:GetTitlePower(title_id)
	local cfg = self:GetTitleCfg(title_id)
	local zhan_li = cfg.maxhp * 0.2 * (1 + 0 * 1) + cfg.gongji * 3.1 * (1 + 0 * 0.3) * (1 + 0 * 0.8) * (1 + 0 *1.3) + cfg.fangyu * 1.3 + 0 * 0.3 + 0 * 0.4 + 0 * 0.9 + 0 * 0.7 + 0 * 1.6
	return zhan_li
end

function TitleData:SortShowTitle(title_list)
	function sortfun(a, b)
		local cfg_1 = self:GetTitleCfg(a)
		local cfg_2 = self:GetTitleCfg(b)
		local title_show_level1 = 0
		local title_show_level2 = 0
		if cfg_1 then
			title_show_level1 = cfg_1.title_show_level
		end
		if cfg_2 then
			title_show_level2 = cfg_2.title_show_level
		end
		return title_show_level1 >= title_show_level2
	end
	table.sort(title_list, sortfun)
	return title_list
end

--称号激活
function TitleData:GetTitleActiveState(title_id)
	local is_active = false
	for k,v in pairs(self.title_list) do
		if v.title_id == title_id then
			is_active = true
		end
	end
	return is_active
end

function TitleData:GetAllTitle(title_type)
	if title_type == ACTIVE_TITLE then
		return self.active_title_id_cfg
	elseif title_type == SPECIAL_TITLE then
		return self.special_title_id_cfg
	end
end

function TitleData:GetIsUsed(title_id)
	for k,v in pairs(self.used_title_list) do
		if v == title_id then
			return true
		end
	end
	return false
end

function TitleData:GetUsedTitle()
	if next(self.used_title_list) then
		return self.used_title_list[1]
	end
	return 0
end

function TitleData:GetCanAdorn(the_list)
	for k,v in pairs(self.title_list) do
		for m,n in pairs(the_list) do
			if n == v.title_id then
				return true
			end
		end
	end
	return false
end

function TitleData:GetUpgradeList()
	local list = {}
	for k, v in pairs(self.upgrade_cfg) do
		table.insert(list, v[1])
	end

	return list
end

-- 获取称号级数
function TitleData:GetTitleGrade(title_id)
	for k, v in pairs(self.upgrade_list) do
		if v.title_id == title_id then
			return v.grade
		end
	end

	return 0
end

function TitleData:GetUpgradeCfg(title_id, is_next)
	if not title_id then return end

	local list_cfg = self.upgrade_cfg[title_id]
	if nil == list_cfg then
		return
	end

	local grade = self:GetTitleGrade(title_id)
	if is_next then
		grade = grade + 1
	else
		grade = grade > 0 and grade or 1
	end

	return list_cfg[grade]
end

function TitleData:GetPlayerTitleRemind()
	return self:IsShowJinjieRedPoint() and 1 or 0
end

function TitleData:IsShowJinjieRedPoint()
	for k, v in pairs(self.upgrade_cfg) do
		local grade = self:GetTitleGrade(k)

		local level_cfg = v[grade + 1]
		if nil ~= level_cfg and ItemData.Instance:GetItemNumInBagById(level_cfg.stuff_id) >= level_cfg.stuff_num then
			return true
		end
	end

	return false
end

function TitleData:GetShowAttrList()
	local title_list = self:GetTitleInfo().title_list
	local all_attack_value = 0
	local all_defense_value = 0
	local all_hp_value = 0
	local all_power_value = 0
	for k,v in pairs(title_list) do
		local cfg = self:GetUpgradeCfg(v.title_id) or self:GetTitleCfg(v.title_id)
		all_attack_value = all_attack_value + cfg.gongji
		all_defense_value = all_defense_value + cfg.fangyu
		all_hp_value = all_hp_value + cfg.maxhp
		all_power_value = all_power_value + CommonDataManager.GetCapabilityCalculation(cfg)--TitleData.Instance:GetTitlePower(v)
	end
	local attr = {}
	attr.attack = all_attack_value
	attr.defense = all_defense_value
	attr.hp = all_hp_value
	attr.power = all_power_value
	return attr
end

function TitleData:GetRankTitle(sex, cur_type)
	if cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_CHARM then
		if sex == 1 then
			return self.title_other_cfg[3].title_id
		else
			return self.title_other_cfg[4].title_id
		end
	elseif cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_WORLD_RIGHT_ANSWER then
		return self.title_other_cfg[5].title_id
	elseif cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_DAY_QingYuan then
		return self.title_other_cfg[9].title_id
	elseif cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_BAOBAO then
		return self.title_other_cfg[10].title_id
	elseif cur_type == PERSON_RANK_TYPE.PERSON_RANK_TYPE_LITTLEPET then
		return self.title_other_cfg[11].title_id
	end
end

function TitleData:ConvertTime(next_time)
	local cur_time = TimeCtrl.Instance:GetServerTime()
	local time_list = TimeUtil.Timediff(next_time,cur_time)
	if time_list.day > 0 then
		return string.format(Language.Time.RemainDay, time_list.day, time_list.hour)
	end

	if time_list.hour > 0 then
		return string.format(Language.Time.RemindHour, time_list.hour, time_list.min)
	end

	if time_list.min > 0 then
		return string.format(Language.Time.RemainMinRed, time_list.min, time_list.sec)
	end

	if time_list.sec > 0 then
		return string.format(Language.Time.RemainSecRed, time_list.sec)
	end
end

function TitleData:GetTitleAddBuffList(title_id)
	local find_name_list = {"maxhp_add_per", "gongji_add_per", "fangyu_add_per"}
	local cfg = TitleData.Instance:GetTitleCfg(title_id)
	local data = {0,0,0}
	if not cfg then return data end
	for k,v in pairs(find_name_list) do
		data[k] = cfg[v]
	end
	return data
end

function TitleData:GetCurTitleId()
	local use_id = self:GetUsedTitle()
	if use_id ~= 0 then
		return use_id
	end

	if next(self.title_list) then
		for k,v in pairs(self.title_list) do
			if not self:IsLingPoTitle(v.title_id) then
				return v.title_id
			end
		end
	end

	return self.first_title_id
end

function TitleData:GetLingPoTitleCfg()
	if nil == self.jingling_card_title then
		self.jingling_card_title = self.title_cfg.jingling_card_title
		table.sort(self.jingling_card_title, function(a, b)
			return a.level < b.level
		end)
	end
	return self.jingling_card_title
end

--获取精灵灵魄称号
function TitleData:GetLingPoTitleId(level)
	--小于5级显示第一层
	local cfg_1 = self.title_cfg.jingling_card_title[1]
	if level < cfg_1.level then
		return cfg_1.title_id, cfg_1.level
	end

	--大于最大级显示最大层
	local cfg_max = self.title_cfg.jingling_card_title
	if level >= cfg_max[#cfg_max].level then
		return cfg_max[#cfg_max].title_id, cfg_max[#cfg_max].level
	end

	for k,v in ipairs(self.title_cfg.jingling_card_title) do
		if v.level > level then
			return v.title_id, v.level
		end
	end

	return cfg_1[1].title_id, cfg_1[1].level
end

--获取精灵灵魄称号
function TitleData:GetLingPoNowTitleId(level)
	--小于5级显示第一层
	local cfg_1 = self.title_cfg.jingling_card_title[1]
	if level < cfg_1.level then
		return cfg_1.title_id, cfg_1.level
	end

	--大于最大级显示最大层
	local cfg_max = self.title_cfg.jingling_card_title
	if level >= cfg_max[#cfg_max].level then
		return cfg_max[#cfg_max].title_id, cfg_max[#cfg_max].level
	end

	for k,v in ipairs(self.title_cfg.jingling_card_title) do
		if v.level > level then
			return v.title_id - 1, v.level - 1
		end
	end

	return cfg_1[1].title_id, cfg_1[1].level
end

--获取精灵灵魄称号最大等级限制
function TitleData:GetLingPoMaxLevel()
	local max_cfg = self.title_cfg.jingling_card_title
	local t = max_cfg[#max_cfg]
	return t.level, t.title_id
end

function TitleData:GetLingPoTitleMaxCfg()
	local temp_level = 0
	local temp_cfg = nil
	local card_cfg = self:GetLingPoTitleCfg()
	for k, v in pairs(card_cfg) do
		if v.level >= temp_level then
			temp_level = v.level
			temp_cfg = v
		end
	end
	return temp_cfg
end

function TitleData:IsLingPoTitle(title_id)
	if nil == title_id then return false end

	local card_cfg = self:GetLingPoTitleCfg()
	for k, v in ipairs(card_cfg) do
		if v.title_id == title_id then
			return true
		end
	end
	return false
end

function TitleData:IsActiveLingPoTitle()
	for k, v in pairs(self.title_list) do
		if self:IsLingPoTitle(v.title_id) then
			return true, v.title_id
		end
	end
	return false, 0
end

function TitleData:GetActivityTitleByType(activity_type)
  for k, v in pairs(self.title_cfg.activity_tilte_list) do
    if activity_type == v.activity_type then
      return v.title_id
    end
  end
  return nil
end

function TitleData:GetArenaCfg()
	return self.title_cfg.challenge_field
end