local tbUi = Ui:CreateClass("KinChangeCareer");

local function GetItems(nCareer)
	local tbItems = {};
	local tbMemberList = Kin:GetMemberList();
	for _, tbData in pairs(tbMemberList or {}) do
		if tbData.nCareer == nCareer then
			table.insert(tbItems, {
				nMemberId = tbData.nMemberId,
				szName = tbData.szName});
		end
	end

	return tbItems;
end

function tbUi:OnOpen(nMemberId, nTargetCareer, szName)
	self.nMemberId = nMemberId;
	self.szName = szName;
	self.nTargetCareer = nTargetCareer;
	self.nTargetMemberId = nil;
	self.pPanel:Label_SetText("TxtTargetCareer", Kin.Def.Career_Name[nTargetCareer]);

	local tbItems = GetItems(nTargetCareer);

	local fnSelectItem = function (itemObj)
		self.nTargetMemberId = itemObj.nMemberId;
	end

	local fnSetItem = function (itemObj, nIdx)
		local tbItem = tbItems[nIdx];
		itemObj.pPanel:Label_SetText("Name", tbItem.szName);
		local nVipLevel = tbItem.nVipLevel
		if not nVipLevel or  nVipLevel == 0 then
			itemObj.pPanel:SetActive("VIP", false)
		else
			itemObj.pPanel:SetActive("VIP", true)
			itemObj.pPanel:Sprite_Animation("VIP",  Recharge.VIP_SHOW_LEVEL[nVipLevel]);
		end
		itemObj.pPanel:Label_SetText("Career", Kin.Def.Career_Name[nTargetCareer]);
		itemObj.pPanel:Toggle_SetChecked("Main", self.nTargetMemberId == tbItem.nMemberId);
		itemObj.nMemberId = tbItem.nMemberId;
		itemObj.pPanel.OnTouchEvent = fnSelectItem;
	end

	self.ScrollView:Update(#tbItems, fnSetItem);
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnConfirm()
	if not self.nTargetMemberId then
		me.CenterMsg("请选择替换目标");
		return;
	end

	Kin:ChangeCareer(self.nMemberId, self.nTargetCareer, self.nTargetMemberId, self.szName);
	Ui:CloseWindow("KinChangeCareer");
end

function tbUi.tbOnClick:BtnCancel()
	Ui:CloseWindow("KinChangeCareer");
end
