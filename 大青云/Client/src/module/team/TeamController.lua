--[[
队伍：控制器
郝户
2014年9月25日12:24:59
]]

_G.TeamController = setmetatable( {}, {__index = IController} );
TeamController.name = "TeamController"

function TeamController:Create()
	MsgManager:RegisterCallBack( MsgType.WC_TeamInfo,			self, self.OnTeamInfoRcv );
	MsgManager:RegisterCallBack( MsgType.WC_TeamRoleJoin,		self, self.OnMemberJoin );
	MsgManager:RegisterCallBack( MsgType.WC_TeamRoleUpdate,    	self, self.OnMemberUpdate );
	MsgManager:RegisterCallBack( MsgType.WC_TeamRoleUpdateInfo,	self, self.OnMemberUpdate );
	MsgManager:RegisterCallBack( MsgType.WC_TeamRoleExit,		self, self.OnMemberQuit );
	MsgManager:RegisterCallBack( MsgType.WC_TeamJoinRequest,	self, self.OnApply );
	MsgManager:RegisterCallBack( MsgType.WC_TeamInviteRequest,	self, self.OnInvite );
	MsgManager:RegisterCallBack( MsgType.WC_TeamNearbyTeam,		self, self.OnNearbyTeamInfoRcv );
	MsgManager:RegisterCallBack( MsgType.WC_TeamNearbyRole,		self, self.OnNearbyPlayerInfoRcv );
end

function TeamController:OnEnterGame()
	self:QueryTeamInfo();
end


----------------------------------------------Response-----------------------------------------------

--收到队伍信息
function TeamController:OnTeamInfoRcv(msg)
	local teamId = msg.teamId;
	if not teamId then return; end
	local memberList = msg.roleList;
	if not memberList then return; end
	for i, memberInfo in ipairs(memberList) do
		--如果队伍里面已经有该玩家，更新这个玩家
		if TeamModel:GetMemberById( memberInfo.roleID ) then
			TeamModel:UpdateMember( memberInfo.roleID, memberInfo );
		else
			local memberVO = TeamMemberVO:new();
			memberVO.teamId = teamId;
			for attrName, attrValue in pairs(memberInfo) do
				memberVO[attrName] = attrValue;
			end	
			--队伍里面没有该玩家，添加玩家到队伍
			TeamModel:AddMember(memberVO);
		end
	end
end

--有玩家加入队伍
function TeamController:OnMemberJoin(msg)
	local memberVO = TeamMemberVO:new();
	table.foreach( msg, function(attrName, attrValue) memberVO[attrName] = attrValue end );
	TeamModel:AddMember(memberVO);
end

--队员信息更新
function TeamController:OnMemberUpdate(msg)
	local memberInfo = msg;
	TeamModel:UpdateMember(memberInfo.roleID, memberInfo);
end

--队员退出队伍
function TeamController:OnMemberQuit(msg)
	local playerId = msg.roleID;
	TeamModel:RemoveMemberById(playerId);
end

--收到入队申请
function TeamController:OnApply(msg)
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
function TeamController:OnInvite(msg)
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

--收到附近队伍信息
function TeamController:OnNearbyTeamInfoRcv(msg)
	local teamList = msg.teamList;
	TeamModel:SetNearbyTeams(teamList);
end

--收到附近玩家信息
function TeamController:OnNearbyPlayerInfoRcv(msg)
	local playerList = msg.roleList;
	TeamModel:SetNearbyPlayers(playerList);
end

----------------------------------------------Request-----------------------------------------------

--请求队伍信息
function TeamController:QueryTeamInfo(teamId)
	local msg = ReqTeamInfoMsg:new();
	msg.teamId = teamId or 0;
	MsgManager:Send(msg);
end

--请求创建队伍
function TeamController:CreateTeam()
	local msg = ReqTeamCreateMsg:new();
	MsgManager:Send(msg);
end

--邀请入队
function TeamController:InvitePlayerJoin(playerId)
	local msg;
	if TeamModel:IsInTeam() then
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
function TeamController:InviteReply(teamId, operate)
	local msg = ReqTeamInviteApprove:new();
	msg.teamId =  teamId;
	msg.operate = operate;
	MsgManager:Send(msg);
end

--申请入队
function TeamController:ApplyJoinTeam(teamId)
	local msg = ReqTeamApplyMsg:new();
	msg.teamId = teamId;
	MsgManager:Send(msg);
end

--审批入队申请(队长)
--@param operate: 1同意0拒绝
function TeamController:ApplyReply(targetRoleID, operate)
	local msg = ReqTeamJoinApproveMsg:new();
	msg.targetRoleID = targetRoleID;
	msg.operate = operate;
	MsgManager:Send(msg);
end

--请求退出队伍
function TeamController:QuitTeam()
	if not TeamModel:IsInTeam() then
		return
	end
	local msg = ReqTeamQuitMsg:new();
	MsgManager:Send(msg);
end

function TeamController:ConfirmQuit()
	if self.quitConfirm then
		self:CloseConfirmQuit();
	end
	if not self.quitConfirm then
		local confirm = function ()
			self:QuitTeam();
			self:CloseConfirmQuit();
		end
		local cancel = function()
			self:CloseConfirmQuit();
		end
		self.quitConfirm = UIConfirm:Open( StrConfig['team200'], confirm, cancel )
	end
end

function TeamController:CloseConfirmQuit()
	if self.quitConfirm then
		UIConfirm:Close(self.quitConfirm)
		self.quitConfirm = nil
	end
end

--请求任命队长
function TeamController:Appoint(memberVO)
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
function TeamController:Kick(playerId)
	if playerId == MainPlayerController:GetRoleID() then
		return;
	end
	local msg = ReqTeamFireMsg:new();
	msg.targetRoleID = playerId;
	MsgManager:Send(msg);
end

--请求附近队伍信息
function TeamController:QueryTeamNearByInfo()
	local msg = ReqTeamNearbyTeamMsg:new();
	MsgManager:Send(msg);
end

--请求附近玩家信息
function TeamController:QueryPlayerNearByInfo()
	local msg = ReqTeamNearbyRoleMsg:new();
	MsgManager:Send(msg);
end



--------------------------------------------------------------------------------