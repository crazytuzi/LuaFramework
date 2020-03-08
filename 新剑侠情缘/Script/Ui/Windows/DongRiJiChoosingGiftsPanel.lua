local tbUi = Ui:CreateClass("DRJ_ChoosingGiftsPanel");
local tbAct = Activity.DongRiJiAct;

function tbUi:OnOpen()
end

function tbUi:OnOpenEnd()
	self:FlushPanel();
end

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end;

	BtnPurchase = function(self)
		self:OpenShop();
	end;

	BtnDetermine = function(self)
		self:Comfirm();
	end;
}

function tbUi:OpenShop()
	Ui:OpenWindow("CommonShop", "Treasure")
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:Comfirm()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:ChooseGift(nIdx)
	Log(self.tbTmpId[i]);
end

function tbUi:FlushPanel()
	self.tbTmpId = {};
	local tbCollect = {};
	for nFDID , _ in pairs(tbAct.tbFuDaiSetting) do
		local nHaveNum = me.GetItemCountInAllPos(nFDID);
		if nHaveNum > 0 then
			table.insert(tbCollect, {nFDID,nHaveNum});
		end
	end
	table.sort( tbCollect, function (a, b) return a[1] < b[1] end )
	for i = 1 , 9 do
		if tbCollect[i] then
			self.pPanel:SetActive("GiftGroup"..i,true);
			local nFDID = tbCollect[i][1];
			local nHaveNum = tbCollect[i][2] or 1;
			local fnClick = function(itemObj)
				tbAct:SelectGift(nFDID);
				self.pPanel:Toggle_SetChecked("GiftGroup" .. i , true);
				self.pPanel:Button_SetCheck("GiftGroup"..i , true);
				Ui:OpenWindow("ItemTips", "Item", nil, nFDID, me.nFaction, me.nSex);
			end
			local itemObj = self["Gift"..i];
			if itemObj then 
				itemObj:SetItemByTemplate(nFDID,nHaveNum,me.nFaction, me.nSex);
				itemObj.fnClick = fnClick;
				self.pPanel:Toggle_SetChecked("GiftGroup" .. i , false);
				self.pPanel:Button_SetCheck("GiftGroup"..i , false);
			end
		else
			self.pPanel:SetActive("GiftGroup"..i,false);
		end
	end
end