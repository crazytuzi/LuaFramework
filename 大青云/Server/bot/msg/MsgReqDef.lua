

--[[
请求登录
]]
_G.ReqConnSrvMsg = {};

ReqConnSrvMsg.msgId = 1001;
ReqConnSrvMsg.accountID = ""; -- 玩家ID
ReqConnSrvMsg.platform = ""; -- 平台
ReqConnSrvMsg.game_name = ""; -- 游戏名
ReqConnSrvMsg.server_id = 0; -- 区服ID
ReqConnSrvMsg.time = 0; -- 时间
ReqConnSrvMsg.is_adult = 0; -- 防沉迷标记
ReqConnSrvMsg.exts = ""; -- 扩展信息
ReqConnSrvMsg.sign = ""; -- 签名
ReqConnSrvMsg.mac = ""; -- 物理地址
ReqConnSrvMsg.version = ""; -- 协议版本
ReqConnSrvMsg.virtualIP = 0; -- 伪造IP



ReqConnSrvMsg.meta = {__index = ReqConnSrvMsg };
function ReqConnSrvMsg:new()
	local obj = setmetatable( {}, ReqConnSrvMsg.meta);
	return obj;
end

function ReqConnSrvMsg:encode()
	local body = "";

	body = body ..writeString(self.accountID,64);
	body = body ..writeString(self.platform,32);
	body = body ..writeString(self.game_name,32);
	body = body ..writeInt(self.server_id);
	body = body ..writeInt(self.time);
	body = body ..writeInt(self.is_adult);
	body = body ..writeString(self.exts,64);
	body = body ..writeString(self.sign,64);
	body = body ..writeString(self.mac,32);
	body = body ..writeString(self.version,33);
	body = body ..writeInt(self.virtualIP);

	return body;
end

function ReqConnSrvMsg:ParseData(pak)
	local idx = 1;

	self.accountID, idx = readString(pak, idx, 64);
	self.platform, idx = readString(pak, idx, 32);
	self.game_name, idx = readString(pak, idx, 32);
	self.server_id, idx = readInt(pak, idx);
	self.time, idx = readInt(pak, idx);
	self.is_adult, idx = readInt(pak, idx);
	self.exts, idx = readString(pak, idx, 64);
	self.sign, idx = readString(pak, idx, 64);
	self.mac, idx = readString(pak, idx, 32);
	self.version, idx = readString(pak, idx, 33);
	self.virtualIP, idx = readInt(pak, idx);

end



--[[
角色申请
]]
_G.ReqCreateRoleMsg = {};

ReqCreateRoleMsg.msgId = 1002;
ReqCreateRoleMsg.roleName = ""; -- 角色名字
ReqCreateRoleMsg.roleProf = 0; -- 角色职业
ReqCreateRoleMsg.iconID = 0; -- 玩家头像
ReqCreateRoleMsg.uf = ""; -- 渠道



ReqCreateRoleMsg.meta = {__index = ReqCreateRoleMsg };
function ReqCreateRoleMsg:new()
	local obj = setmetatable( {}, ReqCreateRoleMsg.meta);
	return obj;
end

function ReqCreateRoleMsg:encode()
	local body = "";

	body = body ..writeString(self.roleName,32);
	body = body ..writeInt(self.roleProf);
	body = body ..writeInt(self.iconID);
	body = body ..writeString(self.uf,32);

	return body;
end

function ReqCreateRoleMsg:ParseData(pak)
	local idx = 1;

	self.roleName, idx = readString(pak, idx, 32);
	self.roleProf, idx = readInt(pak, idx);
	self.iconID, idx = readInt(pak, idx);
	self.uf, idx = readString(pak, idx, 32);

end



--[[
请求登录-TX
]]
_G.ReqConnSrvTXMsg = {};

ReqConnSrvTXMsg.msgId = 1005;
ReqConnSrvTXMsg.openid = ""; -- openid
ReqConnSrvTXMsg.openkey = ""; -- openkey
ReqConnSrvTXMsg.seqid = ""; -- seqid
ReqConnSrvTXMsg.pfkey = ""; -- pfkey
ReqConnSrvTXMsg.pf = ""; -- pf
ReqConnSrvTXMsg.serverid = 0; -- serverid
ReqConnSrvTXMsg.mac = ""; -- 物理地址
ReqConnSrvTXMsg.version = ""; -- 协议版本
ReqConnSrvTXMsg.virtualIP = 0; -- 伪造IP



ReqConnSrvTXMsg.meta = {__index = ReqConnSrvTXMsg };
function ReqConnSrvTXMsg:new()
	local obj = setmetatable( {}, ReqConnSrvTXMsg.meta);
	return obj;
end

function ReqConnSrvTXMsg:encode()
	local body = "";

	body = body ..writeString(self.openid,64);
	body = body ..writeString(self.openkey,64);
	body = body ..writeString(self.seqid,64);
	body = body ..writeString(self.pfkey,64);
	body = body ..writeString(self.pf,32);
	body = body ..writeInt(self.serverid);
	body = body ..writeString(self.mac,32);
	body = body ..writeString(self.version,33);
	body = body ..writeInt(self.virtualIP);

	return body;
end

function ReqConnSrvTXMsg:ParseData(pak)
	local idx = 1;

	self.openid, idx = readString(pak, idx, 64);
	self.openkey, idx = readString(pak, idx, 64);
	self.seqid, idx = readString(pak, idx, 64);
	self.pfkey, idx = readString(pak, idx, 64);
	self.pf, idx = readString(pak, idx, 32);
	self.serverid, idx = readInt(pak, idx);
	self.mac, idx = readString(pak, idx, 32);
	self.version, idx = readString(pak, idx, 33);
	self.virtualIP, idx = readInt(pak, idx);

end



--[[
请求进入游戏
]]
_G.ReqEnterGameMsg = {};

ReqEnterGameMsg.msgId = 2001;
ReqEnterGameMsg.accountID = ""; -- 玩家ID
ReqEnterGameMsg.IP = ""; -- Client IP
ReqEnterGameMsg.mac = ""; -- 物理地址
ReqEnterGameMsg.ltype = 0; -- 登录类型:0web,1微端



ReqEnterGameMsg.meta = {__index = ReqEnterGameMsg };
function ReqEnterGameMsg:new()
	local obj = setmetatable( {}, ReqEnterGameMsg.meta);
	return obj;
end

function ReqEnterGameMsg:encode()
	local body = "";

	body = body ..writeString(self.accountID,32);
	body = body ..writeString(self.IP,32);
	body = body ..writeString(self.mac,32);
	body = body ..writeInt(self.ltype);

	return body;
end

function ReqEnterGameMsg:ParseData(pak)
	local idx = 1;

	self.accountID, idx = readString(pak, idx, 32);
	self.IP, idx = readString(pak, idx, 32);
	self.mac, idx = readString(pak, idx, 32);
	self.ltype, idx = readInt(pak, idx);

end



--[[
进入游戏返回
]]
_G.ResEnterGameMsg = {};

ResEnterGameMsg.msgId = 7001;
ResEnterGameMsg.reason = 0; -- 失败原因 1:服务器未启动 2:玩家已在线



ResEnterGameMsg.meta = {__index = ResEnterGameMsg };
function ResEnterGameMsg:new()
	local obj = setmetatable( {}, ResEnterGameMsg.meta);
	return obj;
end

function ResEnterGameMsg:encode()
	local body = "";

	body = body ..writeInt(self.reason);

	return body;
end

function ResEnterGameMsg:ParseData(pak)
	local idx = 1;

	self.reason, idx = readInt(pak, idx);

end



--[[
发送聊天
]]
_G.ReqChatMsg = {};

ReqChatMsg.msgId = 2002;
ReqChatMsg.channel = 0; -- 频道,1全部,2世界,3区域,3军团,4阵营,5帮派,6组队,7喇叭,8私聊
ReqChatMsg.toID = ""; -- 私聊时,接受者的ID
ReqChatMsg.text = ""; -- 内容



ReqChatMsg.meta = {__index = ReqChatMsg };
function ReqChatMsg:new()
	local obj = setmetatable( {}, ReqChatMsg.meta);
	return obj;
end

function ReqChatMsg:encode()
	local body = "";

	body = body ..writeInt(self.channel);
	body = body ..writeGuid(self.toID);
	body = body ..writeString(self.text);

	return body;
end

function ReqChatMsg:ParseData(pak)
	local idx = 1;

	self.channel, idx = readInt(pak, idx);
	self.toID, idx = readGuid(pak, idx);
	self.text, idx = readString(pak, idx);

end



--[[
设置是否接收对方的私聊信息
]]
_G.ReqPrivateChatStateMsg = {};

ReqPrivateChatStateMsg.msgId = 2004;
ReqPrivateChatStateMsg.roleID = ""; -- 对方ID
ReqPrivateChatStateMsg.state = 0; -- 私聊状态,1接受对方私聊,0关闭私聊



ReqPrivateChatStateMsg.meta = {__index = ReqPrivateChatStateMsg };
function ReqPrivateChatStateMsg:new()
	local obj = setmetatable( {}, ReqPrivateChatStateMsg.meta);
	return obj;
end

function ReqPrivateChatStateMsg:encode()
	local body = "";

	body = body ..writeGuid(self.roleID);
	body = body ..writeInt(self.state);

	return body;
end

function ReqPrivateChatStateMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
请求队伍信息,不在队伍中不返回
]]
_G.ReqTeamInfoMsg = {};

ReqTeamInfoMsg.msgId = 2007;
ReqTeamInfoMsg.teamId = ""; -- 队伍id



ReqTeamInfoMsg.meta = {__index = ReqTeamInfoMsg };
function ReqTeamInfoMsg:new()
	local obj = setmetatable( {}, ReqTeamInfoMsg.meta);
	return obj;
end

function ReqTeamInfoMsg:encode()
	local body = "";

	body = body ..writeGuid(self.teamId);

	return body;
end

function ReqTeamInfoMsg:ParseData(pak)
	local idx = 1;

	self.teamId, idx = readGuid(pak, idx);

end



--[[
请求创建队伍(结果走公告聊天)
]]
_G.ReqTeamCreateMsg = {};

ReqTeamCreateMsg.msgId = 2008;
ReqTeamCreateMsg.targetRoleID = ""; -- 被邀请人,没有直接创建队伍,有创建队伍并邀请



ReqTeamCreateMsg.meta = {__index = ReqTeamCreateMsg };
function ReqTeamCreateMsg:new()
	local obj = setmetatable( {}, ReqTeamCreateMsg.meta);
	return obj;
end

function ReqTeamCreateMsg:encode()
	local body = "";

	body = body ..writeGuid(self.targetRoleID);

	return body;
end

function ReqTeamCreateMsg:ParseData(pak)
	local idx = 1;

	self.targetRoleID, idx = readGuid(pak, idx);

end



--[[
申请入队(结果走公告聊天)
]]
_G.ReqTeamApplyMsg = {};

ReqTeamApplyMsg.msgId = 2009;
ReqTeamApplyMsg.teamId = ""; -- 队伍id



ReqTeamApplyMsg.meta = {__index = ReqTeamApplyMsg };
function ReqTeamApplyMsg:new()
	local obj = setmetatable( {}, ReqTeamApplyMsg.meta);
	return obj;
end

function ReqTeamApplyMsg:encode()
	local body = "";

	body = body ..writeGuid(self.teamId);

	return body;
end

function ReqTeamApplyMsg:ParseData(pak)
	local idx = 1;

	self.teamId, idx = readGuid(pak, idx);

end



--[[
邀请入队(结果走公告聊天)
]]
_G.ReqTeamInviteMsg = {};

ReqTeamInviteMsg.msgId = 2010;
ReqTeamInviteMsg.targetRoleID = ""; -- 被邀请人



ReqTeamInviteMsg.meta = {__index = ReqTeamInviteMsg };
function ReqTeamInviteMsg:new()
	local obj = setmetatable( {}, ReqTeamInviteMsg.meta);
	return obj;
end

function ReqTeamInviteMsg:encode()
	local body = "";

	body = body ..writeGuid(self.targetRoleID);

	return body;
end

function ReqTeamInviteMsg:ParseData(pak)
	local idx = 1;

	self.targetRoleID, idx = readGuid(pak, idx);

end



--[[
请求退出队伍(结果走公告聊天)
]]
_G.ReqTeamQuitMsg = {};

ReqTeamQuitMsg.msgId = 2011;



ReqTeamQuitMsg.meta = {__index = ReqTeamQuitMsg };
function ReqTeamQuitMsg:new()
	local obj = setmetatable( {}, ReqTeamQuitMsg.meta);
	return obj;
end

function ReqTeamQuitMsg:encode()
	local body = "";


	return body;
end

function ReqTeamQuitMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求转让队长(结果走公告聊天)
]]
_G.ReqTeamTransferMsg = {};

ReqTeamTransferMsg.msgId = 2012;
ReqTeamTransferMsg.targetRoleID = ""; -- 目标



ReqTeamTransferMsg.meta = {__index = ReqTeamTransferMsg };
function ReqTeamTransferMsg:new()
	local obj = setmetatable( {}, ReqTeamTransferMsg.meta);
	return obj;
end

function ReqTeamTransferMsg:encode()
	local body = "";

	body = body ..writeGuid(self.targetRoleID);

	return body;
end

function ReqTeamTransferMsg:ParseData(pak)
	local idx = 1;

	self.targetRoleID, idx = readGuid(pak, idx);

end



--[[
请求开除(结果走公告聊天)
]]
_G.ReqTeamFireMsg = {};

ReqTeamFireMsg.msgId = 2013;
ReqTeamFireMsg.targetRoleID = ""; -- 目标



ReqTeamFireMsg.meta = {__index = ReqTeamFireMsg };
function ReqTeamFireMsg:new()
	local obj = setmetatable( {}, ReqTeamFireMsg.meta);
	return obj;
end

function ReqTeamFireMsg:encode()
	local body = "";

	body = body ..writeGuid(self.targetRoleID);

	return body;
end

function ReqTeamFireMsg:ParseData(pak)
	local idx = 1;

	self.targetRoleID, idx = readGuid(pak, idx);

end



--[[
入队审批
]]
_G.ReqTeamJoinApproveMsg = {};

ReqTeamJoinApproveMsg.msgId = 2017;
ReqTeamJoinApproveMsg.targetRoleID = ""; -- 目标
ReqTeamJoinApproveMsg.operate = 0; -- 1同意0拒绝



ReqTeamJoinApproveMsg.meta = {__index = ReqTeamJoinApproveMsg };
function ReqTeamJoinApproveMsg:new()
	local obj = setmetatable( {}, ReqTeamJoinApproveMsg.meta);
	return obj;
end

function ReqTeamJoinApproveMsg:encode()
	local body = "";

	body = body ..writeGuid(self.targetRoleID);
	body = body ..writeInt(self.operate);

	return body;
end

function ReqTeamJoinApproveMsg:ParseData(pak)
	local idx = 1;

	self.targetRoleID, idx = readGuid(pak, idx);
	self.operate, idx = readInt(pak, idx);

end



--[[
入队邀请反馈
]]
_G.ReqTeamInviteApprove = {};

ReqTeamInviteApprove.msgId = 2018;
ReqTeamInviteApprove.teamId = ""; -- 队伍id
ReqTeamInviteApprove.operate = 0; -- 1同意0拒绝



ReqTeamInviteApprove.meta = {__index = ReqTeamInviteApprove };
function ReqTeamInviteApprove:new()
	local obj = setmetatable( {}, ReqTeamInviteApprove.meta);
	return obj;
end

function ReqTeamInviteApprove:encode()
	local body = "";

	body = body ..writeGuid(self.teamId);
	body = body ..writeInt(self.operate);

	return body;
end

function ReqTeamInviteApprove:ParseData(pak)
	local idx = 1;

	self.teamId, idx = readGuid(pak, idx);
	self.operate, idx = readInt(pak, idx);

end



--[[
组队设置
]]
_G.ReqTeamSettingMsg = {};

ReqTeamSettingMsg.msgId = 2019;
ReqTeamSettingMsg.autoTeam = 0; -- 自己,自动组队1, 需询问0
ReqTeamSettingMsg.autoAgreeEnter = 0; -- 队长,自动同意进入队伍1, 需询问0



ReqTeamSettingMsg.meta = {__index = ReqTeamSettingMsg };
function ReqTeamSettingMsg:new()
	local obj = setmetatable( {}, ReqTeamSettingMsg.meta);
	return obj;
end

function ReqTeamSettingMsg:encode()
	local body = "";

	body = body ..writeInt(self.autoTeam);
	body = body ..writeInt(self.autoAgreeEnter);

	return body;
end

function ReqTeamSettingMsg:ParseData(pak)
	local idx = 1;

	self.autoTeam, idx = readInt(pak, idx);
	self.autoAgreeEnter, idx = readInt(pak, idx);

end



--[[
请求附近队伍
]]
_G.ReqTeamNearbyTeamMsg = {};

ReqTeamNearbyTeamMsg.msgId = 2020;



ReqTeamNearbyTeamMsg.meta = {__index = ReqTeamNearbyTeamMsg };
function ReqTeamNearbyTeamMsg:new()
	local obj = setmetatable( {}, ReqTeamNearbyTeamMsg.meta);
	return obj;
end

function ReqTeamNearbyTeamMsg:encode()
	local body = "";


	return body;
end

function ReqTeamNearbyTeamMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求附近玩家
]]
_G.ReqTeamNearbyRoleMsg = {};

ReqTeamNearbyRoleMsg.msgId = 2021;



ReqTeamNearbyRoleMsg.meta = {__index = ReqTeamNearbyRoleMsg };
function ReqTeamNearbyRoleMsg:new()
	local obj = setmetatable( {}, ReqTeamNearbyRoleMsg.meta);
	return obj;
end

function ReqTeamNearbyRoleMsg:encode()
	local body = "";


	return body;
end

function ReqTeamNearbyRoleMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求换线
]]
_G.ReqSwitchLineMsg = {};

ReqSwitchLineMsg.msgId = 2023;
ReqSwitchLineMsg.lineID = 0; -- 



ReqSwitchLineMsg.meta = {__index = ReqSwitchLineMsg };
function ReqSwitchLineMsg:new()
	local obj = setmetatable( {}, ReqSwitchLineMsg.meta);
	return obj;
end

function ReqSwitchLineMsg:encode()
	local body = "";

	body = body ..writeInt(self.lineID);

	return body;
end

function ReqSwitchLineMsg:ParseData(pak)
	local idx = 1;

	self.lineID, idx = readInt(pak, idx);

end



--[[
线列表
]]
_G.ReqLineListMsg = {};

ReqLineListMsg.msgId = 2024;



ReqLineListMsg.meta = {__index = ReqLineListMsg };
function ReqLineListMsg:new()
	local obj = setmetatable( {}, ReqLineListMsg.meta);
	return obj;
end

function ReqLineListMsg:encode()
	local body = "";


	return body;
end

function ReqLineListMsg:ParseData(pak)
	local idx = 1;


end



--[[
添加好友
]]
_G.ReqAddFriend = {};

ReqAddFriend.msgId = 2025;
ReqAddFriend.roleName = ""; -- 角色名称



ReqAddFriend.meta = {__index = ReqAddFriend };
function ReqAddFriend:new()
	local obj = setmetatable( {}, ReqAddFriend.meta);
	return obj;
end

function ReqAddFriend:encode()
	local body = "";

	body = body ..writeString(self.roleName,32);

	return body;
end

function ReqAddFriend:ParseData(pak)
	local idx = 1;

	self.roleName, idx = readString(pak, idx, 32);

end



--[[
目标添加好友反馈
]]
_G.ReqAddFriendApprove = {};

ReqAddFriendApprove.msgId = 2026;
ReqAddFriendApprove.approveList_size = 0; -- 列表 size
ReqAddFriendApprove.approveList = {}; -- 列表 list

--[[
FriendApproveVOVO = {
	agree = 0; -- 0 - 同意， 1 - 不同意 
	roleID = ""; -- 角色ID
}
]]

ReqAddFriendApprove.meta = {__index = ReqAddFriendApprove };
function ReqAddFriendApprove:new()
	local obj = setmetatable( {}, ReqAddFriendApprove.meta);
	return obj;
end

function ReqAddFriendApprove:encode()
	local body = "";


	local list1 = self.approveList;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeInt(list1[i1].agree);
		body = body .. writeGuid(list1[i1].roleID);
	end

	return body;
end

function ReqAddFriendApprove:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.approveList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local FriendApproveVOVo = {};
		FriendApproveVOVo.agree, idx = readInt(pak, idx);
		FriendApproveVOVo.roleID, idx = readGuid(pak, idx);
		table.push(list1,FriendApproveVOVo);
	end

end



--[[
添加到黑名单
]]
_G.ReqAddBlackList = {};

ReqAddBlackList.msgId = 2027;
ReqAddBlackList.roleID = ""; -- 角色ID



ReqAddBlackList.meta = {__index = ReqAddBlackList };
function ReqAddBlackList:new()
	local obj = setmetatable( {}, ReqAddBlackList.meta);
	return obj;
end

function ReqAddBlackList:encode()
	local body = "";

	body = body ..writeGuid(self.roleID);

	return body;
end

function ReqAddBlackList:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);

end



--[[
删除关系
]]
_G.ReqRemoveRelation = {};

ReqRemoveRelation.msgId = 2028;
ReqRemoveRelation.roleID = ""; -- 角色ID
ReqRemoveRelation.relationType = 0; -- 关系类型 好友1, 仇人2, 黑名单3, 最近联系人4



ReqRemoveRelation.meta = {__index = ReqRemoveRelation };
function ReqRemoveRelation:new()
	local obj = setmetatable( {}, ReqRemoveRelation.meta);
	return obj;
end

function ReqRemoveRelation:encode()
	local body = "";

	body = body ..writeGuid(self.roleID);
	body = body ..writeInt(self.relationType);

	return body;
end

function ReqRemoveRelation:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.relationType, idx = readInt(pak, idx);

end



--[[
添加推荐好友
]]
_G.ReqAddFriendRecommend = {};

ReqAddFriendRecommend.msgId = 2029;
ReqAddFriendRecommend.AddFriendList_size = 0; -- 列表 size
ReqAddFriendRecommend.AddFriendList = {}; -- 列表 list

--[[
AddFriendVoVO = {
	roleID = ""; -- 角色ID
}
]]

ReqAddFriendRecommend.meta = {__index = ReqAddFriendRecommend };
function ReqAddFriendRecommend:new()
	local obj = setmetatable( {}, ReqAddFriendRecommend.meta);
	return obj;
end

function ReqAddFriendRecommend:encode()
	local body = "";


	local list1 = self.AddFriendList;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeGuid(list1[i1].roleID);
	end

	return body;
end

function ReqAddFriendRecommend:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.AddFriendList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local AddFriendVoVo = {};
		AddFriendVoVo.roleID, idx = readGuid(pak, idx);
		table.push(list1,AddFriendVoVo);
	end

end



--[[
请求推荐好友列表
]]
_G.ReqAskRecommendList = {};

ReqAskRecommendList.msgId = 2030;



ReqAskRecommendList.meta = {__index = ReqAskRecommendList };
function ReqAskRecommendList:new()
	local obj = setmetatable( {}, ReqAskRecommendList.meta);
	return obj;
end

function ReqAskRecommendList:encode()
	local body = "";


	return body;
end

function ReqAskRecommendList:ParseData(pak)
	local idx = 1;


end



--[[
请求关系改变列表
]]
_G.ReqRelationChangeList = {};

ReqRelationChangeList.msgId = 2031;



ReqRelationChangeList.meta = {__index = ReqRelationChangeList };
function ReqRelationChangeList:new()
	local obj = setmetatable( {}, ReqRelationChangeList.meta);
	return obj;
end

function ReqRelationChangeList:encode()
	local body = "";


	return body;
end

function ReqRelationChangeList:ParseData(pak)
	local idx = 1;


end



--[[
请求获取邮件列表
]]
_G.ReqGetMailList = {};

ReqGetMailList.msgId = 2032;



ReqGetMailList.meta = {__index = ReqGetMailList };
function ReqGetMailList:new()
	local obj = setmetatable( {}, ReqGetMailList.meta);
	return obj;
end

function ReqGetMailList:encode()
	local body = "";


	return body;
end

function ReqGetMailList:ParseData(pak)
	local idx = 1;


end



--[[
请求打开邮件
]]
_G.ReqOpenMail = {};

ReqOpenMail.msgId = 2033;
ReqOpenMail.mailid = ""; -- 邮件id



ReqOpenMail.meta = {__index = ReqOpenMail };
function ReqOpenMail:new()
	local obj = setmetatable( {}, ReqOpenMail.meta);
	return obj;
end

function ReqOpenMail:encode()
	local body = "";

	body = body ..writeGuid(self.mailid);

	return body;
end

function ReqOpenMail:ParseData(pak)
	local idx = 1;

	self.mailid, idx = readGuid(pak, idx);

end



--[[
请求领取附件
]]
_G.ReqMailItem = {};

ReqMailItem.msgId = 2034;
ReqMailItem.MailList_size = 0; --  size
ReqMailItem.MailList = {}; --  list

--[[
MailReqItemVoVO = {
	mailid = ""; -- 邮件id
}
]]

ReqMailItem.meta = {__index = ReqMailItem };
function ReqMailItem:new()
	local obj = setmetatable( {}, ReqMailItem.meta);
	return obj;
end

function ReqMailItem:encode()
	local body = "";


	local list1 = self.MailList;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeGuid(list1[i1].mailid);
	end

	return body;
end

function ReqMailItem:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.MailList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local MailReqItemVoVo = {};
		MailReqItemVoVo.mailid, idx = readGuid(pak, idx);
		table.push(list1,MailReqItemVoVo);
	end

end



--[[
请求删除邮件
]]
_G.ReqDelMail = {};

ReqDelMail.msgId = 2035;
ReqDelMail.MailList_size = 0; --  size
ReqDelMail.MailList = {}; --  list

--[[
ReqMailDelVoVO = {
	mailid = ""; -- 邮件id
}
]]

ReqDelMail.meta = {__index = ReqDelMail };
function ReqDelMail:new()
	local obj = setmetatable( {}, ReqDelMail.meta);
	return obj;
end

function ReqDelMail:encode()
	local body = "";


	local list1 = self.MailList;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeGuid(list1[i1].mailid);
	end

	return body;
end

function ReqDelMail:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.MailList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ReqMailDelVoVo = {};
		ReqMailDelVoVo.mailid, idx = readGuid(pak, idx);
		table.push(list1,ReqMailDelVoVo);
	end

end



--[[
队员回复是否同意加入组队副本
]]
_G.ReqReplyTeamDungeonMsg = {};

ReqReplyTeamDungeonMsg.msgId = 2037;
ReqReplyTeamDungeonMsg.reply = 0; -- 答复结果:1同意，0拒绝



ReqReplyTeamDungeonMsg.meta = {__index = ReqReplyTeamDungeonMsg };
function ReqReplyTeamDungeonMsg:new()
	local obj = setmetatable( {}, ReqReplyTeamDungeonMsg.meta);
	return obj;
end

function ReqReplyTeamDungeonMsg:encode()
	local body = "";

	body = body ..writeInt(self.reply);

	return body;
end

function ReqReplyTeamDungeonMsg:ParseData(pak)
	local idx = 1;

	self.reply, idx = readInt(pak, idx);

end



--[[
请求帮派列表
]]
_G.ReqGuildList = {};

ReqGuildList.msgId = 2038;
ReqGuildList.page = 0; -- 页数
ReqGuildList.onlyAutoAgree = 0; -- 1 - 仅显示自动同意， 0 - 都显示



ReqGuildList.meta = {__index = ReqGuildList };
function ReqGuildList:new()
	local obj = setmetatable( {}, ReqGuildList.meta);
	return obj;
end

function ReqGuildList:encode()
	local body = "";

	body = body ..writeInt(self.page);
	body = body ..writeInt(self.onlyAutoAgree);

	return body;
end

function ReqGuildList:ParseData(pak)
	local idx = 1;

	self.page, idx = readInt(pak, idx);
	self.onlyAutoAgree, idx = readInt(pak, idx);

end



--[[
请求自己帮派信息
]]
_G.ReqMyGuildInfo = {};

ReqMyGuildInfo.msgId = 2039;



ReqMyGuildInfo.meta = {__index = ReqMyGuildInfo };
function ReqMyGuildInfo:new()
	local obj = setmetatable( {}, ReqMyGuildInfo.meta);
	return obj;
end

function ReqMyGuildInfo:encode()
	local body = "";


	return body;
end

function ReqMyGuildInfo:ParseData(pak)
	local idx = 1;


end



--[[
请求自己帮派成员列表
]]
_G.ReqMyGuildMems = {};

ReqMyGuildMems.msgId = 2040;



ReqMyGuildMems.meta = {__index = ReqMyGuildMems };
function ReqMyGuildMems:new()
	local obj = setmetatable( {}, ReqMyGuildMems.meta);
	return obj;
end

function ReqMyGuildMems:encode()
	local body = "";


	return body;
end

function ReqMyGuildMems:ParseData(pak)
	local idx = 1;


end



--[[
请求自己帮派事件
]]
_G.ReqMyGuildEvents = {};

ReqMyGuildEvents.msgId = 2041;



ReqMyGuildEvents.meta = {__index = ReqMyGuildEvents };
function ReqMyGuildEvents:new()
	local obj = setmetatable( {}, ReqMyGuildEvents.meta);
	return obj;
end

function ReqMyGuildEvents:encode()
	local body = "";


	return body;
end

function ReqMyGuildEvents:ParseData(pak)
	local idx = 1;


end



--[[
请求创建帮派
]]
_G.ReqCreateGuild = {};

ReqCreateGuild.msgId = 2042;
ReqCreateGuild.name = ""; -- 帮派名称
ReqCreateGuild.notice = ""; -- 帮派公告



ReqCreateGuild.meta = {__index = ReqCreateGuild };
function ReqCreateGuild:new()
	local obj = setmetatable( {}, ReqCreateGuild.meta);
	return obj;
end

function ReqCreateGuild:encode()
	local body = "";

	body = body ..writeString(self.name,32);
	body = body ..writeString(self.notice,256);

	return body;
end

function ReqCreateGuild:ParseData(pak)
	local idx = 1;

	self.name, idx = readString(pak, idx, 32);
	self.notice, idx = readString(pak, idx, 256);

end



--[[
退出帮派
]]
_G.ReqQuitGuild = {};

ReqQuitGuild.msgId = 2043;



ReqQuitGuild.meta = {__index = ReqQuitGuild };
function ReqQuitGuild:new()
	local obj = setmetatable( {}, ReqQuitGuild.meta);
	return obj;
end

function ReqQuitGuild:encode()
	local body = "";


	return body;
end

function ReqQuitGuild:ParseData(pak)
	local idx = 1;


end



--[[
解散帮派
]]
_G.ReqDismissGuild = {};

ReqDismissGuild.msgId = 2044;



ReqDismissGuild.meta = {__index = ReqDismissGuild };
function ReqDismissGuild:new()
	local obj = setmetatable( {}, ReqDismissGuild.meta);
	return obj;
end

function ReqDismissGuild:encode()
	local body = "";


	return body;
end

function ReqDismissGuild:ParseData(pak)
	local idx = 1;


end



--[[
升级帮派
]]
_G.ReqLvUpGuild = {};

ReqLvUpGuild.msgId = 2045;



ReqLvUpGuild.meta = {__index = ReqLvUpGuild };
function ReqLvUpGuild:new()
	local obj = setmetatable( {}, ReqLvUpGuild.meta);
	return obj;
end

function ReqLvUpGuild:encode()
	local body = "";


	return body;
end

function ReqLvUpGuild:ParseData(pak)
	local idx = 1;


end



--[[
开启某组帮派技能
]]
_G.ReqLvUpGuildSkill = {};

ReqLvUpGuildSkill.msgId = 2046;
ReqLvUpGuildSkill.groupId = 0; -- 技能组ID



ReqLvUpGuildSkill.meta = {__index = ReqLvUpGuildSkill };
function ReqLvUpGuildSkill:new()
	local obj = setmetatable( {}, ReqLvUpGuildSkill.meta);
	return obj;
end

function ReqLvUpGuildSkill:encode()
	local body = "";

	body = body ..writeInt(self.groupId);

	return body;
end

function ReqLvUpGuildSkill:ParseData(pak)
	local idx = 1;

	self.groupId, idx = readInt(pak, idx);

end



--[[
改变职位
]]
_G.ReqChangeGuildPos = {};

ReqChangeGuildPos.msgId = 2047;
ReqChangeGuildPos.memGid = ""; -- 玩家ID
ReqChangeGuildPos.pos = 0; -- 职位



ReqChangeGuildPos.meta = {__index = ReqChangeGuildPos };
function ReqChangeGuildPos:new()
	local obj = setmetatable( {}, ReqChangeGuildPos.meta);
	return obj;
end

function ReqChangeGuildPos:encode()
	local body = "";

	body = body ..writeGuid(self.memGid);
	body = body ..writeInt(self.pos);

	return body;
end

function ReqChangeGuildPos:ParseData(pak)
	local idx = 1;

	self.memGid, idx = readGuid(pak, idx);
	self.pos, idx = readInt(pak, idx);

end



--[[
改变帮派公告
]]
_G.ReqChangeGuildNotice = {};

ReqChangeGuildNotice.msgId = 2048;
ReqChangeGuildNotice.notice = ""; -- 公告内容



ReqChangeGuildNotice.meta = {__index = ReqChangeGuildNotice };
function ReqChangeGuildNotice:new()
	local obj = setmetatable( {}, ReqChangeGuildNotice.meta);
	return obj;
end

function ReqChangeGuildNotice:encode()
	local body = "";

	body = body ..writeString(self.notice,256);

	return body;
end

function ReqChangeGuildNotice:ParseData(pak)
	local idx = 1;

	self.notice, idx = readString(pak, idx, 256);

end



--[[
审核申请
]]
_G.ReqVerifyGuildApply = {};

ReqVerifyGuildApply.msgId = 2049;
ReqVerifyGuildApply.verify = 0; -- 是否同意0 - 同意，1 - 拒绝
ReqVerifyGuildApply.GuildApplyList_size = 0; -- 帮派成员列表 size
ReqVerifyGuildApply.GuildApplyList = {}; -- 帮派成员列表 list

--[[
ReqGuildApplyVoVO = {
	memGid = ""; -- 玩家ID
}
]]

ReqVerifyGuildApply.meta = {__index = ReqVerifyGuildApply };
function ReqVerifyGuildApply:new()
	local obj = setmetatable( {}, ReqVerifyGuildApply.meta);
	return obj;
end

function ReqVerifyGuildApply:encode()
	local body = "";

	body = body ..writeInt(self.verify);

	local list1 = self.GuildApplyList;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeGuid(list1[i1].memGid);
	end

	return body;
end

function ReqVerifyGuildApply:ParseData(pak)
	local idx = 1;

	self.verify, idx = readInt(pak, idx);

	local list1 = {};
	self.GuildApplyList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ReqGuildApplyVoVo = {};
		ReqGuildApplyVoVo.memGid, idx = readGuid(pak, idx);
		table.push(list1,ReqGuildApplyVoVo);
	end

end



--[[
踢出帮派成员
]]
_G.ReqKickGuildMem = {};

ReqKickGuildMem.msgId = 2050;
ReqKickGuildMem.memGid = ""; -- 玩家ID



ReqKickGuildMem.meta = {__index = ReqKickGuildMem };
function ReqKickGuildMem:new()
	local obj = setmetatable( {}, ReqKickGuildMem.meta);
	return obj;
end

function ReqKickGuildMem:encode()
	local body = "";

	body = body ..writeGuid(self.memGid);

	return body;
end

function ReqKickGuildMem:ParseData(pak)
	local idx = 1;

	self.memGid, idx = readGuid(pak, idx);

end



--[[
申请加入帮派
]]
_G.ReqApplyGuild = {};

ReqApplyGuild.msgId = 2051;
ReqApplyGuild.guildId = ""; -- 帮派id
ReqApplyGuild.bApply = 0; -- 0-取消， 1-申请



ReqApplyGuild.meta = {__index = ReqApplyGuild };
function ReqApplyGuild:new()
	local obj = setmetatable( {}, ReqApplyGuild.meta);
	return obj;
end

function ReqApplyGuild:encode()
	local body = "";

	body = body ..writeGuid(self.guildId);
	body = body ..writeInt(self.bApply);

	return body;
end

function ReqApplyGuild:ParseData(pak)
	local idx = 1;

	self.guildId, idx = readGuid(pak, idx);
	self.bApply, idx = readInt(pak, idx);

end



--[[
邀请加入帮派
]]
_G.ReqInviteToGuild = {};

ReqInviteToGuild.msgId = 2052;
ReqInviteToGuild.guildId = ""; -- 帮派id
ReqInviteToGuild.memName = ""; -- 玩家名称



ReqInviteToGuild.meta = {__index = ReqInviteToGuild };
function ReqInviteToGuild:new()
	local obj = setmetatable( {}, ReqInviteToGuild.meta);
	return obj;
end

function ReqInviteToGuild:encode()
	local body = "";

	body = body ..writeGuid(self.guildId);
	body = body ..writeString(self.memName,32);

	return body;
end

function ReqInviteToGuild:ParseData(pak)
	local idx = 1;

	self.guildId, idx = readGuid(pak, idx);
	self.memName, idx = readString(pak, idx, 32);

end



--[[
同意拒绝邀请加入帮派
]]
_G.ReqInviteToGuildResult = {};

ReqInviteToGuildResult.msgId = 2053;
ReqInviteToGuildResult.inviterId = ""; -- 邀请人id
ReqInviteToGuildResult.result = 0; -- 结果 0 - 同意，1 - 不同意



ReqInviteToGuildResult.meta = {__index = ReqInviteToGuildResult };
function ReqInviteToGuildResult:new()
	local obj = setmetatable( {}, ReqInviteToGuildResult.meta);
	return obj;
end

function ReqInviteToGuildResult:encode()
	local body = "";

	body = body ..writeGuid(self.inviterId);
	body = body ..writeInt(self.result);

	return body;
end

function ReqInviteToGuildResult:ParseData(pak)
	local idx = 1;

	self.inviterId, idx = readGuid(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
设置自动申请审核
]]
_G.ReqSetAutoVerify = {};

ReqSetAutoVerify.msgId = 2055;
ReqSetAutoVerify.bAuto = 0; -- 结果 1 - 自动，1 - 不自动
ReqSetAutoVerify.level = 0; -- 档数



ReqSetAutoVerify.meta = {__index = ReqSetAutoVerify };
function ReqSetAutoVerify:new()
	local obj = setmetatable( {}, ReqSetAutoVerify.meta);
	return obj;
end

function ReqSetAutoVerify:encode()
	local body = "";

	body = body ..writeInt(self.bAuto);
	body = body ..writeInt(self.level);

	return body;
end

function ReqSetAutoVerify:ParseData(pak)
	local idx = 1;

	self.bAuto, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);

end



--[[
请求其他帮派信息
]]
_G.ReqOtherGuildInfo = {};

ReqOtherGuildInfo.msgId = 2056;
ReqOtherGuildInfo.guildId = ""; -- 帮派id



ReqOtherGuildInfo.meta = {__index = ReqOtherGuildInfo };
function ReqOtherGuildInfo:new()
	local obj = setmetatable( {}, ReqOtherGuildInfo.meta);
	return obj;
end

function ReqOtherGuildInfo:encode()
	local body = "";

	body = body ..writeGuid(self.guildId);

	return body;
end

function ReqOtherGuildInfo:ParseData(pak)
	local idx = 1;

	self.guildId, idx = readGuid(pak, idx);

end



--[[
请求自己帮派申请
]]
_G.ReqMyGuildApplys = {};

ReqMyGuildApplys.msgId = 2057;



ReqMyGuildApplys.meta = {__index = ReqMyGuildApplys };
function ReqMyGuildApplys:new()
	local obj = setmetatable( {}, ReqMyGuildApplys.meta);
	return obj;
end

function ReqMyGuildApplys:encode()
	local body = "";


	return body;
end

function ReqMyGuildApplys:ParseData(pak)
	local idx = 1;


end



--[[
请求禅让帮主
]]
_G.ReqChangeLeader = {};

ReqChangeLeader.msgId = 2058;
ReqChangeLeader.memGid = ""; -- 玩家ID



ReqChangeLeader.meta = {__index = ReqChangeLeader };
function ReqChangeLeader:new()
	local obj = setmetatable( {}, ReqChangeLeader.meta);
	return obj;
end

function ReqChangeLeader:encode()
	local body = "";

	body = body ..writeGuid(self.memGid);

	return body;
end

function ReqChangeLeader:ParseData(pak)
	local idx = 1;

	self.memGid, idx = readGuid(pak, idx);

end



--[[
请求捐献
]]
_G.ReqGuildContribute = {};

ReqGuildContribute.msgId = 2059;
ReqGuildContribute.itemId = 0; -- 资源ID
ReqGuildContribute.count = 0; -- 数量



ReqGuildContribute.meta = {__index = ReqGuildContribute };
function ReqGuildContribute:new()
	local obj = setmetatable( {}, ReqGuildContribute.meta);
	return obj;
end

function ReqGuildContribute:encode()
	local body = "";

	body = body ..writeInt(self.itemId);
	body = body ..writeInt(self.count);

	return body;
end

function ReqGuildContribute:ParseData(pak)
	local idx = 1;

	self.itemId, idx = readInt(pak, idx);
	self.count, idx = readInt(pak, idx);

end



--[[
升级自身帮派技能
]]
_G.ReqLevelUpMyGuildSkill = {};

ReqLevelUpMyGuildSkill.msgId = 2060;
ReqLevelUpMyGuildSkill.groupId = 0; -- 技能组ID



ReqLevelUpMyGuildSkill.meta = {__index = ReqLevelUpMyGuildSkill };
function ReqLevelUpMyGuildSkill:new()
	local obj = setmetatable( {}, ReqLevelUpMyGuildSkill.meta);
	return obj;
end

function ReqLevelUpMyGuildSkill:encode()
	local body = "";

	body = body ..writeInt(self.groupId);

	return body;
end

function ReqLevelUpMyGuildSkill:ParseData(pak)
	local idx = 1;

	self.groupId, idx = readInt(pak, idx);

end



--[[
查找帮派
]]
_G.ReqSearchGuild = {};

ReqSearchGuild.msgId = 2061;
ReqSearchGuild.type = 0; -- 查找类型, (0 -帮派名， 1- 帮主名)
ReqSearchGuild.name = ""; -- 名称



ReqSearchGuild.meta = {__index = ReqSearchGuild };
function ReqSearchGuild:new()
	local obj = setmetatable( {}, ReqSearchGuild.meta);
	return obj;
end

function ReqSearchGuild:encode()
	local body = "";

	body = body ..writeInt(self.type);
	body = body ..writeString(self.name,32);

	return body;
end

function ReqSearchGuild:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.name, idx = readString(pak, idx, 32);

end



--[[
请求世界Boss列表
]]
_G.ReqWorldBossMsg = {};

ReqWorldBossMsg.msgId = 2063;



ReqWorldBossMsg.meta = {__index = ReqWorldBossMsg };
function ReqWorldBossMsg:new()
	local obj = setmetatable( {}, ReqWorldBossMsg.meta);
	return obj;
end

function ReqWorldBossMsg:encode()
	local body = "";


	return body;
end

function ReqWorldBossMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求帮派同盟
]]
_G.ReqGuildAlianceMsg = {};

ReqGuildAlianceMsg.msgId = 2064;
ReqGuildAlianceMsg.guildId = ""; -- 帮派id



ReqGuildAlianceMsg.meta = {__index = ReqGuildAlianceMsg };
function ReqGuildAlianceMsg:new()
	local obj = setmetatable( {}, ReqGuildAlianceMsg.meta);
	return obj;
end

function ReqGuildAlianceMsg:encode()
	local body = "";

	body = body ..writeGuid(self.guildId);

	return body;
end

function ReqGuildAlianceMsg:ParseData(pak)
	local idx = 1;

	self.guildId, idx = readGuid(pak, idx);

end



--[[
请求解散帮派同盟
]]
_G.ReqDismissGuildAlianceMsg = {};

ReqDismissGuildAlianceMsg.msgId = 2065;



ReqDismissGuildAlianceMsg.meta = {__index = ReqDismissGuildAlianceMsg };
function ReqDismissGuildAlianceMsg:new()
	local obj = setmetatable( {}, ReqDismissGuildAlianceMsg.meta);
	return obj;
end

function ReqDismissGuildAlianceMsg:encode()
	local body = "";


	return body;
end

function ReqDismissGuildAlianceMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求帮派同盟申请列表
]]
_G.ReqGuildAlianceApplysMsg = {};

ReqGuildAlianceApplysMsg.msgId = 2066;



ReqGuildAlianceApplysMsg.meta = {__index = ReqGuildAlianceApplysMsg };
function ReqGuildAlianceApplysMsg:new()
	local obj = setmetatable( {}, ReqGuildAlianceApplysMsg.meta);
	return obj;
end

function ReqGuildAlianceApplysMsg:encode()
	local body = "";


	return body;
end

function ReqGuildAlianceApplysMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求帮派同盟信息
]]
_G.ReqAlianceGuildInfo = {};

ReqAlianceGuildInfo.msgId = 2067;



ReqAlianceGuildInfo.meta = {__index = ReqAlianceGuildInfo };
function ReqAlianceGuildInfo:new()
	local obj = setmetatable( {}, ReqAlianceGuildInfo.meta);
	return obj;
end

function ReqAlianceGuildInfo:encode()
	local body = "";


	return body;
end

function ReqAlianceGuildInfo:ParseData(pak)
	local idx = 1;


end



--[[
审核帮派同盟申请
]]
_G.ReqGuildAlianceVerifyMsg = {};

ReqGuildAlianceVerifyMsg.msgId = 2068;
ReqGuildAlianceVerifyMsg.verify = 0; -- 是否同意0 - 同意，1 - 拒绝
ReqGuildAlianceVerifyMsg.GuildAlianceApplyList_size = 0; -- 帮派同盟列表 size
ReqGuildAlianceVerifyMsg.GuildAlianceApplyList = {}; -- 帮派同盟列表 list

--[[
ReqGuildAlianceApplyVoVO = {
	guild = ""; -- 帮派ID
}
]]

ReqGuildAlianceVerifyMsg.meta = {__index = ReqGuildAlianceVerifyMsg };
function ReqGuildAlianceVerifyMsg:new()
	local obj = setmetatable( {}, ReqGuildAlianceVerifyMsg.meta);
	return obj;
end

function ReqGuildAlianceVerifyMsg:encode()
	local body = "";

	body = body ..writeInt(self.verify);

	local list1 = self.GuildAlianceApplyList;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeGuid(list1[i1].guild);
	end

	return body;
end

function ReqGuildAlianceVerifyMsg:ParseData(pak)
	local idx = 1;

	self.verify, idx = readInt(pak, idx);

	local list1 = {};
	self.GuildAlianceApplyList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ReqGuildAlianceApplyVoVo = {};
		ReqGuildAlianceApplyVoVo.guild, idx = readGuid(pak, idx);
		table.push(list1,ReqGuildAlianceApplyVoVo);
	end

end



--[[
请求清除上次洗炼数据或保存本次
]]
_G.ReqClearBapAidInfoMsg = {};

ReqClearBapAidInfoMsg.msgId = 2069;
ReqClearBapAidInfoMsg.state = 0; -- 0 清除， 1 保存



ReqClearBapAidInfoMsg.meta = {__index = ReqClearBapAidInfoMsg };
function ReqClearBapAidInfoMsg:new()
	local obj = setmetatable( {}, ReqClearBapAidInfoMsg.meta);
	return obj;
end

function ReqClearBapAidInfoMsg:encode()
	local body = "";

	body = body ..writeInt(self.state);

	return body;
end

function ReqClearBapAidInfoMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);

end



--[[
请求加持洗炼
]]
_G.ReqUnionBapAidMsg = {};

ReqUnionBapAidMsg.msgId = 2072;



ReqUnionBapAidMsg.meta = {__index = ReqUnionBapAidMsg };
function ReqUnionBapAidMsg:new()
	local obj = setmetatable( {}, ReqUnionBapAidMsg.meta);
	return obj;
end

function ReqUnionBapAidMsg:encode()
	local body = "";


	return body;
end

function ReqUnionBapAidMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求加持属性
]]
_G.ReqAidInfoMsg = {};

ReqAidInfoMsg.msgId = 2071;



ReqAidInfoMsg.meta = {__index = ReqAidInfoMsg };
function ReqAidInfoMsg:new()
	local obj = setmetatable( {}, ReqAidInfoMsg.meta);
	return obj;
end

function ReqAidInfoMsg:encode()
	local body = "";


	return body;
end

function ReqAidInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求加持升级
]]
_G.ReqAidUpLevelMsg = {};

ReqAidUpLevelMsg.msgId = 2073;



ReqAidUpLevelMsg.meta = {__index = ReqAidUpLevelMsg };
function ReqAidUpLevelMsg:new()
	local obj = setmetatable( {}, ReqAidUpLevelMsg.meta);
	return obj;
end

function ReqAidUpLevelMsg:encode()
	local body = "";


	return body;
end

function ReqAidUpLevelMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求人物属性
]]
_G.ReqArenaMyroleAtbMsg = {};

ReqArenaMyroleAtbMsg.msgId = 2100;



ReqArenaMyroleAtbMsg.meta = {__index = ReqArenaMyroleAtbMsg };
function ReqArenaMyroleAtbMsg:new()
	local obj = setmetatable( {}, ReqArenaMyroleAtbMsg.meta);
	return obj;
end

function ReqArenaMyroleAtbMsg:encode()
	local body = "";


	return body;
end

function ReqArenaMyroleAtbMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求被挑战人物list
]]
_G.ReqArenaBeChallengeRolelistMsg = {};

ReqArenaBeChallengeRolelistMsg.msgId = 2101;
ReqArenaBeChallengeRolelistMsg.type = 0; -- 0 - 123名，1 - 挑战对象



ReqArenaBeChallengeRolelistMsg.meta = {__index = ReqArenaBeChallengeRolelistMsg };
function ReqArenaBeChallengeRolelistMsg:new()
	local obj = setmetatable( {}, ReqArenaBeChallengeRolelistMsg.meta);
	return obj;
end

function ReqArenaBeChallengeRolelistMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqArenaBeChallengeRolelistMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
发起挑战
]]
_G.ReqArenaChallengeMsg = {};

ReqArenaChallengeMsg.msgId = 2102;
ReqArenaChallengeMsg.rank = 0; -- 被挑战排名



ReqArenaChallengeMsg.meta = {__index = ReqArenaChallengeMsg };
function ReqArenaChallengeMsg:new()
	local obj = setmetatable( {}, ReqArenaChallengeMsg.meta);
	return obj;
end

function ReqArenaChallengeMsg:encode()
	local body = "";

	body = body ..writeInt(self.rank);

	return body;
end

function ReqArenaChallengeMsg:ParseData(pak)
	local idx = 1;

	self.rank, idx = readInt(pak, idx);

end



--[[
领取奖励
]]
_G.ReqArenaGetRewardItemMsg = {};

ReqArenaGetRewardItemMsg.msgId = 2103;



ReqArenaGetRewardItemMsg.meta = {__index = ReqArenaGetRewardItemMsg };
function ReqArenaGetRewardItemMsg:new()
	local obj = setmetatable( {}, ReqArenaGetRewardItemMsg.meta);
	return obj;
end

function ReqArenaGetRewardItemMsg:encode()
	local body = "";


	return body;
end

function ReqArenaGetRewardItemMsg:ParseData(pak)
	local idx = 1;


end



--[[
竞技战报
]]
_G.ReqArenaSkillInfoMsg = {};

ReqArenaSkillInfoMsg.msgId = 2104;



ReqArenaSkillInfoMsg.meta = {__index = ReqArenaSkillInfoMsg };
function ReqArenaSkillInfoMsg:new()
	local obj = setmetatable( {}, ReqArenaSkillInfoMsg.meta);
	return obj;
end

function ReqArenaSkillInfoMsg:encode()
	local body = "";


	return body;
end

function ReqArenaSkillInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
购买竞技场次数
]]
_G.ReqBuyArenaTimesMsg = {};

ReqBuyArenaTimesMsg.msgId = 2105;



ReqBuyArenaTimesMsg.meta = {__index = ReqBuyArenaTimesMsg };
function ReqBuyArenaTimesMsg:new()
	local obj = setmetatable( {}, ReqBuyArenaTimesMsg.meta);
	return obj;
end

function ReqBuyArenaTimesMsg:encode()
	local body = "";


	return body;
end

function ReqBuyArenaTimesMsg:ParseData(pak)
	local idx = 1;


end



--[[
购买竞技场CD
]]
_G.ReqBuyArenaCDMsg = {};

ReqBuyArenaCDMsg.msgId = 2106;



ReqBuyArenaCDMsg.meta = {__index = ReqBuyArenaCDMsg };
function ReqBuyArenaCDMsg:new()
	local obj = setmetatable( {}, ReqBuyArenaCDMsg.meta);
	return obj;
end

function ReqBuyArenaCDMsg:encode()
	local body = "";


	return body;
end

function ReqBuyArenaCDMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求帮派活动-地宫炼狱信息
]]
_G.ReqQueryGuildHellInfoMsg = {};

ReqQueryGuildHellInfoMsg.msgId = 2107;



ReqQueryGuildHellInfoMsg.meta = {__index = ReqQueryGuildHellInfoMsg };
function ReqQueryGuildHellInfoMsg:new()
	local obj = setmetatable( {}, ReqQueryGuildHellInfoMsg.meta);
	return obj;
end

function ReqQueryGuildHellInfoMsg:encode()
	local body = "";


	return body;
end

function ReqQueryGuildHellInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求挑战地宫炼狱
]]
_G.ReqEnterGuildHellMsg = {};

ReqEnterGuildHellMsg.msgId = 2108;
ReqEnterGuildHellMsg.id = 0; -- 层级id(与层数一致)



ReqEnterGuildHellMsg.meta = {__index = ReqEnterGuildHellMsg };
function ReqEnterGuildHellMsg:new()
	local obj = setmetatable( {}, ReqEnterGuildHellMsg.meta);
	return obj;
end

function ReqEnterGuildHellMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqEnterGuildHellMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
请求排行榜信息
]]
_G.ReqRanklistMsg = {};

ReqRanklistMsg.msgId = 2113;
ReqRanklistMsg.type = 0; -- 



ReqRanklistMsg.meta = {__index = ReqRanklistMsg };
function ReqRanklistMsg:new()
	local obj = setmetatable( {}, ReqRanklistMsg.meta);
	return obj;
end

function ReqRanklistMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqRanklistMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
查看其他人信息
]]
_G.ReqRankHumanInfoMsg = {};

ReqRankHumanInfoMsg.msgId = 2114;
ReqRankHumanInfoMsg.roleID = ""; -- 角色ID
ReqRankHumanInfoMsg.type = 0; -- 查看类型 1:基本信息 2:详细信息 4:坐骑 8:武魂 16:装备宝石 32:卓越孔信息



ReqRankHumanInfoMsg.meta = {__index = ReqRankHumanInfoMsg };
function ReqRankHumanInfoMsg:new()
	local obj = setmetatable( {}, ReqRankHumanInfoMsg.meta);
	return obj;
end

function ReqRankHumanInfoMsg:encode()
	local body = "";

	body = body ..writeGuid(self.roleID);
	body = body ..writeInt(self.type);

	return body;
end

function ReqRankHumanInfoMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
请求加入帮派战
]]
_G.ReqUnionWarActMsg = {};

ReqUnionWarActMsg.msgId = 2115;



ReqUnionWarActMsg.meta = {__index = ReqUnionWarActMsg };
function ReqUnionWarActMsg:new()
	local obj = setmetatable( {}, ReqUnionWarActMsg.meta);
	return obj;
end

function ReqUnionWarActMsg:encode()
	local body = "";


	return body;
end

function ReqUnionWarActMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求激活码
]]
_G.ReqActivationCodeMsg = {};

ReqActivationCodeMsg.msgId = 2116;
ReqActivationCodeMsg.code = ""; -- 激活码



ReqActivationCodeMsg.meta = {__index = ReqActivationCodeMsg };
function ReqActivationCodeMsg:new()
	local obj = setmetatable( {}, ReqActivationCodeMsg.meta);
	return obj;
end

function ReqActivationCodeMsg:encode()
	local body = "";

	body = body ..writeString(self.code,32);

	return body;
end

function ReqActivationCodeMsg:ParseData(pak)
	local idx = 1;

	self.code, idx = readString(pak, idx, 32);

end



--[[
请求准备加入帮派王城战
]]
_G.ReqUnionEnterCityWarMsg = {};

ReqUnionEnterCityWarMsg.msgId = 2117;



ReqUnionEnterCityWarMsg.meta = {__index = ReqUnionEnterCityWarMsg };
function ReqUnionEnterCityWarMsg:new()
	local obj = setmetatable( {}, ReqUnionEnterCityWarMsg.meta);
	return obj;
end

function ReqUnionEnterCityWarMsg:encode()
	local body = "";


	return body;
end

function ReqUnionEnterCityWarMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求排行榜信息
]]
_G.ReqAllServerRanklistMsg = {};

ReqAllServerRanklistMsg.msgId = 2120;
ReqAllServerRanklistMsg.type = 0; -- 



ReqAllServerRanklistMsg.meta = {__index = ReqAllServerRanklistMsg };
function ReqAllServerRanklistMsg:new()
	local obj = setmetatable( {}, ReqAllServerRanklistMsg.meta);
	return obj;
end

function ReqAllServerRanklistMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqAllServerRanklistMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
查看其他人信息
]]
_G.ReqAllServerRankHumanInfoMsg = {};

ReqAllServerRankHumanInfoMsg.msgId = 2121;
ReqAllServerRankHumanInfoMsg.roleID = ""; -- 角色ID
ReqAllServerRankHumanInfoMsg.typec = 0; -- 1==窗扣查看，2==右侧预览
ReqAllServerRankHumanInfoMsg.type = 0; -- 查看类型 1:基本信息 2:详细信息 4:坐骑 8:武魂 16:装备宝石 32:卓越孔信息



ReqAllServerRankHumanInfoMsg.meta = {__index = ReqAllServerRankHumanInfoMsg };
function ReqAllServerRankHumanInfoMsg:new()
	local obj = setmetatable( {}, ReqAllServerRankHumanInfoMsg.meta);
	return obj;
end

function ReqAllServerRankHumanInfoMsg:encode()
	local body = "";

	body = body ..writeGuid(self.roleID);
	body = body ..writeInt(self.typec);
	body = body ..writeInt(self.type);

	return body;
end

function ReqAllServerRankHumanInfoMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.typec, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
请求至尊王帮人物信息
]]
_G.ReqSuperGloryRoleinfoMsg = {};

ReqSuperGloryRoleinfoMsg.msgId = 2122;



ReqSuperGloryRoleinfoMsg.meta = {__index = ReqSuperGloryRoleinfoMsg };
function ReqSuperGloryRoleinfoMsg:new()
	local obj = setmetatable( {}, ReqSuperGloryRoleinfoMsg.meta);
	return obj;
end

function ReqSuperGloryRoleinfoMsg:encode()
	local body = "";


	return body;
end

function ReqSuperGloryRoleinfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
膜拜城主
]]
_G.ReqSuperGloryWroshipMsg = {};

ReqSuperGloryWroshipMsg.msgId = 2124;



ReqSuperGloryWroshipMsg.meta = {__index = ReqSuperGloryWroshipMsg };
function ReqSuperGloryWroshipMsg:new()
	local obj = setmetatable( {}, ReqSuperGloryWroshipMsg.meta);
	return obj;
end

function ReqSuperGloryWroshipMsg:encode()
	local body = "";


	return body;
end

function ReqSuperGloryWroshipMsg:ParseData(pak)
	local idx = 1;


end



--[[
城主分配礼包
]]
_G.ReqSuperGlorySendBagMsg = {};

ReqSuperGlorySendBagMsg.msgId = 2125;



ReqSuperGlorySendBagMsg.meta = {__index = ReqSuperGlorySendBagMsg };
function ReqSuperGlorySendBagMsg:new()
	local obj = setmetatable( {}, ReqSuperGlorySendBagMsg.meta);
	return obj;
end

function ReqSuperGlorySendBagMsg:encode()
	local body = "";


	return body;
end

function ReqSuperGlorySendBagMsg:ParseData(pak)
	local idx = 1;


end



--[[
提交分配结果
]]
_G.ReqSuperGlorySendBagUpMsg = {};

ReqSuperGlorySendBagUpMsg.msgId = 2126;
ReqSuperGlorySendBagUpMsg.roleList_size = 0; -- list size
ReqSuperGlorySendBagUpMsg.roleList = {}; -- list list

--[[
roleVOVO = {
	roleID = ""; -- 角色ID
	num = 0; -- 数量
}
]]

ReqSuperGlorySendBagUpMsg.meta = {__index = ReqSuperGlorySendBagUpMsg };
function ReqSuperGlorySendBagUpMsg:new()
	local obj = setmetatable( {}, ReqSuperGlorySendBagUpMsg.meta);
	return obj;
end

function ReqSuperGlorySendBagUpMsg:encode()
	local body = "";


	local list1 = self.roleList;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeGuid(list1[i1].roleID);
		body = body .. writeInt(list1[i1].num);
	end

	return body;
end

function ReqSuperGlorySendBagUpMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.roleList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local roleVOVo = {};
		roleVOVo.roleID, idx = readGuid(pak, idx);
		roleVOVo.num, idx = readInt(pak, idx);
		table.push(list1,roleVOVo);
	end

end



--[[
城主请求设置副手
]]
_G.ReqSuperGloryReqSetDeputyMsg = {};

ReqSuperGloryReqSetDeputyMsg.msgId = 2127;



ReqSuperGloryReqSetDeputyMsg.meta = {__index = ReqSuperGloryReqSetDeputyMsg };
function ReqSuperGloryReqSetDeputyMsg:new()
	local obj = setmetatable( {}, ReqSuperGloryReqSetDeputyMsg.meta);
	return obj;
end

function ReqSuperGloryReqSetDeputyMsg:encode()
	local body = "";


	return body;
end

function ReqSuperGloryReqSetDeputyMsg:ParseData(pak)
	local idx = 1;


end



--[[
城主确认设置副手
]]
_G.ReqSuperGlorySetDeputyMsg = {};

ReqSuperGlorySetDeputyMsg.msgId = 2128;
ReqSuperGlorySetDeputyMsg.roleID = ""; -- 角色ID



ReqSuperGlorySetDeputyMsg.meta = {__index = ReqSuperGlorySetDeputyMsg };
function ReqSuperGlorySetDeputyMsg:new()
	local obj = setmetatable( {}, ReqSuperGlorySetDeputyMsg.meta);
	return obj;
end

function ReqSuperGlorySetDeputyMsg:encode()
	local body = "";

	body = body ..writeGuid(self.roleID);

	return body;
end

function ReqSuperGlorySetDeputyMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);

end



--[[
请求仓库操作信息
]]
_G.ReqUnionWareInfomationMsg = {};

ReqUnionWareInfomationMsg.msgId = 2129;



ReqUnionWareInfomationMsg.meta = {__index = ReqUnionWareInfomationMsg };
function ReqUnionWareInfomationMsg:new()
	local obj = setmetatable( {}, ReqUnionWareInfomationMsg.meta);
	return obj;
end

function ReqUnionWareInfomationMsg:encode()
	local body = "";


	return body;
end

function ReqUnionWareInfomationMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求帮派仓库物品列表
]]
_G.ReqUnionWareHouseinfoMsg = {};

ReqUnionWareHouseinfoMsg.msgId = 2130;



ReqUnionWareHouseinfoMsg.meta = {__index = ReqUnionWareHouseinfoMsg };
function ReqUnionWareHouseinfoMsg:new()
	local obj = setmetatable( {}, ReqUnionWareHouseinfoMsg.meta);
	return obj;
end

function ReqUnionWareHouseinfoMsg:encode()
	local body = "";


	return body;
end

function ReqUnionWareHouseinfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
请仓库熔炼操作
]]
_G.ReqUnionWareHouseSmelitingMsg = {};

ReqUnionWareHouseSmelitingMsg.msgId = 2132;
ReqUnionWareHouseSmelitingMsg.infolist_size = 0; -- list size
ReqUnionWareHouseSmelitingMsg.infolist = {}; -- list list

--[[
infoVoVO = {
	uid = ""; -- 物品uid
}
]]

ReqUnionWareHouseSmelitingMsg.meta = {__index = ReqUnionWareHouseSmelitingMsg };
function ReqUnionWareHouseSmelitingMsg:new()
	local obj = setmetatable( {}, ReqUnionWareHouseSmelitingMsg.meta);
	return obj;
end

function ReqUnionWareHouseSmelitingMsg:encode()
	local body = "";


	local list1 = self.infolist;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeGuid(list1[i1].uid);
	end

	return body;
end

function ReqUnionWareHouseSmelitingMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.infolist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local infoVoVo = {};
		infoVoVo.uid, idx = readGuid(pak, idx);
		table.push(list1,infoVoVo);
	end

end



--[[
请求帮派仓库取操作
]]
_G.ReqUnionWareHouseTakeMsg = {};

ReqUnionWareHouseTakeMsg.msgId = 2133;
ReqUnionWareHouseTakeMsg.uid = ""; -- 物品uid
ReqUnionWareHouseTakeMsg.num = 0; -- 物品数量，存在取出道具



ReqUnionWareHouseTakeMsg.meta = {__index = ReqUnionWareHouseTakeMsg };
function ReqUnionWareHouseTakeMsg:new()
	local obj = setmetatable( {}, ReqUnionWareHouseTakeMsg.meta);
	return obj;
end

function ReqUnionWareHouseTakeMsg:encode()
	local body = "";

	body = body ..writeGuid(self.uid);
	body = body ..writeInt(self.num);

	return body;
end

function ReqUnionWareHouseTakeMsg:ParseData(pak)
	local idx = 1;

	self.uid, idx = readGuid(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
请求帮派仓库存操作
]]
_G.ReqUnionWareHouseSaveMsg = {};

ReqUnionWareHouseSaveMsg.msgId = 2134;
ReqUnionWareHouseSaveMsg.uid = ""; -- 物品uid
ReqUnionWareHouseSaveMsg.num = 0; -- 物品数量，存在放入道具



ReqUnionWareHouseSaveMsg.meta = {__index = ReqUnionWareHouseSaveMsg };
function ReqUnionWareHouseSaveMsg:new()
	local obj = setmetatable( {}, ReqUnionWareHouseSaveMsg.meta);
	return obj;
end

function ReqUnionWareHouseSaveMsg:encode()
	local body = "";

	body = body ..writeGuid(self.uid);
	body = body ..writeInt(self.num);

	return body;
end

function ReqUnionWareHouseSaveMsg:ParseData(pak)
	local idx = 1;

	self.uid, idx = readGuid(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
请求微端登录url
]]
_G.ReqMClentLoginUrlMsg = {};

ReqMClentLoginUrlMsg.msgId = 2135;



ReqMClentLoginUrlMsg.meta = {__index = ReqMClentLoginUrlMsg };
function ReqMClentLoginUrlMsg:new()
	local obj = setmetatable( {}, ReqMClentLoginUrlMsg.meta);
	return obj;
end

function ReqMClentLoginUrlMsg:encode()
	local body = "";


	return body;
end

function ReqMClentLoginUrlMsg:ParseData(pak)
	local idx = 1;


end



--[[
心跳
]]
_G.ReqHeartBeatMsg = {};

ReqHeartBeatMsg.msgId = 2136;
ReqHeartBeatMsg.time = 0; -- time



ReqHeartBeatMsg.meta = {__index = ReqHeartBeatMsg };
function ReqHeartBeatMsg:new()
	local obj = setmetatable( {}, ReqHeartBeatMsg.meta);
	return obj;
end

function ReqHeartBeatMsg:encode()
	local body = "";

	body = body ..writeInt64(self.time);

	return body;
end

function ReqHeartBeatMsg:ParseData(pak)
	local idx = 1;

	self.time, idx = readInt64(pak, idx);

end



--[[
请求战场报名
]]
_G.ReqZhancSignUpMsg = {};

ReqZhancSignUpMsg.msgId = 2137;
ReqZhancSignUpMsg.type = 0; -- 0--未报名， 1--报名



ReqZhancSignUpMsg.meta = {__index = ReqZhancSignUpMsg };
function ReqZhancSignUpMsg:new()
	local obj = setmetatable( {}, ReqZhancSignUpMsg.meta);
	return obj;
end

function ReqZhancSignUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqZhancSignUpMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
请求平台V信息
]]
_G.ReqVPlanMsg = {};

ReqVPlanMsg.msgId = 2138;



ReqVPlanMsg.meta = {__index = ReqVPlanMsg };
function ReqVPlanMsg:new()
	local obj = setmetatable( {}, ReqVPlanMsg.meta);
	return obj;
end

function ReqVPlanMsg:encode()
	local body = "";


	return body;
end

function ReqVPlanMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求获得帮派祈福信息
]]
_G.ReqGetUnionPrayMsg = {};

ReqGetUnionPrayMsg.msgId = 2139;



ReqGetUnionPrayMsg.meta = {__index = ReqGetUnionPrayMsg };
function ReqGetUnionPrayMsg:new()
	local obj = setmetatable( {}, ReqGetUnionPrayMsg.meta);
	return obj;
end

function ReqGetUnionPrayMsg:encode()
	local body = "";


	return body;
end

function ReqGetUnionPrayMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求帮派祈福
]]
_G.ReqUnionPrayMsg = {};

ReqUnionPrayMsg.msgId = 2141;
ReqUnionPrayMsg.prayid = 0; -- 祈福类型id



ReqUnionPrayMsg.meta = {__index = ReqUnionPrayMsg };
function ReqUnionPrayMsg:new()
	local obj = setmetatable( {}, ReqUnionPrayMsg.meta);
	return obj;
end

function ReqUnionPrayMsg:encode()
	local body = "";

	body = body ..writeInt(self.prayid);

	return body;
end

function ReqUnionPrayMsg:ParseData(pak)
	local idx = 1;

	self.prayid, idx = readInt(pak, idx);

end



--[[
请求寄售行，物品信息
]]
_G.ReqConsignmentItemInfoMsg = {};

ReqConsignmentItemInfoMsg.msgId = 2142;
ReqConsignmentItemInfoMsg.page = 0; -- 当前请求页数
ReqConsignmentItemInfoMsg.equipPos = 0; -- 当前物品类型，1=武器，2=防具，3饰品，4道具，5消耗品，6其他   条件1
ReqConsignmentItemInfoMsg.equipRole = 0; -- 当前装备种类，人物职业区分 条件2 
ReqConsignmentItemInfoMsg.equipType = 0; -- 当前装备品阶0-10阶 条件3
ReqConsignmentItemInfoMsg.miniLvl = 0; -- 筛选装备最小等级
ReqConsignmentItemInfoMsg.maxLvl = 0; -- 筛选装备最大等级
ReqConsignmentItemInfoMsg.quality = 0; -- 筛选装备品质
ReqConsignmentItemInfoMsg.superAtb = 0; -- 筛选卓越属性 0=全部，1,2,3几条属性
ReqConsignmentItemInfoMsg.canWith = 0; -- 是否要可用物品 0 ==true



ReqConsignmentItemInfoMsg.meta = {__index = ReqConsignmentItemInfoMsg };
function ReqConsignmentItemInfoMsg:new()
	local obj = setmetatable( {}, ReqConsignmentItemInfoMsg.meta);
	return obj;
end

function ReqConsignmentItemInfoMsg:encode()
	local body = "";

	body = body ..writeInt(self.page);
	body = body ..writeInt(self.equipPos);
	body = body ..writeInt(self.equipRole);
	body = body ..writeInt(self.equipType);
	body = body ..writeInt(self.miniLvl);
	body = body ..writeInt(self.maxLvl);
	body = body ..writeInt(self.quality);
	body = body ..writeInt(self.superAtb);
	body = body ..writeInt(self.canWith);

	return body;
end

function ReqConsignmentItemInfoMsg:ParseData(pak)
	local idx = 1;

	self.page, idx = readInt(pak, idx);
	self.equipPos, idx = readInt(pak, idx);
	self.equipRole, idx = readInt(pak, idx);
	self.equipType, idx = readInt(pak, idx);
	self.miniLvl, idx = readInt(pak, idx);
	self.maxLvl, idx = readInt(pak, idx);
	self.quality, idx = readInt(pak, idx);
	self.superAtb, idx = readInt(pak, idx);
	self.canWith, idx = readInt(pak, idx);

end



--[[
购买
]]
_G.ReqConsignmentItemBuyMsg = {};

ReqConsignmentItemBuyMsg.msgId = 2143;
ReqConsignmentItemBuyMsg.uid = ""; -- 寄售行记录id
ReqConsignmentItemBuyMsg.num = 0; -- 数量



ReqConsignmentItemBuyMsg.meta = {__index = ReqConsignmentItemBuyMsg };
function ReqConsignmentItemBuyMsg:new()
	local obj = setmetatable( {}, ReqConsignmentItemBuyMsg.meta);
	return obj;
end

function ReqConsignmentItemBuyMsg:encode()
	local body = "";

	body = body ..writeGuid(self.uid);
	body = body ..writeInt(self.num);

	return body;
end

function ReqConsignmentItemBuyMsg:ParseData(pak)
	local idx = 1;

	self.uid, idx = readGuid(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
物品下架
]]
_G.ReqConsignmentItemOutShelvesMsg = {};

ReqConsignmentItemOutShelvesMsg.msgId = 2144;
ReqConsignmentItemOutShelvesMsg.uid = ""; -- 寄售行记录id
ReqConsignmentItemOutShelvesMsg.isall = 0; -- 是否全部下架 0=true



ReqConsignmentItemOutShelvesMsg.meta = {__index = ReqConsignmentItemOutShelvesMsg };
function ReqConsignmentItemOutShelvesMsg:new()
	local obj = setmetatable( {}, ReqConsignmentItemOutShelvesMsg.meta);
	return obj;
end

function ReqConsignmentItemOutShelvesMsg:encode()
	local body = "";

	body = body ..writeGuid(self.uid);
	body = body ..writeInt(self.isall);

	return body;
end

function ReqConsignmentItemOutShelvesMsg:ParseData(pak)
	local idx = 1;

	self.uid, idx = readGuid(pak, idx);
	self.isall, idx = readInt(pak, idx);

end



--[[
请求领取好友礼包
]]
_G.ReqFriendRewardGetMsg = {};

ReqFriendRewardGetMsg.msgId = 2146;



ReqFriendRewardGetMsg.meta = {__index = ReqFriendRewardGetMsg };
function ReqFriendRewardGetMsg:new()
	local obj = setmetatable( {}, ReqFriendRewardGetMsg.meta);
	return obj;
end

function ReqFriendRewardGetMsg:encode()
	local body = "";


	return body;
end

function ReqFriendRewardGetMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求: 我的寄售行物品信息
]]
_G.ReqMyConsignmentItemInfoMsg = {};

ReqMyConsignmentItemInfoMsg.msgId = 2147;



ReqMyConsignmentItemInfoMsg.meta = {__index = ReqMyConsignmentItemInfoMsg };
function ReqMyConsignmentItemInfoMsg:new()
	local obj = setmetatable( {}, ReqMyConsignmentItemInfoMsg.meta);
	return obj;
end

function ReqMyConsignmentItemInfoMsg:encode()
	local body = "";


	return body;
end

function ReqMyConsignmentItemInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求: 寄售行盈利info
]]
_G.ReqMyConsignmentEarnInfoMsg = {};

ReqMyConsignmentEarnInfoMsg.msgId = 2148;



ReqMyConsignmentEarnInfoMsg.meta = {__index = ReqMyConsignmentEarnInfoMsg };
function ReqMyConsignmentEarnInfoMsg:new()
	local obj = setmetatable( {}, ReqMyConsignmentEarnInfoMsg.meta);
	return obj;
end

function ReqMyConsignmentEarnInfoMsg:encode()
	local body = "";


	return body;
end

function ReqMyConsignmentEarnInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求: 帮派申请人数
]]
_G.ReqGuildReplyCountTipMsg = {};

ReqGuildReplyCountTipMsg.msgId = 2149;



ReqGuildReplyCountTipMsg.meta = {__index = ReqGuildReplyCountTipMsg };
function ReqGuildReplyCountTipMsg:new()
	local obj = setmetatable( {}, ReqGuildReplyCountTipMsg.meta);
	return obj;
end

function ReqGuildReplyCountTipMsg:encode()
	local body = "";


	return body;
end

function ReqGuildReplyCountTipMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求排行榜数据
]]
_G.ReqGetExtremityRankDataMsg = {};

ReqGetExtremityRankDataMsg.msgId = 2150;



ReqGetExtremityRankDataMsg.meta = {__index = ReqGetExtremityRankDataMsg };
function ReqGetExtremityRankDataMsg:new()
	local obj = setmetatable( {}, ReqGetExtremityRankDataMsg.meta);
	return obj;
end

function ReqGetExtremityRankDataMsg:encode()
	local body = "";


	return body;
end

function ReqGetExtremityRankDataMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：请求新版极限挑战UIdata
]]
_G.ReqGetNewExtremityDataMsg = {};

ReqGetNewExtremityDataMsg.msgId = 2151;



ReqGetNewExtremityDataMsg.meta = {__index = ReqGetNewExtremityDataMsg };
function ReqGetNewExtremityDataMsg:new()
	local obj = setmetatable( {}, ReqGetNewExtremityDataMsg.meta);
	return obj;
end

function ReqGetNewExtremityDataMsg:encode()
	local body = "";


	return body;
end

function ReqGetNewExtremityDataMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：请求排名
]]
_G.ReqExtremityRankDataMsg = {};

ReqExtremityRankDataMsg.msgId = 2152;
ReqExtremityRankDataMsg.state = 0; -- 请求排行榜模式 1 BOSS 2 小怪 
ReqExtremityRankDataMsg.val = 0; -- 当前伤害值或杀怪数



ReqExtremityRankDataMsg.meta = {__index = ReqExtremityRankDataMsg };
function ReqExtremityRankDataMsg:new()
	local obj = setmetatable( {}, ReqExtremityRankDataMsg.meta);
	return obj;
end

function ReqExtremityRankDataMsg:encode()
	local body = "";

	body = body ..writeInt(self.state);
	body = body ..writeInt64(self.val);

	return body;
end

function ReqExtremityRankDataMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);
	self.val, idx = readInt64(pak, idx);

end



--[[
客户端请求：灵光封魔房间信息
]]
_G.ReqTimeDungeonRoomMsg = {};

ReqTimeDungeonRoomMsg.msgId = 2153;



ReqTimeDungeonRoomMsg.meta = {__index = ReqTimeDungeonRoomMsg };
function ReqTimeDungeonRoomMsg:new()
	local obj = setmetatable( {}, ReqTimeDungeonRoomMsg.meta);
	return obj;
end

function ReqTimeDungeonRoomMsg:encode()
	local body = "";


	return body;
end

function ReqTimeDungeonRoomMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：灵光封魔快速房间
]]
_G.ReqQuickTimeDungeonRoomMsg = {};

ReqQuickTimeDungeonRoomMsg.msgId = 2155;



ReqQuickTimeDungeonRoomMsg.meta = {__index = ReqQuickTimeDungeonRoomMsg };
function ReqQuickTimeDungeonRoomMsg:new()
	local obj = setmetatable( {}, ReqQuickTimeDungeonRoomMsg.meta);
	return obj;
end

function ReqQuickTimeDungeonRoomMsg:encode()
	local body = "";


	return body;
end

function ReqQuickTimeDungeonRoomMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：灵光封魔请求创建
]]
_G.ReqTimeDungeonRoomBuildMsg = {};

ReqTimeDungeonRoomBuildMsg.msgId = 2156;
ReqTimeDungeonRoomBuildMsg.dungeonIndex = 0; -- 副本难度 1 2 3 4 5 
ReqTimeDungeonRoomBuildMsg.password = ""; -- 密码
ReqTimeDungeonRoomBuildMsg.attLimit = 0; -- 战力需求



ReqTimeDungeonRoomBuildMsg.meta = {__index = ReqTimeDungeonRoomBuildMsg };
function ReqTimeDungeonRoomBuildMsg:new()
	local obj = setmetatable( {}, ReqTimeDungeonRoomBuildMsg.meta);
	return obj;
end

function ReqTimeDungeonRoomBuildMsg:encode()
	local body = "";

	body = body ..writeInt(self.dungeonIndex);
	body = body ..writeString(self.password,32);
	body = body ..writeInt(self.attLimit);

	return body;
end

function ReqTimeDungeonRoomBuildMsg:ParseData(pak)
	local idx = 1;

	self.dungeonIndex, idx = readInt(pak, idx);
	self.password, idx = readString(pak, idx, 32);
	self.attLimit, idx = readInt(pak, idx);

end



--[[
客户端请求：切换准备状态
]]
_G.ReqTimeDungeonPrepareMsg = {};

ReqTimeDungeonPrepareMsg.msgId = 2157;
ReqTimeDungeonPrepareMsg.prepare = 0; -- 准备状态 0 true 1 false



ReqTimeDungeonPrepareMsg.meta = {__index = ReqTimeDungeonPrepareMsg };
function ReqTimeDungeonPrepareMsg:new()
	local obj = setmetatable( {}, ReqTimeDungeonPrepareMsg.meta);
	return obj;
end

function ReqTimeDungeonPrepareMsg:encode()
	local body = "";

	body = body ..writeInt(self.prepare);

	return body;
end

function ReqTimeDungeonPrepareMsg:ParseData(pak)
	local idx = 1;

	self.prepare, idx = readInt(pak, idx);

end



--[[
客户端请求：退出房间
]]
_G.ReqQuitTimeDungeonRoomMsg = {};

ReqQuitTimeDungeonRoomMsg.msgId = 2158;



ReqQuitTimeDungeonRoomMsg.meta = {__index = ReqQuitTimeDungeonRoomMsg };
function ReqQuitTimeDungeonRoomMsg:new()
	local obj = setmetatable( {}, ReqQuitTimeDungeonRoomMsg.meta);
	return obj;
end

function ReqQuitTimeDungeonRoomMsg:encode()
	local body = "";


	return body;
end

function ReqQuitTimeDungeonRoomMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：请求领取排行榜奖励
]]
_G.ReqExtremityRewardMsg = {};

ReqExtremityRewardMsg.msgId = 2159;
ReqExtremityRewardMsg.type = 0; -- 领取类型 0 BOSS 1 小怪 



ReqExtremityRewardMsg.meta = {__index = ReqExtremityRewardMsg };
function ReqExtremityRewardMsg:new()
	local obj = setmetatable( {}, ReqExtremityRewardMsg.meta);
	return obj;
end

function ReqExtremityRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqExtremityRewardMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
客户端请求：进入他人队伍
]]
_G.ReqCenterTimeDungeonTeamMsg = {};

ReqCenterTimeDungeonTeamMsg.msgId = 2160;
ReqCenterTimeDungeonTeamMsg.password = ""; -- 密码
ReqCenterTimeDungeonTeamMsg.teamID = ""; -- 队伍ID



ReqCenterTimeDungeonTeamMsg.meta = {__index = ReqCenterTimeDungeonTeamMsg };
function ReqCenterTimeDungeonTeamMsg:new()
	local obj = setmetatable( {}, ReqCenterTimeDungeonTeamMsg.meta);
	return obj;
end

function ReqCenterTimeDungeonTeamMsg:encode()
	local body = "";

	body = body ..writeString(self.password,32);
	body = body ..writeGuid(self.teamID);

	return body;
end

function ReqCenterTimeDungeonTeamMsg:ParseData(pak)
	local idx = 1;

	self.password, idx = readString(pak, idx, 32);
	self.teamID, idx = readGuid(pak, idx);

end



--[[
客户端请求：更换房间难度
]]
_G.ReqChangeRoomDiffMsg = {};

ReqChangeRoomDiffMsg.msgId = 2161;
ReqChangeRoomDiffMsg.dungeonIndex = 0; -- 副本难度 1 2 3 4 5 



ReqChangeRoomDiffMsg.meta = {__index = ReqChangeRoomDiffMsg };
function ReqChangeRoomDiffMsg:new()
	local obj = setmetatable( {}, ReqChangeRoomDiffMsg.meta);
	return obj;
end

function ReqChangeRoomDiffMsg:encode()
	local body = "";

	body = body ..writeInt(self.dungeonIndex);

	return body;
end

function ReqChangeRoomDiffMsg:ParseData(pak)
	local idx = 1;

	self.dungeonIndex, idx = readInt(pak, idx);

end



--[[
客户端请求：自动开始
]]
_G.ReqChangeRoomAutoStartMsg = {};

ReqChangeRoomAutoStartMsg.msgId = 2162;
ReqChangeRoomAutoStartMsg.autoStart = 0; -- 自动开始 0 true



ReqChangeRoomAutoStartMsg.meta = {__index = ReqChangeRoomAutoStartMsg };
function ReqChangeRoomAutoStartMsg:new()
	local obj = setmetatable( {}, ReqChangeRoomAutoStartMsg.meta);
	return obj;
end

function ReqChangeRoomAutoStartMsg:encode()
	local body = "";

	body = body ..writeInt(self.autoStart);

	return body;
end

function ReqChangeRoomAutoStartMsg:ParseData(pak)
	local idx = 1;

	self.autoStart, idx = readInt(pak, idx);

end



--[[
客户端请求：房间队伍开始战斗
]]
_G.ReqRoomStartMsg = {};

ReqRoomStartMsg.msgId = 2163;



ReqRoomStartMsg.meta = {__index = ReqRoomStartMsg };
function ReqRoomStartMsg:new()
	local obj = setmetatable( {}, ReqRoomStartMsg.meta);
	return obj;
end

function ReqRoomStartMsg:encode()
	local body = "";


	return body;
end

function ReqRoomStartMsg:ParseData(pak)
	local idx = 1;


end



--[[
选项返回
]]
_G.ReqTimeDungeonPreparedMsg = {};

ReqTimeDungeonPreparedMsg.msgId = 2166;
ReqTimeDungeonPreparedMsg.state = 0; -- 客户端回应状态 0 换线并准备 1拒绝



ReqTimeDungeonPreparedMsg.meta = {__index = ReqTimeDungeonPreparedMsg };
function ReqTimeDungeonPreparedMsg:new()
	local obj = setmetatable( {}, ReqTimeDungeonPreparedMsg.meta);
	return obj;
end

function ReqTimeDungeonPreparedMsg:encode()
	local body = "";

	body = body ..writeInt(self.state);

	return body;
end

function ReqTimeDungeonPreparedMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);

end



--[[
请求开启帮派boss活动
]]
_G.ReqUnionBossActivityOpenMsg = {};

ReqUnionBossActivityOpenMsg.msgId = 2167;
ReqUnionBossActivityOpenMsg.Id = 0; -- 对应id



ReqUnionBossActivityOpenMsg.meta = {__index = ReqUnionBossActivityOpenMsg };
function ReqUnionBossActivityOpenMsg:new()
	local obj = setmetatable( {}, ReqUnionBossActivityOpenMsg.meta);
	return obj;
end

function ReqUnionBossActivityOpenMsg:encode()
	local body = "";

	body = body ..writeInt(self.Id);

	return body;
end

function ReqUnionBossActivityOpenMsg:ParseData(pak)
	local idx = 1;

	self.Id, idx = readInt(pak, idx);

end



--[[
请求进入帮派boss活动
]]
_G.ReqUnionBossActivityEnterMsg = {};

ReqUnionBossActivityEnterMsg.msgId = 2169;



ReqUnionBossActivityEnterMsg.meta = {__index = ReqUnionBossActivityEnterMsg };
function ReqUnionBossActivityEnterMsg:new()
	local obj = setmetatable( {}, ReqUnionBossActivityEnterMsg.meta);
	return obj;
end

function ReqUnionBossActivityEnterMsg:encode()
	local body = "";


	return body;
end

function ReqUnionBossActivityEnterMsg:ParseData(pak)
	local idx = 1;


end



--[[
家园建筑信息
]]
_G.ReqHomesBuildInfoMsg = {};

ReqHomesBuildInfoMsg.msgId = 2170;



ReqHomesBuildInfoMsg.meta = {__index = ReqHomesBuildInfoMsg };
function ReqHomesBuildInfoMsg:new()
	local obj = setmetatable( {}, ReqHomesBuildInfoMsg.meta);
	return obj;
end

function ReqHomesBuildInfoMsg:encode()
	local body = "";


	return body;
end

function ReqHomesBuildInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
家园建筑升级
]]
_G.ReqHomesBuildUplvlMsg = {};

ReqHomesBuildUplvlMsg.msgId = 2171;
ReqHomesBuildUplvlMsg.buildType = 0; -- 建筑类型,1=主建筑，2=寻仙台，3=宗门任务



ReqHomesBuildUplvlMsg.meta = {__index = ReqHomesBuildUplvlMsg };
function ReqHomesBuildUplvlMsg:new()
	local obj = setmetatable( {}, ReqHomesBuildUplvlMsg.meta);
	return obj;
end

function ReqHomesBuildUplvlMsg:encode()
	local body = "";

	body = body ..writeInt(self.buildType);

	return body;
end

function ReqHomesBuildUplvlMsg:ParseData(pak)
	local idx = 1;

	self.buildType, idx = readInt(pak, idx);

end



--[[
我的宗门弟子信息
]]
_G.ReqHomesZongminfoMsg = {};

ReqHomesZongminfoMsg.msgId = 2172;



ReqHomesZongminfoMsg.meta = {__index = ReqHomesZongminfoMsg };
function ReqHomesZongminfoMsg:new()
	local obj = setmetatable( {}, ReqHomesZongminfoMsg.meta);
	return obj;
end

function ReqHomesZongminfoMsg:encode()
	local body = "";


	return body;
end

function ReqHomesZongminfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
寻仙台弟子刷新
]]
_G.ReqHomesXunxianMsg = {};

ReqHomesXunxianMsg.msgId = 2173;
ReqHomesXunxianMsg.type = 0; -- 0=请求寻仙台弟子信息，刷新类型，1为消耗刷新。



ReqHomesXunxianMsg.meta = {__index = ReqHomesXunxianMsg };
function ReqHomesXunxianMsg:new()
	local obj = setmetatable( {}, ReqHomesXunxianMsg.meta);
	return obj;
end

function ReqHomesXunxianMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqHomesXunxianMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
弟子招募
]]
_G.ReqHomesPupilEnlistMsg = {};

ReqHomesPupilEnlistMsg.msgId = 2174;
ReqHomesPupilEnlistMsg.guid = ""; -- 弟子id



ReqHomesPupilEnlistMsg.meta = {__index = ReqHomesPupilEnlistMsg };
function ReqHomesPupilEnlistMsg:new()
	local obj = setmetatable( {}, ReqHomesPupilEnlistMsg.meta);
	return obj;
end

function ReqHomesPupilEnlistMsg:encode()
	local body = "";

	body = body ..writeGuid(self.guid);

	return body;
end

function ReqHomesPupilEnlistMsg:ParseData(pak)
	local idx = 1;

	self.guid, idx = readGuid(pak, idx);

end



--[[
弟子销毁
]]
_G.ReqHomesPupildestoryMsg = {};

ReqHomesPupildestoryMsg.msgId = 2175;
ReqHomesPupildestoryMsg.guid = ""; -- 弟子id



ReqHomesPupildestoryMsg.meta = {__index = ReqHomesPupildestoryMsg };
function ReqHomesPupildestoryMsg:new()
	local obj = setmetatable( {}, ReqHomesPupildestoryMsg.meta);
	return obj;
end

function ReqHomesPupildestoryMsg:encode()
	local body = "";

	body = body ..writeGuid(self.guid);

	return body;
end

function ReqHomesPupildestoryMsg:ParseData(pak)
	local idx = 1;

	self.guid, idx = readGuid(pak, idx);

end



--[[
我的任务信息
]]
_G.ReqHomesMyQuestInfoMsg = {};

ReqHomesMyQuestInfoMsg.msgId = 2176;



ReqHomesMyQuestInfoMsg.meta = {__index = ReqHomesMyQuestInfoMsg };
function ReqHomesMyQuestInfoMsg:new()
	local obj = setmetatable( {}, ReqHomesMyQuestInfoMsg.meta);
	return obj;
end

function ReqHomesMyQuestInfoMsg:encode()
	local body = "";


	return body;
end

function ReqHomesMyQuestInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
任务殿信息
]]
_G.ReqHomesQuestInfoMsg = {};

ReqHomesQuestInfoMsg.msgId = 2177;
ReqHomesQuestInfoMsg.type = 0; -- 0=请求台弟子信息，刷新类型，1为消耗刷新。



ReqHomesQuestInfoMsg.meta = {__index = ReqHomesQuestInfoMsg };
function ReqHomesQuestInfoMsg:new()
	local obj = setmetatable( {}, ReqHomesQuestInfoMsg.meta);
	return obj;
end

function ReqHomesQuestInfoMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqHomesQuestInfoMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
接取任务
]]
_G.ReqHomesGetQuestMsg = {};

ReqHomesGetQuestMsg.msgId = 2178;
ReqHomesGetQuestMsg.guid = ""; -- uid
ReqHomesGetQuestMsg.pupil1 = ""; -- 弟子id1，0为无
ReqHomesGetQuestMsg.pupil2 = ""; -- 弟子id2
ReqHomesGetQuestMsg.pupil3 = ""; -- 弟子id3



ReqHomesGetQuestMsg.meta = {__index = ReqHomesGetQuestMsg };
function ReqHomesGetQuestMsg:new()
	local obj = setmetatable( {}, ReqHomesGetQuestMsg.meta);
	return obj;
end

function ReqHomesGetQuestMsg:encode()
	local body = "";

	body = body ..writeGuid(self.guid);
	body = body ..writeGuid(self.pupil1);
	body = body ..writeGuid(self.pupil2);
	body = body ..writeGuid(self.pupil3);

	return body;
end

function ReqHomesGetQuestMsg:ParseData(pak)
	local idx = 1;

	self.guid, idx = readGuid(pak, idx);
	self.pupil1, idx = readGuid(pak, idx);
	self.pupil2, idx = readGuid(pak, idx);
	self.pupil3, idx = readGuid(pak, idx);

end



--[[
请求任务掠夺信息
]]
_G.ReqHomesRodQuestMsg = {};

ReqHomesRodQuestMsg.msgId = 2179;



ReqHomesRodQuestMsg.meta = {__index = ReqHomesRodQuestMsg };
function ReqHomesRodQuestMsg:new()
	local obj = setmetatable( {}, ReqHomesRodQuestMsg.meta);
	return obj;
end

function ReqHomesRodQuestMsg:encode()
	local body = "";


	return body;
end

function ReqHomesRodQuestMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求抢
]]
_G.ReqHomesGoRodQuestMsg = {};

ReqHomesGoRodQuestMsg.msgId = 2181;
ReqHomesGoRodQuestMsg.guid = ""; -- uid



ReqHomesGoRodQuestMsg.meta = {__index = ReqHomesGoRodQuestMsg };
function ReqHomesGoRodQuestMsg:new()
	local obj = setmetatable( {}, ReqHomesGoRodQuestMsg.meta);
	return obj;
end

function ReqHomesGoRodQuestMsg:encode()
	local body = "";

	body = body ..writeGuid(self.guid);

	return body;
end

function ReqHomesGoRodQuestMsg:ParseData(pak)
	local idx = 1;

	self.guid, idx = readGuid(pak, idx);

end



--[[
增加抢次数or claerCD
]]
_G.ReqHomesRodQuestNumMsg = {};

ReqHomesRodQuestNumMsg.msgId = 2182;
ReqHomesRodQuestNumMsg.type = 0; -- 1=CD，2=addNum



ReqHomesRodQuestNumMsg.meta = {__index = ReqHomesRodQuestNumMsg };
function ReqHomesRodQuestNumMsg:new()
	local obj = setmetatable( {}, ReqHomesRodQuestNumMsg.meta);
	return obj;
end

function ReqHomesRodQuestNumMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqHomesRodQuestNumMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
领取我任务奖励
]]
_G.ReqHomesGetMyQuestRewardMsg = {};

ReqHomesGetMyQuestRewardMsg.msgId = 2184;
ReqHomesGetMyQuestRewardMsg.guid = ""; -- uid



ReqHomesGetMyQuestRewardMsg.meta = {__index = ReqHomesGetMyQuestRewardMsg };
function ReqHomesGetMyQuestRewardMsg:new()
	local obj = setmetatable( {}, ReqHomesGetMyQuestRewardMsg.meta);
	return obj;
end

function ReqHomesGetMyQuestRewardMsg:encode()
	local body = "";

	body = body ..writeGuid(self.guid);

	return body;
end

function ReqHomesGetMyQuestRewardMsg:ParseData(pak)
	local idx = 1;

	self.guid, idx = readGuid(pak, idx);

end



--[[
返回领取我任务奖励
]]
_G.RespHomesGetMyQuestRewardMsg = {};

RespHomesGetMyQuestRewardMsg.msgId = 7184;
RespHomesGetMyQuestRewardMsg.guid = ""; -- uid
RespHomesGetMyQuestRewardMsg.result = 0; -- 结果 0=成功，1=任务失败  -1=任务不存在



RespHomesGetMyQuestRewardMsg.meta = {__index = RespHomesGetMyQuestRewardMsg };
function RespHomesGetMyQuestRewardMsg:new()
	local obj = setmetatable( {}, RespHomesGetMyQuestRewardMsg.meta);
	return obj;
end

function RespHomesGetMyQuestRewardMsg:encode()
	local body = "";

	body = body ..writeGuid(self.guid);
	body = body ..writeInt(self.result);

	return body;
end

function RespHomesGetMyQuestRewardMsg:ParseData(pak)
	local idx = 1;

	self.guid, idx = readGuid(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
客户端请求：请求跨服副本信息
]]
_G.ReqCrossDungeonRoomMsg = {};

ReqCrossDungeonRoomMsg.msgId = 2185;
ReqCrossDungeonRoomMsg.dungeonId = 0; -- 副本ID



ReqCrossDungeonRoomMsg.meta = {__index = ReqCrossDungeonRoomMsg };
function ReqCrossDungeonRoomMsg:new()
	local obj = setmetatable( {}, ReqCrossDungeonRoomMsg.meta);
	return obj;
end

function ReqCrossDungeonRoomMsg:encode()
	local body = "";

	body = body ..writeInt(self.dungeonId);

	return body;
end

function ReqCrossDungeonRoomMsg:ParseData(pak)
	local idx = 1;

	self.dungeonId, idx = readInt(pak, idx);

end



--[[
客户端请求：跨服快速进入
]]
_G.ReqQuickCrossDungeonRoomMsg = {};

ReqQuickCrossDungeonRoomMsg.msgId = 2186;



ReqQuickCrossDungeonRoomMsg.meta = {__index = ReqQuickCrossDungeonRoomMsg };
function ReqQuickCrossDungeonRoomMsg:new()
	local obj = setmetatable( {}, ReqQuickCrossDungeonRoomMsg.meta);
	return obj;
end

function ReqQuickCrossDungeonRoomMsg:encode()
	local body = "";


	return body;
end

function ReqQuickCrossDungeonRoomMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：请求创建跨服副本
]]
_G.ReqCrossDungeonRoomBuildMsg = {};

ReqCrossDungeonRoomBuildMsg.msgId = 2187;
ReqCrossDungeonRoomBuildMsg.dungeonId = 0; -- 副本ID
ReqCrossDungeonRoomBuildMsg.password = ""; -- 密码
ReqCrossDungeonRoomBuildMsg.attLimit = 0; -- 战力需求



ReqCrossDungeonRoomBuildMsg.meta = {__index = ReqCrossDungeonRoomBuildMsg };
function ReqCrossDungeonRoomBuildMsg:new()
	local obj = setmetatable( {}, ReqCrossDungeonRoomBuildMsg.meta);
	return obj;
end

function ReqCrossDungeonRoomBuildMsg:encode()
	local body = "";

	body = body ..writeInt(self.dungeonId);
	body = body ..writeString(self.password,32);
	body = body ..writeInt(self.attLimit);

	return body;
end

function ReqCrossDungeonRoomBuildMsg:ParseData(pak)
	local idx = 1;

	self.dungeonId, idx = readInt(pak, idx);
	self.password, idx = readString(pak, idx, 32);
	self.attLimit, idx = readInt(pak, idx);

end



--[[
客户端请求：切换准备状态
]]
_G.ReqCrossDungeonPrepareMsg = {};

ReqCrossDungeonPrepareMsg.msgId = 2188;
ReqCrossDungeonPrepareMsg.prepare = 0; -- 准备状态 0 true 1 false



ReqCrossDungeonPrepareMsg.meta = {__index = ReqCrossDungeonPrepareMsg };
function ReqCrossDungeonPrepareMsg:new()
	local obj = setmetatable( {}, ReqCrossDungeonPrepareMsg.meta);
	return obj;
end

function ReqCrossDungeonPrepareMsg:encode()
	local body = "";

	body = body ..writeInt(self.prepare);

	return body;
end

function ReqCrossDungeonPrepareMsg:ParseData(pak)
	local idx = 1;

	self.prepare, idx = readInt(pak, idx);

end



--[[
客户端请求：退出房间
]]
_G.ReqQuitCrossDungeonRoomMsg = {};

ReqQuitCrossDungeonRoomMsg.msgId = 2189;



ReqQuitCrossDungeonRoomMsg.meta = {__index = ReqQuitCrossDungeonRoomMsg };
function ReqQuitCrossDungeonRoomMsg:new()
	local obj = setmetatable( {}, ReqQuitCrossDungeonRoomMsg.meta);
	return obj;
end

function ReqQuitCrossDungeonRoomMsg:encode()
	local body = "";


	return body;
end

function ReqQuitCrossDungeonRoomMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：进入跨服房间
]]
_G.ReqEnterCrossDungeonMsg = {};

ReqEnterCrossDungeonMsg.msgId = 2190;
ReqEnterCrossDungeonMsg.password = ""; -- 密码
ReqEnterCrossDungeonMsg.roomID = ""; -- 房间ID



ReqEnterCrossDungeonMsg.meta = {__index = ReqEnterCrossDungeonMsg };
function ReqEnterCrossDungeonMsg:new()
	local obj = setmetatable( {}, ReqEnterCrossDungeonMsg.meta);
	return obj;
end

function ReqEnterCrossDungeonMsg:encode()
	local body = "";

	body = body ..writeString(self.password,32);
	body = body ..writeGuid(self.roomID);

	return body;
end

function ReqEnterCrossDungeonMsg:ParseData(pak)
	local idx = 1;

	self.password, idx = readString(pak, idx, 32);
	self.roomID, idx = readGuid(pak, idx);

end



--[[
客户端请求：自动开始
]]
_G.ReqChangeCrossRoomAutoStartMsg = {};

ReqChangeCrossRoomAutoStartMsg.msgId = 2191;
ReqChangeCrossRoomAutoStartMsg.autoStart = 0; -- 自动开始 0 true



ReqChangeCrossRoomAutoStartMsg.meta = {__index = ReqChangeCrossRoomAutoStartMsg };
function ReqChangeCrossRoomAutoStartMsg:new()
	local obj = setmetatable( {}, ReqChangeCrossRoomAutoStartMsg.meta);
	return obj;
end

function ReqChangeCrossRoomAutoStartMsg:encode()
	local body = "";

	body = body ..writeInt(self.autoStart);

	return body;
end

function ReqChangeCrossRoomAutoStartMsg:ParseData(pak)
	local idx = 1;

	self.autoStart, idx = readInt(pak, idx);

end



--[[
客户端请求：房间开始战斗
]]
_G.ReqCrossRoomStartMsg = {};

ReqCrossRoomStartMsg.msgId = 2192;



ReqCrossRoomStartMsg.meta = {__index = ReqCrossRoomStartMsg };
function ReqCrossRoomStartMsg:new()
	local obj = setmetatable( {}, ReqCrossRoomStartMsg.meta);
	return obj;
end

function ReqCrossRoomStartMsg:encode()
	local body = "";


	return body;
end

function ReqCrossRoomStartMsg:ParseData(pak)
	local idx = 1;


end



--[[
跨服重连进入战斗
]]
_G.ReqReEnterGameMsg = {};

ReqReEnterGameMsg.msgId = 2193;
ReqReEnterGameMsg.guid = ""; -- 玩家GUID
ReqReEnterGameMsg.accountID = ""; -- 玩家ID
ReqReEnterGameMsg.sign = ""; -- MD5



ReqReEnterGameMsg.meta = {__index = ReqReEnterGameMsg };
function ReqReEnterGameMsg:new()
	local obj = setmetatable( {}, ReqReEnterGameMsg.meta);
	return obj;
end

function ReqReEnterGameMsg:encode()
	local body = "";

	body = body ..writeGuid(self.guid);
	body = body ..writeString(self.accountID,64);
	body = body ..writeString(self.sign,33);

	return body;
end

function ReqReEnterGameMsg:ParseData(pak)
	local idx = 1;

	self.guid, idx = readGuid(pak, idx);
	self.accountID, idx = readString(pak, idx, 64);
	self.sign, idx = readString(pak, idx, 33);

end



--[[
跨服重连进入场景
]]
_G.ReqReEnterSceneMsg = {};

ReqReEnterSceneMsg.msgId = 2194;



ReqReEnterSceneMsg.meta = {__index = ReqReEnterSceneMsg };
function ReqReEnterSceneMsg:new()
	local obj = setmetatable( {}, ReqReEnterSceneMsg.meta);
	return obj;
end

function ReqReEnterSceneMsg:encode()
	local body = "";


	return body;
end

function ReqReEnterSceneMsg:ParseData(pak)
	local idx = 1;


end



--[[
弟子使用经验
]]
_G.ReqHomesUsePupilExpMsg = {};

ReqHomesUsePupilExpMsg.msgId = 2195;
ReqHomesUsePupilExpMsg.pupilguid = ""; -- 弟子id
ReqHomesUsePupilExpMsg.cid = 0; -- 物品id



ReqHomesUsePupilExpMsg.meta = {__index = ReqHomesUsePupilExpMsg };
function ReqHomesUsePupilExpMsg:new()
	local obj = setmetatable( {}, ReqHomesUsePupilExpMsg.meta);
	return obj;
end

function ReqHomesUsePupilExpMsg:encode()
	local body = "";

	body = body ..writeGuid(self.pupilguid);
	body = body ..writeInt(self.cid);

	return body;
end

function ReqHomesUsePupilExpMsg:ParseData(pak)
	local idx = 1;

	self.pupilguid, idx = readGuid(pak, idx);
	self.cid, idx = readInt(pak, idx);

end



--[[
开始匹配
]]
_G.ReqStartMatchPvpMsg = {};

ReqStartMatchPvpMsg.msgId = 2196;



ReqStartMatchPvpMsg.meta = {__index = ReqStartMatchPvpMsg };
function ReqStartMatchPvpMsg:new()
	local obj = setmetatable( {}, ReqStartMatchPvpMsg.meta);
	return obj;
end

function ReqStartMatchPvpMsg:encode()
	local body = "";


	return body;
end

function ReqStartMatchPvpMsg:ParseData(pak)
	local idx = 1;


end



--[[
退出匹配
]]
_G.ReqExitMatchPvpMsg = {};

ReqExitMatchPvpMsg.msgId = 2197;



ReqExitMatchPvpMsg.meta = {__index = ReqExitMatchPvpMsg };
function ReqExitMatchPvpMsg:new()
	local obj = setmetatable( {}, ReqExitMatchPvpMsg.meta);
	return obj;
end

function ReqExitMatchPvpMsg:encode()
	local body = "";


	return body;
end

function ReqExitMatchPvpMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求跨服信息
]]
_G.ReqCrossPvpInfoMsg = {};

ReqCrossPvpInfoMsg.msgId = 2198;



ReqCrossPvpInfoMsg.meta = {__index = ReqCrossPvpInfoMsg };
function ReqCrossPvpInfoMsg:new()
	local obj = setmetatable( {}, ReqCrossPvpInfoMsg.meta);
	return obj;
end

function ReqCrossPvpInfoMsg:encode()
	local body = "";


	return body;
end

function ReqCrossPvpInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求历届跨服信息
]]
_G.ReqCrossSeasonPvpInfoMsg = {};

ReqCrossSeasonPvpInfoMsg.msgId = 2199;
ReqCrossSeasonPvpInfoMsg.seasonid = 0; -- 赛季ID



ReqCrossSeasonPvpInfoMsg.meta = {__index = ReqCrossSeasonPvpInfoMsg };
function ReqCrossSeasonPvpInfoMsg:new()
	local obj = setmetatable( {}, ReqCrossSeasonPvpInfoMsg.meta);
	return obj;
end

function ReqCrossSeasonPvpInfoMsg:encode()
	local body = "";

	body = body ..writeInt(self.seasonid);

	return body;
end

function ReqCrossSeasonPvpInfoMsg:ParseData(pak)
	local idx = 1;

	self.seasonid, idx = readInt(pak, idx);

end



--[[
发送活动信息
]]
_G.ReqSendGuildActivityNoticeMsg = {};

ReqSendGuildActivityNoticeMsg.msgId = 2200;
ReqSendGuildActivityNoticeMsg.id = 0; -- 活动ID
ReqSendGuildActivityNoticeMsg.param = 0; -- 参数
ReqSendGuildActivityNoticeMsg.text = ""; -- 内容



ReqSendGuildActivityNoticeMsg.meta = {__index = ReqSendGuildActivityNoticeMsg };
function ReqSendGuildActivityNoticeMsg:new()
	local obj = setmetatable( {}, ReqSendGuildActivityNoticeMsg.meta);
	return obj;
end

function ReqSendGuildActivityNoticeMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.param);
	body = body ..writeString(self.text,128);

	return body;
end

function ReqSendGuildActivityNoticeMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.param, idx = readInt(pak, idx);
	self.text, idx = readString(pak, idx, 128);

end



--[[
请求PVP每日奖励
]]
_G.ReqGetPvpDayRewardMsg = {};

ReqGetPvpDayRewardMsg.msgId = 2202;



ReqGetPvpDayRewardMsg.meta = {__index = ReqGetPvpDayRewardMsg };
function ReqGetPvpDayRewardMsg:new()
	local obj = setmetatable( {}, ReqGetPvpDayRewardMsg.meta);
	return obj;
end

function ReqGetPvpDayRewardMsg:encode()
	local body = "";


	return body;
end

function ReqGetPvpDayRewardMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求使用GM称号
]]
_G.ReqGMTitleMsg = {};

ReqGMTitleMsg.msgId = 2203;
ReqGMTitleMsg.isUseGMTitle = 0; -- 是否使用GM称号
ReqGMTitleMsg.isChat = 0; -- 是否接收聊天



ReqGMTitleMsg.meta = {__index = ReqGMTitleMsg };
function ReqGMTitleMsg:new()
	local obj = setmetatable( {}, ReqGMTitleMsg.meta);
	return obj;
end

function ReqGMTitleMsg:encode()
	local body = "";

	body = body ..writeInt(self.isUseGMTitle);
	body = body ..writeInt(self.isChat);

	return body;
end

function ReqGMTitleMsg:ParseData(pak)
	local idx = 1;

	self.isUseGMTitle, idx = readInt(pak, idx);
	self.isChat, idx = readInt(pak, idx);

end



--[[
请求被GM的列表
]]
_G.ReqGMListMsg = {};

ReqGMListMsg.msgId = 2204;
ReqGMListMsg.type = 0; -- 1禁言列表,2封停列表,3封mac列表



ReqGMListMsg.meta = {__index = ReqGMListMsg };
function ReqGMListMsg:new()
	local obj = setmetatable( {}, ReqGMListMsg.meta);
	return obj;
end

function ReqGMListMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqGMListMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
GM查找
]]
_G.ReqGMSearchMsg = {};

ReqGMSearchMsg.msgId = 2206;
ReqGMSearchMsg.key = ""; -- key



ReqGMSearchMsg.meta = {__index = ReqGMSearchMsg };
function ReqGMSearchMsg:new()
	local obj = setmetatable( {}, ReqGMSearchMsg.meta);
	return obj;
end

function ReqGMSearchMsg:encode()
	local body = "";

	body = body ..writeString(self.key,32);

	return body;
end

function ReqGMSearchMsg:ParseData(pak)
	local idx = 1;

	self.key, idx = readString(pak, idx, 32);

end



--[[
GM操作
]]
_G.ReqGMOperMsg = {};

ReqGMOperMsg.msgId = 2207;
ReqGMOperMsg.id = ""; -- uid
ReqGMOperMsg.type = 0; -- 1禁言,2封停,3mac,4踢下线
ReqGMOperMsg.time = 0; -- time



ReqGMOperMsg.meta = {__index = ReqGMOperMsg };
function ReqGMOperMsg:new()
	local obj = setmetatable( {}, ReqGMOperMsg.meta);
	return obj;
end

function ReqGMOperMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);
	body = body ..writeInt(self.type);
	body = body ..writeInt64(self.time);

	return body;
end

function ReqGMOperMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.type, idx = readInt(pak, idx);
	self.time, idx = readInt64(pak, idx);

end



--[[
GM反向操作
]]
_G.ReqGMUnOperMsg = {};

ReqGMUnOperMsg.msgId = 2208;
ReqGMUnOperMsg.id = ""; -- uid
ReqGMUnOperMsg.type = 0; -- 1禁言,2封停,3mac



ReqGMUnOperMsg.meta = {__index = ReqGMUnOperMsg };
function ReqGMUnOperMsg:new()
	local obj = setmetatable( {}, ReqGMUnOperMsg.meta);
	return obj;
end

function ReqGMUnOperMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);
	body = body ..writeInt(self.type);

	return body;
end

function ReqGMUnOperMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
请求GM帮派成员列表
]]
_G.ReqGMGuildRoleListMsg = {};

ReqGMGuildRoleListMsg.msgId = 2209;
ReqGMGuildRoleListMsg.guildUid = ""; -- uid



ReqGMGuildRoleListMsg.meta = {__index = ReqGMGuildRoleListMsg };
function ReqGMGuildRoleListMsg:new()
	local obj = setmetatable( {}, ReqGMGuildRoleListMsg.meta);
	return obj;
end

function ReqGMGuildRoleListMsg:encode()
	local body = "";

	body = body ..writeGuid(self.guildUid);

	return body;
end

function ReqGMGuildRoleListMsg:ParseData(pak)
	local idx = 1;

	self.guildUid, idx = readGuid(pak, idx);

end



--[[
请求GM帮派操作,推列表刷新
]]
_G.ReqGMGuildOperMsg = {};

ReqGMGuildOperMsg.msgId = 2210;
ReqGMGuildOperMsg.guildUid = ""; -- uid
ReqGMGuildOperMsg.roleId = ""; -- roleId
ReqGMGuildOperMsg.type = 0; -- 任命帮主/副帮主/长老/精英/帮众/踢出成员



ReqGMGuildOperMsg.meta = {__index = ReqGMGuildOperMsg };
function ReqGMGuildOperMsg:new()
	local obj = setmetatable( {}, ReqGMGuildOperMsg.meta);
	return obj;
end

function ReqGMGuildOperMsg:encode()
	local body = "";

	body = body ..writeGuid(self.guildUid);
	body = body ..writeGuid(self.roleId);
	body = body ..writeInt(self.type);

	return body;
end

function ReqGMGuildOperMsg:ParseData(pak)
	local idx = 1;

	self.guildUid, idx = readGuid(pak, idx);
	self.roleId, idx = readGuid(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
请求GM解散帮派
]]
_G.ReqGMGuildDismissMsg = {};

ReqGMGuildDismissMsg.msgId = 2211;
ReqGMGuildDismissMsg.guildUid = ""; -- uid



ReqGMGuildDismissMsg.meta = {__index = ReqGMGuildDismissMsg };
function ReqGMGuildDismissMsg:new()
	local obj = setmetatable( {}, ReqGMGuildDismissMsg.meta);
	return obj;
end

function ReqGMGuildDismissMsg:encode()
	local body = "";

	body = body ..writeGuid(self.guildUid);

	return body;
end

function ReqGMGuildDismissMsg:ParseData(pak)
	local idx = 1;

	self.guildUid, idx = readGuid(pak, idx);

end



--[[
请求发送世界notice
]]
_G.ReqWCWorldNoticeMsg = {};

ReqWCWorldNoticeMsg.msgId = 2212;
ReqWCWorldNoticeMsg.type = 0; -- 1 灵光封魔 2 帮派招人



ReqWCWorldNoticeMsg.meta = {__index = ReqWCWorldNoticeMsg };
function ReqWCWorldNoticeMsg:new()
	local obj = setmetatable( {}, ReqWCWorldNoticeMsg.meta);
	return obj;
end

function ReqWCWorldNoticeMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqWCWorldNoticeMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
请求红包排行
]]
_G.ReqGetRedPacketRankMsg = {};

ReqGetRedPacketRankMsg.msgId = 2214;
ReqGetRedPacketRankMsg.id = 0; -- 红包id



ReqGetRedPacketRankMsg.meta = {__index = ReqGetRedPacketRankMsg };
function ReqGetRedPacketRankMsg:new()
	local obj = setmetatable( {}, ReqGetRedPacketRankMsg.meta);
	return obj;
end

function ReqGetRedPacketRankMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqGetRedPacketRankMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
请求领取红包
]]
_G.ReqGetRedPacketMsg = {};

ReqGetRedPacketMsg.msgId = 2215;
ReqGetRedPacketMsg.id = 0; -- 红包id



ReqGetRedPacketMsg.meta = {__index = ReqGetRedPacketMsg };
function ReqGetRedPacketMsg:new()
	local obj = setmetatable( {}, ReqGetRedPacketMsg.meta);
	return obj;
end

function ReqGetRedPacketMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqGetRedPacketMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
客户端请求: 我的寄售行物品信息
]]
_G.ReqConsignmentItemInShelvesMsg = {};

ReqConsignmentItemInShelvesMsg.msgId = 2216;
ReqConsignmentItemInShelvesMsg.uid = ""; -- 物品uid
ReqConsignmentItemInShelvesMsg.num = 0; -- 数量
ReqConsignmentItemInShelvesMsg.money = 0; -- 货币数量
ReqConsignmentItemInShelvesMsg.timerLimit = 0; -- 出售时限，1=12小时，2=24小时，3=48小时,4=78小时



ReqConsignmentItemInShelvesMsg.meta = {__index = ReqConsignmentItemInShelvesMsg };
function ReqConsignmentItemInShelvesMsg:new()
	local obj = setmetatable( {}, ReqConsignmentItemInShelvesMsg.meta);
	return obj;
end

function ReqConsignmentItemInShelvesMsg:encode()
	local body = "";

	body = body ..writeGuid(self.uid);
	body = body ..writeInt(self.num);
	body = body ..writeInt(self.money);
	body = body ..writeInt(self.timerLimit);

	return body;
end

function ReqConsignmentItemInShelvesMsg:ParseData(pak)
	local idx = 1;

	self.uid, idx = readGuid(pak, idx);
	self.num, idx = readInt(pak, idx);
	self.money, idx = readInt(pak, idx);
	self.timerLimit, idx = readInt(pak, idx);

end



--[[
放弃任务
]]
_G.ReqHomesGiveupQuestMsg = {};

ReqHomesGiveupQuestMsg.msgId = 2217;
ReqHomesGiveupQuestMsg.guid = ""; -- 任务id



ReqHomesGiveupQuestMsg.meta = {__index = ReqHomesGiveupQuestMsg };
function ReqHomesGiveupQuestMsg:new()
	local obj = setmetatable( {}, ReqHomesGiveupQuestMsg.meta);
	return obj;
end

function ReqHomesGiveupQuestMsg:encode()
	local body = "";

	body = body ..writeGuid(self.guid);

	return body;
end

function ReqHomesGiveupQuestMsg:ParseData(pak)
	local idx = 1;

	self.guid, idx = readGuid(pak, idx);

end



--[[
团购购买
]]
_G.ReqPartyBuyMsg = {};

ReqPartyBuyMsg.msgId = 2218;
ReqPartyBuyMsg.id = 0; -- 活动id



ReqPartyBuyMsg.meta = {__index = ReqPartyBuyMsg };
function ReqPartyBuyMsg:new()
	local obj = setmetatable( {}, ReqPartyBuyMsg.meta);
	return obj;
end

function ReqPartyBuyMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqPartyBuyMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
扩展帮派人数
]]
_G.ReqExtendGuildMsg = {};

ReqExtendGuildMsg.msgId = 2222;
ReqExtendGuildMsg.itemid = ""; -- 物品ID



ReqExtendGuildMsg.meta = {__index = ReqExtendGuildMsg };
function ReqExtendGuildMsg:new()
	local obj = setmetatable( {}, ReqExtendGuildMsg.meta);
	return obj;
end

function ReqExtendGuildMsg:encode()
	local body = "";

	body = body ..writeGuid(self.itemid);

	return body;
end

function ReqExtendGuildMsg:ParseData(pak)
	local idx = 1;

	self.itemid, idx = readGuid(pak, idx);

end



--[[
请求帮派弹劾权限
]]
_G.ReqGuildTanHeQuanXianMsg = {};

ReqGuildTanHeQuanXianMsg.msgId = 2223;



ReqGuildTanHeQuanXianMsg.meta = {__index = ReqGuildTanHeQuanXianMsg };
function ReqGuildTanHeQuanXianMsg:new()
	local obj = setmetatable( {}, ReqGuildTanHeQuanXianMsg.meta);
	return obj;
end

function ReqGuildTanHeQuanXianMsg:encode()
	local body = "";


	return body;
end

function ReqGuildTanHeQuanXianMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求帮派弹劾
]]
_G.ReqGuildTanHeMsg = {};

ReqGuildTanHeMsg.msgId = 2224;



ReqGuildTanHeMsg.meta = {__index = ReqGuildTanHeMsg };
function ReqGuildTanHeMsg:new()
	local obj = setmetatable( {}, ReqGuildTanHeMsg.meta);
	return obj;
end

function ReqGuildTanHeMsg:encode()
	local body = "";


	return body;
end

function ReqGuildTanHeMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求帮派仓库审批列表
]]
_G.ReqGuildQueryCheckListMsg = {};

ReqGuildQueryCheckListMsg.msgId = 2225;



ReqGuildQueryCheckListMsg.meta = {__index = ReqGuildQueryCheckListMsg };
function ReqGuildQueryCheckListMsg:new()
	local obj = setmetatable( {}, ReqGuildQueryCheckListMsg.meta);
	return obj;
end

function ReqGuildQueryCheckListMsg:encode()
	local body = "";


	return body;
end

function ReqGuildQueryCheckListMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求帮派审核操作
]]
_G.ReqGuildQueryCheckOperMsg = {};

ReqGuildQueryCheckOperMsg.msgId = 2226;
ReqGuildQueryCheckOperMsg.operid = ""; -- 玩家ID
ReqGuildQueryCheckOperMsg.oper = 0; -- 1-批准，2-拒绝, 3-撤销



ReqGuildQueryCheckOperMsg.meta = {__index = ReqGuildQueryCheckOperMsg };
function ReqGuildQueryCheckOperMsg:new()
	local obj = setmetatable( {}, ReqGuildQueryCheckOperMsg.meta);
	return obj;
end

function ReqGuildQueryCheckOperMsg:encode()
	local body = "";

	body = body ..writeGuid(self.operid);
	body = body ..writeInt(self.oper);

	return body;
end

function ReqGuildQueryCheckOperMsg:ParseData(pak)
	local idx = 1;

	self.operid, idx = readGuid(pak, idx);
	self.oper, idx = readInt(pak, idx);

end



--[[
请求设置自动审核
]]
_G.ReqGuildSetAutoCheckMsg = {};

ReqGuildSetAutoCheckMsg.msgId = 2227;
ReqGuildSetAutoCheckMsg.pos = 0; -- 自动审核职位



ReqGuildSetAutoCheckMsg.meta = {__index = ReqGuildSetAutoCheckMsg };
function ReqGuildSetAutoCheckMsg:new()
	local obj = setmetatable( {}, ReqGuildSetAutoCheckMsg.meta);
	return obj;
end

function ReqGuildSetAutoCheckMsg:encode()
	local body = "";

	body = body ..writeInt(self.pos);

	return body;
end

function ReqGuildSetAutoCheckMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readInt(pak, idx);

end



--[[
客户端请求举报聊天
]]
_G.ReqBanChatMsg = {};

ReqBanChatMsg.msgId = 2230;
ReqBanChatMsg.roleId = ""; -- 角色id



ReqBanChatMsg.meta = {__index = ReqBanChatMsg };
function ReqBanChatMsg:new()
	local obj = setmetatable( {}, ReqBanChatMsg.meta);
	return obj;
end

function ReqBanChatMsg:encode()
	local body = "";

	body = body ..writeGuid(self.roleId);

	return body;
end

function ReqBanChatMsg:ParseData(pak)
	local idx = 1;

	self.roleId, idx = readGuid(pak, idx);

end



--[[
请求准备加入帮派地宫争夺战
]]
_G.ReqUnionEnterDiGongWarMsg = {};

ReqUnionEnterDiGongWarMsg.msgId = 2231;



ReqUnionEnterDiGongWarMsg.meta = {__index = ReqUnionEnterDiGongWarMsg };
function ReqUnionEnterDiGongWarMsg:new()
	local obj = setmetatable( {}, ReqUnionEnterDiGongWarMsg.meta);
	return obj;
end

function ReqUnionEnterDiGongWarMsg:encode()
	local body = "";


	return body;
end

function ReqUnionEnterDiGongWarMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求帮派野外地宫信息
]]
_G.ReqUnionDiGongInfoMsg = {};

ReqUnionDiGongInfoMsg.msgId = 2232;



ReqUnionDiGongInfoMsg.meta = {__index = ReqUnionDiGongInfoMsg };
function ReqUnionDiGongInfoMsg:new()
	local obj = setmetatable( {}, ReqUnionDiGongInfoMsg.meta);
	return obj;
end

function ReqUnionDiGongInfoMsg:encode()
	local body = "";


	return body;
end

function ReqUnionDiGongInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求帮派野外地宫竞标信息
]]
_G.ReqUnionDiGongBidInfoMsg = {};

ReqUnionDiGongBidInfoMsg.msgId = 2233;
ReqUnionDiGongBidInfoMsg.id = 0; -- 活动id



ReqUnionDiGongBidInfoMsg.meta = {__index = ReqUnionDiGongBidInfoMsg };
function ReqUnionDiGongBidInfoMsg:new()
	local obj = setmetatable( {}, ReqUnionDiGongBidInfoMsg.meta);
	return obj;
end

function ReqUnionDiGongBidInfoMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqUnionDiGongBidInfoMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
请求帮派野外地宫竞标
]]
_G.ReqUnionDiGongBidMsg = {};

ReqUnionDiGongBidMsg.msgId = 2234;
ReqUnionDiGongBidMsg.id = 0; -- 活动id
ReqUnionDiGongBidMsg.bidmoney = 0; -- 竞标资金



ReqUnionDiGongBidMsg.meta = {__index = ReqUnionDiGongBidMsg };
function ReqUnionDiGongBidMsg:new()
	local obj = setmetatable( {}, ReqUnionDiGongBidMsg.meta);
	return obj;
end

function ReqUnionDiGongBidMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt64(self.bidmoney);

	return body;
end

function ReqUnionDiGongBidMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.bidmoney, idx = readInt64(pak, idx);

end



--[[
请求跨服排行刷新状态
]]
_G.ReqKuafuRankListStateMsg = {};

ReqKuafuRankListStateMsg.msgId = 2236;
ReqKuafuRankListStateMsg.rankType = 0; -- 1段位排行，2荣耀排行



ReqKuafuRankListStateMsg.meta = {__index = ReqKuafuRankListStateMsg };
function ReqKuafuRankListStateMsg:new()
	local obj = setmetatable( {}, ReqKuafuRankListStateMsg.meta);
	return obj;
end

function ReqKuafuRankListStateMsg:encode()
	local body = "";

	body = body ..writeInt(self.rankType);

	return body;
end

function ReqKuafuRankListStateMsg:ParseData(pak)
	local idx = 1;

	self.rankType, idx = readInt(pak, idx);

end



--[[
请求跨服段位排行
]]
_G.ReqKuafuRankDuanweiListMsg = {};

ReqKuafuRankDuanweiListMsg.msgId = 2237;
ReqKuafuRankDuanweiListMsg.type = 0; -- 1=段位，2=荣耀
ReqKuafuRankDuanweiListMsg.version = 0; -- 版本



ReqKuafuRankDuanweiListMsg.meta = {__index = ReqKuafuRankDuanweiListMsg };
function ReqKuafuRankDuanweiListMsg:new()
	local obj = setmetatable( {}, ReqKuafuRankDuanweiListMsg.meta);
	return obj;
end

function ReqKuafuRankDuanweiListMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);
	body = body ..writeInt(self.version);

	return body;
end

function ReqKuafuRankDuanweiListMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.version, idx = readInt(pak, idx);

end



--[[
请求跨服荣耀榜信息
]]
_G.ReqKuafuRongyaoInfoMsg = {};

ReqKuafuRongyaoInfoMsg.msgId = 2238;



ReqKuafuRongyaoInfoMsg.meta = {__index = ReqKuafuRongyaoInfoMsg };
function ReqKuafuRongyaoInfoMsg:new()
	local obj = setmetatable( {}, ReqKuafuRongyaoInfoMsg.meta);
	return obj;
end

function ReqKuafuRongyaoInfoMsg:encode()
	local body = "";


	return body;
end

function ReqKuafuRongyaoInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求跨服荣耀榜奖励
]]
_G.ReqGetPvpRongyaoRewardMsg = {};

ReqGetPvpRongyaoRewardMsg.msgId = 2239;



ReqGetPvpRongyaoRewardMsg.meta = {__index = ReqGetPvpRongyaoRewardMsg };
function ReqGetPvpRongyaoRewardMsg:new()
	local obj = setmetatable( {}, ReqGetPvpRongyaoRewardMsg.meta);
	return obj;
end

function ReqGetPvpRongyaoRewardMsg:encode()
	local body = "";


	return body;
end

function ReqGetPvpRongyaoRewardMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求GM设置公告
]]
_G.ReqGMGuildNoticeMsg = {};

ReqGMGuildNoticeMsg.msgId = 2241;
ReqGMGuildNoticeMsg.guildUid = ""; -- uid
ReqGMGuildNoticeMsg.notice = ""; -- 帮派公告



ReqGMGuildNoticeMsg.meta = {__index = ReqGMGuildNoticeMsg };
function ReqGMGuildNoticeMsg:new()
	local obj = setmetatable( {}, ReqGMGuildNoticeMsg.meta);
	return obj;
end

function ReqGMGuildNoticeMsg:encode()
	local body = "";

	body = body ..writeGuid(self.guildUid);
	body = body ..writeString(self.notice,128);

	return body;
end

function ReqGMGuildNoticeMsg:ParseData(pak)
	local idx = 1;

	self.guildUid, idx = readGuid(pak, idx);
	self.notice, idx = readString(pak, idx, 128);

end



--[[
请求进入跨服Boss
]]
_G.ReqEnterCrossBossMsg = {};

ReqEnterCrossBossMsg.msgId = 2242;
ReqEnterCrossBossMsg.gamemapID = 0; -- Boss地图ID
ReqEnterCrossBossMsg.srvid = 0; -- 区服ID



ReqEnterCrossBossMsg.meta = {__index = ReqEnterCrossBossMsg };
function ReqEnterCrossBossMsg:new()
	local obj = setmetatable( {}, ReqEnterCrossBossMsg.meta);
	return obj;
end

function ReqEnterCrossBossMsg:encode()
	local body = "";

	body = body ..writeInt64(self.gamemapID);
	body = body ..writeInt(self.srvid);

	return body;
end

function ReqEnterCrossBossMsg:ParseData(pak)
	local idx = 1;

	self.gamemapID, idx = readInt64(pak, idx);
	self.srvid, idx = readInt(pak, idx);

end



--[[
请求跨服BOSS排行信息
]]
_G.ReqCrossBossInfoMsg = {};

ReqCrossBossInfoMsg.msgId = 2243;



ReqCrossBossInfoMsg.meta = {__index = ReqCrossBossInfoMsg };
function ReqCrossBossInfoMsg:new()
	local obj = setmetatable( {}, ReqCrossBossInfoMsg.meta);
	return obj;
end

function ReqCrossBossInfoMsg:encode()
	local body = "";


	return body;
end

function ReqCrossBossInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求进入跨服擂台赛
]]
_G.ReqEnterCrossArenaMsg = {};

ReqEnterCrossArenaMsg.msgId = 2247;
ReqEnterCrossArenaMsg.srvid = 0; -- 区服ID



ReqEnterCrossArenaMsg.meta = {__index = ReqEnterCrossArenaMsg };
function ReqEnterCrossArenaMsg:new()
	local obj = setmetatable( {}, ReqEnterCrossArenaMsg.meta);
	return obj;
end

function ReqEnterCrossArenaMsg:encode()
	local body = "";

	body = body ..writeInt(self.srvid);

	return body;
end

function ReqEnterCrossArenaMsg:ParseData(pak)
	local idx = 1;

	self.srvid, idx = readInt(pak, idx);

end



--[[
请求擂台赛信息
]]
_G.ReqCrossArenaInfoMsg = {};

ReqCrossArenaInfoMsg.msgId = 2248;
ReqCrossArenaInfoMsg.seasonid = 0; -- 第几届



ReqCrossArenaInfoMsg.meta = {__index = ReqCrossArenaInfoMsg };
function ReqCrossArenaInfoMsg:new()
	local obj = setmetatable( {}, ReqCrossArenaInfoMsg.meta);
	return obj;
end

function ReqCrossArenaInfoMsg:encode()
	local body = "";

	body = body ..writeInt(self.seasonid);

	return body;
end

function ReqCrossArenaInfoMsg:ParseData(pak)
	local idx = 1;

	self.seasonid, idx = readInt(pak, idx);

end



--[[
请求擂台赛资格
]]
_G.ReqCrossArenaZigeMsg = {};

ReqCrossArenaZigeMsg.msgId = 2250;



ReqCrossArenaZigeMsg.meta = {__index = ReqCrossArenaZigeMsg };
function ReqCrossArenaZigeMsg:new()
	local obj = setmetatable( {}, ReqCrossArenaZigeMsg.meta);
	return obj;
end

function ReqCrossArenaZigeMsg:encode()
	local body = "";


	return body;
end

function ReqCrossArenaZigeMsg:ParseData(pak)
	local idx = 1;


end



--[[
求婚
]]
_G.ReqProposalMsg = {};

ReqProposalMsg.msgId = 2251;
ReqProposalMsg.roleID = ""; -- 角色ID
ReqProposalMsg.desc = ""; -- 求婚宣言
ReqProposalMsg.ringId = 0; -- 戒指id



ReqProposalMsg.meta = {__index = ReqProposalMsg };
function ReqProposalMsg:new()
	local obj = setmetatable( {}, ReqProposalMsg.meta);
	return obj;
end

function ReqProposalMsg:encode()
	local body = "";

	body = body ..writeGuid(self.roleID);
	body = body ..writeString(self.desc,128);
	body = body ..writeInt(self.ringId);

	return body;
end

function ReqProposalMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.desc, idx = readString(pak, idx, 128);
	self.ringId, idx = readInt(pak, idx);

end



--[[
被求婚者的选择
]]
_G.ReqBeProposaledChooseMsg = {};

ReqBeProposaledChooseMsg.msgId = 2252;
ReqBeProposaledChooseMsg.name = ""; -- 求婚者
ReqBeProposaledChooseMsg.result = 0; -- 选择结果0不同意，1同意
ReqBeProposaledChooseMsg.ringId = 0; -- 戒指id



ReqBeProposaledChooseMsg.meta = {__index = ReqBeProposaledChooseMsg };
function ReqBeProposaledChooseMsg:new()
	local obj = setmetatable( {}, ReqBeProposaledChooseMsg.meta);
	return obj;
end

function ReqBeProposaledChooseMsg:encode()
	local body = "";

	body = body ..writeString(self.name,32);
	body = body ..writeInt(self.result);
	body = body ..writeInt(self.ringId);

	return body;
end

function ReqBeProposaledChooseMsg:ParseData(pak)
	local idx = 1;

	self.name, idx = readString(pak, idx, 32);
	self.result, idx = readInt(pak, idx);
	self.ringId, idx = readInt(pak, idx);

end



--[[
预约时间
]]
_G.ReqAookyNarryDataMsg = {};

ReqAookyNarryDataMsg.msgId = 2253;
ReqAookyNarryDataMsg.time = 0; -- 预约时间戳



ReqAookyNarryDataMsg.meta = {__index = ReqAookyNarryDataMsg };
function ReqAookyNarryDataMsg:new()
	local obj = setmetatable( {}, ReqAookyNarryDataMsg.meta);
	return obj;
end

function ReqAookyNarryDataMsg:encode()
	local body = "";

	body = body ..writeInt64(self.time);

	return body;
end

function ReqAookyNarryDataMsg:ParseData(pak)
	local idx = 1;

	self.time, idx = readInt64(pak, idx);

end



--[[
申请结婚
]]
_G.ReqApplyMarryMsg = {};

ReqApplyMarryMsg.msgId = 2254;
ReqApplyMarryMsg.toke = 0; -- 预约星期
ReqApplyMarryMsg.time = 0; -- 预约时间戳
ReqApplyMarryMsg.timeIndex = 0; -- 时间下标



ReqApplyMarryMsg.meta = {__index = ReqApplyMarryMsg };
function ReqApplyMarryMsg:new()
	local obj = setmetatable( {}, ReqApplyMarryMsg.meta);
	return obj;
end

function ReqApplyMarryMsg:encode()
	local body = "";

	body = body ..writeInt(self.toke);
	body = body ..writeInt64(self.time);
	body = body ..writeInt(self.timeIndex);

	return body;
end

function ReqApplyMarryMsg:ParseData(pak)
	local idx = 1;

	self.toke, idx = readInt(pak, idx);
	self.time, idx = readInt64(pak, idx);
	self.timeIndex, idx = readInt(pak, idx);

end



--[[
申请发送婚礼邀请
]]
_G.ReqMarryInviteMsg = {};

ReqMarryInviteMsg.msgId = 2256;



ReqMarryInviteMsg.meta = {__index = ReqMarryInviteMsg };
function ReqMarryInviteMsg:new()
	local obj = setmetatable( {}, ReqMarryInviteMsg.meta);
	return obj;
end

function ReqMarryInviteMsg:encode()
	local body = "";


	return body;
end

function ReqMarryInviteMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求查看红包详情
]]
_G.ReqLookMarryRedPacketsMsg = {};

ReqLookMarryRedPacketsMsg.msgId = 2257;



ReqLookMarryRedPacketsMsg.meta = {__index = ReqLookMarryRedPacketsMsg };
function ReqLookMarryRedPacketsMsg:new()
	local obj = setmetatable( {}, ReqLookMarryRedPacketsMsg.meta);
	return obj;
end

function ReqLookMarryRedPacketsMsg:encode()
	local body = "";


	return body;
end

function ReqLookMarryRedPacketsMsg:ParseData(pak)
	local idx = 1;


end



--[[
婚礼mv结束
]]
_G.ReqMarryMovEndMsg = {};

ReqMarryMovEndMsg.msgId = 2258;



ReqMarryMovEndMsg.meta = {__index = ReqMarryMovEndMsg };
function ReqMarryMovEndMsg:new()
	local obj = setmetatable( {}, ReqMarryMovEndMsg.meta);
	return obj;
end

function ReqMarryMovEndMsg:encode()
	local body = "";


	return body;
end

function ReqMarryMovEndMsg:ParseData(pak)
	local idx = 1;


end



--[[
传送到配偶身边
]]
_G.ReqFlyToMateMsg = {};

ReqFlyToMateMsg.msgId = 2261;



ReqFlyToMateMsg.meta = {__index = ReqFlyToMateMsg };
function ReqFlyToMateMsg:new()
	local obj = setmetatable( {}, ReqFlyToMateMsg.meta);
	return obj;
end

function ReqFlyToMateMsg:encode()
	local body = "";


	return body;
end

function ReqFlyToMateMsg:ParseData(pak)
	local idx = 1;


end



--[[
换线成功，请求传送
]]
_G.ReqFlyToMateOkMsg = {};

ReqFlyToMateOkMsg.msgId = 2262;



ReqFlyToMateOkMsg.meta = {__index = ReqFlyToMateOkMsg };
function ReqFlyToMateOkMsg:new()
	local obj = setmetatable( {}, ReqFlyToMateOkMsg.meta);
	return obj;
end

function ReqFlyToMateOkMsg:encode()
	local body = "";


	return body;
end

function ReqFlyToMateOkMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求擂台赛下注信息
]]
_G.ReqCrossArenaXiaZhuInfoMsg = {};

ReqCrossArenaXiaZhuInfoMsg.msgId = 2263;



ReqCrossArenaXiaZhuInfoMsg.meta = {__index = ReqCrossArenaXiaZhuInfoMsg };
function ReqCrossArenaXiaZhuInfoMsg:new()
	local obj = setmetatable( {}, ReqCrossArenaXiaZhuInfoMsg.meta);
	return obj;
end

function ReqCrossArenaXiaZhuInfoMsg:encode()
	local body = "";


	return body;
end

function ReqCrossArenaXiaZhuInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求擂台赛下注
]]
_G.ReqCrossArenaXiaZhuMsg = {};

ReqCrossArenaXiaZhuMsg.msgId = 2264;
ReqCrossArenaXiaZhuMsg.id = ""; -- ID
ReqCrossArenaXiaZhuMsg.gold = 0; -- 下注金额



ReqCrossArenaXiaZhuMsg.meta = {__index = ReqCrossArenaXiaZhuMsg };
function ReqCrossArenaXiaZhuMsg:new()
	local obj = setmetatable( {}, ReqCrossArenaXiaZhuMsg.meta);
	return obj;
end

function ReqCrossArenaXiaZhuMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);
	body = body ..writeInt(self.gold);

	return body;
end

function ReqCrossArenaXiaZhuMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.gold, idx = readInt(pak, idx);

end



--[[
请求擂台赛鼓舞
]]
_G.ReqCrossArenaGuWuMsg = {};

ReqCrossArenaGuWuMsg.msgId = 2265;



ReqCrossArenaGuWuMsg.meta = {__index = ReqCrossArenaGuWuMsg };
function ReqCrossArenaGuWuMsg:new()
	local obj = setmetatable( {}, ReqCrossArenaGuWuMsg.meta);
	return obj;
end

function ReqCrossArenaGuWuMsg:encode()
	local body = "";


	return body;
end

function ReqCrossArenaGuWuMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求擂台赛对手
]]
_G.ReqCrossArenaDuiShouMsg = {};

ReqCrossArenaDuiShouMsg.msgId = 2266;



ReqCrossArenaDuiShouMsg.meta = {__index = ReqCrossArenaDuiShouMsg };
function ReqCrossArenaDuiShouMsg:new()
	local obj = setmetatable( {}, ReqCrossArenaDuiShouMsg.meta);
	return obj;
end

function ReqCrossArenaDuiShouMsg:encode()
	local body = "";


	return body;
end

function ReqCrossArenaDuiShouMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求激活邀请码
]]
_G.ReqInvitationCodeMsg = {};

ReqInvitationCodeMsg.msgId = 2267;
ReqInvitationCodeMsg.code = ""; -- 激活码



ReqInvitationCodeMsg.meta = {__index = ReqInvitationCodeMsg };
function ReqInvitationCodeMsg:new()
	local obj = setmetatable( {}, ReqInvitationCodeMsg.meta);
	return obj;
end

function ReqInvitationCodeMsg:encode()
	local body = "";

	body = body ..writeString(self.code,128);

	return body;
end

function ReqInvitationCodeMsg:ParseData(pak)
	local idx = 1;

	self.code, idx = readString(pak, idx, 128);

end



--[[
圣诞兑换活动信息
]]
_G.ReqChristmasDonateInfoMsg = {};

ReqChristmasDonateInfoMsg.msgId = 2268;



ReqChristmasDonateInfoMsg.meta = {__index = ReqChristmasDonateInfoMsg };
function ReqChristmasDonateInfoMsg:new()
	local obj = setmetatable( {}, ReqChristmasDonateInfoMsg.meta);
	return obj;
end

function ReqChristmasDonateInfoMsg:encode()
	local body = "";


	return body;
end

function ReqChristmasDonateInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
圣诞兑换活动提交物品
]]
_G.ReqChristmasDonateMsg = {};

ReqChristmasDonateMsg.msgId = 2269;
ReqChristmasDonateMsg.id = 0; -- 物品ID
ReqChristmasDonateMsg.num = 0; -- 物品个数



ReqChristmasDonateMsg.meta = {__index = ReqChristmasDonateMsg };
function ReqChristmasDonateMsg:new()
	local obj = setmetatable( {}, ReqChristmasDonateMsg.meta);
	return obj;
end

function ReqChristmasDonateMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.num);

	return body;
end

function ReqChristmasDonateMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
圣诞兑换进度奖励
]]
_G.ReqChristmasDonateRewardMsg = {};

ReqChristmasDonateRewardMsg.msgId = 2270;
ReqChristmasDonateRewardMsg.index = 0; -- 某一阶段的奖励



ReqChristmasDonateRewardMsg.meta = {__index = ReqChristmasDonateRewardMsg };
function ReqChristmasDonateRewardMsg:new()
	local obj = setmetatable( {}, ReqChristmasDonateRewardMsg.meta);
	return obj;
end

function ReqChristmasDonateRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.index);

	return body;
end

function ReqChristmasDonateRewardMsg:ParseData(pak)
	local idx = 1;

	self.index, idx = readInt(pak, idx);

end



--[[
请求腾讯充值
]]
_G.ReqTXRechargeMsg = {};

ReqTXRechargeMsg.msgId = 2275;



ReqTXRechargeMsg.meta = {__index = ReqTXRechargeMsg };
function ReqTXRechargeMsg:new()
	local obj = setmetatable( {}, ReqTXRechargeMsg.meta);
	return obj;
end

function ReqTXRechargeMsg:encode()
	local body = "";


	return body;
end

function ReqTXRechargeMsg:ParseData(pak)
	local idx = 1;


end



--[[
主角进入场景
]]
_G.ReqSceneEnterSceneMsg = {};

ReqSceneEnterSceneMsg.msgId = 3003;
ReqSceneEnterSceneMsg.initGame = 0; -- 默认0，取值1为切换地图状态



ReqSceneEnterSceneMsg.meta = {__index = ReqSceneEnterSceneMsg };
function ReqSceneEnterSceneMsg:new()
	local obj = setmetatable( {}, ReqSceneEnterSceneMsg.meta);
	return obj;
end

function ReqSceneEnterSceneMsg:encode()
	local body = "";

	body = body ..writeInt(self.initGame);

	return body;
end

function ReqSceneEnterSceneMsg:ParseData(pak)
	local idx = 1;

	self.initGame, idx = readInt(pak, idx);

end



--[[
主角请求移动
]]
_G.ReqSceneMoveMsg = {};

ReqSceneMoveMsg.msgId = 3004;
ReqSceneMoveMsg.srcX = 0; -- 源X
ReqSceneMoveMsg.srcY = 0; -- 源Y
ReqSceneMoveMsg.dirX = 0; -- 方向X坐标
ReqSceneMoveMsg.dirY = 0; -- 方向y坐标



ReqSceneMoveMsg.meta = {__index = ReqSceneMoveMsg };
function ReqSceneMoveMsg:new()
	local obj = setmetatable( {}, ReqSceneMoveMsg.meta);
	return obj;
end

function ReqSceneMoveMsg:encode()
	local body = "";

	body = body ..writeDouble(self.srcX);
	body = body ..writeDouble(self.srcY);
	body = body ..writeDouble(self.dirX);
	body = body ..writeDouble(self.dirY);

	return body;
end

function ReqSceneMoveMsg:ParseData(pak)
	local idx = 1;

	self.srcX, idx = readDouble(pak, idx);
	self.srcY, idx = readDouble(pak, idx);
	self.dirX, idx = readDouble(pak, idx);
	self.dirY, idx = readDouble(pak, idx);

end



--[[
主角请求周围玩家
]]
_G.ReqSceneGetRoleMsg = {};

ReqSceneGetRoleMsg.msgId = 3005;
ReqSceneGetRoleMsg.roleID = ""; -- 填0为获取自己可视区域的玩家；填roleId为玩家Id



ReqSceneGetRoleMsg.meta = {__index = ReqSceneGetRoleMsg };
function ReqSceneGetRoleMsg:new()
	local obj = setmetatable( {}, ReqSceneGetRoleMsg.meta);
	return obj;
end

function ReqSceneGetRoleMsg:encode()
	local body = "";

	body = body ..writeGuid(self.roleID);

	return body;
end

function ReqSceneGetRoleMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);

end



--[[
主角请求停止移动
]]
_G.ReqSceneMoveStopMsg = {};

ReqSceneMoveStopMsg.msgId = 3006;
ReqSceneMoveStopMsg.stopX = 0; -- 
ReqSceneMoveStopMsg.stopY = 0; -- 
ReqSceneMoveStopMsg.dir = 0; -- 



ReqSceneMoveStopMsg.meta = {__index = ReqSceneMoveStopMsg };
function ReqSceneMoveStopMsg:new()
	local obj = setmetatable( {}, ReqSceneMoveStopMsg.meta);
	return obj;
end

function ReqSceneMoveStopMsg:encode()
	local body = "";

	body = body ..writeDouble(self.stopX);
	body = body ..writeDouble(self.stopY);
	body = body ..writeDouble(self.dir);

	return body;
end

function ReqSceneMoveStopMsg:ParseData(pak)
	local idx = 1;

	self.stopX, idx = readDouble(pak, idx);
	self.stopY, idx = readDouble(pak, idx);
	self.dir, idx = readDouble(pak, idx);

end



--[[

]]
_G.ReqHumanModifyAttyMsg = {};

ReqHumanModifyAttyMsg.msgId = 3011;
ReqHumanModifyAttyMsg.attrData_size = 0; --  size
ReqHumanModifyAttyMsg.attrData = {}; --  list

--[[
ClientAttrVO = {
	type = 0; -- 类型
	value = 0; -- 值
}
]]

ReqHumanModifyAttyMsg.meta = {__index = ReqHumanModifyAttyMsg };
function ReqHumanModifyAttyMsg:new()
	local obj = setmetatable( {}, ReqHumanModifyAttyMsg.meta);
	return obj;
end

function ReqHumanModifyAttyMsg:encode()
	local body = "";


	local list1 = self.attrData;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeInt(list1[i1].type);
		body = body .. writeDouble(list1[i1].value);
	end

	return body;
end

function ReqHumanModifyAttyMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.attrData = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ClientAttrVo = {};
		ClientAttrVo.type, idx = readInt(pak, idx);
		ClientAttrVo.value, idx = readDouble(pak, idx);
		table.push(list1,ClientAttrVo);
	end

end



--[[
客户端请求: 获取物品列表
]]
_G.ReqQueryItemMsg = {};

ReqQueryItemMsg.msgId = 3019;
ReqQueryItemMsg.id = ""; -- 
ReqQueryItemMsg.item_bag = 0; -- 背包



ReqQueryItemMsg.meta = {__index = ReqQueryItemMsg };
function ReqQueryItemMsg:new()
	local obj = setmetatable( {}, ReqQueryItemMsg.meta);
	return obj;
end

function ReqQueryItemMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);
	body = body ..writeInt(self.item_bag);

	return body;
end

function ReqQueryItemMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.item_bag, idx = readInt(pak, idx);

end



--[[
客户端请求: 丢弃一件物品
]]
_G.ReqDiscardItemMsg = {};

ReqDiscardItemMsg.msgId = 3020;
ReqDiscardItemMsg.item_bag = 0; -- 背包
ReqDiscardItemMsg.item_idx = 0; -- 格子索引



ReqDiscardItemMsg.meta = {__index = ReqDiscardItemMsg };
function ReqDiscardItemMsg:new()
	local obj = setmetatable( {}, ReqDiscardItemMsg.meta);
	return obj;
end

function ReqDiscardItemMsg:encode()
	local body = "";

	body = body ..writeInt(self.item_bag);
	body = body ..writeInt(self.item_idx);

	return body;
end

function ReqDiscardItemMsg:ParseData(pak)
	local idx = 1;

	self.item_bag, idx = readInt(pak, idx);
	self.item_idx, idx = readInt(pak, idx);

end



--[[
客户端请求: 交换两个物品
]]
_G.ReqSwapItemMsg = {};

ReqSwapItemMsg.msgId = 3021;
ReqSwapItemMsg.src_bag = 0; -- 源背包
ReqSwapItemMsg.dst_bag = 0; -- 目标背包
ReqSwapItemMsg.src_idx = 0; -- 源格子
ReqSwapItemMsg.dst_idx = 0; -- 目标格子



ReqSwapItemMsg.meta = {__index = ReqSwapItemMsg };
function ReqSwapItemMsg:new()
	local obj = setmetatable( {}, ReqSwapItemMsg.meta);
	return obj;
end

function ReqSwapItemMsg:encode()
	local body = "";

	body = body ..writeInt(self.src_bag);
	body = body ..writeInt(self.dst_bag);
	body = body ..writeInt(self.src_idx);
	body = body ..writeInt(self.dst_idx);

	return body;
end

function ReqSwapItemMsg:ParseData(pak)
	local idx = 1;

	self.src_bag, idx = readInt(pak, idx);
	self.dst_bag, idx = readInt(pak, idx);
	self.src_idx, idx = readInt(pak, idx);
	self.dst_idx, idx = readInt(pak, idx);

end



--[[
客户端请求: 使用一个物品
]]
_G.ReqUseItemMsg = {};

ReqUseItemMsg.msgId = 3022;
ReqUseItemMsg.item_bag = 0; -- 背包
ReqUseItemMsg.item_idx = 0; -- 格子索引
ReqUseItemMsg.item_count = 0; -- 使用数量



ReqUseItemMsg.meta = {__index = ReqUseItemMsg };
function ReqUseItemMsg:new()
	local obj = setmetatable( {}, ReqUseItemMsg.meta);
	return obj;
end

function ReqUseItemMsg:encode()
	local body = "";

	body = body ..writeInt(self.item_bag);
	body = body ..writeInt(self.item_idx);
	body = body ..writeInt(self.item_count);

	return body;
end

function ReqUseItemMsg:ParseData(pak)
	local idx = 1;

	self.item_bag, idx = readInt(pak, idx);
	self.item_idx, idx = readInt(pak, idx);
	self.item_count, idx = readInt(pak, idx);

end



--[[
客户端请求: 出售背包物品
]]
_G.ReqSellItemMsg = {};

ReqSellItemMsg.msgId = 3023;
ReqSellItemMsg.item_bag = 0; -- 背包
ReqSellItemMsg.item_idx = 0; -- 格子索引



ReqSellItemMsg.meta = {__index = ReqSellItemMsg };
function ReqSellItemMsg:new()
	local obj = setmetatable( {}, ReqSellItemMsg.meta);
	return obj;
end

function ReqSellItemMsg:encode()
	local body = "";

	body = body ..writeInt(self.item_bag);
	body = body ..writeInt(self.item_idx);

	return body;
end

function ReqSellItemMsg:ParseData(pak)
	local idx = 1;

	self.item_bag, idx = readInt(pak, idx);
	self.item_idx, idx = readInt(pak, idx);

end



--[[
客户端请求: 整理背包物品
]]
_G.ReqPackItemMsg = {};

ReqPackItemMsg.msgId = 3024;
ReqPackItemMsg.item_bag = 0; -- 背包



ReqPackItemMsg.meta = {__index = ReqPackItemMsg };
function ReqPackItemMsg:new()
	local obj = setmetatable( {}, ReqPackItemMsg.meta);
	return obj;
end

function ReqPackItemMsg:encode()
	local body = "";

	body = body ..writeInt(self.item_bag);

	return body;
end

function ReqPackItemMsg:ParseData(pak)
	local idx = 1;

	self.item_bag, idx = readInt(pak, idx);

end



--[[
客户端请求: 背包容量扩充
]]
_G.ReqExpandBagMsg = {};

ReqExpandBagMsg.msgId = 3025;
ReqExpandBagMsg.item_bag = 0; -- 背包
ReqExpandBagMsg.inc_size = 0; -- 扩充格子数
ReqExpandBagMsg.moneyType = 0; -- 物品不足时使用的元宝类型,1元宝,2绑定元宝



ReqExpandBagMsg.meta = {__index = ReqExpandBagMsg };
function ReqExpandBagMsg:new()
	local obj = setmetatable( {}, ReqExpandBagMsg.meta);
	return obj;
end

function ReqExpandBagMsg:encode()
	local body = "";

	body = body ..writeInt(self.item_bag);
	body = body ..writeInt(self.inc_size);
	body = body ..writeInt(self.moneyType);

	return body;
end

function ReqExpandBagMsg:ParseData(pak)
	local idx = 1;

	self.item_bag, idx = readInt(pak, idx);
	self.inc_size, idx = readInt(pak, idx);
	self.moneyType, idx = readInt(pak, idx);

end



--[[
客户端请求: 拆分一个物品
]]
_G.ReqSplitItemMsg = {};

ReqSplitItemMsg.msgId = 3026;
ReqSplitItemMsg.item_bag = 0; -- 背包
ReqSplitItemMsg.item_idx = 0; -- 格子索引
ReqSplitItemMsg.split_count = 0; -- 拆分数量



ReqSplitItemMsg.meta = {__index = ReqSplitItemMsg };
function ReqSplitItemMsg:new()
	local obj = setmetatable( {}, ReqSplitItemMsg.meta);
	return obj;
end

function ReqSplitItemMsg:encode()
	local body = "";

	body = body ..writeInt(self.item_bag);
	body = body ..writeInt(self.item_idx);
	body = body ..writeInt(self.split_count);

	return body;
end

function ReqSplitItemMsg:ParseData(pak)
	local idx = 1;

	self.item_bag, idx = readInt(pak, idx);
	self.item_idx, idx = readInt(pak, idx);
	self.split_count, idx = readInt(pak, idx);

end



--[[
请求技能列表
]]
_G.ReqSkillListMsg = {};

ReqSkillListMsg.msgId = 3028;



ReqSkillListMsg.meta = {__index = ReqSkillListMsg };
function ReqSkillListMsg:new()
	local obj = setmetatable( {}, ReqSkillListMsg.meta);
	return obj;
end

function ReqSkillListMsg:encode()
	local body = "";


	return body;
end

function ReqSkillListMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求学习技能
]]
_G.ReqSkillLearnMsg = {};

ReqSkillLearnMsg.msgId = 3029;
ReqSkillLearnMsg.skillId = 0; -- 技能id



ReqSkillLearnMsg.meta = {__index = ReqSkillLearnMsg };
function ReqSkillLearnMsg:new()
	local obj = setmetatable( {}, ReqSkillLearnMsg.meta);
	return obj;
end

function ReqSkillLearnMsg:encode()
	local body = "";

	body = body ..writeInt(self.skillId);

	return body;
end

function ReqSkillLearnMsg:ParseData(pak)
	local idx = 1;

	self.skillId, idx = readInt(pak, idx);

end



--[[
请求升级技能
]]
_G.ReqSkillLvlUpMsg = {};

ReqSkillLvlUpMsg.msgId = 3030;
ReqSkillLvlUpMsg.skillId = 0; -- 技能id



ReqSkillLvlUpMsg.meta = {__index = ReqSkillLvlUpMsg };
function ReqSkillLvlUpMsg:new()
	local obj = setmetatable( {}, ReqSkillLvlUpMsg.meta);
	return obj;
end

function ReqSkillLvlUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.skillId);

	return body;
end

function ReqSkillLvlUpMsg:ParseData(pak)
	local idx = 1;

	self.skillId, idx = readInt(pak, idx);

end



--[[
客户端主动去请求obj列表
]]
_G.ReqMapObjListMsg = {};

ReqMapObjListMsg.msgId = 3035;
ReqMapObjListMsg.objType = 0; -- 分类标示 传送门或者NPC



ReqMapObjListMsg.meta = {__index = ReqMapObjListMsg };
function ReqMapObjListMsg:new()
	local obj = setmetatable( {}, ReqMapObjListMsg.meta);
	return obj;
end

function ReqMapObjListMsg:encode()
	local body = "";

	body = body ..writeInt(self.objType);

	return body;
end

function ReqMapObjListMsg:ParseData(pak)
	local idx = 1;

	self.objType, idx = readInt(pak, idx);

end



--[[
客户端主动去请求转向
]]
_G.ReqChangeDir = {};

ReqChangeDir.msgId = 3036;
ReqChangeDir.dir = 0; -- 朝向



ReqChangeDir.meta = {__index = ReqChangeDir };
function ReqChangeDir:new()
	local obj = setmetatable( {}, ReqChangeDir.meta);
	return obj;
end

function ReqChangeDir:encode()
	local body = "";

	body = body ..writeDouble(self.dir);

	return body;
end

function ReqChangeDir:ParseData(pak)
	local idx = 1;

	self.dir, idx = readDouble(pak, idx);

end



--[[
客户端请求: 主角施放技能
]]
_G.ReqCastMagicMsg = {};

ReqCastMagicMsg.msgId = 3050;
ReqCastMagicMsg.skillID = 0; -- 技能ID
ReqCastMagicMsg.targetID = ""; -- 如果锁定目标，目标ID
ReqCastMagicMsg.posX = 0; -- 如果位置施法，位置坐标x
ReqCastMagicMsg.posY = 0; -- 如果位置施法，位置坐标y



ReqCastMagicMsg.meta = {__index = ReqCastMagicMsg };
function ReqCastMagicMsg:new()
	local obj = setmetatable( {}, ReqCastMagicMsg.meta);
	return obj;
end

function ReqCastMagicMsg:encode()
	local body = "";

	body = body ..writeInt(self.skillID);
	body = body ..writeGuid(self.targetID);
	body = body ..writeDouble(self.posX);
	body = body ..writeDouble(self.posY);

	return body;
end

function ReqCastMagicMsg:ParseData(pak)
	local idx = 1;

	self.skillID, idx = readInt(pak, idx);
	self.targetID, idx = readGuid(pak, idx);
	self.posX, idx = readDouble(pak, idx);
	self.posY, idx = readDouble(pak, idx);

end



--[[
客户端请求: 主角打断施法
]]
_G.ReqInterruptCastMsg = {};

ReqInterruptCastMsg.msgId = 3056;
ReqInterruptCastMsg.skillID = 0; -- 技能ID



ReqInterruptCastMsg.meta = {__index = ReqInterruptCastMsg };
function ReqInterruptCastMsg:new()
	local obj = setmetatable( {}, ReqInterruptCastMsg.meta);
	return obj;
end

function ReqInterruptCastMsg:encode()
	local body = "";

	body = body ..writeInt(self.skillID);

	return body;
end

function ReqInterruptCastMsg:ParseData(pak)
	local idx = 1;

	self.skillID, idx = readInt(pak, idx);

end



--[[
客户端请求:任务列表
]]
_G.ReqQueryQuestMsg = {};

ReqQueryQuestMsg.msgId = 3059;



ReqQueryQuestMsg.meta = {__index = ReqQueryQuestMsg };
function ReqQueryQuestMsg:new()
	local obj = setmetatable( {}, ReqQueryQuestMsg.meta);
	return obj;
end

function ReqQueryQuestMsg:encode()
	local body = "";


	return body;
end

function ReqQueryQuestMsg:ParseData(pak)
	local idx = 1;


end



--[[
点击计数(如功能指引任务)
]]
_G.ReqQuestClickMsg = {};

ReqQuestClickMsg.msgId = 3061;
ReqQuestClickMsg.id = 0; -- 任务id



ReqQuestClickMsg.meta = {__index = ReqQuestClickMsg };
function ReqQuestClickMsg:new()
	local obj = setmetatable( {}, ReqQuestClickMsg.meta);
	return obj;
end

function ReqQuestClickMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqQuestClickMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
客户端请求:接受任务(接取任务成功推Update)
]]
_G.ReqAcceptQuestMsg = {};

ReqAcceptQuestMsg.msgId = 3062;
ReqAcceptQuestMsg.id = 0; -- 任务id



ReqAcceptQuestMsg.meta = {__index = ReqAcceptQuestMsg };
function ReqAcceptQuestMsg:new()
	local obj = setmetatable( {}, ReqAcceptQuestMsg.meta);
	return obj;
end

function ReqAcceptQuestMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqAcceptQuestMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
客户端请求:放弃任务
]]
_G.ReqGiveupQuestMsg = {};

ReqGiveupQuestMsg.msgId = 3063;
ReqGiveupQuestMsg.id = 0; -- 任务id



ReqGiveupQuestMsg.meta = {__index = ReqGiveupQuestMsg };
function ReqGiveupQuestMsg:new()
	local obj = setmetatable( {}, ReqGiveupQuestMsg.meta);
	return obj;
end

function ReqGiveupQuestMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqGiveupQuestMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
客户端请求:完成任务
]]
_G.ReqFinishQuestMsg = {};

ReqFinishQuestMsg.msgId = 3064;
ReqFinishQuestMsg.id = 0; -- 任务id
ReqFinishQuestMsg.multiple = 0; -- 1：免费领一倍，2：银两领双倍，：3元宝领三倍



ReqFinishQuestMsg.meta = {__index = ReqFinishQuestMsg };
function ReqFinishQuestMsg:new()
	local obj = setmetatable( {}, ReqFinishQuestMsg.meta);
	return obj;
end

function ReqFinishQuestMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.multiple);

	return body;
end

function ReqFinishQuestMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.multiple, idx = readInt(pak, idx);

end



--[[
客户端请求: 触发静物
]]
_G.ReqTriggerObjMsg = {};

ReqTriggerObjMsg.msgId = 3070;
ReqTriggerObjMsg.cID = ""; -- 静物ID
ReqTriggerObjMsg.jiguan = 0; -- 机关ID



ReqTriggerObjMsg.meta = {__index = ReqTriggerObjMsg };
function ReqTriggerObjMsg:new()
	local obj = setmetatable( {}, ReqTriggerObjMsg.meta);
	return obj;
end

function ReqTriggerObjMsg:encode()
	local body = "";

	body = body ..writeGuid(self.cID);
	body = body ..writeInt(self.jiguan);

	return body;
end

function ReqTriggerObjMsg:ParseData(pak)
	local idx = 1;

	self.cID, idx = readGuid(pak, idx);
	self.jiguan, idx = readInt(pak, idx);

end



--[[
客户端请求: 选择那个传送地图
]]
_G.ReqTriggerSelectMapMsg = {};

ReqTriggerSelectMapMsg.msgId = 3072;
ReqTriggerSelectMapMsg.cID = ""; -- 静物ID
ReqTriggerSelectMapMsg.mapID = 0; -- 配置表中ID



ReqTriggerSelectMapMsg.meta = {__index = ReqTriggerSelectMapMsg };
function ReqTriggerSelectMapMsg:new()
	local obj = setmetatable( {}, ReqTriggerSelectMapMsg.meta);
	return obj;
end

function ReqTriggerSelectMapMsg:encode()
	local body = "";

	body = body ..writeGuid(self.cID);
	body = body ..writeInt(self.mapID);

	return body;
end

function ReqTriggerSelectMapMsg:ParseData(pak)
	local idx = 1;

	self.cID, idx = readGuid(pak, idx);
	self.mapID, idx = readInt(pak, idx);

end



--[[
拾取
]]
_G.ReqPickUpItemMsg = {};

ReqPickUpItemMsg.msgId = 3076;
ReqPickUpItemMsg.data_size = 0; --  size
ReqPickUpItemMsg.data = {}; --  list

--[[
item_idVO = {
	id = ""; -- 
}
]]

ReqPickUpItemMsg.meta = {__index = ReqPickUpItemMsg };
function ReqPickUpItemMsg:new()
	local obj = setmetatable( {}, ReqPickUpItemMsg.meta);
	return obj;
end

function ReqPickUpItemMsg:encode()
	local body = "";


	local list1 = self.data;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeGuid(list1[i1].id);
	end

	return body;
end

function ReqPickUpItemMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.data = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local item_idVo = {};
		item_idVo.id, idx = readGuid(pak, idx);
		table.push(list1,item_idVo);
	end

end



--[[
请求复活
]]
_G.ReqReviveMsg = {};

ReqReviveMsg.msgId = 3077;
ReqReviveMsg.reviveType = 0; -- 复活类型
ReqReviveMsg.moneyType = 0; -- 物品不足时使用的元宝类型,1元宝,2绑定元宝



ReqReviveMsg.meta = {__index = ReqReviveMsg };
function ReqReviveMsg:new()
	local obj = setmetatable( {}, ReqReviveMsg.meta);
	return obj;
end

function ReqReviveMsg:encode()
	local body = "";

	body = body ..writeInt(self.reviveType);
	body = body ..writeInt(self.moneyType);

	return body;
end

function ReqReviveMsg:ParseData(pak)
	local idx = 1;

	self.reviveType, idx = readInt(pak, idx);
	self.moneyType, idx = readInt(pak, idx);

end



--[[
请求手动升级
]]
_G.ReqLevelUpMsg = {};

ReqLevelUpMsg.msgId = 3088;



ReqLevelUpMsg.meta = {__index = ReqLevelUpMsg };
function ReqLevelUpMsg:new()
	local obj = setmetatable( {}, ReqLevelUpMsg.meta);
	return obj;
end

function ReqLevelUpMsg:encode()
	local body = "";


	return body;
end

function ReqLevelUpMsg:ParseData(pak)
	local idx = 1;


end



--[[
喂养武魂
]]
_G.ReqFeedWuHunMsg = {};

ReqFeedWuHunMsg.msgId = 3092;
ReqFeedWuHunMsg.wuhunId = 0; -- 武魂id
ReqFeedWuHunMsg.feedNum = 0; -- 武魂喂养次数



ReqFeedWuHunMsg.meta = {__index = ReqFeedWuHunMsg };
function ReqFeedWuHunMsg:new()
	local obj = setmetatable( {}, ReqFeedWuHunMsg.meta);
	return obj;
end

function ReqFeedWuHunMsg:encode()
	local body = "";

	body = body ..writeInt(self.wuhunId);
	body = body ..writeInt(self.feedNum);

	return body;
end

function ReqFeedWuHunMsg:ParseData(pak)
	local idx = 1;

	self.wuhunId, idx = readInt(pak, idx);
	self.feedNum, idx = readInt(pak, idx);

end



--[[
武魂进阶
]]
_G.ReqProceWuHunMsg = {};

ReqProceWuHunMsg.msgId = 3093;
ReqProceWuHunMsg.wuhunId = 0; -- 武魂id
ReqProceWuHunMsg.autobuy = 0; -- 是否自动购买,0自动购买



ReqProceWuHunMsg.meta = {__index = ReqProceWuHunMsg };
function ReqProceWuHunMsg:new()
	local obj = setmetatable( {}, ReqProceWuHunMsg.meta);
	return obj;
end

function ReqProceWuHunMsg:encode()
	local body = "";

	body = body ..writeInt(self.wuhunId);
	body = body ..writeInt(self.autobuy);

	return body;
end

function ReqProceWuHunMsg:ParseData(pak)
	local idx = 1;

	self.wuhunId, idx = readInt(pak, idx);
	self.autobuy, idx = readInt(pak, idx);

end



--[[
武魂附身
]]
_G.ReqAdjunctionWuHunMsg = {};

ReqAdjunctionWuHunMsg.msgId = 3094;
ReqAdjunctionWuHunMsg.wuhunId = 0; -- 武魂id
ReqAdjunctionWuHunMsg.wuhunFlag = 0; -- 武魂附加标识，1表示附加，0表示卸下



ReqAdjunctionWuHunMsg.meta = {__index = ReqAdjunctionWuHunMsg };
function ReqAdjunctionWuHunMsg:new()
	local obj = setmetatable( {}, ReqAdjunctionWuHunMsg.meta);
	return obj;
end

function ReqAdjunctionWuHunMsg:encode()
	local body = "";

	body = body ..writeInt(self.wuhunId);
	body = body ..writeInt(self.wuhunFlag);

	return body;
end

function ReqAdjunctionWuHunMsg:ParseData(pak)
	local idx = 1;

	self.wuhunId, idx = readInt(pak, idx);
	self.wuhunFlag, idx = readInt(pak, idx);

end



--[[
发送喇叭
]]
_G.ReqHornMsg = {};

ReqHornMsg.msgId = 3095;
ReqHornMsg.hornId = 0; -- 喇叭id
ReqHornMsg.item_bag = 0; -- 背包
ReqHornMsg.item_idx = 0; -- 格子索引
ReqHornMsg.autoMoney = 0; -- 喇叭不足时,自动使用元宝,0否1是
ReqHornMsg.text = ""; -- 内容



ReqHornMsg.meta = {__index = ReqHornMsg };
function ReqHornMsg:new()
	local obj = setmetatable( {}, ReqHornMsg.meta);
	return obj;
end

function ReqHornMsg:encode()
	local body = "";

	body = body ..writeInt(self.hornId);
	body = body ..writeInt(self.item_bag);
	body = body ..writeInt(self.item_idx);
	body = body ..writeInt(self.autoMoney);
	body = body ..writeString(self.text);

	return body;
end

function ReqHornMsg:ParseData(pak)
	local idx = 1;

	self.hornId, idx = readInt(pak, idx);
	self.item_bag, idx = readInt(pak, idx);
	self.item_idx, idx = readInt(pak, idx);
	self.autoMoney, idx = readInt(pak, idx);
	self.text, idx = readString(pak, idx);

end



--[[
请求技能栏设置
]]
_G.ReqSkillShortCutMsg = {};

ReqSkillShortCutMsg.msgId = 3097;
ReqSkillShortCutMsg.skillId = 0; -- 技能id
ReqSkillShortCutMsg.pos = 0; -- 格子



ReqSkillShortCutMsg.meta = {__index = ReqSkillShortCutMsg };
function ReqSkillShortCutMsg:new()
	local obj = setmetatable( {}, ReqSkillShortCutMsg.meta);
	return obj;
end

function ReqSkillShortCutMsg:encode()
	local body = "";

	body = body ..writeInt(self.skillId);
	body = body ..writeInt(self.pos);

	return body;
end

function ReqSkillShortCutMsg:ParseData(pak)
	local idx = 1;

	self.skillId, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);

end



--[[
请求剧情副本Npc对话结束
]]
_G.ReqDungeonNpcTalkEndMsg = {};

ReqDungeonNpcTalkEndMsg.msgId = 3101;
ReqDungeonNpcTalkEndMsg.step = 0; -- 剧情副本stepid,1=任务



ReqDungeonNpcTalkEndMsg.meta = {__index = ReqDungeonNpcTalkEndMsg };
function ReqDungeonNpcTalkEndMsg:new()
	local obj = setmetatable( {}, ReqDungeonNpcTalkEndMsg.meta);
	return obj;
end

function ReqDungeonNpcTalkEndMsg:encode()
	local body = "";

	body = body ..writeInt(self.step);

	return body;
end

function ReqDungeonNpcTalkEndMsg:ParseData(pak)
	local idx = 1;

	self.step, idx = readInt(pak, idx);

end



--[[
请求进入剧情副本
]]
_G.ReqEnterDungeonMsg = {};

ReqEnterDungeonMsg.msgId = 3102;
ReqEnterDungeonMsg.flag = 0; -- 1：从新开始，2：延续上一次中途退出的副本
ReqEnterDungeonMsg.dungeonId = 0; -- 副本id



ReqEnterDungeonMsg.meta = {__index = ReqEnterDungeonMsg };
function ReqEnterDungeonMsg:new()
	local obj = setmetatable( {}, ReqEnterDungeonMsg.meta);
	return obj;
end

function ReqEnterDungeonMsg:encode()
	local body = "";

	body = body ..writeInt(self.flag);
	body = body ..writeInt(self.dungeonId);

	return body;
end

function ReqEnterDungeonMsg:ParseData(pak)
	local idx = 1;

	self.flag, idx = readInt(pak, idx);
	self.dungeonId, idx = readInt(pak, idx);

end



--[[
请求退出剧情副本
]]
_G.ReqCS_LeaveDungeon = {};

ReqCS_LeaveDungeon.msgId = 3103;
ReqCS_LeaveDungeon.dungeonId = 0; -- 副本id



ReqCS_LeaveDungeon.meta = {__index = ReqCS_LeaveDungeon };
function ReqCS_LeaveDungeon:new()
	local obj = setmetatable( {}, ReqCS_LeaveDungeon.meta);
	return obj;
end

function ReqCS_LeaveDungeon:encode()
	local body = "";

	body = body ..writeInt(self.dungeonId);

	return body;
end

function ReqCS_LeaveDungeon:ParseData(pak)
	local idx = 1;

	self.dungeonId, idx = readInt(pak, idx);

end



--[[
剧情播放完成
]]
_G.ReqStoryEndMsg = {};

ReqStoryEndMsg.msgId = 3104;
ReqStoryEndMsg.type = 0; -- 1：对话框，2：任务，其它是剧情
ReqStoryEndMsg.id = 0; -- 剧情步骤id或任务id



ReqStoryEndMsg.meta = {__index = ReqStoryEndMsg };
function ReqStoryEndMsg:new()
	local obj = setmetatable( {}, ReqStoryEndMsg.meta);
	return obj;
end

function ReqStoryEndMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);
	body = body ..writeInt(self.id);

	return body;
end

function ReqStoryEndMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
请求交易
]]
_G.ReqExchangeMsg = {};

ReqExchangeMsg.msgId = 3106;
ReqExchangeMsg.roleID = ""; -- 玩家id



ReqExchangeMsg.meta = {__index = ReqExchangeMsg };
function ReqExchangeMsg:new()
	local obj = setmetatable( {}, ReqExchangeMsg.meta);
	return obj;
end

function ReqExchangeMsg:encode()
	local body = "";

	body = body ..writeGuid(self.roleID);

	return body;
end

function ReqExchangeMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);

end



--[[
被邀请交易返回结果
]]
_G.ReqExchangeInviteRtMsg = {};

ReqExchangeInviteRtMsg.msgId = 3107;
ReqExchangeInviteRtMsg.resultCode = 0; -- 结果 0:同意 -1:拒绝
ReqExchangeInviteRtMsg.roleID = ""; -- 玩家id



ReqExchangeInviteRtMsg.meta = {__index = ReqExchangeInviteRtMsg };
function ReqExchangeInviteRtMsg:new()
	local obj = setmetatable( {}, ReqExchangeInviteRtMsg.meta);
	return obj;
end

function ReqExchangeInviteRtMsg:encode()
	local body = "";

	body = body ..writeInt(self.resultCode);
	body = body ..writeGuid(self.roleID);

	return body;
end

function ReqExchangeInviteRtMsg:ParseData(pak)
	local idx = 1;

	self.resultCode, idx = readInt(pak, idx);
	self.roleID, idx = readGuid(pak, idx);

end



--[[
交易放置物品
]]
_G.ReqExchangeMoveItemMsg = {};

ReqExchangeMoveItemMsg.msgId = 3108;
ReqExchangeMoveItemMsg.bagPos = 0; -- 背包内位置
ReqExchangeMoveItemMsg.containerID = 0; -- 交易栏位置
ReqExchangeMoveItemMsg.gold = 0; -- 金币



ReqExchangeMoveItemMsg.meta = {__index = ReqExchangeMoveItemMsg };
function ReqExchangeMoveItemMsg:new()
	local obj = setmetatable( {}, ReqExchangeMoveItemMsg.meta);
	return obj;
end

function ReqExchangeMoveItemMsg:encode()
	local body = "";

	body = body ..writeInt(self.bagPos);
	body = body ..writeInt(self.containerID);
	body = body ..writeInt64(self.gold);

	return body;
end

function ReqExchangeMoveItemMsg:ParseData(pak)
	local idx = 1;

	self.bagPos, idx = readInt(pak, idx);
	self.containerID, idx = readInt(pak, idx);
	self.gold, idx = readInt64(pak, idx);

end



--[[
交易操作
]]
_G.ReqExchangeHandleMsg = {};

ReqExchangeHandleMsg.msgId = 3109;
ReqExchangeHandleMsg.type = 0; -- 锁定操作 1:锁定 -1:取消锁定 2:确认交易 -2:取消交易



ReqExchangeHandleMsg.meta = {__index = ReqExchangeHandleMsg };
function ReqExchangeHandleMsg:new()
	local obj = setmetatable( {}, ReqExchangeHandleMsg.meta);
	return obj;
end

function ReqExchangeHandleMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqExchangeHandleMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
请求珍宝阁数据
]]
_G.ReqZhenBaoGeMsg = {};

ReqZhenBaoGeMsg.msgId = 3113;



ReqZhenBaoGeMsg.meta = {__index = ReqZhenBaoGeMsg };
function ReqZhenBaoGeMsg:new()
	local obj = setmetatable( {}, ReqZhenBaoGeMsg.meta);
	return obj;
end

function ReqZhenBaoGeMsg:encode()
	local body = "";


	return body;
end

function ReqZhenBaoGeMsg:ParseData(pak)
	local idx = 1;


end



--[[
珍宝阁提交道具
]]
_G.ReqZhenBaoGeSubmitMsg = {};

ReqZhenBaoGeSubmitMsg.msgId = 3114;
ReqZhenBaoGeSubmitMsg.id = 0; -- 珍宝阁id



ReqZhenBaoGeSubmitMsg.meta = {__index = ReqZhenBaoGeSubmitMsg };
function ReqZhenBaoGeSubmitMsg:new()
	local obj = setmetatable( {}, ReqZhenBaoGeSubmitMsg.meta);
	return obj;
end

function ReqZhenBaoGeSubmitMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqZhenBaoGeSubmitMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
珍宝阁提交特殊道具
]]
_G.ReqZhenBaoGeSpeItemMsg = {};

ReqZhenBaoGeSpeItemMsg.msgId = 3115;
ReqZhenBaoGeSpeItemMsg.id = 0; -- 珍宝阁id
ReqZhenBaoGeSpeItemMsg.itemId = 0; -- 特殊道具id



ReqZhenBaoGeSpeItemMsg.meta = {__index = ReqZhenBaoGeSpeItemMsg };
function ReqZhenBaoGeSpeItemMsg:new()
	local obj = setmetatable( {}, ReqZhenBaoGeSpeItemMsg.meta);
	return obj;
end

function ReqZhenBaoGeSpeItemMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.itemId);

	return body;
end

function ReqZhenBaoGeSpeItemMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.itemId, idx = readInt(pak, idx);

end



--[[
商店购物
]]
_G.ReqShoppingMsg = {};

ReqShoppingMsg.msgId = 3116;
ReqShoppingMsg.id = 0; -- 商品id
ReqShoppingMsg.num = 0; -- 购买数量



ReqShoppingMsg.meta = {__index = ReqShoppingMsg };
function ReqShoppingMsg:new()
	local obj = setmetatable( {}, ReqShoppingMsg.meta);
	return obj;
end

function ReqShoppingMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.num);

	return body;
end

function ReqShoppingMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
坐骑进阶
]]
_G.ReqRideLvlUpMsg = {};

ReqRideLvlUpMsg.msgId = 3118;
ReqRideLvlUpMsg.type = 0; -- 0 进阶石，1 灵力
ReqRideLvlUpMsg.autoBuy = 0; -- 0 自动购买道具,1 不自动购买



ReqRideLvlUpMsg.meta = {__index = ReqRideLvlUpMsg };
function ReqRideLvlUpMsg:new()
	local obj = setmetatable( {}, ReqRideLvlUpMsg.meta);
	return obj;
end

function ReqRideLvlUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);
	body = body ..writeInt(self.autoBuy);

	return body;
end

function ReqRideLvlUpMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.autoBuy, idx = readInt(pak, idx);

end



--[[
使用属性丹
]]
_G.ReqUseAttrDanMsg = {};

ReqUseAttrDanMsg.msgId = 3120;
ReqUseAttrDanMsg.type = 0; -- 1、坐骑，2、灵兽，3、神兵、4、灵阵，5、骑战，6、神灵，7、元灵，8、灵兽坐骑百分比属性丹，9、战弩，10 = 五行灵脉



ReqUseAttrDanMsg.meta = {__index = ReqUseAttrDanMsg };
function ReqUseAttrDanMsg:new()
	local obj = setmetatable( {}, ReqUseAttrDanMsg.meta);
	return obj;
end

function ReqUseAttrDanMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqUseAttrDanMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
更改坐骑
]]
_G.ReqChangeRideIdMsg = {};

ReqChangeRideIdMsg.msgId = 3121;
ReqChangeRideIdMsg.rideId = 0; -- 坐骑id



ReqChangeRideIdMsg.meta = {__index = ReqChangeRideIdMsg };
function ReqChangeRideIdMsg:new()
	local obj = setmetatable( {}, ReqChangeRideIdMsg.meta);
	return obj;
end

function ReqChangeRideIdMsg:encode()
	local body = "";

	body = body ..writeInt(self.rideId);

	return body;
end

function ReqChangeRideIdMsg:ParseData(pak)
	local idx = 1;

	self.rideId, idx = readInt(pak, idx);

end



--[[
更改骑乘状态
]]
_G.ReqChangeRideStateMsg = {};

ReqChangeRideStateMsg.msgId = 3122;
ReqChangeRideStateMsg.rideState = 0; -- 骑乘状态,0下马,1上马



ReqChangeRideStateMsg.meta = {__index = ReqChangeRideStateMsg };
function ReqChangeRideStateMsg:new()
	local obj = setmetatable( {}, ReqChangeRideStateMsg.meta);
	return obj;
end

function ReqChangeRideStateMsg:encode()
	local body = "";

	body = body ..writeInt(self.rideState);

	return body;
end

function ReqChangeRideStateMsg:ParseData(pak)
	local idx = 1;

	self.rideState, idx = readInt(pak, idx);

end



--[[
回购
]]
_G.ReqBuyBackMsg = {};

ReqBuyBackMsg.msgId = 3125;
ReqBuyBackMsg.cid = ""; -- 回购物品cid



ReqBuyBackMsg.meta = {__index = ReqBuyBackMsg };
function ReqBuyBackMsg:new()
	local obj = setmetatable( {}, ReqBuyBackMsg.meta);
	return obj;
end

function ReqBuyBackMsg:encode()
	local body = "";

	body = body ..writeGuid(self.cid);

	return body;
end

function ReqBuyBackMsg:ParseData(pak)
	local idx = 1;

	self.cid, idx = readGuid(pak, idx);

end



--[[
召唤噬魂怪物
]]
_G.ReqShiHunSummonMsg = {};

ReqShiHunSummonMsg.msgId = 3130;
ReqShiHunSummonMsg.monsterId = 0; -- 噬魂怪物id



ReqShiHunSummonMsg.meta = {__index = ReqShiHunSummonMsg };
function ReqShiHunSummonMsg:new()
	local obj = setmetatable( {}, ReqShiHunSummonMsg.meta);
	return obj;
end

function ReqShiHunSummonMsg:encode()
	local body = "";

	body = body ..writeInt(self.monsterId);

	return body;
end

function ReqShiHunSummonMsg:ParseData(pak)
	local idx = 1;

	self.monsterId, idx = readInt(pak, idx);

end



--[[
请求更新打坐状态
]]
_G.ReqSitStatusChangeMsg = {};

ReqSitStatusChangeMsg.msgId = 3133;
ReqSitStatusChangeMsg.oper = 0; -- 0:取消打坐 1:进入打坐
ReqSitStatusChangeMsg.id = 0; -- 要加入的打坐阵id, 0表示自己一个人进入打坐, 仅oper为1时有效
ReqSitStatusChangeMsg.index = 0; -- 序号, 加入已有打坐阵时有效



ReqSitStatusChangeMsg.meta = {__index = ReqSitStatusChangeMsg };
function ReqSitStatusChangeMsg:new()
	local obj = setmetatable( {}, ReqSitStatusChangeMsg.meta);
	return obj;
end

function ReqSitStatusChangeMsg:encode()
	local body = "";

	body = body ..writeInt(self.oper);
	body = body ..writeInt(self.id);
	body = body ..writeInt(self.index);

	return body;
end

function ReqSitStatusChangeMsg:ParseData(pak)
	local idx = 1;

	self.oper, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);
	self.index, idx = readInt(pak, idx);

end



--[[
请求附近可加入的打坐(人数4的不传)
]]
_G.ReqNearbySitMsg = {};

ReqNearbySitMsg.msgId = 3134;



ReqNearbySitMsg.meta = {__index = ReqNearbySitMsg };
function ReqNearbySitMsg:new()
	local obj = setmetatable( {}, ReqNearbySitMsg.meta);
	return obj;
end

function ReqNearbySitMsg:encode()
	local body = "";


	return body;
end

function ReqNearbySitMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求副本组列表
]]
_G.ReqDungeonGroupMsg = {};

ReqDungeonGroupMsg.msgId = 3137;



ReqDungeonGroupMsg.meta = {__index = ReqDungeonGroupMsg };
function ReqDungeonGroupMsg:new()
	local obj = setmetatable( {}, ReqDungeonGroupMsg.meta);
	return obj;
end

function ReqDungeonGroupMsg:encode()
	local body = "";


	return body;
end

function ReqDungeonGroupMsg:ParseData(pak)
	local idx = 1;


end



--[[
放弃副本(副本进行中退出后倒计时，点击确认放弃)
]]
_G.ReqDungeonAbstainMsg = {};

ReqDungeonAbstainMsg.msgId = 3140;
ReqDungeonAbstainMsg.tid = 0; -- 副本id



ReqDungeonAbstainMsg.meta = {__index = ReqDungeonAbstainMsg };
function ReqDungeonAbstainMsg:new()
	local obj = setmetatable( {}, ReqDungeonAbstainMsg.meta);
	return obj;
end

function ReqDungeonAbstainMsg:encode()
	local body = "";

	body = body ..writeInt(self.tid);

	return body;
end

function ReqDungeonAbstainMsg:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);

end



--[[
领奖
]]
_G.ReqDungeonGetAwardMsg = {};

ReqDungeonGetAwardMsg.msgId = 3141;



ReqDungeonGetAwardMsg.meta = {__index = ReqDungeonGetAwardMsg };
function ReqDungeonGetAwardMsg:new()
	local obj = setmetatable( {}, ReqDungeonGetAwardMsg.meta);
	return obj;
end

function ReqDungeonGetAwardMsg:encode()
	local body = "";


	return body;
end

function ReqDungeonGetAwardMsg:ParseData(pak)
	local idx = 1;


end



--[[
穿戴称号
]]
_G.ReqTitleEpuipMsg = {};

ReqTitleEpuipMsg.msgId = 3143;
ReqTitleEpuipMsg.id = 0; -- 称号id
ReqTitleEpuipMsg.state = 0; -- 1穿戴，0未穿戴



ReqTitleEpuipMsg.meta = {__index = ReqTitleEpuipMsg };
function ReqTitleEpuipMsg:new()
	local obj = setmetatable( {}, ReqTitleEpuipMsg.meta);
	return obj;
end

function ReqTitleEpuipMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.state);

	return body;
end

function ReqTitleEpuipMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
装备升品
]]
_G.ReqEquipProMsg = {};

ReqEquipProMsg.msgId = 3147;
ReqEquipProMsg.id = ""; -- 装备cid
ReqEquipProMsg.list_size = 0; -- 升品用装备列表 size
ReqEquipProMsg.list = {}; -- 升品用装备列表 list

--[[
EquipProListVOVO = {
	id = ""; -- 装备cid
}
]]

ReqEquipProMsg.meta = {__index = ReqEquipProMsg };
function ReqEquipProMsg:new()
	local obj = setmetatable( {}, ReqEquipProMsg.meta);
	return obj;
end

function ReqEquipProMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);

	local list1 = self.list;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeGuid(list1[i1].id);
	end

	return body;
end

function ReqEquipProMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local EquipProListVOVo = {};
		EquipProListVOVo.id, idx = readGuid(pak, idx);
		table.push(list1,EquipProListVOVo);
	end

end



--[[
装备传承
]]
_G.ReqEquipInheritMsg = {};

ReqEquipInheritMsg.msgId = 3148;
ReqEquipInheritMsg.srcid = ""; -- 源装备cid
ReqEquipInheritMsg.tarid = ""; -- 目标装备cid
ReqEquipInheritMsg.autoBuy = 0; -- 自动购买材料 1:true



ReqEquipInheritMsg.meta = {__index = ReqEquipInheritMsg };
function ReqEquipInheritMsg:new()
	local obj = setmetatable( {}, ReqEquipInheritMsg.meta);
	return obj;
end

function ReqEquipInheritMsg:encode()
	local body = "";

	body = body ..writeGuid(self.srcid);
	body = body ..writeGuid(self.tarid);
	body = body ..writeInt(self.autoBuy);

	return body;
end

function ReqEquipInheritMsg:ParseData(pak)
	local idx = 1;

	self.srcid, idx = readGuid(pak, idx);
	self.tarid, idx = readGuid(pak, idx);
	self.autoBuy, idx = readInt(pak, idx);

end



--[[
日环任务升到5星
]]
_G.ReqDailyQuestStarMsg = {};

ReqDailyQuestStarMsg.msgId = 3152;
ReqDailyQuestStarMsg.id = 0; -- 任务id



ReqDailyQuestStarMsg.meta = {__index = ReqDailyQuestStarMsg };
function ReqDailyQuestStarMsg:new()
	local obj = setmetatable( {}, ReqDailyQuestStarMsg.meta);
	return obj;
end

function ReqDailyQuestStarMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqDailyQuestStarMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
日环任务一键完成
]]
_G.ReqDailyQuestFinishMsg = {};

ReqDailyQuestFinishMsg.msgId = 3153;
ReqDailyQuestFinishMsg.multiple = 0; -- 1：免费领一倍，2：银两领双倍，：3元宝领三倍



ReqDailyQuestFinishMsg.meta = {__index = ReqDailyQuestFinishMsg };
function ReqDailyQuestFinishMsg:new()
	local obj = setmetatable( {}, ReqDailyQuestFinishMsg.meta);
	return obj;
end

function ReqDailyQuestFinishMsg:encode()
	local body = "";

	body = body ..writeInt(self.multiple);

	return body;
end

function ReqDailyQuestFinishMsg:ParseData(pak)
	local idx = 1;

	self.multiple, idx = readInt(pak, idx);

end



--[[
请求日环任务结果
]]
_G.ReqDailyQuestResultMsg = {};

ReqDailyQuestResultMsg.msgId = 3154;



ReqDailyQuestResultMsg.meta = {__index = ReqDailyQuestResultMsg };
function ReqDailyQuestResultMsg:new()
	local obj = setmetatable( {}, ReqDailyQuestResultMsg.meta);
	return obj;
end

function ReqDailyQuestResultMsg:encode()
	local body = "";


	return body;
end

function ReqDailyQuestResultMsg:ParseData(pak)
	local idx = 1;


end



--[[
日环任务抽奖
]]
_G.ReqDailyQuestDrawMsg = {};

ReqDailyQuestDrawMsg.msgId = 3155;



ReqDailyQuestDrawMsg.meta = {__index = ReqDailyQuestDrawMsg };
function ReqDailyQuestDrawMsg:new()
	local obj = setmetatable( {}, ReqDailyQuestDrawMsg.meta);
	return obj;
end

function ReqDailyQuestDrawMsg:encode()
	local body = "";


	return body;
end

function ReqDailyQuestDrawMsg:ParseData(pak)
	local idx = 1;


end



--[[
日环任务抽奖确认
]]
_G.ReqDailyQuestDrawConfirmMsg = {};

ReqDailyQuestDrawConfirmMsg.msgId = 3156;



ReqDailyQuestDrawConfirmMsg.meta = {__index = ReqDailyQuestDrawConfirmMsg };
function ReqDailyQuestDrawConfirmMsg:new()
	local obj = setmetatable( {}, ReqDailyQuestDrawConfirmMsg.meta);
	return obj;
end

function ReqDailyQuestDrawConfirmMsg:encode()
	local body = "";


	return body;
end

function ReqDailyQuestDrawConfirmMsg:ParseData(pak)
	local idx = 1;


end



--[[
装备宝石升级
]]
_G.ReqEquipGemUpLevelMsg = {};

ReqEquipGemUpLevelMsg.msgId = 3157;
ReqEquipGemUpLevelMsg.tid = 0; -- 表id
ReqEquipGemUpLevelMsg.pos = 0; -- 装备位
ReqEquipGemUpLevelMsg.slot = 0; -- 孔位
ReqEquipGemUpLevelMsg.autoUp = 0; -- 是否一键升级1=true
ReqEquipGemUpLevelMsg.autoBuy = 0; -- 是否自动购买0=true



ReqEquipGemUpLevelMsg.meta = {__index = ReqEquipGemUpLevelMsg };
function ReqEquipGemUpLevelMsg:new()
	local obj = setmetatable( {}, ReqEquipGemUpLevelMsg.meta);
	return obj;
end

function ReqEquipGemUpLevelMsg:encode()
	local body = "";

	body = body ..writeInt(self.tid);
	body = body ..writeInt(self.pos);
	body = body ..writeInt(self.slot);
	body = body ..writeInt(self.autoUp);
	body = body ..writeInt(self.autoBuy);

	return body;
end

function ReqEquipGemUpLevelMsg:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);
	self.slot, idx = readInt(pak, idx);
	self.autoUp, idx = readInt(pak, idx);
	self.autoBuy, idx = readInt(pak, idx);

end



--[[
请求进入活动
]]
_G.ReqActivityEnterMsg = {};

ReqActivityEnterMsg.msgId = 3159;
ReqActivityEnterMsg.id = 0; -- 活动id
ReqActivityEnterMsg.param1 = 0; -- 参数1



ReqActivityEnterMsg.meta = {__index = ReqActivityEnterMsg };
function ReqActivityEnterMsg:new()
	local obj = setmetatable( {}, ReqActivityEnterMsg.meta);
	return obj;
end

function ReqActivityEnterMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.param1);

	return body;
end

function ReqActivityEnterMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.param1, idx = readInt(pak, idx);

end



--[[
请求退出活动
]]
_G.ReqActivityQuitMsg = {};

ReqActivityQuitMsg.msgId = 3160;
ReqActivityQuitMsg.id = 0; -- 活动id



ReqActivityQuitMsg.meta = {__index = ReqActivityQuitMsg };
function ReqActivityQuitMsg:new()
	local obj = setmetatable( {}, ReqActivityQuitMsg.meta);
	return obj;
end

function ReqActivityQuitMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqActivityQuitMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
请求封妖列表
]]
_G.ReqFengYaoInfoMsg = {};

ReqFengYaoInfoMsg.msgId = 3164;



ReqFengYaoInfoMsg.meta = {__index = ReqFengYaoInfoMsg };
function ReqFengYaoInfoMsg:new()
	local obj = setmetatable( {}, ReqFengYaoInfoMsg.meta);
	return obj;
end

function ReqFengYaoInfoMsg:encode()
	local body = "";


	return body;
end

function ReqFengYaoInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
难度刷新
]]
_G.ReqFengYaoLvlRefreshMsg = {};

ReqFengYaoLvlRefreshMsg.msgId = 3165;
ReqFengYaoLvlRefreshMsg.type = 0; -- 刷新类型 0:客户端申请列表 1:银两 2:元宝



ReqFengYaoLvlRefreshMsg.meta = {__index = ReqFengYaoLvlRefreshMsg };
function ReqFengYaoLvlRefreshMsg:new()
	local obj = setmetatable( {}, ReqFengYaoLvlRefreshMsg.meta);
	return obj;
end

function ReqFengYaoLvlRefreshMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqFengYaoLvlRefreshMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
接受封妖任务
]]
_G.ReqAcceptFengYaoMsg = {};

ReqAcceptFengYaoMsg.msgId = 3166;
ReqAcceptFengYaoMsg.fengyaoid = 0; -- 封妖id



ReqAcceptFengYaoMsg.meta = {__index = ReqAcceptFengYaoMsg };
function ReqAcceptFengYaoMsg:new()
	local obj = setmetatable( {}, ReqAcceptFengYaoMsg.meta);
	return obj;
end

function ReqAcceptFengYaoMsg:encode()
	local body = "";

	body = body ..writeInt(self.fengyaoid);

	return body;
end

function ReqAcceptFengYaoMsg:ParseData(pak)
	local idx = 1;

	self.fengyaoid, idx = readInt(pak, idx);

end



--[[
领取封妖奖励
]]
_G.ReqGetFengYaoRewardMsg = {};

ReqGetFengYaoRewardMsg.msgId = 3168;
ReqGetFengYaoRewardMsg.fengyaoid = 0; -- 封妖id
ReqGetFengYaoRewardMsg.type = 0; -- 类型 0、普通，1、银两，2、元宝



ReqGetFengYaoRewardMsg.meta = {__index = ReqGetFengYaoRewardMsg };
function ReqGetFengYaoRewardMsg:new()
	local obj = setmetatable( {}, ReqGetFengYaoRewardMsg.meta);
	return obj;
end

function ReqGetFengYaoRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.fengyaoid);
	body = body ..writeInt(self.type);

	return body;
end

function ReqGetFengYaoRewardMsg:ParseData(pak)
	local idx = 1;

	self.fengyaoid, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
放弃封妖
]]
_G.ReqGiveupFengYaoMsg = {};

ReqGiveupFengYaoMsg.msgId = 3169;
ReqGiveupFengYaoMsg.fengyaoid = 0; -- 封妖id



ReqGiveupFengYaoMsg.meta = {__index = ReqGiveupFengYaoMsg };
function ReqGiveupFengYaoMsg:new()
	local obj = setmetatable( {}, ReqGiveupFengYaoMsg.meta);
	return obj;
end

function ReqGiveupFengYaoMsg:encode()
	local body = "";

	body = body ..writeInt(self.fengyaoid);

	return body;
end

function ReqGiveupFengYaoMsg:ParseData(pak)
	local idx = 1;

	self.fengyaoid, idx = readInt(pak, idx);

end



--[[
获取封妖宝箱奖励
]]
_G.ReqGetFengYaoBoxMsg = {};

ReqGetFengYaoBoxMsg.msgId = 3171;
ReqGetFengYaoBoxMsg.boxId = 0; -- 宝箱等级



ReqGetFengYaoBoxMsg.meta = {__index = ReqGetFengYaoBoxMsg };
function ReqGetFengYaoBoxMsg:new()
	local obj = setmetatable( {}, ReqGetFengYaoBoxMsg.meta);
	return obj;
end

function ReqGetFengYaoBoxMsg:encode()
	local body = "";

	body = body ..writeInt(self.boxId);

	return body;
end

function ReqGetFengYaoBoxMsg:ParseData(pak)
	local idx = 1;

	self.boxId, idx = readInt(pak, idx);

end



--[[
发送定义的PK规则
]]
_G.ReqSendPKRuleMsg = {};

ReqSendPKRuleMsg.msgId = 3172;
ReqSendPKRuleMsg.pkid = 0; -- 返回定义PK的规则0：和平，1：组队，2：帮派，3：本服，4：阵营，5：善恶，6：全体，7：自定义
ReqSendPKRuleMsg.myselfpk = 0; -- 自己定义的PK规则



ReqSendPKRuleMsg.meta = {__index = ReqSendPKRuleMsg };
function ReqSendPKRuleMsg:new()
	local obj = setmetatable( {}, ReqSendPKRuleMsg.meta);
	return obj;
end

function ReqSendPKRuleMsg:encode()
	local body = "";

	body = body ..writeInt(self.pkid);
	body = body ..writeInt(self.myselfpk);

	return body;
end

function ReqSendPKRuleMsg:ParseData(pak)
	local idx = 1;

	self.pkid, idx = readInt(pak, idx);
	self.myselfpk, idx = readInt(pak, idx);

end



--[[
妖魂兑换
]]
_G.ReqYaoHunExchangeMsg = {};

ReqYaoHunExchangeMsg.msgId = 3175;
ReqYaoHunExchangeMsg.type = 0; -- 类型



ReqYaoHunExchangeMsg.meta = {__index = ReqYaoHunExchangeMsg };
function ReqYaoHunExchangeMsg:new()
	local obj = setmetatable( {}, ReqYaoHunExchangeMsg.meta);
	return obj;
end

function ReqYaoHunExchangeMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqYaoHunExchangeMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
请求签到
]]
_G.ReqSignMsg = {};

ReqSignMsg.msgId = 3179;
ReqSignMsg.day = 0; -- 签到天
ReqSignMsg.state = 0; -- 1 签到 2 补签



ReqSignMsg.meta = {__index = ReqSignMsg };
function ReqSignMsg:new()
	local obj = setmetatable( {}, ReqSignMsg.meta);
	return obj;
end

function ReqSignMsg:encode()
	local body = "";

	body = body ..writeInt(self.day);
	body = body ..writeInt(self.state);

	return body;
end

function ReqSignMsg:ParseData(pak)
	local idx = 1;

	self.day, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
领取签到奖励
]]
_G.ReqSignRewardMsg = {};

ReqSignRewardMsg.msgId = 3180;
ReqSignRewardMsg.day = 0; -- 签到天
ReqSignRewardMsg.type = 0; -- 领取的奖励类型



ReqSignRewardMsg.meta = {__index = ReqSignRewardMsg };
function ReqSignRewardMsg:new()
	local obj = setmetatable( {}, ReqSignRewardMsg.meta);
	return obj;
end

function ReqSignRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.day);
	body = body ..writeInt(self.type);

	return body;
end

function ReqSignRewardMsg:ParseData(pak)
	local idx = 1;

	self.day, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
请求领取等级奖励
]]
_G.ReqGetLvlRewardMsg = {};

ReqGetLvlRewardMsg.msgId = 3182;
ReqGetLvlRewardMsg.lvl = 0; -- 等级



ReqGetLvlRewardMsg.meta = {__index = ReqGetLvlRewardMsg };
function ReqGetLvlRewardMsg:new()
	local obj = setmetatable( {}, ReqGetLvlRewardMsg.meta);
	return obj;
end

function ReqGetLvlRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.lvl);

	return body;
end

function ReqGetLvlRewardMsg:ParseData(pak)
	local idx = 1;

	self.lvl, idx = readInt(pak, idx);

end



--[[
请求战场总排行
]]
_G.ReqZhancRankMsg = {};

ReqZhancRankMsg.msgId = 3184;
ReqZhancRankMsg.camp = 0; -- 阵营



ReqZhancRankMsg.meta = {__index = ReqZhancRankMsg };
function ReqZhancRankMsg:new()
	local obj = setmetatable( {}, ReqZhancRankMsg.meta);
	return obj;
end

function ReqZhancRankMsg:encode()
	local body = "";

	body = body ..writeInt(self.camp);

	return body;
end

function ReqZhancRankMsg:ParseData(pak)
	local idx = 1;

	self.camp, idx = readInt(pak, idx);

end



--[[
退出竞技场
]]
_G.ReqQuitArenaMsg = {};

ReqQuitArenaMsg.msgId = 3192;



ReqQuitArenaMsg.meta = {__index = ReqQuitArenaMsg };
function ReqQuitArenaMsg:new()
	local obj = setmetatable( {}, ReqQuitArenaMsg.meta);
	return obj;
end

function ReqQuitArenaMsg:encode()
	local body = "";


	return body;
end

function ReqQuitArenaMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求旗帜操作
]]
_G.ReqPickFlagMsg = {};

ReqPickFlagMsg.msgId = 3199;
ReqPickFlagMsg.oper = 0; -- 0:拾取 1:交付
ReqPickFlagMsg.idx = 0; -- 旗帜索引



ReqPickFlagMsg.meta = {__index = ReqPickFlagMsg };
function ReqPickFlagMsg:new()
	local obj = setmetatable( {}, ReqPickFlagMsg.meta);
	return obj;
end

function ReqPickFlagMsg:encode()
	local body = "";

	body = body ..writeInt(self.oper);
	body = body ..writeInt(self.idx);

	return body;
end

function ReqPickFlagMsg:ParseData(pak)
	local idx = 1;

	self.oper, idx = readInt(pak, idx);
	self.idx, idx = readInt(pak, idx);

end



--[[
请求传送
]]
_G.ReqTeleportMsg = {};

ReqTeleportMsg.msgId = 3200;
ReqTeleportMsg.type = 0; -- 1世界地图传送 2日环传送 3剧情传送 4悬赏传送 5世界boss传送 6主线传送 7远距离主线任务免费传送(根据任务表配的teleportMap地图id)10一键挖宝传送
ReqTeleportMsg.mapId = 0; -- 地图id
ReqTeleportMsg.x = 0; -- x
ReqTeleportMsg.y = 0; -- y



ReqTeleportMsg.meta = {__index = ReqTeleportMsg };
function ReqTeleportMsg:new()
	local obj = setmetatable( {}, ReqTeleportMsg.meta);
	return obj;
end

function ReqTeleportMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);
	body = body ..writeInt(self.mapId);
	body = body ..writeInt(self.x);
	body = body ..writeInt(self.y);

	return body;
end

function ReqTeleportMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.mapId, idx = readInt(pak, idx);
	self.x, idx = readInt(pak, idx);
	self.y, idx = readInt(pak, idx);

end



--[[
请求合成道具
]]
_G.ReqToolHeChengMsg = {};

ReqToolHeChengMsg.msgId = 3204;
ReqToolHeChengMsg.Id = 0; -- 合成分解的道具Id
ReqToolHeChengMsg.type = 0; -- 合成分解类型 1:合成 2:分解
ReqToolHeChengMsg.count = 0; -- 合成分解的道具数量



ReqToolHeChengMsg.meta = {__index = ReqToolHeChengMsg };
function ReqToolHeChengMsg:new()
	local obj = setmetatable( {}, ReqToolHeChengMsg.meta);
	return obj;
end

function ReqToolHeChengMsg:encode()
	local body = "";

	body = body ..writeInt(self.Id);
	body = body ..writeInt(self.type);
	body = body ..writeInt(self.count);

	return body;
end

function ReqToolHeChengMsg:ParseData(pak)
	local idx = 1;

	self.Id, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);
	self.count, idx = readInt(pak, idx);

end



--[[
请求快速解救
]]
_G.ReqQuickJieFengMsg = {};

ReqQuickJieFengMsg.msgId = 3209;
ReqQuickJieFengMsg.Id = 0; -- 解救目标Id
ReqQuickJieFengMsg.count = 0; -- 解救目标数量



ReqQuickJieFengMsg.meta = {__index = ReqQuickJieFengMsg };
function ReqQuickJieFengMsg:new()
	local obj = setmetatable( {}, ReqQuickJieFengMsg.meta);
	return obj;
end

function ReqQuickJieFengMsg:encode()
	local body = "";

	body = body ..writeInt(self.Id);
	body = body ..writeInt(self.count);

	return body;
end

function ReqQuickJieFengMsg:ParseData(pak)
	local idx = 1;

	self.Id, idx = readInt(pak, idx);
	self.count, idx = readInt(pak, idx);

end



--[[
请求副本Boss降星级
]]
_G.ReqBossFallStarMsg = {};

ReqBossFallStarMsg.msgId = 3210;
ReqBossFallStarMsg.Id = 0; -- 降星boss_id



ReqBossFallStarMsg.meta = {__index = ReqBossFallStarMsg };
function ReqBossFallStarMsg:new()
	local obj = setmetatable( {}, ReqBossFallStarMsg.meta);
	return obj;
end

function ReqBossFallStarMsg:encode()
	local body = "";

	body = body ..writeInt(self.Id);

	return body;
end

function ReqBossFallStarMsg:ParseData(pak)
	local idx = 1;

	self.Id, idx = readInt(pak, idx);

end



--[[
请求领取奖励
]]
_G.ReqZhancRewardMsg = {};

ReqZhancRewardMsg.msgId = 3215;



ReqZhancRewardMsg.meta = {__index = ReqZhancRewardMsg };
function ReqZhancRewardMsg:new()
	local obj = setmetatable( {}, ReqZhancRewardMsg.meta);
	return obj;
end

function ReqZhancRewardMsg:encode()
	local body = "";


	return body;
end

function ReqZhancRewardMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求退出地宫炼狱
]]
_G.ReqQuitGuildHellMsg = {};

ReqQuitGuildHellMsg.msgId = 3216;



ReqQuitGuildHellMsg.meta = {__index = ReqQuitGuildHellMsg };
function ReqQuitGuildHellMsg:new()
	local obj = setmetatable( {}, ReqQuitGuildHellMsg.meta);
	return obj;
end

function ReqQuitGuildHellMsg:encode()
	local body = "";


	return body;
end

function ReqQuitGuildHellMsg:ParseData(pak)
	local idx = 1;


end



--[[
查看其他人信息
]]
_G.ReqOtherHumanInfoMsg = {};

ReqOtherHumanInfoMsg.msgId = 3217;
ReqOtherHumanInfoMsg.roleID = ""; -- 角色ID
ReqOtherHumanInfoMsg.type = 0; -- 查看类型 1:基本信息 2:详细信息 4:坐骑 8:武魂 16:装备宝石 32:卓越孔信息 64:身上道具 128:灵阵 256:神兵



ReqOtherHumanInfoMsg.meta = {__index = ReqOtherHumanInfoMsg };
function ReqOtherHumanInfoMsg:new()
	local obj = setmetatable( {}, ReqOtherHumanInfoMsg.meta);
	return obj;
end

function ReqOtherHumanInfoMsg:encode()
	local body = "";

	body = body ..writeGuid(self.roleID);
	body = body ..writeInt(self.type);

	return body;
end

function ReqOtherHumanInfoMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
发送自定义设置
]]
_G.ReqSetSystemInfoMsg = {};

ReqSetSystemInfoMsg.msgId = 3223;
ReqSetSystemInfoMsg.showInfo = 0; -- 显示类型参数
ReqSetSystemInfoMsg.keyStr = ""; -- 按键参数



ReqSetSystemInfoMsg.meta = {__index = ReqSetSystemInfoMsg };
function ReqSetSystemInfoMsg:new()
	local obj = setmetatable( {}, ReqSetSystemInfoMsg.meta);
	return obj;
end

function ReqSetSystemInfoMsg:encode()
	local body = "";

	body = body ..writeInt(self.showInfo);
	body = body ..writeString(self.keyStr,128);

	return body;
end

function ReqSetSystemInfoMsg:ParseData(pak)
	local idx = 1;

	self.showInfo, idx = readInt(pak, idx);
	self.keyStr, idx = readString(pak, idx, 128);

end



--[[
发送打宝活力值设置
]]
_G.ReqSetDynamicDropMsg = {};

ReqSetDynamicDropMsg.msgId = 3224;
ReqSetDynamicDropMsg.level = 0; -- 级别,0:关闭



ReqSetDynamicDropMsg.meta = {__index = ReqSetDynamicDropMsg };
function ReqSetDynamicDropMsg:new()
	local obj = setmetatable( {}, ReqSetDynamicDropMsg.meta);
	return obj;
end

function ReqSetDynamicDropMsg:encode()
	local body = "";

	body = body ..writeInt(self.level);

	return body;
end

function ReqSetDynamicDropMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);

end



--[[
穿戴时装
]]
_G.ReqDressFashionMsg = {};

ReqDressFashionMsg.msgId = 3226;
ReqDressFashionMsg.tid = 0; -- 时装tid
ReqDressFashionMsg.type = 0; -- 操作类型 1:穿 0:脱



ReqDressFashionMsg.meta = {__index = ReqDressFashionMsg };
function ReqDressFashionMsg:new()
	local obj = setmetatable( {}, ReqDressFashionMsg.meta);
	return obj;
end

function ReqDressFashionMsg:encode()
	local body = "";

	body = body ..writeInt(self.tid);
	body = body ..writeInt(self.type);

	return body;
end

function ReqDressFashionMsg:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
请求通天塔信息
]]
_G.ReqGetBabelInfoMsg = {};

ReqGetBabelInfoMsg.msgId = 3231;
ReqGetBabelInfoMsg.layer = 0; -- 请求通天塔某一层数据类型



ReqGetBabelInfoMsg.meta = {__index = ReqGetBabelInfoMsg };
function ReqGetBabelInfoMsg:new()
	local obj = setmetatable( {}, ReqGetBabelInfoMsg.meta);
	return obj;
end

function ReqGetBabelInfoMsg:encode()
	local body = "";

	body = body ..writeInt(self.layer);

	return body;
end

function ReqGetBabelInfoMsg:ParseData(pak)
	local idx = 1;

	self.layer, idx = readInt(pak, idx);

end



--[[
请求通天塔排行榜信息
]]
_G.ReqGetRankingListMsg = {};

ReqGetRankingListMsg.msgId = 3232;



ReqGetRankingListMsg.meta = {__index = ReqGetRankingListMsg };
function ReqGetRankingListMsg:new()
	local obj = setmetatable( {}, ReqGetRankingListMsg.meta);
	return obj;
end

function ReqGetRankingListMsg:encode()
	local body = "";


	return body;
end

function ReqGetRankingListMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求进入通天塔
]]
_G.ReqEnterIntoMsg = {};

ReqEnterIntoMsg.msgId = 3233;
ReqEnterIntoMsg.layer = 0; -- 进入层数



ReqEnterIntoMsg.meta = {__index = ReqEnterIntoMsg };
function ReqEnterIntoMsg:new()
	local obj = setmetatable( {}, ReqEnterIntoMsg.meta);
	return obj;
end

function ReqEnterIntoMsg:encode()
	local body = "";

	body = body ..writeInt(self.layer);

	return body;
end

function ReqEnterIntoMsg:ParseData(pak)
	local idx = 1;

	self.layer, idx = readInt(pak, idx);

end



--[[
请求退出通天塔
]]
_G.ReqOutBabelMsg = {};

ReqOutBabelMsg.msgId = 3234;
ReqOutBabelMsg.state = 0; -- 1 继续 0 退出 2 再次挑战



ReqOutBabelMsg.meta = {__index = ReqOutBabelMsg };
function ReqOutBabelMsg:new()
	local obj = setmetatable( {}, ReqOutBabelMsg.meta);
	return obj;
end

function ReqOutBabelMsg:encode()
	local body = "";

	body = body ..writeInt(self.state);

	return body;
end

function ReqOutBabelMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);

end



--[[
请求进入帮派战
]]
_G.ReqEnterGuildWarMsg = {};

ReqEnterGuildWarMsg.msgId = 3237;
ReqEnterGuildWarMsg.MapId = 0; -- 地图ID



ReqEnterGuildWarMsg.meta = {__index = ReqEnterGuildWarMsg };
function ReqEnterGuildWarMsg:new()
	local obj = setmetatable( {}, ReqEnterGuildWarMsg.meta);
	return obj;
end

function ReqEnterGuildWarMsg:encode()
	local body = "";

	body = body ..writeInt64(self.MapId);

	return body;
end

function ReqEnterGuildWarMsg:ParseData(pak)
	local idx = 1;

	self.MapId, idx = readInt64(pak, idx);

end



--[[
请求退出帮派战
]]
_G.ReqQuitGuildWarMsg = {};

ReqQuitGuildWarMsg.msgId = 3238;



ReqQuitGuildWarMsg.meta = {__index = ReqQuitGuildWarMsg };
function ReqQuitGuildWarMsg:new()
	local obj = setmetatable( {}, ReqQuitGuildWarMsg.meta);
	return obj;
end

function ReqQuitGuildWarMsg:encode()
	local body = "";


	return body;
end

function ReqQuitGuildWarMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求卓越孔升级
]]
_G.ReqSuperHoleUpMsg = {};

ReqSuperHoleUpMsg.msgId = 3241;
ReqSuperHoleUpMsg.pos = 0; -- 装备位
ReqSuperHoleUpMsg.index = 0; -- 孔索引 从1开始
ReqSuperHoleUpMsg.autoBuy = 0; -- 自动购买,0true



ReqSuperHoleUpMsg.meta = {__index = ReqSuperHoleUpMsg };
function ReqSuperHoleUpMsg:new()
	local obj = setmetatable( {}, ReqSuperHoleUpMsg.meta);
	return obj;
end

function ReqSuperHoleUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.pos);
	body = body ..writeInt(self.index);
	body = body ..writeInt(self.autoBuy);

	return body;
end

function ReqSuperHoleUpMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readInt(pak, idx);
	self.index, idx = readInt(pak, idx);
	self.autoBuy, idx = readInt(pak, idx);

end



--[[
请求卸载卓越属性
]]
_G.ReqSuperAttrDownMsg = {};

ReqSuperAttrDownMsg.msgId = 3243;
ReqSuperAttrDownMsg.eid = ""; -- 装备uid
ReqSuperAttrDownMsg.index = 0; -- 孔索引 从1开始



ReqSuperAttrDownMsg.meta = {__index = ReqSuperAttrDownMsg };
function ReqSuperAttrDownMsg:new()
	local obj = setmetatable( {}, ReqSuperAttrDownMsg.meta);
	return obj;
end

function ReqSuperAttrDownMsg:encode()
	local body = "";

	body = body ..writeGuid(self.eid);
	body = body ..writeInt(self.index);

	return body;
end

function ReqSuperAttrDownMsg:ParseData(pak)
	local idx = 1;

	self.eid, idx = readGuid(pak, idx);
	self.index, idx = readInt(pak, idx);

end



--[[
请求安装卓越属性
]]
_G.ReqSuperAttrUpMsg = {};

ReqSuperAttrUpMsg.msgId = 3244;
ReqSuperAttrUpMsg.uid = ""; -- 属性uid
ReqSuperAttrUpMsg.eid = ""; -- 装备uid
ReqSuperAttrUpMsg.index = 0; -- 孔索引 从1开始
ReqSuperAttrUpMsg.autoBuy = 0; -- 自动购买,0true



ReqSuperAttrUpMsg.meta = {__index = ReqSuperAttrUpMsg };
function ReqSuperAttrUpMsg:new()
	local obj = setmetatable( {}, ReqSuperAttrUpMsg.meta);
	return obj;
end

function ReqSuperAttrUpMsg:encode()
	local body = "";

	body = body ..writeGuid(self.uid);
	body = body ..writeGuid(self.eid);
	body = body ..writeInt(self.index);
	body = body ..writeInt(self.autoBuy);

	return body;
end

function ReqSuperAttrUpMsg:ParseData(pak)
	local idx = 1;

	self.uid, idx = readGuid(pak, idx);
	self.eid, idx = readGuid(pak, idx);
	self.index, idx = readInt(pak, idx);
	self.autoBuy, idx = readInt(pak, idx);

end



--[[
请求从卓越属性库删除
]]
_G.ReqSuperLibRemoveMsg = {};

ReqSuperLibRemoveMsg.msgId = 3245;
ReqSuperLibRemoveMsg.list_size = 0; -- 列表 size
ReqSuperLibRemoveMsg.list = {}; -- 列表 list

--[[
EquipExtraVOVO = {
	uid = ""; -- 属性uid
}
]]

ReqSuperLibRemoveMsg.meta = {__index = ReqSuperLibRemoveMsg };
function ReqSuperLibRemoveMsg:new()
	local obj = setmetatable( {}, ReqSuperLibRemoveMsg.meta);
	return obj;
end

function ReqSuperLibRemoveMsg:encode()
	local body = "";


	local list1 = self.list;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeGuid(list1[i1].uid);
	end

	return body;
end

function ReqSuperLibRemoveMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local EquipExtraVOVo = {};
		EquipExtraVOVo.uid, idx = readGuid(pak, idx);
		table.push(list1,EquipExtraVOVo);
	end

end



--[[
追加属性传承
]]
_G.ReqEquipExtraInheritMsg = {};

ReqEquipExtraInheritMsg.msgId = 3247;
ReqEquipExtraInheritMsg.srcId = ""; -- 源cid
ReqEquipExtraInheritMsg.tarId = ""; -- 目标cid
ReqEquipExtraInheritMsg.state = 0; -- 是否自动购买



ReqEquipExtraInheritMsg.meta = {__index = ReqEquipExtraInheritMsg };
function ReqEquipExtraInheritMsg:new()
	local obj = setmetatable( {}, ReqEquipExtraInheritMsg.meta);
	return obj;
end

function ReqEquipExtraInheritMsg:encode()
	local body = "";

	body = body ..writeGuid(self.srcId);
	body = body ..writeGuid(self.tarId);
	body = body ..writeInt(self.state);

	return body;
end

function ReqEquipExtraInheritMsg:ParseData(pak)
	local idx = 1;

	self.srcId, idx = readGuid(pak, idx);
	self.tarId, idx = readGuid(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
客户端请求：神兵进阶
]]
_G.ReqMagicWeaponLevelUpMsg = {};

ReqMagicWeaponLevelUpMsg.msgId = 3250;
ReqMagicWeaponLevelUpMsg.autobuy = 0; -- 道具不足时是否自动购买, 0自动购买



ReqMagicWeaponLevelUpMsg.meta = {__index = ReqMagicWeaponLevelUpMsg };
function ReqMagicWeaponLevelUpMsg:new()
	local obj = setmetatable( {}, ReqMagicWeaponLevelUpMsg.meta);
	return obj;
end

function ReqMagicWeaponLevelUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.autobuy);

	return body;
end

function ReqMagicWeaponLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.autobuy, idx = readInt(pak, idx);

end



--[[
客户端请求：进入时间副本
]]
_G.ReqEnterTimeDungeonMsg = {};

ReqEnterTimeDungeonMsg.msgId = 3251;
ReqEnterTimeDungeonMsg.state = 0; -- 进入难度：1 普通 2 困难 3 噩梦 4 神话 5 传说



ReqEnterTimeDungeonMsg.meta = {__index = ReqEnterTimeDungeonMsg };
function ReqEnterTimeDungeonMsg:new()
	local obj = setmetatable( {}, ReqEnterTimeDungeonMsg.meta);
	return obj;
end

function ReqEnterTimeDungeonMsg:encode()
	local body = "";

	body = body ..writeInt(self.state);

	return body;
end

function ReqEnterTimeDungeonMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);

end



--[[
客户端请求：退出时间副本
]]
_G.ReqQuitTimeDungeonMsg = {};

ReqQuitTimeDungeonMsg.msgId = 3252;



ReqQuitTimeDungeonMsg.meta = {__index = ReqQuitTimeDungeonMsg };
function ReqQuitTimeDungeonMsg:new()
	local obj = setmetatable( {}, ReqQuitTimeDungeonMsg.meta);
	return obj;
end

function ReqQuitTimeDungeonMsg:encode()
	local body = "";


	return body;
end

function ReqQuitTimeDungeonMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：剩余挑战次数
]]
_G.ReqDungeonNumMsg = {};

ReqDungeonNumMsg.msgId = 3253;



ReqDungeonNumMsg.meta = {__index = ReqDungeonNumMsg };
function ReqDungeonNumMsg:new()
	local obj = setmetatable( {}, ReqDungeonNumMsg.meta);
	return obj;
end

function ReqDungeonNumMsg:encode()
	local body = "";


	return body;
end

function ReqDungeonNumMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：领取帮派战奖励
]]
_G.ReqGetUnionWarRewardMsg = {};

ReqGetUnionWarRewardMsg.msgId = 3257;



ReqGetUnionWarRewardMsg.meta = {__index = ReqGetUnionWarRewardMsg };
function ReqGetUnionWarRewardMsg:new()
	local obj = setmetatable( {}, ReqGetUnionWarRewardMsg.meta);
	return obj;
end

function ReqGetUnionWarRewardMsg:encode()
	local body = "";


	return body;
end

function ReqGetUnionWarRewardMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：离线奖励
]]
_G.ReqGetOutLineRewardMsg = {};

ReqGetOutLineRewardMsg.msgId = 3259;
ReqGetOutLineRewardMsg.type = 0; -- 1 基本收益，2 双倍收益，3 三倍收益



ReqGetOutLineRewardMsg.meta = {__index = ReqGetOutLineRewardMsg };
function ReqGetOutLineRewardMsg:new()
	local obj = setmetatable( {}, ReqGetOutLineRewardMsg.meta);
	return obj;
end

function ReqGetOutLineRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqGetOutLineRewardMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
客户端请求：活跃度升级
]]
_G.ReqHuoYueLevelupMsg = {};

ReqHuoYueLevelupMsg.msgId = 3262;



ReqHuoYueLevelupMsg.meta = {__index = ReqHuoYueLevelupMsg };
function ReqHuoYueLevelupMsg:new()
	local obj = setmetatable( {}, ReqHuoYueLevelupMsg.meta);
	return obj;
end

function ReqHuoYueLevelupMsg:encode()
	local body = "";


	return body;
end

function ReqHuoYueLevelupMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：剧情结束
]]
_G.ReqsSendStoryEndMsg = {};

ReqsSendStoryEndMsg.msgId = 3263;
ReqsSendStoryEndMsg.type = 0; -- 剧情类型： 1 通天塔；



ReqsSendStoryEndMsg.meta = {__index = ReqsSendStoryEndMsg };
function ReqsSendStoryEndMsg:new()
	local obj = setmetatable( {}, ReqsSendStoryEndMsg.meta);
	return obj;
end

function ReqsSendStoryEndMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqsSendStoryEndMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
请求在线抽奖
]]
_G.ReqRandomRewardMsg = {};

ReqRandomRewardMsg.msgId = 3265;
ReqRandomRewardMsg.index = 0; -- 索引 0 , 1 ,2 , 3



ReqRandomRewardMsg.meta = {__index = ReqRandomRewardMsg };
function ReqRandomRewardMsg:new()
	local obj = setmetatable( {}, ReqRandomRewardMsg.meta);
	return obj;
end

function ReqRandomRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.index);

	return body;
end

function ReqRandomRewardMsg:ParseData(pak)
	local idx = 1;

	self.index, idx = readInt(pak, idx);

end



--[[
请求修炼境界
]]
_G.ReqPracticeMsg = {};

ReqPracticeMsg.msgId = 3290;
ReqPracticeMsg.jingjieOrder = 0; -- 境界等阶



ReqPracticeMsg.meta = {__index = ReqPracticeMsg };
function ReqPracticeMsg:new()
	local obj = setmetatable( {}, ReqPracticeMsg.meta);
	return obj;
end

function ReqPracticeMsg:encode()
	local body = "";

	body = body ..writeInt(self.jingjieOrder);

	return body;
end

function ReqPracticeMsg:ParseData(pak)
	local idx = 1;

	self.jingjieOrder, idx = readInt(pak, idx);

end



--[[
请求境界突破
]]
_G.ReqBreakJingjieMsg = {};

ReqBreakJingjieMsg.msgId = 3291;
ReqBreakJingjieMsg.jingjieOrder = 0; -- 境界等阶
ReqBreakJingjieMsg.autoBuy = 0; -- 0 不自动购买，1 自动购买道具



ReqBreakJingjieMsg.meta = {__index = ReqBreakJingjieMsg };
function ReqBreakJingjieMsg:new()
	local obj = setmetatable( {}, ReqBreakJingjieMsg.meta);
	return obj;
end

function ReqBreakJingjieMsg:encode()
	local body = "";

	body = body ..writeInt(self.jingjieOrder);
	body = body ..writeInt(self.autoBuy);

	return body;
end

function ReqBreakJingjieMsg:ParseData(pak)
	local idx = 1;

	self.jingjieOrder, idx = readInt(pak, idx);
	self.autoBuy, idx = readInt(pak, idx);

end



--[[
请求限时副本信息
]]
_G.ReqExtremityInfoMsg = {};

ReqExtremityInfoMsg.msgId = 3293;



ReqExtremityInfoMsg.meta = {__index = ReqExtremityInfoMsg };
function ReqExtremityInfoMsg:new()
	local obj = setmetatable( {}, ReqExtremityInfoMsg.meta);
	return obj;
end

function ReqExtremityInfoMsg:encode()
	local body = "";


	return body;
end

function ReqExtremityInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求进入限时副本
]]
_G.ReqEnterExtremityMsg = {};

ReqEnterExtremityMsg.msgId = 3294;



ReqEnterExtremityMsg.meta = {__index = ReqEnterExtremityMsg };
function ReqEnterExtremityMsg:new()
	local obj = setmetatable( {}, ReqEnterExtremityMsg.meta);
	return obj;
end

function ReqEnterExtremityMsg:encode()
	local body = "";


	return body;
end

function ReqEnterExtremityMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求退出限时副本
]]
_G.ReqQuitExtremityMsg = {};

ReqQuitExtremityMsg.msgId = 3295;



ReqQuitExtremityMsg.meta = {__index = ReqQuitExtremityMsg };
function ReqQuitExtremityMsg:new()
	local obj = setmetatable( {}, ReqQuitExtremityMsg.meta);
	return obj;
end

function ReqQuitExtremityMsg:encode()
	local body = "";


	return body;
end

function ReqQuitExtremityMsg:ParseData(pak)
	local idx = 1;


end



--[[
加入帮派王城战
]]
_G.ReqEnterGuildCityWarMsg = {};

ReqEnterGuildCityWarMsg.msgId = 3302;
ReqEnterGuildCityWarMsg.MapId = 0; -- 地图ID



ReqEnterGuildCityWarMsg.meta = {__index = ReqEnterGuildCityWarMsg };
function ReqEnterGuildCityWarMsg:new()
	local obj = setmetatable( {}, ReqEnterGuildCityWarMsg.meta);
	return obj;
end

function ReqEnterGuildCityWarMsg:encode()
	local body = "";

	body = body ..writeInt64(self.MapId);

	return body;
end

function ReqEnterGuildCityWarMsg:ParseData(pak)
	local idx = 1;

	self.MapId, idx = readInt64(pak, idx);

end



--[[
退出帮派王城战
]]
_G.ReqQuitGuildCityWarMsg = {};

ReqQuitGuildCityWarMsg.msgId = 3303;



ReqQuitGuildCityWarMsg.meta = {__index = ReqQuitGuildCityWarMsg };
function ReqQuitGuildCityWarMsg:new()
	local obj = setmetatable( {}, ReqQuitGuildCityWarMsg.meta);
	return obj;
end

function ReqQuitGuildCityWarMsg:encode()
	local body = "";


	return body;
end

function ReqQuitGuildCityWarMsg:ParseData(pak)
	local idx = 1;


end



--[[
询问打宝活力值掉宝记录
]]
_G.ReqDynamicDropItemsMsg = {};

ReqDynamicDropItemsMsg.msgId = 3306;



ReqDynamicDropItemsMsg.meta = {__index = ReqDynamicDropItemsMsg };
function ReqDynamicDropItemsMsg:new()
	local obj = setmetatable( {}, ReqDynamicDropItemsMsg.meta);
	return obj;
end

function ReqDynamicDropItemsMsg:encode()
	local body = "";


	return body;
end

function ReqDynamicDropItemsMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求副本排行榜，前十
]]
_G.ReqDungeonRankMsg = {};

ReqDungeonRankMsg.msgId = 3308;
ReqDungeonRankMsg.dungeonId = 0; -- 副本id



ReqDungeonRankMsg.meta = {__index = ReqDungeonRankMsg };
function ReqDungeonRankMsg:new()
	local obj = setmetatable( {}, ReqDungeonRankMsg.meta);
	return obj;
end

function ReqDungeonRankMsg:encode()
	local body = "";

	body = body ..writeInt(self.dungeonId);

	return body;
end

function ReqDungeonRankMsg:ParseData(pak)
	local idx = 1;

	self.dungeonId, idx = readInt(pak, idx);

end



--[[
请求领取帮派王城战奖励
]]
_G.ReqUnionCityWarGetRewardMsg = {};

ReqUnionCityWarGetRewardMsg.msgId = 3310;



ReqUnionCityWarGetRewardMsg.meta = {__index = ReqUnionCityWarGetRewardMsg };
function ReqUnionCityWarGetRewardMsg:new()
	local obj = setmetatable( {}, ReqUnionCityWarGetRewardMsg.meta);
	return obj;
end

function ReqUnionCityWarGetRewardMsg:encode()
	local body = "";


	return body;
end

function ReqUnionCityWarGetRewardMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：请求今日必做信息
]]
_G.ReqDailyMustDoMsg = {};

ReqDailyMustDoMsg.msgId = 3311;



ReqDailyMustDoMsg.meta = {__index = ReqDailyMustDoMsg };
function ReqDailyMustDoMsg:new()
	local obj = setmetatable( {}, ReqDailyMustDoMsg.meta);
	return obj;
end

function ReqDailyMustDoMsg:encode()
	local body = "";


	return body;
end

function ReqDailyMustDoMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：完成或者追回资源
]]
_G.ReqFinishMustDoMsg = {};

ReqFinishMustDoMsg.msgId = 3312;
ReqFinishMustDoMsg.id = 0; -- 活跃id
ReqFinishMustDoMsg.type = 0; -- 类型, 1=扫荡，2=追回
ReqFinishMustDoMsg.consumetype = 0; -- 类型, 0=银两，1=元宝



ReqFinishMustDoMsg.meta = {__index = ReqFinishMustDoMsg };
function ReqFinishMustDoMsg:new()
	local obj = setmetatable( {}, ReqFinishMustDoMsg.meta);
	return obj;
end

function ReqFinishMustDoMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.type);
	body = body ..writeInt(self.consumetype);

	return body;
end

function ReqFinishMustDoMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);
	self.consumetype, idx = readInt(pak, idx);

end



--[[
客户端请求：一键完成或者追回资源
]]
_G.ReqFinishAllMustDoMsg = {};

ReqFinishAllMustDoMsg.msgId = 3313;
ReqFinishAllMustDoMsg.consumetype = 0; -- 类型, 0=银两，1=元宝
ReqFinishAllMustDoMsg.type = 0; -- 类型, 0=今日必做，1=昨日追回



ReqFinishAllMustDoMsg.meta = {__index = ReqFinishAllMustDoMsg };
function ReqFinishAllMustDoMsg:new()
	local obj = setmetatable( {}, ReqFinishAllMustDoMsg.meta);
	return obj;
end

function ReqFinishAllMustDoMsg:encode()
	local body = "";

	body = body ..writeInt(self.consumetype);
	body = body ..writeInt(self.type);

	return body;
end

function ReqFinishAllMustDoMsg:ParseData(pak)
	local idx = 1;

	self.consumetype, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
请求领取运营活动奖励
]]
_G.ReqOperActGetRewardMsg = {};

ReqOperActGetRewardMsg.msgId = 3315;
ReqOperActGetRewardMsg.id = 0; -- 运营活动配表id



ReqOperActGetRewardMsg.meta = {__index = ReqOperActGetRewardMsg };
function ReqOperActGetRewardMsg:new()
	local obj = setmetatable( {}, ReqOperActGetRewardMsg.meta);
	return obj;
end

function ReqOperActGetRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqOperActGetRewardMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
客户端请求:回城
]]
_G.ReqBackHomeMsg = {};

ReqBackHomeMsg.msgId = 3318;
ReqBackHomeMsg.mapid = 0; -- 地图id



ReqBackHomeMsg.meta = {__index = ReqBackHomeMsg };
function ReqBackHomeMsg:new()
	local obj = setmetatable( {}, ReqBackHomeMsg.meta);
	return obj;
end

function ReqBackHomeMsg:encode()
	local body = "";

	body = body ..writeInt(self.mapid);

	return body;
end

function ReqBackHomeMsg:ParseData(pak)
	local idx = 1;

	self.mapid, idx = readInt(pak, idx);

end



--[[
请求境界灌注
]]
_G.ReqRealmFloodMsg = {};

ReqRealmFloodMsg.msgId = 3322;
ReqRealmFloodMsg.floodnum = 0; -- 灌注次数
ReqRealmFloodMsg.type = 0; -- 类型，1、经验，2、境界经验丹



ReqRealmFloodMsg.meta = {__index = ReqRealmFloodMsg };
function ReqRealmFloodMsg:new()
	local obj = setmetatable( {}, ReqRealmFloodMsg.meta);
	return obj;
end

function ReqRealmFloodMsg:encode()
	local body = "";

	body = body ..writeInt(self.floodnum);
	body = body ..writeInt(self.type);

	return body;
end

function ReqRealmFloodMsg:ParseData(pak)
	local idx = 1;

	self.floodnum, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
请求境界突破
]]
_G.ReqGoBreakMsg = {};

ReqGoBreakMsg.msgId = 3323;
ReqGoBreakMsg.autobuy = 0; -- 道具不足时是否自动购买, 0自动购买



ReqGoBreakMsg.meta = {__index = ReqGoBreakMsg };
function ReqGoBreakMsg:new()
	local obj = setmetatable( {}, ReqGoBreakMsg.meta);
	return obj;
end

function ReqGoBreakMsg:encode()
	local body = "";

	body = body ..writeInt(self.autobuy);

	return body;
end

function ReqGoBreakMsg:ParseData(pak)
	local idx = 1;

	self.autobuy, idx = readInt(pak, idx);

end



--[[
领奖退出
]]
_G.ReqBeicangjieQuitMsg = {};

ReqBeicangjieQuitMsg.msgId = 3331;



ReqBeicangjieQuitMsg.meta = {__index = ReqBeicangjieQuitMsg };
function ReqBeicangjieQuitMsg:new()
	local obj = setmetatable( {}, ReqBeicangjieQuitMsg.meta);
	return obj;
end

function ReqBeicangjieQuitMsg:encode()
	local body = "";


	return body;
end

function ReqBeicangjieQuitMsg:ParseData(pak)
	local idx = 1;


end



--[[
继续挑战
]]
_G.ReqBeicangjieConMsg = {};

ReqBeicangjieConMsg.msgId = 3332;



ReqBeicangjieConMsg.meta = {__index = ReqBeicangjieConMsg };
function ReqBeicangjieConMsg:new()
	local obj = setmetatable( {}, ReqBeicangjieConMsg.meta);
	return obj;
end

function ReqBeicangjieConMsg:encode()
	local body = "";


	return body;
end

function ReqBeicangjieConMsg:ParseData(pak)
	local idx = 1;


end



--[[
交换物品
]]
_G.ReqSpiritWarPrintSwapMsg = {};

ReqSpiritWarPrintSwapMsg.msgId = 3338;
ReqSpiritWarPrintSwapMsg.src_bag = 0; -- 源背包
ReqSpiritWarPrintSwapMsg.dst_bag = 0; -- 目标背包
ReqSpiritWarPrintSwapMsg.src_idx = 0; -- 源格子
ReqSpiritWarPrintSwapMsg.dst_idx = 0; -- 目标格子



ReqSpiritWarPrintSwapMsg.meta = {__index = ReqSpiritWarPrintSwapMsg };
function ReqSpiritWarPrintSwapMsg:new()
	local obj = setmetatable( {}, ReqSpiritWarPrintSwapMsg.meta);
	return obj;
end

function ReqSpiritWarPrintSwapMsg:encode()
	local body = "";

	body = body ..writeInt(self.src_bag);
	body = body ..writeInt(self.dst_bag);
	body = body ..writeInt(self.src_idx);
	body = body ..writeInt(self.dst_idx);

	return body;
end

function ReqSpiritWarPrintSwapMsg:ParseData(pak)
	local idx = 1;

	self.src_bag, idx = readInt(pak, idx);
	self.dst_bag, idx = readInt(pak, idx);
	self.src_idx, idx = readInt(pak, idx);
	self.dst_idx, idx = readInt(pak, idx);

end



--[[
请求一键吞噬 回发更新
]]
_G.ReqSpiritWarPrintAutoDevourMsg = {};

ReqSpiritWarPrintAutoDevourMsg.msgId = 3339;
ReqSpiritWarPrintAutoDevourMsg.pos = 0; -- 吞噬装备pos



ReqSpiritWarPrintAutoDevourMsg.meta = {__index = ReqSpiritWarPrintAutoDevourMsg };
function ReqSpiritWarPrintAutoDevourMsg:new()
	local obj = setmetatable( {}, ReqSpiritWarPrintAutoDevourMsg.meta);
	return obj;
end

function ReqSpiritWarPrintAutoDevourMsg:encode()
	local body = "";

	body = body ..writeInt(self.pos);

	return body;
end

function ReqSpiritWarPrintAutoDevourMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readInt(pak, idx);

end



--[[
请求吞噬 回发更新
]]
_G.ReqSpiritWarPrintDevourMsg = {};

ReqSpiritWarPrintDevourMsg.msgId = 3340;
ReqSpiritWarPrintDevourMsg.bagType = 0; -- 吞噬装备背包
ReqSpiritWarPrintDevourMsg.pos = 0; -- 吞噬装备
ReqSpiritWarPrintDevourMsg.BebagType = 0; -- 被吞噬装备背包
ReqSpiritWarPrintDevourMsg.Bepos = 0; -- 被吞噬



ReqSpiritWarPrintDevourMsg.meta = {__index = ReqSpiritWarPrintDevourMsg };
function ReqSpiritWarPrintDevourMsg:new()
	local obj = setmetatable( {}, ReqSpiritWarPrintDevourMsg.meta);
	return obj;
end

function ReqSpiritWarPrintDevourMsg:encode()
	local body = "";

	body = body ..writeInt(self.bagType);
	body = body ..writeInt(self.pos);
	body = body ..writeInt(self.BebagType);
	body = body ..writeInt(self.Bepos);

	return body;
end

function ReqSpiritWarPrintDevourMsg:ParseData(pak)
	local idx = 1;

	self.bagType, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);
	self.BebagType, idx = readInt(pak, idx);
	self.Bepos, idx = readInt(pak, idx);

end



--[[
请求分解
]]
_G.ReqSpiritWarPrintDebrisMsg = {};

ReqSpiritWarPrintDebrisMsg.msgId = 3341;
ReqSpiritWarPrintDebrisMsg.list_size = 0; -- 被分解装备 size
ReqSpiritWarPrintDebrisMsg.list = {}; -- 被分解装备 list

--[[
listvoVO = {
	pos = 0; -- 位置
}
]]

ReqSpiritWarPrintDebrisMsg.meta = {__index = ReqSpiritWarPrintDebrisMsg };
function ReqSpiritWarPrintDebrisMsg:new()
	local obj = setmetatable( {}, ReqSpiritWarPrintDebrisMsg.meta);
	return obj;
end

function ReqSpiritWarPrintDebrisMsg:encode()
	local body = "";


	local list1 = self.list;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeInt(list1[i1].pos);
	end

	return body;
end

function ReqSpiritWarPrintDebrisMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listvoVo = {};
		listvoVo.pos, idx = readInt(pak, idx);
		table.push(list1,listvoVo);
	end

end



--[[
购买
]]
_G.ReqSpiritWarPrintBuyMsg = {};

ReqSpiritWarPrintBuyMsg.msgId = 3342;
ReqSpiritWarPrintBuyMsg.type = 0; -- 花费类型，元宝，金币
ReqSpiritWarPrintBuyMsg.type2 = 0; -- 多次购买0=true ，



ReqSpiritWarPrintBuyMsg.meta = {__index = ReqSpiritWarPrintBuyMsg };
function ReqSpiritWarPrintBuyMsg:new()
	local obj = setmetatable( {}, ReqSpiritWarPrintBuyMsg.meta);
	return obj;
end

function ReqSpiritWarPrintBuyMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);
	body = body ..writeInt(self.type2);

	return body;
end

function ReqSpiritWarPrintBuyMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.type2, idx = readInt(pak, idx);

end



--[[
客户端请求:武魂
]]
_G.ReqQueryWuHunLingshouInfoMsg = {};

ReqQueryWuHunLingshouInfoMsg.msgId = 3344;



ReqQueryWuHunLingshouInfoMsg.meta = {__index = ReqQueryWuHunLingshouInfoMsg };
function ReqQueryWuHunLingshouInfoMsg:new()
	local obj = setmetatable( {}, ReqQueryWuHunLingshouInfoMsg.meta);
	return obj;
end

function ReqQueryWuHunLingshouInfoMsg:encode()
	local body = "";


	return body;
end

function ReqQueryWuHunLingshouInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求:武魂神兽
]]
_G.ReqQueryWuHunShenshouMsg = {};

ReqQueryWuHunShenshouMsg.msgId = 3345;



ReqQueryWuHunShenshouMsg.meta = {__index = ReqQueryWuHunShenshouMsg };
function ReqQueryWuHunShenshouMsg:new()
	local obj = setmetatable( {}, ReqQueryWuHunShenshouMsg.meta);
	return obj;
end

function ReqQueryWuHunShenshouMsg:encode()
	local body = "";


	return body;
end

function ReqQueryWuHunShenshouMsg:ParseData(pak)
	local idx = 1;


end



--[[
武魂神兽附身
]]
_G.ReqAdjunctionWuHunShenshouMsg = {};

ReqAdjunctionWuHunShenshouMsg.msgId = 3346;
ReqAdjunctionWuHunShenshouMsg.wuhunId = 0; -- 武魂神兽id
ReqAdjunctionWuHunShenshouMsg.wuhunFlag = 0; -- 武魂神兽附加标识，1表示附加，0表示卸下



ReqAdjunctionWuHunShenshouMsg.meta = {__index = ReqAdjunctionWuHunShenshouMsg };
function ReqAdjunctionWuHunShenshouMsg:new()
	local obj = setmetatable( {}, ReqAdjunctionWuHunShenshouMsg.meta);
	return obj;
end

function ReqAdjunctionWuHunShenshouMsg:encode()
	local body = "";

	body = body ..writeInt(self.wuhunId);
	body = body ..writeInt(self.wuhunFlag);

	return body;
end

function ReqAdjunctionWuHunShenshouMsg:ParseData(pak)
	local idx = 1;

	self.wuhunId, idx = readInt(pak, idx);
	self.wuhunFlag, idx = readInt(pak, idx);

end



--[[
请求激活武魂神兽
]]
_G.ReqAddWuHunShenshouMsg = {};

ReqAddWuHunShenshouMsg.msgId = 3347;
ReqAddWuHunShenshouMsg.wuhunId = 0; -- 武魂神兽id



ReqAddWuHunShenshouMsg.meta = {__index = ReqAddWuHunShenshouMsg };
function ReqAddWuHunShenshouMsg:new()
	local obj = setmetatable( {}, ReqAddWuHunShenshouMsg.meta);
	return obj;
end

function ReqAddWuHunShenshouMsg:encode()
	local body = "";

	body = body ..writeInt(self.wuhunId);

	return body;
end

function ReqAddWuHunShenshouMsg:ParseData(pak)
	local idx = 1;

	self.wuhunId, idx = readInt(pak, idx);

end



--[[
购买
]]
_G.ReqSpiritWarPrintBuyStoreMsg = {};

ReqSpiritWarPrintBuyStoreMsg.msgId = 3348;
ReqSpiritWarPrintBuyStoreMsg.tid = 0; -- 物品表id
ReqSpiritWarPrintBuyStoreMsg.num = 0; -- 数量



ReqSpiritWarPrintBuyStoreMsg.meta = {__index = ReqSpiritWarPrintBuyStoreMsg };
function ReqSpiritWarPrintBuyStoreMsg:new()
	local obj = setmetatable( {}, ReqSpiritWarPrintBuyStoreMsg.meta);
	return obj;
end

function ReqSpiritWarPrintBuyStoreMsg:encode()
	local body = "";

	body = body ..writeInt(self.tid);
	body = body ..writeInt(self.num);

	return body;
end

function ReqSpiritWarPrintBuyStoreMsg:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
客户端请求：宝甲进阶
]]
_G.ReqBaoJiaLevelUpMsg = {};

ReqBaoJiaLevelUpMsg.msgId = 3353;
ReqBaoJiaLevelUpMsg.autobuy = 0; -- 道具不足时是否自动购买, 0自动购买



ReqBaoJiaLevelUpMsg.meta = {__index = ReqBaoJiaLevelUpMsg };
function ReqBaoJiaLevelUpMsg:new()
	local obj = setmetatable( {}, ReqBaoJiaLevelUpMsg.meta);
	return obj;
end

function ReqBaoJiaLevelUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.autobuy);

	return body;
end

function ReqBaoJiaLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.autobuy, idx = readInt(pak, idx);

end



--[[
请求领取V等级礼包
]]
_G.ReqVLevelGiftMsg = {};

ReqVLevelGiftMsg.msgId = 3359;
ReqVLevelGiftMsg.levelGift_size = 0; -- 等级礼包 size
ReqVLevelGiftMsg.levelGift = {}; -- 等级礼包 list

--[[
VLevelGiftVOVO = {
	id = 0; -- 等级礼包id
}
]]

ReqVLevelGiftMsg.meta = {__index = ReqVLevelGiftMsg };
function ReqVLevelGiftMsg:new()
	local obj = setmetatable( {}, ReqVLevelGiftMsg.meta);
	return obj;
end

function ReqVLevelGiftMsg:encode()
	local body = "";


	local list1 = self.levelGift;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeInt(list1[i1].id);
	end

	return body;
end

function ReqVLevelGiftMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.levelGift = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local VLevelGiftVOVo = {};
		VLevelGiftVOVo.id, idx = readInt(pak, idx);
		table.push(list1,VLevelGiftVOVo);
	end

end



--[[
请求领取V每日礼包
]]
_G.ReqVDayGiftMsg = {};

ReqVDayGiftMsg.msgId = 3360;
ReqVDayGiftMsg.type = 0; -- 月费=1，年费=2



ReqVDayGiftMsg.meta = {__index = ReqVDayGiftMsg };
function ReqVDayGiftMsg:new()
	local obj = setmetatable( {}, ReqVDayGiftMsg.meta);
	return obj;
end

function ReqVDayGiftMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqVDayGiftMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
请求领取V首充礼包
]]
_G.ReqVVGiftMsg = {};

ReqVVGiftMsg.msgId = 3361;



ReqVVGiftMsg.meta = {__index = ReqVVGiftMsg };
function ReqVVGiftMsg:new()
	local obj = setmetatable( {}, ReqVVGiftMsg.meta);
	return obj;
end

function ReqVVGiftMsg:encode()
	local body = "";


	return body;
end

function ReqVVGiftMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求领取V年费礼包
]]
_G.ReqVYearGiftMsg = {};

ReqVYearGiftMsg.msgId = 3362;



ReqVYearGiftMsg.meta = {__index = ReqVYearGiftMsg };
function ReqVYearGiftMsg:new()
	local obj = setmetatable( {}, ReqVYearGiftMsg.meta);
	return obj;
end

function ReqVYearGiftMsg:encode()
	local body = "";


	return body;
end

function ReqVYearGiftMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求领取V称号
]]
_G.ReqVTitleMsg = {};

ReqVTitleMsg.msgId = 3363;
ReqVTitleMsg.type = 0; -- 1月费称号,2年费称号,3同时领取



ReqVTitleMsg.meta = {__index = ReqVTitleMsg };
function ReqVTitleMsg:new()
	local obj = setmetatable( {}, ReqVTitleMsg.meta);
	return obj;
end

function ReqVTitleMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqVTitleMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
请求徽章注灵
]]
_G.ReqHuiZhangPracticeMsg = {};

ReqHuiZhangPracticeMsg.msgId = 3366;
ReqHuiZhangPracticeMsg.type = 0; -- 0 普通注灵，1 vip注灵



ReqHuiZhangPracticeMsg.meta = {__index = ReqHuiZhangPracticeMsg };
function ReqHuiZhangPracticeMsg:new()
	local obj = setmetatable( {}, ReqHuiZhangPracticeMsg.meta);
	return obj;
end

function ReqHuiZhangPracticeMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqHuiZhangPracticeMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
请求突破徽章
]]
_G.ReqBreakHuiZhangMsg = {};

ReqBreakHuiZhangMsg.msgId = 3367;



ReqBreakHuiZhangMsg.meta = {__index = ReqBreakHuiZhangMsg };
function ReqBreakHuiZhangMsg:new()
	local obj = setmetatable( {}, ReqBreakHuiZhangMsg.meta);
	return obj;
end

function ReqBreakHuiZhangMsg:encode()
	local body = "";


	return body;
end

function ReqBreakHuiZhangMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求领取微端奖励
]]
_G.ReqMClientRewardMsg = {};

ReqMClientRewardMsg.msgId = 3368;



ReqMClientRewardMsg.meta = {__index = ReqMClientRewardMsg };
function ReqMClientRewardMsg:new()
	local obj = setmetatable( {}, ReqMClientRewardMsg.meta);
	return obj;
end

function ReqMClientRewardMsg:encode()
	local body = "";


	return body;
end

function ReqMClientRewardMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求获得聚灵灵力
]]
_G.ReqGetJuLingMsg = {};

ReqGetJuLingMsg.msgId = 3370;



ReqGetJuLingMsg.meta = {__index = ReqGetJuLingMsg };
function ReqGetJuLingMsg:new()
	local obj = setmetatable( {}, ReqGetJuLingMsg.meta);
	return obj;
end

function ReqGetJuLingMsg:encode()
	local body = "";


	return body;
end

function ReqGetJuLingMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求获得世界最高等阶
]]
_G.ReqGetRealmMaxMsg = {};

ReqGetRealmMaxMsg.msgId = 3371;



ReqGetRealmMaxMsg.meta = {__index = ReqGetRealmMaxMsg };
function ReqGetRealmMaxMsg:new()
	local obj = setmetatable( {}, ReqGetRealmMaxMsg.meta);
	return obj;
end

function ReqGetRealmMaxMsg:encode()
	local body = "";


	return body;
end

function ReqGetRealmMaxMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求成就信息
]]
_G.ReqGetAchievementInfoMsg = {};

ReqGetAchievementInfoMsg.msgId = 3372;



ReqGetAchievementInfoMsg.meta = {__index = ReqGetAchievementInfoMsg };
function ReqGetAchievementInfoMsg:new()
	local obj = setmetatable( {}, ReqGetAchievementInfoMsg.meta);
	return obj;
end

function ReqGetAchievementInfoMsg:encode()
	local body = "";


	return body;
end

function ReqGetAchievementInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求领取成就奖励
]]
_G.ReqGetAchievementRewardMsg = {};

ReqGetAchievementRewardMsg.msgId = 3373;
ReqGetAchievementRewardMsg.id = 0; -- 成就阶段ID



ReqGetAchievementRewardMsg.meta = {__index = ReqGetAchievementRewardMsg };
function ReqGetAchievementRewardMsg:new()
	local obj = setmetatable( {}, ReqGetAchievementRewardMsg.meta);
	return obj;
end

function ReqGetAchievementRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqGetAchievementRewardMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
请求领取阶段成就奖励
]]
_G.ReqGetAchievementPonitRewardMsg = {};

ReqGetAchievementPonitRewardMsg.msgId = 3374;
ReqGetAchievementPonitRewardMsg.id = 0; -- 成就阶段点数ID



ReqGetAchievementPonitRewardMsg.meta = {__index = ReqGetAchievementPonitRewardMsg };
function ReqGetAchievementPonitRewardMsg:new()
	local obj = setmetatable( {}, ReqGetAchievementPonitRewardMsg.meta);
	return obj;
end

function ReqGetAchievementPonitRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqGetAchievementPonitRewardMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
请求修改炼体该星级
]]
_G.ReqLianTiXingMsg = {};

ReqLianTiXingMsg.msgId = 3377;
ReqLianTiXingMsg.id = 0; -- 炼体id
ReqLianTiXingMsg.type = 0; -- 类型 1、道具和灵力，2、炼体丹



ReqLianTiXingMsg.meta = {__index = ReqLianTiXingMsg };
function ReqLianTiXingMsg:new()
	local obj = setmetatable( {}, ReqLianTiXingMsg.meta);
	return obj;
end

function ReqLianTiXingMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.type);

	return body;
end

function ReqLianTiXingMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
请求修改炼体升重
]]
_G.ReqLianTiLayerMsg = {};

ReqLianTiLayerMsg.msgId = 3378;
ReqLianTiLayerMsg.id = 0; -- 炼体id



ReqLianTiLayerMsg.meta = {__index = ReqLianTiLayerMsg };
function ReqLianTiLayerMsg:new()
	local obj = setmetatable( {}, ReqLianTiLayerMsg.meta);
	return obj;
end

function ReqLianTiLayerMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqLianTiLayerMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
从库中创建一个卓越卷轴
]]
_G.ReqCreateSuperItemMsg = {};

ReqCreateSuperItemMsg.msgId = 3385;
ReqCreateSuperItemMsg.uid = ""; -- 库属性uid



ReqCreateSuperItemMsg.meta = {__index = ReqCreateSuperItemMsg };
function ReqCreateSuperItemMsg:new()
	local obj = setmetatable( {}, ReqCreateSuperItemMsg.meta);
	return obj;
end

function ReqCreateSuperItemMsg:encode()
	local body = "";

	body = body ..writeGuid(self.uid);

	return body;
end

function ReqCreateSuperItemMsg:ParseData(pak)
	local idx = 1;

	self.uid, idx = readGuid(pak, idx);

end



--[[
请求装备打造
]]
_G.ReqEquipBuildStartMsg = {};

ReqEquipBuildStartMsg.msgId = 3387;
ReqEquipBuildStartMsg.id = 0; -- 图纸id
ReqEquipBuildStartMsg.isVip = 0; -- 是否vip锻造
ReqEquipBuildStartMsg.num = 0; -- 打造数量
ReqEquipBuildStartMsg.buildType = 0; -- 0=非绑，1=绑定，3=啥都行



ReqEquipBuildStartMsg.meta = {__index = ReqEquipBuildStartMsg };
function ReqEquipBuildStartMsg:new()
	local obj = setmetatable( {}, ReqEquipBuildStartMsg.meta);
	return obj;
end

function ReqEquipBuildStartMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.isVip);
	body = body ..writeInt(self.num);
	body = body ..writeInt(self.buildType);

	return body;
end

function ReqEquipBuildStartMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.isVip, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);
	self.buildType, idx = readInt(pak, idx);

end



--[[
请求分解装备
]]
_G.ReqEquipDecomposeMsg = {};

ReqEquipDecomposeMsg.msgId = 3388;
ReqEquipDecomposeMsg.equiplist_size = 0; -- 等待分解的装备list size
ReqEquipDecomposeMsg.equiplist = {}; -- 等待分解的装备list list

--[[
EquipVO = {
	guid = ""; -- 装备guid
}
]]

ReqEquipDecomposeMsg.meta = {__index = ReqEquipDecomposeMsg };
function ReqEquipDecomposeMsg:new()
	local obj = setmetatable( {}, ReqEquipDecomposeMsg.meta);
	return obj;
end

function ReqEquipDecomposeMsg:encode()
	local body = "";


	local list1 = self.equiplist;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeGuid(list1[i1].guid);
	end

	return body;
end

function ReqEquipDecomposeMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.equiplist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local EquipVo = {};
		EquipVo.guid, idx = readGuid(pak, idx);
		table.push(list1,EquipVo);
	end

end



--[[
请求UI信息
]]
_G.ReqDominateRouteMsg = {};

ReqDominateRouteMsg.msgId = 3390;



ReqDominateRouteMsg.meta = {__index = ReqDominateRouteMsg };
function ReqDominateRouteMsg:new()
	local obj = setmetatable( {}, ReqDominateRouteMsg.meta);
	return obj;
end

function ReqDominateRouteMsg:encode()
	local body = "";


	return body;
end

function ReqDominateRouteMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求挑战
]]
_G.ReqDominateRouteChallengeMsg = {};

ReqDominateRouteChallengeMsg.msgId = 3392;
ReqDominateRouteChallengeMsg.id = 0; -- 挑战ID



ReqDominateRouteChallengeMsg.meta = {__index = ReqDominateRouteChallengeMsg };
function ReqDominateRouteChallengeMsg:new()
	local obj = setmetatable( {}, ReqDominateRouteChallengeMsg.meta);
	return obj;
end

function ReqDominateRouteChallengeMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqDominateRouteChallengeMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
请求退出
]]
_G.ReqDominateRouteQuitMsg = {};

ReqDominateRouteQuitMsg.msgId = 3393;



ReqDominateRouteQuitMsg.meta = {__index = ReqDominateRouteQuitMsg };
function ReqDominateRouteQuitMsg:new()
	local obj = setmetatable( {}, ReqDominateRouteQuitMsg.meta);
	return obj;
end

function ReqDominateRouteQuitMsg:encode()
	local body = "";


	return body;
end

function ReqDominateRouteQuitMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求扫荡
]]
_G.ReqDominateRouteWipeMsg = {};

ReqDominateRouteWipeMsg.msgId = 3395;
ReqDominateRouteWipeMsg.id = 0; -- 扫荡ID
ReqDominateRouteWipeMsg.num = 0; -- 扫荡次数



ReqDominateRouteWipeMsg.meta = {__index = ReqDominateRouteWipeMsg };
function ReqDominateRouteWipeMsg:new()
	local obj = setmetatable( {}, ReqDominateRouteWipeMsg.meta);
	return obj;
end

function ReqDominateRouteWipeMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.num);

	return body;
end

function ReqDominateRouteWipeMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
请求购买精力
]]
_G.ReqDominateRouteVigorMsg = {};

ReqDominateRouteVigorMsg.msgId = 3396;



ReqDominateRouteVigorMsg.meta = {__index = ReqDominateRouteVigorMsg };
function ReqDominateRouteVigorMsg:new()
	local obj = setmetatable( {}, ReqDominateRouteVigorMsg.meta);
	return obj;
end

function ReqDominateRouteVigorMsg:encode()
	local body = "";


	return body;
end

function ReqDominateRouteVigorMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求领取宝箱奖励
]]
_G.ReqDominateRouteBoxRewardMsg = {};

ReqDominateRouteBoxRewardMsg.msgId = 3397;
ReqDominateRouteBoxRewardMsg.id = 0; -- 宝箱ID



ReqDominateRouteBoxRewardMsg.meta = {__index = ReqDominateRouteBoxRewardMsg };
function ReqDominateRouteBoxRewardMsg:new()
	local obj = setmetatable( {}, ReqDominateRouteBoxRewardMsg.meta);
	return obj;
end

function ReqDominateRouteBoxRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqDominateRouteBoxRewardMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
请求一键扫荡
]]
_G.ReqDominateRouteImmediatelyMsg = {};

ReqDominateRouteImmediatelyMsg.msgId = 3398;



ReqDominateRouteImmediatelyMsg.meta = {__index = ReqDominateRouteImmediatelyMsg };
function ReqDominateRouteImmediatelyMsg:new()
	local obj = setmetatable( {}, ReqDominateRouteImmediatelyMsg.meta);
	return obj;
end

function ReqDominateRouteImmediatelyMsg:encode()
	local body = "";


	return body;
end

function ReqDominateRouteImmediatelyMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求: 一键使用一类物品
]]
_G.ReqUseAllItemMsg = {};

ReqUseAllItemMsg.msgId = 3399;
ReqUseAllItemMsg.item_bag = 0; -- 背包
ReqUseAllItemMsg.itemlist_size = 0; -- 物品list size
ReqUseAllItemMsg.itemlist = {}; -- 物品list list

--[[
itemvoVO = {
	item_tid = 0; -- 物品tid
	item_count = 0; -- 使用数量
}
]]

ReqUseAllItemMsg.meta = {__index = ReqUseAllItemMsg };
function ReqUseAllItemMsg:new()
	local obj = setmetatable( {}, ReqUseAllItemMsg.meta);
	return obj;
end

function ReqUseAllItemMsg:encode()
	local body = "";

	body = body ..writeInt(self.item_bag);

	local list1 = self.itemlist;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeInt(list1[i1].item_tid);
		body = body .. writeInt(list1[i1].item_count);
	end

	return body;
end

function ReqUseAllItemMsg:ParseData(pak)
	local idx = 1;

	self.item_bag, idx = readInt(pak, idx);

	local list1 = {};
	self.itemlist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local itemvoVo = {};
		itemvoVo.item_tid, idx = readInt(pak, idx);
		itemvoVo.item_count, idx = readInt(pak, idx);
		table.push(list1,itemvoVo);
	end

end



--[[
客户端请求:升级炼化装备
]]
_G.ReqEquipRefininglvlUpMsg = {};

ReqEquipRefininglvlUpMsg.msgId = 3403;
ReqEquipRefininglvlUpMsg.pos = 0; -- pos



ReqEquipRefininglvlUpMsg.meta = {__index = ReqEquipRefininglvlUpMsg };
function ReqEquipRefininglvlUpMsg:new()
	local obj = setmetatable( {}, ReqEquipRefininglvlUpMsg.meta);
	return obj;
end

function ReqEquipRefininglvlUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.pos);

	return body;
end

function ReqEquipRefininglvlUpMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readInt(pak, idx);

end



--[[
客户端请求:升级一键炼化装备
]]
_G.ReqEquipRefiningAutolvlUpMsg = {};

ReqEquipRefiningAutolvlUpMsg.msgId = 3404;



ReqEquipRefiningAutolvlUpMsg.meta = {__index = ReqEquipRefiningAutolvlUpMsg };
function ReqEquipRefiningAutolvlUpMsg:new()
	local obj = setmetatable( {}, ReqEquipRefiningAutolvlUpMsg.meta);
	return obj;
end

function ReqEquipRefiningAutolvlUpMsg:encode()
	local body = "";


	return body;
end

function ReqEquipRefiningAutolvlUpMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求:退出兽魄副本
]]
_G.ReqExitWuhunDungeonMsg = {};

ReqExitWuhunDungeonMsg.msgId = 3410;



ReqExitWuhunDungeonMsg.meta = {__index = ReqExitWuhunDungeonMsg };
function ReqExitWuhunDungeonMsg:new()
	local obj = setmetatable( {}, ReqExitWuhunDungeonMsg.meta);
	return obj;
end

function ReqExitWuhunDungeonMsg:encode()
	local body = "";


	return body;
end

function ReqExitWuhunDungeonMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：灵阵进阶
]]
_G.ReqLingzhenLevelUpMsg = {};

ReqLingzhenLevelUpMsg.msgId = 3414;
ReqLingzhenLevelUpMsg.autobuy = 0; -- 道具不足时是否自动购买, 0自动购买



ReqLingzhenLevelUpMsg.meta = {__index = ReqLingzhenLevelUpMsg };
function ReqLingzhenLevelUpMsg:new()
	local obj = setmetatable( {}, ReqLingzhenLevelUpMsg.meta);
	return obj;
end

function ReqLingzhenLevelUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.autobuy);

	return body;
end

function ReqLingzhenLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.autobuy, idx = readInt(pak, idx);

end



--[[
客户端请求：请求进入data
]]
_G.ReqExtremityEnterDataMsg = {};

ReqExtremityEnterDataMsg.msgId = 3416;
ReqExtremityEnterDataMsg.state = 0; -- 进入模式 1 BOSS 2 小怪 



ReqExtremityEnterDataMsg.meta = {__index = ReqExtremityEnterDataMsg };
function ReqExtremityEnterDataMsg:new()
	local obj = setmetatable( {}, ReqExtremityEnterDataMsg.meta);
	return obj;
end

function ReqExtremityEnterDataMsg:encode()
	local body = "";

	body = body ..writeInt(self.state);

	return body;
end

function ReqExtremityEnterDataMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);

end



--[[
客户端请求：请求退出
]]
_G.ReqExtremityQuitMsg = {};

ReqExtremityQuitMsg.msgId = 3420;



ReqExtremityQuitMsg.meta = {__index = ReqExtremityQuitMsg };
function ReqExtremityQuitMsg:new()
	local obj = setmetatable( {}, ReqExtremityQuitMsg.meta);
	return obj;
end

function ReqExtremityQuitMsg:encode()
	local body = "";


	return body;
end

function ReqExtremityQuitMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：灵兽墓地信息
]]
_G.ReqLingShouMuDiInfoMsg = {};

ReqLingShouMuDiInfoMsg.msgId = 3421;



ReqLingShouMuDiInfoMsg.meta = {__index = ReqLingShouMuDiInfoMsg };
function ReqLingShouMuDiInfoMsg:new()
	local obj = setmetatable( {}, ReqLingShouMuDiInfoMsg.meta);
	return obj;
end

function ReqLingShouMuDiInfoMsg:encode()
	local body = "";


	return body;
end

function ReqLingShouMuDiInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：挑战灵兽墓地
]]
_G.ReqChallLingShouMuDiMsg = {};

ReqChallLingShouMuDiMsg.msgId = 3422;
ReqChallLingShouMuDiMsg.layer = 0; -- 挑战层数



ReqChallLingShouMuDiMsg.meta = {__index = ReqChallLingShouMuDiMsg };
function ReqChallLingShouMuDiMsg:new()
	local obj = setmetatable( {}, ReqChallLingShouMuDiMsg.meta);
	return obj;
end

function ReqChallLingShouMuDiMsg:encode()
	local body = "";

	body = body ..writeInt(self.layer);

	return body;
end

function ReqChallLingShouMuDiMsg:ParseData(pak)
	local idx = 1;

	self.layer, idx = readInt(pak, idx);

end



--[[
客户端请求：获得奖励
]]
_G.ReqLSMDGetAwardMsg = {};

ReqLSMDGetAwardMsg.msgId = 3425;



ReqLSMDGetAwardMsg.meta = {__index = ReqLSMDGetAwardMsg };
function ReqLSMDGetAwardMsg:new()
	local obj = setmetatable( {}, ReqLSMDGetAwardMsg.meta);
	return obj;
end

function ReqLSMDGetAwardMsg:encode()
	local body = "";


	return body;
end

function ReqLSMDGetAwardMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：灵兽墓地排行榜
]]
_G.ReqLingShouMuDiRanklistMsg = {};

ReqLingShouMuDiRanklistMsg.msgId = 3426;



ReqLingShouMuDiRanklistMsg.meta = {__index = ReqLingShouMuDiRanklistMsg };
function ReqLingShouMuDiRanklistMsg:new()
	local obj = setmetatable( {}, ReqLingShouMuDiRanklistMsg.meta);
	return obj;
end

function ReqLingShouMuDiRanklistMsg:encode()
	local body = "";


	return body;
end

function ReqLingShouMuDiRanklistMsg:ParseData(pak)
	local idx = 1;


end



--[[
设置技能栏物品
]]
_G.ReqItemShortCutMsg = {};

ReqItemShortCutMsg.msgId = 3427;
ReqItemShortCutMsg.itemId = 0; -- 物品id



ReqItemShortCutMsg.meta = {__index = ReqItemShortCutMsg };
function ReqItemShortCutMsg:new()
	local obj = setmetatable( {}, ReqItemShortCutMsg.meta);
	return obj;
end

function ReqItemShortCutMsg:encode()
	local body = "";

	body = body ..writeInt(self.itemId);

	return body;
end

function ReqItemShortCutMsg:ParseData(pak)
	local idx = 1;

	self.itemId, idx = readInt(pak, idx);

end



--[[
客户端请求：激活萌宠
]]
_G.ReqActiveLovelyPetMsg = {};

ReqActiveLovelyPetMsg.msgId = 3429;
ReqActiveLovelyPetMsg.id = 0; -- 萌宠id



ReqActiveLovelyPetMsg.meta = {__index = ReqActiveLovelyPetMsg };
function ReqActiveLovelyPetMsg:new()
	local obj = setmetatable( {}, ReqActiveLovelyPetMsg.meta);
	return obj;
end

function ReqActiveLovelyPetMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqActiveLovelyPetMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
客户端请求：派出萌宠或者休息
]]
_G.ReqSendLovelyPetMsg = {};

ReqSendLovelyPetMsg.msgId = 3431;
ReqSendLovelyPetMsg.id = 0; -- 萌宠id
ReqSendLovelyPetMsg.state = 0; -- 1休息，2出战



ReqSendLovelyPetMsg.meta = {__index = ReqSendLovelyPetMsg };
function ReqSendLovelyPetMsg:new()
	local obj = setmetatable( {}, ReqSendLovelyPetMsg.meta);
	return obj;
end

function ReqSendLovelyPetMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.state);

	return body;
end

function ReqSendLovelyPetMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
客户端请求：退出灵兽墓地
]]
_G.ReqLingShouMuDiQuitMsg = {};

ReqLingShouMuDiQuitMsg.msgId = 3432;



ReqLingShouMuDiQuitMsg.meta = {__index = ReqLingShouMuDiQuitMsg };
function ReqLingShouMuDiQuitMsg:new()
	local obj = setmetatable( {}, ReqLingShouMuDiQuitMsg.meta);
	return obj;
end

function ReqLingShouMuDiQuitMsg:encode()
	local body = "";


	return body;
end

function ReqLingShouMuDiQuitMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：续费萌宠
]]
_G.ReqRenewLovelyPetMsg = {};

ReqRenewLovelyPetMsg.msgId = 3433;
ReqRenewLovelyPetMsg.id = 0; -- 萌宠id
ReqRenewLovelyPetMsg.type = 0; -- 0-道具，1-元宝



ReqRenewLovelyPetMsg.meta = {__index = ReqRenewLovelyPetMsg };
function ReqRenewLovelyPetMsg:new()
	local obj = setmetatable( {}, ReqRenewLovelyPetMsg.meta);
	return obj;
end

function ReqRenewLovelyPetMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.type);

	return body;
end

function ReqRenewLovelyPetMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
客户端请求：流水副本信息
]]
_G.ReqWaterDungeonInfoMsg = {};

ReqWaterDungeonInfoMsg.msgId = 3434;



ReqWaterDungeonInfoMsg.meta = {__index = ReqWaterDungeonInfoMsg };
function ReqWaterDungeonInfoMsg:new()
	local obj = setmetatable( {}, ReqWaterDungeonInfoMsg.meta);
	return obj;
end

function ReqWaterDungeonInfoMsg:encode()
	local body = "";


	return body;
end

function ReqWaterDungeonInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：流水副本排行榜
]]
_G.ReqWaterDungeonRankMsg = {};

ReqWaterDungeonRankMsg.msgId = 3435;



ReqWaterDungeonRankMsg.meta = {__index = ReqWaterDungeonRankMsg };
function ReqWaterDungeonRankMsg:new()
	local obj = setmetatable( {}, ReqWaterDungeonRankMsg.meta);
	return obj;
end

function ReqWaterDungeonRankMsg:encode()
	local body = "";


	return body;
end

function ReqWaterDungeonRankMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：购买祈愿
]]
_G.ReqBuyWishItemMsg = {};

ReqBuyWishItemMsg.msgId = 3438;
ReqBuyWishItemMsg.type = 0; -- 类型，发itemID



ReqBuyWishItemMsg.meta = {__index = ReqBuyWishItemMsg };
function ReqBuyWishItemMsg:new()
	local obj = setmetatable( {}, ReqBuyWishItemMsg.meta);
	return obj;
end

function ReqBuyWishItemMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqBuyWishItemMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
客户端请求：进入流水副本
]]
_G.ReqWaterDungeonEnterMsg = {};

ReqWaterDungeonEnterMsg.msgId = 3439;



ReqWaterDungeonEnterMsg.meta = {__index = ReqWaterDungeonEnterMsg };
function ReqWaterDungeonEnterMsg:new()
	local obj = setmetatable( {}, ReqWaterDungeonEnterMsg.meta);
	return obj;
end

function ReqWaterDungeonEnterMsg:encode()
	local body = "";


	return body;
end

function ReqWaterDungeonEnterMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：退出流水副本
]]
_G.ReqWaterDungeonExitMsg = {};

ReqWaterDungeonExitMsg.msgId = 3440;



ReqWaterDungeonExitMsg.meta = {__index = ReqWaterDungeonExitMsg };
function ReqWaterDungeonExitMsg:new()
	local obj = setmetatable( {}, ReqWaterDungeonExitMsg.meta);
	return obj;
end

function ReqWaterDungeonExitMsg:encode()
	local body = "";


	return body;
end

function ReqWaterDungeonExitMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：神兵换模型
]]
_G.ReqMagicWeaponChangeModelMsg = {};

ReqMagicWeaponChangeModelMsg.msgId = 3456;
ReqMagicWeaponChangeModelMsg.level = 0; -- 请求更换模型的等阶(即配表ID)



ReqMagicWeaponChangeModelMsg.meta = {__index = ReqMagicWeaponChangeModelMsg };
function ReqMagicWeaponChangeModelMsg:new()
	local obj = setmetatable( {}, ReqMagicWeaponChangeModelMsg.meta);
	return obj;
end

function ReqMagicWeaponChangeModelMsg:encode()
	local body = "";

	body = body ..writeInt(self.level);

	return body;
end

function ReqMagicWeaponChangeModelMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);

end



--[[
客户端请求:续费(激活)vip
]]
_G.ReqVipRenewMsg = {};

ReqVipRenewMsg.msgId = 3461;
ReqVipRenewMsg.vipType = 0; -- vip类型id(黄金1/钻石2/至尊3)



ReqVipRenewMsg.meta = {__index = ReqVipRenewMsg };
function ReqVipRenewMsg:new()
	local obj = setmetatable( {}, ReqVipRenewMsg.meta);
	return obj;
end

function ReqVipRenewMsg:encode()
	local body = "";

	body = body ..writeInt(self.vipType);

	return body;
end

function ReqVipRenewMsg:ParseData(pak)
	local idx = 1;

	self.vipType, idx = readInt(pak, idx);

end



--[[
客户端请求:领取vip等级奖励
]]
_G.ReqVipLevelRewardAcceptMsg = {};

ReqVipLevelRewardAcceptMsg.msgId = 3462;
ReqVipLevelRewardAcceptMsg.vipLevel = 0; -- 奖励对应的vip等级



ReqVipLevelRewardAcceptMsg.meta = {__index = ReqVipLevelRewardAcceptMsg };
function ReqVipLevelRewardAcceptMsg:new()
	local obj = setmetatable( {}, ReqVipLevelRewardAcceptMsg.meta);
	return obj;
end

function ReqVipLevelRewardAcceptMsg:encode()
	local body = "";

	body = body ..writeInt(self.vipLevel);

	return body;
end

function ReqVipLevelRewardAcceptMsg:ParseData(pak)
	local idx = 1;

	self.vipLevel, idx = readInt(pak, idx);

end



--[[
客户端请求:领取vip每周奖励
]]
_G.ReqVipWeekRewardAcceptMsg = {};

ReqVipWeekRewardAcceptMsg.msgId = 3463;



ReqVipWeekRewardAcceptMsg.meta = {__index = ReqVipWeekRewardAcceptMsg };
function ReqVipWeekRewardAcceptMsg:new()
	local obj = setmetatable( {}, ReqVipWeekRewardAcceptMsg.meta);
	return obj;
end

function ReqVipWeekRewardAcceptMsg:encode()
	local body = "";


	return body;
end

function ReqVipWeekRewardAcceptMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：翅膀合成
]]
_G.ReqWingHeChengMsg = {};

ReqWingHeChengMsg.msgId = 3464;
ReqWingHeChengMsg.wingid = 0; -- 翅膀id
ReqWingHeChengMsg.list_size = 0; -- 提高成功率道具列表 size
ReqWingHeChengMsg.list = {}; -- 提高成功率道具列表 list

--[[
listVO = {
	id = 0; -- 道具id
}
]]

ReqWingHeChengMsg.meta = {__index = ReqWingHeChengMsg };
function ReqWingHeChengMsg:new()
	local obj = setmetatable( {}, ReqWingHeChengMsg.meta);
	return obj;
end

function ReqWingHeChengMsg:encode()
	local body = "";

	body = body ..writeInt(self.wingid);

	local list1 = self.list;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeInt(list1[i1].id);
	end

	return body;
end

function ReqWingHeChengMsg:ParseData(pak)
	local idx = 1;

	self.wingid, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listVo = {};
		listVo.id, idx = readInt(pak, idx);
		table.push(list1,listVo);
	end

end



--[[
客户端请求：设置装备套装
]]
_G.ReqEquipGroupMsg = {};

ReqEquipGroupMsg.msgId = 3465;
ReqEquipGroupMsg.equipId = ""; -- 装备uid
ReqEquipGroupMsg.itemId = ""; -- 物品uid



ReqEquipGroupMsg.meta = {__index = ReqEquipGroupMsg };
function ReqEquipGroupMsg:new()
	local obj = setmetatable( {}, ReqEquipGroupMsg.meta);
	return obj;
end

function ReqEquipGroupMsg:encode()
	local body = "";

	body = body ..writeGuid(self.equipId);
	body = body ..writeGuid(self.itemId);

	return body;
end

function ReqEquipGroupMsg:ParseData(pak)
	local idx = 1;

	self.equipId, idx = readGuid(pak, idx);
	self.itemId, idx = readGuid(pak, idx);

end



--[[
客户端请求:完成奇遇任务
]]
_G.ReqRandomQuestCompleteMsg = {};

ReqRandomQuestCompleteMsg.msgId = 3468;
ReqRandomQuestCompleteMsg.id = 0; -- 奇遇任务id



ReqRandomQuestCompleteMsg.meta = {__index = ReqRandomQuestCompleteMsg };
function ReqRandomQuestCompleteMsg:new()
	local obj = setmetatable( {}, ReqRandomQuestCompleteMsg.meta);
	return obj;
end

function ReqRandomQuestCompleteMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqRandomQuestCompleteMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
客户端请求:退出奇遇副本
]]
_G.ReqRandomDungeonExitMsg = {};

ReqRandomDungeonExitMsg.msgId = 3470;



ReqRandomDungeonExitMsg.meta = {__index = ReqRandomDungeonExitMsg };
function ReqRandomDungeonExitMsg:new()
	local obj = setmetatable( {}, ReqRandomDungeonExitMsg.meta);
	return obj;
end

function ReqRandomDungeonExitMsg:encode()
	local body = "";


	return body;
end

function ReqRandomDungeonExitMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求:奇遇副本步骤完成
]]
_G.ReqRandomDungeonStepMsg = {};

ReqRandomDungeonStepMsg.msgId = 3471;
ReqRandomDungeonStepMsg.step = 0; -- 步骤



ReqRandomDungeonStepMsg.meta = {__index = ReqRandomDungeonStepMsg };
function ReqRandomDungeonStepMsg:new()
	local obj = setmetatable( {}, ReqRandomDungeonStepMsg.meta);
	return obj;
end

function ReqRandomDungeonStepMsg:encode()
	local body = "";

	body = body ..writeInt(self.step);

	return body;
end

function ReqRandomDungeonStepMsg:ParseData(pak)
	local idx = 1;

	self.step, idx = readInt(pak, idx);

end



--[[
客户端请求:奇遇副本步骤内容提交(答题)
]]
_G.ReqRandomDungeonStepSubmitMsg = {};

ReqRandomDungeonStepSubmitMsg.msgId = 3473;
ReqRandomDungeonStepSubmitMsg.reply = 0; -- 回应内容索引



ReqRandomDungeonStepSubmitMsg.meta = {__index = ReqRandomDungeonStepSubmitMsg };
function ReqRandomDungeonStepSubmitMsg:new()
	local obj = setmetatable( {}, ReqRandomDungeonStepSubmitMsg.meta);
	return obj;
end

function ReqRandomDungeonStepSubmitMsg:encode()
	local body = "";

	body = body ..writeInt(self.reply);

	return body;
end

function ReqRandomDungeonStepSubmitMsg:ParseData(pak)
	local idx = 1;

	self.reply, idx = readInt(pak, idx);

end



--[[
客户端请求:奇遇任务领奖
]]
_G.ReqRandomQuestRewardMsg = {};

ReqRandomQuestRewardMsg.msgId = 3474;
ReqRandomQuestRewardMsg.id = 0; -- 奇遇任务id



ReqRandomQuestRewardMsg.meta = {__index = ReqRandomQuestRewardMsg };
function ReqRandomQuestRewardMsg:new()
	local obj = setmetatable( {}, ReqRandomQuestRewardMsg.meta);
	return obj;
end

function ReqRandomQuestRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqRandomQuestRewardMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
客户端请求：寻宝任务接取
]]
_G.ReqFindTreasureMsg = {};

ReqFindTreasureMsg.msgId = 3476;
ReqFindTreasureMsg.quality = 0; -- 寻宝图quality



ReqFindTreasureMsg.meta = {__index = ReqFindTreasureMsg };
function ReqFindTreasureMsg:new()
	local obj = setmetatable( {}, ReqFindTreasureMsg.meta);
	return obj;
end

function ReqFindTreasureMsg:encode()
	local body = "";

	body = body ..writeInt(self.quality);

	return body;
end

function ReqFindTreasureMsg:ParseData(pak)
	local idx = 1;

	self.quality, idx = readInt(pak, idx);

end



--[[
客户端请求：取消寻宝任务
]]
_G.ReqFindTreasureCancelMsg = {};

ReqFindTreasureCancelMsg.msgId = 3477;



ReqFindTreasureCancelMsg.meta = {__index = ReqFindTreasureCancelMsg };
function ReqFindTreasureCancelMsg:new()
	local obj = setmetatable( {}, ReqFindTreasureCancelMsg.meta);
	return obj;
end

function ReqFindTreasureCancelMsg:encode()
	local body = "";


	return body;
end

function ReqFindTreasureCancelMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：接取
]]
_G.ReqFindTreasureCollectMsg = {};

ReqFindTreasureCollectMsg.msgId = 3478;
ReqFindTreasureCollectMsg.type = 0; -- 0请求一键挖宝



ReqFindTreasureCollectMsg.meta = {__index = ReqFindTreasureCollectMsg };
function ReqFindTreasureCollectMsg:new()
	local obj = setmetatable( {}, ReqFindTreasureCollectMsg.meta);
	return obj;
end

function ReqFindTreasureCollectMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqFindTreasureCollectMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
武魂出战
]]
_G.ReqWuHunBattleMsg = {};

ReqWuHunBattleMsg.msgId = 3480;
ReqWuHunBattleMsg.wuhunId = 0; -- 武魂id
ReqWuHunBattleMsg.wuhunFlag = 0; -- 武魂出战，1表示出战，0表示卸下



ReqWuHunBattleMsg.meta = {__index = ReqWuHunBattleMsg };
function ReqWuHunBattleMsg:new()
	local obj = setmetatable( {}, ReqWuHunBattleMsg.meta);
	return obj;
end

function ReqWuHunBattleMsg:encode()
	local body = "";

	body = body ..writeInt(self.wuhunId);
	body = body ..writeInt(self.wuhunFlag);

	return body;
end

function ReqWuHunBattleMsg:ParseData(pak)
	local idx = 1;

	self.wuhunId, idx = readInt(pak, idx);
	self.wuhunFlag, idx = readInt(pak, idx);

end



--[[
领取卓越引导奖励
]]
_G.ReqZhuoyueGuideRewardMsg = {};

ReqZhuoyueGuideRewardMsg.msgId = 3482;
ReqZhuoyueGuideRewardMsg.id = 0; -- 阶段id



ReqZhuoyueGuideRewardMsg.meta = {__index = ReqZhuoyueGuideRewardMsg };
function ReqZhuoyueGuideRewardMsg:new()
	local obj = setmetatable( {}, ReqZhuoyueGuideRewardMsg.meta);
	return obj;
end

function ReqZhuoyueGuideRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqZhuoyueGuideRewardMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
发送挂机状态
]]
_G.ReqHangStateMsg = {};

ReqHangStateMsg.msgId = 3483;
ReqHangStateMsg.hangState = 0; -- 1开启0关闭



ReqHangStateMsg.meta = {__index = ReqHangStateMsg };
function ReqHangStateMsg:new()
	local obj = setmetatable( {}, ReqHangStateMsg.meta);
	return obj;
end

function ReqHangStateMsg:encode()
	local body = "";

	body = body ..writeInt(self.hangState);

	return body;
end

function ReqHangStateMsg:ParseData(pak)
	local idx = 1;

	self.hangState, idx = readInt(pak, idx);

end



--[[
请求领取七日登录奖励
]]
_G.ReqWeedSignMsg = {};

ReqWeedSignMsg.msgId = 3484;
ReqWeedSignMsg.signID = 0; -- 日期id



ReqWeedSignMsg.meta = {__index = ReqWeedSignMsg };
function ReqWeedSignMsg:new()
	local obj = setmetatable( {}, ReqWeedSignMsg.meta);
	return obj;
end

function ReqWeedSignMsg:encode()
	local body = "";

	body = body ..writeInt(self.signID);

	return body;
end

function ReqWeedSignMsg:ParseData(pak)
	local idx = 1;

	self.signID, idx = readInt(pak, idx);

end



--[[
确认进入帮派boss活动
]]
_G.ReqUnionBossActivitySureEnterMsg = {};

ReqUnionBossActivitySureEnterMsg.msgId = 3491;



ReqUnionBossActivitySureEnterMsg.meta = {__index = ReqUnionBossActivitySureEnterMsg };
function ReqUnionBossActivitySureEnterMsg:new()
	local obj = setmetatable( {}, ReqUnionBossActivitySureEnterMsg.meta);
	return obj;
end

function ReqUnionBossActivitySureEnterMsg:encode()
	local body = "";


	return body;
end

function ReqUnionBossActivitySureEnterMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求退出帮派boss活动
]]
_G.ReqUnionBossActivityOutMsg = {};

ReqUnionBossActivityOutMsg.msgId = 3492;



ReqUnionBossActivityOutMsg.meta = {__index = ReqUnionBossActivityOutMsg };
function ReqUnionBossActivityOutMsg:new()
	local obj = setmetatable( {}, ReqUnionBossActivityOutMsg.meta);
	return obj;
end

function ReqUnionBossActivityOutMsg:encode()
	local body = "";


	return body;
end

function ReqUnionBossActivityOutMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求进入跨服服务器
]]
_G.ReqConCrossFightMsg = {};

ReqConCrossFightMsg.msgId = 4001;
ReqConCrossFightMsg.guid = ""; -- 玩家GUID
ReqConCrossFightMsg.accountID = ""; -- 玩家ID
ReqConCrossFightMsg.sign = ""; -- MD5



ReqConCrossFightMsg.meta = {__index = ReqConCrossFightMsg };
function ReqConCrossFightMsg:new()
	local obj = setmetatable( {}, ReqConCrossFightMsg.meta);
	return obj;
end

function ReqConCrossFightMsg:encode()
	local body = "";

	body = body ..writeGuid(self.guid);
	body = body ..writeString(self.accountID,64);
	body = body ..writeString(self.sign,33);

	return body;
end

function ReqConCrossFightMsg:ParseData(pak)
	local idx = 1;

	self.guid, idx = readGuid(pak, idx);
	self.accountID, idx = readString(pak, idx, 64);
	self.sign, idx = readString(pak, idx, 33);

end



--[[
请求流水副本奖励类型
]]
_G.ReqWaterDungeonRewardMsg = {};

ReqWaterDungeonRewardMsg.msgId = 3500;
ReqWaterDungeonRewardMsg.type = 0; -- 请求领取奖励类型



ReqWaterDungeonRewardMsg.meta = {__index = ReqWaterDungeonRewardMsg };
function ReqWaterDungeonRewardMsg:new()
	local obj = setmetatable( {}, ReqWaterDungeonRewardMsg.meta);
	return obj;
end

function ReqWaterDungeonRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqWaterDungeonRewardMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
请求vip返还信息
]]
_G.ReqVipBackInfoMsg = {};

ReqVipBackInfoMsg.msgId = 3502;
ReqVipBackInfoMsg.backType = 0; -- 返回类型 1返还坐骑升阶消耗的灵力2返还灵兽进阶的道具3装备强化灵力返还4境界返还



ReqVipBackInfoMsg.meta = {__index = ReqVipBackInfoMsg };
function ReqVipBackInfoMsg:new()
	local obj = setmetatable( {}, ReqVipBackInfoMsg.meta);
	return obj;
end

function ReqVipBackInfoMsg:encode()
	local body = "";

	body = body ..writeInt(self.backType);

	return body;
end

function ReqVipBackInfoMsg:ParseData(pak)
	local idx = 1;

	self.backType, idx = readInt(pak, idx);

end



--[[
请求vip返还
]]
_G.ReqGetVipBackMsg = {};

ReqGetVipBackMsg.msgId = 3503;
ReqGetVipBackMsg.backType = 0; -- 返回类型



ReqGetVipBackMsg.meta = {__index = ReqGetVipBackMsg };
function ReqGetVipBackMsg:new()
	local obj = setmetatable( {}, ReqGetVipBackMsg.meta);
	return obj;
end

function ReqGetVipBackMsg:encode()
	local body = "";

	body = body ..writeInt(self.backType);

	return body;
end

function ReqGetVipBackMsg:ParseData(pak)
	local idx = 1;

	self.backType, idx = readInt(pak, idx);

end



--[[
请求进入跨服战斗
]]
_G.ReqEnterCrossFightMsg = {};

ReqEnterCrossFightMsg.msgId = 4002;



ReqEnterCrossFightMsg.meta = {__index = ReqEnterCrossFightMsg };
function ReqEnterCrossFightMsg:new()
	local obj = setmetatable( {}, ReqEnterCrossFightMsg.meta);
	return obj;
end

function ReqEnterCrossFightMsg:encode()
	local body = "";


	return body;
end

function ReqEnterCrossFightMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求在活动时长
]]
_G.ReqActivityOnlineTimeMsg = {};

ReqActivityOnlineTimeMsg.msgId = 3505;
ReqActivityOnlineTimeMsg.id = 0; -- 活动id



ReqActivityOnlineTimeMsg.meta = {__index = ReqActivityOnlineTimeMsg };
function ReqActivityOnlineTimeMsg:new()
	local obj = setmetatable( {}, ReqActivityOnlineTimeMsg.meta);
	return obj;
end

function ReqActivityOnlineTimeMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqActivityOnlineTimeMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
请求退出跨服PVP1
]]
_G.ReqQuitCrossFightPvpMsg = {};

ReqQuitCrossFightPvpMsg.msgId = 3508;



ReqQuitCrossFightPvpMsg.meta = {__index = ReqQuitCrossFightPvpMsg };
function ReqQuitCrossFightPvpMsg:new()
	local obj = setmetatable( {}, ReqQuitCrossFightPvpMsg.meta);
	return obj;
end

function ReqQuitCrossFightPvpMsg:encode()
	local body = "";


	return body;
end

function ReqQuitCrossFightPvpMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求360加速球奖励
]]
_G.ReqQihooQuickMsg = {};

ReqQihooQuickMsg.msgId = 3510;



ReqQihooQuickMsg.meta = {__index = ReqQihooQuickMsg };
function ReqQihooQuickMsg:new()
	local obj = setmetatable( {}, ReqQihooQuickMsg.meta);
	return obj;
end

function ReqQihooQuickMsg:encode()
	local body = "";


	return body;
end

function ReqQihooQuickMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求特权奖励
]]
_G.ReqPrerogativeRewardMsg = {};

ReqPrerogativeRewardMsg.msgId = 3512;
ReqPrerogativeRewardMsg.type = 0; -- 类型, 1:卫士特权 2:游戏大厅 3:特权加速礼包
ReqPrerogativeRewardMsg.param = 0; -- 参数, 等级, 天数...



ReqPrerogativeRewardMsg.meta = {__index = ReqPrerogativeRewardMsg };
function ReqPrerogativeRewardMsg:new()
	local obj = setmetatable( {}, ReqPrerogativeRewardMsg.meta);
	return obj;
end

function ReqPrerogativeRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);
	body = body ..writeInt(self.param);

	return body;
end

function ReqPrerogativeRewardMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.param, idx = readInt(pak, idx);

end



--[[
请求装备熔炼
]]
_G.ReqEquipSmeltMsg = {};

ReqEquipSmeltMsg.msgId = 3514;
ReqEquipSmeltMsg.flags = 0; -- 熔炼品质
ReqEquipSmeltMsg.smeltlist_size = 0; -- 装备熔炼list size
ReqEquipSmeltMsg.smeltlist = {}; -- 装备熔炼list list

--[[
SmeltVO = {
	guid = ""; -- 道具guid
}
]]

ReqEquipSmeltMsg.meta = {__index = ReqEquipSmeltMsg };
function ReqEquipSmeltMsg:new()
	local obj = setmetatable( {}, ReqEquipSmeltMsg.meta);
	return obj;
end

function ReqEquipSmeltMsg:encode()
	local body = "";

	body = body ..writeInt(self.flags);

	local list1 = self.smeltlist;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeGuid(list1[i1].guid);
	end

	return body;
end

function ReqEquipSmeltMsg:ParseData(pak)
	local idx = 1;

	self.flags, idx = readInt(pak, idx);

	local list1 = {};
	self.smeltlist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local SmeltVo = {};
		SmeltVo.guid, idx = readGuid(pak, idx);
		table.push(list1,SmeltVo);
	end

end



--[[
转生，上线推协议
]]
_G.RespTurnlifeinfoMsg = {};

RespTurnlifeinfoMsg.msgId = 8515;
RespTurnlifeinfoMsg.type = 0; -- 转生类型, 1=一转，2=二转，3=三转



RespTurnlifeinfoMsg.meta = {__index = RespTurnlifeinfoMsg };
function RespTurnlifeinfoMsg:new()
	local obj = setmetatable( {}, RespTurnlifeinfoMsg.meta);
	return obj;
end

function RespTurnlifeinfoMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function RespTurnlifeinfoMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
花费转生
]]
_G.ReqTurnlifeMoneyMsg = {};

ReqTurnlifeMoneyMsg.msgId = 3516;



ReqTurnlifeMoneyMsg.meta = {__index = ReqTurnlifeMoneyMsg };
function ReqTurnlifeMoneyMsg:new()
	local obj = setmetatable( {}, ReqTurnlifeMoneyMsg.meta);
	return obj;
end

function ReqTurnlifeMoneyMsg:encode()
	local body = "";


	return body;
end

function ReqTurnlifeMoneyMsg:ParseData(pak)
	local idx = 1;


end



--[[
转生结果
]]
_G.RespTurnlifeMoneyMsg = {};

RespTurnlifeMoneyMsg.msgId = 8516;
RespTurnlifeMoneyMsg.result = 0; -- 花费转生结果 0成功，1失败，-1=元宝不足



RespTurnlifeMoneyMsg.meta = {__index = RespTurnlifeMoneyMsg };
function RespTurnlifeMoneyMsg:new()
	local obj = setmetatable( {}, RespTurnlifeMoneyMsg.meta);
	return obj;
end

function RespTurnlifeMoneyMsg:encode()
	local body = "";

	body = body ..writeInt(self.result);

	return body;
end

function RespTurnlifeMoneyMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
开始转生
]]
_G.ReqTurnlifeEnterMsg = {};

ReqTurnlifeEnterMsg.msgId = 3517;



ReqTurnlifeEnterMsg.meta = {__index = ReqTurnlifeEnterMsg };
function ReqTurnlifeEnterMsg:new()
	local obj = setmetatable( {}, ReqTurnlifeEnterMsg.meta);
	return obj;
end

function ReqTurnlifeEnterMsg:encode()
	local body = "";


	return body;
end

function ReqTurnlifeEnterMsg:ParseData(pak)
	local idx = 1;


end



--[[
进入结果
]]
_G.RespTurnlifeEnterMsg = {};

RespTurnlifeEnterMsg.msgId = 8517;
RespTurnlifeEnterMsg.result = 0; -- 进入结果，0成功，1失败！



RespTurnlifeEnterMsg.meta = {__index = RespTurnlifeEnterMsg };
function RespTurnlifeEnterMsg:new()
	local obj = setmetatable( {}, RespTurnlifeEnterMsg.meta);
	return obj;
end

function RespTurnlifeEnterMsg:encode()
	local body = "";

	body = body ..writeInt(self.result);

	return body;
end

function RespTurnlifeEnterMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
退出转生
]]
_G.ReqTurnlifeOutMsg = {};

ReqTurnlifeOutMsg.msgId = 3518;



ReqTurnlifeOutMsg.meta = {__index = ReqTurnlifeOutMsg };
function ReqTurnlifeOutMsg:new()
	local obj = setmetatable( {}, ReqTurnlifeOutMsg.meta);
	return obj;
end

function ReqTurnlifeOutMsg:encode()
	local body = "";


	return body;
end

function ReqTurnlifeOutMsg:ParseData(pak)
	local idx = 1;


end



--[[
 退出结果
]]
_G.RespTurnlifeOutMsg = {};

RespTurnlifeOutMsg.msgId = 8518;
RespTurnlifeOutMsg.result = 0; -- 0成功



RespTurnlifeOutMsg.meta = {__index = RespTurnlifeOutMsg };
function RespTurnlifeOutMsg:new()
	local obj = setmetatable( {}, RespTurnlifeOutMsg.meta);
	return obj;
end

function RespTurnlifeOutMsg:encode()
	local body = "";

	body = body ..writeInt(self.result);

	return body;
end

function RespTurnlifeOutMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
客户端请求：冰魂换模型
]]
_G.ReqBingHunChangeModelMsg = {};

ReqBingHunChangeModelMsg.msgId = 3521;
ReqBingHunChangeModelMsg.id = 0; -- 请求更换模型的id(即配表ID)



ReqBingHunChangeModelMsg.meta = {__index = ReqBingHunChangeModelMsg };
function ReqBingHunChangeModelMsg:new()
	local obj = setmetatable( {}, ReqBingHunChangeModelMsg.meta);
	return obj;
end

function ReqBingHunChangeModelMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqBingHunChangeModelMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
客户端请求：刷新悬赏状态
]]
_G.ReqFengYaoRefreshStateMsg = {};

ReqFengYaoRefreshStateMsg.msgId = 3522;



ReqFengYaoRefreshStateMsg.meta = {__index = ReqFengYaoRefreshStateMsg };
function ReqFengYaoRefreshStateMsg:new()
	local obj = setmetatable( {}, ReqFengYaoRefreshStateMsg.meta);
	return obj;
end

function ReqFengYaoRefreshStateMsg:encode()
	local body = "";


	return body;
end

function ReqFengYaoRefreshStateMsg:ParseData(pak)
	local idx = 1;


end



--[[
额外领取流水副本多倍奖励
]]
_G.ReqWaterDungeonLossRewardMsg = {};

ReqWaterDungeonLossRewardMsg.msgId = 3523;
ReqWaterDungeonLossRewardMsg.type = 0; -- 请求领取奖励类型,2:1.2倍,3:1.5倍



ReqWaterDungeonLossRewardMsg.meta = {__index = ReqWaterDungeonLossRewardMsg };
function ReqWaterDungeonLossRewardMsg:new()
	local obj = setmetatable( {}, ReqWaterDungeonLossRewardMsg.meta);
	return obj;
end

function ReqWaterDungeonLossRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqWaterDungeonLossRewardMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
请求领取消费礼包
]]
_G.ReqGiveBuyGiftMsg = {};

ReqGiveBuyGiftMsg.msgId = 3529;
ReqGiveBuyGiftMsg.index = 0; -- 第*个



ReqGiveBuyGiftMsg.meta = {__index = ReqGiveBuyGiftMsg };
function ReqGiveBuyGiftMsg:new()
	local obj = setmetatable( {}, ReqGiveBuyGiftMsg.meta);
	return obj;
end

function ReqGiveBuyGiftMsg:encode()
	local body = "";

	body = body ..writeInt(self.index);

	return body;
end

function ReqGiveBuyGiftMsg:ParseData(pak)
	local idx = 1;

	self.index, idx = readInt(pak, idx);

end



--[[
请求发送世界notice
]]
_G.ReqWorldNoticeMsg = {};

ReqWorldNoticeMsg.msgId = 3530;
ReqWorldNoticeMsg.type = 0; -- 1 悬赏



ReqWorldNoticeMsg.meta = {__index = ReqWorldNoticeMsg };
function ReqWorldNoticeMsg:new()
	local obj = setmetatable( {}, ReqWorldNoticeMsg.meta);
	return obj;
end

function ReqWorldNoticeMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqWorldNoticeMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
发红包
]]
_G.ReqSendRedPacketMsg = {};

ReqSendRedPacketMsg.msgId = 3531;
ReqSendRedPacketMsg.type = 0; -- 0默认vip红包，1婚礼红包
ReqSendRedPacketMsg.allNum = 0; -- 婚礼红包，总量
ReqSendRedPacketMsg.allPart = 0; -- 婚礼红包总份数
ReqSendRedPacketMsg.numType = 0; -- 货币类型



ReqSendRedPacketMsg.meta = {__index = ReqSendRedPacketMsg };
function ReqSendRedPacketMsg:new()
	local obj = setmetatable( {}, ReqSendRedPacketMsg.meta);
	return obj;
end

function ReqSendRedPacketMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);
	body = body ..writeInt(self.allNum);
	body = body ..writeInt(self.allPart);
	body = body ..writeInt(self.numType);

	return body;
end

function ReqSendRedPacketMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.allNum, idx = readInt(pak, idx);
	self.allPart, idx = readInt(pak, idx);
	self.numType, idx = readInt(pak, idx);

end



--[[
客户端请求：运营活动
]]
_G.ReqPartyListMsg = {};

ReqPartyListMsg.msgId = 3534;
ReqPartyListMsg.btnid = 0; -- 按钮id



ReqPartyListMsg.meta = {__index = ReqPartyListMsg };
function ReqPartyListMsg:new()
	local obj = setmetatable( {}, ReqPartyListMsg.meta);
	return obj;
end

function ReqPartyListMsg:encode()
	local body = "";

	body = body ..writeInt(self.btnid);

	return body;
end

function ReqPartyListMsg:ParseData(pak)
	local idx = 1;

	self.btnid, idx = readInt(pak, idx);

end



--[[
客户端请求：运营活动
]]
_G.ReqPartyStatListMsg = {};

ReqPartyStatListMsg.msgId = 3535;
ReqPartyStatListMsg.btnid = 0; -- 按钮id



ReqPartyStatListMsg.meta = {__index = ReqPartyStatListMsg };
function ReqPartyStatListMsg:new()
	local obj = setmetatable( {}, ReqPartyStatListMsg.meta);
	return obj;
end

function ReqPartyStatListMsg:encode()
	local body = "";

	body = body ..writeInt(self.btnid);

	return body;
end

function ReqPartyStatListMsg:ParseData(pak)
	local idx = 1;

	self.btnid, idx = readInt(pak, idx);

end



--[[
客户端请求：获得运营活动奖励
]]
_G.ReqGetPartyAwardMsg = {};

ReqGetPartyAwardMsg.msgId = 3536;
ReqGetPartyAwardMsg.id = 0; -- 活动id
ReqGetPartyAwardMsg.index = 0; -- 奖励的索引



ReqGetPartyAwardMsg.meta = {__index = ReqGetPartyAwardMsg };
function ReqGetPartyAwardMsg:new()
	local obj = setmetatable( {}, ReqGetPartyAwardMsg.meta);
	return obj;
end

function ReqGetPartyAwardMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.index);

	return body;
end

function ReqGetPartyAwardMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.index, idx = readInt(pak, idx);

end



--[[
请求战力运营排行
]]
_G.ReqPartyRankMsg = {};

ReqPartyRankMsg.msgId = 3540;
ReqPartyRankMsg.id = 0; -- 组id



ReqPartyRankMsg.meta = {__index = ReqPartyRankMsg };
function ReqPartyRankMsg:new()
	local obj = setmetatable( {}, ReqPartyRankMsg.meta);
	return obj;
end

function ReqPartyRankMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqPartyRankMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
请求团购信息
]]
_G.ReqPartyGroupPurchaseMsg = {};

ReqPartyGroupPurchaseMsg.msgId = 3541;
ReqPartyGroupPurchaseMsg.id = 0; -- 组id



ReqPartyGroupPurchaseMsg.meta = {__index = ReqPartyGroupPurchaseMsg };
function ReqPartyGroupPurchaseMsg:new()
	local obj = setmetatable( {}, ReqPartyGroupPurchaseMsg.meta);
	return obj;
end

function ReqPartyGroupPurchaseMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqPartyGroupPurchaseMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
灵兽坐骑进阶
]]
_G.ReqLSHorseLvlUpMsg = {};

ReqLSHorseLvlUpMsg.msgId = 3544;
ReqLSHorseLvlUpMsg.type = 0; -- 0 进阶石，1 灵力
ReqLSHorseLvlUpMsg.autoBuy = 0; -- 0 自动购买道具,1 不自动购买



ReqLSHorseLvlUpMsg.meta = {__index = ReqLSHorseLvlUpMsg };
function ReqLSHorseLvlUpMsg:new()
	local obj = setmetatable( {}, ReqLSHorseLvlUpMsg.meta);
	return obj;
end

function ReqLSHorseLvlUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);
	body = body ..writeInt(self.autoBuy);

	return body;
end

function ReqLSHorseLvlUpMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.autoBuy, idx = readInt(pak, idx);

end



--[[
请求单个活动信息
]]
_G.ReqPartyInfoMsg = {};

ReqPartyInfoMsg.msgId = 3548;
ReqPartyInfoMsg.groupid = 0; -- 组ID
ReqPartyInfoMsg.version = 0; -- 本地版本号，刚登陆就发0



ReqPartyInfoMsg.meta = {__index = ReqPartyInfoMsg };
function ReqPartyInfoMsg:new()
	local obj = setmetatable( {}, ReqPartyInfoMsg.meta);
	return obj;
end

function ReqPartyInfoMsg:encode()
	local body = "";

	body = body ..writeInt(self.groupid);
	body = body ..writeInt(self.version);

	return body;
end

function ReqPartyInfoMsg:ParseData(pak)
	local idx = 1;

	self.groupid, idx = readInt(pak, idx);
	self.version, idx = readInt(pak, idx);

end



--[[
请求打开道具卡片
]]
_G.ReqOpenItemCardMsg = {};

ReqOpenItemCardMsg.msgId = 3549;
ReqOpenItemCardMsg.itemCardID = ""; -- ID
ReqOpenItemCardMsg.type = 0; -- 打开类型 1免费 2 3 



ReqOpenItemCardMsg.meta = {__index = ReqOpenItemCardMsg };
function ReqOpenItemCardMsg:new()
	local obj = setmetatable( {}, ReqOpenItemCardMsg.meta);
	return obj;
end

function ReqOpenItemCardMsg:encode()
	local body = "";

	body = body ..writeGuid(self.itemCardID);
	body = body ..writeInt(self.type);

	return body;
end

function ReqOpenItemCardMsg:ParseData(pak)
	local idx = 1;

	self.itemCardID, idx = readGuid(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
开装备卓越孔(只能顺序开)
]]
_G.ReqOpenSuperHoleMsg = {};

ReqOpenSuperHoleMsg.msgId = 3550;
ReqOpenSuperHoleMsg.eId = ""; -- 装备cid
ReqOpenSuperHoleMsg.itemTid = 0; -- 使用道具cid



ReqOpenSuperHoleMsg.meta = {__index = ReqOpenSuperHoleMsg };
function ReqOpenSuperHoleMsg:new()
	local obj = setmetatable( {}, ReqOpenSuperHoleMsg.meta);
	return obj;
end

function ReqOpenSuperHoleMsg:encode()
	local body = "";

	body = body ..writeGuid(self.eId);
	body = body ..writeInt(self.itemTid);

	return body;
end

function ReqOpenSuperHoleMsg:ParseData(pak)
	local idx = 1;

	self.eId, idx = readGuid(pak, idx);
	self.itemTid, idx = readInt(pak, idx);

end



--[[
客户端请求运营活动领奖
]]
_G.ReqYunYingRewardMsg = {};

ReqYunYingRewardMsg.msgId = 3557;
ReqYunYingRewardMsg.type = 0; -- 类型



ReqYunYingRewardMsg.meta = {__index = ReqYunYingRewardMsg };
function ReqYunYingRewardMsg:new()
	local obj = setmetatable( {}, ReqYunYingRewardMsg.meta);
	return obj;
end

function ReqYunYingRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqYunYingRewardMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
请求首冲团购
]]
_G.ReqPartyGroupChargeMsg = {};

ReqPartyGroupChargeMsg.msgId = 3559;
ReqPartyGroupChargeMsg.id = 0; -- 组id



ReqPartyGroupChargeMsg.meta = {__index = ReqPartyGroupChargeMsg };
function ReqPartyGroupChargeMsg:new()
	local obj = setmetatable( {}, ReqPartyGroupChargeMsg.meta);
	return obj;
end

function ReqPartyGroupChargeMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqPartyGroupChargeMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
客户端请求进入个人BOSS副本
]]
_G.ReqEnterPersonalBossMsg = {};

ReqEnterPersonalBossMsg.msgId = 3561;
ReqEnterPersonalBossMsg.id = 0; -- bossID



ReqEnterPersonalBossMsg.meta = {__index = ReqEnterPersonalBossMsg };
function ReqEnterPersonalBossMsg:new()
	local obj = setmetatable( {}, ReqEnterPersonalBossMsg.meta);
	return obj;
end

function ReqEnterPersonalBossMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqEnterPersonalBossMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
客户端请求退出个人BOSS副本
]]
_G.ReqQuitPersonalBossMsg = {};

ReqQuitPersonalBossMsg.msgId = 3562;



ReqQuitPersonalBossMsg.meta = {__index = ReqQuitPersonalBossMsg };
function ReqQuitPersonalBossMsg:new()
	local obj = setmetatable( {}, ReqQuitPersonalBossMsg.meta);
	return obj;
end

function ReqQuitPersonalBossMsg:encode()
	local body = "";


	return body;
end

function ReqQuitPersonalBossMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求扫荡斗破苍穹
]]
_G.ReqBabelSweepsMsg = {};

ReqBabelSweepsMsg.msgId = 3567;
ReqBabelSweepsMsg.babelID = 0; -- 扫荡



ReqBabelSweepsMsg.meta = {__index = ReqBabelSweepsMsg };
function ReqBabelSweepsMsg:new()
	local obj = setmetatable( {}, ReqBabelSweepsMsg.meta);
	return obj;
end

function ReqBabelSweepsMsg:encode()
	local body = "";

	body = body ..writeInt(self.babelID);

	return body;
end

function ReqBabelSweepsMsg:ParseData(pak)
	local idx = 1;

	self.babelID, idx = readInt(pak, idx);

end



--[[
客户端请求结束个人副本loading
]]
_G.ReqPersonalBossLoadingMsg = {};

ReqPersonalBossLoadingMsg.msgId = 3568;



ReqPersonalBossLoadingMsg.meta = {__index = ReqPersonalBossLoadingMsg };
function ReqPersonalBossLoadingMsg:new()
	local obj = setmetatable( {}, ReqPersonalBossLoadingMsg.meta);
	return obj;
end

function ReqPersonalBossLoadingMsg:encode()
	local body = "";


	return body;
end

function ReqPersonalBossLoadingMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：骑战进阶
]]
_G.ReqQiZhanLevelUpMsg = {};

ReqQiZhanLevelUpMsg.msgId = 3570;
ReqQiZhanLevelUpMsg.autobuy = 0; -- 道具不足时是否自动购买, 0自动购买



ReqQiZhanLevelUpMsg.meta = {__index = ReqQiZhanLevelUpMsg };
function ReqQiZhanLevelUpMsg:new()
	local obj = setmetatable( {}, ReqQiZhanLevelUpMsg.meta);
	return obj;
end

function ReqQiZhanLevelUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.autobuy);

	return body;
end

function ReqQiZhanLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.autobuy, idx = readInt(pak, idx);

end



--[[
顺网平台
]]
_G.ReqShunwangTerraceMsg = {};

ReqShunwangTerraceMsg.msgId = 3571;
ReqShunwangTerraceMsg.swlvl = 0; -- 要领取的等级



ReqShunwangTerraceMsg.meta = {__index = ReqShunwangTerraceMsg };
function ReqShunwangTerraceMsg:new()
	local obj = setmetatable( {}, ReqShunwangTerraceMsg.meta);
	return obj;
end

function ReqShunwangTerraceMsg:encode()
	local body = "";

	body = body ..writeInt(self.swlvl);

	return body;
end

function ReqShunwangTerraceMsg:ParseData(pak)
	local idx = 1;

	self.swlvl, idx = readInt(pak, idx);

end



--[[
商店道具兑换
]]
_G.ReqExchangeShopMsg = {};

ReqExchangeShopMsg.msgId = 3572;
ReqExchangeShopMsg.id = 0; -- 商品id
ReqExchangeShopMsg.num = 0; -- 购买数量



ReqExchangeShopMsg.meta = {__index = ReqExchangeShopMsg };
function ReqExchangeShopMsg:new()
	local obj = setmetatable( {}, ReqExchangeShopMsg.meta);
	return obj;
end

function ReqExchangeShopMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.num);

	return body;
end

function ReqExchangeShopMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
激活骑战
]]
_G.ReqActiveQiZhanMsg = {};

ReqActiveQiZhanMsg.msgId = 3574;
ReqActiveQiZhanMsg.autobuy = 0; -- 道具不足时是否自动购买, 0自动购买



ReqActiveQiZhanMsg.meta = {__index = ReqActiveQiZhanMsg };
function ReqActiveQiZhanMsg:new()
	local obj = setmetatable( {}, ReqActiveQiZhanMsg.meta);
	return obj;
end

function ReqActiveQiZhanMsg:encode()
	local body = "";

	body = body ..writeInt(self.autobuy);

	return body;
end

function ReqActiveQiZhanMsg:ParseData(pak)
	local idx = 1;

	self.autobuy, idx = readInt(pak, idx);

end



--[[
请求骑战副本date
]]
_G.ReqQiZhanDungeonDateMsg = {};

ReqQiZhanDungeonDateMsg.msgId = 3575;



ReqQiZhanDungeonDateMsg.meta = {__index = ReqQiZhanDungeonDateMsg };
function ReqQiZhanDungeonDateMsg:new()
	local obj = setmetatable( {}, ReqQiZhanDungeonDateMsg.meta);
	return obj;
end

function ReqQiZhanDungeonDateMsg:encode()
	local body = "";


	return body;
end

function ReqQiZhanDungeonDateMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求进入骑战副本
]]
_G.ReqQiZhanDungeonEnterMsg = {};

ReqQiZhanDungeonEnterMsg.msgId = 3576;



ReqQiZhanDungeonEnterMsg.meta = {__index = ReqQiZhanDungeonEnterMsg };
function ReqQiZhanDungeonEnterMsg:new()
	local obj = setmetatable( {}, ReqQiZhanDungeonEnterMsg.meta);
	return obj;
end

function ReqQiZhanDungeonEnterMsg:encode()
	local body = "";


	return body;
end

function ReqQiZhanDungeonEnterMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求退出骑战副本
]]
_G.ReqQiZhanDungeonQuitMsg = {};

ReqQiZhanDungeonQuitMsg.msgId = 3579;



ReqQiZhanDungeonQuitMsg.meta = {__index = ReqQiZhanDungeonQuitMsg };
function ReqQiZhanDungeonQuitMsg:new()
	local obj = setmetatable( {}, ReqQiZhanDungeonQuitMsg.meta);
	return obj;
end

function ReqQiZhanDungeonQuitMsg:encode()
	local body = "";


	return body;
end

function ReqQiZhanDungeonQuitMsg:ParseData(pak)
	local idx = 1;


end



--[[
骑战副本发送准备状态
]]
_G.ReqQiZhanDungeonTeamStateMsg = {};

ReqQiZhanDungeonTeamStateMsg.msgId = 3581;
ReqQiZhanDungeonTeamStateMsg.state = 0; -- 选择结果 0同意 1拒绝 2关闭(所有人权限)



ReqQiZhanDungeonTeamStateMsg.meta = {__index = ReqQiZhanDungeonTeamStateMsg };
function ReqQiZhanDungeonTeamStateMsg:new()
	local obj = setmetatable( {}, ReqQiZhanDungeonTeamStateMsg.meta);
	return obj;
end

function ReqQiZhanDungeonTeamStateMsg:encode()
	local body = "";

	body = body ..writeInt(self.state);

	return body;
end

function ReqQiZhanDungeonTeamStateMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);

end



--[[
切换骑战
]]
_G.ReqChangeQiZhanMsg = {};

ReqChangeQiZhanMsg.msgId = 3582;
ReqChangeQiZhanMsg.level = 0; -- 骑战等阶



ReqChangeQiZhanMsg.meta = {__index = ReqChangeQiZhanMsg };
function ReqChangeQiZhanMsg:new()
	local obj = setmetatable( {}, ReqChangeQiZhanMsg.meta);
	return obj;
end

function ReqChangeQiZhanMsg:encode()
	local body = "";

	body = body ..writeInt(self.level);

	return body;
end

function ReqChangeQiZhanMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);

end



--[[
请求激活/升级Boss勋章
]]
_G.ReqBossMedalLevelUpMsg = {};

ReqBossMedalLevelUpMsg.msgId = 3585;



ReqBossMedalLevelUpMsg.meta = {__index = ReqBossMedalLevelUpMsg };
function ReqBossMedalLevelUpMsg:new()
	local obj = setmetatable( {}, ReqBossMedalLevelUpMsg.meta);
	return obj;
end

function ReqBossMedalLevelUpMsg:encode()
	local body = "";


	return body;
end

function ReqBossMedalLevelUpMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求进入帮派地宫争夺战
]]
_G.ReqEnterGuildDiGongMsg = {};

ReqEnterGuildDiGongMsg.msgId = 3591;
ReqEnterGuildDiGongMsg.id = 0; -- 活动id



ReqEnterGuildDiGongMsg.meta = {__index = ReqEnterGuildDiGongMsg };
function ReqEnterGuildDiGongMsg:new()
	local obj = setmetatable( {}, ReqEnterGuildDiGongMsg.meta);
	return obj;
end

function ReqEnterGuildDiGongMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqEnterGuildDiGongMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
请求退出帮派地宫争夺战
]]
_G.ReqQuitGuildDiGongMsg = {};

ReqQuitGuildDiGongMsg.msgId = 3594;
ReqQuitGuildDiGongMsg.id = 0; -- 活动id



ReqQuitGuildDiGongMsg.meta = {__index = ReqQuitGuildDiGongMsg };
function ReqQuitGuildDiGongMsg:new()
	local obj = setmetatable( {}, ReqQuitGuildDiGongMsg.meta);
	return obj;
end

function ReqQuitGuildDiGongMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqQuitGuildDiGongMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
请求帮派地宫争夺战旗帜操作
]]
_G.ReqUnionDiGongPickFlagMsg = {};

ReqUnionDiGongPickFlagMsg.msgId = 3597;



ReqUnionDiGongPickFlagMsg.meta = {__index = ReqUnionDiGongPickFlagMsg };
function ReqUnionDiGongPickFlagMsg:new()
	local obj = setmetatable( {}, ReqUnionDiGongPickFlagMsg.meta);
	return obj;
end

function ReqUnionDiGongPickFlagMsg:encode()
	local body = "";


	return body;
end

function ReqUnionDiGongPickFlagMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求洗练
]]
_G.ReqEquipNewSuperNewValMsg = {};

ReqEquipNewSuperNewValMsg.msgId = 3603;
ReqEquipNewSuperNewValMsg.cid = ""; -- 装备cid



ReqEquipNewSuperNewValMsg.meta = {__index = ReqEquipNewSuperNewValMsg };
function ReqEquipNewSuperNewValMsg:new()
	local obj = setmetatable( {}, ReqEquipNewSuperNewValMsg.meta);
	return obj;
end

function ReqEquipNewSuperNewValMsg:encode()
	local body = "";

	body = body ..writeGuid(self.cid);

	return body;
end

function ReqEquipNewSuperNewValMsg:ParseData(pak)
	local idx = 1;

	self.cid, idx = readGuid(pak, idx);

end



--[[
请求洗练保存属性
]]
_G.ReqEquipNewSuperNewValSetMsg = {};

ReqEquipNewSuperNewValSetMsg.msgId = 3604;
ReqEquipNewSuperNewValSetMsg.cid = ""; -- 装备cid



ReqEquipNewSuperNewValSetMsg.meta = {__index = ReqEquipNewSuperNewValSetMsg };
function ReqEquipNewSuperNewValSetMsg:new()
	local obj = setmetatable( {}, ReqEquipNewSuperNewValSetMsg.meta);
	return obj;
end

function ReqEquipNewSuperNewValSetMsg:encode()
	local body = "";

	body = body ..writeGuid(self.cid);

	return body;
end

function ReqEquipNewSuperNewValSetMsg:ParseData(pak)
	local idx = 1;

	self.cid, idx = readGuid(pak, idx);

end



--[[
请求跨服BOSS排行信息
]]
_G.ReqCrossBossRankInfoMsg = {};

ReqCrossBossRankInfoMsg.msgId = 3607;
ReqCrossBossRankInfoMsg.type = 0; -- BOSS类型



ReqCrossBossRankInfoMsg.meta = {__index = ReqCrossBossRankInfoMsg };
function ReqCrossBossRankInfoMsg:new()
	local obj = setmetatable( {}, ReqCrossBossRankInfoMsg.meta);
	return obj;
end

function ReqCrossBossRankInfoMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqCrossBossRankInfoMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
客户端请求：退出跨服BOSS
]]
_G.ReqQuitCrossBossMsg = {};

ReqQuitCrossBossMsg.msgId = 3610;



ReqQuitCrossBossMsg.meta = {__index = ReqQuitCrossBossMsg };
function ReqQuitCrossBossMsg:new()
	local obj = setmetatable( {}, ReqQuitCrossBossMsg.meta);
	return obj;
end

function ReqQuitCrossBossMsg:encode()
	local body = "";


	return body;
end

function ReqQuitCrossBossMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：请求激活/升级噬魂徽章升级
]]
_G.ReqShiHunMedalLevelUpMsg = {};

ReqShiHunMedalLevelUpMsg.msgId = 3611;



ReqShiHunMedalLevelUpMsg.meta = {__index = ReqShiHunMedalLevelUpMsg };
function ReqShiHunMedalLevelUpMsg:new()
	local obj = setmetatable( {}, ReqShiHunMedalLevelUpMsg.meta);
	return obj;
end

function ReqShiHunMedalLevelUpMsg:encode()
	local body = "";


	return body;
end

function ReqShiHunMedalLevelUpMsg:ParseData(pak)
	local idx = 1;


end



--[[
搜狗平台，领取奖励
]]
_G.ReqSougouDownHallMsg = {};

ReqSougouDownHallMsg.msgId = 3614;
ReqSougouDownHallMsg.type = 0; -- 1，游戏大厅，2搜狗皮肤



ReqSougouDownHallMsg.meta = {__index = ReqSougouDownHallMsg };
function ReqSougouDownHallMsg:new()
	local obj = setmetatable( {}, ReqSougouDownHallMsg.meta);
	return obj;
end

function ReqSougouDownHallMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqSougouDownHallMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
珍宝阁请求突破
]]
_G.ReqJewelleryBreakMsg = {};

ReqJewelleryBreakMsg.msgId = 3616;
ReqJewelleryBreakMsg.id = 0; -- 珍宝阁id



ReqJewelleryBreakMsg.meta = {__index = ReqJewelleryBreakMsg };
function ReqJewelleryBreakMsg:new()
	local obj = setmetatable( {}, ReqJewelleryBreakMsg.meta);
	return obj;
end

function ReqJewelleryBreakMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqJewelleryBreakMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
请求跨服回血
]]
_G.ReqUseCrossHpMsg = {};

ReqUseCrossHpMsg.msgId = 3618;



ReqUseCrossHpMsg.meta = {__index = ReqUseCrossHpMsg };
function ReqUseCrossHpMsg:new()
	local obj = setmetatable( {}, ReqUseCrossHpMsg.meta);
	return obj;
end

function ReqUseCrossHpMsg:encode()
	local body = "";


	return body;
end

function ReqUseCrossHpMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求翅膀强化
]]
_G.ReqSendWingStrenMsg = {};

ReqSendWingStrenMsg.msgId = 3620;



ReqSendWingStrenMsg.meta = {__index = ReqSendWingStrenMsg };
function ReqSendWingStrenMsg:new()
	local obj = setmetatable( {}, ReqSendWingStrenMsg.meta);
	return obj;
end

function ReqSendWingStrenMsg:encode()
	local body = "";


	return body;
end

function ReqSendWingStrenMsg:ParseData(pak)
	local idx = 1;


end



--[[
发送跨服聊天
]]
_G.ReqCrossChatMsg = {};

ReqCrossChatMsg.msgId = 3621;
ReqCrossChatMsg.channel = 0; -- 频道,101 区域，102 本服
ReqCrossChatMsg.text = ""; -- 内容



ReqCrossChatMsg.meta = {__index = ReqCrossChatMsg };
function ReqCrossChatMsg:new()
	local obj = setmetatable( {}, ReqCrossChatMsg.meta);
	return obj;
end

function ReqCrossChatMsg:encode()
	local body = "";

	body = body ..writeInt(self.channel);
	body = body ..writeString(self.text);

	return body;
end

function ReqCrossChatMsg:ParseData(pak)
	local idx = 1;

	self.channel, idx = readInt(pak, idx);
	self.text, idx = readString(pak, idx);

end



--[[
客户端请求：神灵进阶
]]
_G.ReqShenLingLevelUpMsg = {};

ReqShenLingLevelUpMsg.msgId = 3623;
ReqShenLingLevelUpMsg.autobuy = 0; -- 道具不足时是否自动购买, 0自动购买



ReqShenLingLevelUpMsg.meta = {__index = ReqShenLingLevelUpMsg };
function ReqShenLingLevelUpMsg:new()
	local obj = setmetatable( {}, ReqShenLingLevelUpMsg.meta);
	return obj;
end

function ReqShenLingLevelUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.autobuy);

	return body;
end

function ReqShenLingLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.autobuy, idx = readInt(pak, idx);

end



--[[
激活神灵
]]
_G.ReqActiveShenLingMsg = {};

ReqActiveShenLingMsg.msgId = 3624;



ReqActiveShenLingMsg.meta = {__index = ReqActiveShenLingMsg };
function ReqActiveShenLingMsg:new()
	local obj = setmetatable( {}, ReqActiveShenLingMsg.meta);
	return obj;
end

function ReqActiveShenLingMsg:encode()
	local body = "";


	return body;
end

function ReqActiveShenLingMsg:ParseData(pak)
	local idx = 1;


end



--[[
切换神灵
]]
_G.ReqChangeShenLingMsg = {};

ReqChangeShenLingMsg.msgId = 3625;
ReqChangeShenLingMsg.shenlingId = 0; -- 神灵Id



ReqChangeShenLingMsg.meta = {__index = ReqChangeShenLingMsg };
function ReqChangeShenLingMsg:new()
	local obj = setmetatable( {}, ReqChangeShenLingMsg.meta);
	return obj;
end

function ReqChangeShenLingMsg:encode()
	local body = "";

	body = body ..writeInt(self.shenlingId);

	return body;
end

function ReqChangeShenLingMsg:ParseData(pak)
	local idx = 1;

	self.shenlingId, idx = readInt(pak, idx);

end



--[[
请求跨服预选赛第一名
]]
_G.ReqCrossPreArenaRankMsg = {};

ReqCrossPreArenaRankMsg.msgId = 3629;



ReqCrossPreArenaRankMsg.meta = {__index = ReqCrossPreArenaRankMsg };
function ReqCrossPreArenaRankMsg:new()
	local obj = setmetatable( {}, ReqCrossPreArenaRankMsg.meta);
	return obj;
end

function ReqCrossPreArenaRankMsg:encode()
	local body = "";


	return body;
end

function ReqCrossPreArenaRankMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求退出跨服预选赛
]]
_G.ReqCrossPreArenaQuitMsg = {};

ReqCrossPreArenaQuitMsg.msgId = 3630;



ReqCrossPreArenaQuitMsg.meta = {__index = ReqCrossPreArenaQuitMsg };
function ReqCrossPreArenaQuitMsg:new()
	local obj = setmetatable( {}, ReqCrossPreArenaQuitMsg.meta);
	return obj;
end

function ReqCrossPreArenaQuitMsg:encode()
	local body = "";


	return body;
end

function ReqCrossPreArenaQuitMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求退出跨服淘汰赛
]]
_G.ReqCrossArenaQuitMsg = {};

ReqCrossArenaQuitMsg.msgId = 3632;



ReqCrossArenaQuitMsg.meta = {__index = ReqCrossArenaQuitMsg };
function ReqCrossArenaQuitMsg:new()
	local obj = setmetatable( {}, ReqCrossArenaQuitMsg.meta);
	return obj;
end

function ReqCrossArenaQuitMsg:encode()
	local body = "";


	return body;
end

function ReqCrossArenaQuitMsg:ParseData(pak)
	local idx = 1;


end



--[[
结婚典礼
]]
_G.ReqMarryTypeMsg = {};

ReqMarryTypeMsg.msgId = 3633;
ReqMarryTypeMsg.marryType = 0; -- 婚礼类型表id



ReqMarryTypeMsg.meta = {__index = ReqMarryTypeMsg };
function ReqMarryTypeMsg:new()
	local obj = setmetatable( {}, ReqMarryTypeMsg.meta);
	return obj;
end

function ReqMarryTypeMsg:encode()
	local body = "";

	body = body ..writeInt(self.marryType);

	return body;
end

function ReqMarryTypeMsg:ParseData(pak)
	local idx = 1;

	self.marryType, idx = readInt(pak, idx);

end



--[[
申请结婚巡游
]]
_G.ReqMarryTravelMsg = {};

ReqMarryTravelMsg.msgId = 3635;



ReqMarryTravelMsg.meta = {__index = ReqMarryTravelMsg };
function ReqMarryTravelMsg:new()
	local obj = setmetatable( {}, ReqMarryTravelMsg.meta);
	return obj;
end

function ReqMarryTravelMsg:encode()
	local body = "";


	return body;
end

function ReqMarryTravelMsg:ParseData(pak)
	local idx = 1;


end



--[[
申请进入婚礼礼堂
]]
_G.ReqEnterMarryChurchMsg = {};

ReqEnterMarryChurchMsg.msgId = 3636;



ReqEnterMarryChurchMsg.meta = {__index = ReqEnterMarryChurchMsg };
function ReqEnterMarryChurchMsg:new()
	local obj = setmetatable( {}, ReqEnterMarryChurchMsg.meta);
	return obj;
end

function ReqEnterMarryChurchMsg:encode()
	local body = "";


	return body;
end

function ReqEnterMarryChurchMsg:ParseData(pak)
	local idx = 1;


end



--[[
退出婚礼副本
]]
_G.ReqOutMarryCopyMsg = {};

ReqOutMarryCopyMsg.msgId = 3637;



ReqOutMarryCopyMsg.meta = {__index = ReqOutMarryCopyMsg };
function ReqOutMarryCopyMsg:new()
	local obj = setmetatable( {}, ReqOutMarryCopyMsg.meta);
	return obj;
end

function ReqOutMarryCopyMsg:encode()
	local body = "";


	return body;
end

function ReqOutMarryCopyMsg:ParseData(pak)
	local idx = 1;


end



--[[
婚礼仪式
]]
_G.ReqMarryMsg = {};

ReqMarryMsg.msgId = 3638;
ReqMarryMsg.result = 0; -- 1我愿意,2不愿意



ReqMarryMsg.meta = {__index = ReqMarryMsg };
function ReqMarryMsg:new()
	local obj = setmetatable( {}, ReqMarryMsg.meta);
	return obj;
end

function ReqMarryMsg:encode()
	local body = "";

	body = body ..writeInt(self.result);

	return body;
end

function ReqMarryMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
使用请帖前的data
]]
_G.ReqMarryCardUseMyDataMsg = {};

ReqMarryCardUseMyDataMsg.msgId = 3640;



ReqMarryCardUseMyDataMsg.meta = {__index = ReqMarryCardUseMyDataMsg };
function ReqMarryCardUseMyDataMsg:new()
	local obj = setmetatable( {}, ReqMarryCardUseMyDataMsg.meta);
	return obj;
end

function ReqMarryCardUseMyDataMsg:encode()
	local body = "";


	return body;
end

function ReqMarryCardUseMyDataMsg:ParseData(pak)
	local idx = 1;


end



--[[
使用请帖
]]
_G.ReqMarryCardUseMsg = {};

ReqMarryCardUseMsg.msgId = 3641;
ReqMarryCardUseMsg.cid = 0; -- 道具配置id
ReqMarryCardUseMsg.rolelist_size = 0; -- list size
ReqMarryCardUseMsg.rolelist = {}; -- list list

--[[
roleVoVO = {
	roleID = ""; -- 角色ID
}
]]

ReqMarryCardUseMsg.meta = {__index = ReqMarryCardUseMsg };
function ReqMarryCardUseMsg:new()
	local obj = setmetatable( {}, ReqMarryCardUseMsg.meta);
	return obj;
end

function ReqMarryCardUseMsg:encode()
	local body = "";

	body = body ..writeInt(self.cid);

	local list1 = self.rolelist;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeGuid(list1[i1].roleID);
	end

	return body;
end

function ReqMarryCardUseMsg:ParseData(pak)
	local idx = 1;

	self.cid, idx = readInt(pak, idx);

	local list1 = {};
	self.rolelist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local roleVoVo = {};
		roleVoVo.roleID, idx = readGuid(pak, idx);
		table.push(list1,roleVoVo);
	end

end



--[[
结婚面板打开
]]
_G.ReqMarryMainPanelInfoMsg = {};

ReqMarryMainPanelInfoMsg.msgId = 3643;



ReqMarryMainPanelInfoMsg.meta = {__index = ReqMarryMainPanelInfoMsg };
function ReqMarryMainPanelInfoMsg:new()
	local obj = setmetatable( {}, ReqMarryMainPanelInfoMsg.meta);
	return obj;
end

function ReqMarryMainPanelInfoMsg:encode()
	local body = "";


	return body;
end

function ReqMarryMainPanelInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求:生成附加属性卷轴
]]
_G.ReqBuildAttrScrollMsg = {};

ReqBuildAttrScrollMsg.msgId = 3645;
ReqBuildAttrScrollMsg.list_size = 0; -- 选中的附加属性列表 size
ReqBuildAttrScrollMsg.list = {}; -- 选中的附加属性列表 list

--[[
SuperLibVOVO = {
	uid = ""; -- 属性uid
}
]]

ReqBuildAttrScrollMsg.meta = {__index = ReqBuildAttrScrollMsg };
function ReqBuildAttrScrollMsg:new()
	local obj = setmetatable( {}, ReqBuildAttrScrollMsg.meta);
	return obj;
end

function ReqBuildAttrScrollMsg:encode()
	local body = "";


	local list1 = self.list;
	local list1Size = #list1;
	body = body .. writeInt(list1Size);
	for i1=1,list1Size do
		body = body .. writeGuid(list1[i1].uid);
	end

	return body;
end

function ReqBuildAttrScrollMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local SuperLibVOVo = {};
		SuperLibVOVo.uid, idx = readGuid(pak, idx);
		table.push(list1,SuperLibVOVo);
	end

end



--[[
请求离婚
]]
_G.ReqDivorceMsg = {};

ReqDivorceMsg.msgId = 3646;
ReqDivorceMsg.type = 0; -- 离婚类型,1双方，2单方，



ReqDivorceMsg.meta = {__index = ReqDivorceMsg };
function ReqDivorceMsg:new()
	local obj = setmetatable( {}, ReqDivorceMsg.meta);
	return obj;
end

function ReqDivorceMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqDivorceMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
队长开启婚礼仪式
]]
_G.ReqMarryOpenMsg = {};

ReqMarryOpenMsg.msgId = 3647;



ReqMarryOpenMsg.meta = {__index = ReqMarryOpenMsg };
function ReqMarryOpenMsg:new()
	local obj = setmetatable( {}, ReqMarryOpenMsg.meta);
	return obj;
end

function ReqMarryOpenMsg:encode()
	local body = "";


	return body;
end

function ReqMarryOpenMsg:ParseData(pak)
	local idx = 1;


end



--[[
切线完成
]]
_G.ReqEnterMarryChurchOKMsg = {};

ReqEnterMarryChurchOKMsg.msgId = 3648;



ReqEnterMarryChurchOKMsg.meta = {__index = ReqEnterMarryChurchOKMsg };
function ReqEnterMarryChurchOKMsg:new()
	local obj = setmetatable( {}, ReqEnterMarryChurchOKMsg.meta);
	return obj;
end

function ReqEnterMarryChurchOKMsg:encode()
	local body = "";


	return body;
end

function ReqEnterMarryChurchOKMsg:ParseData(pak)
	local idx = 1;


end



--[[
更换戒指
]]
_G.ReqMarryRingChangMsg = {};

ReqMarryRingChangMsg.msgId = 3649;
ReqMarryRingChangMsg.id = ""; -- 道具配置id
ReqMarryRingChangMsg.cid = 0; -- 增加道具cid



ReqMarryRingChangMsg.meta = {__index = ReqMarryRingChangMsg };
function ReqMarryRingChangMsg:new()
	local obj = setmetatable( {}, ReqMarryRingChangMsg.meta);
	return obj;
end

function ReqMarryRingChangMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);
	body = body ..writeInt(self.cid);

	return body;
end

function ReqMarryRingChangMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.cid, idx = readInt(pak, idx);

end



--[[
客户端请求：兵灵进阶
]]
_G.ReqBingLingLevelUpMsg = {};

ReqBingLingLevelUpMsg.msgId = 3652;
ReqBingLingLevelUpMsg.id = 0; -- 兵灵id



ReqBingLingLevelUpMsg.meta = {__index = ReqBingLingLevelUpMsg };
function ReqBingLingLevelUpMsg:new()
	local obj = setmetatable( {}, ReqBingLingLevelUpMsg.meta);
	return obj;
end

function ReqBingLingLevelUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqBingLingLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
客户端请求：神武升星
]]
_G.ReqShenWuStarUpMsg = {};

ReqShenWuStarUpMsg.msgId = 3654;



ReqShenWuStarUpMsg.meta = {__index = ReqShenWuStarUpMsg };
function ReqShenWuStarUpMsg:new()
	local obj = setmetatable( {}, ReqShenWuStarUpMsg.meta);
	return obj;
end

function ReqShenWuStarUpMsg:encode()
	local body = "";


	return body;
end

function ReqShenWuStarUpMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：神武激活/进阶
]]
_G.ReqShenWuLevelUpMsg = {};

ReqShenWuLevelUpMsg.msgId = 3655;



ReqShenWuLevelUpMsg.meta = {__index = ReqShenWuLevelUpMsg };
function ReqShenWuLevelUpMsg:new()
	local obj = setmetatable( {}, ReqShenWuLevelUpMsg.meta);
	return obj;
end

function ReqShenWuLevelUpMsg:encode()
	local body = "";


	return body;
end

function ReqShenWuLevelUpMsg:ParseData(pak)
	local idx = 1;


end



--[[
赠送红包
]]
_G.ReqGiveRedPacketMsg = {};

ReqGiveRedPacketMsg.msgId = 3656;
ReqGiveRedPacketMsg.type = 0; -- 红包类型(元宝、非绑定银两)
ReqGiveRedPacketMsg.num = 0; -- 元宝、非绑定银两数量
ReqGiveRedPacketMsg.desc = ""; -- 赠言



ReqGiveRedPacketMsg.meta = {__index = ReqGiveRedPacketMsg };
function ReqGiveRedPacketMsg:new()
	local obj = setmetatable( {}, ReqGiveRedPacketMsg.meta);
	return obj;
end

function ReqGiveRedPacketMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);
	body = body ..writeInt(self.num);
	body = body ..writeString(self.desc,64);

	return body;
end

function ReqGiveRedPacketMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);
	self.desc, idx = readString(pak, idx, 64);

end



--[[
发送结婚宝箱
]]
_G.ReqSendMarryBoxMsg = {};

ReqSendMarryBoxMsg.msgId = 3658;



ReqSendMarryBoxMsg.meta = {__index = ReqSendMarryBoxMsg };
function ReqSendMarryBoxMsg:new()
	local obj = setmetatable( {}, ReqSendMarryBoxMsg.meta);
	return obj;
end

function ReqSendMarryBoxMsg:encode()
	local body = "";


	return body;
end

function ReqSendMarryBoxMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：元灵进阶
]]
_G.ReqYuanLingLevelUpMsg = {};

ReqYuanLingLevelUpMsg.msgId = 3660;
ReqYuanLingLevelUpMsg.autobuy = 0; -- 道具不足时是否自动购买, 0自动购买



ReqYuanLingLevelUpMsg.meta = {__index = ReqYuanLingLevelUpMsg };
function ReqYuanLingLevelUpMsg:new()
	local obj = setmetatable( {}, ReqYuanLingLevelUpMsg.meta);
	return obj;
end

function ReqYuanLingLevelUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.autobuy);

	return body;
end

function ReqYuanLingLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.autobuy, idx = readInt(pak, idx);

end



--[[
激活元灵
]]
_G.ReqActiveYuanLingMsg = {};

ReqActiveYuanLingMsg.msgId = 3661;



ReqActiveYuanLingMsg.meta = {__index = ReqActiveYuanLingMsg };
function ReqActiveYuanLingMsg:new()
	local obj = setmetatable( {}, ReqActiveYuanLingMsg.meta);
	return obj;
end

function ReqActiveYuanLingMsg:encode()
	local body = "";


	return body;
end

function ReqActiveYuanLingMsg:ParseData(pak)
	local idx = 1;


end



--[[
切换元灵
]]
_G.ReqChangeYuanLingMsg = {};

ReqChangeYuanLingMsg.msgId = 3662;
ReqChangeYuanLingMsg.yuanlingId = 0; -- 元灵Id



ReqChangeYuanLingMsg.meta = {__index = ReqChangeYuanLingMsg };
function ReqChangeYuanLingMsg:new()
	local obj = setmetatable( {}, ReqChangeYuanLingMsg.meta);
	return obj;
end

function ReqChangeYuanLingMsg:encode()
	local body = "";

	body = body ..writeInt(self.yuanlingId);

	return body;
end

function ReqChangeYuanLingMsg:ParseData(pak)
	local idx = 1;

	self.yuanlingId, idx = readInt(pak, idx);

end



--[[
双方点击是否同意
]]
_G.ReqDivorceXieYiMsg = {};

ReqDivorceXieYiMsg.msgId = 3663;
ReqDivorceXieYiMsg.type = 0; -- 1yes，2no



ReqDivorceXieYiMsg.meta = {__index = ReqDivorceXieYiMsg };
function ReqDivorceXieYiMsg:new()
	local obj = setmetatable( {}, ReqDivorceXieYiMsg.meta);
	return obj;
end

function ReqDivorceXieYiMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqDivorceXieYiMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
请求境界巩固重
]]
_G.ReqStrenthenChongMsg = {};

ReqStrenthenChongMsg.msgId = 3664;
ReqStrenthenChongMsg.chongId = 0; -- 巩固重Id
ReqStrenthenChongMsg.num = 0; -- 巩固次数



ReqStrenthenChongMsg.meta = {__index = ReqStrenthenChongMsg };
function ReqStrenthenChongMsg:new()
	local obj = setmetatable( {}, ReqStrenthenChongMsg.meta);
	return obj;
end

function ReqStrenthenChongMsg:encode()
	local body = "";

	body = body ..writeInt(self.chongId);
	body = body ..writeInt(self.num);

	return body;
end

function ReqStrenthenChongMsg:ParseData(pak)
	local idx = 1;

	self.chongId, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
请求巩固重突破
]]
_G.ReqStrenthenBreakMsg = {};

ReqStrenthenBreakMsg.msgId = 3665;
ReqStrenthenBreakMsg.chongId = 0; -- 巩固重Id



ReqStrenthenBreakMsg.meta = {__index = ReqStrenthenBreakMsg };
function ReqStrenthenBreakMsg:new()
	local obj = setmetatable( {}, ReqStrenthenBreakMsg.meta);
	return obj;
end

function ReqStrenthenBreakMsg:encode()
	local body = "";

	body = body ..writeInt(self.chongId);

	return body;
end

function ReqStrenthenBreakMsg:ParseData(pak)
	local idx = 1;

	self.chongId, idx = readInt(pak, idx);

end



--[[
请求切换境界
]]
_G.ReqChangeRealmModelMsg = {};

ReqChangeRealmModelMsg.msgId = 3666;
ReqChangeRealmModelMsg.id = 0; -- 大于100境界重，小于100境界等阶



ReqChangeRealmModelMsg.meta = {__index = ReqChangeRealmModelMsg };
function ReqChangeRealmModelMsg:new()
	local obj = setmetatable( {}, ReqChangeRealmModelMsg.meta);
	return obj;
end

function ReqChangeRealmModelMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqChangeRealmModelMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
请求信息
]]
_G.ReqSendHallowsMsg = {};

ReqSendHallowsMsg.msgId = 3667;



ReqSendHallowsMsg.meta = {__index = ReqSendHallowsMsg };
function ReqSendHallowsMsg:new()
	local obj = setmetatable( {}, ReqSendHallowsMsg.meta);
	return obj;
end

function ReqSendHallowsMsg:encode()
	local body = "";


	return body;
end

function ReqSendHallowsMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求镶嵌
]]
_G.ReqInlayHallowsMsg = {};

ReqInlayHallowsMsg.msgId = 3668;
ReqInlayHallowsMsg.id = 0; -- 圣灵id
ReqInlayHallowsMsg.guid = ""; -- 道具guid



ReqInlayHallowsMsg.meta = {__index = ReqInlayHallowsMsg };
function ReqInlayHallowsMsg:new()
	local obj = setmetatable( {}, ReqInlayHallowsMsg.meta);
	return obj;
end

function ReqInlayHallowsMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeGuid(self.guid);

	return body;
end

function ReqInlayHallowsMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.guid, idx = readGuid(pak, idx);

end



--[[
请求剥离
]]
_G.ReqPeelHallowsMsg = {};

ReqPeelHallowsMsg.msgId = 3669;
ReqPeelHallowsMsg.id = 0; -- 圣灵id
ReqPeelHallowsMsg.index = 0; -- 镶嵌位置



ReqPeelHallowsMsg.meta = {__index = ReqPeelHallowsMsg };
function ReqPeelHallowsMsg:new()
	local obj = setmetatable( {}, ReqPeelHallowsMsg.meta);
	return obj;
end

function ReqPeelHallowsMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.index);

	return body;
end

function ReqPeelHallowsMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.index, idx = readInt(pak, idx);

end



--[[
切换元灵盾
]]
_G.ReqYuanLingDunMsg = {};

ReqYuanLingDunMsg.msgId = 3671;
ReqYuanLingDunMsg.state = 0; -- 状态0关1开



ReqYuanLingDunMsg.meta = {__index = ReqYuanLingDunMsg };
function ReqYuanLingDunMsg:new()
	local obj = setmetatable( {}, ReqYuanLingDunMsg.meta);
	return obj;
end

function ReqYuanLingDunMsg:encode()
	local body = "";

	body = body ..writeInt(self.state);

	return body;
end

function ReqYuanLingDunMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);

end



--[[
请求改名
]]
_G.ReqChangePlayerNameMsg = {};

ReqChangePlayerNameMsg.msgId = 3672;
ReqChangePlayerNameMsg.itemId = ""; -- 道具Id
ReqChangePlayerNameMsg.roleName = ""; -- 角色名字



ReqChangePlayerNameMsg.meta = {__index = ReqChangePlayerNameMsg };
function ReqChangePlayerNameMsg:new()
	local obj = setmetatable( {}, ReqChangePlayerNameMsg.meta);
	return obj;
end

function ReqChangePlayerNameMsg:encode()
	local body = "";

	body = body ..writeGuid(self.itemId);
	body = body ..writeString(self.roleName,32);

	return body;
end

function ReqChangePlayerNameMsg:ParseData(pak)
	local idx = 1;

	self.itemId, idx = readGuid(pak, idx);
	self.roleName, idx = readString(pak, idx, 32);

end



--[[
请求轮盘抽取
]]
_G.ReqLunPanRollMsg = {};

ReqLunPanRollMsg.msgId = 3674;



ReqLunPanRollMsg.meta = {__index = ReqLunPanRollMsg };
function ReqLunPanRollMsg:new()
	local obj = setmetatable( {}, ReqLunPanRollMsg.meta);
	return obj;
end

function ReqLunPanRollMsg:encode()
	local body = "";


	return body;
end

function ReqLunPanRollMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求轮盘一键10次抽取
]]
_G.ReqLunPanSuperRollMsg = {};

ReqLunPanSuperRollMsg.msgId = 3675;



ReqLunPanSuperRollMsg.meta = {__index = ReqLunPanSuperRollMsg };
function ReqLunPanSuperRollMsg:new()
	local obj = setmetatable( {}, ReqLunPanSuperRollMsg.meta);
	return obj;
end

function ReqLunPanSuperRollMsg:encode()
	local body = "";


	return body;
end

function ReqLunPanSuperRollMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：五行灵脉进阶
]]
_G.ReqWuxinglingmaiLevelUpMsg = {};

ReqWuxinglingmaiLevelUpMsg.msgId = 3678;
ReqWuxinglingmaiLevelUpMsg.autobuy = 0; -- 道具不足时是否自动购买, 0自动购买



ReqWuxinglingmaiLevelUpMsg.meta = {__index = ReqWuxinglingmaiLevelUpMsg };
function ReqWuxinglingmaiLevelUpMsg:new()
	local obj = setmetatable( {}, ReqWuxinglingmaiLevelUpMsg.meta);
	return obj;
end

function ReqWuxinglingmaiLevelUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.autobuy);

	return body;
end

function ReqWuxinglingmaiLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.autobuy, idx = readInt(pak, idx);

end



--[[
激活五行灵脉
]]
_G.ReqActiveWuxinglingmaiMsg = {};

ReqActiveWuxinglingmaiMsg.msgId = 3679;



ReqActiveWuxinglingmaiMsg.meta = {__index = ReqActiveWuxinglingmaiMsg };
function ReqActiveWuxinglingmaiMsg:new()
	local obj = setmetatable( {}, ReqActiveWuxinglingmaiMsg.meta);
	return obj;
end

function ReqActiveWuxinglingmaiMsg:encode()
	local body = "";


	return body;
end

function ReqActiveWuxinglingmaiMsg:ParseData(pak)
	local idx = 1;


end



--[[
交换物品
]]
_G.ReqWuxinglingmaiItemSwapMsg = {};

ReqWuxinglingmaiItemSwapMsg.msgId = 3684;
ReqWuxinglingmaiItemSwapMsg.src_bag = 0; -- 源背包
ReqWuxinglingmaiItemSwapMsg.dst_bag = 0; -- 目标背包
ReqWuxinglingmaiItemSwapMsg.src_idx = 0; -- 源格子
ReqWuxinglingmaiItemSwapMsg.dst_idx = 0; -- 目标格子



ReqWuxinglingmaiItemSwapMsg.meta = {__index = ReqWuxinglingmaiItemSwapMsg };
function ReqWuxinglingmaiItemSwapMsg:new()
	local obj = setmetatable( {}, ReqWuxinglingmaiItemSwapMsg.meta);
	return obj;
end

function ReqWuxinglingmaiItemSwapMsg:encode()
	local body = "";

	body = body ..writeInt(self.src_bag);
	body = body ..writeInt(self.dst_bag);
	body = body ..writeInt(self.src_idx);
	body = body ..writeInt(self.dst_idx);

	return body;
end

function ReqWuxinglingmaiItemSwapMsg:ParseData(pak)
	local idx = 1;

	self.src_bag, idx = readInt(pak, idx);
	self.dst_bag, idx = readInt(pak, idx);
	self.src_idx, idx = readInt(pak, idx);
	self.dst_idx, idx = readInt(pak, idx);

end



--[[
合成五行灵脉
]]
_G.ReqHechengWuxinglingmaiMsg = {};

ReqHechengWuxinglingmaiMsg.msgId = 3685;
ReqHechengWuxinglingmaiMsg.idlist_size = 5; -- 灵玉列表list size
ReqHechengWuxinglingmaiMsg.idlist = {}; -- 灵玉列表list list

--[[
idVoVO = {
	pos = 0; -- 位置
}
]]

ReqHechengWuxinglingmaiMsg.meta = {__index = ReqHechengWuxinglingmaiMsg };
function ReqHechengWuxinglingmaiMsg:new()
	local obj = setmetatable( {}, ReqHechengWuxinglingmaiMsg.meta);
	return obj;
end

function ReqHechengWuxinglingmaiMsg:encode()
	local body = "";


	local list = self.idlist;
	local listSize = 5;

	for i=1,listSize do
		body = body .. writeInt(list[i].pos);
	end

	return body;
end

function ReqHechengWuxinglingmaiMsg:ParseData(pak)
	local idx = 1;


	local list = {};
	self.idlist = list;
	local listSize = 5;

	for i=1,listSize do
		local idVoVo = {};
		idVoVo.pos, idx = readInt(pak, idx);
		table.push(list,idVoVo);
	end

end



--[[
开启套装孔
]]
_G.ReqEquipGroupOpenPosMsg = {};

ReqEquipGroupOpenPosMsg.msgId = 3687;
ReqEquipGroupOpenPosMsg.pos = 0; -- 装备位
ReqEquipGroupOpenPosMsg.index = 0; -- 套装位
ReqEquipGroupOpenPosMsg.groupTid = 0; -- 套装表Id



ReqEquipGroupOpenPosMsg.meta = {__index = ReqEquipGroupOpenPosMsg };
function ReqEquipGroupOpenPosMsg:new()
	local obj = setmetatable( {}, ReqEquipGroupOpenPosMsg.meta);
	return obj;
end

function ReqEquipGroupOpenPosMsg:encode()
	local body = "";

	body = body ..writeInt(self.pos);
	body = body ..writeInt(self.index);
	body = body ..writeInt(self.groupTid);

	return body;
end

function ReqEquipGroupOpenPosMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readInt(pak, idx);
	self.index, idx = readInt(pak, idx);
	self.groupTid, idx = readInt(pak, idx);

end



--[[
设置套装id
]]
_G.ReqEquipGroupOpenSetMsg = {};

ReqEquipGroupOpenSetMsg.msgId = 3688;
ReqEquipGroupOpenSetMsg.pos = 0; -- 装备位
ReqEquipGroupOpenSetMsg.index = 0; -- 套装位
ReqEquipGroupOpenSetMsg.groupTid = 0; -- 套装表Id



ReqEquipGroupOpenSetMsg.meta = {__index = ReqEquipGroupOpenSetMsg };
function ReqEquipGroupOpenSetMsg:new()
	local obj = setmetatable( {}, ReqEquipGroupOpenSetMsg.meta);
	return obj;
end

function ReqEquipGroupOpenSetMsg:encode()
	local body = "";

	body = body ..writeInt(self.pos);
	body = body ..writeInt(self.index);
	body = body ..writeInt(self.groupTid);

	return body;
end

function ReqEquipGroupOpenSetMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readInt(pak, idx);
	self.index, idx = readInt(pak, idx);
	self.groupTid, idx = readInt(pak, idx);

end



--[[
请求升级，套装
]]
_G.ReqEquipGroupUpLvlMsg = {};

ReqEquipGroupUpLvlMsg.msgId = 3689;
ReqEquipGroupUpLvlMsg.pos = 0; -- 装备位
ReqEquipGroupUpLvlMsg.index = 0; -- 套装位
ReqEquipGroupUpLvlMsg.groupTid = 0; -- 套装表Id



ReqEquipGroupUpLvlMsg.meta = {__index = ReqEquipGroupUpLvlMsg };
function ReqEquipGroupUpLvlMsg:new()
	local obj = setmetatable( {}, ReqEquipGroupUpLvlMsg.meta);
	return obj;
end

function ReqEquipGroupUpLvlMsg:encode()
	local body = "";

	body = body ..writeInt(self.pos);
	body = body ..writeInt(self.index);
	body = body ..writeInt(self.groupTid);

	return body;
end

function ReqEquipGroupUpLvlMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readInt(pak, idx);
	self.index, idx = readInt(pak, idx);
	self.groupTid, idx = readInt(pak, idx);

end



--[[
请求挑战本date
]]
_G.ReqDekaronDungeonDateMsg = {};

ReqDekaronDungeonDateMsg.msgId = 3690;



ReqDekaronDungeonDateMsg.meta = {__index = ReqDekaronDungeonDateMsg };
function ReqDekaronDungeonDateMsg:new()
	local obj = setmetatable( {}, ReqDekaronDungeonDateMsg.meta);
	return obj;
end

function ReqDekaronDungeonDateMsg:encode()
	local body = "";


	return body;
end

function ReqDekaronDungeonDateMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求进入挑战副本
]]
_G.ReqDekaronDungeonEnterMsg = {};

ReqDekaronDungeonEnterMsg.msgId = 3691;



ReqDekaronDungeonEnterMsg.meta = {__index = ReqDekaronDungeonEnterMsg };
function ReqDekaronDungeonEnterMsg:new()
	local obj = setmetatable( {}, ReqDekaronDungeonEnterMsg.meta);
	return obj;
end

function ReqDekaronDungeonEnterMsg:encode()
	local body = "";


	return body;
end

function ReqDekaronDungeonEnterMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求退出挑战副本
]]
_G.ReqDekaronDungeonQuitMsg = {};

ReqDekaronDungeonQuitMsg.msgId = 3694;



ReqDekaronDungeonQuitMsg.meta = {__index = ReqDekaronDungeonQuitMsg };
function ReqDekaronDungeonQuitMsg:new()
	local obj = setmetatable( {}, ReqDekaronDungeonQuitMsg.meta);
	return obj;
end

function ReqDekaronDungeonQuitMsg:encode()
	local body = "";


	return body;
end

function ReqDekaronDungeonQuitMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求兽魂升级
]]
_G.ReqShouHunLevelUpMsg = {};

ReqShouHunLevelUpMsg.msgId = 3698;
ReqShouHunLevelUpMsg.tid = 0; -- 兽魂id, 1~7



ReqShouHunLevelUpMsg.meta = {__index = ReqShouHunLevelUpMsg };
function ReqShouHunLevelUpMsg:new()
	local obj = setmetatable( {}, ReqShouHunLevelUpMsg.meta);
	return obj;
end

function ReqShouHunLevelUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.tid);

	return body;
end

function ReqShouHunLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);

end



--[[
戒指强化
]]
_G.ReqMarryRingStrenMsg = {};

ReqMarryRingStrenMsg.msgId = 3699;



ReqMarryRingStrenMsg.meta = {__index = ReqMarryRingStrenMsg };
function ReqMarryRingStrenMsg:new()
	local obj = setmetatable( {}, ReqMarryRingStrenMsg.meta);
	return obj;
end

function ReqMarryRingStrenMsg:encode()
	local body = "";


	return body;
end

function ReqMarryRingStrenMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：战弩进阶
]]
_G.ReqZhanNuLevelUpMsg = {};

ReqZhanNuLevelUpMsg.msgId = 3702;
ReqZhanNuLevelUpMsg.autobuy = 0; -- 道具不足时是否自动购买, 0自动购买



ReqZhanNuLevelUpMsg.meta = {__index = ReqZhanNuLevelUpMsg };
function ReqZhanNuLevelUpMsg:new()
	local obj = setmetatable( {}, ReqZhanNuLevelUpMsg.meta);
	return obj;
end

function ReqZhanNuLevelUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.autobuy);

	return body;
end

function ReqZhanNuLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.autobuy, idx = readInt(pak, idx);

end



--[[
激活战弩
]]
_G.ReqActiveZhanNuMsg = {};

ReqActiveZhanNuMsg.msgId = 3703;



ReqActiveZhanNuMsg.meta = {__index = ReqActiveZhanNuMsg };
function ReqActiveZhanNuMsg:new()
	local obj = setmetatable( {}, ReqActiveZhanNuMsg.meta);
	return obj;
end

function ReqActiveZhanNuMsg:encode()
	local body = "";


	return body;
end

function ReqActiveZhanNuMsg:ParseData(pak)
	local idx = 1;


end



--[[
切换战弩
]]
_G.ReqChangeZhanNuMsg = {};

ReqChangeZhanNuMsg.msgId = 3704;
ReqChangeZhanNuMsg.zhannuId = 0; -- 战弩Id



ReqChangeZhanNuMsg.meta = {__index = ReqChangeZhanNuMsg };
function ReqChangeZhanNuMsg:new()
	local obj = setmetatable( {}, ReqChangeZhanNuMsg.meta);
	return obj;
end

function ReqChangeZhanNuMsg:encode()
	local body = "";

	body = body ..writeInt(self.zhannuId);

	return body;
end

function ReqChangeZhanNuMsg:ParseData(pak)
	local idx = 1;

	self.zhannuId, idx = readInt(pak, idx);

end



--[[
宝石镶嵌
]]
_G.ReqGemInstallMsg = {};

ReqGemInstallMsg.msgId = 3705;
ReqGemInstallMsg.pos = 0; -- 装备位
ReqGemInstallMsg.slot = 0; -- 孔位
ReqGemInstallMsg.tid = 0; -- 宝石id



ReqGemInstallMsg.meta = {__index = ReqGemInstallMsg };
function ReqGemInstallMsg:new()
	local obj = setmetatable( {}, ReqGemInstallMsg.meta);
	return obj;
end

function ReqGemInstallMsg:encode()
	local body = "";

	body = body ..writeInt(self.pos);
	body = body ..writeInt(self.slot);
	body = body ..writeInt(self.tid);

	return body;
end

function ReqGemInstallMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readInt(pak, idx);
	self.slot, idx = readInt(pak, idx);
	self.tid, idx = readInt(pak, idx);

end



--[[
宝石卸载
]]
_G.ReqGemUninstallMsg = {};

ReqGemUninstallMsg.msgId = 3706;
ReqGemUninstallMsg.pos = 0; -- 装备位
ReqGemUninstallMsg.slot = 0; -- 孔位
ReqGemUninstallMsg.tid = 0; -- 宝石id



ReqGemUninstallMsg.meta = {__index = ReqGemUninstallMsg };
function ReqGemUninstallMsg:new()
	local obj = setmetatable( {}, ReqGemUninstallMsg.meta);
	return obj;
end

function ReqGemUninstallMsg:encode()
	local body = "";

	body = body ..writeInt(self.pos);
	body = body ..writeInt(self.slot);
	body = body ..writeInt(self.tid);

	return body;
end

function ReqGemUninstallMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readInt(pak, idx);
	self.slot, idx = readInt(pak, idx);
	self.tid, idx = readInt(pak, idx);

end



--[[
宝石更换
]]
_G.ReqGemChangeMsg = {};

ReqGemChangeMsg.msgId = 3707;
ReqGemChangeMsg.pos = 0; -- 装备位
ReqGemChangeMsg.slot = 0; -- 孔位
ReqGemChangeMsg.gem_oldId = 0; -- 被更换宝石id
ReqGemChangeMsg.gem_newId = 0; -- 更换的宝石id



ReqGemChangeMsg.meta = {__index = ReqGemChangeMsg };
function ReqGemChangeMsg:new()
	local obj = setmetatable( {}, ReqGemChangeMsg.meta);
	return obj;
end

function ReqGemChangeMsg:encode()
	local body = "";

	body = body ..writeInt(self.pos);
	body = body ..writeInt(self.slot);
	body = body ..writeInt(self.gem_oldId);
	body = body ..writeInt(self.gem_newId);

	return body;
end

function ReqGemChangeMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readInt(pak, idx);
	self.slot, idx = readInt(pak, idx);
	self.gem_oldId, idx = readInt(pak, idx);
	self.gem_newId, idx = readInt(pak, idx);

end



--[[
客户端请求: 改变法宝施放目标
]]
_G.ReqFabaoCastTargetMsg = {};

ReqFabaoCastTargetMsg.msgId = 3708;
ReqFabaoCastTargetMsg.fabaoID = ""; -- 法宝ID
ReqFabaoCastTargetMsg.skillID = 0; -- 法宝技能ID
ReqFabaoCastTargetMsg.targetID = ""; -- 如果锁定目标，目标ID
ReqFabaoCastTargetMsg.posX = 0; -- 如果位置施法，位置坐标x
ReqFabaoCastTargetMsg.posY = 0; -- 如果位置施法，位置坐标y



ReqFabaoCastTargetMsg.meta = {__index = ReqFabaoCastTargetMsg };
function ReqFabaoCastTargetMsg:new()
	local obj = setmetatable( {}, ReqFabaoCastTargetMsg.meta);
	return obj;
end

function ReqFabaoCastTargetMsg:encode()
	local body = "";

	body = body ..writeGuid(self.fabaoID);
	body = body ..writeInt(self.skillID);
	body = body ..writeGuid(self.targetID);
	body = body ..writeDouble(self.posX);
	body = body ..writeDouble(self.posY);

	return body;
end

function ReqFabaoCastTargetMsg:ParseData(pak)
	local idx = 1;

	self.fabaoID, idx = readGuid(pak, idx);
	self.skillID, idx = readInt(pak, idx);
	self.targetID, idx = readGuid(pak, idx);
	self.posX, idx = readDouble(pak, idx);
	self.posY, idx = readDouble(pak, idx);

end



--[[
客户端请求：合成法宝
]]
_G.ReqFabaoCombineMsg = {};

ReqFabaoCombineMsg.msgId = 3709;
ReqFabaoCombineMsg.tid = 0; -- 法宝配置id



ReqFabaoCombineMsg.meta = {__index = ReqFabaoCombineMsg };
function ReqFabaoCombineMsg:new()
	local obj = setmetatable( {}, ReqFabaoCombineMsg.meta);
	return obj;
end

function ReqFabaoCombineMsg:encode()
	local body = "";

	body = body ..writeInt(self.tid);

	return body;
end

function ReqFabaoCombineMsg:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);

end



--[[
客户端请求：法宝融合
]]
_G.ReqFabaoDevourMsg = {};

ReqFabaoDevourMsg.msgId = 3710;
ReqFabaoDevourMsg.srcid = ""; -- 原始法宝id
ReqFabaoDevourMsg.dstid = ""; -- 目标法宝id



ReqFabaoDevourMsg.meta = {__index = ReqFabaoDevourMsg };
function ReqFabaoDevourMsg:new()
	local obj = setmetatable( {}, ReqFabaoDevourMsg.meta);
	return obj;
end

function ReqFabaoDevourMsg:encode()
	local body = "";

	body = body ..writeGuid(self.srcid);
	body = body ..writeGuid(self.dstid);

	return body;
end

function ReqFabaoDevourMsg:ParseData(pak)
	local idx = 1;

	self.srcid, idx = readGuid(pak, idx);
	self.dstid, idx = readGuid(pak, idx);

end



--[[
客户端请求：法宝重生
]]
_G.ReqFabaoRebornMsg = {};

ReqFabaoRebornMsg.msgId = 3711;
ReqFabaoRebornMsg.id = ""; -- 法宝id



ReqFabaoRebornMsg.meta = {__index = ReqFabaoRebornMsg };
function ReqFabaoRebornMsg:new()
	local obj = setmetatable( {}, ReqFabaoRebornMsg.meta);
	return obj;
end

function ReqFabaoRebornMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);

	return body;
end

function ReqFabaoRebornMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);

end



--[[
客户端请求：法宝炼书
]]
_G.ReqFabaoLearnMsg = {};

ReqFabaoLearnMsg.msgId = 3712;
ReqFabaoLearnMsg.id = ""; -- 法宝id
ReqFabaoLearnMsg.skillitem = 0; -- 技能书id



ReqFabaoLearnMsg.meta = {__index = ReqFabaoLearnMsg };
function ReqFabaoLearnMsg:new()
	local obj = setmetatable( {}, ReqFabaoLearnMsg.meta);
	return obj;
end

function ReqFabaoLearnMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);
	body = body ..writeInt(self.skillitem);

	return body;
end

function ReqFabaoLearnMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.skillitem, idx = readInt(pak, idx);

end



--[[
客户端请求：召唤法宝
]]
_G.ReqFabaoCallMsg = {};

ReqFabaoCallMsg.msgId = 3713;
ReqFabaoCallMsg.id = ""; -- 法宝id
ReqFabaoCallMsg.state = 0; -- 状态，0=休息，1=召唤，2=丢弃



ReqFabaoCallMsg.meta = {__index = ReqFabaoCallMsg };
function ReqFabaoCallMsg:new()
	local obj = setmetatable( {}, ReqFabaoCallMsg.meta);
	return obj;
end

function ReqFabaoCallMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);
	body = body ..writeInt(self.state);

	return body;
end

function ReqFabaoCallMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
请求装备升星
]]
_G.ReqStrenMsg = {};

ReqStrenMsg.msgId = 3136;
ReqStrenMsg.id = ""; -- 装备cid
ReqStrenMsg.useyuanbao = 0; -- 是否使用元宝 1:true



ReqStrenMsg.meta = {__index = ReqStrenMsg };
function ReqStrenMsg:new()
	local obj = setmetatable( {}, ReqStrenMsg.meta);
	return obj;
end

function ReqStrenMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);
	body = body ..writeInt(self.useyuanbao);

	return body;
end

function ReqStrenMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.useyuanbao, idx = readInt(pak, idx);

end



--[[
请求打开空星位
]]
_G.ReqEmptyStarOpenMsg = {};

ReqEmptyStarOpenMsg.msgId = 3714;
ReqEmptyStarOpenMsg.id = ""; -- 装备cid



ReqEmptyStarOpenMsg.meta = {__index = ReqEmptyStarOpenMsg };
function ReqEmptyStarOpenMsg:new()
	local obj = setmetatable( {}, ReqEmptyStarOpenMsg.meta);
	return obj;
end

function ReqEmptyStarOpenMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);

	return body;
end

function ReqEmptyStarOpenMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);

end



--[[
请求装备合成
]]
_G.ReqEquipMerge = {};

ReqEquipMerge.msgId = 3715;
ReqEquipMerge.id = ""; -- 装备cid
ReqEquipMerge._id = ""; -- 装备cid
ReqEquipMerge.src_bag = 0; -- 装备1背包
ReqEquipMerge.dst_bag = 0; -- 装备2背包



ReqEquipMerge.meta = {__index = ReqEquipMerge };
function ReqEquipMerge:new()
	local obj = setmetatable( {}, ReqEquipMerge.meta);
	return obj;
end

function ReqEquipMerge:encode()
	local body = "";

	body = body ..writeGuid(self.id);
	body = body ..writeGuid(self._id);
	body = body ..writeInt(self.src_bag);
	body = body ..writeInt(self.dst_bag);

	return body;
end

function ReqEquipMerge:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self._id, idx = readGuid(pak, idx);
	self.src_bag, idx = readInt(pak, idx);
	self.dst_bag, idx = readInt(pak, idx);

end



--[[
护盾增加进度
]]
_G.ReqHuDunProgress = {};

ReqHuDunProgress.msgId = 3716;
ReqHuDunProgress.tid = 0; -- 护盾tid
ReqHuDunProgress.itemid = 0; -- 消耗道具id



ReqHuDunProgress.meta = {__index = ReqHuDunProgress };
function ReqHuDunProgress:new()
	local obj = setmetatable( {}, ReqHuDunProgress.meta);
	return obj;
end

function ReqHuDunProgress:encode()
	local body = "";

	body = body ..writeInt(self.tid);
	body = body ..writeInt(self.itemid);

	return body;
end

function ReqHuDunProgress:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);
	self.itemid, idx = readInt(pak, idx);

end



--[[
护盾一键灌注
]]
_G.ReqHuDunAutoUp = {};

ReqHuDunAutoUp.msgId = 3717;
ReqHuDunAutoUp.tid = 0; -- 护盾tid



ReqHuDunAutoUp.meta = {__index = ReqHuDunAutoUp };
function ReqHuDunAutoUp:new()
	local obj = setmetatable( {}, ReqHuDunAutoUp.meta);
	return obj;
end

function ReqHuDunAutoUp:encode()
	local body = "";

	body = body ..writeInt(self.tid);

	return body;
end

function ReqHuDunAutoUp:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);

end



--[[
绝学学习升级突破
]]
_G.ReqJueXueOperMsg = {};

ReqJueXueOperMsg.msgId = 3718;
ReqJueXueOperMsg.type = 0; -- 1=绝学，2=心法
ReqJueXueOperMsg.oper = 0; -- 1=学习，2=升级，3=突破
ReqJueXueOperMsg.gid = 0; -- 组id



ReqJueXueOperMsg.meta = {__index = ReqJueXueOperMsg };
function ReqJueXueOperMsg:new()
	local obj = setmetatable( {}, ReqJueXueOperMsg.meta);
	return obj;
end

function ReqJueXueOperMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);
	body = body ..writeInt(self.oper);
	body = body ..writeInt(self.gid);

	return body;
end

function ReqJueXueOperMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.oper, idx = readInt(pak, idx);
	self.gid, idx = readInt(pak, idx);

end



--[[
伏魔操作
]]
_G.ReqFuMoOperMsg = {};

ReqFuMoOperMsg.msgId = 3719;
ReqFuMoOperMsg.oper = 0; -- 1=开启，2=升级
ReqFuMoOperMsg.id = 0; -- 图鉴id
ReqFuMoOperMsg.cost_num = 0; -- 要消耗的图鉴物品数量



ReqFuMoOperMsg.meta = {__index = ReqFuMoOperMsg };
function ReqFuMoOperMsg:new()
	local obj = setmetatable( {}, ReqFuMoOperMsg.meta);
	return obj;
end

function ReqFuMoOperMsg:encode()
	local body = "";

	body = body ..writeInt(self.oper);
	body = body ..writeInt(self.id);
	body = body ..writeInt(self.cost_num);

	return body;
end

function ReqFuMoOperMsg:ParseData(pak)
	local idx = 1;

	self.oper, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);
	self.cost_num, idx = readInt(pak, idx);

end



--[[
请求转生
]]
_G.ReqZhuanShengMsg = {};

ReqZhuanShengMsg.msgId = 3720;
ReqZhuanShengMsg.tid = 0; -- 转职增加属性配置表tid



ReqZhuanShengMsg.meta = {__index = ReqZhuanShengMsg };
function ReqZhuanShengMsg:new()
	local obj = setmetatable( {}, ReqZhuanShengMsg.meta);
	return obj;
end

function ReqZhuanShengMsg:encode()
	local body = "";

	body = body ..writeInt(self.tid);

	return body;
end

function ReqZhuanShengMsg:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);

end



--[[
完成该任务
]]
_G.ReqFinishZhuanZhiMsg = {};

ReqFinishZhuanZhiMsg.msgId = 3721;
ReqFinishZhuanZhiMsg.tid = 0; -- 转职配置表tid



ReqFinishZhuanZhiMsg.meta = {__index = ReqFinishZhuanZhiMsg };
function ReqFinishZhuanZhiMsg:new()
	local obj = setmetatable( {}, ReqFinishZhuanZhiMsg.meta);
	return obj;
end

function ReqFinishZhuanZhiMsg:encode()
	local body = "";

	body = body ..writeInt(self.tid);

	return body;
end

function ReqFinishZhuanZhiMsg:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);

end



--[[
一键完成所有任务
]]
_G.ReqZhuanZhiAutoFinishMsg = {};

ReqZhuanZhiAutoFinishMsg.msgId = 3722;
ReqZhuanZhiAutoFinishMsg.tid = 0; -- 转职增加属性配置表tid



ReqZhuanZhiAutoFinishMsg.meta = {__index = ReqZhuanZhiAutoFinishMsg };
function ReqZhuanZhiAutoFinishMsg:new()
	local obj = setmetatable( {}, ReqZhuanZhiAutoFinishMsg.meta);
	return obj;
end

function ReqZhuanZhiAutoFinishMsg:encode()
	local body = "";

	body = body ..writeInt(self.tid);

	return body;
end

function ReqZhuanZhiAutoFinishMsg:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);

end



--[[
获取转职奖励
]]
_G.ReqGetZhuanZhiRewardMsg = {};

ReqGetZhuanZhiRewardMsg.msgId = 3723;
ReqGetZhuanZhiRewardMsg.tid = 0; -- 转职配置表tid



ReqGetZhuanZhiRewardMsg.meta = {__index = ReqGetZhuanZhiRewardMsg };
function ReqGetZhuanZhiRewardMsg:new()
	local obj = setmetatable( {}, ReqGetZhuanZhiRewardMsg.meta);
	return obj;
end

function ReqGetZhuanZhiRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.tid);

	return body;
end

function ReqGetZhuanZhiRewardMsg:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);

end



--[[
星图操作
]]
_G.ReqStarOperMsg = {};

ReqStarOperMsg.msgId = 3724;
ReqStarOperMsg.oper = 0; -- 1=手动，2=自动
ReqStarOperMsg.id = 0; -- 星图id，1-28



ReqStarOperMsg.meta = {__index = ReqStarOperMsg };
function ReqStarOperMsg:new()
	local obj = setmetatable( {}, ReqStarOperMsg.meta);
	return obj;
end

function ReqStarOperMsg:encode()
	local body = "";

	body = body ..writeInt(self.oper);
	body = body ..writeInt(self.id);

	return body;
end

function ReqStarOperMsg:ParseData(pak)
	local idx = 1;

	self.oper, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
请求野外Boss列表
]]
_G.ReqFieldBossMsg = {};

ReqFieldBossMsg.msgId = 2276;



ReqFieldBossMsg.meta = {__index = ReqFieldBossMsg };
function ReqFieldBossMsg:new()
	local obj = setmetatable( {}, ReqFieldBossMsg.meta);
	return obj;
end

function ReqFieldBossMsg:encode()
	local body = "";


	return body;
end

function ReqFieldBossMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求地宫Boss列表
]]
_G.ReqDiGongBossMsg = {};

ReqDiGongBossMsg.msgId = 2277;



ReqDiGongBossMsg.meta = {__index = ReqDiGongBossMsg };
function ReqDiGongBossMsg:new()
	local obj = setmetatable( {}, ReqDiGongBossMsg.meta);
	return obj;
end

function ReqDiGongBossMsg:encode()
	local body = "";


	return body;
end

function ReqDiGongBossMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求进入地宫
]]
_G.ReqEnterDiGongMsg = {};

ReqEnterDiGongMsg.msgId = 3725;
ReqEnterDiGongMsg.floor = 0; -- 几层



ReqEnterDiGongMsg.meta = {__index = ReqEnterDiGongMsg };
function ReqEnterDiGongMsg:new()
	local obj = setmetatable( {}, ReqEnterDiGongMsg.meta);
	return obj;
end

function ReqEnterDiGongMsg:encode()
	local body = "";

	body = body ..writeInt(self.floor);

	return body;
end

function ReqEnterDiGongMsg:ParseData(pak)
	local idx = 1;

	self.floor, idx = readInt(pak, idx);

end



--[[
请求退出地宫
]]
_G.ReqQuitDiGongMsg = {};

ReqQuitDiGongMsg.msgId = 3726;



ReqQuitDiGongMsg.meta = {__index = ReqQuitDiGongMsg };
function ReqQuitDiGongMsg:new()
	local obj = setmetatable( {}, ReqQuitDiGongMsg.meta);
	return obj;
end

function ReqQuitDiGongMsg:encode()
	local body = "";


	return body;
end

function ReqQuitDiGongMsg:ParseData(pak)
	local idx = 1;


end






















