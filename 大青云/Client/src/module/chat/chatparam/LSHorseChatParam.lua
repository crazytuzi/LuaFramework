--[[
灵兽坐骑
参数:type,灵兽坐骑id
lizhuangzhuang
2015年10月20日12:18:03
]]

_G.LSHorseChatParam = setmetatable({},{__index=ChatParam});

function LSHorseChatParam:GetType()
	return ChatConsts.ChatParam_LSHorse;
end

function LSHorseChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local id = toint(params[1]);
	local cfg = t_horselingshou[id];
	if not cfg then return ""; end
	local str = "<font color='#ffffff'>"..cfg.name.."</font>";
	return str;
end