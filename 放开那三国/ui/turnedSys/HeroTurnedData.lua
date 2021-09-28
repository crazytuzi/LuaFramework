-- FileName: HeroTurnedData.lua
-- Author: lgx
-- Date: 2016-09-13
-- Purpose: 武将幻化系统数据层

module("HeroTurnedData", package.seeall)

require "script/model/utils/HeroUtil"
require "script/model/hero/HeroModel"
require "db/DB_Heroes"
require "db/DB_Heros_dress"
require "db/DB_Heros_dress_id"

local _curTurnInfo 	= nil -- 当前选择的武将幻化信息
local _allTurnInfo 	= nil -- 幻化图鉴信息
local _turnAttrInfo = nil -- 幻化图鉴属性加成信息
local _unLockedNum 	= nil -- 幻化图鉴解锁的数量
local _allTurnNum 	= nil -- 所有幻化图鉴的数量

------------------------------------ 武将幻化相关 ------------------------------------

--[[
	@desc	: 设置当前选择的武将幻化信息
    @param	: pInfo 武将幻化信息
    @return	: 
—-]]
function setCurTurnInfo( pInfo )
	_curTurnInfo = pInfo
end

--[[
	@desc	: 获取当前选择的武将幻化信息
    @param	: 
    @return	: table 当前选择的武将幻化信息
—-]]
function getCurTurnInfo()
	return _curTurnInfo
end

--[[
	@desc	: 获取武将是否可以幻化
    @param	: pHid 武将id
    @return	: bool 是否可幻化
—-]]
function isCanTurned( pHid )
	local isCan = false
    if ( DataCache.getSwitchNodeState(ksSwitchHeroTurned,false) ) then
        local heroInfo = HeroUtil.getHeroInfoByHid(pHid)
    	if heroInfo then
	    	if (heroInfo.localInfo.is_dress and heroInfo.localInfo.is_dress == 1) then
	        	isCan = true
	        end
    	end
    end
	return isCan
end

--[[
	@desc	: 是否是已经解锁的幻化id(当前选择的武将)
    @param	: pTurnId 幻化id
    @return	: bool 是否已经解锁
—-]]
function isUnLockedTurnId( pTurnId )
	local isUnLock = false
	local curTurnInfo = getCurTurnInfo()
	for k,v in pairs(curTurnInfo) do
		if (tonumber(v) == tonumber(pTurnId)) then
			isUnLock = true
			break
		end
	end
	return isUnLock
end

--[[
	@desc	: 根据武将id，获取当前的幻化形象id
    @param	: pHid 武将id
    @return	: number 当前幻化形象id
—-]]
function getCurTurnedIdByHid( pHid )
	local retId = 0
	local heroInfo = HeroUtil.getHeroInfoByHid(pHid)
	if heroInfo then
		retId = tonumber(heroInfo.turned_id)
    end
	return retId
end

--[[
	@desc	: 设置当前的幻化形象id
    @param	: pHid 武将id
    @param 	: pTurnId 幻化id
    @return	: 是否有返回值，返回值说明  
—-]]
function setCurTurnedIdByHid( pHid, pTurnId )
	local heroInfo = HeroUtil.getHeroInfoByHid(pHid)
	heroInfo.turned_id = pTurnId
end

--[[
	@desc	: 根据武将id，获取当前显示的索引
    @param	: pHid 武将id
    @return	: number 显示的索引
—-]]
function getCurIndexByHid( pHid )
	local curIndex = 1
    local turnId = getCurTurnedIdByHid(pHid)
    local htid = HeroModel.getHtidByHid(pHid)
    local modelId = getHeroModelIdById(htid)
	local allTurnIds = getAllTurnIdsByModelId(modelId)
	for i,v in ipairs(allTurnIds) do
		if (turnId == tonumber(v)) then
			curIndex = i
			break
		end
	end
	return curIndex
end

