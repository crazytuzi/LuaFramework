local tbUi = Ui:CreateClass("TeamDetail");

function tbUi:Init()
	self:Update();
end

function tbUi:Update()
	local _, nMinOpenMember, szCurTarget, _, bCanHelp = TeamMgr:GetCurActivityInfo();
	self.pPanel:Label_SetText("TxtCurTarget", szCurTarget or "无");
	self.pPanel:Label_SetText("TxtNeedPeople", nMinOpenMember or "无");

	local tbMembers = {};
	local bMyHelpState = TeamMgr:GetMyHelpState();
	local bHasTeam = TeamMgr:HasTeam();
	if bHasTeam then
		table.insert(tbMembers,
			{
				szName = me.szName,
				nLevel = me.nLevel,
				nPlayerID = me.dwID,
				nFaction = me.nFaction,
				nPortrait = me.nPortrait,
				nBigFace = PlayerPortrait:GetBigFaceId(me),
				nHonorLevel = me.nHonorLevel,
				nVipLevel = me.GetVipLevel(),
				nKinId = me.dwKinId,
				bHelp = bMyHelpState,
			});

		for _, tbData in ipairs(TeamMgr:GetTeamMember()) do
			table.insert(tbMembers, tbData);
		end
	end

	for i = 1, TeamMgr.MAX_MEMBER_COUNT do
		if bHasTeam then
			self.pPanel:SetActive("TeamMember" .. i, true);
			self["TeamMember" .. i]:Init(i, tbMembers[i], bCanHelp);
		else
			self.pPanel:SetActive("TeamMember" .. i, false);
		end
	end

	local nCurActivityId = TeamMgr:GetCurActivityId();
	local bIsCaptain = TeamMgr:IsCaptain();
	self.pPanel:SetActive("BtnAutoAgree", bIsCaptain);
	self.pPanel:Toggle_SetChecked("BtnAutoAgree", TeamMgr:IsAutoAgree());
	self.pPanel:SetActive("TeamMemberGroup", bHasTeam);
	self.pPanel:SetActive("Tip", not bHasTeam);
	self.pPanel:SetActive("BtnExitTarget", bHasTeam and nCurActivityId);
	self.pPanel:SetActive("BtnChatRecruit", bHasTeam and nCurActivityId);
	self.pPanel:SetActive("BtnHelp", bCanHelp or false);
	self.pPanel:Toggle_SetChecked("BtnHelp", bMyHelpState);

	if bCanHelp then
		self.pPanel:SetActive("BtnAutoAgree2", false);
		self.pPanel:SetActive("BtnAutoAgree", bIsCaptain);
		self.pPanel:Toggle_SetChecked("BtnAutoAgree", TeamMgr:IsAutoAgree());
	else
		self.pPanel:SetActive("BtnAutoAgree", false);
		self.pPanel:SetActive("BtnAutoAgree2", bIsCaptain);
		self.pPanel:Toggle_SetChecked("BtnAutoAgree2", TeamMgr:IsAutoAgree());
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnAutoAgree(szBtnName)
	local bIsCaptain = TeamMgr:IsCaptain();
	if not bIsCaptain then
		me.CenterMsg("你不是队长不可以进行设置哦");
		self.pPanel:Toggle_SetChecked(szBtnName, TeamMgr:IsAutoAgree());
		return;
	end

	local bChecked = self.pPanel:Toggle_GetChecked(szBtnName);
	TeamMgr:SetAutoAgree(bChecked);
end
tbUi.tbOnClick.BtnAutoAgree2 = tbUi.tbOnClick.BtnAutoAgree;

function tbUi.tbOnClick:BtnHelp()
	local bChecked = self.pPanel:Toggle_GetChecked("BtnHelp");
	TeamMgr:SetHelpState(bChecked);

	if bChecked then
		me.CenterMsg("进入协助状态，参与活动不消耗次数也无法获得奖励！", true);
	else
		me.CenterMsg("协助状态取消，参与活动将消耗次数并获得奖励！", true);
	end
end

function tbUi.tbOnClick:BtnChatRecruit()
	if not TeamMgr:HasTeam() then
		me.CenterMsg("然而你并没有队伍, 谈何招募");
		return;
	end

	if not TeamMgr:GetCurActivityId() then
		me.CenterMsg("请先加入一个目标");
		return;
	end

	Ui:OpenWindow("ChatLargePanel", Kin:HasKin() and ChatMgr.ChannelType.Kin or ChatMgr.ChannelType.Public, nil, "AddTeamLink");
