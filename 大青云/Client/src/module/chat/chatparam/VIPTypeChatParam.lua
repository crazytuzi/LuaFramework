--[[
VIP类型
参数类型:type,vip类型
lizhuangzhuang
2015年10月24日00:05:26
]]

_G.VIPTypeChatParam = setmetatable({},{__index=ChatParam});

function VIPTypeChatParam:GetType()
	return ChatConsts.ChatParam_VIPType;
end

function VIPTypeChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	if not params[1] then return ""; end
	local vipType = toint(params[1]);
	if vipType == 1 then
		return "<font color='#ffffff'>白银</font>";
	elseif vipType == 2 then
		return "<font color='#ffffff'>黄金</font>";
	elseif vipType == 3 then
		return "<font color='#ffffff'>钻石</font>";
	end
	return "";
end
