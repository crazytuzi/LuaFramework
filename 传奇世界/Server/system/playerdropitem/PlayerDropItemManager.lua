--PlayerDropItemManager.lua
--/*-----------------------------------------------------------------
 --* Module:  PlayerDropItemManager.lua
 --* Author:  gongyingqi
 --* Modified: 2016年2月5日
 --* Purpose: 玩家死亡爆物管理器
 -------------------------------------------------------------------*/
require ("system.playerdropitem.PlayerDropItemConstant")

PlayerDropItemInfo = class()
local prop = Property(PlayerDropItemInfo)
prop:accessor("roleSID")

function PlayerDropItemInfo:__init(roleSID)
	prop(self, "roleSID", roleSID)

	--数据存这里，存数据库也是这个结构
	self._playerdropitem_datas = 
	{
		lastDropTick = 0,			--上次掉落装备时间
		lastDropEquipPos = Item_EquipPosition_Unknown,	--上次掉落装备位置
		deathTicks = {},			--死亡时间记录
	}
end

function PlayerDropItemInfo:__release()
end

--保存到数据库
function PlayerDropItemInfo:cast2db()
	local cache_buff = self:writeObject()
	g_engine:savePlayerCache(self:getRoleSID(), FIELD_PLAYERDROPITEM, cache_buff, #cache_buff)
end

--保存到数据库
function PlayerDropItemInfo:writeObject()
	return protobuf.encode("PlayerDropItemProtocol", self._playerdropitem_datas)
end

--加载数据库数据
function PlayerDropItemInfo:loadDBdata(cache_buf)
	if #cache_buf > 0 then	
		local datas = protobuf.decode("PlayerDropItemProtocol", cache_buf)
		table.sort( datas.deathTicks, function(a, b) return a <= b end )
		self._playerdropitem_datas = 
		{
			lastDropTick = datas.lastDropTick,
			lastDropEquipPos = datas.lastDropEquipPos,
			deathTicks = datas.deathTicks	
		}
	end
end

--¸üÐÂÊ±¼ä´Á
-- function PlayerDropItemInfo:updateStamp()
-- 	local timeStamp = time.toedition("day")
-- 	if tonumber(timeStamp) <= self._playerdropitem_datas.dropStamp then
-- 		return
-- 	end
-- 	self._playerdropitem_datas.dropStamp = time.toedition("day")+1
-- 	self._playerdropitem_datas.dailyDeathNum = 0
-- 	self:cast2db()
-- end

local function dropPlayerEquip(player, equipPos, dropInfo, killer)
	--掉落装备
	print('drop equipPos'..equipPos)
	player:dropItemWhenDied(equipPos, killer, Item_BagIndex_EquipmentBar)
	--记录掉落咯
	dropInfo:recordDropInfo(equipPos)
end

--记录掉落时间
function PlayerDropItemInfo:recordDropInfo(pos)
	print('PlayerDropItemInfo:recordDropInfo')
	self._playerdropitem_datas.lastDropTick = os.time()
	self._playerdropitem_datas.lastDropEquipPos = pos
	--print(self._playerdropitem_datas.lastDropTick, self._playerdropitem_datas.lastDropEquipPos)
	self:cast2db()
end

--更新死亡记录
function PlayerDropItemInfo:updateDeathRecord()
	local records = self._playerdropitem_datas.deathTicks
	local now = os.time()
	--删除x秒以外的死亡记录
	local size = table.size(records)
	if size <= 0 then 
		print('no death record')
		return 
	end
	-- print('deathRecord size:'..size)
	-- for k,v in pairs(records) do
	-- 	print(k,v)
	-- end
	local delIdx = 0
	for i = 1, size do
		if now - records[i] >= EQUIP_DROP_JUDGE[1] then
			delIdx = i
		else
			break
		end
	end

	if delIdx > 0 then
		for j=1,delIdx do
			table.remove(records, 1)
		end
	end
	self:cast2db()
end

--记录死亡时间
function PlayerDropItemInfo:recordDeathTick()
	self:updateDeathRecord()
	table.insert(self._playerdropitem_datas.deathTicks, os.time())
	self:cast2db()
end

--获取X秒钟死亡次数
function PlayerDropItemInfo:getDeathNum()
	self:updateDeathRecord()
	return table.size(self._playerdropitem_datas.deathTicks)
end

--获取上次掉装备时间和位置
function PlayerDropItemInfo:getLastDropEquipInfo()
	return self._playerdropitem_datas.lastDropTick, self._playerdropitem_datas.lastDropEquipPos
end

--¼ì²éÊÇ·ñ¿ÉµôÂä
-- function PlayerDropItemInfo:checkDrop()
-- 	-- self:updateStamp()
	
-- 	print("PlayerDropItemInfo:checkDrop", self:getRoleSID(), os.time(), self._playerdropitem_datas.dropStamp, self._playerdropitem_datas.dailyDeathNum, self._playerdropitem_datas.lastDropTick, self._playerdropitem_datas.orangeDeathTick, self._playerdropitem_datas.orangeDeathNum)
	
-- 	--ÏÈ¼ì²é´ÎÊý
-- 	if self._playerdropitem_datas.dailyDeathNum < DAILY_DROP_BEGIN_DEATH_NUM then
-- 		self._playerdropitem_datas.dailyDeathNum = self._playerdropitem_datas.dailyDeathNum + 1
-- 		self:cast2db()
-- 		return false
-- 	end
	
-- 	--ÔÙ¼ì²éÊ±¼ä
-- 	local dropTime = os.time()
-- 	if dropTime - self._playerdropitem_datas.lastDropTick < DAILY_DROP_CD then	
-- 		return false
-- 	end
-- 	return true
-- end

--¼ì²é³ÈÉ«×°±¸¶îÍâµôÂä
-- function PlayerDropItemInfo:checkDropOrange()
-- 	--ÉÏÃæË¢ÐÂ¹ýÁË£¬ÕâÀï²»Ë¢ÁË
	
-- 	local deathTime = os.time()
-- 	if deathTime - self._playerdropitem_datas.orangeDeathTick > EQUIP_ORANGE_EXTRA[0] then
-- 		self._playerdropitem_datas.orangeDeathTick = deathTime
-- 		self._playerdropitem_datas.orangeDeathNum = 1
-- 		self:cast2db()
-- 		return false
-- 	end
	
-- 	self._playerdropitem_datas.orangeDeathNum = self._playerdropitem_datas.orangeDeathNum + 1
-- 	if self._playerdropitem_datas.orangeDeathNum < EQUIP_ORANGE_EXTRA[1] then
-- 		self:cast2db()
-- 		return false		
-- 	end
	
-- 	self._playerdropitem_datas.orangeDeathTick = deathTime
-- 	self._playerdropitem_datas.orangeDeathNum = 1
-- 	self:cast2db()
-- 	return true
-- end

PlayerDropItemManager = class(nil, Singleton)

--全局对象定义
function PlayerDropItemManager:__init()
	self._PlayerDropItemInfos = {}     --在线玩家爆物信息表	
	g_listHandler:addListener(self)
end

function PlayerDropItemManager:__release()
	self._PlayerDropItemInfos = {}
end

--玩家注销
function PlayerDropItemManager:onPlayerOffLine(player)
	local roleID = player:getID()
	self._PlayerDropItemInfos[roleID] = nil
end

--玩家数据加载完成
function PlayerDropItemManager:loadDBDataImpl(player, cache_buf, roleSid)
	local playerdropiteminfo = self:getInfo(player)
	if playerdropiteminfo then
		playerdropiteminfo:loadDBdata(cache_buf)
	end
end

--玩家数据加载完成
function PlayerDropItemManager.loadDBData(player, cache_buf, roleSid)		
	g_PlayerDropItemMgr:loadDBDataImpl(player, cache_buf, roleSid)
end

--获取掉落数据
function PlayerDropItemManager:getInfo(player)
	local roleID = player:getID()
	local roleSID = player:getSerialID()
	if not self._PlayerDropItemInfos[roleID] then
		local playerdropiteminfo = PlayerDropItemInfo(roleSID)
		self._PlayerDropItemInfos[roleID] = playerdropiteminfo
	end
	return self._PlayerDropItemInfos[roleID]
end

--掉落装备物品
function PlayerDropItemManager:dropEquip(player, mapInfo, killer)
	print('PlayerDropItemManager:dropEquip')
	if not player then 
		warning('not find player')
		return  
	end

	if not mapInfo then
		warning('not find cur map')
		return
	end

	if mapInfo.q_die_equip and mapInfo.q_die_equip == 1 then
		print('cur map not drop equip')
		return
	end

	local dropInfo = self:getInfo(player)
	if not dropInfo then
		warning('not find player drop info')
		return
	end

	local itemMgr = player:getItemMgr()
	local equipBag = itemMgr:getBag(Item_BagIndex_EquipmentBar)

	local deathNum = dropInfo:getDeathNum()
	local lastDropTick, lastDropEquipPos = dropInfo:getLastDropEquipInfo()
	--print(time.tostring(lastDropTick), lastDropEquipPos)
	local gap = os.time() - lastDropTick
	print('deathNum:'..deathNum..' time gap:'..gap)
	--print(EQUIP_DROP_JUDGE[1], EQUIP_DROP_JUDGE[2])
	if deathNum > EQUIP_DROP_JUDGE[2] and gap > EQUIP_DROP_JUDGE[1] then
		print('20% random drop a equip')
		local dropRate = math.random(0, 100)
		if dropRate >= EQUIP_DROP_RATE then
			print(dropRate..'-20% random result: not drop equip')
			return
		end

		--随机掉落一件装备,武器衣服除外
		local dropRate1 = math.random(3, table.size(EQUIP_INDEX) + 1)
		local equipPos = EQUIP_INDEX[dropRate1]

		--取装备
		local item = itemMgr:findItem(equipPos, Item_BagIndex_EquipmentBar)
		--没有装备则返回
		if item == nil then
			print('cur pos no equip:'..equipPos)
			return
		end
		return dropPlayerEquip(player, equipPos, dropInfo, killer)
	end

	--角色x秒内掉过装备
	local isDropEquip = false
	if lastDropTick < EQUIP_DROP_TIME_SCOPE then
		isDropEquip = true
	end
	
	--取随机
	local rd = math.random(1, DROP_RATE_MAX)
	local equipPosition = Item_EquipPosition_Unknown
	for _, positioninfo in pairs(EQUIP_POSITIONS or table.empty) do
		if rd <= positioninfo[2] then
			equipPosition = positioninfo[1]
			break
			end
		rd = rd - positioninfo[2]
	end
	
	--取装备
	local item = itemMgr:findItem(equipPosition, Item_BagIndex_EquipmentBar)
	--没有装备则返回
	if item == nil then
		return
	end
	
	--获取物品品质
	local equipColor = item:getProto().defaultColor
	--获取物品品质对应系数
	local equipColorRate = EQUIP_COLOR_RATE[equipColor]
	-- --获取物品等级
	-- local equipLevel = item:getLevel()
	-- --获取物品等级对应系数
	-- local equipLevelRate = 1
	-- for _, info in pairs(EQUIP_LEVEL_RATE or table.empty) do
	-- 	if equipLevel <= info[1] then
	-- 		equipLevelRate = info[2]
	-- 		break
	-- 	end
	-- end

	--获取物品强化等级
	--local equipStrengthLevel = item:getEquipProp():getStrengthLevel()
	local equipStrengthLevel = 0
	local equipProp = item:getEquipProp()
	if equipProp then
		equipStrengthLevel = equipProp:getStrengthLevel()
	end
	--获取物品强化等级对应系数
	local equipStrengthLevelRate = 0
	for _, info in pairs(EQUIP_STRENTH_RATE or table.empty) do
		if equipStrengthLevel >= info[1] then
			if equipStrengthLevel <= info[2] then
				equipStrengthLevelRate = info[3]
				break
			end
		end
	end
	--获取角色pk值
	local playerPKValue = player:getPK()
	for _, info in pairs(EQUIP_PKVALUE_RATE or table.empty) do
		if playerPKValue >= info[1] then
			if playerPKValue <= info[2] then
				playerPKValueRate = info[3]
				break
			end
		end
	end	
	print('equipColor:'..equipColor..' equipStrengthLevel:'..equipStrengthLevel..'pk:'..playerPKValue)
	print('equipColorRate:'..equipColorRate..' equipStrengthLevelRate:'..equipStrengthLevelRate..' playerPKValueRate:'..playerPKValueRate)
	local dropRate2 = equipColorRate * equipStrengthLevelRate * playerPKValueRate
	local dropRate3 = math.random(0, DROP_RATE_MAX)

	--与上次掉落位置相同
	if isDropEquip  and lastDropEquipPos == equipPosition then
		print('cur drop pos and last drop Pos same')
		local rate = EQUIP_AGAIN_DROP_RATE * DROP_RATE_MAX / 100
		if dropRate2 > rate then
			dropRate2 = rate
		end
	end
	
	print('random result:'..dropRate3..' dropRate:'..dropRate2)
	--概率不到返回
	if dropRate3 > dropRate2 then
		print('random result not drop')
		return
	end

	g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.dropEquip, equipPosition, killer:getSerialID())
	
	return dropPlayerEquip(player, equipPosition, dropInfo, killer)
