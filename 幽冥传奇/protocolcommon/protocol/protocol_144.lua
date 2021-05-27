-------------------------------------------------------------
-- 请求
-------------------------------------------------------------
--请求 跨服活动数据
CSCrossActDataReq = CSCrossActDataReq or BaseClass(BaseProtocolStruct)
function CSCrossActDataReq:__init()
	self:InitMsgType(144, 1)
end

function CSCrossActDataReq:Encode()
	self:WriteBegin()
end

-- 请求 进入跨服
CSJoinCrossServerReq = CSJoinCrossServerReq or BaseClass(BaseProtocolStruct)
function CSJoinCrossServerReq:__init()
	self:InitMsgType(144, 2)
	self.cross_server_type = 0	-- 跨服副本索引,1 蓬莱仙界 2 烈焰幻境 3 龙魂圣域 4 圣兽宫 5 轮回地狱
	self.entrance_index = 0		-- 场景索引
end

function CSJoinCrossServerReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.cross_server_type)
	MsgAdapter.WriteUChar(self.entrance_index)
end

-- 请求 退出跨服
CSQuitCrossServerReq = CSQuitCrossServerReq or BaseClass(BaseProtocolStruct)
function CSQuitCrossServerReq:__init()
	self:InitMsgType(144, 3)
end

function CSQuitCrossServerReq:Encode()
	self:WriteBegin()
end

-- 请求 翻牌 操作(返回 144 4)
CSCrossTurnBrandReq = CSCrossTurnBrandReq or BaseClass(BaseProtocolStruct)
function CSCrossTurnBrandReq:__init()
	self:InitMsgType(144, 4)
	self.opt_type = 0
	self.brand_index = 0
end

function CSCrossTurnBrandReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.opt_type)
	if self.opt_type == 1 then -- 请求翻牌 发送索引
		MsgAdapter.WriteUChar(self.brand_index)
	end
end

-- 请求 跨服转盘 操作(返回 144 7)
CSRotaryTableReq = CSRotaryTableReq or BaseClass(BaseProtocolStruct)
function CSRotaryTableReq:__init()
	self:InitMsgType(144, 7)
	self.index = 0 -- 1 获取转盘信息 2 抽奖
end

function CSRotaryTableReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

-- 请求"轮回地狱"操作 返回(144, 8)
CSRebirthHellrDataReq = CSRebirthHellrDataReq or BaseClass(BaseProtocolStruct)
function CSRebirthHellrDataReq:__init()
	self:InitMsgType(144, 8)
	self.index = 0 -- 1 购买次数 2 获取信息
end

function CSRebirthHellrDataReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

-- 请求"龙魂圣域"操作 返回(144, 9)
CSDragonSoulDataReq = CSDragonSoulDataReq or BaseClass(BaseProtocolStruct)
function CSDragonSoulDataReq:__init()
	self:InitMsgType(144, 9)
	self.index = 0 -- 1 请求面板信息 2 购买击杀次数
end

function CSDragonSoulDataReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

-- 请求"圣兽宫殿"次数 返回(144, 10)
CSBeastPalaceNumberReq = CSBeastPalaceNumberReq or BaseClass(BaseProtocolStruct)
function CSBeastPalaceNumberReq:__init()
	self:InitMsgType(144, 10)
	self.index = 0 -- 1 请求面板信息 2 购买击杀次数
end

function CSBeastPalaceNumberReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end

-- 请求"烈焰幻境"数据 返回(144, 11)
CSFireVisionDataReq = CSFireVisionDataReq or BaseClass(BaseProtocolStruct)
function CSFireVisionDataReq:__init()
	self:InitMsgType(144, 11)
	self.index = 0 -- 1 请求面板信息 2 购买击杀次数
end

function CSFireVisionDataReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.index)
end


-- 请求蓬莱仙界信息/购买击杀次数
CSCrossServerBossPengLai = CSCrossServerBossPengLai or BaseClass(BaseProtocolStruct)
function CSCrossServerBossPengLai:__init()
	self:InitMsgType(144, 12)
	self.req_type = 0 --请求类型 1请求面板信息，2购买击杀次数
end

function CSCrossServerBossPengLai:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.req_type)
end

-- 发送祈福请求 返回(144, 13) 
CSCrossServerPrayReq = CSCrossServerPrayReq or BaseClass(BaseProtocolStruct)
function CSCrossServerPrayReq:__init()
	self:InitMsgType(144, 13)
	self.fuben_index = 0 -- 副本索引 1 烈焰  2 龙魂
	self.pray_type = 0 -- 祈福类型 1 免费祈福  2 元宝祈福
end

function CSCrossServerPrayReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.fuben_index)
	MsgAdapter.WriteUChar(self.pray_type)
end

