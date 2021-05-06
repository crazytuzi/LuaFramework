local CScoreAnswerView = class("CScoreAnswerView", CViewBase)

function CScoreAnswerView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/QuestionAnswer/ScoreAnswerView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CScoreAnswerView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	
	self.m_RankPart = self:NewUI(2, CBox)
	self.m_QuestionPart = self:NewUI(3, CBox)
	self.m_ResultPart = self:NewUI(4, CBox)
	self.m_AnswerPart = self:NewUI(5, CBox)
	self.m_HelpBtn = self:NewUI(6, CButton)
	self.m_WaitPart = self:NewUI(7, CBox)
	self.m_EndPart = self:NewUI(8, CBox)
	self:InitContent()
end

function CScoreAnswerView.InitContent(self)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnShowHelp"))
	self:InitRankPart()
	self:InitQustionPart()
	self:InitResultPart()
	self:InitAnswerPart()
	self:InitWaitPart()
	local function updaterank()
		if Utils.IsNil(self) then
			return
		else
			self:UpdateRankList()
			return true
		end
	end
	self.m_RankTimer = Utils.AddTimer(updaterank, 10, 0)
	self:UpdateRankList()
	local QACtrl = g_ActivityCtrl:GetQuesionAnswerCtrl()
	QACtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnActivityEvent"))
end

function CScoreAnswerView.InitRankPart(self)
	self.m_RankGrid = self.m_RankPart:NewUI(1, CGrid)
	self.m_RankItem = self.m_RankPart:NewUI(2, CBox)
	self.m_SelfRankItem = self.m_RankPart:NewUI(3, CBox)
	self.m_SelfRankItem.m_Rank = self.m_SelfRankItem:NewUI(1, CLabel)
	self.m_SelfRankItem.m_Name = self.m_SelfRankItem:NewUI(2, CLabel)
	self.m_SelfRankItem.m_Score = self.m_SelfRankItem:NewUI(3, CLabel)
	self.m_SelfRankItem.m_AwardBtn = self.m_SelfRankItem:NewUI(4, CButton)
	self.m_SelfRankItem.m_Avatar = self.m_SelfRankItem:NewUI(5, CSprite)
	self.m_SelfRankItem.m_RankSprite = self.m_SelfRankItem:NewUI(6, CSprite)
	self.m_SelfRankItem.m_AwardBtn:AddUIEvent("click", callback(self, "GetSelfAward"))
	self.m_SelfRankItem:SetActive(false)
	self.m_RankItem:SetActive(false)
end

function CScoreAnswerView.InitQustionPart(self)
	self.m_QuestionLabel = self.m_QuestionPart:NewUI(1, CLabel)
	self.m_QuestonGoldLabel = self.m_QuestionPart:NewUI(2, CLabel)
	self.m_LeftTimeLabel = self.m_QuestionPart:NewUI(3, CLabel)
	self.m_QuestionPart:SetActive(true)
end

function CScoreAnswerView.InitResultPart(self)
	self.m_ResultTable = self.m_ResultPart:NewUI(1, CTable)
	self.m_ResultScoreView = self.m_ResultPart:NewUI(2, CScrollView)
	self.m_LeftResultItem = self.m_ResultPart:NewUI(3, CBox)
	self.m_RightResultItem = self.m_ResultPart:NewUI(4, CBox)
	self.m_LeftResultItem:SetActive(false)
	self.m_RightResultItem:SetActive(false)
	self.m_ResultPart:SetActive(true)
end

function CScoreAnswerView.InitAnswerPart(self)
	self.m_AnswerGrid = self.m_AnswerPart:NewUI(1, CGrid)
	self.m_AnswerItem = self.m_AnswerPart:NewUI(2, CButton)
	self.m_AnswerTip = self.m_AnswerPart:NewUI(3, CLabel)
	self.m_AnswerItem:SetActive(false)
	self.m_AnswerPart:SetActive(true)
end

function CScoreAnswerView.InitWaitPart(self)
	self.m_WaitTimeLabel = self.m_WaitPart:NewUI(1, CLabel)
	self.m_WaitPart:SetActive(false)
end

