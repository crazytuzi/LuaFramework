--[[
背包界面
lizhuangzhuang
2014年7月28日10:39:40
]]

_G.UIBag = BaseSlotPanel:new("UIBag");
UIBag.isOpenSmith = false
UIBag.SlotTotalNum = 49;--UI上的格子总数
UIBag.tabButton = {};
UIBag.currencyBtns = {}; --显示货币名、货币数目的button(原为label，为了加rollover改为button)
UIBag.showType = BagConsts.ShowType_All; --显示类型
UIBag.isQuickSell = false;--是否快速出售
UIBag.isPacking = false;--是否整理背包冷却
UIBag.list = {};--当前物品列表

function UIBag:Create()
	self:AddSWF("bagPanel.swf",true,"center");
end

function UIBag:OnLoaded(objSwf)
	objSwf.btnClose.click     = function() self:OnBtnCloseClick();     end
	-- objSwf.btnQuickSell.click = function() self:OnBtnQuickSellClick(); end
	-- objSwf.maskQuickSell.doubleClickEnabled = true;
	-- objSwf.maskQuickSell.click = function() self:OnMaskQuickSellClick();end

	-- objSwf.maskQuickSell.doubleClick = function() 
										-- self:SetQuickSell(false);
										-- self:ShowList(true);
									-- end
	objSwf.btnTianshen.click = function()
		if UITianshenBag:IsShow() then
			UITianshenBag:Hide()
		else
			UITianshenBag:Show()
		end
	end
	objSwf.btnPack.click      = function() self:OnBtnPackClick();      end
	objSwf.btnFenjie.click      = function() self:OnBtnFenjieClick();      end
	objSwf.btnShop.click      = function() self:OnBtnShopClick();      end
	objSwf.btnShichang.click      = function() self:OnBtnShichangClick();      end
	objSwf.btnStorage.click   = function() self:OnBtnStorageClick();   end
	--objSwf.btnCompound.click  = function() self:OnBtnCompoundClick();  end
	--objSwf.btnSmelting.click  = function() self:OnBtnSmeltClick();  end
	--tabButton
	self.tabButton[BagConsts.ShowType_All]    = objSwf.btnAll;
	self.tabButton[BagConsts.ShowType_Equip]  = objSwf.btnEquip;
	self.tabButton[BagConsts.ShowType_Consum] = objSwf.btnConsum;
	self.tabButton[BagConsts.ShowType_Task]   = objSwf.btnTask;
	self.tabButton[BagConsts.ShowType_Other]  = objSwf.btnOther;
	-- objSwf.btnTianshen.click = function()
	-- 	if UITianshenBag:IsShow() then
	-- 		UITianshenBag:Hide()
	-- 	else
	-- 		UITianshenBag:Show()
	-- 	end
	-- end
	for k, btn in pairs( self.tabButton ) do
		btn.click = function() self:OnTabButtonClick(k); end
	end
	--货币按钮
	-- objSwf.btnNumTael.autoSize     = true
	objSwf.btnNumBindTael.autoSize = true
	objSwf.btnNumIngot.autoSize    = true
	objSwf.btnNumCashGift.autoSize = true
	self.currencyBtns["tael"    ] = objSwf.btnTael;
	self.currencyBtns["bindTael"] = objSwf.btnBindTael;
	self.currencyBtns["ingot"   ] = objSwf.btnIngot;
	self.currencyBtns["cashGift"] = objSwf.btnCashGift;
	-- self.currencyBtns["numTael"    ] = objSwf.btnNumTael;
	self.currencyBtns["numBindTael"] = objSwf.btnNumBindTael;
	self.currencyBtns["numIngot"   ] = objSwf.btnNumIngot;
	self.currencyBtns["numCashGift"] = objSwf.btnNumCashGift;
	for name, btn in pairs( self.currencyBtns ) do
		btn.rollOver = function() self:OnCurrencyBtnRollOver(name); end
		btn.rollOut  = function() self:OnCurrencyBtnRollOut();      end
	end
	--初始化格子
	for i=1,self.SlotTotalNum do
		self:AddSlotItem(BaseItemSlot:new(objSwf["item"..i]),i);
	end
	UITianshenBag:Show()
	--self:SetQuickSell(false);
end

