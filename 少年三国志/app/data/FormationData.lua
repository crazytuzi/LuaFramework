--FormationData.lua


local FormationData = class ("FormationData")
local funLevelConst = require("app.const.FunctionLevelConst")
require("app.cfg.team_target_info")
require("app.cfg.pet_info")
require "app.cfg.function_level_info"

function FormationData:ctor(  )
	
    self._firstTeam = {}
    self._firstFormation = {}
    self._secondTeam = {}
    self._secondFormation = {}
    self._showTeamId = 1

    self._fightEquipments = {}
    self._fightTreasures = {}
    self._protectPets = {} -- 护佑的战宠们

    self._fightEquipQuality = {}
    self._fightTreasureQuality = {}
end

function FormationData:showMainTeam( mainTeam )
	self._showTeamId = 1
end

function FormationData:showTeamId( )
	return self._showTeamId
end

function FormationData:getMainKnightId(  )
	if not self._firstTeam or not self._firstTeam[1] then
		return 0
	end

	return self._firstTeam[1]
end

function FormationData:isFirstTeamFull( )
	if #self._firstTeam < 6 then 
		return false
	end
	for key, value in pairs(self._firstTeam) do 
		if type(value) == "number" and value < 1 then 
			return false
		end
	end

	return true
end

function FormationData:getMainTeamCountryIds( ... )
	local teamIds = {}
	for key, value in pairs(self._firstTeam) do 
		if type(value) == "number" then
			local baseId = 0 
			local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(value)
    		if knightInfo then
    			baseId = knightInfo["base_id"]
    		end

    		local baseInfo = knight_info.get(baseId)
    		if baseInfo then 
    			local groupCount = teamIds[baseInfo.group] or 0
    			teamIds[baseInfo.group] = groupCount + 1
    		end
		end
	end

	return teamIds
end

function FormationData:getTeamKnightIdAndBaseIdByIndex( teamId, index )
    if teamId ~= 1 and teamId ~= 2 then
            __LogError("teamId is wrong!")
            return 
    end

    local team = (teamId == 1) and self._firstTeam or self._secondTeam
    local knightId = team[index] or 0
    local baseId = 0
    if type(knightId) == "number" and knightId > 0 then
    	local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId(knightId)
    	if knightInfo then
    		baseId = knightInfo["base_id"]
    	end
    end

    return knightId, baseId
end

function FormationData:getFormationIndexAndKnighId( teamId, index )
	if teamId ~= 1 and teamId ~= 2 then
		__LogError("teamId is wrong!")
		return 
	end

	local team = (teamId == 1) and self._firstTeam or self._secondTeam
	local formation = (teamId == 1) and self._firstFormation or self._secondFormation

	local formationIndex = formation[index] or 0
	local knightId = formationIndex ~= nil and team[formationIndex] or 0

	return formationIndex, knightId
end

function FormationData:getFormationHeroCount( teamId )
	teamId = teamId or 1
	local team = (teamId == 1) and self._firstTeam or self._secondTeam
	local count = 0
	for _, value in pairs(team) do
		if type(value) == "number" and value > 0 then
			count = count + 1
		end
	end

	return count
end

function FormationData:getFormationIndexByKnightIndex( teamId, index )
	teamId = teamId or 1
	local formation = (teamId == 1) and self._firstFormation or self._secondFormation

	for i, value in pairs(formation) do
		if value ~= nil and value == index then
			return i
		end
	end

	return nil
end

function FormationData:getFormationIdByFormationIndex( teamId, index )
	teamId = teamId or 1
	local formation = (teamId == 1) and self._firstFormation or self._secondFormation
	return formation[index]
end

function FormationData:getKnightIdByIndex( teamId, index )
	teamId = teamId or 1
	local team = (teamId == 1) and self._firstTeam or self._secondTeam
	return team[index] or 0
end

function FormationData:getFormationIdKnightIdByOrderIndex( teamId, order )
	teamId = teamId or 1
	local team = (teamId == 1) and self._firstTeam or self._secondTeam
	local formation = (teamId == 1) and self._firstFormation or self._secondFormation
	
	local formationId = self:getFormationIndexByKnightIndex(teamId, order)
	if formationId == nil then
		return 0, 0
	end

	return formationId, team[order]
