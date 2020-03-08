local tbItem = Item:GetClass("GoodVoicePaper")
local tbAct = Activity.GoodVoice

function tbItem:GetUseSetting(nTemplateId)
	if not tbAct:IsInProcess() or not tbAct:IsSignUp() then
		return {}
	end

	local tbUseSetting = 
	{
		["szFirstName"] = "我的页面",
		["fnFirst"] = function ()
			Ui.HyperTextHandle:Handle(string.format(tbAct:GetPlayerPage(me.dwID, Sdk:GetUid())));
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
	if dwTemplateId == tbAct.SIGNUP_ITEM_SEMI_FINAL then
		tbTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.SEMI_FINAL]
		szMatch = "复赛"
	elseif dwTemplateId == tbAct.SIGNUP_ITEM_FINAL then
		tbTime = tbAct.STATE_TIME[tbAct.STATE_TYPE.FINAL]
		szMatch = "决赛"
	end
	return string.format("[FFFE0D]%s：%s~%s[-]\n\n记录着好声音参赛选手信息的手册，可以通过它在任意聊天频道宣传个人的最美声音或打开自己的参赛页面。", szMatch, Lib:TimeDesc10(tbTime[1]), Lib:TimeDesc10(tbTime[2]+1))
end