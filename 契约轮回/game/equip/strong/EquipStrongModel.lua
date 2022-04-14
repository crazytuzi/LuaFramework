--
-- @Author: chk
-- @Date:   2018-09-18 15:07:59
--
EquipStrongModel = EquipStrongModel or class("EquipStrongModel",BaseBagModel)
local EquipStrongModel = EquipStrongModel

function EquipStrongModel:ctor()
	EquipStrongModel.Instance = self

	self.role_data = RoleInfoModel.GetInstance():GetMainRoleData()
	self:Reset()
end

function EquipStrongModel:Reset()
	self.is_auto_strong = false
	self.minStrongEquip = nil
	self.slotMapPhaselv = {}
	self.last_select_item = nil
	self.strong_type = 1         --强化类型（1-强化，2-铸造）
	self.suitId = 0
end

function EquipStrongModel.GetInstance()
	if EquipStrongModel.Instance == nil then
		EquipStrongModel()
	end
	return EquipStrongModel.Instance
end

function EquipStrongModel:GetNextPhase(crntSlot,crntPhase,crntLv)
	local key = crntSlot .. "@" .. crntPhase .. "@" .. (crntLv + 1)
	if Config.db_equip_strength[key] ~= nil then
		return crntPhase
	else
		return crntPhase + 1
	end
end

function EquipStrongModel:GetNextStrong(crntSlot,crntPhase,crntLv)
	local key = crntSlot .. "@" .. crntPhase .. "@" .. (crntLv + 1)
	if Config.db_equip_strength[key] ~= nil then
		return  Config.db_equip_strength[key]
	else
		local nextPhase = crntPhase + 1
		key = crntSlot .. "@" .. nextPhase .. "@".. 1
		return Config.db_equip_strength[key]
	end
end

function EquipStrongModel:GetAttStrongValue(att,strongCfg)
	local vlu = 0
	for i, v in pairs(String2Table(strongCfg.attrib)) do
		if att == v[1] then
			vlu = v[2]
			break
		end
	end

	return vlu
end

--获取最小强化等级
function EquipStrongModel:GetMinStrongEquip()
	local min = 0
	local minStrogEquip = nil
	local equips = EquipModel.Instance:GetCanStrongEquips()
	for i, v in pairs(equips) do
		if not self:IsMaxStrong(v) then
			if min == 0 then
				min = v.equip.stren_phase*10 + v.equip.stren_lv
				minStrogEquip = v
			else
				local _min = v.equip.stren_phase*10 + v.equip.stren_lv
				if _min < min then
					min = _min
					minStrogEquip = v
				end
			end
		end
	end

	return minStrogEquip or equips[1]
end

--是否所有都达到最大强化等级
function EquipStrongModel:IsAllStrongMax()
	local equips = EquipModel.Instance:GetCanStrongEquips()
	for _, pitem in pairs(equips) do
		if not self:IsMaxStrong(pitem) then
			return false
		end
	end
	return true
end

--是否达到最高强化等级
function EquipStrongModel:IsMaxStrong(pitem)
    local equipCfg = Config.db_equip[pitem.id]
    local itemCfg = Config.db_equip[pitem.id]
    local key = string.format("%s@%s@%s", equipCfg.slot, equipCfg.order, itemCfg.color)
    local strongLimit = Config.db_equip_strength_limit[key]
    if pitem.equip.stren_phase + 1 == strongLimit.max_phase and pitem.equip.stren_lv == 10 then
        return true
    end
    return false
end

function EquipStrongModel:GetStrongConfig(equipId,strongPhase,strongLV)
	local equipConfig = Config.db_equip[equipId]
	local strong_key = equipConfig.slot .. "@" .. strongPhase .. "@" .. strongLV
	return Config.db_equip_strength[strong_key]
end

function EquipStrongModel:SetSlotMapPhaseLv(slot)
	self.slotMapPhaselv[slot] = self.slotMapPhaselv[slot] or {}
end

function EquipStrongModel:GetStrongCountByPhase(phase,level)
	local equips = EquipModel.Instance:GetCanStrongEquips()
	local count = 0
	for i, v in pairs(equips) do
		if v.equip.stren_phase >= phase and v.equip.stren_lv >= level then
			count = count + 1
		end
	end
	return count
end

