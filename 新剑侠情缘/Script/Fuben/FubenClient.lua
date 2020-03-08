function Fuben:ClearClientData()
	me.tbFubenInfo = {};
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE);
end

function Fuben:SetTargetPos(nX, nY)
	me.tbFubenInfo = me.tbFubenInfo or {};
	me.tbFubenInfo.tbTargetPos = {nX, nY};
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE);
end

function Fuben:SetTargetInfo(szInfo, nTime)
	me.tbFubenInfo = me.tbFubenInfo or {};
	me.tbFubenInfo.tbTargetInfo = {szInfo, nTime};
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE);
end

function Fuben:SetFubenProgress(nProgress, szInfo)
	me.tbFubenInfo = me.tbFubenInfo or {};
	me.tbFubenInfo.tbProgress = {nProgress, szInfo};
	UiNotify.OnNotify(UiNotify.emNoTIFY_FUBEN_PROGRESS_REFRESH);
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE);
end

function Fuben:SetScoro(nScore)
	me.tbFubenInfo = me.tbFubenInfo or {};
	me.tbFubenInfo.nScore = nScore;
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE);
end

function Fuben:SetScoreTxtInfo( szScoreLine1, szScoreLine2 )
	me.tbFubenInfo = me.tbFubenInfo or {};
	me.tbFubenInfo.szScoreLine1 = szScoreLine1
	me.tbFubenInfo.szScoreLine2 = szScoreLine2
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE);
end

function Fuben:SetScoreTimerInfo( szScoreTime, nScoreEndTime )
	me.tbFubenInfo = me.tbFubenInfo or {};
	me.tbFubenInfo.szScoreTime = szScoreTime
	me.tbFubenInfo.nScoreEndTime = nScoreEndTime
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE);
end

function Fuben:SetEndTime(nEndTime, szTimeTitle)
	me.tbFubenInfo = me.tbFubenInfo or {};
	me.tbFubenInfo.nEndTime = nEndTime;
	me.tbFubenInfo.szTimeTitle = szTimeTitle
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE);
end

function Fuben:StopEndTime()
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_STOP_ENDTIME);
end

function Fuben:SetShowInfo(nItemCount, nCoinCount)
	me.tbFubenInfo = me.tbFubenInfo or {};
	me.tbFubenInfo.tbShowInfo = {nItemCount, nCoinCount};
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE);
end

function Fuben:ShowLeave()
	me.tbFubenInfo = me.tbFubenInfo or {};
	me.tbFubenInfo.bCanLeave = true;
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE);
end

function Fuben:ShowHelp(szHelpKey)
	me.tbFubenInfo = me.tbFubenInfo or {};
	me.tbFubenInfo.szHelpKey = szHelpKey;
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE);
end

function Fuben:CloseLeave()
	me.tbFubenInfo = me.tbFubenInfo or {};
	me.tbFubenInfo.bCanLeave = false;
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE);
end

function Fuben:HideLeave()
	self:CloseLeave()
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE_CLOSE);
end

function Fuben:GetTargetPos()
	me.tbFubenInfo = me.tbFubenInfo or {};
	local tbInfo = me.tbFubenInfo.tbTargetPos or {};
	return tbInfo[1], tbInfo[2];
end

function Fuben:HideInviteButton()
	if Ui:WindowVisible("HomeScreenFuben") == 1 then
		Ui("HomeScreenFuben"):HideInviteButton();
	end
end

function Fuben:SetOpenUiAfterDialog(szUi, ...)
	self.szWaitOpenUi = szUi
	self.tbParam = {...}
	UiNotify:RegistNotify(UiNotify.emNOTIFY_ON_CLOSE_DIALOG, self.OnDialogCloseOpenUi, self)
end

function Fuben:OnDialogCloseOpenUi()
	if self.szWaitOpenUi then
		Ui:OpenWindow(self.szWaitOpenUi, unpack(self.tbParam))
		self.szWaitOpenUi = nil;
		self.tbParam = nil
	end
	UiNotify:UnRegistNotify(UiNotify.emNOTIFY_ON_CLOSE_DIALOG, self)
end

function Fuben:OnGetStarAward(nSectionIdx, nFubenLevel, nIndex)
	UiNotify.OnNotify(UiNotify.emNOTIFY_GET_STAR_AWARD, nSectionIdx, nFubenLevel, nIndex);
end

function Fuben:OnFinishPersonalFuben(nSectionIdx, nSubSectionIdx, nFubenLevel)
	UiNotify.OnNotify(UiNotify.emNOTIFY_FINISH_PERSONALFUBEN, nSectionIdx, nSubSectionIdx, nFubenLevel);
end

function Fuben:OnUpdateMissionScroe(nScroe)
	UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_FUBEN_SCROE, nScroe);
end

