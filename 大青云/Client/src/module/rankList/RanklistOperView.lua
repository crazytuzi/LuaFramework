--[[
排行榜操作面板
wangshuai
]]

_G.UIRankListOper = BaseUI:new("UIRankListOper");

UIRankListOper.friendVO = nil;
UIRankListOper.rType = 0;
UIRankListOper.operlist = {};
UIRankListOper.myOperlist = {FriendConsts.Oper_ShowInfo,FriendConsts.Oper_Chat,FriendConsts.Oper_AddFriend,FriendConsts.Oper_CopyName};
UIRankListOper.IsAllServer = false;
function UIRankListOper:Create()
	self:AddSWF("friendOperPanel.swf",true,"center");
end

function UIRankListOper:OnLoaded(objSwf,name)
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
end

function UIRankListOper:OnShow()
	self:ShowList();
end

function UIRankListOper:Open(friendVO,rType,IsAllServer)
	self.friendVO = friendVO;
	self.rType = rType;
	self.IsAllServer = IsAllServer
	if self:IsShow() then
		self:ShowList();
	else
		self:Show();
	end
end

--点击其他地方,关闭
function UIRankListOper:HandleNotification(name,body)
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

function UIRankListOper:ListNotificationInterests()
	return {NotifyConsts.StageClick,NotifyConsts.StageFocusOut};
end

function UIRankListOper:ShowList()
	local objSwf = self:GetSWF("UIFriendOper");
	if not objSwf then return; end
	self.operlist= {};

	for i,info in ipairs(self.myOperlist) do 
		local vo = {};
				vo.name = FriendConsts:GetOperName(info);
				vo.oper = info;

			table.push(self.operlist,vo)	

	end;

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

function UIRankListOper:OnListItemClick(e)
	if not self.operlist[e.index+1] then
		return;
	end
	local oper = self.operlist[e.index+1].oper;
	if oper == FriendConsts.Oper_ShowInfo then
		if self.IsAllServer == false then 
	 		RoleController:ViewRoleInfo(self.friendVO.roleId);
	 	elseif self.IsAllServer == true then 
	 		RankListController:AtServerReqRoleinfo(self.friendVO.roleId,0,1)
	 	end;
	elseif oper == FriendConsts.Oper_Chat then
		ChatController:OpenPrivateChat(self.friendVO.roleId,self.friendVO.roleName,
						self.friendVO.prof,self.friendVO.roleLvl,self.friendVO.vipLvl);
	elseif oper == FriendConsts.Oper_AddFriend then
		FriendController:AddFriend(self.friendVO.roleId);
	elseif oper == FriendConsts.Oper_CopyName then
		_sys.clipboard = self.friendVO.roleName;
	 end;
	self:Hide();
end
