
-- 背包仓库
BagData = BagData or BaseClass()

function BagData:GetOneEmptyStorage()
	return 1 --只有1
end

--判断仓库是否已满
function BagData:IsStorageFull()
	return #self:GetStorageList() < bit:_rshift(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_STALL_GRID_COUNT), 16)
end


function BagData:SortStorageList()
	local function sort_baglist()
		return function(a, b)
			if a.item_id ~= b.item_id then
				return a.item_id > b.item_id
			elseif a.num ~= b.num then
				return a.num < b.num
			else
				return a.is_bind < b.is_bind
			end
		end
	end
	table.sort(self.storage_list, sort_baglist())
end

--添加仓库数据
local add_storage_id_cache = {}
function BagData:AddStorageList(info)
	if nil ~= add_storage_id_cache[info.storage_id] then
		return
	end
	add_storage_id_cache[info.storage_id] = 1		-- 缓存已获取的仓库id

	for k,v in pairs(info.storage_list) do
		table.insert(self.storage_list, v)
	end
	-- self:SortStorageList()
	self:DispatchEvent(BagData.STORAGE_ITEM_CHANGE)
end

--添加仓库数据
function BagData:AddOneStorageItem(info)
	table.insert(self.storage_list, info.item)
	self:DispatchEvent(BagData.STORAGE_ITEM_CHANGE)
end

--删除仓库数据
function BagData:DelOneStorageItem(index)
	table.remove(self.storage_list, index)
	self:DispatchEvent(BagData.STORAGE_ITEM_CHANGE)
end

function BagData:ChangeOneStorageItemNum(index, num)
	if self:GetStorageItem(index) then
		self:GetStorageItem(index).num = num
	end
end

--获取仓库数据
function BagData:GetStorageList()
	return self.storage_list
end

--获取仓库数据
function BagData:GetStorageItem(index)
	return self.storage_list[index]
end

--获取仓库数据
function BagData:GetStorageItemIndexBySeries(series)
	for k,v in pairs(self.storage_list) do
		if v.series == series then
			return k
		end
	end
	return -1
end

--设置仓库保护状态
function BagData:SetStorageLockType(lock_type)
	self.storage_lock_type = lock_type
	self:DispatchEvent(BagData.STORAGE_LOCK_TYPE_CHANGE)
end

function BagData:GetStorageLockType()
	return self.storage_lock_type
end
