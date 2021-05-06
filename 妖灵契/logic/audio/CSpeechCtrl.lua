local CSpeechCtrl = class("CSpeechCtrl", CCtrlBase)

CSpeechCtrl.g_TestSpeech = Utils.IsEditor()
CSpeechCtrl.g_TranslateUrl = "http://vop.baidu.com/server_api"

--语音
function CSpeechCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_AudioRecord = C_api.AudioRecord.Instance
	self.m_Sepeechs = {}
	self.m_PlayList = {}
	self.m_TranslateDone = {}
	self.m_WaitTranslate = {}
	self.m_PathKey = {}
	self.m_TranslateToken ="test_token"
	self.m_TokenGetting = false
	self.m_MaxTime = 29
end

function CSpeechCtrl.GetRecordVolume(self)
	return self.m_AudioRecord:GetRecordVolume(800) * 10
end

function CSpeechCtrl.InitCtrl(self)
	local localToken = self:GetTokenFromLocal()
	if localToken then
		self.m_TranslateToken = localToken
	else
		self:GetTokenFormServer()
	end
end

function CSpeechCtrl.GetMaxTime(self)
	return self.m_MaxTime
end

function CSpeechCtrl.GetTokenFromLocal(self)
	local tLocal = IOTools.GetClientData("bdyy_token")
	if tLocal then 
		print("CSpeechCtrl.GetTokenFromLocal", g_TimeCtrl:GetTimeS(),  tLocal.expire)
		if g_TimeCtrl:GetTimeS() < tLocal.expire then
			return tLocal.token
		end
	end
end

function CSpeechCtrl.GetTokenFormServer(self)
	if self.m_TokenGetting then
		return
	end
	self.m_TokenGetting = true
	local url = self:GetTokenUrl()
	g_HttpCtrl:Get(url, callback(self, "OnTokenGet"), {json_result=true})
end

function CSpeechCtrl.GetTokenUrl(self)
	return Utils.GetUrl("https://openapi.baidu.com/oauth/2.0/token",
			{grant_type="client_credentials",
			client_id ="rlU84dprH6I7sMjBkqM0gizl",
			client_secret="c15395c2433c4a904d22aa27eab8321b",})
end

function CSpeechCtrl.OnTokenGet(self, success, tResult)
	if success then
		self.m_TranslateToken = tResult.access_token
		local tSave = {["token"]=self.m_TranslateToken,
		["expire"]=(g_TimeCtrl:GetTimeS()+tResult.expires_in-240)}
		table.print(tResult, "OnTokenGet1-->")
		table.print(tSave, "OnTokenGet2-->")
		IOTools.SetClientData("bdyy_token", tSave)
	else
		print("OnTokenGet err")
	end
	self.m_TokenGetting = false
end

function CSpeechCtrl.StartRecord(self, iMax)
	self.m_StartTime = g_TimeCtrl:GetTimeS()
	g_AudioCtrl:SetSlience()
	self.m_AudioRecord:StartRecord(0, self.m_MaxTime + 10)  --设定的时间>30秒，实际时间30秒就会脚本关闭
end

function CSpeechCtrl.EndRecord(self)
	local iErr = self.m_AudioRecord:EndRecord()
	g_AudioCtrl:ExitSlience()
	local sKey = nil
	local iTime = 0
	if self.m_StartTime then
		iTime = g_TimeCtrl:GetTimeS() - self.m_StartTime
		self.m_StartTime = nil
	else
		iTime = 10
	end
	if iErr == enum.AudioRecordError.None then		
		if g_AttrCtrl.pid and g_AttrCtrl.pid ~= 0 then
			sKey = string.format("speech%d-%d", g_AttrCtrl.pid, g_TimeCtrl:GetTimeMS())
		else
			sKey = Utils.NewGuid()
		end
	
	elseif iErr == enum.AudioRecordError.IsSilence then
		g_NotifyCtrl:FloatMsg("录音失败，声音太小")
	elseif iErr == enum.AudioRecordError.IsToShort then
		g_NotifyCtrl:FloatMsg("录音失败，时间太短")
		
	elseif CSpeechCtrl.g_TestSpeech then
		if iTime < 1 then
			g_NotifyCtrl:FloatMsg("录音失败，时间太短")
			return
		end
		sKey = Utils.NewGuid()
	
	elseif iTime > 40 then
		g_NotifyCtrl:FloatMsg("录音失败，时间太长")
		return
	end
	
	if sKey then
		local dSpeech = self:GetSpeech(sKey)
		dSpeech["time"] = iTime
	end
	return sKey, iErr
