local CUITouchCtrl = class("CUITouchCtrl")

function CUITouchCtrl.ctor(self)
	self.m_RefObjs = {}
	self.m_DetectDict = {}
	self.m_DragData = {}
	self.m_CurDragObject = nil
end

function CUITouchCtrl.Clear(self)
	self.m_RefObjs = {}
	self.m_DetectDict = {}
end

function CUITouchCtrl.AutoCheckDrag(self)
	if not self.m_DragValidTimer then
		self.m_DragValidTimer = Utils.AddTimer(callback(self, "CheckAllDragObject"), 0.1, 0)
	end
end

function CUITouchCtrl.InitCtrl(self)
	local gameEventHandler = C_api.GameEventHandler.Instance
	gameEventHandler:SetClickCallback(callback(self, "ScreenClick"))
end

function CUITouchCtrl.ScreenClick(self, gameObject)
	if next(self.m_DetectDict) then
		local worldPos = g_CameraCtrl:GetNGUICamera().lastWorldPosition
		for id, cb in pairs(self.m_DetectDict) do
			local obj = self:GetObj(id)
			if obj then
				if not UITools.IsChild(obj.m_Transform, gameObject.transform) then
					cb(gameObject)
				end
			else
				self.m_DetectDict[id] = nil
				self.m_RefObjs[id] = nil
			end
		end
	end

	--组队时，判断是否点击了屏幕
	g_TeamCtrl:SetLeaderTouchUI(true)

	--新手引导战斗3 点击任意UI
	g_GuideCtrl:War3GuideTouchAnyway()

	--新手引导宅邸 任意点击
	g_GuideCtrl:HouseGuideTouchAnyway()	
end

function CUITouchCtrl.NotTouchUI(self)
	for id, cb in pairs(self.m_DetectDict) do
		local obj = self:GetObj(id)
		if obj then
			cb()
		end
	end
end

--必须是根结点
function CUITouchCtrl.TouchOutDetect(self, root, cb)
	local function delay()
		if Utils.IsExist(root) then
			self.m_DetectDict[root:GetInstanceID()] = cb
			self.m_RefObjs[root:GetInstanceID()] = weakref(root)
		end
	end
	Utils.AddTimer(delay, 0, 0)
end

function CUITouchCtrl.GetObj(self, id)
	local obj = getrefobj(self.m_RefObjs[id])
	if not obj then
		self.m_RefObjs[id] = nil
	end
	return obj
end

--拖动
function CUITouchCtrl.CheckAllDragObject(self)
	for id, data in pairs(self.m_DragData) do
		local obj = getrefobj(data.refObj)
		if not self:CheckValidDragObj(obj) then
			if C_api.Utils.IsObjectExist(data.gameObject) then
				data.gameObject:Destroy()
			end
			self.m_DragData[id] = nil
		end
	end
	return true
end

function CUITouchCtrl.CheckValidDragObj(self, oWidget)
	if Utils.IsNil(oWidget) then
		return false
	end
	local data = self.m_DragData[oWidget:GetInstanceID()]
	if data.is_dragging then
		if data.reset_info.parent and C_api.Utils.IsObjectExist(data.reset_info.parent) then
			return true
		else
			return false
		end
	else
		return true
	end
end

function CUITouchCtrl.AddDragObject(self, oWidget, dDragArgs)
	self:AutoCheckDrag()
	oWidget:AddUIEvent("dragstart", callback(self, "OnDragStart"))
	oWidget:AddUIEvent("drag", callback(self, "OnDrag"))
	oWidget:AddUIEvent("dragend", callback(self, "OnDragEnd"))
	local x, y = UITools.GetCenterOffsetPixel(oWidget)
	self.m_DragData[oWidget:GetInstanceID()] = {
		start_delta=dDragArgs.start_delta, -- 必备参数
		start_func = dDragArgs.start_func,
		cb_dragstart = dDragArgs.cb_dragstart,
		cb_dragging = dDragArgs.cb_dragging,
		cb_dragend = dDragArgs.cb_dragend,
		offset = dDragArgs.offset or Vector3.zero,
		drag_obj = dDragArgs.drag_obj,
		is_dragging = false,
		drag_center = true,
		center_offset = Vector3.New(x, y, 0),
		refObj = weakref(oWidget),
		gameObject = oWidget.m_GameObject,
		long_press = dDragArgs.long_press,
		component_dragscrollview = oWidget:GetComponent(classtype.UIDragScrollView),
		reset_info = nil, --还原位置
		dragstart_pos = nil,
		total_delta = Vector3.zero,
	}
	if dDragArgs.long_press then
		oWidget:SetLongPressTime(dDragArgs.long_press)
		oWidget:SetLongPressAnim(true, dDragArgs.start_func)
		oWidget:AddUIEvent("longpress", callback(self, "OnLongPress"))
	end
end

function CUITouchCtrl.OnLongPress(self, oWidget, bPress)
	if not self:CheckValidDragObj(oWidget) then
		self.m_CurDragObject = nil
		return
	end
	if bPress then
		self:StartDragObject(oWidget)
	else
		self:StopDragObejct(oWidget, true)
	end
end

