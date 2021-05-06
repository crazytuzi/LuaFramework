local CMainMenuExpandBox = class("CMainMenuExpandBox", CBox)

function CMainMenuExpandBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Content = self:NewUI(1, CObject)
	self.m_EquipFbPage = self:NewPage(2, CExpandEquipFbPage)
	self.m_PopBtn = self:NewUI(3, CButton)
	self.m_TeamBtn = self:NewUI(4, CButton, true, false)
	self.m_TaskBtn = self:NewUI(5, CButton, true, false)
	self.m_TaskPage = self:NewPage(6, CExpandTaskPage)
	self.m_TeamPage = self:NewPage(7, CExpandTeamPage)
	self.m_AnLeiPage = self:NewPage(8, CExpandAnLeiPage)
	self.m_YJFbPage = self:NewPage(9, CExpandYJFbPage)
	self.m_FieldBossPage = self:NewPage(10, CExpandYwBossPage)
	self.m_CaiQuanPage = self:NewPage(11, CExpandCaiQuanPage)
	self.m_LilianPage = self:NewPage(12, CExpandLilianPage)
	self.m_TeamPvpPage = self:NewPage(13, CExpandTeamPvpPage)
	self.m_ConvoyPage = self:NewPage(14, CExpandConvoyPage)
	self.m_WorldBossPage = self:NewPage(15, CExpandWorldBossPage)
	self.m_OrgWarPage = self:NewPage(16, CExpandOrgWarPage)
	self.m_DailyTrainPage = self:NewPage(17, CExpandDailyTrainPage)
	
	self.m_IsArrowPop = false
	self:InitContent()
end

function CMainMenuExpandBox.InitContent(self)
	self.m_PopBtn:AddUIEvent("click", callback(self, "OnPopBtn"))
	self.m_TeamBtn:AddUIEvent("click", callback(self, "OnTeamBtn"))
	self.m_TaskBtn:AddUIEvent("click", callback(self, "OnTaskBtn"))
	self.m_TeamBtn:SetGroup(self:GetInstanceID())
	self.m_TaskBtn:SetGroup(self:GetInstanceID())
	-- self.m_PopBtn:SetActive(false)
	g_EquipFubenCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEquipFubenEvent"))
	g_AnLeiCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAnLeiEvent"))
	g_ActivityCtrl:GetYJFbCtrl():AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlYJFubenEvent"))
	g_ActivityCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlActivityEvent"))
	g_FieldBossCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlFieldBossEvent"))
	g_TaskCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlTaskEvent"))
	g_TeamPvpCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTeamPvpEvent"))
	g_ConvoyCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnConvoyEvent"))
	g_SceneExamCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlSceneExam"))
	g_OrgWarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnOrgWarEvent"))
	--如果当前有装备副本任务，则显示装备副本标签
	self:DelayCall(0, "CheckPage")
	
	--self:BindMenuArea()

	local function delay()
		self:OnPopBtn()		
		return false
	end
	Utils.AddTimer(delay, 1, 0.5)
end

function CMainMenuExpandBox.BindMenuArea(self)
	local tweenPos = self.m_Content:GetComponent(classtype.TweenPosition)
	local tweenRotation = self.m_PopBtn:GetComponent(classtype.TweenRotation)
	local callback = function()
		tweenRotation:Toggle()
	end
	g_MainMenuCtrl:AddPopArea(define.MainMenu.AREA.Task, tweenPos, callback, false)

end

function CMainMenuExpandBox.OnPopBtn(self)
	-- 点击主界面扩展弹出缩进按钮
	-- self:Pop()
	if g_MainMenuCtrl:GetAreaStatus(define.MainMenu.AREA.Task) then
		g_MainMenuCtrl:HideArea(define.MainMenu.AREA.Task)
	else
		g_MainMenuCtrl:ShowArea(define.MainMenu.AREA.Task)
	end
end

function CMainMenuExpandBox.OnTeamBtn(self, oBtn)
	if self.m_TeamBtn:GetSelected() then
		CTeamMainView:ShowView(function (oView )
			oView:ShowTeamPage(CTeamMainView.Tab.TeamMain)
		end)
	else
		self:ShowTeamPage()
	end
end

