local HandlerBase = require("app.network.message.HandlerBase")
local ExpansionDungeonHandler = class("ExpansionDungeonHandler",HandlerBase)

function ExpansionDungeonHandler:ctor(...)
end

function ExpansionDungeonHandler:initHandler( ... )
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetExpansiveDungeonChapterList, self._recvGetExpansiveDungeonChapterList, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_ExcuteExpansiveDungeonStage, self._recvExcuteExpansiveDungeonStage, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetExpansiveDungeonChapterReward, self._recvGetExpansiveDungeonChapterReward, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_FirstEnterExpansiveDungeonChapter, self._recvFirstEnterExpansiveDungeonChapter, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_AddExpansiveDungeonNewStage, self._recvAddExpansiveDungeonNewStage, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_PurchaseExpansiveDungeonShopItem, self._recvPurchaseExpansiveDungeonShopItem, self)

end

-- 拉取章节列表
function ExpansionDungeonHandler:sendGetExpansiveDungeonChapterList()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_GetExpansiveDungeonChapterList", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_GetExpansiveDungeonChapterList, msgBuf)
end

function ExpansionDungeonHandler:_recvGetExpansiveDungeonChapterList(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetExpansiveDungeonChapterList", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end
	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.expansionDungeonData:storeChapterList(decodeBuffer.chapters)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_EX_DUNGEON_GET_CHAPTER_LIST_SUCC, nil, false)
	end
end

-- 挑战
function ExpansionDungeonHandler:sendExcuteExpansiveDungeonStage(nStageId)
	local buffer = {
		stage_id = nStageId
	}
	local msgBuf = protobuf.encode("cs.C2S_ExcuteExpansiveDungeonStage", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_ExcuteExpansiveDungeonStage, msgBuf)
end

function ExpansionDungeonHandler:_recvExcuteExpansiveDungeonStage(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_ExcuteExpansiveDungeonStage", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end
	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.expansionDungeonData:updateStage(decodeBuffer.chapter_id, decodeBuffer.stage)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_EX_DUNGEON_EXCUTE_STAGE_SUCC, nil, false, decodeBuffer)
	end
end

-- 领取章节奖励
function ExpansionDungeonHandler:sendGetExpansiveDungeonChapterReward(nChapterId)
	local buffer = {
		chapter_id = nChapterId
	}
	local msgBuf = protobuf.encode("cs.C2S_GetExpansiveDungeonChapterReward", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_GetExpansiveDungeonChapterReward, msgBuf)
end

function ExpansionDungeonHandler:_recvGetExpansiveDungeonChapterReward(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_GetExpansiveDungeonChapterReward", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end
	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.expansionDungeonData:updateWithClaimBoxSucc(decodeBuffer.chapter_id)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_EX_DUNGEON_GET_CHAPTER_AWARD_SUCC, nil, false, decodeBuffer)
	end
end

-- 第一次进入一个章节
function ExpansionDungeonHandler:sendFirstEnterExpansiveDungeonChapter()
	local buffer = {}
	local msgBuf = protobuf.encode("cs.C2S_FirstEnterExpansiveDungeonChapter", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_FirstEnterExpansiveDungeonChapter, msgBuf)
end

function ExpansionDungeonHandler:_recvFirstEnterExpansiveDungeonChapter(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_FirstEnterExpansiveDungeonChapter", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end
	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.expansionDungeonData:updateChapter(decodeBuffer.id, decodeBuffer.chapter)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_EX_DUNGEON_FIRST_ENTER_CHAPTER_SUCC, nil, false)
	end
end

-- 增加一个stage数据
function ExpansionDungeonHandler:_recvAddExpansiveDungeonNewStage(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_AddExpansiveDungeonNewStage", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end
	G_Me.expansionDungeonData:setOpenNewStage(true)
	G_Me.expansionDungeonData:updateStage(decodeBuffer.chapter_id, decodeBuffer.stage)
	G_Me.expansionDungeonData:updateStoredMaxStage()
end

-- 购买商品
-- nItemId 商品id
-- nBuyCount 本次要购买的次数
function ExpansionDungeonHandler:sendPurchaseExpansiveDungeonShopItem(nItemId, nBuyCount)
	local buffer = {
		id = nItemId,
		count = nBuyCount,
	}
	local msgBuf = protobuf.encode("cs.C2S_PurchaseExpansiveDungeonShopItem", buffer)
	self:sendMsg(NetMsg_ID.ID_C2S_PurchaseExpansiveDungeonShopItem, msgBuf)
end

function ExpansionDungeonHandler:_recvPurchaseExpansiveDungeonShopItem(msgId, msg, len)
	local decodeBuffer = self:_decodeBuf("cs.S2C_PurchaseExpansiveDungeonShopItem", msg, len)
	if type(decodeBuffer) ~= "table" then
		return
	end
	if decodeBuffer.ret == NetMsg_ERROR.RET_OK then
		G_Me.expansionDungeonData:updateChapterItem(decodeBuffer.id, decodeBuffer.count)
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_EX_DUNGEON_BUY_ITEM_SUCC, nil, false, decodeBuffer)
	end
end

return ExpansionDungeonHandler