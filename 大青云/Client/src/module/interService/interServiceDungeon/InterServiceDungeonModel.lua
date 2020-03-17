--[[
跨服副本
liyuan

]]

_G.InterServiceDungeonModel = Module:new();

-------------------------------------------------------------
InterServiceDungeonModel.teamId = nil;
InterServiceDungeonModel.memberList = {};

--添加一个队员
function InterServiceDungeonModel:AddMember(memberVO)
	local numMembers = self:GetMemberNum();
	if numMembers < TeamConsts.MemberCeiling then
		local index = InterServiceDungeonModel:CalcIndex();
		memberVO.index = index;
		self.memberList[index] = memberVO;
		self:sendNotification( NotifyConsts.TeamMemberAdd, index );
	end
	if numMembers == 0 then
		self:CreateTeam(memberVO.teamId);
	end
	self:ChangeNearbyPlayerState( memberVO.roleID, TeamConsts.InTeam );
	return memberVO;
end

-- 根据玩家id移除一个队员
function InterServiceDungeonModel:RemoveMemberById(playerId)
	local memberVO = self:GetMemberById(playerId);
	if memberVO then
		--如果移除队员是自己，执行退出队伍
		if playerId == MainPlayerController:GetRoleID() then
			self:QuitTeam();
		--否则移除队员
		else
			self:RemoveMember( memberVO.index );
		end
		return memberVO;
	end
	return nil;
end

-- 更新玩家信息
function InterServiceDungeonModel:UpdateMember(playerId, info)
	local memberVO = self:GetMemberById(playerId);
	if not memberVO then return; end
	local appearanceChanged = false;
	local index = memberVO.index;
	for attrName, attrValue in pairs(info) do
		if memberVO[attrName] ~= attrValue then
			memberVO[attrName] = attrValue;
			if TeamUtils:IsAppearance(attrName) then
				appearanceChanged = true;
			end
			self:sendNotification( NotifyConsts.MemberChange, { index = index, attrType = attrName, attrValue = attrValue } );
		end
	end
	if appearanceChanged then
		self:sendNotification( NotifyConsts.MemberAppearanceChange, index );
	end
end

--是否是有队伍状态
function InterServiceDungeonModel:IsInTeam()
	return self.teamId ~= nil;
end

--获取队长ID
function InterServiceDungeonModel:GetCaptainId()
	for index, memberVO in pairs(self.memberList) do
		if memberVO.teamPos == TeamConsts.PosCaptain then
			return memberVO.roleID;
		end
	end
end

--获取队长信息
function InterServiceDungeonModel:GetCaptainInfo()
	for index, memberVO in pairs(self.memberList) do
		if memberVO.teamPos == TeamConsts.PosCaptain then
			return memberVO;
		end
	end
end

--获取队长玩家索引
function InterServiceDungeonModel:GetCaptainIndex()
	for index, memberVO in pairs(self.memberList) do
		if memberVO.teamPos == TeamConsts.PosCaptain then
			return memberVO.index;
		end
	end
end

--获取队友列表
function InterServiceDungeonModel:GetMemberList()
	return self.memberList;
end

--根据id获取队员名字
function InterServiceDungeonModel:GetMemberName(playerId)
	local memberVO = self:GetMemberById(playerId);
	return memberVO and memberVO.roleName;
end

--获取队伍人数
function InterServiceDungeonModel:GetMemberNum()
	return getTableLen(self.memberList);
end

--获取主玩家在队伍中的索引
function InterServiceDungeonModel:GetMainPlayerIndex()
	local mainPlayerId = MainPlayerController:GetRoleID();
	local memberVO = InterServiceDungeonModel:GetMemberById(mainPlayerId)
	return memberVO and memberVO.index;
end

--根据index获取队员vo
function InterServiceDungeonModel:GetMember(index)
	return self.memberList[index];
end

--根据index获取玩家Id
function InterServiceDungeonModel:GetMemberIdByIndex(index)
	local memberVO = self.memberList[index];
	return memberVO and memberVO.roleID;
end

--判断某个玩家是不是队友
function InterServiceDungeonModel:IsTeammate(playerId)
	return self:GetMemberById(playerId) ~= nil;
end


-------------------------------------private---------------------------------
--进入有队伍状态(加入队伍)
function InterServiceDungeonModel:CreateTeam(teamId)
	self.teamId = teamId;
	self:sendNotification( NotifyConsts.TeamJoin );
	self:RemoveTeam(teamId); -- why? because once you join a team then you do not need to see it in you nearby teams' list.
end

--进入无队伍状态(离开队伍)
function InterServiceDungeonModel:QuitTeam()
	self.teamId = nil;
	self.memberList = {};
	self:sendNotification( NotifyConsts.TeamQuit );
	
	MapRelationModel:ClearTeamRelation()
end

--根据队员玩家id获取memberVO
function InterServiceDungeonModel:GetMemberById(playerId)
	for index, memberVO in pairs(self.memberList) do
		if memberVO.roleID == playerId then
			return memberVO;
		end
	end
	return nil;
end

--计算新加入的队员索引
function InterServiceDungeonModel:CalcIndex()
	for i = 1, TeamConsts.MemberCeiling do
		if not self.memberList[i] then
			return i;
		end
	end
end

--移除队员
function InterServiceDungeonModel:RemoveMember(index)
	self.memberList[index] = nil;
	self:sendNotification( NotifyConsts.TeamMemberRemove, index );
end















