Require("Script/Ui/Logic/Notify.lua");
Require("CommonScript/Task/TaskCommon.lua");

Task.tbMainTaskDesInfo = {};
function Task:InitMainTaskDes()
	local tbFile = LoadTabFile("Setting/Task/MainTaskInfo.tab", "dss", nil, {"nIndex", "szTitle", "szDesc"});
	for _, tbInfo in pairs(tbFile) do
		Task.tbMainTaskDesInfo[tbInfo.nIndex] = tbInfo;
	end
end
Task:InitMainTaskDes();

Task.tbClientNpcInfo = {};
function Task:LoadClientNpc()
	local tbFile = LoadTabFile("Setting/Task/TaskClientNpc.tab", "ddddddsddss", nil, {"nShowId", "nNpcId", "nMapTemplateId", "nX", "nY", "nDir", "Trap", "bIsTaskNpc", "bIsFollow", "szStartFunc", "szStartParam"});
	for _, tbRow in pairs(tbFile) do
		Task.tbClientNpcInfo[tbRow.nShowId] = Task.tbClientNpcInfo[tbRow.nShowId] or {};
		tbRow.szIdx = string.format("%s_%s_%s_%s", tbRow.nNpcId, tbRow.nMapTemplateId, tbRow.nX, tbRow.nY);
		table.insert(Task.tbClientNpcInfo[tbRow.nShowId], tbRow);
	end
end
Task:LoadClientNpc();

function Task:OnEnter(nMapTemplateId)
	self:CheckTaskNotSyncNpc(nMapTemplateId);
end

function Task:CheckTaskNotSyncNpc(nMapTemplateId, nTaskId)
	if not self.tbNpcNotSyncInfo or not self.tbNpcNotSyncInfo[nMapTemplateId] then
		self.tbNpcNotSyncInfo = self.tbNpcNotSyncInfo or {};
		self.tbNpcNotSyncInfo[nMapTemplateId] = self.tbNpcNotSyncInfo[nMapTemplateId] or {};

		local tbMapInfo = Map:GetMapNpcInfo(nMapTemplateId);
		if tbMapInfo then
			for _, tbInfo in pairs(tbMapInfo) do
				if tbInfo.HideTaskId > 0 then
					table.insert(self.tbNpcNotSyncInfo[nMapTemplateId], tbInfo);
				end
			end
		end
	end

	if #self.tbNpcNotSyncInfo[nMapTemplateId] <= 0 then
		return;
	end

	local tbNotSyncInfo = {};
	for _, tbInfo in pairs(self.tbNpcNotSyncInfo[nMapTemplateId]) do
		if Task:GetTaskFlag(me, tbInfo.HideTaskId) ~= 1 then
			table.insert(tbNotSyncInfo, {nMapTemplateId, tbInfo.NpcTemplateId, tbInfo.XPos, tbInfo.YPos});
		elseif nTaskId and nTaskId > 0 and tbInfo.HideTaskId == nTaskId then
			RemoteServer.RequestSyncNpc(tbInfo.NpcTemplateId);
		end
	end

	KNpc.SetNotSyncNpc(tbNotSyncInfo);
end

function Task:OnMapLoaded()
	self:UpdateClientNpc();
end

function Task:CheckClientNpc()
	self.tbClientNpcInfo = self.tbClientNpcInfo or {};
	if not self.tbClientNpcInfo or not self.tbClientNpcInfo.nMapTemplateId or self.tbClientNpcInfo.nMapTemplateId ~= me.nMapTemplateId then
		self.tbClientNpcInfo.nMapTemplateId = me.nMapTemplateId;
		self.tbClientNpcInfo.tbTrapInfo = {};
		self.tbClientNpcInfo.tbCurClinetNpc = {};
	end
end

