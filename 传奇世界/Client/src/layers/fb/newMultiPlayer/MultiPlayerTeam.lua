--Author:		bishaoqing
--DateTime:		2016-05-31 14:06:49
--Region:		多人组队一般队伍对象
local MultiPlayerTeam = class("MultiPlayerTeam")
--[[
message CopyTeamInfo
{
	optional int32 teamId = 1;
	optional string leaderName = 2;
	optional int32 createTime = 3;
	optional int32 memberCnt = 4;
	optional int32 leaderBattle = 5;
}
]]
function MultiPlayerTeam:ctor( nUid )
	-- body
	self.m_nUid = nUid
end

function MultiPlayerTeam:reset( stInfo )
	-- body
	self.m_stInfo = stInfo
	self.m_nTeamId = stInfo.teamId
	self.m_sLeaderName = stInfo.leaderName
	self.m_nCreateTime = stInfo.createTime
	self.m_nMemberCnt = stInfo.memberCnt
	self.m_nLeaderBattle = stInfo.leaderBattle
end

function MultiPlayerTeam:getLeaderBattle( ... )
	-- body
	return self.m_nLeaderBattle
end

function MultiPlayerTeam:getUid( ... )
	-- body
	return self.m_nUid
end

function MultiPlayerTeam:getInfo( ... )
	-- body
	return self.m_stInfo
end

function MultiPlayerTeam:getTeamId( ... )
	-- body
	return self.m_nTeamId
end

function MultiPlayerTeam:getLeaderName( ... )
	-- body
	return self.m_sLeaderName
end

function MultiPlayerTeam:getCreateTime( ... )
	-- body
	return self.m_nCreateTime
end

function MultiPlayerTeam:getMemberCnt( ... )
	-- body
	return self.m_nMemberCnt
end

function MultiPlayerTeam:dispose( ... )
	-- body
end

return MultiPlayerTeam