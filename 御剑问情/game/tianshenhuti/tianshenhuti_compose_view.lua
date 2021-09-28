--无双装备合成
local MAX_COMPOSE_NUM = 3

TianshenhutiComposeView = TianshenhutiComposeView or BaseClass(BaseRender)

function TianshenhutiComposeView:__init()
	self.play_audio = true
	self:ListenEvent("OnClickYes",BindTool.Bind(self.OnClickYes, self)) --合成
	self:ListenEvent("OnClickNo",BindTool.Bind(self.OnClickNo, self))  --重置
	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self:ListenEvent("OnClickAutomatic",BindTool.Bind(self.OnClickAutomatic, self)) --自动合成
	self.item_name = self:FindVariable("item_name")

	self.item = TianshenhutiEquipItemCell.New()     --中间神格
	self.item:SetInstanceParent(self:FindObj("HeChenngItem"))
	self.item:SetDefualtQuality()
	self.effect = self:FindObj("Effect")
	self.item_list = {}
	self.show_plus_list = {}
	for i = 1, 3 do
		local item = TianshenhutiEquipItemCell.New()
		item:SetInstanceParent(self:FindObj("Item"..i))
		item:SetInteractable(true)
		item:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
		self.item_list[i] = item
		self.show_plus_list[i] = self:FindVariable("ShowPlus"..i)  --+号
	end

	self.composite_prob = self:FindVariable("composite_prob")           --显示合成或者失败文本
	self.ShowProb = self:FindVariable("ShowProb")                       --是否显示合成成功或者失败
	self.is_automatic_button = self:FindVariable("IsAutomaticbutton")   --自动合成状态
	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	TianshenhutiData.Instance:AddListener(TianshenhutiData.COMPOSE_SELECT_CHANGE_EVENT, self.data_change_event)
end

function TianshenhutiComposeView:__delete()
	for _, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	if nil ~= TianshenhutiData.Instance and self.data_change_event then
		TianshenhutiData.Instance:RemoveListener(TianshenhutiData.COMPOSE_SELECT_CHANGE_EVENT, self.data_change_event)
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

-- function TianshenhutiComposeView:LoadCallBack()

-- end

function TianshenhutiComposeView:OpenCallBack()
	TianshenhutiData.Instance:ClearComposeSelectList()
end

function TianshenhutiComposeView:OnClickYes()
	local data_list = TianshenhutiData.Instance:GetComposeSelectList()
	if data_list[1] == nil or data_list[2] == nil or data_list[3] == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Equip.XuanzeZhuangBei)
		return
	end
	TianshenhutiCtrl.SendTianshenhutiCombine(data_list[1].index, data_list[2].index, data_list[3].index)
end

function TianshenhutiComposeView:OnClickNo()
	TianshenhutiData.Instance:ClearComposeSelectList()
end

function TianshenhutiComposeView:OnClickHelp()
	local tips_id = 274
 	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function TianshenhutiComposeView:OnClickAutomatic()
	TianshenhutiCtrl.Instance:OpenOneKeyCompose()
end

function TianshenhutiComposeView:OnDataChange(index)
	self:InitItemData(index)
end

function TianshenhutiComposeView:OnClickItem(index)
	local tsht_data = TianshenhutiData.Instance
	if tsht_data:GetComposeSelect(index) then --，如果有,清除当前的
		tsht_data:DelComposeSelect(index)
		return
	end

	local select_data = tsht_data:GetCanComposeDataList(true)
	if next(select_data) == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Tianshenhuti.NoCanSelectTips)
		return
	end

	TianshenhutiCtrl.Instance:ShowSelectView(index, {}, "from_compose") --弹出神格面板
	self.item_name:SetValue("")
	self.item:SetData()
	self.item:SetDefualtQuality()
end

function TianshenhutiComposeView:InitItemData(index)
	local data_list = TianshenhutiData.Instance:GetComposeSelectList()
	if index then
		if self.item_list[index] then
			self.item_list[index]:SetData(data_list[index])
			self.show_plus_list[index]:SetValue(data_list[index] == nil)
		end
	else
		for k, v in pairs(self.item_list) do
			v:SetData(data_list[k])
			self.show_plus_list[k]:SetValue(data_list[k] == nil)
		end
	end
	if next(data_list) then
		self:ClearComposeData()
	end
end

function TianshenhutiComposeView:ClearItemDataByIndex(index)
	TianshenhutiData.Instance:DelComposeSelect(index)
	self:ClearComposeData()
end

function TianshenhutiComposeView:ClearComposeData()
	self.item:SetData()
	self.item:SetDefualtQuality()
	self.item_name:SetValue("")
end

function TianshenhutiComposeView:CloseCallBack()

end

function TianshenhutiComposeView:OnFlush(param_t)

end