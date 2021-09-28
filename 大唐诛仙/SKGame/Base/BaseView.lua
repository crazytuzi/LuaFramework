-- GlobalDispatcher:AddEventListener(EventName.OPENVIEW, openHandler [view->id]) -- 控制模块层监听这个事件，以实现事件指定打开功能面板参数{...}

-- UI显示基类(parent根级默认载入UI层级) 【类似弹出显示】
BaseView = BaseClass()

BaseView.AutoZOrder = 100000
BaseView.AutoId = 1

BaseView.CacheMax = 20
BaseView.Caches = {}
BaseView.CurView = nil

BaseView.OpenOnOtherCloseList = {} -- 队列打开上一个视图

-- 以下初始属性在子类重置后会起效，对于 _ 开头的 内置接口变量不要动
function BaseView:__init()
	self:__AutoId()
	self.ui = nil
	self.isCenter = true -- 居中打开
	self.__isOpen = false


	self.isInited = true
	self.parent = layerMgr:GetUILayer() -- 设置层级容器（一般是layerMgr的 UI， 可以其他，如Top， MSG, Loader 层级等等）

	self.closeCallback = nil -- 回调操作
	self.openCallback = nil

	self.useFade = false -- 开启打开淡化效果
	self.__isOpening = false -- 正在淡化过程中
	self.__isClosing = false -- 正在淡化过程中
	self.destroy = true -- 关闭是否销毁
	self._alpha = 1 -- 开启淡化后的中间变量
	self.__autoClose = false -- 多个打开时，自动关闭

	self.useCache = true -- 缓存窗口
	self.isOnOtherClose = true -- 排拆之前已经打开的窗口，把之前弹出的关掉，放到一个列表中

	self.openSound = "731003" -- 打开时的音效
	self.closeSound = "731002" -- 关闭时的音效
end

function BaseView:Open()
	if self.ui == nil or self.__isOpen then return end
	if self.isCenter then self:_SetCenter() end
	local p = self:GetParent()
	if p then 
		p:AddChild(self.ui)
	end
	local preOpen = BaseView.CurView
	if preOpen ~= self then
		if preOpen then
			if preOpen:IsOpen() then
				if self.isOnOtherClose then
					preOpen.__autoClose = true
					preOpen:Close()
					table.insert(BaseView.OpenOnOtherCloseList, preOpen) -- 存起上一个
				end
			end
		end
		BaseView.CurView = self
		if self.useCache then
			BaseView.CacheView()
		end
	end

	self.__isOpen = true
	self.__isClosing = false
	self:SetVisible(self.__isOpen)
	self:__TopMe()

	if self.useFade then -- 淡入
		self.__isOpening = true
		self._alpha = 0
		self.ui.alpha = self._alpha
		local tweener = self.ui:TweenFade(1, 0.5)
		TweenUtils.OnComplete(tweener, function ( obj )
			obj.__isOpening = false
		end, self)
	else
		self.ui.alpha = 1
		self.__isOpening = false
	end
	local mainUI = MainUIController:GetInstance()
	if mainUI:IsHasMainCityUI() == true then
		mainUI:CloseMainCityUI()
	end

	if self.openCallback ~= nil then
		if not pcall(function ()
			if not self.isInited then return end
			self:openCallback()
		end) then
		 	debugFollow()
		end
	end
	EffectMgr.PlaySound(self.openSound)
end

function BaseView:Close()
	if not self.isInited then return end
	if not self.__isOpen then return end
	self.__isOpen = false
	self.__isOpening = false
	if not self.__autoClose then
		BaseView.OpenPreView()
	end
	
	if self.useFade and not self.__autoClose then -- 淡出
		self.__isClosing = true
		self._alpha = 1
		self.ui.alpha = self._alpha
		local tweener = self.ui:TweenFade(0, 0.3)
		if self.closeCallback then
			if not pcall(function ()
				self:closeCallback()
			end) then
				print(self.id, "关闭回调有错!")
			 	debugFollow()
			end
		end
		TweenUtils.OnComplete(tweener, function ( obj )
			if not obj.ui then return end
			obj.__isClosing = false
			self:SetVisible( self.__isOpen )
			if self.destroy then
				self:Destroy()
			end
		end, self)
	else
		self:SetVisible( self.__isOpen )
		self.__isClosing = false
		if self.destroy then
			if self.closeCallback then
				if not pcall(function ()
					self:closeCallback()
				end) then
					print(self.id, "关闭回调有错!")
				 	debugFollow()
				end
			end
			self:Destroy()
		end
	end
	
	self.__autoClose = false -- 重置
	if not self:IsHasOpen() then
		local mainUI = MainUIController:GetInstance()
		if mainUI:IsHasMainCityUI() then
			if not LoginModel:GetInstance():GetRoleSelectPanelOpenFlag() then
				mainUI:OpenMainCityUI()
			end
		end
	end

	EffectMgr.PlaySound(self.closeSound)
end

function BaseView:IsHasOpen()
	return BaseView.CurView and BaseView.CurView:IsOpen()
end

function BaseView:__delete()
	if self.ui then
		destroyUI(self.ui)
	end
	self.ui = nil
	self.isCenter = false
	self.visible = false
	self.isInited = false
	self.__isOpen = false
	self.parent = nil
	self.id = nil
	self.openCallback = nil
	self.closeCallback = nil
	self.isOnOtherClose = false
	self.__isOpening = false
	self.__isClosing = false
	self.__autoClose = false
end

