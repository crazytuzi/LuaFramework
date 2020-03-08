if 1 then
	return
end


Debris.SAVE_GROUP = 10;
Debris.KEY_AVOID_BEGIN = 1; --面战时间的开始时间
Debris.KEY_AVOID_DUR   = 2; --持续时间S

Debris.AysncTop1From = 4;  --异步数据最高档的起始位 和C里一致
Debris.AysncTop2From = 14; --异步数据第二高档的起始位
Debris.AysncKeyUse = 20; --实际用了21个异步key


--配置只能是从低档的到高档的填， --同档次的写到一起
Debris.tbSettingLevel = 
{
	{ 
		--T1装备
		nNum = 3,  --需要合成碎片数
		tbItems = {1022, 1032, 1042, 1052, 1062, 1072, 1082, 1092, 1102, 1112}, --能合成的道具 --每档不能超过10个，因为异步数据的原因
		nFlipCardSetIndex = 1, --翻牌设置
		nAvoidRobTime = 3600, --该碎片被抢夺后自动获得的免战时间
		nRobProb = 1.875, --原始抢夺到碎片概率, 翻牌的话几率是其一半
		nValue = 5333,
	},
	{ 
		--T2装备
		nNum = 4,  
		tbItems = {1023, 1033, 1043, 1053, 1063, 1073, 1083, 1093, 1103, 1113},
		nFlipCardSetIndex = 2, 
		nAvoidRobTime = 3600 * 2,
		nRobProb = 1.25,
		nValue = 8000,	
	},
	{ 
		--T3装备
		nNum = 4,  
		tbItems = {1024, 1034, 1044, 1054, 1064, 1074, 1084, 1094, 1104, 1114},
		nFlipCardSetIndex = 3, 
		nAvoidRobTime = 3600 * 4,
		nRobProb = 0.625,
		nValue = 16000,
	},
	{ 
		--T4装备
		nNum = 5,  
		tbItems = {1025, 1035, 1045, 1055, 1065, 1075, 1085, 1095, 1105, 1115},
		nFlipCardSetIndex = 4, 
		nAvoidRobTime = 3600 * 6,
		nRobProb = 0.3125,
		nValue = 32000,
	},
	{ 
		--T5装备
		nNum = 5,  
		tbItems = {1026, 1036, 1046, 1056, 1066, 1076, 1086, 1096, 1106, 1116},
		nFlipCardSetIndex = 5, 
		nAvoidRobTime = 3600 * 12,
		nRobProb = 0.1875,
		nValue = 80000,
	},
	{ 
		--T6装备
		nNum = 6,  
		tbItems = {1027, 1037, 1047, 1057, 1067, 1077, 1087, 1097, 1107, 1117},
		nFlipCardSetIndex = 6, 
		nAvoidRobTime = 3600 * 24,
		nRobProb = 0.125,
		nValue = 160000,	
	},
};