function UIBag:OnDelete()
	self:RemoveAllSlotItem();
	for k,_ in pairs(self.tabButton) do
		self.tabButton[k] = nil;
	end
	for k,_ in pairs(self.currencyBtns) do
		self.currencyBtns[k] = nil;
	end
end

function UIBag:IsTween()
	return true;
end

function UIBag:BeforeTween()
	local func = FuncManager:GetFunc(FuncConsts.Bag);
	if not func then return; end
	self.tweenStartPos = func:GetBtnGlobalPos();
end

function UIBag:OnBeforeHide()
	if self.isQuickSell then
		--self:SetQuickSell(false);
	end
	UITianshenBag:Hide()
	return true;
end

function UIBag:IsShowLoading()
	return true;
end

function UIBag:GetPanelType()
	return 0;
end

function UIBag:ESCHide()
	return true;
end

function UIBag:WithRes()
	return {"bagSlotCD.swf"};
end

function UIBag:IsShowSound()
	return true;
end

function UIBag:GetWidth()
	return 464;
end

function UIBag:GetHeight()
	return 688;
end

function UIBag:OnResize(dwWidth,dwHeight)
	if self.isQuickSell then
		--self:SetQuickSellMask();
	end
end 

function UIBag:OnShow()
    
	self:OnTabButtonClick(BagConsts.ShowType_All);
	self:ShowBagSize();
	self:ShowMoney();
    self:UnRegisterTime()
    self:InitBagRedPoint()
	self:RegisterTime()
	--self:ShowCompoundBtn();
end

function UIBag:OnFullShow()
end;

function UIBag:OnHide()
	UIStorage:Hide();
	UIBagSplit:Hide();
	UIBagBatchUse:Hide();
	UIBagSellConfirm:Hide();
	UIBagOpenGift:Hide();
	UIBagOpen:Hide();
	UIDeal:Hide();
	BagController:ClearDiscardConfirm();
	UIBagEquipConfirm:CloseAll();
    UIBag:UnRegisterTime()
	
end

--显示列表
--主标签按正常格子显示,分标签过滤后连续显示
--@param keepPos 是否保留滚动条位置
function UIBag:ShowList(keepPos)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.list = BagUtil:GetBagItemList(BagConsts.BagType_Bag,self.showType);
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
function UIBag:ShowBagSize()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local useSize = bagVO:GetUseSize();
	local size = bagVO:GetSize();
	local leftSize = size - useSize;
	if leftSize == 0 then
		objSwf.tfSize.htmlText = string.format(StrConfig["bag40"],useSize,size);
	elseif leftSize < 5 then
		objSwf.tfSize.htmlText = string.format(StrConfig["bag39"],useSize,size);
	else
		objSwf.tfSize.htmlText = string.format(StrConfig["bag38"],useSize,size);
	end
end

--显示金币
function UIBag:ShowMoney()
	local objSwf = self.objSwf;
	if not objSwf then return; end 
	local info = MainPlayerModel.humanDetailInfo;
	-- objSwf.btnNumTael.label     = info.eaUnBindGold;
	objSwf.btnNumBindTael.label = info.eaBindGold;
	objSwf.btnNumIngot.label    = info.eaUnBindMoney;
	objSwf.btnNumCashGift.label = info.eaBindMoney;
end

function UIBag:ShowCompoundBtn()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
--	objSwf.btnCompound.visible = false;

	if FuncManager:GetFuncIsOpen(FuncConsts.Smelt) then
		objSwf.btnSmelting.visible = true;
	else
		objSwf.btnSmelting.visible = false;
	end
end

function UIBag:HandleNotification(name,body)
	if not self.bShowState then return; end
	if name == NotifyConsts.BagAdd then
		if body.type == BagConsts.BagType_Role then
			--人身上装备变化时，刷更好装备标志
			self:ShowBetterEquip(body.pos);
		elseif body.type == BagConsts.BagType_Bag then
			self:DoAddItem(body.pos);
			self:ShowBagSize();
		end
	elseif name == NotifyConsts.BagRemove then
		if body.type == BagConsts.BagType_Role then
			--人身上装备变化时，刷更好装备标志
			self:ShowBetterEquip(body.pos);
		elseif body.type == BagConsts.BagType_Bag then
			self:DoRemoveItem(body.pos);
			self:ShowBagSize();
		end
	elseif name == NotifyConsts.BagUpdate then
		if body.type ~= BagConsts.BagType_Bag then return; end
		self:DoUpdateItem(body.pos);
	elseif name == NotifyConsts.BagRefresh then
		if body.type ~= BagConsts.BagType_Bag then return; end
		self:ShowList();
		self:ShowBagSize();
	elseif name == NotifyConsts.BagSlotOpen then
		if body.type ~= BagConsts.BagType_Bag then return; end
		self:DoOpenSlot(body.oldSize,body.newSize);
		self:ShowBagSize();
	elseif name == NotifyConsts.BagItemCDUpdate then
		if body.type ~= BagConsts.BagType_Bag then return; end
		self:ShowList(true);
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaBindGold or body.type==enAttrType.eaBindMoney or 
			body.type==enAttrType.eaUnBindGold or body.type==enAttrType.eaUnBindMoney then
			self:ShowMoney();
		end
	elseif name == NotifyConsts.RespSuccess then
		self:ShowList()
	end
