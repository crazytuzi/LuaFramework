--[[
坐标
参数格式:type,线,mapId,x,y
lizhuangzhuang
2014年9月17日21:24:04
]]
_G.classlist['MapPosChatParam'] = 'MapPosChatParam'
_G.MapPosChatParam = setmetatable({},{__index=ChatParam});
MapPosChatParam.objName = 'MapPosChatParam'
function MapPosChatParam:GetType()
	return ChatConsts.ChatParam_MapPos;
end

function MapPosChatParam:DecodeToText(paramStr,withLink)
	local params = self:Decode(paramStr);
	local mapId = toint(params[2]);
	local cfg = t_map[mapId];
	if not mapId then return ""; end
	local line = toint(params[1]);
	local x = toint(params[3]);
	local y = toint(params[4]);
	local x2D,y2D = MapUtils:Point3Dto2D(x,y,mapId);
	local str = string.format(StrConfig["chat100"],line,cfg.name,toint(x2D),toint(y2D));
	str = "<font color='#00ff00'>" .. str .. "</font>";
	if withLink then
		return self:GetLinkStr(str,paramStr);
	else
		return str;
	end
end

function MapPosChatParam:DoLink(paramStr)
	local params = self:Decode(paramStr);
	local line = toint(params[1]);
	if line ~= CPlayerMap:GetCurLineID() then
		FloatManager:AddSkill(StrConfig["chat112"]);
		return;
	end
	local mapId = toint(params[2]);
	local cfg = t_map[mapId];
	if not mapId then return ""; end
	local currMapId = MainPlayerController:GetMapId();
	if currMapId == mapId then
		local x = toint(params[3]);
		local y = toint(params[4]);
		MainPlayerController:DoAutoRun(mapId,_Vector3.new(x,y,0));
		return;
	end
	local currMapCfg = t_map[currMapId];
	if (currMapCfg.type==1 or currMapCfg.type==2) and (cfg.type==1 or cfg.type==2) then
		local x = toint(params[3]);
		local y = toint(params[4]);
		MainPlayerController:DoAutoRun(mapId,_Vector3.new(x,y,0));
	else
		FloatManager:AddSkill(StrConfig["chat117"]);
	end
end