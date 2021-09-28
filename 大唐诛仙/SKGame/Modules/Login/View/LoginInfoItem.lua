LoginInfoItem = BaseClass(LuaUI)

function LoginInfoItem:__init(...)
	self.URL = "ui://0qk3a0fjj2mzh";
	self:__property(...)
	self:Config()
end

function LoginInfoItem:SetProperty(...)
	
end

function LoginInfoItem:Config()
	
end

function LoginInfoItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Login","LoginInfoItem")
	self.bgBorder = self.ui:GetChild("bgBorder")
	self.loader = self.ui:GetChild("loader")
	self.labelContent = self.ui:GetChild("labelContent")
end

function LoginInfoItem.Create(ui, ...)
	return LoginInfoItem.New(ui, "#", {...})
end

function LoginInfoItem:__delete()
end

function LoginInfoItem:SetIcon(url)
	self.loader.url = url or ""
end

function LoginInfoItem:SetContentUI(strContent)
	self.labelContent.text = strContent or ""
end

function LoginInfoItem:DisplayAsPassword()
	self.labelContent.asTextInput.displayAsPassword = true
end

function LoginInfoItem:SetEditable(bl)
	if bl ~= nil then self.labelContent.editable = bl end
end


-- Default = 0
-- ASCIICapable = 1
-- NumbersAndPunctuation = 2
-- URL = 3
-- NumberPad = 4
-- PhonePad = 5
-- NamePhonePad = 6
-- EmailAddress = 7
-- NintendoNetworkAccount = 8
function LoginInfoItem:SetKeyBoardType(keyBoardType)
	self.labelContent.asTextInput.keyboardType = keyBoardType
end

function LoginInfoItem:SetInputTips(str)
	self.labelContent.promptText = str or ""
end

function LoginInfoItem:GetContent()
	local formatStr , replaceCnt = string.gsub(self.labelContent.text , " " , "")
	return formatStr , replaceCnt	
end