function Task:UpdateClientNpc(szTrap)
	self:CheckClientNpc();

	szTrap = szTrap or "";

	self.tbClientNpcInfo.tbTrapInfo = self.tbClientNpcInfo.tbTrapInfo or {};
	self.tbClientNpcInfo.tbCurClinetNpc = self.tbClientNpcInfo.tbCurClinetNpc or {};

	local tbCurNpcInfo = self.tbClientNpcInfo.tbCurClinetNpc;
	if szTrap ~= "" then
		local tbCurTrapInfo = self.tbClientNpcInfo.tbTrapInfo;
		if tbCurTrapInfo and tbCurTrapInfo[me.nMapTemplateId] and tbCurTrapInfo[me.nMapTemplateId][szTrap] then
			return;
		end

		tbCurTrapInfo[me.nMapTemplateId] = tbCurTrapInfo[me.nMapTemplateId] or {};
		tbCurTrapInfo[me.nMapTemplateId][szTrap] = true;
	end

	local tbPlayerTask = self:GetPlayerTaskInfo(me);
	local tbTaskIdInfo = {};
	local tbShowIdx = {};
	for nIdx, tbTaskInfo in pairs(tbPlayerTask.tbCurTaskInfo) do
		local tbTask = Task:GetTask(tbTaskInfo.nTaskId);
		if not tbTask then
			Log(string.format("[Task] ERR!!!! nTaskId = %d is nil !!!", tbTaskInfo.nTaskId));
		else
			for _, nShowId in pairs(tbTask.tbShowClientNpc or {}) do
				tbShowIdx[nShowId] = tbTaskInfo.nTaskId;
			end
		end
	end

	local tbCurNpc = {};
	for _, tbInfo in pairs(tbCurNpcInfo) do
		for _, nNpcId in pairs(tbInfo) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc and pNpc.szIdx then
				tbCurNpc[pNpc.szIdx] = pNpc;
			end
		end
	end

	for nShowId, nTaskId in pairs(tbShowIdx) do
		local tbShowNpcInfo = self.tbClientNpcInfo[nShowId] or {}

		for _, tbNpcInfo in pairs(tbShowNpcInfo) do
			local pNpc = tbCurNpc[tbNpcInfo.szIdx];
			if tbNpcInfo.nMapTemplateId == me.nMapTemplateId and tbNpcInfo.Trap == szTrap and not pNpc then
				pNpc = KNpc.Add(tbNpcInfo.nNpcId, 10, 0, 0, tbNpcInfo.nX, tbNpcInfo.nY, 0, tbNpcInfo.nDir);
				pNpc.szIdx = tbNpcInfo.szIdx;
				tbCurNpcInfo[nShowId] = tbCurNpcInfo[nShowId] or {};
				table.insert(tbCurNpcInfo[nShowId], pNpc.nId);
				pNpc.SetProtected(1);

			end

			if pNpc then
				if tbNpcInfo.bIsFollow == 1 then
					pNpc.AI_SetFollowNpc(me.GetNpc().nId);
				end
				pNpc.nTaskId = nTaskId;
				pNpc.bIsTaskNpc = tbNpcInfo.bIsTaskNpc;
				self:UpdateClientTaskState(pNpc);
				tbCurNpc[tbNpcInfo.szIdx] = nil;
				local fnStartAction = self.tbClientNpcFunc[tbNpcInfo.szStartFunc];

				if fnStartAction and (GetTime() - (pNpc.nActionTime or 0)) > 10 then
					fnStartAction(self.tbClientNpcFunc, pNpc, tbNpcInfo.szStartParam);
					pNpc.nActionTime = GetTime();
				end
			end
		end
	end

	for _, pNpc in pairs(tbCurNpc) do
		pNpc.nTaskId = nil;
		pNpc.bIsTaskNpc = nil;
		self:UpdateClientTaskState(pNpc);
	end
end

function Task:DeleteClientNpc(nTaskId)
	local tbTask = Task:GetTask(nTaskId);
	local tbDeleteClientNpc = tbTask.tbDeleteClientNpc;

	self.tbClientNpcInfo.tbCurClinetNpc = self.tbClientNpcInfo.tbCurClinetNpc or {};
	for _, nDeleteShowId in pairs(tbDeleteClientNpc or {}) do
		for _, nNpcId in pairs(self.tbClientNpcInfo.tbCurClinetNpc[nDeleteShowId] or {}) do
			local pNpc = KNpc.GetById(nNpcId);
			if pNpc then
				pNpc.Delete();
			end
		end

		self.tbClientNpcInfo.tbCurClinetNpc[nDeleteShowId] = nil;
	end
end

