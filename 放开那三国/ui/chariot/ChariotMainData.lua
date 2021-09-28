-- FileName: ChariotMainData.lua
-- Author: lgx
-- Date: 2016-06-27
-- Purpose: 战车数据处理中心

module("ChariotMainData", package.seeall)

require "db/DB_Item_warcar"
require "db/DB_Normal_config"
require "db/skill"
require "script/utils/LuaUtil"
require "script/ui/chariot/illustrate/ChariotIllustrateData"
require "script/ui/bag/BagUtil"

local _chariotAttrInfo 	= nil -- 战车属性加成信息

--[[
	@desc 	: 初始化战车配置信息
	@param  : pChariot 后端返回单个的战车信息 pGid 背包格子id
    @return : 处理后的单个的战车信息
--]]
function parseNetChariot( pChariot, pGid )
	pChariot.itemDesc = ItemUtil.getItemById(pChariot.item_template_id)
	pChariot.gid = pGid
	return pChariot
end

--[[
	@desc 	: 获取战车是否装备上了
	@param  : pItemId 战车物品id
    @return : bool 是否装备
--]]
function isEquipedChariotByItemId( pItemId )
	local isEquiped = false
	local chariotEquipInfo = getEquipChariotInfo()
	if (not table.isEmpty(chariotEquipInfo)) then
		for k,v in pairs(chariotEquipInfo) do
			if (tonumber(v.item_id) == tonumber(pItemId) ) then
				isEquiped = true
				break
			end
		end
	end
	return isEquiped
end

--[[
	@desc 	: 根据战车物品id获取战车装备位置
	@param  : pItemId 战车物品id
    @return : 战车装备位置 没有就返回 0 
--]]
function getChariotPosByItemId( pItemId )
	local equipPos = 0
	if (pItemId and pItemId > 0) then
		local chariotEquipInfo = getEquipChariotInfo()
		if (not table.isEmpty(chariotEquipInfo)) then
			for k,v in pairs(chariotEquipInfo) do
				if (tonumber(v.item_id) == tonumber(pItemId) ) then
					equipPos = tonumber(k)
					break
				end
			end
		end
	end
	return equipPos
end

--[[
	@desc   : 获取装备战车信息
    @param  : 
    @return : 
--]]
function getEquipChariotInfo()
	require "script/model/hero/HeroModel"
	local chariotEquipInfo = HeroModel.getMasterHeroChariotInfo()
	return chariotEquipInfo
end

--[[
	@desc   : 根据位置获取装备战车信息
    @param  : pPos 装备位置
    @return : 
--]]
function getEquipChariotInfoByPos( pPos )
	local equipChariotInfo = getEquipChariotInfo()
	local retData = nil
	if (not table.isEmpty(equipChariotInfo)) then
		retData = equipChariotInfo[pPos] or equipChariotInfo[tostring(pPos)]
    end
	return retData
end

--[[
	@desc 	: 获取可以装备的战车
	@param 	: pPos 装备位置
	@return : 
--]]
function getCanEquipChariotByPos( pPos )
 	local retData = {}

 	local needLevel,needType = getCanEquipLvAndTypeByPos(pPos)

	-- 背包里的
	local bagInfo = DataCache.getBagInfo()
	for k_itemId,v_info in pairs(bagInfo.chariotBag) do
		if (v_info.itemDesc.warcar_type == needType) then
			table.insert(retData,v_info)
		end
	end
	-- 排序
	table.sort( retData, BagUtil.sortChariotForBag )

	return retData
end

--[[
	@desc 	: 更新战车装备信息
	@param 	: pChariot 战车信息 pPos 位置
	@return : 
--]]
function updateChariotInfoByPos( pChariot, pPos )
	require "script/model/hero/HeroModel"
	local pos = tonumber(pPos)
	if ( pChariot ) then
		-- 装备或更换
		-- 更新HeroModel的数据
		HeroModel.changeMasterHeroChariotByPos(pos,pChariot)
	else
		-- 卸下
		-- 更新HeroModel的数据
		HeroModel.changeMasterHeroChariotByPos(pos,nil)
	end

	-- 刷新装备战车的战力加成
	getChariotAttrInfo(true)
end

--[[
	@desc 	: 更新战车强化等级
	@param 	: pCurLv 强化等级 pPos 位置
	@return :
--]]
function updateChariotEnforceLvByPos( pCurLv, pPos )
	local pos = tonumber(pPos)
	local chariotInfo = getEquipChariotInfoByPos(pos)
	if (chariotInfo) then
		chariotInfo.va_item_text.chariotEnforce = pCurLv
	end

	require "script/model/hero/HeroModel"
	-- 更新HeroModel的数据
	HeroModel.changeMasterHeroChariotByPos(pos,chariotInfo)

	-- 刷新装备战车的战力加成
	getChariotAttrInfo(true)
end

