local tbItem = Item:GetClass("PartnerProtentailItem");

function tbItem:GetUseSetting(nTemplateId, nItemId)
	if Ui:WindowVisible("Partner") or not nItemId or nItemId <= 0 then
		return {};
	end

	local function fnFirst()
		Ui:OpenWindow("Partner");
		Ui:CloseWindow("ItemTips");
	end

	return { szFirstName = "使用", fnFirst = fnFirst};
end

local tbReinitItem = Item:GetClass("PartnerReinitItem");
function tbReinitItem:GetUseSetting(nTemplateId, nItemId)
	if Ui:WindowVisible("Partner") or not nItemId or nItemId <= 0 then
		return {};
	end

	local function fnFirst()
		Ui:OpenWindow("Partner");
		Ui:CloseWindow("ItemTips");
	end

	return { szFirstName = "使用", fnFirst = fnFirst};
end