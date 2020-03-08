
local tbItem = Item:GetClass("AddTitleItem");
tbItem.nExtTitleId = 1;
tbItem.nExtTime = 2;

function tbItem:OnUse(it)
	local nTitleId    = KItem.GetItemExtParam(it.dwTemplateId, self.nExtTitleId);
	local nTime = KItem.GetItemExtParam(it.dwTemplateId, self.nExtTime);
	
	if nTitleId <= 0 then
		Log("Error AddTitleItem Not nTitleId", it.dwTemplateId, nTitleId);
		return;
	end

	local bOk = me.AddTitle(nTitleId, nTime, false, true)
	Log("AddTitleItem", me.dwID, nTitleId, nTime, tostring(bOk))
	return bOk and 1 or 0
end

function tbItem:GetUseSetting(nItemTemplateId, nItemId)
	local tbSetting = {szFirstName = "使用", fnFirst = "UseItem"}
	if Gift:GetMailGiftItemInfo(nItemTemplateId) then
		tbSetting = {
	        szFirstName = "赠送",
	        fnFirst = function()
	            Ui:OpenWindow("GiftSystem")
	            Ui:CloseWindow("ItemTips")
	        end,
	        szSecondName = "使用",
	        fnSecond = "UseItem",
	    }
	end
	return tbSetting
end