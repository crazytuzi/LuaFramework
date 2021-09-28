ShenGeComposeView = ShenGeComposeView or BaseClass(BaseView)

local MAX_COMPOSE_NUM = 3

function ShenGeComposeView:__init()
	self.ui_config = {"uis/views/shengeview_prefab", "ShenGeComposeView"}
	self.play_audio = true
	self.fight_info_view = true
	self.click_index = -1
	self.had_set_data_list = {}
	self.had_set_data_count = 0
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

	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end

	self.item_name = nil
	self.effect = nil
	self.is_automatic_button = nil
end

function ShenGeComposeView:LoadCallBack()
	self:ListenEvent("OnClickYes",BindTool.Bind(self.OnClickYes, self))
	self:ListenEvent("OnClickNo",BindTool.Bind(self.OnClickNo, self))
	self:ListenEvent("OnClickClose",BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickAutomatic",BindTool.Bind(self.OnClickAutomatic, self))
	self.item_name = self:FindVariable("item_name")

	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("HeChenngItem"))
	self.item:SetDefualtQuality()
	self.effect = self:FindObj("Effect")
	self.item_list = {}
	self.show_plus_list = {}
	for i = 1, 3 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item"..i))
		item:SetClearListenValue(false)
		item:SetInteractable(true)
		item:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
		self.item_list[i] = item
		self.show_plus_list[i] = self:FindVariable("ShowPlus"..i)
	end

	self.composite_prob = self:FindVariable("composite_prob")
	self.ShowProb = self:FindVariable("ShowProb")
	self.is_automatic_button = self:FindVariable("IsAutomaticbutton")

	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	ShenGeData.Instance:NotifyDataChangeCallBack(self.data_change_event)
end

function ShenGeComposeView:OpenCallBack()
	self:ClearItemData()
end

function ShenGeComposeView:CloseCallBack()
	self:CacleDelayTime()
	ShenGeCtrl.Instance:RecoverData()
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
		self.had_set_data_list[3].shen_ge_data.index)
		self.effect.animator:SetTrigger("play")
	end

	if self.had_set_data_list[1].shen_ge_data.level > 1
		or self.had_set_data_list[2].shen_ge_data.level > 1
		or self.had_set_data_list[3].shen_ge_data.level > 1 then
		TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.ShenGe.ComposeTip , nil, nil, true, false, "compose_shen_ge", false, "", "", false, nil, true, Language.Common.Cancel, nil, false)
		return
	end

	ok_func()
end

--自动合成
function ShenGeComposeView:OnClickAutomatic()
	local flag = ShenGeData.Instance:GetAutomaticComposeFlag()
	if flag == SHENGE_AUTOMATIC_COMPOSE_FLAG.NO_START then
		ShenGeData.Instance:SetAutomaticComposeFlag(SHENGE_AUTOMATIC_COMPOSE_FLAG.COMPOSE_REQUIRE)
		ShenGeData.Instance:SetSelectComposeList(self.had_set_data_list)
		ShenGeCtrl.Instance:AutomaticComposeAction()
	else
		ShenGeCtrl.Instance:RecoverData()
	end
end

function ShenGeComposeView:EffectAnimatior()
	self.effect.animator:SetTrigger("play")
end

function ShenGeComposeView:FlushComposeButton(state)
	self.is_automatic_button:SetValue(state)
end

function ShenGeComposeView:LoadEffect()
	-- body
end

