_G.UIFabaoPick = BaseUI:new("UIFabaoPick");

function UIFabaoPick:Create()
	self:AddSWF("fabaoBagPanel.swf",true,"top");
end

function UIFabaoPick:OnLoaded(objSwf)
	objSwf.list.itemRollOver = function(e) self:OnItemOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
	objSwf.list.itemClick = function(e) self:OnItemClick(e); end
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
end

function UIFabaoPick:OnItemOver(e)
	if not e.item then
		return;
	end
	local selected = nil;
	local type = self.args[1];
	if type == FabaoModel.PickFabao then
		selected = FabaoModel:GetFabaoById(e.item.id);
		TipsManager:ShowFabaoTips(selected);
	elseif type == FabaoModel.PickBook then
		local bag = BagModel:GetBag(BagConsts.BagType_Bag);
		selected = bag:GetItemByPos(e.item.pos);
		if selected then
			TipsManager:ShowItemTips(selected.tid);
		end
	end
end

function UIFabaoPick:OnItemClick(e)
	if not e.item then
		self:OnBtnCloseClick();
		return;
	end
	local type = self.args[1];
	local selected = nil;
	if type == FabaoModel.PickFabao then
		if not e.item.id then
			self:OnBtnCloseClick();
			return;
		end
		selected = FabaoModel:GetFabaoById(e.item.id);
		local fabao = FabaoModel:GetFabao(e.item.id,e.item.modelId);
		Notifier:sendNotification(NotifyConsts.FabaoPick,{args=self.args,selected=fabao});
	elseif type == FabaoModel.PickBook then
		local bag = BagModel:GetBag(BagConsts.BagType_Bag);
		selected = bag:GetItemByPos(e.item.pos);
		if selected then
			local item = BagSlotVO:new();
			item.pos = selected:GetPos();
			item.bagType = BagConsts.BagType_Bag;
			item.opened = true;
			item.hasItem = true;
			item.tid = selected:GetTid();
			item.count = selected:GetCount();
			item.bindState = selected:GetBindState() ;
			Notifier:sendNotification(NotifyConsts.FabaoPick,{args=self.args,selected=item});
		end
	end
	self:OnBtnCloseClick();
end

function UIFabaoPick:OnBtnCloseClick()
	self:Hide();
end

function UIFabaoPick:OnShow()
	if not self.args then
		return;
	end
	
	local list = nil;
	self.objSwf.list.dataProvider:cleanUp();
	local type = self.args[1];
	if type == FabaoModel.PickFabao then
		self.objSwf.lblBook._visible = false;
		self.objSwf.lblFabao._visible = true;
		list = FabaoModel.list;
		if FabaoModel:GetCount() == 0 then
			self:OnBtnCloseClick();
			return;
		end
		for id,fabao in pairs(list) do
			self.objSwf.list.dataProvider:push(UIData.encode(fabao.view));
		end
	elseif type == FabaoModel.PickBook then
	-- self.objSwf.list:scrollToIndex(0);
	-- self.objSwf.list.selectedIndex = 0;
		self.objSwf.lblBook._visible = true;
		self.objSwf.lblFabao._visible = false;
		local bag = BagModel:GetBag(BagConsts.BagType_Bag);
		list = bag:BagItemListBySub(BagConsts.SubT_FabaoBook);
		if #list == 0 then
			self:OnBtnCloseClick();
			return;
		end
		local items = {};
		for i,item in ipairs(list) do
			local slotVO = BagSlotVO:new();
			slotVO.pos = item:GetPos();
			slotVO.bagType = BagConsts.BagType_Bag;
			slotVO.opened = true;
			slotVO.hasItem = true;
			slotVO.tid = item:GetTid();
			slotVO.count = item:GetCount();
			slotVO.bindState = item:GetBindState() ;
			table.push(items,slotVO);
		end
		table.sort(items,function(A,B) return A.pos < B.pos end);
		for i,item in ipairs(items) do
			self.objSwf.list.dataProvider:push(item:GetUIData());
		end	
	else
		self:OnBtnCloseClick();
	end
	self.objSwf.list:invalidateData();
	-- self.objSwf.list:scrollToIndex(0);
	-- self.objSwf.list.selectedIndex = 0;
end

function UIFabaoPick:OnHide()
	self.objSwf.list.dataProvider:cleanUp();
	self.objSwf.list:invalidateData();
	-- self.objSwf.list:scrollToIndex(0);
	-- self.objSwf.list.selectedIndex = 0;
end

function UIFabaoPick:IsTween()
	return false;
end

function UIFabaoPick:GetPanelType()
	return 0;
end

function UIFabaoPick:IsShowSound()
	return true;
end

function UIFabaoPick:GetWidth()
	return 400;
end

function UIFabaoPick:GetHeight()
	return 400;
end

