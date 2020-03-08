
local tbItem = Item:GetClass("PlatinumEvoMaterial");

function tbItem:GetUseSetting(nTemplateId, nItemId)
	local tbUseSetting = {szFirstName = "使用"};
	tbUseSetting.fnFirst = function ()
		Ui:CloseWindow("ItemTips")
		Ui:OpenWindow("EquipmentEvolutionPanel", "Type_EvolutionPlatinum")
	end
	
	if GetTimeFrameState("OpenLevel89") == 1 then
		tbUseSetting.szFirstName = "打造"
		tbUseSetting.szSecondName = "升阶"
		tbUseSetting.fnSecond = function ()
			--判断下有无白金装备
			local tbEquips = me.GetEquips()
			local nFindPlatinumItemId;
			for i,nEquipId in ipairs(tbEquips) do
				local pItem = me.GetItemInBag(nEquipId);
				if pItem and pItem.nDetailType == Item.DetailType_Platinum then
					nFindPlatinumItemId = pItem.dwId;
					break;
				end
			end
			if not nFindPlatinumItemId then
				me.CenterMsg("您身上没有白金装备")
				return
			end

			Ui:CloseWindow("ItemTips")
			Ui:OpenWindow("EquipmentEvolutionPanel", "Type_Upgrade", nFindPlatinumItemId)	
		end
	end
	

	return tbUseSetting;		
end