function CUITouchCtrl.GetDragObjectParent(self)
	return CNotifyView:GetView().m_Transform
end

function CUITouchCtrl.OnDragStart(self, oWidget) 
	local data = self.m_DragData[oWidget:GetInstanceID()]
	if data then
		data.total_delta =Vector3.zero
	end
end

function CUITouchCtrl.OnDrag(self, oWidget, delta)
	if not self:CheckValidDragObj(oWidget) then
		self.m_CurDragObject = nil
		return false
	end
	local data = self.m_DragData[oWidget:GetInstanceID()]
	local moveobj = data["drag_obj"] or oWidget

	if data.is_dragging then
		local pos = moveobj:GetLocalPos()
		local adjust = UITools.GetPixelSizeAdjustment()
		pos.x = pos.x + delta.x * adjust
		pos.y = pos.y + delta.y * adjust
		moveobj:SetLocalPos(pos)
		if data.cb_dragging then
			data.cb_dragging(oWidget)
		end
	else
		data.total_delta = data.total_delta + delta
		if self:IsOutDelta("x", data.start_delta, data.total_delta) and
			self:IsOutDelta("y", data.start_delta, data.total_delta) then
			if oWidget.m_GameObject == g_CameraCtrl:GetNGUICamera().selectedObject then
				self:StartDragObject(oWidget)
			end
		end
	end
end

function CUITouchCtrl.IsOutDelta(self, k, startDelta, totalDelta)
	return (startDelta[k] == 0) or (math.abs(totalDelta[k]) >= math.abs(startDelta[k])) and (totalDelta[k] * startDelta[k] > 0)
end


function CUITouchCtrl.OnDragEnd(self, oWidget, bCallCb)
	self:StopDragObejct(oWidget, bCallCb)
end

function CUITouchCtrl.StartDragObject(self, oWidget)
	local data = self.m_DragData[oWidget:GetInstanceID()]
	local startFunc = data.start_func
	if startFunc and not startFunc(oWidget) then
		return
	end
	data.is_dragging = true
	local oWidget = getrefobj(data.refObj)
	local moveobj = data["drag_obj"] or oWidget
	if data.cb_dragstart then
		data.cb_dragstart(oWidget)
	end
	local dReset = {
		parent = moveobj.m_Transform.parent,
		sibling = oWidget:GetSiblingIndex(),
		pos = oWidget:GetLocalPos(),
	}
	data["reset_info"] = dReset
	local p = self:GetDragObjectParent()
	moveobj.m_Transform.parent = p
	local localPos = p:InverseTransformPoint(g_CameraCtrl:GetNGUICamera().lastWorldPosition)
	if data.drag_center then
		localPos = localPos + data.center_offset
	end
	moveobj:SetLocalPos(localPos + data.offset) -- 初始化位置
	
	UITools.MarkParentAsChanged(moveobj.m_GameObject)
	if data.component_dragscrollview then
		data.component_dragscrollview.enabled = false
	end
	self.m_CurDragObject = oWidget
end

function CUITouchCtrl.StopDragObejct(self, oWidget, bCallCb)
	oWidget:StopLongPress()
	if self.m_CurDragObject then
		self.m_CurDragObject = nil
	else
		return false
	end
	if not self:CheckValidDragObj(oWidget) then
		return false
	end
	local data = self.m_DragData[oWidget:GetInstanceID()]
	if data.is_dragging then
		data.is_dragging = false
	else
		return
	end
	local moveobj = data["drag_obj"] or oWidget
	local bNeedReset = true
	bCallCb = bCallCb == false and false or true
	if bCallCb and data.cb_dragend then
		bNeedReset = not data.cb_dragend(moveobj) --dragend有做处理则不还原
	end
	
	if bNeedReset and data.reset_info then
		moveobj.m_Transform.parent = data.reset_info.parent
		oWidget:SetSiblingIndex(data.reset_info.sibling)
		oWidget:SetLocalPos(data.reset_info.pos)
		UITools.MarkParentAsChanged(moveobj.m_GameObject)
		if data.component_dragscrollview then
			data.component_dragscrollview.enabled = true
		end
	end
end

function CUITouchCtrl.DelDragObject(self, oWidget)
	local data = self.m_DragData[oWidget:GetInstanceID()]
	if data then
		if data.is_dragging then
			self:StopDragObejct(oWidget, false)
		end
		if data.long_press then
			oWidget:SetLongPressTime(0.36)
			oWidget:AddUIEvent("longpress", nil)
			oWidget:StopLongPress()
		end
		self.m_DragData[oWidget:GetInstanceID()] = nil
		oWidget:AddUIEvent("drag", nil)
		oWidget:AddUIEvent("dragend", nil)
	end
end

function CUITouchCtrl.FroceEndDrag(self, bDestroy)
	if bDestroy and self.m_CurDragObject then
		self:DelDragObject(self.m_CurDragObject)
		self.m_CurDragObject = nil
	elseif self.m_CurDragObject then
		self:OnDragEnd(self.m_CurDragObject, false)
		self.m_CurDragObject = nil
	else
		g_NotifyCtrl:HideLongPressAni()
	end
end

return CUITouchCtrl