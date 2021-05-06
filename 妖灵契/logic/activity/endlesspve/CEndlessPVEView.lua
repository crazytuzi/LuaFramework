local CEndlessPVEView = class("CEndlessPVEView", CViewBase)

function CEndlessPVEView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/EndlessPVE/EndlessPVEView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_GroupName = "main"
end

function CEndlessPVEView.OnCreateView(self)
	self.m_HelpBtn = self:NewUI(1, CButton)
	self.m_CloseBtn = self:NewUI(2, CButton)
	self.m_FightBtn = self:NewUI(3, CButton)
	self.m_TeamBtn = self:NewUI(4, CButton)
	self.m_MonsterGrid = self:NewUI(5, CGrid)
	-- self.m_RefreshBtn = self:NewUI(6, CButton)
	-- self.m_RefreshCostLabel = self:NewUI(7, CLabel)
	self.m_GuideMaskGrid = self:NewUI(8, CGrid)
	self.m_TipsLabel = self:NewUI(9, CLabel)
	self.m_Container = self:NewUI(10, CWidget)
	self.m_BgTexture = self:NewUI(11, CTexture)
	self:InitContent()
end

function CEndlessPVEView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container, 4, 4)
	UITools.ScaleToFit(self.m_BgTexture, nil)
	g_GuideCtrl:AddGuideUI("yuejian_help_btn", self.m_HelpBtn)
	-- self.m_RefreshBtn:AddUIEvent("click", callback(self, "OnClickRefresh"))
	self.m_HelpBtn:AddUIEvent("click", callback(self, "OnClickHelp"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_FightBtn:AddUIEvent("click", callback(self, "OnClickFight"))
	self.m_TeamBtn:AddUIEvent("click", callback(self, "OnClickTeam"))
	g_EndlessPVECtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnEndlessEvent"))

	self.m_GuideMaskGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox:AddUIEvent("click", callback(self, "ClickGuideMask"))
		return oBox
	end)

	self.m_MonsterGrid:InitChild(function(obj, idx)
		local oBtn = CBox.New(obj, false)
		oBtn.m_Btn = oBtn:NewUI(1, CBox)
		oBtn.m_OnSelectSprite = oBtn:NewUI(2, CSprite)
		oBtn.m_ActorTexture = oBtn:NewUI(3, CActorTexture)
		oBtn.m_LockLabel = oBtn:NewUI(4, CLabel)


		oBtn.m_OpenGrade = data.endlesspvedata.ModeInfo[idx].open_grade
		oBtn.m_LockLabel:SetText(string.format("%s级开放", oBtn.m_OpenGrade))
		oBtn.m_LockLabel:SetActive(oBtn.m_OpenGrade > g_AttrCtrl.grade)

		oBtn.m_Btn:AddUIEvent("click", callback(self, "OnSelect", oBtn))
		
		if idx == 2 then
			g_GuideCtrl:AddGuideUI("yuejian_monster_2", oBtn)
		end
		return oBtn
	end)
	
	self:SetData()
end

-- function CEndlessPVEView.OnClickRefresh(self)
-- 	if g_AttrCtrl.goldcoin < g_EndlessPVECtrl:GetRefreshCost() then
-- 		g_NotifyCtrl:FloatMsg("您的水晶不足")
-- 		g_SdkCtrl:ShowPayView()
-- 	else
-- 		nethuodong.C2GSRefreshChipList()
-- 	end
-- end

function CEndlessPVEView.SetData(self)
	self.m_CurrentMonsterBtn = nil
	-- self.m_RefreshCostLabel:SetText(g_EndlessPVECtrl:GetRefreshCost())
	local count = self.m_MonsterGrid:GetCount()
	for i = 1, count do
		local oBtn = self.m_MonsterGrid:GetChild(i)
		local oData = g_EndlessPVECtrl.m_ChipList[i]
		if oData then
			oBtn.m_ActorTexture:ChangeShape(oData.shape)
			oBtn.m_ActorTexture:SetColor(Color.black)
			oBtn.m_Data = oData
			oBtn.m_OnSelectSprite:SetActive(false)
			oBtn:SetActive(true)
		else
			oBtn:SetActive(false)
		end
	end
end

function CEndlessPVEView.OnEndlessEvent(self, oCtrl)
	if oCtrl.m_EventID == define.EndlessPVE.Event.OnReceiveChipList then
		self:SetData()
	end
end

function CEndlessPVEView.OnSelect(self, oMonsterBox)
	if oMonsterBox.m_OpenGrade > g_AttrCtrl.grade then
		g_NotifyCtrl:FloatMsg(string.format("%s级开放", oMonsterBox.m_OpenGrade))
		return
	end
	if self.m_CurrentMonsterBtn ~= nil then
		self.m_CurrentMonsterBtn.m_OnSelectSprite:SetActive(false)
		self.m_CurrentMonsterBtn.m_ActorTexture:SetColor(Color.black)
	end
	self.m_CurrentMonsterBtn = oMonsterBox
	self.m_CurrentMonsterBtn.m_OnSelectSprite:SetActive(true)
	self.m_CurrentMonsterBtn.m_ActorTexture:SetColor(Color.white)
	-- printc("OnSelect: " .. oMonsterBox.m_Data)
end

function CEndlessPVEView.OnClickHelp(self)
	CHelpView:ShowView(function (oView)
		oView:ShowHelp(define.Help.Key.EndlessPVE)
	end)
end

function CEndlessPVEView.OnClickFight(self)
	-- printc("OnClickFight")
	-- local memberSize = g_TeamCtrl:GetMemberSize()
	-- if memberSize > 1 and not g_TeamCtrl:IsLeader() then
	-- 	g_NotifyCtrl:FloatMsg("请先退出队伍")
	-- elseif memberSize > 2 then
	-- 	g_NotifyCtrl:FloatMsg("月见幻境需要进入人数2人以下")
	-- elseif self.m_CurrentMonsterBtn == nil then
	if self.m_CurrentMonsterBtn == nil then
		g_NotifyCtrl:FloatMsg("请选择副本难度")
	else
		g_EndlessPVECtrl:Fight(self.m_CurrentMonsterBtn.m_Data.mode)
	end
end

function CEndlessPVEView.OnClickTeam(self)
	if self.m_CurrentMonsterBtn == nil then
		g_NotifyCtrl:FloatMsg("请选择副本难度")
		return
	end
	local teamTargetId = data.endlesspvedata.ModeInfo[self.m_CurrentMonsterBtn.m_Data.mode].autoteamID
	-- printc("OnClickTeam: " .. teamTargetId)
	local defalutMin, defalutMax = g_TeamCtrl:GetTeamTargetDefaultLevel(teamTargetId)
	if g_TeamCtrl:GetMemberSize() == 0 then
		g_TeamCtrl:C2GSCreateTeam(teamTargetId, defalutMin, defalutMax)
	elseif g_TeamCtrl:IsLeader() then
		g_TeamCtrl:C2GSSetTeamTarget(teamTargetId, defalutMin, defalutMax)
	else
		g_NotifyCtrl:FloatMsg("请先退出队伍")
		return
	end

	CTeamMainView:ShowView(function (oView )
		oView:ShowTeamPage(CTeamMainView.Tab.TeamMain)
	end)
end

function CEndlessPVEView.ShowGuideBox(self)
	self.m_GuideMaskGrid:SetActive(true)
	self.m_TeamBtn:SetActive(false)
	self.m_TipsLabel:SetActive(false)
end

function CEndlessPVEView.ClickGuideMask(self )
	g_GuideCtrl:ShowWrongTips()
end

return CEndlessPVEView