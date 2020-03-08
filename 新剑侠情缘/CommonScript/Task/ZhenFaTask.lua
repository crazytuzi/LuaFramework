
-- 这个数字牵扯东西很多，要连同  CommonScript/DegreeCtrl.lua  里面的一起调整，最好找程序帮忙
ZhenFaTask.nMaxTaskCount = 5;			-- 每环任务个数

ZhenFaTask.nMinLevel = 80;
ZhenFaTask.szOpenTimeFrame = "OpenLevel89";

-- 各种任务类型
ZhenFaTask.ZHEN_FA_TYPE_SHE_JIAO = 1;		--社交强化
ZhenFaTask.ZHEN_FA_TYPE_CAI_HUA = 2;		--读条任务，采集同心花
ZhenFaTask.ZHEN_FA_TYPE_YAN_HUA = 3;		--读条任务，燃放烟花
ZhenFaTask.ZHEN_FA_TYPE_SHA_GUAI = 4;		--杀怪任务
ZhenFaTask.ZHEN_FA_TYPE_DUI_HUA = 5;		--Npc对话
ZhenFaTask.ZHEN_FA_TYPE_NPC_DA_TI = 6;		--NPC对话答题

-- 关系类型，最大不超过9个
ZhenFaTask.RELATIONSHIP_TYPE_NONE = 0;			--无关
ZhenFaTask.RELATIONSHIP_TYPE_MARRY = 1;			--结婚
ZhenFaTask.RELATIONSHIP_TYPE_SHI_TU = 2;		--师徒
ZhenFaTask.RELATIONSHIP_TYPE_JIE_BAI = 3;		--结拜
ZhenFaTask.RELATIONSHIP_TYPE_FRIEND = 4;		--好友

-- 详细关系类型
ZhenFaTask.RELATIONSHIP_SS_NONE = 0;		--无关
ZhenFaTask.RELATIONSHIP_SS_LOVER = 1;		--情缘
ZhenFaTask.RELATIONSHIP_SS_MARRY = 2;		--侠侣
ZhenFaTask.RELATIONSHIP_SS_SHI_FU = 3;		--师傅
ZhenFaTask.RELATIONSHIP_SS_TU_DI = 4;		--徒弟
ZhenFaTask.RELATIONSHIP_SS_JIE_BAI = 5;		--结拜
ZhenFaTask.RELATIONSHIP_SS_FRIEND = 6;		--好友

ZhenFaTask.tbSheJiaoTaskQuestion = {
	[ZhenFaTask.RELATIONSHIP_SS_LOVER] = "下列谁和你是情缘关系？";
	[ZhenFaTask.RELATIONSHIP_SS_MARRY] = "下列谁和你是侠侣关系？";
	[ZhenFaTask.RELATIONSHIP_SS_SHI_FU] = "下列谁是你的师傅？";
	[ZhenFaTask.RELATIONSHIP_SS_TU_DI] = "下列谁是你的徒弟？";
	[ZhenFaTask.RELATIONSHIP_SS_JIE_BAI] = "下面谁和你进行了义结金兰？";
	[ZhenFaTask.RELATIONSHIP_SS_FRIEND] = "下面谁和你是好友关系？";
}

ZhenFaTask.tbQuestionRightAward = {
	{"BasicExp", 30};
}

-- 正常任务奖励
ZhenFaTask.tbTaskAward = {
	{{"Item", 7533, 1}};			--第一环
	{{"Item", 7533, 1}};			--第二环
	{{"Item", 7533, 1}};			--第三环
	{{"Item", 7533, 1}};			--第四环
	{{"Item", 7533, 1}, {"Item", 7281, 1}};			--第五环
}

-- 队员跟随奖励
ZhenFaTask.tbOtherTaskAward = {
	{{"Item", 7534, 1}};			--第一环
	{{"Item", 7534, 1}};			--第二环
	{{"Item", 7534, 1}};			--第三环
	{{"Item", 7534, 1}};			--第四环
	{{"Item", 7534, 1}};			--第五环
}

