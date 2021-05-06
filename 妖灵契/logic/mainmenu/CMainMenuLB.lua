local CMainMenuLB = class("CMainMenuLB", CBox)

function CMainMenuLB.ctor(self, obj)
	CBox.ctor(self, obj)

	-- self.m_TeamBox = self:NewUI(1, CBox)
	self.m_ChatBox = self:NewUI(2, CMainMenuChatBox)
	self.m_ExpSlider = self:NewUI(3, CSlider)
	self.m_ExpCurLabel = self:NewUI(4, CLabel)
	self.m_ExpNextLabel = self:NewUI(5, CLabel)
	self.m_ExpDivLabel = self:NewUI(6, CLabel)
	self.m_ExpGroup = self:NewUI(7, CBox)
	self.m_QuestionAnswer = self:NewUI(8, CBox)
	self.m_SocialityPart = self:NewUI(9, CSocialityPart)
	self.m_MonsterAtkCityInfoPart = self:NewUI(10, CMonsterAtkCityInfoPart)
	self.m_ActivityBox = self:NewUI(11, CBox)
	self:InitContent()
end

function CMainMenuLB.InitContent(self)
	self.m_ChatBox:AddUIEvent("click", callback(self, "ShowChat"))
	
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlMapEvent"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWarEvent"))
	g_MonsterAtkCityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMonsterAtkCityEvnet"))
	g_FieldBossCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnFieldBossEvent"))
	local QACtrl = g_ActivityCtrl:GetQuesionAnswerCtrl()
	QACtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnActivityEvent"))
	g_SceneExamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSceneExamEvent"))
	--TODO:策划说经验条有bug，临时隐藏 
	-- self.m_ExpSlider:SetActive(false)
	self:InitQuestionAnswer()
	--self:RefrehExp()
	self:CheckMonsterAtkCityInfoPart()
end

function CMainMenuLB.InitQuestionAnswer(self)
	self.m_QuestionAnswerLabel = self.m_QuestionAnswer:NewUI(1, CLabel)
	self.m_QuestionAnswer.m_Icon = self.m_QuestionAnswer:NewUI(2, CTexture)
	self.m_QuestionAnswer.m_Icon:AddUIEvent("click", callback(self, "OnShowQAView" ))
	self.m_QuestionAnswerLabel:AddUIEvent("click", callback(self, "OnShowQAView" ))
	self.m_QuestionAnswer:SetActive(false)
	self:UpdateQuestion(g_ActivityCtrl:GetQuesionAnswerCtrl():GetNotifyQuestion())
end

function CMainMenuLB.OnWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.Replace then
		self:CheckShow()
	end
	self:CheckUI()
end

function CMainMenuLB.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if oCtrl.m_EventData["dAttr"]["grade"] then
			self:CheckMonsterAtkCityInfoPart()
		end
		--self:RefrehExp(data.dPreAttr, data.dAttr)
	end
end

function CMainMenuLB.OnCtrlMapEvent(self, oCtrl)
	self:CheckMonsterAtkCityInfoPart()
end

function CMainMenuLB.OnActivityEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Activity.Event.QAState then
		self:UpdateQuestion(oCtrl.m_EventData)
	end
end

function CMainMenuLB.OnSceneExamEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SceneExam.Event.Notify then
		self:UpdateSceneExam(oCtrl.m_EventData)
	elseif oCtrl.m_EventID == define.SceneExam.Event.UpdateOpen then
		self:UpdateSceneExam(oCtrl.m_EventData)
	end
end

function CMainMenuLB.CheckShow(self)
	local bPrepare = g_WarCtrl:IsReplace()
	self:SetActive(not bPrepare)
end

function CMainMenuLB.SetActive(self, bActive)
	CObject.SetActive(self, bActive)
	-- if bActive then
	-- 	self.m_ChatBox:DelayCall(0, "RefreshAllMsg")
	-- end
end

function CMainMenuLB.CheckUI(self)
	local bWar = g_WarCtrl:IsWar()
	if bWar then
		self.m_QuestionAnswer:SetActive(false)
		self:SetActive(false)
	else
		if g_SceneExamCtrl:GetState() then
			if g_ActivityCtrl:IsActivityVisibleBlock("sceneexam") then
				self:UpdateSceneExam(g_SceneExamCtrl:GetData())	
			else
				self.m_QuestionAnswer:SetActive(false)
			end
		else
			if g_ActivityCtrl:IsActivityVisibleBlock("question") then
				self:UpdateQuestion(g_ActivityCtrl:GetQuesionAnswerCtrl():GetQuestionState())
			else
				self.m_QuestionAnswer:SetActive(false)
			end
		end
		self:SetActive(true)
		if g_SceneExamCtrl:IsInExam() and not g_SceneExamCtrl:IsPrepare() then
			self:SetActive(false)
		end
		
	end
end

