ReBindStepOne = BaseClass(LuaUI)

function ReBindStepOne:__init( ... )
	self.URL = "ui://wn6osdzss1mjn";
	self:__property(...)
	self:Config()
end

-- Set self property
function ReBindStepOne:SetProperty( ... )
end

-- start
function ReBindStepOne:Config()
	
end

-- wrap UI to lua
function ReBindStepOne:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Account","ReBindStepOne");

	self.deBindBtn = self.ui:GetChild("deBindBtn")
	self.numberInput = self.ui:GetChild("numberInput")
	self.closeBtn = self.ui:GetChild("closeBtn")

	self.numberInputTxt = self.numberInput:GetChild("input")
	
	self.numberInputTxt.promptText = "请输入手机号码"

	self:AddEvent()
end

function ReBindStepOne:AddEvent()
	self.deBindBtn.onClick:Add(function()
		if self.numberInputTxt.text == "" then
			Message:GetInstance():TipsMsg("手机号码不能为空")
			return
		end
		if not CheckIsMobilePhoneNum(self.numberInputTxt.text) then
			Message:GetInstance():TipsMsg("请输入正确的手机号码")
			return
		end
		if AccountModel:GetInstance().bindTelePhone == self.numberInputTxt.text then
			local reBindStepTow = ReBindStepTow.New()
			UIMgr.ShowCenterPopup(reBindStepTow)
		else
			Message:GetInstance():TipsMsg("手机号码不匹配")
		end
	end, self)

	self.closeBtn.onClick:Add(function()
		UIMgr.HidePopup()
	end, self)
end

function ReBindStepOne:RemoveEvent()
end

-- Combining existing UI generates a class
function ReBindStepOne.Create( ui, ...)
	return ReBindStepOne.New(ui, "#", {...})
end

function ReBindStepOne:__delete()
	self:RemoveEvent()
end