-- Filename：	PetData.lua
-- Author：		zhz
-- Date：		2014-3-31
-- Purpose：		宠物的数据层

module("PetData", package.seeall)

require "db/DB_Pet"
require "db/DB_Pet_skill"
require "db/DB_Vip"
require "script/model/user/UserModel"
require "script/ui/pet/PetUtil"
require "script/ui/item/ItemUtil"

local _allPetInfo 	= {}			-- 所有宠物的信息
local _formationPetInfo= {}         -- 宠物阵上的数据
local _feededPetInfo = nil          -- 驯养中的宠物的数据
local _cacheAttr = {}               -- 缓存的属性信息 加速战斗力计算
local _handbookInfo = {}			-- 已经获得的图鉴信息
local _allHandbookInfo = nil 		-- 所有要展示的图鉴信息
local _extenseAffixes = {} 		-- 额外的属性加成
local _isEvolvePetInfo = nil        -- 可以进阶的宠物

function setAllPetInfo(petInfo )
	--petInfo结构 摘自 后端文档
	--array(
	--		petInfo =>array(
	--			'petid => array (
	--				'petid' => int,宠物id
    -- 				'pet_tmpl' => int, 宠物模板id
    -- 				'level' => int ,宠物等级
    -- 				'exp' => int ,宠物经验
    -- 				'swallow' => int, 已经吞噬宠物的数量
    -- 				'skill_point' => int, 宠物拥有的技能点
    -- 				'va_pet' => array(
    --					skillTalent => array(0 => array(id => 0, level => int, status => int)),
    --                  skillNormal => array(0 => array(id => 0level => int, status => int)),
    --                  skillProduct => array(0 => array(id => 0, level => int, status => int)),
    --				), 宠物技能相关
	--			),
	--		),
	--		keeperInfo =>array(
	--			pet_slot => int,宠物仓库已开启数量
    --          va_keeper => array(
    --          	0 => array(
    --					petid => int, 
    --					status => int[0未出战1已出战], 
    --					producttime => int, 
    --					traintime => int
    --				)
	--			),拥有者信息
    --		),
	--);
	_allPetInfo = petInfo
	-- 如果宠物培养属性超过上限，按照上限显示
	-- for petId,petInfo in pairs(_allPetInfo.petInfo) do
	-- 	-- if petInfo.va_pet.confirmed then
	-- 		local petDesc = DB_Pet.getDataById(tonumber(petInfo.pet_tmpl))
	-- 		petInfo.petDesc = petDesc
	-- 		limitPetAttrValue(petInfo)
	-- 	-- end
	-- end
end

function setHandbookInfo(p_handbookInfo)
	_handbookInfo = p_handbookInfo
end

function getHandbookInfo( ... )
	return _handbookInfo
end

-- 得到要展示的图鉴信息
function getAllHandbookInfo( ... )
	if _allHandbookInfo == nil then
		_allHandbookInfo = DB_Pet.getArrDataByField("handBook", 1)
		local comparator = function ( data1, data2 )
			return data1.id < data2.id
		end
		table.sort(_allHandbookInfo, comparator)
	end
	return _allHandbookInfo
end

function isGot(p_id)
	for i = 1, #_handbookInfo do
		if tonumber(_handbookInfo[i]) == p_id then
			return true
		end
	end
	return false
end

-- 
function getAllPetInfo(  )
	return _allPetInfo
end

-- 得到第一个宠物的信息
function getFirstPetInfo( )
	
end

-- 把宠物信息加到_allPetInfo
function addPetInfo( petData)
	print("petData++++++++++++++++++++++ ")
	print_t(petData)
	_allPetInfo.petInfo["" .. petData.petid]= petData
	for i = 1, #_handbookInfo do
		if tonumber(_handbookInfo[i]) == tonumber(petData.pet_tmpl) then
			return
		end
	end
	table.insert(_handbookInfo, petData.pet_tmpl)
	getExtenseAffixes(true)
end

-- 增加宠物的上阵栏位
function addPetSetpet( )
	local tempTable= {
				petid =0,
				status=0,
				producttime =0,
		}
		table.insert(_allPetInfo.keeperInfo.va_keeper.setpet, tempTable )
		-- --更新属性信息
		-- getPetAffixValue(true)
end

--获得背包大小
function getOpenBagNum()
	return tonumber(_allPetInfo.keeperInfo.keeper_slot)
end

--增加背包大小
function  addOpenBagNum(addNum)
	_allPetInfo.keeperInfo.keeper_slot = tonumber(_allPetInfo.keeperInfo.keeper_slot) + tonumber(addNum)
	print("addOpenBagNum",_allPetInfo.keeperInfo.keeper_slot)
end

--目前宠物的数量
function getPetNum()
	return tonumber(table.count(_allPetInfo.petInfo))
end

--得到背包中所有宠物的信息
function getAllBagPetInfo()
	return _allPetInfo.petInfo
end

--通过模板id获得宠物名字
function getPetNameByTid(ptid)
	local petData = DB_Pet.getDataById(ptid)
	return petData.roleName
end

--通过模板id获得宠物的品质
function getPetQualityByTid(ptid)
	local petData = DB_Pet.getDataById(ptid)
	return petData.quality
end

-- 通过petId 修改宠物的等级
function setPetLevelByPetId( petId)
	
end


-- 得到上阵的宠物信息
function getFormationPetInfo()

	_formationPetInfo = {}

	local setpet = _allPetInfo.keeperInfo.va_keeper.setpet

	for i=1,table.count(setpet) do
		if(tonumber(setpet[i].petid)== 0) then
			local tempTable= {}
			tempTable.setpet= setpet[i]
			tempTable.showStatus=2
			table.insert( _formationPetInfo,tempTable )
		else	
			for petid, petInfo in pairs(_allPetInfo.petInfo) do
				if( tonumber(setpet[i].petid ) == tonumber(petid)) then
					local tempTable= {}
					tempTable= petInfo
					tempTable.showStatus = 1
					tempTable.setpet =setpet[i]
					tempTable.petDesc=  DB_Pet.getDataById(tonumber(petInfo.pet_tmpl ) )
					-- print("=========PetData getFormationPetInfo")
					table.insert(_formationPetInfo ,tempTable)
				end
			end
		end	
	end

	if( table.count(setpet) < PetUtil.getMaxFormationNum() ) then
		local tempTable= {}
		tempTable.showStatus=3
		tempTable.setpet = {}
		table.insert( _formationPetInfo,tempTable )
	end
	
	-- print("=======================getFormationPetInfo ===================== ")
	-- print_t(_allPetInfo)
	return _formationPetInfo
end
--[[
	@des 	:获取驯养中的宠物的数据
	@param 	:
	@return :
--]]
function getFeededPetInfo( ... )
	-- body
	_feededPetInfo = {}
	local setpet = _allPetInfo.keeperInfo.va_keeper.setpet
	for i=1,table.count(setpet) do
		for petid, petInfo in pairs(_allPetInfo.petInfo) do
			if( tonumber(setpet[i].petid ) == tonumber(petid)) then
				local tempTable= {}
				tempTable= petInfo
				tempTable.showStatus = 1
				tempTable.setpet =setpet[i]
				tempTable.petDesc=  DB_Pet.getDataById(tonumber(petInfo.pet_tmpl ))
				-- print("=========PetData getFeededPetInfo")
				table.insert(_feededPetInfo ,tempTable)
			end
		end
	end
	return _feededPetInfo
end
--[[
	@des 	:获取可以进阶的宠物的数据
	@param 	:
	@return :
--]]
function getIsEvolvePetInfo( ... )
	-- body
	_isEvolvePetInfo = {}
	local setpet = _allPetInfo.keeperInfo.va_keeper.setpet
	for i=1,table.count(setpet) do
		for petid, petInfo in pairs(_allPetInfo.petInfo) do
			if( tonumber(setpet[i].petid ) == tonumber(petid)) then
				local tempTable= {}
				tempTable= petInfo
				tempTable.showStatus = 1
				tempTable.setpet = setpet[i]
				tempTable.petDesc= DB_Pet.getDataById(tonumber(petInfo.pet_tmpl ))
				-- print("=========PetData getIsEvolvePetInfo")
				if tonumber(tempTable.petDesc.ifEvolve) == 1 then
					table.insert(_isEvolvePetInfo ,tempTable)
				end
			end
		end
	end
	return _isEvolvePetInfo
end
--[[
	@des 	:通过宠物的petid获取宠物在驯养宠物中的索引
	@param 	:
	@return :
--]]
function getFeededPetIndex( pPetId )
	-- body
	local feededPetInfo = getFeededPetInfo()
	local index = nil
	for i,petInfo in ipairs(feededPetInfo) do
		if tonumber(petInfo.petid) == tonumber(pPetId) then
			index = i
			break
		end
	end
	return index
