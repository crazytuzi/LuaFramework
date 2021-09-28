ServerTabItem = BaseClass(LuaUI)

function ServerTabItem:__init(...)
	self.URL = "ui://csn9w87sc0uhb";
	self:__property(...)
	self:Config()
end

function ServerTabItem:SetProperty(...)
	
end

function ServerTabItem:Config()
	
end

function ServerTabItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("ServerSelect","ServerTabItem");

	self.button = self.ui:GetController("button")
	self.bg = self.ui:GetChild("bg")
	self.bgSelected = self.ui:GetChild("bgSelected")
	self.title = self.ui:GetChild("title")
end

function ServerTabItem.Create(ui, ...)
	return ServerTabItem.New(ui, "#", {...})
end

function ServerTabItem:__delete()
end

function ServerTabItem:InitData()
	self.data = -1
end

function ServerTabItem:SetData(data)
	self.data = data or -1
end

function ServerTabItem:SetUI()
	if self.data == -1 then return end

	local strTabDesc = ""
	if self.data == 1 then
		strTabDesc = "我的服务器"
	elseif self.data == 2 then
		strTabDesc = "推荐服"
	else
		local firstNum = (self.data - 2) * ServerSelectConst.ServerGroupItemCnt - (ServerSelectConst.ServerGroupItemCnt - 1)
		local secondNum = (self.data - 2) * ServerSelectConst.ServerGroupItemCnt
		strTabDesc = StringFormat("{0}{1}{2}{3}" , tostring(firstNum) , "-" , tostring(secondNum) , "服")
	end
	self.title.text = strTabDesc
end