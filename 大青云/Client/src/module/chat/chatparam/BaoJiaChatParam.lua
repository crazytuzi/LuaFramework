--[[
宝甲
参数:type,宝甲id
lizhuangzhuang
2015年5月5日15:59:40
]]

_G.BaoJiaChatParam = setmetatable({},{__index=ChatParam});

function BaoJiaChatParam:GetType()
	return ChatConsts.ChatParam_BaoJia;
end

function BaoJiaChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local id = toint(params[1]);
	local cfg = t_baojia[id];
	if not cfg then return ""; end
	local str = "<font color='#ffffff'>【"..cfg.name.."】</font>";
	return str;
end
