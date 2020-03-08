local tbItem = Item:GetClass("BeautyPageantPaper")
local tbAct = Activity.BeautyPageant

function tbItem:GetUseSetting(nTemplateId)
	if not tbAct:IsInProcess() or not tbAct:IsSignUp() then
		return {}
	end

	local tbUseSetting = 
	{
		["szFirstName"] = "我的页面",
		["fnFirst"] = function ()
			Ui.HyperTextHandle:Handle(string.format("[url=openBeautyUrl:PlayerPage, %s][-]", string.format(tbAct.szPlayerUrl, me.dwID, Sdk:GetServerId())));
			Ui:CloseWindow("ItemTips")
		end,

		["szSecondName"] = "分享",
		["fnSecond"] = function ()
			local nChannel = ChatMgr.ChannelType.Public
			if Kin:HasKin() then
				nChannel = ChatMgr.ChannelType.Kin
			end
			Ui:OpenWindow("ChatLargePanel", nChannel, nil, "OpenEmotionLink")
			Ui:CloseWindow("ItemTips")
		end,
	}

	return tbUseSetting;		
end

function tbItem:GetIntrol(dwTemplateId)

	local tbTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.LOCAL]
	local szMatch = "海选赛（本服评选）"
	if dwTemplateId == tbAct.SIGNUP_ITEM_FINAL then
		tbTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.FINAL]
		szMatch = "决赛"
	end

	return string.format("[FFFE0D]%s：%s~%s[-]\n\n记录着参赛佳人信息的纸张，可以通过它在任意聊天频道宣传个人的选美信息，或打开自己的参赛页面", szMatch, Lib:TimeDesc10(tbTime[1]), Lib:TimeDesc10(tbTime[2]+1))
end
