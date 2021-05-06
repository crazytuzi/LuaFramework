local CSdkCtrl = class("CSdkCtrl")

function CSdkCtrl.ctor(self)
	C_api.SPSDK.SetCallback(callback(self, "OnSdkEvent"))
	C_api.SPSDK.Init()
	self.m_IsInit = false
	self.m_IsLogin = false
	self.m_IsLogining = false
	self.m_SdkSid = nil
	self.m_SdkUid = nil
	self.m_DemiToken = nil
	self.m_PayInfo = nil
	self.m_ClosePay = false
end

function CSdkCtrl.Init(self)
	C_api.SPSDK.Init()
end

function CSdkCtrl.GetDebugInfo(self)
	local t = {
		cs_url = Utils.GetCenterServerUrl(),
		channel = self:GetChannelId(),
		sub_channel = self:GetSubChannelId(),
		game_type = Utils.GetGameType(),
	}
	return "debuginfo:" .. cjson.encode(t)
end

function CSdkCtrl.IsNeedAutoLogin(self)
	if Utils.IsIOS() then
		return true
	elseif Utils.IsAndroid() then
		local sChannel = self:GetSubChannelId()
		if sChannel == "qihoo360" or sChannel == "huawei" then
			return false
		end
		return true
	end
end

function CSdkCtrl.SetClosePay(self, bClose)
	self.m_ClosePay = bClose
	self:ClearPayInfo()
end

function CSdkCtrl.IsClosePay(self)
	-- local dServer = g_LoginCtrl:GetConnectServer()
	-- if dServer and dServer.server_id == "bus_gs10001" then 
	-- 	return true
	-- end
	return self.m_ClosePay
end

function CSdkCtrl.ShowPayView(self)
	if self:IsClosePay() then
		g_NotifyCtrl:FloatMsg("充值暂未开放")
	else
		local oView = CNpcShopView:GetView()
		if oView then
			oView:OpenRecharge()
			oView:SetActive(false)
			oView:SetActive(true)
		else
			CNpcShopView:ShowView(function (oView1)
				oView1:OpenRecharge()
			end)
		end
	end
end

function CSdkCtrl.PlatformCall(self, sFuncName, ...)
	local oCtrl
	if Utils.IsIOS() then
		oCtrl = g_IOSCtrl
	elseif Utils.IsAndroid() then
		oCtrl = g_AndroidCtrl
	else
		return
	end
	local func = oCtrl[sFuncName]
	if func then
		return func(oCtrl, ...)
	else
		print("PlatformCall missing:", sFuncName)
	end
end

function CSdkCtrl.Setter(self, k, v)
	self[k] = v
end

function CSdkCtrl.Getter(self, k)
	return self[k]
end

function CSdkCtrl.ExitGame(self)
	local bUnityQuit = false
	if Utils.IsIOS() then
		bUnityQuit = true
	end
	if self.m_IsInit and not bUnityQuit then
		C_api.SPSDK.DoExiter()
		return true
	end
	return false
end

function CSdkCtrl.Logout(self)
	if self.m_IsInit then
		C_api.SPSDK.Logout()
	end
	self.m_IsLogin = false
end

function CSdkCtrl.IsInit(self)
	return self.m_IsInit
end

function CSdkCtrl.IsLogin(self)
	return self.m_IsLogin
end

function CSdkCtrl.RetryDlg(self, title, msg, okStr, okCallback)
	local args ={
		title = title,
		msg = msg,
		okCallback = okCallback,
		okStr = okStr,
		cancelStr = "退出游戏",
		cancelCallback = function() Utils.QuitGame() end,
		forceConfirm = true,
	}
	g_WindowTipCtrl:SetWindowConfirm(args)
	g_NotifyCtrl:HideConnect()
end


function CSdkCtrl.RetryLoginDlg(self, title, msg)
	local args ={
		title = title,
		msg = msg,
		okCallback = function() self:Login() end,
		okStr = "登录",
		forceConfirm = true,
		hideCancel = true,
	}
	g_WindowTipCtrl:SetWindowConfirm(args)
	g_NotifyCtrl:HideConnect()
