require("app.cfg.pet_info")
require("app.cfg.pet_star_info")
require("app.cfg.pet_addition_info")
require("app.cfg.pet_compose_info")

local PetData = class("PetData")

-- Pet的数据结构
--[[
	Pet = {
		id,
		base_id,
		level,
		exp,
		mood,
		addition_exp,
		addition_lvl,
		fight_value,
	}
]]

function PetData:ctor()
	self:_init()
end

function PetData:_init( ... )
	-- 战宠列表
	self._tPetList = {}
	self._tPetIndexList = {}
	self._tPetHandBookIds = {} -- 图鉴列表
	-- 上阵宠物id
	self._nFightPetId = 0
end

-- 上阵宠物的id
function PetData:storeFightPetId(nId)
	self._nFightPetId = nId --nId or 0
	self:sortPetList()
end

-- 获取上阵的宠物的id
function PetData:getFightPetId()
	return self._nFightPetId
end

-- 获取上阵的宠物
function PetData:getFightPet()
	local tPet = self._tPetList[self._nFightPetId]
	return tPet
end

-- 存储宠物列表
function PetData:storePetList(data)
	if not data then
		return
	end

	for i, value in ipairs(data) do
		if type(value) == "table" and value["id"] ~= nil then
			local tPet = value
			self._tPetList[tPet["id"]] = tPet
			self._tPetIndexList[i] = tPet["id"]
		end
	end

	self:sortPetList()
end