--[[
	@desc	: 根据武将id，获取可幻化的id数组
    @param	: pHid 武将id
    @return	: table 可幻化的id数组
—-]]
function getAllTurnedIdsByHid( pHid )

	local htid = HeroModel.getHtidByHid(pHid)
	local modelId = getHeroModelIdById(htid)
	local allTurnIds = getAllTurnIdsByModelId(modelId)

	return allTurnIds
end

--[[
	@desc	: 根据武将id和幻化形象索引，获取幻化id
    @param	: pHid 武将id
    @param 	: pIndex 幻化形象索引
    @return	: number 幻化id
—-]]
function getTurnIdByHidAndIndex( pHid, pIndex )
	local htid = HeroModel.getHtidByHid(pHid)
	local modelId = getHeroModelIdById(htid)
	local allTurnIds = getAllTurnIdsByModelId(modelId)
	local retId = allTurnIds[pIndex] or 0
	return tonumber(retId)
end

--[[
	@desc	: 根据幻化id，获取幻化形象配置表中数据
    @param	: pTurnId 幻化id
    @return	: table 配置表中幻化数据
—-]]
function getTurnDBInfoById( pTurnId )
	pTurnId = tonumber(pTurnId)
	local retData = nil
	-- id：1-9999 是幻化形象的id;    id>10000的是武将经典形象id
	if (pTurnId > 0 and pTurnId < 10000) then
		retData = DB_Heros_dress.getDataById(pTurnId)
	elseif  (pTurnId > 10000) then
		retData = DB_Heroes.getDataById(pTurnId)
	end
	return retData
end

--[[
	@desc	: 根据幻化id，获取武将原型id
    @param	: pTurnId 幻化id
    @return	: number 武将原型id
—-]]
function getHeroModelIdById( pTurnId )
	local retId = tonumber(getTurnDBInfoById(pTurnId).model_id)
	return retId
end

--[[
	@desc	: 获取武将全身像全路径
    @param	: pTurnId 幻化id
    @return	: string 武将全身像文件路径 body_img_id
—-]]
function getHeroBodyImgById( pTurnId )
	local heroInfo = getTurnDBInfoById(pTurnId)
	local bodyImg = nil
	if (heroInfo) then
		bodyImg = "images/base/hero/body_img/"..heroInfo.body_img_id
	end
	return bodyImg
end

--[[
	@desc	: 获取武将卡牌半身像全路径
    @param	: pTurnId 幻化id
    @return	: string 武将卡牌半身像全路径 action_module_id
—-]]
function getHeroCardImgById( pTurnId )
	local heroInfo = getTurnDBInfoById(pTurnId)
	local cardImg = nil
	if (heroInfo) then
		cardImg = heroInfo.action_module_id--"images/base/hero/action_module/"..
	end
	return cardImg
end

--[[
	@desc	: 获取武将头像全路径
    @param	: pTurnId 幻化id
    @return	: string 武将头像全路径 head_icon_id
—-]]
function getHeroHeadIconById( pTurnId )
	local heroInfo = getTurnDBInfoById(pTurnId)
	local headIcon = nil
	if (heroInfo) then
		headIcon = "images/base/hero/head_icon/"..heroInfo.head_icon_id
	end
	return headIcon
end

--[[
	@desc	: 获取武将怒气头像全路径
    @param	: pTurnId 幻化id
    @return	: string 武将怒气头像全路径 rage_head_icon_id
—-]]
function getHeroRageHeadIconById( pTurnId )
	local heroInfo = getTurnDBInfoById(pTurnId)
	local readHeadIcon = nil
	if (heroInfo) then
		readHeadIcon = "images/battle/rage_head/"..heroInfo.rage_head_icon_id
	end
	return readHeadIcon
end

