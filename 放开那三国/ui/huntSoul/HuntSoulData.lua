-- FileName: HuntSoulData.lua 
-- Author: Li Cong 
-- Date: 14-2-11 
-- Purpose: function description of module 


module("HuntSoulData", package.seeall)
require "script/ui/item/ItemUtil"
require "script/utils/LevelUpUtil"
require "script/model/user/UserModel"
require "script/ui/bag/BagUtil"

local placeId = nil
local chooseFSTable = {}

-- 得到背包里的战魂数据
function getFightSoulByBag( ... )
	local bagInfo = DataCache.getBagInfo()
	return bagInfo.fightSoul or {}
end

-- 得到战魂背包的显示数据
-- 战魂背包 和 武将装备的
function getFSBagShowData( ... )
	local data = {}
	local temp_data= {}
	local bagInfo = DataCache.getBagInfo()
	
	for k,v in pairs(bagInfo.fightSoul) do
		table.insert(data, v)
	end
	table.sort( data, BagUtil.fightSoulSort )
	local on_equips = HeroUtil.getAllFightSoulOnHeros()
	local arr = {}
	for k,v in pairs(on_equips) do
		table.insert(arr,v)
	end
	table.sort( arr, BagUtil.fightSoulSort )
	for k, v in pairs(arr) do
		table.insert(data, v)
	end
	return data
end

-- 得到背包里的可被吃掉的战魂数据
-- desItemId:要喂养的战魂itemId
function getBagInfoWithOutDesItem( desItemId )
	local data = {}
	local bagInfo = DataCache.getBagInfo()
	for k,v in pairs(bagInfo.fightSoul) do
		if(tonumber(v.item_id) ~= tonumber(desItemId) and tonumber(v.itemDesc.quality) < 6 )then 
			table.insert(data,v)
		end
	end
	table.sort( data, BagUtil.fightSoulSort )
	return data
end

-- 解析战魂属性
--[[ 以属性id为key  属性值为value
	arr = {
		"1" = 10,
		"2" = 20,
	}
--]]
function getAttrIdAndValue( str_arr )
	-- print("str_arr ", str_arr)
	local arrData = {}
	local arr_1 = string.split(str_arr, ",")
	for k,v in pairs(arr_1) do
		local arr_2 = string.split(v, "|")
		-- 以属性id为key  属性值为value
		arrData[arr_2[1]] = arr_2[2]
	end
	return arrData
end


--获得表配置的战魂的属性id，基础值，成长值
function getFightSoulAttrByTemplate_id( template_id )
	local tData = {}
	local itemData = ItemUtil.getItemById(template_id)
	-- 基础值
	local arr_1 = getAttrIdAndValue(itemData.baseAtt)
	-- print("---------------1-----------")
	-- print_t(arr_1)
	-- 成长值
	local arr_2 = getAttrIdAndValue(itemData.growAtt)
	-- print("--------------2------------")
	-- print_t(arr_2)
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

-- 获得战魂的属性 key:属性 value: desc 描述,displayNum 数值
-- item_id: 战魂itemid
-- itemLv: 战魂等级 默认为真实等级
function getFightSoulAttrByItem_id( item_id, itemLv, itmeData )
	local tData = {}
	if(table.isEmpty(itmeData))then
		itmeData = ItemUtil.getItemInfoByItemId(item_id)
		if( itmeData == nil )then
			-- 背包中没有 检查英雄身上是否有该战魂
			itmeData = ItemUtil.getFightSoulInfoFromHeroByItemId(item_id)
		end
	end

	local t_arrt = getFightSoulAttrByTemplate_id(itmeData.item_template_id)
	-- print("--------------------------")
	-- print_t(t_arrt)
	for k,v in pairs(t_arrt) do
		-- 最终显示数值
		local fsLevel = tonumber(itemLv) or tonumber(itmeData.va_item_text.fsLevel)
		local num = tonumber(v.baseData) + tonumber(v.growData) * fsLevel
		local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(tonumber(k),num)
		tData[k] = {}
		tData[k].desc = affixDesc
		tData[k].realNum = num
		tData[k].displayNum = displayNum
		-- 显示成长值
		local a,growNum,b = ItemUtil.getAtrrNameAndNum(tonumber(k),tonumber(v.growData))
		tData[k].growNum = growNum
		tData[k].growRealNum = tonumber(v.growData)
	end
	
	return tData
end


-- 获得战魂的基础属性描述 key:属性 value: desc 描述,displayNum 数值
function getFSoulAttrBaseDescByTempId( template_id )
	local tData = {}
	local t_arrt = getFightSoulAttrByTemplate_id(template_id)
	-- print("--------------------------")
	-- print_t(t_arrt)
	for k,v in pairs(t_arrt) do
		-- 最终显示数值
		local num = tonumber(v.baseData) 
		local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(tonumber(k),num)
		tData[k] = {}
		tData[k].desc = affixDesc
		tData[k].displayNum = displayNum
	end
	return tData
