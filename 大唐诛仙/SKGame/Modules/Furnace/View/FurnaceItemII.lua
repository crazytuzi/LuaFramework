FurnaceItemII = BaseClass(LuaUI)
function FurnaceItemII:__init( ... )
	self.URL = "ui://wt6b3levu156o"
	self:__property(...)
	self:Config()
end
function FurnaceItemII:SetProperty( ... )
end
function FurnaceItemII:Config()
	
end
function FurnaceItemII:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Furnace","FurnaceItemII");

	self.bg = self.ui:GetChild("bg")
	self.starConn = self.ui:GetChild("starConn")
	self.icon_active = self.ui:GetChild("icon_active")
	self.stars = {}
	self.curNum = 0
end
-- 选择回调
function FurnaceItemII:SetSelectCallback( cb )
	self.ui.onClick:Add(function ()
		cb(self.data)
	end)
end
-- 设置星数
function FurnaceItemII:SetStarNum( num )
	if num and self.curNum >= num then return end
	local num = num - self.curNum
	for i=self.curNum+1,self.curNum+num do
		local star = StarComp.New()
		star:AddTo(self.starConn, 33*(i-1), 0)
		star:SetScale(0.8, 0.8)
		self.stars[i] = star
		star:Active( true )
	end
	self.curNum = num
end
-- 设置激活状态
function FurnaceItemII:SetActive( b )
	if b then
		self.icon_active.url = "Icon/Vip/jihuo"
	else
		self.icon_active.url = ""
	end
end

function FurnaceItemII:SetData( v )
	self.data = v
end
function FurnaceItemII.Create( ui, ...)
	return FurnaceItemII.New(ui, "#", {...})
end
function FurnaceItemII:__delete()
	self.ui.onClick:Clear()
	if self.cell then
		self.cell:Destroy()
	end
	self.cell = nil
end