end

function FormationData:isKnightValidjForCurrentTeam(teamId, knightId, posIndex )
	if not knightId or knightId < 1 then
		return false
	end

	teamId = teamId or 1
	local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(knightId) 
	local baseInfo = knight_info.get(baseId)
	for i, value in pairs(self._firstTeam) do
		if teamId == 2 or posIndex ~= i then 
			local teamBaseId = G_Me.bagData.knightsData:getBaseIdByKnightId(value) 
			if teamBaseId == baseId then
				return false
			end

			local teamBaseInfo = knight_info.get(teamBaseId)
			if baseInfo and teamBaseInfo and baseInfo.advance_code == teamBaseInfo.advance_code then
				return false
			end
		end
	end

	for i, value in pairs(self._secondTeam) do
		if teamId == 1 or posIndex ~= i then 
			local teamBaseId = G_Me.bagData.knightsData:getBaseIdByKnightId(value) 
			if teamBaseId == baseId then
				return false
			end

			local teamBaseInfo = knight_info.get(teamBaseId)
			if baseInfo and teamBaseInfo and baseInfo.advance_code == teamBaseInfo.advance_code then
				return false
			end
		end
	end

	return true
end

function FormationData:updateFormation( teamId, indexTable, knightTable )
	if teamId == 1 then
		self._firstTeam = indexTable
		self._firstFormation = knightTable
		G_Me.bagData.knightsData:setMainKnightId(self._firstTeam[1])
	elseif teamId == 2 then
		self._secondTeam = indexTable
		self._secondFormation = knightTable
	else
		__LogError("updateFormation: wrong teamId:%d", teamId)
	end
end

function FormationData:updateFormationIndex( teamId, indexTable )
	if teamId == 1 then
		self._firstFormation = indexTable
	elseif teamId == 2 then
		self._secondFormation = indexTable
	else
		__LogError("updateFormationIndex: wrong teamId:%d", teamId)
	end
end

function FormationData:changeFormationId( teamId, index, knightId )
	if teamId == 1 then
		self._firstTeam[index] = knightId
	elseif teamId == 2 then
		self._secondTeam[index] = knightId
	else
		__LogError("changeFormationId: wrong teamId:%d", teamId)
	end
end


function FormationData:isKnightInTeam( teamId , knightId)
	local team = (teamId == 1) and self._firstTeam or self._secondTeam
	--local formation = (teamId == 1) and self._firstFormation or self._secondFormation

	local index = 1
	while index <= table.getn(team) do
			if team[index] > 0 and team[index] == knightId then
				return true
			end

		index = index + 1
	end

	return false
end

function FormationData:isKnightInTeamByFragment( teamId, knightFragValue)
	local team = (teamId == 1) and self._firstTeam or self._secondTeam

	local index = 1
	while index <= table.getn(team) do
		local knightBaseID = G_Me.bagData.knightsData:getBaseIdByKnightId(team[index])
		local teamKnightInfo = knight_info.get(knightBaseID)
		if teamKnightInfo and teamKnightInfo.advance_code == knightFragValue then
			return true
		end

		index = index + 1
	end

	return false
end

function FormationData:getKnightTeamId( knightId )
	if self:isKnightInTeam(1, knightId)  then
		return 1
	elseif self:isKnightInTeam(2, knightId) then
		return 2
	else
		return 0
	end
end

function FormationData:getKnightTeamIdByFragment( knightFragValue )
	if self:isKnightInTeamByFragment(1, knightFragValue)  then
		return 1
	elseif self:isKnightInTeamByFragment(2, knightFragValue) then
		return 2
	else
		return 0
	end
end

function FormationData:hasKnightOnTeam( advanceCode, teamId )
	if type(advanceCode) ~= "number" then 
		return false
	end

	local teamIds = (type(teamId) == "number" and teamId == 2) and self._secondTeam or self._firstTeam
	for key, value in pairs(teamIds) do 
		local baseId = G_Me.bagData.knightsData:getBaseIdByKnightId(value)
		local knightInfo = knight_info.get(baseId)
		if knightInfo and knightInfo.advance_code == advanceCode then 
			return true 
		end
	end

	return false
