--请求好友列表
CSFriendInfoReq = CSFriendInfoReq or BaseClass(BaseProtocolStruct)

function CSFriendInfoReq:__init()
	self.msg_type = 2150
end

function CSFriendInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end


--请求添加好友
CSAddFriendReq = CSAddFriendReq or BaseClass(BaseProtocolStruct)

function CSAddFriendReq:__init()
	self.friend_user_id = 0
	self.is_yi_jian = 0
	self.msg_type = 2151
end

function CSAddFriendReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.friend_user_id)
	MsgAdapter.WriteInt(self.is_yi_jian)
end


--是否接受加好友
CSAddFriendRet = CSAddFriendRet or BaseClass(BaseProtocolStruct)

function CSAddFriendRet:__init()
	self.req_user_id = 0
	self.req_gamename = ""
	self.is_accept = 0
	self.reserved = 0
	self.req_sex = 0
	self.req_prof = 0
	self.msg_type = 2152
end

function CSAddFriendRet:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.req_user_id)
	MsgAdapter.WriteStrN(self.req_gamename, 32)
	MsgAdapter.WriteChar(self.is_accept)
	MsgAdapter.WriteChar(self.reserved)
	MsgAdapter.WriteChar(self.req_sex)
	MsgAdapter.WriteChar(self.req_prof)
end


--发送删除好友请求
CSDeleteFriend = CSDeleteFriend or BaseClass(BaseProtocolStruct)

function CSDeleteFriend:__init()
	self.user_id=0
	self.is_silence=0
	self.msg_type = 2153
end

function CSDeleteFriend:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.user_id)
	MsgAdapter.WriteInt(self.is_silence)
end


--接收好友列表
SCFriendInfoAck = SCFriendInfoAck or BaseClass(BaseProtocolStruct)

function SCFriendInfoAck:__init()
	self.msg_type = 2100
end

function SCFriendInfoAck:Decode()
	self.count = MsgAdapter.ReadInt()
	self.friend_list = {}

	for i = 1, self.count do
		self.friend_list[i] = {}
		self.friend_list[i].user_id = MsgAdapter.ReadInt()
		self.friend_list[i].gamename = MsgAdapter.ReadStrN(32)
		self.friend_list[i].intimacy = MsgAdapter.ReadInt()
		self.friend_list[i].camp = MsgAdapter.ReadChar()
		self.friend_list[i].sex = MsgAdapter.ReadChar()
		self.friend_list[i].prof = MsgAdapter.ReadChar()
		self.friend_list[i].is_online = MsgAdapter.ReadChar()
		MsgAdapter.ReadStrN(32)
		self.friend_list[i].level = MsgAdapter.ReadShort()
		MsgAdapter.ReadShort()
		self.friend_list[i].capability = MsgAdapter.ReadInt()
		self.friend_list[i].avatar_key_big = MsgAdapter.ReadUInt()
		self.friend_list[i].avatar_key_small = MsgAdapter.ReadUInt()
		self.friend_list[i].last_logout_timestamp = MsgAdapter.ReadUInt()
		self.friend_list[i].gift_count = MsgAdapter.ReadInt()		--送礼次数
	end
end

--好友请求
SCAddFriendRoute = SCAddFriendRoute or BaseClass(BaseProtocolStruct)

function SCAddFriendRoute:__init()
	self.req_gamename = ""
	self.req_user_id = 0
	self.req_avatar = 0
	self.req_sex = 0
	self.req_prof = 0
	self.req_camp = 0
	self.req_level = 0
	self.msg_type = 2101
end

function SCAddFriendRoute:Decode()
	self.req_gamename = MsgAdapter.ReadStrN(32)
	self.req_user_id = MsgAdapter.ReadInt()
	self.req_avatar = MsgAdapter.ReadChar()
	self.req_sex = MsgAdapter.ReadChar()
	self.req_prof = MsgAdapter.ReadChar()
	self.req_camp = MsgAdapter.ReadChar()
	self.req_level = MsgAdapter.ReadInt()
	self.avatar_key_big = MsgAdapter.ReadUInt()
	self.avatar_key_small = MsgAdapter.ReadUInt()
	self.req_role_capability = MsgAdapter.ReadInt()
end


--接收好友改变
SCChangeFriend = SCChangeFriend or BaseClass(BaseProtocolStruct)

function SCChangeFriend:__init()
	self.msg_type = 2102
	self.changestate = 0
	self.friend_info = {}
end

