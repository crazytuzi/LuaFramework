-------------------------------------------
--主角称号数据
--------------------------------------------
MAX_TITLE_COUNT_TO_SAVE = 120 -- 保存进阶称号最大数量

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
	self.title_id_list = {}
	self.use_jingling_titleid = 0
	self.count = 0
	self.used_title_list = {}   --正在使用中的称号
	self.obj_id = 0
	self.is_operate = false
	self.title_cfg = ConfigManager.Instance:GetAutoConfig("titleconfig_auto")
	
	self.title_list_cfg = ListToMap(self.title_cfg.title_list, "title_id")
	self.upgrade_rank_cfg = ListToMapList(self.title_cfg.upgrade, "rank")
	self.upgrade_cfg = ListToMapList(self.title_cfg.upgrade, "title_id")


	self.first_title_id = self.title_cfg.title_list[1].title_id

	local cfg = self:GetAllTitleCfg()
	self.all_title_id_cfg = {}
	for k,v in ipairs(cfg) do
		table.insert(self.all_title_id_cfg, v.title_id)
	end

	self.upgrade_list = {}
	RemindManager.Instance:Register(RemindName.PlayerTitle, BindTool.Bind(self.GetPlayerTitleRemind, self))

end

function TitleData:__delete()
	RemindManager.Instance:UnRegister(RemindName.PlayerTitle)
	
	TitleData.Instance = nil
	self.title_cfg = {}
	self.upgrade_list = {}
end

function TitleData:OnTitleList(protocol) ----获得新称号时回调 或者 主动请求时回调 查看已激活的称号
	self.title_id_list = protocol.title_id_list
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
	self.used_title_list = protocol.title_active_list
end

function TitleData:GetFirstTitleId()
	return self.first_title_id
end

--获取单个称号配置
function TitleData:GetTitleCfg(id)
	return self.title_list_cfg[id]
end

function TitleData:GetTitleNum()
	local num = 0
	if self.title_list_cfg ~= nil then
		for k,v in pairs(self.title_list_cfg) do
			if v ~= nil then
				num = num + 1
			end
		end
	end

	return num
end

function TitleData:GetPataShowTitle()
	local pata_title_id = 0
	for k, v in pairs(self.title_cfg.patafb_title) do
		for i, j in ipairs(self.title_id_list) do
			if v.title_id == j then
				pata_title_id = v.title_id
				break
			end
		end
	end
	table.sort(self.title_cfg.patafb_title, function(a, b)
		return a.title_id < b.title_id
	end)
	if pata_title_id == 0 then
		if self.title_cfg.patafb_title[1] then
			pata_title_id = self.title_cfg.patafb_title[1].title_id
		end
	end

	return self:GetTitleCfg(pata_title_id)
end

function TitleData:IsPataFbTitle(title_id)
	if not title_id then return false end

	for k, v in pairs(self.title_cfg.patafb_title) do
		if v.title_id == title_id then
			return true
		end
	end
	return false
end

--获取所有称号配置
function TitleData:GetAllTitleCfg()
	local list =  {}
	local vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in pairs(self.title_cfg.title_list) do
		if not self:IsPataFbTitle(v.title_id) and (v.country == 4 or vo.camp == v.country) then
			table.insert(list, v)
		end
	end
	table.insert(list, self:GetPataShowTitle())
	return list
end

--获得称号信息
function TitleData:GetTitleInfo()
	local info = {}
	info.used_title_list = self.used_title_list
	info.title_id_list = self.title_id_list
	return info
end

--根据牛逼值获取id
function TitleData:GetTitleIdByShowLevelAndGongji(show_level,gongji)
	local all_title_list = self.title_cfg.title_list
	for k,v in pairs(all_title_list) do
		if v.title_show_level == show_level and v.gongji == gongji then
			return v.title_id
		end
	end
end

--获得激活后的数据排序
function TitleData:ResortTitleIdList()
	local spid = ChannelAgent.GetChannelID()
	local all_title_id_list = {}
	local index = 1
	for k,v in pairs(self:GetAllTitleCfg()) do
		local spid_list = Split(v.show_spid, ",")
		if spid_list ~= nil and next(spid_list) ~= nil then
			while true do
				for k1, v1 in pairs(spid_list) do
					if v1 ~= nil and spid ~= nil and (v1 == spid or v1 == "all") then
						all_title_id_list[index] = v.title_id
						index = index + 1
						break
					end
				end

				break
		 	end
		else
			all_title_id_list[k] = v.title_id
			index = index + 1
		end
	end
	if #self.title_id_list == 0 then
		return all_title_id_list
	else
		local new_list = {}
		for k,v in pairs(self.title_id_list) do
			new_list[k] = v
		end
		for k,v in pairs(all_title_id_list) do
			local is_ok = true
			for m,n in pairs(self.title_id_list) do
				if n == v then
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

function TitleData:SortShowTitle(title_id_list)
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
	table.sort(title_id_list, sortfun)
	return title_id_list
end

--称号激活
function TitleData:GetTitleActiveState(title_id)
	local is_active = false
	for k,v in pairs(self.title_id_list) do
		if v == title_id then
			is_active = true
		end
	end
	return is_active
end

function TitleData:GetAllTitle()
	return self.all_title_id_cfg
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
	return self.used_title_list[1]
end


function TitleData:GetCanAdorn(the_list)
	for k,v in pairs(self.title_id_list) do
		for m,n in pairs(the_list) do
			if n == v then
				return true
			end
		end
	end
	return false
end


function TitleData:GetUpgradeList()
	local countryIndex = GameVoManager.Instance:GetMainRoleVo().camp
	local list = {}
	--根据角色身份屏蔽称号
	for k, v in pairs(self.upgrade_rank_cfg) do
		if v[1].camp_limit==countryIndex or v[1].camp_limit==0 then
			table.insert(list,v[1])
		end
	end
	--根据攻击力排序
	SortTools.SortAsc(list, "rank")
	

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

function TitleData:SetToTitleId(title_id)
	for k,v in pairs(self:GetUpgradeList()) do
		if v.stuff_id == title_id then
			self.to_title_id = k
		end
	end
end

function TitleData:GetToToTitleId()
	return self.to_title_id or 1
end

function TitleData:GetIsActivateTitleId(title_id)
	for k,v in pairs(self.title_id_list) do
		if v == title_id then
			return true
		end
	end
	return false
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
	local title_id_list = self:GetTitleInfo().title_id_list
	local all_attack_value = 0
	local all_defense_value = 0
	local all_hp_value = 0
	local all_power_value = 0
	for k,v in pairs(title_id_list) do
		local cfg = self:GetUpgradeCfg(v) and self:GetUpgradeCfg(v) or self:GetTitleCfg(v)
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