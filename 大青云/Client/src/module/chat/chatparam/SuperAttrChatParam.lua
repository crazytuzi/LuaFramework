--[[
卓越属性
参数：type,id,val1
lizhuangzhuang
2015年5月26日11:41:49
]]

_G.SuperAttrChatParam = setmetatable({},{__index=ChatParam});

function SuperAttrChatParam:GetType()
	return ChatConsts.ChatParam_SuperAttr;
end

function SuperAttrChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local vo = {};
	vo.id = toint(params[1]);
	vo.val1 = toint(params[2]);
	local cfg = t_fujiashuxing[vo.id];
	if not cfg then return ""; end
	local str = string.format("「%s」",cfg.name);
	str = str .. formatAttrStr(cfg.attrType,vo.val1);
	return str;
end