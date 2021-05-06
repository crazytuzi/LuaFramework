local CAudioPlayer = class("CAudioPlayer", CObject)

function CAudioPlayer.ctor(self)
	local gameObject = UnityEngine.GameObject.New()
	CObject.ctor(self, gameObject)
	self.m_AudioSource = self:GetMissingComponent(classtype.AudioSource)
	self.m_Timer = nil
	self.m_StopPlayCb = nil
	self.m_FadePath = nil
	self.m_IsPlaying = false
	self.m_Path = nil
	self.m_IsLoading = false
	self.m_Length = 0
	self.m_Vol = self.m_AudioSource.volume
	self.m_Rate = 1 --游戏中设置的rate
	self.m_DefaultRate = 1 --默认的rate
	self.m_Pitch = self.m_AudioSource.pitch
	self.m_IsScaledTime = false
end

function CAudioPlayer.FadePlay(self, sPath)
	self.m_FadePath = sPath
	if self.m_Path == sPath then
		-- DOTween.DOKill(self.m_AudioSource, true)
	else
		self:UpdateDefaultRate(sPath, true)
		DOTween.DOKill(self.m_AudioSource, false)
		if self:IsPlaying() then
			local tween  = DOTween.DOFade(self.m_AudioSource, 0, 1.5)
			DOTween.SetEase(tween, enum.DOTween.Ease.Linear)
			DOTween.OnComplete(tween, callback(self, "FadeUp"))
		else
			self:FadeUp()
		end
	end
end

function CAudioPlayer.SetPitch(self, i)
	if self.m_Pitch ~= i then
		self.m_Pitch = i
		self.m_AudioSource.pitch = i
	end
end

function CAudioPlayer.FadeUp(self)
	if self.m_FadePath then
		self.m_AudioSource.volume = 0
		self:Play(self.m_FadePath)
		local tween  = DOTween.DOFade(self.m_AudioSource, self:GetRealVolume(), 2)
		DOTween.SetEase(tween, enum.DOTween.Ease.Linear)
		self.m_FadePath = nil
	end
end

function CAudioPlayer.UpdateDefaultRate(self, path, bFade)
	local dAudioData
	if path then
		local filename = IOTools.GetFileName(path, true)
		dAudioData = data.audiodata.DATA[filename]
	end
	
	if dAudioData then
		self.m_DefaultRate = dAudioData.defalut_rate
	else
		self.m_DefaultRate = 1
	end
	if bFade then
		self.m_AudioSource.volume = self.m_Vol * self.m_Rate * self.m_DefaultRate
	end
end

function CAudioPlayer.Play(self, sPath, bAsync)
	if self.m_Path == sPath then
		return
	end
	self.m_Path = sPath
	self:UpdateDefaultRate(sPath)
	self.m_IsLoading = true
	local cb = function(clip, path)
		self.m_IsLoading = false
		if clip and self.m_Path == path then
			self:SetClip(clip)
		end
	end
	if bAsync then
		g_ResCtrl:LoadAsync(sPath, cb)
	else
		g_ResCtrl:Load(sPath, cb)
	end
	
end

function CAudioPlayer.SetClip(self, clip)
	if self.m_AudioSource.clip then
		g_ResCtrl:DelManagedAsset(self.m_AudioSource.clip, self.m_GameObject)
	end
	if clip then
		g_ResCtrl:AddManageAsset(clip, self.m_GameObject, self.m_Path)
	end
	self.m_AudioSource.clip = clip
	self.m_Length = clip and clip.length or 0

	if self.m_AudioSource.clip then
		g_AudioCtrl:OnEvent(define.Audio.Event.LoadDone, self)
		self.m_AudioSource:Play()
		self.m_IsPlaying = true
	else
		self.m_IsPlaying = false
	end
	self:ResetTimer()
end

function CAudioPlayer.SetStopCb(self, cb)
	self.m_StopPlayCb = cb
end

function CAudioPlayer.IsPlaying(self)
	return self.m_IsPlaying
end

function CAudioPlayer.IsReuse(self)
	return not self:IsPlaying() and not self.m_IsLoading
end

function CAudioPlayer.SetLoop(self, bLoop)
	self.m_AudioSource.loop = bLoop
	self:ResetTimer()
end

function CAudioPlayer.GetLoop(self)
	return self.m_AudioSource.loop
end

function CAudioPlayer.ResetTimer(self)
	if self.m_Timer then
		Utils.DelTimer(self.m_Timer)
		self.m_Timer = nil
	end
	if self.m_AudioSource.clip and not self.m_Pause and not self:GetLoop() and self.m_Length > 0 then
		local time = self.m_Length - self.m_AudioSource.time
		if self.m_IsScaledTime then
			self.m_Timer = Utils.AddScaledTimer(callback(self, "OnStopPlay"), 0, time)
		else
			self.m_Timer = Utils.AddTimer(callback(self, "OnStopPlay"), 0, time)
		end
	end
end

function CAudioPlayer.SetScaledTime(self, b)
	self.m_IsScaledTime = b
end

function CAudioPlayer.Pause(self)
	self.m_Pause = true
	self.m_AudioSource:Pause()
	self:ResetTimer()
end

function CAudioPlayer.UnPause(self)
	self.m_Pause = false
	self.m_AudioSource:UnPause()
	self:ResetTimer()
end

function CAudioPlayer.OnStopPlay(self)
	if self.m_StopPlayCb then
		self.m_StopPlayCb(self)
	end
	self.m_Path = nil
	self:UpdateDefaultRate()
	self:SetClip(nil)
end

function CAudioPlayer.SetRate(self, i)
	self.m_Rate = i
	self.m_AudioSource.volume = self.m_Vol * self.m_Rate * self.m_DefaultRate
end

function CAudioPlayer.SetVolume(self, i)
	if self.m_FadeAction then
		self.m_FadeAction:Stop()
		g_ActionCtrl:DelAction(self.m_FadeAction)
		self.m_FadeAction = nil
	end
	self.m_Vol = i
	self.m_AudioSource.volume = i * self.m_Rate * self.m_DefaultRate
end

function CAudioPlayer.SetVolumeInFade(self, i)
	self.m_Vol = i
	self.m_AudioSource.volume = i * self.m_Rate * self.m_DefaultRate
end

function CAudioPlayer.SetVolumeFade(self, i, time)
	if self.m_FadeAction then
		self.m_FadeAction:Stop()
		g_ActionCtrl:DelAction(self.m_FadeAction)
		self.m_FadeAction = nil
	end
	time = time or 2
	self.m_FadeAction = CActionFloat.New(self, time, "SetVolumeInFade", self.m_Vol, i)	
	g_ActionCtrl:AddAction(self.m_FadeAction)
end

function CAudioPlayer.GetVolume(self)
	return self.m_Vol
end

function CAudioPlayer.GetRealVolume(self)
	return self.m_Vol * self.m_Rate * self.m_DefaultRate
end

function CAudioPlayer.Stop(self, noCb)
	self.m_AudioSource:Stop()
	if self.m_FadeAction then
		self.m_FadeAction:Stop()
		g_ActionCtrl:DelAction(self.m_FadeAction)
		self.m_FadeAction = nil
	end
	if not noCb then
		if self.m_Timer then
			Utils.DelTimer(self.m_Timer)
			self.m_Timer = nil
		end
		self:OnStopPlay()
	end
end

return CAudioPlayer