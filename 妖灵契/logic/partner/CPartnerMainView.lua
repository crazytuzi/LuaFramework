local CPartnerMainView = class("CPartnerMainView", CViewBase)

function CPartnerMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/PartnerMainView2.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_GroupName = "main"
	self.m_IsAlwaysShow = true
end

function CPartnerMainView.ShowView(cls, cb)
	if #g_PartnerCtrl:GetPartnerList() <= 0 then
		g_NotifyCtrl:FloatMsg("你还没有拥有伙伴")
		return
	end
	return g_ViewCtrl:ShowView(cls, cb)
end

function CPartnerMainView.OnShowView(self)
	self.m_SkinPage:UpdateView()
	self.m_PartnerEquipPage:UpdateView()
	self.m_PartnerList:UpdateView()
	local oView = CPartnerEquipImproveView:GetView()
	if oView and oView:GetActive() then
		g_ViewCtrl:TopView(oView)
	end
	local oView = CPartnerImproveView:GetView()
	if oView and oView:GetActive() then
		g_ViewCtrl:TopView(oView)
	end

end

function CPartnerMainView.OnHideView(self)
	--self.m_PartnerScroll:CloseGrid()
end

function CPartnerMainView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_TabGrid = self:NewUI(2, CGrid)
	self.m_CloseBtn = self:NewUI(3, CButton)
	self.m_MainPage = self:NewPage(4, CPartnerMainPage)
	self.m_LineupPage = self:NewPage(5, CPartnerLineupPage)
	self.m_SkinPage = self:NewPage(6, CPartnerChangeSkinPage)
	self.m_PartnerComposePage = self:NewPage(9, CPartnerComposePage)
	self.m_PartnerEquipPage = self:NewPage(10, CPartnerEquipPage)
	self.m_SoulPage = self:NewPage(12, CPartnerEquipSoulPage)
	self.m_PartnerList = self:NewUI(11, CPartnerLeftList)
	self.m_TouchBox = self:NewUI(13, CWidget)
	self.m_SoulLock = self:NewUI(14, CBox)
	self.m_PartnerList:SetParentView(self)
	
	self.m_CurParID = nil
	self:InitContent()
end

function CPartnerMainView.InitContent(self)
	local rootw, rooth = UITools.GetRootSize()
	-- self.m_Container:SetSize(rootw, rooth)
	-- self.m_Container:SetLocalPos(Vector3.New(-rootw/2, 0, 0))
	self.m_TabGrid:InitChild(function(obj, idx)
		local oBtn = CBox.New(obj, false)
		oBtn:SetGroup(self.m_TabGrid:GetInstanceID())
		return oBtn
	end)
	self.m_MainBtn = self.m_TabGrid:GetChild(1)
	self.m_LineupBtn = self.m_TabGrid:GetChild(2)
	self.m_EquipmentBtn = self.m_TabGrid:GetChild(3)
	self.m_SoulBtn = self.m_TabGrid:GetChild(4)
	self.m_SkinBtn = self.m_TabGrid:GetChild(5)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_MainBtn:AddUIEvent("click", callback(self, "ShowMainPage", true))
	self.m_LineupBtn:AddUIEvent("click", callback(self, "ShowLineupPage", true))
	self.m_SkinBtn:AddUIEvent("click", callback(self, "ShowSkinPage", true))
	self.m_EquipmentBtn:AddUIEvent("click", callback(self, "ShowEquipPage", true))
	self.m_SoulBtn:AddUIEvent("click", callback(self, "ShowSoulPage", true))
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerCtrlEvent"))
	self:UpdateTabBtn()
	self.m_MainBtn:SetSelected(true)
	if g_PartnerCtrl:GetMainFightPartner() then
		self.m_CurParID = g_PartnerCtrl:GetMainFightPartner().m_ID
	end
	self.m_EquipmentBtn.m_IgnoreCheckEffect = true
	self:ShowMainPage()
	g_GuideCtrl:AddGuideUI("partner_equip_tab_btn", self.m_EquipmentBtn)
	g_GuideCtrl:AddGuideUI("partner_lineup_tab_btn", self.m_LineupBtn)
	g_GuideCtrl:AddGuideUI("partner_yuling_tab_btn", self.m_SoulBtn)

