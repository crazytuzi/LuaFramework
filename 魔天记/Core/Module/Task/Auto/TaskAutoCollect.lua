TaskAutoCollect = class("TaskAutoCollect", SequenceContent)
local insert = table.insert

function TaskAutoCollect.GetSteps()
	return {
		TaskAutoCollect.A
	};
end

function TaskAutoCollect.A(seq)
	local task = seq:GetTask();
	local cfg = seq:GetCfg();
	local radius = tonumber(cfg.target[3]);
	local cache = task.cache;
	local mapId = task.mapId;

	local tmp = {};
	for k, v in pairs(cache) do
		if TaskUtils.InMap(mapId) then
			local obj = GameSceneManager.map:GetSceneObjById(k);
			if obj and obj:IsEnable() then
				insert(tmp, k);
			end
		else
			insert(tmp, k);
		end
	end

	local item = nil;
	if #tmp > 0 then
		local idx = math.floor(math.Random(1, #tmp + 1));
		item = cache[tmp[idx]];
	end

	if item then

		local map = item.map;
		local pos = item.pos;
		if seq:IsPay() then
			return SequenceCommand.Task.TaskTransmit(map, pos);
		end

		return SequenceCommand.Common.GoToPos(map, pos, radius, 1.5);
	end

	return nil;
end