-- 加入一个新的宠物到列表中
function PetData:addPetToList(tPet)
	if not tPet then
		return
	end

	self._tPetList[tPet["id"]] = tPet
	self._tPetIndexList[#self._tPetIndexList+1] = tPet["id"]

	self:sortPetList()
end

-- 更新一个战宠
function PetData:updatePet(tPet)
	if not tPet then
		return
	end
	for k , v in pairs(tPet) do 
		self._tPetList[tPet["id"]][k] = v
	end
	-- self._tPetList[tPet["id"]] = tPet

	self:sortPetList()
end

-- 删除一个战宠
function PetData:removePetById(nId)
	if type(nId) ~= "number" then
		return
	end
	for i, v in ipairs(self._tPetIndexList) do
		local nPetId = v
		if nPetId == nId then
			self._tPetList[nPetId] = nil
			table.remove(self._tPetIndexList, i) 
		end
	end
end

-- 获取一个宠物的id, 通过index
function PetData:getPetIdByIndex(nIndex)
	if type(nIndex) ~= "number" then
		return nil
	end
	return self._tPetIndexList[nIndex]
end

-- 通过index,获取一个宠物
function PetData:getPetByIndex(nIndex)
	if type(nIndex) ~= "number" then
		return nil
	end
	local tPet = nil
	local nPetId = self._tPetIndexList[nIndex]
	if nPetId then
		tPet = self._tPetList[nPetId]
	end
	return tPet
end

function PetData:getPetByIndexExceptFightOne(nIndex)
	local tList = {}
	for i, val in ipairs(self._tPetIndexList) do
		local nPetId = val
		if nPetId ~= self._nFightPetId then
			table.insert(tList, #tList + 1, nPetId)
		end
	end

	local tPet = nil
	if #tList > 0 then
		local nPetId = tList[nIndex]
		if nPetId then
			tPet = self._tPetList[nPetId]
		end
	end

	return tPet
end

function PetData:getPetCountExceptFightOne()
	local tList = {}
	self:sortPetList()
	for i, val in ipairs(self._tPetIndexList) do
		local nPetId = val
		if nPetId ~= self._nFightPetId then
			table.insert(tList, #tList + 1, nPetId)
		end
	end

	return #tList
end

-- 战宠排序
function PetData:sortPetList()
	local function sortFunc(nPetId1, nPetId2)
		local nFightPetId = self:getFightPetId()
		if nPetId1 == nFightPetId then
			return true
		end
		if nPetId2 == nFightPetId then
			return false
		end

		-- 是否护佑
		local flag1 = G_Me.formationData:isProtectPetByPetId(nPetId1)
		local flag2 = G_Me.formationData:isProtectPetByPetId(nPetId2)
		if flag1 ~= flag2 then
			return flag1
		end

		local tPet1 = self:getPetById(nPetId1)
		local tPet2 = self:getPetById(nPetId2)

		local tPetTmpl1 = pet_info.get(tPet1["base_id"])
		local tPetTmpl2 = pet_info.get(tPet2["base_id"])

		-- 战力
		if tPet1.fight_value ~= tPet2.fight_value then
			return tPet1.fight_value > tPet2.fight_value
		end
		-- 品质
		if tPetTmpl1.quality ~= tPetTmpl2.quality then
			return tPetTmpl1.quality > tPetTmpl2.quality
		end
		-- 模板id
		return tPetTmpl1.id < tPetTmpl2.id
	end

	table.sort(self._tPetIndexList or {}, sortFunc)
end

-- 获取战宠列表
function PetData:getPetList()
	return self._tPetList
end

-- nId指存储在服务器中的id
function PetData:getPetById(nId)
	local tPet = nil
	for key, val in pairs(self._tPetList) do
		if val["id"] == nId then
			tPet = val
		end
	end
	return tPet
end

-- 获取一个Pet的base_id
function PetData:getPetBaseIdById(nId)
	local nBaseId = nil
	local tPet = self:getPetById(nId)
	if not tPet then
		nBaseId = tPet["base_id"]
	end
	return nBaseId
end

-- 获取包裹里战宠的数量
function PetData:getPetCount()
--	return table.nums(self._tPetList)
	local nCount = 0
	for key, val in pairs(self._tPetList) do
		nCount = nCount + 1
	end
	return nCount
end

-- 战宠能不能强化与当前的强化等级
function PetData:couldStrength(pet)
	if not pet then
		return false
	end

	local isUnlock = false
	local couldStrength = pet.level < self:getMaxStrengthLevel()

	return couldStrength and not isUnlock
end

-- 战宠能不能升星与当前的星级
function PetData:couldUpStar(pet)
	if not pet then
		return false
	end

	local isUnlock = false
	local couldUpStar = false
	local star = 0
	local nBaseId = pet["base_id"]
	if type(nBaseId) == "number" and nBaseId > 0 then
		local tPetTmpl = pet_info.get(nBaseId)
		if tPetTmpl then
			couldUpStar = tPetTmpl.star < self:getMaxStarLevel()
		end
	end
	return couldUpStar and not isUnlock
end

-- 战宠能不能神炼与当前的神炼等级
function PetData:couldRefine(pet)
	if not pet then
		return false
	end

	if pet.addition_lvl >= self:getMaxRefineLevel() then
		return false
	end

	local isUnlock = false
	local info = pet_info.get(pet.base_id)
	local addInfo = pet_addition_info.get(info.addition_id,pet.addition_lvl)
	local couldRefine = not addInfo or pet.level >= addInfo.level_ban
	return couldRefine and not isUnlock
end

function PetData:getCanRefineLevel(pet)
	if not pet then
		return 0
	end

	if pet.addition_lvl >= self:getMaxRefineLevel() then
		return self:getMaxRefineLevel()
	end

	local level = pet.addition_lvl
	local isUnlock = false
	local info = pet_info.get(pet.base_id)
	for i = self:getMaxRefineLevel(),level+1 , -1 do 
		local addInfo = pet_addition_info.get(info.addition_id,i-1)
		local couldRefine = not addInfo or pet.level >= addInfo.level_ban
		if couldRefine then
			return i
		end
	end

	return level
end


function PetData:getMaxStarLevel()
	return 5
end

-- 战宠最大强化等级
function PetData:getMaxStrengthLevel()
	return G_Me.userData.level
end


function PetData:getMaxRefineLevel()
	return 30
end


function PetData:getPetIdListCopy()
	local tCopyList = {}
	self:sortPetList()
	for i=1, #self._tPetIndexList do
		local nPetId = self._tPetIndexList[i]
		table.insert(tCopyList, #tCopyList + 1, nPetId)
	end
	return tCopyList
end

function PetData:couldCompound()
	-- 碎片id列表
	local tList = {}
    local tPetList = self:getPetList()
    for key, val in pairs(tPetList) do
    	local tPet = val
    	local tPetTmpl = pet_info.get(tPet["base_id"])
    	if tPetTmpl then
    		table.insert(tList, #tList + 1, tPetTmpl.relife_id)
    	end
	end

	-- local function comtains(nFragementId)
	-- 	local isContains = false
	-- 	for key, val in pairs(tList) do
 --            if nFragementId == val then
 --            	isContains = true
 --            end
	-- 	end
	-- 	return isContains
	-- end

	local list = G_Me.bagData:getPetFragmentList()
    for i,v in ipairs(list) do
        local fragment = fragment_info.get(v["id"])
        if v["num"] >= fragment.max_num and v["num"] < fragment.max_num * 2 then
            return true
        end
    end
    return false
end

function PetData:setPetBookIds(ids)
	self._tPetHandBookIds = ids or {}
end

function PetData:hasPetBookById(id)
	for k,v in pairs(self._tPetHandBookIds) do 
		if v == id then
			return true
		end
	end
	return false
end

function PetData:getComposeAttr()
	local data = {}
	for i = 1, pet_compose_info.getLength() do 
		local info = pet_compose_info.indexOf(i)
		local status = true
		for j = 1, 3 do 
			if info["pet_"..j] > 0 and not self:hasPetBookById(info["pet_"..j]) then
				status = false
			end
		end
		if status then
			for k = 1, 3 do 
				local _type = info["attribute_type_"..k]
				local _value = info["attribute_value_"..k]
				if _type > 0 then
					if data[_type] then
						data[_type] = data[_type] + _value
					else
						data[_type] = _value
					end	
				end
			end
		end
	end
	return data
end

----------------------------------------------------------------------------------

-- 计算基础属性，与强化等级有关
-- nLevel 强化等级
function PetData:getBaseAttr(nLevel, nBaseId,addition_lvl)
	local nAttack, nHp, nPhyDef, nMagDef = 0, 0, 0, 0

	local tPetTmpl = pet_info.get(nBaseId)
	local additionAttr = {self:getAttrAdd(tPetTmpl.addition_id,addition_lvl)}
	assert(tPetTmpl)
	if not tPetTmpl then
		return nAttack, nHp, nPhyDef, nMagDef
	end

	nAttack = math.floor((tPetTmpl.base_attack + (nLevel - 1) * tPetTmpl.develop_attack)*(1+additionAttr[1]/1000))
	nHp = math.floor((tPetTmpl.base_hp + (nLevel - 1) * tPetTmpl.develop_hp)*(1+additionAttr[2]/1000))
	nPhyDef = math.floor((tPetTmpl.base_physical_defence + (nLevel - 1) * tPetTmpl.develop_physical_defence)*(1+additionAttr[3]/1000))
	nMagDef = math.floor((tPetTmpl.base_magical_defence + (nLevel - 1) * tPetTmpl.develop_magical_defence)*(1+additionAttr[4]/1000))

	return nAttack, nHp, nPhyDef, nMagDef
end

function PetData:getLeftStrengthExp(pet)
	local total =  pet.exp or 0
	local level = pet.level or 1
	for i=0,level-1 do
	    total = total - self:getStrengthNextLevelExp(pet,i)
	end

	return total
end

function PetData:getStrengthMoney(pet,exp)
	return exp
end

function PetData:getNextRefineLevel(pet)
	local info = pet_info.get(pet.base_id)
	local addInfo = pet_addition_info.get(info.addition_id,pet.addition_lvl)
	return addInfo.level_ban
end

function PetData:getStrengthNextLevelExp(pet,level)
	if level == nil then
	    level = pet.level or 0
	end

	if level == 0 then 
	    return 0 
	end

	local baseInfo = pet_info.get(pet.base_id)
	--每级升级所需经验 = 初始需求经验值 + （lv ^1.8 ）* 需求经验成长值
	local exp = baseInfo.upgrade_exp + math.floor(level^1.8) * baseInfo.upgrade_exp_growth
	return exp
end

--强化到满级所需要的经验
function PetData:getStrengthLeftExp(pet)

    local maxLevel = self:getMaxStrengthLevel()
    local baseInfo = pet_info.get(pet.base_id)
    local totalExp = 0

    for i=1,maxLevel-1 do
        totalExp = totalExp + self:getStrengthNextLevelExp(pet,i)
    end
    
    local exp = totalExp - pet.exp
    return exp
end

function PetData:getStrengthAddLevel(pet,exp)
	local totalExp =  pet.exp + exp
	local level = 1
	while totalExp > 0 do
	    totalExp = totalExp - self:getStrengthNextLevelExp(pet,level)
	    level = level + 1
	end
	level = level - 1
	return level - pet.level
end

-- 口粮列表
function PetData:getCaiLiaoList()
	local idList = {290,200,199,198} -- 狗粮id
	local itemList = {}
	function getList( )
		local list = {}
		for i = 1 , #idList do 
			for j = 1 , G_Me.bagData:getPropCount(idList[i]) do 
				local g = G_Goods.convert(3,idList[i])
				g.id = i*100000+j
				table.insert(list,#list+1,g)
				if #list >= 200 then
					return list
				end
			end
		end
		return list
	end
	itemList = getList()
	-- local sortFunc = function ( a,b )
	-- 	return a.info.item_value > b.info.item_value
	-- end
	-- table.sort( itemList, sortFunc )
	return itemList
end

function PetData:getLeftRefineExp(pet)
	local total =  pet.addition_exp or 0
	local level = pet.addition_lvl or 1
	local info = pet_info.get(pet.base_id)
	for i=0,level-1 do
		local additionInfo = pet_addition_info.get(info.addition_id,i)
	    	total = total - additionInfo.exp
	end

	return total
end

function PetData.getRefineNeedExp(pet,level)
	level = level or pet.addition_lvl
	local addInfo = pet_addition_info.get(pet_info.get(pet.base_id).addition_id,level)
	return addInfo.exp
end

function PetData:getAddAttrOnKnight(pos)
	-- local pet = self:getFightPet()
	-- if not pet then
	-- 	return nil
	-- end
	-- local info = pet_info.get(pet.base_id)
	-- local additionInfo = pet_addition_info.get(info.addition_id,pet.addition_lvl)
	-- return {affect_type=additionInfo["type_"..pos],affect_value=additionInfo["value_"..pos]}
	return nil
end

--全属性加成，暂定4个加成相同
function PetData:getAttrAdd(base_id,addition_lvl)
	local info = pet_info.get(base_id)
	local additionInfo = pet_addition_info.get(info.addition_id,addition_lvl)
	return additionInfo.attack_add,additionInfo.hp_add,additionInfo.physical_defend_add,additionInfo.magical_defend_add
end

--全属性：+xxx%
function PetData:getAttrAddShow(base_id,addition_lvl)
	local per = self:getAttrAdd(base_id,addition_lvl)
	if per == 0 then
		return nil
	end
	return G_lang:get("LANG_PET_ATTR_ADD"),G_lang:get("LANG_PET_ATTR_ADD_PER",{per=string.format("%.1f",per/10)})
end

return PetData