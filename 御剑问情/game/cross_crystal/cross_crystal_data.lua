CrossCrystalData = CrossCrystalData or BaseClass()

--采集物类型
local SHUIJING_TYPE =
{
	SMALL = 1,
	MIDDLE = 2,
	BIG = 3,
	MAX_BIG = 4,
}

--采集物子类型
local SHUIJING_SUB_TYPE =
{
	ZHI_ZHUN = 1,
	MO_JING = 2,
	SHENG_WANG = 3,
	ZHUAN_SHI = 4,
}

local SHUIJING_ID =
{
	0,
	1,
	2,
	3,
}

function CrossCrystalData:__init()
	if CrossCrystalData.Instance then
		ErrorLog("[CrossCrystalData] attempt to create singleton twice!")
		return
	end
	CrossCrystalData.Instance =self

	self.cfg = ConfigManager.Instance:GetAutoConfig("activityshuijing_auto")
	self.task_exp_xishu_cfg = self.cfg.task_exp_xishu
	self.gather_cfg = self.cfg.gather
	self.info = {
		total_mojing = 0,
		total_bind_gold = 0,
		total_shengwang = 0,
		total_relive_times = 0,
		cur_gather_times = 0,
		gather_buff_time = 0,
		big_shuijing_num = 0,
		next_time = 0,
	}
	self.task_info = {
		gather_shuijing_total_num = 0,
		gather_big_shuijing_total_num = 0,
		gather_diamond_big_shuijing_num = 0,
		gather_best_shuijing_count = 0,
		fetch_task_reward_flag = 0,
	}
end

function CrossCrystalData:__delete()
	CrossCrystalData.Instance = nil
end

function CrossCrystalData:SetCrystalInfo(info)
	self.info.total_mojing = info.total_mojing				-- 总共-绑定元宝
	self.info.total_bind_gold = info.total_bind_gold		-- 总共-魔晶
	self.info.total_shengwang = info.total_shengwang		-- 总共-声望

	self.info.free_relive_times = info.free_relive_times	-- 已免费复活次数
	self.info.cur_gather_times = info.cur_gather_times 		-- 当前采集次数
	self.info.gather_buff_time = info.gather_buff_time 		-- 采集不被打断buff时间
	self.info.big_shuijing_num = info.big_shuijing_num 		-- 至尊水晶数量
end

function CrossCrystalData:SetNextTime(time)
	self.info.next_time = time
end

function CrossCrystalData:GetCrystalInfo()
	return self.info
end

function CrossCrystalData:OnSCGatherGeneraterList(gather_list)
	self.gather_list = gather_list
end

function CrossCrystalData:SetCrystalTaskInfo(info)
	self.task_info.gather_shuijing_total_num = info.gather_shuijing_total_num                   --采集任意水晶次数
	self.task_info.gather_big_shuijing_total_num = info.gather_big_shuijing_total_num		    --采集任意大水晶次数
	self.task_info.gather_diamond_big_shuijing_num = info.gather_diamond_big_shuijing_num	    --采集钻石大水晶次数
	self.task_info.gather_best_shuijing_count = info.gather_best_shuijing_count  			    --采集至尊水晶次数
	self.task_info.fetch_task_reward_flag = bit:d2b(info.fetch_task_reward_flag) 				--已完成列表
end

function CrossCrystalData:GetCrystalTaskInfo()
	local info = {}
	info.task_info = self.task_info
	info.task_num = #(self.cfg["task"])

	info.task_id = {}
	info.task_gather_count = {}
	for i = 1,info.task_num do
		info.task_id[i] = self.cfg["task"][i].task_id
		info.task_gather_count[i] = self.cfg["task"][i].gather_count
	end

	return info
end

function CrossCrystalData:GetTaskDataById(id)
	if id == self.cfg["task"][1].task_id then
		return self.task_info.gather_shuijing_total_num
	elseif id == self.cfg["task"][2].task_id then
		return self.task_info.gather_big_shuijing_total_num
	elseif id == self.cfg["task"][3].task_id then
		return self.task_info.gather_diamond_big_shuijing_num
	elseif id == self.cfg["task"][4].task_id then
		return self.task_info.gather_best_shuijing_count
	else return
	end
end

