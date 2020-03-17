--[[
	天神卡背包
]]

_G.UITianshenBag = BaseSlotPanel:new("UITianshenBag");

UITianshenBag.SlotTotalNum = 49;--UI上的格子总数
UITianshenBag.list = {};--当前物品列表

function UITianshenBag:Create()
	self:AddSWF("tianshenBag.swf",true,"center");
end

function UITianshenBag:OnLoaded(objSwf)
	objSwf.btnClose.click     = function() self:Hide() end
	objSwf.cardBtn.click = function() 
		UINewTianshenCompose:Show() 
	end
	objSwf.btnPack.click = function()
		self:OnBtnPackClick()
	end
	objSwf.tianshenBtn.click = function()
		FuncManager:OpenFunc(FuncConsts.NewTianshen)
	end
	for i=1,self.SlotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end

	objSwf.btnRules.rollOver =  function() TipsManager:ShowBtnTips(StrConfig["newtianshen203"],TipsConsts.Dir_RightDown); end
	objSwf.btnRules.rollOut = function(e) TipsManager:Hide(); end
end

function UITianshenBag:OnShow()
	self:ShowList()
	self:RegisterTimes()
end

function UITianshenBag:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.list = BagUtil:GetBagItemList(BagConsts.BagType_Tianshen,BagConsts.ShowType_All);
	objSwf.list.dataProvider:cleanUp();
	for i,slotVO in ipairs(self.list) do
		slotVO.opened = true
		objSwf.list.dataProvider:push(slotVO:GetUIData());
	end
	objSwf.list:invalidateData();
	if not keepPos then
		objSwf.list:scrollToIndex(0);
	end
end

--整理背包
function UITianshenBag:OnBtnPackClick()
	BagController:PackItem(BagConsts.BagType_Tianshen);
	SoundManager:PlaySfx(2046);
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnPack.disabled = true;
	local callBackFunc = function(count)
		local objSwf = self.objSwf;
		if objSwf then
			objSwf.btnPack.label = string.format(UIStrConfig['bag021'],(20-count	));
			objSwf.btnPack.disabled = true;
		end
		if count >= 20 then
			if objSwf then
				objSwf.btnPack.disabled = false;
				objSwf.btnPack.label = UIStrConfig['bag009'];
			end	
		end
	end
	callBackFunc(0);
	TimerManager:RegisterTimer(callBackFunc,1000,20);
end

function UITianshenBag:OnDelete()
	self:RemoveAllSlotItem();
end

function UITianshenBag:ESCHide()
	return true;
end

--更新Item
function UITianshenBag:DoUpdateItem(pos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Tianshen);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagSlotVO = self.list[pos+1];
	bagSlotVO.id = item:GetId();
	bagSlotVO.tid = item:GetTid();
	bagSlotVO.count = item:GetCount();
	bagSlotVO.bindState = item:GetBindState();
	bagSlotVO.flags = item.flags;
	objSwf.list.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = objSwf.list:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

--添加Item
function UITianshenBag:DoAddItem(pos)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Tianshen);
	if not bagVO then return; end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagSlotVO = self.list[pos+1];
	bagSlotVO.hasItem = true;
	bagSlotVO.id = item:GetId();
	bagSlotVO.tid = item:GetTid();
	bagSlotVO.count = item:GetCount();
	bagSlotVO.bindState = item:GetBindState();
	bagSlotVO.flags = item.flags;
	objSwf.list.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = objSwf.list:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

--移除Item
function UITianshenBag:DoRemoveItem(pos)
	local objSwf = self.objSwf;
	if not objSwf then return; end;
	local bagSlotVO = self.list[pos+1];
	bagSlotVO.hasItem = false;
	objSwf.list.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = objSwf.list:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

function UITianshenBag:OnItemRollOver(item)
	local data = item:GetData();
	local bagVO = BagModel:GetBag(BagConsts.BagType_Tianshen);
	if not bagVO then return; end
	TipsManager:ShowBagTips(BagConsts.BagType_Tianshen,data.pos);
end

function UITianshenBag:OnItemRollOut(item)
	TipsManager:Hide();
end

function UITianshenBag:OnItemDragIn(fromData,toData)
	if fromData.bagType==toData.bagType and fromData.pos==toData.pos then
		return;
	end
	--只接受来自自己的拖拽
	if fromData.bagType ~= BagConsts.BagType_Tianshen then
		return
	end
	BagController:SwapItem(fromData.bagType,fromData.pos,toData.bagType,toData.pos);
end

function UITianshenBag:OnItemDragBegin(item)
	TipsManager:Hide();
end

function UITianshenBag:OnItemDragEnd(item)
	local itemData = item:GetData();
	--没拖出背包
	local mousePos = UIManager:GetMousePos();
	local x1,y1 = self:GetPos();
	local x2,y2 = x1+self:GetWidth(),y1+self:GetHeight();
	if mousePos.x>x1 and mousePos.x<x2 and mousePos.y>y1 and mousePos.y<y2 then
		return;
	end
	BagController:DiscardItem(BagConsts.BagType_Tianshen, itemData.pos);
end

--双击使用
function UITianshenBag:OnItemDoubleClick(item)
	TipsManager:Hide();
	local itemData = item:GetData();
	--快速出售
	if not itemData.hasItem then
		return;
	end

	BagController:UseItem(BagConsts.BagType_Tianshen, itemData.pos, 1);
end

--左键菜单
function UITianshenBag:OnItemClick(item)
	TipsManager:Hide();
	local itemData = item:GetData();
	if not itemData.hasItem then
		UIBagOper:Hide();
		return;
	end

	--锁定物品处理
	local bagVO = BagModel:GetBag(BagConsts.BagType_Tianshen);
	if not bagVO then return; end

	UIBagOper:Open(item.mc,itemData.bagType,itemData.pos);
end

--右键使用
function UITianshenBag:OnItemRClick(item)
	TipsManager:Hide();
	local itemData = item:GetData();
	BagController:UseItem(BagConsts.BagType_Tianshen, itemData.pos, 1);
end

function UITianshenBag:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.BagAdd then
		if body.type == BagConsts.BagType_Tianshen then
			self:DoAddItem(body.pos);
		end
	elseif name == NotifyConsts.BagRemove then
		if body.type == BagConsts.BagType_Tianshen then
			self:DoRemoveItem(body.pos);
		end
	elseif name == NotifyConsts.BagUpdate then
		if body.type ~= BagConsts.BagType_Tianshen then 
			return 
		end
		self:DoUpdateItem(body.pos);
	elseif name == NotifyConsts.BagRefresh then
		if body.type ~= BagConsts.BagType_Tianshen then return; end
		self:ShowList()
	elseif name == NotifyConsts.tianShenOutUpdata then
		self:ShowList()
	end
end

function UITianshenBag:ListNotificationInterests()
	return {NotifyConsts.BagAdd,NotifyConsts.BagRemove,NotifyConsts.BagUpdate,NotifyConsts.BagRefresh,NotifyConsts.tianShenOutUpdata,}
end

function UITianshenBag:InitSmithingRedPoint(  )
	local objSwf = self.objSwf
	if not objSwf then return end
	
	if NewTianshenUtil:IsHaveCardCanCompose() then
		PublicUtil:SetRedPoint(objSwf.cardBtn, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.cardBtn, nil, 0)
	end
end

function UITianshenBag:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil
	end
end

function UITianshenBag:RegisterTimes()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey)
		self.timerKey = nil
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		self:InitSmithingRedPoint()
	end,1000,0); 
end