end

function UIBag:ListNotificationInterests()
	return {NotifyConsts.BagAdd,NotifyConsts.BagRemove,NotifyConsts.BagUpdate,NotifyConsts.BagRefresh,
			NotifyConsts.BagSlotOpen,NotifyConsts.BagItemCDUpdate,NotifyConsts.RespSuccess,
			NotifyConsts.PlayerAttrChange};
end

--添加Item
function UIBag:DoAddItem(pos)

	if self.showType ~= BagConsts.ShowType_All then
		self:ShowList();
		return;
	end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
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
	if BagUtil:IsRelic(item:GetTid()) then
		bagSlotVO.relicLv = item:GetParam()
	end
	bagSlotVO.bindState = item:GetBindState();
	bagSlotVO.flags = item.flags;
	objSwf.list.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = objSwf.list:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

--移除Item
function UIBag:DoRemoveItem(pos)
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
function UIBag:DoUpdateItem(pos)
	if self.showType ~= BagConsts.ShowType_All then
		self:ShowList();
		return;
	end
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
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
	if BagUtil:IsRelic(item:GetTid()) then
		bagSlotVO.relicLv = item:GetParam()
	end
	objSwf.list.dataProvider[pos] = bagSlotVO:GetUIData();
	local uiSlot = objSwf.list:getRendererAt(pos);
	if uiSlot then
		uiSlot:setData(bagSlotVO:GetUIData());
	end
end

--检查更好装备
function UIBag:ShowBetterEquip(equipType)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local objSwf = self.objSwf;
	for i,slotVO in ipairs(self.list) do
		if slotVO.opened and slotVO.hasItem then
			local bagItem = bagVO:GetItemByPos(slotVO.pos);
			if bagItem and bagItem:GetShowType()==BagConsts.ShowType_Equip 
				and bagItem:GetCfg().pos==equipType then
				objSwf.list.dataProvider[slotVO.pos] = slotVO:GetUIData();
				local uiSlot = objSwf.list:getRendererAt(slotVO.pos);
				if uiSlot and uiSlot.userdata.isBetter~=slotVO:GetIsBetter() then
					uiSlot:setData(slotVO:GetUIData());
				end
				
			end
		end
	end
end

--开启格子
function UIBag:DoOpenSlot(oldSize,newSize)
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

function UIBag:OnItemRollOver(item)
	local data = item:GetData();
	if not data.opened then 
		local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
		if not bagVO then return; end
		if data.pos == bagVO:GetSize() then
			if data.pos+1 <= BagConsts:GetBagTimeSize(BagConsts.BagType_Bag) then
				local hour,min,sec = CTimeFormat:sec2format(bagVO:GetOpenNextTime());
				local str = string.format(StrConfig["bag32"],data.pos+1,UIStrConfig['bag001'],hour,min,sec);
				TipsManager:ShowBtnTips(str,TipsConsts.Dir_RightDown);
			else
				TipsManager:ShowBtnTips(string.format(StrConfig["bag10"],UIStrConfig['bag001'],UIStrConfig['bag001']),TipsConsts.Dir_RightDown);
			end
		else
			TipsManager:ShowBtnTips(string.format(StrConfig["bag10"],UIStrConfig['bag001'],UIStrConfig['bag001']),TipsConsts.Dir_RightDown);
		end
		return; 
	end;
	if not data.hasItem then return; end;
	TipsManager:ShowBagTips(BagConsts.BagType_Bag,data.pos);
end

