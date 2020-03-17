

--[[
登录返回
]]

_G.RespConnSrvMsg = {};

RespConnSrvMsg.msgId = 6001;
RespConnSrvMsg.resultCode = 0; -- 返回：0:OK -1:Create Role -2:时间戳错误 -3:签名不匹配 -4:封停 -5:协议不一致 -6:MAC封禁
RespConnSrvMsg.accountID = ""; -- 登录账户ID
RespConnSrvMsg.guid = ""; -- guid
RespConnSrvMsg.forbbidenTime = 0; -- 封停时间
RespConnSrvMsg.serverTime = 0; -- 服务器时间,秒



RespConnSrvMsg.meta = {__index = RespConnSrvMsg};
function RespConnSrvMsg:new()
	local obj = setmetatable( {}, RespConnSrvMsg.meta);
	return obj;
end

function RespConnSrvMsg:ParseData(pak)
	local idx = 1;

	self.resultCode, idx = readInt(pak, idx);
	self.accountID, idx = readString(pak, idx, 64);
	self.guid, idx = readGuid(pak, idx);
	self.forbbidenTime, idx = readInt(pak, idx);
	self.serverTime, idx = readInt64(pak, idx);

end



--[[
角色返回
]]

_G.RespCreateRoleMsg = {};

RespCreateRoleMsg.msgId = 6002;
RespCreateRoleMsg.resultCode = 0; -- 结果,0成功,-1名字冲突,-2名字不合法 -3其他Error
RespCreateRoleMsg.roleProf = 0; -- 角色职业
RespCreateRoleMsg.roleID = ""; -- 角色ID
RespCreateRoleMsg.roleName = ""; -- 角色名字



RespCreateRoleMsg.meta = {__index = RespCreateRoleMsg};
function RespCreateRoleMsg:new()
	local obj = setmetatable( {}, RespCreateRoleMsg.meta);
	return obj;
end

function RespCreateRoleMsg:ParseData(pak)
	local idx = 1;

	self.resultCode, idx = readInt(pak, idx);
	self.roleProf, idx = readInt(pak, idx);
	self.roleID, idx = readGuid(pak, idx);
	self.roleName, idx = readString(pak, idx, 32);

end



--[[
返回登录角色信息
]]

_G.RespLoginRoleInfoMsg = {};

RespLoginRoleInfoMsg.msgId = 6003;
RespLoginRoleInfoMsg.roleID = ""; -- 角色ID
RespLoginRoleInfoMsg.roleName = ""; -- 角色名字
RespLoginRoleInfoMsg.mapId = 0; -- 地图
RespLoginRoleInfoMsg.prof = 0; -- 职业
RespLoginRoleInfoMsg.level = 0; -- 等级
RespLoginRoleInfoMsg.fight = 0; -- 战斗力
RespLoginRoleInfoMsg.vipLevel = 0; -- VIP等级
RespLoginRoleInfoMsg.lastLoginTime = 0; -- 上次登录时间,秒
RespLoginRoleInfoMsg.icon = 0; -- 头像
RespLoginRoleInfoMsg.arms = 0; -- 武器
RespLoginRoleInfoMsg.dress = 0; -- 衣服
RespLoginRoleInfoMsg.fashionshead = 0; -- 时装头
RespLoginRoleInfoMsg.fashionsarms = 0; -- 时装武器
RespLoginRoleInfoMsg.fashionsdress = 0; -- 时装衣服
RespLoginRoleInfoMsg.wuhun = 0; -- 武魂
RespLoginRoleInfoMsg.wing = 0; -- 翅膀
RespLoginRoleInfoMsg.suitflag = 0; -- 套装标识
RespLoginRoleInfoMsg.shenwuId = 0; -- 神武ID
RespLoginRoleInfoMsg.shoulder = 0; -- 肩膀



RespLoginRoleInfoMsg.meta = {__index = RespLoginRoleInfoMsg};
function RespLoginRoleInfoMsg:new()
	local obj = setmetatable( {}, RespLoginRoleInfoMsg.meta);
	return obj;
end

function RespLoginRoleInfoMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.roleName, idx = readString(pak, idx, 32);
	self.mapId, idx = readInt(pak, idx);
	self.prof, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);
	self.fight, idx = readInt(pak, idx);
	self.vipLevel, idx = readInt(pak, idx);
	self.lastLoginTime, idx = readInt64(pak, idx);
	self.icon, idx = readInt(pak, idx);
	self.arms, idx = readInt(pak, idx);
	self.dress, idx = readInt(pak, idx);
	self.fashionshead, idx = readInt(pak, idx);
	self.fashionsarms, idx = readInt(pak, idx);
	self.fashionsdress, idx = readInt(pak, idx);
	self.wuhun, idx = readInt(pak, idx);
	self.wing, idx = readInt(pak, idx);
	self.suitflag, idx = readInt(pak, idx);
	self.shenwuId, idx = readByte(pak, idx);
	self.shoulder, idx = readInt(pak, idx);

end



--[[
返回关闭链接
]]

_G.RespCloseLinkMsg = {};

RespCloseLinkMsg.msgId = 6004;
RespCloseLinkMsg.reason = 0; -- 关闭原因 1:顶号 2:封停 3:GM踢人  4:禁言
RespCloseLinkMsg.param = 0; -- 封停时间(s)



RespCloseLinkMsg.meta = {__index = RespCloseLinkMsg};
function RespCloseLinkMsg:new()
	local obj = setmetatable( {}, RespCloseLinkMsg.meta);
	return obj;
end

function RespCloseLinkMsg:ParseData(pak)
	local idx = 1;

	self.reason, idx = readInt(pak, idx);
	self.param, idx = readInt(pak, idx);

end



--[[
登录返回
]]

_G.RespConnSrvTXMsg = {};

RespConnSrvTXMsg.msgId = 6005;
RespConnSrvTXMsg.resultCode = 0; -- 返回：0:OK -1:Create Role -2TX登录失败 -4:封停 -5:协议不一致 -6:MAC封禁
RespConnSrvTXMsg.txCode = 0; -- 如果是TX接口失败,返回TX的错误码
RespConnSrvTXMsg.accountID = ""; -- 登录账户ID
RespConnSrvTXMsg.guid = ""; -- guid
RespConnSrvTXMsg.forbbidenTime = 0; -- 封停时间
RespConnSrvTXMsg.serverTime = 0; -- 服务器时间,秒



RespConnSrvTXMsg.meta = {__index = RespConnSrvTXMsg};
function RespConnSrvTXMsg:new()
	local obj = setmetatable( {}, RespConnSrvTXMsg.meta);
	return obj;
end

function RespConnSrvTXMsg:ParseData(pak)
	local idx = 1;

	self.resultCode, idx = readInt(pak, idx);
	self.txCode, idx = readInt(pak, idx);
	self.accountID, idx = readString(pak, idx, 64);
	self.guid, idx = readGuid(pak, idx);
	self.forbbidenTime, idx = readInt(pak, idx);
	self.serverTime, idx = readInt64(pak, idx);

end



--[[
服务端通知: 收到聊天
]]

_G.RespChatMsg = {};

RespChatMsg.msgId = 7002;
RespChatMsg.senderID = ""; -- 发送者ID
RespChatMsg.senderName = ""; -- 发送者名字
RespChatMsg.senderTeamId = ""; -- 发送者队伍id
RespChatMsg.senderGuildId = ""; -- 发送者帮派id
RespChatMsg.senderGuildPos = 0; -- 发送者帮派职务
RespChatMsg.senderVIP = 0; -- 发送者VIP信息，按位存，前三位依次表示钻石、黄金、白银VIP是否开通，后29位存vip等级
RespChatMsg.senderLvl = 0; -- 发送者等级
RespChatMsg.senderIcon = 0; -- 发送者头像
RespChatMsg.senderFlag = 0; -- 发送者标示
RespChatMsg.senderCityPos = 0; -- 发送者王城职位
RespChatMsg.senderVflag = 0; -- 发送者V计划标示
RespChatMsg.senderIsGM = 0; -- 是否GM标示
RespChatMsg.sendTime = 0; -- 发送时间
RespChatMsg.hornId = 0; -- 喇叭时,喇叭id
RespChatMsg.channel = 0; -- 频道
RespChatMsg.text = ""; -- 内容



RespChatMsg.meta = {__index = RespChatMsg};
function RespChatMsg:new()
	local obj = setmetatable( {}, RespChatMsg.meta);
	return obj;
end

function RespChatMsg:ParseData(pak)
	local idx = 1;

	self.senderID, idx = readGuid(pak, idx);
	self.senderName, idx = readString(pak, idx, 32);
	self.senderTeamId, idx = readGuid(pak, idx);
	self.senderGuildId, idx = readGuid(pak, idx);
	self.senderGuildPos, idx = readByte(pak, idx);
	self.senderVIP, idx = readInt(pak, idx);
	self.senderLvl, idx = readInt(pak, idx);
	self.senderIcon, idx = readByte(pak, idx);
	self.senderFlag, idx = readInt(pak, idx);
	self.senderCityPos, idx = readByte(pak, idx);
	self.senderVflag, idx = readInt(pak, idx);
	self.senderIsGM, idx = readByte(pak, idx);
	self.sendTime, idx = readInt64(pak, idx);
	self.hornId, idx = readInt(pak, idx);
	self.channel, idx = readInt(pak, idx);
	self.text, idx = readString(pak, idx);

end



--[[
服务端通知: 收到私聊通知
]]

_G.RespPrivateChatNoticetMsg = {};

RespPrivateChatNoticetMsg.msgId = 7003;
RespPrivateChatNoticetMsg.senderID = ""; -- 发送者ID
RespPrivateChatNoticetMsg.senderName = ""; -- 发送者名字
RespPrivateChatNoticetMsg.num = 0; -- 未读私聊数量
RespPrivateChatNoticetMsg.senderVIP = 0; -- 发送者VIP等级
RespPrivateChatNoticetMsg.senderLvl = 0; -- 发送者等级
RespPrivateChatNoticetMsg.senderIcon = 0; -- 发送者头像



RespPrivateChatNoticetMsg.meta = {__index = RespPrivateChatNoticetMsg};
function RespPrivateChatNoticetMsg:new()
	local obj = setmetatable( {}, RespPrivateChatNoticetMsg.meta);
	return obj;
end

function RespPrivateChatNoticetMsg:ParseData(pak)
	local idx = 1;

	self.senderID, idx = readGuid(pak, idx);
	self.senderName, idx = readString(pak, idx, 32);
	self.num, idx = readInt(pak, idx);
	self.senderVIP, idx = readByte(pak, idx);
	self.senderLvl, idx = readInt(pak, idx);
	self.senderIcon, idx = readByte(pak, idx);

end



--[[
服务端通知:聊天,系统通知
]]

_G.RespChatSysNoticeMsg = {};

RespChatSysNoticeMsg.msgId = 7005;
RespChatSysNoticeMsg.id = 0; -- id
RespChatSysNoticeMsg.param = ""; -- 参数



RespChatSysNoticeMsg.meta = {__index = RespChatSysNoticeMsg};
function RespChatSysNoticeMsg:new()
	local obj = setmetatable( {}, RespChatSysNoticeMsg.meta);
	return obj;
end

function RespChatSysNoticeMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.param, idx = readString(pak, idx);

end



--[[
服务端通知:公告
]]

_G.RespNoticeMsg = {};

RespNoticeMsg.msgId = 7006;
RespNoticeMsg.id = 0; -- 公告id
RespNoticeMsg.param = ""; -- 公告参数



RespNoticeMsg.meta = {__index = RespNoticeMsg};
function RespNoticeMsg:new()
	local obj = setmetatable( {}, RespNoticeMsg.meta);
	return obj;
end

function RespNoticeMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.param, idx = readString(pak, idx);

end



--[[
服务端通知:返回队伍信息(登录时推一次)
]]

_G.RespTeamInfoMsg = {};

RespTeamInfoMsg.msgId = 7007;
RespTeamInfoMsg.teamId = ""; -- 队伍id
RespTeamInfoMsg.roleList_size = 0; -- 成员列表 size
RespTeamInfoMsg.roleList = {}; -- 成员列表 list



--[[
TeamRoleVO = {
	roleID = ""; -- 角色ID
	roleName = ""; -- 角色名字
	line = 0; -- 线
	mapId = 0; -- 地图
	prof = 0; -- 职业
	level = 0; -- 等级
	hp = 0; -- hp
	maxHp = 0; -- maxHP
	mp = 0; -- mp
	maxMp = 0; -- maxMp
	fight = 0; -- 战斗力
	guildName = ""; -- 帮会名
	teamPos = 0; -- 职位,0成员,1队长
	online = 0; -- 在线状态
	iconID = 0; -- 玩家头像
	arms = 0; -- 武器
	dress = 0; -- 衣服
	fashionshead = 0; -- 时装头
	fashionsarms = 0; -- 时装武器
	fashionsdress = 0; -- 时装衣服
	wuhunId = 0; -- 武魂id
	wing = 0; -- 翅膀
	suitflag = 0; -- 套装标识
	vipLevel = 0; -- VIP等级
	roomType = 0; -- 准备状态 0 true 
}
]]

RespTeamInfoMsg.meta = {__index = RespTeamInfoMsg};
function RespTeamInfoMsg:new()
	local obj = setmetatable( {}, RespTeamInfoMsg.meta);
	return obj;
end

function RespTeamInfoMsg:ParseData(pak)
	local idx = 1;

	self.teamId, idx = readGuid(pak, idx);

	local list1 = {};
	self.roleList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local TeamRoleVo = {};
		TeamRoleVo.roleID, idx = readGuid(pak, idx);
		TeamRoleVo.roleName, idx = readString(pak, idx, 32);
		TeamRoleVo.line, idx = readInt(pak, idx);
		TeamRoleVo.mapId, idx = readInt(pak, idx);
		TeamRoleVo.prof, idx = readInt(pak, idx);
		TeamRoleVo.level, idx = readInt(pak, idx);
		TeamRoleVo.hp, idx = readInt(pak, idx);
		TeamRoleVo.maxHp, idx = readInt(pak, idx);
		TeamRoleVo.mp, idx = readInt(pak, idx);
		TeamRoleVo.maxMp, idx = readInt(pak, idx);
		TeamRoleVo.fight, idx = readInt64(pak, idx);
		TeamRoleVo.guildName, idx = readString(pak, idx, 32);
		TeamRoleVo.teamPos, idx = readByte(pak, idx);
		TeamRoleVo.online, idx = readByte(pak, idx);
		TeamRoleVo.iconID, idx = readInt(pak, idx);
		TeamRoleVo.arms, idx = readInt(pak, idx);
		TeamRoleVo.dress, idx = readInt(pak, idx);
		TeamRoleVo.fashionshead, idx = readInt(pak, idx);
		TeamRoleVo.fashionsarms, idx = readInt(pak, idx);
		TeamRoleVo.fashionsdress, idx = readInt(pak, idx);
		TeamRoleVo.wuhunId, idx = readInt(pak, idx);
		TeamRoleVo.wing, idx = readInt(pak, idx);
		TeamRoleVo.suitflag, idx = readInt(pak, idx);
		TeamRoleVo.vipLevel, idx = readInt(pak, idx);
		TeamRoleVo.roomType, idx = readInt(pak, idx);
		table.push(list1,TeamRoleVo);
	end

end



--[[
服务端通知: 广播,有人进入队伍
]]

_G.RespTeamJoinMsg = {};

RespTeamJoinMsg.msgId = 7014;
RespTeamJoinMsg.teamId = ""; -- 队伍id
RespTeamJoinMsg.roleID = ""; -- 角色ID
RespTeamJoinMsg.roleName = ""; -- 角色名字
RespTeamJoinMsg.line = 0; -- 线
RespTeamJoinMsg.mapId = 0; -- 地图
RespTeamJoinMsg.prof = 0; -- 职业
RespTeamJoinMsg.level = 0; -- 等级
RespTeamJoinMsg.hp = 0; -- hp
RespTeamJoinMsg.maxHp = 0; -- maxHP
RespTeamJoinMsg.mp = 0; -- mp
RespTeamJoinMsg.maxMp = 0; -- maxMp
RespTeamJoinMsg.fight = 0; -- 战斗力
RespTeamJoinMsg.guildName = ""; -- 帮会名,无帮会则发空字符串
RespTeamJoinMsg.teamPos = 0; -- 职位,0成员,1队长
RespTeamJoinMsg.online = 0; -- 在线状态1:在线, 0:不在线
RespTeamJoinMsg.iconID = 0; -- 玩家头像
RespTeamJoinMsg.arms = 0; -- 武器
RespTeamJoinMsg.dress = 0; -- 衣服
RespTeamJoinMsg.fashionshead = 0; -- 时装头
RespTeamJoinMsg.fashionsarms = 0; -- 时装武器
RespTeamJoinMsg.fashionsdress = 0; -- 时装衣服
RespTeamJoinMsg.wuhunId = 0; -- 武魂id
RespTeamJoinMsg.wing = 0; -- 翅膀
RespTeamJoinMsg.suitflag = 0; -- 套装标识
RespTeamJoinMsg.vipLevel = 0; -- VIP等级
RespTeamJoinMsg.roomType = 0; -- 准备状态 0 true 



RespTeamJoinMsg.meta = {__index = RespTeamJoinMsg};
function RespTeamJoinMsg:new()
	local obj = setmetatable( {}, RespTeamJoinMsg.meta);
	return obj;
end

function RespTeamJoinMsg:ParseData(pak)
	local idx = 1;

	self.teamId, idx = readGuid(pak, idx);
	self.roleID, idx = readGuid(pak, idx);
	self.roleName, idx = readString(pak, idx, 32);
	self.line, idx = readInt(pak, idx);
	self.mapId, idx = readInt(pak, idx);
	self.prof, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);
	self.hp, idx = readInt(pak, idx);
	self.maxHp, idx = readInt(pak, idx);
	self.mp, idx = readInt(pak, idx);
	self.maxMp, idx = readInt(pak, idx);
	self.fight, idx = readInt64(pak, idx);
	self.guildName, idx = readString(pak, idx, 32);
	self.teamPos, idx = readByte(pak, idx);
	self.online, idx = readByte(pak, idx);
	self.iconID, idx = readInt(pak, idx);
	self.arms, idx = readInt(pak, idx);
	self.dress, idx = readInt(pak, idx);
	self.fashionshead, idx = readInt(pak, idx);
	self.fashionsarms, idx = readInt(pak, idx);
	self.fashionsdress, idx = readInt(pak, idx);
	self.wuhunId, idx = readInt(pak, idx);
	self.wing, idx = readInt(pak, idx);
	self.suitflag, idx = readInt(pak, idx);
	self.vipLevel, idx = readInt(pak, idx);
	self.roomType, idx = readInt(pak, idx);

end



--[[
服务端通知: 广播,队伍成员信息变化
]]

_G.RespTeamUpdateMsg = {};

RespTeamUpdateMsg.msgId = 7015;
RespTeamUpdateMsg.roleID = ""; -- 角色ID
RespTeamUpdateMsg.roleName = ""; -- 角色名字
RespTeamUpdateMsg.line = 0; -- 线
RespTeamUpdateMsg.mapId = 0; -- 地图
RespTeamUpdateMsg.prof = 0; -- 职业
RespTeamUpdateMsg.level = 0; -- 等级
RespTeamUpdateMsg.guildName = ""; -- 帮会名
RespTeamUpdateMsg.teamPos = 0; -- 职位,0成员,1队长
RespTeamUpdateMsg.online = 0; -- 在线状态
RespTeamUpdateMsg.iconID = 0; -- 玩家头像
RespTeamUpdateMsg.arms = 0; -- 武器
RespTeamUpdateMsg.dress = 0; -- 衣服
RespTeamUpdateMsg.fashionshead = 0; -- 时装头
RespTeamUpdateMsg.fashionsarms = 0; -- 时装武器
RespTeamUpdateMsg.fashionsdress = 0; -- 时装衣服
RespTeamUpdateMsg.wuhunId = 0; -- 武魂id
RespTeamUpdateMsg.wing = 0; -- 翅膀
RespTeamUpdateMsg.suitflag = 0; -- 套装标识
RespTeamUpdateMsg.vipLevel = 0; -- VIP等级
RespTeamUpdateMsg.roomType = 0; -- 准备状态 0 true 



RespTeamUpdateMsg.meta = {__index = RespTeamUpdateMsg};
function RespTeamUpdateMsg:new()
	local obj = setmetatable( {}, RespTeamUpdateMsg.meta);
	return obj;
end

function RespTeamUpdateMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.roleName, idx = readString(pak, idx, 32);
	self.line, idx = readInt(pak, idx);
	self.mapId, idx = readInt(pak, idx);
	self.prof, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);
	self.guildName, idx = readString(pak, idx, 32);
	self.teamPos, idx = readByte(pak, idx);
	self.online, idx = readByte(pak, idx);
	self.iconID, idx = readInt(pak, idx);
	self.arms, idx = readInt(pak, idx);
	self.dress, idx = readInt(pak, idx);
	self.fashionshead, idx = readInt(pak, idx);
	self.fashionsarms, idx = readInt(pak, idx);
	self.fashionsdress, idx = readInt(pak, idx);
	self.wuhunId, idx = readInt(pak, idx);
	self.wing, idx = readInt(pak, idx);
	self.suitflag, idx = readInt(pak, idx);
	self.vipLevel, idx = readInt(pak, idx);
	self.roomType, idx = readInt(pak, idx);

end



--[[
服务端通知: 广播,有人退出队伍
]]

_G.RespTeamExitMsg = {};

RespTeamExitMsg.msgId = 7016;
RespTeamExitMsg.roleID = ""; -- 角色ID



RespTeamExitMsg.meta = {__index = RespTeamExitMsg};
function RespTeamExitMsg:new()
	local obj = setmetatable( {}, RespTeamExitMsg.meta);
	return obj;
end

function RespTeamExitMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);

end



--[[
服务端通知: 入队请求(仅队长)
]]

_G.RespTeamJoinRequestMsg = {};

RespTeamJoinRequestMsg.msgId = 7017;
RespTeamJoinRequestMsg.roleID = ""; -- 角色ID
RespTeamJoinRequestMsg.roleName = ""; -- 角色名字



RespTeamJoinRequestMsg.meta = {__index = RespTeamJoinRequestMsg};
function RespTeamJoinRequestMsg:new()
	local obj = setmetatable( {}, RespTeamJoinRequestMsg.meta);
	return obj;
end

function RespTeamJoinRequestMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.roleName, idx = readString(pak, idx, 32);

end



--[[
服务端通知: 入队邀请
]]

_G.RespTeamInviteRequestMsg = {};

RespTeamInviteRequestMsg.msgId = 7018;
RespTeamInviteRequestMsg.teamId = ""; -- 队伍id
RespTeamInviteRequestMsg.leaderName = ""; -- 队长名字



RespTeamInviteRequestMsg.meta = {__index = RespTeamInviteRequestMsg};
function RespTeamInviteRequestMsg:new()
	local obj = setmetatable( {}, RespTeamInviteRequestMsg.meta);
	return obj;
end

function RespTeamInviteRequestMsg:ParseData(pak)
	local idx = 1;

	self.teamId, idx = readGuid(pak, idx);
	self.leaderName, idx = readString(pak, idx, 32);

end



--[[
服务端通知:返回附近队伍
]]

_G.RespTeamNearbyTeamMsg = {};

RespTeamNearbyTeamMsg.msgId = 7020;
RespTeamNearbyTeamMsg.teamList_size = 0; -- 队伍列表 size
RespTeamNearbyTeamMsg.teamList = {}; -- 队伍列表 list



--[[
TeamListVO = {
	teamId = ""; -- 队伍id
	leaderName = ""; -- 队长名字
	maxRoleLevel = 0; -- 最高等级
	averageRoleLevel = 0; -- 平均等级
	maxRoleFight = 0; -- 最高战斗力
	averageRoleFight = 0; -- 平均战斗力
	roleNum = 0; -- 成员数量
}
]]

RespTeamNearbyTeamMsg.meta = {__index = RespTeamNearbyTeamMsg};
function RespTeamNearbyTeamMsg:new()
	local obj = setmetatable( {}, RespTeamNearbyTeamMsg.meta);
	return obj;
end

function RespTeamNearbyTeamMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.teamList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local TeamListVo = {};
		TeamListVo.teamId, idx = readGuid(pak, idx);
		TeamListVo.leaderName, idx = readString(pak, idx, 32);
		TeamListVo.maxRoleLevel, idx = readInt(pak, idx);
		TeamListVo.averageRoleLevel, idx = readInt(pak, idx);
		TeamListVo.maxRoleFight, idx = readInt64(pak, idx);
		TeamListVo.averageRoleFight, idx = readInt64(pak, idx);
		TeamListVo.roleNum, idx = readInt(pak, idx);
		table.push(list1,TeamListVo);
	end

end



--[[
服务端通知:返回附近玩家
]]

_G.RespTeamNearbyRoleMsg = {};

RespTeamNearbyRoleMsg.msgId = 7021;
RespTeamNearbyRoleMsg.roleList_size = 0; -- 列表 size
RespTeamNearbyRoleMsg.roleList = {}; -- 列表 list



--[[
TeamNearbyRoleVO = {
	roleID = ""; -- 角色ID
	roleName = ""; -- 角色名字
	level = 0; -- 等级
	prof = 0; -- 职业
	teamState = 0; -- 组队状态,0未组队,1已组队
	guildName = ""; -- 帮派名
	fight = 0; -- 战斗力
}
]]

RespTeamNearbyRoleMsg.meta = {__index = RespTeamNearbyRoleMsg};
function RespTeamNearbyRoleMsg:new()
	local obj = setmetatable( {}, RespTeamNearbyRoleMsg.meta);
	return obj;
end

function RespTeamNearbyRoleMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.roleList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local TeamNearbyRoleVo = {};
		TeamNearbyRoleVo.roleID, idx = readGuid(pak, idx);
		TeamNearbyRoleVo.roleName, idx = readString(pak, idx, 32);
		TeamNearbyRoleVo.level, idx = readInt(pak, idx);
		TeamNearbyRoleVo.prof, idx = readInt(pak, idx);
		TeamNearbyRoleVo.teamState, idx = readInt(pak, idx);
		TeamNearbyRoleVo.guildName, idx = readString(pak, idx, 32);
		TeamNearbyRoleVo.fight, idx = readInt(pak, idx);
		table.push(list1,TeamNearbyRoleVo);
	end

end



--[[
服务端返回换线结果
]]

_G.RespSwitchLineRetMsg = {};

RespSwitchLineRetMsg.msgId = 7023;
RespSwitchLineRetMsg.result = 0; -- 0成功, -1:已在当前线 -2:线不存在 -3:地图类型错误 -4:战斗状态中 -5组队确认状态 -6:跨服匹配状态
RespSwitchLineRetMsg.lineID = 0; -- 



RespSwitchLineRetMsg.meta = {__index = RespSwitchLineRetMsg};
function RespSwitchLineRetMsg:new()
	local obj = setmetatable( {}, RespSwitchLineRetMsg.meta);
	return obj;
end

function RespSwitchLineRetMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.lineID, idx = readInt(pak, idx);

end



--[[
服务端返回线列表
]]

_G.RespLineListRetMsg = {};

RespLineListRetMsg.msgId = 7024;
RespLineListRetMsg.lineList_size = 0; -- 列表 size
RespLineListRetMsg.lineList = {}; -- 列表 list



--[[
LineVoVO = {
	lineID = 0; -- 
}
]]

RespLineListRetMsg.meta = {__index = RespLineListRetMsg};
function RespLineListRetMsg:new()
	local obj = setmetatable( {}, RespLineListRetMsg.meta);
	return obj;
end

function RespLineListRetMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.lineList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local LineVoVo = {};
		LineVoVo.lineID, idx = readInt(pak, idx);
		table.push(list1,LineVoVo);
	end

end



--[[
服务端通知: 广播,队伍成员(hp, mp)更新
]]

_G.RespTeamRoleUpdateInfoMsg = {};

RespTeamRoleUpdateInfoMsg.msgId = 7025;
RespTeamRoleUpdateInfoMsg.roleID = ""; -- 角色ID
RespTeamRoleUpdateInfoMsg.hp = 0; -- hp
RespTeamRoleUpdateInfoMsg.maxHp = 0; -- maxHP
RespTeamRoleUpdateInfoMsg.mp = 0; -- mp
RespTeamRoleUpdateInfoMsg.maxMp = 0; -- maxMp
RespTeamRoleUpdateInfoMsg.fight = 0; -- 战斗力



RespTeamRoleUpdateInfoMsg.meta = {__index = RespTeamRoleUpdateInfoMsg};
function RespTeamRoleUpdateInfoMsg:new()
	local obj = setmetatable( {}, RespTeamRoleUpdateInfoMsg.meta);
	return obj;
end

function RespTeamRoleUpdateInfoMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.hp, idx = readInt(pak, idx);
	self.maxHp, idx = readInt(pak, idx);
	self.mp, idx = readInt(pak, idx);
	self.maxMp, idx = readInt(pak, idx);
	self.fight, idx = readInt64(pak, idx);

end



--[[
添加好友请求返回
]]

_G.RespAddFriendTarget = {};

RespAddFriendTarget.msgId = 7027;
RespAddFriendTarget.roleID = ""; -- 角色ID
RespAddFriendTarget.roleName = ""; -- 角色名称
RespAddFriendTarget.level = 0; -- 等级



RespAddFriendTarget.meta = {__index = RespAddFriendTarget};
function RespAddFriendTarget:new()
	local obj = setmetatable( {}, RespAddFriendTarget.meta);
	return obj;
end

function RespAddFriendTarget:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.roleName, idx = readString(pak, idx, 32);
	self.level, idx = readInt(pak, idx);

end



--[[
关系列表
]]

_G.RespRelationList = {};

RespRelationList.msgId = 7028;
RespRelationList.RelationList_size = 0; -- 列表 size
RespRelationList.RelationList = {}; -- 列表 list



--[[
RelationVoVO = {
	roleID = ""; -- 角色ID
	relationFlag = 0; -- 关系标识
	roleName = ""; -- 角色名称
	relationDegree = 0; -- 亲密度
	beKillNum = 0; -- 被杀次数
	level = 0; -- 等级
	iconID = 0; -- 玩家头像
	vipLevel = 0; -- VIP等级
	onlinestatus = 0; -- 在线状态 0 - 玩家不在线， 1 - 玩家在线， 2 - 三天未登陆
	teamId = ""; -- 队伍id
	guildId = ""; -- 帮派id
	guildPos = 0; -- 帮派职务
	recentTime = 0; -- 最近联系时间
	killTime = 0; -- 击杀时间
	txhflag = 0; -- 黄钻标识
}
]]

RespRelationList.meta = {__index = RespRelationList};
function RespRelationList:new()
	local obj = setmetatable( {}, RespRelationList.meta);
	return obj;
end

function RespRelationList:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.RelationList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RelationVoVo = {};
		RelationVoVo.roleID, idx = readGuid(pak, idx);
		RelationVoVo.relationFlag, idx = readByte(pak, idx);
		RelationVoVo.roleName, idx = readString(pak, idx, 32);
		RelationVoVo.relationDegree, idx = readInt(pak, idx);
		RelationVoVo.beKillNum, idx = readInt(pak, idx);
		RelationVoVo.level, idx = readInt(pak, idx);
		RelationVoVo.iconID, idx = readInt(pak, idx);
		RelationVoVo.vipLevel, idx = readInt(pak, idx);
		RelationVoVo.onlinestatus, idx = readByte(pak, idx);
		RelationVoVo.teamId, idx = readGuid(pak, idx);
		RelationVoVo.guildId, idx = readGuid(pak, idx);
		RelationVoVo.guildPos, idx = readByte(pak, idx);
		RelationVoVo.recentTime, idx = readInt64(pak, idx);
		RelationVoVo.killTime, idx = readInt64(pak, idx);
		RelationVoVo.txhflag, idx = readInt(pak, idx);
		table.push(list1,RelationVoVo);
	end

end



--[[
删除关系返回
]]

_G.RespRemoveRelation = {};

RespRemoveRelation.msgId = 7029;
RespRemoveRelation.RemoveRelationList_size = 0; -- 列表 size
RespRemoveRelation.RemoveRelationList = {}; -- 列表 list



--[[
RemoveRelationVoVO = {
	roleID = ""; -- 角色ID
	relationType = 0; -- 关系类型 好友1, 仇人2, 黑名单3, 最近联系人4
}
]]

RespRemoveRelation.meta = {__index = RespRemoveRelation};
function RespRemoveRelation:new()
	local obj = setmetatable( {}, RespRemoveRelation.meta);
	return obj;
end

function RespRemoveRelation:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.RemoveRelationList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RemoveRelationVoVo = {};
		RemoveRelationVoVo.roleID, idx = readGuid(pak, idx);
		RemoveRelationVoVo.relationType, idx = readByte(pak, idx);
		table.push(list1,RemoveRelationVoVo);
	end

end



--[[
返回推荐好友列表
]]

_G.RespRecommendList = {};

RespRecommendList.msgId = 7030;
RespRecommendList.RecommendList_size = 0; -- 列表 size
RespRecommendList.RecommendList = {}; -- 列表 list



--[[
RecommendListVoVO = {
	roleID = ""; -- 角色ID
	roleName = ""; -- 角色名称ID
	level = 0; -- 等级
	iconID = 0; -- 玩家头像
	vipLevel = 0; -- VIP等级
}
]]

RespRecommendList.meta = {__index = RespRecommendList};
function RespRecommendList:new()
	local obj = setmetatable( {}, RespRecommendList.meta);
	return obj;
end

function RespRecommendList:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.RecommendList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RecommendListVoVo = {};
		RecommendListVoVo.roleID, idx = readGuid(pak, idx);
		RecommendListVoVo.roleName, idx = readString(pak, idx, 32);
		RecommendListVoVo.level, idx = readInt(pak, idx);
		RecommendListVoVo.iconID, idx = readInt(pak, idx);
		RecommendListVoVo.vipLevel, idx = readInt(pak, idx);
		table.push(list1,RecommendListVoVo);
	end

end



--[[
更新在线状态
]]

_G.RespRelationOnLineStatus = {};

RespRelationOnLineStatus.msgId = 7031;
RespRelationOnLineStatus.RelationList_size = 0; -- 列表 size
RespRelationOnLineStatus.RelationList = {}; -- 列表 list



--[[
RelationVoVO = {
	roleID = ""; -- 角色ID
	onlinestatus = 0; -- 在线状态 0 - 玩家不在线， 1 - 玩家在线， 2 - 三天未登陆
}
]]

RespRelationOnLineStatus.meta = {__index = RespRelationOnLineStatus};
function RespRelationOnLineStatus:new()
	local obj = setmetatable( {}, RespRelationOnLineStatus.meta);
	return obj;
end

function RespRelationOnLineStatus:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.RelationList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RelationVoVo = {};
		RelationVoVo.roleID, idx = readGuid(pak, idx);
		RelationVoVo.onlinestatus, idx = readByte(pak, idx);
		table.push(list1,RelationVoVo);
	end

end



--[[
返回邮件列表
]]

_G.RespGetMailResult = {};

RespGetMailResult.msgId = 7032;
RespGetMailResult.MailList_size = 0; --  size
RespGetMailResult.MailList = {}; --  list



--[[
MailVoVO = {
	mailid = ""; -- 邮件id
	read = 0; -- 是否读过 0 - 未读， 1 - 已读
	item = 0; -- 是否领取过附件0 - 没有附件， 1 - 未领取附件， 2 - 已领取附件
	sendTime = 0; -- 发件时间
	leftTime = 0; -- 剩余时间
	mailtitle = ""; -- 邮件标题
	mailTxtId = 0; -- 配表id
}
]]

RespGetMailResult.meta = {__index = RespGetMailResult};
function RespGetMailResult:new()
	local obj = setmetatable( {}, RespGetMailResult.meta);
	return obj;
end

function RespGetMailResult:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.MailList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local MailVoVo = {};
		MailVoVo.mailid, idx = readGuid(pak, idx);
		MailVoVo.read, idx = readByte(pak, idx);
		MailVoVo.item, idx = readByte(pak, idx);
		MailVoVo.sendTime, idx = readInt64(pak, idx);
		MailVoVo.leftTime, idx = readInt64(pak, idx);
		MailVoVo.mailtitle, idx = readString(pak, idx, 50);
		MailVoVo.mailTxtId, idx = readInt(pak, idx);
		table.push(list1,MailVoVo);
	end

end



--[[
返回打开邮件
]]

_G.RespOpenResult = {};

RespOpenResult.msgId = 7033;
RespOpenResult.mailid = ""; -- 邮件id
RespOpenResult.item = 0; -- 是否领取过附件0 - 没有领取附件， 1 - 已领取附件
RespOpenResult.mailcontnet = ""; -- 邮件内容 type=1 'param1:type1,param2:type2' 
RespOpenResult.MailItemList_size = 8; -- 物品列表 size
RespOpenResult.MailItemList = {}; -- 物品列表 list



--[[
MailItemVoVO = {
	itemid = 0; -- 附件物品id
	itemcount = 0; -- 附件物品数量
}
]]

RespOpenResult.meta = {__index = RespOpenResult};
function RespOpenResult:new()
	local obj = setmetatable( {}, RespOpenResult.meta);
	return obj;
end

function RespOpenResult:ParseData(pak)
	local idx = 1;

	self.mailid, idx = readGuid(pak, idx);
	self.item, idx = readByte(pak, idx);
	self.mailcontnet, idx = readString(pak, idx, 512);

	local list1 = {};
	self.MailItemList = list1;
	local list1Size = 8;

	for i=1,list1Size do
		local MailItemVoVo = {};
		MailItemVoVo.itemid, idx = readInt(pak, idx);
		MailItemVoVo.itemcount, idx = readInt64(pak, idx);
		table.push(list1,MailItemVoVo);
	end

end



--[[
请求领取附件返回
]]

_G.RespMailItemResult = {};

RespMailItemResult.msgId = 7034;
RespMailItemResult.MailList_size = 0; --  size
RespMailItemResult.MailList = {}; --  list



--[[
MailRespItemVoVO = {
	mailid = ""; -- 邮件id
	result = 0; -- 领取邮件附件结果 0- 成功 1-失败
}
]]

RespMailItemResult.meta = {__index = RespMailItemResult};
function RespMailItemResult:new()
	local obj = setmetatable( {}, RespMailItemResult.meta);
	return obj;
end

function RespMailItemResult:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.MailList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local MailRespItemVoVo = {};
		MailRespItemVoVo.mailid, idx = readGuid(pak, idx);
		MailRespItemVoVo.result, idx = readByte(pak, idx);
		table.push(list1,MailRespItemVoVo);
	end

end



--[[
请求删除邮件返回
]]

_G.RespDelMail = {};

RespDelMail.msgId = 7035;
RespDelMail.MailList_size = 0; --  size
RespDelMail.MailList = {}; --  list



--[[
RespMailDelVoVO = {
	mailid = ""; -- 邮件id
}
]]

RespDelMail.meta = {__index = RespDelMail};
function RespDelMail:new()
	local obj = setmetatable( {}, RespDelMail.meta);
	return obj;
end

function RespDelMail:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.MailList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RespMailDelVoVo = {};
		RespMailDelVoVo.mailid, idx = readGuid(pak, idx);
		table.push(list1,RespMailDelVoVo);
	end

end



--[[
邮件提醒
]]

_G.RespNotifyMail = {};

RespNotifyMail.msgId = 7036;
RespNotifyMail.mailcount = 0; -- 邮件数量



RespNotifyMail.meta = {__index = RespNotifyMail};
function RespNotifyMail:new()
	local obj = setmetatable( {}, RespNotifyMail.meta);
	return obj;
end

function RespNotifyMail:ParseData(pak)
	local idx = 1;

	self.mailcount, idx = readInt(pak, idx);

end



--[[
更新组队副本确认的队员列表
]]

_G.RespTeamDungeonUpdateMsg = {};

RespTeamDungeonUpdateMsg.msgId = 7037;
RespTeamDungeonUpdateMsg.dungeonId = 0; -- 副本ID
RespTeamDungeonUpdateMsg.line = 0; -- 队长所在线
RespTeamDungeonUpdateMsg.dungeonTeamList_size = 0; -- 更新后的组队副本队员列表 size
RespTeamDungeonUpdateMsg.dungeonTeamList = {}; -- 更新后的组队副本队员列表 list



--[[
DungeonTeamListVO = {
	roleId = ""; -- 玩家guid
	status = 0; -- 玩家状态 0:已同意，1:等待确认中，2:已拒绝
}
]]

RespTeamDungeonUpdateMsg.meta = {__index = RespTeamDungeonUpdateMsg};
function RespTeamDungeonUpdateMsg:new()
	local obj = setmetatable( {}, RespTeamDungeonUpdateMsg.meta);
	return obj;
end

function RespTeamDungeonUpdateMsg:ParseData(pak)
	local idx = 1;

	self.dungeonId, idx = readInt(pak, idx);
	self.line, idx = readInt(pak, idx);

	local list1 = {};
	self.dungeonTeamList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local DungeonTeamListVo = {};
		DungeonTeamListVo.roleId, idx = readGuid(pak, idx);
		DungeonTeamListVo.status, idx = readInt(pak, idx);
		table.push(list1,DungeonTeamListVo);
	end

end



--[[
返回帮派列表
]]

_G.RespGuildList = {};

RespGuildList.msgId = 7038;
RespGuildList.pages = 0; -- 页数
RespGuildList.GuildList_size = 0; -- 帮派列表 size
RespGuildList.GuildList = {}; -- 帮派列表 list



--[[
RespGuildVoVO = {
	guildId = ""; -- 帮派id
	rank = 0; -- 排名
	level = 0; -- 帮派等级
	memCnt = 0; -- 成员数量
	extendNum = 0; -- 扩展人数
	power = 0; -- 战斗力
	applyFlag = 0; -- 申请标识(1-已经申请,0-未申请)
	guildName = ""; -- 帮派名称
	guildMasterName = ""; -- 帮主名称
}
]]

RespGuildList.meta = {__index = RespGuildList};
function RespGuildList:new()
	local obj = setmetatable( {}, RespGuildList.meta);
	return obj;
end

function RespGuildList:ParseData(pak)
	local idx = 1;

	self.pages, idx = readInt(pak, idx);

	local list1 = {};
	self.GuildList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RespGuildVoVo = {};
		RespGuildVoVo.guildId, idx = readGuid(pak, idx);
		RespGuildVoVo.rank, idx = readInt(pak, idx);
		RespGuildVoVo.level, idx = readInt(pak, idx);
		RespGuildVoVo.memCnt, idx = readInt(pak, idx);
		RespGuildVoVo.extendNum, idx = readInt(pak, idx);
		RespGuildVoVo.power, idx = readInt64(pak, idx);
		RespGuildVoVo.applyFlag, idx = readByte(pak, idx);
		RespGuildVoVo.guildName, idx = readString(pak, idx, 32);
		RespGuildVoVo.guildMasterName, idx = readString(pak, idx, 32);
		table.push(list1,RespGuildVoVo);
	end

end



--[[
帮派信息返回
]]

_G.RespMyGuildInfo = {};

RespMyGuildInfo.msgId = 7039;
RespMyGuildInfo.guildId = ""; -- 帮派id
RespMyGuildInfo.alianceGuildId = ""; -- 同盟帮派id
RespMyGuildInfo.rank = 0; -- 排名
RespMyGuildInfo.level = 0; -- 帮派等级
RespMyGuildInfo.memCnt = 0; -- 成员数量
RespMyGuildInfo.extendNum = 0; -- 扩展人数
RespMyGuildInfo.captial = 0; -- 帮派资金
RespMyGuildInfo.liveness = 0; -- 帮派活跃度
RespMyGuildInfo.pos = 0; -- 职位
RespMyGuildInfo.autoagree = 0; -- 0-不自动， 自动档位
RespMyGuildInfo.contribution = 0; -- 当前贡献
RespMyGuildInfo.totalContribution = 0; -- 累计贡献
RespMyGuildInfo.loyalty = 0; -- 忠诚度
RespMyGuildInfo.power = 0; -- 战斗力
RespMyGuildInfo.guildName = ""; -- 帮派名称
RespMyGuildInfo.applynum = 0; -- 申请数量
RespMyGuildInfo.guildMasterName = ""; -- 帮主名称
RespMyGuildInfo.guildNotice = ""; -- 帮派公告
RespMyGuildInfo.GuildResList_size = 3; -- 帮派资源列表 size
RespMyGuildInfo.GuildResList = {}; -- 帮派资源列表 list
RespMyGuildInfo.GuildSkillList_size = 8; -- 帮派技能列表 size
RespMyGuildInfo.GuildSkillList = {}; -- 帮派技能列表 list



--[[
RespGuildResVoVO = {
	itemId = 0; -- 资源ID
	count = 0; -- 数量
}
]]
--[[
RespGuildSkillVoVO = {
	skillId = 0; -- 技能ID
	openFlag = 0; -- 是否开启(1 - 开启， 0 - 未开启)
}
]]

RespMyGuildInfo.meta = {__index = RespMyGuildInfo};
function RespMyGuildInfo:new()
	local obj = setmetatable( {}, RespMyGuildInfo.meta);
	return obj;
end

function RespMyGuildInfo:ParseData(pak)
	local idx = 1;

	self.guildId, idx = readGuid(pak, idx);
	self.alianceGuildId, idx = readGuid(pak, idx);
	self.rank, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);
	self.memCnt, idx = readInt(pak, idx);
	self.extendNum, idx = readInt(pak, idx);
	self.captial, idx = readDouble(pak, idx);
	self.liveness, idx = readInt(pak, idx);
	self.pos, idx = readByte(pak, idx);
	self.autoagree, idx = readByte(pak, idx);
	self.contribution, idx = readInt(pak, idx);
	self.totalContribution, idx = readInt(pak, idx);
	self.loyalty, idx = readInt(pak, idx);
	self.power, idx = readInt64(pak, idx);
	self.guildName, idx = readString(pak, idx, 32);
	self.applynum, idx = readInt(pak, idx);
	self.guildMasterName, idx = readString(pak, idx, 32);
	self.guildNotice, idx = readString(pak, idx, 256);

	local list = {};
	self.GuildResList = list;
	local listSize = 3;

	for i=1,listSize do
		local RespGuildResVoVo = {};
		RespGuildResVoVo.itemId, idx = readInt(pak, idx);
		RespGuildResVoVo.count, idx = readInt(pak, idx);
		table.push(list,RespGuildResVoVo);
	end

	local list = {};
	self.GuildSkillList = list;
	local listSize = 8;

	for i=1,listSize do
		local RespGuildSkillVoVo = {};
		RespGuildSkillVoVo.skillId, idx = readInt(pak, idx);
		RespGuildSkillVoVo.openFlag, idx = readInt(pak, idx);
		table.push(list,RespGuildSkillVoVo);
	end

end



--[[
返回帮派成员列表
]]

_G.RespMyGuildMems = {};

RespMyGuildMems.msgId = 7040;
RespMyGuildMems.timeNow = 0; -- 当前时间
RespMyGuildMems.GuildMemList_size = 0; -- 帮派成员列表 size
RespMyGuildMems.GuildMemList = {}; -- 帮派成员列表 list



--[[
RespGuildMemsVoVO = {
	id = ""; -- Gid
	name = ""; -- 名称
	time = 0; -- 最后登录时间
	jointime = 0; -- 加入帮派时间
	level = 0; -- 等级
	vipLevel = 0; -- VIP等级
	contribute = 0; -- 当前贡献
	allcontribute = 0; -- 累积贡献
	loyalty = 0; -- 忠诚度
	power = 0; -- 战斗力
	pos = 0; -- 职位
	online = 0; -- 1-在线，0-不在线
	iconID = 0; -- 玩家头像
	vflag = 0; -- V计划
	mapid = 0; -- 地图ID
	lineid = 0; -- 线
	txhflag = 0; -- 黄钻标识
}
]]

RespMyGuildMems.meta = {__index = RespMyGuildMems};
function RespMyGuildMems:new()
	local obj = setmetatable( {}, RespMyGuildMems.meta);
	return obj;
end

function RespMyGuildMems:ParseData(pak)
	local idx = 1;

	self.timeNow, idx = readInt64(pak, idx);

	local list1 = {};
	self.GuildMemList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RespGuildMemsVoVo = {};
		RespGuildMemsVoVo.id, idx = readGuid(pak, idx);
		RespGuildMemsVoVo.name, idx = readString(pak, idx, 32);
		RespGuildMemsVoVo.time, idx = readInt64(pak, idx);
		RespGuildMemsVoVo.jointime, idx = readInt64(pak, idx);
		RespGuildMemsVoVo.level, idx = readInt(pak, idx);
		RespGuildMemsVoVo.vipLevel, idx = readInt(pak, idx);
		RespGuildMemsVoVo.contribute, idx = readInt(pak, idx);
		RespGuildMemsVoVo.allcontribute, idx = readInt(pak, idx);
		RespGuildMemsVoVo.loyalty, idx = readInt(pak, idx);
		RespGuildMemsVoVo.power, idx = readInt64(pak, idx);
		RespGuildMemsVoVo.pos, idx = readByte(pak, idx);
		RespGuildMemsVoVo.online, idx = readByte(pak, idx);
		RespGuildMemsVoVo.iconID, idx = readInt(pak, idx);
		RespGuildMemsVoVo.vflag, idx = readInt(pak, idx);
		RespGuildMemsVoVo.mapid, idx = readInt(pak, idx);
		RespGuildMemsVoVo.lineid, idx = readInt(pak, idx);
		RespGuildMemsVoVo.txhflag, idx = readInt(pak, idx);
		table.push(list1,RespGuildMemsVoVo);
	end

end



--[[
返回帮派事件
]]

_G.RespMyGuildEvents = {};

RespMyGuildEvents.msgId = 7041;
RespMyGuildEvents.GuildEventList_size = 0; -- 帮派成员列表 size
RespMyGuildEvents.GuildEventList = {}; -- 帮派成员列表 list



--[[
RespGuildEventVoVO = {
	id = 0; -- 事件ID
	time = 0; -- 时间
	param = ""; -- 参数
}
]]

RespMyGuildEvents.meta = {__index = RespMyGuildEvents};
function RespMyGuildEvents:new()
	local obj = setmetatable( {}, RespMyGuildEvents.meta);
	return obj;
end

function RespMyGuildEvents:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.GuildEventList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RespGuildEventVoVo = {};
		RespGuildEventVoVo.id, idx = readInt(pak, idx);
		RespGuildEventVoVo.time, idx = readInt64(pak, idx);
		RespGuildEventVoVo.param, idx = readString(pak, idx, 64);
		table.push(list1,RespGuildEventVoVo);
	end

end



--[[
创建帮派返回
]]

_G.RespCreateGuildRet = {};

RespCreateGuildRet.msgId = 7042;
RespCreateGuildRet.result = 0; -- 创建帮派返回结果 0- 成功 1-失败



RespCreateGuildRet.meta = {__index = RespCreateGuildRet};
function RespCreateGuildRet:new()
	local obj = setmetatable( {}, RespCreateGuildRet.meta);
	return obj;
end

function RespCreateGuildRet:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
更新帮派信息
]]

_G.RespUpdateGuildInfo = {};

RespUpdateGuildInfo.msgId = 7043;
RespUpdateGuildInfo.guildId = ""; -- 帮派id
RespUpdateGuildInfo.alianceGuildId = ""; -- 同盟帮派id
RespUpdateGuildInfo.rank = 0; -- 排名
RespUpdateGuildInfo.level = 0; -- 帮派等级
RespUpdateGuildInfo.memCnt = 0; -- 成员数量
RespUpdateGuildInfo.extendNum = 0; -- 扩展人数
RespUpdateGuildInfo.captial = 0; -- 帮派资金
RespUpdateGuildInfo.liveness = 0; -- 帮派活跃度
RespUpdateGuildInfo.power = 0; -- 战斗力
RespUpdateGuildInfo.GuildResList_size = 3; -- 帮派资源列表 size
RespUpdateGuildInfo.GuildResList = {}; -- 帮派资源列表 list



--[[
RespGuildResVoVO = {
	itemId = 0; -- 资源ID
	count = 0; -- 数量
}
]]

RespUpdateGuildInfo.meta = {__index = RespUpdateGuildInfo};
function RespUpdateGuildInfo:new()
	local obj = setmetatable( {}, RespUpdateGuildInfo.meta);
	return obj;
end

function RespUpdateGuildInfo:ParseData(pak)
	local idx = 1;

	self.guildId, idx = readGuid(pak, idx);
	self.alianceGuildId, idx = readGuid(pak, idx);
	self.rank, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);
	self.memCnt, idx = readInt(pak, idx);
	self.extendNum, idx = readInt(pak, idx);
	self.captial, idx = readDouble(pak, idx);
	self.liveness, idx = readInt(pak, idx);
	self.power, idx = readInt64(pak, idx);

	local list = {};
	self.GuildResList = list;
	local listSize = 3;

	for i=1,listSize do
		local RespGuildResVoVo = {};
		RespGuildResVoVo.itemId, idx = readInt(pak, idx);
		RespGuildResVoVo.count, idx = readInt(pak, idx);
		table.push(list,RespGuildResVoVo);
	end

end



--[[
更新帮派帮主
]]

_G.RespUpdateGuildMasterName = {};

RespUpdateGuildMasterName.msgId = 7044;
RespUpdateGuildMasterName.guildMasterName = ""; -- 帮主名称



RespUpdateGuildMasterName.meta = {__index = RespUpdateGuildMasterName};
function RespUpdateGuildMasterName:new()
	local obj = setmetatable( {}, RespUpdateGuildMasterName.meta);
	return obj;
end

function RespUpdateGuildMasterName:ParseData(pak)
	local idx = 1;

	self.guildMasterName, idx = readString(pak, idx, 32);

end



--[[
更新帮派公告
]]

_G.RespUpdateGuildNotice = {};

RespUpdateGuildNotice.msgId = 7045;
RespUpdateGuildNotice.guildNotice = ""; -- 帮派公告



RespUpdateGuildNotice.meta = {__index = RespUpdateGuildNotice};
function RespUpdateGuildNotice:new()
	local obj = setmetatable( {}, RespUpdateGuildNotice.meta);
	return obj;
end

function RespUpdateGuildNotice:ParseData(pak)
	local idx = 1;

	self.guildNotice, idx = readString(pak, idx, 256);

end



--[[
返回帮派邀请
]]

_G.ResqBeInvitedGuild = {};

ResqBeInvitedGuild.msgId = 7046;
ResqBeInvitedGuild.name = ""; -- 邀请人名称
ResqBeInvitedGuild.inviterId = ""; -- 邀请人id
ResqBeInvitedGuild.guildName = ""; -- 帮派名称



ResqBeInvitedGuild.meta = {__index = ResqBeInvitedGuild};
function ResqBeInvitedGuild:new()
	local obj = setmetatable( {}, ResqBeInvitedGuild.meta);
	return obj;
end

function ResqBeInvitedGuild:ParseData(pak)
	local idx = 1;

	self.name, idx = readString(pak, idx, 32);
	self.inviterId, idx = readGuid(pak, idx);
	self.guildName, idx = readString(pak, idx, 32);

end



--[[
返回其他帮派信息
]]

_G.RespOtherGuildInfo = {};

RespOtherGuildInfo.msgId = 7047;
RespOtherGuildInfo.guildId = ""; -- 帮派id
RespOtherGuildInfo.rank = 0; -- 排名
RespOtherGuildInfo.level = 0; -- 帮派等级
RespOtherGuildInfo.memCnt = 0; -- 成员数量
RespOtherGuildInfo.extendNum = 0; -- 扩展人数
RespOtherGuildInfo.captial = 0; -- 帮派资金
RespOtherGuildInfo.power = 0; -- 战斗力
RespOtherGuildInfo.guildName = ""; -- 帮派名称
RespOtherGuildInfo.guildMasterName = ""; -- 帮主名称
RespOtherGuildInfo.guildNotice = ""; -- 帮派公告



RespOtherGuildInfo.meta = {__index = RespOtherGuildInfo};
function RespOtherGuildInfo:new()
	local obj = setmetatable( {}, RespOtherGuildInfo.meta);
	return obj;
end

function RespOtherGuildInfo:ParseData(pak)
	local idx = 1;

	self.guildId, idx = readGuid(pak, idx);
	self.rank, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);
	self.memCnt, idx = readInt(pak, idx);
	self.extendNum, idx = readInt(pak, idx);
	self.captial, idx = readDouble(pak, idx);
	self.power, idx = readInt64(pak, idx);
	self.guildName, idx = readString(pak, idx, 32);
	self.guildMasterName, idx = readString(pak, idx, 32);
	self.guildNotice, idx = readString(pak, idx, 256);

end



--[[
返回帮派申请列表
]]

_G.RespMyGuildApplys = {};

RespMyGuildApplys.msgId = 7048;
RespMyGuildApplys.GuildApplysList_size = 0; -- 帮派成员列表 size
RespMyGuildApplys.GuildApplysList = {}; -- 帮派成员列表 list



--[[
RespGuildApplysVoVO = {
	id = ""; -- Gid
	name = ""; -- 名称
	time = 0; -- 申请时间
	level = 0; -- 等级
	power = 0; -- 战斗力
}
]]

RespMyGuildApplys.meta = {__index = RespMyGuildApplys};
function RespMyGuildApplys:new()
	local obj = setmetatable( {}, RespMyGuildApplys.meta);
	return obj;
end

function RespMyGuildApplys:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.GuildApplysList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RespGuildApplysVoVo = {};
		RespGuildApplysVoVo.id, idx = readGuid(pak, idx);
		RespGuildApplysVoVo.name, idx = readString(pak, idx, 32);
		RespGuildApplysVoVo.time, idx = readInt64(pak, idx);
		RespGuildApplysVoVo.level, idx = readInt(pak, idx);
		RespGuildApplysVoVo.power, idx = readInt64(pak, idx);
		table.push(list1,RespGuildApplysVoVo);
	end

end



--[[
申请加入返回帮派
]]

_G.ResqApplyGuild = {};

ResqApplyGuild.msgId = 7049;
ResqApplyGuild.guildId = ""; -- 帮派id
ResqApplyGuild.bApply = 0; -- 0-取消， 1-申请
ResqApplyGuild.applyFlag = 0; -- 申请标识(1-已经申请,0-未申请)



ResqApplyGuild.meta = {__index = ResqApplyGuild};
function ResqApplyGuild:new()
	local obj = setmetatable( {}, ResqApplyGuild.meta);
	return obj;
end

function ResqApplyGuild:ParseData(pak)
	local idx = 1;

	self.guildId, idx = readGuid(pak, idx);
	self.bApply, idx = readByte(pak, idx);
	self.applyFlag, idx = readByte(pak, idx);

end



--[[
审核申请返回
]]

_G.ResqVerifyGuildApply = {};

ResqVerifyGuildApply.msgId = 7050;
ResqVerifyGuildApply.verify = 0; -- 是否同意0 - 同意，1 - 拒绝
ResqVerifyGuildApply.GuildApplyList_size = 0; -- 帮派成员列表 size
ResqVerifyGuildApply.GuildApplyList = {}; -- 帮派成员列表 list



--[[
RespGuildApplyVoVO = {
	memGid = ""; -- 玩家ID
	result = 0; -- 0-成功，1失败
}
]]

ResqVerifyGuildApply.meta = {__index = ResqVerifyGuildApply};
function ResqVerifyGuildApply:new()
	local obj = setmetatable( {}, ResqVerifyGuildApply.meta);
	return obj;
end

function ResqVerifyGuildApply:ParseData(pak)
	local idx = 1;

	self.verify, idx = readInt(pak, idx);

	local list1 = {};
	self.GuildApplyList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RespGuildApplyVoVo = {};
		RespGuildApplyVoVo.memGid, idx = readGuid(pak, idx);
		RespGuildApplyVoVo.result, idx = readByte(pak, idx);
		table.push(list1,RespGuildApplyVoVo);
	end

end



--[[
返回退出帮派
]]

_G.RespQuitGuild = {};

RespQuitGuild.msgId = 7051;
RespQuitGuild.result = 0; -- 0-成功，-1失败



RespQuitGuild.meta = {__index = RespQuitGuild};
function RespQuitGuild:new()
	local obj = setmetatable( {}, RespQuitGuild.meta);
	return obj;
end

function RespQuitGuild:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回解散帮派
]]

_G.RespDismissGuild = {};

RespDismissGuild.msgId = 7052;
RespDismissGuild.result = 0; -- 0-成功，-1失败



RespDismissGuild.meta = {__index = RespDismissGuild};
function RespDismissGuild:new()
	local obj = setmetatable( {}, RespDismissGuild.meta);
	return obj;
end

function RespDismissGuild:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回升级帮派
]]

_G.RespLvUpGuild = {};

RespLvUpGuild.msgId = 7053;
RespLvUpGuild.level = 0; -- 帮派等级
RespLvUpGuild.result = 0; -- 0-成功，-1失败



RespLvUpGuild.meta = {__index = RespLvUpGuild};
function RespLvUpGuild:new()
	local obj = setmetatable( {}, RespLvUpGuild.meta);
	return obj;
end

function RespLvUpGuild:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
返回开启某组帮派技能
]]

_G.RespLvUpGuildSkill = {};

RespLvUpGuildSkill.msgId = 7054;
RespLvUpGuildSkill.groupId = 0; -- 技能组ID
RespLvUpGuildSkill.result = 0; -- 0-成功，-1失败



RespLvUpGuildSkill.meta = {__index = RespLvUpGuildSkill};
function RespLvUpGuildSkill:new()
	local obj = setmetatable( {}, RespLvUpGuildSkill.meta);
	return obj;
end

function RespLvUpGuildSkill:ParseData(pak)
	local idx = 1;

	self.groupId, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
返回改变职位
]]

_G.RespChangeGuildPos = {};

RespChangeGuildPos.msgId = 7055;
RespChangeGuildPos.memGid = ""; -- 玩家ID
RespChangeGuildPos.pos = 0; -- 职位
RespChangeGuildPos.result = 0; -- 0-成功，-1失败



RespChangeGuildPos.meta = {__index = RespChangeGuildPos};
function RespChangeGuildPos:new()
	local obj = setmetatable( {}, RespChangeGuildPos.meta);
	return obj;
end

function RespChangeGuildPos:ParseData(pak)
	local idx = 1;

	self.memGid, idx = readGuid(pak, idx);
	self.pos, idx = readByte(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
返回踢出帮派成员
]]

_G.RespKickGuildMem = {};

RespKickGuildMem.msgId = 7056;
RespKickGuildMem.memGid = ""; -- 玩家ID
RespKickGuildMem.result = 0; -- 0-成功，-1失败



RespKickGuildMem.meta = {__index = RespKickGuildMem};
function RespKickGuildMem:new()
	local obj = setmetatable( {}, RespKickGuildMem.meta);
	return obj;
end

function RespKickGuildMem:ParseData(pak)
	local idx = 1;

	self.memGid, idx = readGuid(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
返回禅让帮主
]]

_G.RespChangeLeader = {};

RespChangeLeader.msgId = 7057;
RespChangeLeader.oldId = ""; -- 老帮主ID
RespChangeLeader.newId = ""; -- 新帮主ID
RespChangeLeader.pos = 0; -- 老帮主职位
RespChangeLeader.result = 0; -- 0-成功，-1失败



RespChangeLeader.meta = {__index = RespChangeLeader};
function RespChangeLeader:new()
	local obj = setmetatable( {}, RespChangeLeader.meta);
	return obj;
end

function RespChangeLeader:ParseData(pak)
	local idx = 1;

	self.oldId, idx = readGuid(pak, idx);
	self.newId, idx = readGuid(pak, idx);
	self.pos, idx = readByte(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
返回帮派捐献
]]

_G.RespGuildContribute = {};

RespGuildContribute.msgId = 7058;
RespGuildContribute.captial = 0; -- 帮派资金
RespGuildContribute.contribute = 0; -- 当前贡献
RespGuildContribute.GuildResList_size = 3; -- 帮派资源列表 size
RespGuildContribute.GuildResList = {}; -- 帮派资源列表 list



--[[
RespGuildResVoVO = {
	itemId = 0; -- 资源ID
	count = 0; -- 数量
}
]]

RespGuildContribute.meta = {__index = RespGuildContribute};
function RespGuildContribute:new()
	local obj = setmetatable( {}, RespGuildContribute.meta);
	return obj;
end

function RespGuildContribute:ParseData(pak)
	local idx = 1;

	self.captial, idx = readDouble(pak, idx);
	self.contribute, idx = readInt(pak, idx);

	local list = {};
	self.GuildResList = list;
	local listSize = 3;

	for i=1,listSize do
		local RespGuildResVoVo = {};
		RespGuildResVoVo.itemId, idx = readInt(pak, idx);
		RespGuildResVoVo.count, idx = readInt(pak, idx);
		table.push(list,RespGuildResVoVo);
	end

end



--[[
返回升级自身帮派技能
]]

_G.RespLevelUpMyGuildSkill = {};

RespLevelUpMyGuildSkill.msgId = 7059;
RespLevelUpMyGuildSkill.groupId = 0; -- 技能组ID
RespLevelUpMyGuildSkill.result = 0; -- 0-成功，-1失败



RespLevelUpMyGuildSkill.meta = {__index = RespLevelUpMyGuildSkill};
function RespLevelUpMyGuildSkill:new()
	local obj = setmetatable( {}, RespLevelUpMyGuildSkill.meta);
	return obj;
end

function RespLevelUpMyGuildSkill:ParseData(pak)
	local idx = 1;

	self.groupId, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
返回世界Boss列表(刷新时推单个)
]]

_G.RespWorldBossMsg = {};

RespWorldBossMsg.msgId = 7064;
RespWorldBossMsg.list_size = 0; -- 世界Boss列表 size
RespWorldBossMsg.list = {}; -- 世界Boss列表 list



--[[
WorldBossVO = {
	id = 0; -- 世界bossId
	line = 0; -- 活动所在线
	state = 0; -- 0活着,1死亡
	lastKillRoleID = ""; -- 上次击杀roleId
	lastKillRoleName = ""; -- 上次击杀roleName
}
]]

RespWorldBossMsg.meta = {__index = RespWorldBossMsg};
function RespWorldBossMsg:new()
	local obj = setmetatable( {}, RespWorldBossMsg.meta);
	return obj;
end

function RespWorldBossMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local WorldBossVo = {};
		WorldBossVo.id, idx = readInt(pak, idx);
		WorldBossVo.line, idx = readInt(pak, idx);
		WorldBossVo.state, idx = readInt(pak, idx);
		WorldBossVo.lastKillRoleID, idx = readGuid(pak, idx);
		WorldBossVo.lastKillRoleName, idx = readString(pak, idx, 32);
		table.push(list1,WorldBossVo);
	end

end



--[[
返回活动状态(刷新时推单个)
]]

_G.RespActivityStateMsg = {};

RespActivityStateMsg.msgId = 7065;
RespActivityStateMsg.list_size = 0; -- 活动状态 size
RespActivityStateMsg.list = {}; -- 活动状态 list



--[[
ActivityStateVO = {
	id = 0; -- 活动id
	state = 0; -- 0关闭,1开启
	time = 0; -- 开启或关闭时间
	line = 0; -- 活动所在线
	mapID = 0; -- 活动所在地图
}
]]

RespActivityStateMsg.meta = {__index = RespActivityStateMsg};
function RespActivityStateMsg:new()
	local obj = setmetatable( {}, RespActivityStateMsg.meta);
	return obj;
end

function RespActivityStateMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ActivityStateVo = {};
		ActivityStateVo.id, idx = readInt(pak, idx);
		ActivityStateVo.state, idx = readInt(pak, idx);
		ActivityStateVo.time, idx = readInt64(pak, idx);
		ActivityStateVo.line, idx = readInt(pak, idx);
		ActivityStateVo.mapID, idx = readInt(pak, idx);
		table.push(list1,ActivityStateVo);
	end

end



--[[
返回帮派同盟
]]

_G.RespGuildAlianceMsg = {};

RespGuildAlianceMsg.msgId = 7066;
RespGuildAlianceMsg.guildId = ""; -- 帮派id
RespGuildAlianceMsg.result = 0; -- 0-成功，-1失败



RespGuildAlianceMsg.meta = {__index = RespGuildAlianceMsg};
function RespGuildAlianceMsg:new()
	local obj = setmetatable( {}, RespGuildAlianceMsg.meta);
	return obj;
end

function RespGuildAlianceMsg:ParseData(pak)
	local idx = 1;

	self.guildId, idx = readGuid(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
返回解散帮派同盟
]]

_G.RespDismissGuildAlianceMsg = {};

RespDismissGuildAlianceMsg.msgId = 7067;
RespDismissGuildAlianceMsg.guildId = ""; -- 帮派id



RespDismissGuildAlianceMsg.meta = {__index = RespDismissGuildAlianceMsg};
function RespDismissGuildAlianceMsg:new()
	local obj = setmetatable( {}, RespDismissGuildAlianceMsg.meta);
	return obj;
end

function RespDismissGuildAlianceMsg:ParseData(pak)
	local idx = 1;

	self.guildId, idx = readGuid(pak, idx);

end



--[[
返回帮派同盟申请列表
]]

_G.RespGuildAlianceApplysMsg = {};

RespGuildAlianceApplysMsg.msgId = 7068;
RespGuildAlianceApplysMsg.GuildAlianceApplysList_size = 0; -- 帮派列表 size
RespGuildAlianceApplysMsg.GuildAlianceApplysList = {}; -- 帮派列表 list



--[[
RespGuildAlianceApplysVoVO = {
	id = ""; -- 帮派Id
	name = ""; -- 帮派名称
	time = 0; -- 申请时间
	power = 0; -- 战斗力
	level = 0; -- 等级
	memCnt = 0; -- 成员数量
	extendNum = 0; -- 扩展人数
}
]]

RespGuildAlianceApplysMsg.meta = {__index = RespGuildAlianceApplysMsg};
function RespGuildAlianceApplysMsg:new()
	local obj = setmetatable( {}, RespGuildAlianceApplysMsg.meta);
	return obj;
end

function RespGuildAlianceApplysMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.GuildAlianceApplysList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RespGuildAlianceApplysVoVo = {};
		RespGuildAlianceApplysVoVo.id, idx = readGuid(pak, idx);
		RespGuildAlianceApplysVoVo.name, idx = readString(pak, idx, 32);
		RespGuildAlianceApplysVoVo.time, idx = readInt64(pak, idx);
		RespGuildAlianceApplysVoVo.power, idx = readInt64(pak, idx);
		RespGuildAlianceApplysVoVo.level, idx = readInt(pak, idx);
		RespGuildAlianceApplysVoVo.memCnt, idx = readInt(pak, idx);
		RespGuildAlianceApplysVoVo.extendNum, idx = readInt(pak, idx);
		table.push(list1,RespGuildAlianceApplysVoVo);
	end

end



--[[
返回帮派同盟信息
]]

_G.RespAlianceGuildInfo = {};

RespAlianceGuildInfo.msgId = 7069;
RespAlianceGuildInfo.rank = 0; -- 排名
RespAlianceGuildInfo.level = 0; -- 帮派等级
RespAlianceGuildInfo.memCnt = 0; -- 成员数量
RespAlianceGuildInfo.extendNum = 0; -- 扩展人数
RespAlianceGuildInfo.power = 0; -- 战斗力
RespAlianceGuildInfo.guildName = ""; -- 帮派名称
RespAlianceGuildInfo.GuildMemList_size = 0; -- 帮派成员列表 size
RespAlianceGuildInfo.GuildMemList = {}; -- 帮派成员列表 list



--[[
RespGuildMemsVoVO = {
	id = ""; -- Gid
	name = ""; -- 名称
	time = 0; -- 最后登录时间
	level = 0; -- 等级
	power = 0; -- 战斗力
	pos = 0; -- 职位
	online = 0; -- 1-在线，0-不在线
}
]]

RespAlianceGuildInfo.meta = {__index = RespAlianceGuildInfo};
function RespAlianceGuildInfo:new()
	local obj = setmetatable( {}, RespAlianceGuildInfo.meta);
	return obj;
end

function RespAlianceGuildInfo:ParseData(pak)
	local idx = 1;

	self.rank, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);
	self.memCnt, idx = readInt(pak, idx);
	self.extendNum, idx = readInt(pak, idx);
	self.power, idx = readInt64(pak, idx);
	self.guildName, idx = readString(pak, idx, 32);

	local list1 = {};
	self.GuildMemList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RespGuildMemsVoVo = {};
		RespGuildMemsVoVo.id, idx = readGuid(pak, idx);
		RespGuildMemsVoVo.name, idx = readString(pak, idx, 32);
		RespGuildMemsVoVo.time, idx = readInt64(pak, idx);
		RespGuildMemsVoVo.level, idx = readInt(pak, idx);
		RespGuildMemsVoVo.power, idx = readInt64(pak, idx);
		RespGuildMemsVoVo.pos, idx = readByte(pak, idx);
		RespGuildMemsVoVo.online, idx = readByte(pak, idx);
		table.push(list1,RespGuildMemsVoVo);
	end

end



--[[
审核帮派同盟返回
]]

_G.ResqGuildAlianceVerifyMsg = {};

ResqGuildAlianceVerifyMsg.msgId = 7070;
ResqGuildAlianceVerifyMsg.verify = 0; -- 是否同意0 - 同意，1 - 拒绝
ResqGuildAlianceVerifyMsg.GuildAlianceApplyList_size = 0; -- 帮派同盟列表 size
ResqGuildAlianceVerifyMsg.GuildAlianceApplyList = {}; -- 帮派同盟列表 list



--[[
ReqGuildAlianceApplyVoVO = {
	guild = ""; -- 帮派ID
	result = 0; -- 0-成功，1失败
}
]]

ResqGuildAlianceVerifyMsg.meta = {__index = ResqGuildAlianceVerifyMsg};
function ResqGuildAlianceVerifyMsg:new()
	local obj = setmetatable( {}, ResqGuildAlianceVerifyMsg.meta);
	return obj;
end

function ResqGuildAlianceVerifyMsg:ParseData(pak)
	local idx = 1;

	self.verify, idx = readInt(pak, idx);

	local list1 = {};
	self.GuildAlianceApplyList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ReqGuildAlianceApplyVoVo = {};
		ReqGuildAlianceApplyVoVo.guild, idx = readGuid(pak, idx);
		ReqGuildAlianceApplyVoVo.result, idx = readByte(pak, idx);
		table.push(list1,ReqGuildAlianceApplyVoVo);
	end

end



--[[
返回洗炼属性
]]

_G.ResqBapAidInfoMsg = {};

ResqBapAidInfoMsg.msgId = 7072;
ResqBapAidInfoMsg.att = 0; -- 洗炼攻击
ResqBapAidInfoMsg.def = 0; -- 洗炼防御
ResqBapAidInfoMsg.maxhp = 0; -- 洗炼生命
ResqBapAidInfoMsg.cri = 0; -- 洗炼暴击



ResqBapAidInfoMsg.meta = {__index = ResqBapAidInfoMsg};
function ResqBapAidInfoMsg:new()
	local obj = setmetatable( {}, ResqBapAidInfoMsg.meta);
	return obj;
end

function ResqBapAidInfoMsg:ParseData(pak)
	local idx = 1;

	self.att, idx = readInt(pak, idx);
	self.def, idx = readInt(pak, idx);
	self.maxhp, idx = readInt(pak, idx);
	self.cri, idx = readInt(pak, idx);

end



--[[
返回加持属性
]]

_G.ResqUpdateGuildAidInfoMsg = {};

ResqUpdateGuildAidInfoMsg.msgId = 7071;
ResqUpdateGuildAidInfoMsg.aidLevel = 0; -- 加持等级
ResqUpdateGuildAidInfoMsg.att = 0; -- 加持攻击
ResqUpdateGuildAidInfoMsg.def = 0; -- 加持防御
ResqUpdateGuildAidInfoMsg.maxhp = 0; -- 加持生命
ResqUpdateGuildAidInfoMsg.cri = 0; -- 加持暴击



ResqUpdateGuildAidInfoMsg.meta = {__index = ResqUpdateGuildAidInfoMsg};
function ResqUpdateGuildAidInfoMsg:new()
	local obj = setmetatable( {}, ResqUpdateGuildAidInfoMsg.meta);
	return obj;
end

function ResqUpdateGuildAidInfoMsg:ParseData(pak)
	local idx = 1;

	self.aidLevel, idx = readInt(pak, idx);
	self.att, idx = readInt(pak, idx);
	self.def, idx = readInt(pak, idx);
	self.maxhp, idx = readInt(pak, idx);
	self.cri, idx = readInt(pak, idx);

end



--[[
返回加持升级
]]

_G.ResqUpAidLevelInfoMsg = {};

ResqUpAidLevelInfoMsg.msgId = 7073;
ResqUpAidLevelInfoMsg.result = 0; -- 0 成功， 1 失败



ResqUpAidLevelInfoMsg.meta = {__index = ResqUpAidLevelInfoMsg};
function ResqUpAidLevelInfoMsg:new()
	local obj = setmetatable( {}, ResqUpAidLevelInfoMsg.meta);
	return obj;
end

function ResqUpAidLevelInfoMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
更新自己帮派信息
]]

_G.ResqMyGuildMemInfoMsg = {};

ResqMyGuildMemInfoMsg.msgId = 7074;
ResqMyGuildMemInfoMsg.pos = 0; -- 职位
ResqMyGuildMemInfoMsg.contribution = 0; -- 当前贡献
ResqMyGuildMemInfoMsg.totalContribution = 0; -- 累计贡献
ResqMyGuildMemInfoMsg.loyalty = 0; -- 忠诚度



ResqMyGuildMemInfoMsg.meta = {__index = ResqMyGuildMemInfoMsg};
function ResqMyGuildMemInfoMsg:new()
	local obj = setmetatable( {}, ResqMyGuildMemInfoMsg.meta);
	return obj;
end

function ResqMyGuildMemInfoMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readByte(pak, idx);
	self.contribution, idx = readInt(pak, idx);
	self.totalContribution, idx = readInt(pak, idx);
	self.loyalty, idx = readInt(pak, idx);

end



--[[
服务器通知：返回我的竞技场信息(登录推,除排行外更新推)
]]

_G.RespArenaMyRoleAtbMsg = {};

RespArenaMyRoleAtbMsg.msgId = 7100;
RespArenaMyRoleAtbMsg.rank = 0; -- 人物排行
RespArenaMyRoleAtbMsg.ranks = 0; -- 人物0点排行
RespArenaMyRoleAtbMsg.chal = 0; -- 挑战次数
RespArenaMyRoleAtbMsg.lastTime = 0; -- 冷却时间(剩余时间)
RespArenaMyRoleAtbMsg.isResults = 0; -- 0未领取，1领取
RespArenaMyRoleAtbMsg.field = 0; -- 连胜场数
RespArenaMyRoleAtbMsg.admoney = 0; -- 整点在线累计奖励金币
RespArenaMyRoleAtbMsg.adhonor = 0; -- 整点在线累计奖励荣誉
RespArenaMyRoleAtbMsg.maxchallTime = 0; -- 挑战最大次数



RespArenaMyRoleAtbMsg.meta = {__index = RespArenaMyRoleAtbMsg};
function RespArenaMyRoleAtbMsg:new()
	local obj = setmetatable( {}, RespArenaMyRoleAtbMsg.meta);
	return obj;
end

function RespArenaMyRoleAtbMsg:ParseData(pak)
	local idx = 1;

	self.rank, idx = readInt(pak, idx);
	self.ranks, idx = readInt(pak, idx);
	self.chal, idx = readInt(pak, idx);
	self.lastTime, idx = readInt(pak, idx);
	self.isResults, idx = readInt(pak, idx);
	self.field, idx = readInt(pak, idx);
	self.admoney, idx = readInt(pak, idx);
	self.adhonor, idx = readInt(pak, idx);
	self.maxchallTime, idx = readInt(pak, idx);

end



--[[
服务器通知：返回当前可挑战对象list
]]

_G.RespArenaRoleListMsg = {};

RespArenaRoleListMsg.msgId = 7101;
RespArenaRoleListMsg.type = 0; -- 0 - 123名，1 - 挑战对象
RespArenaRoleListMsg.ArenaList_size = 0; -- 人物挑战列表 size
RespArenaRoleListMsg.ArenaList = {}; -- 人物挑战列表 list



--[[
ArenaRoleVoVO = {
	roleId = ""; -- 人物id
	roleName = ""; -- 人物名称
	fight = 0; -- 人物战力
	rank = 0; -- 人物排行
	prof = 0; -- 职业
	arms = 0; -- 武器
	dress = 0; -- 衣服
	fashionshead = 0; -- 时装头
	fashionsarms = 0; -- 时装武器
	fashionsdress = 0; -- 时装衣服
	wuhunId = 0; -- 武魂id
	wing = 0; -- 翅膀
	suitflag = 0; -- 套装标识
}
]]

RespArenaRoleListMsg.meta = {__index = RespArenaRoleListMsg};
function RespArenaRoleListMsg:new()
	local obj = setmetatable( {}, RespArenaRoleListMsg.meta);
	return obj;
end

function RespArenaRoleListMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

	local list1 = {};
	self.ArenaList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ArenaRoleVoVo = {};
		ArenaRoleVoVo.roleId, idx = readGuid(pak, idx);
		ArenaRoleVoVo.roleName, idx = readString(pak, idx, 32);
		ArenaRoleVoVo.fight, idx = readInt64(pak, idx);
		ArenaRoleVoVo.rank, idx = readInt(pak, idx);
		ArenaRoleVoVo.prof, idx = readInt(pak, idx);
		ArenaRoleVoVo.arms, idx = readInt(pak, idx);
		ArenaRoleVoVo.dress, idx = readInt(pak, idx);
		ArenaRoleVoVo.fashionshead, idx = readInt(pak, idx);
		ArenaRoleVoVo.fashionsarms, idx = readInt(pak, idx);
		ArenaRoleVoVo.fashionsdress, idx = readInt(pak, idx);
		ArenaRoleVoVo.wuhunId, idx = readInt(pak, idx);
		ArenaRoleVoVo.wing, idx = readInt(pak, idx);
		ArenaRoleVoVo.suitflag, idx = readInt(pak, idx);
		table.push(list1,ArenaRoleVoVo);
	end

end



--[[
服通知：返回挑战结果
]]

_G.RespArenaChallengeResultsMsg = {};

RespArenaChallengeResultsMsg.msgId = 7102;
RespArenaChallengeResultsMsg.result = 0; -- 0成功,1失败
RespArenaChallengeResultsMsg.rank = 0; -- 排名
RespArenaChallengeResultsMsg.exp = 0; -- 获得经验
RespArenaChallengeResultsMsg.honor = 0; -- 获得荣誉



RespArenaChallengeResultsMsg.meta = {__index = RespArenaChallengeResultsMsg};
function RespArenaChallengeResultsMsg:new()
	local obj = setmetatable( {}, RespArenaChallengeResultsMsg.meta);
	return obj;
end

function RespArenaChallengeResultsMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.rank, idx = readInt(pak, idx);
	self.exp, idx = readInt(pak, idx);
	self.honor, idx = readInt(pak, idx);

end



--[[
服通知：返回奖励领取结果
]]

_G.RespArenaRewardMsg = {};

RespArenaRewardMsg.msgId = 7103;
RespArenaRewardMsg.result = 0; -- 0成功,1失败



RespArenaRewardMsg.meta = {__index = RespArenaRewardMsg};
function RespArenaRewardMsg:new()
	local obj = setmetatable( {}, RespArenaRewardMsg.meta);
	return obj;
end

function RespArenaRewardMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器通知：返回战报
]]

_G.RespArenaSkInfoMsg = {};

RespArenaSkInfoMsg.msgId = 7104;
RespArenaSkInfoMsg.SkInfoList_size = 0; -- 战报list size
RespArenaSkInfoMsg.SkInfoList = {}; -- 战报list list



--[[
ArenaInfoVoVO = {
	id = 0; -- 配表ID
	time = 0; -- 时间（秒）
	param = ""; -- 参数，分割
}
]]

RespArenaSkInfoMsg.meta = {__index = RespArenaSkInfoMsg};
function RespArenaSkInfoMsg:new()
	local obj = setmetatable( {}, RespArenaSkInfoMsg.meta);
	return obj;
end

function RespArenaSkInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.SkInfoList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ArenaInfoVoVo = {};
		ArenaInfoVoVo.id, idx = readInt(pak, idx);
		ArenaInfoVoVo.time, idx = readInt64(pak, idx);
		ArenaInfoVoVo.param, idx = readString(pak, idx, 64);
		table.push(list1,ArenaInfoVoVo);
	end

end



--[[
返回购买竞技场次数
]]

_G.RespBuyArenaTimesMsg = {};

RespBuyArenaTimesMsg.msgId = 7105;
RespBuyArenaTimesMsg.result = 0; -- 0成功,1失败，2购买上限
RespBuyArenaTimesMsg.times = 0; -- 新次数



RespBuyArenaTimesMsg.meta = {__index = RespBuyArenaTimesMsg};
function RespBuyArenaTimesMsg:new()
	local obj = setmetatable( {}, RespBuyArenaTimesMsg.meta);
	return obj;
end

function RespBuyArenaTimesMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.times, idx = readInt(pak, idx);

end



--[[
返回购买竞技场CD
]]

_G.RespBuyArenaCDMsg = {};

RespBuyArenaCDMsg.msgId = 7106;
RespBuyArenaCDMsg.result = 0; -- 0成功,1失败
RespBuyArenaCDMsg.cd = 0; -- 新cd



RespBuyArenaCDMsg.meta = {__index = RespBuyArenaCDMsg};
function RespBuyArenaCDMsg:new()
	local obj = setmetatable( {}, RespBuyArenaCDMsg.meta);
	return obj;
end

function RespBuyArenaCDMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.cd, idx = readInt(pak, idx);

end



--[[
服务端通知:帮派活动-地宫炼狱信息
]]

_G.RespGuildHellInfoMsg = {};

RespGuildHellInfoMsg.msgId = 7107;
RespGuildHellInfoMsg.stratumList_size = 0; -- 地宫炼狱层列表 size
RespGuildHellInfoMsg.stratumList = {}; -- 地宫炼狱层列表 list



--[[
stratumListVO = {
	id = 0; -- 层级id(与层数一致)
	state = 0; -- 是否已过关 0:已过关， 1:未过关
	passTime = 0; -- 过关用时，未过关时传0
	numPass = 0; -- 本周过关人数
	bestPass = ""; -- 本帮最佳过关玩家名字
	bestPassTime = 0; -- 本帮最佳过关玩家用时, s
}
]]

RespGuildHellInfoMsg.meta = {__index = RespGuildHellInfoMsg};
function RespGuildHellInfoMsg:new()
	local obj = setmetatable( {}, RespGuildHellInfoMsg.meta);
	return obj;
end

function RespGuildHellInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.stratumList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local stratumListVo = {};
		stratumListVo.id, idx = readByte(pak, idx);
		stratumListVo.state, idx = readByte(pak, idx);
		stratumListVo.passTime, idx = readInt(pak, idx);
		stratumListVo.numPass, idx = readInt(pak, idx);
		stratumListVo.bestPass, idx = readString(pak, idx, 32);
		stratumListVo.bestPassTime, idx = readInt(pak, idx);
		table.push(list1,stratumListVo);
	end

end



--[[
服务端通知：请求进入地宫炼狱结果
]]

_G.RespEnterGuildHellMsg = {};

RespEnterGuildHellMsg.msgId = 7108;
RespEnterGuildHellMsg.result = 0; -- 进入结果 0:成功, 1:组队状态
RespEnterGuildHellMsg.id = 0; -- 层级id(与层数一致)



RespEnterGuildHellMsg.meta = {__index = RespEnterGuildHellMsg};
function RespEnterGuildHellMsg:new()
	local obj = setmetatable( {}, RespEnterGuildHellMsg.meta);
	return obj;
end

function RespEnterGuildHellMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.id, idx = readByte(pak, idx);

end



--[[
服务端通知：挑战地宫炼狱结果
]]

_G.RespGuildHellResultMsg = {};

RespGuildHellResultMsg.msgId = 7109;
RespGuildHellResultMsg.id = 0; -- 层级id(与层数一致)
RespGuildHellResultMsg.result = 0; -- 0:胜利 1:失败
RespGuildHellResultMsg.time = 0; -- 用时 s
RespGuildHellResultMsg.bestTime = 0; -- 最佳用时 s



RespGuildHellResultMsg.meta = {__index = RespGuildHellResultMsg};
function RespGuildHellResultMsg:new()
	local obj = setmetatable( {}, RespGuildHellResultMsg.meta);
	return obj;
end

function RespGuildHellResultMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readByte(pak, idx);
	self.result, idx = readInt(pak, idx);
	self.time, idx = readInt(pak, idx);
	self.bestTime, idx = readInt(pak, idx);

end



--[[
服务器通知：排行榜list
]]

_G.RespRankListMsg = {};

RespRankListMsg.msgId = 7110;
RespRankListMsg.type = 0; -- 1=等级，2=战力，4=境界 5=灵兽，6=灵阵，7=极限挑战boss，8=极限挑战小怪
RespRankListMsg.rankList_size = 0; -- list size
RespRankListMsg.rankList = {}; -- list list



--[[
rankVOVO = {
	roleID = ""; -- 角色ID
	rank = 0; -- 名次
	roleName = ""; -- 人物名称
	lvl = 0; -- 等级
	fight = 0; -- 战斗力
	roletype = 0; -- 角色类型 1 萝莉 2 男魔 3 人男 4 御姐
	vipLvl = 0; -- vip等级
	rankvlue = 0; -- 当前排行值
	vflag = 0; -- V计划
	txhflag = 0; -- 黄钻标识
}
]]

RespRankListMsg.meta = {__index = RespRankListMsg};
function RespRankListMsg:new()
	local obj = setmetatable( {}, RespRankListMsg.meta);
	return obj;
end

function RespRankListMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

	local list1 = {};
	self.rankList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local rankVOVo = {};
		rankVOVo.roleID, idx = readGuid(pak, idx);
		rankVOVo.rank, idx = readInt(pak, idx);
		rankVOVo.roleName, idx = readString(pak, idx, 32);
		rankVOVo.lvl, idx = readInt(pak, idx);
		rankVOVo.fight, idx = readInt64(pak, idx);
		rankVOVo.roletype, idx = readInt(pak, idx);
		rankVOVo.vipLvl, idx = readInt(pak, idx);
		rankVOVo.rankvlue, idx = readInt64(pak, idx);
		rankVOVo.vflag, idx = readInt(pak, idx);
		rankVOVo.txhflag, idx = readInt(pak, idx);
		table.push(list1,rankVOVo);
	end

end



--[[
服务器通知：返回坐骑排行榜list
]]

_G.RespMountRankMsg = {};

RespMountRankMsg.msgId = 7111;
RespMountRankMsg.rankList_size = 0; -- list size
RespMountRankMsg.rankList = {}; -- list list



--[[
rankVOVO = {
	roleID = ""; -- 角色ID
	rank = 0; -- 名次
	lvl = 0; -- 等级
	roletype = 0; -- 角色类型 1 萝莉 2 男魔 3 人男 4 御姐
	roleName = ""; -- 人物名称
	mountId = 0; -- 坐骑ID
	vipLvl = 0; -- vip等级
	vflag = 0; -- V计划
	txhflag = 0; -- 黄钻标识
}
]]

RespMountRankMsg.meta = {__index = RespMountRankMsg};
function RespMountRankMsg:new()
	local obj = setmetatable( {}, RespMountRankMsg.meta);
	return obj;
end

function RespMountRankMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.rankList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local rankVOVo = {};
		rankVOVo.roleID, idx = readGuid(pak, idx);
		rankVOVo.rank, idx = readInt(pak, idx);
		rankVOVo.lvl, idx = readInt(pak, idx);
		rankVOVo.roletype, idx = readInt(pak, idx);
		rankVOVo.roleName, idx = readString(pak, idx, 32);
		rankVOVo.mountId, idx = readInt(pak, idx);
		rankVOVo.vipLvl, idx = readInt(pak, idx);
		rankVOVo.vflag, idx = readInt(pak, idx);
		rankVOVo.txhflag, idx = readInt(pak, idx);
		table.push(list1,rankVOVo);
	end

end



--[[
服务器通知：是否需要请求排信息
]]

_G.RespNoticeRankMsg = {};

RespNoticeRankMsg.msgId = 7112;
RespNoticeRankMsg.type = 0; -- 



RespNoticeRankMsg.meta = {__index = RespNoticeRankMsg};
function RespNoticeRankMsg:new()
	local obj = setmetatable( {}, RespNoticeRankMsg.meta);
	return obj;
end

function RespNoticeRankMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
服务器通知：排行榜第一名
]]

_G.RespAllRankListMsg = {};

RespAllRankListMsg.msgId = 7114;
RespAllRankListMsg.rankList_size = 0; -- list size
RespAllRankListMsg.rankList = {}; -- list list



--[[
rankVOVO = {
	roleID = ""; -- 角色ID
	ranktype = 0; -- 名次类型
	roleName = ""; -- 人物名称
	fight = 0; -- 战斗力
	prof = 0; -- 职业
	dress = 0; -- 衣服
	arms = 0; -- 武器
	fashionshead = 0; -- 时装头
	fashionsarms = 0; -- 时装武器
	fashionsdress = 0; -- 时装衣服
	wuhunId = 0; -- 武魂id
	vipLvl = 0; -- vip等级
	vflag = 0; -- V计划
	wing = 0; -- 翅膀
	suitflag = 0; -- 套装标识
	txhflag = 0; -- 黄钻标识
}
]]

RespAllRankListMsg.meta = {__index = RespAllRankListMsg};
function RespAllRankListMsg:new()
	local obj = setmetatable( {}, RespAllRankListMsg.meta);
	return obj;
end

function RespAllRankListMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.rankList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local rankVOVo = {};
		rankVOVo.roleID, idx = readGuid(pak, idx);
		rankVOVo.ranktype, idx = readInt(pak, idx);
		rankVOVo.roleName, idx = readString(pak, idx, 32);
		rankVOVo.fight, idx = readInt64(pak, idx);
		rankVOVo.prof, idx = readInt(pak, idx);
		rankVOVo.dress, idx = readInt(pak, idx);
		rankVOVo.arms, idx = readInt(pak, idx);
		rankVOVo.fashionshead, idx = readInt(pak, idx);
		rankVOVo.fashionsarms, idx = readInt(pak, idx);
		rankVOVo.fashionsdress, idx = readInt(pak, idx);
		rankVOVo.wuhunId, idx = readInt(pak, idx);
		rankVOVo.vipLvl, idx = readInt(pak, idx);
		rankVOVo.vflag, idx = readInt(pak, idx);
		rankVOVo.wing, idx = readInt(pak, idx);
		rankVOVo.suitflag, idx = readInt(pak, idx);
		rankVOVo.txhflag, idx = readInt(pak, idx);
		table.push(list1,rankVOVo);
	end

end



--[[
返回加入帮派战
]]

_G.RespUnionWarActMsg = {};

RespUnionWarActMsg.msgId = 7115;
RespUnionWarActMsg.isopen = 0; -- 1=开启
RespUnionWarActMsg.lineID = 0; -- 线ID
RespUnionWarActMsg.type = 0; -- 0 备战场景， 1 帮战场景
RespUnionWarActMsg.lasttime = 0; -- 活动剩余时间



RespUnionWarActMsg.meta = {__index = RespUnionWarActMsg};
function RespUnionWarActMsg:new()
	local obj = setmetatable( {}, RespUnionWarActMsg.meta);
	return obj;
end

function RespUnionWarActMsg:ParseData(pak)
	local idx = 1;

	self.isopen, idx = readInt(pak, idx);
	self.lineID, idx = readInt(pak, idx);
	self.type, idx = readByte(pak, idx);
	self.lasttime, idx = readInt(pak, idx);

end



--[[
返回激活码
]]

_G.RespActivationCodeMsg = {};

RespActivationCodeMsg.msgId = 7116;
RespActivationCodeMsg.result = 0; -- 0 成功， 1失败，2已使用过此类型的礼包码，3礼包码还未到使用期限，4礼包码无效，5礼包码使用次数已达到上限，6礼包码使用已达上限，
RespActivationCodeMsg.id = 0; -- 激活码类型



RespActivationCodeMsg.meta = {__index = RespActivationCodeMsg};
function RespActivationCodeMsg:new()
	local obj = setmetatable( {}, RespActivationCodeMsg.meta);
	return obj;
end

function RespActivationCodeMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
返回加入帮派王城战
]]

_G.RespUnionEnterCityWarMsg = {};

RespUnionEnterCityWarMsg.msgId = 7117;
RespUnionEnterCityWarMsg.isopen = 0; -- 1=开启
RespUnionEnterCityWarMsg.isPass = 0; -- 0=有进入权限，1=没有进入权限
RespUnionEnterCityWarMsg.lineID = 0; -- 线ID



RespUnionEnterCityWarMsg.meta = {__index = RespUnionEnterCityWarMsg};
function RespUnionEnterCityWarMsg:new()
	local obj = setmetatable( {}, RespUnionEnterCityWarMsg.meta);
	return obj;
end

function RespUnionEnterCityWarMsg:ParseData(pak)
	local idx = 1;

	self.isopen, idx = readInt(pak, idx);
	self.isPass, idx = readInt(pak, idx);
	self.lineID, idx = readInt(pak, idx);

end



--[[
服务器通知：排行榜list
]]

_G.RespAllServerRankListMsg = {};

RespAllServerRankListMsg.msgId = 7118;
RespAllServerRankListMsg.type = 0; -- 1=等级，2=战力 4= 境界5=灵兽，6=灵阵，7=极限挑战boss，8=极限挑战小怪
RespAllServerRankListMsg.rankList_size = 0; -- list size
RespAllServerRankListMsg.rankList = {}; -- list list



--[[
rankVOVO = {
	roleID = ""; -- 角色ID
	rank = 0; -- 名次
	roleName = ""; -- 人物名称
	lvl = 0; -- 等级
	fight = 0; -- 战斗力
	roletype = 0; -- 角色类型 1 萝莉 2 男魔 3 人男 4 御姐
	vipLvl = 0; -- vip等级
	rankvlue = 0; -- 当前排行值
	vflag = 0; -- V计划
	txhflag = 0; -- 黄钻标识
}
]]

RespAllServerRankListMsg.meta = {__index = RespAllServerRankListMsg};
function RespAllServerRankListMsg:new()
	local obj = setmetatable( {}, RespAllServerRankListMsg.meta);
	return obj;
end

function RespAllServerRankListMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

	local list1 = {};
	self.rankList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local rankVOVo = {};
		rankVOVo.roleID, idx = readGuid(pak, idx);
		rankVOVo.rank, idx = readInt(pak, idx);
		rankVOVo.roleName, idx = readString(pak, idx, 32);
		rankVOVo.lvl, idx = readInt(pak, idx);
		rankVOVo.fight, idx = readInt64(pak, idx);
		rankVOVo.roletype, idx = readInt(pak, idx);
		rankVOVo.vipLvl, idx = readInt(pak, idx);
		rankVOVo.rankvlue, idx = readInt64(pak, idx);
		rankVOVo.vflag, idx = readInt(pak, idx);
		rankVOVo.txhflag, idx = readInt(pak, idx);
		table.push(list1,rankVOVo);
	end

end



--[[
服务器通知：返回坐骑排行榜list
]]

_G.RespAllServerMountRankMsg = {};

RespAllServerMountRankMsg.msgId = 7119;
RespAllServerMountRankMsg.rankList_size = 0; -- list size
RespAllServerMountRankMsg.rankList = {}; -- list list



--[[
rankVOVO = {
	roleID = ""; -- 角色ID
	rank = 0; -- 名次
	lvl = 0; -- 等级
	roletype = 0; -- 角色类型 1 萝莉 2 男魔 3 人男 4 御姐
	roleName = ""; -- 人物名称
	mountId = 0; -- 坐骑ID
	vipLvl = 0; -- vip等级
	vflag = 0; -- V计划
	txhflag = 0; -- 黄钻标识
}
]]

RespAllServerMountRankMsg.meta = {__index = RespAllServerMountRankMsg};
function RespAllServerMountRankMsg:new()
	local obj = setmetatable( {}, RespAllServerMountRankMsg.meta);
	return obj;
end

function RespAllServerMountRankMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.rankList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local rankVOVo = {};
		rankVOVo.roleID, idx = readGuid(pak, idx);
		rankVOVo.rank, idx = readInt(pak, idx);
		rankVOVo.lvl, idx = readInt(pak, idx);
		rankVOVo.roletype, idx = readInt(pak, idx);
		rankVOVo.roleName, idx = readString(pak, idx, 32);
		rankVOVo.mountId, idx = readInt(pak, idx);
		rankVOVo.vipLvl, idx = readInt(pak, idx);
		rankVOVo.vflag, idx = readInt(pak, idx);
		rankVOVo.txhflag, idx = readInt(pak, idx);
		table.push(list1,rankVOVo);
	end

end



--[[
服务器通知：是否需要请求排信息
]]

_G.RespAllServerNoticeRankMsg = {};

RespAllServerNoticeRankMsg.msgId = 7120;
RespAllServerNoticeRankMsg.type = 0; -- 



RespAllServerNoticeRankMsg.meta = {__index = RespAllServerNoticeRankMsg};
function RespAllServerNoticeRankMsg:new()
	local obj = setmetatable( {}, RespAllServerNoticeRankMsg.meta);
	return obj;
end

function RespAllServerNoticeRankMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
至尊王帮信息
]]

_G.RespGetSuperGloryinfoMsg = {};

RespGetSuperGloryinfoMsg.msgId = 7122;
RespGetSuperGloryinfoMsg.isDuke = 0; -- 是否城主1==是
RespGetSuperGloryinfoMsg.cont = 0; -- 连任次数
RespGetSuperGloryinfoMsg.worship = 0; -- 当前膜拜次数
RespGetSuperGloryinfoMsg.atkName = ""; -- 占领帮派名称
RespGetSuperGloryinfoMsg.defName = ""; -- 攻城帮派名称
RespGetSuperGloryinfoMsg.lasttime = 0; -- 下次开启时间
RespGetSuperGloryinfoMsg.curstate = 0; -- 当前开启状态,1=开启
RespGetSuperGloryinfoMsg.curBagnum = 0; -- 当前礼包数量



RespGetSuperGloryinfoMsg.meta = {__index = RespGetSuperGloryinfoMsg};
function RespGetSuperGloryinfoMsg:new()
	local obj = setmetatable( {}, RespGetSuperGloryinfoMsg.meta);
	return obj;
end

function RespGetSuperGloryinfoMsg:ParseData(pak)
	local idx = 1;

	self.isDuke, idx = readInt(pak, idx);
	self.cont, idx = readInt(pak, idx);
	self.worship, idx = readInt(pak, idx);
	self.atkName, idx = readString(pak, idx, 32);
	self.defName, idx = readString(pak, idx, 32);
	self.lasttime, idx = readInt(pak, idx);
	self.curstate, idx = readInt(pak, idx);
	self.curBagnum, idx = readInt(pak, idx);

end



--[[
至尊王帮人物信息
]]

_G.RespGetSuperGloryRoleinfoMsg = {};

RespGetSuperGloryRoleinfoMsg.msgId = 7123;
RespGetSuperGloryRoleinfoMsg.roleList_size = 0; -- list size
RespGetSuperGloryRoleinfoMsg.roleList = {}; -- list list



--[[
roleVOVO = {
	roleID = ""; -- 角色ID
	ranktype = 0; -- 名次类型,1=城主，2=副城主，3=青龙，4=白虎 5= 朱雀，6=玄武
	roleName = ""; -- 人物名称
	unionName = ""; -- 帮派名
	fight = 0; -- 战斗力
	lvl = 0; -- 等级
	prof = 0; -- 职业
	dress = 0; -- 衣服
	arms = 0; -- 武器
	fashionshead = 0; -- 时装头
	fashionsarms = 0; -- 时装武器
	fashionsdress = 0; -- 时装衣服
	wuhunId = 0; -- 武魂id
	vipLvl = 0; -- vip等级
	vflag = 0; -- V计划
	wing = 0; -- 翅膀
	suitflag = 0; -- 套装标识
}
]]

RespGetSuperGloryRoleinfoMsg.meta = {__index = RespGetSuperGloryRoleinfoMsg};
function RespGetSuperGloryRoleinfoMsg:new()
	local obj = setmetatable( {}, RespGetSuperGloryRoleinfoMsg.meta);
	return obj;
end

function RespGetSuperGloryRoleinfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.roleList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local roleVOVo = {};
		roleVOVo.roleID, idx = readGuid(pak, idx);
		roleVOVo.ranktype, idx = readInt(pak, idx);
		roleVOVo.roleName, idx = readString(pak, idx, 32);
		roleVOVo.unionName, idx = readString(pak, idx, 32);
		roleVOVo.fight, idx = readInt64(pak, idx);
		roleVOVo.lvl, idx = readInt(pak, idx);
		roleVOVo.prof, idx = readInt(pak, idx);
		roleVOVo.dress, idx = readInt(pak, idx);
		roleVOVo.arms, idx = readInt(pak, idx);
		roleVOVo.fashionshead, idx = readInt(pak, idx);
		roleVOVo.fashionsarms, idx = readInt(pak, idx);
		roleVOVo.fashionsdress, idx = readInt(pak, idx);
		roleVOVo.wuhunId, idx = readInt(pak, idx);
		roleVOVo.vipLvl, idx = readInt(pak, idx);
		roleVOVo.vflag, idx = readInt(pak, idx);
		roleVOVo.wing, idx = readInt(pak, idx);
		roleVOVo.suitflag, idx = readInt(pak, idx);
		table.push(list1,roleVOVo);
	end

end



--[[
 膜拜结果
]]

_G.RespSuperGloryWorshipResultMsg = {};

RespSuperGloryWorshipResultMsg.msgId = 7124;
RespSuperGloryWorshipResultMsg.result = 0; -- 结果，0 成功



RespSuperGloryWorshipResultMsg.meta = {__index = RespSuperGloryWorshipResultMsg};
function RespSuperGloryWorshipResultMsg:new()
	local obj = setmetatable( {}, RespSuperGloryWorshipResultMsg.meta);
	return obj;
end

function RespSuperGloryWorshipResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
 帮派成员
]]

_G.RespSuperGloryUnionRoleMsg = {};

RespSuperGloryUnionRoleMsg.msgId = 7125;
RespSuperGloryUnionRoleMsg.roleList_size = 0; -- list size
RespSuperGloryUnionRoleMsg.roleList = {}; -- list list



--[[
roleVOVO = {
	roleID = ""; -- 角色ID
	roleName = ""; -- 人物名称
	pos = 0; -- 职位
	lvl = 0; -- 等级
}
]]

RespSuperGloryUnionRoleMsg.meta = {__index = RespSuperGloryUnionRoleMsg};
function RespSuperGloryUnionRoleMsg:new()
	local obj = setmetatable( {}, RespSuperGloryUnionRoleMsg.meta);
	return obj;
end

function RespSuperGloryUnionRoleMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.roleList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local roleVOVo = {};
		roleVOVo.roleID, idx = readGuid(pak, idx);
		roleVOVo.roleName, idx = readString(pak, idx, 32);
		roleVOVo.pos, idx = readInt(pak, idx);
		roleVOVo.lvl, idx = readInt(pak, idx);
		table.push(list1,roleVOVo);
	end

end



--[[
提交礼包分配结果
]]

_G.RespSuperGlorySendBagUpMsg = {};

RespSuperGlorySendBagUpMsg.msgId = 7126;
RespSuperGlorySendBagUpMsg.result = 0; -- 结果，0 成功.1=失败，，3 = 礼包不足



RespSuperGlorySendBagUpMsg.meta = {__index = RespSuperGlorySendBagUpMsg};
function RespSuperGlorySendBagUpMsg:new()
	local obj = setmetatable( {}, RespSuperGlorySendBagUpMsg.meta);
	return obj;
end

function RespSuperGlorySendBagUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
设置副手结果
]]

_G.RespSuperGlorySetDeputyMsg = {};

RespSuperGlorySetDeputyMsg.msgId = 7128;
RespSuperGlorySetDeputyMsg.result = 0; -- 结果，0 成功.1=失败，2=不是本帮成员，3=已有职位！



RespSuperGlorySetDeputyMsg.meta = {__index = RespSuperGlorySetDeputyMsg};
function RespSuperGlorySetDeputyMsg:new()
	local obj = setmetatable( {}, RespSuperGlorySetDeputyMsg.meta);
	return obj;
end

function RespSuperGlorySetDeputyMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回仓库操作
]]

_G.RespUnionWareInfomationMsg = {};

RespUnionWareInfomationMsg.msgId = 7129;
RespUnionWareInfomationMsg.type = 0; -- 1=更新，2全部数据
RespUnionWareInfomationMsg.infolist_size = 0; -- list size
RespUnionWareInfomationMsg.infolist = {}; -- list list



--[[
infoVoVO = {
	time = 0; -- 操作时间
	roleName = ""; -- 操作人物名称
	opertype = 0; -- 操作类型1==存入，2=取出, 3=装备熔炼
	itemid = 0; -- 物品id
	cont = 0; -- 贡献度
}
]]

RespUnionWareInfomationMsg.meta = {__index = RespUnionWareInfomationMsg};
function RespUnionWareInfomationMsg:new()
	local obj = setmetatable( {}, RespUnionWareInfomationMsg.meta);
	return obj;
end

function RespUnionWareInfomationMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

	local list1 = {};
	self.infolist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local infoVoVo = {};
		infoVoVo.time, idx = readInt64(pak, idx);
		infoVoVo.roleName, idx = readString(pak, idx, 32);
		infoVoVo.opertype, idx = readInt(pak, idx);
		infoVoVo.itemid, idx = readInt(pak, idx);
		infoVoVo.cont, idx = readInt(pak, idx);
		table.push(list1,infoVoVo);
	end

end



--[[
服务端通知: 帮派仓库物品列表
]]

_G.RespUnionWareHouseinfoMsg = {};

RespUnionWareHouseinfoMsg.msgId = 7130;
RespUnionWareHouseinfoMsg.type = 0; -- 1== 物品列表，2= 增加物品
RespUnionWareHouseinfoMsg.items_size = 0; -- 物品列表 size
RespUnionWareHouseinfoMsg.items = {}; -- 物品列表 list



--[[
SItemInfoVO = {
	uid = ""; -- 物品uid
	apply = 0; -- 是否已被申请(1-被申请,0-没有)
	cid = 0; -- 物品id
	strenLvl = 0; -- 强化等级
	emptystarnum = 0; -- 空星位数
	attrAddLvl = 0; -- 追加属性等级
	groupId = 0; -- 套装id
	groupId2 = 0; -- 套装id2
	group2Level = 0; -- 套装2的等级
	superNum = 0; -- 卓越数量
	superList_size = 7; -- 卓越属性列表 size
	superList = {}; -- 卓越属性列表 list
	newSuperList_size = 3; -- 新卓越属性列表 size
	newSuperList = {}; -- 新卓越属性列表 list
}
SuperVOVO = {
	uid = ""; -- 属性uid
	id = 0; -- 卓越id
	val1 = 0; -- 值1
}
NewSuperVOVO = {
	id = 0; -- 新卓越id
	wash = 0; -- 洗练值
}
]]

RespUnionWareHouseinfoMsg.meta = {__index = RespUnionWareHouseinfoMsg};
function RespUnionWareHouseinfoMsg:new()
	local obj = setmetatable( {}, RespUnionWareHouseinfoMsg.meta);
	return obj;
end

function RespUnionWareHouseinfoMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

	local list1 = {};
	self.items = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local SItemInfoVo = {};
		SItemInfoVo.uid, idx = readGuid(pak, idx);
		SItemInfoVo.apply, idx = readByte(pak, idx);
		SItemInfoVo.cid, idx = readInt(pak, idx);
		SItemInfoVo.strenLvl, idx = readInt(pak, idx);
		SItemInfoVo.emptystarnum, idx = readInt(pak, idx);
		SItemInfoVo.attrAddLvl, idx = readInt(pak, idx);
		SItemInfoVo.groupId, idx = readInt(pak, idx);
		SItemInfoVo.groupId2, idx = readInt(pak, idx);
		SItemInfoVo.group2Level, idx = readInt(pak, idx);
		SItemInfoVo.superNum, idx = readInt(pak, idx);
		table.push(list1,SItemInfoVo);

		local list2 = {};
		SItemInfoVo.superList = list2;
		local list2Size = 7;

		for i=1,list2Size do
			local SuperVOVo = {};
			SuperVOVo.uid, idx = readGuid(pak, idx);
			SuperVOVo.id, idx = readInt(pak, idx);
			SuperVOVo.val1, idx = readInt(pak, idx);
			table.push(list2,SuperVOVo);
		end

		local list3 = {};
		SItemInfoVo.newSuperList = list3;
		local list3Size = 3;

		for i=1,list3Size do
			local NewSuperVOVo = {};
			NewSuperVOVo.id, idx = readInt(pak, idx);
			NewSuperVOVo.wash, idx = readInt(pak, idx);
			table.push(list3,NewSuperVOVo);
		end
	end

end



--[[
服知: 帮派仓库物品删除
]]

_G.RespUnionWareremoveMsg = {};

RespUnionWareremoveMsg.msgId = 7131;
RespUnionWareremoveMsg.items_size = 0; -- 物品列表 size
RespUnionWareremoveMsg.items = {}; -- 物品列表 list



--[[
SItemInfoVO = {
	uid = ""; -- 物品uid
}
]]

RespUnionWareremoveMsg.meta = {__index = RespUnionWareremoveMsg};
function RespUnionWareremoveMsg:new()
	local obj = setmetatable( {}, RespUnionWareremoveMsg.meta);
	return obj;
end

function RespUnionWareremoveMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.items = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local SItemInfoVo = {};
		SItemInfoVo.uid, idx = readGuid(pak, idx);
		table.push(list1,SItemInfoVo);
	end

end



--[[
返回微端登录url
]]

_G.RespMClientLoginUrlMsg = {};

RespMClientLoginUrlMsg.msgId = 7135;
RespMClientLoginUrlMsg.url = ""; -- 微端登录url



RespMClientLoginUrlMsg.meta = {__index = RespMClientLoginUrlMsg};
function RespMClientLoginUrlMsg:new()
	local obj = setmetatable( {}, RespMClientLoginUrlMsg.meta);
	return obj;
end

function RespMClientLoginUrlMsg:ParseData(pak)
	local idx = 1;

	self.url, idx = readString(pak, idx);

end



--[[
心跳
]]

_G.RespHeartBeatMsg = {};

RespHeartBeatMsg.msgId = 7136;
RespHeartBeatMsg.time = 0; -- time



RespHeartBeatMsg.meta = {__index = RespHeartBeatMsg};
function RespHeartBeatMsg:new()
	local obj = setmetatable( {}, RespHeartBeatMsg.meta);
	return obj;
end

function RespHeartBeatMsg:ParseData(pak)
	local idx = 1;

	self.time, idx = readInt64(pak, idx);

end



--[[
服务器通知：战场报名
]]

_G.RespZhancSignUpMsg = {};

RespZhancSignUpMsg.msgId = 7137;
RespZhancSignUpMsg.type = 0; -- 0--未报名， 1--报名



RespZhancSignUpMsg.meta = {__index = RespZhancSignUpMsg};
function RespZhancSignUpMsg:new()
	local obj = setmetatable( {}, RespZhancSignUpMsg.meta);
	return obj;
end

function RespZhancSignUpMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
返回平台V信息
]]

_G.RespVPlanMsg = {};

RespVPlanMsg.msgId = 7138;
RespVPlanMsg.type = 0; -- V类型
RespVPlanMsg.level = 0; -- V等级



RespVPlanMsg.meta = {__index = RespVPlanMsg};
function RespVPlanMsg:new()
	local obj = setmetatable( {}, RespVPlanMsg.meta);
	return obj;
end

function RespVPlanMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readByte(pak, idx);
	self.level, idx = readByte(pak, idx);

end



--[[
服务器返回：获得帮派祈福信息
]]

_G.RespGetUnionPrayMsg = {};

RespGetUnionPrayMsg.msgId = 7139;
RespGetUnionPrayMsg.isPray1 = 0; -- 普通祈福 0未祈福，1已祈福
RespGetUnionPrayMsg.isPray2 = 0; -- 高级祈福 0未祈福，1已祈福
RespGetUnionPrayMsg.isPray3 = 0; -- 至尊祈福 0未祈福，1已祈福
RespGetUnionPrayMsg.praylist_size = 0; -- 今天帮派祈福列表 size
RespGetUnionPrayMsg.praylist = {}; -- 今天帮派祈福列表 list



--[[
PrayVoVO = {
	time = 0; -- 祈福时间
	roleName = ""; -- 人物名称
	prayid = 0; -- 祈福类型id
}
]]

RespGetUnionPrayMsg.meta = {__index = RespGetUnionPrayMsg};
function RespGetUnionPrayMsg:new()
	local obj = setmetatable( {}, RespGetUnionPrayMsg.meta);
	return obj;
end

function RespGetUnionPrayMsg:ParseData(pak)
	local idx = 1;

	self.isPray1, idx = readInt(pak, idx);
	self.isPray2, idx = readInt(pak, idx);
	self.isPray3, idx = readInt(pak, idx);

	local list1 = {};
	self.praylist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local PrayVoVo = {};
		PrayVoVo.time, idx = readInt64(pak, idx);
		PrayVoVo.roleName, idx = readString(pak, idx, 32);
		PrayVoVo.prayid, idx = readInt(pak, idx);
		table.push(list1,PrayVoVo);
	end

end



--[[
服务器返回：其他玩家祈福增加帮派祈福信息
]]

_G.RespUnionPrayAddMsg = {};

RespUnionPrayAddMsg.msgId = 7140;
RespUnionPrayAddMsg.time = 0; -- 祈福时间
RespUnionPrayAddMsg.roleName = ""; -- 人物名称
RespUnionPrayAddMsg.prayid = 0; -- 祈福类型id



RespUnionPrayAddMsg.meta = {__index = RespUnionPrayAddMsg};
function RespUnionPrayAddMsg:new()
	local obj = setmetatable( {}, RespUnionPrayAddMsg.meta);
	return obj;
end

function RespUnionPrayAddMsg:ParseData(pak)
	local idx = 1;

	self.time, idx = readInt64(pak, idx);
	self.roleName, idx = readString(pak, idx, 32);
	self.prayid, idx = readInt(pak, idx);

end



--[[
服务器返回：帮派祈福结果
]]

_G.RespUnionPrayMsg = {};

RespUnionPrayMsg.msgId = 7141;
RespUnionPrayMsg.result = 0; -- 请求服务器返回：获得结果 0:成功(成功获得),1:失败
RespUnionPrayMsg.prayid = 0; -- 祈福类型id



RespUnionPrayMsg.meta = {__index = RespUnionPrayMsg};
function RespUnionPrayMsg:new()
	local obj = setmetatable( {}, RespUnionPrayMsg.meta);
	return obj;
end

function RespUnionPrayMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.prayid, idx = readInt(pak, idx);

end



--[[
返回寄售行物品
]]

_G.RespConsignmentItemInfoMsg = {};

RespConsignmentItemInfoMsg.msgId = 7142;
RespConsignmentItemInfoMsg.type = 0; -- 0=寄售行信息，1=我寄售行信息
RespConsignmentItemInfoMsg.curPage = 0; -- 当前页数
RespConsignmentItemInfoMsg.tatlPage = 0; -- 总页数
RespConsignmentItemInfoMsg.consignlist_size = 0; -- 寄售物品 size
RespConsignmentItemInfoMsg.consignlist = {}; -- 寄售物品 list



--[[
itemVO = {
	uid = ""; -- 寄售行记录id
	cid = 0; -- 物品id
	num = 0; -- 数量
	lastTime = 0; -- 剩余时间
	roleName = ""; -- 出售者角色名字
	price = 0; -- 出售单价
	strenLvl = 0; -- 强化等级(翅膀时代表到期时间)
	refinLvl = 0; -- 炼化等级(翅膀时代表是否特殊属性)
	strenId = 0; -- 升星强化等级
	emptystarnum = 0; -- 空星位数
	attrAddLvl = 0; -- 追加属性等级
	groupId = 0; -- 套装id
	groupId2 = 0; -- 套装id2
	group2Level = 0; -- 套装2的等级
	superNum = 0; -- 卓越数量
	superList_size = 7; -- 卓越属性列表 size
	superList = {}; -- 卓越属性列表 list
	newSuperList_size = 3; -- 新卓越属性列表 size
	newSuperList = {}; -- 新卓越属性列表 list
}
SuperVOVO = {
	uid = ""; -- 属性uid
	id = 0; -- 卓越id
	val1 = 0; -- 值1
}
NewSuperVOVO = {
	id = 0; -- 新卓越id
	wash = 0; -- 洗练值
}
]]

RespConsignmentItemInfoMsg.meta = {__index = RespConsignmentItemInfoMsg};
function RespConsignmentItemInfoMsg:new()
	local obj = setmetatable( {}, RespConsignmentItemInfoMsg.meta);
	return obj;
end

function RespConsignmentItemInfoMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.curPage, idx = readInt(pak, idx);
	self.tatlPage, idx = readInt(pak, idx);

	local list1 = {};
	self.consignlist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local itemVo = {};
		itemVo.uid, idx = readGuid(pak, idx);
		itemVo.cid, idx = readInt(pak, idx);
		itemVo.num, idx = readInt(pak, idx);
		itemVo.lastTime, idx = readInt(pak, idx);
		itemVo.roleName, idx = readString(pak, idx, 32);
		itemVo.price, idx = readInt(pak, idx);
		itemVo.strenLvl, idx = readInt(pak, idx);
		itemVo.refinLvl, idx = readInt(pak, idx);
		itemVo.strenId, idx = readInt(pak, idx);
		itemVo.emptystarnum, idx = readInt(pak, idx);
		itemVo.attrAddLvl, idx = readInt(pak, idx);
		itemVo.groupId, idx = readInt(pak, idx);
		itemVo.groupId2, idx = readInt(pak, idx);
		itemVo.group2Level, idx = readInt(pak, idx);
		itemVo.superNum, idx = readInt(pak, idx);
		table.push(list1,itemVo);

		local list2 = {};
		itemVo.superList = list2;
		local list2Size = 7;

		for i=1,list2Size do
			local SuperVOVo = {};
			SuperVOVo.uid, idx = readGuid(pak, idx);
			SuperVOVo.id, idx = readInt(pak, idx);
			SuperVOVo.val1, idx = readInt(pak, idx);
			table.push(list2,SuperVOVo);
		end

		local list2 = {};
		itemVo.newSuperList = list2;
		local list2Size = 3;

		for i=1,list2Size do
			local NewSuperVOVo = {};
			NewSuperVOVo.id, idx = readInt(pak, idx);
			NewSuperVOVo.wash, idx = readInt(pak, idx);
			table.push(list2,NewSuperVOVo);
		end
	end

end



--[[
购买返回
]]

_G.RespConsignmentItemBuyMsg = {};

RespConsignmentItemBuyMsg.msgId = 7143;
RespConsignmentItemBuyMsg.uid = ""; -- 寄售行记录id
RespConsignmentItemBuyMsg.result = 0; -- 购买结果 0=成功 1:功能未开启 2：物品已下架 3=失败数量不足 4：不能购买自己的 5=金钱不足  6=背包满了 ，7其他失败



RespConsignmentItemBuyMsg.meta = {__index = RespConsignmentItemBuyMsg};
function RespConsignmentItemBuyMsg:new()
	local obj = setmetatable( {}, RespConsignmentItemBuyMsg.meta);
	return obj;
end

function RespConsignmentItemBuyMsg:ParseData(pak)
	local idx = 1;

	self.uid, idx = readGuid(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
物品下架
]]

_G.RespConsignmentItemOutShelvesMsg = {};

RespConsignmentItemOutShelvesMsg.msgId = 7144;
RespConsignmentItemOutShelvesMsg.result = 0; -- 结果：0成功 2:物品已下架或已被购买 3:背包满了
RespConsignmentItemOutShelvesMsg.isall = 0; -- 是否全部下架，0=true



RespConsignmentItemOutShelvesMsg.meta = {__index = RespConsignmentItemOutShelvesMsg};
function RespConsignmentItemOutShelvesMsg:new()
	local obj = setmetatable( {}, RespConsignmentItemOutShelvesMsg.meta);
	return obj;
end

function RespConsignmentItemOutShelvesMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.isall, idx = readInt(pak, idx);

end



--[[
返回可领取好友礼包
]]

_G.RespFriendRewardMsg = {};

RespFriendRewardMsg.msgId = 7145;
RespFriendRewardMsg.roleID = ""; -- 角色ID
RespFriendRewardMsg.roleName = ""; -- 角色名称
RespFriendRewardMsg.level = 0; -- 等级



RespFriendRewardMsg.meta = {__index = RespFriendRewardMsg};
function RespFriendRewardMsg:new()
	local obj = setmetatable( {}, RespFriendRewardMsg.meta);
	return obj;
end

function RespFriendRewardMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.roleName, idx = readString(pak, idx, 32);
	self.level, idx = readInt(pak, idx);

end



--[[
返回领取好友礼包
]]

_G.RespFriendRewardGetMsg = {};

RespFriendRewardGetMsg.msgId = 7146;
RespFriendRewardGetMsg.result = 0; -- 结果：0成功



RespFriendRewardGetMsg.meta = {__index = RespFriendRewardGetMsg};
function RespFriendRewardGetMsg:new()
	local obj = setmetatable( {}, RespFriendRewardGetMsg.meta);
	return obj;
end

function RespFriendRewardGetMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回盈利信息
]]

_G.RespMyConsignmentEarnInfoMsg = {};

RespMyConsignmentEarnInfoMsg.msgId = 7148;
RespMyConsignmentEarnInfoMsg.gold = 0; -- 交易获得金币
RespMyConsignmentEarnInfoMsg.earnlist_size = 0; -- 寄售物品 size
RespMyConsignmentEarnInfoMsg.earnlist = {}; -- 寄售物品 list



--[[
itemVO = {
	cid = 0; -- 表id
	num = 0; -- 数量
	lastTime = 0; -- 交易完成时间
	roleName = ""; -- 购买者角色名字
	monet = 0; -- 收益货币数量
}
]]

RespMyConsignmentEarnInfoMsg.meta = {__index = RespMyConsignmentEarnInfoMsg};
function RespMyConsignmentEarnInfoMsg:new()
	local obj = setmetatable( {}, RespMyConsignmentEarnInfoMsg.meta);
	return obj;
end

function RespMyConsignmentEarnInfoMsg:ParseData(pak)
	local idx = 1;

	self.gold, idx = readInt64(pak, idx);

	local list1 = {};
	self.earnlist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local itemVo = {};
		itemVo.cid, idx = readInt(pak, idx);
		itemVo.num, idx = readInt(pak, idx);
		itemVo.lastTime, idx = readInt64(pak, idx);
		itemVo.roleName, idx = readString(pak, idx, 32);
		itemVo.monet, idx = readInt(pak, idx);
		table.push(list1,itemVo);
	end

end



--[[
帮派申请人数
]]

_G.RespGuildReplyCountTipMsg = {};

RespGuildReplyCountTipMsg.msgId = 7149;
RespGuildReplyCountTipMsg.replyNum = 0; -- 帮派申请人数



RespGuildReplyCountTipMsg.meta = {__index = RespGuildReplyCountTipMsg};
function RespGuildReplyCountTipMsg:new()
	local obj = setmetatable( {}, RespGuildReplyCountTipMsg.meta);
	return obj;
end

function RespGuildReplyCountTipMsg:ParseData(pak)
	local idx = 1;

	self.replyNum, idx = readInt(pak, idx);

end



--[[
服务器返回：新版极限挑战排行榜UIdata
]]

_G.RespBackExtremityRankDataMsg = {};

RespBackExtremityRankDataMsg.msgId = 7150;
RespBackExtremityRankDataMsg.bossRankList_size = 10; -- BOSS排行榜 size
RespBackExtremityRankDataMsg.bossRankList = {}; -- BOSS排行榜 list
RespBackExtremityRankDataMsg.monsterRankList_size = 10; -- 小怪排行榜 size
RespBackExtremityRankDataMsg.monsterRankList = {}; -- 小怪排行榜 list



--[[
bossRankListVO = {
	roleId = ""; -- 玩家guid
	roleRank = 0; -- 玩家名次
	roleName = ""; -- 玩家名称
	roleHarm = 0; -- 玩家伤害数值
}
]]
--[[
monsterRankListVO = {
	roleId = ""; -- 玩家guid
	roleRank = 0; -- 玩家名次
	roleName = ""; -- 玩家名称
	roleNum = 0; -- 玩家击杀数量
}
]]

RespBackExtremityRankDataMsg.meta = {__index = RespBackExtremityRankDataMsg};
function RespBackExtremityRankDataMsg:new()
	local obj = setmetatable( {}, RespBackExtremityRankDataMsg.meta);
	return obj;
end

function RespBackExtremityRankDataMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.bossRankList = list1;
	local list1Size = 10;

	for i=1,list1Size do
		local bossRankListVo = {};
		bossRankListVo.roleId, idx = readGuid(pak, idx);
		bossRankListVo.roleRank, idx = readByte(pak, idx);
		bossRankListVo.roleName, idx = readString(pak, idx, 32);
		bossRankListVo.roleHarm, idx = readInt64(pak, idx);
		table.push(list1,bossRankListVo);
	end

	local list2 = {};
	self.monsterRankList = list2;
	local list2Size = 10;

	for i=1,list2Size do
		local monsterRankListVo = {};
		monsterRankListVo.roleId, idx = readGuid(pak, idx);
		monsterRankListVo.roleRank, idx = readByte(pak, idx);
		monsterRankListVo.roleName, idx = readString(pak, idx, 32);
		monsterRankListVo.roleNum, idx = readInt64(pak, idx);
		table.push(list2,monsterRankListVo);
	end

end



--[[
服务器返回：新版极限挑战UIdata
]]

_G.RespBackNewExtremityDataMsg = {};

RespBackNewExtremityDataMsg.msgId = 7151;
RespBackNewExtremityDataMsg.bossRank = 0; -- 自己boss排名
RespBackNewExtremityDataMsg.bossHarm = 0; -- 自己boss伤害
RespBackNewExtremityDataMsg.bossJoinNum = 0; -- boss参加总人数
RespBackNewExtremityDataMsg.monsterRank = 0; -- 自己小怪排名
RespBackNewExtremityDataMsg.monsterNum = 0; -- 自己小怪数量
RespBackNewExtremityDataMsg.monsterJoinNum = 0; -- 小怪参加总人数
RespBackNewExtremityDataMsg.bossState = 0; -- BOSS排行榜领奖状态 0 未领取
RespBackNewExtremityDataMsg.monsterState = 0; -- Monster排行榜领奖状态 0 未领取



RespBackNewExtremityDataMsg.meta = {__index = RespBackNewExtremityDataMsg};
function RespBackNewExtremityDataMsg:new()
	local obj = setmetatable( {}, RespBackNewExtremityDataMsg.meta);
	return obj;
end

function RespBackNewExtremityDataMsg:ParseData(pak)
	local idx = 1;

	self.bossRank, idx = readInt(pak, idx);
	self.bossHarm, idx = readInt64(pak, idx);
	self.bossJoinNum, idx = readInt(pak, idx);
	self.monsterRank, idx = readInt(pak, idx);
	self.monsterNum, idx = readInt(pak, idx);
	self.monsterJoinNum, idx = readInt(pak, idx);
	self.bossState, idx = readInt(pak, idx);
	self.monsterState, idx = readInt(pak, idx);

end



--[[
服务器返回：排名
]]

_G.RespExtremityRankDataMsg = {};

RespExtremityRankDataMsg.msgId = 7152;
RespExtremityRankDataMsg.rankNum = 0; -- 排名



RespExtremityRankDataMsg.meta = {__index = RespExtremityRankDataMsg};
function RespExtremityRankDataMsg:new()
	local obj = setmetatable( {}, RespExtremityRankDataMsg.meta);
	return obj;
end

function RespExtremityRankDataMsg:ParseData(pak)
	local idx = 1;

	self.rankNum, idx = readInt(pak, idx);

end



--[[
服务器返回:所有房间信息
]]

_G.RespTimeDungeonRoomListMsg = {};

RespTimeDungeonRoomListMsg.msgId = 7153;
RespTimeDungeonRoomListMsg.list_size = 0; -- 房间列表 size
RespTimeDungeonRoomListMsg.list = {}; -- 房间列表 list



--[[
roomVOVO = {
	roomID = ""; -- roomID
	dungeonIndex = 0; -- 副本难度 1 2 3 4 5 
	capName = ""; -- 队长名称
	att = 0; -- 战斗力需求 0:无限制
	lock = 0; -- 锁 0 true 1 false
	roomNum = 0; -- 房间人数
}
]]

RespTimeDungeonRoomListMsg.meta = {__index = RespTimeDungeonRoomListMsg};
function RespTimeDungeonRoomListMsg:new()
	local obj = setmetatable( {}, RespTimeDungeonRoomListMsg.meta);
	return obj;
end

function RespTimeDungeonRoomListMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local roomVOVo = {};
		roomVOVo.roomID, idx = readGuid(pak, idx);
		roomVOVo.dungeonIndex, idx = readByte(pak, idx);
		roomVOVo.capName, idx = readString(pak, idx, 32);
		roomVOVo.att, idx = readInt(pak, idx);
		roomVOVo.lock, idx = readByte(pak, idx);
		roomVOVo.roomNum, idx = readByte(pak, idx);
		table.push(list1,roomVOVo);
	end

end



--[[
服务器返回:自己房间信息
]]

_G.RespTimeDungeonRoomInfoMsg = {};

RespTimeDungeonRoomInfoMsg.msgId = 7154;
RespTimeDungeonRoomInfoMsg.dungeonIndex = 0; -- 副本难度 1 2 3 4 5 
RespTimeDungeonRoomInfoMsg.lock = 0; -- 锁 0 true 1 false
RespTimeDungeonRoomInfoMsg.lockAttNum = 0; -- 战斗力限制值 0:无限制
RespTimeDungeonRoomInfoMsg.autoStart = 0; -- 自动开始 0 true



RespTimeDungeonRoomInfoMsg.meta = {__index = RespTimeDungeonRoomInfoMsg};
function RespTimeDungeonRoomInfoMsg:new()
	local obj = setmetatable( {}, RespTimeDungeonRoomInfoMsg.meta);
	return obj;
end

function RespTimeDungeonRoomInfoMsg:ParseData(pak)
	local idx = 1;

	self.dungeonIndex, idx = readByte(pak, idx);
	self.lock, idx = readByte(pak, idx);
	self.lockAttNum, idx = readInt(pak, idx);
	self.autoStart, idx = readInt(pak, idx);

end



--[[
服务器返回:准备状态
]]

_G.RespTimeDungeonPrepareMsg = {};

RespTimeDungeonPrepareMsg.msgId = 7157;
RespTimeDungeonPrepareMsg.prepare = 0; -- 准备状态 0 true 1 false



RespTimeDungeonPrepareMsg.meta = {__index = RespTimeDungeonPrepareMsg};
function RespTimeDungeonPrepareMsg:new()
	local obj = setmetatable( {}, RespTimeDungeonPrepareMsg.meta);
	return obj;
end

function RespTimeDungeonPrepareMsg:ParseData(pak)
	local idx = 1;

	self.prepare, idx = readByte(pak, idx);

end



--[[
服务器返回:退出房间
]]

_G.RespQuitTimeDungeonRoomMsg = {};

RespQuitTimeDungeonRoomMsg.msgId = 7158;
RespQuitTimeDungeonRoomMsg.result = 0; -- 结果 0 true



RespQuitTimeDungeonRoomMsg.meta = {__index = RespQuitTimeDungeonRoomMsg};
function RespQuitTimeDungeonRoomMsg:new()
	local obj = setmetatable( {}, RespQuitTimeDungeonRoomMsg.meta);
	return obj;
end

function RespQuitTimeDungeonRoomMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回：返回领取排行榜奖励
]]

_G.RespBackExtremityRewardMsg = {};

RespBackExtremityRewardMsg.msgId = 7159;
RespBackExtremityRewardMsg.result = 0; -- 领取结果 0 成功 
RespBackExtremityRewardMsg.type = 0; -- 领取类型 0 BOSS 1 小怪



RespBackExtremityRewardMsg.meta = {__index = RespBackExtremityRewardMsg};
function RespBackExtremityRewardMsg:new()
	local obj = setmetatable( {}, RespBackExtremityRewardMsg.meta);
	return obj;
end

function RespBackExtremityRewardMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
服务器返回：帮派仓库次数更新
]]

_G.RespUnionWareMyNumInfoMsg = {};

RespUnionWareMyNumInfoMsg.msgId = 7164;
RespUnionWareMyNumInfoMsg.maxIn = 0; -- 还剩几次放入



RespUnionWareMyNumInfoMsg.meta = {__index = RespUnionWareMyNumInfoMsg};
function RespUnionWareMyNumInfoMsg:new()
	local obj = setmetatable( {}, RespUnionWareMyNumInfoMsg.meta);
	return obj;
end

function RespUnionWareMyNumInfoMsg:ParseData(pak)
	local idx = 1;

	self.maxIn, idx = readInt(pak, idx);

end



--[[
服务器返回：常置公告
]]

_G.RespAlwaysNoticeMsg = {};

RespAlwaysNoticeMsg.msgId = 7165;
RespAlwaysNoticeMsg.link = ""; -- 链接
RespAlwaysNoticeMsg.link_name = ""; -- 链接
RespAlwaysNoticeMsg.content = ""; -- 内容



RespAlwaysNoticeMsg.meta = {__index = RespAlwaysNoticeMsg};
function RespAlwaysNoticeMsg:new()
	local obj = setmetatable( {}, RespAlwaysNoticeMsg.meta);
	return obj;
end

function RespAlwaysNoticeMsg:ParseData(pak)
	local idx = 1;

	self.link, idx = readString(pak, idx, 64);
	self.link_name, idx = readString(pak, idx, 64);
	self.content, idx = readString(pak, idx);

end



--[[
准备tips
]]

_G.RespTimeDungeonStartTipMsg = {};

RespTimeDungeonStartTipMsg.msgId = 7166;
RespTimeDungeonStartTipMsg.id = 0; -- 难度ID



RespTimeDungeonStartTipMsg.meta = {__index = RespTimeDungeonStartTipMsg};
function RespTimeDungeonStartTipMsg:new()
	local obj = setmetatable( {}, RespTimeDungeonStartTipMsg.meta);
	return obj;
end

function RespTimeDungeonStartTipMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
返回开启结果
]]

_G.RespUnionBossActivityOpenMsg = {};

RespUnionBossActivityOpenMsg.msgId = 7167;
RespUnionBossActivityOpenMsg.result = 0; -- 1=开启成功，2=资金不足，3= 等级不足



RespUnionBossActivityOpenMsg.meta = {__index = RespUnionBossActivityOpenMsg};
function RespUnionBossActivityOpenMsg:new()
	local obj = setmetatable( {}, RespUnionBossActivityOpenMsg.meta);
	return obj;
end

function RespUnionBossActivityOpenMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
成员上线推，全员提醒
]]

_G.RespUnionBossActivityRemindMsg = {};

RespUnionBossActivityRemindMsg.msgId = 7168;
RespUnionBossActivityRemindMsg.result = 0; -- 0=未开启,1=已开启过，2=活动正在进行中
RespUnionBossActivityRemindMsg.lastTime = 0; -- 活动剩余时间(/秒)
RespUnionBossActivityRemindMsg.id = 0; -- 对呀表id



RespUnionBossActivityRemindMsg.meta = {__index = RespUnionBossActivityRemindMsg};
function RespUnionBossActivityRemindMsg:new()
	local obj = setmetatable( {}, RespUnionBossActivityRemindMsg.meta);
	return obj;
end

function RespUnionBossActivityRemindMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.lastTime, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
进入结果
]]

_G.RespUnionBossActivityEnterResultMsg = {};

RespUnionBossActivityEnterResultMsg.msgId = 7169;
RespUnionBossActivityEnterResultMsg.result = 0; -- 0=成功,1=失败，2=未开启
RespUnionBossActivityEnterResultMsg.lineID = 0; -- 线ID



RespUnionBossActivityEnterResultMsg.meta = {__index = RespUnionBossActivityEnterResultMsg};
function RespUnionBossActivityEnterResultMsg:new()
	local obj = setmetatable( {}, RespUnionBossActivityEnterResultMsg.meta);
	return obj;
end

function RespUnionBossActivityEnterResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.lineID, idx = readInt(pak, idx);

end



--[[
家园建筑信息
]]

_G.RespHomesBuildInfoMsg = {};

RespHomesBuildInfoMsg.msgId = 7170;
RespHomesBuildInfoMsg.list_size = 0; -- 建筑信息 size
RespHomesBuildInfoMsg.list = {}; -- 建筑信息 list



--[[
infovoVO = {
	buildType = 0; -- 建筑类型,1=主建筑，2=寻仙台，3=宗门任务
	lvl = 0; -- 建筑等级,0=未解锁
}
]]

RespHomesBuildInfoMsg.meta = {__index = RespHomesBuildInfoMsg};
function RespHomesBuildInfoMsg:new()
	local obj = setmetatable( {}, RespHomesBuildInfoMsg.meta);
	return obj;
end

function RespHomesBuildInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local infovoVo = {};
		infovoVo.buildType, idx = readInt(pak, idx);
		infovoVo.lvl, idx = readInt(pak, idx);
		table.push(list1,infovoVo);
	end

end



--[[
升级返回
]]

_G.RespHomesBuildUplvlresultMsg = {};

RespHomesBuildUplvlresultMsg.msgId = 7171;
RespHomesBuildUplvlresultMsg.result = 0; -- 升级结果 0=成功，-1:类型不对 -2:大殿等级不足 -3:消耗配置错误 -4:元宝或物品不足 -5:等待服务器返回
RespHomesBuildUplvlresultMsg.buildType = 0; -- 建筑类型,1=主建筑，2=寻仙台，3=宗门任务
RespHomesBuildUplvlresultMsg.lvl = 0; -- 建筑等级



RespHomesBuildUplvlresultMsg.meta = {__index = RespHomesBuildUplvlresultMsg};
function RespHomesBuildUplvlresultMsg:new()
	local obj = setmetatable( {}, RespHomesBuildUplvlresultMsg.meta);
	return obj;
end

function RespHomesBuildUplvlresultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.buildType, idx = readInt(pak, idx);
	self.lvl, idx = readInt(pak, idx);

end



--[[
我的宗门弟子信息
]]

_G.RespHomesZongminfoMsg = {};

RespHomesZongminfoMsg.msgId = 7172;
RespHomesZongminfoMsg.type = 0; -- 推送类型，1=all，2=单个
RespHomesZongminfoMsg.list_size = 0; -- 弟子信息 size
RespHomesZongminfoMsg.list = {}; -- 弟子信息 list



--[[
infovoVO = {
	roleName = ""; -- 名字
	iconId = 0; -- 头像id
	guid = ""; -- id
	lvl = 0; -- 等级
	exp = 0; -- 经验
	quality = 0; -- 品质
	queststeat = 0; -- 任务状态，1=闲置，2=已接任务
	atb = 0; -- 属性，1=金····
	skills_size = 3; -- 技能列表 size
	skills = {}; -- 技能列表 list
}
SkillInfoVO = {
	skillId = 0; -- 技能id
}
]]

RespHomesZongminfoMsg.meta = {__index = RespHomesZongminfoMsg};
function RespHomesZongminfoMsg:new()
	local obj = setmetatable( {}, RespHomesZongminfoMsg.meta);
	return obj;
end

function RespHomesZongminfoMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local infovoVo = {};
		infovoVo.roleName, idx = readString(pak, idx, 32);
		infovoVo.iconId, idx = readInt(pak, idx);
		infovoVo.guid, idx = readGuid(pak, idx);
		infovoVo.lvl, idx = readInt(pak, idx);
		infovoVo.exp, idx = readInt(pak, idx);
		infovoVo.quality, idx = readInt(pak, idx);
		infovoVo.queststeat, idx = readInt(pak, idx);
		infovoVo.atb, idx = readInt(pak, idx);
		table.push(list1,infovoVo);

		local list = {};
		infovoVo.skills = list;
		local listSize = 3;

		for i=1,listSize do
			local SkillInfoVo = {};
			SkillInfoVo.skillId, idx = readInt(pak, idx);
			table.push(list,SkillInfoVo);
		end
	end

end



--[[
寻仙台弟子刷新
]]

_G.RespHomesXunxianMsg = {};

RespHomesXunxianMsg.msgId = 7173;
RespHomesXunxianMsg.result = 0; -- 结果0=成功-1条件不足 -2:等待服务器返回
RespHomesXunxianMsg.lasttime = 0; -- 下次刷新时间
RespHomesXunxianMsg.cnt = 0; -- 刷新次数
RespHomesXunxianMsg.recruit = 0; -- 招募次数
RespHomesXunxianMsg.list_size = 0; -- 弟子信息 size
RespHomesXunxianMsg.list = {}; -- 弟子信息 list



--[[
infovoVO = {
	lvl = 0; -- 等级
	roleName = ""; -- 名字
	iconId = 0; -- 头像id
	guid = ""; -- id
	quality = 0; -- 品质
	atb = 0; -- 属性，1=金····
	state = 0; -- 招募状态
	skills_size = 3; -- 技能列表 size
	skills = {}; -- 技能列表 list
}
SkillInfoVO = {
	skillId = 0; -- 技能id
}
]]

RespHomesXunxianMsg.meta = {__index = RespHomesXunxianMsg};
function RespHomesXunxianMsg:new()
	local obj = setmetatable( {}, RespHomesXunxianMsg.meta);
	return obj;
end

function RespHomesXunxianMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.lasttime, idx = readInt(pak, idx);
	self.cnt, idx = readInt(pak, idx);
	self.recruit, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local infovoVo = {};
		infovoVo.lvl, idx = readInt(pak, idx);
		infovoVo.roleName, idx = readString(pak, idx, 32);
		infovoVo.iconId, idx = readInt(pak, idx);
		infovoVo.guid, idx = readGuid(pak, idx);
		infovoVo.quality, idx = readInt(pak, idx);
		infovoVo.atb, idx = readInt(pak, idx);
		infovoVo.state, idx = readInt(pak, idx);
		table.push(list1,infovoVo);

		local list = {};
		infovoVo.skills = list;
		local listSize = 3;

		for i=1,listSize do
			local SkillInfoVo = {};
			SkillInfoVo.skillId, idx = readInt(pak, idx);
			table.push(list,SkillInfoVo);
		end
	end

end



--[[
弟子招募
]]

_G.RespHomesPupilEnlistMsg = {};

RespHomesPupilEnlistMsg.msgId = 7174;
RespHomesPupilEnlistMsg.result = 0; -- 招募结果 0=成功，-1=达到最大数量 -2:弟子不存在 -3:弟子已招募 -4:钱不够



RespHomesPupilEnlistMsg.meta = {__index = RespHomesPupilEnlistMsg};
function RespHomesPupilEnlistMsg:new()
	local obj = setmetatable( {}, RespHomesPupilEnlistMsg.meta);
	return obj;
end

function RespHomesPupilEnlistMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
弟子销毁
]]

_G.RespHomesPupildestoryMsg = {};

RespHomesPupildestoryMsg.msgId = 7175;
RespHomesPupildestoryMsg.guid = ""; -- 弟子id
RespHomesPupildestoryMsg.result = 0; -- 销毁结果 0=成功，-2=弟子不存在 -3:弟子状态



RespHomesPupildestoryMsg.meta = {__index = RespHomesPupildestoryMsg};
function RespHomesPupildestoryMsg:new()
	local obj = setmetatable( {}, RespHomesPupildestoryMsg.meta);
	return obj;
end

function RespHomesPupildestoryMsg:ParseData(pak)
	local idx = 1;

	self.guid, idx = readGuid(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
我的任务信息
]]

_G.RespHomesMyQuestInfoMsg = {};

RespHomesMyQuestInfoMsg.msgId = 7176;
RespHomesMyQuestInfoMsg.list_size = 0; -- 任务信息 size
RespHomesMyQuestInfoMsg.list = {}; -- 任务信息 list



--[[
infovoVO = {
	guid = ""; -- uid
	tid = 0; -- 表id
	lastTime = 0; -- 完成剩余时间
	questlvl = 0; -- 任务等级
	MaxTime = 0; -- 完成总时间
	rewardType = 0; -- 奖励type
	rewardNum = 0; -- 奖励数量
	pupilExp = 0; -- 弟子经验
	itemid = 0; -- 物品id
	quality = 0; -- 品质
	status = 0; -- 是否成功
}
]]

RespHomesMyQuestInfoMsg.meta = {__index = RespHomesMyQuestInfoMsg};
function RespHomesMyQuestInfoMsg:new()
	local obj = setmetatable( {}, RespHomesMyQuestInfoMsg.meta);
	return obj;
end

function RespHomesMyQuestInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local infovoVo = {};
		infovoVo.guid, idx = readGuid(pak, idx);
		infovoVo.tid, idx = readInt(pak, idx);
		infovoVo.lastTime, idx = readInt(pak, idx);
		infovoVo.questlvl, idx = readInt(pak, idx);
		infovoVo.MaxTime, idx = readInt(pak, idx);
		infovoVo.rewardType, idx = readInt(pak, idx);
		infovoVo.rewardNum, idx = readInt64(pak, idx);
		infovoVo.pupilExp, idx = readInt64(pak, idx);
		infovoVo.itemid, idx = readInt(pak, idx);
		infovoVo.quality, idx = readInt(pak, idx);
		infovoVo.status, idx = readInt(pak, idx);
		table.push(list1,infovoVo);
	end

end



--[[
任务殿信息
]]

_G.RespHomesQuestInfoMsg = {};

RespHomesQuestInfoMsg.msgId = 7177;
RespHomesQuestInfoMsg.result = 0; -- 结果0=成功-1条件不足 -2:等待服务器返回
RespHomesQuestInfoMsg.lasttime = 0; -- 下次刷新时间
RespHomesQuestInfoMsg.cnt = 0; -- 刷新次数
RespHomesQuestInfoMsg.list_size = 0; -- 任务信息 size
RespHomesQuestInfoMsg.list = {}; -- 任务信息 list



--[[
infovoVO = {
	guid = ""; -- uid
	tid = 0; -- 表id
	time = 0; -- 完成时间
	rewardType = 0; -- 奖励type
	questlvl = 0; -- 任务等级
	rewardNum = 0; -- 奖励数量
	pupilExp = 0; -- 弟子经验
	itemid = 0; -- 物品id
	quality = 0; -- 品质
	questState = 0; -- 任务领取状态，1已领取0未领取
	list_size = 3; -- 怪物id size
	list = {}; -- 怪物id list
}
monsterVoVO = {
	id = 0; -- 怪物id
}
]]

RespHomesQuestInfoMsg.meta = {__index = RespHomesQuestInfoMsg};
function RespHomesQuestInfoMsg:new()
	local obj = setmetatable( {}, RespHomesQuestInfoMsg.meta);
	return obj;
end

function RespHomesQuestInfoMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.lasttime, idx = readInt(pak, idx);
	self.cnt, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local infovoVo = {};
		infovoVo.guid, idx = readGuid(pak, idx);
		infovoVo.tid, idx = readInt(pak, idx);
		infovoVo.time, idx = readInt(pak, idx);
		infovoVo.rewardType, idx = readInt(pak, idx);
		infovoVo.questlvl, idx = readInt(pak, idx);
		infovoVo.rewardNum, idx = readInt64(pak, idx);
		infovoVo.pupilExp, idx = readInt64(pak, idx);
		infovoVo.itemid, idx = readInt(pak, idx);
		infovoVo.quality, idx = readInt(pak, idx);
		infovoVo.questState, idx = readInt(pak, idx);
		table.push(list1,infovoVo);

		local list = {};
		infovoVo.list = list;
		local listSize = 3;

		for i=1,listSize do
			local monsterVoVo = {};
			monsterVoVo.id, idx = readInt(pak, idx);
			table.push(list,monsterVoVo);
		end
	end

end



--[[
接取任务
]]

_G.RespHomesGetQuestMsg = {};

RespHomesGetQuestMsg.msgId = 7178;
RespHomesGetQuestMsg.result = 0; -- 结果 0=成功，-1:任务不存在，-2:弟子错误



RespHomesGetQuestMsg.meta = {__index = RespHomesGetQuestMsg};
function RespHomesGetQuestMsg:new()
	local obj = setmetatable( {}, RespHomesGetQuestMsg.meta);
	return obj;
end

function RespHomesGetQuestMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
掠夺信息
]]

_G.RespHomesRodQuestMsg = {};

RespHomesRodQuestMsg.msgId = 7179;
RespHomesRodQuestMsg.list_size = 0; -- 掠夺列表 size
RespHomesRodQuestMsg.list = {}; -- 掠夺列表 list



--[[
rodlistVO = {
	roleName = ""; -- 名字
	fight = 0; -- 战斗力
	roleId = ""; -- 对象id
	guid = ""; -- uid
	questlvl = 0; -- 任务等级
	tid = 0; -- 表id
	rodNum = 0; -- 该任务被抢次数
	rewardType = 0; -- 奖励type
	rewardNum = 0; -- 奖励数量
	rolelvl = 0; -- 人物等级
	quality = 0; -- 品质
}
]]

RespHomesRodQuestMsg.meta = {__index = RespHomesRodQuestMsg};
function RespHomesRodQuestMsg:new()
	local obj = setmetatable( {}, RespHomesRodQuestMsg.meta);
	return obj;
end

function RespHomesRodQuestMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local rodlistVo = {};
		rodlistVo.roleName, idx = readString(pak, idx, 32);
		rodlistVo.fight, idx = readInt64(pak, idx);
		rodlistVo.roleId, idx = readGuid(pak, idx);
		rodlistVo.guid, idx = readGuid(pak, idx);
		rodlistVo.questlvl, idx = readInt(pak, idx);
		rodlistVo.tid, idx = readInt(pak, idx);
		rodlistVo.rodNum, idx = readInt(pak, idx);
		rodlistVo.rewardType, idx = readInt(pak, idx);
		rodlistVo.rewardNum, idx = readInt64(pak, idx);
		rodlistVo.rolelvl, idx = readInt(pak, idx);
		rodlistVo.quality, idx = readInt(pak, idx);
		table.push(list1,rodlistVo);
	end

end



--[[
掠夺信息2
]]

_G.RespHomesRodQuestTwoMsg = {};

RespHomesRodQuestTwoMsg.msgId = 7180;
RespHomesRodQuestTwoMsg.rodNum = 0; -- 今日已掠夺次数
RespHomesRodQuestTwoMsg.rodCD = 0; -- 冷却时间
RespHomesRodQuestTwoMsg.listdesc_size = 0; -- 掠夺记录 size
RespHomesRodQuestTwoMsg.listdesc = {}; -- 掠夺记录 list



--[[
rodlistInfoVO = {
	time = 0; -- 时间
	type = 0; -- 0=我的操作，1=我被操作
	roleName = ""; -- 对象名字
	rewardType = 0; -- 收益type
	rewardNum = 0; -- 奖励数量
	descID = 0; -- 收益描述id
}
]]

RespHomesRodQuestTwoMsg.meta = {__index = RespHomesRodQuestTwoMsg};
function RespHomesRodQuestTwoMsg:new()
	local obj = setmetatable( {}, RespHomesRodQuestTwoMsg.meta);
	return obj;
end

function RespHomesRodQuestTwoMsg:ParseData(pak)
	local idx = 1;

	self.rodNum, idx = readInt(pak, idx);
	self.rodCD, idx = readInt(pak, idx);

	local list1 = {};
	self.listdesc = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local rodlistInfoVo = {};
		rodlistInfoVo.time, idx = readInt(pak, idx);
		rodlistInfoVo.type, idx = readInt(pak, idx);
		rodlistInfoVo.roleName, idx = readString(pak, idx, 32);
		rodlistInfoVo.rewardType, idx = readInt(pak, idx);
		rodlistInfoVo.rewardNum, idx = readInt64(pak, idx);
		rodlistInfoVo.descID, idx = readInt(pak, idx);
		table.push(list1,rodlistInfoVo);
	end

end



--[[
请求抢返回
]]

_G.RespHomesGoRodQuestMsg = {};

RespHomesGoRodQuestMsg.msgId = 7181;
RespHomesGoRodQuestMsg.guid = ""; -- uid
RespHomesGoRodQuestMsg.result = 0; -- 结果 0=成功，1=抢夺失败  -1=任务不存在，-2:任务状态不对, -3:任务次数达上线 -4CD中 -5:不可掠夺自己 -6:次数上限



RespHomesGoRodQuestMsg.meta = {__index = RespHomesGoRodQuestMsg};
function RespHomesGoRodQuestMsg:new()
	local obj = setmetatable( {}, RespHomesGoRodQuestMsg.meta);
	return obj;
end

function RespHomesGoRodQuestMsg:ParseData(pak)
	local idx = 1;

	self.guid, idx = readGuid(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
增加抢次数返回
]]

_G.RespHomesRodQuestNumMsg = {};

RespHomesRodQuestNumMsg.msgId = 7182;
RespHomesRodQuestNumMsg.result = 0; -- 结果0=成功，-1=元宝不足 -2等待服务器返回



RespHomesRodQuestNumMsg.meta = {__index = RespHomesRodQuestNumMsg};
function RespHomesRodQuestNumMsg:new()
	local obj = setmetatable( {}, RespHomesRodQuestNumMsg.meta);
	return obj;
end

function RespHomesRodQuestNumMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回跨服战信息
]]

_G.RespCrossFightMsg = {};

RespCrossFightMsg.msgId = 7183;
RespCrossFightMsg.sign = ""; -- MD5
RespCrossFightMsg.congroupid = 0; -- 连接服务器ID



RespCrossFightMsg.meta = {__index = RespCrossFightMsg};
function RespCrossFightMsg:new()
	local obj = setmetatable( {}, RespCrossFightMsg.meta);
	return obj;
end

function RespCrossFightMsg:ParseData(pak)
	local idx = 1;

	self.sign, idx = readString(pak, idx, 33);
	self.congroupid, idx = readInt(pak, idx);

end



--[[
服务器返回:所有房间信息
]]

_G.RespCrossDungeonRoomListMsg = {};

RespCrossDungeonRoomListMsg.msgId = 7185;
RespCrossDungeonRoomListMsg.list_size = 0; -- 房间列表 size
RespCrossDungeonRoomListMsg.list = {}; -- 房间列表 list



--[[
roomVOVO = {
	roomID = ""; -- roomID
	capName = ""; -- 队长名称
	att = 0; -- 战斗力需求 0:无限制
	lock = 0; -- 锁 0 true 1 false
	roomNum = 0; -- 房间人数
}
]]

RespCrossDungeonRoomListMsg.meta = {__index = RespCrossDungeonRoomListMsg};
function RespCrossDungeonRoomListMsg:new()
	local obj = setmetatable( {}, RespCrossDungeonRoomListMsg.meta);
	return obj;
end

function RespCrossDungeonRoomListMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local roomVOVo = {};
		roomVOVo.roomID, idx = readGuid(pak, idx);
		roomVOVo.capName, idx = readString(pak, idx, 32);
		roomVOVo.att, idx = readInt(pak, idx);
		roomVOVo.lock, idx = readByte(pak, idx);
		roomVOVo.roomNum, idx = readByte(pak, idx);
		table.push(list1,roomVOVo);
	end

end



--[[
服务器返回:自己房间信息
]]

_G.RespCrossDungeonRoomInfoMsg = {};

RespCrossDungeonRoomInfoMsg.msgId = 7186;
RespCrossDungeonRoomInfoMsg.lock = 0; -- 锁 0 true 1 false
RespCrossDungeonRoomInfoMsg.lockAttNum = 0; -- 战斗力限制值 0:无限制
RespCrossDungeonRoomInfoMsg.autoStart = 0; -- 自动开始 0 true



RespCrossDungeonRoomInfoMsg.meta = {__index = RespCrossDungeonRoomInfoMsg};
function RespCrossDungeonRoomInfoMsg:new()
	local obj = setmetatable( {}, RespCrossDungeonRoomInfoMsg.meta);
	return obj;
end

function RespCrossDungeonRoomInfoMsg:ParseData(pak)
	local idx = 1;

	self.lock, idx = readByte(pak, idx);
	self.lockAttNum, idx = readInt(pak, idx);
	self.autoStart, idx = readInt(pak, idx);

end



--[[
服务器返回:准备状态
]]

_G.RespCrossDungeonPrepareMsg = {};

RespCrossDungeonPrepareMsg.msgId = 7188;
RespCrossDungeonPrepareMsg.memId = ""; -- 成员ID
RespCrossDungeonPrepareMsg.prepare = 0; -- 准备状态 0 true 1 false



RespCrossDungeonPrepareMsg.meta = {__index = RespCrossDungeonPrepareMsg};
function RespCrossDungeonPrepareMsg:new()
	local obj = setmetatable( {}, RespCrossDungeonPrepareMsg.meta);
	return obj;
end

function RespCrossDungeonPrepareMsg:ParseData(pak)
	local idx = 1;

	self.memId, idx = readGuid(pak, idx);
	self.prepare, idx = readByte(pak, idx);

end



--[[
服务器返回:退出房间
]]

_G.RespQuitCrossDungeonRoomMsg = {};

RespQuitCrossDungeonRoomMsg.msgId = 7189;
RespQuitCrossDungeonRoomMsg.memId = ""; -- 成员ID
RespQuitCrossDungeonRoomMsg.result = 0; -- 结果 0 true



RespQuitCrossDungeonRoomMsg.meta = {__index = RespQuitCrossDungeonRoomMsg};
function RespQuitCrossDungeonRoomMsg:new()
	local obj = setmetatable( {}, RespQuitCrossDungeonRoomMsg.meta);
	return obj;
end

function RespQuitCrossDungeonRoomMsg:ParseData(pak)
	local idx = 1;

	self.memId, idx = readGuid(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
跨服重连返回
]]

_G.RespReEnterGameMsg = {};

RespReEnterGameMsg.msgId = 7193;
RespReEnterGameMsg.result = 0; -- 结果 0 true
RespReEnterGameMsg.lineid = 0; -- 线ID



RespReEnterGameMsg.meta = {__index = RespReEnterGameMsg};
function RespReEnterGameMsg:new()
	local obj = setmetatable( {}, RespReEnterGameMsg.meta);
	return obj;
end

function RespReEnterGameMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.lineid, idx = readInt(pak, idx);

end



--[[
跨服重连返回进入场景
]]

_G.RespReEnterSceneMsg = {};

RespReEnterSceneMsg.msgId = 7194;
RespReEnterSceneMsg.result = 0; -- 0 成功



RespReEnterSceneMsg.meta = {__index = RespReEnterSceneMsg};
function RespReEnterSceneMsg:new()
	local obj = setmetatable( {}, RespReEnterSceneMsg.meta);
	return obj;
end

function RespReEnterSceneMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
弟子使用经验
]]

_G.RespHomesUsePupilExpMsg = {};

RespHomesUsePupilExpMsg.msgId = 7195;
RespHomesUsePupilExpMsg.result = 0; -- 结果0成功，-1道具不足 -2:弟子不存在 -3:弟子到达最大等级 -4:等待服务器返回



RespHomesUsePupilExpMsg.meta = {__index = RespHomesUsePupilExpMsg};
function RespHomesUsePupilExpMsg:new()
	local obj = setmetatable( {}, RespHomesUsePupilExpMsg.meta);
	return obj;
end

function RespHomesUsePupilExpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
开始匹配返回
]]

_G.RespStartMatchPvpMsg = {};

RespStartMatchPvpMsg.msgId = 7196;
RespStartMatchPvpMsg.result = 0; -- 结果0成功,1已在跨服匹配中，2,组队状态,3,匹配未开启，4，未到匹配时间，5,每日匹配上限，6，在竞技场, 7,在副本或者活动中，8,未开启跨服功能，9



RespStartMatchPvpMsg.meta = {__index = RespStartMatchPvpMsg};
function RespStartMatchPvpMsg:new()
	local obj = setmetatable( {}, RespStartMatchPvpMsg.meta);
	return obj;
end

function RespStartMatchPvpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
退出匹配返回
]]

_G.RespExitMatchPvpMsg = {};

RespExitMatchPvpMsg.msgId = 7197;
RespExitMatchPvpMsg.result = 0; -- 结果0成功



RespExitMatchPvpMsg.meta = {__index = RespExitMatchPvpMsg};
function RespExitMatchPvpMsg:new()
	local obj = setmetatable( {}, RespExitMatchPvpMsg.meta);
	return obj;
end

function RespExitMatchPvpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回跨服信息
]]

_G.RespCrossPvpInfoMsg = {};

RespCrossPvpInfoMsg.msgId = 7198;
RespCrossPvpInfoMsg.contwin = 0; -- 连胜场数
RespCrossPvpInfoMsg.totalcnt = 0; -- 总挑战次数
RespCrossPvpInfoMsg.totalwin = 0; -- 总胜利场数
RespCrossPvpInfoMsg.remaintimes = 0; -- 剩余次数
RespCrossPvpInfoMsg.rank = 0; -- 名次
RespCrossPvpInfoMsg.rewardflag = 0; -- 领奖标记(0 - 已领奖， 1 - 未领奖)
RespCrossPvpInfoMsg.lastSeasonid = 0; -- 上赛季ID
RespCrossPvpInfoMsg.seasonid = 0; -- 赛季ID
RespCrossPvpInfoMsg.CrossRankList_size = 3; -- 跨服积分前三列表 size
RespCrossPvpInfoMsg.CrossRankList = {}; -- 跨服积分前三列表 list



--[[
CrossRankRoleVoVO = {
	roleId = ""; -- 人物id
	roleName = ""; -- 人物名称
	fight = 0; -- 人物战力
	rank = 0; -- 人物排行
	prof = 0; -- 职业
	arms = 0; -- 武器
	dress = 0; -- 衣服
	fashionshead = 0; -- 时装头
	fashionsarms = 0; -- 时装武器
	fashionsdress = 0; -- 时装衣服
	wuhunId = 0; -- 武魂id
	wing = 0; -- 翅膀
	suitflag = 0; -- 套装标识
}
]]

RespCrossPvpInfoMsg.meta = {__index = RespCrossPvpInfoMsg};
function RespCrossPvpInfoMsg:new()
	local obj = setmetatable( {}, RespCrossPvpInfoMsg.meta);
	return obj;
end

function RespCrossPvpInfoMsg:ParseData(pak)
	local idx = 1;

	self.contwin, idx = readInt(pak, idx);
	self.totalcnt, idx = readInt(pak, idx);
	self.totalwin, idx = readInt(pak, idx);
	self.remaintimes, idx = readInt(pak, idx);
	self.rank, idx = readInt(pak, idx);
	self.rewardflag, idx = readInt(pak, idx);
	self.lastSeasonid, idx = readInt(pak, idx);
	self.seasonid, idx = readInt(pak, idx);

	local list = {};
	self.CrossRankList = list;
	local listSize = 3;

	for i=1,listSize do
		local CrossRankRoleVoVo = {};
		CrossRankRoleVoVo.roleId, idx = readGuid(pak, idx);
		CrossRankRoleVoVo.roleName, idx = readString(pak, idx, 32);
		CrossRankRoleVoVo.fight, idx = readInt64(pak, idx);
		CrossRankRoleVoVo.rank, idx = readInt(pak, idx);
		CrossRankRoleVoVo.prof, idx = readInt(pak, idx);
		CrossRankRoleVoVo.arms, idx = readInt(pak, idx);
		CrossRankRoleVoVo.dress, idx = readInt(pak, idx);
		CrossRankRoleVoVo.fashionshead, idx = readInt(pak, idx);
		CrossRankRoleVoVo.fashionsarms, idx = readInt(pak, idx);
		CrossRankRoleVoVo.fashionsdress, idx = readInt(pak, idx);
		CrossRankRoleVoVo.wuhunId, idx = readInt(pak, idx);
		CrossRankRoleVoVo.wing, idx = readInt(pak, idx);
		CrossRankRoleVoVo.suitflag, idx = readInt(pak, idx);
		table.push(list,CrossRankRoleVoVo);
	end

end



--[[
服务器返回历届跨服信息
]]

_G.RespCrossSeasonPvpInfoMsg = {};

RespCrossSeasonPvpInfoMsg.msgId = 7199;
RespCrossSeasonPvpInfoMsg.lastSeasonid = 0; -- 上赛季ID
RespCrossSeasonPvpInfoMsg.nextSeasonid = 0; -- 下赛季ID
RespCrossSeasonPvpInfoMsg.seasonid = 0; -- 赛季ID
RespCrossSeasonPvpInfoMsg.CrossRankList_size = 3; -- 跨服积分前三列表 size
RespCrossSeasonPvpInfoMsg.CrossRankList = {}; -- 跨服积分前三列表 list



--[[
CrossRankRoleVoVO = {
	roleId = ""; -- 人物id
	roleName = ""; -- 人物名称
	fight = 0; -- 人物战力
	rank = 0; -- 人物排行
	prof = 0; -- 职业
	arms = 0; -- 武器
	dress = 0; -- 衣服
	fashionshead = 0; -- 时装头
	fashionsarms = 0; -- 时装武器
	fashionsdress = 0; -- 时装衣服
	wuhunId = 0; -- 武魂id
	wing = 0; -- 翅膀
	suitflag = 0; -- 套装标识
}
]]

RespCrossSeasonPvpInfoMsg.meta = {__index = RespCrossSeasonPvpInfoMsg};
function RespCrossSeasonPvpInfoMsg:new()
	local obj = setmetatable( {}, RespCrossSeasonPvpInfoMsg.meta);
	return obj;
end

function RespCrossSeasonPvpInfoMsg:ParseData(pak)
	local idx = 1;

	self.lastSeasonid, idx = readInt(pak, idx);
	self.nextSeasonid, idx = readInt(pak, idx);
	self.seasonid, idx = readInt(pak, idx);

	local list = {};
	self.CrossRankList = list;
	local listSize = 3;

	for i=1,listSize do
		local CrossRankRoleVoVo = {};
		CrossRankRoleVoVo.roleId, idx = readGuid(pak, idx);
		CrossRankRoleVoVo.roleName, idx = readString(pak, idx, 32);
		CrossRankRoleVoVo.fight, idx = readInt64(pak, idx);
		CrossRankRoleVoVo.rank, idx = readInt(pak, idx);
		CrossRankRoleVoVo.prof, idx = readInt(pak, idx);
		CrossRankRoleVoVo.arms, idx = readInt(pak, idx);
		CrossRankRoleVoVo.dress, idx = readInt(pak, idx);
		CrossRankRoleVoVo.fashionshead, idx = readInt(pak, idx);
		CrossRankRoleVoVo.fashionsarms, idx = readInt(pak, idx);
		CrossRankRoleVoVo.fashionsdress, idx = readInt(pak, idx);
		CrossRankRoleVoVo.wuhunId, idx = readInt(pak, idx);
		CrossRankRoleVoVo.wing, idx = readInt(pak, idx);
		CrossRankRoleVoVo.suitflag, idx = readInt(pak, idx);
		table.push(list,CrossRankRoleVoVo);
	end

end



--[[
服务器返回活动信息
]]

_G.RespGuildActivityNoticeMsg = {};

RespGuildActivityNoticeMsg.msgId = 7200;
RespGuildActivityNoticeMsg.NoticeList_size = 0; -- 活动通知 size
RespGuildActivityNoticeMsg.NoticeList = {}; -- 活动通知 list



--[[
NoticeVoVO = {
	id = 0; -- 活动ID
	param = 0; -- 参数
	text = ""; -- 内容
	roleName = ""; -- 发起人名字
	time = 0; -- 发起时间
}
]]

RespGuildActivityNoticeMsg.meta = {__index = RespGuildActivityNoticeMsg};
function RespGuildActivityNoticeMsg:new()
	local obj = setmetatable( {}, RespGuildActivityNoticeMsg.meta);
	return obj;
end

function RespGuildActivityNoticeMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.NoticeList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local NoticeVoVo = {};
		NoticeVoVo.id, idx = readInt(pak, idx);
		NoticeVoVo.param, idx = readInt(pak, idx);
		NoticeVoVo.text, idx = readString(pak, idx, 128);
		NoticeVoVo.roleName, idx = readString(pak, idx, 32);
		NoticeVoVo.time, idx = readInt(pak, idx);
		table.push(list1,NoticeVoVo);
	end

end



--[[
帮派活动提醒
]]

_G.RespUnionActivityRemindMsg = {};

RespUnionActivityRemindMsg.msgId = 7201;
RespUnionActivityRemindMsg.NoticeList_size = 0; -- 活动通知 size
RespUnionActivityRemindMsg.NoticeList = {}; -- 活动通知 list



--[[
NoticeVoVO = {
	type = 0; -- 活动id 2=帮派战，3=帮派王城战，5=帮派地宫争夺
	result = 0; -- 0=未开启,1=已开启过，2=活动正在进行中
	lastTime = 0; -- 活动剩余时间(/秒)
}
]]

RespUnionActivityRemindMsg.meta = {__index = RespUnionActivityRemindMsg};
function RespUnionActivityRemindMsg:new()
	local obj = setmetatable( {}, RespUnionActivityRemindMsg.meta);
	return obj;
end

function RespUnionActivityRemindMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.NoticeList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local NoticeVoVo = {};
		NoticeVoVo.type, idx = readInt(pak, idx);
		NoticeVoVo.result, idx = readInt(pak, idx);
		NoticeVoVo.lastTime, idx = readInt(pak, idx);
		table.push(list1,NoticeVoVo);
	end

end



--[[
返回GM信息
]]

_G.RespGMInfoMsg = {};

RespGMInfoMsg.msgId = 7203;
RespGMInfoMsg.isGM = 0; -- 是否是GM
RespGMInfoMsg.isUseGMTitle = 0; -- 是否使用GM称号
RespGMInfoMsg.isChat = 0; -- 是否接收聊天



RespGMInfoMsg.meta = {__index = RespGMInfoMsg};
function RespGMInfoMsg:new()
	local obj = setmetatable( {}, RespGMInfoMsg.meta);
	return obj;
end

function RespGMInfoMsg:ParseData(pak)
	local idx = 1;

	self.isGM, idx = readInt(pak, idx);
	self.isUseGMTitle, idx = readInt(pak, idx);
	self.isChat, idx = readInt(pak, idx);

end



--[[
返回被GM的列表
]]

_G.RespGMListMsg = {};

RespGMListMsg.msgId = 7204;
RespGMListMsg.type = 0; -- 1禁言列表,2封停列表,3封mac列表
RespGMListMsg.list_size = 0; -- list size
RespGMListMsg.list = {}; -- list list



--[[
GMListVOVO = {
	roleId = ""; -- uid
	name = ""; -- 名字
	prof = 0; -- 职业
	level = 0; -- 等级
	vipLevel = 0; -- VIP等级
	charge = 0; -- 充值
	guildName = ""; -- 帮派名
	guildUid = ""; -- 帮派id
	mac = ""; -- mac
	time = 0; -- 终止时间
}
]]

RespGMListMsg.meta = {__index = RespGMListMsg};
function RespGMListMsg:new()
	local obj = setmetatable( {}, RespGMListMsg.meta);
	return obj;
end

function RespGMListMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local GMListVOVo = {};
		GMListVOVo.roleId, idx = readGuid(pak, idx);
		GMListVOVo.name, idx = readString(pak, idx, 32);
		GMListVOVo.prof, idx = readInt(pak, idx);
		GMListVOVo.level, idx = readInt(pak, idx);
		GMListVOVo.vipLevel, idx = readInt(pak, idx);
		GMListVOVo.charge, idx = readInt64(pak, idx);
		GMListVOVo.guildName, idx = readString(pak, idx, 32);
		GMListVOVo.guildUid, idx = readGuid(pak, idx);
		GMListVOVo.mac, idx = readString(pak, idx, 32);
		GMListVOVo.time, idx = readInt64(pak, idx);
		table.push(list1,GMListVOVo);
	end

end



--[[
GM接收聊天
]]

_G.RespGMChatMsg = {};

RespGMChatMsg.msgId = 7205;
RespGMChatMsg.senderID = ""; -- 发送者ID
RespGMChatMsg.senderName = ""; -- 发送者名字
RespGMChatMsg.senderTeamId = ""; -- 发送者队伍id
RespGMChatMsg.senderGuildId = ""; -- 发送者帮派id
RespGMChatMsg.senderGuildPos = 0; -- 发送者帮派职务
RespGMChatMsg.senderVIP = 0; -- 发送者VIP等级
RespGMChatMsg.senderLvl = 0; -- 发送者等级
RespGMChatMsg.senderIcon = 0; -- 发送者头像
RespGMChatMsg.senderFlag = 0; -- 发送者标示
RespGMChatMsg.senderCityPos = 0; -- 发送者王城职位
RespGMChatMsg.senderVflag = 0; -- 发送者V计划标示
RespGMChatMsg.senderIsGM = 0; -- 是否GM标示
RespGMChatMsg.toID = ""; -- 发送者ID
RespGMChatMsg.toName = ""; -- 发送者名字
RespGMChatMsg.toTeamId = ""; -- 发送者队伍id
RespGMChatMsg.toGuildId = ""; -- 发送者帮派id
RespGMChatMsg.toGuildPos = 0; -- 发送者帮派职务
RespGMChatMsg.toVIP = 0; -- 发送者VIP等级
RespGMChatMsg.toLvl = 0; -- 发送者等级
RespGMChatMsg.toIcon = 0; -- 发送者头像
RespGMChatMsg.toFlag = 0; -- 发送者标示
RespGMChatMsg.toCityPos = 0; -- 发送者王城职位
RespGMChatMsg.toVflag = 0; -- 发送者V计划标示
RespGMChatMsg.toIsGM = 0; -- 是否GM标示
RespGMChatMsg.sendTime = 0; -- 发送时间
RespGMChatMsg.hornId = 0; -- 喇叭时,喇叭id
RespGMChatMsg.channel = 0; -- 频道
RespGMChatMsg.text = ""; -- 内容



RespGMChatMsg.meta = {__index = RespGMChatMsg};
function RespGMChatMsg:new()
	local obj = setmetatable( {}, RespGMChatMsg.meta);
	return obj;
end

function RespGMChatMsg:ParseData(pak)
	local idx = 1;

	self.senderID, idx = readGuid(pak, idx);
	self.senderName, idx = readString(pak, idx, 32);
	self.senderTeamId, idx = readGuid(pak, idx);
	self.senderGuildId, idx = readGuid(pak, idx);
	self.senderGuildPos, idx = readByte(pak, idx);
	self.senderVIP, idx = readInt(pak, idx);
	self.senderLvl, idx = readInt(pak, idx);
	self.senderIcon, idx = readByte(pak, idx);
	self.senderFlag, idx = readInt(pak, idx);
	self.senderCityPos, idx = readByte(pak, idx);
	self.senderVflag, idx = readInt(pak, idx);
	self.senderIsGM, idx = readByte(pak, idx);
	self.toID, idx = readGuid(pak, idx);
	self.toName, idx = readString(pak, idx, 32);
	self.toTeamId, idx = readGuid(pak, idx);
	self.toGuildId, idx = readGuid(pak, idx);
	self.toGuildPos, idx = readByte(pak, idx);
	self.toVIP, idx = readByte(pak, idx);
	self.toLvl, idx = readInt(pak, idx);
	self.toIcon, idx = readByte(pak, idx);
	self.toFlag, idx = readInt(pak, idx);
	self.toCityPos, idx = readByte(pak, idx);
	self.toVflag, idx = readInt(pak, idx);
	self.toIsGM, idx = readByte(pak, idx);
	self.sendTime, idx = readInt64(pak, idx);
	self.hornId, idx = readInt(pak, idx);
	self.channel, idx = readInt(pak, idx);
	self.text, idx = readString(pak, idx);

end



--[[
返回GM查找
]]

_G.RespGMSearchMsg = {};

RespGMSearchMsg.msgId = 7206;
RespGMSearchMsg.list_size = 0; -- list size
RespGMSearchMsg.list = {}; -- list list



--[[
GMSearchListVOVO = {
	roleId = ""; -- uid
	name = ""; -- 名字
	prof = 0; -- 职业
	level = 0; -- 等级
	vipLevel = 0; -- VIP等级
	guildName = ""; -- 帮派名
	guildUid = ""; -- 帮派id
}
]]

RespGMSearchMsg.meta = {__index = RespGMSearchMsg};
function RespGMSearchMsg:new()
	local obj = setmetatable( {}, RespGMSearchMsg.meta);
	return obj;
end

function RespGMSearchMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local GMSearchListVOVo = {};
		GMSearchListVOVo.roleId, idx = readGuid(pak, idx);
		GMSearchListVOVo.name, idx = readString(pak, idx, 32);
		GMSearchListVOVo.prof, idx = readInt(pak, idx);
		GMSearchListVOVo.level, idx = readInt(pak, idx);
		GMSearchListVOVo.vipLevel, idx = readInt(pak, idx);
		GMSearchListVOVo.guildName, idx = readString(pak, idx, 32);
		GMSearchListVOVo.guildUid, idx = readGuid(pak, idx);
		table.push(list1,GMSearchListVOVo);
	end

end



--[[
返回GM操作息
]]

_G.RespGMOperRetMsg = {};

RespGMOperRetMsg.msgId = 7207;
RespGMOperRetMsg.result = 0; -- 结果
RespGMOperRetMsg.id = ""; -- uid
RespGMOperRetMsg.type = 0; -- 1禁言,2封停,3mac,4踢下线



RespGMOperRetMsg.meta = {__index = RespGMOperRetMsg};
function RespGMOperRetMsg:new()
	local obj = setmetatable( {}, RespGMOperRetMsg.meta);
	return obj;
end

function RespGMOperRetMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readGuid(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
返回GM反向操作
]]

_G.RespGMUnOperRetMsg = {};

RespGMUnOperRetMsg.msgId = 7208;
RespGMUnOperRetMsg.result = 0; -- 结果
RespGMUnOperRetMsg.id = ""; -- uid
RespGMUnOperRetMsg.type = 0; -- 1禁言,2封停,3mac



RespGMUnOperRetMsg.meta = {__index = RespGMUnOperRetMsg};
function RespGMUnOperRetMsg:new()
	local obj = setmetatable( {}, RespGMUnOperRetMsg.meta);
	return obj;
end

function RespGMUnOperRetMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readGuid(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
返回GM帮派成员列表
]]

_G.RespGMGuildRoleListMsg = {};

RespGMGuildRoleListMsg.msgId = 7209;
RespGMGuildRoleListMsg.guildName = ""; -- 帮派名
RespGMGuildRoleListMsg.guildUid = ""; -- 帮派id
RespGMGuildRoleListMsg.timeNow = 0; -- 当前时间
RespGMGuildRoleListMsg.GuildMemList_size = 0; -- 帮派成员列表 size
RespGMGuildRoleListMsg.GuildMemList = {}; -- 帮派成员列表 list



--[[
RespGuildMemsVoVO = {
	id = ""; -- Gid
	name = ""; -- 名称
	time = 0; -- 最后登录时间
	jointime = 0; -- 加入帮派时间
	level = 0; -- 等级
	vipLevel = 0; -- VIP等级
	contribute = 0; -- 当前贡献
	allcontribute = 0; -- 累积贡献
	loyalty = 0; -- 忠诚度
	power = 0; -- 战斗力
	pos = 0; -- 职位
	online = 0; -- 1-在线，0-不在线
	iconID = 0; -- 玩家头像
	vflag = 0; -- V计划
}
]]

RespGMGuildRoleListMsg.meta = {__index = RespGMGuildRoleListMsg};
function RespGMGuildRoleListMsg:new()
	local obj = setmetatable( {}, RespGMGuildRoleListMsg.meta);
	return obj;
end

function RespGMGuildRoleListMsg:ParseData(pak)
	local idx = 1;

	self.guildName, idx = readString(pak, idx, 32);
	self.guildUid, idx = readGuid(pak, idx);
	self.timeNow, idx = readInt64(pak, idx);

	local list1 = {};
	self.GuildMemList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RespGuildMemsVoVo = {};
		RespGuildMemsVoVo.id, idx = readGuid(pak, idx);
		RespGuildMemsVoVo.name, idx = readString(pak, idx, 32);
		RespGuildMemsVoVo.time, idx = readInt64(pak, idx);
		RespGuildMemsVoVo.jointime, idx = readInt64(pak, idx);
		RespGuildMemsVoVo.level, idx = readInt(pak, idx);
		RespGuildMemsVoVo.vipLevel, idx = readInt(pak, idx);
		RespGuildMemsVoVo.contribute, idx = readInt(pak, idx);
		RespGuildMemsVoVo.allcontribute, idx = readInt(pak, idx);
		RespGuildMemsVoVo.loyalty, idx = readInt(pak, idx);
		RespGuildMemsVoVo.power, idx = readInt64(pak, idx);
		RespGuildMemsVoVo.pos, idx = readByte(pak, idx);
		RespGuildMemsVoVo.online, idx = readByte(pak, idx);
		RespGuildMemsVoVo.iconID, idx = readInt(pak, idx);
		RespGuildMemsVoVo.vflag, idx = readInt(pak, idx);
		table.push(list1,RespGuildMemsVoVo);
	end

end



--[[
返回GM帮派操作
]]

_G.RespGuildOperMsg = {};

RespGuildOperMsg.msgId = 7210;
RespGuildOperMsg.result = 0; -- 



RespGuildOperMsg.meta = {__index = RespGuildOperMsg};
function RespGuildOperMsg:new()
	local obj = setmetatable( {}, RespGuildOperMsg.meta);
	return obj;
end

function RespGuildOperMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回GM解散帮派
]]

_G.RespGMGuildDismissMsg = {};

RespGMGuildDismissMsg.msgId = 7211;
RespGMGuildDismissMsg.result = 0; -- 



RespGMGuildDismissMsg.meta = {__index = RespGMGuildDismissMsg};
function RespGMGuildDismissMsg:new()
	local obj = setmetatable( {}, RespGMGuildDismissMsg.meta);
	return obj;
end

function RespGMGuildDismissMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
收到全服红包信息
]]

_G.RespRedPacketInfoNotifyMsg = {};

RespRedPacketInfoNotifyMsg.msgId = 7213;
RespRedPacketInfoNotifyMsg.type = 0; -- 0默认vip红包，1婚礼红包
RespRedPacketInfoNotifyMsg.id = 0; -- 红包id
RespRedPacketInfoNotifyMsg.roleName = ""; -- 发送者角色名称
RespRedPacketInfoNotifyMsg.num = 0; -- 数量，-1：全服红包



RespRedPacketInfoNotifyMsg.meta = {__index = RespRedPacketInfoNotifyMsg};
function RespRedPacketInfoNotifyMsg:new()
	local obj = setmetatable( {}, RespRedPacketInfoNotifyMsg.meta);
	return obj;
end

function RespRedPacketInfoNotifyMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);
	self.roleName, idx = readString(pak, idx, 32);
	self.num, idx = readInt(pak, idx);

end



--[[
收到全服红包排行信息
]]

_G.RespGetRedPacketRankMsg = {};

RespGetRedPacketRankMsg.msgId = 7214;
RespGetRedPacketRankMsg.id = 0; -- 红包id
RespGetRedPacketRankMsg.senderName = ""; -- 发送者角色名称
RespGetRedPacketRankMsg.tid = 0; -- 红包物品id
RespGetRedPacketRankMsg.num = 0; -- 剩余数量
RespGetRedPacketRankMsg.type = 0; -- 0默认vip红包，1婚礼红包
RespGetRedPacketRankMsg.list_size = 0; -- 红包list size
RespGetRedPacketRankMsg.list = {}; -- 红包list list



--[[
RedPacketListVO = {
	roleName = ""; -- 角色名称
	num = 0; -- 数量
}
]]

RespGetRedPacketRankMsg.meta = {__index = RespGetRedPacketRankMsg};
function RespGetRedPacketRankMsg:new()
	local obj = setmetatable( {}, RespGetRedPacketRankMsg.meta);
	return obj;
end

function RespGetRedPacketRankMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.senderName, idx = readString(pak, idx, 32);
	self.tid, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RedPacketListVo = {};
		RedPacketListVo.roleName, idx = readString(pak, idx, 32);
		RedPacketListVo.num, idx = readInt(pak, idx);
		table.push(list1,RedPacketListVo);
	end

end



--[[
返回领取红包结果
]]

_G.RespGetRedPacketMsg = {};

RespGetRedPacketMsg.msgId = 7215;
RespGetRedPacketMsg.id = 0; -- 红包id
RespGetRedPacketMsg.result = 0; -- 领取结果：0=成功,1=失败
RespGetRedPacketMsg.num = 0; -- 数量



RespGetRedPacketMsg.meta = {__index = RespGetRedPacketMsg};
function RespGetRedPacketMsg:new()
	local obj = setmetatable( {}, RespGetRedPacketMsg.meta);
	return obj;
end

function RespGetRedPacketMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
物品上架结果
]]

_G.RespConsignmentItemInShelvesMsg = {};

RespConsignmentItemInShelvesMsg.msgId = 7216;
RespConsignmentItemInShelvesMsg.result = 0; -- 结果：0成功，1上架达上限，



RespConsignmentItemInShelvesMsg.meta = {__index = RespConsignmentItemInShelvesMsg};
function RespConsignmentItemInShelvesMsg:new()
	local obj = setmetatable( {}, RespConsignmentItemInShelvesMsg.meta);
	return obj;
end

function RespConsignmentItemInShelvesMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
放弃任务
]]

_G.RespHomesGiveupQuestMsg = {};

RespHomesGiveupQuestMsg.msgId = 7217;
RespHomesGiveupQuestMsg.guid = ""; -- 任务id
RespHomesGiveupQuestMsg.result = 0; -- 销毁结果 0=成功，-1=任务不存在



RespHomesGiveupQuestMsg.meta = {__index = RespHomesGiveupQuestMsg};
function RespHomesGiveupQuestMsg:new()
	local obj = setmetatable( {}, RespHomesGiveupQuestMsg.meta);
	return obj;
end

function RespHomesGiveupQuestMsg:ParseData(pak)
	local idx = 1;

	self.guid, idx = readGuid(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
团购购买返回
]]

_G.ResqPartyBuyMsg = {};

ResqPartyBuyMsg.msgId = 7220;
ResqPartyBuyMsg.id = 0; -- 活动id
ResqPartyBuyMsg.result = 0; -- 结果(0成功,其他失败)
ResqPartyBuyMsg.mypurchase = 0; -- 我的购买次数
ResqPartyBuyMsg.totalpurchase = 0; -- 总的购买次数



ResqPartyBuyMsg.meta = {__index = ResqPartyBuyMsg};
function ResqPartyBuyMsg:new()
	local obj = setmetatable( {}, ResqPartyBuyMsg.meta);
	return obj;
end

function ResqPartyBuyMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);
	self.mypurchase, idx = readInt(pak, idx);
	self.totalpurchase, idx = readInt(pak, idx);

end



--[[
通知是否退出匹配
]]

_G.RespNoticeQuitMatchMsg = {};

RespNoticeQuitMatchMsg.msgId = 7221;



RespNoticeQuitMatchMsg.meta = {__index = RespNoticeQuitMatchMsg};
function RespNoticeQuitMatchMsg:new()
	local obj = setmetatable( {}, RespNoticeQuitMatchMsg.meta);
	return obj;
end

function RespNoticeQuitMatchMsg:ParseData(pak)
	local idx = 1;


end



--[[
返回扩展帮派
]]

_G.RespExtendGuildMsg = {};

RespExtendGuildMsg.msgId = 7222;
RespExtendGuildMsg.result = 0; -- 结果(0成功,1帮派已经拓展,2没有权限,3,道具不足)



RespExtendGuildMsg.meta = {__index = RespExtendGuildMsg};
function RespExtendGuildMsg:new()
	local obj = setmetatable( {}, RespExtendGuildMsg.meta);
	return obj;
end

function RespExtendGuildMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回弹劾权限
]]

_G.RespGuildTanHeQuanXianMsg = {};

RespGuildTanHeQuanXianMsg.msgId = 7223;
RespGuildTanHeQuanXianMsg.result = 0; -- 是否可以弹劾(0-不可以，1-可以)



RespGuildTanHeQuanXianMsg.meta = {__index = RespGuildTanHeQuanXianMsg};
function RespGuildTanHeQuanXianMsg:new()
	local obj = setmetatable( {}, RespGuildTanHeQuanXianMsg.meta);
	return obj;
end

function RespGuildTanHeQuanXianMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回弹劾结果
]]

_G.RespGuildTanHeQuanMsg = {};

RespGuildTanHeQuanMsg.msgId = 7224;
RespGuildTanHeQuanMsg.result = 0; -- 是否弹劾成功
RespGuildTanHeQuanMsg.quanxian = 0; -- 是否可以弹劾(0-不可以，1-可以)



RespGuildTanHeQuanMsg.meta = {__index = RespGuildTanHeQuanMsg};
function RespGuildTanHeQuanMsg:new()
	local obj = setmetatable( {}, RespGuildTanHeQuanMsg.meta);
	return obj;
end

function RespGuildTanHeQuanMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.quanxian, idx = readInt(pak, idx);

end



--[[
返回帮派仓库审批列表
]]

_G.RespGuildQueryCheckListMsg = {};

RespGuildQueryCheckListMsg.msgId = 7225;
RespGuildQueryCheckListMsg.pos = 0; -- 自动审核职位
RespGuildQueryCheckListMsg.list_size = 0; -- 审核list size
RespGuildQueryCheckListMsg.list = {}; -- 审核list list



--[[
CheckListVO = {
	operid = 0; -- 操作
	playerid = ""; -- 玩家ID
	pos = 0; -- 职位
	itemid = 0; -- 物品ID
	playerName = ""; -- 玩家名字
	validtime = 0; -- 到期时间
}
]]

RespGuildQueryCheckListMsg.meta = {__index = RespGuildQueryCheckListMsg};
function RespGuildQueryCheckListMsg:new()
	local obj = setmetatable( {}, RespGuildQueryCheckListMsg.meta);
	return obj;
end

function RespGuildQueryCheckListMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local CheckListVo = {};
		CheckListVo.operid, idx = readInt(pak, idx);
		CheckListVo.playerid, idx = readGuid(pak, idx);
		CheckListVo.pos, idx = readInt(pak, idx);
		CheckListVo.itemid, idx = readInt(pak, idx);
		CheckListVo.playerName, idx = readString(pak, idx, 32);
		CheckListVo.validtime, idx = readInt64(pak, idx);
		table.push(list1,CheckListVo);
	end

end



--[[
返回帮派审核操作
]]

_G.ResqGuildQueryCheckOperMsg = {};

ResqGuildQueryCheckOperMsg.msgId = 7226;
ResqGuildQueryCheckOperMsg.result = 0; -- 1-成功，0-失败



ResqGuildQueryCheckOperMsg.meta = {__index = ResqGuildQueryCheckOperMsg};
function ResqGuildQueryCheckOperMsg:new()
	local obj = setmetatable( {}, ResqGuildQueryCheckOperMsg.meta);
	return obj;
end

function ResqGuildQueryCheckOperMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回设置自动审核
]]

_G.ResqGuildSetAutoCheckMsg = {};

ResqGuildSetAutoCheckMsg.msgId = 7227;
ResqGuildSetAutoCheckMsg.result = 0; -- 1-成功，0-失败



ResqGuildSetAutoCheckMsg.meta = {__index = ResqGuildSetAutoCheckMsg};
function ResqGuildSetAutoCheckMsg:new()
	local obj = setmetatable( {}, ResqGuildSetAutoCheckMsg.meta);
	return obj;
end

function ResqGuildSetAutoCheckMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回地宫炼狱提醒
]]

_G.ResqGuildHellNoticeMsg = {};

ResqGuildHellNoticeMsg.msgId = 7228;



ResqGuildHellNoticeMsg.meta = {__index = ResqGuildHellNoticeMsg};
function ResqGuildHellNoticeMsg:new()
	local obj = setmetatable( {}, ResqGuildHellNoticeMsg.meta);
	return obj;
end

function ResqGuildHellNoticeMsg:ParseData(pak)
	local idx = 1;


end



--[[
服务器:举报聊天
]]

_G.RespBanChatMsg = {};

RespBanChatMsg.msgId = 7230;
RespBanChatMsg.result = 0; -- 结果 0 成功 -1失败



RespBanChatMsg.meta = {__index = RespBanChatMsg};
function RespBanChatMsg:new()
	local obj = setmetatable( {}, RespBanChatMsg.meta);
	return obj;
end

function RespBanChatMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
返回加入帮派地宫争夺战
]]

_G.RespUnionEnterDiGongWarMsg = {};

RespUnionEnterDiGongWarMsg.msgId = 7231;
RespUnionEnterDiGongWarMsg.isopen = 0; -- 0=开启
RespUnionEnterDiGongWarMsg.isPass = 0; -- 0=有进入权限，1=没有进入权限
RespUnionEnterDiGongWarMsg.lineID = 0; -- 线ID



RespUnionEnterDiGongWarMsg.meta = {__index = RespUnionEnterDiGongWarMsg};
function RespUnionEnterDiGongWarMsg:new()
	local obj = setmetatable( {}, RespUnionEnterDiGongWarMsg.meta);
	return obj;
end

function RespUnionEnterDiGongWarMsg:ParseData(pak)
	local idx = 1;

	self.isopen, idx = readInt(pak, idx);
	self.isPass, idx = readInt(pak, idx);
	self.lineID, idx = readInt(pak, idx);

end



--[[
返回帮派野外地宫信息
]]

_G.RespUnionDiGongInfoMsg = {};

RespUnionDiGongInfoMsg.msgId = 7232;
RespUnionDiGongInfoMsg.list_size = 0; -- list size
RespUnionDiGongInfoMsg.list = {}; -- list list



--[[
listvoVO = {
	id = 0; -- 活动id
	UnionName = ""; -- 当前占领帮派名称
	Unionid = ""; -- 当前占领帮派id
	Unionid1 = ""; -- 当前占领帮派1id
	UnionName1 = ""; -- 当前争夺帮派名称
	bidmoney1 = 0; -- 竞标资金1
	Unionid2 = ""; -- 当前占领帮派2id
	UnionName2 = ""; -- 当前争夺帮派名称
	bidmoney2 = 0; -- 竞标资金2
}
]]

RespUnionDiGongInfoMsg.meta = {__index = RespUnionDiGongInfoMsg};
function RespUnionDiGongInfoMsg:new()
	local obj = setmetatable( {}, RespUnionDiGongInfoMsg.meta);
	return obj;
end

function RespUnionDiGongInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listvoVo = {};
		listvoVo.id, idx = readInt(pak, idx);
		listvoVo.UnionName, idx = readString(pak, idx, 32);
		listvoVo.Unionid, idx = readGuid(pak, idx);
		listvoVo.Unionid1, idx = readGuid(pak, idx);
		listvoVo.UnionName1, idx = readString(pak, idx, 32);
		listvoVo.bidmoney1, idx = readInt64(pak, idx);
		listvoVo.Unionid2, idx = readGuid(pak, idx);
		listvoVo.UnionName2, idx = readString(pak, idx, 32);
		listvoVo.bidmoney2, idx = readInt64(pak, idx);
		table.push(list1,listvoVo);
	end

end



--[[
返回帮派野外地宫竞标信息
]]

_G.RespUnionDiGongBidInfoMsg = {};

RespUnionDiGongBidInfoMsg.msgId = 7233;
RespUnionDiGongBidInfoMsg.id = 0; -- 活动id
RespUnionDiGongBidInfoMsg.list_size = 0; -- list size
RespUnionDiGongBidInfoMsg.list = {}; -- list list



--[[
listvoVO = {
	UnionName = ""; -- 当前争夺帮派名称
	bidmoney = 0; -- 竞标资金
}
]]

RespUnionDiGongBidInfoMsg.meta = {__index = RespUnionDiGongBidInfoMsg};
function RespUnionDiGongBidInfoMsg:new()
	local obj = setmetatable( {}, RespUnionDiGongBidInfoMsg.meta);
	return obj;
end

function RespUnionDiGongBidInfoMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listvoVo = {};
		listvoVo.UnionName, idx = readString(pak, idx, 32);
		listvoVo.bidmoney, idx = readInt64(pak, idx);
		table.push(list1,listvoVo);
	end

end



--[[
返回帮派野外地宫竞标
]]

_G.RespUnionDiGongBidMsg = {};

RespUnionDiGongBidMsg.msgId = 7234;
RespUnionDiGongBidMsg.result = 0; -- 结果 0:成功 1：失败,-2已参与其他地宫竞标并暂时获得资格
RespUnionDiGongBidMsg.id = 0; -- 活动id



RespUnionDiGongBidMsg.meta = {__index = RespUnionDiGongBidMsg};
function RespUnionDiGongBidMsg:new()
	local obj = setmetatable( {}, RespUnionDiGongBidMsg.meta);
	return obj;
end

function RespUnionDiGongBidMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
返回跨服排行刷新状态
]]

_G.RespKuafuRankListStateMsg = {};

RespKuafuRankListStateMsg.msgId = 7236;
RespKuafuRankListStateMsg.rankType = 0; -- 1段位排行，2荣耀排行
RespKuafuRankListStateMsg.value = 0; -- 是否需要刷新,0不需要，1需要



RespKuafuRankListStateMsg.meta = {__index = RespKuafuRankListStateMsg};
function RespKuafuRankListStateMsg:new()
	local obj = setmetatable( {}, RespKuafuRankListStateMsg.meta);
	return obj;
end

function RespKuafuRankListStateMsg:ParseData(pak)
	local idx = 1;

	self.rankType, idx = readInt(pak, idx);
	self.value, idx = readInt(pak, idx);

end



--[[
返回跨服段位排行
]]

_G.RespKuafuRankDuanweiListMsg = {};

RespKuafuRankDuanweiListMsg.msgId = 7237;
RespKuafuRankDuanweiListMsg.type = 0; -- 1=段位，2=荣耀
RespKuafuRankDuanweiListMsg.version = 0; -- 版本
RespKuafuRankDuanweiListMsg.ret = 0; -- 0已经最新无需更新 1有数据更新
RespKuafuRankDuanweiListMsg.rankList_size = 0; -- list size
RespKuafuRankDuanweiListMsg.rankList = {}; -- list list



--[[
rankVOVO = {
	roleID = ""; -- 角色ID
	rank = 0; -- 名次
	roleName = ""; -- 人物名称
	lvl = 0; -- 等级
	fight = 0; -- 积分
	roletype = 0; -- 角色类型 1 萝莉 2 男魔 3 人男 4 御姐
	vipLvl = 0; -- vip等级
	rankvlue = 0; -- 段位
	vflag = 0; -- V计划
}
]]

RespKuafuRankDuanweiListMsg.meta = {__index = RespKuafuRankDuanweiListMsg};
function RespKuafuRankDuanweiListMsg:new()
	local obj = setmetatable( {}, RespKuafuRankDuanweiListMsg.meta);
	return obj;
end

function RespKuafuRankDuanweiListMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.version, idx = readInt(pak, idx);
	self.ret, idx = readByte(pak, idx);

	local list1 = {};
	self.rankList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local rankVOVo = {};
		rankVOVo.roleID, idx = readGuid(pak, idx);
		rankVOVo.rank, idx = readInt(pak, idx);
		rankVOVo.roleName, idx = readString(pak, idx, 32);
		rankVOVo.lvl, idx = readInt(pak, idx);
		rankVOVo.fight, idx = readInt64(pak, idx);
		rankVOVo.roletype, idx = readInt(pak, idx);
		rankVOVo.vipLvl, idx = readInt(pak, idx);
		rankVOVo.rankvlue, idx = readInt64(pak, idx);
		rankVOVo.vflag, idx = readInt(pak, idx);
		table.push(list1,rankVOVo);
	end

end



--[[
返回跨服荣耀榜信息
]]

_G.RespKuafuRongyaoInfoMsg = {};

RespKuafuRongyaoInfoMsg.msgId = 7238;
RespKuafuRongyaoInfoMsg.num = 0; -- 达到标准的人数
RespKuafuRongyaoInfoMsg.isAward = 0; -- 领奖状态0不可领1可领



RespKuafuRongyaoInfoMsg.meta = {__index = RespKuafuRongyaoInfoMsg};
function RespKuafuRongyaoInfoMsg:new()
	local obj = setmetatable( {}, RespKuafuRongyaoInfoMsg.meta);
	return obj;
end

function RespKuafuRongyaoInfoMsg:ParseData(pak)
	local idx = 1;

	self.num, idx = readInt(pak, idx);
	self.isAward, idx = readInt(pak, idx);

end



--[[
返回跨服荣耀榜奖励
]]

_G.RespGetPvpRongyaoRewardMsg = {};

RespGetPvpRongyaoRewardMsg.msgId = 7239;
RespGetPvpRongyaoRewardMsg.result = 0; -- 0成功1失败



RespGetPvpRongyaoRewardMsg.meta = {__index = RespGetPvpRongyaoRewardMsg};
function RespGetPvpRongyaoRewardMsg:new()
	local obj = setmetatable( {}, RespGetPvpRongyaoRewardMsg.meta);
	return obj;
end

function RespGetPvpRongyaoRewardMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回我方遗迹被攻击
]]

_G.RespSWYJStatueBeHitMsg = {};

RespSWYJStatueBeHitMsg.msgId = 7240;
RespSWYJStatueBeHitMsg.id = 0; -- 活动id



RespSWYJStatueBeHitMsg.meta = {__index = RespSWYJStatueBeHitMsg};
function RespSWYJStatueBeHitMsg:new()
	local obj = setmetatable( {}, RespSWYJStatueBeHitMsg.meta);
	return obj;
end

function RespSWYJStatueBeHitMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
返回GM设置公告
]]

_G.RespGMGuildNoticeMsg = {};

RespGMGuildNoticeMsg.msgId = 7241;
RespGMGuildNoticeMsg.result = 0; -- 



RespGMGuildNoticeMsg.meta = {__index = RespGMGuildNoticeMsg};
function RespGMGuildNoticeMsg:new()
	local obj = setmetatable( {}, RespGMGuildNoticeMsg.meta);
	return obj;
end

function RespGMGuildNoticeMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回进入跨服BOSS
]]

_G.RespEnterCrossBossMsg = {};

RespEnterCrossBossMsg.msgId = 7242;
RespEnterCrossBossMsg.result = 0; -- 0成功,1失败



RespEnterCrossBossMsg.meta = {__index = RespEnterCrossBossMsg};
function RespEnterCrossBossMsg:new()
	local obj = setmetatable( {}, RespEnterCrossBossMsg.meta);
	return obj;
end

function RespEnterCrossBossMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回跨服BOSS排行信息
]]

_G.RespCrossBossRankInfoMsg = {};

RespCrossBossRankInfoMsg.msgId = 7243;
RespCrossBossRankInfoMsg.level = 0; -- 等级
RespCrossBossRankInfoMsg.rankList_size = 5; -- list size
RespCrossBossRankInfoMsg.rankList = {}; -- list list



--[[
rankVOVO = {
	bossid = 0; -- BOSSID
	firstroleName = ""; -- 人物名称
	roleName = ""; -- 人物名称
}
]]

RespCrossBossRankInfoMsg.meta = {__index = RespCrossBossRankInfoMsg};
function RespCrossBossRankInfoMsg:new()
	local obj = setmetatable( {}, RespCrossBossRankInfoMsg.meta);
	return obj;
end

function RespCrossBossRankInfoMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);

	local list = {};
	self.rankList = list;
	local listSize = 5;

	for i=1,listSize do
		local rankVOVo = {};
		rankVOVo.bossid, idx = readInt(pak, idx);
		rankVOVo.firstroleName, idx = readString(pak, idx, 32);
		rankVOVo.roleName, idx = readString(pak, idx, 32);
		table.push(list,rankVOVo);
	end

end



--[[
跨服BOSS提醒
]]

_G.RespCrossBossNoticeMsg = {};

RespCrossBossNoticeMsg.msgId = 7244;



RespCrossBossNoticeMsg.meta = {__index = RespCrossBossNoticeMsg};
function RespCrossBossNoticeMsg:new()
	local obj = setmetatable( {}, RespCrossBossNoticeMsg.meta);
	return obj;
end

function RespCrossBossNoticeMsg:ParseData(pak)
	local idx = 1;


end



--[[
跨服BOSS资格信息
]]

_G.RespCrossBossMemInfoMsg = {};

RespCrossBossMemInfoMsg.msgId = 7245;
RespCrossBossMemInfoMsg.rankList_size = 0; -- list size
RespCrossBossMemInfoMsg.rankList = {}; -- list list



--[[
rankVOVO = {
	roleID = ""; -- 角色ID
	roleName = ""; -- 人物名称
}
]]

RespCrossBossMemInfoMsg.meta = {__index = RespCrossBossMemInfoMsg};
function RespCrossBossMemInfoMsg:new()
	local obj = setmetatable( {}, RespCrossBossMemInfoMsg.meta);
	return obj;
end

function RespCrossBossMemInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.rankList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local rankVOVo = {};
		rankVOVo.roleID, idx = readGuid(pak, idx);
		rankVOVo.roleName, idx = readString(pak, idx, 32);
		table.push(list1,rankVOVo);
	end

end



--[[
跨服BOSS提醒
]]

_G.RespCrossBossRemindMsg = {};

RespCrossBossRemindMsg.msgId = 7246;
RespCrossBossRemindMsg.NoticeList_size = 0; -- 活动通知 size
RespCrossBossRemindMsg.NoticeList = {}; -- 活动通知 list



--[[
NoticeVoVO = {
	type = 0; -- 活动id 1-跨服BOSS,2-跨服擂台资格赛，3-跨服擂台淘汰赛
	result = 0; -- 0=未开启,1=活动正在进行中
	lastTime = 0; -- 活动剩余时间(/秒)
}
]]

RespCrossBossRemindMsg.meta = {__index = RespCrossBossRemindMsg};
function RespCrossBossRemindMsg:new()
	local obj = setmetatable( {}, RespCrossBossRemindMsg.meta);
	return obj;
end

function RespCrossBossRemindMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.NoticeList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local NoticeVoVo = {};
		NoticeVoVo.type, idx = readInt(pak, idx);
		NoticeVoVo.result, idx = readInt(pak, idx);
		NoticeVoVo.lastTime, idx = readInt(pak, idx);
		table.push(list1,NoticeVoVo);
	end

end



--[[
返回进入跨服擂台赛
]]

_G.RespEnterCrossArenaMsg = {};

RespEnterCrossArenaMsg.msgId = 7247;
RespEnterCrossArenaMsg.result = 0; -- 0成功,1失败



RespEnterCrossArenaMsg.meta = {__index = RespEnterCrossArenaMsg};
function RespEnterCrossArenaMsg:new()
	local obj = setmetatable( {}, RespEnterCrossArenaMsg.meta);
	return obj;
end

function RespEnterCrossArenaMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回跨服擂台赛排名
]]

_G.RespCrossArenaRankInfoMsg = {};

RespCrossArenaRankInfoMsg.msgId = 7248;
RespCrossArenaRankInfoMsg.seasonid = 0; -- 第几届
RespCrossArenaRankInfoMsg.cnt = 0; -- 总届数
RespCrossArenaRankInfoMsg.guwucnt = 0; -- 鼓舞次数
RespCrossArenaRankInfoMsg.guwuflag = 0; -- 是否可以鼓舞
RespCrossArenaRankInfoMsg.enterflag = 0; -- 是否可以进入
RespCrossArenaRankInfoMsg.rankList_size = 32; -- list size
RespCrossArenaRankInfoMsg.rankList = {}; -- list list



--[[
rankVOVO = {
	id = 0; -- ID
	prof = 0; -- 职业
	roleName = ""; -- 人物名称
}
]]

RespCrossArenaRankInfoMsg.meta = {__index = RespCrossArenaRankInfoMsg};
function RespCrossArenaRankInfoMsg:new()
	local obj = setmetatable( {}, RespCrossArenaRankInfoMsg.meta);
	return obj;
end

function RespCrossArenaRankInfoMsg:ParseData(pak)
	local idx = 1;

	self.seasonid, idx = readInt(pak, idx);
	self.cnt, idx = readInt(pak, idx);
	self.guwucnt, idx = readInt(pak, idx);
	self.guwuflag, idx = readByte(pak, idx);
	self.enterflag, idx = readByte(pak, idx);

	local list = {};
	self.rankList = list;
	local listSize = 32;

	for i=1,listSize do
		local rankVOVo = {};
		rankVOVo.id, idx = readInt(pak, idx);
		rankVOVo.prof, idx = readInt(pak, idx);
		rankVOVo.roleName, idx = readString(pak, idx, 32);
		table.push(list,rankVOVo);
	end

end



--[[
跨服擂台赛资格提醒
]]

_G.RespCrossArenaRemaindMsg = {};

RespCrossArenaRemaindMsg.msgId = 7249;



RespCrossArenaRemaindMsg.meta = {__index = RespCrossArenaRemaindMsg};
function RespCrossArenaRemaindMsg:new()
	local obj = setmetatable( {}, RespCrossArenaRemaindMsg.meta);
	return obj;
end

function RespCrossArenaRemaindMsg:ParseData(pak)
	local idx = 1;


end



--[[
返回跨服擂台赛资格
]]

_G.RespCrossArenaZigeMsg = {};

RespCrossArenaZigeMsg.msgId = 7250;
RespCrossArenaZigeMsg.rankList_size = 0; -- list size
RespCrossArenaZigeMsg.rankList = {}; -- list list



--[[
rankVOVO = {
	power = 0; -- 战力
	prof = 0; -- 职业
	roleName = ""; -- 人物名称
}
]]

RespCrossArenaZigeMsg.meta = {__index = RespCrossArenaZigeMsg};
function RespCrossArenaZigeMsg:new()
	local obj = setmetatable( {}, RespCrossArenaZigeMsg.meta);
	return obj;
end

function RespCrossArenaZigeMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.rankList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local rankVOVo = {};
		rankVOVo.power, idx = readInt64(pak, idx);
		rankVOVo.prof, idx = readInt(pak, idx);
		rankVOVo.roleName, idx = readString(pak, idx, 32);
		table.push(list1,rankVOVo);
	end

end



--[[
求婚结果
]]

_G.ResProposalResMsg = {};

ResProposalResMsg.msgId = 7251;
ResProposalResMsg.result = 0; -- 0成功，-1道具不足，-2对方不在线 -3同性结婚 -4本身已在结婚或求婚状态 -5等级不足, -6对方已在结婚或求婚状态 -7对方已经与你是婚姻状态 -8对方等级不足, -9对方不在同一地图或线路



ResProposalResMsg.meta = {__index = ResProposalResMsg};
function ResProposalResMsg:new()
	local obj = setmetatable( {}, ResProposalResMsg.meta);
	return obj;
end

function ResProposalResMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
被求婚
]]

_G.ResBeProposaledMsg = {};

ResBeProposaledMsg.msgId = 7252;
ResBeProposaledMsg.name = ""; -- 求婚者
ResBeProposaledMsg.desc = ""; -- 求婚宣言
ResBeProposaledMsg.ringId = 0; -- 戒指id



ResBeProposaledMsg.meta = {__index = ResBeProposaledMsg};
function ResBeProposaledMsg:new()
	local obj = setmetatable( {}, ResBeProposaledMsg.meta);
	return obj;
end

function ResBeProposaledMsg:ParseData(pak)
	local idx = 1;

	self.name, idx = readString(pak, idx, 32);
	self.desc, idx = readString(pak, idx, 128);
	self.ringId, idx = readInt(pak, idx);

end



--[[
返回时间列表
]]

_G.ResApplyNarryDataMsg = {};

ResApplyNarryDataMsg.msgId = 7253;
ResApplyNarryDataMsg.time = 0; -- 预约时间戳
ResApplyNarryDataMsg.TimeList_size = 0; -- list size
ResApplyNarryDataMsg.TimeList = {}; -- list list



--[[
DataVOVO = {
	TimeID = 0; -- 时间下标
	naName = ""; -- 男人名称
	nvName = ""; -- 女人名称
}
]]

ResApplyNarryDataMsg.meta = {__index = ResApplyNarryDataMsg};
function ResApplyNarryDataMsg:new()
	local obj = setmetatable( {}, ResApplyNarryDataMsg.meta);
	return obj;
end

function ResApplyNarryDataMsg:ParseData(pak)
	local idx = 1;

	self.time, idx = readInt64(pak, idx);

	local list1 = {};
	self.TimeList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local DataVOVo = {};
		DataVOVo.TimeID, idx = readInt(pak, idx);
		DataVOVo.naName, idx = readString(pak, idx, 32);
		DataVOVo.nvName, idx = readString(pak, idx, 32);
		table.push(list1,DataVOVo);
	end

end



--[[
申请返回
]]

_G.ResApplyMarryMsg = {};

ResApplyMarryMsg.msgId = 7254;
ResApplyMarryMsg.result = 0; -- 0成功，-1时间不可选择 -2配偶不在 -3需要与组成2人队伍 。-4选择时间已过-5只可队长操作,-6配偶不同线，或者不同地图 -7 没有选择婚礼类型



ResApplyMarryMsg.meta = {__index = ResApplyMarryMsg};
function ResApplyMarryMsg:new()
	local obj = setmetatable( {}, ResApplyMarryMsg.meta);
	return obj;
end

function ResApplyMarryMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
申请返回
]]

_G.ResMarryInviteMsg = {};

ResMarryInviteMsg.msgId = 7256;
ResMarryInviteMsg.result = 0; -- 0成功，-1没有资格,-2只可队长操作, -3没有可邀请的人



ResMarryInviteMsg.meta = {__index = ResMarryInviteMsg};
function ResMarryInviteMsg:new()
	local obj = setmetatable( {}, ResMarryInviteMsg.meta);
	return obj;
end

function ResMarryInviteMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
查看红包详情
]]

_G.ResLookMarryRedPacketsMsg = {};

ResLookMarryRedPacketsMsg.msgId = 7257;
ResLookMarryRedPacketsMsg.datalist_size = 0; -- list size
ResLookMarryRedPacketsMsg.datalist = {}; -- list list



--[[
DataVOVO = {
	name = ""; -- 玩家名字
	silverNum = 0; -- 红包银两金额
	goldNum = 0; -- 红包元宝金额
	desc = ""; -- 赠言
}
]]

ResLookMarryRedPacketsMsg.meta = {__index = ResLookMarryRedPacketsMsg};
function ResLookMarryRedPacketsMsg:new()
	local obj = setmetatable( {}, ResLookMarryRedPacketsMsg.meta);
	return obj;
end

function ResLookMarryRedPacketsMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.datalist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local DataVOVo = {};
		DataVOVo.name, idx = readString(pak, idx, 32);
		DataVOVo.silverNum, idx = readInt(pak, idx);
		DataVOVo.goldNum, idx = readInt(pak, idx);
		DataVOVo.desc, idx = readString(pak, idx, 64);
		table.push(list1,DataVOVo);
	end

end



--[[
收到请帖给提醒
]]

_G.ResMarryCardRemindMsg = {};

ResMarryCardRemindMsg.msgId = 7259;
ResMarryCardRemindMsg.naroleName = ""; -- 发请帖的人



ResMarryCardRemindMsg.meta = {__index = ResMarryCardRemindMsg};
function ResMarryCardRemindMsg:new()
	local obj = setmetatable( {}, ResMarryCardRemindMsg.meta);
	return obj;
end

function ResMarryCardRemindMsg:ParseData(pak)
	local idx = 1;

	self.naroleName, idx = readString(pak, idx, 32);

end



--[[
婚礼提醒
]]

_G.ResMarryTimeRemandMsg = {};

ResMarryTimeRemandMsg.msgId = 7260;
ResMarryTimeRemandMsg.naroleName = ""; -- 男名字
ResMarryTimeRemandMsg.nvroleName = ""; -- 女名字
ResMarryTimeRemandMsg.naprof = 0; -- 男职业
ResMarryTimeRemandMsg.nvprof = 0; -- 女职业



ResMarryTimeRemandMsg.meta = {__index = ResMarryTimeRemandMsg};
function ResMarryTimeRemandMsg:new()
	local obj = setmetatable( {}, ResMarryTimeRemandMsg.meta);
	return obj;
end

function ResMarryTimeRemandMsg:ParseData(pak)
	local idx = 1;

	self.naroleName, idx = readString(pak, idx, 32);
	self.nvroleName, idx = readString(pak, idx, 32);
	self.naprof, idx = readInt(pak, idx);
	self.nvprof, idx = readInt(pak, idx);

end



--[[
传送切线
]]

_G.ResFlyToMateMsg = {};

ResFlyToMateMsg.msgId = 7261;
ResFlyToMateMsg.lineId = 0; -- 线id -1配偶不在线 -2自己不在野外或主城 -3目标不在野外或主城 -4 CD中



ResFlyToMateMsg.meta = {__index = ResFlyToMateMsg};
function ResFlyToMateMsg:new()
	local obj = setmetatable( {}, ResFlyToMateMsg.meta);
	return obj;
end

function ResFlyToMateMsg:ParseData(pak)
	local idx = 1;

	self.lineId, idx = readInt(pak, idx);

end



--[[
返回跨服擂台赛下注信息
]]

_G.RespCrossArenaXiaZhuInfoMsg = {};

RespCrossArenaXiaZhuInfoMsg.msgId = 7263;
RespCrossArenaXiaZhuInfoMsg.id = ""; -- 我下注的ID
RespCrossArenaXiaZhuInfoMsg.rankList_size = 64; -- list size
RespCrossArenaXiaZhuInfoMsg.rankList = {}; -- list list



--[[
rankVOVO = {
	id = ""; -- ID
	prof = 0; -- 职业
	fight = 0; -- 战斗力
	guwucnt = 0; -- 鼓舞次数
	xiazhucnt = 0; -- 下注金额
	roleName = ""; -- 人物名称
}
]]

RespCrossArenaXiaZhuInfoMsg.meta = {__index = RespCrossArenaXiaZhuInfoMsg};
function RespCrossArenaXiaZhuInfoMsg:new()
	local obj = setmetatable( {}, RespCrossArenaXiaZhuInfoMsg.meta);
	return obj;
end

function RespCrossArenaXiaZhuInfoMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);

	local list = {};
	self.rankList = list;
	local listSize = 64;

	for i=1,listSize do
		local rankVOVo = {};
		rankVOVo.id, idx = readGuid(pak, idx);
		rankVOVo.prof, idx = readInt(pak, idx);
		rankVOVo.fight, idx = readInt64(pak, idx);
		rankVOVo.guwucnt, idx = readInt(pak, idx);
		rankVOVo.xiazhucnt, idx = readInt64(pak, idx);
		rankVOVo.roleName, idx = readString(pak, idx, 32);
		table.push(list,rankVOVo);
	end

end



--[[
返回跨服擂台赛下注结果
]]

_G.RespCrossArenaXiaZhuMsg = {};

RespCrossArenaXiaZhuMsg.msgId = 7264;
RespCrossArenaXiaZhuMsg.result = 0; -- 结果
RespCrossArenaXiaZhuMsg.gold = 0; -- 下注金额
RespCrossArenaXiaZhuMsg.id = ""; -- ID



RespCrossArenaXiaZhuMsg.meta = {__index = RespCrossArenaXiaZhuMsg};
function RespCrossArenaXiaZhuMsg:new()
	local obj = setmetatable( {}, RespCrossArenaXiaZhuMsg.meta);
	return obj;
end

function RespCrossArenaXiaZhuMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.gold, idx = readInt(pak, idx);
	self.id, idx = readGuid(pak, idx);

end



--[[
返回跨服擂台赛鼓舞结果
]]

_G.RespCrossArenaGuWuMsg = {};

RespCrossArenaGuWuMsg.msgId = 7265;
RespCrossArenaGuWuMsg.result = 0; -- 结果



RespCrossArenaGuWuMsg.meta = {__index = RespCrossArenaGuWuMsg};
function RespCrossArenaGuWuMsg:new()
	local obj = setmetatable( {}, RespCrossArenaGuWuMsg.meta);
	return obj;
end

function RespCrossArenaGuWuMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回跨服擂台赛对手
]]

_G.RespCrossArenaDuiShouMsg = {};

RespCrossArenaDuiShouMsg.msgId = 7266;
RespCrossArenaDuiShouMsg.prof = 0; -- 职业
RespCrossArenaDuiShouMsg.fight = 0; -- 战斗力
RespCrossArenaDuiShouMsg.roleName = ""; -- 人物名称



RespCrossArenaDuiShouMsg.meta = {__index = RespCrossArenaDuiShouMsg};
function RespCrossArenaDuiShouMsg:new()
	local obj = setmetatable( {}, RespCrossArenaDuiShouMsg.meta);
	return obj;
end

function RespCrossArenaDuiShouMsg:ParseData(pak)
	local idx = 1;

	self.prof, idx = readInt(pak, idx);
	self.fight, idx = readInt64(pak, idx);
	self.roleName, idx = readString(pak, idx, 32);

end



--[[
返回激活邀请码
]]

_G.RespInvitationCodeMsg = {};

RespInvitationCodeMsg.msgId = 7267;
RespInvitationCodeMsg.codetype = 0; -- 码类型
RespInvitationCodeMsg.result = 0; -- 结果(0-成功 1-参数错误 2-无效码 -3-已经被邀请过 4-邀请人已达上限 5-系统忙，请稍后再试)



RespInvitationCodeMsg.meta = {__index = RespInvitationCodeMsg};
function RespInvitationCodeMsg:new()
	local obj = setmetatable( {}, RespInvitationCodeMsg.meta);
	return obj;
end

function RespInvitationCodeMsg:ParseData(pak)
	local idx = 1;

	self.codetype, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
服务器通知：圣诞兑换信息
]]

_G.RespChristmasDonateInfoMsg = {};

RespChristmasDonateInfoMsg.msgId = 7268;
RespChristmasDonateInfoMsg.allprogress = 0; -- 总进度
RespChristmasDonateInfoMsg.rewardstate = 0; -- 奖励领取状态 按位取 取到就是已领取 1 2 3 4



RespChristmasDonateInfoMsg.meta = {__index = RespChristmasDonateInfoMsg};
function RespChristmasDonateInfoMsg:new()
	local obj = setmetatable( {}, RespChristmasDonateInfoMsg.meta);
	return obj;
end

function RespChristmasDonateInfoMsg:ParseData(pak)
	local idx = 1;

	self.allprogress, idx = readInt(pak, idx);
	self.rewardstate, idx = readInt(pak, idx);

end



--[[
服务器通知：返回兑换结果
]]

_G.RespSubmitChristmasDonateResultMsg = {};

RespSubmitChristmasDonateResultMsg.msgId = 7269;
RespSubmitChristmasDonateResultMsg.result = 0; -- 返回结果 0成功
RespSubmitChristmasDonateResultMsg.type = 0; -- 兑换类型 1234
RespSubmitChristmasDonateResultMsg.progress = 0; -- 总进度
RespSubmitChristmasDonateResultMsg.num = 0; -- 兑换个数



RespSubmitChristmasDonateResultMsg.meta = {__index = RespSubmitChristmasDonateResultMsg};
function RespSubmitChristmasDonateResultMsg:new()
	local obj = setmetatable( {}, RespSubmitChristmasDonateResultMsg.meta);
	return obj;
end

function RespSubmitChristmasDonateResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);
	self.progress, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
服务器通知：返回领奖结果
]]

_G.RespBackChristmasDonateRewardMsg = {};

RespBackChristmasDonateRewardMsg.msgId = 7270;
RespBackChristmasDonateRewardMsg.result = 0; -- 返回结果 0成功
RespBackChristmasDonateRewardMsg.type = 0; -- 领奖类型 1234



RespBackChristmasDonateRewardMsg.meta = {__index = RespBackChristmasDonateRewardMsg};
function RespBackChristmasDonateRewardMsg:new()
	local obj = setmetatable( {}, RespBackChristmasDonateRewardMsg.meta);
	return obj;
end

function RespBackChristmasDonateRewardMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
资格赛提醒
]]

_G.RespCrossArenaZiGeNoticeMsg = {};

RespCrossArenaZiGeNoticeMsg.msgId = 7271;



RespCrossArenaZiGeNoticeMsg.meta = {__index = RespCrossArenaZiGeNoticeMsg};
function RespCrossArenaZiGeNoticeMsg:new()
	local obj = setmetatable( {}, RespCrossArenaZiGeNoticeMsg.meta);
	return obj;
end

function RespCrossArenaZiGeNoticeMsg:ParseData(pak)
	local idx = 1;


end



--[[
淘汰赛提醒
]]

_G.RespCrossArenaTaoTaiNoticeMsg = {};

RespCrossArenaTaoTaiNoticeMsg.msgId = 7272;



RespCrossArenaTaoTaiNoticeMsg.meta = {__index = RespCrossArenaTaoTaiNoticeMsg};
function RespCrossArenaTaoTaiNoticeMsg:new()
	local obj = setmetatable( {}, RespCrossArenaTaoTaiNoticeMsg.meta);
	return obj;
end

function RespCrossArenaTaoTaiNoticeMsg:ParseData(pak)
	local idx = 1;


end



--[[
求婚成功
]]

_G.ResProposaledSureMsg = {};

ResProposaledSureMsg.msgId = 7273;
ResProposaledSureMsg.ringId = 0; -- 戒指id
ResProposaledSureMsg.naProf = 0; -- 男职业
ResProposaledSureMsg.nvProf = 0; -- 女职业



ResProposaledSureMsg.meta = {__index = ResProposaledSureMsg};
function ResProposaledSureMsg:new()
	local obj = setmetatable( {}, ResProposaledSureMsg.meta);
	return obj;
end

function ResProposaledSureMsg:ParseData(pak)
	local idx = 1;

	self.ringId, idx = readInt(pak, idx);
	self.naProf, idx = readInt(pak, idx);
	self.nvProf, idx = readInt(pak, idx);

end



--[[
轮空提醒
]]

_G.RespCrossArenaLunKongNoticeMsg = {};

RespCrossArenaLunKongNoticeMsg.msgId = 7274;



RespCrossArenaLunKongNoticeMsg.meta = {__index = RespCrossArenaLunKongNoticeMsg};
function RespCrossArenaLunKongNoticeMsg:new()
	local obj = setmetatable( {}, RespCrossArenaLunKongNoticeMsg.meta);
	return obj;
end

function RespCrossArenaLunKongNoticeMsg:ParseData(pak)
	local idx = 1;


end



--[[
返回：请求腾讯充值
]]

_G.RespTXRechargeMsg = {};

RespTXRechargeMsg.msgId = 7275;
RespTXRechargeMsg.result = 0; -- 返回结果 0成功
RespTXRechargeMsg.url = ""; -- 返回充值url



RespTXRechargeMsg.meta = {__index = RespTXRechargeMsg};
function RespTXRechargeMsg:new()
	local obj = setmetatable( {}, RespTXRechargeMsg.meta);
	return obj;
end

function RespTXRechargeMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.url, idx = readString(pak, idx, 256);

end



--[[
返回：TX openkey过期
]]

_G.RespTXOpenkeyOutMsg = {};

RespTXOpenkeyOutMsg.msgId = 7276;



RespTXOpenkeyOutMsg.meta = {__index = RespTXOpenkeyOutMsg};
function RespTXOpenkeyOutMsg:new()
	local obj = setmetatable( {}, RespTXOpenkeyOutMsg.meta);
	return obj;
end

function RespTXOpenkeyOutMsg:ParseData(pak)
	local idx = 1;


end



--[[
返回：TX黄钻
]]

_G.RespTXHFlagMsg = {};

RespTXHFlagMsg.msgId = 7277;
RespTXHFlagMsg.txhflag = 0; -- 黄钻标识



RespTXHFlagMsg.meta = {__index = RespTXHFlagMsg};
function RespTXHFlagMsg:new()
	local obj = setmetatable( {}, RespTXHFlagMsg.meta);
	return obj;
end

function RespTXHFlagMsg:ParseData(pak)
	local idx = 1;

	self.txhflag, idx = readInt(pak, idx);

end



--[[
通知玩家进入场景
]]

_G.RespSceneEnterGameMsg = {};

RespSceneEnterGameMsg.msgId = 8001;
RespSceneEnterGameMsg.result = 0; -- 结果
RespSceneEnterGameMsg.lineID = 0; -- 线
RespSceneEnterGameMsg.posX = 0; -- X坐标
RespSceneEnterGameMsg.posY = 0; -- Y坐标
RespSceneEnterGameMsg.dir = 0; -- 方向
RespSceneEnterGameMsg.mapID = 0; -- 地图ID
RespSceneEnterGameMsg.dungeonId = 0; -- 副本ID
RespSceneEnterGameMsg.type = 0; -- 0:登录游戏 1:切换场景
RespSceneEnterGameMsg.serverSTime = 0; -- 开服时间,时间戳,秒
RespSceneEnterGameMsg.MergeSTime = 0; -- 合服时间,时间戳,秒



RespSceneEnterGameMsg.meta = {__index = RespSceneEnterGameMsg};
function RespSceneEnterGameMsg:new()
	local obj = setmetatable( {}, RespSceneEnterGameMsg.meta);
	return obj;
end

function RespSceneEnterGameMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.lineID, idx = readInt(pak, idx);
	self.posX, idx = readDouble(pak, idx);
	self.posY, idx = readDouble(pak, idx);
	self.dir, idx = readDouble(pak, idx);
	self.mapID, idx = readInt(pak, idx);
	self.dungeonId, idx = readInt(pak, idx);
	self.type, idx = readByte(pak, idx);
	self.serverSTime, idx = readInt64(pak, idx);
	self.MergeSTime, idx = readInt64(pak, idx);

end



--[[
主角接收自己的信息
]]

_G.RespSceneShowMeInfoMsg = {};

RespSceneShowMeInfoMsg.msgId = 8002;
RespSceneShowMeInfoMsg.roleID = ""; -- 角色ID
RespSceneShowMeInfoMsg.roleName = ""; -- 角色名字
RespSceneShowMeInfoMsg.sex = 0; -- 性别
RespSceneShowMeInfoMsg.prof = 0; -- 职业
RespSceneShowMeInfoMsg.icon = 0; -- 头像
RespSceneShowMeInfoMsg.dress = 0; -- 衣服
RespSceneShowMeInfoMsg.arms = 0; -- 武器
RespSceneShowMeInfoMsg.fashionshead = 0; -- 时装头
RespSceneShowMeInfoMsg.fashionsarms = 0; -- 时装武器
RespSceneShowMeInfoMsg.fashionsdress = 0; -- 时装衣服
RespSceneShowMeInfoMsg.wuhun = 0; -- 武魂
RespSceneShowMeInfoMsg.shenbin = 0; -- 神兵
RespSceneShowMeInfoMsg.faction = 0; -- 阵营
RespSceneShowMeInfoMsg.realm = 0; -- 境界0无
RespSceneShowMeInfoMsg.actpet = 0; -- 萌宠
RespSceneShowMeInfoMsg.wing = 0; -- 翅膀
RespSceneShowMeInfoMsg.suitflag = 0; -- 套装标识
RespSceneShowMeInfoMsg.footprints = 0; -- 脚印
RespSceneShowMeInfoMsg.shenwuId = 0; -- 神武ID
RespSceneShowMeInfoMsg.yuanlingId = 0; -- 元灵ID
RespSceneShowMeInfoMsg.zhannuId = 0; -- 战弩ID
RespSceneShowMeInfoMsg.shoulder = 0; -- 肩膀



RespSceneShowMeInfoMsg.meta = {__index = RespSceneShowMeInfoMsg};
function RespSceneShowMeInfoMsg:new()
	local obj = setmetatable( {}, RespSceneShowMeInfoMsg.meta);
	return obj;
end

function RespSceneShowMeInfoMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.roleName, idx = readString(pak, idx, 32);
	self.sex, idx = readByte(pak, idx);
	self.prof, idx = readInt(pak, idx);
	self.icon, idx = readInt(pak, idx);
	self.dress, idx = readInt(pak, idx);
	self.arms, idx = readInt(pak, idx);
	self.fashionshead, idx = readInt(pak, idx);
	self.fashionsarms, idx = readInt(pak, idx);
	self.fashionsdress, idx = readInt(pak, idx);
	self.wuhun, idx = readInt(pak, idx);
	self.shenbin, idx = readInt(pak, idx);
	self.faction, idx = readByte(pak, idx);
	self.realm, idx = readInt(pak, idx);
	self.actpet, idx = readInt(pak, idx);
	self.wing, idx = readInt(pak, idx);
	self.suitflag, idx = readInt(pak, idx);
	self.footprints, idx = readInt(pak, idx);
	self.shenwuId, idx = readByte(pak, idx);
	self.yuanlingId, idx = readByte(pak, idx);
	self.zhannuId, idx = readByte(pak, idx);
	self.shoulder, idx = readInt(pak, idx);

end



--[[
主角进入场景 回应
]]

_G.RespSceneEnterSceneRetMsg = {};

RespSceneEnterSceneRetMsg.msgId = 8003;



RespSceneEnterSceneRetMsg.meta = {__index = RespSceneEnterSceneRetMsg};
function RespSceneEnterSceneRetMsg:new()
	local obj = setmetatable( {}, RespSceneEnterSceneRetMsg.meta);
	return obj;
end

function RespSceneEnterSceneRetMsg:ParseData(pak)
	local idx = 1;


end



--[[
返回主角请求移动
]]

_G.RespSceneMoveToRetMsg = {};

RespSceneMoveToRetMsg.msgId = 8004;
RespSceneMoveToRetMsg.result = 0; -- 结果：0成功 -1错误
RespSceneMoveToRetMsg.srcX = 0; -- 源X
RespSceneMoveToRetMsg.srcY = 0; -- 源Y
RespSceneMoveToRetMsg.dirX = 0; -- 方向X坐标
RespSceneMoveToRetMsg.dirY = 0; -- 方向y坐标



RespSceneMoveToRetMsg.meta = {__index = RespSceneMoveToRetMsg};
function RespSceneMoveToRetMsg:new()
	local obj = setmetatable( {}, RespSceneMoveToRetMsg.meta);
	return obj;
end

function RespSceneMoveToRetMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.srcX, idx = readDouble(pak, idx);
	self.srcY, idx = readDouble(pak, idx);
	self.dirX, idx = readDouble(pak, idx);
	self.dirY, idx = readDouble(pak, idx);

end



--[[
返回主角请求周围玩家
]]

_G.RespSceneGetRoleRetMsg = {};

RespSceneGetRoleRetMsg.msgId = 8005;
RespSceneGetRoleRetMsg.result = 0; -- 结果：0成功 -1错误
RespSceneGetRoleRetMsg.count = 0; -- 玩家数量



RespSceneGetRoleRetMsg.meta = {__index = RespSceneGetRoleRetMsg};
function RespSceneGetRoleRetMsg:new()
	local obj = setmetatable( {}, RespSceneGetRoleRetMsg.meta);
	return obj;
end

function RespSceneGetRoleRetMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.count, idx = readInt(pak, idx);

end



--[[
主角请求停止移动 回复
]]

_G.RespSceneMoveStopRetMsg = {};

RespSceneMoveStopRetMsg.msgId = 8006;
RespSceneMoveStopRetMsg.result = 0; -- 结果：0成功 -1错误
RespSceneMoveStopRetMsg.stopX = 0; -- 
RespSceneMoveStopRetMsg.stopY = 0; -- 
RespSceneMoveStopRetMsg.dir = 0; -- 



RespSceneMoveStopRetMsg.meta = {__index = RespSceneMoveStopRetMsg};
function RespSceneMoveStopRetMsg:new()
	local obj = setmetatable( {}, RespSceneMoveStopRetMsg.meta);
	return obj;
end

function RespSceneMoveStopRetMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.stopX, idx = readDouble(pak, idx);
	self.stopY, idx = readDouble(pak, idx);
	self.dir, idx = readDouble(pak, idx);

end



--[[
收到其他玩家移动通知
]]

_G.RespSceneObjMoveToNotifyMsg = {};

RespSceneObjMoveToNotifyMsg.msgId = 8007;
RespSceneObjMoveToNotifyMsg.roleId = ""; -- 角色ID
RespSceneObjMoveToNotifyMsg.objType = 0; -- 类型
RespSceneObjMoveToNotifyMsg.srcX = 0; -- 
RespSceneObjMoveToNotifyMsg.srcY = 0; -- 
RespSceneObjMoveToNotifyMsg.disX = 0; -- 
RespSceneObjMoveToNotifyMsg.disY = 0; -- 



RespSceneObjMoveToNotifyMsg.meta = {__index = RespSceneObjMoveToNotifyMsg};
function RespSceneObjMoveToNotifyMsg:new()
	local obj = setmetatable( {}, RespSceneObjMoveToNotifyMsg.meta);
	return obj;
end

function RespSceneObjMoveToNotifyMsg:ParseData(pak)
	local idx = 1;

	self.roleId, idx = readGuid(pak, idx);
	self.objType, idx = readByte(pak, idx);
	self.srcX, idx = readInt(pak, idx);
	self.srcY, idx = readInt(pak, idx);
	self.disX, idx = readInt(pak, idx);
	self.disY, idx = readInt(pak, idx);

end



--[[
收到其他玩家停止移动
]]

_G.RespSceneObjMoveStopNotifyMsg = {};

RespSceneObjMoveStopNotifyMsg.msgId = 8008;
RespSceneObjMoveStopNotifyMsg.roleId = ""; -- 角色ID
RespSceneObjMoveStopNotifyMsg.objType = 0; -- 
RespSceneObjMoveStopNotifyMsg.stopX = 0; -- 
RespSceneObjMoveStopNotifyMsg.stopY = 0; -- 
RespSceneObjMoveStopNotifyMsg.dir = 0; -- 



RespSceneObjMoveStopNotifyMsg.meta = {__index = RespSceneObjMoveStopNotifyMsg};
function RespSceneObjMoveStopNotifyMsg:new()
	local obj = setmetatable( {}, RespSceneObjMoveStopNotifyMsg.meta);
	return obj;
end

function RespSceneObjMoveStopNotifyMsg:ParseData(pak)
	local idx = 1;

	self.roleId, idx = readGuid(pak, idx);
	self.objType, idx = readByte(pak, idx);
	self.stopX, idx = readInt(pak, idx);
	self.stopY, idx = readInt(pak, idx);
	self.dir, idx = readInt(pak, idx);

end



--[[
收到其他玩家离开通知
]]

_G.RespScenePlayerLeftNotifyMsg = {};

RespScenePlayerLeftNotifyMsg.msgId = 8010;
RespScenePlayerLeftNotifyMsg.roleId = ""; -- 角色ID



RespScenePlayerLeftNotifyMsg.meta = {__index = RespScenePlayerLeftNotifyMsg};
function RespScenePlayerLeftNotifyMsg:new()
	local obj = setmetatable( {}, RespScenePlayerLeftNotifyMsg.meta);
	return obj;
end

function RespScenePlayerLeftNotifyMsg:ParseData(pak)
	local idx = 1;

	self.roleId, idx = readGuid(pak, idx);

end



--[[

]]

_G.RespObjAttrInfoMsg = {};

RespObjAttrInfoMsg.msgId = 8011;
RespObjAttrInfoMsg.roleId = ""; -- 角色ID
RespObjAttrInfoMsg.objType = 0; -- 类型
RespObjAttrInfoMsg.attrData_size = 0; --  size
RespObjAttrInfoMsg.attrData = {}; --  list



--[[
ClientAttrVO = {
	type = 0; -- 类型
	value = 0; -- 值
}
]]

RespObjAttrInfoMsg.meta = {__index = RespObjAttrInfoMsg};
function RespObjAttrInfoMsg:new()
	local obj = setmetatable( {}, RespObjAttrInfoMsg.meta);
	return obj;
end

function RespObjAttrInfoMsg:ParseData(pak)
	local idx = 1;

	self.roleId, idx = readGuid(pak, idx);
	self.objType, idx = readByte(pak, idx);

	local list1 = {};
	self.attrData = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ClientAttrVo = {};
		ClientAttrVo.type, idx = readByte(pak, idx);
		ClientAttrVo.value, idx = readDouble(pak, idx);
		table.push(list1,ClientAttrVo);
	end

end



--[[
Obj进入场景
]]

_G.RespSceneObjEnterNotifyMsg = {};

RespSceneObjEnterNotifyMsg.msgId = 8012;
RespSceneObjEnterNotifyMsg.data = ""; -- 数据



RespSceneObjEnterNotifyMsg.meta = {__index = RespSceneObjEnterNotifyMsg};
function RespSceneObjEnterNotifyMsg:new()
	local obj = setmetatable( {}, RespSceneObjEnterNotifyMsg.meta);
	return obj;
end

function RespSceneObjEnterNotifyMsg:ParseData(pak)
	local idx = 1;

	self.data, idx = readString(pak, idx);

end



--[[
Obj离开场景
]]

_G.RespSceneObjLeftNotifyMsg = {};

RespSceneObjLeftNotifyMsg.msgId = 8013;
RespSceneObjLeftNotifyMsg.guid = ""; -- guid
RespSceneObjLeftNotifyMsg.objType = 0; -- 类型



RespSceneObjLeftNotifyMsg.meta = {__index = RespSceneObjLeftNotifyMsg};
function RespSceneObjLeftNotifyMsg:new()
	local obj = setmetatable( {}, RespSceneObjLeftNotifyMsg.meta);
	return obj;
end

function RespSceneObjLeftNotifyMsg:ParseData(pak)
	local idx = 1;

	self.guid, idx = readGuid(pak, idx);
	self.objType, idx = readByte(pak, idx);

end



--[[
服务器通知客户端，增加物品
]]

_G.RespItemAddMsg = {};

RespItemAddMsg.msgId = 8014;
RespItemAddMsg.id = ""; -- 物品uid
RespItemAddMsg.tid = 0; -- 物品id
RespItemAddMsg.count = 0; -- 物品数量
RespItemAddMsg.bag = 0; -- 属于哪个背包
RespItemAddMsg.pos = 0; -- 格子号
RespItemAddMsg.useCnt = 0; -- 当前使用次数
RespItemAddMsg.todayUse = 0; -- 当天使用次数
RespItemAddMsg.flags = 0; -- 标志位,第1位:绑定, 第2位:交易绑定



RespItemAddMsg.meta = {__index = RespItemAddMsg};
function RespItemAddMsg:new()
	local obj = setmetatable( {}, RespItemAddMsg.meta);
	return obj;
end

function RespItemAddMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.tid, idx = readInt(pak, idx);
	self.count, idx = readInt(pak, idx);
	self.bag, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);
	self.useCnt, idx = readInt(pak, idx);
	self.todayUse, idx = readInt(pak, idx);
	self.flags, idx = readInt64(pak, idx);

end



--[[
服务器通知客户端，删除物品
]]

_G.RespItemDelMsg = {};

RespItemDelMsg.msgId = 8015;
RespItemDelMsg.item_bag = 0; -- 背包
RespItemDelMsg.item_idx = 0; -- 格子索引



RespItemDelMsg.meta = {__index = RespItemDelMsg};
function RespItemDelMsg:new()
	local obj = setmetatable( {}, RespItemDelMsg.meta);
	return obj;
end

function RespItemDelMsg:ParseData(pak)
	local idx = 1;

	self.item_bag, idx = readInt(pak, idx);
	self.item_idx, idx = readInt(pak, idx);

end



--[[
服务器通知客户端，更新物品
]]

_G.RespItemUpdateMsg = {};

RespItemUpdateMsg.msgId = 8016;
RespItemUpdateMsg.id = ""; -- 物品uid
RespItemUpdateMsg.tid = 0; -- 物品id
RespItemUpdateMsg.count = 0; -- 物品数量
RespItemUpdateMsg.bag = 0; -- 属于哪个背包
RespItemUpdateMsg.pos = 0; -- 格子号
RespItemUpdateMsg.useCnt = 0; -- 当前使用次数
RespItemUpdateMsg.todayUse = 0; -- 当天使用次数
RespItemUpdateMsg.flags = 0; -- 标志位,第1位:绑定, 第2位:交易绑定



RespItemUpdateMsg.meta = {__index = RespItemUpdateMsg};
function RespItemUpdateMsg:new()
	local obj = setmetatable( {}, RespItemUpdateMsg.meta);
	return obj;
end

function RespItemUpdateMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.tid, idx = readInt(pak, idx);
	self.count, idx = readInt(pak, idx);
	self.bag, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);
	self.useCnt, idx = readInt(pak, idx);
	self.todayUse, idx = readInt(pak, idx);
	self.flags, idx = readInt64(pak, idx);

end



--[[
服务端通知: 下发物品列表
]]

_G.RespQueryItemResultMsg = {};

RespQueryItemResultMsg.msgId = 8019;
RespQueryItemResultMsg.id = ""; -- 
RespQueryItemResultMsg.item_bag = 0; -- 背包
RespQueryItemResultMsg.bag_size = 0; -- 背包总大小;已开格子数
RespQueryItemResultMsg.openLastTime = 0; -- 自动开启下一格子剩余时间,秒
RespQueryItemResultMsg.items_size = 0; -- 物品列表 size
RespQueryItemResultMsg.items = {}; -- 物品列表 list



--[[
SItemInfoVO = {
	id = ""; -- 物品uid
	tid = 0; -- 物品id
	count = 0; -- 物品数量
	bag = 0; -- 属于哪个背包
	pos = 0; -- 格子号
	useCnt = 0; -- 当前使用次数
	todayUse = 0; -- 当天使用次数
	flags = 0; -- 标志位,第1位:绑定, 第2位:交易绑定
}
]]

RespQueryItemResultMsg.meta = {__index = RespQueryItemResultMsg};
function RespQueryItemResultMsg:new()
	local obj = setmetatable( {}, RespQueryItemResultMsg.meta);
	return obj;
end

function RespQueryItemResultMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.item_bag, idx = readInt(pak, idx);
	self.bag_size, idx = readInt(pak, idx);
	self.openLastTime, idx = readInt(pak, idx);

	local list1 = {};
	self.items = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local SItemInfoVo = {};
		SItemInfoVo.id, idx = readGuid(pak, idx);
		SItemInfoVo.tid, idx = readInt(pak, idx);
		SItemInfoVo.count, idx = readInt(pak, idx);
		SItemInfoVo.bag, idx = readInt(pak, idx);
		SItemInfoVo.pos, idx = readInt(pak, idx);
		SItemInfoVo.useCnt, idx = readInt(pak, idx);
		SItemInfoVo.todayUse, idx = readInt(pak, idx);
		SItemInfoVo.flags, idx = readInt64(pak, idx);
		table.push(list1,SItemInfoVo);
	end

end



--[[
服务器通知: 丢弃物品反馈
]]

_G.RespDiscardItemResultMsg = {};

RespDiscardItemResultMsg.msgId = 8020;
RespDiscardItemResultMsg.result = 0; -- 结果 0:成功
RespDiscardItemResultMsg.item_bag = 0; -- 背包
RespDiscardItemResultMsg.item_idx = 0; -- 格子索引



RespDiscardItemResultMsg.meta = {__index = RespDiscardItemResultMsg};
function RespDiscardItemResultMsg:new()
	local obj = setmetatable( {}, RespDiscardItemResultMsg.meta);
	return obj;
end

function RespDiscardItemResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.item_bag, idx = readInt(pak, idx);
	self.item_idx, idx = readInt(pak, idx);

end



--[[
服务端通知: 交换物品反馈
]]

_G.RespSwapItemResultMsg = {};

RespSwapItemResultMsg.msgId = 8021;
RespSwapItemResultMsg.result = 0; -- 结果  0:成功
RespSwapItemResultMsg.src_bag = 0; -- 源背包
RespSwapItemResultMsg.dst_bag = 0; -- 目标背包
RespSwapItemResultMsg.src_idx = 0; -- 源格子
RespSwapItemResultMsg.dst_idx = 0; -- 目标格子



RespSwapItemResultMsg.meta = {__index = RespSwapItemResultMsg};
function RespSwapItemResultMsg:new()
	local obj = setmetatable( {}, RespSwapItemResultMsg.meta);
	return obj;
end

function RespSwapItemResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.src_bag, idx = readInt(pak, idx);
	self.dst_bag, idx = readInt(pak, idx);
	self.src_idx, idx = readInt(pak, idx);
	self.dst_idx, idx = readInt(pak, idx);

end



--[[
服务端通知: 使用物品反馈
]]

_G.RespUseItemResultMsg = {};

RespUseItemResultMsg.msgId = 8022;
RespUseItemResultMsg.result = 0; -- 结果  0:成功
RespUseItemResultMsg.item_bag = 0; -- 背包
RespUseItemResultMsg.item_idx = 0; -- 格子索引
RespUseItemResultMsg.item_count = 0; -- 使用数量
RespUseItemResultMsg.item_tid = 0; -- 物品tid



RespUseItemResultMsg.meta = {__index = RespUseItemResultMsg};
function RespUseItemResultMsg:new()
	local obj = setmetatable( {}, RespUseItemResultMsg.meta);
	return obj;
end

function RespUseItemResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.item_bag, idx = readInt(pak, idx);
	self.item_idx, idx = readInt(pak, idx);
	self.item_count, idx = readInt(pak, idx);
	self.item_tid, idx = readInt(pak, idx);

end



--[[
服务端通知: 出售物品反馈
]]

_G.RespSellItemResultMsg = {};

RespSellItemResultMsg.msgId = 8023;
RespSellItemResultMsg.result = 0; -- 结果  0:成功
RespSellItemResultMsg.id = ""; -- 物品uid
RespSellItemResultMsg.tid = 0; -- 物品id
RespSellItemResultMsg.count = 0; -- 物品数量
RespSellItemResultMsg.flags = 0; -- 标志位,第1位:绑定, 第2位:交易绑定



RespSellItemResultMsg.meta = {__index = RespSellItemResultMsg};
function RespSellItemResultMsg:new()
	local obj = setmetatable( {}, RespSellItemResultMsg.meta);
	return obj;
end

function RespSellItemResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readGuid(pak, idx);
	self.tid, idx = readInt(pak, idx);
	self.count, idx = readInt(pak, idx);
	self.flags, idx = readInt64(pak, idx);

end



--[[
服务端通知: 整理背包反馈
]]

_G.RespPackItemResultMsg = {};

RespPackItemResultMsg.msgId = 8024;
RespPackItemResultMsg.result = 0; -- 结果  0:成功
RespPackItemResultMsg.item_bag = 0; -- 背包



RespPackItemResultMsg.meta = {__index = RespPackItemResultMsg};
function RespPackItemResultMsg:new()
	local obj = setmetatable( {}, RespPackItemResultMsg.meta);
	return obj;
end

function RespPackItemResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.item_bag, idx = readInt(pak, idx);

end



--[[
服务端通知: 背包扩充反馈
]]

_G.RespExpandBagResultMsg = {};

RespExpandBagResultMsg.msgId = 8025;
RespExpandBagResultMsg.result = 0; -- 结果 0:成功
RespExpandBagResultMsg.item_bag = 0; -- 背包
RespExpandBagResultMsg.new_size = 0; -- 新格子数



RespExpandBagResultMsg.meta = {__index = RespExpandBagResultMsg};
function RespExpandBagResultMsg:new()
	local obj = setmetatable( {}, RespExpandBagResultMsg.meta);
	return obj;
end

function RespExpandBagResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.item_bag, idx = readInt(pak, idx);
	self.new_size, idx = readInt(pak, idx);

end



--[[
服务端通知: 拆分物品反馈
]]

_G.RespSplitItemResultMsg = {};

RespSplitItemResultMsg.msgId = 8026;
RespSplitItemResultMsg.result = 0; -- 结果  0:成功 -1:不可拆分...



RespSplitItemResultMsg.meta = {__index = RespSplitItemResultMsg};
function RespSplitItemResultMsg:new()
	local obj = setmetatable( {}, RespSplitItemResultMsg.meta);
	return obj;
end

function RespSplitItemResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务端通知：场景中玩家形象改变
]]

_G.RespScenePlayerShowChangeMsg = {};

RespScenePlayerShowChangeMsg.msgId = 8027;
RespScenePlayerShowChangeMsg.roleID = ""; -- 主角id
RespScenePlayerShowChangeMsg.type = 0; -- 类型:1Face,2Hair,3Dress,4Arms,5武魂,6坐骑,7打坐,14神兵,27V计划,35肩膀
RespScenePlayerShowChangeMsg.newVal = 0; -- 值



RespScenePlayerShowChangeMsg.meta = {__index = RespScenePlayerShowChangeMsg};
function RespScenePlayerShowChangeMsg:new()
	local obj = setmetatable( {}, RespScenePlayerShowChangeMsg.meta);
	return obj;
end

function RespScenePlayerShowChangeMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.type, idx = readInt(pak, idx);
	self.newVal, idx = readInt(pak, idx);

end



--[[
服务端通知:返回技能列表
]]

_G.RespSkillListResultMsg = {};

RespSkillListResultMsg.msgId = 8028;
RespSkillListResultMsg.skills_size = 0; -- 技能列表 size
RespSkillListResultMsg.skills = {}; -- 技能列表 list



--[[
SkillInfoVO = {
	skillId = 0; -- 技能id
}
]]

RespSkillListResultMsg.meta = {__index = RespSkillListResultMsg};
function RespSkillListResultMsg:new()
	local obj = setmetatable( {}, RespSkillListResultMsg.meta);
	return obj;
end

function RespSkillListResultMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.skills = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local SkillInfoVo = {};
		SkillInfoVo.skillId, idx = readInt(pak, idx);
		table.push(list1,SkillInfoVo);
	end

end



--[[
服务端通知: 返回学习技能
]]

_G.RespSkillLearnResultMsg = {};

RespSkillLearnResultMsg.msgId = 8029;
RespSkillLearnResultMsg.result = 0; -- 反馈结果,0成功,1失败
RespSkillLearnResultMsg.skillId = 0; -- 技能id



RespSkillLearnResultMsg.meta = {__index = RespSkillLearnResultMsg};
function RespSkillLearnResultMsg:new()
	local obj = setmetatable( {}, RespSkillLearnResultMsg.meta);
	return obj;
end

function RespSkillLearnResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.skillId, idx = readInt(pak, idx);

end



--[[
服务端通知: 返回升级技能
]]

_G.RespSkillLvlUpResultMsg = {};

RespSkillLvlUpResultMsg.msgId = 8031;
RespSkillLvlUpResultMsg.result = 0; -- 反馈结果,0成功,1 2失败 4 升级技能物品不足 5 技能已存在 9 已经学到最大等级 10 等级不够 11 坐骑等阶限制 12 宝夹等阶限制 13 骑战等阶限制  14 神武等阶限制 15 玩家等级不够
RespSkillLvlUpResultMsg.oldSkillId = 0; -- 学习前技能id
RespSkillLvlUpResultMsg.skillId = 0; -- 新技能id



RespSkillLvlUpResultMsg.meta = {__index = RespSkillLvlUpResultMsg};
function RespSkillLvlUpResultMsg:new()
	local obj = setmetatable( {}, RespSkillLvlUpResultMsg.meta);
	return obj;
end

function RespSkillLvlUpResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.oldSkillId, idx = readInt(pak, idx);
	self.skillId, idx = readInt(pak, idx);

end



--[[
服务端通知: 增加一个技能(特殊技能，如武魂技能)
]]

_G.RespSkillAddMsg = {};

RespSkillAddMsg.msgId = 8033;
RespSkillAddMsg.skillId = 0; -- 技能id



RespSkillAddMsg.meta = {__index = RespSkillAddMsg};
function RespSkillAddMsg:new()
	local obj = setmetatable( {}, RespSkillAddMsg.meta);
	return obj;
end

function RespSkillAddMsg:ParseData(pak)
	local idx = 1;

	self.skillId, idx = readInt(pak, idx);

end



--[[
服务端通知: 删除一个技能(特殊技能，如武魂技能)
]]

_G.RespSkillRemoveMsg = {};

RespSkillRemoveMsg.msgId = 8034;
RespSkillRemoveMsg.skillId = 0; -- 技能id



RespSkillRemoveMsg.meta = {__index = RespSkillRemoveMsg};
function RespSkillRemoveMsg:new()
	local obj = setmetatable( {}, RespSkillRemoveMsg.meta);
	return obj;
end

function RespSkillRemoveMsg:ParseData(pak)
	local idx = 1;

	self.skillId, idx = readInt(pak, idx);

end



--[[
服务器主动推送给客户端的Obj列表
]]

_G.RespMapObjListMsg = {};

RespMapObjListMsg.msgId = 8035;
RespMapObjListMsg.objType = 0; -- 类型
RespMapObjListMsg.objInfo_size = 0; --  size
RespMapObjListMsg.objInfo = {}; --  list



--[[
ObjInfoVO = {
	cid = ""; -- char ID
	id = 0; -- 配置表ID
	x = 0; -- 坐标X
	y = 0; -- 坐标Y
	dir = 0; -- 朝向
}
]]

RespMapObjListMsg.meta = {__index = RespMapObjListMsg};
function RespMapObjListMsg:new()
	local obj = setmetatable( {}, RespMapObjListMsg.meta);
	return obj;
end

function RespMapObjListMsg:ParseData(pak)
	local idx = 1;

	self.objType, idx = readInt(pak, idx);

	local list1 = {};
	self.objInfo = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ObjInfoVo = {};
		ObjInfoVo.cid, idx = readGuid(pak, idx);
		ObjInfoVo.id, idx = readInt(pak, idx);
		ObjInfoVo.x, idx = readDouble(pak, idx);
		ObjInfoVo.y, idx = readDouble(pak, idx);
		ObjInfoVo.dir, idx = readDouble(pak, idx);
		table.push(list1,ObjInfoVo);
	end

end



--[[

]]

_G.RespCharChangeDirMsg = {};

RespCharChangeDirMsg.msgId = 8036;
RespCharChangeDirMsg.guid = ""; -- 
RespCharChangeDirMsg.objType = 0; -- 
RespCharChangeDirMsg.dir = 0; -- 



RespCharChangeDirMsg.meta = {__index = RespCharChangeDirMsg};
function RespCharChangeDirMsg:new()
	local obj = setmetatable( {}, RespCharChangeDirMsg.meta);
	return obj;
end

function RespCharChangeDirMsg:ParseData(pak)
	local idx = 1;

	self.guid, idx = readGuid(pak, idx);
	self.objType, idx = readByte(pak, idx);
	self.dir, idx = readDouble(pak, idx);

end



--[[
服务端通知: 普通施法开始（全屏广播）
]]

_G.RespCastBeganMsg = {};

RespCastBeganMsg.msgId = 8050;
RespCastBeganMsg.casterID = ""; -- 施法者ID
RespCastBeganMsg.skillID = 0; -- 技能ID
RespCastBeganMsg.targetID = ""; -- 如果锁定目标，目标ID
RespCastBeganMsg.posX = 0; -- 如果位置施法，位置坐标x
RespCastBeganMsg.posY = 0; -- 如果位置施法，位置坐标y



RespCastBeganMsg.meta = {__index = RespCastBeganMsg};
function RespCastBeganMsg:new()
	local obj = setmetatable( {}, RespCastBeganMsg.meta);
	return obj;
end

function RespCastBeganMsg:ParseData(pak)
	local idx = 1;

	self.casterID, idx = readGuid(pak, idx);
	self.skillID, idx = readInt(pak, idx);
	self.targetID, idx = readGuid(pak, idx);
	self.posX, idx = readInt(pak, idx);
	self.posY, idx = readInt(pak, idx);

end



--[[
服务端通知: 普通施法结束（全屏广播）
]]

_G.RespCastEndedMsg = {};

RespCastEndedMsg.msgId = 8051;
RespCastEndedMsg.casterID = ""; -- 施法者ID
RespCastEndedMsg.skillID = 0; -- 技能ID



RespCastEndedMsg.meta = {__index = RespCastEndedMsg};
function RespCastEndedMsg:new()
	local obj = setmetatable( {}, RespCastEndedMsg.meta);
	return obj;
end

function RespCastEndedMsg:ParseData(pak)
	local idx = 1;

	self.casterID, idx = readGuid(pak, idx);
	self.skillID, idx = readInt(pak, idx);

end



--[[
服务端通知: 施法蓄力开始（全屏广播）
]]

_G.RespCastPrepBeganMsg = {};

RespCastPrepBeganMsg.msgId = 8052;
RespCastPrepBeganMsg.casterID = ""; -- 施法者ID
RespCastPrepBeganMsg.skillID = 0; -- 技能ID
RespCastPrepBeganMsg.prepTime = 0; -- 蓄力持续时间（毫秒）
RespCastPrepBeganMsg.targetID = ""; -- 如果锁定目标，目标ID
RespCastPrepBeganMsg.posX = 0; -- 如果位置施法，位置坐标x
RespCastPrepBeganMsg.posY = 0; -- 如果位置施法，位置坐标y



RespCastPrepBeganMsg.meta = {__index = RespCastPrepBeganMsg};
function RespCastPrepBeganMsg:new()
	local obj = setmetatable( {}, RespCastPrepBeganMsg.meta);
	return obj;
end

function RespCastPrepBeganMsg:ParseData(pak)
	local idx = 1;

	self.casterID, idx = readGuid(pak, idx);
	self.skillID, idx = readInt(pak, idx);
	self.prepTime, idx = readInt(pak, idx);
	self.targetID, idx = readGuid(pak, idx);
	self.posX, idx = readDouble(pak, idx);
	self.posY, idx = readDouble(pak, idx);

end



--[[
服务端通知: 施法蓄力结束（全屏广播）
]]

_G.RespCastPrepEndedMsg = {};

RespCastPrepEndedMsg.msgId = 8053;
RespCastPrepEndedMsg.casterID = ""; -- 施法者ID
RespCastPrepEndedMsg.skillID = 0; -- 技能ID
RespCastPrepEndedMsg.isend = 0; -- 0:中断 1:蓄力满



RespCastPrepEndedMsg.meta = {__index = RespCastPrepEndedMsg};
function RespCastPrepEndedMsg:new()
	local obj = setmetatable( {}, RespCastPrepEndedMsg.meta);
	return obj;
end

function RespCastPrepEndedMsg:ParseData(pak)
	local idx = 1;

	self.casterID, idx = readGuid(pak, idx);
	self.skillID, idx = readInt(pak, idx);
	self.isend, idx = readByte(pak, idx);

end



--[[
服务端通知: 施法引导开始（全屏广播）
]]

_G.RespCastChanBeganMsg = {};

RespCastChanBeganMsg.msgId = 8054;
RespCastChanBeganMsg.casterID = ""; -- 施法者ID
RespCastChanBeganMsg.skillID = 0; -- 技能ID
RespCastChanBeganMsg.targetID = ""; -- 如果锁定目标，目标ID
RespCastChanBeganMsg.posX = 0; -- 如果位置施法，位置坐标x
RespCastChanBeganMsg.posY = 0; -- 如果位置施法，位置坐标y



RespCastChanBeganMsg.meta = {__index = RespCastChanBeganMsg};
function RespCastChanBeganMsg:new()
	local obj = setmetatable( {}, RespCastChanBeganMsg.meta);
	return obj;
end

function RespCastChanBeganMsg:ParseData(pak)
	local idx = 1;

	self.casterID, idx = readGuid(pak, idx);
	self.skillID, idx = readInt(pak, idx);
	self.targetID, idx = readGuid(pak, idx);
	self.posX, idx = readDouble(pak, idx);
	self.posY, idx = readDouble(pak, idx);

end



--[[
服务端通知: 施法引导结束（全屏广播）
]]

_G.RespCastChanEndedMsg = {};

RespCastChanEndedMsg.msgId = 8055;
RespCastChanEndedMsg.casterID = ""; -- 施法者ID
RespCastChanEndedMsg.skillID = 0; -- 技能ID



RespCastChanEndedMsg.meta = {__index = RespCastChanEndedMsg};
function RespCastChanEndedMsg:new()
	local obj = setmetatable( {}, RespCastChanEndedMsg.meta);
	return obj;
end

function RespCastChanEndedMsg:ParseData(pak)
	local idx = 1;

	self.casterID, idx = readGuid(pak, idx);
	self.skillID, idx = readInt(pak, idx);

end



--[[
服务端通知: 施法中断通知（全屏广播）
]]

_G.RespInterruptCastMsg = {};

RespInterruptCastMsg.msgId = 8056;
RespInterruptCastMsg.casterID = ""; -- 施法者ID
RespInterruptCastMsg.skillID = 0; -- 技能ID



RespInterruptCastMsg.meta = {__index = RespInterruptCastMsg};
function RespInterruptCastMsg:new()
	local obj = setmetatable( {}, RespInterruptCastMsg.meta);
	return obj;
end

function RespInterruptCastMsg:ParseData(pak)
	local idx = 1;

	self.casterID, idx = readGuid(pak, idx);
	self.skillID, idx = readInt(pak, idx);

end



--[[
服务端通知: 施法效果结算（全屏广播）
]]

_G.RespCastEffectMsg = {};

RespCastEffectMsg.msgId = 8057;
RespCastEffectMsg.casterID = ""; -- 施法者ID
RespCastEffectMsg.skillID = 0; -- 技能ID
RespCastEffectMsg.effectID = 0; -- 效果ID
RespCastEffectMsg.targetID = ""; -- 目标ID
RespCastEffectMsg.flags = 0; -- 目标标记
RespCastEffectMsg.damageType = 0; -- 类型
RespCastEffectMsg.damage = 0; -- 目标伤害



RespCastEffectMsg.meta = {__index = RespCastEffectMsg};
function RespCastEffectMsg:new()
	local obj = setmetatable( {}, RespCastEffectMsg.meta);
	return obj;
end

function RespCastEffectMsg:ParseData(pak)
	local idx = 1;

	self.casterID, idx = readGuid(pak, idx);
	self.skillID, idx = readInt(pak, idx);
	self.effectID, idx = readInt(pak, idx);
	self.targetID, idx = readGuid(pak, idx);
	self.flags, idx = readInt(pak, idx);
	self.damageType, idx = readInt(pak, idx);
	self.damage, idx = readDouble(pak, idx);

end



--[[
服务端通知: 法术冷却信息
]]

_G.RespMagicCooldownMsg = {};

RespMagicCooldownMsg.msgId = 8058;
RespMagicCooldownMsg.casterID = ""; -- 施法者ID
RespMagicCooldownMsg.skillID = 0; -- 技能ID
RespMagicCooldownMsg.cdTime = 0; -- 冷却时间
RespMagicCooldownMsg.cdGroup = 0; -- 技能CD组
RespMagicCooldownMsg.cdGroupTime = 0; -- 技能CD组时间



RespMagicCooldownMsg.meta = {__index = RespMagicCooldownMsg};
function RespMagicCooldownMsg:new()
	local obj = setmetatable( {}, RespMagicCooldownMsg.meta);
	return obj;
end

function RespMagicCooldownMsg:ParseData(pak)
	local idx = 1;

	self.casterID, idx = readGuid(pak, idx);
	self.skillID, idx = readInt(pak, idx);
	self.cdTime, idx = readInt(pak, idx);
	self.cdGroup, idx = readInt(pak, idx);
	self.cdGroupTime, idx = readInt(pak, idx);

end



--[[
服务端通知:任务列表反馈
]]

_G.RespQueryQuestResultMsg = {};

RespQueryQuestResultMsg.msgId = 8059;
RespQueryQuestResultMsg.quests_size = 0; --  size
RespQueryQuestResultMsg.quests = {}; --  list



--[[
SQuestVO = {
	id = 0; -- 任务id
	state = 0; -- 任务状态,0未接,1进行中,2可交
	flag = 0; -- 日环任务时,高16位环数,中8位星级,低8位倍率
	goals_size = 3; -- 任务目标 size
	goals = {}; -- 任务目标 list
}
SQuestGoalVO = {
	current_goalsId = 0; -- 目标id
	current_count = 0; -- 当前任务计数
}
]]

RespQueryQuestResultMsg.meta = {__index = RespQueryQuestResultMsg};
function RespQueryQuestResultMsg:new()
	local obj = setmetatable( {}, RespQueryQuestResultMsg.meta);
	return obj;
end

function RespQueryQuestResultMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.quests = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local SQuestVo = {};
		SQuestVo.id, idx = readInt(pak, idx);
		SQuestVo.state, idx = readInt(pak, idx);
		SQuestVo.flag, idx = readInt(pak, idx);
		table.push(list1,SQuestVo);

		local list2 = {};
		SQuestVo.goals = list2;
		local list2Size = 3;

		for i=1,list2Size do
			local SQuestGoalVo = {};
			SQuestGoalVo.current_goalsId, idx = readInt(pak, idx);
			SQuestGoalVo.current_count, idx = readInt(pak, idx);
			table.push(list2,SQuestGoalVo);
		end
	end

end



--[[
服务端通知:增加一个任务
]]

_G.RespQuestAddMsg = {};

RespQuestAddMsg.msgId = 8060;
RespQuestAddMsg.id = 0; -- 任务id
RespQuestAddMsg.state = 0; -- 任务状态,0未接,1进行中,2可交
RespQuestAddMsg.flag = 0; -- 日环任务时,高16位环数,中8位星级,低8位倍率
RespQuestAddMsg.goals_size = 0; -- 任务目标 size
RespQuestAddMsg.goals = {}; -- 任务目标 list



--[[
SQuestGoalVO = {
	current_goalsId = 0; -- 目标id
	current_count = 0; -- 当前任务计数
}
]]

RespQuestAddMsg.meta = {__index = RespQuestAddMsg};
function RespQuestAddMsg:new()
	local obj = setmetatable( {}, RespQuestAddMsg.meta);
	return obj;
end

function RespQuestAddMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);
	self.flag, idx = readInt(pak, idx);

	local list1 = {};
	self.goals = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local SQuestGoalVo = {};
		SQuestGoalVo.current_goalsId, idx = readInt(pak, idx);
		SQuestGoalVo.current_count, idx = readInt(pak, idx);
		table.push(list1,SQuestGoalVo);
	end

end



--[[
服务端通知:任务更新
]]

_G.RespQuestUpdateMsg = {};

RespQuestUpdateMsg.msgId = 8061;
RespQuestUpdateMsg.id = 0; -- 任务id
RespQuestUpdateMsg.state = 0; -- 任务状态,0未接,1进行中,2可交
RespQuestUpdateMsg.flag = 0; -- 日环任务时,高16位环数,中8位星级,低8位倍率
RespQuestUpdateMsg.goals_size = 0; -- 任务目标 size
RespQuestUpdateMsg.goals = {}; -- 任务目标 list



--[[
SQuestGoalVO = {
	current_goalsId = 0; -- 目标id
	current_count = 0; -- 当前任务计数
}
]]

RespQuestUpdateMsg.meta = {__index = RespQuestUpdateMsg};
function RespQuestUpdateMsg:new()
	local obj = setmetatable( {}, RespQuestUpdateMsg.meta);
	return obj;
end

function RespQuestUpdateMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);
	self.flag, idx = readInt(pak, idx);

	local list1 = {};
	self.goals = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local SQuestGoalVo = {};
		SQuestGoalVo.current_goalsId, idx = readInt(pak, idx);
		SQuestGoalVo.current_count, idx = readInt(pak, idx);
		table.push(list1,SQuestGoalVo);
	end

end



--[[
服务端通知:接受任务反馈
]]

_G.RespAcceptQuestResultMsg = {};

RespAcceptQuestResultMsg.msgId = 8062;
RespAcceptQuestResultMsg.result = 0; -- 0:成功



RespAcceptQuestResultMsg.meta = {__index = RespAcceptQuestResultMsg};
function RespAcceptQuestResultMsg:new()
	local obj = setmetatable( {}, RespAcceptQuestResultMsg.meta);
	return obj;
end

function RespAcceptQuestResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务端通知:放弃任务反馈
]]

_G.RespGiveupQuestResultMsg = {};

RespGiveupQuestResultMsg.msgId = 8063;
RespGiveupQuestResultMsg.result = 0; -- 0:成功
RespGiveupQuestResultMsg.id = 0; -- 任务id



RespGiveupQuestResultMsg.meta = {__index = RespGiveupQuestResultMsg};
function RespGiveupQuestResultMsg:new()
	local obj = setmetatable( {}, RespGiveupQuestResultMsg.meta);
	return obj;
end

function RespGiveupQuestResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
服务端通知:完成任务反馈
]]

_G.RespFinishQuestResultMsg = {};

RespFinishQuestResultMsg.msgId = 8064;
RespFinishQuestResultMsg.result = 0; -- 0：为成功
RespFinishQuestResultMsg.id = 0; -- 任务id



RespFinishQuestResultMsg.meta = {__index = RespFinishQuestResultMsg};
function RespFinishQuestResultMsg:new()
	local obj = setmetatable( {}, RespFinishQuestResultMsg.meta);
	return obj;
end

function RespFinishQuestResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
服务端通知:任务删除
]]

_G.RespQuestDelMsg = {};

RespQuestDelMsg.msgId = 8065;
RespQuestDelMsg.id = 0; -- 任务id



RespQuestDelMsg.meta = {__index = RespQuestDelMsg};
function RespQuestDelMsg:new()
	local obj = setmetatable( {}, RespQuestDelMsg.meta);
	return obj;
end

function RespQuestDelMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
服务端通知:触发静物反馈
]]

_G.RespTriggerObjectResultMsg = {};

RespTriggerObjectResultMsg.msgId = 8070;
RespTriggerObjectResultMsg.result = 0; -- 范围结果, 0成功, -1失败 -2等级不足 -3境界不足
RespTriggerObjectResultMsg.cID = ""; -- 静物ID
RespTriggerObjectResultMsg.jiguan = 0; -- 机关ID
RespTriggerObjectResultMsg.jiguan_open = 0; -- 打开或者关闭，1打开，0关闭



RespTriggerObjectResultMsg.meta = {__index = RespTriggerObjectResultMsg};
function RespTriggerObjectResultMsg:new()
	local obj = setmetatable( {}, RespTriggerObjectResultMsg.meta);
	return obj;
end

function RespTriggerObjectResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.cID, idx = readGuid(pak, idx);
	self.jiguan, idx = readInt(pak, idx);
	self.jiguan_open, idx = readInt(pak, idx);

end



--[[
服务端通知: 通知客户端打开传送门
]]

_G.RespOpenPortalMsg = {};

RespOpenPortalMsg.msgId = 8071;
RespOpenPortalMsg.portalID = 0; -- 传送门配置表ID



RespOpenPortalMsg.meta = {__index = RespOpenPortalMsg};
function RespOpenPortalMsg:new()
	local obj = setmetatable( {}, RespOpenPortalMsg.meta);
	return obj;
end

function RespOpenPortalMsg:ParseData(pak)
	local idx = 1;

	self.portalID, idx = readInt(pak, idx);

end



--[[
技能栏
]]

_G.RespSkillContainerMsg = {};

RespSkillContainerMsg.msgId = 8074;
RespSkillContainerMsg.data_size = 0; --  size
RespSkillContainerMsg.data = {}; --  list



--[[
Container_infoVO = {
	pos = 0; -- 
	id = 0; -- 
}
]]

RespSkillContainerMsg.meta = {__index = RespSkillContainerMsg};
function RespSkillContainerMsg:new()
	local obj = setmetatable( {}, RespSkillContainerMsg.meta);
	return obj;
end

function RespSkillContainerMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.data = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local Container_infoVo = {};
		Container_infoVo.pos, idx = readInt(pak, idx);
		Container_infoVo.id, idx = readInt(pak, idx);
		table.push(list1,Container_infoVo);
	end

end



--[[
死亡信息
]]

_G.RespObjDeadInfoMsg = {};

RespObjDeadInfoMsg.msgId = 8075;
RespObjDeadInfoMsg.deadid = ""; -- 
RespObjDeadInfoMsg.killerName = ""; -- 击杀者名字
RespObjDeadInfoMsg.killerLevel = 0; -- 击杀者等级
RespObjDeadInfoMsg.killerType = 0; -- 0,玩家 1，怪物
RespObjDeadInfoMsg.objType = 0; -- 
RespObjDeadInfoMsg.killerID = ""; -- 
RespObjDeadInfoMsg.skillID = 0; -- 



RespObjDeadInfoMsg.meta = {__index = RespObjDeadInfoMsg};
function RespObjDeadInfoMsg:new()
	local obj = setmetatable( {}, RespObjDeadInfoMsg.meta);
	return obj;
end

function RespObjDeadInfoMsg:ParseData(pak)
	local idx = 1;

	self.deadid, idx = readGuid(pak, idx);
	self.killerName, idx = readString(pak, idx, 32);
	self.killerLevel, idx = readInt(pak, idx);
	self.killerType, idx = readInt(pak, idx);
	self.objType, idx = readByte(pak, idx);
	self.killerID, idx = readGuid(pak, idx);
	self.skillID, idx = readInt(pak, idx);

end



--[[
拾取结果
]]

_G.RespPickUpItemMsg = {};

RespPickUpItemMsg.msgId = 8076;
RespPickUpItemMsg.data_size = 0; --  size
RespPickUpItemMsg.data = {}; --  list



--[[
item_idVO = {
	result = 0; -- 结果 0:成功 -1:物品不存在 -2:不属于该玩家 -3:背包已满
	id = ""; -- 
}
]]

RespPickUpItemMsg.meta = {__index = RespPickUpItemMsg};
function RespPickUpItemMsg:new()
	local obj = setmetatable( {}, RespPickUpItemMsg.meta);
	return obj;
end

function RespPickUpItemMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.data = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local item_idVo = {};
		item_idVo.result, idx = readInt(pak, idx);
		item_idVo.id, idx = readGuid(pak, idx);
		table.push(list1,item_idVo);
	end

end



--[[
复活信息
]]

_G.RespReviveMsg = {};

RespReviveMsg.msgId = 8077;
RespReviveMsg.result = 0; -- 复活结果, 0:成功 -1:5s限制时间 -2:其他错误,人没死等 -3:道具不足 -4:元宝不足 -5:红名不可原地复活
RespReviveMsg.roleID = ""; -- 角色id
RespReviveMsg.reviveType = 0; -- 复活类型
RespReviveMsg.posX = 0; -- 复活位置坐标x
RespReviveMsg.posY = 0; -- 复活位置坐标y



RespReviveMsg.meta = {__index = RespReviveMsg};
function RespReviveMsg:new()
	local obj = setmetatable( {}, RespReviveMsg.meta);
	return obj;
end

function RespReviveMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.roleID, idx = readGuid(pak, idx);
	self.reviveType, idx = readInt(pak, idx);
	self.posX, idx = readDouble(pak, idx);
	self.posY, idx = readDouble(pak, idx);

end



--[[
服务端通知: 开礼包结果
]]

_G.RespOpenGiftResultMsg = {};

RespOpenGiftResultMsg.msgId = 8079;
RespOpenGiftResultMsg.id = 0; -- 礼包id
RespOpenGiftResultMsg.items_size = 0; -- 物品列表 size
RespOpenGiftResultMsg.items = {}; -- 物品列表 list



--[[
GiftItemVOVO = {
	itemId = 0; -- 物品id
	itemCount = 0; -- 物品数量
	bind = 0; -- 绑定,0绑定
}
]]

RespOpenGiftResultMsg.meta = {__index = RespOpenGiftResultMsg};
function RespOpenGiftResultMsg:new()
	local obj = setmetatable( {}, RespOpenGiftResultMsg.meta);
	return obj;
end

function RespOpenGiftResultMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

	local list1 = {};
	self.items = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local GiftItemVOVo = {};
		GiftItemVOVo.itemId, idx = readInt(pak, idx);
		GiftItemVOVo.itemCount, idx = readInt(pak, idx);
		GiftItemVOVo.bind, idx = readInt(pak, idx);
		table.push(list1,GiftItemVOVo);
	end

end



--[[
服务端通知:击退
]]

_G.RespKnockBackMsg = {};

RespKnockBackMsg.msgId = 8081;
RespKnockBackMsg.caster = ""; -- 施放者
RespKnockBackMsg.target = ""; -- 目标者
RespKnockBackMsg.speed = 0; -- 移动速度
RespKnockBackMsg.time = 0; -- 移动时间
RespKnockBackMsg.posX = 0; -- 最终位置
RespKnockBackMsg.posY = 0; -- 最终位置



RespKnockBackMsg.meta = {__index = RespKnockBackMsg};
function RespKnockBackMsg:new()
	local obj = setmetatable( {}, RespKnockBackMsg.meta);
	return obj;
end

function RespKnockBackMsg:ParseData(pak)
	local idx = 1;

	self.caster, idx = readGuid(pak, idx);
	self.target, idx = readGuid(pak, idx);
	self.speed, idx = readInt(pak, idx);
	self.time, idx = readInt(pak, idx);
	self.posX, idx = readDouble(pak, idx);
	self.posY, idx = readDouble(pak, idx);

end



--[[
服务端通知:增加BUFF
]]

_G.RespAddBuffMsg = {};

RespAddBuffMsg.msgId = 8082;
RespAddBuffMsg.caster = ""; -- 施放者
RespAddBuffMsg.target = ""; -- 目标者
RespAddBuffMsg.id = ""; -- BUFF实例ID
RespAddBuffMsg.buffid = 0; -- BUFF配置ID
RespAddBuffMsg.time = 0; -- BUFF持续时间



RespAddBuffMsg.meta = {__index = RespAddBuffMsg};
function RespAddBuffMsg:new()
	local obj = setmetatable( {}, RespAddBuffMsg.meta);
	return obj;
end

function RespAddBuffMsg:ParseData(pak)
	local idx = 1;

	self.caster, idx = readGuid(pak, idx);
	self.target, idx = readGuid(pak, idx);
	self.id, idx = readGuid(pak, idx);
	self.buffid, idx = readInt(pak, idx);
	self.time, idx = readInt(pak, idx);

end



--[[
服务端通知:更新BUFF
]]

_G.RespUpdateBuffMsg = {};

RespUpdateBuffMsg.msgId = 8083;
RespUpdateBuffMsg.id = ""; -- BUFF实例ID
RespUpdateBuffMsg.time = 0; -- BUFF持续时间
RespUpdateBuffMsg.count = 0; -- 叠加层数
RespUpdateBuffMsg.param_size = 3; -- buff参数,1时间,2间隔,3增益减益效果 size
RespUpdateBuffMsg.param = {}; -- buff参数,1时间,2间隔,3增益减益效果 list



--[[
BuffParamVO = {
	value = 0; -- 
}
]]

RespUpdateBuffMsg.meta = {__index = RespUpdateBuffMsg};
function RespUpdateBuffMsg:new()
	local obj = setmetatable( {}, RespUpdateBuffMsg.meta);
	return obj;
end

function RespUpdateBuffMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.time, idx = readInt(pak, idx);
	self.count, idx = readInt(pak, idx);

	local list1 = {};
	self.param = list1;
	local list1Size = 3;

	for i=1,list1Size do
		local BuffParamVo = {};
		BuffParamVo.value, idx = readInt(pak, idx);
		table.push(list1,BuffParamVo);
	end

end



--[[
服务端通知:删除BUFF
]]

_G.RespDelBuffMsg = {};

RespDelBuffMsg.msgId = 8084;
RespDelBuffMsg.id = ""; -- BUFF实例ID
RespDelBuffMsg.caster = ""; -- 施放者
RespDelBuffMsg.target = ""; -- 目标者
RespDelBuffMsg.buffid = 0; -- BUFF配置ID



RespDelBuffMsg.meta = {__index = RespDelBuffMsg};
function RespDelBuffMsg:new()
	local obj = setmetatable( {}, RespDelBuffMsg.meta);
	return obj;
end

function RespDelBuffMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.caster, idx = readGuid(pak, idx);
	self.target, idx = readGuid(pak, idx);
	self.buffid, idx = readInt(pak, idx);

end



--[[
服务端通知:状态位改变
]]

_G.RespStateBitChangedMsg = {};

RespStateBitChangedMsg.msgId = 8085;
RespStateBitChangedMsg.roleID = ""; -- 
RespStateBitChangedMsg.idx = 0; -- 状态位
RespStateBitChangedMsg.set = 0; -- true/false



RespStateBitChangedMsg.meta = {__index = RespStateBitChangedMsg};
function RespStateBitChangedMsg:new()
	local obj = setmetatable( {}, RespStateBitChangedMsg.meta);
	return obj;
end

function RespStateBitChangedMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.idx, idx = readByte(pak, idx);
	self.set, idx = readByte(pak, idx);

end



--[[
服务端通知: 连击持续时间开始（全屏广播）
]]

_G.RespCastContBeganMsg = {};

RespCastContBeganMsg.msgId = 8086;
RespCastContBeganMsg.casterID = ""; -- 施法者ID
RespCastContBeganMsg.skillID = 0; -- 技能ID
RespCastContBeganMsg.contTime = 0; -- 连击持续时间（毫秒）
RespCastContBeganMsg.targetID = ""; -- 如果锁定目标，目标ID



RespCastContBeganMsg.meta = {__index = RespCastContBeganMsg};
function RespCastContBeganMsg:new()
	local obj = setmetatable( {}, RespCastContBeganMsg.meta);
	return obj;
end

function RespCastContBeganMsg:ParseData(pak)
	local idx = 1;

	self.casterID, idx = readGuid(pak, idx);
	self.skillID, idx = readInt(pak, idx);
	self.contTime, idx = readInt(pak, idx);
	self.targetID, idx = readGuid(pak, idx);

end



--[[
服务端通知: 连击持续时间结束（全屏广播）
]]

_G.RespCastContEndedMsg = {};

RespCastContEndedMsg.msgId = 8087;
RespCastContEndedMsg.casterID = ""; -- 施法者ID
RespCastContEndedMsg.skillID = 0; -- 技能ID



RespCastContEndedMsg.meta = {__index = RespCastContEndedMsg};
function RespCastContEndedMsg:new()
	local obj = setmetatable( {}, RespCastContEndedMsg.meta);
	return obj;
end

function RespCastContEndedMsg:ParseData(pak)
	local idx = 1;

	self.casterID, idx = readGuid(pak, idx);
	self.skillID, idx = readInt(pak, idx);

end



--[[
服务端通知: 收到升级结果
]]

_G.RespLevelUpResultMsg = {};

RespLevelUpResultMsg.msgId = 8088;
RespLevelUpResultMsg.result = 0; -- 0成功, -1:等级不足20 -2:经验不足



RespLevelUpResultMsg.meta = {__index = RespLevelUpResultMsg};
function RespLevelUpResultMsg:new()
	local obj = setmetatable( {}, RespLevelUpResultMsg.meta);
	return obj;
end

function RespLevelUpResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务端通知:位移技能效果
]]

_G.RespCastMotionEffectMsg = {};

RespCastMotionEffectMsg.msgId = 8089;
RespCastMotionEffectMsg.casterID = ""; -- 施放者
RespCastMotionEffectMsg.targetID = ""; -- 目标者
RespCastMotionEffectMsg.skillID = 0; -- 技能配置ID
RespCastMotionEffectMsg.skillEffectID = 0; -- 技能效果配置ID
RespCastMotionEffectMsg.time = 0; -- 移动时间
RespCastMotionEffectMsg.posX = 0; -- 最终位置
RespCastMotionEffectMsg.posY = 0; -- 最终位置



RespCastMotionEffectMsg.meta = {__index = RespCastMotionEffectMsg};
function RespCastMotionEffectMsg:new()
	local obj = setmetatable( {}, RespCastMotionEffectMsg.meta);
	return obj;
end

function RespCastMotionEffectMsg:ParseData(pak)
	local idx = 1;

	self.casterID, idx = readGuid(pak, idx);
	self.targetID, idx = readGuid(pak, idx);
	self.skillID, idx = readInt(pak, idx);
	self.skillEffectID, idx = readInt(pak, idx);
	self.time, idx = readInt(pak, idx);
	self.posX, idx = readDouble(pak, idx);
	self.posY, idx = readDouble(pak, idx);

end



--[[
服务器通知：返回武魂祝福值
]]

_G.RespFeedWuHunResultMsg = {};

RespFeedWuHunResultMsg.msgId = 8092;
RespFeedWuHunResultMsg.wuhunId = 0; -- 武魂id
RespFeedWuHunResultMsg.hunzhu = 0; -- 武魂当前魂珠
RespFeedWuHunResultMsg.feedNum = 0; -- 喂养次数
RespFeedWuHunResultMsg.feedProgress = 0; -- 喂养进度



RespFeedWuHunResultMsg.meta = {__index = RespFeedWuHunResultMsg};
function RespFeedWuHunResultMsg:new()
	local obj = setmetatable( {}, RespFeedWuHunResultMsg.meta);
	return obj;
end

function RespFeedWuHunResultMsg:ParseData(pak)
	local idx = 1;

	self.wuhunId, idx = readInt(pak, idx);
	self.hunzhu, idx = readInt(pak, idx);
	self.feedNum, idx = readInt(pak, idx);
	self.feedProgress, idx = readInt(pak, idx);

end



--[[
服务器通知：返回武魂进阶结果
]]

_G.RespProceWuHunResultMsg = {};

RespProceWuHunResultMsg.msgId = 8093;
RespProceWuHunResultMsg.wuhunId = 0; -- 武魂id
RespProceWuHunResultMsg.proceId = 0; -- 武魂进阶id
RespProceWuHunResultMsg.proceState = 0; -- 进阶状态
RespProceWuHunResultMsg.wuhunWish = 0; -- 祝福值
RespProceWuHunResultMsg.result = 0; -- 进阶结果



RespProceWuHunResultMsg.meta = {__index = RespProceWuHunResultMsg};
function RespProceWuHunResultMsg:new()
	local obj = setmetatable( {}, RespProceWuHunResultMsg.meta);
	return obj;
end

function RespProceWuHunResultMsg:ParseData(pak)
	local idx = 1;

	self.wuhunId, idx = readInt(pak, idx);
	self.proceId, idx = readInt(pak, idx);
	self.proceState, idx = readInt(pak, idx);
	self.wuhunWish, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
服务端通知: 返回武魂附身
]]

_G.RespAdjunctionWuHunResultMsg = {};

RespAdjunctionWuHunResultMsg.msgId = 8094;
RespAdjunctionWuHunResultMsg.result = 0; -- 反馈结果,2卸下武魂,1成功,0失败
RespAdjunctionWuHunResultMsg.wuhunId = 0; -- 武魂id



RespAdjunctionWuHunResultMsg.meta = {__index = RespAdjunctionWuHunResultMsg};
function RespAdjunctionWuHunResultMsg:new()
	local obj = setmetatable( {}, RespAdjunctionWuHunResultMsg.meta);
	return obj;
end

function RespAdjunctionWuHunResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.wuhunId, idx = readInt(pak, idx);

end



--[[
传送信息
]]

_G.RespChangePosMsg = {};

RespChangePosMsg.msgId = 8096;
RespChangePosMsg.roleId = ""; -- 玩家guid
RespChangePosMsg.posX = 0; -- 传送位置坐标x
RespChangePosMsg.posY = 0; -- 传送位置坐标y



RespChangePosMsg.meta = {__index = RespChangePosMsg};
function RespChangePosMsg:new()
	local obj = setmetatable( {}, RespChangePosMsg.meta);
	return obj;
end

function RespChangePosMsg:ParseData(pak)
	local idx = 1;

	self.roleId, idx = readGuid(pak, idx);
	self.posX, idx = readDouble(pak, idx);
	self.posY, idx = readDouble(pak, idx);

end



--[[
返回技能栏技能改变
]]

_G.RespSkillShortCutMsg = {};

RespSkillShortCutMsg.msgId = 8097;
RespSkillShortCutMsg.pos = 0; -- 格子
RespSkillShortCutMsg.skillId = 0; -- 技能id



RespSkillShortCutMsg.meta = {__index = RespSkillShortCutMsg};
function RespSkillShortCutMsg:new()
	local obj = setmetatable( {}, RespSkillShortCutMsg.meta);
	return obj;
end

function RespSkillShortCutMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readInt(pak, idx);
	self.skillId, idx = readInt(pak, idx);

end



--[[
服务端通知: 背包可扩充
]]

_G.RespExpandBagTipsMsg = {};

RespExpandBagTipsMsg.msgId = 8098;
RespExpandBagTipsMsg.item_bag = 0; -- 背包



RespExpandBagTipsMsg.meta = {__index = RespExpandBagTipsMsg};
function RespExpandBagTipsMsg:new()
	local obj = setmetatable( {}, RespExpandBagTipsMsg.meta);
	return obj;
end

function RespExpandBagTipsMsg:ParseData(pak)
	local idx = 1;

	self.item_bag, idx = readInt(pak, idx);

end



--[[
服务端通知: 释放技能返回结果
]]

_G.RespCastMagicResultMsg = {};

RespCastMagicResultMsg.msgId = 8099;
RespCastMagicResultMsg.skillId = 0; -- 技能id
RespCastMagicResultMsg.resultCode = 0; -- 释放技能返回结果 0:成功 -1:目标或坐标不对 -2:技能不存在 -3:CD -10:目标不存在 -11:消耗检查 -21 目标状态不对 -31/32/33:距离不对 -61施法者状态不对



RespCastMagicResultMsg.meta = {__index = RespCastMagicResultMsg};
function RespCastMagicResultMsg:new()
	local obj = setmetatable( {}, RespCastMagicResultMsg.meta);
	return obj;
end

function RespCastMagicResultMsg:ParseData(pak)
	local idx = 1;

	self.skillId, idx = readInt(pak, idx);
	self.resultCode, idx = readInt(pak, idx);

end



--[[
服务端通知: Monster刷新
]]

_G.RespMonsterSpawnMsg = {};

RespMonsterSpawnMsg.msgId = 8100;
RespMonsterSpawnMsg.cid = ""; -- 怪物ID
RespMonsterSpawnMsg.tid = 0; -- 怪物配置ID



RespMonsterSpawnMsg.meta = {__index = RespMonsterSpawnMsg};
function RespMonsterSpawnMsg:new()
	local obj = setmetatable( {}, RespMonsterSpawnMsg.meta);
	return obj;
end

function RespMonsterSpawnMsg:ParseData(pak)
	local idx = 1;

	self.cid, idx = readGuid(pak, idx);
	self.tid, idx = readInt(pak, idx);

end



--[[
服务端通知: 播放剧情返回结果
]]

_G.RespStoryStartResultMsg = {};

RespStoryStartResultMsg.msgId = 8101;
RespStoryStartResultMsg.storyId = ""; -- 剧情id
RespStoryStartResultMsg.type = 0; -- 1：对话框，2：任务，3: 场景里播的任务剧情，其它是剧情
RespStoryStartResultMsg.id = 0; -- 剧情stepid或者任务id



RespStoryStartResultMsg.meta = {__index = RespStoryStartResultMsg};
function RespStoryStartResultMsg:new()
	local obj = setmetatable( {}, RespStoryStartResultMsg.meta);
	return obj;
end

function RespStoryStartResultMsg:ParseData(pak)
	local idx = 1;

	self.storyId, idx = readString(pak, idx, 64);
	self.type, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
服务端通知: 进入副本返回结果
]]

_G.RespEnterDungeonResultMsg = {};

RespEnterDungeonResultMsg.msgId = 8102;
RespEnterDungeonResultMsg.result = 0; -- 返回结果 0:成功, -1:错误 -4:当前场景不对 -2:副本已关闭 -3:不在同一线
RespEnterDungeonResultMsg.dungeonId = 0; -- 副本id
RespEnterDungeonResultMsg.stepId = 0; -- 步骤id
RespEnterDungeonResultMsg.dungeonTime = 0; -- 副本进行时间 秒
RespEnterDungeonResultMsg.Id = 0; -- boss变异id
RespEnterDungeonResultMsg.star = 0; -- boss星级



RespEnterDungeonResultMsg.meta = {__index = RespEnterDungeonResultMsg};
function RespEnterDungeonResultMsg:new()
	local obj = setmetatable( {}, RespEnterDungeonResultMsg.meta);
	return obj;
end

function RespEnterDungeonResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.dungeonId, idx = readInt(pak, idx);
	self.stepId, idx = readInt(pak, idx);
	self.dungeonTime, idx = readInt64(pak, idx);
	self.Id, idx = readInt(pak, idx);
	self.star, idx = readInt(pak, idx);

end



--[[
服务端通知: 离开副本返回结果
]]

_G.RespLeaveDungeonResultMsg = {};

RespLeaveDungeonResultMsg.msgId = 8103;
RespLeaveDungeonResultMsg.result = 0; -- 返回结果 0:成功



RespLeaveDungeonResultMsg.meta = {__index = RespLeaveDungeonResultMsg};
function RespLeaveDungeonResultMsg:new()
	local obj = setmetatable( {}, RespLeaveDungeonResultMsg.meta);
	return obj;
end

function RespLeaveDungeonResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务端通知: 剧情完成返回结果
]]

_G.RespStoryEndResultMsg = {};

RespStoryEndResultMsg.msgId = 8104;
RespStoryEndResultMsg.result = 0; -- 返回结果 0:成功



RespStoryEndResultMsg.meta = {__index = RespStoryEndResultMsg};
function RespStoryEndResultMsg:new()
	local obj = setmetatable( {}, RespStoryEndResultMsg.meta);
	return obj;
end

function RespStoryEndResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务端通知: 副本剧情步骤
]]

_G.RespStoryStepMsg = {};

RespStoryStepMsg.msgId = 8105;
RespStoryStepMsg.stepId = 0; -- 步骤id
RespStoryStepMsg.dungeonId = 0; -- 副本id



RespStoryStepMsg.meta = {__index = RespStoryStepMsg};
function RespStoryStepMsg:new()
	local obj = setmetatable( {}, RespStoryStepMsg.meta);
	return obj;
end

function RespStoryStepMsg:ParseData(pak)
	local idx = 1;

	self.stepId, idx = readInt(pak, idx);
	self.dungeonId, idx = readInt(pak, idx);

end



--[[
请求交易返回结果
]]

_G.RespExchangeMsg = {};

RespExchangeMsg.msgId = 8106;
RespExchangeMsg.roleID = ""; -- 玩家id
RespExchangeMsg.roleName = ""; -- 角色名字
RespExchangeMsg.level = 0; -- 等级



RespExchangeMsg.meta = {__index = RespExchangeMsg};
function RespExchangeMsg:new()
	local obj = setmetatable( {}, RespExchangeMsg.meta);
	return obj;
end

function RespExchangeMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.roleName, idx = readString(pak, idx, 32);
	self.level, idx = readInt(pak, idx);

end



--[[
被邀请交易
]]

_G.RespExchangeInviteMsg = {};

RespExchangeInviteMsg.msgId = 8107;
RespExchangeInviteMsg.roleID = ""; -- 玩家id
RespExchangeInviteMsg.roleName = ""; -- 角色名字
RespExchangeInviteMsg.level = 0; -- 等级



RespExchangeInviteMsg.meta = {__index = RespExchangeInviteMsg};
function RespExchangeInviteMsg:new()
	local obj = setmetatable( {}, RespExchangeInviteMsg.meta);
	return obj;
end

function RespExchangeInviteMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.roleName, idx = readString(pak, idx, 32);
	self.level, idx = readInt(pak, idx);

end



--[[
交易物品列表
]]

_G.RespExchangeItemListMsg = {};

RespExchangeItemListMsg.msgId = 8108;
RespExchangeItemListMsg.roleID = ""; -- 玩家id
RespExchangeItemListMsg.gold = 0; -- 金币
RespExchangeItemListMsg.ItemList_size = 0; -- 物品列表 size
RespExchangeItemListMsg.ItemList = {}; -- 物品列表 list



--[[
ItemInfoVO = {
	tid = 0; -- 物品id
	count = 0; -- 物品数量
	pos = 0; -- 格子号
	strenLvl = 0; -- 强化等级(是翅膀时这个值代表到期时间)
	strenVal = 0; -- 强化值(是翅膀时这个值代表是否有特殊属性)
	emptystarnum = 0; -- 空星数
	attrAddLvl = 0; -- 追加属性等级
	groupId = 0; -- 套装id
	groupId2 = 0; -- 套装id2
	group2Level = 0; -- 套装2的等级
	superNum = 0; -- 卓越数量
	superList_size = 7; -- 卓越属性列表 size
	superList = {}; -- 卓越属性列表 list
	newSuperList_size = 3; -- 新卓越属性列表 size
	newSuperList = {}; -- 新卓越属性列表 list
}
SuperVOVO = {
	uid = ""; -- 属性uid
	id = 0; -- 卓越id
	val1 = 0; -- 值1
}
NewSuperVOVO = {
	id = 0; -- 新卓越id
	wash = 0; -- 洗练值
}
]]

RespExchangeItemListMsg.meta = {__index = RespExchangeItemListMsg};
function RespExchangeItemListMsg:new()
	local obj = setmetatable( {}, RespExchangeItemListMsg.meta);
	return obj;
end

function RespExchangeItemListMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.gold, idx = readInt64(pak, idx);

	local list1 = {};
	self.ItemList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ItemInfoVo = {};
		ItemInfoVo.tid, idx = readInt(pak, idx);
		ItemInfoVo.count, idx = readInt(pak, idx);
		ItemInfoVo.pos, idx = readInt(pak, idx);
		ItemInfoVo.strenLvl, idx = readInt(pak, idx);
		ItemInfoVo.strenVal, idx = readInt(pak, idx);
		ItemInfoVo.emptystarnum, idx = readInt(pak, idx);
		ItemInfoVo.attrAddLvl, idx = readInt(pak, idx);
		ItemInfoVo.groupId, idx = readInt(pak, idx);
		ItemInfoVo.groupId2, idx = readInt(pak, idx);
		ItemInfoVo.group2Level, idx = readInt(pak, idx);
		ItemInfoVo.superNum, idx = readInt(pak, idx);
		table.push(list1,ItemInfoVo);

		local list2 = {};
		ItemInfoVo.superList = list2;
		local list2Size = 7;

		for i=1,list2Size do
			local SuperVOVo = {};
			SuperVOVo.uid, idx = readGuid(pak, idx);
			SuperVOVo.id, idx = readInt(pak, idx);
			SuperVOVo.val1, idx = readInt(pak, idx);
			table.push(list2,SuperVOVo);
		end

		local list3 = {};
		ItemInfoVo.newSuperList = list3;
		local list3Size = 3;

		for i=1,list3Size do
			local NewSuperVOVo = {};
			NewSuperVOVo.id, idx = readInt(pak, idx);
			NewSuperVOVo.wash, idx = readInt(pak, idx);
			table.push(list3,NewSuperVOVo);
		end
	end

end



--[[
返回交易操作
]]

_G.RespExchangeHandleMsg = {};

RespExchangeHandleMsg.msgId = 8109;
RespExchangeHandleMsg.roleID = ""; -- 玩家id
RespExchangeHandleMsg.type = 0; -- 锁定操作 1:锁定 -1:取消锁定 2:确认交易 -2:取消交易



RespExchangeHandleMsg.meta = {__index = RespExchangeHandleMsg};
function RespExchangeHandleMsg:new()
	local obj = setmetatable( {}, RespExchangeHandleMsg.meta);
	return obj;
end

function RespExchangeHandleMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
服务端通知: 新功能开启
]]

_G.RespFunctionOpenTipsMsg = {};

RespFunctionOpenTipsMsg.msgId = 8110;
RespFunctionOpenTipsMsg.funcID = 0; -- 表内ID



RespFunctionOpenTipsMsg.meta = {__index = RespFunctionOpenTipsMsg};
function RespFunctionOpenTipsMsg:new()
	local obj = setmetatable( {}, RespFunctionOpenTipsMsg.meta);
	return obj;
end

function RespFunctionOpenTipsMsg:ParseData(pak)
	local idx = 1;

	self.funcID, idx = readInt(pak, idx);

end



--[[
服务端通知: 新功能列表
]]

_G.RespFunctionOpenInfoMsg = {};

RespFunctionOpenInfoMsg.msgId = 8111;
RespFunctionOpenInfoMsg.FuncList_size = 0; -- 功能ID列表 size
RespFunctionOpenInfoMsg.FuncList = {}; -- 功能ID列表 list



--[[
FuncInfoVO = {
	funcID = 0; -- 表内ID
}
]]

RespFunctionOpenInfoMsg.meta = {__index = RespFunctionOpenInfoMsg};
function RespFunctionOpenInfoMsg:new()
	local obj = setmetatable( {}, RespFunctionOpenInfoMsg.meta);
	return obj;
end

function RespFunctionOpenInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.FuncList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local FuncInfoVo = {};
		FuncInfoVo.funcID, idx = readInt(pak, idx);
		table.push(list1,FuncInfoVo);
	end

end



--[[
纠正主角位置
]]

_G.RespFixLocationMsg = {};

RespFixLocationMsg.msgId = 8112;
RespFixLocationMsg.stopX = 0; -- 
RespFixLocationMsg.stopY = 0; -- 
RespFixLocationMsg.dir = 0; -- 



RespFixLocationMsg.meta = {__index = RespFixLocationMsg};
function RespFixLocationMsg:new()
	local obj = setmetatable( {}, RespFixLocationMsg.meta);
	return obj;
end

function RespFixLocationMsg:ParseData(pak)
	local idx = 1;

	self.stopX, idx = readDouble(pak, idx);
	self.stopY, idx = readDouble(pak, idx);
	self.dir, idx = readDouble(pak, idx);

end



--[[
返回珍宝阁数据,数据刷新时也返回这个
]]

_G.RespZhenBaoGeMsg = {};

RespZhenBaoGeMsg.msgId = 8113;
RespZhenBaoGeMsg.list_size = 0; -- 珍宝阁列表 size
RespZhenBaoGeMsg.list = {}; -- 珍宝阁列表 list



--[[
ZhenBaoGeVOVO = {
	id = 0; -- 珍宝阁id
	submitTimes = 0; -- 已提交次数
	submitNum = 0; -- 当前次数已提交数量
	itemNum1 = 0; -- 特效道具1
	itemNum2 = 0; -- 特效道具2
	itemNum3 = 0; -- 特效道具3
	breakNum = 0; -- 突破等级
}
]]

RespZhenBaoGeMsg.meta = {__index = RespZhenBaoGeMsg};
function RespZhenBaoGeMsg:new()
	local obj = setmetatable( {}, RespZhenBaoGeMsg.meta);
	return obj;
end

function RespZhenBaoGeMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ZhenBaoGeVOVo = {};
		ZhenBaoGeVOVo.id, idx = readInt(pak, idx);
		ZhenBaoGeVOVo.submitTimes, idx = readInt(pak, idx);
		ZhenBaoGeVOVo.submitNum, idx = readInt(pak, idx);
		ZhenBaoGeVOVo.itemNum1, idx = readInt(pak, idx);
		ZhenBaoGeVOVo.itemNum2, idx = readInt(pak, idx);
		ZhenBaoGeVOVo.itemNum3, idx = readInt(pak, idx);
		ZhenBaoGeVOVo.breakNum, idx = readInt(pak, idx);
		table.push(list1,ZhenBaoGeVOVo);
	end

end



--[[
商品购买返回结果
]]

_G.RespShopPingresultMsg = {};

RespShopPingresultMsg.msgId = 8116;
RespShopPingresultMsg.result = 0; -- 0=成功 1=失败
RespShopPingresultMsg.id = 0; -- 商品id
RespShopPingresultMsg.num = 0; -- 数量



RespShopPingresultMsg.meta = {__index = RespShopPingresultMsg};
function RespShopPingresultMsg:new()
	local obj = setmetatable( {}, RespShopPingresultMsg.meta);
	return obj;
end

function RespShopPingresultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
服务端通知:返回坐骑信息
]]

_G.RespRideInfoMsg = {};

RespRideInfoMsg.msgId = 8117;
RespRideInfoMsg.rideLevel = 0; -- 坐骑阶位
RespRideInfoMsg.starProgress = 0; -- 星级进度
RespRideInfoMsg.pillNum = 0; -- 属性丹数量
RespRideInfoMsg.rideId = 0; -- 当前骑乘坐骑id
RespRideInfoMsg.rideState = 0; -- 骑乘状态,0下马,1上马
RespRideInfoMsg.specailRides_size = 0; -- 特色坐骑列表 size
RespRideInfoMsg.specailRides = {}; -- 特色坐骑列表 list



--[[
RideInfoVO = {
	rideId = 0; -- 特色坐骑id
	time = 0; -- 特色坐骑时限,-1无限时
}
]]

RespRideInfoMsg.meta = {__index = RespRideInfoMsg};
function RespRideInfoMsg:new()
	local obj = setmetatable( {}, RespRideInfoMsg.meta);
	return obj;
end

function RespRideInfoMsg:ParseData(pak)
	local idx = 1;

	self.rideLevel, idx = readInt(pak, idx);
	self.starProgress, idx = readInt(pak, idx);
	self.pillNum, idx = readInt(pak, idx);
	self.rideId, idx = readInt(pak, idx);
	self.rideState, idx = readInt(pak, idx);

	local list1 = {};
	self.specailRides = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RideInfoVo = {};
		RideInfoVo.rideId, idx = readInt(pak, idx);
		RideInfoVo.time, idx = readInt64(pak, idx);
		table.push(list1,RideInfoVo);
	end

end



--[[
服务器通知：返回坐骑进阶进度
]]

_G.RespRideLvlUpInfoMsg = {};

RespRideLvlUpInfoMsg.msgId = 8118;
RespRideLvlUpInfoMsg.result = 0; -- 0=成功 -1=未开启 -2最大等级 -3金币不足 -4进阶石不足 -5元宝不足 -6材料不足
RespRideLvlUpInfoMsg.rideLevel = 0; -- 坐骑阶位
RespRideLvlUpInfoMsg.starProgress = 0; -- 星级进度
RespRideLvlUpInfoMsg.uptype = 0; -- 1 普通成长,2 双倍成长



RespRideLvlUpInfoMsg.meta = {__index = RespRideLvlUpInfoMsg};
function RespRideLvlUpInfoMsg:new()
	local obj = setmetatable( {}, RespRideLvlUpInfoMsg.meta);
	return obj;
end

function RespRideLvlUpInfoMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.rideLevel, idx = readInt(pak, idx);
	self.starProgress, idx = readInt(pak, idx);
	self.uptype, idx = readInt(pak, idx);

end



--[[
服务器通知：返回坐骑进阶成功
]]

_G.RespRideLvlUpSucessMsg = {};

RespRideLvlUpSucessMsg.msgId = 8119;
RespRideLvlUpSucessMsg.rideLevel = 0; -- 坐骑阶位



RespRideLvlUpSucessMsg.meta = {__index = RespRideLvlUpSucessMsg};
function RespRideLvlUpSucessMsg:new()
	local obj = setmetatable( {}, RespRideLvlUpSucessMsg.meta);
	return obj;
end

function RespRideLvlUpSucessMsg:ParseData(pak)
	local idx = 1;

	self.rideLevel, idx = readInt(pak, idx);

end



--[[
服务器通知：返回使用属性丹
]]

_G.RespUserAttDanmsg = {};

RespUserAttDanmsg.msgId = 8120;
RespUserAttDanmsg.type = 0; -- 1、坐骑，2、灵兽，3、神兵、4、灵阵，5、骑战，6、神灵，7、元灵，8、灵兽坐骑百分比属性丹，9、战弩，10 = 五行灵脉
RespUserAttDanmsg.result = 0; -- 0=成功 -1=未开启 -2达到上限 -3数量不足
RespUserAttDanmsg.pillNum = 0; -- 属性丹数量



RespUserAttDanmsg.meta = {__index = RespUserAttDanmsg};
function RespUserAttDanmsg:new()
	local obj = setmetatable( {}, RespUserAttDanmsg.meta);
	return obj;
end

function RespUserAttDanmsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);
	self.pillNum, idx = readInt(pak, idx);

end



--[[
服务器通知：返回更改坐骑
]]

_G.RespChangeRideIdMsg = {};

RespChangeRideIdMsg.msgId = 8121;
RespChangeRideIdMsg.rideId = 0; -- 当前骑乘坐骑id
RespChangeRideIdMsg.rideState = 0; -- 骑乘状态,0下马,1上马



RespChangeRideIdMsg.meta = {__index = RespChangeRideIdMsg};
function RespChangeRideIdMsg:new()
	local obj = setmetatable( {}, RespChangeRideIdMsg.meta);
	return obj;
end

function RespChangeRideIdMsg:ParseData(pak)
	local idx = 1;

	self.rideId, idx = readInt(pak, idx);
	self.rideState, idx = readInt(pak, idx);

end



--[[
服务器通知：返回更改骑乘状态
]]

_G.RespChangeRideStateMsg = {};

RespChangeRideStateMsg.msgId = 8122;
RespChangeRideStateMsg.rideState = 0; -- 骑乘状态,0下马,1上马



RespChangeRideStateMsg.meta = {__index = RespChangeRideStateMsg};
function RespChangeRideStateMsg:new()
	local obj = setmetatable( {}, RespChangeRideStateMsg.meta);
	return obj;
end

function RespChangeRideStateMsg:ParseData(pak)
	local idx = 1;

	self.rideState, idx = readInt(pak, idx);

end



--[[
服务器通知：返回特色坐骑变动
]]

_G.RespRideSpecialMsg = {};

RespRideSpecialMsg.msgId = 8123;
RespRideSpecialMsg.rideId = 0; -- 特色坐骑id
RespRideSpecialMsg.time = 0; -- 特色坐骑时限,-1无限时



RespRideSpecialMsg.meta = {__index = RespRideSpecialMsg};
function RespRideSpecialMsg:new()
	local obj = setmetatable( {}, RespRideSpecialMsg.meta);
	return obj;
end

function RespRideSpecialMsg:ParseData(pak)
	local idx = 1;

	self.rideId, idx = readInt(pak, idx);
	self.time, idx = readInt64(pak, idx);

end



--[[
返回回购结果
]]

_G.RespBuyBackResultMsg = {};

RespBuyBackResultMsg.msgId = 8125;
RespBuyBackResultMsg.result = 0; -- 结果,0成功
RespBuyBackResultMsg.cid = ""; -- 回购物品cid



RespBuyBackResultMsg.meta = {__index = RespBuyBackResultMsg};
function RespBuyBackResultMsg:new()
	local obj = setmetatable( {}, RespBuyBackResultMsg.meta);
	return obj;
end

function RespBuyBackResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.cid, idx = readGuid(pak, idx);

end



--[[
返回噬魂信息
]]

_G.RespShiHunMsg = {};

RespShiHunMsg.msgId = 8127;
RespShiHunMsg.shiHunVal = 0; -- 当前魂值
RespShiHunMsg.shiHunLevel = 0; -- 当前噬魂徽章等级
RespShiHunMsg.monsterList_size = 0; -- 噬魂怪物列表 size
RespShiHunMsg.monsterList = {}; -- 噬魂怪物列表 list



--[[
ShiHunMonsterVOVO = {
	monsterId = 0; -- 噬魂怪物id
	num = 0; -- 怪物数量
}
]]

RespShiHunMsg.meta = {__index = RespShiHunMsg};
function RespShiHunMsg:new()
	local obj = setmetatable( {}, RespShiHunMsg.meta);
	return obj;
end

function RespShiHunMsg:ParseData(pak)
	local idx = 1;

	self.shiHunVal, idx = readInt(pak, idx);
	self.shiHunLevel, idx = readInt(pak, idx);

	local list1 = {};
	self.monsterList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ShiHunMonsterVOVo = {};
		ShiHunMonsterVOVo.monsterId, idx = readInt(pak, idx);
		ShiHunMonsterVOVo.num, idx = readInt(pak, idx);
		table.push(list1,ShiHunMonsterVOVo);
	end

end



--[[
返回魂值改变
]]

_G.RespShiHunValMsg = {};

RespShiHunValMsg.msgId = 8128;
RespShiHunValMsg.shiHunVal = 0; -- 当前魂值



RespShiHunValMsg.meta = {__index = RespShiHunValMsg};
function RespShiHunValMsg:new()
	local obj = setmetatable( {}, RespShiHunValMsg.meta);
	return obj;
end

function RespShiHunValMsg:ParseData(pak)
	local idx = 1;

	self.shiHunVal, idx = readInt(pak, idx);

end



--[[
返回噬魂怪物变化
]]

_G.RespShiHunMonsterMsg = {};

RespShiHunMonsterMsg.msgId = 8129;
RespShiHunMonsterMsg.id = 0; -- 噬魂id
RespShiHunMonsterMsg.monsterId = 0; -- 噬魂怪物id
RespShiHunMonsterMsg.num = 0; -- 怪物数量



RespShiHunMonsterMsg.meta = {__index = RespShiHunMonsterMsg};
function RespShiHunMonsterMsg:new()
	local obj = setmetatable( {}, RespShiHunMonsterMsg.meta);
	return obj;
end

function RespShiHunMonsterMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.monsterId, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
返回装备附加信息
]]

_G.RespEquipInfoMsg = {};

RespEquipInfoMsg.msgId = 8131;
RespEquipInfoMsg.list_size = 0; -- 装备list size
RespEquipInfoMsg.list = {}; -- 装备list list



--[[
ItemEquipVOVO = {
	id = ""; -- 装备cid
	strenLvl = 0; -- 强化等级
	strenVal = 0; -- 强化值
	emptystarnum = 0; -- 空星数
	groupId = 0; -- 套装id
	groupId2 = 0; -- 套装id2
	groupId2Bind = 0; -- 套装id2的绑定状态,0 未绑定，1 已绑定
	group2Level = 0; -- 套装2的等级
}
]]

RespEquipInfoMsg.meta = {__index = RespEquipInfoMsg};
function RespEquipInfoMsg:new()
	local obj = setmetatable( {}, RespEquipInfoMsg.meta);
	return obj;
end

function RespEquipInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ItemEquipVOVo = {};
		ItemEquipVOVo.id, idx = readGuid(pak, idx);
		ItemEquipVOVo.strenLvl, idx = readInt(pak, idx);
		ItemEquipVOVo.strenVal, idx = readInt(pak, idx);
		ItemEquipVOVo.emptystarnum, idx = readInt(pak, idx);
		ItemEquipVOVo.groupId, idx = readInt(pak, idx);
		ItemEquipVOVo.groupId2, idx = readInt(pak, idx);
		ItemEquipVOVo.groupId2Bind, idx = readInt(pak, idx);
		ItemEquipVOVo.group2Level, idx = readInt(pak, idx);
		table.push(list1,ItemEquipVOVo);
	end

end



--[[
返回装备宝石信息
]]

_G.RespEquipGemMsg = {};

RespEquipGemMsg.msgId = 8132;
RespEquipGemMsg.list_size = 0; -- 宝石list size
RespEquipGemMsg.list = {}; -- 宝石list list



--[[
ItemEquipGemVOVO = {
	tid = 0; -- 表id
	pos = 0; -- 装备位
	slot = 0; -- 孔位
}
]]

RespEquipGemMsg.meta = {__index = RespEquipGemMsg};
function RespEquipGemMsg:new()
	local obj = setmetatable( {}, RespEquipGemMsg.meta);
	return obj;
end

function RespEquipGemMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ItemEquipGemVOVo = {};
		ItemEquipGemVOVo.tid, idx = readInt(pak, idx);
		ItemEquipGemVOVo.pos, idx = readInt(pak, idx);
		ItemEquipGemVOVo.slot, idx = readInt(pak, idx);
		table.push(list1,ItemEquipGemVOVo);
	end

end



--[[
更新打坐阵信息
]]

_G.RespSitStatusChangeMsg = {};

RespSitStatusChangeMsg.msgId = 8133;
RespSitStatusChangeMsg.flag = 0; -- 加入：1， 退出：0
RespSitStatusChangeMsg.id = 0; -- 打坐阵id
RespSitStatusChangeMsg.x = 0; -- 打坐阵x
RespSitStatusChangeMsg.y = 0; -- 打坐阵y
RespSitStatusChangeMsg.sitRoleList_size = 0; -- 打坐成员信息 size
RespSitStatusChangeMsg.sitRoleList = {}; -- 打坐成员信息 list



--[[
listVO = {
	index = 0; -- 序号
	roleId = ""; -- 
}
]]

RespSitStatusChangeMsg.meta = {__index = RespSitStatusChangeMsg};
function RespSitStatusChangeMsg:new()
	local obj = setmetatable( {}, RespSitStatusChangeMsg.meta);
	return obj;
end

function RespSitStatusChangeMsg:ParseData(pak)
	local idx = 1;

	self.flag, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);
	self.x, idx = readDouble(pak, idx);
	self.y, idx = readDouble(pak, idx);

	local list1 = {};
	self.sitRoleList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listVo = {};
		listVo.index, idx = readInt(pak, idx);
		listVo.roleId, idx = readGuid(pak, idx);
		table.push(list1,listVo);
	end

end



--[[
返回附近可加入的打坐(人数4的不传)
]]

_G.RespNearbySitMsg = {};

RespNearbySitMsg.msgId = 8134;
RespNearbySitMsg.nearbySitList_size = 0; -- 附近可加入的打坐,仅进入单人打坐成功时传 size
RespNearbySitMsg.nearbySitList = {}; -- 附近可加入的打坐,仅进入单人打坐成功时传 list



--[[
listVO = {
	id = 0; -- 打坐阵id
	roleName = ""; -- 阵内打坐的人的名字
	roleNum = 0; -- 人数
	index = 0; -- 序号
	x = 0; -- 打坐阵x
	y = 0; -- 打坐阵y
}
]]

RespNearbySitMsg.meta = {__index = RespNearbySitMsg};
function RespNearbySitMsg:new()
	local obj = setmetatable( {}, RespNearbySitMsg.meta);
	return obj;
end

function RespNearbySitMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.nearbySitList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listVo = {};
		listVo.id, idx = readInt(pak, idx);
		listVo.roleName, idx = readString(pak, idx, 32);
		listVo.roleNum, idx = readInt(pak, idx);
		listVo.index, idx = readInt(pak, idx);
		listVo.x, idx = readDouble(pak, idx);
		listVo.y, idx = readDouble(pak, idx);
		table.push(list1,listVo);
	end

end



--[[
每5秒获取一次经验和真气
]]

_G.RespSitGainMsg = {};

RespSitGainMsg.msgId = 8135;
RespSitGainMsg.exp = 0; -- 经验
RespSitGainMsg.zhenQi = 0; -- 真气



RespSitGainMsg.meta = {__index = RespSitGainMsg};
function RespSitGainMsg:new()
	local obj = setmetatable( {}, RespSitGainMsg.meta);
	return obj;
end

function RespSitGainMsg:ParseData(pak)
	local idx = 1;

	self.exp, idx = readInt(pak, idx);
	self.zhenQi, idx = readInt(pak, idx);

end



--[[
服务端通知: 副本组列表更新
]]

_G.RespDungeonGroupUpdateMsg = {};

RespDungeonGroupUpdateMsg.msgId = 8137;
RespDungeonGroupUpdateMsg.dungeonGroupList_size = 0; -- 副本组列表 size
RespDungeonGroupUpdateMsg.dungeonGroupList = {}; -- 副本组列表 list



--[[
listVO = {
	group = 0; -- 副本组：各个难度组成一组
	usedTimes = 0; -- 已用次数
	usedPayTimes = 0; -- 已用付费次数
	curDiff = 0; -- the highest difficulty that has been passed currently：1,2,3,4,5对应五个难度
	difficultyList_size = 5; -- 副本组各难度得分 size
	difficultyList = {}; -- 副本组各难度得分 list
}
difficultyVO = {
	time = 0; -- 通关最快用时
}
]]

RespDungeonGroupUpdateMsg.meta = {__index = RespDungeonGroupUpdateMsg};
function RespDungeonGroupUpdateMsg:new()
	local obj = setmetatable( {}, RespDungeonGroupUpdateMsg.meta);
	return obj;
end

function RespDungeonGroupUpdateMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.dungeonGroupList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listVo = {};
		listVo.group, idx = readInt(pak, idx);
		listVo.usedTimes, idx = readByte(pak, idx);
		listVo.usedPayTimes, idx = readByte(pak, idx);
		listVo.curDiff, idx = readByte(pak, idx);
		table.push(list1,listVo);

		local list2 = {};
		listVo.difficultyList = list2;
		local list2Size = 5;

		for i=1,list2Size do
			local difficultyVo = {};
			difficultyVo.time, idx = readInt(pak, idx);
			table.push(list2,difficultyVo);
		end
	end

end



--[[
服务端通知: 开始副本关闭倒计时
]]

_G.RespDungeonCountDownMsg = {};

RespDungeonCountDownMsg.msgId = 8140;
RespDungeonCountDownMsg.tid = 0; -- 副本id
RespDungeonCountDownMsg.line = 0; -- 线
RespDungeonCountDownMsg.time = 0; -- 倒计时时间



RespDungeonCountDownMsg.meta = {__index = RespDungeonCountDownMsg};
function RespDungeonCountDownMsg:new()
	local obj = setmetatable( {}, RespDungeonCountDownMsg.meta);
	return obj;
end

function RespDungeonCountDownMsg:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);
	self.line, idx = readInt(pak, idx);
	self.time, idx = readInt(pak, idx);

end



--[[
服务端通知: 副本过关结果
]]

_G.RespDungeonPassResultMsg = {};

RespDungeonPassResultMsg.msgId = 8141;
RespDungeonPassResultMsg.tid = 0; -- 副本id
RespDungeonPassResultMsg.result = 0; -- 返回结果 1:胜利, 0:失败
RespDungeonPassResultMsg.time = 0; -- 副本通关时间



RespDungeonPassResultMsg.meta = {__index = RespDungeonPassResultMsg};
function RespDungeonPassResultMsg:new()
	local obj = setmetatable( {}, RespDungeonPassResultMsg.meta);
	return obj;
end

function RespDungeonPassResultMsg:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);
	self.time, idx = readInt(pak, idx);

end



--[[
物品获得失去提示
]]

_G.RespItemTipsMsg = {};

RespItemTipsMsg.msgId = 8142;
RespItemTipsMsg.itemTipsList_size = 0; --  size
RespItemTipsMsg.itemTipsList = {}; --  list



--[[
ItemTipsVOVO = {
	type = 0; -- 类型,1:获得,0失去
	tid = 0; -- 物品id
	count = 0; -- 物品数量
}
]]

RespItemTipsMsg.meta = {__index = RespItemTipsMsg};
function RespItemTipsMsg:new()
	local obj = setmetatable( {}, RespItemTipsMsg.meta);
	return obj;
end

function RespItemTipsMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.itemTipsList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ItemTipsVOVo = {};
		ItemTipsVOVo.type, idx = readByte(pak, idx);
		ItemTipsVOVo.tid, idx = readInt(pak, idx);
		ItemTipsVOVo.count, idx = readInt(pak, idx);
		table.push(list1,ItemTipsVOVo);
	end

end



--[[
称号信息
]]

_G.RespTitleInfoMsg = {};

RespTitleInfoMsg.msgId = 8143;
RespTitleInfoMsg.list_size = 0; -- 称号列表 size
RespTitleInfoMsg.list = {}; -- 称号列表 list



--[[
TitleListVOVO = {
	id = 0; -- 称号ID
	state = 0; -- 1已拥有，0未激活，2穿戴
	time = 0; -- 称号剩余过期时间，-1为无期限
}
]]

RespTitleInfoMsg.meta = {__index = RespTitleInfoMsg};
function RespTitleInfoMsg:new()
	local obj = setmetatable( {}, RespTitleInfoMsg.meta);
	return obj;
end

function RespTitleInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local TitleListVOVo = {};
		TitleListVOVo.id, idx = readInt(pak, idx);
		TitleListVOVo.state, idx = readInt(pak, idx);
		TitleListVOVo.time, idx = readInt64(pak, idx);
		table.push(list1,TitleListVOVo);
	end

end



--[[
获得失去提示
]]

_G.RespGetTitleInfoMsg = {};

RespGetTitleInfoMsg.msgId = 8144;
RespGetTitleInfoMsg.id = 0; -- 称号ID
RespGetTitleInfoMsg.time = 0; -- 称号剩余过期时间，-1为无期限 0: 失去 



RespGetTitleInfoMsg.meta = {__index = RespGetTitleInfoMsg};
function RespGetTitleInfoMsg:new()
	local obj = setmetatable( {}, RespGetTitleInfoMsg.meta);
	return obj;
end

function RespGetTitleInfoMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.time, idx = readInt64(pak, idx);

end



--[[
返回装备升品
]]

_G.RespEquipProMsg = {};

RespEquipProMsg.msgId = 8147;
RespEquipProMsg.result = 0; -- -1失败,0进度改变,1升品成功
RespEquipProMsg.id = ""; -- 装备cid
RespEquipProMsg.proVal = 0; -- 进度



RespEquipProMsg.meta = {__index = RespEquipProMsg};
function RespEquipProMsg:new()
	local obj = setmetatable( {}, RespEquipProMsg.meta);
	return obj;
end

function RespEquipProMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readGuid(pak, idx);
	self.proVal, idx = readInt(pak, idx);

end



--[[
返回开关阻挡
]]

_G.RespDungeonBlockMsg = {};

RespDungeonBlockMsg.msgId = 8148;
RespDungeonBlockMsg.enable = 0; -- 1关闭阻挡,0开启阻挡
RespDungeonBlockMsg.music = 0; -- 音效id
RespDungeonBlockMsg.blockname = ""; -- 阻挡名字
RespDungeonBlockMsg.jiguan = 0; -- 机关ID



RespDungeonBlockMsg.meta = {__index = RespDungeonBlockMsg};
function RespDungeonBlockMsg:new()
	local obj = setmetatable( {}, RespDungeonBlockMsg.meta);
	return obj;
end

function RespDungeonBlockMsg:ParseData(pak)
	local idx = 1;

	self.enable, idx = readByte(pak, idx);
	self.music, idx = readInt(pak, idx);
	self.blockname, idx = readString(pak, idx, 64);
	self.jiguan, idx = readByte(pak, idx);

end



--[[
返回添加装备附加信息
]]

_G.RespEquipAddMsg = {};

RespEquipAddMsg.msgId = 8149;
RespEquipAddMsg.id = ""; -- 装备cid
RespEquipAddMsg.strenLvl = 0; -- 强化等级
RespEquipAddMsg.strenVal = 0; -- 强化值
RespEquipAddMsg.emptystarnum = 0; -- 空星数
RespEquipAddMsg.attrAddLvl = 0; -- 追加属性等级
RespEquipAddMsg.groupId = 0; -- 套装id
RespEquipAddMsg.groupId2 = 0; -- 套装id2
RespEquipAddMsg.groupId2Bind = 0; -- 套装id2绑定状态0 未绑定，1 已绑定
RespEquipAddMsg.group2Level = 0; -- 套装2的等级
RespEquipAddMsg.superNum = 0; -- 卓越数量
RespEquipAddMsg.superList_size = 7; -- 卓越属性列表 size
RespEquipAddMsg.superList = {}; -- 卓越属性列表 list
RespEquipAddMsg.newSuperList_size = 3; -- 新卓越属性列表 size
RespEquipAddMsg.newSuperList = {}; -- 新卓越属性列表 list



--[[
SuperVOVO = {
	uid = ""; -- 属性uid
	id = 0; -- 卓越id
	val1 = 0; -- 值1
}
]]
--[[
NewSuperVOVO = {
	id = 0; -- 新卓越id
	wash = 0; -- 洗练值
}
]]

RespEquipAddMsg.meta = {__index = RespEquipAddMsg};
function RespEquipAddMsg:new()
	local obj = setmetatable( {}, RespEquipAddMsg.meta);
	return obj;
end

function RespEquipAddMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.strenLvl, idx = readInt(pak, idx);
	self.strenVal, idx = readInt(pak, idx);
	self.emptystarnum, idx = readInt(pak, idx);
	self.attrAddLvl, idx = readInt(pak, idx);
	self.groupId, idx = readInt(pak, idx);
	self.groupId2, idx = readInt(pak, idx);
	self.groupId2Bind, idx = readInt(pak, idx);
	self.group2Level, idx = readInt(pak, idx);
	self.superNum, idx = readInt(pak, idx);

	local list1 = {};
	self.superList = list1;
	local list1Size = 7;

	for i=1,list1Size do
		local SuperVOVo = {};
		SuperVOVo.uid, idx = readGuid(pak, idx);
		SuperVOVo.id, idx = readInt(pak, idx);
		SuperVOVo.val1, idx = readInt(pak, idx);
		table.push(list1,SuperVOVo);
	end

	local list2 = {};
	self.newSuperList = list2;
	local list2Size = 3;

	for i=1,list2Size do
		local NewSuperVOVo = {};
		NewSuperVOVo.id, idx = readInt(pak, idx);
		NewSuperVOVo.wash, idx = readInt(pak, idx);
		table.push(list2,NewSuperVOVo);
	end

end



--[[
返回装备传承
]]

_G.RespEquipInheritMsg = {};

RespEquipInheritMsg.msgId = 8150;
RespEquipInheritMsg.srcid = ""; -- 源装备cid
RespEquipInheritMsg.tarid = ""; -- 目标装备cid
RespEquipInheritMsg.result = 0; -- 结果,0成功, -1失败



RespEquipInheritMsg.meta = {__index = RespEquipInheritMsg};
function RespEquipInheritMsg:new()
	local obj = setmetatable( {}, RespEquipInheritMsg.meta);
	return obj;
end

function RespEquipInheritMsg:ParseData(pak)
	local idx = 1;

	self.srcid, idx = readGuid(pak, idx);
	self.tarid, idx = readGuid(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
日环任务升5星结果
]]

_G.RespDailyQuestStarMsg = {};

RespDailyQuestStarMsg.msgId = 8152;
RespDailyQuestStarMsg.result = 0; -- 结果,0成功, 1:钱不够 2:目标任务不存在



RespDailyQuestStarMsg.meta = {__index = RespDailyQuestStarMsg};
function RespDailyQuestStarMsg:new()
	local obj = setmetatable( {}, RespDailyQuestStarMsg.meta);
	return obj;
end

function RespDailyQuestStarMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
返回日环任务一键完成奖励信息
]]

_G.RespDailyQuestFinishMsg = {};

RespDailyQuestFinishMsg.msgId = 8153;
RespDailyQuestFinishMsg.result = 0; -- 结果, 0成功, 1:钱不够 2:vip等级不够
RespDailyQuestFinishMsg.level = 0; -- 每日完成奖励等级
RespDailyQuestFinishMsg.rewardList_size = 4; -- 日环抽奖列表 size
RespDailyQuestFinishMsg.rewardList = {}; -- 日环抽奖列表 list
RespDailyQuestFinishMsg.list_size = 0; -- 一键完成的日环任务列表 size
RespDailyQuestFinishMsg.list = {}; -- 一键完成的日环任务列表 list



--[[
DailyQuestRewardListVO = {
	id = 0; -- 物品id, id为0为空
	num = 0; -- 数量
}
]]
--[[
DailyQuestListVO = {
	id = 0; -- 任务id
	star = 0; -- 星级
	double = 0; -- 倍率
}
]]

RespDailyQuestFinishMsg.meta = {__index = RespDailyQuestFinishMsg};
function RespDailyQuestFinishMsg:new()
	local obj = setmetatable( {}, RespDailyQuestFinishMsg.meta);
	return obj;
end

function RespDailyQuestFinishMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.level, idx = readInt(pak, idx);

	local list2 = {};
	self.rewardList = list2;
	local list2Size = 4;

	for i=1,list2Size do
		local DailyQuestRewardListVo = {};
		DailyQuestRewardListVo.id, idx = readInt(pak, idx);
		DailyQuestRewardListVo.num, idx = readInt(pak, idx);
		table.push(list2,DailyQuestRewardListVo);
	end

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local DailyQuestListVo = {};
		DailyQuestListVo.id, idx = readInt(pak, idx);
		DailyQuestListVo.star, idx = readInt(pak, idx);
		DailyQuestListVo.double, idx = readInt(pak, idx);
		table.push(list1,DailyQuestListVo);
	end

end



--[[
返回日环任务结果
]]

_G.RespDailyQuestResultMsg = {};

RespDailyQuestResultMsg.msgId = 8154;
RespDailyQuestResultMsg.list_size = 20; -- 日环列表 size
RespDailyQuestResultMsg.list = {}; -- 日环列表 list
RespDailyQuestResultMsg.rewardList_size = 4; -- 日环抽奖列表 size
RespDailyQuestResultMsg.rewardList = {}; -- 日环抽奖列表 list



--[[
DailyQuestListVO = {
	id = 0; -- 任务id
	star = 0; -- 星级
	double = 0; -- 倍率
}
]]
--[[
DailyQuestRewardListVO = {
	id = 0; -- 物品id
	num = 0; -- 数量
}
]]

RespDailyQuestResultMsg.meta = {__index = RespDailyQuestResultMsg};
function RespDailyQuestResultMsg:new()
	local obj = setmetatable( {}, RespDailyQuestResultMsg.meta);
	return obj;
end

function RespDailyQuestResultMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 20;

	for i=1,list1Size do
		local DailyQuestListVo = {};
		DailyQuestListVo.id, idx = readInt(pak, idx);
		DailyQuestListVo.star, idx = readInt(pak, idx);
		DailyQuestListVo.double, idx = readInt(pak, idx);
		table.push(list1,DailyQuestListVo);
	end

	local list2 = {};
	self.rewardList = list2;
	local list2Size = 4;

	for i=1,list2Size do
		local DailyQuestRewardListVo = {};
		DailyQuestRewardListVo.id, idx = readInt(pak, idx);
		DailyQuestRewardListVo.num, idx = readInt(pak, idx);
		table.push(list2,DailyQuestRewardListVo);
	end

end



--[[
返回日环任务抽奖
]]

_G.RespDailyQuestDrawMsg = {};

RespDailyQuestDrawMsg.msgId = 8155;
RespDailyQuestDrawMsg.rewardIndex = 0; -- 奖励索引
RespDailyQuestDrawMsg.doubleIndex = 0; -- 倍数索引



RespDailyQuestDrawMsg.meta = {__index = RespDailyQuestDrawMsg};
function RespDailyQuestDrawMsg:new()
	local obj = setmetatable( {}, RespDailyQuestDrawMsg.meta);
	return obj;
end

function RespDailyQuestDrawMsg:ParseData(pak)
	local idx = 1;

	self.rewardIndex, idx = readInt(pak, idx);
	self.doubleIndex, idx = readInt(pak, idx);

end



--[[
返回宝石升级信息
]]

_G.RespEquipGemUpLevelInfo = {};

RespEquipGemUpLevelInfo.msgId = 8157;
RespEquipGemUpLevelInfo.result = 0; -- -1失败,0升级成功
RespEquipGemUpLevelInfo.tid = 0; -- 表id
RespEquipGemUpLevelInfo.gemlvl = 0; -- 等级
RespEquipGemUpLevelInfo.pos = 0; -- 装备位
RespEquipGemUpLevelInfo.slot = 0; -- 孔位



RespEquipGemUpLevelInfo.meta = {__index = RespEquipGemUpLevelInfo};
function RespEquipGemUpLevelInfo:new()
	local obj = setmetatable( {}, RespEquipGemUpLevelInfo.meta);
	return obj;
end

function RespEquipGemUpLevelInfo:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.tid, idx = readInt(pak, idx);
	self.gemlvl, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);
	self.slot, idx = readInt(pak, idx);

end



--[[
登录返回活动列表
]]

_G.RespActivityMsg = {};

RespActivityMsg.msgId = 8158;
RespActivityMsg.list_size = 0; -- 任务列表 size
RespActivityMsg.list = {}; -- 任务列表 list



--[[
ActivityVO = {
	id = 0; -- 活动id
	dailyTimes = 0; -- 今天已参加次数
}
]]

RespActivityMsg.meta = {__index = RespActivityMsg};
function RespActivityMsg:new()
	local obj = setmetatable( {}, RespActivityMsg.meta);
	return obj;
end

function RespActivityMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ActivityVo = {};
		ActivityVo.id, idx = readInt(pak, idx);
		ActivityVo.dailyTimes, idx = readInt(pak, idx);
		table.push(list1,ActivityVo);
	end

end



--[[
返回进入活动
]]

_G.RespActivityEnterMsg = {};

RespActivityEnterMsg.msgId = 8159;
RespActivityEnterMsg.result = 0; -- 结果,0成功 -1活动未开启 -2:等级 -3:次数 -4:当前场景类型 -5:组队 -6:疲劳值 -7:功能未开启
RespActivityEnterMsg.id = 0; -- 活动id
RespActivityEnterMsg.param1 = 0; -- 参数1



RespActivityEnterMsg.meta = {__index = RespActivityEnterMsg};
function RespActivityEnterMsg:new()
	local obj = setmetatable( {}, RespActivityEnterMsg.meta);
	return obj;
end

function RespActivityEnterMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);
	self.param1, idx = readInt(pak, idx);

end



--[[
返回退出活动
]]

_G.RespActivityQuitMsg = {};

RespActivityQuitMsg.msgId = 8160;
RespActivityQuitMsg.result = 0; -- 结果,0成功
RespActivityQuitMsg.id = 0; -- 活动id



RespActivityQuitMsg.meta = {__index = RespActivityQuitMsg};
function RespActivityQuitMsg:new()
	local obj = setmetatable( {}, RespActivityQuitMsg.meta);
	return obj;
end

function RespActivityQuitMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
返回活动结束(活动内玩家)
]]

_G.RespActivityFinishMsg = {};

RespActivityFinishMsg.msgId = 8161;
RespActivityFinishMsg.id = 0; -- 活动id



RespActivityFinishMsg.meta = {__index = RespActivityFinishMsg};
function RespActivityFinishMsg:new()
	local obj = setmetatable( {}, RespActivityFinishMsg.meta);
	return obj;
end

function RespActivityFinishMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
返回玩家累计伤害
]]

_G.RespWorldBossDamageMsg = {};

RespWorldBossDamageMsg.msgId = 8162;
RespWorldBossDamageMsg.damage = 0; -- 伤害总量



RespWorldBossDamageMsg.meta = {__index = RespWorldBossDamageMsg};
function RespWorldBossDamageMsg:new()
	local obj = setmetatable( {}, RespWorldBossDamageMsg.meta);
	return obj;
end

function RespWorldBossDamageMsg:ParseData(pak)
	local idx = 1;

	self.damage, idx = readDouble(pak, idx);

end



--[[
返回世界Boss伤害信息(活动内)
]]

_G.RespWorldBossHurtMsg = {};

RespWorldBossHurtMsg.msgId = 8163;
RespWorldBossHurtMsg.hp = 0; -- hp
RespWorldBossHurtMsg.maxHp = 0; -- maxHp
RespWorldBossHurtMsg.list_size = 5; -- 伤害排行(前5名) size
RespWorldBossHurtMsg.list = {}; -- 伤害排行(前5名) list



--[[
WorldBossHurtVO = {
	roleID = ""; -- roleID
	roleName = ""; -- roleName
	hurt = 0; -- 造成伤害
}
]]

RespWorldBossHurtMsg.meta = {__index = RespWorldBossHurtMsg};
function RespWorldBossHurtMsg:new()
	local obj = setmetatable( {}, RespWorldBossHurtMsg.meta);
	return obj;
end

function RespWorldBossHurtMsg:ParseData(pak)
	local idx = 1;

	self.hp, idx = readDouble(pak, idx);
	self.maxHp, idx = readDouble(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 5;

	for i=1,list1Size do
		local WorldBossHurtVo = {};
		WorldBossHurtVo.roleID, idx = readGuid(pak, idx);
		WorldBossHurtVo.roleName, idx = readString(pak, idx, 32);
		WorldBossHurtVo.hurt, idx = readDouble(pak, idx);
		table.push(list1,WorldBossHurtVo);
	end

end



--[[
服务端通知:返回封妖信息
]]

_G.RespFengYaoInfoMsg = {};

RespFengYaoInfoMsg.msgId = 8164;
RespFengYaoInfoMsg.fengyaoGroup = 0; -- 当前选择的封妖组id
RespFengYaoInfoMsg.fengyaoId = 0; -- 当前可选择的封妖id
RespFengYaoInfoMsg.curState = 0; -- 活动状态 0:未接受,1已接受,2可领奖,3已领奖
RespFengYaoInfoMsg.finishCount = 0; -- 今日完成次数
RespFengYaoInfoMsg.curScore = 0; -- 当前积分
RespFengYaoInfoMsg.boxList_size = 0; -- 已领奖宝箱列表 size
RespFengYaoInfoMsg.boxList = {}; -- 已领奖宝箱列表 list



--[[
ScoreBoxVOVO = {
	boxId = 0; -- 宝箱id
}
]]

RespFengYaoInfoMsg.meta = {__index = RespFengYaoInfoMsg};
function RespFengYaoInfoMsg:new()
	local obj = setmetatable( {}, RespFengYaoInfoMsg.meta);
	return obj;
end

function RespFengYaoInfoMsg:ParseData(pak)
	local idx = 1;

	self.fengyaoGroup, idx = readInt(pak, idx);
	self.fengyaoId, idx = readInt(pak, idx);
	self.curState, idx = readInt(pak, idx);
	self.finishCount, idx = readInt(pak, idx);
	self.curScore, idx = readInt(pak, idx);

	local list1 = {};
	self.boxList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ScoreBoxVOVo = {};
		ScoreBoxVOVo.boxId, idx = readInt(pak, idx);
		table.push(list1,ScoreBoxVOVo);
	end

end



--[[
服务器通知：返回难度刷新
]]

_G.RespFengYaoLvlRefreshResultMsg = {};

RespFengYaoLvlRefreshResultMsg.msgId = 8165;
RespFengYaoLvlRefreshResultMsg.result = 0; -- 结果
RespFengYaoLvlRefreshResultMsg.fengyaoid = 0; -- 当前可选择的封妖id



RespFengYaoLvlRefreshResultMsg.meta = {__index = RespFengYaoLvlRefreshResultMsg};
function RespFengYaoLvlRefreshResultMsg:new()
	local obj = setmetatable( {}, RespFengYaoLvlRefreshResultMsg.meta);
	return obj;
end

function RespFengYaoLvlRefreshResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.fengyaoid, idx = readInt(pak, idx);

end



--[[
服务器通知：返回接受封妖任务
]]

_G.RespAcceptFengYaoResultMsg = {};

RespAcceptFengYaoResultMsg.msgId = 8166;
RespAcceptFengYaoResultMsg.fengyaoid = 0; -- 封妖id



RespAcceptFengYaoResultMsg.meta = {__index = RespAcceptFengYaoResultMsg};
function RespAcceptFengYaoResultMsg:new()
	local obj = setmetatable( {}, RespAcceptFengYaoResultMsg.meta);
	return obj;
end

function RespAcceptFengYaoResultMsg:ParseData(pak)
	local idx = 1;

	self.fengyaoid, idx = readInt(pak, idx);

end



--[[
服务器通知：封妖活动可领奖
]]

_G.RespFinishFengYaoMsg = {};

RespFinishFengYaoMsg.msgId = 8167;
RespFinishFengYaoMsg.fengyaoid = 0; -- 封妖id



RespFinishFengYaoMsg.meta = {__index = RespFinishFengYaoMsg};
function RespFinishFengYaoMsg:new()
	local obj = setmetatable( {}, RespFinishFengYaoMsg.meta);
	return obj;
end

function RespFinishFengYaoMsg:ParseData(pak)
	local idx = 1;

	self.fengyaoid, idx = readInt(pak, idx);

end



--[[
服务器返回结果：返回领取封妖奖励结果
]]

_G.RespGetFengYaoRewardResltMsg = {};

RespGetFengYaoRewardResltMsg.msgId = 8168;
RespGetFengYaoRewardResltMsg.result = 0; -- 结果 0、成功，1、银两不足，2、元宝不足
RespGetFengYaoRewardResltMsg.curScore = 0; -- 当前积分
RespGetFengYaoRewardResltMsg.fengyaoid = 0; -- 封妖id



RespGetFengYaoRewardResltMsg.meta = {__index = RespGetFengYaoRewardResltMsg};
function RespGetFengYaoRewardResltMsg:new()
	local obj = setmetatable( {}, RespGetFengYaoRewardResltMsg.meta);
	return obj;
end

function RespGetFengYaoRewardResltMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.curScore, idx = readInt(pak, idx);
	self.fengyaoid, idx = readInt(pak, idx);

end



--[[
服务器通知：返回放弃封妖结果
]]

_G.RespGiveupFengYaoResultMsg = {};

RespGiveupFengYaoResultMsg.msgId = 8169;
RespGiveupFengYaoResultMsg.result = 0; -- 结果
RespGiveupFengYaoResultMsg.fengyaoid = 0; -- 封妖id



RespGiveupFengYaoResultMsg.meta = {__index = RespGiveupFengYaoResultMsg};
function RespGiveupFengYaoResultMsg:new()
	local obj = setmetatable( {}, RespGiveupFengYaoResultMsg.meta);
	return obj;
end

function RespGiveupFengYaoResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.fengyaoid, idx = readInt(pak, idx);

end



--[[
服务器通知：自动刷新封妖列表
]]

_G.RespRefreshFengYaoListMsg = {};

RespRefreshFengYaoListMsg.msgId = 8170;
RespRefreshFengYaoListMsg.fengyaoGroup = 0; -- 当前选择的封妖组id
RespRefreshFengYaoListMsg.fengyaoId = 0; -- 当前可选择的封妖id



RespRefreshFengYaoListMsg.meta = {__index = RespRefreshFengYaoListMsg};
function RespRefreshFengYaoListMsg:new()
	local obj = setmetatable( {}, RespRefreshFengYaoListMsg.meta);
	return obj;
end

function RespRefreshFengYaoListMsg:ParseData(pak)
	local idx = 1;

	self.fengyaoGroup, idx = readInt(pak, idx);
	self.fengyaoId, idx = readInt(pak, idx);

end



--[[
服务器通知：返回获取封妖宝箱结果
]]

_G.RespGetFengYaoBoxResultMsg = {};

RespGetFengYaoBoxResultMsg.msgId = 8171;
RespGetFengYaoBoxResultMsg.result = 0; -- 结果,0ture
RespGetFengYaoBoxResultMsg.boxId = 0; -- 宝箱id



RespGetFengYaoBoxResultMsg.meta = {__index = RespGetFengYaoBoxResultMsg};
function RespGetFengYaoBoxResultMsg:new()
	local obj = setmetatable( {}, RespGetFengYaoBoxResultMsg.meta);
	return obj;
end

function RespGetFengYaoBoxResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.boxId, idx = readInt(pak, idx);

end



--[[
服务器返回PK规则：返回定义的PK规则
]]

_G.RespGetPKRuleMsg = {};

RespGetPKRuleMsg.msgId = 8172;
RespGetPKRuleMsg.pkid = 0; -- 返回定义PK的规则0：和平，1：组队，2：帮派，3：本服，4：阵营，5：善恶，6：全体，7：自定义
RespGetPKRuleMsg.myselfpk = 0; -- 自己定义的PK规则
RespGetPKRuleMsg.mystate = 0; -- 自己当前PK的状态



RespGetPKRuleMsg.meta = {__index = RespGetPKRuleMsg};
function RespGetPKRuleMsg:new()
	local obj = setmetatable( {}, RespGetPKRuleMsg.meta);
	return obj;
end

function RespGetPKRuleMsg:ParseData(pak)
	local idx = 1;

	self.pkid, idx = readInt(pak, idx);
	self.myselfpk, idx = readInt(pak, idx);
	self.mystate, idx = readInt(pak, idx);

end



--[[
服务器返回物品使用数量列表
]]

_G.RespItemUseNumListMsg = {};

RespItemUseNumListMsg.msgId = 8173;
RespItemUseNumListMsg.list_size = 0; -- list size
RespItemUseNumListMsg.list = {}; -- list list



--[[
ItemUseNumVO = {
	itemId = 0; -- 物品id
	dailyNum = 0; -- 每次使用数量
	lifeNum = 0; -- 一生使用数量
}
]]

RespItemUseNumListMsg.meta = {__index = RespItemUseNumListMsg};
function RespItemUseNumListMsg:new()
	local obj = setmetatable( {}, RespItemUseNumListMsg.meta);
	return obj;
end

function RespItemUseNumListMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ItemUseNumVo = {};
		ItemUseNumVo.itemId, idx = readInt(pak, idx);
		ItemUseNumVo.dailyNum, idx = readInt(pak, idx);
		ItemUseNumVo.lifeNum, idx = readInt(pak, idx);
		table.push(list1,ItemUseNumVo);
	end

end



--[[
服务器返回妖魂值
]]

_G.RespYaoHunMsg = {};

RespYaoHunMsg.msgId = 8174;
RespYaoHunMsg.val = 0; -- 妖魂值



RespYaoHunMsg.meta = {__index = RespYaoHunMsg};
function RespYaoHunMsg:new()
	local obj = setmetatable( {}, RespYaoHunMsg.meta);
	return obj;
end

function RespYaoHunMsg:ParseData(pak)
	local idx = 1;

	self.val, idx = readInt(pak, idx);

end



--[[
服务器返回妖魂兑换
]]

_G.RespYaoHunExchangeMsg = {};

RespYaoHunExchangeMsg.msgId = 8175;
RespYaoHunExchangeMsg.result = 0; -- 0成功
RespYaoHunExchangeMsg.type = 0; -- 类型



RespYaoHunExchangeMsg.meta = {__index = RespYaoHunExchangeMsg};
function RespYaoHunExchangeMsg:new()
	local obj = setmetatable( {}, RespYaoHunExchangeMsg.meta);
	return obj;
end

function RespYaoHunExchangeMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
服务器通知是否抽奖，每环结束都要发
]]

_G.RespDQDrawNoticeMsg = {};

RespDQDrawNoticeMsg.msgId = 8176;
RespDQDrawNoticeMsg.draw = 0; -- 0:抽奖 1:不抽奖



RespDQDrawNoticeMsg.meta = {__index = RespDQDrawNoticeMsg};
function RespDQDrawNoticeMsg:new()
	local obj = setmetatable( {}, RespDQDrawNoticeMsg.meta);
	return obj;
end

function RespDQDrawNoticeMsg:ParseData(pak)
	local idx = 1;

	self.draw, idx = readByte(pak, idx);

end



--[[
服务器返回跳环结果
]]

_G.RespDailyQuestSkipResultMsg = {};

RespDailyQuestSkipResultMsg.msgId = 8177;
RespDailyQuestSkipResultMsg.round = 0; -- 跳到第几环
RespDailyQuestSkipResultMsg.list_size = 0; -- 跳过的任务列表,跳环均以5星结算 size
RespDailyQuestSkipResultMsg.list = {}; -- 跳过的任务列表,跳环均以5星结算 list



--[[
DailyQuestListVO = {
	id = 0; -- 任务id
	star = 0; -- 星级
	double = 0; -- 倍率
}
]]

RespDailyQuestSkipResultMsg.meta = {__index = RespDailyQuestSkipResultMsg};
function RespDailyQuestSkipResultMsg:new()
	local obj = setmetatable( {}, RespDailyQuestSkipResultMsg.meta);
	return obj;
end

function RespDailyQuestSkipResultMsg:ParseData(pak)
	local idx = 1;

	self.round, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local DailyQuestListVo = {};
		DailyQuestListVo.id, idx = readInt(pak, idx);
		DailyQuestListVo.star, idx = readInt(pak, idx);
		DailyQuestListVo.double, idx = readInt(pak, idx);
		table.push(list1,DailyQuestListVo);
	end

end



--[[
服务器返回妖魂兑换属性列表
]]

_G.RespYaoHunAttrResultMsg = {};

RespYaoHunAttrResultMsg.msgId = 8178;
RespYaoHunAttrResultMsg.list_size = 0; -- list size
RespYaoHunAttrResultMsg.list = {}; -- list list



--[[
YaoHunVO = {
	type = 0; -- 兑换类型
	num = 0; -- 妖魂数量
}
]]

RespYaoHunAttrResultMsg.meta = {__index = RespYaoHunAttrResultMsg};
function RespYaoHunAttrResultMsg:new()
	local obj = setmetatable( {}, RespYaoHunAttrResultMsg.meta);
	return obj;
end

function RespYaoHunAttrResultMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local YaoHunVo = {};
		YaoHunVo.type, idx = readInt(pak, idx);
		YaoHunVo.num, idx = readInt(pak, idx);
		table.push(list1,YaoHunVo);
	end

end



--[[
服务器返回签到属性列表
]]

_G.RespSignListResultMsg = {};

RespSignListResultMsg.msgId = 8179;
RespSignListResultMsg.day = 0; -- 签到天
RespSignListResultMsg.lastNum = 0; -- 补签次数
RespSignListResultMsg.nextNum = 0; -- 提前签到次数



RespSignListResultMsg.meta = {__index = RespSignListResultMsg};
function RespSignListResultMsg:new()
	local obj = setmetatable( {}, RespSignListResultMsg.meta);
	return obj;
end

function RespSignListResultMsg:ParseData(pak)
	local idx = 1;

	self.day, idx = readInt(pak, idx);
	self.lastNum, idx = readInt(pak, idx);
	self.nextNum, idx = readInt(pak, idx);

end



--[[
服务器返回签到奖励列表
]]

_G.RespSignRewardResultMsg = {};

RespSignRewardResultMsg.msgId = 8180;
RespSignRewardResultMsg.list_size = 0; -- list size
RespSignRewardResultMsg.list = {}; -- list list



--[[
SignrewardVO = {
	day = 0; -- 签到天
	vipstate = 0; -- VIP奖励是否已领取
	state = 0; -- 奖励是否已领取
}
]]

RespSignRewardResultMsg.meta = {__index = RespSignRewardResultMsg};
function RespSignRewardResultMsg:new()
	local obj = setmetatable( {}, RespSignRewardResultMsg.meta);
	return obj;
end

function RespSignRewardResultMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local SignrewardVo = {};
		SignrewardVo.day, idx = readInt(pak, idx);
		SignrewardVo.vipstate, idx = readInt(pak, idx);
		SignrewardVo.state, idx = readInt(pak, idx);
		table.push(list1,SignrewardVo);
	end

end



--[[
服务端通知:等级奖励信息
]]

_G.RespLvRewardInfoMsg = {};

RespLvRewardInfoMsg.msgId = 8181;
RespLvRewardInfoMsg.lvrewardList_size = 0; -- 已领等级奖励列表 size
RespLvRewardInfoMsg.lvrewardList = {}; -- 已领等级奖励列表 list



--[[
LvRewardVOVO = {
	lvl = 0; -- 等级
}
]]

RespLvRewardInfoMsg.meta = {__index = RespLvRewardInfoMsg};
function RespLvRewardInfoMsg:new()
	local obj = setmetatable( {}, RespLvRewardInfoMsg.meta);
	return obj;
end

function RespLvRewardInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.lvrewardList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local LvRewardVOVo = {};
		LvRewardVOVo.lvl, idx = readInt(pak, idx);
		table.push(list1,LvRewardVOVo);
	end

end



--[[
服务器通知：返回领取等级奖励结果
]]

_G.RespGetLvlRewardResultMsg = {};

RespGetLvlRewardResultMsg.msgId = 8182;
RespGetLvlRewardResultMsg.result = 0; -- 结果 0成功
RespGetLvlRewardResultMsg.lvl = 0; -- 等级



RespGetLvlRewardResultMsg.meta = {__index = RespGetLvlRewardResultMsg};
function RespGetLvlRewardResultMsg:new()
	local obj = setmetatable( {}, RespGetLvlRewardResultMsg.meta);
	return obj;
end

function RespGetLvlRewardResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.lvl, idx = readInt(pak, idx);

end



--[[
服务器通知：返回战场信息
]]

_G.RespGetZhanchanginfoMsg = {};

RespGetZhanchanginfoMsg.msgId = 8183;
RespGetZhanchanginfoMsg.type = 0; -- 我所属战场 6--A  7-- B
RespGetZhanchanginfoMsg.scoreA = 0; -- 我方得分
RespGetZhanchanginfoMsg.scoreB = 0; -- 敌方方得分
RespGetZhanchanginfoMsg.sourceTime = 0; -- 资源到达时间
RespGetZhanchanginfoMsg.num = 0; -- 我方击杀信使数
RespGetZhanchanginfoMsg.contr = 0; -- 我的贡献
RespGetZhanchanginfoMsg.Addnum = 0; -- 我的累计击杀数量 
RespGetZhanchanginfoMsg.contnum = 0; -- 我的连续击杀数量 
RespGetZhanchanginfoMsg.Maxcontnum = 0; -- 我的最大连续击杀数量 
RespGetZhanchanginfoMsg.time = 0; -- 战场剩余时间 



RespGetZhanchanginfoMsg.meta = {__index = RespGetZhanchanginfoMsg};
function RespGetZhanchanginfoMsg:new()
	local obj = setmetatable( {}, RespGetZhanchanginfoMsg.meta);
	return obj;
end

function RespGetZhanchanginfoMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.scoreA, idx = readInt(pak, idx);
	self.scoreB, idx = readInt(pak, idx);
	self.sourceTime, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);
	self.contr, idx = readInt(pak, idx);
	self.Addnum, idx = readInt(pak, idx);
	self.contnum, idx = readInt(pak, idx);
	self.Maxcontnum, idx = readInt(pak, idx);
	self.time, idx = readInt(pak, idx);

end



--[[
服务器通知：返回战场人物信息
]]

_G.RespZhancRoleinfoMsg = {};

RespZhancRoleinfoMsg.msgId = 8184;
RespZhancRoleinfoMsg.camp = 0; -- 阵营
RespZhancRoleinfoMsg.infolist_size = 0; -- list size
RespZhancRoleinfoMsg.infolist = {}; -- list list



--[[
infoVO = {
	roleName = ""; -- 人物名称
	contr = 0; -- 玩家贡献
	Addnum = 0; -- 累计击杀数量
	contnum = 0; -- 连续击杀数量
}
]]

RespZhancRoleinfoMsg.meta = {__index = RespZhancRoleinfoMsg};
function RespZhancRoleinfoMsg:new()
	local obj = setmetatable( {}, RespZhancRoleinfoMsg.meta);
	return obj;
end

function RespZhancRoleinfoMsg:ParseData(pak)
	local idx = 1;

	self.camp, idx = readInt(pak, idx);

	local list1 = {};
	self.infolist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local infoVo = {};
		infoVo.roleName, idx = readString(pak, idx, 32);
		infoVo.contr, idx = readInt(pak, idx);
		infoVo.Addnum, idx = readInt(pak, idx);
		infoVo.contnum, idx = readInt(pak, idx);
		table.push(list1,infoVo);
	end

end



--[[
服务器通知：击杀数量和经验
]]

_G.RespTianjijianKillNumMsg = {};

RespTianjijianKillNumMsg.msgId = 8190;
RespTianjijianKillNumMsg.num = 0; -- 本次击杀数量
RespTianjijianKillNumMsg.exp = 0; -- 本次击杀所得经验



RespTianjijianKillNumMsg.meta = {__index = RespTianjijianKillNumMsg};
function RespTianjijianKillNumMsg:new()
	local obj = setmetatable( {}, RespTianjijianKillNumMsg.meta);
	return obj;
end

function RespTianjijianKillNumMsg:ParseData(pak)
	local idx = 1;

	self.num, idx = readInt(pak, idx);
	self.exp, idx = readInt(pak, idx);

end



--[[
服务器通知：天机剑时间信息
]]

_G.RespTianjijianTimeInfoMsg = {};

RespTianjijianTimeInfoMsg.msgId = 8191;
RespTianjijianTimeInfoMsg.remaintime = 0; -- 天机剑剩余总时间
RespTianjijianTimeInfoMsg.curremaintime = 0; -- 天机剑本轮剩余时间



RespTianjijianTimeInfoMsg.meta = {__index = RespTianjijianTimeInfoMsg};
function RespTianjijianTimeInfoMsg:new()
	local obj = setmetatable( {}, RespTianjijianTimeInfoMsg.meta);
	return obj;
end

function RespTianjijianTimeInfoMsg:ParseData(pak)
	local idx = 1;

	self.remaintime, idx = readInt(pak, idx);
	self.curremaintime, idx = readInt(pak, idx);

end



--[[
服务器通知进入竞技场
]]

_G.RespEnterArenaMsg = {};

RespEnterArenaMsg.msgId = 8192;
RespEnterArenaMsg.result = 0; -- 结果0 - 成功， 1 - 失败
RespEnterArenaMsg.ArenaMemlist_size = 2; -- 竞技场列表 size
RespEnterArenaMsg.ArenaMemlist = {}; -- 竞技场列表 list



--[[
ArenaMemVoVO = {
	roleId = ""; -- 玩家id
	roleName = ""; -- 名字
	power = 0; -- 战斗力
	level = 0; -- 等级
	prof = 0; -- 职业
	dress = 0; -- 衣服
	arms = 0; -- 武器
	fashionshead = 0; -- 时装头
	fashionsarms = 0; -- 时装武器
	fashionsdress = 0; -- 时装衣服
	wuhunId = 0; -- 灵兽ID
	shenbing = 0; -- 神兵ID
	sex = 0; -- 性别
	icon = 0; -- 头像
	wing = 0; -- 翅膀
	suitflag = 0; -- 套装标识
	atk = 0; -- atk
	hp = 0; -- hp
	subdef = 0; -- subdef
	def = 0; -- def
	cri = 0; -- cri
	crivalue = 0; -- crivalue
	absatk = 0; -- absatk
	defcri = 0; -- defcri
	subcri = 0; -- subcri
	dmgsub = 0; -- dmgsub
	dmgadd = 0; -- dmgadd
	skillList_size = 10; -- 技能列表 size
	skillList = {}; -- 技能列表 list
}
SkillVOVO = {
	skillid = 0; -- 技能id
}
]]

RespEnterArenaMsg.meta = {__index = RespEnterArenaMsg};
function RespEnterArenaMsg:new()
	local obj = setmetatable( {}, RespEnterArenaMsg.meta);
	return obj;
end

function RespEnterArenaMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

	local list1 = {};
	self.ArenaMemlist = list1;
	local list1Size = 2;

	for i=1,list1Size do
		local ArenaMemVoVo = {};
		ArenaMemVoVo.roleId, idx = readGuid(pak, idx);
		ArenaMemVoVo.roleName, idx = readString(pak, idx, 32);
		ArenaMemVoVo.power, idx = readInt64(pak, idx);
		ArenaMemVoVo.level, idx = readInt(pak, idx);
		ArenaMemVoVo.prof, idx = readInt(pak, idx);
		ArenaMemVoVo.dress, idx = readInt(pak, idx);
		ArenaMemVoVo.arms, idx = readInt(pak, idx);
		ArenaMemVoVo.fashionshead, idx = readInt(pak, idx);
		ArenaMemVoVo.fashionsarms, idx = readInt(pak, idx);
		ArenaMemVoVo.fashionsdress, idx = readInt(pak, idx);
		ArenaMemVoVo.wuhunId, idx = readInt(pak, idx);
		ArenaMemVoVo.shenbing, idx = readInt(pak, idx);
		ArenaMemVoVo.sex, idx = readInt(pak, idx);
		ArenaMemVoVo.icon, idx = readInt(pak, idx);
		ArenaMemVoVo.wing, idx = readInt(pak, idx);
		ArenaMemVoVo.suitflag, idx = readInt(pak, idx);
		ArenaMemVoVo.atk, idx = readDouble(pak, idx);
		ArenaMemVoVo.hp, idx = readDouble(pak, idx);
		ArenaMemVoVo.subdef, idx = readDouble(pak, idx);
		ArenaMemVoVo.def, idx = readDouble(pak, idx);
		ArenaMemVoVo.cri, idx = readDouble(pak, idx);
		ArenaMemVoVo.crivalue, idx = readDouble(pak, idx);
		ArenaMemVoVo.absatk, idx = readDouble(pak, idx);
		ArenaMemVoVo.defcri, idx = readDouble(pak, idx);
		ArenaMemVoVo.subcri, idx = readDouble(pak, idx);
		ArenaMemVoVo.dmgsub, idx = readDouble(pak, idx);
		ArenaMemVoVo.dmgadd, idx = readDouble(pak, idx);
		table.push(list1,ArenaMemVoVo);

		local list2 = {};
		ArenaMemVoVo.skillList = list2;
		local list2Size = 10;

		for i=1,list2Size do
			local SkillVOVo = {};
			SkillVOVo.skillid, idx = readInt(pak, idx);
			table.push(list2,SkillVOVo);
		end
	end

end



--[[
服务器推送需要在地图上显示的玩家信息
]]

_G.RespMapPlayerMsg = {};

RespMapPlayerMsg.msgId = 8193;
RespMapPlayerMsg.mapPlayerList_size = 0; -- 需要在地图上显示的玩家信息列表 size
RespMapPlayerMsg.mapPlayerList = {}; -- 需要在地图上显示的玩家信息列表 list



--[[
mapMemVOVO = {
	roleId = ""; -- 玩家guid
	posX = 0; -- 玩家x坐标
	posY = 0; -- 玩家y坐标
	roleName = ""; -- 人物名称
	flag = 0; -- 1 队伍-队长; 2 队伍-队员; 3 帮派-帮主 4 帮派-成员; 5 帮派地宫旗帜
	level = 0; -- 等级
}
]]

RespMapPlayerMsg.meta = {__index = RespMapPlayerMsg};
function RespMapPlayerMsg:new()
	local obj = setmetatable( {}, RespMapPlayerMsg.meta);
	return obj;
end

function RespMapPlayerMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.mapPlayerList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local mapMemVOVo = {};
		mapMemVOVo.roleId, idx = readGuid(pak, idx);
		mapMemVOVo.posX, idx = readInt(pak, idx);
		mapMemVOVo.posY, idx = readInt(pak, idx);
		mapMemVOVo.roleName, idx = readString(pak, idx, 32);
		mapMemVOVo.flag, idx = readByte(pak, idx);
		mapMemVOVo.level, idx = readInt(pak, idx);
		table.push(list1,mapMemVOVo);
	end

end



--[[
签到领取奖励成功或失败
]]

_G.RespSignMsg = {};

RespSignMsg.msgId = 8194;
RespSignMsg.flag = 0; -- 返回结果



RespSignMsg.meta = {__index = RespSignMsg};
function RespSignMsg:new()
	local obj = setmetatable( {}, RespSignMsg.meta);
	return obj;
end

function RespSignMsg:ParseData(pak)
	local idx = 1;

	self.flag, idx = readInt(pak, idx);

end



--[[
返回在线时间
]]

_G.RespOnlineTime = {};

RespOnlineTime.msgId = 8195;
RespOnlineTime.onlineTime = 0; -- 



RespOnlineTime.meta = {__index = RespOnlineTime};
function RespOnlineTime:new()
	local obj = setmetatable( {}, RespOnlineTime.meta);
	return obj;
end

function RespOnlineTime:ParseData(pak)
	local idx = 1;

	self.onlineTime, idx = readInt(pak, idx);

end



--[[
服务端通知: 返回技能进阶
]]

_G.RespSkillStepUpMsg = {};

RespSkillStepUpMsg.msgId = 8196;
RespSkillStepUpMsg.result = 0; -- 反馈结果,0成功,1失败
RespSkillStepUpMsg.oldSkillId = 0; -- 学习前技能id
RespSkillStepUpMsg.skillId = 0; -- 新技能id



RespSkillStepUpMsg.meta = {__index = RespSkillStepUpMsg};
function RespSkillStepUpMsg:new()
	local obj = setmetatable( {}, RespSkillStepUpMsg.meta);
	return obj;
end

function RespSkillStepUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.oldSkillId, idx = readInt(pak, idx);
	self.skillId, idx = readInt(pak, idx);

end



--[[
推送战场内旗子状态
]]

_G.RespUpdateFlagsMsg = {};

RespUpdateFlagsMsg.msgId = 8198;
RespUpdateFlagsMsg.flagList_size = 0; --  size
RespUpdateFlagsMsg.flagList = {}; --  list



--[[
flagVOVO = {
	idx = 0; -- 旗帜索引
	camp = 0; -- 所属阵营
	canPick = 0; -- 能否拾取 1:可 0:不可
}
]]

RespUpdateFlagsMsg.meta = {__index = RespUpdateFlagsMsg};
function RespUpdateFlagsMsg:new()
	local obj = setmetatable( {}, RespUpdateFlagsMsg.meta);
	return obj;
end

function RespUpdateFlagsMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.flagList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local flagVOVo = {};
		flagVOVo.idx, idx = readByte(pak, idx);
		flagVOVo.camp, idx = readByte(pak, idx);
		flagVOVo.canPick, idx = readByte(pak, idx);
		table.push(list1,flagVOVo);
	end

end



--[[
返回结果
]]

_G.RespPickFlagResultMsg = {};

RespPickFlagResultMsg.msgId = 8199;
RespPickFlagResultMsg.idx = 0; -- 旗帜索引
RespPickFlagResultMsg.type = 0; -- 0夺取，1交付
RespPickFlagResultMsg.result = 0; -- 结果:  1:成功 2:不可拾取 3:位置校验错误 0:参数错误



RespPickFlagResultMsg.meta = {__index = RespPickFlagResultMsg};
function RespPickFlagResultMsg:new()
	local obj = setmetatable( {}, RespPickFlagResultMsg.meta);
	return obj;
end

function RespPickFlagResultMsg:ParseData(pak)
	local idx = 1;

	self.idx, idx = readByte(pak, idx);
	self.type, idx = readByte(pak, idx);
	self.result, idx = readByte(pak, idx);

end



--[[
返回传送结果
]]

_G.RespTeleportMsg = {};

RespTeleportMsg.msgId = 8200;
RespTeleportMsg.type = 0; -- 1世界地图传送 2日环传送 3剧情传送 4悬赏传送 5世界boss传送 6主线传送 7远距离主线任务免费传送(根据任务表配的teleportMap地图id), 8奇遇传送 ,10一键挖宝传送
RespTeleportMsg.result = 0; -- 结果 0:成功,1:ID错误 2:当前场景错误 3:目标地图错误 4:等级 5:PKing 6:同地图 7:钱不够 8:待定义，9:巡游中



RespTeleportMsg.meta = {__index = RespTeleportMsg};
function RespTeleportMsg:new()
	local obj = setmetatable( {}, RespTeleportMsg.meta);
	return obj;
end

function RespTeleportMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readByte(pak, idx);
	self.result, idx = readByte(pak, idx);

end



--[[
服务器通知：返回战场噬血榜
]]

_G.RespZhancKillRankMsg = {};

RespZhancKillRankMsg.msgId = 8201;
RespZhancKillRankMsg.rankList_size = 5; -- list size
RespZhancKillRankMsg.rankList = {}; -- list list



--[[
rankVOVO = {
	camp = 0; -- 阵营
	roleName = ""; -- 人物名称
	Addnum = 0; -- 累计击杀数量
}
]]

RespZhancKillRankMsg.meta = {__index = RespZhancKillRankMsg};
function RespZhancKillRankMsg:new()
	local obj = setmetatable( {}, RespZhancKillRankMsg.meta);
	return obj;
end

function RespZhancKillRankMsg:ParseData(pak)
	local idx = 1;


	local list = {};
	self.rankList = list;
	local listSize = 5;

	for i=1,listSize do
		local rankVOVo = {};
		rankVOVo.camp, idx = readByte(pak, idx);
		rankVOVo.roleName, idx = readString(pak, idx, 32);
		rankVOVo.Addnum, idx = readInt(pak, idx);
		table.push(list,rankVOVo);
	end

end



--[[
服务器通知：返回战场贡献榜
]]

_G.RespZhancContriRankMsg = {};

RespZhancContriRankMsg.msgId = 8202;
RespZhancContriRankMsg.rankList_size = 5; -- list size
RespZhancContriRankMsg.rankList = {}; -- list list



--[[
rankVOVO = {
	camp = 0; -- 阵营
	roleName = ""; -- 人物名称
	contr = 0; -- 玩家贡献
}
]]

RespZhancContriRankMsg.meta = {__index = RespZhancContriRankMsg};
function RespZhancContriRankMsg:new()
	local obj = setmetatable( {}, RespZhancContriRankMsg.meta);
	return obj;
end

function RespZhancContriRankMsg:ParseData(pak)
	local idx = 1;


	local list = {};
	self.rankList = list;
	local listSize = 5;

	for i=1,listSize do
		local rankVOVo = {};
		rankVOVo.camp, idx = readByte(pak, idx);
		rankVOVo.roleName, idx = readString(pak, idx, 32);
		rankVOVo.contr, idx = readInt(pak, idx);
		table.push(list,rankVOVo);
	end

end



--[[
服务器通知：返回战场信息更新
]]

_G.RespZhancUpdateMsg = {};

RespZhancUpdateMsg.msgId = 8203;
RespZhancUpdateMsg.type = 0; -- 0:A阵营得分 1:B阵营得分 2:A阵营击杀信使 3:A阵营击杀信使 4:资源刷新 5:我的击杀 6:我的连续击杀 7:我的贡献度 8：最大击杀
RespZhancUpdateMsg.value = 0; -- 值



RespZhancUpdateMsg.meta = {__index = RespZhancUpdateMsg};
function RespZhancUpdateMsg:new()
	local obj = setmetatable( {}, RespZhancUpdateMsg.meta);
	return obj;
end

function RespZhancUpdateMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readByte(pak, idx);
	self.value, idx = readInt(pak, idx);

end



--[[
服务端通知:返回道具合成信息
]]

_G.RespToolHeChengMsg = {};

RespToolHeChengMsg.msgId = 8204;
RespToolHeChengMsg.result = 0; -- 返回结果
RespToolHeChengMsg.Id = 0; -- 合成分解的道具Id
RespToolHeChengMsg.type = 0; -- 合成分解类型 1:合成 2:分解



RespToolHeChengMsg.meta = {__index = RespToolHeChengMsg};
function RespToolHeChengMsg:new()
	local obj = setmetatable( {}, RespToolHeChengMsg.meta);
	return obj;
end

function RespToolHeChengMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.Id, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
服务器通知：返回狂暴
]]

_G.RespRampageInfoMsg = {};

RespRampageInfoMsg.msgId = 8205;
RespRampageInfoMsg.kill = 0; -- 
RespRampageInfoMsg.exp = 0; -- 



RespRampageInfoMsg.meta = {__index = RespRampageInfoMsg};
function RespRampageInfoMsg:new()
	local obj = setmetatable( {}, RespRampageInfoMsg.meta);
	return obj;
end

function RespRampageInfoMsg:ParseData(pak)
	local idx = 1;

	self.kill, idx = readInt(pak, idx);
	self.exp, idx = readInt(pak, idx);

end



--[[
服务器通知：随机事件
]]

_G.RespDungeonRandomEventMsg = {};

RespDungeonRandomEventMsg.msgId = 8206;
RespDungeonRandomEventMsg.id = 0; -- 事件id
RespDungeonRandomEventMsg.state = 0; -- 状态 1:事件通知 2:事件开始 3:事件胜利 4:事件失败
RespDungeonRandomEventMsg.param1 = 0; -- 参数1
RespDungeonRandomEventMsg.param2 = 0; -- 参数2



RespDungeonRandomEventMsg.meta = {__index = RespDungeonRandomEventMsg};
function RespDungeonRandomEventMsg:new()
	local obj = setmetatable( {}, RespDungeonRandomEventMsg.meta);
	return obj;
end

function RespDungeonRandomEventMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.state, idx = readByte(pak, idx);
	self.param1, idx = readInt(pak, idx);
	self.param2, idx = readInt(pak, idx);

end



--[[
服务端通知:返回解封信息
]]

_G.RespJieFengResultMsg = {};

RespJieFengResultMsg.msgId = 8207;
RespJieFengResultMsg.type = 0; -- 今日解封返回类型,1解封总值,2本次解封,3快速解救
RespJieFengResultMsg.count = 0; -- 今日解封数量
RespJieFengResultMsg.list_size = 0; -- 奖励列表 size
RespJieFengResultMsg.list = {}; -- 奖励列表 list



--[[
RewardListVO = {
	type = 0; -- 奖励类型
	num = 0; -- 奖励总值
}
]]

RespJieFengResultMsg.meta = {__index = RespJieFengResultMsg};
function RespJieFengResultMsg:new()
	local obj = setmetatable( {}, RespJieFengResultMsg.meta);
	return obj;
end

function RespJieFengResultMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.count, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RewardListVo = {};
		RewardListVo.type, idx = readInt(pak, idx);
		RewardListVo.num, idx = readInt64(pak, idx);
		table.push(list1,RewardListVo);
	end

end



--[[
服务端通知:返回boss星级结果
]]

_G.RespRandomBossStarMsg = {};

RespRandomBossStarMsg.msgId = 8210;
RespRandomBossStarMsg.result = 0; -- 结果: 0成功
RespRandomBossStarMsg.Id = 0; -- boss_id
RespRandomBossStarMsg.star = 0; -- 星级



RespRandomBossStarMsg.meta = {__index = RespRandomBossStarMsg};
function RespRandomBossStarMsg:new()
	local obj = setmetatable( {}, RespRandomBossStarMsg.meta);
	return obj;
end

function RespRandomBossStarMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.Id, idx = readInt(pak, idx);
	self.star, idx = readInt(pak, idx);

end



--[[
服务端通知：场景中玩家显示名字变化
]]

_G.RespScenePlayerNameChangeMsg = {};

RespScenePlayerNameChangeMsg.msgId = 8211;
RespScenePlayerNameChangeMsg.roleID = ""; -- 主角id
RespScenePlayerNameChangeMsg.guildId = ""; -- 帮派id
RespScenePlayerNameChangeMsg.type = 0; -- 类型:1玩家名字，2帮派名字，3配偶名字
RespScenePlayerNameChangeMsg.name = ""; -- 名字信息



RespScenePlayerNameChangeMsg.meta = {__index = RespScenePlayerNameChangeMsg};
function RespScenePlayerNameChangeMsg:new()
	local obj = setmetatable( {}, RespScenePlayerNameChangeMsg.meta);
	return obj;
end

function RespScenePlayerNameChangeMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.guildId, idx = readGuid(pak, idx);
	self.type, idx = readInt(pak, idx);
	self.name, idx = readString(pak, idx, 32);

end



--[[
服务端通知:返回仙缘洞府BOSS状态
]]

_G.RespXianYuanCaveBossStateMsg = {};

RespXianYuanCaveBossStateMsg.msgId = 8212;
RespXianYuanCaveBossStateMsg.id = 0; -- BOSSID
RespXianYuanCaveBossStateMsg.num = 0; -- BOSS状态



RespXianYuanCaveBossStateMsg.meta = {__index = RespXianYuanCaveBossStateMsg};
function RespXianYuanCaveBossStateMsg:new()
	local obj = setmetatable( {}, RespXianYuanCaveBossStateMsg.meta);
	return obj;
end

function RespXianYuanCaveBossStateMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
服务端通知:战场结果
]]

_G.RespZhancResultMsg = {};

RespZhancResultMsg.msgId = 8213;
RespZhancResultMsg.result = 0; -- 胜利方id
RespZhancResultMsg.rewardList_size = 3; -- list index 1累计击杀 2最大击杀 3贡献  size
RespZhancResultMsg.rewardList = {}; -- list index 1累计击杀 2最大击杀 3贡献  list



--[[
listVOVO = {
	roleName = ""; -- 人物名称
	icon = 0; -- 头像id
	num = 0; -- 数量
}
]]

RespZhancResultMsg.meta = {__index = RespZhancResultMsg};
function RespZhancResultMsg:new()
	local obj = setmetatable( {}, RespZhancResultMsg.meta);
	return obj;
end

function RespZhancResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

	local list = {};
	self.rewardList = list;
	local listSize = 3;

	for i=1,listSize do
		local listVOVo = {};
		listVOVo.roleName, idx = readString(pak, idx, 32);
		listVOVo.icon, idx = readInt(pak, idx);
		listVOVo.num, idx = readInt(pak, idx);
		table.push(list,listVOVo);
	end

end



--[[
服务器通知：返回最大击杀榜
]]

_G.RespZhancZuidajishaMsg = {};

RespZhancZuidajishaMsg.msgId = 8214;
RespZhancZuidajishaMsg.rankList_size = 5; -- list size
RespZhancZuidajishaMsg.rankList = {}; -- list list



--[[
rankVOVO = {
	camp = 0; -- 阵营
	roleName = ""; -- 人物名称
	Addnum = 0; -- 最大击杀数量
}
]]

RespZhancZuidajishaMsg.meta = {__index = RespZhancZuidajishaMsg};
function RespZhancZuidajishaMsg:new()
	local obj = setmetatable( {}, RespZhancZuidajishaMsg.meta);
	return obj;
end

function RespZhancZuidajishaMsg:ParseData(pak)
	local idx = 1;


	local list = {};
	self.rankList = list;
	local listSize = 5;

	for i=1,listSize do
		local rankVOVo = {};
		rankVOVo.camp, idx = readByte(pak, idx);
		rankVOVo.roleName, idx = readString(pak, idx, 32);
		rankVOVo.Addnum, idx = readInt(pak, idx);
		table.push(list,rankVOVo);
	end

end



--[[
服务端通知：退出挑战地宫炼狱结果
]]

_G.RespQuitGuildHellMsg = {};

RespQuitGuildHellMsg.msgId = 8215;
RespQuitGuildHellMsg.result = 0; -- 退出结果 0:成功



RespQuitGuildHellMsg.meta = {__index = RespQuitGuildHellMsg};
function RespQuitGuildHellMsg:new()
	local obj = setmetatable( {}, RespQuitGuildHellMsg.meta);
	return obj;
end

function RespQuitGuildHellMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
服务器返回结果：返回成功失败
]]

_G.RespOtherHumanInfoRetMsg = {};

RespOtherHumanInfoRetMsg.msgId = 8217;
RespOtherHumanInfoRetMsg.result = 0; -- 结果: 0成功 1失败



RespOtherHumanInfoRetMsg.meta = {__index = RespOtherHumanInfoRetMsg};
function RespOtherHumanInfoRetMsg:new()
	local obj = setmetatable( {}, RespOtherHumanInfoRetMsg.meta);
	return obj;
end

function RespOtherHumanInfoRetMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回结果：返回他人信息
]]

_G.RespOtherHumanBSInfoRetMsg = {};

RespOtherHumanBSInfoRetMsg.msgId = 8218;
RespOtherHumanBSInfoRetMsg.serverType = 0; -- 是否全服排行信息 1=是 其余都不是
RespOtherHumanBSInfoRetMsg.type = 0; -- 1== 详细信息，2 == 排行榜详细信息
RespOtherHumanBSInfoRetMsg.roleID = ""; -- 角色ID
RespOtherHumanBSInfoRetMsg.roleName = ""; -- 角色名字
RespOtherHumanBSInfoRetMsg.prof = 0; -- 职业
RespOtherHumanBSInfoRetMsg.level = 0; -- 等级
RespOtherHumanBSInfoRetMsg.hp = 0; -- hp
RespOtherHumanBSInfoRetMsg.maxHp = 0; -- maxHP
RespOtherHumanBSInfoRetMsg.mp = 0; -- mp
RespOtherHumanBSInfoRetMsg.maxMp = 0; -- maxMp
RespOtherHumanBSInfoRetMsg.fight = 0; -- 战斗力
RespOtherHumanBSInfoRetMsg.guildName = ""; -- 帮会名
RespOtherHumanBSInfoRetMsg.vipLevel = 0; -- VIP等级
RespOtherHumanBSInfoRetMsg.sex = 0; -- 性别
RespOtherHumanBSInfoRetMsg.dress = 0; -- 衣服
RespOtherHumanBSInfoRetMsg.arms = 0; -- 武器
RespOtherHumanBSInfoRetMsg.fashionshead = 0; -- 时装头
RespOtherHumanBSInfoRetMsg.fashionsarms = 0; -- 时装武器
RespOtherHumanBSInfoRetMsg.fashionsdress = 0; -- 时装衣服
RespOtherHumanBSInfoRetMsg.mountState = 0; -- 0未开启状态，1已开启状态
RespOtherHumanBSInfoRetMsg.wuhunState = 0; -- 0未开启状态，1已开启状态
RespOtherHumanBSInfoRetMsg.shoulder = 0; -- 肩膀
RespOtherHumanBSInfoRetMsg.wuhunId = 0; -- 武魂id
RespOtherHumanBSInfoRetMsg.wing = 0; -- 翅膀
RespOtherHumanBSInfoRetMsg.wingStarLevel = 0; -- 翅膀强化等级
RespOtherHumanBSInfoRetMsg.suitflag = 0; -- 套装标识
RespOtherHumanBSInfoRetMsg.att = 0; -- 攻击
RespOtherHumanBSInfoRetMsg.def = 0; -- 防御
RespOtherHumanBSInfoRetMsg.hit = 0; -- 命中
RespOtherHumanBSInfoRetMsg.cri = 0; -- 暴击
RespOtherHumanBSInfoRetMsg.dodge = 0; -- 闪避
RespOtherHumanBSInfoRetMsg.defcri = 0; -- 韧性
RespOtherHumanBSInfoRetMsg.attspper = 0; -- 攻击速度
RespOtherHumanBSInfoRetMsg.moveper = 0; -- 移动速度
RespOtherHumanBSInfoRetMsg.hl = 0; -- 魂力
RespOtherHumanBSInfoRetMsg.tp = 0; -- 体魄
RespOtherHumanBSInfoRetMsg.sf = 0; -- 身法
RespOtherHumanBSInfoRetMsg.js = 0; -- 精神
RespOtherHumanBSInfoRetMsg.shenwu = 0; -- 神武等级 * 10000 + 神武星级
RespOtherHumanBSInfoRetMsg.loveName = ""; -- 配偶名字
RespOtherHumanBSInfoRetMsg.shenwuSkills_size = 3; -- 神武技能 size
RespOtherHumanBSInfoRetMsg.shenwuSkills = {}; -- 神武技能 list
RespOtherHumanBSInfoRetMsg.list_size = 0; -- 装备list size
RespOtherHumanBSInfoRetMsg.list = {}; -- 装备list list



--[[
shenwuSkillsVO = {
	skillId = 0; -- 神武技能tid
}
]]
--[[
ItemEquipVOVO = {
	tid = 0; -- 装备tid
	bind = 0; -- 0 未绑定，1 已绑定
	strenLvl = 0; -- 强化等级
	strenVal = 0; -- 强化值
	emptystarnum = 0; -- 空星数
	refinLvl = 0; -- 炼化等级
	attrAddLvl = 0; -- 追加属性等级
	groupId = 0; -- 套装id
	groupId2 = 0; -- 套装id2
	group2Level = 0; -- 套装2的等级
	superNum = 0; -- 卓越数量
	superList_size = 7; -- 卓越属性列表 size
	superList = {}; -- 卓越属性列表 list
	newSuperList_size = 3; -- 新卓越属性列表 size
	newSuperList = {}; -- 新卓越属性列表 list
}
SuperVOVO = {
	uid = ""; -- 属性uid
	id = 0; -- 卓越id
	val1 = 0; -- 值1
}
NewSuperVOVO = {
	id = 0; -- 新卓越id
	wash = 0; -- 洗练值
}
]]

RespOtherHumanBSInfoRetMsg.meta = {__index = RespOtherHumanBSInfoRetMsg};
function RespOtherHumanBSInfoRetMsg:new()
	local obj = setmetatable( {}, RespOtherHumanBSInfoRetMsg.meta);
	return obj;
end

function RespOtherHumanBSInfoRetMsg:ParseData(pak)
	local idx = 1;

	self.serverType, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);
	self.roleID, idx = readGuid(pak, idx);
	self.roleName, idx = readString(pak, idx, 32);
	self.prof, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);
	self.hp, idx = readInt(pak, idx);
	self.maxHp, idx = readInt(pak, idx);
	self.mp, idx = readInt(pak, idx);
	self.maxMp, idx = readInt(pak, idx);
	self.fight, idx = readInt64(pak, idx);
	self.guildName, idx = readString(pak, idx, 32);
	self.vipLevel, idx = readInt(pak, idx);
	self.sex, idx = readByte(pak, idx);
	self.dress, idx = readInt(pak, idx);
	self.arms, idx = readInt(pak, idx);
	self.fashionshead, idx = readInt(pak, idx);
	self.fashionsarms, idx = readInt(pak, idx);
	self.fashionsdress, idx = readInt(pak, idx);
	self.mountState, idx = readInt(pak, idx);
	self.wuhunState, idx = readInt(pak, idx);
	self.shoulder, idx = readInt(pak, idx);
	self.wuhunId, idx = readInt(pak, idx);
	self.wing, idx = readInt(pak, idx);
	self.wingStarLevel, idx = readInt(pak, idx);
	self.suitflag, idx = readInt(pak, idx);
	self.att, idx = readInt(pak, idx);
	self.def, idx = readInt(pak, idx);
	self.hit, idx = readInt(pak, idx);
	self.cri, idx = readInt(pak, idx);
	self.dodge, idx = readInt(pak, idx);
	self.defcri, idx = readInt(pak, idx);
	self.attspper, idx = readInt(pak, idx);
	self.moveper, idx = readInt(pak, idx);
	self.hl, idx = readInt(pak, idx);
	self.tp, idx = readInt(pak, idx);
	self.sf, idx = readInt(pak, idx);
	self.js, idx = readInt(pak, idx);
	self.shenwu, idx = readInt(pak, idx);
	self.loveName, idx = readString(pak, idx, 32);

	local list4 = {};
	self.shenwuSkills = list4;
	local list4Size = 3;

	for i=1,list4Size do
		local shenwuSkillsVo = {};
		shenwuSkillsVo.skillId, idx = readInt(pak, idx);
		table.push(list4,shenwuSkillsVo);
	end

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ItemEquipVOVo = {};
		ItemEquipVOVo.tid, idx = readInt(pak, idx);
		ItemEquipVOVo.bind, idx = readByte(pak, idx);
		ItemEquipVOVo.strenLvl, idx = readInt(pak, idx);
		ItemEquipVOVo.strenVal, idx = readInt(pak, idx);
		ItemEquipVOVo.emptystarnum, idx = readInt(pak, idx);
		ItemEquipVOVo.refinLvl, idx = readInt(pak, idx);
		ItemEquipVOVo.attrAddLvl, idx = readInt(pak, idx);
		ItemEquipVOVo.groupId, idx = readInt(pak, idx);
		ItemEquipVOVo.groupId2, idx = readInt(pak, idx);
		ItemEquipVOVo.group2Level, idx = readInt(pak, idx);
		ItemEquipVOVo.superNum, idx = readInt(pak, idx);
		table.push(list1,ItemEquipVOVo);

		local list2 = {};
		ItemEquipVOVo.superList = list2;
		local list2Size = 7;

		for i=1,list2Size do
			local SuperVOVo = {};
			SuperVOVo.uid, idx = readGuid(pak, idx);
			SuperVOVo.id, idx = readInt(pak, idx);
			SuperVOVo.val1, idx = readInt(pak, idx);
			table.push(list2,SuperVOVo);
		end

		local list3 = {};
		ItemEquipVOVo.newSuperList = list3;
		local list3Size = 3;

		for i=1,list3Size do
			local NewSuperVOVo = {};
			NewSuperVOVo.id, idx = readInt(pak, idx);
			NewSuperVOVo.wash, idx = readInt(pak, idx);
			table.push(list3,NewSuperVOVo);
		end
	end

end



--[[
服务端返回结果:返回其他人详细信息
]]

_G.RespOtherHumanXXInfoRetMsg = {};

RespOtherHumanXXInfoRetMsg.msgId = 8219;
RespOtherHumanXXInfoRetMsg.roleID = ""; -- 角色ID
RespOtherHumanXXInfoRetMsg.dodge = 0; -- 闪避
RespOtherHumanXXInfoRetMsg.defcri = 0; -- 韧性
RespOtherHumanXXInfoRetMsg.crivalue = 0; -- 爆伤
RespOtherHumanXXInfoRetMsg.subcri = 0; -- 免爆
RespOtherHumanXXInfoRetMsg.absatt = 0; -- 穿刺
RespOtherHumanXXInfoRetMsg.defparry = 0; -- 格挡率
RespOtherHumanXXInfoRetMsg.parryvalue = 0; -- 格挡值
RespOtherHumanXXInfoRetMsg.adddamage = 0; -- 伤害增强
RespOtherHumanXXInfoRetMsg.subdamage = 0; -- 伤害减免
RespOtherHumanXXInfoRetMsg.pkValue = 0; -- pk值
RespOtherHumanXXInfoRetMsg.pkHonor = 0; -- 荣誉
RespOtherHumanXXInfoRetMsg.killValue = 0; -- 杀戮值
RespOtherHumanXXInfoRetMsg.subdef = 0; -- 穿刺
RespOtherHumanXXInfoRetMsg.super = 0; -- 卓越一击几率
RespOtherHumanXXInfoRetMsg.supervalue = 0; -- 卓越一击伤害
RespOtherHumanXXInfoRetMsg.shenWei = 0; -- 神威



RespOtherHumanXXInfoRetMsg.meta = {__index = RespOtherHumanXXInfoRetMsg};
function RespOtherHumanXXInfoRetMsg:new()
	local obj = setmetatable( {}, RespOtherHumanXXInfoRetMsg.meta);
	return obj;
end

function RespOtherHumanXXInfoRetMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);
	self.dodge, idx = readInt(pak, idx);
	self.defcri, idx = readInt(pak, idx);
	self.crivalue, idx = readInt(pak, idx);
	self.subcri, idx = readInt(pak, idx);
	self.absatt, idx = readInt(pak, idx);
	self.defparry, idx = readInt(pak, idx);
	self.parryvalue, idx = readInt(pak, idx);
	self.adddamage, idx = readInt(pak, idx);
	self.subdamage, idx = readInt(pak, idx);
	self.pkValue, idx = readInt(pak, idx);
	self.pkHonor, idx = readInt(pak, idx);
	self.killValue, idx = readInt(pak, idx);
	self.subdef, idx = readInt(pak, idx);
	self.super, idx = readDouble(pak, idx);
	self.supervalue, idx = readDouble(pak, idx);
	self.shenWei, idx = readDouble(pak, idx);

end



--[[
服务端返回结果:返回其他人坐骑信息
]]

_G.RespOtherMountInfoRetMsg = {};

RespOtherMountInfoRetMsg.msgId = 8220;
RespOtherMountInfoRetMsg.type = 0; -- 1== 详细信息，2 == 排行榜详细信息
RespOtherMountInfoRetMsg.roleID = ""; -- 角色ID
RespOtherMountInfoRetMsg.rideLevel = 0; -- 坐骑阶位
RespOtherMountInfoRetMsg.starProgress = 0; -- 星级进度
RespOtherMountInfoRetMsg.rideSelect = 0; -- 选中坐骑
RespOtherMountInfoRetMsg.pillNum = 0; -- 属性丹数量
RespOtherMountInfoRetMsg.equiplist_size = 4; -- 坐骑装备list size
RespOtherMountInfoRetMsg.equiplist = {}; -- 坐骑装备list list
RespOtherMountInfoRetMsg.skilllist_size = 6; -- 坐骑技能list size
RespOtherMountInfoRetMsg.skilllist = {}; -- 坐骑技能list list
RespOtherMountInfoRetMsg.attrlist_size = 0; -- 属性list size
RespOtherMountInfoRetMsg.attrlist = {}; -- 属性list list



--[[
ItemEquipVOVO = {
	id = 0; -- 装备tid
	groupId = 0; -- 套装id
	bind = 0; -- 0 未绑定，1 已绑定
}
]]
--[[
SkillVOVO = {
	skillid = 0; -- 技能id
	skilllvl = 0; -- 技能等级
}
]]
--[[
AttrVOVO = {
	type = 0; -- 属性
	valX = 0; -- 属性百分比
}
]]

RespOtherMountInfoRetMsg.meta = {__index = RespOtherMountInfoRetMsg};
function RespOtherMountInfoRetMsg:new()
	local obj = setmetatable( {}, RespOtherMountInfoRetMsg.meta);
	return obj;
end

function RespOtherMountInfoRetMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.roleID, idx = readGuid(pak, idx);
	self.rideLevel, idx = readInt(pak, idx);
	self.starProgress, idx = readInt(pak, idx);
	self.rideSelect, idx = readInt(pak, idx);
	self.pillNum, idx = readInt(pak, idx);

	local list = {};
	self.equiplist = list;
	local listSize = 4;

	for i=1,listSize do
		local ItemEquipVOVo = {};
		ItemEquipVOVo.id, idx = readInt(pak, idx);
		ItemEquipVOVo.groupId, idx = readInt(pak, idx);
		ItemEquipVOVo.bind, idx = readByte(pak, idx);
		table.push(list,ItemEquipVOVo);
	end

	local list = {};
	self.skilllist = list;
	local listSize = 6;

	for i=1,listSize do
		local SkillVOVo = {};
		SkillVOVo.skillid, idx = readInt(pak, idx);
		SkillVOVo.skilllvl, idx = readInt(pak, idx);
		table.push(list,SkillVOVo);
	end

	local list1 = {};
	self.attrlist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local AttrVOVo = {};
		AttrVOVo.type, idx = readInt(pak, idx);
		AttrVOVo.valX, idx = readDouble(pak, idx);
		table.push(list1,AttrVOVo);
	end

end



--[[
服务端返回结果:返回其他人武魂信息
]]

_G.RespOtherWuhunInfoRetMsg = {};

RespOtherWuhunInfoRetMsg.msgId = 8221;
RespOtherWuhunInfoRetMsg.serverType = 0; -- 是否全服排行信息 1=是 其余都不是
RespOtherWuhunInfoRetMsg.type = 0; -- 1== 详细信息，2 == 排行榜详细信息
RespOtherWuhunInfoRetMsg.roleID = ""; -- 角色ID
RespOtherWuhunInfoRetMsg.wuhunId = 0; -- 等阶
RespOtherWuhunInfoRetMsg.wuhunselectId = 0; -- 选用武魂id
RespOtherWuhunInfoRetMsg.hunzhu = 0; -- 武魂当前魂珠
RespOtherWuhunInfoRetMsg.feedNum = 0; -- 喂养次数
RespOtherWuhunInfoRetMsg.wuhunState = 0; -- 状态，0,未附身，1,俯身
RespOtherWuhunInfoRetMsg.equiplist_size = 4; -- 灵兽装备list size
RespOtherWuhunInfoRetMsg.equiplist = {}; -- 灵兽装备list list
RespOtherWuhunInfoRetMsg.attrlist_size = 0; -- 属性list size
RespOtherWuhunInfoRetMsg.attrlist = {}; -- 属性list list



--[[
ItemEquipVOVO = {
	id = 0; -- 装备tid
	groupId = 0; -- 套装id
	bind = 0; -- 0 未绑定，1 已绑定
}
]]
--[[
AttrVOVO = {
	type = 0; -- 属性
	valX = 0; -- 属性百分比
}
]]

RespOtherWuhunInfoRetMsg.meta = {__index = RespOtherWuhunInfoRetMsg};
function RespOtherWuhunInfoRetMsg:new()
	local obj = setmetatable( {}, RespOtherWuhunInfoRetMsg.meta);
	return obj;
end

function RespOtherWuhunInfoRetMsg:ParseData(pak)
	local idx = 1;

	self.serverType, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);
	self.roleID, idx = readGuid(pak, idx);
	self.wuhunId, idx = readInt(pak, idx);
	self.wuhunselectId, idx = readInt(pak, idx);
	self.hunzhu, idx = readInt(pak, idx);
	self.feedNum, idx = readInt(pak, idx);
	self.wuhunState, idx = readInt(pak, idx);

	local list = {};
	self.equiplist = list;
	local listSize = 4;

	for i=1,listSize do
		local ItemEquipVOVo = {};
		ItemEquipVOVo.id, idx = readInt(pak, idx);
		ItemEquipVOVo.groupId, idx = readInt(pak, idx);
		ItemEquipVOVo.bind, idx = readByte(pak, idx);
		table.push(list,ItemEquipVOVo);
	end

	local list1 = {};
	self.attrlist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local AttrVOVo = {};
		AttrVOVo.type, idx = readInt(pak, idx);
		AttrVOVo.valX, idx = readDouble(pak, idx);
		table.push(list1,AttrVOVo);
	end

end



--[[
服务端返回结果:组队副本伤害统计
]]

_G.RespDungeonTeamDamageMsg = {};

RespDungeonTeamDamageMsg.msgId = 8222;
RespDungeonTeamDamageMsg.damageInfo_size = 0; -- 伤害信息 size
RespDungeonTeamDamageMsg.damageInfo = {}; -- 伤害信息 list



--[[
damageInfoVO = {
	roleId = ""; -- 玩家id
	damage = 0; -- 玩家副本内造成的伤害
}
]]

RespDungeonTeamDamageMsg.meta = {__index = RespDungeonTeamDamageMsg};
function RespDungeonTeamDamageMsg:new()
	local obj = setmetatable( {}, RespDungeonTeamDamageMsg.meta);
	return obj;
end

function RespDungeonTeamDamageMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.damageInfo = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local damageInfoVo = {};
		damageInfoVo.roleId, idx = readGuid(pak, idx);
		damageInfoVo.damage, idx = readDouble(pak, idx);
		table.push(list1,damageInfoVo);
	end

end



--[[
服务器返回结果：返回设置数据
]]

_G.RespBackSetSystemMsg = {};

RespBackSetSystemMsg.msgId = 8223;
RespBackSetSystemMsg.showInfo = 0; -- 显示类型参数
RespBackSetSystemMsg.keyStr = ""; -- 按键参数



RespBackSetSystemMsg.meta = {__index = RespBackSetSystemMsg};
function RespBackSetSystemMsg:new()
	local obj = setmetatable( {}, RespBackSetSystemMsg.meta);
	return obj;
end

function RespBackSetSystemMsg:ParseData(pak)
	local idx = 1;

	self.showInfo, idx = readInt(pak, idx);
	self.keyStr, idx = readString(pak, idx, 128);

end



--[[
发送打宝活力值设置
]]

_G.RespSetDynamicDropMsg = {};

RespSetDynamicDropMsg.msgId = 8224;
RespSetDynamicDropMsg.level = 0; -- 级别,0:关闭



RespSetDynamicDropMsg.meta = {__index = RespSetDynamicDropMsg};
function RespSetDynamicDropMsg:new()
	local obj = setmetatable( {}, RespSetDynamicDropMsg.meta);
	return obj;
end

function RespSetDynamicDropMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);

end



--[[
服务端返回通知:返回时装列表
]]

_G.RespFashionsInfoMsg = {};

RespFashionsInfoMsg.msgId = 8225;
RespFashionsInfoMsg.fashionlist_size = 0; -- 时装列表 size
RespFashionsInfoMsg.fashionlist = {}; -- 时装列表 list



--[[
fashionVOVO = {
	tid = 0; -- 时装tid
	time = 0; -- 时装剩余时间
}
]]

RespFashionsInfoMsg.meta = {__index = RespFashionsInfoMsg};
function RespFashionsInfoMsg:new()
	local obj = setmetatable( {}, RespFashionsInfoMsg.meta);
	return obj;
end

function RespFashionsInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.fashionlist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local fashionVOVo = {};
		fashionVOVo.tid, idx = readInt(pak, idx);
		fashionVOVo.time, idx = readInt(pak, idx);
		table.push(list1,fashionVOVo);
	end

end



--[[
服务端返回通知:返回穿戴时装结果
]]

_G.RespDressFashionMsg = {};

RespDressFashionMsg.msgId = 8226;
RespDressFashionMsg.result = 0; -- 结果 0 - 成功，1 - 失败
RespDressFashionMsg.tid = 0; -- 时装tid
RespDressFashionMsg.type = 0; -- 操作类型 1:穿 0:脱



RespDressFashionMsg.meta = {__index = RespDressFashionMsg};
function RespDressFashionMsg:new()
	local obj = setmetatable( {}, RespDressFashionMsg.meta);
	return obj;
end

function RespDressFashionMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.tid, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
服务器返回结果：Npc挂了
]]

_G.RespUnionWarNpcHungUpMsg = {};

RespUnionWarNpcHungUpMsg.msgId = 8227;



RespUnionWarNpcHungUpMsg.meta = {__index = RespUnionWarNpcHungUpMsg};
function RespUnionWarNpcHungUpMsg:new()
	local obj = setmetatable( {}, RespUnionWarNpcHungUpMsg.meta);
	return obj;
end

function RespUnionWarNpcHungUpMsg:ParseData(pak)
	local idx = 1;


end



--[[
服务器通知：帮派战场信息
]]

_G.RespUnionWarInfoMsg = {};

RespUnionWarInfoMsg.msgId = 8228;
RespUnionWarInfoMsg.myUnionNum = 0; -- 本帮积分
RespUnionWarInfoMsg.myUnionRank = 0; -- 本帮排行
RespUnionWarInfoMsg.UnionTime = 0; -- 活动倒计时
RespUnionWarInfoMsg.skill = 0; -- 杀敌数
RespUnionWarInfoMsg.luckyRank = 0; -- 幸运排名



RespUnionWarInfoMsg.meta = {__index = RespUnionWarInfoMsg};
function RespUnionWarInfoMsg:new()
	local obj = setmetatable( {}, RespUnionWarInfoMsg.meta);
	return obj;
end

function RespUnionWarInfoMsg:ParseData(pak)
	local idx = 1;

	self.myUnionNum, idx = readInt(pak, idx);
	self.myUnionRank, idx = readInt(pak, idx);
	self.UnionTime, idx = readInt(pak, idx);
	self.skill, idx = readInt(pak, idx);
	self.luckyRank, idx = readInt(pak, idx);

end



--[[
服务器通知：帮派战场积分
]]

_G.RespUnionWarScoreMsg = {};

RespUnionWarScoreMsg.msgId = 8229;
RespUnionWarScoreMsg.type = 0; -- 1== 积分  2 == 击杀，3==个人积分
RespUnionWarScoreMsg.mySocre = 0; -- 我的积分
RespUnionWarScoreMsg.mySocreRank = 0; -- 我的个人积分排名
RespUnionWarScoreMsg.list_size = 0; -- list size
RespUnionWarScoreMsg.list = {}; -- list list



--[[
listvoVO = {
	Score = 0; -- 积分数 or 击杀数 or 个人积分
	UnionName = ""; -- 帮派名称，玩家名字
	Unionid = ""; -- 帮派id
}
]]

RespUnionWarScoreMsg.meta = {__index = RespUnionWarScoreMsg};
function RespUnionWarScoreMsg:new()
	local obj = setmetatable( {}, RespUnionWarScoreMsg.meta);
	return obj;
end

function RespUnionWarScoreMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.mySocre, idx = readInt(pak, idx);
	self.mySocreRank, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listvoVo = {};
		listvoVo.Score, idx = readInt(pak, idx);
		listvoVo.UnionName, idx = readString(pak, idx, 32);
		listvoVo.Unionid, idx = readGuid(pak, idx);
		table.push(list1,listvoVo);
	end

end



--[[
服务器通知：帮派战建筑物状态
]]

_G.RespUnionWarBuStateMsg = {};

RespUnionWarBuStateMsg.msgId = 8230;
RespUnionWarBuStateMsg.throneBelong = ""; -- 王座归属帮派名字
RespUnionWarBuStateMsg.listStatus_size = 9; -- list size
RespUnionWarBuStateMsg.listStatus = {}; -- list list



--[[
listVoStatusVO = {
	status = 0; -- 状态 0摧毁， 1 完整
}
]]

RespUnionWarBuStateMsg.meta = {__index = RespUnionWarBuStateMsg};
function RespUnionWarBuStateMsg:new()
	local obj = setmetatable( {}, RespUnionWarBuStateMsg.meta);
	return obj;
end

function RespUnionWarBuStateMsg:ParseData(pak)
	local idx = 1;

	self.throneBelong, idx = readString(pak, idx, 32);

	local list = {};
	self.listStatus = list;
	local listSize = 9;

	for i=1,listSize do
		local listVoStatusVo = {};
		listVoStatusVo.status, idx = readByte(pak, idx);
		table.push(list,listVoStatusVo);
	end

end



--[[
服务器通知：玩家通天塔的信息
]]

_G.RespBackBabelMsg = {};

RespBackBabelMsg.msgId = 8231;
RespBackBabelMsg.maxLayer = 0; -- 当前挑战最高层
RespBackBabelMsg.layer = 0; -- 返回的是第几层
RespBackBabelMsg.maxTier = ""; -- 最佳通关人物的名字
RespBackBabelMsg.minTime = 0; -- 最佳通关时间
RespBackBabelMsg.myTime = 0; -- 我的时间
RespBackBabelMsg.num = 0; -- 我剩余的次数
RespBackBabelMsg.daikyNum = 0; -- 我剩余的每日总次数



RespBackBabelMsg.meta = {__index = RespBackBabelMsg};
function RespBackBabelMsg:new()
	local obj = setmetatable( {}, RespBackBabelMsg.meta);
	return obj;
end

function RespBackBabelMsg:ParseData(pak)
	local idx = 1;

	self.maxLayer, idx = readInt(pak, idx);
	self.layer, idx = readInt(pak, idx);
	self.maxTier, idx = readString(pak, idx, 32);
	self.minTime, idx = readInt(pak, idx);
	self.myTime, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);
	self.daikyNum, idx = readInt(pak, idx);

end



--[[
服务器通知：通天塔排行榜信息
]]

_G.RespBackRankingListInfoMsg = {};

RespBackRankingListInfoMsg.msgId = 8232;
RespBackRankingListInfoMsg.list_size = 10; -- 排行列表 size
RespBackRankingListInfoMsg.list = {}; -- 排行列表 list



--[[
listvoVO = {
	name = ""; -- 名称
	level = 0; -- 人物等级
	tier = 0; -- 通关层数
}
]]

RespBackRankingListInfoMsg.meta = {__index = RespBackRankingListInfoMsg};
function RespBackRankingListInfoMsg:new()
	local obj = setmetatable( {}, RespBackRankingListInfoMsg.meta);
	return obj;
end

function RespBackRankingListInfoMsg:ParseData(pak)
	local idx = 1;


	local list = {};
	self.list = list;
	local listSize = 10;

	for i=1,listSize do
		local listvoVo = {};
		listvoVo.name, idx = readString(pak, idx, 32);
		listvoVo.level, idx = readInt(pak, idx);
		listvoVo.tier, idx = readInt(pak, idx);
		table.push(list,listvoVo);
	end

end



--[[
服务器通知：进入通天塔
]]

_G.RespBackBabelNowInfoMsg = {};

RespBackBabelNowInfoMsg.msgId = 8233;
RespBackBabelNowInfoMsg.result = 0; -- 进入结果 0成功 -1 总次数不足 -2 层数错误 -3层数次数不足 -4功能未开启 -5创建ing -6处于活动场景 -7等级不足 -8队伍状态
RespBackBabelNowInfoMsg.layer = 0; -- 进入层数
RespBackBabelNowInfoMsg.state = 0; -- 是否是第一次 0 不是  1是



RespBackBabelNowInfoMsg.meta = {__index = RespBackBabelNowInfoMsg};
function RespBackBabelNowInfoMsg:new()
	local obj = setmetatable( {}, RespBackBabelNowInfoMsg.meta);
	return obj;
end

function RespBackBabelNowInfoMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.layer, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
服务器通知：通关结果
]]

_G.RespBackBabelResultMsg = {};

RespBackBabelResultMsg.msgId = 8234;
RespBackBabelResultMsg.state = 0; -- 失败成功 0 失败 1成功 2首次通关
RespBackBabelResultMsg.rewardList_size = 0; -- 列表 size
RespBackBabelResultMsg.rewardList = {}; -- 列表 list



--[[
rewardVOVO = {
	id = 0; -- 物品ID
	num = 0; -- 数量
}
]]

RespBackBabelResultMsg.meta = {__index = RespBackBabelResultMsg};
function RespBackBabelResultMsg:new()
	local obj = setmetatable( {}, RespBackBabelResultMsg.meta);
	return obj;
end

function RespBackBabelResultMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);

	local list1 = {};
	self.rewardList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local rewardVOVo = {};
		rewardVOVo.id, idx = readInt(pak, idx);
		rewardVOVo.num, idx = readInt(pak, idx);
		table.push(list1,rewardVOVo);
	end

end



--[[
服务器通知：退出通天塔
]]

_G.RespBackBabelOutMsg = {};

RespBackBabelOutMsg.msgId = 8235;
RespBackBabelOutMsg.state = 0; -- 退出的结果 0 失败 1 成功



RespBackBabelOutMsg.meta = {__index = RespBackBabelOutMsg};
function RespBackBabelOutMsg:new()
	local obj = setmetatable( {}, RespBackBabelOutMsg.meta);
	return obj;
end

function RespBackBabelOutMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);

end



--[[
服务器通知：每日杀戮值
]]

_G.RespKillingValueMsg = {};

RespKillingValueMsg.msgId = 8236;
RespKillingValueMsg.killingValue = 0; -- 每日杀戮值
RespKillingValueMsg.flag = 0; -- 0:没有增加属性, 1:增加了属性, 用于显示属性增加提示框



RespKillingValueMsg.meta = {__index = RespKillingValueMsg};
function RespKillingValueMsg:new()
	local obj = setmetatable( {}, RespKillingValueMsg.meta);
	return obj;
end

function RespKillingValueMsg:ParseData(pak)
	local idx = 1;

	self.killingValue, idx = readInt(pak, idx);
	self.flag, idx = readInt(pak, idx);

end



--[[
返回装备卓越信息
]]

_G.RespEquipSuperMsg = {};

RespEquipSuperMsg.msgId = 8239;
RespEquipSuperMsg.list_size = 0; -- 装备list size
RespEquipSuperMsg.list = {}; -- 装备list list



--[[
EquipSuperListVOVO = {
	id = ""; -- 装备cid
	superNum = 0; -- 卓越数量
	superList_size = 7; -- 卓越属性列表 size
	superList = {}; -- 卓越属性列表 list
}
SuperVOVO = {
	uid = ""; -- 属性uid
	id = 0; -- 卓越id
	val1 = 0; -- 值1
}
]]

RespEquipSuperMsg.meta = {__index = RespEquipSuperMsg};
function RespEquipSuperMsg:new()
	local obj = setmetatable( {}, RespEquipSuperMsg.meta);
	return obj;
end

function RespEquipSuperMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local EquipSuperListVOVo = {};
		EquipSuperListVOVo.id, idx = readGuid(pak, idx);
		EquipSuperListVOVo.superNum, idx = readInt(pak, idx);
		table.push(list1,EquipSuperListVOVo);

		local list2 = {};
		EquipSuperListVOVo.superList = list2;
		local list2Size = 7;

		for i=1,list2Size do
			local SuperVOVo = {};
			SuperVOVo.uid, idx = readGuid(pak, idx);
			SuperVOVo.id, idx = readInt(pak, idx);
			SuperVOVo.val1, idx = readInt(pak, idx);
			table.push(list2,SuperVOVo);
		end
	end

end



--[[
返回装备卓越孔信息
]]

_G.RespEquipSuperHoleMsg = {};

RespEquipSuperHoleMsg.msgId = 8240;
RespEquipSuperHoleMsg.list_size = 0; -- 列表 size
RespEquipSuperHoleMsg.list = {}; -- 列表 list



--[[
SuperHoleListVOVO = {
	pos = 0; -- 装备位
	holeList_size = 5; -- 孔列表 size
	holeList = {}; -- 孔列表 list
}
SuperHoleVOVO = {
	index = 0; -- 孔索引 从1开始
	level = 0; -- 孔等级
}
]]

RespEquipSuperHoleMsg.meta = {__index = RespEquipSuperHoleMsg};
function RespEquipSuperHoleMsg:new()
	local obj = setmetatable( {}, RespEquipSuperHoleMsg.meta);
	return obj;
end

function RespEquipSuperHoleMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local SuperHoleListVOVo = {};
		SuperHoleListVOVo.pos, idx = readInt(pak, idx);
		table.push(list1,SuperHoleListVOVo);

		local list2 = {};
		SuperHoleListVOVo.holeList = list2;
		local list2Size = 5;

		for i=1,list2Size do
			local SuperHoleVOVo = {};
			SuperHoleVOVo.index, idx = readInt(pak, idx);
			SuperHoleVOVo.level, idx = readInt(pak, idx);
			table.push(list2,SuperHoleVOVo);
		end
	end

end



--[[
返回卓越孔升级
]]

_G.RespSuperHoleUpMsg = {};

RespSuperHoleUpMsg.msgId = 8241;
RespSuperHoleUpMsg.pos = 0; -- 装备位
RespSuperHoleUpMsg.index = 0; -- 孔索引 从1开始
RespSuperHoleUpMsg.level = 0; -- 孔等级



RespSuperHoleUpMsg.meta = {__index = RespSuperHoleUpMsg};
function RespSuperHoleUpMsg:new()
	local obj = setmetatable( {}, RespSuperHoleUpMsg.meta);
	return obj;
end

function RespSuperHoleUpMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readInt(pak, idx);
	self.index, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);

end



--[[
返回卓越属性库
]]

_G.RespSuperLibMsg = {};

RespSuperLibMsg.msgId = 8242;
RespSuperLibMsg.list_size = 0; -- 列表 size
RespSuperLibMsg.list = {}; -- 列表 list



--[[
SuperLibVOVO = {
	uid = ""; -- 属性uid
	id = 0; -- 卓越id
	val1 = 0; -- 值1
}
]]

RespSuperLibMsg.meta = {__index = RespSuperLibMsg};
function RespSuperLibMsg:new()
	local obj = setmetatable( {}, RespSuperLibMsg.meta);
	return obj;
end

function RespSuperLibMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local SuperLibVOVo = {};
		SuperLibVOVo.uid, idx = readGuid(pak, idx);
		SuperLibVOVo.id, idx = readInt(pak, idx);
		SuperLibVOVo.val1, idx = readInt(pak, idx);
		table.push(list1,SuperLibVOVo);
	end

end



--[[
返回卸载卓越属性
]]

_G.RespSuperAttrDownMsg = {};

RespSuperAttrDownMsg.msgId = 8243;
RespSuperAttrDownMsg.result = 0; -- 0成功,1库已满
RespSuperAttrDownMsg.eid = ""; -- 装备uid
RespSuperAttrDownMsg.index = 0; -- 孔索引 从1开始



RespSuperAttrDownMsg.meta = {__index = RespSuperAttrDownMsg};
function RespSuperAttrDownMsg:new()
	local obj = setmetatable( {}, RespSuperAttrDownMsg.meta);
	return obj;
end

function RespSuperAttrDownMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.eid, idx = readGuid(pak, idx);
	self.index, idx = readInt(pak, idx);

end



--[[
返回安装卓越属性
]]

_G.RespSuperAttrUpMsg = {};

RespSuperAttrUpMsg.msgId = 8244;
RespSuperAttrUpMsg.result = 0; -- 0成功,1非法孔
RespSuperAttrUpMsg.uid = ""; -- 属性uid
RespSuperAttrUpMsg.eid = ""; -- 装备uid
RespSuperAttrUpMsg.index = 0; -- 孔索引 从1开始



RespSuperAttrUpMsg.meta = {__index = RespSuperAttrUpMsg};
function RespSuperAttrUpMsg:new()
	local obj = setmetatable( {}, RespSuperAttrUpMsg.meta);
	return obj;
end

function RespSuperAttrUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.uid, idx = readGuid(pak, idx);
	self.eid, idx = readGuid(pak, idx);
	self.index, idx = readInt(pak, idx);

end



--[[
返回从卓越属性库删除
]]

_G.RespSuperLibRemoveMsg = {};

RespSuperLibRemoveMsg.msgId = 8245;
RespSuperLibRemoveMsg.list_size = 0; -- 列表 size
RespSuperLibRemoveMsg.list = {}; -- 列表 list



--[[
EquipExtraVOVO = {
	uid = ""; -- 属性uid
	result = 0; -- 0成功
}
]]

RespSuperLibRemoveMsg.meta = {__index = RespSuperLibRemoveMsg};
function RespSuperLibRemoveMsg:new()
	local obj = setmetatable( {}, RespSuperLibRemoveMsg.meta);
	return obj;
end

function RespSuperLibRemoveMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local EquipExtraVOVo = {};
		EquipExtraVOVo.uid, idx = readGuid(pak, idx);
		EquipExtraVOVo.result, idx = readInt(pak, idx);
		table.push(list1,EquipExtraVOVo);
	end

end



--[[
返回装备追加属性信息
]]

_G.RespEquipEquipExtraMsg = {};

RespEquipEquipExtraMsg.msgId = 8246;
RespEquipEquipExtraMsg.list_size = 0; -- 列表 size
RespEquipEquipExtraMsg.list = {}; -- 列表 list



--[[
EquipExtraVOVO = {
	id = ""; -- 装备cid
	level = 0; -- 追加属性等级
}
]]

RespEquipEquipExtraMsg.meta = {__index = RespEquipEquipExtraMsg};
function RespEquipEquipExtraMsg:new()
	local obj = setmetatable( {}, RespEquipEquipExtraMsg.meta);
	return obj;
end

function RespEquipEquipExtraMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local EquipExtraVOVo = {};
		EquipExtraVOVo.id, idx = readGuid(pak, idx);
		EquipExtraVOVo.level, idx = readInt(pak, idx);
		table.push(list1,EquipExtraVOVo);
	end

end



--[[
返回追加属性传承
]]

_G.RespEquipExtraInheritMsg = {};

RespEquipExtraInheritMsg.msgId = 8247;
RespEquipExtraInheritMsg.result = 0; -- 0成功
RespEquipExtraInheritMsg.srcId = ""; -- 源cid
RespEquipExtraInheritMsg.tarId = ""; -- 目标cid



RespEquipExtraInheritMsg.meta = {__index = RespEquipExtraInheritMsg};
function RespEquipExtraInheritMsg:new()
	local obj = setmetatable( {}, RespEquipExtraInheritMsg.meta);
	return obj;
end

function RespEquipExtraInheritMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.srcId, idx = readGuid(pak, idx);
	self.tarId, idx = readGuid(pak, idx);

end



--[[
服务器通知:神兵信息
]]

_G.RespMagicWeaponInfoMsg = {};

RespMagicWeaponInfoMsg.msgId = 8248;
RespMagicWeaponInfoMsg.level = 0; -- 神兵等阶
RespMagicWeaponInfoMsg.modelLevel = 0; -- 神兵使用模型的等阶(≤神兵等阶)
RespMagicWeaponInfoMsg.proficiency = 0; -- 神兵熟练度
RespMagicWeaponInfoMsg.lvlProficiency = 0; -- 熟练度等级
RespMagicWeaponInfoMsg.blessing = 0; -- 进阶祝福值
RespMagicWeaponInfoMsg.pillNum = 0; -- 属性丹数量



RespMagicWeaponInfoMsg.meta = {__index = RespMagicWeaponInfoMsg};
function RespMagicWeaponInfoMsg:new()
	local obj = setmetatable( {}, RespMagicWeaponInfoMsg.meta);
	return obj;
end

function RespMagicWeaponInfoMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);
	self.modelLevel, idx = readInt(pak, idx);
	self.proficiency, idx = readInt(pak, idx);
	self.lvlProficiency, idx = readInt(pak, idx);
	self.blessing, idx = readInt(pak, idx);
	self.pillNum, idx = readInt(pak, idx);

end



--[[
服务器通知:神兵熟练度
]]

_G.ReqMagicWeaponProficiencyMsg = {};

ReqMagicWeaponProficiencyMsg.msgId = 8249;
ReqMagicWeaponProficiencyMsg.proficiency = 0; -- 神兵熟练度



ReqMagicWeaponProficiencyMsg.meta = {__index = ReqMagicWeaponProficiencyMsg};
function ReqMagicWeaponProficiencyMsg:new()
	local obj = setmetatable( {}, ReqMagicWeaponProficiencyMsg.meta);
	return obj;
end

function ReqMagicWeaponProficiencyMsg:ParseData(pak)
	local idx = 1;

	self.proficiency, idx = readInt(pak, idx);

end



--[[
服务器返回：神兵进阶
]]

_G.RespMagicWeaponLevelUpMsg = {};

RespMagicWeaponLevelUpMsg.msgId = 8250;
RespMagicWeaponLevelUpMsg.result = 0; -- 请求进阶结果 0:成功(成功获得祝福值), 2:神兵未解锁, 3:已达等级上限, 4:熟练度不够, 5:金币不够, 6:道具数量不足
RespMagicWeaponLevelUpMsg.blessing = 0; -- 进阶后的祝福值



RespMagicWeaponLevelUpMsg.meta = {__index = RespMagicWeaponLevelUpMsg};
function RespMagicWeaponLevelUpMsg:new()
	local obj = setmetatable( {}, RespMagicWeaponLevelUpMsg.meta);
	return obj;
end

function RespMagicWeaponLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.blessing, idx = readInt(pak, idx);

end



--[[
返回进入时间副本
]]

_G.RespBackEnterTimeDungeonMsg = {};

RespBackEnterTimeDungeonMsg.msgId = 8251;
RespBackEnterTimeDungeonMsg.result = 0; -- 进入结果 1:成功 -1:id错误 -2 次数不足 -3 等级不足 -4 不是队长 -5 物品不足 -6时间未开启 -7场景错误 -8功能未开启
RespBackEnterTimeDungeonMsg.state = 0; -- 进入难度：1 普通 2 困难 3 噩梦 4 神话 5 传说



RespBackEnterTimeDungeonMsg.meta = {__index = RespBackEnterTimeDungeonMsg};
function RespBackEnterTimeDungeonMsg:new()
	local obj = setmetatable( {}, RespBackEnterTimeDungeonMsg.meta);
	return obj;
end

function RespBackEnterTimeDungeonMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
返回退出时间副本
]]

_G.RespBackQuitTimeDungeonMsg = {};

RespBackQuitTimeDungeonMsg.msgId = 8252;
RespBackQuitTimeDungeonMsg.result = 0; -- 退出结果 0:失败, 1:成功



RespBackQuitTimeDungeonMsg.meta = {__index = RespBackQuitTimeDungeonMsg};
function RespBackQuitTimeDungeonMsg:new()
	local obj = setmetatable( {}, RespBackQuitTimeDungeonMsg.meta);
	return obj;
end

function RespBackQuitTimeDungeonMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回时间副本信息
]]

_G.RespBackTimeDungeonRewardMsg = {};

RespBackTimeDungeonRewardMsg.msgId = 8253;
RespBackTimeDungeonRewardMsg.exp = 0; -- 杀怪经验
RespBackTimeDungeonRewardMsg.num = 0; -- 杀怪个数



RespBackTimeDungeonRewardMsg.meta = {__index = RespBackTimeDungeonRewardMsg};
function RespBackTimeDungeonRewardMsg:new()
	local obj = setmetatable( {}, RespBackTimeDungeonRewardMsg.meta);
	return obj;
end

function RespBackTimeDungeonRewardMsg:ParseData(pak)
	local idx = 1;

	self.exp, idx = readInt64(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
返回副本通关结果
]]

_G.RespBackTimeDungeonInfoMsg = {};

RespBackTimeDungeonInfoMsg.msgId = 8254;
RespBackTimeDungeonInfoMsg.result = 0; -- 返回结果 0 失败 1 成功
RespBackTimeDungeonInfoMsg.exp = 0; -- 累积经验
RespBackTimeDungeonInfoMsg.time = 0; -- 通关时间



RespBackTimeDungeonInfoMsg.meta = {__index = RespBackTimeDungeonInfoMsg};
function RespBackTimeDungeonInfoMsg:new()
	local obj = setmetatable( {}, RespBackTimeDungeonInfoMsg.meta);
	return obj;
end

function RespBackTimeDungeonInfoMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.exp, idx = readInt64(pak, idx);
	self.time, idx = readInt(pak, idx);

end



--[[
返回时间副本波数
]]

_G.RespBackTimeDungeonNumMsg = {};

RespBackTimeDungeonNumMsg.msgId = 8255;
RespBackTimeDungeonNumMsg.num = 0; -- 怪物波数
RespBackTimeDungeonNumMsg.monID = 0; -- 怪物ID
RespBackTimeDungeonNumMsg.monNum = 0; -- 怪物个数



RespBackTimeDungeonNumMsg.meta = {__index = RespBackTimeDungeonNumMsg};
function RespBackTimeDungeonNumMsg:new()
	local obj = setmetatable( {}, RespBackTimeDungeonNumMsg.meta);
	return obj;
end

function RespBackTimeDungeonNumMsg:ParseData(pak)
	local idx = 1;

	self.num, idx = readInt(pak, idx);
	self.monID, idx = readInt(pak, idx);
	self.monNum, idx = readInt(pak, idx);

end



--[[
返回时间副本次数
]]

_G.RespBackDungeonNumMsg = {};

RespBackDungeonNumMsg.msgId = 8257;
RespBackDungeonNumMsg.num = 0; -- 剩余次数



RespBackDungeonNumMsg.meta = {__index = RespBackDungeonNumMsg};
function RespBackDungeonNumMsg:new()
	local obj = setmetatable( {}, RespBackDungeonNumMsg.meta);
	return obj;
end

function RespBackDungeonNumMsg:ParseData(pak)
	local idx = 1;

	self.num, idx = readInt(pak, idx);

end



--[[
服务器通知：帮派战结算奖励
]]

_G.RespUnionWarRewardMsg = {};

RespUnionWarRewardMsg.msgId = 8256;
RespUnionWarRewardMsg.isfirst = 0; -- 是否第一次帮派战 0 是， 1 不是
RespUnionWarRewardMsg.luaRank = 0; -- 幸运排名
RespUnionWarRewardMsg.ranklist_size = 0; -- list size
RespUnionWarRewardMsg.ranklist = {}; -- list list



--[[
listvoVO = {
	Id = ""; -- 帮派ID
	Score = 0; -- 积分数 or 击杀数
	UnionName = ""; -- 帮派名称
	isqua = 0; -- 是否获得资格,0未获得，1进攻，2防守
}
]]

RespUnionWarRewardMsg.meta = {__index = RespUnionWarRewardMsg};
function RespUnionWarRewardMsg:new()
	local obj = setmetatable( {}, RespUnionWarRewardMsg.meta);
	return obj;
end

function RespUnionWarRewardMsg:ParseData(pak)
	local idx = 1;

	self.isfirst, idx = readInt(pak, idx);
	self.luaRank, idx = readInt(pak, idx);

	local list1 = {};
	self.ranklist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listvoVo = {};
		listvoVo.Id, idx = readGuid(pak, idx);
		listvoVo.Score, idx = readInt(pak, idx);
		listvoVo.UnionName, idx = readString(pak, idx, 32);
		listvoVo.isqua, idx = readByte(pak, idx);
		table.push(list1,listvoVo);
	end

end



--[[
返回离线时间
]]

_G.RespOutLineTimeMsg = {};

RespOutLineTimeMsg.msgId = 8258;
RespOutLineTimeMsg.time = 0; -- 离线时间



RespOutLineTimeMsg.meta = {__index = RespOutLineTimeMsg};
function RespOutLineTimeMsg:new()
	local obj = setmetatable( {}, RespOutLineTimeMsg.meta);
	return obj;
end

function RespOutLineTimeMsg:ParseData(pak)
	local idx = 1;

	self.time, idx = readInt(pak, idx);

end



--[[
返回离线奖励结果
]]

_G.RespGetOutLineRewardMsg = {};

RespGetOutLineRewardMsg.msgId = 8259;
RespGetOutLineRewardMsg.result = 0; -- 结果 0 成功，1 失败
RespGetOutLineRewardMsg.type = 0; -- 1 基本收益，2 双倍收益，3 三倍收益



RespGetOutLineRewardMsg.meta = {__index = RespGetOutLineRewardMsg};
function RespGetOutLineRewardMsg:new()
	local obj = setmetatable( {}, RespGetOutLineRewardMsg.meta);
	return obj;
end

function RespGetOutLineRewardMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
返回活跃度信息
]]

_G.RespHuoYueDuMsg = {};

RespHuoYueDuMsg.msgId = 8260;
RespHuoYueDuMsg.exp = 0; -- 当前经验
RespHuoYueDuMsg.level = 0; -- 当前等级
RespHuoYueDuMsg.list_size = 0; -- 活跃度值 size
RespHuoYueDuMsg.list = {}; -- 活跃度值 list



--[[
voVO = {
	id = 0; -- 活跃任务id
	num = 0; -- 活跃度完成数
}
]]

RespHuoYueDuMsg.meta = {__index = RespHuoYueDuMsg};
function RespHuoYueDuMsg:new()
	local obj = setmetatable( {}, RespHuoYueDuMsg.meta);
	return obj;
end

function RespHuoYueDuMsg:ParseData(pak)
	local idx = 1;

	self.exp, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local voVo = {};
		voVo.id, idx = readInt(pak, idx);
		voVo.num, idx = readInt(pak, idx);
		table.push(list1,voVo);
	end

end



--[[
返回活跃度任务完成一次
]]

_G.RespHuoYueDuFinishMsg = {};

RespHuoYueDuFinishMsg.msgId = 8261;
RespHuoYueDuFinishMsg.id = 0; -- 活跃任务id
RespHuoYueDuFinishMsg.num = 0; -- 该活跃任务完成总数量
RespHuoYueDuFinishMsg.exp = 0; -- 当前经验



RespHuoYueDuFinishMsg.meta = {__index = RespHuoYueDuFinishMsg};
function RespHuoYueDuFinishMsg:new()
	local obj = setmetatable( {}, RespHuoYueDuFinishMsg.meta);
	return obj;
end

function RespHuoYueDuFinishMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);
	self.exp, idx = readInt(pak, idx);

end



--[[
返回活跃度升级结果
]]

_G.RespHuoYueLevelupMsg = {};

RespHuoYueLevelupMsg.msgId = 8262;
RespHuoYueLevelupMsg.result = 0; -- 结果 0 成功，1 失败
RespHuoYueLevelupMsg.exp = 0; -- 当前经验
RespHuoYueLevelupMsg.level = 0; -- 当前等级



RespHuoYueLevelupMsg.meta = {__index = RespHuoYueLevelupMsg};
function RespHuoYueLevelupMsg:new()
	local obj = setmetatable( {}, RespHuoYueLevelupMsg.meta);
	return obj;
end

function RespHuoYueLevelupMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.exp, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);

end



--[[
返回剧情结束
]]

_G.RespStoryEndMsg = {};

RespStoryEndMsg.msgId = 8263;
RespStoryEndMsg.result = 0; -- 结果 0 成功，1 失败
RespStoryEndMsg.type = 0; -- 剧情类型：1 通天塔；



RespStoryEndMsg.meta = {__index = RespStoryEndMsg};
function RespStoryEndMsg:new()
	local obj = setmetatable( {}, RespStoryEndMsg.meta);
	return obj;
end

function RespStoryEndMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
返回任务奖励装备提升结果
]]

_G.RespQuestEquipPromoteMsg = {};

RespQuestEquipPromoteMsg.msgId = 8264;
RespQuestEquipPromoteMsg.questId = 0; -- 任务id
RespQuestEquipPromoteMsg.newId = 0; -- 新装备tid
RespQuestEquipPromoteMsg.newCid = ""; -- 新装备cid
RespQuestEquipPromoteMsg.oldId = 0; -- 原装备tid



RespQuestEquipPromoteMsg.meta = {__index = RespQuestEquipPromoteMsg};
function RespQuestEquipPromoteMsg:new()
	local obj = setmetatable( {}, RespQuestEquipPromoteMsg.meta);
	return obj;
end

function RespQuestEquipPromoteMsg:ParseData(pak)
	local idx = 1;

	self.questId, idx = readInt(pak, idx);
	self.newId, idx = readInt(pak, idx);
	self.newCid, idx = readGuid(pak, idx);
	self.oldId, idx = readInt(pak, idx);

end



--[[
返回时间副本开始计时
]]

_G.RespBackDungeonTimeStartMsg = {};

RespBackDungeonTimeStartMsg.msgId = 8265;
RespBackDungeonTimeStartMsg.timeNum = 0; -- 返回总时间



RespBackDungeonTimeStartMsg.meta = {__index = RespBackDungeonTimeStartMsg};
function RespBackDungeonTimeStartMsg:new()
	local obj = setmetatable( {}, RespBackDungeonTimeStartMsg.meta);
	return obj;
end

function RespBackDungeonTimeStartMsg:ParseData(pak)
	local idx = 1;

	self.timeNum, idx = readInt(pak, idx);

end



--[[
服务器通知：返回抽奖索引
]]

_G.RespBackRewardIndexMsg = {};

RespBackRewardIndexMsg.msgId = 8285;
RespBackRewardIndexMsg.timeIndex = 0; -- 索引0123
RespBackRewardIndexMsg.index = 0; -- 索引0123456



RespBackRewardIndexMsg.meta = {__index = RespBackRewardIndexMsg};
function RespBackRewardIndexMsg:new()
	local obj = setmetatable( {}, RespBackRewardIndexMsg.meta);
	return obj;
end

function RespBackRewardIndexMsg:ParseData(pak)
	local idx = 1;

	self.timeIndex, idx = readInt(pak, idx);
	self.index, idx = readInt(pak, idx);

end



--[[
服务器通知：返回抽奖次数
]]

_G.RespBackRewardNumMsg = {};

RespBackRewardNumMsg.msgId = 8286;
RespBackRewardNumMsg.time = 0; -- 时间
RespBackRewardNumMsg.indexString = ""; -- 已抽索引



RespBackRewardNumMsg.meta = {__index = RespBackRewardNumMsg};
function RespBackRewardNumMsg:new()
	local obj = setmetatable( {}, RespBackRewardNumMsg.meta);
	return obj;
end

function RespBackRewardNumMsg:ParseData(pak)
	local idx = 1;

	self.time, idx = readInt(pak, idx);
	self.indexString, idx = readString(pak, idx, 64);

end



--[[
服务端通知:返回境界信息
]]

_G.RespJingJieInfoMsg = {};

RespJingJieInfoMsg.msgId = 8289;
RespJingJieInfoMsg.jingjieOrder = 0; -- 境界等阶
RespJingJieInfoMsg.jingjieStar = 0; -- 境界星级
RespJingJieInfoMsg.starProgress = 0; -- 星级进度
RespJingJieInfoMsg.breakProgress = 0; -- 突破进度



RespJingJieInfoMsg.meta = {__index = RespJingJieInfoMsg};
function RespJingJieInfoMsg:new()
	local obj = setmetatable( {}, RespJingJieInfoMsg.meta);
	return obj;
end

function RespJingJieInfoMsg:ParseData(pak)
	local idx = 1;

	self.jingjieOrder, idx = readInt(pak, idx);
	self.jingjieStar, idx = readInt(pak, idx);
	self.starProgress, idx = readInt(pak, idx);
	self.breakProgress, idx = readInt(pak, idx);

end



--[[
服务器通知：返回修炼境界进度
]]

_G.RespPracticeResultMsg = {};

RespPracticeResultMsg.msgId = 8290;
RespPracticeResultMsg.result = 0; -- 返回结果 0:成功, 2:已达修炼度上限, 3:真气不够...
RespPracticeResultMsg.jingjieOrder = 0; -- 境界等阶
RespPracticeResultMsg.jingjieStar = 0; -- 境界星级
RespPracticeResultMsg.practiceNum = 0; -- 修炼次数
RespPracticeResultMsg.practiceProgress = 0; -- 修炼进度



RespPracticeResultMsg.meta = {__index = RespPracticeResultMsg};
function RespPracticeResultMsg:new()
	local obj = setmetatable( {}, RespPracticeResultMsg.meta);
	return obj;
end

function RespPracticeResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.jingjieOrder, idx = readInt(pak, idx);
	self.jingjieStar, idx = readInt(pak, idx);
	self.practiceNum, idx = readInt(pak, idx);
	self.practiceProgress, idx = readInt(pak, idx);

end



--[[
服务器通知：返回破境值
]]

_G.RespBreakJingjieResultMsg = {};

RespBreakJingjieResultMsg.msgId = 8291;
RespBreakJingjieResultMsg.result = 0; -- 返回结果 0:成功, 2:已达等阶上限, 3:修炼度不够, 4:银两不够, 5:道具数量不足...
RespBreakJingjieResultMsg.jingjieOrder = 0; -- 境界等阶
RespBreakJingjieResultMsg.breakProgress = 0; -- 突破进度



RespBreakJingjieResultMsg.meta = {__index = RespBreakJingjieResultMsg};
function RespBreakJingjieResultMsg:new()
	local obj = setmetatable( {}, RespBreakJingjieResultMsg.meta);
	return obj;
end

function RespBreakJingjieResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.jingjieOrder, idx = readInt(pak, idx);
	self.breakProgress, idx = readInt(pak, idx);

end



--[[
服务器通知：返回境界升阶成功
]]

_G.RespJingjieOrderSuccessMsg = {};

RespJingjieOrderSuccessMsg.msgId = 8292;
RespJingjieOrderSuccessMsg.jingjieOrder = 0; -- 境界等阶



RespJingjieOrderSuccessMsg.meta = {__index = RespJingjieOrderSuccessMsg};
function RespJingjieOrderSuccessMsg:new()
	local obj = setmetatable( {}, RespJingjieOrderSuccessMsg.meta);
	return obj;
end

function RespJingjieOrderSuccessMsg:ParseData(pak)
	local idx = 1;

	self.jingjieOrder, idx = readInt(pak, idx);

end



--[[
服务器通知：限时副本信息
]]

_G.RespBackExtremityInfoMsg = {};

RespBackExtremityInfoMsg.msgId = 8293;
RespBackExtremityInfoMsg.bossNum = 0; -- 我的BOSS个数
RespBackExtremityInfoMsg.monsterNum = 0; -- 我的怪物个数
RespBackExtremityInfoMsg.num = 0; -- 剩余进入次数
RespBackExtremityInfoMsg.headID = 0; -- 第一名头像
RespBackExtremityInfoMsg.list_size = 10; -- 排行列表 size
RespBackExtremityInfoMsg.list = {}; -- 排行列表 list



--[[
listvoVO = {
	bossNum = 0; -- BOSS个数
	monsterNum = 0; -- 怪物个数
	name = ""; -- 名称
}
]]

RespBackExtremityInfoMsg.meta = {__index = RespBackExtremityInfoMsg};
function RespBackExtremityInfoMsg:new()
	local obj = setmetatable( {}, RespBackExtremityInfoMsg.meta);
	return obj;
end

function RespBackExtremityInfoMsg:ParseData(pak)
	local idx = 1;

	self.bossNum, idx = readInt(pak, idx);
	self.monsterNum, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);
	self.headID, idx = readInt(pak, idx);

	local list = {};
	self.list = list;
	local listSize = 10;

	for i=1,listSize do
		local listvoVo = {};
		listvoVo.bossNum, idx = readInt(pak, idx);
		listvoVo.monsterNum, idx = readInt(pak, idx);
		listvoVo.name, idx = readString(pak, idx, 32);
		table.push(list,listvoVo);
	end

end



--[[
服务器通知：进入限时副本
]]

_G.RespEnterExtremityMsg = {};

RespEnterExtremityMsg.msgId = 8294;
RespEnterExtremityMsg.result = 0; --  0 失败 1 成功



RespEnterExtremityMsg.meta = {__index = RespEnterExtremityMsg};
function RespEnterExtremityMsg:new()
	local obj = setmetatable( {}, RespEnterExtremityMsg.meta);
	return obj;
end

function RespEnterExtremityMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器通知：退出结果
]]

_G.RespBackQuitExtremityMsg = {};

RespBackQuitExtremityMsg.msgId = 8295;
RespBackQuitExtremityMsg.result = 0; -- 1成功



RespBackQuitExtremityMsg.meta = {__index = RespBackQuitExtremityMsg};
function RespBackQuitExtremityMsg:new()
	local obj = setmetatable( {}, RespBackQuitExtremityMsg.meta);
	return obj;
end

function RespBackQuitExtremityMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器通知：击杀信息
]]

_G.RespBackKillInfoMsg = {};

RespBackKillInfoMsg.msgId = 8297;
RespBackKillInfoMsg.monster = 0; -- 小怪
RespBackKillInfoMsg.boss = 0; -- boss



RespBackKillInfoMsg.meta = {__index = RespBackKillInfoMsg};
function RespBackKillInfoMsg:new()
	local obj = setmetatable( {}, RespBackKillInfoMsg.meta);
	return obj;
end

function RespBackKillInfoMsg:ParseData(pak)
	local idx = 1;

	self.monster, idx = readInt(pak, idx);
	self.boss, idx = readInt(pak, idx);

end



--[[
服务器通知：通关奖励
]]

_G.RespBackExtremitRewardMsg = {};

RespBackExtremitRewardMsg.msgId = 8298;
RespBackExtremitRewardMsg.bossNum = 0; -- boss
RespBackExtremitRewardMsg.monsterNum = 0; -- 小怪
RespBackExtremitRewardMsg.dieNum = 0; -- 死亡次数
RespBackExtremitRewardMsg.list_size = 0; -- 奖励列表 size
RespBackExtremitRewardMsg.list = {}; -- 奖励列表 list



--[[
listvoVO = {
	rewardID = 0; -- 奖励ID
	num = 0; -- 个数
}
]]

RespBackExtremitRewardMsg.meta = {__index = RespBackExtremitRewardMsg};
function RespBackExtremitRewardMsg:new()
	local obj = setmetatable( {}, RespBackExtremitRewardMsg.meta);
	return obj;
end

function RespBackExtremitRewardMsg:ParseData(pak)
	local idx = 1;

	self.bossNum, idx = readInt(pak, idx);
	self.monsterNum, idx = readInt(pak, idx);
	self.dieNum, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listvoVo = {};
		listvoVo.rewardID, idx = readInt(pak, idx);
		listvoVo.num, idx = readInt(pak, idx);
		table.push(list1,listvoVo);
	end

end



--[[
服务器通知：返回帮派王城战总信息
]]

_G.RespUnionCityWarAllInfoMsg = {};

RespUnionCityWarAllInfoMsg.msgId = 8299;
RespUnionCityWarAllInfoMsg.SuperMaxHp = 0; -- 王座最大血量
RespUnionCityWarAllInfoMsg.time = 0; -- 活动剩余时间
RespUnionCityWarAllInfoMsg.mytype = 0; -- 1=进攻方  2=防守方
RespUnionCityWarAllInfoMsg.atkUnionName = ""; -- 进攻方帮派名字
RespUnionCityWarAllInfoMsg.defUnionName = ""; -- 防守方帮派名字



RespUnionCityWarAllInfoMsg.meta = {__index = RespUnionCityWarAllInfoMsg};
function RespUnionCityWarAllInfoMsg:new()
	local obj = setmetatable( {}, RespUnionCityWarAllInfoMsg.meta);
	return obj;
end

function RespUnionCityWarAllInfoMsg:ParseData(pak)
	local idx = 1;

	self.SuperMaxHp, idx = readInt(pak, idx);
	self.time, idx = readInt(pak, idx);
	self.mytype, idx = readInt(pak, idx);
	self.atkUnionName, idx = readString(pak, idx, 32);
	self.defUnionName, idx = readString(pak, idx, 32);

end



--[[
服务器通知：玩家击杀排名
]]

_G.RespUnionCityWarRolejiShaMsg = {};

RespUnionCityWarRolejiShaMsg.msgId = 8300;
RespUnionCityWarRolejiShaMsg.list_size = 0; -- 玩家击杀排名 size
RespUnionCityWarRolejiShaMsg.list = {}; -- 玩家击杀排名 list



--[[
roleListVO = {
	roleName = ""; -- 角色名字
	RoleID = ""; -- 玩家ID
	jisha = 0; -- 击杀数量
	type = 0; -- 玩家阵营，1=进攻方，2=防守方
}
]]

RespUnionCityWarRolejiShaMsg.meta = {__index = RespUnionCityWarRolejiShaMsg};
function RespUnionCityWarRolejiShaMsg:new()
	local obj = setmetatable( {}, RespUnionCityWarRolejiShaMsg.meta);
	return obj;
end

function RespUnionCityWarRolejiShaMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local roleListVo = {};
		roleListVo.roleName, idx = readString(pak, idx, 32);
		roleListVo.RoleID, idx = readGuid(pak, idx);
		roleListVo.jisha, idx = readInt(pak, idx);
		roleListVo.type, idx = readInt(pak, idx);
		table.push(list1,roleListVo);
	end

end



--[[
服务器通知：神像状态
]]

_G.RespUnionCityWarSuperStateMsg = {};

RespUnionCityWarSuperStateMsg.msgId = 8301;
RespUnionCityWarSuperStateMsg.SuperHp = 0; -- 王座血量
RespUnionCityWarSuperStateMsg.list_size = 0; -- 神像 类型  1=青龙,2=白虎,3=朱雀,4=玄武 5=王座 size
RespUnionCityWarSuperStateMsg.list = {}; -- 神像 类型  1=青龙,2=白虎,3=朱雀,4=玄武 5=王座 list



--[[
StatueListVO = {
	state = 0; -- 状态 1=进攻方 2= 防守方 
}
]]

RespUnionCityWarSuperStateMsg.meta = {__index = RespUnionCityWarSuperStateMsg};
function RespUnionCityWarSuperStateMsg:new()
	local obj = setmetatable( {}, RespUnionCityWarSuperStateMsg.meta);
	return obj;
end

function RespUnionCityWarSuperStateMsg:ParseData(pak)
	local idx = 1;

	self.SuperHp, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local StatueListVo = {};
		StatueListVo.state, idx = readInt(pak, idx);
		table.push(list1,StatueListVo);
	end

end



--[[
已购的限购物品列表，登陆、购买限购商品时推送
]]

_G.RespShopHasBuyMsg = {};

RespShopHasBuyMsg.msgId = 8304;
RespShopHasBuyMsg.shopHasBuyList_size = 0; -- 已购的限购物品列表 size
RespShopHasBuyMsg.shopHasBuyList = {}; -- 已购的限购物品列表 list



--[[
listVO = {
	id = 0; -- 商品id
	num = 0; -- 已购买数量
}
]]

RespShopHasBuyMsg.meta = {__index = RespShopHasBuyMsg};
function RespShopHasBuyMsg:new()
	local obj = setmetatable( {}, RespShopHasBuyMsg.meta);
	return obj;
end

function RespShopHasBuyMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.shopHasBuyList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listVo = {};
		listVo.id, idx = readInt(pak, idx);
		listVo.num, idx = readInt(pak, idx);
		table.push(list1,listVo);
	end

end



--[[
返回打宝活力值掉宝记录
]]

_G.RespDynamicDropItemsMsg = {};

RespDynamicDropItemsMsg.msgId = 8306;
RespDynamicDropItemsMsg.flag = 0; -- 0：新增掉宝，1：本次登录全部掉宝
RespDynamicDropItemsMsg.dropItems_size = 0; -- flag=0时：新增加的掉宝，flag=1时：本次登录全部掉宝记录 size
RespDynamicDropItemsMsg.dropItems = {}; -- flag=0时：新增加的掉宝，flag=1时：本次登录全部掉宝记录 list



--[[
dropItemsVO = {
	id = 0; -- 物品id
	num = 0; -- 物品数量
}
]]

RespDynamicDropItemsMsg.meta = {__index = RespDynamicDropItemsMsg};
function RespDynamicDropItemsMsg:new()
	local obj = setmetatable( {}, RespDynamicDropItemsMsg.meta);
	return obj;
end

function RespDynamicDropItemsMsg:ParseData(pak)
	local idx = 1;

	self.flag, idx = readByte(pak, idx);

	local list1 = {};
	self.dropItems = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local dropItemsVo = {};
		dropItemsVo.id, idx = readInt(pak, idx);
		dropItemsVo.num, idx = readInt(pak, idx);
		table.push(list1,dropItemsVo);
	end

end



--[[
上线时服务器通知：历史达成杀戮属性信息
]]

_G.RespKillHistoryMsg = {};

RespKillHistoryMsg.msgId = 8307;
RespKillHistoryMsg.killHistory_size = 0; -- 历史达成杀戮属性信息，用于计算历史杀戮属性 size
RespKillHistoryMsg.killHistory = {}; -- 历史达成杀戮属性信息，用于计算历史杀戮属性 list



--[[
killHistoryVO = {
	level = 0; -- 杀戮值档
	num = 0; -- 历史达成次数
}
]]

RespKillHistoryMsg.meta = {__index = RespKillHistoryMsg};
function RespKillHistoryMsg:new()
	local obj = setmetatable( {}, RespKillHistoryMsg.meta);
	return obj;
end

function RespKillHistoryMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.killHistory = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local killHistoryVo = {};
		killHistoryVo.level, idx = readInt(pak, idx);
		killHistoryVo.num, idx = readInt(pak, idx);
		table.push(list1,killHistoryVo);
	end

end



--[[
返回副本排行榜，前十
]]

_G.RespDungeonRankMsg = {};

RespDungeonRankMsg.msgId = 8308;
RespDungeonRankMsg.dungeonId = 0; -- 副本id
RespDungeonRankMsg.icon = 0; -- 第一名玩家头像
RespDungeonRankMsg.rankList_size = 10; -- 副本排行榜，前十 size
RespDungeonRankMsg.rankList = {}; -- 副本排行榜，前十 list



--[[
rankListVO = {
	id = ""; -- 玩家id
	name = ""; -- 玩家名字
	time = 0; -- 用时, s
}
]]

RespDungeonRankMsg.meta = {__index = RespDungeonRankMsg};
function RespDungeonRankMsg:new()
	local obj = setmetatable( {}, RespDungeonRankMsg.meta);
	return obj;
end

function RespDungeonRankMsg:ParseData(pak)
	local idx = 1;

	self.dungeonId, idx = readInt(pak, idx);
	self.icon, idx = readInt(pak, idx);

	local list1 = {};
	self.rankList = list1;
	local list1Size = 10;

	for i=1,list1Size do
		local rankListVo = {};
		rankListVo.id, idx = readGuid(pak, idx);
		rankListVo.name, idx = readString(pak, idx, 32);
		rankListVo.time, idx = readInt(pak, idx);
		table.push(list1,rankListVo);
	end

end



--[[
帮派王城战结果
]]

_G.RespUnionCityWarSuperResultMsg = {};

RespUnionCityWarSuperResultMsg.msgId = 8309;
RespUnionCityWarSuperResultMsg.type = 0; -- 我的阵营，1=进攻方，2=防守方
RespUnionCityWarSuperResultMsg.result = 0; -- 0=胜利，1=失败



RespUnionCityWarSuperResultMsg.meta = {__index = RespUnionCityWarSuperResultMsg};
function RespUnionCityWarSuperResultMsg:new()
	local obj = setmetatable( {}, RespUnionCityWarSuperResultMsg.meta);
	return obj;
end

function RespUnionCityWarSuperResultMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
返回今日必做信息
]]

_G.RespDailyMustDoMsg = {};

RespDailyMustDoMsg.msgId = 8311;
RespDailyMustDoMsg.list_size = 0; -- 活动次数列表 size
RespDailyMustDoMsg.list = {}; -- 活动次数列表 list



--[[
voVO = {
	id = 0; -- 活动id
	todaynum = 0; -- 今日剩余次数
	runnum = 0; -- 昨日剩余次数
	param1 = 0; -- 参数1
}
]]

RespDailyMustDoMsg.meta = {__index = RespDailyMustDoMsg};
function RespDailyMustDoMsg:new()
	local obj = setmetatable( {}, RespDailyMustDoMsg.meta);
	return obj;
end

function RespDailyMustDoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local voVo = {};
		voVo.id, idx = readInt(pak, idx);
		voVo.todaynum, idx = readInt(pak, idx);
		voVo.runnum, idx = readInt(pak, idx);
		voVo.param1, idx = readInt(pak, idx);
		table.push(list1,voVo);
	end

end



--[[
返回完成或者追回资源结果
]]

_G.RespFinishMustDoMsg = {};

RespFinishMustDoMsg.msgId = 8312;
RespFinishMustDoMsg.result = 0; -- 结果 0 成功，1 失败
RespFinishMustDoMsg.id = 0; -- 活动id
RespFinishMustDoMsg.type = 0; -- 类型 1=可扫荡，2=可追回，3=都可以
RespFinishMustDoMsg.consumetype = 0; -- 类型, 0=银两，1=元宝



RespFinishMustDoMsg.meta = {__index = RespFinishMustDoMsg};
function RespFinishMustDoMsg:new()
	local obj = setmetatable( {}, RespFinishMustDoMsg.meta);
	return obj;
end

function RespFinishMustDoMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);
	self.consumetype, idx = readInt(pak, idx);

end



--[[
返回一键完成或者追回资源结果
]]

_G.RespFinishAllMustDoMsg = {};

RespFinishAllMustDoMsg.msgId = 8313;
RespFinishAllMustDoMsg.result = 0; -- 结果 0 成功，1 失败
RespFinishAllMustDoMsg.consumetype = 0; -- 类型, 0=银两，1=元宝
RespFinishAllMustDoMsg.type = 0; -- 类型, 0=今日必做，1=昨日追回



RespFinishAllMustDoMsg.meta = {__index = RespFinishAllMustDoMsg};
function RespFinishAllMustDoMsg:new()
	local obj = setmetatable( {}, RespFinishAllMustDoMsg.meta);
	return obj;
end

function RespFinishAllMustDoMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.consumetype, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
返回运营活动信息
]]

_G.RespOperActMsg = {};

RespOperActMsg.msgId = 8314;
RespOperActMsg.list_size = 0; -- 运营活动信息列表 size
RespOperActMsg.list = {}; -- 运营活动信息列表 list



--[[
listVO = {
	id = 0; -- 运营活动配表id
	state = 0; -- 是否已领取, 0:未领取, 1:已领取
	time = 0; -- 已用时间, 不限时的活动传-1
	rewardNum = 0; -- 返还数量, 固定数量的传-1
}
]]

RespOperActMsg.meta = {__index = RespOperActMsg};
function RespOperActMsg:new()
	local obj = setmetatable( {}, RespOperActMsg.meta);
	return obj;
end

function RespOperActMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listVo = {};
		listVo.id, idx = readInt(pak, idx);
		listVo.state, idx = readInt(pak, idx);
		listVo.time, idx = readInt64(pak, idx);
		listVo.rewardNum, idx = readInt(pak, idx);
		table.push(list1,listVo);
	end

end



--[[
关闭运营活动
]]

_G.RespOperActDeactiveMsg = {};

RespOperActDeactiveMsg.msgId = 8316;
RespOperActDeactiveMsg.id = 0; -- 运营活动配表id



RespOperActDeactiveMsg.meta = {__index = RespOperActDeactiveMsg};
function RespOperActDeactiveMsg:new()
	local obj = setmetatable( {}, RespOperActDeactiveMsg.meta);
	return obj;
end

function RespOperActDeactiveMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
返回防沉迷信息
]]

_G.RespFangChenMiMsg = {};

RespFangChenMiMsg.msgId = 8317;
RespFangChenMiMsg.onlinetime = 0; -- 在线时间



RespFangChenMiMsg.meta = {__index = RespFangChenMiMsg};
function RespFangChenMiMsg:new()
	local obj = setmetatable( {}, RespFangChenMiMsg.meta);
	return obj;
end

function RespFangChenMiMsg:ParseData(pak)
	local idx = 1;

	self.onlinetime, idx = readInt(pak, idx);

end



--[[
服务器通知:回城结果
]]

_G.RespBackHomeResultMsg = {};

RespBackHomeResultMsg.msgId = 8318;
RespBackHomeResultMsg.result = 0; -- 返回回城结果,0返回时间,1:cd未结束,2:非传送场景,3:pk状态,4:死亡 5:当前地图不能传送 6:功能未开启 7:其他错误
RespBackHomeResultMsg.time = 0; -- 倒计时



RespBackHomeResultMsg.meta = {__index = RespBackHomeResultMsg};
function RespBackHomeResultMsg:new()
	local obj = setmetatable( {}, RespBackHomeResultMsg.meta);
	return obj;
end

function RespBackHomeResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.time, idx = readInt64(pak, idx);

end



--[[
返回防沉迷标记信息
]]

_G.RespFangChenMiBiaoJiMsg = {};

RespFangChenMiBiaoJiMsg.msgId = 8319;
RespFangChenMiBiaoJiMsg.is_adult = 0; -- 防沉迷标记



RespFangChenMiBiaoJiMsg.meta = {__index = RespFangChenMiBiaoJiMsg};
function RespFangChenMiBiaoJiMsg:new()
	local obj = setmetatable( {}, RespFangChenMiBiaoJiMsg.meta);
	return obj;
end

function RespFangChenMiBiaoJiMsg:ParseData(pak)
	local idx = 1;

	self.is_adult, idx = readInt(pak, idx);

end



--[[
签到返回
]]

_G.RespSignResultMsg = {};

RespSignResultMsg.msgId = 8320;
RespSignResultMsg.result = 0; -- 1：重复 2：VIP等级不够 3:补签次数不够 4：提前签次数不够 



RespSignResultMsg.meta = {__index = RespSignResultMsg};
function RespSignResultMsg:new()
	local obj = setmetatable( {}, RespSignResultMsg.meta);
	return obj;
end

function RespSignResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务端通知:返回境界信息
]]

_G.RespRealmInfoMsg = {};

RespRealmInfoMsg.msgId = 8321;
RespRealmInfoMsg.RealmOrder = 0; -- 境界等阶
RespRealmInfoMsg.feedToalNum = 0; -- 已灌注总次数
RespRealmInfoMsg.blessing = 0; -- 进阶后的祝福值
RespRealmInfoMsg.chongId = 0; -- 境界巩固重Id
RespRealmInfoMsg.chongprogress = 0; -- 境界巩固重进度
RespRealmInfoMsg.selectId = 0; -- 当前选中的境界Id
RespRealmInfoMsg.realmattrlist_size = 7; -- 境界属性加成 size
RespRealmInfoMsg.realmattrlist = {}; -- 境界属性加成 list



--[[
realmattrlistVO = {
	type = 0; -- 类型
	value = 0; -- 值
}
]]

RespRealmInfoMsg.meta = {__index = RespRealmInfoMsg};
function RespRealmInfoMsg:new()
	local obj = setmetatable( {}, RespRealmInfoMsg.meta);
	return obj;
end

function RespRealmInfoMsg:ParseData(pak)
	local idx = 1;

	self.RealmOrder, idx = readInt(pak, idx);
	self.feedToalNum, idx = readInt(pak, idx);
	self.blessing, idx = readInt(pak, idx);
	self.chongId, idx = readInt(pak, idx);
	self.chongprogress, idx = readInt(pak, idx);
	self.selectId, idx = readInt(pak, idx);

	local list = {};
	self.realmattrlist = list;
	local listSize = 7;

	for i=1,listSize do
		local realmattrlistVo = {};
		realmattrlistVo.type, idx = readInt(pak, idx);
		realmattrlistVo.value, idx = readInt(pak, idx);
		table.push(list,realmattrlistVo);
	end

end



--[[
服务器通知：返回灌注境界进度
]]

_G.RespRealmFloodResultMsg = {};

RespRealmFloodResultMsg.msgId = 8322;
RespRealmFloodResultMsg.result = 0; -- 返回结果 0:成功, 1:失败
RespRealmFloodResultMsg.realmOrder = 0; -- 境界等阶
RespRealmFloodResultMsg.feedToalNum = 0; -- 已灌注总次数
RespRealmFloodResultMsg.attrlist_size = 0; -- 境界属性加成 size
RespRealmFloodResultMsg.attrlist = {}; -- 境界属性加成 list



--[[
RealmAttrVO = {
	type = 0; -- 类型
	value = 0; -- 值
}
]]

RespRealmFloodResultMsg.meta = {__index = RespRealmFloodResultMsg};
function RespRealmFloodResultMsg:new()
	local obj = setmetatable( {}, RespRealmFloodResultMsg.meta);
	return obj;
end

function RespRealmFloodResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.realmOrder, idx = readInt(pak, idx);
	self.feedToalNum, idx = readInt(pak, idx);

	local list1 = {};
	self.attrlist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local RealmAttrVo = {};
		RealmAttrVo.type, idx = readInt(pak, idx);
		RealmAttrVo.value, idx = readInt(pak, idx);
		table.push(list1,RealmAttrVo);
	end

end



--[[
服务器通知：境界突破进阶结果
]]

_G.RespRealmBreakResultMsg = {};

RespRealmBreakResultMsg.msgId = 8325;
RespRealmBreakResultMsg.result = 0; -- 返回结果 0:突破成功, 1:突破失败
RespRealmBreakResultMsg.blessing = 0; -- 进阶后的祝福值



RespRealmBreakResultMsg.meta = {__index = RespRealmBreakResultMsg};
function RespRealmBreakResultMsg:new()
	local obj = setmetatable( {}, RespRealmBreakResultMsg.meta);
	return obj;
end

function RespRealmBreakResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.blessing, idx = readInt(pak, idx);

end



--[[
服务器返回:返回我在北仓界的排名
]]

_G.RespBackBeiCangRankIndexMsg = {};

RespBackBeiCangRankIndexMsg.msgId = 8327;
RespBackBeiCangRankIndexMsg.rankIndex = 0; -- 名次



RespBackBeiCangRankIndexMsg.meta = {__index = RespBackBeiCangRankIndexMsg};
function RespBackBeiCangRankIndexMsg:new()
	local obj = setmetatable( {}, RespBackBeiCangRankIndexMsg.meta);
	return obj;
end

function RespBackBeiCangRankIndexMsg:ParseData(pak)
	local idx = 1;

	self.rankIndex, idx = readInt(pak, idx);

end



--[[
服务器返回:刷新积分
]]

_G.RespBackBeiCangJieIntegralMsg = {};

RespBackBeiCangJieIntegralMsg.msgId = 8328;
RespBackBeiCangJieIntegralMsg.num = 0; -- 消耗积分 发总值



RespBackBeiCangJieIntegralMsg.meta = {__index = RespBackBeiCangJieIntegralMsg};
function RespBackBeiCangJieIntegralMsg:new()
	local obj = setmetatable( {}, RespBackBeiCangJieIntegralMsg.meta);
	return obj;
end

function RespBackBeiCangJieIntegralMsg:ParseData(pak)
	local idx = 1;

	self.num, idx = readInt(pak, idx);

end



--[[
服务器返回:争夺积分结束
]]

_G.RespBackBeiCangJieEndMsg = {};

RespBackBeiCangJieEndMsg.msgId = 8329;
RespBackBeiCangJieEndMsg.state = 0; -- 1 第一场 2 第二场
RespBackBeiCangJieEndMsg.result = 0; -- 结果 0成功 1失败
RespBackBeiCangJieEndMsg.num = 0; -- 积分



RespBackBeiCangJieEndMsg.meta = {__index = RespBackBeiCangJieEndMsg};
function RespBackBeiCangJieEndMsg:new()
	local obj = setmetatable( {}, RespBackBeiCangJieEndMsg.meta);
	return obj;
end

function RespBackBeiCangJieEndMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
服务器返回:排行榜
]]

_G.RespBackBeiCangJieRankMsg = {};

RespBackBeiCangJieRankMsg.msgId = 8330;
RespBackBeiCangJieRankMsg.list_size = 0; -- 排行列表 size
RespBackBeiCangJieRankMsg.list = {}; -- 排行列表 list



--[[
listvoVO = {
	rankIndex = 0; -- 名次
	head = 0; -- 玩家头像
	num = 0; -- 玩家得分
	name = ""; -- 名称
}
]]

RespBackBeiCangJieRankMsg.meta = {__index = RespBackBeiCangJieRankMsg};
function RespBackBeiCangJieRankMsg:new()
	local obj = setmetatable( {}, RespBackBeiCangJieRankMsg.meta);
	return obj;
end

function RespBackBeiCangJieRankMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listvoVo = {};
		listvoVo.rankIndex, idx = readInt(pak, idx);
		listvoVo.head, idx = readInt(pak, idx);
		listvoVo.num, idx = readInt(pak, idx);
		listvoVo.name, idx = readString(pak, idx, 32);
		table.push(list1,listvoVo);
	end

end



--[[
服务器返回:领奖退出结果
]]

_G.RespBackBeicangjieQuitMsg = {};

RespBackBeicangjieQuitMsg.msgId = 8331;
RespBackBeicangjieQuitMsg.result = 0; -- 结果 0成功 1失败



RespBackBeicangjieQuitMsg.meta = {__index = RespBackBeicangjieQuitMsg};
function RespBackBeicangjieQuitMsg:new()
	local obj = setmetatable( {}, RespBackBeicangjieQuitMsg.meta);
	return obj;
end

function RespBackBeicangjieQuitMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回:继续挑战结果
]]

_G.RespBackBeicangjieConMsg = {};

RespBackBeicangjieConMsg.msgId = 8332;
RespBackBeicangjieConMsg.result = 0; -- 结果 0成功 1失败



RespBackBeicangjieConMsg.meta = {__index = RespBackBeicangjieConMsg};
function RespBackBeicangjieConMsg:new()
	local obj = setmetatable( {}, RespBackBeicangjieConMsg.meta);
	return obj;
end

function RespBackBeicangjieConMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回:灵兽战印列表
]]

_G.RespRSpiritWarPrintMsg = {};

RespRSpiritWarPrintMsg.msgId = 8334;
RespRSpiritWarPrintMsg.debris = 0; -- 印记碎片数量
RespRSpiritWarPrintMsg.list_size = 0; -- 装备战印 size
RespRSpiritWarPrintMsg.list = {}; -- 装备战印 list



--[[
baglistVO = {
	tid = 0; -- 表id
	value = 0; -- 经验
	pos = 0; -- 位置
	bagType = 0; -- 背包类型1=着装，2=背包。3= 仓库
}
]]

RespRSpiritWarPrintMsg.meta = {__index = RespRSpiritWarPrintMsg};
function RespRSpiritWarPrintMsg:new()
	local obj = setmetatable( {}, RespRSpiritWarPrintMsg.meta);
	return obj;
end

function RespRSpiritWarPrintMsg:ParseData(pak)
	local idx = 1;

	self.debris, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local baglistVo = {};
		baglistVo.tid, idx = readInt(pak, idx);
		baglistVo.value, idx = readInt(pak, idx);
		baglistVo.pos, idx = readInt(pak, idx);
		baglistVo.bagType, idx = readInt(pak, idx);
		table.push(list1,baglistVo);
	end

end



--[[
添加战印
]]

_G.RespSpiritWarPrintAddMsg = {};

RespSpiritWarPrintAddMsg.msgId = 8335;
RespSpiritWarPrintAddMsg.isChou = 0; -- 是否抽取,1=是，其余均不是
RespSpiritWarPrintAddMsg.tid = 0; -- 表id
RespSpiritWarPrintAddMsg.value = 0; -- 经验
RespSpiritWarPrintAddMsg.pos = 0; -- 位置
RespSpiritWarPrintAddMsg.bagType = 0; -- 背包类型1=着装，2=背包。3= 仓库



RespSpiritWarPrintAddMsg.meta = {__index = RespSpiritWarPrintAddMsg};
function RespSpiritWarPrintAddMsg:new()
	local obj = setmetatable( {}, RespSpiritWarPrintAddMsg.meta);
	return obj;
end

function RespSpiritWarPrintAddMsg:ParseData(pak)
	local idx = 1;

	self.isChou, idx = readInt(pak, idx);
	self.tid, idx = readInt(pak, idx);
	self.value, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);
	self.bagType, idx = readInt(pak, idx);

end



--[[
更新战印
]]

_G.RespSpiritWarPrintUpdataMsg = {};

RespSpiritWarPrintUpdataMsg.msgId = 8336;
RespSpiritWarPrintUpdataMsg.tid = 0; -- 表id
RespSpiritWarPrintUpdataMsg.value = 0; -- 经验
RespSpiritWarPrintUpdataMsg.pos = 0; -- 位置
RespSpiritWarPrintUpdataMsg.bagType = 0; -- 背包类型1=着装，2=背包。3= 仓库



RespSpiritWarPrintUpdataMsg.meta = {__index = RespSpiritWarPrintUpdataMsg};
function RespSpiritWarPrintUpdataMsg:new()
	local obj = setmetatable( {}, RespSpiritWarPrintUpdataMsg.meta);
	return obj;
end

function RespSpiritWarPrintUpdataMsg:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);
	self.value, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);
	self.bagType, idx = readInt(pak, idx);

end



--[[
删除战印
]]

_G.RespSpiritWarPrintRemoveMsg = {};

RespSpiritWarPrintRemoveMsg.msgId = 8337;
RespSpiritWarPrintRemoveMsg.pos = 0; -- 位置
RespSpiritWarPrintRemoveMsg.bagType = 0; -- 背包类型1=着装，2=背包。3= 仓库



RespSpiritWarPrintRemoveMsg.meta = {__index = RespSpiritWarPrintRemoveMsg};
function RespSpiritWarPrintRemoveMsg:new()
	local obj = setmetatable( {}, RespSpiritWarPrintRemoveMsg.meta);
	return obj;
end

function RespSpiritWarPrintRemoveMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readInt(pak, idx);
	self.bagType, idx = readInt(pak, idx);

end



--[[
服务端通知: 交换物品反馈
]]

_G.RespSpiritWarPrintSwapResultMsg = {};

RespSpiritWarPrintSwapResultMsg.msgId = 8338;
RespSpiritWarPrintSwapResultMsg.result = 0; -- 结果  0:成功
RespSpiritWarPrintSwapResultMsg.src_bag = 0; -- 源背包
RespSpiritWarPrintSwapResultMsg.dst_bag = 0; -- 目标背包
RespSpiritWarPrintSwapResultMsg.src_idx = 0; -- 源格子
RespSpiritWarPrintSwapResultMsg.dst_idx = 0; -- 目标格子



RespSpiritWarPrintSwapResultMsg.meta = {__index = RespSpiritWarPrintSwapResultMsg};
function RespSpiritWarPrintSwapResultMsg:new()
	local obj = setmetatable( {}, RespSpiritWarPrintSwapResultMsg.meta);
	return obj;
end

function RespSpiritWarPrintSwapResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.src_bag, idx = readInt(pak, idx);
	self.dst_bag, idx = readInt(pak, idx);
	self.src_idx, idx = readInt(pak, idx);
	self.dst_idx, idx = readInt(pak, idx);

end



--[[
分解结果
]]

_G.RespSpiritWarPrintDebrisResultMsg = {};

RespSpiritWarPrintDebrisResultMsg.msgId = 8340;
RespSpiritWarPrintDebrisResultMsg.result = 0; -- 0= 成功
RespSpiritWarPrintDebrisResultMsg.debris = 0; -- 印记碎片数量



RespSpiritWarPrintDebrisResultMsg.meta = {__index = RespSpiritWarPrintDebrisResultMsg};
function RespSpiritWarPrintDebrisResultMsg:new()
	local obj = setmetatable( {}, RespSpiritWarPrintDebrisResultMsg.meta);
	return obj;
end

function RespSpiritWarPrintDebrisResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.debris, idx = readInt(pak, idx);

end



--[[
服务器返回:购买结果
]]

_G.RespSpiritWarPrintBuyMsg = {};

RespSpiritWarPrintBuyMsg.msgId = 8342;
RespSpiritWarPrintBuyMsg.result = 0; -- 结果 0成功 1失败
RespSpiritWarPrintBuyMsg.cid = 0; -- 物品表id
RespSpiritWarPrintBuyMsg.pos = 0; -- 物品位置
RespSpiritWarPrintBuyMsg.bagtype = 0; -- 背包 类型
RespSpiritWarPrintBuyMsg.num = 0; -- 碎片



RespSpiritWarPrintBuyMsg.meta = {__index = RespSpiritWarPrintBuyMsg};
function RespSpiritWarPrintBuyMsg:new()
	local obj = setmetatable( {}, RespSpiritWarPrintBuyMsg.meta);
	return obj;
end

function RespSpiritWarPrintBuyMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.cid, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);
	self.bagtype, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
服务端通知:返回武魂
]]

_G.RespWuHunLingshouInfoResultMsg = {};

RespWuHunLingshouInfoResultMsg.msgId = 8344;
RespWuHunLingshouInfoResultMsg.wuhunId = 0; -- 武魂id
RespWuHunLingshouInfoResultMsg.wuhunselectId = 0; -- 当前使用武魂id
RespWuHunLingshouInfoResultMsg.hunzhu = 0; -- 武魂当前魂珠
RespWuHunLingshouInfoResultMsg.feedNum = 0; -- 喂养次数
RespWuHunLingshouInfoResultMsg.hunzhuProgress = 0; -- 魂珠进度
RespWuHunLingshouInfoResultMsg.wuhunWish = 0; -- 喂养祝福
RespWuHunLingshouInfoResultMsg.wuhunState = 0; -- 状态，0,未附身，1,俯身
RespWuHunLingshouInfoResultMsg.pillNum = 0; -- 属性丹数量



RespWuHunLingshouInfoResultMsg.meta = {__index = RespWuHunLingshouInfoResultMsg};
function RespWuHunLingshouInfoResultMsg:new()
	local obj = setmetatable( {}, RespWuHunLingshouInfoResultMsg.meta);
	return obj;
end

function RespWuHunLingshouInfoResultMsg:ParseData(pak)
	local idx = 1;

	self.wuhunId, idx = readInt(pak, idx);
	self.wuhunselectId, idx = readInt(pak, idx);
	self.hunzhu, idx = readInt(pak, idx);
	self.feedNum, idx = readInt(pak, idx);
	self.hunzhuProgress, idx = readInt(pak, idx);
	self.wuhunWish, idx = readInt(pak, idx);
	self.wuhunState, idx = readInt(pak, idx);
	self.pillNum, idx = readInt(pak, idx);

end



--[[
服务端通知:返回武魂神兽列表
]]

_G.RespWuHunShenshouListResultMsg = {};

RespWuHunShenshouListResultMsg.msgId = 8345;
RespWuHunShenshouListResultMsg.wuhunshenshou_size = 0; -- 武魂神兽列表 size
RespWuHunShenshouListResultMsg.wuhunshenshou = {}; -- 武魂神兽列表 list



--[[
WuHunShenshouInfoVO = {
	wuhunId = 0; -- 武魂神兽id
	time = 0; -- 剩余时间
}
]]

RespWuHunShenshouListResultMsg.meta = {__index = RespWuHunShenshouListResultMsg};
function RespWuHunShenshouListResultMsg:new()
	local obj = setmetatable( {}, RespWuHunShenshouListResultMsg.meta);
	return obj;
end

function RespWuHunShenshouListResultMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.wuhunshenshou = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local WuHunShenshouInfoVo = {};
		WuHunShenshouInfoVo.wuhunId, idx = readInt(pak, idx);
		WuHunShenshouInfoVo.time, idx = readInt64(pak, idx);
		table.push(list1,WuHunShenshouInfoVo);
	end

end



--[[
服务端通知: 返回武魂神兽附身
]]

_G.RespAdjunctionWuHunShenshouResultMsg = {};

RespAdjunctionWuHunShenshouResultMsg.msgId = 8346;
RespAdjunctionWuHunShenshouResultMsg.result = 0; -- 反馈结果,2卸下武魂,1附身成功,-1:未知错误,-2:未激活, -3:已附身
RespAdjunctionWuHunShenshouResultMsg.wuhunId = 0; -- 武魂神兽id



RespAdjunctionWuHunShenshouResultMsg.meta = {__index = RespAdjunctionWuHunShenshouResultMsg};
function RespAdjunctionWuHunShenshouResultMsg:new()
	local obj = setmetatable( {}, RespAdjunctionWuHunShenshouResultMsg.meta);
	return obj;
end

function RespAdjunctionWuHunShenshouResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.wuhunId, idx = readInt(pak, idx);

end



--[[
服务端通知: 返回添加武魂神兽
]]

_G.RespAddWuHunShenshouResultMsg = {};

RespAddWuHunShenshouResultMsg.msgId = 8347;
RespAddWuHunShenshouResultMsg.result = 0; -- 反馈结果,0成功,-1:未知错误,-2:重复激活, -3:不满足条件
RespAddWuHunShenshouResultMsg.wuhunId = 0; -- 武魂神兽id



RespAddWuHunShenshouResultMsg.meta = {__index = RespAddWuHunShenshouResultMsg};
function RespAddWuHunShenshouResultMsg:new()
	local obj = setmetatable( {}, RespAddWuHunShenshouResultMsg.meta);
	return obj;
end

function RespAddWuHunShenshouResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.wuhunId, idx = readInt(pak, idx);

end



--[[
服务端通知: 购买结果
]]

_G.RespSpiritWarPrintBuyStoreMsg = {};

RespSpiritWarPrintBuyStoreMsg.msgId = 8348;
RespSpiritWarPrintBuyStoreMsg.result = 0; -- 1=成功，2条件不足，
RespSpiritWarPrintBuyStoreMsg.tid = 0; -- 物品表id
RespSpiritWarPrintBuyStoreMsg.num = 0; -- 碎片数量



RespSpiritWarPrintBuyStoreMsg.meta = {__index = RespSpiritWarPrintBuyStoreMsg};
function RespSpiritWarPrintBuyStoreMsg:new()
	local obj = setmetatable( {}, RespSpiritWarPrintBuyStoreMsg.meta);
	return obj;
end

function RespSpiritWarPrintBuyStoreMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.tid, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
返回装备宝石信息
]]

_G.RespOtherEquipGemMsg = {};

RespOtherEquipGemMsg.msgId = 8349;
RespOtherEquipGemMsg.serverType = 0; -- 是否全服排行信息 1=是 其余都不是
RespOtherEquipGemMsg.type = 0; -- 1== 详细信息，2 == 排行榜详细信息
RespOtherEquipGemMsg.roleID = ""; -- 角色ID
RespOtherEquipGemMsg.list_size = 0; -- 宝石list size
RespOtherEquipGemMsg.list = {}; -- 宝石list list



--[[
OtherItemEquipGemVOVO = {
	tid = 0; -- 表id
	pos = 0; -- 装备位
	slot = 0; -- 孔位
}
]]

RespOtherEquipGemMsg.meta = {__index = RespOtherEquipGemMsg};
function RespOtherEquipGemMsg:new()
	local obj = setmetatable( {}, RespOtherEquipGemMsg.meta);
	return obj;
end

function RespOtherEquipGemMsg:ParseData(pak)
	local idx = 1;

	self.serverType, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);
	self.roleID, idx = readGuid(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local OtherItemEquipGemVOVo = {};
		OtherItemEquipGemVOVo.tid, idx = readInt(pak, idx);
		OtherItemEquipGemVOVo.pos, idx = readInt(pak, idx);
		OtherItemEquipGemVOVo.slot, idx = readInt(pak, idx);
		table.push(list1,OtherItemEquipGemVOVo);
	end

end



--[[
返回运营类奖励是否已领取
]]

_G.RespYunYingRewardMsg = {};

RespYunYingRewardMsg.msgId = 8350;
RespYunYingRewardMsg.value = 0; -- (从第0位开始)值:1手机绑定奖励,2:微端奖励,3:加速球,4:是否首冲,5:黄子韬称号;6:杨幂称号



RespYunYingRewardMsg.meta = {__index = RespYunYingRewardMsg};
function RespYunYingRewardMsg:new()
	local obj = setmetatable( {}, RespYunYingRewardMsg.meta);
	return obj;
end

function RespYunYingRewardMsg:ParseData(pak)
	local idx = 1;

	self.value, idx = readInt(pak, idx);

end



--[[
服务器通知:宝甲信息
]]

_G.RespBaoJiaInfoMsg = {};

RespBaoJiaInfoMsg.msgId = 8352;
RespBaoJiaInfoMsg.level = 0; -- 宝甲等阶
RespBaoJiaInfoMsg.blessing = 0; -- 进阶祝福值



RespBaoJiaInfoMsg.meta = {__index = RespBaoJiaInfoMsg};
function RespBaoJiaInfoMsg:new()
	local obj = setmetatable( {}, RespBaoJiaInfoMsg.meta);
	return obj;
end

function RespBaoJiaInfoMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);
	self.blessing, idx = readInt(pak, idx);

end



--[[
服务器返回：宝甲进阶
]]

_G.RespBaoJiaLevelUpMsg = {};

RespBaoJiaLevelUpMsg.msgId = 8353;
RespBaoJiaLevelUpMsg.result = 0; -- 请求进阶结果 0:成功(成功获得祝福值), 2:宝甲未解锁, 3:已达等级上限, 4:金币不够, 5:道具数量不足
RespBaoJiaLevelUpMsg.blessing = 0; -- 进阶后的祝福值



RespBaoJiaLevelUpMsg.meta = {__index = RespBaoJiaLevelUpMsg};
function RespBaoJiaLevelUpMsg:new()
	local obj = setmetatable( {}, RespBaoJiaLevelUpMsg.meta);
	return obj;
end

function RespBaoJiaLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.blessing, idx = readInt(pak, idx);

end



--[[
返回其他人物装备卓越孔信息
]]

_G.RespOtherEquipSuperHoleMsg = {};

RespOtherEquipSuperHoleMsg.msgId = 8354;
RespOtherEquipSuperHoleMsg.serverType = 0; -- 是否全服排行信息 1=是 其余都不是
RespOtherEquipSuperHoleMsg.type = 0; -- 1== 详细信息，2 == 排行榜详细信息
RespOtherEquipSuperHoleMsg.list_size = 0; -- 列表 size
RespOtherEquipSuperHoleMsg.list = {}; -- 列表 list



--[[
SuperHoleListVOVO = {
	pos = 0; -- 装备位
	holeList_size = 5; -- 孔列表 size
	holeList = {}; -- 孔列表 list
}
SuperHoleVOVO = {
	index = 0; -- 孔索引 从1开始
	level = 0; -- 孔等级
}
]]

RespOtherEquipSuperHoleMsg.meta = {__index = RespOtherEquipSuperHoleMsg};
function RespOtherEquipSuperHoleMsg:new()
	local obj = setmetatable( {}, RespOtherEquipSuperHoleMsg.meta);
	return obj;
end

function RespOtherEquipSuperHoleMsg:ParseData(pak)
	local idx = 1;

	self.serverType, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local SuperHoleListVOVo = {};
		SuperHoleListVOVo.pos, idx = readInt(pak, idx);
		table.push(list1,SuperHoleListVOVo);

		local list2 = {};
		SuperHoleListVOVo.holeList = list2;
		local list2Size = 5;

		for i=1,list2Size do
			local SuperHoleVOVo = {};
			SuperHoleVOVo.index, idx = readInt(pak, idx);
			SuperHoleVOVo.level, idx = readInt(pak, idx);
			table.push(list2,SuperHoleVOVo);
		end
	end

end



--[[
返回召唤结果
]]

_G.RespShiHunMonstSummonResultMsg = {};

RespShiHunMonstSummonResultMsg.msgId = 8355;
RespShiHunMonstSummonResultMsg.result = 0; -- 结果=0成功 1= 魂值不足，2= 不能召唤
RespShiHunMonstSummonResultMsg.monstid = 0; -- 怪物id



RespShiHunMonstSummonResultMsg.meta = {__index = RespShiHunMonstSummonResultMsg};
function RespShiHunMonstSummonResultMsg:new()
	local obj = setmetatable( {}, RespShiHunMonstSummonResultMsg.meta);
	return obj;
end

function RespShiHunMonstSummonResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.monstid, idx = readInt(pak, idx);

end



--[[
通知客户端释放被动技能了
]]

_G.RespCastPassiveSkillMsg = {};

RespCastPassiveSkillMsg.msgId = 8356;
RespCastPassiveSkillMsg.skillId = 0; -- 技能ID



RespCastPassiveSkillMsg.meta = {__index = RespCastPassiveSkillMsg};
function RespCastPassiveSkillMsg:new()
	local obj = setmetatable( {}, RespCastPassiveSkillMsg.meta);
	return obj;
end

function RespCastPassiveSkillMsg:ParseData(pak)
	local idx = 1;

	self.skillId, idx = readInt(pak, idx);

end



--[[
返回V计划礼包领取情况--登录推
]]

_G.RespVPlanGiftMsg = {};

RespVPlanGiftMsg.msgId = 8358;
RespVPlanGiftMsg.dayGiftM = 0; -- 每日月费礼包,0未领取,1已领取
RespVPlanGiftMsg.dayGiftY = 0; -- 每日年费礼包,0未领取,1已领取
RespVPlanGiftMsg.vGift = 0; -- V首充礼包,0未领取,1已领取
RespVPlanGiftMsg.vYearGift = 0; -- V年费首充礼包,0未领取,1已领取
RespVPlanGiftMsg.mTitle = 0; -- 月称号,0未领取,1已领取
RespVPlanGiftMsg.yTitle = 0; -- 年称号,0未领取,1已领取
RespVPlanGiftMsg.levelGift_size = 0; -- 领取过的等级礼包 size
RespVPlanGiftMsg.levelGift = {}; -- 领取过的等级礼包 list



--[[
VLevelGiftVOVO = {
	id = 0; -- 等级礼包id
}
]]

RespVPlanGiftMsg.meta = {__index = RespVPlanGiftMsg};
function RespVPlanGiftMsg:new()
	local obj = setmetatable( {}, RespVPlanGiftMsg.meta);
	return obj;
end

function RespVPlanGiftMsg:ParseData(pak)
	local idx = 1;

	self.dayGiftM, idx = readByte(pak, idx);
	self.dayGiftY, idx = readByte(pak, idx);
	self.vGift, idx = readByte(pak, idx);
	self.vYearGift, idx = readByte(pak, idx);
	self.mTitle, idx = readByte(pak, idx);
	self.yTitle, idx = readByte(pak, idx);

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
返回领取V等级礼包
]]

_G.RespVLevelGiftMsg = {};

RespVLevelGiftMsg.msgId = 8359;
RespVLevelGiftMsg.levelGiftRet_size = 0; -- 等级礼包 size
RespVLevelGiftMsg.levelGiftRet = {}; -- 等级礼包 list



--[[
VLevelGiftRetVOVO = {
	result = 0; -- 结果,0成功,1不可领取,2已领取
	id = 0; -- 等级礼包id
}
]]

RespVLevelGiftMsg.meta = {__index = RespVLevelGiftMsg};
function RespVLevelGiftMsg:new()
	local obj = setmetatable( {}, RespVLevelGiftMsg.meta);
	return obj;
end

function RespVLevelGiftMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.levelGiftRet = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local VLevelGiftRetVOVo = {};
		VLevelGiftRetVOVo.result, idx = readByte(pak, idx);
		VLevelGiftRetVOVo.id, idx = readInt(pak, idx);
		table.push(list1,VLevelGiftRetVOVo);
	end

end



--[[
返回领取V每日礼包
]]

_G.RespVDayGiftMsg = {};

RespVDayGiftMsg.msgId = 8360;
RespVDayGiftMsg.result = 0; -- 结果,0成功,1不可领取,2已领取



RespVDayGiftMsg.meta = {__index = RespVDayGiftMsg};
function RespVDayGiftMsg:new()
	local obj = setmetatable( {}, RespVDayGiftMsg.meta);
	return obj;
end

function RespVDayGiftMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
返回领取V首充礼包
]]

_G.RespVVGiftMsg = {};

RespVVGiftMsg.msgId = 8361;
RespVVGiftMsg.result = 0; -- 结果,0成功,1不可领取,2已领取



RespVVGiftMsg.meta = {__index = RespVVGiftMsg};
function RespVVGiftMsg:new()
	local obj = setmetatable( {}, RespVVGiftMsg.meta);
	return obj;
end

function RespVVGiftMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
返回领取V年费礼包
]]

_G.RespVYearGiftMsg = {};

RespVYearGiftMsg.msgId = 8362;
RespVYearGiftMsg.result = 0; -- 结果,0成功,1不可领取,2已领取



RespVYearGiftMsg.meta = {__index = RespVYearGiftMsg};
function RespVYearGiftMsg:new()
	local obj = setmetatable( {}, RespVYearGiftMsg.meta);
	return obj;
end

function RespVYearGiftMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
返回领取V称号
]]

_G.RespVTitleMsg = {};

RespVTitleMsg.msgId = 8363;
RespVTitleMsg.result = 0; -- 结果,0成功，1不可领取，2=已领取
RespVTitleMsg.type = 0; -- 1月费称号,2年费称号,3同时领取



RespVTitleMsg.meta = {__index = RespVTitleMsg};
function RespVTitleMsg:new()
	local obj = setmetatable( {}, RespVTitleMsg.meta);
	return obj;
end

function RespVTitleMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
服务端通知:增加BUFF列表
]]

_G.RespAddBuffListMsg = {};

RespAddBuffListMsg.msgId = 8364;
RespAddBuffListMsg.target = ""; -- 目标者
RespAddBuffListMsg.buffList_size = 0; -- BUFF列表 size
RespAddBuffListMsg.buffList = {}; -- BUFF列表 list



--[[
buffVOVO = {
	caster = ""; -- 施放者
	id = ""; -- BUFF实例ID
	buffid = 0; -- BUFF配置ID
	time = 0; -- BUFF持续时间
}
]]

RespAddBuffListMsg.meta = {__index = RespAddBuffListMsg};
function RespAddBuffListMsg:new()
	local obj = setmetatable( {}, RespAddBuffListMsg.meta);
	return obj;
end

function RespAddBuffListMsg:ParseData(pak)
	local idx = 1;

	self.target, idx = readGuid(pak, idx);

	local list1 = {};
	self.buffList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local buffVOVo = {};
		buffVOVo.caster, idx = readGuid(pak, idx);
		buffVOVo.id, idx = readGuid(pak, idx);
		buffVOVo.buffid, idx = readInt(pak, idx);
		buffVOVo.time, idx = readInt(pak, idx);
		table.push(list1,buffVOVo);
	end

end



--[[
服务端通知:返回徽章信息
]]

_G.RespHuiZhangInfoMsg = {};

RespHuiZhangInfoMsg.msgId = 8365;
RespHuiZhangInfoMsg.huizhangOrder = 0; -- 徽章等阶
RespHuiZhangInfoMsg.freeNum = 0; -- 已经使用了的VIP免费灌注次数
RespHuiZhangInfoMsg.linglinum = 0; -- 聚灵的总数量
RespHuiZhangInfoMsg.killlinglinum = 0; -- 击杀怪物得到的灵力
RespHuiZhangInfoMsg.attrlist_size = 0; -- 徽章属性加成 size
RespHuiZhangInfoMsg.attrlist = {}; -- 徽章属性加成 list



--[[
HuiZhangAttrVO = {
	type = 0; -- 类型
	value = 0; -- 值
}
]]

RespHuiZhangInfoMsg.meta = {__index = RespHuiZhangInfoMsg};
function RespHuiZhangInfoMsg:new()
	local obj = setmetatable( {}, RespHuiZhangInfoMsg.meta);
	return obj;
end

function RespHuiZhangInfoMsg:ParseData(pak)
	local idx = 1;

	self.huizhangOrder, idx = readInt(pak, idx);
	self.freeNum, idx = readInt(pak, idx);
	self.linglinum, idx = readInt(pak, idx);
	self.killlinglinum, idx = readInt(pak, idx);

	local list1 = {};
	self.attrlist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local HuiZhangAttrVo = {};
		HuiZhangAttrVo.type, idx = readInt(pak, idx);
		HuiZhangAttrVo.value, idx = readInt(pak, idx);
		table.push(list1,HuiZhangAttrVo);
	end

end



--[[
服务器返回：徽章注灵
]]

_G.RespHuiZhangPracticeMsg = {};

RespHuiZhangPracticeMsg.msgId = 8366;
RespHuiZhangPracticeMsg.result = 0; -- 请求服务器返回：徽章注灵结果 0:成功(成功获得注灵),1:失败
RespHuiZhangPracticeMsg.type = 0; -- 0 普通注灵，1 vip注灵
RespHuiZhangPracticeMsg.attrlist_size = 0; -- 徽章属性加成 size
RespHuiZhangPracticeMsg.attrlist = {}; -- 徽章属性加成 list



--[[
HuiZhangAttrVO = {
	type = 0; -- 类型
	value = 0; -- 值
}
]]

RespHuiZhangPracticeMsg.meta = {__index = RespHuiZhangPracticeMsg};
function RespHuiZhangPracticeMsg:new()
	local obj = setmetatable( {}, RespHuiZhangPracticeMsg.meta);
	return obj;
end

function RespHuiZhangPracticeMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.type, idx = readInt(pak, idx);

	local list1 = {};
	self.attrlist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local HuiZhangAttrVo = {};
		HuiZhangAttrVo.type, idx = readInt(pak, idx);
		HuiZhangAttrVo.value, idx = readInt(pak, idx);
		table.push(list1,HuiZhangAttrVo);
	end

end



--[[
服务器返回：徽章突破失败结果
]]

_G.RespBreakHuiZhangMsg = {};

RespBreakHuiZhangMsg.msgId = 8367;
RespBreakHuiZhangMsg.result = 0; -- 请求突破徽章结果 0:成功(成功获得注灵),1:失败



RespBreakHuiZhangMsg.meta = {__index = RespBreakHuiZhangMsg};
function RespBreakHuiZhangMsg:new()
	local obj = setmetatable( {}, RespBreakHuiZhangMsg.meta);
	return obj;
end

function RespBreakHuiZhangMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
返回领取微端奖励
]]

_G.RespMClientRewardMsg = {};

RespMClientRewardMsg.msgId = 8368;
RespMClientRewardMsg.result = 0; -- 0成功,1已领取,2非微端登录



RespMClientRewardMsg.meta = {__index = RespMClientRewardMsg};
function RespMClientRewardMsg:new()
	local obj = setmetatable( {}, RespMClientRewardMsg.meta);
	return obj;
end

function RespMClientRewardMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
服务端通知:返回徽章聚灵信息
]]

_G.RespHuiZhangJuLingInfoMsg = {};

RespHuiZhangJuLingInfoMsg.msgId = 8369;
RespHuiZhangJuLingInfoMsg.linglinum = 0; -- 灵力数量，单次增加的数量



RespHuiZhangJuLingInfoMsg.meta = {__index = RespHuiZhangJuLingInfoMsg};
function RespHuiZhangJuLingInfoMsg:new()
	local obj = setmetatable( {}, RespHuiZhangJuLingInfoMsg.meta);
	return obj;
end

function RespHuiZhangJuLingInfoMsg:ParseData(pak)
	local idx = 1;

	self.linglinum, idx = readInt(pak, idx);

end



--[[
服务器返回：获得聚灵灵力
]]

_G.RespGetJuLingMsg = {};

RespGetJuLingMsg.msgId = 8370;
RespGetJuLingMsg.result = 0; -- 请求服务器返回：获得聚灵灵力结果 0:成功(成功获得聚灵),1:失败



RespGetJuLingMsg.meta = {__index = RespGetJuLingMsg};
function RespGetJuLingMsg:new()
	local obj = setmetatable( {}, RespGetJuLingMsg.meta);
	return obj;
end

function RespGetJuLingMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
服务器返回：获得世界最高等阶
]]

_G.RespGetRealmMaxMsg = {};

RespGetRealmMaxMsg.msgId = 8371;
RespGetRealmMaxMsg.order = 0; -- 世界最高等阶



RespGetRealmMaxMsg.meta = {__index = RespGetRealmMaxMsg};
function RespGetRealmMaxMsg:new()
	local obj = setmetatable( {}, RespGetRealmMaxMsg.meta);
	return obj;
end

function RespGetRealmMaxMsg:ParseData(pak)
	local idx = 1;

	self.order, idx = readInt(pak, idx);

end



--[[
服务器返回：成就信息
]]

_G.RespBackAchievementInfoMsg = {};

RespBackAchievementInfoMsg.msgId = 8372;
RespBackAchievementInfoMsg.pointIndex = 0; -- 点数阶段
RespBackAchievementInfoMsg.Achievement_size = 0; -- 成就列表：UI显示的阶段ID及进度 size
RespBackAchievementInfoMsg.Achievement = {}; -- 成就列表：UI显示的阶段ID及进度 list



--[[
AchievementVOVO = {
	id = 0; -- 类型
	value = 0; -- 值
	state = 0; -- 领奖状态
}
]]

RespBackAchievementInfoMsg.meta = {__index = RespBackAchievementInfoMsg};
function RespBackAchievementInfoMsg:new()
	local obj = setmetatable( {}, RespBackAchievementInfoMsg.meta);
	return obj;
end

function RespBackAchievementInfoMsg:ParseData(pak)
	local idx = 1;

	self.pointIndex, idx = readByte(pak, idx);

	local list1 = {};
	self.Achievement = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local AchievementVOVo = {};
		AchievementVOVo.id, idx = readInt(pak, idx);
		AchievementVOVo.value, idx = readByte(pak, idx);
		AchievementVOVo.state, idx = readByte(pak, idx);
		table.push(list1,AchievementVOVo);
	end

end



--[[
服务器返回：领取成就奖励
]]

_G.RespBackAchievementRewardMsg = {};

RespBackAchievementRewardMsg.msgId = 8373;
RespBackAchievementRewardMsg.result = 0; -- 结果 成功 0 失败  -1
RespBackAchievementRewardMsg.id = 0; -- 成就ID



RespBackAchievementRewardMsg.meta = {__index = RespBackAchievementRewardMsg};
function RespBackAchievementRewardMsg:new()
	local obj = setmetatable( {}, RespBackAchievementRewardMsg.meta);
	return obj;
end

function RespBackAchievementRewardMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
服务器返回：领取阶段成就奖励
]]

_G.RespBackAchievementPonitRewardMsg = {};

RespBackAchievementPonitRewardMsg.msgId = 8374;
RespBackAchievementPonitRewardMsg.result = 0; -- 结果 成功 0 失败  -1
RespBackAchievementPonitRewardMsg.id = 0; -- 成就点数ID



RespBackAchievementPonitRewardMsg.meta = {__index = RespBackAchievementPonitRewardMsg};
function RespBackAchievementPonitRewardMsg:new()
	local obj = setmetatable( {}, RespBackAchievementPonitRewardMsg.meta);
	return obj;
end

function RespBackAchievementPonitRewardMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
服务器返回：阶段成就完成
]]

_G.RespBackAchievementCompleteMsg = {};

RespBackAchievementCompleteMsg.msgId = 8375;
RespBackAchievementCompleteMsg.id = 0; -- 请求服务器返回：完成某阶段的ID



RespBackAchievementCompleteMsg.meta = {__index = RespBackAchievementCompleteMsg};
function RespBackAchievementCompleteMsg:new()
	local obj = setmetatable( {}, RespBackAchievementCompleteMsg.meta);
	return obj;
end

function RespBackAchievementCompleteMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
服务端通知:返回炼体信息
]]

_G.RespLianTiInfoMsg = {};

RespLianTiInfoMsg.msgId = 8376;
RespLianTiInfoMsg.list_size = 0; -- 炼体信息列表 size
RespLianTiInfoMsg.list = {}; -- 炼体信息列表 list



--[[
LianTiVoVO = {
	id = 0; -- 炼体类型id*1000+炼体等阶*100+点id
}
]]

RespLianTiInfoMsg.meta = {__index = RespLianTiInfoMsg};
function RespLianTiInfoMsg:new()
	local obj = setmetatable( {}, RespLianTiInfoMsg.meta);
	return obj;
end

function RespLianTiInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local LianTiVoVo = {};
		LianTiVoVo.id, idx = readInt(pak, idx);
		table.push(list1,LianTiVoVo);
	end

end



--[[
服务器返回：获得炼体升星结果
]]

_G.RespLianTiXingMsg = {};

RespLianTiXingMsg.msgId = 8377;
RespLianTiXingMsg.result = 0; -- 请求服务器返回：获得炼体升星结果 0:成功(成功升星),1:失败
RespLianTiXingMsg.id = 0; -- 炼体类型id*1000+炼体等阶*100+点id 已修炼的id



RespLianTiXingMsg.meta = {__index = RespLianTiXingMsg};
function RespLianTiXingMsg:new()
	local obj = setmetatable( {}, RespLianTiXingMsg.meta);
	return obj;
end

function RespLianTiXingMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
服务器返回：获得炼体升重结果
]]

_G.RespLianTiLayerMsg = {};

RespLianTiLayerMsg.msgId = 8378;
RespLianTiLayerMsg.result = 0; -- 请求服务器返回：获得升重结果 0:成功(成功升重),1:失败
RespLianTiLayerMsg.id = 0; -- 炼体类型id*1000+炼体等阶*100+点id  已修炼的id



RespLianTiLayerMsg.meta = {__index = RespLianTiLayerMsg};
function RespLianTiLayerMsg:new()
	local obj = setmetatable( {}, RespLianTiLayerMsg.meta);
	return obj;
end

function RespLianTiLayerMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
服务端通知:返回击杀怪物得到灵力信息
]]

_G.RespKillGetLingLiInfoMsg = {};

RespKillGetLingLiInfoMsg.msgId = 8382;
RespKillGetLingLiInfoMsg.killlinglinum = 0; -- 击杀怪物得到灵力总数



RespKillGetLingLiInfoMsg.meta = {__index = RespKillGetLingLiInfoMsg};
function RespKillGetLingLiInfoMsg:new()
	local obj = setmetatable( {}, RespKillGetLingLiInfoMsg.meta);
	return obj;
end

function RespKillGetLingLiInfoMsg:ParseData(pak)
	local idx = 1;

	self.killlinglinum, idx = readInt(pak, idx);

end



--[[
返回怪物归属变化
]]

_G.RespMonChangeBelong = {};

RespMonChangeBelong.msgId = 8383;
RespMonChangeBelong.guid = ""; -- 
RespMonChangeBelong.belongType = 0; -- 
RespMonChangeBelong.belongID = ""; -- 



RespMonChangeBelong.meta = {__index = RespMonChangeBelong};
function RespMonChangeBelong:new()
	local obj = setmetatable( {}, RespMonChangeBelong.meta);
	return obj;
end

function RespMonChangeBelong:ParseData(pak)
	local idx = 1;

	self.guid, idx = readGuid(pak, idx);
	self.belongType, idx = readInt(pak, idx);
	self.belongID, idx = readGuid(pak, idx);

end



--[[
返回道具卓越信息
]]

_G.RespItemSuperMsg = {};

RespItemSuperMsg.msgId = 8384;
RespItemSuperMsg.list_size = 0; -- 道具list size
RespItemSuperMsg.list = {}; -- 道具list list



--[[
ItemSuperListVOVO = {
	itemId = ""; -- 道具cid
	id = 0; -- 卓越id
	val1 = 0; -- 值1
}
]]

RespItemSuperMsg.meta = {__index = RespItemSuperMsg};
function RespItemSuperMsg:new()
	local obj = setmetatable( {}, RespItemSuperMsg.meta);
	return obj;
end

function RespItemSuperMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ItemSuperListVOVo = {};
		ItemSuperListVOVo.itemId, idx = readGuid(pak, idx);
		ItemSuperListVOVo.id, idx = readInt(pak, idx);
		ItemSuperListVOVo.val1, idx = readInt(pak, idx);
		table.push(list1,ItemSuperListVOVo);
	end

end



--[[
返回创建卓越卷轴
]]

_G.RespCreateSuperItemMsg = {};

RespCreateSuperItemMsg.msgId = 8385;
RespCreateSuperItemMsg.result = 0; -- 结果 0:成功
RespCreateSuperItemMsg.libUid = ""; -- 库属性uid
RespCreateSuperItemMsg.itemUid = ""; -- 生成的道具uid



RespCreateSuperItemMsg.meta = {__index = RespCreateSuperItemMsg};
function RespCreateSuperItemMsg:new()
	local obj = setmetatable( {}, RespCreateSuperItemMsg.meta);
	return obj;
end

function RespCreateSuperItemMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.libUid, idx = readGuid(pak, idx);
	self.itemUid, idx = readGuid(pak, idx);

end



--[[
服务器返回：装备打造开启列表
]]

_G.RespEquipBuildOpenListMsg = {};

RespEquipBuildOpenListMsg.msgId = 8386;
RespEquipBuildOpenListMsg.openlist_size = 0; -- 开启列表 size
RespEquipBuildOpenListMsg.openlist = {}; -- 开启列表 list



--[[
openlistVoVO = {
	id = 0; -- 图纸id
}
]]

RespEquipBuildOpenListMsg.meta = {__index = RespEquipBuildOpenListMsg};
function RespEquipBuildOpenListMsg:new()
	local obj = setmetatable( {}, RespEquipBuildOpenListMsg.meta);
	return obj;
end

function RespEquipBuildOpenListMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.openlist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local openlistVoVo = {};
		openlistVoVo.id, idx = readInt(pak, idx);
		table.push(list1,openlistVoVo);
	end

end



--[[
返回打造结果
]]

_G.RespEquipBuildStartMsg = {};

RespEquipBuildStartMsg.msgId = 8387;
RespEquipBuildStartMsg.result = 0; -- 结果  0:成功
RespEquipBuildStartMsg.list_size = 0; -- 打造结果 size
RespEquipBuildStartMsg.list = {}; -- 打造结果 list



--[[
equipListVO = {
	cid = 0; -- 装备id
	attrAddLvl = 0; -- 追加属性等级
	groupId = 0; -- 套装id
	groupId2 = 0; -- 套装id2
	group2Level = 0; -- 套装2的等级
	superNum = 0; -- 卓越数量
	bind = 0; -- 是否绑定0非绑定，1绑定
	superList_size = 7; -- 卓越属性列表 size
	superList = {}; -- 卓越属性列表 list
	newSuperList_size = 3; -- 新卓越属性列表 size
	newSuperList = {}; -- 新卓越属性列表 list
}
SuperVOVO = {
	uid = ""; -- 属性uid
	id = 0; -- 卓越id
	val1 = 0; -- 值1
}
NewSuperVOVO = {
	id = 0; -- 新卓越id
	wash = 0; -- 洗练值
}
]]

RespEquipBuildStartMsg.meta = {__index = RespEquipBuildStartMsg};
function RespEquipBuildStartMsg:new()
	local obj = setmetatable( {}, RespEquipBuildStartMsg.meta);
	return obj;
end

function RespEquipBuildStartMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local equipListVo = {};
		equipListVo.cid, idx = readInt(pak, idx);
		equipListVo.attrAddLvl, idx = readInt(pak, idx);
		equipListVo.groupId, idx = readInt(pak, idx);
		equipListVo.groupId2, idx = readInt(pak, idx);
		equipListVo.group2Level, idx = readInt(pak, idx);
		equipListVo.superNum, idx = readInt(pak, idx);
		equipListVo.bind, idx = readInt(pak, idx);
		table.push(list1,equipListVo);

		local list2 = {};
		equipListVo.superList = list2;
		local list2Size = 7;

		for i=1,list2Size do
			local SuperVOVo = {};
			SuperVOVo.uid, idx = readGuid(pak, idx);
			SuperVOVo.id, idx = readInt(pak, idx);
			SuperVOVo.val1, idx = readInt(pak, idx);
			table.push(list2,SuperVOVo);
		end

		local list3 = {};
		equipListVo.newSuperList = list3;
		local list3Size = 3;

		for i=1,list3Size do
			local NewSuperVOVo = {};
			NewSuperVOVo.id, idx = readInt(pak, idx);
			NewSuperVOVo.wash, idx = readInt(pak, idx);
			table.push(list3,NewSuperVOVo);
		end
	end

end



--[[
返回分解结果
]]

_G.RespEquipDecomposeMsg = {};

RespEquipDecomposeMsg.msgId = 8388;
RespEquipDecomposeMsg.result = 0; -- 结果  0:成功
RespEquipDecomposeMsg.chiplist_size = 0; -- 分解的碎片list size
RespEquipDecomposeMsg.chiplist = {}; -- 分解的碎片list list



--[[
chipVO = {
	num = 0; -- 碎片数量
	cid = 0; -- 物品id
}
]]

RespEquipDecomposeMsg.meta = {__index = RespEquipDecomposeMsg};
function RespEquipDecomposeMsg:new()
	local obj = setmetatable( {}, RespEquipDecomposeMsg.meta);
	return obj;
end

function RespEquipDecomposeMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

	local list1 = {};
	self.chiplist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local chipVo = {};
		chipVo.num, idx = readInt(pak, idx);
		chipVo.cid, idx = readInt(pak, idx);
		table.push(list1,chipVo);
	end

end



--[[
返回帮派战状态
]]

_G.RespUnionWarStateMsg = {};

RespUnionWarStateMsg.msgId = 8389;
RespUnionWarStateMsg.result = 0; -- 结果 0:关闭 1：开启



RespUnionWarStateMsg.meta = {__index = RespUnionWarStateMsg};
function RespUnionWarStateMsg:new()
	local obj = setmetatable( {}, RespUnionWarStateMsg.meta);
	return obj;
end

function RespUnionWarStateMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回UI信息
]]

_G.RespDominateRouteDataMsg = {};

RespDominateRouteDataMsg.msgId = 8390;
RespDominateRouteDataMsg.enterNum = 0; -- 剩余挑战次数
RespDominateRouteDataMsg.veillist_size = 11; -- 幕list size
RespDominateRouteDataMsg.veillist = {}; -- 幕list list
RespDominateRouteDataMsg.stagelist_size = 0; -- 章节list size
RespDominateRouteDataMsg.stagelist = {}; -- 章节list list



--[[
veilvoVO = {
	rewardState = 0; -- 宝箱状态: 0未领取 1已领取
}
]]
--[[
stagevoVO = {
	num = 0; -- 剩余挑战次数
	id = 0; -- id
	state = 0; -- 0 没扫荡 1在扫荡
	timeNum = 0; --  扫荡剩余时间0 待领取倒计时
	maxNum = 0; --  总次数
	evaluate = 0; -- 评价1-3星
}
]]

RespDominateRouteDataMsg.meta = {__index = RespDominateRouteDataMsg};
function RespDominateRouteDataMsg:new()
	local obj = setmetatable( {}, RespDominateRouteDataMsg.meta);
	return obj;
end

function RespDominateRouteDataMsg:ParseData(pak)
	local idx = 1;

	self.enterNum, idx = readInt(pak, idx);

	local list2 = {};
	self.veillist = list2;
	local list2Size = 11;

	for i=1,list2Size do
		local veilvoVo = {};
		veilvoVo.rewardState, idx = readInt(pak, idx);
		table.push(list2,veilvoVo);
	end

	local list1 = {};
	self.stagelist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local stagevoVo = {};
		stagevoVo.num, idx = readInt(pak, idx);
		stagevoVo.id, idx = readInt(pak, idx);
		stagevoVo.state, idx = readInt(pak, idx);
		stagevoVo.timeNum, idx = readInt64(pak, idx);
		stagevoVo.maxNum, idx = readInt(pak, idx);
		stagevoVo.evaluate, idx = readInt(pak, idx);
		table.push(list1,stagevoVo);
	end

end



--[[
刷新
]]

_G.RespDominateRouteUpDateMsg = {};

RespDominateRouteUpDateMsg.msgId = 8391;
RespDominateRouteUpDateMsg.num = 0; -- 剩余次数
RespDominateRouteUpDateMsg.state = 0; -- 0 没扫荡 1在扫荡
RespDominateRouteUpDateMsg.time = 0; -- 扫荡剩余时间0 待领取倒计时
RespDominateRouteUpDateMsg.id = 0; -- id



RespDominateRouteUpDateMsg.meta = {__index = RespDominateRouteUpDateMsg};
function RespDominateRouteUpDateMsg:new()
	local obj = setmetatable( {}, RespDominateRouteUpDateMsg.meta);
	return obj;
end

function RespDominateRouteUpDateMsg:ParseData(pak)
	local idx = 1;

	self.num, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);
	self.time, idx = readInt64(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
返回挑战
]]

_G.RespBackDominateRouteChallengeMsg = {};

RespBackDominateRouteChallengeMsg.msgId = 8392;
RespBackDominateRouteChallengeMsg.result = 0; -- 进入结果返回: 0失败 1成功
RespBackDominateRouteChallengeMsg.id = 0; -- 返回进入挑战



RespBackDominateRouteChallengeMsg.meta = {__index = RespBackDominateRouteChallengeMsg};
function RespBackDominateRouteChallengeMsg:new()
	local obj = setmetatable( {}, RespBackDominateRouteChallengeMsg.meta);
	return obj;
end

function RespBackDominateRouteChallengeMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
返回退出
]]

_G.RespBackDominateRouteQuitMsg = {};

RespBackDominateRouteQuitMsg.msgId = 8393;
RespBackDominateRouteQuitMsg.result = 0; -- 进入结果返回 0 失败 1 成功



RespBackDominateRouteQuitMsg.meta = {__index = RespBackDominateRouteQuitMsg};
function RespBackDominateRouteQuitMsg:new()
	local obj = setmetatable( {}, RespBackDominateRouteQuitMsg.meta);
	return obj;
end

function RespBackDominateRouteQuitMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回追踪信息
]]

_G.RespBackDominateRouteInfoMsg = {};

RespBackDominateRouteInfoMsg.msgId = 8394;
RespBackDominateRouteInfoMsg.num = 0; -- 待定~~~



RespBackDominateRouteInfoMsg.meta = {__index = RespBackDominateRouteInfoMsg};
function RespBackDominateRouteInfoMsg:new()
	local obj = setmetatable( {}, RespBackDominateRouteInfoMsg.meta);
	return obj;
end

function RespBackDominateRouteInfoMsg:ParseData(pak)
	local idx = 1;

	self.num, idx = readInt(pak, idx);

end



--[[
返回扫荡
]]

_G.RespBackDominateRouteWipeMsg = {};

RespBackDominateRouteWipeMsg.msgId = 8395;
RespBackDominateRouteWipeMsg.result = 0; -- 扫荡结果返回: 0失败 1成功
RespBackDominateRouteWipeMsg.id = 0; -- 返回进入扫荡
RespBackDominateRouteWipeMsg.num = 0; -- 返回扫荡次数



RespBackDominateRouteWipeMsg.meta = {__index = RespBackDominateRouteWipeMsg};
function RespBackDominateRouteWipeMsg:new()
	local obj = setmetatable( {}, RespBackDominateRouteWipeMsg.meta);
	return obj;
end

function RespBackDominateRouteWipeMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
返回购买精力
]]

_G.RespBackDominateRouteVigorMsg = {};

RespBackDominateRouteVigorMsg.msgId = 8396;
RespBackDominateRouteVigorMsg.result = 0; -- 购买结果返回: 0失败 1成功



RespBackDominateRouteVigorMsg.meta = {__index = RespBackDominateRouteVigorMsg};
function RespBackDominateRouteVigorMsg:new()
	local obj = setmetatable( {}, RespBackDominateRouteVigorMsg.meta);
	return obj;
end

function RespBackDominateRouteVigorMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回领取宝箱奖励
]]

_G.RespBackDominateRouteBoxRewardMsg = {};

RespBackDominateRouteBoxRewardMsg.msgId = 8397;
RespBackDominateRouteBoxRewardMsg.result = 0; -- 购买领取结果: 0失败 1成功
RespBackDominateRouteBoxRewardMsg.id = 0; -- 返回领取id



RespBackDominateRouteBoxRewardMsg.meta = {__index = RespBackDominateRouteBoxRewardMsg};
function RespBackDominateRouteBoxRewardMsg:new()
	local obj = setmetatable( {}, RespBackDominateRouteBoxRewardMsg.meta);
	return obj;
end

function RespBackDominateRouteBoxRewardMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
返回通关
]]

_G.RespBackDominateRouteEndMsg = {};

RespBackDominateRouteEndMsg.msgId = 8398;
RespBackDominateRouteEndMsg.level = 0; -- 评定
RespBackDominateRouteEndMsg.result = 0; -- 购买领取结果: 0失败 1成功



RespBackDominateRouteEndMsg.meta = {__index = RespBackDominateRouteEndMsg};
function RespBackDominateRouteEndMsg:new()
	local obj = setmetatable( {}, RespBackDominateRouteEndMsg.meta);
	return obj;
end

function RespBackDominateRouteEndMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
返回扫荡结束
]]

_G.RespBackDominateRouteMopupEndMsg = {};

RespBackDominateRouteMopupEndMsg.msgId = 8399;
RespBackDominateRouteMopupEndMsg.id = 0; -- 扫荡完成的ID
RespBackDominateRouteMopupEndMsg.result = 0; -- 扫荡结果
RespBackDominateRouteMopupEndMsg.num = 0; -- 扫荡次数



RespBackDominateRouteMopupEndMsg.meta = {__index = RespBackDominateRouteMopupEndMsg};
function RespBackDominateRouteMopupEndMsg:new()
	local obj = setmetatable( {}, RespBackDominateRouteMopupEndMsg.meta);
	return obj;
end

function RespBackDominateRouteMopupEndMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
返回已完成任务列表
]]

_G.RespFinishedQuestMsg = {};

RespFinishedQuestMsg.msgId = 8400;
RespFinishedQuestMsg.QuestIds_size = 0; -- 已完成任务列表 size
RespFinishedQuestMsg.QuestIds = {}; -- 已完成任务列表 list



--[[
QuestIdsVoVO = {
	id = 0; -- 任务ID
}
]]

RespFinishedQuestMsg.meta = {__index = RespFinishedQuestMsg};
function RespFinishedQuestMsg:new()
	local obj = setmetatable( {}, RespFinishedQuestMsg.meta);
	return obj;
end

function RespFinishedQuestMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.QuestIds = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local QuestIdsVoVo = {};
		QuestIdsVoVo.id, idx = readInt(pak, idx);
		table.push(list1,QuestIdsVoVo);
	end

end



--[[
服务端通知: 返回使用卓越道具
]]

_G.RespUseItemSuperMsg = {};

RespUseItemSuperMsg.msgId = 8401;
RespUseItemSuperMsg.result = 0; -- 结果  0:成功
RespUseItemSuperMsg.id = 0; -- 卓越tid
RespUseItemSuperMsg.val1 = 0; -- 值1



RespUseItemSuperMsg.meta = {__index = RespUseItemSuperMsg};
function RespUseItemSuperMsg:new()
	local obj = setmetatable( {}, RespUseItemSuperMsg.meta);
	return obj;
end

function RespUseItemSuperMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);
	self.val1, idx = readInt(pak, idx);

end



--[[
返回炼化装备信息
]]

_G.RespEquipRefiningListMsg = {};

RespEquipRefiningListMsg.msgId = 8402;
RespEquipRefiningListMsg.Refining_size = 0; -- 炼化列表 size
RespEquipRefiningListMsg.Refining = {}; -- 炼化列表 list



--[[
refiningVoVO = {
	id = 0; -- 表id
	pos = 0; -- pos
}
]]

RespEquipRefiningListMsg.meta = {__index = RespEquipRefiningListMsg};
function RespEquipRefiningListMsg:new()
	local obj = setmetatable( {}, RespEquipRefiningListMsg.meta);
	return obj;
end

function RespEquipRefiningListMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.Refining = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local refiningVoVo = {};
		refiningVoVo.id, idx = readInt(pak, idx);
		refiningVoVo.pos, idx = readInt(pak, idx);
		table.push(list1,refiningVoVo);
	end

end



--[[
返回炼化结果
]]

_G.RespEquipRefiningLvlUpResultMsg = {};

RespEquipRefiningLvlUpResultMsg.msgId = 8403;
RespEquipRefiningLvlUpResultMsg.result = 0; -- 0=成功



RespEquipRefiningLvlUpResultMsg.meta = {__index = RespEquipRefiningLvlUpResultMsg};
function RespEquipRefiningLvlUpResultMsg:new()
	local obj = setmetatable( {}, RespEquipRefiningLvlUpResultMsg.meta);
	return obj;
end

function RespEquipRefiningLvlUpResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回一键炼化结果
]]

_G.RespEquipRefiningAutoLvlUpResultMsg = {};

RespEquipRefiningAutoLvlUpResultMsg.msgId = 8404;
RespEquipRefiningAutoLvlUpResultMsg.result = 0; -- 0=成功 1失败
RespEquipRefiningAutoLvlUpResultMsg.itemlist_size = 0; -- 炼化列表 size
RespEquipRefiningAutoLvlUpResultMsg.itemlist = {}; -- 炼化列表 list



--[[
resultVoVO = {
	pos = 0; -- pos
	result = 0; -- result 0成功1失败
}
]]

RespEquipRefiningAutoLvlUpResultMsg.meta = {__index = RespEquipRefiningAutoLvlUpResultMsg};
function RespEquipRefiningAutoLvlUpResultMsg:new()
	local obj = setmetatable( {}, RespEquipRefiningAutoLvlUpResultMsg.meta);
	return obj;
end

function RespEquipRefiningAutoLvlUpResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

	local list1 = {};
	self.itemlist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local resultVoVo = {};
		resultVoVo.pos, idx = readByte(pak, idx);
		resultVoVo.result, idx = readByte(pak, idx);
		table.push(list1,resultVoVo);
	end

end



--[[
服务器返回:返回BOSS计时信息
]]

_G.RespBackBeiCangJieBossUpDataInfoMsg = {};

RespBackBeiCangJieBossUpDataInfoMsg.msgId = 8405;
RespBackBeiCangJieBossUpDataInfoMsg.timeNum = 0; -- boss剩余刷新时间



RespBackBeiCangJieBossUpDataInfoMsg.meta = {__index = RespBackBeiCangJieBossUpDataInfoMsg};
function RespBackBeiCangJieBossUpDataInfoMsg:new()
	local obj = setmetatable( {}, RespBackBeiCangJieBossUpDataInfoMsg.meta);
	return obj;
end

function RespBackBeiCangJieBossUpDataInfoMsg:ParseData(pak)
	local idx = 1;

	self.timeNum, idx = readInt(pak, idx);

end



--[[
服务器返回:返回BOSS刷新信息
]]

_G.RespBackBeiCangJieBossInfoMsg = {};

RespBackBeiCangJieBossInfoMsg.msgId = 8406;
RespBackBeiCangJieBossInfoMsg.location = 0; -- boss站台位置 1234



RespBackBeiCangJieBossInfoMsg.meta = {__index = RespBackBeiCangJieBossInfoMsg};
function RespBackBeiCangJieBossInfoMsg:new()
	local obj = setmetatable( {}, RespBackBeiCangJieBossInfoMsg.meta);
	return obj;
end

function RespBackBeiCangJieBossInfoMsg:ParseData(pak)
	local idx = 1;

	self.location, idx = readInt(pak, idx);

end



--[[
服务器返回:返回全图怪物信息
]]

_G.RespBackBeiCangJieMonsterInfoMsg = {};

RespBackBeiCangJieMonsterInfoMsg.msgId = 8407;
RespBackBeiCangJieMonsterInfoMsg.eliteNum = 0; -- 精英怪物存活数量
RespBackBeiCangJieMonsterInfoMsg.commonNum = 0; -- 怪物存活数量



RespBackBeiCangJieMonsterInfoMsg.meta = {__index = RespBackBeiCangJieMonsterInfoMsg};
function RespBackBeiCangJieMonsterInfoMsg:new()
	local obj = setmetatable( {}, RespBackBeiCangJieMonsterInfoMsg.meta);
	return obj;
end

function RespBackBeiCangJieMonsterInfoMsg:ParseData(pak)
	local idx = 1;

	self.eliteNum, idx = readInt(pak, idx);
	self.commonNum, idx = readInt(pak, idx);

end



--[[
服务器推送需要在地图上显示的北仓界玩家信息
]]

_G.RespBcjMapPlayerMsg = {};

RespBcjMapPlayerMsg.msgId = 8408;
RespBcjMapPlayerMsg.roleList_size = 0; -- 需要在地图上显示的北仓界玩家信息列表 size
RespBcjMapPlayerMsg.roleList = {}; -- 需要在地图上显示的北仓界玩家信息列表 list



--[[
roleListVO = {
	roleId = ""; -- 玩家guid
	posX = 0; -- 玩家x坐标
	posY = 0; -- 玩家y坐标
	roleName = ""; -- 人物名称
	level = 0; -- 等级
	score = 0; -- 北仓界分数
}
]]

RespBcjMapPlayerMsg.meta = {__index = RespBcjMapPlayerMsg};
function RespBcjMapPlayerMsg:new()
	local obj = setmetatable( {}, RespBcjMapPlayerMsg.meta);
	return obj;
end

function RespBcjMapPlayerMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.roleList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local roleListVo = {};
		roleListVo.roleId, idx = readGuid(pak, idx);
		roleListVo.posX, idx = readInt(pak, idx);
		roleListVo.posY, idx = readInt(pak, idx);
		roleListVo.roleName, idx = readString(pak, idx, 32);
		roleListVo.level, idx = readInt(pak, idx);
		roleListVo.score, idx = readInt(pak, idx);
		table.push(list1,roleListVo);
	end

end



--[[
返回挑战首通结果
]]

_G.RespZhuZaiRoadFirstChallengeMsg = {};

RespZhuZaiRoadFirstChallengeMsg.msgId = 8409;
RespZhuZaiRoadFirstChallengeMsg.id = 0; -- 挑战id



RespZhuZaiRoadFirstChallengeMsg.meta = {__index = RespZhuZaiRoadFirstChallengeMsg};
function RespZhuZaiRoadFirstChallengeMsg:new()
	local obj = setmetatable( {}, RespZhuZaiRoadFirstChallengeMsg.meta);
	return obj;
end

function RespZhuZaiRoadFirstChallengeMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
服务器通知:免费传送次数
]]

_G.RespTeleportFreeTimeMsg = {};

RespTeleportFreeTimeMsg.msgId = 8412;
RespTeleportFreeTimeMsg.time = 0; -- 免费传送次数(玩家初始有n次, 低于n后每小时恢复1次,最大累积n次,每日0点重置为n次.n在常量表配置)



RespTeleportFreeTimeMsg.meta = {__index = RespTeleportFreeTimeMsg};
function RespTeleportFreeTimeMsg:new()
	local obj = setmetatable( {}, RespTeleportFreeTimeMsg.meta);
	return obj;
end

function RespTeleportFreeTimeMsg:ParseData(pak)
	local idx = 1;

	self.time, idx = readByte(pak, idx);

end



--[[
服务器通知:灵阵信息
]]

_G.RespLingzhenInfoMsg = {};

RespLingzhenInfoMsg.msgId = 8413;
RespLingzhenInfoMsg.level = 0; -- 灵阵等阶
RespLingzhenInfoMsg.blessing = 0; -- 进阶祝福值
RespLingzhenInfoMsg.pillNum = 0; -- 属性丹数量



RespLingzhenInfoMsg.meta = {__index = RespLingzhenInfoMsg};
function RespLingzhenInfoMsg:new()
	local obj = setmetatable( {}, RespLingzhenInfoMsg.meta);
	return obj;
end

function RespLingzhenInfoMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);
	self.blessing, idx = readInt(pak, idx);
	self.pillNum, idx = readInt(pak, idx);

end



--[[
服务器返回：灵阵进阶
]]

_G.RespLingzhenLevelUpMsg = {};

RespLingzhenLevelUpMsg.msgId = 8414;
RespLingzhenLevelUpMsg.result = 0; -- 请求进阶结果 0:成功(成功获得祝福值), 2:灵阵未解锁, 3:已达等级上限, 4:熟练度不够, 5:金币不够, 6:道具数量不足
RespLingzhenLevelUpMsg.blessing = 0; -- 进阶后的祝福值



RespLingzhenLevelUpMsg.meta = {__index = RespLingzhenLevelUpMsg};
function RespLingzhenLevelUpMsg:new()
	local obj = setmetatable( {}, RespLingzhenLevelUpMsg.meta);
	return obj;
end

function RespLingzhenLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.blessing, idx = readInt(pak, idx);

end



--[[
服务器返回：进入data
]]

_G.RespExtremityEnterDataMsg = {};

RespExtremityEnterDataMsg.msgId = 8416;
RespExtremityEnterDataMsg.result = 0; -- 进入结果 0 成功 
RespExtremityEnterDataMsg.state = 0; -- 进入结果类型 1 BOSS 2 小怪



RespExtremityEnterDataMsg.meta = {__index = RespExtremityEnterDataMsg};
function RespExtremityEnterDataMsg:new()
	local obj = setmetatable( {}, RespExtremityEnterDataMsg.meta);
	return obj;
end

function RespExtremityEnterDataMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
服务器返回：BOSS面板数据
]]

_G.RespExtremityBossDataMsg = {};

RespExtremityBossDataMsg.msgId = 8417;
RespExtremityBossDataMsg.harm = 0; -- 累积伤害



RespExtremityBossDataMsg.meta = {__index = RespExtremityBossDataMsg};
function RespExtremityBossDataMsg:new()
	local obj = setmetatable( {}, RespExtremityBossDataMsg.meta);
	return obj;
end

function RespExtremityBossDataMsg:ParseData(pak)
	local idx = 1;

	self.harm, idx = readInt64(pak, idx);

end



--[[
服务器返回：Monster面板数据
]]

_G.RespExtremityMonsterDataMsg = {};

RespExtremityMonsterDataMsg.msgId = 8418;
RespExtremityMonsterDataMsg.killNum = 0; -- 击杀数量



RespExtremityMonsterDataMsg.meta = {__index = RespExtremityMonsterDataMsg};
function RespExtremityMonsterDataMsg:new()
	local obj = setmetatable( {}, RespExtremityMonsterDataMsg.meta);
	return obj;
end

function RespExtremityMonsterDataMsg:ParseData(pak)
	local idx = 1;

	self.killNum, idx = readInt(pak, idx);

end



--[[
服务器返回：结局面板数据
]]

_G.RespExtremityResultDataMsg = {};

RespExtremityResultDataMsg.msgId = 8419;
RespExtremityResultDataMsg.state = 0; -- 类型 0 BOSS
RespExtremityResultDataMsg.num = 0; -- 数据



RespExtremityResultDataMsg.meta = {__index = RespExtremityResultDataMsg};
function RespExtremityResultDataMsg:new()
	local obj = setmetatable( {}, RespExtremityResultDataMsg.meta);
	return obj;
end

function RespExtremityResultDataMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);
	self.num, idx = readInt64(pak, idx);

end



--[[
服务器返回：退出
]]

_G.RespExtremityQuitMsg = {};

RespExtremityQuitMsg.msgId = 8420;
RespExtremityQuitMsg.result = 0; -- 退出结果 0 成功 



RespExtremityQuitMsg.meta = {__index = RespExtremityQuitMsg};
function RespExtremityQuitMsg:new()
	local obj = setmetatable( {}, RespExtremityQuitMsg.meta);
	return obj;
end

function RespExtremityQuitMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器通知:灵兽墓地信息
]]

_G.RespLingShouMuDiInfoMsg = {};

RespLingShouMuDiInfoMsg.msgId = 8421;
RespLingShouMuDiInfoMsg.finishlayer = 0; -- 已通关的层数
RespLingShouMuDiInfoMsg.mymaxlayer = 0; -- 我的最好层数
RespLingShouMuDiInfoMsg.firstroleName = ""; -- 第一名角色名字
RespLingShouMuDiInfoMsg.firstheadID = 0; -- 头像id
RespLingShouMuDiInfoMsg.firstlayer = 0; -- 第一名的最高层数



RespLingShouMuDiInfoMsg.meta = {__index = RespLingShouMuDiInfoMsg};
function RespLingShouMuDiInfoMsg:new()
	local obj = setmetatable( {}, RespLingShouMuDiInfoMsg.meta);
	return obj;
end

function RespLingShouMuDiInfoMsg:ParseData(pak)
	local idx = 1;

	self.finishlayer, idx = readInt(pak, idx);
	self.mymaxlayer, idx = readInt(pak, idx);
	self.firstroleName, idx = readString(pak, idx, 32);
	self.firstheadID, idx = readInt(pak, idx);
	self.firstlayer, idx = readInt(pak, idx);

end



--[[
服务器返回：返回进入灵兽墓地结果
]]

_G.RespChallLingShouMuDiMsg = {};

RespChallLingShouMuDiMsg.msgId = 8422;
RespChallLingShouMuDiMsg.result = 0; -- 返回结果 0:成功, 1:失败
RespChallLingShouMuDiMsg.layer = 0; -- 挑战层数



RespChallLingShouMuDiMsg.meta = {__index = RespChallLingShouMuDiMsg};
function RespChallLingShouMuDiMsg:new()
	local obj = setmetatable( {}, RespChallLingShouMuDiMsg.meta);
	return obj;
end

function RespChallLingShouMuDiMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.layer, idx = readInt(pak, idx);

end



--[[
服务器返回：灵兽墓地怪物波数信息
]]

_G.RespLSMDMonsterInfoMsg = {};

RespLSMDMonsterInfoMsg.msgId = 8423;
RespLSMDMonsterInfoMsg.num = 0; -- 怪物波数
RespLSMDMonsterInfoMsg.monID = 0; -- 怪物ID
RespLSMDMonsterInfoMsg.monNum = 0; -- 怪物个数



RespLSMDMonsterInfoMsg.meta = {__index = RespLSMDMonsterInfoMsg};
function RespLSMDMonsterInfoMsg:new()
	local obj = setmetatable( {}, RespLSMDMonsterInfoMsg.meta);
	return obj;
end

function RespLSMDMonsterInfoMsg:ParseData(pak)
	local idx = 1;

	self.num, idx = readInt(pak, idx);
	self.monID, idx = readInt(pak, idx);
	self.monNum, idx = readInt(pak, idx);

end



--[[
服务器返回:挑战灵兽墓地结果
]]

_G.RespChallLSMDResult = {};

RespChallLSMDResult.msgId = 8424;
RespChallLSMDResult.result = 0; -- 结果 0成功 1失败



RespChallLSMDResult.meta = {__index = RespChallLSMDResult};
function RespChallLSMDResult:new()
	local obj = setmetatable( {}, RespChallLSMDResult.meta);
	return obj;
end

function RespChallLSMDResult:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
服务器返回:获得奖励结果
]]

_G.RespLSMDGetAwardMsg = {};

RespLSMDGetAwardMsg.msgId = 8425;
RespLSMDGetAwardMsg.result = 0; -- 结果 0成功 1失败



RespLSMDGetAwardMsg.meta = {__index = RespLSMDGetAwardMsg};
function RespLSMDGetAwardMsg:new()
	local obj = setmetatable( {}, RespLSMDGetAwardMsg.meta);
	return obj;
end

function RespLSMDGetAwardMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
服务器返回：返回灵兽墓地排行榜
]]

_G.RespLingShouMuDiRanklistMsg = {};

RespLingShouMuDiRanklistMsg.msgId = 8426;
RespLingShouMuDiRanklistMsg.list_size = 10; -- 排行列表 size
RespLingShouMuDiRanklistMsg.list = {}; -- 排行列表 list



--[[
listvoVO = {
	name = ""; -- 名称
	rank = 0; -- 名次
	num = 0; -- 通关层数
}
]]

RespLingShouMuDiRanklistMsg.meta = {__index = RespLingShouMuDiRanklistMsg};
function RespLingShouMuDiRanklistMsg:new()
	local obj = setmetatable( {}, RespLingShouMuDiRanklistMsg.meta);
	return obj;
end

function RespLingShouMuDiRanklistMsg:ParseData(pak)
	local idx = 1;


	local list = {};
	self.list = list;
	local listSize = 10;

	for i=1,listSize do
		local listvoVo = {};
		listvoVo.name, idx = readString(pak, idx, 32);
		listvoVo.rank, idx = readInt(pak, idx);
		listvoVo.num, idx = readInt(pak, idx);
		table.push(list,listvoVo);
	end

end



--[[
返回设置技能栏物品,登录推
]]

_G.RespItemShortCutMsg = {};

RespItemShortCutMsg.msgId = 8427;
RespItemShortCutMsg.itemId = 0; -- 物品id



RespItemShortCutMsg.meta = {__index = RespItemShortCutMsg};
function RespItemShortCutMsg:new()
	local obj = setmetatable( {}, RespItemShortCutMsg.meta);
	return obj;
end

function RespItemShortCutMsg:ParseData(pak)
	local idx = 1;

	self.itemId, idx = readInt(pak, idx);

end



--[[
服务器通知:萌宠信息
]]

_G.RespLovelyPetInfoMsg = {};

RespLovelyPetInfoMsg.msgId = 8428;
RespLovelyPetInfoMsg.list_size = 0; -- 萌宠列表 size
RespLovelyPetInfoMsg.list = {}; -- 萌宠列表 list



--[[
listvoVO = {
	id = 0; -- Id
	state = 0; -- 0未激活，1休息，2出战，3过期
	time = 0; -- 剩余时间
}
]]

RespLovelyPetInfoMsg.meta = {__index = RespLovelyPetInfoMsg};
function RespLovelyPetInfoMsg:new()
	local obj = setmetatable( {}, RespLovelyPetInfoMsg.meta);
	return obj;
end

function RespLovelyPetInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listvoVo = {};
		listvoVo.id, idx = readInt(pak, idx);
		listvoVo.state, idx = readInt(pak, idx);
		listvoVo.time, idx = readInt64(pak, idx);
		table.push(list1,listvoVo);
	end

end



--[[
服务器返回:激活萌宠结果
]]

_G.RespActiveLovelyPetMsg = {};

RespActiveLovelyPetMsg.msgId = 8429;
RespActiveLovelyPetMsg.result = 0; -- 结果 0成功 1失败
RespActiveLovelyPetMsg.id = 0; -- 萌宠id



RespActiveLovelyPetMsg.meta = {__index = RespActiveLovelyPetMsg};
function RespActiveLovelyPetMsg:new()
	local obj = setmetatable( {}, RespActiveLovelyPetMsg.meta);
	return obj;
end

function RespActiveLovelyPetMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
服务器返回:到期了或者添加新的
]]

_G.RespLovelyPetTimeOverMsg = {};

RespLovelyPetTimeOverMsg.msgId = 8430;
RespLovelyPetTimeOverMsg.id = 0; -- 萌宠id
RespLovelyPetTimeOverMsg.time = 0; -- 剩余时间



RespLovelyPetTimeOverMsg.meta = {__index = RespLovelyPetTimeOverMsg};
function RespLovelyPetTimeOverMsg:new()
	local obj = setmetatable( {}, RespLovelyPetTimeOverMsg.meta);
	return obj;
end

function RespLovelyPetTimeOverMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.time, idx = readInt64(pak, idx);

end



--[[
服务器返回:派出萌宠或者休息结果
]]

_G.RespSendLovelyPetMsg = {};

RespSendLovelyPetMsg.msgId = 8431;
RespSendLovelyPetMsg.result = 0; -- 结果 0成功 1失败
RespSendLovelyPetMsg.id = 0; -- 萌宠id
RespSendLovelyPetMsg.state = 0; -- 1休息，2出战



RespSendLovelyPetMsg.meta = {__index = RespSendLovelyPetMsg};
function RespSendLovelyPetMsg:new()
	local obj = setmetatable( {}, RespSendLovelyPetMsg.meta);
	return obj;
end

function RespSendLovelyPetMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.id, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
服务器返回：退出灵兽墓地结果
]]

_G.RespLingShouMuDiQuitMsg = {};

RespLingShouMuDiQuitMsg.msgId = 8432;
RespLingShouMuDiQuitMsg.result = 0; -- 返回结果 0:成功, 1:失败



RespLingShouMuDiQuitMsg.meta = {__index = RespLingShouMuDiQuitMsg};
function RespLingShouMuDiQuitMsg:new()
	local obj = setmetatable( {}, RespLingShouMuDiQuitMsg.meta);
	return obj;
end

function RespLingShouMuDiQuitMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
服务器返回:续费萌宠结果
]]

_G.RespRenewLovelyPetMsg = {};

RespRenewLovelyPetMsg.msgId = 8433;
RespRenewLovelyPetMsg.result = 0; -- 结果 0成功 1失败
RespRenewLovelyPetMsg.id = 0; -- 萌宠id
RespRenewLovelyPetMsg.time = 0; -- 剩余时间



RespRenewLovelyPetMsg.meta = {__index = RespRenewLovelyPetMsg};
function RespRenewLovelyPetMsg:new()
	local obj = setmetatable( {}, RespRenewLovelyPetMsg.meta);
	return obj;
end

function RespRenewLovelyPetMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.id, idx = readInt(pak, idx);
	self.time, idx = readInt64(pak, idx);

end



--[[
服务器返回:流水副本信息
]]

_G.RespWaterDungeonInfoMsg = {};

RespWaterDungeonInfoMsg.msgId = 8434;
RespWaterDungeonInfoMsg.wave = 0; -- 我的最佳波数
RespWaterDungeonInfoMsg.exp = 0; -- 我的最高经验
RespWaterDungeonInfoMsg.time = 0; -- 已用次数
RespWaterDungeonInfoMsg.monster = 0; -- 我的最多杀怪
RespWaterDungeonInfoMsg.moreExp = 0; -- 今天可额外领取的经验
RespWaterDungeonInfoMsg.moreReward = 0; -- 0不可以额外领取,1可以额外领取



RespWaterDungeonInfoMsg.meta = {__index = RespWaterDungeonInfoMsg};
function RespWaterDungeonInfoMsg:new()
	local obj = setmetatable( {}, RespWaterDungeonInfoMsg.meta);
	return obj;
end

function RespWaterDungeonInfoMsg:ParseData(pak)
	local idx = 1;

	self.wave, idx = readInt(pak, idx);
	self.exp, idx = readDouble(pak, idx);
	self.time, idx = readByte(pak, idx);
	self.monster, idx = readInt(pak, idx);
	self.moreExp, idx = readDouble(pak, idx);
	self.moreReward, idx = readByte(pak, idx);

end



--[[
服务器返回:流水副本排行榜
]]

_G.RespWaterDungeonRankMsg = {};

RespWaterDungeonRankMsg.msgId = 8435;
RespWaterDungeonRankMsg.rankList_size = 10; -- 排行榜列表 size
RespWaterDungeonRankMsg.rankList = {}; -- 排行榜列表 list



--[[
rankListVO = {
	roleId = ""; -- 玩家id
	name = ""; -- 玩家名字
	icon = 0; -- 玩家头像id
	wave = 0; -- 最佳波数
}
]]

RespWaterDungeonRankMsg.meta = {__index = RespWaterDungeonRankMsg};
function RespWaterDungeonRankMsg:new()
	local obj = setmetatable( {}, RespWaterDungeonRankMsg.meta);
	return obj;
end

function RespWaterDungeonRankMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.rankList = list1;
	local list1Size = 10;

	for i=1,list1Size do
		local rankListVo = {};
		rankListVo.roleId, idx = readGuid(pak, idx);
		rankListVo.name, idx = readString(pak, idx, 32);
		rankListVo.icon, idx = readInt(pak, idx);
		rankListVo.wave, idx = readInt(pak, idx);
		table.push(list1,rankListVo);
	end

end



--[[
服务器返回:流水副本进度
]]

_G.RespWaterDungeonProgressMsg = {};

RespWaterDungeonProgressMsg.msgId = 8436;
RespWaterDungeonProgressMsg.wave = 0; -- 当前波数
RespWaterDungeonProgressMsg.monster = 0; -- 当前波杀怪数
RespWaterDungeonProgressMsg.exp = 0; -- 累计获得经验
RespWaterDungeonProgressMsg.totalKillMonster = 0; -- 累计击杀怪物数量



RespWaterDungeonProgressMsg.meta = {__index = RespWaterDungeonProgressMsg};
function RespWaterDungeonProgressMsg:new()
	local obj = setmetatable( {}, RespWaterDungeonProgressMsg.meta);
	return obj;
end

function RespWaterDungeonProgressMsg:ParseData(pak)
	local idx = 1;

	self.wave, idx = readInt(pak, idx);
	self.monster, idx = readInt(pak, idx);
	self.exp, idx = readDouble(pak, idx);
	self.totalKillMonster, idx = readInt(pak, idx);

end



--[[
服务器返回:流水副本结算
]]

_G.RespWaterDungeonResultMsg = {};

RespWaterDungeonResultMsg.msgId = 8437;
RespWaterDungeonResultMsg.wave = 0; -- 累计波数
RespWaterDungeonResultMsg.exp = 0; -- 累计获得经验



RespWaterDungeonResultMsg.meta = {__index = RespWaterDungeonResultMsg};
function RespWaterDungeonResultMsg:new()
	local obj = setmetatable( {}, RespWaterDungeonResultMsg.meta);
	return obj;
end

function RespWaterDungeonResultMsg:ParseData(pak)
	local idx = 1;

	self.wave, idx = readInt(pak, idx);
	self.exp, idx = readDouble(pak, idx);

end



--[[
服务器上线推
]]

_G.RespWishInfoUpdataMsg = {};

RespWishInfoUpdataMsg.msgId = 8438;
RespWishInfoUpdataMsg.list_size = 0; -- 物品列表 size
RespWishInfoUpdataMsg.list = {}; -- 物品列表 list



--[[
listvoVO = {
	id = 0; -- itemId
	lastnum = 0; -- 剩余次数
	withnum = 0; -- 今日已用次数
}
]]

RespWishInfoUpdataMsg.meta = {__index = RespWishInfoUpdataMsg};
function RespWishInfoUpdataMsg:new()
	local obj = setmetatable( {}, RespWishInfoUpdataMsg.meta);
	return obj;
end

function RespWishInfoUpdataMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listvoVo = {};
		listvoVo.id, idx = readInt(pak, idx);
		listvoVo.lastnum, idx = readInt(pak, idx);
		listvoVo.withnum, idx = readInt(pak, idx);
		table.push(list1,listvoVo);
	end

end



--[[
服务器返回:进入流水副本结果
]]

_G.RespWaterDungeonEnterResultMsg = {};

RespWaterDungeonEnterResultMsg.msgId = 8439;
RespWaterDungeonEnterResultMsg.result = 0; -- 0:成功 1:功能未开启 2: 副本次数已用完



RespWaterDungeonEnterResultMsg.meta = {__index = RespWaterDungeonEnterResultMsg};
function RespWaterDungeonEnterResultMsg:new()
	local obj = setmetatable( {}, RespWaterDungeonEnterResultMsg.meta);
	return obj;
end

function RespWaterDungeonEnterResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
服务器返回:退出流水副本结果
]]

_G.RespWaterDungeonExitResultMsg = {};

RespWaterDungeonExitResultMsg.msgId = 8440;
RespWaterDungeonExitResultMsg.result = 0; -- 0:成功



RespWaterDungeonExitResultMsg.meta = {__index = RespWaterDungeonExitResultMsg};
function RespWaterDungeonExitResultMsg:new()
	local obj = setmetatable( {}, RespWaterDungeonExitResultMsg.meta);
	return obj;
end

function RespWaterDungeonExitResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
返回装备新卓越信息
]]

_G.RespEquipNewSuperMsg = {};

RespEquipNewSuperMsg.msgId = 8447;
RespEquipNewSuperMsg.list_size = 0; -- 装备list size
RespEquipNewSuperMsg.list = {}; -- 装备list list



--[[
EquipNewSuperListVOVO = {
	id = ""; -- 装备cid
	newSuperList_size = 3; -- 新卓越属性列表 size
	newSuperList = {}; -- 新卓越属性列表 list
}
NewSuperVOVO = {
	id = 0; -- 新卓越id
	wash = 0; -- 洗练值
}
]]

RespEquipNewSuperMsg.meta = {__index = RespEquipNewSuperMsg};
function RespEquipNewSuperMsg:new()
	local obj = setmetatable( {}, RespEquipNewSuperMsg.meta);
	return obj;
end

function RespEquipNewSuperMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local EquipNewSuperListVOVo = {};
		EquipNewSuperListVOVo.id, idx = readGuid(pak, idx);
		table.push(list1,EquipNewSuperListVOVo);

		local list2 = {};
		EquipNewSuperListVOVo.newSuperList = list2;
		local list2Size = 3;

		for i=1,list2Size do
			local NewSuperVOVo = {};
			NewSuperVOVo.id, idx = readInt(pak, idx);
			NewSuperVOVo.wash, idx = readInt(pak, idx);
			table.push(list2,NewSuperVOVo);
		end
	end

end



--[[
祈愿结果
]]

_G.RespWishInfoResultMsg = {};

RespWishInfoResultMsg.msgId = 8448;
RespWishInfoResultMsg.type = 0; -- 类型，发itemID
RespWishInfoResultMsg.result = 0; -- 结果 0成功 



RespWishInfoResultMsg.meta = {__index = RespWishInfoResultMsg};
function RespWishInfoResultMsg:new()
	local obj = setmetatable( {}, RespWishInfoResultMsg.meta);
	return obj;
end

function RespWishInfoResultMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
精力购买次数
]]

_G.RespJingLiBuyNumMsg = {};

RespJingLiBuyNumMsg.msgId = 8449;
RespJingLiBuyNumMsg.num = 0; -- 已购买的次数



RespJingLiBuyNumMsg.meta = {__index = RespJingLiBuyNumMsg};
function RespJingLiBuyNumMsg:new()
	local obj = setmetatable( {}, RespJingLiBuyNumMsg.meta);
	return obj;
end

function RespJingLiBuyNumMsg:ParseData(pak)
	local idx = 1;

	self.num, idx = readInt(pak, idx);

end



--[[
登录同步物品CD
]]

_G.RespItemCDListMsg = {};

RespItemCDListMsg.msgId = 8450;
RespItemCDListMsg.list_size = 0; -- 物品组list size
RespItemCDListMsg.list = {}; -- 物品组list list



--[[
ItemCDListVOVO = {
	groupId = 0; -- 物品组id
	cdTime = 0; -- 冷却时间
}
]]

RespItemCDListMsg.meta = {__index = RespItemCDListMsg};
function RespItemCDListMsg:new()
	local obj = setmetatable( {}, RespItemCDListMsg.meta);
	return obj;
end

function RespItemCDListMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local ItemCDListVOVo = {};
		ItemCDListVOVo.groupId, idx = readInt(pak, idx);
		ItemCDListVOVo.cdTime, idx = readInt(pak, idx);
		table.push(list1,ItemCDListVOVo);
	end

end



--[[
登录同步技能CD
]]

_G.RespSkillCDListMsg = {};

RespSkillCDListMsg.msgId = 8451;
RespSkillCDListMsg.list_size = 0; -- 技能list size
RespSkillCDListMsg.list = {}; -- 技能list list



--[[
SkillCDListVOVO = {
	skillID = 0; -- 技能ID
	cdTime = 0; -- 冷却时间
}
]]

RespSkillCDListMsg.meta = {__index = RespSkillCDListMsg};
function RespSkillCDListMsg:new()
	local obj = setmetatable( {}, RespSkillCDListMsg.meta);
	return obj;
end

function RespSkillCDListMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local SkillCDListVOVo = {};
		SkillCDListVOVo.skillID, idx = readInt(pak, idx);
		SkillCDListVOVo.cdTime, idx = readInt(pak, idx);
		table.push(list1,SkillCDListVOVo);
	end

end



--[[
返回身上道具信息
]]

_G.RespOtherBodyToolMsg = {};

RespOtherBodyToolMsg.msgId = 8452;
RespOtherBodyToolMsg.serverType = 0; -- 是否全服排行信息 1=是 其余都不是
RespOtherBodyToolMsg.type = 0; -- 1== 详细信息，2 == 排行榜详细信息
RespOtherBodyToolMsg.roleID = ""; -- 角色ID
RespOtherBodyToolMsg.list_size = 0; -- 道具list size
RespOtherBodyToolMsg.list = {}; -- 道具list list



--[[
OtherBodyToolVOVO = {
	wing = 0; -- 翅膀itemid
	wingState = 0; -- 绑定状态
	val1 = 0; -- 翅膀时代表过期时间
	val2 = 0; -- 翅膀时代表是否特殊属性
}
]]

RespOtherBodyToolMsg.meta = {__index = RespOtherBodyToolMsg};
function RespOtherBodyToolMsg:new()
	local obj = setmetatable( {}, RespOtherBodyToolMsg.meta);
	return obj;
end

function RespOtherBodyToolMsg:ParseData(pak)
	local idx = 1;

	self.serverType, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);
	self.roleID, idx = readGuid(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local OtherBodyToolVOVo = {};
		OtherBodyToolVOVo.wing, idx = readInt(pak, idx);
		OtherBodyToolVOVo.wingState, idx = readInt(pak, idx);
		OtherBodyToolVOVo.val1, idx = readInt(pak, idx);
		OtherBodyToolVOVo.val2, idx = readInt(pak, idx);
		table.push(list1,OtherBodyToolVOVo);
	end

end



--[[
极限挑战自己的历史最高
]]

_G.RespExtremitHistoryRankMsg = {};

RespExtremitHistoryRankMsg.msgId = 8453;
RespExtremitHistoryRankMsg.bossHarm = 0; -- BOSS历史最高
RespExtremitHistoryRankMsg.monsterNum = 0; -- 小怪历史最高



RespExtremitHistoryRankMsg.meta = {__index = RespExtremitHistoryRankMsg};
function RespExtremitHistoryRankMsg:new()
	local obj = setmetatable( {}, RespExtremitHistoryRankMsg.meta);
	return obj;
end

function RespExtremitHistoryRankMsg:ParseData(pak)
	local idx = 1;

	self.bossHarm, idx = readInt64(pak, idx);
	self.monsterNum, idx = readInt(pak, idx);

end



--[[
服务器通知:他人灵阵信息
]]

_G.RespOhterLingzhenInfoMsg = {};

RespOhterLingzhenInfoMsg.msgId = 8454;
RespOhterLingzhenInfoMsg.serverType = 0; -- 是否全服排行信息 1=是 其余都不是
RespOhterLingzhenInfoMsg.type = 0; -- 1== 详细信息，2 == 排行榜详细信息
RespOhterLingzhenInfoMsg.roleID = ""; -- 角色ID
RespOhterLingzhenInfoMsg.level = 0; -- 灵阵等阶
RespOhterLingzhenInfoMsg.skills_size = 0; -- 技能列表 size
RespOhterLingzhenInfoMsg.skills = {}; -- 技能列表 list



--[[
SkillInfoVO = {
	skillId = 0; -- 技能id
}
]]

RespOhterLingzhenInfoMsg.meta = {__index = RespOhterLingzhenInfoMsg};
function RespOhterLingzhenInfoMsg:new()
	local obj = setmetatable( {}, RespOhterLingzhenInfoMsg.meta);
	return obj;
end

function RespOhterLingzhenInfoMsg:ParseData(pak)
	local idx = 1;

	self.serverType, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);
	self.roleID, idx = readGuid(pak, idx);
	self.level, idx = readInt(pak, idx);

	local list1 = {};
	self.skills = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local SkillInfoVo = {};
		SkillInfoVo.skillId, idx = readInt(pak, idx);
		table.push(list1,SkillInfoVo);
	end

end



--[[
服务器通知:该采集物已被采集
]]

_G.RespCollectionStateMsg = {};

RespCollectionStateMsg.msgId = 8455;
RespCollectionStateMsg.cid = ""; -- 采集物ID



RespCollectionStateMsg.meta = {__index = RespCollectionStateMsg};
function RespCollectionStateMsg:new()
	local obj = setmetatable( {}, RespCollectionStateMsg.meta);
	return obj;
end

function RespCollectionStateMsg:ParseData(pak)
	local idx = 1;

	self.cid, idx = readGuid(pak, idx);

end



--[[
服务器通知:神兵换模型结果
]]

_G.RespMagicWeaponChangeModelMsg = {};

RespMagicWeaponChangeModelMsg.msgId = 8456;
RespMagicWeaponChangeModelMsg.level = 0; -- 成功时：更换后的模型等阶；失败时：-1：等阶不够：-2：其他



RespMagicWeaponChangeModelMsg.meta = {__index = RespMagicWeaponChangeModelMsg};
function RespMagicWeaponChangeModelMsg:new()
	local obj = setmetatable( {}, RespMagicWeaponChangeModelMsg.meta);
	return obj;
end

function RespMagicWeaponChangeModelMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);

end



--[[
服务器通知:vip经验
]]

_G.RespVipExpMsg = {};

RespVipExpMsg.msgId = 8457;
RespVipExpMsg.exp = 0; -- vip经验



RespVipExpMsg.meta = {__index = RespVipExpMsg};
function RespVipExpMsg:new()
	local obj = setmetatable( {}, RespVipExpMsg.meta);
	return obj;
end

function RespVipExpMsg:ParseData(pak)
	local idx = 1;

	self.exp, idx = readInt64(pak, idx);

end



--[[
服务器通知:vip剩余时间
]]

_G.RespVipPeriodMsg = {};

RespVipPeriodMsg.msgId = 8458;
RespVipPeriodMsg.period_size = 0; -- 不同类型vip剩余期限列表 size
RespVipPeriodMsg.period = {}; -- 不同类型vip剩余期限列表 list



--[[
periodVO = {
	vipType = 0; -- vip类型id(黄金1/钻石2/至尊3)
	time = 0; -- 到期时间(h), -1表示未激活, 0表示已到期
}
]]

RespVipPeriodMsg.meta = {__index = RespVipPeriodMsg};
function RespVipPeriodMsg:new()
	local obj = setmetatable( {}, RespVipPeriodMsg.meta);
	return obj;
end

function RespVipPeriodMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.period = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local periodVo = {};
		periodVo.vipType, idx = readInt(pak, idx);
		periodVo.time, idx = readInt64(pak, idx);
		table.push(list1,periodVo);
	end

end



--[[
服务器通知:vip等级奖励未领取
]]

_G.RespVipLevelRewardStateMsg = {};

RespVipLevelRewardStateMsg.msgId = 8459;
RespVipLevelRewardStateMsg.levelRewardState_size = 0; -- vip等级奖励领取状态，未领取 size
RespVipLevelRewardStateMsg.levelRewardState = {}; -- vip等级奖励领取状态，未领取 list



--[[
levelRewardStateVO = {
	vipLevel = 0; -- 奖励对应的vip等级
}
]]

RespVipLevelRewardStateMsg.meta = {__index = RespVipLevelRewardStateMsg};
function RespVipLevelRewardStateMsg:new()
	local obj = setmetatable( {}, RespVipLevelRewardStateMsg.meta);
	return obj;
end

function RespVipLevelRewardStateMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.levelRewardState = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local levelRewardStateVo = {};
		levelRewardStateVo.vipLevel, idx = readInt(pak, idx);
		table.push(list1,levelRewardStateVo);
	end

end



--[[
服务器通知:vip周奖励领取状态
]]

_G.RespVipWeekRewardStateMsg = {};

RespVipWeekRewardStateMsg.msgId = 8460;
RespVipWeekRewardStateMsg.state = 0; -- 1:已领取 0:未领取



RespVipWeekRewardStateMsg.meta = {__index = RespVipWeekRewardStateMsg};
function RespVipWeekRewardStateMsg:new()
	local obj = setmetatable( {}, RespVipWeekRewardStateMsg.meta);
	return obj;
end

function RespVipWeekRewardStateMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);

end



--[[
服务器通知:续费(激活)vip结果
]]

_G.RespVipRenewMsg = {};

RespVipRenewMsg.msgId = 8461;
RespVipRenewMsg.result = 0; -- 结果:0成功 1:元宝不足
RespVipRenewMsg.vipType = 0; -- vip类型id(黄金1/钻石2/至尊3)
RespVipRenewMsg.time = 0; -- 到期时间(h), -1表示未激活, 0表示已到期



RespVipRenewMsg.meta = {__index = RespVipRenewMsg};
function RespVipRenewMsg:new()
	local obj = setmetatable( {}, RespVipRenewMsg.meta);
	return obj;
end

function RespVipRenewMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.vipType, idx = readInt(pak, idx);
	self.time, idx = readInt64(pak, idx);

end



--[[
服务器通知:领取vip等级奖励结果
]]

_G.RespVipLevelRewardAcceptMsg = {};

RespVipLevelRewardAcceptMsg.msgId = 8462;
RespVipLevelRewardAcceptMsg.result = 0; -- 结果:0成功
RespVipLevelRewardAcceptMsg.vipLevel = 0; -- 奖励对应的vip等级



RespVipLevelRewardAcceptMsg.meta = {__index = RespVipLevelRewardAcceptMsg};
function RespVipLevelRewardAcceptMsg:new()
	local obj = setmetatable( {}, RespVipLevelRewardAcceptMsg.meta);
	return obj;
end

function RespVipLevelRewardAcceptMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.vipLevel, idx = readInt(pak, idx);

end



--[[
服务器通知:领取vip每周奖励结果
]]

_G.RespVipWeekRewardAcceptMsg = {};

RespVipWeekRewardAcceptMsg.msgId = 8463;
RespVipWeekRewardAcceptMsg.result = 0; -- 结果:0成功



RespVipWeekRewardAcceptMsg.meta = {__index = RespVipWeekRewardAcceptMsg};
function RespVipWeekRewardAcceptMsg:new()
	local obj = setmetatable( {}, RespVipWeekRewardAcceptMsg.meta);
	return obj;
end

function RespVipWeekRewardAcceptMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器通知:翅膀合成结果
]]

_G.RespWingHeChengMsg = {};

RespWingHeChengMsg.msgId = 8464;
RespWingHeChengMsg.result = 0; -- 结果:0成功，1错误，2材料不足，3银两不足，4背包已满



RespWingHeChengMsg.meta = {__index = RespWingHeChengMsg};
function RespWingHeChengMsg:new()
	local obj = setmetatable( {}, RespWingHeChengMsg.meta);
	return obj;
end

function RespWingHeChengMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
服务器返回:设置装备套装
]]

_G.RespEquipGroupMsg = {};

RespEquipGroupMsg.msgId = 8465;
RespEquipGroupMsg.result = 0; -- 结果:0成功,1装备不存在,2道具不存在,3物品无法使用
RespEquipGroupMsg.equipId = ""; -- 装备uid
RespEquipGroupMsg.itemId = ""; -- 物品uid
RespEquipGroupMsg.itemTid = 0; -- 物品tid



RespEquipGroupMsg.meta = {__index = RespEquipGroupMsg};
function RespEquipGroupMsg:new()
	local obj = setmetatable( {}, RespEquipGroupMsg.meta);
	return obj;
end

function RespEquipGroupMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.equipId, idx = readGuid(pak, idx);
	self.itemId, idx = readGuid(pak, idx);
	self.itemTid, idx = readInt(pak, idx);

end



--[[
服务器返回:增加奇遇任务
]]

_G.RespRandomQuestAddMsg = {};

RespRandomQuestAddMsg.msgId = 8466;
RespRandomQuestAddMsg.id = 0; -- 奇遇任务id
RespRandomQuestAddMsg.state = 0; -- 任务状态,1进行中,2可交
RespRandomQuestAddMsg.round = 0; -- 是当天的第几组任务



RespRandomQuestAddMsg.meta = {__index = RespRandomQuestAddMsg};
function RespRandomQuestAddMsg:new()
	local obj = setmetatable( {}, RespRandomQuestAddMsg.meta);
	return obj;
end

function RespRandomQuestAddMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);
	self.round, idx = readInt(pak, idx);

end



--[[
服务器返回:更新奇遇任务
]]

_G.RespRandomQuestUpdateMsg = {};

RespRandomQuestUpdateMsg.msgId = 8467;
RespRandomQuestUpdateMsg.id = 0; -- 奇遇任务id
RespRandomQuestUpdateMsg.state = 0; -- 任务状态,1进行中,2可交
RespRandomQuestUpdateMsg.count = 0; -- 已完成数目(如杀死多少个怪物)



RespRandomQuestUpdateMsg.meta = {__index = RespRandomQuestUpdateMsg};
function RespRandomQuestUpdateMsg:new()
	local obj = setmetatable( {}, RespRandomQuestUpdateMsg.meta);
	return obj;
end

function RespRandomQuestUpdateMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);
	self.count, idx = readInt(pak, idx);

end



--[[
服务器返回:删除奇遇任务
]]

_G.RespRandomQuestRemoveMsg = {};

RespRandomQuestRemoveMsg.msgId = 8468;
RespRandomQuestRemoveMsg.id = 0; -- 奇遇任务id



RespRandomQuestRemoveMsg.meta = {__index = RespRandomQuestRemoveMsg};
function RespRandomQuestRemoveMsg:new()
	local obj = setmetatable( {}, RespRandomQuestRemoveMsg.meta);
	return obj;
end

function RespRandomQuestRemoveMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
服务器返回:进入奇遇副本
]]

_G.RespRandomDungeonEnterMsg = {};

RespRandomDungeonEnterMsg.msgId = 8469;
RespRandomDungeonEnterMsg.id = 0; -- 奇遇副本id



RespRandomDungeonEnterMsg.meta = {__index = RespRandomDungeonEnterMsg};
function RespRandomDungeonEnterMsg:new()
	local obj = setmetatable( {}, RespRandomDungeonEnterMsg.meta);
	return obj;
end

function RespRandomDungeonEnterMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
服务器返回:退出奇遇副本结果
]]

_G.RespRandomDungeonExitResultMsg = {};

RespRandomDungeonExitResultMsg.msgId = 8470;
RespRandomDungeonExitResultMsg.result = 0; -- 0:成功



RespRandomDungeonExitResultMsg.meta = {__index = RespRandomDungeonExitResultMsg};
function RespRandomDungeonExitResultMsg:new()
	local obj = setmetatable( {}, RespRandomDungeonExitResultMsg.meta);
	return obj;
end

function RespRandomDungeonExitResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回:奇遇副本步骤完成结果
]]

_G.RespRandomDungeonStepResultMsg = {};

RespRandomDungeonStepResultMsg.msgId = 8471;
RespRandomDungeonStepResultMsg.result = 0; -- 0:成功
RespRandomDungeonStepResultMsg.step = 0; -- 完成的步骤



RespRandomDungeonStepResultMsg.meta = {__index = RespRandomDungeonStepResultMsg};
function RespRandomDungeonStepResultMsg:new()
	local obj = setmetatable( {}, RespRandomDungeonStepResultMsg.meta);
	return obj;
end

function RespRandomDungeonStepResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.step, idx = readInt(pak, idx);

end



--[[
客户端请求:奇遇副本步骤内容发送(发题)
]]

_G.ReqRandomDungeonStepContentIssueMsg = {};

ReqRandomDungeonStepContentIssueMsg.msgId = 8472;
ReqRandomDungeonStepContentIssueMsg.id = 0; -- type=1时,题id



ReqRandomDungeonStepContentIssueMsg.meta = {__index = ReqRandomDungeonStepContentIssueMsg};
function ReqRandomDungeonStepContentIssueMsg:new()
	local obj = setmetatable( {}, ReqRandomDungeonStepContentIssueMsg.meta);
	return obj;
end

function ReqRandomDungeonStepContentIssueMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
服务器返回:奇遇副本步骤进度信息
]]

_G.ReqRandomDungeonStepProgressMsg = {};

ReqRandomDungeonStepProgressMsg.msgId = 8473;
ReqRandomDungeonStepProgressMsg.count = 0; -- 进度计数(杀怪数量or完成答题数量 bla bla)



ReqRandomDungeonStepProgressMsg.meta = {__index = ReqRandomDungeonStepProgressMsg};
function ReqRandomDungeonStepProgressMsg:new()
	local obj = setmetatable( {}, ReqRandomDungeonStepProgressMsg.meta);
	return obj;
end

function ReqRandomDungeonStepProgressMsg:ParseData(pak)
	local idx = 1;

	self.count, idx = readInt(pak, idx);

end



--[[
服务器返回:奇遇副本完成
]]

_G.RespRandomDungeonCompleteMsg = {};

RespRandomDungeonCompleteMsg.msgId = 8474;



RespRandomDungeonCompleteMsg.meta = {__index = RespRandomDungeonCompleteMsg};
function RespRandomDungeonCompleteMsg:new()
	local obj = setmetatable( {}, RespRandomDungeonCompleteMsg.meta);
	return obj;
end

function RespRandomDungeonCompleteMsg:ParseData(pak)
	local idx = 1;


end



--[[
寻宝信息
]]

_G.FindTreasureInfoMsg = {};

FindTreasureInfoMsg.msgId = 8475;
FindTreasureInfoMsg.mapid = 0; -- 地图点1
FindTreasureInfoMsg.mapid2 = 0; -- 地图点2
FindTreasureInfoMsg.wabaoId = 0; -- wabao表ID
FindTreasureInfoMsg.getlvl = 0; -- 接取时玩家等级
FindTreasureInfoMsg.lastNum = 0; -- 剩余次数
FindTreasureInfoMsg.lookPoint = 0; -- 看过的点。没有发0



FindTreasureInfoMsg.meta = {__index = FindTreasureInfoMsg};
function FindTreasureInfoMsg:new()
	local obj = setmetatable( {}, FindTreasureInfoMsg.meta);
	return obj;
end

function FindTreasureInfoMsg:ParseData(pak)
	local idx = 1;

	self.mapid, idx = readInt(pak, idx);
	self.mapid2, idx = readInt(pak, idx);
	self.wabaoId, idx = readInt(pak, idx);
	self.getlvl, idx = readInt(pak, idx);
	self.lastNum, idx = readInt(pak, idx);
	self.lookPoint, idx = readInt(pak, idx);

end



--[[
服务器返回:寻宝任务接取 结果
]]

_G.RespFindTreasureResultMsg = {};

RespFindTreasureResultMsg.msgId = 8476;
RespFindTreasureResultMsg.result = 0; -- 结果=0成功，1=失败
RespFindTreasureResultMsg.mapid = 0; -- 地图点1
RespFindTreasureResultMsg.mapid2 = 0; -- 地图点2
RespFindTreasureResultMsg.wabaoId = 0; -- wabao表ID
RespFindTreasureResultMsg.getlvl = 0; -- 接取时玩家等级
RespFindTreasureResultMsg.lastNum = 0; -- 剩余次数



RespFindTreasureResultMsg.meta = {__index = RespFindTreasureResultMsg};
function RespFindTreasureResultMsg:new()
	local obj = setmetatable( {}, RespFindTreasureResultMsg.meta);
	return obj;
end

function RespFindTreasureResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.mapid, idx = readInt(pak, idx);
	self.mapid2, idx = readInt(pak, idx);
	self.wabaoId, idx = readInt(pak, idx);
	self.getlvl, idx = readInt(pak, idx);
	self.lastNum, idx = readInt(pak, idx);

end



--[[
服务器返回:取消寻宝任务
]]

_G.RespFindTreasureCancelMsg = {};

RespFindTreasureCancelMsg.msgId = 8477;
RespFindTreasureCancelMsg.result = 0; -- 0=成功



RespFindTreasureCancelMsg.meta = {__index = RespFindTreasureCancelMsg};
function RespFindTreasureCancelMsg:new()
	local obj = setmetatable( {}, RespFindTreasureCancelMsg.meta);
	return obj;
end

function RespFindTreasureCancelMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回:接取结果
]]

_G.RespFindTreasureCollectMsg = {};

RespFindTreasureCollectMsg.msgId = 8478;
RespFindTreasureCollectMsg.result = 0; -- 0=真，1=假
RespFindTreasureCollectMsg.mapId = 0; -- 当前辨别的id
RespFindTreasureCollectMsg.resType = 0; -- 1=宝箱，2=妖怪
RespFindTreasureCollectMsg.resId = 0; -- 挖到的id



RespFindTreasureCollectMsg.meta = {__index = RespFindTreasureCollectMsg};
function RespFindTreasureCollectMsg:new()
	local obj = setmetatable( {}, RespFindTreasureCollectMsg.meta);
	return obj;
end

function RespFindTreasureCollectMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.mapId, idx = readInt(pak, idx);
	self.resType, idx = readInt(pak, idx);
	self.resId, idx = readInt(pak, idx);

end



--[[
服务器返回:刷新成就进度
]]

_G.RespAchievementUpDataMsg = {};

RespAchievementUpDataMsg.msgId = 8479;
RespAchievementUpDataMsg.id = 0; -- 成就ID
RespAchievementUpDataMsg.value = 0; -- 进度值
RespAchievementUpDataMsg.state = 0; -- 领奖状态



RespAchievementUpDataMsg.meta = {__index = RespAchievementUpDataMsg};
function RespAchievementUpDataMsg:new()
	local obj = setmetatable( {}, RespAchievementUpDataMsg.meta);
	return obj;
end

function RespAchievementUpDataMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.value, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
服务端通知: 返回武魂出战
]]

_G.RespWuHunBattleResultMsg = {};

RespWuHunBattleResultMsg.msgId = 8480;
RespWuHunBattleResultMsg.result = 0; -- 反馈结果,2卸下武魂,1成功,0失败
RespWuHunBattleResultMsg.wuhunId = 0; -- 武魂id



RespWuHunBattleResultMsg.meta = {__index = RespWuHunBattleResultMsg};
function RespWuHunBattleResultMsg:new()
	local obj = setmetatable( {}, RespWuHunBattleResultMsg.meta);
	return obj;
end

function RespWuHunBattleResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.wuhunId, idx = readInt(pak, idx);

end



--[[
服务器返回:卓越引导状态
]]

_G.RespZhuoyueGuideMsg = {};

RespZhuoyueGuideMsg.msgId = 8481;
RespZhuoyueGuideMsg.id = 0; -- 当前阶段
RespZhuoyueGuideMsg.state = 0; -- 0未达成,1已达成未领奖



RespZhuoyueGuideMsg.meta = {__index = RespZhuoyueGuideMsg};
function RespZhuoyueGuideMsg:new()
	local obj = setmetatable( {}, RespZhuoyueGuideMsg.meta);
	return obj;
end

function RespZhuoyueGuideMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
返回领取卓越引导奖励
]]

_G.RespZhuoyueGuideRewardMsg = {};

RespZhuoyueGuideRewardMsg.msgId = 8482;
RespZhuoyueGuideRewardMsg.rst = 0; -- 结果,0成功
RespZhuoyueGuideRewardMsg.nextId = 0; -- 下阶段id
RespZhuoyueGuideRewardMsg.nextState = 0; -- 下阶段状态



RespZhuoyueGuideRewardMsg.meta = {__index = RespZhuoyueGuideRewardMsg};
function RespZhuoyueGuideRewardMsg:new()
	local obj = setmetatable( {}, RespZhuoyueGuideRewardMsg.meta);
	return obj;
end

function RespZhuoyueGuideRewardMsg:ParseData(pak)
	local idx = 1;

	self.rst, idx = readInt(pak, idx);
	self.nextId, idx = readInt(pak, idx);
	self.nextState, idx = readInt(pak, idx);

end



--[[
服务端通知: 七日奖励信息
]]

_G.RespWeedSignDataMsg = {};

RespWeedSignDataMsg.msgId = 8483;
RespWeedSignDataMsg.signID = 0; -- 日期id
RespWeedSignDataMsg.result = 0; -- 领取结果 0:成功 -1:未到次数 -2:已领取
RespWeedSignDataMsg.login = 0; -- 登录天数
RespWeedSignDataMsg.reward = 0; -- 领取状态, 按位取



RespWeedSignDataMsg.meta = {__index = RespWeedSignDataMsg};
function RespWeedSignDataMsg:new()
	local obj = setmetatable( {}, RespWeedSignDataMsg.meta);
	return obj;
end

function RespWeedSignDataMsg:ParseData(pak)
	local idx = 1;

	self.signID, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);
	self.login, idx = readInt(pak, idx);
	self.reward, idx = readInt(pak, idx);

end



--[[
返回开启结果，上线推
]]

_G.RespUnionBossActivityInfoMsg = {};

RespUnionBossActivityInfoMsg.msgId = 8491;
RespUnionBossActivityInfoMsg.bossCurHp = 0; -- boss当前血量
RespUnionBossActivityInfoMsg.bossAllHp = 0; -- boss总血量
RespUnionBossActivityInfoMsg.damage = 0; -- 伤害
RespUnionBossActivityInfoMsg.curid = 0; -- 当前id
RespUnionBossActivityInfoMsg.allnum = 0; -- 参与总人数
RespUnionBossActivityInfoMsg.rolelist_size = 0; -- 伤害 size
RespUnionBossActivityInfoMsg.rolelist = {}; -- 伤害 list



--[[
listVO = {
	skillNum = 0; -- 伤害值
	roleName = ""; -- 角色名字
}
]]

RespUnionBossActivityInfoMsg.meta = {__index = RespUnionBossActivityInfoMsg};
function RespUnionBossActivityInfoMsg:new()
	local obj = setmetatable( {}, RespUnionBossActivityInfoMsg.meta);
	return obj;
end

function RespUnionBossActivityInfoMsg:ParseData(pak)
	local idx = 1;

	self.bossCurHp, idx = readDouble(pak, idx);
	self.bossAllHp, idx = readDouble(pak, idx);
	self.damage, idx = readDouble(pak, idx);
	self.curid, idx = readInt(pak, idx);
	self.allnum, idx = readInt(pak, idx);

	local list1 = {};
	self.rolelist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listVo = {};
		listVo.skillNum, idx = readDouble(pak, idx);
		listVo.roleName, idx = readString(pak, idx, 32);
		table.push(list1,listVo);
	end

end



--[[
退出结果
]]

_G.RespUnionBossActivityOutMsg = {};

RespUnionBossActivityOutMsg.msgId = 8492;
RespUnionBossActivityOutMsg.result = 0; -- 挑战结果：0=成功,1=失败



RespUnionBossActivityOutMsg.meta = {__index = RespUnionBossActivityOutMsg};
function RespUnionBossActivityOutMsg:new()
	local obj = setmetatable( {}, RespUnionBossActivityOutMsg.meta);
	return obj;
end

function RespUnionBossActivityOutMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
结束奖励面板
]]

_G.RespUnionBossActivityResultMsg = {};

RespUnionBossActivityResultMsg.msgId = 8493;
RespUnionBossActivityResultMsg.result = 0; -- 挑战结果：0=成功,1=失败



RespUnionBossActivityResultMsg.meta = {__index = RespUnionBossActivityResultMsg};
function RespUnionBossActivityResultMsg:new()
	local obj = setmetatable( {}, RespUnionBossActivityResultMsg.meta);
	return obj;
end

function RespUnionBossActivityResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
怪物攻城波数信息
]]

_G.RespMonsterSiegeWaveMsg = {};

RespMonsterSiegeWaveMsg.msgId = 8494;
RespMonsterSiegeWaveMsg.worldLevel = 0; -- 世界等级
RespMonsterSiegeWaveMsg.wave = 0; -- 第几波
RespMonsterSiegeWaveMsg.killMonster = 0; -- 个人击杀怪物
RespMonsterSiegeWaveMsg.killHuman = 0; -- 个人击杀玩家



RespMonsterSiegeWaveMsg.meta = {__index = RespMonsterSiegeWaveMsg};
function RespMonsterSiegeWaveMsg:new()
	local obj = setmetatable( {}, RespMonsterSiegeWaveMsg.meta);
	return obj;
end

function RespMonsterSiegeWaveMsg:ParseData(pak)
	local idx = 1;

	self.worldLevel, idx = readInt(pak, idx);
	self.wave, idx = readInt(pak, idx);
	self.killMonster, idx = readInt(pak, idx);
	self.killHuman, idx = readInt(pak, idx);

end



--[[
怪物攻城玩家击杀信息
]]

_G.RespMonsterSiegeKillDataMsg = {};

RespMonsterSiegeKillDataMsg.msgId = 8495;
RespMonsterSiegeKillDataMsg.state = 0; -- 0 怪物  1 玩家



RespMonsterSiegeKillDataMsg.meta = {__index = RespMonsterSiegeKillDataMsg};
function RespMonsterSiegeKillDataMsg:new()
	local obj = setmetatable( {}, RespMonsterSiegeKillDataMsg.meta);
	return obj;
end

function RespMonsterSiegeKillDataMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);

end



--[[
怪物攻城数量信息
]]

_G.RespMonsterSiegeDataMsg = {};

RespMonsterSiegeDataMsg.msgId = 8496;
RespMonsterSiegeDataMsg.boss = 0; -- boss数量
RespMonsterSiegeDataMsg.elite = 0; -- 精英数量
RespMonsterSiegeDataMsg.monster = 0; -- 怪物数量



RespMonsterSiegeDataMsg.meta = {__index = RespMonsterSiegeDataMsg};
function RespMonsterSiegeDataMsg:new()
	local obj = setmetatable( {}, RespMonsterSiegeDataMsg.meta);
	return obj;
end

function RespMonsterSiegeDataMsg:ParseData(pak)
	local idx = 1;

	self.boss, idx = readInt(pak, idx);
	self.elite, idx = readInt(pak, idx);
	self.monster, idx = readInt(pak, idx);

end



--[[
怪物攻城获得奖励
]]

_G.RespMonsterSiegeRewardMsg = {};

RespMonsterSiegeRewardMsg.msgId = 8497;
RespMonsterSiegeRewardMsg.rewardlist_size = 0; -- 奖励 size
RespMonsterSiegeRewardMsg.rewardlist = {}; -- 奖励 list



--[[
listVO = {
	id = 0; -- 奖励ID
	num = 0; -- 奖励个数
}
]]

RespMonsterSiegeRewardMsg.meta = {__index = RespMonsterSiegeRewardMsg};
function RespMonsterSiegeRewardMsg:new()
	local obj = setmetatable( {}, RespMonsterSiegeRewardMsg.meta);
	return obj;
end

function RespMonsterSiegeRewardMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.rewardlist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listVo = {};
		listVo.id, idx = readInt(pak, idx);
		listVo.num, idx = readInt(pak, idx);
		table.push(list1,listVo);
	end

end



--[[
怪物攻城结局面板
]]

_G.RespMonsterSiegeResultMsg = {};

RespMonsterSiegeResultMsg.msgId = 8498;
RespMonsterSiegeResultMsg.result = 0; -- 守卫结果 0 成功



RespMonsterSiegeResultMsg.meta = {__index = RespMonsterSiegeResultMsg};
function RespMonsterSiegeResultMsg:new()
	local obj = setmetatable( {}, RespMonsterSiegeResultMsg.meta);
	return obj;
end

function RespMonsterSiegeResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
怪物攻城BOSS击杀榜
]]

_G.RespMonsterSiegeKillRankMsg = {};

RespMonsterSiegeKillRankMsg.msgId = 8499;
RespMonsterSiegeKillRankMsg.killList_size = 0; -- 击杀榜 size
RespMonsterSiegeKillRankMsg.killList = {}; -- 击杀榜 list



--[[
listVO = {
	wave = 0; -- 波数
	roleName = ""; -- 角色名字
}
]]

RespMonsterSiegeKillRankMsg.meta = {__index = RespMonsterSiegeKillRankMsg};
function RespMonsterSiegeKillRankMsg:new()
	local obj = setmetatable( {}, RespMonsterSiegeKillRankMsg.meta);
	return obj;
end

function RespMonsterSiegeKillRankMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.killList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listVo = {};
		listVo.wave, idx = readInt(pak, idx);
		listVo.roleName, idx = readString(pak, idx, 32);
		table.push(list1,listVo);
	end

end



--[[
返回流水副本奖励
]]

_G.RespBackWaterDungeonRewardMsg = {};

RespBackWaterDungeonRewardMsg.msgId = 8500;
RespBackWaterDungeonRewardMsg.result = 0; -- 奖励领取结果 0 成功 1 银两不足 2 元宝不足 



RespBackWaterDungeonRewardMsg.meta = {__index = RespBackWaterDungeonRewardMsg};
function RespBackWaterDungeonRewardMsg:new()
	local obj = setmetatable( {}, RespBackWaterDungeonRewardMsg.meta);
	return obj;
end

function RespBackWaterDungeonRewardMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器通知:vip初始信息
]]

_G.RespVipInitStateMsg = {};

RespVipInitStateMsg.msgId = 8501;
RespVipInitStateMsg.weekReward = 0; -- 周奖励未领取0领取1
RespVipInitStateMsg.exp = 0; -- vip经验
RespVipInitStateMsg.period_size = 3; -- 不同类型vip到期时间列表 size
RespVipInitStateMsg.period = {}; -- 不同类型vip到期时间列表 list
RespVipInitStateMsg.levelRewardState_size = 0; -- vip等级奖励领取状态，未领取 size
RespVipInitStateMsg.levelRewardState = {}; -- vip等级奖励领取状态，未领取 list



--[[
periodVO = {
	vipType = 0; -- vip类型id(黄金1/钻石2/至尊3)
	time = 0; -- 到期时间(h), -1表示未激活, 0表示已到期
}
]]
--[[
levelRewardStateVO = {
	vipLevel = 0; -- 奖励对应的vip等级
}
]]

RespVipInitStateMsg.meta = {__index = RespVipInitStateMsg};
function RespVipInitStateMsg:new()
	local obj = setmetatable( {}, RespVipInitStateMsg.meta);
	return obj;
end

function RespVipInitStateMsg:ParseData(pak)
	local idx = 1;

	self.weekReward, idx = readInt(pak, idx);
	self.exp, idx = readInt64(pak, idx);

	local list1 = {};
	self.period = list1;
	local list1Size = 3;

	for i=1,list1Size do
		local periodVo = {};
		periodVo.vipType, idx = readInt(pak, idx);
		periodVo.time, idx = readInt64(pak, idx);
		table.push(list1,periodVo);
	end

	local list1 = {};
	self.levelRewardState = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local levelRewardStateVo = {};
		levelRewardStateVo.vipLevel, idx = readInt(pak, idx);
		table.push(list1,levelRewardStateVo);
	end

end



--[[
vip返还信息结果
]]

_G.RespVipBackInfoMsg = {};

RespVipBackInfoMsg.msgId = 8502;
RespVipBackInfoMsg.backType = 0; -- 返回类型
RespVipBackInfoMsg.itemId = 0; -- 道具id
RespVipBackInfoMsg.itemNum = 0; -- 累计可返还道具数量
RespVipBackInfoMsg.numCanBack = 0; -- 当前可领取道具数量



RespVipBackInfoMsg.meta = {__index = RespVipBackInfoMsg};
function RespVipBackInfoMsg:new()
	local obj = setmetatable( {}, RespVipBackInfoMsg.meta);
	return obj;
end

function RespVipBackInfoMsg:ParseData(pak)
	local idx = 1;

	self.backType, idx = readInt(pak, idx);
	self.itemId, idx = readInt(pak, idx);
	self.itemNum, idx = readInt64(pak, idx);
	self.numCanBack, idx = readInt64(pak, idx);

end



--[[
请求vip返还结果
]]

_G.RespGetVipBackMsg = {};

RespGetVipBackMsg.msgId = 8503;
RespGetVipBackMsg.result = 0; -- 结果：0=成功,1=失败
RespGetVipBackMsg.backType = 0; -- 返回类型



RespGetVipBackMsg.meta = {__index = RespGetVipBackMsg};
function RespGetVipBackMsg:new()
	local obj = setmetatable( {}, RespGetVipBackMsg.meta);
	return obj;
end

function RespGetVipBackMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.backType, idx = readInt(pak, idx);

end



--[[
进入跨服服务器结果
]]

_G.RespConCrossFightMsg = {};

RespConCrossFightMsg.msgId = 9001;
RespConCrossFightMsg.lineid = 0; -- 线ID
RespConCrossFightMsg.result = 0; -- 0 成功



RespConCrossFightMsg.meta = {__index = RespConCrossFightMsg};
function RespConCrossFightMsg:new()
	local obj = setmetatable( {}, RespConCrossFightMsg.meta);
	return obj;
end

function RespConCrossFightMsg:ParseData(pak)
	local idx = 1;

	self.lineid, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
进入跨服战斗结果
]]

_G.RespEnterCrossFightMsg = {};

RespEnterCrossFightMsg.msgId = 9002;
RespEnterCrossFightMsg.result = 0; -- 0 成功



RespEnterCrossFightMsg.meta = {__index = RespEnterCrossFightMsg};
function RespEnterCrossFightMsg:new()
	local obj = setmetatable( {}, RespEnterCrossFightMsg.meta);
	return obj;
end

function RespEnterCrossFightMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
结束跨服战斗
]]

_G.RespEndCrossFightMsg = {};

RespEndCrossFightMsg.msgId = 9003;
RespEndCrossFightMsg.sign = ""; -- MD5



RespEndCrossFightMsg.meta = {__index = RespEndCrossFightMsg};
function RespEndCrossFightMsg:new()
	local obj = setmetatable( {}, RespEndCrossFightMsg.meta);
	return obj;
end

function RespEndCrossFightMsg:ParseData(pak)
	local idx = 1;

	self.sign, idx = readString(pak, idx, 33);

end



--[[
服务器通知:他人神兵信息
]]

_G.RespOhterMagicWeaponInfoMsg = {};

RespOhterMagicWeaponInfoMsg.msgId = 8504;
RespOhterMagicWeaponInfoMsg.serverType = 0; -- 是否全服排行信息 1=是 其余都不是
RespOhterMagicWeaponInfoMsg.type = 0; -- 1== 详细信息，2 == 排行榜详细信息
RespOhterMagicWeaponInfoMsg.roleID = ""; -- 角色ID
RespOhterMagicWeaponInfoMsg.level = 0; -- 神兵等阶
RespOhterMagicWeaponInfoMsg.skills_size = 0; -- 技能列表 size
RespOhterMagicWeaponInfoMsg.skills = {}; -- 技能列表 list



--[[
SkillInfoVO = {
	skillId = 0; -- 技能id
}
]]

RespOhterMagicWeaponInfoMsg.meta = {__index = RespOhterMagicWeaponInfoMsg};
function RespOhterMagicWeaponInfoMsg:new()
	local obj = setmetatable( {}, RespOhterMagicWeaponInfoMsg.meta);
	return obj;
end

function RespOhterMagicWeaponInfoMsg:ParseData(pak)
	local idx = 1;

	self.serverType, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);
	self.roleID, idx = readGuid(pak, idx);
	self.level, idx = readInt(pak, idx);

	local list1 = {};
	self.skills = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local SkillInfoVo = {};
		SkillInfoVo.skillId, idx = readInt(pak, idx);
		table.push(list1,SkillInfoVo);
	end

end



--[[
请求在活动时长返还结果
]]

_G.RespActivityOnlineTimeMsg = {};

RespActivityOnlineTimeMsg.msgId = 8505;
RespActivityOnlineTimeMsg.id = 0; -- 活动id
RespActivityOnlineTimeMsg.time = 0; -- 返回在活动已使用时间(秒)
RespActivityOnlineTimeMsg.param1 = 0; -- 参数1



RespActivityOnlineTimeMsg.meta = {__index = RespActivityOnlineTimeMsg};
function RespActivityOnlineTimeMsg:new()
	local obj = setmetatable( {}, RespActivityOnlineTimeMsg.meta);
	return obj;
end

function RespActivityOnlineTimeMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.time, idx = readInt(pak, idx);
	self.param1, idx = readInt(pak, idx);

end



--[[
进入跨服PVP返回
]]

_G.RespEnterCrossFightPvpMsg = {};

RespEnterCrossFightPvpMsg.msgId = 8506;
RespEnterCrossFightPvpMsg.roleId = ""; -- 玩家id
RespEnterCrossFightPvpMsg.name = ""; -- 玩家名字
RespEnterCrossFightPvpMsg.prof = 0; -- 职业
RespEnterCrossFightPvpMsg.level = 0; -- 等级
RespEnterCrossFightPvpMsg.score = 0; -- 积分
RespEnterCrossFightPvpMsg.pvplv = 0; -- 段位
RespEnterCrossFightPvpMsg.groupid = 0; -- 服务器ID
RespEnterCrossFightPvpMsg.power = 0; -- 战斗力
RespEnterCrossFightPvpMsg.time = 0; -- 剩余时间S



RespEnterCrossFightPvpMsg.meta = {__index = RespEnterCrossFightPvpMsg};
function RespEnterCrossFightPvpMsg:new()
	local obj = setmetatable( {}, RespEnterCrossFightPvpMsg.meta);
	return obj;
end

function RespEnterCrossFightPvpMsg:ParseData(pak)
	local idx = 1;

	self.roleId, idx = readGuid(pak, idx);
	self.name, idx = readString(pak, idx, 32);
	self.prof, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);
	self.score, idx = readInt(pak, idx);
	self.pvplv, idx = readInt(pak, idx);
	self.groupid, idx = readInt(pak, idx);
	self.power, idx = readInt64(pak, idx);
	self.time, idx = readInt(pak, idx);

end



--[[
服务端通知:返回困难仙缘洞府BOSS状态
]]

_G.RespDIFXianYuanCaveBossStateMsg = {};

RespDIFXianYuanCaveBossStateMsg.msgId = 8507;
RespDIFXianYuanCaveBossStateMsg.id = 0; -- BOSSID
RespDIFXianYuanCaveBossStateMsg.num = 0; -- BOSS状态



RespDIFXianYuanCaveBossStateMsg.meta = {__index = RespDIFXianYuanCaveBossStateMsg};
function RespDIFXianYuanCaveBossStateMsg:new()
	local obj = setmetatable( {}, RespDIFXianYuanCaveBossStateMsg.meta);
	return obj;
end

function RespDIFXianYuanCaveBossStateMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
返回跨服PVP1结果
]]

_G.RespRewardCrossFightPvpMsg = {};

RespRewardCrossFightPvpMsg.msgId = 8508;
RespRewardCrossFightPvpMsg.result = 0; -- 结果



RespRewardCrossFightPvpMsg.meta = {__index = RespRewardCrossFightPvpMsg};
function RespRewardCrossFightPvpMsg:new()
	local obj = setmetatable( {}, RespRewardCrossFightPvpMsg.meta);
	return obj;
end

function RespRewardCrossFightPvpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回360加速球奖励是已否领取
]]

_G.RespQihooQuickStateMsg = {};

RespQihooQuickStateMsg.msgId = 8509;
RespQihooQuickStateMsg.state = 0; -- 结果 0领取  1未领取



RespQihooQuickStateMsg.meta = {__index = RespQihooQuickStateMsg};
function RespQihooQuickStateMsg:new()
	local obj = setmetatable( {}, RespQihooQuickStateMsg.meta);
	return obj;
end

function RespQihooQuickStateMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);

end



--[[
返回360加速球奖励领取结果
]]

_G.RespQihooQuickRewardMsg = {};

RespQihooQuickRewardMsg.msgId = 8510;
RespQihooQuickRewardMsg.result = 0; -- 结果 0成功  1失败



RespQihooQuickRewardMsg.meta = {__index = RespQihooQuickRewardMsg};
function RespQihooQuickRewardMsg:new()
	local obj = setmetatable( {}, RespQihooQuickRewardMsg.meta);
	return obj;
end

function RespQihooQuickRewardMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回角色状态
]]

_G.RespBitInfoMsg = {};

RespBitInfoMsg.msgId = 8511;
RespBitInfoMsg.buff = 0; -- 角色状态



RespBitInfoMsg.meta = {__index = RespBitInfoMsg};
function RespBitInfoMsg:new()
	local obj = setmetatable( {}, RespBitInfoMsg.meta);
	return obj;
end

function RespBitInfoMsg:ParseData(pak)
	local idx = 1;

	self.buff, idx = readInt(pak, idx);

end



--[[
返回特权奖励结果
]]

_G.RespPrerogativeRewardMsg = {};

RespPrerogativeRewardMsg.msgId = 8512;
RespPrerogativeRewardMsg.result = 0; -- 结果
RespPrerogativeRewardMsg.type = 0; -- 类型, 1:卫士特权 2:游戏大厅 3:特权加速礼包
RespPrerogativeRewardMsg.param = 0; -- 参数, 等级, 天数...



RespPrerogativeRewardMsg.meta = {__index = RespPrerogativeRewardMsg};
function RespPrerogativeRewardMsg:new()
	local obj = setmetatable( {}, RespPrerogativeRewardMsg.meta);
	return obj;
end

function RespPrerogativeRewardMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);
	self.param, idx = readInt(pak, idx);

end



--[[
返回特权奖励
]]

_G.RespPrerogativeInfoMsg = {};

RespPrerogativeInfoMsg.msgId = 8513;
RespPrerogativeInfoMsg.PrerogativeList_size = 0; -- 特权列表 size
RespPrerogativeInfoMsg.PrerogativeList = {}; -- 特权列表 list



--[[
PrerogativeInfoVO = {
	type = 0; -- 类型, 1:卫士特权 2:游戏大厅 3:特权加速礼包
	flags = 0; -- 领奖标识 0 没有领取
}
]]

RespPrerogativeInfoMsg.meta = {__index = RespPrerogativeInfoMsg};
function RespPrerogativeInfoMsg:new()
	local obj = setmetatable( {}, RespPrerogativeInfoMsg.meta);
	return obj;
end

function RespPrerogativeInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.PrerogativeList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local PrerogativeInfoVo = {};
		PrerogativeInfoVo.type, idx = readInt(pak, idx);
		PrerogativeInfoVo.flags, idx = readInt(pak, idx);
		table.push(list1,PrerogativeInfoVo);
	end

end



--[[
返回熔炼结果
]]

_G.RespEquipSmeltMsg = {};

RespEquipSmeltMsg.msgId = 8514;
RespEquipSmeltMsg.id = 0; -- 熔炼id
RespEquipSmeltMsg.exp = 0; -- 熔炼经验
RespEquipSmeltMsg.flags = 0; -- 熔炼品质



RespEquipSmeltMsg.meta = {__index = RespEquipSmeltMsg};
function RespEquipSmeltMsg:new()
	local obj = setmetatable( {}, RespEquipSmeltMsg.meta);
	return obj;
end

function RespEquipSmeltMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.exp, idx = readInt(pak, idx);
	self.flags, idx = readInt(pak, idx);

end



--[[
返回冰魂信息
]]

_G.RespBingHunInfoMsg = {};

RespBingHunInfoMsg.msgId = 8519;
RespBingHunInfoMsg.selectid = 0; -- 当前使用的冰魂id
RespBingHunInfoMsg.BingHunList_size = 0; -- 激活的冰魂列表 size
RespBingHunInfoMsg.BingHunList = {}; -- 激活的冰魂列表 list



--[[
BingHunVOVO = {
	id = 0; -- 冰魂id
	time = 0; -- 剩余时间
}
]]

RespBingHunInfoMsg.meta = {__index = RespBingHunInfoMsg};
function RespBingHunInfoMsg:new()
	local obj = setmetatable( {}, RespBingHunInfoMsg.meta);
	return obj;
end

function RespBingHunInfoMsg:ParseData(pak)
	local idx = 1;

	self.selectid, idx = readInt(pak, idx);

	local list1 = {};
	self.BingHunList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local BingHunVOVo = {};
		BingHunVOVo.id, idx = readInt(pak, idx);
		BingHunVOVo.time, idx = readInt(pak, idx);
		table.push(list1,BingHunVOVo);
	end

end



--[[
服务端通知:冰魂到期或者有新的冰魂激活
]]

_G.RespBingHunVOUpdateMsg = {};

RespBingHunVOUpdateMsg.msgId = 8520;
RespBingHunVOUpdateMsg.id = 0; -- 冰魂id
RespBingHunVOUpdateMsg.time = 0; -- 剩余时间



RespBingHunVOUpdateMsg.meta = {__index = RespBingHunVOUpdateMsg};
function RespBingHunVOUpdateMsg:new()
	local obj = setmetatable( {}, RespBingHunVOUpdateMsg.meta);
	return obj;
end

function RespBingHunVOUpdateMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.time, idx = readInt(pak, idx);

end



--[[
服务器通知:冰魂换模型结果
]]

_G.RespBingHunChangeModelMsg = {};

RespBingHunChangeModelMsg.msgId = 8521;
RespBingHunChangeModelMsg.id = 0; -- 成功时：更换后的模型id；-1：未激活;-2：过期; -3：其他



RespBingHunChangeModelMsg.meta = {__index = RespBingHunChangeModelMsg};
function RespBingHunChangeModelMsg:new()
	local obj = setmetatable( {}, RespBingHunChangeModelMsg.meta);
	return obj;
end

function RespBingHunChangeModelMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
服务器通知:刷新悬赏状态结果
]]

_G.RespFengYaoRefreshStateMsg = {};

RespFengYaoRefreshStateMsg.msgId = 8522;
RespFengYaoRefreshStateMsg.result = 0; -- 0成功, 1:玩家等级/vip等级不够 2:封妖任务状态错误 3：元宝不够



RespFengYaoRefreshStateMsg.meta = {__index = RespFengYaoRefreshStateMsg};
function RespFengYaoRefreshStateMsg:new()
	local obj = setmetatable( {}, RespFengYaoRefreshStateMsg.meta);
	return obj;
end

function RespFengYaoRefreshStateMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回额外领取流水副本多倍奖励
]]

_G.RespBackWaterDungeonLossRewardMsg = {};

RespBackWaterDungeonLossRewardMsg.msgId = 8523;
RespBackWaterDungeonLossRewardMsg.result = 0; -- 奖励领取结果 0 成功 1 银两不足 2 元宝不足 



RespBackWaterDungeonLossRewardMsg.meta = {__index = RespBackWaterDungeonLossRewardMsg};
function RespBackWaterDungeonLossRewardMsg:new()
	local obj = setmetatable( {}, RespBackWaterDungeonLossRewardMsg.meta);
	return obj;
end

function RespBackWaterDungeonLossRewardMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
消耗经验提示
]]

_G.RespExpTipsMsg = {};

RespExpTipsMsg.msgId = 8524;
RespExpTipsMsg.exp = 0; -- 消耗的经验



RespExpTipsMsg.meta = {__index = RespExpTipsMsg};
function RespExpTipsMsg:new()
	local obj = setmetatable( {}, RespExpTipsMsg.meta);
	return obj;
end

function RespExpTipsMsg:ParseData(pak)
	local idx = 1;

	self.exp, idx = readDouble(pak, idx);

end



--[[
转生步骤更新
]]

_G.RespTurnlifeStepMsg = {};

RespTurnlifeStepMsg.msgId = 8525;
RespTurnlifeStepMsg.copyId = 0; -- 副本id
RespTurnlifeStepMsg.monsterList_size = 0; -- 怪物 size
RespTurnlifeStepMsg.monsterList = {}; -- 怪物 list



--[[
monsterVoVO = {
	id = 0; -- 怪物id
	num = 0; -- 击杀数量
}
]]

RespTurnlifeStepMsg.meta = {__index = RespTurnlifeStepMsg};
function RespTurnlifeStepMsg:new()
	local obj = setmetatable( {}, RespTurnlifeStepMsg.meta);
	return obj;
end

function RespTurnlifeStepMsg:ParseData(pak)
	local idx = 1;

	self.copyId, idx = readInt(pak, idx);

	local list1 = {};
	self.monsterList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local monsterVoVo = {};
		monsterVoVo.id, idx = readInt(pak, idx);
		monsterVoVo.num, idx = readInt(pak, idx);
		table.push(list1,monsterVoVo);
	end

end



--[[
转生完成
]]

_G.RespTurnlifefinishMsg = {};

RespTurnlifefinishMsg.msgId = 8526;
RespTurnlifefinishMsg.stype = 0; -- 转生类型，1转2转3转



RespTurnlifefinishMsg.meta = {__index = RespTurnlifefinishMsg};
function RespTurnlifefinishMsg:new()
	local obj = setmetatable( {}, RespTurnlifefinishMsg.meta);
	return obj;
end

function RespTurnlifefinishMsg:ParseData(pak)
	local idx = 1;

	self.stype, idx = readInt(pak, idx);

end



--[[
返回翅膀信息
]]

_G.RespWingInfoMsg = {};

RespWingInfoMsg.msgId = 8527;
RespWingInfoMsg.list_size = 0; -- 翅膀list size
RespWingInfoMsg.list = {}; -- 翅膀list list



--[[
WingInfoVOVO = {
	itemId = ""; -- 道具cid
	time = 0; -- 到期时间,-1无限
	attrFlag = 0; -- 是否有特殊属性,1有
}
]]

RespWingInfoMsg.meta = {__index = RespWingInfoMsg};
function RespWingInfoMsg:new()
	local obj = setmetatable( {}, RespWingInfoMsg.meta);
	return obj;
end

function RespWingInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local WingInfoVOVo = {};
		WingInfoVOVo.itemId, idx = readGuid(pak, idx);
		WingInfoVOVo.time, idx = readInt64(pak, idx);
		WingInfoVOVo.attrFlag, idx = readByte(pak, idx);
		table.push(list1,WingInfoVOVo);
	end

end



--[[
我的v计划信息
]]

_G.RespVplanMyInfoMsg = {};

RespVplanMyInfoMsg.msgId = 8529;
RespVplanMyInfoMsg.exp = 0; -- 当前经验
RespVplanMyInfoMsg.Allexp = 0; -- 总经验
RespVplanMyInfoMsg.speed = 0; -- 成长速度，/天
RespVplanMyInfoMsg.expiretime = 0; -- 到期时间



RespVplanMyInfoMsg.meta = {__index = RespVplanMyInfoMsg};
function RespVplanMyInfoMsg:new()
	local obj = setmetatable( {}, RespVplanMyInfoMsg.meta);
	return obj;
end

function RespVplanMyInfoMsg:ParseData(pak)
	local idx = 1;

	self.exp, idx = readInt(pak, idx);
	self.Allexp, idx = readInt(pak, idx);
	self.speed, idx = readInt(pak, idx);
	self.expiretime, idx = readInt64(pak, idx);

end



--[[
消费礼包--登录推
]]

_G.RespVPlanBuyGiftDateMsg = {};

RespVPlanBuyGiftDateMsg.msgId = 8530;
RespVPlanBuyGiftDateMsg.restTime = 0; -- 剩余重置时间
RespVPlanBuyGiftDateMsg.xnum = 0; -- 本期累计消费
RespVPlanBuyGiftDateMsg.BuyGift_size = 5; -- 领取过的消费礼包 size
RespVPlanBuyGiftDateMsg.BuyGift = {}; -- 领取过的消费礼包 list



--[[
BuyGiftVOVO = {
	id = 0; -- 消费礼包id
	state = 0; -- 领取状态，0=未领取，1=已领取
}
]]

RespVPlanBuyGiftDateMsg.meta = {__index = RespVPlanBuyGiftDateMsg};
function RespVPlanBuyGiftDateMsg:new()
	local obj = setmetatable( {}, RespVPlanBuyGiftDateMsg.meta);
	return obj;
end

function RespVPlanBuyGiftDateMsg:ParseData(pak)
	local idx = 1;

	self.restTime, idx = readInt(pak, idx);
	self.xnum, idx = readInt(pak, idx);

	local list = {};
	self.BuyGift = list;
	local listSize = 5;

	for i=1,listSize do
		local BuyGiftVOVo = {};
		BuyGiftVOVo.id, idx = readInt(pak, idx);
		BuyGiftVOVo.state, idx = readInt(pak, idx);
		table.push(list,BuyGiftVOVo);
	end

end



--[[
返回发红包结果
]]

_G.RespSendRedPacketMsg = {};

RespSendRedPacketMsg.msgId = 8531;
RespSendRedPacketMsg.result = 0; -- 发红包结果成功 0成功，-6不是您的婚礼不可操作
RespSendRedPacketMsg.num = 0; -- 发红包剩余次数：0=



RespSendRedPacketMsg.meta = {__index = RespSendRedPacketMsg};
function RespSendRedPacketMsg:new()
	local obj = setmetatable( {}, RespSendRedPacketMsg.meta);
	return obj;
end

function RespSendRedPacketMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
退出跨服PVP1返回
]]

_G.ResqQuitCrossFightPvpMsg = {};

ResqQuitCrossFightPvpMsg.msgId = 8532;



ResqQuitCrossFightPvpMsg.meta = {__index = ResqQuitCrossFightPvpMsg};
function ResqQuitCrossFightPvpMsg:new()
	local obj = setmetatable( {}, ResqQuitCrossFightPvpMsg.meta);
	return obj;
end

function ResqQuitCrossFightPvpMsg:ParseData(pak)
	local idx = 1;


end



--[[
升阶石抽奖返回
]]

_G.ResqUpgradeStoneMsg = {};

ResqUpgradeStoneMsg.msgId = 8533;
ResqUpgradeStoneMsg.id = 0; -- 抽中的ID



ResqUpgradeStoneMsg.meta = {__index = ResqUpgradeStoneMsg};
function ResqUpgradeStoneMsg:new()
	local obj = setmetatable( {}, ResqUpgradeStoneMsg.meta);
	return obj;
end

function ResqUpgradeStoneMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
运营活动返回
]]

_G.RespPartyListMsg = {};

RespPartyListMsg.msgId = 8534;
RespPartyListMsg.list_size = 0; -- 活动list size
RespPartyListMsg.list = {}; -- 活动list list



--[[
PartyListVOVO = {
	id = 0; -- ID
	open = 0; -- 活动开启
	btn = 0; -- 活动按钮图标
	group = 0; -- 组id
	priority = 0; -- 优先级ID
	needActivity = 0; -- 前置活动
	sort = 0; -- UI内排序
	absolutePriority = 0; -- 绝对优先
	groupName = ""; -- 活动名称
	openTimeAb = ""; -- 绝对开启时间
	openTimeStart = 0; -- 相对开启时间
	mergeTimeStart = 0; -- 相对合服开启时间
	lastTime = 0; -- 持续时间
	rewardTime = 0; -- 结算时间
	mainType = 0; -- 活动类型
	subType = 0; -- 活动子类型
}
]]

RespPartyListMsg.meta = {__index = RespPartyListMsg};
function RespPartyListMsg:new()
	local obj = setmetatable( {}, RespPartyListMsg.meta);
	return obj;
end

function RespPartyListMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local PartyListVOVo = {};
		PartyListVOVo.id, idx = readInt(pak, idx);
		PartyListVOVo.open, idx = readByte(pak, idx);
		PartyListVOVo.btn, idx = readByte(pak, idx);
		PartyListVOVo.group, idx = readInt(pak, idx);
		PartyListVOVo.priority, idx = readInt(pak, idx);
		PartyListVOVo.needActivity, idx = readInt(pak, idx);
		PartyListVOVo.sort, idx = readInt(pak, idx);
		PartyListVOVo.absolutePriority, idx = readByte(pak, idx);
		PartyListVOVo.groupName, idx = readString(pak, idx, 20);
		PartyListVOVo.openTimeAb, idx = readString(pak, idx, 20);
		PartyListVOVo.openTimeStart, idx = readInt(pak, idx);
		PartyListVOVo.mergeTimeStart, idx = readInt(pak, idx);
		PartyListVOVo.lastTime, idx = readInt(pak, idx);
		PartyListVOVo.rewardTime, idx = readInt(pak, idx);
		PartyListVOVo.mainType, idx = readInt(pak, idx);
		PartyListVOVo.subType, idx = readInt(pak, idx);
		table.push(list1,PartyListVOVo);
	end

end



--[[
运营活动状态返回
]]

_G.RespPartyStatListMsg = {};

RespPartyStatListMsg.msgId = 8535;
RespPartyStatListMsg.list_size = 0; -- 活动状态list size
RespPartyStatListMsg.list = {}; -- 活动状态list list



--[[
PartyStatListVOVO = {
	id = 0; -- ID
	isAward = 0; -- 是否已领取，(0 - 没有， 1 - 可领， 2 - 已领)团购（1,首冲，2，一次购买， 4， 二次购买 8，三次购买）
	progress = 0; -- 当前进度，总进度在param里
	count = 0; -- 已领次数，总次数在receiveTime(团购的是否达成首冲1达成0未达成)
}
]]

RespPartyStatListMsg.meta = {__index = RespPartyStatListMsg};
function RespPartyStatListMsg:new()
	local obj = setmetatable( {}, RespPartyStatListMsg.meta);
	return obj;
end

function RespPartyStatListMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local PartyStatListVOVo = {};
		PartyStatListVOVo.id, idx = readInt(pak, idx);
		PartyStatListVOVo.isAward, idx = readByte(pak, idx);
		PartyStatListVOVo.progress, idx = readInt(pak, idx);
		PartyStatListVOVo.count, idx = readInt(pak, idx);
		table.push(list1,PartyStatListVOVo);
	end

end



--[[
获得运营活动奖励返回
]]

_G.RespGetPartyAwardMsg = {};

RespGetPartyAwardMsg.msgId = 8536;
RespGetPartyAwardMsg.id = 0; -- 活动id
RespGetPartyAwardMsg.ret = 0; -- 结果(0 - 没有， 1 - 可领， 2 - 已领)团购（1,首冲，2，一次购买， 4， 二次购买 8，三次购买）
RespGetPartyAwardMsg.count = 0; -- 已领次数，总次数在receiveTime(团购的是否达成首冲1达成0未达成)



RespGetPartyAwardMsg.meta = {__index = RespGetPartyAwardMsg};
function RespGetPartyAwardMsg:new()
	local obj = setmetatable( {}, RespGetPartyAwardMsg.meta);
	return obj;
end

function RespGetPartyAwardMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.ret, idx = readInt(pak, idx);
	self.count, idx = readInt(pak, idx);

end



--[[
服务端通知:神兽获得或者失去通知
]]

_G.RespShenShouTimeNotifyMsg = {};

RespShenShouTimeNotifyMsg.msgId = 8537;
RespShenShouTimeNotifyMsg.wuhunId = 0; -- 武魂神兽id
RespShenShouTimeNotifyMsg.time = 0; -- 剩余时间



RespShenShouTimeNotifyMsg.meta = {__index = RespShenShouTimeNotifyMsg};
function RespShenShouTimeNotifyMsg:new()
	local obj = setmetatable( {}, RespShenShouTimeNotifyMsg.meta);
	return obj;
end

function RespShenShouTimeNotifyMsg:ParseData(pak)
	local idx = 1;

	self.wuhunId, idx = readInt(pak, idx);
	self.time, idx = readInt64(pak, idx);

end



--[[
翅膀过期通知
]]

_G.RespWingTimePassMsg = {};

RespWingTimePassMsg.msgId = 8538;
RespWingTimePassMsg.id = 0; -- 翅膀id



RespWingTimePassMsg.meta = {__index = RespWingTimePassMsg};
function RespWingTimePassMsg:new()
	local obj = setmetatable( {}, RespWingTimePassMsg.meta);
	return obj;
end

function RespWingTimePassMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);

end



--[[
返回战力运营排行
]]

_G.RespPartyPowerRankMsg = {};

RespPartyPowerRankMsg.msgId = 8540;
RespPartyPowerRankMsg.roleName = ""; -- 人物名称
RespPartyPowerRankMsg.prof = 0; -- 职业
RespPartyPowerRankMsg.arms = 0; -- 武器
RespPartyPowerRankMsg.dress = 0; -- 衣服
RespPartyPowerRankMsg.fashionshead = 0; -- 时装头
RespPartyPowerRankMsg.fashionsarms = 0; -- 时装武器
RespPartyPowerRankMsg.fashionsdress = 0; -- 时装衣服
RespPartyPowerRankMsg.wuhunId = 0; -- 武魂id
RespPartyPowerRankMsg.wing = 0; -- 翅膀
RespPartyPowerRankMsg.suitflag = 0; -- 套装标识
RespPartyPowerRankMsg.list_size = 0; -- 排行list size
RespPartyPowerRankMsg.list = {}; -- 排行list list



--[[
PartyRankListVOVO = {
	name = ""; -- 名称
	val = 0; -- 排行值
	rank = 0; -- 排名
}
]]

RespPartyPowerRankMsg.meta = {__index = RespPartyPowerRankMsg};
function RespPartyPowerRankMsg:new()
	local obj = setmetatable( {}, RespPartyPowerRankMsg.meta);
	return obj;
end

function RespPartyPowerRankMsg:ParseData(pak)
	local idx = 1;

	self.roleName, idx = readString(pak, idx, 32);
	self.prof, idx = readInt(pak, idx);
	self.arms, idx = readInt(pak, idx);
	self.dress, idx = readInt(pak, idx);
	self.fashionshead, idx = readInt(pak, idx);
	self.fashionsarms, idx = readInt(pak, idx);
	self.fashionsdress, idx = readInt(pak, idx);
	self.wuhunId, idx = readInt(pak, idx);
	self.wing, idx = readInt(pak, idx);
	self.suitflag, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local PartyRankListVOVo = {};
		PartyRankListVOVo.name, idx = readString(pak, idx, 32);
		PartyRankListVOVo.val, idx = readInt64(pak, idx);
		PartyRankListVOVo.rank, idx = readByte(pak, idx);
		table.push(list1,PartyRankListVOVo);
	end

end



--[[
返回团购信息
]]

_G.RespPartyGroupPurchaseMsg = {};

RespPartyGroupPurchaseMsg.msgId = 8541;
RespPartyGroupPurchaseMsg.list_size = 0; -- 排行list size
RespPartyGroupPurchaseMsg.list = {}; -- 排行list list



--[[
PartyRankListVOVO = {
	id = 0; -- 活动id
	mypurchase = 0; -- 我的购买次数
	totalpurchase = 0; -- 总的购买
}
]]

RespPartyGroupPurchaseMsg.meta = {__index = RespPartyGroupPurchaseMsg};
function RespPartyGroupPurchaseMsg:new()
	local obj = setmetatable( {}, RespPartyGroupPurchaseMsg.meta);
	return obj;
end

function RespPartyGroupPurchaseMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local PartyRankListVOVo = {};
		PartyRankListVOVo.id, idx = readInt(pak, idx);
		PartyRankListVOVo.mypurchase, idx = readInt(pak, idx);
		PartyRankListVOVo.totalpurchase, idx = readInt(pak, idx);
		table.push(list1,PartyRankListVOVo);
	end

end



--[[
返回运营活动基本信息
]]

_G.RespPartySimpleInfoMsg = {};

RespPartySimpleInfoMsg.msgId = 8542;
RespPartySimpleInfoMsg.list_size = 0; -- 活动基本list size
RespPartySimpleInfoMsg.list = {}; -- 活动基本list list



--[[
PartyListVOVO = {
	btnid = 0; -- 按钮id
	cnt = 0; -- 可领奖的数量
	reward = 0; -- 是否有奖励(1-有，0-没有)
	new = 0; -- 是否是新活动(1-新，0-旧)
	imageTxt = ""; -- 按钮标题
}
]]

RespPartySimpleInfoMsg.meta = {__index = RespPartySimpleInfoMsg};
function RespPartySimpleInfoMsg:new()
	local obj = setmetatable( {}, RespPartySimpleInfoMsg.meta);
	return obj;
end

function RespPartySimpleInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local PartyListVOVo = {};
		PartyListVOVo.btnid, idx = readInt(pak, idx);
		PartyListVOVo.cnt, idx = readInt(pak, idx);
		PartyListVOVo.reward, idx = readByte(pak, idx);
		PartyListVOVo.new, idx = readByte(pak, idx);
		PartyListVOVo.imageTxt, idx = readString(pak, idx, 32);
		table.push(list1,PartyListVOVo);
	end

end



--[[
服务端通知:返回灵兽坐骑信息
]]

_G.RespLingShouHorseInfoMsg = {};

RespLingShouHorseInfoMsg.msgId = 8543;
RespLingShouHorseInfoMsg.lshorseStep = 0; -- 灵兽坐骑阶位
RespLingShouHorseInfoMsg.starProgress = 0; -- 星级进度
RespLingShouHorseInfoMsg.zzpillNum = 0; -- 资质属性丹数量



RespLingShouHorseInfoMsg.meta = {__index = RespLingShouHorseInfoMsg};
function RespLingShouHorseInfoMsg:new()
	local obj = setmetatable( {}, RespLingShouHorseInfoMsg.meta);
	return obj;
end

function RespLingShouHorseInfoMsg:ParseData(pak)
	local idx = 1;

	self.lshorseStep, idx = readInt(pak, idx);
	self.starProgress, idx = readInt(pak, idx);
	self.zzpillNum, idx = readInt(pak, idx);

end



--[[
服务器通知：返回灵兽坐骑进阶进度
]]

_G.RespLSHorseLvlUpInfoMsg = {};

RespLSHorseLvlUpInfoMsg.msgId = 8544;
RespLSHorseLvlUpInfoMsg.result = 0; -- 0=成功 -1=未开启 -2最大等级 -3金币不足 -4进阶石不足 -5元宝不足 -6材料不足 -7最高等阶
RespLSHorseLvlUpInfoMsg.lshorseLevel = 0; -- 坐骑阶位
RespLSHorseLvlUpInfoMsg.starProgress = 0; -- 星级进度
RespLSHorseLvlUpInfoMsg.uptype = 0; -- 1 普通成长,2 双倍成长



RespLSHorseLvlUpInfoMsg.meta = {__index = RespLSHorseLvlUpInfoMsg};
function RespLSHorseLvlUpInfoMsg:new()
	local obj = setmetatable( {}, RespLSHorseLvlUpInfoMsg.meta);
	return obj;
end

function RespLSHorseLvlUpInfoMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.lshorseLevel, idx = readInt(pak, idx);
	self.starProgress, idx = readInt(pak, idx);
	self.uptype, idx = readInt(pak, idx);

end



--[[
服务器通知：返回灵兽坐骑进阶成功
]]

_G.RespLSHorseLvlUpSucessMsg = {};

RespLSHorseLvlUpSucessMsg.msgId = 8545;
RespLSHorseLvlUpSucessMsg.lshorseLevel = 0; -- 灵兽坐骑阶位



RespLSHorseLvlUpSucessMsg.meta = {__index = RespLSHorseLvlUpSucessMsg};
function RespLSHorseLvlUpSucessMsg:new()
	local obj = setmetatable( {}, RespLSHorseLvlUpSucessMsg.meta);
	return obj;
end

function RespLSHorseLvlUpSucessMsg:ParseData(pak)
	local idx = 1;

	self.lshorseLevel, idx = readInt(pak, idx);

end



--[[
服务器通知：灵兽坐骑功能开启通知id
]]

_G.RespLSHorseLvlUpSucessMsg = {};

RespLSHorseLvlUpSucessMsg.msgId = 8546;
RespLSHorseLvlUpSucessMsg.lshorseLevel = 0; -- 灵兽坐骑阶位



RespLSHorseLvlUpSucessMsg.meta = {__index = RespLSHorseLvlUpSucessMsg};
function RespLSHorseLvlUpSucessMsg:new()
	local obj = setmetatable( {}, RespLSHorseLvlUpSucessMsg.meta);
	return obj;
end

function RespLSHorseLvlUpSucessMsg:ParseData(pak)
	local idx = 1;

	self.lshorseLevel, idx = readInt(pak, idx);

end



--[[
返回发红包剩余次数
]]

_G.RespRedPacketHaveInfoMsg = {};

RespRedPacketHaveInfoMsg.msgId = 8547;
RespRedPacketHaveInfoMsg.num = 0; -- 发红包剩余次数



RespRedPacketHaveInfoMsg.meta = {__index = RespRedPacketHaveInfoMsg};
function RespRedPacketHaveInfoMsg:new()
	local obj = setmetatable( {}, RespRedPacketHaveInfoMsg.meta);
	return obj;
end

function RespRedPacketHaveInfoMsg:ParseData(pak)
	local idx = 1;

	self.num, idx = readInt(pak, idx);

end



--[[
返回单个活动信息
]]

_G.RespPartyInfoMsg = {};

RespPartyInfoMsg.msgId = 8548;
RespPartyInfoMsg.groupid = 0; -- 组ID
RespPartyInfoMsg.ret = 0; -- 0已经最新无需更新 1有数据更新
RespPartyInfoMsg.version = 0; -- 最新版本号
RespPartyInfoMsg.list_size = 0; -- 活动list size
RespPartyInfoMsg.list = {}; -- 活动list list



--[[
PartyListVOVO = {
	id = 0; -- ID
	param = ""; -- 参数
	reward = ""; -- 奖励内容
	receiveTime = 0; -- 领取次数
	groupbuyPrice = 0; -- 团购售价
	groupTxt = ""; -- 活动描述
	eachTxt = ""; -- 奖励描述
	imageTxt = ""; -- 美术字标题
	imagePic = ""; -- 美术图片
	consume = ""; -- 兑换消耗
	groupbuyRequire = ""; -- 团购额外需求
	showModel = ""; -- 3D模型展示
	groupbuyItem_size = 2; -- 团购物品及数量 size
	groupbuyItem = {}; -- 团购物品及数量 list
}
GroupBuyItemListVOVO = {
	ID = 0; -- ID
}
]]

RespPartyInfoMsg.meta = {__index = RespPartyInfoMsg};
function RespPartyInfoMsg:new()
	local obj = setmetatable( {}, RespPartyInfoMsg.meta);
	return obj;
end

function RespPartyInfoMsg:ParseData(pak)
	local idx = 1;

	self.groupid, idx = readInt(pak, idx);
	self.ret, idx = readByte(pak, idx);
	self.version, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local PartyListVOVo = {};
		PartyListVOVo.id, idx = readInt(pak, idx);
		PartyListVOVo.param, idx = readString(pak, idx, 64);
		PartyListVOVo.reward, idx = readString(pak, idx, 200);
		PartyListVOVo.receiveTime, idx = readInt(pak, idx);
		PartyListVOVo.groupbuyPrice, idx = readInt(pak, idx);
		PartyListVOVo.groupTxt, idx = readString(pak, idx, 128);
		PartyListVOVo.eachTxt, idx = readString(pak, idx, 128);
		PartyListVOVo.imageTxt, idx = readString(pak, idx, 32);
		PartyListVOVo.imagePic, idx = readString(pak, idx, 10);
		PartyListVOVo.consume, idx = readString(pak, idx, 128);
		PartyListVOVo.groupbuyRequire, idx = readString(pak, idx, 20);
		PartyListVOVo.showModel, idx = readString(pak, idx, 64);
		table.push(list1,PartyListVOVo);

		local list = {};
		PartyListVOVo.groupbuyItem = list;
		local listSize = 2;

		for i=1,listSize do
			local GroupBuyItemListVOVo = {};
			GroupBuyItemListVOVo.ID, idx = readInt(pak, idx);
			table.push(list,GroupBuyItemListVOVo);
		end
	end

end



--[[
道具卡片打开结果
]]

_G.RespItemCardResultMsg = {};

RespItemCardResultMsg.msgId = 8549;
RespItemCardResultMsg.result = 0; -- 打开卡片返回结果 0 成功 -1 道具不足 -2 次数不足 -3 等级不足 -4 元宝不足 -5背包满 -7 异常



RespItemCardResultMsg.meta = {__index = RespItemCardResultMsg};
function RespItemCardResultMsg:new()
	local obj = setmetatable( {}, RespItemCardResultMsg.meta);
	return obj;
end

function RespItemCardResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回开装备卓越孔
]]

_G.RespOpenSuperHoleMsg = {};

RespOpenSuperHoleMsg.msgId = 8550;
RespOpenSuperHoleMsg.result = 0; -- 结果
RespOpenSuperHoleMsg.eId = ""; -- 装备cid
RespOpenSuperHoleMsg.superNum = 0; -- 卓越数量



RespOpenSuperHoleMsg.meta = {__index = RespOpenSuperHoleMsg};
function RespOpenSuperHoleMsg:new()
	local obj = setmetatable( {}, RespOpenSuperHoleMsg.meta);
	return obj;
end

function RespOpenSuperHoleMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.eId, idx = readGuid(pak, idx);
	self.superNum, idx = readInt(pak, idx);

end



--[[
收到其他怪物移动通知
]]

_G.RespSceneMonsterMoveToNotifyMsg = {};

RespSceneMonsterMoveToNotifyMsg.msgId = 8551;
RespSceneMonsterMoveToNotifyMsg.roleId = ""; -- 角色ID
RespSceneMonsterMoveToNotifyMsg.disX = 0; -- 
RespSceneMonsterMoveToNotifyMsg.disY = 0; -- 



RespSceneMonsterMoveToNotifyMsg.meta = {__index = RespSceneMonsterMoveToNotifyMsg};
function RespSceneMonsterMoveToNotifyMsg:new()
	local obj = setmetatable( {}, RespSceneMonsterMoveToNotifyMsg.meta);
	return obj;
end

function RespSceneMonsterMoveToNotifyMsg:ParseData(pak)
	local idx = 1;

	self.roleId, idx = readGuid(pak, idx);
	self.disX, idx = readInt(pak, idx);
	self.disY, idx = readInt(pak, idx);

end



--[[
福神降临(抢门活动)进入类型
]]

_G.RespMascotComeTypeMsg = {};

RespMascotComeTypeMsg.msgId = 8552;
RespMascotComeTypeMsg.type = 0; -- 进入副本类型 1 2 3 4 5



RespMascotComeTypeMsg.meta = {__index = RespMascotComeTypeMsg};
function RespMascotComeTypeMsg:new()
	local obj = setmetatable( {}, RespMascotComeTypeMsg.meta);
	return obj;
end

function RespMascotComeTypeMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

end



--[[
福神降临(抢门活动)副本内信息
]]

_G.RespMascotComeInfoMsg = {};

RespMascotComeInfoMsg.msgId = 8553;
RespMascotComeInfoMsg.wave = 0; -- 波数
RespMascotComeInfoMsg.monsterNum = 0; -- 击杀怪物数量



RespMascotComeInfoMsg.meta = {__index = RespMascotComeInfoMsg};
function RespMascotComeInfoMsg:new()
	local obj = setmetatable( {}, RespMascotComeInfoMsg.meta);
	return obj;
end

function RespMascotComeInfoMsg:ParseData(pak)
	local idx = 1;

	self.wave, idx = readInt(pak, idx);
	self.monsterNum, idx = readInt(pak, idx);

end



--[[
福神降临(抢门活动)结局面板
]]

_G.RespMascotComeResultMsg = {};

RespMascotComeResultMsg.msgId = 8554;
RespMascotComeResultMsg.result = 0; -- 挑战结果 0 成功



RespMascotComeResultMsg.meta = {__index = RespMascotComeResultMsg};
function RespMascotComeResultMsg:new()
	local obj = setmetatable( {}, RespMascotComeResultMsg.meta);
	return obj;
end

function RespMascotComeResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
福神降临(抢门活动)传送门剩余数量
]]

_G.RespSC_MascotComePortalNumMsg = {};

RespSC_MascotComePortalNumMsg.msgId = 8555;
RespSC_MascotComePortalNumMsg.num = 0; -- 剩余传送门数量
RespSC_MascotComePortalNumMsg.mapID = 0; -- 传送门的地图ID



RespSC_MascotComePortalNumMsg.meta = {__index = RespSC_MascotComePortalNumMsg};
function RespSC_MascotComePortalNumMsg:new()
	local obj = setmetatable( {}, RespSC_MascotComePortalNumMsg.meta);
	return obj;
end

function RespSC_MascotComePortalNumMsg:ParseData(pak)
	local idx = 1;

	self.num, idx = readInt(pak, idx);
	self.mapID, idx = readInt(pak, idx);

end



--[[
跨天推
]]

_G.RespAcrossDayInformMsg = {};

RespAcrossDayInformMsg.msgId = 8556;
RespAcrossDayInformMsg.time = 0; -- 时间



RespAcrossDayInformMsg.meta = {__index = RespAcrossDayInformMsg};
function RespAcrossDayInformMsg:new()
	local obj = setmetatable( {}, RespAcrossDayInformMsg.meta);
	return obj;
end

function RespAcrossDayInformMsg:ParseData(pak)
	local idx = 1;

	self.time, idx = readInt(pak, idx);

end



--[[
客户端返回运营活动领奖
]]

_G.RespGetYunYingRewardMsg = {};

RespGetYunYingRewardMsg.msgId = 8557;
RespGetYunYingRewardMsg.rst = 0; -- 结果 0:成功 -1:类型错误 -2:已领取
RespGetYunYingRewardMsg.type = 0; -- 类型



RespGetYunYingRewardMsg.meta = {__index = RespGetYunYingRewardMsg};
function RespGetYunYingRewardMsg:new()
	local obj = setmetatable( {}, RespGetYunYingRewardMsg.meta);
	return obj;
end

function RespGetYunYingRewardMsg:ParseData(pak)
	local idx = 1;

	self.rst, idx = readByte(pak, idx);
	self.type, idx = readInt(pak, idx);

end



--[[
返回首冲团购信息
]]

_G.RespPartyGroupChargeMsg = {};

RespPartyGroupChargeMsg.msgId = 8559;
RespPartyGroupChargeMsg.id = 0; -- 组id
RespPartyGroupChargeMsg.chargenum = 0; -- 首冲充值人数



RespPartyGroupChargeMsg.meta = {__index = RespPartyGroupChargeMsg};
function RespPartyGroupChargeMsg:new()
	local obj = setmetatable( {}, RespPartyGroupChargeMsg.meta);
	return obj;
end

function RespPartyGroupChargeMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readInt(pak, idx);
	self.chargenum, idx = readInt(pak, idx);

end



--[[
服务器返回BOSS挑战列表
]]

_G.RespPersonalBossListMsg = {};

RespPersonalBossListMsg.msgId = 8560;
RespPersonalBossListMsg.itemEnterNum = 0; -- 道具进入次数(已进入次数)
RespPersonalBossListMsg.PersonalBossItem_size = 0; -- BOSS信息 size
RespPersonalBossListMsg.PersonalBossItem = {}; -- BOSS信息 list



--[[
PersonalBossVOVO = {
	id = 0; -- BOSSID
	num = 0; -- 已进入次数
	isfirst = 0; -- 是否已每日首通 0已首通
}
]]

RespPersonalBossListMsg.meta = {__index = RespPersonalBossListMsg};
function RespPersonalBossListMsg:new()
	local obj = setmetatable( {}, RespPersonalBossListMsg.meta);
	return obj;
end

function RespPersonalBossListMsg:ParseData(pak)
	local idx = 1;

	self.itemEnterNum, idx = readInt(pak, idx);

	local list1 = {};
	self.PersonalBossItem = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local PersonalBossVOVo = {};
		PersonalBossVOVo.id, idx = readInt(pak, idx);
		PersonalBossVOVo.num, idx = readInt(pak, idx);
		PersonalBossVOVo.isfirst, idx = readInt(pak, idx);
		table.push(list1,PersonalBossVOVo);
	end

end



--[[
服务器返回进入个人BOSS结果
]]

_G.RespBackEnterResultPersonalBossMsg = {};

RespBackEnterResultPersonalBossMsg.msgId = 8561;
RespBackEnterResultPersonalBossMsg.result = 0; -- 结果 0 成功 -1等级不足 -2次数不足 -3非VIP -4组队 -5异常
RespBackEnterResultPersonalBossMsg.id = 0; -- id 进入的ID
RespBackEnterResultPersonalBossMsg.type = 0; -- 进入形式 是否是道具 0是道具进入
RespBackEnterResultPersonalBossMsg.enterNum = 0; -- 已进入免费次数
RespBackEnterResultPersonalBossMsg.itemEnterNum = 0; -- 已进入道具次数



RespBackEnterResultPersonalBossMsg.meta = {__index = RespBackEnterResultPersonalBossMsg};
function RespBackEnterResultPersonalBossMsg:new()
	local obj = setmetatable( {}, RespBackEnterResultPersonalBossMsg.meta);
	return obj;
end

function RespBackEnterResultPersonalBossMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);
	self.enterNum, idx = readInt(pak, idx);
	self.itemEnterNum, idx = readInt(pak, idx);

end



--[[
服务器:退出个人BOSS结果
]]

_G.RespBackQuitPersonalBossMsg = {};

RespBackQuitPersonalBossMsg.msgId = 8562;
RespBackQuitPersonalBossMsg.result = 0; -- 结果 0 成功 -1失败



RespBackQuitPersonalBossMsg.meta = {__index = RespBackQuitPersonalBossMsg};
function RespBackQuitPersonalBossMsg:new()
	local obj = setmetatable( {}, RespBackQuitPersonalBossMsg.meta);
	return obj;
end

function RespBackQuitPersonalBossMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器:挑战个人BOSS结果
]]

_G.RespPersonalBossResultMsg = {};

RespPersonalBossResultMsg.msgId = 8563;
RespPersonalBossResultMsg.result = 0; -- 结果 0 成功 -1失败
RespPersonalBossResultMsg.isfirst = 0; -- 结果 0 是



RespPersonalBossResultMsg.meta = {__index = RespPersonalBossResultMsg};
function RespPersonalBossResultMsg:new()
	local obj = setmetatable( {}, RespPersonalBossResultMsg.meta);
	return obj;
end

function RespPersonalBossResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.isfirst, idx = readInt(pak, idx);

end



--[[
服务器:返回卫士特权状态
]]

_G.RespBackWeishiStatusMsg = {};

RespBackWeishiStatusMsg.msgId = 8566;
RespBackWeishiStatusMsg.type = 0; -- 类型, 1:卫士特权 2:游戏大厅 3:特权加速礼包
RespBackWeishiStatusMsg.status = 0; -- 结果 0 关闭 1开启



RespBackWeishiStatusMsg.meta = {__index = RespBackWeishiStatusMsg};
function RespBackWeishiStatusMsg:new()
	local obj = setmetatable( {}, RespBackWeishiStatusMsg.meta);
	return obj;
end

function RespBackWeishiStatusMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.status, idx = readInt(pak, idx);

end



--[[
服务器:扫荡斗破苍穹
]]

_G.RespBackBabelSweepsDateMsg = {};

RespBackBabelSweepsDateMsg.msgId = 8567;
RespBackBabelSweepsDateMsg.result = 0; -- 结果 0 成功 -1失败
RespBackBabelSweepsDateMsg.layer = 0; -- 挑战层数 配表ID
RespBackBabelSweepsDateMsg.rewardList_size = 0; -- 列表 size
RespBackBabelSweepsDateMsg.rewardList = {}; -- 列表 list



--[[
rewardVOVO = {
	id = 0; -- 物品ID
	num = 0; -- 数量
}
]]

RespBackBabelSweepsDateMsg.meta = {__index = RespBackBabelSweepsDateMsg};
function RespBackBabelSweepsDateMsg:new()
	local obj = setmetatable( {}, RespBackBabelSweepsDateMsg.meta);
	return obj;
end

function RespBackBabelSweepsDateMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.layer, idx = readInt(pak, idx);

	local list1 = {};
	self.rewardList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local rewardVOVo = {};
		rewardVOVo.id, idx = readInt(pak, idx);
		rewardVOVo.num, idx = readInt(pak, idx);
		table.push(list1,rewardVOVo);
	end

end



--[[
服务器通知:骑战兵器信息
]]

_G.RespQiZhanInfoMsg = {};

RespQiZhanInfoMsg.msgId = 8569;
RespQiZhanInfoMsg.level = 0; -- 骑战等阶
RespQiZhanInfoMsg.selectlevel = 0; -- 当前使用的骑战等阶
RespQiZhanInfoMsg.blessing = 0; -- 进阶祝福值
RespQiZhanInfoMsg.pillNum = 0; -- 属性丹数量



RespQiZhanInfoMsg.meta = {__index = RespQiZhanInfoMsg};
function RespQiZhanInfoMsg:new()
	local obj = setmetatable( {}, RespQiZhanInfoMsg.meta);
	return obj;
end

function RespQiZhanInfoMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);
	self.selectlevel, idx = readInt(pak, idx);
	self.blessing, idx = readInt(pak, idx);
	self.pillNum, idx = readInt(pak, idx);

end



--[[
服务器返回：骑战进阶
]]

_G.RespQiZhanLevelUpMsg = {};

RespQiZhanLevelUpMsg.msgId = 8570;
RespQiZhanLevelUpMsg.result = 0; -- 请求进阶结果 0:成功(成功获得祝福值), 2:骑战未解锁, 3:已达等级上限, 4:熟练度不够, 5:金币不够, 6:道具数量不足
RespQiZhanLevelUpMsg.blessing = 0; -- 进阶后的祝福值



RespQiZhanLevelUpMsg.meta = {__index = RespQiZhanLevelUpMsg};
function RespQiZhanLevelUpMsg:new()
	local obj = setmetatable( {}, RespQiZhanLevelUpMsg.meta);
	return obj;
end

function RespQiZhanLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.blessing, idx = readInt(pak, idx);

end



--[[
顺网平台,需上线推
]]

_G.RespShunwangTerraceMsg = {};

RespShunwangTerraceMsg.msgId = 8571;
RespShunwangTerraceMsg.swlvl = 0; -- 我的vip等级
RespShunwangTerraceMsg.result = 0; -- 错误结果--上线推-1，0成功 -2等级不到 -3已经领过
RespShunwangTerraceMsg.rewardList_size = 0; -- 列表 size
RespShunwangTerraceMsg.rewardList = {}; -- 列表 list



--[[
rewardVOVO = {
	swlvl = 0; -- 顺网vip等级
	state = 0; -- 当前等级下的领取状态，0=可领取，1=不可领取
}
]]

RespShunwangTerraceMsg.meta = {__index = RespShunwangTerraceMsg};
function RespShunwangTerraceMsg:new()
	local obj = setmetatable( {}, RespShunwangTerraceMsg.meta);
	return obj;
end

function RespShunwangTerraceMsg:ParseData(pak)
	local idx = 1;

	self.swlvl, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);

	local list1 = {};
	self.rewardList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local rewardVOVo = {};
		rewardVOVo.swlvl, idx = readInt(pak, idx);
		rewardVOVo.state, idx = readInt(pak, idx);
		table.push(list1,rewardVOVo);
	end

end



--[[
商店道具兑换返回结果
]]

_G.RespExchangeShopResultMsg = {};

RespExchangeShopResultMsg.msgId = 8572;
RespExchangeShopResultMsg.result = 0; -- 0=成功 1=失败
RespExchangeShopResultMsg.id = 0; -- 商品id
RespExchangeShopResultMsg.num = 0; -- 数量



RespExchangeShopResultMsg.meta = {__index = RespExchangeShopResultMsg};
function RespExchangeShopResultMsg:new()
	local obj = setmetatable( {}, RespExchangeShopResultMsg.meta);
	return obj;
end

function RespExchangeShopResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);

end



--[[
累计充值,需上线推,变化推
]]

_G.RespFeihuoTerraceMsg = {};

RespFeihuoTerraceMsg.msgId = 8573;
RespFeihuoTerraceMsg.consume = 0; -- 月累计充值
RespFeihuoTerraceMsg.Maxcon = 0; -- 最大单次充值数



RespFeihuoTerraceMsg.meta = {__index = RespFeihuoTerraceMsg};
function RespFeihuoTerraceMsg:new()
	local obj = setmetatable( {}, RespFeihuoTerraceMsg.meta);
	return obj;
end

function RespFeihuoTerraceMsg:ParseData(pak)
	local idx = 1;

	self.consume, idx = readInt(pak, idx);
	self.Maxcon, idx = readInt(pak, idx);

end



--[[
激活骑战返回结果
]]

_G.RespActiveQiZhanResultMsg = {};

RespActiveQiZhanResultMsg.msgId = 8574;
RespActiveQiZhanResultMsg.result = 0; -- 0=成功 1=失败



RespActiveQiZhanResultMsg.meta = {__index = RespActiveQiZhanResultMsg};
function RespActiveQiZhanResultMsg:new()
	local obj = setmetatable( {}, RespActiveQiZhanResultMsg.meta);
	return obj;
end

function RespActiveQiZhanResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回骑战副本date
]]

_G.RespBackQiZhanDungeonDateMsg = {};

RespBackQiZhanDungeonDateMsg.msgId = 8575;
RespBackQiZhanDungeonDateMsg.enterNum = 0; -- 今日进入次数 (已进入)
RespBackQiZhanDungeonDateMsg.nowBestLayer = 0; -- 今日挑战的最好成绩
RespBackQiZhanDungeonDateMsg.bestLayer = 0; -- 自己历史最好成绩
RespBackQiZhanDungeonDateMsg.bestTeamLayer = 0; -- 全服历史最好成绩
RespBackQiZhanDungeonDateMsg.bestTeamList_size = 4; -- 最强通关队伍列表 size
RespBackQiZhanDungeonDateMsg.bestTeamList = {}; -- 最强通关队伍列表 list
RespBackQiZhanDungeonDateMsg.rankList_size = 10; -- 排行榜列表 size
RespBackQiZhanDungeonDateMsg.rankList = {}; -- 排行榜列表 list



--[[
bestTeamVOVO = {
	name = ""; -- 玩家名称
	cap = 0; -- 对战 0：是
}
]]
--[[
rankVOVO = {
	rankIndex = 0; -- 名次
	name = ""; -- 人物名称
	layer = 0; -- 通关层数
}
]]

RespBackQiZhanDungeonDateMsg.meta = {__index = RespBackQiZhanDungeonDateMsg};
function RespBackQiZhanDungeonDateMsg:new()
	local obj = setmetatable( {}, RespBackQiZhanDungeonDateMsg.meta);
	return obj;
end

function RespBackQiZhanDungeonDateMsg:ParseData(pak)
	local idx = 1;

	self.enterNum, idx = readInt(pak, idx);
	self.nowBestLayer, idx = readInt(pak, idx);
	self.bestLayer, idx = readInt(pak, idx);
	self.bestTeamLayer, idx = readInt(pak, idx);

	local list1 = {};
	self.bestTeamList = list1;
	local list1Size = 4;

	for i=1,list1Size do
		local bestTeamVOVo = {};
		bestTeamVOVo.name, idx = readString(pak, idx, 32);
		bestTeamVOVo.cap, idx = readInt(pak, idx);
		table.push(list1,bestTeamVOVo);
	end

	local list2 = {};
	self.rankList = list2;
	local list2Size = 10;

	for i=1,list2Size do
		local rankVOVo = {};
		rankVOVo.rankIndex, idx = readInt(pak, idx);
		rankVOVo.name, idx = readString(pak, idx, 32);
		rankVOVo.layer, idx = readInt(pak, idx);
		table.push(list2,rankVOVo);
	end

end



--[[
返回骑战副本进入结果
]]

_G.RespBackQiZhanDungeonEnterMsg = {};

RespBackQiZhanDungeonEnterMsg.msgId = 8576;
RespBackQiZhanDungeonEnterMsg.result = 0; -- 进入结果 0成功 错误码  1不是队长 2等级不足 3 次数不足 4 队友次数不足 5队长不在线 6队长功能未开启 7队友功能未开启 8 正在活动中
RespBackQiZhanDungeonEnterMsg.layer = 0; -- 进入层
RespBackQiZhanDungeonEnterMsg.state = 0; -- 挑战状态 0未挑战 1以挑战



RespBackQiZhanDungeonEnterMsg.meta = {__index = RespBackQiZhanDungeonEnterMsg};
function RespBackQiZhanDungeonEnterMsg:new()
	local obj = setmetatable( {}, RespBackQiZhanDungeonEnterMsg.meta);
	return obj;
end

function RespBackQiZhanDungeonEnterMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.layer, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
返回骑战副本挑战过程
]]

_G.RespBackQiZhanDungeonInfoMsg = {};

RespBackQiZhanDungeonInfoMsg.msgId = 8577;
RespBackQiZhanDungeonInfoMsg.killList_size = 0; -- 击杀怪物列表 size
RespBackQiZhanDungeonInfoMsg.killList = {}; -- 击杀怪物列表 list



--[[
monsterVOVO = {
	monsterId = 0; -- 击杀怪物ID
	monsterNum = 0; -- 击杀怪物数量
}
]]

RespBackQiZhanDungeonInfoMsg.meta = {__index = RespBackQiZhanDungeonInfoMsg};
function RespBackQiZhanDungeonInfoMsg:new()
	local obj = setmetatable( {}, RespBackQiZhanDungeonInfoMsg.meta);
	return obj;
end

function RespBackQiZhanDungeonInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.killList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local monsterVOVo = {};
		monsterVOVo.monsterId, idx = readInt(pak, idx);
		monsterVOVo.monsterNum, idx = readInt(pak, idx);
		table.push(list1,monsterVOVo);
	end

end



--[[
返回骑战副本通关结果
]]

_G.RespBackQiZhanDungeonResultMsg = {};

RespBackQiZhanDungeonResultMsg.msgId = 8578;
RespBackQiZhanDungeonResultMsg.result = 0; -- 通关结果 0成功
RespBackQiZhanDungeonResultMsg.layer = 0; -- 通关层数



RespBackQiZhanDungeonResultMsg.meta = {__index = RespBackQiZhanDungeonResultMsg};
function RespBackQiZhanDungeonResultMsg:new()
	local obj = setmetatable( {}, RespBackQiZhanDungeonResultMsg.meta);
	return obj;
end

function RespBackQiZhanDungeonResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.layer, idx = readInt(pak, idx);

end



--[[
返回骑战副本退出结果
]]

_G.RespBackQiZhanDungeonQuitMsg = {};

RespBackQiZhanDungeonQuitMsg.msgId = 8579;
RespBackQiZhanDungeonQuitMsg.result = 0; -- 进入结果 0成功



RespBackQiZhanDungeonQuitMsg.meta = {__index = RespBackQiZhanDungeonQuitMsg};
function RespBackQiZhanDungeonQuitMsg:new()
	local obj = setmetatable( {}, RespBackQiZhanDungeonQuitMsg.meta);
	return obj;
end

function RespBackQiZhanDungeonQuitMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回打开骑战副本组队进入确认框
]]

_G.RespBackQiZhanDungeonTeamConfirmMsg = {};

RespBackQiZhanDungeonTeamConfirmMsg.msgId = 8580;



RespBackQiZhanDungeonTeamConfirmMsg.meta = {__index = RespBackQiZhanDungeonTeamConfirmMsg};
function RespBackQiZhanDungeonTeamConfirmMsg:new()
	local obj = setmetatable( {}, RespBackQiZhanDungeonTeamConfirmMsg.meta);
	return obj;
end

function RespBackQiZhanDungeonTeamConfirmMsg:ParseData(pak)
	local idx = 1;


end



--[[
返回骑战副本组队进入确认框信息
]]

_G.RespBackQiZhanDungeonTeamConfirmDataMsg = {};

RespBackQiZhanDungeonTeamConfirmDataMsg.msgId = 8581;
RespBackQiZhanDungeonTeamConfirmDataMsg.palyerGuid = ""; -- 玩家guid
RespBackQiZhanDungeonTeamConfirmDataMsg.state = 0; -- 准备状态 0准备 1 拒绝



RespBackQiZhanDungeonTeamConfirmDataMsg.meta = {__index = RespBackQiZhanDungeonTeamConfirmDataMsg};
function RespBackQiZhanDungeonTeamConfirmDataMsg:new()
	local obj = setmetatable( {}, RespBackQiZhanDungeonTeamConfirmDataMsg.meta);
	return obj;
end

function RespBackQiZhanDungeonTeamConfirmDataMsg:ParseData(pak)
	local idx = 1;

	self.palyerGuid, idx = readGuid(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
切换骑战返回结果
]]

_G.RespChangeQiZhanResultMsg = {};

RespChangeQiZhanResultMsg.msgId = 8582;
RespChangeQiZhanResultMsg.result = 0; -- 0=成功 1=失败
RespChangeQiZhanResultMsg.level = 0; -- 骑战等阶



RespChangeQiZhanResultMsg.meta = {__index = RespChangeQiZhanResultMsg};
function RespChangeQiZhanResultMsg:new()
	local obj = setmetatable( {}, RespChangeQiZhanResultMsg.meta);
	return obj;
end

function RespChangeQiZhanResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);

end



--[[
平台vip图标开启
]]

_G.RespPlatformVipMsg = {};

RespPlatformVipMsg.msgId = 8583;
RespPlatformVipMsg.isOpen = 0; -- 是否开启 0关闭 1开启



RespPlatformVipMsg.meta = {__index = RespPlatformVipMsg};
function RespPlatformVipMsg:new()
	local obj = setmetatable( {}, RespPlatformVipMsg.meta);
	return obj;
end

function RespPlatformVipMsg:ParseData(pak)
	local idx = 1;

	self.isOpen, idx = readByte(pak, idx);

end



--[[
返回Boss勋章信息,上线/功能开启时发
]]

_G.RespBossMedalInfoMsg = {};

RespBossMedalInfoMsg.msgId = 8584;
RespBossMedalInfoMsg.level = 0; -- 等级
RespBossMedalInfoMsg.star = 0; -- 星
RespBossMedalInfoMsg.growValue = 0; -- 成长值
RespBossMedalInfoMsg.pointsList_size = 0; -- boss击杀数列表 size
RespBossMedalInfoMsg.pointsList = {}; -- boss击杀数列表 list



--[[
pointsListVO = {
	bossNum = 0; -- boss击杀数
}
]]

RespBossMedalInfoMsg.meta = {__index = RespBossMedalInfoMsg};
function RespBossMedalInfoMsg:new()
	local obj = setmetatable( {}, RespBossMedalInfoMsg.meta);
	return obj;
end

function RespBossMedalInfoMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);
	self.star, idx = readInt(pak, idx);
	self.growValue, idx = readInt(pak, idx);

	local list1 = {};
	self.pointsList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local pointsListVo = {};
		pointsListVo.bossNum, idx = readInt(pak, idx);
		table.push(list1,pointsListVo);
	end

end



--[[
返回Boss勋章升级结果
]]

_G.RespBossMedalLevelUpMsg = {};

RespBossMedalLevelUpMsg.msgId = 8585;
RespBossMedalLevelUpMsg.result = 0; -- 0成功
RespBossMedalLevelUpMsg.level = 0; -- 等级
RespBossMedalLevelUpMsg.star = 0; -- 星
RespBossMedalLevelUpMsg.growValue = 0; -- 成长值



RespBossMedalLevelUpMsg.meta = {__index = RespBossMedalLevelUpMsg};
function RespBossMedalLevelUpMsg:new()
	local obj = setmetatable( {}, RespBossMedalLevelUpMsg.meta);
	return obj;
end

function RespBossMedalLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.level, idx = readInt(pak, idx);
	self.star, idx = readInt(pak, idx);
	self.growValue, idx = readInt(pak, idx);

end



--[[
返回Boss击杀数
]]

_G.RespBossMedalPointsMsg = {};

RespBossMedalPointsMsg.msgId = 8586;
RespBossMedalPointsMsg.bossType = 0; -- boss类别 0:世界boss 1:个人boss 2:地宫boss 3:野外boss
RespBossMedalPointsMsg.bossNum = 0; -- boss击杀数



RespBossMedalPointsMsg.meta = {__index = RespBossMedalPointsMsg};
function RespBossMedalPointsMsg:new()
	local obj = setmetatable( {}, RespBossMedalPointsMsg.meta);
	return obj;
end

function RespBossMedalPointsMsg:ParseData(pak)
	local idx = 1;

	self.bossType, idx = readByte(pak, idx);
	self.bossNum, idx = readInt(pak, idx);

end



--[[
返回迅雷平台手机绑定领取状态
]]

_G.RespYunYingXunleiRewardMsg = {};

RespYunYingXunleiRewardMsg.msgId = 8587;
RespYunYingXunleiRewardMsg.value = 0; -- 手机绑定奖励,0没领取，1已领取



RespYunYingXunleiRewardMsg.meta = {__index = RespYunYingXunleiRewardMsg};
function RespYunYingXunleiRewardMsg:new()
	local obj = setmetatable( {}, RespYunYingXunleiRewardMsg.meta);
	return obj;
end

function RespYunYingXunleiRewardMsg:ParseData(pak)
	local idx = 1;

	self.value, idx = readInt(pak, idx);

end



--[[
服务器通知：帮派地宫争夺战战场积分
]]

_G.RespUnionDiGongScoreNotifyMsg = {};

RespUnionDiGongScoreNotifyMsg.msgId = 8592;
RespUnionDiGongScoreNotifyMsg.RoleName = ""; -- 当前扛旗的玩家名称
RespUnionDiGongScoreNotifyMsg.UnionName = ""; -- 当前扛旗的帮派名称
RespUnionDiGongScoreNotifyMsg.UnionTime = 0; -- 活动倒计时
RespUnionDiGongScoreNotifyMsg.Unionid1 = ""; -- 帮派id
RespUnionDiGongScoreNotifyMsg.Score1 = 0; -- 积分数
RespUnionDiGongScoreNotifyMsg.Unionid2 = ""; -- 帮派id
RespUnionDiGongScoreNotifyMsg.Score2 = 0; -- 积分数



RespUnionDiGongScoreNotifyMsg.meta = {__index = RespUnionDiGongScoreNotifyMsg};
function RespUnionDiGongScoreNotifyMsg:new()
	local obj = setmetatable( {}, RespUnionDiGongScoreNotifyMsg.meta);
	return obj;
end

function RespUnionDiGongScoreNotifyMsg:ParseData(pak)
	local idx = 1;

	self.RoleName, idx = readString(pak, idx, 32);
	self.UnionName, idx = readString(pak, idx, 32);
	self.UnionTime, idx = readInt(pak, idx);
	self.Unionid1, idx = readGuid(pak, idx);
	self.Score1, idx = readInt(pak, idx);
	self.Unionid2, idx = readGuid(pak, idx);
	self.Score2, idx = readInt(pak, idx);

end



--[[
服务器通知：帮派地宫争夺战建筑物状态
]]

_G.RespUnionDiGongBuStateMsg = {};

RespUnionDiGongBuStateMsg.msgId = 8593;
RespUnionDiGongBuStateMsg.zhuziList_size = 2; -- 柱子列表 size
RespUnionDiGongBuStateMsg.zhuziList = {}; -- 柱子列表 list



--[[
zhuziVOVO = {
	id = 0; -- 柱子id
	Unionid = ""; -- 帮派id
}
]]

RespUnionDiGongBuStateMsg.meta = {__index = RespUnionDiGongBuStateMsg};
function RespUnionDiGongBuStateMsg:new()
	local obj = setmetatable( {}, RespUnionDiGongBuStateMsg.meta);
	return obj;
end

function RespUnionDiGongBuStateMsg:ParseData(pak)
	local idx = 1;


	local list = {};
	self.zhuziList = list;
	local listSize = 2;

	for i=1,listSize do
		local zhuziVOVo = {};
		zhuziVOVo.id, idx = readInt(pak, idx);
		zhuziVOVo.Unionid, idx = readGuid(pak, idx);
		table.push(list,zhuziVOVo);
	end

end



--[[
服务器通知：帮派地宫争夺战结算结果
]]

_G.RespUnionDiGongRetMsg = {};

RespUnionDiGongRetMsg.msgId = 8595;
RespUnionDiGongRetMsg.Unionid = ""; -- 获胜方帮派id



RespUnionDiGongRetMsg.meta = {__index = RespUnionDiGongRetMsg};
function RespUnionDiGongRetMsg:new()
	local obj = setmetatable( {}, RespUnionDiGongRetMsg.meta);
	return obj;
end

function RespUnionDiGongRetMsg:ParseData(pak)
	local idx = 1;

	self.Unionid, idx = readGuid(pak, idx);

end



--[[
返回帮派地宫争夺战状态
]]

_G.RespUnionDiGongStateMsg = {};

RespUnionDiGongStateMsg.msgId = 8596;
RespUnionDiGongStateMsg.result = 0; -- 结果 0:关闭 1：开启



RespUnionDiGongStateMsg.meta = {__index = RespUnionDiGongStateMsg};
function RespUnionDiGongStateMsg:new()
	local obj = setmetatable( {}, RespUnionDiGongStateMsg.meta);
	return obj;
end

function RespUnionDiGongStateMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器通知：旗帜显示位置
]]

_G.RespUnionDiGongFlagNotifyMsg = {};

RespUnionDiGongFlagNotifyMsg.msgId = 8601;
RespUnionDiGongFlagNotifyMsg.posX = 0; -- X坐标
RespUnionDiGongFlagNotifyMsg.posY = 0; -- Y坐标



RespUnionDiGongFlagNotifyMsg.meta = {__index = RespUnionDiGongFlagNotifyMsg};
function RespUnionDiGongFlagNotifyMsg:new()
	local obj = setmetatable( {}, RespUnionDiGongFlagNotifyMsg.meta);
	return obj;
end

function RespUnionDiGongFlagNotifyMsg:ParseData(pak)
	local idx = 1;

	self.posX, idx = readDouble(pak, idx);
	self.posY, idx = readDouble(pak, idx);

end



--[[
服务器推送需要在地图上显示的旗帜信息
]]

_G.RespDGWarMapFlagMsg = {};

RespDGWarMapFlagMsg.msgId = 8602;
RespDGWarMapFlagMsg.posX = 0; -- 玩家x坐标
RespDGWarMapFlagMsg.posY = 0; -- 玩家y坐标



RespDGWarMapFlagMsg.meta = {__index = RespDGWarMapFlagMsg};
function RespDGWarMapFlagMsg:new()
	local obj = setmetatable( {}, RespDGWarMapFlagMsg.meta);
	return obj;
end

function RespDGWarMapFlagMsg:ParseData(pak)
	local idx = 1;

	self.posX, idx = readInt(pak, idx);
	self.posY, idx = readInt(pak, idx);

end



--[[
返回卓越洗练临时数据
]]

_G.RespEquipNewSuperNewValMsg = {};

RespEquipNewSuperNewValMsg.msgId = 8603;
RespEquipNewSuperNewValMsg.result = 0; -- 错误类型，0成功，-1失败，-2不是卓越装备无法洗练, -3 该装备不能洗练, -4已经达到洗练最高 -5道具不足
RespEquipNewSuperNewValMsg.cid = ""; -- 装备cid
RespEquipNewSuperNewValMsg.newSuperList_size = 3; -- 新卓越属性列表 size
RespEquipNewSuperNewValMsg.newSuperList = {}; -- 新卓越属性列表 list



--[[
NewSuperVOVO = {
	id = 0; -- 新卓越id
	wash = 0; -- 洗练值
}
]]

RespEquipNewSuperNewValMsg.meta = {__index = RespEquipNewSuperNewValMsg};
function RespEquipNewSuperNewValMsg:new()
	local obj = setmetatable( {}, RespEquipNewSuperNewValMsg.meta);
	return obj;
end

function RespEquipNewSuperNewValMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.cid, idx = readGuid(pak, idx);

	local list1 = {};
	self.newSuperList = list1;
	local list1Size = 3;

	for i=1,list1Size do
		local NewSuperVOVo = {};
		NewSuperVOVo.id, idx = readInt(pak, idx);
		NewSuperVOVo.wash, idx = readInt(pak, idx);
		table.push(list1,NewSuperVOVo);
	end

end



--[[
返回保存属性
]]

_G.RespEquipNewSuperNewValSetMsg = {};

RespEquipNewSuperNewValSetMsg.msgId = 8604;
RespEquipNewSuperNewValSetMsg.result = 0; -- 错误类型，0成功，-1失败，-2不是卓越装备无法洗练保存。-3 该装备不能洗练
RespEquipNewSuperNewValSetMsg.cid = ""; -- 装备cid
RespEquipNewSuperNewValSetMsg.newSuperList_size = 3; -- 新卓越属性列表 size
RespEquipNewSuperNewValSetMsg.newSuperList = {}; -- 新卓越属性列表 list



--[[
NewSuperVOVO = {
	id = 0; -- 新卓越id
	wash = 0; -- 洗练值
}
]]

RespEquipNewSuperNewValSetMsg.meta = {__index = RespEquipNewSuperNewValSetMsg};
function RespEquipNewSuperNewValSetMsg:new()
	local obj = setmetatable( {}, RespEquipNewSuperNewValSetMsg.meta);
	return obj;
end

function RespEquipNewSuperNewValSetMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.cid, idx = readGuid(pak, idx);

	local list1 = {};
	self.newSuperList = list1;
	local list1Size = 3;

	for i=1,list1Size do
		local NewSuperVOVo = {};
		NewSuperVOVo.id, idx = readInt(pak, idx);
		NewSuperVOVo.wash, idx = readInt(pak, idx);
		table.push(list1,NewSuperVOVo);
	end

end



--[[
服务器返回:跨服BOSS信息
]]

_G.RespBossInfoMsg = {};

RespBossInfoMsg.msgId = 8606;
RespBossInfoMsg.remainsec = 0; -- 剩余时间秒
RespBossInfoMsg.status = 0; -- 状态（0-准备， 1-小BOSS， 2-大BOSS，3-宝箱）
RespBossInfoMsg.level = 0; -- 等级
RespBossInfoMsg.baoxiangremainsec = 0; -- 宝箱刷新时间秒
RespBossInfoMsg.statusList_size = 5; -- 状态列表 size
RespBossInfoMsg.statusList = {}; -- 状态列表 list
RespBossInfoMsg.statueList_size = 4; -- 神像状态列表 size
RespBossInfoMsg.statueList = {}; -- 神像状态列表 list



--[[
statusVOVO = {
	status = 0; -- BOSS状态0未刷新1已刷新2死亡
	roleID = ""; -- 击杀bossd的playerId
}
]]
--[[
statueVOVO = {
	groupid = 0; -- 区服ID
}
]]

RespBossInfoMsg.meta = {__index = RespBossInfoMsg};
function RespBossInfoMsg:new()
	local obj = setmetatable( {}, RespBossInfoMsg.meta);
	return obj;
end

function RespBossInfoMsg:ParseData(pak)
	local idx = 1;

	self.remainsec, idx = readInt(pak, idx);
	self.status, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);
	self.baoxiangremainsec, idx = readInt(pak, idx);

	local list = {};
	self.statusList = list;
	local listSize = 5;

	for i=1,listSize do
		local statusVOVo = {};
		statusVOVo.status, idx = readByte(pak, idx);
		statusVOVo.roleID, idx = readGuid(pak, idx);
		table.push(list,statusVOVo);
	end

	local list = {};
	self.statueList = list;
	local listSize = 4;

	for i=1,listSize do
		local statueVOVo = {};
		statueVOVo.groupid, idx = readInt(pak, idx);
		table.push(list,statueVOVo);
	end

end



--[[
服务器返回:跨服BOSS排行信息
]]

_G.RespCrossBossFightRankMsg = {};

RespCrossBossFightRankMsg.msgId = 8607;
RespCrossBossFightRankMsg.type = 0; -- BOSS类型
RespCrossBossFightRankMsg.rankList_size = 0; -- boss排行列表 size
RespCrossBossFightRankMsg.rankList = {}; -- boss排行列表 list



--[[
rankVOVO = {
	name = ""; -- 人物名称
	damage = 0; -- 伤害
}
]]

RespCrossBossFightRankMsg.meta = {__index = RespCrossBossFightRankMsg};
function RespCrossBossFightRankMsg:new()
	local obj = setmetatable( {}, RespCrossBossFightRankMsg.meta);
	return obj;
end

function RespCrossBossFightRankMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

	local list1 = {};
	self.rankList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local rankVOVo = {};
		rankVOVo.name, idx = readString(pak, idx, 32);
		rankVOVo.damage, idx = readInt64(pak, idx);
		table.push(list1,rankVOVo);
	end

end



--[[
服务器返回:跨服BOSS宝箱数
]]

_G.RespCrossBossTreasureMsg = {};

RespCrossBossTreasureMsg.msgId = 8608;
RespCrossBossTreasureMsg.treasurenum = 0; -- 宝箱数



RespCrossBossTreasureMsg.meta = {__index = RespCrossBossTreasureMsg};
function RespCrossBossTreasureMsg:new()
	local obj = setmetatable( {}, RespCrossBossTreasureMsg.meta);
	return obj;
end

function RespCrossBossTreasureMsg:ParseData(pak)
	local idx = 1;

	self.treasurenum, idx = readInt(pak, idx);

end



--[[
服务器返回:跨服BOSS结算
]]

_G.RespCrossBossResultMsg = {};

RespCrossBossResultMsg.msgId = 8609;
RespCrossBossResultMsg.treasurenum = 0; -- 宝箱数
RespCrossBossResultMsg.rankList_size = 5; -- list size
RespCrossBossResultMsg.rankList = {}; -- list list



--[[
rankVOVO = {
	rank = 0; -- 排名
	result = 0; -- 是否击杀(1-击杀，0未击杀)
}
]]

RespCrossBossResultMsg.meta = {__index = RespCrossBossResultMsg};
function RespCrossBossResultMsg:new()
	local obj = setmetatable( {}, RespCrossBossResultMsg.meta);
	return obj;
end

function RespCrossBossResultMsg:ParseData(pak)
	local idx = 1;

	self.treasurenum, idx = readInt(pak, idx);

	local list = {};
	self.rankList = list;
	local listSize = 5;

	for i=1,listSize do
		local rankVOVo = {};
		rankVOVo.rank, idx = readInt(pak, idx);
		rankVOVo.result, idx = readByte(pak, idx);
		table.push(list,rankVOVo);
	end

end



--[[
服务器返回:退出跨服BOSS
]]

_G.RespQuitCrossBossMsg = {};

RespQuitCrossBossMsg.msgId = 8610;
RespQuitCrossBossMsg.result = 0; -- 结果(0-成功，-1失败)



RespQuitCrossBossMsg.meta = {__index = RespQuitCrossBossMsg};
function RespQuitCrossBossMsg:new()
	local obj = setmetatable( {}, RespQuitCrossBossMsg.meta);
	return obj;
end

function RespQuitCrossBossMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回：噬魂徽章升级结果
]]

_G.RespShiHunMedalLevelUpMsg = {};

RespShiHunMedalLevelUpMsg.msgId = 8611;
RespShiHunMedalLevelUpMsg.result = 0; -- 请求进阶结果 0:成功(成功获得魂值), 2:噬魂徽章未解锁, 3:已达等级上限, 4:道具不足
RespShiHunMedalLevelUpMsg.shiHunLevel = 0; -- 当前噬魂徽章等级



RespShiHunMedalLevelUpMsg.meta = {__index = RespShiHunMedalLevelUpMsg};
function RespShiHunMedalLevelUpMsg:new()
	local obj = setmetatable( {}, RespShiHunMedalLevelUpMsg.meta);
	return obj;
end

function RespShiHunMedalLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.shiHunLevel, idx = readInt(pak, idx);

end



--[[
搜狗平台
]]

_G.RespSougouDownHallMsg = {};

RespSougouDownHallMsg.msgId = 8614;
RespSougouDownHallMsg.type = 0; -- 1，游戏大厅，2搜狗皮肤
RespSougouDownHallMsg.result = 0; -- 0成功，-1失败



RespSougouDownHallMsg.meta = {__index = RespSougouDownHallMsg};
function RespSougouDownHallMsg:new()
	local obj = setmetatable( {}, RespSougouDownHallMsg.meta);
	return obj;
end

function RespSougouDownHallMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
搜狗平台，变化上线推
]]

_G.RespSougouBtnStateMsg = {};

RespSougouBtnStateMsg.msgId = 8615;
RespSougouBtnStateMsg.youxiReward = 0; -- 游戏领奖状态，state 0未领，1已领
RespSougouBtnStateMsg.pifuReward = 0; -- 皮肤，state 0未领，1已领



RespSougouBtnStateMsg.meta = {__index = RespSougouBtnStateMsg};
function RespSougouBtnStateMsg:new()
	local obj = setmetatable( {}, RespSougouBtnStateMsg.meta);
	return obj;
end

function RespSougouBtnStateMsg:ParseData(pak)
	local idx = 1;

	self.youxiReward, idx = readInt(pak, idx);
	self.pifuReward, idx = readInt(pak, idx);

end



--[[
珍宝阁返回突破
]]

_G.RespBackJewelleryBreakMsg = {};

RespBackJewelleryBreakMsg.msgId = 8616;
RespBackJewelleryBreakMsg.result = 0; -- 突破结果 0 成功
RespBackJewelleryBreakMsg.id = 0; -- 珍宝阁id



RespBackJewelleryBreakMsg.meta = {__index = RespBackJewelleryBreakMsg};
function RespBackJewelleryBreakMsg:new()
	local obj = setmetatable( {}, RespBackJewelleryBreakMsg.meta);
	return obj;
end

function RespBackJewelleryBreakMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
返回平台手机绑定领取状态
]]

_G.RespYunYingPhoneRewardMsg = {};

RespYunYingPhoneRewardMsg.msgId = 8617;
RespYunYingPhoneRewardMsg.type = 0; -- 1=飞火，2=37wan 
RespYunYingPhoneRewardMsg.value = 0; -- 0没领取，1已领取



RespYunYingPhoneRewardMsg.meta = {__index = RespYunYingPhoneRewardMsg};
function RespYunYingPhoneRewardMsg:new()
	local obj = setmetatable( {}, RespYunYingPhoneRewardMsg.meta);
	return obj;
end

function RespYunYingPhoneRewardMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);
	self.value, idx = readInt(pak, idx);

end



--[[
跨服BOSS返回回血
]]

_G.RespUseCrossHpMsg = {};

RespUseCrossHpMsg.msgId = 8618;
RespUseCrossHpMsg.result = 0; -- 结果,0-成功，1-失败



RespUseCrossHpMsg.meta = {__index = RespUseCrossHpMsg};
function RespUseCrossHpMsg:new()
	local obj = setmetatable( {}, RespUseCrossHpMsg.meta);
	return obj;
end

function RespUseCrossHpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
翅膀升星data
]]

_G.RespWingStarDataMsg = {};

RespWingStarDataMsg.msgId = 8619;
RespWingStarDataMsg.starLevel = 0; -- 翅膀星级
RespWingStarDataMsg.progress = 0; -- 当前进度



RespWingStarDataMsg.meta = {__index = RespWingStarDataMsg};
function RespWingStarDataMsg:new()
	local obj = setmetatable( {}, RespWingStarDataMsg.meta);
	return obj;
end

function RespWingStarDataMsg:ParseData(pak)
	local idx = 1;

	self.starLevel, idx = readInt(pak, idx);
	self.progress, idx = readInt(pak, idx);

end



--[[
返回强化结果
]]

_G.RespBackWingStrenResultMsg = {};

RespBackWingStrenResultMsg.msgId = 8620;
RespBackWingStrenResultMsg.result = 0; -- 强化结果 0成功 
RespBackWingStrenResultMsg.starLevel = 0; -- 翅膀星级
RespBackWingStrenResultMsg.progress = 0; -- 当前进度



RespBackWingStrenResultMsg.meta = {__index = RespBackWingStrenResultMsg};
function RespBackWingStrenResultMsg:new()
	local obj = setmetatable( {}, RespBackWingStrenResultMsg.meta);
	return obj;
end

function RespBackWingStrenResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.starLevel, idx = readInt(pak, idx);
	self.progress, idx = readInt(pak, idx);

end



--[[
服务器通知:神灵信息
]]

_G.RespShenLingInfoMsg = {};

RespShenLingInfoMsg.msgId = 8622;
RespShenLingInfoMsg.level = 0; -- 神灵等阶
RespShenLingInfoMsg.selectlevel = 0; -- 当前使用的神灵等阶
RespShenLingInfoMsg.progress = 0; -- 进阶进度
RespShenLingInfoMsg.pillNum = 0; -- 属性丹数量
RespShenLingInfoMsg.specailSkin_size = 0; -- 神灵列表 size
RespShenLingInfoMsg.specailSkin = {}; -- 神灵列表 list



--[[
specailSkinVO = {
	skinId = 0; -- 神灵皮肤id
	time = 0; -- 神灵皮肤到期时间,-1无限时
}
]]

RespShenLingInfoMsg.meta = {__index = RespShenLingInfoMsg};
function RespShenLingInfoMsg:new()
	local obj = setmetatable( {}, RespShenLingInfoMsg.meta);
	return obj;
end

function RespShenLingInfoMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);
	self.selectlevel, idx = readInt(pak, idx);
	self.progress, idx = readInt(pak, idx);
	self.pillNum, idx = readInt(pak, idx);

	local list1 = {};
	self.specailSkin = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local specailSkinVo = {};
		specailSkinVo.skinId, idx = readInt(pak, idx);
		specailSkinVo.time, idx = readInt64(pak, idx);
		table.push(list1,specailSkinVo);
	end

end



--[[
服务器返回：神灵进阶
]]

_G.RespShenLingLevelUpMsg = {};

RespShenLingLevelUpMsg.msgId = 8623;
RespShenLingLevelUpMsg.result = 0; -- 请求进阶结果 0:成功(成功获得祝福值), 2:神灵未解锁, 3:已达等级上限, 4:金币不够, 5:道具数量不足
RespShenLingLevelUpMsg.progress = 0; -- 进阶后的进度



RespShenLingLevelUpMsg.meta = {__index = RespShenLingLevelUpMsg};
function RespShenLingLevelUpMsg:new()
	local obj = setmetatable( {}, RespShenLingLevelUpMsg.meta);
	return obj;
end

function RespShenLingLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.progress, idx = readInt(pak, idx);

end



--[[
激活神灵返回结果
]]

_G.RespActiveShenLingResultMsg = {};

RespActiveShenLingResultMsg.msgId = 8624;
RespActiveShenLingResultMsg.result = 0; -- 0=成功 1=失败



RespActiveShenLingResultMsg.meta = {__index = RespActiveShenLingResultMsg};
function RespActiveShenLingResultMsg:new()
	local obj = setmetatable( {}, RespActiveShenLingResultMsg.meta);
	return obj;
end

function RespActiveShenLingResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
切换神灵返回结果
]]

_G.RespChangeShenLingResultMsg = {};

RespChangeShenLingResultMsg.msgId = 8625;
RespChangeShenLingResultMsg.result = 0; -- 0=成功 1=失败
RespChangeShenLingResultMsg.shenlingId = 0; -- 神灵Id



RespChangeShenLingResultMsg.meta = {__index = RespChangeShenLingResultMsg};
function RespChangeShenLingResultMsg:new()
	local obj = setmetatable( {}, RespChangeShenLingResultMsg.meta);
	return obj;
end

function RespChangeShenLingResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.shenlingId, idx = readInt(pak, idx);

end



--[[
服务器通知：返回特色神灵变动
]]

_G.RespShenLingSpecialMsg = {};

RespShenLingSpecialMsg.msgId = 8626;
RespShenLingSpecialMsg.shenlingId = 0; -- 特色神灵Id
RespShenLingSpecialMsg.time = 0; -- 神灵皮肤到期时间,-1无限时



RespShenLingSpecialMsg.meta = {__index = RespShenLingSpecialMsg};
function RespShenLingSpecialMsg:new()
	local obj = setmetatable( {}, RespShenLingSpecialMsg.meta);
	return obj;
end

function RespShenLingSpecialMsg:ParseData(pak)
	local idx = 1;

	self.shenlingId, idx = readInt(pak, idx);
	self.time, idx = readInt64(pak, idx);

end



--[[
服务器通知：返回跨服信息
]]

_G.RespCrossInfoMsg = {};

RespCrossInfoMsg.msgId = 8627;
RespCrossInfoMsg.groupId = 0; -- 区服ID



RespCrossInfoMsg.meta = {__index = RespCrossInfoMsg};
function RespCrossInfoMsg:new()
	local obj = setmetatable( {}, RespCrossInfoMsg.meta);
	return obj;
end

function RespCrossInfoMsg:ParseData(pak)
	local idx = 1;

	self.groupId, idx = readInt(pak, idx);

end



--[[
服务器通知：返回跨服预选赛信息
]]

_G.RespCrossPreArenaInfoMsg = {};

RespCrossPreArenaInfoMsg.msgId = 8628;
RespCrossPreArenaInfoMsg.remain = 0; -- 剩余时间
RespCrossPreArenaInfoMsg.score = 0; -- 积分



RespCrossPreArenaInfoMsg.meta = {__index = RespCrossPreArenaInfoMsg};
function RespCrossPreArenaInfoMsg:new()
	local obj = setmetatable( {}, RespCrossPreArenaInfoMsg.meta);
	return obj;
end

function RespCrossPreArenaInfoMsg:ParseData(pak)
	local idx = 1;

	self.remain, idx = readInt(pak, idx);
	self.score, idx = readInt(pak, idx);

end



--[[
服务器通知：跨服预选赛第一名
]]

_G.RespCrossPreArenaRankMsg = {};

RespCrossPreArenaRankMsg.msgId = 8629;
RespCrossPreArenaRankMsg.name = ""; -- 人物名称
RespCrossPreArenaRankMsg.score = 0; -- 积分
RespCrossPreArenaRankMsg.prof = 0; -- 职业



RespCrossPreArenaRankMsg.meta = {__index = RespCrossPreArenaRankMsg};
function RespCrossPreArenaRankMsg:new()
	local obj = setmetatable( {}, RespCrossPreArenaRankMsg.meta);
	return obj;
end

function RespCrossPreArenaRankMsg:ParseData(pak)
	local idx = 1;

	self.name, idx = readString(pak, idx, 32);
	self.score, idx = readInt(pak, idx);
	self.prof, idx = readInt(pak, idx);

end



--[[
服务器通知：跨服预选赛结果
]]

_G.RespCrossPreArenaResultMsg = {};

RespCrossPreArenaResultMsg.msgId = 8630;
RespCrossPreArenaResultMsg.score = 0; -- 积分
RespCrossPreArenaResultMsg.isFirst = 0; -- 是否第一名(0-不是，1-是)



RespCrossPreArenaResultMsg.meta = {__index = RespCrossPreArenaResultMsg};
function RespCrossPreArenaResultMsg:new()
	local obj = setmetatable( {}, RespCrossPreArenaResultMsg.meta);
	return obj;
end

function RespCrossPreArenaResultMsg:ParseData(pak)
	local idx = 1;

	self.score, idx = readInt(pak, idx);
	self.isFirst, idx = readByte(pak, idx);

end



--[[
服务器通知：跨服淘汰赛
]]

_G.RespCrossArenaInfoMsg = {};

RespCrossArenaInfoMsg.msgId = 8631;
RespCrossArenaInfoMsg.name = ""; -- 玩家名字
RespCrossArenaInfoMsg.prof = 0; -- 职业
RespCrossArenaInfoMsg.power = 0; -- 战斗力
RespCrossArenaInfoMsg.time = 0; -- 剩余时间S
RespCrossArenaInfoMsg.guwucnt = 0; -- 鼓舞次数



RespCrossArenaInfoMsg.meta = {__index = RespCrossArenaInfoMsg};
function RespCrossArenaInfoMsg:new()
	local obj = setmetatable( {}, RespCrossArenaInfoMsg.meta);
	return obj;
end

function RespCrossArenaInfoMsg:ParseData(pak)
	local idx = 1;

	self.name, idx = readString(pak, idx, 32);
	self.prof, idx = readInt(pak, idx);
	self.power, idx = readInt64(pak, idx);
	self.time, idx = readInt(pak, idx);
	self.guwucnt, idx = readInt(pak, idx);

end



--[[
服务器通知：跨服淘汰赛结果
]]

_G.RespCrossArenaResultMsg = {};

RespCrossArenaResultMsg.msgId = 8632;
RespCrossArenaResultMsg.rank = 0; -- 第几强
RespCrossArenaResultMsg.result = 0; -- 0=成功 -1=失败



RespCrossArenaResultMsg.meta = {__index = RespCrossArenaResultMsg};
function RespCrossArenaResultMsg:new()
	local obj = setmetatable( {}, RespCrossArenaResultMsg.meta);
	return obj;
end

function RespCrossArenaResultMsg:ParseData(pak)
	local idx = 1;

	self.rank, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
结婚典礼返回
]]

_G.ResMarryTypeMsg = {};

ResMarryTypeMsg.msgId = 8633;
ResMarryTypeMsg.result = 0; -- 返回婚礼类型选择，0成，-1钱不够，-2非组队 -3对方不在线 -4已选择结婚类型 -5双方不在同一地图内 -6没资格，-7只可队长操作, -8夫妻组队



ResMarryTypeMsg.meta = {__index = ResMarryTypeMsg};
function ResMarryTypeMsg:new()
	local obj = setmetatable( {}, ResMarryTypeMsg.meta);
	return obj;
end

function ResMarryTypeMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
结婚时间到，通知双方
]]

_G.ResMarryTimeStartMsg = {};

ResMarryTimeStartMsg.msgId = 8634;



ResMarryTimeStartMsg.meta = {__index = ResMarryTimeStartMsg};
function ResMarryTimeStartMsg:new()
	local obj = setmetatable( {}, ResMarryTimeStartMsg.meta);
	return obj;
end

function ResMarryTimeStartMsg:ParseData(pak)
	local idx = 1;


end



--[[
结婚时间到，通知双方
]]

_G.ResMarryTravelResMsg = {};

ResMarryTravelResMsg.msgId = 8635;
ResMarryTravelResMsg.result = 0; -- 是否可以巡游 0可以 -1不可以，2巡游完成 -3只可队长操作 -4未到巡游时间 -5巡游时间已过   -6不在同场景or不在同线



ResMarryTravelResMsg.meta = {__index = ResMarryTravelResMsg};
function ResMarryTravelResMsg:new()
	local obj = setmetatable( {}, ResMarryTravelResMsg.meta);
	return obj;
end

function ResMarryTravelResMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
进入结果
]]

_G.ResEnterMarryChurchMsg = {};

ResEnterMarryChurchMsg.msgId = 8636;
ResEnterMarryChurchMsg.result = 0; -- 进入结果 0成功 -1时间未到 -2时间过期，-3无资格，-4人数不足 -5还没有巡游，-6 由于玩家拒绝了结婚，本场婚礼被取消了 -7已在副本中 -8新人还没有进入副本 不准进入
ResEnterMarryChurchMsg.lineID = 0; -- 线路ID 自己进入-1



ResEnterMarryChurchMsg.meta = {__index = ResEnterMarryChurchMsg};
function ResEnterMarryChurchMsg:new()
	local obj = setmetatable( {}, ResEnterMarryChurchMsg.meta);
	return obj;
end

function ResEnterMarryChurchMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.lineID, idx = readInt(pak, idx);

end



--[[
退出结果
]]

_G.ResOutMarryCopyMsg = {};

ResOutMarryCopyMsg.msgId = 8637;
ResOutMarryCopyMsg.result = 0; -- 退出结果 0成功 -1不成功



ResOutMarryCopyMsg.meta = {__index = ResOutMarryCopyMsg};
function ResOutMarryCopyMsg:new()
	local obj = setmetatable( {}, ResOutMarryCopyMsg.meta);
	return obj;
end

function ResOutMarryCopyMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
婚礼结果
]]

_G.ResMarryMsg = {};

ResMarryMsg.msgId = 8638;
ResMarryMsg.result = 0; -- 是否结婚成功。0成功,-1配偶不在线。-2不满足组队条件 -3不在结婚时间 -4不在同一地图，-5只可队长操作 -6双方不在同一线路
ResMarryMsg.marryType = 0; -- 婚礼类型
ResMarryMsg.naprof = 0; -- 男职业
ResMarryMsg.nvprof = 0; -- 女职业



ResMarryMsg.meta = {__index = ResMarryMsg};
function ResMarryMsg:new()
	local obj = setmetatable( {}, ResMarryMsg.meta);
	return obj;
end

function ResMarryMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.marryType, idx = readInt(pak, idx);
	self.naprof, idx = readInt(pak, idx);
	self.nvprof, idx = readInt(pak, idx);

end



--[[
请柬列表
]]

_G.RespMarryCardListMsg = {};

RespMarryCardListMsg.msgId = 8639;
RespMarryCardListMsg.type = 0; -- 0全部，1单个，2更新
RespMarryCardListMsg.list_size = 0; -- 请柬list size
RespMarryCardListMsg.list = {}; -- 请柬list list



--[[
CardInfoVOVO = {
	itemId = ""; -- 道具cid
	state = 0; -- state请柬，0未到时间，-1失效，1可进入
	naroleName = ""; -- 男名字
	nvroleName = ""; -- 女名字
	naroleprof = 0; -- 男职业
	nvroleprof = 0; -- 女职业
	time = 0; -- 结婚时间戳
}
]]

RespMarryCardListMsg.meta = {__index = RespMarryCardListMsg};
function RespMarryCardListMsg:new()
	local obj = setmetatable( {}, RespMarryCardListMsg.meta);
	return obj;
end

function RespMarryCardListMsg:ParseData(pak)
	local idx = 1;

	self.type, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local CardInfoVOVo = {};
		CardInfoVOVo.itemId, idx = readGuid(pak, idx);
		CardInfoVOVo.state, idx = readInt64(pak, idx);
		CardInfoVOVo.naroleName, idx = readString(pak, idx, 32);
		CardInfoVOVo.nvroleName, idx = readString(pak, idx, 32);
		CardInfoVOVo.naroleprof, idx = readInt(pak, idx);
		CardInfoVOVo.nvroleprof, idx = readInt(pak, idx);
		CardInfoVOVo.time, idx = readInt64(pak, idx);
		table.push(list1,CardInfoVOVo);
	end

end



--[[
使用请帖前的data
]]

_G.RespMarryCardUseMyDataMsg = {};

RespMarryCardUseMyDataMsg.msgId = 8640;
RespMarryCardUseMyDataMsg.result = 0; -- 0成功，1状态更新-1不在结婚状态，-2数量不够
RespMarryCardUseMyDataMsg.naroleName = ""; -- 对方姓名
RespMarryCardUseMyDataMsg.time = 0; -- 结婚时间戳



RespMarryCardUseMyDataMsg.meta = {__index = RespMarryCardUseMyDataMsg};
function RespMarryCardUseMyDataMsg:new()
	local obj = setmetatable( {}, RespMarryCardUseMyDataMsg.meta);
	return obj;
end

function RespMarryCardUseMyDataMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.naroleName, idx = readString(pak, idx, 32);
	self.time, idx = readInt64(pak, idx);

end



--[[
请柬使用结果
]]

_G.ResMarryCardUseMsg = {};

ResMarryCardUseMsg.msgId = 8641;
ResMarryCardUseMsg.result = 0; -- 使用结果，0成功 -1没有资格



ResMarryCardUseMsg.meta = {__index = ResMarryCardUseMsg};
function ResMarryCardUseMsg:new()
	local obj = setmetatable( {}, ResMarryCardUseMsg.meta);
	return obj;
end

function ResMarryCardUseMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
清空婚礼状态
]]

_G.ResClaerMarryMsg = {};

ResClaerMarryMsg.msgId = 8642;
ResClaerMarryMsg.result = 0; -- 0成功清理婚礼状态，-1玩家退队导致强制停止



ResClaerMarryMsg.meta = {__index = ResClaerMarryMsg};
function ResClaerMarryMsg:new()
	local obj = setmetatable( {}, ResClaerMarryMsg.meta);
	return obj;
end

function ResClaerMarryMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
婚礼界面信息
]]

_G.ResMarryMainPanelInfoMsg = {};

ResMarryMainPanelInfoMsg.msgId = 8643;
ResMarryMainPanelInfoMsg.beRoleName = ""; -- 对方名字
ResMarryMainPanelInfoMsg.beUnionName = ""; -- 对方帮派名字
ResMarryMainPanelInfoMsg.beProf = 0; -- 对方职业
ResMarryMainPanelInfoMsg.lvl = 0; -- 对方等级
ResMarryMainPanelInfoMsg.fight = 0; -- 对方战斗力
ResMarryMainPanelInfoMsg.time = 0; -- 结婚时间
ResMarryMainPanelInfoMsg.MaxDay = 0; -- 携手天数
ResMarryMainPanelInfoMsg.intimate = 0; -- 亲密度
ResMarryMainPanelInfoMsg.cid = 0; -- 戒指id（123）
ResMarryMainPanelInfoMsg.marryType = 0; -- 婚礼类型
ResMarryMainPanelInfoMsg.ringLvl = 0; -- 戒指强化等级
ResMarryMainPanelInfoMsg.newVal = 0; -- 婚戒祝福值



ResMarryMainPanelInfoMsg.meta = {__index = ResMarryMainPanelInfoMsg};
function ResMarryMainPanelInfoMsg:new()
	local obj = setmetatable( {}, ResMarryMainPanelInfoMsg.meta);
	return obj;
end

function ResMarryMainPanelInfoMsg:ParseData(pak)
	local idx = 1;

	self.beRoleName, idx = readString(pak, idx, 32);
	self.beUnionName, idx = readString(pak, idx, 32);
	self.beProf, idx = readInt(pak, idx);
	self.lvl, idx = readInt(pak, idx);
	self.fight, idx = readInt(pak, idx);
	self.time, idx = readInt64(pak, idx);
	self.MaxDay, idx = readInt(pak, idx);
	self.intimate, idx = readInt(pak, idx);
	self.cid, idx = readInt(pak, idx);
	self.marryType, idx = readInt(pak, idx);
	self.ringLvl, idx = readInt(pak, idx);
	self.newVal, idx = readInt(pak, idx);

end



--[[
婚礼进行中的状态
]]

_G.ResMarryingStateMsg = {};

ResMarryingStateMsg.msgId = 8644;
ResMarryingStateMsg.marryState = 0; -- 婚姻状态 0单身 1订婚 2已婚 3离婚
ResMarryingStateMsg.marryType = 0; -- 婚礼类型
ResMarryingStateMsg.marryTime = 0; -- 婚礼时间
ResMarryingStateMsg.marrySchedule = 0; -- 是否巡游过 
ResMarryingStateMsg.marryDinner = 0; -- 是否开启过婚宴 



ResMarryingStateMsg.meta = {__index = ResMarryingStateMsg};
function ResMarryingStateMsg:new()
	local obj = setmetatable( {}, ResMarryingStateMsg.meta);
	return obj;
end

function ResMarryingStateMsg:ParseData(pak)
	local idx = 1;

	self.marryState, idx = readInt(pak, idx);
	self.marryType, idx = readInt(pak, idx);
	self.marryTime, idx = readInt64(pak, idx);
	self.marrySchedule, idx = readInt(pak, idx);
	self.marryDinner, idx = readInt(pak, idx);

end



--[[
服务器返回:生成附加属性卷轴
]]

_G.RespBuildAttrScrollMsg = {};

RespBuildAttrScrollMsg.msgId = 8645;
RespBuildAttrScrollMsg.result = 0; -- 0:成功



RespBuildAttrScrollMsg.meta = {__index = RespBuildAttrScrollMsg};
function RespBuildAttrScrollMsg:new()
	local obj = setmetatable( {}, RespBuildAttrScrollMsg.meta);
	return obj;
end

function RespBuildAttrScrollMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);

end



--[[
请求离婚返回
]]

_G.ResDivorceMsg = {};

ResDivorceMsg.msgId = 8646;
ResDivorceMsg.result = 0; -- 0成功 -1没钱,-2不符合组队条件，-3组队成员不对 -4没有配偶 -5配偶不在线。-6只可队长操作，-7协议离婚失败，由一方不同意 -8双方不在同一线路



ResDivorceMsg.meta = {__index = ResDivorceMsg};
function ResDivorceMsg:new()
	local obj = setmetatable( {}, ResDivorceMsg.meta);
	return obj;
end

function ResDivorceMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
队长开启婚礼仪式，双方弹出ui
]]

_G.ResMarryOpenMsg = {};

ResMarryOpenMsg.msgId = 8647;
ResMarryOpenMsg.result = 0; -- 是否结婚成功。0开启成功，-1不符合队伍条件 -2不是在结婚状态 -3配偶不在线 -4与配偶不在同一地图，-5只可队长操作
ResMarryOpenMsg.roleID = ""; -- 队友guid'



ResMarryOpenMsg.meta = {__index = ResMarryOpenMsg};
function ResMarryOpenMsg:new()
	local obj = setmetatable( {}, ResMarryOpenMsg.meta);
	return obj;
end

function ResMarryOpenMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.roleID, idx = readGuid(pak, idx);

end



--[[
更换戒指
]]

_G.ResMarryRingChangMsg = {};

ResMarryRingChangMsg.msgId = 8649;
ResMarryRingChangMsg.result = 0; -- 0成功 -1失败, -2婚姻状态不对



ResMarryRingChangMsg.meta = {__index = ResMarryRingChangMsg};
function ResMarryRingChangMsg:new()
	local obj = setmetatable( {}, ResMarryRingChangMsg.meta);
	return obj;
end

function ResMarryRingChangMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回美女直播状态
]]

_G.RespGirlTVStateMsg = {};

RespGirlTVStateMsg.msgId = 8650;
RespGirlTVStateMsg.state = 0; -- 0关闭,1开启



RespGirlTVStateMsg.meta = {__index = RespGirlTVStateMsg};
function RespGirlTVStateMsg:new()
	local obj = setmetatable( {}, RespGirlTVStateMsg.meta);
	return obj;
end

function RespGirlTVStateMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);

end



--[[
返回兵灵信息
]]

_G.ResBingLingInfoMsg = {};

ResBingLingInfoMsg.msgId = 8651;
ResBingLingInfoMsg.list_size = 0; -- 兵灵信息list size
ResBingLingInfoMsg.list = {}; -- 兵灵信息list list



--[[
listVO = {
	id = 0; -- 兵灵id
	progress = 0; -- 进阶进度
}
]]

ResBingLingInfoMsg.meta = {__index = ResBingLingInfoMsg};
function ResBingLingInfoMsg:new()
	local obj = setmetatable( {}, ResBingLingInfoMsg.meta);
	return obj;
end

function ResBingLingInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listVo = {};
		listVo.id, idx = readInt(pak, idx);
		listVo.progress, idx = readInt(pak, idx);
		table.push(list1,listVo);
	end

end



--[[
服务器返回：兵灵进阶
]]

_G.RespBingLingLevelUpMsg = {};

RespBingLingLevelUpMsg.msgId = 8652;
RespBingLingLevelUpMsg.result = 0; -- 请求进阶结果 0:成功(成功获得进度), 2:兵灵未解锁, 3:已达等级上限, 4:金币不够, 5:道具数量不足
RespBingLingLevelUpMsg.id = 0; -- 兵灵id
RespBingLingLevelUpMsg.progress = 0; -- 进阶后的进度



RespBingLingLevelUpMsg.meta = {__index = RespBingLingLevelUpMsg};
function RespBingLingLevelUpMsg:new()
	local obj = setmetatable( {}, RespBingLingLevelUpMsg.meta);
	return obj;
end

function RespBingLingLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.id, idx = readInt(pak, idx);
	self.progress, idx = readInt(pak, idx);

end



--[[
服务器返回：神武信息上线推
]]

_G.RespShenWuInfoMsg = {};

RespShenWuInfoMsg.msgId = 8653;
RespShenWuInfoMsg.level = 0; -- 神武等阶
RespShenWuInfoMsg.star = 0; -- 神武星级
RespShenWuInfoMsg.stoneNum = 0; -- 已使用成功石数量
RespShenWuInfoMsg.rate = 0; -- 升星成功率



RespShenWuInfoMsg.meta = {__index = RespShenWuInfoMsg};
function RespShenWuInfoMsg:new()
	local obj = setmetatable( {}, RespShenWuInfoMsg.meta);
	return obj;
end

function RespShenWuInfoMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);
	self.star, idx = readInt(pak, idx);
	self.stoneNum, idx = readInt(pak, idx);
	self.rate, idx = readInt(pak, idx);

end



--[[
服务器返回：神武升星
]]

_G.RespShenWuStarUpMsg = {};

RespShenWuStarUpMsg.msgId = 8654;
RespShenWuStarUpMsg.result = 0; -- 结果 0:成功, 1:功能未开启 2:道具数量不足, 3:已达等级上限, 4: , 5:概率失败 
RespShenWuStarUpMsg.star = 0; -- 神武星级
RespShenWuStarUpMsg.rate = 0; -- 升星成功率



RespShenWuStarUpMsg.meta = {__index = RespShenWuStarUpMsg};
function RespShenWuStarUpMsg:new()
	local obj = setmetatable( {}, RespShenWuStarUpMsg.meta);
	return obj;
end

function RespShenWuStarUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.star, idx = readInt(pak, idx);
	self.rate, idx = readInt(pak, idx);

end



--[[
服务器返回：神武激活/进阶
]]

_G.RespShenWuLevelUpMsg = {};

RespShenWuLevelUpMsg.msgId = 8655;
RespShenWuLevelUpMsg.result = 0; -- 结果 0:成功, 1:掉星, 2:道具数量不足, 3:已达等级上限, 4:星不够 , 5: 
RespShenWuLevelUpMsg.level = 0; -- 神武等阶
RespShenWuLevelUpMsg.star = 0; -- 神武星级
RespShenWuLevelUpMsg.stoneNum = 0; -- 已使用成功石数量



RespShenWuLevelUpMsg.meta = {__index = RespShenWuLevelUpMsg};
function RespShenWuLevelUpMsg:new()
	local obj = setmetatable( {}, RespShenWuLevelUpMsg.meta);
	return obj;
end

function RespShenWuLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.level, idx = readInt(pak, idx);
	self.star, idx = readInt(pak, idx);
	self.stoneNum, idx = readInt(pak, idx);

end



--[[
赠送红包返回
]]

_G.ResGiveRedPacketMsg = {};

ResGiveRedPacketMsg.msgId = 8656;
ResGiveRedPacketMsg.result = 0; -- 0成功，-1银两不足 -2夫妻双方都不在线



ResGiveRedPacketMsg.meta = {__index = ResGiveRedPacketMsg};
function ResGiveRedPacketMsg:new()
	local obj = setmetatable( {}, ResGiveRedPacketMsg.meta);
	return obj;
end

function ResGiveRedPacketMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
视野设置到跟随物的目标
]]

_G.ResSetFollowerGuidMsg = {};

ResSetFollowerGuidMsg.msgId = 8657;
ResSetFollowerGuidMsg.roleID = ""; -- 跟随物的guid'



ResSetFollowerGuidMsg.meta = {__index = ResSetFollowerGuidMsg};
function ResSetFollowerGuidMsg:new()
	local obj = setmetatable( {}, ResSetFollowerGuidMsg.meta);
	return obj;
end

function ResSetFollowerGuidMsg:ParseData(pak)
	local idx = 1;

	self.roleID, idx = readGuid(pak, idx);

end



--[[
发送结婚宝箱返回结果
]]

_G.ResSendMarryBoxMsg = {};

ResSendMarryBoxMsg.msgId = 8658;
ResSendMarryBoxMsg.result = 0; -- 0成功，1失败，2cd未到



ResSendMarryBoxMsg.meta = {__index = ResSendMarryBoxMsg};
function ResSendMarryBoxMsg:new()
	local obj = setmetatable( {}, ResSendMarryBoxMsg.meta);
	return obj;
end

function ResSendMarryBoxMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器通知:元灵信息
]]

_G.RespYuanLingInfoMsg = {};

RespYuanLingInfoMsg.msgId = 8659;
RespYuanLingInfoMsg.level = 0; -- 元灵等阶
RespYuanLingInfoMsg.selectlevel = 0; -- 当前使用的元灵等阶
RespYuanLingInfoMsg.progress = 0; -- 进阶进度
RespYuanLingInfoMsg.pillNum = 0; -- 属性丹数量



RespYuanLingInfoMsg.meta = {__index = RespYuanLingInfoMsg};
function RespYuanLingInfoMsg:new()
	local obj = setmetatable( {}, RespYuanLingInfoMsg.meta);
	return obj;
end

function RespYuanLingInfoMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);
	self.selectlevel, idx = readInt(pak, idx);
	self.progress, idx = readInt(pak, idx);
	self.pillNum, idx = readInt(pak, idx);

end



--[[
服务器返回：元灵进阶
]]

_G.RespYuanLingLevelUpMsg = {};

RespYuanLingLevelUpMsg.msgId = 8660;
RespYuanLingLevelUpMsg.result = 0; -- 请求进阶结果 0:成功(成功获得祝福值), 2:元灵未解锁, 3:已达等级上限, 4:金币不够, 5:道具数量不足
RespYuanLingLevelUpMsg.progress = 0; -- 进阶后的进度



RespYuanLingLevelUpMsg.meta = {__index = RespYuanLingLevelUpMsg};
function RespYuanLingLevelUpMsg:new()
	local obj = setmetatable( {}, RespYuanLingLevelUpMsg.meta);
	return obj;
end

function RespYuanLingLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.progress, idx = readInt(pak, idx);

end



--[[
激活元灵返回结果
]]

_G.RespActiveYuanLingResultMsg = {};

RespActiveYuanLingResultMsg.msgId = 8661;
RespActiveYuanLingResultMsg.result = 0; -- 0=成功 1=失败



RespActiveYuanLingResultMsg.meta = {__index = RespActiveYuanLingResultMsg};
function RespActiveYuanLingResultMsg:new()
	local obj = setmetatable( {}, RespActiveYuanLingResultMsg.meta);
	return obj;
end

function RespActiveYuanLingResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
切换元灵返回结果
]]

_G.RespChangeYuanLingResultMsg = {};

RespChangeYuanLingResultMsg.msgId = 8662;
RespChangeYuanLingResultMsg.result = 0; -- 0=成功 1=失败
RespChangeYuanLingResultMsg.yuanlingId = 0; -- 元灵Id



RespChangeYuanLingResultMsg.meta = {__index = RespChangeYuanLingResultMsg};
function RespChangeYuanLingResultMsg:new()
	local obj = setmetatable( {}, RespChangeYuanLingResultMsg.meta);
	return obj;
end

function RespChangeYuanLingResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.yuanlingId, idx = readInt(pak, idx);

end



--[[
队长发起协议离婚
]]

_G.ResDivorceXieYiMsg = {};

ResDivorceXieYiMsg.msgId = 8663;



ResDivorceXieYiMsg.meta = {__index = ResDivorceXieYiMsg};
function ResDivorceXieYiMsg:new()
	local obj = setmetatable( {}, ResDivorceXieYiMsg.meta);
	return obj;
end

function ResDivorceXieYiMsg:ParseData(pak)
	local idx = 1;


end



--[[
境界巩固重返回结果
]]

_G.ResStrenthenChongMsg = {};

ResStrenthenChongMsg.msgId = 8664;
ResStrenthenChongMsg.result = 0; -- 0成功，1失败
ResStrenthenChongMsg.chongId = 0; -- 巩固重Id
ResStrenthenChongMsg.progress = 0; -- 巩固重进度



ResStrenthenChongMsg.meta = {__index = ResStrenthenChongMsg};
function ResStrenthenChongMsg:new()
	local obj = setmetatable( {}, ResStrenthenChongMsg.meta);
	return obj;
end

function ResStrenthenChongMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.chongId, idx = readInt(pak, idx);
	self.progress, idx = readInt(pak, idx);

end



--[[
巩固重突破返回结果
]]

_G.ResStrenthenBreakResultMsg = {};

ResStrenthenBreakResultMsg.msgId = 8665;
ResStrenthenBreakResultMsg.result = 0; -- 0成功，1失败
ResStrenthenBreakResultMsg.chongId = 0; -- 境界重Id
ResStrenthenBreakResultMsg.progress = 0; -- 境界重进度



ResStrenthenBreakResultMsg.meta = {__index = ResStrenthenBreakResultMsg};
function ResStrenthenBreakResultMsg:new()
	local obj = setmetatable( {}, ResStrenthenBreakResultMsg.meta);
	return obj;
end

function ResStrenthenBreakResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.chongId, idx = readInt(pak, idx);
	self.progress, idx = readInt(pak, idx);

end



--[[
境界切换返回结果
]]

_G.ResChangeRealmModelMsg = {};

ResChangeRealmModelMsg.msgId = 8666;
ResChangeRealmModelMsg.result = 0; -- 0成功，1失败
ResChangeRealmModelMsg.id = 0; -- 大于100境界重，小于100境界等阶



ResChangeRealmModelMsg.meta = {__index = ResChangeRealmModelMsg};
function ResChangeRealmModelMsg:new()
	local obj = setmetatable( {}, ResChangeRealmModelMsg.meta);
	return obj;
end

function ResChangeRealmModelMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
服务器返回：圣灵镶嵌信息
]]

_G.RespBackHallowsMsg = {};

RespBackHallowsMsg.msgId = 8667;
RespBackHallowsMsg.hallowslist_size = 0; -- 圣灵信息list size
RespBackHallowsMsg.hallowslist = {}; -- 圣灵信息list list



--[[
hallowsVOVO = {
	id = 0; -- 圣灵id
	holenum = 0; -- 开启格子数量
	sortlist_size = 7; -- 镶嵌信息list size
	sortlist = {}; -- 镶嵌信息list list
}
sortVOVO = {
	index = 0; -- 镶嵌位置
	id = 0; -- 镶嵌物品ID
}
]]

RespBackHallowsMsg.meta = {__index = RespBackHallowsMsg};
function RespBackHallowsMsg:new()
	local obj = setmetatable( {}, RespBackHallowsMsg.meta);
	return obj;
end

function RespBackHallowsMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.hallowslist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local hallowsVOVo = {};
		hallowsVOVo.id, idx = readInt(pak, idx);
		hallowsVOVo.holenum, idx = readInt(pak, idx);
		table.push(list1,hallowsVOVo);

		local list2 = {};
		hallowsVOVo.sortlist = list2;
		local list2Size = 7;

		for i=1,list2Size do
			local sortVOVo = {};
			sortVOVo.index, idx = readInt(pak, idx);
			sortVOVo.id, idx = readInt(pak, idx);
			table.push(list2,sortVOVo);
		end
	end

end



--[[
圣灵镶嵌返回
]]

_G.ResInlayHallowsResultMsg = {};

ResInlayHallowsResultMsg.msgId = 8668;
ResInlayHallowsResultMsg.result = 0; -- 0成功 -1:冰魂不存在 -2:物品不存在 -3:格子满



ResInlayHallowsResultMsg.meta = {__index = ResInlayHallowsResultMsg};
function ResInlayHallowsResultMsg:new()
	local obj = setmetatable( {}, ResInlayHallowsResultMsg.meta);
	return obj;
end

function ResInlayHallowsResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
圣灵剥离返回
]]

_G.ResPeelHallowsResultMsg = {};

ResPeelHallowsResultMsg.msgId = 8669;
ResPeelHallowsResultMsg.result = 0; -- 0成功 -1:冰魂不存在 -2:格子错误 -3:背包满



ResPeelHallowsResultMsg.meta = {__index = ResPeelHallowsResultMsg};
function ResPeelHallowsResultMsg:new()
	local obj = setmetatable( {}, ResPeelHallowsResultMsg.meta);
	return obj;
end

function ResPeelHallowsResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
当前元灵盾数量
]]

_G.RespYuanLingDunNumMsg = {};

RespYuanLingDunNumMsg.msgId = 8670;
RespYuanLingDunNumMsg.num = 0; -- 当前元灵盾数量



RespYuanLingDunNumMsg.meta = {__index = RespYuanLingDunNumMsg};
function RespYuanLingDunNumMsg:new()
	local obj = setmetatable( {}, RespYuanLingDunNumMsg.meta);
	return obj;
end

function RespYuanLingDunNumMsg:ParseData(pak)
	local idx = 1;

	self.num, idx = readInt(pak, idx);

end



--[[
返回开启元灵盾
]]

_G.RespYuanLingDunMsg = {};

RespYuanLingDunMsg.msgId = 8671;
RespYuanLingDunMsg.state = 0; -- 状态0关1开
RespYuanLingDunMsg.result = 0; -- 默认0



RespYuanLingDunMsg.meta = {__index = RespYuanLingDunMsg};
function RespYuanLingDunMsg:new()
	local obj = setmetatable( {}, RespYuanLingDunMsg.meta);
	return obj;
end

function RespYuanLingDunMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);
	self.result, idx = readInt(pak, idx);

end



--[[
返回改名
]]

_G.RespChangePlayerNameMsg = {};

RespChangePlayerNameMsg.msgId = 8672;
RespChangePlayerNameMsg.result = 0; -- 默认0
RespChangePlayerNameMsg.roleName = ""; -- 角色名字



RespChangePlayerNameMsg.meta = {__index = RespChangePlayerNameMsg};
function RespChangePlayerNameMsg:new()
	local obj = setmetatable( {}, RespChangePlayerNameMsg.meta);
	return obj;
end

function RespChangePlayerNameMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.roleName, idx = readString(pak, idx, 32);

end



--[[
返回天命轮盘历史获得属性(上线发)
]]

_G.RespLunPanAttrMsg = {};

RespLunPanAttrMsg.msgId = 8673;
RespLunPanAttrMsg.used = 0; -- 今日已用次数
RespLunPanAttrMsg.list_size = 0; -- 天命轮盘历史数据 size
RespLunPanAttrMsg.list = {}; -- 天命轮盘历史数据 list



--[[
listVO = {
	tid = 0; -- 天命轮盘表id
	num = 0; -- 历史抽中次数(含单倍、双倍)
	num2 = 0; -- 历史翻倍次数(含双倍)
}
]]

RespLunPanAttrMsg.meta = {__index = RespLunPanAttrMsg};
function RespLunPanAttrMsg:new()
	local obj = setmetatable( {}, RespLunPanAttrMsg.meta);
	return obj;
end

function RespLunPanAttrMsg:ParseData(pak)
	local idx = 1;

	self.used, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listVo = {};
		listVo.tid, idx = readInt(pak, idx);
		listVo.num, idx = readInt(pak, idx);
		listVo.num2, idx = readInt(pak, idx);
		table.push(list1,listVo);
	end

end



--[[
返回轮盘抽取
]]

_G.RespLunPanRollMsg = {};

RespLunPanRollMsg.msgId = 8674;
RespLunPanRollMsg.result = 0; -- 0-成功 1-灵力不足
RespLunPanRollMsg.tid = 0; -- 天命轮盘表id
RespLunPanRollMsg.num = 0; -- 1:单倍 2:双倍
RespLunPanRollMsg.used = 0; -- 今日已用次数



RespLunPanRollMsg.meta = {__index = RespLunPanRollMsg};
function RespLunPanRollMsg:new()
	local obj = setmetatable( {}, RespLunPanRollMsg.meta);
	return obj;
end

function RespLunPanRollMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.tid, idx = readInt(pak, idx);
	self.num, idx = readInt(pak, idx);
	self.used, idx = readInt(pak, idx);

end



--[[
返回轮盘一键10次抽取
]]

_G.RespLunPanSuperRollMsg = {};

RespLunPanSuperRollMsg.msgId = 8675;
RespLunPanSuperRollMsg.result = 0; -- 0-成功 1-灵力不足
RespLunPanSuperRollMsg.used = 0; -- 今日已用次数
RespLunPanSuperRollMsg.list_size = 10; -- 抽取结果 size
RespLunPanSuperRollMsg.list = {}; -- 抽取结果 list



--[[
listVO = {
	tid = 0; -- 天命轮盘表id
	num = 0; -- 1:单倍 2:双倍
}
]]

RespLunPanSuperRollMsg.meta = {__index = RespLunPanSuperRollMsg};
function RespLunPanSuperRollMsg:new()
	local obj = setmetatable( {}, RespLunPanSuperRollMsg.meta);
	return obj;
end

function RespLunPanSuperRollMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.used, idx = readInt(pak, idx);

	local list1 = {};
	self.list = list1;
	local list1Size = 10;

	for i=1,list1Size do
		local listVo = {};
		listVo.tid, idx = readInt(pak, idx);
		listVo.num, idx = readInt(pak, idx);
		table.push(list1,listVo);
	end

end



--[[
婚宴开启
]]

_G.ResMarryEatStartMsg = {};

ResMarryEatStartMsg.msgId = 8676;
ResMarryEatStartMsg.time = 0; -- 剩余时间



ResMarryEatStartMsg.meta = {__index = ResMarryEatStartMsg};
function ResMarryEatStartMsg:new()
	local obj = setmetatable( {}, ResMarryEatStartMsg.meta);
	return obj;
end

function ResMarryEatStartMsg:ParseData(pak)
	local idx = 1;

	self.time, idx = readInt(pak, idx);

end



--[[
服务器通知:五行灵脉信息
]]

_G.RespWuxinglingmaiInfoMsg = {};

RespWuxinglingmaiInfoMsg.msgId = 8677;
RespWuxinglingmaiInfoMsg.level = 0; -- 五行灵脉等阶
RespWuxinglingmaiInfoMsg.progress = 0; -- 进阶进度
RespWuxinglingmaiInfoMsg.pillNum = 0; -- 属性丹数量



RespWuxinglingmaiInfoMsg.meta = {__index = RespWuxinglingmaiInfoMsg};
function RespWuxinglingmaiInfoMsg:new()
	local obj = setmetatable( {}, RespWuxinglingmaiInfoMsg.meta);
	return obj;
end

function RespWuxinglingmaiInfoMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);
	self.progress, idx = readInt(pak, idx);
	self.pillNum, idx = readInt(pak, idx);

end



--[[
服务器返回：五行灵脉进阶
]]

_G.RespWuxinglingmaiLevelUpMsg = {};

RespWuxinglingmaiLevelUpMsg.msgId = 8678;
RespWuxinglingmaiLevelUpMsg.result = 0; -- 请求进阶结果 0:成功(成功获得祝福值), 2:五行灵脉未解锁, 3:已达等级上限, 4:金币不够, 5:道具数量不足
RespWuxinglingmaiLevelUpMsg.progress = 0; -- 进阶后的进度



RespWuxinglingmaiLevelUpMsg.meta = {__index = RespWuxinglingmaiLevelUpMsg};
function RespWuxinglingmaiLevelUpMsg:new()
	local obj = setmetatable( {}, RespWuxinglingmaiLevelUpMsg.meta);
	return obj;
end

function RespWuxinglingmaiLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.progress, idx = readInt(pak, idx);

end



--[[
激活五行灵脉返回结果
]]

_G.RespActiveWuxinglingmaiResultMsg = {};

RespActiveWuxinglingmaiResultMsg.msgId = 8679;
RespActiveWuxinglingmaiResultMsg.result = 0; -- 0=成功 1=失败



RespActiveWuxinglingmaiResultMsg.meta = {__index = RespActiveWuxinglingmaiResultMsg};
function RespActiveWuxinglingmaiResultMsg:new()
	local obj = setmetatable( {}, RespActiveWuxinglingmaiResultMsg.meta);
	return obj;
end

function RespActiveWuxinglingmaiResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回:五行灵脉列表
]]

_G.RespWuxinglingmaiItemMsg = {};

RespWuxinglingmaiItemMsg.msgId = 8680;
RespWuxinglingmaiItemMsg.list_size = 0; -- 装备五行灵脉 size
RespWuxinglingmaiItemMsg.list = {}; -- 装备五行灵脉 list



--[[
baglistVO = {
	id = ""; -- 唯一ID
	tid = 0; -- 表id
	pos = 0; -- 位置
	bagType = 0; -- 背包类型1=着装，2=背包
	attrlist_size = 5; -- 属性列表list size
	attrlist = {}; -- 属性列表list list
}
attrVoVO = {
	val = 0; -- 属性值
	type = 0; -- 属性类型
}
]]

RespWuxinglingmaiItemMsg.meta = {__index = RespWuxinglingmaiItemMsg};
function RespWuxinglingmaiItemMsg:new()
	local obj = setmetatable( {}, RespWuxinglingmaiItemMsg.meta);
	return obj;
end

function RespWuxinglingmaiItemMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local baglistVo = {};
		baglistVo.id, idx = readGuid(pak, idx);
		baglistVo.tid, idx = readInt(pak, idx);
		baglistVo.pos, idx = readInt(pak, idx);
		baglistVo.bagType, idx = readInt(pak, idx);
		table.push(list1,baglistVo);

		local list = {};
		baglistVo.attrlist = list;
		local listSize = 5;

		for i=1,listSize do
			local attrVoVo = {};
			attrVoVo.val, idx = readInt(pak, idx);
			attrVoVo.type, idx = readByte(pak, idx);
			table.push(list,attrVoVo);
		end
	end

end



--[[
添加五行灵脉
]]

_G.RespWuxinglingmaiItemAddMsg = {};

RespWuxinglingmaiItemAddMsg.msgId = 8681;
RespWuxinglingmaiItemAddMsg.id = ""; -- 唯一ID
RespWuxinglingmaiItemAddMsg.tid = 0; -- 表id
RespWuxinglingmaiItemAddMsg.pos = 0; -- 位置
RespWuxinglingmaiItemAddMsg.bagType = 0; -- 背包类型1=着装，2=背包
RespWuxinglingmaiItemAddMsg.attrlist_size = 5; -- 属性列表list size
RespWuxinglingmaiItemAddMsg.attrlist = {}; -- 属性列表list list



--[[
attrVoVO = {
	val = 0; -- 属性值
	type = 0; -- 属性类型
}
]]

RespWuxinglingmaiItemAddMsg.meta = {__index = RespWuxinglingmaiItemAddMsg};
function RespWuxinglingmaiItemAddMsg:new()
	local obj = setmetatable( {}, RespWuxinglingmaiItemAddMsg.meta);
	return obj;
end

function RespWuxinglingmaiItemAddMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.tid, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);
	self.bagType, idx = readInt(pak, idx);

	local list = {};
	self.attrlist = list;
	local listSize = 5;

	for i=1,listSize do
		local attrVoVo = {};
		attrVoVo.val, idx = readInt(pak, idx);
		attrVoVo.type, idx = readByte(pak, idx);
		table.push(list,attrVoVo);
	end

end



--[[
更新五行灵脉
]]

_G.RespWuxinglingmaiItemUpdataMsg = {};

RespWuxinglingmaiItemUpdataMsg.msgId = 8682;
RespWuxinglingmaiItemUpdataMsg.id = ""; -- 唯一ID
RespWuxinglingmaiItemUpdataMsg.tid = 0; -- 表id
RespWuxinglingmaiItemUpdataMsg.pos = 0; -- 位置
RespWuxinglingmaiItemUpdataMsg.bagType = 0; -- 背包类型1=着装，2=背包



RespWuxinglingmaiItemUpdataMsg.meta = {__index = RespWuxinglingmaiItemUpdataMsg};
function RespWuxinglingmaiItemUpdataMsg:new()
	local obj = setmetatable( {}, RespWuxinglingmaiItemUpdataMsg.meta);
	return obj;
end

function RespWuxinglingmaiItemUpdataMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.tid, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);
	self.bagType, idx = readInt(pak, idx);

end



--[[
删除五行灵脉
]]

_G.RespWuxinglingmaiItemRemoveMsg = {};

RespWuxinglingmaiItemRemoveMsg.msgId = 8683;
RespWuxinglingmaiItemRemoveMsg.pos = 0; -- 位置
RespWuxinglingmaiItemRemoveMsg.bagType = 0; -- 背包类型1=着装，2=背包



RespWuxinglingmaiItemRemoveMsg.meta = {__index = RespWuxinglingmaiItemRemoveMsg};
function RespWuxinglingmaiItemRemoveMsg:new()
	local obj = setmetatable( {}, RespWuxinglingmaiItemRemoveMsg.meta);
	return obj;
end

function RespWuxinglingmaiItemRemoveMsg:ParseData(pak)
	local idx = 1;

	self.pos, idx = readInt(pak, idx);
	self.bagType, idx = readInt(pak, idx);

end



--[[
服务端通知: 交换物品反馈
]]

_G.RespWuxinglingmaiItemSwapResultMsg = {};

RespWuxinglingmaiItemSwapResultMsg.msgId = 8684;
RespWuxinglingmaiItemSwapResultMsg.result = 0; -- 结果  0:成功
RespWuxinglingmaiItemSwapResultMsg.src_bag = 0; -- 源背包
RespWuxinglingmaiItemSwapResultMsg.dst_bag = 0; -- 目标背包
RespWuxinglingmaiItemSwapResultMsg.src_idx = 0; -- 源格子
RespWuxinglingmaiItemSwapResultMsg.dst_idx = 0; -- 目标格子



RespWuxinglingmaiItemSwapResultMsg.meta = {__index = RespWuxinglingmaiItemSwapResultMsg};
function RespWuxinglingmaiItemSwapResultMsg:new()
	local obj = setmetatable( {}, RespWuxinglingmaiItemSwapResultMsg.meta);
	return obj;
end

function RespWuxinglingmaiItemSwapResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.src_bag, idx = readInt(pak, idx);
	self.dst_bag, idx = readInt(pak, idx);
	self.src_idx, idx = readInt(pak, idx);
	self.dst_idx, idx = readInt(pak, idx);

end



--[[
合成五行灵脉返回结果
]]

_G.RespHechengWuxinglingmaiResultMsg = {};

RespHechengWuxinglingmaiResultMsg.msgId = 8685;
RespHechengWuxinglingmaiResultMsg.result = 0; -- 0=成功 1=失败



RespHechengWuxinglingmaiResultMsg.meta = {__index = RespHechengWuxinglingmaiResultMsg};
function RespHechengWuxinglingmaiResultMsg:new()
	local obj = setmetatable( {}, RespHechengWuxinglingmaiResultMsg.meta);
	return obj;
end

function RespHechengWuxinglingmaiResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
套装激活
]]

_G.ResEquipGroupActiInfoMsg = {};

ResEquipGroupActiInfoMsg.msgId = 8686;
ResEquipGroupActiInfoMsg.list_size = 0; -- 抽取结果 size
ResEquipGroupActiInfoMsg.list = {}; -- 抽取结果 list



--[[
listVO = {
	pos = 0; -- 装备位
	index = 0; -- 套装位
	lvl = 0; -- 等级：小于0未镶嵌
}
]]

ResEquipGroupActiInfoMsg.meta = {__index = ResEquipGroupActiInfoMsg};
function ResEquipGroupActiInfoMsg:new()
	local obj = setmetatable( {}, ResEquipGroupActiInfoMsg.meta);
	return obj;
end

function ResEquipGroupActiInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listVo = {};
		listVo.pos, idx = readInt(pak, idx);
		listVo.index, idx = readInt(pak, idx);
		listVo.lvl, idx = readInt(pak, idx);
		table.push(list1,listVo);
	end

end



--[[
开启套装孔结果
]]

_G.RespEquipGroupOpenPosMsg = {};

RespEquipGroupOpenPosMsg.msgId = 8687;
RespEquipGroupOpenPosMsg.result = 0; -- 0-成功 1-道具不足，-2不可开启，-3已打可开启上限
RespEquipGroupOpenPosMsg.pos = 0; -- 装备位
RespEquipGroupOpenPosMsg.index = 0; -- 套装位



RespEquipGroupOpenPosMsg.meta = {__index = RespEquipGroupOpenPosMsg};
function RespEquipGroupOpenPosMsg:new()
	local obj = setmetatable( {}, RespEquipGroupOpenPosMsg.meta);
	return obj;
end

function RespEquipGroupOpenPosMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);
	self.index, idx = readInt(pak, idx);

end



--[[
设置套装id
]]

_G.RespEquipGroupOpenSetMsg = {};

RespEquipGroupOpenSetMsg.msgId = 8688;
RespEquipGroupOpenSetMsg.result = 0; -- 0-成功 1-道具不足，-2不可开启
RespEquipGroupOpenSetMsg.pos = 0; -- 装备位
RespEquipGroupOpenSetMsg.index = 0; -- 套装位



RespEquipGroupOpenSetMsg.meta = {__index = RespEquipGroupOpenSetMsg};
function RespEquipGroupOpenSetMsg:new()
	local obj = setmetatable( {}, RespEquipGroupOpenSetMsg.meta);
	return obj;
end

function RespEquipGroupOpenSetMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);
	self.index, idx = readInt(pak, idx);

end



--[[
升级套装
]]

_G.RespEquipGroupUpLvlMsg = {};

RespEquipGroupUpLvlMsg.msgId = 8689;
RespEquipGroupUpLvlMsg.result = 0; -- 0-成功 1-道具不足，-2不可开启
RespEquipGroupUpLvlMsg.pos = 0; -- 装备位
RespEquipGroupUpLvlMsg.index = 0; -- 套装位
RespEquipGroupUpLvlMsg.lvl = 0; -- 等级



RespEquipGroupUpLvlMsg.meta = {__index = RespEquipGroupUpLvlMsg};
function RespEquipGroupUpLvlMsg:new()
	local obj = setmetatable( {}, RespEquipGroupUpLvlMsg.meta);
	return obj;
end

function RespEquipGroupUpLvlMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);
	self.index, idx = readInt(pak, idx);
	self.lvl, idx = readInt(pak, idx);

end



--[[
返回挑战副本date
]]

_G.RespBackDekaronDungeonDateMsg = {};

RespBackDekaronDungeonDateMsg.msgId = 8690;
RespBackDekaronDungeonDateMsg.enterNum = 0; -- 今日进入次数 (已进入)
RespBackDekaronDungeonDateMsg.nowBestLayer = 0; -- 今日挑战的最好成绩
RespBackDekaronDungeonDateMsg.bestLayer = 0; -- 自己历史最好成绩
RespBackDekaronDungeonDateMsg.bestTeamLayer = 0; -- 全服历史最好成绩
RespBackDekaronDungeonDateMsg.bestTeamList_size = 4; -- 最强通关队伍列表 size
RespBackDekaronDungeonDateMsg.bestTeamList = {}; -- 最强通关队伍列表 list
RespBackDekaronDungeonDateMsg.rankList_size = 10; -- 排行榜列表 size
RespBackDekaronDungeonDateMsg.rankList = {}; -- 排行榜列表 list



--[[
bestTeamVOVO = {
	name = ""; -- 玩家名称
	cap = 0; -- 对战 0：是
}
]]
--[[
rankVOVO = {
	rankIndex = 0; -- 名次
	name = ""; -- 人物名称
	layer = 0; -- 通关层数
}
]]

RespBackDekaronDungeonDateMsg.meta = {__index = RespBackDekaronDungeonDateMsg};
function RespBackDekaronDungeonDateMsg:new()
	local obj = setmetatable( {}, RespBackDekaronDungeonDateMsg.meta);
	return obj;
end

function RespBackDekaronDungeonDateMsg:ParseData(pak)
	local idx = 1;

	self.enterNum, idx = readInt(pak, idx);
	self.nowBestLayer, idx = readInt(pak, idx);
	self.bestLayer, idx = readInt(pak, idx);
	self.bestTeamLayer, idx = readInt(pak, idx);

	local list1 = {};
	self.bestTeamList = list1;
	local list1Size = 4;

	for i=1,list1Size do
		local bestTeamVOVo = {};
		bestTeamVOVo.name, idx = readString(pak, idx, 32);
		bestTeamVOVo.cap, idx = readInt(pak, idx);
		table.push(list1,bestTeamVOVo);
	end

	local list2 = {};
	self.rankList = list2;
	local list2Size = 10;

	for i=1,list2Size do
		local rankVOVo = {};
		rankVOVo.rankIndex, idx = readInt(pak, idx);
		rankVOVo.name, idx = readString(pak, idx, 32);
		rankVOVo.layer, idx = readInt(pak, idx);
		table.push(list2,rankVOVo);
	end

end



--[[
返回挑战副本进入结果
]]

_G.RespBackDekaronDungeonEnterMsg = {};

RespBackDekaronDungeonEnterMsg.msgId = 8691;
RespBackDekaronDungeonEnterMsg.result = 0; -- 进入结果 0成功 错误码  1不是队长 2等级不足 3 次数不足 4 队友次数不足 5队长不在线 6队长功能未开启 7队友功能未开启 8 正在活动中
RespBackDekaronDungeonEnterMsg.layer = 0; -- 进入层
RespBackDekaronDungeonEnterMsg.state = 0; -- 挑战状态 0未挑战 1以挑战



RespBackDekaronDungeonEnterMsg.meta = {__index = RespBackDekaronDungeonEnterMsg};
function RespBackDekaronDungeonEnterMsg:new()
	local obj = setmetatable( {}, RespBackDekaronDungeonEnterMsg.meta);
	return obj;
end

function RespBackDekaronDungeonEnterMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.layer, idx = readInt(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
返回挑战副本挑战过程
]]

_G.RespBackDekaronDungeonInfoMsg = {};

RespBackDekaronDungeonInfoMsg.msgId = 8692;
RespBackDekaronDungeonInfoMsg.killList_size = 0; -- 击杀怪物列表 size
RespBackDekaronDungeonInfoMsg.killList = {}; -- 击杀怪物列表 list



--[[
monsterVOVO = {
	monsterId = 0; -- 击杀怪物ID
	monsterNum = 0; -- 击杀怪物数量
}
]]

RespBackDekaronDungeonInfoMsg.meta = {__index = RespBackDekaronDungeonInfoMsg};
function RespBackDekaronDungeonInfoMsg:new()
	local obj = setmetatable( {}, RespBackDekaronDungeonInfoMsg.meta);
	return obj;
end

function RespBackDekaronDungeonInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.killList = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local monsterVOVo = {};
		monsterVOVo.monsterId, idx = readInt(pak, idx);
		monsterVOVo.monsterNum, idx = readInt(pak, idx);
		table.push(list1,monsterVOVo);
	end

end



--[[
返回挑战副本通关结果
]]

_G.RespBackDekaronDungeonResultMsg = {};

RespBackDekaronDungeonResultMsg.msgId = 8693;
RespBackDekaronDungeonResultMsg.result = 0; -- 通关结果 0成功
RespBackDekaronDungeonResultMsg.layer = 0; -- 通关层数



RespBackDekaronDungeonResultMsg.meta = {__index = RespBackDekaronDungeonResultMsg};
function RespBackDekaronDungeonResultMsg:new()
	local obj = setmetatable( {}, RespBackDekaronDungeonResultMsg.meta);
	return obj;
end

function RespBackDekaronDungeonResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.layer, idx = readInt(pak, idx);

end



--[[
返回挑战副本退出结果
]]

_G.RespBackDekaronDungeonQuitMsg = {};

RespBackDekaronDungeonQuitMsg.msgId = 8694;
RespBackDekaronDungeonQuitMsg.result = 0; -- 进入结果 0成功



RespBackDekaronDungeonQuitMsg.meta = {__index = RespBackDekaronDungeonQuitMsg};
function RespBackDekaronDungeonQuitMsg:new()
	local obj = setmetatable( {}, RespBackDekaronDungeonQuitMsg.meta);
	return obj;
end

function RespBackDekaronDungeonQuitMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
兽魂信息
]]

_G.RespShouHunInfoMsg = {};

RespShouHunInfoMsg.msgId = 8697;
RespShouHunInfoMsg.list_size = 7; -- 兽魂列表 size
RespShouHunInfoMsg.list = {}; -- 兽魂列表 list



--[[
listVO = {
	tid = 0; -- 兽魂id 1~7
	level = 0; -- 兽魂等级
	star = 0; -- 兽魂星级
}
]]

RespShouHunInfoMsg.meta = {__index = RespShouHunInfoMsg};
function RespShouHunInfoMsg:new()
	local obj = setmetatable( {}, RespShouHunInfoMsg.meta);
	return obj;
end

function RespShouHunInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 7;

	for i=1,list1Size do
		local listVo = {};
		listVo.tid, idx = readInt(pak, idx);
		listVo.level, idx = readInt(pak, idx);
		listVo.star, idx = readInt(pak, idx);
		table.push(list1,listVo);
	end

end



--[[
返回兽魂升级
]]

_G.RespShouHunLevelUpMsg = {};

RespShouHunLevelUpMsg.msgId = 8698;
RespShouHunLevelUpMsg.result = 0; -- 结果 0成功, 1:道具不够 2:比最低兽魂等级差不能超过3 3:功能未开启 
RespShouHunLevelUpMsg.tid = 0; -- 兽魂id
RespShouHunLevelUpMsg.level = 0; -- 兽魂等级
RespShouHunLevelUpMsg.star = 0; -- 兽魂星级



RespShouHunLevelUpMsg.meta = {__index = RespShouHunLevelUpMsg};
function RespShouHunLevelUpMsg:new()
	local obj = setmetatable( {}, RespShouHunLevelUpMsg.meta);
	return obj;
end

function RespShouHunLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.tid, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);
	self.star, idx = readInt(pak, idx);

end



--[[
戒指强化
]]

_G.RespMarryRingStrenMsg = {};

RespMarryRingStrenMsg.msgId = 8699;
RespMarryRingStrenMsg.result = 0; -- 结果 0成功, 1:道具不够 
RespMarryRingStrenMsg.lvl = 0; -- 新等级
RespMarryRingStrenMsg.newVal = 0; -- 祝福值



RespMarryRingStrenMsg.meta = {__index = RespMarryRingStrenMsg};
function RespMarryRingStrenMsg:new()
	local obj = setmetatable( {}, RespMarryRingStrenMsg.meta);
	return obj;
end

function RespMarryRingStrenMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.lvl, idx = readInt(pak, idx);
	self.newVal, idx = readInt(pak, idx);

end



--[[
陷阱预警信息
]]

_G.RespTrapWarningInfoMsg = {};

RespTrapWarningInfoMsg.msgId = 8700;
RespTrapWarningInfoMsg.list_size = 0; -- 预警信息列表 size
RespTrapWarningInfoMsg.list = {}; -- 预警信息列表 list



--[[
listVO = {
	id = 0; -- 预警配置id
	x = 0; -- 预警位置坐标x
	y = 0; -- 预警位置坐标y
}
]]

RespTrapWarningInfoMsg.meta = {__index = RespTrapWarningInfoMsg};
function RespTrapWarningInfoMsg:new()
	local obj = setmetatable( {}, RespTrapWarningInfoMsg.meta);
	return obj;
end

function RespTrapWarningInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local listVo = {};
		listVo.id, idx = readInt(pak, idx);
		listVo.x, idx = readDouble(pak, idx);
		listVo.y, idx = readDouble(pak, idx);
		table.push(list1,listVo);
	end

end



--[[
服务器通知:战弩信息
]]

_G.RespZhanNuInfoMsg = {};

RespZhanNuInfoMsg.msgId = 8701;
RespZhanNuInfoMsg.level = 0; -- 战弩等阶
RespZhanNuInfoMsg.selectlevel = 0; -- 当前使用的战弩等阶
RespZhanNuInfoMsg.progress = 0; -- 进阶进度
RespZhanNuInfoMsg.pillNum = 0; -- 属性丹数量



RespZhanNuInfoMsg.meta = {__index = RespZhanNuInfoMsg};
function RespZhanNuInfoMsg:new()
	local obj = setmetatable( {}, RespZhanNuInfoMsg.meta);
	return obj;
end

function RespZhanNuInfoMsg:ParseData(pak)
	local idx = 1;

	self.level, idx = readInt(pak, idx);
	self.selectlevel, idx = readInt(pak, idx);
	self.progress, idx = readInt(pak, idx);
	self.pillNum, idx = readInt(pak, idx);

end



--[[
服务器返回：战弩进阶
]]

_G.RespZhanNuLevelUpMsg = {};

RespZhanNuLevelUpMsg.msgId = 8702;
RespZhanNuLevelUpMsg.result = 0; -- 请求进阶结果 0:成功(成功获得祝福值), 2:战弩未解锁, 3:已达等级上限, 4:金币不够, 5:道具数量不足
RespZhanNuLevelUpMsg.progress = 0; -- 进阶后的进度



RespZhanNuLevelUpMsg.meta = {__index = RespZhanNuLevelUpMsg};
function RespZhanNuLevelUpMsg:new()
	local obj = setmetatable( {}, RespZhanNuLevelUpMsg.meta);
	return obj;
end

function RespZhanNuLevelUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readByte(pak, idx);
	self.progress, idx = readInt(pak, idx);

end



--[[
激活战弩返回结果
]]

_G.RespActiveZhanNuResultMsg = {};

RespActiveZhanNuResultMsg.msgId = 8703;
RespActiveZhanNuResultMsg.result = 0; -- 0=成功 1=失败



RespActiveZhanNuResultMsg.meta = {__index = RespActiveZhanNuResultMsg};
function RespActiveZhanNuResultMsg:new()
	local obj = setmetatable( {}, RespActiveZhanNuResultMsg.meta);
	return obj;
end

function RespActiveZhanNuResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
切换战弩返回结果
]]

_G.RespChangeZhanNuResultMsg = {};

RespChangeZhanNuResultMsg.msgId = 8704;
RespChangeZhanNuResultMsg.result = 0; -- 0=成功 1=失败
RespChangeZhanNuResultMsg.zhannuId = 0; -- 战弩Id



RespChangeZhanNuResultMsg.meta = {__index = RespChangeZhanNuResultMsg};
function RespChangeZhanNuResultMsg:new()
	local obj = setmetatable( {}, RespChangeZhanNuResultMsg.meta);
	return obj;
end

function RespChangeZhanNuResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.zhannuId, idx = readInt(pak, idx);

end



--[[
返回手机助手状态
]]

_G.RespPhoneHelpStateMsg = {};

RespPhoneHelpStateMsg.msgId = 8705;
RespPhoneHelpStateMsg.state = 0; -- 0关闭,1开启



RespPhoneHelpStateMsg.meta = {__index = RespPhoneHelpStateMsg};
function RespPhoneHelpStateMsg:new()
	local obj = setmetatable( {}, RespPhoneHelpStateMsg.meta);
	return obj;
end

function RespPhoneHelpStateMsg:ParseData(pak)
	local idx = 1;

	self.state, idx = readInt(pak, idx);

end



--[[
宝石镶嵌返回结果
]]

_G.RespGemInstallResultMsg = {};

RespGemInstallResultMsg.msgId = 8706;
RespGemInstallResultMsg.result = 0; -- 0=成功 -1=失败  -2等级不够 -3孔位置不对 -4 没有该类型宝石可以镶嵌
RespGemInstallResultMsg.pos = 0; -- 装备位
RespGemInstallResultMsg.slot = 0; -- 孔位
RespGemInstallResultMsg.tid = 0; -- 宝石id



RespGemInstallResultMsg.meta = {__index = RespGemInstallResultMsg};
function RespGemInstallResultMsg:new()
	local obj = setmetatable( {}, RespGemInstallResultMsg.meta);
	return obj;
end

function RespGemInstallResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);
	self.slot, idx = readInt(pak, idx);
	self.tid, idx = readInt(pak, idx);

end



--[[
宝石卸载返回结果
]]

_G.RespGemUninstallResultMsg = {};

RespGemUninstallResultMsg.msgId = 8707;
RespGemUninstallResultMsg.result = 0; -- 0=成功 -1=失败 -2等级不够 -3该位置没有宝石 -4背包已满 无法卸载宝石 
RespGemUninstallResultMsg.pos = 0; -- 装备位
RespGemUninstallResultMsg.slot = 0; -- 孔位
RespGemUninstallResultMsg.tid = 0; -- 宝石id



RespGemUninstallResultMsg.meta = {__index = RespGemUninstallResultMsg};
function RespGemUninstallResultMsg:new()
	local obj = setmetatable( {}, RespGemUninstallResultMsg.meta);
	return obj;
end

function RespGemUninstallResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);
	self.slot, idx = readInt(pak, idx);
	self.tid, idx = readInt(pak, idx);

end



--[[
宝石更换返回结果
]]

_G.RespChangeResultMsg = {};

RespChangeResultMsg.msgId = 8708;
RespChangeResultMsg.result = 0; -- 0=成功 -1=失败 -2等级不够 -3背包已满，无法卸载宝石
RespChangeResultMsg.pos = 0; -- 装备位
RespChangeResultMsg.slot = 0; -- 孔位
RespChangeResultMsg.gem_oldId = 0; -- 被更换宝石id
RespChangeResultMsg.gem_newId = 0; -- 更换的宝石id



RespChangeResultMsg.meta = {__index = RespChangeResultMsg};
function RespChangeResultMsg:new()
	local obj = setmetatable( {}, RespChangeResultMsg.meta);
	return obj;
end

function RespChangeResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);
	self.slot, idx = readInt(pak, idx);
	self.gem_oldId, idx = readInt(pak, idx);
	self.gem_newId, idx = readInt(pak, idx);

end



--[[
服务器通知:法宝信息
]]

_G.RespFabaoInfoMsg = {};

RespFabaoInfoMsg.msgId = 8709;
RespFabaoInfoMsg.fabaolist_size = 0; -- 法宝列表 size
RespFabaoInfoMsg.fabaolist = {}; -- 法宝列表 list



--[[
fabaoVoVO = {
	id = ""; -- 法宝唯一id
	tid = 0; -- 法宝配置id
	level = 0; -- 法宝等级
	exp = 0; -- 法宝经验
	state = 0; -- 法宝状态，0=初始，1=出战
	changed = 0; -- 法宝变异，0=无，1=有
	attrList_size = 10; -- 属性列表 size
	attrList = {}; -- 属性列表 list
	abilityList_size = 10; -- 资质列表 size
	abilityList = {}; -- 资质列表 list
	skillList_size = 20; -- 被动技能列表 size
	skillList = {}; -- 被动技能列表 list
}
FabaoAttrVoVO = {
	val = 0; -- 属性数值
}
FabaoAbilityVoVO = {
	val = 0; -- 资质数值
}
FabaoSkillVoVO = {
	sid = 0; -- 技能id
}
]]

RespFabaoInfoMsg.meta = {__index = RespFabaoInfoMsg};
function RespFabaoInfoMsg:new()
	local obj = setmetatable( {}, RespFabaoInfoMsg.meta);
	return obj;
end

function RespFabaoInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.fabaolist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local fabaoVoVo = {};
		fabaoVoVo.id, idx = readGuid(pak, idx);
		fabaoVoVo.tid, idx = readInt(pak, idx);
		fabaoVoVo.level, idx = readInt(pak, idx);
		fabaoVoVo.exp, idx = readInt(pak, idx);
		fabaoVoVo.state, idx = readByte(pak, idx);
		fabaoVoVo.changed, idx = readByte(pak, idx);
		table.push(list1,fabaoVoVo);

		local list2 = {};
		fabaoVoVo.attrList = list2;
		local list2Size = 10;

		for i=1,list2Size do
			local FabaoAttrVoVo = {};
			FabaoAttrVoVo.val, idx = readInt(pak, idx);
			table.push(list2,FabaoAttrVoVo);
		end

		local list3 = {};
		fabaoVoVo.abilityList = list3;
		local list3Size = 10;

		for i=1,list3Size do
			local FabaoAbilityVoVo = {};
			FabaoAbilityVoVo.val, idx = readInt(pak, idx);
			table.push(list3,FabaoAbilityVoVo);
		end

		local list4 = {};
		fabaoVoVo.skillList = list4;
		local list4Size = 20;

		for i=1,list4Size do
			local FabaoSkillVoVo = {};
			FabaoSkillVoVo.sid, idx = readInt(pak, idx);
			table.push(list4,FabaoSkillVoVo);
		end
	end

end



--[[
服务器返回：法宝施放目标改变反馈
]]

_G.RespFabaoCastTargetMsg = {};

RespFabaoCastTargetMsg.msgId = 8710;
RespFabaoCastTargetMsg.result = 0; -- 错误码，0=成功



RespFabaoCastTargetMsg.meta = {__index = RespFabaoCastTargetMsg};
function RespFabaoCastTargetMsg:new()
	local obj = setmetatable( {}, RespFabaoCastTargetMsg.meta);
	return obj;
end

function RespFabaoCastTargetMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回：合成法宝反馈
]]

_G.RespFabaoCombineMsg = {};

RespFabaoCombineMsg.msgId = 8711;
RespFabaoCombineMsg.result = 0; -- 错误码，0=成功



RespFabaoCombineMsg.meta = {__index = RespFabaoCombineMsg};
function RespFabaoCombineMsg:new()
	local obj = setmetatable( {}, RespFabaoCombineMsg.meta);
	return obj;
end

function RespFabaoCombineMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回：法宝融合反馈
]]

_G.RespFabaoDevourMsg = {};

RespFabaoDevourMsg.msgId = 8712;
RespFabaoDevourMsg.result = 0; -- 错误码，0=成功
RespFabaoDevourMsg.srcid = ""; -- 原始法宝id
RespFabaoDevourMsg.dstid = ""; -- 目标法宝id



RespFabaoDevourMsg.meta = {__index = RespFabaoDevourMsg};
function RespFabaoDevourMsg:new()
	local obj = setmetatable( {}, RespFabaoDevourMsg.meta);
	return obj;
end

function RespFabaoDevourMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.srcid, idx = readGuid(pak, idx);
	self.dstid, idx = readGuid(pak, idx);

end



--[[
服务器返回：法宝重生反馈
]]

_G.RespFabaoRebornMsg = {};

RespFabaoRebornMsg.msgId = 8713;
RespFabaoRebornMsg.result = 0; -- 错误码，0=成功
RespFabaoRebornMsg.oid = ""; -- 老法宝id
RespFabaoRebornMsg.nid = ""; -- 新法宝id



RespFabaoRebornMsg.meta = {__index = RespFabaoRebornMsg};
function RespFabaoRebornMsg:new()
	local obj = setmetatable( {}, RespFabaoRebornMsg.meta);
	return obj;
end

function RespFabaoRebornMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.oid, idx = readGuid(pak, idx);
	self.nid, idx = readGuid(pak, idx);

end



--[[
服务器返回：法宝炼书反馈
]]

_G.RespFabaoLearnMsg = {};

RespFabaoLearnMsg.msgId = 8714;
RespFabaoLearnMsg.result = 0; -- 错误码，0=成功



RespFabaoLearnMsg.meta = {__index = RespFabaoLearnMsg};
function RespFabaoLearnMsg:new()
	local obj = setmetatable( {}, RespFabaoLearnMsg.meta);
	return obj;
end

function RespFabaoLearnMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回：法宝召唤反馈
]]

_G.RespFabaoCallMsg = {};

RespFabaoCallMsg.msgId = 8715;
RespFabaoCallMsg.result = 0; -- 错误码，0=成功
RespFabaoCallMsg.id = ""; -- 法宝id
RespFabaoCallMsg.callid = ""; -- 法宝实体id
RespFabaoCallMsg.state = 0; -- 状态，0=休息，1=召唤，2=丢弃



RespFabaoCallMsg.meta = {__index = RespFabaoCallMsg};
function RespFabaoCallMsg:new()
	local obj = setmetatable( {}, RespFabaoCallMsg.meta);
	return obj;
end

function RespFabaoCallMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readGuid(pak, idx);
	self.callid, idx = readGuid(pak, idx);
	self.state, idx = readInt(pak, idx);

end



--[[
返回装备升星结果
]]

_G.RespStrenMsg = {};

RespStrenMsg.msgId = 8136;
RespStrenMsg.result = 0; -- 结果,0成功, -1是条件不足失败 -2升星失败 -3没有空星位 -4品质不够
RespStrenMsg.id = ""; -- 装备cid
RespStrenMsg.strenLvl = 0; -- 新强化等级
RespStrenMsg.emptystarnum = 0; -- 空星数



RespStrenMsg.meta = {__index = RespStrenMsg};
function RespStrenMsg:new()
	local obj = setmetatable( {}, RespStrenMsg.meta);
	return obj;
end

function RespStrenMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readGuid(pak, idx);
	self.strenLvl, idx = readInt(pak, idx);
	self.emptystarnum, idx = readInt(pak, idx);

end



--[[
返回打开空星位结果
]]

_G.RespEmptyStarOpenMsg = {};

RespEmptyStarOpenMsg.msgId = 8716;
RespEmptyStarOpenMsg.result = 0; -- 结果,0成功, -1是条件不足失败 -2打开空星位失败
RespEmptyStarOpenMsg.id = ""; -- 装备cid
RespEmptyStarOpenMsg.emptystarnum = 0; -- 空星数



RespEmptyStarOpenMsg.meta = {__index = RespEmptyStarOpenMsg};
function RespEmptyStarOpenMsg:new()
	local obj = setmetatable( {}, RespEmptyStarOpenMsg.meta);
	return obj;
end

function RespEmptyStarOpenMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.id, idx = readGuid(pak, idx);
	self.emptystarnum, idx = readInt(pak, idx);

end



--[[
返回请求装备合成结果
]]

_G.RespEquipMergeMsg = {};

RespEquipMergeMsg.msgId = 8717;
RespEquipMergeMsg.result = 0; -- 结果,0成功, -1失败 -2阶数不同 -3装备位不同 -4至少有一件不是二卓越装备 -5 材料不够 -6该装备不能融合



RespEquipMergeMsg.meta = {__index = RespEquipMergeMsg};
function RespEquipMergeMsg:new()
	local obj = setmetatable( {}, RespEquipMergeMsg.meta);
	return obj;
end

function RespEquipMergeMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
返回护盾增加进度结果
]]

_G.RespHuDunProgressMsg = {};

RespHuDunProgressMsg.msgId = 8718;
RespHuDunProgressMsg.result = 0; -- 结果,0成功, -1失败 -2升阶道具不对 -3 已到最高等级 -4 消耗道具不足
RespHuDunProgressMsg.tid = 0; -- 护盾tid
RespHuDunProgressMsg.star = 0; -- 星级
RespHuDunProgressMsg.level = 0; -- 几阶
RespHuDunProgressMsg.value = 0; -- 进度值



RespHuDunProgressMsg.meta = {__index = RespHuDunProgressMsg};
function RespHuDunProgressMsg:new()
	local obj = setmetatable( {}, RespHuDunProgressMsg.meta);
	return obj;
end

function RespHuDunProgressMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.tid, idx = readInt(pak, idx);
	self.star, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);
	self.value, idx = readInt(pak, idx);

end



--[[
返回护盾一键灌注结果
]]

_G.RespHuDunAutoUpMsg = {};

RespHuDunAutoUpMsg.msgId = 8719;
RespHuDunAutoUpMsg.result = 0; -- 结果,0成功, -1失败
RespHuDunAutoUpMsg.tid = 0; -- 护盾tid
RespHuDunAutoUpMsg.level = 0; -- 几阶
RespHuDunAutoUpMsg.star = 0; -- 星级
RespHuDunAutoUpMsg.value = 0; -- 进度值



RespHuDunAutoUpMsg.meta = {__index = RespHuDunAutoUpMsg};
function RespHuDunAutoUpMsg:new()
	local obj = setmetatable( {}, RespHuDunAutoUpMsg.meta);
	return obj;
end

function RespHuDunAutoUpMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.tid, idx = readInt(pak, idx);
	self.level, idx = readInt(pak, idx);
	self.star, idx = readInt(pak, idx);
	self.value, idx = readInt(pak, idx);

end



--[[
返回护盾信息
]]

_G.RespHuDunInfoMsg = {};

RespHuDunInfoMsg.msgId = 8720;
RespHuDunInfoMsg.list_size = 0; -- 护盾信息 size
RespHuDunInfoMsg.list = {}; -- 护盾信息 list



--[[
HuDunListVO = {
	tid = 0; -- 护盾tid
	value = 0; -- 进度值
	step = 0; -- 几阶
	star = 0; -- 星级
}
]]

RespHuDunInfoMsg.meta = {__index = RespHuDunInfoMsg};
function RespHuDunInfoMsg:new()
	local obj = setmetatable( {}, RespHuDunInfoMsg.meta);
	return obj;
end

function RespHuDunInfoMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local HuDunListVo = {};
		HuDunListVo.tid, idx = readInt(pak, idx);
		HuDunListVo.value, idx = readInt(pak, idx);
		HuDunListVo.step, idx = readInt(pak, idx);
		HuDunListVo.star, idx = readInt(pak, idx);
		table.push(list1,HuDunListVo);
	end

end



--[[
服务器返回：法宝升级反馈
]]

_G.RespFabaoLevelupMsg = {};

RespFabaoLevelupMsg.msgId = 8721;
RespFabaoLevelupMsg.id = ""; -- 法宝id
RespFabaoLevelupMsg.level = 0; -- 当前等级



RespFabaoLevelupMsg.meta = {__index = RespFabaoLevelupMsg};
function RespFabaoLevelupMsg:new()
	local obj = setmetatable( {}, RespFabaoLevelupMsg.meta);
	return obj;
end

function RespFabaoLevelupMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.level, idx = readInt(pak, idx);

end



--[[
服务器返回：法宝经验反馈
]]

_G.RespFabaoExpChangedMsg = {};

RespFabaoExpChangedMsg.msgId = 8722;
RespFabaoExpChangedMsg.id = ""; -- 法宝id
RespFabaoExpChangedMsg.exp = 0; -- 当前经验



RespFabaoExpChangedMsg.meta = {__index = RespFabaoExpChangedMsg};
function RespFabaoExpChangedMsg:new()
	local obj = setmetatable( {}, RespFabaoExpChangedMsg.meta);
	return obj;
end

function RespFabaoExpChangedMsg:ParseData(pak)
	local idx = 1;

	self.id, idx = readGuid(pak, idx);
	self.exp, idx = readInt(pak, idx);

end



--[[
服务器返回：绝学学习升级突破反馈
]]

_G.RespJueXueOperResultMsg = {};

RespJueXueOperResultMsg.msgId = 8723;
RespJueXueOperResultMsg.result = 0; -- 错误码
RespJueXueOperResultMsg.type = 0; -- 1=绝学，2=心法
RespJueXueOperResultMsg.oper = 0; -- 1=学习，2=升级，3=突破
RespJueXueOperResultMsg.gid = 0; -- 组id



RespJueXueOperResultMsg.meta = {__index = RespJueXueOperResultMsg};
function RespJueXueOperResultMsg:new()
	local obj = setmetatable( {}, RespJueXueOperResultMsg.meta);
	return obj;
end

function RespJueXueOperResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.type, idx = readInt(pak, idx);
	self.oper, idx = readInt(pak, idx);
	self.gid, idx = readInt(pak, idx);

end



--[[
服务器返回：绝学心法信息更新
]]

_G.RespJueXueUpdateMsg = {};

RespJueXueUpdateMsg.msgId = 8724;
RespJueXueUpdateMsg.jxlist_size = 16; -- 绝学列表 size
RespJueXueUpdateMsg.jxlist = {}; -- 绝学列表 list
RespJueXueUpdateMsg.xflist_size = 16; -- 心法列表 size
RespJueXueUpdateMsg.xflist = {}; -- 心法列表 list



--[[
juexueVoVO = {
	id = 0; -- 技能id
	lv = 0; -- 技能等级
}
]]
--[[
xinfaVoVO = {
	id = 0; -- 技能id
	lv = 0; -- 技能等级
}
]]

RespJueXueUpdateMsg.meta = {__index = RespJueXueUpdateMsg};
function RespJueXueUpdateMsg:new()
	local obj = setmetatable( {}, RespJueXueUpdateMsg.meta);
	return obj;
end

function RespJueXueUpdateMsg:ParseData(pak)
	local idx = 1;


	local list = {};
	self.jxlist = list;
	local listSize = 16;

	for i=1,listSize do
		local juexueVoVo = {};
		juexueVoVo.id, idx = readInt(pak, idx);
		juexueVoVo.lv, idx = readInt(pak, idx);
		table.push(list,juexueVoVo);
	end

	local list = {};
	self.xflist = list;
	local listSize = 16;

	for i=1,listSize do
		local xinfaVoVo = {};
		xinfaVoVo.id, idx = readInt(pak, idx);
		xinfaVoVo.lv, idx = readInt(pak, idx);
		table.push(list,xinfaVoVo);
	end

end



--[[
服务器返回：伏魔操作反馈
]]

_G.RespFuMoOperResultMsg = {};

RespFuMoOperResultMsg.msgId = 8725;
RespFuMoOperResultMsg.result = 0; -- 错误码
RespFuMoOperResultMsg.oper = 0; -- 1=开启，2=升级
RespFuMoOperResultMsg.id = 0; -- 图鉴id



RespFuMoOperResultMsg.meta = {__index = RespFuMoOperResultMsg};
function RespFuMoOperResultMsg:new()
	local obj = setmetatable( {}, RespFuMoOperResultMsg.meta);
	return obj;
end

function RespFuMoOperResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.oper, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);

end



--[[
服务器返回：伏魔信息更新
]]

_G.RespFuMoUpdateMsg = {};

RespFuMoUpdateMsg.msgId = 8726;
RespFuMoUpdateMsg.fmlist_size = 0; -- 图鉴列表 size
RespFuMoUpdateMsg.fmlist = {}; -- 图鉴列表 list



--[[
fumoVoVO = {
	id = 0; -- 图鉴id
	lv = 0; -- 图鉴等级
	used_num = 0; -- 当前使用数量
}
]]

RespFuMoUpdateMsg.meta = {__index = RespFuMoUpdateMsg};
function RespFuMoUpdateMsg:new()
	local obj = setmetatable( {}, RespFuMoUpdateMsg.meta);
	return obj;
end

function RespFuMoUpdateMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.fmlist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local fumoVoVo = {};
		fumoVoVo.id, idx = readInt(pak, idx);
		fumoVoVo.lv, idx = readInt(pak, idx);
		fumoVoVo.used_num, idx = readInt(pak, idx);
		table.push(list1,fumoVoVo);
	end

end



--[[
服务器返回：转职信息
]]

_G.RespZhuanzhiMsg = {};

RespZhuanzhiMsg.msgId = 8727;
RespZhuanzhiMsg.tid = 0; -- 转职增加属性配置表tid
RespZhuanzhiMsg.ZhuanZhilist_size = 5; -- 转职列表 size
RespZhuanzhiMsg.ZhuanZhilist = {}; -- 转职列表 list



--[[
ZhuanZhiVoVO = {
	tid = 0; -- 转职配置id
	finish = 0; -- 是否完成 0完成  1未完成
	receive = 0; -- 是否领取 0领取  1未领取
}
]]

RespZhuanzhiMsg.meta = {__index = RespZhuanzhiMsg};
function RespZhuanzhiMsg:new()
	local obj = setmetatable( {}, RespZhuanzhiMsg.meta);
	return obj;
end

function RespZhuanzhiMsg:ParseData(pak)
	local idx = 1;

	self.tid, idx = readInt(pak, idx);

	local list = {};
	self.ZhuanZhilist = list;
	local listSize = 5;

	for i=1,listSize do
		local ZhuanZhiVoVo = {};
		ZhuanZhiVoVo.tid, idx = readInt(pak, idx);
		ZhuanZhiVoVo.finish, idx = readInt(pak, idx);
		ZhuanZhiVoVo.receive, idx = readInt(pak, idx);
		table.push(list,ZhuanZhiVoVo);
	end

end



--[[
服务器返回：转生结果
]]

_G.RespZhuanShengResultMsg = {};

RespZhuanShengResultMsg.msgId = 8728;
RespZhuanShengResultMsg.result = 0; -- 0成功 -1失败



RespZhuanShengResultMsg.meta = {__index = RespZhuanShengResultMsg};
function RespZhuanShengResultMsg:new()
	local obj = setmetatable( {}, RespZhuanShengResultMsg.meta);
	return obj;
end

function RespZhuanShengResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回：完成该任务结果
]]

_G.RespFinishZhuanZhiMsg = {};

RespFinishZhuanZhiMsg.msgId = 8729;
RespFinishZhuanZhiMsg.result = 0; -- 0成功 -1失败



RespFinishZhuanZhiMsg.meta = {__index = RespFinishZhuanZhiMsg};
function RespFinishZhuanZhiMsg:new()
	local obj = setmetatable( {}, RespFinishZhuanZhiMsg.meta);
	return obj;
end

function RespFinishZhuanZhiMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回：一键完成所有任务结果
]]

_G.RespZhuanZhiAutoFinishResultMsg = {};

RespZhuanZhiAutoFinishResultMsg.msgId = 8730;
RespZhuanZhiAutoFinishResultMsg.result = 0; -- 0成功 -1失败



RespZhuanZhiAutoFinishResultMsg.meta = {__index = RespZhuanZhiAutoFinishResultMsg};
function RespZhuanZhiAutoFinishResultMsg:new()
	local obj = setmetatable( {}, RespZhuanZhiAutoFinishResultMsg.meta);
	return obj;
end

function RespZhuanZhiAutoFinishResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回：获取转职奖励结果
]]

_G.RespGetZhuanZhiRewardResultMsg = {};

RespGetZhuanZhiRewardResultMsg.msgId = 8731;
RespGetZhuanZhiRewardResultMsg.result = 0; -- 0成功 -1失败



RespGetZhuanZhiRewardResultMsg.meta = {__index = RespGetZhuanZhiRewardResultMsg};
function RespGetZhuanZhiRewardResultMsg:new()
	local obj = setmetatable( {}, RespGetZhuanZhiRewardResultMsg.meta);
	return obj;
end

function RespGetZhuanZhiRewardResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回：星图操作反馈
]]

_G.RespStarOperResultMsg = {};

RespStarOperResultMsg.msgId = 8732;
RespStarOperResultMsg.result = 0; -- 错误码
RespStarOperResultMsg.oper = 0; -- 1=手动，2=自动
RespStarOperResultMsg.id = 0; -- 星图id，1-28
RespStarOperResultMsg.lv = 0; -- 星图重数，1-3
RespStarOperResultMsg.pos = 0; -- 星图位置，1-7



RespStarOperResultMsg.meta = {__index = RespStarOperResultMsg};
function RespStarOperResultMsg:new()
	local obj = setmetatable( {}, RespStarOperResultMsg.meta);
	return obj;
end

function RespStarOperResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);
	self.oper, idx = readInt(pak, idx);
	self.id, idx = readInt(pak, idx);
	self.lv, idx = readInt(pak, idx);
	self.pos, idx = readInt(pak, idx);

end



--[[
服务器返回：星图信息更新
]]

_G.RespStarUpdateMsg = {};

RespStarUpdateMsg.msgId = 8733;
RespStarUpdateMsg.starlist_size = 0; -- 星图列表 size
RespStarUpdateMsg.starlist = {}; -- 星图列表 list



--[[
starVoVO = {
	id = 0; -- 星图id，1-28
	lv = 0; -- 星图重数，1-3
	pos = 0; -- 星图位置，1-7
}
]]

RespStarUpdateMsg.meta = {__index = RespStarUpdateMsg};
function RespStarUpdateMsg:new()
	local obj = setmetatable( {}, RespStarUpdateMsg.meta);
	return obj;
end

function RespStarUpdateMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.starlist = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local starVoVo = {};
		starVoVo.id, idx = readInt(pak, idx);
		starVoVo.lv, idx = readInt(pak, idx);
		starVoVo.pos, idx = readInt(pak, idx);
		table.push(list1,starVoVo);
	end

end



--[[
服务端通知: Monster死亡
]]

_G.RespMonsterKilledMsg = {};

RespMonsterKilledMsg.msgId = 8734;
RespMonsterKilledMsg.cid = ""; -- 怪物ID
RespMonsterKilledMsg.tid = 0; -- 怪物配置ID



RespMonsterKilledMsg.meta = {__index = RespMonsterKilledMsg};
function RespMonsterKilledMsg:new()
	local obj = setmetatable( {}, RespMonsterKilledMsg.meta);
	return obj;
end

function RespMonsterKilledMsg:ParseData(pak)
	local idx = 1;

	self.cid, idx = readGuid(pak, idx);
	self.tid, idx = readInt(pak, idx);

end



--[[
返回野外Boss列表(刷新时推单个)
]]

_G.RespFieldBossMsg = {};

RespFieldBossMsg.msgId = 7278;
RespFieldBossMsg.list_size = 0; -- 野外Boss列表 size
RespFieldBossMsg.list = {}; -- 野外Boss列表 list



--[[
FieldBossVO = {
	tid = 0; -- 野外配置表tid
	line = 0; -- 活动所在线
	state = 0; -- 0活着,1死亡
	lastKillRoleID = ""; -- 上次击杀roleId
	lastKillRoleName = ""; -- 上次击杀roleName
	lastKillTime = 0; -- 上次击杀时间
	type = 0; -- 类型 0是请求时发送 1开启  2重生 3死亡
}
]]

RespFieldBossMsg.meta = {__index = RespFieldBossMsg};
function RespFieldBossMsg:new()
	local obj = setmetatable( {}, RespFieldBossMsg.meta);
	return obj;
end

function RespFieldBossMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local FieldBossVo = {};
		FieldBossVo.tid, idx = readInt(pak, idx);
		FieldBossVo.line, idx = readInt(pak, idx);
		FieldBossVo.state, idx = readInt(pak, idx);
		FieldBossVo.lastKillRoleID, idx = readGuid(pak, idx);
		FieldBossVo.lastKillRoleName, idx = readString(pak, idx, 32);
		FieldBossVo.lastKillTime, idx = readInt64(pak, idx);
		FieldBossVo.type, idx = readInt(pak, idx);
		table.push(list1,FieldBossVo);
	end

end



--[[
返回地宫Boss列表(刷新时推单个)
]]

_G.RespDiGongBossMsg = {};

RespDiGongBossMsg.msgId = 7279;
RespDiGongBossMsg.list_size = 0; -- 地宫Boss列表 size
RespDiGongBossMsg.list = {}; -- 地宫Boss列表 list



--[[
DiGongBossVO = {
	tid = 0; -- 地宫配置表tid
	state = 0; -- 0活着,1死亡
	line = 0; -- 几线
	lastKillTime = 0; -- 上次击杀时间
	type = 0; -- 类型 0是请求时发送 1开启  2重生 3死亡
}
]]

RespDiGongBossMsg.meta = {__index = RespDiGongBossMsg};
function RespDiGongBossMsg:new()
	local obj = setmetatable( {}, RespDiGongBossMsg.meta);
	return obj;
end

function RespDiGongBossMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local DiGongBossVo = {};
		DiGongBossVo.tid, idx = readInt(pak, idx);
		DiGongBossVo.state, idx = readInt(pak, idx);
		DiGongBossVo.line, idx = readInt(pak, idx);
		DiGongBossVo.lastKillTime, idx = readInt64(pak, idx);
		DiGongBossVo.type, idx = readInt(pak, idx);
		table.push(list1,DiGongBossVo);
	end

end



--[[
服务器返回：请求地宫反馈
]]

_G.RespEnterDiGongResultMsg = {};

RespEnterDiGongResultMsg.msgId = 8735;
RespEnterDiGongResultMsg.result = 0; -- 错误码 成功不回复直接扣资源进地图 -1 失败  -2 等级不够  -3  参与人数已满 请稍后再进 -4 活动关闭 -5 不允许组队 -6 请去一线 切换一线在请求进入 -7 跨服无法参加 -8 门票不够



RespEnterDiGongResultMsg.meta = {__index = RespEnterDiGongResultMsg};
function RespEnterDiGongResultMsg:new()
	local obj = setmetatable( {}, RespEnterDiGongResultMsg.meta);
	return obj;
end

function RespEnterDiGongResultMsg:ParseData(pak)
	local idx = 1;

	self.result, idx = readInt(pak, idx);

end



--[[
服务器返回：地宫boss血量
]]

_G.RespDiGongBossHpMsg = {};

RespDiGongBossHpMsg.msgId = 8736;
RespDiGongBossHpMsg.list_size = 0; -- 地宫hp列表 size
RespDiGongBossHpMsg.list = {}; -- 地宫hp列表 list



--[[
DiGongBossHpVO = {
	tid = 0; -- 地宫配置表tid
	hp = 0; -- 地宫boss当前hp
}
]]

RespDiGongBossHpMsg.meta = {__index = RespDiGongBossHpMsg};
function RespDiGongBossHpMsg:new()
	local obj = setmetatable( {}, RespDiGongBossHpMsg.meta);
	return obj;
end

function RespDiGongBossHpMsg:ParseData(pak)
	local idx = 1;


	local list1 = {};
	self.list = list1;
	local list1Size = 0;
	list1Size, idx = readInt(pak,idx);
	for i=1,list1Size do
		local DiGongBossHpVo = {};
		DiGongBossHpVo.tid, idx = readInt(pak, idx);
		DiGongBossHpVo.hp, idx = readDouble(pak, idx);
		table.push(list1,DiGongBossHpVo);
	end

end



--[[
服务端返回: 经验副本增加时间
]]

_G.RespWaterDungeonBuffTimeMsg = {};

RespWaterDungeonBuffTimeMsg.msgId = 8737;
RespWaterDungeonBuffTimeMsg.buffTime = 0; -- buff时间



RespWaterDungeonBuffTimeMsg.meta = {__index = RespWaterDungeonBuffTimeMsg};
function RespWaterDungeonBuffTimeMsg:new()
	local obj = setmetatable( {}, RespWaterDungeonBuffTimeMsg.meta);
	return obj;
end

function RespWaterDungeonBuffTimeMsg:ParseData(pak)
	local idx = 1;

	self.buffTime, idx = readInt(pak, idx);

end
