function CMainMenuExpandBox.OnTaskBtn(self, oBtn)
	--如果当前有装备副本任务，则显示装备副本标签
	if g_EquipFubenCtrl:IsInEquipFB() then
		if not self.m_TaskBtn:GetSelected() then
			self:ShowEquipFbPage()
		end
	elseif g_AnLeiCtrl:IsInAnLei() then
		if not self.m_TaskBtn:GetSelected() then
			self:ShowAnLeiPage()
		end
	elseif g_ActivityCtrl:GetYJFbCtrl():IsInFuben() then
		if not self.m_TaskBtn:GetSelected() then
			self:ShowYJFbPage()
		end
	else
		if self.m_TaskBtn:GetSelected() then
			CTaskMainView:ShowView(function (oView)
				oView:ShowDefaultTask()
			end)
		else
			self:ShowTaskPage()
		end
	end
end

function CMainMenuExpandBox.OnCtrlEquipFubenEvent(self, oCtrl)
	if oCtrl.m_EventID == define.EquipFb.Event.BeginFb then		
		self:ShowEquipFbPage()

	elseif oCtrl.m_EventID == define.EquipFb.Event.EndFb then
		if not self.m_TeamBtn:GetSelected() then
			self:ShowTaskPage()
		end
	end
end

function CMainMenuExpandBox.OnCtrlYJFubenEvent(self, oCtrl)
	if oCtrl.m_EventID == define.RJFuben.Event.EnterFuben then
		self:ShowYJFbPage()
	
	elseif oCtrl.m_EventID == define.RJFuben.Event.CloseFuben then
		if not self.m_TeamBtn:GetSelected() then
			self:CheckPage()
		end
	end
end

function CMainMenuExpandBox.OnCtrlAnLeiEvent(self, oCtrl)
	if oCtrl.m_EventID == define.AnLei.Event.BeginPatrol then	
		self:ShowAnLeiPage()

	elseif oCtrl.m_EventID == define.AnLei.Event.EndPatrol then
		if not self.m_TeamBtn:GetSelected() then
			self:CheckPage()
		end
	end
end

function CMainMenuExpandBox.OnCtrlFieldBossEvent(self, oCtrl)
	if oCtrl.m_EventID == define.FieldBoss.Event.UpdataUIData then
		self:ShowFieldBossPage()
	
	elseif oCtrl.m_EventID == define.FieldBoss.Event.EndFieldBoss then
		if not self.m_TeamBtn:GetSelected() then
			self:CheckPage()
		end
	end
end

function CMainMenuExpandBox.OnCtrlTaskEvent(self, oCtrl)
	self:DelayCall(0, "CheckPage")
end

function CMainMenuExpandBox.ShowSubPage(self, oPage)
	CGameObjContainer.ShowSubPage(self, oPage)
	self:DelayCall(0, "RefreshMainMenuChatBoxSize")
end

function CMainMenuExpandBox.RefreshMainMenuChatBoxSize(self)
	local oView = CMainMenuView:GetView()
	if oView then
		local lb = oView.m_LB
		if lb then
			lb.m_ChatBox:RefreshSize(self.m_CurPage ~= self.m_TaskPage)
		end
	end
end

function CMainMenuExpandBox.ShowTaskPage(self)
	self.m_TaskBtn:SetSelected(true)
	self:ShowSubPage(self.m_TaskPage)
end

function CMainMenuExpandBox.ShowTeamPage(self)
	self.m_TeamBtn:SetSelected(true)
	self:ShowSubPage(self.m_TeamPage)  
end

function CMainMenuExpandBox.ShowEquipFbPage(self)
	self.m_TaskBtn:SetSelected(true)
	self:ShowSubPage(self.m_EquipFbPage)  
end

function CMainMenuExpandBox.ShowAnLeiPage(self)
	self.m_TaskBtn:SetSelected(true)
	self:ShowSubPage(self.m_AnLeiPage)  
end

function CMainMenuExpandBox.ShowYJFbPage(self)
	self.m_TaskBtn:SetSelected(true)
	self:ShowSubPage(self.m_YJFbPage)  
end

function CMainMenuExpandBox.ShowFieldBossPage(self)
	self.m_TaskBtn:SetSelected(true)
	self:ShowSubPage(self.m_FieldBossPage)
end