-- 发送神豪殿的请求 返回(144, 14)
CSCrossTemplesReq = CSCrossTemplesReq or BaseClass(BaseProtocolStruct)
function CSCrossTemplesReq:__init()
	self:InitMsgType(144, 14)
	self.req_type = 0 -- 1 购买  2 获取信息
end

function CSCrossTemplesReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUChar(self.req_type)
end

-------------------------------------------------------------
-- 下发
-------------------------------------------------------------
-- 下发 跨服boss列表
SCCrossServerBossList = SCCrossServerBossList or BaseClass(BaseProtocolStruct)
function SCCrossServerBossList:__init()
	self:InitMsgType(144, 1)
end

function SCCrossServerBossList:Decode()
end

-- 下发 进入跨服boss
SCJoinCrossServerBoss = SCJoinCrossServerBoss or BaseClass(BaseProtocolStruct)
function SCJoinCrossServerBoss:__init()
	self:InitMsgType(144, 2)
end

function SCJoinCrossServerBoss:Decode()
end

-- 成功返回 六界入口相关操作 结果
SCJoinCrossFubenResult = SCJoinCrossFubenResult or BaseClass(BaseProtocolStruct)
function SCJoinCrossFubenResult:__init()
	self:InitMsgType(144, 3)
	self.entrance_index = 0	-- (uchar)选择的入口, 对应配置顺序
	self.opt_type = 0		-- (uchar)操作类型, 1进入副本 2退出副本
end

function SCJoinCrossFubenResult:Decode()
	self.entrance_index = MsgAdapter.ReadUChar()
	self.opt_type = MsgAdapter.ReadUChar()
end

-- -- 返回 翻牌 操作
-- SCCrossBrandInfo = SCCrossBrandInfo or BaseClass(BaseProtocolStruct)
-- function SCCrossBrandInfo:__init()
-- 	self:InitMsgType(144, 4)
-- 	self.fuben_index = 0
-- 	self.flop_info = 0
-- 	self.prize_pool_index_data = 0
-- 	self.item_index_data = 0
-- 	self.brand_index = 0
-- 	self.brand_num = 0
-- 	self.brands_data = {}
-- end

-- function SCCrossBrandInfo:Decode()
-- 	self.fuben_index = MsgAdapter.ReadUChar()
-- 	self.flop_info = MsgAdapter.ReadUInt()
-- 	self.prize_pool_index_data = MsgAdapter.ReadUInt()
-- 	self.item_index_data = MsgAdapter.ReadUInt()
-- 	self.brand_index = MsgAdapter.ReadUChar()
-- end

-- 返回 翻牌 操作
SCCrossBrandInfo = SCCrossBrandInfo or BaseClass(BaseProtocolStruct)
function SCCrossBrandInfo:__init()
	self:InitMsgType(144, 4)
	self.flop_num = 0
	self.brands_data = {}
	self.flop_record = ""
	self.flop_opt = 0
	self.is_can_draw = 0
end

function SCCrossBrandInfo:Decode()
	self.flop_num = MsgAdapter.ReadInt()
	self.brands_data = {}
	for i = 1, MsgAdapter.ReadUChar() do
		self.brands_data[#self.brands_data + 1] = {
			card_idx = MsgAdapter.ReadUChar(),
			pool_idx = MsgAdapter.ReadUChar(),
			item_index = MsgAdapter.ReadUChar(),
		}
	end
	self.flop_record = MsgAdapter.ReadStr()
	self.flop_opt = MsgAdapter.ReadUChar()
	self.is_can_draw = MsgAdapter.ReadUChar() == 1
end

-- 下发 六界入口状态
SCCrossServerEntrnceState = SCCrossServerEntrnceState or BaseClass(BaseProtocolStruct)
function SCCrossServerEntrnceState:__init()
	self:InitMsgType(144, 5)
	self.entrance_state = 0			-- 是否开启, false\0 不可以 true\1 可以
end

function SCCrossServerEntrnceState:Decode()
	self.entrance_state = MsgAdapter.ReadUChar()
end

-- 接收"跨服转盘"处理 请求(144, 7)
SCRotaryTableResults = SCRotaryTableResults or BaseClass(BaseProtocolStruct)
function SCRotaryTableResults:__init()
	self:InitMsgType(144, 7)
	self.type = 0			-- 操作类型, 1请求剩余次数 2单次抽奖
	self.jackpot = 0 		-- 当前元宝池[图片]
	self.number = 0			-- 剩余次数
	self.record_str = ""	-- 中奖记录
	self.show_index = 0 	-- 显示索引
	self.index = 0 			-- 中奖索引
end

function SCRotaryTableResults:Decode()
	self.index = 0
	self.type = MsgAdapter.ReadUChar()
	if self.type == 3 then
		self.number = MsgAdapter.ReadUChar()
	else
		self.jackpot = MsgAdapter.ReadUInt()
		self.record_str = MsgAdapter.ReadStr()
		self.show_index = MsgAdapter.ReadUShort()
		self.number = MsgAdapter.ReadUChar()
		if self.type == 2 then
			self.index = MsgAdapter.ReadUChar()
		end
	end
