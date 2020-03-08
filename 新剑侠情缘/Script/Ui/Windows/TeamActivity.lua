local tbUi = Ui:CreateClass("TeamActivity");

function tbUi:Init(szActivityType, subtype, szHelpType, nActivityId)
	local nActivityId = nActivityId;
	local tbActivitys = TeamMgr:GetActivityList();
	for _, tbActivity in pairs(tbActivitys) do
		if tbActivity.szType == szActivityType and tbActivity.subtype == subtype then
			nActivityId = tbActivity.nActivityId;
			break;
		end
	end

	self.nCurActivityId = nActivityId or TeamMgr:GetCurActivityId() or next(TeamMgr:GetMatchingActivityIds());

	self.pPanel:SetActive("TeamDetail", false);
	self:UpdateButtonStates();
	self:UpdateActivityList(true);

	if not Client:GetFlag("TeamGuid", -1) then
		Client:SetFlag("TeamGuid", true, -1);
		szHelpType = "Member";
	end

	self.pPanel:Label_SetText("MemberName1", Guide.ZHAOLIYING_NAME);
	self.pPanel:Label_SetText("MemberName6", Guide.ZHAOLIYING_NAME);
	self.pPanel:Label_SetText("LeaderName1", Guide.ZHAOLIYING_NAME);
	self.szHelpType = szHelpType;
	self.nHelpStep = 0;
	self:UpdateHelp();
end

local _tbHelp =
{
	Member =
	{
		{"HelpClicker", "MemberStep1"},
		{"HelpClicker", "MemberStep2"},
		{"HelpClicker", "MemberStep3"},
		{"HelpClicker", "MemberStep4"},
		{"HelpClicker", "MemberStep5"},
		{"HelpClicker", "MemberStep6"},
	},
	Leader =
	{
		{"HelpClicker", "LeaderStep1"},
		{"HelpClicker", "LeaderStep2"},
		{"HelpClicker", "LeaderStep3"},
		{"HelpClicker", "LeaderStep4"},
		{"HelpClicker", "LeaderStep5"},
		{"HelpClicker", "LeaderStep6"},
		{"HelpClicker", "LeaderStep7"},
	}
}
local tbHelp = {}
local tbAllHelpWnd = {}
for szHelpType, tbList in pairs(_tbHelp) do
	tbHelp[szHelpType] = {};
	for nSetpId, tbInfo in ipairs(tbList) do
		tbHelp[szHelpType][nSetpId] = {}
		for _, szWnd in ipairs(tbInfo) do
			tbHelp[szHelpType][nSetpId][szWnd] = true;
			tbAllHelpWnd[szWnd] = true;
		end
	end
end

function tbUi:UpdateHelp()
	self.nHelpStep = self.nHelpStep + 1;
	if tbHelp[self.szHelpType] and tbHelp[self.szHelpType][self.nHelpStep] then
		for szWnd, _ in pairs(tbAllHelpWnd) do
			self.pPanel:SetActive(szWnd, tbHelp[self.szHelpType][self.nHelpStep][szWnd])
		end
	else
		for szWnd, _ in pairs(tbAllHelpWnd) do
			self.pPanel:SetActive(szWnd, false);
		end
	end

	local tbUserSet = Ui:GetPlayerSetting();
	self.pPanel:Button_SetCheck("BtnVoice", tbUserSet.bMuteGuideVoice and true or false);
end

function tbUi:UpdateButtonStates()
	local nCurTarget = TeamMgr:GetCurActivityId();
	local bHasTeam = TeamMgr:HasTeam();
	self.pPanel:SetActive("BtnCreateTeam", not bHasTeam);
	self.pPanel:SetActive("BtnAdd2List", bHasTeam and self.nCurActivityId ~= nCurTarget);
	self.pPanel:SetActive("BtnEnterActivity", bHasTeam and self.nCurActivityId == nCurTarget);
	self.pPanel:SetActive("BtnAutomaticMatching", not bHasTeam and self.nCurActivityId);
	self.pPanel:SetActive("BtnQuite", bHasTeam);

	local bIsCaptain = TeamMgr:IsCaptain();
	self.pPanel:SetActive("BtnApplyList", bIsCaptain and bHasTeam);
	self.pPanel:SetActive("BtnInviteList", not bHasTeam);
	self.pPanel:SetActive("BtnNearTeam", not bHasTeam and not self.nCurActivityId)

	-- local nMatchingActivityId = TeamMgr:GetMatchingActivityId();
	-- if nMatchingActivityId == self.nCurActivityId then
	-- 	self.pPanel:Label_SetText("TxtAutomaticMatching", "退出匹配");
	-- else
		self.pPanel:Label_SetText("TxtAutomaticMatching", "匹配队伍");
	-- end

	if self.nCurActivityId == nCurTarget then
		self.pPanel:Button_SetText("BtnAdd2List", "退出目标");
	else
		self.pPanel:Button_SetText("BtnAdd2List", nCurTarget and "切换目标" or "加入目标");
	end
