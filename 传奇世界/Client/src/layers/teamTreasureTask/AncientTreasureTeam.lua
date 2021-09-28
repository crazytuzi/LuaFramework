--Author:		bishaoqing
--DateTime:		2016-05-13 15:03:14
--Region:		远古宝藏队伍对象
local AncientTreasureTeam = class("AncientTreasureTeam")

--[[stInfo格式:
message SharedTaskInfo
{
	optional string name = 1;
	optional int32 roleSid = 2;
	optional int32 level = 3;
	optional int32 taskRank = 4;
	optional int32 taskStatus = 5;
}--]]
function AncientTreasureTeam:ctor( iUid, stInfo )
	-- body
	self.m_iUid = iUid
	

	self:Reset(stInfo)
end

--初始化成员变量
function AncientTreasureTeam:Reset( stInfo )
	-- body
	self.m_stInfo = stInfo
	self.m_sName = stInfo.name
	self.m_nSid = stInfo.roleSid
	self.m_nLevel = stInfo.level
	self.m_nTaskRank = stInfo.taskRank
	self.m_nTaskStatus = stInfo.taskStatus
end

--获取唯一id
function AncientTreasureTeam:GetUid( ... )
	-- body
	return self.m_iUid
end

--获取参数设置
function AncientTreasureTeam:GetInfo( ... )
	-- body
	return self.m_stInfo
end

function AncientTreasureTeam:GetName( ... )
	-- body
	return self.m_sName
end

function AncientTreasureTeam:GetSid( ... )
	-- body
	return self.m_nSid
end

function AncientTreasureTeam:GetLevel( ... )
	-- body
	return self.m_nLevel
end

function AncientTreasureTeam:GetTaskRank( ... )
	-- body
	return self.m_nTaskRank
end

function AncientTreasureTeam:GetTaskStatus( ... )
	-- body
	return self.m_nTaskStatus
end

function AncientTreasureTeam:Dispose( ... )
	-- body
end

return AncientTreasureTeam