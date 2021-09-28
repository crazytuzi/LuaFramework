-- FileName: PocketData.lua
-- Author:
-- Date: 2014-04-00
-- Purpose: 锦囊模块数据层
--[[TODO List]]

module("PocketData", package.seeall)
require "script/ui/pocket/PocketChooseLayer"
local _pocketInfo =nil
local _pocketFightPowerInfo = {}
local chooseFSTable = {}
local _itemData = nil

function setItemData( pData )
	-- body
	_itemData = pData
end

function getAttrIdAndValue( str_arr )
	local arrData = {}
	local arr_1 = string.split(str_arr, ",")
	for k,v in pairs(arr_1) do
		local arr_2 = string.split(v, "|")
		-- 以属性id为key  属性值为value
		arrData[arr_2[1]] = arr_2[2]
	end
	return arrData
end

--获得表配置的锦囊的属性id，基础值，成长值
function getPocketAttrByTemplate_id( template_id )
	local tData = {}
	local itemData = ItemUtil.getItemById(template_id)
	-- 基础值
	local arr_1 = getAttrIdAndValue(itemData.baseAtt)
	-- 成长值
	local arr_2 = getAttrIdAndValue(itemData.growAtt)
	-- 合并
	for k1,v1 in pairs(arr_1) do
		for k2,v2 in pairs(arr_2) do
			if( tonumber(k1) == tonumber(k2) )then
				tData[k1] = {}
				tData[k1].baseData = tonumber(v1)
				tData[k1].growData = tonumber(v2)
			end
		end
	end
	return tData
end

-- 得到升级消耗后剩下的锦囊
function getDifferentData(table_1, table_2 )
	local data = {}
	for k,v in pairs(table_1) do
		local isIn = false
		for x,y in pairs(table_2) do
			if(tonumber(v.item_id) == tonumber(y))then
				isIn = true
				break
			end
		end
		if(isIn == false)then
			table.insert(data,v)
		end
	end
	-- 排序
	table.sort( data, BagUtil.pocketSortForBag )
	return data
end

--得到锦囊信息
function getPocketData( pItemId,pTempleId,pInfo )
	-- body
	local _desItemData = {}
	-- local data = getFiltersForItem()
	if(_itemData==nil)then
		_itemData = getFiltersForItem()
	end
	if(pTempleId==nil)then
		for k,v in pairs(_itemData)do
			if(tonumber(pItemId)==tonumber(v.item_id))then
				_desItemData = v
			end
		end
	else
		_desItemData = DB_Item_pocket.getDataById(pTempleId)
	end

	local descArray = nil
	if(pTempleId==nil)then
		descArray = string.split(_desItemData.itemDesc.level_effect,",")
	else
		descArray = string.split(_desItemData.level_effect,",")
	end
	local effectStr = nil
	for k,v in pairs(descArray) do
		local levelDescArray = string.split(v,"|")
		if(pTempleId==nil)then
			if((tonumber(_desItemData.va_item_text.pocketLevel)>=tonumber(levelDescArray[1])))then
				effectStr = DB_Awake_ability.getDataById(levelDescArray[2])
				return effectStr
			end
		else
			effectStr = DB_Awake_ability.getDataById(levelDescArray[2])
			return effectStr
		end
	end
end

function getPocketAttrByItem_id( item_id, itemLv, itmeData )
	local tData = {}
	if(table.isEmpty(itmeData))then
		itmeData = ItemUtil.getItemInfoByItemId(item_id)
		if( itmeData == nil )then
			-- 背包中没有 检查英雄身上是否有该锦囊
			itmeData = ItemUtil.getPocketInfoFromHeroByItemId(item_id)
		end
	end

	local t_arrt = getPocketAttrByTemplate_id(itmeData.item_template_id)
	for k,v in pairs(t_arrt) do
		-- 最终显示数值
		local fsLevel = tonumber(itemLv) or tonumber(itmeData.va_item_text.pocketLevel)
		local num = tonumber(v.baseData) + tonumber(v.growData) * fsLevel
		local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(tonumber(k),num)
		tData[k] = {}
		tData[k].desc = affixDesc
		tData[k].realNum = num
		tData[k].displayNum = displayNum
		-- 显示成长值
		local a,growNum,b = ItemUtil.getAtrrNameAndNum(tonumber(k),tonumber(v.growData))
		tData[k].growNum = growNum
	end

	return tData
