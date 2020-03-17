_G.UISmithingPick = BaseUI:new("UISmithingPick");

function UISmithingPick:Create()
	self:AddSWF("smithingGemSelectPanel.swf",true,"highTop");
end

function UISmithingPick:OnLoaded(objSwf)
	objSwf.list.itemRollOver = function(e) self:OnItemOver(e); end
	objSwf.list.itemRollOut = function(e) TipsManager:Hide(); end
	objSwf.list.itemClick = function(e) self:OnItemClick(e); end
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
end

function UISmithingPick:OnItemOver(e)
	if not e.item then
		return;
	end
	
	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
	local item = bag:GetItemByPos(e.item.pos);
	local config = t_gemgroup[e.item.tid];
	if config then
		TipsManager:ShowItemTips(config.itemid);
	end
end

function UISmithingPick:OnItemClick(e)
	if not e.item then
		return;
	end
	
	local bag = BagModel:GetBag(BagConsts.BagType_Bag);
	local selected = bag:GetItemByPos(e.item.pos);
	if not selected then
		return;
	end
	
	local item = BagSlotVO:new();
	item.pos = selected:GetPos();
	item.bagType = BagConsts.BagType_Bag;
	item.opened = true;
	item.hasItem = true;
	item.tid = selected:GetTid();
	item.count = selected:GetCount();
	item.bindState = selected:GetBindState();
	item.groupid = e.item.tid;
	Notifier:sendNotification(NotifyConsts.GemInlayPick,{args=self.args,item=item});
	self:OnBtnCloseClick();
end

function UISmithingPick:OnShow()
	local pos = self.args[1];
	local hole = self.args[2];
	local level = self.args[3];
	
	local list = SmithingModel:GetAllEquipGems(pos,hole,level);
	self.objSwf.list.dataProvider:cleanUp();
	if #list == 0 then
		FloatManager:AddNormal(StrConfig['smithing208']);
		local cfg = t_equipgem[pos]
		local item = split(cfg.celerityshop, "#")
		UIQuickBuyConfirm:Open(self,toint(item[hole]))
		self:OnBtnCloseClick();
		return;
	end
	local items = {};
	for i,config in ipairs(list) do
		local item = config.item;
		local slotVO = {};
		slotVO.pos = item:GetPos();
		slotVO.bagType = BagConsts.BagType_Bag;
		slotVO.opened = true;
		slotVO.hasItem = true;
		slotVO.hasSkill = true;
		slotVO.tid = config.groupid;
		slotVO.count = item:GetCount();
		slotVO.showCount = slotVO.count
		slotVO.showBind = item:GetBindState() ;
		slotVO.iconUrl = BagUtil:GetItemIcon(item.tid);
		slotVO.qualityUrl = ResUtil:GetSlotQuality(t_item[item.tid].quality)
		slotVO.isBlack = false;
		slotVO.super = 0
		slotVO.strenLvl = 0
		slotVO.biaoshiUrl = BagUtil:GetItemBiaoShiUrl(item.tid)
		slotVO.id = item.tid
		table.push(items,slotVO);
	end
	table.sort(items,function(A,B) if A.tid and B.tid then return A.tid < B.tid end return A.tid end);
	for i,item in ipairs(items) do
		self.objSwf.list.dataProvider:push(UIData.encode(item));
	end
	
	self.objSwf.list:invalidateData();
	self.objSwf.list:scrollToIndex(0);
	self.objSwf.list.selectedIndex = 0;
	
end

function UISmithingPick:OnHide()
	self.objSwf.list.dataProvider:cleanUp();
	self.objSwf.list:invalidateData();
	self.objSwf.list:scrollToIndex(0);
	self.objSwf.list.selectedIndex = 0;
	TipsManager:Hide()
end

function UISmithingPick:IsTween()
	return false;
end

function UISmithingPick:GetPanelType()
	return 0;
end

function UISmithingPick:OnBtnCloseClick()
	self:Hide();
end