local CShareView = class("CShareView", CViewBase)

function CShareView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Misc/ShareView.prefab", cb)
	self.m_DepthType = "Notify"
	self.m_ExtendClose = "ClickOut"
end

function CShareView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_Grid = self:NewUI(2, CGrid)
	self.m_ShareBox = self:NewUI(3, CBox)
	self.m_ShareBox:SetActive(false)
	self.m_ShareCb = nil
	UITools.ResizeToRootSize(self.m_Container)
	self:RefreshGrid()
end

function CShareView.SetShareCb(self, cb)
	self.m_ShareCb = cb
end

function CShareView.RefreshGrid(self)
	self.m_Grid:Clear()
	local platinfos = self:GetPlatforms()
	for i, info in ipairs(platinfos) do
		local oBox = self.m_ShareBox:Clone()
		oBox.m_Sprite = oBox:NewUI(1, CSprite)
		oBox:SetActive(true)
		oBox.m_Label = oBox:NewUI(2, CLabel)
		oBox.m_Sprite:SetSpriteName(info.icon)
		oBox.m_Label:SetText(info.text)
		oBox.m_Sprite:AddUIEvent("click", callback(self, "OnShare", info.plat))
		self.m_Grid:AddChild(oBox)
	end
	self.m_Grid:Reposition()
end

function CShareView.OnShare(self, platid)
	if not g_ShareCtrl:IsClientInstalled(platid) then
		g_NotifyCtrl:FloatMsg("没有安装分享应用")
		return
	end
	if self.m_ShareCb then
		self.m_ShareCb(platid)
		self.m_ShareCb = nil
	end
	self:CloseView()
end

function CShareView.SetCloseCb(self, cb)
	self.m_CloseCallBack = cb
end

function CShareView.CloseView(self)
	if self.m_ShareCb then
		self.m_ShareCb(nil)
		self.m_ShareCb = nil
	end
	if self.m_CloseCallBack then
		self.m_CloseCallBack()
		self.m_CloseCallBack = nil
	end
	CViewBase.CloseView(self)
end

function CShareView.GetPlatforms(self)
	return {
		{plat=enum.Share.PlatformType.WeChat ,icon="pic_WeChat", text="微信好友"},
		{plat=enum.Share.PlatformType.WeChatMoments ,icon="pic_WeChatMoments", text="朋友圈"},
		{plat=enum.Share.PlatformType.SinaWeibo ,icon="pic_SinaWeibo", text="微博"},
	}
end

return CShareView