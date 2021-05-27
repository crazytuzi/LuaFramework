---------------
-- 消费荣耀
---------------
local CSGoldZhuanPanActData = {}

function CSGoldZhuanPanActData:Init(t)
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.act_cfg = t.act_cfg
	self.act_id = t.act_cfg.act_id
	self.act_name = self.act_cfg.act_name
	self.data = {}
	self.client_cfg = OPER_ACT_CLIENT_CFG[self.act_id]
	self.is_valid = true

	self.cur_person_level = 1
	self.remind_num = 0
	return self
end

function CSGoldZhuanPanActData:Delete()
	self:RemoveAllEventListeners()
	self.is_valid = false
end

function CSGoldZhuanPanActData:HasRemind()
	return self.client_cfg.remind_param and (0 < #self.client_cfg.remind_param)
end

function CSGoldZhuanPanActData:IsValid()
	return self.is_valid
end

function CSGoldZhuanPanActData:ServerProtocol(protocol)
	self.data.rank_list = protocol.rank_list
	self.data.mine_rank = protocol.mine_rank
	self.data.mine_num = protocol.mine_num
	self.data.lingqu_flag = protocol.lingqu_flag

	self:DispatchEvent("CZRY_DATA_CHANGE")
end

function CSGoldZhuanPanActData:SetPersonRewardRemind()
	local remind_num = 0
	self.remind_num = remind_num
	RemindManager.Instance:DoRemind(RemindName.CSHonorActXFRY)
	self:DispatchEvent("REMIND_CHANGE")
end

function CSGoldZhuanPanActData:GetRemindNum(remind_name)
	return self.remind_num
end
return CSGoldZhuanPanActData