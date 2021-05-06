local CCtrlBase = class("CCtrlBase")

function CCtrlBase.ctor(self)
	self.m_RegDict = {}
	self.m_RegList = {}
	self.m_EventID = nil
	self.m_EventData = nil
	self.m_EventCached = {}
	self.m_UpdateTimer = nil
end

function CCtrlBase.Clear(self)
	self.m_RegDict = {}
	self.m_RegList = {}
	self.m_EventID = nil
	self.m_EventData = nil
end

--注册回调
function CCtrlBase.AddCtrlEvent(self, regid, callback)
	if not self.m_RegDict[regid] then
		table.insert(self.m_RegList, regid)
	end
	self.m_RegDict[regid] = callback
end

function CCtrlBase.DelCtrlEvent(self, regid)
	local idx = table.index(self.m_RegList, regid)
	if idx then
		table.remove(self.m_RegList, idx)
	end
	self.m_RegDict[regid] = nil
end

function CCtrlBase.Notify(self)
	local lDelete = {}
	for i, regid in ipairs(self.m_RegList) do
		local callback = self.m_RegDict[regid]
		if callback then
			local _, ret = xxpcall(callback, self)
			if ret == false then
				table.insert(lDelete, regid)
			end
		else
			table.insert(lDelete, regid)
		end
	end
	for i, regid in ipairs(lDelete) do
		self:DelCtrlEvent(regid)
	end
end

--触发回调
--有特殊需求, 继承类可自己实现
function CCtrlBase.OnEvent(self, iEventID, tEventData)
	self.m_EventID = iEventID
	self.m_EventData = tEventData
	self:Notify()
	self.m_EventID = nil
	self.m_EventData = nil
end

--延迟触发(默认一帧一次)
function CCtrlBase.DelayEvent(self, iEventID, tEventData, iDelayTime)
	if not self.m_UpdateTimer then
		self.m_UpdateTimer = Utils.AddTimer(callback(self, "UpdateEvent"), 0, 0)
	end
	iDelayTime = iDelayTime or 0
	self.m_EventCached[iEventID] = {data=tEventData, delay_time=iDelayTime}
end

function CCtrlBase.UpdateEvent(self, dt)
	for iEventID, dInfo in pairs(self.m_EventCached) do
		dInfo.delay_time = dInfo.delay_time - dt
		if dInfo.delay_time <= 0 then
			self.m_EventCached[iEventID]= nil
			self:OnEvent(iEventID, dInfo.data)
		end
	end

	return true
end

return CCtrlBase