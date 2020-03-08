
local szWnd = "SituationalDialogue";
local tbDlg = Ui:CreateClass(szWnd);
local TouchMgr = luanet.import_type("TouchMgr");

tbDlg.TXT_NAME = "Name";
tbDlg.TXT_INFO = "Dialogue";

tbDlg.nTimeout = 90;

tbDlg.nNormalSpeed = 0.7;

tbDlg.tbTaskDialog = tbDlg.tbTaskDialog or {};
tbDlg.tbLookToNpcInfo = tbDlg.tbLookToNpcInfo or {};
tbDlg.tbErrTaskDialogId = tbDlg.tbErrTaskDialogId or {}; --防止重复读取无效的任务id
function tbDlg:GetTaskDialogInfo( nDialogId )
	local tbFindInfo = self.tbTaskDialog[nDialogId]
	if tbFindInfo then
		return tbFindInfo, self.tbLookToNpcInfo[nDialogId]
	end
	if self.tbErrTaskDialogId[nDialogId] then
		Log(debug.traceback(), nDialogId)
		return  {}, 0
	end
	local tbFile = LoadTabFile("Setting/Task/TaskDialog.tab", "dsddssssds", nil, {"nDialogId", "szDialogIndex", "nLookNpcTemplateId", "nNpcTemplateId", "szStoryBefore", "szStoryAfter", "szNpcSay", "szPlayerSay", "nSoundId", "szAction"});
	Log("Loading TaskDialog.tab",  nDialogId)
	local nFindDifferentIdCount = 0;
	local nFromRow;
	for nRow, tbRow in ipairs(tbFile) do
		local _nDialogId = tbRow.nDialogId;
		if _nDialogId == nDialogId then
			nFromRow = nRow
		end
		if nFromRow and nRow >= nFromRow then
			if not self.tbTaskDialog[_nDialogId] then
				if nFindDifferentIdCount >= 15 then
					break;
				end	
				nFindDifferentIdCount = nFindDifferentIdCount + 1;
				self.tbTaskDialog[_nDialogId] = {};
			end
			local tbInfo = {}
			if tbRow.szNpcSay ~= "" then
				tbInfo.szNpcSay       = tbRow.szNpcSay;
			else
				tbInfo.szPlayerSay    = tbRow.szPlayerSay;
			end

			if tbRow.nNpcTemplateId ~= 0 then
				tbInfo.nNpcTemplateId = tbRow.nNpcTemplateId;
			end

			if tbRow.nLookNpcTemplateId ~= 0 then
				self.tbLookToNpcInfo[_nDialogId] = tbRow.nLookNpcTemplateId;
			end

			if tbRow.szAction ~= "" then
				tbInfo.szAction = tbRow.szAction;
			end

			if not Lib:IsEmptyStr(tbRow.szStoryBefore) then
				tbInfo.szStoryBefore = tbRow.szStoryBefore
			end
			if not Lib:IsEmptyStr(tbRow.szStoryAfter) then
				tbInfo.szStoryAfter = tbRow.szStoryAfter
			end

			tbInfo.nSoundId = tbRow.nSoundId;
			table.insert(self.tbTaskDialog[_nDialogId], tbInfo);
		end
	end
	tbFindInfo = self.tbTaskDialog[nDialogId]
	if not tbFindInfo then
		self.tbErrTaskDialogId[nDialogId] = true
	end
	tbFindInfo = tbFindInfo or {}
	return tbFindInfo, self.tbLookToNpcInfo[nDialogId]
end

function tbDlg:CheckLookToNpc(nDialogId)
	local _, nLookNpcTemplateId self:GetTaskDialogInfo(nDialogId)
	if nLookNpcTemplateId and (not me.nLookNpcTemplateId or me.nLookNpcTemplateId ~= nLookNpcTemplateId) then
		local tbNpcList = KNpc.GetAroundNpcList(me.GetNpc(), Npc.DIALOG_DISTANCE * 2);
		local pShowNpc = nil;
		for _, pNpc in pairs(tbNpcList or {}) do
			if pNpc.nTemplateId == nLookNpcTemplateId then
				pShowNpc = pNpc;
				break;
			end
		end

		if pShowNpc then
			me.nLookNpcTemplateId = nLookNpcTemplateId;
			return pShowNpc.nId;
		end
	end
end

