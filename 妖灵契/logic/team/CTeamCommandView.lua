local CTeamCommandView = class("CTeamCommandView", CViewBase)

function CTeamCommandView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Team/TeamCommandView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CTeamCommandView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_AllyBox = self:NewUI(3, CBox)
	self.m_EnemyBox = self:NewUI(4, CBox)
	self.m_CommandGrid = self:NewUI(5, CGrid)
	self.m_CommandBox = self:NewUI(6, CBox)
	self:InitContent()
end

function CTeamCommandView.InitContent(self)
	self.m_Ally = nil
	self.m_CommandBox:SetActive(false)

	self.m_AllyBox:SetGroup(self:GetInstanceID())
	self.m_EnemyBox:SetGroup(self:GetInstanceID())

	self.m_AllyBox:AddUIEvent("click", callback(self, "OnAllyBox"))
	self.m_EnemyBox:AddUIEvent("click", callback(self, "OnEnemyBox"))

	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlAttrEvent"))
	self:DefaultSelect()
end

function CTeamCommandView.OnCtrlAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		if oCtrl.m_EventData["dAttr"] and oCtrl.m_EventData["dAttr"]["bcmd"] then
			self:RefreshCommandGrid()
		end
	end
end

function CTeamCommandView.DefaultSelect(self)
	self:OnEnemyBox()
end

function CTeamCommandView.OnAllyBox(self, oBox)
	self.m_Ally = true
	self.m_AllyBox:SetSelected(true)
	self:RefreshCommandGrid()
end

function CTeamCommandView.OnEnemyBox(self, oBox)
	self.m_Ally = false
	self.m_EnemyBox:SetSelected(true)
	self:RefreshCommandGrid()
end

function CTeamCommandView.RefreshCommandGrid(self)
	local lCommand = g_AttrCtrl:GetBattleCmd(self.m_Ally)
	self.m_CommandGrid:Clear()
	for i,v in ipairs(lCommand) do
		local oBox = self.m_CommandBox:Clone()
		oBox.m_Idx = v.idx
		oBox.m_Cmd = v.cmd
		oBox.m_CommandLabel = oBox:NewUI(1, CLabel)
		local txt = "+"
		if oBox.m_Cmd and oBox.m_Cmd ~= "" then
			txt = oBox.m_Cmd
		end
		oBox.m_CommandLabel:SetText(txt)
		oBox:SetActive(true)
		oBox:AddUIEvent("click", callback(self, "OnCommandBox"))
		self.m_CommandGrid:AddChild(oBox)
	end
	self.m_CommandGrid:Reposition()
end

function CTeamCommandView.OnCommandBox(self, oBox)
	CTeamCommandChangeView:ShowView(function (oView)
		oView:SetData(self.m_Ally, oBox.m_Idx)
	end)
end

return CTeamCommandView