end

function getChooseFSItemTable( ... )
	return chooseFSTable
end

-- 清空选择列表
function ClearChooseFSItemTable( ... )
	chooseFSTable = {}
end

-- 获得锦囊的能提供的总经验
function getUseExpByItemId( item_id )
	-- 总经验 + 基础经验
	local itmeData = getDesItemInfoByItemId(item_id)
	local exp = 0
	exp = tonumber(itmeData.va_item_text.pocketExp) + tonumber(itmeData.itemDesc.baseExp)
	return exp
end

--获得英雄＋背包里的所有锦囊 或 选择界面过滤掉该英雄自己的锦囊
function getFiltersForItem(p_hid,p_Choose)
	pChoose = p_Choose or false
	local bagInfo = DataCache.getBagInfo()

	local herosPockets = HeroUtil.getAllPocketOnHeros()

	local curData = {}
	local temData = {}
	--英雄背包
	if(p_hid==nil)then
		if(not table.isEmpty(herosPockets))then
			for k,v in pairs(herosPockets) do
				table.insert(temData,v)
			end
		end
	else
		local data = HeroUtil.getPocketByHid(p_hid)

		if(table.isEmpty(data))then
			for k,v in pairs(herosPockets) do
				table.insert(temData,v)
			end
		else
			local pTable = {}
			local rTable = {}
			for k,v in pairs(herosPockets)do
				table.insert(pTable,k)
			end
			for k,v in pairs(data)do
				table.insert(rTable,k)
			end

			local i = 1
			repeat
			    local j = 1
			    repeat
			        if pTable[i] == rTable[j] then
			            table.remove(pTable, i)
			            table.remove(rTable, j)
			            i = i - 1
			        else
			            j = j + 1
			        end
			    until j > #rTable
			    i = i + 1
			until i > #pTable

			for k,v in pairs(pTable)do
				table.insert(temData,herosPockets[v])
			end
		end
	end
	if(pChoose==true)then
		for k,v in pairs(bagInfo.pocket) do
			local data = DB_Item_pocket.getDataById(tonumber(v.item_template_id))
			if(tonumber(data.is_exp)~=1)then
				table.insert(curData, v)
			end
		end
	else
		for k,v in pairs(bagInfo.pocket) do
			local data = DB_Item_pocket.getDataById(tonumber(v.item_template_id))
			table.insert(curData, v)
		end
	end

	table.sort( temData, BagUtil.pocketSortForBag )

	for i=1,#temData do
		table.insert(curData, temData[i])
	end
	return curData
end

function getDesItemInfoByItemId( item_id )
	-- body
	if(_itemData==nil)then
		_itemData = getFiltersForItem()
	end

	for k,v in pairs(_itemData)do
		if(tonumber(item_id)==tonumber(v.item_id))then
			return v
		end
	end
end

-- 添加选择的锦囊itemId
function addChooseFSItemId( item_id )
	-- 判断这个锦囊有没有在选择列表里  有就从列表删除 没有就添加
	local isIn = false
	local pos = 0

	for k,v in pairs(chooseFSTable) do
		if(tonumber(v) == tonumber(item_id))then
			isIn = true
			pos = k
			break
		end
	end
	if(isIn)then
		table.remove(chooseFSTable,pos)
	else
		table.insert(chooseFSTable,item_id)
	end
end

-- 移除选择列表
function removeItemIdFromChooseFS( item_id )
	if(table.isEmpty(chooseFSTable))then
		return
	end
	for k,v in pairs(chooseFSTable) do
		if(tonumber(v) == tonumber(item_id))then
			table.remove(chooseFSTable,k)
		end
	end
end

-- 获得当前选择的经验能升得等级，当前结余exp，下级需要的exp,增加总经验值
-- id:升级表id
function getCurLvAndCurExpAndNeedExp( id, item_id )
	local itmeData = getDesItemInfoByItemId(item_id)
	local selfExp = tonumber(itmeData.va_item_text.pocketExp)
	local allExp = selfExp
	local addExp = 0
	for k,v in pairs(chooseFSTable) do
		local canUseExp = getUseExpByItemId(v)
		allExp = allExp + canUseExp
		addExp = addExp + canUseExp
	end
	local curLv,curExp,needExp = LevelUpUtil.getLvByExp(id,allExp)
	return curLv,curExp,needExp,addExp
