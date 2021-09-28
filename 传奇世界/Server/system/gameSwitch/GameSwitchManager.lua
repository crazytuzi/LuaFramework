--GameSwitchManager.lua
--/*-----------------------------------------------------------------
 --* Module:  GameSwitchManager.lua
 --* Author:  seezon
 --* Modified: 2016年3月21日
 --* Purpose: 系统开关管理器
 -------------------------------------------------------------------*/
require ("system.gameSwitch.GameSwitchConstant")


GameSwitchManager = class(nil, Singleton)

function GameSwitchManager:__init()
	self._gameSwitch = {}
	g_listHandler:addListener(self)
end

--加载开关数据
function GameSwitchManager:onLoadFunSwitchData(data)
	if data then
		self._gameSwitch = unserialize(data)
	end
end

--发送最新的系统开关数据给登陆的客户端
function GameSwitchManager:notifyClient(roleID)
	local retData = {}
	for _, funId in pairs(self._gameSwitch) do
		local data = {
				funID = funId,
				isActive = false,
		}
		table.insert(retData.gameSwitch,data)
	end
	fireProtoMessage(roleID,GAMECONFIG_SC_GAME_SWITCH,"GameConfigSwitchRetProtocol", retData)

end

--更新开关系统
function GameSwitchManager:updateSwitch(funId, isActive)
	local retData = {}
	table.insert(retData.gameSwitch,{funID = funId,isActive = isActive})
	boardProtoMessage(GAMECONFIG_SC_GAME_SWITCH,"GameConfigSwitchRetProtocol",retData)
end

function GameSwitchManager:setFunActive(funId, isActive)
	--funId 定义的功能ID   isActive为true表示开启功能  为false表示关闭功能
	local dealRet = self:onDealBasicFunc(funId, isActive)
	if dealRet then return end

	if DefaultGameSwitch[funId] then
		DefaultGameSwitch[funId]:setActive(isActive)

		if isActive and table.contains(self._gameSwitch, funId) then
			table.removeValue(self._gameSwitch, funId)
		end

		if not isActive and not table.contains(self._gameSwitch, funId) then
			table.insert(self._gameSwitch, funId)
			
			--关闭系统的话，吧正在进行的活动强制关闭
			local acData = g_normalLimitMgr:getAllActivityConfig()
			local ids = {}
			for _, record in pairs(acData or {}) do
				if funId == GAME_SWITCH_ID_ENVOY then
					table.insert(ids, ACTIVITY_NORMAL_ID.ENVOY)
				elseif funId == GAME_SWITCH_ID_LUOXIA then
					table.insert(ids, ACTIVITY_NORMAL_ID.LUOXIA)
				elseif funId == GAME_SWITCH_ID_WORLDBOSS then
					table.insert(ids, ACTIVITY_NORMAL_ID.WORLD_BOSS)
				elseif funId == GAME_SWITCH_ID_GIVEWINE then
					table.insert(ids, ACTIVITY_NORMAL_ID.GIVE_WINE)		
				end 
			end

			for _,id in pairs(ids) do
				g_normalLimitMgr:gmOff(id)
			end

		end
		self:updateSwitch(funId, isActive)
		updateCommonData(COMMON_DATA_ID_FUN_SWITCH, self._gameSwitch)
	end
end

--玩家上线
function GameSwitchManager:onPlayerLoaded(player)
	self:notifyClient(player:getID())
end

--掉线登陆
function GameSwitchManager:onActivePlayer(player)
	self:notifyClient(player:getID())
end

