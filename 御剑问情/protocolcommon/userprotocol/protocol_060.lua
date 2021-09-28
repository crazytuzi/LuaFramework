
--  结婚特效
SCMarrySpecialEffect = SCMarrySpecialEffect or BaseClass(BaseProtocolStruct)
function SCMarrySpecialEffect:__init()
	self.msg_type = 6003
	self.marry_type = 0 			--结婚类型
end

function SCMarrySpecialEffect:Decode()
	self.marry_type = MsgAdapter.ReadInt()
end

--  求婚信息转发给对方
SCMarryReqRoute = SCMarryReqRoute or BaseClass(BaseProtocolStruct)
function SCMarryReqRoute:__init()
	self.msg_type = 6004
	self.marry_type = 0 			--结婚类型
	self.req_uid = 0				--求婚人id
	self.GameName = ""				--名字
end

function SCMarryReqRoute:Decode()
	self.marry_type = MsgAdapter.ReadInt()
	self.req_uid = MsgAdapter.ReadInt()
	self.GameName = MsgAdapter.ReadStrN(32)
end

-- 接受离婚请求
SCDivorceReqRoute = SCDivorceReqRoute or BaseClass(BaseProtocolStruct)
function SCDivorceReqRoute:__init()
	self.msg_type = 6005
	self.req_uid = 0
	self.req_name = ""
end

function SCDivorceReqRoute:Decode()
	self.req_uid = MsgAdapter.ReadInt()
	self.req_name = MsgAdapter.ReadStrN(32)
end

--  婚宴播放烟花特效协议下发
SCMarryHunyanOpera = SCMarryHunyanOpera or BaseClass(BaseProtocolStruct)
function SCMarryHunyanOpera:__init()
	self.msg_type = 6008
	self.obj_id = 0 					--播放特效的人物
	self.opera_type = 0					--播放特效类型
	self.opera_param = 0
	self.reserve = 0
end

function SCMarryHunyanOpera:Decode()
	self.obj_id = MsgAdapter.ReadUShort()
	self.opera_type = MsgAdapter.ReadShort()
	self.opera_param = MsgAdapter.ReadShort()
	self.reserve = MsgAdapter.ReadShort()
end

--  婚宴信息
SCHunyanInfo = SCHunyanInfo or BaseClass(BaseProtocolStruct)
function SCHunyanInfo:__init()
	self.msg_type = 6009
end

function SCHunyanInfo:Decode()
	self.notify_reason = MsgAdapter.ReadInt()
	self.hunyan_state = MsgAdapter.ReadInt()				-- 婚宴状态 0无效 1准备 2开始 3结束
	self.next_state_timestmp = MsgAdapter.ReadUInt()		-- 时间戳 下一个状态的时间
	self.fb_key = MsgAdapter.ReadInt()						-- 婚宴副本的KEY
	self.yanhui_type = MsgAdapter.ReadInt()
	self.remainder_eat_food_num = MsgAdapter.ReadInt()
	local guest_count = MsgAdapter.ReadInt()
	self.is_first_diamond = MsgAdapter.ReadInt()
	self.is_self_hunyan = MsgAdapter.ReadInt()				--是否自己的婚宴(1 是)
	self.paohuoqiu_timestmp = MsgAdapter.ReadUInt()			--开始抛花球的时间戳
	self.today_gather_times = MsgAdapter.ReadInt()			--今天采集酒席的次数
	self.paohuaqiu_times = MsgAdapter.ReadShort()			--抛花球免费次数
	self.guest_bless_free_times = MsgAdapter.ReadShort()	--宾客祝福免费次数
	self.marryuser_list = {}
	for i = 1, 2 do
		local vo = {}
		vo.marry_uid = MsgAdapter.ReadInt()
		vo.marry_name = MsgAdapter.ReadStrN(32)
		vo.sex = MsgAdapter.ReadChar()
		vo.prof = MsgAdapter.ReadChar()
		vo.camp = MsgAdapter.ReadChar()
		vo.hongbao_count = MsgAdapter.ReadChar()			-- 发了多少次红包的数量
		vo.avatar_key_big = MsgAdapter.ReadInt()			-- long long avator_timestamp; 拆分成两个两个int型的
		vo.avatar_key_small = MsgAdapter.ReadInt()
		self.marryuser_list[i] = vo
	end
	self.guest_list = {}
	for i=1,guest_count do
		local guest = MsgAdapter.ReadInt()
		self.guest_list[i] = guest
	end
