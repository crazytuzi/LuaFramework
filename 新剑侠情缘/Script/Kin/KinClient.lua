
--[[
	关于家族数据同步的策略:
	分为基本数据, 成员数据, 申请列表. 这些分别按版本号维护更新
]]

local TitleSettingCareer = {
	[Kin.Def.Career_Elite]  = "【全体精英成员】",
	[Kin.Def.Career_Normal] = "【全体正式成员】",
	[Kin.Def.Career_New]    = "【全体见习成员】",
};

local tbUneditableCareers = {
	[Kin.Def.Career_Mascot] = true,
}

function Kin:GetCareerMaxCount(nCareer)
	local nLevel = Kin:GetLevel();
	return Kin:GetMaxMember(nLevel or 1, nCareer);
end

Kin._CacheData = Kin._CacheData or {};

function Kin:CacheData(szKey, tbData, nVersion)
	Kin._CacheData[szKey] = {
		tbData = tbData;
		nVersion = nVersion;
	};
end

function Kin:GetData(szKey)
	local tbCache = Kin._CacheData[szKey];
	if tbCache then
		return tbCache.tbData, tbCache.nVersion;
	end
end

function Kin:GetLevel()
	local tbBuildingData = Kin:GetBuildingData(Kin.Def.Building_Main);
	if tbBuildingData then
		return tbBuildingData.nLevel;
	end

	local tbBaseInfo = Kin:GetData("BaseInfo") or {};
	return tbBaseInfo.nLevel or 1;
end

function Kin:GetBuildingOpenLevel(nBuildingId)
	if nBuildingId == Kin.Def.Building_Main then
		return Kin:GetMainBuildingOpenLevel();
	else
		local nMaxLevel = Kin:GetBuildingMaxLevel(nBuildingId);
		if nMaxLevel == 1 then
			return 1;
		end

		local nMainLevel = Kin:GetLevel();
		local nNextLevel = Kin:GetBuildingLevel(nBuildingId) + 1;
		local bCanLevelup, nMainBuildeRequre = Kin:CanLevelUp(nBuildingId, nNextLevel, nMainLevel);
		return bCanLevelup and nNextLevel or (nNextLevel - 1);
	end
end

function Kin:ClearCache()
	Kin._CacheData = {};
	Kin:ClearAuctionCache();
end

function Kin:HasKin()
	return me.dwKinId ~= 0;
end

function Kin:OnKinJoined(nKinId, szKinTitle)
	if Ui:WindowVisible("KinJoinPanel") then
		Ui:CloseWindow("KinJoinPanel");
		Ui:CloseWindow("KinCreatePanel");
		Ui:OpenWindow("KinDetailPanel");
	end
	Client:SetFlag("FirstJoinKin");
	me.dwKinId = nKinId;
	me.szKinTitle = szKinTitle;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, "New");
end

----------------------与服务端交互接口----------------------------------

function Kin:Create(szKinName, szAddDeclare, tbVoice, nCamp)
	if Kin:HasKin() then
		me.CenterMsg("您已经有家族了");
		return false;
	end
	if me.nLevel < Kin.Def.nLevelLimite then
		me.CenterMsg(string.format("家族创建需要角色达到%d级", Kin.Def.nLevelLimite));
		return false;
	end

	local bValid, szErr = Kin:IsNameValid(szKinName)
	if not bValid then
		me.CenterMsg(szErr)
		return false
	end

	local bRet = Kin:CheckKinCamp(nCamp);
	if not bRet then
		me.CenterMsg("请选择阵营！");
		return false;
	end

	szAddDeclare = ReplaceLimitWords(szAddDeclare) or szAddDeclare;

	if Lib:Utf8Len(szAddDeclare) > Kin.Def.nMaxAddDeclareLength then
		me.CenterMsg("家族宣言超过最大长度" .. Kin.Def.nMaxAddDeclareLength);
		return false;
	end

	RemoteServer.OnKinRequest("Create", szKinName, szAddDeclare, tbVoice, nCamp);
	return true;
end

function Kin:CheckChangeName(szKinName)
	if not self:HasKin() then
		return false, "您没有家族"
	end

	if not self:AmIMaster() then
		return false, "您不是族长"
	end

	local nCost = Kin:GetChangeNamePrice(me)
	if me.GetMoney("Gold")<nCost then
		return false, "您的元宝不足"
	end

	local bValid, szErr = Kin:IsNameValid(szKinName)
	if not bValid then
		return false, szErr
	end

	local tbBaseInfo = self:GetBaseInfo()
	if tbBaseInfo and szKinName==tbBaseInfo.szName then
		return false, "新家族名与当前家族名一致"
	end

	return true
end

function Kin:ChangeName(szKinName)
	local bSuccess, szErr = self:CheckChangeName(szKinName)
	if not bSuccess then
		me.CenterMsg(szErr)
		return false
	end

	RemoteServer.OnKinRequest("ChangeName", szKinName)
	return true
end

function Kin:Invite(nPlayerId)
	assert(nPlayerId);
	if not Kin:HasKin() then
		me.CenterMsg("当前无家族, 不可邀请");
		return;
	end

	RemoteServer.OnKinRequest("Invite", nPlayerId);
end

function Kin:SetMemberState(tbOnlineMembers)
	Kin:CacheData("OnlineMembers", tbOnlineMembers);
end

function Kin:GetMemberState()
	return Kin:GetData("OnlineMembers");
end

function Kin:SetMemberCareer(tbMemberCareer, nVersion)
	Kin:CacheData("MemberCareer", tbMemberCareer, nVersion);
	ChatMgr.ChatDecorate:TryCheckValid()
	UiNotify.OnNotify(UiNotify.emNOTIFY_CHAT_THEME_OVERDUE,true)
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, "MemberCareer");
end

function Kin:GetMemberCareer()
	return Kin:GetData("MemberCareer");
end

