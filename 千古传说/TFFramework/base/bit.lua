--[[bit.lua
Exported API:
	bit_and(a, b)
	bit_or(a, b)
	bit_xor(a, b)
	bit_not(a)
	bit_lshift(a, n)
	bit_rshift(a, n)
	bit_tostring(a)
--]]

if BIT_MASK == nil then
	BIT_MASK = 0xffffffff
end

local power = BIT_POWER or 32
local data = {}
for i = 1, power do data[i] = 2^(power-i) end

local function d2b(n)
	n = tonumber(n) or 0
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

local function b2d(b)
	local ret = 0
	for i = 1, power do
		if b[i] ==1 then
			ret = ret + 2^(power-i)
		end
	end
	return  ret
end

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

function bit_and(...)
	local ret = select(1, ...)
	for i = 2, select("#", ...) do
		ret = _and(ret, select(i, ...))
	end
	return ret
end

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

function bit_or(...)
	local ret = select(1, ...)
	for i = 2, select("#", ...) do
		ret = _or(ret, select(i, ...))
	end
	return ret
end

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

function bit_tostring(a)
	local b = d2b(a)
	local s = ""
	for i = 1, power do
		s = s .. b[i]
	end
	return s
end

--[[
--Example:
print("power =", power)
print("BIT_POWER =", BIT_POWER)
print("BIT_MASK =", string.format("%x",BIT_MASK))

print("\nbit_and(0xffffffff, 0xffffffff)\n11111111111111111111111111111111	4294967295	ffffffff")
local n = bit_and(BIT_MASK, BIT_MASK)
print(bit_tostring(n), n, string.format("%x",n))

print("\nbit_and(7, 0xffffffff)\n00000000000000000000000000000111	7	7")
local n = bit_and(7, BIT_MASK)
print(bit_tostring(n), n, string.format("%x",n))

print("\nbit_not(7)\n11111111111111111111111111111000	4294967288	fffffff8")
local n = bit_not(7)
print(bit_tostring(n), n, string.format("%x",n))

print("\nbit_not(0x0F)\n11111111111111111111111111110000	4294967280	fffffff0")
local n = bit_not(0x0F)
print(bit_tostring(n), n, string.format("%x",n))

print("\nbit_lshift(7, 2)\n00000000000000000000000000011100	28	1c")
local n = bit_lshift(7, 2)
print(bit_tostring(n), n, string.format("%x",n))

print("\nbit_rshift(7, 2)\n00000000000000000000000000000001	1	1")
local n = bit_rshift(7, 2)
print(bit_tostring(n), n, string.format("%x",n))

print("\nbit_and(0x08, 0x0A)\n00000000000000000000000000001000	8	8")
local n = bit_and(0x08, 0x0A)
print(bit_tostring(n), n, string.format("%x",n))

print("\nbit_or(0x08, 0x0A)\n00000000000000000000000000001010	10	a")
local n = bit_or(0x08, 0x0A)
print(bit_tostring(n), n, string.format("%x",n))

print("\nbit_xor(0x08, 0x0A)\n00000000000000000000000000000010	2	2")
local n = bit_xor(0x08, 0x0A)
print(bit_tostring(n), n, string.format("%x",n))
--]]
