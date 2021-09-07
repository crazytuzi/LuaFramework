ShenGeComposeView = ShenGeComposeView or BaseClass(BaseView)

local MAX_COMPOSE_NUM = 4

function ShenGeComposeView:__init()
	self.ui_config = {"uis/views/shengeview", "ShenGeComposeView"}
	self.play_audio = true
	self.fight_info_view = true
	self.click_index = -1
	self.had_set_data_list = {}
	self.had_set_data_count = 0
	self:SetMaskBg(true)
end

function ShenGeComposeView:ReleaseCallBack()
	for _, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if nil ~= ShenGeData.Instance then
		ShenGeData.Instance:UnNotifyDataChangeCallBack(self.data_change_event)
		self.data_change_event = nil
	end

	-- 清理变量
	self.show_plus_list = nil
	self.composite_prob = nil
	self.ShowProb = nil
	self.show_quality_list = nil
	self.quality_bao_list  = nil
	self.shen_back_level_list = nil
end

function ShenGeComposeView:LoadCallBack()
	self:ListenEvent("OnClickYes",BindTool.Bind(self.OnClickYes, self))
	self:ListenEvent("OnClickNo",BindTool.Bind(self.OnClickNo, self))
	self:ListenEvent("OnClickClose",BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))

	self.item_list = {}
	self.show_plus_list = {}
	self.show_quality_list = {}
	self.quality_bao_list  = {}
	self.shen_back_level_list = {}

	for i = 1, 4 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item"..i))
		item:SetClearListenValue(false)
		item:SetInteractable(true)
		item:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
		item:ShowQuality(false)
		self.item_list[i] = item
		self.show_plus_list[i] = self:FindVariable("ShowPlus"..i)
		self.show_quality_list[i] = self:FindVariable("showqualityItem"..i)
		self.quality_bao_list[i] = self:FindVariable("QualityBao"..i)	
		self.shen_back_level_list[i] = self:FindVariable("ShenBackLevel"..i)


	end

	self.composite_prob = self:FindVariable("composite_prob")
	self.ShowProb = self:FindVariable("ShowProb")

	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	ShenGeData.Instance:NotifyDataChangeCallBack(self.data_change_event)
end

function ShenGeComposeView:OpenCallBack()
	self:ClearItemData()
end

function ShenGeComposeView:CloseCallBack()
end

function ShenGeComposeView:OnClickYes()
	if self.had_set_data_count < MAX_COMPOSE_NUM then
		TipsCtrl.Instance:ShowSystemMsg(Language.ShenGe.MaterialNoEnough)
		return
	end

	local ok_func = function()
		ShenGeCtrl.Instance:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_COMPOSE,
		self.had_set_data_list[1].shen_ge_data.index,
		self.had_set_data_list[2].shen_ge_data.index,
		self.had_set_data_list[3].shen_ge_data.index,
		self.had_set_data_list[4].shen_ge_data.index)
	end

	if self.had_set_data_list[1].shen_ge_data.level > 1
		or self.had_set_data_list[2].shen_ge_data.level > 1
		or self.had_set_data_list[3].shen_ge_data.level > 1
		or self.had_set_data_list[4].shen_ge_data.level > 1 then
		TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.ShenGe.ComposeTip , nil, nil, true, false, "compose_shen_ge", false, "", "", false, nil, true, Language.Common.Cancel, nil, false)
		return
	end

	ok_func()
end

function ShenGeComposeView:OnClickNo()
	self:ClearItemData()
end

function ShenGeComposeView:OnClickClose()
	self:Close()
end

function ShenGeComposeView:OnClickHelp()
	local tips_id = 168
 	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ShenGeComposeView:OnClickItem(index)
	local call_back = function(data)
		self.item_list[index]:SetHighLight(false)
		if nil ~= data then
			if nil == self.item_list[index]:GetData().item_id then
				self.had_set_data_count = self.had_set_data_count + 1
			end
			self.item_list[index]:SetData(data)
			self.show_plus_list[index]:SetValue(false)
			self.show_quality_list[index]:SetValue(true)
			self.quality_bao_list[index]:SetAsset(ResPath.GetRomeNumImage(data.shen_ge_data.quality))
			self.shen_back_level_list[index]:SetValue(data.shen_ge_data.level)

			self.had_set_data_list[index] = data

			-- 第一次选择，自动填充同样的神格
			if self.click_index <= 0 then
				local list = ShenGeData.Instance:GetBagSameQualityAndTypesItemDataList(data.shen_ge_data.type, data.shen_ge_data.quality, data.shen_ge_data.index)
				for k, v in pairs(self.item_list) do
					if nil == v:GetData().item_id and nil ~= list[1] then
						self.had_set_data_count = self.had_set_data_count + 1
						v:SetData(list[1])
						self.show_plus_list[k]:SetValue(false)
						self.show_quality_list[k]:SetValue(true)
						self.quality_bao_list[k]:SetAsset(ResPath.GetRomeNumImage(list[1].shen_ge_data.quality))
						self.shen_back_level_list[k]:SetValue(list[1].shen_ge_data.level)
						self.had_set_data_list[k] = list[1]
						table.remove(list, 1)
					end
				end
			end
			self.click_index = index
		end

		if self.had_set_data_count == MAX_COMPOSE_NUM then
			local shen_ge_kind = self.had_set_data_list[1].shen_ge_kindz
			local quality = self.had_set_data_list[1].shen_ge_data.quality
			local composite_prob = ShenGeData.Instance:GetCompseSucceedRate(shen_ge_kind, quality)
			self.ShowProb:SetValue(true)
			self.composite_prob:SetValue(composite_prob)
		end
	end

	self.had_set_data_list.count = self.had_set_data_count
	ShenGeCtrl.Instance:ShowSelectView(call_back, self.had_set_data_list, "from_compose")
end

function ShenGeComposeView:OnDataChange(info_type, param1, param2, param3, param4)
	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_COMPOSE_SHENGE_INFO then
		self:ClearItemData()
	end
end

function ShenGeComposeView:ClearItemData()
	for k, v in pairs(self.item_list) do
		v:SetData()
		self.show_plus_list[k]:SetValue(true)
		self.show_quality_list[k]:SetValue(false)
	end
	self.had_set_data_list = {}
	self.click_index = -1
	self.had_set_data_count = 0
	self.ShowProb:SetValue(false)
end