end

--掉落包裹物品
function PlayerDropItemManager:dropBag(player, mapInfo, killer)
	print('PlayerDropItemManager:dropBag')
	if not player then 
		warning('not find player')
		return 
	end

	if not mapInfo then
		warning('not find cur map')
		return
	end

	if mapInfo.q_die_pack and mapInfo.q_die_pack == 1 then
		print('cur map not drop bag item')
		return
	end

	local dropRate1 = math.random(0, 100)
	--print('drop item random:'..dropRate1)
	if dropRate1 >= BAG_ITEM_DROP_RATE then
		print('random result:not drop item')
		return
	end

	local dropnum = math.random(1, BAG_ITEM_DROP_NUM)

	--掉物品
	player:dropBagWhenDied(dropnum, BAG_ITEM_DROP_MAX, true, killer)
end

--玩家死亡
function PlayerDropItemManager:onPlayerDied(player, killerID)
	print('PlayerDropItemManager:onPlayerDied()')
	local killer = g_entityMgr:getPlayer(killerID)
	if not killer then return end

	local playerdropiteminfo = self:getInfo(player)
	if not playerdropiteminfo then
		warning('not find player drop info')
		return
	end

	--记录死亡时间
	playerdropiteminfo:recordDeathTick()

	--获取地图信息
	local curMap = player:getMapID()
	local mapInfo = {}
	local maps = require "data.MapDB"
	for _, info in pairs(maps) do
		if info.q_map_id == curMap then
			mapInfo = info
		end
	end 

	self:dropEquip(player, mapInfo, killer)
	self:dropBag(player, mapInfo, killer)
end

function PlayerDropItemManager.getInstance()
	return PlayerDropItemManager()
end

g_PlayerDropItemMgr = PlayerDropItemManager.getInstance()