-- 类型			道具ID		道具数量		
-- {"item", 	110, 		1, 		
-- {"Coin",		100},

Debris.tbFipCardSetting = {
	--T1翻盘池
	{ 		
		{ Award = 0, 			     nProb = 0.6 }, --0 对应碎片 需填第一位  这个是翻玩家的牌，翻npc的牌子时几率是其一半 ,另一半当是抢的
		{ Award = {"item", 1021, 1}, nProb = 0.06 },
		{ Award = {"item", 1020, 1}, nProb = 0.08 },
		{ Award = {"Coin", 1000},	 nProb = 0.1 },
		{ Award = {"Coin", 500},	 nProb = 0.08 },
		{ Award = {"Coin", 300},	 nProb = 0 },
		{ Award = {"item", 601,  1}, nProb = 0.08 },
	},	
	--T2翻盘池
	{ 	
		{ Award = 0, 			     nProb = 0.6 },
		{ Award = {"item", 1021, 1}, nProb = 0.08 },
		{ Award = {"item", 1020, 1}, nProb = 0.1 },
		{ Award = {"Coin", 1000},	 nProb = 0.08 },
		{ Award = {"Coin", 500},	 nProb = 0.06 },
		{ Award = {"Coin", 300},	 nProb = 0 },
		{ Award = {"item", 601,  1}, nProb = 0.08 },
	},	
	--T3翻盘池
	{ 	
		{ Award = 0, 			     nProb = 0.4375 },
		{ Award = {"item", 1021, 1}, nProb = 0.1 },
		{ Award = {"item", 1020, 1}, nProb = 0.1 },
		{ Award = {"Coin", 1000},	 nProb = 0.085 },
		{ Award = {"Coin", 500},	 nProb = 0.0888 },
		{ Award = {"Coin", 300},	 nProb = 0.0687 },
		{ Award = {"item", 601,  1}, nProb = 0.12 },
	},	
	--T4翻盘池
	{ 	
		{ Award = 0, 			     nProb = 0.25 },
		{ Award = {"item", 1021, 1}, nProb = 0.08 },
		{ Award = {"item", 1020, 1}, nProb = 0.15 },
		{ Award = {"Coin", 1000},	 nProb = 0.07 },
		{ Award = {"Coin", 500},	 nProb = 0.1 },
		{ Award = {"Coin", 300},	 nProb = 0.15 },
		{ Award = {"item", 601,  1}, nProb = 0.2 },
	},	
	--T5翻盘池
	{ 	
		{ Award = 0, 			     nProb = 0.11 },
		{ Award = {"item", 1021, 1}, nProb = 0.05 },
		{ Award = {"item", 1020, 1}, nProb = 0.2 },
		{ Award = {"Coin", 1000},	 nProb = 0.0828 },
		{ Award = {"Coin", 500},	 nProb = 0.1502 },
		{ Award = {"Coin", 300},	 nProb = 0.207 },
		{ Award = {"item", 601,  1}, nProb = 0.2 },
	},	
	--T6翻盘池
	{ 	
		{ Award = 0, 			     nProb = 0.075 },
		{ Award = {"item", 1021, 1}, nProb = 0.04 },
		{ Award = {"item", 1020, 1}, nProb = 0.2 },
		{ Award = {"Coin", 1000},	 nProb = 0.12 },
		{ Award = {"Coin", 500},	 nProb = 0.1525 },
		{ Award = {"Coin", 300},	 nProb = 0.2125 },
		{ Award = {"item", 601,  1}, nProb = 0.2 },
	},
}

--目前根据界面只能是3个，如需动态则需改界面
Debris.tbBuyAvoidRobSet = {
		--类型  免战时间 消耗道具id， 消耗个数
	[1] = {"item", 3600 * 2,  1020, 1};
	[2] = {"item", 3600 * 8,  1021, 1};
	[3] = {"Gold", 3600 * 12, { {1, 10}, {19, 10}, {20, 20}, {39, 20}, {40, 30}, {59, 30}, {60, 40}, {79, 40}, {80, 50}}}; --等级，消耗的元宝，其他等级在之间差值
}

function Debris:GetProbFactor(nHonorMinus) --nHonorMinus = his.nHonorLevel - me.nHonorLevel
	if nHonorMinus <= -2 then
		return 0.4
	elseif nHonorMinus == -1 then
		return 0.6
	elseif nHonorMinus == 0 then
		return 1
	else
		return 2.4
	end
end

--再根据上面的生成道具的index索引
Debris.tbItemIndex = {};

local function CheckSetingInvalid()
	for i,v in ipairs(Debris.tbFipCardSetting) do
		local nLastProb = 0
		for i2, v2 in ipairs(v) do
			v2.nProb = nLastProb + v2.nProb
			nLastProb = v2.nProb
		end
		assert(math.abs( nLastProb - 1) <= 0.001, i.." but " ..nLastProb)
	end

	for i,v in ipairs(Debris.tbSettingLevel) do
		assert(#v.tbItems <= 10, i);
		assert(v.nNum <= 32, i)
		local tbCard = Debris.tbFipCardSetting[v.nFlipCardSetIndex]
		assert(tbCard, i);

		for i2, v2 in ipairs(v.tbItems) do
			Debris.tbItemIndex[v2] = i;
		end

	end
end
CheckSetingInvalid();

--没有0-10点的 指定天秒数 --因为是针对现实中的 传过来的time先加上时差就好了
local fnGet14HTime = function (nTime)
	local nDay = math.floor(nTime / (3600 * 24));
	local nPassTime = nTime - 3600 * 24 * nDay - 3600 * 10
	nPassTime = nPassTime < 0 and 0 or nPassTime
	return 3600 * 14 * nDay + nPassTime
end

--计算时间方式2 正确的
function Debris:GetAvoidRobLeftTime(nBeginTime, nDuraTime, nTimeNow)
	nTimeNow = nTimeNow + Lib:GetGMTSec();
	nBeginTime = nBeginTime + Lib:GetGMTSec();
	nTimeNow = fnGet14HTime(nTimeNow)
	nBeginTime = fnGet14HTime(nBeginTime)
	local nLeftTime =  nBeginTime + nDuraTime - nTimeNow
	nLeftTime = nLeftTime < 0 and 0 or nLeftTime
	return nLeftTime
end

--免战停止时间
function Debris:GetAvoidRobEndTime(nBeginTime, nDuraTime)
	local nBeginDay = Lib:GetLocalDay(nBeginTime)
	local nBeginPassSecs = Lib:GetLocalDayTime(nBeginTime) ---开始计时的那天过去的秒数
	
	nBeginPassSecs = nBeginPassSecs - 36000
	nBeginPassSecs = nBeginPassSecs > 0 and nBeginPassSecs or 0

	nDuraTime = nDuraTime + nBeginPassSecs
	local nDuraDays = math.floor(nDuraTime / (3600 * 14)) 
	nDuraTime = nDuraTime - nDuraDays * 3600 * 14

	return nBeginTime - nBeginPassSecs + nDuraTime + nDuraDays * 3600 * 24
end

--根据结束时间反算当前时间下持续时间有多久
function Debris:GetAvoidRobBeginTime(nEndTime, nTimeNow)
	if nEndTime < nTimeNow then
		return 0;
	end
	local nEndDay = Lib:GetLocalDay(nEndTime)
	local nEndPassSecs = Lib:GetLocalDayTime(nEndTime) ---开始计时的那天过去的秒数

	nEndPassSecs = nEndPassSecs - 36000
	nEndPassSecs = nEndPassSecs > 0 and nEndPassSecs or 0

	local nToday = Lib:GetLocalDay(nTimeNow)
	local nTodaySecs = Lib:GetLocalDayTime(nTimeNow)
	nTodaySecs = nTodaySecs - 36000
	nTodaySecs = nTodaySecs > 0 and nTodaySecs or 0

	return nEndPassSecs  - nTodaySecs + (nEndDay - nToday) * 14 * 3600
end

--获取碎片对应价值量
function Debris:GetItemValue(nItemId)
	local nKind = self.tbItemIndex[nItemId]
	if not nKind then
		return 0
	end
	return	self.tbSettingLevel[nKind].nValue
end