
local tbUi = Ui:CreateClass("PartnerSelectSkillBook");

function tbUi:OnOpen(nPartnerId, tbItemList)
	self.nPartnerId = nPartnerId;
	local pPartner = me.GetPartnerObj(nPartnerId);
	if not pPartner or not tbItemList then
		return 0;
	end

	self.tbItemList = tbItemList;
	self.nItemId = nil;
	self:Update();
end

function tbUi:Update()
	local function fnOnSelect(itemObj)
		for i = 0, 1000 do
			local item = self.SkillBookScrollView.Grid["Item" .. i];
			if not item then
				break;
			end

			item.pPanel:Button_SetCheck("Main", itemObj.nItemId == item.nItemId);
		end

		self.nItemId = itemObj.nItemId;
	end

	local function fnSetItem(itemObj, index)
		local nItemId = self.tbItemList[index];
		local pItem = KItem.GetItemObj(nItemId);

		itemObj.nItemId = nItemId;
		itemObj.szName = pItem.szName;
		itemObj.pPanel:Label_SetText("SkillBookName", pItem.szName);
		itemObj.pPanel:Button_SetCheck("Main", self.nItemId == nItemId);
		itemObj.itemframe:SetItem(nItemId);
		itemObj.itemframe.fnClick = itemObj.itemframe.DefaultClick;
		itemObj.pPanel.OnTouchEvent = fnOnSelect;
	end

	self.SkillBookScrollView:Update(self.tbItemList, fnSetItem);
end

function tbUi:OnScreenClick(szClickUi)
	Ui:CloseWindow(self.UI_NAME);
end


tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnSure = function (self)
	if not self.nItemId or self.nItemId <= 0 then
		me.CenterMsg("请选择要使用的技能书");
		return;
	end

	local bRet, _, _, nMustPos = Partner:CheckCanUseSkillBook(me, self.nPartnerId, self.nItemId)
	if bRet then
		RemoteServer.CallPartnerFunc("UseSkillBook", self.nPartnerId, self.nItemId, nMustPos);
	end

	Ui:CloseWindow(self.UI_NAME);
end
