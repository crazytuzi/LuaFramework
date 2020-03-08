
TeamMgr.tbTeamDataCache = TeamMgr.tbTeamDataCache or {
	tbTeamMember = {};
	tbApplyer    = {};
	nCaptainID   = 0;
	nTeamID      = 0;
	nTargetActivityId = nil;
	tbMatchingIds = {};
	tbActivityList = {};
	tbActivityTeams = {};
	tbActivityTeamUpdateTime = {}; -- 记录队伍更新时间
	tbInviterList = {}; -- 邀请者列表
	tbAsyncMember = {};
	nAsyncMapTID = 0;
};

TeamMgr.tbForibitNearbyMap = {
	[DrinkHouse.tbDef.NORMAL_MAP] = 1;
}

local _TeamDataCache = TeamMgr.tbTeamDataCache;

function TeamMgr:IsCaptain(nPlayerID)
	if not nPlayerID then
		nPlayerID = me.dwID;
	end
	return nPlayerID == _TeamDataCache.nCaptainID;
end

function TeamMgr:GetTeamMember(bAsync)
	if not bAsync then
		return _TeamDataCache.tbTeamMember;
	end

	local tbAsync = self:GetAsyncOffLineMember();
	local tbTeamMember = {};
	Lib:MergeTable(tbTeamMember, _TeamDataCache.tbTeamMember);
	Lib:MergeTable(tbTeamMember, tbAsync);
	return tbTeamMember;
end

function TeamMgr:GetAsyncOffLineMember()
	if _TeamDataCache.nAsyncMapTID ~= me.nMapTemplateId then
		return {};
	end

	local tbTeamMember = {};
	for _, tbInfo in pairs(_TeamDataCache.tbAsyncMember) do
		local bAdd = true;
		for _, tbInfo1 in pairs(_TeamDataCache.tbTeamMember) do
			-- 因跨服情况下playerId与本服不一致，故改用名字判断
			if tbInfo1.szName == tbInfo.szName then
				bAdd = false;
				break;
			end
		end

		if bAdd and tbInfo.szName ~= me.szName then
			table.insert(tbTeamMember, tbInfo);
		end
	end

	return tbTeamMember;
end

function TeamMgr:SyncAsyncMember(tbAsyncMember)
	_TeamDataCache.tbAsyncMember = tbAsyncMember or {};
	for _, tbInfo in pairs(_TeamDataCache.tbAsyncMember) do
		tbInfo.bOffLine = true;
		tbInfo.nHpPercent = 0;
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE, "new", false);
end

function TeamMgr:SetAsyncMapTID(nAsyncMapTID)
	_TeamDataCache.nAsyncMapTID = nAsyncMapTID;
end

function TeamMgr:GetTeamMatesPos()
	local tbPos = {};
	for idx, tbMemberData in ipairs(_TeamDataCache.tbTeamMember) do
		if tbMemberData.nMapId == me.nMapId then
			table.insert(tbPos, {tbMemberData.nPosX, tbMemberData.nPosY});
		end
	end
	return tbPos;
end

function TeamMgr:GetApplyList()
	return _TeamDataCache.tbApplyer;
end

function TeamMgr:GetActivityList()
	return _TeamDataCache.tbActivityList;
end

function TeamMgr:GetCurActivityId()
	return _TeamDataCache.nTargetActivityId;
end

function TeamMgr:GetCurActivityInfo()
	return TeamMgr:GetActivityInfo(TeamMgr:GetCurActivityId());
end

function TeamMgr:GetActivityInfo(nActivityId)
	local tbActivitys = TeamMgr:GetActivityList();
	for _, tbActivity in pairs(tbActivitys) do
		if nActivityId == tbActivity.nActivityId then
			local szName = tbActivity.szName;
			if TeamMgr.TEAM_ACTIVITY_NAME[tbActivity.szType]
				and tbActivity.szType ~= tbActivity.subtype
				then
				szName = TeamMgr.TEAM_ACTIVITY_NAME[tbActivity.szType] .. "·" .. szName;
			end
			return szName, tbActivity.nMinOpenMember, tbActivity.szName, tbActivity.szType, tbActivity.bCanHelp;
		end
	end
