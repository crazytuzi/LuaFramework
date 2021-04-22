--[[
	QSBActorStatus感觉不够好，这个脚本是作为替代用的，这个脚本只用来做判断 配合QSBSelector一起使用
	条件方面还是取QSBActorStatus一样的思路,但是要实现and or之类的判断
	这个运算的过程是支持运算的优先级的，但是不支持负数 所以 2*(-1) 这种操作要写成 2*(0-1)
	比较符只支持> < = ~(不等于) 这样单个字符的
	如果要判断对方的buff数目是否超过5 则可以配置
	"target:buff_num:buff_id>5"
	
	一些特殊值的格式为目标类型:名称:其他参数 目标类型与名称不可省略
	random等虽然是与目标无关的 但是也必须写目标, 比如self:random
	目标类型现在有
	self:施法者
	target:技能目标
	hero_target:施法者目标

	对方血量大于50%且有某个buff:
	"(target:hp>target:max_hp*0.5)&target:has_buff:buff_id"
	完整的格式
	{
		failed_select = false, --没有匹配到的话select会置成这个值 默认为2
		{expression = "表达式", select = 1}, --select的意思是如果匹配到了这一条那么select会置成1,默认为1
	}
	计算规则 
	+ - * / 与正常的一样
	> < = ~ 如果条件成立则值为1，否则值为0
	& | 两个值进行对应的位运算
	筛选规则  这个脚本会计算表达式 当表达式的值比0大时会认为匹配成功，否则失败
	所以判断我的血量比对方血量多时可以写
	self:hp>target:hp
	也可以写
	self:hp-target:hp
--]]
local QSBNode = import("..QSBNode")
local QSBArgsConditionSelector = class("QSBArgsConditionSelector", QSBNode)

--取number返回值的加在这
local status_value = 
{
	hp = function(self, actor, arg_str)--acotr极有可能是空值 所以要做判空处理
		return actor and actor:getHp() or 0
	end,
	max_hp = function(self, actor, arg_str)
		return actor and actor:getMaxHp() or 0
	end,
	max_attack = function(self, actor, arg_str)
		return actor and actor:getAttack() or 0
	end,
	buff_num = function(self, actor, buff_id)
		if actor == nil then
			return 0
		end
		local i = 0
		for _,buff in ipairs(actor:getBuffs()) do
			if (not buff:isImmuned()) and buff:getId() == buff_id then
				i = i + 1
			end
		end
		return i
	end,
	status_apply_count = function(self, actor, status)
		return actor:getApplyCountByStatus(status)
	end,
	random = function(...)
		return app.random()
	end,
	distance = function(self, actor, buff_id)
		if actor == nil or self._attacker == nil then
			return 0
		end
		return q.distOf2Points(self._attacker:getPosition(), actor:getPosition())
	end,
	self_teammates_num = function(self, actor, arg_str)
		local actors = app.battle:getMyTeammates(actor, true, true) or {}
		local num = #actors
		return num
	end,
	get_absorb_value = function(self, actor, arg_str)
		return actor:getAbsorbDamageValue()
	end,
}

--取bool返回值的加在这
local status_functions = 
{
	has_buff = function(self, actor, arg_str) --因为状态是随着英雄的,所以actor一定不会为空，为空会直接返回false,这里不需要做判空处理
			for i, buff in ipairs(actor:getBuffs()) do
				if buff:getId() == arg_str then
					return true
				end
			end
			return false
		end,
	is_boss = function(self, actor, arg_str)
			if actor then
				return actor:isBoss()
			end
			return false
		end,
	is_pvp = function(self, actor, arg_str)
		if app.battle then
			return app.battle:isPVPMode()
		end
		return false
	end,
	is_copy_hero = function(self, actor, arg_str)
		if actor then
			return actor:isCopyHero()
		end
		return false
	end,
	is_teammate_hero = function(self, actor, arg_str)
		if actor and app.battle then
			local actors = app.battle:getMyTeammates(actor, false, true)
			for _, hero in ipairs(actors) do
				if hero == actor then
					return true
				end
			end
		end
		return false
	end,
	is_can_control_move = function(self, actor, arg_str)
		if actor and app.battle then
			return actor:CanControlMove()
		end
	end,
	is_actor_dead = function(self, actor, arg_str)
		if actor and app.battle then
			return actor:isDead()
		end
	end,
	is_ranged = function(self, actor, arg_str)	--true为远程攻击
		return actor:isRanged()
	end,
}

-- local function calcValue(str)
-- 	return loadstring("return "..str)() 海哥觉得还是不要这么写了 所以后面利用后缀表达式实现
-- end

--运算符列表 后面的数字是优先级
local expressions = {["+"] = 21, ["-"] = 21, ["*"] = 22, ["/"] = 22, --普通运算的优先级
					["("] = -1, [")"] = -1,  --这两个的优先级是在代码里写死的无限大的那种
					["|"] = 1, ["&"] = 1,  --位运算
					[">"] = 11, ["<"] = 11, ["="] = 11, ["~"] = 11}  -- 比较 >= <= ~=这种需要写两个字符 这样创建中缀表达式的代码要麻烦一点儿，所以就简单一些
