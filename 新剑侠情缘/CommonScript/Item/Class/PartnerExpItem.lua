
local tbItem = Item:GetClass("PartnerExpItem");

tbItem.nVipLevel = 13;
tbItem.nAddPrecent = 1.2;

function tbItem:OnUse(pItem)
	me.CallClientScript("Ui:OpenWindow", "PartnerAddExpPanel", pItem.dwId);
end

function tbItem:GetUseSetting(nTemplateId, nItemId)
	if Ui:WindowVisible("Partner") then
		return {};
	end

	local function fnFirst()
		Ui:OpenWindow("Partner");
		Ui:CloseWindow("ItemTips");
	end

	return { szFirstName = "使用", fnFirst = fnFirst};
end

function tbItem:GetExpInfo(nItemId, nTemplateId, pPlayer)
	if nItemId and nItemId > 0 then
		local pItem = KItem.GetItemObj(nItemId);
		if not pItem or pItem.szClass ~= "PartnerExpItem" then
			return 0;
		end

		nTemplateId = pItem.dwTemplateId;
	end

	local tbBaseInfo = KItem.GetItemBaseProp(nTemplateId or 0);
	if not tbBaseInfo or not tbBaseInfo.szClass or tbBaseInfo.szClass ~= "PartnerExpItem" then
		return 0;
	end

	local nBaseExp = tbBaseInfo.nValue * Partner.nValueToBaseExp;
	if pPlayer and pPlayer.GetVipLevel() >= self.nVipLevel then
		nBaseExp = nBaseExp * self.nAddPrecent;
	end
	return nBaseExp;
end
