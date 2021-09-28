--RoleAdoreInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  RoleAdoreInfo.lua
 --* Author:  seezon
 --* Modified: 2015年7月28日
 --* Purpose: Implementation of the class RoleAdoreInfo
 -------------------------------------------------------------------*/

RoleAdoreInfo = class()

local prop = Property(RoleAdoreInfo)
prop:accessor("roleSID")
prop:accessor("roleID")

function RoleAdoreInfo:__init()
	self._datas = {remainTime = 0,remainIngotTime = 0, stamp = 0}
end


--刷新时间戳
function RoleAdoreInfo:freshTimeStamp()
	local stamp = tonumber(time.toedition("day") + 1)
	self._datas.stamp = stamp
	self._datas.remainTime = ADORE_FREE_TIME
	self._datas.remainIngotTime = ADORE_INGOT_TIME
    self:cast2DB()
end

--获取膜拜的次数
function RoleAdoreInfo:getRemainTime()
    local timeStamp = time.toedition("day")
    if tonumber(timeStamp) < self._datas.stamp then
	    return self._datas.remainTime
    else
	    --过期的时间戳要刷新
	    self:freshTimeStamp()
	    return ADORE_FREE_TIME
    end
end

function RoleAdoreInfo:getRemainIngotTime()
	local timeStamp = time.toedition("day")
    if tonumber(timeStamp) < self._datas.stamp then
	    return self._datas.remainIngotTime
    else
	    --过期的时间戳要刷新
	    self:freshTimeStamp()
	    return ADORE_INGOT_TIME
    end
end

function RoleAdoreInfo:freshVipTime()
	self._datas.remainIngotTime = ADORE_INGOT_TIME
end

--膜拜处理
function RoleAdoreInfo:adoreKing(IngotCost)
	local player = g_entityMgr:getPlayer(self:getRoleID())
	if not player then
		return false
	end
	if player:getLevel() < ADORE_LEVEL_LIMIT then
		g_adoreServlet:sendErrMsg2Client(self:getRoleID(), ADORE_ERR_NOT_LEVEL, 1, {ADORE_LEVEL_LIMIT})
		return false
	end

	local data = g_adoreMgr._data[player:getLevel()]

	if IngotCost <= 0 then
		if self:getRemainTime(adoreType) > 0 then
			local vital = data.q_rewards_sw
			local exp = data.q_rewards_exp
			self._datas.remainTime = self._datas.remainTime - 1
			g_taskMgr:NotifyListener(player, "onAdore") --膜拜（adoreType为1是中州王，2是沙巴克）
			
			player:setVital(player:getVital() + vital)
			addExpToPlayer(player,exp,21)
			g_tlogMgr:TlogZZMBFlow(player,0,0)
			g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.ADORE)
			g_adoreServlet:sendErrMsg2Client(self:getRoleID(), ADORE_ERR_ID_SUCC, 2, {vital,exp})
			self:cast2DB()
			return true
		else
			g_adoreServlet:sendErrMsg2Client(self:getRoleID(), ADORE_ERR_ID_NO_TIMES, 0)
			return false
		end
	else
		if self:getRemainIngotTime() > 0 then
			local times = self:getRemainIngotTime() or 1
			local reward = unserialize(data.q_reward)

			local payIngot = reward[times].ingot or 100
			local exp = reward[times].exp or 1500000
			local vital = reward[times].vital or 2000
			if not isIngotEnough(player,payIngot) then 
				g_adoreServlet:sendErrMsg2Client(self:getRoleID(), ADORE_ERR_ID_INGOT_NOT_ENOUGH, 1, {payIngot})
				return false
			end
			--costIngot(player, payIngot, 21) 

			self._datas.remainIngotTime = self._datas.remainIngotTime - 1
			player:setVital(player:getVital() + vital)
			addExpToPlayer(player,exp,21)
			g_adoreServlet:sendErrMsg2Client(self:getRoleID(), ADORE_ERR_ID_SUCC, 2, {vital,exp})
			
			g_taskMgr:NotifyListener(player, "onAdore") --膜拜（adoreType为1是中州王，2是沙巴克）
		 	
		  	g_achieveSer:costIngot(player:getSerialID(), payIngot)
		  	--消耗元宝

			g_tlogMgr:TlogHDFlow(player,5)
			g_tlogMgr:TlogZZMBFlow(player,payIngot,1)
			g_PayRecord:Record(player:getID(), -payIngot, CURRENCY_INGOT, 33)
			g_normalMgr:activeness(player:getID(), ACTIVENESS_TYPE.ADORE)
			self:cast2DB()
			return true
		else
			g_adoreServlet:sendErrMsg2Client(self:getRoleID(), ADORE_ERR_ID_NO_TIMES, 0)
			return false
		end
	end

	return true
end



function RoleAdoreInfo:writeObject( )
	local buff = {datas = serialize(self._datas)}
	return protobuf.encode("AdoreProtocol", buff)
end


--切换world的通知
function RoleAdoreInfo:switchWorld(peer, dbid, mapID)
	local cache_buf = self:writeObject()

	local luaBuf = g_buffMgr:getLuaEventEx(LOGIN_WW_SWITCH_WORLD)
	luaBuf:pushInt(dbid)
	luaBuf:pushShort(EVENT_ADORE_SET)
	--具体数据跟在后面
	luaBuf:pushLString(cache_buf,#cache_buf)
	g_engine:fireSwitchBuffer(peer, mapID, luaBuf)
end

--保存到数据库
function RoleAdoreInfo:cast2DB()
	local cache_buf = self:writeObject()
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_ADORE, cache_buf, #cache_buf)
end

function RoleAdoreInfo:loadDBDataImpl(player, cache_buf)
	if #cache_buf > 0 then
		local datas = protobuf.decode("AdoreProtocol", cache_buf)
		self._datas = unserialize(datas.datas)
	end
end