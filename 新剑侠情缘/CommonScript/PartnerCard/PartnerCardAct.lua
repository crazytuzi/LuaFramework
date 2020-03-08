PartnerCard.tbMaxLiveHouse = {4,4,4,4,4,4,4}		-- 最大入住等级家园数量
PartnerCard.tbMaxVisitHouse = {2,2,2,2,2,2,2}		-- 最大拜访等级家园数量			
PartnerCard.CARD_ACT_STATE_NONE = 0 				-- 空闲
PartnerCard.CARD_ACT_STATE_VISIT = 1 				-- 拜访
PartnerCard.CARD_ACT_STATE_TRIP = 2 				-- 游历
PartnerCard.CARD_ACT_STATE_MUSE = 3 				-- 冥想
PartnerCard.CARD_ACT_STATE_END = 4 					-- 结束类型

PartnerCard.STATE_TRIP_NONE = 0 					-- 无
PartnerCard.STATE_TRIP_MAP = 1 						-- 游历地图
PartnerCard.STATE_TRIP_FUBEN = 2 					-- 游历副本

PartnerCard.tbStateTripMapRate =  					-- 游历地图触发概率
{
	[1] = 100;
	[2] = 100;
	[3] = 100;
	[4] = 100;
}		
PartnerCard.tbStateTripFubenRate =  				-- 游历副本触发概率
{
	[1] = 100;
	[2] = 100;
	[3] = 100;
	[4] = 100;
}		
PartnerCard.STATE_TRIP_TOTAL_RATE = 1000 			-- 游历事件总概率

PartnerCard.STATE_TRIP_MAP_NPC_RATE = 10000 		-- 游历地图触发NPC概率
PartnerCard.STATE_TRIP_MAP_NPC_TOTAL_RATE = 10000 	-- 游历地图触发NPC总概率
-- 游历副本触发时间 = 游历开始时间算起的PartnerCard.STATE_TRIP_FUBEN_BEGIN_TIME ~ PartnerCard.CARD_ACT_ACTIVE_TIME - PartnerCard.STATE_TRIP_FUBEN_STAY_TIME之间
PartnerCard.STATE_TRIP_FUBEN_STAY_TIME = 60 * 60    -- 游历副本持续时间
PartnerCard.STATE_TRIP_FUBEN_BEGIN_TIME = 1 		-- 游历副本随机开始时间
PartnerCard.nTripMapNpcAddExp = 30 					-- 游历地图NPC增加的友好度
PartnerCard.tbripMapNpcAward = {{"BasicExp", 15}}   -- 游历地图NPC玩家奖励

PartnerCard.CARD_ACT_ACTIVE_TIME = 24*60*60         -- 派遣持续时间
PartnerCard.DEFAULT_TALK = "吾浪荡江湖多年，终于找到了个落脚的地方，此处静谧，吾甚是喜欢。" 				-- 默认泡泡
PartnerCard.HOUSE_NPC_TALK_INTERVAL = 10 			-- 泡泡间隔时间
PartnerCard.HOUSE_NPC_TALK_TIME = "5" 				-- 泡泡持续时间

PartnerCard.TYPE_QUESTION = 1 						-- 拜访提问
PartnerCard.TYPE_ANSWER = 2 						-- 拜访回答

PartnerCard.nKorBubbleMax = 30
PartnerCard.nKorBubbleMin = 3
PartnerCard.nVNBubbleMax = 30
PartnerCard.nVNBubbleMin = 3
PartnerCard.nTHBubbleMax = 30
PartnerCard.nTHBubbleMin = 3
PartnerCard.nBubbleMax = 30
PartnerCard.nBubbleMin = 3

PartnerCard.NPC_TYPE_VISIT = "VisitNpc" 			--拜访npc类型
PartnerCard.NPC_TYPE_LIVE = "LiveNpc" 				-- 入住npc类型
PartnerCard.NPC_TYPE_TRIP_FUBEN = "TripFubenNpc" 	-- 游历副本npc类型
PartnerCard.NPC_TYPE_TRIP_MAP = "TripMapNpc" 		-- 游历地图npc类型

PartnerCard.tbVisitRightAward = {{"ZhenQi", 200}}	-- 回答拜访问题正确奖励

PartnerCard.VISIT_NOTIFY_TIME = 24*60*60 			-- 拜访家园感叹号持续时间