--[[
	@desc	: 根据幻化id，获取形象名称
    @param	: pTurnId 幻化id
    @param 	: pIndex 索引(可不传)
    @return	: string 形象名称
    默认形象→紫卡形象→橙卡形象→红卡形象→稀有形象1→稀有形象2....
—-]]
function getTurnedNameById( pTurnId, pIndex )
	pTurnId = tonumber(pTurnId)
	local retName = ""
	-- id：1-9999 是幻化形象的id;    id>10000的是武将经典形象id
	if (pTurnId > 0 and pTurnId < 10000) then
		retName = DB_Heros_dress.getDataById(pTurnId).dress_name
	elseif  (pTurnId > 10000) then
		local retData = DB_Heroes.getDataById(pTurnId)
		local potential = tonumber(retData.potential)
		if (potential == 5) then
			-- 紫卡形象
			retName = GetLocalizeStringBy("lgx_1114")
		elseif (potential == 6) then
			-- 橙卡形象
			retName = GetLocalizeStringBy("lgx_1115")
		elseif (potential == 7) then
			-- 红卡形象
			retName = GetLocalizeStringBy("lgx_1116")
		else
			-- 默认形象
			retName = GetLocalizeStringBy("lgx_1113")
		end
	else
	end

	if (pIndex == 1) then
		-- 默认形象
		retName = GetLocalizeStringBy("lgx_1113")
	end

	return retName
end

--[[
	@desc	: 根据武将模板id，获取武将名称和品质
    @param	: pTurnId 武将模板id
    @return	: string,string,number 武将名称,品质,品质数值
—-]]
function getHeroNameAndQualityById( pTurnId )
	local heroInfo = DB_Heroes.getDataById(pTurnId)
	local heroName = ""
	local heroQual = ""
	local potential = 0
	if (heroInfo) then
		heroName = heroInfo.name
		potential = tonumber(heroInfo.potential)
		if (potential == 5) then
			-- 紫
			heroQual = GetLocalizeStringBy("lgx_1120")
		elseif (potential == 6) then
			-- 橙
			heroQual = GetLocalizeStringBy("lgx_1121")
		elseif (potential == 7) then
			-- 红
			heroQual = GetLocalizeStringBy("lgx_1122")
		end
	end
	return heroName,heroQual,potential
end

--[[
	@desc	: 根据幻化形象id，获取形象获得途径
    @param	: pTurnId 形象id
    @return	: string 获得途径
—-]]
function getHeroTurnAccessById( pTurnId )
	local retStr = ""
	local turnInfo = getTurnDBInfoById(pTurnId)
	if (turnInfo) then
		retStr = turnInfo.access
	end
	return retStr
end

--[[
	@desc	: 获取幻化形象解锁提示文字
    @param	: pTurnId 形象id
    @param 	: pIsUnLock 是否解锁
    @param 	: pCurTurnId 武将当前形象id
    @param 	: pIndex 形象索引
    @return	: string 提示文字
—-]]
function getTurnUnlockNoteStr( pTurnId, pIsUnLock, pCurTurnId, pIndex )
	local retStr = ""
	if ( pIndex == 1 ) then
		-- 默认形象
		retStr = GetLocalizeStringBy("lgx_1117")
	end
	if ( pIsUnLock == false ) then
		-- 未解锁
		-- id：1-9999 是幻化形象的id;    id>10000的是武将经典形象id
		if (pTurnId > 0 and pTurnId < 10000) then
			local access = getHeroTurnAccessById(pTurnId)
			retStr = GetLocalizeStringBy("lgx_1119",access)
		elseif  (pTurnId > 10000) then
			local heroName,heroQuality,potential = getHeroNameAndQualityById(pTurnId)
			if (potential == 5) then
				 -- 紫将特殊处理
				retStr = GetLocalizeStringBy("lgx_1131",heroName)
			else
				retStr = GetLocalizeStringBy("lgx_1118",heroName,heroQuality)
			end

		end
	else
		-- 已解锁
		if  (pTurnId > 10000) then
			local heroName,heroQuality = getHeroNameAndQualityById(pTurnId)
			retStr = GetLocalizeStringBy("lgx_1127",heroQuality)
		elseif (pTurnId > 0 and pTurnId < 10000) then
			retStr = GetLocalizeStringBy("lgx_1129")
		end
	end
	return retStr
end

------------------------------------ 幻化图鉴相关 ------------------------------------

