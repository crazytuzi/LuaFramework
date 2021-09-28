--[[bit.lua
描述：
	提供位运算
--]]

if BIT_MASK == nil then
	BIT_MASK = 0xffffffff
end

local power = BIT_POWER or 32
local data = {}
for i = 1, power do data[i] = 2^(power-i) end

--@note：将整型数字转换成2进制位数组
--@param n：整型数字
--@ret：2进制位数组
local function d2b(n)
	local ret = {}
	for i = 1, power do
		if n >= data[i] then
			ret[i] = 1
			n = n - data[i]
		else
			ret[i] = 0
		end
	end
	return ret
end

--@note：将2进制数组转换成整型数字
--@param b：2进制数组
--@ret：整型数字
local function b2d(b)
	local ret = 0
	for i = 1, power do
		if b[i] ==1 then
			ret = ret + 2^(power-i)
		end
	end
	return  ret
end

--@note：位与运算，优先使用底层运算
local _and = BIT_AND
if _and == nil then
	_and = function(a, b)
		if not a then
			return b
		elseif not b then
			return a
		end

		local b1 = d2b(a)
		local b2 = d2b(b)
		local r = {}

		for i = 1, power do
			if b1[i] == 1 and b2[i] == 1 then
				r[i] = 1
			else
				r[i] = 0
			end
		end

		return b2d(r)
	end
end

--@note：位或运算，优先使用底层运算
local _or = BIT_OR
if _or == nil then
	_or = function(a, b)
		if not a then
			return b
		elseif not b then
			return a
		end

		local b1 = d2b(a)
		local b2 = d2b(b)
		local r = {}

		for i = 1, power do
			if b1[i] == 1 or b2[i] == 1 then
				r[i] = 1
			else
				r[i] = 0
			end
		end

		return b2d(r)
	end
end

--@note：非运算，优先使用底层运算
bit_not = BIT_NOT
if bit_not == nil then
	bit_not = function(a)
		local b = d2b(a)
		local r = {}

		for i = 1, power do
			if b[i] == 0 then
				r[i] = 1
			else
				r[i] = 0
			end
		end

		return b2d(r)
	end
end

--@note：异或运算，优先使用底层运算
bit_xor = BIT_XOR
if bit_xor == nil then
	bit_xor = function(a, b)
		if not a then
			return b
		elseif not b then
			return a
		end

		local b1 = d2b(a)
		local b2 = d2b(b)
		local r = {}

		for i = 1, power do
			if b1[i] ~= b2[i] then
				r[i] = 1
			else
				r[i] = 0
			end
		end

		return b2d(r)
	end
end

--@note：左移运算，优先使用底层运算
bit_lshift = BIT_LSHIFT
if bit_lshift == nil then
	bit_lshift = function(a, n)
		local r = d2b(0)

		if n < power and n > 0 then
			local b = d2b(a)
			for i = 1, n do
				for j = 1, power - 1 do
					b[j] = b[j+1]
				end
				b[power] = 0
			end
			r = b
		end

		return b2d(r)
	end
end

--@note：右移运算，优先使用底层运算
bit_rshift = BIT_RSHIFT
if bit_rshift == nil then
	bit_rshift = function(a, n)
		local r = d2b(0)

		if n < power and n > 0 then
			local b = d2b(a)
			for i = 1, n do
				for j = power - 1, 1, -1 do
					b[j+1] = b[j]
				end
				b[1] = 0
			end
			r = b
		end

		return b2d(r)
	end
end

--@note：位与，提供多个数值同时参与运算
function bit_and(...)
	local ret = select(1, ...)
	for i = 2, select("#", ...) do
		local value = select(i, ...)
		ret = _and(ret, value)
	end
	return ret
end

--@note：位或，提供多个数值同时参与运算
function bit_or(...)
	local ret = select(1, ...)
	for i = 2, select("#", ...) do
		local value = select(i, ...)
		ret = _or(ret, value)
	end
	return ret
end

--@note：讲整型数值转换成位字符串
function bit_tostring(a)
	local b = d2b(a)
	local s = ""
	for i = 1, power do
		s = s .. b[i]
	end
	return s
end