local COrgMainView = class("COrgMainView", CViewBase)

function COrgMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Org/OrgMainView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_StopHeroWalk = true
end

function COrgMainView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_ShopBtn = self:NewUI(3, CBox)
	self.m_ChamberBtn = self:NewUI(4, CBox)
	self.m_WishingWellBtn = self:NewUI(5, CBox)
	self.m_ActivityBtn = self:NewUI(6, CBox)
	self.m_InviteBtn = self:NewUI(7, CButton)
	self.m_IDLabel = self:NewUI(8, CLabel)
	self.m_GradeLabel = self:NewUI(9, CLabel)
	self.m_MemberLabel = self:NewUI(10, CLabel)
	self.m_AimLabel = self:NewUI(11, CLabel)
	self.m_InfoPart = self:NewUI(12, CBox)
	self.m_HideBtn = self:NewUI(13, CButton)
	self.m_HideMark = self:NewUI(14, CBox)
	self.m_BgTexture = self:NewUI(15, CWidget)
	self.m_CloseBtn1 = self:NewUI(16, CButton)
	self.m_FlagBgSprite = self:NewUI(17, CSprite)
	self.m_FlagLabel = self:NewUI(18, CLabel)
	self.m_TipsGrid = self:NewUI(19, CGrid)
	self.m_BgScrollView = self:NewUI(20, CScrollView)
	self.m_JumpBtn = self:NewUI(21, CBox)
	self.m_Container = self:NewUI(22, CBox)
	self.m_SpreadLabel = self:NewUI(23, CCountDownLabel)
	self.m_InfoPartTween = self.m_InfoPart:GetComponent(classtype.TweenPosition)
	self.m_HideBtnTween = self.m_HideBtn:GetComponent(classtype.TweenRotation)
	self:InitContent()
end

