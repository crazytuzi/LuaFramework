--[[
道具存入数量选择窗口
wangshuai
]]
_G.UIWarehouseWindow = BaseUI:new("UIWarehouseWindow")

UIWarehouseWindow.itemUid = nil;

function UIWarehouseWindow:Create()
	self:AddSWF("unionWarehouseNumWindow.swf",nil,nil)
end;

function UIWarehouseWindow:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:Hide() end;
	objSwf.btnConfirm.click = function() self:BtnOk()end;
	objSwf.btnCancel.click = function() self:BtnNo() end;
	objSwf.labelNameKey.text = StrConfig["unionwareHouse510"];
	objSwf.tfInfo.text = "";
end;

function UIWarehouseWindow:OnShow() 
	self:SetUiData();
end;

function UIWarehouseWindow:OnHide()
	self.itemUid = nil
	self.itemMaxNum = 0;
end;

function UIWarehouseWindow:BtnOk()
	local objSwf = self.objSwf;
	self.backFun(objSwf.nsNum.value);
	self:Hide();
end;

function UIWarehouseWindow:BtnNo()
	self:Hide();
end;

function UIWarehouseWindow:SetItemUid(id,MaxNum,fun,type)
	if not id then return end;
	if not t_item[toint(id)] then 
		print("ERROR: cur id at t_item is nil",id)
		return false
	end;
	self.itemUid = id;
	self.itemMaxNum = MaxNum;
	self.backFun = fun;
	self.type = type;

	if self:IsShow() then 
		self:SetUiData();
	else
		self:Show();
	end;
	return true;
end;

function UIWarehouseWindow:SetUiData()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	--放入1， 取出2
	objSwf.bg.name_mc:gotoAndStop(self.type)

	--
	objSwf.nsNum.minimum = 1;
	objSwf.nsNum.maximum = self.itemMaxNum;
	objSwf.nsNum.value = 1;

	local itemConfig = t_item[self.itemUid];
	if itemConfig then
		-- objSwf.labelContent.text = string.format(StrConfig["bag9"],itemConfig.name);
		objSwf.txtOper.text = StrConfig["unionwareHouse509"];
		objSwf.txtName.text = itemConfig.name;
		objSwf.txtName.textColor = TipsConsts:GetItemQualityColorVal( itemConfig.quality );
		--显示物品图标
		local slotVO = RewardSlotVO:new();
		slotVO.id = self.itemUid;
		slotVO.count = 0;
		objSwf.item:setData( slotVO:GetUIData() );
	end
	
end;
