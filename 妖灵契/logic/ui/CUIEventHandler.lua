local CUIEventHandler = class("CUIEventHandler")
function CUIEventHandler.ctor(self, obj)
	self.m_EventGo = obj

	self.m_UIEventHandler = nil
	self.m_CallbackDict = {}

	self.m_LongPressInfo = {
		has_trigger = nil,
		timer = nil,
		left_trigger_time = nil,
		total_trigger_time = 0.3,
		has_anim = nil,
		need_anim = false,
		check_anim_func = nil,
	}

	self.m_RepeatPressTimer = nil
	self.m_RepeatDelta= 0.2
	self.m_DoubleClickTimer = nil
	self.m_ClickCachedCnt = 0

	self.m_LastClickFrame = nil
	self.m_CurClickFrame = nil
	self.m_DoubleClickFrame = nil
	self.m_Delegate = nil
	-- 点击是否销毁特效
	self.m_IgnoreCheckEffect = false

	self.m_ClickSoundPath = define.Audio.SoundPath.Btn
end

function CUIEventHandler.SetLongPressTime(self, iTime)
	self.m_LongPressInfo.total_trigger_time = iTime
end

function CUIEventHandler.SetLongPressAnim(self, bAnim, func)
	self.m_LongPressInfo.need_anim = bAnim
	self.m_LongPressInfo.check_anim_func = func
end

function CUIEventHandler.SetClickSounPath(self, sPath)
	self.m_ClickSoundPath = sPath
end

function CUIEventHandler.PlayUISound(self, iEvent)
	if iEvent == enum.UIEvent["click"] then
		g_AudioCtrl:PlaySound(self.m_ClickSoundPath)
	end
end


function CUIEventHandler.AddUIEventHandler(self)
	if not self.m_UIEventHandler then
		self.m_UIEventHandler = self.m_EventGo:GetMissingComponent(classtype.UIEventHandler)
	end
	if not self.m_Delegate then
		self.m_Delegate = g_DelegateCtrl:NewDelegate(callback(self, "Notify"))
		self.m_UIEventHandler:SetEventID(self.m_Delegate:GetID())
	end
end

function CUIEventHandler.InitUIEventHandler(self)
	if not self.m_UIEventHandler then
		self.m_UIEventHandler = self.m_EventGo:GetComponent(classtype.UIEventHandler)
	end
	if not self.m_Delegate then
		self.m_Delegate = g_DelegateCtrl:NewDelegate(callback(self, "Notify"))
		self.m_UIEventHandler:SetEventID(self.m_Delegate:GetID())
	end
end

function CUIEventHandler.SetRepeatDelta(self, iDelta)
	self.m_RepeatDelta = iDelta
end

function CUIEventHandler.AddUIEvent(self, sEvent, func)
	-- do return end
	self:InitUIEventHandler()
	local iEvent = enum.UIEvent[sEvent]
	self.m_CallbackDict[iEvent] = func
	if sEvent == "longpress" or sEvent == "repeatpress" then
		self.m_UIEventHandler:AddEventType(enum.UIEvent["press"])
	else
		self.m_UIEventHandler:AddEventType(iEvent)
	end
end

function CUIEventHandler.UIEventCheckEffect(self, iEvent)
	if self.m_IgnoreCheckEffect then
		return
	end
	if iEvent == enum.UIEvent["press"] or 
		iEvent == enum.UIEvent["click"] then
		self:ClickClearEffect()
	end
end

function CUIEventHandler.Notify(self, iEvent, ...)
	self:UIEventCheckEffect(iEvent)
	if self:CommonExtendEvent(iEvent, ...) then
		return
	end
	if self:SpecialExtendEvent(iEvent, ...) then
		return
	end
	local func = self.m_CallbackDict[iEvent]
	if func then
		local ret = func(self, ...)
		self:PlayUISound(iEvent)
		if ret == false then
			self.m_CallbackDict[iEvent] = nil
			self.m_UIEventHandler:DelEventType(iEvent)
		end
		return ret
	end
end

