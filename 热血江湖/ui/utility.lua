module(..., package.seeall)

NIL = {}

--xxxtodo: add doc
function rcsReturn(tb, index)	--xxxtodo: eliminate index
	if index < #tb then
		local value = tb[index]
		local rt
		if value ~= NIL then rt = value end
		return rt, rcsReturn(tb, index + 1)
	else
		local value = tb[index]
		local rt
		if value ~= NIL then rt = value end
		return rt
	end
end

function switchNil(v)
	if v == NIL then 
		return nil 
	elseif v == nil then
		return NIL
	else
		return v 
	end
end

--xxxtodo:use new module function

i3k_watcher = require("ui/utility_watcher").i3k_watcher
i3k_callback = require("ui/utility_callback").i3k_callback
i3k_reddot = require("ui/utility_reddot").i3k_reddot

