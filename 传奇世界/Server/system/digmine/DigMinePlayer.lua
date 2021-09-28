--DigMinePlayer.lua
--/*-----------------------------------------------------------------
--* Module:  DigMinePlayer.lua
--* Author:  Andy
--* Modified: 2016年1月7日
--* Purpose: Implementation of the class DigMinePlayer
-------------------------------------------------------------------*/

DigMinePlayer = class()

local prop = Property(DigMinePlayer)

prop:accessor("roleSID")
prop:accessor("roleID")
prop:accessor("exchangeCount", 0)	--兑换的次数
prop:accessor("exchangeTime", 0)	--上次兑换时间
prop:accessor("lastLogout", 0)		--上次下线时间
prop:accessor("newOffMine", true)	--是否首次离线挖矿
prop:accessor("lastDigTime", 0)		--上次离线挖矿累计时间
prop:accessor("offMineExp", 0)		--上次离线挖矿获得的经验
--Tlog相关数据
prop:accessor("enterTime", 0)		--进入矿区地图的时间
prop:accessor("killNum", 0)			--杀死玩家的人数
prop:accessor("killerNum", 0)		--被杀的次数
prop:accessor("mineNum", 0)			--挖取到的矿石结晶数量

prop:accessor("cast2DBTime", os.time())

function DigMinePlayer:__init(roleSID, roleID)
	prop(self, "roleSID", roleSID)
	prop(self, "roleID", roleID)

	self._offMineReward = {}			--离线挖矿奖励
	self._offMineMergeRewardReward = {}	--离线挖矿奖励合并后
end

function DigMinePlayer:setOffMineReward(reward)
	self._offMineReward = reward
end

function DigMinePlayer:getOffMineReward()
	return self._offMineReward
end

function DigMinePlayer:setOffMineMergeReward(reward)
	self._offMineMergeRewardReward = reward
end

function DigMinePlayer:getOffMineMergeReward()
	return self._offMineMergeRewardReward
end

function DigMinePlayer:loadDBData(cache_buf)
	if #cache_buf > 0 then
		local datas, errCode = protobuf.decode("DigMineProtocol", cache_buf)
		self:setExchangeCount(datas.exchangeCount)
		self:setExchangeTime(datas.exchangeTime)
		self:setLastLogout(datas.out)
		self:setNewOffMine(datas.new)
	end
end

function DigMinePlayer:cast2DB()
	local dbData = {
		exchangeCount = self:getExchangeCount(),
		exchangeTime = self:getExchangeTime(),
		out = os.time(),
		new = self:getNewOffMine(),
	}
	local cache_buff = protobuf.encode("DigMineProtocol", dbData)
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_DIGMINE, cache_buff, #cache_buff)
end