end

function TeamMgr:HasTeam()
	return _TeamDataCache.nTeamID ~= 0;
end

function TeamMgr:GetTeamId()
	return _TeamDataCache.nTeamID;
end

function TeamMgr:GetMatchingActivityIds()
	if self:HasTeam() then
		return {};
	end

	return _TeamDataCache.tbMatchingIds or {};
end

function TeamMgr:GetMemberData(nNpcID)
	for idx, tbMemberData in ipairs(_TeamDataCache.tbTeamMember) do
		if tbMemberData.nNpcID == nNpcID then
			return tbMemberData, idx;
		end
	end
end

function TeamMgr:GetMemberDataByPlayerId(nPlayerId)
	for idx, tbMemberData in ipairs(_TeamDataCache.tbTeamMember) do
		if tbMemberData.nPlayerID == nPlayerId then
			return tbMemberData, idx;
		end
	end
end


function TeamMgr:OnLeaveGame()
	TeamMgr:OnSynQuite();
end

local nTeammateAttackTimeOut = 5; -- 攻击有效时间为5s
function TeamMgr:CacheMemberTarget(nNpcId, nParam1, nParam2)
	local tbMember = TeamMgr:GetMemberData(nNpcId);
	if not tbMember then
		return;
	end

	if nParam1 == -1 then
		tbMember.nTargetNpcId = nParam2;
		tbMember.nAttackTimeOut = GetTime() + nTeammateAttackTimeOut;
	end
end

------------------------------操作-------------------------------------------

function TeamMgr:OnInvited(nTeamID, nInviterID, szInvitorName, nLevel, nFaction, nPortrait, nHonorLevel, szTarget)
	if not TeamMgr:CanTeam(me.nMapTemplateId) then
		return false;
	end

	for idx, tbTeamInfo in ipairs(_TeamDataCache.tbInviterList) do
		if tbTeamInfo.nTeamId == nTeamID then
			table.remove(_TeamDataCache.tbInviterList, idx);
			break;
		end
	end

	table.insert(_TeamDataCache.tbInviterList, {
			nTeamId = nTeamID,
			nPlayerId = nInviterID,
			szName = szInvitorName,
			nLevel = nLevel,
			nFaction = nFaction,
			nPortrait = nPortrait,
			nHonorLevel = nHonorLevel,
			szTarget = szTarget,
			nTime = GetTime(),
		});

	Ui:SetRedPointNotify("TeamNewInvitor");
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE, "NewInvite");
end

function TeamMgr:GetInviteList()
	return _TeamDataCache.tbInviterList;
end

function TeamMgr:InviteRespond(nTeamID, bAgree)
	for i, tbTeamInfo in ipairs(_TeamDataCache.tbInviterList) do
		if nTeamID == tbTeamInfo.nTeamId then
			if bAgree then
				RemoteServer.OnTeamRequest("AcceptInvitation", tbTeamInfo.nTeamId, tbTeamInfo.nPlayerId);
			end
			table.remove(_TeamDataCache.tbInviterList, i);
			break;
		end
	end

	self:UpdateRedPoints()
end

function TeamMgr:UpdateRedPoints()
	local bNewInviter = #_TeamDataCache.tbInviterList>0
	local bNewApplyer = #_TeamDataCache.tbApplyer>0
	if bNewInviter then
		Ui:SetRedPointNotify("TeamNewInvitor")
	else
		Ui:ClearRedPointNotify("TeamNewInvitor")
	end

	if bNewApplyer then
		Ui:SetRedPointNotify("TeamNewApplyer")
	else
		Ui:ClearRedPointNotify("TeamNewApplyer")
	end

	if bNewInviter or bNewApplyer then
		Ui:SetRedPointNotify("TeamBtnNew")
	else
		Ui:ClearRedPointNotify("TeamBtnNew")
	end
end

function TeamMgr:ClearInviteList()
	_TeamDataCache.tbInviterList = {};
end

function TeamMgr:ClearApplyList()
	if not me.CanTeamOpt() then
		me.CenterMsg("当前地图无法进行此操作");
		return
	end
	
	_TeamDataCache.tbApplyer = {};
	RemoteServer.OnTeamRequest("ClearApplyerList");
	Ui:ClearRedPointNotify("TeamNewApplyer");
end

function TeamMgr:AgreeAppler(nApplerID, bAgree)
	if not TeamMgr:IsCaptain() then
		me.CenterMsg("没有权限");
		return;
	end

	if not me.CanTeamOpt() then
		me.CenterMsg("当前地图无法进行此操作");
		return
	end

	TeamMgr:RemoveApplyer(nApplerID);
	RemoteServer.OnTeamRequest("Agree", nApplerID, bAgree);
	self:UpdateRedPoints()
end

function TeamMgr:_AutoAcceptInvide(nTeamId)
	local tbInviterList = self:GetInviteList()
	for _, tbInviter in ipairs(tbInviterList) do
		if tbInviter.nTeamId==nTeamId then
			self:InviteRespond(nTeamId, true)
			return true
		end
	end
	return false
end

function TeamMgr:Apply(nTeamId, nTargetPlayerID, bNoFeedback)
	if nTargetPlayerID == me.dwID then
		me.CenterMsg("不可以对自己申请");
		return;
	end

	if me.nLevel < TeamMgr.OPEN_LEVEL then
		me.CenterMsg("4级以上才允许组队");
		return;
	end

	if TeamMgr:HasTeam() then
		me.CenterMsg("已在队伍中, 不可申请");
		return;
	end

	if not TeamMgr:CanTeam(me.nMapTemplateId) then
		me.CenterMsg("所在地图不可组队");
		return false;
	end

	if not self:_AutoAcceptInvide(nTeamId) then
		RemoteServer.OnTeamRequest("Apply", nTargetPlayerID, bNoFeedback);
	end
end

function TeamMgr:_AutoAcceptApply(nTargetPlayerID)
	local tbApplyerList = self:GetApplyList()
	for _, tbApplyer in ipairs(tbApplyerList) do
		if tbApplyer.nID==nTargetPlayerID then
			self:AgreeAppler(nTargetPlayerID, true)
			return true
		end
	end
	return false
end

function TeamMgr:Invite(nTargetPlayerID)
	if not TeamMgr:CanClientOperTeam(me.nMapTemplateId) then
		me.CenterMsg("当前地图不允许组队");
		return;
	end
	if nTargetPlayerID == me.dwID then
		me.CenterMsg("不可以邀请自己");
		return;
	end

	if me.nLevel < TeamMgr.OPEN_LEVEL then
		me.CenterMsg("4级以上才允许组队");
		return;
	end

	if not TeamMgr:HasTeam() then
		me.MsgBox("你还没有队伍哦，是否创建队伍并发送邀请?",
			{{"是", function ()
				if TeamMgr:CreateOnePersonTeam() then
					RemoteServer.OnTeamRequest("Invite", nTargetPlayerID);
				else
					return;
				end

				Timer:Register(1, function ()
					local OnOk = function ()
						Ui:OpenWindow("TeamPanel", "TeamActivity");
					end
					me.MsgBox("成功创建队伍，加入目标更容易找到志同道合的侠士哦，是否前往队伍活动[FFFE0D] 设置活动目标 [-]？", { {"前往", OnOk}, {"取消"}});
				end)
			end}, {"否"}})
		return;
	end

	if not TeamMgr:CanTeam(me.nMapTemplateId) then
		me.CenterMsg("所在地图不可组队");
		return false;
	end

	if not self:_AutoAcceptApply(nTargetPlayerID) then
		RemoteServer.OnTeamRequest("Invite", nTargetPlayerID);
	end
end

function TeamMgr:Quite()
	if not TeamMgr:HasTeam() then
		me.CenterMsg("当前无队伍, 不可退出");
		return false;
	end

	Ui:ClearRedPointNotify("TeamNewApplyer");
	RemoteServer.OnTeamRequest("Quite");
end

function TeamMgr:RequestApplyerData()
	RemoteServer.OnTeamRequest("RequestApplyerData");
end