ZhenFaTask.tbNpcId2DialogId = {

	[70088] = {
		[ZhenFaTask.RELATIONSHIP_SS_LOVER] = {50007};
	};

	[70089] = {
		[ZhenFaTask.RELATIONSHIP_SS_MARRY] = {50007};
	};

	[70090] = {
		[ZhenFaTask.RELATIONSHIP_SS_SHI_FU] = {50009};
	};

	[70091] = {
		[ZhenFaTask.RELATIONSHIP_SS_TU_DI] = {50010};
	};

	[70092] = {
		[ZhenFaTask.RELATIONSHIP_SS_JIE_BAI] = {50011};
	};

	[70093] = {
		[ZhenFaTask.RELATIONSHIP_SS_FRIEND] = {50012};
	};

}

ZhenFaTask.tbSkillEffect = {
	[70044] = {2309, 3511};
	[70045] = {2309, 3511};
};

ZhenFaTask.tbBlackBoardMsg = {
	[70044] = {"[FFFE0D]%s[-]惊喜地望着漫天烟花，洋溢着幸福的面庞让你看得出神……", "你惊喜地望着漫天烟花，洋溢着幸福的面庞让[FFFE0D]%s[-]看得出神……"};
	[70045] = {"[FFFE0D]%s[-]惊喜地望着漫天烟花，洋溢着幸福的面庞让你看得出神……", "你惊喜地望着漫天烟花，洋溢着幸福的面庞让[FFFE0D]%s[-]看得出神……"};
}

function ZhenFaTask:LoadSetting()
	self.tbTaskInfo = {};
	self.tbAllTask = {};
	local tbFile = LoadTabFile("Setting/Task/ZhenFaTaskList.tab", "ddd", nil, {"nTaskId", "nTaskType", "nRelation"});
	for _, tbRow in pairs(tbFile) do
		self.tbTaskInfo[tbRow.nTaskType] = self.tbTaskInfo[tbRow.nTaskType] or {};
		self.tbTaskInfo[tbRow.nTaskType][tbRow.nRelation] = self.tbTaskInfo[tbRow.nTaskType][tbRow.nRelation] or {};
		table.insert(self.tbTaskInfo[tbRow.nTaskType][tbRow.nRelation], tbRow.nTaskId);

		self.tbAllTask[tbRow.nTaskId] = {nTaskType = tbRow.nTaskType, nRelation = tbRow.nRelation};
	end

	self.tbRandomSetting = {};
	local szType = "d";
	local tbTitle = {"nRandomType"};
	for nType in pairs(ZhenFaTask.tbTaskInfo) do
		szType = szType .. "d";
		table.insert(tbTitle, tostring(nType));
	end
	tbFile = LoadTabFile("Setting/Task/ZhenFaTaskRandomType.tab", szType, nil, tbTitle);
	for _, tbInfo in pairs(tbFile) do
		assert(not self.tbRandomSetting[tbInfo.nRandomType]);

		local tbRate = {};
		local nTotalRate = 0;
		for nType in pairs(ZhenFaTask.tbTaskInfo) do
			local nValue = tbInfo[tostring(nType)] or 0;
			if nValue > 0 then
				nTotalRate = nTotalRate + nValue;
				table.insert(tbRate, {nType, nTotalRate});
			end
		end

		self.tbRandomSetting[tbInfo.nRandomType] = tbRate;
	end

	self.tbTaskSetting = {};
	tbFile = LoadTabFile("Setting/Task/ZhenFaTaskSetting.tab", "dddddd", nil, {"nTeamType", "nTask1", "nTask2", "nTask3", "nTask4", "nTask5"});
	for _, tbInfo in pairs(tbFile) do
		assert(self.tbRandomSetting[tbInfo.nTask1]);
		assert(self.tbRandomSetting[tbInfo.nTask2]);
		assert(self.tbRandomSetting[tbInfo.nTask3]);
		assert(self.tbRandomSetting[tbInfo.nTask4]);
		assert(self.tbRandomSetting[tbInfo.nTask5]);

		self.tbTaskSetting[tbInfo.nTeamType] = {tbInfo.nTask1, tbInfo.nTask2, tbInfo.nTask3, tbInfo.nTask4, tbInfo.nTask5};
	end

	self.tbAllQuestion = {};
	tbFile = LoadTabFile("Setting/Task/ZhenFaTaskQuestion.tab", "dsdssss", nil, 
										{"nQuestionId", "szQuestion", "nAnswerId", "szA1", "szA2", "szA3", "szA4"});

	for _, tbInfo in pairs(tbFile) do
		assert(not self.tbAllQuestion[tbInfo.nQuestionId]);
		self.tbAllQuestion[tbInfo.nQuestionId] = {
			tbQuestionInfo = {tbInfo.szQuestion, tbInfo.szA1, tbInfo.szA2, tbInfo.szA3, tbInfo.szA4};
			nAnswerId = tbInfo.nAnswerId;
		}
	end
