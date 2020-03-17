--[[
套装
参数:type,套装id
lizhuangzhuang
2015年11月3日23:29:15
]]

_G.EquipGroupChatParam = setmetatable({},{__index=ChatParam});

function EquipGroupChatParam:GetType()
	return ChatConsts.ChatParam_EquipGroup;
end

function EquipGroupChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local id = toint(params[1]);
	local cfg = t_equipgroup[id];
	if not cfg then return ""; end
	local str = "<font color='#00ff00'>"..cfg.name.."</font>";
	return str;
end
