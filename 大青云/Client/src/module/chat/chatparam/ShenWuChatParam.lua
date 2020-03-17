--[[
神武
参数:type,神武id
lizhuangzhuang
2015年12月30日14:10:40
]]

_G.ShenWuChatParam = setmetatable({},{__index=ChatParam});

function ShenWuChatParam:GetType()
	return ChatConsts.ChatParam_ShenWu;
end

function ShenWuChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local id = toint(params[1]);
	local cfg = t_shenwu[id];
	if not cfg then return ""; end
	local str = "<font color='#ffffff'>"..cfg.name.."</font>";
	return str;
end
