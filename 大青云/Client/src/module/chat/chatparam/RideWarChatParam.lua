--[[
骑战
参数:type,骑战id
lizhuangzhuang
2015年11月13日21:53:43
]]

_G.RideWarChatParam = setmetatable({},{__index=ChatParam});

function RideWarChatParam:GetType()
	return ChatConsts.ChatParam_RideWar;
end

function RideWarChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local id = toint(params[1]);
	local cfg = t_ridewar[id];
	if not cfg then return ""; end
	local str = "<font color='#ffffff'>"..cfg.name.."</font>";
	return str;
end
