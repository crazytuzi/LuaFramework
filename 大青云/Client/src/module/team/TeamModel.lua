--[[
队伍:数据模型
郝户
2014年9月24日20:24:23
]]

_G.TeamModel = Module:new();


-------------------------------------------------------------
TeamModel.teamId = nil;
TeamModel.memberList = {};

--添加一个队员
function TeamModel:AddMember(memberVO)
	local numMembers = self:GetMemberNum();
	if numMembers < TeamConsts.MemberCeiling then
		local index = TeamModel:CalcIndex();
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
function TeamModel:RemoveMemberById(playerId)
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
function TeamModel:UpdateMember(playerId, info)
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
function TeamModel:IsInTeam()
	return self.teamId ~= nil;
end

--获取队长ID
function TeamModel:GetCaptainId()
	for index, memberVO in pairs(self.memberList) do
		if memberVO.teamPos == TeamConsts.PosCaptain then
			return memberVO.roleID;
		end
	end
end

--获取队长信息
function TeamModel:GetCaptainInfo()
	for index, memberVO in pairs(self.memberList) do
		if memberVO.teamPos == TeamConsts.PosCaptain then
			return memberVO;
		end
	end
end

--获取队长玩家索引
function TeamModel:GetCaptainIndex()
	for index, memberVO in pairs(self.memberList) do
		if memberVO.teamPos == TeamConsts.PosCaptain then
			return memberVO.index;
		end
	end
end

--获取队友列表
function TeamModel:GetMemberList()
	return self.memberList;
end

--根据id获取队员名字
function TeamModel:GetMemberName(playerId)
	local memberVO = self:GetMemberById(playerId);
	return memberVO and memberVO.roleName;
end

--获取队伍人数
function TeamModel:GetMemberNum()
	return getTableLen(self.memberList);
end

--获取主玩家在队伍中的索引
function TeamModel:GetMainPlayerIndex()
	local mainPlayerId = MainPlayerController:GetRoleID();
	local memberVO = TeamModel:GetMemberById(mainPlayerId)
	return memberVO and memberVO.index;
end

--根据index获取队员vo
function TeamModel:GetMember(index)
	return self.memberList[index];
end

--根据index获取玩家Id
function TeamModel:GetMemberIdByIndex(index)
	local memberVO = self.memberList[index];
	return memberVO and memberVO.roleID;
end

--判断某个玩家是不是队友
function TeamModel:IsTeammate(playerId)
	return self:GetMemberById(playerId) ~= nil;
end


-------------------------------------private---------------------------------
--进入有队伍状态(加入队伍)
function TeamModel:CreateTeam(teamId)
	self.teamId = teamId;
	self:sendNotification( NotifyConsts.TeamJoin );
	self:RemoveTeam(teamId); -- why? because once you join a team then you do not need to see it in you nearby teams' list.
end

--进入无队伍状态(离开队伍)
function TeamModel:QuitTeam()
	self.teamId = nil;
	self.memberList = {};
	self:sendNotification( NotifyConsts.TeamQuit );
	
	MapRelationModel:ClearTeamRelation()

	TeamController:CloseConfirmQuit()
end

--根据队员玩家id获取memberVO
function TeamModel:GetMemberById(playerId)
	for index, memberVO in pairs(self.memberList) do
		if memberVO.roleID == playerId then
			return memberVO;
		end
	end
	return nil;
end

--计算新加入的队员索引
function TeamModel:CalcIndex()
	for i = 1, TeamConsts.MemberCeiling do
		if not self.memberList[i] then
			return i;
		end
	end
end

--移除队员
function TeamModel:RemoveMember(index)
	self.memberList[index] = nil;
	self:sendNotification( NotifyConsts.TeamMemberRemove, index );
end


--------------------------------附近玩家信息-----------------------------------

TeamModel.nearbyPlayers = {};

function TeamModel:SetNearbyPlayers(nearbyPlayers)
	self.nearbyPlayers = nearbyPlayers;
	self:sendNotification( NotifyConsts.PlayerNearby );
end

function TeamModel:GetNearbyPlayers()
	return self.nearbyPlayers;
end

function TeamModel:ChangeNearbyPlayerState(playerId, teamState)
	for _, playerVO in pairs(self.nearbyPlayers) do
		if playerVO.roleID == playerId then
			playerVO.teamState = teamState;
			self:sendNotification( NotifyConsts.PlayerNearby );
			return;
		end
	end
end

-- <attribute type="guid" name="roleID" comment="角色ID"/>
-- <attribute type="string" length="64" name="roleName" comment="角色名字" />
-- <attribute type="int" name="level" comment="等级" />
-- <attribute type="int" name="prof" comment="职业" />
-- <attribute type="int" name="teamState" comment="组队状态,0未组队,1已组队" />
-- <attribute type="string" length="64" name="guildName" comment="帮派名" />
-- <attribute type="int" name="fight" comment="战斗力" />

--------------------------------附近队伍信息-----------------------------------

TeamModel.nearbyTeams = {};

function TeamModel:SetNearbyTeams(nearbyTeams)
	self.nearbyTeams = nearbyTeams;
	self:sendNotification( NotifyConsts.TeamNearby );
end

function TeamModel:GetNearbyTeams()
	return self.nearbyTeams;
end

-- 从附近的队伍列表中删除某个队伍
function TeamModel:RemoveTeam(teamId)
	for index, teamVO in pairs(self.nearbyTeams) do
		if teamVO.teamId == teamId then
			table.remove(self.nearbyTeams, index);
			self:sendNotification( NotifyConsts.TeamNearby );
			return;
		end
	end
end

-- <attribute type="guid" name="teamId" comment="队伍id"/>
-- <attribute type="string" length="64" name="leaderName" comment="队长名字" />
-- <attribute type="int" name="maxRoleLevel" comment="最高等级" />
-- <attribute type="int" name="averageRoleLevel" comment="平均等级" />
-- <attribute type="int" name="maxRoleFight" comment="最高战斗力" />
-- <attribute type="int" name="averageRoleFight" comment="平均战斗力" />
-- <attribute type="int" name="roleNum" comment="成员数量" />

----------------------------------------------------------------------------------
