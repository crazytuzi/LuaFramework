

--[[
请求登录
MsgType.CL_CONN_SRV
]]
_G.ReqConnSrvMsg = {};

ReqConnSrvMsg.msgId = 1001;
ReqConnSrvMsg.msgType = "CL_CONN_SRV";
ReqConnSrvMsg.msgClassName = "ReqConnSrvMsg";
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
MsgType.CL_CREATE_ROLE_REQ
]]
_G.ReqCreateRoleMsg = {};

ReqCreateRoleMsg.msgId = 1002;
ReqCreateRoleMsg.msgType = "CL_CREATE_ROLE_REQ";
ReqCreateRoleMsg.msgClassName = "ReqCreateRoleMsg";
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
MsgType.CL_CONN_SRV_TX
]]
_G.ReqConnSrvTXMsg = {};

ReqConnSrvTXMsg.msgId = 1005;
ReqConnSrvTXMsg.msgType = "CL_CONN_SRV_TX";
ReqConnSrvTXMsg.msgClassName = "ReqConnSrvTXMsg";
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
MsgType.CW_ENTER_GAME
]]
_G.ReqEnterGameMsg = {};

ReqEnterGameMsg.msgId = 2001;
ReqEnterGameMsg.msgType = "CW_ENTER_GAME";
ReqEnterGameMsg.msgClassName = "ReqEnterGameMsg";
ReqEnterGameMsg.accountID = ""; -- 玩家ID
ReqEnterGameMsg.IP = ""; -- Client IP
ReqEnterGameMsg.mac = ""; -- 物理地址
ReqEnterGameMsg.ltype = 0; -- 登录类型:0web,1微端
ReqEnterGameMsg.channel = 0; -- 渠道ID



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
	body = body ..writeInt64(self.channel);

	return body;
end

function ReqEnterGameMsg:ParseData(pak)
	local idx = 1;

	self.accountID, idx = readString(pak, idx, 32);
	self.IP, idx = readString(pak, idx, 32);
	self.mac, idx = readString(pak, idx, 32);
	self.ltype, idx = readInt(pak, idx);
	self.channel, idx = readInt64(pak, idx);

end



--[[
进入游戏返回
MsgType.WC_ENTER_GAME
]]
_G.ResEnterGameMsg = {};

ResEnterGameMsg.msgId = 7001;
ResEnterGameMsg.msgType = "WC_ENTER_GAME";
ResEnterGameMsg.msgClassName = "ResEnterGameMsg";
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
MsgType.CW_Chat
]]
_G.ReqChatMsg = {};

ReqChatMsg.msgId = 2002;
ReqChatMsg.msgType = "CW_Chat";
ReqChatMsg.msgClassName = "ReqChatMsg";
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
MsgType.CW_PrivateChatState
]]
_G.ReqPrivateChatStateMsg = {};

ReqPrivateChatStateMsg.msgId = 2004;
ReqPrivateChatStateMsg.msgType = "CW_PrivateChatState";
ReqPrivateChatStateMsg.msgClassName = "ReqPrivateChatStateMsg";
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
MsgType.CW_TeamInfo
]]
_G.ReqTeamInfoMsg = {};

ReqTeamInfoMsg.msgId = 2007;
ReqTeamInfoMsg.msgType = "CW_TeamInfo";
ReqTeamInfoMsg.msgClassName = "ReqTeamInfoMsg";
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
MsgType.CW_TeamCreate
]]
_G.ReqTeamCreateMsg = {};

ReqTeamCreateMsg.msgId = 2008;
ReqTeamCreateMsg.msgType = "CW_TeamCreate";
ReqTeamCreateMsg.msgClassName = "ReqTeamCreateMsg";
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
MsgType.CW_TeamApply
]]
_G.ReqTeamApplyMsg = {};

ReqTeamApplyMsg.msgId = 2009;
ReqTeamApplyMsg.msgType = "CW_TeamApply";
ReqTeamApplyMsg.msgClassName = "ReqTeamApplyMsg";
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
MsgType.CW_TeamInvite
]]
_G.ReqTeamInviteMsg = {};

ReqTeamInviteMsg.msgId = 2010;
ReqTeamInviteMsg.msgType = "CW_TeamInvite";
ReqTeamInviteMsg.msgClassName = "ReqTeamInviteMsg";
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
MsgType.CW_TeamQuit
]]
_G.ReqTeamQuitMsg = {};

ReqTeamQuitMsg.msgId = 2011;
ReqTeamQuitMsg.msgType = "CW_TeamQuit";
ReqTeamQuitMsg.msgClassName = "ReqTeamQuitMsg";



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
MsgType.CW_TeamTransfer
]]
_G.ReqTeamTransferMsg = {};

ReqTeamTransferMsg.msgId = 2012;
ReqTeamTransferMsg.msgType = "CW_TeamTransfer";
ReqTeamTransferMsg.msgClassName = "ReqTeamTransferMsg";
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
MsgType.CW_TeamFire
]]
_G.ReqTeamFireMsg = {};

ReqTeamFireMsg.msgId = 2013;
ReqTeamFireMsg.msgType = "CW_TeamFire";
ReqTeamFireMsg.msgClassName = "ReqTeamFireMsg";
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
MsgType.CW_TeamJoinApprove
]]
_G.ReqTeamJoinApproveMsg = {};

ReqTeamJoinApproveMsg.msgId = 2017;
ReqTeamJoinApproveMsg.msgType = "CW_TeamJoinApprove";
ReqTeamJoinApproveMsg.msgClassName = "ReqTeamJoinApproveMsg";
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
MsgType.CW_TeamInviteApprove
]]
_G.ReqTeamInviteApprove = {};

ReqTeamInviteApprove.msgId = 2018;
ReqTeamInviteApprove.msgType = "CW_TeamInviteApprove";
ReqTeamInviteApprove.msgClassName = "ReqTeamInviteApprove";
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
MsgType.CW_TeamSetting
]]
_G.ReqTeamSettingMsg = {};

ReqTeamSettingMsg.msgId = 2019;
ReqTeamSettingMsg.msgType = "CW_TeamSetting";
ReqTeamSettingMsg.msgClassName = "ReqTeamSettingMsg";
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
MsgType.CW_TeamNearbyTeam
]]
_G.ReqTeamNearbyTeamMsg = {};

ReqTeamNearbyTeamMsg.msgId = 2020;
ReqTeamNearbyTeamMsg.msgType = "CW_TeamNearbyTeam";
ReqTeamNearbyTeamMsg.msgClassName = "ReqTeamNearbyTeamMsg";



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
MsgType.CW_TeamNearbyRole
]]
_G.ReqTeamNearbyRoleMsg = {};

ReqTeamNearbyRoleMsg.msgId = 2021;
ReqTeamNearbyRoleMsg.msgType = "CW_TeamNearbyRole";
ReqTeamNearbyRoleMsg.msgClassName = "ReqTeamNearbyRoleMsg";



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
MsgType.CW_SwitchLine
]]
_G.ReqSwitchLineMsg = {};

ReqSwitchLineMsg.msgId = 2023;
ReqSwitchLineMsg.msgType = "CW_SwitchLine";
ReqSwitchLineMsg.msgClassName = "ReqSwitchLineMsg";
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
MsgType.CW_LineList
]]
_G.ReqLineListMsg = {};

ReqLineListMsg.msgId = 2024;
ReqLineListMsg.msgType = "CW_LineList";
ReqLineListMsg.msgClassName = "ReqLineListMsg";



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
MsgType.CW_AddFriend
]]
_G.ReqAddFriend = {};

ReqAddFriend.msgId = 2025;
ReqAddFriend.msgType = "CW_AddFriend";
ReqAddFriend.msgClassName = "ReqAddFriend";
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
MsgType.CW_AddFriendTarget
]]
_G.ReqAddFriendApprove = {};

ReqAddFriendApprove.msgId = 2026;
ReqAddFriendApprove.msgType = "CW_AddFriendTarget";
ReqAddFriendApprove.msgClassName = "ReqAddFriendApprove";
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
MsgType.CW_AddBlackList
]]
_G.ReqAddBlackList = {};

ReqAddBlackList.msgId = 2027;
ReqAddBlackList.msgType = "CW_AddBlackList";
ReqAddBlackList.msgClassName = "ReqAddBlackList";
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
MsgType.CW_RemoveRelation
]]
_G.ReqRemoveRelation = {};

ReqRemoveRelation.msgId = 2028;
ReqRemoveRelation.msgType = "CW_RemoveRelation";
ReqRemoveRelation.msgClassName = "ReqRemoveRelation";
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
MsgType.CW_AddFriendRecommend
]]
_G.ReqAddFriendRecommend = {};

ReqAddFriendRecommend.msgId = 2029;
ReqAddFriendRecommend.msgType = "CW_AddFriendRecommend";
ReqAddFriendRecommend.msgClassName = "ReqAddFriendRecommend";
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
MsgType.CW_AskRecommendList
]]
_G.ReqAskRecommendList = {};

ReqAskRecommendList.msgId = 2030;
ReqAskRecommendList.msgType = "CW_AskRecommendList";
ReqAskRecommendList.msgClassName = "ReqAskRecommendList";



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
MsgType.CW_RelationChangeList
]]
_G.ReqRelationChangeList = {};

ReqRelationChangeList.msgId = 2031;
ReqRelationChangeList.msgType = "CW_RelationChangeList";
ReqRelationChangeList.msgClassName = "ReqRelationChangeList";



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
MsgType.CW_GetMailList
]]
_G.ReqGetMailList = {};

ReqGetMailList.msgId = 2032;
ReqGetMailList.msgType = "CW_GetMailList";
ReqGetMailList.msgClassName = "ReqGetMailList";



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
MsgType.CW_OpenMail
]]
_G.ReqOpenMail = {};

ReqOpenMail.msgId = 2033;
ReqOpenMail.msgType = "CW_OpenMail";
ReqOpenMail.msgClassName = "ReqOpenMail";
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
MsgType.CW_GetMailItem
]]
_G.ReqMailItem = {};

ReqMailItem.msgId = 2034;
ReqMailItem.msgType = "CW_GetMailItem";
ReqMailItem.msgClassName = "ReqMailItem";
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
MsgType.CW_DelMail
]]
_G.ReqDelMail = {};

ReqDelMail.msgId = 2035;
ReqDelMail.msgType = "CW_DelMail";
ReqDelMail.msgClassName = "ReqDelMail";
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
MsgType.CW_ReplyTeamDungeon
]]
_G.ReqReplyTeamDungeonMsg = {};

ReqReplyTeamDungeonMsg.msgId = 2037;
ReqReplyTeamDungeonMsg.msgType = "CW_ReplyTeamDungeon";
ReqReplyTeamDungeonMsg.msgClassName = "ReqReplyTeamDungeonMsg";
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
MsgType.CW_QueryGuildList
]]
_G.ReqGuildList = {};

ReqGuildList.msgId = 2038;
ReqGuildList.msgType = "CW_QueryGuildList";
ReqGuildList.msgClassName = "ReqGuildList";
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
MsgType.CW_QueryMyGuildInfo
]]
_G.ReqMyGuildInfo = {};

ReqMyGuildInfo.msgId = 2039;
ReqMyGuildInfo.msgType = "CW_QueryMyGuildInfo";
ReqMyGuildInfo.msgClassName = "ReqMyGuildInfo";



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
MsgType.CW_QueryMyGuildMems
]]
_G.ReqMyGuildMems = {};

ReqMyGuildMems.msgId = 2040;
ReqMyGuildMems.msgType = "CW_QueryMyGuildMems";
ReqMyGuildMems.msgClassName = "ReqMyGuildMems";



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
MsgType.CW_QueryMyGuildEvent
]]
_G.ReqMyGuildEvents = {};

ReqMyGuildEvents.msgId = 2041;
ReqMyGuildEvents.msgType = "CW_QueryMyGuildEvent";
ReqMyGuildEvents.msgClassName = "ReqMyGuildEvents";



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
MsgType.CW_CreateGuild
]]
_G.ReqCreateGuild = {};

ReqCreateGuild.msgId = 2042;
ReqCreateGuild.msgType = "CW_CreateGuild";
ReqCreateGuild.msgClassName = "ReqCreateGuild";
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
MsgType.CW_QuitGuild
]]
_G.ReqQuitGuild = {};

ReqQuitGuild.msgId = 2043;
ReqQuitGuild.msgType = "CW_QuitGuild";
ReqQuitGuild.msgClassName = "ReqQuitGuild";



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
MsgType.CW_DismissGuild
]]
_G.ReqDismissGuild = {};

ReqDismissGuild.msgId = 2044;
ReqDismissGuild.msgType = "CW_DismissGuild";
ReqDismissGuild.msgClassName = "ReqDismissGuild";



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
MsgType.CW_LvUpGuild
]]
_G.ReqLvUpGuild = {};

ReqLvUpGuild.msgId = 2045;
ReqLvUpGuild.msgType = "CW_LvUpGuild";
ReqLvUpGuild.msgClassName = "ReqLvUpGuild";



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
MsgType.CW_LvUpGuildSkill
]]
_G.ReqLvUpGuildSkill = {};

ReqLvUpGuildSkill.msgId = 2046;
ReqLvUpGuildSkill.msgType = "CW_LvUpGuildSkill";
ReqLvUpGuildSkill.msgClassName = "ReqLvUpGuildSkill";
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
MsgType.CW_ChangeGuildPos
]]
_G.ReqChangeGuildPos = {};

ReqChangeGuildPos.msgId = 2047;
ReqChangeGuildPos.msgType = "CW_ChangeGuildPos";
ReqChangeGuildPos.msgClassName = "ReqChangeGuildPos";
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
MsgType.CW_ChangeGuildNotice
]]
_G.ReqChangeGuildNotice = {};

ReqChangeGuildNotice.msgId = 2048;
ReqChangeGuildNotice.msgType = "CW_ChangeGuildNotice";
ReqChangeGuildNotice.msgClassName = "ReqChangeGuildNotice";
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
MsgType.CW_VerifyGuildApply
]]
_G.ReqVerifyGuildApply = {};

ReqVerifyGuildApply.msgId = 2049;
ReqVerifyGuildApply.msgType = "CW_VerifyGuildApply";
ReqVerifyGuildApply.msgClassName = "ReqVerifyGuildApply";
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
MsgType.CW_KickGuildMem
]]
_G.ReqKickGuildMem = {};

ReqKickGuildMem.msgId = 2050;
ReqKickGuildMem.msgType = "CW_KickGuildMem";
ReqKickGuildMem.msgClassName = "ReqKickGuildMem";
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
MsgType.CW_ApplyGuild
]]
_G.ReqApplyGuild = {};

ReqApplyGuild.msgId = 2051;
ReqApplyGuild.msgType = "CW_ApplyGuild";
ReqApplyGuild.msgClassName = "ReqApplyGuild";
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
MsgType.CW_InviteToGuild
]]
_G.ReqInviteToGuild = {};

ReqInviteToGuild.msgId = 2052;
ReqInviteToGuild.msgType = "CW_InviteToGuild";
ReqInviteToGuild.msgClassName = "ReqInviteToGuild";
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
MsgType.CW_InviteToGuildResult
]]
_G.ReqInviteToGuildResult = {};

ReqInviteToGuildResult.msgId = 2053;
ReqInviteToGuildResult.msgType = "CW_InviteToGuildResult";
ReqInviteToGuildResult.msgClassName = "ReqInviteToGuildResult";
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
MsgType.CW_SetAutoVerify
]]
_G.ReqSetAutoVerify = {};

ReqSetAutoVerify.msgId = 2055;
ReqSetAutoVerify.msgType = "CW_SetAutoVerify";
ReqSetAutoVerify.msgClassName = "ReqSetAutoVerify";
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
MsgType.CW_QueryOtherGuildInfo
]]
_G.ReqOtherGuildInfo = {};

ReqOtherGuildInfo.msgId = 2056;
ReqOtherGuildInfo.msgType = "CW_QueryOtherGuildInfo";
ReqOtherGuildInfo.msgClassName = "ReqOtherGuildInfo";
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
MsgType.CW_QueryMyGuildApplys
]]
_G.ReqMyGuildApplys = {};

ReqMyGuildApplys.msgId = 2057;
ReqMyGuildApplys.msgType = "CW_QueryMyGuildApplys";
ReqMyGuildApplys.msgClassName = "ReqMyGuildApplys";



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
MsgType.CW_ChangeLeader
]]
_G.ReqChangeLeader = {};

ReqChangeLeader.msgId = 2058;
ReqChangeLeader.msgType = "CW_ChangeLeader";
ReqChangeLeader.msgClassName = "ReqChangeLeader";
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
MsgType.CW_GuildContribute
]]
_G.ReqGuildContribute = {};

ReqGuildContribute.msgId = 2059;
ReqGuildContribute.msgType = "CW_GuildContribute";
ReqGuildContribute.msgClassName = "ReqGuildContribute";
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
MsgType.CW_LevelUpMyGuildSkill
]]
_G.ReqLevelUpMyGuildSkill = {};

ReqLevelUpMyGuildSkill.msgId = 2060;
ReqLevelUpMyGuildSkill.msgType = "CW_LevelUpMyGuildSkill";
ReqLevelUpMyGuildSkill.msgClassName = "ReqLevelUpMyGuildSkill";
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
MsgType.CW_SearchGuild
]]
_G.ReqSearchGuild = {};

ReqSearchGuild.msgId = 2061;
ReqSearchGuild.msgType = "CW_SearchGuild";
ReqSearchGuild.msgClassName = "ReqSearchGuild";
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
MsgType.CW_WorldBoss
]]
_G.ReqWorldBossMsg = {};

ReqWorldBossMsg.msgId = 2063;
ReqWorldBossMsg.msgType = "CW_WorldBoss";
ReqWorldBossMsg.msgClassName = "ReqWorldBossMsg";



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
MsgType.CW_GuildAliance
]]
_G.ReqGuildAlianceMsg = {};

ReqGuildAlianceMsg.msgId = 2064;
ReqGuildAlianceMsg.msgType = "CW_GuildAliance";
ReqGuildAlianceMsg.msgClassName = "ReqGuildAlianceMsg";
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
MsgType.CW_DismissGuildAliance
]]
_G.ReqDismissGuildAlianceMsg = {};

ReqDismissGuildAlianceMsg.msgId = 2065;
ReqDismissGuildAlianceMsg.msgType = "CW_DismissGuildAliance";
ReqDismissGuildAlianceMsg.msgClassName = "ReqDismissGuildAlianceMsg";



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
MsgType.CW_QueryGuildAlianceApplys
]]
_G.ReqGuildAlianceApplysMsg = {};

ReqGuildAlianceApplysMsg.msgId = 2066;
ReqGuildAlianceApplysMsg.msgType = "CW_QueryGuildAlianceApplys";
ReqGuildAlianceApplysMsg.msgClassName = "ReqGuildAlianceApplysMsg";



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
MsgType.CW_QueryAlianceGuildInfo
]]
_G.ReqAlianceGuildInfo = {};

ReqAlianceGuildInfo.msgId = 2067;
ReqAlianceGuildInfo.msgType = "CW_QueryAlianceGuildInfo";
ReqAlianceGuildInfo.msgClassName = "ReqAlianceGuildInfo";



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
MsgType.CW_GuildAlianceVerify
]]
_G.ReqGuildAlianceVerifyMsg = {};

ReqGuildAlianceVerifyMsg.msgId = 2068;
ReqGuildAlianceVerifyMsg.msgType = "CW_GuildAlianceVerify";
ReqGuildAlianceVerifyMsg.msgClassName = "ReqGuildAlianceVerifyMsg";
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
MsgType.CW_ReqClearBapAidInfo
]]
_G.ReqClearBapAidInfoMsg = {};

ReqClearBapAidInfoMsg.msgId = 2069;
ReqClearBapAidInfoMsg.msgType = "CW_ReqClearBapAidInfo";
ReqClearBapAidInfoMsg.msgClassName = "ReqClearBapAidInfoMsg";
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
MsgType.CW_ReqUnionBapAid
]]
_G.ReqUnionBapAidMsg = {};

ReqUnionBapAidMsg.msgId = 2072;
ReqUnionBapAidMsg.msgType = "CW_ReqUnionBapAid";
ReqUnionBapAidMsg.msgClassName = "ReqUnionBapAidMsg";



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
MsgType.CW_ReqAidInfo
]]
_G.ReqAidInfoMsg = {};

ReqAidInfoMsg.msgId = 2071;
ReqAidInfoMsg.msgType = "CW_ReqAidInfo";
ReqAidInfoMsg.msgClassName = "ReqAidInfoMsg";



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
MsgType.CW_ReqAidUpLevel
]]
_G.ReqAidUpLevelMsg = {};

ReqAidUpLevelMsg.msgId = 2073;
ReqAidUpLevelMsg.msgType = "CW_ReqAidUpLevel";
ReqAidUpLevelMsg.msgClassName = "ReqAidUpLevelMsg";



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
MsgType.CW_ArenaInfo
]]
_G.ReqArenaMyroleAtbMsg = {};

ReqArenaMyroleAtbMsg.msgId = 2100;
ReqArenaMyroleAtbMsg.msgType = "CW_ArenaInfo";
ReqArenaMyroleAtbMsg.msgClassName = "ReqArenaMyroleAtbMsg";



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
MsgType.CW_ArenaList
]]
_G.ReqArenaBeChallengeRolelistMsg = {};

ReqArenaBeChallengeRolelistMsg.msgId = 2101;
ReqArenaBeChallengeRolelistMsg.msgType = "CW_ArenaList";
ReqArenaBeChallengeRolelistMsg.msgClassName = "ReqArenaBeChallengeRolelistMsg";
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
MsgType.CW_ArenaChallenge
]]
_G.ReqArenaChallengeMsg = {};

ReqArenaChallengeMsg.msgId = 2102;
ReqArenaChallengeMsg.msgType = "CW_ArenaChallenge";
ReqArenaChallengeMsg.msgClassName = "ReqArenaChallengeMsg";
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
MsgType.CW_ArenaReward
]]
_G.ReqArenaGetRewardItemMsg = {};

ReqArenaGetRewardItemMsg.msgId = 2103;
ReqArenaGetRewardItemMsg.msgType = "CW_ArenaReward";
ReqArenaGetRewardItemMsg.msgClassName = "ReqArenaGetRewardItemMsg";



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
MsgType.CW_ArenaSkInfo
]]
_G.ReqArenaSkillInfoMsg = {};

ReqArenaSkillInfoMsg.msgId = 2104;
ReqArenaSkillInfoMsg.msgType = "CW_ArenaSkInfo";
ReqArenaSkillInfoMsg.msgClassName = "ReqArenaSkillInfoMsg";



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
MsgType.CW_BuyArenaTimes
]]
_G.ReqBuyArenaTimesMsg = {};

ReqBuyArenaTimesMsg.msgId = 2105;
ReqBuyArenaTimesMsg.msgType = "CW_BuyArenaTimes";
ReqBuyArenaTimesMsg.msgClassName = "ReqBuyArenaTimesMsg";



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
MsgType.CW_BuyArenaCD
]]
_G.ReqBuyArenaCDMsg = {};

ReqBuyArenaCDMsg.msgId = 2106;
ReqBuyArenaCDMsg.msgType = "CW_BuyArenaCD";
ReqBuyArenaCDMsg.msgClassName = "ReqBuyArenaCDMsg";



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
MsgType.CW_QueryGuildHellInfo
]]
_G.ReqQueryGuildHellInfoMsg = {};

ReqQueryGuildHellInfoMsg.msgId = 2107;
ReqQueryGuildHellInfoMsg.msgType = "CW_QueryGuildHellInfo";
ReqQueryGuildHellInfoMsg.msgClassName = "ReqQueryGuildHellInfoMsg";



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
MsgType.CW_EnterGuildHell
]]
_G.ReqEnterGuildHellMsg = {};

ReqEnterGuildHellMsg.msgId = 2108;
ReqEnterGuildHellMsg.msgType = "CW_EnterGuildHell";
ReqEnterGuildHellMsg.msgClassName = "ReqEnterGuildHellMsg";
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
MsgType.CW_ReqRanklist
]]
_G.ReqRanklistMsg = {};

ReqRanklistMsg.msgId = 2113;
ReqRanklistMsg.msgType = "CW_ReqRanklist";
ReqRanklistMsg.msgClassName = "ReqRanklistMsg";
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
MsgType.CW_RankHumanInfo
]]
_G.ReqRankHumanInfoMsg = {};

ReqRankHumanInfoMsg.msgId = 2114;
ReqRankHumanInfoMsg.msgType = "CW_RankHumanInfo";
ReqRankHumanInfoMsg.msgClassName = "ReqRankHumanInfoMsg";
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
MsgType.CW_UnionWarAct
]]
_G.ReqUnionWarActMsg = {};

ReqUnionWarActMsg.msgId = 2115;
ReqUnionWarActMsg.msgType = "CW_UnionWarAct";
ReqUnionWarActMsg.msgClassName = "ReqUnionWarActMsg";



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
MsgType.CW_ActivationCode
]]
_G.ReqActivationCodeMsg = {};

ReqActivationCodeMsg.msgId = 2116;
ReqActivationCodeMsg.msgType = "CW_ActivationCode";
ReqActivationCodeMsg.msgClassName = "ReqActivationCodeMsg";
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
MsgType.CW_UnionEnterCityWar
]]
_G.ReqUnionEnterCityWarMsg = {};

ReqUnionEnterCityWarMsg.msgId = 2117;
ReqUnionEnterCityWarMsg.msgType = "CW_UnionEnterCityWar";
ReqUnionEnterCityWarMsg.msgClassName = "ReqUnionEnterCityWarMsg";



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
MsgType.CW_AllServerReqRanklist
]]
_G.ReqAllServerRanklistMsg = {};

ReqAllServerRanklistMsg.msgId = 2120;
ReqAllServerRanklistMsg.msgType = "CW_AllServerReqRanklist";
ReqAllServerRanklistMsg.msgClassName = "ReqAllServerRanklistMsg";
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
MsgType.CW_AllServerRankHumanInfo
]]
_G.ReqAllServerRankHumanInfoMsg = {};

ReqAllServerRankHumanInfoMsg.msgId = 2121;
ReqAllServerRankHumanInfoMsg.msgType = "CW_AllServerRankHumanInfo";
ReqAllServerRankHumanInfoMsg.msgClassName = "ReqAllServerRankHumanInfoMsg";
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
MsgType.CW_SuperGloryRoleinfo
]]
_G.ReqSuperGloryRoleinfoMsg = {};

ReqSuperGloryRoleinfoMsg.msgId = 2122;
ReqSuperGloryRoleinfoMsg.msgType = "CW_SuperGloryRoleinfo";
ReqSuperGloryRoleinfoMsg.msgClassName = "ReqSuperGloryRoleinfoMsg";



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
MsgType.CW_SuperGloryWroship
]]
_G.ReqSuperGloryWroshipMsg = {};

ReqSuperGloryWroshipMsg.msgId = 2124;
ReqSuperGloryWroshipMsg.msgType = "CW_SuperGloryWroship";
ReqSuperGloryWroshipMsg.msgClassName = "ReqSuperGloryWroshipMsg";



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
MsgType.CW_SuperGlorySendBag
]]
_G.ReqSuperGlorySendBagMsg = {};

ReqSuperGlorySendBagMsg.msgId = 2125;
ReqSuperGlorySendBagMsg.msgType = "CW_SuperGlorySendBag";
ReqSuperGlorySendBagMsg.msgClassName = "ReqSuperGlorySendBagMsg";



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
MsgType.CW_SuperGlorySendBagUp
]]
_G.ReqSuperGlorySendBagUpMsg = {};

ReqSuperGlorySendBagUpMsg.msgId = 2126;
ReqSuperGlorySendBagUpMsg.msgType = "CW_SuperGlorySendBagUp";
ReqSuperGlorySendBagUpMsg.msgClassName = "ReqSuperGlorySendBagUpMsg";
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
MsgType.CW_SuperGloryReqSetDeputy
]]
_G.ReqSuperGloryReqSetDeputyMsg = {};

ReqSuperGloryReqSetDeputyMsg.msgId = 2127;
ReqSuperGloryReqSetDeputyMsg.msgType = "CW_SuperGloryReqSetDeputy";
ReqSuperGloryReqSetDeputyMsg.msgClassName = "ReqSuperGloryReqSetDeputyMsg";



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
MsgType.CW_SuperGlorySetDeputy
]]
_G.ReqSuperGlorySetDeputyMsg = {};

ReqSuperGlorySetDeputyMsg.msgId = 2128;
ReqSuperGlorySetDeputyMsg.msgType = "CW_SuperGlorySetDeputy";
ReqSuperGlorySetDeputyMsg.msgClassName = "ReqSuperGlorySetDeputyMsg";
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
MsgType.CW_UnionWareInfomation
]]
_G.ReqUnionWareInfomationMsg = {};

ReqUnionWareInfomationMsg.msgId = 2129;
ReqUnionWareInfomationMsg.msgType = "CW_UnionWareInfomation";
ReqUnionWareInfomationMsg.msgClassName = "ReqUnionWareInfomationMsg";



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
MsgType.CW_UnionWareHouseinfo
]]
_G.ReqUnionWareHouseinfoMsg = {};

ReqUnionWareHouseinfoMsg.msgId = 2130;
ReqUnionWareHouseinfoMsg.msgType = "CW_UnionWareHouseinfo";
ReqUnionWareHouseinfoMsg.msgClassName = "ReqUnionWareHouseinfoMsg";



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
MsgType.CW_UnionWareSmeliting
]]
_G.ReqUnionWareHouseSmelitingMsg = {};

ReqUnionWareHouseSmelitingMsg.msgId = 2132;
ReqUnionWareHouseSmelitingMsg.msgType = "CW_UnionWareSmeliting";
ReqUnionWareHouseSmelitingMsg.msgClassName = "ReqUnionWareHouseSmelitingMsg";
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
MsgType.CW_UnionWareHouseTake
]]
_G.ReqUnionWareHouseTakeMsg = {};

ReqUnionWareHouseTakeMsg.msgId = 2133;
ReqUnionWareHouseTakeMsg.msgType = "CW_UnionWareHouseTake";
ReqUnionWareHouseTakeMsg.msgClassName = "ReqUnionWareHouseTakeMsg";
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
MsgType.CW_UnionWareHouseSave
]]
_G.ReqUnionWareHouseSaveMsg = {};

ReqUnionWareHouseSaveMsg.msgId = 2134;
ReqUnionWareHouseSaveMsg.msgType = "CW_UnionWareHouseSave";
ReqUnionWareHouseSaveMsg.msgClassName = "ReqUnionWareHouseSaveMsg";
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
MsgType.CW_MClientLoginUrl
]]
_G.ReqMClentLoginUrlMsg = {};

ReqMClentLoginUrlMsg.msgId = 2135;
ReqMClentLoginUrlMsg.msgType = "CW_MClientLoginUrl";
ReqMClentLoginUrlMsg.msgClassName = "ReqMClentLoginUrlMsg";



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
MsgType.CW_HeartBeat
]]
_G.ReqHeartBeatMsg = {};

ReqHeartBeatMsg.msgId = 2136;
ReqHeartBeatMsg.msgType = "CW_HeartBeat";
ReqHeartBeatMsg.msgClassName = "ReqHeartBeatMsg";
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
MsgType.CW_ZhancSignUp
]]
_G.ReqZhancSignUpMsg = {};

ReqZhancSignUpMsg.msgId = 2137;
ReqZhancSignUpMsg.msgType = "CW_ZhancSignUp";
ReqZhancSignUpMsg.msgClassName = "ReqZhancSignUpMsg";
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
MsgType.CW_VPlan
]]
_G.ReqVPlanMsg = {};

ReqVPlanMsg.msgId = 2138;
ReqVPlanMsg.msgType = "CW_VPlan";
ReqVPlanMsg.msgClassName = "ReqVPlanMsg";



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
MsgType.CW_ReqGetUnionPray
]]
_G.ReqGetUnionPrayMsg = {};

ReqGetUnionPrayMsg.msgId = 2139;
ReqGetUnionPrayMsg.msgType = "CW_ReqGetUnionPray";
ReqGetUnionPrayMsg.msgClassName = "ReqGetUnionPrayMsg";



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
MsgType.CW_ReqUnionPray
]]
_G.ReqUnionPrayMsg = {};

ReqUnionPrayMsg.msgId = 2141;
ReqUnionPrayMsg.msgType = "CW_ReqUnionPray";
ReqUnionPrayMsg.msgClassName = "ReqUnionPrayMsg";
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
MsgType.CW_ConsignmentItemInfo
]]
_G.ReqConsignmentItemInfoMsg = {};

ReqConsignmentItemInfoMsg.msgId = 2142;
ReqConsignmentItemInfoMsg.msgType = "CW_ConsignmentItemInfo";
ReqConsignmentItemInfoMsg.msgClassName = "ReqConsignmentItemInfoMsg";
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
MsgType.CW_ConsignmentItemBuy
]]
_G.ReqConsignmentItemBuyMsg = {};

ReqConsignmentItemBuyMsg.msgId = 2143;
ReqConsignmentItemBuyMsg.msgType = "CW_ConsignmentItemBuy";
ReqConsignmentItemBuyMsg.msgClassName = "ReqConsignmentItemBuyMsg";
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
MsgType.CW_ConsignmentItemOutShelves
]]
_G.ReqConsignmentItemOutShelvesMsg = {};

