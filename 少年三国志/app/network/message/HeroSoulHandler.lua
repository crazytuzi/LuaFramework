local HandlerBase = require("app.network.message.HandlerBase")
local HeroSoulHandler = class("HeroSoulHandler", HandlerBase)

local BagConst = require("app.const.BagConst")

function HeroSoulHandler:ctor()

end


function HeroSoulHandler:initHandler( ... )
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetKsoul, self._recvSoulInfo, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_RecycleKsoul, self._recvDecomposeSoul, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ActiveKsoulGroup, self._recvActivateChart, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ActiveKsoulTarget, self._recvActivateAchievement, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetCommonRank, self._recvChartRank, self)
	-- 点将
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_SummonKsoul, self._recvSummonKsoul, self)
	-- 奇遇值买将灵
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_SummonKsoulExchange, self._recvSummonKsoulExchange, self)

	-- 名将试炼
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_KsoulDungeonInfo, self._recvKsoulDungeonInfo, self)
    uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_KsoulDungeonRefresh, self._recvKsoulDungeonRefresh, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_KsoulDungeonChallenge, self._recvKsoulDungeonChallenge, self)

	-- 商店
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_KsoulShopInfo, self._recvKsoulShopInfo, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_KsoulShopRefresh, self._recvKsoulShopRefresh, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_KsoulShopBuy, self._recvKsoulShopBuy, self)

	-- 底座
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_KsoulSetFightBase, self._recvSetFightBase, self)

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_USER_LEVELUP, self._doWithLevelup, self)
end

-- 玩家升级了，若到这个功能开启条件，则去拉一下基础协议
function HeroSoulHandler:_doWithLevelup()
	require("app.cfg.function_level_info")
	local FunctionLevelConst = require("app.const.FunctionLevelConst")
	local tFuncLevTmpl = function_level_info.get(FunctionLevelConst.HERO_SOUL)
	if tFuncLevTmpl then
		if tFuncLevTmpl.level == G_Me.userData.level then
			self:sendGetSoulInfo()
		end
	end
end

-- 请求将灵基础信息
function HeroSoulHandler:sendGetSoulInfo()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_GetKsoul", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_GetKsoul, msgBuf)
end

-- 收到将灵基础信息
function HeroSoulHandler:_recvSoulInfo(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetKsoul", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	G_Me.heroSoulData:setSoulInfo(decodeBuffer)
	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HERO_SOUL_GET_SOUL_INFO, nil, false)
end

-- 请求分解将灵
function HeroSoulHandler:sendDecomposeSoul(soulList)
	local buffer = { ksoul = soulList }
	local msgBuf = protobuf.encode("cs.C2S_RecycleKsoul", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_RecycleKsoul, msgBuf)
end