--创建中缀表达式
local function createInfixExpression(str)
	local arr = {}
	local strlen = #str
	local _str = ""
	for i = 1, strlen, 1 do
		local c = string.char(string.byte(str, i))
		if expressions[c] then
			if _str ~= "" then
				table.insert(arr, _str)
				_str = ""
			end
			table.insert(arr, c)
		else
			_str = _str..c
		end
	end
	if _str ~= "" then
		table.insert(arr, _str)
	end
	return arr
end

--把中缀表达式转换成后缀表达式
local function createSuffixExpression(infix_expression)
    local opts = {}
    local suffix_expression = {}
    for i, value in ipairs(infix_expression) do
        if expressions[value] then
            if #opts == 0 or value == "(" then
            	table.insert(opts, 1, value)
            elseif value == ")" then
            	while #opts > 0 do
            		if opts[1] == "(" then
            			table.remove(opts, 1)
            			break
            		else
            			table.insert(suffix_expression, opts[1])
            			table.remove(opts, 1)
            		end
            	end
            else
            	while #opts > 0 do
            		if expressions[opts[1]] >= expressions[value] then
            			table.insert(suffix_expression, opts[1])
            			table.remove(opts, 1)
            		else
            			break
            		end
            	end
            	table.insert(opts, 1, value)
            end
        else
            table.insert(suffix_expression, value)
        end
    end
    while #opts > 0 do
    	table.insert(suffix_expression, opts[1])
        table.remove(opts, 1)
    end
    return suffix_expression
end

function QSBArgsConditionSelector:getActor(target_str)
	return self._targets[target_str]
end

function QSBArgsConditionSelector:isUnderStatus(actor, status, arg_str)
	assert(actor ~= nil, "actor is nil")
	if status_functions[status] then
		return status_functions[status](self, actor, arg_str)
	else
		return actor:isUnderStatus(status)
	end
end

function QSBArgsConditionSelector:getValue(value)
	local v = tonumber(value)
	if v then
		return v 
	end
	if value == "false" then
		return 0
	end
	if value == "true" then
		return 1
	end
	local cfg = string.split(value, ":")
	local target_str, status, arg_str = cfg[1], cfg[2], cfg[3]
	local actor = self:getActor(target_str)
	if status_value[status] then
		return status_value[status](self, actor, arg_str)
	elseif actor ~= nil then
		return self:isUnderStatus(actor, status, arg_str) and 1 or 0
	else
		return 0
	end
end

function QSBArgsConditionSelector:calcValue(v1, v2, expression)
	if expression == "+" then
		return v1 + v2
	elseif expression == "-" then
		return v1 - v2
	elseif expression == "*" then
		return v1 * v2
	elseif expression == "/" then
		return v1 / v2
	elseif expression == "|" then
		return bit.bor(v1, v2)
	elseif expression == "&" then
		return bit.band(v1, v2)
	elseif expression == ">" then
		return v1 > v2 and 1 or 0
	elseif expression == "<" then
		return v1 < v2 and 1 or 0
	elseif expression == "=" then
		return v1 == v2 and 1 or 0
	elseif expression == "~" then
		return v1 ~= v2 and 1 or 0
	end
	assert(false, "unknown expression:"..tostring(expression))
end

--表达式求值
function QSBArgsConditionSelector:calcString(str)
	local suffix_expression = createSuffixExpression(createInfixExpression(str))
	local stack = {}
	while #suffix_expression > 0 do
		local value = table.remove(suffix_expression, 1)
		if expressions[value] then
			local v1 = table.remove(stack, 1) 
			local v2 = table.remove(stack, 1)
			assert(v1 ~= nil and v2 ~= nil)
			table.insert(stack, 1, self:calcValue(v2, v1, value))--因为是栈的结构 其实先弹出来的数是要运算的后一个数，后弹出来的是前一个数 所以调用的时候要用v2,v1不能颠倒
		else
			table.insert(stack, 1, self:getValue(value))
		end
	end
	assert(#stack == 1, "stack error: size:"..tostring(#stack))
	return stack[1]
end

function QSBArgsConditionSelector:initTargets()
	self._targets = 
	{
		["self"] = self._attacker,
		["target"] = self._target,
		["hero_target"] = self._attacker:getTarget(),
	}
end

function QSBArgsConditionSelector:_execute(dt)
   	self:initTargets()
   	for i,ops in ipairs(self._options) do
   		assert(ops.expression, "expression is nil!")
   		local result = self:calcString(ops.expression)
   		if result > 0 then
   			self:finished({select = ops.select or 1})
   			return
   		end
   	end
   	self:finished({select = self._options.failed_select or 2})
end

return QSBArgsConditionSelector