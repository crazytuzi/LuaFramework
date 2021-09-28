-- local btn = LuaUI.New(10,300) -- 新建ui
-- -- layerMgr:GetUILayer():AddChild(btn.ui)
-- btn:AddTo(layerMgr:GetUILayer())
-- local btn2 = LuaUI.Create( btn.ui, 29, 56 ) -- 组合现有UI
-- btn2:Destroy() --注意销毁
-- lua 公共的UI基类
LuaUI =BaseClass()

LuaUI.AutoZOrder = 1
-- 获得的UI最高层级 （用于置顶）
function LuaUI.GetTopOrder()
	LuaUI.AutoZOrder = LuaUI.AutoZOrder + 1
end
function LuaUI:__property(...)
	local args = {...}
	if args[2] == "#" then
		if args[1] and self.URL == args[1].resourceURL then
			self.ui = args[1]
			if next(args[3]) then
				self:SetProperty(unpack(args[3]))
			end
		else
			print("重构UI有误：", self.URL , args[1].resourceURL)
			error("create ui error!")
			return
		end
	else
		self:SetProperty(...)
	end
	self:RegistUI(self.ui)
end

-- 销毁
function LuaUI:__delete()
	if self.ui then
		destroyUI(self.ui)
	end
	self.ui = nil
end

-- 添加到指定ui容器
function LuaUI:AddTo(parent, x, y, w, h, ignorePivot)
	self.ui:RemoveFromParent()
	if x and y then
		self.ui:SetXY(x, y)
	end
	if w and h then
		self.ui:SetSize(w, h, ignorePivot==true)
	end
	return parent:AddChild(self.ui)
end
function LuaUI:AddChild( ui )
	if self.ui then
		self.ui:AddChild(ui)
	end
end
function LuaUI:RemoveChild( ui )
	if self.ui then
		self.ui:RemoveChild(ui)
	end
end
---------------------------------------

function LuaUI:GetUIId()
	return self.ui.id
end

function LuaUI:GetUIName()
	return self.ui.name
end

function LuaUI:GetUIParent()
	return self.ui.parent
end

function LuaUI:GetData()
	return self.ui.data
end

function LuaUI:GetXY()
	return self.ui.xy
end

function LuaUI:GetPosition()
	return self.ui.position
end

function LuaUI:GetX()
	return self.ui.x or 0
end

function LuaUI:GetY()
	return self.ui.y or 0
end

function LuaUI:GetZ()
	return self.ui.z or 0
end

function LuaUI:GetSourceHeight()
	return self.ui.sourceHeight
end

function LuaUI:GetSourceWidth()
	return self.ui.sourceWidth
end

function LuaUI:GetW()
	return self.ui.width
end

function LuaUI:GetH()
	return self.ui.height
end


function LuaUI:SetData(v)
	self.ui.data = v
end

function LuaUI:SetTouchable(v)
	self.ui.touchable = v
end

function LuaUI:SetGrayed(v)
	self.ui.grayed = v
end

function LuaUI:SetEnabled(v)
	self.ui.enabled = v
end

function LuaUI:SetRotation(v)
	self.ui.rotation = v
end

function LuaUI:SetRotationX(v)
	self.ui.rotationX = v
end

function LuaUI:SetRotationY(v)
	self.ui.rotationY = v
end

function LuaUI:SetAlpha(v)
	self.ui.alpha = v
end

function LuaUI:SetVisible(v)
	self.ui.visible = v
end

function LuaUI:SetDraggable(v)
	self.ui.draggable = v
end


function LuaUI:SetXY(x, y)
	self.ui:SetXY(x or 0, y or 0)
end

function LuaUI:SetCenter()
	self.ui.x = (layerMgr.WIDTH - self.ui.width)/2
	self.ui.y = (layerMgr.HEIGHT - self.ui.height)/2
end

function LuaUI:SetPosition(x, y, z)
	self.ui:SetPosition(x, y, z)
end

function LuaUI:SetSize(w, h, ignorePivot)
	self.ui:SetSize(w, h, ignorePivot)
end

function LuaUI:SetPivot(x, y, asAnchor)
	self.ui:SetPivot(x, y, asAnchor)
end

function LuaUI:SetScale(x, y)
	self.ui:SetScale(x, y)
end

function LuaUI:RemoveFromParent()
	self.ui:RemoveFromParent()
end

function LuaUI:StartDrag()
	self.ui:StartDrag()
end

function LuaUI:StopDrag()
	self.ui:StopDrag()
end

function LuaUI:GetChildAt( idx )
	return self.ui:GetChildAt(idx)
end
function LuaUI:GetChild( name )
	return self.ui:GetChild(name)
end
function LuaUI:GetControllerAt( idx )
	return self.ui:GetControllerAt( idx )
end
function LuaUI:GetController( name )
	return self.ui:GetController( name )
end

function LuaUI:GetTransitionAt( idx )
	return self.ui:GetTransitionAt( idx )
end
function LuaUI:GetTransition( name )
	return self.ui:GetTransition( name )
end
function LuaUI:SetZorder( v )
	if not ToLuaIsNull(self.ui) then
		self.ui.sortingOrder = math.floor(v)
	end
end



