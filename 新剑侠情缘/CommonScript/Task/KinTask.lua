Task.KinTask = Task.KinTask or {};
local KinTask = Task.KinTask;

KinTask.DEGREE_TYPE = "KinTask";
KinTask.nFinishAllTaskDialogId = 20037;  --今日任务全完成后的剧情对话

KinTask.bIsOpen = false;
KinTask.szTimeFrame = "OpenDay2";

KinTask.tbAwardList =
{
	[1] = {
		{"BasicExp", 8};
		{"Contrib", 20};
		{"KinFound", 200};
	};

	[2] = {
		{"BasicExp", 8};
		{"Contrib", 20};
		{"KinFound", 200};
	};

	[3] = {
		{"BasicExp", 16};
		{"Contrib", 20};
		{"KinFound", 200};
	};

	[4] = {
		{"BasicExp", 8};
		{"Contrib", 20};
		{"KinFound", 200};
	};

	[5] = {
		{"BasicExp", 8};
		{"Contrib", 20};
		{"KinFound", 200};
	};

	[6] = {
		{"BasicExp", 16};
		{"Contrib", 20};
		{"KinFound", 200};
	};

	[7] = {
		{"BasicExp", 8};
		{"Contrib", 20};
		{"KinFound", 200};
	};

	[8] = {
		{"BasicExp", 8};
		{"Contrib", 20};
		{"KinFound", 200};
	};

	[9] = {
		{"BasicExp", 8};
		{"Contrib", 20};
		{"KinFound", 200};
	};

	[10] = {
		{"BasicExp", 32};
		{"Contrib", 20};
		{"KinFound", 200};
		{"item", 787, 1};
	};
}

KinTask.tbTaskInfo = {
--任务类型 		奖励ID
	{1,				1},
	{1,				2},
	{2,				3},
	{1,				4},
	{1,				5},
	{2,				6},
	{1,				7},
	{1,				8},
	{1,				9},
	{2,				10},
};

function KinTask:LoadSetting()
	local tbFile = LoadTabFile("Setting/Task/KinTaskSetting.tab", "dd", "nTaskId", {"nTaskId", "nType"});

	self.tbTask2Type = {};
	self.tbType2Task = {};
	for nTaskId, tbInfo in pairs(tbFile) do
		self.tbTask2Type[nTaskId] = tbInfo.nType;
		self.tbType2Task[tbInfo.nType] = self.tbType2Task[tbInfo.nType] or {};
		table.insert(self.tbType2Task[tbInfo.nType], nTaskId);
	end
end
KinTask:LoadSetting();

function KinTask:CheckOpen()
	return self.bIsOpen and GetTimeFrameState(self.szTimeFrame) == 1;
end

function KinTask:GetTaskInfo(pPlayer)
	local nMaxCount = DegreeCtrl:GetMaxDegree(KinTask.DEGREE_TYPE, pPlayer);
	local nLastCount = DegreeCtrl:GetDegree(pPlayer, KinTask.DEGREE_TYPE);
	return nLastCount, ((nMaxCount - nLastCount) % #KinTask.tbTaskInfo) + 1;
end

function KinTask:CheckCanAcceptTask(pPlayer)
	local nTaskCount, nCurTaskIdx, nNextTaskIdx = self:GetTaskInfo(pPlayer);
	if nTaskCount <= 0 then
		pPlayer.CallClientScript("Ui:TryPlaySitutionalDialog", self.nFinishAllTaskDialogId);
		return;
	end

	if pPlayer.dwKinId <= 0 then
		pPlayer.CenterMsg("你当前没有家族，无法接取任务！");
		return;
	end

	local tbCurTask = Task:GetPlayerCurTask(pPlayer);
	for nTaskId in pairs(tbCurTask or {}) do
		if self.tbTask2Type[nTaskId] then
			pPlayer.CenterMsg("你已经接取家族任务了！");
			return;
		end
	end

	return true, self.tbTaskInfo[nCurTaskIdx][1], nCurTaskIdx;
end

function KinTask:GetShowTask(pPlayer)
	local _, nIndex = self:GetTaskInfo(pPlayer);
	local nAwardIndex = self.tbTaskInfo[nIndex][2];
	local tbAward = Lib:CopyTB(self.tbAwardList[nAwardIndex]);
	for i = #tbAward, 1, -1 do
		if Player.AwardType[tbAward[i][1]] == Player.award_type_kin_found then
			table.remove(tbAward, i);
		end
	end

	return tbAward;
end