--[[
	@desc 	: 获取战车装备的位置数量
	@param 	: 
    @return	: 战车装备的位置数量
--]]
function getCanEquipPosNum()
	-- DB_Normal_config 新增字段处理 装备战车位置及等级  
	-- 1|1|62,2|2|80 位置|类型|级别
	local normalConfigDb = DB_Normal_config.getDataById(1)
	local warcarLvTab = parseField(normalConfigDb.warcar_lv,2)
	local posNum = table.count(warcarLvTab)

	-- print("-------------getCanEquipPosNum--------------")
	-- print_t(warcarLvTab)
	-- print("posNum => ",posNum)

	return posNum
end

--[[
	@desc 	: 获取战车开启装备的位置及等级
	@param 	: pPos 装备位置
    @return	: 开启装备战车位置及等级
--]]
function getCanEquipLvAndTypeByPos( pPos )
	-- DB_Normal_config 新增字段处理 装备战车位置及等级  
	-- 1|1|62,2|2|80 位置|类型|级别
	local normalConfigDb = DB_Normal_config.getDataById(1)
	-- 传 2 如果是 1|1|62 只开一个位置，也以二维数组返回
	local warcarLvTab = parseField(normalConfigDb.warcar_lv,2)
	local needType = 0
	local needLevel = 0
	local chariotPosInfo = warcarLvTab[pPos]
	if (chariotPosInfo ~= nil) then
		needType = chariotPosInfo[2]
		needLevel = chariotPosInfo[3]
	end

	-- print("-------------getCanEquipLvAndTypeByPos--------------")
	-- print_t(warcarLvTab)
	-- print("needLevel,needType => ",needLevel,needType)

	return needLevel,needType
end

--[[
	@desc 	: 获取战车强化消耗银币和物品
	@param 	: pTid 战车Tid
	@return : silverNum,needTid,needNum
--]]
function getEnforeCostByTidAndLv( pTid, pLevel )
	local enforeCost = DB_Item_warcar.getDataById(pTid).enforeCost
	local enforeCostTab = parseField(enforeCost,2)
	local retData = enforeCostTab[pLevel+1] or {}
	local silverNum,needTid,needNum = retData[1] or 0,retData[2] or 0,retData[3] or 0
	return silverNum,needTid,needNum
end

--[[
	@desc	: 传入战车获取战车属性加成信息
	@param	: pInfo 战车信息
	@return	: table 战车属性加成信息
--]]
function getChariotAttrByInfo( pInfo )
	local chariotTid = tonumber(pInfo.item_template_id)
	local chariotLv = tonumber(pInfo.va_item_text.chariotEnforce)
	local attrInfo = getChariotAttrInfoByTidAndLv(chariotTid,chariotLv)
	return attrInfo
end

--[[
	@desc	: 获取战车属性加成信息
	@param	: pTid 战车Tid pLevel 战车等级
	@return	: table 战车属性加成信息
--]]
function getChariotAttrInfoByTidAndLv( pTid, pLevel )
	local chariotDB = DB_Item_warcar.getDataById(pTid)
	local attrInfo  = {}
	-- 等级默认为 1
	local chariotLv = pLevel or 0
	if (chariotDB) then
		-- 基础属性
		local baseAttTab = parseField(chariotDB.baseAtt,2)

		-- print("---------------getChariotAttrInfoByTidAndLv baseAtt---------------")
		-- print_t(baseAttTab)
		-- print("---------------getChariotAttrInfoByTidAndLv baseAtt---------------")

		for i,v in ipairs(baseAttTab) do
			local attrId = tonumber(v[1])
			local attrNum = tonumber(v[2])
			local attrTab = {}
			attrTab.num = attrNum
			-- 记录属性排序
			attrTab.order = i
			attrInfo[attrId] = attrTab
		end

		-- 成长属性
		if (chariotLv > 0) then
			local growAttTab = parseField(chariotDB.growAtt,2)

			-- print("---------------getChariotAttrInfoByTidAndLv growAtt---------------")
			-- print_t(growAttTab)
			-- print("---------------getChariotAttrInfoByTidAndLv growAtt---------------")

			for i,v in ipairs(growAttTab) do
				local attrId = tonumber(v[1])
				local attrNum = tonumber(v[2]) * chariotLv
				local attrTab = {}
				attrTab.num = attrNum
				-- 记录属性排序
				attrTab.order = i
				if (attrInfo[attrId] == nil) then
					attrInfo[attrId] = attrTab
				else
					attrTab.num = attrInfo[attrId].num + attrNum
					attrInfo[attrId] = attrTab
				end
			end
		end
	else
		print("getChariotAttrInfoByTidAndLv pTid error!")
	end

	-- print("---------------getChariotAttrInfoByTidAndLv---------------")
	-- print_t(attrInfo)
	-- print("---------------getChariotAttrInfoByTidAndLv---------------")

	return attrInfo
