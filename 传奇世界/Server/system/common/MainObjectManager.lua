--MainObjectManager.lua
--/*-----------------------------------------------------------------
--* Module:  MainObjectManager.lua
--* Author:  YangXi
--* Modified: 2014年6月24日
--* Purpose: Implementation of the class MainObjectManager
--* 主线目标
-------------------------------------------------------------------*/

-- 目标类型
MainObjectType = {
	skill = 1,		-- 技能
	equip = 2,		-- 装备
	boss = 3,		-- 打宝
	wing = 4,		-- 翅膀
	faction = 5,	-- 争霸
	artifact = 6, 	-- 神器
}



MainObjectManager = class()

function MainObjectManager:__init()
	self._playerMainObject = {}			-- 玩家的主线目标数据

	self._mainObjectConfig = {}			-- 主线目标配置
	self._typeObjectMap = {}			-- 类型和目标id的映射

	local datas = require "data.GrowUpTarget"
	for _, data in pairs(datas) do
		local config = {}
		config.q_id = tonumber(data.q_id)
		config.q_level = tonumber(data.q_level)
		config.q_type = tonumber(data.q_type)
		if data.q_reward then
			config.q_reward = unserialize(data.q_reward)
		else
			config.q_reward = {}
		end

		self._mainObjectConfig[config.q_id] = config
		self._typeObjectMap[config.q_type] = config.q_id
	end

	g_listHandler:addListener(self)
end

function MainObjectManager:addPlayerData(roleSID)
	self._playerMainObject[roleSID] = {doneObject = {}, takeReward = {}}
end

-- 加载主线目标数据
function MainObjectManager:loadDBdata(roleSID, data)
	local playerObject = self._playerMainObject[roleSID]
	
	for _, objectID in pairs(data.doneObjectID) do
		playerObject.doneObject[objectID] = true
	end

	for _, objectID in pairs(data.takeRewardObjectID) do
		playerObject.takeReward[objectID] = true
	end
end

-- 保存数据
function MainObjectManager:saveDB(roleSID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		local commonInfo = g_commonMgr:getCommonInfo(player:getID())
		if commonInfo then
			commonInfo:cast2db()
		end
	end
end

function MainObjectManager:writeObject(roleSID, data)
	local playerObject = self._playerMainObject[roleSID]
	if not playerObject then
		return
	end

	data.mainObject = {doneObjectID = {}, takeRewardObjectID = {}}
	for objectID, _ in pairs(playerObject.doneObject) do
		table.insert(data.mainObject.doneObjectID, objectID)
	end

	for objectID, _ in pairs(playerObject.takeReward) do
		table.insert(data.mainObject.takeRewardObjectID, objectID)
	end
end

-- 玩家加载
function MainObjectManager:onPlayerLoaded(player)
	if not player then
		return
	end

	local roleSID = player:getSerialID()

	local playerObject = self._playerMainObject[roleSID]
	if not playerObject then
		return
	end

	local ret = {}
	ret.doneObjectID = {}
	ret.takeRewardObjectID = {}

	for objectID, _ in pairs(playerObject.doneObject) do
		table.insert(ret.doneObjectID, objectID)
	end

	for objectID, _ in pairs(playerObject.takeReward) do
		table.insert(ret.takeRewardObjectID, objectID)
	end

	fireProtoMessage(player:getID(), COMMON_SC_GETMAINOBJECT_RET, "GetMainObjectRetProtocol", ret)
end

-- 玩家下线
function MainObjectManager:onPlayerOffLine(player)
	-- if not player then
	-- 	return
	-- end

	-- local roleSID = player:getSerialID()

	-- self._playerMainObject[roleSID] = nil
end

-- 事件通知
function MainObjectManager:notify(roleSID, notfiyType, ...)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end

	local playerObject = self._playerMainObject[roleSID]
	if not playerObject then
		return
	end

	local flag = false
	if notfiyType == MainObjectType.skill then
		flag = true
	elseif notfiyType == MainObjectType.equip then
		local itemMgr = player:getItemMgr()
		if itemMgr == nil then
			return
		end

		for i = 1, Item_EquipPosition_Foot do
			local item = itemMgr:findItem(i, Item_BagIndex_EquipmentBar)
			if item then
				local itemProto = g_entityMgr:getConfigMgr():getItemProto(item:getProtoID())
				if itemProto and itemProto.defaultColor >= 3 then
					flag = true
					break
				end
			end
		end
	elseif notfiyType == MainObjectType.boss then
		flag = true
	elseif notfiyType == MainObjectType.wing then
		local level = select(1, ...)
		local curPomoteTime = select(2, ...)

		if level == 1 and curPomoteTime == 5 then
			flag = true
		end
	elseif notfiyType == MainObjectType.faction then
		flag = true
	elseif notfiyType == MainObjectType.artifact then
		flag = true
	end	

	if not flag then
		return
	end

	local id = self._typeObjectMap[notfiyType]
	if not id then
		return
	end

	if playerObject.doneObject[id] then
		return
	end

	playerObject.doneObject[id] = true

	local ret = {}
	ret.doneObjectID = {}
	ret.takeRewardObjectID = {}

	for objectID, _ in pairs(playerObject.doneObject) do
		table.insert(ret.doneObjectID, objectID)
	end

	for objectID, _ in pairs(playerObject.takeReward) do
		table.insert(ret.takeRewardObjectID, objectID)
	end

	fireProtoMessage(player:getID(), COMMON_SC_GETMAINOBJECT_RET, "GetMainObjectRetProtocol", ret)

	self:saveDB(roleSID)
end

function MainObjectManager:clientNotify(roleSID, objectType)
	if objectType == MainObjectType.artifact then
		self:notify(roleSID, objectType)
	end
end

-- 领取奖励
function MainObjectManager:takeReward(roleSID, objectID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then
		return
	end

	local playerObject = self._playerMainObject[roleSID]
	if not playerObject then
		return
	end

	local objectConfig = self._mainObjectConfig[objectID]
	if not objectConfig then
		return
	end

	if not playerObject.doneObject[objectID] then
		fireProtoSysMessage(0, player:getID(), EVENT_COMMON_SETS, COMMON_ERR_TAKE_OBJECT_REWARD_OBJECT_NOT_DONE , 0, {})
		return
	end

	if player:getLevel() < objectConfig.q_level then
		fireProtoSysMessage(0, player:getID(), EVENT_COMMON_SETS, COMMON_ERR_TAKE_OBJECT_REWARD_LEVEL , 0, {})
		return
	end

	if playerObject.takeReward[objectID] then
		fireProtoSysMessage(0, player:getID(), EVENT_COMMON_SETS, COMMON_ERR_TAKE_OBJECT_REWARD_TAKED , 0, {})
		return
	end

	local itemMgr = player:getItemMgr()
	if not itemMgr then
		return
	end

	local emptySize = itemMgr:getEmptySize(Item_BagIndex_Bag)
	if emptySize < #objectConfig.q_reward then
		fireProtoSysMessage(0, player:getID(), EVENT_COMMON_SETS, COMMON_ERR_TAKE_OBJECT_BAG , 0, {})
		return
	end

	for _, reward in ipairs(objectConfig.q_reward) do
		itemMgr:addItem(Item_BagIndex_Bag, reward.itemID, reward.count, reward.bind)
	end
	
	playerObject.takeReward[objectID] = true

	local ret = {}
	ret.objectID = objectID

	fireProtoMessage(player:getID(), COMMON_SC_GETMAINOBJECTREWARD_RET, "GetMainObjectRewardRetProtocol", ret)

	self:saveDB(roleSID)
end

g_MainObjectMgr = MainObjectManager()