end

function isOpen()
	-- body
	local open = false
	local normal_config = DB_Normal_config.getDataById(1)
    local limitLevel = string.split(normal_config.pocket_limit,",")
	if(UserModel.getHeroLevel()>=tonumber(limitLevel[1]))then
		open = true
	end
	return open
end

-------------------------------------- add by licong  start ----------------------------------------------------
--[[
	@des 	: 获得锦囊天赋配置数据
	@param 	: p_itemTid 模板id, p_curLv当前等级
	@return : num
--]]
function getPocketAbilityBDByTid( p_itemTid, p_curLv )
	local dbInfo = ItemUtil.getItemById(p_itemTid)
	local abilityStrTab = string.split(dbInfo.level_effect,",")
	local curLv = tonumber(p_curLv) or 0
	local curAbilityId = nil
	for i=1,#abilityStrTab do
		local temTab = string.split(abilityStrTab[i],"|")
		if( curLv < tonumber(temTab[1]) )then
			break
		else
			curAbilityId = temTab[2]
		end
	end
	require "db/DB_Awake_ability"
	local retData = DB_Awake_ability.getDataById(curAbilityId)
	return retData
end

--[[
	@des 	: 获得锦囊天赋配置数据
	@param 	: p_itemInfo宝物详细信息
	@return : num
--]]
function getPocketAbilityBDByItemInfo( p_itemInfo )
	local retData = getPocketAbilityBDByTid( p_itemInfo.item_template_id, p_itemInfo.va_item_text.pocketLevel )
	return retData
end

--[[
	@des 	: 获得锦囊天赋配置数据
	@param 	: p_itemId: 物品id
	@return : num
--]]
function getPocketAbilityBDByItemId( p_itemId )
	local itemInfo = ItemUtil.getItemInfoByItemId(p_itemId)
	if(itemInfo == nil)then
		itemInfo = ItemUtil.getPocketInfoFromHeroByItemId(p_itemId)
	end
	local retData = getPocketAbilityBDByItemInfo( itemInfo )
	return retData
end

--[[
	@des 	: 获得锦囊属性数据 基础 + 成长
	@param 	: p_itemTid 模板id, p_curLv当前等级
	@return : num
--]]
function getPocketAttrByTid( p_itemTid, p_curLv )
	local retData = {}
	local dbInfo = ItemUtil.getItemById(p_itemTid)
	local baseAttrStrTab = string.split(dbInfo.baseAtt,",")
	local growAttrStrTab = string.split(dbInfo.growAtt,",")
	local curLv = tonumber(p_curLv) or 0
	local curAbilityId = nil
	for i=1,#baseAttrStrTab do
		local temTab = string.split(baseAttrStrTab[i],"|")
		retData[tonumber(temTab[1])] = tonumber(temTab[2])
		if( curLv > 0)then
			local temTab2 = string.split(growAttrStrTab[i],"|")
			retData[tonumber(temTab[1])] = retData[tonumber(temTab[1])] + tonumber(temTab2[2]) * curLv
		end
	end
	return retData
end

--[[
	@des 	:获得锦囊属性数据 基础 + 成长
	@param 	: p_itemInfo宝物详细信息
	@return : num
--]]
function getPocketAttrByItemInfo( p_itemInfo )
	local retData = getPocketAttrByTid( p_itemInfo.item_template_id, p_itemInfo.va_item_text.pocketLevel )
	return retData
end

--[[
	@des 	: 获得锦囊属性数据 基础 + 成长
	@param 	: p_itemId: 物品id
	@return : num
--]]
function getPocketAttrByItemId( p_itemId )
	local itemInfo = ItemUtil.getItemInfoByItemId(p_itemId)
	if(itemInfo == nil)then
		itemInfo = ItemUtil.getPocketInfoFromHeroByItemId(p_itemId)
	end
	local retData = getPocketAttrByItemInfo( itemInfo )
	return retData
end
-------------------------------------- add by licong  end ----------------------------------------------------

---------------------------缓存战斗力数据用
-- 获取单一锦囊所有信息
function getSinglePocketInfo( p_itemId )
	local pocketInfo = HeroUtil.getAllPocketOnHeros()
	for k,v in pairs(pocketInfo)do
		if(tonumber(k)==tonumber(p_itemId))then
			return v
		end
	end
end

