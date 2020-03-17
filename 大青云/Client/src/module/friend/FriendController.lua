--[[
好友
lizhuangzhuang
2014年10月16日20:27:35
]]

_G.FriendController = setmetatable({},{__index=IController});
FriendController.name = "FriendController";

function FriendController:Create()
	MsgManager:RegisterCallBack(MsgType.WC_RelationList,self,self.OnRelationListMsg);
	MsgManager:RegisterCallBack(MsgType.WC_AddFriendTarget,self,self.OnAddFriendTargetMsg);
	MsgManager:RegisterCallBack(MsgType.WC_RemoveRelation,self,self.OnRemoveRelationMsg);
	MsgManager:RegisterCallBack(MsgType.WC_RecommendList,self,self.OnRecommendListMsg);
	MsgManager:RegisterCallBack(MsgType.WC_RelationOnLineStatus,self,self.OnOnlineStatusMsg);
	MsgManager:RegisterCallBack(MsgType.WC_FriendReward,self,self.OnFriendReward);
	MsgManager:RegisterCallBack(MsgType.WC_FriendRewardGet,self,self.OnFriendRewardGet);
end

--根据id添加好友
function FriendController:AddFriend(roleId)
	if not FuncManager:GetFuncIsOpen(FuncConsts.Friend) then
		local tips = FuncManager:GetFuncUnOpenTips(FuncConsts.Friend);
		if tips ~= "" then
			FloatManager:AddCenter(tips);
		end
		return;
	end
	local list = {};
	table.push(list,roleId);
	self:AddFriendList(list);
end

--根据name添加好友
function FriendController:AddFriendByName(roleName)
	--有区服直接发送,没有区服的话增加区服再发送
	local s,e = string.find(roleName,"%[[0-9]+%]");
	if (not s) or s~=1 then
		local s,e = string.find(MainPlayerModel.sMeShowInfo.szRoleName,"%[[0-9]+%]");
		roleName = string.sub(MainPlayerModel.sMeShowInfo.szRoleName,s,e) .. roleName;
	end
	if roleName == MainPlayerModel.sMeShowInfo.szRoleName then
		FloatManager:AddCenter(StrConfig['friend112']);
		return;
	end
	local msg = ReqAddFriend:new();
	msg.roleName = roleName;
	MsgManager:Send(msg);
	FloatManager:AddCenter(StrConfig["friend111"]);
end

--添加多个好友
function FriendController:AddFriendList(list)
	if #list <= 0 then return; end
	local filterList = {};
	for i,roleId in ipairs(list) do
		if FriendModel:GetIsFriend(roleId) then
			local friendVO = FriendModel:GetFriendVO(roleId);
			if friendVO then
				local str = string.format(StrConfig["friend108"],friendVO:GetRoleName());
				FloatManager:AddCenter(str);
			end
		elseif FriendModel:GetIsBlack(roleId) then
			local friendVO = FriendModel:GetFriendVO(roleId);
			if friendVO then
				local str = string.format(StrConfig["friend109"],friendVO:GetRoleName());
				FloatManager:AddCenter(str);
			end
		else
			local vo = {};
			vo.roleID = roleId;
			table.push(filterList,vo);
		end
	end
	if #filterList <= 0 then return; end
	local msg = ReqAddFriendRecommend:new();
	msg.AddFriendList = filterList;
	MsgManager:Send(msg);
	FloatManager:AddCenter(StrConfig["friend111"]);
end

--删除好友
function FriendController:RemoveFriend(roleId)
	if not FriendModel:GetIsFriend(roleId) then
		return;
	end
	UIConfirm:Open(StrConfig['friend104'],function()
		self:RemoveRelation(roleId,FriendConsts.RType_Friend);
	end);
end

--添加黑名单
function FriendController:AddBlack(roleId,roleName)
	if FriendModel:GetIsBlack(roleId) then
		local str = string.format(StrConfig["friend109"],roleName);
		FloatManager:AddCenter(str);
		return;
	end
	local content;
	if FriendModel:GetIsFriend(roleId) then
		content = string.format(StrConfig['friend106'],roleName);
	else
		content = string.format(StrConfig['friend105'],roleName);
	end
	UIConfirm:Open(content,function()
		local msg = ReqAddBlackList:new();
		msg.roleID = roleId;
		MsgManager:Send(msg);
	end);
end

--移除黑名单
function FriendController:RemoveBlack(roleId,roleName)
	if not FriendModel:GetIsBlack(roleId) then
		return;
	end
	UIConfirm:Open(string.format(StrConfig['friend107'],roleName),function()
		self:RemoveRelation(roleId,FriendConsts.RType_Black);
	end);
