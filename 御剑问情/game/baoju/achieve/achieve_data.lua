AchieveData = AchieveData or BaseClass(BaseController)

AchieveRewardFlag = {
	CanNotFetch = 0,
	CanFetch = 1,
	BeFetched = 2,
}
AchieveParam = {
	Normal = 0,
	Different = 1,					 -- 进阶 服务端阶数比客户端大  显示需要减去一阶
}

function AchieveData:__init()
	if AchieveData.Instance then
		print_error("[AchieveData] 尝试创建第二个单例模式")
		return
	end
	AchieveData.Instance = self

	self.reward_info_list = {}
	self.reward_client_cfg = {}
	local reward_cfg = TableCopy(ConfigManager.Instance:GetAutoConfig("chengjiu_auto").reward)
	self.reward_info_list = reward_cfg
	for i, v in ipairs(reward_cfg) do
		self.reward_client_cfg[v.client_type] = self.reward_client_cfg[v.client_type] or {}
		table.insert(self.reward_client_cfg[v.client_type], v)
	end

	self.new_client_cfg = {}
	for k,v in pairs(reward_cfg) do
		if v.client_type and v.client_childtype then
			local data = v
			self.new_client_cfg[v.client_type] = self.new_client_cfg[v.client_type] or {}
			self.new_client_cfg[v.client_type][v.client_childtype] = self.new_client_cfg[v.client_type][v.client_childtype] or {}
			table.insert(self.new_client_cfg[v.client_type][v.client_childtype], data)
			self.new_client_cfg[v.client_type].client_type_str = v.client_type_str
			self.new_client_cfg[v.client_type][v.client_childtype].client_childtype_str = v.client_childtype_str
		end
	end

	--TODO 符文
	self.fuwen_data_list = {}
	self.fuwen_type_list = {}
	local res_id = nil
	local fuwen_cfg = ConfigManager.Instance:GetAutoConfig("chengjiu_auto").fuwen
	for i, v in ipairs(fuwen_cfg) do
		self.fuwen_data_list[v.level] = v
		if res_id == nil or res_id ~= v.res_id then
			res_id = v.res_id
			self.fuwen_type_list[#self.fuwen_type_list + 1] = v
		end
	end
	self.red_point_list = {
		["Title"] = false,
		["Overview"] = false,
	}
	self.reward_list = {}
	self.title_level = 0
	RemindManager.Instance:Register(RemindName.Achieve_Overview, BindTool.Bind(self.GetOverviewRemind, self))
	RemindManager.Instance:Register(RemindName.Achieve_Title, BindTool.Bind(self.GetTitleRemind, self))
end

function AchieveData:__delete()
	RemindManager.Instance:UnRegister(RemindName.Achieve_Overview)
	RemindManager.Instance:UnRegister(RemindName.Achieve_Title)
	AchieveData.Instance = nil
end

-- 服务器成就改变信息
function AchieveData:SetChengJiuRewardInfo(data)
	self.reward_id = data.reward_id
	self.reserve_sh = data.reserve_sh
end

-- 设置头衔等级
function AchieveData:SetTitleLevel(title_level)
	self.title_level = title_level
end

local LevelToColor = {
	[1] = TEXT_COLOR.GREEN,
	[2] = TEXT_COLOR.BLUE,
	[3] = TEXT_COLOR.PURPLE,
	[4] = TEXT_COLOR.ORANGE,
	[5] = TEXT_COLOR.RED,
}

-- 根据等级得到头衔名字的颜色
function AchieveData:GetTitleColor(title_level)
	local color = math.ceil(title_level/25)
	return LevelToColor[color]
end

-- 得到头衔等级x
function AchieveData:GetTitleLevel()
	return self.title_level
end

-- 根据等级得到头衔名字
function AchieveData:GetTitleNameByLevel(level)
	local cfg = self:GetAchieveTitleDataByLevel(level)
	return cfg.show or ""
end

-- 根据等级得到头衔数据
function AchieveData:GetAchieveTitleDataByLevel(level)
	local title_cfg = ConfigManager.Instance:GetAutoConfig("chengjiu_auto").title
	for k,v in pairs(title_cfg) do
		if v.level == level then
			return v
		end
	end
end

-- 得到所有头衔数据
function AchieveData:GetAchieveTitleGridCfg()
	local title_cfg = ConfigManager.Instance:GetAutoConfig("chengjiu_auto").title
	local real_title_cfg = {}
	for i,v in ipairs(title_cfg) do
		real_title_cfg[i - 1] = v
	end
	return real_title_cfg
end

-- 得到头衔数量
function AchieveData:GetAchieveTitleCount()
	local title_cfg = ConfigManager.Instance:GetAutoConfig("chengjiu_auto").title
	return #title_cfg
end

-- 服务器成就信息同步
function AchieveData:OnAchieveInfo(protocol)
	self.title_level = protocol.title_level
	self.reward_list = protocol.reward_list
	self:CheckRedPoint()
end

-- 成就奖励改变
function AchieveData:OnAchieveRewardChange(protocol)
	for k, v in pairs(protocol.reward_list) do
		self.reward_list[k] = v
	end
	self:CheckRedPoint()
end

-- 通过id获取成就信息
function AchieveData:GetAchieveDataById(id)
	local data = {}
	for k,v in pairs(self.reward_info_list) do
		if id == v.id then
			table.insert(data,v)
		end
	end

	return data[1]
end

--检查红点
function AchieveData:GetOverviewRemind()
	return self.red_point_list["Overview"] and 1 or 0
end

--检查红点
function AchieveData:GetTitleRemind()
	return self.red_point_list["Title"] and 1 or 0
end

--检查红点
function AchieveData:CheckRedPoint()
	if self.title_level == nil then
		print("头衔等级为空############")
		return false
	end
	local flag = false
	for k,v in pairs(self.reward_list) do
		if v.flag == 1 then
			flag = true
			break
		end
	end
	self.red_point_list["Overview"] = flag

	local main_ro = GameVoManager.Instance:GetMainRoleVo()
	local next_title_data = self:GetAchieveTitleDataByLevel(self.title_level + 1)
	local title_flag = false
	if next_title_data ~= nil then
		title_flag = (main_ro.chengjiu >= next_title_data.chengjiu)
	end
	self.red_point_list["Title"] = title_flag
end

--获取红点信息
function AchieveData:GetRedPoint()
	return self.red_point_list
end

-- 根据ID得到该ID对应的成就奖励
function AchieveData:GetAchieveReward(reward_id)
	return self.reward_list[reward_id]
end

-- 得到所有一级成就格子
function AchieveData:GetRewardTitleDataList()
	local title_data_list = {}
	for k,v in pairs(self.reward_client_cfg) do
		title_data_list[k] = {}
		title_data_list[k].client_type = k
		title_data_list[k].icon_item_id = v[1].icon_item_id
		title_data_list[k].client_type_str = v[1].client_type_str
		local cfg = self:GetRewardDataList(k)
		title_data_list[k].flag = false
		for k2,v2 in pairs(cfg) do
			if v2.flag == 1 then
				title_data_list[k].flag = true
				break
			end
		end
	end
	return title_data_list
end

--根据client_type获取成就奖励列表
function AchieveData:GetRewardDataList(client_type)
	local reward_cfg = ConfigManager.Instance:GetAutoConfig("chengjiu_auto").reward
	if nil == self.reward_client_cfg[client_type] then
		return nil
	end
	local reward_data_list = {}
	for i, v in ipairs(self.reward_client_cfg[client_type]) do
		local reward_data = {
			cfg = v,
			flag = 0,
			process = 0,
			sort = 0,
			process_text = "",
		}

		if nil ~= self.reward_list[v.id] then
			reward_data.flag = self.reward_list[v.id].flag
			if v.prog_type == 0 then
				local param1 = reward_cfg[v.id].param1
				local process = self.reward_list[v.id].process
				if reward_cfg[v.id].client_type == 5 then
					process = process - 1
					process = process < 0 and 0 or process
					param1 = param1 - 1
				end
				reward_data.process_text = process.." / "..param1
				reward_data.process = process / param1
			else
				if self.reward_list[v.id].process >= reward_cfg[v.id].param1 then
					reward_data.process_text = "1".." / ".."1"
					reward_data.process = 1
				else
					reward_data.process_text = "0".." / ".."1"
					reward_data.process = 0
				end
			end
		end
		--	处理排序，已领取的排最下
		if AchieveRewardFlag.CanFetch == reward_data.flag then
			reward_data.sort = v.client_sort + 1000
		elseif AchieveRewardFlag.BeFetched == reward_data.flag then
			reward_data.sort = v.client_sort + 100000
		else
			reward_data.sort = v.client_sort + 10000
		end

		table.insert(reward_data_list, reward_data)
	end
	table.sort(reward_data_list, SortTools.KeyLowerSorter("sort"))
	return reward_data_list
end

-- 通过ID得到奖励数据
function AchieveData:GetRewardConfigById(id)
	for k,v in pairs(self.reward_client_cfg) do
		for key, value in pairs(v) do
			if value.id == id then
				return value
			end
		end
	end
end

-- 通过client_type查看对应奖励是否能获取
function AchieveData:ChengjiuCanRewardByClientType(client_type)
	local reward_list = self:GetRewardDataList(client_type) or {}
	local num = 0
	for k,v in pairs(reward_list) do
		if v.flag == AchieveRewardFlag.CanFetch then
			num = num + 1
		end
	end
	return num
end

function AchieveData:GetPower()
	local level = AchieveData.Instance:GetTitleLevel()
	local attr_data = AchieveData.Instance:GetAchieveTitleDataByLevel(level)
	return CommonDataManager.GetCapability(attr_data)
end

function AchieveData:GetDefaultOpenView()
	local list = TaskData.Instance:GetTaskCompletedList()
	local default_open = "chengjiu"
	if list[OPEN_FUNCTION_TYPE_ID.MEDAL] == 1 then
		default_open = "medal"
	end
	if list[OPEN_FUNCTION_TYPE_ID.ZHIBAO] == 1 then
		default_open = "zhibao"
	end
	return default_open
end

-- 成就奖励总表
function AchieveData:GetAllCfgInfo()
	return self.new_client_cfg or {}
end

-- 成就类型列表
function AchieveData:GetSingleList(client_type)
	return self.new_client_cfg[client_type] or {}
end

-- 子类型数量
function AchieveData:GetChildNum(client_type, second_index)
	return #self.new_client_cfg[client_type][second_index] or 0
end

--根据client_type获取成就奖励列表
function AchieveData:GetThirdRewardDataList(client_type, second_index)
	local reward_cfg = TableCopy(ConfigManager.Instance:GetAutoConfig("chengjiu_auto").reward)
	if nil == self.new_client_cfg[client_type][second_index] then
		return nil
	end
	local reward_data_list = {}
	for i, v in ipairs(self.new_client_cfg[client_type][second_index]) do
		local reward_data = {
			cfg = v,
			flag = 0,
			process = 0,
			sort = 0,
			process_text = "",
			icon_id = 0,
		}

		if nil ~= self.reward_list[v.id] then
			reward_data.icon_id =  reward_cfg[v.id].icon_item_id
			reward_data.flag = self.reward_list[v.id].flag

			local param_1 = 1
			local param_2 = reward_cfg[v.id].param2
			local process = 0

			if v.prog_type == 0 then
				param_1 = reward_cfg[v.id].param1
				process = self.reward_list[v.id].process or 0
				if param_2 == AchieveParam.Different then
					process = process - 1
					process = process < 0 and 0 or process
					param_1 = param_1 - 1
				end

			elseif (v.prog_type == 2 and self.reward_list[v.id].process == reward_cfg[v.id].param1)			-- 进度类型2 激活女神或精灵 服务端需要道具id 所以用道具id判断
				or (v.prog_type ~= 2 and self.reward_list[v.id].process >= reward_cfg[v.id].param1) then
				process = 1
				param_1 = 1
			end

			reward_data.process_text = process .. " / " .. param_1
			reward_data.process = process / param_1
		end
		--	处理排序，已领取的排最下
		if AchieveRewardFlag.CanFetch == reward_data.flag then
			reward_data.sort = v.client_sort + 1000
		elseif AchieveRewardFlag.BeFetched == reward_data.flag then
			reward_data.sort = v.client_sort + 100000
		else
			reward_data.sort = v.client_sort + 10000
		end

		table.insert(reward_data_list, reward_data)
	end
	table.sort(reward_data_list, SortTools.KeyLowerSorter("sort"))
	return reward_data_list
end

function AchieveData:GetCompleteNum(client_type, second_index)
	if not client_type or not second_index then return end
	local data_list = self:GetThirdRewardDataList(client_type, second_index)
	if not data_list or not next(data_list) then return end
	local num = 0
	local show_red = false
	for k,v in pairs(data_list) do
		if v.flag == AchieveRewardFlag.BeFetched then
			num = num + 1
		elseif v.flag == AchieveRewardFlag.CanFetch then
			show_red = true
		end
	end
	return num, show_red
end

function AchieveData:GetCompleteList()
	if not next(self.reward_list) then return {} end
	local complete_list = {}
	for k,v in pairs(self.reward_list) do
		if v.flag == AchieveRewardFlag.CanFetch then
			table.insert(complete_list, v)
		end
	end
	return complete_list
end