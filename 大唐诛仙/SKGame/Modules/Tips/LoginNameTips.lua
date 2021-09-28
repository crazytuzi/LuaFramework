LoginNameTips = BaseClass(LuaMsgWin)
function LoginNameTips:__init(...)
	self.URL = "ui://ixdopynlroks1d";
	self.ui = ui or self.ui or UIPackage.CreateObject("Tips","LoginNameTips")

	self.bg0 = self.ui:GetChild("bg0")
	self.richTextTips = self.ui:GetChild("richTextTips")
	self:Config()
end

function LoginNameTips:Config()
	self:InitData()
	self:InitEvent()
	self:InitUI()
end

function LoginNameTips:InitData()
	self.loginController = LoginController:GetInstance()
end

function LoginNameTips:InitEvent()
	self.richTextTips.onClickLink:Add(self.OnBindClick ,self)
end

function LoginNameTips:InitUI()

end

function LoginNameTips.Create(ui, ...)
	return LoginNameTips.New(ui, "#", {...})
end

function LoginNameTips:SetMsg(accountData)
	self.accountData = accountData or {}
	self:SetCenter()
	self:ShowMsg()
	self:SetTipsTween()
end

function LoginNameTips:SetTipsTween()
	self.tweener = self.ui:TweenMoveY(self.ui.y-100, 2)
	TweenUtils.SetEase(self.tweener, 21)
	TweenUtils.SetAutoKill(self.tweener, true)
	TweenUtils.OnComplete(self.tweener, function ()
		TweenUtils.Kill(self.tweener, true)
		self.tweener = self.ui:TweenFade(0, 0.5)
		TweenUtils.OnComplete(self.tweener, function ()
			TweenUtils.Kill(self.tweener, true)
			self.tweener = nil
			self:Close()
			self:Destroy()
		end)
	end)
end


function LoginNameTips:ShowMsg()
	self.richTextTips.text = self:GetTipsContent()
end

function LoginNameTips:GetTipsContent()
	local rtnTipsContent = ""
	local accountIconURL = UIPackage.GetItemURL("Login" , "zhanghao")
	if accountIconURL then rtnTipsContent = StringFormat("<img src='{0}'/>" , accountIconURL) end
	if not TableIsEmpty(self.accountData) then
		if  self.accountData.isVisitor == true then
			rtnTipsContent = StringFormat("[size=24][color=#0F0F0F]{0}  游客{1} 进入游戏  [/color][color=#20A47D][url][u]游客绑定[/u][/url][/color][/size]" , rtnTipsContent , self.accountData.userName or "")
		else
			rtnTipsContent = StringFormat("[size=24][color=#OFOFOF]{0}  {1} 进入游戏[/color][/size]", rtnTipsContent , self.accountData.userName or "")
		end

		if self.accountData.telePhone ~= nil then
			if self.accountData.telePhone == 0 then
				rtnTipsContent = StringFormat("{0}\n[size=18][color=#F85555]账号有丢失风险，请尽快在设置界面绑定手机号码[/color][/size]", rtnTipsContent)
			else
				rtnTipsContent = StringFormat("{0}\n[size=18][color=#20A47D]您的账号已经绑定手机号码[/color][/size]" , rtnTipsContent)
			end
		end
	end

	return rtnTipsContent
end

function LoginNameTips:OnBindClick()
	local isVisitorBind = true
	self.loginController:OpenCreateAccountPanel(isVisitorBind)
	self:Close()
	self:Destroy()
end

function LoginNameTips:__delete()
	self:Close()
	if self.tweener then
		TweenUtils.Kill(self.tweener, true)
		self.tweener = nil
	end
	self.bg0 = nil
end