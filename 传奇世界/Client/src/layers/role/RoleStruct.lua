local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
local MroleOp = require("src/config/roleOp")
local MObserver = require "src/young/observer"
local Mconvertor = require "src/config/convertor"
-------------------------------------------------------------
mData = {}
-------------------------------------------------------------
mObservable = MObserver.new()

-- 观察者监听
register = function(self, observer)
	self.mObservable:register(observer)
end

-- 观察者取消监听
unregister = function(self, observer)
	self.mObservable:unregister(observer)
end


-- 向观察者发送广播
broadcast = function(self, ...)
	self.mObservable:broadcast(self, ...)
end
-------------------------------------------------------------
local popAction = function(item, attrId, buff, fmt)
	local value = buff:readByFmt(fmt)
	if item then item[attrId] = value end
	return value
end
-------------------------------------------------------------
local popStringData = function(item, attrId, buff)
	return popAction(item, attrId, buff, "S")
end

local popCharData = function(item, attrId, buff)
	return popAction(item, attrId, buff, "c")
end

local popShortData = function(item, attrId, buff)
	return popAction(item, attrId, buff, "s")
end

local popIntData = function(item, attrId, buff)
	return popAction(item, attrId, buff, "i")
end
-------------------------------------------------------------
local tAttrSetAction = {
	-- 角色名字
	[ROLE_NAME] = popStringData,
	
	-- 帮派名字
	[PLAYER_FACTIONNAME] = popStringData,
	-- 宠物主人名字
	[ROLE_HOST_NAME] = popStringData,
	-- 雕像、旗帜名字
	[ROLE_STATUS_NAME] = popStringData,
	-- 称号
	--[PLAYER_TITLE] = popStringData,
	-- -- 等级
	-- [ROLE_LEVEL] = popCharData,
	
	-- -- 职业
	-- [ROLE_SCHOOL] = popCharData,
	-- -- 方向
	-- [ROLE_DIR] = popCharData,	
	-- -- 性别
	-- [PLAYER_SEX] = popCharData,
	
	-- -- 攻击速度
	-- [PLAYER_AT_SPEED] = popCharData,
	
	-- -- 幸运值
	-- [PLAYER_LUCK] = popCharData,

	-- -- 攻击模式
	-- [PLAYER_PATTERN] = popCharData,
	-- -- vip
	-- [PLAYER_VIP] = popCharData,

	-- 重装使者玩家持有物品
	[PLAYER_HOLD_MAT] = popStringData,

	--挖矿物品
	[PLAYER_HOLD_MINE] = popStringData,

	--旗帜
	[PLAYER_BANNER] = popStringData,
	
	-- --增加战士伤害几率
	-- [PLAYER_AT_ADD] = popShortData,
	
	-- --增加法师伤害几率
	-- [PLAYER_MT_ADD] = popShortData,
	
	-- --增加道士伤害几率
	-- [PLAYER_DT_ADD] = popShortData,
	
	-- --减少战士伤害几率
	-- [PLAYER_AT_SUB] = popShortData,
	
	-- --减少法师伤害几率
	-- [PLAYER_MT_SUB] = popShortData,
	
	-- --减少道士伤害几率
	-- [PLAYER_DT_SUB] = popShortData,
}
-------------------------------------------------------------
-- 着装包裹数据解析
function onDressUpdate(buff, isMe, roleId)
	local MPackManager = require "src/layers/bag/PackManager"
	--local str = buff:popString()
	--dump(str, "str")
	--dump("+++++++++++++++++++++++++++++++++++++++++++++++")
	return MPackManager:updateDressPack(isMe, roleId, buff)
	--dump("-----------------------------------------------")
end

-------------------------------------------------------------
-- 着装包裹数据解析
function onBuffUpdate(buff, isMe, roleId)
	--local buff_string = buff:popString() -- 忽略长度
	local buffTable = protobuf.decode("BuffProtocol", buff)
	local buffs = {}
	if buffTable and buffTable.buffs then
		for k,v in pairs(buffTable.buffs)do
			buffs[v.id] = v.tick
		end
	end
	return  buffs
end

