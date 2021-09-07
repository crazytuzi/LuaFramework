QueueLoader = QueueLoader or BaseClass()
function QueueLoader:__init()
	if QueueLoader.Instance then
		print_error("[QueueLoader]:Attempt to create singleton twice!")
	end
	QueueLoader.Instance = self

	self.wait_queue = {}

	Runner.Instance:AddRunObj(self, 8)
end

function QueueLoader:__delete()
	QueueLoader.Instance = nil
	Runner.Instance:RemoveRunObj(self)
end

function QueueLoader:Update(now_time, elapse_time)
	if #self.wait_queue <= 0 then
		return
	end

	local t = table.remove(self.wait_queue, 1)
	UtilU3d.PrefabLoad(t.bundle, t.asset, t.callback)
end

function QueueLoader:LoadPrefab(bundle, asset, callback)
	table.insert(self.wait_queue, {bundle = bundle, asset = asset, callback = callback})
end