end

function tbUi.tbOnClick:BtnExitTarget()
	TeamMgr:SetTeamActivity(nil);
end

local tbMemberUi = Ui:CreateClass("TeamDetailMember");

function tbMemberUi:Init(nIndex, tbMemberData, bCanHelp)
	self.nIndex = nIndex;
	self.pPanel:SetActive("BtnAdd", not tbMemberData);
	self.pPanel:SetActive("MemberInfo", tbMemberData and true);
	self.pPanel:SetActive("PitchOn", false);
	self.pPanel:SetActive("Help", bCanHelp and tbMemberData and tbMemberData.bHelp or false);
	self.pPanel.OnTouchEvent = nil;
	if not tbMemberData then
		return;
	end

	local tbHonorInfo = Player.tbHonorLevelSetting[tbMemberData.nHonorLevel];
	self.nPlayerId = tbMemberData.nPlayerID;
	self.szName = tbMemberData.szName;
	self.nKinId = tbMemberData.nKinId;

	self.pPanel:Label_SetText("TxtName", tbMemberData.szName);
	self.pPanel:SetActive("TxtName", tbHonorInfo and true);
	self.pPanel:Label_SetText("TxtNameNoHonor", tbMemberData.szName);
	self.pPanel:SetActive("TxtNameNoHonor", not tbHonorInfo);
	self.pPanel:Label_SetText("TxtLevel", tbMemberData.nLevel);
	self.pPanel:Label_SetText("TxtFactonName", Faction:GetName(tbMemberData.nFaction));
	self.pPanel:Sprite_SetSprite("TextureFaction", Faction:GetIcon(tbMemberData.nFaction));
	self.pPanel:SetActive("LeaderMark", TeamMgr:IsCaptain(tbMemberData.nPlayerID));

	local nTmpBigFace = PlayerPortrait:CheckBigFaceId(tbMemberData.nBigFace, tbMemberData.nPortrait, 
		tbMemberData.nFaction, tbMemberData.nSex);
	local szHead, szAtlas = PlayerPortrait:GetPortraitBigIcon(nTmpBigFace);
	self.pPanel:Sprite_SetSprite("TextureHead", szHead, szAtlas);

	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbMemberData.nHonorLevel)
	if ImgPrefix then
		self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix, Atlas);
	end

	local nVipLevel = tbMemberData.nVipLevel;
	local szVipTexture = tbHonorInfo and "VIP" or "VIP2"
	if not nVipLevel or  nVipLevel == 0 then
		self.pPanel:SetActive(szVipTexture, false)
	else
		self.pPanel:SetActive(szVipTexture, true)
		self.pPanel:Sprite_Animation(szVipTexture,  Recharge.VIP_SHOW_LEVEL[nVipLevel]);
	end

	self.pPanel:SetActive("BtnKickOut", TeamMgr:IsCaptain(me.dwID) and me.dwID ~= tbMemberData.nPlayerID);
end

tbMemberUi.tbOnClick = tbMemberUi.tbOnClick or {};

function tbMemberUi.tbOnClick:BtnAdd()
	if not TeamMgr:HasTeam() then
		local OnOk = function ()
			TeamMgr:CreateOnePersonTeam();
			Ui:OpenWindow("TeamPanel", "TeamActivity");
		end

		local OnCancel = function ()
			TeamMgr:CreateOnePersonTeam();
		end

		me.MsgBox("成功创建队伍，加入目标更容易找到志同道合的侠士哦，是否前往队伍活动[FFFE0D] 设置活动目标 [-]？", { {"前往", OnOk}, {"取消", OnCancel}});
		return;
	end

	Ui:OpenWindow("DungeonInviteList", "TeamInvite", function (nPlayerId)
		TeamMgr:Invite(nPlayerId);
	end);
end

function tbMemberUi.tbOnClick:TextureHead()
	if self.nPlayerId == me.dwID then
		return;
	end

	self.pPanel:SetActive("PitchOn", true);
	local tbPos = self.pPanel:GetRealPosition("Main");
	Ui:OpenWindowAtPos("RightPopup", tbPos.x - 90, tbPos.y - 110, "Team", {dwRoleId = self.nPlayerId, dwKinId = self.nKinId})
end

function tbMemberUi.tbOnClick:BtnKickOut()
	local fnConfirm = function ()
		TeamMgr:KickOutMember(self.nPlayerId);
	end
	me.MsgBox(string.format("是否将%s踢出队伍?", self.szName), {{"确定", fnConfirm}, {"取消"}});
end
