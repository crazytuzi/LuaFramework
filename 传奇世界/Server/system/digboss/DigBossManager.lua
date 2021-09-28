
--DigBossManager.lua
--/*-----------------------------------------------------------------
--* Module:  DigBossManager.lua
--* Author:  liucheng
--* Modified: 2015年6月1日
--* Purpose: Implementation of the class DigBossManager
-------------------------------------------------------------------*/
require "system.digboss.DigBossConstant"

DigBossManager = class(nil, Singleton)

function DigBossManager:__init()
	self._BossDig = {}			--可挖掘的boss信息	
	self._UserDigInfo = {}		--用户挖掘boss	{[静态ID]={BossID=刚杀死的bossID，Num=已挖掘此boss的次数}}	
	self._DigDropItem = {}
	self:loadDropItem()

	g_listHandler:addListener(self)
end

function DigBossManager:loadDropItem()
	self._DigDropItem = {}
    local records = require "data.DropDB"
    for _, data in pairs(records or {}) do
    	if DIG_DROP_ID==data.q_id then
    		local itemTmp = {itemID=data.q_item or 0,itemName=data.F3 or ""}
    		table.insert(self._DigDropItem,itemTmp)
    	end
    end
end

function DigBossManager:onMonsterKill(monSID, roleID, monID)
	if table.contains(self._BossDig, monSID) then
		--add lc 20150601	判断玩家是否在副本中  如果是并且boss是可挖掘的  记录玩家刚杀死的bossID
		local player = g_entityMgr:getPlayer(roleID)
		if player and player:getCopyID() > 0 then
			local roleSID = player:getSerialID()
			self._UserDigInfo[roleSID] = {}
			self._UserDigInfo[roleSID].BossID = monSID
			self._UserDigInfo[roleSID].Num = 0
		end
	end	
end

--玩家离线的消息
function DigBossManager:onPlayerOffLine(player)
	local roleSID = player:getSerialID()
	self._UserDigInfo[roleSID] = nil
end

--增加可挖掘的boss
function DigBossManager:addDigBoss(BossID)
	table.insert(self._BossDig,BossID)
end

function DigBossManager.getInstance()
	return DigBossManager()
end

g_DigBossMgr = DigBossManager.getInstance()