end
--[[
	@des 	:通过宠物的petid获取宠物在进阶宠物中的索引
	@param 	:
	@return :
--]]
function getEvolvePetIndex( pPetId )
	-- body
	local feededPetInfo = getIsEvolvePetInfo()
	local index = nil
	for i,petInfo in ipairs(feededPetInfo) do
		if tonumber(petInfo.petid) == tonumber(pPetId) then
			index = i
			break
		end
	end
	return index
end

-- 得到通过宠物的petId来获得可以喂养或是学习技能的宠物信息
function getFormationPetById( id)

	local _singlePetInfo={}
	local id= tonumber(id)

	local formationPetInfo = getFormationPetInfo()

	for i=1, #formationPetInfo do
		if(id == tonumber(formationPetInfo[i].petid)) then
			_singlePetInfo= formationPetInfo[i]
			break
		end
	end

	if(table.isEmpty(_singlePetInfo)) then

		local petInfo = getPetInfoById(id)
		_singlePetInfo= petInfo
		_singlePetInfo.showStatus =4

		-- local setpet= {}
	end

	return _singlePetInfo

end

--  设置普通技能状态
function setNormalSkillStatus( petId, normalId,status)
	local petInfo = getPetInfoById(petId)

	local normalId = tonumber(normalId)
	for i=1, table.count(petInfo.va_pet.skillNormal ) do
		if( tonumber(normalId) == tonumber( petInfo.va_pet.skillNormal[i].id ) ) then
			petInfo.va_pet.skillNormal[i].status=status
			break
		end
	end
end

-- 得到宠物已经锁的技能
function getLockSkillNum( petId)
	local petInfo = getPetInfoById(petId)
	local number= 0

	for i=1, table.count(petInfo.va_pet.skillNormal) do
		if( tonumber( petInfo.va_pet.skillNormal[i].status)==1 ) then
			number= number+1
		end
	end

	return number
end

-- 得到宠物在第几个上阵栏位，从0 开始
function getPosIndexById(id)
	local formationPetInfo = getFormationPetInfo()

	local id = tonumber(id)
	local posIndex =0

	for i=1, table.count(formationPetInfo) do

		if(id == tonumber( formationPetInfo[i].petid )) then
			posIndex = i-1
		end
	end
	return posIndex
end

-- 按照宠物的id,来修改技能点
function addPetSKillPointById( id, number)
	
	local number = number or 1
	local petId= tonumber(id)
	local petInfo = getPetInfoById(id)

	petInfo.skill_point = tonumber(petInfo.skill_point)+ tonumber(number) 

end

-- 通过宠物的上阵栏位获得宠物的信息
function getPetInfoByPos(posIndex )
	local formationPetInfo = getFormationPetInfo()

	local i=tonumber(posIndex)+1

	return  formationPetInfo[i]
end

-- 得到出战宠物的栏位，从0开始
function getUpPosIndex( ... )
	local posIndex = nil
	if _allPetInfo.keeperInfo then
		local setpet = _allPetInfo.keeperInfo.va_keeper.setpet

		for i=1, table.count(setpet ) do

			if( tonumber(setpet[i].status )== 1) then
				posIndex= i-1
				break
			end
		end
	end
	return posIndex
end



-- 通过宠物的petId 修改宠物出战的状态
function setFightStatusById( petId )
	local petId = tonumber(petId)

	local setpet= _allPetInfo.keeperInfo.va_keeper.setpet
	for i=1, table.count(setpet) do
		if( petId == tonumber(setpet[i].petid )) then
			_allPetInfo.keeperInfo.va_keeper.setpet[i].status=1
		else
			_allPetInfo.keeperInfo.va_keeper.setpet[i].status=0
		end
	end
	--更新属性信息
	getPetAffixValue(true)
end

-- 修改宠物的生产时间
function setProducttimeById( id ,time)
	
	for i=1, table.count(_allPetInfo.keeperInfo.va_keeper.setpet ) do

		if(id == tonumber( _allPetInfo.keeperInfo.va_keeper.setpet[i].petid)) then
			_allPetInfo.keeperInfo.va_keeper.setpet[i].producttime = time
			break
		end
	end

end

-- 获取宠物技能产出剩余时间
local _nMaxNum = 99999999999
function getLeftProducttimeById( pPetId )
	local nLeftTime = _nMaxNum    --默认剩余时间为极大数，即没有产出
	if pPetId == nil or _allPetInfo.keeperInfo == nil or _allPetInfo.keeperInfo.va_keeper == nil or _allPetInfo.keeperInfo.va_keeper.setpet == nil then
		print("getLeftProducttimeById pPetId: ", pPetId, " _allPetInfo.keeperInfo: ", _allPetInfo.keeperInfo, " _allPetInfo.keeperInfo.va_keeper: ", _allPetInfo.keeperInfo.va_keeper, " _allPetInfo.keeperInfo.va_keeper.setpet: ", _allPetInfo.keeperInfo.va_keeper.setpet)
		return nLeftTime
	end

	local nPetId = tonumber(pPetId)
	for k, v in ipairs(_allPetInfo.keeperInfo.va_keeper.setpet) do
		if nPetId == tonumber(v.petid) then
			nLeftTime = getLeftProducttimeBySet(v)
			break
		end
	end

	-- print("getLeftProducttimeById nPetId: ", nPetId, " nLeftTime: ", nLeftTime)
	return nLeftTime
end

-- 获取宠物技能产出剩余时间
function getLeftProducttimeBySet( pSetPet )
	local nLeftTime = _nMaxNum    --默认剩余时间为极大数，即没有产出
	if table.isEmpty(pSetPet) then
		print("getLeftProducttimeBySet pSetPet is empty")
		return nLeftTime
	end

	local nPetId = tonumber(pSetPet.petid)
	local tbPet = getPetInfoById(nPetId)
	if table.isEmpty(tbPet) then
		print("getLeftProducttimeBySet tbPet is empty")
		return nLeftTime
	end

	local skillId= tonumber(tbPet.va_pet.skillProduct[1].id)
	if skillId <= 0 then
		print_table("getLeftProducttimeBySet skill id is 0: ", pSetPet)
		return nLeftTime
	end

    local skillLevel= PetData.getPetSkillLevel( nPetId )
    local cdTime= PetUtil.getProduceTime(skillId, skillLevel)
    nLeftTime = cdTime + tonumber(pSetPet.producttime) - BTUtil:getSvrTimeInterval()

    return nLeftTime
end

-- 一键领取：1.是否有宠物的技能产出可以领取 2.宠物产出中是否含有物品 3.宠物产出中含有英雄
-- return: 1.是否有可以领取的产出 2.可以领取的产出信息集合 3.可领取的产出是否含有物品 4.可领取的产出是否含有英雄
function hasProductToReceive( ... )
	local bHas, tbReceive, bHasItem, bHasHero = false, {}, false, false

	if _allPetInfo.keeperInfo == nil or _allPetInfo.keeperInfo.va_keeper == nil or _allPetInfo.keeperInfo.va_keeper.setpet == nil then
		print("hasProductToReceive _allPetInfo.keeperInfo: ", _allPetInfo.keeperInfo, " _allPetInfo.keeperInfo.va_keeper: ", _allPetInfo.keeperInfo.va_keeper, " _allPetInfo.keeperInfo.va_keeper.setpet: ", _allPetInfo.keeperInfo.va_keeper.setpet)
		return bHas, tbReceive, bHasItem, bHasHero
	end

	for k, v in ipairs(_allPetInfo.keeperInfo.va_keeper.setpet) do
		if tonumber(v.petid) > 0 then           --当宠物栏位开启，但没有添加宠物时，v.petid=0
			local nLeftTime = getLeftProducttimeBySet(v)
			if nLeftTime <= 0 then
				bHas = true

				local tbPet = getPetInfoById(tonumber(v.petid))
				local skillId, level= tonumber(tbPet.va_pet.skillProduct[1].id), tonumber(tbPet.va_pet.skillProduct[1].level)

				local rewardInfo= PetUtil.getProdceInfo(skillId, level)  --lua_string_split(specialReward, "|")
				local rewardType, rewardId, rewardNum = tonumber(rewardInfo[1]), tonumber(rewardInfo[2]), tonumber(rewardInfo[3])

				if(rewardType == 7 or rewardType==6 ) then  --是否含有物品
					bHasItem = true
				end

				if(rewardType == 10 or rewardType== 13) then   --是否含有英雄
					bHasHero = true
				end

				--保存可以领取的宠物技能产出信息
				local tbTemp = {petid=tonumber(v.petid), skillid=skillId, level=level}
				tbTemp.petid, tbTemp.skillid, tbTemp.level = tonumber(v.petid), skillId, level
				table.insert(tbReceive, tbTemp)
			end
		end
	end

	return bHas, tbReceive, bHasItem, bHasHero