end

function CPartnerMainView.OnPartnerCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Partner.Event.UpdateRedPoint then
		local d = oCtrl.m_EventData
		if type(d) == "table" and table.index(d, self.m_CurParID) then
			self:UpdateRedSpr()
		elseif d == self.m_CurParID then
			self:UpdateRedSpr()
		end
	end
end

function CPartnerMainView.OnChangePartner(self, parid)
	if self.m_CurPage == self.m_PartnerComposePage then
		self.m_ChipID = parid
		self.m_CurPage:SetChipID(parid)
		self.m_PartnerList:OnSelectChip(parid)
	else
		self.m_CurParID = parid
		self.m_CurPage:SetPartnerID(parid)
		self.m_PartnerList:OnSelectPartner(parid)
		self:UpdateRedSpr()
	end
end

function CPartnerMainView.GetCurPartnerID(self)
	return self.m_CurParID
end

function CPartnerMainView.GetChipID(self)
	if self.m_CurParID then
		local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
		local partner_type = oPartner:GetValue("partner_type")
		for id, dItem in pairs(data.itemdata.PARTNER_CHIP) do
			if dItem.partner_type == partner_type then
				return id
			end
		end
	end
	for id, dItem in pairs(data.itemdata.PARTNER_CHIP) do
		return id
	end
end

function CPartnerMainView.ShowComposeResult(self, iPartnerID)
	self:ShowMainPage()
	self:OnChangePartner(iPartnerID)
end

function CPartnerMainView.ShowFirstPage(self, isClick)
	self:ShowSubPage(self.m_MainPage)
	self.m_MainBtn:SetSelected(true)
	self.m_CurPage = self.m_MainPage
	if g_PartnerCtrl:GetMainFightPartner() then
		self.m_CurParID = g_PartnerCtrl:GetMainFightPartner().m_ID
	end
	self.m_CurPage:SetPartnerID(self.m_CurParID)
	self:UpdateRedSpr()
	self.m_PartnerList:OnSelectPartner(self.m_CurParID)
	self.m_PartnerList:SetType("main")
	self.m_PartnerList:UnRegisterDrag()
end

function CPartnerMainView.ShowMainPage(self, isClick)
	self:ShowSubPage(self.m_MainPage)
	self.m_MainBtn:SetSelected(true)
	self.m_CurPage = self.m_MainPage
	self.m_CurPage:SetPartnerID(self.m_CurParID)
	self.m_PartnerList:OnSelectPartner(self.m_CurParID)
	self.m_PartnerList:SetType("main")
	self.m_PartnerList:UnRegisterDrag()
end

function CPartnerMainView.SwitchMainPage(self, iPartnerID)
	self:ShowSubPage(self.m_MainPage)
	self.m_MainBtn:SetSelected(true)
	self.m_CurPage = self.m_MainPage
	self:OnChangePartner(iPartnerID)
end

function CPartnerMainView.ShowLineupPage(self, isClick)	
	self:ShowSubPage(self.m_LineupPage)
	self.m_LineupBtn:SetSelected(true)
	self.m_CurPage = self.m_LineupPage
	self.m_CurPage:SetPartnerID(self.m_CurParID)
	self.m_PartnerList:SetType("lineup")
	local dArgs = self.m_LineupPage:GetDragArgs()
	self.m_PartnerList:RegisterDrag(dArgs)
end

function CPartnerMainView.ShowSkinPage(self, isClick)
	self.m_SkinBtn:SetSelected(true)
	self:ShowSubPage(self.m_SkinPage)
	self.m_CurPage = self.m_SkinPage
	self.m_CurPage:SetPartnerID(self.m_CurParID)
	self.m_PartnerList:SetType("awake")
	self.m_PartnerList:OnSelectPartner(self.m_CurParID)
	self.m_PartnerList:UnRegisterDrag()
