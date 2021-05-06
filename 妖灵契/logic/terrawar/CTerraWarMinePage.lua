local CTerraWarMinePage = class("CTerraWarMinePage", CPageBase)

function CTerraWarMinePage.ctor(self, cb)
	CPageBase.ctor(self, cb)

	self.m_TerraWarBoxDic = {}
end

function CTerraWarMinePage.OnInitPage(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_ContentWidget = self:NewUI(2, CWidget)
	self.m_TerraWarGrid = self:NewUI(4, CGrid)
	self.m_TerraWarBox = self:NewUI(5, CBox)
	self.m_TipsTexture = self:NewUI(6, CTexture)
	self:InitContent()
end

function CTerraWarMinePage.InitContent(self)
	self.m_TipsTexture:SetActive(false)
	self.m_TerraWarBox:SetActive(false)
	--UITools.ResizeToRootSize(self.m_Container)
	g_TerrawarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnTerrawarCtrl"))
end

function CTerraWarMinePage.OnTerrawarCtrl(self, oCtrl)
	if oCtrl.m_EventID == define.Terrawar.Event.RefreshMine then
		self:Refresh()
	end
end

function CTerraWarMinePage.Refresh(self)
	local terrawarMineInfo = g_TerrawarCtrl:GetTerrawarMineInfo()
	local lMineInfo = {}
	for i,d in ipairs(terrawarMineInfo) do
		--战斗中>占领中>保护中
		local info = table.copy(d)
		if info.status == define.Terrawar.status.Not then
			info.sort = 1
		elseif info.status == define.Terrawar.status.Attack then
			info.sort = 3
		elseif info.status == define.Terrawar.status.Occupy then
			info.sort = 2
		elseif info.status == define.Terrawar.status.Protect then
			info.sort = 1
		end
		if info.playername == g_AttrCtrl.name then 
			info.sort = info.sort + 10
		else
			info.sort = info.sort
		end
		table.insert(lMineInfo, info)
	end
	local function sortfunc(a, b)
		if a.sort == b.sort then
			return data.terrawardata.TERRACONFIG[a.id].size > data.terrawardata.TERRACONFIG[b.id].size
		else
			return a.sort > b.sort
		end
	end
	table.sort(lMineInfo, sortfunc)
	self.m_TerraWarGrid:Clear()
	for i,info in ipairs(lMineInfo) do
		local oBox = self:CreateTerraWarBox(info)
		self:RefreshTerraWarBox(oBox.m_ID, info)
		self.m_TerraWarGrid:AddChild(oBox)
	end
	self.m_TerraWarGrid:Reposition()
	self.m_TipsTexture:SetActive(self.m_TerraWarGrid:GetCount() == 0)
end

function CTerraWarMinePage.CreateTerraWarBox(self, info)
	local oBox = self.m_TerraWarBox:Clone()
	oBox:SetActive(true)

	oBox.m_PosLabel = oBox:NewUI(1, CLabel)
	oBox.m_StateLabel = oBox:NewUI(2, CLabel)
	oBox.m_ScoreLabel = oBox:NewUI(3, CLabel)
	oBox.m_BtnTable = oBox:NewUI(5, CTable)
	oBox.m_RecallBtn = oBox:NewUI(6, CButton)
	oBox.m_HelpBtn = oBox:NewUI(7, CButton)
	oBox.m_PartnerGrid = oBox:NewUI(8, CGrid)
	oBox.m_PartnerBox = oBox:NewUI(9, CBox)
	oBox.m_PartnerBox:SetActive(false)
	
	oBox.m_ID = info.id
	oBox.m_Info = info
	if info.playername == g_AttrCtrl.name then
		local orgscore = info.orgscore or 0
		local personal_score = info.personal_score or 0
		local personal_contribution = info.personal_contribution or 0

		oBox.m_ScoreLabel:SetText(string.format("公会积分:%d  个人积分:%d  贡献度:%d", orgscore, personal_score, personal_contribution))
		oBox.m_RecallBtn:SetActive(info.status ~= define.Terrawar.status.Protect)
	else
		local orgscore = info.orgscore or 0
		oBox.m_ScoreLabel:SetText(string.format("公会积分:%d", orgscore))
		oBox.m_RecallBtn:SetActive(false)
	end
	oBox.m_RecallBtn:AddUIEvent("click", callback(self, "OnRecallBtn", oBox.m_ID))
	oBox.m_HelpBtn:AddUIEvent("click", callback(self, "OnHelpBtn", oBox.m_ID))
	oBox.m_BtnTable:Reposition()
	self.m_TerraWarBoxDic[oBox.m_ID] = oBox
	return oBox
end

function CTerraWarMinePage.RefreshTerraWarBox(self, id, info)
	local oBox = self.m_TerraWarBoxDic[id]
	if oBox then
		oBox.m_Info = info
		if oBox.m_Timer then
			Utils.DelTimer(oBox.m_Timer)
			oBox.m_Timer = nil
		end
		local terraconfig = data.terrawardata.TERRACONFIG[id]
		if info.playername == g_AttrCtrl.name then
			oBox.m_PosLabel:SetText(string.format("我的据点 %s",terraconfig.name))
		else
			oBox.m_PosLabel:SetText(string.format("公会据点 %s",terraconfig.name))
		end
		local status = info.status
		if status == define.Terrawar.status.Not then
			oBox.m_StateLabel:SetText("[674622]和平中") 
		elseif status == define.Terrawar.status.Attack then
			oBox.m_StateLabel:SetText("[FF5B5B]战斗中")
		elseif status == define.Terrawar.status.Occupy then
			oBox.m_StateLabel:SetText("[FF5B5B]占领中")
		elseif status == define.Terrawar.status.Protect then
			local time = info.times - g_TimeCtrl:GetTimeS()
			local function countdown()
				if Utils.IsNil(oBox) then
					return
				end
				if time >= 0 then
					oBox.m_StateLabel:SetText(string.format("[1B7E5A]保护中 %s", g_TimeCtrl:GetLeftTime(time)))
					time = time - 1
					return true
				else
					oBox.m_StateLabel:SetText("[674622]和平中")
				end
			end
			oBox.m_Timer = Utils.AddTimer(countdown, 1, 0)
		end
		for i,v in ipairs(info.partner_info) do
			local oPartnerBox = self:CreatePartnerBox(oBox.m_PartnerBox)
			self:SetPartnerBoxData(oPartnerBox, v)
			oBox.m_PartnerGrid:AddChild(oPartnerBox)
		end
		oBox.m_PartnerGrid:Reposition()
	end
end

function CTerraWarMinePage.CreatePartnerBox(self, oBox)
	local oPartnerBox = oBox:Clone()
	oPartnerBox:SetActive(true)
	oPartnerBox.m_BoderSpr = oPartnerBox:NewUI(1, CSprite)
	oPartnerBox.m_Icon = oPartnerBox:NewUI(2, CSprite)
	oPartnerBox.m_StarGrid = oPartnerBox:NewUI(3, CGrid)
	oPartnerBox.m_StarSpr = oPartnerBox:NewUI(4, CSprite)
	oPartnerBox.m_AwakeSpr = oPartnerBox:NewUI(5, CSprite)
	oPartnerBox.m_GradeLabel = oPartnerBox:NewUI(6, CLabel)
	oPartnerBox.m_NameLabel = oPartnerBox:NewUI(7, CLabel)
	oPartnerBox.m_HPSlider = oPartnerBox:NewUI(8, CSlider)

	oPartnerBox.m_StarSpr:SetActive(false)
	oPartnerBox.m_StarGrid:Clear()
	for i = 1, 5 do
		local oSpr = oPartnerBox.m_StarSpr:Clone()
		oSpr:SetActive(true)
		oPartnerBox.m_StarGrid:AddChild(oSpr)
	end
	oPartnerBox.m_StarGrid:Reposition()

	return oPartnerBox
end

function CTerraWarMinePage.SetPartnerBoxData(self, oPartnerBox, dData)
	local icon = dData.model_info.shape
	oPartnerBox.m_Icon:SpriteAvatar(icon)

	local star = dData.star
	for i, oSpr in ipairs(oPartnerBox.m_StarGrid:GetChildList()) do
		if star >= i then
			oSpr:SetSpriteName("pic_chouka_dianliang")
		else
			oSpr:SetSpriteName("pic_chouka_weidianliang")
		end
	end

	local rare = dData.rare
	local sSprite = oPartnerBox.m_BoderSpr:GetSpriteName()
	if string.startswith(sSprite, "bg_haoyoukuang_") then
		local filename = define.Partner.CardColor[rare] or "hui"
		oPartnerBox.m_BoderSpr:SetSpriteName("bg_haoyoukuang_"..filename.."se")
	elseif string.startswith(sSprite, "bg_huobankuang_") then
		oPartnerBox.m_BoderSpr:SetSpriteName(string.format("bg_huobankuang_da%d", rare))
	end

	local awake = dData.awake
	oPartnerBox.m_AwakeSpr:SetActive(awake == 1)

	local grade = dData.grade
	oPartnerBox.m_GradeLabel:SetText(string.format("%d", grade))

	local name = dData.name
	oPartnerBox.m_NameLabel:SetText(name)

	local hp = dData.hp or 0
	local max_hp = dData.max_hp or 0
	oPartnerBox.m_HPSlider:SetValue(hp/max_hp)
	oPartnerBox.m_HPSlider:SetSliderText(string.format("%d/%d", hp, max_hp))
end

function CTerraWarMinePage.OnRecallBtn(self, id, oBtn)
	--printc("CTerraWarMinePage.OnRecallBtn")
	nethuodong.C2GSTerrawarOperate(id, define.Terrawar.Operate.Recall)
end

function CTerraWarMinePage.OnHelpBtn(self, id, oBtn)
	--printc("CTerraWarMinePage.OnHelpBtn")
	g_TerrawarCtrl:ClientTerraWarHelp(id)
	CTerraWarMainView:CloseView()
	COrgActivityCenterView:CloseView()
	COrgMainView:CloseView()
end

return CTerraWarMinePage