end

-- 是否满足一键领取所有宠物产出条件
function canOneKeyReceive( ... )
	local bRet, sDesc = 0, ""

	--是否有产出可以领取
	local bHas, tbReceive, bHasItem, bHasHero = hasProductToReceive()
	if not bHas then
		bRet, sDesc = 1, GetLocalizeStringBy("key_2416")
		return bRet, sDesc
	end

	--是背包是否已满
	if bHasItem and ItemUtil.isBagFull() then
		bRet, sDesc = 2, GetLocalizeStringBy("zq_0016")   --"背包已满"
		return bRet, sDesc
	end

	--武将数量是否已达上限
	--if bHasHero and HeroPublicUI.showHeroIsLimitedUI() then
	if bHasHero and HeroModel.isLimitedCount() then
		bRet, sDesc = 3, GetLocalizeStringBy("zq_0017")  --"武将数量是否已达上限"
		return bRet, sDesc
	end

	return bRet, sDesc
end

-- 得到可以上阵宠物的数量
function getMaxForamtionNum( ... )
	return table.count(_allPetInfo.keeperInfo.va_keeper.setpet)
end

-- 得到已经上阵的宠物数量
function getFormationNum( )

	local number=0
	local setpet= _allPetInfo.keeperInfo.va_keeper.setpet
	for i=1, table.count(setpet) do
		if( tonumber( setpet[i].petid)~= 0) then
			number=number+1
		end
	end
	return number
end

-- 通过ID获得宠物的信息
function getPetInfoById(id )
	local id=tonumber(id)

	for petId, petInfo in pairs( _allPetInfo.petInfo) do
		if( id == tonumber(petId) ) then
			return petInfo
		end
	end
	return nil
end

function setPetInfoById(id ,petData)
	local id=tonumber(id)

	print("id is :", id)

	for petId, petInfo in pairs( _allPetInfo.petInfo) do
		if( id == tonumber(petId) ) then
			_allPetInfo.petInfo["" .. petId] =petData
		end
	end
end

--通过pid得到单个宠物的战斗力 
function getPetSingleFightValue(pid)
	return 0
end


-- 得到可以上阵的宠物
function getPetCanFormation( )
	local canFormationPetInfo= {}
	for petId, petInfo in pairs( _allPetInfo.petInfo) do
		if( isPetUpByid(petId) == false) then
			table.insert(canFormationPetInfo ,petInfo)
		end
	end
	return canFormationPetInfo
end

-- 通过petTid和 petId得到可以吞噬的宠物数据
-- 首先要除掉上阵的宠物
function getCanSwallowPetInfoByTid( petId)
	
	local upPetId = nil
	local curPetInfo = getPetInfoById(tonumber(petId))
	local petTid = tonumber( curPetInfo.pet_tmpl )

	local canSwallowPetInfo= {}
	local setpet = _allPetInfo.keeperInfo.va_keeper.setpet

	local formationPetInfo = getFormationPetInfo()

	-- for i=1, table.count(formationPetInfo) do
	-- 	if( petTid == tonumber(formationPetInfo[i].pet_tmpl)) then
	-- 		upPetId = tonumber(formationPetInfo[i].petid) 
	-- 		break
	-- 	end
	-- end

	print("upPetId is :", upPetId)
	print("petTid  is :", petTid)

	--
	for petid,petInfo in pairs(_allPetInfo.petInfo) do
		-- 只能吞噬未进阶和未培养的宠物
		-- 可卖出已培养的宠物 modify 20160330 lgx
		if (petInfo.va_pet.evolveLevel == nil or tonumber(petInfo.va_pet.evolveLevel) == 0) then
			-- print(12333,petTid,petInfo.pet_tmpl,petInfo.exp,petTid ~= tonumber(petInfo.pet_tmpl) and tonumber(petInfo.exp)>0,isPetUpByid( petInfo.petid))
			if(  isPetUpByid( petInfo.petid) == false ) then
				if(  petTid == tonumber(petInfo.pet_tmpl) or ( petTid ~= tonumber(petInfo.pet_tmpl) and tonumber(petInfo.exp)>0 ) ) then
					local tempTable= {}
					tempTable= petInfo
					tempTable.showStatus = 4
					tempTable.petDesc=  DB_Pet.getDataById(tonumber(petInfo.pet_tmpl))
					-- print("=========PetData getCanSwallowPetInfoByTid")
					table.insert(canSwallowPetInfo,tempTable)
				end
			end
		end
	end	

	local function sort(w1,w2 )
		if( tonumber(w1.pet_tmpl)<tonumber(w2.pet_tmpl) ) then
			return true
		end
	end

	table.sort(canSwallowPetInfo, sort)
	return canSwallowPetInfo
end

-- 得到所有可以购买的宠物信息
function getCanSellPetInfo( )
	
	local canSellPetInfo= {}
	for petid,petInfo in pairs(_allPetInfo.petInfo) do
		-- 可卖出已培养的宠物 modify 20160330 lgx
		if(  isPetUpByid( petInfo.petid) == false and  tonumber(petInfo.level)<=20 and
			 (petInfo.va_pet == nil or (petInfo.va_pet.evolveLevel == nil or tonumber(petInfo.va_pet.evolveLevel) == 0))) then
			local tempTable= {}
			tempTable= petInfo
			tempTable.showStatus = 4
			tempTable.petDesc=  DB_Pet.getDataById(tonumber(petInfo.pet_tmpl))
			-- print("=========PetData getCanSellPetInfo")
			table.insert(canSellPetInfo,tempTable)
		end
	end	

	local function sort(w1, w2)
		
		if tonumber(w1.petDesc.quality) < tonumber(w2.petDesc.quality) then
			return true
		elseif tonumber(w1.petDesc.quality) == tonumber(w2.petDesc.quality) then
			if tonumber(w1.level) < tonumber(w2.level) then
				return true
			elseif( tonumber(w1.level) == tonumber(w2.level) ) then --and tonumber(w1.petDesc.id) < tonumber(w1.petDesc.id) )then
				if( tonumber(w1.petDesc.id) < tonumber(w2.petDesc.id) ) then
					return true
				else
					return false
				end	
			end	
		else
			return false	
		end
	end	

	table.sort(canSellPetInfo, sort)

	return canSellPetInfo
end

-- 得到卖掉一个宠物所得到的银币。
function getSoldSliverByPetInfo( petId)
	if( petId==nil ) then
		print("error !")
		return
	end

	local petInfo= getPetInfoById(tonumber(petId))
	-- print(" petInfo petInfo petInfo ")
	-- print_t(petInfo)

	local level = tonumber(petInfo.level)
	local pet_tmpl =tonumber(petInfo.pet_tmpl)

	-- print(" pet_tmpl  is ............ ", pet_tmpl)	
	local sellSilver= DB_Pet.getDataById(pet_tmpl).sellSilver
	sellSilver= lua_string_split( sellSilver,",")

	local soldSliver= tonumber(sellSilver[1])+ tonumber(sellSilver[2])*(level-1)
	return soldSliver
end



-- 通过宠物的ID，删除宠物
function removePetById(petId )
	if(petId== nil ) then
		return
	end
	_allPetInfo.petInfo[tostring(petId)] = nil 
end

-- 通过被吞噬的宠物的ID，得到可以增加的skill_point
-- 吞噬不同种宠物，被吞噬的宠物的技能点，不加到被吞噬的宠物身上。
function getAddPoint( petId, swallowPetId)

	local petInfo = getPetInfoById(tonumber(petId))
	local curPetTmpl, swallowNum=tonumber( petInfo.pet_tmpl) , petInfo.swallow 
	local PetData = DB_Pet.getDataById(tonumber(curPetTmpl) )
	local swallowedPetInfo = getPetInfoById(tonumber(swallowPetId ))
	local expUpgradeID= PetData.expUpgradeID

	local orginPetExp = tonumber(petInfo.exp)
	local originLv = tonumber(petInfo.level )

    local swallowExp = swallowedPetInfo.exp
    -- local PetData= DB_Pet.getDataById(  tonumber(swallowedPetInfo.pet_tmpl))
   	local allExp= tonumber(petInfo.exp )+ tonumber(swallowedPetInfo.exp)

    local curLv,curExp,needExp = LevelUpUtil.getObjectCurExp(PetData.expUpgradeID,allExp)


    if(curLv >UserModel.getHeroLevel() ) then
    	curLv = UserModel.getHeroLevel()
    end

    print("originLv, curLv,tonumber( petInfo.pet_tmpl) ",originLv, curLv,tonumber( petInfo.pet_tmpl))
    local levelPoint = PetUtil.getAddSkillPoint(originLv, curLv,tonumber( petInfo.pet_tmpl) )
    local swallowPoint = PetData.swallow*(tonumber(swallowedPetInfo.swallow )+1 )

    -- 如果，吞噬的宠物 何被吞噬的宠物的是不同种宠物， 那么 swallowPoint 不加。
    if( tonumber(petInfo.pet_tmpl) ~= tonumber(swallowedPetInfo.pet_tmpl) ) then
    	swallowPoint = 0
    end

    local addPoint= levelPoint+ swallowPoint

    return addPoint, curLv, allExp

