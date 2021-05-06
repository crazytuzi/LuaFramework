local CMapBookMainPage = class("CMapBookMainPage", CPageBase)

function CMapBookMainPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CMapBookMainPage.OnInitPage(self)
	self.m_PartnerBox = self:NewUI(1, CBox)
	self.m_EquipBox = self:NewUI(2, CBox)
	self.m_HeroBox = self:NewUI(3, CBox)
	self.m_WorldBox = self:NewUI(4, CBox)
	self.m_SpineTexture = self:NewUI(5, CSpineTexture)
	self.m_NpcChatLabel = self:NewUI(6, CLabelWriteEffect)
	self.m_NpcChatBG = self:NewUI(7, CSprite)
	self.m_HelpTipBtn = self:NewUI(8, CButton)
	self:InitBtnBox(self.m_PartnerBox)
	self:InitBtnBox(self.m_EquipBox)
	self:InitBtnBox(self.m_HeroBox)
	self:InitBtnBox(self.m_WorldBox)
	self.m_PartnerBox:AddUIEvent("click", callback(self, "ShowPartnerPage"))
	self.m_EquipBox:AddUIEvent("click", callback(self, "ShowEquipPage"))
	self.m_HelpTipBtn:AddHelpTipClick("mapbook")
	self:RefreshBoxShow()
	self:InitNpcChat()
	self.m_HeroBox:AddUIEvent("click", callback(self, "ShowHeroPage"))
	self.m_WorldBox:AddUIEvent("click", callback(self, "ShowWorldPage"))
	self:RefreshMapBookRedDot()
	g_MapBookCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapBookCtrlEvent"))
	g_GuideCtrl:AddGuideUI("mapbook_partner_box", self.m_PartnerBox)
	g_GuideCtrl:AddGuideUI("mapbook_world_box", self.m_WorldBox)
	
end

function CMapBookMainPage.InitNpcChat(self)
	self.m_NpcChatLabel.SetText = function(a, text)
		CLabel.SetText(a, text)
		self.m_NpcChatBG:ResetAndUpdateAnchors()
	end
	local list = {}
	for parid, v in pairs(data.partnerdata.DATA) do
		if v["show_type"] == 1 then
			table.insert(list, v.shape)
		end
	end
	self.m_NpcShapeList = list
	self.m_SpineTexture:ShapeCommon(1014, function ()
		self.m_SpineTexture:SetAnimation(0, "idle", true)
		self.m_SpineTexture:AddUIEvent("click", callback(self, "OnClickSpine"))
	end)
end

function CMapBookMainPage.InitBtnBox(self, box)
	box.m_LockSpr = box:NewUI(2, CSprite)
	box.m_IconSpr = box:NewUI(3, CSprite)
end

function CMapBookMainPage.OnShowPage(self)
	self:CreateAutoChat()
	self:RefreshMapBookRedDot()
end

function CMapBookMainPage.ShowChatMsg(self, msg)
	local text = msg or table.randomvalue(data.mapbookdata.NPCCHAT)["msg"]
	self.m_NpcChatLabel:SetActive(false)
	self.m_NpcChatLabel:SetActive(true)
	self.m_NpcChatLabel:SetEffectText(text)
end

function CMapBookMainPage.OnMapBookCtrlEvent(self, oCtrl)
	self:RefreshMapBookRedDot()
end

function CMapBookMainPage.CreateAutoChat(self)
	if not self.m_ChatTimer then
		local function update()
			if Utils.IsNil(self) then
				return
			end
			if self.m_ChatCnt > 45 then
				self.m_ChatCnt = 0
				self:OnClickSpine()
			end
			self.m_ChatCnt = self.m_ChatCnt + 1
			return true
		end
		self:ShowChatMsg()
		self.m_ChatCnt = 0
		self.m_SpineTexture:SetAnimation(0, "idle", true)
		self.m_ChatTimer = Utils.AddTimer(update, 1, 0)
	end
end

function CMapBookMainPage.RefreshBoxShow(self)
	local grade = g_AttrCtrl.grade
	self.m_PartnerBox.m_IconSpr:SetActive(grade >= data.globalcontroldata.GLOBAL_CONTROL.partnerbook.open_grade)
	self.m_PartnerBox.m_LockSpr:SetActive(grade < data.globalcontroldata.GLOBAL_CONTROL.partnerbook.open_grade)

	self.m_EquipBox.m_IconSpr:SetActive(grade >= data.globalcontroldata.GLOBAL_CONTROL.fuwenbook.open_grade)
	self.m_EquipBox.m_LockSpr:SetActive(grade < data.globalcontroldata.GLOBAL_CONTROL.fuwenbook.open_grade)

	self.m_HeroBox.m_IconSpr:SetActive(grade >= data.globalcontroldata.GLOBAL_CONTROL.personbook.open_grade)
	self.m_HeroBox.m_LockSpr:SetActive(grade < data.globalcontroldata.GLOBAL_CONTROL.personbook.open_grade)

	self.m_WorldBox.m_IconSpr:SetActive(grade >= data.globalcontroldata.GLOBAL_CONTROL.worldbook.open_grade)
	self.m_WorldBox.m_LockSpr:SetActive(grade < data.globalcontroldata.GLOBAL_CONTROL.worldbook.open_grade)

end

