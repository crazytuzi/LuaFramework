--[[
心法
参数:type,心法id
解析服务器脚本
houxudong
2016年8月10日 10:01:05
]]

_G.XinFaChatParam = setmetatable({},{__index=ChatParam});

function XinFaChatParam:GetType()
	return ChatConsts.ChatParam_XinFa;
end

function XinFaChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local gid = toint(params[1]);       --这个id是组gid
	local xinFaCfg = t_xinfazu[gid]
	if not xinFaCfg then return ""; end
	local id = xinFaCfg.startid
	local cfg = t_passiveskill[id];
	if not id then return ""; end
	if not cfg then return ""; end
	local str = "<font color='#ffffff'>"..cfg.name.."</font>";
	return str;
end