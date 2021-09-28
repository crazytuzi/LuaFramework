return { new = function(integer, width)

	integer = math.abs(integer)
	integer = math.floor(integer)
	
	local ret = {}
	local divide
	divide = function(integer)
		local tmp = math.floor(integer/10)
		if tmp > 0 then divide(tmp) end
		local remainder = integer % 10
		ret[#ret + 1] = remainder
	end; divide(integer)
	
	width = math.max(width or #ret)
	local blank = width - #ret
	
	return function(state, ctrlvar)
	
		if ctrlvar > #state + blank then return end
		
		local save = ctrlvar
		ctrlvar = ctrlvar + 1
		
		if blank > 0 then
			if save <= blank then
				return ctrlvar, 0
			else
				return ctrlvar, state[save - blank]
			end
		else
			return ctrlvar, state[save]
		end
	end, ret, 1
	
end }