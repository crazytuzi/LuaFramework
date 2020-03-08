local tbNpc = Npc:GetClass("KinElectStatue")
local tbAct = MODULE_GAMESERVER and Activity:GetClass("KinElect") or Activity.KinElect

function tbNpc:OnDialog()
	if not him.tbKin or not him.tbStatueInfo then
		return
	end

	local OptList = {
		{Text = "我再看看"},
	};

	local bOwner = false

	local szDefaultText = ""
	local nType = him.tbKin.nType
	if nType == tbAct.WINNER_TYPE.FIRST_1 then
		szDefaultText = string.format("[FF69B4]「家族评选初赛本服第一家族领袖」[-]%s", him.tbKin.szPlayerName);
	elseif nType == tbAct.WINNER_TYPE.SECOND_1 then
		szDefaultText = string.format("[FF69B4]「家族评选复赛总冠军家族领袖」[-]%s\n来自：[FFFE0D]%s[-]", him.tbKin.szPlayerName, him.tbKin.szServerName);
	elseif nType == tbAct.WINNER_TYPE.SECOND_SUB_1_1 then
		szDefaultText = string.format("[FF69B4]「家族评选复赛主题冠军家族领袖」[-]%s\n来自：[FFFE0D]%s[-]", him.tbKin.szPlayerName, him.tbKin.szServerName);
	elseif nType == tbAct.WINNER_TYPE.SECOND_SUB_1_2 then
		szDefaultText = string.format("[FF69B4]「家族评选复赛主题冠军家族领袖」[-]%s\n来自：[FFFE0D]%s[-]", him.tbKin.szPlayerName, him.tbKin.szServerName);
	elseif nType == tbAct.WINNER_TYPE.SECOND_SUB_1_3 then
		szDefaultText = string.format("[FF69B4]「家族评选复赛主题冠军家族领袖」[-]%s\n来自：[FFFE0D]%s[-]", him.tbKin.szPlayerName, him.tbKin.szServerName);
	elseif nType == tbAct.WINNER_TYPE.SECOND_SUB_1_4 then
		szDefaultText = string.format("[FF69B4]「家族评选复赛主题冠军家族领袖」[-]%s\n来自：[FFFE0D]%s[-]", him.tbKin.szPlayerName, him.tbKin.szServerName);
	elseif nType == tbAct.WINNER_TYPE.SECOND_SUB_1_5 then
		szDefaultText = string.format("[FF69B4]「家族评选复赛主题冠军家族领袖」[-]%s\n来自：[FFFE0D]%s[-]", him.tbKin.szPlayerName, him.tbKin.szServerName);
	elseif nType == tbAct.WINNER_TYPE.SECOND_SUB_1_6 then
		szDefaultText = string.format("[FF69B4]「家族评选复赛主题冠军家族领袖」[-]%s\n来自：[FFFE0D]%s[-]", him.tbKin.szPlayerName, him.tbKin.szServerName);
	elseif nType == tbAct.WINNER_TYPE.SECOND_SUB_1_7 then
		szDefaultText = string.format("[FF69B4]「家族评选复赛主题冠军家族领袖」[-]%s\n来自：[FFFE0D]%s[-]", him.tbKin.szPlayerName, him.tbKin.szServerName);
	elseif nType == tbAct.WINNER_TYPE.SECOND_SUB_1_8 then
		szDefaultText = string.format("[FF69B4]「家族评选复赛主题冠军家族领袖」[-]%s\n来自：[FFFE0D]%s[-]", him.tbKin.szPlayerName, him.tbKin.szServerName);
	elseif nType == tbAct.WINNER_TYPE.SECOND_SUB_1_9 then
		szDefaultText = string.format("[FF69B4]「家族评选复赛主题冠军家族领袖」[-]%s\n来自：[FFFE0D]%s[-]", him.tbKin.szPlayerName, him.tbKin.szServerName);
	elseif nType == tbAct.WINNER_TYPE.SECOND_SUB_1_10 then
		szDefaultText = string.format("[FF69B4]「家族评选复赛主题冠军家族领袖」[-]%s\n来自：[FFFE0D]%s[-]", him.tbKin.szPlayerName, him.tbKin.szServerName);
	elseif nType == tbAct.WINNER_TYPE.THIRD_1 then
		szDefaultText = string.format("[FF69B4]「家族评选决赛冠军家族领袖」[-]%s\n来自：[FFFE0D]%s[-]", him.tbKin.szPlayerName, him.tbKin.szServerName);
	elseif nType == tbAct.WINNER_TYPE.THIRD_2 then
		szDefaultText = string.format("[FF69B4]「家族评选决赛亚军家族领袖[-]%s\n来自：[FFFE0D]%s[-]", him.tbKin.szPlayerName, him.tbKin.szServerName);
	elseif nType == tbAct.WINNER_TYPE.THIRD_3 then
		szDefaultText = string.format("[FF69B4]「家族评选决赛季军家族领袖」[-]%s\n来自：[FFFE0D]%s[-]", him.tbKin.szPlayerName, him.tbKin.szServerName);
	end

	if self:CheckStatueOwner(me, him) then
		table.insert(OptList, 1, {Text = "更新形象", Callback = self.UpdateStatue, Param = {self, him.nId}})
	end

	local tbDialogInfo = {Text = szDefaultText, OptList = OptList};
	Dialog:Show(tbDialogInfo, me, him);
end

function tbNpc:CheckStatueOwner(pPlayer, pNpc)
	if not pPlayer or not pNpc then
		return false
	end

	if not pNpc.tbKin or not pNpc.tbStatueInfo then
		return false
	end

	local nServerId = GetServerIdentity()
	if pPlayer.dwID == pNpc.tbKin.nPlayerId and pNpc.tbKin.nServerId == nServerId then
	 	return true
	end
	return false
end

function tbNpc:UpdateStatue(nNpcId)
	local pNpc = KNpc.GetById(nNpcId)
	if not pNpc or not pNpc.tbKin or not pNpc.tbStatueInfo then
		return
	end

	if not self:CheckStatueOwner(me, pNpc) then
		return
	end

	tbAct:UpdateStatueInfo(me, pNpc.tbKin.nType)
end