end

--[[
	@desc	: 获取排序过的战车属性加成信息
	@param	: pTid 战车Tid pLevel 战车等级
	@return	: table 战车属性加成信息
--]]
function getSortedChariotAttrInfoByTidAndLv( pTid, pLevel )
	local attrInfo = getChariotAttrInfoByTidAndLv(pTid,pLevel)
	local retData = {}
	for k,v in pairs(attrInfo) do
		v.id = tonumber(k)
		table.insert(retData,v)
	end

	-- 策划说 属性要按表里配的顺序 攻击 生命 物防 法防
	table.sort(retData,function (v1,v2)
    	return v1.order < v2.order
	end)

	return retData
end

--[[
	@desc 	: 计算战车图鉴属性加成信息 给全体上阵武将加
	@param 	: 
	@return : table {id = value} 全体上阵武将加成属性加成信息
--]]
function calculateChariotAttrInfo()
	local retData = {}
	if DataCache.getSwitchNodeState(ksSwitchChariot, false) then
		local equipChariotInfo = getEquipChariotInfo()
		if ( not table.isEmpty(equipChariotInfo) ) then
			for k,v in pairs(equipChariotInfo) do
				local tid = tonumber(v.item_template_id)
				local level = tonumber(v.va_item_text.chariotEnforce)
				local attrTab = getChariotAttrInfoByTidAndLv(tid,level)
				for attrId,attrNum in pairs(attrTab) do
					if (retData[attrId] == nil) then
						retData[attrId] = attrNum.num
					else
						retData[attrId] = retData[attrId] + attrNum.num
					end
				end
			end
		end
	end
	return retData
end

--[[
	@desc	: 获取战车属性加成信息
	@param	: pIsForce 强制重新计算
	@return : table {id = value} 战车属性加成信息
--]]
function getChariotAttrInfo( pIsForce )
	if (pIsForce or _chariotAttrInfo == nil) then
		_chariotAttrInfo = calculateChariotAttrInfo()
	end

	-- print("-----------------------getChariotAttrInfo---------------------")
	-- print_t(_chariotAttrInfo)
	-- print("-----------------------getChariotAttrInfo---------------------")
	
	return _chariotAttrInfo
end


--[[
	@desc	: 获取战车所有属性加成信息(包括图鉴、组合、装备上的)
    @param	: pIsForce 强制重新计算
    @return	: table {id = value} 战车所有属性加成信息
—]]
function getChariotAllAttrInfo( pIsForce )
	local retData = {}

	-- 战车图鉴加成
	local bookAttr = ChariotIllustrateData.getChariotBookAttrInfo(pIsForce)
	margeAttrTable(retData,bookAttr)

	-- 战车组合加成
	local suitAttr = ChariotIllustrateData.getChariotSuitAttrInfo(pIsForce)
	margeAttrTable(retData,suitAttr)

	-- 装备战车加成
	local equipAttr = getChariotAttrInfo(pIsForce)
	margeAttrTable(retData,equipAttr)

	print("-----------------------getChariotAllAttrInfo---------------------")
	print_t(retData)
	print("-----------------------getChariotAllAttrInfo---------------------")

	return retData
end

--[[
	@desc	: 属性加成合并
    @param	: pRetAttr 合并后的属性加成信息
    @param	: pAttr 要合并进去的属性加成
    @return	:   
—]]
function margeAttrTable( pRetAttr, pAttr )
	for attrId,attrNum in pairs(pAttr) do
		if (pRetAttr[attrId] == nil) then
			pRetAttr[attrId] = attrNum
		else
			pRetAttr[attrId] = pRetAttr[attrId] + attrNum
		end
	end
end

------------------------------- DB 配置相关 -------------------------------
--[[
	@desc 	: 获取战车技能描述
	@param 	: pSkillId 战车技能id
	@return : 
--]]
function getSkillNameAndDescById( pSkillId )
	local skillDB = skill.getDataById(tonumber(pSkillId))
	local skillNeme = skillDB.name or ""
	local skillDesc = skillDB.des or ""
	return skillNeme,skillDesc
end


--[[
	@desc 	: 获取战车表配置
	@param 	: pTid 战车Tid
	@return : 
--]]
function getChariotDBByTid( pTid )
	local chariotDB = DB_Item_warcar.getDataById(pTid)
	return chariotDB
end

--[[
	@desc 	: 获取战车类型
	@param 	: pTid 战车Tid
	@return : 
--]]
function getChariotTypeByTid( pTid )
	local warcarType = DB_Item_warcar.getDataById(pTid).warcar_type
	return warcarType
end

--[[
	@desc 	: 获取战车最大等级
	@param 	: pTid 战车Tid
	@return : 
--]]
function getMaxLevelByTid( pTid )
	local maxlevel = DB_Item_warcar.getDataById(pTid).maxlevel
	return maxlevel
end

