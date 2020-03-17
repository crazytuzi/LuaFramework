--[[
灵光封魔
lizhuangzhuang
2015年10月10日14:40:30
]]

_G.TimingChatParam = setmetatable({},{__index=ChatParam});

function TimingChatParam:GetType()
	return ChatConsts.ChatParam_Timing;
end

function TimingChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	if params[1] then
		local id = toint(params[1]);
		local cfg = t_monkeytime[id];
		if not cfg then return ""; end
		local str = "天神战场副本" --<font color='%s'>%s</font>";
		-- str = string.format(str,TipsConsts:GetItemDiffColor(cfg.diff_id - 1),cfg.diff_name);
		return str;
	else
		return "";
	end
end