function TeamMgr:SetAutoAgree(bAutoAgree)
	RemoteServer.OnTeamRequest("SetAutoAgree", bAutoAgree);
end

function TeamMgr:IsAutoAgree()
	return me.GetUserValue(TeamMgr.Def.AUTO_AGREE_GROUP, TeamMgr.Def.AUTO_AGREE_KEY) >= 0;
end

function TeamMgr:KickOutMember(nTargertPlayerID)
	if not TeamMgr:IsCaptain() then
		me.CenterMsg("没有权限");
		return;
	end

	RemoteServer.OnTeamRequest("KickOutMember", nTargertPlayerID);
end

function TeamMgr:ChangeCaptain(nPlayerId)
	RemoteServer.OnTeamRequest("ChangeCaptain", nPlayerId);
end

function TeamMgr:RemoveApplyer(nApplerID)
	for nIdx, tbData in ipairs(_TeamDataCache.tbApplyer) do
		if tbData.nID == nApplerID then
			table.remove(_TeamDataCache.tbApplyer, nIdx);
			break;
		end
	end

	if not next(_TeamDataCache.tbApplyer) then
		Ui:ClearRedPointNotify("TeamNewApplyer");
	end
end

function TeamMgr:GetMyTeamMemberData()
	if not TeamMgr:HasTeam() then
		return;
	end

	local pNpc = me.GetNpc();
	if not pNpc then
		return;
	end

	return {
			nPlayerID = me.dwID;
			nNpcID = pNpc.nId;
			szName = me.szName;
			nFaction = me.nFaction;
			nPortrait = me.nPortrait;
			nHonorLevel = me.nHonorLevel;
			nLevel = me.nLevel;
			nMapId = me.nMapId;
			nMapTemplateId = me.nMapTemplateId;
			nPosX = 1;
			nPosY = 1;
			nHpPercent = (pNpc.nCurLife / pNpc.nMaxLife * 100);
			nSex = me.nSex;
		};
end

function TeamMgr:GetCaptainData()
	if me.dwID == _TeamDataCache.nCaptainID then
		return TeamMgr:GetMyTeamMemberData();
	end

	for _, tbMemberData in ipairs(_TeamDataCache.tbTeamMember) do
		if tbMemberData.nPlayerID == _TeamDataCache.nCaptainID then
			return tbMemberData;
		end
	end
end

--------------------------同步数据-----------------------------------------

function TeamMgr:OnSynAddApplyerTable(tbApplyerData)
	table.insert(_TeamDataCache.tbApplyer, tbApplyerData);
	Ui:SetRedPointNotify("TeamNewApplyer");
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE, "NewApplyer");
end

function TeamMgr:OnSynNewTeam(nTeamID, nCaptainID, tbTeamMember, bHideNotify)
	_TeamDataCache.nTeamID = nTeamID;
	_TeamDataCache.nCaptainID = nCaptainID;
	_TeamDataCache.tbTeamMember = tbTeamMember;

	local bShowTeamSetting = next(_TeamDataCache.tbMatchingIds or {}) and me.dwID ~= nCaptainID;
	_TeamDataCache.tbMatchingIds = {};

	if not bHideNotify and me.dwID ~= nCaptainID then
		local tbCaptainData = TeamMgr:GetCaptainData();
		local szCaptainName = tbCaptainData and tbCaptainData.szName or "";
		me.CenterMsg(string.format("你加入了[ffff00]「%s」[-]的队伍", szCaptainName));
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE, "new", bShowTeamSetting);
end

function TeamMgr:OnSynAddMember(tbMemberData)
	if not TeamMgr:GetMemberData(tbMemberData.nNpcID) then
		table.insert(_TeamDataCache.tbTeamMember, tbMemberData);
	else
		Log("ERROR:already have team member ", tbMemberData.nNpcID);
	end

	local bShowTeamSetting = false;
	if TeamMgr:GetCurActivityId()
		and TeamMgr:IsCaptain()
		and #TeamMgr:GetTeamMember() >= (TeamMgr.MAX_MEMBER_COUNT - 1)
		then
		bShowTeamSetting = true;
	end

	if TeamMgr:IsCaptain() then
		me.CenterMsg(string.format("[ffff00]「%s」[-]加入了你的队伍", tbMemberData.szName));
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE, "MemberChanged", bShowTeamSetting, "AddMember");
end