function CrossCrystalData:GetGatherCfg()
	return self.gather_cfg
end

--获取小水晶信息
function CrossCrystalData:GetSmallShuiJingInfoList()
	if self.small_shuijing_info_list == nil then
		self.small_shuijing_info_list = {}
		for k,v in pairs(self.gather_cfg) do
			if v.gather_type == SHUIJING_TYPE.SMALL then
				table.insert(self.small_shuijing_info_list, v)
			end
		end
	end
	return self.small_shuijing_info_list
end

--获取中水晶信息
function CrossCrystalData:GetMiddleShuiJingInfoList()
	if self.middle_shuijing_info_list == nil then
		self.middle_shuijing_info_list = {}
		for k,v in pairs(self.gather_cfg) do
			if v.gather_type == SHUIJING_TYPE.MIDDLE then
				table.insert(self.middle_shuijing_info_list, v)
			end
		end
	end
	return self.middle_shuijing_info_list
end

--获取大水晶信息
function CrossCrystalData:GetBigShuiJingInfoList()
	if self.big_shuijing_info_list == nil then
		self.big_shuijing_info_list = {}
		for k,v in pairs(self.gather_cfg) do
			if v.gather_type == SHUIJING_TYPE.BIG then
				table.insert(self.big_shuijing_info_list, v)
			end
		end
	end
	return self.big_shuijing_info_list
end

--获取至尊水晶信息
function CrossCrystalData:GetMaxBigShuiJingInfoList()
	if self.max_big_shuijing_info_list == nil then
		self.max_big_shuijing_info_list = {}
		for k,v in pairs(self.gather_cfg) do
			if v.gather_type == SHUIJING_TYPE.MAX_BIG then
				table.insert(self.max_big_shuijing_info_list, v)
			end
		end
	end
	return self.max_big_shuijing_info_list
end

function CrossCrystalData:GetShuiJingInfoById(task_id)
	if task_id == 0 then  		--采集4次任意水晶
		return self.gather_cfg
	elseif task_id == 1 then 	--采集3次任意大水晶
		return self:GetBigShuiJingInfoList()
	elseif task_id == 2 then    --采集1次钻石大水晶
		local big_shuijing_list = self:GetBigShuiJingInfoList()
		if #big_shuijing_list == 1 then
			return big_shuijing_list[1]
		else
			for k,v in pairs(big_shuijing_list) do
				if v.gather_sub_type == SHUIJING_SUB_TYPE.ZHUAN_SHI then
					return v
				end
			end
		end
	elseif task_id == 3 then 	--采集1次至尊水晶
		local max_big_shuijing_list = self:GetMaxBigShuiJingInfoList()
		if #max_big_shuijing_list == 1 then
			return max_big_shuijing_list[1]
		else
			for k,v in pairs(max_big_shuijing_list) do
				if v.gather_sub_type == SHUIJING_SUB_TYPE.ZHI_ZHUN then
					return v
				end
			end
		end
	end
end

function CrossCrystalData:GetMinGatherId(index)
	local shui_jing_info = CrossCrystalData.Instance:GetShuiJingInfoById(index)
	local distance_list = {}
	if #shui_jing_info == 0 then  --只有一个表
		return shui_jing_info.gather_id
	else  --含有多个表
		for k,v in pairs(shui_jing_info) do
			local list = {}
			list.distance = Scene.Instance:GetMinDisGather(v.gather_id)
			list.gather_id = v.gather_id
			table.insert(distance_list, list)
		end
		if #distance_list > 1 then
			table.sort(distance_list, SortTools.KeyLowerSorters("distance") )
		end
		return distance_list[1].gather_id
	end
	return 0
end

--获取下次采集的任务id
--参数:当前采集id
--[[如果没完成,则继续当前id。
   如果完成了则自动找下一个任务id
   如果所有都完成了 则返回-1
--]]
function CrossCrystalData:GetNextTaskId(task_id)
	if self.task_info.fetch_task_reward_flag[32 - task_id] == 0 then
		return task_id
	else
		for k,v in pairs(SHUIJING_ID) do
			if v ~= task_id then
				if self.task_info.fetch_task_reward_flag[32 - v] == 0 then
					return v
				end
			end
		end
	end
	return -1
end

