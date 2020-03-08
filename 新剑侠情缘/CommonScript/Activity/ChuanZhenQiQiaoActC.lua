Require("CommonScript/Player/PlayerDef.lua")
if not MODULE_GAMESERVER then
	Activity.ChuanZhenQiQiaoAct = Activity.ChuanZhenQiQiaoAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("ChuanZhenQiQiaoAct") or Activity.ChuanZhenQiQiaoAct

tbAct.nJoinLevel = 20   --最低参与等级
tbAct.nMatchTime = 10 * 60  --答题时间

-- 每日活跃宝箱额外获得
tbAct.tbTargetRewards = {
    [Player.SEX_MALE] = {   --男
        [1] = {{9440, 1}},    -- 物品id，个数
        [2] = {{9441, 1}},
        [3] = {{9442, 1}},
        [4] = {{9443, 1}},
        [5] = {{9444, 1}},
    },
    [Player.SEX_FEMALE] = { --女
        [1] = {{9446, 2}},    -- 物品id，个数
        [2] = {{9446, 2}},
        [3] = {{9446, 2}},
        [4] = {{9446, 2}},
        [5] = {{9446, 1}, {9447, 1}},
    },
}

tbAct.nAnswerRewardItemId = 9449	--鹊之灵
tbAct.nAnswerCount = 9 	--总共答对题数

-- 参与答题消耗道具
tbAct.tbDialogItems = {
    [Player.SEX_MALE] = {9445, 1},   --道具id，数量
    [Player.SEX_FEMALE] = {9448, 1},
}

tbAct.nDialogNpcId = 2371

--奖励配置
tbAct.tbRewards = {
	tbFinished = {	--完成
		{60, "得巧", 10, { {"Contrib", 2000}, {"BasicExp", 30}}},	--耗时（秒，含），评价，鹊之灵个数，额外奖励
		{90, "大巧", 9, { {"Contrib", 1800}, {"BasicExp", 30}}},
		{150, "小巧", 8, { {"Contrib", 1500}, {"BasicExp", 30}}},
		{300, "略巧", 7, { {"Contrib", 1200}, {"BasicExp", 20}}},
		{600, "有点巧", 6, { {"Contrib", 1000}, {"BasicExp", 20}}},
	},
	tbNotFinished = {	--未完成
		{5, "拙", 4, { {"Contrib", 800}, {"BasicExp", 15}}},	--答对题数（含），评价，鹊之灵个数，额外奖励
		{8, "小拙", 5, { {"Contrib", 500}, {"BasicExp", 15}}},
	},
}

tbAct.nIntroDlgId = 4100	--播放介绍对话id

function tbAct:LoadSetting()
	self.tbQuestions = Lib:LoadTabFile("Setting/Activity/ChuanZhenQiQiaoQA.tab", {nId=1, nAnswerId=1})
end
tbAct:LoadSetting()

function tbAct:IsAnswerRight(nId, nAnswerId)
	local tbQuestion = self:GetQuestionSetting(nId)
	if not tbQuestion then
		Log("[x] ChuanZhenQiQiaoAct:IsAnswerRight", nId, nAnswerId)
		return false
	end
	return tbQuestion.nAnswerId==nAnswerId
end

function tbAct:GetQuestionSetting(nId)
	return self.tbQuestions[nId]
end

if MODULE_GAMECLIENT then
	function tbAct:OnSyncMatchState(tbState)
		self.tbState = tbState
		if not tbState.bStarted then
			self.tbData = nil
		end
		local szUiName = "ChuanZhenQiQiaoPanel"
		if Ui:WindowVisible(szUiName) ~= 1 then
			Ui:OpenWindow(szUiName)
			return
		end
		Ui(szUiName):Refresh()
	end

	function tbAct:OnUpdateData(tbData)
		local bNewRight = false
		if self.tbData and self.tbData.nRight ~= tbData.nRight then
			bNewRight = true
		end
		self.tbData = tbData
		self.tbData.nDeadline = GetTime() + tbData.nTimeLeft
		local szUiName = "ChuanZhenQiQiaoPanel"
		if Ui:WindowVisible(szUiName) ~= 1 then
			Ui:OpenWindow(szUiName)
			return
		end
		Ui(szUiName):Refresh()
		if bNewRight then
			Ui(szUiName):PlayAnimation()
		end
	end

	function tbAct:OnSyncAnswer(nAnswerIdx)
		local szUiName = "ChuanZhenQiQiaoPanel"
		if Ui:WindowVisible(szUiName) ~= 1 then
			return
		end
		Ui(szUiName):OnSyncAnswer(nAnswerIdx)
	end
end