ReqConsignmentItemOutShelvesMsg.msgId = 2144;
ReqConsignmentItemOutShelvesMsg.msgType = "CW_ConsignmentItemOutShelves";
ReqConsignmentItemOutShelvesMsg.msgClassName = "ReqConsignmentItemOutShelvesMsg";
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
MsgType.CW_FriendRewardGet
]]
_G.ReqFriendRewardGetMsg = {};

ReqFriendRewardGetMsg.msgId = 2146;
ReqFriendRewardGetMsg.msgType = "CW_FriendRewardGet";
ReqFriendRewardGetMsg.msgClassName = "ReqFriendRewardGetMsg";



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
MsgType.CW_MyConsignmentItemInfo
]]
_G.ReqMyConsignmentItemInfoMsg = {};

ReqMyConsignmentItemInfoMsg.msgId = 2147;
ReqMyConsignmentItemInfoMsg.msgType = "CW_MyConsignmentItemInfo";
ReqMyConsignmentItemInfoMsg.msgClassName = "ReqMyConsignmentItemInfoMsg";



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
MsgType.CW_MyConsignmentEarnInfo
]]
_G.ReqMyConsignmentEarnInfoMsg = {};

ReqMyConsignmentEarnInfoMsg.msgId = 2148;
ReqMyConsignmentEarnInfoMsg.msgType = "CW_MyConsignmentEarnInfo";
ReqMyConsignmentEarnInfoMsg.msgClassName = "ReqMyConsignmentEarnInfoMsg";



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
MsgType.CW_GuildReplyCountTip
]]
_G.ReqGuildReplyCountTipMsg = {};

ReqGuildReplyCountTipMsg.msgId = 2149;
ReqGuildReplyCountTipMsg.msgType = "CW_GuildReplyCountTip";
ReqGuildReplyCountTipMsg.msgClassName = "ReqGuildReplyCountTipMsg";



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
MsgType.CW_GetExtremityRankData
]]
_G.ReqGetExtremityRankDataMsg = {};

ReqGetExtremityRankDataMsg.msgId = 2150;
ReqGetExtremityRankDataMsg.msgType = "CW_GetExtremityRankData";
ReqGetExtremityRankDataMsg.msgClassName = "ReqGetExtremityRankDataMsg";



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
MsgType.CW_GetNewExtremityData
]]
_G.ReqGetNewExtremityDataMsg = {};

ReqGetNewExtremityDataMsg.msgId = 2151;
ReqGetNewExtremityDataMsg.msgType = "CW_GetNewExtremityData";
ReqGetNewExtremityDataMsg.msgClassName = "ReqGetNewExtremityDataMsg";



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
MsgType.CW_SendExtremityRank
]]
_G.ReqExtremityRankDataMsg = {};

ReqExtremityRankDataMsg.msgId = 2152;
ReqExtremityRankDataMsg.msgType = "CW_SendExtremityRank";
ReqExtremityRankDataMsg.msgClassName = "ReqExtremityRankDataMsg";
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
MsgType.CW_TimeDungeonRoom
]]
_G.ReqTimeDungeonRoomMsg = {};

ReqTimeDungeonRoomMsg.msgId = 2153;
ReqTimeDungeonRoomMsg.msgType = "CW_TimeDungeonRoom";
ReqTimeDungeonRoomMsg.msgClassName = "ReqTimeDungeonRoomMsg";
ReqTimeDungeonRoomMsg.dungeonType = 0; -- 副本类型



ReqTimeDungeonRoomMsg.meta = {__index = ReqTimeDungeonRoomMsg };
function ReqTimeDungeonRoomMsg:new()
	local obj = setmetatable( {}, ReqTimeDungeonRoomMsg.meta);
	return obj;
end

function ReqTimeDungeonRoomMsg:encode()
	local body = "";

	body = body ..writeInt(self.dungeonType);

	return body;
end

function ReqTimeDungeonRoomMsg:ParseData(pak)
	local idx = 1;

	self.dungeonType, idx = readInt(pak, idx);

end



--[[
客户端请求：灵光封魔快速房间
MsgType.CW_QuickEnterRoom
]]
_G.ReqQuickTimeDungeonRoomMsg = {};

ReqQuickTimeDungeonRoomMsg.msgId = 2155;
ReqQuickTimeDungeonRoomMsg.msgType = "CW_QuickEnterRoom";
ReqQuickTimeDungeonRoomMsg.msgClassName = "ReqQuickTimeDungeonRoomMsg";
ReqQuickTimeDungeonRoomMsg.dungeonType = 0; -- 副本类型



ReqQuickTimeDungeonRoomMsg.meta = {__index = ReqQuickTimeDungeonRoomMsg };
function ReqQuickTimeDungeonRoomMsg:new()
	local obj = setmetatable( {}, ReqQuickTimeDungeonRoomMsg.meta);
	return obj;
end

function ReqQuickTimeDungeonRoomMsg:encode()
	local body = "";

	body = body ..writeInt(self.dungeonType);

	return body;
end

function ReqQuickTimeDungeonRoomMsg:ParseData(pak)
	local idx = 1;

	self.dungeonType, idx = readInt(pak, idx);

end



--[[
客户端请求：灵光封魔请求创建
MsgType.CW_CreateRoom
]]
_G.ReqTimeDungeonRoomBuildMsg = {};

ReqTimeDungeonRoomBuildMsg.msgId = 2156;
ReqTimeDungeonRoomBuildMsg.msgType = "CW_CreateRoom";
ReqTimeDungeonRoomBuildMsg.msgClassName = "ReqTimeDungeonRoomBuildMsg";
ReqTimeDungeonRoomBuildMsg.dungeonType = 0; -- 副本类型
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

	body = body ..writeInt(self.dungeonType);
	body = body ..writeInt(self.dungeonIndex);
	body = body ..writeString(self.password,32);
	body = body ..writeInt(self.attLimit);

	return body;
end

function ReqTimeDungeonRoomBuildMsg:ParseData(pak)
	local idx = 1;

	self.dungeonType, idx = readInt(pak, idx);
	self.dungeonIndex, idx = readInt(pak, idx);
	self.password, idx = readString(pak, idx, 32);
	self.attLimit, idx = readInt(pak, idx);

end



--[[
客户端请求：切换准备状态
MsgType.CW_RoomPrepare
]]
_G.ReqTimeDungeonPrepareMsg = {};

ReqTimeDungeonPrepareMsg.msgId = 2157;
ReqTimeDungeonPrepareMsg.msgType = "CW_RoomPrepare";
ReqTimeDungeonPrepareMsg.msgClassName = "ReqTimeDungeonPrepareMsg";
ReqTimeDungeonPrepareMsg.dungeonType = 0; -- 副本类型
ReqTimeDungeonPrepareMsg.prepare = 0; -- 准备状态 0 true 1 false



ReqTimeDungeonPrepareMsg.meta = {__index = ReqTimeDungeonPrepareMsg };
function ReqTimeDungeonPrepareMsg:new()
	local obj = setmetatable( {}, ReqTimeDungeonPrepareMsg.meta);
	return obj;
end

function ReqTimeDungeonPrepareMsg:encode()
	local body = "";

	body = body ..writeInt(self.dungeonType);
	body = body ..writeInt(self.prepare);

	return body;
end

function ReqTimeDungeonPrepareMsg:ParseData(pak)
	local idx = 1;

	self.dungeonType, idx = readInt(pak, idx);
	self.prepare, idx = readInt(pak, idx);

end



--[[
客户端请求：退出房间
MsgType.CW_ExitRoom
]]
_G.ReqQuitTimeDungeonRoomMsg = {};

ReqQuitTimeDungeonRoomMsg.msgId = 2158;
ReqQuitTimeDungeonRoomMsg.msgType = "CW_ExitRoom";
ReqQuitTimeDungeonRoomMsg.msgClassName = "ReqQuitTimeDungeonRoomMsg";
ReqQuitTimeDungeonRoomMsg.dungeonType = 0; -- 副本类型



ReqQuitTimeDungeonRoomMsg.meta = {__index = ReqQuitTimeDungeonRoomMsg };
function ReqQuitTimeDungeonRoomMsg:new()
	local obj = setmetatable( {}, ReqQuitTimeDungeonRoomMsg.meta);
	return obj;
end

function ReqQuitTimeDungeonRoomMsg:encode()
	local body = "";

	body = body ..writeInt(self.dungeonType);

	return body;
end

function ReqQuitTimeDungeonRoomMsg:ParseData(pak)
	local idx = 1;

	self.dungeonType, idx = readInt(pak, idx);

end



--[[
客户端请求：请求领取排行榜奖励
MsgType.CW_SendExtremityReward
]]
_G.ReqExtremityRewardMsg = {};

ReqExtremityRewardMsg.msgId = 2159;
ReqExtremityRewardMsg.msgType = "CW_SendExtremityReward";
ReqExtremityRewardMsg.msgClassName = "ReqExtremityRewardMsg";
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
MsgType.CW_EnterRoom
]]
_G.ReqCenterTimeDungeonTeamMsg = {};

ReqCenterTimeDungeonTeamMsg.msgId = 2160;
ReqCenterTimeDungeonTeamMsg.msgType = "CW_EnterRoom";
ReqCenterTimeDungeonTeamMsg.msgClassName = "ReqCenterTimeDungeonTeamMsg";
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
MsgType.CW_ChangeRoomDiff
]]
_G.ReqChangeRoomDiffMsg = {};

ReqChangeRoomDiffMsg.msgId = 2161;
ReqChangeRoomDiffMsg.msgType = "CW_ChangeRoomDiff";
ReqChangeRoomDiffMsg.msgClassName = "ReqChangeRoomDiffMsg";
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
MsgType.CW_ChangeRoomAutoStart
]]
_G.ReqChangeRoomAutoStartMsg = {};

ReqChangeRoomAutoStartMsg.msgId = 2162;
ReqChangeRoomAutoStartMsg.msgType = "CW_ChangeRoomAutoStart";
ReqChangeRoomAutoStartMsg.msgClassName = "ReqChangeRoomAutoStartMsg";
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
MsgType.CW_RoomStart
]]
_G.ReqRoomStartMsg = {};

ReqRoomStartMsg.msgId = 2163;
ReqRoomStartMsg.msgType = "CW_RoomStart";
ReqRoomStartMsg.msgClassName = "ReqRoomStartMsg";



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
MsgType.CW_TimeDungeonPrepared
]]
_G.ReqTimeDungeonPreparedMsg = {};

ReqTimeDungeonPreparedMsg.msgId = 2166;
ReqTimeDungeonPreparedMsg.msgType = "CW_TimeDungeonPrepared";
ReqTimeDungeonPreparedMsg.msgClassName = "ReqTimeDungeonPreparedMsg";
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
MsgType.CW_UnionBossActivityOpen
]]
_G.ReqUnionBossActivityOpenMsg = {};

ReqUnionBossActivityOpenMsg.msgId = 2167;
ReqUnionBossActivityOpenMsg.msgType = "CW_UnionBossActivityOpen";
ReqUnionBossActivityOpenMsg.msgClassName = "ReqUnionBossActivityOpenMsg";
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
MsgType.CW_UnionBossActivityEnter
]]
_G.ReqUnionBossActivityEnterMsg = {};

ReqUnionBossActivityEnterMsg.msgId = 2169;
ReqUnionBossActivityEnterMsg.msgType = "CW_UnionBossActivityEnter";
ReqUnionBossActivityEnterMsg.msgClassName = "ReqUnionBossActivityEnterMsg";



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
MsgType.CW_HomesBuildInfo
]]
_G.ReqHomesBuildInfoMsg = {};

ReqHomesBuildInfoMsg.msgId = 2170;
ReqHomesBuildInfoMsg.msgType = "CW_HomesBuildInfo";
ReqHomesBuildInfoMsg.msgClassName = "ReqHomesBuildInfoMsg";



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
MsgType.CW_HomesBuildUplvl
]]
_G.ReqHomesBuildUplvlMsg = {};

ReqHomesBuildUplvlMsg.msgId = 2171;
ReqHomesBuildUplvlMsg.msgType = "CW_HomesBuildUplvl";
ReqHomesBuildUplvlMsg.msgClassName = "ReqHomesBuildUplvlMsg";
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
MsgType.CW_HomesZongminfo
]]
_G.ReqHomesZongminfoMsg = {};

ReqHomesZongminfoMsg.msgId = 2172;
ReqHomesZongminfoMsg.msgType = "CW_HomesZongminfo";
ReqHomesZongminfoMsg.msgClassName = "ReqHomesZongminfoMsg";



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
MsgType.CW_HomesXunxian
]]
_G.ReqHomesXunxianMsg = {};

ReqHomesXunxianMsg.msgId = 2173;
ReqHomesXunxianMsg.msgType = "CW_HomesXunxian";
ReqHomesXunxianMsg.msgClassName = "ReqHomesXunxianMsg";
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
MsgType.CW_HomesPupilEnlist
]]
_G.ReqHomesPupilEnlistMsg = {};

ReqHomesPupilEnlistMsg.msgId = 2174;
ReqHomesPupilEnlistMsg.msgType = "CW_HomesPupilEnlist";
ReqHomesPupilEnlistMsg.msgClassName = "ReqHomesPupilEnlistMsg";
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
MsgType.CW_HomesPupildestory
]]
_G.ReqHomesPupildestoryMsg = {};

ReqHomesPupildestoryMsg.msgId = 2175;
ReqHomesPupildestoryMsg.msgType = "CW_HomesPupildestory";
ReqHomesPupildestoryMsg.msgClassName = "ReqHomesPupildestoryMsg";
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
MsgType.CW_HomesMyQuestInfo
]]
_G.ReqHomesMyQuestInfoMsg = {};

ReqHomesMyQuestInfoMsg.msgId = 2176;
ReqHomesMyQuestInfoMsg.msgType = "CW_HomesMyQuestInfo";
ReqHomesMyQuestInfoMsg.msgClassName = "ReqHomesMyQuestInfoMsg";



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
MsgType.CW_HomesQuestInfo
]]
_G.ReqHomesQuestInfoMsg = {};

ReqHomesQuestInfoMsg.msgId = 2177;
ReqHomesQuestInfoMsg.msgType = "CW_HomesQuestInfo";
ReqHomesQuestInfoMsg.msgClassName = "ReqHomesQuestInfoMsg";
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
MsgType.CW_HomesGetQuest
]]
_G.ReqHomesGetQuestMsg = {};

ReqHomesGetQuestMsg.msgId = 2178;
ReqHomesGetQuestMsg.msgType = "CW_HomesGetQuest";
ReqHomesGetQuestMsg.msgClassName = "ReqHomesGetQuestMsg";
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
MsgType.CW_HomesRodQuest
]]
_G.ReqHomesRodQuestMsg = {};

ReqHomesRodQuestMsg.msgId = 2179;
ReqHomesRodQuestMsg.msgType = "CW_HomesRodQuest";
ReqHomesRodQuestMsg.msgClassName = "ReqHomesRodQuestMsg";



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
MsgType.CW_HomesGoRodQuest
]]
_G.ReqHomesGoRodQuestMsg = {};

ReqHomesGoRodQuestMsg.msgId = 2181;
ReqHomesGoRodQuestMsg.msgType = "CW_HomesGoRodQuest";
ReqHomesGoRodQuestMsg.msgClassName = "ReqHomesGoRodQuestMsg";
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
MsgType.CW_HomesRodQuestNum
]]
_G.ReqHomesRodQuestNumMsg = {};

ReqHomesRodQuestNumMsg.msgId = 2182;
ReqHomesRodQuestNumMsg.msgType = "CW_HomesRodQuestNum";
ReqHomesRodQuestNumMsg.msgClassName = "ReqHomesRodQuestNumMsg";
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
MsgType.CW_HomesGetMyQuestReward
]]
_G.ReqHomesGetMyQuestRewardMsg = {};

ReqHomesGetMyQuestRewardMsg.msgId = 2184;
ReqHomesGetMyQuestRewardMsg.msgType = "CW_HomesGetMyQuestReward";
ReqHomesGetMyQuestRewardMsg.msgClassName = "ReqHomesGetMyQuestRewardMsg";
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
MsgType.WC_HomesGetMyQuestReward
]]
_G.RespHomesGetMyQuestRewardMsg = {};

RespHomesGetMyQuestRewardMsg.msgId = 7184;
RespHomesGetMyQuestRewardMsg.msgType = "WC_HomesGetMyQuestReward";
RespHomesGetMyQuestRewardMsg.msgClassName = "RespHomesGetMyQuestRewardMsg";
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
MsgType.CW_CrossDungeonRoom
]]
_G.ReqCrossDungeonRoomMsg = {};

ReqCrossDungeonRoomMsg.msgId = 2185;
ReqCrossDungeonRoomMsg.msgType = "CW_CrossDungeonRoom";
ReqCrossDungeonRoomMsg.msgClassName = "ReqCrossDungeonRoomMsg";
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
MsgType.CW_QuickEnterCrossRoom
]]
_G.ReqQuickCrossDungeonRoomMsg = {};

ReqQuickCrossDungeonRoomMsg.msgId = 2186;
ReqQuickCrossDungeonRoomMsg.msgType = "CW_QuickEnterCrossRoom";
ReqQuickCrossDungeonRoomMsg.msgClassName = "ReqQuickCrossDungeonRoomMsg";



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
MsgType.CW_CreateCrossRoom
]]
_G.ReqCrossDungeonRoomBuildMsg = {};

ReqCrossDungeonRoomBuildMsg.msgId = 2187;
ReqCrossDungeonRoomBuildMsg.msgType = "CW_CreateCrossRoom";
ReqCrossDungeonRoomBuildMsg.msgClassName = "ReqCrossDungeonRoomBuildMsg";
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
MsgType.CW_RoomCrossPrepare
]]
_G.ReqCrossDungeonPrepareMsg = {};

ReqCrossDungeonPrepareMsg.msgId = 2188;
ReqCrossDungeonPrepareMsg.msgType = "CW_RoomCrossPrepare";
ReqCrossDungeonPrepareMsg.msgClassName = "ReqCrossDungeonPrepareMsg";
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
MsgType.CW_ExitCrossRoom
]]
_G.ReqQuitCrossDungeonRoomMsg = {};

ReqQuitCrossDungeonRoomMsg.msgId = 2189;
ReqQuitCrossDungeonRoomMsg.msgType = "CW_ExitCrossRoom";
ReqQuitCrossDungeonRoomMsg.msgClassName = "ReqQuitCrossDungeonRoomMsg";



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
MsgType.CW_EnterCrossRoom
]]
_G.ReqEnterCrossDungeonMsg = {};

ReqEnterCrossDungeonMsg.msgId = 2190;
ReqEnterCrossDungeonMsg.msgType = "CW_EnterCrossRoom";
ReqEnterCrossDungeonMsg.msgClassName = "ReqEnterCrossDungeonMsg";
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
MsgType.CW_ChangeCrossRoomAutoStart
]]
_G.ReqChangeCrossRoomAutoStartMsg = {};

ReqChangeCrossRoomAutoStartMsg.msgId = 2191;
ReqChangeCrossRoomAutoStartMsg.msgType = "CW_ChangeCrossRoomAutoStart";
ReqChangeCrossRoomAutoStartMsg.msgClassName = "ReqChangeCrossRoomAutoStartMsg";
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
MsgType.CW_CrossRoomStart
]]
_G.ReqCrossRoomStartMsg = {};

ReqCrossRoomStartMsg.msgId = 2192;
ReqCrossRoomStartMsg.msgType = "CW_CrossRoomStart";
ReqCrossRoomStartMsg.msgClassName = "ReqCrossRoomStartMsg";



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
MsgType.CW_ReEnterGame
]]
_G.ReqReEnterGameMsg = {};

ReqReEnterGameMsg.msgId = 2193;
ReqReEnterGameMsg.msgType = "CW_ReEnterGame";
ReqReEnterGameMsg.msgClassName = "ReqReEnterGameMsg";
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
MsgType.CW_ReEnterScene
]]
_G.ReqReEnterSceneMsg = {};

ReqReEnterSceneMsg.msgId = 2194;
ReqReEnterSceneMsg.msgType = "CW_ReEnterScene";
ReqReEnterSceneMsg.msgClassName = "ReqReEnterSceneMsg";



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
MsgType.CW_HomesUsePupilExp
]]
_G.ReqHomesUsePupilExpMsg = {};

ReqHomesUsePupilExpMsg.msgId = 2195;
ReqHomesUsePupilExpMsg.msgType = "CW_HomesUsePupilExp";
ReqHomesUsePupilExpMsg.msgClassName = "ReqHomesUsePupilExpMsg";
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
MsgType.CW_StartMatchPvp
]]
_G.ReqStartMatchPvpMsg = {};

ReqStartMatchPvpMsg.msgId = 2196;
ReqStartMatchPvpMsg.msgType = "CW_StartMatchPvp";
ReqStartMatchPvpMsg.msgClassName = "ReqStartMatchPvpMsg";



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
MsgType.CW_ExitMatchPvp
]]
_G.ReqExitMatchPvpMsg = {};

ReqExitMatchPvpMsg.msgId = 2197;
ReqExitMatchPvpMsg.msgType = "CW_ExitMatchPvp";
ReqExitMatchPvpMsg.msgClassName = "ReqExitMatchPvpMsg";



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
MsgType.CW_QueryCrossPvpInfo
]]
_G.ReqCrossPvpInfoMsg = {};

ReqCrossPvpInfoMsg.msgId = 2198;
ReqCrossPvpInfoMsg.msgType = "CW_QueryCrossPvpInfo";
ReqCrossPvpInfoMsg.msgClassName = "ReqCrossPvpInfoMsg";



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
MsgType.CW_QueryCrossSeasonPvpInfo
]]
_G.ReqCrossSeasonPvpInfoMsg = {};

ReqCrossSeasonPvpInfoMsg.msgId = 2199;
ReqCrossSeasonPvpInfoMsg.msgType = "CW_QueryCrossSeasonPvpInfo";
ReqCrossSeasonPvpInfoMsg.msgClassName = "ReqCrossSeasonPvpInfoMsg";
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
MsgType.CW_SendGuildActivityNotice
]]
_G.ReqSendGuildActivityNoticeMsg = {};

ReqSendGuildActivityNoticeMsg.msgId = 2200;
ReqSendGuildActivityNoticeMsg.msgType = "CW_SendGuildActivityNotice";
ReqSendGuildActivityNoticeMsg.msgClassName = "ReqSendGuildActivityNoticeMsg";
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
MsgType.CW_GetPvpDayReward
]]
_G.ReqGetPvpDayRewardMsg = {};

ReqGetPvpDayRewardMsg.msgId = 2202;
ReqGetPvpDayRewardMsg.msgType = "CW_GetPvpDayReward";
ReqGetPvpDayRewardMsg.msgClassName = "ReqGetPvpDayRewardMsg";



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
MsgType.CW_GMTitle
]]
_G.ReqGMTitleMsg = {};

ReqGMTitleMsg.msgId = 2203;
ReqGMTitleMsg.msgType = "CW_GMTitle";
ReqGMTitleMsg.msgClassName = "ReqGMTitleMsg";
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
MsgType.CW_GMList
]]
_G.ReqGMListMsg = {};

ReqGMListMsg.msgId = 2204;
ReqGMListMsg.msgType = "CW_GMList";
ReqGMListMsg.msgClassName = "ReqGMListMsg";
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
MsgType.CW_GMSearch
]]
_G.ReqGMSearchMsg = {};

ReqGMSearchMsg.msgId = 2206;
ReqGMSearchMsg.msgType = "CW_GMSearch";
ReqGMSearchMsg.msgClassName = "ReqGMSearchMsg";
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
MsgType.CW_GMOper
]]
_G.ReqGMOperMsg = {};

ReqGMOperMsg.msgId = 2207;
ReqGMOperMsg.msgType = "CW_GMOper";
ReqGMOperMsg.msgClassName = "ReqGMOperMsg";
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
MsgType.CW_GMUnOper
]]
_G.ReqGMUnOperMsg = {};

ReqGMUnOperMsg.msgId = 2208;
ReqGMUnOperMsg.msgType = "CW_GMUnOper";
ReqGMUnOperMsg.msgClassName = "ReqGMUnOperMsg";
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
MsgType.CW_GMGuildRoleList
]]
_G.ReqGMGuildRoleListMsg = {};

ReqGMGuildRoleListMsg.msgId = 2209;
ReqGMGuildRoleListMsg.msgType = "CW_GMGuildRoleList";
ReqGMGuildRoleListMsg.msgClassName = "ReqGMGuildRoleListMsg";
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
MsgType.CW_GMGuildOper
]]
_G.ReqGMGuildOperMsg = {};

ReqGMGuildOperMsg.msgId = 2210;
ReqGMGuildOperMsg.msgType = "CW_GMGuildOper";
ReqGMGuildOperMsg.msgClassName = "ReqGMGuildOperMsg";
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
MsgType.CW_GMGuildDismiss
]]
_G.ReqGMGuildDismissMsg = {};

ReqGMGuildDismissMsg.msgId = 2211;
ReqGMGuildDismissMsg.msgType = "CW_GMGuildDismiss";
ReqGMGuildDismissMsg.msgClassName = "ReqGMGuildDismissMsg";
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
MsgType.CW_WorldNotice
]]
_G.ReqWCWorldNoticeMsg = {};

ReqWCWorldNoticeMsg.msgId = 2212;
ReqWCWorldNoticeMsg.msgType = "CW_WorldNotice";
ReqWCWorldNoticeMsg.msgClassName = "ReqWCWorldNoticeMsg";
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
MsgType.CW_GetRedPacketRank
]]
_G.ReqGetRedPacketRankMsg = {};

ReqGetRedPacketRankMsg.msgId = 2214;
ReqGetRedPacketRankMsg.msgType = "CW_GetRedPacketRank";
ReqGetRedPacketRankMsg.msgClassName = "ReqGetRedPacketRankMsg";
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
MsgType.CW_GetRedPacket
]]
_G.ReqGetRedPacketMsg = {};

ReqGetRedPacketMsg.msgId = 2215;
ReqGetRedPacketMsg.msgType = "CW_GetRedPacket";
ReqGetRedPacketMsg.msgClassName = "ReqGetRedPacketMsg";
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
MsgType.CW_ConsignmentItemInShelves
]]
_G.ReqConsignmentItemInShelvesMsg = {};

ReqConsignmentItemInShelvesMsg.msgId = 2216;
ReqConsignmentItemInShelvesMsg.msgType = "CW_ConsignmentItemInShelves";
ReqConsignmentItemInShelvesMsg.msgClassName = "ReqConsignmentItemInShelvesMsg";
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
MsgType.CW_HomesGiveupQuest
]]
_G.ReqHomesGiveupQuestMsg = {};

ReqHomesGiveupQuestMsg.msgId = 2217;
ReqHomesGiveupQuestMsg.msgType = "CW_HomesGiveupQuest";
ReqHomesGiveupQuestMsg.msgClassName = "ReqHomesGiveupQuestMsg";
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
MsgType.CW_PartyBuy
]]
_G.ReqPartyBuyMsg = {};

ReqPartyBuyMsg.msgId = 2218;
ReqPartyBuyMsg.msgType = "CW_PartyBuy";
ReqPartyBuyMsg.msgClassName = "ReqPartyBuyMsg";
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
MsgType.CW_ExtendGuild
]]
_G.ReqExtendGuildMsg = {};

ReqExtendGuildMsg.msgId = 2222;
ReqExtendGuildMsg.msgType = "CW_ExtendGuild";
ReqExtendGuildMsg.msgClassName = "ReqExtendGuildMsg";
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
MsgType.CW_GuildTanHeQuanXian
]]
_G.ReqGuildTanHeQuanXianMsg = {};

ReqGuildTanHeQuanXianMsg.msgId = 2223;
ReqGuildTanHeQuanXianMsg.msgType = "CW_GuildTanHeQuanXian";
ReqGuildTanHeQuanXianMsg.msgClassName = "ReqGuildTanHeQuanXianMsg";



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
MsgType.CW_GuildTanHe
]]
_G.ReqGuildTanHeMsg = {};

ReqGuildTanHeMsg.msgId = 2224;
ReqGuildTanHeMsg.msgType = "CW_GuildTanHe";
ReqGuildTanHeMsg.msgClassName = "ReqGuildTanHeMsg";



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
MsgType.CW_GuildQueryCheckList
]]
_G.ReqGuildQueryCheckListMsg = {};

ReqGuildQueryCheckListMsg.msgId = 2225;
ReqGuildQueryCheckListMsg.msgType = "CW_GuildQueryCheckList";
ReqGuildQueryCheckListMsg.msgClassName = "ReqGuildQueryCheckListMsg";



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
MsgType.CW_GuildQueryCheckOper
]]
_G.ReqGuildQueryCheckOperMsg = {};

ReqGuildQueryCheckOperMsg.msgId = 2226;
ReqGuildQueryCheckOperMsg.msgType = "CW_GuildQueryCheckOper";
ReqGuildQueryCheckOperMsg.msgClassName = "ReqGuildQueryCheckOperMsg";
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
MsgType.CW_GuildSetAutoCheck
]]
_G.ReqGuildSetAutoCheckMsg = {};

ReqGuildSetAutoCheckMsg.msgId = 2227;
ReqGuildSetAutoCheckMsg.msgType = "CW_GuildSetAutoCheck";
ReqGuildSetAutoCheckMsg.msgClassName = "ReqGuildSetAutoCheckMsg";
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
MsgType.CW_BanChat
]]
_G.ReqBanChatMsg = {};

ReqBanChatMsg.msgId = 2230;
ReqBanChatMsg.msgType = "CW_BanChat";
ReqBanChatMsg.msgClassName = "ReqBanChatMsg";
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
MsgType.CW_UnionEnterDiGongWar
]]
_G.ReqUnionEnterDiGongWarMsg = {};

ReqUnionEnterDiGongWarMsg.msgId = 2231;
ReqUnionEnterDiGongWarMsg.msgType = "CW_UnionEnterDiGongWar";
ReqUnionEnterDiGongWarMsg.msgClassName = "ReqUnionEnterDiGongWarMsg";



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
MsgType.CW_UnionDiGongInfo
]]
_G.ReqUnionDiGongInfoMsg = {};

ReqUnionDiGongInfoMsg.msgId = 2232;
ReqUnionDiGongInfoMsg.msgType = "CW_UnionDiGongInfo";
ReqUnionDiGongInfoMsg.msgClassName = "ReqUnionDiGongInfoMsg";



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
MsgType.CW_UnionDiGongBidInfo
]]
_G.ReqUnionDiGongBidInfoMsg = {};

ReqUnionDiGongBidInfoMsg.msgId = 2233;
ReqUnionDiGongBidInfoMsg.msgType = "CW_UnionDiGongBidInfo";
ReqUnionDiGongBidInfoMsg.msgClassName = "ReqUnionDiGongBidInfoMsg";
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
MsgType.CW_UnionDiGongBid
]]
_G.ReqUnionDiGongBidMsg = {};

ReqUnionDiGongBidMsg.msgId = 2234;
ReqUnionDiGongBidMsg.msgType = "CW_UnionDiGongBid";
ReqUnionDiGongBidMsg.msgClassName = "ReqUnionDiGongBidMsg";
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
MsgType.CW_KuafuRankListState
]]
_G.ReqKuafuRankListStateMsg = {};

ReqKuafuRankListStateMsg.msgId = 2236;
ReqKuafuRankListStateMsg.msgType = "CW_KuafuRankListState";
ReqKuafuRankListStateMsg.msgClassName = "ReqKuafuRankListStateMsg";
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
MsgType.CW_KuafuRankDuanweiList
]]
_G.ReqKuafuRankDuanweiListMsg = {};

ReqKuafuRankDuanweiListMsg.msgId = 2237;
ReqKuafuRankDuanweiListMsg.msgType = "CW_KuafuRankDuanweiList";
ReqKuafuRankDuanweiListMsg.msgClassName = "ReqKuafuRankDuanweiListMsg";
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
MsgType.CW_KuafuRongyaoInfo
]]
_G.ReqKuafuRongyaoInfoMsg = {};

ReqKuafuRongyaoInfoMsg.msgId = 2238;
ReqKuafuRongyaoInfoMsg.msgType = "CW_KuafuRongyaoInfo";
ReqKuafuRongyaoInfoMsg.msgClassName = "ReqKuafuRongyaoInfoMsg";



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
MsgType.CW_GetPvpRongyaoReward
]]
_G.ReqGetPvpRongyaoRewardMsg = {};

ReqGetPvpRongyaoRewardMsg.msgId = 2239;
ReqGetPvpRongyaoRewardMsg.msgType = "CW_GetPvpRongyaoReward";
ReqGetPvpRongyaoRewardMsg.msgClassName = "ReqGetPvpRongyaoRewardMsg";



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
MsgType.CW_GMGuildNotice
]]
_G.ReqGMGuildNoticeMsg = {};

ReqGMGuildNoticeMsg.msgId = 2241;
ReqGMGuildNoticeMsg.msgType = "CW_GMGuildNotice";
ReqGMGuildNoticeMsg.msgClassName = "ReqGMGuildNoticeMsg";
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
MsgType.CW_EnterCrossBoss
]]
_G.ReqEnterCrossBossMsg = {};

ReqEnterCrossBossMsg.msgId = 2242;
ReqEnterCrossBossMsg.msgType = "CW_EnterCrossBoss";
ReqEnterCrossBossMsg.msgClassName = "ReqEnterCrossBossMsg";
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
MsgType.CW_CrossBossRankInfo
]]
_G.ReqCrossBossInfoMsg = {};

