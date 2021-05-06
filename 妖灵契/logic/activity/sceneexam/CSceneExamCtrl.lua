local CSceneExamCtrl = class("CSceneExamCtrl", CCtrlBase)

define.SceneExam = {
	Event = {
		Notify = 1,
		UpdateRank = 2,
		UpdateOpen = 3,
	}
}

function CSceneExamCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:InitCtrl()
end

function CSceneExamCtrl.InitCtrl(self)
	self.m_Data = {}
end

function CSceneExamCtrl.RestCtrl(self)
	self.m_Data = {}
	self.m_Open = 0
end

function CSceneExamCtrl.IsInExam(self)
	return self.m_Open == 1
end

function CSceneExamCtrl.IsPrepare(self)
	if self.m_Data["status"] == 1 then
		return true
	else
		return false
	end
end

function CSceneExamCtrl.SetOpen(self, iOpen)
	self.m_Open = iOpen
	self:OnEvent(define.SceneExam.Event.UpdateOpen, self.m_Data)
	local mainView = CMainMenuView:GetView()
	if self:IsInExam() then
		CSceneExamLeftView:ShowView()
		if mainView then
			mainView:SetSceneExamMode(true)
			if self.m_Data["status"] == 1 then
				mainView.m_LB:SetActive(true)
			end
		end
	else
		if mainView then
			mainView:SetSceneExamMode(false)
		end
	end
end

function CSceneExamCtrl.AddQuestionInfo(self, dQuestion)
	self.m_Data["desc"] = dQuestion.desc
	self.m_Data["end_time"] = dQuestion.end_time
	self.m_Data["answer_list"] = dQuestion.answer_list
	self.m_Data["id"] = dQuestion.id
	local oView = CSceneExamMainView:GetView()
	if oView then
		oView:ShowExamPage()
		oView:UpdateQuestion()
	else
		CSceneExamMainView:ShowView(function (oView)
			oView:ShowExamPage()
			oView:UpdateQuestion()
		end)
	end
end

function CSceneExamCtrl.NotifyQuestion(self, dNotify)
	self.m_Data["status"] = dNotify.status
	self.m_Data["notify_desc"] = dNotify.desc
	self.m_Data["notify_end_time"] = dNotify.end_time
	self:OnEvent(define.SceneExam.Event.Notify, self.m_Data)
	if dNotify.status == 3 then
		if self.m_Data["rank"] and self.m_Data["rank"]["score_list"] then
			local rankdata = self.m_Data["rank"]["score_list"]
			CQARankView:ShowView(function (oView)
				oView:RefreshData(rankdata, true)
			end)
		end
		self.m_Data = {}
		--self:OnEvent(define.SceneExam.Event.UpdateOpen, self.m_Data)
	end
end

function CSceneExamCtrl.SetRankList(self, id, score_list)
	table.sort(score_list, function(a1, a2)
		if a1["score"] ~= a2["score"] then
			if a1["score"] > a2["score"] then
				return true
			else
				return false
			end
		end
		if a1["question_idx"] ~= a2["question_idx"] then
			if a1["question_idx"] < a2["question_idx"] then
				return true
			else
				return false
			end
		end
		if a1["rank"] ~= a2["rank"] then
			if a1["rank"] < a2["rank"] then
				return true
			else
				return false
			end
		end
	end)

	self.m_Data["rank"] = {id=id, score_list=score_list}
	local oView = CSceneExamMainView:GetView()
	if not oView and not self:IsInExam() then
		CSceneExamMainView:ShowView(function (oView)
			oView:ShowReadPage()
		end)
	end
	self:OnEvent(define.SceneExam.Event.UpdateRank)
end

function CSceneExamCtrl.AddResult(self, dResultList)
	if self:IsInExam() then
		for _, dResult in ipairs(dResultList) do
			local pid = dResult.pid
			local score = dResult.score
			local reward = dResult.reward
			local bFirst, bRight, sRight, sReward = self:GetExtraInfoStr(dResult.extra_info)
			local oWalker = g_MapCtrl:GetPlayer(pid)
			if oWalker then
				oWalker:StopWalk()
				if dResult.result == 1 then
					sReward = string.format("奖励 + %s%%", sReward)
					oWalker:SetSceneExamAmount(tonumber(sRight), sReward, pid == g_AttrCtrl.pid)
					local t = {display_id = Utils.RandomInt(10001, 10003), start_time = g_TimeCtrl:GetTimeS() }
					g_SocialityCtrl:Play(t, oWalker)
				else
					oWalker:CrossFade("dizzy")
					oWalker:CreateStateObj(1017)
				end
				if g_AttrCtrl.pid == pid then
					local oView = CSceneExamLeftView:GetView()
					if oView and dResult.result == 1 then
						oView:SetResult(true)
					elseif oView then
						oView:SetResult(false)
					end
				end
			end
		end
		local function delay()
			if Utils.IsNil(self) then
				return
			end
			for _, dResult in ipairs(dResultList) do
				local oWalker = g_MapCtrl:GetPlayer(dResult.pid)
				if oWalker then
					oWalker:StopWalk()
					oWalker:ClearStateObj(1017)
				end
			end
		end
		Utils.AddTimer(delay, 0, 4)
	end
end

function CSceneExamCtrl.GetExtraInfoStr(self, str)
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
			end
			if string.find(v, "first") then
				sFirst = string.split(v, "=")[2]
				bFirst = true
			end
			if string.find(v, "reward") then
				sReward = string.split(v, "=")[2]
			end
		end
	end
	return bFirst, bRight, sRight, sReward
end

function CSceneExamCtrl.AnswerResult(self, dAnswer)
	
end

function CSceneExamCtrl.GetState(self)
	return self.m_Data["status"]
end

function CSceneExamCtrl.GetData(self)
	return self.m_Data
end

function CSceneExamCtrl.GetQuestion(self)
	return self.m_Data
end

function CSceneExamCtrl.GetRankList(self)
	if self.m_Data["rank"] then
		return self.m_Data["rank"]["score_list"]
	end
end


return CSceneExamCtrl