--客户端兼容服务端接口用
function Kin:GetPlayerCareer( dwRoleId )
	if dwRoleId and dwRoleId ~= me.dwID then
		return
	end
	if me.dwKinId == 0 then
		return
	end
	local tbData = self:GetMemberCareer()
	if not tbData or not next(tbData) then
		self:UpdateMemberCareer()
		return
	end
	return tbData[me.nLocalServerPlayerId]
end
function Kin:IsMemberManager(nMemberId)
	local tbCareers = self:GetMemberCareer() or {}
	local nCareer = tbCareers[nMemberId] or -1
	return self.Def.tbManagerCareers[nCareer]
end

function Kin:UpdateMemberCareer()
	local _, nVersion = Kin:GetMemberCareer();
	RemoteServer.OnKinRequest("SyncKinCareer", nVersion);
end

function Kin:OnSyncJoinInfo(tbJoinKinsData, nPage, nMaxPage)
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, "JoinKins", tbJoinKinsData, nPage, nMaxPage);
end

function Kin:CheckBeforeApply(nKinId, szMsg)
	if me.dwKinId ~= 0 then
		me.CenterMsg("你已经有家族了");
		return false;
	end

	if not szMsg or szMsg == "" then
		me.CenterMsg("请输入留言")
		return false
	end

	if ReplaceLimitWords(szMsg) then
		me.CenterMsg("留言中有敏感词")
		return false
	end

	if Lib:Utf8Len(szMsg) > self.Def.nApplyMsgMaxLen then
		me.CenterMsg(string.format("留言最多%d字", self.Def.nApplyMsgMaxLen))
		return false
	end

	if me.nLevel < Kin.Def.nLevelLimite then
		me.CenterMsg(string.format("等级达到%d级后开放家族", Kin.Def.nLevelLimite));
		return false;
	end

	local nJoinCD = self:GetJoinCD(me)
	if nJoinCD>0 then
		me.CenterMsg(string.format("%s后才可以加入家族", Lib:TimeDesc2(nJoinCD)))
		return false
	end
	return true
end

function Kin:ApplyKin(nKinId, szMsg, tbVoice)
	if not self:CheckBeforeApply(nKinId, szMsg) then
		return false
	end
	RemoteServer.OnKinRequest("Apply", nKinId, szMsg, tbVoice);
	return true;
end

function Kin:ApplyApplyer(nPlayerId)
	RemoteServer.OnKinRequest("ApplyPlayer", nPlayerId);
end

function Kin:UpdateJoinKinsData(nPage)
	RemoteServer.OnKinRequest("SyncKins2Join", nPage);
end

function Kin:OnInvited(szInviter, szKinName, nKinId)
	Ui:OpenWindow("MessageBox",
		string.format("[FFFE0D]%s[-] 邀请你进入家族 [FFFE0D]%s[-]", szInviter, szKinName),
		{ {function ()
			RemoteServer.OnKinRequest("AgreeInvite", nKinId);
			end},{} },
		{"同意", "取消"});
end

function Kin:OnSyncBaseInfo(tbBaseInfo, nVersion)
	Kin:CacheData("BaseInfo", tbBaseInfo, nVersion);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, "BaseInfo");
	Kin:UpdateGroupInfo();
end

function Kin:GetBaseInfo()
	return Kin:GetData("BaseInfo");
end

function Kin:GetOrgServerId()
	local tbBaseInfo = self:GetBaseInfo() or {};
	return tbBaseInfo.nOrgServerId or Sdk:GetServerId();
end

function Kin:CancelAppointLeader()
	local nCandidateId = self:GetCandidateLeaderId()
	local tbData = Kin:GetMemberData(nCandidateId)
	local function fnCancel()
		RemoteServer.OnKinRequest("CancelAppointLeader")
	end
	me.MsgBox(string.format("你确定要取消 [FFFE0D]%s[-] 的领袖任命吗？", tbData.szName),
		{{"确定", fnCancel}, {"取消"}})
end

function Kin:GetCandidateLeaderInfo()
	local tbBaseInfo = self:GetBaseInfo()
	if not tbBaseInfo then
		self:UpdateBaseInfo()
		return
	end

	local nCandidateId = tbBaseInfo.nCandidateLeaderId
	if nCandidateId>0 then
		local tbInfo = self:GetMemberData(nCandidateId)
		if tbInfo then
			local nDeadline = self:ComputeChangeLeaderDeadline(tbBaseInfo.nChangeLeaderTime)
			local nSeconds = math.max(0, nDeadline-GetTime())
			return tbInfo.szName, Lib:TimeDesc5(nSeconds)
		end
	end
	return nil
end

function Kin:GetLeaderTitle()
	local tbBaseInfo = self:GetBaseInfo()
	if not tbBaseInfo then
		self:UpdateBaseInfo()
		return Kin.Def.Career_Name[Kin.Def.Career_Leader]
	end

	local szTitle = tbBaseInfo.szLeaderTitle
	if szTitle and szTitle~="" then
		return szTitle
	end
	return Kin.Def.Career_Name[Kin.Def.Career_Leader]
end

function Kin:GetLeaderId()
	local tbBaseInfo = self:GetBaseInfo()
	if not tbBaseInfo then
		self:UpdateBaseInfo()
		return 0
	end
	return tbBaseInfo.nLeaderId
end

function Kin:GetCandidateLeaderId()
	local tbBaseInfo = self:GetBaseInfo()
	if not tbBaseInfo then
		self:UpdateBaseInfo()
		return 0
	end
	return tbBaseInfo.nCandidateLeaderId
end

function Kin:GetLeaderData()
	local nLeaderId = self:GetLeaderId()
	if nLeaderId>0 then
		local tbMembers = self:GetMemberList() or {}
		for _,tbData in ipairs(tbMembers) do
			if tbData.nMemberId==nLeaderId then
				return tbData
			end
		end
	end
end

function Kin:GetLeaderName()
	local szRet = "无"
	local tbData = self:GetLeaderData()
	if tbData then
		szRet = tbData.szName
	end
	return szRet
end

function Kin:AmILeader()
	return self:GetLeaderId()==me.dwID
end