tbDlg.tbCloseUi = {
	"SkillPanel",
	"ItemBox",
	"WelfareActivity",
	"ViewRolePanel",
	"RankBoardPanel",
	"WaiyiPreview",
	"NewInformationPanel",
	"Partner",
	"EquipMakerPanel",
	"SkillPanel",
	"CommonShop",
};

function tbDlg:OnOpen(szType, ...)
	local szCheckFunc = "Check" .. szType
	if self[szCheckFunc] then
		local bOpen, tbParam = self[szCheckFunc](self, ...)
		if bOpen then
			local tbDialogInfo = self:GetTaskDialogInfo(self.nDialogId)
			local tbFirstContent = tbDialogInfo[1]
			Ui:OpenWindow("TaskStoryBlackPanel", nil, tbFirstContent.szStoryBefore, function ()
				Ui:OpenWindow(self.UI_NAME, szType, unpack(tbParam))
			end)
			return 0
		end
	end

	Ui:SetForbiddenOperation(false);

	self.nTimeoutId = Timer:Register(Env.GAME_FPS * self.nTimeout, function (self)
		self.nTimeoutId = nil;
		self:OnClick();
	end, self);

	if Sdk:IsPCVersion() then
		TouchMgr.SetJoyStick(false);
	end
end

function tbDlg:OnOpenEnd(szType, ...)
	UiNotify.OnNotify(UiNotify.emNOTIFY_SHOW_DIALOG, szType)
	Operation:SetJoyStickUp();

	me.StopDirection();
	if not Client:IsLowMemryDevice() then
		self.pPanel:NpcView_Open("PartnerView", me.nFaction, me.nSex);
		self.pPanel:NpcView_SetModePos("PartnerView", unpack(Npc.tbTaskDialogModelPos[0]));
	end
	self.nPos = 1;
	if not self[szType] then
		self:ShowNormalDialog(1);
		return;
	end

	for _, szUi in pairs(self.tbCloseUi) do
		if Ui:WindowVisible(szUi) then
			Ui:CloseWindow(szUi);
		end
	end

	Ui:SetAllUiVisable(false);

	self.szNpcName = "神秘人";
	self[szType](self, ...);
	self.tbDialogInfo = self:GetTaskDialogInfo(self.nDialogId)
	self:Update();
end

function tbDlg:CheckOpenStoryBlack()
	local tbDialogInfo = self:GetTaskDialogInfo(self.nDialogId)
	local tbFirstContent = tbDialogInfo[1] or {}
	return (not Lib:IsEmptyStr(tbFirstContent.szStoryBefore))
end

function tbDlg:CheckShowTaskDialog(nTaskId, nNpcId, nDialogId, nState, bSkip)
	self.nDialogId = nDialogId;
	if bSkip then
		return false
	end

	local bOpen = self:CheckOpenStoryBlack()
	local tbParam = {nTaskId, nNpcId, nDialogId, nState, true}
	return bOpen, tbParam
end

function tbDlg:ShowTaskDialog(nTaskId, nNpcId, nDialogId, nState)
	self.nTaskId   = nTaskId;
	self.nNpcId    = nNpcId;
	self.nState    = nState;

	local pNpc = KNpc.GetById(nNpcId);
	if pNpc then
		self.szNpcName = pNpc.szName;
	end
end

function tbDlg:CheckShowNormalDialog(nDialogId, tbCallBack, nNpcTemplateId, bSkip)
	self.nDialogId  = nDialogId or 1;
	if bSkip then
		return false
	end

	local bOpen = self:CheckOpenStoryBlack()
	local tbParam = {nDialogId, tbCallBack, nNpcTemplateId, true}
	return bOpen, tbParam
end

function tbDlg:ShowNormalDialog(nDialogId, tbCallBack, nNpcTemplateId)
	self.tbCallBack = tbCallBack;
	self.nNpcTemplateId = nNpcTemplateId
end

function tbDlg:OnClick()
	self.nPos = self.nPos + 1;
	self:Update();

	if self.nTimeoutId then
		Timer:Close(self.nTimeoutId);
	end

	self.nTimeoutId = Timer:Register(Env.GAME_FPS * self.nTimeout, function (self)
		self.nTimeoutId = nil;
		self:OnClick();
	end, self)
end

function tbDlg:OnScreenClick()
	self:OnClick();
end

function tbDlg:StopDialogueSound()
	if self.nSoundId and self.nSoundId > 0 then
		Ui:StopDialogueSound(self.nSoundId, 500);
	end
end

