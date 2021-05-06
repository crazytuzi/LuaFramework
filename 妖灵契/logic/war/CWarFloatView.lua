local CWarFloatView = class("CWarFloatView", CViewBase)

function CWarFloatView.ctor(self)
	CViewBase.ctor(self, "UI/War/WarFloatView.prefab")
end

function CWarFloatView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_AllySelSpr = self:NewUI(2, CSprite)
	self.m_EnemySelSpr = self:NewUI(3, CSprite)
	self.m_BoutTimeBox = self:NewUI(4, CWarBoutTimeBox)
	self.m_OrderTipBox = self:NewUI(5, CWarOrderTipBox)
	self.m_MagicNameBox = self:NewUI(6, CWarMagicNameBox)
	self.m_MagicDescBox = self:NewUI(7, CBox)
	self.m_FliterBtn = self:NewUI(8, CButton)
	self.m_FliterWidget = self:NewUI(9, CWidget)

	self.m_AlphaAction = nil
	self.m_NumberPos = {}
	self.m_Cached = {}
	self:InitContent()
end

function CWarFloatView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_MagicDescBox.m_NameLabel = self.m_MagicDescBox:NewUI(1, CLabel)
	self.m_MagicDescBox.m_DescLabel = self.m_MagicDescBox:NewUI(2, CLabel)
	self.m_FliterWidget:SetActive(false)
	self.m_OrderTipBox:SetActive(false)
	self.m_MagicNameBox:SetActive(false)
	self.m_MagicDescBox:SetAlpha(0)
	self.m_BoutTimeBox:StartCountDown()
end

function CWarFloatView.ShowOrderTip(self)
	self.m_OrderTipBox:SetActive(true)
	self.m_OrderTipBox:RefreshTip()
end

function CWarFloatView.HideOrderTip(self)
	self.m_OrderTipBox:SetActive(false)
end

function CWarFloatView.MagicName(self, name, duration, warrior)
	self.m_MagicNameBox:Display(name, duration, warrior)
end

function CWarFloatView.ShowMagicDesc(self, magic, level)
	if self.m_AlphaAction then
		g_ActionCtrl:DelAction(self.m_AlphaAction)
	end
	local dData = DataTools.GetMagicData(magic)
	local desc = self:GetMagicDesc(magic, level) or dData.desc
	self.m_MagicDescBox.m_NameLabel:SetText(dData.name)
	self.m_MagicDescBox.m_DescLabel:SetText(desc)
	self.m_MagicDescBox:SimulateOnEnable()
	self.m_MagicDescBox:SetAlpha(1)
	self.m_MagicDescBox:SetActive(true)
	self.m_AlphaAction = CActionFloat.New(self.m_MagicDescBox, 2.5, "SetAlpha", 1, 0)
	self.m_AlphaAction:SetEndCallback(callback(self.m_MagicDescBox, "SetActive", false))
	g_ActionCtrl:AddAction(self.m_AlphaAction, 2.5)
	return self.m_MagicDescBox
end

function CWarFloatView.GetMagicDesc(self, magic, level)
	level = level or 0
	local awake, level = math.floor(level/100), level%100
	if level > 0 then
		local d = data.skilldata.PARTNER
		local d2 = data.skilldata.PARTNERSKILL
		local awakedesc = ""
		if d[magic] and d[magic][level] then
			if awake == 1 and d2[magic] then
				local parid = d2[magic]["partner"]
				local d3 = data.partnerdata.DATA[parid]
				if d3 and (d3["awake_type"] == 3 or d3["awake_type"] == 1) and tonumber(d3["awake_effect_skill"]) == magic then
					return d3["awake_desc"]
				end
			end
			return d[magic][level]["war_desc"]..awakedesc
		end
		--走到这里，判断是否是人物技能
		local d3 = data.skilldata.SCHOOL
		if d3[magic] and d3[magic][level+1] then
			return d3[magic][level+1].desc
		end
	end
end

function CWarFloatView.HideMagicDesc(self)
	if self.m_AlphaAction then
		g_ActionCtrl:DelAction(self.m_AlphaAction)
	end
	self.m_MagicDescBox:SetAlpha(0)
	self.m_MagicDescBox:SetActive(false)
end

function CWarFloatView.FinishOrder(self)
	if not Utils.IsInEditorMode() then
		self.m_BoutTimeBox:CheckShowWait()
	end
	self:HideOrderTip()
	self:HideMagicDesc()
end

function CWarFloatView.ShowFliter(self, sText, func)
	self.m_FliterWidget:SetActive(true)
	self.m_FliterBtn:SetText(sText)
	local function wrap()
		self.m_FliterWidget:SetActive(false)
		func()
	end
	self.m_FliterBtn:AddUIEvent("click", wrap) 
end

function CWarFloatView.CloseFliterWidget(self)
	self.m_FliterWidget:SetActive(false)
end

return CWarFloatView