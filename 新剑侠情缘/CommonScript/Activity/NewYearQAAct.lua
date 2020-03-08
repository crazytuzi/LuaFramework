if not MODULE_GAMESERVER then
    Activity.NewYearQAAct = Activity.NewYearQAAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("NewYearQAAct") or Activity.NewYearQAAct
tbAct.nDayInRound          = 2 --多少天作为一轮出题
tbAct.nQuestionNum         = 3 --题目数量
tbAct.nAnswerCount         = 8 --供玩家选择答案数量
tbAct.nAnswerCount_Npc     = 4 --NPC每题答案数量
tbAct.nCreateSysQuestion   = 21 --什么时间使用系统题库
tbAct.n4ChooseAnswer       = 4 --答题时选项数量
tbAct.nDayQuestionCount    = 10 --每天可以回答多少道题目
tbAct.nDayMoneyRefresh     = 2 --每天可以花钱刷新多少次题目
tbAct.nSetQuestionGold     = 108 --豪华出题
tbAct.nRefreshQuestionGold = 108 --刷新题库
tbAct.nMoneyRightImity     = 500
tbAct.nNormalRightImity    = 200
tbAct.tbMoneyQuestionAward = {{"Contrib", 1000}}
tbAct.tbPlayerTitle        = {{4600, "%s的挚友", 2}, {4601, "%s的表面兄弟", 3}}
tbAct.nTitleValidTime      = 30*24*3600
tbAct.nDayRefreshTimes     = 2 --每天花钱刷新的次数
tbAct.nActEnterItem        = 7443 --活动开始时邮件奖励
tbAct.nMoneyAward          = 7454 --豪华题奖品
tbAct.nNormalAward         = 7453 --普通题奖品
tbAct.nRequireLv           = 20 -- 参与等级
tbAct.nBeAnswerAwardTimes  = 5 -- 被回答能拿到的奖励上限
tbAct.nNewDayTime          = 4*3600
tbAct.bWolrdNotify         = true
tbAct.szMailTitle          = "新年礼盒的考验"
tbAct.szMailContent        = "新年将至，大侠快收下这个题板，来检验一下过去的一年中收获了多少好朋友吧！" --活动开始时邮件内容
tbAct.szNotGainMailTips    = "大侠还未领取题板，请先从邮件中领取题板再去答题！"
tbAct.szWCreateQuestionTips= "大侠的好友已经出题完毕，快打开题板前去答题吧！"
tbAct.szCreateQuestionTips = "大侠的好友已经出题完毕，快打开题板前去答题吧！"
tbAct.szQuestionFile       = "Setting/Activity/NewYearQAAct.tab"
tbAct.szDQuestionFile      = "Setting/Activity/NewYearQAAct_DefaultQA.tab"

--[[
不同Key对应的配置
添加新项需程序处理
注意，客户端不支持多开
]]
tbAct.tbDiffKeySetting = {
	["AnniversaryQAAct"] = {
		nActEnterItem         = 7962,
		nMoneyAward           = 7964,
		nNormalAward          = 7963,
		bWolrdNotify          = false,
		szMailTitle           = "周年庆礼盒考验",
		szMailContent         = "周年庆将至，大侠快收下这个题板，来检验一下自己的朋友是不是真的了解自己吧！",
		szNotGainMailTips     = "大侠还未领取题板，请先从邮件中领取题板再去答题！",
		szWCreateQuestionTips = "大侠的好友已经出题完毕，快打开题板前去答题吧！",
		szCreateQuestionTips  = "大侠的好友已经出题完毕，快打开题板前去答题吧！",
		szQuestionFile        = "Setting/Activity/NewYearQAAct.tab",
		szDQuestionFile       = "Setting/Activity/NewYearQAAct_DefaultQA.tab",
		tbPlayerTitle         = {{4602, "%s的挚友", 2}, {4603, "%s的表面兄弟", 3}},
	},
	["CeremonyQAAct"] = {
		tbCompleteDayAllQA   = {"Item", 9878, 1}, --答完当天三套题的奖励
		nActEnterItem         = 9891,
		nMoneyAward           = 9893,
		nNormalAward          = 9892,
		bWolrdNotify          = false,
		szMailTitle           = "盛典礼盒考验",
		szMailContent         = "江湖盛典将至，大侠快收下这个题板，来检验一下自己的朋友是不是真的了解自己吧！",
		szNotGainMailTips     = "大侠还未领取题板，请先从邮件中领取题板再去答题！",
		szWCreateQuestionTips = "大侠的好友已经出题完毕，快打开题板前去答题吧！",
		szCreateQuestionTips  = "大侠的好友已经出题完毕，快打开题板前去答题吧！",
		szQuestionFile        = "Setting/Activity/CeremonyQAAct.tab",
		szDQuestionFile       = "Setting/Activity/NewYearQAAct_DefaultQA.tab",
		tbPlayerTitle         = {{4604, "%s的挚友", 2}, {4605, "%s的表面兄弟", 3}},
	},
}