--[[
	@desc	: 设置后端返回的幻化图鉴信息
    @param	: pInfo 幻化图鉴信息
    @return	: 
—-]]
function setAllTurnInfo( pInfo )
	_allTurnInfo = {}
	for k,v in pairs(pInfo) do
		_allTurnInfo[tonumber(k)] = v
	end
end

--[[
	@desc	: 获取幻化图鉴信息
    @param	: 
    @return	: table 幻化图鉴信息
—-]]
function getAllTurnInfo()
	return _allTurnInfo
end

--[[
	@desc	: 解锁幻化图鉴
    @param	: pTurnId 幻化id
    @param 	: pModelId 武将原型id
    @return	: 
—-]]
function activeTurnByIdAndModelId( pTurnId, pModelId )
	-- 判断功能节点
	if ( not DataCache.getSwitchNodeState(ksSwitchHeroTurned,false) ) then
		return
	end
	pTurnId = tonumber(pTurnId)
	pModelId = tonumber(pModelId)

	-- 判断武将原型id是否在幻化图鉴中
	local isIn = isModelIdInIllustrate(pModelId)
	if ( isIn ) then
		-- 更新幻化图鉴信息
		if (_allTurnInfo == nil) then
			_allTurnInfo = {}
		end

		if (_allTurnInfo[pModelId] == nil) then
			_allTurnInfo[pModelId] = {}
		end

		-- 判断是否已经解锁
		local isExist = false
		for i,v in ipairs(_allTurnInfo[pModelId]) do
			if (pTurnId == tonumber(v)) then
				isExist = true
				break
			end
		end

		if (not isExist) then
			table.insert(_allTurnInfo[pModelId],pTurnId)
			-- 刷新属性加成信息
			getAllTurnAttrInfo(true)
		end
	end
end

--[[
	@desc	: 获取武将原型id是否在幻化图鉴中
    @param	: pModelId 武将原型id
    @return	: bool 是否在幻化图鉴中
—-]]
function isModelIdInIllustrate( pModelId )
	local heroDress = DB_Heros_dress_id.getDataById(tonumber(pModelId))
	if (heroDress) then
		return true
	else
		return false
	end
end

--[[
	@desc	: 获取已经解锁的幻化id数组
    @param	: pModelId 武将原型id
    @return	: table 幻化id数组
—-]]
function getUnLockedTurnArrByModelId( pModelId )
	local retData = {}
	local allTurnInfo = getAllTurnInfo()
	if (not table.isEmpty(allTurnInfo)) then
		retData = allTurnInfo[pModelId]
	end
	return retData
end

--[[
	@desc	: 是否是已经解锁的幻化id
    @param	: pTurnId 幻化id
    @param 	: pModelId 武将原型id
    @return	: bool 是否已经解锁
—-]]
function isUnLockedByIdAndModelId( pTurnId, pModelId )
	pModelId = tonumber(pModelId)
	local isUnLock = false
	local allTurnInfo = getAllTurnInfo()
	if (not table.isEmpty(allTurnInfo)) then
		local turnInfo = allTurnInfo[pModelId]
		if (not table.isEmpty(turnInfo)) then
			for k,v in pairs(turnInfo) do
				if (tonumber(v) == tonumber(pTurnId)) then
					isUnLock = true
					break
				end
			end
		end
	end
	return isUnLock
end

--[[
	@desc	: 根据国家返回，获取幻化图鉴武将信息
    @param	: pCoun 选择的国家(1 2 3 4 魏蜀吴群)
    @return	: table 幻化图鉴武将信息
—-]]
function getHerosDataByCountry( pCoun )
	local retData = {}
	local counHeros = DB_Heros_dress_id.getArrDataByField("country", pCoun)
	for k,v in pairs(counHeros) do
		local retTab = {}
		retTab.modelId = tonumber(v.model_id)
		local allIds = string.split(v.all_id, ",")
		retTab.allTurns = allIds
		table.insert(retData, retTab)
	end
	-- 按 modelId 排序
    table.sort(retData,function (v1,v2)
    	return v1.modelId > v2.modelId
	end)
	return retData
