_G.PortalController = setmetatable({}, {__index = IController})
PortalController.name = "PortalController"
PortalController.currPickPortal = nil

function PortalController:Create()
	CControlBase:RegControl(self, true)
	CPlayerControl:AddPickListen(self)
	self.bCanUse = true
	return true
end

function PortalController:Update(interval)
	PortalController:CheckCloseDialog()
	return true
end

function PortalController:OnEnterGame()
	return true
end

function PortalController:OnChangeSceneMap()
	return true
end

function PortalController:OnLeaveSceneMap()
	return true
end

function PortalController:OnLineChange()
	return true
end

function PortalController:OnMouseWheel()
	return true
end

function PortalController:OnBtnPick(button, type, node)
	self:OnMouseClick(node)
end

function PortalController:OnRollOver(type, node)
	self:OnMouseOver(node)
end

function PortalController:OnRollOut(type, node)
	self:OnMouseOut(node)
end

function PortalController:OnMouseOut(node)
	if not node then
		return
	end
	local cid = node.cid
	local portal = PortalController:GetPortal(cid)
	if not portal then
		return
	end
	self:MouseOutNpc(portal)
end

function PortalController:OnMouseOver(node)
	if not node then
		return
	end
	local cid = node.cid
	local portal = PortalController:GetPortal(cid)
	if not portal then
		return
	end
	self:MouseOverNpc(portal)
end

function PortalController:OnMouseClick(node)
	if not node then
		return
	end
	local cid = node.cid
	local portal = PortalController:GetPortal(cid)
	if not portal then
		return
	end
	PortalController.currPickPortal = cid
	PortalController:OpenDialog()
end

function PortalController:MouseOverNpc(portal)
	if portal.avatar then 
		portal.avatar:SetHighLight( 0x10000000 )
    end
end

function PortalController:MouseOutNpc(portal)
	if portal.avatar then 
		portal.avatar:DelHighLight()
    end
end

function PortalController:GetPortal(cid)
	if not CPlayerMap.currMapPoint then
		return
	end
	return CPlayerMap.currMapPoint[cid]
end

function PortalController:CheckCloseDialog()
	local cid = PortalController.currPickPortal
	if not cid then
		PortalController:CloseDialog()
		return
	end
	local portal = PortalController:GetPortal(cid)
	if not portal then
		PortalController:CloseDialog()
	end
end

function PortalController:OpenDialog()
	local cid = PortalController.currPickPortal
	if not cid then
		return
	end
	local portal = PortalController:GetPortal(cid)
	if not portal then
		return
	end
	CPlayerMap:OnEnterMascotCome(portal)
end

function PortalController:CloseDialog()
	PortalController.currPickPortal = nil
	UIConfirm:Close(CPlayerMap.uiconfirmID)
end

function PortalController:AddPortal(point)
	local portal = Portal:New(point.id, point.cid, point.x, point.y)
	if not portal then
		return
	end
	portal:Show()
	return portal
end

function PortalController:DeletePortal(cid)
	local portal = PortalController:GetPortal(cid)
	if not portal then
		return
	end
	portal:Hide()
end