ReqCrossBossInfoMsg.msgId = 2243;
ReqCrossBossInfoMsg.msgType = "CW_CrossBossRankInfo";
ReqCrossBossInfoMsg.msgClassName = "ReqCrossBossInfoMsg";



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
MsgType.CW_EnterCrossArena
]]
_G.ReqEnterCrossArenaMsg = {};

ReqEnterCrossArenaMsg.msgId = 2247;
ReqEnterCrossArenaMsg.msgType = "CW_EnterCrossArena";
ReqEnterCrossArenaMsg.msgClassName = "ReqEnterCrossArenaMsg";
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
MsgType.CW_CrossArenaRankInfo
]]
_G.ReqCrossArenaInfoMsg = {};

ReqCrossArenaInfoMsg.msgId = 2248;
ReqCrossArenaInfoMsg.msgType = "CW_CrossArenaRankInfo";
ReqCrossArenaInfoMsg.msgClassName = "ReqCrossArenaInfoMsg";
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
MsgType.CW_CrossArenaZige
]]
_G.ReqCrossArenaZigeMsg = {};

ReqCrossArenaZigeMsg.msgId = 2250;
ReqCrossArenaZigeMsg.msgType = "CW_CrossArenaZige";
ReqCrossArenaZigeMsg.msgClassName = "ReqCrossArenaZigeMsg";



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
MsgType.CW_Proposal
]]
_G.ReqProposalMsg = {};

ReqProposalMsg.msgId = 2251;
ReqProposalMsg.msgType = "CW_Proposal";
ReqProposalMsg.msgClassName = "ReqProposalMsg";
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
MsgType.CW_BeProposaledChoose
]]
_G.ReqBeProposaledChooseMsg = {};

ReqBeProposaledChooseMsg.msgId = 2252;
ReqBeProposaledChooseMsg.msgType = "CW_BeProposaledChoose";
ReqBeProposaledChooseMsg.msgClassName = "ReqBeProposaledChooseMsg";
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
MsgType.CW_ApplyMarryData
]]
_G.ReqAookyNarryDataMsg = {};

ReqAookyNarryDataMsg.msgId = 2253;
ReqAookyNarryDataMsg.msgType = "CW_ApplyMarryData";
ReqAookyNarryDataMsg.msgClassName = "ReqAookyNarryDataMsg";
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
MsgType.CW_ApplyMarry
]]
_G.ReqApplyMarryMsg = {};

ReqApplyMarryMsg.msgId = 2254;
ReqApplyMarryMsg.msgType = "CW_ApplyMarry";
ReqApplyMarryMsg.msgClassName = "ReqApplyMarryMsg";
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
MsgType.CW_MarryInvite
]]
_G.ReqMarryInviteMsg = {};

ReqMarryInviteMsg.msgId = 2256;
ReqMarryInviteMsg.msgType = "CW_MarryInvite";
ReqMarryInviteMsg.msgClassName = "ReqMarryInviteMsg";



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
MsgType.CW_LookMarryRedPackets
]]
_G.ReqLookMarryRedPacketsMsg = {};

ReqLookMarryRedPacketsMsg.msgId = 2257;
ReqLookMarryRedPacketsMsg.msgType = "CW_LookMarryRedPackets";
ReqLookMarryRedPacketsMsg.msgClassName = "ReqLookMarryRedPacketsMsg";



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
MsgType.CW_MarryMovEnd
]]
_G.ReqMarryMovEndMsg = {};

ReqMarryMovEndMsg.msgId = 2258;
ReqMarryMovEndMsg.msgType = "CW_MarryMovEnd";
ReqMarryMovEndMsg.msgClassName = "ReqMarryMovEndMsg";



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
MsgType.CW_FlyToMate
]]
_G.ReqFlyToMateMsg = {};

ReqFlyToMateMsg.msgId = 2261;
ReqFlyToMateMsg.msgType = "CW_FlyToMate";
ReqFlyToMateMsg.msgClassName = "ReqFlyToMateMsg";



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
MsgType.CW_FlyToMateOk
]]
_G.ReqFlyToMateOkMsg = {};

ReqFlyToMateOkMsg.msgId = 2262;
ReqFlyToMateOkMsg.msgType = "CW_FlyToMateOk";
ReqFlyToMateOkMsg.msgClassName = "ReqFlyToMateOkMsg";



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
MsgType.CW_CrossArenaXiaZhuInfo
]]
_G.ReqCrossArenaXiaZhuInfoMsg = {};

ReqCrossArenaXiaZhuInfoMsg.msgId = 2263;
ReqCrossArenaXiaZhuInfoMsg.msgType = "CW_CrossArenaXiaZhuInfo";
ReqCrossArenaXiaZhuInfoMsg.msgClassName = "ReqCrossArenaXiaZhuInfoMsg";



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
MsgType.CW_CrossArenaXiaZhu
]]
_G.ReqCrossArenaXiaZhuMsg = {};

ReqCrossArenaXiaZhuMsg.msgId = 2264;
ReqCrossArenaXiaZhuMsg.msgType = "CW_CrossArenaXiaZhu";
ReqCrossArenaXiaZhuMsg.msgClassName = "ReqCrossArenaXiaZhuMsg";
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
MsgType.CW_CrossArenaGuWu
]]
_G.ReqCrossArenaGuWuMsg = {};

ReqCrossArenaGuWuMsg.msgId = 2265;
ReqCrossArenaGuWuMsg.msgType = "CW_CrossArenaGuWu";
ReqCrossArenaGuWuMsg.msgClassName = "ReqCrossArenaGuWuMsg";



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
MsgType.CW_CrossArenaDuiShou
]]
_G.ReqCrossArenaDuiShouMsg = {};

ReqCrossArenaDuiShouMsg.msgId = 2266;
ReqCrossArenaDuiShouMsg.msgType = "CW_CrossArenaDuiShou";
ReqCrossArenaDuiShouMsg.msgClassName = "ReqCrossArenaDuiShouMsg";



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
MsgType.CW_InvitationCode
]]
_G.ReqInvitationCodeMsg = {};

ReqInvitationCodeMsg.msgId = 2267;
ReqInvitationCodeMsg.msgType = "CW_InvitationCode";
ReqInvitationCodeMsg.msgClassName = "ReqInvitationCodeMsg";
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
MsgType.CW_ChristmasDonateInfo
]]
_G.ReqChristmasDonateInfoMsg = {};

ReqChristmasDonateInfoMsg.msgId = 2268;
ReqChristmasDonateInfoMsg.msgType = "CW_ChristmasDonateInfo";
ReqChristmasDonateInfoMsg.msgClassName = "ReqChristmasDonateInfoMsg";



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
MsgType.CW_ChristmasDonate
]]
_G.ReqChristmasDonateMsg = {};

ReqChristmasDonateMsg.msgId = 2269;
ReqChristmasDonateMsg.msgType = "CW_ChristmasDonate";
ReqChristmasDonateMsg.msgClassName = "ReqChristmasDonateMsg";
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
MsgType.CW_ChristmasDonateReward
]]
_G.ReqChristmasDonateRewardMsg = {};

ReqChristmasDonateRewardMsg.msgId = 2270;
ReqChristmasDonateRewardMsg.msgType = "CW_ChristmasDonateReward";
ReqChristmasDonateRewardMsg.msgClassName = "ReqChristmasDonateRewardMsg";
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
MsgType.CW_TXRecharge
]]
_G.ReqTXRechargeMsg = {};

ReqTXRechargeMsg.msgId = 2275;
ReqTXRechargeMsg.msgType = "CW_TXRecharge";
ReqTXRechargeMsg.msgClassName = "ReqTXRechargeMsg";



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
请求野外Boss列表
MsgType.CW_FieldBoss
]]
_G.ReqFieldBossMsg = {};

ReqFieldBossMsg.msgId = 2276;
ReqFieldBossMsg.msgType = "CW_FieldBoss";
ReqFieldBossMsg.msgClassName = "ReqFieldBossMsg";



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
MsgType.CW_DiGongBoss
]]
_G.ReqDiGongBossMsg = {};

ReqDiGongBossMsg.msgId = 2277;
ReqDiGongBossMsg.msgType = "CW_DiGongBoss";
ReqDiGongBossMsg.msgClassName = "ReqDiGongBossMsg";



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
进入活动
MsgType.CW_EnterInterServiceScene
]]
_G.ReqEnterInterServiceSceneMsg = {};

ReqEnterInterServiceSceneMsg.msgId = 2278;
ReqEnterInterServiceSceneMsg.msgType = "CW_EnterInterServiceScene";
ReqEnterInterServiceSceneMsg.msgClassName = "ReqEnterInterServiceSceneMsg";
ReqEnterInterServiceSceneMsg.groupid = 0; -- 区服ID



ReqEnterInterServiceSceneMsg.meta = {__index = ReqEnterInterServiceSceneMsg };
function ReqEnterInterServiceSceneMsg:new()
	local obj = setmetatable( {}, ReqEnterInterServiceSceneMsg.meta);
	return obj;
end

function ReqEnterInterServiceSceneMsg:encode()
	local body = "";

	body = body ..writeInt(self.groupid);

	return body;
end

function ReqEnterInterServiceSceneMsg:ParseData(pak)
	local idx = 1;

	self.groupid, idx = readInt(pak, idx);

end



--[[
请求秘境Boss列表
MsgType.CW_MiJingBoss
]]
_G.ReqMiJingBossMsg = {};

ReqMiJingBossMsg.msgId = 2279;
ReqMiJingBossMsg.msgType = "CW_MiJingBoss";
ReqMiJingBossMsg.msgClassName = "ReqMiJingBossMsg";



ReqMiJingBossMsg.meta = {__index = ReqMiJingBossMsg };
function ReqMiJingBossMsg:new()
	local obj = setmetatable( {}, ReqMiJingBossMsg.meta);
	return obj;
end

function ReqMiJingBossMsg:encode()
	local body = "";


	return body;
end

function ReqMiJingBossMsg:ParseData(pak)
	local idx = 1;


end



--[[
主角进入场景
MsgType.CS_SCENE_ENTER_SCENE
]]
_G.ReqSceneEnterSceneMsg = {};

ReqSceneEnterSceneMsg.msgId = 3003;
ReqSceneEnterSceneMsg.msgType = "CS_SCENE_ENTER_SCENE";
ReqSceneEnterSceneMsg.msgClassName = "ReqSceneEnterSceneMsg";
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
MsgType.CS_SCENE_MOVE_TO
]]
_G.ReqSceneMoveMsg = {};

ReqSceneMoveMsg.msgId = 3004;
ReqSceneMoveMsg.msgType = "CS_SCENE_MOVE_TO";
ReqSceneMoveMsg.msgClassName = "ReqSceneMoveMsg";
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
MsgType.CS_SCENE_GET_ROLE
]]
_G.ReqSceneGetRoleMsg = {};

ReqSceneGetRoleMsg.msgId = 3005;
ReqSceneGetRoleMsg.msgType = "CS_SCENE_GET_ROLE";
ReqSceneGetRoleMsg.msgClassName = "ReqSceneGetRoleMsg";
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
MsgType.CS_SCENE_MOVE_STOP
]]
_G.ReqSceneMoveStopMsg = {};

ReqSceneMoveStopMsg.msgId = 3006;
ReqSceneMoveStopMsg.msgType = "CS_SCENE_MOVE_STOP";
ReqSceneMoveStopMsg.msgClassName = "ReqSceneMoveStopMsg";
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

MsgType.CS_HUMAN_MODIFY_ATTY
]]
_G.ReqHumanModifyAttyMsg = {};

ReqHumanModifyAttyMsg.msgId = 3011;
ReqHumanModifyAttyMsg.msgType = "CS_HUMAN_MODIFY_ATTY";
ReqHumanModifyAttyMsg.msgClassName = "ReqHumanModifyAttyMsg";
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
MsgType.CS_QueryItem
]]
_G.ReqQueryItemMsg = {};

ReqQueryItemMsg.msgId = 3019;
ReqQueryItemMsg.msgType = "CS_QueryItem";
ReqQueryItemMsg.msgClassName = "ReqQueryItemMsg";
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
MsgType.CS_DiscardItem
]]
_G.ReqDiscardItemMsg = {};

ReqDiscardItemMsg.msgId = 3020;
ReqDiscardItemMsg.msgType = "CS_DiscardItem";
ReqDiscardItemMsg.msgClassName = "ReqDiscardItemMsg";
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
MsgType.CS_SwapItem
]]
_G.ReqSwapItemMsg = {};

ReqSwapItemMsg.msgId = 3021;
ReqSwapItemMsg.msgType = "CS_SwapItem";
ReqSwapItemMsg.msgClassName = "ReqSwapItemMsg";
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
MsgType.CS_UseItem
]]
_G.ReqUseItemMsg = {};

ReqUseItemMsg.msgId = 3022;
ReqUseItemMsg.msgType = "CS_UseItem";
ReqUseItemMsg.msgClassName = "ReqUseItemMsg";
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
MsgType.CS_SellItem
]]
_G.ReqSellItemMsg = {};

ReqSellItemMsg.msgId = 3023;
ReqSellItemMsg.msgType = "CS_SellItem";
ReqSellItemMsg.msgClassName = "ReqSellItemMsg";
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
MsgType.CS_PackItem
]]
_G.ReqPackItemMsg = {};

ReqPackItemMsg.msgId = 3024;
ReqPackItemMsg.msgType = "CS_PackItem";
ReqPackItemMsg.msgClassName = "ReqPackItemMsg";
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
MsgType.CS_ExpandBag
]]
_G.ReqExpandBagMsg = {};

ReqExpandBagMsg.msgId = 3025;
ReqExpandBagMsg.msgType = "CS_ExpandBag";
ReqExpandBagMsg.msgClassName = "ReqExpandBagMsg";
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
MsgType.CS_SplitItem
]]
_G.ReqSplitItemMsg = {};

ReqSplitItemMsg.msgId = 3026;
ReqSplitItemMsg.msgType = "CS_SplitItem";
ReqSplitItemMsg.msgClassName = "ReqSplitItemMsg";
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
MsgType.CS_SkillList
]]
_G.ReqSkillListMsg = {};

ReqSkillListMsg.msgId = 3028;
ReqSkillListMsg.msgType = "CS_SkillList";
ReqSkillListMsg.msgClassName = "ReqSkillListMsg";



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
MsgType.CS_SkillLearn
]]
_G.ReqSkillLearnMsg = {};

ReqSkillLearnMsg.msgId = 3029;
ReqSkillLearnMsg.msgType = "CS_SkillLearn";
ReqSkillLearnMsg.msgClassName = "ReqSkillLearnMsg";
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
MsgType.CS_SkillLvlUp
]]
_G.ReqSkillLvlUpMsg = {};

ReqSkillLvlUpMsg.msgId = 3030;
ReqSkillLvlUpMsg.msgType = "CS_SkillLvlUp";
ReqSkillLvlUpMsg.msgClassName = "ReqSkillLvlUpMsg";
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
一键请求升级技能
MsgType.CS_SkillLvlUpOneKey
]]
_G.ReqSkillLvlUpOneKeyMsg = {};

ReqSkillLvlUpOneKeyMsg.msgId = 3031;
ReqSkillLvlUpOneKeyMsg.msgType = "CS_SkillLvlUpOneKey";
ReqSkillLvlUpOneKeyMsg.msgClassName = "ReqSkillLvlUpOneKeyMsg";



ReqSkillLvlUpOneKeyMsg.meta = {__index = ReqSkillLvlUpOneKeyMsg };
function ReqSkillLvlUpOneKeyMsg:new()
	local obj = setmetatable( {}, ReqSkillLvlUpOneKeyMsg.meta);
	return obj;
end

function ReqSkillLvlUpOneKeyMsg:encode()
	local body = "";


	return body;
end

function ReqSkillLvlUpOneKeyMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端主动去请求obj列表
MsgType.CS_REQ_MAP_OBJ_LIST
]]
_G.ReqMapObjListMsg = {};

ReqMapObjListMsg.msgId = 3035;
ReqMapObjListMsg.msgType = "CS_REQ_MAP_OBJ_LIST";
ReqMapObjListMsg.msgClassName = "ReqMapObjListMsg";
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
MsgType.CS_REQ_CHANGE_DIR
]]
_G.ReqChangeDir = {};

ReqChangeDir.msgId = 3036;
ReqChangeDir.msgType = "CS_REQ_CHANGE_DIR";
ReqChangeDir.msgClassName = "ReqChangeDir";
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
MsgType.CS_CastMagic
]]
_G.ReqCastMagicMsg = {};

ReqCastMagicMsg.msgId = 3050;
ReqCastMagicMsg.msgType = "CS_CastMagic";
ReqCastMagicMsg.msgClassName = "ReqCastMagicMsg";
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
MsgType.CS_InterruptCast
]]
_G.ReqInterruptCastMsg = {};

ReqInterruptCastMsg.msgId = 3056;
ReqInterruptCastMsg.msgType = "CS_InterruptCast";
ReqInterruptCastMsg.msgClassName = "ReqInterruptCastMsg";
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
MsgType.CS_QueryQuest
]]
_G.ReqQueryQuestMsg = {};

ReqQueryQuestMsg.msgId = 3059;
ReqQueryQuestMsg.msgType = "CS_QueryQuest";
ReqQueryQuestMsg.msgClassName = "ReqQueryQuestMsg";



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
MsgType.CS_QuestClick
]]
_G.ReqQuestClickMsg = {};

ReqQuestClickMsg.msgId = 3061;
ReqQuestClickMsg.msgType = "CS_QuestClick";
ReqQuestClickMsg.msgClassName = "ReqQuestClickMsg";
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
MsgType.CS_AcceptQuest
]]
_G.ReqAcceptQuestMsg = {};

ReqAcceptQuestMsg.msgId = 3062;
ReqAcceptQuestMsg.msgType = "CS_AcceptQuest";
ReqAcceptQuestMsg.msgClassName = "ReqAcceptQuestMsg";
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
MsgType.CS_GiveupQuest
]]
_G.ReqGiveupQuestMsg = {};

ReqGiveupQuestMsg.msgId = 3063;
ReqGiveupQuestMsg.msgType = "CS_GiveupQuest";
ReqGiveupQuestMsg.msgClassName = "ReqGiveupQuestMsg";
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
MsgType.CS_FinishQuest
]]
_G.ReqFinishQuestMsg = {};

ReqFinishQuestMsg.msgId = 3064;
ReqFinishQuestMsg.msgType = "CS_FinishQuest";
ReqFinishQuestMsg.msgClassName = "ReqFinishQuestMsg";
ReqFinishQuestMsg.id = 0; -- 任务id
ReqFinishQuestMsg.multiple = 0; -- 1：免费领一倍，2：银两领双倍，3：元宝领三倍
ReqFinishQuestMsg.opertype = 0; -- 0：正常完成，1：一键完成



ReqFinishQuestMsg.meta = {__index = ReqFinishQuestMsg };
function ReqFinishQuestMsg:new()
	local obj = setmetatable( {}, ReqFinishQuestMsg.meta);
	return obj;
end

function ReqFinishQuestMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);
	body = body ..writeInt(self.multiple);
	body = body ..writeInt(self.opertype);

	return body;
end

function ReqFinishQuestMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.multiple, idx = readInt(pak, idx);
	self.opertype, idx = readInt(pak, idx);

end



--[[
客户端请求: 触发静物
MsgType.CS_TriggerObject
]]
_G.ReqTriggerObjMsg = {};

ReqTriggerObjMsg.msgId = 3070;
ReqTriggerObjMsg.msgType = "CS_TriggerObject";
ReqTriggerObjMsg.msgClassName = "ReqTriggerObjMsg";
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
MsgType.CS_TriggerSelectMap
]]
_G.ReqTriggerSelectMapMsg = {};

ReqTriggerSelectMapMsg.msgId = 3072;
ReqTriggerSelectMapMsg.msgType = "CS_TriggerSelectMap";
ReqTriggerSelectMapMsg.msgClassName = "ReqTriggerSelectMapMsg";
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
MsgType.CS_PickUpItem
]]
_G.ReqPickUpItemMsg = {};

ReqPickUpItemMsg.msgId = 3076;
ReqPickUpItemMsg.msgType = "CS_PickUpItem";
ReqPickUpItemMsg.msgClassName = "ReqPickUpItemMsg";
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
MsgType.CS_Revive
]]
_G.ReqReviveMsg = {};

ReqReviveMsg.msgId = 3077;
ReqReviveMsg.msgType = "CS_Revive";
ReqReviveMsg.msgClassName = "ReqReviveMsg";
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
MsgType.CS_LevelUp
]]
_G.ReqLevelUpMsg = {};

ReqLevelUpMsg.msgId = 3088;
ReqLevelUpMsg.msgType = "CS_LevelUp";
ReqLevelUpMsg.msgClassName = "ReqLevelUpMsg";



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
MsgType.CS_FeedWuHun
]]
_G.ReqFeedWuHunMsg = {};

ReqFeedWuHunMsg.msgId = 3092;
ReqFeedWuHunMsg.msgType = "CS_FeedWuHun";
ReqFeedWuHunMsg.msgClassName = "ReqFeedWuHunMsg";
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
MsgType.CS_ProceWuHun
]]
_G.ReqProceWuHunMsg = {};

ReqProceWuHunMsg.msgId = 3093;
ReqProceWuHunMsg.msgType = "CS_ProceWuHun";
ReqProceWuHunMsg.msgClassName = "ReqProceWuHunMsg";
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
MsgType.CS_AdjunctionWuHun
]]
_G.ReqAdjunctionWuHunMsg = {};

ReqAdjunctionWuHunMsg.msgId = 3094;
ReqAdjunctionWuHunMsg.msgType = "CS_AdjunctionWuHun";
ReqAdjunctionWuHunMsg.msgClassName = "ReqAdjunctionWuHunMsg";
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
MsgType.CS_Horn
]]
_G.ReqHornMsg = {};

ReqHornMsg.msgId = 3095;
ReqHornMsg.msgType = "CS_Horn";
ReqHornMsg.msgClassName = "ReqHornMsg";
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
MsgType.CS_SkillShortCut
]]
_G.ReqSkillShortCutMsg = {};

ReqSkillShortCutMsg.msgId = 3097;
ReqSkillShortCutMsg.msgType = "CS_SkillShortCut";
ReqSkillShortCutMsg.msgClassName = "ReqSkillShortCutMsg";
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
MsgType.CS_DungeonNpcTalkEnd
]]
_G.ReqDungeonNpcTalkEndMsg = {};

ReqDungeonNpcTalkEndMsg.msgId = 3101;
ReqDungeonNpcTalkEndMsg.msgType = "CS_DungeonNpcTalkEnd";
ReqDungeonNpcTalkEndMsg.msgClassName = "ReqDungeonNpcTalkEndMsg";
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
MsgType.CS_EnterDungeon
]]
_G.ReqEnterDungeonMsg = {};

ReqEnterDungeonMsg.msgId = 3102;
ReqEnterDungeonMsg.msgType = "CS_EnterDungeon";
ReqEnterDungeonMsg.msgClassName = "ReqEnterDungeonMsg";
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
MsgType.CS_LeaveDungeon
]]
_G.ReqCS_LeaveDungeon = {};

ReqCS_LeaveDungeon.msgId = 3103;
ReqCS_LeaveDungeon.msgType = "CS_LeaveDungeon";
ReqCS_LeaveDungeon.msgClassName = "ReqCS_LeaveDungeon";
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
MsgType.CS_StoryEnd
]]
_G.ReqStoryEndMsg = {};

ReqStoryEndMsg.msgId = 3104;
ReqStoryEndMsg.msgType = "CS_StoryEnd";
ReqStoryEndMsg.msgClassName = "ReqStoryEndMsg";
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
MsgType.CS_ExchangeReq
]]
_G.ReqExchangeMsg = {};

ReqExchangeMsg.msgId = 3106;
ReqExchangeMsg.msgType = "CS_ExchangeReq";
ReqExchangeMsg.msgClassName = "ReqExchangeMsg";
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
MsgType.CS_ExchangeInviteRt
]]
_G.ReqExchangeInviteRtMsg = {};

ReqExchangeInviteRtMsg.msgId = 3107;
ReqExchangeInviteRtMsg.msgType = "CS_ExchangeInviteRt";
ReqExchangeInviteRtMsg.msgClassName = "ReqExchangeInviteRtMsg";
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
MsgType.CS_ExchangeMoveItem
]]
_G.ReqExchangeMoveItemMsg = {};

ReqExchangeMoveItemMsg.msgId = 3108;
ReqExchangeMoveItemMsg.msgType = "CS_ExchangeMoveItem";
ReqExchangeMoveItemMsg.msgClassName = "ReqExchangeMoveItemMsg";
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
MsgType.CS_ExchangeHandle
]]
_G.ReqExchangeHandleMsg = {};

ReqExchangeHandleMsg.msgId = 3109;
ReqExchangeHandleMsg.msgType = "CS_ExchangeHandle";
ReqExchangeHandleMsg.msgClassName = "ReqExchangeHandleMsg";
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
MsgType.CS_ZhenBaoGe
]]
_G.ReqZhenBaoGeMsg = {};

ReqZhenBaoGeMsg.msgId = 3113;
ReqZhenBaoGeMsg.msgType = "CS_ZhenBaoGe";
ReqZhenBaoGeMsg.msgClassName = "ReqZhenBaoGeMsg";



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
MsgType.CS_ZhenBaoGeSubmit
]]
_G.ReqZhenBaoGeSubmitMsg = {};

ReqZhenBaoGeSubmitMsg.msgId = 3114;
ReqZhenBaoGeSubmitMsg.msgType = "CS_ZhenBaoGeSubmit";
ReqZhenBaoGeSubmitMsg.msgClassName = "ReqZhenBaoGeSubmitMsg";
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
MsgType.CS_ZhenBaoGeSpeItem
]]
_G.ReqZhenBaoGeSpeItemMsg = {};

ReqZhenBaoGeSpeItemMsg.msgId = 3115;
ReqZhenBaoGeSpeItemMsg.msgType = "CS_ZhenBaoGeSpeItem";
ReqZhenBaoGeSpeItemMsg.msgClassName = "ReqZhenBaoGeSpeItemMsg";
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
MsgType.CS_Shopping
]]
_G.ReqShoppingMsg = {};

ReqShoppingMsg.msgId = 3116;
ReqShoppingMsg.msgType = "CS_Shopping";
ReqShoppingMsg.msgClassName = "ReqShoppingMsg";
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
MsgType.CS_RideLvlUp
]]
_G.ReqRideLvlUpMsg = {};

ReqRideLvlUpMsg.msgId = 3118;
ReqRideLvlUpMsg.msgType = "CS_RideLvlUp";
ReqRideLvlUpMsg.msgClassName = "ReqRideLvlUpMsg";
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
MsgType.CS_UseAttrDan
]]
_G.ReqUseAttrDanMsg = {};

ReqUseAttrDanMsg.msgId = 3120;
ReqUseAttrDanMsg.msgType = "CS_UseAttrDan";
ReqUseAttrDanMsg.msgClassName = "ReqUseAttrDanMsg";
ReqUseAttrDanMsg.type = 0; -- 1、坐骑，2、灵兽，3、神兵、4、灵阵，5、骑战，6、神灵，7、元灵，8、灵兽坐骑百分比属性丹，9、战弩，10 = 五行灵脉 11 法宝 12 命玉 13  保甲 14  境界



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
MsgType.CS_ChangeRideId
]]
_G.ReqChangeRideIdMsg = {};

ReqChangeRideIdMsg.msgId = 3121;
ReqChangeRideIdMsg.msgType = "CS_ChangeRideId";
ReqChangeRideIdMsg.msgClassName = "ReqChangeRideIdMsg";
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
MsgType.CS_ChangeRideState
]]
_G.ReqChangeRideStateMsg = {};

ReqChangeRideStateMsg.msgId = 3122;
ReqChangeRideStateMsg.msgType = "CS_ChangeRideState";
ReqChangeRideStateMsg.msgClassName = "ReqChangeRideStateMsg";
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
MsgType.CS_BuyBack
]]
_G.ReqBuyBackMsg = {};

ReqBuyBackMsg.msgId = 3125;
ReqBuyBackMsg.msgType = "CS_BuyBack";
ReqBuyBackMsg.msgClassName = "ReqBuyBackMsg";
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
MsgType.CS_ShiHunSummon
]]
_G.ReqShiHunSummonMsg = {};

ReqShiHunSummonMsg.msgId = 3130;
ReqShiHunSummonMsg.msgType = "CS_ShiHunSummon";
ReqShiHunSummonMsg.msgClassName = "ReqShiHunSummonMsg";
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
MsgType.CS_SitStatusChange
]]
_G.ReqSitStatusChangeMsg = {};

ReqSitStatusChangeMsg.msgId = 3133;
ReqSitStatusChangeMsg.msgType = "CS_SitStatusChange";
ReqSitStatusChangeMsg.msgClassName = "ReqSitStatusChangeMsg";
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
MsgType.CS_NearbySit
]]
_G.ReqNearbySitMsg = {};

ReqNearbySitMsg.msgId = 3134;
ReqNearbySitMsg.msgType = "CS_NearbySit";
ReqNearbySitMsg.msgClassName = "ReqNearbySitMsg";



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
MsgType.CS_DungeonGroup
]]
_G.ReqDungeonGroupMsg = {};

ReqDungeonGroupMsg.msgId = 3137;
ReqDungeonGroupMsg.msgType = "CS_DungeonGroup";
ReqDungeonGroupMsg.msgClassName = "ReqDungeonGroupMsg";



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
MsgType.CS_DungeonAbstain
]]
_G.ReqDungeonAbstainMsg = {};

ReqDungeonAbstainMsg.msgId = 3140;
ReqDungeonAbstainMsg.msgType = "CS_DungeonAbstain";
ReqDungeonAbstainMsg.msgClassName = "ReqDungeonAbstainMsg";
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
MsgType.CS_DungeonGetAward
]]
_G.ReqDungeonGetAwardMsg = {};

ReqDungeonGetAwardMsg.msgId = 3141;
ReqDungeonGetAwardMsg.msgType = "CS_DungeonGetAward";
ReqDungeonGetAwardMsg.msgClassName = "ReqDungeonGetAwardMsg";



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
MsgType.CS_TitleEquip
]]
_G.ReqTitleEpuipMsg = {};

ReqTitleEpuipMsg.msgId = 3143;
ReqTitleEpuipMsg.msgType = "CS_TitleEquip";
ReqTitleEpuipMsg.msgClassName = "ReqTitleEpuipMsg";
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
MsgType.CS_EquipPro
]]
_G.ReqEquipProMsg = {};

ReqEquipProMsg.msgId = 3147;
ReqEquipProMsg.msgType = "CS_EquipPro";
ReqEquipProMsg.msgClassName = "ReqEquipProMsg";
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
MsgType.CS_EquipInherit
]]
_G.ReqEquipInheritMsg = {};

ReqEquipInheritMsg.msgId = 3148;
ReqEquipInheritMsg.msgType = "CS_EquipInherit";
ReqEquipInheritMsg.msgClassName = "ReqEquipInheritMsg";
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
MsgType.CS_DailyQuestStar
]]
_G.ReqDailyQuestStarMsg = {};

ReqDailyQuestStarMsg.msgId = 3152;
ReqDailyQuestStarMsg.msgType = "CS_DailyQuestStar";
ReqDailyQuestStarMsg.msgClassName = "ReqDailyQuestStarMsg";
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
MsgType.CS_DailyQuestFinish
]]
_G.ReqDailyQuestFinishMsg = {};

ReqDailyQuestFinishMsg.msgId = 3153;
ReqDailyQuestFinishMsg.msgType = "CS_DailyQuestFinish";
ReqDailyQuestFinishMsg.msgClassName = "ReqDailyQuestFinishMsg";
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
MsgType.CS_DailyQuestResult
]]
_G.ReqDailyQuestResultMsg = {};

ReqDailyQuestResultMsg.msgId = 3154;
ReqDailyQuestResultMsg.msgType = "CS_DailyQuestResult";
ReqDailyQuestResultMsg.msgClassName = "ReqDailyQuestResultMsg";



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
MsgType.CS_DQDraw
]]
_G.ReqDailyQuestDrawMsg = {};

ReqDailyQuestDrawMsg.msgId = 3155;
ReqDailyQuestDrawMsg.msgType = "CS_DQDraw";
ReqDailyQuestDrawMsg.msgClassName = "ReqDailyQuestDrawMsg";



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
MsgType.CS_DQDrawConfirm
]]
_G.ReqDailyQuestDrawConfirmMsg = {};

ReqDailyQuestDrawConfirmMsg.msgId = 3156;
ReqDailyQuestDrawConfirmMsg.msgType = "CS_DQDrawConfirm";
ReqDailyQuestDrawConfirmMsg.msgClassName = "ReqDailyQuestDrawConfirmMsg";



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
MsgType.CS_EquipGemUpLevel
]]
_G.ReqEquipGemUpLevelMsg = {};

ReqEquipGemUpLevelMsg.msgId = 3157;
ReqEquipGemUpLevelMsg.msgType = "CS_EquipGemUpLevel";
ReqEquipGemUpLevelMsg.msgClassName = "ReqEquipGemUpLevelMsg";
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
MsgType.CS_ActivityEnter
]]
_G.ReqActivityEnterMsg = {};

ReqActivityEnterMsg.msgId = 3159;
ReqActivityEnterMsg.msgType = "CS_ActivityEnter";
ReqActivityEnterMsg.msgClassName = "ReqActivityEnterMsg";
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
MsgType.CS_ActivityQuit
]]
_G.ReqActivityQuitMsg = {};

