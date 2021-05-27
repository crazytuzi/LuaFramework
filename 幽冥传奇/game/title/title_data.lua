-------------------------------------------
--主角称号数据
--------------------------------------------

TitleData = TitleData or BaseClass(BaseData)

TITLE_TYPE = {
	TEMPORARY = 0,
	FOREVER = 1,
	TIME_LIMIT = 2,
	CUSTOM = 3, -- 定制称号
}


TITLE_CLIENT_CONFIG = CLIENT_GAME_GLOBAL_CFG.title_client_config or {}

TITLE_REQ = {
	INFO = 1,
	SELECT = 2
}

TitleData.TITLE_LEVEL_DATA_CHANGE = "TITLE_LEVEL_DATA_CHANGE" -- 称号等级数据改变

function TitleData:__init()
	if TitleData.Instance then
		ErrorLog("[TitleData] Attemp to create a singleton twice !")
	end
	TitleData.Instance = self

	self.all_title_list = {}
	self.tem_title_list = {} 			--临时称号
	self.for_title_list = {}			--永久称号
	self.title_act_t = {}				--称号激活标志列表
	self.custom_title_list = {}			--定制称号
	self.title_over_times = {}
	-- self.title_info = {
	-- 	title_sign = 0,    --称号标记
	-- 	loading_days = 0, 
	-- 	xunbao_add_consume_gold = 0,  --探索宝藏累计消费达到多少元宝
	-- 	get_gold_50000 = 0,   --累计获得500000绑定元宝
	-- 	faction_battle_kill_people = 0,  --阵营战击杀人数
	-- 	consume_gold_count = 0,  --消耗元宝数
	-- }
	self.title_act_t = {}
	self:InitAllTitlelist()

	-- 初始化称号升级配置
	self.title_upgrade_cfg = {}
	for i,v in ipairs(TitleUpgradeConfig) do
		self.title_upgrade_cfg[v.titleId] = v
	end

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex, self), RemindName.FashionTitle)
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function TitleData:__delete()
	TitleData.Instance = nil
	self.all_title_list = nil
end

--------------------------称号

function TitleData:InitAllTitlelist()
	self.all_title_list = {}
	self.tem_title_list = {}
	self.for_title_list = {}
	for i = 1, 100 do
		if TITLE_CLIENT_CONFIG[i] then
			local title_cfg = self.GetHeadTitleConfig(i)
			if nil ~= title_cfg then
				if not title_cfg.Spid or title_cfg.Spid == AgentAdapter:GetSpid() then
					table.insert(self.all_title_list, title_cfg)
					if title_cfg.titleType == TITLE_TYPE.TEMPORARY or title_cfg.titleType == TITLE_TYPE.TIME_LIMIT then
						table.insert(self.tem_title_list, title_cfg)
					elseif title_cfg.titleType == TITLE_TYPE.FOREVER then
						table.insert(self.for_title_list, title_cfg)
					elseif title_cfg.titleType == TITLE_TYPE.CUSTOM then
						table.insert(self.custom_title_list, title_cfg)
					end
				end
			end
		end
	end
end

function TitleData:GetAllTitlelist()
	return self.all_title_list
end

function TitleData.GetHeadTitleConfig(title_id)
	if cc.FileUtils:getInstance():isFileExist("scripts/config/server/config/rank/headTitle/headTitle" .. title_id .. ".lua") then
		return ConfigManager.Instance:GetServerConfig("rank/headTitle/headTitle" .. title_id)[1]
	end
end

-- function TitleData:GetTitleInfo()
-- 	return self.title_info
-- end

function TitleData.GetTitleEffId(title_id)
	local effect_id = nil
	local role_id = GameVoManager.Instance:GetMainRoleVo().role_id
	local effect_list = {}
	if cc.FileUtils:getInstance():isFileExist("scripts/config/client/title/customized_title.lua") then
		effect_list = ConfigManager.Instance:GetClientConfig("title/customized_title")[title_id]
	end
	if nil ~= effect_list then
		for k,v in ipairs(effect_list) do
			if v.role_id == role_id then
				effect_id = v.effect_id
			end
		end
	end
	return effect_id or TITLE_CLIENT_CONFIG[title_id] and TITLE_CLIENT_CONFIG[title_id].effect_id or 0
end

function TitleData.GetCond(title_id)
	if cc.FileUtils:getInstance():isFileExist("scripts/config/client/title/headTitleDesc.lua") then
		return ConfigManager.Instance:GetClientConfig("title/headTitleDesc")[title_id]
	end
end

function TitleData:TitleSort()
	return function (a, b)
		local off_a = 100
		local off_b = 100

		if self:GetTitleActive(a.titleId) ~= 0 then
			off_a = off_a + 10
		end
		if self:GetTitleActive(b.titleId) ~= 0 then
			off_b = off_b + 10
		end
		
		if a.titleId < b.titleId then
			off_a = off_a + 1
		elseif a.titleId > b.titleId then
			off_b = off_b + 1
		end

		return off_a > off_b
	end	