function Kin:AmIMaster()
	local myData = self:GetMyMemberData()
	return myData and myData.nCareer==Kin.Def.Career_Master
end

function Kin:UpdateBaseInfo()
	if not Kin:HasKin() then
		return;
	end

	local _, nVersion = Kin:GetBaseInfo();
	RemoteServer.OnKinRequest("SyncKinBaseInfo", nVersion);
end

function Kin:_IsMemberListSliceTransOver(nExpectCount)
	local tbMemberListSliced = self:GetData("MemberListSliced")
	for nIdx=1, nExpectCount do
		if not tbMemberListSliced[nIdx] then
			return false
		end
	end
	return true
end

function Kin:_SetMemberListFromSlice()
	local tbMemberListSliced, nVersion = self:GetData("MemberListSliced")
	self:OnSyncMemberList(tbMemberListSliced, nVersion)
	self:CacheData("MemberListSliced", {}, 0)
end

function Kin:OnSyncMemberListSlice(tbSliceList, nVersion)
	local tbMemberListSliced, nCacheVersion = self:GetData("MemberListSliced")
	tbMemberListSliced = nCacheVersion==nVersion and tbMemberListSliced or {}

	local nExpectCount = tbSliceList.nExpectCount
	tbSliceList.nExpectCount = nil
	for nIdx, tbMemberData in pairs(tbSliceList) do
		tbMemberListSliced[nIdx] = tbMemberData
	end
	self:CacheData("MemberListSliced", tbMemberListSliced, nVersion)

	if self:_IsMemberListSliceTransOver(nExpectCount) then
		self:_SetMemberListFromSlice()
	end
end

function Kin:OnSyncMemberList(tbMemberList, nVersion)
	Kin:CacheData("MemberList", tbMemberList, nVersion);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, "MemberList");
end

function Kin:GetMemberList()
	return Kin:GetData("MemberList");
end

function Kin:UpdateMemberList()
	local _, nVersion = Kin:GetMemberList();
	RemoteServer.OnKinRequest("SyncKinMemberInfo", nVersion);
end

function Kin:OnSyncApplyerList(tbApplyList, nVersion)
	Kin:CacheData("ApplyList", tbApplyList, nVersion);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, "ApplyList");
	Kin:UpdateRedPoint();
end

function Kin:GetApplyerList()
	return Kin:GetData("ApplyList");
end

function Kin:MarkCurApplyListSeen()
	local _, nVersion = Kin:GetApplyerList();
	if nVersion then
		Kin:CacheData("ApplyListSeenVersion", nVersion);
	end
end

function Kin:UpdateApplyInfo(bManual)
	local _, nVersion = Kin:GetApplyerList();
	RemoteServer.OnKinRequest("SyncApplyerList", nVersion, bManual);
end

function Kin:OnSyncRecruit(tbRecruitSetting, nVersion)
	Kin:CacheData("RecruitSetting", tbRecruitSetting, nVersion);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, "RecruitSetting");
end

function Kin:GetRecruitSetting()
	return Kin:GetData("RecruitSetting");
end

function Kin:UpdateRecruitSetting()
	local _, nVersion = Kin:GetRecruitSetting();
	RemoteServer.OnKinRequest("SyncRecruiSetting", nVersion);
end

function Kin:SetRecruitSetting(bAutoRecruitNewer, bConditionRecruit, nLimitLevel, tbFaction)
	RemoteServer.OnKinRequest("SetRecruitSetting", bAutoRecruitNewer, bConditionRecruit, nLimitLevel, tbFaction);
end

function Kin:GetDonationData()
	return DegreeCtrl:GetDegree(me, "DonationCount"), DegreeCtrl:GetMaxDegree("DonationCount", me);
end

function Kin:Donate(nCount)
	if nCount<=0 then
		return
	end
	local nCurDonateCount = Kin:GetDonationData()
	RemoteServer.OnKinRequest("Donate", nCurDonateCount, nCount)
end

function Kin:UpdateDonationRecord()
	local _, nVersion = Kin:GetDonationRecord();
	RemoteServer.OnKinRequest("SyncDonationRecord", nVersion);
end

function Kin:GetDonationRecord()
	return Kin:GetData("DonationRecord");
end

function Kin:OnSyncDonationRecord(tbRecord, nVersion)
	Kin:CacheData("DonationRecord", tbRecord, nVersion);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, "DonationRecord");
end

function Kin:GetSendMailFee()
	local tbMemberList = Kin:GetMemberList();
	return #tbMemberList * Kin.Def.nSendMailFeeRate;
end

function Kin:UpdateMailInfo()
	local nMailCount = Kin:GetLeftMailCount();
	RemoteServer.OnKinRequest("SyncMailCount", nMailCount);
end

function Kin:GetLeftMailCount()
	return Kin:GetData("MailCount");
end

function Kin:OnSyncMailCount(nCount)
	Kin:CacheData("MailCount", nCount);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, "MailCount");
end

function Kin:SendKinMail(szMail, bSendPhoneNotify)
	if ReplaceLimitWords(szMail) then
	  	me.CenterMsg("内容中含有敏感字符，请修改后重试");
  		return false;
	end

	RemoteServer.OnKinRequest("SendKinMail", szMail, bSendPhoneNotify);
	return true;
end

