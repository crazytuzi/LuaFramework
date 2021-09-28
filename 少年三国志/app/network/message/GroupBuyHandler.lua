-- GroupBuyHandler.lua

local GroupBuyConst = require("app.const.GroupBuyConst")
local GroupBuyHandler = class("GroupBuyHandler", require("app.network.message.HandlerBase"))

local assert = assert
local rawget = rawget

function GroupBuyHandler:initHandler()
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetGroupBuyConfig, self._recvGetGroupBuyConfig, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetGroupBuyMainInfo, self._recvGetGroupBuyMainInfo, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetGroupBuyEndInfo, self._recvGetGroupBuyEndInfo, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetGroupBuyRanking, self._recvGetGroupBuyRanking, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetGroupBuyTaskAwardInfo, self._recvGetGroupBuyTaskAwardInfo, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetGroupBuyTaskAward, self._recvGetGroupBuyTaskAward, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetGroupBuyRankAward, self._recvGetGroupBuyRankAward, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GroupBuyPurchaseGoods, self._recvGroupBuyPurchaseGoods, self)
	uf_messageDispatcher:bindMsg(NetMsg_ID.ID_S2C_GetGroupBuyTimeInfo, self._recvGetGroupBuyTimeInfo, self)
end

-- 获取配置信息，客户端发一个缓存的md5过来验证
function GroupBuyHandler:sendGetGroupBuyConfig(md5)
	local msg = {
		md5 = md5 or "147852963", -- 使用MD5来判断本地的配置信息是否是最新
	}
	local msgBuffer = protobuf.encode("cs.C2S_GetGroupBuyConfig", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetGroupBuyConfig, msgBuffer)
end

function GroupBuyHandler:_recvGetGroupBuyConfig(_, ...)
	local db = self:_decodeBuf("cs.S2C_GetGroupBuyConfig", ...)
    if type(db) ~= "table" then return end
    if db.ret == NetMsg_ERROR.RET_OK then
    	-- dump(db)
	    if not rawget(db, "items") then
	    	db.items = {}
	    end
	    G_Me.groupBuyData:updateConfigInfoFromServer(db)
	end
end

function GroupBuyHandler:sendGetGroupBuyTimeInfo()
	local msg = {}
	local msgBuffer = protobuf.encode("cs.C2S_GetGroupBuyTimeInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetGroupBuyTimeInfo, msgBuffer)
end

function GroupBuyHandler:_recvGetGroupBuyTimeInfo(_, ...)
	local db = self:_decodeBuf("cs.S2C_GetGroupBuyTimeInfo", ...)
    if type(db) ~= "table" then return end
    -- dump(db)
    if not rawget(db, "time_cfg") then db.time_cfg = {} end
    G_Me.groupBuyData:setTimeConfig(db.time_cfg)
    self:sendGetGroupBuyConfig(G_Me.groupBuyData:getConfigMd5())
    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_TIME_PRIVILEGE_MAIN_SCENE_SHOW_ICON, nil, false, db)
end

-- 请求界面信息
function GroupBuyHandler:sendGetGroupBuyMainInfo()
	local msg = {}
	local msgBuffer = protobuf.encode("cs.C2S_GetGroupBuyMainInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetGroupBuyMainInfo, msgBuffer)
end

function GroupBuyHandler:_recvGetGroupBuyMainInfo(_, ...)
	local db = self:_decodeBuf("cs.S2C_GetGroupBuyMainInfo", ...)
    if type(db) ~= "table" then return end
    if db.ret == NetMsg_ERROR.RET_OK then
    	-- dump(db)
    	if not rawget(db, "item_datas") then
	    	db.item_datas = {}
	    end
	    G_Me.groupBuyData:setMainDataFromServer(db)
	    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GROUPBUY_MAINLAYER_UPDATE, nil, false, db)
    end

end

-- 请求活动结束领奖界面信息
function GroupBuyHandler:sendGetGroupBuyEndInfo()
	local msgBuffer = protobuf.encode("cs.C2S_GetGroupBuyEndInfo", {}) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetGroupBuyEndInfo, msgBuffer)
end

function GroupBuyHandler:_recvGetGroupBuyEndInfo(_, ...)
	local db = self:_decodeBuf("cs.S2C_GetGroupBuyEndInfo", ...)
    if type(db) ~= "table" then return end
    if db.ret == NetMsg_ERROR.RET_OK then
    	if not rawget(db, "ranks") then
	    	db.ranks = {}
	    end
	   	G_Me.groupBuyData:setEndInfo(info)
	   	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GROUPBUY_MAINLAYER_UPDATE, nil, false, db)
    end	
end