ReqActivityQuitMsg.msgId = 3160;
ReqActivityQuitMsg.msgType = "CS_ActivityQuit";
ReqActivityQuitMsg.msgClassName = "ReqActivityQuitMsg";
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
MsgType.CS_FengYaoInfo
]]
_G.ReqFengYaoInfoMsg = {};

ReqFengYaoInfoMsg.msgId = 3164;
ReqFengYaoInfoMsg.msgType = "CS_FengYaoInfo";
ReqFengYaoInfoMsg.msgClassName = "ReqFengYaoInfoMsg";



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
MsgType.CS_FengYaoLvlRefresh
]]
_G.ReqFengYaoLvlRefreshMsg = {};

ReqFengYaoLvlRefreshMsg.msgId = 3165;
ReqFengYaoLvlRefreshMsg.msgType = "CS_FengYaoLvlRefresh";
ReqFengYaoLvlRefreshMsg.msgClassName = "ReqFengYaoLvlRefreshMsg";
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
领取封妖奖励
MsgType.CS_GetFengYaoReward
]]
_G.ReqGetFengYaoRewardMsg = {};

ReqGetFengYaoRewardMsg.msgId = 3168;
ReqGetFengYaoRewardMsg.msgType = "CS_GetFengYaoReward";
ReqGetFengYaoRewardMsg.msgClassName = "ReqGetFengYaoRewardMsg";
ReqGetFengYaoRewardMsg.fengyaoid = 0; -- 封妖id



ReqGetFengYaoRewardMsg.meta = {__index = ReqGetFengYaoRewardMsg };
function ReqGetFengYaoRewardMsg:new()
	local obj = setmetatable( {}, ReqGetFengYaoRewardMsg.meta);
	return obj;
end

function ReqGetFengYaoRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.fengyaoid);

	return body;
end

function ReqGetFengYaoRewardMsg:ParseData(pak)
	local idx = 1;

	self.fengyaoid, idx = readInt(pak, idx);

end



--[[
获取封妖宝箱奖励
MsgType.CS_GetFengYaoBox
]]
_G.ReqGetFengYaoBoxMsg = {};

ReqGetFengYaoBoxMsg.msgId = 3171;
ReqGetFengYaoBoxMsg.msgType = "CS_GetFengYaoBox";
ReqGetFengYaoBoxMsg.msgClassName = "ReqGetFengYaoBoxMsg";
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
MsgType.CS_SendPKRule
]]
_G.ReqSendPKRuleMsg = {};

ReqSendPKRuleMsg.msgId = 3172;
ReqSendPKRuleMsg.msgType = "CS_SendPKRule";
ReqSendPKRuleMsg.msgClassName = "ReqSendPKRuleMsg";
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
MsgType.CS_YaoHunExchange
]]
_G.ReqYaoHunExchangeMsg = {};

ReqYaoHunExchangeMsg.msgId = 3175;
ReqYaoHunExchangeMsg.msgType = "CS_YaoHunExchange";
ReqYaoHunExchangeMsg.msgClassName = "ReqYaoHunExchangeMsg";
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
MsgType.CS_Sign
]]
_G.ReqSignMsg = {};

ReqSignMsg.msgId = 3179;
ReqSignMsg.msgType = "CS_Sign";
ReqSignMsg.msgClassName = "ReqSignMsg";
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
MsgType.CS_SignReward
]]
_G.ReqSignRewardMsg = {};

ReqSignRewardMsg.msgId = 3180;
ReqSignRewardMsg.msgType = "CS_SignReward";
ReqSignRewardMsg.msgClassName = "ReqSignRewardMsg";
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
MsgType.CS_GetLvlReward
]]
_G.ReqGetLvlRewardMsg = {};

ReqGetLvlRewardMsg.msgId = 3182;
ReqGetLvlRewardMsg.msgType = "CS_GetLvlReward";
ReqGetLvlRewardMsg.msgClassName = "ReqGetLvlRewardMsg";
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
MsgType.CS_ZhancRank
]]
_G.ReqZhancRankMsg = {};

ReqZhancRankMsg.msgId = 3184;
ReqZhancRankMsg.msgType = "CS_ZhancRank";
ReqZhancRankMsg.msgClassName = "ReqZhancRankMsg";
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
MsgType.CS_AskQuitArena
]]
_G.ReqQuitArenaMsg = {};

ReqQuitArenaMsg.msgId = 3192;
ReqQuitArenaMsg.msgType = "CS_AskQuitArena";
ReqQuitArenaMsg.msgClassName = "ReqQuitArenaMsg";



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
MsgType.CS_PickFlag
]]
_G.ReqPickFlagMsg = {};

ReqPickFlagMsg.msgId = 3199;
ReqPickFlagMsg.msgType = "CS_PickFlag";
ReqPickFlagMsg.msgClassName = "ReqPickFlagMsg";
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
MsgType.CS_Teleport
]]
_G.ReqTeleportMsg = {};

ReqTeleportMsg.msgId = 3200;
ReqTeleportMsg.msgType = "CS_Teleport";
ReqTeleportMsg.msgClassName = "ReqTeleportMsg";
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
MsgType.CS_ToolHeCheng
]]
_G.ReqToolHeChengMsg = {};

ReqToolHeChengMsg.msgId = 3204;
ReqToolHeChengMsg.msgType = "CS_ToolHeCheng";
ReqToolHeChengMsg.msgClassName = "ReqToolHeChengMsg";
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
MsgType.CS_QuickJieFeng
]]
_G.ReqQuickJieFengMsg = {};

ReqQuickJieFengMsg.msgId = 3209;
ReqQuickJieFengMsg.msgType = "CS_QuickJieFeng";
ReqQuickJieFengMsg.msgClassName = "ReqQuickJieFengMsg";
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
MsgType.CS_RequestBossFallStar
]]
_G.ReqBossFallStarMsg = {};

ReqBossFallStarMsg.msgId = 3210;
ReqBossFallStarMsg.msgType = "CS_RequestBossFallStar";
ReqBossFallStarMsg.msgClassName = "ReqBossFallStarMsg";
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
MsgType.CS_ZhancGetReward
]]
_G.ReqZhancRewardMsg = {};

ReqZhancRewardMsg.msgId = 3215;
ReqZhancRewardMsg.msgType = "CS_ZhancGetReward";
ReqZhancRewardMsg.msgClassName = "ReqZhancRewardMsg";



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
MsgType.CS_QuitGuildHell
]]
_G.ReqQuitGuildHellMsg = {};

ReqQuitGuildHellMsg.msgId = 3216;
ReqQuitGuildHellMsg.msgType = "CS_QuitGuildHell";
ReqQuitGuildHellMsg.msgClassName = "ReqQuitGuildHellMsg";



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
MsgType.CS_OtherHumanInfo
]]
_G.ReqOtherHumanInfoMsg = {};

ReqOtherHumanInfoMsg.msgId = 3217;
ReqOtherHumanInfoMsg.msgType = "CS_OtherHumanInfo";
ReqOtherHumanInfoMsg.msgClassName = "ReqOtherHumanInfoMsg";
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
MsgType.CS_SetSystemInfo
]]
_G.ReqSetSystemInfoMsg = {};

ReqSetSystemInfoMsg.msgId = 3223;
ReqSetSystemInfoMsg.msgType = "CS_SetSystemInfo";
ReqSetSystemInfoMsg.msgClassName = "ReqSetSystemInfoMsg";
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
MsgType.CS_SetDynamicDrop
]]
_G.ReqSetDynamicDropMsg = {};

ReqSetDynamicDropMsg.msgId = 3224;
ReqSetDynamicDropMsg.msgType = "CS_SetDynamicDrop";
ReqSetDynamicDropMsg.msgClassName = "ReqSetDynamicDropMsg";
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
MsgType.CS_DressFashion
]]
_G.ReqDressFashionMsg = {};

ReqDressFashionMsg.msgId = 3226;
ReqDressFashionMsg.msgType = "CS_DressFashion";
ReqDressFashionMsg.msgClassName = "ReqDressFashionMsg";
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
MsgType.CS_GetBabelInfo
]]
_G.ReqGetBabelInfoMsg = {};

ReqGetBabelInfoMsg.msgId = 3231;
ReqGetBabelInfoMsg.msgType = "CS_GetBabelInfo";
ReqGetBabelInfoMsg.msgClassName = "ReqGetBabelInfoMsg";
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
MsgType.CS_GetRankingList
]]
_G.ReqGetRankingListMsg = {};

ReqGetRankingListMsg.msgId = 3232;
ReqGetRankingListMsg.msgType = "CS_GetRankingList";
ReqGetRankingListMsg.msgClassName = "ReqGetRankingListMsg";



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
MsgType.CS_EnterInto
]]
_G.ReqEnterIntoMsg = {};

ReqEnterIntoMsg.msgId = 3233;
ReqEnterIntoMsg.msgType = "CS_EnterInto";
ReqEnterIntoMsg.msgClassName = "ReqEnterIntoMsg";
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
MsgType.CS_OutBabel
]]
_G.ReqOutBabelMsg = {};

ReqOutBabelMsg.msgId = 3234;
ReqOutBabelMsg.msgType = "CS_OutBabel";
ReqOutBabelMsg.msgClassName = "ReqOutBabelMsg";
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
MsgType.CS_EnterGuildWar
]]
_G.ReqEnterGuildWarMsg = {};

ReqEnterGuildWarMsg.msgId = 3237;
ReqEnterGuildWarMsg.msgType = "CS_EnterGuildWar";
ReqEnterGuildWarMsg.msgClassName = "ReqEnterGuildWarMsg";
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
MsgType.CS_QuitGuildWar
]]
_G.ReqQuitGuildWarMsg = {};

ReqQuitGuildWarMsg.msgId = 3238;
ReqQuitGuildWarMsg.msgType = "CS_QuitGuildWar";
ReqQuitGuildWarMsg.msgClassName = "ReqQuitGuildWarMsg";



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
追加属性传承
MsgType.CS_EquipExtraInherit
]]
_G.ReqEquipExtraInheritMsg = {};

ReqEquipExtraInheritMsg.msgId = 3247;
ReqEquipExtraInheritMsg.msgType = "CS_EquipExtraInherit";
ReqEquipExtraInheritMsg.msgClassName = "ReqEquipExtraInheritMsg";
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
MsgType.CS_MagicWeaponLevelUp
]]
_G.ReqMagicWeaponLevelUpMsg = {};

ReqMagicWeaponLevelUpMsg.msgId = 3250;
ReqMagicWeaponLevelUpMsg.msgType = "CS_MagicWeaponLevelUp";
ReqMagicWeaponLevelUpMsg.msgClassName = "ReqMagicWeaponLevelUpMsg";
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
MsgType.CS_EnterTimeDungeon
]]
_G.ReqEnterTimeDungeonMsg = {};

ReqEnterTimeDungeonMsg.msgId = 3251;
ReqEnterTimeDungeonMsg.msgType = "CS_EnterTimeDungeon";
ReqEnterTimeDungeonMsg.msgClassName = "ReqEnterTimeDungeonMsg";
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
MsgType.CS_QuitTimeDungeon
]]
_G.ReqQuitTimeDungeonMsg = {};

ReqQuitTimeDungeonMsg.msgId = 3252;
ReqQuitTimeDungeonMsg.msgType = "CS_QuitTimeDungeon";
ReqQuitTimeDungeonMsg.msgClassName = "ReqQuitTimeDungeonMsg";



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
MsgType.CS_DungeonNum
]]
_G.ReqDungeonNumMsg = {};

ReqDungeonNumMsg.msgId = 3253;
ReqDungeonNumMsg.msgType = "CS_DungeonNum";
ReqDungeonNumMsg.msgClassName = "ReqDungeonNumMsg";



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
MsgType.CS_GetUnionWarReward
]]
_G.ReqGetUnionWarRewardMsg = {};

ReqGetUnionWarRewardMsg.msgId = 3257;
ReqGetUnionWarRewardMsg.msgType = "CS_GetUnionWarReward";
ReqGetUnionWarRewardMsg.msgClassName = "ReqGetUnionWarRewardMsg";



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
MsgType.CS_GetOutLineReward
]]
_G.ReqGetOutLineRewardMsg = {};

ReqGetOutLineRewardMsg.msgId = 3259;
ReqGetOutLineRewardMsg.msgType = "CS_GetOutLineReward";
ReqGetOutLineRewardMsg.msgClassName = "ReqGetOutLineRewardMsg";
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
MsgType.CS_HuoYueLevelup
]]
_G.ReqHuoYueLevelupMsg = {};

ReqHuoYueLevelupMsg.msgId = 3262;
ReqHuoYueLevelupMsg.msgType = "CS_HuoYueLevelup";
ReqHuoYueLevelupMsg.msgClassName = "ReqHuoYueLevelupMsg";



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
MsgType.CS_SendStoryEnd
]]
_G.ReqsSendStoryEndMsg = {};

ReqsSendStoryEndMsg.msgId = 3263;
ReqsSendStoryEndMsg.msgType = "CS_SendStoryEnd";
ReqsSendStoryEndMsg.msgClassName = "ReqsSendStoryEndMsg";
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
MsgType.CS_RandomReward
]]
_G.ReqRandomRewardMsg = {};

ReqRandomRewardMsg.msgId = 3265;
ReqRandomRewardMsg.msgType = "CS_RandomReward";
ReqRandomRewardMsg.msgClassName = "ReqRandomRewardMsg";
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
MsgType.CS_ReqPractice
]]
_G.ReqPracticeMsg = {};

ReqPracticeMsg.msgId = 3290;
ReqPracticeMsg.msgType = "CS_ReqPractice";
ReqPracticeMsg.msgClassName = "ReqPracticeMsg";
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
MsgType.CS_BreakJingjie
]]
_G.ReqBreakJingjieMsg = {};

ReqBreakJingjieMsg.msgId = 3291;
ReqBreakJingjieMsg.msgType = "CS_BreakJingjie";
ReqBreakJingjieMsg.msgClassName = "ReqBreakJingjieMsg";
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
MsgType.CS_ReqExtremityInfo
]]
_G.ReqExtremityInfoMsg = {};

ReqExtremityInfoMsg.msgId = 3293;
ReqExtremityInfoMsg.msgType = "CS_ReqExtremityInfo";
ReqExtremityInfoMsg.msgClassName = "ReqExtremityInfoMsg";



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
MsgType.CS_ReqEnterExtremity
]]
_G.ReqEnterExtremityMsg = {};

ReqEnterExtremityMsg.msgId = 3294;
ReqEnterExtremityMsg.msgType = "CS_ReqEnterExtremity";
ReqEnterExtremityMsg.msgClassName = "ReqEnterExtremityMsg";



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
MsgType.CS_ReqQuitExtremity
]]
_G.ReqQuitExtremityMsg = {};

ReqQuitExtremityMsg.msgId = 3295;
ReqQuitExtremityMsg.msgType = "CS_ReqQuitExtremity";
ReqQuitExtremityMsg.msgClassName = "ReqQuitExtremityMsg";



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
MsgType.CS_EnterGuildCityWar
]]
_G.ReqEnterGuildCityWarMsg = {};

ReqEnterGuildCityWarMsg.msgId = 3302;
ReqEnterGuildCityWarMsg.msgType = "CS_EnterGuildCityWar";
ReqEnterGuildCityWarMsg.msgClassName = "ReqEnterGuildCityWarMsg";
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
MsgType.CS_QuitGuildCityWar
]]
_G.ReqQuitGuildCityWarMsg = {};

ReqQuitGuildCityWarMsg.msgId = 3303;
ReqQuitGuildCityWarMsg.msgType = "CS_QuitGuildCityWar";
ReqQuitGuildCityWarMsg.msgClassName = "ReqQuitGuildCityWarMsg";



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
MsgType.CS_DynamicDropItems
]]
_G.ReqDynamicDropItemsMsg = {};

ReqDynamicDropItemsMsg.msgId = 3306;
ReqDynamicDropItemsMsg.msgType = "CS_DynamicDropItems";
ReqDynamicDropItemsMsg.msgClassName = "ReqDynamicDropItemsMsg";



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
MsgType.CS_DungeonRank
]]
_G.ReqDungeonRankMsg = {};

ReqDungeonRankMsg.msgId = 3308;
ReqDungeonRankMsg.msgType = "CS_DungeonRank";
ReqDungeonRankMsg.msgClassName = "ReqDungeonRankMsg";
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
MsgType.CS_UnionCityWarGetReward
]]
_G.ReqUnionCityWarGetRewardMsg = {};

ReqUnionCityWarGetRewardMsg.msgId = 3310;
ReqUnionCityWarGetRewardMsg.msgType = "CS_UnionCityWarGetReward";
ReqUnionCityWarGetRewardMsg.msgClassName = "ReqUnionCityWarGetRewardMsg";



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
MsgType.CS_DailyMustDo
]]
_G.ReqDailyMustDoMsg = {};

ReqDailyMustDoMsg.msgId = 3311;
ReqDailyMustDoMsg.msgType = "CS_DailyMustDo";
ReqDailyMustDoMsg.msgClassName = "ReqDailyMustDoMsg";



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
MsgType.CS_FinishMustDo
]]
_G.ReqFinishMustDoMsg = {};

ReqFinishMustDoMsg.msgId = 3312;
ReqFinishMustDoMsg.msgType = "CS_FinishMustDo";
ReqFinishMustDoMsg.msgClassName = "ReqFinishMustDoMsg";
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
MsgType.CS_FinishAllMustDo
]]
_G.ReqFinishAllMustDoMsg = {};

ReqFinishAllMustDoMsg.msgId = 3313;
ReqFinishAllMustDoMsg.msgType = "CS_FinishAllMustDo";
ReqFinishAllMustDoMsg.msgClassName = "ReqFinishAllMustDoMsg";
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
MsgType.CS_OperActGetReward
]]
_G.ReqOperActGetRewardMsg = {};

ReqOperActGetRewardMsg.msgId = 3315;
ReqOperActGetRewardMsg.msgType = "CS_OperActGetReward";
ReqOperActGetRewardMsg.msgClassName = "ReqOperActGetRewardMsg";
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
MsgType.CS_BackHome
]]
_G.ReqBackHomeMsg = {};

ReqBackHomeMsg.msgId = 3318;
ReqBackHomeMsg.msgType = "CS_BackHome";
ReqBackHomeMsg.msgClassName = "ReqBackHomeMsg";
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
MsgType.CS_ReqRealmFlood
]]
_G.ReqRealmFloodMsg = {};

ReqRealmFloodMsg.msgId = 3322;
ReqRealmFloodMsg.msgType = "CS_ReqRealmFlood";
ReqRealmFloodMsg.msgClassName = "ReqRealmFloodMsg";
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
MsgType.CS_GoBreak
]]
_G.ReqGoBreakMsg = {};

ReqGoBreakMsg.msgId = 3323;
ReqGoBreakMsg.msgType = "CS_GoBreak";
ReqGoBreakMsg.msgClassName = "ReqGoBreakMsg";
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
MsgType.CS_BeicangjieQuit
]]
_G.ReqBeicangjieQuitMsg = {};

ReqBeicangjieQuitMsg.msgId = 3331;
ReqBeicangjieQuitMsg.msgType = "CS_BeicangjieQuit";
ReqBeicangjieQuitMsg.msgClassName = "ReqBeicangjieQuitMsg";



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
MsgType.CS_BeicangjieCon
]]
_G.ReqBeicangjieConMsg = {};

ReqBeicangjieConMsg.msgId = 3332;
ReqBeicangjieConMsg.msgType = "CS_BeicangjieCon";
ReqBeicangjieConMsg.msgClassName = "ReqBeicangjieConMsg";



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
MsgType.CS_SpiritWarPrintSwap
]]
_G.ReqSpiritWarPrintSwapMsg = {};

ReqSpiritWarPrintSwapMsg.msgId = 3338;
ReqSpiritWarPrintSwapMsg.msgType = "CS_SpiritWarPrintSwap";
ReqSpiritWarPrintSwapMsg.msgClassName = "ReqSpiritWarPrintSwapMsg";
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
MsgType.CS_SpiritWarPrintAutoDevour
]]
_G.ReqSpiritWarPrintAutoDevourMsg = {};

ReqSpiritWarPrintAutoDevourMsg.msgId = 3339;
ReqSpiritWarPrintAutoDevourMsg.msgType = "CS_SpiritWarPrintAutoDevour";
ReqSpiritWarPrintAutoDevourMsg.msgClassName = "ReqSpiritWarPrintAutoDevourMsg";
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
MsgType.CS_SpiritWarPrintDevour
]]
_G.ReqSpiritWarPrintDevourMsg = {};

ReqSpiritWarPrintDevourMsg.msgId = 3340;
ReqSpiritWarPrintDevourMsg.msgType = "CS_SpiritWarPrintDevour";
ReqSpiritWarPrintDevourMsg.msgClassName = "ReqSpiritWarPrintDevourMsg";
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
购买
MsgType.CS_SpiritWarPrintBuy
]]
_G.ReqSpiritWarPrintBuyMsg = {};

ReqSpiritWarPrintBuyMsg.msgId = 3342;
ReqSpiritWarPrintBuyMsg.msgType = "CS_SpiritWarPrintBuy";
ReqSpiritWarPrintBuyMsg.msgClassName = "ReqSpiritWarPrintBuyMsg";
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
MsgType.CS_WuHunLingshouInfo
]]
_G.ReqQueryWuHunLingshouInfoMsg = {};

ReqQueryWuHunLingshouInfoMsg.msgId = 3344;
ReqQueryWuHunLingshouInfoMsg.msgType = "CS_WuHunLingshouInfo";
ReqQueryWuHunLingshouInfoMsg.msgClassName = "ReqQueryWuHunLingshouInfoMsg";



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
MsgType.CS_WuHunShenshouList
]]
_G.ReqQueryWuHunShenshouMsg = {};

ReqQueryWuHunShenshouMsg.msgId = 3345;
ReqQueryWuHunShenshouMsg.msgType = "CS_WuHunShenshouList";
ReqQueryWuHunShenshouMsg.msgClassName = "ReqQueryWuHunShenshouMsg";



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
MsgType.CS_AdjunctionWuHunShenshou
]]
_G.ReqAdjunctionWuHunShenshouMsg = {};

ReqAdjunctionWuHunShenshouMsg.msgId = 3346;
ReqAdjunctionWuHunShenshouMsg.msgType = "CS_AdjunctionWuHunShenshou";
ReqAdjunctionWuHunShenshouMsg.msgClassName = "ReqAdjunctionWuHunShenshouMsg";
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
MsgType.CS_AddWuHunShenshou
]]
_G.ReqAddWuHunShenshouMsg = {};

ReqAddWuHunShenshouMsg.msgId = 3347;
ReqAddWuHunShenshouMsg.msgType = "CS_AddWuHunShenshou";
ReqAddWuHunShenshouMsg.msgClassName = "ReqAddWuHunShenshouMsg";
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
MsgType.CS_SpiritWarPrintBuyStore
]]
_G.ReqSpiritWarPrintBuyStoreMsg = {};

ReqSpiritWarPrintBuyStoreMsg.msgId = 3348;
ReqSpiritWarPrintBuyStoreMsg.msgType = "CS_SpiritWarPrintBuyStore";
ReqSpiritWarPrintBuyStoreMsg.msgClassName = "ReqSpiritWarPrintBuyStoreMsg";
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
请求领取V等级礼包
MsgType.CS_VLevelGift
]]
_G.ReqVLevelGiftMsg = {};

ReqVLevelGiftMsg.msgId = 3359;
ReqVLevelGiftMsg.msgType = "CS_VLevelGift";
ReqVLevelGiftMsg.msgClassName = "ReqVLevelGiftMsg";
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
MsgType.CS_VDayGift
]]
_G.ReqVDayGiftMsg = {};

ReqVDayGiftMsg.msgId = 3360;
ReqVDayGiftMsg.msgType = "CS_VDayGift";
ReqVDayGiftMsg.msgClassName = "ReqVDayGiftMsg";
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
MsgType.CS_VVGift
]]
_G.ReqVVGiftMsg = {};

ReqVVGiftMsg.msgId = 3361;
ReqVVGiftMsg.msgType = "CS_VVGift";
ReqVVGiftMsg.msgClassName = "ReqVVGiftMsg";



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
MsgType.CS_VYearGift
]]
_G.ReqVYearGiftMsg = {};

ReqVYearGiftMsg.msgId = 3362;
ReqVYearGiftMsg.msgType = "CS_VYearGift";
ReqVYearGiftMsg.msgClassName = "ReqVYearGiftMsg";



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
MsgType.CS_VTitle
]]
_G.ReqVTitleMsg = {};

ReqVTitleMsg.msgId = 3363;
ReqVTitleMsg.msgType = "CS_VTitle";
ReqVTitleMsg.msgClassName = "ReqVTitleMsg";
ReqVTitleMsg.type = 0; -- 1：v1等级,2：v23等级,3：v45等级



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
MsgType.CS_ReqHuiZhangPractice
]]
_G.ReqHuiZhangPracticeMsg = {};

ReqHuiZhangPracticeMsg.msgId = 3366;
ReqHuiZhangPracticeMsg.msgType = "CS_ReqHuiZhangPractice";
ReqHuiZhangPracticeMsg.msgClassName = "ReqHuiZhangPracticeMsg";
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
MsgType.CS_BreakHuiZhang
]]
_G.ReqBreakHuiZhangMsg = {};

ReqBreakHuiZhangMsg.msgId = 3367;
ReqBreakHuiZhangMsg.msgType = "CS_BreakHuiZhang";
ReqBreakHuiZhangMsg.msgClassName = "ReqBreakHuiZhangMsg";



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
MsgType.CS_MClientReward
]]
_G.ReqMClientRewardMsg = {};

ReqMClientRewardMsg.msgId = 3368;
ReqMClientRewardMsg.msgType = "CS_MClientReward";
ReqMClientRewardMsg.msgClassName = "ReqMClientRewardMsg";



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
MsgType.CS_ReqGetJuLing
]]
_G.ReqGetJuLingMsg = {};

ReqGetJuLingMsg.msgId = 3370;
ReqGetJuLingMsg.msgType = "CS_ReqGetJuLing";
ReqGetJuLingMsg.msgClassName = "ReqGetJuLingMsg";



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
MsgType.CS_ReqGetRealmMax
]]
_G.ReqGetRealmMaxMsg = {};

ReqGetRealmMaxMsg.msgId = 3371;
ReqGetRealmMaxMsg.msgType = "CS_ReqGetRealmMax";
ReqGetRealmMaxMsg.msgClassName = "ReqGetRealmMaxMsg";



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
MsgType.CS_GetAchievementInfo
]]
_G.ReqGetAchievementInfoMsg = {};

ReqGetAchievementInfoMsg.msgId = 3372;
ReqGetAchievementInfoMsg.msgType = "CS_GetAchievementInfo";
ReqGetAchievementInfoMsg.msgClassName = "ReqGetAchievementInfoMsg";



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
MsgType.CS_GetAchievementReward
]]
_G.ReqGetAchievementRewardMsg = {};

ReqGetAchievementRewardMsg.msgId = 3373;
ReqGetAchievementRewardMsg.msgType = "CS_GetAchievementReward";
ReqGetAchievementRewardMsg.msgClassName = "ReqGetAchievementRewardMsg";
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
MsgType.CS_GetAchievementPonitReward
]]
_G.ReqGetAchievementPonitRewardMsg = {};

ReqGetAchievementPonitRewardMsg.msgId = 3374;
ReqGetAchievementPonitRewardMsg.msgType = "CS_GetAchievementPonitReward";
ReqGetAchievementPonitRewardMsg.msgClassName = "ReqGetAchievementPonitRewardMsg";
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
MsgType.CS_ReqLianTiXing
]]
_G.ReqLianTiXingMsg = {};

ReqLianTiXingMsg.msgId = 3377;
ReqLianTiXingMsg.msgType = "CS_ReqLianTiXing";
ReqLianTiXingMsg.msgClassName = "ReqLianTiXingMsg";
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
MsgType.CS_ReqLianTiLayer
]]
_G.ReqLianTiLayerMsg = {};

ReqLianTiLayerMsg.msgId = 3378;
ReqLianTiLayerMsg.msgType = "CS_ReqLianTiLayer";
ReqLianTiLayerMsg.msgClassName = "ReqLianTiLayerMsg";
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
MsgType.CS_CreateSuperItem
]]
_G.ReqCreateSuperItemMsg = {};

ReqCreateSuperItemMsg.msgId = 3385;
ReqCreateSuperItemMsg.msgType = "CS_CreateSuperItem";
ReqCreateSuperItemMsg.msgClassName = "ReqCreateSuperItemMsg";
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
MsgType.CS_EquipBuildStart
]]
_G.ReqEquipBuildStartMsg = {};

ReqEquipBuildStartMsg.msgId = 3387;
ReqEquipBuildStartMsg.msgType = "CS_EquipBuildStart";
ReqEquipBuildStartMsg.msgClassName = "ReqEquipBuildStartMsg";
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
MsgType.CS_EquipDecompose
]]
_G.ReqEquipDecomposeMsg = {};

ReqEquipDecomposeMsg.msgId = 3388;
ReqEquipDecomposeMsg.msgType = "CS_EquipDecompose";
ReqEquipDecomposeMsg.msgClassName = "ReqEquipDecomposeMsg";
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
MsgType.CS_DominateRoute
]]
_G.ReqDominateRouteMsg = {};

ReqDominateRouteMsg.msgId = 3390;
ReqDominateRouteMsg.msgType = "CS_DominateRoute";
ReqDominateRouteMsg.msgClassName = "ReqDominateRouteMsg";



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
MsgType.CS_DominateRouteChallenge
]]
_G.ReqDominateRouteChallengeMsg = {};

ReqDominateRouteChallengeMsg.msgId = 3392;
ReqDominateRouteChallengeMsg.msgType = "CS_DominateRouteChallenge";
ReqDominateRouteChallengeMsg.msgClassName = "ReqDominateRouteChallengeMsg";
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
MsgType.CS_DominateRouteQuit
]]
_G.ReqDominateRouteQuitMsg = {};

ReqDominateRouteQuitMsg.msgId = 3393;
ReqDominateRouteQuitMsg.msgType = "CS_DominateRouteQuit";
ReqDominateRouteQuitMsg.msgClassName = "ReqDominateRouteQuitMsg";



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
MsgType.CS_DominateRouteWipe
]]
_G.ReqDominateRouteWipeMsg = {};

ReqDominateRouteWipeMsg.msgId = 3395;
ReqDominateRouteWipeMsg.msgType = "CS_DominateRouteWipe";
ReqDominateRouteWipeMsg.msgClassName = "ReqDominateRouteWipeMsg";
ReqDominateRouteWipeMsg.id = 0; -- 扫荡ID



ReqDominateRouteWipeMsg.meta = {__index = ReqDominateRouteWipeMsg };
function ReqDominateRouteWipeMsg:new()
	local obj = setmetatable( {}, ReqDominateRouteWipeMsg.meta);
	return obj;
end

function ReqDominateRouteWipeMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqDominateRouteWipeMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
请求购买精力
MsgType.CS_DominateRouteVigor
]]
_G.ReqDominateRouteVigorMsg = {};

ReqDominateRouteVigorMsg.msgId = 3396;
ReqDominateRouteVigorMsg.msgType = "CS_DominateRouteVigor";
ReqDominateRouteVigorMsg.msgClassName = "ReqDominateRouteVigorMsg";



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
请求领取首通宝箱奖励
MsgType.CS_DominateRouteBoxReward
]]
_G.ReqDominateRouteBoxRewardMsg = {};

ReqDominateRouteBoxRewardMsg.msgId = 3397;
ReqDominateRouteBoxRewardMsg.msgType = "CS_DominateRouteBoxReward";
ReqDominateRouteBoxRewardMsg.msgClassName = "ReqDominateRouteBoxRewardMsg";
ReqDominateRouteBoxRewardMsg.id = 0; -- id



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
MsgType.CS_DominateRouteImmediately
]]
_G.ReqDominateRouteImmediatelyMsg = {};

ReqDominateRouteImmediatelyMsg.msgId = 3398;
ReqDominateRouteImmediatelyMsg.msgType = "CS_DominateRouteImmediately";
ReqDominateRouteImmediatelyMsg.msgClassName = "ReqDominateRouteImmediatelyMsg";



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
MsgType.CS_UseAllItem
]]
_G.ReqUseAllItemMsg = {};

ReqUseAllItemMsg.msgId = 3399;
ReqUseAllItemMsg.msgType = "CS_UseAllItem";
ReqUseAllItemMsg.msgClassName = "ReqUseAllItemMsg";
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
MsgType.CS_EquipRefininglvlUp
]]
_G.ReqEquipRefininglvlUpMsg = {};

ReqEquipRefininglvlUpMsg.msgId = 3403;
ReqEquipRefininglvlUpMsg.msgType = "CS_EquipRefininglvlUp";
ReqEquipRefininglvlUpMsg.msgClassName = "ReqEquipRefininglvlUpMsg";
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
MsgType.CS_EquipRefiningAutolvlUp
]]
_G.ReqEquipRefiningAutolvlUpMsg = {};

ReqEquipRefiningAutolvlUpMsg.msgId = 3404;
ReqEquipRefiningAutolvlUpMsg.msgType = "CS_EquipRefiningAutolvlUp";
ReqEquipRefiningAutolvlUpMsg.msgClassName = "ReqEquipRefiningAutolvlUpMsg";



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
MsgType.CS_ExitWuhunDungeon
]]
_G.ReqExitWuhunDungeonMsg = {};

