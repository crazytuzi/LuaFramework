PetManager = {};

-- local _petAttrConfig = {}
-- local _petTitleConfig = {}
-- local _petRateConfig = {}
-- local _allPetSkill = {}
-- local _skillStageConfig = {}
-- local _tempskillConfig = {}
-- local _petExpConfig = {}
-- local _petFateConfig = {}
-- local _petFataData = {}
-- local _petFateRelation = {}
-- local _petIdAndIndex = {}
-- local _petSkillConfig = {}
-- local _petAptitudeConfig = {}
-- local _autoConfrim = false
-- local _allAddSkillByType = {}
-- local _isUpdateSkill = true
-- PetManager.PETS_MAX_COUNT = 60
-- PetManager.MAX_QUALITY = 5
-- PetManager.RANDAPTITUDENEEDITEMID = 500007         -- 宠物资质丹
-- PetManager.RANDAPTITUDENEEDITEMCOUNT = 3
-- PetManager.FormationOpenLevel = {1, 100, 150, 200, 250, 300}
-- PetManager.MaxRefineLevel = 7
-- PetManager.PetSkillMaxLevel = 20
PetManager.MAXPETLEVEL = ConfigManager.GetLevelLimit("partner_level")
PetManager.PetAddExpItemId = {500100, 500101, 500102}
PetManager.MAXSTAR = 10
PetManager.MAXRANK = ConfigManager.GetLevelLimit("partner_advance")
PetManager.MAXFASHIONLEVEL = 4
-- PetManager.PHY_ATTACK_DES = LanguageMgr.Get("Pet/PetManger/PHY_ATTACK_DES")
-- PetManager.MAG_ATTACK_DES = LanguageMgr.Get("Pet/PetManger/MAG_ATTACK_DES")
-- PetManager.PHY_ATTACK_PRO_DES = LanguageMgr.Get("Pet/PetManger/PHY_ATTACK_PRO_DES")
-- PetManager.MAG_ATTACK_PRO_DES = LanguageMgr.Get("Pet/PetManger/MAG_ATTACK_PRO_DES")
-- PetManager.PHY_ATTACK_APTITUDE_DES = LanguageMgr.Get("Pet/PetManger/PHY_ATTACK_APTITUDE_DES")
-- PetManager.MAG_ATTACK_APTITUDE_DES = LanguageMgr.Get("Pet/PetManger/MAG_ATTACK_APTITUDE_DES")
PetManager.MAXDES = LanguageMgr.Get("Pet/PetManger/MAXDES")


local _insert = table.insert
local _sortfunc = table.sort
local _petConfig = nil
local _petLevelUpdaConfig = nil
local _petAdvanceConfig = nil
local _petTransform = nil
local _curUseId = nil
local _currentPet = nil--当前宠物的完整数据 
local _petFashionData = nil -- 所有幻形数据
local _petAdvanceFashionData = nil -- 所有进阶的幻形数据
local _petAdvanceIdAndIndex = nil
local _idAndIndex = nil
local _isUpdatePetFashion = nil
local _allPetFashionAttr = nil
local _effectConfig = nil
require "Core.Info.PetInfo"
require "Core.Info.PetFateInfo"
require "Core.Info.BaseAdvanceAttrInfo"
local PetFashionInfo = require "Core.Info.PetFashionInfo"

require "Core.Module.Pet.PetNotes"

local function _InitPetData(data)
	if(data) then
		
		_currentPet = PetInfo:New(data)
		_isUpdatePetFashion = true
		_petFashionData = {}
		_petAdvanceFashionData = {}
		_idAndIndex = {}
		_petAdvanceIdAndIndex = {}
		_curUseId = data.use_id
		_allPetFashionAttr = BaseAdvanceAttrInfo:New()
		local count = 1
		local count1 = 1
		for k, v in pairs(_petConfig) do
			local item = PetFashionInfo:New(v)			
			item:SetRankLevel(data.star)	
			
			if(v.type == 2) then				
				_idAndIndex[v.id] = count
				_insert(_petFashionData, item)
				count = count + 1
			elseif v.type == 1 then	
				_petAdvanceIdAndIndex[v.id] = count1	
				item:SetActive(math.ceil((data.star + 1) / PetManager.MAXSTAR) >= item:GetActiveLevel())
				_insert(_petAdvanceFashionData, item)	
				count1 = count1 + 1
			end
		end		
		
		_sortfunc(_petAdvanceFashionData, function(a, b)
			return a:GetActiveLevel() < b:GetActiveLevel()
		end)
		
		
		for i, v in ipairs(_petAdvanceFashionData) do
			_petAdvanceIdAndIndex[v:GetId()] = i
		end
		
		if(data.pet_fashion) then
			for k, v in ipairs(data.pet_fashion) do
				_petFashionData[_idAndIndex[v.id]]:SetActive(true)
				_petFashionData[_idAndIndex[v.id]]:UpdateLevel(v.lev)
			end
		end
		
		PetManager.SortPet()
	end