function tbDlg:GetNpcTemplateId()
	for _,v in ipairs(self.tbDialogInfo) do
		if v.nNpcTemplateId and v.nNpcTemplateId>0 then
			return v.nNpcTemplateId
		end
	end
	return 0
end

function tbDlg:Update()
	self.bCanSkip = true;
	local tbInfo = self.tbDialogInfo[self.nPos];
	if not tbInfo then
		self:DoFinishTaskDialog();
		return;
	end

	if tbInfo.nSoundId and tbInfo.nSoundId > 0 then
		self:StopDialogueSound()
		self.nSoundId = tbInfo.nSoundId;
		Ui:PlayDialogueSound(self.nSoundId)
	else
		if self.nPos==1 then
			local nNpcId = self:GetNpcTemplateId()
			if nNpcId > 0 then
				local nSoundId = Npc:GetRandomSound(nNpcId, me.nMapTemplateId)
				if nSoundId and nSoundId>0 then
					self:StopDialogueSound()
					self.nSoundId = nSoundId
					Ui:PlayDialogueSound(self.nSoundId)
				end
			end
		end
	end

	local szMsg = tbInfo.szNpcSay or tbInfo.szPlayerSay;
	szMsg = string.gsub(szMsg, "$N", me.szName);
	szMsg = string.gsub(szMsg, "$F", Faction:GetName(me.nFaction));

	local szZFTName = ZhenFaTask.szDialogPlayerName;
	if Lib:IsEmptyStr(szZFTName) then
		szZFTName = ZhenFaTask.szPlayerName or "";
	end
	szMsg = string.gsub(szMsg, "$ZFT", szZFTName);
	self.pPanel:Label_SetText("Dialogue", szMsg);
	self.pPanel:Label_SetText("Name", self:GetName(tbInfo));
	if not Client:IsLowMemryDevice() then
		self:SetFace(tbInfo);
	end
end

function tbDlg:GetName(tbInfo)
	if tbInfo.szNpcSay then
		local nNpcTId = self.nNpcTemplateId and tonumber(self.nNpcTemplateId)
		if nNpcTId then
			local szNpcName = KNpc.GetNameByTemplateId(nNpcTId);
			return szNpcName or "神秘人"
		end
		return KNpc.GetNameByTemplateId(tbInfo.nNpcTemplateId or 0) or self.szNpcName;
	end

	if me.dwID == 0 then
		return "我"
	else
		return me.szName;
	end
end

local tbFaceInfo =
{
	[0] = 300;
	[1] = 1121;
	[2] = 1122;
	[3] = 1123;
	[4] = 1124;
	[5] = 1125;
	[6] = 1126;
}

local tbModelInfo = {
	[1] = 
	{
		[Player.SEX_MALE] = {-70, -220, -350},
		[Player.SEX_FEMALE] = {-70, -120, -450},
	},
	[2] = 
	{
		[Player.SEX_MALE] = {-70, -210, -500},
		[Player.SEX_FEMALE] = {-70, -210, -500},
	},
	[3] = 
	{
		[Player.SEX_MALE] = {-70, -120, -450},
		[Player.SEX_FEMALE] = {-70, -120, -450},
	},
	[4] = 
	{
		[Player.SEX_MALE] = {-70, -210, -450},
		[Player.SEX_FEMALE] = {-70, -210, -450},
	},
	[5] = 
	{
		[Player.SEX_MALE] = {-70, -210, -450},
		[Player.SEX_FEMALE] = {-70, -210, -450},
	},
	[6] = 
	{
		[Player.SEX_MALE] = {-70, -210, -450},
		[Player.SEX_FEMALE] = {-70, -210, -500},
	},
	[7] = 
	{
		[Player.SEX_MALE] = {-70, -220, -350},
		[Player.SEX_FEMALE] = {-70, -220, -350},
	},
	[8] = 
	{
		[Player.SEX_MALE] = {-70, -210, -500},
		[Player.SEX_FEMALE] = {-70, -210, -500},
	},
	[9] = 
	{
		[Player.SEX_MALE] = {-70, -210, -450},
		[Player.SEX_FEMALE] = {-70, -210, -450},
	},
	[10] = 
	{
		[Player.SEX_MALE] = {-70, -220, -350},
		[Player.SEX_FEMALE] = {-70, -210, -500},
	},
	[11] = 
	{
		[Player.SEX_MALE] = {-70, -220, -350},
		[Player.SEX_FEMALE] = {-70, -120, -450},
	},
	[12] = 
	{
		[Player.SEX_MALE] = {-70, -120, -450},
		[Player.SEX_FEMALE] = {-70, -120, -450},
	},
	[13] = 
	{
		[Player.SEX_MALE] = {-70, -210, -450},
		[Player.SEX_FEMALE] = {-70, -210, -450},
	},
	[14] = 
	{
		[Player.SEX_MALE] = {-70, -210, -500},
		[Player.SEX_FEMALE] = {-70, -210, -500},
	},
	[15] = 
	{
		[Player.SEX_MALE] = {-70, -210, -450},
		[Player.SEX_FEMALE] = {-70, -210, -450},
	},
	[16] = 
	{
		[Player.SEX_MALE] = {-70, -220, -350},
		[Player.SEX_FEMALE] = {-70, -120, -450},
	},
	[17] = 
	{
		[Player.SEX_MALE] = {-70, -210, -450},
		[Player.SEX_FEMALE] = {-70, -210, -450},
	},
	[18] = 
	{
		[Player.SEX_MALE] = {-70, -210, -450},
		[Player.SEX_FEMALE] = {-70, -210, -450},
	},
	[19] = 
	{
		[Player.SEX_MALE] = {-70, -210, -450},
		[Player.SEX_FEMALE] = {-70, -120, -450},
	},
	[20] = 
	{
		[Player.SEX_MALE] = {-70, -210, -450},
		[Player.SEX_FEMALE] = {-70, -210, -450},
	},
	[21] = 
	{
		[Player.SEX_MALE] = {-70, -210, -450},
		[Player.SEX_FEMALE] = {-70, -210, -450},
	},
};