-- 获取单一锦囊战斗力
function countSinglePocketPower( p_itemId,p_templateId,p_info )
	local retArr = {}
	local pData = {}
	local bagInfo = DataCache.getBagInfo()
	-- 获取锦囊信息 在背包里的查背包 人身上的getSinglePocketInfo
	if(p_templateId~=nil)then
		for k,v in pairs(bagInfo.pocket) do
			if(tonumber(p_templateId)==tonumber(v.item_template_id))then
				pData = v
				break
			end
		end
		pData.itemDesc = {}
		pData.itemDesc = DB_Item_pocket.getDataById(p_templateId)
	else
		pData = getSinglePocketInfo(p_itemId)
	end
	-- end

	-- 基础属性和成长属性
	local baseArr = string.split(pData.itemDesc.baseAtt,",")
	local growArr = string.split(pData.itemDesc.growAtt,",")
	-- end

	-- 获取天赋id
	local descArray = string.split(pData.itemDesc.level_effect,",")
	local effectStr = nil
	local affixId = 0
	for k,v in pairs(descArray) do
		local levelDescArray = string.split(v,"|")
		if(tonumber(pData.va_item_text.pocketLevel)>=tonumber(levelDescArray[1]))then
			affixId = levelDescArray[2]
		end
	end
	-- end

	-- 基础属性＋等级增加属性＋天赋对应属性（基础属性可以和天赋增加属性对应上）
	local affixTable = HeroAffixModel.getAffixByTelentId(affixId)
	for i=1,table.count(baseArr) do
		local baseCache = string.split(baseArr[i],"|")
		local growCache = string.split(growArr[i],"|")
		local attStr = DB_Affix.getDataById(tonumber(baseCache[1]))
		local temArr = {}
		temArr.affixId = tonumber(baseCache[1])
		for k,v in pairs(affixTable) do
			if(tonumber(baseCache[1])==tonumber(k))then
				baseCache[2] = baseCache[2] + tonumber(v)
				affixTable[tonumber(k)]=0
				break
			end
		end
		temArr.num = baseCache[2] + growCache[2]*(tonumber(pData.va_item_text.pocketLevel))
		
		-- if(affixTable[temArr.affixId]==nil)then
		-- 	temArr.num = baseCache[2] + growCache[2]*(tonumber(pData.va_item_text.pocketLevel))
		-- else
		-- 	temArr.num = baseCache[2] + growCache[2]*(tonumber(pData.va_item_text.pocketLevel)) + tonumber(affixTable[temArr.affixId])
		-- 	affixTable[temArr.affixId] = 0
		-- end
		table.insert(retArr,temArr)
	end
	-- end

	-- （基础属性可以和天赋增加属性对应不上）
	for k,v in pairs(affixTable)do
		local newAffixTable = {}
		newAffixTable.affixId = tonumber(k)
		newAffixTable.num = tonumber(v)
		if(newAffixTable.num~=0)then
			table.insert(retArr,newAffixTable)
		end
	end
	-- end 最终返回总锦囊属性值
	return retArr
end

-- 计算锦囊战斗力数据（人身上最多两个锦囊 锦囊总战斗力要取和）
function countPocketFightPower( ... )
	-- body
	local formationInfo = {}
	local pocketcache = {}
	local ptable = {}
	--取出所有hid
	local real_formation = DataCache.getFormationInfo()
	for f_pos, f_hid in pairs(real_formation) do
        if(tonumber(f_hid)>0)then
            formationInfo[tonumber(f_pos)] = tonumber(f_hid)
        elseif(FormationUtil.isOpenedByPosition(f_pos))then
            formationInfo[tonumber(f_pos)] = 0
        else
            formationInfo[tonumber(f_pos)] = -1
        end
    end
    --取出每个hid身上所有锦囊的属性
    for formationPos, formationId in pairs(formationInfo)do
    	_pocketFightPowerInfo[formationId] = {}
    	if(tonumber(formationId)>0)then
    		local heroInfo = HeroModel.getHeroByHid(tonumber(formationId))
    		for pos,pInfo in pairs(heroInfo.equip.pocket)do
    			if(not table.isEmpty(pInfo))then
    				table.insert(_pocketFightPowerInfo[formationId],countSinglePocketPower(pInfo.item_id))
    			end
			end
    	end
    end
    --把两个锦囊的属性合在一块儿
    for formationPos, formationId in pairs(formationInfo)do
    	pocketcache[formationId] = {}
    	for k,v in pairs(_pocketFightPowerInfo[formationId]) do
    		for key,value in pairs(v)do
    			table.insert(pocketcache[formationId],value)
    		end
    	end
    end
    --相同affixid的属性值加在一起
    for formationPos, formationId in pairs(formationInfo)do
    	local x = 0
    	ptable[formationId] = {}
	    for k,v in pairs(pocketcache[formationId]) do
	    	if(ptable[formationId][tonumber(v.affixId)]==nil)then
	    		ptable[formationId][tonumber(v.affixId)]= v.num
	    	else
	    		ptable[formationId][tonumber(v.affixId)]= v.num+ptable[formationId][tonumber(v.affixId)]
	    	end
	    end
	    
	end
    return ptable
