-- Filename: TitleData.lua
-- Author: lgx
-- Date: 2016-05-04
-- Purpose: 称号系统数据处理中心

module("TitleData", package.seeall)
require "db/DB_Sign"
require "script/ui/title/TitleDef"
require "script/model/user/UserModel"
require "script/utils/TimeUtil"
require "script/ui/login/ServerList"
require "script/ui/hero/HeroPublicLua"

-- 玩家所有称号信息
local _titleInfo 	 	= nil
-- 玩家激活的称号信息
local _gotTitleInfo  	= nil
-- 装备称号属性加成信息
local _titleAttrInfo  	= nil
-- 称号图鉴属性加成信息
local _gotTitleAttrInfo = nil
-- 玩家最近获得的称号ID数组
local _lastGotTitleIds  = {}

--[[
	@desc 	: 设置玩家称号信息
	@param 	: pData 后端称号信息
	@return : 
--]]
function setTitleInfo( pData )
	_titleInfo = {}
	_gotTitleInfo = {}
	for k,v in pairs(DB_Sign.Sign) do
        local tab = DB_Sign.getDataById(v[1])
        -- 只有appear为1的称号显示在列表中
        if (tab.appear == TitleDef.kTitleAppearStatusShow) then
	        tab.isGot = TitleDef.kTitleIllustrateNotGot -- 记录是否获得过 0代表没有 1有
	        tab.deadline = 0 -- 记录失效时间 默认是0
	        -- print("signid--"..v[1])
		    -- 判断是否已经获得过
		    if (pData.title[v[1]] ~= nil or pData.title[tostring(v[1])] ~= nil) then
		    	tab.isGot = TitleDef.kTitleIllustrateHadGot
		    	tab.deadline = tonumber(pData.title[v[1]]) or tonumber(pData.title[tostring(v[1])])
		    	_gotTitleInfo[v[1]] = tab
	        end
	       	_titleInfo[v[1]] = tab
	    end
    end
    -- print("-------------titleInfo-------------")
    -- print_t(_titleInfo)
    -- print_t(_gotTitleInfo)
    -- print("-------------titleInfo-------------")
end

--[[
	@desc 	: 获取玩家称号信息
	@param 	: 
	@return : table 称号信息
--]]
function getTitleInfo()
	return _titleInfo
end

--[[
	@desc 	: 获取玩家激活的称号信息
	@param 	: 
	@return : table 激活的称号信息
--]]
function getGotTitleInfo()
	return _gotTitleInfo
end

--[[
	@desc 	: 根据称号类型获取称号信息
	@param 	: number pType 称号类型 1普通称号 2活动称号 3跨服称号
	@return : table 称号信息
--]]
function getTitleInfoByType( pType )
	local titleInfo = {}
	for k,v in pairs(_titleInfo) do
	    -- 根据称号类型
	    if (v.signtype == pType) then
	        table.insert(titleInfo,v)
        end
    end
    -- 按order排序
    table.sort(titleInfo,function (v1,v2)
    	return v1.order > v2.order
	end)
	return titleInfo
end

--[[
	@desc 	: 根据称号类型获取排序的称号列表信息
	@param 	: number pType 称号类型 1普通称号 2活动称号 3跨服称号
	@return : table 称号列表信息
--]]
function getSortedTitleInfoByType( pType )
	local titleInfo = getTitleInfoByType(pType)
	-- 称号类型内的所有称号排序方式：所有未激活称号按照称号id顺序进行排序，若激活称号，则已激活称号在上面，未获得称号在已获得称号下方。
	local getInfo = {}
	local notGetInfo = {}
	for i,v in ipairs(titleInfo) do
	    -- 根据称号状态
	    local vStatus = getTitleStatusById(v.signid)
	    if (vStatus == TitleDef.kTitleStatusEquiped or vStatus == TitleDef.kTitleStatusIsGot) then
    		-- 已激活
			table.insert(getInfo,v)
    	else
    		-- 未激活
    		table.insert(notGetInfo,v)
    	end
    end

	titleInfo = table.connect({notGetInfo,getInfo})
	
	return titleInfo
end

--[[
	@desc 	: 根据称号类型获取排序的称号图鉴列表信息
	@param 	: number pType 称号类型 1普通称号 2活动称号 3跨服称号
	@return : table 称号图鉴列表信息
--]]
function getSortedTitleIllustrateInfoByType( pType )
	local titleInfo = getTitleInfoByType(pType)
	-- 按isGot排序 已有的排上面
	local hadGotInfo = {}
	local notGetInfo = {}
	for i,v in ipairs(titleInfo) do
	    -- 根据isGot状态
	    if (v.isGot == TitleDef.kTitleIllustrateHadGot) then
    		-- 获得过
			table.insert(hadGotInfo,v)
    	else
    		-- 未获得过
    		table.insert(notGetInfo,v)
    	end
    end

	titleInfo = table.connect({notGetInfo,hadGotInfo})

	return titleInfo
