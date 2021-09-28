require "utils.stringbuilder"
GetRoleInfoMsg = {}

local time = 0
function GetRoleInfoMsg.run(elapse)
	time = time + elapse
end

function GetRoleInfoMsg.AddMsg(roleid, rolename)
	LogInfo("GetRoleInfoMsg addmsg")
	local strBuild = StringBuilder:new()	
	strBuild:Set("parameter1", rolename)
	local str = strBuild:GetString(MHSD_UTILS.get_msgtipstring(140740))
	strBuild:delete()
	if time > 15000 then
		time = 0
		GetGameUIManager():AddMessageTip(str)
	else
		if GetChatManager() then
			GetChatManager():AddMessageMsg(str,true)
		end
	end
end

return GetRoleInfoMsg
