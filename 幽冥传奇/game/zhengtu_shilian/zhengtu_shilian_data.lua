ZhengtuShilianData = ZhengtuShilianData or BaseClass()

ZhengtuShilianData.ROTARY_TABLE_DATA_CHANGE = "rotary_table_data_change"
ZhengtuShilianData.DAILY_REWARD_DATA_CHANGE = "daily_reward_data_change"

function ZhengtuShilianData:__init()
	if ZhengtuShilianData.Instance then
		ErrorLog("[ZhengtuShilianData] attempt to create singleton twice!")
		return
	end
	ZhengtuShilianData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.table_data = {
		times = 0,		 -- 剩余次数
		pool_index = 1,	-- 奖池配置索引, 从1开始
		item_index = 0,	-- 中奖索引, 从1开始
	}

	self.daily_reward_data = {
		index = 0,		 -- 关卡索引
		pool_index = 0,	 -- 奖池索引
		times = 0,		 -- 已领取次数
	}

	self.skip_animation_check_box_status = false
	self.is_dont_need_req_everyday_award = false

	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))

	-- 绑定红点提示触发条件
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.ShiLianCanLuckyDraw)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRewardRemind), RemindName.ShiLianReward)
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	EventProxy.New(ZhengtuShilianData.Instance, self):AddEventListener(ZhengtuShilianData.DAILY_REWARD_DATA_CHANGE, BindTool.Bind(self.OnDailyRewardDataChange, self))
end

function ZhengtuShilianData:__delete()
	ZhengtuShilianData.Instance = nil
end


function ZhengtuShilianData:OnRecvMainRoleInfo()
	RemindManager.Instance:DoRemindDelayTime(RemindName.ShiLianReward)
end

function ZhengtuShilianData:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL then
		 RemindManager.Instance:DoRemindDelayTime(RemindName.ShiLianReward)
	end
end

function ZhengtuShilianData:OnDailyRewardDataChange(vo)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ShiLianReward)
end


-- 设置转盘数据
function ZhengtuShilianData:SetRotaryTableData(protocol)
	self.table_data.times = protocol.times
	if protocol.type == 1 then
		self.table_data.pool_index = protocol.pool_index
		self.table_data.item_index = protocol.item_index
	end
	self:DispatchEvent(ZhengtuShilianData.ROTARY_TABLE_DATA_CHANGE)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ShiLianCanLuckyDraw)
end

-- 获取转盘数据
function ZhengtuShilianData:GetRotaryTableData()
	return self.table_data
end

-- 获取"幸运转盘"需要显示的物品
function ZhengtuShilianData.GetRotaryTableItemData(index)
	if nil == index then return end
	--获取显示配置
	local show_cfg = TrialWheelCfg.awardPool[index].award
	local data_list = {}
	for i = 1, 10 do
		data_list[i] = ItemData.FormatItemData(show_cfg[i])
	end
	
	return data_list
end

-- 设置每日领取奖励数据
function ZhengtuShilianData:SetShiLianAwardEverydayData(protocol)
	self.daily_reward_data.index = protocol.index
	self.daily_reward_data.pool_index = protocol.pool_index
	self.daily_reward_data.times = protocol.times

	self.is_dont_need_req_everyday_award = true
	self:DispatchEvent(ZhengtuShilianData.DAILY_REWARD_DATA_CHANGE)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ShiLianReward)
end

-- 获取"每日奖励"数据
function ZhengtuShilianData:GetDailyRewardData()
	return self.daily_reward_data
end

function ZhengtuShilianData:CanLingquEverydayAward()
	return self.daily_reward_data.times and self.daily_reward_data.times < TrialEveryDayAwardCfg.freeCount
end

-- 获取是否需要请求"每日奖励"数据
function ZhengtuShilianData:IsNotNeedSendReqEverydayAward()
	return self.is_dont_need_req_everyday_award
end

-- 获取"每日奖励"数据
function ZhengtuShilianData:GetEverydayAwardCfg()
	local index, pool_index = self.daily_reward_data.index, self.daily_reward_data.pool_index
	if index ~= 0 and pool_index ~= 0 then
		local cfg = TrialEveryDayAwardCfg.AwardsList[index].pools[pool_index]
		local list = {}
		for k,v in pairs(cfg.award) do
			for i = 1, v.count do
				list[#list + 1] = {type = v.type, item_id = v.id, bind = v.bind, num = 1}
			end
		end
		return list
	end
end

----------红点提示----------

-- 获取提醒显示索引 0不显示红点, 1显示红点
function ZhengtuShilianData.GetRemindIndex()
	local data = ZhengtuShilianData.Instance:GetRotaryTableData()
	local index = data.times > 0 and 1 or 0
	return index
end

function ZhengtuShilianData:GetRewardRemind()
	return ZhengtuShilianData.Instance:CanLingquEverydayAward() and 1 or 0 
end

--------------------