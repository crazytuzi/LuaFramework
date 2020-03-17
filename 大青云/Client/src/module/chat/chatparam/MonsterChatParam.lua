--[[
怪物
参数格式:type,monsterId
lizhuangzhuang
2014年9月18日16:15:30
]]

_G.MonsterChatParam = setmetatable({},{__index=ChatParam});

function MonsterChatParam:GetType()
	return ChatConsts.ChatParam_Monster;
end

function MonsterChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local monsterId = toint(params[1]);
	local cfg = t_monster[monsterId];
	if not cfg then return ""; end
	local str = "";
	if cfg.starLvl > 0 then
		str = string.format("%s星 %s",cfg.starLvl,cfg.name);
	elseif cfg.type == MonsterConsts.Type_Boss_World then
		str = string.format("世界Boss %s",cfg.name);
	elseif cfg.type == MonsterConsts.Type_False then
		str = cfg.name;
	else
		str = string.format("怪物 %s",cfg.name);
	end
	str = "<font color='#ffffff'>"..str.."</font>";
	return str;
end