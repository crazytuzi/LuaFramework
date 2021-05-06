local CQuestionAnswerCtrl = class("CQuestionAnswerCtrl", CCtrlBase)

function CQuestionAnswerCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetCtrl()
end

function CQuestionAnswerCtrl.ResetCtrl(self)
	self.m_QAData = {}
end

function CQuestionAnswerCtrl.NotifyQuestion(self, data)
	self.m_QAData["state"] = data
	if data["status"] == 3 then
		self.m_QAData["rank"] = {}
		self.m_QAData["question"] = nil
		self.m_QAData["result"] = {}
		CMainMenuLB.FirstShowView = false
	end
	self:OnEvent(define.Activity.Event.QAState, data)
end

function CQuestionAnswerCtrl.GetNotifyQuestion(self)
	return self.m_QAData["state"]
end

function CQuestionAnswerCtrl.AddQuestionInfo(self, data)
	self.m_QAData["question"] = data
	if data["type"] == 1 then
		self:AddQuestionMsg(data["id"], data["desc"])
	end
	self:OnEvent(define.Activity.Event.QAAdd, data)
end

function CQuestionAnswerCtrl.AddQuestionMsg(self, id, sQustion)
	local sLinkText = LinkTools.GenerateQAnswerLink(id, "本次突击测验的题目为："..sQustion)
	local dMsg = {
		channel = 1,
		text = sLinkText,
	}
	g_ChatCtrl:AddMsg(dMsg)
end

function CQuestionAnswerCtrl.ShowQAView(self)
	local data = self:GetQuestionInfo()
	if data and data["type"] == 1 then
		CQuestionAnswerView:ShowView(function (oView)
			oView:RefreshData(data)
		end)
	else
		g_NotifyCtrl:FloatMsg("答题已过期")
	end
end

function CQuestionAnswerCtrl.GetQuestionState(self)
	return self.m_QAData["state"]
end

function CQuestionAnswerCtrl.GetQuestionInfo(self)
	if not self.m_QAData["state"] or self.m_QAData["state"]["status"] ~= 2 then
		return nil
	end
	local data = self.m_QAData["question"]
	if data then
		if g_TimeCtrl:GetTimeS() > data["end_time"] then
			return nil
		else
			return data
		end
	else
		return nil
	end
end

function CQuestionAnswerCtrl.AnswerResult(self, data)
	if data["role"]["pid"] == g_AttrCtrl.pid or data["type"] == 1 then
		self.m_QAData["result"] = data
	end
	self:OnEvent(define.Activity.Event.QAResult, data)
end

function CQuestionAnswerCtrl.GetMyAnswerResult(self)
	return self.m_QAData["result"]
end

function CQuestionAnswerCtrl.IsRightAnswer(self)
	local result = self.m_QAData["result"]
	if result and result["type"] == 1 and result["result"] == 1 then
		return true
	end
	return false
end

function CQuestionAnswerCtrl.SetSARankList(self, teamid, score_list)
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

	self.m_QAData["rank"] = {teamid=teamid, score_list=score_list}
	if self.m_QAData["state"]["status"] == 1 then
		CScoreAnswerView:ShowView(function (oView)
			oView:ShowWait(self.m_QAData["state"]["end_time"])
		end)
	elseif self.m_QAData["state"]["status"] == 2 then
		CScoreAnswerView:ShowView(function (oView)
				oView:RefreshData(self:GetQuestionInfo())
			end)
	end
end

function CQuestionAnswerCtrl.SetSAReward(self, status)
	self:OnEvent(define.Activity.Event.SAReward, status)
end

function CQuestionAnswerCtrl.UpdateSARankList(self, teamid, score_info)
	if self.m_QAData["rank"] then
		if self.m_QAData["rank"]["teamid"] == teamid then
			local index = nil
			for i, dict in ipairs(self.m_QAData["rank"]["score_list"]) do
				if dict["pid"] == score_info["pid"] then
					index = i
					break
				end
			end
			if index then
				table.remove(self.m_QAData["rank"]["score_list"], index)
			end
			index = nil
			for i, dict in ipairs(self.m_QAData["rank"]["score_list"]) do
				if score_info["score"] ~= dict["score"] then
					if score_info["score"] > dict["score"] then
						index = i
						break
					end
				elseif score_info["question_idx"] ~= dict["question_idx"] then
					if score_info["question_idx"] < dict["question_idx"] then
						index = i
						break
					end
				elseif score_info["rank"] ~= dict["rank"] then
					if score_info["rank"] < dict["rank"] then
						index = i
						break
					end
					
				end
			
			end
			if index then
				table.insert(self.m_QAData["rank"]["score_list"], index, score_info)
			else
				table.insert(self.m_QAData["rank"]["score_list"], score_info)
			end
		end
	end
	if score_info["pid"] == g_AttrCtrl.pid then
		self:OnEvent(define.Activity.Event.SARefresh)
	end
end

function CQuestionAnswerCtrl.GetSARankList(self)
	if self.m_QAData["rank"] then
		return self.m_QAData["rank"]["score_list"]
	end
	return nil
end

function CQuestionAnswerCtrl.EnterActicity(self)
	local data = self:GetQuestionInfo()
	local statedata = self:GetQuestionState()
	local bopen = false
	if data then
		if data["type"] == 1 then
			CQuestionAnswerView:ShowView(function (oView)
				oView:RefreshData(data)
			end)
			CChatMainView:ShowView(function(oView)
				oView:SwitchChannel(define.Channel.World)
			end)
			bopen = true
		
		elseif data["type"] == 2 then
			CScoreAnswerView:ShowView(function (oView)
				oView:RefreshData(data)
			end)
			bopen = true
		end
	
	elseif statedata and statedata["type"] == 2 and statedata["status"] == 1 then
		if statedata["end_time"] - g_TimeCtrl:GetTimeS() >= 0 then
			if self:GetSARankList() then
				CScoreAnswerView:ShowView(function (oView)
					oView:ShowWait(statedata["end_time"])
				end)
			else
				nethuodong.C2GSQuestionEnterMember()
			end
			bopen = true
		end
	end
	return bopen
end

--是否在世界答题报名时间内
function CQuestionAnswerCtrl.IsInReadyTime(self)
	local b = false
	local time = g_TimeCtrl:GetTimeS()
	if time and time > 0 then
		local h = tonumber(os.date("%H",time))
		local m = tonumber(os.date("%M",time))
		if h == 11 and m >= 55 then
			b = true
		end
	end
	return b
end

return CQuestionAnswerCtrl