PartnerCard.EFFECT_MUSE = 5141 						-- 冥想特效
PartnerCard.EFFECT_DEVIL = 5142						-- 入魔特效
PartnerCard.tbTriggerDevilRate = 					-- 触发入魔概率
{
	[1] = 50;
	[2] = 50;
	[3] = 50;
} 				
PartnerCard.nTriggerDevilTotalRate = 1000 			-- 触发入魔总概率
PartnerCard.nDevilStayTime = 60 * 60 				-- 入魔持续时间
PartnerCard.nDevilBeginTime = 1 					-- 入魔触发随机开始时间
PartnerCard.nDevilChangeStateInterval = 10 			-- 改变状态间隔时间

PartnerCard.DEVIL_STATE_HOT = 1 					-- 燥热
PartnerCard.DEVIL_STATE_LOST = 2 					-- 错乱
PartnerCard.DEVIL_STATE_FEAR = 3 					-- 恐惧
PartnerCard.DEVIL_STATE_MAX = 4 					-- 最大状态
PartnerCard.DEVIL_INIT_LIFE = 50 					-- 初始生命值
PartnerCard.DEVIL_MAX_LIFE = 100 					-- 最大生命值
PartnerCard.DEVIL_MAX_CURE = 15 					-- 玩家最大可制服门客数量
PartnerCard.DEVIL_CURE_WAIT = 6 					-- 点击制服等待时间	
PartnerCard.tbDevilMasterAward = {					-- 主人奖励
	{1,{{"Energy", 240}},{{"BasicExp", 5}}};
	{2,{{"Energy", 280}},{{"BasicExp", 10}}};
	{3,{{"Energy", 320}},{{"BasicExp", 15}}};
	{4,{{"Energy", 360}},{{"BasicExp", 20}}};
	{5,{{"Energy", 400}},{{"BasicExp", 25}}};
	{6,{{"Energy", 440}},{{"BasicExp", 30}}};
	{7,{{"Energy", 480}},{{"BasicExp", 35}}};
	{8,{{"Energy", 520}},{{"BasicExp", 40}}};
	{9,{{"Energy", 560}},{{"BasicExp", 45}}};
	{10,{{"Energy", 600}},{{"BasicExp", 50}}};								-- n次（包括n次）以上的奖励
} 	
PartnerCard.tbDevilAssistAward	= {					-- 协助奖励
	{1,{{"Energy", 40}},{{"BasicExp", 5}}};
	{2,{{"Energy", 80}},{{"BasicExp", 10}}};
	{3,{{"Energy", 120}},{{"BasicExp", 15}}};
	{4,{{"Energy", 160}},{{"BasicExp", 20}}};
	{5,{{"Energy", 200}},{{"BasicExp", 25}}};
	{6,{{"Energy", 240}},{{"BasicExp", 30}}};
	{7,{{"Energy", 280}},{{"BasicExp", 35}}};
	{8,{{"Energy", 320}},{{"BasicExp", 40}}};
	{9,{{"Energy", 360}},{{"BasicExp", 45}}};
	{10,{{"Energy", 400}},{{"BasicExp", 50}}};									-- n次（包括n次）以上的奖励
} 	
PartnerCard.DEVIL_CURE_RIGHT = 1 						-- 治疗正确
PartnerCard.DEVIL_CURE_WRONG = 2 						-- 治疗错误
PartnerCard.DEVIL_MAX_SHOW_MSG = 5 						-- 最多显示五条
PartnerCard.tbDevilMsg =  								-- 心魔操作描述
{
	[PartnerCard.DEVIL_STATE_HOT] = {
		[PartnerCard.DEVIL_CURE_RIGHT] = "[3FF200]%s[-][87CEFA]对[-][3FF200]%s[-][87CEFA]泼了一瓢冷水，[-][3FF200]%s[-][87CEFA]的心境平和了一些[-]";
		[PartnerCard.DEVIL_CURE_WRONG] = "[3FF200]%s[-][87CEFA]对[-][3FF200]%s[-][87CEFA]泼了一瓢冷水，[-][3FF200]%s[-][87CEFA]十分愤怒[-]";
	};
	[PartnerCard.DEVIL_STATE_LOST] = {
		[PartnerCard.DEVIL_CURE_RIGHT] = "[3FF200]%s[-][87CEFA]对[-][3FF200]%s[-][87CEFA]输入了真气，[-][3FF200]%s[-][87CEFA]的心境平和了一些[-]";
		[PartnerCard.DEVIL_CURE_WRONG] = "[3FF200]%s[-][87CEFA]对[-][3FF200]%s[-][87CEFA]输入了真气，[-][3FF200]%s[-][87CEFA]真气逆行，极度痛苦[-]";
	};
	[PartnerCard.DEVIL_STATE_FEAR] = {
		[PartnerCard.DEVIL_CURE_RIGHT] = "[3FF200]%s[-][87CEFA]对[-][3FF200]%s[-][87CEFA]轻拍了几下，[-][3FF200]%s[-][87CEFA]从梦魇中缓过神来[-]";
		[PartnerCard.DEVIL_CURE_WRONG] = "[3FF200]%s[-][87CEFA]对[-][3FF200]%s[-][87CEFA]进行了安抚，[-][3FF200]%s[-][87CEFA]感到莫名其妙[-]";
	};
}

