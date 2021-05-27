--===================================请求==================================
--添加或删除某人
CSAddOrDelSomeOne = CSAddOrDelSomeOne or BaseClass(BaseProtocolStruct)
function CSAddOrDelSomeOne:__init()
	self:InitMsgType(41, 1)
	self.opt_type = 0					-- (uchar)操作类型, 0添加, 1删除
	self.relate_column = 1				-- (uchar)关系栏目, 0好友, 1仇敌, 2黑名单
	self.role_id = 0
	self.role_name = ""
end

function CSAddOrDelSomeOne:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.opt_type)
	MsgAdapter.WriteUChar(self.relate_column)
	MsgAdapter.WriteInt(self.role_id)
	MsgAdapter.WriteStr(self.role_name)
end

--是否同意添加(返回 41 2)
CSIsAgreeAdd = CSIsAgreeAdd or BaseClass(BaseProtocolStruct)
function CSIsAgreeAdd:__init()
	self:InitMsgType(41, 2)
	self.answer_result = 0		--(uchar)1同意, 0不同意
	self.relate_column = 1		--(uchar)关系栏目, 0好友, 1仇敌, 2黑名单
	self.opposite_id = 0
end

function CSIsAgreeAdd:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.answer_result)
	MsgAdapter.WriteUChar(self.relate_column)
	MsgAdapter.WriteInt(self.opposite_id)
end

--获取关系列表(返回 第一次请求41 3, 第二次后41 8)
CSGetRelationshipList = CSGetRelationshipList or BaseClass(BaseProtocolStruct)
function CSGetRelationshipList:__init()
	self:InitMsgType(41, 3)
	
end

function CSGetRelationshipList:Encode()
	self:WriteBegin()
end

--追踪玩家(返回 41 5)
CSTracePlayer = CSTracePlayer or BaseClass(BaseProtocolStruct)
function CSTracePlayer:__init()
	self:InitMsgType(41, 5)
	self.beTraced_name = ""		--(string)被追踪的名字
end

function CSTracePlayer:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.beTraced_name)
end

--获取追踪的信息(返回 41 5)
CSGetTraceInfo = CSGetTraceInfo or BaseClass(BaseProtocolStruct)
function CSGetTraceInfo:__init()
	self:InitMsgType(41, 6)
end

function CSGetTraceInfo:Encode()
	self:WriteBegin()
end

--设置心情(返回41 7，这个先不做)
CSExpressMood = CSExpressMood or BaseClass(BaseProtocolStruct)
function CSExpressMood:__init()
	self:InitMsgType(41, 7)
	self.mood_content = "" 		--(string)玩家输入的心情内容最长64个字符
end

function CSExpressMood:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.mood_content)
end

--好友聊天(这个先不做)
CSChatWithFriend = CSChatWithFriend or BaseClass(BaseProtocolStruct)
function CSChatWithFriend:__init()
	self:InitMsgType(41, 9)
	self.role_id = 0
	self.chat_content = ""
	self.freind_name = ""
	self.content_type = 0			--(uchar)0文本, 1语音
	self.check_code = 1
end

function CSChatWithFriend:Encode()
	self:WriteBegin()
	MsgAdapter.WriteInt(self.role_id)
	MsgAdapter.WriteStr(self.chat_content)
	MsgAdapter.WriteStr(self.freind_name)
	MsgAdapter.WriteUChar(self.content_type)
	MsgAdapter.WriteUInt(self.check_code)
end

--发送坐标扣除金币
CSSendCoordAndDeductGold = CSSendCoordAndDeductGold or BaseClass(BaseProtocolStruct)
function CSSendCoordAndDeductGold:__init()
	self:InitMsgType(41, 10)
	
end
function CSSendCoordAndDeductGold:Encode()
	self:WriteBegin()
end

-- 是否同意结婚
CSReplyMarry = CSReplyMarry or BaseClass(BaseProtocolStruct)
function CSReplyMarry:__init()
	self:InitMsgType(41, 12)
	self.reply_result = 0 	-- (uchar)0拒绝,1同意
	self.role_id = 0
end

function CSReplyMarry:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.reply_result)
	MsgAdapter.WriteInt(self.role_id)
end

--获取仇人列表
CSGetEnemyList = CSGetEnemyList or BaseClass(BaseProtocolStruct)
function CSGetEnemyList:__init()
	self:InitMsgType(41, 16)
	
end
function CSGetEnemyList:Encode()
	self:WriteBegin()