--是否可以升级强化套装
function EquipStrongModel:IsCanUpStrongSuite()
	local nextsuite = Config.db_equip_strength_suite[self.suitId + 1]
	if nextsuite then
		local hadcount = self:GetStrongCountByPhase(nextsuite.phase, nextsuite.level)
		if hadcount >= nextsuite.num then
			return true
		end
	end
	return false
end

function EquipStrongModel:GetStrongSuit()
	local phase = 100
	local equips = EquipModel.Instance:GetCanStrongEquips()
	for i, v in pairs(equips) do
		if v.equip.stren_phase < phase then
			phase = v.equip.stren_phase
		end
	end
	return phase
end

--该装备是否要显示小红点
function EquipStrongModel:GetNeedShowRedDotByEquip(equipDetail)

	local itemConfig = Config.db_item[equipDetail.id]
	local equipConfig = Config.db_equip[equipDetail.id]
	local strong_key = equipConfig.slot .. "@" .. equipDetail.equip.stren_phase .. "@" .. equipDetail.equip.stren_lv
	local strong_limit_key = equipConfig.slot .. "@" .. equipConfig.order .. "@" .. itemConfig.color

	if Config.db_equip_strength_limit[strong_limit_key] == nil then
		return false
	end

	if self:GetNextPhase(equipConfig.slot,equipDetail.equip.stren_phase,equipDetail.equip.stren_lv) >= Config.db_equip_strength_limit[strong_limit_key].max_phase then
		return false
	end
	local costCfg = String2Table(Config.db_equip_strength[strong_key].cost)

	if table.nums(costCfg) < 2 then
		return false
	end

	if RoleInfoModel.GetInstance():GetRoleValue(costCfg[1]) >= tonumber(costCfg[2]) then
		return true
	else
		return false
	end
end

--装备的铸造红点
function EquipStrongModel:IsNeedShowCastRedDotByEquip(pitem)
	local level = pitem.equip.cast
	local item_id = pitem.id
	local max_level = self:GetCastMaxLevel(item_id)
	if level < max_level then
		local itemcfg = Config.db_item[item_id]
		local equipcfg = Config.db_equip[item_id]
		local key = string.format("%s@%s", equipcfg.slot, level+1)
		local cost = String2Table(Config.db_equip_cast[key].cost)
		for _, v in pairs(cost) do
			local id = v[1]
			local num = v[2]
			local had = BagController:GetInstance():GetItemListNum(id)
			if had < num then
				return false
			end
		end
	else
		return false
	end
	return true
end

--强化红点
function EquipStrongModel:GetNeedShowRedDot()
	local hasRedDot = false
	for i, v in pairs(EquipModel.Instance:GetCanStrongEquips()) do
		if self:GetNeedShowRedDotByEquip(v) then
			hasRedDot = true
			break
		end
	end

	return hasRedDot
end

--铸造红点
function EquipStrongModel:GetNeedShowCastRedDot()
	local hasRedDot = false
	for k, v in pairs(EquipModel.Instance:GetCanCastEquips()) do
		if self:IsNeedShowCastRedDotByEquip(v) then
			hasRedDot = true
			break
		end
	end
	return hasRedDot
end


--计算铸造属性
function EquipStrongModel:CalcCastAttr(pitem, level)
	local item_id = pitem.id
	local equipcfg = Config.db_equip[item_id]
	local baseAttr = EquipModel:GetInstance():FormatAttr(equipcfg.base)
	local key = string.format("%s@%s", equipcfg.slot, level)
	local castcfg = Config.db_equip_cast[key]
	local strongcfg = self:GetStrongConfig(item_id, pitem.equip.stren_phase, pitem.equip.stren_lv)
	local strongAttr = EquipModel:GetInstance():FormatAttr(strongcfg.attrib)
	local castAttr = {}
	for k, v in pairs(baseAttr) do
		castAttr[k] = math.floor((v + (strongAttr[k] or 0)) * castcfg.percent/10000)
	end
	local otherAttr = EquipModel:GetInstance():FormatAttr(castcfg.attr)
	for k, v in pairs(otherAttr) do
		castAttr[k] = (castAttr[k] or 0) + v
	end

	return castAttr
end

--获取最大铸造等级
function EquipStrongModel:GetCastMaxLevel(item_id)
	local itemcfg = Config.db_item[item_id]
	local equipcfg = Config.db_equip[item_id]
	local key = string.format("%s@%s@%s", equipcfg.order, itemcfg.color, equipcfg.star)
	local castlimit = Config.db_equip_cast_limit[key]
	return castlimit and castlimit.level or 0
end