function CScoreAnswerView.OnActivityEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Activity.Event.QAAdd then
		self:RefreshData(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Activity.Event.QAResult then
		self:RefreshResult(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Activity.Event.SAReward then
		self:SetSAReward(oCtrl.m_EventData)
	
	elseif oCtrl.m_EventID == define.Activity.Event.SARefresh then
		self:UpdateRankList()
	end
end

function CScoreAnswerView.ShowWait(self, iTime)
	self.m_WaitPart:SetActive(true)
	self.m_QuestionPart:SetActive(false)
	self.m_ResultPart:SetActive(false)
	self.m_AnswerPart:SetActive(false)
	self.m_WaitTime = iTime - g_TimeCtrl:GetTimeS()
	local function updatetime()
		if Utils.IsNil(self) then
			return
		end
		self.m_WaitTime = iTime - g_TimeCtrl:GetTimeS()
		if self.m_WaitTime < 0 then
			local str = g_TimeCtrl:GetLeftTime(0)
			self.m_WaitTimeLabel:SetText(str)
			self.m_WaitPart:SetActive(false)
			self.m_QuestionPart:SetActive(true)
			self.m_ResultPart:SetActive(true)
			self.m_AnswerPart:SetActive(true)
			return false
		else
			local str = g_TimeCtrl:GetLeftTime(self.m_WaitTime)
			if self.m_WaitTime < 30 then
				self.m_WaitTimeLabel:SetText(str)
			else
				self.m_WaitTimeLabel:SetText(str)
			end
			return true
		end
	end
	if self.m_WaitTimer then
		Utils.DelTimer(self.m_WaitTimer)
	end
	self.m_WaitTimer = Utils.AddTimer(updatetime, 0.1, 0)
end

function CScoreAnswerView.RefreshData(self, data)
	self.m_Data = data
	local sQustion = data["desc"]
	local sAnswer = ""
	self.m_QuestionLabel:SetText(tostring(self.m_Data["id"]).."."..sQustion)
	self.m_QuestonGoldLabel:SetText(data["base_reward"])
	self.m_LeftTime = data["end_time"] - g_TimeCtrl:GetTimeS()
	self:CreateTimer()
	self:RefreshAnswer(data)
	self:RefreshLastAnswer()
end

function CScoreAnswerView.CreateTimer(self)
	local function updatetime()
		if Utils.IsNil(self) then
			return
		end
		self.m_LeftTime = self.m_Data["end_time"] - g_TimeCtrl:GetTimeS()
		if self.m_LeftTime < 0 then
			local str = g_TimeCtrl:GetLeftTime(0)
			self.m_LeftTimeLabel:SetText(str)
		else
			local str = g_TimeCtrl:GetLeftTime(self.m_LeftTime)
			if self.m_LeftTime < 30 then
				self.m_LeftTimeLabel:SetText(str)
			else
				self.m_LeftTimeLabel:SetText(str)
			end
			return true
		end
	end
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
	end
	self.m_Timer = Utils.AddTimer(updatetime, 0.1, 0)
end

function CScoreAnswerView.RefreshAnswer(self, data)
	self.m_AnswerGrid:SetActive(true)
	self.m_AnswerTip:SetActive(false)
	self.m_AnswerGrid:Clear()
	for i, s in ipairs(data["answer_list"]) do
		local itemobj = self.m_AnswerItem:Clone()
		itemobj:SetActive(true)
		itemobj:SetText(string.char(string.byte("A")+i-1)..".".. s)
		itemobj:AddUIEvent("click", callback(self, "OnAnswer", i))
		self.m_AnswerGrid:AddChild(itemobj)
	end
	self.m_AnswerGrid:Reposition()
	self.m_AnswerPart:ResetAndUpdateAnchors()
end

function CScoreAnswerView.RefreshLastAnswer(self)
	local result = g_ActivityCtrl:GetQuesionAnswerCtrl():GetMyAnswerResult()
	if result and result["type"] == 2 and result["id"] == self.m_Data["id"] and result["result"] == 1 then
		self:SetRightAnswer()
	end
end

function CScoreAnswerView.SetRightAnswer(self)
	self.m_AnswerGrid:SetActive(false)
	self.m_AnswerTip:SetActive(true)
end

function CScoreAnswerView.RefreshResult(self, data)
	if data["type"] == 2 then
		local resultItem = nil
		local isme = false
		if data["role"]["pid"] == g_AttrCtrl.pid then
			isme = true
			resultItem = self.m_RightResultItem:Clone()
			if data["result"] == 1 then
				self:SetRightAnswer()
			end
		else
			resultItem = self.m_LeftResultItem:Clone()
		end
		self:InitResultItem(resultItem)
		resultItem.m_TimeLabel:SetText(os.date("%H:%M:%S", data["time"]))
		resultItem.m_IconSpr:SpriteAvatar(data["role"]["model_info"]["shape"])
		if isme then
			resultItem.m_NameLabel:SetText(g_AttrCtrl.name)
		else
			resultItem.m_NameLabel:SetText(data["role"]["name"])
		end
		resultItem.m_AnswerSprite:SetSpriteName(string.format("pic_%s", string.char(string.byte("A")+data["answer"]-1)))
		resultItem.m_RightSpr:SetActive(data["result"] == 1)
		resultItem.m_WrongSpr:SetActive(data["result"] == 0)
		resultItem.m_GoldLabel:SetText(data["reward"])
		local bFirst, bRight, sRight, sReward = self:GetExtraInfoStr(data["extra_info"])
		resultItem.m_FirstSprite:SetActive(bFirst)
		resultItem.m_RightSprite:SetActive(bRight)
		resultItem.m_RightNumLabel:SetText(sRight)
		if sReward ~= "" then
			sReward = string.format("奖励 + %s%%", sReward)
			if bFirst then
				resultItem.m_FirstLabel:SetText(sReward)
			end
			if bRight then
				if not bFirst then
					resultItem.m_RightLabel:SetText(sReward)
				end
				resultItem.m_RightTweenScale.enabled = true
				local function tween()
					if Utils.IsNil(resultItem) then
						return
					end
					resultItem.m_RightTweenPosition.enabled = true
					resultItem.m_RightTweenAlpha.enabled = true
				end
				Utils.AddTimer(tween, 1, 1)
			end
		end
		self.m_ResultTable:AddChild(resultItem)
		self.m_ResultTable:Reposition()
		self.m_ResultScoreView:ResetPosition()
	end
end

function CScoreAnswerView.GetExtraInfoStr(self, str)
--{right=1,first=1,reward=200}
	local bFirst, bRight = false, false 
	local sRight, sFirst, sReward = "", "", ""
	if str and str ~= "" then
		local list = string.split(string.gsub(str, "[{}]", ""), ",")
		for i,v in ipairs(list) do
			if string.find(v, "right") then
				sRight = tonumber(string.split(v, "=")[2])
				if sRight > 1 then
					bRight = true
				end
				--printc("right:",first)
			end
			if string.find(v, "first") then
				sFirst = string.split(v, "=")[2]
				bFirst = true
				--printc("first:",first)
			end
			if string.find(v, "reward") then
				sReward = string.split(v, "=")[2]
				--printc("reward:",reward)
			end
		end
	end
	return bFirst, bRight, sRight, sReward
end

function CScoreAnswerView.InitResultItem(self, resultItem)
	resultItem:SetActive(true)
	resultItem.m_TimeLabel = resultItem:NewUI(1, CLabel)
	resultItem.m_AnswerSprite = resultItem:NewUI(2, CSprite)
	resultItem.m_RightSpr = resultItem:NewUI(3, CSprite)
	resultItem.m_WrongSpr = resultItem:NewUI(4, CSprite)
	resultItem.m_GoldLabel = resultItem:NewUI(5, CLabel)
	resultItem.m_NameLabel = resultItem:NewUI(6, CLabel)
	resultItem.m_IconSpr = resultItem:NewUI(7, CSprite)
	resultItem.m_FirstSprite = resultItem:NewUI(8, CSprite)
	resultItem.m_FirstLabel = resultItem:NewUI(9, CLabel)
	resultItem.m_RightSprite = resultItem:NewUI(10, CSprite)
	resultItem.m_RightNumLabel = resultItem:NewUI(11, CLabel)
	resultItem.m_RightLabel = resultItem:NewUI(12, CLabel)
	resultItem.m_RightTweenScale = resultItem.m_RightSprite:GetComponent(classtype.TweenScale)
	resultItem.m_RightTweenPosition = resultItem.m_RightSprite:GetComponent(classtype.TweenPosition)
	resultItem.m_RightTweenAlpha = resultItem.m_RightSprite:GetComponent(classtype.TweenAlpha)
	resultItem.m_RightTweenScale.enabled = false
	resultItem.m_RightTweenPosition.enabled = false
	resultItem.m_RightTweenAlpha.enabled = false
	resultItem.m_FirstSprite:SetActive(false)
	resultItem.m_RightSprite:SetActive(false)
end

function CScoreAnswerView.UpdateRankList(self)
	self.m_RankList = g_ActivityCtrl:GetQuesionAnswerCtrl():GetSARankList()
	if not self.m_RankList then
		return
	end
	self.m_RankGrid:Clear()
	local myscore = nil
	local myrank = 1
	for i, score_info in ipairs(self.m_RankList) do
		if i < 11 then
			local itemobj = self.m_RankItem:Clone()
			itemobj:SetActive(true)
			itemobj.m_Rank = itemobj:NewUI(1, CLabel)
			itemobj.m_Name = itemobj:NewUI(2, CLabel)
			itemobj.m_Score = itemobj:NewUI(3, CLabel)
			itemobj.m_FirstBG = itemobj:NewUI(4, CSprite)
			itemobj.m_Avatar = itemobj:NewUI(5, CSprite)
			itemobj.m_RankSprite = itemobj:NewUI(6, CSprite)
			itemobj.m_FirstBG:SetActive(i == 1)
			local bSpr = i < 4
			itemobj.m_RankSprite:SetActive(bSpr)
			itemobj.m_Rank:SetActive(not bSpr)
			if bSpr then
				itemobj.m_RankSprite:SetSpriteName("pic_rank_" .. i)
			else
				itemobj.m_Rank:SetText(tostring(i))
			end
			itemobj.m_Name:SetText(score_info["name"])
			itemobj.m_Avatar:SpriteAvatar(score_info["model_info"]["shape"])
			itemobj.m_Score:SetText(tostring(score_info["score"]))
			self.m_RankGrid:AddChild(itemobj)
		end
		if score_info["pid"] == g_AttrCtrl.pid then
			myscore = score_info
			myrank = i
		end
	end
	if myscore then
		self.m_SelfRankItem:SetActive(true)
		self.m_SelfRankItem.m_Name:SetText(g_AttrCtrl.name)
		local bSpr = myrank < 4
		self.m_SelfRankItem.m_RankSprite:SetActive(bSpr)
		self.m_SelfRankItem.m_Rank:SetActive(not bSpr)
		if bSpr then
			self.m_SelfRankItem.m_RankSprite:SetSpriteName("pic_rank_" .. myrank)
		else
			self.m_SelfRankItem.m_Rank:SetText(tostring(myrank))
		end
		self.m_SelfRankItem.m_Score:SetText(tostring(myscore["score"]))
		self.m_SelfRankItem.m_Avatar:SpriteAvatar(g_AttrCtrl.model_info.shape)
	end
	self.m_RankGrid:Reposition()
end

function CScoreAnswerView.SetSAReward(self, status)
	self.m_WaitPart:SetActive(false)
	self.m_QuestionPart:SetActive(false)
	self.m_ResultPart:SetActive(false)
	self.m_AnswerPart:SetActive(false)
	self.m_EndPart:SetActive(true)
	if status == 2 then
		self:OnClose()
	end
	if status == 0 then
		self:CloseView()
		CQARankView:ShowView(function (oView)
			oView:RefreshData(self.m_RankList)
		end)
	end
end

function CScoreAnswerView.CreateItem(self)
	local itemobj = self.m_AnswerItem:Clone()
	itemobj:SetActive(true)
	itemobj.m_Label = itemobj:NewUI(1, CLabel)
	itemobj.m_ErrorSpr = itemobj:NewUI(2, CSprite)
	itemobj.m_ErrorSpr:SetActive(false)
	return itemobj
end

function CScoreAnswerView.OnAnswer(self, idx)
	nethuodong.C2GSAnswerQuestion(self.m_Data["id"], self.m_Data["type"], idx)
end

function CScoreAnswerView.GetSelfAward(self)
	nethuodong.C2GSQuestionEndReward(1)
end

function CScoreAnswerView.CloseView(self)
	if self.m_SelfRankItem.m_AwardBtn:GetActive() then
		nethuodong.C2GSQuestionEndReward(2)
	end
	CHelpView:CloseView()
	CViewBase.CloseView(self)
end

function CScoreAnswerView.OnShowHelp(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp("question_answer")
	end)
end

return CScoreAnswerView