function Kin:ChangeCareer(nMemberId, nCareer, nReplaceMemberId, szName)
	local fnConfirm = function()
		local fnChangeCareer = function ()
			RemoteServer.OnKinRequest("ChangeCareer", nMemberId, nCareer, nReplaceMemberId);
		end

		if nCareer == Kin.Def.Career_Master then
			local fnNoticeChange = function ()
				local szTip = string.format("你是否要将 [FFFE0D]%s[-] 任命为族长？任命成功后原族长将成为普通成员。", szName or "他")
					me.MsgBox(szTip, { {"确定", function ()
						fnChangeCareer();
					end}, {"取消"}});
			end

			local tbBaseInfo = Kin:GetBaseInfo();
			if tbBaseInfo.szGroupOpenId then
				me.MsgBox("移交族长前必须解除家族群绑定, 是否确认解除?", { {"确定", function ()
					Kin:UnbindQQGroup(tbBaseInfo.szGroupOpenId, me.dwKinId, true);
					Timer:Register(1, function ()
						fnNoticeChange();
					end)
				end}, {"取消"}});
			else
				Timer:Register(1, function()
					fnNoticeChange();
				end)
			end
			return;
		end

		fnChangeCareer();
	end

	if Kin:WillSendSalaryIn24Hours() and Kin:ShouldSalaryWarn({nReplaceMemberId}, {nMemberId}, nCareer) then
		if nReplaceMemberId and nReplaceMemberId>0 then
			Ui:OpenWindow("MessageBox", "任职未满[FFFE0D]24小时[-]将无法获得工资，是否确定在此时替换职位成员？", { {fnConfirm},{}  }, {"确定", "取消"})
		else
			Ui:OpenWindow("MessageBox", "小提示：任职未满[FFFE0D]24小时[-]将无法获得工资", { {fnConfirm}, {}, }, {"确定任命", "取消"})
		end
	else
		fnConfirm()
	end
end

function Kin:LeaderInfoChange()
	UiNotify.OnNotify(UiNotify.emNOTIFY_LEADER_INFO_CHANGE)
end

function Kin:ChangeCareers(nCareer, tbCancelMember, tbChangeMember)
	RemoteServer.OnKinRequest("ChangeCareers", nCareer, tbCancelMember, tbChangeMember);
end

function Kin:AppointLeader(nCandidateId)
	if not nCandidateId then
		me.CenterMsg("请先选择要被任命的成员")
		return
	end
	if nCandidateId==me.dwID then
		me.CenterMsg("不能任命自己")
		return
	end

	local tbData = Kin:GetMemberData(nCandidateId)
	local nLastOnlineTime = tbData.nLastOnlineTime
	local nDays = Lib:SecondsToDays(GetTime()-nLastOnlineTime)

	local function fnAppoint()
		RemoteServer.OnKinRequest("AppointLeader", nCandidateId)
	end

	if nDays>=7 then
		me.MsgBox(string.format("「%s」离线超7天，确定继续任命吗？", tbData.szName), {{"确定", fnAppoint}, {"取消"}})
	else
		me.MsgBox(string.format("你是否要将 [FFFE0D]%s[-] 任命为领袖？任命成功后原领袖将成为普通成员。", tbData.szName),
			{ {"确定", fnAppoint}, {"取消"}})
	end
end

function Kin:ChangePublicDeclare(szDeclare)
	szDeclare = ReplaceLimitWords(szDeclare) or szDeclare;
	RemoteServer.OnKinRequest("ChangePublicDeclare", szDeclare);
end

function Kin:ChangeAddDeclare(szAddDeclare, tbVoice)
	RemoteServer.OnKinRequest("ChangeAddDeclare", szAddDeclare, tbVoice);
end

function Kin:CleanApplyList()
	RemoteServer.OnKinRequest("CleanApplyerList");
	Kin:CacheData("ApplyList", {});

	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, "ApplyList");
	Kin:UpdateRedPoint();
end

function Kin:AgreeApply(nApplyerId)
	RemoteServer.OnKinRequest("AgreeApply", nApplyerId);
end

function Kin:DisAgreeApply(nApplyerId)
	RemoteServer.OnKinRequest("DisagreeApply", nApplyerId);
end

function Kin:Quite()
	RemoteServer.OnKinRequest("Quite");
end

function Kin:ClearData()
	Kin:ClearCache();
	Kin:RedBagClear()
	Kin:EscortFinishInfoClear()
end

function Kin:OnQuite()
	self:ClearData()
	me.szKinTitle = "";
	me.dwKinId = 0;
	Ui:CloseWindow("KinDetailPanel");
	me.CenterMsg("你已成功退出家族");
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, "Quit");
end

--------------------------------家族建设------------------------------
function Kin:OnSyncBuildingData(tbBuildingData, nVersion)
	Kin:CacheData("BuildingData", tbBuildingData, nVersion);
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, "Building");
end

function Kin:GetAllBuildingData()
	return Kin:GetData("BuildingData");
end

function Kin:UpdateBuildingData()
	if not Kin:HasKin() then
		return;
	end

	local _, nVersion = Kin:GetAllBuildingData();
	RemoteServer.OnKinRequest("SyncBuildingData", nVersion);
end

function Kin:GetBuildingName(nBuildingId)
	return assert(Kin.Def.BuildingName[nBuildingId]);
end

function Kin:GetFound()
	local tbBaseData = Kin:GetBaseInfo() or {};
	return tbBaseData.nFound or 0;
end

function Kin:GetBuildingData(nBuildingId)
	local tbBuilding = Kin:GetAllBuildingData() or {};
	return tbBuilding[nBuildingId];
end

function Kin:GetBuildingLevel(nBuildingId)
	local tbBuildingData = Kin:GetBuildingData(nBuildingId) or {};
	return tbBuildingData.nLevel or 0;
end

function Kin:BuildingUpgrade(nBuildingId)
	RemoteServer.OnKinRequest("BuildingUpgrade", nBuildingId)
end

-----------------------------------------------------------------------

function Kin:GetMemberData(nId)
	local tbMemberList = Kin:GetData("MemberList") or {}
	for _, tbData in pairs(tbMemberList) do
		if tbData.nMemberId == nId then
			return tbData
		end
	end
end

function Kin:GetMyMemberData()
	return self:GetMemberData(me.dwID)
end

function Kin:CheckMyAuthority(authority)
	local myMemberData = Kin:GetMyMemberData();
	if not myMemberData then
		return false;
	end

	if (Kin.Def.Authority_GrantMaster==authority or Kin.Def.Authority_GrantLeader==authority) and Kin:AmILeader() then
		return true
	end

	local careerAuthority = Kin.Def.Career_Authority[myMemberData.nCareer] or {};
	if careerAuthority[authority] then
		return true;
	end

	if Kin:AmILeader() and Kin.Def.Career_Authority[Kin.Def.Career_Leader][authority] then
		return true;
	end

	return myMemberData.tbAuthority and myMemberData.tbAuthority[authority] and true or false;