ReqExitWuhunDungeonMsg.msgId = 3410;
ReqExitWuhunDungeonMsg.msgType = "CS_ExitWuhunDungeon";
ReqExitWuhunDungeonMsg.msgClassName = "ReqExitWuhunDungeonMsg";
ReqExitWuhunDungeonMsg.id = 0; -- 任务副本奖索引



ReqExitWuhunDungeonMsg.meta = {__index = ReqExitWuhunDungeonMsg };
function ReqExitWuhunDungeonMsg:new()
	local obj = setmetatable( {}, ReqExitWuhunDungeonMsg.meta);
	return obj;
end

function ReqExitWuhunDungeonMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqExitWuhunDungeonMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
客户端请求：灵阵进阶
MsgType.CS_LingzhenLevelUp
]]
_G.ReqLingzhenLevelUpMsg = {};

ReqLingzhenLevelUpMsg.msgId = 3414;
ReqLingzhenLevelUpMsg.msgType = "CS_LingzhenLevelUp";
ReqLingzhenLevelUpMsg.msgClassName = "ReqLingzhenLevelUpMsg";
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
MsgType.CS_SendExtremityEnterData
]]
_G.ReqExtremityEnterDataMsg = {};

ReqExtremityEnterDataMsg.msgId = 3416;
ReqExtremityEnterDataMsg.msgType = "CS_SendExtremityEnterData";
ReqExtremityEnterDataMsg.msgClassName = "ReqExtremityEnterDataMsg";
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
MsgType.CS_SendExtremityQuit
]]
_G.ReqExtremityQuitMsg = {};

ReqExtremityQuitMsg.msgId = 3420;
ReqExtremityQuitMsg.msgType = "CS_SendExtremityQuit";
ReqExtremityQuitMsg.msgClassName = "ReqExtremityQuitMsg";



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
MsgType.CS_LingShouMuDiInfo
]]
_G.ReqLingShouMuDiInfoMsg = {};

ReqLingShouMuDiInfoMsg.msgId = 3421;
ReqLingShouMuDiInfoMsg.msgType = "CS_LingShouMuDiInfo";
ReqLingShouMuDiInfoMsg.msgClassName = "ReqLingShouMuDiInfoMsg";



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
MsgType.CS_ChallLingShouMuDi
]]
_G.ReqChallLingShouMuDiMsg = {};

ReqChallLingShouMuDiMsg.msgId = 3422;
ReqChallLingShouMuDiMsg.msgType = "CS_ChallLingShouMuDi";
ReqChallLingShouMuDiMsg.msgClassName = "ReqChallLingShouMuDiMsg";
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
MsgType.CS_LSMDGetAward
]]
_G.ReqLSMDGetAwardMsg = {};

ReqLSMDGetAwardMsg.msgId = 3425;
ReqLSMDGetAwardMsg.msgType = "CS_LSMDGetAward";
ReqLSMDGetAwardMsg.msgClassName = "ReqLSMDGetAwardMsg";



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
MsgType.CS_LingShouMuDiRanklist
]]
_G.ReqLingShouMuDiRanklistMsg = {};

ReqLingShouMuDiRanklistMsg.msgId = 3426;
ReqLingShouMuDiRanklistMsg.msgType = "CS_LingShouMuDiRanklist";
ReqLingShouMuDiRanklistMsg.msgClassName = "ReqLingShouMuDiRanklistMsg";



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
MsgType.CS_ItemShortCut
]]
_G.ReqItemShortCutMsg = {};

ReqItemShortCutMsg.msgId = 3427;
ReqItemShortCutMsg.msgType = "CS_ItemShortCut";
ReqItemShortCutMsg.msgClassName = "ReqItemShortCutMsg";
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
MsgType.CS_ActiveLovelyPet
]]
_G.ReqActiveLovelyPetMsg = {};

ReqActiveLovelyPetMsg.msgId = 3429;
ReqActiveLovelyPetMsg.msgType = "CS_ActiveLovelyPet";
ReqActiveLovelyPetMsg.msgClassName = "ReqActiveLovelyPetMsg";
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
MsgType.CS_SendLovelyPet
]]
_G.ReqSendLovelyPetMsg = {};

ReqSendLovelyPetMsg.msgId = 3431;
ReqSendLovelyPetMsg.msgType = "CS_SendLovelyPet";
ReqSendLovelyPetMsg.msgClassName = "ReqSendLovelyPetMsg";
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
MsgType.CS_LingShouMuDiQuit
]]
_G.ReqLingShouMuDiQuitMsg = {};

ReqLingShouMuDiQuitMsg.msgId = 3432;
ReqLingShouMuDiQuitMsg.msgType = "CS_LingShouMuDiQuit";
ReqLingShouMuDiQuitMsg.msgClassName = "ReqLingShouMuDiQuitMsg";



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
MsgType.CS_RenewLovelyPet
]]
_G.ReqRenewLovelyPetMsg = {};

ReqRenewLovelyPetMsg.msgId = 3433;
ReqRenewLovelyPetMsg.msgType = "CS_RenewLovelyPet";
ReqRenewLovelyPetMsg.msgClassName = "ReqRenewLovelyPetMsg";
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
MsgType.CS_WaterDungeonInfo
]]
_G.ReqWaterDungeonInfoMsg = {};

ReqWaterDungeonInfoMsg.msgId = 3434;
ReqWaterDungeonInfoMsg.msgType = "CS_WaterDungeonInfo";
ReqWaterDungeonInfoMsg.msgClassName = "ReqWaterDungeonInfoMsg";



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
MsgType.CS_WaterDungeonRank
]]
_G.ReqWaterDungeonRankMsg = {};

ReqWaterDungeonRankMsg.msgId = 3435;
ReqWaterDungeonRankMsg.msgType = "CS_WaterDungeonRank";
ReqWaterDungeonRankMsg.msgClassName = "ReqWaterDungeonRankMsg";



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
MsgType.CS_BuyWishItem
]]
_G.ReqBuyWishItemMsg = {};

ReqBuyWishItemMsg.msgId = 3438;
ReqBuyWishItemMsg.msgType = "CS_BuyWishItem";
ReqBuyWishItemMsg.msgClassName = "ReqBuyWishItemMsg";
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
MsgType.CS_WaterDungeonEnter
]]
_G.ReqWaterDungeonEnterMsg = {};

ReqWaterDungeonEnterMsg.msgId = 3439;
ReqWaterDungeonEnterMsg.msgType = "CS_WaterDungeonEnter";
ReqWaterDungeonEnterMsg.msgClassName = "ReqWaterDungeonEnterMsg";



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
MsgType.CS_WaterDungeonExit
]]
_G.ReqWaterDungeonExitMsg = {};

ReqWaterDungeonExitMsg.msgId = 3440;
ReqWaterDungeonExitMsg.msgType = "CS_WaterDungeonExit";
ReqWaterDungeonExitMsg.msgClassName = "ReqWaterDungeonExitMsg";



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
MsgType.CS_MagicWeaponChangeModel
]]
_G.ReqMagicWeaponChangeModelMsg = {};

ReqMagicWeaponChangeModelMsg.msgId = 3456;
ReqMagicWeaponChangeModelMsg.msgType = "CS_MagicWeaponChangeModel";
ReqMagicWeaponChangeModelMsg.msgClassName = "ReqMagicWeaponChangeModelMsg";
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
MsgType.CS_VipRenew
]]
_G.ReqVipRenewMsg = {};

ReqVipRenewMsg.msgId = 3461;
ReqVipRenewMsg.msgType = "CS_VipRenew";
ReqVipRenewMsg.msgClassName = "ReqVipRenewMsg";
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
MsgType.CS_VipLevelRewardAccept
]]
_G.ReqVipLevelRewardAcceptMsg = {};

ReqVipLevelRewardAcceptMsg.msgId = 3462;
ReqVipLevelRewardAcceptMsg.msgType = "CS_VipLevelRewardAccept";
ReqVipLevelRewardAcceptMsg.msgClassName = "ReqVipLevelRewardAcceptMsg";
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
MsgType.CS_VipWeekRewardAccept
]]
_G.ReqVipWeekRewardAcceptMsg = {};

ReqVipWeekRewardAcceptMsg.msgId = 3463;
ReqVipWeekRewardAcceptMsg.msgType = "CS_VipWeekRewardAccept";
ReqVipWeekRewardAcceptMsg.msgClassName = "ReqVipWeekRewardAcceptMsg";



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
MsgType.CS_WingHeCheng
]]
_G.ReqWingHeChengMsg = {};

ReqWingHeChengMsg.msgId = 3464;
ReqWingHeChengMsg.msgType = "CS_WingHeCheng";
ReqWingHeChengMsg.msgClassName = "ReqWingHeChengMsg";
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
MsgType.CS_EquipGroup
]]
_G.ReqEquipGroupMsg = {};

ReqEquipGroupMsg.msgId = 3465;
ReqEquipGroupMsg.msgType = "CS_EquipGroup";
ReqEquipGroupMsg.msgClassName = "ReqEquipGroupMsg";
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
MsgType.CS_RandomQuestComplete
]]
_G.ReqRandomQuestCompleteMsg = {};

ReqRandomQuestCompleteMsg.msgId = 3468;
ReqRandomQuestCompleteMsg.msgType = "CS_RandomQuestComplete";
ReqRandomQuestCompleteMsg.msgClassName = "ReqRandomQuestCompleteMsg";
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
MsgType.CS_RandomDungeonExit
]]
_G.ReqRandomDungeonExitMsg = {};

ReqRandomDungeonExitMsg.msgId = 3470;
ReqRandomDungeonExitMsg.msgType = "CS_RandomDungeonExit";
ReqRandomDungeonExitMsg.msgClassName = "ReqRandomDungeonExitMsg";



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
MsgType.CS_RandomDungeonStep
]]
_G.ReqRandomDungeonStepMsg = {};

ReqRandomDungeonStepMsg.msgId = 3471;
ReqRandomDungeonStepMsg.msgType = "CS_RandomDungeonStep";
ReqRandomDungeonStepMsg.msgClassName = "ReqRandomDungeonStepMsg";
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
MsgType.CS_RandomDungeonStepContentSubmit
]]
_G.ReqRandomDungeonStepSubmitMsg = {};

ReqRandomDungeonStepSubmitMsg.msgId = 3473;
ReqRandomDungeonStepSubmitMsg.msgType = "CS_RandomDungeonStepContentSubmit";
ReqRandomDungeonStepSubmitMsg.msgClassName = "ReqRandomDungeonStepSubmitMsg";
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
MsgType.CS_RandomQuestReward
]]
_G.ReqRandomQuestRewardMsg = {};

ReqRandomQuestRewardMsg.msgId = 3474;
ReqRandomQuestRewardMsg.msgType = "CS_RandomQuestReward";
ReqRandomQuestRewardMsg.msgClassName = "ReqRandomQuestRewardMsg";
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
MsgType.CS_FindTreasure
]]
_G.ReqFindTreasureMsg = {};

ReqFindTreasureMsg.msgId = 3476;
ReqFindTreasureMsg.msgType = "CS_FindTreasure";
ReqFindTreasureMsg.msgClassName = "ReqFindTreasureMsg";
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
MsgType.CS_FindTreasureCancel
]]
_G.ReqFindTreasureCancelMsg = {};

ReqFindTreasureCancelMsg.msgId = 3477;
ReqFindTreasureCancelMsg.msgType = "CS_FindTreasureCancel";
ReqFindTreasureCancelMsg.msgClassName = "ReqFindTreasureCancelMsg";



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
MsgType.CS_FindTreasureCollect
]]
_G.ReqFindTreasureCollectMsg = {};

ReqFindTreasureCollectMsg.msgId = 3478;
ReqFindTreasureCollectMsg.msgType = "CS_FindTreasureCollect";
ReqFindTreasureCollectMsg.msgClassName = "ReqFindTreasureCollectMsg";
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
MsgType.CS_WuHunBattle
]]
_G.ReqWuHunBattleMsg = {};

ReqWuHunBattleMsg.msgId = 3480;
ReqWuHunBattleMsg.msgType = "CS_WuHunBattle";
ReqWuHunBattleMsg.msgClassName = "ReqWuHunBattleMsg";
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
MsgType.CS_ZhuoyueGuideReward
]]
_G.ReqZhuoyueGuideRewardMsg = {};

ReqZhuoyueGuideRewardMsg.msgId = 3482;
ReqZhuoyueGuideRewardMsg.msgType = "CS_ZhuoyueGuideReward";
ReqZhuoyueGuideRewardMsg.msgClassName = "ReqZhuoyueGuideRewardMsg";
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
MsgType.CS_HangState
]]
_G.ReqHangStateMsg = {};

ReqHangStateMsg.msgId = 3483;
ReqHangStateMsg.msgType = "CS_HangState";
ReqHangStateMsg.msgClassName = "ReqHangStateMsg";
ReqHangStateMsg.hangState = 0; -- 1开启0关闭2分解



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
MsgType.CS_WeedSign
]]
_G.ReqWeedSignMsg = {};

ReqWeedSignMsg.msgId = 3484;
ReqWeedSignMsg.msgType = "CS_WeedSign";
ReqWeedSignMsg.msgClassName = "ReqWeedSignMsg";
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
MsgType.CS_UnionBossActivitySureEnter
]]
_G.ReqUnionBossActivitySureEnterMsg = {};

ReqUnionBossActivitySureEnterMsg.msgId = 3491;
ReqUnionBossActivitySureEnterMsg.msgType = "CS_UnionBossActivitySureEnter";
ReqUnionBossActivitySureEnterMsg.msgClassName = "ReqUnionBossActivitySureEnterMsg";



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
MsgType.CS_UnionBossActivityOut
]]
_G.ReqUnionBossActivityOutMsg = {};

ReqUnionBossActivityOutMsg.msgId = 3492;
ReqUnionBossActivityOutMsg.msgType = "CS_UnionBossActivityOut";
ReqUnionBossActivityOutMsg.msgClassName = "ReqUnionBossActivityOutMsg";



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
MsgType.CR_ConCrossFight
]]
_G.ReqConCrossFightMsg = {};

ReqConCrossFightMsg.msgId = 4001;
ReqConCrossFightMsg.msgType = "CR_ConCrossFight";
ReqConCrossFightMsg.msgClassName = "ReqConCrossFightMsg";
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
MsgType.CS_WaterDungeonReward
]]
_G.ReqWaterDungeonRewardMsg = {};

ReqWaterDungeonRewardMsg.msgId = 3500;
ReqWaterDungeonRewardMsg.msgType = "CS_WaterDungeonReward";
ReqWaterDungeonRewardMsg.msgClassName = "ReqWaterDungeonRewardMsg";
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
MsgType.CS_VipBackInfo
]]
_G.ReqVipBackInfoMsg = {};

ReqVipBackInfoMsg.msgId = 3502;
ReqVipBackInfoMsg.msgType = "CS_VipBackInfo";
ReqVipBackInfoMsg.msgClassName = "ReqVipBackInfoMsg";
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
MsgType.CS_GetVipBack
]]
_G.ReqGetVipBackMsg = {};

ReqGetVipBackMsg.msgId = 3503;
ReqGetVipBackMsg.msgType = "CS_GetVipBack";
ReqGetVipBackMsg.msgClassName = "ReqGetVipBackMsg";
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
MsgType.CR_EnterCrossFight
]]
_G.ReqEnterCrossFightMsg = {};

ReqEnterCrossFightMsg.msgId = 4002;
ReqEnterCrossFightMsg.msgType = "CR_EnterCrossFight";
ReqEnterCrossFightMsg.msgClassName = "ReqEnterCrossFightMsg";



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
MsgType.CS_ActivityOnlineTime
]]
_G.ReqActivityOnlineTimeMsg = {};

ReqActivityOnlineTimeMsg.msgId = 3505;
ReqActivityOnlineTimeMsg.msgType = "CS_ActivityOnlineTime";
ReqActivityOnlineTimeMsg.msgClassName = "ReqActivityOnlineTimeMsg";
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
MsgType.CS_QuitCrossFightPvp1
]]
_G.ReqQuitCrossFightPvpMsg = {};

ReqQuitCrossFightPvpMsg.msgId = 3508;
ReqQuitCrossFightPvpMsg.msgType = "CS_QuitCrossFightPvp1";
ReqQuitCrossFightPvpMsg.msgClassName = "ReqQuitCrossFightPvpMsg";



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
MsgType.CS_SendQihooQuick
]]
_G.ReqQihooQuickMsg = {};

ReqQihooQuickMsg.msgId = 3510;
ReqQihooQuickMsg.msgType = "CS_SendQihooQuick";
ReqQihooQuickMsg.msgClassName = "ReqQihooQuickMsg";



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
MsgType.CS_PrerogativeReward
]]
_G.ReqPrerogativeRewardMsg = {};

ReqPrerogativeRewardMsg.msgId = 3512;
ReqPrerogativeRewardMsg.msgType = "CS_PrerogativeReward";
ReqPrerogativeRewardMsg.msgClassName = "ReqPrerogativeRewardMsg";
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
MsgType.CS_EquipSmelt
]]
_G.ReqEquipSmeltMsg = {};

ReqEquipSmeltMsg.msgId = 3514;
ReqEquipSmeltMsg.msgType = "CS_EquipSmelt";
ReqEquipSmeltMsg.msgClassName = "ReqEquipSmeltMsg";
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
客户端请求：冰魂换模型
MsgType.CS_BingHunChangeModel
]]
_G.ReqBingHunChangeModelMsg = {};

ReqBingHunChangeModelMsg.msgId = 3521;
ReqBingHunChangeModelMsg.msgType = "CS_BingHunChangeModel";
ReqBingHunChangeModelMsg.msgClassName = "ReqBingHunChangeModelMsg";
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
MsgType.CS_FengYaoRefreshState
]]
_G.ReqFengYaoRefreshStateMsg = {};

ReqFengYaoRefreshStateMsg.msgId = 3522;
ReqFengYaoRefreshStateMsg.msgType = "CS_FengYaoRefreshState";
ReqFengYaoRefreshStateMsg.msgClassName = "ReqFengYaoRefreshStateMsg";



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
MsgType.CS_WaterDungeonMoreReward
]]
_G.ReqWaterDungeonLossRewardMsg = {};

ReqWaterDungeonLossRewardMsg.msgId = 3523;
ReqWaterDungeonLossRewardMsg.msgType = "CS_WaterDungeonMoreReward";
ReqWaterDungeonLossRewardMsg.msgClassName = "ReqWaterDungeonLossRewardMsg";
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
MsgType.CS_GiveBuyGift
]]
_G.ReqGiveBuyGiftMsg = {};

ReqGiveBuyGiftMsg.msgId = 3529;
ReqGiveBuyGiftMsg.msgType = "CS_GiveBuyGift";
ReqGiveBuyGiftMsg.msgClassName = "ReqGiveBuyGiftMsg";
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
MsgType.CS_WorldNotice
]]
_G.ReqWorldNoticeMsg = {};

ReqWorldNoticeMsg.msgId = 3530;
ReqWorldNoticeMsg.msgType = "CS_WorldNotice";
ReqWorldNoticeMsg.msgClassName = "ReqWorldNoticeMsg";
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
MsgType.CS_SendRedPacket
]]
_G.ReqSendRedPacketMsg = {};

ReqSendRedPacketMsg.msgId = 3531;
ReqSendRedPacketMsg.msgType = "CS_SendRedPacket";
ReqSendRedPacketMsg.msgClassName = "ReqSendRedPacketMsg";
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
MsgType.CS_GetPartyList
]]
_G.ReqPartyListMsg = {};

ReqPartyListMsg.msgId = 3534;
ReqPartyListMsg.msgType = "CS_GetPartyList";
ReqPartyListMsg.msgClassName = "ReqPartyListMsg";
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
MsgType.CS_GetPartyStatList
]]
_G.ReqPartyStatListMsg = {};

ReqPartyStatListMsg.msgId = 3535;
ReqPartyStatListMsg.msgType = "CS_GetPartyStatList";
ReqPartyStatListMsg.msgClassName = "ReqPartyStatListMsg";
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
MsgType.CS_GetPartyAward
]]
_G.ReqGetPartyAwardMsg = {};

ReqGetPartyAwardMsg.msgId = 3536;
ReqGetPartyAwardMsg.msgType = "CS_GetPartyAward";
ReqGetPartyAwardMsg.msgClassName = "ReqGetPartyAwardMsg";
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
MsgType.CS_PartyPowerRank
]]
_G.ReqPartyRankMsg = {};

ReqPartyRankMsg.msgId = 3540;
ReqPartyRankMsg.msgType = "CS_PartyPowerRank";
ReqPartyRankMsg.msgClassName = "ReqPartyRankMsg";
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
MsgType.CS_PartyGroupPurchase
]]
_G.ReqPartyGroupPurchaseMsg = {};

ReqPartyGroupPurchaseMsg.msgId = 3541;
ReqPartyGroupPurchaseMsg.msgType = "CS_PartyGroupPurchase";
ReqPartyGroupPurchaseMsg.msgClassName = "ReqPartyGroupPurchaseMsg";
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
MsgType.CS_LSHorseLvlUp
]]
_G.ReqLSHorseLvlUpMsg = {};

ReqLSHorseLvlUpMsg.msgId = 3544;
ReqLSHorseLvlUpMsg.msgType = "CS_LSHorseLvlUp";
ReqLSHorseLvlUpMsg.msgClassName = "ReqLSHorseLvlUpMsg";
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
MsgType.CS_PartyInfo
]]
_G.ReqPartyInfoMsg = {};

ReqPartyInfoMsg.msgId = 3548;
ReqPartyInfoMsg.msgType = "CS_PartyInfo";
ReqPartyInfoMsg.msgClassName = "ReqPartyInfoMsg";
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
MsgType.CS_OpenItemCard
]]
_G.ReqOpenItemCardMsg = {};

ReqOpenItemCardMsg.msgId = 3549;
ReqOpenItemCardMsg.msgType = "CS_OpenItemCard";
ReqOpenItemCardMsg.msgClassName = "ReqOpenItemCardMsg";
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
客户端请求运营活动领奖
MsgType.CS_GetYunYingReward
]]
_G.ReqYunYingRewardMsg = {};

ReqYunYingRewardMsg.msgId = 3557;
ReqYunYingRewardMsg.msgType = "CS_GetYunYingReward";
ReqYunYingRewardMsg.msgClassName = "ReqYunYingRewardMsg";
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
MsgType.CS_PartyGroupCharge
]]
_G.ReqPartyGroupChargeMsg = {};

ReqPartyGroupChargeMsg.msgId = 3559;
ReqPartyGroupChargeMsg.msgType = "CS_PartyGroupCharge";
ReqPartyGroupChargeMsg.msgClassName = "ReqPartyGroupChargeMsg";
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
MsgType.CS_EnterPersonalBoss
]]
_G.ReqEnterPersonalBossMsg = {};

ReqEnterPersonalBossMsg.msgId = 3561;
ReqEnterPersonalBossMsg.msgType = "CS_EnterPersonalBoss";
ReqEnterPersonalBossMsg.msgClassName = "ReqEnterPersonalBossMsg";
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
MsgType.CS_QuitPersonalBoss
]]
_G.ReqQuitPersonalBossMsg = {};

ReqQuitPersonalBossMsg.msgId = 3562;
ReqQuitPersonalBossMsg.msgType = "CS_QuitPersonalBoss";
ReqQuitPersonalBossMsg.msgClassName = "ReqQuitPersonalBossMsg";



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
MsgType.CS_BabelSweeps
]]
_G.ReqBabelSweepsMsg = {};

ReqBabelSweepsMsg.msgId = 3567;
ReqBabelSweepsMsg.msgType = "CS_BabelSweeps";
ReqBabelSweepsMsg.msgClassName = "ReqBabelSweepsMsg";
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
MsgType.CS_PersonalBossLoading
]]
_G.ReqPersonalBossLoadingMsg = {};

ReqPersonalBossLoadingMsg.msgId = 3568;
ReqPersonalBossLoadingMsg.msgType = "CS_PersonalBossLoading";
ReqPersonalBossLoadingMsg.msgClassName = "ReqPersonalBossLoadingMsg";
ReqPersonalBossLoadingMsg.id = 0; -- bossID



ReqPersonalBossLoadingMsg.meta = {__index = ReqPersonalBossLoadingMsg };
function ReqPersonalBossLoadingMsg:new()
	local obj = setmetatable( {}, ReqPersonalBossLoadingMsg.meta);
	return obj;
end

function ReqPersonalBossLoadingMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqPersonalBossLoadingMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
客户端请求：骑战进阶
MsgType.CS_QiZhanLevelUp
]]
_G.ReqQiZhanLevelUpMsg = {};

ReqQiZhanLevelUpMsg.msgId = 3570;
ReqQiZhanLevelUpMsg.msgType = "CS_QiZhanLevelUp";
ReqQiZhanLevelUpMsg.msgClassName = "ReqQiZhanLevelUpMsg";
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
MsgType.CS_ShunwangTerrace
]]
_G.ReqShunwangTerraceMsg = {};

ReqShunwangTerraceMsg.msgId = 3571;
ReqShunwangTerraceMsg.msgType = "CS_ShunwangTerrace";
ReqShunwangTerraceMsg.msgClassName = "ReqShunwangTerraceMsg";
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
MsgType.CS_ExchangeShop
]]
_G.ReqExchangeShopMsg = {};

ReqExchangeShopMsg.msgId = 3572;
ReqExchangeShopMsg.msgType = "CS_ExchangeShop";
ReqExchangeShopMsg.msgClassName = "ReqExchangeShopMsg";
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
MsgType.CS_ActiveQiZhan
]]
_G.ReqActiveQiZhanMsg = {};

ReqActiveQiZhanMsg.msgId = 3574;
ReqActiveQiZhanMsg.msgType = "CS_ActiveQiZhan";
ReqActiveQiZhanMsg.msgClassName = "ReqActiveQiZhanMsg";
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
MsgType.CS_QiZhanDungeonDate
]]
_G.ReqQiZhanDungeonDateMsg = {};

ReqQiZhanDungeonDateMsg.msgId = 3575;
ReqQiZhanDungeonDateMsg.msgType = "CS_QiZhanDungeonDate";
ReqQiZhanDungeonDateMsg.msgClassName = "ReqQiZhanDungeonDateMsg";



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
MsgType.CS_QiZhanDungeonEnter
]]
_G.ReqQiZhanDungeonEnterMsg = {};

ReqQiZhanDungeonEnterMsg.msgId = 3576;
ReqQiZhanDungeonEnterMsg.msgType = "CS_QiZhanDungeonEnter";
ReqQiZhanDungeonEnterMsg.msgClassName = "ReqQiZhanDungeonEnterMsg";



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
MsgType.CS_QiZhanDungeonQuit
]]
_G.ReqQiZhanDungeonQuitMsg = {};

ReqQiZhanDungeonQuitMsg.msgId = 3579;
ReqQiZhanDungeonQuitMsg.msgType = "CS_QiZhanDungeonQuit";
ReqQiZhanDungeonQuitMsg.msgClassName = "ReqQiZhanDungeonQuitMsg";



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
MsgType.CS_QiZhanDungeonTeamState
]]
_G.ReqQiZhanDungeonTeamStateMsg = {};

ReqQiZhanDungeonTeamStateMsg.msgId = 3581;
ReqQiZhanDungeonTeamStateMsg.msgType = "CS_QiZhanDungeonTeamState";
ReqQiZhanDungeonTeamStateMsg.msgClassName = "ReqQiZhanDungeonTeamStateMsg";
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
MsgType.CS_ChangeQiZhan
]]
_G.ReqChangeQiZhanMsg = {};

ReqChangeQiZhanMsg.msgId = 3582;
ReqChangeQiZhanMsg.msgType = "CS_ChangeQiZhan";
ReqChangeQiZhanMsg.msgClassName = "ReqChangeQiZhanMsg";
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
MsgType.CS_BossMedalLevelUp
]]
_G.ReqBossMedalLevelUpMsg = {};

ReqBossMedalLevelUpMsg.msgId = 3585;
ReqBossMedalLevelUpMsg.msgType = "CS_BossMedalLevelUp";
ReqBossMedalLevelUpMsg.msgClassName = "ReqBossMedalLevelUpMsg";



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
MsgType.CS_EnterGuildDiGong
]]
_G.ReqEnterGuildDiGongMsg = {};

ReqEnterGuildDiGongMsg.msgId = 3591;
ReqEnterGuildDiGongMsg.msgType = "CS_EnterGuildDiGong";
ReqEnterGuildDiGongMsg.msgClassName = "ReqEnterGuildDiGongMsg";
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
MsgType.CS_QuitGuildDiGong
]]
_G.ReqQuitGuildDiGongMsg = {};

ReqQuitGuildDiGongMsg.msgId = 3594;
ReqQuitGuildDiGongMsg.msgType = "CS_QuitGuildDiGong";
ReqQuitGuildDiGongMsg.msgClassName = "ReqQuitGuildDiGongMsg";
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
MsgType.CS_UnionDiGongPickFlag
]]
_G.ReqUnionDiGongPickFlagMsg = {};

ReqUnionDiGongPickFlagMsg.msgId = 3597;
ReqUnionDiGongPickFlagMsg.msgType = "CS_UnionDiGongPickFlag";
ReqUnionDiGongPickFlagMsg.msgClassName = "ReqUnionDiGongPickFlagMsg";



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
MsgType.CS_EquipNewSuperNewVal
]]
_G.ReqEquipNewSuperNewValMsg = {};

ReqEquipNewSuperNewValMsg.msgId = 3603;
ReqEquipNewSuperNewValMsg.msgType = "CS_EquipNewSuperNewVal";
ReqEquipNewSuperNewValMsg.msgClassName = "ReqEquipNewSuperNewValMsg";
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
MsgType.CS_EquipNewSuperNewValSet
]]
_G.ReqEquipNewSuperNewValSetMsg = {};

ReqEquipNewSuperNewValSetMsg.msgId = 3604;
ReqEquipNewSuperNewValSetMsg.msgType = "CS_EquipNewSuperNewValSet";
ReqEquipNewSuperNewValSetMsg.msgClassName = "ReqEquipNewSuperNewValSetMsg";
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
MsgType.CS_CrossBossRankInfo
]]
_G.ReqCrossBossRankInfoMsg = {};

ReqCrossBossRankInfoMsg.msgId = 3607;
ReqCrossBossRankInfoMsg.msgType = "CS_CrossBossRankInfo";
ReqCrossBossRankInfoMsg.msgClassName = "ReqCrossBossRankInfoMsg";
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
MsgType.CS_QuitCrossBoss
]]
_G.ReqQuitCrossBossMsg = {};

ReqQuitCrossBossMsg.msgId = 3610;
ReqQuitCrossBossMsg.msgType = "CS_QuitCrossBoss";
ReqQuitCrossBossMsg.msgClassName = "ReqQuitCrossBossMsg";



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
MsgType.CS_ShiHunMedalLevelUp
]]
_G.ReqShiHunMedalLevelUpMsg = {};

ReqShiHunMedalLevelUpMsg.msgId = 3611;
ReqShiHunMedalLevelUpMsg.msgType = "CS_ShiHunMedalLevelUp";
ReqShiHunMedalLevelUpMsg.msgClassName = "ReqShiHunMedalLevelUpMsg";



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
MsgType.CS_SougouDownHall
]]
_G.ReqSougouDownHallMsg = {};

ReqSougouDownHallMsg.msgId = 3614;
ReqSougouDownHallMsg.msgType = "CS_SougouDownHall";
ReqSougouDownHallMsg.msgClassName = "ReqSougouDownHallMsg";
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
MsgType.CS_JewelleryBreak
]]
_G.ReqJewelleryBreakMsg = {};

ReqJewelleryBreakMsg.msgId = 3616;
ReqJewelleryBreakMsg.msgType = "CS_JewelleryBreak";
ReqJewelleryBreakMsg.msgClassName = "ReqJewelleryBreakMsg";
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
MsgType.CS_UseCrossHp
]]
_G.ReqUseCrossHpMsg = {};

ReqUseCrossHpMsg.msgId = 3618;
ReqUseCrossHpMsg.msgType = "CS_UseCrossHp";
ReqUseCrossHpMsg.msgClassName = "ReqUseCrossHpMsg";



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
MsgType.CS_SendWingStren
]]
_G.ReqSendWingStrenMsg = {};

ReqSendWingStrenMsg.msgId = 3620;
ReqSendWingStrenMsg.msgType = "CS_SendWingStren";
ReqSendWingStrenMsg.msgClassName = "ReqSendWingStrenMsg";



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
MsgType.CS_CrossChat
]]
_G.ReqCrossChatMsg = {};

ReqCrossChatMsg.msgId = 3621;
ReqCrossChatMsg.msgType = "CS_CrossChat";
ReqCrossChatMsg.msgClassName = "ReqCrossChatMsg";
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
MsgType.CS_ShenLingLevelUp
]]
_G.ReqShenLingLevelUpMsg = {};

ReqShenLingLevelUpMsg.msgId = 3623;
ReqShenLingLevelUpMsg.msgType = "CS_ShenLingLevelUp";
ReqShenLingLevelUpMsg.msgClassName = "ReqShenLingLevelUpMsg";
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
MsgType.CS_ActiveShenLing
]]
_G.ReqActiveShenLingMsg = {};