end
-- 获得战魂的基础属性描述 key:属性 value: desc 描述,displayNum 数值
function getFSoulAttrBaseDescByItemInfo( p_itemInfo )
	local tData = {}
	local t_arrt = getFightSoulAttrByTemplate_id(p_itemInfo.item_template_id)
	local fsLevel = 1
	if(p_itemInfo and p_itemInfo.va_item_text and p_itemInfo.va_item_text.fsLevel)then
		fsLevel = tonumber(p_itemInfo.va_item_text.fsLevel)
	end
	-- print("--------------------------")
	-- print_t(t_arrt)
	for k,v in pairs(t_arrt) do
		-- 最终显示数值
		local num = tonumber(v.baseData) + tonumber(v.growData) * fsLevel
		local affixDesc, displayNum, realNum = ItemUtil.getAtrrNameAndNum(tonumber(k),num)
		tData[k] = {}
		tData[k].desc = affixDesc
		tData[k].displayNum = displayNum
	end
	return tData
end
--------------------------------------------升级战魂数据操作--------------------------------------------------

-- 通过item_id得到目标战魂的信息
function getDesItemInfoByItemId( item_id )
	-- print("item_id:",item_id)
	local itemData = ItemUtil.getItemInfoByItemId(item_id)
	if( itemData == nil )then
		-- 背包中没有 检查英雄身上是否有该战魂
		itemData = ItemUtil.getFightSoulInfoFromHeroByItemId(item_id)
	end
	if( table.isEmpty(itemData.itemDesc))then
		itemData.itemDesc = ItemUtil.getItemById(itemData.item_template_id)
	end
	-- print("itemData -- ")
	-- print_t(itemData)
	return itemData
end

-- 计算战魂可升级最大上限
-- 战魂最大可强化到的等级=min【int（（强化基础等级+强化等级系数*玩家等级/100）/5）*5，最大强化等级】
function getMaxLvByFSTempId( item_template_id, p_userLv )
	local itemData = ItemUtil.getItemById(item_template_id)
	local maxLv = tonumber(itemData.maxLevel)
	local baseLv = tonumber(itemData.baseMaxLevelArg)
	local lvArg = tonumber(itemData.maxLevelArg)*0.01
	local userLv = nil
	if(p_userLv)then
		userLv = tonumber(p_userLv)
	else
		userLv = UserModel.getHeroLevel()
	end
	local retLv = 0
	local data1 = math.floor((baseLv+(lvArg*userLv))/5)*5
	-- print("---------------------------------------------",data1,maxLv)
	retLv = math.min(data1, maxLv)
	return math.floor(retLv)
end

-- 清空选择列表
function ClearChooseFSItemTable( ... )
	chooseFSTable = {}
end
-- 得到选择的战魂列表
function getChooseFSItemTable( ... )
	return chooseFSTable
end

-- 添加选择的战魂itemId
function addChooseFSItemId( item_id )
	-- 判断这个战魂有没有在选择列表里  有就从列表删除 没有就添加
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
	-- print("addddddddd ***")
	-- print_t(chooseFSTable)
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

-- 获得战魂的能提供的总经验
function getUseExpByItemId( item_id )
	-- 总经验 + 基础经验
	local itmeData = getDesItemInfoByItemId(item_id)
	local exp = 0
	-- print("baseExp----- ",tonumber(itmeData.itemDesc.baseExp))
	exp = tonumber(itmeData.va_item_text.fsExp) + tonumber(itmeData.itemDesc.baseExp)
	return exp
end

-- 获得当前选择的经验能升得等级，当前结余exp，下级需要的exp,增加总经验值
-- id:升级表id
function getCurLvAndCurExpAndNeedExp( id, item_id )
	local itmeData = getDesItemInfoByItemId(item_id)
	local selfExp = tonumber(itmeData.va_item_text.fsExp)
	local allExp = selfExp
	local addExp = 0
	for k,v in pairs(chooseFSTable) do
		local canUseExp = getUseExpByItemId(v)
		allExp = allExp + canUseExp
		addExp = addExp + canUseExp
	end
	-- print("**id",id)
	-- print("**allExp",allExp)
	local curLv,curExp,needExp = LevelUpUtil.getLvByExp(id,allExp)
	return curLv,curExp,needExp,addExp
end

-- 得到升级消耗后剩下的战魂
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
	table.sort( data, BagUtil.fightSoulSort )
	return data
end

----------------------------------------猎魂数据-----------------------------------------------
-- 得到当前场景id
function getHuntPlaceId( ... )
	return tonumber(placeId)
end

