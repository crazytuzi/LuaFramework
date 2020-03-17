--[[
背包操作面板
lizhuangzhuang
2014年8月4日11:01:32
]]

_G.UIBagOper = BaseUI:new("UIBagOper");

UIBagOper.slotMc = nil;--mc
UIBagOper.bagType = 0;--背包类型
UIBagOper.pos = 0;--格子位置
UIBagOper.operList = nil;--操作列表

function UIBagOper:Create()
	self:AddSWF("bagOperPanel.swf",true,"top");
end

function UIBagOper:OnLoaded(objSwf)
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end;
end

function UIBagOper:OnShow()
	self:DoShowPanel();
end

function UIBagOper:OnHide()
	self.slotMc = nil;
end

--在目标位置打开操作面板
function UIBagOper:Open(slotMc,bagType,pos)
	self.slotMc = slotMc;
	self.bagType = bagType;
	self.pos = pos;
	if self:IsShow() then
		self:DoShowPanel();
	else
		self:Show();
	end
end

--点击其他地方,关闭
function UIBagOper:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self:GetSWF("UIBagOper");
	if not objSwf then return; end
	if name == NotifyConsts.StageClick then
		if not self.slotMc then
			self:Hide();
			return;
		end
		if not self.slotMc._target then return; end
		local slotTarget = string.gsub(self.slotMc._target,"/",".");
		local listTarget = string.gsub(objSwf._target, "/",".");
		if string.find(body.target,slotTarget) or string.find(body.target,listTarget) then
			return
		end
		self:Hide();
	elseif name == NotifyConsts.StageFocusOut then
		self:Hide();
	end
end

function UIBagOper:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end

function UIBagOper:DoShowPanel()
	local objSwf = self:GetSWF("UIBagOper");
	if not objSwf then return; end
	local pos = nil;
	if self.slotMc then
		pos = UIManager:GetMcPos(self.slotMc);
		local width = self.slotMc.width or self.slotMc._width;
		local height = self.slotMc.height or self.slotMc._height;
		pos.x = pos.x + width/2;
		pos.y = pos.y + height;
	else
		pos = _sys:getRelativeMouse();
	end
	objSwf._x = pos.x;
	objSwf._y = pos.y-5;
	
	self.operList = BagOperUtil:GetOperList(self.bagType,self.pos);
	
	local len = #self.operList;
	if len <= 0 then
		self:Hide();
		return;
	end
	objSwf.list.dataProvider:cleanUp();
	for i=1,len do
		objSwf.list.dataProvider:push(self.operList[i].name);
	end
	objSwf.list.height = len*20+10;
	objSwf.bg.height = len*20+10;
	objSwf.list:invalidateData();
end

--点击列表
function UIBagOper:OnListItemClick(e)
	self:Hide();
	if not self.operList[e.index+1] then
		return;
	end
	local oper = self.operList[e.index+1].oper;
	if oper == BagConsts.Oper_Store then
		BagController:MoveToStorage(self.bagType,self.pos);
	elseif oper == BagConsts.Oper_UnStore then
		BagController:MoveToBag(self.bagType,self.pos);
	elseif oper == BagConsts.Oper_Use then
		BagController:UseItem(self.bagType,self.pos,1);
	elseif oper == BagConsts.Oper_BatchUse then
		UIBagBatchUse:Open(self.bagType,self.pos);
	elseif oper == BagConsts.Oper_Split then
		UIBagSplit:Open(self.bagType,self.pos);
	elseif oper == BagConsts.Oper_Equip then
		BagController:EquipItem(self.bagType,self.pos)
	elseif oper == BagConsts.Oper_UnEquip then
		BagController:UnEquipItem(self.bagType,self.pos);
	elseif oper == BagConsts.Oper_Compound then
		local bagVO = BagModel:GetBag(self.bagType);
		if not bagVO then return; end
		local item = bagVO:GetItemByPos(self.pos);
		if not item then return; end
		FuncManager:OpenFunc(FuncConsts.HeCheng,false,BagModel.compoundMap[item:GetTid()]);
	elseif oper == BagConsts.Oper_Show then
		ChatQuickSend:SendItem(self.bagType,self.pos);
	elseif oper == BagConsts.Oper_Destroy then
		BagController:DiscardItem(self.bagType,self.pos);
	elseif oper == BagConsts.Oper_Sell then
		BagController:SellItem(self.bagType,self.pos);
	elseif oper == BagConsts.Oper_EquipWing then
		BagController:EquipWing(self.bagType,self.pos)
	elseif oper == BagConsts.Oper_EquipRelic then
		BagController:EquipRelic(self.bagType,self.pos)
	elseif oper == BagConsts.Oper_RelicUp then
		local bagVO = BagModel:GetBag(self.bagType)
		local item = bagVO:GetItemByPos(self.pos)
		if not item then return end
		UIRelicView:OpenView(item)
	elseif oper == BagConsts.Oper_CardCom then
		UINewTianshenCompose:Show()
	end
end



