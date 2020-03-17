--[[
仓库界面
lizhuangzhuang
2014年7月28日10:39:55
]]

_G.UIStorage = BaseSlotPanel:new("UIStorage");

UIStorage.SlotTotalNum = 63;--UI中格子总数
UIStorage.tabButton = {};
UIStorage.showType = BagConsts.ShowType_All;--显示类型
UIStorage.list = {};

function UIStorage:Create()
	self:AddSWF("storagePanel.swf", true, "center");
end

function UIStorage:OnLoaded(objSwf,name)
	objSwf.labelInfo.htmlText = StrConfig['bag44'];
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	objSwf.btnPack.click = function() self:OnBtnPackClick(); end;
	--tabButton
	self.tabButton[BagConsts.ShowType_All] = objSwf.btnAll;
	self.tabButton[BagConsts.ShowType_All] = objSwf.btnAll;
	self.tabButton[BagConsts.ShowType_Equip] = objSwf.btnEquip;
	self.tabButton[BagConsts.ShowType_Consum] = objSwf.btnConsum;
	self.tabButton[BagConsts.ShowType_Task] = objSwf.btnTask;
	self.tabButton[BagConsts.ShowType_Other] = objSwf.btnOther;
	for k,btn in pairs(self.tabButton) do
		btn.click = function() self:OnTabButtonClick(k); end
	end
	--初始化格子
	for i=1,self.SlotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end
end

function UIStorage:OnDelete()
	self:RemoveAllSlotItem();
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
end

function UIStorage:IsTween()
	return true;
end

function UIStorage:GetPanelType()
	return 0;
end

function UIStorage:ESCHide()
	return true;
end

function UIStorage:IsShowLoading()
	return true;
end

function UIStorage:IsShowSound()
	return true;
end

function UIStorage:BeforeTween()
	local func = FuncManager:GetFunc(FuncConsts.Bag);
	if not func then return; end
	self.tweenStartPos = func:GetBtnGlobalPos();
end

function UIStorage:GetWidth()
	return 460;
end

function UIStorage:GetHeight()
	return 672;
end

function UIStorage:OnShow(name)
	self:OnTabButtonClick(BagConsts.ShowType_All);
	self:ShowBagSize();
end

--显示列表
--主标签按正常格子显示,分标签过滤后连续显示
--@param keepPos 是否保留滚动条位置
function UIStorage:ShowList(keepPos)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.list = BagUtil:GetBagItemList(BagConsts.BagType_Storage,self.showType);
	objSwf.list.dataProvider:cleanUp();
	for i,slotVO in ipairs(self.list) do
		objSwf.list.dataProvider:push(slotVO:GetUIData());
	end
	objSwf.list:invalidateData();
	if not keepPos then
		objSwf.list:scrollToIndex(0);
	end
end

--显示背包格子数
function UIStorage:ShowBagSize()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Storage);
	if not bagVO then return; end
	local useSize = bagVO:GetUseSize();
	local size = bagVO:GetSize();
	local leftSize = size - useSize;
	if leftSize == 0 then
		objSwf.tfSize.htmlText = string.format(StrConfig["bag43"],useSize,size);
	elseif leftSize < 5 then
		objSwf.tfSize.htmlText = string.format(StrConfig["bag42"],useSize,size);
	else
		objSwf.tfSize.htmlText = string.format(StrConfig["bag41"],useSize,size);
	end
end

function UIStorage:HandleNotification(name,body)
	if not self.bShowState then return; end
	if not self.objSwf then return; end
	if name == NotifyConsts.BagAdd then
		if body.type ~= BagConsts.BagType_Storage then return; end
		self:DoAddItem(body.pos);
		self:ShowBagSize();
	elseif name == NotifyConsts.BagRemove then
		if body.type ~= BagConsts.BagType_Storage then return; end
		self:DoRemoveItem(body.pos);
		self:ShowBagSize();
	elseif name == NotifyConsts.BagUpdate then
		if body.type ~= BagConsts.BagType_Storage then return; end
		self:DoUpdateItem(body.pos);
	elseif name == NotifyConsts.BagRefresh then
		if body.type ~= BagConsts.BagType_Storage then return; end
		self:ShowList();
		self:ShowBagSize();
	elseif name == NotifyConsts.BagSlotOpen then
		if body.type ~= BagConsts.BagType_Storage then return; end
		self:DoOpenSlot(body.oldSize,body.newSize);
		self:ShowBagSize();
	elseif name == NotifyConsts.BagItemCDUpdate then
		if body.type ~= BagConsts.BagType_Storage then return; end
		self:ShowList(true);
	end
