local CSpeechRecordView = class("CSpeechRecordView", CViewBase)

function CSpeechRecordView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Audio/SpecchRecordView.prefab",cb)
end

function CSpeechRecordView.OnCreateView(self)
	self.m_RecordWidget = self:NewUI(1, CWidget)
	self.m_CacelWidget = self:NewUI(2, CWidget)
	self.m_VolumeSpr = self:NewUI(3, CSprite)
	self.m_ShortWidget = self:NewUI(4, CWidget)
	self.m_RecordBtnRef = nil
	self.m_CheckTimer = Utils.AddTimer(callback(self, "CheckRecord"), 0, 0)
end

function CSpeechRecordView.BeginRecord(self)
	self:ShowRecord()
	g_SpeechCtrl:StartRecord()
end

function CSpeechRecordView.EndRecord(self, iChannel)
	local key, iErr = g_SpeechCtrl:EndRecord()
	if key and self.m_RecordWidget:GetActive() then
		local path = g_SpeechCtrl:SaveToAmr(key)
		if path then
			local dUploadArgs = {channel = iChannel}
			g_SpeechCtrl:UploadToServer(key, path, dUploadArgs)
			g_SpeechCtrl:TranslateFromServer(key, path)
		end
	end
	
	if iErr == enum.AudioRecordError.IsToShort then
		self:ShowShort()
	else
		self:CloseView()
	end
end

function CSpeechRecordView.EndFriendRecord(self, pid)
	local key, iErr = g_SpeechCtrl:EndRecord()
	if key and self.m_RecordWidget:GetActive() then
		local path = g_SpeechCtrl:SaveToAmr(key)
		if path then
			local dUploadArgs = {pid = pid}
			g_SpeechCtrl:UploadToServer(key, path, dUploadArgs)
			g_SpeechCtrl:TranslateFromServer(key, path)
		end
	end
	
	if iErr == enum.AudioRecordError.IsToShort then
		self:ShowShort()
	else
		self:CloseView()
	end
end

function CSpeechRecordView.ShowRecord(self)
	self.m_RecordWidget:SetActive(true)
	self.m_CacelWidget:SetActive(false)
	self.m_ShortWidget:SetActive(false)
end

function CSpeechRecordView.ShowCancel(self)
	self.m_RecordWidget:SetActive(false)
	self.m_CacelWidget:SetActive(true)
	self.m_ShortWidget:SetActive(false)
end

function CSpeechRecordView.ShowShort(self)
	Utils.DelTimer(self.m_CheckTimer)
	self.m_RecordWidget:SetActive(false)
	self.m_CacelWidget:SetActive(false)
	self.m_ShortWidget:SetActive(true)
	Utils.AddTimer(callback(self, "CloseView"), 0, 1)
end

function CSpeechRecordView.SetRecordBtn(self, oBtn)
	self.m_RecordBtnRef = weakref(oBtn)
end

function CSpeechRecordView.GetRecordBtn(self)
	return getrefobj(self.m_RecordBtnRef)
end

function CSpeechRecordView.CheckRecord(self)
	local oBtn = self:GetRecordBtn()
	if oBtn then
		local worldPos = g_CameraCtrl:GetNGUICamera().lastWorldPosition
		if oBtn:IsInRect(worldPos) then
			self:ShowRecord()
		else
			self:ShowCancel()
		end
	end
	local iVolume = g_SpeechCtrl:GetRecordVolume()
	self.m_VolumeSpr:SetFillAmount(iVolume)
	return true
end


return CSpeechRecordView