setAttr = function(self, attrId, objId, buff, isMe, callback)
	local cb = callback or function() end
	local body_id = nil
	local save = isMe
	if (not isMe) then 
		save = (attrId == ROLE_HP or attrId == PLAYER_EQUIP_WING or attrId == PLAYER_EQUIP_RIDE
			or attrId == PLAYER_EQUIP_WEAPON or attrId == PLAYER_EQUIP_UPPERBODY
			or attrId == PLAYER_FACTIONID or attrId == PLAYER_SERVER_ID or  attrId == ROLE_SHOW
			or attrId == PLAYER_PK or attrId == ROLE_MODEL or attrId == ROLE_HOST_NAME or attrId == PLAYER_TEAMID 
			or attrId == ROLE_STATUS_NAME or attrId == PLAYER_FIGHT_TEAM_ID or attrId == PLAYER_SPECIAL_TITLE_ID) 
	end
	local ret = nil
	
	-- 着装包裹
	if attrId >= PLAYER_EQUIP_WEAPON and attrId <= PLAYER_EQUIP_MEDAL then
		local g_id ,event = onDressUpdate(buff.propString, isMe, objId)
		local item = self.mData[objId] or (save and {} or nil)
		if item ~= self.mData[objId] then self.mData[objId] = item end
		if save then self.mData[objId][attrId] = g_id end
		cb(attrId, objId, isMe, g_id ,event)
		ret = g_id
	elseif attrId == ROLE_BUFF then 
		--print("ROLE_BUFFROLE_BUFF")
		cb(attrId, objId, isMe, onBuffUpdate(buff.propString, isMe, objId) )
	else
		local item = self.mData[objId] or (save and {} or nil)
		if item ~= self.mData[objId] then self.mData[objId] = item end
		
		local old = item and item[attrId]
		
		local action = tAttrSetAction[attrId]
		if action then
			ret = buff.propString--action(item, attrId, buff)
		else
			ret = buff.propInt--popIntData(item, attrId, buff)
		end
		if save and item then item[attrId] = ret end
		----------------------------------------------
		--[[
		--此处暂时强制处理性别
		if attrId == PLAYER_SEX then
			ret = 1
			if self.mData[objId] and self.mData[objId][ROLE_SCHOOL] and self.mData[objId][ROLE_SCHOOL]==2 then
				ret = 2
			end
			if isMe then self.mData[objId][PLAYER_SEX] = ret end
		end
		-----------------------------
		]]
		if attrId == PLAYER_EQUIP_WING or attrId == PLAYER_EQUIP_RIDE then
			cb( attrId, objId, isMe, ret)
		end
		
		self:broadcast(attrId, objId, isMe, ret, old)
	end
	return ret
end

setAttrHPByValue = function(self, objId, value)
	local item = self.mData[objId]
	if not item then return end
	item[ROLE_HP] = value
end
-------------------------------------------------------------
-- local tAttrGetAction = {
-- 	--[[
-- 	-- 移动速度
-- 	[ROLE_MOVE_SPEED] = function(item, attrId)
-- 		local base_speed = getConfigItemByKeys("roleData", {"q_zy", "q_level", }, {1, 1}, "q_move_speed")
-- 		local percentage = item[attrId] or 100
-- 		return math.floor(base_speed*percentage/100)
-- 	end,
-- 	--]]
-- }