end

ZhenFaTask:LoadSetting();

function ZhenFaTask:GetTeamRelationship(pPlayer)
	local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID);
	if not teamData or teamData.nCaptainID ~= pPlayer.dwID then
		return nil;
	end

	local tbAllRelationSSMember = {};
	local tbRelationship = {};
	local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID);
	for _, nPlayerId in pairs(tbMember) do
		if nPlayerId ~= pPlayer.dwID then
			local pOther = KPlayer.GetPlayerObjById(nPlayerId);
			if pOther then
				local nRelation, nSSRelation = ZhenFaTask:GetRelationship(pPlayer, pOther);
				if nRelation ~= ZhenFaTask.RELATIONSHIP_TYPE_NONE then
					table.insert(tbRelationship, nRelation);
				end

				tbAllRelationSSMember[nSSRelation] = tbAllRelationSSMember[nSSRelation] or {};
				table.insert(tbAllRelationSSMember[nSSRelation], nPlayerId);
			end
		end
	end

	if #tbRelationship <= 0 then
		return nil;
	end

	table.sort(tbRelationship, function (a, b)
		return a < b;
	end)

	local nRelation = 0;
	for _, nRel in pairs(tbRelationship) do
		nRelation = nRelation * 10 + nRel;
	end
	return nRelation, "", tbAllRelationSSMember;
end

function ZhenFaTask:GetRelationship(pPlayer, pOther)
	if Wedding:IsLover(pPlayer.dwID, pOther.dwID) then
		return ZhenFaTask.RELATIONSHIP_TYPE_MARRY, ZhenFaTask.RELATIONSHIP_SS_MARRY;
	end

	if BiWuZhaoQin:CheckIsLover(pPlayer.dwID, pOther.dwID) then
		return ZhenFaTask.RELATIONSHIP_TYPE_MARRY, ZhenFaTask.RELATIONSHIP_SS_LOVER;
	end

	local pTeacher, pStudent = TeacherStudent:_GetRelations(pPlayer, pOther);
	if pTeacher then
		if pTeacher.dwID == pOther.dwID then
			return ZhenFaTask.RELATIONSHIP_TYPE_SHI_TU, ZhenFaTask.RELATIONSHIP_SS_SHI_FU;
		else
			return ZhenFaTask.RELATIONSHIP_TYPE_SHI_TU, ZhenFaTask.RELATIONSHIP_SS_TU_DI;
		end
	end

	if SwornFriends:IsConnected(pPlayer.dwID, pOther.dwID) then
		return ZhenFaTask.RELATIONSHIP_TYPE_JIE_BAI, ZhenFaTask.RELATIONSHIP_SS_JIE_BAI;
	end

	if FriendShip:IsFriend(pPlayer.dwID, pOther.dwID) then
		return ZhenFaTask.RELATIONSHIP_TYPE_FRIEND, ZhenFaTask.RELATIONSHIP_SS_FRIEND;
	end

	return ZhenFaTask.RELATIONSHIP_TYPE_NONE, ZhenFaTask.RELATIONSHIP_SS_NONE;
end