end

--请求仇人处理(返回 41 17)
CSRequestHandleEnemy = CSRequestHandleEnemy or BaseClass(BaseProtocolStruct)
function CSRequestHandleEnemy:__init()
	self:InitMsgType(41, 17)
	self.op_type = 1 			-- (uchar)操作类型, 1查看, 2删除
    self.kill_time = 0 			-- (int)击杀时间, 是一个短时间(单位秒)，短时间 = (uint)当前系统时间 - 2010/1/1 00:00:00
end

function CSRequestHandleEnemy:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.op_type)
	MsgAdapter.WriteInt(self.kill_time)
end

--给好友聚宝盆增加经验(好像没用了)
CSAddExp2FriendTreasureBowl = CSAddExp2FriendTreasureBowl or BaseClass(BaseProtocolStruct)
function CSAddExp2FriendTreasureBowl:__init()
	self:InitMsgType(41, 18)
	self.role_id = 0
    
end

function CSAddExp2FriendTreasureBowl:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUInt(self.role_id)
end

--搜索某人
CSSearchSomeOne = CSSearchSomeOne or BaseClass(BaseProtocolStruct)
function CSSearchSomeOne:__init()
	self:InitMsgType(41, 19)
	self.search_name = ""
    
end

function CSSearchSomeOne:Encode()
	self:WriteBegin()
	MsgAdapter.WriteStr(self.search_name)
end

--===================================下发==================================

--返回添加好友等需要对方同意
SCAddSomeOneWaitAgree = SCAddSomeOneWaitAgree or BaseClass(BaseProtocolStruct)
function SCAddSomeOneWaitAgree:__init()
	self:InitMsgType(41, 1)
	self.answer = 1		--(uchar)1为添加到好友栏, 2为仇人, 
	self.self_id = 0
	self.self_name = ""
	self.power = 0
	self.level = 0
	self.prof = 0
	self.sex = 0
	self.guild_name = ""
end

function SCAddSomeOneWaitAgree:Decode()
	self.answer = MsgAdapter.ReadUChar()
	self.self_id = MsgAdapter.ReadInt()
	self.self_name = MsgAdapter.ReadStr()
	self.power = MsgAdapter.ReadInt()
	self.level = MsgAdapter.ReadUShort()
	self.prof = MsgAdapter.ReadUChar()
	self.sex = MsgAdapter.ReadUChar()
	self.guild_name = MsgAdapter.ReadStr()
end

-- 接收添加或删除信息
SCAddOrDelNeedInfo = SCAddOrDelNeedInfo or BaseClass(BaseProtocolStruct)
function SCAddOrDelNeedInfo:__init()
	self:InitMsgType(41, 2)
	self.op_type = 0				--(uchar)操作类型, 0添加, 1删除 
	self.relate_column = 1			--(uchar)好友栏目索引, 0好友, 1仇敌, 2黑名单
	self.role_id = 0				--(int)对方角色id
	self.is_online = 0				--(uchar)0不在线,1在线
	self.opposite_info = {}
end

function SCAddOrDelNeedInfo:Decode()
	self.op_type = MsgAdapter.ReadUChar()
	self.relate_column = MsgAdapter.ReadUChar()
	self.role_id = MsgAdapter.ReadInt()
	self.is_online = MsgAdapter.ReadUChar()
	self.opposite_info = {}
	if self.op_type == 0 then
		self.opposite_info.role_id = self.role_id
		self.opposite_info.type = self.relate_column
		self.opposite_info.name = MsgAdapter.ReadStr()
		self.opposite_info.level = MsgAdapter.ReadInt()	
		self.opposite_info.prof = MsgAdapter.ReadInt()	
		self.opposite_info.avatar_id = MsgAdapter.ReadInt()
		self.opposite_info.feel = MsgAdapter.ReadStr()
		self.opposite_info.sex = MsgAdapter.ReadInt() 			
		self.opposite_info.guild_name = MsgAdapter.ReadStr()
		self.opposite_info.intimacy = MsgAdapter.ReadInt()
		self.opposite_info.is_online = self.is_online
	end
end

--返回关系列表
SCGetRelationshipList = SCGetRelationshipList or BaseClass(BaseProtocolStruct)
function SCGetRelationshipList:__init()
	self:InitMsgType(41, 3)
	self.count = 0					--(int)数量
	self.relation_info_list = {}
end

