ReBindStepTow = BaseClass(LuaUI)

function ReBindStepTow:__init( ... )
	self.URL = "ui://wn6osdzss1mjr";
	self:__property(...)
	self:Config()
end

-- Set self property
function ReBindStepTow:SetProperty( ... )
end

-- start
function ReBindStepTow:Config()
	
end

-- wrap UI to lua
function ReBindStepTow:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Account","ReBindStepTow");

	self.getCheckBtn = self.ui:GetChild("getCheckBtn")
	self.numberInput = self.ui:GetChild("numberInput")
	self.closeBtn = self.ui:GetChild("closeBtn")
	self.checkInput = self.ui:GetChild("checkInput")
	self.comfirmBtn = self.ui:GetChild("comfirmBtn")

	self.numberInputTxt = self.numberInput:GetChild("input")
	self.checkInputTxt = self.checkInput:GetChild("input")

	self.numberInputTxt.promptText = "请输入手机号码"
	self.checkInputTxt.promptText = "请输入验证码"

	self:AddEvent()
end

function ReBindStepTow:AddEvent()
	self.getCheckBtn.onClick:Add(function()
		if self.numberInputTxt.text == "" then
			Message:GetInstance():TipsMsg("手机号码不能为空")
			return
		end
		if not CheckIsMobilePhoneNum(self.numberInputTxt.text) then
			Message:GetInstance():TipsMsg("请输入正确的手机号码")
			return
		end
		AccountController:GetInstance():C_GetValidateCode(self.numberInputTxt.text)
		AccountPanel.CountDown(self.getCheckBtn, "获取验证码")
	end, self)
	
	self.comfirmBtn.onClick:Add(function()
		if self.numberInputTxt.text == "" then
			Message:GetInstance():TipsMsg("手机号码不能为空")
			return
		end
		if not CheckIsMobilePhoneNum(self.numberInputTxt.text) then
			Message:GetInstance():TipsMsg("请输入正确的手机号码")
			return
		end
		if self.checkInputTxt.text == "" then
			Message:GetInstance():TipsMsg("请输入验证码")
			return
		end
		AccountController:GetInstance():C_BindPhone(self.numberInputTxt.text, AccountModel:GetInstance().bizId, self.checkInputTxt.text)
		UIMgr.HidePopup()
	end, self)

	self.closeBtn.onClick:Add(function()
		UIMgr.HidePopup()
	end, self)
end

function ReBindStepTow:RemoveEvent()
end

-- Combining existing UI generates a class
function ReBindStepTow.Create( ui, ...)
	return ReBindStepTow.New(ui, "#", {...})
end

function ReBindStepTow:__delete()
	self:RemoveEvent()
	AccountPanel.StopCountDownInFrame()
end