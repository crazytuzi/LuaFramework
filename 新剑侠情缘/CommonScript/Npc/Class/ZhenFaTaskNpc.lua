
local tbNpc = Npc:GetClass("ZhenFaTaskNpc");

function tbNpc:OnDialog()
	if TimeFrame:GetTimeFrameState(ZhenFaTask.szOpenTimeFrame) ~= 1 then
		Dialog:Show({Text = "一人之力，终究难以回天！早些团结周围的力量，组成联盟，方能长盛不衰！", OptList = {}}, me, him);
		return;
	end

	local bRet, szMsg = ZhenFaTask:CheckCanAcceptTaskCommon(me);
	if not bRet then
		me.CenterMsg(szMsg);
		return;
	end

	local OptList = {
		{Text = "接受", Callback = self.Accept, Param = {self}},
		{Text = "离开"},
	};
	local szDefaultText = "少侠，是否已准备好开启今日的阵法试炼？";
	local tbDialogInfo = {Text = szDefaultText, OptList = OptList};
	Dialog:Show(tbDialogInfo, me, him);
end

function tbNpc:Accept()
	local bRet, szMsg = ZhenFaTask:CheckCanAcceptTaskByNpc(me);
	if not bRet then
		me.CenterMsg(szMsg);
		return;
	end

	c2s:OnTeamRequest("AskTeammate2Follow");

	me.MsgBox("队员不在周围将无法顺利进行试炼，已为大侠召回所有队员", {{"好的", function ()
		ZhenFaTask:AcceptNewTask(me);
	end}});
end
