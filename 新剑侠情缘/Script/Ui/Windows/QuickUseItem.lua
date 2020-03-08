
local tbUi = Ui:CreateClass("QuickUseItem");

function tbUi:OnOpen(nItemId, szBtnName, bCantClose)
	self.nItemId = nItemId;
	self.szBtnName = szBtnName or "使用";
	self.bCantClose = bCantClose
	self:Update();
end

function tbUi:OnClose()
	self.nItemId = nil;
	self.pPanel:Label_SetText("ItemName", "");
	self.itemframe:Clear();
end

function tbUi:Update(szBtnName)
	local pItem = KItem.GetItemObj(self.nItemId or -1);
	if not pItem then
		Timer:Register(1, Ui.CloseWindow, Ui, "QuickUseItem");
		return;
	end

	self.szBtnName = szBtnName or self.szBtnName;
	self.pPanel:Button_SetText("BtnUse", self.szBtnName);
	self.pPanel:Label_SetText("ItemName", pItem.szName);
	self.itemframe:SetItem(self.nItemId);
	self.itemframe.fnClick = self.itemframe.DefaultControls;
end

tbUi.tbOnClick = {};
tbUi.tbOnClick.BtnUse = function (self)
	if not self.nItemId or not KItem.GetItemObj(self.nItemId) then
		Ui:CloseWindow("QuickUseItem");
		return
	end 
	RemoteServer.UseItem(self.nItemId);
end

tbUi.tbOnClick.BtnClose = function (self)
	if self.bCantClose then
		return
	end
	Ui:CloseWindow("QuickUseItem");
end