function tbDlg:ChangePlayerRes()
	local tbPos = tbModelInfo[me.nFaction][me.nSex] or Npc.tbTaskDialogModelPos[0];
	self.pPanel:NpcView_SetModePos("PartnerView", unpack(tbPos));

	self.pPanel:NpcView_ShowNpc("PartnerView", 0);
	local tbNpcRes, tbEffectRes = me.GetNpcResInfo();
	for nPartId, nResId in pairs(tbNpcRes) do
		local nCurResId = nResId
		if nPartId == Npc.NpcResPartsDef.npc_part_horse then
		    nCurResId = 0;
		end

		self.pPanel:NpcView_ChangePartRes("PartnerView", nPartId, nCurResId);
	end

	for nPartId, nResId in pairs(tbEffectRes) do
		self.pPanel:NpcView_ChangePartEffect("PartnerView", nPartId, nResId);
	end
	self.pPanel:NpcView_SetAnimationSpeed("PartnerView", 1);
end

function tbDlg:SetFace(tbInfo)
	self.pPanel:NpcView_ChangeDir("PartnerView", 180, false);
	self.szAction = tbInfo.szAction;
	if not tbInfo.szNpcSay then
		local szDefaultAtlas, szDefaultSpr = Npc:GetFace(tbFaceInfo[me.nFaction] or tbFaceInfo[0]);
		self.pPanel:SetActive("Face", false);
		self:ChangePlayerRes();
		return;
	end

	local tbNpcRes, tbEffectRes = me.GetNpcResInfo();
	for nPartId, nResId in pairs(tbNpcRes) do
		self.pPanel:NpcView_ChangePartRes("PartnerView", nPartId, 0);
	end

	for nPartId, nResId in pairs(tbEffectRes) do
		self.pPanel:NpcView_ChangePartEffect("PartnerView", nPartId, 0);
	end
	local nNpcTID = self.nNpcTemplateId and tonumber(self.nNpcTemplateId)
	local nNpcTemplateId = nNpcTID or tbInfo.nNpcTemplateId
	if nNpcTemplateId > 0 then
		local _, nResId = KNpc.GetNpcShowInfo(nNpcTemplateId);
		local tbPos = Npc.tbTaskDialogModelPos[nResId] or Npc.tbTaskDialogModelPos[0];
		self.pPanel:NpcView_SetModePos("PartnerView", unpack(tbPos));
		self.pPanel:NpcView_ShowNpc("PartnerView", nResId);
		self.pPanel:NpcView_SetAnimationSpeed("PartnerView", self.nNormalSpeed);
		self.pPanel:SetActive("Face", false);
		return;
	end

	self.pPanel:NpcView_ShowNpc("PartnerView", 0);
	self.pPanel:SetActive("Face", true);

	local nFaceId;
	if nNpcTemplateId then
		local nNorFace, _, nBigFaceId = KNpc.GetNpcShowInfo(nNpcTemplateId);
		nFaceId = nBigFaceId;
	end

	if not nFaceId or nFaceId <= 0 then
		nFaceId = 300;
	end

	local szAtlas, szSprite = Npc:GetFace(nFaceId);
	self.pPanel:Sprite_SetSprite("Face", szSprite or szDefaultSpr, szAtlas or szDefaultAtlas);
