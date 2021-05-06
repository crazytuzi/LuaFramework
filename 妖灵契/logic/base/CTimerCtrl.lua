local CTimerCtrl = class("CTimerCtrl")
local tinsert = table.insert
local tremove = table.remove
local ipairs = ipairs

function CTimerCtrl.ctor(self)
	self.m_TimerDict = {}
	self.m_TimerIDList = {}
	self.m_LateTimerIDList = {}
end

function CTimerCtrl.AddTimer(self, cbfunc, delta, delay, unsacled, lateupdate)
	local iTimerID = Utils.GetUniqueID()
	local iElapsed = unsacled and UnityEngine.Time.unscaledTime or UnityEngine.Time.time
	self.m_TimerDict[iTimerID] = {
		cbfunc = cbfunc,
		delta = delta,
		delay = delay,
		next_call_time = iElapsed + delay,
		last_call_time = iElapsed,
		add_frame = UnityEngine.Time.frameCount,
		unsacled = unsacled,
	}

	if lateupdate then
		tinsert(self.m_LateTimerIDList, iTimerID)
	else
		tinsert(self.m_TimerIDList, iTimerID)
	end
	return iTimerID
end

function CTimerCtrl.DelTimer(self, iTimerID)
	self.m_TimerDict[iTimerID] = nil
end

function CTimerCtrl.UpdateList(self, list)
	if not next(list) then
		return
	end
	local lDel = {}
	local iFrameCount = UnityEngine.Time.frameCount
	local iUnscaledTime = UnityEngine.Time.unscaledTime
	local iTime = UnityEngine.Time.time
	for i, id in ipairs(list) do
		local v = self.m_TimerDict[id]
		if v then 
			local iElapsed = v.unsacled and iUnscaledTime or iTime
			if v.add_frame ~= iFrameCount and (iElapsed - v.next_call_time) >= -0.005 then
				local callDelta = iElapsed - v.last_call_time
				local sucess, ret = xxpcall(v.cbfunc, callDelta)
				if sucess and ret == true then
					v.last_call_time = iElapsed
					v.next_call_time = iElapsed + v.delta
				else
					tinsert(lDel, i)
					self.m_TimerDict[id] = nil
				end
			end
		else
			tinsert(lDel, i)
		end
	end
	for j=#lDel, 1, -1 do
		tremove(list, lDel[j])
	end
end

function CTimerCtrl.Update(self)
	self:UpdateList(self.m_TimerIDList)
end

function CTimerCtrl.LateUpdate(self)
	self:UpdateList(self.m_LateTimerIDList)
end

return CTimerCtrl