function SCChangeFriend:Decode()
	self.friend_info.user_id = MsgAdapter.ReadInt()
	self.friend_info.gamename = MsgAdapter.ReadStrN(32)
	self.friend_info.intimacy = MsgAdapter.ReadInt()
	MsgAdapter.ReadChar()
	self.friend_info.sex = MsgAdapter.ReadChar()
	self.changestate = MsgAdapter.ReadChar()
	self.friend_info.prof = MsgAdapter.ReadChar()
	self.friend_info.camp = MsgAdapter.ReadChar()
	self.friend_info.is_online = MsgAdapter.ReadChar()
	self.friend_info.level = MsgAdapter.ReadShort()
	self.friend_info.capability = MsgAdapter.ReadInt()
	self.friend_info.avatar_key_big = MsgAdapter.ReadUInt()
	self.friend_info.avatar_key_small = MsgAdapter.ReadUInt()
	self.friend_info.last_logout_timestamp = MsgAdapter.ReadUInt()
	self.friend_info.gift_count = MsgAdapter.ReadInt()

end


--接收对方是否同意添加好友请求
SCAddFriendRet = SCAddFriendRet or BaseClass(BaseProtocolStruct)

function SCAddFriendRet:__init()
	self.msg_type = 2103

	self.gamename=""
	self.is_accept=0       -- 0不同意，1同意
end

function SCAddFriendRet:Decode()
	self.gamename = MsgAdapter.ReadStrN(32)
	self.is_accept = MsgAdapter.ReadInt()
end


StructEnemy = StructEnemy or {}

function StructEnemy.ReadEnemyItem()
	local stu = {}
	stu.gamename = MsgAdapter.ReadStrN(32)
	stu.last_kill_time = MsgAdapter.ReadLL()
	stu.user_id = MsgAdapter.ReadInt()
	stu.kill_count = MsgAdapter.ReadInt()
	stu.index = MsgAdapter.ReadInt()
	stu.camp = MsgAdapter.ReadChar()
	stu.sex = MsgAdapter.ReadChar()
	stu.prof = MsgAdapter.ReadChar()
	stu.is_online = MsgAdapter.ReadChar()
	stu.level = MsgAdapter.ReadShort()
	MsgAdapter.ReadShort()
	stu.capability = MsgAdapter.ReadInt()
	stu.avatar_key_big = MsgAdapter.ReadUInt()
	stu.avatar_key_small = MsgAdapter.ReadUInt()
	return stu
 end

--返回仇人列表2104
SCEnemyListACK = SCEnemyListACK or BaseClass(BaseProtocolStruct)

function SCEnemyListACK:__init()
	self.msg_type = 2104

	self.count = 0
	self.enemy_list = {}
end

function SCEnemyListACK:Decode()
	self.count = MsgAdapter.ReadInt()

	self.enemy_list = {}
	for i=1,self.count do
		self.enemy_list[i] = StructEnemy.ReadEnemyItem()
	end
end

--服务器通知客户端仇人改变2105
SCChangeEnemy = SCChangeEnemy or BaseClass(BaseProtocolStruct)

function SCChangeEnemy:__init()
	self.msg_type = 2105
	self.changstate = 0
	self.enemy_info = {}
end

function SCChangeEnemy:Decode()
	self.enemy_info.index = MsgAdapter.ReadInt()
	self.enemy_info.user_id = MsgAdapter.ReadInt()
	self.enemy_info.gamename = MsgAdapter.ReadStrN(32)
	self.enemy_info.last_kill_time = MsgAdapter.ReadLL()
	self.enemy_info.kill_count = MsgAdapter.ReadInt()
	self.enemy_info.camp = MsgAdapter.ReadChar()
	self.enemy_info.sex = MsgAdapter.ReadChar()
	self.changstate = MsgAdapter.ReadChar()
	self.enemy_info.prof = MsgAdapter.ReadChar()
	self.enemy_info.level = MsgAdapter.ReadShort()
	self.enemy_info.is_online = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.enemy_info.capability = MsgAdapter.ReadInt()
	self.enemy_info.avatar_key_big = MsgAdapter.ReadUInt()
	self.enemy_info.avatar_key_small = MsgAdapter.ReadUInt()
end

--请求删除仇人2154
CSEnemyDelete = CSEnemyDelete or BaseClass(BaseProtocolStruct)

function CSEnemyDelete:__init()
	self.msg_type = 2154

	self.user_id = 0
end

function CSEnemyDelete:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.user_id)
end

--送花
CSGiveFlower = CSGiveFlower or BaseClass(BaseProtocolStruct)

