EquipRefineModel = EquipRefineModel or class("EquipRefineModel", BaseBagModel)
local EquipRefineModel = EquipRefineModel
local json = require "cjson"
--json.encode_sparse_array(true)

function EquipRefineModel:ctor()
	EquipRefineModel.Instance = self
	self:Reset()
end

function EquipRefineModel:Reset()
	self.slots = {}
	self.free_count = 0
	self.select_itemid = 0
	self.red_max_itemid = 13121
	self.pink_itemid = 13122
	self.locks = {}
end

function EquipRefineModel.GetInstance()
	if EquipRefineModel.Instance == nil then
		EquipRefineModel()
	end
	return EquipRefineModel.Instance
end


function EquipRefineModel:SetInfo(data)
	for i=1, #data.slots do
		local v = data.slots[i]
		self.slots[v.slot] = v
	end
	if data.free_count then
		self.free_count = data.free_count
	end
end

--部位是否可以解锁
function EquipRefineModel:IsCanActive(slot)
	local refinecfg = Config.db_equip_refine[slot]
	local level = RoleInfoModel:GetInstance():GetMainRoleLevel()
	if not self.slots[slot] and level >= refinecfg.open then
		return true
	end
	return false
end

--部位是否已解锁
function EquipRefineModel:IsSlotActive(slot)
	if self.slots[slot] then
		return true
	end
	return false
end

--孔位是否可解锁
function EquipRefineModel:IsHoleCanActive(slot, hole)
	local puton = EquipModel:GetInstance():GetEquipBySlot(slot)
	if not puton then
		return false
	end
	local othercfg = Config.db_equip_refine_other[1]
	local costs = String2Table(othercfg.unlock)
	local need_vip = costs[5][2][2]
	local vip = RoleInfoModel:GetInstance():GetMainRoleVipLevel()
	local prefineslot = self.slots[slot]
	if prefineslot then
		local holes = prefineslot.holes
		if not holes[hole] and vip >= need_vip then
			return true
		end
	end
	return false
end

--洗练红点
function EquipRefineModel:GetNeedShowRedDot()
	local othercfg = Config.db_equip_refine_other[1]
	local total_count = othercfg.freecount
	local flag = false
	if self.free_count < total_count then
		flag = true
	end
	if not flag then
		local equipSetTbl = String2Table(Config.db_equip_set[5].slot)
		for k, slot in pairs(equipSetTbl) do
			if self:IsCanActive(slot) or self:IsHoleCanActive(slot, 5) then
				flag = true
				break
			end
		end
	end
	return flag
end

function EquipRefineModel:LoadLocks()
	local str = CacheManager:GetString("equip_refine", "")
	if str ~= ""  then
		self.locks = json.decode(str)
	end
end

function EquipRefineModel:SaveLocks()
	CacheManager:SetString("equip_refine", json.encode(self.locks))
end

function EquipRefineModel:IsLock(slot, hole)
	slot = slot .. ""
	local role_id = RoleInfoModel:GetInstance():GetMainRoleId()
	self.locks[role_id] = self.locks[role_id] or {}
	local role_lock = self.locks[role_id]
	return role_lock[slot] and role_lock[slot][hole] or false
end

function EquipRefineModel:UpdateLock(slot, hole, flag)
	slot = slot .. ""
	local role_id = RoleInfoModel:GetInstance():GetMainRoleId()
	self.locks[role_id] = self.locks[role_id] or {}
	local role_lock = self.locks[role_id]
	local lock = role_lock[slot] or {}
	lock[hole] = flag
	role_lock[slot] = lock
	self.locks[role_id] = role_lock
	self:SaveLocks()
end

