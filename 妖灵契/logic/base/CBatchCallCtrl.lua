local CBatchCallCtrl = class("CBatchCallCtrl")

function CBatchCallCtrl.ctor(self)
	self.m_CallInfos = {} --参数过多unpack会报错,所以分开存
	self.m_MaxArgsCnt = 200
	local obj = UnityEngine.GameObject.Find("GameRoot/BatchCall")
	self.m_RenderObjectHandler = obj:GetMissingComponent(classtype.RenderObjectHandler)
	self.m_HudHandler = obj:GetMissingComponent(classtype.HudHandler)
end

function CBatchCallCtrl.GetCallInfo(self, objtype, iCnt)
	local list = self.m_CallInfos[objtype] or {}
	local len = #list
	local dCallInfo
	if len > 0 then
		dCallInfo = list[len]
		if dCallInfo.arg_cnt + iCnt > self.m_MaxArgsCnt then
			dCallInfo = self:NewCallInfo(objtype)
			list[len + 1] = dCallInfo
		end
	else
		dCallInfo = self:NewCallInfo(objtype)
		list[1] = dCallInfo
	end
	self.m_CallInfos[objtype] = list
	return dCallInfo
end

function CBatchCallCtrl.NewCallInfo(self, objtype)
	local dCallInfo = {call_cnt=0, args = {}, arg_cnt=0}
	if objtype == enum.BatchCall.ObjType.RenderObjectHandler then
		dCallInfo.handler = self.m_RenderObjectHandler
	elseif objtype == enum.BatchCall.ObjType.HudHandler then
		dCallInfo.handler = self.m_HudHandler
	end
	return dCallInfo
end

function CBatchCallCtrl.PushCallData(self, objtype, objid, functype, ...)
	local iArgCnt = select("#", ...)
	local iTotal = iArgCnt + 2
	local dCallInfo = self:GetCallInfo(objtype, iTotal)
	table.insert(dCallInfo.args, objid)
	table.insert(dCallInfo.args, functype)
	local iCurIdx = #dCallInfo.args
	for i=1, iArgCnt do
		dCallInfo.args[iCurIdx + i] = select(i, ...)
	end
	dCallInfo.arg_cnt = dCallInfo.arg_cnt + iTotal
	dCallInfo.call_cnt = dCallInfo.call_cnt + 1
end

function CBatchCallCtrl.BatchCall(self)
	for k, list in pairs(self.m_CallInfos) do
		for _, dCallInfo in ipairs(list) do
			dCallInfo.handler.BatchCall(dCallInfo.call_cnt, unpack(dCallInfo.args))
		end
		self.m_CallInfos[k] = {}
	end
end

return CBatchCallCtrl