local tAttrGetFromCfg = {
	-- 角色名字
	[ROLE_NAME] = function(school, level)
		return ""
		--error("角色名未知")
	end,
	
	-- 等级
	[ROLE_LEVEL] = function(school, level)
		return 1
	end,
	
	-- 职业
	[ROLE_SCHOOL] = function(school, level)
		return 1
		--error("角色职业未知")
	end,
	
	-- 性别
	[PLAYER_SEX] = function(school, level)
		return 1
		--error("角色性别未知")
	end,
	
	-- 角色模型
	[ROLE_MODEL] = function(school, level)
		--error("角色模型未知")
		return 0
	end,
	
	-- 幸运值|诅咒值(负数代表诅咒)
	[PLAYER_LUCK] = function(school, level)
		return MroleOp:luck(school, level)
	end,
	
	-- 最小物理攻击
	[ROLE_MIN_AT] = function(school, level)
		local min, max = MroleOp:PAttack(school, level)
		return min
	end,
	
	-- 最大物理攻击
	[ROLE_MAX_AT] = function(school, level)
		local min, max = MroleOp:PAttack(school, level)
		return max
	end,
	
	-- 最小物理防御
	[ROLE_MIN_DF] = function(school, level)
		local min, max = MroleOp:PDefense(school, level)
		return min
	end,
	
	-- 最大物理防御
	[ROLE_MAX_DF] = function(school, level)
		local min, max = MroleOp:PDefense(school, level)
		return max
	end,
	
	-- 最小魔法攻击
	[ROLE_MIN_MT] = function(school, level)
		local min, max = MroleOp:MAttack(school, level)
		return min
	end,
	
	-- 最大魔法攻击
	[ROLE_MAX_MT] = function(school, level)
		local min, max = MroleOp:MAttack(school, level)
		return max
	end,
	
	-- 最小道术攻击
	[ROLE_MIN_DT] = function(school, level)
		local min, max = MroleOp:TAttack(school, level)
		return min
	end,
	
	-- 最大道术攻击
	[ROLE_MAX_DT] = function(school, level)
		local min, max = MroleOp:TAttack(school, level)
		return max
	end,
	
	-- 最小魔法防御
	[ROLE_MIN_MF] = function(school, level)
		local min, max = MroleOp:MDefense(school, level)
		return min
	end,
	
	-- 最大魔法防御
	[ROLE_MAX_MF] = function(school, level)
		local min, max = MroleOp:MDefense(school, level)
		return max
	end,
	
	-- 最大HP
	[ROLE_MAX_HP] = function(school, level)
		return MroleOp:maxHP(school, level)
	end,
	
	-- 最大MP
	[ROLE_MAX_MP] = function(school, level)
		return MroleOp:maxMP(school, level)
	end,
	
	-- 升级所需经验值
	[PLAYER_NEXT_XP] = function(school, level)
		return MroleOp:upLevelExpNeed(school, level)
	end,
	
	-- 当前经验值
	[PLAYER_XP] = function(school, level)
		return 0
	end,
	
	-- 当前 HP
	[ROLE_HP] = function(school, level)
		return 0
	end,
	
	-- 当前 MP
	[ROLE_MP] = function(school, level)
		return 0
	end,
	
	-- 命中
	[ROLE_HIT] = function(school, level)
		return MroleOp:hit(school, level)
	end,
	
	-- 闪避
	[ROLE_DODGE] = function(school, level)
		return MroleOp:dodge(school, level)
	end,
	
	-- 暴击
	[ROLE_CRIT] = function(school, level)
		return 0
	end,
	
	-- 韧性
	[ROLE_TENACITY] = function(school, level)
		return 0
	end,
	
	-- 护身穿透
	[PLAYER_PROJECT_DEF] = function(school, level)
		return 0
	end,
	
	-- 护身
	[PLAYER_PROJECT] = function(school, level)
		return 0
	end,
	
	-- 冰冻|麻痹
	[PLAYER_BENUMB] = function(school, level)
		return 0
	end,
	
	-- 冰冻抵抗|麻痹抵抗
	[PLAYER_BENUMB_DEF] = function(school, level)
		return 0
	end,
	
	-- 游戏币
	[PLAYER_MONEY] = function(school, level)
		return 0
	end,
	
	-- 绑定游戏币
	[PLAYER_BINDMONEY] = function(school, level)
		return 0
	end,
	
	-- 元宝
	[PLAYER_INGOT] = function(school, level)
		return 0
	end,
	
	-- 绑定元宝
	[PLAYER_BINDINGOT] = function(school, level)
		return 0
	end,
	
	-- 帮会ID
	[PLAYER_FACTIONID] = function(school, level)
		return 0
	end,
	
	-- 帮会名字
	[PLAYER_FACTIONNAME] = function(school, level)
		return ""
	end,
	
	-- 移动速度
	[ROLE_MOVE_SPEED] = function(school, level)
		return 100--MroleOp:moveSpeed(school, level)
	end,
	
	-- 荣誉
	[PLAYER_HONOUR] = function(school, level)
		return 0
	end,
	
	-- PK值
	[PLAYER_PK] = function(school, level)
		return 0
	end,
	
	-- 战斗力
	[PLAYER_BATTLE] = function(school, level)
		return 0
	end,
	
	-- 真气
	[PLAYER_VITAL] = function(school, level)
		return 0
	end,
	
	-- 魂值
	[PLAYER_SOUL_SCORE] = function(school, level)
		return 0
	end,
	
	-- 功勋
	[PLAYER_MERITORIOUS] = function(school, level)
		return 0
	end,
	
	-- 魅力值
	[PLAYER_GLAMOUR] = function(school, level)
		return 0
	end,

	--领地战旗帜属性
	[PLAYER_BANNER] = function(school, level)
		return 0
	end,

	-- 对战士强悍
	[PLAYER_AT_ADD] = function(school, level)
		return 0
	end,
	
	-- 对法师强悍
	[PLAYER_MT_ADD] = function(school, level)
		return 0
	end,
	
	-- 对道士强悍
	[PLAYER_DT_ADD] = function(school, level)
		return 0
	end,
	
	-- 对战士坚韧
	[PLAYER_AT_SUB] = function(school, level)
		return 0
	end,
	
	-- 对法师坚韧
	[PLAYER_MT_SUB] = function(school, level)
		return 0
	end,
	
	-- 对道士坚韧
	[PLAYER_DT_SUB] = function(school, level)
		return 0
	end,
}
-------------------------------------------------------------
getAttr = function(self, attrId, objId)
	local objId = objId or (G_ROLE_MAIN and G_ROLE_MAIN.obj_id)
	if not objId then return nil end
	
	local item = self.mData[objId]
	if not item then return nil end
	
	--local action = nil
	
	-- action = tAttrGetAction[attrId]
	-- if action then return action(item, attrId) end
	-------------------------------
	local ret = nil
	
	ret = item[attrId]
	if ret ~= nil then return ret end
	-------------------------------
	local action = tAttrGetFromCfg[attrId]
	if action then
		local school = item[ROLE_SCHOOL] or 0
		local level = item[ROLE_LEVEL] or 0
		return action(school, level)
	end