function TeamMgr:OnSynChangeCaptain(nCaptainID)
	_TeamDataCache.nCaptainID = nCaptainID;
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE, "MemberChanged");
end

function TeamMgr:OnSynRemoveMember(nMemberID)
	for nIdx, tbMemberData in ipairs(_TeamDataCache.tbTeamMember) do
		if tbMemberData.nPlayerID == nMemberID then
			table.remove(_TeamDataCache.tbTeamMember, nIdx);
			break;
		end
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE, "MemberChanged");
end

function TeamMgr:OnSynApplyerList(tbApplyerList)
	_TeamDataCache.tbApplyer = tbApplyerList;
	if tbApplyerList and next(tbApplyerList) then
		Ui:SetRedPointNotify("TeamNewApplyer");
		UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE, "NewApplyer");
	else
		Ui:ClearRedPointNotify("TeamNewApplyer");
	end
end

function TeamMgr:OnSynTeamHelpState(bHelp)
	_TeamDataCache.bIsTeamHelp = bHelp;
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE, "MemberChanged");
end

function TeamMgr:GetMyHelpState()
	return _TeamDataCache.bIsTeamHelp or false;
end

function TeamMgr:IsNoShowQuitTip()
	if QunYingHuiCross:IsNoShowQuitTeamTip() then
		return true
	end
end

function TeamMgr:OnSynQuite()
	if TeamMgr:HasTeam() then
		if not self:IsNoShowQuitTip() then
			me.CenterMsg("你退出了队伍");
		end
		Ui:CloseWindow("TeammateSelectPop");
	end

	_TeamDataCache.tbTeamMember      = {};
	_TeamDataCache.tbApplyer         = {};
	_TeamDataCache.nCaptainID        = 0;
	_TeamDataCache.nTeamID           = 0;
	_TeamDataCache.nTargetActivityId = nil;
	_TeamDataCache.tbInviterList     = {};
	_TeamDataCache.bIsTeamHelp       = nil;
	_TeamDataCache.tbAsyncMember     = {};
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE, "quite");
end

function TeamMgr:OnSyncTeamMemberInfo(...)
	local tbMemberInfo = {...};
	local bUpdate = false;
	for _, tbMember in pairs(tbMemberInfo) do
		local member = TeamMgr:GetMemberData(tbMember[1]);
		if member then
			if member.nHpPercent ~= tbMember[2] then
				member.nHpPercent = tbMember[2];
				bUpdate = true;
			end

			if member.nMapId ~= tbMember[3] then
				member.nMapId = tbMember[3];
				bUpdate = true;
			end

			member.nPosX = tbMember[4];
			member.nPosY = tbMember[5];
		else
			Log("team c sync wrong, no member", tbMember[1]);
		end
	end

	if bUpdate then
		UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE, "TeamUpdate");
	end
end

function TeamMgr:OnSynTeammateChangeMap(nPlayerId, nMapTemplateId, nMapId, nX, nY)
	for _, tbMemberData in ipairs(_TeamDataCache.tbTeamMember) do
		if tbMemberData.nPlayerID == nPlayerId then
			tbMemberData.nMapId = nMapId;
			tbMemberData.nPosX = nX;
			tbMemberData.nPosY = nY;
			tbMemberData.nMapTemplateId = nMapTemplateId;
			UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE, "TeamUpdate");
			break;
		end
	end
end

-----------------------快速组队----------------------------

function TeamMgr:Ask4Activitys()
	local nNow = GetTime();
	if not self.nNextAsk4ActivityTime or self.nNextAsk4ActivityTime < nNow then
		self.nNextAsk4ActivityTime = nNow + 10;
		RemoteServer.OnTeamUpRequest("Ask4Activitys");
	end
end

function TeamMgr:Ask4ActivityTeams(nActivityId)
	if nActivityId then
		RemoteServer.OnTeamUpRequest("Ask4ActivityTeams", nActivityId);
	end
end