end

function CSpeechCtrl.GetTestAmrPath(self)
	return IOTools.GetGameResPath("/Audio/testspeech.amr")
end

function CSpeechCtrl.SaveToAmr(self, key)
	if CSpeechCtrl.g_TestSpeech then
		return self:GetTestAmrPath()
	end
	local amrPath = IOTools.GetRoleFilePath(string.format("/speech/%s.amr", key))
	if self.m_AudioRecord:SaveToAmr(amrPath) then
		return amrPath
	else
		g_NotifyCtrl:FloatMsg("录音失败，无法保存")
	end
end

function CSpeechCtrl.SaveToWav(self, key)
	local wavPath = IOTools.GetRoleFilePath(string.format("/speech/%s.wav", key))
	if self.m_AudioRecord:SaveToWav(wavPath) then
		return wavPath
	else
		g_NotifyCtrl:FloatMsg("录音录制失败")
	end
end

function CSpeechCtrl.UploadToServer(self, key, path, dUploadArgs)
	dUploadArgs = dUploadArgs or {}
	if CSpeechCtrl.g_TestSpeech then
		Utils.AddTimer(function()
				self:OnUploadResult(path, dUploadArgs, key, true)
			end, 0, 0)
	else
		g_QiniuCtrl:UploadFile(key, path, enum.QiniuType.Audio, callback(self, "OnUploadResult", path, dUploadArgs))
	end
end

function CSpeechCtrl.OnUploadResult(self, path, dUploadArgs, key, sucess)
	if sucess then
		local filetype = string.gsub(IOTools.GetExtension(path), "%.", "")
		local dSpeech = self:GetSpeech(key)
		dSpeech[filetype] = path
		dSpeech["need_send"] = dUploadArgs.channel~=nil or dUploadArgs.pid~=nil
		dSpeech["channel"] = dUploadArgs.channel
		dSpeech["pid"] = dUploadArgs.pid
		if self.m_TranslateDone[key] then
			dSpeech["translate"] = self.m_TranslateDone[key]
			self.m_TranslateDone[key] = nil
		else
			self.m_WaitTranslate[key] = true
		end
		table.print(dSpeech, "speech.OnUploadResult-->")
		self:CheckSendSpeech(key)
	else
		print("上传失败", key)
	end
end

function CSpeechCtrl.TranslateFromServer(self, key, filepath)
	if CSpeechCtrl.g_TestSpeech then
		Utils.AddTimer(function()
				self:OnTranslateResult(key, true, {result={"自动语音转文字失败"}})
			end, 0, 0.1)
	else
		local url = Utils.GetUrl(CSpeechCtrl.g_TranslateUrl,
					{cuid = Utils.GetDeviceUID(),
					token = self.m_TranslateToken,
					lan = "zh"})
		local bytes = IOTools.LoadByteFile(filepath)
		local headers = {
			["Content-Type"]="audio/amr;rate=8000",
			["Content-length"]= tostring(bytes.Length),
		}
		g_HttpCtrl:Post(url, callback(self, "OnTranslateResult", key), headers, bytes, {json_result=true})
	end
end

function CSpeechCtrl.OnTranslateResult(self, key, success, tResult)
	local sTranslate = "自动语音转文字失败"
	if success then
		local result = tResult.result
		if result and next(result)then
			sTranslate = self:ProcessTranslateResult(result[1])
		else
			if tResult.err_no == 3302 then
				self:GetTokenFormServer()
			end
			print("translate fail->err_no", tResult.err_no, tResult.err_msg)
			sTranslate = sTranslate..tostring(tResult.err_no)
		end
		
	else
		print("translate err", key)
	end
	local bWait = self.m_WaitTranslate[key]
	if bWait then
		local dSpeech = self:GetSpeech(key)
		dSpeech["translate"] = sTranslate
		self.m_WaitTranslate[key] = nil
		self:CheckSendSpeech(key)
	else
		self.m_TranslateDone[key] = sTranslate
	end
end

function CSpeechCtrl.ProcessTranslateResult(self, sTranslate)
	sTranslate = string.gsub(sTranslate, "，", "")
	return sTranslate
end

