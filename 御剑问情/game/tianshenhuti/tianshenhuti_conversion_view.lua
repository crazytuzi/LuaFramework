--无双装备转化
TianshenhutiConversionView = TianshenhutiConversionView or BaseClass(BaseRender)

function TianshenhutiConversionView:__init()
	self.select_slot = -1
	self.item_name = self:FindVariable("item_name")
	local equip_parent = self:FindObj("HeChenngItem")
	PrefabPool.Instance:Load(AssetID("uis/views/tianshenhutiview_prefab","Slot"),
		function(prefab)
			local obj = GameObject.Instantiate(prefab)
			obj.transform:SetParent(equip_parent.transform, false)
			obj = U3DObject(obj)
			self.item = TianshenhutiConversionSlotCell.New(obj)
			self.item:SetDefualtQuality()
			self.item:ListenClick(BindTool.Bind(self.OnClickSelectSlot, self, i))
			self:Flush()
		end)
	self.effect = self:FindObj("Effect")
	self.item_list = {}
	self.show_plus_list = {}
	for i = 1, 2 do
		local item = TianshenhutiEquipItemCell.New()
		item:SetInstanceParent(self:FindObj("Item"..i))
		item:SetInteractable(true)
		item:ListenClick(BindTool.Bind(self.OnClickItem, self, i))
		self.item_list[i] = item
		self.show_plus_list[i] = self:FindVariable("ShowPlus"..i)  --+号
	end
	self:ListenEvent("OnClickYes",BindTool.Bind(self.OnClickYes, self)) --合成
	self:ListenEvent("OnClickNo",BindTool.Bind(self.OnClickNo, self))  --重置
	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self.data_change_event = BindTool.Bind(self.OnDataChange, self)
	TianshenhutiData.Instance:AddListener(TianshenhutiData.COMPOSE_SELECT_CHANGE_EVENT, self.data_change_event)
end

function TianshenhutiConversionView:__delete()
	if nil ~= TianshenhutiData.Instance and self.data_change_event then
		TianshenhutiData.Instance:RemoveListener(TianshenhutiData.COMPOSE_SELECT_CHANGE_EVENT, self.data_change_event)
		self.data_change_event = nil
	end
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
	if self.item_list then
		for k,v in pairs(self.item_list) do
			v:DeleteMe()
		end
		self.item_list = {}
	end
end

function TianshenhutiConversionView:OpenCallBack()
	self.select_slot = -1
	self:Flush()
	TianshenhutiData.Instance:ClearComposeSelectList()
end

function TianshenhutiConversionView:CloseCallBack()

end

function TianshenhutiConversionView:OnClickItem(index)
	local tsht_data = TianshenhutiData.Instance

	if tsht_data:GetComposeSelect(index) then --，如果有,清除当前的
		tsht_data:DelComposeSelect(index)
		return
	end

	local select_data = tsht_data:GetCanComposeDataList()
	if next(select_data) == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Tianshenhuti.NoCanSelectTips)
		return
	end

	TianshenhutiCtrl.Instance:ShowSelectView(index, {}, "") --弹出神格面板
end

function TianshenhutiConversionView:OnClickYes()
	local data_list = TianshenhutiData.Instance:GetComposeSelectList()
	if self.select_slot < 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Tianshenhuti.SelectSlotTips)
		return
	end
	if data_list[1] == nil or data_list[2] == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Equip.XuanzeZhuangBei)
		return
	end
	TianshenhutiCtrl.SendTianshenhutiTransform(data_list[1].index, data_list[2].index, self.select_slot)
end

function TianshenhutiConversionView:OnClickSelectSlot()
	local data_list = TianshenhutiData.Instance:GetComposeSelectList()
	if data_list[1] == nil or data_list[2] == nil then
		SysMsgCtrl.Instance:ErrorRemind(Language.Equip.XuanzeZhuangBei)
		return
	end
	TianshenhutiCtrl.Instance:OpenSelectSlot(BindTool.Bind(self.SelectSlotCallBack, self))
end

function TianshenhutiConversionView:SelectSlotCallBack(index)
	self.select_slot = index
	self.item_name:SetValue(self.select_slot > -1 and "" or Language.Tianshenhuti.SelectConversionTips)
	self.item:SetData(self.select_slot)
end

function TianshenhutiConversionView:OnClickNo()
	TianshenhutiData.Instance:ClearComposeSelectList()
end

function TianshenhutiConversionView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(275)
end

function TianshenhutiConversionView:OnDataChange(data_list)
	self:InitItemData(data_list)
end

function TianshenhutiConversionView:InitItemData(index)
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
	if data_list[1] == nil and data_list[2] == nil then
		self.select_slot = -1
		self:ClearComposeData()
	end
end

function TianshenhutiConversionView:ClearComposeData()
	if self.item == nil then return end
	self.item:SetData()
	self.item:SetDefualtQuality()
end

function TianshenhutiConversionView:OnFlush(param_t)
	if self.select_slot < 0 then
		self:ClearComposeData()
	elseif self.item then
		self.item:SetData(self.select_slot)
	end
	self.item_name:SetValue(self.select_slot > -1 and "" or Language.Tianshenhuti.SelectConversionTips)
end