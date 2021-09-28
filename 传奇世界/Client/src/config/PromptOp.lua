local Myoung = require "src/young/young"; local M = Myoung.beginModule(...)
-----------------------------------------------------------------------------
local tPrompt = getConfigItemByKey("Prompt", "q_MarkID")

record = function(self, id)
	return tPrompt[id]
end

content = function(self, id)
	local record = self:record(id)
	local ret = ""
	if record then
		for i=1, 10 do
			if record["q_contentdescription" .. i] and record["q_contentdescription" .. i] ~= "" then
				ret = ret .. record["q_contentdescription" .. i]
				if record["q_contentdescription" .. i + 1] and record["q_contentdescription" .. i + 1] ~= "" then
					ret = ret .. "\n"
				end
			else
				break
			end
		end
	end
	return ret
end