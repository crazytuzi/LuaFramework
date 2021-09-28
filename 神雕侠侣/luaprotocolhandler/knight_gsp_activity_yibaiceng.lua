local p = require "protocoldef.knight.gsp.activity.yibaiceng.syibaicenglayer"
function p:process()
	local _instance = require "ui.logo.logoinfodlg"
	if _instance ~= nil then
		local strbuilder = StringBuilder:new()  
	    strbuilder:SetNum("parameter1", self.layer)
	    local message = strbuilder:GetString(MHSD_UTILS.get_resstring(3138))
	    strbuilder:delete()
	    
		_instance:SetMapName(message)
	end
end
