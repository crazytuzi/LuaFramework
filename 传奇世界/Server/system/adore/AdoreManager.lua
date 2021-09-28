--AdoreManager.lua
--/*-----------------------------------------------------------------
 --* Module:  AdoreManager.lua
 --* Author:  seezon
 --* Modified: 2015年7月27日
 --* Purpose: 膜拜系统管理器
 -------------------------------------------------------------------*/
require ("system.adore.AdoreServlet")
require ("system.adore.RoleAdoreInfo")
require ("system.adore.AdoreConstant")
	
AdoreManager = class(nil, Singleton)
--全局对象定义
g_adoreServlet = AdoreServlet.getInstance()

function AdoreManager:__init()
	self._roleInfos = {} --运行时ID
	self._roleInfoBySID = {} --数据库ID
	self._adoreZhongData = {name= "null", num = 0, adoreName = {}} --膜拜中州王公共数据
	self.updateZhongDB = false
	self._adoreShaData = {name= "null", num = 0, adoreName = {}} --膜拜沙巴克城主公共数据
	self.updateShaDB = false
	self._data = {}
	self:loadAdoreData()
	g_listHandler:addListener(self)
end

function AdoreManager:loadAdoreData()
	local adareData = require "data.AdoreConfig"
	for i,v in pairs(adareData) do
		self._data[v.q_Lv] = v
	end
	ADORE_INGOT_TIME = table.size(unserialize(adareData[1].q_reward))
end

--加载数据库的数据
function AdoreManager.loadDBData(player, cache_buf, roleSid)
	g_adoreMgr:loadDBDataImpl(player, cache_buf, roleSid)
end
--加载数据库的数据
function AdoreManager:loadDBDataImpl(player, cache_buf, roleSid)	
	local memInfo = self:getRoleInfo(player:getID())
	memInfo:loadDBDataImpl(player, cache_buf)
end

--玩家下线
function AdoreManager:onPlayerOffLine(player)
	local roleSID = player:getSerialID()
	local roleID = player:getID()
	local memInfo = self:getRoleInfoBySID(roleSID)
	if not memInfo then
		return
	end

    --保存系统设置数据到数据库
    memInfo:cast2DB()
	if memInfo then
		self._roleInfos[roleID] = nil
		self._roleInfoBySID[roleSID] = nil
	end
end

--掉线登陆
function AdoreManager:onActivePlayer(player)
	local memInfo = self:getRoleInfoBySID(player:getSerialID()) 
	if not memInfo then
		return
	end
end

--玩家通知存数据库
function AdoreManager:onPlayerCast2DB(player)
	local roleSID = player:getSerialID()
	local memInfo = self:getRoleInfoBySID(roleSID)
	if not memInfo then
		return
	end
	memInfo:cast2DB()
	
	-- if self.updateZhongDB then
	-- 	updateCommonData(COMMON_DATA_ID_TOLAL_ADORE_ZHONG, self._adoreZhongData)
	-- 	self.updateZhongDB = false
	-- end

	-- if self.updateShaDB then
	-- 	updateCommonData(COMMON_DATA_ID_TOLAL_ADORE_SHA, self._adoreShaData)
	-- 	self.updateShaDB = false
	-- end
end

--加载膜拜中州王公共数据
function AdoreManager:onLoadZhongData(data)
	if data then
		self._adoreZhongData = unserialize(data)
	end
end

--加载膜拜沙巴克城主公共数据
function AdoreManager:onLoadShaData(data)
	if data then
		self._adoreShaData = unserialize(data)
	end
end

function AdoreManager.adoreByIngot( roleSID, payRet, money, itemId, itemCount, callBackContext )
	local player = g_entityMgr:getPlayerBySID(roleSID)
	local context = unserialize(callBackContext)
	local useIngot = context.useIngot
	local adoreInfo = g_adoreMgr:getRoleInfo(player:getID())
	local ret = TPAY_FAILED
	if payRet == 0  and adoreInfo then
		adoreInfo:adoreKing(useIngot)
		local retData = {}
		fireProtoMessage(player:getID(),ADORE_SC_ADOREKING_RET,"AdoreKingRetProtocol",retData)
		ret =  TPAY_SUCESS
	else
		ret =  TPAY_FAILED
	end
	return ret
