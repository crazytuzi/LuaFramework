--最详细的队伍对象
local TeamObj = class("TeamObj")
local TeamMemObj = require("src/layers/teamup/TeamMemObj")
function TeamObj:ctor( nUid, stInfo )
	-- body
	self.m_nUid = nUid

	self.m_stAllMem = {}
	self.m_nMemUid = 0
	self.m_nMaxNum = 10

	self:update(stInfo)
end
--[[
	optional bool hasTeam = 1;
	optional int32 teamId = 2;
	optional int32 memCnt = 3;
	repeated SimpleInfo infos = 4;
	optional int32 memCount1 = 5; 			//hurt add
	optional int32 memCount2 = 6; 			//exp add
	optional int32 teamTarget = 7;
]]
function TeamObj:update( stInfo )
	-- body
	self:reset()

	self.m_bHasTeam = stInfo.hasTeam or stInfo.has_team
	self.m_nTeamId = stInfo.teamId or stInfo.teamID
	self.m_nMemCnt = stInfo.memCnt
	self.m_nMemCnt1 = stInfo.memCount1 or stInfo.hurtAdd
	self.m_nMemCnt2 = stInfo.memCount2 or stInfo.expAdd
	self.m_nTeamTarget = stInfo.teamTarget


	self.m_oCaptain = nil
	local vMems = stInfo.infos or stInfo.team_data
	for i,v in ipairs(vMems) do
		local oMem = self:createMem(v)
		if i == 1 then
			oMem:setCaptain(true)
			self.m_oCaptain = oMem
		end
	end


end

function TeamObj:reset( ... )
	-- body
	self:clear()
end

--是否满了
function TeamObj:isFull( ... )
	-- body
	return self.m_nMemCnt >= self.m_nMaxNum
end

--队长是否是某人
function TeamObj:isCaptain( nId )
	-- body
	nId = nId or userInfo.currRoleStaticId
	if not self.m_oCaptain then
		return false
	end
	local nCapId = self.m_oCaptain:getRoleId()
	print("isCaptain", nCapId, nId)
	return nCapId == nId
end

--获取队长名字
function TeamObj:getLeaderName( ... )
	-- body
	if not self.m_oCaptain then
		return ""
	end
	local strName = self.m_oCaptain:getName()
	return strName
end

--获取队长战斗力
function TeamObj:getLeaderBattle( ... )
	-- body
	if not self.m_oCaptain then
		return
	end
	local nBattle = self.m_oCaptain:getBattleNum()
	return nBattle
end

--获取队长对象
function TeamObj:getLeader( ... )
	-- body
	return self.m_oCaptain
end

function TeamObj:hasTeam( ... )
	-- body
	return self.m_bHasTeam
end

function TeamObj:getTeamId( ... )
	-- body
	return self.m_nTeamId
end

function TeamObj:getMemCnt( ... )
	-- body
	return self.m_nMemCnt
end

function TeamObj:getMemCnt1( ... )
	-- body
	return self.m_nMemCnt1
end

function TeamObj:getMemCnt2( ... )
	-- body
	return self.m_nMemCnt2
end

function TeamObj:getTeamTarget( ... )
	-- body
	return self.m_nTeamTarget
end

function TeamObj:createMem( stInfo )
	-- body
	print("createMem", stInfo)
	local oMemObj = TeamMemObj.new(self.m_nMemUid, stInfo)
	self.m_nMemUid = self.m_nMemUid + 1
	self:addMemObj(oMemObj)
	return oMemObj
end

function TeamObj:addMemObj( oMemObj )
	-- body
	if not oMemObj then
		return
	end
	local nUid = oMemObj:getUid()
	self:removeMemObj(nUid)
	self.m_stAllMem[nUid] = oMemObj
end

function TeamObj:removeMemObj( nUid )
	-- body
	local oMemObj = self.m_stAllMem[nUid]
	if oMemObj then
		oMemObj:dispose()
		self.m_stAllMem[nUid] = nil
	end
end

function TeamObj:clear( ... )
	-- body
	for nUid,oMemObj in pairs(self.m_stAllMem) do
		self:removeMemObj(nUid)
	end
end

function TeamObj:getAllMem( ... )
	-- body
	local vAll = {}
	for nUid,oMemObj in pairs(self.m_stAllMem) do
		table.insert(vAll, oMemObj)
	end

	return vAll
end

function TeamObj:getUid( ... )
	-- body
	return self.m_nUid
end

function TeamObj:dispose( ... )
	-- body
end

return TeamObj