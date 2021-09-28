--RankServlet.lua
--/*-----------------------------------------------------------------
--* Module:  RankServlet.lua
--* Author:  HE Ningxu
--* Modified: 2014年9月22日
--* Purpose: Implementation of the class RankServlet
-------------------------------------------------------------------*/

RankServlet = class(EventSetDoer, Singleton)

function RankServlet:__init()
	self._doer = {
		[RANK_CS_REQ]			= RankServlet.Req,
		[RANK_CS_NO1]			= RankServlet.worldNO1,
		[RANK_CS_GET_NO1_DATA]	= RankServlet.getNO1Data,
		[RANK_CS_GLAMOUR_REQ]	= RankServlet.getGlamourData,
	}
end

function RankServlet:getGlamourData(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	-- self:decodeProto(pbc_string, "RankGlamour")
	if not player then return end
	local name, glamour = g_RankMgr:getGlamourData()
	local ret = {
		name = name,
		glamour = glamour,
	}
	fireProtoMessage(player:getID(), RANK_SC_GLAMOUR_RET, 'RankGlamourRet', ret)
end

function RankServlet:Req(event)
	local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	local req = self:decodeProto(pbc_string, "RankReq")
	if not player or not req then return end
	local tab, page, factionID = req.tab, req.page, req.factionID
	local tabData = g_RankMgr:getRankData(tab)
	if not tabData then
		return
	end
	local size = #tabData
	local pageCount = math.ceil(size / RANK_PAGE_SIZE)	-- 总页数
	if page > pageCount and page ~= 1 then
		return
	end
	local startIndex = RANK_PAGE_SIZE * (page - 1) + 1					-- 第一条记录索引
	local endIndex = math.min(size, startIndex + RANK_PAGE_SIZE - 1)	-- 最后一条记录索引
	local ret = {}
	if tab == RANK_TYPR.RANK_FACTION then
		local rank = 0
		for index, data in pairs(tabData) do
			if data.factionID == factionID then
				rank = index
				break
			end
		end
		ret.tab = tab
		ret.size = math.min(size, 100)
		ret.selfRank = rank
		local factionData = {}
		for index = startIndex, endIndex do
			local data, tmp = tabData[index], {}
			tmp.rank = index
			tmp.factionID = data.factionID
			tmp.name = data.name
			tmp.level = data.level
			tmp.battle = data.battle
			table.insert(factionData, tmp)
		end
		ret.factionData = factionData
	else
		local rank = 0
		for index, data in pairs(tabData) do
			if data[1] == dbid then
				rank = index
				break
			end
		end
		ret.tab = tab
		ret.size = size
		ret.selfRank = rank
		if tab == RANK_TYPR.RANK_GLAMOUR and page == 1 then
			local glamourData, glamour = g_RankMgr:getGlamour(), {}
			if glamourData then
				glamour.roleSID = glamourData[1]
				glamour.name = glamourData[2]
				glamour.school = glamourData[3]
				glamour.value = glamourData[4]
			end
			ret.glamour = glamour
		end
		local rankData = {}
		for index = startIndex, endIndex do
			local data, tmp = tabData[index], {}
			if data then
				tmp.rank = index
				tmp.roleSID = data[1]
				tmp.name = data[2]
				tmp.school = data[3]
				tmp.value = data[4]
				table.insert(rankData, tmp)
			end
		end
		ret.rankData = rankData
	end
	fireProtoMessage(player:getID(), RANK_SC_RET, 'RankReqRet', ret)
end

function RankServlet:worldNO1(event)
	local params = event:getParams()
	local buffer, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	if player then 
		g_RankMgr:worldNO1(player:getID())
	end
end

function RankServlet:getNO1Data(event)
	local params = event:getParams()
	local buffer, dbid = params[1], params[2]
	local player = g_entityMgr:getPlayerBySID(dbid)
	if player then 
		g_RankMgr:getNO1Data(player:getID())
	end
end

function RankServlet:decodeProto(pb_str, protoName)
	local protoData, errorCode = protobuf.decode(protoName, pb_str)
	if not protoData then
		print("decodeProto error! RankServlet:", protoName, errorCode)
		return
	end
	return protoData
end

function RankServlet.getInstance()
	return RankServlet()
end
g_RankServlet = RankServlet.getInstance()

g_eventMgr:addEventListener(RankServlet.getInstance())
