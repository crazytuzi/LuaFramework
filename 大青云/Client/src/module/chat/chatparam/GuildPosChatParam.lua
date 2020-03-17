--[[
帮派职位
参数:type,职位id
lizhuangzhuang
2015年5月5日15:48:47
]]

_G.GuildPosChatParam = setmetatable({},{__index=ChatParam});

function GuildPosChatParam:GetType()
	return ChatConsts.ChatParam_GuildPos;
end

function GuildPosChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local posId = toint(params[1]);
	local name = UnionUtils:GetOperDutyName(posId);
	if not name then return ""; end
	return name;
end