
local tbUi = Ui:CreateClass("TeamFubenMission");
tbUi.nMaxItemCount = 6;
tbUi.nFlyAniTime = 0.7;
--tbUi.nTotalSpaceTime = tbUi.nFlyAniTime +; -- 这里多出来的 0.2s是两次加数字的间隔时间

function tbUi:OnOpen(szName, nScroe, tbMember, nCostTime, tbPlayerAward, bHasNewPlayer)
	self.szName = szName;
	self.nScroe = nScroe;
	self.tbMember = tbMember;
	self.nCostTime = nCostTime or 0;
	self.tbPlayerAward = tbPlayerAward or {};
	self.tbPlayerAward.nExp = self.tbPlayerAward.nExp or 0;
	self.bIsShowScoreInfo = false;
	self.szCurType = nil;
	self.bHasNewPlayer = bHasNewPlayer;

	self.pPanel:NumberAni_SetNumberDirect("ScroeInfo", 0, false);
	self:Update();
end

function tbUi:Update()
	self:UpdatePlayerAward();
	self:UpdateTeamMemberInfo();
	self:UpdateScroe();
end

function tbUi:UpdateScroe(nScroe)
	self.pPanel:Label_SetText("SectionName", self.szName or "--");
	self.pPanel:SetActive("Pass", false);

	self.nScroe = nScroe or self.nScroe;
	local szType, nPresent, nNextLevelScroe = self:GetGradePersent();

	local nMin = math.floor(self.nCostTime / 60);
	local nSce = math.floor(self.nCostTime % 60);
	self.pPanel:Label_SetText("TimeInfo", string.format("%02s:%02s", nMin, nSce));
	self.pPanel:NumberAni_SetNumber("ScroeInfo", tonumber(self.nScroe or 0), false);

	if not self.szCurType or self.szCurType ~= szType then
		self:SetGradeLevel(szType);
	end

	self.szCurType = szType;

	local szMsg = "当前已是最高奖励等级";
	if nNextLevelScroe then
		szMsg = string.format("当前得分%s，差%s分可提升奖励等级", self.nScroe, nNextLevelScroe - self.nScroe);
	end

	self.pPanel:Label_SetText("ScroeTips", szMsg);
	self.pPanel:ProgressBar_SetValue("ScroeProgress", nPresent);

	self.pPanel:SetActive("TraineeTip", self.bHasNewPlayer);
	if self.bHasNewPlayer then
		self.pPanel:Label_SetText("TraineeTip", string.format("队伍中有本家族见习成员，秘境积分+%s", TeamFuben.KIN_NEWER_SCROE));
	end

	local nGrade = MissionAward:GetGrade(MissionAward.emType_TeamFuben, self.nScroe);
	local tbAward = TeamFuben.tbExtMissAward[nGrade];
	local nExpCount = 0;
	for _, tbInfo in pairs(tbAward or {}) do
		if Player.AwardType[tbInfo[1]] == Player.award_type_basic_exp then
			nExpCount = nExpCount + me.GetBaseAwardExp() * tbInfo[2];
		elseif Player.AwardType[tbInfo[1]] == Player.award_type_exp then
			nExpCount = nExpCount + tbInfo[2];
		end
	end

	self.pPanel:Label_SetText("ExpCount", "+" .. (self.tbPlayerAward.nExp + nExpCount));
	self.pPanel:ProgressBar_SetValue("ExpInfo", math.min((me.GetExp() + nExpCount + self.tbPlayerAward.nExp) / me.GetNextLevelExp(), 1));
end

function tbUi:UpdatePlayerAward()
	self.pPanel:Label_SetText("PlayerLevel", string.format("%s级", me.nLevel));

	local nCurBoxIdx = 1;
	for nIndex, tbInfo in pairs(self.tbPlayerAward.tbOther or {}) do
		self["itemframe" .. nIndex]:SetGenericItem(tbInfo);
		self["itemframe" .. nIndex].fnClick = self["itemframe" .. nIndex].DefaultClick;
		nCurBoxIdx = nIndex + 1;
		if nCurBoxIdx > self.nMaxItemCount then
			break;
		end
	end

	for i = nCurBoxIdx, self.nMaxItemCount do
		self["itemframe" .. i]:Clear();
		self["itemframe" .. nCurBoxIdx].fnClick = nil;
	end
end