end

-- 强化修改战斗力数据
function upgradeChangePocketFightPower( p_hid,p_info )
	_pocketFightPowerInfo = countPocketFightPower()
end

-- 设置锦囊战斗力数据
function changePocketFightPower( p_hid,p_info,isAdd )
	if(table.isEmpty(_pocketFightPowerInfo))then
		_pocketFightPowerInfo = countPocketFightPower()
	else
		for k,v in pairs(p_info) do
			if(isAdd==true)then
				if(not table.isEmpty(_pocketFightPowerInfo[p_hid]))then
					for key,value in pairs(_pocketFightPowerInfo[p_hid])do
						-- 原来战斗力属性又该属性就加／没有该属性就将该属性添加
						if(tonumber(v.affixId)==tonumber(key))then
							_pocketFightPowerInfo[p_hid][tonumber(key)] = tonumber(v.num)+tonumber(value)
							break
						elseif(_pocketFightPowerInfo[p_hid][tonumber(v.affixId)]==nil)then
							_pocketFightPowerInfo[p_hid][tonumber(v.affixId)] = tonumber(v.num)
							break
						end
					end
				else
					_pocketFightPowerInfo[p_hid] = {}
					_pocketFightPowerInfo[p_hid][tonumber(v.affixId)] = tonumber(v.num)
				end
			else
				if(_pocketFightPowerInfo[p_hid]~=nil)then
					for key,value in pairs(_pocketFightPowerInfo[p_hid])do
						if(tonumber(v.affixId)==tonumber(key))then
							_pocketFightPowerInfo[p_hid][tonumber(key)] = tonumber(value)-tonumber(v.num)
							break
						end
					end
				end
			end
		end
	end
end

-- 获取锦囊战斗力数据
function getPocketFightPower( p_hid )
	local hid = tonumber(p_hid)
	-- body
	if(table.isEmpty(_pocketFightPowerInfo))then
		_pocketFightPowerInfo = countPocketFightPower()
	end
	return _pocketFightPowerInfo[hid]
end
-- end

-------------------------------------飞字用数据
-- 卸下
function removeAttrNumAndAtrrName( pData,pAdd,pHid )
	-- body
	local ptable = {1,4,5,9}
	local affixTable = nil
	if(pHid~=nil)then
		nextaffixTable = FightForceModel.getHeroDisplayAffix(pHid)
	end

	local retArr = {}
	for k,v in pairs(ptable)do
		local attStr = DB_Affix.getDataById(tonumber(v))
		local realNum = tonumber(nextaffixTable[tonumber(v)])-tonumber(PocketMainLayer._curAffixTable[tonumber(v)])
		if(tonumber(realNum)~=0)then
			local temArr = {}	
			temArr.txt = attStr.sigleName
			temArr.num = realNum
			table.insert(retArr,temArr)
		end
	end
	PocketMainLayer._curAffixTable = FightForceModel.getHeroDisplayAffix(pHid)
	return retArr
