AccountPanel = BaseClass(LuaUI)

function AccountPanel:__init( ... )
	self.URL = "ui://wn6osdzsdmzw2";
	self:__property(...)
	self:Config()
end

-- Set self property
function AccountPanel:SetProperty( ... )
end

-- start
function AccountPanel:Config()
	
end

-- wrap UI to lua
function AccountPanel:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Account","AccountPanel");

	self.state = self.ui:GetController("state")
	self.bindBtn = self.ui:GetChild("bindBtn")
	self.numberInput = self.ui:GetChild("numberInput")
	self.checkInputTxt = self.ui:GetChild("checkInput")
	self.getCheckBtn = self.ui:GetChild("getCheckBtn")
	self.bindOperateGroup = self.ui:GetChild("bindOperateGroup")
	self.changBtn = self.ui:GetChild("changBtn")
	self.bindInfo = self.ui:GetChild("bindInfo")
	self.bindInfoGroup = self.ui:GetChild("bindInfoGroup")
	self.bandState = self.ui:GetController("bandState")

	self.numberInputTxt = self.numberInput:GetChild("input")
	self.checkInputTxt = self.checkInputTxt:GetChild("input")
	
	self.ui.visible = false
	self:GetReward()

	self.numberInputTxt.promptText = "请输入手机号码"
	self.checkInputTxt.promptText = "请输入验证码"

	self.reBandOperate = false
	self.bindState = 0 --0:确定绑定 1:领取奖励 2:已领取
	self:AddEvent()
end

-- Combining existing UI generates a class
function AccountPanel.Create( ui, ...)
	return AccountPanel.New(ui, "#", {...})
end

function AccountPanel:AddEvent()
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
		
	end, self)

	self.bindBtn.onClick:Add(function()
		if self.bindState == 0 then --请求绑定
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
		elseif self.bindState == 1 then --领取奖励
			AccountController:GetInstance():C_GetBindReward()
		elseif self.bindState == 2 then --已领取
			Message:GetInstance():TipsMsg("奖励已领取")
		end
	end, self)

	self.changBtn.onClick:Add(function()
		self.reBandOperate = true
		local reBindStepOne = ReBindStepOne.New()
		UIMgr.ShowCenterPopup(reBindStepOne, function()
			self.reBandOperate = false
		end)
	end, self)

	self.updateHandler = AccountModel:GetInstance():AddEventListener(AccountConst.Update, function (data) self:Update(data) end)
	self.startCountDownHandler = AccountModel:GetInstance():AddEventListener(AccountConst.StartCountDown , function(data) 
		if data ~= 0 then
			AccountPanel.CountDown(self.getCheckBtn, "获取验证码")
		end
	end)
end

function AccountPanel:RemoveEvent()
	AccountModel:GetInstance():RemoveEventListener(self.updateHandler)
	AccountModel:GetInstance():RemoveEventListener(self.startCountDownHandler)
end

function AccountPanel:GetReward()
	local rewardCfg = GetCfgData("reward")
	for k , v in pairs(rewardCfg) do
		if type(v) ~= 'function' and v and v.type == RewardConst.Type.PhoneBind then
			self.cfg = v
		end
	end
	if self.cfg then
		local rewards = self.cfg.reward
		local count = #rewards
		local w = 88
		local x = (862 - w*count)*0.5
		local y = self.ui:GetChild("n16").y + 45
		for i = 1, #rewards do
			local icon = PkgCell.New(self.ui)
			icon:SetDataByCfg(rewards[i][1], rewards[i][2], rewards[i][3], rewards[i][4])
			icon:SetXY(x, y)	
			icon:OpenTips(true)
			x = x + w + 15
		end
	end
end

function AccountPanel:Update()
	if self.reBandOperate then return end
	if AccountModel:GetInstance().bindTelePhone == "0" then --未绑定
		self.state.selectedIndex = 0
		self.bindState = 0
		self.bandState.selectedIndex = 0
	else --已绑定
		self.state.selectedIndex = 1

		local number = AccountModel:GetInstance().bindTelePhone
		local pre = string.sub(number, 1, 3)
		local tail = string.sub(number, 8)
		self.bindInfo.text = StringFormat("您绑定的手机号为：{0}****{1}", pre, tail)

		if AccountModel:GetInstance().rewardState == 0 then
			self.bindState = 1
			self.bandState.selectedIndex = 1
		else
			self.bindState = 2
			self.bandState.selectedIndex = 2
		end
	end
	self.ui.visible = true
end

AccountPanel.OldTxt = nil
AccountPanel.CountDownTime = 0
AccountPanel.CountDownTarget = nil
AccountPanel.CountDownTargetTxt = nil
function AccountPanel.CountDown(target, oldTxt)
	AccountPanel.OldTxt = oldTxt
	AccountPanel.CountDownTarget = target
	AccountPanel.CountDownTargetTxt = target:GetChild("title")
	-- AccountPanel.CountDownTarget.grayed = true
	AccountPanel.CountDownTarget.touchable = false
	AccountPanel.CountDownTime = 60
	AccountPanel.CountDownTargetTxt.text = ""
	RenderMgr.Add(function () AccountPanel.CountDownInFrame() end, "AccountPanel.CountDown")
end

function AccountPanel.CountDownInFrame()
	AccountPanel.CountDownTime = AccountPanel.CountDownTime - Time.deltaTime
	AccountPanel.CountDownTargetTxt.text = StringFormat("{0}秒",math.ceil(AccountPanel.CountDownTime))
	if AccountPanel.CountDownTime < 0 then
		AccountPanel.StopCountDownInFrame()
	end
end

function AccountPanel.StopCountDownInFrame()
	RenderMgr.Remove("AccountPanel.CountDown")

	if AccountPanel.CountDownTarget then
		-- AccountPanel.CountDownTarget.grayed = false
		AccountPanel.CountDownTarget.touchable = true
		AccountPanel.CountDownTargetTxt.text = AccountPanel.OldTxt
	end

	AccountPanel.CountDownTarget = nil
	AccountPanel.CountDownTargetTxt = nil
end

function AccountPanel:__delete()
	self:RemoveEvent()
end