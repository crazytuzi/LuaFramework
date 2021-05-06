local CTerraWarLogPage = class("CTerraWarLogPage", CPageBase)

function CTerraWarLogPage.ctor(self, cb)
	CPageBase.ctor(self, cb)
end

function CTerraWarLogPage.OnInitPage(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_Content = self:NewUI(2, CWidget)
	self.m_ScrollView = self:NewUI(3, CScrollView)
	self.m_Grid = self:NewUI(4, CGrid)
	self.m_Box = self:NewUI(5, CBox)
	self.m_Texture = self:NewUI(6, CTexture, false)
	self:InitContent()
end

function CTerraWarLogPage.InitContent(self)
	self.m_Box:SetActive(false)
	g_TerrawarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTerrawarCtrl"))
end

function CTerraWarLogPage.OnTerrawarCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Terrawar.Event.TerraWarLog then
		self:Refresh()
	end
end

function CTerraWarLogPage.Refresh(self)
	local terrawarlog = g_TerrawarCtrl:GetTerraWarLog()
	self.m_Grid:Clear()
	for i,v in ipairs(terrawarlog) do
		local oBox = self:CreateBox()
		self:UpdateBox(oBox, v)
		self.m_Grid:AddChild(oBox)
		oBox:SetAsFirstSibling()
	end
	self.m_Grid:Reposition()
	self.m_Texture:SetActive(not next(terrawarlog))
end

function CTerraWarLogPage.CreateBox(self)
	local oBox = self.m_Box:Clone()
	oBox.m_DescLabel = oBox:NewUI(1, CLabel)
	oBox.m_OperateBtn = oBox:NewUI(2, CButton)
	oBox.m_TimeLabel = oBox:NewUI(3, CLabel)
	oBox.m_BgSpr = oBox:NewUI(4, CSprite)
	oBox:SetActive(true)
	return oBox
end

function CTerraWarLogPage.UpdateBox(self, oBox, info)
	if not info or not info.terraid then
		return
	end
	oBox.m_CreateTime = info.createtime
	oBox.m_Option = info.option
	oBox.m_DefenderID = info.defender_id
	oBox.m_DefenderName = info.defender_name
	oBox.m_AttackerID = info.attacker_id
	oBox.m_AttackerName = info.attacker_name
	oBox.m_Terraid = info.terraid
	oBox.m_Status = info.status
	local terrawarName = data.terrawardata.TERRACONFIG[info.terraid].name
	
	local terrawarname = string.format("[FF0000]【%s】[-]", terrawarName)
	local atkname = string.format("[2B926B]【%s】[-]", oBox.m_AttackerName)
	local defname = string.format("[A8811A]【%s】[-]", oBox.m_DefenderName)
	local txt = ""
	if oBox.m_Option == 1 then
		if oBox.m_DefenderID == g_AttrCtrl.pid then
			txt = string.format("[7E4800FF]你的%s正被%s攻击，请快去支援！[-]", terrawarname, atkname)
		else
			txt = string.format("[7E4800FF]公会成员%s的%s正被%s攻击，请快去支援！[-]", defname, terrawarname, atkname)
		end
	elseif oBox.m_Option == 2 then
		if oBox.m_DefenderID == g_AttrCtrl.pid then
			txt = string.format("[7E4800FF]你的%s已经被%s攻击占据！[-]", terrawarname, atkname)
		else
			txt = string.format("[7E4800FF]公会成员%s的%s已经被%s占据！[-]", defname, terrawarname, atkname)
		end
	elseif oBox.m_Option == 3 then
		if oBox.m_DefenderID == g_AttrCtrl.pid then
			txt = string.format("[7E4800FF]你成功支援了%s[-]", terrawarname)
		else
			txt = string.format("[7E4800FF]%s成功支援了%s[-]", defname, terrawarname)
		end	
	elseif oBox.m_Option == 4 then
		if oBox.m_DefenderID == g_AttrCtrl.pid then
			txt = string.format("[7E4800FF]你成功抵挡了敌人的攻击,%s领主保持不变[-]", terrawarname)
		else
			txt = string.format("[7E4800FF]%s成功抵挡了敌人的攻击,%s领主保持不变[-]", defname, terrawarname)
		end		
	end
	oBox.m_DescLabel:SetText(txt)
	if oBox.m_Status == 1 then
		oBox.m_TimeLabel:SetActive(true)
		oBox.m_OperateBtn:SetActive(false)
	else
		local iEvent
		oBox.m_TimeLabel:SetActive(false)
		oBox.m_OperateBtn:SetActive(true)
		if oBox.m_Option  == 1 then
			if oBox.m_DefenderID == g_AttrCtrl.pid then
				oBox.m_OperateBtn:SetText("求救")
				iEvent = 1
			else
				oBox.m_OperateBtn:SetText("支援")
				iEvent = 2
			end
		elseif oBox.m_Option == 2 then
			oBox.m_OperateBtn:SetText("前往")
			iEvent = 3
		elseif oBox.m_Option == 3 or oBox.m_Option == 4 then
			oBox.m_TimeLabel:SetActive(false)
			oBox.m_OperateBtn:SetActive(false)
		end
		oBox.m_OperateBtn:AddUIEvent("click", callback(self, "OnOperate", oBox, iEvent))
	end
end

function CTerraWarLogPage.OnOperate(self, oBox, iEvent)
	if iEvent == 1 then
		nethuodong.C2GSTerraAskForHelp(oBox.m_Terraid)
	elseif iEvent == 2 then
		g_TerrawarCtrl:ClientTerraWarHelp(oBox.m_Terraid)
		CTerraWarMainView:CloseView()
	elseif iEvent == 3 then
		g_TerrawarCtrl:ClientTerraWarHelp(oBox.m_Terraid)
		CTerraWarMainView:CloseView()
	end
	--g_ChatCtrl:SendMsg(string.format("%s", LinkTools.GenerateHelpTerraWarLink(oBox.m_Terraid, "123", g_TimeCtrl:GetTimeS() + 30)), define.Channel.Org)
end

return CTerraWarLogPage