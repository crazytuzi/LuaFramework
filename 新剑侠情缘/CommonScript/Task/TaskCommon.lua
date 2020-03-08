Require("CommonScript/Task/TaskCheckFunc.lua");

Task.tbAllTask = Task.tbAllTask or {};
Task.tbTaskAttachNpc = Task.tbTaskAttachNpc or {};
Task.nFirstTaskId = 1;
Task.tbKillNpc = Task.tbKillNpc or {};

Task.TASK_TYPE_MAIN = 1;
Task.TASK_TYPE_SUB = 2;
Task.TASK_TYPE_DAILY = 3;
Task.TASK_TYPE_VALUE_COMPOSE = 4;
Task.TASK_TYPE_WLDS = 5;
Task.TASK_TYPE_ZHEN_FA = 6;
Task.TASK_TYPE_WLDS_CYCLE = 7;
Task.TASK_TYPE_PARTNERCARD = 8;
Task.TASK_TYPE_JYFL = 9
Task.TASK_TYPE_LOVER = 10

Task.TASK_CONFIRM_TYPE_NORMAL = 1;
Task.TASK_CONFIRM_TYPE_WLDS   = 2;

Task.tbExtTaskAward = {
	[43] = {
		{"Partner", 96, 1},
	},
}

Task.ExtInfo_JianDing 			= "JianDing";						-- Done
Task.ExtInfo_TongBanDaShu		= "TongBanDaShu";					-- Done
Task.ExtInfo_YuanBaoZhaoMu		= "YuanBaoZhaoMu";					-- Done
Task.ExtInfo_TiShengZiZhi		= "TiShengZiZhi";					-- Done
Task.ExtInfo_ShanZeiMiKu		= "ShanZeiMiKu";					-- Done
Task.ExtInfo_DaTi				= "DaTi";							-- Done
Task.ExtInfo_BaiTan				= "BaiTan";							-- Done
Task.ExtInfo_ShangCheng			= "ShangCheng";						-- Done
Task.ExtInfo_TaskQuestion 		= "Task_DaTi";						-- Done
Task.ExtInfo_ShangZhenTongBan	= "ShangZhenTongBan"				-- Done
Task.ExtInfo_TongBanJiaJingYan	= "TongBanJiaJingYan"				-- Done
Task.ExtInfo_JiangHuTrain		= "JiangHuTrain"					-- TODO
Task.ExtInfo_UseFurniture		= "UseFurniture"					-- Done
Task.ExtInfo_DaiYanRenAct 		= "DaiYanRenAct"					-- Done

Task.tbTrap2TrackInfo = Task.tbTrap2TrackInfo or {};

Task.SAVE_GROUP_JYFL = 173 											 -- 剑意风流
Task.FIRST_TASK_ACCEPT_TIME = 1 				 					 -- 接第一个任务时间
Task.nFirstJYFLTaskId = 9001 										 -- 第一个任务id
Task.nLastJYFLTasjId = -1 											 -- 当前任务线最后一个任务
Task.nNewLineFirstTaskId = 9015 									-- 新任务线开放后第一个任务id
Task.nAcceptJYFLLimitTime = Lib:ParseDateTime("2018/9/19 4:00:00") 	-- 这个时间点之后第一个任务接的是nNewLineFirstTaskId
Task.nEndJYFLLimitTime = Lib:ParseDateTime("2018/11/1 4:00:00") 	-- 这个时间点之后不能再接任务线的开头任务
Task.nAcceptJYFLMinLevel = 40 										-- 接任务最小等级


Task.VIDEO_TYPE_JYFL = 1 											 -- 剑意风流预告片视频
Task.VIDEO_TYPE_JYFL_2 = 2 											 -- 剑意风流预告片视频
Task.VIDEO_TYPE_JYFL_3 = 3 											 -- 剑意风流预告片视频
Task.VIDEO_TYPE_JYFL_4 = 4 											 -- 剑意风流预告片视频
Task.VIDEO_TYPE_JYFL_5 = 5 											 -- 剑意风流预告片视频
Task.VIDEO_TYPE_JYFL_6 = 6 											 -- 剑意风流预告片视频
Task.VIDEO_TYPE_JYFL_7 = 7 											 -- 剑意风流预告片视频
Task.nJYFLTaskMapTId = 4100 										 -- 分流任务主任务
Task.tbAllVideoTask = 
{
	[Task.VIDEO_TYPE_JYFL] = {
		fnOnOpen = function ()
			Pandora:OpenVideo()
			me.SendBlackBoardMsg("故事正在酝酿，请稍等片刻");
		end;
		nTaskId = 9013;
		szVideoTitle = "预告";
	}; 		
	[Task.VIDEO_TYPE_JYFL_2] = {
		fnOnOpen = function ()
			local fnAgree = function ()
				Pandora:OpenVideo(1)
				me.SendBlackBoardMsg("故事正在酝酿，请稍等片刻");
			end
			me.MsgBox("观看剧情需要额外流量，如果遇到播放卡顿、无法播放等体验不佳的问题，可以先选择跳过，再去临安城的林青羽出对话体验剧情", {{"确定", fnAgree}, {"取消"}})
			
		end;
		nTaskId = 9017;
		szVideoTitle = "序幕";
	}; 			
	[Task.VIDEO_TYPE_JYFL_3] = {
		fnOnOpen = function ()
			Pandora:OpenVideo(2)
			me.SendBlackBoardMsg("故事正在酝酿，请稍等片刻");
		end;
		nTaskId = 9022;
		szVideoTitle = "潜伏";
	}; 			
	[Task.VIDEO_TYPE_JYFL_4] = {
		fnOnOpen = function ()
			Pandora:OpenVideo(3)
			me.SendBlackBoardMsg("故事正在酝酿，请稍等片刻");
		end;
		nTaskId = 9027;
		szVideoTitle = "坎坷";
	}; 			
	[Task.VIDEO_TYPE_JYFL_5] = {
		fnOnOpen = function ()
			Pandora:OpenVideo(4)
			me.SendBlackBoardMsg("故事正在酝酿，请稍等片刻");
		end;
		nTaskId = 9032;
		szVideoTitle = "复仇";
	}; 			
	[Task.VIDEO_TYPE_JYFL_6] = {
		fnOnOpen = function ()
			Pandora:OpenVideo(5)
			me.SendBlackBoardMsg("故事正在酝酿，请稍等片刻");
		end;
		nTaskId = 9037;
		szVideoTitle = "孽缘";
	}; 			
	[Task.VIDEO_TYPE_JYFL_7] = {
		fnOnOpen = function ()
			Pandora:OpenVideo(6)
			me.SendBlackBoardMsg("故事正在酝酿，请稍等片刻");
		end;
		nTaskId = 9041;
		szVideoTitle = "大决战";
	}; 										 
}

