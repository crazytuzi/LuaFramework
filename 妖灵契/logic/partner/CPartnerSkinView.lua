local CPartnerSkinView = class("CPartnerSkinView", CViewBase)

function CPartnerSkinView.ctor(self, cb)
	CViewBase.ctor(self, "UI/partner/PartnerSkinView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
end


function CPartnerSkinView.OnCreateView(self)
	self.m_Texture = self:NewUI(1, CTexture)
	self.m_CloseBtn = self:NewUI(2, CBox)
	self.m_ShareBtn = self:NewUI(3, CButton)
	self.m_SkinNameTexure = self:NewUI(4, CTexture)
	self.m_ShareTexture = self:NewUI(5, CTexture)
	self.m_NameLabel = self:NewUI(6, CLabel)
	self.m_ServerLabel = self:NewUI(7, CLabel)
	self.m_BGTexture = self:NewUI(8, CTexture)
	self.m_ContinuLabel = self:NewUI(9, CLabel)
	self.m_SharePart = self:NewUI(10, CObject)
	self.m_Container = self:NewUI(11, CWidget)
	self:InitContent()
end

function CPartnerSkinView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_ShareBtn:AddUIEvent("click", callback(self, "OnClickShare"))
	self.m_BGTexture:AddUIEvent("click", callback(self, "OnClose"))
	self.m_SharePart:SetActive(false)
	self.m_ServerLabel:SetText(g_ServerCtrl:GetCurServerName())
	self.m_ShareBtn:SetActive(g_ShareCtrl:IsShowShare())
	self.m_NameLabel:SetText(g_AttrCtrl.name)
	self:SetActive(false)
end

function CPartnerSkinView.OnClickShare(self)
	self:DoShare()
end

function CPartnerSkinView.IsHasSkinView(cls, sid)
	local oData = DataTools.GetItemData(sid)
	if oData then
		local iShape = oData.shape
		if data.partnerskinsizedata.PartnerSkinSize[iShape] then
			return true
		end
	end
	return false
end

function CPartnerSkinView.SetData(self, sid)
	local oData = DataTools.GetItemData(sid)
	local iShape = oData.shape
	self.m_Shape = iShape
	local sPath = string.format("Texture/Skin/skin_"..iShape..".png")
	if not g_ResCtrl:IsExist(sPath) then
		sPath = "Texture/Photo/full_9999.png"
	end
	self.m_Texture:LoadPath(sPath, callback(self, "LoadDoneCallback"))

	local sPath = string.format("Texture/Skin/skinname_"..iShape..".png")
	if not g_ResCtrl:IsExist(sPath) then
		sPath = "Texture/Photo/full_9999.png"
	end
	self.m_SkinNameTexure:LoadPath(sPath)
end

function CPartnerSkinView.LoadDoneCallback(self)
	local info = data.partnerskinsizedata.PartnerSkinSize[self.m_Shape]
	if info then
		self.m_Texture:SetSize(info.w, info.h)
		local w, h = UITools.GetRootSize()
		self.m_Texture:SetLocalPos(Vector3.New(w/2 - info.w/2, -h/2 + info.h/2, 0))
	end
	self:SetActive(true)
end

function CPartnerSkinView.DoShare(self)
	self.m_ShareBtn:SetActive(false)
	self.m_ContinuLabel:SetActive(false)
	g_NotifyCtrl:HideView(true)
	local oView = CAchieveFinishTipsView:GetView()
	if oView then
		self.m_AchieveFlag = oView:GetActive()
		oView:SetActive(false)
	end
	local tex = Utils.CreateQRCodeTex(define.Url.OffcialWeb, self.m_ShareTexture.m_UIWidget.width)
	self.m_SharePart:SetActive(true)
	self.m_ShareTexture:SetMainTexture(tex)
	Utils.AddTimer(callback(self, "PrintSceen"), 0, 0)
end

function CPartnerSkinView.PrintSceen(self)
	local w, h = UITools.GetRootSize()
	local rt = UnityEngine.RenderTexture.New(w, h, 16)
	local oCam = g_CameraCtrl:GetUICamera()
	oCam:SetTargetTexture(rt)
	oCam:Render()
	oCam:SetTargetTexture(nil)
	local texture2D = UITools.GetRTPixels(rt)
	local filename = os.date("%Y%m%d%H%M%S", g_TimeCtrl:GetTimeS())
	local path = IOTools.GetRoleFilePath(string.format("/Screen/%s.jpg", filename))
	IOTools.SaveByteFile(path, texture2D:EncodeToJPG())
	self:EndShare(self)
	local sTip = string.format("【#妖灵契#没想到你居然还有这种皮肤~%s】", define.Url.OffcialWeb)
	g_ShareCtrl:ShareImage(path, sTip, function () 
		if not g_AttrCtrl:IsHasGameShare() then
			netplayer.C2GSGameShare("skin_share")
		end
	end)
end

function CPartnerSkinView.EndShare(self)
	g_NotifyCtrl:HideView(false)
	self.m_ShareBtn:SetActive(true)
	self.m_ContinuLabel:SetActive(true)
	self.m_SharePart:SetActive(false)
	local oView = CAchieveFinishTipsView:GetView()
	if oView and self.m_AchieveFlag then
		oView:SetActive(true)
	end
end


return CPartnerSkinView