function CrossCrystalData:GetTaskIdByIndex()
	local task_list = {}
	local num = 0

	if self:GetCrystalTaskInfo() then
		num = self:GetCrystalTaskInfo().task_num or 0
	end

	for i = 1, num do
		task_list[i] = i - 1
	end

	function sortfun(a, b)  --战力
		local a_value = self.task_info.fetch_task_reward_flag[32 - a]
		local b_value = self.task_info.fetch_task_reward_flag[32 - b]
		if a_value < b_value then
			return true
		elseif a_value == b_value then
			return a < b
		else
			return false
		end
	end
    table.sort(task_list, sortfun)
    return task_list
end

function CrossCrystalData:GetTaskIsCompelete(task_id)
	return self.task_info.fetch_task_reward_flag[32 - task_id] == 1
end

--获得视野外指定id的最小距离
function CrossCrystalData:GetMinDistGatherPos(task_id)
	local target_gather_id_list = {}
	local target_gather_list = {}
	local shuijing_list = self:GetShuiJingInfoById(task_id)
	local key_shuijint_list = {}
	--最终返回的结果
	local final_list = {}
	if nil == shuijing_list then
		return final_list
	end
	--重新创建一个以gather_id为key的表
	if #shuijing_list == 0 then
		key_shuijint_list[shuijing_list.gather_id] = shuijing_list
	else
		for k,v in pairs(shuijing_list) do
			key_shuijint_list[v.gather_id] = v
		end
	end

	for k,v in pairs(self.gather_list) do
		if key_shuijint_list[v.gather_id] then
			if v.next_refresh_time <= 0 then
				table.insert(target_gather_list, v)
			else
				if not next(final_list) then  --默认保存等于gather_id的信息(只保存一次),无论是否被采集了
					final_list = v
				end
			end
		end
	end
	local main_role = Scene.Instance:GetMainRole()
	local main_role_x, main_role_y = main_role:GetLogicPos()
	local min_key = -1
	local min_distance = nil
	--找到距离最小的gather_id
	for k,v in pairs(target_gather_list) do
		if min_distance == nil then
			min_distance = GameMath.GetDistance(main_role_x, main_role_y, v.pos_x, v.pos_y, false)
			min_key = k
		else
			local temp_distance = GameMath.GetDistance(main_role_x, main_role_y, v.pos_x, v.pos_y, false)
			if temp_distance < min_distance then
				min_distance = temp_distance
				min_key = k
			end
		end
	end

	if target_gather_list[min_key] then  --全图内有最优采集id
		final_list = target_gather_list[min_key]
	end
	return final_list
end

function CrossCrystalData:GetCurGatherCount(task_id)
	if task_id == SHUIJING_ID[1] then
		return self.task_info.gather_shuijing_total_num
	elseif task_id == SHUIJING_ID[2] then
		return self.task_info.gather_big_shuijing_total_num
	elseif task_id == SHUIJING_ID[3] then
		return self.task_info.gather_diamond_big_shuijing_num
	elseif task_id == SHUIJING_ID[4] then
		return self.task_info.gather_best_shuijing_count
	end
end

--服务端还未同步
function CrossCrystalData:CheckIsComplete(task_id)
	local count = 0
	if self.cfg["task"] and self.cfg["task"][task_id + 1] then
		count = self.cfg["task"][task_id + 1].gather_count or 0
	end
	if task_id == 0 then
		return self.task_info.gather_shuijing_total_num >= count
	elseif task_id == 1 then
		return self.task_info.gather_big_shuijing_total_num >= count
	elseif task_id == 2 then
		return self.task_info.gather_diamond_big_shuijing_num >= count
	elseif task_id == 3 then
		return self.task_info.gather_best_shuijing_count >= count
	end
end

--获取当前id经验
function CrossCrystalData:GetShuijingExp(task_id)
	local exp_per = self:GetShuijingExpPer() * 0.01
	return self.cfg["task"][task_id + 1].reward_exp * exp_per
end

--获得当前等级经验系数
function CrossCrystalData:GetShuijingExpPer()
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	for k,v in pairs(self.task_exp_xishu_cfg) do
		if my_level <= v.max_level and my_level >= v.min_level then
			return v.exp_per
		end
	end
	return 0
end

