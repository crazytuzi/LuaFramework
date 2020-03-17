--[[
聊天快捷发送
发送位置物品等
lizhuangzhuang
2014年9月24日22:09:30
]]

_G.ChatQuickSend = {};

--发送坐标
function ChatQuickSend:SendPos()
	local line = CPlayerMap:GetCurLineID();
	local mapId = MainPlayerController:GetMapId();
	local mapCfg = t_map[mapId];
	if not mapCfg then return false; end
	if mapCfg.type~=1 and mapCfg.type~=2 then
		return false;
	end
	local pos = MainPlayerController:GetPos();
	local encoder = MapPosChatParam:new();
	local val = encoder:Encode(line,mapId,toint(pos.x),toint(pos.y));
	local key = StrConfig['chat108'];
	UIChat:AddQuickSend(key,val);
	return true;
end

--发送物品
function ChatQuickSend:SendItem(bag,pos)
	local bagVO = BagModel:GetBag(bag);
	if not bagVO then return;end
	local item = bagVO:GetItemByPos(pos);
	if not item then return; end
	local cfg = item:GetCfg();
	if not cfg then return; end
	if item:GetShowType() == BagConsts.ShowType_Equip then
		local encoder = EquipChatParam:new();
		local val = encoder:EncodeEquip(item);
		UIChat:AddQuickSend("["..cfg.name.."]",val);
	else
		local encoder = ItemChatParam:new();
		local val = encoder:EncodeItem(item);
		UIChat:AddQuickSend("["..cfg.name.."]",val);
	end
end