end

function Kin:GetTitleSettingData()
	local tbMemberList = Kin:GetData("MemberList");
	local tbBaseInfo = Kin:GetData("BaseInfo");
	local tbTitleEditList = {};

	if not tbMemberList or not tbBaseInfo then
		return tbTitleEditList;
	end

	for _, tbMemberData in pairs(tbMemberList) do
		if not TitleSettingCareer[tbMemberData.nCareer] then
			table.insert(tbTitleEditList, {
				nCareer = tbMemberData.nCareer;
				szKinTitle = tbMemberData.szKinTitle;
				nMemberId = tbMemberData.nMemberId;
				szName = tbMemberData.szName;
				nVipLevel = tbMemberData.nVipLevel;
			})
		end
	end

	--添加领袖
	local tbLeaderData = Kin:GetLeaderData()
	if tbLeaderData then
		table.insert(tbTitleEditList, {
			nCareer = Kin.Def.Career_Leader;
			szKinTitle = Kin:GetLeaderTitle();
			nMemberId = tbLeaderData.nMemberId;
			szName = tbLeaderData.szName;
			nVipLevel = tbLeaderData.nVipLevel;
		})
	end

	for nCareer, szName in pairs(TitleSettingCareer) do
		table.insert(tbTitleEditList, {
			nCareer = nCareer;
			szKinTitle = tbBaseInfo.tbKinTitle[nCareer];
			nMemberId = 0;
			szName = szName;
		})
	end

	for i=#tbTitleEditList,1,-1 do
		local tbData = tbTitleEditList[i]
		if tbUneditableCareers[tbData.nCareer] then
			table.remove(tbTitleEditList, i)
		end
	end

	table.sort(tbTitleEditList, function(tbA, tbB)
		local bLeaderA = tbA.nCareer==Kin.Def.Career_Leader
		local bLeaderB = tbB.nCareer==Kin.Def.Career_Leader
		if bLeaderA or bLeaderB then
			return bLeaderA
		end
		local nOrderA = Kin.Def.tbCareersOrder[tbA.nCareer] or math.huge
		local nOrderB = Kin.Def.tbCareersOrder[tbB.nCareer] or math.huge
		return nOrderA < nOrderB or (nOrderA == nOrderB and tbA.nMemberId < tbB.nMemberId)
	end)

	return tbTitleEditList;
end

function Kin:GetTitleSettingMap()
	local tbSpeialTitle = {};
	local tbMemberList = Kin:GetData("MemberList") or {};
	local tbBaseInfo = Kin:GetData("BaseInfo") or {};

	for _, tbMemberData in pairs(tbMemberList) do
		if not TitleSettingCareer[tbMemberData.nCareer] then
			tbSpeialTitle[tbMemberData.nMemberId] = tbMemberData.szKinTitle;
		end
	end

	return tbSpeialTitle, tbBaseInfo.tbKinTitle;
end

-----------------------------家族福利礼包-----------------------------------
function Kin:BuyGiftBox()
	local nTongbao = me.GetMoney("Contrib");
	if nTongbao < Kin.Def.nGiftBoxCost then
		me.CenterMsg("领取失败，贡献不足");
		return;
	end

	RemoteServer.OnKinRequest("BuyGiftBox");
end

function Kin:OnUpdateGiftBoxData()
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA, "GiftBox");
	Kin:UpdateRedPoint();
end

function Kin:GetGiftBoxData()
	local nNow    = GetTime();
	local nToday  = Lib:GetLocalDay(nNow - Kin.Def.nGiftBagRefreshTime);
	local nCurDay = me.GetUserValue(Kin.Def.MEMBER_GIFT_KEY_GROUP, Kin.Def.MEMBER_GIFT_KEY_CUR_DAY);
	if nCurDay ~= nToday then
		return Kin:GetGiftMaxCount(me.GetVipLevel()), nNow - 1;
	end

	local nNextBuyTime = me.GetUserValue(Kin.Def.MEMBER_GIFT_KEY_GROUP, Kin.Def.MEMBER_GIFT_KEY_NEXT_BUY_TIME);
	local nLeftCount   = me.GetUserValue(Kin.Def.MEMBER_GIFT_KEY_GROUP, Kin.Def.MEMBER_GIFT_KEY_LEFT_COUNT);
	return nLeftCount, nNextBuyTime;
end

------------------------------------------------------------------

function Kin:GoKinMap()
	AutoFight:StopAll();
	Map:SwitchMap(Kin.Def.nKinMapTemplateId);
end

function Kin:IsNormalCareer(nCareer)
	return (nCareer ~= Kin.Def.Career_New
			and nCareer ~= Kin.Def.Career_Retire);
end

function Kin:GatherDrink()
	if me.nMapTemplateId ~= Kin.Def.nKinMapTemplateId then
		me.MsgBox("确定要回到家族参加活动吗？", {{"确定", Kin.GoKinMap}, {"取消"}});
		return;
	end
	RemoteServer.OnKinGatherRequest("Drink");
end

function Kin:GatherAnswer(nQuizIndex, nAnswerIndex)
	RemoteServer.OnKinGatherRequest("Answer", nQuizIndex, nAnswerIndex);
end

function Kin:GetGatherAnswerRightCount()
	return self.nGatherAnswerRightCount or 0;
end

function Kin:OnSyncGatherAnswerRightCount(nCount)
	self.nGatherAnswerRightCount = nCount;
	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_KIN_DATA);
	UiNotify.OnNotify(UiNotify.emNOTIFY_KINGATHER_UPDATE)
end

function Kin:OnSyncEscortInfo(tbInfo)
	self.tbEscortCarriageInfo = tbInfo
end

function Kin:GetEscortCarPos()
	if not next(self.tbEscortCarriageInfo or {}) then
		return
	end
	return self.tbEscortCarriageInfo.nMapId, self.tbEscortCarriageInfo.nX, self.tbEscortCarriageInfo.nY
