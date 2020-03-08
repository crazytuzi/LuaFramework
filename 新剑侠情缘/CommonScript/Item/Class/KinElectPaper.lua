local tbItem = Item:GetClass("KinElectPaper")

function tbItem:GetUseSetting(nTemplateId)
	local tbAct = Activity.KinElect
	if not tbAct:IsInProcess() or not tbAct:IsSignUp() then
		return {}
	end

	local tbUseSetting =
	{
		["szFirstName"] = "打开",
		["fnFirst"] = function ()
			Ui.HyperTextHandle:Handle(string.format("[url=openKinElectPaperUrl:PlayerPage, %s][-]", string.format(tbAct.szPaperUrl, me.dwID, Sdk:GetServerId())));
			Ui:CloseWindow("ItemTips")
		end,
	}

	return tbUseSetting;
end

function tbItem:GetIntrol(dwTemplateId)
	local tbAct = Activity.KinElect
	local tbTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.FIRST_1]
	local szMatch = "初赛"
	if dwTemplateId == tbAct.SIGNUP_ITEM_SECOND then
		tbTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.SECOND_1]
		szMatch = "复赛"
	elseif dwTemplateId == tbAct.SIGNUP_ITEM_THIRD then
		tbTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.THIRD_1]
		szMatch = "决赛"
	end

	return string.format("[FFFE0D]%s：%s~%s[-]\n\n使用后打开应援页面，应援达一定数量可领取奖励。", szMatch, Lib:TimeDesc10(tbTime[1]), Lib:TimeDesc10(tbTime[2]+1))
end
