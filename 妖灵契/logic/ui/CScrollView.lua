local CScrollView = class("CScrollView", CPanel)

function CScrollView.ctor(self, obj)
	CPanel.ctor(self, obj)
	self.m_UIScrollView = obj:GetComponent(classtype.UIScrollView)
	self.m_AbsoluteBounds = UITools.CalculateAbsoluteWidgetBounds(self.m_Transform)
	self.m_ForceCheckCull = false
	self.m_PreCnt = 1
	self.m_MoveCheck = {}
	self.m_CullObj = nil
	if self.m_UIScrollView.momentumAmount == 35 then
		self.m_UIScrollView.momentumAmount = 200
	end
end

function CScrollView.MoveRelative(self, pos)
	if pos ~= Vector3.zero then
		self.m_UIScrollView:MoveRelative(pos)
	end
end

function CScrollView.MoveAbsolute(self, pos)
	self.m_UIScrollView:MoveAbsolute(pos)
end

function CScrollView.Press(self, bPress)
	self.m_UIScrollView:Press(bPress)
end

function CScrollView.Drag(self)
	self.m_UIScrollView:Drag()
end

function CScrollView.Scroll(self, delta)
	self.m_UIScrollView:Scroll(delta)
end

function CScrollView.RestrictWithinBounds(self, bInstant)
	return self.m_UIScrollView:RestrictWithinBounds(bInstant)
end

function CScrollView.ResetPosition(self)
	return self.m_UIScrollView:ResetPosition()
end

function CScrollView.DisableSpring(self)
	self.m_UIScrollView:DisableSpring()
end

function CScrollView.GetMovement(self)
	return self.m_UIScrollView.movement
end

function CScrollView.InitCenterOnCompnent(self, oEventHandler, cb)
	self.m_UIScrollView.centerOnChild = oEventHandler:GetComponent(classtype.UICenterOnChild)
	if self.m_UIScrollView.centerOnChild then
		oEventHandler:AddUIEvent("UICenterOnChildOnCenter", cb)
	end
end

function CScrollView.CenterOn(self, transform)
	local o = self.m_UIScrollView.centerOnChild
	if o then
		o:CenterOn(transform)
	end
end

function CScrollView.GetCenteredObject(self)
	local o = self.m_UIScrollView.centerOnChild
	if o then
		return o.centeredObject
	end
end

function CScrollView.SetCullContent(self, obj)
	if obj.GetChildList then
		self.m_CullObj = obj
		self:StartClipMoveCheck()
	end
end

function CScrollView.AddMoveCheck(self, sType, obj, cb)
	self.m_MoveCheck[sType] = {obj=obj, cb=cb}
	self:StartClipMoveCheck()
end

function CScrollView.ClipMove(self)
	self:CheckMove()
	self:CullContent()
end


function CScrollView.RefreshBounds(self)
	self.m_AbsoluteBounds = UITools.CalculateAbsoluteWidgetBounds(self.m_Transform)
end

function CScrollView.CheckMove(self)
	for sType, dInfo in pairs(self.m_MoveCheck) do
		if not dInfo.obj then
			--continue
		elseif sType == "right" then
			local bounds = UITools.CalculateAbsoluteWidgetBounds(dInfo.obj.m_Transform)
			if bounds.max.x - self.m_AbsoluteBounds.max.x <= -0.03 then
				dInfo.cb()
			end
		elseif sType == "left" then
			local bounds = UITools.CalculateAbsoluteWidgetBounds(dInfo.obj.m_Transform)
			if bounds.min.x - self.m_AbsoluteBounds.min.x >= 0.03 then
				dInfo.cb()
			end
		elseif sType == "down" then
			local bounds = UITools.CalculateAbsoluteWidgetBounds(dInfo.obj.m_Transform)
			if bounds.min.y - self.m_AbsoluteBounds.min.y >= 0.03 then
				dInfo.cb()
			end
		elseif sType == "up" then
			local bounds = UITools.CalculateAbsoluteWidgetBounds(dInfo.obj.m_Transform)
			if bounds.max.y - self.m_AbsoluteBounds.max.y <= -0.03 then
				dInfo.cb()
			end
		
		elseif sType == "upmove" then
			local bounds = UITools.CalculateAbsoluteWidgetBounds(dInfo.obj.m_Transform)
			if bounds.max.y - self.m_AbsoluteBounds.max.y >= 0.03 then
				dInfo.cb()
			end
		
		elseif sType == "downmove" then
			local bounds = UITools.CalculateAbsoluteWidgetBounds(dInfo.obj.m_Transform)
			if bounds.max.y - self.m_AbsoluteBounds.max.y <= -0.03 then
				dInfo.cb()
			end
		end
	end
end

function CScrollView.CullContent(self)
	if self.m_CullObj == nil then
		return
	end
	for i, oWidget in ipairs(self.m_CullObj:GetChildList()) do
		local bNeedShow = not self:IsFullOut(oWidget)
		if oWidget.m_LastScrollCull ~= bNeedShow then
			oWidget.m_LastScrollCull = bNeedShow
			oWidget:SetActive(bNeedShow)
		end
	end
end

function CScrollView.CullContentLater(self)
	if self.m_LaterTimer then
		return
	end
	local function later(obj)
		obj.m_LaterTimer = nil
		obj:CullContent()
	end
	self.m_LaterTimer = Utils.AddTimer(objcall(self, later), 0, 0.5)
end

function CScrollView.Move2Obj(self, obj, bHorizontal, offset)
	local offset = offset or Vector3.zero
	local pos = obj:GetLocalPos()
	self.m_UIScrollView:ResetPosition()
	if bHorizontal then
		self.m_UIScrollView:MoveRelative(Vector3.New(-pos.x, 0, 0))
	else
		self.m_UIScrollView:MoveRelative(Vector3.New(0, -pos.y, 0))
	end
end

function CScrollView.Move2Pos(self, pos, bHorizontal, offset)
	local offset = offset or Vector3.zero
	self.m_UIScrollView:ResetPosition()
	if bHorizontal then
		self.m_UIScrollView:MoveRelative(Vector3.New(-pos.x, 0, 0))
	else
		self.m_UIScrollView:MoveRelative(Vector3.New(0, -pos.y, 0))
	end
end

return CScrollView