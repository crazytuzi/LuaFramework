--------------------------------------------------------
-- 未知暗殿 配置 WeiZhiAnDianCfg
--------------------------------------------------------

UnknownDarkHouseData = UnknownDarkHouseData or BaseClass()

UnknownDarkHouseData.UNKNOWN_DARK_HOUSE_DATA_CHANGE = "unknown_dark_house_data_change"
UnknownDarkHouseData.UNKNOWN_DARK_HOUSE_EXP_CHANGE = "unknown_dark_house_exp_change"
function UnknownDarkHouseData:__init()
	if UnknownDarkHouseData.Instance then
		ErrorLog("[UnknownDarkHouseData]:Attempt to create singleton twice!")
	end
	UnknownDarkHouseData.Instance = self

	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.data = {
		type = 0,
		times = 0,
		multiple = 0,
		now_time = 0,
		time = 0,
		exp_num = 0,
		left_time = 0,
		peo_num = 0,
		max_peo_num = 0,
	}
	self.special_eff_info = {}
	self.exp_info = {}
	-- 绑定红点提示触发条件
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.UnknownDarkHouseCanFreeAccess)
end

function UnknownDarkHouseData:__delete()
	UnknownDarkHouseData.Instance = nil
end

----------设置----------

function UnknownDarkHouseData:SetData(protocol)
	self.data.type = protocol.type
	if self.data.type == 1 then
		self.data.times = protocol.times
		self.data.multiple = protocol.multiple
		self.data.now_time = protocol.now_time
		self.data.left_time = protocol.left_time
		self.data.ppl_qty = protocol.ppl_qty
		self.data.max_ppl_qty = protocol.max_ppl_qty
		self:DispatchEvent(UnknownDarkHouseData.UNKNOWN_DARK_HOUSE_DATA_CHANGE)
	elseif self.data.type == 3 then
		ViewManager.Instance:OpenViewByDef(ViewDef.UnknownDarkHouse)
	end
	RemindManager.Instance:DoRemindDelayTime(RemindName.UnknownDarkHouseCanFreeAccess)
end

function UnknownDarkHouseData:GetData()
	return self.data
end

-- 获取篝火双倍剩余时间
function UnknownDarkHouseData:GetDoubleLeftTime()
	local left_time = self.data.left_time - (Status.NowTime - self.data.now_time)
	return math.max(left_time, 0)
end

function UnknownDarkHouseData:SetExp(protocol)
	self.exp_info.exp_num = protocol.exp_num
	self.exp_info.exp_mul = protocol.exp_mul
	self:DispatchEvent(UnknownDarkHouseData.UNKNOWN_DARK_HOUSE_EXP_CHANGE)
end

-- 获取经验信息
function UnknownDarkHouseData:GetExpInfo()
	return self.exp_info
end

function UnknownDarkHouseData:SetSpecialEffInfo(protocol)
	self.special_eff_info[protocol.type] = {}
	self.special_eff_info[protocol.type].type = protocol.type
	self.special_eff_info[protocol.type].state = protocol.state
	self.special_eff_info[protocol.type].now_time = protocol.now_time
	self.special_eff_info[protocol.type].left_time = protocol.left_time
	self.special_eff_info[protocol.type].ppl_qty = protocol.ppl_qty
	self.special_eff_info[protocol.type].max_ppl_qty = protocol.max_ppl_qty
	self:DispatchEvent(UnknownDarkHouseData.UNKNOWN_DARK_HOUSE_EXP_CHANGE)
end

-- 获取篝火信息
function UnknownDarkHouseData:GetDonfireInfo()
	return self.special_eff_info[1]
end

-- 获取篝火剩余时间
function UnknownDarkHouseData:GetDonfireLeftTime()
	if nil == self.special_eff_info[1] then return end
	local left_time = self.special_eff_info[1].left_time - (Status.NowTime - self.special_eff_info[1].now_time)
	return math.max(left_time, 0)
end
--------------------

----------红点提示----------

-- 获取提醒显示索引 0不显示红点, 1显示红点
function UnknownDarkHouseData.GetRemindIndex()
	local data = UnknownDarkHouseData.Instance:GetData()
	local index = data.times < WeiZhiAnDianCfg.freeTimes and 1 or 0
	
	return index
end

----------end----------