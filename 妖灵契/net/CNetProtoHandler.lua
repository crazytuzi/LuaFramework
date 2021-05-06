local CNetProtoHandler = class("CNetProtoHandler")
CNetProtoHandler.g_Open = true
--GS2CHeartBeat, GS2CSessionResponse
CNetProtoHandler.g_PriorType = {3001, 3008}

function CNetProtoHandler.ctor(self)
	self.m_ProtoList = {} -- 等待执行的队列
	self.m_SendList = {}
	self.m_MaxTime = 200--ms
	self.m_CostTime = 0
	self.m_LastCostFrame = UnityEngine.Time.frameCount
end

function CNetProtoHandler.Clear(self)
	self.m_CostTime = 0
	self.m_ProtoList = {} 
end

function CNetProtoHandler.IsPriorType(self, iPbType)
	return table.index(CNetProtoHandler.g_PriorType, iPbType) ~= nil
end

function CNetProtoHandler.SetMaxTime(self, iTime)
	self.m_MaxTime = iTime
end

function CNetProtoHandler.ResetCostTime(self)
	self.m_CostTime = 0
end

function CNetProtoHandler.CostTime(self, iTime)
	if CNetProtoHandler.g_Open  then
		if self.m_LastCostFrame ~= UnityEngine.Time.frameCount  then
			self.m_LastCostFrame =  UnityEngine.Time.frameCount 
			self:ResetCostTime()
		end
		self.m_CostTime = self.m_CostTime + iTime
	end
end

function CNetProtoHandler.IsCanProcess(self)
	if CNetProtoHandler.g_Open then
		if g_MapCtrl:IsLoading() then
			return false
		end
		if self.m_LastCostFrame ~= UnityEngine.Time.frameCount  then
			self:ResetCostTime()
		end
		return self.m_CostTime < self.m_MaxTime
	else
		return true
	end
end

function CNetProtoHandler.IsEmpty(self)
	if CNetProtoHandler.g_Open then 
		return next(self.m_ProtoList) == nil
	else
		return true
	end
end

function CNetProtoHandler.PushProto(self, iPbType, sData)
	table.insert(self.m_ProtoList, {iPbType, sData})
end

function CNetProtoHandler.PopProto(self)
	local dProto = self.m_ProtoList[1]
	if dProto then
		table.remove(self.m_ProtoList, 1)
		return unpack(dProto, 1, 2)
	end
end

function CNetProtoHandler.PushSendData(self, sData)
	table.insert(self.m_SendList, sData)
end

function CNetProtoHandler.ProcessSendList(self, oNetObj)
	if oNetObj and next(self.m_SendList) then
		oNetObj:BatchSend(#self.m_SendList, self.m_SendList)
	end
	self.m_SendList = {}
end

return CNetProtoHandler