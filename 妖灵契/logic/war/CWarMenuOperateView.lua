local CWarMenuOperateView = class("CWarMenuOperateView", CViewBase)

function CWarMenuOperateView.ctor(self, cb)
	CViewBase.ctor(self, "UI/War/WarMenuOperateView.prefab", cb)

	self.m_ExtendClose = "ClickOut"
end

function CWarMenuOperateView.OnCreateView(self)
	self.m_BtnGrid = self:NewUI(1, CGrid)
	self.m_Container = self:NewUI(2, CWidget)
	self.m_ItemBtn = self:NewUI(3, CButton)
	self.m_ForgeBtn = self:NewUI(4, CButton)
	self.m_PartnerBtn = self:NewUI(5, CButton)
	self.m_DrawCardBtn = self:NewUI(6, CButton)
	self.m_HuntBtn = self:NewUI(7, CButton)
	self.m_ShopBtn = self:NewUI(8, CButton)
	self.m_ScheduleBtn = self:NewUI(9, CButton)
	self.m_RankBtn = self:NewUI(10, CButton)
	self.m_AchievementBtn = self:NewUI(11, CButton)
	self.m_WelfareBtn = self:NewUI(12, CButton)
	self.m_LimitRewardBtn = self:NewUI(13, CButton)
	self.m_PowerGuideBtn = self:NewUI(14, CButton)
	self.m_SystemSettingsBtn = self:NewUI(15, CButton)

	self.m_ToggleTimer = nil

	self.m_Container.m_TweenPos = self.m_Container:GetComponent(classtype.TweenPosition)
	UITools.ResizeToRootSize(self.m_Container)
	self:IntContent()
end

function CWarMenuOperateView.IntContent(self)
	self.m_ItemBtn:AddUIEvent("click", callback(self, "OnItem"))
	self.m_ForgeBtn:AddUIEvent("click", callback(self, "OnForge"))
	self.m_PartnerBtn:AddUIEvent("click", callback(self, "OnPartner"))
	self.m_DrawCardBtn:AddUIEvent("click", callback(self, "OnDrawCard"))
	self.m_HuntBtn:AddUIEvent("click", callback(self, "OnHunt"))
	self.m_ShopBtn:AddUIEvent("click", callback(self, "OnShop"))
	self.m_ScheduleBtn:AddUIEvent("click", callback(self, "OnSchedule"))
	self.m_RankBtn:AddUIEvent("click", callback(self, "OnRankBtn"))
	self.m_AchievementBtn:AddUIEvent("click", callback(self, "OnAchievement"))
	self.m_WelfareBtn:AddUIEvent("click", callback(self, "OnWelfare"))
	self.m_LimitRewardBtn:AddUIEvent("click", callback(self, "OnLimitReward"))
	self.m_PowerGuideBtn:AddUIEvent("click", callback(self, "OnPowerGuide"))
	self.m_SystemSettingsBtn:AddUIEvent("click", callback(self, "OnSysSetting"))

	self.m_Container.m_TweenPos:Toggle()
	self:CheckOpenGrade()
	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
end

--模块开放等级
function CWarMenuOperateView.CheckOpenGrade(self)
	self.m_ItemBtn:SetActive(self.m_ItemBtn:GetActive())
	self.m_ForgeBtn:SetActive(self.m_ForgeBtn:GetActive() and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.forge.open_grade)
	self.m_PartnerBtn:SetActive(self.m_PartnerBtn:GetActive())
	self.m_DrawCardBtn:SetActive(self.m_DrawCardBtn:GetActive() and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.draw_card.open_grade)
	self.m_HuntBtn:SetActive(self.m_HuntBtn:GetActive() and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.huntpartnersoul.open_grade)
	self.m_ShopBtn:SetActive(self.m_ShopBtn:GetActive() and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.shop.open_grade)
	self.m_ScheduleBtn:SetActive(self.m_ScheduleBtn:GetActive() and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.schedule.open_grade)
	self.m_RankBtn:SetActive(self.m_RankBtn:GetActive() and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.rank.open_grade)
	self.m_AchievementBtn:SetActive(self.m_AchievementBtn:GetActive() and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.achieve.open_grade)
	self.m_WelfareBtn:SetActive(self.m_WelfareBtn:GetActive() and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.welfare.open_grade)
	self.m_LimitRewardBtn:SetActive(self.m_LimitRewardBtn:GetActive() and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.limit_kuanghuan.open_grade)
	self.m_PowerGuideBtn:SetActive(self.m_PowerGuideBtn:GetActive() and g_AttrCtrl.grade >= data.globalcontroldata.GLOBAL_CONTROL.powerguide.open_grade)
	self.m_SystemSettingsBtn:SetActive(self.m_SystemSettingsBtn:GetActive())
	self.m_BtnGrid:Reposition()
end

function CWarMenuOperateView.OnNotify(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:CheckOpenGrade()
	end
end

function CWarMenuOperateView.OnItem(self)
	CItemBagMainView:ShowView()
end

function CWarMenuOperateView.OnForge(self)
	CForgeMainView:ShowView()
end

function CWarMenuOperateView.OnPartner(self)
	CPartnerMainView:ShowView()
	self:CloseView()
end

function CWarMenuOperateView.OnDrawCard(self)
	CPartnerHireView:ShowView()
end

function CWarMenuOperateView.OnHunt(self)
	g_OpenUICtrl:OpenHuntPartnerSoul()
end

function CWarMenuOperateView.OnShop(self)
	g_NpcShopCtrl:OpenShop()
end

function CWarMenuOperateView.OnSchedule(self)
	local last = g_ScheduleCtrl:GetLastSchedule()
	g_ScheduleCtrl:C2GSOpenScheduleUI(last.iRightTag, last.iTopTag, last.IDTag)
end

function CWarMenuOperateView.OnRankBtn(self)
	g_RankCtrl:OpenRank()
end

function CWarMenuOperateView.OnAchievement(self)
	g_AchieveCtrl:C2GSAchieveMain()
end

function CWarMenuOperateView.OnWelfare(self)
	CWelfareView:ShowView(function (oView)
		oView:ShowDefaultPage()
	end)
end

function CWarMenuOperateView.OnLimitReward(self)
	CLimitRewardView:ShowView()
end

function CWarMenuOperateView.OnPowerGuide(self)
	CPowerGuideMainView:ShowView()
end

function CWarMenuOperateView.OnSysSetting(self, oBtn)
	CSysSettingView:ShowView()
end
						
function CWarMenuOperateView.OnToggleClose(self)
	if self.m_ToggleTimer ~= nil then
		Utils.DelTimer(self.m_ToggleTimer)
		self.m_ToggleTimer = nil
	end
	if self.m_BehidLayer then
		self.m_BehidLayer:SetActive(false)
	end
	self.m_Container.m_TweenPos:Toggle()
	Utils.AddTimer(callback(self, "OnClose"), 0.1, 0.4)
end

function CWarMenuOperateView.CloseView(self)
	local oView = CWarMainView:GetView()
	if oView then
		oView.m_LT:ShowMenuOperate(false)
	end
	self:OnToggleClose()
end

function CWarMenuOperateView.OnClose(self)
	g_ViewCtrl:CloseView(self)
end

return CWarMenuOperateView