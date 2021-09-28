TipsExpFuBenView = TipsExpFuBenView or BaseClass(BaseView)
local Drop_Id_List =
{
	23091,	--3倍经验
	23090,	--2.5倍经验
	23089,	--2倍经验
	23088,	--1.5倍经验
}

function TipsExpFuBenView:__init()
	self.ui_config = {"uis/views/tips/expviewtips_prefab", "ExpFuBenTips"}
	self.view_layer = UiLayer.Pop
end

function TipsExpFuBenView:ReleaseCallBack()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
	self.list_view = nil
	self.drug_add_text = nil
end

function TipsExpFuBenView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.ClickClose, self))
	self.drug_add_text = self:FindVariable("drug_add_text")
	self.item_cell_list = {}
	self.list_view = self:FindObj("List")
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetListNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.FlushListCellView, self)
end

function TipsExpFuBenView:OpenCallBack()
	--监听物品变化
	self.item_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)

	self.fight_effect_change = GlobalEventSystem:Bind(ObjectEventType.FIGHT_EFFECT_CHANGE,
		BindTool.Bind1(self.Flush, self))
	self:Flush()
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

function TipsExpFuBenView:OnItemDataChange(item_id)
	for k,v in pairs(Drop_Id_List) do
		if item_id == v then
			self:Flush()
			return
		end
	end
end

function TipsExpFuBenView:GetListNumberOfCells()
	return #Drop_Id_List or 0
end

function TipsExpFuBenView:FlushListCellView(cellObj, cell_index, data_index)
	data_index = data_index + 1
	local cell = self.item_cell_list[cellObj]
	if cell == nil then
		self.item_cell_list[cellObj] = TipExpListCell.New(cellObj)
		cell = self.item_cell_list[cellObj]
	end
	cell:SetIndex(data_index)
	cell:Flush()
end


function TipsExpFuBenView:ClickClose()
	self:Close()
end

function TipsExpFuBenView:SetData()
	self.tips_cfg = FuBenData.Instance:GetExpFBTipsCfg()
	self:Flush()
end

function TipsExpFuBenView:OnFlush()
	self.drug_add_text:SetValue(FightData.Instance:GetMainRoleDrugAddExp())
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

----------------------------------------------------------------------------
TipExpListCell = TipExpListCell or BaseClass(BaseCell)

function TipExpListCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))
	self.exp_des = self:FindVariable("exp_des")
	self.btn_text = self:FindVariable("btn_text")
	self.btn_gray = self:FindVariable("btn_gray")
	self.btn_desc = self:FindVariable("Des")
	self:ListenEvent("use_btn_click",BindTool.Bind(self.OnClick,self))
end

function TipExpListCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function TipExpListCell:SetIndex(index)
	self.index = index
end

function TipExpListCell:OnFlush()
	local my_count = ItemData.Instance:GetItemNumInBagById(Drop_Id_List[self.index])
	local data = {}
	data.item_id = Drop_Id_List[self.index]
	data.num = my_count
	self.item_cell:SetData(data)
	self.item_cell:SetNum(my_count)

	if my_count > 0 then
		if self.index == 1 or self.index == 2 then
			self.btn_gray:SetValue(true)
		end
		self.btn_text:SetValue(Language.Common.Use)
	else
		if self.index == 1 or self.index == 2 then
			self.btn_gray:SetValue(false)
			self.btn_text:SetValue(Language.Common.Use)
		else
			self.btn_text:SetValue(Language.Common.CanPurchase)
		end
	end
	local item_cfg = ItemData.Instance:GetItemConfig(Drop_Id_List[self.index])
	local des = item_cfg.name or ""
	self.exp_des:SetValue(des)
	if 23088 == item_cfg.id then    								--(1.5倍经验药水)
		self.btn_desc:SetValue(Language.Common.BindCoinBuy)
	else
		self.btn_desc:SetValue("")
	end
	
end

function TipExpListCell:OnClick()
	local bind_gold = GameVoManager.Instance:GetMainRoleVo().bind_gold
	local my_count = ItemData.Instance:GetItemNumInBagById(Drop_Id_List[self.index])
	if my_count > 0 then
		local bag_index = ItemData.Instance:GetItemIndex(Drop_Id_List[self.index])
		PackageCtrl.Instance:SendUseItem(bag_index, 1, 0, 0)
	elseif self.index == #Drop_Id_List then
		local shop_item_gold = ShopData.Instance:GetShopItemCfg(Drop_Id_List[self.index]).bind_gold
		if shop_item_gold < bind_gold then
			TipsCtrl.Instance:ShowShopView(Drop_Id_List[self.index], 1, nil, 1)
		else
			TipsCtrl.Instance:ShowShopView(Drop_Id_List[self.index], 2, nil, 1)
		end
	else
		TipsCtrl.Instance:ShowShopView(Drop_Id_List[self.index], 2, nil, 1)
	end
end