ReqActiveShenLingMsg.msgId = 3624;
ReqActiveShenLingMsg.msgType = "CS_ActiveShenLing";
ReqActiveShenLingMsg.msgClassName = "ReqActiveShenLingMsg";



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
MsgType.CS_ChangeShenLing
]]
_G.ReqChangeShenLingMsg = {};

ReqChangeShenLingMsg.msgId = 3625;
ReqChangeShenLingMsg.msgType = "CS_ChangeShenLing";
ReqChangeShenLingMsg.msgClassName = "ReqChangeShenLingMsg";
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
MsgType.CS_CrossPreArenaRank
]]
_G.ReqCrossPreArenaRankMsg = {};

ReqCrossPreArenaRankMsg.msgId = 3629;
ReqCrossPreArenaRankMsg.msgType = "CS_CrossPreArenaRank";
ReqCrossPreArenaRankMsg.msgClassName = "ReqCrossPreArenaRankMsg";



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
MsgType.CS_CrossPreArenaQuit
]]
_G.ReqCrossPreArenaQuitMsg = {};

ReqCrossPreArenaQuitMsg.msgId = 3630;
ReqCrossPreArenaQuitMsg.msgType = "CS_CrossPreArenaQuit";
ReqCrossPreArenaQuitMsg.msgClassName = "ReqCrossPreArenaQuitMsg";



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
MsgType.CS_CrossArenaQuit
]]
_G.ReqCrossArenaQuitMsg = {};

ReqCrossArenaQuitMsg.msgId = 3632;
ReqCrossArenaQuitMsg.msgType = "CS_CrossArenaQuit";
ReqCrossArenaQuitMsg.msgClassName = "ReqCrossArenaQuitMsg";



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
MsgType.CS_MarryType
]]
_G.ReqMarryTypeMsg = {};

ReqMarryTypeMsg.msgId = 3633;
ReqMarryTypeMsg.msgType = "CS_MarryType";
ReqMarryTypeMsg.msgClassName = "ReqMarryTypeMsg";
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
MsgType.CS_MarryTravel
]]
_G.ReqMarryTravelMsg = {};

ReqMarryTravelMsg.msgId = 3635;
ReqMarryTravelMsg.msgType = "CS_MarryTravel";
ReqMarryTravelMsg.msgClassName = "ReqMarryTravelMsg";



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
MsgType.CS_EnterMarryChurch
]]
_G.ReqEnterMarryChurchMsg = {};

ReqEnterMarryChurchMsg.msgId = 3636;
ReqEnterMarryChurchMsg.msgType = "CS_EnterMarryChurch";
ReqEnterMarryChurchMsg.msgClassName = "ReqEnterMarryChurchMsg";



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
MsgType.CS_OutMarryCopy
]]
_G.ReqOutMarryCopyMsg = {};

ReqOutMarryCopyMsg.msgId = 3637;
ReqOutMarryCopyMsg.msgType = "CS_OutMarryCopy";
ReqOutMarryCopyMsg.msgClassName = "ReqOutMarryCopyMsg";



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
MsgType.CS_Marry
]]
_G.ReqMarryMsg = {};

ReqMarryMsg.msgId = 3638;
ReqMarryMsg.msgType = "CS_Marry";
ReqMarryMsg.msgClassName = "ReqMarryMsg";
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
MsgType.CS_MarryCardUseMyData
]]
_G.ReqMarryCardUseMyDataMsg = {};

ReqMarryCardUseMyDataMsg.msgId = 3640;
ReqMarryCardUseMyDataMsg.msgType = "CS_MarryCardUseMyData";
ReqMarryCardUseMyDataMsg.msgClassName = "ReqMarryCardUseMyDataMsg";



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
MsgType.CS_MarryCardUse
]]
_G.ReqMarryCardUseMsg = {};

ReqMarryCardUseMsg.msgId = 3641;
ReqMarryCardUseMsg.msgType = "CS_MarryCardUse";
ReqMarryCardUseMsg.msgClassName = "ReqMarryCardUseMsg";
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
MsgType.CS_MarryMainPanelInfo
]]
_G.ReqMarryMainPanelInfoMsg = {};

ReqMarryMainPanelInfoMsg.msgId = 3643;
ReqMarryMainPanelInfoMsg.msgType = "CS_MarryMainPanelInfo";
ReqMarryMainPanelInfoMsg.msgClassName = "ReqMarryMainPanelInfoMsg";



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
MsgType.CS_BuildAttrScroll
]]
_G.ReqBuildAttrScrollMsg = {};

ReqBuildAttrScrollMsg.msgId = 3645;
ReqBuildAttrScrollMsg.msgType = "CS_BuildAttrScroll";
ReqBuildAttrScrollMsg.msgClassName = "ReqBuildAttrScrollMsg";
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
MsgType.CS_Divorce
]]
_G.ReqDivorceMsg = {};

ReqDivorceMsg.msgId = 3646;
ReqDivorceMsg.msgType = "CS_Divorce";
ReqDivorceMsg.msgClassName = "ReqDivorceMsg";
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
MsgType.CS_MarryOpen
]]
_G.ReqMarryOpenMsg = {};

ReqMarryOpenMsg.msgId = 3647;
ReqMarryOpenMsg.msgType = "CS_MarryOpen";
ReqMarryOpenMsg.msgClassName = "ReqMarryOpenMsg";



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
MsgType.CS_EnterMarryChurchOK
]]
_G.ReqEnterMarryChurchOKMsg = {};

ReqEnterMarryChurchOKMsg.msgId = 3648;
ReqEnterMarryChurchOKMsg.msgType = "CS_EnterMarryChurchOK";
ReqEnterMarryChurchOKMsg.msgClassName = "ReqEnterMarryChurchOKMsg";



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
MsgType.CS_MarryRingChang
]]
_G.ReqMarryRingChangMsg = {};

ReqMarryRingChangMsg.msgId = 3649;
ReqMarryRingChangMsg.msgType = "CS_MarryRingChang";
ReqMarryRingChangMsg.msgClassName = "ReqMarryRingChangMsg";
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
MsgType.CS_BingLingLevelUp
]]
_G.ReqBingLingLevelUpMsg = {};

ReqBingLingLevelUpMsg.msgId = 3652;
ReqBingLingLevelUpMsg.msgType = "CS_BingLingLevelUp";
ReqBingLingLevelUpMsg.msgClassName = "ReqBingLingLevelUpMsg";
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
MsgType.CS_ShenWuStarUp
]]
_G.ReqShenWuStarUpMsg = {};

ReqShenWuStarUpMsg.msgId = 3654;
ReqShenWuStarUpMsg.msgType = "CS_ShenWuStarUp";
ReqShenWuStarUpMsg.msgClassName = "ReqShenWuStarUpMsg";



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
MsgType.CS_ShenWuLevelUp
]]
_G.ReqShenWuLevelUpMsg = {};

ReqShenWuLevelUpMsg.msgId = 3655;
ReqShenWuLevelUpMsg.msgType = "CS_ShenWuLevelUp";
ReqShenWuLevelUpMsg.msgClassName = "ReqShenWuLevelUpMsg";



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
MsgType.CS_GiveRedPacket
]]
_G.ReqGiveRedPacketMsg = {};

ReqGiveRedPacketMsg.msgId = 3656;
ReqGiveRedPacketMsg.msgType = "CS_GiveRedPacket";
ReqGiveRedPacketMsg.msgClassName = "ReqGiveRedPacketMsg";
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
MsgType.CS_SendMarryBox
]]
_G.ReqSendMarryBoxMsg = {};

ReqSendMarryBoxMsg.msgId = 3658;
ReqSendMarryBoxMsg.msgType = "CS_SendMarryBox";
ReqSendMarryBoxMsg.msgClassName = "ReqSendMarryBoxMsg";



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
MsgType.CS_YuanLingLevelUp
]]
_G.ReqYuanLingLevelUpMsg = {};

ReqYuanLingLevelUpMsg.msgId = 3660;
ReqYuanLingLevelUpMsg.msgType = "CS_YuanLingLevelUp";
ReqYuanLingLevelUpMsg.msgClassName = "ReqYuanLingLevelUpMsg";
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
MsgType.CS_ActiveYuanLing
]]
_G.ReqActiveYuanLingMsg = {};

ReqActiveYuanLingMsg.msgId = 3661;
ReqActiveYuanLingMsg.msgType = "CS_ActiveYuanLing";
ReqActiveYuanLingMsg.msgClassName = "ReqActiveYuanLingMsg";



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
MsgType.CS_ChangeYuanLing
]]
_G.ReqChangeYuanLingMsg = {};

ReqChangeYuanLingMsg.msgId = 3662;
ReqChangeYuanLingMsg.msgType = "CS_ChangeYuanLing";
ReqChangeYuanLingMsg.msgClassName = "ReqChangeYuanLingMsg";
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
MsgType.CS_DivorceXieYi
]]
_G.ReqDivorceXieYiMsg = {};

ReqDivorceXieYiMsg.msgId = 3663;
ReqDivorceXieYiMsg.msgType = "CS_DivorceXieYi";
ReqDivorceXieYiMsg.msgClassName = "ReqDivorceXieYiMsg";
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
MsgType.CS_StrenthenChong
]]
_G.ReqStrenthenChongMsg = {};

ReqStrenthenChongMsg.msgId = 3664;
ReqStrenthenChongMsg.msgType = "CS_StrenthenChong";
ReqStrenthenChongMsg.msgClassName = "ReqStrenthenChongMsg";
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
MsgType.CS_StrenthenBreak
]]
_G.ReqStrenthenBreakMsg = {};

ReqStrenthenBreakMsg.msgId = 3665;
ReqStrenthenBreakMsg.msgType = "CS_StrenthenBreak";
ReqStrenthenBreakMsg.msgClassName = "ReqStrenthenBreakMsg";
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
MsgType.CS_ChangeRealmModel
]]
_G.ReqChangeRealmModelMsg = {};

ReqChangeRealmModelMsg.msgId = 3666;
ReqChangeRealmModelMsg.msgType = "CS_ChangeRealmModel";
ReqChangeRealmModelMsg.msgClassName = "ReqChangeRealmModelMsg";
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
MsgType.CS_SendHallows
]]
_G.ReqSendHallowsMsg = {};

ReqSendHallowsMsg.msgId = 3667;
ReqSendHallowsMsg.msgType = "CS_SendHallows";
ReqSendHallowsMsg.msgClassName = "ReqSendHallowsMsg";



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
MsgType.CS_InlayHallows
]]
_G.ReqInlayHallowsMsg = {};

ReqInlayHallowsMsg.msgId = 3668;
ReqInlayHallowsMsg.msgType = "CS_InlayHallows";
ReqInlayHallowsMsg.msgClassName = "ReqInlayHallowsMsg";
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
MsgType.CS_PeelHallows
]]
_G.ReqPeelHallowsMsg = {};

ReqPeelHallowsMsg.msgId = 3669;
ReqPeelHallowsMsg.msgType = "CS_PeelHallows";
ReqPeelHallowsMsg.msgClassName = "ReqPeelHallowsMsg";
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
MsgType.CS_YuanLingDun
]]
_G.ReqYuanLingDunMsg = {};

ReqYuanLingDunMsg.msgId = 3671;
ReqYuanLingDunMsg.msgType = "CS_YuanLingDun";
ReqYuanLingDunMsg.msgClassName = "ReqYuanLingDunMsg";
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
MsgType.CS_ChangePlayerName
]]
_G.ReqChangePlayerNameMsg = {};

ReqChangePlayerNameMsg.msgId = 3672;
ReqChangePlayerNameMsg.msgType = "CS_ChangePlayerName";
ReqChangePlayerNameMsg.msgClassName = "ReqChangePlayerNameMsg";
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
MsgType.CS_LunPanRoll
]]
_G.ReqLunPanRollMsg = {};

ReqLunPanRollMsg.msgId = 3674;
ReqLunPanRollMsg.msgType = "CS_LunPanRoll";
ReqLunPanRollMsg.msgClassName = "ReqLunPanRollMsg";



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
MsgType.CS_LunPanSuperRoll
]]
_G.ReqLunPanSuperRollMsg = {};

ReqLunPanSuperRollMsg.msgId = 3675;
ReqLunPanSuperRollMsg.msgType = "CS_LunPanSuperRoll";
ReqLunPanSuperRollMsg.msgClassName = "ReqLunPanSuperRollMsg";



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
MsgType.CS_WuxinglingmaiLevelUp
]]
_G.ReqWuxinglingmaiLevelUpMsg = {};

ReqWuxinglingmaiLevelUpMsg.msgId = 3678;
ReqWuxinglingmaiLevelUpMsg.msgType = "CS_WuxinglingmaiLevelUp";
ReqWuxinglingmaiLevelUpMsg.msgClassName = "ReqWuxinglingmaiLevelUpMsg";
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
MsgType.CS_ActiveWuxinglingmai
]]
_G.ReqActiveWuxinglingmaiMsg = {};

ReqActiveWuxinglingmaiMsg.msgId = 3679;
ReqActiveWuxinglingmaiMsg.msgType = "CS_ActiveWuxinglingmai";
ReqActiveWuxinglingmaiMsg.msgClassName = "ReqActiveWuxinglingmaiMsg";



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
MsgType.CS_WuxinglingmaiItemSwap
]]
_G.ReqWuxinglingmaiItemSwapMsg = {};

ReqWuxinglingmaiItemSwapMsg.msgId = 3684;
ReqWuxinglingmaiItemSwapMsg.msgType = "CS_WuxinglingmaiItemSwap";
ReqWuxinglingmaiItemSwapMsg.msgClassName = "ReqWuxinglingmaiItemSwapMsg";
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
MsgType.CS_HechengWuxinglingmai
]]
_G.ReqHechengWuxinglingmaiMsg = {};

ReqHechengWuxinglingmaiMsg.msgId = 3685;
ReqHechengWuxinglingmaiMsg.msgType = "CS_HechengWuxinglingmai";
ReqHechengWuxinglingmaiMsg.msgClassName = "ReqHechengWuxinglingmaiMsg";
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
MsgType.CS_EquipGroupOpenPos
]]
_G.ReqEquipGroupOpenPosMsg = {};

ReqEquipGroupOpenPosMsg.msgId = 3687;
ReqEquipGroupOpenPosMsg.msgType = "CS_EquipGroupOpenPos";
ReqEquipGroupOpenPosMsg.msgClassName = "ReqEquipGroupOpenPosMsg";
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
MsgType.CS_EquipGroupOpenSet
]]
_G.ReqEquipGroupOpenSetMsg = {};

ReqEquipGroupOpenSetMsg.msgId = 3688;
ReqEquipGroupOpenSetMsg.msgType = "CS_EquipGroupOpenSet";
ReqEquipGroupOpenSetMsg.msgClassName = "ReqEquipGroupOpenSetMsg";
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
MsgType.CS_EquipGroupUpLvl
]]
_G.ReqEquipGroupUpLvlMsg = {};

ReqEquipGroupUpLvlMsg.msgId = 3689;
ReqEquipGroupUpLvlMsg.msgType = "CS_EquipGroupUpLvl";
ReqEquipGroupUpLvlMsg.msgClassName = "ReqEquipGroupUpLvlMsg";
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
MsgType.CS_DekaronDungeonDate
]]
_G.ReqDekaronDungeonDateMsg = {};

ReqDekaronDungeonDateMsg.msgId = 3690;
ReqDekaronDungeonDateMsg.msgType = "CS_DekaronDungeonDate";
ReqDekaronDungeonDateMsg.msgClassName = "ReqDekaronDungeonDateMsg";



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
MsgType.CS_DekaronDungeonEnter
]]
_G.ReqDekaronDungeonEnterMsg = {};

ReqDekaronDungeonEnterMsg.msgId = 3691;
ReqDekaronDungeonEnterMsg.msgType = "CS_DekaronDungeonEnter";
ReqDekaronDungeonEnterMsg.msgClassName = "ReqDekaronDungeonEnterMsg";



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
MsgType.CS_DekaronDungeonQuit
]]
_G.ReqDekaronDungeonQuitMsg = {};

ReqDekaronDungeonQuitMsg.msgId = 3694;
ReqDekaronDungeonQuitMsg.msgType = "CS_DekaronDungeonQuit";
ReqDekaronDungeonQuitMsg.msgClassName = "ReqDekaronDungeonQuitMsg";



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
MsgType.CS_ShouHunLevelUp
]]
_G.ReqShouHunLevelUpMsg = {};

ReqShouHunLevelUpMsg.msgId = 3698;
ReqShouHunLevelUpMsg.msgType = "CS_ShouHunLevelUp";
ReqShouHunLevelUpMsg.msgClassName = "ReqShouHunLevelUpMsg";
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
MsgType.CS_MarryRingStren
]]
_G.ReqMarryRingStrenMsg = {};

ReqMarryRingStrenMsg.msgId = 3699;
ReqMarryRingStrenMsg.msgType = "CS_MarryRingStren";
ReqMarryRingStrenMsg.msgClassName = "ReqMarryRingStrenMsg";



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
MsgType.CS_ZhanNuLevelUp
]]
_G.ReqZhanNuLevelUpMsg = {};

ReqZhanNuLevelUpMsg.msgId = 3702;
ReqZhanNuLevelUpMsg.msgType = "CS_ZhanNuLevelUp";
ReqZhanNuLevelUpMsg.msgClassName = "ReqZhanNuLevelUpMsg";
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
MsgType.CS_ActiveZhanNu
]]
_G.ReqActiveZhanNuMsg = {};

ReqActiveZhanNuMsg.msgId = 3703;
ReqActiveZhanNuMsg.msgType = "CS_ActiveZhanNu";
ReqActiveZhanNuMsg.msgClassName = "ReqActiveZhanNuMsg";



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
MsgType.CS_ChangeZhanNu
]]
_G.ReqChangeZhanNuMsg = {};

ReqChangeZhanNuMsg.msgId = 3704;
ReqChangeZhanNuMsg.msgType = "CS_ChangeZhanNu";
ReqChangeZhanNuMsg.msgClassName = "ReqChangeZhanNuMsg";
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
MsgType.CS_GemInstall
]]
_G.ReqGemInstallMsg = {};

ReqGemInstallMsg.msgId = 3705;
ReqGemInstallMsg.msgType = "CS_GemInstall";
ReqGemInstallMsg.msgClassName = "ReqGemInstallMsg";
ReqGemInstallMsg.pos = 0; -- 装备位
ReqGemInstallMsg.slot = 0; -- 孔位
ReqGemInstallMsg.tid = 0; -- 宝石id
ReqGemInstallMsg.bAutoBuy = 0; -- 自动购买



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
	body = body ..writeInt(self.bAutoBuy);

	return body;
end

function ReqGemInstallMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readInt(pak, idx);
	self.slot, idx = readInt(pak, idx);
	self.tid, idx = readInt(pak, idx);
	self.bAutoBuy, idx = readInt(pak, idx);

end



--[[
宝石卸载
MsgType.CS_GemUninstall
]]
_G.ReqGemUninstallMsg = {};

ReqGemUninstallMsg.msgId = 3706;
ReqGemUninstallMsg.msgType = "CS_GemUninstall";
ReqGemUninstallMsg.msgClassName = "ReqGemUninstallMsg";
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
MsgType.CS_GemChange
]]
_G.ReqGemChangeMsg = {};

ReqGemChangeMsg.msgId = 3707;
ReqGemChangeMsg.msgType = "CS_GemChange";
ReqGemChangeMsg.msgClassName = "ReqGemChangeMsg";
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
MsgType.CS_FabaoCastTarget
]]
_G.ReqFabaoCastTargetMsg = {};

ReqFabaoCastTargetMsg.msgId = 3708;
ReqFabaoCastTargetMsg.msgType = "CS_FabaoCastTarget";
ReqFabaoCastTargetMsg.msgClassName = "ReqFabaoCastTargetMsg";
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
MsgType.CS_FabaoCombine
]]
_G.ReqFabaoCombineMsg = {};

ReqFabaoCombineMsg.msgId = 3709;
ReqFabaoCombineMsg.msgType = "CS_FabaoCombine";
ReqFabaoCombineMsg.msgClassName = "ReqFabaoCombineMsg";
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
MsgType.CS_FabaoDevour
]]
_G.ReqFabaoDevourMsg = {};

ReqFabaoDevourMsg.msgId = 3710;
ReqFabaoDevourMsg.msgType = "CS_FabaoDevour";
ReqFabaoDevourMsg.msgClassName = "ReqFabaoDevourMsg";
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
MsgType.CS_FabaoReborn
]]
_G.ReqFabaoRebornMsg = {};

ReqFabaoRebornMsg.msgId = 3711;
ReqFabaoRebornMsg.msgType = "CS_FabaoReborn";
ReqFabaoRebornMsg.msgClassName = "ReqFabaoRebornMsg";
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
MsgType.CS_FabaoLearn
]]
_G.ReqFabaoLearnMsg = {};

ReqFabaoLearnMsg.msgId = 3712;
ReqFabaoLearnMsg.msgType = "CS_FabaoLearn";
ReqFabaoLearnMsg.msgClassName = "ReqFabaoLearnMsg";
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
MsgType.CS_FabaoCall
]]
_G.ReqFabaoCallMsg = {};

ReqFabaoCallMsg.msgId = 3713;
ReqFabaoCallMsg.msgType = "CS_FabaoCall";
ReqFabaoCallMsg.msgClassName = "ReqFabaoCallMsg";
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
MsgType.CS_Stren
]]
_G.ReqStrenMsg = {};

ReqStrenMsg.msgId = 3136;
ReqStrenMsg.msgType = "CS_Stren";
ReqStrenMsg.msgClassName = "ReqStrenMsg";
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
MsgType.CS_EmptyStarOpen
]]
_G.ReqEmptyStarOpenMsg = {};

ReqEmptyStarOpenMsg.msgId = 3714;
ReqEmptyStarOpenMsg.msgType = "CS_EmptyStarOpen";
ReqEmptyStarOpenMsg.msgClassName = "ReqEmptyStarOpenMsg";
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
MsgType.CS_EquipMerge
]]
_G.ReqEquipMerge = {};

ReqEquipMerge.msgId = 3715;
ReqEquipMerge.msgType = "CS_EquipMerge";
ReqEquipMerge.msgClassName = "ReqEquipMerge";
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
MsgType.CS_HuDunProgress
]]
_G.ReqHuDunProgress = {};

ReqHuDunProgress.msgId = 3716;
ReqHuDunProgress.msgType = "CS_HuDunProgress";
ReqHuDunProgress.msgClassName = "ReqHuDunProgress";
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
MsgType.CS_HuDunAutoUp
]]
_G.ReqHuDunAutoUp = {};

ReqHuDunAutoUp.msgId = 3717;
ReqHuDunAutoUp.msgType = "CS_HuDunAutoUp";
ReqHuDunAutoUp.msgClassName = "ReqHuDunAutoUp";
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
MsgType.CS_JueXueOper
]]
_G.ReqJueXueOperMsg = {};

ReqJueXueOperMsg.msgId = 3718;
ReqJueXueOperMsg.msgType = "CS_JueXueOper";
ReqJueXueOperMsg.msgClassName = "ReqJueXueOperMsg";
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
MsgType.CS_FuMoOper
]]
_G.ReqFuMoOperMsg = {};

ReqFuMoOperMsg.msgId = 3719;
ReqFuMoOperMsg.msgType = "CS_FuMoOper";
ReqFuMoOperMsg.msgClassName = "ReqFuMoOperMsg";
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
请求进入转职副本
MsgType.CS_EnterZhuanZhiDungeon
]]
_G.ReqEnterZhuanZhiDungeonMsg = {};

ReqEnterZhuanZhiDungeonMsg.msgId = 3721;
ReqEnterZhuanZhiDungeonMsg.msgType = "CS_EnterZhuanZhiDungeon";
ReqEnterZhuanZhiDungeonMsg.msgClassName = "ReqEnterZhuanZhiDungeonMsg";
ReqEnterZhuanZhiDungeonMsg.tid = 0; -- 转职配置表tid



ReqEnterZhuanZhiDungeonMsg.meta = {__index = ReqEnterZhuanZhiDungeonMsg };
function ReqEnterZhuanZhiDungeonMsg:new()
	local obj = setmetatable( {}, ReqEnterZhuanZhiDungeonMsg.meta);
	return obj;
end

function ReqEnterZhuanZhiDungeonMsg:encode()
	local body = "";

	body = body ..writeInt(self.tid);

	return body;
end

function ReqEnterZhuanZhiDungeonMsg:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);

end



--[[
一键完成所有任务
MsgType.CS_ZhuanZhiAutoFinish
]]
_G.ReqZhuanZhiAutoFinishMsg = {};

ReqZhuanZhiAutoFinishMsg.msgId = 3722;
ReqZhuanZhiAutoFinishMsg.msgType = "CS_ZhuanZhiAutoFinish";
ReqZhuanZhiAutoFinishMsg.msgClassName = "ReqZhuanZhiAutoFinishMsg";
ReqZhuanZhiAutoFinishMsg.level = 0; -- 要转生的等级 1 - 5



ReqZhuanZhiAutoFinishMsg.meta = {__index = ReqZhuanZhiAutoFinishMsg };
function ReqZhuanZhiAutoFinishMsg:new()
	local obj = setmetatable( {}, ReqZhuanZhiAutoFinishMsg.meta);
	return obj;
end

function ReqZhuanZhiAutoFinishMsg:encode()
	local body = "";

	body = body ..writeInt(self.level);

	return body;
end

function ReqZhuanZhiAutoFinishMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);

end



--[[
获取转职奖励
MsgType.CS_GetZhuanZhiReward
]]
_G.ReqGetZhuanZhiRewardMsg = {};

ReqGetZhuanZhiRewardMsg.msgId = 3723;
ReqGetZhuanZhiRewardMsg.msgType = "CS_GetZhuanZhiReward";
ReqGetZhuanZhiRewardMsg.msgClassName = "ReqGetZhuanZhiRewardMsg";
ReqGetZhuanZhiRewardMsg.tid = 0; -- tid(1 -25)



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
MsgType.CS_StarOper
]]
_G.ReqStarOperMsg = {};

ReqStarOperMsg.msgId = 3724;
ReqStarOperMsg.msgType = "CS_StarOper";
ReqStarOperMsg.msgClassName = "ReqStarOperMsg";
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
请求进入地宫
MsgType.CS_EnterDiGong
]]
_G.ReqEnterDiGongMsg = {};

ReqEnterDiGongMsg.msgId = 3725;
ReqEnterDiGongMsg.msgType = "CS_EnterDiGong";
ReqEnterDiGongMsg.msgClassName = "ReqEnterDiGongMsg";
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
MsgType.CS_QuitDiGong
]]
_G.ReqQuitDiGongMsg = {};

ReqQuitDiGongMsg.msgId = 3726;
ReqQuitDiGongMsg.msgType = "CS_QuitDiGong";
ReqQuitDiGongMsg.msgClassName = "ReqQuitDiGongMsg";



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



--[[
请求开始组队副本
MsgType.CS_StartRideBattle
]]
_G.ReqStartRideBattle = {};

ReqStartRideBattle.msgId = 3727;
ReqStartRideBattle.msgType = "CS_StartRideBattle";
ReqStartRideBattle.msgClassName = "ReqStartRideBattle";



ReqStartRideBattle.meta = {__index = ReqStartRideBattle };
function ReqStartRideBattle:new()
	local obj = setmetatable( {}, ReqStartRideBattle.meta);
	return obj;
end

function ReqStartRideBattle:encode()
	local body = "";


	return body;
end

function ReqStartRideBattle:ParseData(pak)
	local idx = 1;


end



--[[
请求退出转生副本
MsgType.CS_QuitZhuanShengDungeon
]]
_G.ReqQuitZhuanShengDungeon = {};

ReqQuitZhuanShengDungeon.msgId = 3728;
ReqQuitZhuanShengDungeon.msgType = "CS_QuitZhuanShengDungeon";
ReqQuitZhuanShengDungeon.msgClassName = "ReqQuitZhuanShengDungeon";



ReqQuitZhuanShengDungeon.meta = {__index = ReqQuitZhuanShengDungeon };
function ReqQuitZhuanShengDungeon:new()
	local obj = setmetatable( {}, ReqQuitZhuanShengDungeon.meta);
	return obj;
end

function ReqQuitZhuanShengDungeon:encode()
	local body = "";


	return body;
end

function ReqQuitZhuanShengDungeon:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：活跃度模型显示
MsgType.CS_HuoYueDisplay
]]
_G.ReqHuoYueDisplayMsg = {};

ReqHuoYueDisplayMsg.msgId = 3729;
ReqHuoYueDisplayMsg.msgType = "CS_HuoYueDisplay";
ReqHuoYueDisplayMsg.msgClassName = "ReqHuoYueDisplayMsg";
ReqHuoYueDisplayMsg.modelid = 0; -- 仙阶模型ID



ReqHuoYueDisplayMsg.meta = {__index = ReqHuoYueDisplayMsg };
function ReqHuoYueDisplayMsg:new()
	local obj = setmetatable( {}, ReqHuoYueDisplayMsg.meta);
	return obj;
end

function ReqHuoYueDisplayMsg:encode()
	local body = "";

	body = body ..writeInt(self.modelid);

	return body;
end

function ReqHuoYueDisplayMsg:ParseData(pak)
	local idx = 1;

	self.modelid, idx = readInt(pak, idx);

end



--[[
请求装备洗练激活
MsgType.CS_EquipWashActivate
]]
_G.ReqEquipWashActivateMsg = {};

ReqEquipWashActivateMsg.msgId = 3730;
ReqEquipWashActivateMsg.msgType = "CS_EquipWashActivate";
ReqEquipWashActivateMsg.msgClassName = "ReqEquipWashActivateMsg";
ReqEquipWashActivateMsg.id = ""; -- 装备cid



ReqEquipWashActivateMsg.meta = {__index = ReqEquipWashActivateMsg };
function ReqEquipWashActivateMsg:new()
	local obj = setmetatable( {}, ReqEquipWashActivateMsg.meta);
	return obj;
end

function ReqEquipWashActivateMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);

	return body;
end

function ReqEquipWashActivateMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);

end



--[[
请求装备洗练升级
MsgType.CS_EquipWashLevelUp
]]
_G.ReqEquipWashLevelUpMsg = {};

ReqEquipWashLevelUpMsg.msgId = 3731;
ReqEquipWashLevelUpMsg.msgType = "CS_EquipWashLevelUp";
ReqEquipWashLevelUpMsg.msgClassName = "ReqEquipWashLevelUpMsg";
ReqEquipWashLevelUpMsg.id = ""; -- 装备cid



ReqEquipWashLevelUpMsg.meta = {__index = ReqEquipWashLevelUpMsg };
function ReqEquipWashLevelUpMsg:new()
	local obj = setmetatable( {}, ReqEquipWashLevelUpMsg.meta);
	return obj;
end

function ReqEquipWashLevelUpMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);

	return body;
end

function ReqEquipWashLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);

end



--[[
请求装备洗练
MsgType.CS_EquipWashRandom
]]
_G.ReqEquipWashRandomMsg = {};

ReqEquipWashRandomMsg.msgId = 3732;
ReqEquipWashRandomMsg.msgType = "CS_EquipWashRandom";
ReqEquipWashRandomMsg.msgClassName = "ReqEquipWashRandomMsg";
ReqEquipWashRandomMsg.id = ""; -- 装备cid
ReqEquipWashRandomMsg.uid = ""; -- 属性uid



ReqEquipWashRandomMsg.meta = {__index = ReqEquipWashRandomMsg };
function ReqEquipWashRandomMsg:new()
	local obj = setmetatable( {}, ReqEquipWashRandomMsg.meta);
	return obj;
end

function ReqEquipWashRandomMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);
	body = body ..writeGuid(self.uid);

	return body;
end

function ReqEquipWashRandomMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.uid, idx = readGuid(pak, idx);

end



--[[
请求装备传承
MsgType.CS_EquipChuanCheng
]]
_G.ReqEquipChuanChengMsg = {};

ReqEquipChuanChengMsg.msgId = 3733;
ReqEquipChuanChengMsg.msgType = "CS_EquipChuanCheng";
ReqEquipChuanChengMsg.msgClassName = "ReqEquipChuanChengMsg";
ReqEquipChuanChengMsg.srccid = ""; -- 传承装备cid
ReqEquipChuanChengMsg.destcid = ""; -- 被传承装备cid
ReqEquipChuanChengMsg.operation = 0; -- 操作 1 升星 2 洗练 3 升星 洗练



ReqEquipChuanChengMsg.meta = {__index = ReqEquipChuanChengMsg };
function ReqEquipChuanChengMsg:new()
	local obj = setmetatable( {}, ReqEquipChuanChengMsg.meta);
	return obj;
end

function ReqEquipChuanChengMsg:encode()
	local body = "";

	body = body ..writeGuid(self.srccid);
	body = body ..writeGuid(self.destcid);
	body = body ..writeInt(self.operation);

	return body;
end

function ReqEquipChuanChengMsg:ParseData(pak)
	local idx = 1;

	self.srccid, idx = readGuid(pak, idx);
	self.destcid, idx = readGuid(pak, idx);
	self.operation, idx = readInt(pak, idx);

end



--[[
继续挑战
MsgType.CS_QiZhanDungeonContinue
]]
_G.ReqQiZhanDungeonContinueMsg = {};

ReqQiZhanDungeonContinueMsg.msgId = 3734;
ReqQiZhanDungeonContinueMsg.msgType = "CS_QiZhanDungeonContinue";
ReqQiZhanDungeonContinueMsg.msgClassName = "ReqQiZhanDungeonContinueMsg";



