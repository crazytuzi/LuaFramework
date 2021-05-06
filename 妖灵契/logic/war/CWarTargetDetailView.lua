local CWarTargetDetailView = class("CWarTargetDetailView", CViewBase)

function CWarTargetDetailView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarTargetDetailView.prefab", cb)

	self.m_ExtendClose = "ClickOut"
end

function CWarTargetDetailView.OnCreateView(self)
	self.m_BuffTable = self:NewUI(1, CTable)
	self.m_BuffBox = self:NewUI(2, CBox)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_StateLabel = self:NewUI(4, CLabel)
	self.m_CommandBtn = self:NewUI(5, CButton)
	self.m_CommandWidget = self:NewUI(6, CWidget)
	self.m_CommandGrid = self:NewUI(7, CGrid)
	self.m_CommandBox = self:NewUI(8, CBox)
	self.m_EditorBtn = self:NewUI(9, CButton)
	self.m_ClearBox = self:NewUI(10, CBox)
	self.m_BG = self:NewUI(11, CSprite)
	self.m_BuffBG = self:NewUI(12, CSprite)
	self.m_BuffBox:SetActive(false)

	self:InitContent()
end

function CWarTargetDetailView.InitContent(self)
	self.m_CommandBtn:SetActive(g_TeamCtrl:IsCommander(g_AttrCtrl.pid) and not g_WarCtrl:IsObserverView())
	self.m_CommandWidget:SetActive(false)
	self.m_CommandBox:SetActive(false)
	self.m_ClearBox:SetActive(false)

	self.m_CommandBtn:AddUIEvent("click", callback(self, "OnCommandBtn"))
	self.m_EditorBtn:AddUIEvent("click", callback(self, "OnEditorCommand"))

end

function CWarTargetDetailView.SetWarrior(self, oWarrior)
	self.m_Warrior = oWarrior
	self.m_WarriorRef = weakref(oWarrior)
	local sText = string.format("[6fff00]%s[-]", oWarrior:GetName())
	if oWarrior.m_OwnerWid then
		local oOwner = g_WarCtrl:GetWarrior(oWarrior.m_OwnerWid)
		sText = sText..string.format("[ffe6a3](%s)[-]", oOwner:GetName())
	end
	self.m_NameLabel:SetText(sText)
	local dStatus = oWarrior:GetStatus()
	local sState = ""
	if oWarrior:IsNpcWarriorTypeBoss() then
		sState = ""
	else
		sState = string.format("[ff4242]气血:%d/%d\n", dStatus.hp, dStatus.max_hp)
	end
	if oWarrior:IsAlly() then
		sState = sState..string.format("[ffa820]怒气:%d/5", math.floor(g_WarCtrl:GetSP()/20))
	end
	self.m_StateLabel:SetText(sState)

	self:RefreshBuffTable()
	self:ReSize()
end

function CWarTargetDetailView.ReSize(self)
	local iBuffCount = self.m_BuffTable:GetCount()
	local bCommander = self.m_CommandBtn:GetActive()
	if iBuffCount == 1 then
		self.m_BuffBG:SetSize(300, 100)
		if bCommander then
			self.m_BG:SetSize(306, 265)
		else
			self.m_BG:SetSize(306, 200)
		end
	else
		self.m_BuffBG:SetSize(300, 210)
		if bCommander then
			self.m_BG:SetSize(306, 380)
		else
			self.m_BG:SetSize(306, 306)
		end
	end
end


function CWarTargetDetailView.GetWarrior(self)
	return getrefobj(self.m_WarriorRef)
end

function CWarTargetDetailView.RefreshBuffTable(self)
	self.m_BuffTable:Clear()
	local oWarrior = self:GetWarrior()
	if not oWarrior then
		return
	end
	local lBuffs = oWarrior:GetBuffList()
	for i, dBuffInfo in ipairs(lBuffs) do
		local oBox = self:GetWarBuffBox(dBuffInfo.buff_id, dBuffInfo.bout, dBuffInfo.level)
		self.m_BuffTable:AddChild(oBox)
	end
end

function CWarTargetDetailView.GetWarBuffBox(self, buffid, bout, level)
	local oBox = self.m_BuffBox:Clone()
	oBox:SetActive(true)
	oBox.m_Icon = oBox:NewUI(1, CSprite)
	oBox.m_NameLabel = oBox:NewUI(2, CLabel)
	oBox.m_BoutLabel = oBox:NewUI(3, CLabel)
	oBox.m_DescLabel = oBox:NewUI(4, CLabel)
	local dBuff = data.buffdata.DATA[buffid]
	oBox.m_Icon:SpriteBuff(buffid)
	if bout == define.War.Infinite_Buff_Bout then
		oBox.m_BoutLabel:SetText(string.format("层数:%d 回合数:无限制", level))
	else
		oBox.m_BoutLabel:SetText(string.format("层数:%d 回合数:%d", level, bout))
	end
	if dBuff then
		oBox.m_NameLabel:SetText(dBuff.name)
		oBox.m_DescLabel:SetText(dBuff.desc)
	end
	return oBox
end

function CWarTargetDetailView.OnCommandBtn(self, btn)
	local bAct = not self.m_CommandWidget:GetActive()
	self.m_CommandWidget:SetActive(bAct)
	if bAct then
		self:RefreshCommandGrid()
	end 
end

function CWarTargetDetailView.RefreshCommandGrid(self)
	self.m_CommandGrid:Clear()
	local lCommand = g_AttrCtrl:GetBattleCmd(self.m_Warrior:IsAlly())
	for i,v in ipairs(lCommand) do
		if v.cmd and v.cmd ~= "" then
			local oBox = self.m_CommandBox:Clone()
			oBox.m_Idx = v.idx
			oBox.m_Cmd = v.cmd
			oBox.m_CommandBtn = oBox:NewUI(1, CButton)
			oBox.m_CommandBtn:SetText(oBox.m_Cmd)
			oBox:SetActive(true)
			oBox:AddUIEvent("click", callback(self, "OnCommandBox"))
			self.m_CommandGrid:AddChild(oBox)
		end
	end
	--清除指令
	local oBox = self.m_ClearBox:Clone()
	oBox.m_CommandBtn = oBox:NewUI(1, CButton)
	oBox.m_CommandBtn:SetText("清除指令")
	oBox:SetActive(true)
	oBox:AddUIEvent("click", callback(self, "OnClearCommand"))
	self.m_CommandGrid:AddChild(oBox)

	self.m_CommandGrid:Reposition()
end

function CWarTargetDetailView.OnCommandBox(self, oBox)
	local war_id = g_WarCtrl:GetWarID()
	local wid = self.m_Warrior.m_ID
	local cmd = oBox.m_Cmd
	netwar.C2GSWarBattleCommand(war_id, wid, cmd)
	self:CloseView()
end

function CWarTargetDetailView.OnEditorCommand(self, oBox)
	CTeamCommandChangeView:ShowView(function (oView)
		oView:SetData(self.m_Warrior:IsAlly(), oBox.m_Idx, self.m_Warrior.m_ID)
	end)
end

function CWarTargetDetailView.OnClearCommand(self, oBox)
	local war_id = g_WarCtrl:GetWarID()
	local wid = self.m_Warrior.m_ID
	netwar.C2GSCleanWarBattleCommand(war_id, wid)
	self:CloseView()
end

return CWarTargetDetailView