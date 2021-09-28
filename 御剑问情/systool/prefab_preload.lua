-- 加载器
local Loader = Loader or BaseClass()
function Loader:__init()
	self.id = 0
	self.callback = nil
	self.load_total_num = 0
	self.loaded_num = 0
	self.is_loading = false
end

function Loader:__delete()

end

function Loader:GetId()
	return self.id
end

function Loader:IsLoading()
	return self.is_loading
end

function Loader:StopLoad()
	self.is_loading = false
end

function Loader:StartLoad(id, list, callback)
	self.id = id
	self.callback = callback
	self.loaded_num = 0
	self.load_total_num = 0
	self.is_loading = true

	for _, v in ipairs(list) do
		local bundle = v[1]
		local asset = v[2]

		if nil ~= bundle and nil ~= asset then
			self.load_total_num = self.load_total_num + 1
			PrefabPool.Instance:Load(AssetID(bundle, asset), function(prefab)
				PrefabPool.Instance:Free(prefab)
				self.loaded_num = self.loaded_num + 1
				if self.loaded_num >= self.load_total_num and self.is_loading then
					self.is_loading = false
					self.callback()
				end
			end)
		end
	end

	if self.load_total_num <= 0 then
		self.is_loading = false
		self.callback()
	end
end

-- prefabload
PrefabPreload = PrefabPreload or BaseClass()
function PrefabPreload:__init()
	if PrefabPreload.Instance then
		print_error("[PrefabPreload]:Attempt to create singleton twice!")
	end
	PrefabPreload.Instance = self

	self.inc_id = 0
	self.wait_queue = {}
	self.loader = Loader.New()

	Runner.Instance:AddRunObj(self, 8)
end

function PrefabPreload:__delete()
	Runner.Instance:RemoveRunObj(self)
	self.loader:DeleteMe()
	PrefabPreload.Instance = nil
end

function PrefabPreload:Update(now_time, elapse_time)
	if #self.wait_queue <= 0 then
		return
	end

	if self.loader:IsLoading() then
		return
	end

	local t = table.remove(self.wait_queue, 1)
	self.loader:StartLoad(t.id, t.list, function()
		if nil ~= t.callback then
			t.callback()
		end
	end)
end

function PrefabPreload:LoadPrefables(list, callback)
	self.inc_id = self.inc_id + 1
	table.insert(self.wait_queue, {id = self.inc_id, list = list, callback = callback})

	return self.inc_id
end

function PrefabPreload:StopLoad(id)
	for k, v in pairs(self.wait_queue) do
		if v.id == id then
			table.remove(self.wait_queue, k)
			break
		end 
	end

	if self.loader:IsLoading() and self.loader:GetId() == id then
		self.loader:StopLoad()
	end 
end