end

-- 得到当前宠物有技能的数量
function getSkillNum( petId )
	local petInfo= getPetInfoById( tonumber(petId))

	local number= 0
	for i=1, table.count( petInfo.va_pet.skillNormal ) do
		if( tonumber(petInfo.va_pet.skillNormal[i].id)>0  ) then
			number= number+1
		end
	end
	return number
end


-- 判断宠物是否上阵
-- 返回宠物是否上阵，还在阵上的id
function isPetUpByid( petId )

	local setpet= _allPetInfo.keeperInfo.va_keeper.setpet
	local petId = tonumber(petId) 

	local formationPetInfo = getFormationPetInfo()

	for i=1, table.count(formationPetInfo) do
		if( formationPetInfo[i].petid and petId ==  tonumber(formationPetInfo[i].petid) ) then
			return true
		end
	end
	return false
end


-- 判断阵上是否有相同类型的宠物
function isPetUpByPetTmpl ( petTmpl)

	local petTmpl = tonumber(petTmpl)

	local petData= DB_Pet.getDataById(petTmpl)

	local petResourceType=petData.petResourceType

	local formationPetInfo = getFormationPetInfo()

	for i=1, table.count(formationPetInfo) do
		if( formationPetInfo[i].pet_tmpl and petResourceType ==  tonumber(formationPetInfo[i].petDesc.petResourceType ) ) then
			return true
		end
	end
	return false
end

-- 得到出战宠物的petid, 函数名命名的不好，和上阵有重复，都用up了。
function getUpPetId(  )
	local petId= 0
	local setpet= _allPetInfo.keeperInfo.va_keeper.setpet
	for i=1, table.count(setpet) do
		if(tonumber(setpet[i].status )== 1 ) then
			petId= tonumber(setpet[i].petid )
		end
	end

	return petId
end

-- 判断天赋技能是否有效
-- 原来的天赋技能只有宠物出战才有效果，现在是只要宠物上阵便有效果,后来改成获得过就有效果
function isSkillEffect( petSkill,petId)

	local petSkill = tonumber(petSkill)
	local upPetId = getUpPetId()

	-- 原来是判断宠物是否上阵的。
	if( petSkill == 0 ) then -- or  tonumber(petId)~= upPetId
		return false
	end

	-- print("isPetUpByid(petId)  isPetUpByid(petId) ", isPetUpByid(petId))
	-- 如果宠物不上阵
	-- if( isPetUpByid(petId)== false) then
	-- 	return
	-- end

	local formationPetInfo = getFormationPetInfo()

	local skillData = DB_Pet_skill.getDataById(tonumber(petSkill))
	local isSpecial = skillData.isSpecial
	local specialCondition = lua_string_split(skillData.specialCondition,",")
	local petInfo= getPetInfoById(tonumber(petId))
	local setpet= _allPetInfo.keeperInfo.va_keeper.setpet

	-- print("specialCondition specialCondition specialCondition")
	-- print_t(specialCondition)
	-- print("setpet setpet setpet")
	-- print_t(setpet)

	local isEffect= true

	if( isSpecial==0 or isSpecial== nil) then
		isEffect =true
	elseif(isSpecial ==1) then

		isEffect = isEffectOnSpecial_1(petSkill, petId )
	elseif(isSpecial == 2) then
		local countTable= {}
		for i=1, #specialCondition do
			countTable[i]= false
		end

		for i=1,#specialCondition do
			for j=1, table.count(setpet) do
				if(tonumber(setpet[j].petid)~= 0 ) then
					local uppetInfo = getPetInfoById(tonumber(setpet[j].petid ))
					-- modified by bzx 原来是在阵上才能激活，现在是只要曾经获得过就激活了
					if isGot(tonumber(specialCondition[i])) then
					-- if( tonumber(specialCondition[i]) == tonumber(uppetInfo.pet_tmpl) ) then
						countTable[i]= true
					end
				end
			end
		end

		for i=1, table.count(countTable) do
			if(countTable[i]== false ) then
				isEffect= false
			end
		end

		-- print("countTable countTable countTable")
		-- print_t(countTable)

	end


	return isEffect
end


-- isSpecial== 1时，则该接口为 宠物技能ID1，宠物技能ID2，宠物技能ID3……的形式，表示需要同时拥有以上几个技能才可以激活该技能
function isEffectOnSpecial_1( petSkill,petId )

	local skillData = DB_Pet_skill.getDataById(tonumber(petSkill))
	local isSpecial = skillData.isSpecial
	local specialCondition = lua_string_split(skillData.specialCondition,",")
	local petInfo= getPetInfoById(tonumber(petId))

	local isEffect= true

	local hasSkill= {}

	for i=1,table.count(petInfo.va_pet.skillNormal ) do
		table.insert(hasSkill,  petInfo.va_pet.skillNormal[i] )
	end

	for i=1, table.count(petInfo.va_pet.skillProduct ) do
		table.insert(hasSkill,  petInfo.va_pet.skillProduct[i] )
	end

	local countTable = {}
	for i=1, #specialCondition do
		countTable[i]= false
	end

	-- print("hasSkill ............................................................ ")
	-- print_t(hasSkill)

	-- print("specialCondition specialCondition specialCondition")
	-- print_t(specialCondition)


	for i=1,#specialCondition do
		for j=1, table.count(hasSkill) do
			if(tonumber(hasSkill[j].id)~= 0 ) then
				if( tonumber(specialCondition[i]) == tonumber(hasSkill[j].id) ) then
					countTable[i]= true
				end
			end
		end
	end

	for i=1, table.count(countTable) do
		if(countTable[i]== false ) then
			isEffect= false
		end
	end


	-- print("countTable countTable countTable")
	-- print_t(countTable)

	return isEffect
end

-- 得到上阵宠物天赋技能的加成,
function getAddSkillByTalent(petId)


	local addSkill= {addNormalSkillLevel = 0, addSpecialSkillLevel=0 }
	local formationPetInfo = getFormationPetInfo()
	-- print("formationPetInfo ............................. ")
	-- print_t(formationPetInfo)
	local petId= tonumber(petId)

	local upPetId = getUpPetId()

	-- 判断宠物是否出战
	-- if( tonumber(petId)~= upPetId) then --
	-- 	return addSkill
	-- end

	-- print(" isPetUpByid(petId)  isPetUpByid(petId) " ,  isPetUpByid(petId))

	-- 判断宠物的天赋技能是否有效
	if( isPetUpByid(petId)== false) then
		return addSkill
	end

	local skillTalent = {}
	local upPetId= nil -- 上阵宠物的id

	-- for i=1, table.count(formationPetInfo) do
	-- 	local status=  formationPetInfo[i].setpet.status
		-- if(status and tonumber(status) ==1) then
			-- local petSkill,petId = formationPetInfo[i].va_pet.skillTalent[1].id, formationPetInfo[i].petid
			-- if( isSkillEffect(petSkill, petId) ) then

			-- 	print(" isSkillEffect(petSkill, petId)  is :")
			-- 	print_t(isSkillEffect(petSkill, petId))

			-- 	local skillData= DB_Pet_skill.getDataById(petSkill)

			-- 	if(skillData.addNormalSkillLevel ) then
			-- 		addSkill.addNormalSkillLevel= addSkill.addNormalSkillLevel+ skillData.addNormalSkillLevel
			-- 	end

			-- 	if(skillData.addSpecialSkillLevel ) then
			-- 		addSkill.addSpecialSkillLevel= addSkill.addSpecialSkillLevel+ skillData.addSpecialSkillLevel
			-- 	end  

			-- end
	local petInfo = getPetInfoById(tonumber(petId) )	
	skillTalent=  petInfo.va_pet.skillTalent

	for j =1, table.count(skillTalent) do

		local petSkill= tonumber(skillTalent[j].id)
		if(isSkillEffect(petSkill, petId ) ) then
			local skillData= DB_Pet_skill.getDataById(petSkill)
			if(skillData.addNormalSkillLevel ) then
				addSkill.addNormalSkillLevel= addSkill.addNormalSkillLevel+ tonumber(skillData.addNormalSkillLevel) 
			end

			if(skillData.addSpecialSkillLevel ) then
				addSkill.addSpecialSkillLevel= addSkill.addSpecialSkillLevel+ tonumber(skillData.addSpecialSkillLevel)
			end
		end

	end
	return addSkill