end

--婚宴采集酒席协议下发
SCHunyanGuestInfo = SCHunyanGuestInfo or BaseClass(BaseProtocolStruct)
function SCHunyanGuestInfo:__init()
	self.msg_type = 6010
end

function SCHunyanGuestInfo:Decode()
	self.yanhua_count = MsgAdapter.ReadShort()
	self.zhufu_count = MsgAdapter.ReadShort()
	self.saxianhua_count = MsgAdapter.ReadShort()
	self.hunyan_food_id_count = MsgAdapter.ReadShort()
	self.hunyan_food_id_list = {}
	if self.hunyan_food_id_count > 0 then
		for i = 1, self.hunyan_food_id_count do
			local obj_id = MsgAdapter.ReadUShort()
			self.hunyan_food_id_list[obj_id] = obj_id
		end
	end
end

--开启婚宴
CSHunyanStart = CSHunyanStart or BaseClass(BaseProtocolStruct)
function CSHunyanStart:__init()
	self.msg_type = 6011
	self.hunyan_type = 0
end

function CSHunyanStart:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.hunyan_type)
end

-- 通知全服结婚
SCMarryNotic = SCMarryNotic or BaseClass(BaseProtocolStruct)
function SCMarryNotic:__init()
	self.msg_type = 6013
end

function SCMarryNotic:Decode()
	self.uid1 = MsgAdapter.ReadInt()
	self.name1 = MsgAdapter.ReadStrN(32)
	self.avatar_key_big1 = MsgAdapter.ReadUInt()
	self.avatar_key_small1 = MsgAdapter.ReadUInt()
	self.prof1 = MsgAdapter.ReadInt()
	self.uid2 = MsgAdapter.ReadInt()
	self.name2 = MsgAdapter.ReadStrN(32)
	self.avatar_key_big2 = MsgAdapter.ReadUInt()
	self.avatar_key_small2 = MsgAdapter.ReadUInt()
	self.prof2 = MsgAdapter.ReadInt()
	self.server_marry_times = MsgAdapter.ReadInt()
end

-- 祝贺新人
CSMarryZhuheSend = CSMarryZhuheSend or BaseClass(BaseProtocolStruct)
function CSMarryZhuheSend:__init()
	self.msg_type = 6014
	self.uid = 0
	self.type = 0
end

function CSMarryZhuheSend:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.uid)
	MsgAdapter.WriteInt(self.type)
end

-- 新人收到祝贺
SCMarryZhuheShou = SCMarryZhuheShou or BaseClass(BaseProtocolStruct)
function SCMarryZhuheShou:__init()
	self.msg_type = 6015
end

function SCMarryZhuheShou:Decode()
	self.uid = MsgAdapter.ReadInt()
	self.name = MsgAdapter.ReadStrN(32)
	self.type = MsgAdapter.ReadInt()
end

-- 普通婚宴次数
SCMarryInfo = SCMarryInfo or BaseClass(BaseProtocolStruct)
function SCMarryInfo:__init()
	self.msg_type = 6016
end

function SCMarryInfo:Decode()
	self.today_putong_hunyan_times = MsgAdapter.ReadInt()
	self.today_total_open_hunyan_times = MsgAdapter.ReadInt()
	self.can_open = MsgAdapter.ReadInt()				--今日开启婚宴的次数
	self.has_marry_hunli_type_flag = MsgAdapter.ReadInt()	-- 已结婚礼类型标记
end

-- 当前批次花球时间戳
SCMarryPaoHuaQiuTs = SCMarryPaoHuaQiuTs or BaseClass(BaseProtocolStruct)
function SCMarryPaoHuaQiuTs:__init()
	self.msg_type = 6017
