local tbItem = Item:GetClass("KinElectVote")

function tbItem:GetUseSetting(nTemplateId)
	local tbAct = Activity.KinElect
	if not tbAct:IsInProcess() then
		return {}
	end

	return {
		["szFirstName"] = "投票",
		["fnFirst"] = function ()
			Pandora:OpenFamilySelect()
			Ui:CloseWindow("ItemTips")
		end,
	}
end