end

function tbUi:UpdateTeam(szInfo)
	if szInfo == "quite" or szInfo == "new" then
		self:UpdateActivityList(true);
		self.TeamDetail:Update();
	else
		self:UpdateButtonStates();
		self.TeamDetail:Update();
	end
end

function tbUi:UpdateActivity(szUpdateType, ...)
	if szUpdateType == "ActivityList" then
		self:UpdateActivityList(...);
	end

	if szUpdateType == "ActivityTeams" then
		self:UpdateActivityTeams(...);
	end

	if szUpdateType == "TargetId" then
		self.nCurActivityId = TeamMgr:GetCurActivityId() or self.nCurActivityId;
		self:UpdateActivityList(true);
	end
end

function tbUi:UpdateActivityTeams(nActivityId)
	if nActivityId ~= self.nCurActivityId then
		return;
	end

	if nActivityId == TeamMgr:GetCurActivityId() then
		self.pPanel:SetActive("TeamDetail", true);
		self.pPanel:SetActive("TeamsScrollView", false);
		self.pPanel:SetActive("NoTeam", false);
		self.TeamDetail:Update();
	else
		self.pPanel:SetActive("TeamsScrollView", true);
		self.pPanel:SetActive("TeamDetail", false);
		local tbItems = TeamMgr:GetActivityTeams(nActivityId);
		self.pPanel:SetActive("NoTeam", #tbItems == 0);

		local fnSetItem = function (itemObj, index)
			local tbItem = tbItems[index];
			tbItem.nActivityId = nActivityId;
			itemObj:Init(tbItem, self.szCurActivityName);
		end
		self.TeamsScrollView:Update(#tbItems, fnSetItem);
	end

	self:UpdateButtonStates();
end

function tbUi:UpdateActivityList(bTouchCurActivity)
	local fnOnSelect = function (buttonObj)
		self.nCurActivityId = buttonObj.tbItem.nActivityId;
		self:UpdateActivityTeams(self.nCurActivityId);

		local tbItems = TeamMgr:GetActivityTeams(self.nCurActivityId);
		if not next(tbItems) then
			TeamMgr:Ask4ActivityTeams(self.nCurActivityId);
		end
	end

	local fnSetItem = function(itemObj, tbNodeData, index)
		if tbNodeData.tbLeaves then
			local tbItem = tbNodeData.tbLeaves[1];
			itemObj.pPanel:SetActive("BaseClass", true);
			itemObj.pPanel:SetActive("SubClass", false);
			itemObj.BaseClass.pPanel:Label_SetText("LabelLight", TeamMgr.TEAM_ACTIVITY_NAME[tbItem.szType] or tbItem.szType);
			itemObj.pPanel:Label_SetText("LabelDark", TeamMgr.TEAM_ACTIVITY_NAME[tbItem.szType] or tbItem.szType);
			itemObj.pPanel:SetActive("Mark", false);
			itemObj.BaseClass.pPanel:SetActive("Triangle", true);

			if tbNodeData == self.ActivityTreeMenu:GetCurBaseNode() then
				Timer:Register(1, function ()
					itemObj.BaseClass.pPanel:Toggle_SetChecked("Main", true);
				end);
			else
				itemObj.BaseClass.pPanel:Toggle_SetChecked("Main", false);
			end
		else
			local tbItem = tbNodeData.tbData or tbNodeData;
			local bHasTeam = TeamMgr:HasTeam();
			local bIsCurActivity = (tbItem.nActivityId == TeamMgr:GetCurActivityId());
			local tbMatchingIds = TeamMgr:GetMatchingActivityIds();
			local bIsMatching = tbItem.nActivityId and tbMatchingIds[tbItem.nActivityId];
			itemObj.pPanel:SetActive("Mark", (bHasTeam and bIsCurActivity) or bIsMatching);
			if (bHasTeam and bIsCurActivity) or bIsMatching then
				itemObj.pPanel:Sprite_SetSprite("Mark", bIsCurActivity and "Mark_Target" or "Mark_Matching");
			end

			itemObj.pPanel:SetActive("BaseClass", tbNodeData.tbData and true or false);
			itemObj.BaseClass.pPanel:SetActive("Triangle", false);
			itemObj.pPanel:SetActive("SubClass", not tbNodeData.tbData);
			itemObj.BaseClass.pPanel:Label_SetText("LabelLight", tbItem.szName);
			itemObj.SubClass.pPanel:Label_SetText("LabelLight", tbItem.szName);
			itemObj.pPanel:Label_SetText("LabelDark", tbItem.szName);

			itemObj.BaseClass.tbItem = tbItem;
			itemObj.SubClass.tbItem = tbItem;
			itemObj.BaseClass.pPanel.OnTouchEvent = fnOnSelect;
			itemObj.SubClass.pPanel.OnTouchEvent = fnOnSelect;

			if tbItem.nActivityId == self.nCurActivityId or (not self.nCurActivityId and index == 1) then
				Timer:Register(1, function ()
					itemObj.SubClass.pPanel:Toggle_SetChecked("Main", true);
					itemObj.BaseClass.pPanel:Toggle_SetChecked("Main", true);
				end);

				if bTouchCurActivity then
					bTouchCurActivity = false;
					fnOnSelect(itemObj.SubClass);
				end
			else
				itemObj.BaseClass.pPanel:Toggle_SetChecked("Main", false);
				itemObj.SubClass.pPanel:Toggle_SetChecked("Main", false);
			end
		end
	end

	local tbTree = self:GetActivityTreeData();
	self.ActivityTreeMenu:SetTreeMenu(tbTree, fnSetItem, function ()
		self.nCurActivityId = nil;
	end);
	self:UpdateWldsInstructions()
end

--武林大事有单独的显示方式
function tbUi:UpdateWldsInstructions()
	local bCheck = WuLinDaShi:CheckCurActivityId()
	self.pPanel:SetActive("ActivityTreeMenu", not bCheck)
	self.pPanel:SetActive("BgWLDS", bCheck)
	if bCheck then
		local szTitle, szDesc = WuLinDaShi:GetInstructions4TeamPanel()
		self.pPanel:Label_SetText("BgWLDSTxt1", szTitle)
		self.pPanel:Label_SetText("BgWLDSTxt2", szDesc)
	end
end

tbUi.tbCheckShow = {
	["WuLinDaShiFuben"] = function ()
		return WuLinDaShi:CheckCurActivityId()
	end	
}
function tbUi:GetActivityTreeData()
	local tbTree = {};
	local tbItems = TeamMgr:GetActivityList();
	local tbActivityClass = {};

	if not TeamMgr:GetCurActivityId() then
		table.insert(tbTree, {tbData = {szName = "无目标"}});
	end

	for _, tbItem in ipairs(tbItems) do
		if not self.tbCheckShow[tbItem.szType] or self.tbCheckShow[tbItem.szType]() then
			if tbItem.szType == tbItem.subtype then
				table.insert(tbTree, {tbData = tbItem});
			else
				if not tbActivityClass[tbItem.szType] then
					tbActivityClass[tbItem.szType] = {
						tbLeaves = {};
					};
					table.insert(tbTree, tbActivityClass[tbItem.szType]);
				end
	
				if tbItem.nActivityId == self.nCurActivityId then
					tbActivityClass[tbItem.szType].bDown = true;
				end
				table.insert(tbActivityClass[tbItem.szType].tbLeaves, tbItem);
			end
		end
	end
	return tbTree;
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnCreateTeam()
	TeamMgr:CreateOnePersonTeam(self.nCurActivityId);
end

function tbUi.tbOnClick:BtnAutomaticMatching()
	Ui:SwitchWindow("TeamMatchPanel", self.nCurActivityId);
end

function tbUi.tbOnClick:BtnAdd2List()
	if not self.nCurActivityId then
		me.CenterMsg("请先选择队伍目标");
		return;
	end

	if self.nCurActivityId == TeamMgr:GetCurActivityId() then
		local szMsg = string.format("是否退出当前目标");
		me.MsgBox(szMsg, {{"确认", function ()
			TeamMgr:SetTeamActivity(nil);
		end}, {"取消"}});
		return;
	end

	if not TeamMgr:HasTeam() then
		local fnAgree = function ()
			TeamMgr:CreateOnePersonTeam(self.nCurActivityId);
			Ui:CloseWindow("MessageBox");
		end

		local fnCancel = function ()
			Ui:CloseWindow("MessageBox");
		end

		Ui:OpenWindow("MessageBox",
			"是否要创建队伍并加入队列",
			{{fnAgree}, {fnCancel}},
			{"确定", "取消"});
		return;
	end

	local fnAgree = function ()
		TeamMgr:SetTeamActivity(self.nCurActivityId);
	end

	local szCurActivityName = TeamMgr:GetCurActivityInfo();
	if not szCurActivityName then
		fnAgree();
		return;
	end


	local szTargetActivityName = TeamMgr:GetActivityInfo(self.nCurActivityId);
	local szMsg = string.format("确定将队伍目标切换为[FFFE0D]%s[-]？", szTargetActivityName);
	me.MsgBox(szMsg, {{"确认", fnAgree}, {"取消"}});
end

tbUi.tbTypeCustomFunc = {
	["WuLinDaShiFuben"] = function ()
		WuLinDaShi:ShowTip()
	end,
}
function tbUi.tbOnClick:BtnEnterActivity()
	local tbActivitys = TeamMgr:GetActivityList()
	for _, tbActivity in pairs(tbActivitys) do
		if tbActivity.nActivityId == self.nCurActivityId then
			local szFunc = self.tbTypeCustomFunc[tbActivity.szType]
			if szFunc then
				szFunc()
				return
			end
			break
		end
	end
	TeamMgr:EnterActivity();
end

function tbUi.tbOnClick:HelpClicker()
	self:UpdateHelp()
end

function tbUi.tbOnClick:BtnQuite()
	TeamMgr:Quite();
end

function tbUi.tbOnClick:BtnNearTeam()
	Ui:OpenWindow("NearbyTeamPanel")
end

function tbUi.tbOnClick:BtnApplyList()
	if not TeamMgr:IsCaptain() then
		me.CenterMsg("非队长无权操作");
		return false;
	end
	Ui:OpenWindow("TeamRequestQueue", "Apply");
end

function tbUi.tbOnClick:BtnInviteList()
	if TeamMgr:HasTeam() then
		me.CenterMsg("你可是已经有队伍的人咯");
		return false;
	end

	Ui:OpenWindow("TeamRequestQueue", "Invite");
end

function tbUi.tbOnClick:BtnVoice()
	ChatMgr:OnSwitchNpcGuideVoice();
end

---------------------------------TeamListItem------------------------------------

local tbTeamItem = Ui:CreateClass("TeamListItem");

function tbTeamItem:Init(tbTeamData)
	self.nTeamId = tbTeamData.nTeamId;
	self.nActivityId = tbTeamData.nActivityId;

	local szFactionIcon = Faction:GetIcon(tbTeamData.nFaction);
	local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbTeamData.nPortrait);
	self.pPanel:Sprite_SetSprite("SpFaction", szFactionIcon);
	self.pPanel:Sprite_SetSprite("SpRoleHead", szHead, szAtlas);

	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbTeamData.nHonorLevel)
	self.pPanel:SetActive("PlayerTitle", ImgPrefix and true);
	self.pPanel:Sprite_Animation("PlayerTitle", ImgPrefix or "", Atlas or "");
	self.pPanel:SetActive("TxtCaptainName", ImgPrefix and true);
	self.pPanel:SetActive("TxtCaptainNameNoTitle", not ImgPrefix);
	self.pPanel:Label_SetText("TxtCaptainName", tbTeamData.szCaptainName);
	self.pPanel:Label_SetText("TxtCaptainNameNoTitle", tbTeamData.szCaptainName);
	self.pPanel:Label_SetText("lbLevel", tbTeamData.nLevel);
	self.pPanel:Label_SetText("TxtMemberCounts", string.format("%d/4", tbTeamData.nCount));
	self.pPanel:ProgressBar_SetValue("Progress", tbTeamData.nCount/4);

	local bMyItem = self.nTeamId == TeamMgr:GetTeamId();
	self.pPanel:Sprite_SetSprite("Main", bMyItem and "BtnListThirdOwn" or "ListBarNormal");
end

tbTeamItem.tbOnClick = tbTeamItem.tbOnClick or {};

function tbTeamItem.tbOnClick:BtnApply()
	TeamMgr:ApplyActivityTeam(self.nActivityId, self.nTeamId);
end

-----------------------------------TeamActivityHelp------------------------------------------
local tbHelpUi = Ui:CreateClass("TeamActivityHelp");

function tbHelpUi:OnOpen()
end

tbHelpUi.tbOnClick = tbHelpUi.tbOnClick or {};

function tbHelpUi.tbOnClick:BtnMemberGuide()
	Ui:CloseWindow(self.UI_NAME)
	Ui:OpenWindow("TeamPanel", "TeamActivity", nil, nil, "Member");
end

function tbHelpUi.tbOnClick:BtnLeaderGuide()
	Ui:CloseWindow(self.UI_NAME)
	Ui:OpenWindow("TeamPanel", "TeamActivity", nil, nil, "Leader");
end

function tbHelpUi:OnScreenClick(szClickUi)
	Ui:CloseWindow(self.UI_NAME);
end
