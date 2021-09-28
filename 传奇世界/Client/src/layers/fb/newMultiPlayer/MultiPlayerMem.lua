--Author:		bishaoqing
--DateTime:		2016-05-31 13:12:17
--Region:		多人守卫队伍详细信息
local MultiPlayerMem = class("MultiPlayerMem")
--[[
message CopyMemberInfo
{
	optional int32 memberId = 1;
	optional string memberName = 2;
	optional int32 memberBattle = 3;
	optional bool memberStatus = 4;
	optional int32 memberSchool = 5;
	optional int32 memberSex = 6;
}
]]
function MultiPlayerMem:ctor( nUid )
	-- body
	self.m_nUid = nUid
end

function MultiPlayerMem:reset( stInfo )
	-- body
	self.m_nMemberId = stInfo.memberId
	self.m_sMemberName = stInfo.memberName
	self.m_nMemberBattle = stInfo.memberBattle
	self.m_bMemberStatus = stInfo.memberStatus
	self.m_nMemberSchool = stInfo.memberSchool
	self.m_nMemberSex = stInfo.memberSex
end

function MultiPlayerMem:setIsCaptain( bCaptain )
	-- body
	self.m_bIsCaptain = bCaptain
end

function MultiPlayerMem:getIsCaptain( ... )
	-- body
	return self.m_bIsCaptain
end

function MultiPlayerMem:getMemberId( ... )
	-- body
	return self.m_nMemberId
end

function MultiPlayerMem:getMemberName( ... )
	-- body
	return self.m_sMemberName
end

function MultiPlayerMem:getMemberBattle( ... )
	-- body
	return self.m_nMemberBattle
end

function MultiPlayerMem:getMemberStatus( ... )
	-- body
	return self.m_bMemberStatus
end

function MultiPlayerMem:getMemberSchool( ... )
	-- body
	return self.m_nMemberSchool
end

function MultiPlayerMem:getMemberSex( ... )
	-- body
	return self.m_nMemberSex
end

function MultiPlayerMem:getUid( ... )
	-- body
	return self.m_nUid
end

function MultiPlayerMem:dispose( ... )
	-- body
end

return MultiPlayerMem