end

function tbDlg:DoFinishTaskDialog()
	self.pPanel:PlayUiAnimation("SituationalDialogueClose", false, false, {tostring(self.pPanel)})
end

function tbDlg:OnClose()
	self.bCanSkip = false;
	if Sdk:IsPCVersion() then
		TouchMgr.SetJoyStick(true);
	end
	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end

	if self.nTimeoutId then
		Timer:Close(self.nTimeoutId);
		self.nTimeoutId = nil;
	end

	if self.nToNormalSpeedTimerId then
		Timer:Close(self.nToNormalSpeedTimerId);
		self.nToNormalSpeedTimerId = nil;
	end

	Ui:SetAllUiVisable(true);

	self.pPanel:NpcView_Close("PartnerView");

	UiNotify.OnNotify(UiNotify.emNOTIFY_ON_CLOSE_DIALOG)

	if self.nSoundId and self.nSoundId > 0 then
		Ui:StopSceneSound(self.nSoundId, 2000);
	end
	self.nSoundId = nil;

	local tbDialogInfo = self:GetTaskDialogInfo(self.nDialogId)
	local tbFirstContent = tbDialogInfo[1] or {}
	if not Lib:IsEmptyStr(tbFirstContent.szStoryAfter) then
		Ui:OpenWindow("TaskStoryBlackPanel", nil, tbFirstContent.szStoryAfter)
	end
	self.nNpcTemplateId = nil
end

function tbDlg:Skip()
	if not self.bCanSkip then
		me.CenterMsg("操作太快啦，稍等一下哟~~");
		return;
	end

	self:DoFinishTaskDialog();
end

function tbDlg:OnAniEnd(szAniName)
	if szAniName == "SituationalDialogueClose" then
		Ui:CloseWindow(szWnd);
		if self.nTaskId then
			local tbTask = Task:GetTask(self.nTaskId);
			if tbTask and tbTask.nNeedConfirmFinish > 0 then
				Task:OpenConfirmPanel(self.nTaskId, self.nNpcId);
			else
				RemoteServer.OnFinishTaskDialog(self.nTaskId, self.nState, self.nNpcId);
			end

			self.nTaskId = nil;
		end

		if self.tbCallBack then
			local tbCallBack = self.tbCallBack;
			self.tbCallBack = nil;
			Lib:CallBack(tbCallBack);
		end
	end
end

function tbDlg:ControlsPlay()
	if not self.szAction then
		return;
	end

	if self.nTimerId then
		Timer:Close(self.nTimerId);
		self.nTimerId = nil;
	end

	if self.nToNormalSpeedTimerId then
		Timer:Close(self.nToNormalSpeedTimerId);
		self.nToNormalSpeedTimerId = nil;
	end

	self.pPanel:NpcView_PlayAnimation("PartnerView", self.szAction, 0.1, false);
	self.pPanel:NpcView_SetAnimationSpeed("PartnerView", 1);
	self.nTimerId = Timer:Register(5, function (self)
		self.pPanel:NpcView_PlayAnimation("PartnerView", "st", 1, true);
		self.nTimerId = nil;
	end, self);

	self.nToNormalSpeedTimerId = Timer:Register(Env.GAME_FPS + 5, function (self)
		self.pPanel:NpcView_SetAnimationSpeed("PartnerView", self.nNormalSpeed);
		self.nToNormalSpeedTimerId = nil;
	end, self);

	self.szAction = nil;
end

tbDlg.tbOnClick = {};
tbDlg.tbOnClick.BtnPanel = function (self)
	self:OnClick();
end

tbDlg.tbOnClick.BtnSkip = function (self)
	self:Skip();
end

tbDlg.tbOnDrag =
{
	PartnerView = function (self, szWnd, nX, nY)
		self.pPanel:NpcView_ChangeDir("PartnerView", -nX, true)
	end,
}

function tbDlg:RegisterEvent()
	return
	{
		{UiNotify.emNOTIFY_LOAD_RES_FINISH, self.ControlsPlay},
	};
end