function SCGetRelationshipList:Decode()
	self.count = MsgAdapter.ReadInt()
	self.relation_info_list = {}
	for i = 1, self.count, 1 do
		local vo = {}
		local val = MsgAdapter.ReadUChar()
		vo.type = {}
		for i = 0, 2 do
			if bit:_and(bit:_rshift(val, i), 1) == 1 then
				table.insert(vo.type, i)
			end
		end
		vo.role_id = MsgAdapter.ReadInt()
		vo.is_online = MsgAdapter.ReadUChar()		--(uchar)1在线, 0不在线
		vo.name = MsgAdapter.ReadStr()
		vo.prof = MsgAdapter.ReadInt()
		vo.level = MsgAdapter.ReadInt()
		vo.avatar_id = MsgAdapter.ReadInt()
		vo.feel = MsgAdapter.ReadStr() 
		vo.sex = MsgAdapter.ReadInt()
		vo.guild_name = MsgAdapter.ReadStr()
		vo.intimacy = MsgAdapter.ReadInt() 
		self.relation_info_list[i] = vo
	end
end

--下发推荐的好友列表
SCIssueRecommendFriendList = SCIssueRecommendFriendList or BaseClass(BaseProtocolStruct)
function SCIssueRecommendFriendList:__init()
	self:InitMsgType(41, 4)             --41 4
	self.recommend_count = 0            --(int)推荐数量
	self.recommend_friends_info = {}
end

function SCIssueRecommendFriendList:Decode()
	self.recommend_friends_info = {}
	self.recommend_count = MsgAdapter.ReadInt()
	for i = 1, self.recommend_count do
		local vo = {}
		vo.id = MsgAdapter.ReadInt()
		vo.name = MsgAdapter.ReadStr()
		vo.sex = MsgAdapter.ReadInt()
		vo.level = MsgAdapter.ReadInt()
		vo.prof = MsgAdapter.ReadInt()
		vo.power = MsgAdapter.ReadInt()
		self.recommend_friends_info[i] = vo
	end
end

--返回追踪的信息
SCGetTraceInfo = SCGetTraceInfo or BaseClass(BaseProtocolStruct)
function SCGetTraceInfo:__init()
	self:InitMsgType(41, 5)
	self.role_id = 0
	self.name = ""
	self.scene_id = 0
	self.scene_name = ""
	self.pos_x = 0
	self.pos_y = 0
end

function SCGetTraceInfo:Decode()
	self.role_id = MsgAdapter.ReadInt()
	self.name = MsgAdapter.ReadStr()
	self.scene_id = MsgAdapter.ReadInt()
	self.scene_name = MsgAdapter.ReadStr()
	self.pos_x = MsgAdapter.ReadInt()
	self.pos_y = MsgAdapter.ReadInt()
end

--发送报警信息
SCSendAlertInfo = SCSendAlertInfo or BaseClass(BaseProtocolStruct)
function SCSendAlertInfo:__init()
	self:InitMsgType(41, 6)
	self.tracer_name = ""
	self.scene_id = 0
	self.tracer_pos_x = 0
	self.tracer_pos_y = 0
end

function SCSendAlertInfo:Decode()
	self.tracer_name = MsgAdapter.ReadStr()
	self.scene_id = MsgAdapter.ReadInt()
	self.tracer_pos_x = MsgAdapter.ReadInt()
	self.tracer_pos_y = MsgAdapter.ReadInt()	
end

--返回心情
SCCurrentMood = SCCurrentMood or BaseClass(BaseProtocolStruct)
function SCCurrentMood:__init()
	self:InitMsgType(41, 7)
	self.cur_mood = ""
end

function SCCurrentMood:Decode()
	self.cur_mood = MsgAdapter.ReadStr()
end

--下发需要更新的关系列表
SCIssueUpdateRelationList = SCIssueUpdateRelationList or BaseClass(BaseProtocolStruct)
function SCIssueUpdateRelationList:__init()
	self:InitMsgType(41, 8)
	self.update_count = 0
	self.relation_info_list = {}
end

