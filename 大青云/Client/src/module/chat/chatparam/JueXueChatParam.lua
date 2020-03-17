--[[
绝学
参数:type,绝学id
lizhuangzhuang
2015年11月13日21:50:083
]]

_G.JueXueChatParam = setmetatable({},{__index=ChatParam});

function JueXueChatParam:GetType()
	return ChatConsts.ChatParam_JueXue;
end

function JueXueChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local id = toint(params[1]);

	local cfg = t_skill[id];
	if not id then return ""; end
	local str = "<font color='#ffffff'>"..cfg.name.."</font>";
	return str;
end