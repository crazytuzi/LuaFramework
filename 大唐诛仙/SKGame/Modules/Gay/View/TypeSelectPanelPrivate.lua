TypeSelectPanelPrivate = BaseClass(LuaUI)

function TypeSelectPanelPrivate:__init( ... )
	self.ui = UIPackage.CreateObject("Gay","TypeSelectPanelPrivate");
	
	self.state = self.ui:GetController("state")
	self.com = self.ui:GetChild("com")

	self.state.selectedIndex = 0
	self:SetTouchable(false)
	self:SetVisible(false)
	self.com = TypeSelectComPrivate.Create(self.com)
end

function TypeSelectPanelPrivate:InitEvent()
	--[[ 这里注册各种一次性创建事件
	self.closeCallback = function () end
	self.openCallback  = function () end
	--]]
end

function TypeSelectPanelPrivate:ToShow()
	self:SetVisible(true)
	self:SetTouchable(true)
	self.state.selectedIndex = 1
end

-- 布局UI
function TypeSelectPanelPrivate:Layout()
	self.container:AddChild(self.ui) -- 不改动，注意自行设置self.ui位置
	-- 以下开始UI布局
end

-- Dispose use TypeSelectPanelPrivate obj:Destroy()
function TypeSelectPanelPrivate:__delete()
	destroyUI(self.com.ui)
end