end

function UIStorage:ListNotificationInterests()
	return {NotifyConsts.BagAdd,NotifyConsts.BagRemove,NotifyConsts.BagUpdate,NotifyConsts.BagRefresh,
			NotifyConsts.BagSlotOpen,NotifyConsts.BagItemCDUpdate};
end

--添加Item
function UIStorage:DoAddItem(pos)
	if self.showType ~= BagConsts.ShowType_All then
		self:ShowList();
		return;
	end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Storage);
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
	objSwf.list.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = objSwf.list:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

--移除Item
function UIStorage:DoRemoveItem(pos)
	if self.showType ~= BagConsts.ShowType_All then
		self:ShowList();
		return;
	end
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

--更新Item
function UIStorage:DoUpdateItem(pos)
	if self.showType ~= BagConsts.ShowType_All then
		self:ShowList();
		return;
	end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Storage);
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
	objSwf.list.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = objSwf.list:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

--开启格子
function UIStorage:DoOpenSlot(oldSize,newSize)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i=oldSize,newSize-1 do
		local bagSlotVO = self.list[i+1];
		if bagSlotVO then
			bagSlotVO.opened = true;
			objSwf.list.dataProvider[i] = bagSlotVO:GetUIData();
			local uiSlot = objSwf.list:getRendererAt(i);
			if uiSlot then
				uiSlot:setData(bagSlotVO:GetUIData());
			end
		end
	end
	--下一格子转CD
	local bagSlotVO = self.list[newSize+1];
	if bagSlotVO then
		objSwf.list.dataProvider[newSize] = bagSlotVO:GetUIData();
		local uiSlot = objSwf.list:getRendererAt(newSize);
		if uiSlot then
			uiSlot:setData(bagSlotVO:GetUIData());
		end
	end
end

function UIStorage:OnItemRollOver(item)
	local data = item:GetData();
	if not data.opened then
		local bagVO = BagModel:GetBag(BagConsts.BagType_Storage);
		if not bagVO then return; end
		if data.pos == bagVO:GetSize() then
			if data.pos+1 <= BagConsts:GetBagTimeSize(BagConsts.BagType_Storage) then
				local hour,min,sec = CTimeFormat:sec2format(bagVO:GetOpenNextTime());
				local str = string.format(StrConfig["bag32"],data.pos+1,UIStrConfig['bag018'],hour,min,sec);
				TipsManager:ShowBtnTips(str,TipsConsts.Dir_RightDown);
			else
				TipsManager:ShowBtnTips(string.format(StrConfig["bag10"],UIStrConfig['bag018'],UIStrConfig['bag018']),TipsConsts.Dir_RightDown);
			end
		else
			TipsManager:ShowBtnTips(string.format(StrConfig["bag10"],UIStrConfig['bag018'],UIStrConfig['bag018']),TipsConsts.Dir_RightDown);
		end
		return; 
	end;
	if not data.hasItem then return; end;
	TipsManager:ShowBagTips(BagConsts.BagType_Storage,data.pos);
end

function UIStorage:OnItemRollOut(item)
	TipsManager:Hide();
end

function UIStorage:OnItemDragBegin(item)
	UIBagOper:Hide();
	TipsManager:Hide();
end

function UIStorage:OnItemDragEnd(item)
	local itemData = item:GetData();
	--没拖出仓库
	local mousePos = UIManager:GetMousePos();
	local x1,y1 = self:GetPos();
	local x2,y2 = x1+self:GetWidth(),y1+self:GetHeight();
	if mousePos.x>x1 and mousePos.x<x2 and mousePos.y>y1 and mousePos.y<y2 then
		return;
	end
	--判断背包面板内
	if UIBag:IsShow() then
		local x1,y1 = UIBag:GetPos();
		local x2,y2 = x1+UIBag:GetWidth(),y1+UIBag:GetHeight();
		if mousePos.x>x1 and mousePos.x<x2 and mousePos.y>y1 and mousePos.y<y2 then
			BagController:MoveToBag(BagConsts.BagType_Storage,itemData.pos);
			return;
		end
	end
	BagController:DiscardItem(BagConsts.BagType_Storage, itemData.pos);