end

--删除关系
function FriendController:RemoveRelation(roleId,rType)
	if not FriendModel:GetHasRelation(roleId,rType) then
		return;
	end
	local msg = ReqRemoveRelation:new();
	msg.roleID = roleId;
	msg.relationType = rType;
	MsgManager:Send(msg);
end

--添加好友反馈
function FriendController:AddFriendApprove(approvelist)
	local msg = ReqAddFriendApprove:new();
	msg.approveList = approvelist;
	MsgManager:Send(msg);
end

--请求推荐好友
function FriendController:ReqRecommendFriend()
	FriendModel.recommendList = {};
	local msg = ReqAskRecommendList:new();
	MsgManager:Send(msg);
end

--请求好友改变信息
function FriendController:ReqRelationChangeList()
	local msg = ReqRelationChangeList:new();
	MsgManager:Send(msg);
end

--更新最近联系时间
function FriendController:UpdateRecentTime(roleId)
	local friendVO = FriendModel:GetFriendVO(roleId);
	if not friendVO then return; end
	friendVO:SetRecentTime(GetServerTime());
	self:sendNotification(NotifyConsts.FriendChange);
end

--更新仇人击杀时间
function FriendController:UpdateKillTime(roleId)
	local friendVO = FriendModel:GetFriendVO(roleId);
	if not friendVO then return; end
	friendVO:SetKillTime(GetServerTime());
	self:sendNotification(NotifyConsts.FriendChange);
end

--自动推荐好友
function FriendController:AutoRecommendFriend()
	FriendController:ReqRecommendFriend();
end

-------------------------------------返回消息-------------------------
--收到添加好友请求
function FriendController:OnAddFriendTargetMsg(msg)
	--屏蔽添加好友
	if SetSystemModel:GetIsFriend() then
		local list = {{agree=0,roleID=msg.roleID}};
		self:AddFriendApprove(list);
		return;
	end
	local vo = {};
	vo.roleId = msg.roleID;
	vo.roleName = msg.roleName;
	vo.level = msg.level;
	RemindController:AddRemind(RemindConsts.Type_FriendApply,vo)
end

--服务器返回关系
function FriendController:OnRelationListMsg(msg)
	for i,vo in ipairs(msg.RelationList) do
		local friendVO = FriendModel:GetFriendVO(vo.roleID);
		if not friendVO then
			friendVO = FriendVO:new(vo.roleID);
			FriendModel:AddFriendVO(friendVO);
		end
		friendVO:SetInfo(vo);
	end
	self:sendNotification(NotifyConsts.FriendChange);
end

--删除关系返回
function FriendController:OnRemoveRelationMsg(msg)
	for i,vo in ipairs(msg.RemoveRelationList) do
		local friendVO = FriendModel:GetFriendVO(vo.roleID);
		if friendVO then
			friendVO:RemoveRelation(vo.relationType);
			if friendVO:GetRelationCount() == 0 then
				FriendModel:RemoveFriendVO(vo.roleID);
			end
		end
	end
	self:sendNotification(NotifyConsts.FriendChange);
end

--返回推荐好友
function FriendController:OnRecommendListMsg(msg)
	FriendModel.recommendList = msg.RecommendList;
	if UIFriendRecommend:IsShow() then
		UIFriendRecommend:ShowList();
	else
		if #msg.RecommendList > 0 then
			RemindController:AddRemind(RemindConsts.Type_FRecommend);
		end
	end
end

--返回在线状态改变
function FriendController:OnOnlineStatusMsg(msg)
	for i,vo in ipairs(msg.RelationList) do
		local friendVO = FriendModel:GetFriendVO(vo.roleID);
		if friendVO then
			friendVO:SetOnlineState(vo.onlinestatus);
		end
	end
	self:sendNotification(NotifyConsts.FriendOnlineChange);
end

--返回可领取的好友奖励
function FriendController:OnFriendReward(msg)
	local vo = {};
	vo.roleID = msg.roleID;
	vo.roleName = msg.roleName;
	vo.level = msg.level;
	RemindController:AddRemind(RemindConsts.Type_FReward,vo);
end

--请求领取好友奖励
function FriendController:GetFriendReward()
	local msg = ReqFriendRewardGetMsg:new();
	MsgManager:Send(msg);
end

--返回领取好友奖励
function FriendController:OnFriendRewardGet(msg)
	if msg.result == 0 then
	
	else
		print("领取好友奖励失败");
	end
end