function ShenGeComposeView:HeChengitem(temp_data)
	local item_cfg = ItemData.Instance:GetItemConfig(temp_data.item_id)
	if nil == item_cfg then
		return
	end
	local item_cfg_name = item_cfg.name
	item_cfg_name = ToColorStr(item_cfg_name,LIAN_QI_NAME_COLOR[item_cfg.color])
	self.item_name:SetValue(item_cfg_name)
	self.item:SetData(temp_data)
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
			self.had_set_data_list[index] = data

			-- 第一次选择，自动填充同样的神格
			if self.click_index <= 0 then
				local list = ShenGeData.Instance:GetBagSameQualityAndTypesItemDataList(data.shen_ge_data.type, data.shen_ge_data.quality, data.shen_ge_data.index)
				for k, v in pairs(self.item_list) do
					if nil == v:GetData().item_id and nil ~= list[1] then
						self.had_set_data_count = self.had_set_data_count + 1
						v:SetData(list[1])
						self.show_plus_list[k]:SetValue(false)
						self.had_set_data_list[k] = list[1]
						table.remove(list, 1)
					end
				end
			end
			self.click_index = index
		end

		if self.had_set_data_count == MAX_COMPOSE_NUM then
			local shen_ge_kind = self.had_set_data_list[1].shen_ge_kind
			local quality = self.had_set_data_list[1].shen_ge_data.quality
			local composite_prob = ShenGeData.Instance:GetCompseSucceedRate(shen_ge_kind, quality)
			self.ShowProb:SetValue(true)
			self.composite_prob:SetValue(composite_prob)
		end
	end

	local flag = ShenGeData.Instance:GetAutomaticComposeFlag()
	if flag ~= SHENGE_AUTOMATIC_COMPOSE_FLAG.NO_START then
		self.item_list[index]:ShowHighLight(false)
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenGe.ComposeAutomatic)
		return
	end

	if self.had_set_data_list and self.had_set_data_count >= 0 and self.had_set_data_list[index] then
		self:ClearItemDataByIndex(index)
		return
	end

	self.had_set_data_list.count = self.had_set_data_count
	ShenGeCtrl.Instance:ShowSelectView(call_back, self.had_set_data_list, "from_compose")
	self.item_name:SetValue("")
	self.item:SetData()
	self.item:SetDefualtQuality()
	self.item:OnlyShowQuality(true)
end

function ShenGeComposeView:OnDataChange(info_type, param1, param2, param3)
	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_COMPOSE_SHENGE_INFO then
		self:ClearItemData()
	end
end

function ShenGeComposeView:ClearItemData()
	for k, v in pairs(self.item_list) do
		v:SetData()
		self.show_plus_list[k]:SetValue(true)
	end
	self.had_set_data_list = {}
	self.click_index = -1
	self.had_set_data_count = 0
	self:ClearComposeData()
end

function ShenGeComposeView:ClearItemDataByIndex(index)
	if nil == index or index <= 0 or index > MAX_COMPOSE_NUM or self.had_set_data_count <= 0 then return end
	for k, v in pairs(self.item_list) do
		if k == index then
			v:ShowHighLight(false)
			v:SetData()
			self.show_plus_list[k]:SetValue(true)
		end
	end

	self:ClearComposeData()
	self.had_set_data_list[index] = nil
	self.had_set_data_count = self.had_set_data_count - 1
	self.click_index = self.had_set_data_count <= 0 and -1 or index
	self.ShowProb:SetValue(false)
end

function ShenGeComposeView:ClearComposeData()
	self.item:SetData()
	self.item:SetDefualtQuality()
	self.item:OnlyShowQuality(true)
	self.item_name:SetValue("")
end

function ShenGeComposeView:HideProb(state)
	self.ShowProb:SetValue(state)
end

function ShenGeComposeView:SetDataSameItem()
	self:CacleDelayTime()
	self.delay_time = GlobalTimerQuest:AddDelayTimer(function()
		self:ShowDataSameItem()
		self:ClearComposeData()
	end, 0.2)
end

function ShenGeComposeView:CacleDelayTime()
	if self.delay_time then
		GlobalTimerQuest:CancelQuest(self.delay_time)
		self.delay_time = nil
	end
end

function ShenGeComposeView:ShowDataSameItem()
	local select_list = ShenGeData.Instance:GetSelectComposeList()
	for k, v in pairs(self.item_list) do
		if nil ~= select_list[k] then
			v:SetData(select_list[k])
			self.had_set_data_count = self.had_set_data_count + 1
			self.show_plus_list[k]:SetValue(false)
			self.had_set_data_list[k] = select_list[k]
		end
	end
end