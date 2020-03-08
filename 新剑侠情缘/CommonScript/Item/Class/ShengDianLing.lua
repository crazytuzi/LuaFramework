local tbItem = Item:GetClass("ShengDianLing")

function tbItem:OnUse(pItem)
	if not pItem.dwTemplateId then 
		return
	end
	local tbAct = Activity:GetClass("ShangShengDian")
	tbAct:UseShengDianLing()
	return 1
end


function tbItem:GetUseSetting(nTemplateId, nItemId)

	return {
			szFirstName = "提交", 
			fnFirst = function() 
						RemoteServer.UseItem(nItemId)
						Ui:CloseWindow("ItemTips")
						end
		}
end