end

function PetManager.Init(data)
	_idAndIndex = nil
	_currentPet = nil
	_petFashionData = nil
	_petAdvanceFashionData = nil
	_curUseId = nil
	_petAdvanceIdAndIndex = nil
	_isUpdatePetFashion = true
	local _configManager = ConfigManager
	_petConfig = _configManager.GetConfig(ConfigManager.CONFIG_PET)
	_petLevelUpdaConfig = _configManager.GetConfig(ConfigManager.CONFIG_PET_LEVELUP)
	_petAdvanceConfig = _configManager.GetConfig(ConfigManager.CONFIG_PET_ADVANCE)
	_petTransform = _configManager.GetConfig(ConfigManager.CONFIG_PET_TRANSFORM)
	_effectConfig = ConfigManager.GetConfig(ConfigManager.CONFIG_PET_EFFECTCONFIG)
	_InitPetData(data)	
end

function PetManager.GetCurrentPetdata()
	return _currentPet
end

function PetManager.GetNextAdvanceFashionData(id)
	local index = _petAdvanceIdAndIndex[id]
	index = index + 1
	return _petAdvanceFashionData[index]
end

function PetManager.GetLastAdvanceFashionData(id)
	local index = _petAdvanceIdAndIndex[id]
	index = index - 1
	return _petAdvanceFashionData[index]
end

function PetManager.GetPetAdvanceFashionDataById(id)
	local index = _petAdvanceIdAndIndex[id]
	if(index ~= nil) then
		return _petAdvanceFashionData[index]
	end
end

function PetManager.GetCurUsePetId()
	return _curUseId
end

function PetManager.SetCurUsePetId(id)
	_curUseId = id
	_currentPet:UpdatePetFasionInfo(id)
end

function PetManager.GetPetUpdateConfig(lv)
	return _petLevelUpdaConfig[lv]
end

function PetManager.GetPetAdvanceConfig(rank)
	return _petAdvanceConfig[rank]
end

--获取幻形数据
function PetManager.GetPetTransformConfig(id, level)
	local index = id .. "_" .. level
	return _petTransform[index]
end

function PetManager.GetPetConfig(id)
	return _petConfig[id]
end

function PetManager.GetPetFashionDataById(id)
	return _petFashionData[_idAndIndex[id]]
end


function PetManager.SetPetFashionActive(id)
	_isUpdatePetFashion = true
	local pet = PetManager.GetPetFashionDataById(id)
	pet:SetActive(true)
	PetManager.SortPet()
end

function PetManager.SetPetFashionLevel(id, lev)
	_isUpdatePetFashion = true
	local pet = PetManager.GetPetFashionDataById(id)
	pet:UpdateLevel(lev)
end

function PetManager.GetAllPetFashionData()
	return _petFashionData
end

function PetManager.AddPet(data)
	if(data and data.errCode == nil) then
		_InitPetData(data)
		PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.PetAdvance)
		
		-- if(type(_currentPetId) == "number") then
		-- 	if(data.pid == _currentPetId) then
		-- 		_currentPetId = data.id
		-- 	end
		-- end
		-- for k, v in ipairs(_petData) do
		-- 	if(v.pid == data.pid) then
		-- 		v:Reset(data)
		-- 		_isAnyPetActive = true
		-- 		ModuleManager.SendNotification(PetNotes.OPEN_PETACTIVEPANEL, v)
		-- 		break
		-- 	end
		-- end
		-- PetManager.SortPet()
	end
	ModuleManager.SendNotification(PetNotes.UPDATE_PETPANEL)
end

