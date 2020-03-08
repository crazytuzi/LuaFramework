Fuben.LingJueFengWeek = Fuben.LingJueFengWeek or {};
local LingJueFengWeek = Fuben.LingJueFengWeek;

function LingJueFengWeek:OnLogout()
	self.tbTeamMsg = nil;
	self.tbRankRoleMsg = nil;
	LingJueFengWeek.tbTeamFaction = {};
	LingJueFengWeek.tbFactionChoose = {};
	self.nAskCD = 0;
end

function LingJueFengWeek:GetLevelInfo()
	self:AskTeamMsg();
	local nLevel = 0;
	if self.tbTeamMsg then
		nLevel = self.tbTeamMsg.nLevel - 1;
	end
	return string.format("通关数: %d/%d",nLevel, self.TOTAL_LEVEL);
end

function LingJueFengWeek:IsOpen()
	if me.nLevel < Fuben.LingJueFengWeek.NLIMIT_LEVEL then
		return false;
	end
	self:AskTeamMsg();
	return self.bIsOpen or false;
end

-------------------调用跨服服务器接口-------------------

function LingJueFengWeek:TryCrossChoice(bIsAgree)
	RemoteServer.LingJueFengWeekClientCall("TimerChoose" , bIsAgree);
end

function LingJueFengWeek:TryRevive()
	RemoteServer.LingJueFengWeekClientCall("TryRevive");
end

function LingJueFengWeek:TryLeaveRoom()
	RemoteServer.LingJueFengWeekClientCall("TryLeaveRoom")
end

------------------调用服务端接口-------------------
function LingJueFengWeek:FlushFactionPanel()
	RemoteServer.LingJueFengWeekClientCall("FlushFactionPanel");
end

function LingJueFengWeek:TryEnterFuben()
	if not self.tbTeamMsg then
		me.CenterMsg("凌绝峰险象环生，请大侠先组建好战队,再前来挑战！");
		return ;
	end

	if not TeamMgr:HasTeam() then
		me.CenterMsg("凌绝峰险象环生，请大侠与战队成员结成队伍共同挑战！");
		return;
	end
	if TeamMgr:IsCaptain(me.dwID) then
		RemoteServer.LingJueFengWeekClientCall("TryEnterFuben");
	else
		me.CenterMsg("您不是队长，无权操作");
	end
end



function LingJueFengWeek:AskTeamMsg()
	local nTimeNow = GetTime();
	self.nAskCD = self.nAskCD or 0;
	
	-- 十秒冷缺CD 
	if nTimeNow < self.nAskCD + 180 then
		return ;
	end

	if self.tbTeamMsg then
		--检查数据版本。
		local nWeek = Lib:GetLocalWeek(nTimeNow - (3600*3+55*60));
		if nWeek == self.tbTeamMsg.nWeek then
			return;
		end
	end
	self.nAskCD = nTimeNow;
	RemoteServer.LingJueFengWeekClientCall("AskTeamMsg");
end



function LingJueFengWeek:AskRankBoardMsg(nTeamId)
	self.tbRankRoleMsg = nil;
	Ui:OpenWindow("TeamDetailsPanel")
	RemoteServer.LingJueFengWeekClientCall("AskTeamMsg",nTeamId)
end

function LingJueFengWeek:TrySignUpTeam(szTeamName)
	local tbTeamMsg = TeamMgr:GetTeamMember();
	local szMsg = string.format("是否邀请队友组建战队[FFFE0D]%s[-]?\n",szTeamName);

	for nIdx, tbMem in pairs(tbTeamMsg) do
		if tbMem.nPlayerID ~= me.dwID then
			local szTmp = string.format("[FFFE0D]%s[-]    %d级\n",tbMem.szName,tbMem.nLevel);
			szMsg = szMsg..szTmp;
		end
	end
	szMsg = szMsg.."[FFFE0D]（本周内，无法退出或更改战队）[-]";

	me.MsgBox(szMsg,{
		{"确认", function()
		RemoteServer.LingJueFengWeekClientCall("TrySignUpTeam",szTeamName);
		Ui:CloseWindow("MessageBox");
		LingJueFengWeek:TryLeaveRoom();
		end}
	,{"取消", function() end}})

end

function LingJueFengWeek:TeamCompleteFaction()
	RemoteServer.LingJueFengWeekClientCall("TeamCompleteFaction");
end

function LingJueFengWeek:TrySelectFaction(nFaction)
	RemoteServer.LingJueFengWeekClientCall("TrySelectFaction" , nFaction);
end

------------------服务端回调接口-------------------
LingJueFengWeek.tbTeamFaction = {};
LingJueFengWeek.tbFactionChoose = {};
function LingJueFengWeek:FlushPanel()
	UiNotify.OnNotify(UiNotify.emNoTIFY_LJF_WEEK_UPDATE);
	if self.tbTeamMsg or self.bIsOpen then
		UiNotify.OnNotify(UiNotify.emNOTIFY_ONACTIVITY_STATE_CHANGE)
	end
end

function LingJueFengWeek:ChooseFaction(szName, nFaction)
	local nOldFaction = self.tbTeamFaction[szName];
	if nOldFaction then
		self.tbFactionChoose[nOldFaction] = nil;
	end
	self.tbFactionChoose[nFaction] = szName;
	self.tbTeamFaction[szName] = nFaction;
	self:FlushPanel();
end

function LingJueFengWeek:UpdateTeamMsg(tbTeamMsg, bIsRankMsg , bIsOpen)
	self.bIsOpen = bIsOpen or false;
	if not tbTeamMsg then 
		self.tbTeamMsg = tbTeamMsg;
		self:FlushPanel();
		return ;
	end
	if bIsRankMsg then
		self.tbRankRoleMsg = tbTeamMsg;
		self:FlushPanel();
		return;
	end
	self.tbTeamMsg = tbTeamMsg;
	self.tbTeamMsg.nWeek = Lib:GetLocalWeek(GetTime() - (3600*3+55*60));
	self:FlushPanel();
end