function CMainMenuLB.RefrehExp(self, preData, curData)
	-- print("当前角色经验："..g_AttrCtrl:GetCurGradeExp().." 升级经验："..g_AttrCtrl:GetUpgradeExp())
	-- TODO:寫得好長，回頭拆分
	if not curData or not curData.exp then
		self.m_ExpSlider:SetValue(g_AttrCtrl:GetCurGradeExp()/g_AttrCtrl:GetUpgradeExp())		
		self.m_ExpCurLabel:SetText(tostring( math.floor(g_AttrCtrl:GetCurGradeExp())))
		self.m_ExpNextLabel:SetText(tostring( math.floor(g_AttrCtrl:GetUpgradeExp())))
	else
		if not curData.grade then
			curData.grade = g_AttrCtrl.grade
			preData.grade = g_AttrCtrl.grade
		end
		local preExpinfo = data.upgradedata.DATA[preData.grade]
		local nextExpinfo = data.upgradedata.DATA[preData.grade + 1]
		if not preExpinfo then		--等级为0的特殊处理
			preExpinfo = nextExpinfo
			preExpinfo.sum_player_exp = 0
		end
		if not nextExpinfo then		--满级的特殊处理
			self.m_ExpSlider:SetValue(g_AttrCtrl:GetCurGradeExp()/g_AttrCtrl:GetUpgradeExp())			
			self.m_ExpCurLabel:SetText(tostring( math.floor(g_AttrCtrl:GetCurGradeExp())))
			self.m_ExpNextLabel:SetText(tostring( math.floor(g_AttrCtrl:GetUpgradeExp())))
			return
		end
		local curGrade = -1
		local remainExp = curData.exp - preData.exp
		local addExp = 0
		local curExp = 0

		local function updateExp(delta)
			if addExp >= 1 then				--更新规则：按每个等级的经验更新量折半添加
				curExp = addExp/4 + curExp
				self.m_ExpSlider:SetValue(curExp/nextExpinfo.player_exp)
				self.m_ExpCurLabel:SetText(tostring( math.floor(g_AttrCtrl:GetCurGradeExp())))
				self.m_ExpNextLabel:SetText(tostring( math.floor(g_AttrCtrl:GetUpgradeExp())))
				addExp = addExp - addExp/4
			else
				if remainExp <= 0 then
					self.m_ExpSlider:SetValue(g_AttrCtrl:GetCurGradeExp()/g_AttrCtrl:GetUpgradeExp())	
					return false
				end
				if curGrade > 0 then
					curExp = 0
				else
					curGrade = preData.grade
					curExp = preData.exp - preExpinfo.sum_player_exp
				end
				preExpinfo = data.upgradedata.DATA[curGrade]
				nextExpinfo = data.upgradedata.DATA[curGrade + 1]
				curGrade = curGrade + 1
				if curExp + remainExp <= nextExpinfo.player_exp then
					addExp = remainExp
					remainExp = 0
				else
					addExp = nextExpinfo.player_exp - curExp
					remainExp = curExp + remainExp - nextExpinfo.player_exp
				end
			end
			return true
		end
		Utils.AddTimer(updateExp, 0.05, 0)
	end
end

function CMainMenuLB.ShowChat(self)
	CChatMainView:ShowView()
end

function CMainMenuLB.SetExpLabelActive(self, isShow)
	self.m_ExpGroup:SetActive(isShow)
end

CMainMenuLB.FirstShowView = true

function CMainMenuLB.UpdateQuestion(self, data)
	if not data then
		return
	end
	if g_WarCtrl:IsWar() then
		self.m_QuestionAnswer:SetActive(false)
		return
	end
	self.m_QuestionAnswerLabel:SetText(data["desc"])
	self.m_QustionTime = data["end_time"] - g_TimeCtrl:GetTimeS()
	self.m_QuestionAnswer:SetActive(self.m_QustionTime > 0)
	local rankdata = g_ActivityCtrl:GetQuesionAnswerCtrl():GetSARankList()
	
	if data["type"] == 2 and data["status"] == 2 and self.m_QustionTime > 0 and CMainMenuLB.FirstShowView then
		CMainMenuLB.FirstShowView = false
		self:OnShowQAView()
	end
	
	local function update()
		if Utils.IsNil(self) then
			return
		end
		self.m_QustionTime = data["end_time"] - g_TimeCtrl:GetTimeS()
		if self.m_QustionTime < 0 then
			if data["type"] == 2 and data["status"] == 1 then
				if not rankdata then
				end
			end
			self.m_QuestionAnswer:SetActive(false)
		else
			local str = self:GetTimeS(data["type"], self.m_QustionTime)
			self.m_QuestionAnswerLabel:SetText(data["desc"].."\n"..str)
			return true
		end
	end
	local function close()
		if Utils.IsNil(self) then
			return
		end
		self.m_QuestionAnswer:SetActive(false)
	end
		
	if self.m_QATimer then
		Utils.DelTimer(self.m_QATimer)
	end
	if data["status"] == 3 then
		Utils.AddTimer(close, 0, 5)
	else
		self.m_QATimer = Utils.AddTimer(update, 0.1, 0)
	end
