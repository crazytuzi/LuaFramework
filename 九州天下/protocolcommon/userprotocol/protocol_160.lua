SCActivityStatusShow = SCActivityStatusShow or BaseClass(BaseProtocolStruct)
function SCActivityStatusShow:__init()
	self.msg_type = 16010
end

function SCActivityStatusShow:Decode()
	self.forecast_act_list = {}
	for i = 1, GameEnum.FORECAST_CFG_COUNT do
		local vo = {}
		vo.activity_type = MsgAdapter.ReadInt()
		vo.is_close = MsgAdapter.ReadInt() 					-- 是否已关闭
		vo.act_begin_time = MsgAdapter.ReadUInt() 			-- 参与时间(开始)
		vo.act_end_time = MsgAdapter.ReadUInt() 			-- 参与时间（结束）
		vo.act_begin_cd = MsgAdapter.ReadInt() 				-- 开始剩余时间（倒计时）
		vo.is_opening = MsgAdapter.ReadInt()				-- 活动是否开启中
		self.forecast_act_list[i] = vo
	end
end

--玩家死亡信息
SCRoleDeathTrackInfo = SCRoleDeathTrackInfo or BaseClass(BaseProtocolStruct)
function SCRoleDeathTrackInfo:__init()
	self.msg_type = 16000
	self.yesterday_die_times = 0
	self.yesterday_killer_item_list = {}
end

function SCRoleDeathTrackInfo:Decode()
	self.yesterday_die_times = MsgAdapter.ReadInt()
	for i = 1,DIE_MAIL.SEND_KILLER_ITEM_COUNT do
		self.yesterday_killer_item_list[i] = ProtocolStruct.ReadKillerItem()
	end
end

-- 连服积分信息
ServerGroupScoreParam = ServerGroupScoreParam or BaseClass(BaseProtocolStruct)
function ServerGroupScoreParam:__init()
	self.msg_type = 16001
end

function ServerGroupScoreParam:Decode()
	self.own_judian_info_list = {}
	self.source_item_list = {}
	for i = 1, GameEnum.CROSS_XYJD_MAX_ID_COUNT do
		self.own_judian_info_list[i] = MsgAdapter.ReadInt()
	end 
	for i = 1, SERVER_GROUP_TYPE.SERVER_GROUP_TYPE_MAX do
		local vo = {}
		vo.server_gold = MsgAdapter.ReadLL()
		vo.gold_worker_num = MsgAdapter.ReadInt()
		vo.singer_num = MsgAdapter.ReadInt()
		vo.male_captive_num = MsgAdapter.ReadInt()
		vo.female_captive_num = MsgAdapter.ReadInt()
		self.source_item_list[i] = vo
	end
end

-- -------------------------------------跨服争霸----------------------------------------
--各国纪念碑数量
SCFBInfo = SCFBInfo or BaseClass(BaseProtocolStruct)
function SCFBInfo:__init()
	self.msg_type = 16002
	self.monument_list = {}
end

function SCFBInfo:Decode()
	for i = 0, GameEnum.MAX_CAMP_NUM do
		self.monument_list[i] = MsgAdapter.ReadInt()      	--各国纪念碑数量
	end
	self.treasure_num = MsgAdapter.ReadInt()				--宝箱数量
end

------跨服玩家单个场景信息
SCRoleDakuafuParam = SCRoleDakuafuParam or BaseClass(BaseProtocolStruct)
function SCRoleDakuafuParam:__init()
	self.msg_type = 16003
	self.item_list = {}
end

function SCRoleDakuafuParam:Decode()
	self.seq = MsgAdapter.ReadInt()
	local list = {}
	list.dakuafu_kill_num = MsgAdapter.ReadInt()
	list.dakuafu_dead_num = MsgAdapter.ReadInt()
	list.dakuafu_kill_jinianbei_num = MsgAdapter.ReadInt()
	list.cross_rongyao = MsgAdapter.ReadInt()						--今日获取荣耀值
	list.rongyao_reward_list_seq = MsgAdapter.ReadChar()			--奖励领取状态
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	MsgAdapter.ReadChar()
	list.guaji_kill_num = MsgAdapter.ReadInt()						--挂机当前击杀次数
	list.guaji_today_remain_num = MsgAdapter.ReadInt()				--今日剩余挂机击杀次数
	list.guaji_yesterday_remain_num = MsgAdapter.ReadInt()			--昨日剩余次数
	for i = 0, 63 do
		MsgAdapter.ReadChar()
	end
	self.item_list[self.seq] = list
