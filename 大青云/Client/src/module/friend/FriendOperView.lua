--[[
好友操作面板
lizhuangzhuang
2014年10月18日10:37:27
]]

_G.UIFriendOper = BaseUI:new("UIFriendOper");

UIFriendOper.friendVO = nil;
UIFriendOper.rType = 0;
UIFriendOper.operlist = nil;

function UIFriendOper:Create()
	self:AddSWF("friendOperPanel.swf",true,"center");
end

function UIFriendOper:OnLoaded(objSwf,name)
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
end

function UIFriendOper:OnShow()
	self:ShowList();
end

function UIFriendOper:Open(friendVO,rType)
	self.friendVO = friendVO;
	self.rType = rType;
	if self:IsShow() then
		self:ShowList();
	else
		self:Show();
	end
end

--点击其他地方,关闭
function UIFriendOper:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self:GetSWF("UIFriendOper");
	if not objSwf then return; end
	if name == NotifyConsts.StageClick then
		local target = string.gsub(objSwf._target, "/",".");
		if string.find(body.target,target) then
			return
		end
		self:Hide();
	elseif name == NotifyConsts.StageFocusOut then
		self:Hide();
	end
end

function UIFriendOper:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end

function UIFriendOper:ShowList()
	local objSwf = self:GetSWF("UIFriendOper");
	if not objSwf then return; end
	self.operlist = FriendOperUtil:GetOperList(self.friendVO,self.rType);
	local len = #self.operlist;
	if len <= 0 then
		self:Hide();
		return;
	end
	objSwf.list.dataProvider:cleanUp();
	for i,vo in ipairs(self.operlist) do
		objSwf.list.dataProvider:push(vo.name);
	end
	local height = len*20+10;
	objSwf.list.height = height;
	objSwf.bg.height = height;
	objSwf.list:invalidateData();
	
	local pos = _sys:getRelativeMouse();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf._x = pos.x+15;
	objSwf._y = pos.y-5;
end

function UIFriendOper:OnListItemClick(e)
	if not self.operlist[e.index+1] then
		return;
	end
	local oper = self.operlist[e.index+1].oper;
	--
	if oper == FriendConsts.Oper_ShowInfo then
		RoleController:ViewRoleInfo(self.friendVO:GetRoleId());
	elseif oper == FriendConsts.Oper_Chat then
		ChatController:OpenPrivateChat(self.friendVO:GetRoleId(),self.friendVO:GetRoleName(),
						self.friendVO:GetIconId(),self.friendVO:GetLevel(),self.friendVO:GetVIPLevel());
	elseif oper == FriendConsts.Oper_TeamCreate then
		TeamController:InvitePlayerJoin(self.friendVO:GetRoleId());
	elseif oper == FriendConsts.Oper_TeamApply then
		TeamController:ApplyJoinTeam(self.friendVO:GetTeamId());
	elseif oper == FriendConsts.Oper_TeamInvite then
		TeamController:InvitePlayerJoin(self.friendVO:GetRoleId());
	elseif oper == FriendConsts.Oper_GuildInvite then
		--帮派邀请
		if UnionModel.MyUnionInfo.guildId and UnionModel.MyUnionInfo.guildId ~= '0_0' then
			UnionController:ReqInviteToGuild(UnionModel.MyUnionInfo.guildId, self.friendVO:GetRoleName())	
		end
	elseif oper == FriendConsts.Oper_GuildApply then
		--帮派申请
		UnionController:ReqApplyGuild(self.friendVO:GetGuildId(), 1)
	elseif oper == FriendConsts.Oper_AddFriend then
		FriendController:AddFriend(self.friendVO:GetRoleId());
	elseif oper == FriendConsts.Oper_RemoveFriend then
		FriendController:RemoveFriend(self.friendVO:GetRoleId());
	elseif oper == FriendConsts.Oper_CopyName then
		_sys.clipboard = self.friendVO:GetRoleName();
	elseif oper == FriendConsts.Oper_RemoveRecent then
		FriendController:RemoveRelation(self.friendVO:GetRoleId(),FriendConsts.RType_Recent);
	elseif oper == FriendConsts.Oper_RemoveEnemy then
		FriendController:RemoveRelation(self.friendVO:GetRoleId(),FriendConsts.RType_Enemy);
	elseif oper == FriendConsts.Oper_AddBlack then
		FriendController:AddBlack(self.friendVO:GetRoleId(),self.friendVO:GetRoleName());
	elseif oper == FriendConsts.Oper_RemoveBlack then
		FriendController:RemoveBlack(self.friendVO:GetRoleId(),self.friendVO:GetRoleName());
	end	
	self:Hide();
end
