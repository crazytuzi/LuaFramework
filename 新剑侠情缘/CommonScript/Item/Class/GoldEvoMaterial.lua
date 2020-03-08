
local tbItem = Item:GetClass("GoldEvoMaterial");

function tbItem:GetUseSetting(nTemplateId, nItemId)
	local tbUseSetting = {szFirstName = "使用"};
	tbUseSetting.fnFirst = function ()
		Ui:CloseWindow("ItemTips")
		Ui:OpenWindow("EquipmentEvolutionPanel", "Type_Evolution")
	end
	
	if GetTimeFrameState("OpenLevel89") == 1 then
		tbUseSetting.szFirstName = "打造"
		tbUseSetting.szSecondName = "升阶"
		tbUseSetting.fnSecond = function ()
			Ui:CloseWindow("ItemTips")
			Ui:OpenWindow("EquipmentEvolutionPanel", "Type_Upgrade")	
		end
	end
	

	return tbUseSetting;		
end