end

function CSdkCtrl.Login(self, bLogOut)
	print("CSdkCtrl.Login:", bLogOut)
	g_NotifyCtrl:ShowConnect("正在登录 ...")
	if self.m_IsLogining then
		-- g_NotifyCtrl:FloatMsg("已经在登录中，请稍等")
		print("已经在Logining")
	else
		if not self.m_IsInit then
			print("还没init")
			return
		end
		self.m_IsLogining = true
		CLoginView:ShowView()
		self.m_IsLogin = false
		C_api.SPSDK.Login()
	end
end

function CSdkCtrl.ShowLoginWithMsg(self, sMsg)
	g_NotifyCtrl:HideConnect()
	if sMsg ~= "" then 
		sMsg = sMsg.."\n"..self:GetDebugInfo()
		printerror(sMsg)
	else
		local oView = CLoginView:GetView()
		if oView then
			oView:ShowServerPage()
		end
	end
end

function CSdkCtrl.OnSdkEvent(self, sJson)
	if not g_LoginCtrl:IsSdkLogin() then
		print("不是Sdk登录, 不处理回调")
		return
	end
	local tEvent = decodejson(sJson)
	print("CSdkCtrl.OnSdkEvent: ", sJson, tEvent)
	if not tEvent.code then
		printerror("sdk返回数据code为空")
		return
	end
	tEvent.code = tonumber(tEvent.code)
	if tEvent.type == "init" then
		if tEvent.code == 0 then
			--之前调用过登录，直接登录
			self.m_IsInit = true
			if self.m_IsLogining or self:IsNeedAutoLogin() then
				self:Login()
			end
			local sChanneID = self:GetChannelId()
			if sChanneID == "kaopu" then
				enum.Sdk.UploadType = enum.Kaopu.UploadType
			elseif sChanneID == "sm" then
				enum.Sdk.UploadType = enum.ShouMeng.UploadType
			end
		else
			-- self:RetryDlg("sdk初始化失败", "是否重新初始化?", "重试", function() self:Init() end)
			self:ShowLoginWithMsg("sdk初始化失败, msg:"..tostring(tEvent.msg))
		end
	elseif tEvent.type == "login" then
		self.m_IsLogining = false
		self:PlatformCall("OnLoginProcess", tEvent)
	elseif tEvent.type == "logout" then
		g_LoginCtrl:LogoutProcess()
		local dData = decodejson(tEvent.data)
		if dData.hasCallLogin == false then
			self:Login(true)
		else
			self.m_IsLogin = false
			CLoginView:ShowView(function(oView) 
					oView:ShowSdkPage()
				end)
		end
	elseif tEvent.type == "exit" then
		if tEvent.code == 0 then
			if g_LoginCtrl:HasLoginRole() then
				netlogin.C2GSLogoutByOneKey()
			end
		end
	elseif tEvent.type == "pay" then
		if self.m_PayInfo then
			--0:success, 1:cancel or submit, 2:fail
			if not Utils.IsAndroid() or (self:GetChannelId() == "kaopu") then
				if tEvent.code == 0 then --支付成功，通知demi
					g_NotifyCtrl:FloatMsg("支付成功")
				elseif tEvent.code == 1 then
					g_NotifyCtrl:FloatMsg("支付取消")
				elseif tEvent.code == 2 then
					g_NotifyCtrl:FloatMsg("支付失败")
				end
			end
			self:ClearPayInfo()
		else
			print("不存在订单信息")
		end
	elseif string.startswith(tEvent.type, "QQPlugin") then
		g_QQPluginCtrl:OnCallBack(string.sub(tEvent.type, 10), tEvent.code, tEvent.data)
	end
end

function CSdkCtrl.GetChannelId(self)
	if Utils.IsEditor() then
		return IOTools.GetClientData("SDKChannel") or ""
	end
	if g_QRCodeCtrl:IsQRCodeLogin() then
		local dQrTransData = g_QRCodeCtrl:GetTransferData()
		return dQrTransData.channel_id
	else
		return define.DemiFrame.ChannelID or C_api.SPSDK.GetChannelId()
	end
	return "nil"
