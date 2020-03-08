
local self;

-- IntValue信息
-- 例：_GEN_INTVALUE_FUN("Test", 1)
-- 会生成函数 GetTest()、SetTest(nValue)
local function _GEN_INTVALUE_FUN(szDesc, nValueId, bSync)
	local funGet =
		function ()
			return self.GetIntValue(nValueId)
		end
	local funSet =
		function (nValue)
			return self.SetIntValue(nValueId, nValue, bSync and 1 or 0)
		end
	rawset(_LuaPartner, "Get"..szDesc, funGet)
	rawset(_LuaPartner, "Set"..szDesc, funSet)
end

-- 范围函数生成
-- 例：_GEN_INTVALUE_RANGE_FUN("Test", 11, 16)
-- 会生成函数 GetTest(nIndex)、SetTest(nIndex, nValue), nIndex 取值范围1~6，其他取值无效
local function _GEN_INTVALUE_RANGE_FUN(szDesc, nBeginValueId, nEndValueId)
	local funGet =
		function (nIndex)
			assert(self);  		-- 不能是删……为了保证第一个参数是self
			if nIndex <= 0 or nBeginValueId + nIndex - 1 > nEndValueId then		-- Index 从1开始
				return;
			end
			return self.GetIntValue(nBeginValueId + nIndex - 1)
		end
	local funSet =
		function (nIndex, nValue)
			assert(self);		-- 不能是删……为了保证第一个参数是self
			if nIndex <= 0 or nBeginValueId + nIndex - 1 > nEndValueId then		-- Index 从1开始
				return;
			end
			return self.SetIntValue(nBeginValueId + nIndex - 1, nValue)
		end
	rawset(_LuaPartner, "Get"..szDesc, funGet)
	rawset(_LuaPartner, "Set"..szDesc, funSet)
end

_GEN_INTVALUE_RANGE_FUN("SkillValue", 1, 2);		-- 1: 同伴当前技能书使用价值量, 2: 同伴初始技能价值量（使用过技能书后才生效）
_GEN_INTVALUE_FUN("UseProtentialItemValue", 3);		-- 同伴洗髓丹使用数量
_GEN_INTVALUE_FUN("Awareness", 4, true);					-- 同伴觉醒