function TeamMgr:SetHelpState(bHelp)
	RemoteServer.OnTeamUpRequest("SetQuickTeamHelpState", bHelp);
end

function TeamMgr:OnSynTargetActivityId(nActivityId)
	if _TeamDataCache.nTargetActivityId == nActivityId then
		return;
	end

	_TeamDataCache.nTargetActivityId = nActivityId;
	UiNotify.OnNotify(UiNotify.emNOTIFY_QUICK_TEAM_UPDATE, "TargetId");
end

function TeamMgr:OnLevelChanged()
	_TeamDataCache.nActivityListVersion = nil;
end

function TeamMgr:OnSynActivityList(tbActivityList, nVersion)
	_TeamDataCache.tbActivityList = tbActivityList;
	_TeamDataCache.nActivityListVersion = nVersion;
	UiNotify.OnNotify(UiNotify.emNOTIFY_QUICK_TEAM_UPDATE, "ActivityList", true);
end

local nDelayUpdateTeamTime = 25;

function TeamMgr:OnSynActivityTeams(nActivityId, tbTeams)
	table.sort(tbTeams, function (a, b)
		if a.nTeamId == TeamMgr:GetTeamId() then
			return true;
		elseif b.nTeamId == TeamMgr:GetTeamId() then
			return false;
		end
		return a.nCount > b.nCount;
	end);

	local tbPreTeams = _TeamDataCache.tbActivityTeams[nActivityId] or {};
	_TeamDataCache.tbActivityTeams[nActivityId] = tbTeams;
	_TeamDataCache.tbActivityTeamUpdateTime[nActivityId] = GetTime() + nDelayUpdateTeamTime;

	if not next(tbPreTeams) then
		UiNotify.OnNotify(UiNotify.emNOTIFY_QUICK_TEAM_UPDATE, "ActivityTeams", nActivityId);
	end
end

function TeamMgr:GetActivityTeamUpdateTime(nActivityId)
	return _TeamDataCache.tbActivityTeamUpdateTime[nActivityId] or 0;
end

function TeamMgr:GetActivityTeams(nActivityId)
	local tbTeams = _TeamDataCache.tbActivityTeams[nActivityId] or {};
	if TeamMgr:GetActivityTeamUpdateTime(nActivityId) < GetTime() and next(tbTeams) then
		TeamMgr:Ask4ActivityTeams(nActivityId);
	end

	return tbTeams;
end

function TeamMgr:OnSynQuickTeamsInfo(nActivityId, nTeamId, nMemberCount)
	local tbTeams = TeamMgr:GetActivityTeams(nActivityId);
	for nIdx, tbTeam in pairs(tbTeams) do
		if tbTeam.nTeamId == nTeamId then
			if nMemberCount >= TeamMgr.MAX_MEMBER_COUNT or nMemberCount == 0 then
				table.remove(tbTeams, nIdx);
			else
				tbTeam.nCount = nMemberCount;
			end

			UiNotify.OnNotify(UiNotify.emNOTIFY_QUICK_TEAM_UPDATE, "ActivityTeams", nActivityId);
			break;
		end
	end
end

function TeamMgr:OnSynQuickMatch(tbMatchingIds)
	_TeamDataCache.tbMatchingIds = tbMatchingIds;
	UiNotify.OnNotify(UiNotify.emNOTIFY_QUICK_TEAM_UPDATE, "ActivityList", true);
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE);

	if next(tbMatchingIds) then
		me.CenterMsg("已开始自动寻队，请耐心等待");
	end
end

function TeamMgr:NoticeEnterActivity(nActivityId, nCountDownTime, szName)
	local fnAgree = function ()
		RemoteServer.OnTeamUpRequest("AgreeEnterActivity", nActivityId, true);
	end

	local fnDisagree = function ()
		RemoteServer.OnTeamUpRequest("AgreeEnterActivity", nActivityId, false);
	end

	local fnClose = function ()
		Ui:CloseWindow("MessageBox");
	end

	local szMsg = string.format("队长选择进入%s, 是否同意。\n(%%d秒后自动同意)", szName);
	me.MsgBox(szMsg, {{"同意", fnAgree}, {"拒绝", fnDisagree}}, nil, nCountDownTime, fnClose);