function UIBag:OnItemRollOut(item)
	TipsManager:Hide();
end

function UIBag:OnItemDragBegin(item)
	UIBagOper:Hide();
	TipsManager:Hide();
end

function UIBag:OnItemDragEnd(item)
	local itemData = item:GetData();
	--没拖出背包
	local mousePos = UIManager:GetMousePos();
	local x1,y1 = self:GetPos();
	local x2,y2 = x1+self:GetWidth(),y1+self:GetHeight();
	if mousePos.x>x1 and mousePos.x<x2 and mousePos.y>y1 and mousePos.y<y2 then
		return;
	end
	--判断在人物面板内
	if UIRole:IsShow() and UIRoleBasic:IsShow() then
		local x1,y1 = UIRole:GetPos();
		local x2,y2 = x1+UIRole:GetWidth(),y1+UIRole:GetHeight();
		if mousePos.x>x1 and mousePos.x<x2 and mousePos.y>y1 and mousePos.y<y2 then
			if BagUtil:GetItemShowType(itemData.tid)==BagConsts.ShowType_Equip then
				BagController:EquipItem(BagConsts.BagType_Bag,itemData.pos);
				return;
			end
			if BagUtil:IsWing(itemData.tid) then
				BagController:EquipWing(BagConsts.BagType_Bag,itemData.pos);
				return;
			end
			if BagUtil:IsRelic(itemData.tid) then
				BagController:EquipRelic(BagConsts.BagType_Bag, itemData.pos)
				return
			end
		end	
	end
	--判断在天神背包内直接return
	if UITianshenBag:IsShow() then
		local x1,y1 = UITianshenBag:GetPos();
		local x2,y2 = x1+UIRole:GetWidth(),y1+UIRole:GetHeight();
		if mousePos.x>x1 and mousePos.x<x2 and mousePos.y>y1 and mousePos.y<y2 then
			return
		end
	end
	--判断仓库面板内
	if UIStorage:IsShow() then
		local x1,y1 = UIStorage:GetPos();
		local x2,y2 = x1+UIStorage:GetWidth(),y1+UIStorage:GetHeight();
		if mousePos.x>x1 and mousePos.x<x2 and mousePos.y>y1 and mousePos.y<y2 then
			BagController:MoveToStorage(BagConsts.BagType_Bag,itemData.pos);
			return;
		end
	end
	--判断商店面板内
	if UIShopCarryOn:IsShow() then
		local x1,y1 = UIShopCarryOn:GetPos();
		local x2,y2 = x1+UIShopCarryOn:GetWidth(),y1+UIShopCarryOn:GetHeight();
		if mousePos.x>x1 and mousePos.x<x2 and mousePos.y>y1 and mousePos.y<y2 then
			BagController:SellItem(BagConsts.BagType_Bag,itemData.pos)
			return;
		end
	end
	--判断交易面板内
	if UIDeal:IsShow() then
		local x1,y1 = UIDeal:GetPos();
		local x2,y2 = x1+UIDeal:GetWidth(),y1+UIDeal:GetHeight();
		if mousePos.x>x1 and mousePos.x<x2 and mousePos.y>y1 and mousePos.y<y2 then
			BagController:MoveToDealShelves( itemData )
			return;
		end
	end
	--
	BagController:DiscardItem(BagConsts.BagType_Bag, itemData.pos);
end

