--队伍对象管理
local TeamObj = require("src/layers/teamup/TeamObj")
-- local TeamSimple = require("src/layers/teamup/TeamSimple")

local TeamCtr = class("TeamCtr")

function TeamCtr:getMyTeam( ... )
	-- body
	if not G_TEAM_INFO then
		return
	end
	local oMyTeam = self:convert2TeamObj(G_TEAM_INFO)
	return oMyTeam
end

function TeamCtr:isCaptain( ... )
	-- body
	local oTeam = self:getMyTeam()
	if oTeam and oTeam:isCaptain() then
		return true
	end
	return false
end

--转换为teamobj对象
function TeamCtr:convert2TeamObj( stTeamInfo )
	-- body
	if not stTeamInfo then
		return
	end
	local oTeamObj = TeamObj.new(self.m_nTeamUid, stTeamInfo)
	self.m_nTeamUid = self.m_nTeamUid + 1
	return oTeamObj
end

function TeamCtr:ctor( ... )
	-- body
	self.m_stAllTeam = {}
	self.m_nTeamUid = 0

	self:addEvent()
end

function TeamCtr:addEvent( ... )
	-- body
end

function TeamCtr:removeEvent( ... )
	-- body
end

--第二个参数表明是否是详细队伍信息(简单队伍对象用TeamSimple,详细对象用TeamObj)
function TeamCtr:update( vAllTeam, bDetail )
	-- -- body
	-- self:reset()

	-- --这里读取服务器返回的列表然后解析

	-- for _,v in pairs(vAllTeam) do
	-- 	self:createTeam(v, bDetail)
	-- end
end

function TeamCtr:reset( ... )
	-- body
	self:clear()
end

function TeamCtr:createTeam( stInfo, bDetail )
	-- body
	local oTeamObj = nil
	if bDetail then
		oTeamObj =TeamObj.new(self.m_nTeamUid, stInfo)
	else
		oTeamObj =TeamSimple.new(self.m_nTeamUid, stInfo)
	end
	self.m_nTeamUid = self.m_nTeamUid + 1
	self:addTeamObj(oTeamObj)
end

function TeamCtr:addTeamObj( oTeamObj )
	-- body
	if not oTeamObj then
		return
	end
	local nUid = oTeamObj:getUid()
	self:removeTeamObj(nUid)
	self.m_stAllTeam[nUid] = oTeamObj
end

function TeamCtr:removeTeamObj( nUid )
	-- body
	local oTeamObj = self.m_stAllTeam[nUid]
	if oTeamObj then
		oTeamObj:dispose()
		self.m_stAllTeam[nUid] = nil
	end
end

function TeamCtr:clear( ... )
	-- body
	for nUid,oTeamObj in pairs(self.m_stAllTeam) do
		self:removeTeamObj(nUid)
	end
end

function TeamCtr:getAllTeam( ... )
	-- body
	local vAll = {}
	for nUid,oTeamObj in pairs(self.m_stAllTeam) do
		table.insert(vAll, oTeamObj)
	end

	return vAll
end

--打开附近队伍(包括删选目标)
function TeamCtr:openFindTeam( nTarget )
	-- body
	print("openTargetTeam", nTarget)
	G_TEAM_TARGET = nTarget or 1
	G_TEAM_TARGET = G_TEAM_TARGET + 1
 	__GotoTarget({ru = "a29", index = 4})
end

function TeamCtr:findRoleInTeam( nId )
	-- body
	if not nId then
		return
	end
	local t = G_TEAM_INFO.team_data
	if not t then
		return nil
	end
	for k,v in pairs(t) do
		print("roleId", v.roleId, nId)
		if v.roleId == nId then
			return v
		end
	end
end

function TeamCtr:tagReady( nRoleId, bReady )
	-- body
	local bOk = bReady
	if type(bReady) == "number" then
		if bReady == 0 then
			bOk = false
		else
			bOk = true
		end
	end
	local v = self:findRoleInTeam(nRoleId)
	print("tagReady", v, nRoleId)
	if not v then
		return
	end
	v.bReady = bOk
end

function TeamCtr:clearReadyTag( ... )
	-- body
	print("clearReadyTag")
	local t = G_TEAM_INFO.team_data
	if not t then
		return
	end
	for k,v in pairs(t) do
		v.bReady = false
	end
end

function TeamCtr:allMemReady( ... )
	-- body
	local t = G_TEAM_INFO.team_data
	if not t then
		return false
	end
	print("#t", #t)
	if #t <= 1 then
		return true
	end
	for k,v in pairs(t) do
		print("ttt", v.roleId, v.bReady)
		if v.bReady ~= true and v.roleId ~= userInfo.currRoleStaticId then
			return false
		end
	end
	return true
end

function TeamCtr:checkReady( ... )
	-- body
	print("checkReady", self:allMemReady())
	if self:allMemReady() then
		--清空ready标志，下次再用
		Event.Dispatch(EventName.AllReady)
	end
end

function TeamCtr:dispose( ... )
	-- body
	self:removeEvent()
end

return TeamCtr