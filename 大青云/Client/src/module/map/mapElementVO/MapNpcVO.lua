--[[
地图单位：地图Npc
2015年4月11日17:34:39
haohu
]]

_G.MapNpcVO = MapElementVO:new();

function MapNpcVO:GetClass()
	return MapNpcVO;
end

function MapNpcVO:IsAvailableInMap(mapName)
	if mapName == MapConsts.MapName_Small then
		return false
	end
	return true
end

function MapNpcVO:GetLayer()
	return "bottom";
end

function MapNpcVO:GetType()
	return MapConsts.Type_Npc;
end

function MapNpcVO:GetLabelInfo()
	local labels = {};
	local cfg = t_npc[self.id];
	if cfg then
		table.push( labels, cfg.name );
		if cfg.mapFunc ~= "" then
			table.push( labels, string.format( StrConfig['map104'], cfg.mapFunc ) );
		end
	end
	return labels;
end

function MapNpcVO:GetUIData()
	local vo = {};
	vo.x = self.x;
	vo.y = self.y;
	local labels = self:GetLabelInfo();
	for i = 1, #labels do
		vo["label"..i] = labels[i];
	end
	vo.labelColor = 0xffffff;
	vo.uid = self:ToString();
	return UIData.encode(vo);
end

-- 获取地图图标tips文本
function MapNpcVO:GetTipsTxt()
	local cfg = t_npc[self.id];
	if cfg then
		local mapFunc = cfg.mapFunc;
		local name = cfg.name;
		if mapFunc ~= "" then
			return string.format( StrConfig["map110"], name, mapFunc );
		end
		return name;
	end
	return "tool tip config missing";
end

function MapNpcVO:GetAsLinkage()
	--优先显示任务图标
	local state = QuestController:GetNpcQuestState(self.id);
	if state == QuestConsts.State_CanAccept then
		return "npc_taskAcceptable";
	elseif state == QuestConsts.State_Going then
		return "npc_taskUnfinished";
	elseif state == QuestConsts.State_CanFinish then
		return "npc_taskFinished";
	end
	--其次显示其他各种npc图标
	local cfg = t_npc[self.id];
	if cfg then
		if cfg.type == NpcConsts.Type_Storage then
			return "npc_storage";
		elseif cfg.type == NpcConsts.Type_Shop then
			return "npc_shop";
		end
	end
	--显示普通npc图标
	return "npc_normal";
end
