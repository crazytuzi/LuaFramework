local CBehindLayer = class("CBehindLayer", CPanel, CGameObjContainer)
--界面黑底，关闭界面, 阻挡点击地图

function CBehindLayer.ctor(self)
	local obj = g_ResCtrl:GetCloneFromCache("UI/Misc/BehindLayer.prefab")
	CPanel.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)
	self.m_DataContainer = self:GetComponent(classtype.DataContainer)
	self.m_ClickWidget = self:NewUI(1, CWidget)
	self.m_Texture = nil
	self.m_IsShelter = false
	UITools.ResizeToRootSize(self.m_ClickWidget)
	self.m_ClickWidget:AddUIEvent("click", callback(self, "OnClick"))
end

function CBehindLayer.SetTextrueShow(self, bShow)
	if self.m_Texture then
		self.m_Texture:SetActive(bShow)
	else
		if bShow then
			g_ResCtrl:LoadCloneAsync("UI/Misc/BehindBlack.prefab", callback(self, "OnTextureLoadDone"), true)
		end
	end
end

function CBehindLayer.OnTextureLoadDone(self, oClone, path)
	if oClone then
		self.m_Texture = CTexture.New(oClone)
		self.m_Texture:SetCacheKey(path)
		self.m_Texture:SetParent(self.m_Transform)
		self.m_Texture:SetLocalPos(Vector3.zero)
		UITools.ResizeToRootSize(self.m_Texture, 4, 4)
	end
end

function CBehindLayer.OnClick(self)
	if self.m_IsShelter then
		return
	end
	local oView = self:GetOwner()
	if not oView then
		return
	end
	local bClose = true
	if oView.m_BehindStrike then
		local m = self.m_ClickWidget.m_UIEventHandler:GetUnderHandler()
		if m then
			if m.name ~= "clickWidget" then
				m:Call(enum.UIEvent["click"])
			end
			bClose = not oView:GetStrikeResult()
			oView:SetStrikeResult(false)
		end
	end
	if bClose then
		if oView.ExtendCloseView then
			oView:ExtendCloseView()
		else
			oView:CloseView()
		end
	end
end

function CBehindLayer.SetShelter(self, b)
	self.m_IsShelter = b
end

function CBehindLayer.GetOwner(self)
	return getrefobj(self.m_OwnerRef)
end

function CBehindLayer.SetOwner(self, oView)
	if Utils.IsExist(oView) then
		local depth = oView:GetDepth()
		self:SetParent(oView:GetParent(), false)
		self.m_DataContainer.gameObjectValue = oView.m_GameObject
		-- self:SetParent(oView.m_Transform)
		self:SetPos(Vector3.zero)
		self:SetDepth(depth-1)
		self.m_OwnerRef = weakref(oView)
	else
		self.m_OwnerRef = nil
	end
end

function CBehindLayer.Destroy(self)
	if self.m_Texture then
		-- self.m_Texture:Destroy()
		g_ResCtrl:PutCloneInCache(self.m_Texture:GetCacheKey(), self.m_Texture.m_GameObject)
	end
	CPanel.Destroy(self)
end

return CBehindLayer