end

-- 获得宠物的技能等级，skillType=1,普通技能，2，特殊技能
function getPetSkillLevel( petId, skillTyoe )
	local petInfo = getPetInfoById(tonumber(petId))
	local skillTyoe= skillTyoe or 2

	-- print("in  getPetSkillLevel petId is :", petId)

	local skillLevel =0
	if( skillTyoe==1 ) then
		-- skillLevel= tonumber()

	elseif(skillTyoe ==2) then
		skillId = tonumber(petInfo.va_pet.skillProduct[1].id ) 

		
		skillLevel= petInfo.va_pet.skillProduct[1].level

		if(skillId == 0) then
			return 0
		end

		skillLevel = skillLevel+ getAddSkillByTalent(tonumber(petId)).addSpecialSkillLevel
	end	


	-- print(" getAddSkillByTalent(tonumber(petId)).addSpecialSkillLevel", getAddSkillByTalent(tonumber(petId)).addSpecialSkillLevel)
	-- print("skillLevel is :", skillLevel)
	return skillLevel
end

-- 得到宠物的战斗力，UI前端显示用
function getPetFightForceById( id )
	local petInfo = getPetInfoById(tonumber(id))
	local fightForceNumber = 0

	if(tonumber(id)==0 or table.isEmpty(petInfo)) then
		return 0
	end	

	local skillNormal = petInfo.va_pet.skillNormal
	local skillTalent = petInfo.va_pet.skillTalent
	local skillProduct= petInfo.va_pet.skillProduct
	-- 进阶数值
	local evolveLevel = petInfo.va_pet.evolveLevel
	if(evolveLevel)then
		evolveLevel = tonumber(evolveLevel)
	end
	-- 培养数值
	local confirmed = petInfo.va_pet.confirmed
	local confirmedTotalValue = 0
	local limitValue = getAttrLimitValue(petInfo)
	-- print("limitValue1111",limitValue)
	if(not table.isEmpty(confirmed))then
		for k,affixValue in pairs(confirmed) do
			affixValue = tonumber(affixValue)
			-- 如果宠物属性值大于当前进阶等级所能培养的最大属性值
			if affixValue > limitValue then
				affixValue = limitValue
			end
			confirmedTotalValue = confirmedTotalValue + tonumber(affixValue)
		end
	end
	

	local addTable = getAddSkillByTalent(id)
	local addNormal = addTable.addNormalSkillLevel
	local addSpecial = addTable.addSpecialSkillLevel

	-- 宠物进阶的技能等级加成
    local evolveAddSkillLv = getPetEvolveSkillLevel(petInfo,evolveLevel or 0)
    print("PetData getPetFightForceById evolveAddSkillLv => ",evolveAddSkillLv)

	-- 普通技能
	for i=1, table.count( skillNormal) do
		local skillId= tonumber(skillNormal[i].id)
		if( skillId ~= 0 and DB_Pet_skill.getDataById(skillId).fightForce) then
			local fightForce = DB_Pet_skill.getDataById(skillId).fightForce
			fightForce= fightForce* (tonumber(skillNormal[i].level )+addNormal+evolveAddSkillLv)
			fightForceNumber= fightForceNumber+ fightForce
		end
	end

	if isPetUpByid(id) then
		-- 特殊技能
		for i=1, table.count( skillProduct) do
			local skillId= tonumber(skillProduct[i].id)
			if( skillId ~= 0 and DB_Pet_skill.getDataById(skillId).fightForce) then
				local fightForce = DB_Pet_skill.getDataById(skillId).fightForce
				fightForce= fightForce* (tonumber(skillProduct[i].level )+addSpecial)
				fightForceNumber= fightForceNumber+ fightForce
			end
		end
	end

	-- 天赋技能
	for i=1, table.count( skillTalent) do
		local skillId= tonumber(skillTalent[i].id)
		if( skillId ~= 0 and DB_Pet_skill.getDataById(skillId).fightForce) then
			if isSkillEffect(skillId,id) then
				local fightForce = DB_Pet_skill.getDataById(skillId).fightForce
				fightForce= fightForce* tonumber(skillTalent[i].level )
				fightForceNumber= fightForceNumber+ fightForce
			end
		end
	end

	if(evolveLevel and evolveLevel >= 1)then	
		require "db/DB_Pet_cost"
	    local costTable = DB_Pet_cost.getDataById(1)
		local evolveFightForce = costTable.evolveFightForce
		evolveFightForce = string.split(evolveFightForce,"|")
		for i=1,evolveLevel do
			-- print("fightForceNumber + evolveFightForce[i]",evolveFightForce[i])
			fightForceNumber = fightForceNumber + evolveFightForce[i]
		end
	end
	-- print("confirmedTotalValue",confirmedTotalValue)
	if(confirmedTotalValue > 0)then
		require "db/DB_Pet_cost"
	    local costTable = DB_Pet_cost.getDataById(1)
		local potentialityFightForce = costTable.PotentialityFightForce
		fightForceNumber = fightForceNumber + math.floor(potentialityFightForce * confirmedTotalValue / 10)
	end
	-- print("================= getPetAppend getPetAppend getPetAppend ")
	-- local a =getPetAppend( )

	return fightForceNumber
end


-- 加玩家的战斗力
function getPetAppend( )

	local tRetValue = {}
	if( table.isEmpty(_allPetInfo)) then
		return tRetValue
	end
	
	local formationPetInfo = getFormationPetInfo()

	
	local skillNormal= {}

	for i=1, table.count( formationPetInfo) do
		local status = tonumber( formationPetInfo[i].setpet.status)
		if(status and tonumber(status) ==1) then
			skillNormal = formationPetInfo[i].va_pet.skillNormal 
			break
		end
	end
	local upPetId = getUpPetId()

	local addSkill= getAddSkillByTalent(tonumber(upPetId))
	local addNormalSkillLevel= addSkill.addNormalSkillLevel

	-- print("+===== addSkill getAddSkillByTalent")
	-- print_t(addSkill)

	-- 宠物进阶的技能等级加成
    local curPetInfo = getPetInfoById(tonumber(upPetId))
    local evolveAddSkillLv = 0
    if (curPetInfo) then
	    local evolveLv = tonumber(curPetInfo.va_pet.evolveLevel) or 0
	    evolveAddSkillLv = getPetEvolveSkillLevel(curPetInfo,evolveLv)
	end
    print("PetData getPetAppend evolveAddSkillLv => ",evolveAddSkillLv)

	for i=1, table.count(skillNormal) do
		local skillId, level = tonumber(skillNormal[i].id), tonumber(skillNormal[i].level)+addNormalSkillLevel+evolveAddSkillLv

		if(skillId >0) then	
			local skillProperty= PetUtil.getNormalSkill(skillId, level ) 
			table.insert(tRetValue , skillProperty)
		end
	end

	print("==========tRetValue tRetValue tRetValue ")
	print_t(tRetValue)

	return tRetValue
end
--p_isForce:是否重新计算属性信息
function getPetAffixValue( p_isForce)
	if(p_isForce ~= true and not table.isEmpty(_cacheAttr) )then
		return _cacheAttr
	end
	local tInfo = getPetAppend()

	local retTable = {}

	for i=1,#tInfo do
		for j=1,#tInfo[i] do
			local v = tInfo[i][j]
			if(retTable[tostring(v.affixDesc[1])] == nil) then
				retTable[tostring(v.affixDesc[1])] = tonumber(v.realNum)
			else
				retTable[tostring(v.affixDesc[1])] = tonumber(retTable[tostring(v.affixDesc[1])]) + tonumber(v.realNum)
			end
			
		end
	end
	-- 宠物进阶和培养的属性
	local petUpId = getUpPosIndex()
	if petUpId then
		local petInfo = getPetInfoByPos(petUpId)
		print("petInfo12345")
		print_t(petInfo)
		local evolveInfo = getPetTrainAttrTotalValue(petInfo)
		print("evolveInfo12345")
		print_t(evolveInfo)
		for petId,attrData in pairs(evolveInfo) do
			if(retTable[tostring(petId)] == nil) then
				retTable[tostring(petId)] = tonumber(attrData.realNum)
			else
				retTable[tostring(petId)] = tonumber(retTable[tostring(petId)]) + tonumber(attrData.realNum)
			end
		end
	end
	-- print("retTable12345")
	-- print_t(retTable)
	-- print("evolveInfo12345")
	-- print_t(evolveInfo)
	_cacheAttr = retTable
	return retTable
