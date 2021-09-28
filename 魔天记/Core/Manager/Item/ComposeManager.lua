ComposeManager = {};
ComposeManager.type = nil;
ComposeManager.data = nil;
ComposeManager.Type = {
	STONE = 1;		--紫阳石
	EQUIP = 2; 		--装备精炼
	PILL = 3;		--丹药
}

local cfgs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FORMULA);
local insert = table.insert
local sort = table.sort

function ComposeManager.Init()
	ComposeManager.type = {};
	ComposeManager.data = {};
	
	for k, v in pairs(cfgs) do
		local itemStr = v.demand_item;
		local itemArr = string.split(itemStr, "_");
		ComposeManager.data[tonumber(itemArr[1])] = v;
		if not ComposeManager.type[v.type] then
			ComposeManager.type[v.type] = {};
		end
		insert(ComposeManager.type[v.type], v);
	end

	for k, v in pairs(ComposeManager.type) do
		sort(v, function(a,b) return a.id < b.id end);
	end
end

function ComposeManager.GetCfgByProductId(pid)
	return ComposeManager.data[pid];
end

function ComposeManager.GetTypes()
	local d = {};
	for k, v in pairs(ComposeManager.type) do
		insert(d, k);
	end
	sort(d, function(a,b) return a < b end);
	return d;
end

function ComposeManager.GetListByType(t)
	--[[
	local d = {};
	for i, v in ipairs(cfgs) do
		if v.type == t then
			insert(d, v);
		end
	end
	return d;
	]]
	return ComposeManager.type[t] or {};
end

