
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
	self.is_self_hunyan = MsgAdapter.ReadInt()				-- 是否自己的婚宴(1 是)
	self.paohuoqiu_timestmp = MsgAdapter.ReadUInt()			-- 开始抛花球的时间戳	
	self.paohuoqiu_times = MsgAdapter.ReadShort()			-- 抛花球次数(喜糖)
	self.guest_bless_free_times = MsgAdapter.ReadShort()	-- 宾客祝福免费次数
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

-- 播放烟花次数协议下发
-- SCHunyanGuestInfo = SCHunyanGuestInfo or BaseClass(BaseProtocolStruct)
-- function SCHunyanGuestInfo:__init()
-- 	self.msg_type = 6009
-- 	self.yanhua_count = 0
-- 	self.reserve_sh = 0
-- end

-- function SCHunyanGuestInfo:Decode()
-- 	self.yanhua_count = MsgAdapter.ReadShort()
-- 	self.reserve_sh = MsgAdapter.ReadShort()
-- end

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

-- 婚宴人气值
SCHunyanCommonInfo = SCHunyanCommonInfo or BaseClass(BaseProtocolStruct)
function SCHunyanCommonInfo:__init()
	self.msg_type = 6013

	self.renqi_values = 0
end

function SCHunyanCommonInfo:Decode()
	self.renqi_values = MsgAdapter.ReadInt()			-- 婚宴人气值
end
