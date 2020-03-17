--[[
聊天人名操作菜单
lizhuangzhuang
2014年9月30日15:32:59
]]
_G.classlist['UIChatRoleOper'] = 'UIChatRoleOper'
_G.UIChatRoleOper = BaseUI:new("UIChatRoleOper");
UIChatRoleOper.objName = 'UIChatRoleOper'
UIChatRoleOper.operlist = nil;--操作列表
UIChatRoleOper.chatRoleVO = nil;--操作对象

function UIChatRoleOper:Create()
	self:AddSWF("chatRoleOper.swf",true,"center");
end

function UIChatRoleOper:OnLoaded(objSwf,name)
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
end

function UIChatRoleOper:OnShow(name)
	self:ShowList();
end

function UIChatRoleOper:Open(chatRoleVO)
	if MainPlayerController.isInterServer then return end
	self.chatRoleVO = chatRoleVO;
	if self:IsShow() then
		self:ShowList();
	else
		self:Show();
	end
end

--点击其他地方,关闭
function UIChatRoleOper:HandleNotification(name,body)
	local objSwf = self.objSwf;
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

function UIChatRoleOper:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end

function UIChatRoleOper:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.operlist = ChatRoleOperUtil:GetOperList(self.chatRoleVO);
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
	local y = pos.y - 30;
	if y+height > wHeight then
		y = wHeight-height;
	end
	objSwf._y = y;
end

function UIChatRoleOper:OnListItemClick(e)
	if not self.operlist[e.index+1] then
		return;
	end
	local oper = self.operlist[e.index+1].oper;
	if oper == ChatConsts.ROper_Chat then
		ChatController:OpenPrivateChat(self.chatRoleVO:GetID(),self.chatRoleVO:GetName(),
						self.chatRoleVO:GetIcon(),self.chatRoleVO:GetLvl(),self.chatRoleVO:GetVIP())
	elseif oper == ChatConsts.ROper_ShowInfo then
		RoleController:ViewRoleInfo(self.chatRoleVO:GetID());
	elseif oper == ChatConsts.ROper_AddFriend then
		FriendController:AddFriend(self.chatRoleVO:GetID());
	elseif oper == ChatConsts.ROper_AddBlack then
		FriendController:AddBlack(self.chatRoleVO:GetID(),self.chatRoleVO:GetName());
	elseif oper == ChatConsts.ROper_GuildInvite then
		--帮派邀请
		if UnionUtils:CheckMyUnion() then
			UnionController:ReqInviteToGuild(UnionModel.MyUnionInfo.guildId, self.chatRoleVO:GetName())	
		end
	elseif oper == ChatConsts.ROper_GuildApply then
		--帮派申请
		UnionController:ReqApplyGuild(self.chatRoleVO:GetGuildId(), 1)
	elseif oper == ChatConsts.ROper_TeamCreate then
		local playerId = self.chatRoleVO:GetID();
		TeamController:InvitePlayerJoin(playerId);
	elseif oper == ChatConsts.ROper_TeamApply then
		local teamId = self.chatRoleVO:GetTeamId();--获取点击名字玩家的队伍id
		TeamController:ApplyJoinTeam(teamId)
	elseif oper == ChatConsts.ROper_TeamInvite then
		local playerId = self.chatRoleVO:GetID();
		TeamController:InvitePlayerJoin(playerId);
	elseif oper == ChatConsts.ROper_CopyName then
		_sys.clipboard = self.chatRoleVO:GetName();
	elseif oper == ChatConsts.ROper_Report then
		ChatController:BanGuildChat(self.chatRoleVO:GetID());
	else
		for _,p in ipairs(GMConsts.AllOper) do
			if p == oper then
				GMController:DoGMOper(oper,self.chatRoleVO:GetID());
				break;
			end
		end
	end
	self:Hide();
end
