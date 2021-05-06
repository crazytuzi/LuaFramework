local CWarSwitchPartnerBox = class("CWarSwitchPartnerBox", CBox)

function CWarSwitchPartnerBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_PartnerTable = self:NewUI(1, CTable)
	self.m_PartnerCard = self:NewUI(2, CPartnerCard)
	self.m_NoParLabel = self:NewUI(3, CLabel)
	self.m_LastHoverRef = nil
	self:InitContent()
end

function CWarSwitchPartnerBox.InitContent(self)
	self.m_PartnerCard:SetActive(false)
	self:RefershPartners()
end

function CWarSwitchPartnerBox.LastHoverWarrior(self)
	return getrefobj(m_LastHoverRef)
end


function CWarSwitchPartnerBox.RefershPartners(self)
	self.m_PartnerTable:Clear()
	local list = g_PartnerCtrl:GetPartnerList()
	for i, oPartner in ipairs(list) do
		local oCard = self.m_PartnerCard:Clone()
		oCard:SetPartnerID(oPartner.m_ID)
		oCard:SetActive(true)
		local dArgs = {
			start_func = function(o) return not o:IsFight() end,
			start_delta = Vector2.New(0, 10),
			cb_dragstart = callback(self, "OnDragStart"),
			cb_dragging = callback(self, "OnDragging"),
			cb_dragend = callback(self, "OnDragEnd")
		}
		g_UITouchCtrl:AddDragObject(oCard, dArgs)
		self.m_PartnerTable:AddChild(oCard)
	end
	self.m_NoParLabel:SetActive(#list == 0)
end

function CWarSwitchPartnerBox.OnDragStart(self, oCard)

end

function CWarSwitchPartnerBox.OnDragging(self, oCard)
	local worldPos = oCard:GetCenterPos()
	local oCam = g_CameraCtrl:GetUICamera()
	local screenPos = oCam:WorldToScreenPoint(worldPos)
	local oWarrior = g_WarTouchCtrl:GetTouchWarrior(screenPos.x, screenPos.y)
	local oLastWarrior = self:LastHoverWarrior()
	if oLastWarrior ~= oWarrior then
		if oLastWarrior then
			oLastWarrior:ShowReplaceEffect(false)
		end
		if oWarrior and oWarrior:IsCanReplace() then
			oWarrior:ShowReplaceEffect(true)
			self.m_LastHoverRef = weakref(oWarrior)
		else
			self.m_LastHoverRef = nil
		end
	end
end

function CWarSwitchPartnerBox.OnDragEnd(self, oCard)
	local oLastWarrior = self:LastHoverWarrior()
	if oLastWarrior then
		printc("交换", oLastWarrior.m_ID)
		oLastWarrior:ShowReplaceEffect(false)
		g_WarCtrl:ReplacePartner(oLastWarrior.m_ID, oCard.m_PartnerID)
	end
	self.m_LastHoverRef = nil
end

function CWarSwitchPartnerBox.FroceEndDrag(self)
	local oLastWarrior = self:LastHoverWarrior()
	if oLastWarrior then
		oLastWarrior:ShowReplaceEffect(false)
	end
	self.m_LastHoverRef = nil
	g_UITouchCtrl:FroceEndDrag()
end

return CWarSwitchPartnerBox