-- 获取积分排行榜
function GroupBuyHandler:sendGetGroupBuyRanking(type_, max_rank_id)
	assert(type(type_) == "number", tostring(type_))
	assert(type(max_rank_id) == "number", tostring(max_rank_id))
	local msg = {
		type = type_, -- 1 表示普通排行榜 2 表示豪华排行榜
		max_rank_id = max_rank_id, -- 最大排名，每次返回10个排名信息，比如前十就填10， 11-20就填20
	}
	local msgBuffer = protobuf.encode("cs.C2S_GetGroupBuyRanking", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetGroupBuyRanking, msgBuffer)
end

function GroupBuyHandler:_recvGetGroupBuyRanking(_, ...)
	local db = self:_decodeBuf("cs.S2C_GetGroupBuyRanking", ...)
    if type(db) ~= "table" then return end
	if db.ret == NetMsg_ERROR.RET_OK then
		-- dump(db)
    	if not rawget(db, "gb_user") then db.gb_user = {} end
	   	G_Me.groupBuyData:disposeRankBuffer(db)
    end
end

-- 获取任务奖励状态
function GroupBuyHandler:sendGetGroupBuyTaskAwardInfo()
	local msg = {}
	local msgBuffer = protobuf.encode("cs.C2S_GetGroupBuyTaskAwardInfo", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetGroupBuyTaskAwardInfo, msgBuffer)
end

function GroupBuyHandler:_recvGetGroupBuyTaskAwardInfo(_, ...)
	local db = self:_decodeBuf("cs.S2C_GetGroupBuyTaskAwardInfo", ...)
    if type(db) ~= "table" then return end
    if db.ret == NetMsg_ERROR.RET_OK then
    	-- dump(db)
    	if not rawget(db, "award_ids") then db.award_ids = {} end
    	G_Me.groupBuyData:setScore(db.self_score)
    	G_Me.groupBuyData:setServerBuyCount(db.server_score)
    	G_Me.groupBuyData:setBackGold(db.back_gold)
    	G_Me.groupBuyData:setDailyAwardIds(db.award_ids)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GROUPBUY_DAILY_AWARD_LOAD, nil, false, db)
    end
end

-- 领取任务奖励
function GroupBuyHandler:sendGetGroupBuyTaskAward(id)
	assert(type(id) == "number", tostring(id))
	local msg = {
		id = id,
	}
	local msgBuffer = protobuf.encode("cs.C2S_GetGroupBuyTaskAward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetGroupBuyTaskAward, msgBuffer)
end

function GroupBuyHandler:_recvGetGroupBuyTaskAward(_, ...)
	local db = self:_decodeBuf("cs.S2C_GetGroupBuyTaskAward", ...)
    if type(db) ~= "table" then return end
    if db.ret == NetMsg_ERROR.RET_OK then
    	-- dump(db)
    	if not rawget(db, "awards") then db.awards = {} end
    	if not rawget(db, "award_ids") then db.awards = G_Me.groupBuyData:getDailyAwardIds() end
    	G_Me.groupBuyData:setDailyAwardIds(db.award_ids)
    	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GROUPBUY_DAILY_AWARD_GET, nil, false, db)
    end
end

-- 领取结束界面排名奖励
function GroupBuyHandler:sendGetGroupBuyRankAward()
	local msg = {}
	local msgBuffer = protobuf.encode("cs.C2S_GetGroupBuyRankAward", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GetGroupBuyRankAward, msgBuffer)
end

function GroupBuyHandler:_recvGetGroupBuyRankAward(_, ...)
	local db = self:_decodeBuf("cs.S2C_GetGroupBuyRankAward", ...)
    if type(db) ~= "table" then return end
  	if db.ret == NetMsg_ERROR.RET_OK then
  		if not rawget(db, "awards") then
	    	db.awards = {}
	    end
  		local endInfo = G_Me.groupBuyData:getEndInfo()
  		endInfo.is_acquired = db.is_acquired
  		G_Me.groupBuyData:setEndInfo(endInfo)
  		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GROUPBUY_MAINLAYER_UPDATE, nil, false, db)
  		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GROUPBUY_GET_REWARD, nil, false, db)
  	end
end

-- 购买
function GroupBuyHandler:sendGroupBuyPurchaseGoods(id)
	assert(type(id) == "number", tostring(id))
	local msg = {
		id = id,
	}
	local msgBuffer = protobuf.encode("cs.C2S_GroupBuyPurchaseGoods", msg) 
    self:sendMsg(NetMsg_ID.ID_C2S_GroupBuyPurchaseGoods, msgBuffer)
end

function GroupBuyHandler:_recvGroupBuyPurchaseGoods(_, ...)
	local db = self:_decodeBuf("cs.S2C_GroupBuyPurchaseGoods", ...)
    if type(db) ~= "table" then return end
    if db.ret == NetMsg_ERROR.RET_OK then
    	-- dump(db)
	    G_Me.groupBuyData:updateItemBuyTimesInfoById(db)
	    G_Me.groupBuyData:setScore(db.score)
	    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_GROUPBUY_BUY_REWARD, nil, false, db)
    end
end

return GroupBuyHandler