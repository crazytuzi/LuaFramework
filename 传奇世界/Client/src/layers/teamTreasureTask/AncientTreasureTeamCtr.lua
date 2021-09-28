--Author:		bishaoqing
--DateTime:		2016-05-13 15:07:35
--Region:		远古宝藏组队管理
local AncientTreasureTeamCtr = class("AncientTreasureTeamCtr")

function AncientTreasureTeamCtr:ctor( ... )
	-- body
	self.m_stAllTeams = {}
	self.m_iTeamUid = 0
	self:AddEvent()
end

--设置监听
function AncientTreasureTeamCtr:AddEvent( ... )
	-- body
	g_msgHandlerInst:registerMsgHandler(TASK_SC_GET_SHARED_TASK_RET, handler(self, self.OnTeamRev))
end

--取消监听
function AncientTreasureTeamCtr:RemoveEvent( ... )
	-- body
	g_msgHandlerInst:registerMsgHandler(TASK_SC_GET_SHARED_TASK_RET, nil)
end

--服务器返回
function AncientTreasureTeamCtr:OnTeamRev( sBuffer )
	-- body
	local stProto = g_msgHandlerInst:convertBufferToTable("GetSharedTaskListRetProtocol", sBuffer) 
	if stProto then
		self:Reset(stProto.infos)
	end

	Event.Dispatch(EventName.UpdateTeam)
end

--向服务器请求获取队伍
function AncientTreasureTeamCtr:GetTeamsFromServer( ... )
	-- body
	local t = {}
	g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_GET_SHARED_TASK_LIST, "GetSharedTaskListProtocol", t)
end

--申请加入队伍
function AncientTreasureTeamCtr:Apply( oTeam )
	-- body
	local nSid = oTeam:GetSid()
	local strCapName = oTeam:GetName()
	local nCapLevel = oTeam:GetLevel()
	local nTaskRank = oTeam:GetTaskRank()
	
	local t = {}
	t.roleSid = nSid
	t.taskRank = nTaskRank
	g_msgHandlerInst:sendNetDataByTableExEx(TASK_CS_REQ_ADD_SHARED_TASK_TEAM, "RequestAddToSharedTaskTeamProtocol", t)
end

--重新解析
function AncientTreasureTeamCtr:Reset( vInfo )
	-- body
	self:Clear()
	if not vInfo then
		return
	end
	for _,stInfo in ipairs(vInfo) do
		local oTeam = self:CreateTeam(stInfo)
		if oTeam then
			self:AddCach(oTeam)
		end
	end
end

--创建team对象，uid从1开始
function AncientTreasureTeamCtr:CreateTeam( stInfo )
	-- body
	if not stInfo then
		return
	end
	self.m_iTeamUid = self.m_iTeamUid + 1
	return GetAncientTreasureTeam().new(self.m_iTeamUid, stInfo)
end

--添加缓存
function AncientTreasureTeamCtr:AddCach( oTeam )
	-- body
	if not oTeam then
		return
	end
	local iUid = oTeam:GetUid()
	if iUid then
		self.m_stAllTeams[iUid] = oTeam
	end
end

--删除缓存
function AncientTreasureTeamCtr:RemoveCach( iUid )
	-- body
	if not iUid then
		return
	end
	local oTeam = self.m_stAllTeams[iUid]
	if oTeam then
		oTeam:Dispose()
		self.m_stAllTeams[iUid] = nil
	end
end

--获取缓存
function AncientTreasureTeamCtr:GetCach( iUid )
	-- body
	if not iUid then
		return
	end
	return self.m_stAllTeams[iUid]
end

--清空缓存
function AncientTreasureTeamCtr:Clear( ... )
	-- body
	for k,v in pairs(self.m_stAllTeams) do
		v:Dispose()
		self.m_stAllTeams[k] = nil
	end
end

--获取全部缓存(自己的缓存是map，返回出去的是vector)
function AncientTreasureTeamCtr:GetAllCach( bSort, funSortFun )
	-- body
	local vRet = {}
	if self.m_stAllTeams then
		for iUid,oTeam in pairs(self.m_stAllTeams) do
			table.insert(vRet, oTeam)
		end
	end
	--如果需要排序就排
	if bSort then
		if funSortFun then
			table.sort(vRet, funSortFun)
		else
			table.sort(vRet, handler(self, self.DefaultSort))
		end
	end
	return vRet
end

local iNull = 9999
--默认排序，按照uid从小到大
function AncientTreasureTeamCtr:DefaultSort( a, b )
	-- body
	local iUidA = a:GetUid() or iNull
	local iUidB = b:GetUid() or iNull
	return iUidA < iUidB
end

function AncientTreasureTeamCtr:Dispose( ... )
	-- body
	self:RemoveEvent()
end

return AncientTreasureTeamCtr