function CMapBookMainPage.RefreshMapBookRedDot(self)
	if g_MapBookCtrl:IsHasWorldMapAward() then
		self.m_WorldBox.m_IconSpr:AddEffect("RedDot")
	else
		self.m_WorldBox.m_IconSpr:DelEffect("RedDot")
	end

	if g_MapBookCtrl:IsHasLostBookNotify() then
		self.m_EquipBox.m_IconSpr:AddEffect("RedDot")
	else
		self.m_EquipBox.m_IconSpr:DelEffect("RedDot")
	end

	if g_MapBookCtrl:IsHasPartnerBookNotify() then
		self.m_PartnerBox.m_IconSpr:AddEffect("RedDot")
	else
		self.m_PartnerBox.m_IconSpr:DelEffect("RedDot")
	end

	if g_MapBookCtrl:IsHasPersonBookNotify() then
		self.m_HeroBox.m_IconSpr:AddEffect("RedDot")
	else
		self.m_HeroBox.m_IconSpr:DelEffect("RedDot")
	end
end

function CMapBookMainPage.ShowPartnerPage(self)
	if self.m_IsEffect then
		return
	end
	self:DoEffect(function()
		self.m_ParentView:ShowPartnerPage()
		self:DoAlphaEffect(self.m_ParentView.m_PartnerPage)
	end)
end

function CMapBookMainPage.ShowEquipPage(self)
	if self.m_IsEffect then
		return
	end
	self:DoEffect(function()
		self.m_ParentView:ShowEquipPage()
		self:DoAlphaEffect(self.m_ParentView.m_PEquipPage)
	end)
end

function CMapBookMainPage.ShowPhotoPage(self)
	self.m_ParentView:ShowPhotoPage()
end

function CMapBookMainPage.ShowHeroPage(self)
	if self.m_IsEffect then
		return
	end
	--g_MapBookCtrl:OnClickMenu(3)
	self:DoEffect(function()
		self.m_ParentView:ShowPersonBookPage()
		self:DoAlphaEffect(self.m_ParentView.m_PersonBookPage)
	end)
end

function CMapBookMainPage.ShowWorldPage(self)
	if self.m_IsEffect then
		return
	end
	if g_MapBookCtrl.m_InitWorldData then
		g_MapBookCtrl.m_WordAward = false
		CWorldMapBookView:ShowView()
	else
		netachieve.C2GSOpenPicture()
	end
end

function CMapBookMainPage.ShowLostBookPage(self)
	if self.m_IsEffect then
		return
	end
	--g_MapBookCtrl:OnClickMenu(2)
	self:DoEffect(function()
		self.m_ParentView:ShowLostBookPage()
	end)
end

function CMapBookMainPage.ShowPartnerBookPage(self)
	if self.m_IsEffect then
		return
	end
	--g_MapBookCtrl:OnClickMenu(1)
	self:DoEffect(function()
		self.m_ParentView:ShowPartnerBookPage()
		self.m_ParentView.m_PartnerBookPage:SetAlpha(0.5)
	end)
end

function CMapBookMainPage.InitCamera(self)
	local effectCamera = g_CameraCtrl:GetEffectCamera()
	effectCamera:SetEnabled(true)
	effectCamera:SetLayer(define.Layer.Effect)
	effectCamera:SetDepth(define.Layer.Effect)
	effectCamera:SetCullingMask(0)
	effectCamera:OpenCullingMask(define.Layer.Effect)
	effectCamera:SetFieldOfView(54)
	effectCamera:SetLocalRotation(Quaternion.Euler(0, 0, 0))
	effectCamera:SetLocalPos(Vector3.New(0, 0, -2))
end

function CMapBookMainPage.DoEffect(self, cb)
	local path = "Effect/UI/ui_eff_3001/Prefabs/ui_eff_3001.prefab"
	self:InitCamera()
	
	local oEffect = CEffect.New(path, g_CameraCtrl:GetEffectCamera():GetLayer(), false, nil)
	self.m_IsEffect = true
	self.m_ParentView:HideCloseBtn()
	local iTime = 0
	local function update()
		if Utils.IsNil(self) then
			return
		end
		if iTime >= 0.3 then
			self.m_IsEffect = false
			self.m_ParentView:ShowCloseBtn()
			g_CameraCtrl:GetEffectCamera():SetEnabled(false)
			oEffect:Destroy()
		else
			if iTime == 0.2 then
				cb()
			end 
			iTime = iTime + 0.1
			return true
		end
	end
	
	Utils.AddTimer(update, 0.1, 0)
end

function CMapBookMainPage.DoAlphaEffect(self, oPage)
	if self.m_AlphaTimer then
		Utils.DelTimer(self.m_AlphaTimer)
	end
	local iTime = 0
	local bookTexure = self.m_ParentView.m_BgTexture
	bookTexure:SetActive(true)
	local function update()
		oPage:SetAlpha(math.min(iTime / 5, 1))
		bookTexure:SetAlpha((5	-iTime) / 5)
		if iTime >= 8 then
			bookTexure:SetActive(false)
			return false
	
		elseif iTime >=3 then
			
		end
		iTime = iTime + 1
		return true
	end
	self.m_AlphaTimer = Utils.AddTimer(update, 0.1, 0)

end

function CMapBookMainPage.ShowPersonBookPage(self)
	if self.m_IsEffect then
		return
	end
	g_NotifyCtrl:FloatMsg("该功能暂未开放")
end


function CMapBookMainPage.OnClickSpine(self)
	if self.m_AniIdx == 2 or self.m_AniIdx == 3 then
		return
	end
	local idx = Utils.RandomInt(1, 2)
	self.m_AniIdx = idx
	local t = {"show", "talk"}
	self.m_SpineTexture:SetAnimation(0, t[idx], false)
	local t = {1.3, 2.2, 2.8}
	t = t[idx]
	self.m_SpineTexture:AddAnimation(0, "idle", true, t)
	Utils.AddTimer(function() self.m_AniIdx = 1 end, 0, t)
	self:ShowChatMsg()
	self.m_ChatCnt = 0
end

return CMapBookMainPage