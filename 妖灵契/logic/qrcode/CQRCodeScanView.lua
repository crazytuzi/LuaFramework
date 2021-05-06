local CQRCodeScanView = class("CQRCodeScanView", CViewBase)

function CQRCodeScanView.ctor(self, cb)
	CViewBase.ctor(self, "UI/QRCode/QRCodeScanView.prefab", cb)
	--界面设置
	self.m_DepthType = "Dialog"
	-- self.m_GroupName = "main"
end

function CQRCodeScanView.OnCreateView(self)
	self.m_ScanTexture = self:NewUI(1, CTexture)
	self.m_TipLbl = self:NewUI(2, CLabel)
	self.m_CloseBtn = self:NewUI(3, CButton)
	self.m_Contanier = self:NewUI(4, CWidget)

	self.m_DecodeInterval = 0.5
	self.m_LastDecodeTime = 0

	--用于判断摄像机是否初始化成功的值，据说有可能会出现这个问题
	self.m_WebCamTextureInitSuccessSize = 100
	self.m_InitDone = false
	self.m_ViewSize = 0
	self:InitContent()
end

function CQRCodeScanView.InitContent(self)
	self.m_WebCamTexture = C_api.WebCamTextureHelper.GetNewWebCamTexture(800, 480, true, 30)
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	if self.m_WebCamTexture ~= nil then
		printc("生成m_WebCamTexture成功", self.m_WebCamTexture.width, self.m_WebCamTexture.height, self.m_WebCamTexture.didUpdateThisFrame)
		self.m_WebCamTexture:Play()
		self.m_ScanTexture.m_UIWidget.mainTexture = self.m_WebCamTexture
		self.m_CheckTimer = Utils.AddLateTimer(callback(self, "CheckQRUpdate"), 0, 0)
		self.m_InitDone = true
	else
		printc("生成m_WebCamTexture失败,m_WebCamTexture为nil")
		g_NotifyCtrl:FloatMsg("像机初始化失败, 请重试")
	end
end

function CQRCodeScanView.OnClose(self, cb)
	if self.m_WebCamTexture then
		self.m_WebCamTexture:Stop()
		self.m_WebCamTexture:Destroy()
		self.m_WebCamTexture = nil
	end
	self:CloseView()
end

function CQRCodeScanView.CheckViewSize(self)
	if self.m_InitDone and self.m_ViewSize == 0 then
		local bBasedOnWidth = (UnityEngine.Screen.width / UnityEngine.Screen.height) > (self.m_WebCamTexture.width / self.m_WebCamTexture.height)
		self.m_ScanTexture:SetKeepAspectRatio(bBasedOnWidth and 1 or 2)
		self.m_ScanTexture:SetAspectRatio(self.m_WebCamTexture.width / self.m_WebCamTexture.height)
		self.m_ScanTexture:ResetAndUpdateAnchors()
		local scale = bBasedOnWidth and (self.m_ScanTexture:GetWidth() / self.m_WebCamTexture.width) or (self.m_ScanTexture:GetHeight() / self.m_WebCamTexture.height)
		self.m_ViewSize = math.ceil((self.m_Contanier:GetWidth()+ 100) / scale)
	end
end

function CQRCodeScanView.CheckQRUpdate(self)
	if not self.m_WebCamTexture then
		return true
	end
	if self.m_WebCamTexture.didUpdateThisFrame 
		and self.m_WebCamTexture.width > self.m_WebCamTextureInitSuccessSize 
		and self.m_WebCamTexture.height > self.m_WebCamTextureInitSuccessSize then
		self:CheckViewSize()
		--必须每次都计算
		self.m_ScanTexture:SetLocalScale(Vector3.New(1, self.m_WebCamTexture.videoVerticallyMirrored and -1 or 1, 1))
		self.m_ScanTexture:SetRotation(UnityEngine.Quaternion.AngleAxis(self.m_WebCamTexture.videoRotationAngle, Vector3.forward))
		--保证初始化完毕
		local iCurTime = UnityEngine.Time.realtimeSinceStartup 
		if iCurTime - self.m_LastDecodeTime > self.m_DecodeInterval  then
			local sucess, result = xxpcall(function ()
				return C_api.AntaresQRCodeUtil.Decode(self.m_WebCamTexture, self.m_ViewSize, self.m_ViewSize)
			end)
			self.m_LastDecodeTime = iCurTime
			if not sucess or not result or result == "" then
				return true
			end
			local qrData = decodejson(result)
			self.m_WebCamTexture:Pause()
			self.m_CheckTimer = nil
			print("扫码获得的信息字符串: ", #result, result)
			if qrData.sid then
				local needList = {account_token = g_LoginCtrl.m_VerifyInfo.token, code_token = qrData.sid}
				g_QRCodeCtrl:PostQRLoginRequest(needList, callback(self, "OnPostDone", qrData))
			else
				g_NotifyCtrl:FloatMsg("无效的二维码,请重试")
				self:OnClose()
			end
			return false
		end
	end
	return true
end

function CQRCodeScanView.OnPostDone(self, dData, sucess, tResult)
	if sucess and tResult then
		if tResult.errcode == 0 then
			if dData then
				local function delay()
					CQRCodeEnsureView:CloseView()
					CQRCodeEnsureView:ShowView(function (oView)
						oView:SetData(nil, dData.sid, dData.notice_ver)
					end)
				end
				Utils.AddTimer(delay, 0, 0)
			else
				g_NotifyCtrl:FloatMsg("二维码数据为空, 请重试")
			end

		elseif tResult.errcode == 502 then
			g_NotifyCtrl:FloatMsg("PC端二维码已过期,请重刷二维码")
		elseif tResult.errcode == 501 then
			g_NotifyCtrl:FloatMsg("账号登录失效,请手机端重新登录账号")
		elseif tResult.errcode == 503 then
			g_NotifyCtrl:FloatMsg("PC端二维码已过期,请重刷二维码")
		else
			g_NotifyCtrl:FloatMsg("扫码失败，请把取景框对准PC端二维码")
		end
	else
		g_NotifyCtrl:FloatMsg("该二维码无效,请重刷二维码")
	end
	self:OnClose()
end


function CQRCodeScanView.Destroy(self)
	if self.m_CheckTimer then
		Utils.DelTimer(self.m_CheckTimer)
		self.m_CheckTimer = nil
	end
	CViewBase.Destroy(self)
end

return CQRCodeScanView