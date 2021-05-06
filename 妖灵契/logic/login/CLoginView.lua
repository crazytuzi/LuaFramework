CLoginView = class("CLoginView", CViewBase)

function CLoginView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Login/LoginView.prefab", cb)
	self.m_DepthType = "Login"
end

function CLoginView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_AccountPage = self:NewPage(2, CLoginAccountPage)
	self.m_ServerPage = self:NewPage(3, CLoginServerPage)
	self.m_TipsPage = self:NewPage(4, CLoginTipsPage)
	self.m_VersionLabel = self:NewUI(5, CLabel)
	self.m_InvitationCodePage = self:NewPage(6, CInvitationCodePage)
	self.m_Bg = self:NewUI(7, CWidget)
	self.m_MsgLabel = self:NewUI(8, CLabel)
	self.m_LoginEffect = self:NewUI(9, CObject)
	self.m_SdkPage = self:NewPage(10, CSdkPage)
	self.m_QRCodePage = self:NewPage(11, CQRCodePage)
	self.m_FixedLabel = self:NewUI(12, CLabel)
	self.m_Logo = self:NewUI(13, CWidget)
	self.m_TipLabel = self:NewUI(14, CLabel)
	self.m_LastPag = nil
	self:InitContent()
end

function CLoginView.IsOtherBgRes(self)
	if Utils.IsEditor() then
		return false
	end
	if main.g_DllVer <= 3 then
		return false
	end
	local sType = Utils.GetGameType()
	if sType == "ylq" then
		return false 
	end

	return true
end

function CLoginView.SetEffectShow(self, b)
	if self:IsNeedShowEffect() then
		self.m_LoginEffect:SetActive(b)
	end
end

function CLoginView.IsNeedShowEffect(self)
	local sType = Utils.GetGameType()
	if sType == "ylq" or sType == "ylwy" then
		return true
	end
	return false
end

function CLoginView.InitContent(self)
	self.m_FixedLabel:SetActive(false)
	self.m_FixedLabel:AddUIEvent("click", callback(self, "OnFixed"))
	g_AudioCtrl:PlayMusic("bgm_login.ogg")
	Utils.AddTimer(function() C_api.Utils.HideGameLoading() end, 0, 0)
	UITools.ResizeToRootSize(self.m_Container)
	UITools.FitToRootScale(self.m_Bg, 1334, 750)
	local framever, gamever, resver = C_api.Utils.GetAppVersion()
	local framever2, gamever2, resver2, svnver2 = C_api.Utils.GetPackageResVersion()
	local framever3, gamever3, resver3, svnver3 = C_api.Utils.GetResVersion()
	local s = string.format("App:%s.%s.%s Base:%s.%s.%s.%s Res:%s.%s.%s.%s P:%s", framever, gamever, resver, framever2, gamever2, resver2, svnver2, framever3, gamever3, resver3, svnver3, main.g_ProtoVer)
	self.m_VersionLabel:SetText(s)
	self.m_MsgLabel:SetText("")
	
	self.m_Bg.m_UIWidget.mainTexture = C_api.ResourceManager.LoadStreamingAssetsTexture("Textures/loginBG")
	-- if self:IsOtherBgRes() then
	self.m_Logo.m_UIWidget.mainTexture = C_api.ResourceManager.LoadStreamingAssetsTexture("Textures/logo")
	-- end
	local framever, dllver, resver = C_api.Utils.GetResVersion()
	if resver >= 76 then
		self.m_Logo:MakePixelPerfect()
	end
	self.m_LoginEffect:SetActive(self:IsNeedShowEffect())
	local dGameSettingData = g_ApplicationCtrl:GetGameSettingData()
	if dGameSettingData.loginTipText then
		self.m_TipLabel:SetActive(true)
		self.m_TipLabel:SetText(dGameSettingData.loginTipText)
	else
		self.m_TipLabel:SetActive(false)
	end

	self:CheckShowPage()
	g_ViewCtrl:HideBottomView()
end

function CLoginView.OnFixed(self)
	local args ={
		title = "修复客户端",
		msg = "更新补丁失败,无法进入游戏,可尝试修复",
		okCallback = function() C_api.Utils.RestoreGameRes(true) end,
		okStr = "修复",
		cancelCallback = function()  end,
		forceConfirm = true,
	}
	g_WindowTipCtrl:SetWindowConfirm(args)
	
end

function CLoginView.CheckShowPage(self)
	if g_LoginCtrl:IsSdkLogin() then
		if g_SdkCtrl:IsLogin() and g_ServerCtrl:IsInit() then
			self:ShowServerPage()
		else
			self:ShowSdkPage()
		end
	else
		if Utils.IsPC() and main.g_AppType == "release" then
			self:ShowQRCodePage()
		else
			self:ShowAccountPage()
		end
	end
end

function CLoginView.SetLoginMsg(self, sText)
	self.m_MsgLabel:SetText(sText)
end

function CLoginView.ShowAccountPage(self)
	if g_LoginCtrl:IsSdkLogin() then
		return
	end
	self:ShowSubPage(self.m_AccountPage)
	self:SetEffectShow(true)
end

function CLoginView.ShowServerPage(self)
	self:ShowSubPage(self.m_ServerPage)
	self:SetEffectShow(true)
end

function CLoginView.ShowSdkPage(self)
	self:ShowSubPage(self.m_SdkPage)
	self:SetEffectShow(true)
end

function CLoginView.ShowQRCodePage(self)
	self:ShowSubPage(self.m_QRCodePage)
	self:SetEffectShow(true)
end

function CLoginView.ShowTipsPage(self, sTips)
	if self.m_CurPage ~= self.m_TipsPage then
		self.m_LastPage = self.m_CurPage
	end
	self:ShowSubPage(self.m_TipsPage)
	self.m_TipsPage:SetTips(sTips)
	self:SetEffectShow(true)
end


function CLoginView.HideTipsPage(self)
	if self.m_LastPage then
		self:ShowSubPage(self.m_LastPage)
	else
		self:HideAllPage()
	end
	self:SetEffectShow(true)
end

function CLoginView.ShowInvitationCodePage(self)
	self:ShowSubPage(self.m_InvitationCodePage)
	self:SetEffectShow(false)
end

function CLoginView.CloseView(self)
	CViewBase.CloseView(self)
	g_ViewCtrl:ShowBottomView()
end

return CLoginView