function Task:UpdateClientTaskState(pNpc)
	if not pNpc or pNpc.szClass ~= "ClientTaskNpc" then
		return;
	end

	local nTaskState = Task.STATE_NONE;
	if pNpc.nTaskId and pNpc.bIsTaskNpc and pNpc.bIsTaskNpc == 1 then
		nTaskState = Task:GetTaskState(me, pNpc.nTaskId, me.GetNpc().nId);
	end

	Task:SetNpcTaskState(pNpc, nTaskState);
end

function Task:OnPlayerTrap(nMapTemplateId, szTrapName)
	self:UpdateClientNpc(szTrapName);

	local bRet, szTrack = Task:GetTaskTrapTrack(me, nMapTemplateId, szTrapName);
	if szTrack and szTrack ~= "" then
		Ui.HyperTextHandle:Handle(szTrack, 0, 0);
	end
end

function Task:SyncTaskData(tbData)
	local tbPlayerTask = self:GetPlayerTaskInfo(me);
	for k, v in pairs(tbData) do
		tbPlayerTask[k] = v;
	end

	self:UpdateNpcTaskState();
	self:UpdateTracingList()
end

function Task:SyncOneTask(tbCurTask)
	local tbPlayerTask = self:GetPlayerTaskInfo(me);
	for nIdx, tbTaskInfo in pairs(tbPlayerTask.tbCurTaskInfo) do
		if tbTaskInfo.nTaskId == tbCurTask.nTaskId then
			tbPlayerTask.tbCurTaskInfo[nIdx] = tbCurTask;
			break;
		end
	end

	self:UpdateNpcTaskState();

	self:OnTaskHasChange(tbCurTask.nTaskId);
end

function Task:OnTaskHasChange(nTaskId)
	self:OnTaskUpdate(nTaskId)
	UiNotify.OnNotify(UiNotify.emNOTIFY_TASK_HAS_CHANGE, nTaskId);
end

function Task:SetNpcTaskState(pNpc, nState)
	self:ClearNpcTaskState(pNpc);

	local nCommerceTaskState = CommerceTask:GetHeadTip(pNpc)
	nState = math.max(nCommerceTaskState, nState)
	local tbSkill = {[Task.STATE_ON_DING] = 1003, [Task.STATE_CAN_FINISH] = 1006, [Task.STATE_CAN_ACCEPT] = 1001}
	if tbSkill[nState] then
		pNpc.AddSkillState(tbSkill[nState], 1, 0, 100000);
	end
end

function Task:ClearNpcTaskState(pNpc)
	pNpc.RemoveSkillState(1001);
	pNpc.RemoveSkillState(1003);
	pNpc.RemoveSkillState(1006);
end

function Task:GetNpcTaskStateId(pNpc)
	local tbAllTask = self:GetTaskByNpcTemplateId(pNpc.nTemplateId);
	local nStateSkillId = 0;
	local nCurState = Task.STATE_NONE;

	for _, nTaskId in pairs(tbAllTask or {}) do
		local tbTask = self:GetTask(nTaskId);
		local nState = self:GetTaskState(me, nTaskId, pNpc.nId);
		if (nState == self.STATE_CAN_ACCEPT and tbTask.nAcceptTaskNpcId == pNpc.nTemplateId) or nState ~= self.STATE_CAN_ACCEPT then
			nCurState = math.max(nState, nCurState);
		end
	end

	return nCurState;
end

function Task:UpdateOneNpcTaskState(pNpc)
	local nState = self:GetNpcTaskStateId(pNpc);
	self:SetNpcTaskState(pNpc, nState);
end

function Task:UpdateNpcTaskState()
	local tbNpcList = KNpc.GetNpcListInCurrentMap();
	for _, pNpc in pairs(tbNpcList) do
		self:UpdateOneNpcTaskState(pNpc);
	end

	Task:UpdateClientNpc();
end

function Task:UpdateTaskInfo(nTaskId)
	local tbTask = self:GetTask(nTaskId);
	if not tbTask then
		return;
	end

	self:OnTaskUpdate(nTaskId);
	self:UpdateNpcTaskState();

	UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_TASK, nTaskId);
end

function Task:RemoveTask(nTaskId)
	local tbPlayerTask = self:GetPlayerTaskInfo(me);
	for nIdx, tbTaskInfo in pairs(tbPlayerTask.tbCurTaskInfo) do
		if tbTaskInfo.nTaskId == nTaskId then
			table.remove(tbPlayerTask.tbCurTaskInfo, nIdx);
			break;
		end
	end
	self:DeleteClientNpc(nTaskId);
	self:UpdateTaskInfo(nTaskId);
	self:CheckTaskNotSyncNpc(me.nMapTemplateId, nTaskId);
