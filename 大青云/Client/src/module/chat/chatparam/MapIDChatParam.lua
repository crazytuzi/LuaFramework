--[[
地图
参数格式:type,mapID
lizhuangzhuang
2015年10月23日23:50:28
]]

_G.MapIDChatParam = setmetatable({},{__index=ChatParam});

function MapIDChatParam:GetType()
	return ChatConsts.ChatParam_MapID;
end

function MapIDChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local mapId = toint(params[1]);
	local cfg = t_map[mapId];
	if not cfg then return ""; end
	local str = "<font color='#00ff00'>" .. cfg.name.. "</font>";
	return str;
end