function UIBag:OnItemDragIn(fromData,toData)
	Debug('拖拽,fromBag:'..fromData.bagType..",fromPos"..fromData.pos..",toBag:"..toData.bagType..",toPos:"..toData.pos);
	--同一格子拖动不处理
	if fromData.bagType==toData.bagType and fromData.pos==toData.pos then
		return;
	end
	--来自背包的
	if fromData.bagType == BagConsts.BagType_Bag then
		if self.showType == BagConsts.ShowType_All then
			--主标签,叠加交换;分标签,不处理
			BagController:SwapItem(fromData.bagType,fromData.pos,toData.bagType,toData.pos);
		end
		return;
	end;
	--来自仓库的
	if fromData.bagType == BagConsts.BagType_Storage then
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
	--来自人物或者坐骑或灵兽
	if fromData.bagType==BagConsts.BagType_Role or fromData.bagType==BagConsts.BagType_Horse 
		or fromData.bagType==BagConsts.BagType_LingShou or fromData.bagType==BagConsts.BagType_LingShouHorse
		or fromData.bagType==BagConsts.BagType_LingZhenZhenYan
		or fromData.bagType==BagConsts.BagType_QiZhan then			
		if self.showType == BagConsts.ShowType_All then
			--主标签,没有东西,交换
			if not toData.hasItem then 
				BagController:SwapItem(fromData.bagType,fromData.pos,toData.bagType,toData.pos);
				return;
			end
			--主标签,有东西,判断装备类型,判断是否可穿戴
			if BagUtil:GetEquipType(fromData.tid) ~= BagUtil:GetEquipType(toData.tid) then
				return;
			end
			if BagUtil:GetEquipCanUse(toData.tid) < 0 then
				return;
			end
			BagController:SwapItem(fromData.bagType,fromData.pos,toData.bagType,toData.pos);
		else
			--分标签,没有东西不处理
			if not toData.hasItem then return; end
			--分标签,不是装备
			if self.showType ~= BagConsts.ShowType_Equip then
				return;
			end
			--分标签,判断装备类型
			if BagUtil:GetEquipType(fromData.tid) ~= BagUtil:GetEquipType(toData.tid) then
				return;
			end
			--分标签,判断是否可穿戴
			if BagUtil:GetEquipCanUse(toData.tid) < 0 then
				return;
			end
			BagController:SwapItem(fromData.bagType,fromData.pos,toData.bagType,toData.pos);
		end
		return;
	end
	if fromData.bagType == BagConsts.BagType_RELIC then
		if self.showType == BagConsts.ShowType_All then
			if not toData.hasItem then
				BagController:SwapItem(fromData.bagType,fromData.pos,toData.bagType,toData.pos);
				return
			end
			if BagUtil:IsRelic(toData.tid) then
				if BagUtil:GetRelicPos(toData.tid) == BagUtil:GetRelicPos(fromData.tid) then
					BagController:SwapItem(fromData.bagType,fromData.pos,toData.bagType,toData.pos)
				end
			end
		end
	end
end

--左键菜单
function UIBag:OnItemClick(item)
	TipsManager:Hide();
	local itemData = item:GetData();
	--快速出售
	if self.isQuickSell then
		if itemData.opened and itemData.hasItem then
			BagController:SellItem(BagConsts.BagType_Bag,itemData.pos);
		end
		return;
	end
	--
	if not itemData.opened then
		UIBagOper:Hide();
		UIBagOpen:Open(BagConsts.BagType_Bag,itemData.pos);
		return;
	end
	if not itemData.hasItem then
		UIBagOper:Hide();
		return;
	end

	if  _sys:isKeyDown(_System.KeyCtrl) then
		ChatQuickSend:SendItem(BagConsts.BagType_Bag,itemData.pos);
		return;
	end
	--锁定物品处理
	local bagVO = BagModel:GetBag(BagConsts.BagType_Bag);
	if not bagVO then return; end
	local bagItem = bagVO:GetItemByPos(itemData.pos);
	if not bagItem then return; end
	if bagItem:GetItemLocked() then
		return true;
	end
	UIBagOper:Open(item.mc,itemData.bagType,itemData.pos);
end

--双击使用
function UIBag:OnItemDoubleClick(item)
	UIBagOper:Hide();
	TipsManager:Hide();
	local itemData = item:GetData();
	--快速出售
	if self.isQuickSell then
		if itemData.opened and itemData.hasItem then
			BagController:SellItem(BagConsts.BagType_Bag,itemData.pos);
		end
		return;
	end
	--
	if not itemData.opened then
		return;
	end
	if not itemData.hasItem then
		return;
	end
	--有仓库时,移动到仓库,先叠加后交换
	if UIStorage:IsShow() then
		BagController:MoveToStorage(BagConsts.BagType_Bag,itemData.pos);
		return;
    end
    --交易面板打开时物品的双击处理
    if UIDeal:IsShow() then
    	BagController:MoveToDealShelves( itemData )
        return;
    end
	--是装备,穿戴
	if BagUtil:GetItemShowType(itemData.tid)==BagConsts.ShowType_Equip then
		BagController:EquipItem(BagConsts.BagType_Bag,itemData.pos);
		return;
    end

    if BagUtil:IsRelic(itemData.tid) then
		BagController:EquipRelic(BagConsts.BagType_Bag,itemData.pos)
		return
	end
	--翅膀,穿戴
	if BagUtil:IsWing(itemData.tid) then
		BagController:EquipWing(BagConsts.BagType_Bag,itemData.pos);
		return;
	end
	BagController:UseItem(BagConsts.BagType_Bag, itemData.pos, 1);
end

--右键使用
function UIBag:OnItemRClick(item)
	TipsManager:Hide();
	UIBagOper:Hide();
	local itemData = item:GetData();
	--快速出售
	if self.isQuickSell then
		if itemData.opened and itemData.hasItem then
			BagController:SellItem(BagConsts.BagType_Bag,itemData.pos);
		end
		return;
	end
	if not itemData.opened then
		return;
	end
	if not itemData.hasItem then
		return;
	end
	--有商店时，卖
	if UIShopCarryOn:IsShow() then
		BagController:SellItem(BagConsts.BagType_Bag,itemData.pos);
		return;
	end
	--有仓库时,移动到仓库,先叠加后交换
	if UIStorage:IsShow() then
		BagController:MoveToStorage(BagConsts.BagType_Bag,itemData.pos);
		return;
    end
    --交易面板打开时物品的右击处理
    if UIDeal:IsShow() then
        BagController:MoveToDealShelves( itemData )
        return;
    end
	--是装备,穿戴
	if BagUtil:GetItemShowType(itemData.tid)==BagConsts.ShowType_Equip then
		BagController:EquipItem(BagConsts.BagType_Bag,itemData.pos);
		return;
	end

	if BagUtil:IsRelic(itemData.tid) then
		BagController:EquipRelic(BagConsts.BagType_Bag,itemData.pos)
		return
	end
	--是翅膀,穿戴
	if BagUtil:IsWing(itemData.tid) then
		BagController:EquipWing(BagConsts.BagType_Bag,itemData.pos);
		return;
	end
	BagController:UseItem(BagConsts.BagType_Bag, itemData.pos, 1);
end

--切换标签
function UIBag:OnTabButtonClick(name)
	self.showType = name;
	if self.tabButton[name] then
		self.tabButton[name].selected = true;
	end
	self:ShowList();
end

--点击关闭
function UIBag:OnBtnCloseClick()
	self:Hide();
end

--整理背包
function UIBag:OnBtnPackClick()
	if UIDeal:IsShow() then
		FloatManager:AddNormal( StrConfig['bag52'] )
		return
	end
	BagController:PackItem(BagConsts.BagType_Bag);
	SoundManager:PlaySfx(2046);
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnPack.disabled = true;
	self.isPacking = true;
	local callBackFunc = function(count)
		local objSwf = self.objSwf;
		if objSwf then
			objSwf.btnPack.label = string.format(UIStrConfig['bag021'],(20-count	));
			objSwf.btnPack.disabled = true;
		end
		if count >= 20 then
			self.isPacking = false;
			if objSwf then
				objSwf.btnPack.disabled = false;
				objSwf.btnPack.label = UIStrConfig['bag009'];
			end	
		end
	end
	callBackFunc(0);
	TimerManager:RegisterTimer(callBackFunc,1000,20);
end
--分解
function UIBag:OnBtnFenjieClick()
	if not UISmithing:IsShow() then
		if self:IsOpenDecomp() then
			self.isOpenSmith = true
			UISmithing:Show();
			self:Hide()
		else
			local openLevel = t_funcOpen[FuncConsts.EquipDecomp].open_level;
			local str = string.format( StrConfig['bag00001'], openLevel)
			FloatManager:AddNormal(str)
		end
	else
		UISmithing:Hide();
	end
end
function UIBag:IsOpenDecomp()
	local openLevel = t_funcOpen[FuncConsts.EquipDecomp].open_level;	
	return MainPlayerModel.humanDetailInfo.eaLevel>=openLevel;
end
--市场
function UIBag:OnBtnShichangClick()
	if not UIConsigmentMain:IsShow() then
		UIConsigmentMain:Show();
		self:Hide()
	else
		UIConsigmentMain:Hide();
	end
end
--点击商店
function UIBag:OnBtnShopClick()
	UIShopCarryOn:OpenShopByType(ShopConsts.T_Consumable)
end

--点击仓库
function UIBag:OnBtnStorageClick()
	if not UIStorage:IsShow() then
		UIStorage:Show();
	else
		UIStorage:Hide();
	end
end

