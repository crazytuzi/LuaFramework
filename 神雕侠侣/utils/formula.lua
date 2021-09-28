local brackets = {40, 41}-- ()
local operators = {43, 45, 42, 47, 94}-- +_*/^

local function pop(stack)
	if #stack ~= 0 then
		local e= stack[#stack]
		stack[#stack] = nil
		return e
	end
end

local function Char(num)
	if num == 40 then
		return '('
	elseif num == 41 then
		return ')'
	elseif num == 94 then
		return '^'
	elseif num == 43 then
		return '+'
	elseif num == 45 then
		return '-'
	elseif num == 42 then
		return '*'
	elseif num == 47 then
		return '/'
	end
end

local function isOperator(numb)
	for i = 1, #operators do
		if operators[i] == numb then
			return true
		end
	end
	return false
end

local function cal3(left, right, operator)
	if operator == '+' then
		return left + right
	elseif operator == '-' then
		return left - right
	elseif operator == '*' then
		return left * right
	elseif operator == '/' then
		return left / right
	elseif operator == '^' then
		return left ^ right
	end
	assert(false)
end

local function cal(formula, variables)
	local newFormula = string.gsub(formula, "Lv", "x") -- 'x' = 120
	local stack = {}
	local bytes = {}
	local ignore
	for i = 1, #newFormula do
		if not ignore or i > ignore then
			local numb = string.byte(newFormula, i)
			if numb == 40 then
				table.insert(stack, '(')
			elseif numb == 41 then
				local e = pop(stack)
				if e and e ~= 40 then
					table.insert(bytes, e)
				end
				while e and e ~= 40 do
					e = pop(stack)
					table.insert(bytes, e)
				end
			elseif isOperator(numb) then
			--	assert(#stack ~= 0)
				if numb == 42 or numb == 47 or numb == 94 then
					table.insert(stack, Char(numb))
				else
					if #stack ~= 0 then
						local head = stack[#stack]
						if head ~= 40 then
							head = pop(stack)
							table.insert(bytes, head)
						end
						while #stack ~= 0 and stack[#stack] ~= 40 do
							head = pop(stack)
							table.insert(bytes, head)
						end
					end
					table.insert(stack, Char(numb))
				end
			elseif numb == 120 then
				local lv = variables["Lv"]
				table.insert(bytes, lv)
			else
				local numstart, numend = i, #newFormula
				for j = i + 1, #newFormula do
					local numb2 = string.byte(newFormula, j)
					if isOperator(numb2) or numb2 == 120 or numb2 == 40 or numb2 == 41 then
						numend = j - 1
						break
					end 
				end
				local num = tonumber(string.sub(newFormula, numstart, numend))
				table.insert(bytes, num)
				ignore = numend
			end
		end
	end
	for i = #stack, 1, -1 do
		local e = stack[i]
		table.insert(bytes, e)
	end
--	local xx = {} 
--	table.concat(xx,bytes)
--	assert(#bytes ~= 0 and bytes[1] == 120)
	local function calSuffix()
		assert(#bytes ~= 2)
		if #bytes == 1 then
			return bytes[1]
		end
		for i = 3, #bytes do
			if bytes[i] == '+' or bytes[i] == '-' or bytes[i] == '*' or
				bytes[i] == '/' or bytes[i] == '^' then
				local newnum = cal3(bytes[i - 2], bytes[i - 1], bytes[i])
				table.remove(bytes, i - 2)
				table.remove(bytes, i - 2)
				table.remove(bytes, i - 2)
				table.insert(bytes, i - 2, newnum)
				break
			end
		end
	end
	local ret = calSuffix()
	while not ret do
		ret = calSuffix()
	end
	return ret
end

return cal