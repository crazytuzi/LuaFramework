local tbSpeaker = Item:GetClass("Speaker");

function tbSpeaker:OnUse(it)

	
	local nBuyChatCount = KItem.GetItemExtParam(it.dwTemplateId, 1);
	local nType = KItem.GetItemExtParam(it.dwTemplateId, 2);

	if nType == ChatMgr.ChannelType.Public then
		ChatMgr:AddPublicChatCount(me, nBuyChatCount);
		me.CenterMsg(string.format("增加了%d次世界频道发言机会", nBuyChatCount));
		return 1;
	elseif nType == ChatMgr.ChannelType.Color then
        if me.GetVipLevel() < 6 then
		    me.CenterMsg("功能未开放!");
			return 1;
        end
		
		ChatMgr:AddColorChatCount(me, nBuyChatCount);
		me.CenterMsg(string.format("增加了%d次彩聊频道发言机会", nBuyChatCount));
		me.CallClientScript("ChatMgr:UpdateColorMsgCount");
		return 1;
	elseif nType == ChatMgr.ChannelType.Cross then
        if me.GetVipLevel() < 6 then
		    me.CenterMsg("功能未开放!!");
			return 1;
        end
		ChatMgr:AddCrossChatCount(me, nBuyChatCount);
		me.CenterMsg(string.format("增加了%d次主播频道发言机会", nBuyChatCount));
		return 1;
	else
		me.CenterMsg("未知喇叭类型");
	end
end