if MODULE_GAMESERVER then
	return
end

--[[
这种方式其实不好用，但客户端没有实例，先这样吧
]]
function tbAct:GetValue(szKey)
	for szKeyName, tbInfo in pairs(self.tbDiffKeySetting) do
		if Activity:__GetActTimeInfo(szKeyName) then
			return tbInfo[szKey] or self[szKey]
		end
	end
	return self[szKey]
end

function tbAct:GetRound()
	if not self.nStartTime then
		return
	end
	local nStartDay  = Lib:GetLocalDay(self.nStartTime - self.nNewDayTime)
	local nLocalDay  = Lib:GetLocalDay(GetTime() - self.nNewDayTime)
	local nCurRound  = math.floor((nLocalDay - nStartDay) / self.nDayInRound) + 1
	return nCurRound
end

function tbAct:SyncData(nStartTime, tbPlyerData)
	self.nStartTime = nStartTime
	self.tbPlyerData = tbPlyerData
	self:ClearCacheAnswer()
end

function tbAct:TryBeginQuestion()
	if self.tbPlyerData.tbAskInfo.nRound == self:GetRound() then
		if self.tbPlyerData.tbAskInfo.bConfirm then
			me.CenterMsg("已出题")
			return
		else
			Ui:CloseWindow("NewYearQAMainPanel")
			Ui:OpenWindow("NewYearQASetPanel", self.tbPlyerData.tbAskInfo)
		end
	else
		RemoteServer.NewYearQAClientCall("TryBeginQuestion")
	end
end

function tbAct:BeginQuestion(tbAskInfo)
	self.tbPlyerData = self.tbPlyerData or {}
	self.tbPlyerData.tbAskInfo = tbAskInfo or self.tbPlyerData.tbAskInfo
	Ui:CloseWindow("NewYearQAMainPanel")
	Ui:OpenWindow("NewYearQASetPanel", tbAskInfo)
end

function tbAct:IsCanSetQuestion()
	if self.tbPlyerData.tbAskInfo.nRound ~= self:GetRound() then
		return true
	end
	if not self.tbPlyerData.tbAskInfo.bConfirm then
		return true
	end
end

function tbAct:GetMyQuestion()
	if not self.tbPlyerData or not self.tbPlyerData.tbAskInfo then
		return
	end
	local tbMyQuestion = self.tbPlyerData.tbAskInfo.tbQuestion
	local tbQuestion = {}
	for _, tbInfo in ipairs(tbMyQuestion) do
		table.insert(tbQuestion, {tbInfo.nTitle, tbInfo.nAskId})
	end
	return tbQuestion, self.tbPlyerData.tbAskInfo.bCostGold
end

function tbAct:GetQInfo(nQId)
	if not self.tbQInfo then
		local szTabFile = self:GetValue("szQuestionFile")
		self.tbQInfo = Lib:LoadTabFile(szTabFile, {})
	end
	return self.tbQInfo[nQId]
end

function tbAct:GetDefaultQInfo(nQId)
	if not self.tbDQInfo then
		local szTabFile = self:GetValue("szDQuestionFile")
		self.tbDQInfo = Lib:LoadTabFile(szTabFile, {nLevel = 1, nPortrait = 1, nFaction = 1, nHonorLevel = 1, nRight = 1, nResId = 1})
	end
	return self.tbDQInfo[nQId]
end

function tbAct:SetQuestionSuccess(tbAskInfo)
	self.tbPlyerData.tbAskInfo = tbAskInfo
	Ui:CloseWindow("NewYearQASetPanel")
	me.CenterMsg("出题成功")
end