end

function TeamMgr:CaptainWaitingMsgBox(nCountDownTime)
	local fnClose = function ()
		Ui:CloseWindow("MessageBox");
	end
	me.MsgBox("请等待队员同意进入：%d", {{"确定", fnClose}}, nil, nCountDownTime, fnClose);
end

function TeamMgr:EnterActivityResult(bSucceed, szRefucerName, szActivityName)
	Ui:CloseWindow("MessageBox");

	if not bSucceed then
		me.CenterMsg(string.format("「%s」拒绝进入%s", szRefucerName, szActivityName or ""));
	end
end

function TeamMgr:EnterActivity()
	if not TeamMgr:IsCaptain() then
		me.CenterMsg("你不是队长，无法操作");
		return false;
	end

	if not TeamMgr:HasTeam() then
		me.CenterMsg("请先加入队伍");
		return false;
	end

	local nActivityId = TeamMgr:GetCurActivityId();
	if not nActivityId then
		me.CenterMsg("请先选择队伍目标");
		return false;
	end

	local fnEnter = function ()
		RemoteServer.OnTeamUpRequest("EnterActivity", nActivityId);
	end

	local _, _, _, szActivityType = TeamMgr:GetCurActivityInfo();
	if TeamMgr.QUICK_TEAM_FULL_CHECK[szActivityType] and #TeamMgr:GetTeamMember() < (TeamMgr.MAX_MEMBER_COUNT - 1) then
		Dialog:Show(
		{
			Text = "队伍人数未满员，是否直接开启？",
			OptList = {
				{Text = "直接开启", Callback = fnEnter},
				{Text = "等下再开"},
			},
		}, me);
	else
		fnEnter();
	end
end

function TeamMgr:CreateOnePersonTeam(nActivityId)
	if TeamMgr:HasTeam() then
		me.CenterMsg("已有队伍不可创建");
		return false;
	end

	if not TeamMgr:CanTeam(me.nMapTemplateId) then
		me.CenterMsg("所在地图不可组队");
		return false;
	end

	RemoteServer.OnTeamUpRequest("CreateOnePersonTeam", nActivityId);
	return true;
end

function TeamMgr:QuickMatch(tbActivitys)
	if TeamMgr:HasTeam() then
		me.CenterMsg("你当前已经有队伍了");
		return false;
	end

	RemoteServer.OnTeamUpRequest("ActivityQuickMatch", tbActivitys);
end

function TeamMgr:ApplyActivityTeam(nActivityId, nTeamId)
	if not TeamMgr:CanTeam(me.nMapTemplateId) then
		me.CenterMsg("所在地图不可组队");
		return false;
	end

	if nTeamId == TeamMgr:GetTeamId() then
		me.CenterMsg("已在队伍中");
		return false;
	end

	if TeamMgr:HasTeam() then
		me.MsgBox("少侠当前有队伍了，是否要退出队伍并申请加入目标队伍？", {{"确定", function ()
			TeamMgr:Quite();
			RemoteServer.OnTeamUpRequest("ApplyActivityTeam", nActivityId, nTeamId);
		end}, {"取消"}})
		return false;
	end
	RemoteServer.OnTeamUpRequest("ApplyActivityTeam", nActivityId, nTeamId);
end

function TeamMgr:SetTeamActivity(nActivityId)
	if not TeamMgr:HasTeam() then
		me.CenterMsg("当前没有队伍");
		return false;
	end

	if not TeamMgr:IsCaptain() then
		me.CenterMsg("你不是队长，无法操作")
		return false;
	end

	RemoteServer.OnTeamUpRequest("QuickTeamUpSetting", nActivityId);
end

function TeamMgr:_GetNearbyTeamIds()
	local tbRet = {}
	local tbNpcList = KNpc.GetNpcListInCurrentMap()
	for _, pNpc in pairs(tbNpcList) do
		if pNpc.dwTeamID>0 then
			tbRet[pNpc.dwTeamID] = true
		end
	end
	return tbRet
end