end

--[[
	@desc	: 根据武将原型id，获取武将所有可以幻化的id数组
    @param	: pModelId 武将原型id
    @return	: table 幻化id数组
—-]]
function getAllTurnIdsByModelId( pModelId )
	local retData = {0} -- 默认形象0
	local allIds = string.split(DB_Heros_dress_id.getDataById(tonumber(pModelId)).all_id, ",")
	for i,v in ipairs(allIds) do
		table.insert(retData,v)
	end
	return retData
end

--[[
	@desc	: 获取当前进度 x/y
    @param	: pModelId 武将原型id
    @return	: string 进度 x/y
—-]]
function getProgressStrByModelId( pModelId )
	local retStr = ""
	local allIds = string.split(DB_Heros_dress_id.getDataById(tonumber(pModelId)).all_id, ",")
	local unlockIds = getUnLockedTurnArrByModelId(pModelId)
	retStr = string.format("%i/%i",table.count(unlockIds),table.count(allIds))
	return retStr
end

--[[
	@desc	: 获取幻化形象的图鉴加成数组
    @param	: pTurnId 幻化id
    @return	: table 幻化形象图鉴加成数组
—-]]
function getTurnAttrArrById( pTurnId )
	local retArr = {}
	local heroInfo = getTurnDBInfoById(pTurnId)
	if ( heroInfo ) then
		if ( heroInfo.dress_pro ) then
			local proArr = string.split(heroInfo.dress_pro, ",")
			for i,v in ipairs(proArr) do
				local attrArr = string.split(v, "|")
				local attrId = tonumber(attrArr[1])
				local attrNum = tonumber(attrArr[2])
				retArr[attrId] = attrNum
			end
		end
	end
	return retArr
end

--[[
	@desc	: 获取完成度 x/y
    @param	: 
    @return	: string 完成度 x/y
—-]]
function getAllProgressStr()
	local retStr = ""
	retStr = string.format("%i/%i",_unLockedNum,_allTurnNum)
	return retStr
end

--[[
	@desc	: 计算总共的幻化图鉴数量
    @param	: 
    @return	: 
—-]]
function calculateAllTurnNum()
	if (_allTurnNum == nil) then
		_allTurnNum = 0
		for k,v in pairs(DB_Heros_dress_id.Heros_dress_id) do
			local turnNum = #(string.split(v[2], ","))
			_allTurnNum = _allTurnNum + turnNum
		end
	end
end

--[[
	@desc	: 计算所有幻化图鉴加成数组
    @param	: 
    @return	: table 所有幻化图鉴加成数组
—-]]
function calculateAllTurnAttrInfo()
	local retData = {}
	local allTurnInfo = getAllTurnInfo()
	_unLockedNum = 0
	if (not table.isEmpty(allTurnInfo)) then
		for modelId,turnIds in pairs(allTurnInfo) do
			for k,v in pairs(turnIds) do
				local attrInfo = getTurnAttrArrById(tonumber(v))
				for attrId,attrNum in pairs(attrInfo) do
					if( retData[attrId] == nil  )then
						retData[attrId] = attrNum
					else
						retData[attrId] = retData[attrId] + attrNum
					end
				end
				-- 记录幻化图鉴进度
				_unLockedNum = _unLockedNum + 1
			end
		end
	end
	return retData
end

--[[
	@desc	: 获取所有幻化图鉴属性加成信息
	@param	: pIsForce 强制重新计算
	@return : table {id = value} 属性加成信息
--]]
function getAllTurnAttrInfo( pIsForce )
	-- 判断功能节点
	if ( not DataCache.getSwitchNodeState(ksSwitchHeroTurned,false) ) then
		return {}
	else
		if (pIsForce or _turnAttrInfo == nil) then
			_turnAttrInfo = calculateAllTurnAttrInfo()
		end
	end
	return _turnAttrInfo
end

