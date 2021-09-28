ShenGeDecomposeView = ShenGeDecomposeView or BaseClass(BaseView)

local SHOW_TIP_QUALITY = 3

function ShenGeDecomposeView:__init()
	self.ui_config = {"uis/views/shengeview_prefab", "ShenGeDecomposeView"}
	self.play_audio = true
	self.fight_info_view = true
	self.decompose_data_list = {}
	self.fragmen_num_list = {}
	self.select_num_list = {}
end

function ShenGeDecomposeView:ReleaseCallBack()
	if nil ~= ShenGeData.Instance then
		ShenGeData.Instance:UnNotifyDataChangeCallBack(self.data_change_event)
		self.data_change_event = nil
	end

	-- 清理变量
	self.fragments = nil
	self.toggle_list = nil
	self.select_num_var_list = nil
end

function ShenGeDecomposeView:LoadCallBack()
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickDecompose", BindTool.Bind(self.OnClickDecompose, self))

	self.toggle_list = {}
	self.select_num_var_list = {}
	for i = 1, 6 do
		self:ListenEvent("OnSelect"..i, BindTool.Bind(self.OnSelect, self, i))
		self:ListenEvent("OnClickDetails"..i, BindTool.Bind(self.OnClickDetails, self, i))
		self.toggle_list[i] = self:FindObj("Toggle"..i).toggle
		self.select_num_var_list[i] = self:FindVariable("LevelNum"..i)
	end

	self.fragments = self:FindVariable("Fragments")

	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	ShenGeData.Instance:NotifyDataChangeCallBack(self.data_change_event)
end

function ShenGeDecomposeView:OpenCallBack()
	for k, v in pairs(self.select_num_var_list) do
		v:SetValue(#ShenGeData.Instance:GetShenGeSameQualityItemData(k - 1))
	end
end

function ShenGeDecomposeView:CloseCallBack()
	ShenGeData.Instance:ClearOneKeyDecomposeData()
	self:ResetData()
end

function ShenGeDecomposeView:OnClickDetails(index)
	local call_back = function(index, is_select)
		self:SetFragments(index + 1, true)
	end
	ShenGeCtrl.Instance:ShowDecomposeDetail(index - 1, call_back, nil ~= self.decompose_data_list[index])
end

function ShenGeDecomposeView:OnSelect(index)
	self:SetSelectData(index)
end

function ShenGeDecomposeView:ResetData()
	self.fragments:SetValue(0)
	self.fragmen_num_list = {}
	self.decompose_data_list = {}

	for k, v in pairs(self.toggle_list) do
		v.isOn = false
	end
	for k, v in pairs(self.select_num_var_list) do
		v:SetValue(0)
	end
end

function ShenGeDecomposeView:SetSelectData(index)
	if nil ~= self.decompose_data_list[index] and self.toggle_list[index].isOn then
		for k, v in pairs(self.decompose_data_list[index]) do
			v.is_select = false
		end
		self.decompose_data_list[index] = nil
		self.fragmen_num_list[index] = 0
	else
		self.decompose_data_list[index] = ShenGeData.Instance:GetShenGeSameQualityItemData(index - 1)
		local cfg = {}
		local fragment_num = 0
		local return_score = 0
		for k, v in pairs(self.decompose_data_list[index]) do
			v.is_select = true
			cfg = ShenGeData.Instance:GetShenGeAttributeCfg(v.shen_ge_data.type, v.shen_ge_data.quality, v.shen_ge_data.level)
			return_score = cfg.return_score or 0
			fragment_num = fragment_num + return_score
		end
		self.fragmen_num_list[index] = fragment_num
	end
	self:SetFragments(index, false)
end

function ShenGeDecomposeView:SetFragments(index, is_call_back)
	if is_call_back then
		local cfg = {}
		local fragment_num = 0
		local return_score = 0
		for k, v in pairs(ShenGeData.Instance:GetShenGeSameQualityItemData(index - 1)) do
			if v.is_select then
				cfg = ShenGeData.Instance:GetShenGeAttributeCfg(v.shen_ge_data.type, v.shen_ge_data.quality, v.shen_ge_data.level)
				return_score = cfg.return_score or 0
				fragment_num = fragment_num + return_score
			end
		end

		self.fragmen_num_list[index] = fragment_num
		self.decompose_data_list[index] = ShenGeData.Instance:GetShenGeSameQualityItemData(index - 1)
	end

	local num = 0
	for k, v in pairs(self.fragmen_num_list) do
		num = num + v
	end
	self.fragments:SetValue(num)
end

function ShenGeDecomposeView:OnClickDecompose()
	local send_index_list = {}
	local is_show_tip = false
	for k, v in pairs(self.decompose_data_list) do
		if #v > 0 and k >= SHOW_TIP_QUALITY and not is_show_tip then
			is_show_tip = true
		end
		for _, v2 in pairs(v) do
			if v2.is_select then
				table.insert(send_index_list, v2.shen_ge_data.index)
			end
		end
	end

	if #send_index_list <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenGe.NoChose)
		return
	end

	local ok_func = function()
		self.decompose_data_list = {}
		self.fragmen_num_list = {}
		ShenGeData.Instance:ClearOneKeyDecomposeData()
		self.fragments:SetValue(0)
		for k, v in pairs(self.toggle_list) do
			v.isOn = false
		end

		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_DECOMPOSE, 0, 0, 0, #send_index_list, send_index_list)
	end

	if is_show_tip then
		TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.ShenGe.DecomposeTip , nil, nil, true, false, "decompose_shen_ge", false, "", "", false, nil, true, Language.Common.Cancel, nil, false)
		return
	end

	ok_func()
end

function ShenGeDecomposeView:OnDataChange(info_type, param1, param2, param3, bag_list)
	if not self:IsOpen() then return end

	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_MARROW_SCORE_INFO
		or info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_BAG_INFO then
		for k, v in pairs(self.select_num_var_list) do
			v:SetValue(#ShenGeData.Instance:GetShenGeSameQualityItemData(k - 1))
		end
	end
end

function ShenGeDecomposeView:OnClickClose()
	self:Close()
end