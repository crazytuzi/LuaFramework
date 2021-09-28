--RoleLitterfunInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  RoleLitterfunInfo.lua
 --* Author:  seezon
 --* Modified: 2014Äê6ÔÂ16ÈÕ
 --* Purpose: Implementation of the class RoleLitterfunInfo
 -------------------------------------------------------------------*/

RoleLitterfunInfo = class()

local prop = Property(RoleLitterfunInfo)
prop:accessor("roleSID", 0)
prop:accessor("roleID", 0)

function RoleLitterfunInfo:__init()
    self._datas = {}
	self:initData()
end

function RoleLitterfunInfo:initData()
	self._potencyDanData = {}
	self._datas.potencyDanData = self._potencyDanData
	self._datas.chargeData = {}
	self._datas.accelerateData = {}	--Íâ¹ÒÊý¾Ý
	
	self._loadDB = 0   									--是否加载了数据库的数据

	local maxNum = PotencyDanType.MaxDanNum
	for i=1, maxNum do
		table.insert(self._potencyDanData, 0)
	end
end

function RoleLitterfunInfo:getAccelerateData()
	if not  self._datas.accelerateData then
		 self._datas.accelerateData = {}
	end
	return self._datas.accelerateData
end

function RoleLitterfunInfo:loadRole(dataTb)
	self._datas = unserialize(dataTb)
	

	self:notifyClientLoadData()

	self._loadDB = 1
end

function RoleLitterfunInfo:getFinalIngotNum(sourceIngot)
	local sourceRMB = sourceIngot / 10
	local proto = g_LuaLitterfunDAO:getChargeData(sourceRMB)

	if not proto then
		return sourceIngot
	end
	local finalIngot = sourceIngot
	if self._datas.chargeData and self._datas.chargeData[sourceRMB] and self._datas.chargeData[sourceRMB] >= 1 then
		finalIngot = finalIngot + toNumber(proto.q_freeyb, 0)
		self._datas.chargeData[sourceRMB] = self._datas.chargeData[sourceRMB] + 1
	else
		if tonumber(proto.q_double) > 0 then
			finalIngot = (finalIngot + toNumber(proto.q_freeyb, 0)) * 2
		else
			finalIngot = finalIngot + toNumber(proto.q_freeyb, 0)
		end
		if not self._datas then
			self._datas = {}
			self:initData()
		end
		if not self._datas.chargeData then
			self._datas.chargeData = {}
		end
		self._datas.chargeData[sourceRMB] = 1
	end
	self:cast2DB()
	self:notifyChargeInfo()
	return finalIngot
end

--»ñÈ¡Íæ¼Ò×î´óµÄ³äÖµµµ´Î
function RoleLitterfunInfo:getMaxChargeNum()
	local maxChargeNum = 0
	for k,v in pairs(self._datas.chargeData) do
		if k > maxChargeNum then
			maxChargeNum = k
		end
	end
	return maxChargeNum
end

--±£´æµ½Êý¾Ý¿â
function RoleLitterfunInfo:cast2DB()
	local cache_buf = serialize(self._datas)
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_LITTLEFUN, cache_buf, #cache_buf)
end

--¸ø¿Í»§¶Ë·¢ÐèÒª¼ÓÔØµÄÊý¾Ý
function RoleLitterfunInfo:notifyClientLoadData()
	self:notifyChargeInfo()
end

--Í¨Öª¿Í»§¶Ë³äÖµ´ÎÊýÐÅÏ¢
function RoleLitterfunInfo:notifyChargeInfo()
	local retBuffer = LuaEventManager:instance():getLuaRPCEvent(LITTERFUN_SC_NOTIFY_CHARGE)
	local chargeNum = table.size(self._datas.chargeData)
	retBuffer:pushChar(chargeNum)
	for k,v in pairs(self._datas.chargeData or {}) do
		retBuffer:pushInt(k)
		retBuffer:pushInt(v)
	end
	g_engine:fireLuaEvent(self:getRoleID(), retBuffer)
end

--ÇÐ»»worldµÄÍ¨Öª
function RoleLitterfunInfo:switchWorld(luaBuf)
	apiEntry.switchCount = apiEntry.switchCount + 1
	luaBuf:pushShort(EVENT_LITTERFUN_SETS)
	--¾ßÌåÊý¾Ý¸úÔÚºóÃæ
	luaBuf:pushString(serialize(self._datas))
end

function RoleLitterfunInfo:loadDBDataImpl(player, luaBuf)
	if luaBuf:size() > 0 then
		local data = luaBuf:popString()
		self._datas = unserialize(data)
	end
end