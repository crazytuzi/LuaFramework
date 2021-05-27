------------------------------------------------------------
-- 威望任务Data
------------------------------------------------------------
PrestigeTaskData = PrestigeTaskData or BaseClass(BaseData)

-- 事件
PrestigeTaskData.TASK_DATA_CHANGE = "TASK_DATA_CHANGE"

function PrestigeTaskData:__init()
	if PrestigeTaskData.Instance ~= nil then
		ErrorLog("[PrestigeTaskData] attempt to create singleton twice!")
		return
	end

	PrestigeTaskData.Instance = self

	self.data = {
		times = 0,
		vis = false,
	}
	-- 绑定红点提示触发条件
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindIndex), RemindName.PrestigeTaskCanExchange)
	-- 背包数据监听
	BagData.Instance:AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagDataChange))
end

function PrestigeTaskData:__delete()
	PrestigeTaskData.Instance = nil
end

function PrestigeTaskData:SetData(protocol)
	self.data.times = protocol.times
	self:DispatchEvent(PrestigeTaskData.TASK_DATA_CHANGE)
	RemindManager.Instance:DoRemindDelayTime(RemindName.PrestigeTaskCanExchange)
end

function PrestigeTaskData:GetData()
	return self.data
end

function PrestigeTaskData:SetRewardListVis(vis)
	self.data.vis = vis
end

----------红点提示----------

function PrestigeTaskData.OnBagDataChange()
	RemindManager.Instance:DoRemindDelayTime(RemindName.PrestigeTaskCanExchange)
end

-- 获取提醒显示索引 0不显示红点, 1显示红点
function PrestigeTaskData.GetRemindIndex()
	-- local data = PrestigeTaskData.Instance:GetData()
	-- local index = data.times < PrestigeSysConfig.dayMaxCount and 1 or 0
	-- return index
end

----------end----------