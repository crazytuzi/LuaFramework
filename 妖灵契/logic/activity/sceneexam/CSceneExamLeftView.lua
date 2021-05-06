local CSceneExamLeftView = class("CSceneExamLeftView", CViewBase)

function CSceneExamLeftView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/SceneExam/SceneExamLeftView.prefab", cb)
	self.m_DepthType = "Dialog"
end

function CSceneExamLeftView.OnCreateView(self)
	self.m_ShowGroup = self:NewUI(1, CObject)
	self.m_HideGroup = self:NewUI(2, CObject)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_Grid = self:NewUI(4, CGrid)
	self.m_ExitBtn = self:NewUI(5, CButton)
	self.m_MiniBtn = self:NewUI(6, CSprite)
	self.m_RankBox = self:NewUI(7, CBox)
	self.m_ExpandBtn = self:NewUI(8, CSprite)
	self.m_MyRankBox = self:NewUI(9, CBox)
	self.m_DigitSpr = self:NewUI(10, CSprite)
	self.m_FailObj = self:NewUI(11, CObject)
	self.m_WinObj = self:NewUI(12, CObject)
	self.m_TipBtn = self:NewUI(13, CButton)
	self.m_ExitBtn2 = self:NewUI(14, CButton)
	self.m_MyRankBox2 = self:NewUI(15, CBox)
	self.m_Container = self:NewUI(16, CWidget)
	self.m_LeftTimeLabel = self:NewUI(17, CLabel)
	self:InitContent()
end

function CSceneExamLeftView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_RankBox:SetActive(false)
	self.m_MiniBtn:AddUIEvent("click", callback(self, "OnMini"))
	self.m_ExitBtn:AddUIEvent("click", callback(self, "OnExit"))
	self.m_ExitBtn2:AddUIEvent("click", callback(self, "OnExit"))
	self.m_ExpandBtn:AddUIEvent("click", callback(self, "OnExpand"))
	self.m_MyRankLabel = self.m_MyRankBox:NewUI(1, CLabel)
	self.m_MyNameLabel = self.m_MyRankBox:NewUI(2, CLabel)
	self.m_MyScoreLabel = self.m_MyRankBox:NewUI(3, CLabel)
	self.m_MyRankLabel2 = self.m_MyRankBox2:NewUI(1, CLabel)
	self.m_MyNameLabel2 = self.m_MyRankBox2:NewUI(2, CLabel)
	self.m_MyScoreLabel2 = self.m_MyRankBox2:NewUI(3, CLabel)
	self.m_DigitSpr:SetActive(false)
	self.m_DigitSpr.m_Tween = self.m_DigitSpr:GetComponent(classtype.UITweener)
	self.m_FailObj:SetActive(false)
	self.m_WinObj:SetActive(false)
	self.m_LeftTimeLabel:SetActive(false)
	self.m_FailObj.m_Tween = self.m_FailObj:GetComponent(classtype.UITweener)
	self.m_WinObj.m_Tween = self.m_WinObj:GetComponent(classtype.UITweener)
	self.m_TipBtn:AddHelpTipClick("scene_exam")
	self:OnExpand()
	self:UpdateRank()
	self:SetBegin()
	g_SceneExamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnSceneExamEvent"))
end

function CSceneExamLeftView.OnSceneExamEvent(self, oCtrl)
	if oCtrl.m_EventID == define.SceneExam.Event.UpdateRank then
		self:UpdateRank()
	
	elseif oCtrl.m_EventID == define.SceneExam.Event.UpdateOpen then
		if not g_SceneExamCtrl:IsInExam() then
			self:OnClose()
		end
	end
end

function CSceneExamLeftView.UpdateRank(self)
	self.m_Grid:Clear()
	local rankList = g_SceneExamCtrl:GetRankList()
	rankList = rankList or {}
	local dMyrank = nil
	for i, dRank in ipairs(rankList) do
		local oBox = self.m_RankBox:Clone()
		oBox.m_RankLabel = oBox:NewUI(1, CLabel)
		oBox.m_NameLabel = oBox:NewUI(2, CLabel)
		oBox.m_ScoreLabel = oBox:NewUI(3, CLabel)
		oBox.m_RankLabel:SetText(tostring(i)..".")
		oBox.m_NameLabel:SetText(dRank.name)
		oBox.m_ScoreLabel:SetText(tostring(dRank.score))
		oBox:SetActive(true)
		self.m_Grid:AddChild(oBox)
		if dRank.pid == g_AttrCtrl.pid then
			dMyrank = {rank = i, score = dRank.score}
		end
	end
	self.m_Grid:Reposition()
	if dMyrank then
		self.m_MyRankBox:SetActive(true)
		self.m_MyRankLabel:SetText(tostring(dMyrank.rank)..".")
		self.m_MyNameLabel:SetText(g_AttrCtrl.name)
		self.m_MyScoreLabel:SetText(dMyrank.score)
		self.m_MyRankLabel2:SetText(tostring(dMyrank.rank)..".")
		self.m_MyNameLabel2:SetText(g_AttrCtrl.name)
		self.m_MyScoreLabel2:SetText(dMyrank.score)
	else
		self.m_MyRankBox:SetActive(false)
	end
