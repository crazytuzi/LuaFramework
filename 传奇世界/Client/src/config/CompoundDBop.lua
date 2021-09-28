local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
-----------------------------------------------------------------------------
local tCompoundDB = getConfigItemByKey("CompoundDB", "q_sourceid")

record = function(self, id)
	return tCompoundDB[id]
end
-----------------------------------------------------------------------------