function CSGiveFlower:__init()
	self.msg_type = 2155

	self.grid_index = 0
	self.item_id = 0
	self.target_uid = 0
	self.is_anonymity = 0
	self.is_marry = 0
end

function CSGiveFlower:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteShort(self.grid_index)
	MsgAdapter.WriteUShort(self.item_id)
	MsgAdapter.WriteInt(self.target_uid)
	MsgAdapter.WriteShort(self.is_anonymity)
	MsgAdapter.WriteShort(self.is_marry)
end

--回敬飞吻
CSGiveFlowerKissReq = CSGiveFlowerKissReq or BaseClass(BaseProtocolStruct)

function CSGiveFlowerKissReq:__init()
	self.msg_type = 2156

	self.target_uid = 0
end

function CSGiveFlowerKissReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.target_uid)
end

--被回敬飞吻
SCGiveFlowerKissAck = SCGiveFlowerKissAck or BaseClass(BaseProtocolStruct)

function SCGiveFlowerKissAck:__init()
	self.msg_type = 2106

	self.from_uid = 0
	self.from_camp = 0
	self.from_name = 0
end

function SCGiveFlowerKissAck:Decode()
	self.from_uid = MsgAdapter.ReadInt()
	self.from_camp = MsgAdapter.ReadInt()
	self.from_name = MsgAdapter.ReadStrN(32)
end

--被送花
SCGiveFlower = SCGiveFlower or BaseClass(BaseProtocolStruct)

function SCGiveFlower:__init()
	self.msg_type = 2107

	self.target_uid = 0
	self.from_uid = 0
	self.flower_num = 0
	self.is_anonymity = 0
	self.target_name = 0
	self.from_name = 0
	self.item_id = 0
	self.reserve = 0
end

function SCGiveFlower:Decode()
	self.target_uid = MsgAdapter.ReadInt()
	self.from_uid = MsgAdapter.ReadInt()
	self.flower_num = MsgAdapter.ReadInt()
	self.is_anonymity = MsgAdapter.ReadInt()
	self.target_name = MsgAdapter.ReadStrN(32)
	self.from_name = MsgAdapter.ReadStrN(32)
	self.item_id = MsgAdapter.ReadUShort()
	self.reserve = MsgAdapter.ReadShort()
end

--魅力值改变
SCAllCharmChange = SCAllCharmChange or BaseClass(BaseProtocolStruct)

function SCAllCharmChange:__init()
	self.msg_type = 2108

	self.uid = 0
	self.all_charm = 0
end

function SCAllCharmChange:Decode()
	self.uid = MsgAdapter.ReadInt()
	self.all_charm = MsgAdapter.ReadInt()
end

--祝福信息请求
CSFriendBlessOperaReq = CSFriendBlessOperaReq or BaseClass(BaseProtocolStruct)

function CSFriendBlessOperaReq:__init()
	self.msg_type = 2157
	self.bless_opera_type = 1
	self.target_uid = 0
end

function CSFriendBlessOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.bless_opera_type)
	MsgAdapter.WriteInt(self.target_uid)
end

--接收第一次返回的祝福信息
SCFriendBlessAllInfo = SCFriendBlessAllInfo or BaseClass(BaseProtocolStruct)

function SCFriendBlessAllInfo:__init()
	self.msg_type = 2109
end

function SCFriendBlessAllInfo:Decode()
	self.fetch_reward_times = MsgAdapter.ReadInt()
	self.bless_times = MsgAdapter.ReadInt()
	self.bless_item_count = MsgAdapter.ReadInt()
	self.bless_list = {}
	for i = 1, self.bless_item_count do
		self.bless_list[i] = {}
		self.bless_list[i].user_id = MsgAdapter.ReadInt() 			 	--好友uid
		self.bless_list[i].has_bless = MsgAdapter.ReadChar()			--我是否祝福过他
		self.bless_list[i].bless_me = MsgAdapter.ReadChar()				--他是否祝福过我
		self.bless_list[i].has_fetch_reward = MsgAdapter.ReadChar()		--我是否领取了祝福奖励
		MsgAdapter.ReadChar()
	end
end

--接收改变个别状态的祝福信息
SCFriendBlessChangeInfo = SCFriendBlessChangeInfo or BaseClass(BaseProtocolStruct)

function SCFriendBlessChangeInfo:__init()
	self.msg_type = 2110
end