end

function Kin:EscortFinishInfoClear()
	self.bEscortFinished = nil
	self.nLastEscortDate = nil
	self.tbEscortCarriageInfo = nil
end

function Kin:IsEscortFinished()
	local nKinId = me.dwKinId
	if not nKinId or nKinId<=0 then
		return false
	end

	if self.bEscortFinished and self.nLastEscortDate==Lib:GetLocalDay() then
		return true
	end

	RemoteServer.OnKinRequest("EscortFinishInfoReq")
	return false
end

function Kin:EscortFinishInfoRsp(nLastEscortDate, bFinished)
	self.bEscortFinished = bFinished
	self.nLastEscortDate = nLastEscortDate
end

function Kin:GatherDiceShake(szType)
	self.tbGatherDiceScore = nil;
	if szType == "DrinkHouse" then
		RemoteServer.DrinkHousePlayerRequest("DiceShake");
	else
		RemoteServer.OnKinGatherRequest("DiceShake");
	end

end

function Kin:OnSyncGatherDice(tbScore)
	self.tbGatherDiceScore = tbScore;
	local nScore = 0
    for i = 1, 3 do
        nScore = nScore + tbScore[i]
    end
    self.tbGatherData = self.tbGatherData or {};
    self.tbGatherData.nScore = nScore
	UiNotify.OnNotify(UiNotify.emNOTIFY_KINGATHER_UPDATE)
end

function Kin:GetGatherDiceScore()
	return self.tbGatherDiceScore;
end

function Kin:BeginDice(nTimeOut)
	Ui:OpenWindow("KinDicePanel", nTimeOut);
end

function Kin:AskAllMemberFriend()
	RemoteServer.OnKinRequest("AskAllMemberFriend");
end

function Kin:UpdateCheckRobberCanOpen()
	if me.dwKinId == 0 then
		return false, "没有家族";
	end

	RemoteServer.OnKinRequest("CheckRobberCanOpen");
end

function Kin:AcceptCheckRobberCanOpen(bOpen)
		Kin:CacheData("CheckRobberCanOpen",bOpen);
end

function Kin:CheckRobberCanOpen()
	return Kin:GetData("CheckRobberCanOpen");
end

function Kin:OpenKinFireUi(tbData)
	self.tbGatherData = {}
	for szKey, Value in pairs(tbData) do
		self.tbGatherData[szKey] = Value
	end
	Ui:OpenWindow("KinFireDisplay")
end

-- 当前进行到第几题;篝火经验加成;实时人数;剩余时间...
function Kin:OnSyncGatherOtherData(tbData)
	self.tbGatherData = self.tbGatherData or {}
	for szKey, Value in pairs(tbData) do
		self.tbGatherData[szKey] = Value
	end
	UiNotify.OnNotify(UiNotify.emNOTIFY_KINGATHER_UPDATE)
end

function Kin:GetGatherOtherData()
	return self.tbGatherData or {}
end

function Kin:AfterDrink()
	self.tbGatherData = self.tbGatherData or {}
	self.tbGatherData[Kin.GatherDef.DrinkFlag] = true
end

function Kin:CanGetKinGift()
	if not Kin:HasKin() then return false end

	local nNow = GetTime()
	local nLeftCount, nNextBuyTime = Kin:GetGiftBoxData();
	local nContrib = me.GetMoney("Contrib")

	return nLeftCount>0 and nNow>nNextBuyTime and nContrib>=Kin.Def.nGiftBoxCost
end

function Kin:CanShowKinsStoreRed()
	if not Kin:HasKin() then return false end
	if Kin:GetBuildingLevel(Kin.Def.Building_DrugStore) <= 0 then
		return false;
	end
	local nOpenKinStoreDay = Client:GetFlag("OpenKinStoreDay")
	return nOpenKinStoreDay ~= Lib:GetLocalDay(GetTime() - 3600 * 4)
end

function Kin:UpdateGiftRedPoint()
	if self:CanGetKinGift() then
		Ui:SetRedPointNotify("KinGiftGain")
	else
		Ui:ClearRedPointNotify("KinGiftGain")
	end
end

function Kin:UpdateRedPoint()
	local tbApplyList, nVersion = Kin:GetApplyerList();
	local nApplyListSeenVersion = Kin:GetData("ApplyListSeenVersion");
	if tbApplyList
		and next(tbApplyList)
		and nApplyListSeenVersion ~= nVersion
		and Kin:CheckMyAuthority(Kin.Def.Authority_Recruit)
		then
		Ui:SetRedPointNotify("KinMemberRedPoint");
	else
		Ui:ClearRedPointNotify("KinMemberRedPoint");
	end
	self:UpdateGiftRedPoint()


	if self:CanShowKinsStoreRed() then
		Ui:SetRedPointNotify("KinStoreRedPoint");
	else
		Ui:ClearRedPointNotify("KinStoreRedPoint");
	end

	Ui:CheckRedPoint("KinTopButton");
end