end

function CPartnerMainView.ShowComposePage(self, chipdId)
	chipdId = chipdId or self:GetChipID()
	self:ShowSubPage(self.m_PartnerComposePage)
	self.m_CurPage = self.m_PartnerComposePage
	--self:OnChangePartner(chipdId)
	self.m_PartnerList:SetType("compose")
	self.m_PartnerList:UnRegisterDrag()
end

function CPartnerMainView.ChangeComposePage(self, chipdId)
	chipdId = chipdId or self:GetChipID()
	self:ShowSubPage(self.m_PartnerComposePage)
	self.m_CurPage = self.m_PartnerComposePage
	self:OnChangePartner(chipdId)
end

function CPartnerMainView.ShowEquipPage(self, isClick)
	self:ShowSubPage(self.m_PartnerEquipPage)
	self.m_CurPage = self.m_PartnerEquipPage
	self.m_CurPage:SetPartnerID(self.m_CurParID)
	self.m_EquipmentBtn:SetSelected(true)
	self.m_PartnerList:SetType("equip")
	self.m_PartnerList:OnSelectPartner(self.m_CurParID)
	self.m_PartnerList:UnRegisterDrag()
end

function CPartnerMainView.ShowSoulPage(self, isClick)
	self:ShowSubPage(self.m_SoulPage)
	self.m_CurPage = self.m_SoulPage
	self.m_CurPage:SetPartnerID(self.m_CurParID)
	self.m_SoulBtn:SetSelected(true)
	self.m_PartnerList:SetType("soul")
	self.m_PartnerList:OnSelectPartner(self.m_CurParID)
	self.m_PartnerList:UnRegisterDrag()
end

function CPartnerMainView.ShowPartnerEquip(self, iPartnerID)
	self.m_CurParID = iPartnerID
	self:ShowEquipPage()
end

function CPartnerMainView.ShowWear(self)
end

function CPartnerMainView.ShowEquip(self)
end

function CPartnerMainView.ShowPosEquip(self, pos)
end

function CPartnerMainView.SetNonePartner(self)
	if self.m_CurPage and self.m_CurPage.SetNonePartner then
		self.m_CurPage:SetNonePartner()
	end
end

function CPartnerMainView.UpdateTabBtn(self)
	local iGrade = data.globalcontroldata.GLOBAL_CONTROL["parsoul"].open_grade
	self.m_SoulLock:SetActive(g_AttrCtrl.grade < iGrade)
	self.m_SoulLock:AddUIEvent("click", function ()
		g_NotifyCtrl:FloatMsg("御灵系统"..tostring(iGrade).."级后开放")
		return
	end)
	--self.m_TabGrid:Reposition()
end

function CPartnerMainView.UpdateRedSpr(self)
	local oPartner = g_PartnerCtrl:GetPartner(self.m_CurParID)
	if oPartner and g_PartnerCtrl:IsFight(oPartner.m_ID) then
		if oPartner:CanParEquipUpStone() or oPartner:CanParEquipUpStar() or oPartner:CanParEquipUpGrade() or oPartner:CanWearParEquip() then
			self.m_EquipmentBtn:AddEffect("RedDot")
		else
			self.m_EquipmentBtn:DelEffect("RedDot")
		end
	else
		self.m_EquipmentBtn:DelEffect("RedDot")
	end


	if oPartner and oPartner:IsHasUpStarRedPoint() then
		self.m_MainBtn:AddEffect("RedDot")
	else
		self.m_MainBtn:DelEffect("RedDot")
	end

	
	if oPartner and oPartner:CanWearParSoul() then
		self.m_SoulBtn:AddEffect("RedDot")
	else
		self.m_SoulBtn:DelEffect("RedDot")
	end
end

function CPartnerMainView.CloseView(cls)
	g_UITouchCtrl:FroceEndDrag()
	CViewBase.CloseView(cls)
end

function CPartnerMainView.Destroy(self)
	CViewBase.Destroy(self)
	g_GuideCtrl:TriggerAll()
end

return CPartnerMainView