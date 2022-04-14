--
-- @Author: chk
-- @Date:   2018-10-31 17:53:17
--
EquipSuitModel = EquipSuitModel or class("EquipSuitModel",BaseBagModel)
local EquipSuitModel = EquipSuitModel

function EquipSuitModel:ctor()
	EquipSuitModel.Instance = self
	self:Reset()

	self.crntSuitLv = 1
	self.activeSuit = {}
	self.activeSlots = {}
	self.suitTypeName = {}
	self.selectDefaultEquip = {}
	self.suitTypeName[1] = ConfigLanguage.Equip.ChuangShi
	self.suitTypeName[2] = ConfigLanguage.Equip.ShenYuan
	self.suites = {}
end

function EquipSuitModel:Reset()

end

function EquipSuitModel.GetInstance()
	if EquipSuitModel.Instance == nil then
		EquipSuitModel()
	end
	return EquipSuitModel.Instance
end

function EquipSuitModel:FormatEquipSuite()
	for _, v in pairs(Config.db_equip_suite) do
		self.suites[v.id] = v
	end
end

function EquipSuitModel:GetEquipSuite(suite_id)
	return self.suites[suite_id]
end

function EquipSuitModel:AddActiveSuit(level, suitId,suitCount)
	local suit = self:GetActiveSuitBySuitId(suitId)
	if table.isempty(suit) then
		--table.insert(self.activeSuit,{suitId = suitId,suitCount = suitCount})
		table.insert(self.activeSuit[level], {suitId = suitId,suitCount = suitCount})
	else
		suit.suitCount = suitCount
	end
end

function EquipSuitModel:AddActiveSlot(suitLv,slots)
	self.activeSlots[suitLv] = slots
end

function EquipSuitModel:CleanActiveSuit()
	self.activeSuit = {}
end

function EquipSuitModel:CleanActiveSuitBySuitLv(suitLv)
	self.activeSuit[suitLv] = {}
end

function EquipSuitModel:GetCanBuildMaxSuitLv(id)
	local buildToLV = 0
	local equipCfg = Config.db_equip[id]
	local itemCfg = Config.db_item[id]
	local suitLVCfg1 = Config.db_equip_suite_level[1]
	local suitLvCfg2 = Config.db_equip_suite_level[2]

	if itemCfg.color >= suitLvCfg2.color and equipCfg.order >= suitLvCfg2.order and equipCfg.star >= suitLvCfg2.star then
		buildToLV = 2
	elseif itemCfg.color >= suitLVCfg1.color and equipCfg.order >= suitLVCfg1.order and equipCfg.star >= suitLVCfg1.star then
		buildToLV = 1
	end

	return buildToLV
end

--function EquipSuitModel:GetCanBuildSuitEquip()
--	local canBuildSuitEquips = {}
--	--local equips = EquipModel.Instance:GetCanStrongEquips()
--	for i, v in pairs(EquipModel.Instance.putOnedEquipDetailList) do
--		local equipConfig = Config.db_equip[v.id]
--		if self:GetSlotCanBuild(equipConfig.slot) then
--			table.insert(canBuildSuitEquips,v)
--		end
--	end
--
--	return canBuildSuitEquips
--end

--获取该部位的装备是否满足条件打造(放到左边的列表)
function EquipSuitModel:GetSlotCanBuild(slot)
	local canBuild = false
	for i, v in pairs(Config.db_equip_suite_make) do
		if v.slot == slot then
			canBuild = true
			break
		end
	end

	return canBuild
end

function EquipSuitModel:GetCanBuildSuit(equipDetail,suitLv)
	if equipDetail == nil or suitLv == nil then
		return nil
	end
	local canBuild = true
	local showSuitLv = self:GetShowSuitLvByEquip(equipDetail)
	local itemCfg = Config.db_item[equipDetail.id]
	local equipConfig = Config.db_equip[equipDetail.id]
	----local suitCount = self.model:GetActiveSuitCount(equipCfg.slot,equipCfg.order,showSuitLv)
	--local suitCfg = self:GetSuitConfig(equipCfg.slot,equipCfg.order,showSuitLv)
	--local attrsTb = String2Table(suitCfg.attribs)

	local suitLvCfg = {}
	if suitLv then
		suitLvCfg = Config.db_equip_suite_level[suitLv]
	else
		suitLvCfg = Config.db_equip_suite_level[showSuitLv]
	end
	if equipConfig.order < suitLvCfg.order then
		canBuild = false
	elseif itemCfg.color < suitLvCfg.color or equipConfig.star < suitLvCfg.star then
		canBuild = false
	end

	return canBuild
end