end

function UIStorage:OnItemDragIn(fromData,toData)
	Debug('拖拽,fromBag:'..fromData.bagType..",fromPos"..fromData.pos..",toBag:"..toData.bagType..",toPos:"..toData.pos);
	--同一格子拖动不处理
	if fromData.bagType==toData.bagType and fromData.pos==toData.pos then
		return;
	end
	--来自仓库的
	if fromData.bagType == BagConsts.BagType_Storage then
		if self.showType == BagConsts.ShowType_All then
			--主标签,叠加交换;分标签,不处理
			BagController:SwapItem(fromData.bagType,fromData.pos,toData.bagType,toData.pos);
		end
		return;
	end;
	--来自背包的
	if fromData.bagType == BagConsts.BagType_Bag then
		--主标签,叠加交换;分标签,to没有东西不处理,to有东西判断是否是同一显示类型
		if self.showType == BagConsts.ShowType_All then
			BagController:SwapItem(fromData.bagType,fromData.pos,toData.bagType,toData.pos);
		else
			if not toData.hasItem then return; end
			if BagUtil:GetItemShowType(fromData.tid)==BagUtil:GetItemShowType(toData.tid) then
				BagController:SwapItem(fromData.bagType,fromData.pos,toData.bagType,toData.pos);
			end
		end
		return;
	end
end

--左键菜单
function UIStorage:OnItemClick(item)
	TipsManager:Hide();
	local itemData = item:GetData();
	if not itemData.opened then
		UIBagOper:Hide();
		UIBagOpen:Open(BagConsts.BagType_Storage,itemData.pos);
		return;
	end
	if not itemData.hasItem then
		UIBagOper:Hide();
		return;
	end
	if _sys:isKeyDown(_System.KeyCtrl) then
		ChatQuickSend:SendItem(BagConsts.BagType_Storage,itemData.pos);
		return;
	end
	UIBagOper:Open(item.mc,itemData.bagType,itemData.pos);
end

--双击移动到背包
function UIStorage:OnItemDoubleClick(item)
	UIBagOper:Hide();
	TipsManager:Hide();
	local itemData = item:GetData();
	if not itemData.opened then
		return;
	end
	if not itemData.hasItem then
		return;
	end
	--有背包界面时,移动到背包界面,先叠加后交换
	if UIBag:IsShow() then
		BagController:MoveToBag(BagConsts.BagType_Storage,itemData.pos);
	end
end

--右键移动到背包
function UIStorage:OnItemRClick(item)
	UIBagOper:Hide();
	TipsManager:Hide();
	local itemData = item:GetData();
	if not itemData.opened then
		return;
	end
	if not itemData.hasItem then
		return;
	end
	--有背包界面时,移动到背包界面,先叠加后交换
	if UIBag:IsShow() then
		BagController:MoveToBag(BagConsts.BagType_Storage,itemData.pos);
	end
end

--切换标签
function UIStorage:OnTabButtonClick(name)
	self.showType = name;
	if self.tabButton[name] then
		self.tabButton[name].selected = true;
	end
	self:ShowList();
end
--点击关闭
function UIStorage:OnBtnCloseClick()
	self:Hide();
end
--点击整理
function UIStorage:OnBtnPackClick()
	BagController:PackItem(BagConsts.BagType_Storage);
	SoundManager:PlaySfx(2046);
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnPack.disabled = true;
	local callBackFunc = function(count)
		local objSwf = self.objSwf;
		if objSwf then
			objSwf.btnPack.label = string.format(UIStrConfig['bag021'],(20-count));
			objSwf.btnPack.disabled = true;
		end
		if count >= 20 then
			if objSwf then
				objSwf.btnPack.disabled = false;
				objSwf.btnPack.label = UIStrConfig['bag020'];
			end
		end
	end
	callBackFunc(0);
	TimerManager:RegisterTimer(callBackFunc,1000,20);
end

--获取在指定位置的Item,格子开启用
function UIStorage:GetItemAtPos(pos)
	if not self.isFullShow then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.list:scrollToIndex(pos);
	local uiSlot = objSwf.list:getRendererAt(pos);
	return uiSlot;
end