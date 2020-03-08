local tbUi   = Ui:CreateClass("Task");
local tbItem = Ui:CreateClass("TaskItem")

local tbRightPanel = 
{
	["Task"] = "mainpannle",
	["ValueCompose"] = "FragmentComposeMap",
	["WLDS"] = "TaskCenter",
}

tbUi.nCurSeqId = nil;		--当前选中的nSeqId(生命周期，打开特定界面开始,界面关闭结束)
tbUi.nCurPos = nil;			--当前解锁的位置(生命周期，打开特定界面开始,获得特效播完结束)

local szBaseHideIcon = "mask";
local szBaseHideIconEffect = "NewTask_texiao";

local fHideIconEffectDelay = 2;
local fFinishEffectDelay = 1.5;

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_UPDATE_TASK, 		self.OnTaskUpdate, self },
		{ UiNotify.emNoTIFY_SYNC_COMMERCE_DATA, self.OnTaskUpdate, self },
		{ UiNotify.emNOTIFY_SYNC_KDP_DATA, self.OnTaskUpdate, self },
--		{ UiNotify.emNOTIFY_VALUE_COMPOSE_FINISH, self.OnValueComposeFinish, self},
		{ UiNotify.emNOTIFY_LOVER_TASK_STATE_CHANGE, self.OnTaskUpdate, self },
	};

	return tbRegEvent;
end

