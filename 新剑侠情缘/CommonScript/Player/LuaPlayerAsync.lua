-- 用于接收upvalue
local self;

-- 异步信息
-- 例：_GEN_ASYNC_FUN("Test", 1)
-- 会生成函数 GetTest()、SetTest(nValue)
local function _GEN_ASYNC_FUN(szDesc, nValueId)
	local funGet = 
		function ()
			return self.GetAsyncValue(nValueId)
		end
	local funSet = 
		function (nValue)
			return self.SetAsyncValue(nValueId, nValue)
		end
	rawset(_LuaPlayerAsync, "Get"..szDesc, funGet)
	rawset(_LuaPlayerAsync, "Set"..szDesc, funSet)
end

-- 战斗信息
-- 例：_GEN_ASYNC_FUN("Test", 1)
-- 会生成函数 GetTest()、SetTest(nValue)
local function _GEN_BATTLE_FUN(szDesc, nValueId)
	local funGet = 
		function ()
			return self.GetAsyncBattleValue(nValueId)
		end
	local funSet = 
		function (nValue)
			return self.SetAsyncBattleValue(nValueId, nValue)
		end
	rawset(_LuaPlayerAsync, "Get"..szDesc, funGet)
	rawset(_LuaPlayerAsync, "Set"..szDesc, funSet)
end

-- 范围函数生成
-- 例：_GEN_BATTLE_RANGE_FUN("Test", 11, 16)
-- 会生成函数 GetTest(nIndex)、SetTest(nIndex, nValue), nIndex 取值范围1~6，其他取值无效
local function _GEN_BATTLE_RANGE_FUN(szDesc, nBeginValueId, nEndValueId)
	local funGet = 
		function (nIndex)
			assert(self);  		-- 不能是删……为了保证第一个参数是self
			if nIndex <= 0 or nBeginValueId + nIndex - 1 > nEndValueId then		-- Index 从1开始
				return;
			end
			return self.GetAsyncBattleValue(nBeginValueId + nIndex - 1)
		end
	local funSet = 
		function (nIndex, nValue)
			assert(self);		-- 不能是删……为了保证第一个参数是self
			if nIndex <= 0 or nBeginValueId + nIndex - 1 > nEndValueId then		-- Index 从1开始
				return;
			end
			return self.SetAsyncBattleValue(nBeginValueId + nIndex - 1, nValue)
		end
	rawset(_LuaPlayerAsync, "Get"..szDesc, funGet)
	rawset(_LuaPlayerAsync, "Set"..szDesc, funSet)
end
-- 涉及存盘，不要改变变量编号

--获取镶嵌信息，和 luaplayer一样的接口
function _LuaPlayerAsync.GetInsetInfo(nPos)
	if nPos >= Item.EQUIPPOS_MAIN_NUM then
		return {};
	end
	local tbInfo = {}
	for i = 1, StoneMgr.INSET_COUNT_MAX do
		table.insert(tbInfo, self.GetInset(StoneMgr:GetInsetAsyncKey(nPos, i)))
	end
    return tbInfo	
end

function _LuaPlayerAsync.GetStrengthen()
	local tbInfo = {}
	for i = 1, Item.EQUIPPOS_MAIN_NUM  do
		table.insert(tbInfo, self.GetEnhance(i))
	end
	return tbInfo
end

if MODULE_GAMECLIENT then
	function _LuaPlayerAsync.GetEquipByPos(nPos)
		if not self.tbEquip then --在viewrole时获得
			return
		end
		local nItemId = self.tbEquip[nPos]
		if not nItemId then
			return
		end
		local pItem = KItem.GetItemObj(nItemId)
		return pItem
	end
end


-- 异步数据 请与C++中 XE_ASYNC_NORMAL_VALUE 保持一致
_GEN_ASYNC_FUN("Coin", 1)			-- 银两数量
_GEN_ASYNC_FUN("CoinAdd", 2)		-- 异步中修改的银两数量
-- Require("CommonScript/Debris/Debris.lua");
-- _GEN_ASYNC_FUN("TopDebris", Debris.AysncTop1From) -- 装备碎片可抢夺的最高档,--装备碎片的碎片状态使用5-14 是最高档   15-24是第二高档 脚本配置在com/debris下
_GEN_ASYNC_FUN("VipLevel", 31)			-- Vip等级
_GEN_ASYNC_FUN("JuBaoPenVal", 32)			-- 聚宝盆的总值
_GEN_ASYNC_FUN("JuBaoPenTime", 33)			-- 聚宝盆的修改时间
_GEN_ASYNC_FUN("ChatForbidType", 34)			-- 禁言类型
_GEN_ASYNC_FUN("ChatForbidEndTime", 35)		-- 禁言结束时间
_GEN_ASYNC_FUN("ChatForbidSilence", 36)		-- 是否悄悄禁言(不给提示)
_GEN_ASYNC_FUN("DebrisAvoidTime", 37)		-- 碎片抢夺免战截至时间
_GEN_ASYNC_FUN("MapExploreEnyMap", 38) -- 地图探索所在的遇敌池地图id，
_GEN_ASYNC_FUN("FriendNum", 39) -- 玩家好友数

--特殊货币开始
_GEN_ASYNC_FUN("FactionHonor", 41)	-- 门派竞技荣誉
_GEN_ASYNC_FUN("BattleHonor", 42)	-- 战场荣誉
_GEN_ASYNC_FUN("RankHonor", 43)	-- 武神殿荣誉
_GEN_ASYNC_FUN("DomainHonor", 44)	-- 领土战荣誉
_GEN_ASYNC_FUN("RewardValueDebt", 45)	-- 奖励价值量欠款记录
_GEN_ASYNC_FUN("CrossDomainHonor", 46)	-- 跨服领土战荣誉
--特殊货币



-- 异步战斗数据 请与C++中 XE_ASYNC_BATTLE_VALUE 保持一致
_GEN_BATTLE_RANGE_FUN("BattleArray", 1, 10)		-- 布阵信息，目前只用到5，预留5个位置
_GEN_BATTLE_FUN("Level", 11)		
_GEN_BATTLE_FUN("HonorLevel", 12)		
_GEN_BATTLE_FUN("Faction", 13)	
_GEN_BATTLE_FUN("FightPower", 114)		-- 战斗力
_GEN_BATTLE_FUN("BaseDamage", 115)		-- 基础攻击力最小值
_GEN_BATTLE_FUN("MaxHp", 116)			-- 最大生命值
_GEN_BATTLE_FUN("Vitality", 151)	    -- 体质
_GEN_BATTLE_FUN("Strength", 152)	    -- 力量
_GEN_BATTLE_FUN("Energy", 153)		    -- 灵巧
_GEN_BATTLE_FUN("Dexterity", 154)	    -- 敏捷
_GEN_BATTLE_FUN("Sex", 1156)			-- 性别
_GEN_BATTLE_FUN("WaiyiBgId", 7201)	--查看背景图id
_GEN_BATTLE_FUN("OpenLight", 129)	--发光属性	


_GEN_BATTLE_RANGE_FUN("Enhance", 14, 33) -- 强化信息，目前只用到10，预留10个位置
_GEN_BATTLE_RANGE_FUN("Inset", 34, 113) -- 镶嵌信息，目前只用到40，预留40个位置
_GEN_BATTLE_RANGE_FUN("Suit", 130, 139) -- 套装 (100 * 属性group + level)
_GEN_BATTLE_RANGE_FUN("PlayerAttribute", 140, 150) --玩家属性

_GEN_BATTLE_RANGE_FUN("JuexueSuit", 1157, 1257) -- 绝学套装