end

function CSdkCtrl.GetSubChannelId(self)
	if Utils.IsEditor() then
		return IOTools.GetClientData("SDKSubChannel") or ""
	end
	if g_QRCodeCtrl:IsQRCodeLogin() then
		local dQrTransData = g_QRCodeCtrl:GetTransferData()
		return dQrTransData.sub_channel_id
	else
		local subid = define.DemiFrame.SubChannelID or C_api.SPSDK.GetSubChannelId()
		if subid == "smtest" or subid == "shoumeng" then
			if Utils.IsAndroid() then
				return "sm-android"
			elseif Utils.IsIOS() then
				return "sm-ios"
			end
		end
		return subid
	end
	return "nil"
end

function CSdkCtrl.RequestDemiToken(self)
	-- g_NotifyCtrl:ShowConnect("正在连接数据中心...")
	-- local data = {
	-- 	appId = define.DemiFrame.GameID,
	-- 	channel = self:GetChannelId(), 
	-- 	p = self:GetSubChannelId(),
	-- }
	-- local sUrl = g_HttpCtrl:FormatUrl(define.DemiFrame.NormalUrl, data)
	-- print("CSdkCtrl.RequestDemiToken", sUrl)
	-- g_HttpCtrl:Get(sUrl, callback(self, "OnDemiTokenCallback"), {json_result=true})
	self:SendToCenterServer()
end

function CSdkCtrl.OnDemiTokenCallback(self, success, tResult)
	print("CSdkCtrl.OnDemiTokenCallback:", success)
	table.print(tResult)
	if success then
		if tResult.code > 0 then
			-- self:RetryLoginDlg("数据中心异常", "无效的返回码:"..tostring(tResult.code))
			self:ShowLoginWithMsg("数据中心返回码:"..tostring(tResult.code))
			return
		end
		if tResult.item.close then
			-- self:RetryLoginDlg("数据中心异常", "数据中心已关闭")
			self:ShowLoginWithMsg("数据中心已关闭")
			return
		end
		if tResult.item.channelId then
			self.m_DemiToken = tResult.item.channelId
			self:SendToCenterServer()
		else
			-- self:RetryLoginDlg("数据中心异常", "返回数据channel_id丢失")
			self:ShowLoginWithMsg("数据中心返回数据id不存在")
		end
	else
		self:ShowLoginWithMsg("数据中心连接失败")
		-- self:RetryLoginDlg( "数据中心异常", "请求失败")
	end
end

function CSdkCtrl.SendToCenterServer(self)
	g_NotifyCtrl:ShowConnect("正在更新游戏服务器数据...")
	
	local sJson = cjson.encode({
			token = self.m_SdkSid,
			-- demi_channel = self.m_DemiToken,
			cps = self:GetSubChannelId(),
			device_id = Utils.GetDeviceUID(),
			account = self.m_SdkUid,
			platform = g_LoginCtrl:GetPlatformID(),
			notice_ver = IOTools.GetClientData("last_read_notice") or 0,
			packet_info = {game_type=Utils.GetGameType()},
			sdk_type = self:GetChannelId(),
		})
	local headers = {
		["Content-Type"]= "application/x-www-form-urlencoded",
	}
	local url = Utils.GetCenterServerUrl().."/loginverify/verify_account"
	g_HttpCtrl:Post(url, callback(self, "OnVerifyResult"), headers, sJson, {json_result=true})
	print("SendToCenterServer:", url, sJson)
	self.m_SdkSid = nil
	self.m_SdkUid = nil
	self.m_DemiToken = nil
end

function CSdkCtrl.OnVerifyResult(self, success, tResult)
	printc("OnVerifyResult-->", success)
	g_ServerCtrl:ClearServerData()
	if success and type(tResult) == "table" then 
		local sErr = "??"
		if (not tResult.errcode or tResult.errcode == 0) then
			if tResult.info then
				g_LoginCtrl:ProcessCSLoginInfo(tResult.info)
				return
			else
				sErr = "info"
			end
		else
			sErr = tostring(tResult.errcode)
		end
		self:ShowLoginWithMsg("sdk验证失败, 错误码:"..sErr)
	else
		self:ShowLoginWithMsg("cs已关闭")
		g_NotifyCtrl:FloatMsg("维护中...")
	end
	self.m_IsLogin = false