end

-- 接收"轮回地狱"数据 请求(144, 8)
SCRebirthHellData = SCRebirthHellData or BaseClass(BaseProtocolStruct)
function SCRebirthHellData:__init()
	self:InitMsgType(144, 8)
	self.buy_num = 0			-- 当天的购买过的次数
	self.free_num = 0			-- 已击杀的免费次数
	self.residue_num = 0 		-- 剩余的收费击杀次数
end

function SCRebirthHellData:Decode()
	MsgAdapter.ReadUChar()
	self.buy_num = MsgAdapter.ReadUChar()
	self.free_num = MsgAdapter.ReadUShort()
	self.residue_num = MsgAdapter.ReadUShort()
end

-- 接收"龙魂圣域"数据 请求(144, 9)
SCDragonSoulData = SCDragonSoulData or BaseClass(BaseProtocolStruct)
function SCDragonSoulData:__init()
	self:InitMsgType(144, 9)
	self.free_num = 0	-- 免费次数
	self.pqy_num = 0	-- 收费次数
	self.blessing = 0 	-- 祝福值
end

function SCDragonSoulData:Decode()
	self.free_num = MsgAdapter.ReadUShort()
	self.pqy_num = MsgAdapter.ReadUShort()
	self.blessing = MsgAdapter.ReadUShort()
end

-- 接收"圣兽宫殿"次数 请求(144, 10)
SCBeastPalaceNumber = SCBeastPalaceNumber or BaseClass(BaseProtocolStruct)
function SCBeastPalaceNumber:__init()
	self:InitMsgType(144, 10)
	self.free_num = 0			-- 免费次数
	self.pqy_num = 0			-- 收费次数
end

function SCBeastPalaceNumber:Decode()
	self.free_num = MsgAdapter.ReadUShort()
	self.pqy_num = MsgAdapter.ReadUShort()
end

-- 接收"烈焰幻境"数据 请求(144, 11)
SCFireVisionData = SCFireVisionData or BaseClass(BaseProtocolStruct)
function SCFireVisionData:__init()
	self:InitMsgType(144, 11)
	self.free_num = 0	-- 免费次数
	self.pqy_num = 0	-- 收费次数
	self.blessing = 0 	-- 祝福值
end

function SCFireVisionData:Decode()
	self.free_num = MsgAdapter.ReadUShort()
	self.pqy_num = MsgAdapter.ReadUShort()
	self.blessing = MsgAdapter.ReadUShort()
end

-- 返回蓬莱仙界剩余击杀boss次数、翻牌信息 请求(144 12)
SCPengLaiFairylandInfo = SCPengLaiFairylandInfo or BaseClass(BaseProtocolStruct)
function SCPengLaiFairylandInfo:__init()
	self:InitMsgType(144, 12)
	self.remaining_can_kill_boss_times = 0
	-- self.flop_info = 0
	-- self.brands_data = {}
end

function SCPengLaiFairylandInfo:Decode()
	self.remaining_can_kill_boss_times = MsgAdapter.ReadUShort()
	-- self.flop_info = MsgAdapter.ReadUInt()
	-- local brand_num = #PengLaiXianJieCfg.allCards
	-- for i = 1, brand_num do 
	-- 	local award_info = MsgAdapter.ReadInt()
	-- 	self.brands_data[i] = {prize_pool_index = bit:_and(award_info, 0xffff) or 0, item_index = bit:_rshift(award_info, 16) or 0}
	-- end
end

-- 返回祈福结果 请求(144, 13)
-- SCCrossServerPrayResult = SCCrossServerPrayResult or BaseClass(BaseProtocolStruct)
-- function SCCrossServerPrayResult:__init()
-- 	self:InitMsgType(144, 13)
-- 	self.fuben_index = 0 -- 副本索引 1 烈焰  2 龙魂
-- 	self.pray_value = 0 -- 剩余祈福次数
-- end

-- function SCCrossServerPrayResult:Decode()
-- 	self.fuben_index = MsgAdapter.ReadUChar()
-- 	self.pray_value = MsgAdapter.ReadUShort()
-- end

 --返回神豪殿结果 请求(144, 14)
 SCCrossTemplesInfo = SCCrossTemplesInfo or BaseClass(BaseProtocolStruct)
 function SCCrossTemplesInfo:__init()
 	self:InitMsgType(144, 14)
 	self.count = 0
 	self.buy_times = 0	--已购买次数
 end

 function SCCrossTemplesInfo:Decode()
 	self.count = MsgAdapter.ReadUChar()
 	self.buy_times = MsgAdapter.ReadUChar()
 end