end


--膜拜中州城主
function AdoreManager:adoreKing(roleID,useIngot)
	local player = g_entityMgr:getPlayer(roleID)

	if not player then
		return
	end

	local memInfo = self:getRoleInfo(roleID)
	if not memInfo then
		return
	end
	if useIngot > 0 then 
		local data = g_adoreMgr._data[player:getLevel()]
		local reward = unserialize(data.q_reward)
		local times = memInfo:getRemainIngotTime() 
		local payIngot = reward[times].ingot or 100
		useIngot = payIngot
	end
	local context = {useIngot = useIngot}
	if useIngot <= 0 then 
		local adoreInfo = g_adoreMgr:getRoleInfo(roleID)
		adoreInfo:adoreKing(useIngot)
		local retData = {}
		fireProtoMessage(player:getID(),ADORE_SC_ADOREKING_RET,"AdoreKingRetProtocol",retData)
	else
		local ret = g_tPayMgr:TPayScriptUseMoney(player, useIngot, 21, "Adore", 0, 0, "AdoreManager.adoreByIngot", serialize(context))
	end

end

--切换world的通知
function AdoreManager:onSwitchWorld2(roleID, peer, dbid, mapID)
	local memInfo = self:getRoleInfo(roleID)
	if memInfo then
		memInfo:switchWorld(peer, dbid, mapID)
	end
end

--切换到本world的通知
function AdoreManager:onPlayerSwitch(player, type, luabuf)
	if type == EVENT_ADORE_SET then
		local roleID = player:getID()
		local roleSID = player:getSerialID()
		memInfo = RoleAdoreInfo()
		memInfo:setRoleID(roleID)
		memInfo:setRoleSID(roleSID)
		self._roleInfos[roleID] = memInfo
		self._roleInfoBySID[roleSID] = memInfo

		local cache_buf = luabuf:popLString()
		memInfo:loadDBDataImpl(player, cache_buf)
	end	
end

function AdoreManager:clearZhongAdoreData()
	self._adoreZhongData = {name= "null", num = 0, adoreName = {}}
end

function AdoreManager:clearShaAdoreData()
	self._adoreShaData = {name= "null", num = 0, adoreName = {}}
end

--获取膜拜数据
function AdoreManager:getData(roleID)
	local player = g_entityMgr:getPlayer(roleID)

	if not player then
		return
	end
	local memInfo = self:getRoleInfo(roleID)
	if not memInfo then
		return
	end
	local retData = {
					remainTimes = memInfo:getRemainTime(),
					remainIngotTimes = memInfo:getRemainIngotTime(),
					}
	fireProtoMessage(roleID,ADORE_SC_GETDATA_RET,"AdoreGetDataRetProtocol",retData)
end

--获取玩家数据
function AdoreManager:getRoleInfo(roleID)
	local memInfo = self._roleInfos[roleID]
	if not memInfo then 
		local player = g_entityMgr:getPlayer(roleID)
		if player then 
			local roleSID = player:getSerialID()
			local memInfo = RoleAdoreInfo()
			memInfo:setRoleID(roleID)
			memInfo:setRoleSID(roleSID)
			self._roleInfos[roleID] = memInfo
			self._roleInfoBySID[roleSID] = memInfo	
		end
	end
	return self._roleInfos[roleID]
end

--获取玩家数据通过数据库ID
function AdoreManager:getRoleInfoBySID(roleSID)
	return self._roleInfoBySID[roleSID]
end

-- gm清理膜拜次数
function AdoreManager:gmFreshAdore(roleID)
	local memInfo = self._roleInfos[roleID]
	if memInfo then
		memInfo:freshTimeStamp()
	end 
end


function AdoreManager.getInstance()
	return AdoreManager()
end

g_adoreMgr = AdoreManager.getInstance()