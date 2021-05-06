local CWindowUsePropView = class("CWindowUsePropView", CViewBase)

function CWindowUsePropView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Notify/WindowUsePropView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_ExtendClose = "Black"
end

function CWindowUsePropView.OnCreateView(self)
	self.m_Icon = self:NewUI(1, CSprite)
	self.m_TitleLable = self:NewUI(2, CLabel)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_EnterBtn = self:NewUI(4, CButton)
	self.m_CloseBtn = self:NewUI(5, CButton)
	self.m_BackGroundSprite = self:NewUI(6, CSprite)
	self.m_NumLabel = self:NewUI(7, CLabel)

	self.m_PropName = ""
	self.m_Sid = 0
	self.m_PropNumList = 0
	self.m_CData = {}
	self.m_BtnCallBack = nil

	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnItemCtrlEvent"))
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_EnterBtn:AddUIEvent("click", callback(self, "OnUseProp"))
end

function CWindowUsePropView.OnItemCtrlEvent(self, oCtrl)	
	if oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem or 
		oCtrl.m_EventID == define.Item.Event.RefreshBagItem then
		self.m_NumLabel:SetText(g_ItemCtrl:GetBagItemAmountBySid(self.m_Sid).."/1")
	end
end

function CWindowUsePropView.OnUseProp(self)
	if g_ItemCtrl:GetBagItemAmountBySid(self.m_Sid) == 0  then
		g_NotifyCtrl:FloatMsg(self.m_PropName .. "不足!!")
		return
	end

	if self.m_BtnCallBack then
		self.m_BtnCallBack()
	end
	self:CloseView()
end

function CWindowUsePropView.SetWinInfo(self, data)
	self.m_Sid = data.sid
	self.m_CData = DataTools.GetItemData(data.sid)
	self.m_PropName = self.m_CData.name
	
	self.m_BtnCallBack = data.callback
	self.m_Icon:SpriteItemShape(self.m_CData.icon)
	self.m_TitleLable:SetText(data.title or "提示")
	self.m_NameLabel:SetText(self.m_PropName or "")
	self.m_EnterBtn:SetText(data.btnname or "确定")

	self.m_NumLabel:SetText(g_ItemCtrl:GetBagItemAmountBySid(self.m_Sid).."/1")
end

return CWindowUsePropView