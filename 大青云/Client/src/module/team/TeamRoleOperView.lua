--[[
主界面队伍队员菜单
2015年3月10日17:59:20
haohu
]]

UITeamRoleOper = BaseUI:new("UITeamRoleOper");

function UITeamRoleOper:Create()
	self:AddSWF("chatRoleOper.swf", true, "bottom");
end

function UITeamRoleOper:OnLoaded( objSwf )
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
end

function UITeamRoleOper:OnShow()
	self:UpdateShow();
end

function UITeamRoleOper:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.list;
	self.operlist = self:GetOperList( self.memberVO );
	local len = #self.operlist;
	if len <= 0 then
		self:Hide();
		return;
	end
	list.dataProvider:cleanUp();
	for i, vo in ipairs( self.operlist ) do
		list.dataProvider:push(vo.name);
	end

	local height = len * 20 + 10;
	list.height = height;
	objSwf.bg.height = height;
	list:invalidateData();

	local pos = _sys:getRelativeMouse();
	objSwf._x = pos.x + 15;
	objSwf._y = pos.y + 15;
end

function UITeamRoleOper:GetOperList(memberVO)
	local list = {};
	for _, oper in ipairs( TeamConsts.AllROper ) do
		local show = self:CheckOper(oper, memberVO);
		if show then
			local vo = {};
			vo.name = TeamConsts:GetOperName(oper);
			vo.oper = oper;
			table.push(list, vo);
		end
	end
	return list;
end

-- 检查菜单中是否出现某项oper
function UITeamRoleOper:CheckOper( oper, memberVO )
	if memberVO.roleID == MainPlayerController:GetRoleID() then
		return oper == TeamConsts.ROper_Quit;
	end

	if oper == TeamConsts.ROper_ShowInfo then
		return true;
	elseif oper == TeamConsts.ROper_Deal then
		return true;
	elseif oper == TeamConsts.ROper_AddFriend then
		return not FriendModel:GetIsFriend( memberVO.roleID );
	elseif oper == TeamConsts.ROper_AddBlack then
		return not FriendModel:GetIsBlack( memberVO.roleID );
	elseif oper == TeamConsts.ROper_GuildInvite then
		return UnionUtils:CheckMyUnion() and UnionUtils:GetUnionPermissionByDuty(UnionModel.MyUnionInfo.pos, UnionConsts.invitation) == 1
	elseif oper == TeamConsts.ROper_CopyName then
		return true;
	elseif oper == TeamConsts.ROper_Chat then
		return true;
	elseif oper == TeamConsts.ROper_Apoint then
		return TeamUtils:MainPlayerIsCaptain();
	elseif oper == TeamConsts.ROper_Kick then
		return TeamUtils:MainPlayerIsCaptain();
	elseif oper == TeamConsts.ROper_Quit then
		return false;
	end
end

function UITeamRoleOper:OnListItemClick(e)
	if not self.operlist[e.index + 1] then
		return;
	end
	local oper = self.operlist[e.index + 1].oper;
	if oper == TeamConsts.ROper_ShowInfo then
		RoleController:ViewRoleInfo( self.memberVO.roleID );
	elseif oper == TeamConsts.ROper_Deal then
    	DealController:InviteDeal( self.memberVO.roleID );
	elseif oper == TeamConsts.ROper_AddFriend then
		FriendController:AddFriend( self.memberVO.roleID );
	elseif oper == TeamConsts.ROper_AddBlack then
		FriendController:AddBlack( self.memberVO.roleID, self.memberVO.roleName );
	elseif oper == TeamConsts.ROper_GuildInvite then
		if UnionUtils:CheckMyUnion() then
			UnionController:ReqInviteToGuild( UnionModel.MyUnionInfo.guildId, self.memberVO.roleName );
		end
	elseif oper == TeamConsts.ROper_CopyName then
		_sys.clipboard = self.memberVO.roleName;
	elseif oper == TeamConsts.ROper_Chat then
		ChatController:OpenPrivateChat( self.memberVO.roleID, self.memberVO.roleName,
				self.memberVO.iconID, self.memberVO.level, self.memberVO.vipLevel );
	elseif oper == TeamConsts.ROper_Apoint then
		TeamController:Appoint( self.memberVO );
	elseif oper == TeamConsts.ROper_Kick then
		TeamController:Kick( self.memberVO.roleID );
	elseif oper == TeamConsts.ROper_Quit then
		TeamController:QuitTeam();
	end
	self:Hide();
end

function UITeamRoleOper:ListNotificationInterests()
	return { NotifyConsts.StageClick, NotifyConsts.StageFocusOut };
end

function UITeamRoleOper:HandleNotification(name,body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.StageClick then
		local target = string.gsub( objSwf._target, "/", "." );
		if string.find( body.target, target ) then
			return
		end
		self:Hide();
	elseif name == NotifyConsts.StageFocusOut then
		self:Hide();
	end
end

function UITeamRoleOper:Open(memberVO)
	self.memberVO = memberVO;
	self:Show();
end