function CUIEventHandler.CommonExtendEvent(self, iEvent, ...)
	if iEvent == enum.UIEvent["press"] then
		local bPress = select(1, ...)
		if self:RepeatPressCheck(bPress) then
			return true
		end
		if self.m_CallbackDict[enum.UIEvent["longpress"]] then
			self:LongPressCheckBegin(bPress)
		end
	end
	if iEvent == enum.UIEvent["click"] then
		if self.m_DoubleClickFrame == UnityEngine.Time.frameCount then
			return true
		end
		self.m_LastClickFrame = self.m_CurClickFrame
		self.m_CurClickFrame = UnityEngine.Time.frameCount
		if self.m_LongPressInfo.has_trigger then
			return true
		end
		if self.m_RepeatTimer then
			return true
		end
		if self.m_CallbackDict[enum.UIEvent["doubleclick"]] then
			if not self.m_DoubleClickTimer then
				self.m_DoubleClickTimer = Utils.AddTimer(callback(self, "DoubleClickFail"), 0, 0.36)
				self.m_ClickCachedCnt = 1
			else
				self.m_ClickCachedCnt = self.m_ClickCachedCnt + 1
			end
			return true
		end
	elseif iEvent == enum.UIEvent["doubleclick"] then
		if self.m_DoubleClickTimer then
			self.m_DoubleClickFrame = UnityEngine.Time.frameCount
			Utils.DelTimer(self.m_DoubleClickTimer)
			self.m_DoubleClickTimer = nil
		else
			return true
		end
	end
	return false
end

function CUIEventHandler.DoubleClickFail(self)
	local func = self.m_CallbackDict[enum.UIEvent["click"]]
	if func then
		for i=1, self.m_ClickCachedCnt do
			func(self)
		end
	end
	self.m_DoubleClickTimer = nil
end

function CUIEventHandler.SpecialExtendEvent(self, iEvent, ...)
	return false
end

function CUIEventHandler.StopLongPress(self)
	if self.m_LongPressInfo.timer then
		g_NotifyCtrl:HideLongPressAni()
		Utils.DelTimer(self.m_LongPressInfo.timer)
		self.m_LongPressInfo.timer = nil
	end
	self.m_LongPressInfo.left_trigger_time = nil
	self.m_LongPressInfo.has_anim = nil
end

function CUIEventHandler.LongPressCheckBegin(self, bPress)
	self:StopLongPress()
	if bPress then
		if self.m_LongPressInfo.has_trigger then
			return
		end
		--长按动画
		self.m_LongPressInfo.has_trigger = false
		self.m_LongPressInfo.ori_pos = self:GetPos()
		self.m_LongPressInfo.left_trigger_time = self.m_LongPressInfo.total_trigger_time
		self.m_LongPressInfo.timer = Utils.AddTimer(callback(self, "LongPressCheck"), 0, 0)
	else
		if self.m_LongPressInfo.has_trigger then
			Utils.AddTimer(function() self.m_LongPressInfo.has_trigger = false end, 0, 0)
			self:Notify(enum.UIEvent["longpress"], false)
		end
	end
end

function CUIEventHandler.LongPressCheck(self, dt)
	if Vector3.Distance(self.m_LongPressInfo.ori_pos, self:GetPos()) > 0.001 then
		self:StopLongPress()
		return false
	end
	self.m_LongPressInfo.left_trigger_time = self.m_LongPressInfo.left_trigger_time - dt
	if self.m_LongPressInfo.left_trigger_time <= 0 then
		if self.m_GameObject == g_CameraCtrl:GetNGUICamera().selectedObject then
			self:Notify(enum.UIEvent["longpress"], true)
		end
		self.m_LongPressInfo.has_trigger = true
		self:StopLongPress()
		return false
	elseif self.m_LongPressInfo.need_anim and not self.m_LongPressInfo.has_anim then
		local func = self.m_LongPressInfo.check_anim_func
		if not func or func(self) then
			if self.m_LongPressInfo.left_trigger_time <= (self.m_LongPressInfo.total_trigger_time*0.6) then
				self.m_LongPressInfo.has_anim = true
				local pos = g_CameraCtrl:GetNGUICamera().lastWorldPosition
				g_NotifyCtrl:ShowLongPressAni(pos, self.m_LongPressInfo.total_trigger_time*0.6)
			end
		end
	end
	return true
end

function CUIEventHandler.RepeatPressCheck(self, bPress)
	local func = self.m_CallbackDict[enum.UIEvent.repeatpress]
	if func then
		if bPress then
			if not self.m_RepeatTimer then
				local function repeatcall()
					func(self, bPress)
					return true
				end
				self.m_RepeatTimer = Utils.AddTimer(repeatcall, self.m_RepeatDelta, 0)
			end
		else
			if self.m_RepeatTimer then
				Utils.DelTimer(self.m_RepeatTimer)
				func(self, bPress)
				
				Utils.AddTimer(function() self.m_RepeatTimer = nil end, 0, 0)
			end
		end
		return true
	end
	return false
end
return CUIEventHandler