end

function Task:OnFinishTask(nTaskId)
	self:SetTaskFlag(me, nTaskId);
	local tbPlayerTask = self:GetPlayerTaskInfo(me);
	for nIdx, tbTaskInfo in pairs(tbPlayerTask.tbCurTaskInfo) do
		if tbTaskInfo.nTaskId == nTaskId then
			table.remove(tbPlayerTask.tbCurTaskInfo, nIdx);
			break;
		end
	end

	self:DeleteClientNpc(nTaskId);
	self:UpdateTaskInfo(nTaskId);
	self:CheckTaskNotSyncNpc(me.nMapTemplateId, nTaskId);

	UiNotify.OnNotify(UiNotify.emNOTIFY_TASK_FINISH, nTaskId);

	local tbTask = self:GetTask(nTaskId);
	if tbTask and tbTask.bShowFinish == 1 then
		Ui:OpenWindow("LevelUpPopup", "task");
	end

	if tbTask and tbTask.szOnFinishTrack ~= "" then
		self:DoTrack(tbTask.szOnFinishTrack, nTaskId);
	end
end

function Task:OnAcceptTask(nTaskId)
	local tbPlayerTask = self:GetPlayerTaskInfo(me);
	table.insert(tbPlayerTask.tbCurTaskInfo, {nTaskId = nTaskId, tbState = {}});
	self:UpdateTaskInfo(nTaskId);

	local tbTask = self:GetTask(nTaskId);
	if not tbTask.bNotAutoNext or tbTask.bNotAutoNext ~= 1 then
		self:OnTrack(nTaskId);
	end
	Lib:CallBack({Task.OnZoneTaskAccept, Task, nTaskId});
end

function Task:OnTrack(nTaskId)
	local tbTask = self:GetTask(nTaskId) or {};
	if not tbTask then
		return;
	end

	if tbTask.nMinTargetLevel and tbTask.nMinTargetLevel < 0 then
		me.CenterMsg("旧的故事暂告段落，新的篇章未完待续，敬请期待");
		return;
	end

	if tbTask.nMinTargetLevel and me.nLevel < tbTask.nMinTargetLevel then
		me.CenterMsg(string.format("少侠等级不足 %s ，还是历练一番再来吧！", tbTask.nMinTargetLevel));
		return;
	end

	local szTrackInfo = tbTask.szTrackInfo;
	local nTaskState = Task:GetTaskState(me, nTaskId);
	if nTaskState == Task.STATE_CAN_FINISH then
		szTrackInfo = tbTask.szFinishTrackInfo;
	end
	if not szTrackInfo or szTrackInfo == "" then
		if nTaskState == Task.STATE_CAN_FINISH then
			RemoteServer.DoTaskNextStep(nTaskId, me.GetNpc().nId);
		end
		return;
	end

	AutoFight:ChangeState(AutoFight.OperationType.Manual);

	Timer:Register(10, function () self:DoTrack(szTrackInfo, nTaskId); end);
end