end

--[[
	@desc 	: 根据称号ID获取称号信息
	@param 	: number pTitleId 称号ID
	@return : table 称号信息
--]]
function getTitleInfoById( pTitleId )
	local allTitleInfo = getTitleInfo()
	if (allTitleInfo) then
		return allTitleInfo[pTitleId]
	else
		return nil
	end
end

--[[
	@desc 	: 根据称号ID获取称号装备属性加成信息
	@param 	: number pTitleId 称号ID
	@return : table 称号装备属性加成信息
--]]
function getTitleEquipAttrInfoById( pTitleId )
	local titleInfo = getTitleInfoById(pTitleId)
	local attrInfo  = {}
	if (titleInfo) then
		local propertyTab =  parseField(titleInfo.property)
		-- print("---------------getTitleEquipAttrInfoById---------------")
		-- print_t(propertyTab)
		-- print("---------------getTitleEquipAttrInfoById---------------")
		if (type(propertyTab[1]) == "table") then
			for k,v in pairs(propertyTab) do
				local attrId = tonumber(v[1])
				local attrNum = tonumber(v[2])
				attrInfo[attrId] = attrNum
			end
		else
			local attrId = tonumber(propertyTab[1])
			local attrNum = tonumber(propertyTab[2])
			attrInfo[attrId] = attrNum
		end
	else
		print("getTitleEquipAttrInfoById pTitleId error!")
	end
	return attrInfo
end

--[[
	@desc 	: 根据称号ID获取称号图鉴属性加成信息
	@param 	: number pTitleId 称号ID
	@return : table 称号装备属性加成信息
--]]
function getTitleIllustrateAttrInfoById( pTitleId )
	local titleInfo = getTitleInfoById(pTitleId)
	local attrInfo  = {}
	if (titleInfo) then
		local showTab =  parseField(titleInfo.show)
		-- print("---------------getTitleIllustrateAttrInfoById---------------")
		-- print_t(showTab)
		-- print("---------------getTitleIllustrateAttrInfoById---------------")
		if (type(showTab[1]) == "table") then
			for k,v in pairs(showTab) do
				local attrId = tonumber(v[1])
				local attrNum = tonumber(v[2])
				attrInfo[attrId] = attrNum
			end
		else
			local attrId = tonumber(showTab[1])
			local attrNum = tonumber(showTab[2])
			attrInfo[attrId] = attrNum
		end
	else
		print("getTitleIllustrateAttrInfoById pTitleId error!")
	end
	return attrInfo
end

--[[
	@desc 	: 根据称号ID获取称号状态
	@param 	: number pTitleId 称号ID
	@return : 1 已装备 2 已获得(待装备) 3 未获得(去获取)
--]]
function getTitleStatusById( pTitleId )
	local titleInfo = getTitleInfoById(pTitleId)
	local curTitleId = UserModel.getTitleId()
	local serverTime = TimeUtil.getSvrTimeByOffset()
	local tStatus = TitleDef.kTitleStatusNotGot
	if (titleInfo.time_type == TitleDef.kTimeTypeLimited) then
		-- 限时称号
		if ((titleInfo.signid == curTitleId) and (titleInfo.isGot == TitleDef.kTitleIllustrateHadGot) and (titleInfo.deadline > serverTime)) then
			tStatus = TitleDef.kTitleStatusEquiped
		elseif ((titleInfo.isGot == TitleDef.kTitleIllustrateHadGot) and (titleInfo.deadline > serverTime)) then
			tStatus = TitleDef.kTitleStatusIsGot
		else
			tStatus = TitleDef.kTitleStatusNotGot
		end
	else
		-- 永久称号
		if ((titleInfo.signid == curTitleId) and (titleInfo.isGot == TitleDef.kTitleIllustrateHadGot)) then
			tStatus = TitleDef.kTitleStatusEquiped
		elseif (titleInfo.isGot == TitleDef.kTitleIllustrateHadGot) then
			tStatus = TitleDef.kTitleStatusIsGot
		else
			tStatus = TitleDef.kTitleStatusNotGot
		end
	end
	return tStatus
end

--[[
	@desc 	: 获取称号已激活数量
	@param 	: 
	@return : string 已激活称号数量/总称号数量
--]]
function getGotTitleString()
	local allTitleInfo = getTitleInfo()
	local gotTitleInfo = getGotTitleInfo()
	local retStr = string.format("%i/%i",table.count(gotTitleInfo),table.count(allTitleInfo))
	return retStr
