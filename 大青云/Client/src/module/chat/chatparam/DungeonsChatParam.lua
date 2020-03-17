--[[
副本
参数:type,副本id
lizhuangzhuang
2014年9月17日21:25:54
]]
_G.classlist['DungeonsChatParam'] = 'DungeonsChatParam'
_G.DungeonsChatParam = setmetatable({},{__index=ChatParam});
DungeonsChatParam.objName = 'DungeonsChatParam'

function DungeonsChatParam:GetType()
	return ChatConsts.ChatParam_Dungeons;
end

function DungeonsChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local dungeonId = toint(params[1]);
	local cfg = t_dungeons[dungeonId];
	if not cfg then return ""; end
	local str = "<font color='#ffffff'>【"..cfg.name.."】</font>";
	return str;
end