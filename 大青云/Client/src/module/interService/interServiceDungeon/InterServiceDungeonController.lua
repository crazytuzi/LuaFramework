

_G.InterServiceDungeonController = setmetatable( {}, {__index = IController} );
InterServiceDungeonController.name = "InterServiceDungeonController"

function InterServiceDungeonController:Create()
	MsgManager:RegisterCallBack( MsgType.WC_TeamInfo,			self, self.OnTeamInfoRcv );
	MsgManager:RegisterCallBack( MsgType.WC_TeamRoleJoin,		self, self.OnMemberJoin );
	MsgManager:RegisterCallBack( MsgType.WC_TeamRoleUpdate,    	self, self.OnMemberUpdate );
	MsgManager:RegisterCallBack( MsgType.WC_TeamRoleUpdateInfo,	self, self.OnMemberUpdate );
	MsgManager:RegisterCallBack( MsgType.WC_TeamRoleExit,		self, self.OnMemberQuit );
	MsgManager:RegisterCallBack( MsgType.WC_TeamJoinRequest,	self, self.OnApply );
	MsgManager:RegisterCallBack( MsgType.WC_TeamInviteRequest,	self, self.OnInvite );	
end

function InterServiceDungeonController:OnEnterGame()
	self:QueryTeamInfo();
end


----------------------------------------------Response-----------------------------------------------

--收到队伍信息
function InterServiceDungeonController:OnTeamInfoRcv(msg)
	local teamId = msg.teamId;
	if not teamId then return; end
	local memberList = msg.roleList;
	if not memberList then return; end
	for i, memberInfo in ipairs(memberList) do
		--如果队伍里面已经有该玩家，更新这个玩家
		if InterServiceDungeonModel:GetMemberById( memberInfo.roleID ) then
			InterServiceDungeonModel:UpdateMember( memberInfo.roleID, memberInfo );
		else
			local memberVO = TeamMemberVO:new();
			memberVO.teamId = teamId;
			for attrName, attrValue in pairs(memberInfo) do
				memberVO[attrName] = attrValue;
			end	
			--队伍里面没有该玩家，添加玩家到队伍
			InterServiceDungeonModel:AddMember(memberVO);
		end
	end
end

--有玩家加入队伍
function InterServiceDungeonController:OnMemberJoin(msg)
	local memberVO = TeamMemberVO:new();
	table.foreach( msg, function(attrName, attrValue) memberVO[attrName] = attrValue end );
	InterServiceDungeonModel:AddMember(memberVO);
end

--队员信息更新
function InterServiceDungeonController:OnMemberUpdate(msg)
	local memberInfo = msg;
	InterServiceDungeonModel:UpdateMember(memberInfo.roleID, memberInfo);
end

--队员退出队伍
function InterServiceDungeonController:OnMemberQuit(msg)
	local playerId = msg.roleID;
	InterServiceDungeonModel:RemoveMemberById(playerId);
end

--收到入队申请
function InterServiceDungeonController:OnApply(msg)
	local playerId = msg.roleID; --申请者id
	local playerName = msg.roleName; --申请者名字
	if UITeamMine.autoAcceptJoin then
		self:ApplyReply( playerId, TeamConsts.Agree );
	else
		local vo = {};
		vo.sponsorName = playerName;
		vo.id = playerId;
		RemindController:AddRemind( RemindConsts.Type_TeamApply, vo );
	end
end

--收到入队邀请
function InterServiceDungeonController:OnInvite(msg)
	local teamId = msg.teamId; --邀请你的队伍id
	local captainName = msg.leaderName; --邀请你的队长名字
	if UITeamMine.autoAcceptInvite then
		self:InviteReply( teamId, TeamConsts.Agree );
	else
		local vo = {};
		vo.sponsorName = captainName;
		vo.id = teamId;
		RemindController:AddRemind(RemindConsts.Type_TeamInvite, vo );
	end
end

----------------------------------------------Request-----------------------------------------------

--请求队伍信息
function InterServiceDungeonController:QueryTeamInfo(teamId)
	local msg = ReqTeamInfoMsg:new();
	msg.teamId = teamId or 0;
	MsgManager:Send(msg);
end

--请求创建队伍
function InterServiceDungeonController:CreateTeam()
	local msg = ReqTeamCreateMsg:new();
	MsgManager:Send(msg);
end

--邀请入队
function InterServiceDungeonController:InvitePlayerJoin(playerId)
	local msg;
	if InterServiceDungeonModel:IsInTeam() then
		msg = ReqTeamInviteMsg:new();
		msg.targetRoleID = playerId;
	else
		msg = ReqTeamCreateMsg:new();
		msg.targetRoleID = playerId;
	end
	MsgManager:Send(msg);
end

--审批入队邀请
--@param operate: 1同意0拒绝
function InterServiceDungeonController:InviteReply(teamId, operate)
	local msg = ReqTeamInviteApprove:new();
	msg.teamId =  teamId;
	msg.operate = operate;
	MsgManager:Send(msg);
end

--申请入队
function InterServiceDungeonController:ApplyJoinTeam(teamId)
	local msg = ReqTeamApplyMsg:new();
	msg.teamId = teamId;
	MsgManager:Send(msg);
end

--审批入队申请(队长)
--@param operate: 1同意0拒绝
function InterServiceDungeonController:ApplyReply(targetRoleID, operate)
	local msg = ReqTeamJoinApproveMsg:new();
	msg.targetRoleID = targetRoleID;
	msg.operate = operate;
	MsgManager:Send(msg);
end

--请求退出队伍
function InterServiceDungeonController:QuitTeam()
	if not InterServiceDungeonModel:IsInTeam() then
		return
	end
	local msg = ReqTeamQuitMsg:new();
	MsgManager:Send(msg);
end

--请求任命队长
function InterServiceDungeonController:Appoint(memberVO)
	local playerId = memberVO.roleID;
	--自己已经是队长了，无需任命
	if playerId == MainPlayerController:GetRoleID() then
		return;
	end
	--离线玩家不可任命为队长
	if memberVO.online == TeamConsts.Offline then
		FloatManager:AddCenter( StrConfig['team6'] );
		return;
	end
	local msg = ReqTeamTransferMsg:new();
	msg.targetRoleID = playerId;
	MsgManager:Send(msg);
end

--开除队友(踢人)
function InterServiceDungeonController:Kick(playerId)
	if playerId == MainPlayerController:GetRoleID() then
		return;
	end
	local msg = ReqTeamFireMsg:new();
	msg.targetRoleID = playerId;
	MsgManager:Send(msg);
end




--------------------------------------------------------------------------------