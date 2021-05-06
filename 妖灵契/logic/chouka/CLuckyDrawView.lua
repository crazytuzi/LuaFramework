local CLuckyDrawView = class("CLuckyDrawView", CViewBase)
--wuling武灵
--wuhun武魂
function CLuckyDrawView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Partner/PartnerLuckyDrawView.prefab", cb)
	self.m_SwitchSceneClose = true
	self.m_DepthType = "Menu"
	--self.m_GroupName = "main"
end

function CLuckyDrawView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_DrawMainPage = self:NewPage(2, CDrawMainPage)
	self.m_DrawWhPage = self:NewPage(3, CDrawWhPage)
	self.m_DrawWlPage = self:NewPage(4, CDrawWlPage)
	self.m_DrawWhFivePage = self:NewPage(12, CDrawWhFivePage)
	
	self.m_ItemLabelList = {}
	self.m_ItemLabelList[1] = self:NewUI(5, CLabel)
	self.m_ItemLabelList[2] = self:NewUI(6, CLabel)
	self.m_GoldLabel = self:NewUI(7, CLabel)
	self.m_Container = self:NewUI(8, CWidget)
	self.m_BulletSelBtn = self:NewUI(9, CButton)
	self.m_CloseBtn2 = self:NewUI(10, CButton)
	self.m_GoldContainer = self:NewUI(11, CObject)
	g_GuideCtrl:AddGuideUI("drawcard_close_rt", self.m_CloseBtn)
	g_GuideCtrl:AddGuideUI("drawcard_close_lb", self.m_CloseBtn2)
	self.m_IsInResult = false
	--netopenui.C2GSOpenInterface(define.OpenInterfaceType.Barrage)
	-- CBulletScreenView:ShowView(function ()
	-- 	self:InitBulletState()
	-- end)
	self:ShowSubPage(self.m_DrawMainPage)
	self:RefreshGold()
	self:InitContent()
end

function CLuckyDrawView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container, 4, 4)
	self.m_BulletSelBtn:AddUIEvent("click", callback(self, "OnChangeBullet"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshGold"))
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "RefreshGold"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CloseBtn2:AddUIEvent("click", callback(self, "OnClose"))
end

function CLuckyDrawView.CloseView(self)
	g_ViewCtrl:CloseInterface(define.OpenInterfaceType.Barrage)
	CBulletScreenView:CloseView()
	CViewBase.CloseView(self)
end

function CLuckyDrawView.RefreshGold(self)
	local str = ""
	for i, shape in ipairs({10020, 10021}) do
		local amount = g_ItemCtrl:GetBagItemAmountBySid(shape)
		self.m_ItemLabelList[i]:SetText(amount)
	end
	self.m_GoldLabel:SetText(string.numberConvert(g_AttrCtrl.goldcoin))
end

function CLuckyDrawView.SetResult(self, itype, partner_list, desc, redraw_cost)
	if itype == 1 then
		self:ShowSubPage(self.m_DrawWlPage)
		self.m_DrawWlPage:SetResult(partner_list)
	
	elseif itype == 2 then
		if #partner_list == 1 then
			self:ShowSubPage(self.m_DrawWhPage)
			self.m_DrawWhPage:SetResult(partner_list, desc, redraw_cost)
		else
			self:ShowSubPage(self.m_DrawWhFivePage)
			self.m_DrawWhFivePage:SetResult(partner_list)
		end
	elseif itype == 3 then
		self:ShowSubPage(self.m_DrawWhFivePage)
		self.m_DrawWhFivePage:SetResult(partner_list)
	end
	self.m_IsInResult = true
end

function CLuckyDrawView.DoResultEffect2(self, iParID)
	self:ShowSubPage(self.m_DrawWhPage)
	self.m_DrawWhPage:SetActive(false)
	self.m_DrawWhPage:DoResultEffect(iParID)
end

function CLuckyDrawView.SetBtnShow(self, bShow)
	self.m_GoldContainer:SetActive(bShow)
	self.m_BulletSelBtn:SetActive(false)
	self.m_CloseBtn2:SetActive(bShow)
	if self.m_DrawWhPage:IsShow() then
		self.m_DrawWhPage:SetBtnShow(bShow)
	elseif self.m_DrawWlPage:IsShow() then
		self.m_DrawWlPage:SetBtnShow(bShow)
	end
end

function CLuckyDrawView.ShowMain(self)
	self:ShowSubPage(self.m_DrawMainPage)
	self.m_DrawMainPage:OnBackMain()
	self.m_IsInResult = false
end
	
function CLuckyDrawView.InitBulletState(self)
	local istate = IOTools.GetRoleData("chouka_bullet") or 1
	local oView = CBulletScreenView:GetView()
	istate = 0
	if oView then
		oView:SetActive(istate == 1)
	end
	self.m_BulletSelBtn:SetSelected(istate == 0)
end

function CLuckyDrawView.OnChangeBullet(self)
	local oView = CBulletScreenView:GetView()
	if not oView then
		return
	end
	if self.m_BulletSelBtn:GetSelected() then
		IOTools.SetRoleData("chouka_bullet", 0)
		oView:SetActive(false)
	else
		IOTools.SetRoleData("chouka_bullet", 1)
		oView:SetActive(true)
	end
end

function CLuckyDrawView.Destroy(self)
	g_GuideCtrl:DelGuideUIEffect("drawcard_close_lb", "circle")
	--暂时注释
	--g_GuideCtrl:TriggerWar1()
	CViewBase.Destroy(self)
	g_ChoukaCtrl:Close()
end

return CLuckyDrawView