end
-- 装上
function newAttrNumAndAtrrName( pData )
	-- body
	local affixTable = nil

	local retArr = {}
	local baseArr = string.split(pData.itemDesc.baseAtt,",")
	local growArr = string.split(pData.itemDesc.growAtt,",")

	local descArray = string.split(pData.itemDesc.level_effect,",")
	local effectStr = nil
	local affixId = 0
	for k,v in pairs(descArray) do
		local levelDescArray = string.split(v,"|")
		if(tonumber(pData.va_item_text.pocketLevel)>=tonumber(levelDescArray[1]))then
			affixId = levelDescArray[2]
		end
	end
	local affixTable = HeroAffixModel.getAffixByTelentId(affixId)
	for i=1,table.count(baseArr) do
		local baseCache = string.split(baseArr[i],"|")
		local growCache = string.split(growArr[i],"|")
		local attStr = DB_Affix.getDataById(tonumber(baseCache[1]))
		local temArr = {}
		
		for k,v in pairs(affixTable) do
			if(tonumber(baseCache[1])==tonumber(k))then
				baseCache[2] = baseCache[2] + tonumber(v)
			end
		end

		temArr.txt = attStr.sigleName
		temArr.num = baseCache[2] + growCache[2]*(tonumber(pData.va_item_text.pocketLevel))

		table.insert(retArr,temArr)
	end

	return retArr
end
-- 原有锦囊基础上 上别的锦囊 需要对对应属性进行修改
function diffAttrNumAndAtrrName( pData,pOldInfo )
	local retArr = newAttrNumAndAtrrName( pData )
	--old
	local oldretArr = {}
	local oldbaseArr = string.split(pOldInfo.itemDesc.baseAtt,",")
	local oldgrowArr = string.split(pOldInfo.itemDesc.growAtt,",")

	local olddescArray = string.split(pOldInfo.itemDesc.level_effect,",")
	local oldeffectStr = nil
	local oldaffixId = 0
	for k,v in pairs(olddescArray) do
		local levelDescArray = string.split(v,"|")
		if(tonumber(pData.va_item_text.pocketLevel)>=tonumber(levelDescArray[1]))then
			oldaffixId = levelDescArray[2]
		end
	end
	local oldaffixTable = HeroAffixModel.getAffixByTelentId(oldaffixId)
	for i=1,table.count(oldbaseArr) do
		local baseCache = string.split(oldbaseArr[i],"|")
		local growCache = string.split(oldgrowArr[i],"|")
		local attStr = DB_Affix.getDataById(tonumber(baseCache[1]))
		local temArr = {}
		
		
		for k,v in pairs(oldaffixTable) do
			if(tonumber(baseCache[1])==tonumber(k))then
				baseCache[2] = baseCache[2] + tonumber(v)
			end
		end
		
		temArr.txt = attStr.sigleName
		temArr.num = baseCache[2] + growCache[2]*(tonumber(pOldInfo.va_item_text.pocketLevel))

		-- 显示成长值
		table.insert(oldretArr,temArr)
	end

	local tableCount = 0
	local retArrCount = table.count(retArr)
	local oldretArrCount = table.count(oldretArr)
	local newArrTable = {}
	if(retArrCount>=oldretArrCount)then
		local i = 1
		repeat
		    local j = 1
		    repeat
		    	local newTable = {}

		        if retArr[i]~=nil and oldretArr[j]~=nil and retArr[i].txt == oldretArr[j].txt then
		        	newTable.txt = retArr[i].txt
		        	newTable.num = retArr[i].num-oldretArr[j].num
		        	table.insert(newArrTable,newTable)
		            table.remove(retArr, i)
		            table.remove(oldretArr, j)
		            if(i>1)then
		            	i = i - 1
		            end
		        else
		            j = j + 1
		        end
		    until j > #oldretArr
		    i = i + 1
		until i > #retArr
		for k,v in pairs(retArr)do
			table.insert(newArrTable,v)
		end
	else
		local i = 1
		repeat
		    local j = 1
		    repeat
		    	local newTable = {} 
		        if oldretArr[i]~=nil and retArr[j]~=nil and  retArr[j].txt == oldretArr[i].txt then
		        	newTable.txt = retArr[j].txt
		        	newTable.num = retArr[j].num-oldretArr[i].num
		        	table.insert(newArrTable,newTable)
		            table.remove(retArr, i)
		            table.remove(oldretArr, j)
		            if(i>1)then
		            	i = i - 1
		            end
		        else
		            j = j + 1
		        end
		    until j > #retArr
		    i = i + 1
		until i > #oldretArr
		for k,v in pairs(oldretArr)do
			v.num = -(v.num)
			table.insert(newArrTable,v)
		end
	end

	local endTable = {}
	for k,v in pairs(newArrTable) do
		if(v.num~=0)then
			table.insert(endTable,v)
		end
	end
	-- 显示成长值
	return endTable
end
-- end