local SortFunction = {
	["SortByFaction"] = function(tbMemberList,bIsDown)
		table.sort(tbMemberList, function (a, b)
			if bIsDown then
				return a.nFaction > b.nFaction;
			else
				return a.nFaction < b.nFaction;
			end
		end)
		return tbMemberList;
	end,

	["SortByRank"]  = function(tbMemberList,bIsDown)
		table.sort(tbMemberList, function (a, b)
			if bIsDown then
				return a.nHonorLevel > b.nHonorLevel;
			else
				return a.nHonorLevel < b.nHonorLevel;
			end
		end)
		return tbMemberList;
	end,

	["SortByName"]  = function(tbMemberList,bIsDown)
		table.sort(tbMemberList, function (a, b)
			if bIsDown then
				return a.szName > b.szName;
			else
				return a.szName < b.szName;
			end
		end)
		return tbMemberList;
	end,

	["SortByLevel"]  = function(tbMemberList,bIsDown)
		table.sort(tbMemberList, function (a, b)
			local nLvlA = a.nLevel
			local nLvlB = b.nLevel
			if bIsDown then
				if nLvlA ~= nLvlB then
					return nLvlA > nLvlB
				else
					return a.nExp > b.nExp
				end
			else
				if nLvlA ~= nLvlB then
					return nLvlA < nLvlB
				else
					return a.nExp < b.nExp
				end
			end
		end)
		return tbMemberList;
	end,

	["SortByPost"]  = function(tbMemberList,bIsDown)
		table.sort(tbMemberList, function (a, b)
			local nLeaderId = Kin:GetLeaderId()
			local nCandidateId = Kin:GetCandidateLeaderId()
			if bIsDown then
				if a.nMemberId==nLeaderId or b.nMemberId==nLeaderId then
					return a.nMemberId==nLeaderId
				end
				if a.nMemberId==nCandidateId or b.nMemberId==nCandidateId then
					return a.nMemberId==nCandidateId
				end

				local nOrderA = Kin.Def.tbCareersOrder[a.nCareer] or math.huge
				local nOrderB = Kin.Def.tbCareersOrder[b.nCareer] or math.huge
				return nOrderA<nOrderB or (nOrderA==nOrderB and a.nMemberId<b.nMemberId)
			else
				if a.nMemberId==nLeaderId or b.nMemberId==nLeaderId then
					return b.nMemberId==nLeaderId
				end
				if a.nMemberId==nCandidateId or b.nMemberId==nCandidateId then
					return b.nMemberId==nCandidateId
				end

				local nOrderA = Kin.Def.tbCareersOrder[a.nCareer] or math.huge
				local nOrderB = Kin.Def.tbCareersOrder[b.nCareer] or math.huge
				return nOrderA>nOrderB or (nOrderA==nOrderB and a.nMemberId>b.nMemberId)
			end
		end)
		return tbMemberList;
	end,

	["SortByContribution"] = function(tbMemberList,bIsDown)
		table.sort(tbMemberList, function (a, b)
			if bIsDown then
				return a.nContribution > b.nContribution;
			else
				return a.nContribution < b.nContribution;
			end
		end)
		return tbMemberList;
	end,

	["SortByOffline"] = function(tbMemberList,bIsDown)
		local tbOnlineMembers = Kin:GetMemberState() or {};
		table.sort(tbMemberList,function (a, b)
			if bIsDown then
				-- 在线相关
				if tbOnlineMembers[a.nMemberId] and not tbOnlineMembers[b.nMemberId] then
					return true;
				elseif not tbOnlineMembers[a.nMemberId] and tbOnlineMembers[b.nMemberId] then
					return false;
				end
				return a.nLastOnlineTime > b.nLastOnlineTime;
			else
				-- 在线负相关
				if tbOnlineMembers[a.nMemberId] and not tbOnlineMembers[b.nMemberId] then
					return false;
				elseif not tbOnlineMembers[a.nMemberId] and tbOnlineMembers[b.nMemberId] then
					return true;
				end
				return a.nLastOnlineTime < b.nLastOnlineTime;
			end
		end )
		return tbMemberList;
	end,

	["SortByApplyName"] = function(tbMemberList,bIsDown)
		table.sort(tbMemberList,function (a, b)
			if bIsDown then
				return a.szPlayerName > b.szPlayerName;
			else
				return a.szPlayerName < b.szPlayerName;
			end
		end )
		return tbMemberList;
	end,

	["SortByApplyLevel"] = function(tbMemberList,bIsDown)
		table.sort(tbMemberList,function (a, b)
			if bIsDown then
				return a.nPlayerLevel > b.nPlayerLevel;
			else
				return a.nPlayerLevel < b.nPlayerLevel;
			end
		end )
		return tbMemberList;
	end,

	["SortByApplyOffline"] = function(tbMemberList,bIsDown)
		local tbOnlineMembers = Kin:GetMemberState() or {};
		table.sort(tbMemberList,function (a, b)
			if bIsDown then
				-- 在线相关
				if tbOnlineMembers[a.nMemberId] and not tbOnlineMembers[b.nMemberId] then
					return true;
				elseif not tbOnlineMembers[a.nMemberId] and tbOnlineMembers[b.nMemberId] then
					return false;
				end
				return a.nTime > b.nTime;
			else
				-- 在线负相关
				if tbOnlineMembers[a.nMemberId] and not tbOnlineMembers[b.nMemberId] then
					return false;
				elseif not tbOnlineMembers[a.nMemberId] and tbOnlineMembers[b.nMemberId] then
					return true;
				end
				return a.nTime < b.nTime;
			end
		end )
		return tbMemberList;
	end,

	["SortByActivity"] = function(tbMemberList, bIsDown)
		table.sort(tbMemberList, function (a, b)
			if bIsDown then
				return a.nActivity > b.nActivity;
			else
				return a.nActivity < b.nActivity;
			end
		end)
		return tbMemberList;
	end,

	["SortByChuangGong"] = function(tbMemberList, bIsDown)

		local tbOnlineMembers = Kin:GetMemberState() or {};
		table.sort(tbMemberList,function (a, b)

			local tbAParam = {
				nLevel = a.nLevel,
				nVipLevel = a.nVipLevel,
				nChuangGongTimes = a.nChuangGongTimes,
				nChuangGongSendTimes = a.nChuangGongSendTimes,
				nLastChuangGongSendTime = a.nLastChuangGongSendTime,
			}

			local tbBParam = {
				nLevel = b.nLevel,
				nVipLevel = b.nVipLevel,
				nChuangGongTimes = b.nChuangGongTimes,
				nChuangGongSendTimes = b.nChuangGongSendTimes,
				nLastChuangGongSendTime = b.nLastChuangGongSendTime,
			}

			local bAIsOnline = tbOnlineMembers[a.nMemberId]
			local bBIsOnline = tbOnlineMembers[b.nMemberId]
			local bAIsCan = not not (bAIsOnline and ChuangGong:IsCanChuangGong(tbAParam))
			local bBIsCan = not not (bBIsOnline and ChuangGong:IsCanChuangGong(tbBParam))
			local nLvlA = a.nLevel
			local nLvlB = b.nLevel

			local function _sort()
				if bAIsCan ~= bBIsCan then
					return bAIsCan
				end

				if bAIsCan then
					if nLvlA ~= nLvlB then
						return nLvlA > nLvlB
					end
					return a.nExp > b.nExp
				end

				if bAIsOnline ~= bBIsOnline then
					return bAIsOnline
				end

				if nLvlA ~= nLvlB then
					return nLvlA > nLvlB
				end
				return a.nExp > b.nExp
			end

			if bIsDown then
				return _sort()
			else
				return not _sort()
			end
		end )

		return tbMemberList;
	end,
};