-- 设置当前场景id
function setHuntPlaceId( id )
	placeId = tonumber(id)
end

--得到召唤神龙费用
function getOpenShenLongCost( )
	require "db/DB_Vip"
	local data = DB_Vip.getDataById(UserModel.getVipLevel()+1)
	-- print("++++++ data:")
	-- print_t(data)
	-- print(data.goldOpenExplore)
	local costArr = string.split(data.goldOpenExplore, "|")
	-- print_t(costArr)
	local placeId = tonumber(costArr[1])
	local goldNum = tonumber(costArr[2])
	local itemId = tonumber(costArr[3])
	return placeId,goldNum,itemId
end

-- 根据场景id的到该场景费用
function getCostByPlaceId( id )
	require "db/DB_Huntsoul"
	local data = DB_Huntsoul.getDataById(tonumber(id))
	local num = tonumber(data.cost)
	return num
end

-- 得到场景最大花费 15万
function getMaxCostByNum( p_huntNum )
	-- require "db/DB_Huntsoul"
	-- local data = DB_Huntsoul.getDataById(table.count(DB_Huntsoul.Huntsoul))
	-- local num = tonumber(data.cost)
	local num = 0
	if(p_huntNum == 10)then
		num = 150000
	elseif(p_huntNum == 50)then
		num = 150000*5
	else
		num = 150000
	end
	return num
end

-- 猎魂界面用的背包数据
-- 按itemid小到大排序 
function getFSBagSortByItemId( ... )
	local bagInfo = DataCache.getBagInfo()
	local fsBagInfo = bagInfo.fightSoul or {}
	local function fnSortFun( a, b )
        return tonumber(a.item_id) < tonumber(b.item_id)
    end 
	table.sort( fsBagInfo, fnSortFun )
	return fsBagInfo
end

-- 得到猎十次是否开启
function getIsOpenHuntTen( ... )
	require "db/DB_Vip"
	-- 需要的vip
	local needVip = 0
	local needLeve = 0
	local i = 1
	for k,v in pairs(DB_Vip.Vip) do
        local vInfo = DB_Vip.getDataById(tostring(i))
        local strArr = string.split(vInfo.tenthHunt, "|")
        -- 1是开启0是未开启
        if(tonumber(strArr[1]) == 1)then
        	needVip = tonumber(vInfo.level)
        	needLeve = tonumber(strArr[2])
            break
        end
        i = i+1
    end

    -- 是否开启
    local isOpen = false
    if(UserModel.getVipLevel() >= needVip or  UserModel.getHeroLevel() >= needLeve )then
    	isOpen = true
    else
    	isOpen = false
    end

	return isOpen, needLeve, needVip
end

-- 得到猎50次是否开启
function getIsOpenHuntFifty( ... )
	require "db/DB_Vip"
	-- 需要的vip
	local needVip = 0
	local needLeve = 0
	local i = 1
	for k,v in pairs(DB_Vip.Vip) do
        local vInfo = DB_Vip.getDataById(tostring(i))
        local strArr = string.split(vInfo.FiftiethHunt, "|")
        -- 1是开启0是未开启
        if(tonumber(strArr[1]) == 1)then
        	needVip = tonumber(vInfo.level)
        	needLeve = tonumber(strArr[2])
            break
        end
        i = i+1
    end

    -- 是否开启
    local isOpen = false
    if(UserModel.getVipLevel() >= needVip or  UserModel.getHeroLevel() >= needLeve )then
    	isOpen = true
    else
    	isOpen = false
    end

	return isOpen, needLeve, needVip
end

-- 召唤十次 提示面板数据解析
-- p_items 召唤十次后返回的原始数据
function getDataForCallTenTip( p_items )
	if( p_items == nil )then
		return {}
	end
	local retTab = {}
	for k,v in pairs(p_items) do
		local temTab = {}
		for item_id, template_id in pairs(v) do
			local tab = {}
			tab.item_id = tonumber(item_id)
			tab.item_template_id = tonumber(template_id)
			table.insert(temTab,tab)
		end
		-- 按获得战魂的itemid从小到大排序
		local function fnSortFun( a, b )
	        return tonumber(a.item_id) < tonumber(b.item_id)
	    end 
		table.sort( temTab, fnSortFun )
		retTab[k] = temTab
	end
	return retTab
end

--猎魂五十次 提示面板数据解析
-- p_items 召唤十次后返回的原始数据
function getDataForHuntFiftyTip( p_items )
	if( p_items == nil )then
		return {}
	end
	local retTab = {}
	for item_id, template_id in pairs(p_items) do
		local tab = {}
		tab.item_id = tonumber(item_id)
		tab.item_template_id = tonumber(template_id)
		table.insert(retTab,tab)
	end
	-- 按获得战魂的itemid从小到大排序
	local function fnSortFun( a, b )
        return tonumber(a.item_id) < tonumber(b.item_id)
    end 
	table.sort( retTab, fnSortFun )

	return retTab
