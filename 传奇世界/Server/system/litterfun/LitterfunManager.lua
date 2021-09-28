--LitterfunManager.lua
--/*-----------------------------------------------------------------
 --* Module:  LitterfunManager.lua
 --* Author:  seezon
 --* Modified: 2014年12月18日
 --* Purpose: 小功能管理器
 -------------------------------------------------------------------*/
require ("system.litterfun.LitterfunServlet")
require ("system.litterfun.RoleLitterfunInfo")
require ("system.litterfun.LitterfunConstant")
require ("system.litterfun.LuaLitterfunDAO")
	
LitterfunManager = class(nil, Singleton)
--全局对象定义
g_litterfunServlet = LitterfunServlet.getInstance()
g_LuaLitterfunDAO = LuaLitterfunDAO.getInstance()

function LitterfunManager:__init()
	self._roleInfos = {} --运行时ID
	self._roleInfoBySID = {} --数据库ID
	g_listHandler:addListener(self)
end

--玩家上线
function LitterfunManager:onPlayerLoaded(player)
	local roleID = player:getID()
	local roleSID = player:getSerialID()
	local memInfo = self:getRoleInfo(roleID)
	if not memInfo then
		memInfo = RoleLitterfunInfo()
		memInfo:setRoleID(roleID)
		memInfo:setRoleSID(roleSID)
		self._roleInfos[roleID] = memInfo
		self._roleInfoBySID[roleSID] = memInfo
	end
end

--数据库加载回调
function LitterfunManager.loadDBData(player, cacha_buf, roleSid)
	g_litterfunMgr:loadDBDataImpl(player, cacha_buf, roleSid)
end

--数据库加载回调
function LitterfunManager:loadDBDataImpl(player, cacha_buf, roleSid)
	if not player then return end
	local roleID = player:getID()
	local roleSID = player:getSerialID()

	local memInfo = self:getRoleInfo(player:getID())
	if not memInfo then
		memInfo = RoleLitterfunInfo()
		memInfo:setRoleID(roleID)
		memInfo:setRoleSID(roleSID)
		self._roleInfos[roleID] = memInfo
		self._roleInfoBySID[roleSID] = memInfo
	end
	if memInfo then
		memInfo:loadRole(cacha_buf)
	end
end

--玩家注销
function LitterfunManager:onPlayerOffLine(player)
	local roleSID = player:getSerialID()
	local roleID = player:getID()
	self._roleInfos[roleID] = nil
	self._roleInfoBySID[roleSID] = nil
end

--掉线登陆
function LitterfunManager:onActivePlayer(player)
	local memInfo = self:getRoleInfoBySID(player:getSerialID()) 
	if memInfo then
		memInfo:notifyChargeInfo()
    end
end

--切换world的通知
function LitterfunManager:onSwitchWorld(roleID, luaBuf)
	local memInfo = self:getRoleInfo(roleID)
	if memInfo then
		memInfo:switchWorld(luaBuf)
	end
end

--切换到本world的通知
function LitterfunManager:onPlayerSwitch(player, type, buff)
	if type == EVENT_LITTERFUN_SETS then
		local roleID = player:getID()
		local roleSID = player:getSerialID()
		local memInfo = RoleLitterfunInfo()
		memInfo:setRoleID(roleID)
		memInfo:setRoleSID(roleSID)
		self._roleInfos[roleID] = memInfo
		self._roleInfoBySID[roleSID] = memInfo	
		memInfo:loadDBDataImpl(player, buff)
	end	
end

--玩家升级
function LitterfunManager:onLevelChanged(player)
end

--获取玩家数据
function LitterfunManager:getRoleInfo(roleID)
	return self._roleInfos[roleID]
end

--获取玩家数据通过数据库ID
function LitterfunManager:getRoleInfoBySID(roleSID)
	return self._roleInfoBySID[roleSID]
end

--[[
--整点更新商城受限物品购买记录	20150921
function LitterfunManager:onWholeClock(hour)
	if 5==hour then
		for i,v in pairs(self._roleInfoBySID) do
			if v.JFShopLimit then
				v:SetJFShopLimitData({})
			end
		end
	end
end
]]

function LitterfunManager.getInstance()
	return LitterfunManager()
end

g_litterfunMgr = LitterfunManager.getInstance()