function GameSwitchManager:onDealBasicFunc(funId, isActive)
	if table.contains(BASICK_FUNC,funId) then
		if GAME_SWITCH_ID_MONATTACK == funId then
			self:onDealMonAttack(funId, isActive)
			return true
		elseif GAME_SWITCH_ID_TRADE == funId then
			self:onDealTrade(funId, isActive)
			return true
		elseif GAME_SWITCH_MALL == funId then
			self:onDealMall(funId, isActive)
			return true
		elseif GAME_SWITCH_MYSTERYSHOP == funId then
			self:onDealMysteryshop(funId, isActive)
			return true
		elseif GAME_SWITCH_MERITORIOUS == funId then
			self:onDealMeritorious(funId, isActive)
			return true
		elseif GAME_SWITCH_FACTIONSHOP == funId then
			self:onDealFactionshop(funId, isActive)
			return true
		elseif GAME_SWITCH_ID_FLOWER == funId then
			self:onDealFlower(funId, isActive)
			return true
		elseif GAME_SWITCH_ID_ARROW == funId then
			self:onDealArrow(funId, isActive)
			return true
		elseif GAME_SWITCH_ID_TEAM == funId then
			self:onDealTeam(funId, isActive)
			return true
		elseif GAME_SWITCH_TOWERCOPY == funId then
			if isActive then
				g_copyMgr:setTowerCopySwitch(1)
			else
				g_copyMgr:setTowerCopySwitch(0)
			end
			self:toClientAndCastDB(funId, isActive)
			return true
		elseif GAME_SWITCH_SINGLECOPY == funId then
			if isActive then
				g_copyMgr:setSingleCopySwitch(1)
			else
				g_copyMgr:setSingleCopySwitch(0)
			end
			self:toClientAndCastDB(funId, isActive)
			return true
		else
		end
	end
	return false
end

function GameSwitchManager:onDealMonAttack(funId, isActive)
	if g_MonAttackMgr then
		if isActive then
			g_MonAttackMgr:setxtActive(1)			
		else
			g_MonAttackMgr:setxtActive(0)			
		end

		g_normalLimitMgr:gmOff(ACTIVITY_NORMAL_ID.MON_ATTACK)

		self:toClientAndCastDB(funId, isActive)
	end
end

function GameSwitchManager:onDealTrade(funId, isActive)
	if g_tradeMgr then
		if isActive then
			g_tradeMgr:setTradeActive(1)
		else
			g_tradeMgr:setTradeActive(0)
		end

		self:toClientAndCastDB(funId, isActive)
	end
end

function GameSwitchManager:onDealMall(funId, isActive)
	if g_tradeMgr then
		if isActive then
			g_tradeMgr:setMallActive(1)
		else
			g_tradeMgr:setMallActive(0)
		end

		self:toClientAndCastDB(funId, isActive)
	end
end

function GameSwitchManager:onDealMeritorious(funId, isActive)
	if g_tradeMgr then
		if isActive then
			g_tradeMgr:setMeritoriousActive(1)
		else
			g_tradeMgr:setMeritoriousActive(0)
		end

		self:toClientAndCastDB(funId, isActive)
	end
end

function GameSwitchManager:onDealFactionshop(funId, isActive)
	if g_tradeMgr then
		if isActive then			
			g_tradeMgr:setFactionshopActive(1)
		else
			g_tradeMgr:setFactionshopActive(0)
		end

		self:toClientAndCastDB(funId, isActive)
	end
end

function GameSwitchManager:onDealMysteryshop(funId, isActive)
	if g_mystShopMgr then
		if isActive then
			g_mystShopMgr:setMysteryshopActive(1)
		else
			g_mystShopMgr:setMysteryshopActive(0)
		end

		self:toClientAndCastDB(funId, isActive)
	end
end

function GameSwitchManager:onDealFlower(funId, isActive)
	if g_SpillFlowerMgr then
		if isActive then
			g_SpillFlowerMgr:setFlowerActive(1)
		else
			g_SpillFlowerMgr:setFlowerActive(0)
		end

		self:toClientAndCastDB(funId, isActive)
	end
end

function GameSwitchManager:onDealArrow(funId, isActive)
	if g_SpillFlowerMgr then
		if isActive then
			g_SpillFlowerMgr:setArrowActive(1)
		else
			g_SpillFlowerMgr:setArrowActive(0)
		end

		self:toClientAndCastDB(funId, isActive)
	end
end

function GameSwitchManager:onDealTeam(funId, isActive)	 
	if g_teamMgr then
		if isActive then
			g_teamMgr:setxtActive(1)
		else
			g_teamMgr:setxtActive(0)
		end

		self:toClientAndCastDB(funId, isActive)
	end
end

function GameSwitchManager:toClientAndCastDB(funId, isActive)
	if isActive and table.contains(self._gameSwitch, funId) then
		table.removeValue(self._gameSwitch, funId)
	end

	if not isActive and not table.contains(self._gameSwitch, funId) then
		table.insert(self._gameSwitch, funId)
	end

	self:updateSwitch(funId, isActive)
	updateCommonData(COMMON_DATA_ID_FUN_SWITCH, self._gameSwitch)
end

function GameSwitchManager.getInstance()
	return GameSwitchManager()
end

g_gameSwitchMgr = GameSwitchManager.getInstance()