PartnerCard.tbDevilCureAward = {{"Energy", 40}}

PartnerCard.tbActAward = 
{
	[PartnerCard.CARD_ACT_STATE_VISIT] = 
	{
		[1] = {{"item", 8470, 1}};
		[2] = {{"item", 8470, 1}};
		[3] = {{"item", 8470, 1}};
		[4] = {{"item", 8471, 1}};
		[5] = {{"item", 8472, 1}};
	};
	[PartnerCard.CARD_ACT_STATE_TRIP] = 
	{
		[1] = {{"item", 8473, 1}};
		[2] = {{"item", 8473, 1}};
		[3] = {{"item", 8473, 1}};
		[4] = {{"item", 8474, 1}};
		[5] = {{"item", 8475, 1}};
	};
	[PartnerCard.CARD_ACT_STATE_MUSE] = 
	{
		[1] = {{"item", 8477, 1}};
		[2] = {{"item", 8477, 1}};
		[3] = {{"item", 8477, 1}};
		[4] = {{"item", 8478, 1}};
		[5] = {{"item", 8476, 1}};
	};
}

PartnerCard.tbCommonTask = {80001, 80002, 80003, 80004, 80006,80007,80008,80009,80010,80011,80012,80013,80014,80015,80016,80017,80018,80019,80020,80021,80022,80023,80024,80025,80026,80027,80028,80029,80030,80031,80032} 			-- 通用任务
PartnerCard.nAcceptTaskCount = 5 										-- 每天可接任务数量

PartnerCard.nNpcFurnitureId = 1516 										-- npc同等模型家具检测是否可以摆放门客用

PartnerCard.tbActTimes = {4,4,4,4,4,4,4}								-- 家园等级派遣次数
PartnerCard.tbActCost =  												-- 第n次派遣（不配则不消耗）
{	
	[2] = {{"Gold", 10}};			
	[3] = {{"Gold", 20}};
	[4] = {{"SilverBoard", 20}};	
}

PartnerCard.nMaxPickCard = 5 											-- 抽卡活动期间每天前n次抽卡有机会获得门客

PartnerCard.tbTaskExp = 
{
	[1] = 30;
	[2] = 20;
	[3] = 10;
	[4] = 10;
	[5] = 10;
}

PartnerCard.nVisitAddImitity = 30 										-- 拜访双方增加亲密度
PartnerCard.nMaxAnswer = 10

PartnerCard.nVisitAnswerRightDialogId = 90113
PartnerCard.nVisitAnswerWrongDialogId = 90114