function COrgMainView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container, 4, 4)
	self.m_JumpLeft = true
	self.m_BtnGroup = {self.m_ChamberBtn, self.m_WishingWellBtn, self.m_ActivityBtn, self.m_ShopBtn}
	for i = 1, #self.m_BtnGroup do
		self.m_BtnGroup[i].m_Select = self.m_BtnGroup[i]:NewUI(1, CBox)
		self.m_BtnGroup[i].m_Select:SetActive(true)
		self.m_BtnGroup[i]:AddUIEvent("press", callback(self, "OnHover", self.m_BtnGroup[i]))
	end
	self.m_BgScrollView:AddMoveCheck("right", self.m_BgTexture, callback(self, "OnRightEnd"))
	self.m_BgScrollView:AddMoveCheck("left", self.m_BgTexture, callback(self, "OnLeftEnd"))

	self.m_CloseBtn1:AddUIEvent("click", callback(self, "OnClose"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ShopBtn:AddUIEvent("click", callback(self, "OnClickShop"))
	self.m_ChamberBtn:AddUIEvent("click", callback(self, "OnClickChamber"))
	self.m_WishingWellBtn:AddUIEvent("click", callback(self, "OnClickWishingWell"))
	self.m_InviteBtn:AddUIEvent("click", callback(self, "OnClickInvite"))
	self.m_ActivityBtn:AddUIEvent("click", callback(self, "OnClickActivity"))
	self.m_HideBtn:AddUIEvent("click", callback(self, "OnClickHide"))
	self.m_JumpBtn:AddUIEvent("click", callback(self, "OnClickJump"))

	UITools.ScaleToFit(self.m_BgTexture, 1)
	self.m_HideMark:SetActive(false)
	-- self.m_HideMark:AddUIEvent("click", callback(self, "OnClickHide"))

	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	g_OrgCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnNotify"))
	self.m_WishingWellBtn.m_IgnoreCheckEffect = true
	self.m_ActivityBtn.m_IgnoreCheckEffect = false
	self.m_ChamberBtn.m_IgnoreCheckEffect = true

	self.m_SpreadLabel:SetTickFunc(callback(self, "OnSpreadCount"))
	self.m_SpreadLabel:SetTimeUPCallBack(callback(self, "OnSpreadTimeUp"))
	
	self:CheckRedDot()
	self:RefreshUI()
	self:InitTipsGrid()
end

function COrgMainView.OnSpreadCount(self, iValue)
	self.m_SpreadLabel:SetText(string.format("剩余时间：%s", g_TimeCtrl:GetLeftTime(iValue)))
end

function COrgMainView.OnSpreadTimeUp(self)
	self.m_SpreadLabel:SetText("未开启招募")
end

function COrgMainView.OnClickJump(self)
	local w, h = self.m_BgTexture:GetSize()
	local rw, rh = self.m_BgScrollView:GetSize()
	local pos = self.m_BgScrollView:GetLocalPos()
	local scaleX = self.m_BgTexture:GetLocalScale().x
	if self.m_JumpLeft then
		self.m_BgScrollView:MoveRelative(Vector3.New((scaleX * w - rw)/2 - pos.x, 0, 0))
	else
		self.m_BgScrollView:MoveRelative(Vector3.New((rw - scaleX * w)/2 - pos.x, 0, 0))
	end
end

function COrgMainView.InitTipsGrid(self)
	self.m_AlphaDic = {
		[0] = 1, [1] = 0.75, [2] = 0.5,
	}
	self.m_TipsGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		return oBox
	end)
	self.m_CurrentBoxIdx = 1
	Utils.AddTimer(callback(self, "UpdateBox"), 0.2, 0)
end

function COrgMainView.UpdateBox(self)
	self.m_CurrentBoxIdx = (self.m_CurrentBoxIdx + 1) % 3 + 1

	for i=1, self.m_TipsGrid:GetCount() do
		self.m_TipsGrid:GetChild(i):SetAlpha(self.m_AlphaDic[math.abs(i-self.m_CurrentBoxIdx)])
	end

	return true
end

function COrgMainView.OnRightEnd(self)
	self.m_TipsGrid:SetLocalScale(Vector3.one)
	self.m_JumpLeft = true
end

function COrgMainView.OnLeftEnd(self)
	self.m_TipsGrid:SetLocalScale(Vector3.New(-1, 1, 1))
	self.m_JumpLeft = false
end

function COrgMainView.OnHover(self, oBtn)
	for i = 1, #self.m_BtnGroup do
		self.m_BtnGroup[i].m_Select:SetActive(true)
	end
	oBtn.m_Select:SetActive(false)
end

function COrgMainView.OnClickHide(self)
	self.m_InfoPartTween:Toggle()
	self.m_HideBtnTween:Toggle()
	-- self.m_HideMark:SetActive(not self.m_HideMark:GetActive())
end

function COrgMainView.CheckRedDot(self)
	if (not g_OrgCtrl:IsPlayerWishedChip()) or (not g_OrgCtrl:IsPlayerWishedEquip()) then
		self.m_WishingWellBtn:AddEffect("RedDot", 25, Vector3.New(-323, -54, 0))
	else
		self.m_WishingWellBtn:DelEffect("RedDot")
	end

	if g_OrgCtrl:IsHasSignReward() or g_OrgCtrl:IsHasBuild() or g_OrgCtrl:IsHasBuildFinish() or g_OrgCtrl:IsHasRedBag() then
		self.m_ChamberBtn:AddEffect("RedDot", 25, Vector3.New(-456, -106, 0))
	else
		self.m_ChamberBtn:DelEffect("RedDot")
	end

	if g_OrgCtrl:IsHasFubenCnt() then
		self.m_ActivityBtn:AddEffect("RedDot", 25, Vector3.New(-452, -44, 0))
	else
		self.m_ActivityBtn:DelEffect("RedDot")
	end
end

function COrgMainView.RefreshUI(self)
	local oData = g_OrgCtrl:GetMyOrgInfo()
	self.m_IDLabel:SetText("ID" .. oData.orgid)
	self.m_AimLabel:SetText(oData.aim)
	self.m_NameLabel:SetText(oData.name)
	self.m_GradeLabel:SetText("LV：" .. oData.level)
	self.m_MemberLabel:SetText(string.format("人数：%d/%d", oData.memcnt, g_OrgCtrl:GetMaxMember(oData.level)))
	self.m_FlagBgSprite:SetSpriteName(g_OrgCtrl:GetFlagIcon(oData.flagbgid))
	self.m_FlagLabel:SetText(oData.sflag)
	self.m_SpreadLabel:BeginCountDown(g_OrgCtrl:GetSpreadTime())
end

function COrgMainView.OnClickShop(self)
	g_NpcShopCtrl:OpenShop(define.Store.Page.OrgFuLiShop)
end

function COrgMainView.OnClickChamber(self)
	COrgChamberView:ShowView()
end

function COrgMainView.OnClickWishingWell(self)
	if g_ActivityCtrl:ActivityBlockContrl("org_wish") then
		netorg.C2GSOrgWishList()
	end
end

function COrgMainView.OnClickInvite(self)
	if g_OrgCtrl:GetPosition(g_AttrCtrl.org_pos).broadcast == COrgCtrl.Has_Power then
		COrgSpreadView:ShowView()
	else
		g_NotifyCtrl:FloatMsg("仅会长和副会长可发布招募信息")
	end
end

function COrgMainView.OnClickActivity(self)
	if g_ActivityCtrl:ActivityBlockContrl("org_activity") then
		COrgActivityCenterView:ShowView()
		g_OrgCtrl:SetOrgFubenRedDot(false)
	end	
end

function COrgMainView.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.Change then
		self:CheckRedDot()
	end
end

function COrgMainView.OnNotify(self, oCtrl)
	if define.Org.Event.GetOrgAim == oCtrl.m_EventID then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.Org.Event.DelMember then
		if oCtrl.m_EventData ~= g_AttrCtrl.pid then
			self:RefreshUI()
		end
	elseif oCtrl.m_EventID == define.Org.Event.OnDealApply then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.Org.Event.UpdateOrgInfo then
		self:RefreshUI()
	elseif oCtrl.m_EventID == define.Org.Event.OnOrgFubenRedDot then
		self:CheckRedDot()
	end
end

function COrgMainView.ShowInfo(self, status)
	-- printc("ShowInfo")
	-- self.m_InfoPart:SetActive(status)
	-- self.m_ShopBtn:SetActive(status)
	-- self.m_ChamberBtn:SetActive(status)
	-- self.m_WishingWellBtn:SetActive(status)
	-- self.m_ActivityBtn:SetActive(status)
end

return COrgMainView