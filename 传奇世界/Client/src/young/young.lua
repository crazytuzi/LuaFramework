
local M = {}
setmetatable( M, { __index = _G } )
package.loaded[...] = M
setfenv(1, M)

---------------------------------------------------------------------------
-- [@what] define function "beginModule"
-- [@why] for begin lua module
-- [@param] modname => the name of module to require
-- [@return] a table that contains all public variables in the module
beginModule = function(modname)
	local M = {}
	setmetatable( M, { __index = _G } )
	-- enable a circular "require"
	-- for instance, module a require module b, and in module b, require module a
	package.loaded[modname] = M
	
	setfenv(2, M)
	return M
end
---------------------------------------------------------------------------
beginFunction = function(m)
	local M = {}
	setmetatable( M, { __index = _G } )

	setfenv(2, M)
	return M
end
---------------------------------------------------------------------------
--[[
-- 可能存在bug
inherit = function(m, super, exclude)
	for k, v in pairs(super) do
		if not exclude or not exclude[k] then
			m[k] = v
		end
	end
end
--]]
---------------------------------------------------------------------------
newSubModule = function(super)
	local M = {}
	local mt = nil
	if type(super) == "table" then
		mt = super
	elseif type(super) == "function" then
		mt = {}
	else
		error("[参数1]不是 'table' 或 'function'", 2)
	end
	
	setmetatable(M, mt)
	mt.__index = super
	return M
end
---------------------------------------------------------------------------
require "src/young/mydebug"
require "src/young/util/util"
---------------------------------------------------------------------------
_G.Myoung = M
---------------------------------------------------------------------------

return M






