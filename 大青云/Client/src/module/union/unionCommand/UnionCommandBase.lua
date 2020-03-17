_G.UnionCommandBase = {}

function UnionCommandBase:New() 
	local obj = setmetatable({},{__index = self})
	return obj
end
function UnionCommandBase:ExecuteCommand(data) end