end
-------------------------------------------------------------
local tCombatAttrAction = 
{
	[Mconvertor.ePAttack] = function(self, objId)
		return self:getAttr(ROLE_MIN_AT, objId), self:getAttr(ROLE_MAX_AT, objId)
	end,
	
	[Mconvertor.eMAttack] = function(self, objId)
		return self:getAttr(ROLE_MIN_MT, objId), self:getAttr(ROLE_MAX_MT, objId)
	end,
	
	[Mconvertor.eTAttack] = function(self, objId)
		return self:getAttr(ROLE_MIN_DT, objId), self:getAttr(ROLE_MAX_DT, objId)
	end,
	
	[Mconvertor.ePDefense] = function(self, objId)
		return self:getAttr(ROLE_MIN_DF, objId), self:getAttr(ROLE_MAX_DF, objId)
	end,
	
	[Mconvertor.eMDefense] = function(self, objId)
		return self:getAttr(ROLE_MIN_MF, objId), self:getAttr(ROLE_MAX_MF, objId)
	end,
}

-- 基础战斗属性值
combatAttr = function(self, name, objId)
	local lower, upper
	if type(name) == "number" then
		lower, upper = tCombatAttrAction[name](self, objId)
		return { ["["] = lower, ["]"] = upper }
	end
	
	if name == "all" then name = Mconvertor.eCombatAttrList end
	
	if type(name) == "table" then
		local ret = {}
		for i, v in ipairs(name) do
			lower, upper = tCombatAttrAction[v](self, objId)
			ret[v] = { ["["] = lower, ["]"] = upper }
		end
		return ret
	end
end
-------------------------------------------------------------
objExitScene = function(self, objId)
	self.mData[objId] = nil
end

leadingRoleSwitchScene = function(self, objId)
	-- local objId = objId or G_ROLE_MAIN.obj_id
	-- local item = self.mData[objId]
	self.mData = {}
	-- self.mData[objId] = item
end

-------------------------------------------------------------
_G.MRoleStruct = M
-------------------------------------------------------------



