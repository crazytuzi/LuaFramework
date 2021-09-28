function GetTalkByKey(key)
	local str_tab = {}
	str_tab = require("src/config/MonsterTalk")
	if str_tab[key] then
		return str_tab[key]
	else
		return ""
	end
end


-----------------------------------------------------------

local onRecvCharTalk = function(luabuffer)
	local trd = g_msgHandlerInst:convertBufferToTable("AISpeakProtocol", luabuffer)
	local charid = trd.id
	local type = trd.type
	local textkey = trd.content
	--log("[onRecvCharTalk] called. charid = %d, type = %d, textkey = %s.", charid, type, textkey)

	if G_MAINSCENE then
		G_MAINSCENE.map_layer:addBubble(charid, textkey)
	end
end


-----------------------------------------------------------


g_msgHandlerInst:registerMsgHandler(CHAR_SC_TALK, onRecvCharTalk)	-- ����˵��

