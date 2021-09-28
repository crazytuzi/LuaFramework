-- 弹窗显示基类(parent根级默认载入MSG层级) 【类似弹出显示】
LuaMsgWin =BaseClass()
LuaMsgWin.AutoZOrder = 20000

function LuaMsgWin:__init(...)
	self.ui = nil
	self.isOpen = false
	self.isInited = false
	self.parent = layerMgr:GetMSGLayer()

	self.closeCallback = nil
	self.openCallback = nil
end

function LuaMsgWin:RegistUI(ui, parent)
	self.ui = ui
	self:SetParent(parent)
	self.isInited = true
end

function LuaMsgWin:SetParent(parent)
	if parent == nil then print("parent is nil") return end
	self.parent = parent
end

function LuaMsgWin:Open()
	if self.ui == nil then return end
	if self.isOpen then -- 提升
		self:__TopMe()
		return
	end
	if self:GetParent() and self.ui.parent == nil then 
		self:GetParent():AddChild(self.ui)
	end
	self.isOpen = true
	self:__TopMe()
	if self.openCallback ~= nil then
		pcall(self.openCallback, self)
	end
end

function LuaMsgWin:__TopMe()
	LuaMsgWin.AutoZOrder = LuaMsgWin.AutoZOrder + 1
	if not ToLuaIsNull(self.ui) then
		self.ui.sortingOrder = LuaMsgWin.AutoZOrder
	end
	self:SetVisible( self.isOpen )
end

function LuaMsgWin:Close(useRemove)
	if self.ui == nil then return end
	if self.isOpen and self.closeCallback ~= nil then
		pcall(self.closeCallback, self)
	end

	self.isOpen = false
	if not useRemove then
		self:SetVisible( self.isOpen )
	else
		self:RemoveFromParent()
	end
end

function LuaMsgWin:IsOpen()
	if not self.isInited then return false end
	return self.isOpen
end

function LuaMsgWin:GetParent()
	return self.parent
end

function LuaMsgWin:RemoveFromParent()
	if self.ui and self.ui.parent then
		self.ui:RemoveFromParent()
	end
end

function LuaMsgWin:SetVisible( visible )
	if self.ui ~= nil then
		self.ui.visible = visible
	end
end

function LuaMsgWin:GetVisible()
	if self.ui == nil then
		return false
	else
		return self.ui.visible
	end
end

function LuaMsgWin:__delete()
	if self.ui then
		destroyUI(self.ui)
	end
	self.ui = nil
	self.isInited = false
	self.isOpen = false
	self.parent = nil
	self.id = nil
	self.ui = nil
	self.openCallback = nil
	self.closeCallback = nil
end
---------------------------------------

function LuaMsgWin:GetUIId()
	return self.ui.id
end

function LuaMsgWin:GetUIName()
	return self.ui.name
end

function LuaMsgWin:GetUIParent()
	return self.ui.parent
end

function LuaMsgWin:GetData()
	return self.ui.data
end

function LuaMsgWin:GetXY()
	return self.ui.xy
end

function LuaMsgWin:GetPosition()
	return self.ui.position
end

function LuaMsgWin:GetX()
	return self.ui.x
end

function LuaMsgWin:GetY()
	return self.ui.y
end

function LuaMsgWin:GetZ()
	return self.ui.z
end

function LuaMsgWin:GetSourceHeight()
	return self.ui.sourceHeight
end

function LuaMsgWin:GetSourceWidth()
	return self.ui.sourceWidth
end

function LuaMsgWin:GetW()
	return self.ui.width
end

function LuaMsgWin:GetH()
	return self.ui.height
end


function LuaMsgWin:SetData(v)
	self.ui.data = v
end

function LuaMsgWin:SetTouchable(v)
	self.ui.touchable = v
end

function LuaMsgWin:SetGrayed(v)
	self.ui.grayed = v
end

function LuaMsgWin:SetEnabled(v)
	self.ui.enabled = v
end

function LuaMsgWin:SetRotation(v)
	self.ui.rotation = v
end

function LuaMsgWin:SetRotationX(v)
	self.ui.rotationX = v
end

function LuaMsgWin:SetRotationY(v)
	self.ui.rotationY = v
end

function LuaMsgWin:SetAlpha(v)
	self.ui.alpha = v
end

function LuaMsgWin:SetDraggable(v)
	self.ui.draggable = v
end


function LuaMsgWin:SetXY(x, y)
	self.ui:SetXY(x, y)
end

function LuaMsgWin:SetPosition(x, y, z)
	self.ui:SetPosition(x, y, z)
end

function LuaMsgWin:SetSize(w, h, ignorePivot)
	self.ui:SetSize(w, h, ignorePivot)
end

function LuaMsgWin:SetPivot(x, y, asAnchor)
	self.ui:SetPivot(x, y, asAnchor)
end

function LuaMsgWin:SetScale(x, y)
	self.ui:SetScale(x, y)
end

function LuaMsgWin:StartDrag()
	self.ui:StartDrag()
end

function LuaMsgWin:StopDrag()
	self.ui:StopDrag()
end

function LuaMsgWin:GetChildAt( idx )
	return self.ui:GetChildAt(idx)
end
function LuaMsgWin:GetChild( name )
	return self.ui:GetChild(name)
end
function LuaMsgWin:GetControllerAt( idx )
	return self.ui:GetControllerAt( idx )
end
function LuaMsgWin:GetController( name )
	return self.ui:GetController( name )
end

function LuaMsgWin:GetTransitionAt( idx )
	return self.ui:GetTransitionAt( idx )
end
function LuaMsgWin:GetTransition( name )
	return self.ui:GetTransition( name )
end

function LuaMsgWin:SetCenter()
	self.ui.x = (layerMgr.WIDTH - self.ui.width)*0.5
	self.ui.y = (layerMgr.HEIGHT - self.ui.height)*0.5
end