-- 关闭所有弹窗
function BaseView.CloseAll()
	BaseView.OpenOnOtherCloseList = {}
	if BaseView.CurView == nil then return end
	BaseView.CurView:Close()
	for _, v in ipairs(BaseView.Caches) do
	 	if v.isInited then
	 		v:Close()
	 	end
	end
	local mainUI = MainUIController:GetInstance()
	if mainUI:IsHasMainCityUI() then
		if not LoginModel:GetInstance():GetRoleSelectPanelOpenFlag() then
			mainUI:OpenMainCityUI()
		end
	end
end
-- 缓存
function BaseView.CacheView()
	if BaseView.Caches[#BaseView.Caches] == BaseView.CurView then return end
	for i,v in ipairs(BaseView.Caches) do
		if v == BaseView.CurView then
			table.remove(BaseView.Caches, i)
			break
		end
	end
	for i=#BaseView.Caches,1,-1 do
		if i > BaseView.CacheMax then
			local view = table.remove(BaseView.Caches, 1)
			view:Destroy()
		else
			break
		end
	end
	table.insert(BaseView.Caches, BaseView.CurView)
end
-- 打开上一个视图
function BaseView.OpenPreView()
	for i,v in ipairs(BaseView.OpenOnOtherCloseList) do
		if v == BaseView.CurView then
			table.remove(BaseView.OpenOnOtherCloseList, i)
			break
		end
	end
	if #BaseView.OpenOnOtherCloseList ~= 0 then
		local view = table.remove(BaseView.OpenOnOtherCloseList, #BaseView.OpenOnOtherCloseList)
		if view and not view.isInited then -- 发面有中间销毁，全清掉
			view.isOnOtherClose = true
			BaseView.OpenOnOtherCloseList = {}
			return
		end

		view.isOnOtherClose = false
		
		if view.id ~= "ChatNewPanel" then
			view:Open()
		end
		view.isOnOtherClose = true
	end
end

-- 居中
function BaseView:_SetCenter()
	self.ui.x = (layerMgr.WIDTH - self.ui.width)*0.5
	self.ui.y = (layerMgr.HEIGHT - self.ui.height)*0.5
end
-- 置顶
function BaseView:__TopMe()
	BaseView.AutoZOrder = BaseView.AutoZOrder + 1
	if not ToLuaIsNull(self.ui) then
		self.ui.sortingOrder = BaseView.AutoZOrder
	end
end
-- 自动id
function BaseView:__AutoId()
	BaseView.AutoId = BaseView.AutoId + 1
	self.id = BaseView.AutoId
end
-- 是否打开
function BaseView:IsOpen()
	return self.isInited and self.__isOpen and self.ui and self.ui.visible
end
-- 在其他特殊界面全局__init中可能要更改容器时用到
function BaseView:SetParent(parent)
	if parent == nil then print("parent is nil") return end
	self.parent = parent
end
function BaseView:GetParent()
	return self.parent
end

function BaseView:SetVisible( visible )
	if self.ui ~= nil then
		self.ui.visible = visible
	end
end

function BaseView:GetVisible()
	if self.ui == nil then
		return false
	else
		return self.ui.visible
	end
end

function BaseView:GetUIId()
	return self.ui.id
end

function BaseView:GetUIName()
	return self.ui.name
end

function BaseView:GetUIParent()
	return self.ui.parent
end

function BaseView:GetData()
	return self.ui.data
end

function BaseView:GetXY()
	return self.ui.xy
end

function BaseView:GetPosition()
	return self.ui.position
end

function BaseView:GetX()
	return self.ui.x
end

function BaseView:GetY()
	return self.ui.y
end

function BaseView:GetZ()
	return self.ui.z
end

function BaseView:GetSourceHeight()
	return self.ui.sourceHeight
end

function BaseView:GetSourceWidth()
	return self.ui.sourceWidth
end

function BaseView:GetW()
	return self.ui.width
end

function BaseView:GetH()
	return self.ui.height
end


function BaseView:SetData(v)
	self.ui.data = v
end

function BaseView:SetTouchable(v)
	self.ui.touchable = v
end

function BaseView:SetGrayed(v)
	self.ui.grayed = v
end

function BaseView:SetEnabled(v)
	self.ui.enabled = v
end

function BaseView:SetRotation(v)
	self.ui.rotation = v
end

function BaseView:SetRotationX(v)
	self.ui.rotationX = v
end

function BaseView:SetRotationY(v)
	self.ui.rotationY = v
end

function BaseView:SetAlpha(v)
	self.ui.alpha = v
end

function BaseView:SetDraggable(v)
	self.ui.draggable = v
end


function BaseView:SetXY(x, y)
	self.ui:SetXY(x or 0, y or 0)
end

function BaseView:SetPosition(x, y, z)
	self.ui:SetPosition(x, y, z)
end

function BaseView:SetSize(w, h, ignorePivot)
	self.ui:SetSize(w, h, ignorePivot == true)
end

function BaseView:SetPivot(x, y, asAnchor)
	self.ui:SetPivot(x, y, asAnchor)
end

function BaseView:SetScale(x, y)
	self.ui:SetScale(x, y)
end

function BaseView:StartDrag()
	self.ui:StartDrag()
end

function BaseView:StopDrag()
	self.ui:StopDrag()
end

function BaseView:GetChildAt( idx )
	return self.ui:GetChildAt(idx)
end
function BaseView:GetChild( name )
	return self.ui:GetChild(name)
end
function BaseView:GetControllerAt( idx )
	return self.ui:GetControllerAt( idx )
end
function BaseView:GetController( name )
	return self.ui:GetController( name )
end

function BaseView:GetTransitionAt( idx )
	return self.ui:GetTransitionAt( idx )
end
function BaseView:GetTransition( name )
	return self.ui:GetTransition( name )
end