end

function CMainMenuLB.GetTimeS(self, itype, iSec)
	local s = g_TimeCtrl:GetLeftTime(iSec)
	if itype == 1 then
		if iSec < 10 then
			return "#R"..s
		elseif iSec < 30 then
			return "#Y"..s
		else
			return s
		end
	elseif itype == 2 then
		if iSec < 30 then
			return "#R"..s
		elseif iSec < 180 then
			return "#Y"..s
		else
			return s
		end
	else
		return s
	end
end

function CMainMenuLB.OnShowQAView(self)
	if g_SceneExamCtrl:GetState() then
		if g_ActivityCtrl:ActivityBlockContrl("sceneexam") then
			self:OnShowSceneExam()
		end
	end
	local data = g_ActivityCtrl:GetQuesionAnswerCtrl():GetQuestionInfo()
	local statedata = g_ActivityCtrl:GetQuesionAnswerCtrl():GetQuestionState()
	if not statedata then
		return
	end

	if not g_ActivityCtrl:ActivityBlockContrl("question") then
		return
	end

	if data then
		if data["type"] == 1 then
			CChatMainView:ShowView(function(oView)
				oView:SwitchChannel(define.Channel.World)
			end)
			CQuestionAnswerView:ShowView(function (oView)
				oView:RefreshData(data)
			end)
		elseif data["type"] == 2 then
			CScoreAnswerView:ShowView(function (oView)
				oView:RefreshData(data)
			end)
		end
	elseif statedata["type"] == 1 and statedata["status"] == 1 then
		g_NotifyCtrl:FloatMsg("突击测验尚未开始，请稍后")
		
	elseif statedata["type"] == 2 and statedata["status"] == 1 then
		if self.m_QustionTime >= 0 then
			if g_ActivityCtrl:GetQuesionAnswerCtrl():GetSARankList() then
				CScoreAnswerView:ShowView(function (oView)
					oView:ShowWait(statedata["end_time"])
				end)
			else
				nethuodong.C2GSQuestionEnterMember()
			end
		else
			g_NotifyCtrl:FloatMsg("同学，你错过了准备期间的分组，下次要早点来哦~喵")
			self.m_QuestionAnswer:SetActive(false)
		end
	end
end

function CMainMenuLB.UpdateSceneExam(self, data)
	if not data then
		return
	end
	
	if self.m_SceneExamTimer then
		Utils.DelTimer(self.m_SceneExamTimer)
	end
	if g_WarCtrl:IsWar() then
		self.m_QuestionAnswer:SetActive(false)
		return
	end
	
	if g_SceneExamCtrl:IsInExam() then
		self.m_QuestionAnswer:SetActive(false)
		return
	end
	
	if not data or table.count(data) == 0 then
		self.m_QuestionAnswer:SetActive(false)
		return
	end
	self.m_QuestionAnswerLabel:SetText(data["notify_desc"])
	self.m_QustionTime = data["notify_end_time"] - g_TimeCtrl:GetTimeS()
	self.m_QuestionAnswer:SetActive(self.m_QustionTime > 0)
	
	local function update()
		if Utils.IsNil(self) then
			return
		end
		self.m_QustionTime = data["notify_end_time"] - g_TimeCtrl:GetTimeS()
		if self.m_QustionTime < 0 then
			self.m_QuestionAnswer:SetActive(false)
		else
			local str = self:GetTimeS(1, self.m_QustionTime)
			self.m_QuestionAnswerLabel:SetText(data["notify_desc"].."\n"..str)
			return true
		end
	end
	
	local function close()
		if Utils.IsNil(self) then
			return
		end
		self.m_QuestionAnswer:SetActive(false)
	end
	
	if data["status"] == 3 then
		Utils.AddTimer(close, 0, 5)
	else
		self.m_SceneExamTimer = Utils.AddTimer(update, 0.1, 0)
	end
end

function CMainMenuLB.OnShowSceneExam(self)
	if not g_SceneExamCtrl:GetRankList() then
		nethuodong.C2GSApplyQuestionScene()
		return
	end
	CSceneExamMainView:ShowView(function (oView)
		oView:ShowReadPage()
	end)
end

function CMainMenuLB.OnMonsterAtkCityEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.MonsterAtkCity.Event.Open then
		self:CheckMonsterAtkCityInfoPart()
	end
end

function CMainMenuLB.OnFieldBossEvent(self, oCtrl)
	if oCtrl.m_EventID == define.FieldBoss.Event.UpdataUIData then
		self:CheckMonsterAtkCityInfoPart()
	end
	
end

function CMainMenuLB.CheckMonsterAtkCityInfoPart(self)
	if g_ActivityCtrl:IsActivityVisibleBlock("MonsterAtk") then
		self.m_MonsterAtkCityInfoPart:SetActive(g_MonsterAtkCityCtrl:IsOpen())
	else
		self.m_MonsterAtkCityInfoPart:SetActive(false)
	end
end

return CMainMenuLB