end


-- 通过宠物的id,获得宠物的加成属性
function getPetValueById( petId)
	local petInfo= getPetInfoById(tonumber(petId))
	local skillNormal = petInfo.va_pet.skillNormal
	local addNormalSkillLevel = getAddSkillByTalent( tonumber(petId) ).addNormalSkillLevel

	-- 宠物进阶的技能等级加成
    local evolveLv = tonumber(petInfo.va_pet.evolveLevel) or 0
    local evolveAddSkillLv = getPetEvolveSkillLevel(petInfo,evolveLv)
    print("PetData getPetValueById evolveAddSkillLv => ",evolveAddSkillLv)

	local retTable= {}
	local tInfo = {}
	local petProperty= {}

	for i=1, table.count(skillNormal) do
		local skillId, level = tonumber(skillNormal[i].id), tonumber(skillNormal[i].level)+addNormalSkillLevel+evolveAddSkillLv

		if(skillId >0) then	
			local skillProperty= PetUtil.getNormalSkill(skillId, level ) 
			table.insert(tInfo , skillProperty)
		end
	end

	-- print(" tInfo is =================================== ")
	-- print_t(tInfo)

	-- tInfo: 
	for i=1,#tInfo do
		for j=1,#tInfo[i] do
			local v = tInfo[i][j]
			if(retTable[tostring(v.affixDesc[1])] == nil) then
				retTable[tostring(v.affixDesc[1])] = v
			else
				retTable[tostring(v.affixDesc[1])].realNum = retTable[tostring(v.affixDesc[1])].realNum + v.realNum
				retTable[tostring(v.affixDesc[1])].displayNum = retTable[tostring(v.affixDesc[1])].displayNum + v.displayNum
			end
			-- if(retTable[] )
			
		end
	end

	-- print("retTable retTable--------------------------------------- ")
	-- print_t(retTable)

	for k,v in pairs( retTable) do
		table.insert(petProperty, v)
	end

	return petProperty

end


function getLockCost(petId)
	local haveLockNum = getLockSkillNum(tonumber(petId) )

	local idPetInfo = getPetInfoById(petId)
	require "db/DB_Pet_cost"
	local costTable = DB_Pet_cost.getDataById(1)
	local costString = costTable.lockSkillCost
	local tableOne = lua_string_split(costString,",")

	require "db/DB_Pet"
	local canLockNum = DB_Pet.getDataById(tonumber(idPetInfo.pet_tmpl)).lockSkillNum
	if tonumber(canLockNum) < haveLockNum+1 then
		--返回-1，则无法加锁
		return -1
	else
		local tableTwo = lua_string_split(tableOne[haveLockNum+1],"|")
		return tableTwo[2]
	end
end

--得到宠物的资质
function getPetQuality(petTempId)
	local petDB = DB_Pet.getDataById(petTempId)
	return tonumber(petDB.petQuality)
end
--[[
	@des 	:根据宠物碎片的数目是否足够兑换宠物来显示小红点
	@param 	:
	@return :
--]]
function isShowTip()
	require "script/ui/item/ItemUtil"
	local fragTemp = ItemUtil.getPetFragInfos()
	local isShow = false
	local fragNum = 0
	for i = 1,#fragTemp do
		if tonumber(fragTemp[i].item_num) >= tonumber(fragTemp[i].itemDesc.need_part_num) then
			isShow = true
			fragNum = fragNum+1
		end
	end

	return isShow,fragNum
end

--[[
	@des 	:通过宠物pid得到宠物名字和加锁次数
	@param 	:
	@return :宠物名字，加锁次数
--]]
function getPetName(petId)
	local idPetInfo = getPetInfoById(petId)
	require "db/DB_Pet"
	local petDBInfo = DB_Pet.getDataById(tonumber(idPetInfo.pet_tmpl))

	return petDBInfo.lockSkillNum,petDBInfo.roleName,petDBInfo.quality
end

--[[
	@des 	:特殊技能红圈提示
	@param 	:
	@return :是否有红圈提示
--]]
function productTip()
	local haveTip = false

	if not table.isEmpty(_allPetInfo) then
		local setpet = _allPetInfo.keeperInfo.va_keeper.setpet

		for i=1,table.count(setpet) do
			if tonumber(setpet[i].petid) ~= 0 then
				local petInfo = _allPetInfo.petInfo[tostring(setpet[i].petid)]

				local skillId = tonumber(petInfo.va_pet.skillProduct[1].id)
				if skillId ~= 0 then
					local skillLevel = getPetSkillLevel(tonumber(setpet[i].petid))
					local cdTime= PetUtil.getProduceTime(skillId,skillLevel)
					local leftTime = cdTime + tonumber(setpet[i].producttime ) - BTUtil:getSvrTimeInterval()
					if tonumber(leftTime) <= 0 then
						haveTip = true
						break
					end
				end
			end
		end
	end

	return haveTip
end


--[[
	@des 	:得到扩充宠物背包价格
	@param 	:
	@return :
--]]
function getPetBagEnlargeCostNum()
	require "db/DB_Pet_cost"
    local dbData = DB_Pet_cost.getDataById(1)
    local openNum = dbData.openFenseNum
    local starNum = tonumber(dbData.baseFenseNum)
    local baseMoney = tonumber(dbData.openFenseBaseCost)
    local needMoney = baseMoney + tonumber((getOpenBagNum()-starNum)/openNum)*tonumber(dbData.openFenseGrowCost)
    return needMoney
end

-- 得到额外的属性加成 added by bzx
function getExtenseAffixes(isForce)
	if not isForce then
		return _extenseAffixes
	end 
	_extenseAffixes = {}
	local handbookInfo = getHandbookInfo()
	for i = 1, #handbookInfo do
		local petId = handbookInfo[i]
		local petDb = DB_Pet.getDataById(petId)
		if petDb.extra_affix ~= nil then
			local extraAffix = parseField(petDb.extra_affix, 2)
			for j = 1, #extraAffix do
				local affix = extraAffix[j]
				_extenseAffixes[affix[1]] = _extenseAffixes[affix[1]] or 0
				_extenseAffixes[affix[1]] = _extenseAffixes[affix[1]] + affix[2]
			end
		end
	end
	return _extenseAffixes
end
-------------------------宠物进阶开始-------------------------
-- 根据进阶等级获取进阶所需要的物品
function getAdvanceCostByLevel( pPetId,pLv )
	-- body
	pLv = pLv or 1
	local petData = DB_Pet.getDataById(pPetId)
	local costString = petData.evolveCost
	local costStrAry = string.split(costString,";")
	-- local data = ItemUtil.getItemsDataByStr(costStrAry[pLv])[1]
	-- print(table.count(data),11111)
	return costStrAry[pLv]
