TypeSelectPanel = BaseClass(LuaUI)

function TypeSelectPanel:__init( ... )
	self.ui = UIPackage.CreateObject("ChatNew","TypeSelectPanel");
	
	self.state = self.ui:GetController("state")
	self.com = self.ui:GetChild("com")

	self.state.selectedIndex = 0
	self:SetTouchable(false)
	self:SetVisible(false)
	self.com = TypeSelectCom.Create(self.com)
end

function TypeSelectPanel:InitEvent()
	--[[ 这里注册各种一次性创建事件
	self.closeCallback = function () end
	self.openCallback  = function () end
	--]]
end

function TypeSelectPanel:ToShow()
	self:SetVisible(true)
	self:SetTouchable(true)
	self.state.selectedIndex = 1
end

-- 布局UI
function TypeSelectPanel:Layout()
	self.container:AddChild(self.ui) -- 不改动，注意自行设置self.ui位置
	-- 以下开始UI布局
end

-- Dispose use TypeSelectPanel obj:Destroy()
function TypeSelectPanel:__delete()
	if self.com then
		self.com:Destroy()
	end
	self.com = nil
end