function tbAct:GetQuestionList(bNotRequest)
	local nHour = Lib:GetLocalDayHour()
	if (not self.tbPlyerData) or
		(not self.tbPlyerData.tbAnswerInfo) or
		(#self.tbPlyerData.tbAnswerInfo.tbTodayQuestion <= 0) or
		 -- and (nHour >= self.nCreateSysQuestion or nHour < self.nNewDayTime/3600)) or
		(self.tbPlyerData.tbAnswerInfo.nDataDay ~= Lib:GetLocalDay(GetTime() - self.nNewDayTime)) then
		if not bNotRequest then
			RemoteServer.NewYearQAClientCall("TryBeginAnswer")
		end
		return
	end

	local tbList = {}
	for nQId, tbInfo in ipairs(self.tbPlyerData.tbAnswerInfo.tbTodayQuestion) do
		local tbQAInfo = {}
		if tbInfo.nPlayerId > 0 then
			local tbPlayerInfo = FriendShip:GetFriendDataInfo(tbInfo.nPlayerId)
			if tbPlayerInfo then
				tbQAInfo.nLevel      = tbPlayerInfo.nLevel
				tbQAInfo.nFaction    = tbPlayerInfo.nFaction
				tbQAInfo.szName      = tbPlayerInfo.szName
				tbQAInfo.nPortrait   = tbPlayerInfo.nPortrait
				tbQAInfo.nHonorLevel = tbPlayerInfo.nHonorLevel
			else
				tbQAInfo.nLevel      = 1
				tbQAInfo.nFaction    = 1
				tbQAInfo.szName      = "神秘人"
				tbQAInfo.nPortrait   = 1
				tbQAInfo.nHonorLevel = 1
			end
		else
			local tbDQInfo = self:GetDefaultQInfo(tbInfo.nTitle)
			tbQAInfo.nLevel      = tbDQInfo.nLevel
			-- tbQAInfo.nFaction    = tbDQInfo.nFaction
			tbQAInfo.szName      = tbDQInfo.szName
			tbQAInfo.nPortrait   = tbDQInfo.nPortrait
			tbQAInfo.nHonorLevel = tbDQInfo.nHonorLevel
			tbQAInfo.nResId 	 = tbDQInfo.nResId
		end
		tbQAInfo.nPlayerId = tbInfo.nPlayerId
		tbQAInfo.nQuestionId = nQId
		tbQAInfo.nTitle = tbInfo.nTitle
		tbQAInfo.nChooseAnswer = tbInfo.nChooseAnswer
		tbQAInfo.bCostGold = tbInfo.bCostGold
		tbQAInfo.tb4Choose = self:Get4ChooseItem(tbInfo.nPlayerId > 0, nQId, tbInfo.nAnswer)
		table.insert(tbList, tbQAInfo)
	end
	return tbList
end

tbAct.tbPlayerRandomItem = tbAct.tbPlayerRandomItem or {}
function tbAct:Get4ChooseItem(bPlayer, nQId, nAnswer)
	local nLocalDay = Lib:GetLocalDay(GetTime() - self.nNewDayTime)
	if not self.tbPlayerRandomItem[nLocalDay] then
		self.tbPlayerRandomItem[nLocalDay] = {}
	end
	if not self.tbPlayerRandomItem[nLocalDay][me.dwID] then
		self.tbPlayerRandomItem[nLocalDay][me.dwID] = {}
	end
	if not self.tbPlayerRandomItem[nLocalDay][me.dwID][nQId] then
		local tbAll = {}
		local nChooseItemCount = bPlayer and self.nAnswerCount or self.nAnswerCount_Npc
		for i = 1, nChooseItemCount do
			if i ~= nAnswer then
				table.insert(tbAll, i)
			end
		end
		local tb4Choose = {}
		for i = 1, self.n4ChooseAnswer - 1 do
			local nIdx = table.remove(tbAll, MathRandom(#tbAll))
			table.insert(tb4Choose, nIdx)
		end
		table.insert(tb4Choose, MathRandom(self.n4ChooseAnswer), nAnswer)
		self.tbPlayerRandomItem[nLocalDay][me.dwID][nQId] = tb4Choose
	end
	return self.tbPlayerRandomItem[nLocalDay][me.dwID][nQId]
end

function tbAct:ClearCacheAnswer()
	local nLocalDay = Lib:GetLocalDay(GetTime() - self.nNewDayTime)
	if not self.tbPlayerRandomItem[nLocalDay] then
		self.tbPlayerRandomItem[nLocalDay] = {}
	end
	self.tbPlayerRandomItem[nLocalDay][me.dwID] = nil
end

function tbAct:GetLastRefreshQTimes()
	if self.tbPlyerData and self.tbPlyerData.tbAnswerInfo then
		return self.nDayMoneyRefresh - self.tbPlyerData.tbAnswerInfo.nDayRefreshTimes
	end
	return 0
end

function tbAct:BeginAnswer(tbAnswerInfo)
	self.tbPlyerData.tbAnswerInfo = tbAnswerInfo
	self:ClearCacheAnswer()
	local tbList = self:GetQuestionList(true)
	UiNotify.OnNotify(UiNotify.emNOTIFY_NEWYEAR_QA_ACT, tbList)
end

function tbAct:OnLogout()
	self.nStartTime = nil
	self.tbPlyerData = nil
end

function tbAct:OnAnswer(nQIdx, nChooseAnswer)
	self.tbPlyerData.tbAnswerInfo.tbTodayQuestion[nQIdx].nChooseAnswer = nChooseAnswer
	local tbList = self:GetQuestionList(true)
	UiNotify.OnNotify(UiNotify.emNOTIFY_NEWYEAR_QA_ACT, tbList)
end

function tbAct:TryOpenAnswerUi()
	if me.GetItemCountInAllPos(self.nActEnterItem) > 0 then
		Item:GetClass("NewYearQAActItem"):OpenActUi(2)
	else
		local szMsg = self:GetValue("szNotGainMailTips")
		me.CenterMsg(szMsg)
	end
end

function tbAct:OnCreateNotify()
	local szMsg = self:GetValue("szWCreateQuestionTips")
	me.Msg(szMsg)
	local tbMsgData =
	{
		szType = "NewYearQAAct",
		nTimeOut = GetTime() + 60*5,
	}
	Ui:SynNotifyMsg(tbMsgData)
end