function ZhenFaTask:GetTaskNextId(nRelation, tbAllRelationSSMember, nTaskIdx)
	local tbTaskInfo = self.tbTaskSetting[nRelation] or {};
	local nRandomType = tbTaskInfo[nTaskIdx];

	local nTaskType = ZhenFaTask.ZHEN_FA_TYPE_SHA_GUAI;
	if nRandomType and self.tbRandomSetting[nRandomType] then
		local tbInfo = self.tbRandomSetting[nRandomType];
		if #tbInfo == 1 then
			nTaskType = tbInfo[1][1];
		else
			local nRandom = MathRandom(tbInfo[#tbInfo][2]);
			for _, tb in pairs(tbInfo) do
				if nRandom <= tb[2] then
					nTaskType = tb[1];
					break;
				end
			end
		end
	end

	local tbAllSSType = {};
	for nSSType, tbPlayer in pairs(tbAllRelationSSMember) do
		if ZhenFaTask.tbTaskInfo[nTaskType][nSSType] and #ZhenFaTask.tbTaskInfo[nTaskType][nSSType] > 0 then
			table.insert(tbAllSSType, nSSType);
		end
	end

	if ZhenFaTask.tbTaskInfo[nTaskType][ZhenFaTask.RELATIONSHIP_SS_NONE] and 
		#ZhenFaTask.tbTaskInfo[nTaskType][ZhenFaTask.RELATIONSHIP_SS_NONE] >= 0 then

		table.insert(tbAllSSType, ZhenFaTask.RELATIONSHIP_SS_NONE);
	end

	local nSSType = tbAllSSType[MathRandom(#tbAllSSType)];
	local nOtherPlayerId = 0;
	local szPlayerName = "";
	if tbAllRelationSSMember[nSSType] then
		local nRandomId = MathRandom(#(tbAllRelationSSMember[nSSType]));
		nOtherPlayerId = tbAllRelationSSMember[nSSType][nRandomId];

		local tbRoleInfo = KPlayer.GetRoleStayInfo(nOtherPlayerId);
		szPlayerName = tbRoleInfo.szName;
	end

	local nIdx = MathRandom(#(ZhenFaTask.tbTaskInfo[nTaskType][nSSType]));
	return ZhenFaTask.tbTaskInfo[nTaskType][nSSType][nIdx], nOtherPlayerId, szPlayerName;
end

function ZhenFaTask:OnFinishTask(nTaskId)
	if not ZhenFaTask.tbAllTask[nTaskId] then
		return;
	end

	local nLastCount = DegreeCtrl:GetDegree(me, "ZhenFaTask");
	local nTaskIdx = ZhenFaTask.nMaxTaskCount - nLastCount;
	if not ZhenFaTask.tbTaskAward[nTaskIdx] then
		Log("[ZhenFaTask] OnFinishTask ERR ?? ZhenFaTask.tbTaskAward[nTaskIdx] is nil !!!", me.dwID, me.szAccount, me.szName, nTaskIdx, nTaskId);
		return;
	end

	if not DegreeCtrl:ReduceDegree(me, "ZhenFaTaskSelfAward", 1) then
		me.CenterMsg("领取数量已达上限", true)
		return
	end

	local bDoubleAward, szMsg, tbFinalAward = RegressionPrivilege:GetDoubleAward(me, "ZhenFaTask", ZhenFaTask.tbTaskAward[nTaskIdx])
	if szMsg then
		me.CenterMsg(szMsg, true)
	end

	me.SendAward(tbFinalAward, nil, true, Env.LogWay_ZhenFaAward)
	local tbMember = TeamMgr:GetMembers(me.dwTeamID);
	for _, nPlayerId in pairs(tbMember or {}) do
		local szMsg = nil;
		local pMember = KPlayer.GetPlayerObjById(nPlayerId);
		if pMember and nPlayerId ~= me.dwID then
			if DegreeCtrl:ReduceDegree(pMember, "ZhenFaTaskExtAward", 1) then
				pMember.SendAward(ZhenFaTask.tbOtherTaskAward[nTaskIdx], nil, true, Env.LogWay_ZhenFaOtherAward);
			end

			local nLast = DegreeCtrl:GetDegree(pMember, "ZhenFaTaskExtAward");
			szMsg = string.format("成功完成本次[FFFE0D]阵法试炼援助[-]！今日援助奖励获取剩余[FFFE0D]%s[-]次", nLast);
		elseif nPlayerId == me.dwID then
			szMsg = string.format("成功完成本次试炼！今日剩余[FFFE0D]%s[-]次", nLastCount);
		end

		if pMember and szMsg then
			pMember.SendBlackBoardMsg(szMsg);
		end
	end

	if self.tbSkillEffect[nTaskId] then
		local _, nX, nY = me.GetWorldPos();
		for _, nSkillId in pairs(self.tbSkillEffect[nTaskId]) do
			me.GetNpc().CastSkill(nSkillId, 1, nX, nY);
		end
	end

	if self.tbBlackBoardMsg[nTaskId] then
		local pOther = KPlayer.GetPlayerObjById(me.nZhenFaTaskOtherPlayerId or 0);
		if pOther then
			me.SendBlackBoardMsg(string.format(self.tbBlackBoardMsg[nTaskId][1], pOther.szName));
			pOther.SendBlackBoardMsg(string.format(self.tbBlackBoardMsg[nTaskId][2], me.szName));
		end
	end

	me.CallClientScript("AutoFight:ChangeState", 1);
	Log("[ZhenFaTask] OnFinishTask", me.dwID, me.szAccount, me.szName, nTaskIdx, nTaskId);

	if nLastCount <= 0 then
		me.SendBlackBoardMsg("大侠已完成今日的试练！", true);
	end

	self:DoNextTask(me, self.tbSkillEffect[nTaskId] and 3 or 2);
end

function ZhenFaTask:DoNextTask(pPlayer, nDealyTime)
	local nPlayerId = pPlayer.dwID;
	if nDealyTime and nDealyTime > 0 then
		Timer:Register(Env.GAME_FPS * nDealyTime + 1, function ()
			local pP = KPlayer.GetPlayerObjById(nPlayerId);
			if pP then
				self:DoNextTask(pP);
			end
		end)
		return;
	end

	local bRet, _, _, _, _, szOtherName = self:CheckCanAcceptTask(pPlayer);
	if not bRet and szOtherName then
		pPlayer.MsgBox("队员不在周围，试炼已中断，大侠是否前往活动日历重新接取？", {{"确认", function ()
			me.CallClientScript("Ui:OpenWindow", "CalendarPanel", 1, 48);
		end}, {"取消"}});
	else
		self:AcceptNewTask(pPlayer);
	end
end

function ZhenFaTask:CheckCanAcceptTaskCommon(pPlayer)
	if TimeFrame:GetTimeFrameState(self.szOpenTimeFrame) ~= 1 then
		return false, "活动尚未开放";
	end

	if pPlayer.nLevel < self.nMinLevel then
		return false, "少侠阅历不足";
	end

	local nTaskId = ZhenFaTask:GetZhenFaTask(pPlayer);
	if nTaskId then
		return false, "大侠已经接取试练任务";
	end

	local nLastCount = DegreeCtrl:GetDegree(pPlayer, "ZhenFaTask");
	if nLastCount <= 0 then
		return false, "大侠已完成今日的试练！";
	end

	return true, "", nLastCount;
end

function ZhenFaTask:CheckCanAcceptTaskByNpc(pPlayer)
	local bRet, szMsg, nLastCount = self:CheckCanAcceptTaskCommon(pPlayer);
	if not bRet then
		return false, szMsg;
	end

	local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID);
	if not teamData or teamData.nCaptainID ~= pPlayer.dwID then
		return false, "只有队长才可进行操作";
	end

	local nRelation, szMsg, tbAllRelationSSMember = self:GetTeamRelationship(pPlayer);
	if not nRelation then
		return false, "必须有侠侣、情缘、师徒、好友关系的侠士组队！";
	end

	if tbAllRelationSSMember[ZhenFaTask.RELATIONSHIP_SS_NONE] and #tbAllRelationSSMember[ZhenFaTask.RELATIONSHIP_SS_NONE] > 0 then
		return false, "有队员和队长不是侠侣、情缘、师徒、好友关系！";
	end

	return true, "", nLastCount, nRelation, tbAllRelationSSMember;
end

-- 服务端接口
function ZhenFaTask:CheckCanAcceptTask(pPlayer)
	local bRet, szMsg, nLastCount, nRelation, tbAllRelationSSMember = self:CheckCanAcceptTaskByNpc(pPlayer)
	if not bRet then
		return false, szMsg;
	end

	local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID);
	for _, nPlayerId in pairs(tbMember) do
		local pOther = KPlayer.GetPlayerObjById(nPlayerId);
		if not pOther then
			return false, "有个队员不在线，无法接取任务";
		end

		if pPlayer.nMapId ~= pOther.nMapId then
			return false, string.format("%s不在周围，无法接取任务", pOther.szName), nil, nil, nil, pOther.szName;
		end
	end

	return true, "", nLastCount, nRelation, tbAllRelationSSMember;
end

function ZhenFaTask:AcceptNewTask(pPlayer)
	local bRet, szMsg, nLastCount, nRelation, tbAllRelationSSMember = self:CheckCanAcceptTask(pPlayer);
	if not bRet then
		pPlayer.CenterMsg(szMsg);
		return;
	end

	local nTaskIdx = ZhenFaTask.nMaxTaskCount - nLastCount + 1;
	local nTaskId, nOtherPlayerId, szPlayerName;
	-- 尝试5次，防止连续出相同的任务，如果5次都是相同的，就认了吧
	for i = 1, 5 do
		nTaskId, nOtherPlayerId, szPlayerName = ZhenFaTask:GetTaskNextId(nRelation, tbAllRelationSSMember, nTaskIdx);
		if nTaskId and (not pPlayer.nLastZhenFaTaskId or pPlayer.nLastZhenFaTaskId ~= nTaskId) then
			pPlayer.nLastZhenFaTaskId = nTaskId;
			break;
		end
	end
	if not nTaskId or nTaskId <= 0 then
		Log("[ZhenFaTask] AcceptNewTask ERR ??", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName)
		return;
	end

	if not DegreeCtrl:ReduceDegree(pPlayer, "ZhenFaTask", 1) then
		pPlayer.SendBlackBoardMsg("大侠已完成今日的试练！", true);
		return;
	end

	pPlayer.nZhenFaTaskOtherPlayerId = nOtherPlayerId;
	pPlayer.CallClientScript("ZhenFaTask:SyncTaskPlayerName", nTaskId, szPlayerName)
	Task:DoAcceptTask(pPlayer, nTaskId, pPlayer.GetNpc().nId);
	Task:SetValidTime2Task(pPlayer, nTaskId, Lib:GetTodayZeroHour() + 24 * 3600 + 5 * 3600 - 5);
	Log("[ZhenFaTask] AcceptNewTask", pPlayer.dwID, pPlayer.szAccount, pPlayer.szName, nTaskIdx, nTaskId);
end

function ZhenFaTask:SyncTaskPlayerName(nTaskId, szPlayerName)
	self.nZhenFaTaskId = nTaskId;
	self.szPlayerName = szPlayerName;
end

function ZhenFaTask:GetQuestion(pPlayer, nTaskType)
	if nTaskType == ZhenFaTask.ZHEN_FA_TYPE_SHE_JIAO then
		local tbAllType = {};
		local _, _, tbAllRelationSSMember = ZhenFaTask:GetTeamRelationship(pPlayer);
		for nSSRelation in pairs(tbAllRelationSSMember or {}) do
			if nSSRelation ~= ZhenFaTask.RELATIONSHIP_SS_NONE then
				table.insert(tbAllType, nSSRelation);
			end
		end
		local nSSRelation = tbAllType[MathRandom(#tbAllType)];
		if not nSSRelation then
			return
		end

		local nOtherPlayerId = tbAllRelationSSMember[nSSRelation][MathRandom(#(tbAllRelationSSMember[nSSRelation]))];
		local tbRoleInfo = KPlayer.GetRoleStayInfo(nOtherPlayerId);
		local nAnswerId = MathRandom(4);
		local tbQuestion = {nSSRelation};
		local nTimeNow = GetTime();
		for i = 1, 4 do
			table.insert(tbQuestion, nAnswerId == i and tbRoleInfo.szName or nTimeNow);
		end
		return tbQuestion, nAnswerId;
	end

	if not self.tbAllQuestionIdx or not self.fnRandomQuestion then
		self.tbAllQuestionIdx = {};
		for nQuestionId in pairs(self.tbAllQuestion) do
			table.insert(self.tbAllQuestionIdx, nQuestionId);
		end
		self.fnRandomQuestion = Lib:GetRandomSelect(#self.tbAllQuestionIdx);
	end

	local nQuestionId = self.fnRandomQuestion();
	local tbQuestion = self.tbAllQuestion[nQuestionId];
	return nQuestionId, tbQuestion.nAnswerId;
end

function ZhenFaTask:OnZhenFaTaskDoNext(pPlayer, nNpcId, nTaskId)
	local teamData = TeamMgr:GetTeamById(pPlayer.dwTeamID);
	local tbMember = TeamMgr:GetMembers(pPlayer.dwTeamID);
	if not teamData or teamData.nCaptainID ~= pPlayer.dwID then
		pPlayer.CenterMsg("只有队长才可进行操作");
		return;
	end

	if Lib:CountTB(tbMember) <= 1 then
		pPlayer.CenterMsg("抱歉少侠，阵法试炼任务需组队完成");
		return;
	end

	local nTaskType = ZhenFaTask.tbAllTask[nTaskId].nTaskType;
	if nTaskType ~= ZhenFaTask.ZHEN_FA_TYPE_SHE_JIAO and 
		nTaskType ~= ZhenFaTask.ZHEN_FA_TYPE_NPC_DA_TI then
		return;
	end

	local tbAllRelationSSMember = nil;
	if not pPlayer.ZhenFaTaskQuestion or not pPlayer.nZhenFaTaskId or pPlayer.nZhenFaTaskId ~= nTaskId then
		local Question, nAnswer, tbSSMember = ZhenFaTask:GetQuestion(pPlayer, nTaskType);
		if not Question then
			pPlayer.CenterMsg("必须有侠侣、情缘、师徒、好友关系的侠士组队！");
			return
		end
		pPlayer.nZhenFaTaskId      = nTaskId;
		pPlayer.ZhenFaTaskQuestion = Question;
		pPlayer.nZhenFaTaskAwswer  = nAnswer;
		tbAllRelationSSMember      = tbSSMember;
	end

	local szPlayerName = "";
	local nDialogId = nil;
	if tbAllRelationSSMember then
		local tbAllSSType = {};
		for nSSType in pairs(tbAllRelationSSMember) do
			table.insert(tbAllSSType, nSSType);
		end

		local nSSType = tbAllSSType[MathRandom(#tbAllSSType)];

		local pNpc = KNpc.GetById(nNpcId);
		if pNpc then
			local nRandomId = MathRandom(#tbAllRelationSSMember[nSSType]);
			local nPlayerId = tbAllRelationSSMember[nSSType][nRandomId]
			if nPlayerId then
				local pOther = KPlayer.GetPlayerObjById(nPlayerId);
				if pOther then
					szPlayerName = pOther.szName;
				end
			end
			nDialogId = (self.tbNpcId2DialogId[pNpc.nTemplateId] or {})[nSSType];
		end
	end
	pPlayer.CallClientScript("ZhenFaTask:OnSyncQuestionInfo", nNpcId, nTaskId, pPlayer.ZhenFaTaskQuestion, nDialogId, szPlayerName);
end

function ZhenFaTask:OnSendAnswer(pPlayer, nTaskId, nAnswerId)
	if not pPlayer.nZhenFaTaskAwswer or
		not pPlayer.ZhenFaTaskQuestion or
		not pPlayer.nZhenFaTaskId or
		pPlayer.nZhenFaTaskId ~= nTaskId then

		return;
	end

	local tbTaskInfo = Task:GetTaskTargetInfo(pPlayer, nTaskId);
	if not tbTaskInfo then
		return;
	end

	Task:DoAddExtPoint(pPlayer, nTaskId, 1);
	Task:DoFinishTask(pPlayer, nTaskId, -1);

	if pPlayer.nZhenFaTaskAwswer == nAnswerId then
		pPlayer.SendAward(ZhenFaTask.tbQuestionRightAward, nil, true, Env.LogWay_ZhenFaQuestion);
	end

	pPlayer.CallClientScript("ZhenFaTask:OnSyncResult", pPlayer.nZhenFaTaskAwswer == nAnswerId and true or false, nAnswerId, pPlayer.nZhenFaTaskAwswer);

	pPlayer.ZhenFaTaskQuestion = nil;
	pPlayer.nZhenFaTaskId = nil;
	pPlayer.nZhenFaTaskAwswer = nil;
end

function ZhenFaTask:OnSyncResult(bRight, nSelect, nResult)
	if Ui:WindowVisible("QuestionAnswerPanel") then
		Ui("QuestionAnswerPanel"):OnSyncResult(bRight, nSelect, nResult);
	end
end

function ZhenFaTask:GetRandomName()
	self.tbRandomInfo = self.tbRandomInfo or {};
	self.tbRandomInfo[me.dwID] = self.tbRandomInfo[me.dwID] or {};

	local nToday = Lib:GetLocalDay(GetTime() - 4 * 3600);
	if not self.tbRandomInfo[me.dwID].nDay or self.tbRandomInfo[me.dwID].nDay ~= nToday then
		self.tbRandomInfo[me.dwID].nDay = nToday;
		self.tbRandomInfo[me.dwID].tbNameInfo = {};
		for i = 1, 4 do
			self.tbRandomInfo[me.dwID].tbNameInfo[i] = Player:GetRandomName(MathRandom(1), MathRandom(Faction.MAX_FACTION_COUNT));
		end
	end

	return self.tbRandomInfo[me.dwID].tbNameInfo;
end

function ZhenFaTask:OnSyncQuestionInfo(nNpcId, nTaskId, ZhenFaTaskQuestion, nDialogId, szPlayerName)
	self.szDialogPlayerName = szPlayerName;
	self.nLastDialogId = self.nLastDialogId or 0;

	nDialogId = nDialogId or 0;
	if self.nLastDialogId == nDialogId then
		nDialogId = 0;
	end

	local tbQuestionInfo = ZhenFaTaskQuestion;
	if type(ZhenFaTaskQuestion) == "number" then
		tbQuestionInfo = self.tbAllQuestion[ZhenFaTaskQuestion].tbQuestionInfo;
	else
		local nRelation = ZhenFaTaskQuestion[1];
		tbQuestionInfo[1] = ZhenFaTask.tbSheJiaoTaskQuestion[nRelation];
		
		local tbRandomName = self:GetRandomName();
		for i = 1, 4 do
			if type(tbQuestionInfo[i + 1]) == "number" then
				tbQuestionInfo[i + 1] = tbRandomName[i];
			end
		end
	end

	if nDialogId and nDialogId > 0 then
		Ui:OpenWindow("SituationalDialogue", "ShowNormalDialog", nDialogId, function ()
			Ui:OpenWindow("QuestionAnswerPanel", tbQuestionInfo, function (nSelect)
				RemoteServer.SendZhenFaTaskAnwser(nTaskId, nSelect);
			end);
		end);
	else
		Ui:OpenWindow("QuestionAnswerPanel", tbQuestionInfo, function (nSelect)
			RemoteServer.SendZhenFaTaskAnwser(nTaskId, nSelect);
		end);
	end
end

function ZhenFaTask:AutoPathToTaskNpc()
	local nIdx = self.nMaxTaskCount - DegreeCtrl:GetDegree(me, "ZhenFaTask");
	if nIdx > 1 and nIdx < 5 then
		RemoteServer.AcceptZhenFaTask();
	else
		Ui.HyperTextHandle:Handle("[url=npc:testtt, 88, 15]", 0, 0);
	end
end

function ZhenFaTask:GetZhenFaTask(pPlayer)
	local tbPlayerTask = Task:GetPlayerTaskInfo(pPlayer);
	if not tbPlayerTask then
		return nil;
	end

	for _, tbInfo in pairs(tbPlayerTask.tbCurTaskInfo or {}) do
		if self.tbAllTask[tbInfo.nTaskId] then
			return tbInfo.nTaskId;
		end
	end
	return nil;
end

function ZhenFaTask:GetZhenFaTaskInfo(nTaskId)
	if not nTaskId or not self.tbAllTask[nTaskId] then
		return;
	end

	local szName = "";
	if nTaskId == self.nZhenFaTaskId then
		szName = self.szPlayerName;
	end

	local szTitle, szDesc = Task:GetNormalTaskInfo(nTaskId);
	szTitle = szTitle .. string.format("(%s/%s)", self.nMaxTaskCount - DegreeCtrl:GetDegree(me, "ZhenFaTask"), self.nMaxTaskCount);
	szTitle = string.gsub(szTitle, "$ZFT", szName);
	szDesc = string.gsub(szDesc, "$ZFT", szName);

	return szTitle, szDesc;
end

if MODULE_GAMESERVER and not ZhenFaTask.nFinishTaskRegisterId then
	ZhenFaTask.nFinishTaskRegisterId = PlayerEvent:RegisterGlobal("FinishTask", ZhenFaTask.OnFinishTask, ZhenFaTask)
end

function ZhenFaTask:GetShowAward(nTaskId)
	if not nTaskId or not self.tbAllTask[nTaskId] then
		return;
	end

	local nIdx = self.nMaxTaskCount - DegreeCtrl:GetDegree(me, "ZhenFaTask");
	return ZhenFaTask.tbTaskAward[nIdx];
end