function Fuben:OpenGuide(tbIns, szDescType, szDesc, szUiName, szWnd, tbPointer, bDisableClick, bBlackBg, bDisableVoice)
	if Ui:WindowVisible(szUiName) ~= 1 then
		Log("Error Guide:FubenOpenGuide", szUiName, szWnd);
		return;
	end

	local tbWin = Ui(szUiName);
    Ui:OpenWindow("Guide", szDescType, szDesc, tbWin.pPanel, szWnd, tbPointer, bDisableClick, bBlackBg, bDisableVoice);
    tbIns.nGuideClick = Guide:SetCheckClickWnd(tbWin.pPanel, szWnd);
end

function Fuben:OnGuideClick(nClickKey)
    for _, tbIns in pairs(self.tbFubenInstance) do
		if tbIns.nGuideClick and tbIns.nGuideClick == nClickKey then
			local nLockId = tbIns.nGuideLockId;
			tbIns.nGuideClick = nil;
			tbIns.nGuideLockId = nil;
			if nLockId then
				tbIns:UnLock(nLockId);
			end

			Ui:CloseWindow("Guide");
		end
	end
end

--bTaskFuben:是否为任务副本，任务副本需要有介绍ui
function Fuben:JoinPersonalFuben(nSectionIdx, nSubSectionIdx, nFubenLevel, tbHelperInfo, bTaskFuben, bHadLeftTeam, bConfirm)
	if not bHadLeftTeam and TeamMgr:HasTeam() then
		Ui:OpenWindow("MessageBox", "组队状态无法进入关卡，是否退出当前队伍？",
	 		{{function ()
	 			RemoteServer.OnTeamRequest("Quite")
				self:JoinPersonalFuben(nSectionIdx, nSubSectionIdx, nFubenLevel, tbHelperInfo, bTaskFuben, true)
				return true
			end},{}},
	 		{"退出并进入", "取消"});
		return;
	end

	if not bConfirm and me.nFightMode == 0 then
		local tbAllPartner = me.GetAllPartner();
		local tbAll = {};
		for _, tbPartner in pairs(tbAllPartner) do
			tbAll[tbPartner.nTemplateId] = true;
		end

		local tbPos = me.GetPartnerPosInfo();
		local bHasFreePos = false;
		for i = 1, 4 do
			if me.nLevel >= Partner.tbPosNeedLevel[i] then
				local nPartnerId = tbPos[i];
				if not nPartnerId or nPartnerId <= 0 then
					bHasFreePos = true;
				else
					local nPosTemplateId = tbAllPartner[nPartnerId].nTemplateId;
					tbAll[nPosTemplateId] = nil;
				end
			end
		end

		if bHasFreePos and next(tbAll) then
			me.MsgBox("少侠，一人行走江湖十分凶险，最好与同伴共同闯荡，是否去将未上阵的同伴上阵呢？", {
								{
									"上阵同伴", function ()
													Ui:OpenWindow("Partner");
												end,
									bLight = true,
								},
							});
			return;
		end
	end

	if bHadLeftTeam then
		Ui:CloseWindow("MessageBox")
	end

	if bTaskFuben then
		local nFubenIndex = PersonalFuben:GetFubenIndex(nSectionIdx, nSubSectionIdx, nFubenLevel)
		local tbFubenInfo = PersonalFuben:GetPersonalFubenInfo(nFubenIndex)
		Ui:OpenWindow("TaskStoryBlackPanel", tbFubenInfo.szFubenTitle, tbFubenInfo.szDesc, function ()
			RemoteServer.TryCreatePersonalFuben(nSectionIdx, nSubSectionIdx, nFubenLevel, tbHelperInfo);
		end, true)
	else
		RemoteServer.TryCreatePersonalFuben(nSectionIdx, nSubSectionIdx, nFubenLevel, tbHelperInfo);
	end
end

function Fuben:DoCommonAct(tbNpc, nActId, nActEventId, bLoop, nFrame)
	for _, nNpcId in pairs(tbNpc) do
		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			pNpc.DoCommonAct(nActId, nActEventId, bLoop, nFrame);
		end
	end
end

function Fuben:DoPlayerCommonAct(nActId, nActEventId, bLoop, nFrame)
	local pNpc = me.GetNpc();
	if not pNpc then
		return;
	end
	pNpc.DoCommonAct(nActId, nActEventId, bLoop, nFrame);
end

function Fuben:OnSyncCacheCmd(nMapId, tbCmd)
	Timer:Register(Env.GAME_FPS, function ()
		if me.nMapId == nMapId then
			for _, tbCmd in ipairs(tbCmd) do
				me.CallClientScript(unpack(tbCmd));
			end
		end
	end);
end

function Fuben:SetBtnCandy(bShowCandy)
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE_WEDDING_BTN, "BtnCandy", bShowCandy);
end

function Fuben:SetBtnBless(bShowBless)
	UiNotify.OnNotify(UiNotify.emNOTIFY_FUBEN_TARGET_CHANGE_WEDDING_BTN, "BtnBlessing", bShowBless);
end
