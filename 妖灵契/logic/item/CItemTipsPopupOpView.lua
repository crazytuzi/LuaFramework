local CItemTipsPopupOpView = class("CItemTipsPopupOpView", CViewBase)

CItemTipsPopupOpView.MaxCount = 4

function CItemTipsPopupOpView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Item/ItemTipsPopupOpView.prefab", cb)
	--界面设置
	--self.m_ExtendClose = "ClickOut"
	-- self.m_BehindStrike = false
end

function CItemTipsPopupOpView.OnCreateView(self)
	self.m_OpGrid = self:NewUI(1, CGrid)
	self.m_OpBtn = self:NewUI(2, CButton, true, false)
	self.m_Bg = self:NewUI(3, CSprite)
	self.m_ScroolView = self:NewUI(4, CScrollView)
	self.m_OpGridWidget = self:NewUI(1, CBox)

	self.m_SelectCallback = nil
	self.m_Content = {}
	self.m_OpBtn:SetActive(false)
	self.m_MaxCount = CItemTipsPopupOpView.MaxCount
	self:InitContent()
end

function CItemTipsPopupOpView.InitContent(self)
	g_UITouchCtrl:TouchOutDetect(self.m_Bg, function(obj)
		self:CloseView()
	end)
end

function CItemTipsPopupOpView.ShowPopupList( self, config)
	self.m_OpGrid:Clear()
	self.m_Content = config.Content
	self.m_SelectCallback = config.SelectCallback
	for i = 1, #config.Content do
		local str = config.Content[i]
		self:AddOp(str, callback(self, "OnSelect", i))
	end	
	self:ResizeBg()
end

function CItemTipsPopupOpView.OnSelect(self, pos)
	if self.m_SelectCallback ~= nil then
		self.m_SelectCallback(pos)
	end
end

function CItemTipsPopupOpView.ResizeBg(self)
	self.m_OpGrid:Reposition()
	self.m_ScroolView:ResetPosition()
	local count = self.m_OpGrid:GetCount()
	local height = self.m_OpBtn:GetHeight()	* 4
	local curHeigh = self.m_OpBtn:GetHeight() * #self.m_Content
	local iHeight = math.min(height, curHeigh)
	--height =  (count > self.m_MaxCount) and ( height * self.m_MaxCount)  or ( height * count)
	self.m_OpGridWidget:SetHeight(iHeight)
	self.m_Bg:SetHeight(iHeight + 15)
end

function CItemTipsPopupOpView.AddOp(self, sText, func)
	local oBtn = self.m_OpBtn:Clone(false)
	oBtn:SetActive(true)
	local function wrapclose()
		func()
		if Utils.IsExist(self) then
			CItemTipsPopupOpView:CloseView()
		end
	end
	oBtn:AddUIEvent("click", wrapclose)
	oBtn:SetText(sText)
	self.m_OpGrid:AddChild(oBtn)
	return oBtn
end

return CItemTipsPopupOpView