function SCIssueUpdateRelationList:Decode()
	self.update_count = MsgAdapter.ReadInt()
	self.relation_info_list = {}
	for i = 1, self.update_count, 1 do
		local vo = {}
		local val = MsgAdapter.ReadUChar()
		vo.type = {}
		for i = 0, 2 do
			if bit:_and(bit:_rshift(val, i), 1) == 1 then
				table.insert(vo.type, i)
			end
		end
		vo.role_id = MsgAdapter.ReadInt()
		vo.name = MsgAdapter.ReadStr()
		vo.prof = MsgAdapter.ReadInt()
		vo.level = MsgAdapter.ReadInt()
		vo.avatar_id = MsgAdapter.ReadInt()
		vo.feel = MsgAdapter.ReadStr()
		vo.sex = MsgAdapter.ReadInt()
		vo.guild_name = MsgAdapter.ReadStr()
		vo.is_online = MsgAdapter.ReadUChar()
		vo.intimacy = MsgAdapter.ReadInt()
		self.relation_info_list[i] = vo
	end
end

--返回好友聊天消息
SCChatInfo = SCChatInfo or BaseClass(BaseProtocolStruct)
function SCChatInfo:__init()
	self:InitMsgType(41, 9)
	self.chat_record_count = 0
	self.chat_record_list = {}
end

function SCChatInfo:Decode()
	self.chat_record_list = {}
	self.chat_record_count = MsgAdapter.ReadInt()
	for i = 1, self.chat_record_count do
		local vo = {}
	    vo.self_role_id = MsgAdapter.ReadInt()
		vo.self_name = MsgAdapter.ReadStr()
		vo.short_time = MsgAdapter.ReadInt() 	-- (int)短时间(单位秒)，短时间 = (uint)当前系统时间 - 2010/1/1 00:00:00
		vo.self_level = MsgAdapter.ReadInt()     
		vo.self_sex = MsgAdapter.ReadInt() 
		vo.self_avatar_id = MsgAdapter.ReadInt()
		vo.chat_content = MsgAdapter.ReadStr()
		vo.is_gm_authority = MsgAdapter.ReadInt()
		self.chat_record_list[i] = vo
	end
end

-- 下发请求结婚
SCRequestMarry = SCRequestMarry or BaseClass(BaseProtocolStruct)
function SCRequestMarry:__init()
	self:InitMsgType(41, 12)
	self.role_id = 0
	self.role_name = ""
end

function SCRequestMarry:Decode()
	self.role_id = MsgAdapter.ReadInt()
	self.role_name = MsgAdapter.ReadStr()
end

--发送仇人列表
SCSendEnemyList = SCSendEnemyList or BaseClass(BaseProtocolStruct)
function SCSendEnemyList:__init()
	self:InitMsgType(41, 16)
	self.enemy_count = 0 		--(uchar)仇人数量, 最多只存10个
	self.enemy_list = {}
end

function SCSendEnemyList:Decode()
	self.enemy_list = {}
	self.enemy_count = MsgAdapter.ReadUChar()
	for i = 1, self.enemy_count do
		local vo = {}
		vo.enemy_name = MsgAdapter.ReadStr()
		vo.enemy_avatar_id = MsgAdapter.ReadUChar()
		vo.enemy_level = MsgAdapter.ReadUChar()
		vo.enemy_sex = MsgAdapter.ReadUChar() 
		vo.enemy_prof = MsgAdapter.ReadUChar()
		vo.kill_time = MsgAdapter.ReadUChar()
		self.enemy_list[i] = vo
	end
end

--返回处理仇人结果
SCHandleEnemyResult = SCHandleEnemyResult or BaseClass(BaseProtocolStruct)
function SCHandleEnemyResult:__init()
	self:InitMsgType(41, 17)
	self.op_type = 1		--(uchar)操作类型, 1查看, 2删除
	self.kill_time = 0
end

function SCHandleEnemyResult:Decode()
	self.op_type = MsgAdapter.ReadUChar()
	if self.oper_type == 2 then
		self.kill_time = MsgAdapter.ReadUInt()
	end
end

--返回搜索结果
SCGetSearchResult = SCGetSearchResult or BaseClass(BaseProtocolStruct)
function SCGetSearchResult:__init()
	self:InitMsgType(41, 18)
	self.count = ""					--(uchar)数量, 最多显示20个
	self.search_result_list = {}
end

function SCGetSearchResult:Decode()
	self.search_result_list = {}
	self.count = MsgAdapter.ReadUChar()
	for i = 1, self.count do
		local vo = {}
		vo.name = MsgAdapter.ReadStr()
		vo.role_id = MsgAdapter.ReadInt()
		vo.prof = MsgAdapter.ReadInt()
		vo.level = MsgAdapter.ReadInt() 
		vo.guild_name = MsgAdapter.ReadStr()
		self.search_result_list[i] = vo
	end
end