function CSpeechCtrl.DownloadFromServer(self, key, type, cb)
	if CSpeechCtrl.g_TestSpeech then
		Utils.AddTimer(function()
			local path = self:GetTestAmrPath()
			data.bytes = IOTools.LoadByteFile(path)
			self:OnDownloadResult(type, cb, key, data)
		end, 0, 0.5)
	else
		g_QiniuCtrl:DownloadFile(key, callback(self, "OnDownloadResult", type, cb))
	end
end

function CSpeechCtrl.OnDownloadResult(self, type, cb, key, www)
	if www then
		local path = IOTools.GetRoleFilePath(string.format("/speech/%s.%s", key, type))
		IOTools.SaveByteFile(path, www.bytes)
		local dSpeech = self:GetSpeech(key)
		dSpeech[type] = path
		if cb then
			cb(path)
		end
		table.print(dSpeech, "speech.OnDownloadResult-->")
	else
		print("下载失败", key)
	end
end

function CSpeechCtrl.CheckSendSpeech(self, key)
	local dSpeech = self:GetSpeech(key)
	if dSpeech and dSpeech.need_send and dSpeech.translate then
		local sText = g_MaskWordCtrl:ReplaceMaskWord(dSpeech.translate)
		if dSpeech.channel then -->发送频道
			local sMsg = LinkTools.GenerateSpeechLink(key, sText, dSpeech.time)
			g_ChatCtrl:SendMsg(sMsg, dSpeech.channel)

		elseif dSpeech.pid then -->发给好友
			local sMsg = LinkTools.GenerateSpeechLink(key, sText, dSpeech.time)
			g_TalkCtrl:AddSelfMsg(dSpeech.pid, sMsg)
			g_TalkCtrl:SendChat(dSpeech.pid, sMsg)
		end
		dSpeech.need_send = false
	end
end

function CSpeechCtrl.GetSpeech(self, key)
	if not self.m_Sepeechs[key] then
		self.m_Sepeechs[key] = {key=key}
	end
	return self.m_Sepeechs[key]
end

function CSpeechCtrl.PlayWithKey(self, key)
	local dSpeech = self:GetSpeech(key)
	if dSpeech then
		local function f(path)
			self:ClearPlayList()
			self:PlayWithPath(path)
		end
		if dSpeech.amr then
			self.m_PathKey[dSpeech.amr] = key
			f(dSpeech.amr)
		else
			self:DownloadFromServer(key, "amr", f)
		end
	end
end

function CSpeechCtrl.PlayWithPath(self, path)
	local err, oClip = self.m_AudioRecord:GetClipAmr(path)
	if oClip then
		self.m_CurPlayPath = path
		g_AudioCtrl:SoloClip(oClip, 0, callback(self, "OnPlayEnd"))
		self:OnEvent(define.Chat.Event.PlayAudio, self.m_PathKey[path])
	end
end


function CSpeechCtrl.AddPlayWithPath(self, path, bFirst)
	if bFirst then
		table.insert(self.m_PlayList, 1, path)
	else
		table.insert(self.m_PlayList, path)
	end
	self:PlayNext()
end

function CSpeechCtrl.IsPlay(self, key)
	local curKey = self.m_PathKey[self.m_CurPlayPath]
	if curKey then
		return key == curKey
	end
	return false
end

function CSpeechCtrl.AddPlayWithKey(self, key)
	local dSpeech = self:GetSpeech(key)
	if dSpeech then
		local function f(path)
			self:AddPlayWithPath(path)
		end
		if dSpeech.amr then
			self.m_PathKey[dSpeech.amr] = key
			f(dSpeech.amr)
		else
			self:DownloadFromServer(key,"amr",f)
		end
	end
end

function CSpeechCtrl.ClearPlayList(self)
	self.m_PlayList = {}
end

function CSpeechCtrl.OnPlayEnd(self)
	print("播放完毕->", self.m_CurPlayPath)
	local sKey = self.m_PathKey[self.m_CurPlayPath]
	self.m_CurPlayPath = nil
	self:OnEvent(define.Chat.Event.EndPlayAudio, sKey)
	self:PlayNext()
end

function CSpeechCtrl.PlayNext(self)
	if self.m_CurPlayPath then
		return
	end
	if next(self.m_PlayList) then
		local path = self.m_PlayList[1]
		table.remove(self.m_PlayList, 1)
		self.m_CurPlayPath = path
		self:PlayWithPath(path)
	end
end

return CSpeechCtrl