function TeamMgr:SyncNearbyTeams()
	local tbTeamIds = self:_GetNearbyTeamIds()
	if not next(tbTeamIds) then
		return
	end

	RemoteServer.OnSyncNearbyTeamsReq(tbTeamIds)
end

function TeamMgr:OnSyncNearbyTeams(tbTeams)
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_NEARBY_TEAMS, tbTeams)
end

function TeamMgr:OnMemberInfoChange(tbMemberData)
	local nPlayerId = tbMemberData.nPlayerID
	for nIdx, tbMember in ipairs(_TeamDataCache.tbTeamMember) do
		if tbMember.nPlayerID == nPlayerId then
			_TeamDataCache.tbTeamMember[nIdx] = tbMemberData
			UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE, "MemberChanged")
			break
		end
	end
end

function TeamMgr:OnMyInfoChange()
	if not self:HasTeam() then
		return
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE, "MemberChanged")
end

function TeamMgr:Apply2BeCaptain(nCaptainId)
	if not self:HasTeam() then
		return
	end

	RemoteServer.OnTeamRequest("Apply2BeCaptain", nCaptainId);
end


function TeamMgr:AskTeammate2Follow()
	if not self:HasTeam() then
		return
	end
	if not self:IsCaptain() then
		me.CenterMsg("只有队长可以进行召回");
		return;
	end
	RemoteServer.OnTeamRequest("AskTeammate2Follow");
end

function TeamMgr:AskTeammateNot2Follow()
	if not self:HasTeam() then
		return
	end
	if not self:IsCaptain() then
		me.CenterMsg("只有队长可以取消召回");
		return;
	end

	local fnAgree = function ()
		RemoteServer.OnTeamRequest("AskTeammateNot2Follow");
	end

	local fnClose = function ()
		Ui:CloseWindow("MessageBox");
	end

	local szMsg = "确定要取消队员跟战你的状态吗？";
	me.MsgBox(szMsg, {{"确定", fnAgree}, {"取消", fnClose}});
	
end

function TeamMgr:OnFollowCaptainInvited(nCaptainNpcId, szName)
	if AutoFight:IsFollowTeammate() and AutoFight:GetFollowingNpcId() == nCaptainNpcId then
		me.CenterMsg(string.format("队长 [FFFE0D]「%s」[-] 发起了召回", szName));
		return;
	end

	local fnAgree = function ()
		AutoFight:StartFollowTeammate(nCaptainNpcId);
	end

	local fnClose = function ()
		Ui:CloseWindow("MessageBox");
	end

	local szMsg = string.format("队长 [FFFE0D]「%s」[-] 发起了召回，是否跟战前往？\n(%%d秒后自动同意)", szName);
	me.MsgBox(szMsg, {{"同意", fnAgree}, {"拒绝", fnClose}}, nil, 10, fnAgree);
end

function TeamMgr:OnCancelFollowAttack(nCaptainNpcId, szName)
	if AutoFight:IsFollowTeammate() and AutoFight:GetFollowingNpcId() == nCaptainNpcId then
		AutoFight:StopFollowTeammate();
		AutoFight:ChangeState(AutoFight.OperationType.Auto);
		me.CenterMsg(string.format("队长 [FFFE0D]「%s」[-] 取消了你对他的跟战", szName), 1, ChatMgr.SystemMsgType.Team);
	end
end

function TeamMgr:SendFollowState(nFollowPlayerId)
	if not TeamMgr:HasTeam() or not nFollowPlayerId then
		return;
	end

	RemoteServer.OnTeamRequest("UpdateFollowState", nFollowPlayerId);
end

function TeamMgr:OnSynFollowState(nFollowedPlayerId, nValidTime)
	local tbTeammateData = TeamMgr:GetMemberDataByPlayerId(nFollowedPlayerId);
	if not tbTeammateData then
		return;
	end

	-- Log("OnSynFollowState", nFollowedPlayerId, nValidTime -GetTime())
	tbTeammateData.nFollowingValidTime = nValidTime;
	UiNotify.OnNotify(UiNotify.emNOTIFY_TEAM_UPDATE, "FollowStateChanged");
end