end

function CSceneExamLeftView.SetBegin(self)
	local t2size = {
		[0] = {390, 94},
		[1] = {62,  110},
		[2] = {115, 110},
		[3] = {109, 110},
		[4] = {111, 110},
		[5] = {106, 110},
	}
	local dData = g_SceneExamCtrl:GetData()
	local function update()
		if Utils.IsNil(self) then
			return
		end
		local d = g_SceneExamCtrl:GetData()
		self.m_LeftTimeLabel:SetActive(false)
		if not d or d["status"] ~= 1 then
			self.m_DigitSpr:SetActive(false)
			local mainView = CMainMenuView:GetView()
			mainView.m_LB:SetActive(false)
			return
		end
		local t = d["notify_end_time"] - g_TimeCtrl:GetTimeS()
		if t > 6 then
			self.m_LeftTimeLabel:SetActive(true)
			self.m_LeftTimeLabel:SetText(string.format("答题开始：[4ddc75]%s[-]", g_TimeCtrl:GetLeftTime(t)))
			return true
		elseif t >= 0 then
			self.m_LeftTimeLabel:SetActive(true)
			self.m_LeftTimeLabel:SetText(string.format("答题开始：[4ddc75]%s[-]", g_TimeCtrl:GetLeftTime(t)))
			self.m_DigitSpr:SetActive(true)
			local idx = tonumber(math.max(t-1, 0))
			self.m_DigitSpr:SetSpriteName(string.format("pic_cjdi_%d", idx))
			if self.m_DigitSpr.m_Idx ~= idx then
				self.m_DigitSpr.m_Tween:ResetToBeginning()
				self.m_DigitSpr.m_Tween:Play(true)
			end
			self.m_DigitSpr.m_Idx = idx
			if t2size[idx] then
				self.m_DigitSpr:SetSize(t2size[idx][1], t2size[idx][2])
			end
			return true
		else
			local mainView = CMainMenuView:GetView()
			mainView.m_LB:SetActive(false)
			return
		end
	end
	if self.m_BeginTimer then
		Utils.DelTimer(self.m_BeginTimer)
		self.m_BeginTimer = nil
	end
	if dData and dData["status"] == 1 then
		self.m_BeginTimer = Utils.AddTimer(update, 0.2, 0)
	end
end

function CSceneExamLeftView.SetResult(self, bRight)
	if bRight then
		self.m_WinObj:SetActive(true)
		self.m_FailObj:SetActive(false)
		self.m_WinObj.m_Tween:ResetToBeginning()
		self.m_WinObj.m_Tween:Play(true)
	else
		self.m_WinObj:SetActive(false)
		self.m_FailObj:SetActive(true)
		self.m_FailObj.m_Tween:ResetToBeginning()
		self.m_FailObj.m_Tween:Play(true)
	end

	Utils.AddTimer(function ()
		if Utils.IsNil(self) then
			return
		end
		self.m_FailObj:SetActive(false)
		self.m_WinObj:SetActive(false)
	end, 0, 2)
end

function CSceneExamLeftView.OnMini(self)
	self.m_ShowGroup:SetActive(false)
	self.m_HideGroup:SetActive(true)
end

function CSceneExamLeftView.OnExpand(self)
	self.m_HideGroup:SetActive(false)
	self.m_ShowGroup:SetActive(true)
end

function CSceneExamLeftView.OnExit(self)
	local str = nil
	if g_SceneExamCtrl:GetState() == 1 then
		str = "活动马上就要开始了，确定退出？\n（12:00-12:10为进场时间）"
	elseif g_SceneExamCtrl:GetState() == 2 then
		str = "活动正在进行，确定退出？"
	end
	local windowConfirmInfo = {
		msg				= str,
		okCallback		= function ()				
			nethuodong.C2GSLeaveQuestionScene()
		end,
		okStr = "是",
		cancelStr = "否",			
	}
	if str then
		g_WindowTipCtrl:SetWindowConfirm(windowConfirmInfo)	
	else
		nethuodong.C2GSLeaveQuestionScene()
	end
	
end

return CSceneExamLeftView