function Task:DoTrack(szTrackInfo, nTaskId)
	local tbTask = self:GetTask(nTaskId) or {};
	local tbType, szParam, szType = Ui.HyperTextHandle:Analysis(szTrackInfo);
	if szType ~= "npc" and szType ~= "openwnd" and szType ~= "npcpath" then
		tbType:HandleClick(szParam);
		return;
	end

	if szType == "openwnd" then
		local szDesc, szUiName, szUiParam = string.match(szParam, "^[ \t]*([^ \t,]+)[ \t]*,[ \t]*([^ \t]+)[ \t]*,[ \t]*(.*)$");
		if szUiName == "FubenSectionPanel" then
			local tbParam = loadstring(string.format("return {%s}", szUiParam))();
			local szType, nSectionIdx, nSubSectionIdx = unpack(tbParam);
			if szType ~= "ExplorationFuben" and szType ~= "TeamFuben" then
				local nFubenLevel = PersonalFuben.PERSONAL_LEVEL_NORMAL;
				if szType == "EliteFuben" then
					nFubenLevel = PersonalFuben.PERSONAL_LEVEL_ELITE;
				end

				local bRet, szMsg = PersonalFuben:CanCreateFubenCommon(me, nSectionIdx, nSubSectionIdx, nFubenLevel);
				if not bRet then
					me.CenterMsg(szMsg);
					return;
				end

				if not PersonalFuben:CheckPosition(me, nSectionIdx, nSubSectionIdx, nFubenLevel) then
					me.CenterMsg("此地图无法开启关卡，请先返回[FFFE0D]「襄阳城」[-]");
					return;
				end
			end
		end
	end

	if szType == "npc" then
		local nNpcTemplateId, nMapTemplateId, nX, nY, nNearLength = tbType:AnalysisParam(szParam);
		if not nMapTemplateId then
			return;
		end
		local function fnOnFindNpc()
			self:OnFindNpc(tbTask.nTaskId, nNpcTemplateId);
		end
		AutoPath:GotoAndCall(nMapTemplateId, nX, nY, fnOnFindNpc, nNearLength or Npc.DIALOG_DISTANCE);
	elseif szType == "npcpath" then
		local nNpcTemplateId, tbPath, nNearLength = tbType:AnalysisParam(szParam);
		local function fnOnFindNpc()
			self:OnFindNpc(tbTask.nTaskId, nNpcTemplateId);
		end

		AutoPath:GotoPath(tbPath, fnOnFindNpc, nNearLength);
	else
		tbType:HandleClick(szParam);
	end
end

function Task:OnFindNpc(nTaskId, nNpcTemplateId)
	local tbNpcList = KNpc.GetAroundNpcList(me.GetNpc(), Npc.DIALOG_DISTANCE);

	for _, pNpc in pairs(tbNpcList or {}) do
		if pNpc.nTemplateId == nNpcTemplateId then
			local nState = self:GetTaskState(me, nTaskId, nNpcId);
			if nState == self.STATE_CAN_ACCEPT or nState == self.STATE_CAN_FINISH then
				RemoteServer.DoTaskNextStep(nTaskId, pNpc.nId);
			else
				Operation.SimpleTap(pNpc.nId);
			end
			return;
		end
	end
end

function Task:GetTaskExtInfo(nTaskId)
	local tbTmpTask = self:GetTask(nTaskId);
	if not tbTmpTask then
		return "";
	end

	local nTaskState = Task:GetTaskState(me, nTaskId, -1);

	local szExtInfo = "";
	if Task.KinTask.tbTask2Type[nTaskId] then
		local _, nIndex = Task.KinTask:GetTaskInfo(me);
		szExtInfo = string.format("(%s/%s)", nIndex, #Task.KinTask.tbTaskInfo);
	end

	local tbNeedItemInfo = tbTmpTask.tbTargetInfo["CollectItem"] or {};
	for nItemId, nCount in pairs(tbNeedItemInfo) do
		szExtInfo = string.format("(%s/%s)", me.GetItemCountInBags(nItemId), nCount);
		break;
	end

	local tbNeedKillNpcInfo = tbTmpTask.tbTargetInfo["KillNpc"] or {};
	for nNpcTemplate, nCount in pairs(tbNeedKillNpcInfo) do
		local tbPlayerTask = Task:GetPlayerTaskInfo(me, nTaskId);
		if tbPlayerTask then
			tbPlayerTask.tbTargetInfo = tbPlayerTask.tbTargetInfo or {};
			tbPlayerTask.tbTargetInfo["KillNpc"] = tbPlayerTask.tbTargetInfo["KillNpc"] or {};
			szExtInfo = string.format("(%s/%s)", tbPlayerTask.tbTargetInfo["KillNpc"][nNpcTemplate] or 0, nCount);
		end
		break;
	end
	return nTaskState == Task.STATE_ON_DING and szExtInfo or "";
end

function Task:UseTaskItem(nTaskId)
	local tbPlayerTask = self:GetPlayerTaskInfo(me, nTaskId);
	if not tbPlayerTask then
		return;
	end

	local tbTaskItem = self:GetTaskItem(nTaskId);
	if not tbTaskItem then
		return;
	end

	local function fnOnGotoTaskItem()
		Timer:Register(10, function () RemoteServer.UseTaskItem(nTaskId); end);
	end

	AutoPath:GotoAndCall(tbTaskItem.nMapTemplateId, tbTaskItem.nX, tbTaskItem.nY, fnOnGotoTaskItem);
end

function Task:OnItemCountChanged(nItemId)
	local pItem = KItem.GetItemObj(nItemId)
	if not pItem then
		return;
	end

	local tbPlayerTask = self:GetPlayerTaskInfo(me) or {};
	local tbCurInfo = tbPlayerTask.tbCurTaskInfo;
	if not tbCurInfo then
		return;
	end

	for _, tbInfo in pairs(tbCurInfo) do
		local tbTask = self:GetTask(tbInfo.nTaskId) or {};
		local tbTargetInfo = (tbTask.tbTargetInfo or {})["CollectItem"] or {};
		if tbTargetInfo[pItem.dwTemplateId] then
			UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_TASK, tbInfo.nTaskId);
		end
	end
