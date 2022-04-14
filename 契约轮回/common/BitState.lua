-- 
-- @Author: LaoY
-- @Date:   2018-07-31 10:58:42
-- 
--[[
设：A，B，C，D，E，........ 为逻辑变量；F 为逻辑函数。
“逻辑与”运算：F=AB...(也称逻辑乘) A,B皆为1时，F=1，A,B有一个为0，F=0
“逻辑或”运算：F=A+B.(亦称逻辑加) A,B皆为0时，F=0，A,B有一个为1，F=1
“逻辑非”运算：F=A' (逻辑反) A=1,F=0；A=0,F=1. 一般用变量上加一杠表示！
“与非”运算：(AB)' (等价于) = A'+B'
“或非”运算：(A+B)' (等价于) = A'B'
“异或”运算：F=A'B+AB' 记为：F = A⊕B........A,B取值不同时F=1， 否则为0。
“同或”运算：F=AB+A'B' 记为：F = A⊙B........A,B取值不同时F=0， 否则为1。 

bit.bnot(a) - 返回一个a的补充
bit.band(w1,…) - 返回w的位与
bit.bor(w1,…) - 返回w的位或
bit.bxor(w1,…) - 返回w的位异或
bit.lshift(a,b) - 返回a向左偏移到b位
bit.rshift(a,b) - 返回a逻辑右偏移到b位
bit.arshift(a,b) - 返回a算术偏移到b位
bit.mod(a,b) - 返回a除以b的整数余数
--]]

local bit = require "bit"
local band 	= bit.band
local bor 	= bit.bor
local bnot 	= bit.bnot
local tohex = bit.tohex
BitState = BitState or class("BitState")
local this = BitState
BitState.State = {
	[0]  = 0x0000,
	[1]  = 0x0001,
	[2]  = 0x0002,
	[3]  = 0x0004,
	[4]  = 0x0008,
	[5]  = 0x0010,
	[6]  = 0x0020,
	[7]  = 0x0040,
	[8]  = 0x0080,
	[9]  = 0x0100,
	[10] = 0x0200,
	[11] = 0x0400,
	[12] = 0x0800,
	[13] = 0x1000,
	[14] = 0x2000,
	[15] = 0x4000,
	[16] = 0x8000,
	All  = 0xffff,
}
function BitState:ctor(value)
	self:SetValue(value)
end

function BitState:dctor()
	self.value = BitState.State[0]
end

function BitState:SetValue(value)
	self.value = value or BitState.State[0]
end

function BitState:Add(value)
	self.value = bor(self.value, value)
	-- if self:Contain(value) then
	-- 	return
	-- end
	-- self.value = self.value + value
end

function BitState.StaticAdd(...)
	local list = {...}
	if table.isempty(list) then
		return 0
	end
	local value1 = list[1]
	for i=2,#list do
		local value2 = list[i]
		value1 = bor(value1, value2)
	end
	return value1
end

function BitState:Remove(value)
	if self.value == 0 then
		return
	end
	self.value = band(self.value,bnot(value))
	-- if not self:Contain(value) then
	-- 	return
	-- end
	-- self.value = self.value - value
end              

function BitState.StaticRemove(value1,value2)
	return band(value1,bnot(value2))                                                                                   
end                                                                                   

--[[
	@author LaoY
	@des	是否满足众多条件之一
	@param1 state 条件 选填;默认是所有条件 BitState.State.All
	@return bool
--]]
function BitState:Contain(state)
	if state == 0 then
		-- if AppConfig.Debug then
			-- logError("BitState:Contain Param is 0")
		-- end
	end
	if self.value == state then
		return true
	end
	if self.value == 0 then
		return false
	end
	if not state then
		return self.value > 0
	else
		return band(state,self.value) > 0
	end
end

--[[
	@author LaoY
	@des	是否满足众多条件之一 全局函数
	@param1 state 条件 选填;默认是所有条件 BitState.State.All
	@return bool
--]]
function BitState.StaticContain(value,state)
	value = checknumber(value)
	if value == state then
		return true
	end
	if not state then
		return value > 0
	else
		return band(state,value) > 0
	end
end

function BitState:Debug()
	print("0x" .. tohex(self.value))
end