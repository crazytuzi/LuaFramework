local CTerraWarQueueView = class("CTerraWarQueueView", CViewBase)

function CTerraWarQueueView.ctor(self, cb)
	CViewBase.ctor(self, "UI/TerraWar/TerraWarQueueView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_BehindStrike = true
	self.m_ExtendClose = "Shelter"
end

function CTerraWarQueueView.OnCreateView(self)
	self.m_AttackPidList = {}
	self.m_HelpPidList = {}
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_HelpLabel = self:NewUI(2, CLabel)
	self.m_AttackLabel = self:NewUI(3, CLabel)
	self.m_NameLabel = self:NewUI(4, CLabel)
	self.m_BoxClone = self:NewUI(5, CBox)
	self.m_HelpGrid = self:NewUI(6, CGrid)
	self.m_AttackGrid = self:NewUI(7, CGrid)
	self.m_OperateBtn = self:NewUI(8, CButton)
	self.m_TitleLabel = self:NewUI(9, CLabel)
	self:InitContent()
end

function CTerraWarQueueView.InitContent(self)
	self.m_BoxClone:SetActive(false)

	self.m_HelpGrid:InitChild(function (obj, idx)
  		local oBox = CBox.New(obj)
  		oBox.m_RankLabel = oBox:NewUI(1, CLabel)
		oBox.m_NameLabel = oBox:NewUI(2, CLabel)
		oBox.m_ResultSprite = oBox:NewUI(3, CSprite)
		return oBox
  	end)

  	self.m_AttackGrid:InitChild(function (obj, idx)
  		local oBox = CBox.New(obj)
  		oBox.m_RankLabel = oBox:NewUI(1, CLabel)
		oBox.m_NameLabel = oBox:NewUI(2, CLabel)
		oBox.m_ResultSprite = oBox:NewUI(3, CSprite)
		return oBox
  	end)

	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_OperateBtn:AddUIEvent("click", callback(self, "OnOperateBtn"))
end

function CTerraWarQueueView.OnOperateBtn(self, oBtn)
	local txt = self.m_OperateBtn:GetText()
	if txt == "优先支援" then
		nethuodong.C2GSHelpFirst(self.m_Terraid)
	elseif txt == "取消排队" then
		nethuodong.C2GSLeaveQueue(self.m_Terraid)
	elseif txt == "支援" then
		nethuodong.C2GSTerrawarOperate(self.m_Terraid, define.Terrawar.Operate.Help, define.Terrawar.Next.GetListInfo)
	elseif txt == "攻击" then
		nethuodong.C2GSTerrawarOperate(self.m_Terraid, define.Terrawar.Operate.Attack, define.Terrawar.Next.GetListInfo)
	end
end

function CTerraWarQueueView.InitView(self, terraid, helplist, attacklist, name, orgid)
	self.m_Terraid = terraid
	self.m_TerraName = name
	self.m_Orgid = orgid
	if name and name ~= "" then
		self.m_NameLabel:SetText("领主优先：无")
	end
	self.m_TitleLabel:SetText("排队状况"..data.terrawardata.TERRACONFIG[terraid].name)
	self:InitHelpGrid(helplist)
	self:InitAttackGrid(attacklist)
	self:RefreshBtn()
end

function CTerraWarQueueView.InitHelpGrid(self, helplist)
	self.m_HelpPidList = {}
	for i,oBox in ipairs(self.m_HelpGrid:GetChildList()) do
		oBox.m_RankLabel:SetText(i)
		oBox.m_NameLabel:SetText("")
		oBox.m_ResultSprite:SetActive(false)
	end
	for i,dData in ipairs(helplist) do
		local oBox = self.m_HelpGrid:GetChild(#self.m_HelpPidList + 1)
		if oBox then
			if dData.name == g_AttrCtrl.name then
				--特殊处理，领主优先
				self.m_NameLabel:SetText(string.format("领主优先：%s（下轮）", dData.name))
			else
				oBox.m_RankLabel:SetText(i)
				oBox.m_NameLabel:SetText(dData.name)
				oBox.m_ResultSprite:SetActive(dData.status == 1)
				table.insert(self.m_HelpPidList, dData.pid)
			end
		end
	end
	self.m_HelpLabel:SetText(string.format("支援方(%d/5)", math.min(#helplist, 5)))
end

function CTerraWarQueueView.InitAttackGrid(self, attacklist)
	self.m_AttackPidList = {}
	for i,oBox in ipairs(self.m_AttackGrid:GetChildList()) do
		local dData = attacklist[i]
		if dData then
			oBox.m_RankLabel:SetText(i)
			oBox.m_NameLabel:SetText(dData.name)
			oBox.m_ResultSprite:SetActive(dData.status == 1)
			table.insert(self.m_AttackPidList, dData.pid)
		else
			oBox.m_RankLabel:SetText(i)
			oBox.m_NameLabel:SetText("")
			oBox.m_ResultSprite:SetActive(false)
		end
	end
	self.m_AttackLabel:SetText(string.format("攻击方(%d/5)", #attacklist))
end

function CTerraWarQueueView.RefreshBtn(self)
	if g_AttrCtrl.name == self.m_TerraName then
		self.m_OperateBtn:SetText("优先支援")
	elseif table.index(self.m_AttackPidList, g_AttrCtrl.pid) or 
	 	table.index(self.m_HelpPidList, g_AttrCtrl.pid) then
		self.m_OperateBtn:SetText("取消排队")
	elseif self.m_Orgid == g_AttrCtrl.org_id and g_AttrCtrl.org_id ~= 0 then
		self.m_OperateBtn:SetText("支援")
	else
		self.m_OperateBtn:SetText("攻击")
	end
end

return CTerraWarQueueView