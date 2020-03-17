--[[
圣器
参数:type,圣器id
lizhuangzhuang
2016年1月20日14:59:09
]]

_G.ShengQiChatParam = setmetatable({},{__index=ChatParam});

function ShengQiChatParam:GetType()
	return ChatConsts.ChatParam_ShengQi;
end

function ShengQiChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local id = toint(params[1]);
	local cfg = t_binghun[id];
	if not cfg then return ""; end
	local str = "<font color='#ffffff'>"..cfg.name.."</font>";
	return str;
end