function PetManager.SortPet()
	if(_petFashionData == nil) then
		return
	end
	for k, v in ipairs(_petFashionData) do
		v:SetCurNeedItemCount(BackpackDataManager.GetProductTotalNumBySpid(v:GetActiveNeedItemId()),
		BackpackDataManager.GetProductTotalNumBySpid(v:GetFashionNeedItemId()))
	end
	local aPriority = 0
	local bPriority = 0
	local priority = 0
	local curUseId = PetManager.GetCurUsePetId()
	if(_petFashionData and #_petFashionData > 0) then
		_sortfunc(_petFashionData, function(a, b)
			aPriority = a:GetCanActiveBySort() and 100000000 or 0
			bPriority = b:GetCanActiveBySort() and 100000000 or 0
			
			aPriority = aPriority +(a:GetIsActive() and 10000000 or 0)
			bPriority = bPriority +(b:GetIsActive() and 10000000 or 0)
			
			aPriority = aPriority +(a:GetId() == curUseId and 1000000 or 0)
			bPriority = bPriority +(b:GetId() == curUseId and 1000000 or 0)
			aPriority = aPriority +(a:GetCanFashionUpdateBySort() and 100000 or 0)
			bPriority = bPriority +(b:GetCanFashionUpdateBySort() and 100000 or 0)
			
			
			
			aPriority = aPriority + b:GetOrder()
			bPriority = bPriority + a:GetOrder()
			
			-- aPriority = aPriority + a:GetQuality() * 10000
			-- bPriority = bPriority + b:GetQuality() * 10000
			-- aPriority = aPriority + a:GetId()
			-- bPriority = bPriority + b:GetId()
			-- log(tostring(a._active) .. "," .. tostring(a:GetCanActiveBySort()) .. ":" .. tostring(b._active) .. "," .. tostring(b:GetCanActiveBySort()))
			-- log(a:GetCurActiveNeedItemCount() .. "," .. a._activeNeedCount .. ":" .. b:GetCurActiveNeedItemCount() .. "," .. b._activeNeedCount)		
			-- log(a:GetName() .. aPriority .. ":" .. b:GetName() .. bPriority)
			return aPriority - bPriority > 0
		end
		)
	end
	
	_idAndIndex = {}
	for k, v in ipairs(_petFashionData) do
		_idAndIndex[v:GetId()] = k
	end
	
	
end

function PetManager.IsAdvancePetEnough(petData, rank)
	local count = 0
	for k, v in pairs(_petData) do
		if((v.pid == petData.pid) and(v.rank == rank) and(v.id ~= petData.id) and(v.status == 0)) then
			petData = v
			count = count + 1
		end
	end
	
	return count >= petData.needPet.petCount
end

function PetManager.UpdatePetRank(data)
	_currentPet:UpdateRank(data.star, data.adv_exp)
	for i, v in ipairs(_petFashionData) do
		v:SetRankLevel(data.star)
	end	
	
	for i, v in ipairs(_petAdvanceFashionData) do
		v:SetRankLevel(data.star)
		v:SetActive(math.ceil((data.star + 1) / PetManager.MAXSTAR) >= v:GetActiveLevel())		
	end	
	
	PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.PetAdvance)
end

function PetManager.GetPetAdvanceAttr()
	if(_currentPet) then
		return _currentPet:GetRankAttr()
	end
	return nil
end


function PetManager.GetPetFashionAttr()
	
	if(_isUpdatePetFashion) then
		if(_allPetFashionAttr == nil) then
			_allPetFashionAttr = BaseAdvanceAttrInfo:New()
		end
		_allPetFashionAttr:Reset()
		if(_petFashionData) then
			for k, v in pairs(_petFashionData) do
				if(v:GetIsActive()) then
					_allPetFashionAttr:Add(v:GetAttr())
				end
			end
		end
	end
	
	return _allPetFashionAttr
end

function PetManager.UpdatePetLevel(data)
	_currentPet:UpdateLevel(data.lev, data.exp)
end

function PetManager.HasMsg()
	if(not SystemManager.IsOpen(SystemConst.Id.PET)) then
		return false
	end
	
	return PetManager.GetCanUseExpItem() or PetManager.GetCanAdvance() or PetManager.GetFashionMsg()
	
end


function PetManager.GetFashionMsg()	
	if(not SystemManager.IsOpen(SystemConst.Id.PetFashion)) then
		return false
	end
	
	if(_petFashionData) then
		local enable = false
		for k, v in ipairs(_petFashionData) do
			if(v:GetCanActive() or v:GetCanUpdate()) then
				enable = true
				break
			end
		end
		return enable
	end
	return false
end

-- 是否有提升经验的药
function PetManager.CanUpdatePet()
	local count = 0
	for k, v in ipairs(PetManager.PetAddExpItemId) do
		count = count + BackpackDataManager.GetProductTotalNumBySpid(v)
	end
	return count > 0
end

function PetManager.GetCanAdvance()
	if(not SystemManager.IsOpen(SystemConst.Id.PetAdvance)) then
		return false
	end
	
	if(_currentPet) then
		return _currentPet:GetCanUpdateStar()
	end		
	
	return false
end

function PetManager.GetCanUseExpItem()
	if(not SystemManager.IsOpen(SystemConst.Id.PET)) then
		return false
	end
	
	if(_currentPet) then
		return	_currentPet:GetCanUseExpItem()
	end
	return false
end

--计算七天榜的伙伴阵法战斗力
function PetManager.GetDaysRankFormationPower()
	-- local num = 0;
	-- for i, v in ipairs(_petData) do
	-- 	if v:GetIsActive() and v:GetFormationIndex() ~= 0 then
	-- 		--num = num +((v.quality + 1) * v.rank);
	-- 		num = num + v:GetPower();
	-- 	end
	-- end
	-- return num;
	return 0
end

--将星级转化成 等阶和星级
function PetManager.ChangeStarLevToRank(star)
	if(star == PetManager.MAXRANK) then
		return PetManager.MAXRANK, PetManager.MAXSTAR
	end
	
	return math.ceil((star + 1) / PetManager.MAXSTAR), star % PetManager.MAXSTAR
end

--返回自己的等阶
function PetManager.GetMyStarAndRankLevel()
	if(_currentPet) then
		return _currentPet:GetShowStar(), _currentPet:GetRankLevel()
	end
	
	return 0, 0