end

function FormationData:getFirstTeamKnightIds(  )
	local arr = {}
	local count = 0
	for i, v in pairs(self._firstTeam) do 
		if v > 0 then 
			table.insert(arr, #arr + 1, v or 0)
			count = count + 1	
		end
	end

	return arr, count
end

function FormationData:getKnightPosInTeam( knightId )
	if type(knightId) ~= "number" or knightId < 1 then 
		return 0, 0
	end

	for i, v in pairs(self._firstTeam) do
		if v == knightId then 
			return 1, i 
		end
	end

	for i, v in pairs(self._secondTeam) do
		if v == knightId then 
			return 2, i 
		end
	end

	return 0, 0
end

function FormationData:getSecondTeamKnightIds(  )
	local arr = {}
	local count = 0
	for i, v in pairs(self._secondTeam) do  
		table.insert(arr, #arr + 1, v or 0)
		if v > 0 then 
			count = count + 1
		end
	end

	return arr, count
end


-- equipment and treasure formation data
function FormationData:resetEquipmentFormation( fightEquipments )
	self._fightEquipments = fightEquipments or {}

	G_Me.bagData:sortEquipmentList()
	self:_calcFightEquipQuality(true)
end

function FormationData:_calcFightEquipQuality( resetEquip, resetTreasure, slotId )
	if resetEquip then 
		self._fightEquipQuality = {}
	end
	if resetTreasure then 
		self._fightTreasureQuality = {}
	end
	if not resetEquip and not resetTreasure then 
		if type(slotId) ~= "number" or slotId > 6 or slotId < 1 then 
			return 
		end
	end

	local MAX_POS = G_Me.userData:getMaxTeamSlot()
	local calcFightEquipBySlot = function ( slot, minQuality )
		minQuality = minQuality or 0
		if type(slot) ~= "number" or slot > 4 or slot < 1 then 
			return minQuality
		end

		local localMinQuality = minQuality
		for key, value in pairs(self._fightEquipments) do 
			if type(value) == "table" and key <= MAX_POS  and localMinQuality > 0 then 
				if value["slot_"..slot] > 0 then 
					local equipInfo = G_Me.bagData.equipmentList:getItemByKey(value["slot_"..slot])
					if equipInfo then 
						equipInfo = equipment_info.get(equipInfo["base_id"])
						if equipInfo and equipInfo.quality < localMinQuality then 
							localMinQuality = equipInfo.quality
						end
					end
				else
					localMinQuality = 0
				end
			end
		end	

		return localMinQuality
	end

	local calcFightTreasureBySlot = function ( slot, minQuality )
		minQuality = minQuality or 0
		if type(slot) ~= "number" or slot > 4 or slot < 1 then 
			return minQuality
		end

		local localMinQuality = minQuality
		for key, value in pairs(self._fightTreasures) do 
			if type(value) == "table"  and key <= MAX_POS and localMinQuality > 0 then 
				if value["slot_"..slot] > 0 then 
					local equipInfo = G_Me.bagData.treasureList:getItemByKey(value["slot_"..slot])
					if equipInfo then 
						equipInfo = treasure_info.get(equipInfo["base_id"])
						if equipInfo and equipInfo.quality < localMinQuality then 
							localMinQuality = equipInfo.quality
						end
					end
				else
					localMinQuality = 0
				end
			end
		end	

		return localMinQuality
	end

	if resetEquip then 
		self._fightEquipQuality[1] = calcFightEquipBySlot(1, 10)
		self._fightEquipQuality[2] = calcFightEquipBySlot(2, 10)
		self._fightEquipQuality[3] = calcFightEquipBySlot(3, 10)
		self._fightEquipQuality[4] = calcFightEquipBySlot(4, 10)
	end
	if resetTreasure then 
		self._fightTreasureQuality[1] = calcFightTreasureBySlot(1, 10)
		self._fightTreasureQuality[2] = calcFightTreasureBySlot(2, 10)
	end
	if not resetEquip and not resetTreasure then 
		if slotId <= 4 then 
			self._fightEquipQuality[slotId] = calcFightEquipBySlot(slotId, 10)
		else
			self._fightTreasureQuality[slotId - 4] = calcFightTreasureBySlot(slotId - 4, 10)
		end
	end
end

function FormationData:checkEffectiveEquip( startSlot )
	startSlot = type(startSlot) == "number" and startSlot or 1
	startSlot = startSlot > 7 and 7 or (startSlot < 1 and 1 or startSlot)

	local checkEquipBySlot = function ( slotId )
		if type(slotId) ~= "number" or slotId < 1 or slotId > 6 then 
			return false
		end

		local baseQuality = slotId <= 4 and self._fightEquipQuality[slotId] or 
											self._fightTreasureQuality[slotId - 4]
		local equipList = slotId <= 4 and G_Me.bagData:getEquipmentListByType( slotId ) or 
						G_Me.bagData:getTreasureListByType( slotId - 4 )
        local wearEquip = slotId <= 4 and G_Me.formationData:getFightEquipmentList( slotId ) or 
        				G_Me.formationData:getFightTreasureList(slotId - 4)

        for key, value in pairs(equipList) do 
            if value and not wearEquip[value["id"]] then
            	if slotId <= 4 then 
            		local baseInfo = equipment_info.get(value["base_id"]) or nil 
                	if baseInfo and baseInfo.quality > baseQuality then 
                    	return true
                	end
            	else
            		local baseInfo = treasure_info.get(value["base_id"]) or nil 
                	if baseInfo and baseInfo.quality > baseQuality then 
                    	return true
                	end
            	end                
            end
        end
	end

	local flag = false
	for loopi = startSlot, 4, 1 do 
		flag = flag or checkEquipBySlot(loopi)
	end

	local funLevelConst = require("app.const.FunctionLevelConst")
	local unlockTreasure = G_moduleUnlock:isModuleUnlock(funLevelConst.TREASURE_COMPOSE)
	if unlockTreasure then
		flag = flag or checkEquipBySlot(5)
		flag = flag or checkEquipBySlot(6)
	end

	if startSlot > 1 and not flag then 
		for loopi = 1, startSlot - 1, 1 do 
			flag = flag or checkEquipBySlot(loopi)
		end
	end

	local unlockPet = G_moduleUnlock:isModuleUnlock(funLevelConst.PET_PROTECT1)
	if unlockPet then
		flag = flag or self:checkPetProtectRedDot()
	end

	return flag
end

function FormationData:addFightEquipment( teamId, posId, slotId, equipId )
	if slotId == nil then
		return 
	end
	
	local pos = teamId == 1 and posId or posId + 6
	if self._fightEquipments[pos] == nil then
		self._fightEquipments[pos] = {		["slot_1"] = 0, 
		["slot_2"] = 0,
		["slot_3"] = 0, 
		["slot_4"] = 0,
		}
	end

	self._fightEquipments[pos]["slot_"..slotId] = equipId

	G_Me.bagData:sortEquipmentList()

	self:_calcFightEquipQuality(false, false, slotId)
end

function FormationData:clearFightEquipment( teamId, posId, slotId  )
	if slotId == nil then
		return 
	end

	local pos = teamId == 1 and posId or posId + 6
	if self._fightEquipments[pos] ~= nil then
		self._fightEquipments[pos]["slot_"..slotId] = 0
	end

	G_Me.bagData:sortEquipmentList()

	self:_calcFightEquipQuality(false, false, slotId)
end

function FormationData:resetTreasureFormation( fightTreasures )
	self._fightTreasures = fightTreasures or {}

	G_Me.bagData:sortTreasureList()

	self:_calcFightEquipQuality(false, true)
end

function FormationData:addFightTreasure( teamId, posId, slotId, TreasureId )
	if slotId == nil then
		return 
	end
	
	local pos = teamId == 1 and posId or posId + 6
	if self._fightTreasures[pos] == nil then
		self._fightTreasures[pos] = {["slot_1"] = 0, 
		["slot_2"] = 0}
	end

	self._fightTreasures[pos]["slot_"..slotId] = TreasureId

	G_Me.bagData:sortTreasureList()

	self:_calcFightEquipQuality(false, false, slotId + 4)
end

function FormationData:clearFightTreasure( teamId, posId, slotId  )
	if slotId == nil then
		return 
	end
	
	local pos = teamId == 1 and posId or posId + 6
	if self._fightTreasures[pos] ~= nil then
		self._fightTreasures[pos]["slot_"..slotId] = 0
	end

	G_Me.bagData:sortTreasureList()

	self:_calcFightEquipQuality(false, false, slotId + 4)
end

function FormationData:resetProtectPetFormation(projectPets)

	self._protectPets = projectPets or {}

	G_Me.bagData.petData:sortPetList()
end

function FormationData:addProtectPet(teamId, posId, petId)
	
	if posId == nil or petId == nil then
		return 
	end
	
	local pos = teamId == 1 and posId or posId + 6

	self._protectPets[pos] = petId or 0

	G_Me.bagData.petData:sortPetList()
end

function FormationData:clearProtectPet(teamId, posId, slotId)
	
	if slotId == nil then
		return 
	end
	
	local pos = teamId == 1 and posId or posId + 6

	self._protectPets[pos] = 0

	G_Me.bagData.petData:sortPetList()
end

function FormationData:getProtectPetIdByPos(pos)

	if pos == nil then
		return
	end

	local id = self._protectPets[pos] or 0
	return id
end

-- 统计已上阵战宠的数量
function FormationData:getProtectPetCount()
	local count = 0
	for k, v in pairs(self._protectPets) do
		if v > 0 then
			count = count + 1
		end
	end
	return count
end

-- 这个宠物是否在护佑武将
function FormationData:isProtectPetByPetId(petId)

	for k, v in pairs(self._protectPets) do
		if v == petId then
			return true
		end
	end
	return false
end

-- 是否有同名宠物在护佑武将
function FormationData:isSampleNameProtectPetByPetId(petId)

	local petInfo = G_Me.bagData.petData:getPetById(petId)
	if not petInfo then
		return false
	end
	local baseInfo = pet_info.get(petInfo.base_id)
	if not baseInfo then
		return false
	end 

	for k, v in pairs(self._protectPets) do

		if v > 0 then
			local petProtectInfo = G_Me.bagData.petData:getPetById(v)
			if petProtectInfo then
				local protectBaseInfo = pet_info.get(petProtectInfo.base_id)
				if protectBaseInfo then
					if baseInfo.advanced_id == protectBaseInfo.advanced_id then
						return true
					end
				end
			end
		end
	end

	return false

end

-- 是否有同名宠物在护佑武将(除去某个位置)
function FormationData:isSampleNameProtectPetByPetIdExclusivePosId(petId, posId)

	local petInfo = G_Me.bagData.petData:getPetById(petId)
	if not petInfo then
		return false
	end
	local baseInfo = pet_info.get(petInfo.base_id)
	if not baseInfo then
		return false
	end 

	for k, v in pairs(self._protectPets) do

		if v > 0 and k ~= posId then
			local petProtectInfo = G_Me.bagData.petData:getPetById(v)
			if petProtectInfo then
				local protectBaseInfo = pet_info.get(petProtectInfo.base_id)
				if protectBaseInfo then
					if baseInfo.advanced_id == protectBaseInfo.advanced_id then
						return true
					end
				end
			end
		end
	end

	return false

end

function FormationData:canShangZhenProtectPet()
	local protectCount = G_Me.formationData:getProtectPetCount()
	
    if protectCount < 6 then
    	if not G_moduleUnlock:isModuleUnlock(funLevelConst["PET_PROTECT" .. (protectCount + 1)]) then
            return false
        else
           	return true
        end
    end
    return false
end

function FormationData:checkPetProtectRedDot()

	local petList = G_Me.bagData.petData:getPetList()

	local canShangZhenProtectPet = self:canShangZhenProtectPet()

	for pos = 1, 6 do
		local baseFightValue = 0
	    local protectPetId = G_Me.formationData:getProtectPetIdByPos(pos)

	    if protectPetId > 0 then

	        local petInfo = G_Me.bagData.petData:getPetById(protectPetId)
	        baseFightValue = petInfo.fight_value or 0
	    end
 
 		if not (protectPetId <= 0 and not canShangZhenProtectPet) then
 			local fightPetId = G_Me.bagData.petData:getFightPetId()
		    for k, v in pairs(petList) do

		        if v.id ~= fightPetId and not G_Me.formationData:isProtectPetByPetId(v.id)
		        	and not G_Me.formationData:isSampleNameProtectPetByPetIdExclusivePosId(v.id, pos) then
		            if v.fight_value > baseFightValue then
		                return true
		            end
		        end
		    end
 		end
	    
	end

    return false
end

function FormationData:getKnightIdBySlot( slotId )
	if slotId and slotId < 1 or slotId > 12 then
			return 0
		elseif slotId > 6 then
			return self._secondTeam[slotId - 6] or 0
		else
			return self._firstTeam[slotId] or 0
		end
end

--通过某个侠客ID 获取他所在阵容team, slot
--如果不在阵容, team =0
-- return team, slot
function FormationData:getTeamSlotByKnightId( knightId )
	--先查阵容A

	local team = self._firstTeam 
	local formation = self._firstFormation

	local index = 1
	while index <= table.getn(formation) do
		local formationId = formation[index]
		if formationId ~= nil and formationId > 0 then
			if team[formationId] ~= nil and team[formationId] == knightId then
				return 1, formationId
			end
		end

		index = index + 1
	end

	--再查阵容B
	team =  self._secondTeam
	formation = self._secondFormation
	index = 1
	while index <= table.getn(formation) do
		local formationId = formation[index]
		if formationId ~= nil and formationId > 0 then
			if team[formationId] ~= nil and team[formationId] == knightId then
				return 2, formationId
			end
		end

		index = index + 1
	end

	return 0, 0
end

function FormationData:getFightEquipmentBySlot( teamId, pos, slot )
	local index = teamId == 2 and (pos + 6) or pos
	local fightEquipments = self._fightEquipments[index] or {}

	return fightEquipments and fightEquipments["slot_"..slot] or 0
end

function FormationData:getFightTreasureBySlot( teamId, pos, slot )
	local index = teamId == 2 and (pos + 6) or pos
	local fightTreasures = self._fightTreasures[index] or {}
	return fightTreasures and fightTreasures["slot_"..slot] or 0
end

function FormationData:getFightEquipByPos( teamId, pos )
	local index = teamId == 2 and (pos + 6) or pos 
	return self._fightEquipments[index] or {}
end

function FormationData:getFightTreasureByPos( teamId, pos )
	local index = teamId == 2 and (pos + 6) or pos 
	return self._fightTreasures[index] or {}
end

function FormationData:isFullEquipForPos( teamId, pos )
	local index = teamId == 2 and (pos + 6) or pos 
	local equips = self._fightEquipments[index] or {}

	for loopi = 1, 4, 1 do 
		local equipId = equips["slot_"..loopi]
		if not equipId or equipId < 1 then 
			return false
		end
	end

	return true
end

function FormationData:isFullTreasureForPos( teamId, pos )
	local index = teamId == 2 and (pos + 6) or pos 
	local equips = self._fightTreasures[index] or {}

	for loopi = 1, 2, 1 do 
		local equipId = equips["slot_"..loopi]
		if not equipId or equipId < 1 then 
			return false
		end
	end

	return true
end

function FormationData:calcTargetLevel( curLevel, typeId )
	curLevel = curLevel or 1
	typeId = typeId or 1

	local lastRecordLevel = 0
	local nextRecordLevel = 0
	local targetId = 0
	for loopi = 1, team_target_info.getLength(), 1 do 
		local record = team_target_info._data[loopi]
		if record and typeId == record[2] then 
			if curLevel >= record[3] then 
				lastRecordLevel = record[3]
				targetId = record[1]%1000
			elseif curLevel < record[3] then 
				nextRecordLevel = record[3]
				return targetId, lastRecordLevel, nextRecordLevel
			end
		end
	end

	return targetId, lastRecordLevel, nextRecordLevel
end

function FormationData:getKnightEquipTarget( isStrength, pos )
	if type(pos) ~= "number" or pos < 1 or pos > 6 then 
		return 0, 0, 0
	end

	local equips = self._fightEquipments[pos] or {}
	local curMinLevel = -1
	local fullEquip = true
	for loopi = 1, 4, 1 do 
		local equipId = equips["slot_"..loopi] or 0
		if equipId < 1 then 
			fullEquip = false
		end
		local equipmentInfo = G_Me.bagData.equipmentList:getItemByKey(equipId)
		if equipmentInfo then 
			if isStrength then 
				if curMinLevel < 0 then 
					curMinLevel = equipmentInfo.level
				elseif equipmentInfo.level < curMinLevel then 
					curMinLevel = equipmentInfo.level
				end
			else
				if curMinLevel < 0 then 
					curMinLevel = equipmentInfo.refining_level
				elseif equipmentInfo.refining_level < curMinLevel then 
					curMinLevel = equipmentInfo.refining_level
				end
			end
		end
	end
	if not fullEquip then 
		return 0, 0, 0
	end

	curMinLevel = curMinLevel < 0 and 0 or curMinLevel
	return self:calcTargetLevel(curMinLevel, isStrength and 1 or 3)
end

function FormationData:getKnightTreasureTarget( isStrength, pos )
	if type(pos) ~= "number" or pos < 1 or pos > 6 then 
		return 0, 0, 0
	end

	if not self:isFullEquipForPos(1, pos) then 
		return 0, 0, 0
	end

	local equips = self._fightTreasures[pos] or {}
	local curMinLevel = -1
	local fullTreasure = true
	for loopi = 1, 2, 1 do 
		local equipId = equips["slot_"..loopi] or 0
		if equipId < 1 then 
			fullTreasure = false
		end
		local equipmentInfo = G_Me.bagData.treasureList:getItemByKey(equipId)
		if equipmentInfo then 
			if isStrength then 
				if curMinLevel < 0 then 
					curMinLevel = equipmentInfo.level
				elseif equipmentInfo.level < curMinLevel then 
					curMinLevel = equipmentInfo.level
				end
			else
				if curMinLevel < 0 then 
					curMinLevel = equipmentInfo.refining_level
				elseif equipmentInfo.refining_level < curMinLevel then 
					curMinLevel = equipmentInfo.refining_level
				end
			end
		end
	end
	if not fullTreasure then 
		return 0, 0, 0
	end

	curMinLevel = curMinLevel < 0 and 0 or curMinLevel
	return self:calcTargetLevel(curMinLevel, isStrength and 2 or 4)
end

--1,强化;2,未知
function FormationData:getKnightFriendTarget( sType )

	if not G_moduleUnlock:isModuleUnlock(require("app.const.FunctionLevelConst").KNIGHT_FRIEND_ZHUWEI) then
		return self:calcTargetLevel(0, 5)
	end

	local curMinLevel = -1
	local fullFriend = true
	for loopi = 1, 6 do 
		local knightId, baseId = self:getTeamKnightIdAndBaseIdByIndex(2, loopi)
		if knightId < 1 then 
			fullFriend = false
		end
		require("app.cfg.knight_info")
		local info = knight_info.get(baseId)
		if info and info.quality < 3 then 
			fullFriend = false
		end
		local knightInfo = G_Me.bagData.knightsData:getKnightByKnightId( knightId )
		if knightInfo then 
			if sType == 1 then 
				if curMinLevel < 0 then 
					curMinLevel = knightInfo.level
				elseif knightInfo.level < curMinLevel then 
					curMinLevel = knightInfo.level
				end
			else

			end
		end
	end
	if not fullFriend then 
		return self:calcTargetLevel(0, 5)
	end

	curMinLevel = curMinLevel < 0 and 0 or curMinLevel
	return self:calcTargetLevel(curMinLevel, 5)
end

function FormationData:getAllFightEquipmentList(  )
	local list = {}
	for key, value in pairs(self._fightEquipments) do
		if value["slot_1"] > 0 then
			list[value["slot_1"]] = self:getKnightIdBySlot(key)
		end

		if value["slot_2"] > 0 then
			list[value["slot_2"]] = self:getKnightIdBySlot(key)
		end

		if value["slot_3"] > 0 then
			list[value["slot_3"]] = self:getKnightIdBySlot(key)
		end

		if value["slot_4"] > 0 then
			list[value["slot_4"]] = self:getKnightIdBySlot(key)
		end
	end

	return list
end

function FormationData:getAllFightTreasureList( ... )
	local list = {}

	for key, value in pairs(self._fightTreasures) do
		if value["slot_1"] > 0 then
			list[value["slot_1"]] = self:getKnightIdBySlot(key)
		end

		if value["slot_2"] > 0 then
			list[value["slot_2"]] = self:getKnightIdBySlot(key)
		end
	end

	return list
end

function FormationData:getFightEquipmentList( slot )
	local list = {}

	if slot < 1 or slot > 4 then
		return list
	end

	for key, value in pairs(self._fightEquipments) do
		if value["slot_"..slot] > 0 then
			list[value["slot_"..slot]] = self:getKnightIdBySlot(key)
			--table.insert(list, #list + 1, value["slot_"..slot])
		end
	end

	return list
end

function FormationData:getFightTreasureList( slot )
	local list = {}
	if slot < 1 or slot > 2 then
		return list
	end
	
	for key, value in pairs(self._fightTreasures) do
		if value["slot_"..slot] and value["slot_"..slot] > 0 then
			list[value["slot_"..slot]] = self:getKnightIdBySlot(key)
			--table.insert(list, #list + 1, value["slot_"..slot])
		elseif value["slot_"..slot] == nil then
			dump(value)
		end
	end

	return list
end

function FormationData:getWearEquipmentKnightId( equipId )
	local equipInfo = G_Me.bagData.equipmentList:getItemByKey(equipId)
	if not equipInfo then
		return 0, 0
	end

	require("app.cfg.equipment_info")
	local equipBaseInfo = equipment_info.get(equipInfo["base_id"] or 0)
	if not equipBaseInfo then
		return 0, 0
	end

	local slot = equipBaseInfo.type
	for key, value in pairs(self._fightEquipments) do
		if value["slot_"..slot] and value["slot_"..slot] == equipId then
			return self:getKnightIdBySlot(key), key
		end
	end

	return 0, 0
end

function FormationData:getWearTreasureKnightId( treasureId )
	local treasureInfo = G_Me.bagData.treasureList:getItemByKey(treasureId)
	if not treasureInfo then
		return 0, 0
	end

	require("app.cfg.treasure_info")
	local treasureBaseInfo = treasure_info.get(treasureInfo["base_id"] or 0)
	if not treasureBaseInfo then
		return 0, 0
	end

	local slot = treasureBaseInfo.type
	if slot < 1 or slot > 2 then
		return 0, 0
	end

	for key, value in pairs(self._fightTreasures) do
		if value["slot_"..slot] and value["slot_"..slot] == treasureId then
			return self:getKnightIdBySlot(key), key
		end
	end

	return 0, 0
end

function FormationData:hasAwakenEquipForKnightIndex( index )
	local knightId = self:getKnightIdByIndex(1, index)
	if type(knightId) ~= "number" or knightId < 1 then 
		return false
	end

	return G_Me.bagData.knightsData:hasAwakenEquipmentToEquip(knightId)
end

function FormationData:hasAwakenEquipForTeamKnight(  )
	local flag = false

	for loopi = 1, 6 do 
		local knightId = self:getKnightIdByIndex(1, loopi)
		if type(knightId) ~= "number" or knightId < 1 then 
			return flag
		end

		flag = flag or G_Me.bagData.knightsData:hasAwakenEquipmentToEquip(knightId)
	end

	return flag
end

return FormationData