end

--[[
	@desc 	: 称号是否可以批量激活(使用)
	@param 	: pTitleId 称号ID
	@return : bool 是否可以批量激活
--]]
function isCanBatchActiveById( pTitleId )
	local isCanBatchActive = false
	local titleInfo = getTitleInfoById(pTitleId)
	if (titleInfo ~= nil) then 
		if ( titleInfo.time_type == TitleDef.kTimeTypeForever ) then
			isCanBatchActive = false
		else
			isCanBatchActive = true
		end
	end
	return isCanBatchActive
end

--[[
	@desc 	: 更新获得称号的时效和状态
	@param 	: pTitleId 称号ID
	@return : 
--]]
function updateTitleIsGotAndDeadlineById( pTitleId , pItemNum )
	local titleInfo = getTitleInfoById(pTitleId)
	if (titleInfo.time_type == TitleDef.kTimeTypeLimited) then
		local serverTime = TimeUtil.getSvrTimeByOffset()
		-- 限时称号
		if (titleInfo.deadline > serverTime) then
			-- 之前的有 延长
			titleInfo.deadline = titleInfo.deadline + tonumber(titleInfo.time)*3600*pItemNum
		else
			titleInfo.deadline = serverTime + tonumber(titleInfo.time)*3600*pItemNum
		end
	else
		-- 永久称号
		titleInfo.deadline = 0
	end
	-- 更新称号图鉴信息
	if (titleInfo.isGot == TitleDef.kTitleIllustrateNotGot) then
		_gotTitleInfo[titleInfo.signid] = titleInfo
	end
	titleInfo.isGot = TitleDef.kTitleIllustrateHadGot
end

-----------------------------------------失效提示相关接口 开始-------------------------------------------
--[[
	@desc 	: 是否有失效的称号提示
	@param 	: 
	@return : bool 是否有失效的称号
--]]
function isHadDisappearTitle()
	local lastTitleId = getLastDisappearTitleId()
	-- print("isHadDisappearTitle",lastTitleId)
	if (lastTitleId > 0) then
		return true
	else
		return false
	end
end

--[[
	@desc 	: 设置本地记录失效的称号ID
	@param 	: pTitleId 称号ID
	@return : 
--]]
function setLastDisappearTitleId( pTitleId )
    local group = ServerList.getSelectServerInfo().group
    local uid   = UserModel.getUserUid()
    CCUserDefault:sharedUserDefault():setIntegerForKey("lastTitleId_"..group.."_"..uid, pTitleId)
    CCUserDefault:sharedUserDefault():flush()
end

--[[
	@desc 	: 获取本地记录失效的称号ID
	@param 	: 
	@return : number 称号ID
--]]
function getLastDisappearTitleId()
	local group = ServerList.getSelectServerInfo().group
    local uid   = UserModel.getUserUid()
	local lastTitleId = CCUserDefault:sharedUserDefault():getIntegerForKey("lastTitleId_"..group.."_"..uid) or 0
	return lastTitleId
end
-----------------------------------------失效提示相关接口 结束-------------------------------------------

-----------------------------------------红点提示相关接口 开始-------------------------------------------
--[[
	@desc 	: 设置最近获得的称号ID
	@param 	: pTitleID 最近获得的称号ID
	@return : 
--]]
function setLastGotTitleIdToArr( pTitleId )
	if ( pTitleId and tonumber(pTitleId) > 0) then
		_lastGotTitleIds[pTitleId] = pTitleId
	end
end

--[[
	@desc 	: 获取最近获得的称号ID
	@param 	: 
	@return : table 称号ID数组
--]]
function getLastGotTitleIds()
	return _lastGotTitleIds
end

--[[
	@desc 	: 移除最近获得的称号ID数组
	@param 	: 
	@return : 
--]]
function clearLastGotTitleIds()
	_lastGotTitleIds = {}
end

--[[
	@desc 	: 是否应该显示称号红点 功能按钮/称号入口按钮
	@param 	: 
	@return : bool 是否应该显示称号红点
--]]
function isNeedShowRedTip()
	local lastGotTitleIds = getLastGotTitleIds()
	local isNeedShow = (not table.isEmpty(lastGotTitleIds))
	return isNeedShow
end