end
--[[
	@des 	:根据进阶等级获取宠物进阶后的属性
	@param 	:
	@return :
--]]
function getPetEvolveAttrByLv( pPetInfo,pLv )
	-- body
	-- local petInfo= getPetInfoById(tonumber(pPetId))
	-- 宠物进阶等级和属性的映射
	local attrLVEvolveMap = {}
	if not pPetInfo.petDesc then
		pPetInfo.petDesc = DB_Pet.getDataById(pPetInfo.pet_tmpl)
		-- print("=========PetData getPetEvolveAttrByLv")
	end
	-- 可洗练的属性
	local PotentialityAttrString = pPetInfo.petDesc.PotentialityAttr
	local PotentialityAttrStrAry = string.split(PotentialityAttrString,",")
	for i,attrStr in ipairs(PotentialityAttrStrAry) do
		local attrStrAry = string.split(attrStr,"|")
		local affixDesc,displayNum,realNum = ItemUtil.getAtrrNameAndNum(attrStrAry[1],0)
		attrLVEvolveMap[tonumber(attrStrAry[1])] = {["affixDesc"] = affixDesc,["displayNum"] = displayNum,["realNum"] = realNum}
	end
	-- print(12345)
	-- print_t(attrLVEvolveMap)

	local evolveAttrString = pPetInfo.petDesc.evolveAttr
	-- print("evolveAttrString",evolveAttrString)
	local currAttrAry = string.split(evolveAttrString,",")
	-- 宠物进阶等级和属性的映射
	-- local attrLVEvolveMap = {}
	for i,attrDataStr in ipairs(currAttrAry) do
		local attrDataAry = string.split(attrDataStr,"|")
		-- print(pLv,attrDataAry[1],55555)
		-- print_t(attrDataAry)
		if tonumber(pLv) < tonumber(attrDataAry[1]) then
			break
		end
		local affixDesc,displayNum,realNum = ItemUtil.getAtrrNameAndNum(attrDataAry[2],attrDataAry[3])
		-- print_t(affixDesc)
		local ary = attrLVEvolveMap[tonumber(attrDataAry[2])]
		local tempAry = {["displayNum"] = displayNum,["realNum"] = realNum}
		for k,v in pairs(tempAry) do
			-- print(ary[k],v,123)
			ary[k] = tonumber(ary[k]) + tonumber(v)
		end
	end
	local attrTableAry = {}
	for k,attrTable in pairs(attrLVEvolveMap) do
		table.insert(attrTableAry,attrTable)
	end
	local sortFun = function ( t1,t2 )
		-- body
		return tonumber(t1.affixDesc.id) < tonumber(t2.affixDesc.id)
	end
	table.sort(attrTableAry,sortFun)
	-- print(12345)
	-- print_t(attrTableAry)
	return attrTableAry
end
--[[
	@des 	:根据进阶等级获取宠物进阶后技能等级加成
	@param 	:
	@return :
--]]
function getPetEvolveSkillLevel( pPetInfo,pLv )
	-- print("-----------getPetEvolveSkillLevel-----------")
	-- print_t(pPetInfo)
	-- body
	pLv = tonumber(pLv) or 0
	-- 技能等级加成
	local skillLvNum = 0
	-- local petInfo= getPetInfoById(tonumber(pPetId))
	if not pPetInfo.petDesc then
		pPetInfo.petDesc = DB_Pet.getDataById(pPetInfo.pet_tmpl)
	end
	local evolveSkillString = pPetInfo.petDesc.evolveSkill
	local evolveSkillStringAry = string.split(evolveSkillString,",")
	for i,skillStr in ipairs(evolveSkillStringAry) do
		local tempAry = string.split(skillStr,"|")
		if pLv >= tonumber(tempAry[1]) then
			skillLvNum = skillLvNum + tonumber(tempAry[2])
		else
			break
		end
	end
	return skillLvNum
end
--[[
	@des 	:获取宠物进阶的等级限制
	@param 	:
	@return :
--]]
function getLevelLimitValue( pPetId,pLv )
	-- body
	local petInfo= getPetInfoById(tonumber(pPetId))
	local levelLimitString = petInfo.petDesc.evolveLevel
	local levelLimitStrAry = string.split(levelLimitString,",")
	local curLevelLimitStr = levelLimitStrAry[pLv]
	local curLvLimitAry = string.split(curLevelLimitStr,"|")
	return tonumber(curLvLimitAry[2])
end
--[[
	@des 	:获取宠物进阶最大等级
	@param 	:
	@return :
--]]
function getMaxEvolveLevel( pPetInfo )
	-- body
	-- local petInfo= getPetInfoById(tonumber(pPetId))
	local levelLimitString = pPetInfo.petDesc.evolveLevel
	local levelLimitStrAry = string.split(levelLimitString,",")
	return table.count(levelLimitStrAry)
end
--[[
	@des 	:进阶成功后修改宠物的进阶等级
	@param 	:
	@return :
--]]
function addPetEvolveLv( pPetId )
	-- body
	local petInfo = getPetInfoById(pPetId)
	if petInfo.va_pet.evolveLevel then
		petInfo.va_pet.evolveLevel = petInfo.va_pet.evolveLevel + 1
	else
		petInfo.va_pet.evolveLevel = 1
	end
end
-------------------------宠物进阶结束-------------------------

-------------------------宠物培养开始-------------------------
--[[
	@des 	:获取宠物可以培养的属性数据
	@param 	:
	@return :
--]]
function getTrainAttrData( pPetInfo )
	-- body
	local attrInfoAry = {}
	local attrString = pPetInfo.petDesc.PotentialityAttr
	local attrStrAry = string.split(attrString,",")
	for i,attrStr in ipairs(attrStrAry) do
		local attrAry = string.split(attrStr,"|")
		affixDesc = ItemUtil.getAtrrNameAndNum(attrAry[1],0)
		table.insert(attrInfoAry,affixDesc)
	end
	-- print(12345)
	-- print_t(attrInfoAry)
	return attrInfoAry
end
--[[
	@des 	:获取宠物可以培养的属性值的上限,用于显示
	@param 	:
	@return :
--]]
function getTrainAttrLimit( pPetInfo )
	-- body
	pIsShow = pIsShow or false
	-- 当前的进阶等级
	local limitValueAry = {}
	local limitValue = getAttrLimitValue(pPetInfo)
	local attrString = pPetInfo.petDesc.PotentialityAttr
	local attrStrAry = string.split(attrString,",")
	for i,attrStr in ipairs(attrStrAry) do
		local attrAry = string.split(attrStr,"|")
		-- print("limitValue",limitValue,attrAry[3])
		limitValueAry[tonumber(attrAry[1])] = limitValue / tonumber(attrAry[3])
	end
	-- print("limitValueAry")
	-- print_t(limitValueAry)
	return limitValueAry
end
--[[
	@des 	:根据进阶等级获取宠物可以培养的属性值的上限
	@param 	:
	@return :
--]]
function getAttrLimitValue( pPetInfo )
	-- body
	-- local pPetInfo = getPetInfoById(pPetID)
	local evolveLevel = 0
	if pPetInfo.va_pet then
		evolveLevel = tonumber(pPetInfo.va_pet.evolveLevel) or 0
	elseif pPetInfo.arrSkill and  pPetInfo.arrSkill.evolveLevel then
		evolveLevel = tonumber(pPetInfo.arrSkill.evolveLevel) or 0
	elseif pPetInfo.evolveLevel then
		evolveLevel = tonumber(pPetInfo.evolveLevel) or 0
	end
	if not pPetInfo.petDesc then
		pPetInfo.petDesc = DB_Pet.getDataById(pPetInfo.pet_tmpl)
		-- print("=========PetData getPetEvolveAttrByLv")
	end
	local ValuePotentiality = pPetInfo.petDesc.ValuePotentiality
	local valueStrAry = string.split(ValuePotentiality,",")
	for i,valueStr in ipairs(valueStrAry) do
		local valueLimitAry = string.split(valueStr,"|")
		if evolveLevel <= tonumber(valueLimitAry[1]) then
			limitValue = tonumber(valueLimitAry[2])
			break
		end
	end
	return tonumber(limitValue)
end
--[[
	@des 	:根据培养档次获取材料的数量
	@param 	:
	@return :
--]]
function getItemIdByTrainGrade( pPetInfo,pGrade )
	-- body
	local potentialityItemStr = pPetInfo.petDesc.PotentialityItem
	local potentialityItemStrAry = string.split(potentialityItemStr,",")
	local itemId = string.split(potentialityItemStrAry[pGrade],"|")[2]
	return ItemUtil.getCacheItemNumBy(itemId)
end
--[[
	@des 	:获取培养宠物需要材料的数量
	@param 	:
	@return :
--]]
function getItemCostNumByPetNowAttNum( pPetInfo )
	-- body
	local costNum = 0
	local totalAttrNum = 0
	if pPetInfo.va_pet.confirmed then
		for k,v in pairs(pPetInfo.va_pet.confirmed) do
			v = tonumber(v)
			-- v = getAttrDisplayNumByAttrID(pPetInfo,k,v)
			totalAttrNum = totalAttrNum + tonumber(v)
		end
	end
	print("totalAttrNum",totalAttrNum)
	local PotentialityCost = pPetInfo.petDesc.PotentialityCost
	print("PotentialityCost",PotentialityCost)
	local PotentialityCostAry = string.split(PotentialityCost,",")
	for i,costInfoStr in ipairs(PotentialityCostAry) do
		local costInfoAry = string.split(costInfoStr,"|")
		print("costInfoAry")
		print_t(costInfoAry)
		print(totalAttrNum,costInfoAry[1],totalAttrNum < tonumber(costInfoAry[1]))
		if totalAttrNum < tonumber(costInfoAry[1]) then
			break
		end
		costNum = costInfoAry[2]
	end
	print("costNum",costNum)
	return costNum
