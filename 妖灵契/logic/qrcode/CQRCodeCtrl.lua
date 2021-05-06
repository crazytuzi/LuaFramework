local CQRCodeCtrl = class("CQRCodeCtrl", CCtrlBase)
define.QRCode = {
	Event = {
		QRToken = 1,
		QRCScanSuccess = 2,
		ServerListSuccess = 3,
		QRCodeInvalid = 4,
		QRTimeOut = 5,
	}
}
function CQRCodeCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_ConnectPort = {10004, 10005, 10006, 10007, 10008, 10009}
	self.m_QRLeftTime = 0
	self.m_QRLeftTimer = nil
	self.m_IsQRLogin = false
	self.m_TransferData = {}
end

function CQRCodeCtrl.GetTransferData(self)
	return self.m_TransferData
end

function CQRCodeCtrl.ConnectServer(self)
	local url = Utils.GetCenterServerUrl()
	local idx = url:find("://")
	if idx then
		url = url:sub(idx+3)
	end
	g_NetCtrl:Connect(url, self.m_ConnectPort)
end

function CQRCodeCtrl.RefreshQRToken(self, token, time)
	self:OnEvent(define.QRCode.Event.QRToken, {token=token})
	self:SetQRLeftTime(time)
end

function CQRCodeCtrl.SetLoginInfo(self, sAccountInfo, sTransferInfo)
	local dAccount = decodejson(sAccountInfo)
	if dAccount.errcode == 0 and dAccount.info then
		CQRCodeLoginView:CloseView()
		g_LoginCtrl:ProcessCSLoginInfo(dAccount.info)
		g_NotifyCtrl:FloatMsg("扫码登录成功")
	else
		g_NotifyCtrl:FloatMsg("登录失败, 请重试")
	end
	self.m_IsQRLogin = true
	self.m_TransferData = decodejson(sTransferInfo)
end

function CQRCodeCtrl.IsQRCodeLogin(self)
	return self.m_IsQRLogin
end

function CQRCodeCtrl.OnQRCScanSuccess(self)
	self:OnEvent(define.QRCode.Event.QRCScanSuccess)
end

function CQRCodeCtrl.OnQRCodeInvalid(self)
	self:OnEvent(define.QRCode.Event.QRCodeInvalid)
end

--手机扫描二维码，请求登录
function CQRCodeCtrl.PostQRLoginRequest(self, data, cb)
	local url = Utils.GetCenterServerUrl().."/loginverify/qrcode_scan"
	local headers = {
		["Content-Type"]="application/json;charset=utf-8",
	}
	local sData = cjson.encode(data)
	table.print(sData, "CQRCodeCtrl.PostQRLoginRequest:")
	g_HttpCtrl:Post(url, cb, headers, sData, {json_result=true})
end

--手机上请求确认登录
function CQRCodeCtrl.PostLoginEnsure(self, data, cb)
	local url = Utils.GetCenterServerUrl().."/loginverify/qrcode_login"
	local headers = {
		["Content-Type"]="application/json;charset=utf-8",
	}
	local sData = cjson.encode(data)
	table.print(sData, "CQRCodeCtrl.PostLoginEnsure:")
	g_HttpCtrl:Post(url, cb, headers, sData, {json_result=true})
end

--二维码的总计时
function CQRCodeCtrl.SetQRLeftTime(self, iLeftTime)
	self:ResetQRLeftTimer()
	local function progress(dt)
		self.m_QRLeftTime = self.m_QRLeftTime - dt
		if self.m_QRLeftTime <= 0 then
			self.m_QRLeftTime = 0
			self:OnEvent(define.QRCode.Event.QRTimeOut)
			self.m_QRLeftTimer = nil
			return false
		end
		return true
	end
	self.m_QRLeftTime = iLeftTime + 1
	self.m_QRLeftTimer = Utils.AddTimer(progress, 0.1, 0)
end

function CQRCodeCtrl.ResetQRLeftTimer(self)
	if self.m_QRLeftTimer then
		Utils.DelTimer(self.m_QRLeftTimer)
		self.m_QRLeftTime = 0
		self.m_QRLeftTimer = nil
	end
end

return CQRCodeCtrl