--------------------------------------------------------------------------------------
-- 文件名:	Class_MapInfo.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:
-- 日  期:	2014-
-- 版  本:	1.0
-- 描  述:	
-- 应  用:	
---------------------------------------------------------------------------------------

MapInfo = class("MapInfo")
MapInfo.__index = MapInfo


function MapInfo:setMapTableStarNum(tbList)
	self.tbInfo = tbList
end
function MapInfo:getMapInfo()
	return self.tbInfo
end
function MapInfo:setMapIdStarNum(mapId, starNum)
	self.tbInfo[mapId] = {
		map_id = mapId,
		star_num = starNum,
	}
end

function MapInfo:getMapIdStarNum(mapId)
	if self.tbInfo[mapId] then 
		return self.tbInfo[mapId].star_num or 0
	end
	return 0
end


function MapInfo:mapStarInfoRequest()
	if next(self:getMapInfo()) == nil then 
		g_MsgMgr:sendMsg(msgid_pb.MSGID_MAP_STAR_INFO_REQUEST)
	end
end


function MapInfo:init()
	
	self.tbInfo = {}
	--注册所有副本信息响应
	local order = msgid_pb.MSGID_MAP_STAR_INFO_RESPONSE
	g_MsgMgr:registerCallBackFunc(order, handler(self, self.mapStarInfoResponse))
end

function MapInfo:mapStarInfoResponse(tbMsg)
	local tbMsgDetail = zone_pb.MapStarInfoResponse()
	tbMsgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(tbMsgDetail))
	
	local info = tbMsgDetail.info
	
	for key,value in pairs(info) do
		local t = {}
		t.map_id = value.map_id
		t.star_num = value.star_num
		table.insert(self.tbInfo ,t)
	end
	self:setMapTableStarNum(self.tbInfo)
	
end

---------------------------------------------------------------------------------
g_MapInfo = MapInfo.new()
g_MapInfo:init()