end
--[[
	@des 	:确认后增加属性
	@param 	:
	@return :
--]]
function addAttrValue( pPetInfo )
	-- body
	local confirmed = pPetInfo.va_pet.confirmed
	local toConfirm = pPetInfo.va_pet.toConfirm
	if confirmed then
		for attrID,attrValue in pairs(toConfirm) do
			confirmed[attrID] = attrValue
		end
	else
		pPetInfo.va_pet.confirmed = toConfirm
	end
	pPetInfo.va_pet.toConfirm = nil
end
--[[
	@des 	:根据宠物属性ID获取其显示的数量
	@param 	:
	@return :
--]]
function getAttrDisplayNumByAttrID( pPetInfo,pAttrID,pAttrNum )
	-- body
	local displayNum = 0
	pAttrNum = tonumber(pAttrNum) or 0
	-- 上限判断
	local limitValue = getAttrLimitValue(pPetInfo)
	if pAttrNum > limitValue then
		pAttrNum = limitValue
	end
	local attrString = pPetInfo.petDesc.PotentialityAttr
	local attrStrAry = string.split(attrString,",")
	for i,attrStr in ipairs(attrStrAry) do
		local attrAry = string.split(attrStr,"|")
		if tonumber(attrAry[1]) == tonumber(pAttrID) then
			displayNum = math.floor(tonumber(pAttrNum) / tonumber(attrAry[3]))
			break
		end
	end
	-- print("getAttrDisplayNumByAttrID",pAttrID,pAttrNum)
	return displayNum
end
--[[
	@des 	:根据宠物数据判断当前宠物是否是未确认状态
	@param 	:
	@return :
--]]
function getIsConfirm( pPetInfo )
	-- body
	local ret = false
	if pPetInfo.va_pet.toConfirm and (not table.isEmpty(pPetInfo.va_pet.toConfirm)) then
		ret = true
	end
	return ret
end
--[[
	@des 	:获取宠物培养属性和进阶属性的总和
	@param 	:
	@return :
--]]
function getPetTrainAttrTotalValue( pPetInfo )
	-- body
	-- 属性id和属性加成总值的映射
	print("battlePetInfo")
	print_t(pPetInfo)
	local attrTotalValueMap = {}
	local evolveLevel = 0
	local confirmed = nil
	if pPetInfo.va_pet then
		--宠物背包用
		evolveLevel = tonumber(pPetInfo.va_pet.evolveLevel) or 0
		confirmed = pPetInfo.va_pet.confirmed
	elseif pPetInfo.arrSkill and (pPetInfo.arrSkill.evolveLevel or pPetInfo.arrSkill.confirmed) then
		--查看对方整容
		print("otherPetInfo")
		print_t(pPetInfo)
		evolveLevel = tonumber(pPetInfo.arrSkill.evolveLevel) or 0
		confirmed = pPetInfo.arrSkill.confirmed
	elseif pPetInfo.evolveLevel or pPetInfo.confirmed then
		--战斗中宠物属性
		print("battlePet")
		print_t(pPetInfo)
		evolveLevel = tonumber(pPetInfo.evolveLevel) or 0
		confirmed = pPetInfo.confirmed
	end

	print("evolveLevel11111",evolveLevel)
	print_t(confirmed)
	-- limitPetAttrValue(pPetInfo)
	local evolveAttrAry = getPetEvolveAttrByLv(pPetInfo,evolveLevel)
	for i,attrInfo in ipairs(evolveAttrAry) do
		local attrID = tostring(attrInfo.affixDesc.id)
		local confirmedAttrValue = 0
		if not table.isEmpty(confirmed) then
			confirmedAttrValue = tonumber(confirmed[attrID]) or 0
			confirmedAttrValue = getAttrDisplayNumByAttrID(pPetInfo,attrID,confirmedAttrValue)
		end
		attrInfo.displayNum = tonumber(attrInfo.displayNum) + confirmedAttrValue
		attrInfo.realNum = tonumber(attrInfo.realNum) + confirmedAttrValue
		attrTotalValueMap[attrID] = attrInfo
	end

	return attrTotalValueMap
end
-------------------------宠物培养结束-------------------------

-------------------------宠物资质兑换-------------------------
--[[
	@des 	:获取宠物资质兑换的金币花费
	@param 	:
	@return :
--]]
function getSwapGoldCost( ... )
	-- body
	return DB_Pet_cost.getDataById(1).changeCost
end
--[[
	@des 	:获取可以资质替换的宠物的数据
	@param 	:
	@return :
--]]
function getSwapPetInfo( pPetID )
	-- body
	local swapPetInfoAry = {}
	for petid, petInfo in pairs(_allPetInfo.petInfo) do
		if tonumber(pPetID) ~= tonumber(petid) then
			local tempTable= {}
			tempTable = petInfo
			tempTable.showStatus = 1
			tempTable.petDesc= DB_Pet.getDataById(tonumber(petInfo.pet_tmpl ))
			-- print("=========PetData getSwapPetInfo")
			if tempTable.petDesc.ifEvolve == 1 then
				table.insert(swapPetInfoAry ,tempTable)
			end
		end
	end
	return swapPetInfoAry
end
--[[
	@des 	:交换宠物资质
	@param 	:
	@return :
--]]
function exchangePetInfo( pPetInfo,pSwapPetInfo )
	-- body
	-- print("before exchange")
	-- print_t(pPetInfo)
	-- print_t(pSwapPetInfo)
	-- 宠物进阶等级归零
	pPetInfo.va_pet.evolveLevel = 0
	pSwapPetInfo.va_pet.evolveLevel = 0
	-- 交换宠物的培养属性
	local tempConfirmed = pPetInfo.va_pet.confirmed
	pPetInfo.va_pet.confirmed = pSwapPetInfo.va_pet.confirmed
	pSwapPetInfo.va_pet.confirmed = tempConfirmed
	-- 判断属性是否溢出
	-- limitPetAttrValue(pPetInfo)
	-- limitPetAttrValue(pSwapPetInfo)
	-- 设置宠物数据
	setPetInfoById(pPetInfo.petid,pPetInfo)
	setPetInfoById(pSwapPetInfo.petid,pSwapPetInfo)
	-- print("after exchange")
	-- print_t(pPetInfo)
	-- print_t(pSwapPetInfo)
end
--[[
	@des 	:若宠物的培养属性超出该宠物该阶段的上限，则最终生成的属性按照该宠物该阶段的上限进行生效。
	@param 	:
	@return :
--]]
function limitPetAttrValue( pPetInfo )
	-- body
	local confirmed = pPetInfo.va_pet.confirmed
	if table.isEmpty(confirmed) then
		return
	end
	local limitValue = getAttrLimitValue(pPetInfo)
	for attrID,attrValue in pairs(confirmed) do
		if tonumber(attrValue) > tonumber(limitValue) then
			confirmed[tostring(attrID)] = limitValue
		end
	end
	pPetInfo.va_pet.confirmed = confirmed
end
--[[
	@des 	:资质互换后计算返还的资源
	@param 	:
	@return :
--]]
function countResourceByPetInfo( pPetInfo,pResourceDataTable )
	-- body
	local resourceDataTable = pResourceDataTable or {}
	local evolveLevel = 0
	if pPetInfo.va_pet then
		evolveLevel = pPetInfo.va_pet.evolveLevel or 0
	end
	local petData = DB_Pet.getDataById(tonumber(pPetInfo.pet_tmpl))
	local costString = petData.evolveCost
	local costStrAry = string.split(costString,";")
	local rewardData = nil
	for i=1,evolveLevel do
		local tempRewardData = ItemUtil.getItemsDataByStr(costStrAry[i])
		for i,data in ipairs(tempRewardData) do
			if data.type == "silver" then
				if resourceDataTable["silver"] then
					resourceDataTable["silver"].num = resourceDataTable["silver"].num + data.num
				else
					resourceDataTable["silver"] = data
				end
			else
				if resourceDataTable[data.tid] then
					resourceDataTable[data.tid].num = resourceDataTable[data.tid].num + data.num
				else
					resourceDataTable[data.tid] = data
				end
			end
		end
	end
	return resourceDataTable
end
function countTotalResource( pPetInfo,pSwapPetInfo )
	-- body
	local resourceDataTable = countResourceByPetInfo(pPetInfo)
	resourceDataTable = countResourceByPetInfo(pSwapPetInfo,resourceDataTable)
	local resourceDataAry = {}
	for k,data in pairs(resourceDataTable) do
		table.insert(resourceDataAry,data)
	end
	-- print("resourceDataAry")
	-- print_t(resourceDataAry)
	return resourceDataAry,resourceDataTable
end

-------------------------宠物资质兑换-------------------------