PartnerCard.ACT_AWARD_NOTIFY_TIME = 24*60*60 							-- 派遣奖励感叹号持续时间
function PartnerCard:LoadActSetting()
	self.tbPartnerCardActSetting = LoadTabFile("Setting/PartnerCard/PartnerCardActSetting.tab", "ds", "nActType", {"nActType", "szDes"});
	for _, v in pairs(self.tbPartnerCardActSetting) do
		 local szContent = string.gsub(v.szDes, "\\n", "\n")
		 v.szDes = szContent
	end
	self.tbPartnerCardTalkSetting = {}
	local tbFile = LoadTabFile("Setting/PartnerCard/PartnerCardTalkSetting.tab", "ds", nil, {"nCardId", "szTalk"});
	for _, v in ipairs(tbFile) do
		self.tbPartnerCardTalkSetting[v.nCardId] = self.tbPartnerCardTalkSetting[v.nCardId] or {}
		table.insert(self.tbPartnerCardTalkSetting[v.nCardId], v.szTalk)
	end
	self.tbPartnerCardVisitTalkSetting = {}
	tbFile = LoadTabFile("Setting/PartnerCard/PartnerCardVisitTalkSetting.tab", "ds", nil, {"nCardId", "szTalk"});
	for _, v in ipairs(tbFile) do
		self.tbPartnerCardVisitTalkSetting[v.nCardId] = self.tbPartnerCardVisitTalkSetting[v.nCardId] or {}
		table.insert(self.tbPartnerCardVisitTalkSetting[v.nCardId], v.szTalk)
	end
	self.tbCardVisitQuestion = {}
	local szParamType = "ds";
	local tbParams = {"nQuestionId", "szQuestion"};
	for i=1, PartnerCard.nMaxAnswer do
		szParamType = szParamType .."s";
		table.insert(tbParams,"szAnswer" ..i);
	end
	tbFile = LoadTabFile("Setting/PartnerCard/PartnerCardQuestion.tab", szParamType, nil, tbParams);
	for _, v in ipairs(tbFile) do
		self.tbCardVisitQuestion[v.nQuestionId] = {}
		self.tbCardVisitQuestion[v.nQuestionId].szQuestion = v.szQuestion
		self.tbCardVisitQuestion[v.nQuestionId].tbAnswer = {}
		self.tbCardVisitQuestion[v.nQuestionId].nQuestionId = v.nQuestionId
		for i=1, PartnerCard.nMaxAnswer do
			if not Lib:IsEmptyStr(v["szAnswer" ..i]) then
				table.insert(self.tbCardVisitQuestion[v.nQuestionId].tbAnswer, v["szAnswer" ..i])
			end
		end
		assert(#self.tbCardVisitQuestion[v.nQuestionId].tbAnswer >= 4, "PartnerCardQuestion Err Answer Num" ..#self.tbCardVisitQuestion[v.nQuestionId].tbAnswer)
	end
	self.tbTripMapSetting = {}
	tbFile = LoadTabFile("Setting/PartnerCard/PartnerCardTripMap.tab", "ds", nil, {"nMapTemplateId", "szPos"});
	for _, v in ipairs(tbFile) do
		local tbAllPos = Lib:SplitStr(v.szPos, "|")
		for _, szPos in pairs(tbAllPos) do
			self.tbTripMapSetting[v.nMapTemplateId] = self.tbTripMapSetting[v.nMapTemplateId] or {}
			local tbStrPos = Lib:SplitStr(szPos, ";")
			local nPosX = tbStrPos[1] and tonumber(tbStrPos[1]) or 0
			local nPosY = tbStrPos[2] and tonumber(tbStrPos[2]) or 0
			local nDir = tbStrPos[2] and tonumber(tbStrPos[3]) or 0
			table.insert(self.tbTripMapSetting[v.nMapTemplateId], {nPosX, nPosY, nDir})
		end
	end
end
PartnerCard:LoadActSetting()

function PartnerCard:RandomTask(pPlayer, nCardId)
	local tbCardInfo = self:GetCardInfo(nCardId)
	if not tbCardInfo then
		return 
	end
	local tbRandomTask = {}
	local nRandom = PartnerCard.nAcceptTaskCount
	local fnSelect
	if tbCardInfo.tbTask then
		nRandom = math.min(#tbCardInfo.tbTask, PartnerCard.nAcceptTaskCount)
		fnSelect = Lib:GetRandomSelect(#tbCardInfo.tbTask)
		for i=1, nRandom do
			table.insert(tbRandomTask, tbCardInfo.tbTask[fnSelect()])
		end
		nRandom = PartnerCard.nAcceptTaskCount - nRandom
	end
	nRandom = math.min(nRandom, #PartnerCard.tbCommonTask)
	if nRandom > 0 then
		fnSelect = Lib:GetRandomSelect(#PartnerCard.tbCommonTask)
		for i=1, nRandom do
			table.insert(tbRandomTask, PartnerCard.tbCommonTask[fnSelect()])
		end
	end
	
	return Lib:RandomArray(tbRandomTask)
end

function PartnerCard:CheckAcceptTask(pPlayer, nCardId)
	if not self:GetCardInfo(nCardId) then
		return false, "未知门客"
	end
	if not PartnerCard:IsHaveCard(pPlayer, nCardId) then
		return false, "请先招募该门客"
	end
	local tbTaskData = PartnerCard:GetTaskCardData(pPlayer.dwID)
	if not tbTaskData then
		return  false, "未知错误"
	end
	local nLevel = PartnerCard:GetCardSaveInfo(pPlayer, nCardId, PartnerCard.nLevelIdxStep)
	if nLevel >= self.nMaxCardLevel then
		return false, "已经达到最大等级,不能接任务"
	end
	local tbTaskId = tbTaskData.tbTaskId
	local nUpdateTime = tbTaskData.nUpdateTime or 0
	local nUpdateDay = Lib:GetLocalDay(nUpdateTime)
	local nNowDay = Lib:GetLocalDay()
	local nFinishTaskIdx = tbTaskData.nFinishTaskIdx or 0
	if tbTaskId then
		if nFinishTaskIdx < #tbTaskId then
			return false, "您有尚未完成的门客任务，请完成后再来接取今天的门客任务"
		end
	end
	if nUpdateDay == nNowDay then
		return false, "今天已经接取了任务"
	end
	return true, nil, tbTaskData
end

function PartnerCard:GetNextTaskId(pPlayer, tbTaskId, nTaskId)
	tbTaskId = tbTaskId or {}
	local nIdx = -1
	for i, nId in ipairs(tbTaskId) do
		if nId == nTaskId then
			nIdx = i
			break
		end
	end
	return tbTaskId[nIdx + 1]
end

function PartnerCard:GetAllTask(pPlayer)
	local tbPlayerTask = Task:GetPlayerTaskInfo(pPlayer)
    local tbTaskId = {}
    for _, tbInfo in pairs(tbPlayerTask.tbCurTaskInfo) do
        local tbTask = Task:GetTask(tbInfo.nTaskId)
        if tbTask and tbTask.nTaskType == Task.TASK_TYPE_PARTNERCARD then
            table.insert(tbTaskId, tbInfo.nTaskId)
        end
    end
	return tbTaskId
end

function PartnerCard:GetDevilAward(bMaster, nCount)
	local tbAwardInfo = bMaster and PartnerCard.tbDevilMasterAward or PartnerCard.tbDevilAssistAward
	local tbSendAward 
	for i=#tbAwardInfo, 1, -1 do
		local nCureCount = tbAwardInfo[i][1]
		local tbAward = tbAwardInfo[i][2]
		tbSendAward = tbAward
		if nCount >= nCureCount then
			break
		end
	end
	return tbSendAward
end

function PartnerCard:CheckQuestion(nQuestionId, nAnswerIdx, tbAnswer)
	local tbQuestionInfo = PartnerCard:GetQuestionInfo(nQuestionId)
	if not tbQuestionInfo then
		return false, "未知问题"
	end
	if not tbQuestionInfo.tbAnswer or not tbQuestionInfo.tbAnswer[nAnswerIdx] then
		return false, "未知答案"
	end
	if #tbAnswer ~= 4 then
		return false, "未知答案数量"
	end
	for _, nIdx in ipairs(tbAnswer) do
		if not tbQuestionInfo.tbAnswer[nIdx] then
			return false, "未知答案"
		end
	end
	return true
end

function PartnerCard:CheckBubble(szMsg)
	if version_kor then
		local nKorLen = string.len(szMsg);
		if nKorLen > self.nKorBubbleMax or nKorLen < self.nKorBubbleMin then
			return false, string.format("喊话长度需要在%d~%d个汉字内", self.nVNBubbleMin, self.nVNBubbleMax)
		end
	elseif version_vn then
		local nVNLen = string.len(szMsg);
		if nVNLen > self.nVNBubbleMax or nVNLen < self.nVNBubbleMin then
			return false, string.format("喊话长度需要在%d~%d个汉字内", self.nVNBubbleMin, self.nVNBubbleMax)
		end
	elseif version_th then
		local nNameLen = Lib:Utf8Len(szMsg);
		if nNameLen > self.nTHBubbleMax or nNameLen < self.nTHBubbleMin then
			return false, string.format("喊话长度需要在%d~%d个汉字内", self.nTHBubbleMin, self.nTHBubbleMax)
		end
	else
		local nNameLen = Lib:Utf8Len(szMsg);
		if nNameLen > self.nBubbleMax or nNameLen < self.nBubbleMin then
			return false, string.format("喊话长度需要在%d~%d个汉字内", self.nBubbleMin, self.nBubbleMax)
		end
		if Lib:HasNonChineseChars(szMsg) then
	        return false, "喊话内容只能使用中文字符，请修改后重试！"
	    end
	end
	if ReplaceLimitWords(szMsg) then
		return false, "喊话内容含有敏感字符，请修改后重试！"
	end
	return true
end

function PartnerCard:GetVisitRightAward(nLevel)
	return PartnerCard.tbVisitRightAward
end

-- 随一个问题和四个答案
function PartnerCard:RandomOneQuestion(nQuestionId)
	local nRandomQuestionId = nQuestionId or MathRandom(1, #self.tbCardVisitQuestion)
	local tbRandomQuestion = self.tbCardVisitQuestion[nRandomQuestionId]
	local tbQuestion = {}
	tbQuestion.nQuestionId = tbRandomQuestion.nQuestionId
	tbQuestion.tbAnswer = {}
	local fnSelect = Lib:GetRandomSelect(#tbRandomQuestion.tbAnswer)
	for i=1,4 do
		table.insert(tbQuestion.tbAnswer, fnSelect())
	end
	return tbQuestion
end

function PartnerCard:GetQuestionInfo(nQuestionId)
	return self.tbCardVisitQuestion[nQuestionId]
end

function PartnerCard:GetHouseTalk(nCardId, bVisit)
	return bVisit and self.tbPartnerCardVisitTalkSetting[nCardId] or self.tbPartnerCardTalkSetting[nCardId]
end

function PartnerCard:GetHouseLevel(dwID)
	local nHouseLevel
	if MODULE_GAMESERVER then
		nHouseLevel = House:GetHouseLevel(dwID)
	else
		nHouseLevel = House.nHouseLevel
	end
	return nHouseLevel or 0
end

function PartnerCard:CheckLiveHouse(pPlayer, nCardId)
	if not House:IsInOwnHouse(pPlayer) then
		pPlayer.CenterMsg("在自己家园才可操作", true)
		return 
	end
	if not PartnerCard:IsHaveCard(pPlayer, nCardId) then
		return false, "请先获得该门客"
	end
	if not House:CheckOpen(pPlayer) then
		return false, "请先建造家园" 
	end
	if self:IsCardLiveHouse(pPlayer, nCardId) then
		return false, "该门客已经入住家园"
	end
	-- if not PartnerCard:IsCardUpPos(pPlayer, nCardId) then
	-- 	return false, "门客上阵后才能入住"
	-- aend
	local nHouseLevel = PartnerCard:GetHouseLevel(pPlayer.dwID)
	local nMaxLiveHouse = PartnerCard.tbMaxLiveHouse[nHouseLevel] or 0
	local tbCardData = PartnerCard:GetHouseCardData(pPlayer.dwID) or {}
	if  Lib:CountTB(tbCardData) >= nMaxLiveHouse then
		return false, "家园门客过多，入住失败"
	end
	if PartnerCard:ComposeWorking(pPlayer.dwID, nCardId) then
		return false, string.format("门客正在参与合成，不能升阶")
	end
	return true
end

function PartnerCard:CheckLeaveHouse(pPlayer, nCardId)
	if not PartnerCard:IsHaveCard(pPlayer, nCardId) then
		return false, "请先获得该门客"
	end
	if not House:CheckOpen(pPlayer) then
		return false, "请先建造家园" 
	end
	if not self:IsCardLiveHouse(pPlayer, nCardId) then
		return false, "该门客还没入住家园"
	end
	local nActState = PartnerCard:GetCardActState(pPlayer, nCardId)
	if not nActState then
		return false, "未知状态"
	end
	if PartnerCard:IsActing(pPlayer.dwID, nCardId) then
		return false, "您的门客正在派遣中，无法离开家园"
	end
	if nActState ~= PartnerCard.CARD_ACT_STATE_NONE then
		return false, "您的门客有派遣奖励待领取，请先至派遣界面领取奖励"
	end
	return true
end

function PartnerCard:CheckHouseOperation(pPlayer)
	if not House:IsInOwnHouse(pPlayer) then
		return false, "只能在自己家园才能操作"
	end
	return true
end

function PartnerCard:GetCardUnlockActType(dwID, nCardId)
	local tbActType = PartnerCard:GetRandomActTypeData(dwID)
	local tbUseActType = tbActType.tbUseRandomType or {}
	local tbRandomType = tbActType.tbRandomType or {}
	local nUseIdx = tbUseActType[nCardId] or 0
	local tbCardActType = tbRandomType[nUseIdx] or {}
	local tbUnlockActType = {}
	for _, nActType in ipairs(tbCardActType) do
		tbUnlockActType[nActType] = true
	end
	return tbUnlockActType
end

function PartnerCard:GetMaxActTimes(dwID)
	local nHouseLevel = PartnerCard:GetHouseLevel(dwID) or 0
	return PartnerCard.tbActTimes[nHouseLevel] or 0
end

function PartnerCard:GetActCount(pPlayer)
	local nActDegree = DegreeCtrl:GetDegree(pPlayer, "PartnerCardAct")
	local nActCount = PartnerCard:GetMaxActTimes(pPlayer.dwID) - nActDegree + 1
	return nActCount
end

function PartnerCard:CheckAddStateCommon(pPlayer, nCardId, nActType, bNotCheckState, bNotCheckCost, bNotCheckOpenType, bNotCheckTimes)
	if not PartnerCard:IsOpen() then
		return false, "还没开放门客功能"
	end
	local tbCardInfo = self:GetCardInfo(nCardId)
	if not tbCardInfo then
		return false, "没有门客"
	end
	if not PartnerCard:IsHaveCard(pPlayer, nCardId) then
		return false, "请先招募该门客"
	end
	local tbActInfo = self.tbPartnerCardActSetting[nActType]
	if not tbActInfo then
		return false, "未知操作"
	end
	local tbCardData = PartnerCard:GetHouseCardData(pPlayer.dwID)
	if not tbCardData then
		return false, "数据异常"
	end
	local tbCard = tbCardData[nCardId]
	if not tbCard then
		return false, "入住的门客才可操作"
	end
	if PartnerCard:IsActing(pPlayer.dwID, nCardId) then
		return false, "当前门客正在派遣"
	end
	if not bNotCheckState and tbCard.nActState ~=  PartnerCard.CARD_ACT_STATE_NONE then
		return false, "请先领取派遣奖励"
	end
	local tbUnlockActType = self:GetCardUnlockActType(pPlayer.dwID, nCardId)
	if not bNotCheckOpenType and not tbUnlockActType[nActType] then
		return false, "该门客暂未开放该种派遣类型"
	end
	local nActTimes = DegreeCtrl:GetDegree(pPlayer, "PartnerCardAct")
	if not bNotCheckTimes and nActTimes <= 0 then
		return false, "今日已经达到最大派遣次数"
	end

	local nActCount = PartnerCard:GetActCount(pPlayer)
	local tbCost = PartnerCard.tbActCost[nActCount] or {}
	if next(tbCost) and not bNotCheckCost then
		for _, tbInfo in pairs(tbCost) do
			local nType = Player.AwardType[tbInfo[1]];
			if not nType or (nType ~= Player.award_type_item and nType ~= Player.award_type_money) then
				return false, "异常配置";
			end

			if nType == Player.award_type_money then
				if pPlayer.GetMoney(tbInfo[1]) < tbInfo[2] then
					return false, string.format("%s不足", Shop:GetMoneyName(tbInfo[1]), tbInfo[2]);
				end
			elseif nType == Player.award_type_item then
				local nCount = pPlayer.GetItemCountInBags(tbInfo[2]);
				if nCount < tbInfo[3] then
					local szItemName = Item:GetItemTemplateShowInfo(tbInfo[2], pPlayer.nFaction, pPlayer.nSex)
					return false, string.format("%s不足", szItemName, tbInfo[3]), tbInfo[2];
				end
			end
		end
	end
	return true, nil, tbCardData
end

function PartnerCard:HaveActAward(pPlayer)
	local nNowTime = GetTime()
	local tbCardData = PartnerCard:GetHouseCardData(pPlayer.dwID) or {}
	for _, v in pairs(tbCardData) do
		local nActTime = v.nActTime or 0 
		if nActTime > 0 and nNowTime >= nActTime + PartnerCard.CARD_ACT_ACTIVE_TIME then
			return true
		end
	end
	return false
end

function PartnerCard:CheckHavekGetActAward(pPlayer)
	local tbActSetting = PartnerCard:GetActSetting()
	local tbCardData = PartnerCard:GetHouseCardData(pPlayer.dwID) or {}
	for nCardId, v in pairs(tbCardData) do
		for nActType in ipairs(tbActSetting) do
			if PartnerCard:CanGetActAward(pPlayer, nCardId, nActType) then
				return true
			end
		end
	end
	return false
end

function PartnerCard:CanGetActAward(pPlayer, nCardId, nActState)
	local bRet, szMsg, tbCardData = PartnerCard:CheckAddStateCommon(pPlayer, nCardId, nActState, true, true, true, true)
	if not bRet then
		return false, szMsg
	end
	local nActType = tbCardData[nCardId].nActState
	if nActType == PartnerCard.CARD_ACT_STATE_NONE or nActType ~= nActState then
		return false, "不能领取该派遣类型奖励"
	end
	local nActTime = tbCardData[nCardId].nActTime
	local nNowTime = GetTime()
	if not nActTime or nNowTime < nActTime + PartnerCard.CARD_ACT_ACTIVE_TIME then
		return false, "还没到领取奖励时间"
	end
	return true, nil, tbCardData
end

-- 是否派遣中
function PartnerCard:IsActing(dwID, nCardId, nActState)
	local tbCardData = PartnerCard:GetHouseCardData(dwID) or {}
	local tbCard = tbCardData[nCardId]
	if not tbCard then
		return
	end
	local nNowTime = GetTime()
	if tbCard and tbCard.nActState ~= PartnerCard.CARD_ACT_STATE_NONE and (nNowTime - (tbCard.nActTime or 0) < PartnerCard.CARD_ACT_ACTIVE_TIME)  then
		if nActState then
			return nActState == tbCard.nActState
		else
			return true
		end
	end
end

function PartnerCard:IsCardLiveHouse(pPlayer, nCardId)
	local tbCardData = PartnerCard:GetHouseCardData(pPlayer.dwID) or {}
	return tbCardData[nCardId]
end

function PartnerCard:GetCardActState(pPlayer, nCardId)
	local tbCardData = PartnerCard:GetHouseCardData(pPlayer.dwID) or {}
	return tbCardData[nCardId] and tbCardData[nCardId].nActState
end

function PartnerCard:GetActSetting()
	return self.tbPartnerCardActSetting
end

function PartnerCard:GetDevilIllIndex(nTriggerDevilTime)
	local nNowTime = GetTime()
	local nIllIndex = (nNowTime - nTriggerDevilTime) / PartnerCard.nDevilChangeStateInterval
	if (nNowTime - nTriggerDevilTime) % PartnerCard.nDevilChangeStateInterval == 0 then
		nIllIndex = nIllIndex + 1
	end
	return math.ceil(nIllIndex)
end

function PartnerCard:RandomIllState()
	local tbIll = {}
	local fnSelect = Lib:GetRandomSelect(PartnerCard.DEVIL_STATE_MAX - 1)
	local nIllCount = math.ceil(PartnerCard.nDevilStayTime / PartnerCard.nDevilChangeStateInterval)
	for i=1, nIllCount do
		local nIll = fnSelect()
		table.insert(tbIll, nIll)
	end
	return tbIll
end

function PartnerCard:CheckStartTripFuben(pPlayer, nCardId)
	local tbCardData = PartnerCard:GetHouseCardData(pPlayer.dwID)
	if not tbCardData or not tbCardData[nCardId] then
		return false, "找不到数据"
	end
	if not PartnerCard:IsActing(pPlayer.dwID, nCardId, PartnerCard.CARD_ACT_STATE_TRIP) then
		return false, "门客已经结束游历"
	end
	local nNowTime = GetTime()
	local nActSubTime = tbCardData[nCardId].nActSubTime
	local nActTime = tbCardData[nCardId].nActTime or 0
	if not nActSubTime or nNowTime < nActSubTime or nActSubTime < nActTime then
		return false, "触发时间还没到"
	end
	if tbCardData[nCardId].bTrigger then
		return false, "已经完成协助"
	end
	return true, nil, nActTime
end