--===================================请求==================================

-- 挑战BOSS
CSKillBossReq = CSKillBossReq or BaseClass(BaseProtocolStruct)
function CSKillBossReq:__init()
	self:InitMsgType(49, 2)
	self.boss_id = 0
end

function CSKillBossReq:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.boss_id)
end

-- 获取天之BOSS击杀次数
CSGetSkyBossKillCount = CSGetSkyBossKillCount or BaseClass(BaseProtocolStruct)
function CSGetSkyBossKillCount:__init()
	self:InitMsgType(49, 3)
	self.boss_id = 0	
end

function CSGetSkyBossKillCount:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.boss_id)
end

-- 前往击杀天之BOSS
CSKillSkyBoss = CSKillSkyBoss or BaseClass(BaseProtocolStruct)
function CSKillSkyBoss:__init()
	self:InitMsgType(49, 4)
end

function CSKillSkyBoss:Encode()
	self:WriteBegin()
end

-- 前往魔界秘境
CSDevildomFam = CSDevildomFam or BaseClass(BaseProtocolStruct)
function CSDevildomFam:__init()
	self:InitMsgType(49, 5)
	self.fam_level = 0
end

function CSDevildomFam:Encode()
	self:WriteBegin()
	MsgAdapter.WriteUShort(self.fam_level)
end

-- 购买魔界秘境积分(返回49 5)
CSBuyDevildomFamIntegral = CSBuyDevildomFamIntegral or BaseClass(BaseProtocolStruct)
function CSBuyDevildomFamIntegral:__init()
	self:InitMsgType(49, 6)
end

function CSBuyDevildomFamIntegral:Encode()
	self:WriteBegin()
end

-- 查询魔界秘境积分(返回49 5)
CSGetDevildomFamIntegral = CSGetDevildomFamIntegral or BaseClass(BaseProtocolStruct)
function CSGetDevildomFamIntegral:__init()
	self:InitMsgType(49, 7)
end

function CSGetDevildomFamIntegral:Encode()
	self:WriteBegin()
end

-- 购买秘境积分所需费用(返回49 6)
CSBuyFamIntegralCost = CSBuyFamIntegralCost or BaseClass(BaseProtocolStruct)
function CSBuyFamIntegralCost:__init()
	self:InitMsgType(49, 8)
end

function CSBuyFamIntegralCost:Encode()
	self:WriteBegin()
end

-- 返回城镇
CSGoBackTown = CSGoBackTown or BaseClass(BaseProtocolStruct)
function CSGoBackTown:__init()
	self:InitMsgType(49, 9)
end

function CSGoBackTown:Encode()
	self:WriteBegin()
end

-- 前往神界废墟
CSEnterFeixuReq = CSEnterFeixuReq or BaseClass(BaseProtocolStruct)
function CSEnterFeixuReq:__init()
	self:InitMsgType(49, 10)
end

function CSEnterFeixuReq:Encode()
	self:WriteBegin()
end

-- 购买神力值
CSBugFeixuValReq = CSBugFeixuValReq or BaseClass(BaseProtocolStruct)
function CSBugFeixuValReq:__init()
	self:InitMsgType(49, 11)
end

function CSBugFeixuValReq:Encode()
	self:WriteBegin()
end

-- 查询神力值
CSFeixuInfoReq = CSFeixuInfoReq or BaseClass(BaseProtocolStruct)
function CSFeixuInfoReq:__init()
	self:InitMsgType(49, 12)
end

function CSFeixuInfoReq:Encode()
	self:WriteBegin()
end

-- 离开废墟
CSOutFeixuReq = CSOutFeixuReq or BaseClass(BaseProtocolStruct)
function CSOutFeixuReq:__init()
	self:InitMsgType(49, 13)
end

function CSOutFeixuReq:Encode()
	self:WriteBegin()
end

-- 前往击杀蚩尤
CSKillChiyouReq = CSKillChiyouReq or BaseClass(BaseProtocolStruct)
function CSKillChiyouReq:__init()
	self:InitMsgType(49, 14)
end

function CSKillChiyouReq:Encode()
	self:WriteBegin()
end

--===================================下发==================================

-- 返回天之BOSS的击杀次数
SCSkyBossKillCount = SCSkyBossKillCount or BaseClass(BaseProtocolStruct)
function SCSkyBossKillCount:__init()
	self:InitMsgType(49, 3)
	self.kill_count = 0
	self.boss_id = 0
end

function SCSkyBossKillCount:Decode()
	self.kill_count = MsgAdapter.ReadUChar()
	self.boss_id = MsgAdapter.ReadUShort()
end

-- 天之BOSS觉醒
SCSkyBossAwake = SCSkyBossAwake or BaseClass(BaseProtocolStruct)
function SCSkyBossAwake:__init()
	self:InitMsgType(49, 4)
	self.boss_id = 0
	self.is_sky_boss = -1
end

function SCSkyBossAwake:Decode()
	self.boss_id = MsgAdapter.ReadUShort()
	self.is_sky_boss = MsgAdapter.ReadUChar()
end

-- 魔界秘境积分
SCDevildomFamIntegral = SCDevildomFamIntegral or BaseClass(BaseProtocolStruct)
function SCDevildomFamIntegral:__init()
	self:InitMsgType(49, 5)
	self.fam_integral = 0
	self.buy_count = 0
	self.integral_cost = 0
	self.buy_integral = 0
end

function SCDevildomFamIntegral:Decode()
	self.fam_integral = MsgAdapter.ReadUShort()
	self.buy_count = MsgAdapter.ReadUShort()
	if self.buy_count > 0 then
		self.integral_cost = MsgAdapter.ReadUShort()
		self.buy_integral = MsgAdapter.ReadUShort()
	end
end

-- 前往魔界秘境
SCDevildomFam = SCDevildomFam or BaseClass(BaseProtocolStruct)
function SCDevildomFam:__init()
	self:InitMsgType(49, 10)
	self.is_enter = false
end

function SCDevildomFam:Decode()
	self.is_enter = true
end

-- 返回城镇
SCGoBackTown = SCGoBackTown or BaseClass(BaseProtocolStruct)
function SCGoBackTown:__init()
	self:InitMsgType(49, 9)
	self.is_enter = false
end

function SCGoBackTown:Decode()
end

-- 废墟信息
SCFeixuInfo = SCFeixuInfo or BaseClass(BaseProtocolStruct)
function SCFeixuInfo:__init()
	self:InitMsgType(49, 7)
	self.feixu_value = 0
	self.left_buy_times = 0
	self.buy_gold = 0
end

function SCFeixuInfo:Decode()
	self.feixu_value = MsgAdapter.ReadUShort()
	self.left_buy_times = MsgAdapter.ReadUChar()
	self.buy_gold = MsgAdapter.ReadUShort()
end

-- 离开废墟
SCOutFeixu = SCOutFeixu or BaseClass(BaseProtocolStruct)
function SCOutFeixu:__init()
	self:InitMsgType(49, 11)
end

function SCOutFeixu:Decode()
end

-- 进入废墟
SCEnterFeixu = SCEnterFeixu or BaseClass(BaseProtocolStruct)
function SCEnterFeixu:__init()
	self:InitMsgType(49, 12)
end

function SCEnterFeixu:Decode()
end
