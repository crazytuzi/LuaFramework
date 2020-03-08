local tbUi = Ui:CreateClass("TeamRequestQueue");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_TEAM_UPDATE, self.TeamUpdate, self },
	};

	return tbRegEvent;
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

function tbUi.tbOnClick:BtnClose(tbGameObj)
	Ui:CloseWindow("TeamRequestQueue");
end

function tbUi.tbOnClick:BtnAllRefuse(tbGameObj)
	if TeamMgr:HasTeam() then
		TeamMgr:ClearApplyList();
	else
		TeamMgr:ClearInviteList();
	end
	Ui:CloseWindow("TeamRequestQueue");
end

function tbUi:TeamUpdate(szType)
	if szType == "new" then
		Ui:CloseWindow("TeamRequestQueue");
	end
end

function tbUi:OnOpen(szType)
	Ui:ClearRedPointNotify("TeamBtnNew");
	self.bInvitView = (szType == "Invite");
	self.pPanel:SetActive("ScrollViewInvite", self.bInvitView);
	self.pPanel:SetActive("ScrollViewApply", not self.bInvitView);
	self.pPanel:Label_SetText("Title", self.bInvitView and "邀请组队列表" or "申请组队列表")

	if self.bInvitView then
		self:UpdateInviteList();
	else
		self:UpdateApplyList();
	end
end

function tbUi:UpdateApplyList()
	local tbItemData = TeamMgr:GetApplyList();

	local fnSetItem = function(itemObj, index)
		local data = tbItemData[index];
		itemObj:Init(data);
		itemObj.ScrollView = self.ScrollViewApply;
	end

	self.ScrollViewApply:Update(tbItemData, fnSetItem);
end

function tbUi:UpdateInviteList()
	local tbItemData = TeamMgr:GetInviteList();
	local fnSetItem = function(itemObj, index)
		local data = tbItemData[index];
		itemObj:Init(data);
		itemObj.ScrollView = self.ScrollViewInvite;
	end

	self.ScrollViewInvite:Update(tbItemData, fnSetItem);
	Ui:ClearRedPointNotify("TeamNewInvitor");
end

local tbItem = Ui:CreateClass("TeamRequestItem");

function tbItem:Init(tbData)
	self.tbData = tbData;
	self.pPanel:Label_SetText("lbLevel", tbData.nLevel);
	self.pPanel:Sprite_SetSprite("SpFaction", Faction:GetIcon(tbData.nFaction));

	local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbData.nPortrait);
	self.pPanel:Sprite_SetSprite("SpRoleHead", szHead, szAtlas);

	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbData.nHonorLevel)
	if ImgPrefix then
		self.pPanel:SetActive("Title", true);
		self.pPanel:SetActive("TxtRoleName", true);
		self.pPanel:SetActive("TxtRoleName2", false);
		self.pPanel:Sprite_Animation("Title", ImgPrefix, Atlas);
		self.pPanel:Label_SetText("TxtRoleName", tbData.szName);
	else
		self.pPanel:SetActive("TxtRoleName", false);
		self.pPanel:SetActive("TxtRoleName2", true);
		self.pPanel:SetActive("Title", false);
		self.pPanel:Label_SetText("TxtRoleName2", tbData.szName);
	end

	local szKinName = tbData.szKinName
	self.pPanel:Label_SetText("TxtKinName", string.format("家族：%s", szKinName=="" and "无" or szKinName))
end

tbItem.tbOnClick = {};

function tbItem.tbOnClick:BtnAgree()
	TeamMgr:AgreeAppler(self.tbData.nID, true);
	self.ScrollView.pPanel:UpdateScrollView(#TeamMgr:GetApplyList());
end

function tbItem.tbOnClick:BtnRefuse()
	TeamMgr:AgreeAppler(self.tbData.nID, false);
	self.ScrollView.pPanel:UpdateScrollView(#TeamMgr:GetApplyList());
end

function tbItem.tbOnClick:TeammateHead()
	local tbPos = self.pPanel:GetRealPosition("Main");
	Ui:OpenWindowAtPos("RightPopup", tbPos.x + 70, -180, "TeamPop", {dwRoleId = self.tbData.nID, szName = self.tbData.szName});
end


local tbInviteItem = Ui:CreateClass("TeamInviteItem");

function tbInviteItem:Init(tbData)
	self.tbData = tbData;

	self.pPanel:Label_SetText("lbLevel", tbData.nLevel);
	self.pPanel:Sprite_SetSprite("SpFaction", Faction:GetIcon(tbData.nFaction));

	local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbData.nPortrait);
	self.pPanel:Sprite_SetSprite("SpRoleHead", szHead, szAtlas);

	local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbData.nHonorLevel)
	if ImgPrefix then
		self.pPanel:SetActive("Title", true);
		self.pPanel:SetActive("TxtRoleName", true);
		self.pPanel:SetActive("TxtRoleName2", false);
		self.pPanel:Sprite_Animation("Title", ImgPrefix, Atlas);
		self.pPanel:Label_SetText("TxtRoleName", tbData.szName);
	else
		self.pPanel:SetActive("TxtRoleName", false);
		self.pPanel:SetActive("TxtRoleName2", true);
		self.pPanel:SetActive("Title", false);
		self.pPanel:Label_SetText("TxtRoleName2", tbData.szName);
	end


	self.pPanel:Label_SetText("TeamTarget", tbData.szTarget or "暂无");
end

tbInviteItem.tbOnClick = tbInviteItem.tbOnClick or {};

function tbInviteItem.tbOnClick:BtnAgree()
	TeamMgr:InviteRespond(self.tbData.nTeamId, true);
	self.ScrollView.pPanel:UpdateScrollView(#TeamMgr:GetInviteList());
end

function tbInviteItem.tbOnClick:BtnRefuse()
	TeamMgr:InviteRespond(self.tbData.nTeamId, false);
	self.ScrollView.pPanel:UpdateScrollView(#TeamMgr:GetInviteList());
end

function tbInviteItem.tbOnClick:TeammateHead()
	local tbPos = self.pPanel:GetRealPosition("Main");
	Ui:OpenWindowAtPos("RightPopup", tbPos.x + 70, -180, "TeamPop", {dwRoleId = self.tbData.nPlayerId, szName = self.tbData.szName});
end