function SCFriendBlessChangeInfo:Decode()

	self.notify_reason = MsgAdapter.ReadInt()
	self.fetch_reward_times = MsgAdapter.ReadInt()
	self.bless_times = MsgAdapter.ReadInt()

	self.bless_change_info = {}
	self.bless_change_info.user_id = MsgAdapter.ReadInt() 			 	--好友uid
	self.bless_change_info.has_bless = MsgAdapter.ReadChar()			--我是否祝福过他
	self.bless_change_info.bless_me = MsgAdapter.ReadChar()				--他是否祝福过我
	self.bless_change_info.has_fetch_reward = MsgAdapter.ReadChar()		--我是否领取了祝福奖励
	MsgAdapter.ReadChar()
end

--接收被别人祝福邀请信息
SCFriendBlessInviteBless = SCFriendBlessInviteBless or BaseClass(BaseProtocolStruct)

function SCFriendBlessInviteBless:__init()
	self.msg_type = 2111
	self.gamename = ""
end

function SCFriendBlessInviteBless:Decode()
	self.uid = MsgAdapter.ReadInt()										--接收邀请你的朋友的ID
	self.gamename = MsgAdapter.ReadStrN(32)								--邀请你的朋友的名字
end

--送花
SCSoneHuaInfo = SCSoneHuaInfo or BaseClass(BaseProtocolStruct)
function SCSoneHuaInfo:__init()
	self.msg_type = 2112
end

function SCSoneHuaInfo:Decode()
	self.daily_use_free_times = MsgAdapter.ReadInt()
end

CSSoneHuaInfoReq = CSSoneHuaInfoReq or BaseClass(BaseProtocolStruct)
function CSSoneHuaInfoReq:__init()
	self.msg_type = 2113
end

function CSSoneHuaInfoReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end
------黑名单-------------

 --添加到黑名单
CSAddBlackReq = CSAddBlackReq or BaseClass(BaseProtocolStruct)

function CSAddBlackReq:__init()
	self.msg_type = 2159
	self.user_id = 0
end

function CSAddBlackReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.user_id)
	MsgAdapter.WriteInt(0)

end

 --删除黑名单
CSDeleteBlackReq = CSDeleteBlackReq or BaseClass(BaseProtocolStruct)

function CSDeleteBlackReq:__init()
	self.msg_type = 2160
	self.user_id = 0
end

function CSDeleteBlackReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.user_id)
	MsgAdapter.WriteInt(0)

end

--服务器通知客户端黑名单改变
SCChangeBlacklist = SCChangeBlacklist or BaseClass(BaseProtocolStruct)

function SCChangeBlacklist:__init()
	self.msg_type = 2161
end

function SCChangeBlacklist:Decode()
	self.index = MsgAdapter.ReadInt()
	self.user_id = MsgAdapter.ReadInt()
	self.gamename = MsgAdapter.ReadStrN(32)
	self.changstate = MsgAdapter.ReadChar() --0 update 1 del
	self.sex = MsgAdapter.ReadChar()
	self.prof = MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	self.level = MsgAdapter.ReadInt()
	self.avatar_key_big = MsgAdapter.ReadUInt()
	self.avatar_key_small = MsgAdapter.ReadUInt()
end

--请求玩家登录时间戳
CSRoleLoginTimeSeq = CSRoleLoginTimeSeq or BaseClass(BaseProtocolStruct)

function CSRoleLoginTimeSeq:__init()
	self.msg_type = 2162
end

function CSRoleLoginTimeSeq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
end

--玩家登录时间戳返回
SCGetRoleLoginTime = SCGetRoleLoginTime or BaseClass(BaseProtocolStruct)

function SCGetRoleLoginTime:__init()
	self.msg_type = 2163
end

function SCGetRoleLoginTime:Decode()
	self.login_time = MsgAdapter.ReadUInt()
end

-- 返回黑名单
SCBlacklistsACK = SCBlacklistsACK or BaseClass(BaseProtocolStruct)

function SCBlacklistsACK:__init()
	self.msg_type = 2158
end

function SCBlacklistsACK:Decode()
	local count= MsgAdapter.ReadInt()
	self.blacklist = {}
	for i = 1, count do
		local vo = {}
		vo.user_id = MsgAdapter.ReadInt()
		vo.gamename = MsgAdapter.ReadStrN(32)
		vo.sex = MsgAdapter.ReadChar()
		vo.prof = MsgAdapter.ReadChar()
		vo.level = MsgAdapter.ReadShort()
		vo.avatar_key_big = MsgAdapter.ReadUInt()
		vo.avatar_key_small = MsgAdapter.ReadUInt()
		self.blacklist[i] = vo
	end
end