end

--场景跨服玩家所有信息
SCFBAllMessage = SCFBAllMessage or BaseClass(BaseProtocolStruct)
function SCFBAllMessage:__init()
	self.msg_type = 16004
	self.item_list = {}
end

function SCFBAllMessage:Decode()
	for i = 0, 9 do
		local list = {}
		list.dakuafu_kill_num = MsgAdapter.ReadInt()        	--击杀次数
		list.dakuafu_dead_num = MsgAdapter.ReadInt()			--死亡次数
		list.dakuafu_kill_jinianbei_num = MsgAdapter.ReadInt() 	--击杀纪念碑次数
		list.cross_rongyao = MsgAdapter.ReadInt()				--该场景获得的荣耀
		list.rongyao_reward_list_seq = MsgAdapter.ReadChar()	--奖励领取状态
		MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		MsgAdapter.ReadChar()
		list.guaji_kill_num = MsgAdapter.ReadInt()						--挂机当前击杀次数
		list.guaji_today_remain_num = MsgAdapter.ReadInt()				--今日剩余挂机击杀次数
		list.guaji_yesterday_remain_num = MsgAdapter.ReadInt()			--昨日剩余次数
		for i = 0, 63 do
			MsgAdapter.ReadChar()
		end
		self.item_list[i] = list
	end
	self.time = MsgAdapter.ReadUInt(32)		--上次打开的时间戳
	self.open_num = MsgAdapter.ReadInt()	--打开宝箱的数量
end

-- 大跨服BOSS信息
SCBossInfo = SCBossInfo or BaseClass(BaseProtocolStruct)
function SCBossInfo:__init()
	self.msg_type = 16005
	self.camp_hurt_list = {}
end

function SCBossInfo:Decode()
	self.boss_id = MsgAdapter.ReadUShort()
	self.blong_camp = MsgAdapter.ReadChar()
	self.exist = MsgAdapter.ReadChar()
	for i = 0, 3 do
		self.camp_hurt_list[i] = MsgAdapter.ReadInt()
	end
	self.boss_hp = MsgAdapter.ReadInt()
	self.first_hurt = MsgAdapter.ReadStrN(32)
end

--大跨服BOSS任务信息
BossTaskInfo = BossTaskInfo or BaseClass(BaseProtocolStruct)
function BossTaskInfo:__init()
	self.msg_type = 16006
	self.user_list = {}
end

function BossTaskInfo:Decode()
	self.next_refresh_timetamp = MsgAdapter.ReadUInt()
	self.belong_camp = MsgAdapter.ReadChar()
	self.is_exist = MsgAdapter.ReadChar()
	MsgAdapter.ReadShort()
	for i = 0, 2 do
		self.user_list[i] ={}
		self.user_list[i].user_name = MsgAdapter.ReadStrN(32)
		self.user_list[i].user_plat_type = MsgAdapter.ReadInt()
	end
end

-- 大跨服天降好礼信息
SCGiftinfo = SCGiftinfo or BaseClass(BaseProtocolStruct)
function SCGiftinfo:__init()
	self.msg_type = 16007
end

function SCGiftinfo:Decode()
	self.time = MsgAdapter.ReadUInt(32)		--上次打开的时间戳
	self.collect_num = MsgAdapter.ReadInt()	--才采集次数
	self.collect_max = MsgAdapter.ReadInt() --采集总数
end

-- 跨服密道boss信息
SCCrossMiDaoInfo = SCCrossMiDaoInfo or BaseClass(BaseProtocolStruct)
function SCCrossMiDaoInfo:__init()
	self.msg_type = 16020
end

function SCCrossMiDaoInfo:Decode()
	self.midao_info_list = {}
	for i = 1, SERVER_GROUP_TYPE.SERVER_GROUP_TYPE_MAX do
		local vo = {}
		vo.group_type = MsgAdapter.ReadChar()			-- 阵营
		vo.channel_state = MsgAdapter.ReadChar()		-- 己方密道状态(0开启,1关闭:再开cd中,2可以开启,3其他)
		vo.jiangong_state = MsgAdapter.ReadChar()		-- 对方监工boss状态
		vo.zhuguan_state = MsgAdapter.ReadChar()		-- 对方主管boss状态
		self.midao_info_list[i] = vo
	end
end