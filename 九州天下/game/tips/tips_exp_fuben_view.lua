TipsExpFuBenView = TipsExpFuBenView or BaseClass(BaseView)
local Drop_Id_List =
{
	23088, --1.5倍经验
	23089, --2倍经验
}

function TipsExpFuBenView:__init()
	self.ui_config = {"uis/views/tips/expviewtips", "ExpFuBenTips"}
	self.view_layer = UiLayer.Pop
end

function TipsExpFuBenView:ReleaseCallBack()
	for i=1,2 do
		self.item_cell_list[i].item_cell:DeleteMe()
	end
end

function TipsExpFuBenView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.ClickClose, self))
	self.item_cell_list = {}
	for i =1, 2 do
		self.item_cell_list[i] = {}
		self.item_cell_list[i].item_cell = ItemCell.New()
		self.item_cell_list[i].item_cell:SetInstanceParent(self:FindObj("item_cell_" .. i))
		self.item_cell_list[i].exp_text = self:FindVariable("exp_text_" .. i)
		self.item_cell_list[i].btn_text = self:FindVariable("btn_text_" .. i)
		self:ListenEvent("use_btn_click_" .. i, BindTool.Bind(self.OnClickUse, self, i))
	end
	self.item_cell_list[1].exp_text:SetValue(50)
	self.item_cell_list[2].exp_text:SetValue(100)
end

function TipsExpFuBenView:OpenCallBack()
	--监听物品变化
	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)

	self.fight_effect_change = GlobalEventSystem:Bind(ObjectEventType.FIGHT_EFFECT_CHANGE,
		BindTool.Bind1(self.Flush, self))
	self:Flush()
end

function TipsExpFuBenView:OnItemDataChange(item_id)
	if item_id == 23088 or item_id == 23089 then
		self:Flush()
	end
end

function TipsExpFuBenView:ClickClose()
	self:Close()
end

function TipsExpFuBenView:CloseCallBack()
	if self.fight_effect_change then
		GlobalEventSystem:UnBind(self.fight_effect_change)
		self.fight_effect_change = nil
	end
	if self.item_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
		self.item_change_callback = nil
	end
end

function TipsExpFuBenView:SetData()
	self.tips_cfg = FuBenData.Instance:GetExpFBTipsCfg()
	self:Flush()
end

function TipsExpFuBenView:OnFlush()
	for i =1, 2 do
		self.item_cell_list[i].item_cell:SetShowNumTxtLessNum(0)
		local my_count = ItemData.Instance:GetItemNumInBagById(Drop_Id_List[i])
		local data = {}
		data.item_id = Drop_Id_List[i]
		data.num = my_count
		self.item_cell_list[i].item_cell:SetData(data)
		if my_count > 0 then
			self.item_cell_list[i].btn_text:SetValue(Language.Common.Use)
		else
			self.item_cell_list[i].btn_text:SetValue(Language.Common.CanPurchase)
		end
	end
end

function TipsExpFuBenView:OnClickUse(index)
	local shop_item_gold = ShopData.Instance:GetShopItemCfg(Drop_Id_List[index]).bind_gold
	local bind_gold = GameVoManager.Instance:GetMainRoleVo().bind_gold
	local my_count = ItemData.Instance:GetItemNumInBagById(Drop_Id_List[index])
	if my_count > 0 then
		local bag_index = ItemData.Instance:GetItemIndex(Drop_Id_List[index])
		PackageCtrl.Instance:SendUseItem(bag_index, 1, 0, 0)
	elseif index == 1 then
		if shop_item_gold < bind_gold then
			TipsCtrl.Instance:ShowShopView(Drop_Id_List[index], 1, nil, 1)
		else
			TipsCtrl.Instance:ShowShopView(Drop_Id_List[index], 2, nil, 1)
		end
	else
		TipsCtrl.Instance:ShowShopView(Drop_Id_List[index], 2, nil, 1)
	end
end