Task.nFlowTaskId = 9019 											-- 分流任务线主任务id
Task.Flow_Save_Group = 183 											
Task.Flow_Line_1 = 1 				 								-- 分流类型也是分流1答题次数索引
Task.Flow_Line_2 = 2 												-- 分流类型也是分流2答题次数索引
Task.Flow_Line_3 = 3 												-- 分流类型也是分流3答题次数索引
Task.Flow_Line_4 = 4 												-- 分流类型也是分流4答题次数索引
Task.nFlowQuestionCostGold = 100 									-- 答题花费
Task.nFlowQuestionCostCount = 1 									-- 第n次之后收费
Task.tbFlowSetting = 
{
	[Task.Flow_Line_1] = 
	{
		nStartTaskId = 9020;
		nEndTaskId = 9024;
		szTitle = "潜伏";
		nQuestionTaskId = 9024;
		szFlowQuestionTitle = "潜伏";
	};
	[Task.Flow_Line_2] = 
	{
		nStartTaskId = 9025;
		nEndTaskId = 9029;
		szTitle = "坎坷";
		nQuestionTaskId = 9029;
		szFlowQuestionTitle = "坎坷";
	};
	[Task.Flow_Line_3] = 
	{
		nStartTaskId = 9030;
		nEndTaskId = 9034;
		szTitle = "复仇";
		nQuestionTaskId = 9034;
		szFlowQuestionTitle = "复仇";
	};
	[Task.Flow_Line_4] = 
	{
		nStartTaskId = 9035;
		nEndTaskId = 9039;
		szTitle = "孽缘";
		nQuestionTaskId = 9039;
		szFlowQuestionTitle = "孽缘";
	};
}

Task.tbOldAchi = 
{
	{57, "Task_1"};
	{152, "Task_2"};
	{187, "Task_3"};
	{189, "Task_4"};
	{217, "Task_5"};
	{244, "Task_6"};
	{292, "Task_7"};
	{322, "Task_8"};
	{354, "Task_9"};
	{367, "Task_10"};
	{384, "Task_11"};
	{410, "Task_12"};
	{412, "Task_13"};
}

function Task:Init()
	local tbFileList = LoadTabFile("Setting/Task/TaskList.tab", "s", "TabFile", {"TabFile"});

	for szFilePath in pairs(tbFileList) do
		self:LoadTaskFile(szFilePath);
	end
	self:LoadTaskItem();

	Task.tbTrap2TrackInfo = {};
	local tbFile = LoadTabFile("Setting/Task/Trap2Track.tab", "dsds", nil, {"nMapTemplateId", "szTrap", "nTaskId", "szTrack"});
	for _, tbRow in pairs(tbFile or {}) do
		self.tbTrap2TrackInfo[tbRow.nMapTemplateId] = self.tbTrap2TrackInfo[tbRow.nMapTemplateId] or {};
		local szTrap = Lib:StrTrim(tbRow.szTrap);
		self.tbTrap2TrackInfo[tbRow.nMapTemplateId][szTrap] = self.tbTrap2TrackInfo[tbRow.nMapTemplateId][szTrap] or {};
		local tbInfo = self.tbTrap2TrackInfo[tbRow.nMapTemplateId][szTrap];

		assert(not tbInfo[tbRow.nTaskId], "load Trap2Track.tab fail !!");
		tbInfo[tbRow.nTaskId] = tbRow.szTrack;
	end
	self:LoadFlowTask()
end