end

function PetManager.GetEffectConfigById(id)
	return _effectConfig[id]
end

-- function PetManager.GetPetConfigById(id)
-- 	return _petConfig[id]
-- end
-- function PetManager.GetPetDataByPid(id)
-- 	for k, v in ipairs(_petData) do
-- 		if(v.pid == id) then
-- 			return v
-- 		end
-- 	end
-- end
-- function PetManager.GetPetAttrConfigById(id, grade)
-- 	if(grade == 0) then grade = 1 end
-- 	local index = id .. "_" .. grade
-- 	return _petAttrConfig[index]
-- end
-- function PetManager.GetPetTitle(grade)
-- 	return _petTitleConfig[grade]
-- end
-- function PetManager.GetCurrentPetdata()
-- 	if(_currentPet) then		
-- 		if(type(_currentPet.id) == type(_currentPetId) and _currentPet.id == _currentPetId) then
-- 			return _currentPet
-- 		end
-- 	end
-- 	_currentPet = PetManager.GetPetDataByServerId(_currentPetId) 
-- 	return _currentPet
-- end
-- function PetManager.GetPetDataByServerId(id)
-- 	if(_petIdAndIndex[id]) then
-- 		return _petData[_petIdAndIndex[id]]
-- 	end
-- 	for k, v in ipairs(_petData) do
-- 		if(v.id == id) then
-- 			return v
-- 		end
-- 	end
-- 	return nil
-- end
-- function PetManager.GetPetExpConfig(level)
-- 	return _petExpConfig[level]
-- end
-- function PetManager.GetAllPetData(withOutFight)
-- 	--    PetManager.SortPet()
-- 	local result = ConfigManager.Clone(_petData)
-- 	if(withOutFight) then
-- 		local count = table.getCount(result)
-- 		for i = count, 1, - 1 do
-- 			if(result[i].status == 1 or result[i]:GetFormationIndex() ~= 0) then
-- 				table.remove(result, i)
-- 			end
-- 		end
-- 	end
-- 	return result
-- end
-- function PetManager.GetPetsByQc(qc, withoutFight)
-- 	local result = {}
-- 	local resolveItemCount = 0
-- 	for k, v in pairs(_petData) do
-- 		if(v.quality <= qc) then
-- 			if(withoutFight) then
-- 				if(v.status ~= 1) then
-- 					insert(result, v.id)
-- 					resolveItemCount = resolveItemCount + v.resolveItemNum
-- 				end
-- 			else
-- 				insert(result, v.id)
-- 				resolveItemCount = resolveItemCount + v.resolveItemNum
-- 			end
-- 		end
-- 	end
-- 	return result, resolveItemCount
-- end
-- function PetManager.GetPetsCount()
-- 	return table.getCount(_petData)
-- end
-- function PetManager.GetPetsCountDes()
-- 	local count = table.getCount(_petData)
-- 	if count >= PetManager.PETS_MAX_COUNT then
-- 		return "[ff0000]" .. count .. "/" .. PetManager.PETS_MAX_COUNT .. "[-]"
-- 	else
-- 		return "[00ff00]" .. count .. "/" .. PetManager.PETS_MAX_COUNT .. "[-]"
-- 	end
-- end
-- function PetManager.SetStatus(id, status)
-- 	_fightingPet = nil
-- 	for k, v in ipairs(_petData) do
-- 		if v.id == id then
-- 			v.status = status
-- 			if(status == 1) then
-- 				_fightingPet = v
-- 			end
-- 		else
-- 			v.status = 0
-- 		end
-- 	end
-- 	PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Pet)
-- 	ModuleManager.SendNotification(PetNotes.UPDATE_PETPANEL)
-- end
-- function PetManager.SetCurrentPet(id)
-- 	_currentPetId = id
-- 	ModuleManager.SendNotification(PetNotes.UPDATE_PETPANEL)
-- end
-- local skill1 = LanguageMgr.Get("Pet/PetManger/petSkill1")
-- local skill2 = LanguageMgr.Get("Pet/PetManger/petSkill2")
-- --2主动,3被动
-- function PetManager.GetSkillTypeDes(skillType)
-- 	if skillType == 2 then
-- 		return skill1
-- 	elseif skillType == 3 then
-- 		return skill2
-- 	else
-- 		log("不在计算范围内" .. skillType)
-- 	end
-- end
-- function PetManager.GetUnlockSkillTypeDes(skillType)
--    if skillType == 2 then
--        return "主动技能"
--    elseif skillType == 3 then
--        return "被动技能"
--    else
--        log("不在计算范围内" .. skillType)
--    end
-- end
-- local change = LanguageMgr.Get("Pet/PetManger/change")
-- local equip = LanguageMgr.Get("Pet/PetManger/equip")
-- function PetManager.GetTitleDes(titleType)
-- 	if(titleType == 1) then
-- 		return change
-- 	elseif titleType == 2 then
-- 		return equip
-- 	end
-- 	return ""
-- end
-- function PetManager.MotifyName(id, name, cTime)
-- 	local petData = PetManager.GetPetDataByServerId(id)
-- 	if(petData) then
-- 		petData.c_time = cTime
-- 		petData.name = name
-- 		local currentPetdata = PetManager.GetCurrentPetdata()
-- 		if(currentPetdata.id == id) then
-- 			ModuleManager.SendNotification(PetNotes.CLOSE_PETMOTIFYNAMEPANEL)
-- 			ModuleManager.SendNotification(PetNotes.UPDATE_PETPANEL_NAME, name)
-- 		end
-- 	end
-- end
-- function PetManager.ResetCurrentPetId()
-- 	if(table.getCount(_petData) > 0) then
-- 		_currentPetId = _petData[1].id
-- 	end
-- end
-- function PetManager.GetCurrentPetId()
-- 	return _currentPetId
-- end
-- function PetManager.GetBuffInfo(id, level)
-- 	level = level or 1
-- 	if(PetManager._buffCfg == nil) then
-- 		PetManager._buffCfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_BUFF);
-- 	end
-- 	if(PetManager._buffCfg) then
-- 		return PetManager._buffCfg[id .. "_" .. level];
-- 	end
-- 	return nil;
-- end
-- function PetManager.ResetPetSkill(data)
-- 	if(data) then
-- 		-- k:服务器数据下标 v:数据
-- 		for k, v in ipairs(data) do
-- 			if(_allPetSkill[v.id] ~= nil) then
-- 				-- 先找出该技能是否在之前的宠物中使用到
-- 				-- k1:下标 v1宠物数据
-- 				local pet = PetManager.GetPetDataByServerId(_allPetSkill[v.id].petId)
-- 				if(pet) then
-- 					pet:SetSkillInfoBySId(v.id)
-- 				end 
-- 				if(v.idx == - 1) then
-- 					_allPetSkill[v.id].petId = "-1"
-- 					_allPetSkill[v.id]:SetIndex(tonumber(v.idx))
-- 				else
-- 					_allPetSkill[v.id].petId = v.petId
-- 					_allPetSkill[v.id]:SetIndex(v.idx)
-- 					-- k1:下标 v1宠物数据
-- 					local pet = PetManager.GetPetDataByServerId(v.petId)
-- 					if(pet) then
-- 						local skillInfo = PetManager.GetPetSkillByServerId(v.id)
-- 						pet:SetSkillInfoByIndex(v.idx, skillInfo)
-- 					end 
-- 				end
-- 			end
-- 		end
-- 	end
-- end
-- -- 获取升级技能材料
-- -- id 对应技能表中的id, isInnate 是否天生技能
-- function PetManager.GetUpdateSkillMaterials(id, isInnate, maxCount)
-- 	maxCount = maxCount or 1
-- 	local skill = {}
-- 	local count = 0
-- 	if(isInnate) then
-- 		for k, v in pairs(_allPetSkill) do
-- 			if(v.petId == "-1") then
-- 				count = count + 1
-- 				skill[count] = {}
-- 				setmetatable(skill[count], {__index = v})
-- 				if(count >= maxCount) then
-- 					break
-- 				end
-- 			end
-- 		end
-- 	else
-- 		for k, v in pairs(_allPetSkill) do
-- 			if(v.id == id and v.petId == "-1") then
-- 				count = count + 1
-- 				skill[count] = {}
-- 				setmetatable(skill[count], {__index = v})
-- 				if(count >= maxCount) then
-- 					break
-- 				end
-- 			end
-- 		end
-- 	end
-- 	return skill
-- end
-- -- 获取符合条件的宠物数据和数量
-- function PetManager.GetPetCount(id, rank)
-- 	local count = 0
-- 	local petData = PetManager.GetPetConfigById(id)
-- 	for k, v in pairs(_petData) do
-- 		if((v.pid == id) and(v.rank == rank) and(v.id ~= _currentPetId) and(v.status == 0)) then
-- 			count = count + 1
-- 		end
-- 	end
-- 	return petData, count
-- end
-- -- 是否按列表顺序
-- function PetManager.GetFormationPets(isArray)
-- 	isArray = isArray or false
-- 	local petList = {}
-- 	for k, v in pairs(_petData) do
-- 		if(v:GetFormationIndex() ~= 0 and v:GetIsActive()) then
-- 			if(isArray) then
-- 				insert(petList, v)
-- 			else
-- 				petList[v:GetFormationIndex()] = v
-- 			end
-- 		end
-- 	end
-- 	return petList
-- end
-- function PetManager.GetFormationPetIdList()
-- 	local petList = {}
-- 	for k, v in pairs(_petData) do
-- 		if(v:GetFormationIndex() ~= 0 and v:GetIsActive()) then
-- 			insert(petList, v.petBaseData.id)
-- 		end
-- 	end
-- 	return petList
-- end
-- -- 是否显示上阵伙伴
-- function PetManager.GetAllPetWithoutSame(isHide)
-- 	local pets = {}
-- 	local count = 1
-- 	if(isHide) then
-- 		for k, v in pairs(_petData) do
-- 			if(v:GetIsActive() and v:GetFormationIndex() == 0) then
-- 				pets[count] = v
-- 				count = count + 1
-- 			end
-- 		end
-- 	else
-- 		for k, v in pairs(_petData) do
-- 			if(v:GetIsActive()) then
-- 				pets[count] = v
-- 				count = count + 1
-- 			end
-- 		end
-- 	end
-- 	return pets
-- end
-- function PetManager.GetFormationPetProperty()
-- 	local pets = PetManager.GetFormationPets()
-- 	local attr = BaseAdvanceAttrInfo:New()
-- 	if(pets) then
-- 		for k, v in pairs(pets) do
-- 			if(v.petFormationAttr) then
-- 				attr:Add(v.petFormationAttr)
-- 			end
-- 		end
-- 	end
-- 	for k, v in ipairs(_petFataData) do
-- 		if(v:GetValid()) then
-- 			attr:Add(v:GetAttr())
-- 		end
-- 	end
-- 	return attr
-- end
-- function PetManager.GetFormationPetPropertyDes()
-- 	local attr = PetManager.GetFormationPetProperty()
-- 	return attr:GetAllPropertyAndDes()
-- end
-- function PetManager.HasPet()
-- 	for k, v in ipairs(_petData) do
-- 		if(v:GetIsActive() and v.status == 0) then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end
-- function PetManager.IsPetFighting() 
-- 	return _fightingPet ~= nil
-- end
-- function PetManager.GetFightingPet()
-- 	return _fightingPet
-- end
-- function PetManager.GetMaxPetPower()
-- 	local result = 0
-- 	for k, v in ipairs(_petData) do
-- 		local power = v:GetPower()
-- 		if(power > result) then
-- 			result = power
-- 		end
-- 	end
-- 	return result
-- end
-- -- 是否能上阵
-- function PetManager.GetCanInFormation(index) 
-- 	if(not SystemManager.IsOpen(SystemConst.Id.PetFormation)) then
-- 		return false
-- 	end 
-- 	index = index or 0
-- 	local heroLevel = HeroController:GetInstance().info.level 
-- 	--阵位還未開啓
-- 	if(index ~= 0 and heroLevel < PetManager.FormationOpenLevel[index]) then
-- 		return false
-- 	end
-- 	if(table.getCount(_petData) == 0) then return false end
-- 	local count = 0
-- 	local informationPet = {} 
-- 	for k, v in ipairs(_petData) do
-- 		if(v:GetFormationIndex() ~= 0 and v:GetIsActive()) then
-- 			insert(informationPet, v)
-- 		end
-- 	end
-- 	local count = 1
-- 	for i = 6, 1, - 1 do
-- 		if(heroLevel >= PetManager.FormationOpenLevel[i]) then
-- 			count = i
-- 			break
-- 		end
-- 	end
-- 	if(table.getCount(informationPet) == count) then
-- 		return false
-- 	end
-- 	local isNotIn = true
-- 	for k, v in ipairs(_petData) do
-- 		-- 不在阵法上
-- 		if(v:GetFormationIndex() == 0 and v:GetIsActive()) then
-- 			for k1, v1 in ipairs(informationPet) do
-- 				if(v1.pid == v.pid) then
-- 					isNotIn = false
-- 				end
-- 			end
-- 			if(isNotIn) then
-- 				return true
-- 			end
-- 		end
-- 	end 
-- 	return false
-- end 
-- function PetManager.GetCanRandonAptitude()
-- 	-- if(_isAnyPetActive) then
-- 	-- 	for k, v in ipairs(_petData) do
-- 	-- 		if(v:GetIsActive()) then
-- 	-- 			if(_fightingPet and _fightingPet.id == v.id) then
-- 	-- 				break
-- 	-- 			end
-- 	-- 		end
-- 	-- 	end
-- 	-- end
-- 	if(not SystemManager.IsOpen(SystemConst.Id.PET)) then
-- 		return false
-- 	end
-- 	local canRefine = false
-- 	if(_isAnyPetActive) then		
-- 		for k, v in ipairs(_petData) do
-- 			if(v:GetCanRandonAptitude()) then
-- 				canRefine = true
-- 				break
-- 			end
-- 		end
-- 	end
-- 	return _isAnyPetActive and(_fightingPet ~= nil) and canRefine
-- end
-- function PetManager.CanSkillUpdate()
-- 	if(not SystemManager.IsOpen(SystemConst.Id.PetSkill)) then
-- 		return false
-- 	end
-- 	if(_fightingPet == nil) then
-- 		return false
-- 	end
-- 	for k, v in ipairs(_petData) do
-- 		if(v:CanSkillUpdate()) then
-- 			return true
-- 		end
-- 	end 
-- 	return false
-- end
-- function PetManager.CanSkillActive()
-- 	if(not SystemManager.IsOpen(SystemConst.Id.PetSkill)) then
-- 		return false
-- 	end
-- 	for k,v in pairs(_allPetSkill) do
-- 		if(v:CanActive()) then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end
-- function PetManager.ResetPetFormation(idx)
-- 	for k, v in ipairs(_petData) do
-- 		if(v:GetFormationIndex() == idx) then
-- 			v:SetFormationIndex(0)
-- 			break
-- 		end
-- 	end
-- end
-- function PetManager.GetAptitudeConfigByLev(lev)
-- 	return _petAptitudeConfig[lev]
-- end
-- function PetManager.GetAutoConfirm()
-- 	return _autoConfrim
-- end
-- function PetManager.SetAutoConfirm(v)
-- 	_autoConfrim = v
-- end
-- function PetManager.ResetSkillUpdateState()
-- 	_isUpdateSkill = true
-- end
-- pet_sill：{id:id，，skill_id:技能ID，pet_id：使用技能的宠物ID （为空时，没有使用），exp：经验，level：等级，idx：下标}
-- function PetManager.UpdatePetSkill(data)
-- 	_isUpdateSkill = true
-- 	local newSkill = PetSkillInfo:New(data.skill_id, data.level, data.exp, data.id, data.petId)
-- 	if(_allPetSkill[data.id] ~= nil) then
-- 		_allPetSkill[data.id] = newSkill
-- 	end
-- 	local petData = PetManager.GetPetDataByServerId(data.petId)
-- 	petData:SetSkillInfoBySId(data.id, newSkill)
-- 	-- for k, v in pairs(_petData) do
-- 	-- 	if(v.id == data.petId) then
-- 	-- 		_petData[k]:SetSkillInfoBySId(data.id, newSkill)
-- 	-- 		break
-- 	-- 	end
-- 	-- end
-- 	return newSkill
-- end
-- function PetManager.RemovePetSkill(data)
-- 	local index = 0
-- 	if(data) then
-- 		for k, v in ipairs(data) do
-- 			if(_allPetSkill[v] ~= nil) then
-- 				_allPetSkill[v] = nil
-- 			end
-- 		end
-- 	end
-- end
-- function PetManager.GetPetSkillByServerId(id)
-- 	-- return ConfigManager.Clone(_allPetSkill[id])
-- 	return _allPetSkill[id]
-- end
--类型为空的时候返回整个技能列表 不需要排序
--skillType 2为主动 3为被动
-- function PetManager.GetPetAllAddSkill(skillType)
-- 	if(skillType == nil) then
-- 		return _allPetSkill
-- 	end
-- 	if(_isUpdateSkill) then
-- 		_isUpdateSkill = false
-- 		local count = 1
-- 		local allAddSkill = {}
-- 		_allAddSkillByType = {}
-- 		_allAddSkillByType[PetSkillType.Active] = {}
-- 		_allAddSkillByType[PetSkillType.Passive] = {}
-- 		for k, v in pairs(_allPetSkill) do 
-- 			local item  = {}
-- 			setmetatable(item, {__index = v})
-- 			if(v.skill_type == PetSkillType.Active) then
-- 			 	insert(_allAddSkillByType[PetSkillType.Active],item)				
-- 			elseif v.skill_type == PetSkillType.Passive then
-- 				insert(_allAddSkillByType[PetSkillType.Passive],item)				
-- 			end 
-- 		end
-- 		if(#_allAddSkillByType[PetSkillType.Active] > 1) then
-- 			table.sort(_allAddSkillByType[PetSkillType.Active], function(a, b)
-- 				local p = 0
-- 				p =(a:GetIsActive() and 100000 or 0) -(b:GetIsActive() and 100000 or 0) + a.id - b.id
-- 				return p >	0
-- 			end)
-- 		end
-- 		if(#_allAddSkillByType[PetSkillType.Passive] > 1) then
-- 			table.sort(_allAddSkillByType[PetSkillType.Passive], function(a, b)
-- 				local p = 0
-- 				p =(a:GetIsActive() and 100000 or 0) -(b:GetIsActive() and 100000 or 0) + a.id - b.id
-- 				return p >	0
-- 			end)
-- 		end
-- 	end
-- 	return _allAddSkillByType[skillType]
-- end
--这个是区分类型的
-- function PetManager.GetCanSkillActiveByType(skillType) 
-- 	local skills =  PetManager.GetPetAllAddSkill(skillType)
-- 	for k,v in  pairs( skills) do
-- 		if(v:CanActive()) then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end
-- function PetManager.InitPetFate()
-- 	_petFataData = {}
-- 	_petFateRelation = {}
-- 	local count = 1
-- 	for k, v in ipairs(_petFateConfig) do
-- 		v = ConfigManager.TransformConfig(v)
-- 		_petFataData[v.id] = PetFateInfo.New(v)
-- 		local petList = _petFataData[v.id]:GetPetList()
-- 		for k1, v1 in ipairs(petList) do
-- 			if(_petFateRelation[v1] == nil) then
-- 				_petFateRelation[v1] = {}
-- 			end
-- 			table.insert(_petFateRelation[v1], _petFataData[v.id])
-- 		end
-- 		count = count + 1
-- 	end
-- end
-- --根据宠物id返回宠物相关情缘
-- function PetManager.GetPetFateByPetId(id)
-- 	return _petFateRelation[id] or {}
-- end
-- --获取所有情缘
-- function PetManager.GetAllPetFate()
-- 	local petFateList = {}
-- 	for k, v in ipairs(_petFataData) do
-- 		if(v:GetValid()) then
-- 			table.insert(petFateList, v)
-- 		end
-- 	end
-- 	return petFateList
-- end
-- --根据id判断情缘是否符合
-- function PetManager.GetPetFateIsValidById(id)
-- 	if(_petFataData[id]) then
-- 		return _petFataData[id]:GetValid()
-- 	end
-- 	log("找不到id" .. id)
-- 	return false
-- end
--设置所有宠物情缘的情况
-- function PetManager.SetAllPetFate()
-- 	local allFormationPet = PetManager.GetFormationPetIdList()
-- 	local petList = {}
-- 	local count = 0
-- 	local all = 0
-- 	if(table.getCount(allFormationPet) > 0) then
-- 		for k, v in ipairs(_petFataData) do
-- 			count = 0
-- 			petList = v:GetPetList()
-- 			all = table.getCount(petList)
-- 			for k1, v1 in ipairs(petList) do
-- 				if(table.contains(allFormationPet, v1)) then
-- 					count = count + 1
-- 				end
-- 			end
-- 			--设置情缘是否有效	
-- 			v:SetValid(count == all)
-- 		end
-- 	end
-- end
-- function PetManager.GetPetRateData()
-- 	return _petFataData
-- end
-- function PetManager.RemovePet(data)
-- 	local index = 0
-- 	if(data) then
-- 		for k, v in pairs(_petData) do
-- 			if(v.id == data.id) then
-- 				index = k
-- 				break
-- 			end
-- 		end
-- 	end
-- 	if(index > 0) then
-- 		table.remove(_petData, index)
-- 	end
-- 	if(_currentPetId == data.id) then
-- 		_currentPetId = "0"
-- 	end
-- 	PetManager.SortPet()
-- 	ModuleManager.SendNotification(PetNotes.UPDATE_PETPANEL)
-- end
-- function PetManager.RemovePetByList(data)
-- 	for k, v in ipairs(data) do
-- 		for k1, v1 in ipairs(_petData) do
-- 			if(v1.id == v) then
-- 				if _currentPetId == v then
-- 					_currentPetId = "0"
-- 				end
-- 				table.remove(_petData, k1)
-- 				break
-- 			end
-- 		end
-- 	end
-- 	PetManager.SortPet()
-- end
-- function PetManager.InitPetSkillData(skillData)
-- 	_allPetSkill = {}
-- 	if(skillData) then
-- 		local containSkill = {}
-- 		for k, v in ipairs(skillData) do
-- 			if(_allPetSkill[v.id] == nil) then
-- 				_allPetSkill[v.id] = {}
-- 				_allPetSkill[v.id] = PetSkillInfo:New(v.skill_id, v.level, v.exp, v.id, v.petId)
-- 				_allPetSkill[v.id]:SetIndex(v.idx)
-- 				insert(containSkill, v.skill_id)
-- 			else
-- 				log("宠物技能重复" .. v.id)
-- 			end
-- 		end
-- 		for k, v in pairs(_petSkillConfig) do
-- 			if(not table.contains(containSkill, v.id)) then
-- 				_allPetSkill[v.id] = {}
-- 				_allPetSkill[v.id] = PetSkillInfo:New(v.id, 1, 0)
-- 				_allPetSkill[v.id]:SetIndex(- 1)
-- 			end
-- 		end
-- 	end
-- end
-- function PetManager.GetPetSkillConfigById( id )
-- 	return _petSkillConfig[id]
-- end
-- function PetManager.AddNewPetSkill(data)
-- 	if(data and data.errCode == nil) then		
-- 		_isUpdateSkill = true
-- 		_allPetSkill[data.skill_id] = nil		
-- 		if(_allPetSkill[data.id] == nil) then
-- 			_allPetSkill[data.id] = {}
-- 			_allPetSkill[data.id] = PetSkillInfo:New(data.skill_id, data.level, data.exp, data.id, data.petId)
-- 			_allPetSkill[data.id]:SetIndex(data.idx)
-- 			MsgUtils.ShowTips("Pet/PetManger/getNewSkill", {name = _allPetSkill[data.id].name})
-- 		else
-- 			log("已经有此技能")
-- 		end
-- 	end
-- end