function Kin:GetSortFunction(szFunName)
	return SortFunction[szFunName];
end

function Kin:StartRedPointTimer()
	Kin:UpdateRedPoint()
	self:StopRedPointTimer()
	self.nRedPointTimer = Timer:Register(Env.GAME_FPS*5, function()
		self:UpdateGiftRedPoint()
		return true
	end)
end

function Kin:StopRedPointTimer()
	if self.nRedPointTimer then
		Timer:Close(self.nRedPointTimer)
		self.nRedPointTimer = nil
	end
end

function Kin:UpdateGroupInfo(bForce)
	local nNow = GetTime();
	if self.nNextUpdateGroupInfoTime and self.nNextUpdateGroupInfoTime > nNow then
		if not bForce then
			return;
		end
	end

	self.nNextUpdateGroupInfoTime = nNow + 30; -- 最快30秒刷一次绑群信息
	if Sdk:IsLoginByWeixin() then
		Sdk:QueryGroupInfo(me.dwKinId);
	else
		RemoteServer.OnKinRequest("UpdateGroupInfo");
	end
end

function Kin:Ask2JoinGroup()
	RemoteServer.OnKinRequest("Ask4JoinQQGroup");
end

function Kin:BindQQGroup(szKinName, bRemote)
	-- if bRemote then
		RemoteServer.OnKinRequest("QueryQQGroupList");
	-- else
		-- Sdk:BindQQGroup(me.dwKinId, szKinName);
	-- end
end

function Kin:BindQQGroupRemote(bCreateNew, szGroupNum, szGroupName)
	RemoteServer.OnKinRequest("BindQQGroup", bCreateNew, szGroupNum, szGroupName);
end

function Kin:OnQQGroupListRsp(tbGroupList)
	Ui:OpenWindow("QQGroupPanel", tbGroupList);
end

function Kin:UnbindQQGroup(szGroupOpenId, nKinId, bRemote)
	if bRemote or IOS then
		RemoteServer.OnKinRequest("UnbindQQGroup");
	else
		Sdk:UnbindQQGroup(szGroupOpenId, nKinId)
	end
end

function Kin:MyKinRankRsp(nRank)
	local tbUi = Ui:GetClass("NewInfo_OpenSrvActivity")
	if not tbUi then
		return
	end

	tbUi:SetMyKinRank(nRank)
end

function Kin:OnLogin()
	if Kin:HasKin() then
        Kin:UpdateMemberList()
        self:EscortFinishInfoClear()
    end
end

function Kin:OnLogout()
	self:ClearData()
end

-- return bWarn, bCancelManager
function Kin:ShouldSalaryWarn(tbCancel, tbChange, nNewCareer)
	for _, nId in pairs(tbCancel) do
		if self:IsMemberManager(nId) then
			return true, true
		end
	end
	for _, nId in pairs(tbChange) do
		if self:IsMemberManager(nId) then
			return true, false
		end
	end
	return self.Def.tbManagerCareers[nNewCareer], false
end

function Kin:WillSendSalaryIn24Hours()
	local nNow = os.time()
	local tbDate = os.date("*t", nNow)
	local wday = tbDate.wday
	local hour = tbDate.hour
	local minute = tbDate.min
	local nTime = hour*100+minute
	if wday==1 and nTime>=355 then
		return true
	end
	if wday==2 and nTime<=355 then
		return true
	end
	return false
end

function Kin:SyncMascotOpenStatus()
	RemoteServer.OnKinRequest("SyncMascotOpenStatus")
end

function Kin:OnSyncMascotOpenStatus(bClosed)
	self.bMascotClosed = bClosed
end

function Kin:IsCareerClosed(nCareer)
	if nCareer==Kin.Def.Career_Mascot then
		return self.bMascotClosed
	end
	return false
end

function Kin:CanGetSalary()
	local tbMyData = self:GetMyMemberData()
	if not tbMyData then
		return false
	end
	return self.tbActivityCareerSalary[tbMyData.nCareer]
end

function Kin:ChanePosition(nCareer,nOldCareer)
	ChatMgr.ChatDecorate:ChanePosition(nCareer,nOldCareer)
end

function Kin:SendQQGroupInvitation()
	if not Sdk:IsLoginByQQ() then
		me.CenterMsg("您需要通过手Q登入才可发送Q群消息");
		return;
	end
	RemoteServer.OnKinRequest("SendQQGroupInvitation");
end

function Kin:GroupNotify(nPlatCode)
	UiNotify.OnNotify(UiNotify.emNOTIFY_GROUP_INFO, nPlatCode);
end

function Kin:IsShowQQGroupCall()
	return self.bIsShowQQGroupCall;
end

function Kin:SetShowQQGroupCall(bShow)
	self.bIsShowQQGroupCall = bShow;
end

function Kin:OnSynMiniMainMapInfo(bShow)
	local tbSynInfo = {}
	tbSynInfo[Kin.MonsterNianDef.szMapMonsterIndex] = bShow and "年兽" or ""
	local tbMapTextPosInfo = Map:GetMapTextPosInfo(me.nMapTemplateId)
	for i,v in ipairs(tbMapTextPosInfo) do
		local szNewName = tbSynInfo[v.Index]
		if szNewName then
			v.Text = szNewName
		end
	end
end