--[[
	@desc 	: 是否应该显示称号红点 称号类型标签
	@param 	: pType 称号类型 signtype 1普通称号，2活动称号，3跨服称号
	@return : bool 是否应该显示称号红点
--]]
function isNeedShowRedTipByType( pType )
	local lastGotTitleIds = getLastGotTitleIds()
	local isNeedShow = false
	for k,v in pairs(lastGotTitleIds) do
		local titleType = DB_Sign.getDataById(tonumber(k)).signtype
		if (pType == titleType) then
			isNeedShow = true
			break
		end
	end
	return isNeedShow
end

-----------------------------------------红点提示相关接口 结束-------------------------------------------

------------------------------------------战斗力加成相关接口 开始--------------------------------------------
--[[
	@desc 	: 计算装备称号属性加成信息
	@param 	: property_type
	@return : table {
				[TitleDef.kTitleAttrOwn] => {id = value} -- 主角加成
				[TitleDef.kTitleAttrAll] => {id = value} -- 全体上阵武将加成
			} 属性加成信息
--]]
function calculateEquipTitleAttrInfo()
	local retData = {}
	local curTitleId = UserModel.getTitleId()
	if (curTitleId > 0) then
		local titleInfo = getTitleInfoById(curTitleId)
		if (titleInfo.property_type == TitleDef.kTitleAttrOwn) then
			-- 主角加成
			retData[TitleDef.kTitleAttrOwn] = getTitleEquipAttrInfoById(curTitleId)
			retData[TitleDef.kTitleAttrAll] = {}
		else
			-- 全体上阵武将加成
			retData[TitleDef.kTitleAttrAll] = getTitleEquipAttrInfoById(curTitleId)
			retData[TitleDef.kTitleAttrOwn] = {}
		end
	end
	return retData
end

--[[
	@desc 	: 计算称号图鉴属性加成信息 给全体上阵武将加
	@param 	: 
	@return : table {id = value} 全体上阵武将加成属性加成信息
--]]
function calculateGotTitleAttrInfo()
	local retData = {}
	local gotTitleInfo = getGotTitleInfo()
	if (gotTitleInfo) then
		for k,v in pairs(gotTitleInfo) do
			local attrTab = getTitleIllustrateAttrInfoById(v.signid)
			for attrId,attrNum in pairs(attrTab) do
				if( retData[attrId] == nil  )then
					retData[attrId] = attrNum
				else
					retData[attrId] = retData[attrId] + attrNum
				end
			end
		end
	end
	return retData
end

--[[
	@desc	: 获取装备称号属性加成信息
	@param	: pHid 武将hid pIsForce 强制重新计算
	@return : table {id = value} -- 主角加成 或 全体上阵武将加成 装备称号属性加成信息
--]]
function getEquipTitleAttrInfoByHid( pHid, pIsForce )
	if (pIsForce or _titleAttrInfo == nil) then
		_titleAttrInfo = calculateEquipTitleAttrInfo()
	end
	local heroTitleAttr = {}
	if (pHid == nil) then
		return heroTitleAttr
	end
	local curTitleId = UserModel.getTitleId()
	if (curTitleId > 0) then
		local titleInfo = getTitleInfoById(curTitleId)
		if (titleInfo.property_type == TitleDef.kTitleAttrOwn) then
			-- 主角加成
			if (HeroModel.getNecessaryHero() ~= nil and HeroModel.getNecessaryHero().hid ~= nil) then
				local hid = tonumber(HeroModel.getNecessaryHero().hid)
				if (tonumber(pHid) == hid) then
					heroTitleAttr = _titleAttrInfo[TitleDef.kTitleAttrOwn]
				end
			end
		else
			-- 全体上阵武将加成
			local isOnFormation = HeroPublicLua.isOnFormation(pHid)
			-- 判断是否上阵
			if (isOnFormation) then
				heroTitleAttr = _titleAttrInfo[TitleDef.kTitleAttrAll]
			end
		end
	end

	-- print("-----------------------getEquipTitleAttrInfoByHid---------------------")
	-- print_t(heroTitleAttr)
	-- print("-----------------------getEquipTitleAttrInfoByHid---------------------")

	return heroTitleAttr
end

--[[
	@desc	: 获取称号图鉴属性属性加成信息
	@param	: pIsForce 强制重新计算
	@return : table {id = value} 称号图鉴属性加成信息
--]]
function getGotTitleAttrInfo( pIsForce )
	if (pIsForce or _gotTitleAttrInfo == nil) then
		_gotTitleAttrInfo = calculateGotTitleAttrInfo()
	end

	-- print("-----------------------getGotTitleAttrInfo---------------------")
	-- print_t(_gotTitleAttrInfo)
	-- print("-----------------------getGotTitleAttrInfo---------------------")
	
	return _gotTitleAttrInfo
end

------------------------------------------战斗力加成相关接口 结束--------------------------------------------