end

--[[
	@des 	: 得到猎魂掉材料等级
	@param 	: 
	@return :
--]]
function getSoulMaterialLv()
	require "db/DB_Normal_config"
	local data = DB_Normal_config.getDataById(1)
	return tonumber(data.fightsoul_level)
end

--[[
	@des 	: 得到战魂提供的属性
	@param 	: p_itemInfo info
	@return :
--]]
function getSoulFightForce( p_itemInfo )
	local retTab = {}
	if( table.isEmpty(p_itemInfo.itemDesc))then
		p_itemInfo.itemDesc = ItemUtil.getItemById(p_itemInfo.item_template_id)
	end
	-- 基础属性
	local t_arrt = getFightSoulAttrByTemplate_id(p_itemInfo.item_template_id)
	for k,v in pairs(t_arrt) do
		retTab[k] = tonumber(v.baseData) + tonumber(v.growData) * tonumber(p_itemInfo.va_item_text.fsLevel)
	end
	-- 精炼属性
	-- 当前洗练等级
	local curEvolveLv = 0
	if( not table.isEmpty(p_itemInfo.va_item_text) and p_itemInfo.va_item_text.fsEvolve )then
		curEvolveLv = tonumber(p_itemInfo.va_item_text.fsEvolve)
	end
	local xishu = 0
	if(p_itemInfo.itemDesc.upgrade_affix ~= nil)then
		xishu = tonumber(p_itemInfo.itemDesc.upgrade_affix)
	end
	local evolvXishuNum = xishu/10000*curEvolveLv
	for k,v in pairs(retTab) do
		retTab[k] = retTab[k] + math.floor(retTab[k] * evolvXishuNum)
	end
	return retTab
end


--[[
	@des 	: 得到是否可以自动选择四星级战魂
	@param 	: 
	@return :
--]]
function getIsChooseFourStarSoul()
	require "db/DB_Normal_config"
	local data = DB_Normal_config.getDataById(1)
	local retData = false
	local myLv = UserModel.getHeroLevel()
	if( myLv >= tonumber(data.fs_4star))then
		retData = true
	end
	return retData
end

---------------------------------------------------- 极速猎魂 ----------------------------------------------------------------
--[[
	@des 	: 得到是否开启急速猎魂
	@param 	: 
	@return :是否开启，可见等级，使用等级
--]]
function getIsOpenFlyHunt()
	local retIsOpen = false
	require "db/DB_Normal_config"
	local data = DB_Normal_config.getDataById(1)
	local strTab = string.split(data.superfightsoul, "|")
	local seeLv = tonumber(strTab[1])
	local useLv = tonumber(strTab[2])
	if( UserModel.getHeroLevel() >= useLv )then
		retIsOpen = true
	end
	return retIsOpen,seeLv,useLv
end

--[[
	@des 	: 得到每一档数据
	@param 	: p_id 档次
	@return :
--]]
function getFlyCostById(p_id)
	local retData = 0
	require "db/DB_Normal_config"
	local data = DB_Normal_config.getDataById(1)
	local strTab = string.split(data.supfightsoul_silver, ",")
	for i=1,#strTab do
		local temTab = string.split(strTab[i], "|")
		if( tonumber(temTab[1]) == tonumber(p_id) )then
			retData = tonumber(temTab[2])
			break
		end
	end
	return retData
end

--[[
	@des 	: 得到每一档数据
	@param 	: p_id 档次
	@return :
--]]
function getSortData( p_items )
	local retTab = {}
	for k,v_id in pairs(p_items) do
		table.insert(retTab,v_id)
	end

	local sortFun = function( p_id1, p_id2 )
		local data1 = ItemUtil.getItemById(p_id1)
		local data2 = ItemUtil.getItemById(p_id2)
		return tonumber(data1.quality) > tonumber(data2.quality)
	end 
	table.sort(retTab,sortFun)
	return retTab
end


--[[
	@des 	: 得到可以勾选5星的等级
	@param 	: 
	@return :是否开启，使用等级，
--]]
function getIsOpenChooseFive()
	local retIsOpen = false
	require "db/DB_Normal_config"
	local data = DB_Normal_config.getDataById(1)
	local useLv = tonumber(data.cancel_5fs)
	if( UserModel.getHeroLevel() >= useLv )then
		retIsOpen = true
	end
	return retIsOpen,useLv
end

--[[
	@des 	: 得到可以进阶红色需要的等级
	@param 	: 
	@return :num
--]]
function getDevelopRedNeedLv()
	require "db/DB_Normal_config"
	local data = DB_Normal_config.getDataById(1)
	local retData = data.fightsoul_red or 0
	return retData
end













