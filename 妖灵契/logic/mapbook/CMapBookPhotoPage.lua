local CMapBookPhotoPage = class("CMapBookPhotoPage", CPageBase)

function CMapBookPhotoPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CMapBookPhotoPage.OnInitPage(self)
	self.m_Texture = self:NewUI(1, CTexture)
	self.m_BGRoot = self:NewUI(2, CTexture)
	self.m_Grid = self:NewUI(3, CGrid)
	self.m_BackBtn = self:NewUI(4, CButton)
	self.m_ShareBtn = self:NewUI(5, CButton)
	self.m_SharePart = self:NewUI(6, CBox)
	self.m_ShareTexture = self:NewUI(7, CTexture)
	self.m_TextureList = {}
	self.m_RareBtn = {}
	self.m_Grid:InitChild(function (obj, idx)
		local oButton = CButton.New(obj)
		oButton:SetGroup(self.m_Grid:GetInstanceID())
		oButton:AddUIEvent("click", callback(self, "ShowRarePhoto", 5 - idx))
		self.m_RareBtn[idx] = oButton
		return oButton
	end)
	self.m_RareBtn[1]:SetSelected(true)
	self:InitContent()
	self:InitShare()
end

function CMapBookPhotoPage.InitContent(self)
	self.m_ShareBtn:SetActive(g_ShareCtrl:IsShowShare())
	self.m_BackBtn:AddUIEvent("click", function ()
		self.m_ParentView:ShowMainPage()
	end)
	self.m_ShareBtn:AddUIEvent("click", callback(self, "DoShare"))
	self:ShowRarePhoto(4)
	self.m_SharePart:SetActive(false)
end

function CMapBookPhotoPage.InitShare(self)
	self.m_NameLabel = self.m_SharePart:NewUI(2, CLabel)
	self.m_ServerLabel = self.m_SharePart:NewUI(3, CLabel)
	self.m_ServerLabel:SetText(g_ServerCtrl:GetCurServerName())
	self.m_ShareBtn:SetActive(g_ShareCtrl:IsShowShare())
	self.m_NameLabel:SetText(g_AttrCtrl.name)
end

function CMapBookPhotoPage.ShowRarePhoto(self, iRare)
	iRare = iRare or 4
	local pdata = data.partnerbookdata.PartnerBookConfig
	local k = 1
	for _, photoObj in pairs(pdata) do
		if photoObj["rare"] == iRare then
			local oTexture = self.m_TextureList[k]
			if not oTexture then
				oTexture = self.m_Texture:Clone()
				oTexture:SetParent(self.m_BGRoot.m_Transform)
			end
			oTexture:SetActive(true)
			oTexture:LoadFullPhoto(photoObj.shape, function ()
				oTexture:SetSize(photoObj.w, photoObj.h)
				oTexture:SetLocalPos(Vector3.New(photoObj.x, photoObj.y, 0))
				oTexture:SetDepth(photoObj.depth)
				if photoObj.direct == 2 then
					oTexture:SetFlip(enum.UIBasicSprite.Horizontally)
				else
					oTexture:SetFlip(enum.UIBasicSprite.Nothing)
				end
				if g_PartnerCtrl:IsGetPartner(photoObj.shape) then
					oTexture:SetColor(Utils.HexToColor("ffffffff"))
				else
					oTexture:SetColor(Utils.HexToColor("383838FF"))
				end
			end)
			self.m_TextureList[k] = oTexture
			k = k + 1
		end
	end
	local iAmount = #self.m_TextureList
	if iAmount >= k then
		for i = k, iAmount do
			self.m_TextureList[i]:SetActive(false)
		end
	end

end

function CMapBookPhotoPage.DoShare(self)
	self.m_SharePart:SetActive(true)
	self.m_Grid:SetActive(false)
	self.m_ShareBtn:SetActive(false)
	self.m_BackBtn:SetActive(false)
	local tex = Utils. CreateQRCodeTex("http://ylq.kpzs.com/", self.m_ShareTexture.m_UIWidget.width)
	self.m_ShareTexture:SetMainTexture(tex)
	Utils.AddTimer(callback(self, "PrintSceen"), 0, 0)
end

function CMapBookPhotoPage.PrintSceen(self)
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
	g_ShareCtrl:ShareImage(path, "【#妖灵契#这里有一张我和我的小伙伴的照片~http://ylq.kpzs.com/】", function ()
		if not g_AttrCtrl:IsHasGameShare() then
			netplayer.C2GSGameShare("picture_share")
		end
	end)
end

function CMapBookPhotoPage.EndShare(self)
	self.m_Grid:SetActive(true)
	self.m_ShareBtn:SetActive(true)
	self.m_SharePart:SetActive(false)
	self.m_BackBtn:SetActive(true)
end

return CMapBookPhotoPage