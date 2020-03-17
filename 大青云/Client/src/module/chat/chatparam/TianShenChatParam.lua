--[[
	2016/9/24 21:56:25
]]

_G.TianShenChatParam = setmetatable({},{__index=ChatParam});

function TianShenChatParam:GetType()
	return ChatConsts.ChatParam_TianShen;
end

function TianShenChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local cardCfg = t_newtianshencard[toint(params[1])]
	if not cardCfg then
		return ""
	end
	local cfg = t_newtianshen[cardCfg.tianshenid]
	if not cfg then return ""; end
	local name  = cfg.name

	return "<font color='#ffffff'>【"..name.."】</font>";
end