function CMainMenuExpandBox.ShowCaiQuanPage(self)
	self.m_TaskBtn:SetSelected(true)
	self:ShowSubPage(self.m_CaiQuanPage)
end

function CMainMenuExpandBox.ShowLLilianPage(self)
	self.m_TaskBtn:SetSelected(true)
	self:ShowSubPage(self.m_LilianPage)
end

function CMainMenuExpandBox.ShowTeamPvpPage(self)
	self.m_TaskBtn:SetSelected(true)
	self:ShowSubPage(self.m_TeamPvpPage)
end

function CMainMenuExpandBox.ShowConvoyPage(self)
	self.m_TaskBtn:SetSelected(true)
	self:ShowSubPage(self.m_ConvoyPage)
end

function CMainMenuExpandBox.ShowOrgWarPage(self)
	self.m_TaskBtn:SetSelected(true)
	self:ShowSubPage(self.m_OrgWarPage)
end

function CMainMenuExpandBox.ShowWorldBossPage(self)
	self.m_TaskBtn:SetSelected(true)
	self:ShowSubPage(self.m_WorldBossPage)
end

function CMainMenuExpandBox.ShowDailyTrainPage(self)
	self.m_TaskBtn:SetSelected(true)
	self:ShowSubPage(self.m_DailyTrainPage)
end

function CMainMenuExpandBox.OnCtrlActivityEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Activity.Event.DCAddTeam then
		self:ShowLLilianPage()
	elseif oCtrl.m_EventID == define.Activity.Event.DCLeaveTeam then
		self:DelayCall(0, "CheckPage")
	elseif oCtrl.m_EventID == define.Activity.Event.WolrdBossScene then
		self:DelayCall(0, "CheckPage")
	elseif oCtrl.m_EventID == define.Activity.Event.DTUpdate then
		self:DelayCall(0, "CheckPage")
	end
end

function CMainMenuExpandBox.CheckPage(self)
	self:SetActive(true)
	if g_EquipFubenCtrl:IsInEquipFB() then
		self:ShowEquipFbPage()
	elseif g_AnLeiCtrl:IsInAnLei() then
		self:ShowAnLeiPage()
	elseif g_ActivityCtrl:GetYJFbCtrl():IsInFuben() then
		self:ShowYJFbPage()
	elseif g_FieldBossCtrl:IsOpen() then
		self:ShowFieldBossPage()
	elseif g_ActivityCtrl:IsDailyCultivating() then
		self:ShowLLilianPage()
	elseif g_TeamPvpCtrl:IsInTeamPvpScene() then
		self:ShowTeamPvpPage()
	elseif g_ConvoyCtrl:IsConvoying() then
		self:ShowConvoyPage()
	elseif g_TaskCtrl:GetCaiQuanFuBenTask() and g_TreasureCtrl:IsInChuanshuoScene() then
		self:ShowCaiQuanPage()
	elseif g_ActivityCtrl:InWorldBossFB() then
		self:ShowWorldBossPage()
	elseif g_SceneExamCtrl:IsInExam() then
		self:SetActive(false)
	elseif g_OrgWarCtrl:IsInOrgWarScene() then
		self:ShowOrgWarPage()
	elseif g_ActivityCtrl:IsDailyTraining() then
		self:ShowDailyTrainPage()
	else
		self:ShowTaskPage()
	end
	g_GuideCtrl:TriggerAll()
end

function CMainMenuExpandBox.OnTeamPvpEvent(self, oCtrl)
	self:DelayCall(0, "CheckPage")
end

function CMainMenuExpandBox.OnConvoyEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Convoy.Event.UpdateConvoyInfo then
		self:DelayCall(0, "CheckPage")
	end
end

function CMainMenuExpandBox.OnCtrlSceneExam(self, oCtrl)
	if oCtrl.m_EventID == define.SceneExam.Event.UpdateOpen then
		self:DelayCall(0, "CheckPage")
	end
end

function CMainMenuExpandBox.OnOrgWarEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Org.Event.EnterOrgWarScene or oCtrl.m_EventID == define.Org.Event.LeaveOrgWarScene 
		or oCtrl.m_EventID == define.Org.Event.OnUpdateBlood then
		self:DelayCall(0, "CheckPage")
	end
end

return CMainMenuExpandBox