end

function SCMarryPaoHuaQiuTs:Decode()
	self.next_paohuaqiu_ts = MsgAdapter.ReadInt()			--下次刷新时间
end

---------------------------------情缘圣地----------------------------------
--情缘圣地操作请求
CSQingYuanShengDiOperaReq = CSQingYuanShengDiOperaReq or BaseClass(BaseProtocolStruct)
function CSQingYuanShengDiOperaReq:__init()
	self.msg_type = 6020
	self.opera_type = 0
	self.param = 0
end

function CSQingYuanShengDiOperaReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.opera_type)
	MsgAdapter.WriteInt(self.param)
end

-- 情缘圣地任务信息
SCQingYuanShengDiTaskInfo = SCQingYuanShengDiTaskInfo or BaseClass(BaseProtocolStruct)
function SCQingYuanShengDiTaskInfo:__init()
	self.msg_type = 6021
end

function SCQingYuanShengDiTaskInfo:Decode()
	self.is_fetched_task_other_reward = MsgAdapter.ReadChar()
	self.lover_is_all_task_complete = MsgAdapter.ReadChar()
	self.task_count = MsgAdapter.ReadShort()
	self.task_info_list = {}
	for i=1, self.task_count do
		local vo = {}
		vo.task_id = MsgAdapter.ReadUShort()
		vo.is_fetched_reward = MsgAdapter.ReadChar()
		vo.reserve = MsgAdapter.ReadChar()
		vo.param = MsgAdapter.ReadInt()
		vo.index = i - 1
		self.task_info_list[i] = vo
	end
end

SCQingYuanShengDiBossInfo = SCQingYuanShengDiBossInfo or BaseClass(BaseProtocolStruct)
function SCQingYuanShengDiBossInfo:__init()
	self.msg_type = 6022
end

function SCQingYuanShengDiBossInfo:Decode()
	self.boss_count = MsgAdapter.ReadInt()
	self.boss_list = {}
	for i=1, self.boss_count do
		local vo = {}
		vo.boss_id = MsgAdapter.ReadInt()
		vo.pos_x = MsgAdapter.ReadUShort()
		vo.pos_y = MsgAdapter.ReadUShort()
		vo.next_refresh_time = MsgAdapter.ReadUInt()
		self.boss_list[i] = vo
	end
end

--=======================================================================
-- 6023	限时礼包信息
SCQingyuanTimeLimitInfo = SCQingyuanTimeLimitInfo or BaseClass(BaseProtocolStruct)
function SCQingyuanTimeLimitInfo:__init()
	self.msg_type = 6023
	self.cur_purchased_seq = 0
end

function SCQingyuanTimeLimitInfo:Decode()
	self.cur_purchased_seq = MsgAdapter.ReadInt()
end

-- 6024	限时礼包购买通知
SCQingyuanTimeLimitGiftRemindInfo = SCQingyuanTimeLimitGiftRemindInfo or BaseClass(BaseProtocolStruct)
function SCQingyuanTimeLimitGiftRemindInfo:__init()
	self.msg_type = 6024
	self.openserver_day = 0
	self.buy_seq = 0
	self.is_open_panel = 0
end

function SCQingyuanTimeLimitGiftRemindInfo:Decode()
	self.openserver_day = MsgAdapter.ReadInt()
	self.buy_seq = MsgAdapter.ReadShort()
	self.is_open_panel = MsgAdapter.ReadShort()
end

-- 婚礼类型礼包购买
CSQingYuanBuyWeddingGiftBagReq = CSQingYuanBuyWeddingGiftBagReq or BaseClass(BaseProtocolStruct)
function  CSQingYuanBuyWeddingGiftBagReq:__init()
	self.msg_type = 6025
	self.marry_type = 0
end

function CSQingYuanBuyWeddingGiftBagReq:Encode()
	MsgAdapter.WriteBegin(self.msg_type)
	MsgAdapter.WriteInt(self.marry_type)
end