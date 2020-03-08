local tbUnidentify = Item:GetClass("UnidentifyPiFeng");


function tbUnidentify:GetUseSetting(nTemplateId, nItemId)
	local fnSell = function (  )
		if not Compose.UnCompose:CanUnCompose(nTemplateId) then
			me.CenterMsg("该道具暂时还不可兑换")
			return
		end
		Compose.UnCompose:DoRequestUncompose(nItemId)
	end
	local fnUse = function (  )
		local pItem = me.GetItemInBag(nItemId)
		if not pItem then
			me.CenterMsg("道具已不存在")
			return
		end
		local nRet, szMsg = Item:CheckUsable(pItem, pItem.szClassName)
		if nRet ~= 1 then
			if szMsg then
				me.CenterMsg(szMsg)
			end
			return
		end
		Ui:CloseWindow("ItemTips")
		Ui:OpenWindow("CloakAppraisalPanel", nItemId)
	end
	if Compose.UnCompose:CanUnCompose(nTemplateId) then
		return {szFirstName = "拆分", fnFirst = fnSell, szSecondName = "鉴定", fnSecond = fnUse };
	else
		return {szFirstName = "鉴定", fnFirst = fnUse };
	end
end
