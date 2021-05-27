--=======================请求消息============
--获取vip信息(返回54 2)
CSGetVIPInfoReq = CSGetVIPInfoReq or BaseClass(BaseProtocolStruct)
function CSGetVIPInfoReq:__init()
	self:InitMsgType(54, 1)
end

function CSGetVIPInfoReq:Encode()
	self:WriteBegin()
end

--获取vip奖励(返回54 8)
CSGetVIPRewardsReq = CSGetVIPRewardsReq or BaseClass(BaseProtocolStruct)
function CSGetVIPRewardsReq:__init()
	self:InitMsgType(54, 3)
	self.lev_reward = 0            --(uchar)要获得的等级奖励
end
function CSGetVIPRewardsReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.lev_reward)
end

-- 请求挑战vip关卡
CSChallengeVipBossReq = CSChallengeVipBossReq or BaseClass(BaseProtocolStruct)
function CSChallengeVipBossReq:__init()
	self:InitMsgType(54, 5)
end

function CSChallengeVipBossReq:Encode()
	self:WriteBegin()
end


--获取vip等级奖励标记
CSGetVIPLevRewardsFlagReq = CSGetVIPLevRewardsFlagReq or BaseClass(BaseProtocolStruct)
function CSGetVIPLevRewardsFlagReq:__init()
	self:InitMsgType(54, 7)
end

function CSGetVIPLevRewardsFlagReq:Encode()
	self:WriteBegin()
end


--请求砖石会员等级奖励
CSGetZsVipAwardReq = CSGetZsVipAwardReq or BaseClass(BaseProtocolStruct)
function CSGetZsVipAwardReq:__init()
	self:InitMsgType(54, 8)
	self.gift_type = 0 -- 1专属礼包 2特惠礼包
	self.gift_level = 0
end

function CSGetZsVipAwardReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.gift_type)
	MsgAdapter.WriteUChar(self.gift_level)
end

--请求进入砖石会员地图
CSIntoZsVipMapReq = CSIntoZsVipMapReq or BaseClass(BaseProtocolStruct)
function CSIntoZsVipMapReq:__init()
	self:InitMsgType(54, 9)
	self.map_idx = 0 			--进入场景的配置索引，从1开始
end

function CSIntoZsVipMapReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.map_idx)
end

--------------------下发消息--------------------
--下发vip信息
SCIssueVIPInfo = SCIssueVIPInfo or BaseClass(BaseProtocolStruct)
function SCIssueVIPInfo:__init()
	self:InitMsgType(54, 2)
	self.all_server_vip_user_num = 0     		-- (int)全服vip用户数量
	self.daily_recv_reward_flag = 1	   		 	-- (uchar)每天领取的奖励标记, 1已领取, 0没领取
	self.vip_lev = 0                    	 	-- (uchar)vip等级
	self.recv_vip_reward_flag = {}	
	self.charge_total_yuanbao = 0	     		-- (uint64)充值总元宝
end

function SCIssueVIPInfo:Decode()
	self.all_server_vip_user_num = MsgAdapter.ReadInt()
	self.daily_recv_reward_flag = MsgAdapter.ReadUChar()
	self.vip_lev = MsgAdapter.ReadUChar()
	self.recv_vip_reward_flag = MsgAdapter.ReadUInt()
	self.charge_total_yuanbao = MsgAdapter.ReadLL()
end

--接收vip关卡信息
SCVipBossGuanInfo = SCVipBossGuanInfo or BaseClass(BaseProtocolStruct)
function SCVipBossGuanInfo:__init()
	self:InitMsgType(54, 5)
	self.guan_num = 0    -- 已挑战关卡数
	self.count = 0    -- 当前魄力值
end

function SCVipBossGuanInfo:Decode()
	self.guan_num = MsgAdapter.ReadUShort()
	self.count = MsgAdapter.ReadUShort()
end

--获取vip等级奖励标记
SCGetVIPLevRewardFlag = SCGetVIPLevRewardFlag or BaseClass(BaseProtocolStruct)
function SCGetVIPLevRewardFlag:__init()
	self:InitMsgType(54, 8)
	self.recv_vip_reward_flag = 0    -- (uint)领取VIP奖励标记, 每1位记录一个等级的领取标记, 1已领取, 0没有
end

function SCGetVIPLevRewardFlag:Decode()
	self.recv_vip_reward_flag = MsgAdapter.ReadUInt()
end


--下发砖石会员奖励领取情况
SCGetZsVIPLevRewardFlag = SCGetZsVIPLevRewardFlag or BaseClass(BaseProtocolStruct)
function SCGetZsVIPLevRewardFlag:__init()
	self:InitMsgType(54, 9)
	self.zs_reward_flag = 0    -- (uint)每1位记录一个等级的领取标记, 1已领取, 0没有
	self.th_reward_flag = 0    -- (uint)每1位记录一个等级的领取标记, 1已领取, 0没有
end

function SCGetZsVIPLevRewardFlag:Decode()
	self.zs_reward_flag = MsgAdapter.ReadUInt()
	self.th_reward_flag = MsgAdapter.ReadUInt()
end
