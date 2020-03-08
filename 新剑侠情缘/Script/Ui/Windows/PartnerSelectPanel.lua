
local tbUi = Ui:CreateClass("PartnerSelectPanel");

function tbUi:OnOpen(tbSelectList, fnOnSelect, bShowWeaponState)
	if not tbSelectList or #tbSelectList <= 0 or not fnOnSelect then
		return 0;
	end

	self.tbSelectList = tbSelectList;
	self.bShowWeaponState = bShowWeaponState;
	self.fnOnSelect = fnOnSelect;
	self:Update();
end

function tbUi:Update()
	local fnSetItem = function (itemObj, nIndex)
		local pPartner = me.GetPartnerObj(self.tbSelectList[nIndex]);
		itemObj.pPanel:Label_SetText("PartnerName", pPartner.szName);
		itemObj.pPanel:Label_SetText("Fighting", string.format("战力：%s", pPartner.nFightPower));
		itemObj.pPanel:SetActive("Mark", pPartner.nBYState == 1 and true or false);
		itemObj.pPanel:SetActive("Weapon", self.bShowWeaponState and true or false);
		if self.bShowWeaponState then
			local bHasWeapon = true;
			if pPartner.nWeaponState ~= 1 then
				local nWeaponItemId = Partner.tbPartner2WeaponItem[pPartner.nTemplateId];
				if nWeaponItemId then
					local nCCount = me.GetItemCountInBags(nWeaponItemId);
					bHasWeapon = nCCount > 0;
				end
			end

			itemObj.pPanel:Sprite_SetGray("Weapon", not bHasWeapon);
		end

		itemObj.PartnerHead:SetPlayerPartner(self.tbSelectList[nIndex]);
		itemObj.pPanel.OnTouchEvent = function ()
			self.fnOnSelect(self.tbSelectList[nIndex]);
			Ui:CloseWindow(self.UI_NAME);
			return;
		end
	end

	self.ScrollView:Update(self.tbSelectList, fnSetItem)
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick = tbUi.tbOnClick or {};
tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME);
end