function EquipSuitModel:GetShowSuitLvByEquip(equipDetail)
	if equipDetail == nil then
		return
	end
	local showSuitLv = 2
	local equipConfig = Config.db_equip[equipDetail.id]
	local active2 = self:GetActiveByEquip(equipConfig.slot,2)
	if not active2 then
		showSuitLv = 1
	end

	return showSuitLv
end

function EquipSuitModel:GetSuitLvName(suitLv)
	return self.suitTypeName[suitLv]
end


function EquipSuitModel:GetActiveByEquip(slot,suitLv)
	if suitLv == 1 then
		return self:IsSlotMaked(slot)
	end
	local active = false
	for i, v in pairs(self.activeSlots[suitLv]) do
		if v == slot then
			active = true
			break
		end
	end

	return active
end

function EquipSuitModel:IsSlotMaked(slot)
	for level, slots in pairs(self.activeSlots) do
		for _, v in pairs(slots) do
			if slot == v then
				return true
			end
		end
	end
	return false
end

function EquipSuitModel:GetActiveSuitByEquip(slot,order,suitLv)
	local suitCfg = self:GetSuitConfig(slot,order,suitLv)
	local suit = self:GetActiveSuitBySuitId(suitCfg.id)

	return suit
end

function EquipSuitModel:GetActiveSuitCount(slot,order,suitLv)
	local suitCount = 0
	local suit = self:GetActiveSuitByEquip(slot,order,suitLv)
	if not table.isempty(suit) then
		suitCount = suit.suitCount
	end
	return suitCount
end

function EquipSuitModel:GetActiveSuitBySuitId(suitId)
	local suit = {}
	for level, suites in pairs(self.activeSuit) do
		if not table.isempty(suites) then
			for k, v in ipairs(suites) do
				if v.suitId == suitId then
					suit = v
					break
				end
			end
		end
	end

	return suit
end

function EquipSuitModel:GetSuitConfig(slot,order,suitLv)
	local suitCfg = {}
	local suitMakeCfg = self:GetSuitMakeConfig(slot,order,suitLv)
	if not table.isempty(suitMakeCfg) then
		if suitMakeCfg.type_id == 2 then
			order = 0
		end
		local suitKey = suitMakeCfg.type_id .. "@" .. order .. "@" .. suitLv
		suitCfg = Config.db_equip_suite[suitKey]
	end
	return suitCfg or {}
end

function EquipSuitModel:GetSuitMakeConfig(slot,order,suitLv)
	local suitMakeKey = slot .. "@" .. order .. "@" .. suitLv
	local suitMakeCfg = Config.db_equip_suite_make[suitMakeKey]
	return suitMakeCfg or {}
end


function EquipSuitModel:GetSuitCount(slot,order,suitLv)
	--local suitMakeCfg = self:suitMakeCfg(slot,order)
	local suitCfg = self:GetSuitConfig(slot,order,suitLv)
	local slotTbl = String2Table(suitCfg.slots or {})
	return table.nums(slotTbl)
end

--该装备是否要显示小红点
function EquipSuitModel:GetNeedShowRedDotByEquip(equipDetail,suitLv)
	if not self:GetCanBuildSuit(equipDetail,suitLv) then
		return false
	else
		local equipCfg = Config.db_equip[equipDetail.id]
		if suitLv == 2 and not self:GetActiveByEquip(equipCfg.slot,1) then
			return false
		else
			local suitMakeCfg = self:GetSuitMakeConfig(equipCfg.slot,equipCfg.order,suitLv)

			local costTbl = String2Table( suitMakeCfg.cost or {})
			local canSuit = true
			local career = RoleInfoModel:GetInstance():GetRoleValue("career")
			costTbl = costTbl[career]
			for i, v in ipairs(costTbl) do
				local itemCfg = Config.db_item[v[1]]
				local hasNum = BagModel.Instance:GetItemNumByItemID(itemCfg.id)

				if hasNum < v[2] then
					canSuit = false
				end
			end


			local active = self:GetActiveByEquip(equipCfg.slot,suitLv)
			if active then
				return false
			else
				return canSuit
			end
		end
	end

end

function EquipSuitModel:GetNeedShowRedDot()
	local putOnedEquips = EquipModel.GetInstance():GetCanSuitEquips()
	local onelVShow = self:GetNeedShowRedDotLevel(putOnedEquips, 1)
	if onelVShow then
		return true
	end
	local twoLVShow = self:GetNeedShowRedDotLevel(putOnedEquips, 2)

	return onelVShow or twoLVShow
end

function EquipSuitModel:GetNeedShowRedDotLevel(putOnedEquips, level)
	if not putOnedEquips then
		putOnedEquips = EquipModel.GetInstance():GetCanSuitEquips()
	end
	for i, v in pairs(putOnedEquips) do
		if self:GetNeedShowRedDotByEquip(v,level) then
			return true
		end
	end
	return false
end





