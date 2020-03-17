--[[
神兵
参数:type,神兵id
lizhuangzhuang
2015年3月6日10:47:11
]]

_G.ShenBingChatParam = setmetatable({},{__index=ChatParam});

function ShenBingChatParam:GetType()
	return ChatConsts.ChatParam_ShenBing;
end

function ShenBingChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local shenBingId = toint(params[1]);
	local cfg = t_shenbing[shenBingId];
	if not cfg then return ""; end
	local str = "<font color='#ffffff'>【"..cfg.name.."】</font>";
	return str;
end