end

-- function TitleData:SetTitleInfo(protocol)
-- 	self.title_info.title_sign = protocol.title_sign
-- 	self.title_info.loading_days = protocol.loading_days
-- 	self.title_info.xunbao_add_consume_gold = protocol.xunbao_add_consume_gold
-- 	self.title_info.get_gold_50000 = protocol.get_gold_50000
-- 	self.title_info.faction_battle_kill_people = protocol.faction_battle_kill_people
-- 	self.title_info.consume_gold_count = protocol.consume_gold_count
-- end

function TitleData:SortTitle()
	table.sort(self.all_title_list, self:TitleSort())
	-- table.sort(self.tem_title_list, self:TitleSort())
	-- table.sort(self.for_title_list, self:TitleSort())
end

function TitleData:GetCustomTitleList()
	return self.custom_title_list
end

function TitleData:GetTitleActList()
	return self.title_act_t
end

function TitleData:SetTitleActList(list)
	self.title_act_t = list
	self:SortTitle()

	RemindManager.Instance:DoRemindDelayTime(RemindName.FashionTitle)
end

function TitleData:GetTitleActive(title_id)
	return self.title_act_t[title_id] or 0
end

function TitleData:SetTitleOverTime(title_id, over_time)
	self.title_over_times[title_id] = over_time
end

function TitleData:GetTitleOverTime(title_id)
	return self.title_over_times[title_id] or -1
end

function TitleData:GetTitleUpgradeCfg(title_id)
	if title_id then
		return self.title_upgrade_cfg[title_id]
	else
		return self.title_upgrade_cfg
	end
end

-- function TitleData.GetTitleAttrCfg(title_id)
-- 	local title_cfg = TitleData.GetHeadTitleConfig(title_id)
-- 	return title_cfg and title_cfg.staitcAttrs
-- end

function TitleData.GetTitleAttrCfg(title_id)
	local title_cfg = TitleData.GetHeadTitleConfig(title_id)
	local attr_list = {}
	if title_cfg and title_cfg.staitcAttrs then
		local prof = RoleData.Instance:GetRoleBaseProf()
		local i = 1
		for k, v in pairs(title_cfg.staitcAttrs) do
			if v.job == prof then
				attr_list[i] = v
				i = i + 1
			end
		end
	end

	local title_lv = TitleData.Instance:GetTitleLevelData(title_id or 0)
	if title_lv > 0 then
		local cfg = TitleData.Instance:GetTitleUpgradeCfg(title_id) or {}
		local level_cfg = cfg.levels or {}
		local cur_level_cfg = level_cfg[title_lv] or {}
		local title_lv_attr = cur_level_cfg.attrs or {}
		attr_list = CommonDataManager.AddAttr(attr_list, title_lv_attr)
	end

	return attr_list
end

function TitleData.GetTitleValidity(title_id)
	local title_cfg = TitleData.GetHeadTitleConfig(title_id)
	return title_cfg and title_cfg.titleType
end

-- 设置称号等级数据 
function TitleData:SetTitleLevelData(protocol)
	-- 格式 {title_id = title_lv, ...}
	self.title_level_list = protocol.title_level_list
	self:DispatchEvent(TitleData.TITLE_LEVEL_DATA_CHANGE)
	RemindManager.Instance:DoRemindDelayTime(RemindName.FashionTitle)
end

function TitleData:GetTitleLevelData(title_id)
	if title_id then
		return self.title_level_list[title_id] or 0
	else
		return self.title_level_list
	end
end

function TitleData:OnBagItemChange(event)
	local need_flush = false
	for i, v in ipairs(event.GetChangeDataList()) do
		if v.change_type == ITEM_CHANGE_TYPE.LIST then
			need_flush = true
		else
			local item_data = v.data or {}
			if item_data.type == ItemData.ItemType.itFunctionItem then
				need_flush = true
			end
		end

		if need_flush then
			RemindManager.Instance:DoRemindDelayTime(RemindName.FashionTitle)
			break
		end
	end
end

function TitleData:GetRemindIndex(remind_name)
	local index = 0
	local data_list = TitleData.Instance:GetAllTitlelist()
	for i, data in ipairs(data_list) do
		if TitleData.Instance:GetTitleActive(data.titleId) == 1 then
			local title_id = data.titleId
			local title_upgrade_cfg = TitleData.Instance:GetTitleUpgradeCfg(title_id)
			if title_upgrade_cfg then
				local title_level = TitleData.Instance:GetTitleLevelData(title_id)
				local levels_cfg = title_upgrade_cfg.levels or {}
				local next_upgrade_cfg = levels_cfg[title_level + 1] or {}
				local consumes = next_upgrade_cfg.consumes
				local can_upgrade = BagData.CheckConsumesCount(consumes)
				if can_upgrade then
					index = 1
					break
				end
			end
		end
	end
	return index
end