end

function Task:OnPlayerLevelUp(nNewLevel)
	local tbPlayerTask = self:GetPlayerTaskInfo(me) or {};
	local tbCurInfo = tbPlayerTask.tbCurTaskInfo;
	if not tbCurInfo then
		return;
	end

	for _, tbInfo in pairs(tbCurInfo) do
		local tbTask = self:GetTask(tbInfo.nTaskId) or {};
		if tbTask.nMinTargetLevel == nNewLevel then
			UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_TASK, tbInfo.nTaskId);
		end
	end
end

function Task:OpenConfirmPanel(nTaskId, nNpcId)
	local tbTask = Task:GetTask(nTaskId);
	if not tbTask then
		return
	end
	if tbTask.nNeedConfirmFinish == Task.TASK_CONFIRM_TYPE_NORMAL then
		Ui:OpenWindow("TaskFinish", nTaskId, nNpcId);
	elseif tbTask.nNeedConfirmFinish == Task.TASK_CONFIRM_TYPE_WLDS then
		local _, nCurDay = WuLinDaShi:GetCyclePercent()
		local szMsg = string.format("尊敬的侠士，守卫襄阳共持续10天，每天均有奖励，本阶段已进行到第%d天，要立即接取还是等待下轮开启，请少侠自行斟酌！", nCurDay)
		me.MsgBox(szMsg, {
				{"开始任务", function () RemoteServer.OnFinishTaskDialog(nTaskId, Task.STATE_CAN_FINISH, nNpcId) end},
				{"暂不接取"},
			})
	end
end

function Task:TryAddZoneTaskExtPoint(nTaskId)
	local bRet, szMsg  = self:CheckZoneTaskAddExtPoint(nTaskId)
	if not bRet then
		return
	end
	RemoteServer.TryAddZoneExtPoint(nTaskId);
end

function Task:OnZoneTaskAccept(nTaskId)
	nTaskId = nTaskId or 0
	if not self.tbZoneTaskRef[nTaskId] then
		return
	end
	if nTaskId == Task.nMyZoneTaskId  then
		Ui:SetRedPointNotify("BtnHomepageMy")
	elseif nTaskId == Task.nWorldSquareTaskId then
		Ui:SetRedPointNotify("PandoraPlayerSpaceGuide")
	end
end

function Task:OnOpenTaskVideo(nVideoType)
	local tbVideoTask = Task.tbAllVideoTask[nVideoType]
	if not tbVideoTask then
		Log("Task fnOnOpenTaskVideo No tbVideoTask", me.dwID, me.szName, nVideoType)
		return
	end
	tbVideoTask.fnOnOpen()
	Log("Task fnOnOpenTaskVideo ok", me.dwID, me.szName, nVideoType)
end

function Task:TrackVedioBackPlay()
	Ui.HyperTextHandle:Handle("[url=npc:林青羽, 3246, 15]",0,0)
end

function Task:OnAnswerFlowQuestion(bRight, nFlowType, tbRight)
		UiNotify.OnNotify(UiNotify.emNOTIFY_FLOW_TASK_QUESTION, nFlowType, tbRight)
		if bRight then
			Ui:CloseWindow("TaskQuestionPanel")
		end
end

UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_ITEM, Task.OnItemCountChanged, Task);
UiNotify:RegistNotify(UiNotify.emNOTIFY_DEL_ITEM, Task.OnItemCountChanged, Task);


PlayerEvent:RegisterGlobal("OnLevelUp",			Task.OnPlayerLevelUp, Task);
