--[[
	打宝地宫
	参数:type,活动id
	houxudong
	2016年11月23日 10:33:45
]]
_G.classlist['XianYuanCaveChatParam'] = 'XianYuanCaveChatParam'
_G.XianYuanCaveChatParam = setmetatable({},{__index=ChatParam})
XianYuanCaveChatParam.objName = 'XianYuanCaveChatParam'

function XianYuanCaveChatParam:GetType()
	return ChatConsts.ChatParam_DiBoss
end

function XianYuanCaveChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr)
	if params[1] then
		local Id = toint(params[1]);
		local monsterCfg = t_monster[Id];
		if not monsterCfg then return ""; end
		return "<font color='#ffffff'>【"..monsterCfg.name.."】</font>";
	else
		return "";
	end
end
