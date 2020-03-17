--[[
封妖
参数格式:type,fengyaoId
lizhuangzhuang
2015年6月11日22:44:19
]]

_G.FengYaoChatParam = setmetatable({},{__index=ChatParam});

function FengYaoChatParam:GetType()
	return ChatConsts.ChatParam_FengYao;
end

function FengYaoChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local fengyaoId = toint(params[1]);
	if not fengyaoId then return ""; end
	local cfg = t_fengyao[fengyaoId];
	if not cfg then return ""; end
	
	local monsters = split(cfg.monster_id,',');
	
	local monsterCfg = t_monster[tonumber(monsters[1])];
	if not monsterCfg then return ""; end
	local str = monsterCfg.name;
	--
	local color = StrConfig["fengyao20"..cfg.quality];--尼玛，逗比
	str = "<font color='".. color .."'>"..str.."</font>";
	return str;
end