--点击合成
function UIBag:OnBtnCompoundClick()
	FuncManager:OpenFunc(FuncConsts.HeCheng,true);
end

--点击熔炼
function UIBag:OnBtnSmeltClick()
	FuncManager:OpenFunc(FuncConsts.Smelt);
end

--鼠标悬浮货币名称
function UIBag:OnCurrencyBtnRollOver(name)
	local tipsTxt = "";
	if name == "tael" then
		tipsTxt = StrConfig["bag29"];
	elseif name == "bindTael" then
		tipsTxt = StrConfig["bag29"];
	elseif name == "ingot" then
		tipsTxt = StrConfig["bag30"];
	elseif name == "cashGift" then
		tipsTxt = StrConfig["bag31"];
	elseif name == "numTael" then
		tipsTxt = MainPlayerModel.humanDetailInfo.eaUnBindGold;
	elseif name == "numBindTael" then
		tipsTxt = MainPlayerModel.humanDetailInfo.eaBindGold;
	elseif name == "numIngot" then
		tipsTxt = MainPlayerModel.humanDetailInfo.eaUnBindMoney;
	elseif name == "numCashGift" then
		tipsTxt = MainPlayerModel.humanDetailInfo.eaBindMoney;
	end
	TipsManager:ShowTips( TipsConsts.Type_Normal, tipsTxt, TipsConsts.ShowType_Normal, TipsConsts.Dir_RightDown );
end

--鼠标划离货币名称
function UIBag:OnCurrencyBtnRollOut(name)
	TipsManager:Hide();
end

--获取在指定位置的Item,格子开启用
function UIBag:GetItemAtPos(pos,unScroll)
	if not self.isFullShow then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not unScroll then
		objSwf.list:scrollToIndex(pos);
	end
	local uiSlot = objSwf.list:getRendererAt(pos);
	return uiSlot;
end

--背包红点提示
--adder:jiayong
--date:2016/12/6 20:20:00
UIBag.BagTimerKey = nil;

function UIBag:InitBagRedPoint(  )
	local objSwf = self.objSwf
	if not objSwf then return; end
	
	if BagUtil:GetBlueEquipCount() and BagUtil:GetBlueEquipCount()>0 then
		PublicUtil:SetRedPoint(objSwf.btnFenjie, nil, 1)
	else
		PublicUtil:SetRedPoint(objSwf.btnFenjie, nil, 0)
	end
end

function UIBag:RegisterTime()
	self.BagTimerKey = TimerManager:RegisterTimer(function()
		self:InitBagRedPoint()
	end,1000,0); 
end


function UIBag:UnRegisterTime(  )
	if self.BagTimerKey then
		TimerManager:UnRegisterTimer(self.BagTimerKey);
		self.BagTimerKey = nil;
	end
end

--------------------------------快速出售处理-------------------------------------
--点击快速出售
-- function UIBag:OnBtnQuickSellClick()
	--self:SetQuickSell(not self.isQuickSell);
	-- self:ShowList(true);
-- end

--设置快速出售状态
function UIBag:SetQuickSell(quickSell)
	self.isQuickSell = quickSell;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:SetDragEnabled(not quickSell);
	if quickSell then
		objSwf.btnQuickSell.label = StrConfig["bag37"];
	-- else
		-- objSwf.btnQuickSell.label = StrConfig["bag36"];
	end
	if quickSell then
		objSwf.btnPack.disabled = quickSell;
	else
		objSwf.btnPack.disabled = self.isPacking;
	end
	objSwf.btnShop.disabled = quickSell;
	objSwf.btnStorage.disabled = quickSell;
	objSwf.btnCompound.disabled = quickSell;
	objSwf.mcQuickSell._visible = quickSell;
	objSwf.maskQuickSell.visible = quickSell;
	--self:SetQuickSellMask();
	if quickSell then
		CCursorManager:AddState("sell");
	else
		CCursorManager:DelState("sell");
	end
end

--设置快速出售的Mask
function UIBag:SetQuickSellMask()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local x,y = self:GetPos();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.maskQuickSell._x = -x;
	objSwf.maskQuickSell._y = -y;
	objSwf.maskQuickSell._width = wWidth;
	objSwf.maskQuickSell._height = wHeight;
end

function UIBag:OnMaskQuickSellClick()
	FloatManager:AddNormal(StrConfig["bag47"]); 
end;