ReqQiZhanDungeonContinueMsg.meta = {__index = ReqQiZhanDungeonContinueMsg };
function ReqQiZhanDungeonContinueMsg:new()
	local obj = setmetatable( {}, ReqQiZhanDungeonContinueMsg.meta);
	return obj;
end

function ReqQiZhanDungeonContinueMsg:encode()
	local body = "";


	return body;
end

function ReqQiZhanDungeonContinueMsg:ParseData(pak)
	local idx = 1;


end



--[[
领取首日目标奖励
MsgType.CS_GetFirstDayGoalReward
]]
_G.ReqGetFirstDayGoalRewardMsg = {};

ReqGetFirstDayGoalRewardMsg.msgId = 3735;
ReqGetFirstDayGoalRewardMsg.msgType = "CS_GetFirstDayGoalReward";
ReqGetFirstDayGoalRewardMsg.msgClassName = "ReqGetFirstDayGoalRewardMsg";
ReqGetFirstDayGoalRewardMsg.id = 0; -- 目标id



ReqGetFirstDayGoalRewardMsg.meta = {__index = ReqGetFirstDayGoalRewardMsg };
function ReqGetFirstDayGoalRewardMsg:new()
	local obj = setmetatable( {}, ReqGetFirstDayGoalRewardMsg.meta);
	return obj;
end

function ReqGetFirstDayGoalRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqGetFirstDayGoalRewardMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
我的队伍信息
MsgType.CS_InterServiceSceneMyTeam
]]
_G.ReqInterServiceSceneMyTeamMsg = {};

ReqInterServiceSceneMyTeamMsg.msgId = 3736;
ReqInterServiceSceneMyTeamMsg.msgType = "CS_InterServiceSceneMyTeam";
ReqInterServiceSceneMyTeamMsg.msgClassName = "ReqInterServiceSceneMyTeamMsg";



ReqInterServiceSceneMyTeamMsg.meta = {__index = ReqInterServiceSceneMyTeamMsg };
function ReqInterServiceSceneMyTeamMsg:new()
	local obj = setmetatable( {}, ReqInterServiceSceneMyTeamMsg.meta);
	return obj;
end

function ReqInterServiceSceneMyTeamMsg:encode()
	local body = "";


	return body;
end

function ReqInterServiceSceneMyTeamMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求附近队伍
MsgType.CS_InterSSTeamNearbyTeam
]]
_G.ReqInterSSTeamNearbyTeamMsg = {};

ReqInterSSTeamNearbyTeamMsg.msgId = 3737;
ReqInterSSTeamNearbyTeamMsg.msgType = "CS_InterSSTeamNearbyTeam";
ReqInterSSTeamNearbyTeamMsg.msgClassName = "ReqInterSSTeamNearbyTeamMsg";



ReqInterSSTeamNearbyTeamMsg.meta = {__index = ReqInterSSTeamNearbyTeamMsg };
function ReqInterSSTeamNearbyTeamMsg:new()
	local obj = setmetatable( {}, ReqInterSSTeamNearbyTeamMsg.meta);
	return obj;
end

function ReqInterSSTeamNearbyTeamMsg:encode()
	local body = "";


	return body;
end

function ReqInterSSTeamNearbyTeamMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求附近玩家
MsgType.CS_InterSSTeamNearbyRole
]]
_G.ReqInterSSTeamNearbyRoleMsg = {};

ReqInterSSTeamNearbyRoleMsg.msgId = 3738;
ReqInterSSTeamNearbyRoleMsg.msgType = "CS_InterSSTeamNearbyRole";
ReqInterSSTeamNearbyRoleMsg.msgClassName = "ReqInterSSTeamNearbyRoleMsg";



ReqInterSSTeamNearbyRoleMsg.meta = {__index = ReqInterSSTeamNearbyRoleMsg };
function ReqInterSSTeamNearbyRoleMsg:new()
	local obj = setmetatable( {}, ReqInterSSTeamNearbyRoleMsg.meta);
	return obj;
end

function ReqInterSSTeamNearbyRoleMsg:encode()
	local body = "";


	return body;
end

function ReqInterSSTeamNearbyRoleMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求退出队伍
MsgType.CS_InterSSTeamOut
]]
_G.ReqInterSSTeamOutMsg = {};

ReqInterSSTeamOutMsg.msgId = 3739;
ReqInterSSTeamOutMsg.msgType = "CS_InterSSTeamOut";
ReqInterSSTeamOutMsg.msgClassName = "ReqInterSSTeamOutMsg";



ReqInterSSTeamOutMsg.meta = {__index = ReqInterSSTeamOutMsg };
function ReqInterSSTeamOutMsg:new()
	local obj = setmetatable( {}, ReqInterSSTeamOutMsg.meta);
	return obj;
end

function ReqInterSSTeamOutMsg:encode()
	local body = "";


	return body;
end

function ReqInterSSTeamOutMsg:ParseData(pak)
	local idx = 1;


end



--[[
创建队伍
MsgType.CS_InterSSTeamCreate
]]
_G.ReqInterSSTeamCreateMsg = {};

ReqInterSSTeamCreateMsg.msgId = 3740;
ReqInterSSTeamCreateMsg.msgType = "CS_InterSSTeamCreate";
ReqInterSSTeamCreateMsg.msgClassName = "ReqInterSSTeamCreateMsg";



ReqInterSSTeamCreateMsg.meta = {__index = ReqInterSSTeamCreateMsg };
function ReqInterSSTeamCreateMsg:new()
	local obj = setmetatable( {}, ReqInterSSTeamCreateMsg.meta);
	return obj;
end

function ReqInterSSTeamCreateMsg:encode()
	local body = "";


	return body;
end

function ReqInterSSTeamCreateMsg:ParseData(pak)
	local idx = 1;


end



--[[
加入队伍
MsgType.CS_InterSSTeamjoin
]]
_G.ReqInterSSTeamjoinMsg = {};

ReqInterSSTeamjoinMsg.msgId = 3741;
ReqInterSSTeamjoinMsg.msgType = "CS_InterSSTeamjoin";
ReqInterSSTeamjoinMsg.msgClassName = "ReqInterSSTeamjoinMsg";
ReqInterSSTeamjoinMsg.id = ""; -- 队伍id



ReqInterSSTeamjoinMsg.meta = {__index = ReqInterSSTeamjoinMsg };
function ReqInterSSTeamjoinMsg:new()
	local obj = setmetatable( {}, ReqInterSSTeamjoinMsg.meta);
	return obj;
end

function ReqInterSSTeamjoinMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);

	return body;
end

function ReqInterSSTeamjoinMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);

end



--[[
队长踢人
MsgType.CS_InterSSTeamkick
]]
_G.ReqInterSSTeamkickMsg = {};

ReqInterSSTeamkickMsg.msgId = 3742;
ReqInterSSTeamkickMsg.msgType = "CS_InterSSTeamkick";
ReqInterSSTeamkickMsg.msgClassName = "ReqInterSSTeamkickMsg";
ReqInterSSTeamkickMsg.roleID = ""; -- 角色ID



ReqInterSSTeamkickMsg.meta = {__index = ReqInterSSTeamkickMsg };
function ReqInterSSTeamkickMsg:new()
	local obj = setmetatable( {}, ReqInterSSTeamkickMsg.meta);
	return obj;
end

function ReqInterSSTeamkickMsg:encode()
	local body = "";

	body = body ..writeGuid(self.roleID);

	return body;
end

function ReqInterSSTeamkickMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);

end



--[[
入队审批
MsgType.CS_InterSSTeamApprove
]]
_G.ReqInterSSTeamApproveMsg = {};

ReqInterSSTeamApproveMsg.msgId = 3743;
ReqInterSSTeamApproveMsg.msgType = "CS_InterSSTeamApprove";
ReqInterSSTeamApproveMsg.msgClassName = "ReqInterSSTeamApproveMsg";
ReqInterSSTeamApproveMsg.targetRoleID = ""; -- 目标
ReqInterSSTeamApproveMsg.operate = 0; -- 1同意0拒绝



ReqInterSSTeamApproveMsg.meta = {__index = ReqInterSSTeamApproveMsg };
function ReqInterSSTeamApproveMsg:new()
	local obj = setmetatable( {}, ReqInterSSTeamApproveMsg.meta);
	return obj;
end

function ReqInterSSTeamApproveMsg:encode()
	local body = "";

	body = body ..writeGuid(self.targetRoleID);
	body = body ..writeInt(self.operate);

	return body;
end

function ReqInterSSTeamApproveMsg:ParseData(pak)
	local idx = 1;

	self.targetRoleID, idx = readGuid(pak, idx);
	self.operate, idx = readInt(pak, idx);

end



--[[
请求面板信息
MsgType.CS_InterServiceSceneinfo
]]
_G.ReqInterServiceSceneinfoMsg = {};

ReqInterServiceSceneinfoMsg.msgId = 3744;
ReqInterServiceSceneinfoMsg.msgType = "CS_InterServiceSceneinfo";
ReqInterServiceSceneinfoMsg.msgClassName = "ReqInterServiceSceneinfoMsg";



ReqInterServiceSceneinfoMsg.meta = {__index = ReqInterServiceSceneinfoMsg };
function ReqInterServiceSceneinfoMsg:new()
	local obj = setmetatable( {}, ReqInterServiceSceneinfoMsg.meta);
	return obj;
end

function ReqInterServiceSceneinfoMsg:encode()
	local body = "";


	return body;
end

function ReqInterServiceSceneinfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
退出活动
MsgType.CS_OutInterServiceScene
]]
_G.ReqOutInterServiceSceneMsg = {};

ReqOutInterServiceSceneMsg.msgId = 3745;
ReqOutInterServiceSceneMsg.msgType = "CS_OutInterServiceScene";
ReqOutInterServiceSceneMsg.msgClassName = "ReqOutInterServiceSceneMsg";



ReqOutInterServiceSceneMsg.meta = {__index = ReqOutInterServiceSceneMsg };
function ReqOutInterServiceSceneMsg:new()
	local obj = setmetatable( {}, ReqOutInterServiceSceneMsg.meta);
	return obj;
end

function ReqOutInterServiceSceneMsg:encode()
	local body = "";


	return body;
end

function ReqOutInterServiceSceneMsg:ParseData(pak)
	local idx = 1;


end



--[[
排行信息
MsgType.CS_InterSSQuesRankInfo
]]
_G.ReqInterSSQuesRankInfoMsg = {};

ReqInterSSQuesRankInfoMsg.msgId = 3746;
ReqInterSSQuesRankInfoMsg.msgType = "CS_InterSSQuesRankInfo";
ReqInterSSQuesRankInfoMsg.msgClassName = "ReqInterSSQuesRankInfoMsg";
ReqInterSSQuesRankInfoMsg.type = 0; -- 1杀人，2被杀



ReqInterSSQuesRankInfoMsg.meta = {__index = ReqInterSSQuesRankInfoMsg };
function ReqInterSSQuesRankInfoMsg:new()
	local obj = setmetatable( {}, ReqInterSSQuesRankInfoMsg.meta);
	return obj;
end

function ReqInterSSQuesRankInfoMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqInterSSQuesRankInfoMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
请求我的任务信息
MsgType.CS_InterSSQuestMyInfo
]]
_G.ReqInterSSQuestMyInfoMsg = {};

ReqInterSSQuestMyInfoMsg.msgId = 3747;
ReqInterSSQuestMyInfoMsg.msgType = "CS_InterSSQuestMyInfo";
ReqInterSSQuestMyInfoMsg.msgClassName = "ReqInterSSQuestMyInfoMsg";



ReqInterSSQuestMyInfoMsg.meta = {__index = ReqInterSSQuestMyInfoMsg };
function ReqInterSSQuestMyInfoMsg:new()
	local obj = setmetatable( {}, ReqInterSSQuestMyInfoMsg.meta);
	return obj;
end

function ReqInterSSQuestMyInfoMsg:encode()
	local body = "";


	return body;
end

function ReqInterSSQuestMyInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求任务信息
MsgType.CS_InterSSQuestInfo
]]
_G.ReqInterSSQuestInfoMsg = {};

ReqInterSSQuestInfoMsg.msgId = 3748;
ReqInterSSQuestInfoMsg.msgType = "CS_InterSSQuestInfo";
ReqInterSSQuestInfoMsg.msgClassName = "ReqInterSSQuestInfoMsg";
ReqInterSSQuestInfoMsg.type = 0; -- 0,普通请求，1消耗请求



ReqInterSSQuestInfoMsg.meta = {__index = ReqInterSSQuestInfoMsg };
function ReqInterSSQuestInfoMsg:new()
	local obj = setmetatable( {}, ReqInterSSQuestInfoMsg.meta);
	return obj;
end

function ReqInterSSQuestInfoMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqInterSSQuestInfoMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
请求接取任务信息
MsgType.CS_InterSSQuestGet
]]
_G.ReqInterSSQuestGetMsg = {};

ReqInterSSQuestGetMsg.msgId = 3749;
ReqInterSSQuestGetMsg.msgType = "CS_InterSSQuestGet";
ReqInterSSQuestGetMsg.msgClassName = "ReqInterSSQuestGetMsg";
ReqInterSSQuestGetMsg.questUId = 0; -- 配表id



ReqInterSSQuestGetMsg.meta = {__index = ReqInterSSQuestGetMsg };
function ReqInterSSQuestGetMsg:new()
	local obj = setmetatable( {}, ReqInterSSQuestGetMsg.meta);
	return obj;
end

function ReqInterSSQuestGetMsg:encode()
	local body = "";

	body = body ..writeInt(self.questUId);

	return body;
end

function ReqInterSSQuestGetMsg:ParseData(pak)
	local idx = 1;

	self.questUId, idx = readInt(pak, idx);

end



--[[
请求放弃任务信息
MsgType.CS_InterSSQuestDiscard
]]
_G.ReqInterSSQuestDiscardMsg = {};

ReqInterSSQuestDiscardMsg.msgId = 3750;
ReqInterSSQuestDiscardMsg.msgType = "CS_InterSSQuestDiscard";
ReqInterSSQuestDiscardMsg.msgClassName = "ReqInterSSQuestDiscardMsg";
ReqInterSSQuestDiscardMsg.questUId = ""; -- 任务唯一id



ReqInterSSQuestDiscardMsg.meta = {__index = ReqInterSSQuestDiscardMsg };
function ReqInterSSQuestDiscardMsg:new()
	local obj = setmetatable( {}, ReqInterSSQuestDiscardMsg.meta);
	return obj;
end

function ReqInterSSQuestDiscardMsg:encode()
	local body = "";

	body = body ..writeGuid(self.questUId);

	return body;
end

function ReqInterSSQuestDiscardMsg:ParseData(pak)
	local idx = 1;

	self.questUId, idx = readGuid(pak, idx);

end



--[[
请求领取任务奖励
MsgType.CS_InterSSQuestGetReward
]]
_G.ReqInterSSQuestGetRewardMsg = {};

ReqInterSSQuestGetRewardMsg.msgId = 3751;
ReqInterSSQuestGetRewardMsg.msgType = "CS_InterSSQuestGetReward";
ReqInterSSQuestGetRewardMsg.msgClassName = "ReqInterSSQuestGetRewardMsg";



ReqInterSSQuestGetRewardMsg.meta = {__index = ReqInterSSQuestGetRewardMsg };
function ReqInterSSQuestGetRewardMsg:new()
	local obj = setmetatable( {}, ReqInterSSQuestGetRewardMsg.meta);
	return obj;
end

function ReqInterSSQuestGetRewardMsg:encode()
	local body = "";


	return body;
end

function ReqInterSSQuestGetRewardMsg:ParseData(pak)
	local idx = 1;


end



--[[
队伍邀请玩家
MsgType.CS_InterSSTeamInviteRole
]]
_G.ReqInterSSTeamInviteRoleMsg = {};

ReqInterSSTeamInviteRoleMsg.msgId = 3752;
ReqInterSSTeamInviteRoleMsg.msgType = "CS_InterSSTeamInviteRole";
ReqInterSSTeamInviteRoleMsg.msgClassName = "ReqInterSSTeamInviteRoleMsg";
ReqInterSSTeamInviteRoleMsg.RoleID = ""; -- 目标



ReqInterSSTeamInviteRoleMsg.meta = {__index = ReqInterSSTeamInviteRoleMsg };
function ReqInterSSTeamInviteRoleMsg:new()
	local obj = setmetatable( {}, ReqInterSSTeamInviteRoleMsg.meta);
	return obj;
end

function ReqInterSSTeamInviteRoleMsg:encode()
	local body = "";

	body = body ..writeGuid(self.RoleID);

	return body;
end

function ReqInterSSTeamInviteRoleMsg:ParseData(pak)
	local idx = 1;

	self.RoleID, idx = readGuid(pak, idx);

end



--[[
队伍邀请玩家
MsgType.CS_InterSSTeamInviteRoleResult
]]
_G.ReqInterSSTeamInviteRoleResultMsg = {};

ReqInterSSTeamInviteRoleResultMsg.msgId = 3753;
ReqInterSSTeamInviteRoleResultMsg.msgType = "CS_InterSSTeamInviteRoleResult";
ReqInterSSTeamInviteRoleResultMsg.msgClassName = "ReqInterSSTeamInviteRoleResultMsg";
ReqInterSSTeamInviteRoleResultMsg.TeamId = ""; -- 队伍ID
ReqInterSSTeamInviteRoleResultMsg.operate = 0; -- 1同意0拒绝



ReqInterSSTeamInviteRoleResultMsg.meta = {__index = ReqInterSSTeamInviteRoleResultMsg };
function ReqInterSSTeamInviteRoleResultMsg:new()
	local obj = setmetatable( {}, ReqInterSSTeamInviteRoleResultMsg.meta);
	return obj;
end

function ReqInterSSTeamInviteRoleResultMsg:encode()
	local body = "";

	body = body ..writeGuid(self.TeamId);
	body = body ..writeInt(self.operate);

	return body;
end

function ReqInterSSTeamInviteRoleResultMsg:ParseData(pak)
	local idx = 1;

	self.TeamId, idx = readGuid(pak, idx);
	self.operate, idx = readInt(pak, idx);

end



--[[
玩家申请入队
MsgType.CS_InterSSTeamApproveRole
]]
_G.ReqInterSSTeamApproveRoleMsg = {};

ReqInterSSTeamApproveRoleMsg.msgId = 3754;
ReqInterSSTeamApproveRoleMsg.msgType = "CS_InterSSTeamApproveRole";
ReqInterSSTeamApproveRoleMsg.msgClassName = "ReqInterSSTeamApproveRoleMsg";
ReqInterSSTeamApproveRoleMsg.TaamRoleID = ""; -- 目标



ReqInterSSTeamApproveRoleMsg.meta = {__index = ReqInterSSTeamApproveRoleMsg };
function ReqInterSSTeamApproveRoleMsg:new()
	local obj = setmetatable( {}, ReqInterSSTeamApproveRoleMsg.meta);
	return obj;
end

function ReqInterSSTeamApproveRoleMsg:encode()
	local body = "";

	body = body ..writeGuid(self.TaamRoleID);

	return body;
end

function ReqInterSSTeamApproveRoleMsg:ParseData(pak)
	local idx = 1;

	self.TaamRoleID, idx = readGuid(pak, idx);

end



--[[
玩家戒指升级
MsgType.CS_RingUpGrade
]]
_G.ReqRingUpGradeMsg = {};

ReqRingUpGradeMsg.msgId = 3755;
ReqRingUpGradeMsg.msgType = "CS_RingUpGrade";
ReqRingUpGradeMsg.msgClassName = "ReqRingUpGradeMsg";
ReqRingUpGradeMsg.cid = ""; -- 装备戒指cid



ReqRingUpGradeMsg.meta = {__index = ReqRingUpGradeMsg };
function ReqRingUpGradeMsg:new()
	local obj = setmetatable( {}, ReqRingUpGradeMsg.meta);
	return obj;
end

function ReqRingUpGradeMsg:encode()
	local body = "";

	body = body ..writeGuid(self.cid);

	return body;
end

function ReqRingUpGradeMsg:ParseData(pak)
	local idx = 1;

	self.cid, idx = readGuid(pak, idx);

end



--[[
客户端请求：操作变身功能
MsgType.CS_BianShenOper
]]
_G.ReqBianShenOperMsg = {};

ReqBianShenOperMsg.msgId = 3756;
ReqBianShenOperMsg.msgType = "CS_BianShenOper";
ReqBianShenOperMsg.msgClassName = "ReqBianShenOperMsg";
ReqBianShenOperMsg.oper = 0; -- 1=激活 2=升星 3=升阶 4=换外显 5=换变身
ReqBianShenOperMsg.tid = 0; -- 配置ID
ReqBianShenOperMsg.param1 = 0; -- 参数1
ReqBianShenOperMsg.param2 = 0; -- 参数2



ReqBianShenOperMsg.meta = {__index = ReqBianShenOperMsg };
function ReqBianShenOperMsg:new()
	local obj = setmetatable( {}, ReqBianShenOperMsg.meta);
	return obj;
end

function ReqBianShenOperMsg:encode()
	local body = "";

	body = body ..writeInt(self.oper);
	body = body ..writeInt(self.tid);
	body = body ..writeInt(self.param1);
	body = body ..writeInt(self.param2);

	return body;
end

function ReqBianShenOperMsg:ParseData(pak)
	local idx = 1;

	self.oper, idx = readInt(pak, idx);
	self.tid, idx = readInt(pak, idx);
	self.param1, idx = readInt(pak, idx);
	self.param2, idx = readInt(pak, idx);

end



--[[
客户端请求：选择套餐类型
MsgType.CS_ChooseMealType
]]
_G.ReqChooseMealTypeMsg = {};

ReqChooseMealTypeMsg.msgId = 3757;
ReqChooseMealTypeMsg.msgType = "CS_ChooseMealType";
ReqChooseMealTypeMsg.msgClassName = "ReqChooseMealTypeMsg";
ReqChooseMealTypeMsg.mealType = 0; -- 套餐类型



ReqChooseMealTypeMsg.meta = {__index = ReqChooseMealTypeMsg };
function ReqChooseMealTypeMsg:new()
	local obj = setmetatable( {}, ReqChooseMealTypeMsg.meta);
	return obj;
end

function ReqChooseMealTypeMsg:encode()
	local body = "";

	body = body ..writeInt(self.mealType);

	return body;
end

function ReqChooseMealTypeMsg:ParseData(pak)
	local idx = 1;

	self.mealType, idx = readInt(pak, idx);

end



--[[
返回选择套餐结果
MsgType.SC_ChooseMealTypeResult
]]
_G.ReqChooseMealTypeResultMsg = {};

ReqChooseMealTypeResultMsg.msgId = 8787;
ReqChooseMealTypeResultMsg.msgType = "SC_ChooseMealTypeResult";
ReqChooseMealTypeResultMsg.msgClassName = "ReqChooseMealTypeResultMsg";
ReqChooseMealTypeResultMsg.result = 0; -- 结果 0 成功，1 绑银不足, 2 VIP等级不够
ReqChooseMealTypeResultMsg.mealType = 0; -- 套餐类型



ReqChooseMealTypeResultMsg.meta = {__index = ReqChooseMealTypeResultMsg };
function ReqChooseMealTypeResultMsg:new()
	local obj = setmetatable( {}, ReqChooseMealTypeResultMsg.meta);
	return obj;
end

function ReqChooseMealTypeResultMsg:encode()
	local body = "";

	body = body ..writeInt(self.result);
	body = body ..writeInt(self.mealType);

	return body;
end

function ReqChooseMealTypeResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.mealType, idx = readInt(pak, idx);

end



--[[
客户端请求：吃饭动作
MsgType.CS_MealAction
]]
_G.ReqMealActionMsg = {};

ReqMealActionMsg.msgId = 3758;
ReqMealActionMsg.msgType = "CS_MealAction";
ReqMealActionMsg.msgClassName = "ReqMealActionMsg";
ReqMealActionMsg.actionType = 0; -- 动作类型



ReqMealActionMsg.meta = {__index = ReqMealActionMsg };
function ReqMealActionMsg:new()
	local obj = setmetatable( {}, ReqMealActionMsg.meta);
	return obj;
end

function ReqMealActionMsg:encode()
	local body = "";

	body = body ..writeInt(self.actionType);

	return body;
end

function ReqMealActionMsg:ParseData(pak)
	local idx = 1;

	self.actionType, idx = readInt(pak, idx);

end



--[[
服务器返回：吃饭动作
MsgType.SC_MealAction
]]
_G.RespMealActionMsg = {};

RespMealActionMsg.msgId = 8789;
RespMealActionMsg.msgType = "SC_MealAction";
RespMealActionMsg.msgClassName = "RespMealActionMsg";
RespMealActionMsg.actionType = 0; -- 动作类型



RespMealActionMsg.meta = {__index = RespMealActionMsg };
function RespMealActionMsg:new()
	local obj = setmetatable( {}, RespMealActionMsg.meta);
	return obj;
end

function RespMealActionMsg:encode()
	local body = "";

	body = body ..writeInt(self.actionType);

	return body;
end

function RespMealActionMsg:ParseData(pak)
	local idx = 1;

	self.actionType, idx = readInt(pak, idx);

end



--[[
客户端请求：领取奖励
MsgType.CS_EquipGroupGetReward
]]
_G.ReqEquipGroupGetReward = {};

ReqEquipGroupGetReward.msgId = 3759;
ReqEquipGroupGetReward.msgType = "CS_EquipGroupGetReward";
ReqEquipGroupGetReward.msgClassName = "ReqEquipGroupGetReward";
ReqEquipGroupGetReward.lv = 0; -- 领取几阶奖励



ReqEquipGroupGetReward.meta = {__index = ReqEquipGroupGetReward };
function ReqEquipGroupGetReward:new()
	local obj = setmetatable( {}, ReqEquipGroupGetReward.meta);
	return obj;
end

function ReqEquipGroupGetReward:encode()
	local body = "";

	body = body ..writeInt(self.lv);

	return body;
end

function ReqEquipGroupGetReward:ParseData(pak)
	local idx = 1;

	self.lv, idx = readInt(pak, idx);

end



--[[
客户端请求：激活
MsgType.CS_EquipGroupActivit
]]
_G.ReqEquipGroupActivit = {};

ReqEquipGroupActivit.msgId = 3760;
ReqEquipGroupActivit.msgType = "CS_EquipGroupActivit";
ReqEquipGroupActivit.msgClassName = "ReqEquipGroupActivit";
ReqEquipGroupActivit.lv = 0; -- 几阶
ReqEquipGroupActivit.number = 0; -- 第几个激活按钮（1  2 3）



ReqEquipGroupActivit.meta = {__index = ReqEquipGroupActivit };
function ReqEquipGroupActivit:new()
	local obj = setmetatable( {}, ReqEquipGroupActivit.meta);
	return obj;
end

function ReqEquipGroupActivit:encode()
	local body = "";

	body = body ..writeInt(self.lv);
	body = body ..writeInt(self.number);

	return body;
end

function ReqEquipGroupActivit:ParseData(pak)
	local idx = 1;

	self.lv, idx = readInt(pak, idx);
	self.number, idx = readInt(pak, idx);

end



--[[
客户端请求：设置神炉外显
MsgType.CS_SetShenLuOutLook
]]
_G.ReqSetShenLuOutLook = {};

ReqSetShenLuOutLook.msgId = 3761;
ReqSetShenLuOutLook.msgType = "CS_SetShenLuOutLook";
ReqSetShenLuOutLook.msgClassName = "ReqSetShenLuOutLook";
ReqSetShenLuOutLook.type = 0; -- 0.玄兵 1.保甲
ReqSetShenLuOutLook.lv = 0; -- 阶级
ReqSetShenLuOutLook.operation = 0; -- 1.启用改外显 0.取消改外显



ReqSetShenLuOutLook.meta = {__index = ReqSetShenLuOutLook };
function ReqSetShenLuOutLook:new()
	local obj = setmetatable( {}, ReqSetShenLuOutLook.meta);
	return obj;
end

function ReqSetShenLuOutLook:encode()
	local body = "";

	body = body ..writeInt(self.type);
	body = body ..writeInt(self.lv);
	body = body ..writeInt(self.operation);

	return body;
end

function ReqSetShenLuOutLook:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.lv, idx = readInt(pak, idx);
	self.operation, idx = readInt(pak, idx);

end



--[[
客户端请求：炼制丹药
MsgType.CS_RefineDanYao
]]
_G.ReqRefineDanYaoMsg = {};

ReqRefineDanYaoMsg.msgId = 3762;
ReqRefineDanYaoMsg.msgType = "CS_RefineDanYao";
ReqRefineDanYaoMsg.msgClassName = "ReqRefineDanYaoMsg";



ReqRefineDanYaoMsg.meta = {__index = ReqRefineDanYaoMsg };
function ReqRefineDanYaoMsg:new()
	local obj = setmetatable( {}, ReqRefineDanYaoMsg.meta);
	return obj;
end

function ReqRefineDanYaoMsg:encode()
	local body = "";


	return body;
end

function ReqRefineDanYaoMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：获取炼制丹药信息
MsgType.CS_GetRefineDanYaoInfo
]]
_G.ReqGetRefineDanYaoInfoMsg = {};

ReqGetRefineDanYaoInfoMsg.msgId = 3764;
ReqGetRefineDanYaoInfoMsg.msgType = "CS_GetRefineDanYaoInfo";
ReqGetRefineDanYaoInfoMsg.msgClassName = "ReqGetRefineDanYaoInfoMsg";



ReqGetRefineDanYaoInfoMsg.meta = {__index = ReqGetRefineDanYaoInfoMsg };
function ReqGetRefineDanYaoInfoMsg:new()
	local obj = setmetatable( {}, ReqGetRefineDanYaoInfoMsg.meta);
	return obj;
end

function ReqGetRefineDanYaoInfoMsg:encode()
	local body = "";


	return body;
end

function ReqGetRefineDanYaoInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
点击倒计时的开放功能
MsgType.CS_ClickDelayOpenFunc
]]
_G.ReqClickDelayOpenFuncMsg = {};

ReqClickDelayOpenFuncMsg.msgId = 3763;
ReqClickDelayOpenFuncMsg.msgType = "CS_ClickDelayOpenFunc";
ReqClickDelayOpenFuncMsg.msgClassName = "ReqClickDelayOpenFuncMsg";
ReqClickDelayOpenFuncMsg.funcid = 0; -- 功能ID



ReqClickDelayOpenFuncMsg.meta = {__index = ReqClickDelayOpenFuncMsg };
function ReqClickDelayOpenFuncMsg:new()
	local obj = setmetatable( {}, ReqClickDelayOpenFuncMsg.meta);
	return obj;
end

function ReqClickDelayOpenFuncMsg:encode()
	local body = "";

	body = body ..writeInt(self.funcid);

	return body;
end

function ReqClickDelayOpenFuncMsg:ParseData(pak)
	local idx = 1;

	self.funcid, idx = readInt(pak, idx);

end



--[[
点击倒计时的开放功能
MsgType.SC_ClickDelayOpenFuncResult
]]
_G.RespClickDelayOpenFuncResultMsg = {};

RespClickDelayOpenFuncResultMsg.msgId = 8802;
RespClickDelayOpenFuncResultMsg.msgType = "SC_ClickDelayOpenFuncResult";
RespClickDelayOpenFuncResultMsg.msgClassName = "RespClickDelayOpenFuncResultMsg";
RespClickDelayOpenFuncResultMsg.result = 0; -- 结果，0：成功
RespClickDelayOpenFuncResultMsg.funcid = 0; -- 功能ID



RespClickDelayOpenFuncResultMsg.meta = {__index = RespClickDelayOpenFuncResultMsg };
function RespClickDelayOpenFuncResultMsg:new()
	local obj = setmetatable( {}, RespClickDelayOpenFuncResultMsg.meta);
	return obj;
end

function RespClickDelayOpenFuncResultMsg:encode()
	local body = "";

	body = body ..writeInt(self.result);
	body = body ..writeInt(self.funcid);

	return body;
end

function RespClickDelayOpenFuncResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.funcid, idx = readInt(pak, idx);

end



--[[
快速完成讨伐任务
MsgType.CS_QuickFinshTaoFaTask
]]
_G.ReqQuickFinshTaoFaTaskMsg = {};

ReqQuickFinshTaoFaTaskMsg.msgId = 3766;
ReqQuickFinshTaoFaTaskMsg.msgType = "CS_QuickFinshTaoFaTask";
ReqQuickFinshTaoFaTaskMsg.msgClassName = "ReqQuickFinshTaoFaTaskMsg";



ReqQuickFinshTaoFaTaskMsg.meta = {__index = ReqQuickFinshTaoFaTaskMsg };
function ReqQuickFinshTaoFaTaskMsg:new()
	local obj = setmetatable( {}, ReqQuickFinshTaoFaTaskMsg.meta);
	return obj;
end

function ReqQuickFinshTaoFaTaskMsg:encode()
	local body = "";


	return body;
end

function ReqQuickFinshTaoFaTaskMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求进入讨伐副本
MsgType.CS_EnterTaoFaDungeon
]]
_G.ReqEnterTaoFaDungeonMsg = {};

ReqEnterTaoFaDungeonMsg.msgId = 3767;
ReqEnterTaoFaDungeonMsg.msgType = "CS_EnterTaoFaDungeon";
ReqEnterTaoFaDungeonMsg.msgClassName = "ReqEnterTaoFaDungeonMsg";