-- 分解将灵返回
function HeroSoulHandler:_recvDecomposeSoul(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_RecycleKsoul", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HERO_SOUL_DECOMPOSE, nil, false, decodeBuffer.ksoul_point)
	end
end

-- 请求激活阵图
function HeroSoulHandler:sendActivateChart(chartId)
	local buffer = { id = chartId }
	local msgBuf = protobuf.encode("cs.C2S_ActiveKsoulGroup", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_ActiveKsoulGroup, msgBuf)
end

-- 激活阵图返回
function HeroSoulHandler:_recvActivateChart(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_ActiveKsoulGroup", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.heroSoulData:setActivateChart(decodeBuffer.id)
	end
	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HERO_SOUL_ACTIVATE_CHART, nil, false, decodeBuffer)
end

-- 请求激活成就
function HeroSoulHandler:sendActivateAchievement(achieveId)
	local buffer = { id = achieveId }
	local msgBuf = protobuf.encode("cs.C2S_ActiveKsoulTarget", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_ActiveKsoulTarget, msgBuf)
end

-- 激活成就返回
function HeroSoulHandler:_recvActivateAchievement(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_ActiveKsoulTarget", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.heroSoulData:setActivateAchievement(decodeBuffer.id)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HERO_SOUL_ACTIVATE_ACHIEVEMENT, nil, false)
	end
end

-- 获取阵图排行
function HeroSoulHandler:sendGetChartRank(rankType)
	local buffer =
	{
		r_id = 1,			-- 1表示将灵模块排行
		r_type = rankType,
	}

	local msgBuf = protobuf.encode("cs.C2S_GetCommonRank", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_GetCommonRank, msgBuf)
end

-- 获取阵图排行成功
function HeroSoulHandler:_recvChartRank(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetCommonRank", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK and decodeBuffer.r_id == 1 then
		G_Me.heroSoulData:updateChartRanks(decodeBuffer)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HERO_SOUL_GET_CHART_RANK, nil, false, decodeBuffer.r_type)
	end
end
-----------------------------------------------------------------------------
-- 点将，奇遇
--[[
message C2S_SummonKsoul {
  required uint32 s_type = 1;//1免费 2单抽 3五连
}

message S2C_SummonKsoul {
  required uint32 ret = 1;
  required uint32 s_type = 2;
  repeated Award awards = 3;
  repeated Award scores = 4;
  optional uint32 free_summon = 5;//免费点将次数
  optional uint32 summon_score = 6;//点将点数
  optional uint32 summon_count = 7;//轮回内已经点将的次数
}


message C2S_SummonKsoulExchange{
  required uint32 id = 1;
}

message S2C_SummonKsoulExchange{
  required uint32 ret = 1;
  required uint32 id = 2;
  repeated Ksoul summon_exchange = 3;//今日奇遇兑换的信息
  optional uint32 summon_score = 4; // 奇遇值
}

]]

-- 点将
-- 1免费 2单抽 3五连
function HeroSoulHandler:sendSummonKsoul(nType)
	local buffer = {
		s_type = nType
	}
	local msgBuf = protobuf.encode("cs.C2S_SummonKsoul", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_SummonKsoul, msgBuf)
end

function HeroSoulHandler:_recvSummonKsoul(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_SummonKsoul", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
	  	G_Me.heroSoulData:setFreeExtractCount(decodeBuffer.free_summon)
	  	G_Me.heroSoulData:setCircleExtractCount(decodeBuffer.summon_count)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HERO_SOUL_EXTRACT_SUCC, nil, false, decodeBuffer)
	end
end

-- 奇遇值买将灵
function HeroSoulHandler:sendSummonKsoulExchange(nId)
	local buffer = {
		id = nId
	}
	local msgBuf = protobuf.encode("cs.C2S_SummonKsoulExchange", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_SummonKsoulExchange, msgBuf)
end

function HeroSoulHandler:_recvSummonKsoulExchange(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_SummonKsoulExchange", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HERO_SOUL_QIYU_BUY_SUCC, nil, false, decodeBuffer)
end

-----------------------------------------------------------------------------
-- 名将试炼

--[[
message C2S_SummonKsoul {
  required uint32 s_type = 1;//1免费 2单抽 3五连
}

message S2C_SummonKsoul {
  required uint32 ret = 1;
  required uint32 s_type = 2;
  repeated Award awards = 3;
  repeated uint32 scores = 4;
  optional uint32 summon_score = 5; 
}

message C2S_SummonKsoulExchange{
  required uint32 id = 1;
}

message S2C_SummonKsoulExchange{
  required uint32 ret = 1;
  required uint32 id = 2;
}
]]

-- 进入名将试炼
function HeroSoulHandler:sendKsoulDungeonInfo()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_KsoulDungeonInfo", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_KsoulDungeonInfo, msgBuf)
end

function HeroSoulHandler:_recvKsoulDungeonInfo(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_KsoulDungeonInfo", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	G_Me.heroSoulData:setDungeonInfo(decodeBuffer.refresh_cnt, decodeBuffer.challenge_cnt)
	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HERO_SOUL_GET_DUNGEON_INFO_SUCC, nil, false, decodeBuffer)
end

-- 刷新副本
function HeroSoulHandler:sendKsoulDungeonRefresh()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_KsoulDungeonRefresh", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_KsoulDungeonRefresh, msgBuf)
end

function HeroSoulHandler:_recvKsoulDungeonRefresh(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_KsoulDungeonRefresh", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end
end

-- 挑战
function HeroSoulHandler:sendKsoulDungeonChallenge()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_KsoulDungeonChallenge", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_KsoulDungeonChallenge, msgBuf)
end

function HeroSoulHandler:_recvKsoulDungeonChallenge(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_KsoulDungeonChallenge", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end
	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HERO_SOUL_ACQUIRE_CHALLENGE_SUCC, nil, false, decodeBuffer)
	end
end


-----------------------------------------------------------------------------
-- 商店

-- 进入商店，拉取6个商品信息
function HeroSoulHandler:sendKsoulShopInfo()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_KsoulShopInfo", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_KsoulShopInfo, msgBuf)
end

function HeroSoulHandler:_recvKsoulShopInfo(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_KsoulShopInfo", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end
	G_Me.heroSoulData:setShopInfo(decodeBuffer.refresh_cnt, decodeBuffer.next_refresh_time)
	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HERO_SOUL_GET_SHOP_INFO_SUCC, nil, false, decodeBuffer)
end

-- 刷新商品
function HeroSoulHandler:sendKsoulShopRefresh()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_KsoulShopRefresh", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_KsoulShopRefresh, msgBuf)
end

function HeroSoulHandler:_recvKsoulShopRefresh(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_KsoulShopRefresh", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end
	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HERO_SOUL_REFRESH_SUCC, nil, false, decodeBuffer)
	end
end

-- 购买商品
function HeroSoulHandler:sendKsoulShopBuy(nId)
	local buffer = {
		id = nId,
	}
	local msgBuf = protobuf.encode("cs.C2S_KsoulShopBuy", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_KsoulShopBuy, msgBuf)
end

function HeroSoulHandler:_recvKsoulShopBuy(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_KsoulShopBuy", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end
	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HERO_SOUL_BUY_SUCC, nil, false, decodeBuffer)
	end
end

-- 设置战斗底座
function HeroSoulHandler:sendSetFightBase(baseId)
	local buffer = { id = baseId }
	local msgBuf = protobuf.encode("cs.C2S_KsoulSetFightBase", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_KsoulSetFightBase, msgBuf)
end

function HeroSoulHandler:_recvSetFightBase(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_KsoulSetFightBase", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end

	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_HERO_SOUL_SET_FIGHT_BASE, nil, false, decodeBuffer.id)
	end
end

return HeroSoulHandler