function Task:LoadFlowTask()
	self.tbFlowQuestion = {}
	local szParamType = "dsd";
	local tbParams = {"nFlowType", "szQuestion", "nAnswerIdx"};
	for i=1, 10 do
		szParamType = szParamType .."s";
		table.insert(tbParams,"szAnswer" ..i);
	end
	local tbFile = LoadTabFile("Setting/Task/Task_FlowQuestion.tab", szParamType, nil, tbParams);
	for _, v in ipairs(tbFile) do
		self.tbFlowQuestion[v.nFlowType] = self.tbFlowQuestion[v.nFlowType] or {}
		local tbInfo = {}
		tbInfo.szQuestion = v.szQuestion
		tbInfo.nAnswerIdx = v.nAnswerIdx
		tbInfo.tbAnswer = {}
		for i=1, 10 do
			if not Lib:IsEmptyStr(v["szAnswer" ..i]) then
				table.insert(tbInfo.tbAnswer, v["szAnswer" ..i])
			end
		end
		assert(tbInfo.nAnswerIdx > 0 and tbInfo.nAnswerIdx <= #tbInfo.tbAnswer,string.format( "[FlowTask] Wrong Answer %d", tbInfo.nAnswerIdx))
		table.insert(self.tbFlowQuestion[v.nFlowType], tbInfo)
	end
end

function Task:CheckTaskInfo(tbRow, szIndex, value)
	local szCmdType = string.match(szIndex, "^Require_([^ ]+)$");
	if szCmdType and value ~= "" then
		if szCmdType == "MinLevel" or szCmdType == "MaxLevel" or szCmdType == "FinishTask" then
			if value == 0 then
				return;
			end
		end

		tbRow[szIndex] = nil;
		tbRow.tbRequireInfo[szCmdType] = value;
		return;
	end

	szCmdType = string.match(szIndex, "^Target_([^ ]+)$");
	if szCmdType and value ~= "" and value ~= 0 then
		tbRow[szIndex] = nil;

		local newValue = value;
		if szCmdType == "KillNpc" then
			newValue = Lib:GetTableFromString(value);
			for nNpcTemplateId in pairs(newValue or {}) do
				self.tbKillNpc[nNpcTemplateId] = self.tbKillNpc[nNpcTemplateId] or 0;
				if tbRow.bKillNpcToAllPlayer == 1 then
					self.tbKillNpc[nNpcTemplateId] = 1;
				end
			end
		end

		if szCmdType == "PersonalFuben" then
			local tbInfo = Lib:SplitStr(value, "|");
			newValue = {};
			newValue.nSectionIdx = tonumber(tbInfo[1]) or 99999;
			newValue.nSubSectionIdx = tonumber(tbInfo[2]) or 99999;
			newValue.nFubenLevel = tonumber(tbInfo[3]) or 99999;
		end

		if szCmdType == "Achievement" then
			newValue = Lib:SplitStr(value, "|");
			newValue[2] = tonumber(newValue[2]) or 1;
		end

		if szCmdType == "CollectItem" then
			newValue = Lib:GetTableFromString(value);
		end

		if szCmdType == "MinLevel" then
			tbRow.nMinTargetLevel = newValue;
		end

		if szCmdType == "OnTrap" then
			local tbInfo = Lib:SplitStr(value, "|");
			newValue = {};
			newValue.nMapTemplateId = tonumber(tbInfo[1]);
			newValue.szTrap = tbInfo[2];
		end

		tbRow.tbTargetInfo[szCmdType] = newValue;
		return;
	end

	if szIndex == "ShowClientNpc" or szIndex == "DeleteClientNpc" then
		local tbInfo = Lib:SplitStr(value, "|");
		for _, szValue in ipairs(tbInfo) do
			local nValue = tonumber(szValue);
			if nValue then
				tbRow["tb" .. szIndex] = tbRow["tb" .. szIndex] or {};
				table.insert(tbRow["tb" .. szIndex], nValue);
			end
		end
	end
end

Task.tbCheckTargetFunc =
{
	["KillNpc"] 		= Task.CheckTargetKillNpc,
	["CollectItem"] 	= Task.CheckTargetCollectItem,
	["PersonalFuben"]	= Task.CheckTargetPersonalFuben,
	["MinLevel"]		= Task.CheckTargetMinLevel,
	["ExtPoint"]		= Task.CheckTargetExtPoint,
	["Achievement"]		= Task.CheckTargetAchievement,
	["OnTrap"]			= Task.CheckTargetOnTrap,
	["EnterMap"]		= Task.CheckTargetEnterMap,
	["ExtInfo"]			= Task.CheckTargetExtInfo,
}

Task.tbCheckRequireFunc =
{
	["MinLevel"]		= Task.CheckRequireMinLevel,
	["MaxLevel"]		= Task.CheckRequireMaxLevel,
	["FinishTask"]		= Task.CheckRequireFinishTask,
}

function Task:LoadTaskFile(szFilePath)
	local tbFileIdxInfo = {
			{"nTaskId",					"d"},
			{"szTaskIndex",				"s"},
			{"szTaskTitle",				"s"},
			{"szDetailDesc",			"s"},
			{"szTaskDesc",				"s"},
			{"nAcceptDialogId",			"d"},
			{"szFinishDesc",			"s"},
			{"nFinishDialogId", 		"d"},
			{"nTaskType",				"d"},
			{"szTrackInfo",				"s"},
			{"szFinishTrackInfo",		"s"},
			{"bCanRepeat",				"d"},
			{"bClientAllow",			"d"},
			{"nAutoNextTaskId",			"d"},
			{"nAcceptTaskNpcId",		"d"},
			{"nFinishTaskNpcId",		"d"},
			{"Target_KillNpc",			"s"},
			{"Target_CollectItem",		"s"},
			{"Target_PersonalFuben",	"s"},
			{"Target_MinLevel",			"d"},
			{"Target_ExtPoint",			"d"},
			{"Target_Achievement",		"s"},
			{"Target_EnterMap",			"d"},
			{"Target_OnTrap",			"s"},
			{"Target_ExtInfo",			"s"},
			{"Require_MinLevel",		"d"},
			{"Require_MaxLevel",		"d"},
			{"Require_FinishTask",		"d"},
			{"szAwardInfo",				"s"},
			{"IsFinishGuide",			"d"},
			{"bAutoFinish",				"d"},
			{"bNotAutoNext",			"d"},
			{"bShowFinish",				"d"},
			{"bKillNpcToAllPlayer",		"d"},
			{"ShowClientNpc",			"s"},
			{"DeleteClientNpc",			"s"},
			{"szOnFinishTrack",			"s"},
			{"nNeedConfirmFinish",		"d"},
			{"nTaskItemId",				"d"},
			{"szDoNextFunc",			"s"},
			{"szAchievement", 			"s"},
	};
	local tbFileInfo = {
		szType = "";
		szIndex = nil;
		tbTitle = {};
	};
	for _, tbInfo in pairs(tbFileIdxInfo) do
		table.insert(tbFileInfo.tbTitle, tbInfo[1]);
		tbFileInfo.szType = tbFileInfo.szType .. tbInfo[2];
	end

	local tbFile = LoadTabFile(szFilePath, tbFileInfo.szType, tbFileInfo.szIndex, tbFileInfo.tbTitle);
	if not tbFile then
		Log("[Task] Load Task File Fail !! file can not find !! ", szFilePath);
		return;
	end

	self.tbAllTask = self.tbAllTask or {};
	self.tbTaskAttachNpc = self.tbTaskAttachNpc or {};
	local tbTmp = {};
	for _, tbRow in pairs(tbFile) do
		tbRow.tbTargetInfo = {};
		tbRow.tbRequireInfo = {};

		tbRow.tbAward = Lib:GetAwardFromString(tbRow.szAwardInfo);

		for i, v in ipairs(tbRow.tbAward) do
			local szAwardType = v[1];
			local nAwardType = Player.AwardType[szAwardType];
			--if nAwardType == Player.award_type_basic_exp then
			if nAwardType == Player.award_type_exp then
				tbRow.tbAward[i][2] = v[2] * 10
			end
		end

		tbRow.szAwardInfo = nil;

		if tbRow.szMainTaskIndex == "" then
			tbRow.szMainTaskIndex = nil;
		end

		local tbAllKey = {};
		for szKey in pairs(tbRow) do
			tbAllKey[szKey] = 1;
		end

		for szIndex in pairs(tbAllKey) do
			if szIndex == "bCanRepeat" then
				tbRow[szIndex] = (tbRow[szIndex] == 1);
			elseif szIndex == "bClientAllow" then
				tbRow[szIndex] = (tbRow[szIndex] == 1);
			else
				self:CheckTaskInfo(tbRow, szIndex, tbRow[szIndex]);
			end
		end

		tbTmp[tbRow.nTaskId] = tbTmp[tbRow.nTaskId] or {};
		if tbRow.nAcceptTaskNpcId > 0 and not tbTmp[tbRow.nTaskId][tbRow.nAcceptTaskNpcId] then
			tbTmp[tbRow.nTaskId][tbRow.nAcceptTaskNpcId] = 1;
			self.tbTaskAttachNpc[tbRow.nAcceptTaskNpcId] = self.tbTaskAttachNpc[tbRow.nAcceptTaskNpcId] or {};
			table.insert(self.tbTaskAttachNpc[tbRow.nAcceptTaskNpcId], tbRow.nTaskId);

		end

		if tbRow.nFinishTaskNpcId > 0 and not tbTmp[tbRow.nTaskId][tbRow.nFinishTaskNpcId] then
			tbTmp[tbRow.nTaskId][tbRow.nFinishTaskNpcId] = 1;
			self.tbTaskAttachNpc[tbRow.nFinishTaskNpcId] = self.tbTaskAttachNpc[tbRow.nFinishTaskNpcId] or {};
			table.insert(self.tbTaskAttachNpc[tbRow.nFinishTaskNpcId], tbRow.nTaskId);
		end

		if self.tbAllTask[tbRow.nTaskId] then
			assert(false, string.format("[Task] repeat task id %s", tbRow.nTaskId));
		end

		self.tbAllTask[tbRow.nTaskId] = tbRow;
	end
end

function Task:LoadTaskItem()
	local tbInfo = LoadTabFile("Setting/Task/TaskItem.tab", "dsddddss", "nTaskItemId", {"nTaskItemId", "szMsg", "nTime", "nMapTemplateId", "nX", "nY", "szAtlas", "szImg"});
	self.tbTaskItem = {};
	for nTaskId, tbTask in pairs(self.tbAllTask) do
		if tbTask.nTaskItemId and tbTask.nTaskItemId > 0 then
			self.tbTaskItem[nTaskId] = tbInfo[tbTask.nTaskItemId];
		end
	end
end

function Task:MarcoReplace(tbRow)
	local tbTips = {
		"szTaskTitle", "szDetailDesc", "szTaskDesc", "szFinishDesc", "szTrackInfo", "szFinishTrackInfo", "szOnFinishTrack"
	};

	local szAcceptTaskNpcName = tbRow.nAcceptTaskNpcId > 0 and KNpc.GetNameByTemplateId(tbRow.nAcceptTaskNpcId) or "？";
	local szFinishTaskNpcName = tbRow.nFinishTaskNpcId > 0 and KNpc.GetNameByTemplateId(tbRow.nFinishTaskNpcId) or "？";
	local szPersonalFubenName = "？";

	if tbRow.tbTargetInfo and tbRow.tbTargetInfo["PersonalFuben"] then
		local tbTargetInfo = tbRow.tbTargetInfo["PersonalFuben"];
		szPersonalFubenName = PersonalFuben:GetSectionName(tbTargetInfo.nSectionIdx, tbTargetInfo.nSubSectionIdx, tbTargetInfo.nFubenLevel) or "？";
	end

	for _, szTips in pairs(tbTips) do
		tbRow[szTips] = string.gsub(tbRow[szTips], "$T", tbRow.nTaskId);
		tbRow[szTips] = string.gsub(tbRow[szTips], "$A", tbRow.nAcceptTaskNpcId);
		tbRow[szTips] = string.gsub(tbRow[szTips], "$F", tbRow.nFinishTaskNpcId);
		tbRow[szTips] = string.gsub(tbRow[szTips], "$NA", szAcceptTaskNpcName);
		tbRow[szTips] = string.gsub(tbRow[szTips], "$NF", szFinishTaskNpcName);
		tbRow[szTips] = string.gsub(tbRow[szTips], "$NP", szPersonalFubenName);
	end
end

Task:Init();

function Task:Setup()
	for _, tbRow in pairs(self.tbAllTask) do
		self:MarcoReplace(tbRow);
	end
end

--[[
tbTask = {};
tbTask.tbRecord = {};
tbTask.tbCurTaskInfo = {};
tbTask.tbCurTaskInfo[1] = {
	nTaskId = 110;
	tbTargetInfo = {
		["KillNpc"] = {
			[100] = 1,
			[111] = 2,
		};
		["FinishFuben"] = {
			[10001] = 1,
			[1111] = 2,
		};
		["CollectItem"] =
		{
			[110] = 1,
			[22] = 3,
		}
	};
};
]]

function Task:HaveAcceptTask(pPlayer, nTaskId)
    if not nTaskId then
    	return false;
    end

    local tbTask = self:GetPlayerTaskInfo(pPlayer, nTaskId);
    if not tbTask then
    	return false;
    end

    return true;
end

function Task:GetPlayerTaskInfo(pPlayer, nTaskId)
	local tbTask = pPlayer.GetScriptTable("Task");
	tbTask.tbRecord = tbTask.tbRecord or {};
	tbTask.tbCurTaskInfo = tbTask.tbCurTaskInfo or {};

	if nTaskId then
		for nIndex, tbCurTask in pairs(tbTask.tbCurTaskInfo) do
			if tbCurTask.nTaskId == nTaskId then
				return tbCurTask, tbTask, nIndex;
			end
		end

		return nil;
	end

	return tbTask;
end

function Task:GetPlayerCurTask(pPlayer)
	local tbTask = pPlayer.GetScriptTable("Task");
	tbTask.tbRecord = tbTask.tbRecord or {};
	tbTask.tbCurTaskInfo = tbTask.tbCurTaskInfo or {};

	local tbResult = {};
	for _, tbCurTask in pairs(tbTask.tbCurTaskInfo) do
		tbResult[tbCurTask.nTaskId] = tbCurTask;
	end

	return tbResult;
end

function Task:GetTaskDataInfo(nTaskId, szType)
	local tbDstTask = self:GetTask(nTaskId);
	return ((tbDstTask or {}).tbTargetInfo or {})[szType];
end

function Task:SavePlayerTaskInfo(pPlayer)
	pPlayer.SaveScriptTable("Task");
end

function Task:SetTaskFlag(pPlayer, nTaskId, nFlag)
	local tbTask = self:GetPlayerTaskInfo(pPlayer);
	if not tbTask then
		return;
	end

	if not nFlag or nFlag ~= 0 then
		nFlag = 1;
	end

	if nFlag == 0 then
		Log("Task:SetTaskFlag >>", pPlayer.szName, nTaskId, nFlag);
	end

	Lib:SetTableBit(tbTask.tbRecord, nTaskId, nFlag);
end

function Task:GetTaskFlag(pPlayer, nTaskId)
	local tbTask = self:GetPlayerTaskInfo(pPlayer);
	if not tbTask then
		return 0;
	end

	return Lib:GetTableBit(tbTask.tbRecord, nTaskId);
end

function Task:IsFinish(pPlayer, nTaskId)
	return self:GetTaskFlag(pPlayer, nTaskId)==1
end

function Task:GetTaskState(pPlayer, nTaskId, nNpcId)
	local tbPlayerTask = self:GetPlayerTaskInfo(pPlayer, nTaskId);
	if tbPlayerTask then
		if self:CheckCanFinishTask(pPlayer, nTaskId, -1) then
			return self.STATE_CAN_FINISH;
		end

		local pNpc = KNpc.GetById(nNpcId or -1);
		local tbTask = self:GetTask(nTaskId);

		if not pNpc or (pNpc and pNpc.nTemplateId == tbTask.nFinishTaskNpcId) then
			return self.STATE_ON_DING;
		end

		return self.STATE_NONE;
	end

	if self:CheckCanAcceptTask(pPlayer, nTaskId, -1) then
		return self.STATE_CAN_ACCEPT;
	end

	return self.STATE_NONE;
end

function Task:CommonCheck(pPlayer, nTaskId, nNpcId, bIsCheckAccept)
	if not pPlayer then
		return false, "异常";
	end

	local tbTask = self:GetTask(nTaskId);
	if not tbTask then
		return false, "无此任务！";
	end

	if not bIsCheckAccept then
		local tbCollectItem = tbTask.tbTargetInfo["CollectItem"] or {};
		for nItemId, nNeedCount in pairs(tbCollectItem) do
			if pPlayer.GetItemCountInAllPos(nItemId) < nNeedCount then
				return false, "任务道具不足！";
			end
		end
	end

	local nFlag = self:GetTaskFlag(pPlayer, nTaskId);
	if nFlag == 1 and not tbTask.bCanRepeat then
		return false, "不能重复完成此任务！";
	end

	local nNeedNpcId = tbTask.nFinishTaskNpcId;
	if bIsCheckAccept then
		nNeedNpcId = tbTask.nAcceptTaskNpcId;
	end

	local pNpc = nil;
	if nNpcId ~= -1 then
		pNpc = KNpc.GetById(nNpcId);
		if not pNpc then
			return false, "你在找谁呢？";
		end

		if nNeedNpcId ~= 0 and pNpc.nTemplateId ~= nNeedNpcId then
			return false, "目标错误！";
		end

		if pPlayer.GetNpc().GetDistance(nNpcId) > Npc.DIALOG_DISTANCE then
			return false, "距离太远了！";
		end
	end

	return true, "", tbTask, pNpc;
end

function Task:CheckCanFinishTask(pPlayer, nTaskId, nNpcId)
	local bRet, szMsg, tbTask, pNpc = self:CommonCheck(pPlayer, nTaskId, nNpcId, false);
	if not bRet then
		return false, szMsg;
	end

	local tbTargetInfo = self:GetTaskTargetInfo(pPlayer, nTaskId);
	if not tbTargetInfo then
		return false, "没有接取过此任务！";
	end

	for szType, value in pairs(tbTask.tbTargetInfo) do
		local fnCheckTargetFunc = self.tbCheckTargetFunc[szType];
		if not fnCheckTargetFunc then
			return false, "" .. szType .. " 未定义目标！";
		end

		local bOK, bRet, szMsg = Lib:CallBack({fnCheckTargetFunc, self, pPlayer, nTaskId, value, tbTargetInfo[szType]});
		if not bOK or not bRet then
			return false, szMsg or "未知原因，无法完成任务！";
		end
	end

	return true;
end

function Task:CheckCanAcceptTask(pPlayer, nTaskId, nNpcId)
	local bRet, szMsg, tbTask, pNpc = self:CommonCheck(pPlayer, nTaskId, nNpcId, true);
	if not bRet then
		return false, szMsg;
	end

	local tbTargetInfo = self:GetTaskTargetInfo(pPlayer, nTaskId);
	if tbTargetInfo then
		return false, "已接取此任务！";
	end

	for szFunc, value in pairs(tbTask.tbRequireInfo) do
		local fnCheckRequireFunc = self.tbCheckRequireFunc[szFunc];
		if not fnCheckRequireFunc then
			return false, "" .. szFunc .. " 未定义条件！";
		end

		local bOK, bRet, szMsg = Lib:CallBack({fnCheckRequireFunc, self, pPlayer, value});
		if not bOK or not bRet then
			return false, szMsg or "未知原因，无法完成任务！";
		end
	end

	return true, "", tbTask;
end

function Task:GetTaskTargetInfo(pPlayer, nTaskId)
	local tbPlayerTask = self:GetPlayerTaskInfo(pPlayer, nTaskId);
	if not tbPlayerTask then
		return;
	end

	tbPlayerTask.tbTargetInfo = tbPlayerTask.tbTargetInfo or {};
	return tbPlayerTask.tbTargetInfo;
end

function Task:GetTask(nTaskId)
	return self.tbAllTask[nTaskId];
end

function Task:GetTaskItem(nTaskId)
	return self.tbTaskItem[nTaskId];
end

function Task:GetCurMainTask(pPlayer)
	local tbPlayerTask = Task:GetPlayerTaskInfo(pPlayer);
	local tbCurInfo = tbPlayerTask.tbCurTaskInfo;

	for _, tbInfo in pairs(tbCurInfo) do
		local tbTask = Task:GetTask(tbInfo.nTaskId);
		if tbTask and tbTask.nTaskType == Task.TASK_TYPE_MAIN then
			return tbTask;
		end
	end

	return;
end

function Task:GetCurWLDSTask(pPlayer)
    local tbPlayerTask = Task:GetPlayerTaskInfo(pPlayer);
    local tbCurInfo = tbPlayerTask.tbCurTaskInfo;

    for _, tbInfo in pairs(tbCurInfo) do
        local tbTask = Task:GetTask(tbInfo.nTaskId);
        if tbTask and tbTask.nTaskType == Task.TASK_TYPE_WLDS then
            return tbTask;
        end
    end

    return;
end

function Task:GetTaskByNpcTemplateId(nNpcTemplateId)
	return self.tbTaskAttachNpc[nNpcTemplateId]
end

function Task:TraverseTask(fun, ...)
	for nTaskId in pairs(self.tbAllTask) do
		fun(nTaskId, ...);
	end
end

function Task:ForceAbortTask(pPlayer, nTaskId)
	local _, tbPlayerTask, nIndex = self:GetPlayerTaskInfo(pPlayer, nTaskId);
	if tbPlayerTask and nIndex then
		table.remove(tbPlayerTask.tbCurTaskInfo, nIndex);
	end

	if MODULE_GAMESERVER then
		pPlayer.CallClientScriptWhithPlayer("Task:ForceAbortTask", nTaskId);
	else
		Task:UpdateTaskInfo(nTaskId);
	end
end

function Task:CheckCanClientAccetp(nTaskId)
	local tbTask = self:GetTask(nTaskId);
	if not tbTask or tbTask.bClientAllow or not tbTask.bCanRepeat then
		return true;
	end

	return false;
end

function Task:CheckIsTaskTrap(pPlayer, nMapTemplateId, szTrapName)
	if self.tbTrap2TrackInfo[nMapTemplateId] and self.tbTrap2TrackInfo[nMapTemplateId][szTrapName] then
		return true;
	end

	return false;
end

function Task:GetTaskTrapTrack(pPlayer, nMapTemplateId, szTrapName)
	if not self.tbTrap2TrackInfo[nMapTemplateId] or not self.tbTrap2TrackInfo[nMapTemplateId][szTrapName] then
		return false;
	end

	local tbInfo = self.tbTrap2TrackInfo[nMapTemplateId][szTrapName];
	for nTaskId, szTrack in pairs(tbInfo) do
		local tbTask = self:GetPlayerTaskInfo(me, nTaskId);
		if tbTask then
			return true, szTrack;
		end
	end

	return false;
end

--请在有效期结束是手动检查 Task:CheckTaskValidTime(pPlayer)
function Task:SetValidTime2Task(pPlayer, nTaskId, nEndTime)
	local tbCurTask = self:GetPlayerTaskInfo(pPlayer, nTaskId);
    if not tbCurTask then
        return;
    end

    tbCurTask.nValidTime = nEndTime;
	if MODULE_GAMESERVER then
    	self:SavePlayerTaskInfo(pPlayer);
		pPlayer.CallClientScriptWhithPlayer("Task:SetValidTime2Task", nTaskId, nEndTime);
	end
end

function Task:CheckTaskValidTime(pPlayer)
	local tbTask         = pPlayer.GetScriptTable("Task");
	tbTask.tbRecord      = tbTask.tbRecord or {};
	tbTask.tbCurTaskInfo = tbTask.tbCurTaskInfo or {};
	local tb2RemoveTask  = {};
	local tbRemoveTaskId = {};
	for nIdx, tbInfo in ipairs(tbTask.tbCurTaskInfo) do
		if tbInfo.nValidTime and tbInfo.nValidTime <= GetTime() then
			table.insert(tb2RemoveTask, nIdx);
			table.insert(tbRemoveTaskId, tbInfo.nTaskId);
		end
	end
	if #tb2RemoveTask == 0 then
		return
	end

	for i = #tb2RemoveTask, 1, -1 do
		table.remove(tbTask.tbCurTaskInfo, tb2RemoveTask[i]);
	end
	if MODULE_GAMESERVER then
		self:SavePlayerTaskInfo(pPlayer);
		pPlayer.CallClientScriptWhithPlayer("Task:CheckTaskValidTime");
	else
		self:OnTaskTimeout(tbRemoveTaskId)
	end
end

Task.nMyZoneTaskId = 3302 					-- 打开我的空间
Task.nOtherZoneTaskId = 3303 				-- 打开玩家空间
Task.nWorldSquareTaskId = 3304 				-- 打开江湖广场
Task.tbZoneTaskRef = {}
local tbZoneTask = {Task.nMyZoneTaskId, Task.nOtherZoneTaskId, Task.nWorldSquareTaskId}
for _, nTaskId in ipairs(tbZoneTask) do
	Task.tbZoneTaskRef[nTaskId] = true
end
-- 个人空间任务加点检查
function Task:CheckZoneTaskAddExtPoint(nTaskId)
	if not self.tbZoneTaskRef[nTaskId] then
		return false, "不是个人空间任务"
	end
	local bRet, szMsg = self:CommonCheck(me, nTaskId, -1)
	if not bRet then
		return false, szMsg
	end
	if not Task:GetTaskTargetInfo(me, nTaskId) then
		return false, "还没有接该任务"
	end
	local nTaskState = Task:GetTaskState(me, nTaskId, -1)
	if nTaskState == self.STATE_CAN_FINISH then
		return false, "该任务已经可以提交"
	end
	return true
end

function Task:CanAcceptFirstJYFLTask(pPlayer)
	if not version_tx then
		return false
	end
	local nNowTime = GetTime()
	if nNowTime > self.nEndJYFLLimitTime then
		return false
	end
	if pPlayer.nLevel < Task.nAcceptJYFLMinLevel then
       return false
	end
	local nAcceptTime = pPlayer.GetUserValue(Task.SAVE_GROUP_JYFL, Task.FIRST_TASK_ACCEPT_TIME)
	if nAcceptTime > 0 then
		return false
	end
	local nTaskId
	if nNowTime > Task.nAcceptJYFLLimitTime then
		if self:GetTask(Task.nNewLineFirstTaskId or 0) then
			nTaskId = Task.nNewLineFirstTaskId
		end
	else
		nTaskId = Task.nFirstJYFLTaskId
	end
	nTaskId = nTaskId or 0
	if nTaskId == 0 then
		return false
	end
	if Task:HaveAcceptTask(pPlayer, nTaskId) then
		return false
	end
	return nTaskId
end

function Task:GetAllJYFLTask(pPlayer)
	local tbPlayerTask = Task:GetPlayerTaskInfo(pPlayer)
    local tbTaskId = {}
    local tbAllTaskId = {}
    for _, tbInfo in pairs(tbPlayerTask.tbCurTaskInfo) do
        local tbTask = Task:GetTask(tbInfo.nTaskId)
        if tbTask and tbTask.nTaskType == Task.TASK_TYPE_JYFL and Task.nLastJYFLTasjId ~= tbInfo.nTaskId then
        	-- 分流任务显示优先
        	local nSort = 1
        	if Task.nFlowTaskId and tbInfo.nTaskId == Task.nFlowTaskId then
        		nSort = 0
        	end
        	table.insert(tbAllTaskId, {nTaskId = tbInfo.nTaskId, nSort = nSort})
        end
    end
    table.sort(tbAllTaskId, function (a, b) return a.nSort > b.nSort end)
    for _, v in ipairs(tbAllTaskId) do
    	table.insert(tbTaskId, v.nTaskId)
    end
	return tbTaskId
end

function Task:IsJYFLTask(nTaskId)
	local tbTask = self:GetTask(nTaskId)
	if tbTask and tbTask.nTaskType == Task.TASK_TYPE_JYFL then
		return true
	end
	return false
end

function Task:GetCanAcceptFlowTask(pPlayer)
	if self:IsFinish(pPlayer, self.nFlowTaskId) or not Task:HaveAcceptTask(pPlayer, self.nFlowTaskId) then
		return {}
	end
	local tbTask = {}
	for nFlowType, v in ipairs(self.tbFlowSetting) do
		if not Task:HaveAcceptTask(pPlayer, v.nStartTaskId) and not self:IsFinish(pPlayer, v.nStartTaskId) then
			table.insert(tbTask, nFlowType)
		end
	end
	return tbTask
end

function Task:GetRunningFlowTaskType(pPlayer)
	for nFlowType, v in pairs(self.tbFlowSetting) do
		if (Task:HaveAcceptTask(pPlayer, v.nStartTaskId) or self:IsFinish(pPlayer, v.nStartTaskId)) and (not self:IsFinish(pPlayer, v.nEndTaskId)) then
			return nFlowType
		end
	end
end

function Task:IsFlowTaskEndId(nTaskId)
	for nFlowType, v in pairs(self.tbFlowSetting) do
		if v.nEndTaskId == nTaskId then
			return nFlowType
		end
	end
end

function Task:AllFlowTaskFinish(pPlayer)
	local bAllFinish = true
	for _, v in pairs(self.tbFlowSetting) do
		if not self:IsFinish(pPlayer, v.nEndTaskId) then
			bAllFinish = false
			break
		end
	end
	return bAllFinish
end

function Task:CheckAnswerFlowQuestion(pPlayer, nFlowType, tbAnswer, bNotCheckCost)
	local tbFlowInfo = self.tbFlowSetting[nFlowType]
	if not tbFlowInfo then
		return false, "未知类型"
	end
	local nQuestionTaskId = tbFlowInfo.nQuestionTaskId
	if not nQuestionTaskId then
		return false, "未知任务"
	end
	if not Task:HaveAcceptTask(pPlayer, nQuestionTaskId) then
		return false, "请先接取任务"
	end
	if self:IsFinish(pPlayer, nQuestionTaskId) then
		return false, "该任务已经完成"
	end
	local tbQuestion = self.tbFlowQuestion[nFlowType]
	if not tbQuestion then
		return false, "未知类型"
	end
	if #tbQuestion ~= #tbAnswer then
		return false, "请先回答所有问题"
	end
	local nAnswerCount = pPlayer.GetUserValue(self.Flow_Save_Group, nFlowType);
	if nAnswerCount >= self.nFlowQuestionCostCount then
		if not bNotCheckCost and pPlayer.GetMoney("Gold") < Task.nFlowQuestionCostGold then
			return false, "元宝不足"
		end
	end
	return true, "", nQuestionTaskId, tbQuestion
end

function Task:GetFlowQuestion(nFlowType)
	local szTitle = self.tbFlowSetting[nFlowType] and self.tbFlowSetting[nFlowType].szFlowQuestionTitle
	return self.tbFlowQuestion[nFlowType], szTitle
end

function Task:GetFlowAnswerCount(pPlayer, nFlowType)
	return pPlayer.GetUserValue(self.Flow_Save_Group, nFlowType)
end

function Task:GetBackPlayVideoType(pPlayer)
	local tbVideoType = {}
	for nVideoType, v in ipairs(Task.tbAllVideoTask) do
		if self:IsFinish(pPlayer, v.nTaskId) then
			table.insert(tbVideoType, nVideoType)
		end
	end
	return tbVideoType
end