ReqEnterTaoFaDungeonMsg.meta = {__index = ReqEnterTaoFaDungeonMsg };
function ReqEnterTaoFaDungeonMsg:new()
	local obj = setmetatable( {}, ReqEnterTaoFaDungeonMsg.meta);
	return obj;
end

function ReqEnterTaoFaDungeonMsg:encode()
	local body = "";


	return body;
end

function ReqEnterTaoFaDungeonMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求退出讨伐副本
MsgType.CS_ExitTaoFaDungeon
]]
_G.ReqExitTaoFaDungeonMsg = {};

ReqExitTaoFaDungeonMsg.msgId = 3768;
ReqExitTaoFaDungeonMsg.msgType = "CS_ExitTaoFaDungeon";
ReqExitTaoFaDungeonMsg.msgClassName = "ReqExitTaoFaDungeonMsg";



ReqExitTaoFaDungeonMsg.meta = {__index = ReqExitTaoFaDungeonMsg };
function ReqExitTaoFaDungeonMsg:new()
	local obj = setmetatable( {}, ReqExitTaoFaDungeonMsg.meta);
	return obj;
end

function ReqExitTaoFaDungeonMsg:encode()
	local body = "";


	return body;
end

function ReqExitTaoFaDungeonMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：灵器进阶
MsgType.CS_LingQiWeaponLevelUp
]]
_G.ReqLingQiWeaponLevelUpMsg = {};

ReqLingQiWeaponLevelUpMsg.msgId = 3769;
ReqLingQiWeaponLevelUpMsg.msgType = "CS_LingQiWeaponLevelUp";
ReqLingQiWeaponLevelUpMsg.msgClassName = "ReqLingQiWeaponLevelUpMsg";
ReqLingQiWeaponLevelUpMsg.autobuy = 0; -- 道具不足时是否自动购买, 0自动购买



ReqLingQiWeaponLevelUpMsg.meta = {__index = ReqLingQiWeaponLevelUpMsg };
function ReqLingQiWeaponLevelUpMsg:new()
	local obj = setmetatable( {}, ReqLingQiWeaponLevelUpMsg.meta);
	return obj;
end

function ReqLingQiWeaponLevelUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.autobuy);

	return body;
end

function ReqLingQiWeaponLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.autobuy, idx = readInt(pak, idx);

end



--[[
客户端请求：灵器换模型
MsgType.CS_LingQiWeaponChangeModel
]]
_G.ReqLingQiWeaponChangeModelMsg = {};

ReqLingQiWeaponChangeModelMsg.msgId = 3770;
ReqLingQiWeaponChangeModelMsg.msgType = "CS_LingQiWeaponChangeModel";
ReqLingQiWeaponChangeModelMsg.msgClassName = "ReqLingQiWeaponChangeModelMsg";
ReqLingQiWeaponChangeModelMsg.level = 0; -- 请求更换模型的等阶(即配表ID)



ReqLingQiWeaponChangeModelMsg.meta = {__index = ReqLingQiWeaponChangeModelMsg };
function ReqLingQiWeaponChangeModelMsg:new()
	local obj = setmetatable( {}, ReqLingQiWeaponChangeModelMsg.meta);
	return obj;
end

function ReqLingQiWeaponChangeModelMsg:encode()
	local body = "";

	body = body ..writeInt(self.level);

	return body;
end

function ReqLingQiWeaponChangeModelMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);

end



--[[
客户端请求：灵器兵灵进阶
MsgType.CS_LingQiBingLingLevelUp
]]
_G.ReqLingQiBingLingLevelUpMsg = {};

ReqLingQiBingLingLevelUpMsg.msgId = 3771;
ReqLingQiBingLingLevelUpMsg.msgType = "CS_LingQiBingLingLevelUp";
ReqLingQiBingLingLevelUpMsg.msgClassName = "ReqLingQiBingLingLevelUpMsg";
ReqLingQiBingLingLevelUpMsg.id = 0; -- 兵灵id



ReqLingQiBingLingLevelUpMsg.meta = {__index = ReqLingQiBingLingLevelUpMsg };
function ReqLingQiBingLingLevelUpMsg:new()
	local obj = setmetatable( {}, ReqLingQiBingLingLevelUpMsg.meta);
	return obj;
end

function ReqLingQiBingLingLevelUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.id);

	return body;
end

function ReqLingQiBingLingLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
请求诛仙阵副本
MsgType.CS_GetZXZInfo
]]
_G.ReqGetZXZInfoMsg = {};

ReqGetZXZInfoMsg.msgId = 3772;
ReqGetZXZInfoMsg.msgType = "CS_GetZXZInfo";
ReqGetZXZInfoMsg.msgClassName = "ReqGetZXZInfoMsg";



ReqGetZXZInfoMsg.meta = {__index = ReqGetZXZInfoMsg };
function ReqGetZXZInfoMsg:new()
	local obj = setmetatable( {}, ReqGetZXZInfoMsg.meta);
	return obj;
end

function ReqGetZXZInfoMsg:encode()
	local body = "";


	return body;
end

function ReqGetZXZInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求诛仙阵副本排行榜信息
MsgType.CS_GetZXZRankingList
]]
_G.ReqGetZXZRankingListMsg = {};

ReqGetZXZRankingListMsg.msgId = 3773;
ReqGetZXZRankingListMsg.msgType = "CS_GetZXZRankingList";
ReqGetZXZRankingListMsg.msgClassName = "ReqGetZXZRankingListMsg";



ReqGetZXZRankingListMsg.meta = {__index = ReqGetZXZRankingListMsg };
function ReqGetZXZRankingListMsg:new()
	local obj = setmetatable( {}, ReqGetZXZRankingListMsg.meta);
	return obj;
end

function ReqGetZXZRankingListMsg:encode()
	local body = "";


	return body;
end

function ReqGetZXZRankingListMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求进入诛仙阵副本
MsgType.CS_EnterZXZInto
]]
_G.ReqEnterZXZIntoMsg = {};

ReqEnterZXZIntoMsg.msgId = 3774;
ReqEnterZXZIntoMsg.msgType = "CS_EnterZXZInto";
ReqEnterZXZIntoMsg.msgClassName = "ReqEnterZXZIntoMsg";



ReqEnterZXZIntoMsg.meta = {__index = ReqEnterZXZIntoMsg };
function ReqEnterZXZIntoMsg:new()
	local obj = setmetatable( {}, ReqEnterZXZIntoMsg.meta);
	return obj;
end

function ReqEnterZXZIntoMsg:encode()
	local body = "";


	return body;
end

function ReqEnterZXZIntoMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求退出诛仙阵副本
MsgType.CS_OutZXZ
]]
_G.ReqOutZXZMsg = {};

ReqOutZXZMsg.msgId = 3775;
ReqOutZXZMsg.msgType = "CS_OutZXZ";
ReqOutZXZMsg.msgClassName = "ReqOutZXZMsg";
ReqOutZXZMsg.state = 0; -- 1 继续 0 退出



ReqOutZXZMsg.meta = {__index = ReqOutZXZMsg };
function ReqOutZXZMsg:new()
	local obj = setmetatable( {}, ReqOutZXZMsg.meta);
	return obj;
end

function ReqOutZXZMsg:encode()
	local body = "";

	body = body ..writeInt(self.state);

	return body;
end

function ReqOutZXZMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);

end



--[[
客户端请求：神兵进阶
MsgType.CS_MingYuWeaponLevelUp
]]
_G.ReqMingYuWeaponLevelUpMsg = {};

ReqMingYuWeaponLevelUpMsg.msgId = 3776;
ReqMingYuWeaponLevelUpMsg.msgType = "CS_MingYuWeaponLevelUp";
ReqMingYuWeaponLevelUpMsg.msgClassName = "ReqMingYuWeaponLevelUpMsg";
ReqMingYuWeaponLevelUpMsg.autobuy = 0; -- 道具不足时是否自动购买, 0自动购买



ReqMingYuWeaponLevelUpMsg.meta = {__index = ReqMingYuWeaponLevelUpMsg };
function ReqMingYuWeaponLevelUpMsg:new()
	local obj = setmetatable( {}, ReqMingYuWeaponLevelUpMsg.meta);
	return obj;
end

function ReqMingYuWeaponLevelUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.autobuy);

	return body;
end

function ReqMingYuWeaponLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.autobuy, idx = readInt(pak, idx);

end



--[[
客户端请求：点击功能开放
MsgType.CS_FunctionOpen
]]
_G.ReqFunctionOpenMsg = {};

ReqFunctionOpenMsg.msgId = 3777;
ReqFunctionOpenMsg.msgType = "CS_FunctionOpen";
ReqFunctionOpenMsg.msgClassName = "ReqFunctionOpenMsg";
ReqFunctionOpenMsg.funcID = 0; -- 功能id



ReqFunctionOpenMsg.meta = {__index = ReqFunctionOpenMsg };
function ReqFunctionOpenMsg:new()
	local obj = setmetatable( {}, ReqFunctionOpenMsg.meta);
	return obj;
end

function ReqFunctionOpenMsg:encode()
	local body = "";

	body = body ..writeInt(self.funcID);

	return body;
end

function ReqFunctionOpenMsg:ParseData(pak)
	local idx = 1;

	self.funcID, idx = readInt(pak, idx);

end



--[[
客户端请求：刷新任务集会所中的任务
MsgType.CS_Refresh_QuestAgora
]]
_G.ReqRefreshQuestAgoraMsg = {};

ReqRefreshQuestAgoraMsg.msgId = 3778;
ReqRefreshQuestAgoraMsg.msgType = "CS_Refresh_QuestAgora";
ReqRefreshQuestAgoraMsg.msgClassName = "ReqRefreshQuestAgoraMsg";



ReqRefreshQuestAgoraMsg.meta = {__index = ReqRefreshQuestAgoraMsg };
function ReqRefreshQuestAgoraMsg:new()
	local obj = setmetatable( {}, ReqRefreshQuestAgoraMsg.meta);
	return obj;
end

function ReqRefreshQuestAgoraMsg:encode()
	local body = "";


	return body;
end

function ReqRefreshQuestAgoraMsg:ParseData(pak)
	local idx = 1;


end



--[[
客户端请求：领取任务集会所中的任务
MsgType.CS_Accept_QuestAgora
]]
_G.ReqAcceptQuestAgoraMsg = {};

ReqAcceptQuestAgoraMsg.msgId = 3779;
ReqAcceptQuestAgoraMsg.msgType = "CS_Accept_QuestAgora";
ReqAcceptQuestAgoraMsg.msgClassName = "ReqAcceptQuestAgoraMsg";
ReqAcceptQuestAgoraMsg.quest_idx = 0; -- 领取任务索引（横向顺序）



ReqAcceptQuestAgoraMsg.meta = {__index = ReqAcceptQuestAgoraMsg };
function ReqAcceptQuestAgoraMsg:new()
	local obj = setmetatable( {}, ReqAcceptQuestAgoraMsg.meta);
	return obj;
end

function ReqAcceptQuestAgoraMsg:encode()
	local body = "";

	body = body ..writeInt(self.quest_idx);

	return body;
end

function ReqAcceptQuestAgoraMsg:ParseData(pak)
	local idx = 1;

	self.quest_idx, idx = readInt(pak, idx);

end



--[[
客户端请求：放弃任务集会所中的任务
MsgType.CS_Abandon_QuestAgora
]]
_G.ReqAbandonQuestAgoraMsg = {};

ReqAbandonQuestAgoraMsg.msgId = 3780;
ReqAbandonQuestAgoraMsg.msgType = "CS_Abandon_QuestAgora";
ReqAbandonQuestAgoraMsg.msgClassName = "ReqAbandonQuestAgoraMsg";
ReqAbandonQuestAgoraMsg.quest_idx = 0; -- 放弃任务索引（横向顺序）



ReqAbandonQuestAgoraMsg.meta = {__index = ReqAbandonQuestAgoraMsg };
function ReqAbandonQuestAgoraMsg:new()
	local obj = setmetatable( {}, ReqAbandonQuestAgoraMsg.meta);
	return obj;
end

function ReqAbandonQuestAgoraMsg:encode()
	local body = "";

	body = body ..writeInt(self.quest_idx);

	return body;
end

function ReqAbandonQuestAgoraMsg:ParseData(pak)
	local idx = 1;

	self.quest_idx, idx = readInt(pak, idx);

end



--[[
请求牧业战信息
MsgType.CS_MuYeWarInfo
]]
_G.ReqMuYeWarInfoMsg = {};

ReqMuYeWarInfoMsg.msgId = 3781;
ReqMuYeWarInfoMsg.msgType = "CS_MuYeWarInfo";
ReqMuYeWarInfoMsg.msgClassName = "ReqMuYeWarInfoMsg";



ReqMuYeWarInfoMsg.meta = {__index = ReqMuYeWarInfoMsg };
function ReqMuYeWarInfoMsg:new()
	local obj = setmetatable( {}, ReqMuYeWarInfoMsg.meta);
	return obj;
end

function ReqMuYeWarInfoMsg:encode()
	local body = "";


	return body;
end

function ReqMuYeWarInfoMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求进入牧业战信息
MsgType.CS_MuYeWarEnter
]]
_G.ReqMuYeWarEnterMsg = {};

ReqMuYeWarEnterMsg.msgId = 3782;
ReqMuYeWarEnterMsg.msgType = "CS_MuYeWarEnter";
ReqMuYeWarEnterMsg.msgClassName = "ReqMuYeWarEnterMsg";



ReqMuYeWarEnterMsg.meta = {__index = ReqMuYeWarEnterMsg };
function ReqMuYeWarEnterMsg:new()
	local obj = setmetatable( {}, ReqMuYeWarEnterMsg.meta);
	return obj;
end

function ReqMuYeWarEnterMsg:encode()
	local body = "";


	return body;
end

function ReqMuYeWarEnterMsg:ParseData(pak)
	local idx = 1;


end



--[[
请求退出牧业战
MsgType.CS_MuYeWarQuit
]]
_G.ReqMuYeWarQuitMsg = {};

ReqMuYeWarQuitMsg.msgId = 3783;
ReqMuYeWarQuitMsg.msgType = "CS_MuYeWarQuit";
ReqMuYeWarQuitMsg.msgClassName = "ReqMuYeWarQuitMsg";



ReqMuYeWarQuitMsg.meta = {__index = ReqMuYeWarQuitMsg };
function ReqMuYeWarQuitMsg:new()
	local obj = setmetatable( {}, ReqMuYeWarQuitMsg.meta);
	return obj;
end

function ReqMuYeWarQuitMsg:encode()
	local body = "";


	return body;
end

function ReqMuYeWarQuitMsg:ParseData(pak)
	local idx = 1;


end



--[[
切换骑战
MsgType.CS_ChangeMuYeQiZhan
]]
_G.ReqChangeMuYeQiZhanMsg = {};

ReqChangeMuYeQiZhanMsg.msgId = 3785;
ReqChangeMuYeQiZhanMsg.msgType = "CS_ChangeMuYeQiZhan";
ReqChangeMuYeQiZhanMsg.msgClassName = "ReqChangeMuYeQiZhanMsg";
ReqChangeMuYeQiZhanMsg.level = 0; -- 骑战等阶



ReqChangeMuYeQiZhanMsg.meta = {__index = ReqChangeMuYeQiZhanMsg };
function ReqChangeMuYeQiZhanMsg:new()
	local obj = setmetatable( {}, ReqChangeMuYeQiZhanMsg.meta);
	return obj;
end

function ReqChangeMuYeQiZhanMsg:encode()
	local body = "";

	body = body ..writeInt(self.level);

	return body;
end

function ReqChangeMuYeQiZhanMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);

end



--[[
获取牧业首通奖励
MsgType.CS_GetMuYeReward
]]
_G.ReqGetMuYeRewardMsg = {};

ReqGetMuYeRewardMsg.msgId = 3786;
ReqGetMuYeRewardMsg.msgType = "CS_GetMuYeReward";
ReqGetMuYeRewardMsg.msgClassName = "ReqGetMuYeRewardMsg";
ReqGetMuYeRewardMsg.index = 0; -- 第几个



ReqGetMuYeRewardMsg.meta = {__index = ReqGetMuYeRewardMsg };
function ReqGetMuYeRewardMsg:new()
	local obj = setmetatable( {}, ReqGetMuYeRewardMsg.meta);
	return obj;
end

function ReqGetMuYeRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.index);

	return body;
end

function ReqGetMuYeRewardMsg:ParseData(pak)
	local idx = 1;

	self.index, idx = readInt(pak, idx);

end



--[[
与NPC对话
MsgType.CS_NpcGossip
]]
_G.ReqNpcGossipMsg = {};

ReqNpcGossipMsg.msgId = 3787;
ReqNpcGossipMsg.msgType = "CS_NpcGossip";
ReqNpcGossipMsg.msgClassName = "ReqNpcGossipMsg";
ReqNpcGossipMsg.npcid = 0; -- NPC配置ID



ReqNpcGossipMsg.meta = {__index = ReqNpcGossipMsg };
function ReqNpcGossipMsg:new()
	local obj = setmetatable( {}, ReqNpcGossipMsg.meta);
	return obj;
end

function ReqNpcGossipMsg:encode()
	local body = "";

	body = body ..writeInt(self.npcid);

	return body;
end

function ReqNpcGossipMsg:ParseData(pak)
	local idx = 1;

	self.npcid, idx = readInt(pak, idx);

end



--[[
客户端请求：灵器换模型
MsgType.CS_MingYuWeaponChangeModel
]]
_G.ReqMingYuWeaponChangeModelMsg = {};

ReqMingYuWeaponChangeModelMsg.msgId = 3789;
ReqMingYuWeaponChangeModelMsg.msgType = "CS_MingYuWeaponChangeModel";
ReqMingYuWeaponChangeModelMsg.msgClassName = "ReqMingYuWeaponChangeModelMsg";
ReqMingYuWeaponChangeModelMsg.level = 0; -- 请求更换模型的等阶(即配表ID)



ReqMingYuWeaponChangeModelMsg.meta = {__index = ReqMingYuWeaponChangeModelMsg };
function ReqMingYuWeaponChangeModelMsg:new()
	local obj = setmetatable( {}, ReqMingYuWeaponChangeModelMsg.meta);
	return obj;
end

function ReqMingYuWeaponChangeModelMsg:encode()
	local body = "";

	body = body ..writeInt(self.level);

	return body;
end

function ReqMingYuWeaponChangeModelMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);

end



--[[
客户端请求：保甲进阶
MsgType.CS_NewBaoJiaLevelUp
]]
_G.ReqNewBaoJiaLevelUpMsg = {};

ReqNewBaoJiaLevelUpMsg.msgId = 3790;
ReqNewBaoJiaLevelUpMsg.msgType = "CS_NewBaoJiaLevelUp";
ReqNewBaoJiaLevelUpMsg.msgClassName = "ReqNewBaoJiaLevelUpMsg";
ReqNewBaoJiaLevelUpMsg.autobuy = 0; -- 道具不足时是否自动购买, 0自动购买



ReqNewBaoJiaLevelUpMsg.meta = {__index = ReqNewBaoJiaLevelUpMsg };
function ReqNewBaoJiaLevelUpMsg:new()
	local obj = setmetatable( {}, ReqNewBaoJiaLevelUpMsg.meta);
	return obj;
end

function ReqNewBaoJiaLevelUpMsg:encode()
	local body = "";

	body = body ..writeInt(self.autobuy);

	return body;
end

function ReqNewBaoJiaLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.autobuy, idx = readInt(pak, idx);

end



--[[
日环任务一键完成
MsgType.CS_TodayQuestFinish
]]
_G.ReqTodayQuestFinishMsg = {};

ReqTodayQuestFinishMsg.msgId = 3791;
ReqTodayQuestFinishMsg.msgType = "CS_TodayQuestFinish";
ReqTodayQuestFinishMsg.msgClassName = "ReqTodayQuestFinishMsg";
ReqTodayQuestFinishMsg.multiple = 0; -- 1：免费领一倍，2：银两领双倍，：3元宝领三倍



ReqTodayQuestFinishMsg.meta = {__index = ReqTodayQuestFinishMsg };
function ReqTodayQuestFinishMsg:new()
	local obj = setmetatable( {}, ReqTodayQuestFinishMsg.meta);
	return obj;
end

function ReqTodayQuestFinishMsg:encode()
	local body = "";

	body = body ..writeInt(self.multiple);

	return body;
end

function ReqTodayQuestFinishMsg:ParseData(pak)
	local idx = 1;

	self.multiple, idx = readInt(pak, idx);

end



--[[
请求日环任务结果
MsgType.CS_TodayQuestResult
]]
_G.ReqTodayQuestResultMsg = {};

ReqTodayQuestResultMsg.msgId = 3792;
ReqTodayQuestResultMsg.msgType = "CS_TodayQuestResult";
ReqTodayQuestResultMsg.msgClassName = "ReqTodayQuestResultMsg";



ReqTodayQuestResultMsg.meta = {__index = ReqTodayQuestResultMsg };
function ReqTodayQuestResultMsg:new()
	local obj = setmetatable( {}, ReqTodayQuestResultMsg.meta);
	return obj;
end

function ReqTodayQuestResultMsg:encode()
	local body = "";


	return body;
end

function ReqTodayQuestResultMsg:ParseData(pak)
	local idx = 1;


end



--[[
运营活动抽奖
MsgType.CS_YunYingDraw
]]
_G.ReqYunYingDrawMsg = {};

ReqYunYingDrawMsg.msgId = 3793;
ReqYunYingDrawMsg.msgType = "CS_YunYingDraw";
ReqYunYingDrawMsg.msgClassName = "ReqYunYingDrawMsg";



ReqYunYingDrawMsg.meta = {__index = ReqYunYingDrawMsg };
function ReqYunYingDrawMsg:new()
	local obj = setmetatable( {}, ReqYunYingDrawMsg.meta);
	return obj;
end

function ReqYunYingDrawMsg:encode()
	local body = "";


	return body;
end

function ReqYunYingDrawMsg:ParseData(pak)
	local idx = 1;


end



--[[
使用资质丹
MsgType.CS_UseZiZhiDan
]]
_G.ReqUseZiZhiDanMsg = {};

ReqUseZiZhiDanMsg.msgId = 3794;
ReqUseZiZhiDanMsg.msgType = "CS_UseZiZhiDan";
ReqUseZiZhiDanMsg.msgClassName = "ReqUseZiZhiDanMsg";
ReqUseZiZhiDanMsg.type = 0; -- 1、保甲 2 命玉 3神兵 4 法宝  5境界 6坐骑



ReqUseZiZhiDanMsg.meta = {__index = ReqUseZiZhiDanMsg };
function ReqUseZiZhiDanMsg:new()
	local obj = setmetatable( {}, ReqUseZiZhiDanMsg.meta);
	return obj;
end

function ReqUseZiZhiDanMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqUseZiZhiDanMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
使用升星道具
MsgType.CS_UseShengXingItem
]]
_G.ReqUseShengXingItemMsg = {};

ReqUseShengXingItemMsg.msgId = 3795;
ReqUseShengXingItemMsg.msgType = "CS_UseShengXingItem";
ReqUseShengXingItemMsg.msgClassName = "ReqUseShengXingItemMsg";
ReqUseShengXingItemMsg.equipid = ""; -- 装备cid



ReqUseShengXingItemMsg.meta = {__index = ReqUseShengXingItemMsg };
function ReqUseShengXingItemMsg:new()
	local obj = setmetatable( {}, ReqUseShengXingItemMsg.meta);
	return obj;
end

function ReqUseShengXingItemMsg:encode()
	local body = "";

	body = body ..writeGuid(self.equipid);

	return body;
end

function ReqUseShengXingItemMsg:ParseData(pak)
	local idx = 1;

	self.equipid, idx = readGuid(pak, idx);

end



--[[
请求升级圣物
MsgType.CS_LevelupRelicItem
]]
_G.ReqLevelupRelicItemMsg = {};

ReqLevelupRelicItemMsg.msgId = 3796;
ReqLevelupRelicItemMsg.msgType = "CS_LevelupRelicItem";
ReqLevelupRelicItemMsg.msgClassName = "ReqLevelupRelicItemMsg";
ReqLevelupRelicItemMsg.bag = 0; -- 背包类型
ReqLevelupRelicItemMsg.id = ""; -- 物品ID



ReqLevelupRelicItemMsg.meta = {__index = ReqLevelupRelicItemMsg };
function ReqLevelupRelicItemMsg:new()
	local obj = setmetatable( {}, ReqLevelupRelicItemMsg.meta);
	return obj;
end

function ReqLevelupRelicItemMsg:encode()
	local body = "";

	body = body ..writeInt(self.bag);
	body = body ..writeGuid(self.id);

	return body;
end

function ReqLevelupRelicItemMsg:ParseData(pak)
	local idx = 1;

	self.bag, idx = readInt(pak, idx);
	self.id, idx = readGuid(pak, idx);

end



--[[
客户端请求：进入通用副本
MsgType.CS_EnterCommDungeon
]]
_G.ReqEnterCommDungeonMsg = {};

ReqEnterCommDungeonMsg.msgId = 3797;
ReqEnterCommDungeonMsg.msgType = "CS_EnterCommDungeon";
ReqEnterCommDungeonMsg.msgClassName = "ReqEnterCommDungeonMsg";
ReqEnterCommDungeonMsg.type = 0; -- 副本类型 21 挑战副本  7  天神副本 32 牧野之战
ReqEnterCommDungeonMsg.state = 0; -- 进入难度：1 普通 2 困难 3 噩梦 4 神话 5 传说



ReqEnterCommDungeonMsg.meta = {__index = ReqEnterCommDungeonMsg };
function ReqEnterCommDungeonMsg:new()
	local obj = setmetatable( {}, ReqEnterCommDungeonMsg.meta);
	return obj;
end

function ReqEnterCommDungeonMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);
	body = body ..writeInt(self.state);

	return body;
end

function ReqEnterCommDungeonMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
客户端请求：天神操作功能
MsgType.CS_TianShenOperStar
]]
_G.ReqTianShenOperStarMsg = {};

ReqTianShenOperStarMsg.msgId = 3798;
ReqTianShenOperStarMsg.msgType = "CS_TianShenOperStar";
ReqTianShenOperStarMsg.msgClassName = "ReqTianShenOperStarMsg";
ReqTianShenOperStarMsg.id = ""; -- 唯一ID
ReqTianShenOperStarMsg.starlist_size = 10; -- 升星列表 size
ReqTianShenOperStarMsg.starlist = {}; -- 升星列表 list

--[[
StarListVO = {
	id = ""; -- 升星物品ID
}
]]

ReqTianShenOperStarMsg.meta = {__index = ReqTianShenOperStarMsg };
function ReqTianShenOperStarMsg:new()
	local obj = setmetatable( {}, ReqTianShenOperStarMsg.meta);
	return obj;
end

function ReqTianShenOperStarMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);

	local list1 = self.starlist;
	local list1Size = 10;

	for i1=1,list1Size do
		body = body .. writeGuid(list1[i1].id);
	end

	return body;
end

function ReqTianShenOperStarMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);

	local list1 = {};
	self.starlist = list1;
	local list1Size = 10;

	for i=1,list1Size do
		local StarListVo = {};
		StarListVo.id, idx = readGuid(pak, idx);
		table.push(list1,StarListVo);
	end

end



--[[
客户端请求：天神操作功能
MsgType.CS_TianShenOperStep
]]
_G.ReqTianShenOperStepMsg = {};

ReqTianShenOperStepMsg.msgId = 3799;
ReqTianShenOperStepMsg.msgType = "CS_TianShenOperStep";
ReqTianShenOperStepMsg.msgClassName = "ReqTianShenOperStepMsg";
ReqTianShenOperStepMsg.id = ""; -- 唯一ID
ReqTianShenOperStepMsg.flags = 0; -- 0普通升级，1自动升级



ReqTianShenOperStepMsg.meta = {__index = ReqTianShenOperStepMsg };
function ReqTianShenOperStepMsg:new()
	local obj = setmetatable( {}, ReqTianShenOperStepMsg.meta);
	return obj;
end

function ReqTianShenOperStepMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);
	body = body ..writeInt(self.flags);

	return body;
end

function ReqTianShenOperStepMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.flags, idx = readInt(pak, idx);

end



--[[
客户端请求：天神操作功能
MsgType.CS_TianShenOperEquip
]]
_G.ReqTianShenOperEquipMsg = {};

ReqTianShenOperEquipMsg.msgId = 3800;
ReqTianShenOperEquipMsg.msgType = "CS_TianShenOperEquip";
ReqTianShenOperEquipMsg.msgClassName = "ReqTianShenOperEquipMsg";
ReqTianShenOperEquipMsg.id = ""; -- 唯一ID
ReqTianShenOperEquipMsg.pos = 0; -- 目标位置 >0装备，-1卸下



ReqTianShenOperEquipMsg.meta = {__index = ReqTianShenOperEquipMsg };
function ReqTianShenOperEquipMsg:new()
	local obj = setmetatable( {}, ReqTianShenOperEquipMsg.meta);
	return obj;
end

function ReqTianShenOperEquipMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);
	body = body ..writeInt(self.pos);

	return body;
end

function ReqTianShenOperEquipMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.pos, idx = readInt(pak, idx);

end



--[[
客户端请求：天神操作功能
MsgType.CS_TianShenOperCompose
]]
_G.ReqTianShenOperComposeMsg = {};

ReqTianShenOperComposeMsg.msgId = 3801;
ReqTianShenOperComposeMsg.msgType = "CS_TianShenOperCompose";
ReqTianShenOperComposeMsg.msgClassName = "ReqTianShenOperComposeMsg";
ReqTianShenOperComposeMsg.complist_size = 10; -- 合成列表 size
ReqTianShenOperComposeMsg.complist = {}; -- 合成列表 list

--[[
CompListVO = {
	id = ""; -- 合成物品ID
}
]]

ReqTianShenOperComposeMsg.meta = {__index = ReqTianShenOperComposeMsg };
function ReqTianShenOperComposeMsg:new()
	local obj = setmetatable( {}, ReqTianShenOperComposeMsg.meta);
	return obj;
end

function ReqTianShenOperComposeMsg:encode()
	local body = "";


	local list1 = self.complist;
	local list1Size = 10;

	for i1=1,list1Size do
		body = body .. writeGuid(list1[i1].id);
	end

	return body;
end

function ReqTianShenOperComposeMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.complist = list1;
	local list1Size = 10;

	for i=1,list1Size do
		local CompListVo = {};
		CompListVo.id, idx = readGuid(pak, idx);
		table.push(list1,CompListVo);
	end

end



--[[
客户端请求：天神操作功能
MsgType.CS_TianShenOperInherit
]]
_G.ReqTianShenOperInheritMsg = {};

ReqTianShenOperInheritMsg.msgId = 3802;
ReqTianShenOperInheritMsg.msgType = "CS_TianShenOperInherit";
ReqTianShenOperInheritMsg.msgClassName = "ReqTianShenOperInheritMsg";
ReqTianShenOperInheritMsg.id = ""; -- 唯一ID
ReqTianShenOperInheritMsg.tarid = ""; -- 目标ID
ReqTianShenOperInheritMsg.oper = 0; -- 1=等级，2=星级



ReqTianShenOperInheritMsg.meta = {__index = ReqTianShenOperInheritMsg };
function ReqTianShenOperInheritMsg:new()
	local obj = setmetatable( {}, ReqTianShenOperInheritMsg.meta);
	return obj;
end

function ReqTianShenOperInheritMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);
	body = body ..writeGuid(self.tarid);
	body = body ..writeInt(self.oper);

	return body;
end

function ReqTianShenOperInheritMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.tarid, idx = readGuid(pak, idx);
	self.oper, idx = readInt(pak, idx);

end



--[[
客户端请求：天神操作功能
MsgType.CS_TianShenOperDiscard
]]
_G.ReqTianShenOperDiscardMsg = {};

ReqTianShenOperDiscardMsg.msgId = 3803;
ReqTianShenOperDiscardMsg.msgType = "CS_TianShenOperDiscard";
ReqTianShenOperDiscardMsg.msgClassName = "ReqTianShenOperDiscardMsg";
ReqTianShenOperDiscardMsg.id = ""; -- 唯一ID



ReqTianShenOperDiscardMsg.meta = {__index = ReqTianShenOperDiscardMsg };
function ReqTianShenOperDiscardMsg:new()
	local obj = setmetatable( {}, ReqTianShenOperDiscardMsg.meta);
	return obj;
end

function ReqTianShenOperDiscardMsg:encode()
	local body = "";

	body = body ..writeGuid(self.id);

	return body;
end

function ReqTianShenOperDiscardMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);

end



--[[
客户端请求：卫士渠道奖励功能
MsgType.CS_WeiShiChannelReward
]]
_G.ReqWeiShiChannelRewardMsg = {};

ReqWeiShiChannelRewardMsg.msgId = 3804;
ReqWeiShiChannelRewardMsg.msgType = "CS_WeiShiChannelReward";
ReqWeiShiChannelRewardMsg.msgClassName = "ReqWeiShiChannelRewardMsg";
ReqWeiShiChannelRewardMsg.type = 0; -- type=1,2,3



ReqWeiShiChannelRewardMsg.meta = {__index = ReqWeiShiChannelRewardMsg };
function ReqWeiShiChannelRewardMsg:new()
	local obj = setmetatable( {}, ReqWeiShiChannelRewardMsg.meta);
	return obj;
end

function ReqWeiShiChannelRewardMsg:encode()
	local body = "";

	body = body ..writeInt(self.type);

	return body;
end

function ReqWeiShiChannelRewardMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end






