end

function CSdkCtrl.UploadData(self, sUploadType)
	if not sUploadType then
		return
	end
	if not self.m_IsInit then
		print("sdk upload: not init")
		return
	end
	if not self.m_IsLogin then
		print("sdk upload: not login")
		return
	end
	if g_AttrCtrl.name == "" then
		print("sdk upload: no name", sUploadType)
		return
	end
	local dUpload = self:PlatformCall("GetUploadData", sUploadType)
	local sJson = cjson.encode(dUpload)
	C_api.SPSDK.SubmitRoleData(sJson)
	print("上传数据", sJson)
end

--pay
function CSdkCtrl.Pay(self, sKey, iAmount, args)
	print("CSdkCtrl.Pay:", sKey, iAmount)
	if args then
		table.print(args, "pay args-------------------->")
	end
	if self:IsClosePay() then
		g_NotifyCtrl:FloatMsg("充值暂未开放")
		return
	end
	if sKey == nil then
		g_NotifyCtrl:FloatMsg("充值key不存在")
		return
	end
	g_NotifyCtrl:ShowConnect("请求订单数据...")
	self:ClearPayInfo()
	self.m_PayInfo = {product_key=sKey, product_amount = iAmount, product_args = args}
	netother.C2GSRequestPay(sKey, iAmount, args)

	--15秒没获取到订单，则视为超时
	self.m_PayInfo.request_pay_timer = Utils.AddTimer(function()
		g_NotifyCtrl:FloatMsg("获取订单超时, 请稍后再试")
		self:ClearPayInfo()
	end, 0, 15)
end

function CSdkCtrl.IsPaying(self)
	return self.m_PayInfo ~= nil
end

function CSdkCtrl.ClearPayInfo(self)
	if self.m_PayInfo then
		g_NotifyCtrl:HideConnect()
		if self.m_PayInfo.request_pay_timer then
			Utils.DelTimer(self.m_PayInfo.request_pay_timer)
		end
		self.m_PayInfo = nil
	end
end

function CSdkCtrl.OnServerPayInfo(self, dPayInfo)
	if self.m_PayInfo then 
		if self.m_PayInfo.request_pay_timer then
			Utils.DelTimer(self.m_PayInfo.request_pay_timer)
			self.m_PayInfo.request_pay_timer = nil
		end
		if self.m_PayInfo.product_key == dPayInfo.product_key and
		self.m_PayInfo.product_amount == dPayInfo.product_amount then
			g_NotifyCtrl:ShowConnect("正在支付中...")
			self.m_PayInfo["order_id"] = dPayInfo. order_id
			self.m_PayInfo["product_value"] = dPayInfo.product_value
			self.m_PayInfo["callback_url"] = dPayInfo. callback_url
			
			local sJson = self:PlatformCall("GetJsonPayData", self.m_PayInfo)
			C_api.SPSDK.DoPay(sJson)
		else
			g_NotifyCtrl:FloatMsg("订单信息错误")
			self:ClearPayInfo()
		end
	else
		g_NotifyCtrl:HideConnect()
		g_NotifyCtrl:FloatMsg("不存在订单信息")
	end
end

function CSdkCtrl.GainGameCoin(self, iCoin)
	self:PlatformCall("GainGameCoin", iCoin)
end

function CSdkCtrl.ConsumeGameCoin(self, iCoin)
	iCoin = math.abs(iCoin)
	self:PlatformCall("ConsumeGameCoin", iCoin)
end

--客服论坛
function CSdkCtrl.IsSupportService(self)
	return g_LoginCtrl:IsSdkLogin() and C_api.SPSDK.IsSupportService()
end

function CSdkCtrl.OpenService(self)
	if self:IsSupportService() then
		self:PlatformCall("OpenService")
	end
end

return CSdkCtrl