function tbUi:UpdateTeamMemberInfo()
	for i = 1, 3 do
		if self.tbMember[i] then
			self.pPanel:SetActive("FriendInformation" .. i, true);

			local szIcon, szIconAtlas = PlayerPortrait:GetPortraitIcon(self.tbMember[i].nPortrait);
			self.pPanel:Sprite_SetSprite("SpRoleHead" .. i, szIcon, szIconAtlas);
			self.pPanel:Sprite_SetSprite("SpFaction" .. i, Faction:GetIcon(self.tbMember[i].nFaction));
			self.pPanel:Label_SetText("lbLevel" .. i, self.tbMember[i].nLevel);
			self.pPanel:Label_SetText("Name" .. i, self.tbMember[i].szName);

			local bIsFriend = FriendShip:IsFriend(me.dwID, self.tbMember[i].nPlayerId);
			self.pPanel:Button_SetEnabled("Friend" .. i, not bIsFriend);
			self.pPanel:Sprite_SetGray("Friend" .. i, bIsFriend and true or false);
			self.pPanel:Button_SetText("Friend" .. i, bIsFriend and "好  友" or "加为好友");

			local szShowInfo, bBtnEnabled, bShowScroe = self:GetFamilyShowInfo(me.dwKinId, self.tbMember[i].dwKinId);
			self.pPanel:Button_SetText("Family" .. i, szShowInfo);
			self.pPanel:Button_SetEnabled("Family" .. i, bBtnEnabled);
			self.pPanel:Sprite_SetGray("Family" .. i, not bBtnEnabled);
			self.pPanel:SetActive("AddFaScroe" .. i, bShowScroe);

			local nImity = FriendShip:GetImity(me.dwID, self.tbMember[i].nPlayerId);
			local nImityLevel = FriendShip:GetImityLevel(nImity);
			self.pPanel:Label_SetText("AddFrScroe" .. i, "+" .. TeamFuben:GetFriendLevelScroe(math.max(nImityLevel or 1, 1)));
			self.pPanel:Label_SetText("AddFaScroe" .. i, "+" .. TeamFuben.SAME_KIN_SCROE);
		else
			self.pPanel:SetActive("FriendInformation" .. i, false);
		end
	end
end

function tbUi:GetFamilyShowInfo(nMyKinId, nMemberKinId)
	if me.dwKinId <= 0 then
		if nMemberKinId <= 0 then
			return "对方无家族", false, false;
		else
			return "加入家族", true, true;
		end
	else
		if nMemberKinId <= 0 then
			return "邀请家族", true, true;
		elseif nMemberKinId ~= nMyKinId then
			return "已有家族", false, false;
		else
			return "相同家族", false, true;
		end
	end
end

function tbUi:SetGradeLevel(szType)
	self.tbAllType = self.tbAllType or { "C", "B", "A", "S", "SS", "SSS", };

	for _, szOtherType in pairs(self.tbAllType) do
		self.pPanel:SetActive(szOtherType, szOtherType == szType);
	end

	self.pPanel:PlayUiAnimation("MijingAccountPanle", false, false, {});
end

function tbUi:DoMakeFirend(szButtonName)
	local nIdx = string.match(szButtonName, "Friend(%d)");
	nIdx = tonumber(nIdx);

	RemoteServer.DoFubenClickMakeFriend(self.tbMember[nIdx].nPlayerId);
	FriendShip:RequetAddFriend(self.tbMember[nIdx].nPlayerId)
	self.pPanel:Button_SetEnabled(szButtonName, false);
	self.pPanel:Sprite_SetGray(szButtonName, true);
end

function tbUi:DoJoinKin(szButtonName)
	local nIdx = string.match(szButtonName, "Family(%d)");
	nIdx = tonumber(nIdx);

	local dwKinId = self.tbMember[nIdx].dwKinId;
	if dwKinId > 0 and me.dwKinId <= 0 then
		RemoteServer.OnKinRequest("Apply", dwKinId);
	elseif dwKinId <= 0 and me.dwKinId > 0 then
		Kin:Invite(self.tbMember[nIdx].nPlayerId);
	end
	self.pPanel:Button_SetEnabled(szButtonName, false);
	self.pPanel:Sprite_SetGray(szButtonName, true);
end

function tbUi:DoMissionAward()
	RemoteServer.ConfirmFubenMission();
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:GetGradePersent()
	local nType = MissionAward.emType_TeamFuben;
	local nGrade, szType, nNextLevelScroe, nCurLevelScroe = MissionAward:GetGrade(nType, self.nScroe);
	if nGrade == 1 then
		return szType, 1;
	end

	local tbGradeInfo = MissionAward.tbAllGradeInfo[nType];
	local nPresentPreGrade = 1 / (#tbGradeInfo - 1);
	local nTotalPersent = nPresentPreGrade * (#tbGradeInfo - nGrade) + nPresentPreGrade * (self.nScroe - nCurLevelScroe) / (nNextLevelScroe - nCurLevelScroe);
	return szType, nTotalPersent, nNextLevelScroe;
end

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_UPDATE_FUBEN_SCROE,	self.UpdateScroe,	self },
	};

	return tbRegEvent;
end

tbUi.tbOnClick = {};

tbUi.tbOnClick.BtnMissionAward = tbUi.DoMissionAward;

for i = 1, 3 do
	tbUi.tbOnClick["Friend" .. i] = tbUi.DoMakeFirend;
	tbUi.tbOnClick["Family" .. i] = tbUi.DoJoinKin;
end