tbUi.tbTitle = {{Task.TASK_TYPE_MAIN, "主线任务"}, {Task.TASK_TYPE_SUB, "支线任务"}, {Task.TASK_TYPE_DAILY, "日常任务"}}
function tbUi:InitHead()
	self.tbShowTask  = {};
	self.tbType2Idx  = {}
	self.tbHeadState = self.tbHeadState or {};
	self.tbWLDS      = Task:GetWLDSTask()
	self.tbPartnerCard = PartnerCard:GetAllTask(me)
	self.tbJYFL = {}
	local tbAllJYFL = Task:GetAllJYFLTask(me)
	if tbAllJYFL[1] then
		table.insert(self.tbJYFL, tbAllJYFL[1])
	end
	
	if next(self.tbWLDS) then
		table.insert(self.tbShowTask, 1, { { bHead = true, nType = Task.TASK_TYPE_WLDS, bOpened = self.tbHeadState[Task.TASK_TYPE_WLDS], szTitle = "武林大事" } })
	end
	if next(self.tbJYFL) then
		table.insert(self.tbShowTask, #self.tbShowTask + 1, { { bHead = true, nType = Task.TASK_TYPE_JYFL, bOpened = self.tbHeadState[Task.TASK_TYPE_JYFL], szTitle = "忘忧酒馆叁" } })
	end
	for _, tbInfo in ipairs(self.tbTitle) do
		local nTaskType = tbInfo[1]
		local nIdx = #self.tbShowTask + 1
		self.tbShowTask[nIdx] = { { bHead = true, nType = nTaskType, bOpened = self.tbHeadState[nTaskType], szTitle = tbInfo[2] } }
	end
	if next(self.tbPartnerCard) then
		table.insert(self.tbShowTask, { { bHead = true, nType = Task.TASK_TYPE_PARTNERCARD, bOpened = self.tbHeadState[Task.TASK_TYPE_PARTNERCARD], szTitle = "门客任务" } })
	end
	self.tbLoverTask = LoverTask:GetLoverTask(me)
	if self.tbLoverTask then
		local nSubIdx = 1
		for nIdx, v in pairs(self.tbShowTask) do
			if v[1].nType == Task.TASK_TYPE_SUB then
				nSubIdx = nIdx
				break
			end
		end
		table.insert(self.tbShowTask, nSubIdx + 1, { { bHead = true, nType = Task.TASK_TYPE_LOVER, bOpened = self.tbHeadState[Task.TASK_TYPE_LOVER], szTitle = "情缘任务" } })
	end
	for nIdx, v in pairs(self.tbShowTask) do
		self.tbType2Idx[v[1].nType] = nIdx
	end
end

function tbUi:GetTypeInx(nTaskType)
	--武林大事循环任务放在武林大事下面
	if nTaskType == Task.TASK_TYPE_WLDS_CYCLE then
		nTaskType = Task.TASK_TYPE_WLDS
	end
	return self.tbType2Idx[nTaskType]
end

function tbUi:InitSubTask()
	local tbPlayerTask 	= Task:GetPlayerTaskInfo(me);
	local tbCurInfo 	= tbPlayerTask.tbCurTaskInfo;
	for _, tbInfo in pairs(tbCurInfo) do
		local tbTask 	= Task:GetTask(tbInfo.nTaskId);
		if tbTask and tbTask.nTaskType ~= Task.TASK_TYPE_WLDS and tbTask.nTaskType ~= Task.TASK_TYPE_PARTNERCARD and tbTask.nTaskType ~= Task.TASK_TYPE_JYFL then
			local nType = tbTask.nTaskType;
			if tbTask.nTaskType == Task.TASK_TYPE_ZHEN_FA then
				nType = Task.TASK_TYPE_DAILY;
			end
			local nIdx = self:GetTypeInx(nType);
			table.insert(self.tbShowTask[nIdx], {nTaskId = tbInfo.nTaskId, szTitle = tbTask.szTaskTitle});
		end
	end

	for szKey, tbInfo in pairs(Task.tbDailyTaskSettings) do
		if tbInfo:IsInCurTaskList() then
			local nIdx = self:GetTypeInx(Task.TASK_TYPE_DAILY)
			table.insert(self.tbShowTask[nIdx], {szDailyKey = szKey, szTitle = tbInfo.szTitle});
		end
	end

	-- for _, nSeqId in ipairs(Compose.ValueCompose.tbShowData) do
	-- 	local tbSeqInfo = Compose.ValueCompose:GetSeqInfo(nSeqId);
	-- 	if tbSeqInfo then
	-- 		local nIdx = self:GetTypeInx(Task.TASK_TYPE_VALUE_COMPOSE)
	-- 		table.insert(self.tbShowTask[nIdx], {bIsValueCompose = true, nSeqId = nSeqId, szTitle = tbSeqInfo.szDirTitle});
	-- 	end
	-- end

	for nGroupIdx, tbInfo in ipairs(self.tbWLDS) do
		local nIdx = self:GetTypeInx(Task.TASK_TYPE_WLDS)
		table.insert(self.tbShowTask[nIdx], {nWLDSGroup = nGroupIdx, tbWLDSList = tbInfo.tbTaskList, szTitle = tbInfo.szTitle, nCurTaskId = tbInfo.nCurTaskId, bAllFinish = tbInfo.bAllFinish})
	end

	for _, nTaskId in ipairs(self.tbPartnerCard) do
		local nIdx = self:GetTypeInx(Task.TASK_TYPE_PARTNERCARD)
		local tbTask 	= Task:GetTask(nTaskId);
		if tbTask then
			table.insert(self.tbShowTask[nIdx], {nTaskId = nTaskId, szTitle = tbTask.szTaskTitle})
		end
	end

	for _, nTaskId in ipairs(self.tbJYFL) do
		local nIdx = self:GetTypeInx(Task.TASK_TYPE_JYFL)
		local tbTask 	= Task:GetTask(nTaskId);
		if tbTask then
			table.insert(self.tbShowTask[nIdx], {nTaskId = nTaskId, szTitle = tbTask.szTaskTitle})
		end
	end

	if self.tbLoverTask then
		local nIdx = self:GetTypeInx(Task.TASK_TYPE_LOVER)
		table.insert(self.tbShowTask[nIdx], {nTaskId = self.tbLoverTask[1], szTitle = self.tbLoverTask[2]})
	end
end

local function GetTaskType(tbTask)
	if not tbTask or not next(tbTask) then
		return;
	end

	if tbTask.nTaskId then
		if LoverTask:IsLoverTask(tbTask.nTaskId) then
			return Task.TASK_TYPE_LOVER
		else
			local _, _, nIdx = Task:GetPlayerTaskInfo(me, tbTask.nTaskId);
			if nIdx then
				local tbTaskInfo = Task:GetTask(tbTask.nTaskId) or {}
				return tbTaskInfo.nTaskType
			end
		end
		
	elseif tbTask.szDailyKey then
		local tbTaskInfo = Task.tbDailyTaskSettings[tbTask.szDailyKey];
		if tbTaskInfo.IsInCurTaskList() then
			return Task.TASK_TYPE_DAILY;
		end
	elseif tbTask.bIsValueCompose then
		return Task.TASK_TYPE_VALUE_COMPOSE;
	elseif tbTask.nType == Task.TASK_TYPE_WLDS or tbTask.nWLDSGroup then
		return Task.TASK_TYPE_WLDS
	end
end

function tbUi:CloseAllOpenTab()
	for _, tbInfo in ipairs(self.tbShowTask) do
		tbInfo[1].bOpened = false;
		self.tbHeadState[tbInfo[1].nType] = false;
	end
end

function tbUi:OpenTab(nTabType)
	local nIdx = self:GetTypeInx(nTabType)
	if self.tbShowTask[nIdx] then
		self.tbShowTask[nIdx][1].bOpened = true;
		self.tbHeadState[nIdx] = true;
	end
end

local tbType2Key = {[Task.emTASKTYPE_DAILY] = "szDailyKey", [Task.emTASKTYPE_SUB] = "nTaskId", [Task.emTASKTYPE_WLDS] = "nWLDSGroup"}
function tbUi:InitDefaultTask()
	self.tbDefault = self.tbDefault or {};
	if self.nOpenType and self.nOpenType == Task.TASK_TYPE_VALUE_COMPOSE then
		self:CloseAllOpenTab();
		self:OpenTab(Task.TASK_TYPE_VALUE_COMPOSE);
		self.tbDefault = {nSeqId = self.tbOpenParam[1], bIsValueCompose = true};
		self.nCurSeqId = self.tbOpenParam[1];
		self.nCurPos = self.tbOpenParam[2];
		self:HideComposeEffect();
	else
		local tbLatelyTask = Task:GetLatelyTask();
		if tbLatelyTask and next(tbLatelyTask) then
			local szKey = tbType2Key[tbLatelyTask[1]] or "szDailyKey";
			self.tbDefault = {};
			self.tbDefault[szKey] = tbLatelyTask[2];
		end

		local nType = GetTaskType(self.tbDefault);
		if nType then
			self.tbHeadState[nType] = true;
			local nIdx = self:GetTypeInx(nType)
			if nIdx then
				if nType == Task.TASK_TYPE_WLDS then
					for _, tbInfo in ipairs(self.tbWLDS) do
						if tbLatelyTask[2] == tbInfo.nGroupIdx then
							self.tbShowTask[nIdx][1].bOpened = self.tbHeadState[nType]
							self.nOpenType = self.nOpenType or Task.TASK_TYPE_WLDS
							return
						end
					end
				else
					self.tbShowTask[nIdx][1].bOpened = self.tbHeadState[nType];
					return;
				end
			end
		end

		--缓存的任务都已过期，默认的任务首选第一个活动，再没有就选主线
		local nDaily = self:GetTypeInx(Task.TASK_TYPE_DAILY)
		local nMain = self:GetTypeInx(Task.TASK_TYPE_MAIN)
		self.tbDefault = self.tbShowTask[nDaily][2] or self.tbShowTask[nMain][2];
		if self.tbDefault then
			local nType = GetTaskType(self.tbDefault);
			self.tbHeadState[nType] = true;
			local nIdx = self:GetTypeInx(nType) or 1
			self.tbShowTask[nIdx][1].bOpened = self.tbHeadState[nType];
		end
	end
end
-- ...参数
-- nOpenType 为 Task.TASK_TYPE_VALUE_COMPOSE {...} = {[1] = nSeqId,[2] = nPos} 


function tbUi:OnOpen(nType,...)
	self.nOpenType = nType;
	self.tbOpenParam = {...};

	Compose.ValueCompose:UpdateShowData();

	self:InitHead();
	self:InitSubTask();
	self:InitDefaultTask();

	self:Refresh();

	if self.nOpenType and self.nOpenType == Task.TASK_TYPE_VALUE_COMPOSE then		-- 打开特定界面
		self:UpdateComposePanel();
		self:UpdateRightPanelVisible(tbRightPanel.ValueCompose);
		if self.nCurPos then
			self:PlayGetEffect()
		end
	else
		local szPanel = self.nOpenType and self.nOpenType == Task.TASK_TYPE_WLDS and tbRightPanel.WLDS or tbRightPanel.Task
		self:UpdateRightPanelVisible(szPanel);
		self:UpdateDetailPanel();
	end
end

function tbUi:PlayGetEffect()
	local szHideIconName = szBaseHideIcon .. self.nCurPos
	local tbPos = self.pPanel:GetPosition(szHideIconName)
	self.pPanel:Tween_Play(szHideIconName, 0);
	self.pPanel:ChangePosition("NewTask_texiao9", tbPos.x, tbPos.y);
	self.pPanel:SetActive("NewTask_texiao9", true)
	Timer:Register(Env.GAME_FPS * fHideIconEffectDelay, self.OnGetEffectEnd, self);
end

function tbUi:OnGetEffectEnd()
	self.nCurPos = nil;			--控制隐藏碎片遮挡的图片
	self:UpdateComposePanel()
end

function tbUi:OnClose()
	local tbLatelyTask;
	if self.tbDefault.nTaskId then
		tbLatelyTask = { Task.emTASKTYPE_SUB, self.tbDefault.nTaskId };
	elseif self.tbDefault.nWLDSGroup then
		tbLatelyTask = { Task.emTASKTYPE_WLDS, self.tbDefault.nWLDSGroup };
	else
		tbLatelyTask = { Task.emTASKTYPE_DAILY, self.tbDefault.szDailyKey };
	end
	Task:SetLatelyTask(tbLatelyTask);
	Compose.ValueCompose:CheckShowRedPoint();
	self.pPanel:SetActive("MapBg", false);
end

function tbUi:Refresh()
	local fnOnSelect = function(itemObj)
		local tbTask = self:GetTask(itemObj._nIdx);
		if tbTask.bHead then
			itemObj.pPanel:SetActive("ArrowDown", not tbTask.bOpened);
			itemObj.pPanel:SetActive("ArrowUp", tbTask.bOpened);
		end
		self:OnSelectTask(itemObj._nIdx);
	end

	local bComposeHasFinish = Compose.ValueCompose:CheckShowRedPoint();

	local nType = GetTaskType(self.tbDefault)
	local fnInit = function (itemObj, nIdx)
		local tbTask = self:GetTask(nIdx);
		itemObj.pPanel:SetActive("TaskChapter", tbTask.bHead);
		itemObj.pPanel:SetActive("TaskSections", not tbTask.bHead);
		if tbTask.bHead then
			local nIdx = self:GetTypeInx(tbTask.nType)
			local bArrowActive = #self.tbShowTask[nIdx] > 1;
			itemObj.pPanel:SetActive("ArrowUp", bArrowActive and tbTask.bOpened);
			itemObj.pPanel:SetActive("ArrowDown", bArrowActive and not tbTask.bOpened);

			itemObj.pPanel:SetActive("New1", tbTask.nType == Task.TASK_TYPE_VALUE_COMPOSE and bComposeHasFinish);
			local szSprite = "BtnListMainNormal";
			if tbTask.nType == Task.TASK_TYPE_WLDS then
				szSprite = "BtnWulin01"
			end
			itemObj.pPanel:Sprite_SetSprite("TaskChapter", szSprite);
			itemObj.pPanel:Button_SetSprite("TaskChapter", szSprite);

			itemObj.pPanel:Label_SetText("TaskChapterTitle", tbTask.szTitle);
			itemObj.pPanel:Label_SetText("TaskChapterTitleLight", tbTask.szTitle);
			itemObj.pPanel:SetActive("TaskChapterTitleLight", tbTask.nType == nType)
			itemObj.pPanel:SetActive("TaskChapterTitle", tbTask.nType ~= nType)
		else
			local nThisType = GetTaskType(tbTask);
			local bCurTask  = nType == nThisType and tbTask.nWLDSGroup == self.tbDefault.nWLDSGroup and tbTask.nTaskId == self.tbDefault.nTaskId and tbTask.szDailyKey == self.tbDefault.szDailyKey and tbTask.nSeqId == self.tbDefault.nSeqId
			local szSprite  = nThisType == Task.TASK_TYPE_WLDS and "BtnWulinson" or "BtnListSecond"
			local szPress   = nThisType == Task.TASK_TYPE_WLDS and "02" or "Press"
			local szNormal  = nThisType == Task.TASK_TYPE_WLDS and "01" or "Normal"
			szSprite = szSprite .. (bCurTask and szPress or szNormal);
			itemObj.pPanel:Sprite_SetSprite("TaskSections", szSprite);
			itemObj.pPanel:Button_SetSprite("TaskSections", szSprite);

			itemObj.pPanel:Label_SetText("TaskSectionsTitle", tbTask.szTitle);
			local bRedPoint = false;
			if nThisType == Task.TASK_TYPE_VALUE_COMPOSE and Compose.ValueCompose:CheckIsFinish(me, tbTask.nSeqId, true) then
				bRedPoint = true;
			end
			itemObj.pPanel:SetActive("New2", bRedPoint);
			itemObj.pPanel:SetActive("Mark1", tbTask.nCurTaskId and true or false);
			itemObj.pPanel:SetActive("Mark2", tbTask.bAllFinish and true or false);
		end
		itemObj._nIdx = nIdx;
		itemObj.fnOnSelect = fnOnSelect
	end

	self.ScrollView:UpdateItemHeight(self:GetShowHeight());
	self.ScrollView:Update(self:GetShowTaskNum(), fnInit);
end

function tbUi:GetShowTaskNum()
	local nNum = #self.tbShowTask;
	for _, tbTaskGroup in ipairs(self.tbShowTask) do
		if tbTaskGroup[1].bOpened then
			nNum = nNum + #tbTaskGroup - 1;
		end
	end

	return nNum;	
end

function tbUi:GetShowHeight()
	local tbHeight = {};
	for _, tbTaskGroup in ipairs(self.tbShowTask) do
		table.insert(tbHeight, 80);
		if tbTaskGroup[1].bOpened then
			for i = 1, (#tbTaskGroup - 1) do
				table.insert(tbHeight, 60);
			end
		end
	end
	return tbHeight;
end

function tbUi:GetTask(nIdx)
	for _, tbTaskGroup in ipairs(self.tbShowTask) do
		if tbTaskGroup[1].bOpened then
			if nIdx <= #tbTaskGroup then
				return tbTaskGroup[nIdx];
			end
			nIdx = nIdx - #tbTaskGroup;
		else
			if 1 == nIdx then
				return tbTaskGroup[1];
			end
			nIdx = nIdx - 1;
		end
	end
end

function tbUi:HideComposeEffect()
	self.pPanel:SetActive("NewTask_texiao2",false)
	self.pPanel:SetActive("NewTask_texiao9",false)
end

function tbUi:OnSelectTask(nIdx)
	local tbSelTask = self:GetTask(nIdx);
	if tbSelTask.bHead then
			local nIdx = self:GetTypeInx(tbSelTask.nType)
			local nTaskNum = #self.tbShowTask[nIdx];
			self.tbHeadState[tbSelTask.nType] = (nTaskNum > 1) and (not self.tbHeadState[tbSelTask.nType]) or false;
			tbSelTask.bOpened = self.tbHeadState[tbSelTask.nType];
			if nTaskNum <= 1 then
				if tbSelTask.nType == Task.TASK_TYPE_VALUE_COMPOSE then
					--显示提示对话
					me.CenterMsg("当前没有碎片线索")
				else
					local tbTitle = {"主线", "支线", "日常","神秘碎片"}
					local szMsg   = string.format("当前没有【%s】任务", tbTitle[tbSelTask.nType] or "主线")
					me.CenterMsg(szMsg)
				end
			end
	else
		if tbSelTask.bIsValueCompose then			--碎片合成处理
			self.nCurSeqId = tbSelTask.nSeqId
			self.tbDefault = {nSeqId = tbSelTask.nSeqId, bIsValueCompose = true};
			self:UpdateComposePanel(tbSelTask);
			self:UpdateRightPanelVisible(tbRightPanel.ValueCompose);
			self:HideComposeEffect()
		else
			self.tbDefault = {nWLDSGroup = tbSelTask.nWLDSGroup, nTaskId = tbSelTask.nTaskId, szDailyKey = tbSelTask.szDailyKey};
			self:UpdateDetailPanel(tbSelTask);
			local szPanel = tbSelTask.nWLDSGroup and tbRightPanel.WLDS or tbRightPanel.Task
			self:UpdateRightPanelVisible(szPanel);
		end
	end
	self:Refresh()
end

function tbUi:GetTaskDesc(tbTask)
	local szTaskDesc, szDetailDesc = "", "";
	local bGiveUp, bAwards;
	if tbTask.nTaskId then
		if LoverTask:IsLoverTask(tbTask.nTaskId) then
			local tbLoverTask =LoverTask:GetLoverTask(me)
			szTaskDesc = tbLoverTask and tbLoverTask[3]
			szDetailDesc = tbLoverTask and tbLoverTask[4]
			bGiveUp = true
			bAwards= tbLoverTask and tbLoverTask[5]
		else
			local tbTaskInfo = Task:GetTask(tbTask.nTaskId);

			szTaskDesc 		= tbTaskInfo.szTaskDesc .. Task:GetTaskExtInfo(nTaskId);
			szDetailDesc 	= tbTaskInfo.szDetailDesc;

			bGiveUp 		= false;	--TODO任务可放弃后需修改
			bAwards 		= Task.KinTask.tbTask2Type[tbTask.nTaskId] and true or #tbTaskInfo.tbAward > 0;
			if tbTask.nTaskId == ZhenFaTask.nZhenFaTaskId then
				szDetailDesc = string.gsub(szDetailDesc, "$ZFT", ZhenFaTask.szPlayerName or "");
				szTaskDesc = string.gsub(szTaskDesc, "$ZFT", ZhenFaTask.szPlayerName or "");
			end

			if ZhenFaTask.tbAllTask[tbTask.nTaskId] then
				bAwards = true;
			end
		end
	elseif tbTask.szDailyKey then
		local tbDaily 	= Task.tbDailyTaskSettings[tbTask.szDailyKey];
		szTaskDesc 		= tbDaily.szTarget;
		szDetailDesc 	= tbDaily.szMsg;
		bGiveUp 		= tbDaily.OnGiveUp;
		bAwards 		= tbDaily.bShowAwards;
	elseif tbTask.nCurTaskId then
		local tbTaskInfo = Task:GetTask(tbTask.nCurTaskId);

		szTaskDesc 		= tbTaskInfo.szTaskDesc .. Task:GetTaskExtInfo(nCurTaskId);
		szDetailDesc 	= tbTaskInfo.szDetailDesc;
		bGiveUp 		= false;	--TODO任务可放弃后需修改
		bAwards 		= Task.KinTask.tbTask2Type[tbTask.nCurTaskId] and true or #tbTaskInfo.tbAward > 0;
	end
	return szTaskDesc, szDetailDesc, bGiveUp, bAwards;
end

function tbUi:ClearDetailPanel()
	self.pPanel:Label_SetText("TaskTarget", "");
	self.pPanel:Label_SetText("TaskMsg", "");
	self.pPanel:SetActive("BtnGiveUp", false);
	self.pPanel:SetActive("AwardsGroup", false);
	self.pPanel:SetActive("TextContent", false);
	self.pPanel:SetActive("mainpannle2", false);
end

function tbUi:UpdateDetailPanel(tbTask)
	tbTask = tbTask or self.tbDefault;
	if not tbTask or not next(tbTask) then
		self:ClearDetailPanel();
		return;
	end
	self.pPanel:SetActive("TextContent", false);
	self.pPanel:SetActive("mainpannle2", false);
	self.pPanel:SetActive("Spannle_New", Task:IsJYFLTask(tbTask.nTaskId or 0));
	if tbTask.nTaskId or tbTask.szDailyKey then
		local szTaskDesc, szDetailDesc, bGiveUp, bAwards = self:GetTaskDesc(tbTask);
		self.pPanel:Label_SetText("TaskTarget", szTaskDesc);
		self.pPanel:Label_SetText("TaskMsg", szDetailDesc);
		self.pPanel:SetActive("BtnGiveUp", bGiveUp);
		self.pPanel:SetActive("AwardsGroup", bAwards);
	end

	if tbTask.nTaskId then
		if LoverTask:IsLoverTask(tbTask.nTaskId) then
			self.tbOnClick.BtnGiveUp = function ()
				LoverTask:GiveUpTask()
			end
			self.tbOnClick.BtnGo = function ()
				Ui:CloseWindow("Task");
				LoverTask:TrackTask()
			end
			local tbLoverTask = LoverTask:GetLoverTask(me)
			Lib:ShowTB(tbLoverTask)
 			local tbAward = tbLoverTask and tbLoverTask[5]
			self:UpdateItemFrame(tbAward or {});
		else
			local tbTaskInfo = Task:GetTask(tbTask.nTaskId);
			local tbAward = ZhenFaTask:GetShowAward(tbTask.nTaskId) or tbTaskInfo.tbAward;
			if Task.KinTask.tbTask2Type[tbTask.nTaskId] then
				tbAward = Task.KinTask:GetShowTask(me);
			end

			self:UpdateItemFrame(tbAward);
			self.tbOnClick.BtnGo = function ()
				Ui:CloseWindow("Task");
				Task:OnTrack(tbTaskInfo.nTaskId);
				Task:OnTaskUpdate(tbTaskInfo.nTaskId);
				UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_TASK, nTaskId);
			end
		end
	elseif tbTask.szDailyKey then
		local tbDaily = Task.tbDailyTaskSettings[tbTask.szDailyKey];
		if tbDaily.OnGiveUp then
			self.tbOnClick.BtnGiveUp = function ()
				Ui:CloseWindow("Task");
				tbDaily.OnGiveUp();
			end
		end
		self.tbOnClick.BtnGo = function ()
			Ui:CloseWindow("Task");
			tbDaily.OnTrack();
		end
		if tbDaily.tbAward then
			self:UpdateItemFrame(tbDaily.tbAward)
		end
	elseif tbTask.nWLDSGroup then
		local szContent = ""
		for nGroupIdx, tbInfo in ipairs(self.tbWLDS) do
			if nGroupIdx == tbTask.nWLDSGroup then
				if tbInfo.nCurTaskId then
					self.pPanel:SetActive("mainpannle2", true);
					local szTaskDesc, szDetailDesc, bGiveUp, bAwards = self:GetTaskDesc(tbInfo);
					self.pPanel:Label_SetText("TaskTarget2", szTaskDesc);
					self.pPanel:Label_SetText("TaskMsg2", szDetailDesc);
					self.pPanel:SetActive("BtnGiveUp2", bGiveUp);
					self.pPanel:SetActive("AwardsGroup2", bAwards);

					local tbTaskInfo = Task:GetTask(tbInfo.nCurTaskId);
					local tbAward = tbTaskInfo.tbAward;
					if Task.KinTask.tbTask2Type[tbInfo.nCurTaskId] then
						tbAward = Task.KinTask:GetShowTask(me);
					end

					self:UpdateItemFrame(tbAward, "itemframeWL");
					self.tbOnClick.BtnGo2 = function ()
						Ui:CloseWindow("Task");
						Task:OnTrack(tbTaskInfo.nTaskId);
						Task:OnTaskUpdate(tbTaskInfo.nTaskId);
						UiNotify.OnNotify(UiNotify.emNOTIFY_UPDATE_TASK, tbTaskInfo.nTaskId);
					end
				elseif tbInfo.bAllFinish then
					self.pPanel:SetActive("TextContent", true);
					local tbDes = {}
					for _, nTaskId in ipairs(tbInfo.tbTaskList) do
						local tbTaskInfo = Task:GetTask(nTaskId)
						if tbTaskInfo then
							local szTaskDesc = "      " ..tbTaskInfo.szDetailDesc .. Task:GetTaskExtInfo(nTaskId)
							table.insert(tbDes, szTaskDesc)
						end
					end
					szContent = table.concat(tbDes, "\n\n")
				end
				break
			end
		end
		self.Content:SetLinkText(szContent)
		local tbTextSize = self.pPanel:Label_GetPrintSize("Content")
    	local tbSize = self.pPanel:Widget_GetSize("datagroup")
    	self.pPanel:Widget_SetSize("datagroup", tbSize.x, 50 + tbTextSize.y)
    	self.pPanel:DragScrollViewGoTop("datagroup")
    	self.pPanel:UpdateDragScrollView("datagroup")
	end
end

function tbUi:UpdateItemFrame(tbAwards, szUiName)
	szUiName = szUiName or "itemframe"
	local nAwardLen = 0;
	for nIdx, tbInfo in ipairs(tbAwards) do
		local szItName = szUiName .. nIdx;
		self.pPanel:SetActive(szItName, true);
		self[szItName]:SetGenericItem(tbInfo);
		nAwardLen = nAwardLen + 1;
		self[szItName].fnClick = self[szItName].DefaultClick;
	end

	for nIdx = nAwardLen + 1, 6 do
		if self[szUiName .. nIdx] then
			self.pPanel:SetActive(szUiName .. nIdx, false);
		else
			break;
		end
	end
end

function tbUi:UpdateComposePanel(tbTask)
	tbTask = tbTask or self.tbDefault;
	local nSeqId = tbTask.nSeqId;
	if not nSeqId or nSeqId == 0 then		--已经没有要显示的东西，则隐藏碎片Panel
		self.pPanel:SetActive(tbRightPanel.ValueCompose,false)
		return ;
	end
	local tbSeqInfo = Compose.ValueCompose:GetSeqInfo(nSeqId);
	if not tbSeqInfo or not next(tbSeqInfo) then
		return ;
	end
	local nValueCount = tbSeqInfo.nAllCount;
	local szDes = "";
	local nDesPos = Compose.ValueCompose:GetHaveValueNum(me,nSeqId);
	for nPos=1,nValueCount do
		local szHideIcon = szBaseHideIcon ..nPos;

		self.pPanel:SetActive(szHideIcon,true);
		self.pPanel:Tween_Disable(szHideIcon);
		self.pPanel:Widget_ChangeAlpha(szHideIcon, 1);

		if Compose.ValueCompose:CheckIsHaveValue(me,nSeqId,nPos) then
			self.pPanel:SetActive(szHideIcon,false);
		end
		if self.nCurPos and self.nCurPos == nPos then	--先盖住获得的碎片，特效播完再显示出来
			self.pPanel:SetActive(szHideIcon,true);
		end
	end

	szDes = tbSeqInfo["szItemDes" ..nDesPos] or "";
	self.pPanel:Label_SetText("Tip", szDes);

	local szTexturePath = tbSeqInfo.szBGMapPath
	self.pPanel:Texture_SetTexture("MapBg", szTexturePath)
	self.pPanel:SetActive("MapBg", true);
	local bIsFinish = Compose.ValueCompose:CheckIsFinish(me,nSeqId,true)
	self.pPanel:SetActive("BtnCompose", bIsFinish);
end

function tbUi:OnTaskUpdate()
	Ui:OpenWindow(self.UI_NAME);
end

function tbUi:UpdateRightPanelVisible(szShowPanel)
	for _,szPanelName in pairs(tbRightPanel) do
		self.pPanel:SetActive(szPanelName,false)
	end
	self.pPanel:SetActive(szShowPanel,true)
end

tbUi.tbOnClick = 
{
	BtnClose = function ()
		Ui:CloseWindow("Task");
	end;

	BtnGiveUp = function ()
	end;

	BtnGo = function ()
	end;

	BtnGo2 = function ()
	end;

	BtnCompose = function (self)
		if not self.nCurSeqId then
			me.CenterMsg("请选择需要合成的物品");
			return;
		end

		self.pPanel:SetActive("BtnCompose", false);
		self.pPanel:SetActive("NewTask_texiao2", false);
		self.pPanel:SetActive("NewTask_texiao2", true);
		Timer:Register(Env.GAME_FPS * fFinishEffectDelay, function ()
			Compose.ValueCompose:TryComposeValue(self.nCurSeqId);
		end)
	end;
};

function tbUi:OnValueComposeFinish(nNextSeqId,nFinishSeqId)
	self.nCurSeqId = nNextSeqId;					--特效播完显示下一个碎片
	self:InitHead();
    self:InitSubTask();
	self.tbDefault = {nSeqId = self.nCurSeqId, bIsValueCompose = true};
	self:Refresh();
	self:UpdateComposePanel();
	local nTempleteId = Compose.ValueCompose:GetSeqTempleteId(nFinishSeqId);
	local szName = "";
	if nTempleteId then
		local pItem = KItem.GetItemBaseProp(nTempleteId);
		if pItem then
			szName = pItem.szName;
		end
	end
	me.CenterMsg(string.format("恭喜合成【%s】",szName));
end

tbItem.tbOnClick = {
	TaskChapter = function (self)
		self.fnOnSelect(self)
	end,
	TaskSections = function (self)
		self.fnOnSelect(self)
	end,
}